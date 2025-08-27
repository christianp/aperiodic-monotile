cutter_thickness = 1;
base_thickness = 3;
size = 50;
depth = 20;

r = [1,0];
u = [cos(60),sin(60)];
d = [cos(60),-sin(60)];

hat = [
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
 
module tile(points) {
    scale(size) translate(-r) polygon(points);
}

module outline(thickness) {
    difference() {
        #minkowski() { tile(hat); circle(thickness); };
        tile(hat);
    }
}

 
translate([0,0,depth])
rotate([180,0,0]) {
    linear_extrude(depth) outline(cutter_thickness);
    translate([0,0,depth]) linear_extrude(1) outline(base_thickness);
}
