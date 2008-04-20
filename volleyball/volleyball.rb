# entry for LD11

class Image
  alias_method :old_draw, :draw
  def draw(x=0,y=0,z=0)
    old_draw(x,y,z)
  end
end

class Fixnum
  def px
    self*4
  end
end

class Volleyball < Game
  resolution [160*4, 100*4]

  def setup
    @objects << VolleyballPlayer.left
    @objects << VolleyballPlayer.right
    @objects << VolleyballBall.new
    @objects << VolleyballNet.new
  end
  
  def draw
    "volleyball/background".img.draw()
    super
  end
  
  def ground
    $game.height - (7.px)
  end
end

class VolleyballGameobject < Gameobject
  attr_accessor :vel_x, :vel_y

  def gravity
    -0.25
  end
  
  def update
    @x += @vel_x
    @y += @vel_y
    
    @vel_y -= gravity

    touch_wall :left if @x < 0
    touch_wall :right if @x > right_border
    touch_ground if @y > bottom_border
  end
  
  def in_air?
    @y < bottom_border
  end

  def is_moving?
    @vel_x != 0 # shouldn't this be @vel_x != 0 andvel_y != 0
  end

  def touch_wall side
    if side == :left
      @x = 0
    else
      @x = right_border
    end
  end
  
  def touch_ground
    @y = bottom_border
  end
  
  def right_border
    $game.width - sprite.height
  end
  
  def bottom_border
    $game.ground - sprite.height
  end
end
