package path_tracer

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"

Material :: union #no_nil {
	Lambertian,
	Metal,
	Dielectric,
}

Lambertian :: struct {
	albedo: Color,
}

Metal :: struct {
	albedo: Color,
	fuzz: f64,
}

Dielectric :: struct {
	refraction_index: f64,
}

metal :: proc(albedo: Color = {0, 0, 0}, fuzz: f64) -> (m: Metal) {
	m.albedo = albedo
	if fuzz < 1 {
		m.fuzz = fuzz
	} else {
		m.fuzz = 1
	}
	return
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
	case Dielectric:
		return scatter_dielectric(&m, r, scattered, rec, attenuation)
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
	scattered^ = Ray{rec.p, reflected + material.fuzz * generate_random_vector_in_unit_sphere()}
	attenuation^ = material.albedo
	return linalg.dot(scattered.direction, rec.normal) > 0
}

@private
scatter_dielectric :: proc(
	material: ^Dielectric, r, scattered: ^Ray, rec: ^Hit_Record, attenuation: ^Color,
) -> bool {
	attenuation^ = Color{1, 1, 1}

	refraction_ratio := material.refraction_index
	if (rec.front_face) do refraction_ratio = 1 / material.refraction_index

	unit_direction := linalg.normalize(r.direction)
	cos_theta := min(linalg.dot(-unit_direction, rec.normal), 1)
	sin_theta := linalg.sqrt(1 - cos_theta * cos_theta)

	direction := refract(unit_direction, rec.normal, refraction_ratio)
	cannot_refract := refraction_ratio * sin_theta > 1
	reflectance := calculate_reflectance(cos_theta, refraction_ratio) > rand.float64()
	if cannot_refract ||  reflectance {
		direction = reflect(unit_direction, rec.normal)
	}

	scattered^ = Ray{rec.p, direction}
	return true
}

@private
calculate_reflectance :: proc(cosine, reflectance_index: f64) -> f64 {
	// Reflectivity varies with angle. Use Schlick's approximation to
	// calculate this reflectance with reasonable accuracy.
	r0 := (1 - reflectance_index) / (1 + reflectance_index)
	r0 *= r0
	return r0 + (1 - r0) * math.pow(1 - cosine, 5)
}
