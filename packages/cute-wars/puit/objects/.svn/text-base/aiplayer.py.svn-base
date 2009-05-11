import random

from puit.objects.player import Player
from puit.objects.cpuplayer import Statemachine, StatemachineState
from puit.objects.character import Gun, Minigun

from puit.objects.bullet import Bullet
from puit.objects.itemcrate import Itemcrate

# arrrrgh, actually i'd like to inherit from both Player and CPUPlayer here,
# but those have a common base class, and because they use super, i really
# should use super here, too. however, i don't know how to do this properly
# in this situation, and it's too late in the night^W morning to learn it
# now. so, i'll just inherit from Player and add CPUPlayer behaviour through
# aggregation.
class AiPlayer(Player):
  def __init__(self, position, team, number):
    super(AiPlayer, self).__init__(position, team, number)
    del self.keys # part of Player, but AiPlayer doesn't need this
    self.statemachine = Statemachine(self, {'move': MoveState(),
     'jump': JumpState(), 'prone': ProneState()})
  
  def on_key_press(self, symbol, modifier):
    pass # don't respond to key presses
  
  def on_key_release(self, symbol, modifier):
    pass # don't respond to key presses
  
  def tick(self):
    super(AiPlayer, self).tick()
    self.statemachine.tick()
  
  def collided_with(self, other, description=None, details=None):
    super(AiPlayer, self).collided_with(other, description, details)
    self.statemachine.state.on_collided_with(other, description, details)
  
  def is_enemy_bullet_approaching(self):
    """still a rather simplistic approach ...
    """
    if not hasattr(self, 'gamestate'): # can't take existence of gamestate for granted!
      return False
    bullets = self.gamestate.get_all(Bullet)
    x_pos = self.boundingbox.center_x
    for b in bullets:
      if b.owner.team == self.team:
        continue # not an enemy bullet
      distance = abs(x_pos - b.boundingbox.center_x)
      if distance > 24:
        continue # not dangerous yet
      fly_left = b.velocity < 0
      to_right = b.boundingbox.center_x > x_pos
      if (fly_left and to_right) or ((not fly_left) and (not to_right)):
        return b # OMG a bullet is closing in!
    return False # when we end up here, no dangerous bullets were found
  
  def is_goodie_present(self):
    if not hasattr(self, 'gamestate'):
      return False
    goodies = self.gamestate.get_all(Itemcrate)
    return len(goodies) > 0
    
  def is_nearest_goodie_to_the_left(self):
    if not hasattr(self, 'gamestate'):
      return None
    goodies = self.gamestate.get_all(Itemcrate)
    min_distance = -1
    ret_val = None
    x_pos = self.boundingbox.center_x
    for g in goodies:
      distance = abs(x_pos - g.boundingbox.center_x)
      if (min_distance < 0) or (distance < min_distance):
        min_distance = distance
        ret_val = g.boundingbox.center_x < x_pos
    return ret_val


class MoveState(StatemachineState):
  def on_start(self, options=None):
    """options is a dict:
         'direction' -> 'left' or 'right'
         'shooting_in' -> integer describing in how many ticks a shot will be fired"""
    self.statemachine.owner.stand_up()
    self.ticks = random.randint(8, 24)
    self.move_left = random.choice((True, False))
    self.shooting_in = random.randint(2, 10)
    if options != None:
      if 'direction' in options:
        self.move_left = (options['direction'] == 'left')
      if 'shooting_in' in options:
        self.shooting_in = options['shooting_in']
    if type(self.statemachine.owner.body.equipment) is Minigun:
      self.shooting_in = 0
    if self.statemachine.owner.is_goodie_present():
      if self.move_left == self.statemachine.owner.is_nearest_goodie_to_the_left():
        self.ticks *= 8 # amplify movement towards goodie!
 
  def on_tick(self):
    bullet = self.statemachine.owner.is_enemy_bullet_approaching()
    if self.ticks == 0:
      if random.randint(0, 10) < 1:
        new_state = 'jump'
      elif random.randint(0, 10) < 2:
        new_state = 'prone'
      else:
        new_state = 'move'
      self.statemachine.switch_state(new_state)
    elif bullet:
      height = bullet.boundingbox.bottom \
          - self.statemachine.owner.boundingbox.bottom
      if height >= 5:
        self.statemachine.switch_state('prone')
      else:
        self.statemachine.switch_state('jump', {'move_left': self.move_left})
    else:
      if self.move_left:
        self.statemachine.owner.move_left()
      else:
        self.statemachine.owner.move_right()
      if self.shooting_in <= 0:
        self.statemachine.owner.start_use_equipment()
        if type(self.statemachine.owner.body.equipment) is Gun:
          self.shooting_in = random.randint(2, 6)
        elif type(self.statemachine.owner.body.equipment) is Minigun:
          pass # heck yeah, endless fire!
      else:
        self.statemachine.owner.stop_use_equipment()
        self.shooting_in -= 1
      self.ticks -= 1

  def on_end(self):
    self.statemachine.owner.stop()

  # i'm moving the bounding boxes on collisions (also in the JumoState below)
  # in an attempt to prevent them from getting stuck in the lower left corner,
  # but it doesn't quite help, they still do that sometimes. no idea yet
  # what's causing that.
  def on_collided_with(self, other, description, details=None):
    if description == 'world boundaries':
      if details == 'left':
        self.statemachine.owner.move_right()
        self.statemachine.owner.boundingbox.move((2, 0))
        self.statemachine.switch_state('move', {'direction': 'right'})
      elif details == 'right':
        self.statemachine.owner.move_left()
        self.statemachine.owner.boundingbox.move((-2, 0))
        self.statemachine.switch_state('move', {'direction': 'left'})

