ASM = nasm
CC = gcc
BOOTSTRAP_FILE = bootstrap.asm
INIT_KERNEL_FILES = starter.asm
KERNEL_FILES = main.c
KERNEL_FLAGS = -Wall -m32 -c -ffreestanding -fno-asynchronous-unwind-tables -fno-pie
KERNEL_OBJECT = -o kernel.o
build: $(BOOTSTRAP_FILE) $(KERNEL_FILES)
	$(ASM) -f bin $(BOOTSTRAP_FILE) -o bootstrap.o
	$(ASM) -f elf32 $(INIT_KERNEL_FILES) -o starter.o
	$(CC) $(KERNEL_FLAGS) $(KERNEL_FILES) $(KERNEL_OBJECT)
	"C:\Users\31IMECHAM\i686-elf-tools-windows\bin\i686-elf-ld.exe" -Tlinker.ld starter.o kernel.o -o ShadefenseOSkernel.elf
	objcopy -O binary ShadefenseOSkernel.elf ShadefenseOSkernel.bin
	# The following dd commands require a Unix-like environment (e.g., Git Bash, WSL)
	dd if=bootstrap.o of=kernel.img
	dd seek=1 conv=sync if=ShadefenseOSkernel.bin of=kernel.img bs=512 count=5
	dd seek=6 conv=sync if=/dev/zero of=kernel.img bs=512 count=2046
	# Use -drive for QEMU to specify the image file
	qemu-system-i386 -drive format=raw,file=kernel.img
clean:
	rm -f *.o
	rm -f *.elf
	rm -f *.bin
	rm -f *.img