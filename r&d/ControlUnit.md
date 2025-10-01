# Control Unit Notes (Single-Cycle RISC-V)

## Inputs
- **opcode** (lowest 7 bits of instruction)
- **funct3**, **funct7** (used later by ALUControl)

## Outputs
- **ALUSrc (1-bit)** = Selects ALU operand B  
  - `0` = register file output  
  - `1` = sign-extended immediate  

- **MemtoReg (1-bit)** = Selects what goes back into `rd`  
  - `0` = ALU result  
  - `1` = Data memory output  

- **RegWrite (1-bit)** = Enables writing to register file  
  - `1` = arithmetic (R-type), immediate arithmetic (I-type), loads, jumps, upper immediates  
  - `0` = stores, branches  

- **MemRead (1-bit)** = Enables reading from data memory  
  - `1` = load instructions  
  - `0` = everything else  

- **MemWrite (1-bit)** = Enables writing into data memory  
  - `1` = store instructions  
  - `0` = everything else  

- **Branch (1-bit)** = Tells PC logic this is a conditional branch  
  - Gets ANDed with `Zero` flag from ALU to decide whether to update PC  

- **ALUOp (2-bits)** = Encodes which operation group ALU should perform  
  - `00` = load/store (ALU does add)  
  - `01` = branch (ALU does subtract/compare)  
  - `10` = R-type (use funct3/funct7 to pick operation)  
  - `11` = I-type arithmetic  

---

## Branch Logic
- **Branch signal** AND **Zero flag from ALU** = controls the PC mux.  
  - If true = next PC = `PC + immediate offset`  
  - Else = next PC = `PC + 4`  

---

## Notes
- The control unit does not compute results — it just sets flags and mux selects so the datapath elements know what to do each cycle.
