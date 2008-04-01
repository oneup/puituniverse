class Level < Gameobject
  def initialize
    @track_x_sheer_factor = -(6*4)
    @track_height = 6*4

    @track_length = 4 # segments
  end

  def draw_x_offset
    # top track offset - how far to the right?
    24*4
  end
  
  def draw_track_y_offset
    # offset to top track inside level graphic
    -(3*4)
  end
  
  def draw_y_offset
    # position of level on screen
    $window.height - tile_height
  end
  
  def tile_width
    # one level tile
    img("level/start").width
  end

  def tile_height
    # one level tile
    img("level/start").height
  end

  def scroll_offset
    0
  end
  
  def draw_offset x, track_no
    # calculate draw offset for a character on a given track
    return track_draw_x_offset(x, track_no), track_draw_y_offset(track_no)
  end
  
  def track_draw_x_offset x, track_no
    draw_x_offset + x + scroll_offset + (track_no*@track_x_sheer_factor)
  end

  def track_draw_y_offset track_no
    draw_y_offset + draw_track_y_offset + (track_no * @track_height)
  end
  
  def update
  end
  
  def draw
    img("level/background").draw(0,0,ZOrder::Background)

    x = 0
    y = draw_y_offset
    img("level/start").draw(x,y,0)

    (0..@track_length).each do
      x += tile_width
      img("level/repeat").draw(x,y,0)
    end

    x += tile_width
    img("level/end").draw(x,y,0)
  end
end

class Character < Gameobject
  attr_reader :x, :track_no, :jump_offset, :is_jumping, :name

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

  def update
    @x += @velocity
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
    img("./shared/#{name}/#{action}").draw(x, y + @jump_offset, ZOrder::Tracks + @track_no)
  end
end

class Player < Character
  def update
    super
  end
  
  def on_button down, id
    if id == Gosu::Button::KbRight
      if down
        @velocity = 1
      else
        @velocity = 0
      end
    end
  end
end

class CpuPlayer < Character
  def update
    super
    @velocity = 0.5
  end
end
