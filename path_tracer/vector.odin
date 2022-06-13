package path_tracer

import "core:math/linalg"
import "core:math/rand"

Vector3 :: distinct [3]f64
Point3  :: Vector3
Color   :: Vector3

generate_random_vector :: #force_inline proc() -> (v: Vector3) {
	v.x = rand.float64_range(-1, 1)
	v.y = rand.float64_range(-1, 1)
	v.z = rand.float64_range(-1, 1)
	return
}

generate_random_vector_range :: proc(lo, hi: f64) -> (v: Vector3) {
	v.x = rand.float64_range(lo, hi)
	v.y = rand.float64_range(lo, hi)
	v.z = rand.float64_range(lo, hi)
	return
}

generate_random_vector_in_unit_sphere :: proc() -> (p: Vector3) {
	for {
		// Generate a random point within a unit radius sphere by
		// rejection; that is, reject points within a unit cube until a
		// point falls within the bounds of a unit sphere.
		p = generate_random_vector()
		if linalg.length2(p) >= 1 do continue
		return
	}
}

generate_random_vector_in_unit_disk :: proc() -> (p: Vector3) {
	for {
		// Generate a random point within a unit disk by rejection;
		// that is, reject points within a unit cube until a point
		// falls within the bounds of a unit disk.
		p = {rand.float64_range(-1, 1), rand.float64_range(-1, 1), 0}
		if linalg.length2(p) >= 1 do continue
		return
	}
}

generate_random_unit_vector :: proc() -> (p: Vector3) {
	return linalg.normalize(generate_random_vector_in_unit_sphere())
}

generate_random_vector_in_hemisphere :: proc(normal: Vector3) -> (v: Vector3) {
	v = generate_random_vector_in_unit_sphere()
	if linalg.dot(v, normal) <= 0.0 do v *= -1
	return
}

near_zero :: #force_inline proc(v: Vector3) -> bool {
	s := 1e-8
	return abs(v.x) < s && abs(v.y) < s && abs(v.z) < s
}

reflect :: #force_inline proc(v, n: Vector3) -> Vector3 {
	return v - 2 * linalg.dot(v, n) * n
}

refract :: proc(uv, n: Vector3, etai_over_etat: f64) -> Vector3 {
	cos_theta := min(linalg.dot(-uv, n), 1)
	r_out_perpendicular := etai_over_etat * (uv + cos_theta * n)
	r_out_parallel := -linalg.sqrt(abs(1 - linalg.length2(r_out_perpendicular))) * n
	return r_out_perpendicular + r_out_parallel
}
