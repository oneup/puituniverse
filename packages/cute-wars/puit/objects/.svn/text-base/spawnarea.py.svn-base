import random
import puit

from puit.objects.gameobject import Gameobject
from puit.objects.cpuplayer import CPUPlayer
from puit.objects.itemcrate import Itemcrate


class Spawnarea(Gameobject):
  """
  Spawnareas spawn objects every $random-interval frames
  """
  
  def __init__(self, position, width=1, height=1, interval = (1,1)):
    super(Spawnarea, self).__init__(position, width, height)
    self.affected_by_gravity = False
    self.frame_interval = interval
    self.paused = False
    self.ttl = self.frames_till_next_spawn()

  def set_interval(self, i):
    self.frame_interval = i

  def frames_till_next_spawn(self):
    return random.randint(self.frame_interval[0], self.frame_interval[1])

  def draw(self):
    pass
    
  def spawn_position(self):
    return [random.randint(self.boundingbox.left, self.boundingbox.right),
        random.randint(self.boundingbox.bottom, self.boundingbox.top)]

  def tick(self):
    super(Spawnarea, self).tick()
    
    if self.paused:
      return

    if self.ttl == 0:
      self.ttl = self.frames_till_next_spawn()
      self.gamestate.add_object(self.spawn_object(self.spawn_position()))
    else:
      self.ttl -= 1
  
  def pause(self):
    self.paused = True
  
  def resume(self):
    self.paused = False


class CPUPlayerSpawnarea(Spawnarea):
  def __init__(self, team, position, width=1, height=1, interval = (1,1)):
    super(CPUPlayerSpawnarea, self).__init__(position, width, height, interval)
    self.team = team

  def spawn_object(self, position):
    return CPUPlayer(position, self.team)