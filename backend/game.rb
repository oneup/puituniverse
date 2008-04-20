class Exit < Exception
  def initialize reason
    @reason = reason
  end
  
  def to_s
    @reason
  end
end

# todo: refactor me
class Game < Window
  attr_reader :objects

  include Collideable
  resolution [320, 240]
  
  def self.run
    self.new.show
  end
  
  # super needs to implement caption
  
  def initialize
    super
    set_boundingbox(0,0,self.width,self.height)
    self.caption = "Puit #{$game_name.classify}"
    $game = self
    @objects = []
    setup
  end
  
  def all type # optimize? or: needed?
    @objects.map { |object| object if object.is_a?(type) }.compact
  end
  
  def count type
    all(type).size
  end

  def setup
    #overwrite me
  end
  
  def exit reason
    raise Exit.new(reason)
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
    exit("ESC or Q") if id == Gosu::Button::KbEscape or id == 12 # hacketyhack for alt+q (gosu doesn't find this o_O)
    @objects.each {|o| o.button_down id }
  end

  def button_up id
    @objects.each {|o| o.button_up id }
  end
end
