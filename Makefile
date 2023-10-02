gnu_gcc := "$(HOME)/my_tools/bin/i686-elf-gcc"
gnu_ld := "$(HOME)/my_tools/bin/i686-elf-ld"

src_kernel_dir := src/kernel
src_bootloader_dir := src/bootloader
build_dir := build

all: build run

build:
# kernel.o
	$(gnu_gcc) -nostdlib -nodefaultlibs -ffreestanding -m32 -g -c "$(src_kernel_dir)/kernel.cpp" -o "$(build_dir)/kernel.o"
# kernel_entry.o
	nasm "$(src_bootloader_dir)/kernel_entry.asm" -f elf -o "$(build_dir)/kernel_entry.o"
# kernel.bin - link kernel_entry.o and kernel.o
	$(gnu_ld) -o "$(build_dir)/full_kernel.bin" -nostdlib -Ttext 0x1000 "$(build_dir)/kernel_entry.o" "$(build_dir)/kernel.o" --oformat binary
# boot.bin - bootloader
	nasm -i$(src_bootloader_dir) "$(src_bootloader_dir)/bootsector.asm" -f bin -o "$(build_dir)/boot.bin"
# everything.bin - bootloader + kernel
	cat "$(build_dir)/boot.bin" "$(build_dir)/full_kernel.bin" > "$(build_dir)/everything.bin"
# zeroes.bin - zeroes
	nasm -i$(src_bootloader_dir) "$(src_bootloader_dir)/zeroes.asm" -f bin -o "$(build_dir)/zeroes.bin"
# os.bin - everything + zeroes
	cat "$(build_dir)/everything.bin" "$(build_dir)/zeroes.bin" > "$(build_dir)/os.bin"
# run

run:
	qemu-system-x86_64 -drive format=raw,file="$(build_dir)/os.bin",index=0,if=floppy

dump_kernel:
# View what the kernel does in assembly
	$(HOME)/my_tools/i686-elf/bin/objdump -D -b binary -mi386 -s -S -f $(build_dir)/full_kernel.bin

clean:
	rm -rf $(build_dir)/*