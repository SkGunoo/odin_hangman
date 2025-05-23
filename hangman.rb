require 'yaml'
require 'colorize'

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

      #get a integer value 1 or 2 from user to decide game mode
      def ask_player_about_new_game_or_load_game
        puts " HI, welcome to Hangman"
          answer = ask_player(["1","2"], "     type '1' for new game or type '2' to load saved game")
          #answer is string, so convert it to integer
          answer.to_i
      end

      #set game data for instance variables
      def get_data(game_mode)
        if game_mode == 1
          set_data_for_new_game

          #load if save data exist
        elsif save_data_exist?
          load_data_from_saved_game()
        else
          #prevent error from loading empty file
          puts "there is no saved file, starting a new game"
          set_data_for_new_game
        end
      end

      def play_game
        #show game progress before start the game
        display_game_progress

        #main game play loop
        loop do
          get_letter_from_player(ask_player(("a".."z").to_a, "\ntype a letter to guess or type 'save' to save the game"))
          display_game_progress
          break if check_win
        end
        #ask for replay when game is done
        ask_player_about_replay
      end

      #make sure to get right answer from user
      def ask_player(answer_range, asking_message)
        answer = nil
        loop do
          puts asking_message
          answer = gets.chomp.downcase
          break answer if (answer_range.include?(answer) && !@wrong_letters.include?(answer)) || answer == 'save'
        end
      end

      
      def set_data_for_new_game
        @word_to_guess = get_new_word
        @word_guessing_progress = Array.new(@word_to_guess.length,"_")
        @wrong_letters = []
        @number_of_fails = 0
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

      def add_letter_to_letter_to_progress(letter)
        #turn word to guess to array
        @word_to_guess.split('').each_with_index do |char, index|
          #add matching letter to guess progress
          @word_guessing_progress[index] = letter if char == letter
        end
      end
      

      #start new game if player want to play again
      def ask_player_about_replay
        answer = ask_player(['1','2'],"Do you want to replay the game? \n type " + '" 1 "'.colorize(:yellow) + " to replay or type " + '" 2 "'.colorize(:yellow) + " to stop")
        if answer == '1'
          set_data_for_new_game
          puts "New game started guess a new word!".colorize(:yellow)
          play_game

        else
          puts "Goodbye"
        end
      end


      #use number of fail to indicate how many chances user have
      def draw_pyramid(number_of_fail, height)
        #creates array of symbols corespons to each row 
        symbol_array = Array.new(height) { |e| e >= number_of_fail ? "□" : "▣".colorize(:yellow)}
        num_of_rows = (0..height).to_a
        num_of_rows.each do |num|
          ((height - num) + 10).times {print " "}
          (num*2).times {print symbol_array.reverse[num]}
          puts "\n"
        end
      end


      #show current game progress and characters already wrongly guessed
      def display_game_progress
        print "\n \nYour word guessing progress: [ #{@word_guessing_progress.join(" ").colorize(:red)} ]"
        puts "   Wrong guesses: [ #{@wrong_letters.sort.join(' ')}]"
      end


      def check_win
        if @word_guessing_progress.join() == word_to_guess
          puts 'YOU WON THE GAME!!!!'.colorize(:yellow)
          true
        #game lost 
        elsif @number_of_fails == 10
          draw_pyramid(number_of_fails, 11)
          puts "Pyramid is now FULLY charged you are LOST!\n".colorize(:yellow)
          puts "The answer was : #{word_to_guess.colorize(:red)}"
          true
        else
          false
        end
      end


      def get_letter_from_player(letter)
        #when user guessed correctly
        if word_to_guess.include?(letter)
          puts "\nYou guessed correctly!, guess another one!".colorize(:yellow)
          add_letter_to_letter_to_progress(letter)
        #when user want to save the game
        elsif letter.downcase == 'save'
          puts" Game saved!"
          save_the_game
          exit
        else
          #add the letter picked by user to wrong letters
          @wrong_letters.push(letter)
          @number_of_fails += 1
          draw_pyramid(number_of_fails, 11)
          puts "\n Your guess is WRONG! Pyraid is charging up.... \n you don't want pyramid to be fully charged!".colorize(:red)
        end
      end

      #save the game sate to a yaml file
      def save_the_game
        f = File.new("hangman_data.yaml", "w")

        data = YAML.dump({
          word_to_guess: @word_to_guess,
          word_guessing_progress: @word_guessing_progress,
          number_of_fails: @number_of_fails,
          wrong_letters: @wrong_letters

        })

        f.puts data
        f.close
      end

      #check if save file is empty
      def save_data_exist?
        f = File.open("hangman_data.yaml",'r')
        if f.size == 0 
          f.close
          false
        else
          f.close
          true
        end

      end

      #load the game state from yaml file
      def load_data_from_saved_game
        f = File.open("hangman_data.yaml",'r+')
        data = YAML.load(f)
        @wrong_letters = data[:wrong_letters]
        @word_to_guess = data[:word_to_guess]
        @word_guessing_progress = data[:word_guessing_progress]
        @number_of_fails = data[:number_of_fails]
        puts "game loaded sucessfully "
        f.truncate(0)
        f.close
      end
    end
end


include Hangman

Game.new()
