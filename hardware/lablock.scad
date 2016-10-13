use <publicDomainGearV1.1.scad>

$fn = 100;

dummy = 0.1;
clearance = 0.2;

//m = 1.5; // gear module (smaller variant)
m = 2; // gear module (current testing variant)
gearDistance = 2; // spacing between gears (z-axis)

// dimensions to fit gear on locking cylinder 
lockBoltDia = 8;
lockBoltFlattening = 7;

// covering rosette
rosetteBoreDistance = 38;

lockGearSmallTeeth = 12;
lockGearSmallThickness = 5+gearDistance;

lockGearBigTeeth = 48;
lockGearBigThickness = 5;

endstopGearTeeth = 4*lockGearSmallTeeth;
endstopGearThickness = lockGearSmallThickness-gearDistance;
endstopGearBore = 6;
endstopGearOptoBore = 6;
endstopGearOptoDistance = 3;

transmissionGearTeeth = 12;
transmissionGearThickness = lockGearBigThickness+gearDistance;

beltDiameter = 4;
pulleyClearance = 1;

pulleyDiameter = (pitch_radius(PI*m,lockGearBigTeeth)+pitch_radius(PI*m,transmissionGearTeeth)-pitch_radius(PI*m,lockGearSmallTeeth)-pitch_radius(PI*m,1)-pulleyClearance)-beltDiameter/2;
pulleyThickness = lockGearSmallThickness-gearDistance;
pulleyBore = 6;

bearingOuterDia = 13+0.1;
bearingInnerDia = 6+0.5;
bearingHeight = 5;

module lockGearSmall() {
    translate([0, 0, lockGearSmallThickness/2]) {
        difference() {
            rotate([0, 0, 360/lockGearSmallTeeth/2])
                gear(PI*m, lockGearSmallTeeth, lockGearSmallThickness, 0);
            difference() {
                cylinder(r=lockBoltDia/2, h=lockGearSmallThickness+2*dummy, center=true);
                translate([lockBoltFlattening,0,0]) cube([lockBoltDia, lockBoltDia, lockGearSmallThickness], center=true);
            }
        }
    }
}

module lockGearBig() {
    translate([0,0,lockGearSmallThickness+lockGearBigThickness/2]) 
        difference() {
            gear(PI*m, lockGearBigTeeth, lockGearBigThickness, 0);
            difference() {
                cylinder(r=lockBoltDia/2, h=lockGearSmallThickness+2*dummy, center=true);
                translate([lockBoltFlattening,0,0]) cube([lockBoltDia, lockBoltDia, lockGearSmallThickness], center=true);
            }
        }
}

/*
module endstopRack() {
    rackTeeth = lockGearSmallTeeth*2.5;
    rackHeight = 2.5;
    rackThickness = lockGearSmallThickness;
    translate([-PI*m*rackTeeth/2, -pitch_radius(PI*m,lockGearSmallTeeth)-clearance, rackThickness/2])
        rack(PI*m, rackTeeth, rackThickness, 2*(outer_radius(PI*m,1)-pitch_radius(PI*m,1))+rackHeight);
*/

//echo (pitch_radius(PI*m,lockGearSmallTeeth)+pitch_radius(PI*m,endstopGearTeeth));

module endstopGear() {
    //translate([0,-pitch_radius(PI*m,lockGearSmallTeeth)-pitch_radius(PI*m,endstopGearTeeth),0])
    translate([pitch_radius(PI*m,lockGearSmallTeeth)+pitch_radius(PI*m,endstopGearTeeth),0,0]) {
        difference() {
            union() {
                translate([0,0,endstopGearThickness/2]) gear(PI*m, endstopGearTeeth, endstopGearThickness, 0);
                cylinder(r=bearingOuterDia/2+2, h=lockGearBigThickness+lockGearSmallThickness);
            }
            for(z=[0,lockGearBigThickness+lockGearSmallThickness-bearingHeight+dummy]) {
                translate([0,0,-dummy+z]) cylinder(r=bearingOuterDia/2, h=bearingHeight+dummy);
            }
            translate([0,0,-dummy]) cylinder(r=bearingInnerDia/2, h=lockGearBigThickness+lockGearSmallThickness+2*dummy);
            cylinder(r=endstopGearBore/2, h=endstopGearThickness+2*dummy, center=true);
            translate([pitch_radius(PI*m, endstopGearTeeth) - (outer_radius(PI*m, endstopGearTeeth) - pitch_radius(PI*m, endstopGearTeeth)) - endstopGearOptoBore/2-endstopGearOptoDistance,0,endstopGearThickness/2])
                cylinder(r=endstopGearOptoBore/2, h=endstopGearThickness+2*dummy, center=true);
        }
    }
}

module pulley() {
    translate([0,pitch_radius(PI*m,lockGearBigTeeth)+pitch_radius(PI*m,transmissionGearTeeth), 0]) {
        difference() {
            union() {
                difference() {
                    cylinder(r=pulleyDiameter, h=pulleyThickness);
                    translate([0, 0, pulleyThickness/2]) rotate_extrude(angle=360, convexity=2) {
                        translate([pulleyDiameter, 0]) circle(r=beltDiameter/2, $fn=4);         
                    }
                }
                translate([0,0,transmissionGearThickness/2+pulleyThickness])
                    rotate([0,0,360/transmissionGearTeeth/2]) 
                        gear(PI*m, transmissionGearTeeth, transmissionGearThickness, 0);
            }
            translate([0,0,-dummy]) cylinder(r=pulleyBore/2, h=transmissionGearThickness+pulleyThickness+2*dummy);
            translate([0,0,transmissionGearThickness+pulleyThickness-bearingHeight]) cylinder(r=bearingOuterDia/2, h=bearingHeight+dummy);
            translate([0,0,-dummy]) cylinder(r=bearingOuterDia/2, h=bearingHeight+dummy);
        }
    }
}

motorAxis = 4;
motorPulleyThickness = 0.8;

module motorPulley() {
    difference() {
        cylinder(r=motorAxis/2+motorPulleyThickness+beltDiameter/2, h=pulleyThickness, center=true);
        rotate_extrude(angle=360, convexity=2) {
            translate([beltDiameter/2+motorAxis/2+motorPulleyThickness, 0]) circle(r=beltDiameter/2, $fn=4);
        }
        cylinder(r=motorAxis/2, h=pulleyThickness+2*dummy, center=true);
    }
}

/*
sectorGearTeeth = lockGearSmallTeeth*3;
rotate([0, 0, 360/sectorGearTeeth/2]) translate([0,-40,0]) gear(PI*m, sectorGearTeeth, thickness, hole, 0,sectorGearTeeth-(lockGearSmallTeeth*2.5));
*/


//projection(cut = true) {
    lockGearSmall();
    lockGearBig();

    echo(outer_radius(PI*m, lockGearBigTeeth));

    endstopGear();
    pulley();
    //motorPulley();
//}
