module regfile(
    input wire clk,
    input wire rst,
    //input ports
    input wire[4:0] readReg1,//instruction[19:15]
    input wire[4:0] readReg2,//instruction[24:20]
    input wire[4:0] writeReg,//instruction[11:7], 5 bits is enough to derive which of the 32 regs needs a write
    input wire[31:0] writeData,//output from ALU or data memory
    input wire regWrite,//comes from MEM_WB_WB
    //output ports
    output wire[31:0] regOut1, //Read Data 1
    output wire[31:0] regOut2 //Read Data 2
);
    reg [31:0] registers [1:31];
    integer i;

    assign regOut1 = (readReg1 != 5'b0) ? registers[readReg1] : 32'h00;
    assign regOut2 = (readReg2 != 5'b0) ? registers[readReg2] : 32'h00;

    always @(posedge clk, rst) begin 
        if (rst) begin
            for (i = 1; i<32;i=i+1) begin
                registers[i] <= 32'h00;//wipe all regs
            end
        end else begin
            if (writeReg != 5'b00000 && regWrite) begin
                registers[writeReg] <= writeData;
            end
        end
    end
    
endmodule