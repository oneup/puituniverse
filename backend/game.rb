# todo: refactor me
class Game < Window
  resolution [320, 240]
  
  def initialize
    super
    @objects = []
    setup
  end

  def setup
    #overwrite me
  end

  def update
    @objects.each {|o| o.update }
  end

  def draw
    @objects.each {|o| o.draw }
  end
  
  def button_down id
    close if id == Gosu::Button::KbEscape or id == 12 # "q" => hackety hack remove gosu dependency
    @objects.each {|o| o.on_button_down id }
  end

  def button_up id
    @objects.each {|o| o.on_button_up id }
  end
end
