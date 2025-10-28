module IF_ID(
    input wire clk,
    input wire rst,
    input //to do: the problem is that we do not have the control unit output in this module lets handle the spliut in ID stage and just read in ID_WB,ID_M,ID_EX
    input wire IF_ID_Write,
    input wire Jump,
    input wire [31:0] IF_pc,
    input wire [31:0] IF_instruction,
    output wire [4:0] readData1,
    output wire [4:0] readData2,
    output wire [4:0] writeReg,
    output wire [2:0] funct3,
    output wire [6:0] opcode,
    output wire funct7,
    output wire [31:0] ID_instruction,
    output wire [31:0] ID_pc
);
    reg [31:0] pc;
    reg [31:0] instruction;

    always @(posedge clk or posedge rst) begin
        if (rst || !IF_ID_Write) begin
            pc <= 0;
            instruction <= 32'd13;//nop
        end else if (IF_ID_Write) begin
            pc <= IF_pc;
            instruction <= (Jump) ? 32'd13 : IF_instruction;
        end
    end

    assign funct7 = instruction[30];
    assign readData2 = instruction[24:20];
    assign readData1 = instruction[19:15];
    assign funct3 = instruction[14:12];
    assign writeReg = instruction[11:7];
    assign opcode = instruction[6:0];
    assign ID_instruction = instruction;
    assign ID_pc = pc;
endmodule

module ID_EX(
    input wire clk,
    input wire rst,
    input wire muxSelect,
    input wire [31:0] ID_regOut1,
    input wire [31:0] ID_regOut2,
    input wire [31:0] ID_pc,
    input wire [31:0] ID_imm,
    output wire [31:0] EX_imm,
    output wire [31:0] EX_regOut1,
    output wire [31:0] EX_regOut2,
    output wire [4:0] EX_readData1,
    output wire [4:0] EX_readData2,
    output wire [4:0] EX_writeReg,
    output wire [1:0] EX_WB,
    output wire [1:0] EX_M,
    output wire [3:0] EX_EX,
    output wire [2:0] EX_F3
);
    reg [31:0] ID_EX_PC;
    reg [31:0] ID_EX_RD1;
    reg [31:0] ID_EX_RD2;
    reg [31:0] ID_EX_IMM;

    reg [1:0] ID_EX_WB;//writeback stage: regWrite+memtoreg
    reg [1:0] ID_EX_M;//memory access stage: branch + memRead + memWrite
    reg [3:0] ID_EX_EX;//execution/address calculation stage: ALUOp[1:0] + ALUSrc
    reg [2:0] ID_EX_F3;

    reg [4:0] ID_EX_readData1;
    reg [4:0] ID_EX_readData2;
    reg [4:0] ID_EX_writeReg;

    always @(posedge clk or posedge rst) begin
        if (rst || muxSelect) begin
            ID_EX_PC <= 0;
            ID_EX_RD1 <= 0;
            ID_EX_RD2 <= 0;
            ID_EX_IMM <= 0;
            ID_EX_WB <= 0;
            ID_EX_M <= 0;
            ID_EX_EX <= 0;
            ID_EX_F3 <= 0;
            ID_EX_readData1 <= 0;
            ID_EX_readData2 <= 0;
            ID_EX_writeReg <= 0;
        end else begin
            ID_EX_PC <= ID_pc;
            ID_EX_RD1 <= ID_regOut1;
            ID_EX_RD2 <= ID_regOut2;
            ID_EX_IMM <= ID_imm;
            ID_EX_WB <= {RegWrite, MemtoReg};
            ID_EX_M <= {MemRead, MemWrite};
            ID_EX_EX <= {ALUOp, ALUSrc, ID_funct7};
            ID_EX_F3 <= ID_funct3;
            ID_EX_readData1 <= ID_readData1;
            ID_EX_readData2 <= ID_readData2;
            ID_EX_writeReg <= ID_writeReg;
        end

        assign EX_imm = ID_EX_IMM;
        assign EX_regOut1 = ID_EX_RD1;
        assign EX_regOut2 = ID_EX_RD2;
        assign EX_readData1 = ID_EX_readData1;
        assign EX_readData2 = ID_EX_readData2;
        assign EX_writeReg = ID_EX_writeReg;
        assign EX_WB = ID_EX_WB;
        assign EX_M = ID_EX_M;
        assign EX_EX = ID_EX_EX;
        assign EX_F3 = ID_EX_F3;
    end
endmodule

module EX_MEM();

endmodule

module MEM_WB();

endmodule