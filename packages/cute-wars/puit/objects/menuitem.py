import os
import random
from puit.objects.gameobject import Gameobject
from backgroundstuff.twod import Vector2d
from backgroundstuff import graphics
from pyglet.window import key
import puit
  
class MenuitemGroup(Gameobject):
  def __init__(self, items, x, y):    
    super(MenuitemGroup, self).__init__((x,y), 0, 0)
    self.menuitems = []
    for name in items:
      self.menuitems.append(Menuitem(self, name, x, y))
      y -= 6
    
    self.affected_by_gravity = False
    self.selected_item = 0
    self.menuitems[0].set_active(True)
    self.is_active = True
  
  # the whole submenu process is pretty dirty
  def spawn_submenu(self, submenu):
    self.set_active(False)
    submenu.parent_menu = self
    self.gamestate.add_object(submenu)
  
  def close_submenu(self):
    self.parent_menu.set_active(True)
    self.die()

  def set_active(self, is_active):
    self.is_active = is_active

  def draw(self):
    for item in self.menuitems:
      item.draw()

  def on_key_press(self, symbol, modifier):
    super(MenuitemGroup, self).on_key_press(symbol, modifier)
    if not self.is_active:
      return

    if symbol == key.UP:
      self.select_previous()
    elif symbol == key.DOWN:
      self.select_next()
    elif symbol == key.ENTER:
      self.on_selected(self.menuitems[self.selected_item].text)
  
  def select_next(self):
    self.menuitems[self.selected_item].set_active(False)
    self.selected_item += 1
    if self.selected_item >= len(self.menuitems):
      self.selected_item = 0
    self.menuitems[self.selected_item].set_active(True)
  
  def select_previous(self):
    self.menuitems[self.selected_item].set_active(False)
    self.selected_item -= 1
    if self.selected_item < 0:
      self.selected_item = len(self.menuitems) - 1
    self.menuitems[self.selected_item].set_active(True)
    
  def on_selected(self, text):
    self.menulistener.on_selected(text, self)


class Menuitem(object):
  def __init__(self, menuitemgroup, text, x, y):
    self.x = x
    self.y = y
    self.text = text
    self.is_active = False
    self.menuitemgroup = menuitemgroup

  def set_active(self, active):
    self.is_active = active

  def draw(self):
    if self.is_active:
      puit.gamemaster.pixelfont_grey.draw(self.text, self.x, self.y)
      puit.gamemaster.pixelfont.draw(self.text, self.x+1, self.y+1)
    elif self.menuitemgroup.is_active:
      puit.gamemaster.pixelfont.draw(self.text, self.x, self.y)
    else:
      puit.gamemaster.pixelfont_grey.draw(self.text, self.x, self.y)