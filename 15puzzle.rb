require 'gosu'

class Piece
  def initialize(window, image, x, y)
    @image = Gosu::Image.new(window, image, false)
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
    @image.draw(@x, @y, 0, 0.5, 0.5)
  end
end


class PuzzleWindow < Gosu::Window
  def initialize
    super(1280, 960, false)
    self.caption = "Jenni_Puzzle"
    @normal_pics = ["normal face/normal_1.jpg", "normal face/normal_2.jpg","normal face/normal_3.jpg","normal face/normal_4.jpg","normal face/normal_5.jpg","normal face/normal_6.jpg","normal face/normal_7.jpg","normal face/normal_8.jpg","normal face/normal_9.jpg","normal face/normal_10.jpg","normal face/normal_11.jpg","normal face/normal_12.jpg","normal face/normal_13.jpg","normal face/normal_14.jpg","normal face/normal_15.jpg"]
	@normal_positions = [[30, 25], [135, 25], [245, 25], [357, 24], [30, 133], [135, 133], [245, 133], [357, 133], [30, 241], [135, 241], [245, 241], [357, 241], [30, 349], [135, 349], [245, 349], [357, 349]]
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
