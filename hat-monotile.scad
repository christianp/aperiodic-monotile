r = [1,0];
u = [cos(60),sin(60)];
d = [cos(60),-sin(60)];

points = [
    [0,0],
    1/2 * r,
    u,
    2*u + 1/2*d,
    r + u,
    u + 3/2*r,
    2*r,
    3*r - 1/2*u,
    2*r + d,
    r + d,
    r + 1/2 * d,
    d,
    -1/2 * u
 ];
 
 module tile() {
     linear_extrude(4) {
         scale(10) translate(-r) polygon(points);
     }
 }
 
 tile();