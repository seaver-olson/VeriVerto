//i had chatGPT generate a testbench because I am lazy
`timescale 1ns/1ps

module tb_regfile;

    reg clk;
    reg rst;
    reg [4:0] readReg1;
    reg [4:0] readReg2;
    reg [4:0] writeReg;
    reg [31:0] writeData;
    reg rd_we;
    wire [31:0] regOut1;
    wire [31:0] regOut2;

    // Instantiate the regfile
    regfile uut (
        .clk(clk),
        .rst(rst),
        .readReg1(readReg1),
        .readReg2(readReg2),
        .writeReg(writeReg),
        .writeData(writeData),
        .rd_we(rd_we),
        .regOut1(regOut1),
        .regOut2(regOut2)
    );

    // Clock generator
    always #5 clk = ~clk; // 10 ns period (100 MHz)

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        rd_we = 0;
        readReg1 = 0;
        readReg2 = 0;
        writeReg = 0;
        writeData = 0;

        // Apply reset
        #12 rst = 0;

        // Write to register x5
        writeReg = 5'd5;
        writeData = 32'hA5A5A5A5;
        rd_we = 1;
        #10; // wait for posedge
        rd_we = 0;

        // Read back from x5
        readReg1 = 5'd5;
        #1;
        $display("ReadReg1 (x5) = %h (expect A5A5A5A5)", regOut1);

        // Try writing to x0 (should be ignored)
        writeReg = 5'd0;
        writeData = 32'hFFFFFFFF;
        rd_we = 1;
        #10;
        rd_we = 0;

        // Read back from x0 (should still be 0)
        readReg1 = 5'd0;
        #1;
        $display("ReadReg1 (x0) = %h (expect 00000000)", regOut1);

        // Write to x10, then read through both ports
        writeReg = 5'd10;
        writeData = 32'h12345678;
        rd_we = 1;
        #10;
        rd_we = 0;
        readReg1 = 5'd10;
        readReg2 = 5'd5;
        #1;
        $display("ReadReg1 (x10) = %h (expect 12345678)", regOut1);
        $display("ReadReg2 (x5)  = %h (expect A5A5A5A5)", regOut2);

        $stop;
    end
endmodule
