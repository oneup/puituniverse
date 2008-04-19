# a super mega massive awesome space invaders clone LOL !!!!111eleven
# cc oneup
# thx kingpepe

class Spaceinvaders < Game
  attr_accessor :player

  def setup
    @player = PlayerShip.new
    @objects << @player

    row = 0
    EnemyShip.rows.times do |row|
      x = 10 # fixme: calculate from EnemyShip.rows
      EnemyShip.cols.times do
        enemy = EnemyShip.new(x, row)
        @objects << enemy
        x += (enemy.width + 10)
      end
      row += 1
    end
  end
end

# now: other ships :)
class EnemyShip < Gameobject
#  set :rows, 6
#  set :cols, 24
  
  def self.rows
    6
  end
  
  def self.cols
    $game.width / ("spaceinvaders/Space Invader1".img.width+10)
  end
  
  def points
    (1 + EnemyShip.rows - @row) * 10
  end
  
  def initialize x, row
    set_sprite "spaceinvaders/Space Invader#{row+1}"

    @row = row
    @velocity = 0.2
    @x, @y = x, 10 + (@row+1)*(sprite.height+10)
  end
  
  def change_direction_and_go_to_next_row
    @velocity = -@velocity
    @velocity *= 1.2
    @y += sprite.height + 10
  end
  
  def update
    @x += @velocity

    if right > $game.width or left < 0 # one space invader touched the right or left border!!!
      for ship in $game.all(EnemyShip)
        ship.change_direction_and_go_to_next_row
      end
    end
    
    # kill player?
    if $game.player.collides_with? self
      $game.player.die
    end
    
    # shoot
    if probability(0.0005)
      shot = Shot.new @x, @y+sprite.height, +4, PlayerShip
      $game.objects << shot
    end
  end
  
  def die
    $game.player.score += self.points
    super
    
    $game.exit("Player won") if $game.count(EnemyShip) == 0
  end
end

class Shot < Gameobject
  def initialize x, y, vel_y, target
    @x, @y, @vel_y = x, y, vel_y
    @target = target
    set_sprite "spaceinvaders/Shot1"
  end
  
  # todo: build a class that automatically adds accessors for everything. @owner suxx0rs
  
  def update
    @y += @vel_y

    $game.all(@target).each do |object|
      if self.collides_with? object
        object.die
        die
      end
    end
  end
end

class PlayerShip < Gameobject
  def score
    @score || 0
  end
  
  def set_score value
    @score = value
  end

  @@speed = 5
  attr_accessor :score

  def initialize
    set_sprite("spaceinvaders/Shooter")

    @x = 0
    @y = $game.height - sprite.height - 10 # 10 pixels free to bottom
    @vel_x = 0
    @vel_y = 0
    
    @score = 0
    


    map_keys(Gosu::Button::KbLeft   => :move_left,
             Gosu::Button::KbRight  => :move_right,
             Gosu::Button::GpLeft   => :move_left,
             Gosu::Button::GpRight  => :move_right,
             Gosu::Button::KbSpace  => :shoot)
  end
  
  def update
    @x += @vel_x
    @y += @vel_y
    @x = (0..$game.width).limit @x
    @y = (0..$game.height).limit @y
  end
  
  def draw
    super
    "puit/font/Busk_3x3pixel_fin".ttf.draw("#{@score} points",10, 10, 0)
  end
  
  def shoot pressed
    if pressed
      shot = Shot.new @x, @y - self.height, -6, EnemyShip
      $game.objects << shot
    end
  end
  
  def move_left pressed
    @vel_x = -@@speed if pressed
    @vel_x = 0 if not pressed and not is_pressed? :move_right
  end
  
  def move_right pressed
    @vel_x = @@speed if pressed
    @vel_x = 0 if not pressed and not is_pressed? :move_left
  end
  
  def die
    super
    $game.exit("Player died")
  end
end