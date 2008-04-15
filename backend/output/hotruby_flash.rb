require 'what'

class Window < LOLWH
  @@fullscreen = false

  def self.resolution r
    @@resolution = r
  end
  
  def self.fullscreen= f
    @@fullscreen = f
  end

  def initialize
    super
    # do something
  end
end

class Image < Gosu::Image
  def initialize file_name
  end
end

class Font < Gosu::Font
  def initialize filename, size
  end
end