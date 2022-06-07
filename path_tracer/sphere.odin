package path_tracer

import "core:math/linalg"

Sphere :: struct {
	center: Point3,
	radius: f64,
	material: ^Material,
}

hit_sphere :: proc(s: ^Sphere, r: ^Ray, t_min, t_max: f64, rec: ^Hit_Record) -> bool {
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

			dot(oc, oc) - radius * radius ->  (A - C) - r^2      [c]
			dot(r.direction, r.direction) ->  (b . b)            [a]
			     2 * dot(r.direction, oc) -> 2(b . (A - C))      [b]
			           r.origion - center ->  (A - C)            [ ]

		Because the square length of a vector is the result of the dot
		product of the vector with itself, some code can be simplied
		further:

			length2(oc) - radius * radius -> (A - C) - r^2       [c]
			         length2(r.direction) -> (b . b)             [a]

		Also, since b contains a factor of 2, it's possible to even
		further simplify the quadratic equation as a whole by factoring
		out 2.
	*/

	// Cache parts of the discriminant.
	oc := r.origin - s.center
	a := linalg.length2(r.direction)
	half_b := linalg.dot(oc, r.direction)
	c :=  linalg.length2(oc) - s.radius * s.radius

	// The discriminant is the part under the root in the quadratic
	// equation.
	discriminant := half_b * half_b - a * c;
	if (discriminant < 0) do return false
	sqrtd := linalg.sqrt(discriminant)

	// Use the nearest root within specified range.
	root := (-half_b - sqrtd) / a
	if (root < t_min || t_max < root) {
		root = (-half_b + sqrtd) / a
		if (root < t_min || t_max < root) do return false
	}

	rec.t = root
	rec.p = at(r, rec.t)
	rec.material = s.material
	outward_normal := (rec.p - s.center) / s.radius
	set_face_normal(rec, r, &outward_normal)

	return true
}
