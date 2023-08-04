module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    leftRight_o,
    ShiftOff_o,
    Jumpra_o
);

  //I/O ports
  input [6-1:0] funct_i;
  input [3-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output leftRight_o;
  output ShiftOff_o;
  output Jumpra_o;

  //Internal Signals
  wire [4-1:0] ALU_operation_o;
  wire [2-1:0] FURslt_o;
  wire leftRight_o;
  wire ShiftOff_o;
  wire Jumpra_o;

  //Main function
  /*your code here*/
  assign ALU_operation_o[3:0] = (ALUOp_i == 3'b000) ? 4'b0010 : // lw, sw : add
                                (ALUOp_i == 3'b011) ? 4'b0010 : // addi : add
                                (ALUOp_i == 3'b001) ? 4'b0110 : // b : sub (beq, bne, bnez)
                                (ALUOp_i == 3'b100) ? 4'b0111 : // b : slt (blt, bgez)
                                (funct_i == 6'b100011) ? 4'b0010 : // add
                                (funct_i == 6'b010011) ? 4'b0110 : // sub
                                (funct_i == 6'b011111) ? 4'b0001 : // and
                                (funct_i == 6'b101111) ? 4'b0000 : // or
                                (funct_i == 6'b010000) ? 4'b1101 : // nor
                                (funct_i == 6'b010100) ? 4'b0111 : // slt
                                                         4'bxxxx;

  assign leftRight_o =(funct_i == 6'b010010) ? 1'b0 : // sll
                      (funct_i == 6'b011000) ? 1'b0 : // sllv
                      (funct_i == 6'b100010) ? 1'b1 : // srl
                      (funct_i == 6'b101000) ? 1'b1 : // srlv
                                               1'bx;                              


  assign FURslt_o = (ALUOp_i == 3'b010 &&(funct_i == 6'b010010 || funct_i == 6'b100010 || funct_i == 6'b011000 
                    || funct_i == 6'b101000)) ? 2'b01:2'b00; // shift

  assign ShiftOff_o = (funct_i == 6'b010010 || funct_i == 6'b100010)? 1'b0:1'b1; //sll or srl
  assign Jumpra_o = (ALUOp_i == 3'b010 && funct_i == 6'b000001)? 1'b1:1'b0;

endmodule
