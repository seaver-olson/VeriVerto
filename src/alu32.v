module ALU32 (
    input  wire [31:0] A, 
    input  wire [31:0] B, 
    input  wire [3:0]  Op,
    output reg  [31:0] Result,
    output wire Zero,
    output reg  Cout
);
    wire [31:0] B_in;
    wire [31:0] sum;
    wire [31:0] carry;
    integer i;

    assign B_in = (Op == 4'b0110 || Op == 4'b0111) ? ~B : B;

    assign {Cout, sum} = A + B_in + ((Op == 4'b0110 || Op == 4'b0111) ? 1'b1 : 1'b0);

    always @(*) begin
        case (Op)
            4'b0000: Result = A & B;                           
            4'b0001: Result = A | B;                            
            4'b0010: Result = sum;                                
            4'b0110: Result = sum;                                
            4'b0111: Result = ($signed(A) < $signed(B)) ? 32'h1 : 32'h0; 
            4'b1100: Result = ~(A | B);    
            default: Result = 32'h00000000;
        endcase
    end

    // Zero flag for branching
    assign Zero = (Result == 32'h00000000);

endmodule