`ifndef REGFILE_SV
`define REGFILE_SV
`include "parameters.sv"

module regfile ( clk, read_addr1, read_addr2, write_addr,
                read_data1, read_data2, write_data,
                write_enable) ;
  input clk;
  input [0:NUM_REGFILE_BITS-1] read_addr1 ;
  input [0:NUM_REGFILE_BITS-1] read_addr2 ;
  input [0:NUM_REGFILE_BITS-1] write_addr ;
  input [0:DATABUS_SIZE-1] write_data ;
  input write_enable ;
  
  output [0:DATABUS_SIZE-1] read_data1 ; //System Verilog
  output [0:DATABUS_SIZE-1] read_data2 ; 
  
  logic [0:DATABUS_SIZE-1] reg_mem [0:NUM_REGISTERS-1] ;
  
  //initialize registers to 0
  initial begin
    for(int i = 0; i < NUM_REGISTERS; i++)
      reg_mem[i] = 0;
  end
  
  always @ ( posedge clk ) begin
    if (write_enable && (write_addr != 0))
      reg_mem[write_addr] <= write_data ;
    //read_data1 <= reg_mem[read_addr1] ;
    //read_data2 <= reg_mem[read_addr2] ; behavioral method
    
  end
  //C conditional response. test ? true : false
  assign read_data1 = ((read_addr1 == 0) ? '0 : reg_mem[read_addr1] );
  assign read_data2 = ((read_addr2 == 0) ? '0 : reg_mem[read_addr2] );
  // procedural method
  
endmodule

`endif