//no longer in use, bit slicing turned out to be way too slow

module BitALU (
    input  wire a,
    input  wire b,  
    input  wire cin,    
    input  wire [3:0] op,
    output wire result,
    output wire cout    
);
    wire b_in, sum, carryOut;
    assign b_in = (op == 4'b0110) ? ~b : b;//handles subtraction by flipping b
    assign sum = a ^ b_in ^ cin;
    assign carryOut =  (a & b_in) | (b_in & cin) | (a & cin);

    assign result = (op == 4'b0000) ? a & b :
                    (op == 4'b0001) ? a | b :
                    (op == 4'b0010 || op == 4'b0110) ? a ^ b_in ^ cin :
                    (op == 4'b1100) ? ~(a|b) :
                    1'b0;
    
    assign cout = carryOut//needed for multi-bit addition calculations

endmodule
