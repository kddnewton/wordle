# frozen_string_literal: true

# Read the words.txt file and get all of the possible words in the dictionary.
words = File.readlines("words.txt", chomp: true)

# Set of a list of letters remaining to be guessed. This is important for
# building up the list of weights for choosing optimal guesses.
letters = ("a".."z").to_a

while words.length > 1
  # First, build up a list of "weights". This is a hash of letters that point to
  # the number of unique words that contain those letters. So for example, if
  # you had the words:
  #
  #     apple
  #     knoll
  #
  # You would end up with a hash of weights that looked like:
  #
  #     { "a" => 1, "e" => 1, "k" => 1, "l" => 2, "n" => 1, "o" => 1, "p" => 1 }
  #
  weights = Hash.new { 0 }
  words.each { |word| word.each_char.uniq.tally(weights, &:itself) }
  weights.select! { |letter, _| letters.include?(letter) }

  # Determine which word we're guessing based on which word in the remaining
  # list has the highest weight. We determine the weight by adding the weight of
  # each letter in the word together.
  guess = words.max_by { |word| word.each_char.uniq.sum(&weights) }

  # Print out the the guessed word, the number of remaining words in the
  # dictionary, and a prompt for the user to enter the next input. Additionally
  # flush STDOUT so it doesn't buffer and we're guaranteed the user sees the
  # input immediately.
  print "#{guess} (%05d)> " % words.length
  STDOUT.flush

  # Read a line of input from the user off STDIN, normalize it by stripping the
  # trailing newline and making it lowercase. Then switch on that value.
  case input = gets.chomp.downcase
  when "?"
    # If the user inputs a "?"", then that's used to indicate that the word that
    # was guessed was not a valid word according to wordle. It shouldn't happen
    # since I pulled the list straight from the wordle source, but it's possible
    # that it could change.
    words.delete(guess)
  when "l", "letters"
    # If the user inputs "l" or "letters" then output the remaining letters that
    # could be guessed. This is effectively the list of uncolored letters on the
    # wordle keyboard.
    p letters
  when "w", "words"
    # If the user inputs "w" or "words" then output the remaining dictionary
    # that could be matched.
    p words
  when "q", "quit"
    # If the user inputs a "q" or "quit", then just exit the program.
    exit
  when /^[_gy]{5}$/
    # Otherwise, if the user has input 5 characters consisting of "_", "g", and
    # "y", we're going to assume this was a turn. Each character represents the
    # color of the tile that was turned for the given letter.
    #
    # For example, if word was "apple" and you guessed "angel", the tiles would
    # turn [green][gray][gray][yellow][yellow]. So you would input into the
    # prompt "g__yy".
    actions = guess.each_char.zip(input.each_char)
    actions.each_with_index do |(letter, action), index|
      letters.delete(letter)

      case action
      when "_"
        # In this case, the letter is not in the final word, so delete any words
        # from the dictionary that contain that letter.
        words.reject! { |word| word.include?(letter) }
      when "g"
        # In this case, the letter is in the final word at this index, so delete
        # any words from the dictionary that do not also have this letter at
        # that index.
        words.reject! { |word| word[index] != letter }
      when "y"
        # In this case, the letter is in the final word but at a different
        # index, so delete any words from the dictionary that either do not have
        # this letter or that have this letter at this same index.
        words.reject! { |word| !word.include?(letter) || word[index] == letter }
      end
    end
  end
end

# At this point, there should only be one word left in the dictionary, which
# means we've found our final word.
puts "The word is: #{words.first}"