class JumpState(StatemachineState):
  def on_start(self, options=None):
    self.ticks = 2
    self.move_left = random.choice((True, False))
    self.shooting_in = random.randint(0, 4)
    if options != None:
      if 'move_left' in options:
        self.move_left = options['move_left']
      if 'shooting' in options:
        self.shooting_in = options['shooting_in']
    if type(self.statemachine.owner.body.equipment) is Minigun:
      self.shooting_in = 0
    if self.statemachine.owner.is_goodie_present():
      if self.move_left == self.statemachine.owner.is_nearest_goodie_to_the_left():
        self.ticks *= 10 # amplify movement towards goodie!
    self.statemachine.owner.jump()

  def on_tick(self):
    if (self.ticks <= 0) and self.statemachine.owner.is_on_ground():
      if self.move_left:
        dir = 'left'
      else:
        dir = 'right'
      self.statemachine.switch_state('move',
       {'direction': dir, 'shooting_in': self.shooting_in})
    if self.move_left:
      self.statemachine.owner.move_left()
    else:
      self.statemachine.owner.move_right()
    if self.shooting_in <= 0:
      self.statemachine.owner.start_use_equipment()
      if type(self.statemachine.owner.body.equipment) is Gun:
        self.shooting_in = random.randint(2, 6)
      elif type(self.statemachine.owner.body.equipment) is Minigun:
        pass # heck yeah, endless fire!
    else:
      self.statemachine.owner.stop_use_equipment()
      self.shooting_in -= 1
    if (self.ticks <= -6) and (random.randint(0, 10) < 3):
      # turn around
      self.statemachine.switch_state('jump',
       {'move_left': (not self.move_left), 'shooting_in': self.shooting_in})
    self.ticks -= 1
  
  def on_collided_with(self, other, description, details=None):
    if description == 'world boundaries':
      if details == 'left':
        self.statemachine.owner.move_right()
        self.statemachine.owner.boundingbox.move((2, 0))
        self.statemachine.switch_state('move', {'direction': 'right'})
      elif details == 'right':
        self.statemachine.owner.move_left()
        self.statemachine.owner.boundingbox.move((-2, 0))
        self.statemachine.switch_state('move', {'direction': 'left'})
    elif (description == 'ground') or (description == 'landingzone'):
      if self.move_left:
        dir = 'left'
      else:
        dir = 'right'
      self.statemachine.switch_state('move',
       {'direction': dir, 'shooting_in': self.shooting_in})


class ProneState(StatemachineState):
  def on_start(self, options=None):
    self.ticks = random.randint(8, 20)
    self.shooting_in = random.randint(0, 4)
    if type(self.statemachine.owner.body.equipment) is Minigun:
      self.shooting_in = 0
    self.statemachine.owner.stop()
    self.statemachine.owner.duck()

  def on_tick(self):
    if (self.ticks <= 0):
      self.statemachine.owner.stand_up()
      self.statemachine.switch_state()
    self.statemachine.owner.stop()
    self.statemachine.owner.duck()
    if self.shooting_in <= 0:
      self.statemachine.owner.start_use_equipment()
      if type(self.statemachine.owner.body.equipment) is Gun:
        self.shooting_in = random.randint(2, 6)
      elif type(self.statemachine.owner.body.equipment) is Minigun:
        pass # heck yeah, endless fire!
    else:
      self.statemachine.owner.stop_use_equipment()
      self.shooting_in -= 1
    self.ticks -= 1
  
  def end(self):
    self.statemachine.owner.stand_up()