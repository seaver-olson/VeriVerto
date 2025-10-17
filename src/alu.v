module alu32(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] op,
    output wire [31:0] result,
    output wire zero,
    output wire cout
);

    wire [31:0] carry;
    wire [31:0] resHold;
    wire [31:0] shiftHold;
    wire [31:0] b_in;
    wire [1:0] shiftctrl;
    wire slt;

    assign shiftctrl = (op == 4'b0011) ? 2'b00 : //SLL
                       (op == 4'b0101) ? 2'b01 : //SRL
                       (op == 4'b1101) ? 2'b10 : //SRA
                       2'b00;

    assign b_in = (op == 4'b0110 || op == 4'b0111) ? ~b : b;

    barrelShifter bs(
        .dataIn(a),
        .shamt(b[4:0]),
        .ctrl(shiftctrl),
        .dataOut(shiftHold)
    );

    oneBit aluBit0(
                    .a(a[0]), 
                    .b(b_in[0]),
                    .cin((op == 4'b0110 || op == 4'b0111) ? 1'b1 : 1'b0),
                    .op(op),
                    .result(resHold[0]),
                    .cout(carry[0])
    );

    genvar i;
    generate 
        for (i = 1; i <32; i = i+1) begin
            oneBit aluBit0( .a(a[i]), 
                            .b(b_in[i]),
                            .cin(carry[i-1]),
                            .op(op),
                            .result(resHold[i]),
                            .cout(carry[i])
            );
        end
    endgenerate

    assign slt = resHold[31] ^ (carry[30] ^ carry[31]);
    assign result = (op == 4'b0111) ? {31'b0, slt} : 
                    (op == 4'b0011 || op == 4'b0101 || op == 4'b1101) ? shiftHold :
                    resHold;
    assign zero = (result == 32'h00);
    assign cout = carry[31];
endmodule

module barrelShifter(
    input  wire [31:0] dataIn,
    input  wire [4:0]  shamt,
    input  wire [1:0]  ctrl, // 00=SLL, 01=SRL, 10=SRA
    output reg  [31:0] dataOut
);
    reg [31:0] stage0, stage1, stage2, stage3, stage4;

    always @(*) begin
        case (ctrl)
            2'b00: begin //Logical Left
                stage0 = shamt[0] ? (dataIn << 1)  : dataIn;
                stage1 = shamt[1] ? (stage0 << 2)  : stage0;
                stage2 = shamt[2] ? (stage1 << 4)  : stage1;
                stage3 = shamt[3] ? (stage2 << 8)  : stage2;
                stage4 = shamt[4] ? (stage3 << 16) : stage3;
            end

            2'b01: begin //Logical Right
                stage0 = shamt[0] ? (dataIn >> 1)  : dataIn;
                stage1 = shamt[1] ? (stage0 >> 2)  : stage0;
                stage2 = shamt[2] ? (stage1 >> 4)  : stage1;
                stage3 = shamt[3] ? (stage2 >> 8)  : stage2;
                stage4 = shamt[4] ? (stage3 >> 16) : stage3;
            end

            2'b10: begin //Arithmetic Right
                stage0 = shamt[0] ? ($signed(dataIn) >>> 1)  : $signed(dataIn);
                stage1 = shamt[1] ? ($signed(stage0) >>> 2)  : $signed(stage0);
                stage2 = shamt[2] ? ($signed(stage1) >>> 4)  : $signed(stage1);
                stage3 = shamt[3] ? ($signed(stage2) >>> 8)  : $signed(stage2);
                stage4 = shamt[4] ? ($signed(stage3) >>> 16) : $signed(stage3);
            end

            default: stage4 = 32'b0;
        endcase
        dataOut = stage4;
    end
endmodule

module oneBit(
    input wire a,
    input wire b,
    input wire cin,
    input [3:0] op,
    output wire result,
    output wire cout
);
    wire sum;
    assign sum = a ^ b ^ cin;

    assign result = (op == 4'b0000) ? a & b : 
                    (op == 4'b0001) ? a | b :
                    (op == 4'b0100) ? a ^ b :
                    (op == 4'b0010 || op == 4'b0110 || op == 4'b0111) ? sum :
                    1'b0;

    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule