#!/usr/bin/ruby

# RUBY PREREQUISITS
require "rubygems"
require "yaml"

# PIMP MY RUBY
require "from_future_import.rb"
require 'gosu'

# LOAD THE UNIVERSE
".".each_dir do |bundle|
  require_all "#{bundle}"
end

# CODE GAMES!
$game_name = ARGV[0] || $config['default_game']

# PLAY!
$game_class = $game_name.instantiate rescue quit("Your game class needs to be called #{$game_name.classify}")
  
$game = $game_class.new
$game.show

