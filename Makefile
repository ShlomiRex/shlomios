gnu_gcc := "$(HOME)/my_tools/bin/i686-elf-gcc"
gnu_ld := "$(HOME)/my_tools/bin/i686-elf-ld"

all: compile run

compile:
# kernel.o
	$(gnu_gcc) -nostdlib -nodefaultlibs -ffreestanding -m32 -g -c "kernel.cpp" -o "kernel.o"
# kernel_entry.o
	nasm "kernel_entry.asm" -f elf -o "kernel_entry.o"
# kernel.bin - link kernel_entry.o and kernel.o
	$(gnu_ld) -o "full_kernel.bin" -nostdlib -Ttext 0x1000 "kernel_entry.o" "kernel.o" --oformat binary
# boot.bin - bootloader
	nasm "bootsector.asm" -f bin -o "boot.bin"
# everything.bin - bootloader + kernel
	cat "boot.bin" "full_kernel.bin" > "everything.bin"
# zeroes.bin - zeroes
	nasm "zeroes.asm" -f bin -o "zeroes.bin"
# os.bin - everything + zeroes
	cat "everything.bin" "zeroes.bin" > "os.bin"
# run

run:
	qemu-system-x86_64 -drive format=raw,file="os.bin",index=0,if=floppy

dump_kernel:
# View what the kernel does in assembly
	$(HOME)/my_tools/i686-elf/bin/objdump -D -b binary -mi386 -s -S -f full_kernel.bin