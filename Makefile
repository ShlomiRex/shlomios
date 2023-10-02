CXX := $(HOME)/my_tools/bin/i686-elf-gcc
LD := $(HOME)/my_tools/bin/i686-elf-ld

CXXFLAGS := -nostdlib -nodefaultlibs -ffreestanding -m32 -g
LDFLAGS := -melf_i386 -Ttext 0x1000

src_kernel_dir := src/kernel
src_bootloader_dir := src/bootloader
BUILD_DIR := build

# Find all source files, including in sub-directories
SOURCES := $(shell find $(src_kernel_dir) -name "*.cpp")

# Objects - map .cpp extension to .o extension
OBJECTS := $(patsubst $(src_kernel_dir)/%.cpp, $(src_kernel_dir)/%.o, $(SOURCES))

all: clean prep build link build_image run

prep:
	mkdir -p $(BUILD_DIR)

echo_build:
	@echo "Building..."

build: $(OBJECTS) echo_build
	@echo "Build complete"

link: $(OBJECTS)
	@echo "Linking..."
	$(LD) $(LDFLAGS) $^ -o $(BUILD_DIR)/kernel.o
	@echo "Linking complete"


# Build final OS image (bootloader + kernel)
build_image:
# kernel_entry.o
	nasm "$(src_bootloader_dir)/kernel_entry.asm" -f elf -o "$(BUILD_DIR)/kernel_entry.o"
# kernel.bin - link kernel_entry.o and kernel.o
	$(LD) -o "$(BUILD_DIR)/full_kernel.bin" -nostdlib -Ttext 0x1000 "$(BUILD_DIR)/kernel_entry.o" "$(BUILD_DIR)/kernel.o" --oformat binary
# boot.bin - bootloader
	nasm -i$(src_bootloader_dir) "$(src_bootloader_dir)/bootsector.asm" -f bin -o "$(BUILD_DIR)/boot.bin"
# everything.bin - bootloader + kernel
	cat "$(BUILD_DIR)/boot.bin" "$(BUILD_DIR)/full_kernel.bin" > "$(BUILD_DIR)/everything.bin"
# zeroes.bin - zeroes
	nasm -i$(src_bootloader_dir) "$(src_bootloader_dir)/zeroes.asm" -f bin -o "$(BUILD_DIR)/zeroes.bin"
# os.bin - everything + zeroes
	cat "$(BUILD_DIR)/everything.bin" "$(BUILD_DIR)/zeroes.bin" > "$(BUILD_DIR)/os.bin"

run:
	qemu-system-x86_64 -drive format=raw,file="$(BUILD_DIR)/os.bin",index=0,if=floppy

dump_kernel:
# View what the kernel does in assembly
	$(HOME)/my_tools/i686-elf/bin/objdump -D -b binary -mi386 -s -S -f $(BUILD_DIR)/full_kernel.bin

clean:
	rm -rf ./$(BUILD_DIR)/*
	find ./$(src_kernel_dir) -name "*.o" -type f -delete
	@echo "Clean complete"
