package main

import "core:fmt"

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
			// Calculate each color channel between 0 and 1,
			// inclusive.
			r := f64(i) / (IMAGE_WIDTH - 1)
			g := f64(j) / (IMAGE_HEIGHT - 1)
			b := 0.25

			// Format the previous calculations as integers between
			// 0 and 255.
			ir := int(255.999 * r)
			ib := int(255.999 * b)
			ig := int(255.999 * g)

			fmt.println(ir, ig, ib)
		}
	}
	fmt.eprintln()
}
