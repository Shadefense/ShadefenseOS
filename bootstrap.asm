start:
	mov ax, 07C0h
	mov ds, ax
	mov si, title_string
	call print_string
	mov si, message_string
	call print_string
	call load_kernel_from_disk
	cli
	lgdt [gdtr - start]        ; Load GDT (if not already done in kernel)
	mov eax, cr0
	or eax, 1
	mov cr0, eax               ; Enter protected mode
	; Set up protected mode segments and stack
	mov ax, 0x10               ; Data segment selector in GDT
	mov ds, ax
	mov ss, ax
	mov esp, 0x9FF00           ; Set up stack just below kernel
	jmp 0x08:0x00009000        ; Far jump to kernel entry (selector:offset)
load_kernel_from_disk:
	mov ax, [current_sector_to_load]
	sub ax, 2
	mov dx, 512d
	mul bx
	mov bx, ax
	mov ax, 0900h
	mov es, ax
	mov ah, 02h
	mov al, 1h
	mov ch, 0h
	mov cl, [current_sector_to_load]
	mov dh, 0h
	mov dl, 80h
	int 13h
	jc kernel_load_error
	sub byte [number_of_sectors_to_load], 1
	add byte [current_sector_to_load], 1
	cmp byte [number_of_sectors_to_load], 0
	jne load_kernel_from_disk
	ret
kernel_load_error:
	mov si, load_error_string
	call print_string
	jmp $
print_string:
	mov ah, 0Eh
print_char:
	lodsb
	cmp al, 0
	je printing_finished
	int 10h
	jmp print_char
printing_finished:
	mov al, 10d ; Print new line
	int 10h
	mov ah, 03h
	mov bh, 0
	int 10h
	mov ah, 02h
	mov dl, 0
	int 10h
	ret
title_string: db 'ShadefenseOS Bootloader', 0
message_string: db 'kernel loading...', 0
load_error_string: db 'Kernel load error', 0
number_of_sectors_to_load: db 15
current_sector_to_load: db 2
times 510-($-$$) db 0
dw 0xAA55

; Minimal GDT and GDTR for protected mode jump
gdt_start:
	dq 0x0000000000000000     ; Null descriptor
	dq 0x00cf9a000000ffff     ; Code segment descriptor
	dq 0x00cf92000000ffff     ; Data segment descriptor
gdt_end:

gdtr:
	dw gdt_end - gdt_start - 1
	dd gdt_start