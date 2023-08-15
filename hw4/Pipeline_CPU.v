`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"
`include "Pipe_Reg.v"

module Pipeline_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  /*your code here*/
  //Internal Signles
  wire [32-1:0] pc_in, pc_out, pc_add, instr, MEM_pc_BJresult;
  wire MEM_Branch, MEM_BranchType, MEM_zero; 

  // modules
  // IF
  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (pc_add),
      .data1_i (MEM_pc_BJresult),
      .select_i(MEM_Branch & (~MEM_BranchType ^ MEM_zero)),
      .data_o  (pc_in)
  );

  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );

  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (pc_add)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr)
  );

  // IF to ID
  wire [32-1:0] ID_pc_add, ID_instr;

  Pipe_Reg #(.size(64)) IF_ID(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({pc_add, instr}),
    .data_o({ID_pc_add, ID_instr})
  );
  
  wire RegWrite, ALUSrc, RegDst, Jump, Branch, BranchType, MemReadm, MemWrite, MemtoReg, WB_RegWrite;
  wire [2-1:0] ALUOp;
  wire[4:0] WB_RegAddr;
  wire [32-1:0] extendData, zeroData, RSdata, RTdata, WriteData;

  // ID
  Decoder Decoder (
      .instr_op_i(ID_instr[31:26]),
      .RegWrite_o(RegWrite),
      .ALUOp_o(ALUOp),
      .ALUSrc_o(ALUSrc),
      .RegDst_o(RegDst),
      .Jump_o(Jump),
      .Branch_o(Branch),
      .BranchType_o(BranchType),
      .MemRead_o(MemRead),
      .MemWrite_o(MemWrite),
      .MemtoReg_o(MemtoReg)
  );

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(ID_instr[25:21]),
      .RTaddr_i(ID_instr[20:16]),
      .RDaddr_i(WB_RegAddr),
      .RDdata_i(WriteData),
      .RegWrite_i(WB_RegWrite),
      .RSdata_o(RSdata),
      .RTdata_o(RTdata)
  );

  Sign_Extend SE (
      .data_i(ID_instr[15:0]),
      .data_o(extendData)
  );

  Zero_Filled ZF (
      .data_i(ID_instr[15:0]),
      .data_o(zeroData)
  );

  // ID to EX
  wire [31:0] EX_pc_add, EX_RSdata, EX_RTdata, EX_extendData, EX_zeroData, EX_instr;
  wire [1:0] EX_ALUOp;
  wire EX_RegWrite, EX_ALUSrc, EX_RegDst, EX_Jump, EX_Branch, EX_BranchType, EX_MemRead, EX_MemWrite, EX_MemtoReg;

  Pipe_Reg #(.size(203)) ID_EX(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({RegWrite, ALUOp, ALUSrc, RegDst, Jump, Branch, BranchType, MemRead, MemWrite, MemtoReg, pc_add, RSdata, RTdata,
             extendData, zeroData, ID_instr}),
    .data_o({EX_RegWrite, EX_ALUOp, EX_ALUSrc, EX_RegDst, EX_Jump, EX_Branch, EX_BranchType, EX_MemRead, EX_MemWrite, EX_MemtoReg, 
             EX_pc_add, EX_RSdata, EX_RTdata, EX_extendData, EX_zeroData, EX_instr})
  );
  
  wire JRsrc, sftVariable, leftRight, zero, overflow;
  wire [32-1:0] pc_temp, pc_branch, ALUsrcData, sftResult, ALUresult, RegData, pc_BJresult;
  wire [5-1:0] RegAddrTemp, shamt, RegAddr;
  wire [4-1:0] ALU_operation;
  wire [2-1:0] FURslt;

  // EX
   ALU_Ctrl AC (
      .funct_i(EX_instr[5:0]),
      .ALUOp_i(EX_ALUOp),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .sftVariable_o(sftVariable),
      .leftRight_o(leftRight),
      .JRsrc_o(JRsrc)
  );

  Adder Adder2 (
      .src1_i(EX_pc_add),
      .src2_i({EX_extendData[29:0], 2'b00}),
      .sum_o (pc_branch)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (pc_branch),
      .data1_i ({EX_pc_add[31:28], EX_instr[25:0], 2'b00}),
      .select_i(EX_Jump),
      .data_o  (pc_temp)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jr (
      .data0_i (pc_temp),
      .data1_i (EX_RSdata),
      .select_i(JRsrc),
      .data_o  (pc_BJresult)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_RS_RT (
      .data0_i (EX_instr[20:16]),
      .data1_i (EX_instr[15:11]),
      .select_i(EX_RegDst),
      .data_o  (RegAddrTemp)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (RegAddrTemp),
      .data1_i (5'd31),
      .select_i(EX_Jump),
      .data_o  (RegAddr)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (EX_RTdata),
      .data1_i (EX_extendData),
      .select_i(EX_ALUSrc),
      .data_o  (ALUsrcData)
  );

  ALU ALU (
      .aluSrc1(EX_RSdata),
      .aluSrc2(ALUsrcData),
      .ALU_operation_i(ALU_operation),
      .result(ALUresult),
      .zero(zero),
      .overflow(overflow)
  );

  Mux2to1 #(
      .size(5)
  ) Shamt_Src (
      .data0_i (EX_instr[10:6]),
      .data1_i (EX_RSdata[4:0]),
      .select_i(sftVariable),
      .data_o  (shamt)
  );

  Shifter shifter (
      .leftRight(leftRight),
      .shamt(shamt),
      .sftSrc(ALUsrcData),
      .result(sftResult)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (ALUresult),
      .data1_i (sftResult),
      .data2_i (EX_zeroData),
      .select_i(FURslt),
      .data_o  (RegData)
  );

  wire MEM_MemWrite, MEM_MemRead, MEM_MemtoReg, MEM_Jump, MEM_RegWrite;
  wire [31:0] MEM_RegData, MEM_RTdata, MEM_pc_add;
  wire [4:0] MEM_RegAddr;
  // EX to MEM

  Pipe_Reg #(.size(141)) EX_MEM(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({EX_Branch, EX_BranchType, EX_MemWrite, EX_MemRead, EX_MemtoReg, EX_RegWrite & (~JRsrc), zero, EX_Jump, pc_BJresult, RegData, EX_RTdata, EX_pc_add, RegAddr}),
    .data_o({MEM_Branch, MEM_BranchType, MEM_MemWrite, MEM_MemRead, MEM_MemtoReg, MEM_RegWrite, MEM_zero, MEM_Jump, MEM_pc_BJresult,
             MEM_RegData, MEM_RTdata, MEM_pc_add, MEM_RegAddr})
  );
  
  wire [32-1:0] MemData;
  // MEM
  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(MEM_RegData),
      .data_i(MEM_RTdata),
      .MemRead_i(MEM_MemRead),
      .MemWrite_i(MEM_MemWrite),
      .data_o(MemData)
  );

  wire WB_MemtoReg, WB_Jump;
  wire[31:0] WB_MemData, WB_RegData, WB_pc_add;
  // MEM to WB
  Pipe_Reg #(.size(104)) MEM_WB(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .data_i({MEM_RegWrite, MEM_MemtoReg, MEM_Jump, MemData, MEM_RegData, MEM_pc_add, MEM_RegAddr}),
    .data_o({WB_RegWrite, WB_MemtoReg, WB_Jump, WB_MemData, WB_RegData, WB_pc_add, WB_RegAddr})
  );
  
  wire [32-1:0] DataNoJal;
  // WB
  Mux2to1 #(
      .size(32)
  ) Mux_Read_Mem (
      .data0_i (WB_RegData),
      .data1_i (WB_MemData),
      .select_i(WB_MemtoReg),
      .data_o  (DataNoJal)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Jal (
      .data0_i (DataNoJal),
      .data1_i (WB_pc_add),
      .select_i(WB_Jump),
      .data_o  (WriteData)
  );
endmodule



