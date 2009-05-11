from pyglet import event;
from pyglet.window import key
import random

import puit
from puit.objects.gameobject import Gameobject
from puit.objects.character import Character
from puit.objects.bullet import Bullet
from puit.objects.player import Player

class Statemachine(object):
  def __init__(self, owner, states):
    self.owner = owner
    self.states = states # a dictionary of name:statemachinestate instance
    for state in self.states.values():
      state.statemachine = self
    self.state = None
  
    self.switch_state(random.choice(self.states.keys()))

  def add_state(name, state):
    state.statemachine = self
    self.states[name] = state

  def tick(self):
    self.state.on_tick()
  
  def switch_state(self, statename=None, options=None):
    if statename == None:
      statename = random.choice(self.states.keys())

    if self.state:
      self.state.on_end()
    self.state = self.states[statename]
    self.state.on_start(options)

class StatemachineState(object):
  def on_start(self, options=None):
    pass
    
  def on_end(self):
    pass
    
  def on_tick(self):
    pass
  
  def on_collided_with(self, gameobject, reason=None, details=None):
    pass

class StandState(StatemachineState):
  def on_start(self, options=None):
    self.ticks = random.randint(10, 20)
 
  def on_tick(self):
    if self.ticks == 0:
      self.statemachine.switch_state()
    else:
      self.ticks = self.ticks - 1

class MoveState(StatemachineState):
  def on_start(self, options=None): # options = True - move left
    self.ticks = random.randint(20, 60)
    if options != None:
      self.move_left = options
    else:
      self.move_left = random.choice((True, False))
    
    if self.move_left:
      self.statemachine.owner.move_left()
    else:
      self.statemachine.owner.move_right()
 
  def on_tick(self):
    if self.ticks == 0:
      self.statemachine.switch_state()
    else:
      self.ticks = self.ticks - 1

  def on_end(self):
    self.statemachine.owner.stop()

  def on_collided_with(self, other, description, details=None):
    if description == 'world boundaries':
      if details == 'left':
        self.statemachine.switch_state('move', False)
      elif details == 'right':
        self.statemachine.switch_state('move', True)

class ShootState(StatemachineState):
  def on_start(self, options=None):
    self.statemachine.owner.start_use_equipment()

  def on_tick(self):
    self.statemachine.switch_state()
    
  def on_stop(self):
    self.statemachine.owner.stop_use_equipment()

class CPUPlayer(Character):
  def __init__(self, position, team):
    super(CPUPlayer, self).__init__(position, team)
    self.statemachine = Statemachine(self, {'stand' : StandState(), 'move' : MoveState(), 'shoot' : ShootState()})
    
  def tick(self):
    super(CPUPlayer, self).tick()
    self.statemachine.tick()
  
  def collided_with(self, other, description=None, details=None):
    super(CPUPlayer, self).collided_with(other, description, details)
    self.statemachine.state.on_collided_with(other, description, details)

  def die(self, killer=None):
    super(CPUPlayer, self).die(killer)
    self.gamestate.mainloop.play('die_enemy.wav')