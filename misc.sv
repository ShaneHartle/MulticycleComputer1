`ifndef MISC_SV
`define MISC_SV
`include "parameters.sv"

module mux2x1_data(data_in0, data_in1, data_out, select);
  input [0:DATABUS_MSB] data_in0 ;
  input [0:DATABUS_MSB] data_in1 ;
  output reg [0:DATABUS_MSB] data_out ;
  input select ;
  
  always @ ( * ) begin
    if ( select )
      data_out <= data_in1;
  	else
      data_out <= data_in0;
  end
endmodule

module mux3x1_data(data_in0, data_in1, data_in2, data_out, select);
  input [0:DATABUS_MSB] data_in0;
  input [0:DATABUS_MSB] data_in1;
  input [0:DATABUS_MSB] data_in2;
  output reg [0:DATABUS_MSB] data_out;
  input [0:1] select;
  
  always @ ( * ) begin
    case(select)
      2'b00: data_out <= data_in0;
      2'b01: data_out <= data_in1;
      2'b10: data_out <= data_in2;
      default: data_out <= data_in0;
    endcase
  end
endmodule

module mux2x1_addr(data_in0, data_in1, data_out, select);
  input [0:NUM_REGFILE_BITS - 1] data_in0 ;
  input [0:NUM_REGFILE_BITS - 1] data_in1 ;
  output reg [0:NUM_REGFILE_BITS - 1] data_out ;
  input select ;
  
  always @ ( * ) begin
    if ( select )
      data_out <= data_in1;
  	else
      data_out <= data_in0;
  end
endmodule

`endif