package path_tracer

import "core:math"

// Aspect ratio refers to the ratio of image width to image height.
ASPECT_RATIO :: 16.0 / 9.0

// Focal length refers to the distance between the projection plane and the
// projection point.
FOCAL_LENGTH    :: 1.0

Camera :: struct {
	origin, lower_left_corner: Point3,
	horizontal, vertical: Vector3,
}

init_camera :: proc(vertical_fov, aspect_ratio: f64) -> (c: Camera) {
	theta := math.to_radians(vertical_fov)
	h := math.tan(theta / 2)
	viewport_height := 2 * h
	viewport_width := aspect_ratio * viewport_height

	c.origin = Point3{0, 0, 0}
	c.horizontal = Vector3{viewport_width, 0, 0}
	c.vertical = Vector3{0, viewport_height, 0}
	c.lower_left_corner = c.origin - c.horizontal / 2 - c.vertical / 2 - {0, 0, FOCAL_LENGTH}
	return
}

get_ray :: proc(c: ^Camera, u, v: f64) -> (r: Ray) {
	r.origin = c.origin
	r.direction = c.lower_left_corner + u * c.horizontal + v * c.vertical - c.origin
	return
}


