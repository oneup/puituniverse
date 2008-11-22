#!/usr/bin/ruby

# building the game thing from scratch, following http://code.google.com/p/gosu/wiki/RubyTutorial

require "rubygems"
require 'gosu'
require "yaml"
require "from_future_import.rb"  # gemify this !
require "activeresource.rb"      # gemify this !

class GameWindow < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Gosu Tutorial Game"
  end

  def update
  end

  def draw
  end
end

window = GameWindow.new
window.show