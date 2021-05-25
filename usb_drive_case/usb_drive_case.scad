// Configurable USB Drive case for 3D printing.
// Made by Julian G, 2021-05-25

/* [Generation options] */
generate_case = true;
generate_cover = true;
debug_show_body_and_plug = true;

// Render the cover above the case
show_preview = false;
preview_distance = 7;

/* [USB Port hole] */
port_width = 12.8;
port_height = 4.75;
port_length = 15.5;
// Distance of the port to the bottom of the body
port_z_offset = -0.5;
// How much the port is pushed into the body. Allows to lower the case at the port. Only applicable with port_z_offset < 0
port_in_body_length = 6.1;
// Width and height tolerance for the port lid on the cover
port_lid_tolerance = 0.1;

/* [Inner dimensions] */
body_width = 16.8;
body_length = 48.85;
body_height = 5.6;

/* [Outter dimensions] */
case_thickness = 2.2;
top_cover_height = 1.5;

/* [Case Label] */
add_case_label = true;
label_text = "OMEGALUL";
label_font = "Liberation Sans:style=bold";
label_size = 5.5;
label_extrude_depth = 0.5;

/* [Frame dimensions] */
frame_thickness = 1.1;
frame_height = 1.5;
frame_height_tolerance = 0.05;

// helper variables
outter_width = body_width + case_thickness*2;
outter_length = body_length + case_thickness*2;
outter_case_height = body_height + case_thickness;
port_lid_height = body_height - port_height - port_z_offset - port_lid_tolerance + case_thickness/2;
echo(str("port_lid_height=", port_lid_height));
port_lid_width = port_width - port_lid_tolerance;



module body()
{
	cube([body_width, body_length, body_height], center=true);
}

module port(make_high = true)
{
	tempHeightOffset = make_high ? outter_case_height : 0;
	translate([0, (body_length+port_length-port_in_body_length)/2, (body_height - port_height)/-2 + port_z_offset + tempHeightOffset/2])
	cube([port_width, port_length+port_in_body_length, port_height+tempHeightOffset], center=true);
}

module case()
{
	// translate([0, 0, wall / (-2)])
	difference() {
		cube([outter_width, outter_length, outter_case_height], center=true);
		translate([0, frame_thickness / -2, (outter_case_height - frame_height)/2])
		frame_cube(fix_openscad_bs_z = true);
	}
}

module case_label()
{
	translate([0, 0, 0.1])
	linear_extrude(height = label_extrude_depth + 0.1)
	text(
		text = label_text,
		valign = "center",
		halign = "center",
		font = label_font,
		size = label_size
	);
}

module frame_cube(fix_openscad_bs_z = false)
{
	// because open scad visual glitches
	heightOffset = fix_openscad_bs_z ? 1 : 0;
	translate([0, 0, heightOffset/2])
	cube([
		outter_width - frame_thickness*2,
		outter_length - frame_thickness*3,
		frame_height + heightOffset
	], center=true);
}

module frame_inner()
{
	translate([0, frame_thickness / 2 + 0.5, 0])
	cube([
		body_width,
		body_length + 1,
		frame_height * 1.1
	], center=true);
}

module top_cover()
{
	union()
	{
		cube([outter_width, outter_length, top_cover_height], center=true);
		translate([0, (outter_length-case_thickness)/2, (top_cover_height+port_lid_height)/2])
		cube([port_lid_width, case_thickness, port_lid_height], center=true);
	}
}

module main_case()
{
	difference()
	{
		case();
		body();
		port();
		if (add_case_label)
		{
			translate([0, 0, outter_case_height/-2 + label_extrude_depth])
			rotate([0, 180, 90])
			case_label();
		}
	}
}

module main_cover()
{
	union()
	{
		translate([0, frame_thickness / -2, frame_height - frame_height_tolerance])
		difference() {
			frame_cube();
			frame_inner();
		}
		top_cover();
	}
}


// ================== RENDERING ==================

if (debug_show_body_and_plug)
{
	% union()
	{
		port(false);
		body();
	}
}

if (generate_case)
{
	main_case();
}

if (generate_cover)
{
	if (show_preview)
	{
		translate([0,0, outter_case_height + preview_distance])
		rotate([0, 180, 0])
		main_cover();
	}
	else
	{
		translate([outter_width * -2, 0, 0])
		main_cover();
	}
}

