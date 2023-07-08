#define VGA_BUFFER_ADDRESS 0xB8000
#define VGA_ROWS 25
#define VGA_COLUMNS 80

int row = 2;
int col = 0;

void updateCursorPosition(int row, int column) {
    int offset = (row * VGA_ROWS) + column;
	offset = 0;

    asm volatile(
		// Write the high byte of the offset to port 0x3D4
        "mov $0x3D4, %%dx; "
        "mov $0x0F, %%al; "
        "out %%al, %%dx; "

 		// Write the high byte of the offset
        "inc %%dx; "
        "mov %0, %%al; "
        "out %%al, %%dx; "

		// Write the low byte of the offset to port 0x3D5
        "mov $0x3D5, %%dx; "
        "mov $0x0E, %%al; "
        "out %%al, %%dx; "

		// Write the low byte of the offset
        "inc %%dx; "
        "mov %1, %%al; "
        "out %%al, %%dx"

        : 
        : "r"((unsigned char)(offset >> 8)), "r"((unsigned char)(offset & 0xFF))
        : "%al", "%dx"
    );
}

void print_str(char *str_p, int length)
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
	//updateCursorPosition(row, col);
}

void debug_print_str(char *str_p, int length) {
	char *vga_buffer = (char *)(VGA_BUFFER_ADDRESS + row * VGA_COLUMNS * 2 + col * 2);
	for (int i = 0; i < length; i++)
	{
		vga_buffer[i * 2] = str_p[i];
		vga_buffer[i * 2 + 1] = 0x0F; // White on black
	}
}

extern "C" void main()
{
	// Print OK on the third line
	char *hello_world = "Hello World!";
	print_str(hello_world, 13);

	int old_row = row;
	int old_col = col;
	debug_print_str("Row: ", 5);
}