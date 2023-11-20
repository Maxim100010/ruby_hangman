# frozen_string_literal: true

require 'json'

class Game
  attr_accessor :list_of_words, :chosen_word, :chosen_word_hidden, :used_letters

  def initialize(list_of_words = populate_list_of_words, chosen_word = list_of_words.sample.split(''),
                 chosen_word_hidden = Array.new(chosen_word.length, ' _ '), used_letters = [])
    @list_of_words = list_of_words
    @chosen_word = chosen_word
    @chosen_word_hidden = chosen_word_hidden
    @used_letters = used_letters
  end

  def populate_list_of_words
    words = []
    File.open('google-10000-english-no-swears.txt', 'r') do |file|
      file.each_line do |line|
        words << line.chomp.upcase if line.chomp.length.between?(5, 12)
      end
    end
    words
  end

  def guess_letter(letter)
    if chosen_word.include?(letter)
      indexes = []
      chosen_word.each_index { |i| indexes << i if chosen_word[i] == letter }
      chosen_word_hidden.each_index { |i| chosen_word_hidden[i] = " #{letter.upcase} " if indexes.include?(i) }
      used_letters.push(letter) unless used_letters.include?(letter)
      1
    else
      return 1 if used_letters.include?(letter)

      used_letters.push(letter) unless used_letters.include?(letter)
      0
    end
  end

  def play_game(rounds_left = 10)
    puts 'Welcome to hangman! You have 10 guesses to guess a word'
    puts "Used letters: #{used_letters.join(' ')}" if rounds_left < 10
    while rounds_left != 0
      puts "Guesses remaining: #{rounds_left}"
      puts "#{chosen_word_hidden.join}\n\n"
      puts 'Guess a letter (A-Z) or type SAVE to save and quit'
      guess = ''
      guess = gets.chomp until (guess.length == 1 && /^[a-z]$/i.match?(guess)) || guess.downcase == 'save'
      puts "\n\n"
      save_game(rounds_left) if guess == 'save'
      rounds_left -= 1 if guess_letter(guess.upcase).zero?
      puts "Used letters: #{used_letters.join(' ')}"
      if chosen_word.join == chosen_word_hidden.join.gsub(/\s+/, '')
        puts "\nYou win!!! The word was: #{chosen_word.join}"
        File.open('save_data.json', 'w') {|file| file.truncate(0) }
        return
      end
    end
    puts "\nYou lose :( The word was: #{chosen_word.join}"
    File.open('save_data.json', 'w') {|file| file.truncate(0) }
  end

  def save_game(rounds_left)
    save_file = {
      'list_of_words' => list_of_words,
      'chosen_word' => chosen_word,
      'chosen_word_hidden' => chosen_word_hidden,
      'used_letters' => used_letters,
      'rounds_left' => rounds_left
    }
    File.open('save_data.json', 'w') do |file|
      file.write(JSON.pretty_generate(save_file))
    end
    exit
  end
end

class Main
  def self.start_game
    puts 'Press N to start new game, Press L to load existing save'
    while (choice = gets.chomp.downcase)
      case choice
      when 'n'
        File.open('save_data.json', 'w') {|file| file.truncate(0) }
        Game.new.play_game
        break
      when 'l'
        begin
          file_content = File.read('save_data.json')
          recreated_object = JSON.parse(file_content)

          puts 'Previous game successfully loaded'
          loaded_game = Game.new(recreated_object['list_of_words'],
                                 recreated_object['chosen_word'], recreated_object['chosen_word_hidden'], recreated_object['used_letters'])
          loaded_game.play_game(recreated_object['rounds_left'])
        rescue Errno::ENOENT
          puts 'File not found at save_data.json. Make sure the file exists.'
        rescue JSON::ParserError
          puts 'There is currently no save game'
        end
        break
      else
        puts 'Please select either N or L'
      end
    end
  end
end

Main.start_game
