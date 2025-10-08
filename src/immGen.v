module immgen(
    input wire [31:0] instruction,
    output reg [31:0] immgenOut
);
    wire [6:0] opcode = instruction[6:0];

endmodule