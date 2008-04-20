
class VolleyballNet < Gameobject
  def initialize
    set_sprite "volleyball/net"
    @x, @y = ($game.width-sprite.width)/2, $game.ground - sprite.height
  end
  
  def update
    super
    $game.all(VolleyballBall).each do |ball|
      ball.bounce_x if ball.collides_with? self
    end
    
    $game.all(VolleyballPlayer).each do |player|
      player.vel_x = 0 if player.collides_with? self
      if player.side == :left
        player.right = self.left - 1
      elsif player.side == :right
        player.left = self.right + 1
      end
    end
  end
end