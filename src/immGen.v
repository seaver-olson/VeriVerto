module immgen(
    input wire [31:0] instruction,
    output reg [31:0] immgenOut
);
    case (instruction[6:0])
        //R-Type
        7'b0110011: begin
            immgenOut < 32'h0;
        end
        7'b0010011 : begin
            immgenOut = {{20{instruction[31]}}, instruction[31:20]};
        end
        //SB-Type (conditional branches)
        7'b1100111: begin
            
        end
        //UJ-Type
        7'b1101111: begin
        end
        default: begin
            immgenOut = 32'h0;
        end
    endcase
endmodule