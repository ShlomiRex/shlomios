CXX := "$(HOME)/my_tools/bin/i686-elf-gcc"
LD := "$(HOME)/my_tools/bin/i686-elf-ld"
CXXFLAGS := -nostdlib -nodefaultlibs -ffreestanding -m32 -g

SRC_DIR := src/kernel
src_bootloader_dir := src/bootloader
BUILD_DIR := build

SOURCES = $(wildcard $(SRC_DIR)/*.cpp)
HEADERS = $(wildcard $(INCLUDE_DIR)/*.h)
OBJECTS = $(patsubst $(SRC_DIR)/%.cpp,$(SRC_DIR)/%.o,$(SOURCES))

KERNEL_OBJ = kernel.o

all: prep build link build_image run

test:
	@echo "Sources:"
	@echo $(SOURCES)
	@echo "Headers:"
	@echo $(HEADERS)
	@echo "Objects:"
	@echo $(OBJECTS)

prep:
	@echo "Preparing build directory..."
	mkdir -p build

build: $(OBJECTS)

# General rule for building objects for CPP files (for kernel object)
$(SRC_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

link: $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $(BUILD_DIR)/$(KERNEL_OBJ)

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

	@echo "\nBuild complete! Run 'make run' to run the OS."

run:
	qemu-system-x86_64 -drive format=raw,file="$(BUILD_DIR)/os.bin",index=0,if=floppy

# dump_kernel:
# # View what the kernel does in assembly
# 	$(HOME)/my_tools/i686-elf/bin/objdump -D -b binary -mi386 -s -S -f $(BUILD_DIR)/full_kernel.bin

clean:
	rm -rf $(BUILD_DIR)/*
	rm -rf $(SRC_DIR)/*.o