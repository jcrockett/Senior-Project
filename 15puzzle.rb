require 'gosu'

#This class represents just one tile.
class Piece
	attr_reader :x, :y, :image, :target_x, :target_y
	def initialize(window, image, x, y, target_x, target_y)
		@window = window
		@image = image
		@x = x
		@y = y
		@target_x = target_x
		@target_y = target_y
	end

	def set_x(val)
		@x = val
	end

	def set_y(val)
		@y = val
	end

	#moves the piece left
	def left
		@x -= 155
	end

	#moves the piece right
	def right
		@x += 155
	end

	#moves the piece down
	def down
		@y -= 155
	end

	#moves the piece up
	def up
		@y += 155
	end

	#takes in a character (representing a the direction to move) and the blank piece
	#switches the piece with the blank piece (which visually just looks like moving the piece into the empty spot)
	def move(dir, blank)
		if(dir == "l")
			left
			blank.right
		elsif(dir == "r")
			right
			blank.left
		elsif(dir == "d")
			down
			blank.up
		elsif(dir == "u")
			up
			blank.down
		else
			"what the what"
		end
	end
	
	#true if the piece is above the blank
	def above?(blank)
		@x == blank.x and @y == blank.y + 155
	end

	#true if the piece is below the blank
	def below?(blank)
		@x == blank.x and @y == blank.y - 155
	end

	#true if the piece is to the left of the blank
	def left_of?(blank)
		@x == blank.x - 155 and @y == blank.y
	end

	#true if the piece is to the right of the blank
	def right_of?(blank)
		@x == blank.x + 155 and @y == blank.y
	end
	
	#true if the piece is currently being clicked (if the mouse button is down within its coordinates)
	#takes in "window" because it is needed for button_down?, mouse_x, and mouse_y
	def is_clicked?(window)
		window.button_down? Gosu::MsLeft and window.mouse_x > @x and window.mouse_x < @x + 155 and window.mouse_y > @y and window.mouse_y < @y + 155
	end

	#draws the piece at x and y (with a z coordinate of 0)
	#scales the piece down to 70 percent width and height
	def draw
		@image.draw(@x, @y, 0, 0.7, 0.7)
	end
end

#represents one full 15-puzzle
class Puzzle
	#the puzzle (coordinates of all pieces) and the solution (coordinates of where they should be) need to be accessible outside of this class
	attr_reader :puzzle, :solve_steps, :solved, :solution
	def initialize(window, image, location)
		@window = window
		@image = image
		#a built-in function that divides an image into even tiles in an array
		#the 3rd and 4th arguments determine how many tiles will be made down and across
		#if those values are positive, they represent the number of pixels for each tile
		#if those values are negative, they represent the number of tiles (4 across, 4 down)
		@tiles = Gosu::Image.load_tiles(@window, @image, -4, -4, true)
		#where the puzzle starts
		@location = location
		@positions = []
		#make an array of positions for the tiles
		for i in 0..3
			for j in 0..3
				@positions << [(@location + (j * 155)), (25 + (i * 155))]
			end
		end
		@puzzle = []
		@solution = []
		@solve_steps = []
		#make one piece for each tile/coordinate pair
		for i in 0..15
			@puzzle << Piece.new(self, @tiles[i], @positions[i][0], @positions[i][1], @positions[i][0], @positions[i][1])
			@solution << Piece.new(self, @tiles[i], @positions[i][0], @positions[i][1], @positions[i][0], @positions[i][1])
		end
		#all initial calls of the puzzle are true
		@solved = true
	end

	#this finds all the moves that can be made based on the position of the blank, and selects a random one
	def random_move
		moves = []
		#for each piece, the move array receives a direction (if it is next to the blank) or nothing at all
		for i in 0..15
			direction = find_direction(i)
			if direction != "no"
				moves << [direction, i]
			end
		end
		#here we select a random one from all the possible moves
		move = moves.shuffle[0]
		#we find the piece with the correct index, and we move it
		@puzzle[move[1]].move(move[0], @puzzle[3])
		#finally, we add the move to the solution
		@solve_steps << move
		#not necessarily true (we can move them into solved position), but for our purposes, it doesn't matter
		@solved = false
	end

	#takes in the ID of a piece and returns the direction in which it can move into the blank (or "no" if it can't)
	def find_direction(id)
		if @puzzle[id].right_of?(@puzzle[3])
			"l"
		elsif @puzzle[id].left_of?(@puzzle[3])
			"r"
		elsif @puzzle[id].above?(@puzzle[3])
			"d"
		elsif @puzzle[id].below?(@puzzle[3])
			"u"
		else
			"no"
		end
	end

	#takes in a direction and a piece to move
	#moves the piece in the direction and the blank in the opposite direction
	#for this, the character does not represent the direction the piece needs to move in
	#instead, it represents the direction the piece moved in when it did the move that is being undone
	def solve_step(dir, i)
		if(dir == "r")
			@puzzle[i].left
			@puzzle[3].right
		elsif(dir == "l")
			@puzzle[i].right
			@puzzle[3].left
		elsif(dir == "d")
			@puzzle[i].up
			@puzzle[3].down
		elsif(dir == "u")
			@puzzle[i].down
			@puzzle[3].up
		else
			puts "error"
		end
	end

	#checks each tile to see if it is being clicked, and moves it if it can move and is being clicked
	def move_tiles
		for i in 0..15
			#if the tile is clicked...
			if @puzzle[i].is_clicked?(@window)
				#move it
				if find_direction(i) == "l"
					@puzzle[i].left
					@puzzle[3].right
					solve_steps << ["l", i]
					#not necessarily true (we can move them into solved position), but for our purposes, it doesn't matter
					puzzle_status(false)
				elsif find_direction(i) == "r"
					@puzzle[i].right
					@puzzle[3].left
					solve_steps << ["r", i]
					#not necessarily true (we can move them into solved position), but for our purposes, it doesn't matter
					puzzle_status(false)
				elsif find_direction(i) == "d"
					@puzzle[i].down
					@puzzle[3].up
					solve_steps << ["d", i]
					#not necessarily true (we can move them into solved position), but for our purposes, it doesn't matter
					puzzle_status(false)
				elsif find_direction(i) == "u"
					@puzzle[i].up
					@puzzle[3].down
					solve_steps << ["u", i]
					#not necessarily true (we can move them into solved position), but for our purposes, it doesn't matter
					puzzle_status(false)
				else
					#or do nothing if it can't be moved
				end
			end
		end
	end

	def puzzle_status(status)
		@solved = status
	end

	def is_goal?
		for i in 0..15
			if(@puzzle[i].x != @puzzle[i].target_x or @puzzle[i].y != @puzzle[i].target_y)
				return false
			end
		end
		return true
	end
		
	#putting all pieces back in order
	def quick_solve
		for i in 0..15 #puzzle
			for j in 0..15 #solution
				if @puzzle[i].image == @solution[j].image
					@puzzle[i].set_x(@solution[j].x)
					@puzzle[i].set_y(@solution[j].y)
				end
			end
		end	
	end

	#draws the entire puzzle
	def draw
		for i in 0..15
			if i != 3
				@puzzle[i].draw
			end
		end
	end
