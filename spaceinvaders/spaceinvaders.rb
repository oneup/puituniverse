# Space Invaders
#   a super mega massive awesome space invaders clone LOL !!!!111eleven
#
#   code (cc) oneup <hello@geeq.at>
#   graphics (cc) kingpepe

require "activesupport"
require "kyoto_reconstruction"

def game
  $game
end

class Spaceinvaders < Game
  attr_accessor :player
  include Collideable
  include Timer
  resolution [640, 480]

  def setup
    $game = self
    
    @x, @y = 0, 0
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
    
    every(2.seconds) do
      row = 0
      x = 10 # fixme: calculate from EnemyShip.rows
      EnemyShip.cols.times do
        enemy = EnemyShip.new(x, row)
        @objects << enemy
        x += (enemy.width + 10)
      end
      row += 1
    end
  end
  
  def font
    "puit/font/Busk_3x3pixel_fin".ttf
  end

  def draw
    super
    font.draw("YOU WON", width-120, 10) if $game.count(EnemyShip) == 0
    font.draw("YOU LOST", width-120, 10) if $game.count(PlayerShip) == 0
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

    $game.all(@target).each do |object|
      if self.collides_with? object
        object.die
        die
      end
    end
    
    die unless $game.collides_with? self
  end
end

class PlayerShip < Gameobject
  attr_accessor :score
  @@speed = 5

  def initialize
    set_sprite("spaceinvaders/Shooter")

    @x = 0
    @y = $game.height - sprite.height - 10 # 10 pixels free to bottom
    @vel_x = 0
    @vel_y = 0
    
    @score = 0
    @lives = 3
    
    set_keys("left".key   => :move_left,
             "left".gamepad => :move_left,
             "right".key   => :move_right,
             "right".gamepad  => :move_right,
             "space".key  => :shoot)
  end
  
  def update
    @x += @vel_x
    @y += @vel_y
    @x = (0..$game.width).limit @x
    @y = (0..$game.height).limit @y
  end
  
  def draw
    super
    font.draw("#{@score} points   #{@lives} lives", 10, 10, 0)
  end
  
  def font
    $game.font
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
    @lives -= 1

    if @lives == 0
      super # really die
    end
  end
end