# RISC-V Instruction Types and Datapath Lifecycle

## CPU Stages
1. **IF** – Instruction Fetch: get instruction from Instruction Memory  
2. **ID** – Instruction Decode: Control Unit checks opcode, ImmGen generates immediate  
3. **EX** – Execute: ALU computes address, arithmetic, comparison, or jump target  
4. **MEM** – Memory Access: read or write Data Memory if needed  
5. **WB** – Write Back: write result to Register File if needed  

---

## Instruction Types

### R-Type (e.g., add, sub, and, or)
- Operands: rs1, rs2  
- Destination: rd  
- Immediate: not used  
- ALUSrc: 0 (use rs2)  
- Memory: not used  
- RegWrite: 1 (ALU result written to rd)  

---

### I-Type (e.g., addi, lw)
- Operands: rs1, imm  
- Destination: rd  
- Immediate: 12-bit signed  
- ALUSrc: 1 (use immediate)  
- Special cases:  
  - lw: MemRead = 1, MemToReg selects memory output  
  - addi: normal ALU writeback  
- RegWrite: 1  

---

### S-Type (e.g., sw)
- Operands: rs1 (base), rs2 (value), imm (offset)  
- Immediate: 12-bit signed  
- ALUSrc: 1 (rs1 + imm)  
- MemWrite: 1 (store rs2 into memory[rs1+imm])  
- RegWrite: 0  

---

### B-Type (e.g., beq, bne)
- Operands: rs1, rs2, imm (branch offset)  
- Immediate: 13-bit signed (PC-relative)  
- ALUOp: compare rs1 vs rs2  
- Branch = 1, AND with ALU Zero flag to decide PC  
- RegWrite: 0  

---

### U-Type (e.g., lui, auipc)
- Operands: 20-bit immediate (shifted left 12)  
- Immediate: 20-bit  
- ALUSrc: depends  
  - lui: imm written directly to rd  
  - auipc: ALU = PC + imm  
- RegWrite: 1  

---

### J-Type (e.g., jal)
- Operands: PC + imm (jump target), write PC+4 to rd  
- Immediate: 20-bit signed (jump offset)  
- ALU: PC + imm  
- Control: sets PC to jump target  
- RegWrite: 1 (stores return address in rd)  

---

## Lifecycle Summary
- Control Unit looks at opcode and sets signals: RegWrite, ALUSrc, MemRead, MemWrite, Branch, MemToReg, ALUOp.  
- ImmGen produces the correct immediate value depending on type.  
- Datapath (ALU, Memory, Register File) executes in one cycle using these signals.  