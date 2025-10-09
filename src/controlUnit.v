module controlUnit(
    input wire [6:0] instruction,
    output reg Branch, // enables pc branch
    output reg MemRead,//enables reading data memory
    output reg MemtoReg, //chooses what to write back: 0 ALU result 1 =data memory
    output reg [1:0] ALUOp,
    output reg MemWrite,//enables writing data memory
    output reg ALUSrc, // Chooses ALU's 2nd input: 0 = register file2, 1= immediate
    output reg RegWrite // enables writing to register file
);
    always @(*) begin
        //I found the instruction opcodes for rv32I systems at https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf
        case (instruction)
            //R-Type
            7'b0110011: begin 
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b0;
                RegWrite = 1'b1;
                ALUOp = 2'b10;
            end
            //I-Type
            7'b0010011: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b1; //Use immediate instead of reg read 2
                RegWrite = 1'b1;
                ALUOp = 2'b10;
            end
            //LOAD
            7'b0000011: begin
                Branch = 1'b0;
                MemRead = 1'b1;
                MemtoReg = 1'b1;//writeback from data memory
                MemWrite = 1'b0;
                ALUSrc = 1'b1; //Use immediate for offset
                RegWrite = 1'b1;
                ALUOp = 2'b00; // add operation, pc + immediate offset
            end
            //STORE
            7'b0100011: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                RegWrite = 1'b0;
                ALUOp = 2'b00;// add for address
            end
            //BRANCH
            7'b1100011: begin
                Branch = 1'b1;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b0;
                RegWrite = 1'b0;
                ALUOp = 2'b01;//subtract for comp
            end
            //JAL (referenced page 241)
            7'b1101111: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b0;
                RegWrite = 1'b1;
                ALUOp = 2'b10;
            end
            //LUI
            7'b0110111: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b1;
                RegWrite = 1'b1;
                ALUOp = 2'b11;
            end
            //JALR / SB-Type Instruction
            7'b1100111: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b1;
                RegWrite = 1'b1;
                ALUOp = 2'b00;
            end
            //AUIPC
            7'b0010111: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b1;
                RegWrite = 1'b1;
                ALUOp = 2'b00;
            end
            //Environmental calls need implementation later at 1110011 : ecall, ebreak
            default: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b0;
                RegWrite = 1'b0;
                ALUOp = 2'b00;
            end
        endcase
    end
endmodule