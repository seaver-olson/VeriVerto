module equalityTestUnit(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire zero
);
    assign zero = a ^ ~b;
endmodule