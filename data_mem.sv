`ifndef DATA_MEM_SV
`define DATA_MEM_SV
`include "parameters.sv"

module data_mem(clk, MemRead, MemWrite, addr, write_data, read_data);
  input clk;
  input MemRead;
  input MemWrite;
  input [0:ADDR_MSB] addr;
  input [0:DATABUS_MSB] write_data;
  output reg [0:DATABUS_MSB] read_data;
  
  reg [0:DATABUS_MSB] mem [0:MEM_DEPTH-1];
  
  initial begin
    for(int i = 0; i < MEM_DEPTH; i++)
      mem[i] = 0;
  end
  
  always @(posedge clk) begin
    if (MemWrite)
      mem[addr] <= write_data;
  end
  
  always @( * ) begin
    if (MemRead)
      read_data <= mem[addr];
    else
      read_data <= 0;
  end
    
endmodule

`endif