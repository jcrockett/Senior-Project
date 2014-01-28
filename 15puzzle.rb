require 'gosu'

class Piece
  def initialize(window, image, x, y)
    @image = image
    @x = x
    @y = y
  end

  def move(dif)
      @position.zip(dif).map{|pair| pair.reduce(&:+) }
  end

  def left
    move([-1,0])
  end

  def right
    move([1,0])
  end

  def up
    move([0,-1])
  end

  def left
    move([0,1])
  end

  def draw
    @image.draw(@x, @y, 0, 0.7, 0.7)
  end
end


class PuzzleWindow < Gosu::Window
  def initialize
    super(1280, 960, false)
    self.caption = "Jenni_Puzzle"
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
	for i in 0..14
		@normal_tiles << Piece.new(self, @normal_pics[i], @normal_positions[i][0], @normal_positions[i][1])
		@perfect_tiles << Piece.new(self, @perfect_pics[i], @perfect_positions[i][0], @perfect_positions[i][1])
	end
  end

  def update
	
  end

  def draw
    for i in 0..14
      @normal_tiles[i].draw
	  @perfect_tiles[i].draw
    end
  end

end

window = PuzzleWindow.new
window.show
