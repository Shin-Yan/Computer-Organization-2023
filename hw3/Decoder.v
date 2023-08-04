module Decoder (
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //I/O ports
  input [6-1:0] instr_op_i;

  output RegWrite_o;
  output [3-1:0] ALUOp_o;
  output ALUSrc_o;
  output [2-1:0] RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output [2-1:0] MemtoReg_o;

  //Internal Signals
  wire RegWrite_o;
  wire [3-1:0] ALUOp_o;
  wire ALUSrc_o;
  wire [2-1:0] RegDst_o;
  wire Jump_o;
  wire Branch_o;
  wire BranchType_o;
  wire MemRead_o;
  wire MemWrite_o;
  wire [2-1:0] MemtoReg_o;

  //Main function
  /*your code here*/
  
  assign RegWrite_o = (instr_op_i == 6'b000000) || // R-type
                      (instr_op_i == 6'b010011) || // addi
                      (instr_op_i == 6'b001111) || // jal
                      (instr_op_i == 6'b011000) ? 1'b1 : 1'b0; // lw

  assign ALUOp_o[2:0] = (instr_op_i == 6'b000000) ? 3'b010 : // R-type
                        (instr_op_i == 6'b010011) ? 3'b011 : // addi
                        (instr_op_i == 6'b011000) ? 3'b000 : // lw
                        (instr_op_i == 6'b101000) ? 3'b000 : // sw
                        (instr_op_i == 6'b011001) ? 3'b001 : // beq
                        (instr_op_i == 6'b011010) ? 3'b001 : // bne
                        (instr_op_i == 6'b011100) ? 3'b100 : // blt
                        (instr_op_i == 6'b011101) ? 3'b001 : // bnez
                        (instr_op_i == 6'b011110) ? 3'b100 : // bgez
                                                    3'bxxx;

  assign ALUSrc_o = (instr_op_i == 6'b000000) ? 1'b0 : // R-type
                    (instr_op_i == 6'b011001) ? 1'b0 : // beq
                    (instr_op_i == 6'b011010) ? 1'b0 : // bne
                    (instr_op_i == 6'b011100) ? 1'b0 : // blt
                    (instr_op_i == 6'b011101) ? 1'b0 : // bnez
                    (instr_op_i == 6'b011110) ? 1'b0 : // bgez
                                                1'b1;  // others

  assign RegDst_o = (instr_op_i == 6'b000000) ? 2'b01 : // R-type
                    (instr_op_i == 6'b010011) ? 2'b00 : // addi
                    (instr_op_i == 6'b011000) ? 2'b00 : // lw
                    (instr_op_i == 6'b001111) ? 2'b10 : // jal
                                                2'bxx;  // others

  assign MemtoReg_o = (instr_op_i == 6'b000000) ? 2'b00 : // R-type
                      (instr_op_i == 6'b010011) ? 2'b00 : // addi
                      (instr_op_i == 6'b011000) ? 2'b01 : // lw
                      (instr_op_i == 6'b001111) ? 2'b10 : // jal
                                                  2'bxx;  // others

  assign Jump_o = (instr_op_i == 6'b001100) ? 1'b1 : // jump
                  (instr_op_i == 6'b001111) ? 1'b1 : // jal
                                              1'b0;  // others
  
  assign Branch_o = (instr_op_i == 6'b011001) ? 1'b1 : // beq
                    (instr_op_i == 6'b011010) ? 1'b1 : // bne
                    (instr_op_i == 6'b011100) ? 1'b1 : // blt
                    (instr_op_i == 6'b011101) ? 1'b1 : // bnez
                    (instr_op_i == 6'b011110) ? 1'b1 : // bgez
                                                1'b0;
  
  assign BranchType_o = (instr_op_i == 6'b011001) ? 1'b0 : // beq
                        (instr_op_i == 6'b011010 || instr_op_i == 6'b011101) ? 1'b1 : // bne, bnez
                        (instr_op_i == 6'b011100) ? 1'b1 : // blt
                        (instr_op_i == 6'b011110) ? 1'b0 : // bgez
                                                    1'bx; // no branch

  assign MemWrite_o = (instr_op_i == 6'b101000) ? 1'b1:1'b0; // sw/not_sw
  assign MemRead_o = (instr_op_i == 6'b011000) ? 1'b1:1'b0;  // lw/not_lw

endmodule
