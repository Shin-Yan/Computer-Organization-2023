module Full_adder (
    carryIn,
    input1,
    input2,
    sum,
    carryOut
);

  //I/O ports
  input carryIn;
  input input1;
  input input2;

  output sum;
  output carryOut;

  //Internal Signals
  wire sum;
  wire carryOut;
  wire w1, w2, w3;

  //Main function
  xor x1 (w1, input1, input2);
  xor x2 (sum, w1, carryIn);
  and a1 (w2, input1, input2);
  and a2 (w3, w1, carryIn);
  or o1 (carryOut, w2, w3);

endmodule

module ALU_1bit (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut
);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;

  output result;
  output carryOut;

  //Internal Signals
  wire result;
  wire carryOut;
  wire a_in, b_in, out_or, out_and, out_add;

  //Main function
  /*your code here*/
  xor x1(a_in, a ,invertA);
  xor x2(b_in, b ,invertB);
  or o1(out_or, a_in, b_in);
  and a1(out_and, a_in, b_in);
  Full_adder f_a(carryIn, a_in, b_in, out_add, carryOut);
  assign result = (operation == 2'b00) ? out_or:
                  (operation == 2'b01) ? out_and:
                  (operation == 2'b10) ? out_add:
                                         less;

endmodule

module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire [32:0]   carry;
  wire [1:0] operation;
  wire zero;
  wire overflow;
  wire set;
  wire invertA;
  wire invertB;
  wire in_1, in_2;


  //Main function
  /*your code here*/
  assign carry[0] = (invertA == 1'b0 && invertB == 1'b1) ? 1'b1:1'b0;
  assign invertA = ALU_operation_i[3];
  assign invertB = ALU_operation_i[2];
  assign operation[1] = ALU_operation_i[1];
  assign operation[0] = ALU_operation_i[0];

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