package path_tracer

// Aspect ratio refers to the ratio of image width to image height.
ASPECT_RATIO :: 16.0 / 9.0

// Viewport refers to the part of the screen that contains the portion of the
// world to display.
VIEWPORT_WIDTH  :: ASPECT_RATIO * VIEWPORT_HEIGHT
VIEWPORT_HEIGHT :: 2.0

// Focal length refers to the distance between the projection plane and the
// projection point.
FOCAL_LENGTH    :: 1.0

Camera :: struct {
	origin, lower_left_corner: Point3,
	horizontal, vertical: Vector3,
}

init_camera :: proc() -> (c: Camera) {
	c.origin = Point3{0, 0, 0}
	c.horizontal = Vector3{VIEWPORT_WIDTH, 0, 0}
	c.vertical = Vector3{0, VIEWPORT_HEIGHT, 0}
	c.lower_left_corner = c.origin - c.horizontal / 2 - c.vertical / 2 - {0, 0, FOCAL_LENGTH}
	return
}

get_ray :: proc(c: ^Camera, u, v: f64) -> (r: Ray) {
	r.origin = c.origin
	r.direction = c.lower_left_corner + u * c.horizontal + v * c.vertical - c.origin
	return
}


