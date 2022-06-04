package main

import "core:fmt"

import pt "path_tracer"

main :: proc() {
	IMAGE_WIDTH  :: 256
	IMAGE_HEIGHT :: 256

	// Write PPM (Portable Pixmap Format) header, where 255 represents
	// maximum value of a color channel.
	fmt.printf("P3\n%i %i\n255\n", IMAGE_WIDTH, IMAGE_HEIGHT)

	// Write pixels in rows from left to right, top to bottom.
	for j := IMAGE_HEIGHT - 1; j >= 0; j -= 1 {
		fmt.eprintf("\rscanlines remaining: %i", j)
		for i := 0; i < IMAGE_WIDTH; i += 1 {
			pixel_color := pt.Color{
				f64(i) / (IMAGE_WIDTH - 1),
				f64(j) / (IMAGE_HEIGHT - 1),
				0.25,
			}
			pt.write_color(pixel_color)
		}
	}
	fmt.eprintln()
}
