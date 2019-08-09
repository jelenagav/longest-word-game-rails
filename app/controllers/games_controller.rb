require "open-uri"

class GamesController < ApplicationController
  VOWELS = %w(A E I O U Y)

  def new
    @letters = Array.new(5) { VOWELS.sample }
    @letters += Array.new(5) { (('A'..'Z').to_a - VOWELS).sample }
    @letters.shuffle!
  end

  def score
    @attempt = params[:word]
    @letters = params[:letters]
    @start_time = DateTime.parse(params[:start_time])
    @end_time = Time.now
    @result = run_game(@attempt, @letters, @start_time, @end_time)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
    result
  end

    def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "Good job! #{attempt.upcase} is an English word that can be spelt from the grid."]
      else
        [0, "#{attempt.upcase} is not an English word."]
      end
    else
      [0, "#{attempt.upcase} cannot be spelt from the letters in the grid."]
    end
  end

  private

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}").read
    formated_response = JSON.parse(response)
    formated_response['found']
  end

  def included?(word)
    word = word.upcase
    grid = params[:grid]
    word.chars.all? { |char| word.count(char) <= grid.count(char) }
  end
end






