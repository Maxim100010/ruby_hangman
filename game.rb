# frozen_string_literal: true

class Game
  attr_accessor :list_of_words, :chosen_word, :chosen_word_hidden, :used_letters

  def initialize
    @list_of_words = populate_list_of_words
    @chosen_word = list_of_words.sample.split('')
    @chosen_word_hidden = Array.new(chosen_word.length, ' _ ')
    @used_letters = []
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

  def play_game
    puts 'Welcome to hangman! You have 10 guesses to guess a word'
    number_of_tries = 10
    while number_of_tries != 0
      puts "Guesses remaining: #{number_of_tries}"
      puts "#{chosen_word_hidden.join}\n\n"
      puts 'Guess a letter (A-Z)'
      guess = ''
      guess = gets.chomp until guess.length == 1 && /^[a-z]$/i.match?(guess)
      puts "\n\n"
      number_of_tries -= 1 if guess_letter(guess.upcase).zero?
      puts "Used letters: #{used_letters.join(' ')}"
      if chosen_word.join == chosen_word_hidden.join.gsub(/\s+/, '')
        puts "\nYou win!!! The word was: #{chosen_word.join}"
        return
      end
    end
    puts "\nYou lose :( The word was: #{chosen_word.join}"
  end
end

class Main

  def initialize
  end

  def self.start_game
    Game.new.play_game
  end
end


Main.start_game
