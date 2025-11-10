`timescale 1ns/1ps

module tb_L1_ROM_Cache;
    reg clk;
    reg rst;
    reg [31:0] proc_addr;
    reg proc_req;
    wire [31:0] proc_data;
    wire proc_ready;

    // Memory interface wires
    wire mem_read_req;
    wire [31:0] mem_addr;
    wire [127:0] mem_data;
    wire mem_ready;

    // Instantiate L1 ROM Cache
    L1_ROM_Cache dut (
        .clk(clk),
        .rst(rst),
        .proc_addr(proc_addr),
        .proc_req(proc_req),
        .proc_data(proc_data),
        .proc_ready(proc_ready),
        .mem_read_req(mem_read_req),
        .mem_addr(mem_addr),
        .mem_data(mem_data),
        .mem_ready(mem_ready)
    );

    // Instantiate Main Memory
    MainMemory mem (
        .clk(clk),
        .rst(rst),
        .read_req(mem_read_req),
        .addr(mem_addr),
        .data_out(mem_data),
        .ready(mem_ready)
    );

    // Generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Initialize memory with known values
    initial begin
        // Wait for memory initialization
        #1;
        mem.memory[0]  = 128'h0000_1111_2222_3333_4444_5555_6666_7777;
        mem.memory[16] = 128'hAAAA_BBBB_CCCC_DDDD_EEEE_FFFF_1111_2222;
        mem.memory[32] = 128'h1234_5678_9ABC_DEF0_1111_2222_3333_4444;
    end

    // Test stimulus
    initial begin
        $display("---- L1_ROM_Cache Testbench Start ----");
        rst = 1;
        proc_req = 0;
        proc_addr = 0;
        #20;
        rst = 0;
        #20;

        // 1️⃣ First access (MISS, should fetch from memory)
        proc_addr = 32'h0000_0000;
        proc_req = 1;
        @(posedge proc_ready);
        $display("[%0t] Read from 0x%h -> Data = 0x%h (MISS)", $time, proc_addr, proc_data);
        proc_req = 0;
        #20;

        // 2️⃣ Access the same address again (HIT)
        proc_addr = 32'h0000_0000;
        proc_req = 1;
        @(posedge proc_ready);
        $display("[%0t] Read from 0x%h -> Data = 0x%h (HIT)", $time, proc_addr, proc_data);
        proc_req = 0;
        #20;

        // 3️⃣ Access another address (MISS)
        proc_addr = 32'h0000_0010; // new line (addr 16)
        proc_req = 1;
        @(posedge proc_ready);
        $display("[%0t] Read from 0x%h -> Data = 0x%h (MISS)", $time, proc_addr, proc_data);
        proc_req = 0;
        #20;

        // 4️⃣ Access again (HIT)
        proc_addr = 32'h0000_0010;
        proc_req = 1;
        @(posedge proc_ready);
        $display("[%0t] Read from 0x%h -> Data = 0x%h (HIT)", $time, proc_addr, proc_data);
        proc_req = 0;
        #20;

        // 5️⃣ Access third block
        proc_addr = 32'h0000_0020;
        proc_req = 1;
        @(posedge proc_ready);
        $display("[%0t] Read from 0x%h -> Data = 0x%h (MISS)", $time, proc_addr, proc_data);
        proc_req = 0;
        #20;

        $display("---- L1_ROM_Cache Testbench Complete ----");
        $finish;
    end
endmodule
