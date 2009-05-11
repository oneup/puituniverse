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


class Arcade(Gamestate):
  def __init__(self, level_name=None, mode=None, testing=False):
    if level_name is None:
      self.level = level.random_ground(puit.gamemaster.scrollarea.width * 2, puit.gamemaster.scrollarea.height)
    else:
      self.level = level.load(level_name)
    super(Arcade, self).__init__()
    
    self.test_mode = testing

    self.enemy_team = Team({(0,0,0):(random.randint(0, 255),random.randint(0, 255),random.randint(0, 255)), (128,128,128):(random.randint(0, 128), random.randint(0, 128), random.randint(0, 128))})

    #{(0,0,0):(194,255,74), (128,128,128):(124, 149, 79)}
    self.next_crate_at = 0
    self.next_wave_at = 10
    self.kills = 0
    self.continues = 2
    
    self.spawn_interval = [200, 300]
    
    self.add_object(CPUPlayerSpawnarea(self.enemy_team,[1, self.level.boundingbox.height-1],  1,1, self.spawn_interval))
    self.add_object(CPUPlayerSpawnarea(self.enemy_team,[self.level.boundingbox.right-1, self.level.boundingbox.height-1],  1,1, self.spawn_interval))
    x = self.level.boundingbox.left+1
    self.add_object(CPUPlayerSpawnarea(self.enemy_team,[x, self.level.top_border_at(x, 1)+12], 1,1, self.spawn_interval))
    x = self.level.boundingbox.right-1
    self.add_object(CPUPlayerSpawnarea(self.enemy_team,[x, self.level.top_border_at(x, 1)+12], 1,1, self.spawn_interval))
    self.add_object(CPUPlayerSpawnarea(self.enemy_team, self.level.boundingbox.center,  1,1, self.spawn_interval))
    
    self.add_object(self.level)

    self.player_team = Team({(0,0,0):(255,255,255), (255,255,255):(0,0,0), (128,128,128):(200, 23, 41)})
    self.spawn_player(0)
    if mode == 'multi':
      self.spawn_player(1)
    elif mode == 'help':
      self.spawn_ai_buddy()

  
  def get_kills(self):
    score = 0
    players = self.get_all(Player)
    for player in players:
      score += player.kill_count
    return score

  def increase_enemy_frequency(self, frames):
    spawn_areas = self.get_all(CPUPlayerSpawnarea)
    for area in spawn_areas:
      self.spawn_interval[0] -=frames
      self.spawn_interval[1] -= frames
      if self.spawn_interval[0] < 2:
        self.spawn_interval[0] = 2
      if self.spawn_interval[1] < 3:
        self.spawn_interval[1] = 3
      area.set_interval(self.spawn_interval)
      
  def draw(self):
    """
    Draw the Arcade GUI - "press start to play" and "next wave in"
    """
    super(Arcade, self).draw()
    
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
      self.increase_enemy_frequency(3)
    
    if len(self.get_all(CPUPlayer)) >= 30:
      # pause all spawnareas
      for s in self.get_all(CPUPlayerSpawnarea):
        s.pause()
    else:
      for s in self.get_all(CPUPlayerSpawnarea):
        s.resume()

    super(Arcade, self).tick() # das muss hier sein. damit die scrollarea danach limitiert wird
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
      player = AiPlayer([self.level.boundingbox.width/2 - number*20,
       self.level.spawn_top()], self.player_team, number)
    else:
      player = Player([self.level.boundingbox.width/2 - number*20,
       self.level.spawn_top()], self.player_team, number)
    self.continues -= 1
    self.add_object(player)
  
  def spawn_ai_buddy(self):
    if self.test_mode:
      buddy = AiPlayer(puit.gamemaster.scrollarea.center, self.player_team, 2)
    else:
      buddy = AiBuddy(puit.gamemaster.scrollarea.center, self.player_team, 2)
    self.add_object(buddy)

  def may_spawn_player(self, number):
    return self.continues > 0 and not self.player_alive(1)
    
  def on_key_press(self, symbol, modifiers):
    super(Arcade, self).on_key_press(symbol, modifiers)
      
    if symbol == key.ESCAPE:
      if hasattr(self, 'test_mode') and self.test_mode:
        self.please_quit()
      else:
        puit.gamemaster.switch_state(Pause(self))

    if symbol == key._1:
      if self.may_spawn_player(0):
        self.spawn_player(0)

    if symbol == key._2:
      if self.may_spawn_player(1):
        self.spawn_player(1)

    if symbol == key._9: # INSERT COIN *MWAHAHAHAHA*
      self.continues += 1 #LOLOL CHEAT, NOBODY KNOWS
