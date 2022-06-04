package path_tracer

import "core:fmt"

write_color :: proc(pixel_color: Color) {
	// Translate each color channel from a value between 0 and 1 to a value
	// between 0 and 255.
	r := int(255.999 * pixel_color.r)
	g := int(255.999 * pixel_color.g)
	b := int(255.999 * pixel_color.b)

	// Write the translated color channels to standard output, 1 pixel per
	// line.
	fmt.println(r, g, b)
}
