# Tick Tac Toe v2
class Player
  attr_accessor :turn

  def reset_turn
    self.turn = 0
  end

  def alternate_turn(other_player)
    self.turn -= 1
    other_player.turn += 1
  end
end

class Human < Player
  def initialize
    @turn = 1
  end

  def turn_order
    case turn
    when 1
      'first'
    when 0
      'second'
    end
  end
end

class Computer < Player
  attr_accessor :difficulty

  def initialize
    @turn = 0
    @difficulty = "Medium"
  end
end

class Board
  INDENT = ' ' * 40
  UNMARKED = ' '
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], # horizontal
                   [1, 4, 7], [2, 5, 8], [3, 6, 9], # vertical
                   [1, 5, 9], [3, 5, 7]]            # diag

  attr_accessor :squares, :human_marker, :computer_marker

  def initialize
    @squares = {}
    @human_marker = 'X'
    @computer_marker = 'O'
    initialize_board
  end

  def initialize_board
    (1..9).each { |key| squares[key] = Marker.new }
  end

  def attack_middle_square
    squares[5].mark = computer_marker
  end

  def go_for_3
    computer_attack_lines.sample.each do |key|
      if unmarked_squares.include?(key)
        squares[key].mark = computer_marker
        break
      end
    end
  end

  def place_random_marker
    squares[unmarked_squares.sample].mark = computer_marker
  end

  def computer_attack_lines
    attack_lines = WINNING_LINES.select do |line|
      computer_marker_count = 0
      human_marker_count = 0
      line.each do |key|
        computer_marker_count += 1 if squares[key].mark == computer_marker
        human_marker_count += 1 if squares[key].mark == human_marker
      end
      computer_marker_count == 2 && human_marker_count == 0
    end
    attack_lines
  end

  def human_attack_lines
    attack_lines = WINNING_LINES.select do |line|
      human_marker_count = 0
      computer_marker_count = 0
      line.each do |key|
        human_marker_count += 1 if squares[key].mark == human_marker
        computer_marker_count += 1 if squares[key].mark == computer_marker
      end
      human_marker_count == 2 && computer_marker_count == 0
    end
    attack_lines
  end

  def place_easy_computer_marker
    squares[unmarked_squares.sample].mark = computer_marker
  end

  def place_medium_computer_marker
    if unmarked_squares.include?(5)
      attack_middle_square
    elsif !computer_attack_lines.empty?
      go_for_3
    else
      place_random_marker
    end
  end

  def defend
    human_attack_lines.sample.each do |key|
      if unmarked_squares.include?(key)
        squares[key].mark = computer_marker
        break
      end
    end
  end

  def place_hard_computer_marker
    if unmarked_squares.include?(5)
      attack_middle_square
    elsif !computer_attack_lines.empty?
      go_for_3
    elsif !human_attack_lines.empty?
      defend
    else
      place_random_marker
    end
  end

  def place_human_marker(choice)
    squares[choice].mark = human_marker
  end

  def unmarked_squares
    squares.each_with_object([]) do |(key, square), unmarked_squares|
      unmarked_squares << key if square.mark == UNMARKED
    end
  end

  def human_winner?
    WINNING_LINES.each do |line|
      human_marker_count = 0
      line.each do |key|
        human_marker_count += 1 if squares[key].mark == human_marker
      end
      return true if human_marker_count == 3
    end
    false
  end

  def computer_winner?
    WINNING_LINES.each do |line|
      computer_marker_count = 0
      line.each do |key|
        computer_marker_count += 1 if squares[key].mark == computer_marker
      end
      return true if computer_marker_count == 3
    end
    false
  end

  def full?
    unmarked_squares.empty?
  end

  # rubocop:disable Metrics/AbcSize
  def display
    puts "     |     |     "
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  "
    puts "     |     |     "
  end
  # rubocop:enable Metrics/AbcSize
end

class Marker
  attr_accessor :mark

  def initialize
    @mark = ' '
  end

  def to_s
    mark
  end
end

