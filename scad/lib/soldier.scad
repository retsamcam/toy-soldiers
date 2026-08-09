// toy-soldiers shared library
// All figures and weapons include this file. The grip interface constants
// are the contract: any weapon whose bar uses GRIP_BAR_D fits any figure
// whose hand uses GRIP_HOLE_D / GRIP_SLOT_W.

$fn = $preview ? 32 : 64;

// ---------------------------------------------------------------
// Grip interface — shared contract between figures and weapons
// ---------------------------------------------------------------
GRIP_BAR_D  = 5.6;  // weapon grip-bar diameter
GRIP_HOLE_D = 6.0;  // hand hole diameter (0.4mm clearance for FDM)
GRIP_SLOT_W = 5.3;  // C-opening width; bar snaps through the front
HAND_OD     = 11;   // hand outer diameter
HAND_H      = 9;    // hand height
GRIP_BAR_L  = 14;   // standard bar length (sticks out below the hand)

// ---------------------------------------------------------------
// Figure proportions (~70mm tall incl. base, +Y is forward)
// ---------------------------------------------------------------
BASE_D  = 26;  BASE_H  = 4;
LEG_H   = 22;  LEG_D   = 9;  HIP_X = 5.5;   // leg centre offset from middle
TORSO_H = 24;  TORSO_W = 20; TORSO_WAIST = 16; TORSO_D = 12;
HEAD_D  = 14;  NECK_H  = 3;

HIP_Z      = BASE_H + LEG_H;                 // 26
TORSO_Z0   = HIP_Z - 1;                      // torso overlaps hips 1mm
TORSO_Z1   = TORSO_Z0 + TORSO_H;             // 49
SHOULDER_Z = TORSO_Z1 - 3;                   // 46
SHOULDER_X = TORSO_W/2 + 1;                  // arm root
HEAD_CZ    = TORSO_Z1 + NECK_H + HEAD_D/2;   // head centre

// ---------------------------------------------------------------
// Primitives
// ---------------------------------------------------------------
module rounded_box(size, r=2)
    hull()
        for (x=[-1,1], y=[-1,1], z=[-1,1])
            translate([x*(size[0]/2-r), y*(size[1]/2-r), z*(size[2]/2-r)])
                sphere(r=r);

module limb(a, b, ra=4.5, rb=4)   // thick tapered limb between two points
    hull() { translate(a) sphere(r=ra); translate(b) sphere(r=rb); }

// ---------------------------------------------------------------
// Body parts
// ---------------------------------------------------------------
module base()
    cylinder(d1=BASE_D, d2=BASE_D-2, h=BASE_H);

module leg(x)
    union() {
        translate([x, 0, BASE_H-1]) cylinder(d=LEG_D, h=LEG_H+2);
        // boot: rests on the base, so no overhang
        translate([x, 3.5, BASE_H + 2.5]) rounded_box([LEG_D+1, 13, 5], 2);
    }

module torso()
    hull() {
        translate([0, 0, TORSO_Z0 + 2])
            rounded_box([TORSO_WAIST, TORSO_D-1, 4], 2);
        translate([0, 0, TORSO_Z1 - 2.5])
            rounded_box([TORSO_W, TORSO_D, 5], 2);
    }

module head() {
    // stout neck; the sphere's underside meets it at <45deg so no supports
    translate([0, 0, TORSO_Z1 - 1]) cylinder(d=9.5, h=NECK_H + 3);
    translate([0, 0, HEAD_CZ]) sphere(d=HEAD_D);
}

module helmet()
    translate([0, 0, HEAD_CZ + 1]) {
        difference() {
            sphere(d=HEAD_D + 3.5);
            translate([0, 0, -HEAD_D/2]) cube(HEAD_D*2, center=true);
        }
        // brim with 45-degree underside chamfer
        cylinder(d1=HEAD_D + 1, d2=HEAD_D + 5, h=2);
    }

