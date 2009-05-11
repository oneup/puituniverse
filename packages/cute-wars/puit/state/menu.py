import random, os
from puit.state.gamestate import Gamestate
import puit.objects.level as level
from puit.objects.character import Team
from puit.objects.player import Player
from puit.objects.spawnarea import CPUPlayerSpawnarea
from puit.objects.menuitem import MenuitemGroup
from puit.state.arcade import Arcade
from puit.state.conquest import Conquest
from backgroundstuff import graphics
from pyglet.window import key

import puit
import puit.settings

    
class MenuStuff(MenuitemGroup):
  def __init__(self, x, y):
    super(MenuStuff, self).__init__(['arcade', 'conquest', 'config', 'exit'], x, y)

  def on_selected(self, text):
    if text == 'arcade':
      puit.gamemaster.switch_to_arcade()
    #elif text == 'sidekick':
    #  puit.gamemaster.switch_to_arcade('help')
    elif text == 'conquest':
      puit.gamemaster.switch_state(Conquest())
    elif text == 'config':
      self.spawn_submenu(ConfigSubmenu(self.boundingbox.bottom + 30, self.boundingbox.left))
    elif text == 'exit':
      self.gamestate.please_quit()


class ConfigSubmenu(MenuitemGroup):
  def __init__(self, x, y):
    super(ConfigSubmenu, self).__init__(['plr one', 'plr two', 'back'], x, y)

  def on_selected(self, text):
    if text == 'plr one':
      self.spawn_submenu(ConfigControls(self.boundingbox.left,
          self.boundingbox.bottom - puit.gamemaster.pixelfont.line_height()*4, 0))
    elif text == 'plr two':
      self.spawn_submenu(ConfigControls(self.boundingbox.left,
          self.boundingbox.bottom - puit.gamemaster.pixelfont.line_height()*4, 1))
    elif text == 'back':
      self.close_submenu()


class ConfigControls(MenuitemGroup):
  def __init__(self, x, y, player_number):
    self.player_number = player_number
    self.assigned_keys = puit.settings.keys_player(self.player_number)
    items = self.assigned_keys.keys()
    items.append('back')
    super(ConfigControls, self).__init__(items, x, y)
    self.active_key = None

  def on_selected(self, text):
    if self.assigned_keys.has_key(text):
      self.active_key = text
      self.set_active(False)
    else:
      if text == 'back':
        puit.settings.set_keys_player(self.player_number, self.assigned_keys)
        puit.settings.save_keys()
        self.close_submenu()
  
  def draw(self):
    super(ConfigControls, self).draw()
    if self.active_key:
      puit.gamemaster.pixelfont.draw('press key for %s' % self.active_key,
          self.boundingbox.left, self.boundingbox.bottom \
          - puit.gamemaster.pixelfont.line_height() * (len(self.menuitems)+1))
  
  def on_key_press(self, symbol, modifier):
    if self.active_key:
      self.assigned_keys[self.active_key] = symbol
      self.active_key = None
      self.set_active(True)
    else:
      super(ConfigControls, self).on_key_press(symbol, modifier)


class Menu(Gamestate):
  def __init__(self):
    self.level = level.random_ground(puit.gamemaster.scrollarea.width, puit.gamemaster.scrollarea.height)
    super(Menu, self).__init__()
    self.add_object(self.level)

    self.left_spawn = CPUPlayerSpawnarea(Team(),[0, 50], 20, 1, (5, 20))
    self.add_object(self.left_spawn)
    self.right_spawn = CPUPlayerSpawnarea(Team({(0,0,0):(255,255,255), (255,255,255):(0,0,0), (128,128,128):(200, 23, 41)}),[self.level.width()-20, 50], 20, 1, (5, 20))
    self.add_object(self.right_spawn)
    
    self.add_object(MenuStuff(74, 81))

  def on_key_press(self, symbol, modifiers):
    super(Menu, self).on_key_press(symbol, modifiers)
  
  def tick(self):
    super(Menu, self).tick()
    
    if len(self.objects) < 5:
      self.left_spawn.resume()
      self.left_spawn.frame_interval = (10, 30)
      self.right_spawn.resume()
      self.right_spawn.frame_interval = (10, 30)
    elif len(self.objects) > 15:
      self.left_spawn.frame_interval = (50, 500)
      self.right_spawn.frame_interval = (50, 500)
    elif len(self.objects) > 30:
      self.left_spawn.pause()
      self.right_spawn.pause()
      

  def draw(self):
    super(Menu, self).draw()
    self.mainloop.scroll_to((0,0))
    
    x = 150
    y = 81
    puit.gamemaster.pixelfont.draw('highscore', x, y)
    puit.gamemaster.pixelfont.draw(str(puit.gamemaster.highscore.get_score()), x, y-7)
    
    graphics.get_image(os.path.join('data', 'logo.png')).blit(5, 50)