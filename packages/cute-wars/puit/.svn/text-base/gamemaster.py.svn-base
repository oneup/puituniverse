import os
from puit.state.arcade import Arcade
from puit.state.conquest import Conquest
from puit.state.menu import Menu
from backgroundstuff.mainloop import Mainloop, CameraTarget
from backgroundstuff import pixelfont
from puit.settings import Highscore
import puit
  
class Gamemaster(Mainloop):
  def __init__(self, start_state=None, *args, **kwds):
    super(Gamemaster, self).__init__(*args, **kwds)
    self._camera_targets = []
    self._start_state = start_state
  
  def start(self):
    self.pixelfont = pixelfont.load_font(os.path.join('data', 'font.png'))
    self.pixelfont_grey = pixelfont.load_font(os.path.join('data', 'font.png'), [(255,255,255),(128,128,128)])

    self.highscore = Highscore()
    
    state = None
    if type(self._start_state) is str:
      if self._start_state == 'arcade':
        state = Arcade('test2', testing=True)
      elif self._start_state == 'sidekick':
        state = Arcade('test2', 'help', testing=True)
      elif self._start_state == 'conquest':
        state = Conquest(testing=True)
    if state is None:
      state = Menu()
    self.switch_state(state)
    self.run()
  
  def tick(self, draw=True):
    super(Gamemaster, self).tick(draw)
    h = self._eval_camera_targets()
    if h is None:
      return
    center_x, center_y = h
    x = center_x - (self.scrollarea.width / 2.0)
    y = center_y - (self.scrollarea.height / 2.0)
    self.scroll_to((int(x), int(y)))
  
  def switch_state(self, state):
    if self.state:
      self.state.on_end()

    self.state = state
    self.state.mainloop = self
  
  def switch_to_menu(self):
    self.switch_state(Menu())
    
  def switch_to_arcade(self, mode=None, level=None):
    if not level:
      level = 'test'
    self.switch_state(Arcade(level, mode))
  
  def add_camera_target(self, target):
    self._camera_targets.append(target)
  
  def get_leftmost_camera_target(self):
    retVal = None
    for t in self._camera_targets:
      if (retVal is None) or (t.x < retVal.x):
        retVal = t
    return retVal
  
  def get_rightmost_camera_target(self): # FIXME: copy&paste programming sucks :-(
    retVal = None
    for t in self._camera_targets:
      if (retVal is None) or (t.x > retVal.x):
        retVal = t
    return retVal
    
  MAX_LOOK_AHEAD = 130
  """How many pixels a player can look to one side, at most.
  
  The view won't scroll any further than that, even it it can.
  CAUTION: I haven't yet thought about what'll happen if this value is less
  than half the screen width. If there's a single player who can only look
  100 pixels to the left and the right, but the screen is 320 pixels wide ... o_O
  """
  
  def _eval_camera_targets(self):
    """Empty list of camera targets and return center of best scroll target.
    
    If there are no targets, return None.
    N.B. So far, we only need to scroll left and right; this method currently
    does nothing more than that, the y axis position is taken from the
    current scroll-area. If at one point we need to scroll vertically, too,
    we'll have to expand this method.
    """
    if len(self._camera_targets) == 0:
      return None
    min_x = self.get_leftmost_camera_target().x
    max_x = self.get_rightmost_camera_target().x
    target_span = max_x - min_x
    if target_span > self.scrollarea.width:
      # we can't properly fit all targets on one screen, so we'll do the best
      # we can, ignoring which way they face:
      center_x = min_x + (target_span / 2.0)
      retVal = (center_x, self.scrollarea.center_y)
    else:
      # the scrollarea has some wiggle room; figure out where this space starts
      # and ends. for this purpose, we figure out the min/max x coordinates
      # where the scrollarea's left/right border can end up:
      camera_min_x = max_x - self.scrollarea.width
      camera_max_x = min_x + self.scrollarea.width
      # eventually we should constrain the above values, at this point, by
      # the size of the level. this is still done elsewhere ... FIXME!
      
      # but wait a moment. we don't want to put a single player all the way
      # in the left corner, just because he's looking to the right at the
      # moment. so if the wiggle room is too much, constrain it:
      if min_x - camera_min_x > self.MAX_LOOK_AHEAD:
        camera_min_x = min_x - self.MAX_LOOK_AHEAD
      if camera_max_x - max_x > self.MAX_LOOK_AHEAD:
        camera_max_x = max_x + self.MAX_LOOK_AHEAD
      # how wide is the wiggle room now?
      pan_span = (camera_max_x - self.scrollarea.width) - camera_min_x
      # now evaluate the camera-tagets's preference in terms of look direction:
      left = 0
      right = 0
      for t in self._camera_targets:
        if t.facing is not None:
          if t.facing == CameraTarget.LEFT:
            left += 1
          else:
            right += 1
      try:
        ratio = right / float(left + right)
      except ZeroDivisionError:
        ratio = 0.5
      x = camera_min_x + pan_span * ratio
      center_x = x + (self.scrollarea.width / 2.0)
      retVal = (center_x, self.scrollarea.center_y)
    self._camera_targets = []
    return retVal