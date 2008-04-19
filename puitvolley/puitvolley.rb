# entry for LD11

class Puitvolley < Game
  def setup
    @objects << VolleyballPlayer.left
    @objects << VolleyballPlayer.right
#    @objects << Ball.new
#    @objects << Wall.new
  end
end

class VolleyballPlayer < Gameobject
  attr_accessor :score
  @@speed = 5
  attr_accessor :score
  
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
    @lives = 3
    
    if side == :right
      set_keys(Gosu::Button::KbLeft   => :move_left,
              Gosu::Button::KbRight  => :move_right,
              Gosu::Button::GpLeft   => :move_left,
              Gosu::Button::GpRight  => :move_right,
              Gosu::Button::KbUp  => :jump,
              Gosu::Button::GpUp  => :jump)
    else
      #todo: set_keys CpuController irgendwie bla bla
    end
  end
  
  def gravity
    -0.25
  end
  
  def bottom_border
    $game.height - sprite.height - 10
  end
  
  def update
    @x += @vel_x
    @y += @vel_y
    
    @vel_y -= gravity
    
    if @y > bottom_border
      @y = bottom_border
      @vel_y = 0
    end
    
    @x = (0..$game.width-sprite.height).limit @x
    @y = (0..$game.height-sprite.height).limit @y
  end
  
  def draw
    super
    font.draw("#{@score} points   #{@lives} lives", 10, 10, 0)
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
  
  def die
    @lives -= 1

    if @lives == 0
      super
      $game.exit("Player died")
    end
  end
end