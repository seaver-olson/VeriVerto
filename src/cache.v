//block size : 16 bytes (128 bits) or 4 words

module L1(
    input wire rw_sig,
    input wire valid_sig,
    input wire [31:0] address,
    input wire [31:0] proc_to_cache,
    output wire [31:0] cache_to_proc,
    output wire comp_sig
    );
    reg [127:0] cacheMem [0:1023];
    always @(posedge valid_sig) begin
        if (rw_sig) begin
            cacheMem[address] <= proc_to_cache;//100% wrong but just here for placeholder
        end
    end

    assign cache_to_proc = (rw_sig == 0 && valid_sig) ? cacheMem[address] : 32'h00;
endmodule

module MainMemory(
   input wire clk,
   input wire rw_sig,//if 1 : write
   input wire valid_sig,
   input wire [31:0] address,
   input wire [127:0] cache_to_mem,
   output wire [127:0] mem_to_cache,
   output wire comp_sig
);
    reg [128:0] memory [0:66535];

    initial begin
        $readmemh("loadfile_all.img", memory);//tagging means I don't need to clear memory before loading file
    end

    always @(posedge clk) begin
        if (rw_sig && valid_sig) begin
            mem_to_cache <= {memory[address+16],
                             memory[address+15],
                             memory[address+14],
                             memory[address+13],
                             memory[address+12],
                             memory[address+11],
                             memory[address+10],
                             memory[address+9],
                             memory[address+8],
                             memory[address+7],
                             memory[address+6],
                             memory[address+5],
                             memory[address+4],
                             memory[address+3],
                             memory[address+2],
                             memory[address+1],
                             memory[address]
                             };
            comp_sig <= 1;
        end
    end
    
 
endmodule