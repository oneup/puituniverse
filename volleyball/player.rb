
class VolleyballPlayer < VolleyballGameobject
  attr_accessor :score, :side
  @@speed = 5
  
  def self.left
    self.new :left
  end
  
  def self.right
    self.new :right
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
    
    if side == :right
      set_keys(Gosu::Button::KbLeft  => :move_left,
              Gosu::Button::KbRight  => :move_right,
              Gosu::Button::GpLeft   => :move_left,
              Gosu::Button::GpRight  => :move_right,
              Gosu::Button::KbUp     => :jump,
              Gosu::Button::GpUp     => :jump)
    else
      set_keys(Gosu::Button::KbLeftControl  => :move_left,
              Gosu::Button::KbLeftAlt       => :move_right,
              Gosu::Button::KbLeftShift     => :jump)
    end
  end
  
  def touch_ground
    super
    @vel_y = 0
  end

  def draw
    super
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
    -7
  end
  
  def acceleration
    2
  end
  
  def max_speed
    6
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
    elsif is_pressed? :move_right
      @vel_x = 1 if @vel_x <= 0
      @vel_x += acceleration
    end
    
    @vel_x = (-max_speed..max_speed).limit @vel_x
  end
  
  def move_right pressed
  end
  
  def move_left pressed
  end
end