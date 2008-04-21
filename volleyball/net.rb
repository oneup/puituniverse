
class VolleyballNet < Gameobject
  def initialize
    set_sprite "volleyball/net"
    @x, @y = ($game.width-sprite.width)/2, $game.ground - sprite.height
  end
  
  def height
    $game.height
  end
  
  def update
    super
    $game.all(VolleyballBall).each do |ball|
      ball.bounce_x if ball.collides_with? self
    end
    
    $game.all(VolleyballPlayer).each do |player|
      next unless player.collides_with? self
      player.vel_x = 0
      if player.left_of? self
        player.right = self.left - 1
      else
        player.left = self.right + 1
      end
    end
  end
end