$fn = 30;

// Size, in mm
diameter = 500;
// Thickness of the outline, in mm 
thickness = 5; 

// Diameter of dowel holes, in mm
hole_diameter = 3;

// Angle of the arrow lock between pieces
lock_angle = 30;


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

module tile() {
    curve_points = 
        [ for(i=0; i<len(points); i=i+1) each curve_between(i) ];

    difference() {
        polygon(curve_points);
        offset(-thickness) polygon(curve_points);
    }
}

module divider(i) {
    p = curve_point(i,0.1);
    d = direction_at(i,0.1);
    n = cross([d[0],d[1],0], [0,0,1]);
    an = atan2(d[1],d[0]);
    
    translate(p+n/norm(n)*thickness/2)
    rotate(an+90) {
        rotate(lock_angle)
        #square([thickness,0.1]);
        rotate(-180-lock_angle)
        #square([thickness,0.1]);
    }
}

module hole(i) {
    p = points[i];
    pi = i==0 ? len(points)-1 : i-1;
    t1 = direction_at(i,0);
    t2 = direction_at(pi,1);
    dd = normal(t1) + normal(t2);
    d = unit(dd);
    z = cross(t1,t2);
    f = z==0 ? thickness/2 : hole_diameter + (thickness-hole_diameter)/(z>0 ? 2 : 10);

    c = p + f*d;

    translate(c) circle(d=hole_diameter);
}

module hole_tile() {
    difference() {
        tile();

        #for(i=[0:len(points)-1]) {
            hole(i);
        }
    }
}

module label(i) {
    d = direction_at(i,0.5);
    an = atan2(d[1],d[0]);
    translate(curve_point(i, 0.5)) 
    rotate(an) 
    translate([0,-thickness*0.75]) 
    text(str(i), size=thickness/2, font="Atkinson Hyperlegible Next:style=Bold");
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

pieces(0);

translate([400,0]) pieces(1);