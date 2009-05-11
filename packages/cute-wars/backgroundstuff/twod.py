class Vector2d(object):
  def __init__(self, a, y=None): # a: Vector2d, (x, y) or x
    if y == None:
      if a.__class__ == Vector2d:
        self.x = a.x
        self.y = a.y
      else:
        self.x = a[0]
        self.y = a[1]
    else:
      self.x = a
      self.y = y
    
  def clamp(self, minv, maxv):
    minv = Vector2d(minv)
    maxv = Vector2d(maxv)
    
    if self.x < minv.x:
      self.x = minv.x
    elif self.x > maxv.x:
      self.x = maxv.x
    
    if self.y < minv.y:
      self.y = minv.y
    elif self.y > maxv.y:
      self.y = maxv.y