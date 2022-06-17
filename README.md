# Path Tracer

An implementation of Peter Shirley's _Ray Tracing in One Weekend_ in Odin.

> At the core, the ray tracer sends rays through pixels and computes the color
> seen in the direction of those rays.

-- Peter Shirley, _Ray Tracing in One Weekend_

Shirley's high-level explanation of a ray tracer may be broken down further
into the following steps:

1. Calculate ray from camera to pixel.
2. Determine which objects this ray hits.
3. Compute a color for that point.

Because this ray tracer, or path tracer more specifically, is an implementation
of Shirley's work, it follows this model.

## Usage

This script serves as a very simple wrapper for the Odin compiler.

```shell
./run.sh
```

## Images

Images output by the ray tracer are available under `images/`.

## Credits

[_Ray Tracing in One Weekend_](https://raytracing.github.io/books/RayTracingInOneWeekend.html)
