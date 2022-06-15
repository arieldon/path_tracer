package path_tracer

import "core:fmt"
import "core:math/linalg"
import "core:strings"

write_color :: proc(builder: ^strings.Builder, pixel_color: Color, samples_per_pixel: uint) {
	// Assuming samples_per_pixel > 1, average several colors to blend
	// foreground with background and create smoother edges, i.e. perform
	// antialiasing. Take the square root to correct gamma.
	average_color := linalg.sqrt(pixel_color * (1.0 / f64(samples_per_pixel)))

	// Translate each color channel from a value between 0 and 1 to a value
	// between 0 and 255.
	r := int(256 * clamp(average_color.r, 0.0, 0.999))
	g := int(256 * clamp(average_color.g, 0.0, 0.999))
	b := int(256 * clamp(average_color.b, 0.0, 0.999))

	// Write the translated color channels to standard output, 1 pixel per
	// line.
	fmt.sbprintln(builder, r, g, b)
}
