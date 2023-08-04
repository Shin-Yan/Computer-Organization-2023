module Mux2to1 (
    data0_i,
    data1_i,
    select_i,
    data_o
);

  parameter size = 0;

  //I/O ports
  input [size-1:0] data0_i;
  input [size-1:0] data1_i;
  input select_i;

  output [size-1:0] data_o;

  //Internal Signals
  wire [size-1:0] data_o;

  //Main function
  reg [size-1:0] data_o1;
  /*your code here*/
  always@(data0_i or data1_i or select_i)
  begin
    data_o1 = (select_i == 1'b0) ? data0_i : data1_i;
  end
  assign data_o = data_o1;
endmodule
