module BitALU (
    input  wire a,
    input  wire b,  
    input  wire cin,    
    input  wire [2:0] op,
    output wire result,
    output wire cout    
);
    wire and_ab = a & b;//OPCODE:000
    wire or_ab  = a | b;//OPCODE:001
    wire xor_ab = a ^ b;//OPCODE:010
    //logic taken from previous 4bit ripple adder, I could probably improve the design later
    wire sum = a ^ b ^ cin;
    wire carry = (a & b) | (b & cin) | (a & cin);

    assign result = (op == 3'b000) ? and_ab :
                    (op == 3'b001) ? or_ab  :
                    (op == 3'b010) ? sum    :
                    1'b0;

    assign cout = (op == 3'b010) ? carry : 1'b0;//needed for multi-bit addition calculations

endmodule
