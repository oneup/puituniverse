class Boundingbox(object):
  """TODO: Write documentation, following explanation in release-notes.txt.
  """
  def __init__(self, bottom_left=(0, 0), size=None, width=None, height=None,
      gameobject=None, treenode=None):
    self._pos = bottom_left
    if (type(size) is tuple) and len(size) == 2:
      self._size = size
    elif type(size) is not NoneType:
      try:
        w = size[0]
        h = size[1]
      except IndexError:
        # TODO: we have to implement PuitExceptions and get rid of these
        # oldskool ad-hoc exceptions.
        raise "must pass 2-tuple or something equivalent for size!"
      self._size = (w, h)
    else:
      if (width is None) or (height is None):
        # TODO: see comment above
        raise "must specify width and height of bounding box!"
      self._size = (width, height)
    self._gameobject = gameobject
    self._treenode = treenode
  
  def move(self, delta):
    self._pos = addVertices(self._pos, delta)
    self._movement_notification()
  
  def intersects(self, other):
    #return not (other.left >= self.right
    #    or other.right <= self.left
    #    or other.bottom >= self.top
    #    or other.top <= self.bottom
    #  )
    return not (
        other._pos[0] >= self._pos[0] + self._size[0]
        or self._pos[0] >= other._pos[0] + other._size[0]
        or other._pos[1] >= self._pos[1] + self._size[1]
        or self._pos[1] >= other._pos[1] + other._size[1]
      )
  
  def contains(self, other):
    #return (self.left <= other.left
    #    and self.right >= other.right
    #    and self.bottom <= other.bottom
    #    and self.top >= other.top)
    return (
        self._pos[0] <= other._pos[0]
        and self._pos[0] + self._size[0] >= other._pos[0] + other._size[0]
        and self._pos[1] <= other._pos[1]
        and self._pos[1] + self._size[1] >= other._pos[1] + other._size[1]
      )
  
  def contains_point(self, pos):
    return (
        self._pos[0] <= pos[0]
        and self._pos[0] + self._size[0] > pos[0]
        and self._pos[1] <= pos[1]
        and self._pos[1] + self._size[1] > pos[1]
      )
  
  def enclose(self, others):
    """transform this box so it minimally encloses others.
    
    others is an iterable that must contain one or more Boundingboxes.
    """
    h = others[0]
    left, bottom = h._pos
    right = left + h._size[0]
    top = bottom + h._size[1]
    for o in others[1:]:
      left = min(o._pos[0], left)
      bottom = min(o._pos[1], bottom)
      right = max(o._pos[0] + o._size[0], right)
      top = max(o._pos[1] + o._size[1], top)
    self._pos = (left, bottom)
    self._size = (right - left, top - bottom)
  
  def set_tree_node(self, node):
    self._treenode = node
  
  def _movement_notification(self):
    if self._treenode is not None:
      self._treenode.notify_moved(self._gameobject, self)
  
 ## there's a lot of redundancy in the following functions, but in order   ##
 ## to make this class useful, it's important to offer all of these        ##
 ## properties without too much computational overhead.                    ##
  
  def _get_size(self):
    return self._size
  
  def _set_size(self, size):
    self._size = size
    self._movement_notification()
  
  def _get_width(self):
    return self._size[0]
  
  def _set_width(self, width):
    self._size = (width, self._size[1])
    self._movement_notification()
  
  def _get_height(self):
    return self._size[1]
  
  def _set_height(self, height):
    self._size = (self._size[0], height)
    self._movement_notification()
  
  def _get_center(self):
    return (self._pos[0] + (self._size[0] / 2.0),
        self._pos[1] + (self._size[1] / 2.0))
  
  def _set_center(self, center):
    self._move_delta(self._get_center(), center)
  
  def _get_bottom_left(self):
    return self._pos
  
  def _set_bottom_left(self, point):
    self._pos = point
    self._movement_notification()
  
  def _get_bottom_right(self):
    return (self._pos[0] + self._size[0], self._pos[1])
  
  def _set_bottom_right(self, bottom_right):
    self._move_delta(self._get_bottom_right(), bottom_right)
  
  def _get_top_left(self):
    return (self._pos[0], self._pos[1] + self._size[1])
  
  def _set_top_left(self, top_left):
    self._move_delta(self._get_top_left(), top_left)
  
  def _get_top_right(self):
    return (self._pos[0] + self._size[0], self._pos[1] + self._size[1])
  
  def _set_top_right(self, top_right):
    self._move_delta(self._get_top_right(), top_right)
  
  def _get_mid_left(self):
    return (self._pos[0], self._get_center_y())
  
  def _set_mid_left(self, mid_left):
    self._move_delta(self._get_mid_left(), mid_left)

  def _get_mid_right(self):
    return (self._pos[0] + self._size[0], self._get_center_y())
  
  def _set_mid_right(self, mid_right):
    self._move_delta(self._get_mid_right(), mid_right)

  def _get_mid_top(self):
    return (self._get_center_x(), self._pos[1] + self._size[1])
  
  def _set_mid_top(self, mid_top):
    self._move_delta(self._get_mid_top(), mid_top)

  def _get_mid_bottom(self):
    return (self._get_center_x(), self._pos[1])
  
  def _set_mid_bottom(self, mid_bottom):
    self._move_delta(self._get_mid_bottom(), mid_bottom)
  
  def _get_left(self):
    return self._pos[0]
  
  def _set_left(self, left):
    self._move_delta_x(self._pos[0], left)
  
  def _get_right(self):
    return self._pos[0] + self._size[0]
  
  def _set_right(self, right):
    self._move_delta_x(self._pos[0] + self._size[0], right)
  
  def _get_top(self):
    return self._pos[1] + self._size[1]
  
  def _set_top(self, top):
    self._move_delta_y(self._pos[1] + self._size[1], top)
  
  def _get_bottom(self):
    return self._pos[1]
  
  def _set_bottom(self, bottom):
    self._move_delta_y(self._pos[1], bottom)
  
  def _get_center_x(self):
    return self._pos[0] + (self._size[0] / 2.0)
  
  def _set_center_x(self, center_x):
    self._move_delta_x(self._get_center_x(), center_x)
  
  def _get_center_y(self):
    return self._pos[1] + (self._size[1] / 2.0)

  def _set_center_y(self, center_y):
    self._move_delta_y(self._get_center_y(), center_y)
  
  def _move_delta(self, old_point, new_point):
    """apply the translation old_point -> new_point to self.
    """
    delta_x = new_point[0] - old_point[0]
    delta_y = new_point[1] - old_point[1]
    self._pos = addVertices(self._pos, (delta_x, delta_y))
    self._movement_notification()
  
  def _move_delta_x(self, old_x, new_x):
    """like _move_delta, but for the x axis only
    """
    delta = new_x - old_x
    self._pos = addVertices(self._pos, (delta, 0))
    self._movement_notification()
  
  def _move_delta_y(self, old_y, new_y):
    """like _move_delta, but for the y axis only
    """
    delta = new_y - old_y
    self._pos = addVertices(self._pos, (0, delta))
    self._movement_notification()
  
  size = property(_get_size, _set_size)
  width = property(_get_width, _set_width)
  height = property(_get_height, _set_height)
  center = property(_get_center, _set_center)
  bottom_left = property(_get_bottom_left, _set_bottom_left)
  bottom_right = property(_get_bottom_right, _set_bottom_right)
  top_left = property(_get_top_left, _set_top_left)
  top_right = property(_get_top_right, _set_top_right)
  mid_left = property(_get_mid_left, _set_mid_left)
  mid_right = property(_get_mid_right, _set_mid_right)
  mid_top = property(_get_mid_top, _set_mid_top)
  mid_bottom = property(_get_mid_bottom, _set_mid_bottom)
  left = property(_get_left, _set_left)
  right = property(_get_right, _set_right)
  top = property(_get_top, _set_top)
  bottom = property(_get_bottom, _set_bottom)
  center_x = property(_get_center_x, _set_center_x)
  center_y = property(_get_center_y, _set_center_y)
  
  # TODO: top and bottom are wrong /: ??? (when drawing at x, y - because that's the bottom left corner)
  
  """
  def top(self):
    return self.y + 0
    
  def set_top(self, top):
    self.y = top
  
  def bottom(self):
    return self.y - self.height
    
  def set_bottom(self, bottom):
    self.y = bottom - self.height
  
  def left(self):
    return self.x + 0
  
  def set_left(self, x):
    self.x = x
  
  def right(self):
    return self.x + self.width
  
  def set_right(self, right):
    self.x = right - self.width
    
  def center(self):
    return [self.x + (self.width/2), self.y + (self.height/2)]
  
  def wrong_center(self):
    # FIXME: players are drawn at x,y instead of x, bottom - thus we need this wrong function
    return [self.x + (self.width/2), self.y - (self.height/2)]

  def top_left(self):
    p = [self.x+0, self.y+0] #TODO: do we return copies with/out +0 ?
    return p
  
  def top_right(self):
    p = [self.x+self.width, self.y+0]
    return p

  def bottom_middle(self, new_bottom_middle=None):
    if new_bottom_middle:
      self.x = new_bottom_middle[0] - self.width/2
      self.y = new_bottom_middle[1] + self.height

    p = [self.x + self.width/2, self.y - self.height]
    return p

  def intersects(self, other):
    return not ( other.left() > self.right()
        or other.right() < self.left()
        or other.top() < self.bottom()
        or other.bottom() > self.top()
        )
  """
  
  def __str__(self):
    return '<Boundingbox x=%s y=%s w=%s h=%s>' % (self._pos[0], self._pos[1], self.width, self.height)
  
  def __repr__(self):
    return 'Boundingbox(bottom_left=' + repr(self._pos) + ', size=' \
        + repr(self._size) + ')'
  
  def __nonzero__(self):
    return (self._pos[0] != 0
        or self._pos[1] != 0
        or self._size[0] != 0
        or self._size[1] != 0)
  
  def __lt__(self, other):
    return NotImplemented
  
  def __le__(self, other):
    return NotImplemented
  
  def __gt__(self, other):
    return NotImplemented
  
  def __ge__(self, other):
    return NotImplemented
  
  def __eq__(self, other):
    if not isinstance(other, Boundingbox):
      return False
    return (self.bottom_left == other.bottom_left
        ) and (self.size == other.size)
  
  def __ne__(self, other):
    return not self.__eq__(other)


