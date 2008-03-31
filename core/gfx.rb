class Animation
  def initialize name
    @frames = []

    dir = Dir.new name
    dir.each do |entry|
      next if entry.starts_with? '.'
      file = "#{name}/#{entry}"
      @frames << Resources::load_image(file)
    end
  end
  
  def draw x, y, order
    @frames[Gosu::milliseconds / 100 % @frames.size].draw(x,y,order)
  end
end

class Resources
  def self.init window
    @@window = window
    @@images = {}
    @@gfx = {}
  end

  def self.load_gfx name
    name = resourceify name
    return @@gfx[name] if @@gfx[name]

    #try if it's an animation
    begin
      @@gfx[name] = Animation.new name
    rescue
      return @@gfx[name] = self.load_image("#{name}.png")
    end
  end

  def self.load_image name
    name = resourceify name
    @@images[name] ||= Gosu::Image.new(@@window, name, true)
  end
  
  def self.resourceify name
    if name.starts_with? $config['game_name']
      name
    else
      "#{$config['game_name']}/#{name}" 
    end
  end
end