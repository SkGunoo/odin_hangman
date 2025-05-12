module Hangman
  
    class Game
      
      attr_accessor :word_to_guess, :word_guessing_progress, :wrong_letters, :number_of_fails

      def initialize
        @new_game_or_load_game = ask_player_about_new_game_or_load_game
        @word_to_guess = nil
        @word_guessing_progress = nil
        @wrong_letters = nil
        @number_of_fails = nil
        get_data(@new_game_or_load_game)
        check_value_of_instance_variables
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
        @word_guessing_progress = []
        @wrong_letters = []
        @number_of_fails = 0
      end

      def ask_player_about_new_game_or_load_game
        puts " HI, welcome to hangman"
          answer = ask_player([0,1], "     type '0' for new game or type '1' to load saved game")
      end

      def ask_player(answer_range, asking_message)
        answer = nil
        loop do
          puts asking_message
          answer = gets.chomp.to_i
          break answer if answer_range.include?(answer)
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

    end
end


include Hangman

Game.new()
