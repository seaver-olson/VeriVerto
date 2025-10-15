module regfile(
        input wire clk,
        input wire rst,//control sig 
        //input ports
        input wire[4:0] readReg1,//instruction[19:15]
        input wire[4:0] readReg2,//instruction[24:20]
        input wire[4:0] writeReg,//instruction[11:7], 5 bits is enough to derive which of the 32 regs needs a write
        input wire[31:0] writeData,//output from ALU or data memory
        input  wire rd_we,//opCode signal for ReadWrite
        //output ports  
        output wire[31:0] regOut1, //Read Data 1
        output wire[31:0] regOut2 //Read Data 2
);
    reg [31:0] registers [0:31];//31 - 32bit registers
    integer counter;

    assign regOut1 = registers[readReg1];
    assign regOut2 = registers[readReg2];
    //writes only happen on positive clock edge to sync
    always @(posedge clk) begin
        if (rst) begin
            //accounts for garbage starting in the registers
            for (counter=0;counter<32;counter=counter+1) begin
                registers[counter] <= 32'b0;//wipe all 32 bits in each register
            end
        end else begin
            //if opCode and system isn't trying to write r0
            if (rd_we) begin
                registers[writeReg] <= writeData;//non-blocking assignment
            end
                registers[0] <= 32'b0;
        end
    end
endmodule 