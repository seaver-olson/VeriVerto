module equalityTestUnit(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire zero
);
    wire [31:0] eqCheck;
    assign eqCheck = a^b;
    assign zero = (eqCheck) ? 1'b1 : 1'b0;
endmodule