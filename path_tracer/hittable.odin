package path_tracer

import "core:math/linalg"

Hit_Record :: struct {
	p: Point3,
	normal: Vector3,
	t: f64,
	front_face: bool,
}

set_face_normal :: #force_inline proc(rec: ^Hit_Record, r: ^Ray, outward_normal: ^Vector3) {
	front_face := linalg.dot(r.direction, outward_normal^) < 0
	rec.normal = front_face ? outward_normal^ : -outward_normal^
}

hit :: proc(world: [dynamic]Sphere, r: ^Ray, t_min, t_max: f64, rec: ^Hit_Record) -> bool {
	tmp_rec: Hit_Record
	closest_hit := t_max
	hit_anything := false

	for _, i in world {
		if hit_sphere(&world[i], r, t_min, closest_hit, &tmp_rec) {
			hit_anything = true
			closest_hit = tmp_rec.t
			rec^ = tmp_rec
		}
	}

	return hit_anything
}