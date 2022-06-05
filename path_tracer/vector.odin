package path_tracer

import "core:math/linalg"
import "core:math/rand"

Vector3 :: distinct [3]f64
Point3  :: Vector3
Color   :: Vector3

generate_random_vector_in_unit_sphere :: proc() -> (p: Vector3) {
	for {
		// Generate a random point within a unit radius sphere by
		// rejection; that is, reject points within a unit cube until a
		// point falls within the bounds of a unit sphere.
		p = rand.float64_range(-1, 1)
		if linalg.length2(p) >= 1 do continue
		return
	}
}
