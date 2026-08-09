// Toy rifle — blocky Lego-style silhouette, printed lying flat.
// X = barrel direction, +Y = up in use, grip bar hangs -Y.
include <../lib/soldier.scad>

THK = 6;   // body thickness

// rounded rectangle in the XY profile plane
module rrect(x0, y0, x1, y1, r=1.5)
    translate([(x0+x1)/2, (y0+y1)/2])
        offset(r=r) square([x1-x0-2*r, y1-y0-2*r], center=true);

linear_extrude(THK)
    union() {
        rrect( 0, -7,  9, 4, 2);    // stock
        rrect( 8, -3, 36, 4);       // receiver
        rrect(34, -0.5, 58, 3);     // barrel
        rrect(48,  2, 51, 6);       // front sight
        rrect(14,  3, 24, 7, 2);    // carry handle
        rrect(14, -8, 20, -3);      // magazine
    }

grip_bar(28, -2);   // overlaps 2mm into the receiver
