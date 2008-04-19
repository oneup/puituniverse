module Z
  Background = 0
  Tracks = 1
  GUI = 10
end


class Olympics < Game
  resolution [160*4, 100*4]

  def setup
    @objects = []

    $level = Level.new
    @objects << $level
    @objects << CpuPlayer.new("jack", 0)
    @objects << CpuPlayer.new("jack", 1)
    @objects << CpuPlayer.new("jack", 2)
    @player = Player.new "jack", 3
    @objects << @player
  end

  def update
    @objects.each {|o| o.update }
  end

  def draw
    @objects.each {|o| o.draw }
    
    "puit/font/Busk_3x3pixel_fin".ttf(3*10).draw("you >", @player.x-4*25, 320, Z::GUI)
    #{}"Helvetica".ttf(24).draw("hello", 0,0,0)    
  end
  
  def button_down id
    super
  end
  
  def button_up id
    super
  end
end




class Level < Gameobject
  def initialize
    @track_x_sheer_factor = -(6*4)
    @track_height = 6*4
    @draw_x_offset = 23*4
    @draw_track_y_offset = -(1*4)     # offset to top track inside level graphic

    @track_length = 3 # segments
    @start_tile = "olympics/level/start".img
  end
  
  def draw_y_offset
    # position of level on screen
    $window.height - tile_height
  end
  
  def tile_width
    # one level tile
    @start_tile.width
  end

  def tile_height
    # one level tile
    @start_tile.height
  end

  def scroll_offset
    0
  end
  
  def draw_offset x, track_no
    # calculate draw offset for a character on a given track
    return track_draw_x_offset(x, track_no), track_draw_y_offset(track_no)
  end
  
  def track_draw_x_offset x, track_no
    @draw_x_offset + x + scroll_offset + (track_no*@track_x_sheer_factor)
  end

  def track_draw_y_offset track_no
    draw_y_offset + @draw_track_y_offset + (track_no * @track_height)
  end
  
  def update
  end
  
  def draw
    "olympics/level/background".img.draw(0,0,Z::Background)

    x = 0
    y = draw_y_offset
    @start_tile.draw(x,y, Z::Tracks)

    @repeat_tile ||= "olympics/level/repeat".img
    (0..@track_length).each do
      x += tile_width
      @repeat_tile.draw(x,y, Z::Tracks)
    end

    x += tile_width
    "olympics/level/end".img.draw(x,y, Z::Tracks)
  end
end

class Character < Gameobject
  attr_reader :x, :track_no, :jump_offset, :is_jumping, :name

  def y
    level.track_draw_y_offset track_no
  end
  
  @@run_speed = 3.0
  @@friction = 0.2

  def initialize name, track_no
    @name = name
    @x = 0
    @velocity = 0
    @track_no = track_no
    @is_jumping = false
    @jump_offset = 0
  end

  def jump_offset
    return @jump_offset if is_jumping
    0
  end
  
  def run!
    @velocity += @@run_speed
  end

  def update
    @x += @velocity
    if @velocity != 0
      @velocity -= @@friction
      @velocity = 0 if @velocity < 0
    end
  end
  
  def is_running
    @velocity != 0
  end
  
  def is_jumping
    false
  end
  
  def draw
    action = if is_jumping
      "jump"
    elsif is_running
      "run"
    else
      "stand"
    end
    
    x, y = level.draw_offset(@x, @track_no)
    "puit/#{name}/#{action}".img.draw(x, y + @jump_offset, Z::Tracks + @track_no + 1)
  end
end

class Player < Character
  def initialize a,b
    super a,b
    map_keys(Gosu::Button::KbRight => :press_run)
  end
    
  def press_run pressed
    run! if pressed
  end  
end

class CpuPlayer < Character
  def update
    if probability(0.02) # problemy hack: different fps will generate different speeded players. solution: limit game fps to 60 (NTSC)
      run!
    end
    
    super
  end
end
