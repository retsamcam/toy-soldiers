// Fit-test coupon — PRINT THIS FIRST (10 min, a few grams).
// One grip hand + one bar. If the bar won't snap in or is too loose,
// tune GRIP_HOLE_D / GRIP_SLOT_W in lib/soldier.scad before printing figures.
include <lib/soldier.scad>

translate([0, 0, HAND_H/2]) grip_hand();

// bar with a flat base tab so it prints upright next to the hand
translate([20, 0, 0]) {
    cylinder(d=GRIP_BAR_D, h=GRIP_BAR_L);
    cylinder(d1=12, d2=GRIP_BAR_D, h=2);
}
