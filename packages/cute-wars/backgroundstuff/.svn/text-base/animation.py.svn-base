import os.path
from ConfigParser import ConfigParser
from pyglet import image
import puit # aaaaaaaaaaaaaaaaah shouldn't be. stupid scrolling system. change me
from backgroundstuff import graphics
from backgroundstuff.boundingbox import Boundingbox

data_folder = 'data'

# animation file format:
# 
# 
# [animation_name]
# ticks_per_frame: 0
# x_offset: 0
# y_offset: 0

animation_ini_defaults = {
  'ticks_per_frame' : '0',
  'x_offset' : '0',
  'y_offset' : '0'
}


animationsets = {}

def get_animationset(name):
  if not animationsets.has_key(name):
    animationsets[name] = AnimationSet(name)

  return animationsets[name]

def get_colouredanimationset(name, colours):
  key = name + str(colours)
  if not animationsets.has_key(key):
    animationsets[key] = ColouredAnimationSet(name, colours)

  return animationsets[key]

class AnimationFrames(object):
  def __init__(self, images_folder, ticks_per_frame, x_offset, y_offset):
    self.ticks_per_frame = ticks_per_frame
    self.x_offset = x_offset
    self.y_offset = y_offset
    
    self.frames = []
    self.frames_mirrored = []
          
    # load all images from animation folder
    images = os.listdir(images_folder)
    images.sort() # correct order plz
    for i in images:
      if i.endswith('.png') or i.endswith('.gif') or i.endswith('.bmp'):
        frame = graphics.get_image(os.path.join(images_folder, i))
        frame_mirrored = graphics.mirror_image(frame)
        self.frames.append(frame)
        self.frames_mirrored.append(frame_mirrored)

  def duration(self):
    return self.ticks_per_frame * len(self.frames)
  
  def draw(self, frame, position, mirrored=False):
    if mirrored:
      frame = self.frames_mirrored[frame]
    else:
      frame = self.frames[frame]

    # TODO: stupid scrolling system, improve it
    frame.blit(int(position[0] + self.x_offset - puit.gamemaster.scrollarea.left),
        int(position[1] + self.y_offset - puit.gamemaster.scrollarea.bottom))


class ColoredAnimationFrames(AnimationFrames):
  def __init__(self, images_folder, colors, ticks_per_frame, x_offset, y_offset):
    super(ColoredAnimationFrames, self).__init__(images_folder, ticks_per_frame, x_offset, y_offset)
    
    new_frames = []
    new_frames_mirrored = []
    for i in self.frames:
      new_frames.append( graphics.recolour_image(i, colors) )
    for i in self.frames_mirrored:
      new_frames_mirrored.append( graphics.recolour_image(i, colors) )
    self.frames = new_frames
    self.frames_mirrored = new_frames_mirrored


class AnimationSet(object):
  # TODO: maybe remove class animationset - do we really need this. couldn't we just work with sprites and animations?
  """
  Organizes an animation set: a folder with subfolders containing animations.
  ie
  character
    animation.ini
    running
      0.png
      1.png
    standing
      0.png
  """
  def __init__(self, name):
    base_folder = os.path.join(data_folder, name)
    config_file = os.path.join(base_folder, 'animation.ini')
    config = ConfigParser(animation_ini_defaults)
    config.read(config_file)  
    self.animations = {}

    files = os.listdir(os.path.join(data_folder, name))
    for possible_animation in files:
      animation_folder = os.path.join(data_folder, name, possible_animation)
      if os.path.isdir(animation_folder) and not possible_animation.startswith('.'):
      
        animation_name = possible_animation
        if not config.has_section(animation_name):
          config_section = 'DEFAULT'
        else:
          config_section = animation_name

        self.animations[animation_name] = self._create_animation(os.path.join(base_folder, animation_name),
          config.getint(config_section, 'ticks_per_frame'),
          config.getint(config_section, 'x_offset'),
          config.getint(config_section, 'y_offset'))

  def draw_animation(self, animation, frame, boundingbox, mirrored):
    if boundingbox.intersects(puit.gamemaster.scrollarea):
      self.animations[animation].draw(frame, boundingbox.bottom_left, mirrored)
  
  def _create_animation(self, name, ticks_per_frame, x, y):
    return AnimationFrames(name, ticks_per_frame, x, y)

class ColouredAnimationSet(AnimationSet):
  def __init__(self, name, colours):
    self.colours = colours
    super(ColouredAnimationSet, self).__init__(name)
  
  def _create_animation(self, name, ticks_per_frame, x, y):
    return ColoredAnimationFrames(name, self.colours, ticks_per_frame, x, y)


class Sprite(object):
  def __init__(self, name, colours=None):
    if colours:
      self.animation_set = get_colouredanimationset(name, colours)
    else:
      self.animation_set = get_animationset(name)
    self.frame = -1
    self.ticks_till_next_frame = 0
    self.animations = self.animation_set.animations

  def draw_animation(self, animation, boundingbox, mirrored, shift=None):
    if self.ticks_till_next_frame == 0:
      self.frame = self.frame + 1
      self.ticks_till_next_frame = self.animations[animation].ticks_per_frame
    else:
      self.ticks_till_next_frame = self.ticks_till_next_frame - 1

    if self.frame >= len(self.animations[animation].frames):
      self.frame = 0
    
    if boundingbox.intersects(puit.gamemaster.scrollarea):
      if shift is not None:
        pos = list(boundingbox.bottom_left)
        pos[0] += shift[0]
        pos[1] += shift[1]
        boundingbox = Boundingbox(pos, boundingbox.size)
      self.animation_set.draw_animation(animation, self.frame, boundingbox,
          mirrored)

class ComposedSprite(object):
  """Composed sprites are made up of several sprites and can be drawn as such.
  
  see puit.objects.character
  """
  def __init__(self, names, colours=None):
    self.sprites = []
    for name in names:
      self.sprites.append(Sprite(name, colours))

  def draw_animation(self, animations, boundingbox, mirrored, shift=None):
    i = 0
    offset_position = list(boundingbox.bottom_left)
    h = None
    for animation in animations:
      if shift is not None:
        h = shift[i]
      self.sprites[i].draw_animation(animation,
          Boundingbox(offset_position, boundingbox.size), mirrored, h)
      offset_position[0] += self.sprites[i].animations[animation].x_offset
      offset_position[1] += self.sprites[i].animations[animation].y_offset
      i += 1