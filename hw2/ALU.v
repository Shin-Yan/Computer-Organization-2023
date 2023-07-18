`include "ALU_1bit.v"
module ALU (
    aluSrc1,
    aluSrc2,
    invertA,
    invertB,
    operation,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input invertA;
  input invertB;
  input [2-1:0] operation;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire [1:0]    sub;
  wire [32:0]   carry;
  wire set;
  wire zero;
  wire overflow;
  wire in_1, in_2;

  //Main function
  /*your code here*/

  // when ALU operation is sub, set carry[0] to 1 because of 2's complement issue
  assign carry[0] = (invertA == 1'b0 && invertB == 1'b1) ? 1'b1:1'b0;

  ALU_1bit bit0(aluSrc1[0], aluSrc2[0], invertA, invertB, operation, carry[0], set, result[0], carry[1]);
  genvar i;

  generate
    for(i = 1; i < 32 ; i = i + 1) begin:bits
      ALU_1bit medium_bits(aluSrc1[i], aluSrc2[i], invertA, invertB, operation, carry[i], 1'b0, result[i], carry[i+1]);
    end
  endgenerate

  xor x1(in_1, aluSrc1[31], invertA);
  xor x2(in_2, aluSrc2[31], invertB);

  Full_adder get_set(carry[31], in_1, in_2, set, carry[32]);

  assign overflow = (operation == 2'b00 || operation == 2'b01) ? 1'b0:
                    ((carry[31]==1'b1 && in_1 == 1'b0 && in_2 == 1'b0)||
                    (carry[31]==1'b0 && in_1 == 1'b1 && in_2 == 1'b1))? 1'b1 : 1'b0;

   
  nor n1(zero, result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19], result[20], result[21], result[22], result[23], result[24], result[25], result[26], result[27], result[28], result[29], result[30], result[31]);

endmodule
