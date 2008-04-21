
class VolleyballPlayer < VolleyballGameobject
  attr_accessor :score, :side
  @@speed = 5
  
  def self.left
    self.new :left
  end
  
  def self.right
    self.new :right
  end
  
  def controller side
    {:right => {"left".key       => :move_left,
                "right".key      => :move_right,
                "left".gamepad   => :move_left,
                "right".gamepad  => :move_right,
                "up".key         => :jump,
                "up".gamepad     => :jump},

      :left => {"a".key      => :move_left,
                "d".key      => :move_right,
                "w".key      => :jump}
    }[side]
  end
            
  def initialize side
    set_sprite("puit/jack/stand")

    @side = side
    if side == :left
      @x = 10
    else
      @x = $game.width - sprite.width - 1.px
    end

    @y = bottom_border
    @vel_x = 0
    @vel_y = 0
    
    @score = 0
    
    set_keys controller(side)
  end
  
  def is_facing_left
    @facing_left = true
  end
  
  def is_facing_right
    @facing_left = false
  end
  
  def is_facing_left?
    return @facing_left
  end
  def touch_ground
    super
    @vel_y = 0
  end

  def draw
    if is_facing_left?
      sprite.draw(@x+width,@y, 0, -1)
    else
      sprite.draw(@x,@y)
    end
    x = @side == :left ? 10 : $game.width - 150
    font.draw("#{@score} points", x, 10, 0)
  end
  
  def font
    "puit/font/Busk_3x3pixel_fin".ttf
  end
    
  def jump pressed
    if pressed
      @jump_count = 2 if not in_air?
      
      if @jump_count > 0
        if in_air?
          @vel_y += jump_velocity # add to jump speed to doublejump higher
        else
          @vel_y = jump_velocity # jump up
        end
        @jump_count -= 1
      end
    end
  end
  
  def jump_velocity
    -6
  end
  
  def acceleration
    2.5
  end
  
  def max_speed
    5
  end
  
  def friction
    acceleration/2
  end
  
  def update
    super
    
    if is_moving?
      if @vel_x > 0
        @vel_x -= friction
        @vel_x = 0 if @vel_x < 0
      else
        @vel_x += friction
        @vel_x = 0 if @vel_x > 0
      end
    end
    
    if is_pressed? :move_left and is_pressed? :move_right
      # do nothing lol
    elsif is_pressed? :move_left
      @vel_x = -1 if @vel_x >= 0
      @vel_x -= acceleration
      is_facing_left
    elsif is_pressed? :move_right
      @vel_x = 1 if @vel_x <= 0
      @vel_x += acceleration
      is_facing_right
    end
    
    @vel_x = (-max_speed..max_speed).limit @vel_x
  end
  
  def move_right pressed
  end
  
  def move_left pressed
  end
end