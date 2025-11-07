`timescale 1ns/1ps

module tb_L1Cache();
    reg clk;
    reg rst;

    // Processor interface - Changed to reg so we can drive them
    reg proc_read;
    reg proc_write;
    reg proc_valid;
    reg [31:0] proc_address;
    reg [31:0] proc_write_data;  // Fixed: 32 bits, not 128
    wire [31:0] proc_read_data;  // Fixed: 32 bits, not 128
    wire proc_ready;

    // Memory interface
    wire mem_read;
    wire mem_write;
    wire mem_valid;
    wire [31:0] mem_address;
    wire [127:0] mem_write_data;
    wire [127:0] mem_read_data;
    wire mem_ready;

    
    L1Cache cache_inst (
        .clk(clk),
        .rst(rst),
        .proc_read(proc_read),
        .proc_write(proc_write),
        .proc_valid(proc_valid),
        .proc_address(proc_address),
        .proc_write_data(proc_write_data),
        .proc_read_data(proc_read_data),
        .cache_ready(proc_ready),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_valid(mem_valid),
        .mem_address(mem_address),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data),
        .mem_ready(mem_ready)
    );

    MainMemory mem_inst (
        .clk(clk),
        .rst(rst),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_valid(mem_valid),
        .mem_address(mem_address),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data),
        .mem_ready(mem_ready)
    );
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 50MHz clock
    end
    initial begin
        rst = 1;
        proc_read = 0;
        proc_write = 0;
        proc_valid = 0;
        proc_address = 32'b0;
        proc_write_data = 32'b0;
        #20;
        rst = 0;
        $display("Starting Testbench");
        #20;
    
        #20;
        proc_valid = 1;
        proc_write = 0;
        // Read from address 0x00000000
        #20;
        proc_read = 1;
        proc_valid = 1;
        proc_address = 32'h00000001;
        #20;
        
        #4000;
    end
endmodule