module Mux3to1 (
    data0_i,
    data1_i,
    data2_i,
    select_i,
    data_o
);

  parameter size = 0;

  //I/O ports
  input [size-1:0] data0_i;
  input [size-1:0] data1_i;
  input [size-1:0] data2_i;
  input [2-1:0] select_i;

  output [size-1:0] data_o;

  //Internal Signals
  wire [size-1:0] data_o;

  //Main function
  reg [size-1:0] data_o1;
  /*your code here*/
  always@(data0_i or data1_i or select_i)
  begin
    data_o1 <= (select_i == 2'b00) ? data0_i :
               (select_i == 2'b01) ? data1_i :
                                     data2_i;
  end
  assign data_o = data_o1;

endmodule
