class String
  def yml
    YAML::load_file "#{self}.yml" rescue nil # don't cache. because this can be used in funky ways (i think). speak: duplicate data structures. or something like that. bla bla bla
  end
  
  def ttf size=12
    ttf = "#{self}.ttf"
    return Font.cache(ttf, size) if ttf.is_file? # "root/font/Busk.ttf"
    Font.cache(self, size) # "Helvetica"
  end
  
  def is_file?
    File.file? self
  end
  
  def is_yml?
    "#{self}.yml".is_file?
  end
  
  def img
    return Animation.cache(self) if self.is_yml?
    return self.png
  end
  
  def png
    return Image.cache("#{self}.png")
  end
end

class Object
  @@cache = {}
  
  def self.cache identifier, *arguments
    cache_hash = identifier + arguments.to_s # hacketyhack: let's hope arguments.to_s works
    @@cache[cache_hash] ||= self.new(identifier, *arguments)
  end
end

class Animation
  def initialize file_name
    @yml = file_name.yml
    @frames = []
    
    @yml['frames'].each do |frame|
      @frames << [frame['duration'] || 3, Image.cache(frame['image'])]
    end
  rescue
    raise "error while loading animation config #{file_name}"
  end
  
  def draw x, y, order
    @frames[Gosu::milliseconds / 100 % @frames.size][1].draw(x,y,order)
  end
end

class Image < Gosu::Image
  def initialize file_name
    raise "Image #{file_name} not found!" unless file_name.is_file?
    super($window, file_name, true)
  end
end

class Font < Gosu::Font
  def initialize filename, size
    super($window, filename, size)
    
    # hacketyhack: gosu font loading doesn't throw an error if it failed, so we do
    text_width("test") rescue raise "Unable to load font #{filename}"
  end
end