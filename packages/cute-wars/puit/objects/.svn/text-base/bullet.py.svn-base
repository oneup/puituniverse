from pyglet import event
from pyglet.window import key
from pyglet.gl import *

import puit
from puit import draw as draw_me_a
from puit.objects.gameobject import Gameobject
from backgroundstuff.animation import Sprite

class BulletDrawer(Sprite):
  def __init__(self, owner, colours):
    self.owner = owner
    if colours is None:
      self._colour = (0.5, 0.5, 0.5)
    elif (128, 128, 128) in colours:
      r, g, b = colours[(128, 128, 128)]
      self._colour = (r / 255.0, g / 255.0, b / 255.0)
    else:
      # the old way of drawing bullets, left in as a fallback
      super(BulletDrawer, self).__init__('bullet', colours)
      self.draw = self._draw_fallback
  
  def draw(self):
    bb = self.owner.boundingbox
    h = self.owner.boundingbox.width
    self.owner.boundingbox.width = 2
    draw_me_a.rect(self.owner.boundingbox, self._colour, puit.gamemaster.scrollarea.bottom_left)
    self.owner.boundingbox.width = h

  def _draw_fallback(self):
    self.draw_animation('default', self.owner.boundingbox, True)
    

class Bullet(Gameobject):
  collision_group = 'bullets'
  
  def __init__(self, owner, position, fly_left):
    super(Bullet, self).__init__(position, 6, 1) # FIXME: actualy bullet width is 2, see revision notes ...
    self.drawer = BulletDrawer(self, owner.team.colours)
    self.owner = owner # might be dead befor the bullet is !!!111
    self.affected_by_gravity = False
    self.speed = 4
    if fly_left:
      self.velocity = [-self.speed, 0]
    else:
      self.velocity = [self.speed, 0]
    self.age = 0
    self.max_age = 80

  def draw(self):
    self.drawer.draw()
  
  def tick(self):
    # WARNING: ONLY WORKS IN ARCADE MODE. CONQUEST NEEDS "EVERYWHERE FLYING BULLETS"
    super(Bullet, self).tick()
    if self.age >= self.max_age:
      self.die()
    self.age += 1
    
    # where in our playfield is the scrollare?
    
    # TODO: fixme intersect liefert immer true wtf? fix boundingbox code alltogether
    #if not self.boundingbox.intersects(puit.gamemaster.scrollarea):
    #  # out of visible area - goodbye
    #  self.die()
    
    # ooooehm, ob ich ein paar pixel (die breite eines gegners) nach links oder
    # nach rechts scrolle soll einen einfluss darauf haben koennen, ob ein gegner
    # getroffen wird oder ueberlebt? und bei meinem freund, der uebers netzwerk
    # mitspielt, verschwinden die bullets dann mittem am bildschirm? das ist
    # doch kacke!
    
  def collided_with(self, gameobject, description=None, details=None):
    super(Bullet, self).collided_with(gameobject, description, details)
    if description == 'world boundaries' or description == 'ground' \
        or (description == 'landingzone'):
      self.die()
  
  def collide_with(self, gameobject, parts=None):
    # if gameobject.can('hit_by_bullet'): # took this out, ObjectCollection should have taken care of that
      # if self.boundingbox.intersects(gameobject.boundingbox): # dito
    if gameobject.hit_by_bullet(self, parts):
      self.die()