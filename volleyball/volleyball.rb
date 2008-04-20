# entry for LD11

class Volleyball < Game
  def setup
    @objects << VolleyballPlayer.left
    @objects << VolleyballPlayer.right
    @objects << VolleyballBall.new
#    @objects << Wall.new
  end
end

class VolleyballGameobject < Gameobject
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
    $game.height - sprite.height - 10
  end
end

class VolleyballBall < VolleyballGameobject
  def initialize
    @x = $game.width/2
    @y = 10
    @vel_x = 5
    @vel_y = 0
    set_sprite "puit/jack/stand"
  end
  
  def bounce_x
    @vel_x *= -1
  end

  def touch_wall side
    super side
    bounce_x
  end
  
  def touch_ground
    super
    @vel_y = @vel_y * (-0.5)
  end
  
  def update
    super

    $game.all(VolleyballPlayer).each do |object|
      if object.collides_with? self
        @vel_y = -10
        bounce_x
        self.bottom = object.top
      end
    end
  end
end

class VolleyballPlayer < VolleyballGameobject
  attr_accessor :score
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
      @x = $game.width - sprite.width - 10
    end

    @y = $game.height - sprite.height - 10 # 10 pixels free to bottom
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
    
  def draw
    super
    x = @side == :left ? 10 : $game.width - 150
    font.draw("#{@score} points", x, 10, 0)
  end
  
  def font
    "puit/font/Busk_3x3pixel_fin".ttf
  end
  
  def jumping?
    @vel_y.to_i == 0
  end

  def jump pressed
    if pressed
      @vel_y = -10
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
end