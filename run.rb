#!/usr/bin/ruby

# RUBY PREREQUISITS
require "rubygems"
require "yaml"
require "from_future_import.rb"  # gemify this
require "activeresource.rb"      # gemify this  

def require_package folder
  init_file = "#{folder}/init.rb"
  require init_file if init_file.is_file?
  require_all folder
end
    
require "backend/init"           # core setup routine is special, so the usual each_dir require_all loop doesn't work

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

#rescue Exception => e  
#  println "GRR, EXCEPTION!"
#  println e.message  
#  println e.backtrace
#  
#  repl
#end