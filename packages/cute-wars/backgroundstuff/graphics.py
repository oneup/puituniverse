from pyglet import image

images = {}

def get_image(filename):  
  if not images.has_key(filename):
    images[filename] = image.load(filename) # TODO: get this away from here and use animations everywhere

  return images[filename]


def colour(r, g, b, a=255):
  return str(chr(r)) + str(chr(g)) + str(chr(b)) + str(chr(a))


def dict_to_colourtable(colour_table):
  """
  make real colours out of the (0,0,0):(255,255,255) colour table shorthands
  """
  new_table = {}
  for key, value in colour_table.iteritems():
    new_table[colour(key[0], key[1], key[2])] = colour(value[0], value[1], value[2])
  return new_table


def recolour_image(frame, colour_table):
  colour_table = dict_to_colourtable(colour_table)
  
  rawimage = frame.image_data
  rawimage.format = 'RGBA'
  rawimage.pitch = len(rawimage.format) * rawimage.width
  data = rawimage.data

  # mirror each pixel row
  recoloured_pixels = ""
  pixel_number = 0
  while pixel_number < len(data):
    pixel = data[pixel_number:pixel_number+len(rawimage.format)]
    if colour_table.has_key(pixel):
      recoloured_pixels = recoloured_pixels + colour_table[pixel]
    else:
      recoloured_pixels = recoloured_pixels + pixel
    pixel_number = pixel_number + len(rawimage.format)

  coloured_image = image.ImageData(rawimage.width, rawimage.height, rawimage.format, recoloured_pixels, rawimage.pitch)
  rawimage.format = 'RGBA'
  return coloured_image


def mirror_image(frame):
  rawimage = frame.image_data
  rawimage.format = 'RGBA'
  rawimage.pitch = len(rawimage.format) * rawimage.width
  data = rawimage.data

  # mirror each pixel row
  mirrored_pixels = ""
  line_start = 0 
  while line_start < len(data):
    line = data[line_start:line_start+rawimage.pitch]

    #TODO: always recolour 4char string chunks (rgba)

    pixel_number = len(line)
    while pixel_number >= len(rawimage.format):
      mirrored_pixels = mirrored_pixels + line[pixel_number-len(rawimage.format):pixel_number]
      pixel_number = pixel_number - len(rawimage.format)

    line_start = line_start + rawimage.pitch

  frame_mirrored = image.ImageData(rawimage.width, rawimage.height, rawimage.format, mirrored_pixels, rawimage.pitch)
  rawimage.format = 'RGBA' # otherwise our original frame is broken
  return frame_mirrored

class Pixelmap(object):
  def __init__(self, image):
    rawimage = image.image_data
    rawimage.format = 'RGBA'
    rawimage.pitch = len(rawimage.format) * rawimage.width

    self.data = rawimage.data
    self.image = image
    self.rawimage = rawimage

  def pixel_at(self, x, y):
    assert(x >= 0 and x < self.image.width)
    assert(y >= 0 and y < self.image.height)

    start = y*self.rawimage.pitch + x*4
    return self.data[start:start + 4]