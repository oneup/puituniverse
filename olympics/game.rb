module ZOrder
  Background = 0
  Tracks = 1
  UI = 10
end

require "objects" # TODO: update ruby path in run_game.rb so we can just say require "objects"

class GameWindow < Gosu::Window
  def initialize
    super(160*4, 100*4, false)
    self.caption = "Puit Olympics"
    $window = self

    Resources.init(self)
    @objects = []
    
    $level = Level.new
    @objects << $level
    @objects << CpuPlayer.new("jack", 0)
    @objects << CpuPlayer.new("jack", 1)
    @objects << CpuPlayer.new("jack", 2)
    @player = Player.new "jack", 3
    @objects << @player
  end

  def update
    @objects.each {|o| o.update }
  end

  def draw
    @objects.each {|o| o.draw }
  end
  
  def button_down id
    close if id == Gosu::Button::KbEscape or id == 12 # "q" => hackety hack
      
    @player.on_button true, id
  end
  
  def button_up id
    @player.on_button false, id
  end
end
