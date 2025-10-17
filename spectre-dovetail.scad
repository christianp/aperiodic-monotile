use <dovetail.scad>;

// Your amazing design you want to cut
module amazing_design() {
    cube(size=[50, 50, 10], center=true);
}

// First, setup the cutting position: middle cut
position = [0, 0, 0];

// Next, setup the dimension of the cut: use the bounding box of your design
dimension = [50, 15, 100];

// Finally, setup the dovetail:
// - Teeth count
// - Teeth height
// - Teeth Clearance
teeth = [5, 8, 0.5];

// Now, cut !

// Extract the first part...
intersection() {
    amazing_design();
    #cutter(position=[0, 0, 0], dimension=dimension, teeths=teeth, male=true);
}


// ... and the second part
translate([0,10,0])
intersection() {
    amazing_design();
    cutter(position=[0, 0, 0], dimension=dimension, teeths=teeth, male=false);
}
