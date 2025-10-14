module barrelShifter(
        input wire [31:0] dataIn,
        input wire [4:0] shift,
        input wire shiftLeft,//0 right 1 left
        input wire arithmetic,//0 log, 1 arith
        output wire [31:0] dataOut
);
    //5 stage design: each stage shifts by power of 2
    wire [31:0] s0, s1, s2, s3, s4;
    wire signBit;
    //logical shift doesnt need signBit
    assign signBit = arithmetic ? dataIn[31] : 1'b0;
    wire [31:0] leftShift;
    
    assign leftShift = dataIn << shift;//left shift very easy
    //shift by 1 if shift[0] = 1
    assign s0 = shift[0] ? {arithmetic ? {1{signBit}} : 1'b0, dataIn[31:1]} : dataIn;
    //shift by 2 if shift[1] = 1
    assign s1 = shift[1] ? {arithmetic ? {2{signBit}} : 2'b0, s0[31:2]} : s0;
    //etc
    assign s2 = shift[2] ? {arithmetic ? {4{signBit}} : 4'b0, s1[31:4]} : s1;
    assign s3 = shift[3] ? {arithmetic ? {8{signBit}} : 8'b0, s2[31:8]} : s2;
    assign s4 = shift[4] ? {arithmetic ? {16{signBit}} : 16'b0, s3[31:16]} : s3;
    
    //mux to select output
    assign dataOut = shiftLeft ? leftShift : s4;
endmodule