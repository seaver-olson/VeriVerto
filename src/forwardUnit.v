module forwardingUnit(
    //as seen on page 572 Patterson
    input wire [4:0] ID_EX_readData1,//src reg 1
    input wire [4:0] ID_EX_readData2,//src reg 2

    input wire [4:0]  EX_MEM_writeReg,//dest reg
    input wire EX_MEM_regWrite,//is EX_MEM writing?
    input wire [4:0] MEM_WB_writeReg,//dest reg
    input wire MEM_WB_regWrite,//EX_MEM_WB[1] writing?
    //encodings: 00 = No forward, 01 = forward from MEM/WB, 10 = forward from ex/mem
    //these control 2-bit ctrl mux before the ALU inputs
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    always @(*) begin
        //reset forwards every check
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        //forwardA
        if (EX_MEM_regWrite && 
            EX_MEM_writeReg != 5'b00000 && 
            EX_MEM_writeReg == ID_EX_readData1
        ) begin 
            ForwardA = 2'b10; 
        end
        else if (MEM_WB_regWrite && 
                MEM_WB_writeReg != 5'b00000 && 
                !(EX_MEM_regWrite && EX_MEM_writeReg != 5'b00000 && EX_MEM_writeReg == ID_EX_readData1) &&
                MEM_WB_writeReg == ID_EX_readData1
        ) begin 
            ForwardA = 2'b01;
        end

        //forwardB
        if (EX_MEM_regWrite && 
            EX_MEM_writeReg != 5'b00000 &&
            EX_MEM_writeReg == ID_EX_readData2
        ) begin 
            ForwardB = 2'b10; 
        end
        else if (MEM_WB_regWrite && 
                MEM_WB_writeReg != 5'b00000 && 
                !(EX_MEM_regWrite && EX_MEM_writeReg != 5'b00000 && EX_MEM_writeReg == ID_EX_readData2) &&
                MEM_WB_writeReg == ID_EX_readData2
        ) begin 
            ForwardB = 2'b01; 
        end
    end

endmodule
//Note:  && logic was found on page 578 of Patterson