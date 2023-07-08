#define VIDEO_ADDRESS 0xb8000

extern "C" void main() {
	// char* msg = "Hello World!";
	// int offset = 0x00140;
	// for(int i = 0; i < 13; i++) {
	// 	*(char*)(VIDEO_ADDRESS + offset + i*2) = msg[i];
	// }
	*(char*)(VIDEO_ADDRESS) = 'X';
}