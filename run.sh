#!/usr/bin/env sh

if [ "$1" = "--debug" ]; then
    odin run main.odin -file -collection:path_tracer=./path_tracer -debug
else
    odin run main.odin -file -collection:path_tracer=./path_tracer -o:speed -no-bounds-check
fi
