import puit
from puit.objects.gameobject import Gameobject, CompositeGameobject
from puit.objects.bullet import Bullet
from puit.objects.corpse import Corpse
import puit.objects.particle as particle
from puit.team import Team

from pyglet import event;
from pyglet.window import key

from backgroundstuff.animation import Sprite, ComposedSprite


class CharacterDrawer(object):
  def __init__(self, owner, colours):
    self.owner = owner
    self.sprite = ComposedSprite(['character', 'weapons'], colours)
    self.blink_ttl = 0

  def draw(self):
    if self.owner.character.is_invincible():
      self.blink_ttl += 1
      if self.blink_ttl%6 < 3:
        return

    # TODO: resolve animation via equipment classname
    if self.owner.character.is_on_parachute():
      animation = 'parachute'
    else:
      if not self.owner.is_on_ground():
        if self.owner.velocity[1] > 0:
          animation = 'jump_up'
        else:
          animation = 'jump_down'
      else:
        if self.owner.stance == CharacterBody.STANCE_STANDING:
          if self.owner.velocity[0] != 0:
            animation = 'running'
          else:
            animation = 'standing'
        elif self.owner.stance == CharacterBody.STANCE_PRONE:
          animation = 'prone'

    if animation == 'parachute':
      animations = [animation]
    else:
      animations = [animation, self.owner.equipment.__class__.__name__.lower()]
    shift = None
    if animation == 'prone':
      if animations[1] == 'gun':
        if self.owner.character.facing_left:
          shift = [(0, 0), (-4, -3)]
        else:
          shift = [(0, 0), (3, -3)]
      elif animations[1] == 'minigun':
        if self.owner.character.facing_left:
          shift = [(0, 0), (-4, -2)]
        else:
          shift = [(0, 0), (3, -2)]
        
    self.sprite.draw_animation(animations, self.owner.boundingbox,
        self.owner.character.facing_left, shift)

class Equipment(object):
  def __init__(self, player):
    self.owner = player
    self.in_use = False

  def start_use(self):
    self.in_use = True
  
  def stop_use(self):
    self.in_use = False
  
  def tick(self):
    pass


class Parachute(Equipment):
  def tick(self):
    super(Parachute, self).tick()
    self.owner.character.velocity[1] /= 1.6 # float slower
    # the above line is OK because it counter-acts gravity, which is
    # an acceleration itself. however, for the horizontal component,
    # we just want to slow down a constant movement by a constant factor.
    # changing the velocity every tick isn't going to do that, so instead
    # we simply modify the position like so:
    pos = list(self.owner.character.boundingbox.mid_bottom)
    pos[0] -= 0.6 * self.owner.character.velocity[0]
    self.owner.character.set_mid_bottom(pos)

  def start_use(self):
    super(Parachute, self).start_use()
    # commented the following line out to fix the getting-stuck-in-ground bug
    # see the revision notes for explanation.
    #self.owner.equipment = Gun(self.owner)


class Gun(Equipment):
  def start_use(self):
    super(Gun, self).start_use()
    if self.owner.stance == CharacterBody.STANCE_STANDING:
      bullet_x_offset = 0
      bullet_y_offset = 5
    elif self.owner.stance == CharacterBody.STANCE_PRONE:
      if self.owner.character.facing_left:
        bullet_x_offset = -6
      else:
        bullet_x_offset = 4
      bullet_y_offset = 2
    else:
      raise NotImplemented # ... yet
    if self.owner.character.facing_left:
      position = list(self.owner.boundingbox.bottom_left)
    else:
      position = list(self.owner.boundingbox.bottom_right)
    position[0] = position[0] + bullet_x_offset
    position[1] = position[1] + bullet_y_offset
    self.owner.character.gamestate.add_object(Bullet(self.owner.character, position,
        self.owner.character.facing_left))
    self.owner.character.gamestate.mainloop.play('shoot.wav')

class Minigun(Equipment):    
  def tick(self):
    super(Minigun, self).tick()
    if self.in_use:
      if self.owner.stance == CharacterBody.STANCE_STANDING:
        bullet_x_offset = 0
        bullet_y_offset = 3
      elif self.owner.stance == CharacterBody.STANCE_PRONE:
        if self.owner.character.facing_left:
          bullet_x_offset = -6
        else:
          bullet_x_offset = 4
        bullet_y_offset = 1
      else:
        raise NotImplemented # ... yet
      if self.owner.character.facing_left:
        position = list(self.owner.boundingbox.bottom_left)
      else:
        position = list(self.owner.boundingbox.bottom_right)
      position[0] = position[0] + bullet_x_offset
      position[1] = position[1] + bullet_y_offset
      self.owner.character.gamestate.add_object(Bullet(self.owner.character, position,
          self.owner.character.facing_left))
      self.owner.character.gamestate.mainloop.play('shoot.wav')


