require './board'
require 'gosu'
include Gosu

class Checkers < Window
  attr_accessor :board
  
  def initialize
    super(600,600,true)
    @board = Board.new(self) 
    @background = Image.new(self, "./media/board.png", true)   
  end 
  
  
  def update
    
  end
  
  def draw
    @background.draw(0,0,0)
    @board.draw
  end
  
  def button_down(id)
    if id == MsLeft
      @start_pos = get_mouse_grid
    end
  end
  
  def button_up(id)
    if MsLeft == id
      @end_pos = get_mouse_grid
      piece = @board.get_piece(@start_pos)
      chain_move = @board.request_jump_path(piece, @end_pos) unless piece.nil?
      p "chain move is #{chain_move}"
      if !chain_move.nil? && chain_move != [] 
        piece.perform_moves(chain_move)
      elsif piece.possible_moves != []
        piece.perform_move(@end_pos)
      end
    end
  end
  
  def needs_cursor?
    true
  end 
  
  def grid_to_pixel(x, y, z = 0.5)
     [(x * 75 + 13).to_i, (y * 75 + 13).to_i,z]
   end
   
   def get_mouse_grid
     mouse = []
     mouse = mouse_x, mouse_y
     [((mouse[0] - 13) / 75).to_i,((mouse[1] - 13) / 75).to_i]
   end   
end


##Tests


win = Checkers.new
b = win.board
b.place_pieces
win.show
b.display
p = b.get_piece([2,2])
puts "\n"

 b.place_piece(Piece.new(win, b,[4,2],:B))
puts b.get_piece([4,2]).pos
 b.display

# p1 = b.get_piece([0,2])
# p1.perform_move([1,3])
# puts "getting p's possible moves"
# b.display
# puts "Testing performing move"
# p.perform_move([3,3])
# b.display
# red = b.get_piece([3,5])
# red.perform_move([4,4])
# b.display
# puts "#{red.pos} should be [4,4]"
# puts "#{red.possible_moves} should include [2,2],[3,5]"
# red.perform_move([2,2])
# b.display
# puts "/n"
b.grid.each do |row|
  row.each {|piece| b.remove_piece_at(piece.pos) unless piece.nil?}
end
b.grid[7][7] = Piece.new(win, b,[7,7],:R)
b.grid[6][4] = Piece.new(win, b,[6,4],:B)
b.grid[7][7].kinged = true
puts b.grid[6][4].kinged
b.grid.each_with_index do |row, i|
  row.each_with_index do |piece, j|
    if i == j && i.even?
      b.grid[i][j] = Piece.new(win, b,[i,j],:B)
    end
  end
end

b.display
puts "\n"
red_jumper = b.get_piece([7,7])
puts "Beginning perform moves!!!!!!!!!!!!!!"    
puts "value of jump_path #{b.request_jump_path(red_jumper,[3,7])}"
path = b.request_jump_path(red_jumper,[3,7])
if path.shift == [3,7]
  red_jumper.perform_moves(path)
end
b.display
  





