#include "../drivers/screen.h"
#include "util.h"
// #include "../cpu/isr.h"
// #include "../cpu/idt.h"

void main() {
    clear_screen();
    kprint("Hello, World!1\n");
    kprint("Hello, World!2\n");
    kprint("Hello, World!3\n");
    kprint("Hello, World!4\n");
    kprint("Hello, World!5\n");
    kprint("Hello, World!6\n");
    kprint("Hello, World!7\n");
    kprint("Hello, World!8\n");
    kprint("Hello, World!9\n");
    kprint("Hello, World!10\n");

    isr_install();
    /* Test the interrupts */
    __asm__ __volatile__("int $2");
    __asm__ __volatile__("int $3");
}
