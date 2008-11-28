require "yaml"
#require "jabber"

# http://en.wikipedia.org/wiki/Shufflepuck_Cafe
# thx http://youtube.com/watch?v=9pUmfxM9h54

class Mm9 < Game
  fullscreen false

  def setup
    $player = Player.new
    @objects << $player
    @objects << Level.new
  end

  def draw
    super
  end
end

class Level < Gameobject
  attr_accessor :width, :height, :x, :y

  def initialize
    @x = 0
    @y = 0

    @tiles = [[0,0,0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0,0,0],
              [1,1,1,1,1,1,1,1,1]]

    @width = @tiles[0].count * tile_size
    @height = @tiles.count * tile_size
  end
  
  def tile_size
    16
  end
  
  def draw
    x = @x
    y = @y
    @tiles.each do |row|
      x = 0
      row.each do |col|
        "mm9/tiles/#{col}".img.draw(x,y) unless col == 0
        x += tile_size
      end
      y += tile_size
    end
  end  
  
  def update
    object = $player
    if object.collides_with? self
      player_tile_x = ((object.bottom - @x)/tile_size).ceil
      player_tile_y = ((object.top - @y)/tile_size).ceil
      
      puts player_tile_x
      puts player_tile_y
      
      if @tiles[player_tile_y][player_tile_x] != 0
        # collision with level!
        object.bottom = (player_tile_y) * tile_size
        object.touch_level
      end
    end
  end
end

class Player < Gameobject
  attr_accessor :width, :height, :x, :y
  
  def touch_level
    @velocity_y = 0
  end

  def initialize
    @x = 0
    @y = 0
    @width = 24
    @height = 24
    @velocity_x = 0
    @velocity_y = 0
    @speed = 4
    
    set_keys(Gosu::Button::KbRight => :run_right,
             Gosu::Button::KbLeft => :run_left)
  end
  
  def gravity
    2
  end
  
  def run_right(down)
    if down
      @velocity_x = @speed
    else
      @velocity_x = 0
    end
  end
  
  def run_left(down)
    if down
      @velocity_x = -@speed
    else
      @velocity_x = 0
    end
  end
  
  def update
    @x += @velocity_x
    @y += @velocity_y
    
    @velocity_y += gravity
  end
  
  def draw
    if @velocity_x > 0
      "mm9/blue/run".anim(24,24).draw(@x, @y)
    else
      "mm9/blue/stand".anim(24,24,50).draw(@x, @y)
    end
  end
end