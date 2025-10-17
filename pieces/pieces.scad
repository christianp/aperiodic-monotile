include <../dovetail.scad>;

// Height
height = 20;

// Width
w = 5;

// In-radius
in = 10;

// Angle
angle = 30;

// Total length
L = 90;

// Number of teeth
teeth_count = 2;

// Height of each tooth
teeth_height = w;

// Wiggle room
teeth_clearance = 0.25;



s = sin(angle);
c = cos(angle);

x = (L-4*w-3*(w+2*in)*s)/c;
y = (w+2*in)*(1-c)/s;

b = (x + y)/2;

a = (x-b)/2;

$fn = 100;

module segment(angle) {
    intersection() {
        difference() {
            circle(r=w+in);
            circle(r=in);
        }
        translate([0,-w-in]) square([w+in,2*(w+in)]);
        rotate([0,0,90-angle]) translate([-w-in,0]) square([2*(w+in),w+in]);
    }
}


module edge() {

    p0 = [2*w,w];

    p1 = p0 + [(w+in)*s, -(w+in)*(1-c)];

    p2 = p1 + [a*c, -a*s];

    p3 = p2 + [in*s,in*c];

    p4 = p2 + [in*2*s,0];

    p5 = p4 + [b*c,b*s];

    p6 = p5 + [(w+in)*s,-(w+in)*c];

    p7 = p5 + [2*(w+in)*s,0];

    p8 = p7 + [a*c, -a*s];

    p9 = p8 + [in*s, -in*(1-c)];

    linear_extrude(height) {
        
        translate(p0+[0,-w-in,0]) segment(angle);

        translate(p3) rotate([0,0,180+angle]) segment(2*angle);

        translate(p1) rotate(-angle) translate([0,-w]) square([a,w]);

        translate(p4) rotate(angle) translate([0,-w]) square([b,w]);

        translate(p6) rotate(angle) segment(2*angle);

        translate(p7) rotate(-angle) translate([0,-w]) square([a,w]);

        translate(p0+[L-4*w,in]) rotate(180) segment(angle);
        
        color("white") translate([0,0]) square([2*w,w]);

        color("blue") translate([L-2*w,0]) square([2*w,w]);
    }
}

module convex_90() {
    linear_extrude(height) {
        square(w);
        translate([w,0,0]) square(w);
        translate([0,w,0]) square(w);
    }
}

module convex_120() {
    linear_extrude(height) {
        square([2*w,w]);
        translate([0,0,0]) rotate(30) square([w,2*w]);
    }
}

module straight() {
    linear_extrude(height) {
        translate([-2*w,0,0]) square([4*w,w]);
    }
}

function monotile_points() = 
    let(
    a=L,
    b=L,
    c = cos(60),
    s = sin(60),

    moves = [
        [0, 0, -60],
        [c*b, s*b, 60],
        [b,0, -90],
        [0,a, 60],
        [s*a, c*a, 90],
        [c*b, -s*b, 60],
        [-c*b, -s*b, -90],
        [s*a, -c*a, 60],
        [0, -a, 0],
        [0, -a, 60],
        [-s*a, -c*a, 90],
        [-c*b, s*b, -60],
        [-b, 0, 90],
        [0, a, -60],
        [-s*a, c*a, 90]
    ]
    )
        
    [ 
        for (
            i=0, p=moves[0]; 
            i < len(moves)-1; 
            i = i+1, p = p + moves[i]
        )
        p
    ]
;

module cut_edge() {
    intersection() {
        edge();
        
        translate([L-w-w/2,0,height/2])
        rotate([0,90,90]) 
        cutter(
            position=[0, 0, 0], 
            dimension=[height,L,100],
            teeths=[teeth_count, teeth_height, teeth_clearance],
            male=false
        );
        
        translate([w+w/2,0,height/2])
        rotate([0,90,90])
        cutter(
            position=[0, 0, 0],
            dimension=[height,L,100],
            teeths=[teeth_count, teeth_height, teeth_clearance],
            male=true
        );
    }
}

module cut_convex_90() {
    intersection() {
        convex_90();

            
        translate([w+w/2,0,height/2])
        rotate([0,90,90]) 
        cutter(
            position=[0, 0, 0], 
            dimension=[height,4*w,100],
            teeths=[teeth_count, teeth_height, teeth_clearance],
            male=false
        );
        
        
        translate([0,w+w/2,height/2])
        rotate([0,90,0])
        cutter(
            position=[0, 0, 0],
            dimension=[height,L,100],
            teeths=[teeth_count, teeth_height, teeth_clearance],
            male=true
        );
        
    }
}

module cut_convex_120() {
    intersection() {
        convex_120();

            
        translate([w+w/2,0,height/2])
        rotate([0,90,90]) 
        cutter(
            position=[0, 0, 0], 
            dimension=[height,4*w,100],
            teeths=[teeth_count, teeth_height, teeth_clearance],
            male=false
        );
        
        
        rotate(30)
        translate([0,w+w/2,height/2])
        rotate([0,90,0])
        cutter(
            position=[0, 0, 0],
            dimension=[height,L,100],
            teeths=[teeth_count, teeth_height, teeth_clearance],
            male=true
        );
        
    }
}

module cut_straight() {
    intersection() {
        straight();

            
        translate([w+w/2,0,height/2])
        rotate([0,90,90]) 
        cutter(
            position=[0, 0, 0], 
            dimension=[height,4*w,100],
            teeths=[teeth_count, teeth_height, teeth_clearance],
            male=false
        );
        
        
        #translate([-w-w/2,0,height/2])
        rotate([0,90,90])
        cutter(
            position=[0, 0, 0],
            dimension=[height,L,100],
            teeths=[teeth_count, teeth_height, teeth_clearance],
            male=true
        );
        
    }
}

translate([-30,20,0]) cut_convex_90();
translate([-30,0,0]) rotate(-30) cut_convex_120();
translate([-30,-20,0]) cut_straight();
cut_edge();


//rotate([0,-90,0]) cut_convex_90();
//rotate(-30) cut_convex_120();
// rotate([90,0,0]) cut_straight();
