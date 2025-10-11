module cpu(input wire clk, input wire rst);

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
    wire [4:0] ID_writeReg = IF_ID_INSTRUCTIONp[11:7];
    wire [6:0] ID_opcode = IF_ID_INSTRUCTION[6:0];
    wire [2:0] ID_funct3 = IF_ID_INSTRUCTION[14:12];
    wire ID_funct7 = IF_ID_INSTRUCTION[30];

    wire [31:0] ID_EX_regOut1;
    wire [31:0] ID_EX_regOut2;
    wire [31:0] ID_imm;

    //id/ex pipeline
    reg [31:0] ID_EX_PC;
    reg [31:0] ID_EX_RD1;
    reg [31:0] ID_EX_RD2;
    reg [31:0] ID_EX_IMM;

    reg [1:0] ID_EX_WB;//writeback stage: regWrite+memtoreg
    reg [2:0] ID_EX_M;//memory access stage: branch + memRead + memWrite
    reg [5:0] ID_EX_EX;//execution/address calculation stage: ALUOp + ALUSrc
    reg [4:0] ID_EX_readData1;
    reg [4:0] ID_EX_readData2;
    reg [4:0] ID_EX_writeReg;

    wire [31:0] EX_aluA;
    wire [31:0] EX_aluB;
    wire [31:0] EX_out;
    wire EX_zero;
    //ex/mem pipeline
    reg [31:0] EX_MEM_PC;
    reg [31:0] EX_MEM_OUT;//alu output
    reg [31:0] EX_MEM_RD2;//goes to write data (data memor)
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
    pcUnit programCounter(.clk(clk), .rst(rst), .branch(EX_MEM_M[2]), .zero(EX_MEM_ZERO), .jump(Jump), .branchDest(EX_MEM_OUT), .jumpBase(ID_EX_RD1), .jalrFlag(ID_opcode==7'b1100111), .pc(pc));
    //instruction memory 
    instructionMemory instrMem(.readAddress(pc), .instruction(instr_fetch));
    //control unit + immediate generator + regfile
    regfile regFile(.clk(clk), .rst(rst), .readReg1(ID_readData1), .readReg2(ID_readData2), .writeReg(MEM_WB_RD), .writeData(MEM_WB_WB), .rd_we(WB_regWrite), .regOut1(ID_EX_regOut1), .regOut2(ID_EX_regOut2));
    controlUnit ctrlUnit(.instruction(ID_opcode), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .ALUOp(ALUOp), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite));
    immgen immediateGen(.instruction(IF_ID_INSTRUCTION), .immgenOut(ID_imm));
    //alu and alu control
    aluControl aluCtrlUnit(.ALUOp(ID_EX_EX[1:0]), .funct3(ID_EX_IMM[14:12]), .funct7(ID_EX_IMM[30]), .ALUControl(fixLater));
    alu32 alu(.A(EX_aluA), .B(EX_aluB), .Op(fixLater), .Result(EX_out), .Zero(EX_zero), .Cout(alu_cout));
    
    //data memory instance
    dataMemory dataMem(.clk(clk), .MemWrite(EX_MEM_M[0]), .MemRead(EX_MEM_M[1]), .address(MEM_WB_ALUOUT), .writeData(ID_EX_RD2), .readData(MEM_readData));

    assign WB_memToReg = MEM_WB_WB[0];
    assign WB_regWrite = MEM_WB_WB[1];
    assign WB_writeData = (WB_memToReg) ? MEM_WB_RD : MEM_WB_ALUOUT

endmodule
