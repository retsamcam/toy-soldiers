// Toy dagger — round grip handle, wide rounded blade. Printed lying flat.
// Handle is the grip bar itself (along X here); held blade-up in the fist.
include <../lib/soldier.scad>

THK = 5.6;

module rrect(x0, y0, x1, y1, r=1.5)
    translate([(x0+x1)/2, (y0+y1)/2])
        offset(r=r) square([x1-x0-2*r, y1-y0-2*r], center=true);

// handle: bare grip bar lying along X, resting on the bed
translate([0, 0, GRIP_BAR_D/2])
    rotate([0, 90, 0]) cylinder(d=GRIP_BAR_D, h=15);

linear_extrude(THK)
    union() {
        rrect(13, -7, 17, 7, 1.5);      // cross-guard
        rrect(16, -4, 40, 4, 3.5);      // blade, fat rounded tip
    }
