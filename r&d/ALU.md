# ALU Design Notes (RISC-V)

## Inputs
- **A**: 32-bit operand  
- **B**: 32-bit operand  
- **func**: 8-bit function selector (from Control → ALUControl)  

## Output
- **Result**: 32-bit output  

---

## Top-Level Structure
- A top-level multiplexer selects which operation module (adder, logic, shifter, comparator, etc.) produces the output.  
- The multiplexer is controlled by the `func` field.  
- This modular design makes the ALU easy to extend with new operations.  

---

## ALU Modules

### Arithmetic
- **Addition**: `A + B`  
- **Subtraction**: `A - B` (can reuse adder with inverted B and carry-in = 1)  

### Logic
- **AND**: `A & B`  
- **OR**: `A | B`  
- **XOR**: `A ^ B`  
- **NOT**: `~A` (if implemented)  

### Shifts (Barrel Shifter)
- **SLL**: Logical left shift, `A << shamt` (shamt = B[4:0])  
- **SRL**: Logical right shift, `A >> shamt` (zeros filled in)  
- **SRA**: Arithmetic right shift, `A >> shamt` (sign bit replicated)  
- **SLLI**: Shift Left Logical Immediate
- **SRLI**: shift right logical immediate
- **SRAI**: Shift right arithmeitc immediate

---

## Barrel Shifter Details
- Implemented as a **cascaded multiplexer system**.  
- Each possible shift amount selects a pre-shifted version of the input.  
- Example: 32-to-1 mux, where each input is `A` shifted by `n` positions.  
- Selector = shift amount (B[4:0]).  
- Advantage: completes any shift in **one cycle** instead of multiple single-bit shifts.  

---

## Control (func field)
- `func` encodes which block result to select.  
- Mapping is typically based on `funct3` and `funct7` from the instruction.  
- Example scheme:  
  - `0000 0000` = ADD  
  - `0000 0001` = SUB  
  - `0000 0010` = AND  
  - `0000 0011` = OR  
  - `0000 0100` = XOR  
  - `0000 0101` = SLL  
  - `0000 0110` = SRL  
  - `0000 0111` = SRA  
  

---

## Summary
- The ALU is a collection of arithmetic, logical, comparison, and shift units.  
- A multiplexer (controlled by `func`) chooses the correct output.  
- The barrel shifter provides efficient one-cycle shift operations.  