end

#represents two puzzles put together, the normal one and the perfect one
class TwoPuzzle
	attr_reader :perfect, :normal
	def initialize(window, normal, perfect)
		@window = window
		@normal = normal
		@perfect = perfect
	end

	#scrambles the normal puzzle by doing random_move (from the Puzzle class) 100 times
	def scramble
		for i in 0..100
			@normal.random_move
		end
		#if the blank isn't in the correct position, we scramble again
		if(@normal.puzzle[3].x != 15 or @normal.puzzle[3].y != 25)
			scramble
		end
		@perfect.puzzle_status(false)
		if !@perfect.solved
			@perfect.quick_solve
		end
	end

	#uses the move_tiles method (from the Puzzle class) on the normal puzzle	
	def move_tiles
		@normal.move_tiles
		puts @perfect.solved
		#if !@perfect.solved 
		#	@perfect.quick_solve
		#end
	end

	#solves the normal puzzle and scrambles the perfect one
	def solve
		#if the blank isn't in the upper left corner, then it can't solve
		if @normal.puzzle[3].x == 15 && @normal.puzzle[3].y == 25
			perfect_positions = []
			#finds the perfect tile that would be moving if we moved each normal tile
			#for each tile in the scrambled normal puzzle, the corresponding perfect tile is the one currently at the same height and on the opposite end of the row
			#the loop adds them in an order based on the index number of the normal piece
			for i in 0..15
				for j in 0..15
					if((@normal.puzzle[i].x - 15) == (1115 - @perfect.puzzle[j].x) and @normal.puzzle[i].y == @perfect.puzzle[j].y)
						perfect_positions << j
					end
				end
			end
			#runs until there are no more moves to undo
			while @normal.solve_steps.length > 0
				#we simultaneously delete a move from the solution and store it in "move"
				move = @normal.solve_steps.pop()
				#just checking things
				puts @normal.solve_steps.last.inspect
				#we undo the move on the normal puzzle
				@normal.solve_step(move[0], move[1])
				#if the move was left or right, it's the opposite for the perfect puzzle, but if it's up or down then its the same
				if(move[0] == "r")
					@perfect.solve_step("l", perfect_positions[move[1]])
				elsif(move[0] == "l")
					@perfect.solve_step("r", perfect_positions[move[1]])
				else
					@perfect.solve_step(move[0], perfect_positions[move[1]])
				end
			end
		end
	end

	def toggle
		if(@normal.is_goal? and !@perfect.is_goal?)
			normal_positions = []
			for i in 0..15
				for j in 0..15
					if((@perfect.puzzle[i].x - 15) == (1115 - @normal.puzzle[j].x) and @perfect.puzzle[i].y == @normal.puzzle[j].y)
						normal_positions << j
					end
				end
			end
			@perfect.quick_solve
			for i in 0..15
				if((@normal.puzzle[i].target_x - 15) == (@perfect.puzzle[normal_positions[i]].target_x - 650) and @normal.puzzle[i].target_y == @perfect.puzzle[normal_positions[i]].target_y)
					@normal.puzzle[i].set_x(15 + (1115 - (@perfect.puzzle[normal_positions[i]].x + 155)))
					@normal.puzzle[i].set_y(@perfect.puzzle[normal_positions[i]].y)
				end
			end
		elsif(@perfect.is_goal? and !@normal.is_goal?)
			puts "perfect is solved"
			@normal.quick_solve
			for i in 0..15
				for j in 0..15
					if((@perfect.puzzle[i].target_x - 650) == (@normal.puzzle[j].target_x - 15) and @perfect.puzzle[i].target_y == @normal.puzzle[i].target_y)
						@perfect.puzzle[i].set_x(1115 - (115 + (@normal.puzzle[j].x - 15)))
						@perfect.puzzle[i].set_y(@normal.puzzle[j].y)
					end
				end
			end
		end
		puts "toggle successful"
	end

	#saves the arrangement of puzzle pieces
	def save
		normal = []
		perfect = []
		#gets the arrangement of the normal side
		puts @normal.puzzle.inspect
		puts @perfect.puzzle.inspect
		for i in 0..15 #puzzle
			for j in 0..15 #solution
				if @normal.puzzle[i].image == @normal.solution[j].image
					normal << [@normal.puzzle[i].x, @normal.puzzle[i].y]
				end
			end
		end
		#gets the arrangement of the perfect side
		for i in 0..15 #puzzle
			for j in 0..15 #solution
				if @perfect.puzzle[i].image == @perfect.solution[j].image
					perfect << [@perfect.puzzle[i].x, @perfect.puzzle[i].y]
				end
			end
		end
		#creates a file with the saved coordinates
		File.open("savepuzzle.txt", "a") do |file|
			for i in 0..(normal.length-1)
				normal[i] = normal[i].join(",")
			end
			for i in 0..(perfect.length-1)
				perfect[i] = perfect[i].join(",")
			end
			save_string = normal.join(";") + ":" + perfect.join(";")
			file.puts save_string
		end
	end

	#draws both puzzles
	def draw
		@normal.draw
		@perfect.draw
	end
