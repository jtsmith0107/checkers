require './piece'


class Board
  attr_accessor :grid
  
  def initialize(window) 
    @grid = Array.new(8) { Array.new(8) { nil } }
    @win = window
  end
  
  def draw
    pieces = get_all_pieces
    @win.scale(1.7, 1.7) do
      pieces.each do |piece|
        piece.draw
      end
    end
  end
  
  def get_all_pieces
    pieces = []
    @grid.each do |row|
      row.each do |piece|
        pieces << piece unless piece.nil?
      end
    end
    pieces
  end
  
  def place_pieces    
    #if row even place on even cols
    #0 , 2, 4, 6
    #1,3,5,7
    @grid.each_with_index do |row,col_idx|
      row.each_with_index do |tile, row_idx|  
        curr_color = :B if (0..2).include? row_idx
        curr_color = :W if (5..7).include? row_idx
        
        if !curr_color.nil? && row_idx.even? && col_idx.even?
          @grid[row_idx][col_idx] = Piece.new(@win, self,[row_idx,col_idx],curr_color) 
        elsif !curr_color.nil? && row_idx.odd? && col_idx.odd?
          @grid[row_idx][col_idx] = Piece.new(@win, self,[row_idx,col_idx],curr_color)
        end
      end
    end
  
  end
  
  def move_piece(piece, move_pos)
    pos = piece.pos
    @grid[pos[1]][pos[0]] = nil
    @grid[move_pos[0]][move_pos[1]] = piece
  end
  
  def dup
    new_board = Board.new(Checkers.new)
    @grid.each_with_index do |row, col_idx|
      row.each_with_index do |tile, row_idx|
        curr_piece = get_piece([row_idx,col_idx])
        if curr_piece.nil?          
          new_board.grid[col_idx][row_idx] = nil
        else
          new_board.grid[col_idx][row_idx] =
            Piece.new(@win, new_board,[row_idx,col_idx],curr_piece.color,curr_piece.kinged)
          end
      end
    end
    new_board
  end
  
  def place_piece(new_piece)
    y,x = new_piece.pos
    @grid[x][y] = new_piece
  end
  
  def display
    @grid.each do |row|
      row.each do |tile|
        if !tile.nil?
          print "|_#{tile.color}_|" 
        else
          print "|___|"
        end
      end
      puts "\n"
    end
    nil
  end
  
  #attempts to create a move path from piece's position to end_pos
  #returns array of moves if successful, [] means no path available  
  def request_jump_path(piece,end_pos)    
    moves = piece.possible_jump_moves
    puts "These are #{moves} possible moves"
    return [] if piece.pos == end_pos    
    
    moves.each do |move|
      test_board = self.dup
      test_board.place_piece(Piece.new(@win, test_board,piece.pos,
                                              piece.color,piece.kinged))
      test_piece = Piece.new(@win, test_board,move,piece.color,piece.kinged)
      test_board.place_piece(test_piece)
      path = request_jump_path(test_piece,end_pos)
      p path
      unless path.nil?
        return [move] + path #return move or true???????????????
      end
      
    end
    nil
  end
    
  def remove_piece_at(pos)
    @grid[pos[1]][pos[0]] = nil
  end 
  
  #reversed to correspond with piece pos order
  def get_piece(pos)
    @grid[pos[1]][pos[0]]
  end  
end