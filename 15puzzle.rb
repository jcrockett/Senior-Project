require 'gosu'

class Piece
	attr_reader :image, :x, :y, :target_x, :target_y
	def initialize(window, image, x, y, target_x, target_y)
		@window = window
		@image = image
		@x = x
		@y = y
		@target_x = target_x
		@target_y = target_y
	end

	def set_x(val)
		@x = val
	end

	def set_y(val)
		@y = val
	end

	def x_loc(puzzle_x)
		puzzle_x + @x * 155
	end

	def y_loc(puzzle_y)
		puzzle_y + @y * 155
	end

	def left
		@x -= 1
	end

	def right
		@x += 1
	end

	def down
		@y -= 1
	end

	def up
		@y += 1
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
		@x == blank.x and @y == blank.y + 1
	end

	def below?(blank)
		@x == blank.x and @y == blank.y - 1
	end

	def left_of?(blank)
		@x == blank.x - 1 and @y == blank.y
	end

	def right_of?(blank)
		@x == blank.x + 1 and @y == blank.y
	end
	
	def is_clicked?(window, puzzle_x, puzzle_y)
		window.button_down? Gosu::MsLeft and window.mouse_x > x_loc(puzzle_x) and window.mouse_x < (x_loc(puzzle_x) + 155) and window.mouse_y > y_loc(puzzle_y) and window.mouse_y < (y_loc(puzzle_y) + 155)
	end
	def draw(puzzle_x, puzzle_y)
		@image.draw(x_loc(puzzle_x), y_loc(puzzle_y), 0, 0.7, 0.7)
	end
end

class Puzzle
	attr_reader :puzzle, :solve_steps, :solution, :location, :image, :num, :moves
	def initialize(window, location, image, num, moves)
		@window = window
		@location = location
		@image = image
		@num = num
		@moves = moves
		@solve_steps = []
		@tiles = Gosu::Image.load_tiles(@window, @image, -num, -num, true)
		x, y = 0, 0
		@puzzle = []
		@tiles.each do |tile|
			p = Piece.new(@window, tile, x, y, x, y)
			@puzzle << p
			x += 1
			if x == num
				x = 0
				y += 1
			end
		end
		@blank = @puzzle[3]
	end

	def add_move(m)
		@moves << m
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
		@solve_steps << move
		@solved = false
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
		end
	end

	def move_tiles
		for i in 0..15
			if @puzzle[i].is_clicked?(@window, @location, 25)
				if find_direction(i) == "l"
					@puzzle[i].left
					@puzzle[3].right
					solve_steps << ["l", i]
					puzzle_status(false)
				elsif find_direction(i) == "r"
					@puzzle[i].right
					@puzzle[3].left
					solve_steps << ["r", i]
					puzzle_status(false)
				elsif find_direction(i) == "d"
					@puzzle[i].down
					@puzzle[3].up
					solve_steps << ["d", i]
					puzzle_status(false)
				elsif find_direction(i) == "u"
					@puzzle[i].up
					@puzzle[3].down
					solve_steps << ["u", i]
					puzzle_status(false)
				end
			end
		end
	end

	def puzzle_status(status)
		@solved = status
	end

	def quick_solve
		for i in 0..15
			for j in 0..15
				if @puzzle[i].image == @solution[j].image
					@puzzle[i].set_x(@solution[j].x)
					@puzzle[i].set_y(@solution[j].y)
				end
			end
		end	
	end

	def is_goal?
		for i in 0..15
			if(@puzzle[i].x != @puzzle[i].target_x or @puzzle[i].y != @puzzle[i].target_y)
				return false
			end
		end
		return true
	end

	def possible_moves
		moves = []
		for i in 0..15
			if @puzzle[i].right_of?(@blank)
				moves << ['l', i]
			end
			if @puzzle[i].left_of?(@blank)
				moves << ['r', i]
			end
			if @puzzle[i].above?(@blank)
				moves << ['d', i]
			end
			if @puzzle[i].below?(@blank)
				moves << ['u', i]
			end
		end
		return moves
	end

	def draw
		for i in 0..15
			if i != 3
				@puzzle[i].draw(@location, 25)
			end
		end
	end
