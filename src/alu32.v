module alu32 (
    input wire[31:0] A, 
    input wire[31:0] B, 
    input wire[3:0]  Op, //4-bit opcode to match textbook 
    output wire[31:0] Result, 
    output wire Zero,
    output wire Cout
);
    
    wire slt;
    wire [31:0] carry;
    wire [31:0] resultHolder;
    wire [31:0] shiftResult;
    wire bit0Res;

    wire leftShift, arithmetic;
    assign leftShift = (Op == 4'b1000);
    assign arithmetic = (Op == 4'b1010);
    barrelShifter bs(.dataIn(A), .shift(B[4:0]), .shiftLeft(leftShift), .arithmetic(arithmetic), .dataOut(shiftResult));
    //first bit, slt requires cin = 1
    BitALU alu_bit0 (.a(A[0]), 
                    .b(B[0]),
                    .cin((Op==4'b0110 || Op == 4'b0111) ? 1'b1 : 1'b0),
                    .op(Op),
                    .less(slt),
                    .result(bit0Res),
                    .cout(carry[0])
                    );
    assign resultHolder[0] = bit0Res;

    //generate bit 1-31
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin
            BitALU alu_bit (.a(A[i]), .b(B[i]),.cin(carry[i-1]), .op(Op), .less(1'b0), .result(resultHolder[i]),.cout(carry[i]));
        end
    endgenerate
    //if A < B (signed) 
    assign slt = (A[31] != B[31]) ? A[31] : carry[31] ^ carry[30];
    assign Result = (Op == 4'b0111) ? {31'b0, slt} : 
                    (Op == 4'b1000 || Op == 4'b1001 || Op == 4'b1010) ? shiftResult :
                    resultHolder;
    assign Zero = (Result == 32'b0);//useful for branching and ==
    assign Cout = carry[31];
endmodule