module cap()   // officer's peaked cap
    translate([0, 0, HEAD_CZ + HEAD_D/2 - 3.5]) {
        cylinder(d1=HEAD_D - 0.5, d2=HEAD_D + 1.5, h=4);
        translate([0, 0, 4]) cylinder(d=HEAD_D + 2, h=1.5);
        // peak: wedge jutting over the face, 45deg chamfered underside
        hull() {
            translate([0, HEAD_D/2 - 2, 1.25]) cube([11, 2, 2.5], center=true);
            translate([0, HEAD_D/2 + 3, 2.25]) cube([9, 1, 1.2], center=true);
        }
    }

module backpack()
    translate([0, -TORSO_D/2, SHOULDER_Z - 6])
        hull() {   // sloped underside back to the torso — printable
            translate([0, -1, -4]) rounded_box([13, 2, 4], 1);
            translate([0, -4, 2]) rounded_box([14, 6, 10], 2);
        }

// C-shaped grip hand, hole axis vertical, opening faces +Y (forward)
module grip_hand()
    difference() {
        cylinder(d=HAND_OD, h=HAND_H, center=true);
        cylinder(d=GRIP_HOLE_D, h=HAND_H + 2, center=true);
        translate([0, HAND_OD/4 + 0.5, 0])
            cube([GRIP_SLOT_W, HAND_OD/2 + 2, HAND_H + 2], center=true);
    }

module fist()
    sphere(d=9);

// ---------------------------------------------------------------
// Arms — s = +1 right, -1 left. Poses avoid >45-degree overhangs.
// ---------------------------------------------------------------
module arm(s, pose) {
    sh = [s*SHOULDER_X, 0, SHOULDER_Z];

    if (pose == "grip_side") {          // hand at the hip
        w = [s*(SHOULDER_X + 3), 4, SHOULDER_Z - 14];
        limb(sh, w);
        translate(w + [0, 1, -4]) grip_hand();
    }
    else if (pose == "grip_forward") {  // hand forward at waist height
        w = [s*(SHOULDER_X + 1), 9, SHOULDER_Z - 12];
        limb(sh, w);
        translate(w + [0, 2, -4]) grip_hand();
    }
    else if (pose == "grip_up") {       // bent arm, hand at shoulder height
        e = [s*(SHOULDER_X + 2), 3, SHOULDER_Z - 11];
        w = [s*(SHOULDER_X + 2), 9, SHOULDER_Z - 2];
        limb(sh, e);
        limb(e, w, 4, 4);
        translate(w + [0, 2, 2]) grip_hand();
    }
    else if (pose == "fist_side") {
        w = [s*(SHOULDER_X + 3), 3, SHOULDER_Z - 15];
        limb(sh, w);
        translate(w + [0, 0, -3]) fist();
    }
    else if (pose == "fist_forward") {
        w = [s*(SHOULDER_X + 1), 8, SHOULDER_Z - 13];
        limb(sh, w);
        translate(w + [0, 2, -2]) fist();
    }
    else if (pose == "point_up") {      // raised arm, ~40 degrees off vertical
        w = [s*(SHOULDER_X + 5), 6, SHOULDER_Z + 9];
        limb(sh, w);
        translate(w) sphere(d=8);
        translate(w) rotate([-40, s*15, 0]) cylinder(d=5, h=7);
    }
}

// ---------------------------------------------------------------
// Assembled soldier
// ---------------------------------------------------------------
module soldier(right_arm="grip_side", left_arm="fist_side",
               headgear="helmet", pack=false) {
    base();
    leg(-HIP_X); leg(HIP_X);
    torso();
    head();
    if (headgear == "helmet") helmet();
    if (headgear == "cap") cap();
    if (pack) backpack();
    arm( 1, right_arm);
    arm(-1, left_arm);
}

// ---------------------------------------------------------------
// Weapon helper — weapons are modelled in PRINT orientation:
// lying flat on the bed (z=0), length along X, "up in use" is +Y.
// The bar rests tangent on the bed so nothing floats.
// ---------------------------------------------------------------
module grip_bar(x, y_top, len=GRIP_BAR_L)
    translate([x, y_top, GRIP_BAR_D/2])
        rotate([90, 0, 0]) cylinder(d=GRIP_BAR_D, h=len);
