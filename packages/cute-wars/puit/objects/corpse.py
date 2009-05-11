import puit
from puit.objects.gameobject import Gameobject
from puit.objects.bullet import Bullet
import puit.objects.particle as particle

from pyglet import event;
from pyglet.window import key

from backgroundstuff.animation import Sprite

class CorpseDrawer(Sprite):
  def __init__(self, owner):
    self.owner = owner
    super(CorpseDrawer, self).__init__('character', self.owner.team.colours)

  def draw(self):
    if self.owner.shot_in_back:
      animation = 'die_back'
    else:
      animation = 'die'
    
    self.draw_animation(animation, self.owner.boundingbox, not self.owner.facing_left)

class Corpse(Gameobject):
  collision_group = 'targets'
  
  def __init__(self, character, shot_in_back):
    super(Corpse, self).__init__(character.boundingbox.bottom_left, 6, 10)
    self.team = character.team
    self.affected_by_gravity = True
    self.facing_left = character.facing_left
    self.drawer = CorpseDrawer(self)
    self.ticks_till_remove = self.drawer.animations['die'].duration()
    self.shot_in_back = shot_in_back

    
    self.velocity[1] = character.velocity[1]

  def spawn_blood(self):
    particle.spawn_blood(self, self.facing_left)
    
  def draw(self):
    self.drawer.draw()

  def tick(self):
    super(Corpse, self).tick()
    if self.ticks_till_remove <= 0:
      self.die()
      return
    else:
      self.ticks_till_remove = self.ticks_till_remove - 1
  
  def hit_by_bullet(self, bullet, parts=None):
    """
    Corpses just "suck up bullets" until they leave
    """
    self.spawn_blood()
    return True