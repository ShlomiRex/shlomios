#include <stdint.h>

#include "string.cpp"

#define VGA_BUFFER_ADDRESS 0xB8000
#define VGA_ROWS 25
#define VGA_COLUMNS 80

uint8_t row = 2;
uint8_t col = 0;

static inline void outb(uint16_t port, uint8_t val)
{
    asm volatile ( "outb %0, %1" : : "a"(val), "Nd"(port) :"memory");
    /* There's an outb %al, $imm8  encoding, for compile-time constant port numbers that fit in 8b.  (N constraint).
     * Wider immediate constants would be truncated at assemble-time (e.g. "i" constraint).
     * The  outb  %al, %dx  encoding is the only option for all other cases.
     * %1 expands to %dx because  port  is a uint16_t.  %w1 could be used if we had the port number a wider C type */
}

void updateCursorPosition(uint8_t row, uint8_t column) {
	unsigned short position = (row * VGA_COLUMNS) + column;

	// cursor LOW port to vga INDEX register
	outb(0x3D4, 0x0F);
	outb(0x3D5, (unsigned char)(position & 0xFF));
	// cursor HIGH port to vga INDEX register
	outb(0x3D4, 0x0E);
	outb(0x3D5, (unsigned char)((position >> 8) & 0xFF));
}

void print_str(char const *str_p, int length)
{
	char *vga_buffer = (char *)(VGA_BUFFER_ADDRESS + row * VGA_COLUMNS * 2 + col * 2);
	for (int i = 0; i < length; i++)
	{
		vga_buffer[i * 2] = str_p[i];
		vga_buffer[i * 2 + 1] = 0x0F; // White on black

		col += 1;

		if (col > VGA_COLUMNS)
		{
			col = 0;
			row++;
		}
	}
	updateCursorPosition(row, col);
}

void clear_screen() {
	char *vga_buffer = (char *)(VGA_BUFFER_ADDRESS);
	for (int i = 0; i < VGA_ROWS * VGA_COLUMNS; i++) {
		vga_buffer[i * 2] = ' ';
		vga_buffer[i * 2 + 1] = 0x0F; // White on black
	}

	// Reset cursor
	row = 0;
	col = 0;
	updateCursorPosition(row, col);
}

extern "C" int main() {
	clear_screen();
	char const *hello_world = "Hello";
	print_str(hello_world, 5);

	String str;
	return 0;
}