module regfile(
        input wire clk,
        input wire rst,//control sig 
        //input ports
        input wire[4:0] readReg1,//instruction[19:15]
        input wire[4:0] readReg2,//instruction[24:20]
        input wire[4:0] writeReg,//instruction[11:7]
        input wire[31:0] writeData,//output from ALU or data memory
        input  wire rd_we,//opCode signal for ReadWrite
        //output ports  
        output wire[31:0] regOut1, //Read Data 1
        output wire[31:0] regOut2 //Read Data 2
);
    reg [31:0] registers [0:31];//32 - 32bit registers
    integer counter;
    //writes only happen on positive clock edge to sync
    always @(posedge clk) begin
        if (!rst) begin

        end else begin
            //account for garbage starting in the registers
            for (counter=0;counter<32;counter=counter+1) begin
                assign registers[counter] = 32'b0;//wipe all 32 bits in each register
            end
        end
    end

    assign regOut1;
    assign regOut2;



endmodule
