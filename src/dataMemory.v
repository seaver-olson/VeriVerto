module dataMemory(
    input wire clk,
    input wire MemWrite,
    input wire MemRead,
    input wire [31:0] address,
    input wire [31:0] writeData,
    output reg [31:0] readData
);
    reg [7:0] memory [0:131071];//128KB
    integer i;
    //init memory and delete garbage
    initial begin
        for (i = 0; i < 131072; i = i + 1) begin
            memory[i] = 8'h00; //note: later look into a calloc like command
        end
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            if (address == 32'hFFFF0000) begin
                $display(">>> PROGRAM OUTPUT: %0d", writeData);
            end else begin
                memory[address+3] <= writeData[31:24];  
                memory[address+2] <= writeData[23:16]; 
                memory[address+1] <= writeData[15:8]; 
                memory[address] <= writeData[7:0];
            end
        end
    end 
    
    assign readData = (MemRead) ? {memory[address+3],memory[address+2],memory[address+1],memory[address]}: 32'b0;
endmodule