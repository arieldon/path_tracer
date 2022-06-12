package path_tracer

import "core:math"
import "core:math/linalg"

// Focal length refers to the distance between the projection plane and the
// projection point.
FOCAL_LENGTH    :: 1.0

Camera :: struct {
	origin, lower_left_corner: Point3,
	horizontal, vertical: Vector3,
}

init_camera :: proc(
	look_from, look_at: Point3, view_up: Vector3, vertical_fov, aspect_ratio: f64,
) -> (c: Camera) {
	theta := math.to_radians(vertical_fov)
	h := math.tan(theta / 2)
	viewport_height := 2 * h
	viewport_width := aspect_ratio * viewport_height

	w := linalg.normalize(look_from - look_at)
	u := linalg.normalize(linalg.cross(view_up, w))
	v := linalg.cross(w, u)

	c.origin = look_from
	c.horizontal = viewport_width * u
	c.vertical = viewport_height * v
	c.lower_left_corner = c.origin - c.horizontal / 2 - c.vertical / 2 - w
	return
}

get_ray :: proc(c: ^Camera, s, t: f64) -> (r: Ray) {
	r.origin = c.origin
	r.direction = c.lower_left_corner + s * c.horizontal + t * c.vertical - c.origin
	return
}


