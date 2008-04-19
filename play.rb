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

if $game_name.ends_with? "/"
  $game_name = $game_name[0...$game_name.size-1]
end

println "no game #{$game_name} found" and exit unless $game_name.is_folder?

# PLAY!
class_name = "#{$game_name.capitalize}_game"
$game_class = class_name.instantiate rescue quit("Your game class needs to be called #{class_name}")

begin
  $game_class.run
rescue Exit => e
  println "\nGAME OVER: #{e}\n"
end

# get this exception REPL shell running
#rescue Exception => e  
#  println "GRR, EXCEPTION!"
#  println e.message  
#  println e.backtrace
#  
#  repl
end