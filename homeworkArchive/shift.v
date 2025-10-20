module shifter(
            input wire [3:0] num,
            input wire [2:0] arb,
            output wire [3:0] out
);
    wire [3:0] s0, s1;

    assign s0 = arb[0] ? {1'b0, num[3:1]}: num;
    assign s1 = arb[1] ? {2'b0, num[3:2]} : s0;
    assign out = arb[2] ? 4'b0 : s1;//stage2
endmodule
