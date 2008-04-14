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

class Object
  @@cache = {}
  
  def self.cache identifier, *arguments
    cache_hash = identifier + arguments.to_s # hacketyhack: let's hope arguments.to_s works
    @@cache[cache_hash] ||= self.new(identifier, *arguments)
  end
end