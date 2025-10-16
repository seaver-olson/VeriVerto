//memory2c had a lot of overhead as it accounted for writing as well however other than the inital load of instructions instruction memory should be read only
module instructionMemory(
    input wire [31:0] readAddress, //hook to PC later
    output wire [31:0] instruction
);
    reg [7:0] mem [0:65535];//64K bytes of memory
    integer i;
    wire [15:0] effAddr = readAddress[15:0];
    //PC is byte addressable so it's easier to break instructions up like this
    assign instruction = {mem[effAddr+3],mem[effAddr+2],mem[effAddr+1],mem[effAddr]};
    initial begin
        for (i = 0; i < 65536; i=i+1) begin
            mem[i] = 8'b0;
        end
        $readmemh("loadfile_all.img", mem);
    end
endmodule