//block size : 16 bytes (128 bits) or 4 words
//later possibly add two extra states: read and write for compare tag and write buffer
module L1(
    input wire clk,
    input wire rst,

    //processor interface
    input wire proc_read,
    input wire proc_write,
    input wire proc_valid,
    input wire [31:0] proc_address,
    input wire [31:0] proc_write_data,
    output reg [31:0] proc_read_data,
    output reg proc_ready,//is operation complete

    //memory interface
    output reg mem_read,
    output reg mem_write,
    output reg mem_valid,
    output reg [31:0] mem_address,
    output reg [127:0] mem_write_data,
    input wire [127:0] mem_read_data,
    input wire mem_ready
);
    //FSM states
    localparam IDLE = 2'b00;
    localparam COMPARE_TAG = 2'b01;
    localparam WRITE_BACK = 2'b10;
    localparam ALLOCATE = 2'b11;
    
    reg [1:0] state;//state reg from Patterson and Hennessy 5.38

    reg [127:0] cacheMem [0:1023];//data
    reg [17:0] tagMem [0:1023];//tags (31-14) 
    reg validBits [0:1023];//valid bits
    reg dirtyBits [0:1023];//dirty bits

    //address breakdown
    wire [17:0] address_tag = proc_address[31:14];//18 bits for tag
    wire [9:0] address_index = proc_address[13:4];//10 bits for 1024 blocks  
    wire [1:0] address_offset = proc_address[3:2];//4 which word in block
    wire [1:0] address_byte_offset = proc_address[1:0];//(which byte) add later
    //if the tag we are looking for matches a tag in the cache
    wire tag_match = (tagMem[address_index] == address_tag) ? 1'b1 : 1'b0;
    wire cache_hit = (tag_match && validBits[address_index]) ? 1'b1 : 1'b0;

    //saved requests for multi-cycle ops
    reg saved_write, saved_read;
    reg [31:0] saved_address;
    reg [31:0] saved_write_data;

    integer i;//for clearing dirty and valid bits on reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            state <= IDLE;
            proc_ready <= 0;
            mem_read <= 0;
            mem_write <= 0;
            mem_valid <= 0;
            for (i = 0; i < 1024; i = i + 1) begin
                validBits[i] <= 0;
                dirtyBits[i] <= 0;
            end
        end else begin
            case (state)
                IDLE: begin
                    proc_ready <= 1'b0;
                    mem_valid <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    if (proc_valid) begin
                        //save data for next cycle and switch states
                        saved_address <= proc_address;
                        saved_write_data <= proc_write_data;
                        saved_read <= proc_read;
                        saved_write <= proc_write;
                        state <= COMPARE_TAG;
                    end
                end
                COMPARE_TAG: begin
                  if (cache_hit) begin
                    //write hit == update cache
                    if (saved_write) begin
                        case (address_offset) //which word in block do we write to 
                            2'b00: cacheMem[saved_address[13:4]][31:0]   <= saved_write_data;
                            2'b01: cacheMem[saved_address[13:4]][63:32]  <= saved_write_data;
                            2'b10: cacheMem[saved_address[13:4]][95:64]  <= saved_write_data;
                            2'b11: cacheMem[saved_address[13:4]][127:96] <= saved_write_data;
                        endcase
                        dirtyBits[address_index] <= 1'b1;//marked dirty so memory write back later
                    // read hit == read from cache
                    end else if (saved_read) begin
                        case (address_offset)//which word in block do we read from 
                            2'b00: proc_read_data <= cacheMem[address_index][31:0];
                            2'b01: proc_read_data <= cacheMem[address_index][63:32];
                            2'b10: proc_read_data <= cacheMem[address_index][95:64];
                            2'b11: proc_read_data <= cacheMem[address_index][127:96];
                        endcase
                    end
                    proc_ready <= 1'b1;
                    state <= IDLE;
                  //cache miss
                  end else begin
                    proc_ready <= 1'b0;//test later to see if needed
                    if (dirtyBits[saved_address[13:4]] && validBits[saved_address[13:4]]) begin
                        //miss and dirty = write back
                        mem_write <= 1'b1;
                        mem_read <= 1'b0;
                        mem_valid <= 1'b1;

                        mem_address <= {tagMem[saved_address[13:4]], saved_address[13:4], 4'b0000};//block aligned address
                        mem_write_data <= cacheMem[saved_address[13:4]];
                        state <= WRITE_BACK;
                    end else begin
                        //miss and clean = allocate
                        mem_read <= 1'b1;
                        mem_write <= 1'b0;
                        mem_valid <= 1'b1;
                        mem_address <= {saved_address[31:4], 4'b0000};//block aligned address
                        state <= ALLOCATE;
                    end
                  end
                end
                WRITE_BACK: begin
                    if (mem_ready) begin
                        mem_write <= 1'b0;
                        mem_valid <= 1'b1;
                        mem_read <= 1'b1;
                        mem_address <= {saved_address[31:4], 4'b0000};
                        dirtyBits[saved_address[13:4]] <= 1'b0;//mark as clean
                        state <= ALLOCATE;
                    end 
                end
                ALLOCATE: begin
                    if (mem_ready) begin
                        mem_read <= 1'b0;
                        mem_valid <= 1'b0;

                        cacheMem[saved_address[13:4]] <= mem_read_data;
                        tagMem[saved_address[13:4]] <= saved_address[31:14];
                        validBits[saved_address[13:4]] <= 1'b1;
                        dirtyBits[saved_address[13:4]] <= 1'b0;
                        
                        //retry access(will hit if i didnt mess up)
                        state <= COMPARE_TAG;
                    end
                end
            endcase
        end    
    end
endmodule

module MainMemory(
   input wire clk,

   //memory interface
   input wire mem_read,
   input wire mem_write,
   input wire mem_valid,
   input wire [31:0] address,
   input wire [127:0] mem_write_data,
   output reg [127:0] mem_read_data,
   output wire mem_ready 
);
    reg [127:0] memory [0:4095];//64KB memory

    initial begin
        $readmemh("loadfile_all.img", memory);//tagging means I don't need to clear memory before loading file
    end
    
    always @(posedge clk) begin
        if (mem_valid) begin
            if (mem_write) begin
                memory[address] <= mem_write_data;
            end else if (mem_read) begin
                mem_read_data <= memory[address];
            end
        end
    end
    assign mem_ready = mem_valid; //very simple model of memory so it is always ready next cycle 
endmodule