module cpu(input wire clk, input wire rst);

    reg [31:0] pc;

    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire [1:0] ALUOp;
    wire [2:0] ALUControl;

    wire [31:0] instructions;
    wire [4:0] readReg1 = instructions[19:15];
    wire [4:0] readReg2 = instructions[24:20];
    wire [4:0] writeReg = instructions[11:7];
    wire [6:0] opcode = instructions[6:0];
    
    wire [31:0] regOut1;
    wire [31:0] regOut2;

    // Immediate generator (fix later)
    wire [31:0] immgen_out;

    //ALU + ALU Control Unit wires
    wire [2:0] funct3 = instructions[14:12];
    wire funct7 = instructions[30];
    wire [31:0] ALU_Bin;//for mux between regfile and immgen
    wire [31:0] ALU_out;//dont forget to set this to dataMemory
    wire alu_zero;//zero flag for equalities

    //data memory wires
    wire [31:0] dmem_out;
    wire [31:0] dmemALU_wb;//write back mux for data memory and ALU

     //ALU B Input Mux between regfile and immgen
    assign ALU_Bin = (ALUSrc) ? immgen_out : regOut2;

    //write back mux
    assign dmemALU_wb = (MemtoReg) ? dmem_out : ALU_out;
    //pc Note: I have not implemented branching yet since the immgen is still in progress
    pc programCounter(.clk(clk), .rst(rst), .branch(Branch), .zero(alu_zero), .branchDest(immgen_out), .pc(pc));
    //instruction memory 
    instructionMemory instrMem(.readAddress(pc), .instruction(instructions));
    //control unit + ALU control unit
    controlUnit ctrlUnit(.opcode(opcode), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .ALUOp(ALUOp), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite));
    aluControl aluCtrlUnit(.ALUOp(ALUOp), .funct3(funct3), .funct7(funct7), .ALUControl(ALUControl));
    //register file
    regfile regFile(.clk(clk), .rst(rst), .readReg1(readReg1), .readReg2(readReg2), .writeReg(writeReg), .writeData(dmemALU_wb), .rd_we(RegWrite), .regOut1(regOut1), .regOut2(regOut2));
    //ALU instance
    ALU alu(.a(regOut1), .b(ALU_Bin), .op(ALUControl), .result(ALU_out), .zero(alu_zero));
    //data memory instance
    dataMemory dataMem(.clk(clk), .MemWrite(MemWrite), .MemRead(MemRead), .address(ALU_out), .writeData(regOut2), .readData(dmem_out));
endmodule



