// Toy pistol — chunky sidearm, printed lying flat.
// The grip bar doubles as the pistol grip.
include <../lib/soldier.scad>

THK = 6;

module rrect(x0, y0, x1, y1, r=1.5)
    translate([(x0+x1)/2, (y0+y1)/2])
        offset(r=r) square([x1-x0-2*r, y1-y0-2*r], center=true);

linear_extrude(THK)
    union() {
        rrect( 0,  4, 22, 10, 2);   // slide
        rrect(22,  5.5, 26, 8.5);   // muzzle
        rrect( 2,  0, 20, 5);       // frame
        rrect(14, -2, 19, 1);       // trigger guard block
    }

grip_bar(7, 2);
