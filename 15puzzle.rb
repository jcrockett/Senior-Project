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
	end

	def is_solvable?
		count = 0
		indices = []
		for i in 0..15
			for j in 0..15
				if(@puzzle[i].get_x == @solution[j].get_x and @puzzle[i].get_y == @solution[j].get_y)
					indices << j
				end
			end
		end
		puts indices
		for i in 0..15
			if(i != 3)
				for j in i..15
					if(indices[j] > indices[i] and j != 3)
						count = count + 1
					end
				end
			end
		end
		puts count
		if(count%2 != 0)
			true
		else
			false
		end
	end

	def mix
		temp_puzzle = []
		temp_positions = @positions
		while temp_positions[3] != @positions[0]
			temp_positions = temp_positions.shuffle
		end
		for i in 0..15
			temp_puzzle << Piece.new(self, @tiles[i], temp_positions[i][0], temp_positions[i][1])
		end
		@puzzle = temp_puzzle
	end

	def scramble
		mix
		while(!is_solvable?)
			mix
		end
	end
		

	def legit_shuffle
		moves = []
		for i in 0..15
			direction = find_direction(i)
			if direction != "no"
				moves << [direction, i]
			end
		end
		puts moves.inspect
		puts " "
		move = moves.shuffle[0]
		puts move.inspect
		puts " "
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

	def solve
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
		puts "like your mom did"
		@normal.legit_shuffle
	end
	
	def move_tiles
		@normal.move_tiles
	end

	def solve
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
		@normal = Puzzle.new(self, "Thing.png", 15)
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

	def update
		scramble
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
