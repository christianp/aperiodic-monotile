# The aperiodic monotile in a variety of formats

This repository contains code and vector image files to produce [the aperiodic monotile found by David Smith, Joseph Samuel Myers, Craig S. Kaplan, and Chaim Goodman-Strauss](https://cs.uwaterloo.ca/~csk/hat/).

Each file produces a single copy of the tile. Several copies of the tile, with some flipped or mirrored, fit together to tile the plane.

The files are:

* [monotile.svg](monotile.svg) - A vector graphics file for use in programs such as Inkscape or Adobe Illustrator.
* [monotile.scad](monotile.scad) - Code to produce the tile in [OpenSCAD](https://openscad.org/), for 3D printing.
* [monotile.stl](monotile.stl) - An STL file produced using the OpenSCAD code, which can be sent directly to a 3D printer, or manipulated in other 3D software.
* [monotile.logo](monotile.logo) - A LOGO script to draw the outline of the title with Turtle graphics.
