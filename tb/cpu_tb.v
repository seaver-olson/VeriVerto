`timescale 1ps/1ps

module tb_cpu;

    reg clk;
    reg rst;
    wire instrCompleted;
    reg [31:0] totalCycles;
    reg [31:0] totalInstr;
    cpu dut(.clk(clk), .rst(rst), .WB_RegWrite_O(instrCompleted));

    initial begin
        clk = 1'b0;
        forever #(5) clk = ~clk;
    end 

    always @(posedge clk) begin
        if (rst) begin
            totalCycles <= 0;
            totalInstr <= 0;
        end else begin
            totalCycles <= totalCycles + 1;
            if (instrCompleted) begin
                totalInstr <= totalInstr +1;
            end
        end
    end

    initial begin
        rst = 1'b1;
        //wait for 3 cycles
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);


        rst = 1'b0;
        

        #20000
        
        $display("\n--- Performance Data ---");
        $display("Clock Period:                    10 ps");
        $display("Total Instructions Executed (I): %0d", totalInstr);
        $display("Total Clock Cycles (C):          %0d", totalCycles);
       
        $finish;
    end 

    
endmodule