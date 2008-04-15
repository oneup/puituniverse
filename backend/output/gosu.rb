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
    self.caption = "Puit #{$game_name}"
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
end

class Font < Gosu::Font
  def initialize filename, size
    super($window, filename, size)
    
    # hacketyhack: gosu font loading doesn't throw an error if it failed, so we do
    text_width("test") rescue raise "Unable to load font #{filename}"
  end
end