module pcUnit(
    input wire clk,
    input wire rst,
    //Mux flag: (zero AND branch)
    input wire branch,
    input wire zero,
    input wire jump, //for JAL/JALR
    input wire [31:0] branchDest,
    input wire [31:0] jumpBase, //JALR requires a base add from regOut1
    input wire jalrFlag,
    output reg [31:0] pc
);  
    wire [31:0] pcPlus4;
    wire [31:0] pcNext;
    wire branchSelect;
    wire [31:0] jumpTarget;//jumpBase + offset

    assign pcPlus4 = pc+4;
    assign branchSelect = branch & zero; //AND gate seen top right of diagram
    assign jumpTarget = (jalrFlag) ? ((jumpBase + branchDest) & ~32'h1) : (pc + branchDest);
    assign pcNext = (jump) ? jumpTarget : (branchSelect) ? (pc + branchDest) : pcPlus4;//If branchSelect then pc = branch dest else pc = pc + 4
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 0;
        end else begin
            pc <= pcNext;
        end
    end
endmodule