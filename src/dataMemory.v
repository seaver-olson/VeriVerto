module dataMemory(
    input wire clk,
    input wire MemWrite,
    input wire MemRead,
    input wire [31:0] address,
    input wire [31:0] writeData,
    output reg [31:0] readData
);
    reg [7:0] memory [0:65535];//64KB
    integer i;
    
    //init memory and delete garbage
    initial begin
        for (i = 0; i < 65535; i = i + 1) begin
            memory[i] <= 8'b00000000; //note: later look into a calloc like command
        end
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            if (address == 32'hFFFF0000) begin
                $display("Exposed Data: %h\n", writeData);
            end else begin 
                $display("NonExposed Address: %h\n", address);
                memory[address[15:0]] <= writeData[7:0];
                memory[address[15:0]+1] <= writeData[15:8];
                memory[address[15:0]+2] <= writeData[23:16];
                memory[address[15:0]+3] <= writeData[31:24];
            end
        end
    end 
    //this is almost 100% breaking the output of my program by flushing negative numbers at a edge case so come back later 
    assign readData =   (MemRead) ? {memory[address[15:0]+3], memory[address[15:0]+2], memory[address[15:0]+1], memory[address[15:0]]}
                        : 32'b0;
                        
endmodule