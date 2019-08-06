require 'json'

class Hangman
  attr_accessor :secret_word, :max_tries, :current_tries,
                :template, :wrong_letters

  @@dictionary = File.readlines("5desk.txt").map do |word|
    word = word.gsub("\n", "").upcase
  end


  def initialize (word = @@dictionary[rand(@@dictionary.length)],
                  max_tries = 7,
                  current_tries = 0)

    @secret_word = word
    @max_tries = max_tries
    @current_tries = current_tries
    @template = Array.new(word.length, "")
    @wrong_letters = []
  end


  def load fn
    data = JSON.load(File.read "#{fn}.txt")
    @secret_word = data["secret_word"]
    @max_tries = data["max_tries"]
    @current_tries = data["current_tries"]
    @template = data["template"]
    @wrong_letters = data["wrong_letters"]

    puts "File loaded"
    return "Your last progress: #{progress_format(@template)}. Wrong guesses: #{@wrong_letters.join(" ")}. Tries left #{@max_tries - @current_tries}"
  end


  def to_json
    JSON.dump ({
      :secret_word => @secret_word,
      :max_tries => @max_tries,
      :current_tries => @current_tries,
      :template => @template,
      :wrong_letters => @wrong_letters,
    })
  end


  def save
    puts "Name your save file"
    input = gets.chomp
    File.open("#{input}.txt", 'w') do |f|
      f.puts self.to_json
    end
    return "You have saved your game progress"
  end


  def take_guess letter
    letter = letter.upcase
    if @template.include? letter
      return "You already got that letter correct!"
    end

    if @wrong_letters.include? letter
      return "You already got that letter wrong!"
    end

    if @secret_word.include? letter
      @secret_word.split("").each_with_index do |char, idx|
        if char == letter
          @template[idx] = letter
        end
      end
    else
      @current_tries += 1
      @wrong_letters << letter
    end

    if @template.join("") == @secret_word
      @current_tries = @max_tries
      return "YOU HAVE WON THE GAME, the word IS #{@secret_word}"
    end

    if @current_tries == @max_tries
      return "YOU HAVE LOST. The word is #{@secret_word}. Try again next time"
    end

    return "Your progress: #{progress_format(@template)}. Wrong guesses: #{@wrong_letters.join(" ")}. Tries left #{@max_tries - @current_tries}"
  end


  private

  def progress_format template
    progress = @template.inject("") do |str, elem|
      result = elem == "" ? " _" : " #{elem}"
      str = str + result
      str
    end
  end
end


def main
  puts "GAME STARTING"
  game = Hangman.new
  puts "Would you like to load a save file? [Y/N]"
  input = gets.chomp.upcase
  if input == "Y"
    puts "Enter the name of your save file"
    fn = gets.chomp
    if File.exist?("#{fn}.txt")
      puts game.load fn
    else
      puts "File does not exist"
    end
  end

  while game.current_tries < game.max_tries
    puts "You can enter a guess OR save your game. Type a letter to guess or type SAVE to save"

    # Receiving input loop.
    while true
      input = gets.chomp
      if input == "SAVE"
        puts game.save
        break
      elsif /\A[a-zA-Z]\z/.match?(input)
        break
      else
        puts "Please enter a letter or \"SAVE\""
      end
    end

    if input == "SAVE"
      puts "You can continue the game or stop here with Ctrl + C"
    else
      puts game.take_guess input
    end
  end
end

main
