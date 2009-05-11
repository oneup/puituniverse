import puit
from puit.objects.gameobject import Gameobject
from pyglet import event;
from pyglet.window import key
from backgroundstuff.animation import Sprite, ComposedSprite


class ItemcrateDrawer(object):
  def __init__(self, owner):
    self.owner = owner
    self.sprite = Sprite('itemcrate')
    assert(self.sprite.animations['default'].frames[0].data[0] == "6")

  def draw(self):
    self.sprite.draw_animation('default', self.owner.boundingbox,
        self.owner.facing_left)


class Itemcrate(Gameobject):
  """
  Item boxes - Minigun, Gun, Grenades et
  If touched by a player the player gets the contained item
  """
  # TODO: give more than just the minigun
  
  collision_group = 'goodies'
  
  def __init__(self, position):
    super(Itemcrate, self).__init__(position, 5, 5)
    self.affected_by_gravity = True
    self.drawer = ItemcrateDrawer(self)
    self.contained_item = 'minigun'

  def draw(self):
    self.drawer.draw()

  def collide_with(self, gameobject, parts=None):
    # only check for collisions if the other object can pick up stuff
    if not gameobject.can('pickup_item'):
      return
    
    # took out the following line as ObjectCollection should have taken care of that already
    # if self.boundingbox.intersects(gameobject.boundingbox):
    gameobject.pickup_item(self.contained_item)
    self.die()