`include "Full_adder.v"
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
