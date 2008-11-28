require "yaml"
#require "jabber"

# http://en.wikipedia.org/wiki/Shufflepuck_Cafe
# thx http://youtube.com/watch?v=9pUmfxM9h54

class Mm9 < Game
  fullscreen false

  def setup
    @objects << Player.new
  end

  def draw
    super
  end
end

class Player < Gameobject
  def initialize
    @x = 0
    @y = 0
    @velocity_x = 0
    @velocity_y = 0
    @speed = 4
    
    set_keys(Gosu::Button::KbRight => :run_right,
             Gosu::Button::KbLeft => :run_left)
  end
  
  def run_right(down)
    if down
      @velocity_x = @speed
    else
      @velocity_x = 0
    end
  end
  
  def run_left(down)
    if down
      @velocity_x = -@speed
    else
      @velocity_x = 0
    end
  end
  
  def update
    @x += @velocity_x
    @y += @velocity_y
  end
  
  def draw
    if @velocity_x > 0
      "mm9/blue/run".anim(24,24).draw(@x, @y) # zoom
    else
      "mm9/blue/stand".anim(24,24,50).draw(@x, @y)
    end
  end
end