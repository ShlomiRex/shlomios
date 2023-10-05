# $@ = target file
# $< = first dependency
# $^ = all dependencies

CXX = $(HOME)/my_tools/bin/i686-elf-gcc
LD = $(HOME)/my_tools/bin/i686-elf-ld

CXXFLAGS = -ffreestanding

DIR_BOOTLOADER = src/bootloader
DIR_KERNEL = src/kernel

all: run

build: os-image.bin

# Notice how dependencies are built as needed
kernel.bin: kernel_entry.o kernel.o
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary

kernel_entry.o: $(DIR_BOOTLOADER)/kernel_entry.asm
	nasm $< -f elf -o $@

kernel.o: $(DIR_KERNEL)/kernel.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Rule to disassemble the kernel - may be useful to debug
kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@

bootsect.bin: $(DIR_BOOTLOADER)/bootsect.asm
	nasm -i$(DIR_BOOTLOADER) $< -f bin -o $@

os-image.bin: bootsect.bin kernel.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-i386 -fda $<

clean:
	rm *.bin *.o *.dis
