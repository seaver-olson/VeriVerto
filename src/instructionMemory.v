//memory2c had a lot of overhead as it accounted for writing as well however other than the inital load of instructions instruction memory should be read only
module instructionMemory(
    input wire [31:0] readAddress, //hook to PC later
    output wire [31:0] instruction
);
    reg [7:0] mem [0:65535];//64K bytes of memory
    integer i;
    
    assign instruction = {mem[readAddress+3],mem[readAddress+2],mem[readAddress+1],mem[readAddress]};
    initial begin
        
        for (i = 0; i < 65536; i=i+1) begin
            mem[i] = 8'b0;
        end
        $readmemh("loadfile_all.img", mem);
    end

endmodule