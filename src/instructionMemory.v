//memory2c had a lot of overhead as it accounted for writing as well however other than the inital load of instructions instruction memory should be read only
module instructionMemory(
    input wire [31:0] readAddress, //hook to PC later
    output wire [31:0] instruction
);
    reg [31:0] memory [0:16383];//64K bytes of memory

    initial begin
        integer i;
        for (i = 0; i < 16384; i=i+1) begin
            memory[i] = 32'd0;
        end
        $readmemh("loadfile_all.img", memory);
    end

    always @(*) begin
        assign instruction = memory[readAddress[15:2]]; //word - 2 bit offset
    end
endmodule