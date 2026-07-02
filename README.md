# VeriVerto

VeriVerto is a work-in-progress RV32I RISC-V CPU written in Verilog. The current codebase has moved beyond the original single-cycle design notes and is centered around a five-stage pipelined CPU with basic hazard handling, forwarding, branch/jump support, and experimental memory-system modules.

The project is primarily an educational computer architecture implementation: the goal is to build up a readable processor design while experimenting with real pipeline components such as pipeline registers, stalls, forwarding, branch target prediction, instruction/data memories, and simple cache structures.

## Current architecture

The active CPU implementation is in `src/cpu.v` and is organized around the classic five pipeline stages:

| Stage | Current role |
| --- | --- |
| IF | Program counter update and instruction fetch from instruction memory |
| ID | Decode, register-file read, immediate generation, branch comparison, and control generation |
| EX | ALU execution, address calculation, and forwarding muxes |
| MEM | Data-memory read/write |
| WB | Register writeback from either memory or the ALU result |

Pipeline-register modules live in `src/pipeline.v`:

- `IF_ID`
- `ID_EX`
- `EX_MEM`
- `MEM_WB`

## Implemented or partially implemented components

### CPU datapath and control

- Five-stage pipelined CPU top level in `src/cpu.v`
- Register file with 32 architectural registers and hardwired `x0`
- Program counter unit with sequential `PC + 4`, branch, `JAL`, and `JALR` paths
- Control unit for major RV32I opcode classes
- Immediate generator for I, S, B, U, and J formats
- Equality/branch comparison unit for RV32I branch funct3 cases
- Load-use hazard detection with PC and IF/ID stalling plus ID/EX bubble insertion
- Forwarding unit for EX/MEM and MEM/WB forwarding into the ALU input muxes

### ALU

- 32-bit ALU built from one-bit ALU slices
- ADD / ADDI
- SUB
- AND / ANDI
- OR / ORI
- XOR / XORI
- SLT-style comparison path
- Barrel shifter for SLL, SRL, and SRA-style operations
- ALU control decode using `ALUOp`, `funct3`, and `funct7`

### Memory system

- 64 KiB instruction memory loaded from `loadfile_all.img`
- 64 KiB byte-addressed data memory
- Memory-mapped debug output path at `0xFFFF0000`
- Experimental L1 ROM cache module
- Stub/in-progress L1 RAM cache module
- Simple main-memory model for cache testing

### Branch prediction experiments

- Experimental 16-entry branch target buffer in `src/btb.v`
- 2-bit saturating counter state per BTB entry
- Valid bits, target storage, and simple LRU-style replacement counters
- Standalone BTB testbench in `tb/btb_tb.v`

## Repository layout

```text
.
├── Makefile                 # Builds a RV32I test program into loadfile_all.img
├── linker.ld                # RISC-V linker script for IMEM/DMEM layout
├── src/
│   ├── cpu.v                # Pipelined CPU top level
│   ├── pipeline.v           # IF/ID, ID/EX, EX/MEM, MEM/WB registers
│   ├── pc.v                 # Program counter unit
│   ├── controlUnit.v        # Main control decode
│   ├── immGen.v             # Immediate generator
│   ├── alu.v                # 32-bit ALU and barrel shifter
│   ├── aluCtrl.v            # ALU control decoder
│   ├── regfile.v            # Register file
│   ├── equalityUnit.v       # Branch comparison logic
│   ├── hazardDetection.v    # Load-use hazard detection
│   ├── forwardUnit.v        # Forwarding logic
│   ├── instructionMemory.v  # Instruction memory
│   ├── dataMemory.v         # Data memory
│   ├── btb.v                # Experimental branch target buffer
│   └── cache.v              # Experimental cache modules
├── tb/
│   ├── cpu_tb.v             # CPU testbench
│   ├── btb_tb.v             # BTB testbench
│   └── l1_tb.v              # L1 ROM cache testbench
└── testcases/
    └── class.c              # Current C test program compiled into memory image
```

## Building a test memory image

The included `Makefile` uses a RISC-V bare-metal toolchain to compile `testcases/class.c` into a Verilog memory image:

```sh
make
```

This produces:

- `program.elf`
- `loadfile_all.img`
- `program.dump`

The instruction memory module reads `loadfile_all.img` during simulation.

## Toolchain expectations

The current Makefile expects these tools to be available on your path:

- `riscv64-unknown-elf-gcc`
- `riscv64-unknown-elf-objcopy`
- `riscv64-unknown-elf-objdump`

The current compile flags target RV32I bare-metal code:

```text
-march=rv32i -mabi=ilp32 -O0 -nostdlib -ffreestanding
```

## Testbenches

The repository currently includes testbenches for:

- CPU-level simulation: `tb/cpu_tb.v`
- Branch target buffer behavior: `tb/btb_tb.v`
- L1 ROM cache behavior: `tb/l1_tb.v`

There is not yet a single top-level simulation Makefile for the Verilog testbenches, so simulation is currently expected to be run through your HDL simulator of choice.

## Current status

VeriVerto is actively under development. The repository should be read as a learning/research implementation rather than a complete production RISC-V core.

### Working or substantially present

- Pipelined CPU structure
- Pipeline registers
- RV32I-style decode for major instruction classes
- Immediate generation
- Register file
- ALU operations and barrel shifting
- Data and instruction memories
- Load-use stalling
- Basic forwarding
- Branch comparison logic
- Test-image generation from C

### Experimental or in progress

- BTB integration with the fetch path
- Cache integration with the CPU datapath
- Full load/store width and sign-extension behavior
- Complete RV32I validation coverage
- Control-flow correctness across all branch and jump corner cases
- Cleaner simulator build/test automation

## Project direction

Near-term improvements are likely to focus on:

- Stabilizing the pipelined CPU implementation
- Expanding instruction coverage tests
- Connecting branch prediction cleanly into fetch
- Integrating cache modules into the CPU memory path
- Adding a repeatable simulation flow
- Documenting known limitations and design decisions as the architecture evolves