end

class PuzzleWindow < Gosu::Window
	def initialize
		super(1280, 700, false)
		self.caption = "Jenni_Puzzle"
		@background = Gosu::Image.new(self, "background.jpg", true)
		@scramble_button = Gosu::Image.new(self, "buttons/scramble.tiff", true)
		@solve_button = Gosu::Image.new(self, "buttons/solve.tiff", true)
		@save_button = Gosu::Image.new(self, "buttons/save.tiff", true)
		@toggle_button = Gosu::Image.new(self, "buttons/toggle.tiff", true)
		@normal = Puzzle.new(self, "perfect face/smaller_perfect.jpg", 15)
		@perfect = Puzzle.new(self, "normal face/normal.jpg", 650)
		@puzzle = TwoPuzzle.new(self, @normal, @perfect)
	end

	#lets us see and use the cursor inside the window
	def needs_cursor?
    	true
	end

	#checks if the "scramble" button is being clicked and scrambles the puzzle if it is
	def scramble
		if button_down? Gosu::MsLeft and mouse_x > 220 and mouse_x < 457 and mouse_y > 640 and mouse_y < 695
			@puzzle.scramble
		end
	end

	#checks if the "solve" button is being clicked and solves the puzzle if it is
	def solve
		if button_down? Gosu::MsLeft and mouse_x > 470 and mouse_x < 707 and mouse_y > 640 and mouse_y < 695
			@puzzle.solve
		end
	end

	#checks if the "save" button is being clicked and saves the puzzle if it is
	def save
		if button_down? Gosu::MsLeft and mouse_x > 720 and mouse_x < 957 and mouse_y > 640 and mouse_y < 695
			@puzzle.save
		end
	end

	def toggle
		if button_down? Gosu::MsLeft and mouse_x > 870 and mouse_x < 957 and mouse_y > 640 and mouse_y < 695
			@puzzle.toggle
		end
	end

	#the update function (built into gosu) that does all of these things over and over
	def update
		scramble
		solve
		save
		toggle
		@puzzle.move_tiles
	end

	#draws everything
	def draw
		@background.draw(0, 0, 0)
		@puzzle.draw
		@scramble_button.draw(220, 640, 0)
		@solve_button.draw(470, 640, 0)
		@save_button.draw(720, 640, 0)
		@toggle_button.draw(870, 640, 0)
	end
end

window = PuzzleWindow.new
window.show
