#!/usr/bin/ruby

# RUBY PREREQUISITS
require "rubygems"
require "yaml"
require "from_future_import.rb"  # gemify this !
require "activeresource.rb"      # gemify this !
    
begin

# LOAD THE UNIVERSE
".".each_dir do |bundle|
  require_package bundle
end

# CODE GAMES!
$game_name = ARGV[0] || $config['default_game']

# PLAY!
class_name = "#{$game_name.capitalize}_game"
$game_class = class_name.instantiate #rescue quit("Your game class needs to be called #{class_name}")

$game = $game_class.new
$game.show

# get this exception REPL shell running
#rescue Exception => e  
#  println "GRR, EXCEPTION!"
#  println e.message  
#  println e.backtrace
#  
#  repl
end