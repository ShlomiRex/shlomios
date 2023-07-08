gnu_gcc := "$(HOME)/my_tools/bin/i686-elf-gcc"
gnu_ld := "$(HOME)/my_tools/bin/i686-elf-ld"

all: compile run

compile:
# kernel.o
	$(gnu_gcc) -nostdlib -nodefaultlibs -ffreestanding -m32 -g -c "src/kernel.cpp" -o "build/kernel.o"
# kernel_entry.o
	nasm "src/kernel_entry.asm" -f elf -o "build/kernel_entry.o"
# kernel.bin - link kernel_entry.o and kernel.o
	$(gnu_ld) -o "build/full_kernel.bin" -nostdlib -Ttext 0x1000 "build/kernel_entry.o" "build/kernel.o" --oformat binary
# boot.bin - bootloader
	nasm -isrc/ "src/bootsector.asm" -f bin -o "build/boot.bin"
# everything.bin - bootloader + kernel
	cat "build/boot.bin" "build/full_kernel.bin" > "build/everything.bin"
# zeroes.bin - zeroes
	nasm -isrc "src/zeroes.asm" -f bin -o "build/zeroes.bin"
# os.bin - everything + zeroes
	cat "build/everything.bin" "build/zeroes.bin" > "build/os.bin"
# run

run:
	qemu-system-x86_64 -drive format=raw,file="build/os.bin",index=0,if=floppy

dump_kernel:
# View what the kernel does in assembly
	$(HOME)/my_tools/i686-elf/bin/objdump -D -b binary -mi386 -s -S -f build/full_kernel.bin