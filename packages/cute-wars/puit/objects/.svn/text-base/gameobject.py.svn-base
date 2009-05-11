from backgroundstuff.boundingbox import Boundingbox
import types


class Gameobject(object):
  """
  Base class for all game objects.
  
  Note: Never trust the y velocity to be 0 when on ground. NEVER. IT ISN'T!!!
  """
  
  gravity = -0.3
  collision_group = None
  container = False
  
  def can(self, method):
    """
    returns wether this gameobject can respond to method
    """
    return hasattr(self, method) \
         and type(getattr(self, method)) is types.MethodType
  
  def __init__(self, position, width=1, height=1):
    self.is_dead = False
    self.boundingbox = Boundingbox(position, (width, height), gameobject=self)
    self.velocity = [0.0, 0.0]
    self.on_ground = False
    self._ground_detected = False
    self._mini_graphic_is_valid = False
    self._mini_graphic = None

  def is_on_ground(self):
    return self.on_ground

  def facing_left(self):
    return self.velocity[0] < 0

  #use this instead!
  def init(self):
    pass
    
  def tick(self):
    self.on_ground = self._ground_detected
    self._ground_detected = False
  
  def move(self):
    if self.affected_by_gravity:
      self.velocity[1] += Gameobject.gravity
    self.boundingbox.move(self.velocity)
  
  def draw(self):
    pass
  
  def get_mini_graphic(self, width=None):
    if not self._mini_graphic_is_valid:
      self._mini_graphic = self._make_mini_graphic(width)
      self._mini_graphic_is_valid = True
    return self._mini_graphic
      
  
  # check wether this collides with the other gameobject (called from gamestate for each object pair twice)
  #def collide_with(self, gameobject):
  #  pass
  
  # one object may call this function of another when they collide
  def collided_with(self, gameobject, description=None, details=None):
    if description == 'ground' or (description == 'landingzone'):
      self.velocity[1] = -2 # this needs to be -2, so that little bumps in the level don't send us to a "in_air" state
      self._ground_detected = True

  def die(self, killer=None):
    self.is_dead = True
  
  def revive(self):
    self.is_dead = False

  def on_key_press(self, symbol, modifiers):
    pass

  def on_key_release(self, symbol, modifiers):
    pass
  
  def set_mid_bottom(self, pos):
    """move this object so its mid_bottom is at pos.
    
    why mid_bottom and not center or lower_left? well, the thing is, we
    shouldn't need this at all, once the collision system has some wrinkles
    ironed out. until then, there is just one section of code that wants
    to change a Gameobject's position from the outside, and that one section
    wants to specify the mid_bottom, so here we go. apart from that other
    section of code that needs to set the 'top' attribute ... ugh ... see
    set_top().
    """
    self.boundingbox.mid_bottom = pos
  
  def set_top(self, top):
    """move this object so its top is at top.
    
    see set_mid_bottom
    """
    self.boundingbox.top = top
    

class CompositeGameobject(Gameobject):
  """A small collection of game objects that should logically be treated as one game object.
  
  This can be seen as the game state pendant of ComposedSprite, e.g. this
  class is useful for adding a gun to a character, but it's also useful, for
  example, for joining together multiple parts or layers of a level. Note that
  this is drawn by simply drawing all objects contained herein; object of
  this class are _not_ supposed to have a drawer that uses a ComposedSprite.
  """
  # i'm not done implementing this class yet, it's just there already so i can
  # define classes to inherit from CompositeGameobject and so the above first
  # version of a description is available already. i'm going to need this
  # to make conquest mode levels that are a bit more sophisticated than the
  # levels we have so far, but we should also be able to use this for
  # improving the animation system.
  
  container = True
  
  def __init__(self, objects=None):
    super(CompositeGameobject, self).__init__((0, 0), 0, 0)
    if objects is None:
      self._objects = []
    else:
      self._objects = list(objects)
    if (objects is not None) and (len(objects) > 0):
      self.boundingbox.enclose([o.boundingbox for o in objects])
  
  def add(self, obj):
    raise NotImplemented
  
  def remove(self, obj):
    raise NotImplemented
  
  def get_parts(self):
    return self._objects[:]
  
  def tick(self):
    super(CompositeGameobject, self).tick()
    for o in self._objects:
      o.tick()
    #if (len(self._objects) > 0):
    #  self.boundingbox.enclose([o.boundingbox for o in self._objects])
  
  def move(self):
    """moves this object and all contained objects by the velocity of this object.
    
    all objects contained in this object move together, therefore their
    individual velocity attributes are disregarded. however, they are
    _overwritten_ with the velocity of this object, so their state is
    internally consistent and their drawers can do the right thing."""
    super(CompositeGameobject, self).move()
    for o in self._objects:
      #o.boundingbox.move(self.velocity)
      # note that we're transferring the velocity, but don't change which
      # object o uses to store its velocity! this is necessary because
      # these objects are mutable, and because it would be a mistake to
      # make o.velocity the same object as self.velocity, as o might
      # become detached from self in the future and have an independent
      # velocity again.
      o.velocity[0] = self.velocity[0]
      o.velocity[1] = self.velocity[1]
      o.boundingbox.move(self.velocity)
      
  def draw(self):
    for o in self._objects:
      o.draw()
  
  def collided_with(self, gameobject, description=None, details=None):
    super(CompositeGameobject, self).collided_with(gameobject, description, details)
    for o in self._objects:
      o.collided_with(gameobject, description, details)
  
  def die(self, killer=None):
    super(CompositeGameobject, self).die(killer)
    for o in self._objects:
      o.die(killer)
  
  def revive(self):
    super(CompositeGameobject, self).revive()
    for o in self._objects:
      o.revive()
  
  def set_mid_bottom(self, pos):
    old_pos = self.boundingbox.mid_bottom
    delta = (pos[0] - old_pos[0], pos[1] - old_pos[1])
    # self.boundingbox.mid_bottom = pos
    self.boundingbox.move(delta)
    for o in self._objects:
      o.boundingbox.move(delta)
  
  def set_top(self, top):
    old_top = self.boundingbox.top
    delta = (0, top - old_top)
    self.boundingbox.move(delta)
    for o in self._objects:
      o.boundingbox.move(delta)