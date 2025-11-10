module BTB(
    input wire clk,
    input wire rst,
    //branch resolution inputs
    input wire branch_resolved,
    input wire branch_taken,
    input wire [31:0] branch_pc,
    input wire [31:0] branch_target,

    //fetch stage inputs
    input wire [31:0] fetch_pc,
    output reg predict_taken,
    output reg [31:0] predict_target
);

    localparam ENTRIES = 16;
    
    reg [31:0] btb_pc [0:ENTRIES-1];
    reg [31:0] btb_target [0:ENTRIES-1];
    reg [1:0] btb_state [0:ENTRIES-1];
    reg btb_valid [0:ENTRIES-1];
    reg [7:0] lru_counter [0:ENTRIES-1];

    integer i;

    reg [3:0] hit_index;
    reg hit;

    always @(*) begin
        hit = 0;
        hit_index = 0;
        for (i = 0; i < ENTRIES; i = i + 1) begin
            if (btb_valid[i] && btb_pc[i] == fetch_pc) begin
                hit = 1;
                hit_index = i[3:0];
            end
        end

        if (hit && btb_state[hit_index] >= 2'b10) begin
            predict_taken = 1'b1;
            predict_target = btb_target[hit_index];
        end else begin
            predict_taken = 1'b0;
            predict_target = 32'b0;
        end
    end

    integer lru_max;
    integer replace_index;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < ENTRIES; i = i + 1) begin
                btb_valid[i]   <= 1'b0;
                btb_pc[i]      <= 32'b0;
                btb_target[i]  <= 32'b0;
                btb_state[i]   <= 2'b00;
                lru_counter[i] <= 8'd0;
            end
        end else if (branch_resolved) begin
            hit = 0;
            for (i = 0; i < ENTRIES; i = i + 1) begin
                if (btb_valid[i] && btb_pc[i] == branch_pc) begin
                    hit = 1;
                    hit_index = i[3:0];
                end
            end

            // if no match, find LRU
            if (!hit) begin
                lru_max = 0;
                replace_index = 0;
                for (i = 0; i < ENTRIES; i = i + 1) begin
                    if (!btb_valid[i]) begin
                        replace_index = i;
                        lru_max = 256; // break early
                    end else if (lru_counter[i] > lru_max) begin
                        lru_max = lru_counter[i];
                        replace_index = i;
                    end
                end
                hit_index = replace_index[3:0];//replace index becomes the new hit index
            end

            //update BTB entry
            btb_valid[hit_index] <= 1'b1;
            btb_pc[hit_index] <= branch_pc;//if hit then it will overwrite same pc for simplicity
            btb_target[hit_index] <= branch_target;//same here they basically become no ops on hit

            //update 2-bit saturating counter
            if (branch_taken) begin
                if (btb_state[hit_index] < 2'b11)
                    btb_state[hit_index] <= btb_state[hit_index] + 1;
            end else begin
                if (btb_state[hit_index] > 2'b00)
                    btb_state[hit_index] <= btb_state[hit_index] - 1;
            end
            //update LRU counters
            for (i = 0; i < ENTRIES; i = i + 1) begin
                if (i == hit_index)//if it was just used, reset counter
                    lru_counter[i] <= 8'd0;
                else if (btb_valid[i])//only increment valid entries
                    lru_counter[i] <= lru_counter[i] + 1;
            end
        end
    end
endmodule
