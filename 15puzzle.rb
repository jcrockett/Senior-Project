require 'gosu'

#This class represents just one tile.
class Piece
	def initialize(window, image, x, y)
		@window = window
		@image = image
		@x = x
		@y = y
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
		@x == blank.get_x and @y == blank.get_y + 155
	end

	#true if the piece is below the blank
	def below?(blank)
		@x == blank.get_x and @y == blank.get_y - 155
	end

	#true if the piece is to the left of the blank
	def left_of?(blank)
		@x == blank.get_x - 155 and @y == blank.get_y
	end

	#true if the piece is to the right of the blank
	def right_of?(blank)
		@x == blank.get_x + 155 and @y == blank.get_y
	end

	#returns the piece's x value
	def get_x
		@x
	end

	#returns the piece's y value
	def get_y
		@y
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

#this class represents one full 15-puzzle
class Puzzle
	#the puzzle (coordinates of all pieces) and the solution (coordinates of where they should be) need to be accessible outside of this class
	attr_reader :puzzle, :solution
	def initialize(window, image, location)
		@window = window
		@image = image
		#a built-in function that divides an image into even tiles in an array
		#the 3rd and 4th arguments determine how many tiles will be made down and across
		#if those values are positive, they represent the number of pixels for each tile
		#if those values are negative, they represent the number of tiles (4 across, 4 down)
		@tiles = Gosu::Image.load_tiles(@window, @image, -4, -4, true)
		#this is where the puzzle starts
		@location = location
		@positions = []
		#here we make an array of positions for the tiles
		for i in 0..3
			for j in 0..3
				@positions << [(@location + (j * 155)), (25 + (i * 155))]
			end
		end
		@puzzle = []
		@solution = []
		#here we make one piece for each tile/coordinate pair
		for i in 0..15
			@puzzle << Piece.new(self, @tiles[i], @positions[i][0], @positions[i][1])
		end
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
		@solution << move
	end

	#takes in the id of a piece and returns the direction in which it can move into the blank (or "no" if it can't)
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
					solution << ["l", i]
				elsif find_direction(i) == "r"
					@puzzle[i].right
					@puzzle[3].left
					solution << ["r", i]
				elsif find_direction(i) == "d"
					@puzzle[i].down
					@puzzle[3].up
					solution << ["d", i]
				elsif find_direction(i) == "u"
					@puzzle[i].up
					@puzzle[3].down
					solution << ["u", i]
				else
					#or do nothing if it can't be moved
				end
			end
		end
	end

	#returns the blank tile
	def get_blank
		@puzzle[3]
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

#this class represents two puzzles put together, the normal one and the perfect one
class TwoPuzzle
	def initialize(window, normal, perfect)
		@window = window
		@normal = normal
		@perfect = perfect
	end

	#this scrambles the normal puzzle by doing random_move (from the Puzzle class) 100 times
	def scramble
		for i in 0..100
			@normal.random_move
		end
		#if the blank isn't in the correct position, we scramble again
		if(@normal.get_blank.get_x != 15 or @normal.get_blank.get_y != 25)
			scramble
		end
	end

	#this just uses the move_tiles method (from the Puzzle class) on the normal puzzle	
	def move_tiles
		@normal.move_tiles
	end

	#this solves the normal puzzle and scrambles the perfect one
	def solve
		perfect_positions = []
		#here we find the perfect tile that would be moving if we moved each normal tile
		#for each tile in the scrambled normal puzzle, the corresponding perfect tile is the one currently at the same height and on the opposite end of the row
		#the loop adds them in an order based on the index number of the normal piece
		for i in 0..15
			for j in 0..15
				if((@normal.puzzle[i].get_x - 15) == (1115 - @perfect.puzzle[j].get_x) and @normal.puzzle[i].get_y == @perfect.puzzle[j].get_y)
					perfect_positions << j
				end
			end
		end
		#this loop runs until there are no more moves to undo
		while @normal.solution.length > 0
			#we simultaneously delete a move from the solution and store it in "move"
			move = @normal.solution.pop()
			#just some stuff we did to check some stuff
			puts @normal.solution.last.inspect
			#we undo the move on the normal puzzle
			@normal.solve_step(move[0], move[1])
			#if the move was left or right, its the opposite for the perfect puzzle, but if its up or down then its the same
			if(move[0] == "r")
				@perfect.solve_step("l", perfect_positions[move[1]])
			elsif(move[0] == "l")
				@perfect.solve_step("r", perfect_positions[move[1]])
			else
				@perfect.solve_step(move[0], perfect_positions[move[1]])
			end
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
		@normal = Puzzle.new(self, "perfect face/smaller_perfect.jpg", 15)
		@perfect = Puzzle.new(self, "normal face/normal.jpg", 650)
		@puzzle = TwoPuzzle.new(self, @normal, @perfect)
	end

	#this lets us see and use the cursor inside the window
	def needs_cursor?
    	true
	end

	#this checks if the "scramble" button is being clicked and scrambles the puzzle if it is
	def scramble
		if button_down? Gosu::MsLeft and mouse_x > 110 and mouse_x < 265 and mouse_y > 645 and mouse_y < 695
			@puzzle.scramble
		end
	end

	#this checks if the "solve" button is being clicked and solves the puzzle if it is
	def solve
		if button_down? Gosu::MsLeft and mouse_x > 360 and mouse_x < 515 and mouse_y > 645 and mouse_y < 695
			@puzzle.solve
		end
	end

	#this is the update function (built into gosu) that does all of these things over and over
	def update
		scramble
		solve
		@puzzle.move_tiles
	end

	#this draws everything
	def draw
		@background.draw(0, 0, 0)
		@puzzle.draw
		@scramble_button.draw(100, 645, 0)
		@solve_button.draw(350, 645, 0)
	end
end

window = PuzzleWindow.new
window.show
