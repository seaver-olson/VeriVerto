module dataMemory(
    input wire clk,
    input wire MemWrite,
    input wire MemRead,
    input wire [31:0] address,
    input wire [31:0] writeData,
    output reg [31:0] readData
);
    reg [31:0] memory [0:16383];//128KB
    integer i;
    //init memory and delete garbage
    initial begin
        for (i = 0; i < 16384; i = i + 1) begin
            memory[i] = 32'h00; //note: later look into a calloc like command
        end
    end

    always @(posedge clk) begin
        if (MemWrite) begin
                memory[address[15:2]] = writeData;
        end
    end 
    //this is almost 100% breaking the output of my program by flushing negative numbers at a edge case so come back later 
    assign readData = (MemRead) ? memory[address[15:2]]: 32'b0;
endmodule