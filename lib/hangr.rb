require "hangr/version"
require "hangr/init_db"
require "pry"
require "/hangr/player"
require "/hangr/game"

module Hangr
  # Your code goes here...
  class App
  	def initialize
  		@player = nil
  	end

  	def greeting
  		puts "Welcome to hangman!"
  		puts "What is your name?"
  		name = gets.chomp

  		existing_player = Player.find_by(name: name)
  		if existing_player
  			@player = existing_player
  		else
  			@player = Player.create(name: name, total_wins: 0)
  		end
  	end

  	def resume_game
  		games = Game.where(player_id: @player.id, finished: false)
  		puts "Which game would you like to play?"
  		games.each do |game|
  			puts "ID: #{game.id} | Turn Count: #{game.turn_count}"
  		end

  		game_id = gets.chomp.to_i
  		# map(&:id) is the same as map { |x| x.id }
  		until games.map(&:id).include?(game_id)
  			puts "You have to pick from the list, dummy."
  			game_id = gets.chomp.to_i
  		end

  		until Game.exists?(player_id: @player.id, finished: false, id: game_id)
  			puts "You have to pick from the list of *your* games!"
  			game_id = gets.chomp.to_i
  		end

  		@game = Game.find(game_id)

  	end

	def run
		greeting
		choose_game
		until @game.finish?
			take_turn
		end
		play_again?
	end

  end
end

app = Hangr::App.new
app.run
