module ZOrder
  Background = 0
  Tracks = 1
  UI = 10
end


class Olympics < ActiveGame
  resolution [160*4, 100*4]

  def setup
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
