class ActiveGame < Gosu::Window
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