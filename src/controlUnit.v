module controlUnit(
    input wire [6:0] instruction,
    output reg Branch,
    output reg MemtoRead,
    output reg MemtoReg,
    output reg ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrites
);
    always @(*) begin
        case (instruction)
            default:
                $display("Test");
        endcase
    end
endmodule