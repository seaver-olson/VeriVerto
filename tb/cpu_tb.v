`timescale 1ps/1ps

module tb_cpu;

    reg clk;
    reg rst;

    cpu dut(.clk(clk), .rst(rst));

    initial begin
        clk = 1'b0;
        forever #(5) clk = ~clk;
    end 

    initial begin
        rst = 1'b1;
        //wait for 2 cycles
        @(posedge clk); 
        @(posedge clk);

        rst = 1'b0;

        #20000
        $finish;
    end 
endmodule