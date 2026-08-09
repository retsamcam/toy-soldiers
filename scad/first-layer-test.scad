// First-layer test tile — PRINT THIS BEFORE ANYTHING ELSE (~5 min).
// A single 0.2mm layer over a wide area: the only honest way to judge
// Z-offset. Big flat patch in the middle, one pad per corner so you can
// see whether the bed is level as well as whether the height is right.
//
// Good first layer: solid, faintly glossy, lines fused with no gaps, and it
// peels off in one piece. Bad: separate round strands, gaps, or it drags along
// behind the nozzle.

LAYER = 0.2;
SPAN  = 60;   // corner-to-corner spread
PAD   = 16;

linear_extrude(LAYER) {
    square([30, 30], center=true);
    for (x = [-1, 1], y = [-1, 1])
        translate([x * SPAN/2, y * SPAN/2])
            square([PAD, PAD], center=true);
}
