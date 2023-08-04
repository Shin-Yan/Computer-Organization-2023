module Shifter (
    result_o,
    leftRight_i,
    shamt_i,
    sftSrc_i
);

  //I/O ports
  output [32-1:0] result_o;

  input leftRight_i;
  input [32-1:0] shamt_i;
  input [32-1:0] sftSrc_i;

  //Internal Signals
  wire [32-1:0] result_o;

  //Main function
  reg [32-1:0] result1;
  /*your code here*/
  always@(leftRight_i or sftSrc_i or shamt_i)
  begin
    result1 <= (leftRight_i == 1'b0) ? sftSrc_i << shamt_i : sftSrc_i >> shamt_i;
  end
  assign result_o = result1;
endmodule
