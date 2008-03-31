#!/usr/bin/ruby

# RUBY PREREQUISITS
require "rubygems"
require 'gosu'
require "yaml"

# LITTLE GAME LIBRARY
require "core/pimped_ruby.rb"
require "core/gfx.rb"
require "core/gameobject.rb"
#require "core/activeresource"
#$root = active_resource("./")

$config = YAML::load_file "core/core.yml"

# GO GAME!
$game_folder = $config['game_name']
$LOAD_PATH.push($game_folder)
require "game.rb"

window = GameWindow.new
window.show

