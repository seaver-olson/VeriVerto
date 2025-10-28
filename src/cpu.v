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
    assign ID_jumpDest = ID_pc + ID_imm;
    assign ID_jalr = (ID_opcode==7'b1100111);//if SB-Type
    assign ID_BranchTaken = Branch & ID_zero;

    //EX Stage - in wires
    wire [31:0] EX_regOut1;
    wire [31:0] EX_regOut2;
    wire [31:0] EX_readData1;
    wire [31:0] EX_readData2;
    wire [31:0] EX_imm;
    wire [1:0] EX_WB;
    wire [1:0] EX_M;
    wire [3:0] EX_EX;


    wire [31:0] EX_aluA;
    wire [31:0] EX_aluB;
    wire [31:0] EX_out;
    wire EX_zero;

    //ex/mem pipeline
    reg [31:0] EX_MEM_OUT;//alu output
    reg [31:0] EX_MEM_RD2;//goes to write data (data memory)
    reg [4:0] EX_MEM_writeReg;
    reg [1:0]EX_MEM_WB;
    reg [1:0]EX_MEM_M;
    
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

    equalityTestUnit equalityUnit(.a(ID_regOut1), 
                                  .b(ID_regOut2), 
                                  .funct3(ID_funct3), 
                                  .zero(ID_zero)
                                );

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
    ID_EX ID_EX_pipeline(.clk(clk),
                         .rst(rst),
                         .muxSelect(muxSelect),
                         .ID_regOut1(ID_regOut1),
                         .ID_regOut2(ID_regOut2),
                         .ID_pc(ID_pc),
                         .ID_imm(ID_imm),
                         .EX_imm(EX_imm),
                         .EX_regOut1(EX_regOut1),
                         .EX_regOut2(EX_regOut2),
                         .EX_readData1(EX_readData1),
                         .EX_readData2(EX_readData2),
                         .EX_writeReg(EX_writeReg),
                         .EX_WB(EX_WB),
                         .EX_M(EX_M),
                         .EX_EX(EX_EX),
                         .EX_F3(EX_F3)
                        );

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

    //control unit + immediate generator + regfile
    regfile regFile(.clk(clk), 
                    .rst(rst), 
                    .readReg1(ID_readData1), 
                    .readReg2(ID_readData2), 
                    .writeReg(MEM_WB_writeReg), 
                    .writeData(WB_writeData), 
                    .regDump(regDump),
                    .regWrite(WB_regWrite), 
                    .regOut1(ID_regOut1), 
                    .regOut2(ID_regOut2)
                );

    controlUnit ctrlUnit(.instruction(ID_opcode), 
                         .Branch(Branch), 
                         .MemRead(MemRead), 
                         .MemtoReg(MemtoReg), 
                         .ALUOp(ALUOp), 
                         .MemWrite(MemWrite),
                         .ALUSrc(ALUSrc), 
                         .RegWrite(RegWrite), 
                         .Jump(Jump)
                        );

    immgen immediateGen(.IF_ID_INSTRUCTION(ID_instruction), 
                        .immgenOut(ID_imm)
                    );
    
    forwardingUnit FUnit(.ID_EX_readData1(EX_readData1), 
                         .ID_EX_readData2(EX_readData2),
                         .EX_MEM_writeReg(EX_MEM_writeReg), 
                         .EX_MEM_regWrite(EX_MEM_WB[1]), 
                         .MEM_WB_writeReg(MEM_WB_writeReg),
                         .MEM_WB_regWrite(MEM_WB_WB[1]), 
                         .ForwardA(ForwardA), 
                         .ForwardB(ForwardB)
                        );
    
    //Mux A and B seen on Page 577 of Patterson
    assign EX_aluA = (ForwardA == 2'b10) ? EX_MEM_OUT:
                     (ForwardA == 2'b01) ? WB_writeData:
                    EX_readData1;
    
    assign EX_aluB = EX_EX[1] ? EX_imm : 
                    (ForwardB == 2'b10) ? EX_MEM_OUT:
                    (ForwardB == 2'b01) ? WB_writeData: 
                    EX_readData2;

    aluControl aluCtrlUnit(.ALUOp(EX_EX[3:2]), 
                           .funct3(EX_F3), 
                           .funct7(EX_EX[0]), 
                           .ALUControl(ALUControl));
    alu32 alu(.a(EX_aluA), 
              .b(EX_aluB), 
              .op(ALUControl), 
              .result(EX_out),
              .zero(EX_zero), 
              .cout(alu_cout));
    
    //data memory instance
    dataMemory dataMem(.clk(clk), 
                       .MemWrite(EX_MEM_M[0]), 
                       .MemRead(EX_MEM_M[1]), 
                       .address(EX_MEM_OUT), 
                       .writeData(EX_MEM_RD2), 
                       .readData(MEM_readData));

    assign WB_memToReg = MEM_WB_WB[0];
    assign WB_regWrite = MEM_WB_WB[1];
    assign WB_writeData = (WB_memToReg) ? MEM_WB_RD : MEM_WB_ALUOUT;
    //EX/MEM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            EX_MEM_OUT <= 0;
            EX_MEM_RD2 <= 0;
            EX_MEM_writeReg <= 0;
            EX_MEM_WB <= 0;
            EX_MEM_M <= 0;
        end else begin
            EX_MEM_OUT <= EX_out;
            EX_MEM_RD2 <= EX_aluB;
            EX_MEM_writeReg <= EX_writeReg;
            EX_MEM_WB <= EX_WB;
            EX_MEM_M <= EX_M;
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
            MEM_WB_RD <= MEM_readData;
            MEM_WB_ALUOUT <= EX_MEM_OUT;
            MEM_WB_WB <= EX_MEM_WB;
            MEM_WB_writeReg <= EX_MEM_writeReg;
            
        end
    end
endmodule
