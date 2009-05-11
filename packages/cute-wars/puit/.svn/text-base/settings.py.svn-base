import sys, os
from ConfigParser import ConfigParser
from pyglet.window import key

# TODO: the whole key saving / loading / setting / getting code is ugly and should be cleaned up
settings_file = os.path.join('data', 'settings.ini')

_keys_player = {0 : {'left':key.LEFT, 'right':key.RIGHT, 'jump':key.UP, 'duck':key.DOWN, 'shoot':key.SPACE},
                1 : {'left':key.A, 'right':key.D, 'jump':key.W, 'duck':key.S, 'shoot':key.LSHIFT},
                2 : {'left':key.F, 'right':key.H, 'jump':key.T, 'duck':key.G, 'shoot':key.V}  }
loaded = False
def keys_player(number):
  if not loaded:
    load_keys()
  return _keys_player[number]

def set_keys_player(number, keys):
  _keys_player[number] = keys

def save_keys():
  configparser = ConfigParser()

  for player_nr, keys in _keys_player.iteritems():
    section = str(player_nr)
    configparser.add_section(section)
    for what, s in keys.iteritems():
      configparser.set(section, what, str(s))

  configparser.write(open(settings_file, 'w'))

def load_keys():
  loaded = True
  configparser = ConfigParser()
  if configparser.read(settings_file):
    for player_nr, keys in _keys_player.iteritems():
      section = str(player_nr)
      if not configparser.has_section(section):
        continue
      for key, setting in keys.iteritems():
        _keys_player[player_nr][key] = configparser.getint(section, key)


class Highscore(object):
  """
  very dumb highscore system (tm)
  using .ini files
  """
  def __init__(self):
    # TODO: serialize list of top 10 scores + player colours
    self.configparser = ConfigParser({'score': '0'})
    self.filename = os.path.join('data', 'notimportant.ini')
    self.configparser.read(self.filename) # LOLOLOLOLOLOL ^___^/
    if not self.configparser.has_section('high'):
      self.configparser.add_section('high')
  def get_score(self):
    return self.configparser.getint('high', 'score')

  def set_score(self, score):
    self.configparser.set('high', 'score', str(score))
    self.configparser.write(open(self.filename, 'w'))

