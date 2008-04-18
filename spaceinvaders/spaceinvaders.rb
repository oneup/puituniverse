# a super mega massive awesome space invaders clone LOL !!!!111eleven
# cc oneup
# thx kingpepe

class SpaceinvadersGame < Game
  def setup
    @objects << PlayerShip.new

    y = 10
    6.times do |row|
      x = 10
      while true
        enemy = EnemyShip.new(x, y, row+1)
        #break if enemy.outside? $game
        @objects << enemy
        x += enemy.width + 10
        break if x + enemy.width > $game.width
      end
      y += enemy.height + 10
    end
  end
end

# now: other ships :)

class EnemyShip < Gameobject    
  def initialize x, y, row
    @row = row
    @x = x
    @y = y
    set_sprite("spaceinvaders/Space Invader#{@row}")
  end
  
  def update
    # todo: jump every 10 ticks
  end
end

class Shot < Gameobject
  def initialize x, y
    @x = x
    @y = y
    set_sprite "spaceinvaders/Shot1"
  end
  
  def update
    @y -= 5
    
    $game.all(EnemyShip).each do |enemy|
      if self.collides_with? enemy # todo: why doesn't coldec work?
        enemy.die
      end
    end
  end
end

class PlayerShip < Gameobject
  def initialize
    set_sprite("spaceinvaders/Shooter")
    @x = 0
    @y = $game.height - sprite.height - 10 # 10 pixels free to bottom
    @vel_x = 0
    @vel_y = 0
    
    map_keys(Gosu::Button::KbLeft => :move_left,
             Gosu::Button::KbRight => :move_right,
             Gosu::Button::GpLeft => :move_left,
             Gosu::Button::GpRight => :move_right,
             Gosu::Button::KbSpace => :shoot)
  end
  
  def update
    @x += @vel_x
    @y += @vel_y
    @x = (0..$game.width).limit @x
    @y = (0..$game.height).limit @y
  end
  
  def shoot pressed
    if pressed
      shot = Shot.new @x, @y - self.height
      $game.objects << shot
    end
  end
  
  def move_left pressed
    @vel_x = -5 if pressed
    @vel_x = 0 if not pressed and not is_pressed? :move_right
  end
  
  def move_right pressed
    @vel_x = 5 if pressed
    @vel_x = 0 if not pressed and not is_pressed? :move_left
  end
end