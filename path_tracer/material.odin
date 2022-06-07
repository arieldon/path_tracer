package path_tracer

import "core:fmt"
import "core:math/linalg"

Material :: union #no_nil {
	Lambertian,
	Metal,
}

Lambertian :: struct {
	albedo: Color,
}

Metal :: struct {
	albedo: Color,
}

scatter :: proc(
	material: ^Material, r, scattered: ^Ray, rec: ^Hit_Record, attenuation: ^Color,
) -> bool {
	if material == nil do panic("Unable to process nil material.")

	switch m in material {
	case Lambertian:
		return scatter_lambertain(&m, r, scattered, rec, attenuation)
	case Metal:
		return scatter_metal(&m, r, scattered, rec, attenuation)
	}

	unreachable()
}

@private
scatter_lambertain :: proc(
	material: ^Lambertian, r, scattered: ^Ray, rec: ^Hit_Record, attenuation: ^Color,
) -> bool {
	scatter_direction := rec.normal + generate_random_vector_in_unit_sphere()

	// If the random unit vector exactly opposes the normal vector, they
	// sum to zero. Manually set the scatter direction in this case to
	// prevent undesirable behavior.
	if near_zero(scatter_direction) do scatter_direction = rec.normal

	scattered^ = Ray{rec.p, scatter_direction}
	attenuation^ = material.albedo
	return true
}

@private
scatter_metal :: proc(
	material: ^Metal, r, scattered: ^Ray, rec: ^Hit_Record, attenuation: ^Color,
) -> bool {
	reflected := reflect(linalg.normalize(r.direction), rec.normal)
	scattered^ = Ray{rec.p, reflected}
	attenuation^ = material.albedo
	return linalg.dot(scattered.direction, rec.normal) > 0
}
