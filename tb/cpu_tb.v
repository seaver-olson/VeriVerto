`timescale 1ps/1ps

module tb_cpu;

    reg clk;
    reg rst;
    reg regDump;
    cpu dut(.clk(clk), .rst(rst), .regDump(regDump) );

    initial begin
        clk = 1'b0;
        forever #(5) clk = ~clk;
    end 

    initial begin
        regDump = 1'b0;
        //forever #(100) regDump = ~regDump;
    end


    initial begin
        rst = 1'b1;
        //wait for 3 cycles
        @(posedge clk);

        rst = 1'b0;
        #20000

        $finish;
    end 

endmodule