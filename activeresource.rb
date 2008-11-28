class String
  def validate_existance_of file
    raise "no #{file}" unless file.is_file? or file.is_folder?
  end
  
  alias_method :is_folder?, :is_dir?
  
  def yml
    file = "#{self}.yml"
    validate_existance_of file
    YAML::load_file(file) # rescue nil # don't cache. because this can be used in funky ways (i think). speak: duplicate data structures. or something like that. bla bla bla
  end
  
  def ttf size=12
    ttf = "#{self}.ttf"
    return Font.cache(ttf, size) if ttf.is_file? # "puit/font/Busk.ttf"
    Font.cache(self, size) # "Helvetica"
  end
  
  def is_file?
    File.file? self
  end
  
  def is_yml?
    "#{self}.yml".is_file?
  end
  
  def anim(tile_width, tile_height, duration=1)
    Animation.cache(self, tile_width, tile_height, duration)
  end
  
  def img
    a = Animation.cache(self) if self.is_yml?
    a ||= self.png
    return a
  end
  
  def png
    return Image.cache("#{self}.png")
  end
end

class Animation
  def initialize file_name, tile_width=nil, tile_height=nil, duration=1
    if tile_width # super ugly hack
      @frame_pictures = Gosu::Image::load_tiles($window, file_name+".png", tile_width, tile_height, false)
      @frames = @frame_pictures.map {|f| [duration, f]}
    else
      @yml = file_name.yml
      @frames = []
    
      @yml['frames'].each do |frame|
        @frames << [frame['duration'] || duration, Image.cache(frame['image'])]
      end
    end
#  rescue
#    raise "error while loading animation config #{file_name}"
  end
  
  def draw x, y, order=0, zoom_x=1, zoom_y=1
    current_frame = (Gosu::milliseconds / (100*@frames[0][0]) % @frames.size) # hackish
    @frames[current_frame][1].draw(x, y, order, zoom_x, zoom_y)
  end
end

class Object
  @@cache = {}
  
  def self.cache identifier, *arguments
    cache_hash = identifier + arguments.to_s # hacketyhack: let's hope arguments.to_s works
    @@cache[cache_hash] ||= self.new(identifier, *arguments)
  end
end