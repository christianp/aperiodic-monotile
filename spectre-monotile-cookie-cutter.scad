a = 1;
b = 1;

// Wiggliness
curve_amount = 0; // [0:flat, 3: curvy]

c = cos(60);
s = sin(60);

num_steps = 20;

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
    p*30
];
    
function curve_between(a, b, steps=num_steps, curve=curve_amount) = 
    let(
        d = b-a,
        n = [d[1],-d[0]]/norm(d)
    )
    [ for (i=0,t=0; i<steps; i = i+1, t=i/steps) t*b + (1-t)*a + n*sin(-360*t)*curve ]
;

curve_points = [ for(i=0;i<len(points);i=i+1) each curve_between(points[i], points[(i+1) % len(points)]) ];

module tile() {
    polygon(curve_points);
}
 
module outline(thickness) {
    if(thickness > 0) {
        difference() {
            offset(thickness) children();
            children();
        }
    } else {
        difference() {
            children();
            offset(thickness) children();
        }
    }
}

module cookie_cutter(height, thickness, handle) {
    translate([0,0,height]) rotate([0,180,0]) {
        linear_extrude(height) outline(-thickness) children();
        translate([0,0,height-1]) difference() {
            union() {
//                linear_extrude(1) outline(handle) children();
                linear_extrude(1) outline(-handle) children();
            }
            for (p = points) {
           //     translate(p*30) cylinder(d=1.5*handle, $fn=20);
            }
        }
        //handle_end(height,handle) children();
    }
}

module handle_end(height,handle) {
    intersection() {
      length = (points[2][1] - points[11][1]);
      #union() {
        translate(points[2] - [13,3*handle,0]) cube([2*handle,4*handle,height]);
        translate([points[2][0],points[11][1],0] - [13,0*handle,0]) cube([2*handle,2*handle,height]);
      }
      linear_extrude(1) outline(-handle) children();
    }
}

cookie_cutter(height=10, thickness=2, handle=6) tile();

