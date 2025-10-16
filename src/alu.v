module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] op,
    output wire [31:0] result,
    output wire zero,
    output wire cout
);

    wire [31:0] carry;
    wire [31:0] resHold;
    wire [31:0] b_in;
    wire slt;

    assign b_in = (op == 4'b0110 || op == 4'b0111) ? ~b : b;

    oneBit aluBit0(
                    .a(a[0]), 
                    .b(b_in[0]),
                    .cin((op == 4'b0110 || op == 4'b0111) ? 1'b1 : 1'b0),
                    .op(op),
                    .result(resHold[0]),
                    .cout(carry[0])
    );

    genvar i;
    generate 
        for (i = 1; i <32; i = i+1) begin
            oneBit aluBit0( .a(a[i]), 
                            .b(b_in[i]),
                            .cin(carry[i-1]),
                            .op(op),
                            .result(resHold[i]),
                            .cout(carry[i])
            );
        end
    endgenerate

    assign slt = resHold[31] ^ (carry[30] ^ carry[31]);
    assign result = (op == 4'b0111) ? {31'b0, slt} : resHold;
    assign zero = (result == 32'h00);
    assign cout = carry[31];
endmodule

module oneBit(
    input wire a,
    input wire b,
    input wire cin,
    input [3:0] op,
    output wire result,
    output wire cout
);
    wire sum;
    assign sum = a ^ b ^ cin;

    assign result = (op == 4'b0000) ? a & b : 
                    (op == 4'b0001) ? a | b :
                    (op == 4'b0010 || op == 4'b0110 || op == 4'b0111) ? sum :
                    1'b0;

    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule