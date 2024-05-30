#!/bin/ash
# Ensure script is executable: chmod +x build.sh

# Create the build directory if it does not exist
echo -e "\033[0;36mCreating bin directories...\033[0m\t\c"
mkdir -p ./bin/firmware ./bin/linux ./bin/macos ./bin/windows
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mFailed to create directories!\033[0m"
    exit 1
else
    echo -e "\033[1;32mSuccess!\033[0m"
fi

# Initialize counters
passed_count=0
failed_count=0

# Find all .cpp files
SOURCES=$(find src -name "*.cpp")

# Function to compile and handle errors
compile_and_check() {
    local target_arch=$1
    local target_libc=$2
    local output_file=$3
    local objcopy_file=$4
    local info_msg=$5

    echo -e "Compiling for $target_arch...\c"

    # Define success and failure messages dynamically
    success_msg="\r\033[K\033[0;36mCompiling for $target_arch...\033[0m\t\033[1;32mSuccess!\033[0m $info_msg\n"
    failed_msg="\r\033[K\033[0;36mCompiling for $target_arch...\033[0m\t\033[1;31mFailed!\033[0m $info_msg\n"

    # Temporary store stderr and display it if a compilation fails
    stderr_file=$(mktemp)

    zig c++ -target $target_libc -O3 -I include/ $SOURCES -o $output_file 2>$stderr_file
    if [ $? -eq 0 ]; then
        if [ ! -z "$objcopy_file" ]; then
            objcopy -O ihex $output_file $objcopy_file
            if [ $? -eq 0 ]; then
                echo -ne "$success_msg"
                passed_count=$((passed_count + 1))
            else
                echo -ne "$failed_msg"
                echo -e "\033[0;91m$(cat $stderr_file)\033[0m"
                failed_count=$((failed_count + 1))
            fi
        else
            echo -ne "$success_msg"
            passed_count=$((passed_count + 1))
        fi
    else
        echo -ne "$failed_msg"
        echo -e "\033[0;91m$(cat $stderr_file)\033[0m"
        failed_count=$((failed_count + 1))
    fi
    rm -f $stderr_file
}

# Build for Embedded ARM (ARMv7)
compile_and_check "ARM 32-bit" "arm-linux-gnueabihf" "bin/firmware/app_armv7.elf" "bin/firmware/app_armv7.hex" "(Raspberry Pi 2/3/4)"

# Build for Embedded ARM (ARMv8)
compile_and_check "ARM 64-bit" "aarch64-linux-gnu" "bin/firmware/app_armv8.elf" "bin/firmware/app_armv8.hex" "(Raspberry Pi 3/4/5)"

# Build for Linux (x86_64)
compile_and_check "Linux x86_64" "x86_64-linux-musl" "bin/linux/app_x86_64" "" ""

# Build for Linux (ARM64)
compile_and_check "Linux ARM64" "aarch64-linux-gnu" "bin/linux/app_arm64" "" ""

# Build for MacOS (x86_64)
compile_and_check "MacOS x86_64" "x86_64-macos" "bin/macos/app_x86_64" "" ""

# Build for MacOS (ARM64)
compile_and_check "MacOS ARM64" "aarch64-macos" "bin/macos/app_arm64" "" ""

# Build for Windows (x86)
compile_and_check "Windows x86" "x86_64-windows-gnu" "bin/windows/app_x86_64.exe" "" ""

# Print summary and final status
echo -e "\n\033[0;32mPassed compilations: $passed_count\033[0m"
echo -e "\033[0;31mFailed compilations: $failed_count\033[0m"

if [ $failed_count -gt 0 ]; then
    echo -e "\n\033[1;31mCompilation Completed with Errors!\033[0m\n"
    exit 1
else
    echo -e "\n\033[1;32mCompilation Completed Successfully!\033[0m\n"
    exit 0
fi