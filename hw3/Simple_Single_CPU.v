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

module Simple_Single_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signals
    wire [32-1:0] instr, PC_i, PC_o, PC_add1, PC_add2, signextend, PC_branch, Write_data, Read_data1, Read_data2, Zero_filled, ALU_input2;
    wire [32-1:0] ALU_result, Shifter_num, Shifter_result, RDdata_src, DM_readData;
    wire [5-1:0] WriteReg_addr;
    wire [4-1:0] ALU_operation;
    wire [3-1:0] ALUOp;
    wire [2-1:0] FURslt, RegDst, MemtoReg;
    wire Jump, ALUSrc, Branch, BranchType, MemWrite, RegWrite, MemRead, Zero, BranchTaken, leftRight, shiftOff;
    wire overflow;

  //modules
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(PC_i),
      .pc_out_o(PC_o)
  );

  Adder Adder1 (
      .src1_i(PC_o),
      .src2_i(32'd4),
      .sum_o (PC_add1)
  );

  Adder Adder2 (
      .src1_i(PC_add1),
      .src2_i({signextend[29:0], 2'b00}),
      .sum_o (PC_add2)
  );

  Mux2to1 #(
    .size(1)
  ) Mux_Zero(
    .data0_i(Zero),
    .data1_i(~Zero),
    .select_i(BranchType),
    .data_o(BranchTaken)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (PC_add1),
      .data1_i (PC_add2),
      .select_i(Branch & BranchTaken),
      .data_o  (PC_branch)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (PC_branch),
      .data1_i ({PC_add1[31:28], instr[25:0], 2'b00}),
      .select_i(Jump),
      .data_o  (PC_i)
  );

  Instr_Memory IM (
      .pc_addr_i(PC_o),
      .instr_o  (instr)
  );

  Mux3to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (instr[20:16]),
      .data1_i (instr[15:11]),
      .data2_i (5'b11111),
      .select_i(RegDst),
      .data_o  (WriteReg_addr)
  );

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instr[25:21]),
      .RTaddr_i(instr[20:16]),
      .RDaddr_i(WriteReg_addr),
      .RDdata_i(Write_data),
      .RegWrite_i(RegWrite),
      .RSdata_o(Read_data1),
      .RTdata_o(Read_data2)
  );

  Decoder Decoder (
      .instr_op_i(instr[31:26]),
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

  ALU_Ctrl AC (
      .funct_i(instr[5:0]),
      .ALUOp_i(ALUOp),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .leftRight_o(leftRight),
      .ShiftOff_o(shiftOff)
  );

  Sign_Extend SE (
      .data_i(instr[15:0]),
      .data_o(signextend)
  );

  Zero_Filled ZF (
      .data_i(instr[15:0]),
      .data_o(Zero_filled)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (Read_data2),
      .data1_i (signextend),
      .select_i(ALUSrc),
      .data_o  (ALU_input2)
  );

  Mux2to1 #(
    .size(32)
  ) Shifter_offset(
    .data0_i  ({27'd0,instr[10:6]}),
    .data1_i  (Read_data1),
    .select_i (shiftOff),
    .data_o   (Shifter_num)
  );

  ALU ALU (
      .aluSrc1(Read_data1),
      .aluSrc2(ALU_input2),
      .ALU_operation_i(ALU_operation),
      .result(ALU_result),
      .zero(Zero),
      .overflow(overflow)
  );

  Shifter shifter (
      .result_o(Shifter_result),
      .leftRight_i(leftRight),
      .shamt_i(Shifter_num),
      .sftSrc_i(ALU_input2)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (ALU_result),
      .data1_i (Shifter_result),
      .data2_i (Zero_filled),
      .select_i(FURslt),
      .data_o  (RDdata_src)
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(RDdata_src),
      .data_i(Read_data2),
      .MemRead_i(MemRead),
      .MemWrite_i(MemWrite),
      .data_o(DM_readData)
  );

  Mux3to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(RDdata_src),
      .data1_i(DM_readData),
      .data2_i(PC_add1),
      .select_i(MemtoReg),
      .data_o(Write_data)
  );

endmodule



