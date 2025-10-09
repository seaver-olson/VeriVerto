module alu32 (
    input wire[31:0] A, 
    input wire[31:0] B, 
    input wire[3:0]  Op, //4-bit opcode to match textbook 
    output wire[31:0] Result, 
    output wire Zero
    //output wire Cout
);
    
    wire slt;
    wire [31:0] carry;
    wire sltRes;
    //first bit
    BitALU alu_bit0 (.a(A[0]), 
                    .b(B[0]),
                    .cin((Op==4'b0110 || Op == 4'b0111) ? 1'b1 : 1'b0),
                    .op(Op),
                    .result(sltRes),
                    .cout(carry[0])
                    );
    //generate bit 1-31
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin
            BitALU alu_bit (.a(A[i]), .b(B[i]),.cin(carry[i-1]), .op(Op),.result(Result[i]),.cout(carry[i]));
        end
    endgenerate
    //if A < B (signed)
    assign slt = (carry[30] ^ carry[31]) ^ Result[31];
    assign Result = (Op == 4'b0111) ? {31'b0, slt} : Result;
    assign Zero = (Result == 32'b0);//useful for branching and ==
endmodule
