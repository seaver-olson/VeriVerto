module cpu(input wire clk, input wire rst);

    localparam nop = 32'h13;

    wire [31:0] pc;
    wire [31:0] instr_fetch; 

    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;

    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    
    //if/id pipeline
    reg [31:0] IF_ID_PC;
    reg [31:0] IF_ID_INSTRUCTION;

    wire [4:0] ID_readData1 = IF_ID_INSTRUCTION[19:15];
    wire [4:0] ID_readData2 = IF_ID_INSTRUCTION[24:20];
    wire [4:0] ID_writeReg = IF_ID_INSTRUCTION[11:7];
    wire [6:0] ID_opcode = IF_ID_INSTRUCTION[6:0];
    wire [2:0] ID_funct3 = IF_ID_INSTRUCTION[14:12];
    wire ID_funct7 = IF_ID_INSTRUCTION[30];

    wire [31:0] ID_regOut1;
    wire [31:0] ID_regOut2;
    wire [31:0] ID_imm;

    //id/ex pipeline
    reg [31:0] ID_EX_PC;
    reg [31:0] ID_EX_RD1;
    reg [31:0] ID_EX_RD2;
    reg [31:0] ID_EX_IMM;

    reg [1:0] ID_EX_WB;//writeback stage: regWrite+memtoreg
    reg [2:0] ID_EX_M;//memory access stage: branch + memRead + memWrite
    reg [3:0] ID_EX_EX;//execution/address calculation stage: ALUOp[1:0] + ALUSrc
    reg [2:0] ID_EX_F3;//funct3
    reg ID_EX_JUMP;
    reg [4:0] ID_EX_readData1;
    reg [4:0] ID_EX_readData2;
    reg [4:0] ID_EX_writeReg;

    wire [31:0] EX_aluA;
    wire [31:0] EX_aluB;
    wire [31:0] EX_out;
    wire EX_zero;
    //ex/mem pipeline
    reg [31:0] EX_MEM_PC;
    reg EX_MEM_JUMP;
    reg [31:0] EX_MEM_OUT;//alu output
    reg [31:0] EX_MEM_RD2;//goes to write data (data memory)
    reg EX_MEM_ZERO;//zero flag
    reg [4:0] EX_MEM_writeReg;

    reg [1:0]EX_MEM_WB;
    reg [2:0]EX_MEM_M;

    wire [31:0] MEM_readData;

    //mem/wb pipeline
    reg [31:0] MEM_WB_RD;//data memory read dead
    reg [31:0] MEM_WB_ALUOUT;
    reg [1:0] MEM_WB_WB;
    reg [4:0] MEM_WB_writeReg;

    wire [31:0] WB_writeData;
    wire WB_regWrite;
    wire WB_memToReg;

    wire alu_cout;//i need to do this eventually
    wire Jump;
    
    //pc
    pcUnit programCounter(.clk(clk), .rst(rst), .branch(EX_MEM_M[2]), .zero(EX_MEM_ZERO), .jump(EX_MEM_JUMP), .branchDest(EX_MEM_OUT), .jumpBase(ID_EX_RD1), .jalrFlag(ID_opcode==7'b1100111), .pc(pc));
    //instruction memory 
    instructionMemory instrMem(.readAddress(pc), .instruction(instr_fetch));
    //control unit + immediate generator + regfile
    regfile regFile(.clk(clk), .rst(rst), .readReg1(ID_readData1), .readReg2(ID_readData2), .writeReg(MEM_WB_writeReg), .writeData(WB_writeData), .rd_we(WB_regWrite), .regOut1(ID_regOut1), .regOut2(ID_regOut2));
    controlUnit ctrlUnit(.instruction(ID_opcode), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .ALUOp(ALUOp), .MemWrite(MemWrite),.ALUSrc(ALUSrc), .RegWrite(RegWrite), .Jump(Jump));
    immgen immediateGen(.instruction(IF_ID_INSTRUCTION), .immgenOut(ID_imm));
    //alu and alu control
    assign EX_aluA = ID_EX_RD1;
    
    assign EX_aluB = ID_EX_EX[1] ? ID_EX_IMM : ID_EX_RD2;
    aluControl aluCtrlUnit(.ALUOp(ID_EX_EX[3:2]), .funct3(ID_EX_F3), .funct7(ID_EX_EX[0]), .ALUControl(ALUControl));
    alu32 alu(.A(EX_aluA), .B(EX_aluB), .Op(ALUControl), .Result(EX_out), .Zero(EX_zero), .Cout(alu_cout));
    
    //data memory instance
    dataMemory dataMem(.clk(clk), .MemWrite(EX_MEM_M[0]), .MemRead(EX_MEM_M[1]), .address(EX_MEM_OUT), .writeData(EX_MEM_RD2), .readData(MEM_readData));

    assign WB_memToReg = MEM_WB_WB[0];
    assign WB_regWrite = MEM_WB_WB[1];
    assign WB_writeData = (WB_memToReg) ? MEM_WB_RD : MEM_WB_ALUOUT;

    //IF/ID
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            IF_ID_PC <= 0;
            IF_ID_INSTRUCTION <= nop;    
        end else begin
            IF_ID_PC <= pc;
            IF_ID_INSTRUCTION <= instr_fetch;
        end
    end
    //ID/EX
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ID_EX_PC <= 0;
            ID_EX_RD1 <= 0;
            ID_EX_RD2 <= 0;
            ID_EX_IMM <= 0;
            ID_EX_WB <= 0;
            ID_EX_M <= 0;
            ID_EX_EX <= 0;
            ID_EX_F3 <= 0;
            ID_EX_JUMP <= 0;
            ID_EX_readData1 <= 0;
            ID_EX_readData2 <= 0;
            ID_EX_writeReg <= 0;
        end else begin
            ID_EX_PC <= IF_ID_PC;
            ID_EX_RD1 <= ID_regOut1;
            ID_EX_RD2 <= ID_regOut2;
            ID_EX_IMM <= ID_imm;
            ID_EX_JUMP <= Jump;
            ID_EX_WB <= {RegWrite, MemtoReg};
            ID_EX_M <= {Branch, MemRead, MemWrite};
            ID_EX_EX <= {ALUOp, ALUSrc, ID_funct7};
            ID_EX_F3 <= ID_funct3;
            ID_EX_readData1 <= ID_readData1;
            ID_EX_readData2 <= ID_readData2;
            ID_EX_writeReg <= ID_writeReg;
        end
    end
    //EX/MEM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            EX_MEM_PC <= 0;
            EX_MEM_OUT <= 0;
            EX_MEM_RD2 <= 0;
            EX_MEM_ZERO <= 0;
            EX_MEM_JUMP <= 0;
            EX_MEM_writeReg <= 0;
            EX_MEM_WB <= 0;
            EX_MEM_M <= 0;
        end else begin
            EX_MEM_PC <= ID_EX_PC;
            EX_MEM_OUT <= EX_out;
            EX_MEM_RD2 <= ID_EX_RD2;
            EX_MEM_JUMP <= ID_EX_JUMP;
            EX_MEM_ZERO <= EX_zero;
            EX_MEM_writeReg <= ID_EX_writeReg;
            EX_MEM_WB <= ID_EX_WB;
            EX_MEM_M <= ID_EX_M;
        end
    end
    //MEM/WB
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            MEM_WB_RD  <= 0;
            MEM_WB_ALUOUT <= 0;
            MEM_WB_WB <= 0;
            MEM_WB_writeReg <= 0;
        end else begin
            MEM_WB_RD  <= MEM_readData;
            MEM_WB_ALUOUT <= EX_MEM_OUT;
            MEM_WB_WB <= EX_MEM_WB;
            MEM_WB_writeReg <= EX_MEM_writeReg;
        end
    end
endmodule