class GameEngine
  attr_reader :human, :computer, :board

  def initialize
    @human = Human.new
    @computer = Computer.new
    @board = Board.new
  end

  def play
    display_welcome_message
    loop do
      initialize_game
      loop do
        current_player_moves
        break if winner? || board.full?
        clear_screen_and_display_board
      end
      game_ending_display
      break unless play_again?
    end
    display_goodbye_message
  end

  private

  def prompt(msg)
    puts ">> #{msg}"
  end

  def display_welcome_message
    prompt "Hi and Welcome to Tic-Tac-Toe!"
  end

  def display_goodbye_message
    prompt "Thanks for playing, bye!"
  end

  def human_move
    choice = nil
    prompt "Choose an available square: #{board.unmarked_squares.join(', ')}"
    loop do
      choice = gets.chomp.to_i
      break if board.unmarked_squares.include?(choice)
      prompt "Invalid square!"
    end
    board.place_human_marker(choice)
    human.alternate_turn(computer)
  end

  def computer_move
    case computer.difficulty
    when "Easy"
      board.place_easy_computer_marker
    when "Medium"
      board.place_medium_computer_marker
    when "Hard"
      board.place_hard_computer_marker
    end
    computer.alternate_turn(human)
  end

  def winner?
    board.human_winner? || board.computer_winner?
  end

  def game_ending_display
    clear_screen_and_display_board
    if board.human_winner?
      prompt "You won!"
    elsif board.computer_winner?
      prompt "Computer won!"
    elsif board.full?
      prompt "Board is full..."
    end
  end

  def play_again?
    prompt "Play again? (y/n)"
    answer = gets.chomp.downcase
    answer.start_with?('y')
  end

  def determine_player_order
    prompt "Who goes first?"
    prompt "Press 1) to go FIRST or 2) to go SECOND."
    answer = nil
    loop do
      answer = gets.chomp.to_i
      break if answer == 1 || answer == 2
      prompt "Invalid choice."
    end
    if answer == 1
      human.turn = 1
      computer.turn = 0
    elsif answer == 2
      human.turn = 0
      computer.turn = 1
    end
  end

  def customize_marker
    prompt "You are currently '#{board.human_marker}'"
    prompt "Press 'Enter' if this is OK or any other key to swap."
    choice = gets
    return true if choice == "\n"
    if board.human_marker == 'X'
      board.human_marker = 'O'
      board.computer_marker = 'X'
    elsif board.human_marker == 'O'
      board.human_marker = 'X'
      board.computer_marker = 'O'
    end
  end

  def current_player_moves
    if computer.turn > human.turn
      computer_move
    elsif human.turn > computer.turn
      human_move
    end
  end

  def clear_screen_and_display_board
    system 'clear'
    board.display
  end

  def display_settings
    prompt "These are the default settings: "
    prompt "1) You go #{human.turn_order}"
    prompt "2) You are '#{board.human_marker}'"
    prompt "3) Computer difficulty: #{computer.difficulty}"
    prompt "Type 1-3 to customize or press 'Enter' to continue."
  end

  def customize_settings
    choice = nil
    loop do
      choice = gets
      return nil if choice == "\n"
      break if [1, 2, 3].include?(choice.chomp.to_i)
      prompt "Invalid choice."
    end
    case choice.chomp.to_i
    when 1
      determine_player_order
    when 2
      customize_marker
    when 3
      adjust_difficulty
    end
  end

  def display_difficulty_menu
    prompt "Current difficulty: #{computer.difficulty}"
    prompt "Press 1 for Easy"
    prompt "Press 2 for Medium"
    prompt "Press 3 for Hard"
    prompt "Press 'Enter' to make no changes."
  end

  def change_difficulty
    choice = nil
    loop do
      choice = gets
      return true if choice == "\n"
      break if [1, 2, 3].include?(choice.chomp.to_i)
      prompt "Invalid choice."
    end
    case choice.chomp.to_i
    when 1
      computer.difficulty = "Easy"
    when 2
      computer.difficulty = "Medium"
    when 3
      computer.difficulty = "Hard"
    end
  end

  def adjust_difficulty
    display_difficulty_menu
    change_difficulty
  end

  def initialize_game
    board.initialize_board
    loop do
      display_settings
      break if !customize_settings
    end
    clear_screen_and_display_board
  end
end

GameEngine.new.play
