require 'gosu'

class PuzzleWindow < Gosu::Window
	def initialize
		super 1280, 960, false
		self.caption = "JenniPuzzle"
	end

end


window = PuzzleWindow.new
window.show