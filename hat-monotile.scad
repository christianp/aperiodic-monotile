a = 100;
c = cos(60);
s = sin(60);
h = a / c;
b = h * s;


points = [
    [0,0],
    [0,b],
    [a,b],
    [a + a*c, b + a*s],
    [a + h, b],
    [a + h, 0],
    [2*a + h, 0],
    [2*a + h + a*c, -a*s],
    [a + h, -b],
    [a+h-b*s, -b + b*c],
    [a, -b],
    [-a, -b],
    [-a-a*c, -b+a*s]
];

linear_extrude(50) {
    polygon(points);
}