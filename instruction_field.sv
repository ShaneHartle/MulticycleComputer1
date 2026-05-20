`ifndef INSTRUCTION_FIELD_SV
`define INSTRUCTION_FIELD_SV
`include "parameters.sv"

module instruction_field(instruction, opcode, rs, rt, rd, immediate);
  input [0:30] instruction;
  output [0:3] opcode;
  output [0:4] rs;
  output [0:4] rt;
  output [0:4] rd;
  output [0:11] immediate;
  
  assign opcode = instruction[0:3];
  assign rs = instruction[4:8];
  assign rt = instruction[9:13];
  assign rd = instruction[14:18];
  assign immediate = instruction[19:30];
  
endmodule
`endif