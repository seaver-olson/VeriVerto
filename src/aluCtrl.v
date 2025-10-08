module aluControl(
    input wire [1:0] ALUOp,//2 bit op code
    input wire [2:0] funct3, //instruction [14:12]
    input wire funct7, //instruction [30]
    output reg [3:0] ALUControl
); 
    always @(*) begin
        case (ALUOp) 
            2'b00: begin
                ALUControl = 4'b0010;
            end

            2'b01: begin
                ALUControl = 4'b0011;
            end

            default: begin
                ALUControl = 4'b0010;//for testing ADD if fail
            end
        endcase 
    end
 
endmodule