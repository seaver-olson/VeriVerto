module pcUnit(
    input wire clk,
    input wire rst,
    //Mux flag: (zero AND branch)
    input wire branch,
    input wire zero,
    input wire jump, //for JAL/JALR
    input wire [31:0] jumpDest, // from ID stage IF_ID_PC + imm
    input wire [31:0] branchDest, // from ex/mem
    input wire [31:0] jumpBase, //JALR requires a base add from regOut1
    input wire jalrFlag,
    output reg [31:0] pc
);  
    wire [31:0] pcPlus4;
    wire [31:0] pcNext;
    wire branchSelect;
    wire [31:0] jalrTarget;//jumpBase + offset

    assign pcPlus4 = pc+4;
    assign branchSelect = branch & zero; //AND gate seen top right of diagram
    assign jalrTarget = (jumpBase + branchDest) & ~32'h1;

    assign pcNext = jalrFlag   ? jalrTarget :
                    jump       ? jumpDest   :
                    branchSelect ? (pc + branchDest) :
                    pcPlus4;
                    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 0;
        end else begin
            pc <= pcNext;
        end
    end
endmodule