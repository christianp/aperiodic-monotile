/**
 *  Dovetail parametric generator for OpenScad
 *  Générateur de queue d'aronde pour OpenScad
 *
 *  Copyright (c) 2012 Charles Rincheval.  All rights reserved.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 *  Last update :
 *  https://github.com/hugokernel/OpenSCAD_Dovetail
 *
 *  http://www.digitalspirit.org/
 */

/**
 *  Create one teeth
 *  @param int width        Teeth width
 *  @param int height       Teeth height
 *  @param int thickness    Teeth thickness
 */
module dovetail_teeth(width, height, thickness) {
    offset = width / 3;
    translate([- width / 2, - height / 2, 0]) {
        linear_extrude(height = thickness) {
            polygon([[0, 0], [width, 0], [width - offset, height], [offset, height]]);
        }
    }
}


/**
 *  Dovetail
 *  @param int  width           Dovetail width
 *  @param int  teeth_count     Teeth count
 *  @param int  teeth_height    Teeth height
 *  @param int  teeth_thickness Teeth thickness
 *  @param int  clear           Teeth clear
 *  @param bool male            Get male (true) or female (false)
 */
module dovetail(width, teeth_count, teeth_height, teeth_thickness, clear=0.1, male=true, debug=false) {

    /**
     * 4 sections :
     *
     * |1/2         1/2|
     * |--+ <- 3 -> +--|--+         +--
     * |   \1  1  1/   |   \       /
     * |    \_____/    |    \_____/
     */

    y = ((width - teeth_count * 2 * clear) / teeth_count) / 4;

    compensation = - 0.1;
    teeth_width = y * 3;

    // Always width / 3 (ref. dovetail_teeth())
    offset = teeth_width / 3;
    start_at = clear * 2 + teeth_width / 2 - width / 2 - clear;

    translate([0, 0, - teeth_thickness / 2]) {

        // Debug purpose only
        if (debug) {
            translate([- width / 2, 0, - width / 2]) {
                %cube(size = [width, 0.01, width]);
            }
        }

        for (i = [-1 : teeth_count * 2 - 1] ) {
            x = start_at + y / 2 + (teeth_width - offset + clear) * i;
            if (i % 2) {
                x = x + 0.1;
                translate([x + compensation, - clear, 0]) {
                    rotate([0, 0, 180]) {
                        if (male == true) {
                            dovetail_teeth(teeth_width - clear, teeth_height - clear, teeth_thickness);
                        }
                    }
                }
            } else {
                translate([x, clear, 0]) {
                    if (male == false) {
                        dovetail_teeth(teeth_width - clear, teeth_height - clear, teeth_thickness);
                    }
                }
            }
        }
    }
}

/**
 *  Cut piece
 *  @param vector position  Cut position ([x, y, z])
 *  @param vector dimension Dimension of bounding box ([w, l, h])
 *  @param vector teeths    Teeths parameters ([count, height, clearance])
 *  @param bool   male      Get male (true) or female (false)
 */
module cutter(position, dimension, teeths, male=true, debug=false) {
    translate(position) {
        dovetail(dimension[0], teeths[0], teeths[1], dimension[2], teeths[2], male, debug);

        if (male) {
            translate([- dimension[0] / 2, - (teeths[1] / 2 - 0.1) - dimension[1], - dimension[2] / 2]) {
                cube(size = dimension);
            }
        } else {
            translate([- dimension[0] / 2, teeths[1] / 2 - 0.1, - dimension[2] / 2]) {
                cube(size = dimension);
            }
        }
    }
}
