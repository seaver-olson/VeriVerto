module BitALU (
    input  wire a,
    input  wire b,  
    input  wire cin,    
    input  wire [2:0] op,
    output wire result,
    output wire cout    
);
    wire b_in;
    assign b_in = (op == 3'b011) ? ~b : b;//handles subtraction by flipping b
    assign result = (op == 3'b000) ? a & b :
                    (op == 3'b001) ? a | b :
                    (op == 3'b010 || op == 3'b011) ? a ^ b_in ^ cin :
                    1'b0;

    assign cout = (op == 3'b010 || op == 3'b011) ? (a & b_in) | (b_in & cin) | (a & cin): 1'b0;//needed for multi-bit addition calculations

endmodule
