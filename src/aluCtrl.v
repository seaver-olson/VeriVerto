module aluControl(
    input wire [1:0] ALUOp,//2 bit op code
    input wire [2:0] funct3, //instruction [14:12]
    input wire funct7, //instruction [30]
    output reg [3:0] ALUControl
); 
    always @(*) begin
        case (ALUOp) 
            //LOAD and STORE
            2'b00: begin ALUControl = 4'b0010; end
            // BRANCH
            2'b01: begin ALUControl = 4'b0110; end

            2'b10: begin
                case (funct3)
                    3'b000: begin ALUControl = (funct7) ? 4'b0110 : 4'b0010; end  //SUB : ADD
                    3'b001: begin ALUControl = 4'b1000; end  // SLL (shift left)
                    3'b010: begin ALUControl = 4'b0111; end  // SLT
                    3'b011: begin ALUControl = 4'b0111; end  //SLTU (use SLT for now)
                    3'b100: begin ALUControl = 4'b0100; end  //XOR
                    3'b101: begin ALUControl = (funct7) ? 4'b1010 : 4'b1001; end  //SRA : SRL
                    3'b110: begin ALUControl = 4'b0001; end  //OR
                    3'b111: begin ALUControl = 4'b0000; end  //AND
                    default: begin ALUControl = 4'b0010; end
                endcase
            end

            default: begin ALUControl = 4'b0010; end
        endcase 
    end
 
endmodule