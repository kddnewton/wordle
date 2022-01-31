# frozen_string_literal: true

require "open3"

# Build up a thread-safe queue for every word in the dictionary.
queue = Queue.new
File.foreach("words.txt", chomp: true) { |word| queue << word }

# Create a hash whose default value is 0 for any new keys. We'll use this to
# track how many guesses it took to successfully get to the final word.
results = Hash.new { 0 }

# Build up a list of worker threads that will pull words from the dictionary
# until they are all exhausted.
workers =
  8.times.map do
    Thread.new do
      until queue.empty?
        word = queue.shift
        guesses = 0

        # Open a new ruby process executing the wordle.rb file. Within the
        # block, you can write to the STDIN and read from the STDOUT IO objects
        # to communicate with the child process.
        Open3.popen2("ruby wordle.rb") do |stdin, stdout, waiter|
          # The protocol is a little loose, but basically if you get to the
          # final word it outputs "The word is", so we can use that as our loop
          # condition.
          until (read = stdout.read(3)) == "The"
            guesses += 1

            # Read the rest of the guess, and then skip past the prompt on the
            # STDOUT pipe.
            guess = "#{read}#{stdout.read(2)}"
            stdout.read(10)

            # Create the input necessary to tell the child process which tiles
            # turned which colors. This is analogous to inputting the guessed
            # word into the text box.
            chars =
              guess.each_char.map.with_index do |char, index|
                if word[index] == char
                  "g"
                elsif word.include?(char)
                  "y"
                else
                  "_"
                end
              end

            # Write the input to STDIN and flush it down the pipe so the child
            # process will unblock its read.
            stdin.write("#{chars.join}\n")
            stdin.flush
          end

          # Once we get here, it has started to print "The word is" so read the
          # rest and then verify that it selected the correct word.
          stdout.read(10)
          raise if stdout.read(5) != word
        end

        results[guesses] += 1
      end
    end
  end

# Join each worker thread back into the main thread to make sure we wait for
# everything to complete.
workers.map(&:join)

# Print out the final results, which indicates how many guesses it took to get
# to each word. Ideally all of the numbers would be 5 or below (the number of
# actual guesses you get).
p results.sort.to_h

# Get the score of the results, which is 10 points for every word within 3
# guesses, 5 points for every word guessed within 6 guesses, and no points for
# any other words.
score =
  (results[1] + results[2] + results[3]) * 10 +
  (results[4] + results[5] + results[6]) * 5

p score
