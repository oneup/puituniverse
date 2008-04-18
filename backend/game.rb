class Object
  attr_accessor :x, :y, :width, :height
  
  def left() x; end
  def right() x+width; end
  def top() y; end
  def bottom() y+height; end

  def outside? object
    not object.contains?(self)
  end
  
  def set_boundingbox x,y,w,h
    @x, @y, @width, @height = x, y, w, h
  end
  
  def contains? other
     return( (self.left <= other.left) and
          (self.right >= other.right) and
         (self.bottom <= other.bottom) and
         (self.top >= other.top))
  end
end

# todo: refactor me
class Game < Window
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
