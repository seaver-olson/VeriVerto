module pcUnit(
    input wire clk,
    input wire rst,
    //Mux flag: (zero AND branch)
    input wire branch,
    input wire zero,
    input wire [31:0] branchDest,
    output wire [31:0] pc
);
    wire [31:0] pcPlus4;
    wire [31:0] pcNext;
    wire pcSrc;

    assign pcPlus4 = pc+4;

    wire branchSelect = branch & zero; //AND gate seen top right of diagram
    assign pcNext = (branchSelect) ? branchDest : pcPlus4;//If branchSelect then pc = branch dest else pc = pc + 4
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h0;
        end else begin
            pc <= pcNext;
        end
    end

    
endmodule