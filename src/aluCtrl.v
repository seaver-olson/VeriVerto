module aluControl(
    input wire [1:0] ALUOp,
    input wire [2:0] funct3, //instruction [14:12]
    input wire funct7, //instruction [30]
    output reg [2:0] ALUControl
); 
    always @(*) begin
        case (ALUOp) 
            2'b00: begin
                ALUControl = 3'b010;
            end

            2'b01: begin
                ALUControl = 3'b011;
            end

            default: begin
                ALUControl = 3'b010;//for testing ADD if fail
            end
        endcase 
    end
 
endmodule