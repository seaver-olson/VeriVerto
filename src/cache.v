//block size : 16 bytes (128 bits) or 4 words
//Direct-mapped, write-back, write-allocate cache
module L1Cache(
    input wire clk,
    input wire rst,
    //processor interface
    input wire proc_read,
    input wire proc_write,
    input wire proc_valid,
    input wire [31:0] proc_address,
    input wire [31:0] proc_write_data,
    output reg [31:0] proc_read_data,
    output reg cache_ready,

    //memory interface
    input wire [127:0] mem_read_data,
    input wire mem_ready,
    output reg mem_read,
    output reg mem_write,
    output reg mem_valid,
    output reg [31:0] mem_address,
    output reg [127:0] mem_write_data
);
    //FSM states
    localparam IDLE = 2'b00;
    localparam COMPARE_TAG = 2'b01;
    localparam WRITE_BACK = 2'b10;
    localparam ALLOCATE = 2'b11;
    
    reg [1:0] state;//state reg from Patterson and Hennessy 5.38

    reg [127:0] cacheMem [0:15];//(16 x 4 words = 64 words = 256 bytes) 4 tag bits + 1 valid bit + 1 dirty bit + 128 data bits = 134 bits per block
    reg [27:0] tagMem [0:15];//(16 blocks) full associativity 28 + 128 data bits = 156 bits per block
    reg validBit [0:15];
    reg dirtyBit [0:15];
    
    reg [3:0] evictIndex;//for next block to evict
    reg [3:0] hitIndex;//for hit block index
    wire muxMatch [0:15];
    reg match;

    genvar index;
    generate
        for (index = 0; index < 16; index = index + 1) begin
            comparator comp(.tag1(tagMem[index]), .tag2(proc_address[31:4]), .match(muxMatch[index]));
        end
    endgenerate

    //find which index hit
    integer i;
    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin
            if (muxMatch[i] & validBit[i]) begin
                hitIndex <= i;
                match <= 1'b1;
            end
        end
        case (proc_address[3:2])
            2'b00: proc_read_data = cacheMem[hitIndex][31:0];
            2'b01: proc_read_data = cacheMem[hitIndex][63:32];
            2'b10: proc_read_data = cacheMem[hitIndex][95:64];
            2'b11: proc_read_data = cacheMem[hitIndex][127:96];
            default: proc_read_data = 32'b0;
        endcase
    end 
    assign cache_ready = match & proc_valid & (state == COMPARE_TAG);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) begin
                validBit[i] <= 1'b0;
                dirtyBit[i] <= 1'b0;
            end
            evictIndex <= 4'b0000;
            mem_read <= 1'b0;
            hitIndex <= 4'b0000;
            mem_write <= 1'b0;
            mem_valid <= 1'b0;
            mem_address <= 32'b0;
            mem_write_data <= 128'b0;
            match <= 1'b0;
            proc_read_data <= 32'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (proc_valid) begin
                        state <= COMPARE_TAG;
                    end
                end
                COMPARE_TAG: begin
                    if (proc_valid) begin
                        if (match) begin
                            if (proc_write) begin
                                dirtyBit[hitIndex] <= 1'b1;
                                case (proc_address[3:2])
                                    2'b00: cacheMem[hitIndex][31:0] <= proc_write_data;
                                    2'b01: cacheMem[hitIndex][63:32] <= proc_write_data;
                                    2'b10: cacheMem[hitIndex][95:64] <= proc_write_data;
                                    2'b11: cacheMem[hitIndex][127:96] <= proc_write_data;
                                endcase
                            end
                            state <= IDLE;
                        end else begin
                            if (dirtyBit[evictIndex]) begin
                                //write back
                                mem_write <= 1'b1;
                                mem_valid <= 1'b1;
                                mem_address <= {tagMem[evictIndex], evictIndex, 4'b0000};
                                mem_write_data <= cacheMem[evictIndex];
                                state <= WRITE_BACK;
                            end else begin
                                //allocate
                                mem_read <= 1'b1;
                                mem_valid <= 1'b1;
                                mem_address <= {proc_address[31:4], 4'b0000};
                                state <= ALLOCATE;
                            end
                        end
                    end 
                end
                WRITE_BACK: begin
                    if (mem_ready) begin
                        //after write back, allocate
                        mem_write <= 1'b0;
                        mem_valid <= 1'b0;
                        mem_read <= 1'b1;
                        mem_valid <= 1'b1;
                        mem_address <= {proc_address[31:4], 4'b0000};
                        state <= ALLOCATE;
                    end
                end
                ALLOCATE: begin
                    if (mem_ready) begin
                        //load block into cache
                        cacheMem[evictIndex] <= mem_read_data;
                        tagMem[evictIndex] <= proc_address[31:4];
                        validBit[evictIndex] <= 1'b1;
                        dirtyBit[evictIndex] <= 1'b0;
                        //update evict index
                        evictIndex <= evictIndex + 1;
                        //reset memory interface signals
                        mem_read <= 1'b0;
                        mem_valid <= 1'b0;
                        //after allocation, go to COMPARE_TAG to recheck for hit
                        state <= COMPARE_TAG;
                    end
                end
            endcase
        end
    end

  
endmodule

module comparator(input wire [27:0] tag1, input wire [27:0] tag2, output wire match);
    assign match = (tag1 == tag2) ? 1'b1 : 1'b0;
endmodule

//Byte Addressable
module MainMemory(
    input wire clk,
    input wire rst,

    //memory interface
    input wire mem_read,
    input wire mem_write,
    input wire mem_valid,
    input wire [31:0] mem_address,
    input wire [127:0] mem_write_data,
    output reg [127:0] mem_read_data,
    output reg mem_ready 
);
    reg [127:0] memoryArray [0:1023]; //1024 blocks of 128 bits = 16KB memory

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_ready <= 1'b0;
            mem_read_data <= 128'b0;
        end else begin
            if (mem_valid) begin
                if (mem_read) begin
                    mem_read_data <= memoryArray[mem_address[11:4]]; //block aligned
                    mem_ready <= 1'b1;
                end else if (mem_write) begin
                    memoryArray[mem_address[11:4]] <= mem_write_data; //block aligned
                    mem_ready <= 1'b1;
                end
            end else begin
                mem_ready <= 1'b0;
            end
        end
    end
    
endmodule