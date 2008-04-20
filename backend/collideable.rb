module Collideable
  attr_accessor :x, :y
  
  def left() x.to_f; end
  def right() x.to_f + width.to_f; end
  def top() y.to_f; end
  def bottom() y.to_f + height.to_f; end
  
  def top= value
    y = value
  end

  def bottom= value
    y = value - height
  end
  
  def left= value
    x = value
  end
  
  def right= value
    x = value - width
  end

  def outside? object
    not object.contains?(self)
  end
  
  def set_boundingbox x,y,w,h
    @x, @y, @width, @height = x, y, w, h
  end
  
  def contains? other
    (self.left <= other.left) and
    (self.right >= other.right) and
    (self.bottom <= other.bottom) and
    (self.top >= other.top)
  end
  
  def collides_with? other
    not (
      (other.left > self.right) or
      (other.right < self.left) or
      (other.bottom < self.top) or
      (other.top > self.bottom)
      )
  end
end