# todo: refactor me
class Game < Window
  attr_reader :objects

  include Collideable
  resolution [320, 240]
  
  def self.run
    self.new.show
  end
  
  def initialize
    super
    set_boundingbox(0,0,self.width,self.height)
    $game = self
    @objects = []
    setup
  end
  
  def all type # optimize? or: needed?
    @objects.map { |object| object if object.is_a?(type) }.compact
  end

  def setup
    #overwrite me
  end

  def update
    @objects.reject! do |o|
      o.update
      o.is_dead?
    end
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
