# a super mega massive awesome space invaders clone LOL !!!!111eleven
# cc oneup
# thx kingpepe

class SpaceinvadersGame < Game
  def setup
    print "LOL"
    @objects << PlayerShip.new
    
    x = 10
    y = 10
    x_pitch = (EnemyShip.img.width + 10)
    while (x+x_pitch) < width-10
      @objects << EnemyShip.new(x, y)
      x += x_pitch
    end
  end
end

# now: other ships :)

class EnemyShip < Gameobject
  def self.img
    @@img ||= "spaceinvaders/ship/enemy".img
  end
  
  def img
    @@img
  end

  def initialize x, y
    @x = x
    @y = y
  end
  
  def update
    # todo: jump every 10 ticks
  end
  
  def draw
    img.draw(@x, @y, 0)
  end
end

class PlayerShip < Gameobject
  def initialize
    @image = "spaceinvaders/ship/enemy".img

    @x = 0
    @y = $game.height - @image.height - 10 # 10 pixels free to bottom
    @vel_x = 0
    @vel_y = 0
  end
  
  def update    
    @x += @vel_x
    @y += @vel_y
    @x = (0..$game.width).limit @x
    @y = (0..$game.height).limit @y
  end
  
  def on_button down, id
    if id == Gosu::Button::GpLeft or id == Gosu::Button::KbLeft # fixme. maket it "button.is :left"
      if down
        @vel_x = -10
      else
        @velx = 0
      end
    elsif id == Gosu::Button::GpRight or id == Gosu::Button::KbRight
      if down
        @vel_x = 10
      else
        @vel_x = 0
      end
    end
  end
  
  def draw
    @image.draw(@x, @y, 0)
  end
end