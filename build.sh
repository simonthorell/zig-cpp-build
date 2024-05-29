#!/bin/ash
# Ensure script is executable: chmod +x build.sh

# Create the build directory if it does not exist
echo -e "\033[0;36mCreating bin directories...\033[0m\c"
mkdir -p ./bin/firmware ./bin/linux ./bin/macos ./bin/windows
echo -e "\t\033[1;32mSuccess!\033[0m"

# Build for Embedded ARM (ARMv7)
echo -e "\033[0;36mCompiling for ARM 32-bit... \033[0m\c"
zig c++ -target arm-linux-gnueabihf -O3 -I include/ src/main.cpp -o bin/firmware/app_armv7.elf
objcopy -O ihex bin/firmware/app_armv7.elf bin/firmware/app_armv7.hex
echo -e "\t\033[1;32mSuccess!\033[0m"

# Build for Embedded ARM (ARMv8)
echo -e "\033[0;36mCompiling for ARM 64-bit... \033[0m\c"
zig c++ -target aarch64-linux-gnu -O3 -I include/ src/main.cpp -o bin/firmware/app_armv8.elf
objcopy -O ihex bin/firmware/app_armv8.elf bin/firmware/app_armv8.hex
echo -e "\t\033[1;32mSuccess!\033[0m"

# Build for Linux (x86_64 and ARM64)
echo -e "\033[0;36mCompiling for Linux x86_64... \033[0m\c"
zig c++ -target x86_64-linux-musl -O3 -I include/ src/main.cpp -o bin/linux/app_x86_64
echo -e "\t\033[1;32mSuccess!\033[0m"
echo -e "\033[0;36mCompiling for Linux ARM64... \033[0m\c"
zig c++ -target aarch64-linux -O3 -I include/ src/main.cpp -o bin/linux/app_arm64
echo -e "\t\033[1;32mSuccess!\033[0m"

# Build for MacOS (x86_64 and aarch64)
echo -e "\033[0;36mCompiling for MacOS x86_64... \033[0m\c"
zig c++ -target x86_64-macos -O3 -I include/ src/main.cpp -o bin/macos/app_x86_64
echo -e "\t\033[1;32mSuccess!\033[0m"
echo -e "\033[0;36mCompiling for MacOS ARM64... \033[0m\c"
zig c++ -target aarch64-macos -O3 -I include/ src/main.cpp -o bin/macos/app_arm64
echo -e "\t\033[1;32mSuccess!\033[0m"

# Build for Windows (x86_64)
echo -e "\033[0;36mCompiling for Win x86_64... \033[0m\c"
zig c++ -target x86_64-windows-gnu -O2 -I include/ src/main.cpp -o bin/windows/app_x86_64.exe
echo -e "\t\033[1;32mSuccess!\033[0m"
echo -e "\033[1;32mCompilation complete!\033[0m"

# Clean up the build cache (will slow down subsequent builds)
# rm -rf zig-cache