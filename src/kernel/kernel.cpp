#define VGA_BUFFER_ADDRESS 0xB8000
#define VGA_ROWS 25
#define VGA_COLUMNS 80

int row = 0;
int col = 0;

void outb(unsigned short port, unsigned char val)
{
	asm volatile("outb %0, %1"
				 :
				 : "a"(val), "Nd"(port));
}

void updateCursorPosition(int row, int column)
{
	unsigned short position = (row * 80) + column;
	// cursor LOW port to vga INDEX register
	outb(0x3D4, 0x0F);
	outb(0x3D5, (unsigned char)(position & 0xFF));
	// cursor HIGH port to vga INDEX register
	outb(0x3D4, 0x0E);
	outb(0x3D5, (unsigned char)((position >> 8) & 0xFF));
}

void print_str(char const *str_p, int length)
{
	char *vga_buffer = (char *)(VGA_BUFFER_ADDRESS);
	for (int i = 0; i < length; i++)
	{
		if (str_p[i] == '\n')
		{
			row++;
			col = 0;
			continue;
		}
		vga_buffer[(row * VGA_COLUMNS + col) * 2] = str_p[i];
		vga_buffer[(row * VGA_COLUMNS + col) * 2 + 1] = 0x0F; // White on black
		col++;
		if (col >= VGA_COLUMNS)
		{
			col = 0;
			row++;
		}
		if (row >= VGA_ROWS)
		{
			row = 0;
		}
	}
	updateCursorPosition(row, col);
}

void print_char(char c)
{
	char *vga_buffer = (char *)(VGA_BUFFER_ADDRESS);
	vga_buffer[(row * VGA_COLUMNS + col) * 2] = c;
	vga_buffer[(row * VGA_COLUMNS + col) * 2 + 1] = 0x0F; // White on black
	col++;
	if (col >= VGA_COLUMNS)
	{
		col = 0;
		row++;
	}
	if (row >= VGA_ROWS)
	{
		row = 0;
	}
	updateCursorPosition(row, col);
}

void clear_screen()
{
	char *vga_buffer = (char *)(VGA_BUFFER_ADDRESS);
	for (int i = 0; i < VGA_ROWS * VGA_COLUMNS; i++)
	{
		vga_buffer[i * 2] = ' ';
		vga_buffer[i * 2 + 1] = 0x0F; // White on black
	}
	row = col = 0;
	updateCursorPosition(0, 0);
}

extern "C" int main()
{
	clear_screen();
	print_char('O');
	print_char('K');
	print_char(' ');
	print_char('@');

	return 0;
}