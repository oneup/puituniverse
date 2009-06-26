# a very basic example

class Example < Game
  fullscreen false

  def setup
    @objects << Player.new
  end
end


class Player < Gameobject
  def draw
    "puit/jack/stand".img.draw(42,42)
  end
end



# HOW TO USE

# Game
#  setup
#  update (game logic goes here)
#  draw (extra drawing code goes here)

# Gameobject
#  pretty much the same