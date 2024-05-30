#!/bin/ash
# Ensure script is executable: chmod +x build.sh

# Create the build directory if it does not exist
echo -e "\033[0;36mCreating bin directories...\033[0m\t\c"
mkdir -p ./bin/firmware ./bin/linux ./bin/macos ./bin/windows
echo -e "\033[1;32mSuccess!\033[0m"

# Find all .cpp files in the src directory
SOURCES=$(find src -name "*.cpp")

# Build for Embedded ARM (ARMv7)
echo -e "\033[0;36mCompiling for ARM 32-bit... \033[0m\t\c"
zig c++ -target arm-linux-gnueabihf -O3 -I include/ $SOURCES -o bin/firmware/app_armv7.elf
objcopy -O ihex bin/firmware/app_armv7.elf bin/firmware/app_armv7.hex
echo -e "\033[1;32mSuccess!\033[0m  \033[0m(Raspberry Pi 2/3/4)"

# Build for Embedded ARM (ARMv8)
echo -e "\033[0;36mCompiling for ARM 64-bit... \033[0m\t\c"
zig c++ -target aarch64-linux-gnu -O3 -I include/ $SOURCES -o bin/firmware/app_armv8.elf
objcopy -O ihex bin/firmware/app_armv8.elf bin/firmware/app_armv8.hex
echo -e "\033[1;32mSuccess!\033[0m  \033[0m(Raspberry Pi 3/4/5)"

# Build for Linux (x86_64 and ARM64)
echo -e "\033[0;36mCompiling for Linux x86_64... \033[0m\t\c"
zig c++ -target x86_64-linux-musl -O3 -I include/ $SOURCES -o bin/linux/app_x86_64
echo -e "\033[1;32mSuccess!\033[0m"
echo -e "\033[0;36mCompiling for Linux ARM64... \033[0m\t\c"
zig c++ -target aarch64-linux-gnu -O3 -I include/ $SOURCES -o bin/linux/app_arm64
echo -e "\033[1;32mSuccess!\033[0m"

# Build for MacOS (x86_64 and aarch64)
echo -e "\033[0;36mCompiling for MacOS x86_64... \033[0m\t\c"
zig c++ -target x86_64-macos -O3 -I include/ $SOURCES -o bin/macos/app_x86_64
echo -e "\033[1;32mSuccess!\033[0m"
echo -e "\033[0;36mCompiling for MacOS ARM64... \033[0m\t\c"
zig c++ -target aarch64-macos -O3 -I include/ $SOURCES -o bin/macos/app_arm64
echo -e "\033[1;32mSuccess!\033[0m"

# Build for Windows (x86_64) - (compiler -w flag is not working, hence redirect stderr to /dev/null)
# TODO: checkout Zig source code and try to figure out a fix for the -w flag
echo -e "\033[0;36mCompiling for Win x86_64... \033[0m\t\c"
echo -e "LLD Link...\c"
zig c++ -target x86_64-windows-gnu -O2 -I include/ $SOURCES -o bin/windows/app_x86_64.exe 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "\b\b\b\b\b\b\b\b\b\b\b\033[1;32mSuccess!\033[0m\033[K"
    echo -e "\033[1;32mCompilation complete!\033[0m"
else
    echo -e "\033[1;31mCompilation failed!\033[0m"
fi

# Clean up the build cache (will slow down subsequent builds)
# rm -rf zig-cache