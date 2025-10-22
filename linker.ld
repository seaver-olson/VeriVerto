/* I redid the linker script because the one provided had arm written all over it*/
ENTRY(_start)
OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH("riscv")

MEMORY 
{   
    /*note for future self: please check that origin of dmem isnt inside imem*/
    IMEM (rx) : ORIGIN = 0x0, LENGTH = 16K
    DMEM (rwx) : ORIGIN = 0x00010000, LENGTH = 48K
}   

SECTIONS
{
    . = 0;
    .text : {*(.text.init) *(.text*) } > IMEM
    .rodata : { *(.rodata*) } > IMEM
    .data : { *(.data*) } > DMEM
    _start_bss = . ;
    .bss : { *(.bss) } > DMEM
    _end_bss = ADDR(.bss) + SIZEOF(.bss);
    . = ALIGN(16);
    . = ORIGIN(DMEM) + LENGTH(DMEM);
    
     _stack_top = .;

}