class Character(CompositeGameobject):
  """Character is the base class for all "puit warriors". Player and CPU controlled (AI).
  """
  # parts of this look a bit ugly at the moment, because we're in the middle
  # of the Gameobject -> CompositeGameobject transition. i'll fix this soon.
  
  jump_velocity = 4.2
  collision_group = 'targets'
  
  def __init__(self, position, team):
    self.body = CharacterBody(self, position, team)
    super(Character, self).__init__([self.body])
    self.affected_by_gravity = True
    self.facing_left = False
    self.local_human = False
    """Whether this character is controlled by a human player on the local machine."""
    self.speed = 2.0
    self.team = team
    self.kill_count = 0
    self.invincible_ttl = 0

  def tick(self):
    super(Character, self).tick()
    if self.invincible_ttl > 0:
      self.invincible_ttl -= 1
    
  def move_left(self, suppress_turn=False):
    if not suppress_turn:
      self.facing_left = True
    self.velocity[0] = -self.speed

  def move_right(self, suppress_turn=False):
    if not suppress_turn:
      self.facing_left = False
    self.velocity[0] = self.speed
  
  def stop(self):
    self.velocity[0] = 0
  
  def jump(self):
    if self.is_on_ground() and self.body.stance == CharacterBody.STANCE_STANDING:
      self.velocity[1] = Character.jump_velocity
  
  def duck(self):
    if self.is_on_ground() and self.body.stance != CharacterBody.STANCE_PRONE:
      self.body.go_prone()
  
  def stand_up(self):
    self.body.stand_up()
    
  def start_use_equipment(self):
    self.body.equipment.start_use()
    
  def stop_use_equipment(self):
    self.body.equipment.stop_use()
  
  def is_killable_by(self, killer): # killer: bullet that hit us
    return not self.is_invincible() and killer.owner.team != self.team
    
  def hit_by_bullet(self, bullet, parts=None):
    if self.is_killable_by(bullet) and (self.body in parts):
      if self.body.stance == self.body.STANCE_PRONE:
        height = bullet.boundingbox.bottom - self.boundingbox.bottom
        if height > 4.0:
          return False
      bullet.owner.kill_count += 1
      self.die(bullet)
      return True
    else:
      return False
  
  def is_on_parachute(self):
    return self.body.equipment.__class__.__name__ == 'Parachute' # FIXME
  
  def collided_with(self, gameobject, description=None, details=None):
    super(Character, self).collided_with(gameobject, description, details)
    if description == 'ground' or (description == 'landingzone'):
      if self.is_on_parachute(): # hit ground - switch to ground
        self.body.equipment = Gun(self.body)
      self.landed()
  
  def landed(self):
    pass

  def die(self, killer=None):
    super(Character, self).die(killer)
    if killer != None:
      if self.facing_left:
        shot_in_back = killer.velocity[0] < 0
      else:
        shot_in_back = killer.velocity[0] > 0
      c = Corpse(self, shot_in_back)
      self.gamestate.add_object(c)
      c.spawn_blood() # FIXME: needs to be done this way, because the constructor Corpse() has no gamestate yet and thus can't call spawn_blood
    # self.gamestate.mainloop.play('die.wav')
    
  def set_invincible(self, ttl):
    self.invincible_ttl = ttl

  def is_invincible(self):
    return self.invincible_ttl > 0

class CharacterBody(Gameobject):
  """The actual body of a character.
  
  This is just the body and (not yet, but eventually) excludes stuff like
  the parachute and weapons.
  """
  
  STANCE_STANDING = 0
  STANCE_CROUCHING = 1
  STANCE_PRONE = 2
  
  def __init__(self, character, position, team):
    super(CharacterBody, self).__init__(position, 6, 13)
    self.character = character
    self.stance = self.STANCE_STANDING
    self.drawer = CharacterDrawer(self, team.colours)
    self.equipment = Parachute(self)
  
  def draw(self):
    self.drawer.draw()
    
  def tick(self):
    super(CharacterBody, self).tick()  
    self.equipment.tick()
  
  def go_prone(self):
    self.stance = self.STANCE_PRONE
  
  def stand_up(self):
    if self.stance != self.STANCE_STANDING:
      self.stance = self.STANCE_STANDING