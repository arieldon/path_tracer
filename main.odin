package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:strings"

import pt "path_tracer"

/*
	Use a right-handed coordinate system, where y points up, x to the
	right, and z outward.
*/

ASPECT_RATIO :: 3 / 2
IMAGE_WIDTH  :: 1200
IMAGE_HEIGHT :: int(IMAGE_WIDTH / ASPECT_RATIO)

MAX_DEPTH         ::  50
SAMPLES_PER_PIXEL :: 500

LOOK_FROM      :: pt.Point3{13, 2, 3}
LOOK_AT        :: pt.Point3{0, 0, 0}
VIEW_UP        :: pt.Vector3{0, 1, 0}
FOCUS_DISTANCE :: 10
APERTURE       :: 0.1

main :: proc() {
	camera := pt.init_camera(
		LOOK_FROM, LOOK_AT, VIEW_UP, 20, ASPECT_RATIO, APERTURE, FOCUS_DISTANCE,
	)

	world: [dynamic]pt.Sphere
	defer delete(world)

	ground_material: pt.Material = pt.Lambertian{pt.Color{0.5, 0.5, 0.5}}
	append(&world, pt.Sphere{pt.Point3{0, -1000, 0}, 1000, &ground_material})

	for a in -11..<11 {
		for b in -11..<11 {
			choose_material := rand.float64()
			center := pt.Point3{
				f64(a) + 0.9 * rand.float64(),
				0.2,
				f64(b) + 0.9 * rand.float64()}

			if linalg.length(center - {4, 0.2, 0}) > 0.9 {
				sphere_material: pt.Material
				if choose_material < 0.8 {
					// Create diffuse sphere.
					u := pt.generate_random_vector()
					v := pt.generate_random_vector()
					sphere_material = pt.Lambertian{u * v}
				} else if choose_material < 0.95 {
					// Create metal sphere.
					albedo := pt.generate_random_vector_range(0.5, 1)
					fuzz := rand.float64_range(0, 0.5)
					sphere_material = pt.metal(albedo, fuzz)
				} else {
					// Create glass sphere.
					sphere_material = pt.Dielectric{1.5}
				}
				append(&world, pt.Sphere{center, 0.2, &sphere_material})
			}
		}
	}

	dielectric: pt.Material = pt.Dielectric{1.5}
	append(&world, pt.Sphere{pt.Point3{0, 1, 0}, 1, &dielectric})

	diffuse: pt.Material = pt.Lambertian{pt.Color{0.4, 0.2, 0.1}}
	append(&world, pt.Sphere{pt.Point3{-4, 1, 0}, 1, &diffuse})

	metal: pt.Material = pt.metal(pt.Color{0.7, 0.6, 0.5}, 0)
	append(&world, pt.Sphere{pt.Point3{4, 1, 0}, 1, &metal})

	// Allocate builder for buffered IO.
	builder := strings.make_builder()
	defer strings.destroy_builder(&builder)

	// Write PPM (Portable Pixmap Format) header, where 255 represents
	// maximum value of a color channel.
	fmt.sbprintf(&builder, "P3\n%i %i\n255\n", IMAGE_WIDTH, IMAGE_HEIGHT)

	// Write pixels in rows from left to right, top to bottom.
	for j := IMAGE_HEIGHT - 1; j >= 0; j -= 1 {
		fmt.eprintf("\rscanlines remaining: %4i", j)
		for i := 0; i < IMAGE_WIDTH; i += 1 {
			// Sample each pixel several times and sum the colors
			// of their rays.
			pixel_color := pt.Color{}
			for s in 0..<SAMPLES_PER_PIXEL {
				// Together, u and v represent the ray endpoint
				// on the screen.
				u := (f64(i) + rand.float64())  / f64(IMAGE_WIDTH - 1)
				v := (f64(j) + rand.float64()) / f64(IMAGE_HEIGHT - 1)

				// Calculate ray from camera to pixel.
				r := pt.get_ray(&camera, u, v)

				// Compute color of ray.
				pixel_color += ray_color(&r, world, MAX_DEPTH)
			}

			// Use the average color of all samples in the image.
			pt.write_color(&builder, pixel_color, SAMPLES_PER_PIXEL);
		}
	}
	fmt.eprintln()

	fmt.println(strings.to_string(builder))
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
