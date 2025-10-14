module hazardDetectionUnit(
    input wire ID_EX_MemRead,
    input wire [4:0] IF_ID_ReadData1,
    input wire [4:0] IF_ID_ReadData2,
    input wire [4:0] ID_EX_writeReg,
    output reg PCWrite,//0 stall PC, 1 allow PC to increment
    output reg IF_ID_Write,// 0 stall IF/ID register, 1 = allow update
    output reg muxSelect//1 send all zero control sig to id/ex
);
    always @(*) begin
        PCWrite <= 1'b1;
        IF_ID_Write <= 1'b1;
        muxSelect <= 1'b0;
        if (ID_EX_MemRead && ((ID_EX_writeReg == IF_ID_ReadData1)||(ID_EX_writeReg == IF_ID_ReadData2))) begin
            PCWrite <= 1'b0;
            IF_ID_Write <= 1'b0;
            muxSelect <= 1'b1;
        end
    end
endmodule