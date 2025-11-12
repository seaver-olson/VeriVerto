module pcUnit(
    input wire clk,
    input wire rst,
    //Mux flag: (zero AND branch)
    input wire branchTaken,//switched to have mux outside pc
    input wire jump, //for JAL/JALR
    input wire [31:0] jumpDest, // from ID stage IF_ID_PC + imm
    input wire [31:0] jumpBase, //JALR requires a base add from regOut1
    input wire jalrFlag,
    input wire PCWrite,
    output reg [31:0] pc
);  
    wire [31:0] pcPlus4;
    wire [31:0] pcNext;
    wire [31:0] jalrTarget;//jumpBase + offset

    assign pcPlus4 = pc+4;
    assign jalrTarget = (jumpBase + jumpDest) & ~32'h1;//left shift by 1

    assign pcNext = jalrFlag   ? jalrTarget :
                    (jump | branchTaken) ? jumpDest :
                    pcPlus4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 0;
        end else if (PCWrite) begin
            pc <= pcNext;
        end
    end
endmodule