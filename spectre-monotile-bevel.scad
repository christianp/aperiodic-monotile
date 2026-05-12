/*
This is a bit of a mess, with some modules and functions left over from previous ideas that aren't used in this model.

The general idea is that I construct the Spectre shape, then take a thick outline of it to be the stamper. 
I want to bevel the face that is presented to the sand.

The whole thing is too big to 3D print in one piece, so my plan is to cut it into sections, one for each vertex. Each section extends halfway along the curve towards the next vertex.

How do I get the bevelling to work at the vertex? Can I do it as the union of some things, instead of the difference?
*/


$fn = 30;

// Size, in mm
diameter = 500;
// Thickness of the outline, in mm 
thickness = 10;

// Diameter of dowel holes, in mm
hole_diameter = 3;

// Angle of the arrow lock between pieces
lock_angle = 45;

// Thickness of the wall, in mm
wall = 2;

// Height of the cutter, in mm
cutter_height = 8;

// Height of the sidewall, in mm
sidewall = 5;

// Which corner to make
corner = 7;


a = diameter / 4.767;
b = a;

curve_amount = 0.1*a;

c = cos(60);
s = sin(60);

moves = [
    [0,0],
    [c*b, s*b],
    [b,0],
    [0,a],
    [s*a, c*a],
    [c*b, -s*b],
    [-c*b, -s*b],
    [s*a, -c*a],
    [0, -a],
    [0, -a],
    [-s*a, -c*a],
    [-c*b, s*b],
    [-b, 0],
    [0, a],
    [-s*a, c*a]
];
    
points = [ 
    for (
        i=0, p=moves[0]; 
        i < len(moves)-1; 
        i = i+1, p = p + moves[i]
    )
    p
];

function unit(v) = norm(v) == 0 ? v : v/norm(v);

function normal(v) = [v[1],-v[0]]/norm(v);

function curve_point(i, t, curve=curve_amount) =
    let(
        a = points[i%len(points)],
        b = points[(i+1)%len(points)],
        d = b - a,
        n = normal(d)
    )
    t*b + (1-t)*a + n*sin(-360*t)*curve
;

function direction_at(i, t) =
    let(
        m1 = curve_point(i,t),
        m2 = curve_point(i,t+0.001)
    )
    m2 - m1;


    
function curve_between(j, steps=100, curve=curve_amount) = 
    [ for (i=0,t=0; i<steps; i = i+1, t=i/steps) curve_point(j,t,curve) ]
;

module tile(thickness) {
    curve_points = 
        [ for(i=0; i<len(points); i=i+1) each curve_between(i) ];

    intersection() {
        offset(thickness/2) polygon(curve_points);
        union() {
            difference() {
                offset(thickness/2) polygon(curve_points);
                offset(-thickness/2) polygon(curve_points);
            }
            for(i=[0:len(points)-1]) {
                reinforcer(i);
            }
        }
    }
}

gapo = 0.08;
starto = 0.5+gapo;
endo = 0.5-gapo;
function curve_between_halved(j,a,b, steps=100, curve=curve_amount) = 
    [ for (i=(j==a?steps*starto:0),t=(j==a?starto:0); i<(j==b-1?steps*endo:steps); i = i+1, t=i/steps) curve_point(j,t,curve) ]
;
module tile_part(thickness,a,b) {
    curve_points = 
        [ for(i=a; i<b; i=i+1) each curve_between_halved(i,a,b) ];

    intersection() {
        offset(thickness/2) polygon(curve_points);
        union() {
            difference() {
                offset(thickness/2) polygon(curve_points);
                offset(-thickness/2) polygon(curve_points);
            }
            for(i=[a+1:b-1]) {
                reinforcer(i);
            }
        }
    }
}

module divider(i) {
    x = 0.12;
    p = curve_point(i,x);
    d = direction_at(i,x);
    n = cross([d[0],d[1],0], [0,0,1]);
    an = atan2(d[1],d[0]);
    
    t = 0.3;
    translate(p)
    rotate(an+90) {
        rotate(lock_angle)
        #translate([-t/2,-t/2]) square([thickness,t]);
        rotate(-180-lock_angle)
        #translate([-t/2,-t/2]) square([thickness,t]);
    }
}

module reinforcer(i) {
    p = points[i % len(points)];
    pi = i==0 ? len(points)-1 : i-1;
    t1 = direction_at(i,0);
    t2 = direction_at(pi,1);
    dd = normal(t1) + normal(t2);
    d = unit(dd);
    z = cross(t1,t2);
    f = abs(z) < 0.01 ? 0 : (thickness-hole_diameter)/(z>0 ? 4 : -4);

    c = p + f*d;
    
    s = abs(z)<0.01 ? 1 : z>0 ? 1.5 : 1;

    translate(c) circle(d=s*thickness);
}    

module hole(i) {
    p = points[i];
    pi = i==0 ? len(points)-1 : i-1;
    t1 = direction_at(i,0);
    t2 = direction_at(pi,1);
    dd = normal(t1) + normal(t2);
    d = unit(dd);
    z = cross(t1,t2);
    f = abs(z)<0.01 ? 0 : (thickness-hole_diameter)/(z>0 ? 4 : -4);

    c = p + f*d;

    translate(c) circle(d=hole_diameter);
}

module hole_tile() {
    difference() {
        tile();

        for(i=[0:len(points)-1]) {
            hole(i);
        }
    }
}

module text_at(vertex,along,txt) {
    d = direction_at(vertex, along);
    an = atan2(d[1],d[0]);
    translate(curve_point(vertex, along)) 
    rotate(an)
    text(txt, size=thickness/2, font="Atkinson Hyperlegible Next:style=Bold", valign="center");
}


module label(i) {
    text_at(i, 0.5, str(i));
}

module pieces(layer) {

    difference() {
        hole_tile();

        for(i=[layer:2:len(points)-1]) {
            divider(i);
        
            label(i);
        }
    }
}

function lerp(a,b,t) = t*(b-a) + a;

module cutter(h=cutter_height,steps=100) {
    for (i=[0:len(points)-1]) {
        for (j=[0:steps]) {
            t = lerp(0,1.1,j/steps);
            p = curve_point(i,t);
            d = direction_at(i,t);
            an = atan2(d[1],d[0]) - 90;
            
            translate([0,0,])
            translate(p)
            rotate([0,0,an])
            rotate([90,0,0])
            linear_extrude(2)
                polygon([
                    [-(thickness+2*wall)/2,0],
                    [(thickness+2*wall)/2,0],
                    [0,-h]
                ])
            ;
        }
    }
    
    for(p=points) {
       // translate([0,0,-cutter_height]) translate(p) cylinder(h=cutter_height,r=thickness+wall);
    }
}


module bevel(a) {
    rotate([180,0,0]) {
        intersection() {

            union() {
            intersection() {
                linear_extrude(cutter_height) tile(thickness+wall);
                translate([0,0,cutter_height]) cutter();
             
            }

            translate([0,0,cutter_height])
            difference() {
                linear_extrude(wall+sidewall) tile(thickness+wall);
                translate([0,0,wall]) linear_extrude(sidewall) tile(thickness);
            }
            }
            linear_extrude(200) tile_part(2*thickness,a,a+2);
        }

     }
}

translate(-1 * points[corner]) bevel(corner);