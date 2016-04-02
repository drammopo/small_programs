FIRST_MOVE = :choose # Can either be set to :choose, :computer or :player
WINNING_LINES = [[1, 2, 3], [4, 5, 5], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                [[1, 5, 9], [3, 5, 7]]              # diagonals
INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'

def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def display_board(brd)
  system 'clear'
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

# def joinor(arr, delimiter=', ', word='or')
#   arr[-1] = "#{word} #{arr.last}" if arr.size > 1
#   arr.join(delimiter)
# end

def joinor(arr, separator = ', ', joiner = 'or')
  result = ''
  arr.each_with_index do |num, index|
    index >= arr.size - 1 ? result += "#{joiner} #{num}" : result += "#{num}#{separator}"
  end
  result
end

def player_places_piece!(brd)
  square = ''

  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):" # prompt "Choose a position to place a piece: #{joinor(empty_positions(board), ', ')}"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end
  brd[square] = PLAYER_MARKER
end

def detect_threat(line, brd, marker)
  if brd.values_at(*line).count(marker) == 2
    brd.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  else
    nil
  end
end
  
def computer_places_piece!(brd)
  square = nil

  # offense
  if !square
    WINNING_LINES.each do |line|
      square = detect_threat(line, brd, COMPUTER_MARKER)
      break if square
    end
  end

  # defense
  WINNING_LINES.each do |line|
    square = detect_threat(line, brd, PLAYER_MARKER)
    break if square
  end

  # pick square #5
  if !square && empty_squares(brd).include?(5)
    square = 5
  else
    square = empty_squares(brd).sample # pick a random square
  end

  brd[square] = COMPUTER_MARKER
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return :player
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return :computer
    end
  end
  nil
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def place_piece!(brd, player)
  if player == :player
    player_places_piece!(brd)
  else
    computer_places_piece!(brd)
  end
end

def alternate_player(player)
  player == :computer ? :player : :computer 
end

wins = 0
computer_wins = 0
current_player = FIRST_MOVE

loop do
  board = initialize_board
  puts current_player

  while current_player == :choose
    prompt "Would you like to play first? (y or n)"
    answer = gets.chomp

    if answer.downcase.start_with?('y') 
      current_player = :player 
    else 
      current_player = :computer
    end
  end

  loop do
    display_board(board)
    place_piece!(board, current_player)
    current_player = alternate_player(current_player)
    break if someone_won?(board) || board_full?(board)
  end

  display_board(board)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won!"
    wins += 1 if detect_winner(board) == :player
    computer_wins += 1 if detect_winner(board) == :computer
  else
    prompt "It's a tie!"
  end

  if wins == 5 || computer_wins == 5
    prompt("We have a winner. Final score: #{wins}; Computer: #{computer_wins}")
    break
  else
    prompt("The current score is: #{wins}; Computer: #{computer_wins}.")
  end

  prompt "Play again? (y or n)"
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

prompt "Thanks for playing Tic Tac Toe! Good bye!"