# // class Boundingbox

def addVertices(v1, v2):
  return (v1[0] + v2[0], v1[1] + v2[1])

if __name__ == '__main__':
  import unittest
  
  class TestBoundingbox(unittest.TestCase):
    def setUp(self):
      self.b1 = Boundingbox(bottom_left=(0, 0), size=(10, 5))
      self.b2 = Boundingbox(bottom_left=(-20, 13), size=(4, 12))
    
    def test_instantiation(self):
      b = Boundingbox(size=(10, 5))
      self.assertEqual(type(b), Boundingbox)
      self.assertEqual(b, self.b1)
    
    def test_move(self):
      self.b1.move((3, 3))
      b = Boundingbox(bottom_left=(3, 3), size=(10, 5))
      self.assertEqual(b, self.b1)
    
    def test_scalar_properties(self):
      self.assertEqual(self.b1.left + self.b1.right + self.b1.bottom
          + self.b1.top + self.b1.center_x + self.b1.center_y + self.b1.width
          + self.b1.height, 37)
      self.b1.bottom = 10
      self.assertEqual(self.b1.left + self.b1.right + self.b1.bottom
          + self.b1.top + self.b1.center_x + self.b1.center_y + self.b1.width
          + self.b1.height, 67)
      self.b1.width = 2
      self.assertEqual(self.b1.left + self.b1.right + self.b1.bottom
          + self.b1.top + self.b1.center_x + self.b1.center_y + self.b1.width
          + self.b1.height, 47)
      self.b1.left = -13
      self.assertEqual(self.b1.right, -11)
      b = Boundingbox(bottom_left=(0, 0), size=(4, 4))
      self.assertEqual(b.right, 4)
    
    def test_tuple_properties(self):
      sum = (0, 0)
      sum = addVertices(sum, self.b1.center)
      self.assertEqual(sum, (5, 2))
      sum = addVertices(sum, self.b1.mid_top)
      sum = addVertices(sum, self.b1.mid_right)
      self.assertEqual(sum, (20, 9))
      sum = addVertices(sum, self.b1.mid_left)
      sum = addVertices(sum, self.b1.mid_bottom)
      sum = addVertices(sum, self.b1.top_left)
      sum = addVertices(sum, self.b1.top_right)
      self.assertEqual(sum, (35, 21))
      sum = addVertices(sum, self.b1.bottom_left)
      sum = addVertices(sum, self.b1.bottom_right)
      self.assertEqual(sum, (45, 21))
      self.b1.center = (-6, 7)
      self.b1.size = (20, 5)
      sum = (0, 0)
      sum = addVertices(sum, self.b1.center)
      sum = addVertices(sum, self.b1.mid_top)
      sum = addVertices(sum, self.b1.mid_right)
      sum = addVertices(sum, self.b1.mid_left)
      sum = addVertices(sum, self.b1.mid_bottom)
      sum = addVertices(sum, self.b1.top_left)
      sum = addVertices(sum, self.b1.top_right)
      sum = addVertices(sum, self.b1.bottom_left)
      sum = addVertices(sum, self.b1.bottom_right)
      self.assertEqual(sum, (-9, 66))
      self.b1.width = 10
      self.b1.height = 10
      self.b1.bottom_right = (10, 0)
      self.b1.top_left = (0, 10)
      self.assertEqual(self.b1.top_right, (10, 10))
      self.b1.mid_top = (10, 10)
      self.assertEqual(self.b1.mid_bottom, (10, 0))
    
    def test_intersection(self):
      self.failIf(self.b1.intersects(self.b2))
      self.failIf(self.b2.intersects(self.b1))
      self.b2.move((16, -8))
      self.failIf(self.b1.intersects(self.b2))
      self.failIf(self.b2.intersects(self.b1))
      self.b2.move((1, 0))
      self.failIf(self.b1.intersects(self.b2))
      self.failIf(self.b2.intersects(self.b1))
      self.b2.move((0, -1))
      self.assert_(self.b1.intersects(self.b2))
      self.assert_(self.b2.intersects(self.b1))
      self.b1.move((1, 0))
      self.failIf(self.b1.intersects(self.b2))
      self.failIf(self.b2.intersects(self.b1))
      b = Boundingbox(bottom_left=(3, 3), size=(5, 5))
      self.assert_(self.b1.intersects(b))
      self.assert_(b.intersects(self.b1))
      b.height = 2
      self.assert_(self.b1.intersects(b))
      self.assert_(b.intersects(self.b1))
      self.b1.size = (1, 1)
      self.failIf(self.b1.intersects(b))
      self.failIf(b.intersects(self.b1))
      
  
  test_suite = unittest.TestLoader().loadTestsFromTestCase(TestBoundingbox)
  print "testing class Boundingbox ...\n"
  unittest.TextTestRunner(verbosity=2).run(test_suite)