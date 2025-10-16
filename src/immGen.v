module immgen(
    input wire [31:0] IF_ID_INSTRUCTION,
    output wire [31:0] immgenOut
);
    wire [6:0] opcode = IF_ID_INSTRUCTION[6:0];

    localparam [6:0] I_TYPE = 7'b0010011;
    localparam [6:0] JALR = 7'b1100111;
    localparam [6:0] LOAD = 7'b0000011;
    wire [31:0] iImm = {{20{IF_ID_INSTRUCTION[31]}}, IF_ID_INSTRUCTION[31:20]};
    
    localparam [6:0] STORE = 7'b0100011;
    wire [31:0] sImm = {{20{IF_ID_INSTRUCTION[31]}}, IF_ID_INSTRUCTION[31:25], IF_ID_INSTRUCTION[11:7]};

    localparam [6:0] BRANCH = 7'b1100011;
    wire [31:0] bImm = {{19{IF_ID_INSTRUCTION[31]}}, IF_ID_INSTRUCTION[31], IF_ID_INSTRUCTION[7],
                        IF_ID_INSTRUCTION[30:25], IF_ID_INSTRUCTION[11:8], 1'b0};

    localparam [6:0] LUI = 7'b0110111;
    localparam [6:0] AUIPC = 7'b0010111;
    wire [31:0] uImm = {IF_ID_INSTRUCTION[31:12], 12'b0};   
    
    localparam [6:0] J_TYPE = 7'b1101111;
    wire [31:0] jImm = {{11{IF_ID_INSTRUCTION[31]}}, IF_ID_INSTRUCTION[31], IF_ID_INSTRUCTION[19:12],IF_ID_INSTRUCTION[20], IF_ID_INSTRUCTION[30:21], 1'b0};

    assign immgenOut = (opcode == LOAD || opcode == I_TYPE || opcode == JALR) ? iImm :
                       (opcode == STORE)  ? sImm :
                       (opcode == BRANCH) ? bImm :
                       (opcode == LUI || opcode == AUIPC) ? uImm :
                       (opcode == J_TYPE) ? jImm :
                       32'h00;
endmodule
