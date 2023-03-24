r = [1,0];
d = [cos(60),-sin(60)];

points = [
    [0,0],
    r,
    r + d,
    3*r,
    5*r + 2*d,
    4*r + 4*d,
    3*r + 4*d,
    2*r + 5*d,
    r + 4*d,
    -r + 5*d,
    -r + 4*d,
    3*d,
    -r + 2*d,
 ];
 
 module tile() {
     linear_extrude(4) {
         scale(10) polygon(points);
     }
 }
 
 tile();