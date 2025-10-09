module dataMemory(
    input wire clk,
    input wire MemWrite,
    input wire MemRead,
    input wire [31:0] address,
    input wire [31:0] writeData,
    output wire [31:0] readData
);
    reg [31:0] memory [0:16383];
    integer i;
    //init memory and delete garbage
    initial begin
        for (i = 0; i < 16384; i = i + 1) begin
            memory[i] = 32'd0; //note: later look into a calloc like command
        end
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address[15:2]] <= writeData;
        end
    end 
    
    assign readData = (MemRead) ? memory[address[15:2]] : 32'b0;
endmodule