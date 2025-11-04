`timescale 1ns/1ps

module tb_L1();
    reg clk;
    reg rst;

    wire proc_read;
    wire proc_write;
    wire proc_valid;
    wire [31:0] proc_address;
    wire [127:0] proc_write_data;
    wire [127:0] proc_read_data;
    wire proc_ready;

    wire mem_read;
    wire mem_write;
    wire mem_valid;
    wire [31:0] mem_address;
    wire [127:0] mem_write_data;
    reg [127:0] mem_read_data;
    reg mem_ready;

    L1 dut(.clk(clk),
           .rst(rst),
           .proc_read(proc_read),
           .proc_write(proc_write),
           .proc_valid(proc_valid),
           .proc_address(proc_address),
           .proc_write_data(proc_write_data),
           .proc_read_data(proc_read_data),
           .proc_ready(proc_ready),
           .mem_read(mem_read),
           .mem_write(mem_write),
           .mem_valid(mem_valid),
           .mem_address(mem_address),
           .mem_write_data(mem_write_data),
           .mem_read_data(mem_read_data),
           .mem_ready(mem_ready)
    );

    MainMemory mem(.clk(clk),
                     .mem_read(mem_read),
                     .mem_write(mem_write),
                     .mem_valid(mem_valid),
                     .address(mem_address),
                     .mem_write_data(mem_write_data),
                     .mem_read_data(mem_read_data),
                     .mem_ready(mem_ready)
    );

    always #5 clk = ~clk;

    initial begin
        //initialize signals
        clk = 0;
        rst = 0;

        rst = 1;
        #10;
        rst = 0;
        #10;
        

        #200;
        $finish;
    end
endmodule
