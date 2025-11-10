module L1_ROM_Cache(
    input wire clk,
    input wire rst,
    //proc interface
    input wire [31:0] proc_addr,
    input wire proc_req,//combined read and valid signals
    output reg [31:0] proc_data,
    output reg proc_ready,

    //main memory interface
    output reg mem_read_req,
    output reg [31:0] mem_addr,
    input wire [127:0] mem_data,
    input wire mem_ready
);
    localparam LINE_COUNT = 16;
    localparam LINE_SIZE = 128;//bits
    localparam IDLE = 2'b00;
    localparam MEM_REQ = 2'b01;
    localparam MEM_WAIT = 2'b10;

    reg [1:0] state;
    integer i;

    reg [127:0] cache_mem [0:LINE_COUNT-1];
    reg [27:0] tag_array [0:LINE_COUNT-1];
    reg [LINE_COUNT-1:0] valid_array;
    reg [7:0] lru_counter [0:LINE_COUNT-1];//fix later

    wire [27:0] proc_tag;
    assign proc_tag = proc_addr[31:4];

    wire [1:0] proc_offset;
    assign proc_offset = proc_addr[3:2];

    wire [LINE_COUNT-1:0] tag_match;
    wire [$clog2(LINE_COUNT)-1:0] hit_block;
    wire [$clog2(LINE_COUNT)-1:0] victim_block;
    wire hit;
    function [$clog2(LINE_COUNT)-1:0] find_hit_index(input [LINE_COUNT-1:0] matches);
        integer idx;
        begin
            find_hit_index = 0;
            for (idx = 0; idx < LINE_COUNT; idx = idx + 1) begin
                if (matches[idx]) begin
                    find_hit_index = idx;
                end
            end
        end
    endfunction

    genvar j;
    generate
        for (j = 0; j < LINE_COUNT; j = j + 1) begin : tag_comparators
            comparator tag_comp(
                .tag1(tag_array[j]),
                .validBit(valid_array[j]),
                .tag2(proc_tag),
                .match(tag_match[j])
            );
        end
    endgenerate 

    assign hit = |(tag_match);
    assign hit_block = find_hit_index(tag_match);

    function [$clog2(LINE_COUNT)-1:0] find_victim(input dummy);
        integer idx;
        reg [$clog2(LINE_COUNT)-1:0] max_lru;
        begin 
            max_lru = 0;
            for (idx = 1; idx < LINE_COUNT; idx = idx + 1) begin
                if (lru_counter[idx] > lru_counter[max_lru]) begin
                    max_lru = idx;
                end
            end
            find_victim = max_lru;
        end
    endfunction

    assign victim_block = find_victim(0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            proc_ready <= 1'b0;
            proc_data <= 32'b0;
            mem_addr <= 32'b0;
            mem_read_req <= 1'b0;
            for (i = 0; i < LINE_COUNT; i = i + 1) begin
                valid_array[i] <= 1'b0;
                cache_mem[i] <= 128'b0;
                tag_array[i] <= 28'b0;
                lru_counter[i] <= 0;
            end
        end else begin
            case (state)
                IDLE: begin
                    proc_ready <= 1'b0;
                    mem_read_req <= 1'b0;

                    if (proc_req) begin
                        if (hit) begin
                            case (proc_offset)
                                2'b00: proc_data <= cache_mem[hit_block][31:0];
                                2'b01: proc_data <= cache_mem[hit_block][63:32];
                                2'b10: proc_data <= cache_mem[hit_block][95:64];
                                2'b11: proc_data <= cache_mem[hit_block][127:96];
                            endcase
                            proc_ready <= 1'b1;
                            //update LRU counters
                            for (i = 0; i < LINE_COUNT; i = i + 1) begin
                                lru_counter[i] <= lru_counter[i] + 1;
                            end
                            lru_counter[hit_block] <= 0;//this block was just touched, reset lru counter 
                        end else begin
                            state <= MEM_REQ;
                        end
                    end
                end 

                MEM_REQ: begin
                    mem_read_req <= 1'b1;
                    mem_addr <= {proc_tag, 4'b0000};
                    state <= MEM_WAIT;
                end

                MEM_WAIT: begin
                    if (mem_ready) begin
                        cache_mem[victim_block] <= mem_data;
                        tag_array[victim_block] <= proc_tag;
                        valid_array[victim_block] <= 1'b1;

                        case (proc_offset)
                            2'b00: proc_data <= mem_data[31:0];
                            2'b01: proc_data <= mem_data[63:32];
                            2'b10: proc_data <= mem_data[95:64];
                            2'b11: proc_data <= mem_data[127:96];
                        endcase
                        proc_ready <= 1'b1;

                        //update LRU counters
                        for (i = 0; i < LINE_COUNT; i = i + 1) begin
                            lru_counter[i] <= lru_counter[i] + 1;
                        end
                        lru_counter[victim_block] <= 0;//this block was just touched, reset lru counter
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    
    end
endmodule

module L1_RAM_Cache(
    input wire clk,
    input wire rst,
    //proc interface
    input wire [31:0] proc_addr,
    input wire proc_read,
    input wire proc_write,
    input wire proc_valid,
    input wire [31:0] proc_writeData,
    output reg [31:0] proc_data,
    output reg proc_ready,
    //main memory interface
    output reg mem_read,
    output reg mem_write,
    output reg [31:0] mem_addr,
    output reg [127:0] mem_writeData,
    input wire [127:0] mem_data,
    input wire mem_ready
);
    localparam LINE_COUNT = 16;
    localparam LINE_SIZE = 128;
    localparam IDLE = 2'b00;
    localparam TAG_CHECK = 2'b01;
    localparam ALLOCATE = 2'b10;
    localparam WRITEBACK = 2'b11;

    reg [1:0] state;
    integer i;

    reg [127:0] cache_mem [0:LINE_COUNT-1];
    reg [27:0] tag_array [0:LINE_COUNT-1];
    reg [LINE_COUNT-1:0] valid_array;
    reg [LINE_COUNT-1:0] dirty_array;
    reg [7:0] lru_counter [0:LINE_COUNT-1];
    
endmodule

module comparator(
    input wire [27:0] tag1,
    input wire validBit,
    input wire [27:0] tag2,
    output wire match
);
    assign match = ((tag1 == tag2) & validBit) ? 1'b1 : 1'b0;
    
endmodule

module MainMemory(
    input wire clk,
    input wire rst,
    input wire read_req,
    input wire [31:0] addr,
    output reg [127:0] data_out,
    output reg ready
);
    reg [127:0] memory [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 128'b0;
        end
    end

    initial begin
        memory[0]  = 128'h0000_1111_2222_3333_4444_5555_6666_7777;
        memory[1]  = 128'hAAAA_BBBB_CCCC_DDDD_EEEE_FFFF_1111_2222;
        memory[2]  = 128'h1234_5678_9ABC_DEF0_1111_2222_3333_4444;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ready <= 1'b0;
            data_out <= 128'b0;
        end else begin
            if (read_req) begin
                data_out <= memory[addr[11:4]];
                ready <= 1'b1;
            end else begin
                ready <= 1'b0;
            end
        end
    end
endmodule