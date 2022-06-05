package main

import "core:fmt"
import "core:math"
import "core:math/linalg"

import pt "path_tracer"

/*
	Use a right-handed coordinate system, where y points up, x to the
	right, and z outward.
*/

ASPECT_RATIO :: 16.0 / 9.0
IMAGE_WIDTH  :: 400
IMAGE_HEIGHT :: int(IMAGE_WIDTH / ASPECT_RATIO)

// Viewport refers to the part of the screen that contains the portion of the
// world to display.
VIEWPORT_WIDTH  :: ASPECT_RATIO * VIEWPORT_HEIGHT
VIEWPORT_HEIGHT :: 2.0

// Focal length refers to the distance between the projection plane and the
// projection point.
FOCAL_LENGTH    :: 1.0

ORIGIN     :: pt.Point3{0, 0, 0}
HORIZONTAL :: pt.Vector3{VIEWPORT_WIDTH, 0, 0}
VERTICAL   :: pt.Vector3{0, VIEWPORT_HEIGHT, 0}

// This calculation cannot be stored as a constant since Odin does not
// currently support array programming at compile time.
lower_left := ORIGIN - HORIZONTAL / 2 - VERTICAL / 2 - pt.Vector3{0, 0, FOCAL_LENGTH}

main :: proc() {
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

			r := pt.Ray{
				ORIGIN,
				lower_left + u * HORIZONTAL + v * VERTICAL - ORIGIN,
			}

			pt.write_color(ray_color(r))
		}
	}
	fmt.eprintln()
}

hit_sphere :: proc(center: pt.Point3, radius: f64, r: pt.Ray) -> bool {
	/*
		The equation of a sphere with radius r centered at some point
		(a, b, c) may be calculated with the following equation:

			(x - a)^2 + (y - b)^2 + (z - c)^2 = r^2

		The vector from center C (a, b, c) to some point P (x, y, z)
		may be expressed as (P - C). Therefore, the vector form of the
		equation of a sphere suitable for Odin's array programming
		appears as such:

			(P - C)^2 = r^2

		Any point P that satisfies this equation sits on the sphere. A
		point within the sphere returns a value less than r^2; a point
		outside the sphere returns a value greater than r^2; a point on
		the sphere returns r^2.

		A ray represents points with equation P(t) = A + tb.

			(P(t) - C)^2 = (A + tb - C)^2 = (A + tb - C)(A + tb - C) = r^2

		Expand and move all terms to the left side of the equation.
		Note, the period or dot "." indicates a dot product of vectors.

			t^2(b . b) + 2t(b . (A - C)) + (A - C) . (A - C) - r^2 = 0

		Then, to determine whether a ray intersects a sphere at some
		point, solve the equation directly above for t using the
		quadratic equation -- all other variables are known.

		The variables in the code map directly to the variables in the
		equation above:

			dot(oc, oc) - radius * radius ->  (A - C) - r^2
			dot(r.direction, r.direction) ->  (b . b)
			     2 * dot(r.direction, oc) -> 2(b . (A - C))
			           r.origion - center ->  (A - C)
	*/

	// Cache parts of the discriminant.
	oc := r.origin - center
	a := linalg.dot(r.direction, r.direction)
	b := 2 * linalg.dot(r.direction, oc)
	c := linalg.dot(oc, oc) - radius * radius

	// The discriminant is the part under the root in the quadratic
	// equation.
	discriminant := b * b - 4 * a * c;

	// A positive discriminant indicates two real solutions exist.
	return discriminant > 0
}

lerp :: #force_inline proc(start_value, end_value: pt.Color, t: f64) -> pt.Color {
	return (1 - t) * start_value + t * end_value
}

ray_color :: proc(r: pt.Ray) -> pt.Color {
	RED   :: pt.Color{1, 0, 0}
	WHITE :: pt.Color{1, 1, 1}
	BLUE  :: pt.Color{0.5, 0.7, 1.0}

	// Place a sphere and return red instead of a blend of white and blue
	// when a ray intersects it.
	if hit_sphere(pt.Point3{0, 0, -1}, 0.5, r) do return RED

	// Scale each coordinate of the vector to a value between -1 and 1.
	unit_direction := linalg.normalize(r.direction)

	// Scale to a value between 0 and 1 instead of -1 and 1.
	t := 0.5 * (unit_direction.y + 1)

	// Linearly blend white and blue as a function of the (normalized)
	// y-coordinate. In graphics, programmers refer to this calculation as
	// a linear interpolation or, more colloquially, lerp.
	return lerp(WHITE, BLUE, t)
}
