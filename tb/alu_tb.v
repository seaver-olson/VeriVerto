`timescale 1ns/1ps

module alu32_tb;

    // inputs
    reg  [31:0] A;
    reg  [31:0] B;
    reg  [2:0]  op;

    // outputs
    wire [31:0] Result;
    wire        Zero;
    wire        Cout;

    // instantiate the ALU
    alu32 dut (
        .A(A),
        .B(B),
        .Op(op),
        .Result(Result),
        .Zero(Zero),
        .Cout(Cout)
    );

    initial begin
        // test AND
        A = 32'hF0F0F0F0; 
        B = 32'h0F0F0F0F;
        op = 3'b000; // AND
        #10;
        $display("AND: %h & %h = %h", A, B, Result);

        // test OR
        A = 32'hF0000000; 
        B = 32'h0000FFFF;
        op = 3'b001; // OR
        #10;
        $display("OR: %h | %h = %h", A, B, Result);

        // test ADD
        A = 32'd25;
        B = 32'd17;
        op = 3'b010; // ADD
        #10;
        $display("ADD: %d + %d = %d", A, B, Result);

        // test ADD with carry propagation
        A = 32'hFFFFFFFF; // max value
        B = 32'h00000001;
        op = 3'b010; // ADD
        #10;
        $display("ADD overflow: %h + %h = %h, Cout=%b", A, B, Result, Cout);

        // test Zero flag
        A = 32'd50;
        B = 32'd50;
        op = 3'b010; // ADD (really subtract if we later implement SUB)
        #10;
        $display("Zero flag test: A=%d, B=%d, Result=%h, Zero=%b", A, B, Result, Zero);

        $finish;
    end

endmodule
