#!/usr/bin/ruby

# RUBY PREREQUISITS
require "rubygems"
require "yaml"

require "from_future_import.rb"    # @todo replace by activesupport / activestring (mine)
require "activeresource.rb"
    
begin
  # LOAD THE UNIVERSE
  require_package "backend"


  # CODE GAMES!
  $game_name = ARGV[0] || $config['default_game']
  if $game_name.ends_with? "/" # clean game name
    $game_name = $game_name[0...$game_name.size-1]
  end

  require_package $game_name

  println "no game #{$game_name} found" and exit unless $game_name.is_folder?


  # PLAY!
  class_name = $game_name.classify
  $game_class = class_name.instantiate rescue quit("Your game class needs to be called #{class_name}")

  begin
    $game_class.run
  rescue Exit => e # @todo should not be handled via exception
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

def repl
  s = gets.trim
  begin
    result = eval(s)
  rescue Exception => e
    puts "Exception: #{e.inspect}"
  rescue SyntaxError => e
    puts "SyntaxError: #{e.inspect}"
  end
end