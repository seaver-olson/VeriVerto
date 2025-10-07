module controlUnit(
    input wire [6:0] instruction,
    output reg Branch, // enables pc branch
    output reg MemRead,//enables reading data memory
    output reg MemtoReg, //chooses what to write back: 0 ALU result 1 =data memory
    output reg ALUOp,
    output reg MemWrite,//enables writing data memory
    output reg ALUSrc, // Chooses ALU's 2nd input: 0 = register file2, 1= immediate
    output reg RegWrite // enables writing to register file
);
    always @(*) begin
        //I found the instruction opcodes for rv32I systems at https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf
        case (instruction)
            7'b0110011: begin 
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end

            7'b0010011: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end

            7'b0000011: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end

            7'b0100011: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end

            7'b1100011: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end

            7'1101111: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end

            7'b0110111: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end

            7'b1110011: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end

            default: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 0;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end
        endcase
    end
endmodule