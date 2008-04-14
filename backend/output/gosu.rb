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
    super(@@resolution[0], @@resolution[1], @@fullscreen)
    self.caption = "Puit #{$game_name}"
    $window = self
    setup
  end

  def update
    @objects.each {|o| o.update }
  end

  def draw
    @objects.each {|o| o.draw }
  end

  def button_down id
    close if id == Gosu::Button::KbEscape or id == 12 # "q" => hackety hack
    
    @player.on_button true, id
  end

  def button_up id
    @player.on_button false, id
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