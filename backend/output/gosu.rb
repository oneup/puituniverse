#thx http://code.google.com/p/gosu/wiki/RubyReference

require 'gosu'

class Window < Gosu::Window
  @@fullscreen = false

  def self.resolution r
    @@resolution = r
  end
  
  def self.fullscreen= f
    @@fullscreen = f
  end

  def initialize
    super(@@resolution[0], @@resolution[1], @@fullscreen) # from Game
    $window = self
  end

  def update # overwritten by game
  end

  def draw # overwritten by game
  end

  def button_down id
    on_button map_button(id)
  end

  def map_button id
    id # todo map from Gosu::Button to Button
  end
end


class Image < Gosu::Image
  def initialize file_name
    raise "Image #{file_name} not found!" unless file_name.is_file?
    super($window, file_name, true)
  end
  
  def draw(x=0,y=0,z=0,zoom_x=1,zoom_y=1)
    z ||= 0
    zoom_x ||= 1
    zoom_y ||= 1

    args = []
    if args.size > 0
      params = args.first
      if params.is_symbol?
        params = {params => nil}
      end
      if params[:z]
        z = params[:z]
      end
      if params[:zoom]
        zoom_x = params[:zoom]
        zoom_y = zoom_x
      end
      if params[:mirror_horizontal]
        zoom_x = -1
        x = x + width
      end
      zoom_x = params[:zoom_x] if params[:zoom_x]
      zoom_y = params[:zoom_y] if params[:zoom_y]
    end
 
    super(x,y,z,zoom_x,zoom_y)
  end
end

class Font < Gosu::Font
  def initialize filename, size
    super($window, filename, size)
    
    # hacketyhack: gosu font loading doesn't throw an error if it failed, so we do
    text_width("test") rescue raise "Unable to load font #{filename}"
  end
  
  def draw(text, x,y,z=0)
    super(text,x,y,z)
  end
end