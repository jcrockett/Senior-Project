require 'gosu'

class Piece
  attr_accessable :x, :y, :img
  def initialize(x,y,image, size=155)
    @x = x
    @y = y
    @img = image
    @size = size
  end

  def ==(comparator)
    if conparator.instance_of? Piece
      return (@x == comparator.x and @y == comparator.y)
    else
      return (@x == comparator[0] and @y == comparator[1])
    end
  end

  def move(dir)
    case dir
    when 'l'
      @x -= 1
    when 'r'
      @x += 1
    when 'u'
      @y -= 1
    when 'd'
      @y += 1
    end
  end

  def draw(osx, osy)
    @image.draw(self.pxx+osx, self.pxy+osy, 0, 0.7, 0.7)
  end

  def pxx
    @x * @size
  end
  def pxy
    @y * @size
  end
end

class Puzzle
  attr_accessable :image, :origin

  def initialize(origin, image, blank, num, moves)
    @moves = moves
    @num = num
    @blank = blank
    @origin = origin
    @image = image
    tiles = Gosu::Image.load_tiles(@window, @image, -num, -num, true)
    x, y = 1, 0
    @pieces =[]
    tiles.each do |tile|
      @pieces << Piece.new(x,y,tile)
      if x == num
        x = 0
        y += 1
      end
    end
  end

  def add_move(m)
    @moves << m
  end

  def dump_params
    return @origin, @image, @blank, @num, @moves

  def pair(puzzle)
    pairs = []
    @puzzle.each do |piece|
      puzzle.each do |other|
        if piece == other
          pairs << [piece, other_piece]
        end
      end
    end
    return pairs
  end

  def possible_moves
    moves = []
    if @blank.x < 4
      moves << 'l'
    end
    if @blank.y < 4
      moves << 'd'
    end
    if @blank.x > 0
      moves << 'r'
    end
    if @blank.y > 0
      moves << 'u'
    end
    return moves
  end

  def move(dir)
    case dir
    when 'l'
      @piece.each do |piece|
        if piece == [@blank.x+1, blank.y]
          piece.move('r')
        end
      end
      @blank.move('l')
    when 'r'
      @piece.each do |piece|
        if piece == [@blank.x-1, blank.y]
          piece.move('l')
        end
      end
      @blank.move('r')
    when 'u'
      @piece.each do |piece|
        if piece == [@blank.x, blank.y-1]
          piece.move('d')
        end
      end
      @blank.move('u')
    when 'd'
      @piece.each do |piece|
        if piece == [@blank.x+1, blank.y]
          piece.move('u')
        end
      end
      @blank.move('d')
    end
  end

  def random_move
    move(possible_moves.sample)
  end

  def draw
    @pieces.each { |p| p.draw(@origin) }
  end
end

class DrawPuzzle < Gosu::Window
  def initialize
    super(1280, 700, false)
    self.caption = "Jenny's Puzzle"
    @background = Gosu::Image.new(self, 'background.jpg', true)
    @scramble_button = Gosu::Image.new(self, "buttons/scramble.tiff", true)
    @solve_button = Gosu::Image.new(self, "buttons/solve.tiff", true)
    @normal = Puzzle.new([10,10],"normal face/normal.jpg", 650)
    @perfect = Puzzle.new([1000,1000],"normal face/smaller_perfect.jpg", 650)
  end

  def needs_cursor?
    true
  end

  def scramble
    100.times do
      @normal.random_move
    end
  end

end


def solve(start_board)
  open_nodes = [start_board]
  while !open_nodes[0].is_goal?
    cur = open_nodes.shift
    cur.posible_moves.each do |pm|
      p = Puzzle.new(cur.params_dump)
      p.add_move(pm)
      open_nodes.concat(p.move(pm))
    end
  end
  return open_nodes[0].moves
end
