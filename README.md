# VeriVerto
A single-cycle RISC-V CPU implementation in Verilog

## Architecture
    - Single-cycle datapath
    - ISA: RISC-V RV32I (32 bit base int)
    - Memory: 64KB instruction memory, 64KB data memory

## Progress
- [x] ALU
    - [x] Addition (ADD, ADDI)
    - [x] Subtraction (SUB)
    - [x] Bitwise AND (AND, ANDI)
    - [x] Bitwise OR (OR, ORI)
    - [ ] barrel shifter
- [x] Register File
    - [x] 32 registers × 32 bits
    - [x] Dual read ports
    - [x] Single write port
    - [x] x0 hardwired to zero
- [x] Instruction Memory
    - [x] 64KB capacity
    - [x] Word-aligned addressing
    - [x] Asynchronous read
- [x] Data Memory
    - [x] 64KB capacity
    - [x] Word-aligned addressing
    - [x] Synchronous write, asynchronous read
    - [x] MemRead/MemWrite control
- [x] ALU Control Unit
    - [x] Two-level control decode
    - [x] ALUOp interpretation
    - [x] funct3/funct7 decoding
    - [x] Support for R-type and I-type operations
- [ ] Immediate Generator
  - [ ] I-type immediate extraction
  - [ ] S-type immediate extraction
  - [ ] B-type immediate extraction
  - [ ] U-type immediate extraction
  - [ ] J-type immediate extraction
  - [ ] Sign extension logic
- [ ] Control Unit
  - [x] Opcode decoding
  - [ ] Control signal generation (ALUSrc, MemtoReg, RegWrite, etc.)
  - [ ] Branch control logic
- [ ] Program Counter (PC)
  - [x] PC increment (+4)
  - [ ] Branch target calculation
  - [ ] Jump target calculation
  - [x] PC update logic
