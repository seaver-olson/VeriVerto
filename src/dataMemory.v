module dataMemory(
    input wire clk,
    input wire MemWrite,
    input wire MemRead,
    input wire [31:0] address,
    input wire [31:0] writeData,
    output wire [31:0] readData
);
    reg [7:0] memory [0:65535];
    integer i;
    //init memory and delete garbage
    initial begin
        for (i = 0; i < 65536; i = i + 1) begin
            memory[i] = 8'b0; //note: later look into a calloc like command
        end
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address+3] = writeData[31:24];  
	        memory[address+2] = writeData[23:16]; 
	        memory[address+1] = writeData[15:8]; 
	        memory[address] = writeData[7:0];
        end
    end 
    
    assign readData = (MemRead) ? {memory[address+3],memory[address+2],memory[address+1],memory[address]}: 32'b0;
endmodule