# a super mega massive awesome space invaders clone LOL !!!!111eleven
# cc oneup
# thx kingpepe

class SpaceinvadersGame < Game
  def setup
    @objects << PlayerShip.new
  end
end

class PlayerShip < Gameobject
  def initialize
    @x = 0
    @y = 0
    @vel_x = 10
    @vel_y = 10
  end
  
  def update
    #@x += @vel_x
    #@y += @vel_y
    #@x = (0..$game.width).limit @x
    #@y = (0..$game.height).limit @y
    
    @x = $game.mouse_x
    @y = $game.mouse_y
  end
  
  def draw
    "spaceinvaders/ship/enemy".img.draw(@x, @y, 0)
  end
end