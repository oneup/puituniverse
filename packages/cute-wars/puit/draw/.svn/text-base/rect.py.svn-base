from pyglet.gl import *

import puit

def rect(bounds, colour, shift=None):
  glDisable(GL_TEXTURE_2D)
  glColor3f(*colour)
  if shift is not None:
    glPushMatrix()
    glTranslatef(-1 * shift[0], -1 * shift[1], 0)
    pop = True
  else:
    pop = False
  glBegin(GL_QUADS)
  pos = bounds.bottom_left
  width, height = bounds.size
  glVertex2f(*pos)
  glVertex2f(pos[0] + width, pos[1])
  glVertex2f(pos[0] + width, pos[1] + height)
  glVertex2f(pos[0], pos[1] + height)
  glEnd()
  if pop:
    glPopMatrix()
  glColor3f(1.0, 1.0, 1.0) # TODO: resetting the colour each and every time seems a bit wasteful
  glEnable(GL_TEXTURE_2D) # TODO: same about this