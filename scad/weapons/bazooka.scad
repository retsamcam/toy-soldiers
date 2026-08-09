// Toy bazooka — shoulder tube for the heavy trooper, printed lying flat.
include <../lib/soldier.scad>

THK = 9;

module rrect(x0, y0, x1, y1, r=1.5)
    translate([(x0+x1)/2, (y0+y1)/2])
        offset(r=r) square([x1-x0-2*r, y1-y0-2*r], center=true);

linear_extrude(THK)
    union() {
        rrect( 0, -5, 64, 5, 3);    // main tube
        rrect(56, -7, 64, 7, 2);    // muzzle flare
        rrect( 0, -7,  6, 7, 2);    // exhaust flare
        rrect(26,  5, 32, 9);       // sight block
    }

grip_bar(36, -3);
