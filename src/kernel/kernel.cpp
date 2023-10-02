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

void print_str(const char *str, int len)
{
	for (int i = 0; i < len; i++)
	{
		print_char(str[i]);
	}
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

	
	char const* str = "ABC";
	print_char(str[0]);
	print_char(str[1]);
	print_char(str[2]);
	print_char(str[3]);
	print_char(str[4]);
	print_char(str[5]);
	print_char(str[6]);
	print_char(str[7]);
	print_char(str[8]);
	print_char(str[9]);
	print_char(str[10]);
	print_char(str[11]);

	print_char('A');

	return 0;
}