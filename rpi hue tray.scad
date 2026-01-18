rack_width = 254.0; // 10 inch
rack_height = 1.0;  // 1U (44.45 mm)


tolerance = 0.60;   


// Philips Hue (Left)
hue_w = 90.9;  
hue_h = 26.2;  
hue_d = 95.6; 

// Raspberry Pi (Right)
rpi_w = 60.99; 
rpi_h = 27.20;
rpi_d = 95.00; 

air_holes = true; 
print_orientation = true; 

/* [Hidden] */
height = 44.45 * rack_height;
$fn = 64;

module mount_extended_depth() {
    front_thickness = 3.0;
    
    gap = 17.0;
    
    // Recalculate centering
    total_content_w = hue_w + rpi_w + gap;
    start_x = (rack_width - total_content_w) / 2;

    // --- Helper Modules ---
    module capsule_slot(L, H) {
        hull() {
            translate([-L/2 + H/2, 0]) circle(r=H/2);
            translate([L/2 - H/2, 0]) circle(r=H/2);
        }
    }

    module rounded_rect(w, h, r) {
        hull() {
            translate([r, r]) circle(r=r);
            translate([w-r, r]) circle(r=r);
            translate([w-r, h-r]) circle(r=r);
            translate([r, h-r]) circle(r=r);
        }
    }

    // --- MAIN BODY ---
    module main_body() {
        // 1. Front Panel (Faceplate)
        linear_extrude(height = front_thickness) {
            rounded_rect(rack_width, height, 4);
        }
        
        // 2. LEFT STRUCTURE (HUE) - Enclosed Case
        translate([start_x - 4, (height - (hue_h + 8))/2, 0])
            cube([hue_w + 8, hue_h + 8, hue_d]);
            
        // 3. RIGHT STRUCTURE (RPi) - Open Shelf (L-Shape)
        rpi_start_x = start_x + hue_w + gap;
        rpi_y_start = (height - (rpi_h + 8))/2;
        
        // A. Base (Floor)
        translate([rpi_start_x - 4, rpi_y_start, 0])
            cube([rpi_w + 8, 4, rpi_d]); 
            
        // B. Divider Wall (RPi Left)
        translate([rpi_start_x - 4, rpi_y_start, 0])
            cube([4, rpi_h + 8, rpi_d]);
    }

    // --- RACK HOLES (Standard 1U) ---
    module rack_holes() {
        hole_spacing_x = 236.525;
        positions_y = [6.35, 22.225, 38.1];
        
        for (x = [(rack_width - hole_spacing_x)/2, (rack_width + hole_spacing_x)/2]) {
            for (y = positions_y) {
                translate([x, height - y, -1])
                    linear_extrude(height = 20)
                        capsule_slot(10, 6.5);
            }
        }
    }

    // --- CUTOUTS ---
    module cutouts() {
        // 1. LEFT Cutout (HUE)
        translate([start_x, (height - hue_h)/2, -1]) {
            cube([hue_w + tolerance, hue_h + tolerance, hue_d + 5]);
            // Front Lip
            translate([2, 2, 0]) cube([hue_w - 4, hue_h - 4, 10]);
        }
        
        // Hue Button Hole (Centered on slot)
        translate([start_x + hue_w/2, height/2, -1])
            cylinder(h=10, d=35); 

        // 2. RIGHT Cutout (Raspberry Pi)
        translate([start_x + hue_w + gap, (height - rpi_h)/2, -1]) {
            cube([rpi_w + tolerance, rpi_h + tolerance, rpi_d + 5]);
            // RPi Front Lip
            translate([2, 2, 0]) cube([rpi_w - 4, rpi_h - 4, 10]);
        }
    }

    // --- VENTILATION (HUE ONLY) ---
    module honeycomb() {
        hex_size = 10;
        spacing = 14;
        margin = 8; 
        
        module make_grid(w, depth, offset_x) {
            for (ix = [margin : spacing : w - margin]) {
                for (iz = [15 : spacing : depth - 10]) {
                    stagger = (floor(ix/spacing) % 2 == 0) ? spacing/2 : 0;
                    if (iz + stagger < depth - 5) {
                        translate([offset_x + ix, height, iz + stagger])
                            rotate([90, 0, 0])
                                cylinder(d=hex_size, h=100, $fn=6, center=true);
                    }
                }
            }
        }
        make_grid(hue_w, hue_d, start_x);
    }

    // --- ASSEMBLY ---
    translate([-rack_width/2, -height/2, 0]) {
        difference() {
            main_body();
            union() {
                rack_holes();
                cutouts();
                if (air_holes) honeycomb();
            }
        }
    }
}

if (print_orientation) {
    mount_extended_depth();
} else {
    rotate([-90,0,0]) mount_extended_depth();
}