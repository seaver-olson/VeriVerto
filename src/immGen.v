module immgen(
    input wire [31:0] instruction,
    output reg [31:0] immgenOut
);
    always @(*) begin
        case (instruction[6:0])
            //R-Type
            7'b0110011: immgenOut = 32'h0;
            
            //I-Type and LOAD
            7'b0010011, 
            7'b0000011: begin
                immgenOut = {{20{instruction[31]}}, instruction[31:20]};
            end
            //S-Type
            7'b0100011: begin
                    // Sign-extend imm[11:5|4:0]
                immgenOut = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            //B-Type (conditional branches)
            7'b1100011: begin
                immgenOut = {{19{instruction[31]}}, instruction[31], instruction[7], 
                                instruction[30:25], instruction[11:8], 1'b0};
            end
            //U-Type
            7'b0110111, 
            7'b0010111: begin
                immgenOut = {instruction[31:12], 12'b0};
            end
                
            //J-Type 
            7'b1101111: begin
                immgenOut = {{11{instruction[31]}}, instruction[31], instruction[19:12], 
                                instruction[20], instruction[30:21], 1'b0};
            end

            default: begin
                immgenOut = 32'h0;
            end
        endcase
    end
endmodule