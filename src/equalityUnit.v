module equalityTestUnit(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] funct3,
    output wire zero
);
    wire [31:0] eqCheck;
    assign eqCheck = (a==b);
    wire lts=($signed(a) < $signed(b));
    wire ltu=(a<b);
    //codes from RV32IRef.png in PattersonDocs folder
    assign zero =   (funct3 == 3'b000) ? eqCheck :
                    (funct3 == 3'b001) ? ~eqCheck :
                    (funct3 == 3'b100) ? lts :
                    (funct3 == 3'b101) ? ~lts :
                    (funct3 == 3'b110) ? ltu :
                    (funct3 == 3'b111) ? ~ltu :
                    1'b0;
endmodule