CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump
CFLAGS = -march=rv32i -mabi=ilp32 -O0 -nostdlib -ffreestanding
LDFLAGS = -T linker.ld

SOURCE = testcases/fib.c

ELF = program.elf
IMG = loadfile_all.img
DUMP = program.dump

all: compile

compile: $(IMG)

$(ELF): $(SOURCE) linker.ld
	$(CC) $(CFLAGS) $(LDFLAGS) $(SOURCE) -o $(ELF)

$(IMG): $(ELF)
	$(OBJCOPY) -O verilog $(ELF) $(IMG)
	$(OBJDUMP) -d $(ELF) > $(DUMP)

clean:
	rm -f $(ELF) $(IMG) $(DUMP)

disasm: $(DUMP)
	@less $(DUMP)