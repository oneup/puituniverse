# http://en.wikipedia.org/wiki/Shufflepuck_Cafe
# thx http://youtube.com/watch?v=9pUmfxM9h54

class ShufflepuitCafeGame < Game
  def setup
    @objects << Ball.new
  end

  def draw
    super
    "puit/jack/stand".img.draw(mouse_x,mouse_y, 
                                0, # z order
                                1+(mouse_y/height)*2, 1+(mouse_y/height)*2) # zoom
  end
end

class Ball < Gameobject
  def initialize
    @x = 0
    @y = 0
    @velocity_x = 10
    @velocity_y = 10
  end
  
  def update
    @x += @velocity_x
    @y += @velocity_y
    @velocity_x = -@velocity_x if @x > $game.width or @x < 0
    @velocity_y = -@velocity_y if @y > $game.height or @y < 0
  end
  
  def draw
    "puit/jack/run".img.draw(@x, @y, 0, 1+(@y.to_f/$game.height)*2, 1+(@y.to_f/$game.height)*2)
  end
end