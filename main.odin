package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"

import pt "path_tracer"

/*
	Use a right-handed coordinate system, where y points up, x to the
	right, and z outward.
*/

IMAGE_WIDTH  :: 400
IMAGE_HEIGHT :: int(IMAGE_WIDTH / pt.ASPECT_RATIO)

MAX_DEPTH         ::  50
SAMPLES_PER_PIXEL :: 100

main :: proc() {
	camera := pt.init_camera()

	world: [dynamic]pt.Sphere
	defer delete(world)

	material_ground: pt.Material = pt.Lambertian{pt.Color{0.8, 0.8, 0}}
	material_center: pt.Material = pt.Dielectric{1.5}
	material_left: pt.Material = pt.Dielectric{1.5}
	material_right: pt.Material = pt.metal(pt.Color{0.8, 0.6, 0.2}, 1)

	append(&world, pt.Sphere{pt.Point3{0, -100.5, -1}, 100, &material_ground})
	append(&world, pt.Sphere{pt.Point3{0, 0, -1}, 0.5, &material_center})
	append(&world, pt.Sphere{pt.Point3{-1, 0, -1}, 0.5, &material_left})
	append(&world, pt.Sphere{pt.Point3{1, 0, -1}, 0.5, &material_right})

	// Write PPM (Portable Pixmap Format) header, where 255 represents
	// maximum value of a color channel.
	fmt.printf("P3\n%i %i\n255\n", IMAGE_WIDTH, IMAGE_HEIGHT)

	// Write pixels in rows from left to right, top to bottom.
	for j := IMAGE_HEIGHT - 1; j >= 0; j -= 1 {
		fmt.eprintf("\rscanlines remaining: %3i", j)
		for i := 0; i < IMAGE_WIDTH; i += 1 {
			// Sample each pixel several times and sum the colors
			// of their rays.
			pixel_color := pt.Color{}
			for s in 0..<SAMPLES_PER_PIXEL {
				// Together, u and v represent the ray endpoint
				// on the screen.
				u := (f64(i) + rand.float64())  / f64(IMAGE_WIDTH - 1)
				v := (f64(j) + rand.float64()) / f64(IMAGE_HEIGHT - 1)
				r := pt.get_ray(&camera, u, v)
				pixel_color += ray_color(&r, world, MAX_DEPTH)
			}

			// Use the average color of all samples in the image.
			pt.write_color(pixel_color, SAMPLES_PER_PIXEL);
		}
	}
	fmt.eprintln()
}

lerp :: #force_inline proc(start_value, end_value: pt.Color, t: f64) -> pt.Color {
	return (1 - t) * start_value + t * end_value
}

ray_color :: proc(r: ^pt.Ray, world: [dynamic]pt.Sphere, depth: int) -> pt.Color {
	WHITE :: pt.Color{1, 1, 1}
	BLUE  :: pt.Color{0.5, 0.7, 1.0}

	// Limit recursion.
	if depth <= 0 do return pt.Color{}

	rec: pt.Hit_Record
	if pt.hit(world, r, 0.0001, math.INF_F64, &rec) {
		scattered: pt.Ray
		attenuation: pt.Color

		if pt.scatter(rec.material, r, &scattered, &rec, &attenuation) {
			return attenuation * ray_color(&scattered, world, depth - 1)
		}
		return {}
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
