`ifndef INSTRUCTION_MEM_SV
`define INSTRUCTION_MEM_SV
`include "parameters.sv"

module instruction_mem(addr, instruction);
  
  input [0:ADDR_MSB] addr;
  output [0:DATABUS_MSB] instruction;
  
  reg [0:DATABUS_MSB] mem [0:MEM_DEPTH-1];
  
  initial begin
    for (int i = 0; i < MEM_DEPTH; i++)
      mem[i] = 0;
  end
  
  assign instruction = mem[addr];
endmodule

`endif