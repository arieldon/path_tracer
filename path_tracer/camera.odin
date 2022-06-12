package path_tracer

import "core:math"
import "core:math/linalg"

Camera :: struct {
	origin, lower_left_corner: Point3,
	horizontal, vertical, u, v, w: Vector3,
	lens_radius: f64,
}

init_camera :: proc(
	look_from, look_at: Point3,
	view_up: Vector3,
	vertical_fov, aspect_ratio, aperture, focus_distance: f64,
) -> (c: Camera) {
	theta := math.to_radians(vertical_fov)
	h := math.tan(theta / 2)
	viewport_height := 2 * h
	viewport_width := aspect_ratio * viewport_height

	c.w = linalg.normalize(look_from - look_at)
	c.u = linalg.normalize(linalg.cross(view_up, c.w))
	c.v = linalg.cross(c.w, c.u)

	c.origin = look_from
	c.horizontal = focus_distance * viewport_width * c.u
	c.vertical = focus_distance * viewport_height * c.v
	c.lower_left_corner = c.origin - c.horizontal / 2 - c.vertical / 2 - focus_distance * c.w
	c.lens_radius = aperture / 2
	return
}

get_ray :: proc(c: ^Camera, s, t: f64) -> (r: Ray) {
	rd := c.lens_radius * generate_random_vector_in_unit_disk()
	offset := c.u * rd.x + c.v * rd.y

	r.origin = c.origin + offset
	r.direction = c.lower_left_corner + s * c.horizontal + t * c.vertical - c.origin - offset
	return
}
