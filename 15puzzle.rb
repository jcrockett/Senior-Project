require 'gosu'

class Piece
	def initialize(window, image, x, y)
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

	def draw
		@image.draw(@x, @y, 0, 0.7, 0.7)
	end
end


class PuzzleWindow < Gosu::Window
	def initialize
		super(1280, 700, false)
		self.caption = "Jenni_Puzzle"
		@background = Gosu::Image.new(self, "background.jpg", true)
		@scramble_button = Gosu::Image.new(self, "buttons/scramble.tiff", true)
		@solve_button = Gosu::Image.new(self, "buttons/solve.tiff", true)
		@normal_pics = Gosu::Image.load_tiles(self, "normal face/normal.jpg", -4, -4, true)
		@perfect_pics = Gosu::Image.load_tiles(self, "perfect face/smaller_perfect.jpg", -4, -4, true)
		@normal_positions = []
		@perfect_positions = []
		for i in 0..3
			for j in 0..3
				@normal_positions << [(15 + (j * 155)), (25 + (i * 155))]
				@perfect_positions << [(650 + (j * 155)), (25 + (i * 155))]
			end
		end
		@normal_tiles = []
		@perfect_tiles = []
		for i in 0..15
			@normal_tiles << Piece.new(self, @normal_pics[i], @normal_positions[i][0], @normal_positions[i][1])
			@perfect_tiles << Piece.new(self, @perfect_pics[i], @perfect_positions[i][0], @perfect_positions[i][1])
		end
		puts @normal_tiles
	end

	def needs_cursor?
    	true
	end

	def update
		for i in 1..15
			if button_down? Gosu::MsLeft and mouse_x > @normal_tiles[i].get_x and mouse_x < @normal_tiles[i].get_x + 155 and mouse_y > @normal_tiles[i].get_y and mouse_y < @normal_tiles[i].get_y + 155
				if @normal_tiles[i].get_x == @normal_tiles[0].get_x + 155 and @normal_tiles[i].get_y == @normal_tiles[0].get_y
					@normal_tiles[i].left
					@normal_tiles[0].right
				elsif @normal_tiles[i].get_x == @normal_tiles[0].get_x - 155 and @normal_tiles[i].get_y == @normal_tiles[0].get_y
					@normal_tiles[i].right
					@normal_tiles[0].left
				elsif @normal_tiles[i].get_x == @normal_tiles[0].get_x and @normal_tiles[i].get_y == @normal_tiles[0].get_y + 155
					@normal_tiles[i].down
					@normal_tiles[0].up
				elsif @normal_tiles[i].get_x == @normal_tiles[0].get_x and @normal_tiles[i].get_y == @normal_tiles[0].get_y - 155
					@normal_tiles[i].up
					@normal_tiles[0].down
				else
				end
			end
		end
	end

	def draw
		@background.draw(0, 0, 0)
		for i in 1..15
			@normal_tiles[i].draw
			@perfect_tiles[i].draw
		end
		@scramble_button.draw(100, 645, 0)
		@solve_button.draw(350, 645, 0)
	end
end

window = PuzzleWindow.new
window.show
