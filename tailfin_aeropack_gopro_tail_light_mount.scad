include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 50;

mount_hole_diameter = 5.5;
mount_hole_padding_diameter = 12;
mount_nut_diameter = 9.2;
mount_nut_height = 2;
mount_fin_middle_width = 3.2;
mount_fin_side_width = 2.75;
mount_fin_side_bottom_width = 4;
mount_fin_diameter = 15;
mount_fin_gap = 2.95;
mount_fin_height_extension = 0.01;
mount_fin_rounding = 0.5;

plate_hole_spacing = 50;
plate_hole_diameter = 5.5;
plate_inner_flare = 1.2;
plate_outer_hole_padding = 8;
plate_depth = 3;
plate_rounding = 6;

/* [Hidden] */

mount_width = 2*mount_fin_side_bottom_width+mount_fin_middle_width+2*mount_fin_gap;
mount_height = mount_fin_diameter;
mount_depth = mount_fin_diameter + mount_fin_height_extension;

plate_outer_height = plate_hole_diameter + plate_outer_hole_padding;
plate_inner_height = mount_fin_diameter;
plate_outer_width = plate_hole_spacing + plate_outer_hole_padding * 2;
plate_inner_width = mount_width + plate_rounding * 2/3;

diff_padding = 0.04;

module mount_fin(top_width, bottom_width, with_nut)
{
  zrot(90)
    down(mount_depth/2)
    diff()
    conv_hull("remove ignore")
    cuboid([mount_fin_diameter, bottom_width, mount_fin_height_extension], anchor = BOTTOM)
    {
      position(BACK)
        cyl(d = mount_fin_diameter, h = top_width, rounding = mount_fin_rounding, anchor = FWD+BOTTOM, orient = FWD)
        {
          attach(BOTTOM, overlap = -diff_padding)
            tag("remove")
            cyl(d = mount_hole_diameter, h = bottom_width+diff_padding*2, anchor = TOP);

          if (with_nut)
          {
            attach(TOP)
              tag("ignore")
              cyl(d1 = mount_fin_diameter-1, d2 = mount_fin_diameter-3.5, h = mount_nut_height, anchor = BOTTOM) {
                attach(CENTER)
                  tag("remove")
                  cyl(d = mount_nut_diameter, h = mount_nut_height+diff_padding, $fn = 6, anchor = CENTER);
              }
          } else if (bottom_width > top_width) {
            attach(TOP)
              tag("remove")
              cyl(d = mount_hole_padding_diameter, h = mount_nut_height, anchor = BOTTOM);
          }
        }
    }
}

module mount() {
  attachable(
    anchor = BOTTOM,
    size = [mount_width, mount_height, mount_depth]
  ) {
    union() {
      mount_fin(mount_fin_middle_width, mount_fin_middle_width, false);

      right(mount_fin_middle_width/2 + mount_fin_gap + mount_fin_side_bottom_width/2)
        mount_fin(mount_fin_side_width, mount_fin_side_bottom_width, true);

      left(mount_fin_middle_width/2 + mount_fin_gap + mount_fin_side_bottom_width/2)
        xflip()
        mount_fin(mount_fin_side_width, mount_fin_side_bottom_width, false);
    }
    children();
  }
}

module plate() {
  plate_path = [
    [0, 0],
    [0, plate_outer_height],
    [(plate_outer_width-plate_inner_width)/2/plate_inner_flare, plate_outer_height],
    [(plate_outer_width-plate_inner_width)/2, plate_inner_height],
    [(plate_outer_width-plate_inner_width)/2+plate_inner_width, plate_inner_height],
    [(plate_outer_width-plate_inner_width)/2+plate_inner_width*plate_inner_flare, plate_outer_height],
    [plate_outer_width, plate_outer_height],
    [plate_outer_width, 0],
  ];

  attachable(
    anchor = BOTTOM,
    size = [plate_outer_width, plate_inner_height, plate_depth],
    cp = [plate_outer_width/2, plate_inner_height/2, plate_depth/2]
  ) {
    diff() {
      offset_sweep(round_corners(plate_path, method = "circle", r = plate_rounding), height = plate_depth);

      tag("remove")
        right(plate_outer_width/2)
        grid_copies(n = [2, 1], spacing = plate_hole_spacing)
        back(plate_outer_height / 2)
        up(plate_depth/2)
        zcyl(d = plate_hole_diameter, h = plate_depth+diff_padding);
    }
    children();
  }
}

plate()
  attach(TOP)
  mount();
