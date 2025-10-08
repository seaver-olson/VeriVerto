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

        #10
        //applies reset for 2 cycles
        rst = 1'b0;

        #200
        $finish;
    end 
endmodule