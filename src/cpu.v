module cpu(input wire clk, input wire rst, input wire regDump);

    localparam nop = 32'h13;

    wire [31:0] pc;
    wire [31:0] instr_fetch; 

    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;

    //BTB wires
    wire predict_taken;
    wire [31:0] predict_target;
    wire branch_resolved;

    //hazard regs
    wire PCWrite;
    wire IF_ID_Write;
    wire muxSelect;
    //forwarding unit output wires
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;

    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    //ID Stage - in wires
    wire [6:0] ID_opcode;
    wire [4:0] ID_readData1;
    wire [4:0] ID_readData2;
    wire [4:0] ID_writeReg;
    wire [2:0] ID_funct3;
    wire ID_funct7;
    wire [31:0] ID_instruction;
    wire [31:0] ID_pc;
    //ID Stage - out wires
    wire [31:0] ID_regOut1;
    wire [31:0] ID_regOut2;
    wire [31:0] ID_imm;
    wire [31:0] ID_jumpDest;
    wire ID_zero;
    wire ID_jalr;
    wire ID_BranchTaken;
    wire Jump;
    wire [1:0] ID_WB;
    wire [2:0] ID_M;
    wire [3:0] ID_EXALU;



    assign ID_jumpDest = ID_pc + ID_imm;
    assign ID_jalr = (ID_opcode==7'b1100111);//if SB-Type
    assign ID_BranchTaken = Branch & ID_zero;
    assign ID_WB = {RegWrite, MemtoReg};
    assign ID_M = {Branch, MemRead, MemWrite};
    assign ID_EXALU = {ALUOp, ALUSrc, ID_funct7};//4 bits
 

    //EX Stage - in wires
    wire [31:0] EX_regOut1;
    wire [31:0] EX_regOut2;
    wire [4:0] EX_readData1;
    wire [4:0] EX_readData2;
    wire [4:0] EX_writeReg;
    wire [31:0] EX_imm;
    wire [1:0] EX_WB;
    wire [2:0] EX_funct3;
    wire [2:0] EX_M;
    wire [3:0] EX_EX;

    //internal wires for EX Stage
    wire [31:0] EX_aluA;
    wire [31:0] EX_aluB;

    wire [31:0] EX_out;
    wire EX_zero;
    //i think wires are wrong
    //MEM Stage - out wires
    wire [31:0] MEM_readData;
    wire [31:0] MEM_out;
    wire [31:0] MEM_regOut2;
    wire [1:0] MEM_wb;
    wire [4:0] MEM_writeReg;
    wire [2:0] MEM_M;
    //WB Stage - in wires
    wire [31:0] WB_readData;
    wire [31:0] WB_aluOut;
    wire [1:0] WB_WB;
    wire [4:0] WB_writeReg;

    wire [31:0] WB_writeData;
    wire WB_regWrite;
    wire WB_memToReg;

    wire alu_cout;//i need to do this eventually



    pcUnit programCounter(.clk(clk), 
                          .rst(rst), 
                          .branchTaken(ID_BranchTaken),
                          .jump(Jump), 
                          .jumpDest(ID_jumpDest),
                          .jumpBase(ID_regOut1), 
                          .jalrFlag(ID_jalr), 
                          .PCWrite(PCWrite),
                          .pc(pc)
                        );

    BTB branchTargetBuffer(
        .clk(clk),
        .rst(rst),
        .branch_resolved(branch_resolved),
        .branch_taken(ID_BranchTaken),
        .branch_pc(ID_pc),
        .branch_target(ID_jumpDest),
        .fetch_pc(pc),
        .predict_taken(predict_taken),
        .predict_target(predict_target)
    )

    instructionMemory instrMem(.readAddress(pc), 
                               .instruction(instr_fetch)
                            );
                            

    hazardDetectionUnit hazardUnit(.ID_EX_MemRead(EX_M[1]), 
                                   .IF_ID_ReadData1(ID_readData1), 
                                   .IF_ID_ReadData2(ID_readData2), 
                                   .ID_EX_writeReg(EX_writeReg), 
                                   .IF_ID_Write(IF_ID_Write), 
                                   .PCWrite(PCWrite), 
                                   .muxSelect(muxSelect)
                                );

    IF_ID IF_ID_pipeline(.clk(clk),
                         .rst(rst),
                         .IF_pc(pc), 
                         .IF_ID_Write(IF_ID_Write),
                         .Jump(Jump),
                         .IF_instruction(instr_fetch), 
                         .readData1(ID_readData1), 
                         .readData2(ID_readData2), 
                         .writeReg(ID_writeReg), 
                         .ID_pc(ID_pc),
                         .opcode(ID_opcode),
                         .funct3(ID_funct3), 
                         .funct7(ID_funct7),
                         .ID_instruction(ID_instruction)
                        );

    immgen immediateGen(.IF_ID_INSTRUCTION(ID_instruction), 
                        .immgenOut(ID_imm)
                    );

    controlUnit ctrlUnit(
                         .instruction(ID_opcode), 
                         .Branch(Branch), 
                         .MemRead(MemRead), 
                         .MemtoReg(MemtoReg), 
                         .ALUOp(ALUOp), 
                         .MemWrite(MemWrite),
                         .ALUSrc(ALUSrc), 
                         .RegWrite(RegWrite), 
                         .Jump(Jump)
                        );

    regfile regFile(.clk(clk), 
                .rst(rst), 
                .readReg1(ID_readData1), 
                .readReg2(ID_readData2), 
                .writeReg(WB_writeReg), 
                .writeData(WB_writeData), 
                .regDump(regDump),
                .regWrite(WB_regWrite), 
                .regOut1(ID_regOut1), 
                .regOut2(ID_regOut2)
            );

    equalityTestUnit equalityUnit(.a(ID_regOut1), 
                                  .b(ID_regOut2), 
                                  .funct3(ID_funct3), 
                                  .zero(ID_zero)
                                );

    ID_EX ID_EX_pipeline(.clk(clk),
                         .rst(rst),
                         .muxSelect(muxSelect),
                         .ID_regOut1(ID_regOut1),
                         .ID_regOut2(ID_regOut2),
                         .ID_readData1(ID_readData1),
                         .ID_readData2(ID_readData2),
                         .ID_writeReg(ID_writeReg),
                         .ID_pc(ID_pc),
                         .ID_imm(ID_imm),
                         .ID_WB(ID_WB),
                         .ID_M(ID_M),
                         .ID_EXALU(ID_EXALU),
                         .ID_F3(ID_funct3),
                         .EX_imm(EX_imm),
                         .EX_regOut1(EX_regOut1),
                         .EX_regOut2(EX_regOut2),
                         .EX_readData1(EX_readData1),
                         .EX_readData2(EX_readData2),
                         .EX_writeReg(EX_writeReg),
                         .EX_WB(EX_WB),
                         .EX_M(EX_M),
                         .EX_EX(EX_EX),
                         .EX_F3(EX_funct3)
                        );

    forwardingUnit FUnit(.ID_EX_readData1(EX_readData1), 
                         .ID_EX_readData2(EX_readData2),
                         .EX_MEM_writeReg(MEM_writeReg), 
                         .EX_MEM_regWrite(MEM_wb[1]), 
                         .MEM_WB_writeReg(WB_writeReg),
                         .MEM_WB_regWrite(WB_WB[1]), 
                         .ForwardA(ForwardA), 
                         .ForwardB(ForwardB)
                        );
    
    //Mux A and B seen on Page 577 of Patterson
    assign EX_aluA = (ForwardA == 2'b10) ? MEM_out:
                     (ForwardA == 2'b01) ? WB_writeData:
                     EX_regOut1;
    
    assign EX_aluB = EX_EX[1] ? EX_imm : 
                    (ForwardB == 2'b10) ? MEM_out:
                    (ForwardB == 2'b01) ? WB_writeData: 
                    EX_regOut2;

    aluControl aluCtrlUnit(.ALUOp(EX_EX[3:2]), 
                           .funct3(EX_funct3), 
                           .funct7(EX_EX[0]), 
                           .ALUControl(ALUControl));
    alu32 alu(.a(EX_aluA), 
              .b(EX_aluB), 
              .op(ALUControl), 
              .result(EX_out),
              .zero(EX_zero), 
              .cout(alu_cout));
    
    EX_MEM EX_MEM_pipeline(.clk(clk),
                           .rst(rst),
                           .EX_out(EX_out),
                           .EX_aluB(EX_aluB),
                           .EX_writeReg(EX_writeReg),
                           .EX_WB(EX_WB),
                           .EX_M(EX_M),
                           .MEM_OUT(MEM_out),
                           .MEM_RD2(MEM_regOut2),
                           .MEM_writeReg(MEM_writeReg),
                           .MEM_WB(MEM_wb),
                           .MEM_M(MEM_M)
    );

    //data memory instance
    dataMemory dataMem(.clk(clk), 
                       .MemWrite(MEM_M[0]), 
                       .MemRead(MEM_M[1]), 
                       .address(MEM_out), 
                       .writeData(MEM_regOut2), 
                       .readData(MEM_readData));

    MEM_WB MEM_WB_pipeline(.clk(clk),
                           .rst(rst),
                           .MEM_readData(MEM_readData),
                           .MEM_OUT(MEM_out),
                           .MEM_writeReg(MEM_writeReg),
                           .MEM_WB(MEM_wb),//lowercase to not mess up function
                           .WB_RD(WB_readData),
                           .WB_ALUOUT(WB_aluOut),
                           .WB_WB(WB_WB),
                           .WB_writeReg(WB_writeReg)
    );

    assign WB_memToReg = WB_WB[0];
    assign WB_regWrite = WB_WB[1];
    assign WB_writeData = (WB_memToReg) ? WB_readData : WB_aluOut;
endmodule
