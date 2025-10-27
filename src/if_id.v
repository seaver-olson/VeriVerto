module IF_ID(
    input wire clk,
    input wire rst,
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
        if (rst) begin
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