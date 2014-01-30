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
		for i in 0..15
			@puzzle << Piece.new(self, @tiles[i], @positions[i][0], @positions[i][1])
		end
	end

	def scramble
	end

	def move_tiles
		for i in 0..15
			if @puzzle[i].is_clicked?(@window)
				if @puzzle[i].get_x == @puzzle[3].get_x + 155 and @puzzle[i].get_y == @puzzle[3].get_y
					@puzzle[i].left
					@puzzle[3].right
				elsif @puzzle[i].get_x == @puzzle[3].get_x - 155 and @puzzle[i].get_y == @puzzle[3].get_y
					@puzzle[i].right
					@puzzle[3].left
				elsif @puzzle[i].get_x == @puzzle[3].get_x and @puzzle[i].get_y == @puzzle[3].get_y + 155
					@puzzle[i].down
					@puzzle[3].up
				elsif @puzzle[i].get_x == @puzzle[3].get_x and @puzzle[i].get_y == @puzzle[3].get_y - 155
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


class PuzzleWindow < Gosu::Window
	def initialize
		super(1280, 700, false)
		self.caption = "Jenni_Puzzle"
		@background = Gosu::Image.new(self, "background.jpg", true)
		@scramble_button = Gosu::Image.new(self, "buttons/scramble.tiff", true)
		@solve_button = Gosu::Image.new(self, "buttons/solve.tiff", true)
		@normal = Puzzle.new(self, "normal face/normal.jpg", 15)
		@perfect = Puzzle.new(self, "perfect face/smaller_perfect.jpg", 650)
	end

	def needs_cursor?
    	true
	end

	def update
		for i in 1..15
			@normal.move_tiles
		end
	end

	def draw
		@background.draw(0, 0, 0)
		@normal.draw
		@perfect.draw
		@scramble_button.draw(100, 645, 0)
		@solve_button.draw(350, 645, 0)
	end
end

window = PuzzleWindow.new
window.show
