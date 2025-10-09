module cpu(input wire clk, input wire rst);

    wire [31:0] pc;

    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    

    wire [31:0] instructions;
    wire [4:0] readReg1 = instructions[19:15];
    wire [4:0] readReg2 = instructions[24:20];
    wire [4:0] writeReg = instructions[11:7];

    wire [31:0] regOut1;
    wire [31:0] regOut2;

    wire [31:0] immgen_out;

    //ALU + ALU Control Unit wires
    wire [2:0] funct3 = instructions[14:12];
    wire funct7 = instructions[30];
    wire [31:0] ALU_Bin;//for mux between regfile and immgen
    wire [31:0] ALU_out;//dont forget to set this to dataMemory
    wire alu_cout;
    wire alu_zero;//zero flag for equalities
    wire [6:0] opcode;
    assign opcode = instructions[6:0];

    assign Jump = (opcode == 7'b1101111) || (opcode == 7'b1100111);
    //data memory wires
    wire [31:0] dmem_out;
    wire [31:0] dmemALU_wb;//write back mux for data memory and ALU

    //ALU B Input Mux between regfile and immgen
    assign ALU_Bin = (ALUSrc) ? immgen_out : regOut2;

    //write back mux
    assign dmemALU_wb = (MemtoReg) ? dmem_out : ALU_out;
    //pc Note: I have not implemented branching yet since the immgen is still in progress
    pcUnit programCounter(.clk(clk), .rst(rst), .branch(Branch), .zero(alu_zero), .jump(Jump), .branchDest(immgen_out), .jumpBase(regOut1), .jalrFlag(opcode==7'b1100111), .pc(pc));
    //instruction memory 
    instructionMemory instrMem(.readAddress(pc), .instruction(instructions));
    //control unit + ALU control unit
    controlUnit ctrlUnit(.instruction(opcode), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .ALUOp(ALUOp), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite));
    aluControl aluCtrlUnit(.ALUOp(ALUOp), .funct3(funct3), .funct7(funct7), .ALUControl(ALUControl));
    //immediate generator
    immgen immediateGen(.instruction(instructions), .immgenOut(immgen_out));
    //register file
    regfile regFile(.clk(clk), .rst(rst), .readReg1(readReg1), .readReg2(readReg2), .writeReg(writeReg), .writeData(dmemALU_wb), .rd_we(RegWrite), .regOut1(regOut1), .regOut2(regOut2));
    //ALU instance
    alu32 alu(.A(regOut1), .B(ALU_Bin), .Op(ALUControl), .Result(ALU_out), .Zero(alu_zero), .Cout(alu_cout));
    //data memory instance
    dataMemory dataMem(.clk(clk), .MemWrite(MemWrite), .MemRead(MemRead), .address(ALU_out), .writeData(regOut2), .readData(dmem_out));
endmodule
