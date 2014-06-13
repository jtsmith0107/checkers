class Piece
  attr_accessor :color, :pos, :kinged
  
  BLACK_SLIDES = [[1,1],[1,-1]]
  BLACK_JUMPS = [[2,2],[2,-2]]
  RED_SLIDES = [[-1,1],[-1,-1]]
  RED_JUMPS = [[-2,2],[-2,-2]]
  KING_SLIDES =  BLACK_SLIDES + RED_SLIDES
  KING_JUMPS = BLACK_JUMPS + RED_JUMPS
  
  def initialize(window, board, pos, color,k = false)
    @kinged = k
    @pos = pos
    @color = color
    @board = board
    @win = window
    color_str = color == :B ? "black" : "white"
    king_str = @kinged ? "king" : "piece"
    img_str = "./media/#{color_str}_#{king_str}.png"
    @img = Image.new(@win,img_str,true)
  end
  
  def draw
    x,y,z = @win.grid_to_pixel(*@pos)
    @img.draw(x/1.5,y/1.5,z)
  end
  
  def possible_moves
    if @kinged
      puts "I'm kinged"
      slide_moves = KING_SLIDES
      jump_moves = KING_JUMPS
    else
      puts "Not kinged"
      slide_moves = @color == :B ? BLACK_SLIDES : RED_SLIDES
      jump_moves = @color == :B ? BLACK_JUMPS : RED_JUMPS
    end
    
    add_pos = Proc.new  {|move| [@pos[0] + move[0],@pos[1]+move[1]]}
    slide_poses = slide_moves.map(&add_pos)    
    jump_poses = jump_moves.map(&add_pos)
    puts "slide_poses positions are #{slide_poses}"  
    puts "jump positions are #{jump_poses}"    
    moves = valid_postions(slide_poses,jump_poses)    
    moves.compact # possible nils from map_with_index
  end
  
  def valid_postions(slide_moves, jump_moves)
    slide_moves.each_with_index.map do |move,idx| 
      if in_bounds(move)
        col = collision(move)
        #nil , diff color or same color
         if !col.nil? && col != @color 
          # jump over piece?
          puts "Adding #{jump_moves[idx]}"
          jump_moves[idx] if valid_jump_move(jump_moves[idx]) 
         else #no piece its a good move
           puts "Adding slide move #{slide_moves[idx]}"
          slide_moves[idx]
        end
      end
    end
  end
  
  def possible_jump_moves
    if @kinged
      puts "I'm kinged"
      slide_moves = KING_SLIDES
      jump_moves = KING_JUMPS
    else
      puts "Not kinged"
      slide_moves = @color == :B ? BLACK_SLIDES : RED_SLIDES
      jump_moves = @color == :B ? BLACK_JUMPS : RED_JUMPS
    end
    
    add_pos = Proc.new  {|move| [@pos[0] + move[0],@pos[1]+move[1]]}
    slide_poses = slide_moves.map(&add_pos)    
    jump_poses = jump_moves.map(&add_pos)
    
    slide_poses.each_with_index.map do |move,idx| 
      if in_bounds(move)
        col = collision(move)
         if !col.nil? && col != @color 
          # jump over piece?
          jump_poses[idx] if valid_jump_move(jump_poses[idx]) 
        end
      end
    end.compact
  end
  
  def perform_move(end_pos)
    end_pos[0],end_pos[1] = end_pos[1],end_pos[0]
    if possible_moves.include? end_pos
      @board.move_piece(self, end_pos)
      capture_piece_pos = [(@pos[0]+end_pos[0])/2,(@pos[0]+ end_pos[1])/2]
      unless collision(capture_piece_pos) == @color 
        @board.remove_piece_at(capture_piece_pos) 
      end
      @pos = end_pos 
      if @color == :B ? end_pos[0] == 0 : end_pos[1] == 7
        @kinged = true
      end
      return true     
    else
      return false
    end          
  end  
  
  def perform_moves(move_sequence)
    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
      true
    else
      raise InvalidMoveError, "Invalid move in the sequence"
    end
  end
  
  def perform_moves!(move_sequence)
    move_sequence.each do |move|
     raise InvalidMoveError, "Invalid move in sequence" unless 
     perform_move(move)
    end
  end
  
  def valid_move_seq?(move_sequence)
    begin
      new_board = @board.dup
      new_board.display
      new_board.get_piece(@pos).perform_moves!(move_sequence)
    rescue InvalidMoveError => e
      puts "you suck"
      false
    else
      puts "You rule"
      true      
    end
  end
  
  #must know its own new position
 
  
  def valid_jump_move(jump_move)
    in_bounds(jump_move) && !collision(jump_move)
  end
  
  #returns the color of the piece if one is found
  def collision(pos)
    piece_at_pos = @board.get_piece(pos)
    piece_at_pos.color unless piece_at_pos.nil? 
  end
  
  def in_bounds(pos)
    (0..7).include?(pos[0]) && (0..7).include?(pos[1])
  end
end

class InvalidMoveError < StandardError
  def initialize(message)
    super(message)
  end
end