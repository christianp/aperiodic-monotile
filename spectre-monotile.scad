// Produce Tile(a,b)
a = 1;
b = 1;

curve_amount = 0.1;

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
    
function curve_between(a, b, steps=10, curve=curve_amount) = 
    let(
        d = b-a,
        n = [d[1],-d[0]]/norm(d)
    )
    [ for (i=0,t=0; i<steps; i = i+1, t=i/steps) t*b + (1-t)*a + n*sin(-360*t)*curve ]
;

curve_points = [ for(i=0;i<len(points);i=i+1) each curve_between(points[i], points[(i+1) % len(points)]) ];

 module tile() {
     linear_extrude(4) {
         scale(10) polygon(curve_points);
     }
 }
 
tile();