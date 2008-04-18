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
  attr_reader :row
  
  def initialize x, y, row
    @row = row
    @velocity = 0.5
    @x, @y = x, y
    set_sprite("spaceinvaders/Space Invader#{@row}")
  end
  
  def change_direction_and_go_to_next_row
    @velocity = -@velocity
    @y += sprite.height + 10
  end
  
  def update
    @x += @velocity

    if right > $game.width or left < 0
      # one space invader touched the right or left border!!!      
      # move all in this row
      for ship in $game.all(EnemyShip)
        ship.change_direction_and_go_to_next_row if ship.row == row
      end
    end
    
    # kill player?
    for ship in $game.all(PlayerShip)
      if ship.collides_with? self
        ship.die
      end
    end
    
    # shoot
    if probability(0.0005)
      shot = Shot.new @x, @y+sprite.height, +4, PlayerShip
      $game.objects << shot
    end
    
  end
end

class Shot < Gameobject
  def initialize x, y, vel_y, target
    @x, @y, @vel_y = x, y, vel_y
    @target = target
    set_sprite "spaceinvaders/Shot1"
  end
  
  def update
    @y += @vel_y
    
    $game.all(@target).each do |enemy|
      if self.collides_with? enemy # todo: why doesn't coldec work?
        enemy.die
        die
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
      shot = Shot.new @x, @y - self.height, -6, EnemyShip
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