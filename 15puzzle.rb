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

	def move_tiles
		for i in 0..15
			if @puzzle[i].is_clicked?(@window)
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
				end
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

	def solve
		perfect_positions = []
		for i in 0..15
			for j in 0..15
				if((@normal.puzzle[i].get_x - 15) == (1115 - @perfect.puzzle[j].get_x) and @normal.puzzle[i].get_y == @perfect.puzzle[j].get_y)
					perfect_positions << j
				end
			end
		end
		while @normal.solution.length > 0
			move = @normal.solution.pop()
			#pmove = move.map { |c| c == "l" ? "r" : c }
			#pmove.map! { |c| c == "r" ? "l" : c }
			puts @normal.solution.last.inspect
			@normal.solve_step(move[0], move[1])
			if(move[0] == "r")
				@perfect.solve_step("l", perfect_positions[move[1]])
			elsif(move[0] == "l")
				@perfect.solve_step("r", perfect_positions[move[1]])
			else
				@perfect.solve_step(move[0], perfect_positions[move[1]])
			end
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
