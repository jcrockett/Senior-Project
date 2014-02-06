require 'gosu'

class Piece
	def initialize(window, image, x, y)
		@window = window
		@image = image
		@x = x
		@y = y
	end

	def left
		@x -= 155
	end

	def right
		@x += 155
	end

	def down
		@y -= 155
	end

	def up
		@y += 155
	end

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
	
	def above?(blank)
		@x == blank.get_x and @y == blank.get_y + 155
	end

	def below?(blank)
		@x == blank.get_x and @y == blank.get_y - 155
	end

	def left_of?(blank)
		@x == blank.get_x - 155 and @y == blank.get_y
	end

	def right_of?(blank)
		@x == blank.get_x + 155 and @y == blank.get_y
	end

	def get_x
		@x
	end

	def get_y
		@y
	end
	
	def is_clicked?(window)
		window.button_down? Gosu::MsLeft and window.mouse_x > @x and window.mouse_x < @x + 155 and window.mouse_y > @y and window.mouse_y < @y + 155
	end

	def draw
		@image.draw(@x, @y, 0, 0.7, 0.7)
	end
end

class Puzzle
	attr_reader :puzzle, :solution
	def initialize(window, image, location)
		@window = window
		@image = image
		@tiles = Gosu::Image.load_tiles(@window, @image, -4, -4, true)
		@location = location
		@positions = []
		for i in 0..3
			for j in 0..3
				@positions << [(@location + (j * 155)), (25 + (i * 155))]
			end
		end
		@puzzle = []
		@solution = []
		for i in 0..15
			@puzzle << Piece.new(self, @tiles[i], @positions[i][0], @positions[i][1])
		end
		@blank_goal = @puzzle[0]
	end

	def random_move
		moves = []
		for i in 0..15
			direction = find_direction(i)
			if direction != "no"
				moves << [direction, i]
			end
		end
		move = moves.shuffle[0]
		@puzzle[move[1]].move(move[0], @puzzle[3])
		@solution << move
	end

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

	def move_tiles
		for i in 0..15
			if @puzzle[i].is_clicked?(@window)
				if find_direction(i) == "l"
					@puzzle[i].left
					@puzzle[3].right
				elsif find_direction(i) == "r"
					@puzzle[i].right
					@puzzle[3].left
				elsif find_direction(i) == "d"
					@puzzle[i].down
					@puzzle[3].up
				elsif find_direction(i) == "u"
					@puzzle[i].up
					@puzzle[3].down
				else
				end

			end
		end
	end

	def solve_step(dir)
		for i in 0..15
			if(dir == "l")
				if(@puzzle[i].left_of?(@puzzle[3]))
					@puzzle[i].right
					@puzzle[i].left
				end
			elsif(dir == "r")
				if(@puzzle[i].right_of?(@puzzle[3]))
					@puzzle[i].left
					@puzzle[i].right
				end
			elsif(dir == "u")
				if(@puzzle[i].above?(@puzzle[3]))
					@puzzle[i].down
					@puzzle[i].up
				end
			elsif(dir == "d")
				if(@puzzle[i].below?(@puzzle[3]))
					@puzzle[i].up
					@puzzle[i].down
				end
			else
			end
		end
	end

	def get_blank
		@puzzle[3]
	end

	def get_blank_goal
		@blank_goal
	end

	def draw
		for i in 0..15
			if i != 3
				@puzzle[i].draw
			end
		end
	end
end

class TwoPuzzle
	def initialize(window, normal, perfect)
		@window = window
		@normal = normal
		@perfect = perfect
	end

	def scramble
		for i in 0..100
			@normal.random_move
		end
		if(@normal.get_blank.get_x != 15 or @normal.get_blank.get_y != 25)
			scramble
		end
	end
	
	def move_tiles
		@normal.move_tiles
	end

	def solve_step(dir)
		if(dir == "r")
			for i in 0..15
				if(@normal.puzzle[i].right_of?(@normal.puzzle[3]))
					@normal.puzzle[i].left
					@normal.puzzle[3].right
				end
			end
		elsif(dir == "l")
			for i in 0..15
				if(@normal.puzzle[i].left_of?(@normal.puzzle[3]))
					@normal.puzzle[i].right
					@normal.puzzle[3].left
				end
			end
		elsif(dir == "u")
			for i in 0..15
				if(@normal.puzzle[i].below?(@normal.puzzle[3]))
					@normal.puzzle[i].up
					@normal.puzzle[3].down
				end
			end
		elsif(dir == "d")
			for i in 0..15
				if(@normal.puzzle[i].above?(@normal.puzzle[3]))
					@normal.puzzle[i].down
					@normal.puzzle[3].up
				end
			end
		else
		end
	end

	def solve
		count = @normal.solution.length - 1
		puts @normal.solution[@normal.solution.length-1][0]
		while(count >= 0)
			puts count
			solve_step(@normal.solution[count][0])
			@normal.solution.delete_at(count)
			count = count - 1
		end
	end
	
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
		@normal = Puzzle.new(self, "normal face/normal.jpg", 15)
		@perfect = Puzzle.new(self, "perfect face/smaller_perfect.jpg", 650)
		@puzzle = TwoPuzzle.new(self, @normal, @perfect)
	end

	def needs_cursor?
    	true
	end
	
	def scramble
		if button_down? Gosu::MsLeft and mouse_x > 110 and mouse_x < 265 and mouse_y > 645 and mouse_y < 695
			@puzzle.scramble
		end
	end

	def solve
		if button_down? Gosu::MsLeft and mouse_x > 360 and mouse_x < 515 and mouse_y > 645 and mouse_y < 695
			@puzzle.solve
		end
	end

	def update
		scramble
		solve
		@puzzle.move_tiles
	end

	def draw
		@background.draw(0, 0, 0)
		@puzzle.draw
		@scramble_button.draw(100, 645, 0)
		@solve_button.draw(350, 645, 0)
	end
end

window = PuzzleWindow.new
window.show
