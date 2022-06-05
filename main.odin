package main

import "core:fmt"
import "core:math"
import "core:math/linalg"

import pt "path_tracer"

/*
	Use a right-handed coordinate system, where y points up, x to the
	right, and z outward.
*/

IMAGE_WIDTH  :: 400
IMAGE_HEIGHT :: int(IMAGE_WIDTH / pt.ASPECT_RATIO)

main :: proc() {
	camera := pt.init_camera()

	world: [dynamic]pt.Sphere
	defer delete(world)
	append(&world, pt.Sphere{pt.Point3{0, 0, -1}, 0.5})
	append(&world, pt.Sphere{pt.Point3{0, -100.5, -1}, 100})

	// Write PPM (Portable Pixmap Format) header, where 255 represents
	// maximum value of a color channel.
	fmt.printf("P3\n%i %i\n255\n", IMAGE_WIDTH, IMAGE_HEIGHT)

	// Write pixels in rows from left to right, top to bottom.
	for j := IMAGE_HEIGHT - 1; j >= 0; j -= 1 {
		fmt.eprintf("\rscanlines remaining: %i", j)
		for i := 0; i < IMAGE_WIDTH; i += 1 {
			// Together, u and v represent the ray endpoint on the
			// screen.
			u := f64(i) / f64(IMAGE_WIDTH - 1)
			v := f64(j) / f64(IMAGE_HEIGHT - 1)
			r := pt.get_ray(&camera, u, v)
			pt.write_color(ray_color(&r, world))
		}
	}
	fmt.eprintln()
}

lerp :: #force_inline proc(start_value, end_value: pt.Color, t: f64) -> pt.Color {
	return (1 - t) * start_value + t * end_value
}

ray_color :: proc(r: ^pt.Ray, world: [dynamic]pt.Sphere) -> pt.Color {
	WHITE :: pt.Color{1, 1, 1}
	BLUE  :: pt.Color{0.5, 0.7, 1.0}

	rec: pt.Hit_Record
	if pt.hit(world, r, 0, math.INF_F64, &rec) {
		// Multiply by 0.5 to map each to a value between 0 and 1.
		// Then, map each component of the vector to a color channel.
		return 0.5 * (rec.normal + {1, 1, 1})
	}

	// Scale each coordinate of the vector to a value between -1 and 1.
	unit_direction := linalg.normalize(r.direction)

	// Scale to a value between 0 and 1 instead of -1 and 1.
	t := 0.5 * (unit_direction.y + 1)

	// Linearly blend white and blue as a function of the (normalized)
	// y-coordinate. In graphics, programmers refer to this calculation as
	// a linear interpolation or, more colloquially, lerp.
	return lerp(WHITE, BLUE, t)
}
