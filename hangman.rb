module Hangman
  
    class Game
      
      attr_accessor :word_to_guess, :word_guessing_progress, :wrong_letters, :number_of_fails

      def initialize
        @wrong_letters = []
        @new_game_or_load_game = ask_player_about_new_game_or_load_game
        @word_to_guess = nil
        @word_guessing_progress = nil
        @number_of_fails = 0
        get_data(@new_game_or_load_game)
        # check_value_of_instance_variables
        play_game
      end

      def get_data(game_mode)
        if game_mode == 0 
          set_data_for_new_game
        else
          load_data_from_saved_game()
        end
      end

      def set_data_for_new_game
        @word_to_guess = get_new_word
        @word_guessing_progress = Array.new(@word_to_guess.length,"_")
        @wrong_letters = []
        @number_of_fails = 0
      end

      def ask_player_about_new_game_or_load_game
        puts " HI, welcome to Hangman"
          answer = ask_player(["0","1"], "     type '0' for new game or type '1' to load saved game")
          answer.to_i
      end

      def ask_player(answer_range, asking_message)
        answer = nil
        loop do
          puts asking_message
          answer = gets.chomp.downcase
          break answer if (answer_range.include?(answer) && !@wrong_letters.include?(answer)) || answer == 'save'
        end
      end

      def get_new_word
        file = File.open('google-10000-english-no-swears.txt')
        words = file.readlines.filter {|word| word.length > 5 && word.length < 12}
        random_word_to_guess = words.shuffle[0]
        file.close
        return random_word_to_guess.chomp
      end

      def check_value_of_instance_variables
        puts "game mode: #{@new_game_or_load_game} word to guess: #{word_to_guess}, word guessing progress #{word_guessing_progress}, number of fails #{number_of_fails}, wrong letters: #{wrong_letters}"
      end

      def play_game
        #show game progress before start the game
        display_game_progress
        loop do
          get_letter_from_player(ask_player(("a".."z").to_a, "type a letter to guess or type 'save' to save the game"))
          display_game_progress
          # check_value_of_instance_variables
          
          break if  check_win
        end
      end

      def draw_pyramid(turn, height)
        symbol_array = Array.new(height) { |e| e >= turn ? "□" : "▣"}
        num_of_rows = (0..height).to_a
        num_of_rows.each do |num|
          ((height - num) + 10).times {print " "}
          (num*2).times {print symbol_array.reverse[num]}
          puts "\n"
        end
      end


      def display_game_progress
        print "\n \nyour word guess progress: [ #{@word_guessing_progress.join(" ")} ]"
        puts "   wrong guesses: [ #{@wrong_letters.sort.join(' ')}]"
      end

      def check_win
        #ask for replay if player won the game 
        if @word_guessing_progress.join() == word_to_guess
          puts 'YOU WON THE GAME!!!!'
          true
        elsif @number_of_fails == 10
          draw_pyramid(number_of_fails, 11)
          puts "Pyramid is now FULLY charged you are LOST!" 
          puts "The answer was : #{word_to_guess}"
          true
        else
          false
        end
      end

      def get_letter_from_player(letter)
        if word_to_guess.include?(letter)
          # puts "haha"
          add_letter_to_letter_to_progress(letter)
        elsif letter == 'save'
          puts" game saved!"
          #save the game
        else
          #add the letter picked by user to wrong letters
          @wrong_letters.push(letter)
          @number_of_fails += 1
          draw_pyramid(number_of_fails, 11)
          puts "\n your guess is WRONG! Pyraid is charging up.... \n you don't want pyramid to be fully charged!"
        end
      end

      def add_letter_to_letter_to_progress(letter)
        #turn word to guess to array
        @word_to_guess.split('').each_with_index do |char, index|
          #add matching letter to guess progress
          @word_guessing_progress[index] = letter if char == letter
        end
      end
    end
end


include Hangman

Game.new()
