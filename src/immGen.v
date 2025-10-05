module immgen(
    input wire [31:0] instruction,
    output reg [31:0] immgenOut
);
    wire [6:0] opcode = instructions[6:0];

    always @(*) begin
        case (opcode)
            
        endcase
    end
endmodule