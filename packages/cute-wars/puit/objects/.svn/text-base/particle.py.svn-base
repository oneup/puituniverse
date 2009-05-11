from pyglet import event
from pyglet.gl import *
import random

import puit
from puit.objects.gameobject import Gameobject
from puit.team import Team
from puit import draw as draw_me_a

from backgroundstuff.animation import Sprite


class ParticleDrawer(Sprite):
  def __init__(self, owner, colours):
    self.owner = owner
    if colours is None:
      self._colour = (0.5, 0.5, 0.5)
    elif (128, 128, 128) in colours:
      r, g, b = colours[(128, 128, 128)]
      self._colour = (r / 255.0, g / 255.0, b / 255.0)
    else:
      # the old way of drawing bullets, left in as a fallback
      super(ParticleDrawer, self).__init__('particle', colours)
      self.draw = self._draw_fallback
  
  def draw(self):
    draw_me_a.rect(self.owner.boundingbox, self._colour, puit.gamemaster.scrollarea.bottom_left)

  def _draw_fallback(self):        
    self.draw_animation('default', self.owner.boundingbox, True)


def spawn_blood(character, fly_left=True):
  if not fly_left:
    velx = -2
  else:
    velx = +2
  
  y = 1
  for x in range(-1, 1):
      pos = character.boundingbox.center
      character.gamestate.add_object(
          Particle(pos,
          [velx+random.random()*x, random.random()*2+random.random()*y/1],
          character.team)
        )
  
class Particle(Gameobject):
  """
  1pixel particles: Blood, ejecting brass, etc
  """
  
  collision_group = 'debris'

  def __init__(self, position, velocity, team):
    super(Particle, self).__init__(position, 1, 1)
    self.affected_by_gravity = True
    self.velocity = velocity
    self.team = team
    self.drawer = ParticleDrawer(self, self.team.colours)
    self.age = 0
    self.max_age = 64

  def draw(self):
    self.drawer.draw()

  def tick(self):
    super(Particle, self).tick()
    if (self.velocity[0] == 0) or (self.age >= self.max_age):
      self.die()
    self.age += 1

    
  def collided_with(self, gameobject, description=None, details=None):
    newvely = -self.velocity[1]/2
    super(Particle, self).collided_with(gameobject, description, details)
    
    if description == 'ground' or (description == 'landingzone'):
      self.velocity[1] = newvely
      self.apply_friction(0.3)
    
    if description == 'world boundaries':
      self.die()
  
  def apply_friction(self, friction):
    oldvelx = self.velocity[0]
    if oldvelx > 0:
      newvelx = self.velocity[0] - friction
    else:
      newvelx = self.velocity[0] + friction
    
    if (oldvelx > 0 and newvelx < 0) or (oldvelx < 0 and newvelx > 0):
      newvelx = 0
    
    self.velocity[0] = newvelx