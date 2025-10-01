module cpu(input wire clk, input wire rst);

    reg [31:0] pc;

    wire [31:0] instructions;

    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire ALUOp;
    wire [2:0] ALUControl;

    wire [4:0] readReg1 = instructions[19:15];
    wire [4:0] readReg2 = instructions[24:20];
    wire [4:0] writeReg = instructions[11:7];
    wire [31:0] regOut1;
    wire [31:0] regOut2;

    // Immediate generator (fix later)
    wire [31:0] immgen_out;

    wire [31:0] ALU_Bin;//for mux between regfile and immgen
    wire [31:0] ALU_out;
    wire alu_zero;//zero flag for equalities

    //data memory 
    wire[31:0] dmem_out;

    wire [31:0] dmemALU_wb;//write back mux for data memory and ALU

    //register file
    regfile regFile(.clk(clk), .rst(rst), .readReg1(readReg1), .readReg2(readReg2), .writeReg(writeReg), .writeData(dmemALU_wb), .rd_we(RegWrite), .regOut1(regOut1), .regOut2(regOut2));

    //ALU B Input Mux between regfile and immgen
    assign ALU_Bin = (ALUSrc) ? immgen_out : regOut2;

    //ALU instance
    ALU alu(.a(regOut1), .b(ALU_Bin), .op(ALUControl), .result(ALU_out), .zero(alu_zero));

endmodule