end

class TwoPuzzle
	attr_reader :perfect, :normal
	def initialize(window, normal, perfect)
		@window = window
		@normal = normal
		@perfect = perfect
	end

	def scramble
		for i in 0..100
			@normal.random_move
		end
		if(@normal.puzzle[3].x != 0 or @normal.puzzle[3].y != 0)
			scramble
		end
		if !@perfect.is_goal?
			@perfect.quick_solve
		end
	end

	def move_tiles
		@normal.move_tiles
	end

	def solve
		if @normal.puzzle[3].x == 0 && @normal.puzzle[3].y == 0
			perfect_positions = []
			for i in 0..15
				for j in 0..15
					if(@normal.puzzle[i].x == (3 - @perfect.puzzle[j].x) and @normal.puzzle[i].y == @perfect.puzzle[j].y)
						perfect_positions << j
					end
				end
			end
			puts perfect_positions.inspect
			while @normal.solve_steps.length > 0
				puts @normal.solve_steps.last.inspect
				move = @normal.solve_steps.pop()
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
	end

	def better_solve_helper(puzzles)
		fringe = []
		puzzles.each do |ps|
			pm = ps.possible_moves
			temp_fringe = []
			for i in 0..(pm.length-1)
				p = ps.clone
				p.solve_step(pm[i][0], pm[i][1])
				p.add_move(pm[i])
				temp_fringe << p
			end
			temp_fringe.each do |f|
				if(f.is_goal?)
					return f.moves
				else
					fringe << f
				end
			end
		end
		better_solve_helper(fringe)
	end

	def better_solve
		if @normal.puzzle[3].x == 0 && @normal.puzzle[3].y == 0	
		solution = better_solve_helper([@normal])
			perfect_positions = []
			for i in 0..15
				for j in 0..15
					if(@normal.puzzle[i].x == (3 - @perfect.puzzle[j].x) and @normal.puzzle[i].y == @perfect.puzzle[j].y)
						perfect_positions << j
					end
				end
			end
			puts perfect_positions.inspect
			while solution.length > 0
				puts solution.last.inspect
				move = solution.pop()
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
	end

	def save
		normal = []
		perfect = []
		puts @normal.puzzle.inspect
		puts @perfect.puzzle.inspect
		@normal.puzzle.each do |n|
			normal << [n.x, n.y]
		end
		@perfect.puzzle.each do |p|
			perfect << [p.x, p.y]
		end
		File.open("savepuzzle.txt", "a") do |file|
			for i in 0..(normal.length-1)
				normal[i] = normal[i].join(",")
			end
			for i in 0..(perfect.length-1)
				perfect[i] = perfect[i].join(",")
			end
			save_string = normal.join(";") + ":" + perfect.join(";")
			file.puts save_string
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
		@save_button = Gosu::Image.new(self, "buttons/save.tiff", true)
		@normal = Puzzle.new(self, 15, "perfect face/smaller_perfect.jpg", 4, [])
		@perfect = Puzzle.new(self, 650, "normal face/normal.jpg", 4, [])
		@puzzle = TwoPuzzle.new(self, @normal, @perfect)
	end

	def needs_cursor?
    	true
	end

	def scramble
		if button_down? Gosu::MsLeft and mouse_x > 302 and mouse_x < 457 and mouse_y > 645 and mouse_y < 695
			@puzzle.scramble
		end
	end

	def solve
		if button_down? Gosu::MsLeft and mouse_x > 552 and mouse_x < 707 and mouse_y > 645 and mouse_y < 695
			@puzzle.better_solve
		end
	end

	def save
		if button_down? Gosu::MsLeft and mouse_x > 802 and mouse_x < 957 and mouse_y > 645 and mouse_y < 695
			@puzzle.save
		end
	end

	def update
		scramble
		solve
		save
		@puzzle.move_tiles
	end

	def draw
		@background.draw(0, 0, 0)
		@puzzle.draw
		@scramble_button.draw(302, 645, 0)
		@solve_button.draw(552, 645, 0)
		@save_button.draw(802, 645, 0)
	end
end

window = PuzzleWindow.new
window.show
