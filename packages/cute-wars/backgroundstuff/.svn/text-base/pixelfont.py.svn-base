from pyglet import image
from backgroundstuff import graphics

fonts = {}
def load_font(filename, colours=None):
  key = filename + str(colours)
  if not fonts.has_key(key):
    if colours:
      colourtable = {(0,0,0):colours[0], (255,255,255):colours[1]}
      font = Pixelfont(filename, colourtable)
    else:
      font = Pixelfont(filename)
    fonts[key] = font

  return fonts[key]

class Pixelfont(object):
  glyphs = 'abcdefghijklmnopqrstuvwxyz1234567890.!?/:_- #'
  glyph_width = 5 # TODO: get from graphics file
  glyph_height = 5

  def __init__(self, filename, colours=None):
    self.offset_map = {}
    x = 0
    for g in Pixelfont.glyphs:
      self.offset_map[g] = x
      x += 1
    
    self.image = graphics.get_image(filename)
    if colours:
      self.image = graphics.recolour_image(self.image, colours)
    self.imagegrid = image.ImageGrid(self.image, 1, len(Pixelfont.glyphs))
    self.frames = image.TextureGrid(self.imagegrid)

  def line_height(self):
    return Pixelfont.glyph_height + 1

  def string_width(self, text):
    return len(text) * (Pixelfont.glyph_width-1) + 1

  def draw_center(self, text, x, y):
    x -= self.string_width(text)/2 # because glyphs are drawn with only 4 px advance
    self.draw(text, x, y)

  def draw_right(self, text, x, y):
    x -= self.string_width(text) # because glyphs are drawn with only 4 px advance
    self.draw(text, x, y)

  def draw(self, text, x, y):
    for g in text:
      g = g.lower()
      if self.offset_map.has_key(g):
        offset = self.offset_map[g]
      else:
        offset = self.offset_map['#']
      self.frames[offset].blit(x, y)
      x += Pixelfont.glyph_width - 1