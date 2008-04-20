
class VolleyballBall < VolleyballGameobject
  def initialize
    @x = $game.width/2
    @y = 5.px
    @vel_x = 5
    @vel_y = 0
    set_sprite "volleyball/ball"
  end
  
  def bounce_x
    @vel_x *= -1
  end

  def touch_wall side
    super side
    bounce_x
    @vel_x = @vel_x * (0.5)
  end
  
  def touch_ground
    super
    @vel_y = @vel_y * (-0.5)
  end

  def draw_move_mirror_factor
    if @vel_x > 0
      +1
    elsif @vel_x < 0
      -1
    else
      0
    end
  end
  def draw_rotation
    speed = @vel_x.abs + @vel_y.abs
    @draw_rotation ||= 0
    @draw_rotation += speed*draw_move_mirror_factor
    if @draw_rotation > 360
      @draw_rotation = 0
    end
    @draw_rotation
  end

  def draw
    sprite.draw_rot(@x,@y,0,draw_rotation)
  end
  
  def update
    super

    $game.all(VolleyballPlayer).each do |player|
      if player.collides_with? self
        @vel_y = -10
        if player.is_moving?
          @vel_x += player.vel_x
        else
          @vel_x = @vel_x * 0.5
        end
        self.bottom = player.top
      end
    end
  end
end