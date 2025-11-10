`timescale 1ns/1ps

module BTB_tb;
    parameter ENTRIES = 16;
    parameter CLK_PERIOD = 10;

    reg clk;
    reg rst;
    reg branch_resolved;
    reg branch_taken;
    reg [31:0] branch_pc;
    reg [31:0] branch_target;
    reg [31:0] fetch_pc;
    wire predict_taken;
    wire [31:0] predict_target;

    BTB dut (
        .clk(clk),
        .rst(rst),
        .branch_resolved(branch_resolved),
        .branch_taken(branch_taken),
        .branch_pc(branch_pc),
        .branch_target(branch_target),
        .fetch_pc(fetch_pc),
        .predict_taken(predict_taken),
        .predict_target(predict_target)
    );
    defparam dut.ENTRIES = ENTRIES;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    integer i;

    initial begin
        rst = 1;
        branch_resolved = 0;
        branch_taken = 0;
        branch_pc = 32'b0;
        branch_target = 32'b0;
        fetch_pc = 32'b0;
        #(CLK_PERIOD);
        rst = 0;
        #(CLK_PERIOD);

        $display("\n[Test 1] Insert PC=0x1000 -> Target=0x2000 (taken)");
        branch_resolved = 1;
        branch_taken = 1;
        branch_pc = 32'h00001000;
        branch_target = 32'h00002000;
        #(CLK_PERIOD);
        branch_resolved = 0;
        #(CLK_PERIOD);

        fetch_pc = 32'h00001000;
        #(CLK_PERIOD);
        $display("Predict_taken=%b  Predict_target=%h", predict_taken, predict_target);

        $display("\n[Test 3] Strengthen prediction (multiple taken)");
        for (i = 0; i < 3; i = i + 1) begin
            branch_resolved = 1;
            branch_taken = 1;
            branch_pc = 32'h00001000;
            branch_target = 32'h00002000;
            #(CLK_PERIOD);
            branch_resolved = 0;
            #(CLK_PERIOD);
        end

        fetch_pc = 32'h00001000;
        #(CLK_PERIOD);
        $display("After training: Predict_taken=%b Target=%h", predict_taken, predict_target);

        $display("\n[Test 4] Train NOT taken several times");
        for (i = 0; i < 4; i = i + 1) begin
            branch_resolved = 1;
            branch_taken = 0;
            branch_pc = 32'h00001000;
            branch_target = 32'h00002000;
            #(CLK_PERIOD);
            branch_resolved = 0;
            #(CLK_PERIOD);
        end

        fetch_pc = 32'h00001000;
        #(CLK_PERIOD);
        $display("After not-taken training: Predict_taken=%b", predict_taken);

        $display("\n[Test 5] Fill BTB to cause replacement");
        for (i = 0; i < ENTRIES + 2; i = i + 1) begin
            branch_resolved = 1;
            branch_taken = 1;
            branch_pc = 32'h00003000 + (i * 4);
            branch_target = 32'h00004000 + (i * 4);
            #(CLK_PERIOD);
            branch_resolved = 0;
            #(CLK_PERIOD);
        end

        $display("BTB should now have tested replacement.");

        fetch_pc = 32'h00003000 + ((ENTRIES - 1) * 4);
        #(CLK_PERIOD);
        $display("Predict_taken=%b Predict_target=%h", predict_taken, predict_target);


        $display("\n==== BTB TEST COMPLETE ====");
        #(5 * CLK_PERIOD);
        $finish;
    end

endmodule
