module alu32 (input wire[31:0] A, input wire[31:0] B, input wire[2:0]  Op, output wire[31:0] Result, output wire Zero, output wire Cout);
    wire [31:0] carry;
    //first bit
    BitALU alu_bit0 (.a(A[0]), .b(B[0]),.cin(1'b0), .op(Op),.result(Result[0]),.cout(carry[0]));
    //generate bit 1-31
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin
            BitALU alu_bit (.a(A[i]), .b(B[i]),.cin(carry[i-1]), .op(Op),.result(Result[i]),.cout(carry[i]));
        end
    endgenerate
    assign Cout = carry[31];
    assign Zero = (Result == 32'b0);//useful for branching and ==
endmodule
