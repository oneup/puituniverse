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
class_name = "#{$game_name.capitalize}_game"
$game_class = class_name.instantiate #rescue quit("Your game class needs to be called #{class_name}")
  
$game = $game_class.new
$game.show

