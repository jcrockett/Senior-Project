hrequire 'gosu'

class PuzzleWindow < Gosu::Window
	def initialize
		super 1280, 960, false
		self.caption = "JenniPuzzle"
	end

end



class piece
  def initialize(position=[0,0], id=0)
    @position = position
    @id = id
  end


  def move(dif):
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

end

class board
  def initialize(pieces)
    # id = 0 assumed to be a space
    @pieces = peices
  end
  
  def posible_boards
    # things around the space can move
    # so make a move for each way something can enter the space.
  end

  def is_goal(goal)
    # return bool (true/false
  end

end

# search Depth First
def search(start_board)
  boards = [start_board]
  while !boards[0].is_goal
    boards.append(boards[0].possible_boards)
    boards.pop(0)
  end
    return board    
  
window = PuzzleWindow.new
window.show
