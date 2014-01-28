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
    @image.draw(@x, @y, 0, 0.75, 0.75)
  end
end


class PuzzleWindow < Gosu::Window
  def initialize
    super(1280, 960, false)
    self.caption = "Jenni_Puzzle"
    @normal_pics = Gosu::Image.load_tiles(self, "normal face/normal.jpg", -4, -4, true)
	@normal_positions = []
	for i in 0..3
		for j in 0..3
			@normal_positions << [(25 + (j * 163)), (25 + (i * 163))]
		end
	end
    @tiles = []
	for i in 0..14
		@tiles << Piece.new(self, @normal_pics[i], @normal_positions[i][0], @normal_positions[i][1])
	end
  end

  def update
	
  end

  def draw
    for i in 0..14
      @tiles[i].draw
    end
  end

end

window = PuzzleWindow.new
window.show
