package path_tracer

/*
	The function P(t) = A + tb represents a ray mathematically.

		- P represents a point or position along a ray in 3-dimensional
		  space.
		- A represents the origin of the ray.
		- b represents the direction of the ray.
		- t is a parameter that shifts the point along the ray.

	This equation equates to y = mx + b from basic algebra.
*/

Ray :: struct {
	origin: Point3,
	direction: Vector3,
}

// Encode P(t) = A + tb in Odin.
at :: proc(r: ^Ray, t: f64) -> Point3 {
	return r.origin + t * r.direction;
}
