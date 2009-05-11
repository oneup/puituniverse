import random, os
from ConfigParser import ConfigParser
from puit.state.gamestate import Gamestate
from pyglet.window import key
import puit
from puit.state.pause import Pause

import puit.objects.level as level
from puit.objects.character import Team
from puit.objects.player import Player
from puit.objects.cpuplayer import CPUPlayer
from puit.objects.spawnarea import CPUPlayerSpawnarea
from puit.objects.itemcrate import Itemcrate
from puit.objects.aibuddy import AiBuddy
from puit.objects.aiplayer import AiPlayer

from puit.draw.radar import Radar


# well, yeah, this is mostly a copy&paste of arcade :-( i'll have to factor
# out the common parts some time. but most of the parts that are stil common
# now will change soon anyways.
class Conquest(Gamestate):
  def __init__(self, level_name=None, mode=None, testing=False):
    team1_col = (30,40,190)
    team2_col = (200,50,20)
    self.team1 = Team({(0,0,0):team1_col, (128,128,128):(100, 50, 75)})
    self.team2 = Team({(0,0,0):team2_col, (255,255,255):(0,0,0), (128,128,128):(100, 50, 75)})
    self.level = level.ConquestLevel(1600, 120, self.team1, self.team2)
    super(Conquest, self).__init__()
    self.add_object(self.level)
    self.test_mode = testing
    self.next_crate_at = 0
    self.next_wave_at = 10
    self.kills = 0
    self.continues = 2
    self.spawn_interval = [20, 50]
    self.add_object(CPUPlayerSpawnarea(self.team2,[self.level.boundingbox.right-30, self.level.boundingbox.height-1],  1,1, self.spawn_interval))
    self.spawn_player(0)
    self._radar = Radar(self)

  
  def get_kills(self):
    score = 0
    players = self.get_all(Player)
    for player in players:
      score += player.kill_count
    return score

  def increase_enemy_frequency(self, frames):
    spawn_areas = self.get_all(CPUPlayerSpawnarea)
    for area in spawn_areas:
      self.spawn_interval[0] -= frames
      self.spawn_interval[1] -= frames
      if self.spawn_interval[0] < 2:
        self.spawn_interval[0] = 2
      if self.spawn_interval[1] < 3:
        self.spawn_interval[1] = 3
      area.set_interval(self.spawn_interval)
      
  def draw(self):
    self._radar.draw()
    """
    Draw the Arcade GUI - "press start to play" and "next wave in"
    """
    super(Conquest, self).draw()
    x = puit.gamemaster.scrollarea.width/2
    y = puit.gamemaster.scrollarea.height-6
    puit.gamemaster.pixelfont_grey.draw_center('next wave in %s' % (self.next_wave_at - self.get_kills()), x, y)
    
    if self.may_spawn_player(0):
      x = puit.gamemaster.scrollarea.width-1
      puit.gamemaster.pixelfont_grey.draw_right('press 1', x, y)

    if self.may_spawn_player(1):
      x = puit.gamemaster.scrollarea.width-1
      puit.gamemaster.pixelfont_grey.draw_right('press 2', x, y)

  
  def all_players_dead(self):
    return len(self.get_all(Player)) == 0

  def player_alive(self, number):
    for p in self.get_all(Player):
      if p.number == number:
        return True
    return False

  def on_end(self):
    if puit.gamemaster.highscore.get_score() < self.kills:
      puit.gamemaster.highscore.set_score(self.kills)

  def tick(self):
    #super(Arcade, self).tick()
    #puit.gamemaster.scroll_to((0,0))
    self.kills = self.get_kills()
    if self.get_kills() == self.next_crate_at:
      self.next_crate_at += 30
      self.add_object(Itemcrate([random.randint(0, self.level.boundingbox.width), self.level.boundingbox.height-1]))
    
    if self.get_kills() >= self.next_wave_at:
      self.next_wave_at += 10
      self.increase_enemy_frequency(5)
    
    if len(self.get_all(CPUPlayer)) >= 30:
      # pause all spawnareas
      for s in self.get_all(CPUPlayerSpawnarea):
        s.pause()
    else:
      for s in self.get_all(CPUPlayerSpawnarea):
        s.resume()

    super(Conquest, self).tick() # das muss hier sein. damit die scrollarea danach limitiert wird
                               # haeh? was in Gamestate.tick() tut irgendwas mit scrollen?
    
    # limit scrollarea to level
    if puit.gamemaster.scrollarea.left < self.level.boundingbox.left:
      puit.gamemaster.scrollarea.left = self.level.boundingbox.left
    elif puit.gamemaster.scrollarea.right > self.level.boundingbox.right:
      puit.gamemaster.scrollarea.right = self.level.boundingbox.right
    if puit.gamemaster.scrollarea.top > self.level.boundingbox.top:
      puit.gamemaster.scrollarea.top = self.level.boundingbox.top
    elif puit.gamemaster.scrollarea.bottom < self.level.boundingbox.bottom:
      puit.gamemaster.scrollarea.bottom = self.level.boundingbox.bottom

    if self.all_players_dead(): # no more players living
      if self.test_mode:
        self.please_quit()
      else:
        puit.gamemaster.switch_to_menu()
    
  def spawn_player(self, number):
    if self.test_mode:
      player = AiPlayer([number*20,
       self.level.spawn_top()], self.team1, number)
    else:
      player = Player([number*20,
       self.level.spawn_top()], self.team1, number)
    self.continues -= 1
    self.add_object(player)

  def may_spawn_player(self, number):
    return self.continues > 0 and not self.player_alive(1)
    
  def on_key_press(self, symbol, modifiers):
    super(Conquest, self).on_key_press(symbol, modifiers)
      
    if symbol == key.ESCAPE:
      if hasattr(self, 'test_mode') and self.test_mode:
        self.please_quit()
      else:
        puit.gamemaster.switch_state(Pause(self))
