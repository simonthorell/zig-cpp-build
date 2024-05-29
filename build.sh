#!/bin/ash
# Ensure script is executable: chmod +x build.sh

# Create the build directory if it does not exist
mkdir -p ./bin/firmware ./bin/linux ./bin/macos ./bin/windows

# Create hex and elf binaries (using musl libc)
zig c++ -target x86_64-linux-musl -O3 -I include/ src/main.cpp -o bin/firmware/app.elf
objcopy -O ihex bin/firmware/app.elf bin/firmware/app.hex

# Build for Linux (x86_64)
zig c++ -target x86_64-linux-musl -O3 -I include/ src/main.cpp -o bin/linux/app_x86_64-linux

# Build for MacOS (aarch64)
zig c++ -target aarch64-macos -O3 -I include/ src/main.cpp -o bin/macos/app_aarch64-macos

# Build for Windows (x86_64)
zig c++ -target x86_64-windows-gnu -O3 -I include/ src/main.cpp -o bin/windows/app_x86_64-windows.exe

# Clean up the build cache (will slow down subsequent builds)
# rm -rf zig-cache