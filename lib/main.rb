# contains the methods to manipulate wiht the display

module Display
  def display_intro 
    "WELLCOME TO THE GAME MASTERMIND!"
  end
  def display_instruction
    "The Codemaker selects a 4-digit code, using numbers from 1 - 6:
    1234
     (the same number can not be used more than once).

     Each turn, the Codebreaker tries to guess the code by inputting 4 digits.
     (Just type them and press enter. They can be separated by spaces, commas, or not at all.)

     Then, the Codemaker provides a hint:
     BBWX
     'B' indicates the correct digit in the correct position.
     'W' indicates a correct digit, but in the wrong position.
     'Empty space' indicates an incorrect digit.Note that the hints are not in order."
   end

  def display_require_instruction
    "Do you want to get familiar with instruction? type y/n"
  end

 

   def display_chose_role
    "Type 1 for Codemaker or 2 for Codebreaker"
   end

   def display_enter_code
    "Enter your code in 4 digits from the range of 1 - 6"
   end

   def display_enter_guess
    "Enter your guess"
   end 

   def display_closure
    puts "Would like to give it another try? y/n"
   end 
    
end

# shows the hints and numbers 

class Board
  attr_accessor :numbers, :hints 

  def initialize
    @numbers = [1, 2, 3, 4]
    @hints = [" ", " ", " ", " "]
  end 

  def show 
    puts <<-HEREDOC
          #{numbers[0]}|#{numbers[1]}|#{numbers[2]}|#{numbers[3]}
          #{hints[0]}|#{hints[1]}|#{hints[2]}|#{hints[3]}
         HEREDOC
  end

  def update_number(number)
    @numbers = number.split("")
  end 

  def update_for_comp(number)
    @numbers = number
  end 

  
end
        

# contains all the states for codemaker

class CodemakerUser
  attr_accessor :code

  def initialize
    @code = nil
  end 

  def input_code(input)
    @code = input.split("")
  end 

  def make_elements_int
    @code.map!{|str| str.to_i}
  end 
 
end

# contains all the states and methods for code breaker

class CodebreakerUser
  attr_accessor :guess

  def initialize
    @guess = nil
  end 

  def input_code(input)
    @guess = input.split("")
  end

  def make_elements_int
    @guess.map!{|string| string.to_i}
  end

end

# contains the states and methods for computer codemaker

class CodemakerComp
  attr_accessor :code 

  def initialize
    @code = (1..6).to_a.shuffle.take(4)
  end 
end

# contains the states and methods for copmuter codereader 

class CodereaderComp
  attr_accessor :guess
  CONSTANTS = [1, 2, 3, 4, 5, 6]

  def initialize
    @guess = nil
  end

  def guess_random_code
    @guess = (1..6).to_a.shuffle.take(4)
  end 

  
  def guess_based_hint(hints)
    hints.each_with_index do |hint, inx|
      if hint == "B"
         @guess[inx] = @guess[inx]
      elsif hint == " "
        @guess[inx] = rand 1..6
      else 
        if inx + 1 > @guess.length - 1
        @guess[inx], @guess[inx - 1] =  @guess[inx - 1], @guess[inx]
        else 
        @guess[inx], @guess[inx + 1] =  @guess[inx + 1], @guess[inx]
        end 
      end 
    end 
  end
  
end

# counts the moves 
class MoveCounter
  @@moves_counter = 6

  def initialize
    @@moves_counter -= 1
  end 

  def self.moves_left
    @@moves_counter
  end 
end 

# contains the logic of the game 

class Game

  
  include Display
  attr_accessor :board, :comp_maker, :comp_reader, :user_reader, :user_maker, :counter

  def initialize
    @board = Board.new
    @comp_maker = nil
    @comp_reader = nil
    @user_maker = nil
    @user_reader = nil
    @counter = nil 
  end 

  def role_checker
    input = gets.chomp
    if input.to_i == 1
      @user_maker = CodemakerUser.new
      @comp_reader = CodereaderComp.new 
      puts self.display_enter_code
    elsif input.to_i == 2
      @user_reader = CodebreakerUser.new
      @comp_maker = CodemakerComp.new 
      puts self.display_enter_code
    else
      puts "Invalid input, please tyr again!"
      role_checker
    end 
  end 

  def input_checker
  input = gets.chomp
    if input == 'y'
      puts self.display_instruction
    elsif input == 'n'
      puts "Cool! you already know the rules. Lets Rock!"
    else 
      puts "Invalid input, please tyr again!"
      input_checker
   end 
  end

  def game_setter
    puts self.display_intro
    puts self.display_require_instruction
    self.input_checker
    puts self.display_chose_role
    self.role_checker
  end 

  def play_as_reader 
    self.counter = MoveCounter.new 
    guess_input = gets.chomp
    user_reader.input_code(guess_input)
    user_reader.make_elements_int
    board.update_number(guess_input)
    self.code_comparasion(user_reader, comp_maker)
    board.show
    if board.hints == ["B", "B", "B", "B"] && MoveCounter.moves_left >= 0
      puts "WOW! You have broken the code! kicked Comp's ass real nice"
     elsif board.hints != ["B", "B", "B", "B"] && MoveCounter.moves_left <= 0
       puts "FOR A SHAME! VM has kicked you fat ass!!"
     else 
     puts "Moves left: #{MoveCounter.moves_left}"
     play_as_reader
     end
  end 


  def play_as_maker
    code_input = gets.chomp
    user_maker.input_code(code_input)
    user_maker.make_elements_int
    comp_reader.guess_random_code
    board.update_for_comp(comp_reader.guess)
    self.code_comparasion(comp_reader, user_maker)
    board.show
    loop do
     self.counter = MoveCounter.new
     puts "Moves left: #{MoveCounter.moves_left}"
     comp_reader.guess_based_hint(board.hints)
     board.update_for_comp(comp_reader.guess)
     self.code_comparasion(comp_reader, user_maker)
     board.show
     break if board.hints == ["B", "B", "B", "B"] && MoveCounter.moves_left >= 0 || 
     board.hints != ["B", "B", "B", "B"] && MoveCounter.moves_left <= 0
    end 
    if board.hints == ["B", "B", "B", "B"] && MoveCounter.moves_left >= 0
      puts "WOW! VM has won the game vie breaking your code"
    elsif board.hints != ["B", "B", "B", "B"] && MoveCounter.moves_left <= 0
       puts "VM's digital ass has been kicked! tough one"
     end
  end
end

  def code_comparasion(reader, maker)
    reader.guess.each_with_index do |user_num, user_index|
      maker.code.each_with_index do |comp_num, comp_index|
        if user_num == comp_num && user_index == comp_index
          board.hints[user_index] = "B"
        elsif user_num == comp_num && user_index != comp_index
          board.hints[user_index] = "W"
        end
      end
    end
  end 



# lounch the game 
class Main  
  attr_accessor :game

  def initialize
    @game = Game.new
  end

  def play_the_game
    game.game_setter
    if game.user_maker == nil
      game.play_as_reader
    else 
      game.play_as_maker
    end 
  end

  def closure
    game.display_closure
    input = gets.chomp
    if input == 'y'
      self.play_the_game
    elsif input == 'n'
      puts "Thanks for playing!"
    else 
      puts "Invalid input, please tyr again!"
      self.closure
    end 
  end

  end

  play = Main.new
  play.play_the_game
  play.closure
  

