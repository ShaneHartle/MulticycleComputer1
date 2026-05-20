`ifndef CONTROL_SV
`define CONTROL_SV
`include "parameters.sv"

module control(opcode, clk, reboot, CarryOut, Negative, Zero, oVerflow, IR_Write,
              MemtoReg, MemWrite, MemRead, PC_Write, PC_Write_Cond,
               Reg_Destination, RegWrite, ALU_SRC_A, ALU_SRC_B, ALU_opcode,
              PC_Source, state_check);
  input clk;
  input [0:3] opcode;
  input reboot;
  input CarryOut;
  input Negative;
  input Zero;
  input oVerflow;
  
  
  output reg IR_Write;
  output reg MemtoReg;
  output reg MemWrite;
  output reg MemRead;
  output reg PC_Write;
  output reg PC_Write_Cond;
  output reg Reg_Destination;
  output reg RegWrite;
  output reg ALU_SRC_A;
  output reg [0:1] ALU_SRC_B;
  output reg [0:3] ALU_opcode;
  output reg [0:1] PC_Source;
  
  reg [0:3] curr_state, next_state;
  
  //This part is just used here for checking
  output [0:3] state_check;
  assign state_check = curr_state;
  
  //CTRL Logic
  always @(posedge clk or posedge reboot) begin
    if (reboot)
      curr_state <= CTRL_REBOOT; //For some reason it doesn't like =, and it only wants <=
    else
      curr_state <= next_state;
  end
  
  always @(*) begin
    //set everything to 0
    IR_Write = 0;
    MemtoReg = 0;
    MemWrite = 0;
    MemRead = 0;
    PC_Write = 0;
    PC_Write_Cond = 0;
    Reg_Destination = 0;
    RegWrite = 0;
    ALU_SRC_A = 0;
    ALU_SRC_B = ALU_B_REG;
    ALU_opcode = ALU_ADD;
    PC_Source = PC_SRC_SEQ;
    next_state = CTRL_REBOOT;
    
    case (curr_state)
    //Reboot stage
    CTRL_REBOOT: begin
      next_state = CTRL_FETCH;
    end
      
    //Fetch stage
    CTRL_FETCH: begin
      IR_Write = 1;
      PC_Write = 1;
      ALU_SRC_A = 1;
      ALU_SRC_B = ALU_B_CONST1;
      ALU_opcode = ALU_ADD;
      PC_Source = PC_SRC_SEQ;
      next_state = CTRL_DECODE;
    end
    
    //Decode Stage
    CTRL_DECODE: begin
      ALU_SRC_A = 1;
      ALU_SRC_B = ALU_B_IMM;
      ALU_opcode = ALU_ADD;
      
      case(opcode)
        ADD: next_state = CTRL_EXECUTE_ALU;
		SUB: next_state = CTRL_EXECUTE_ALU;
		SHIFT_LEFT: next_state = CTRL_EXECUTE_ALU;
		SHIFT_RIGHT: next_state = CTRL_EXECUTE_ALU;
		AND: next_state = CTRL_EXECUTE_ALU;
		OR: next_state = CTRL_EXECUTE_ALU;
        ADDI: next_state = CTRL_EXECUTE_ALU;
		EQUAL: next_state = CTRL_EXECUTE_ALU;
		LESSTHANEQUAL: next_state = CTRL_EXECUTE_ALU;
		GREATTHANEQUAL: next_state = CTRL_EXECUTE_ALU;
		LESSTHAN: next_state = CTRL_EXECUTE_ALU;
		GREATTHAN: next_state = CTRL_EXECUTE_ALU;
		NOT: next_state = CTRL_EXECUTE_ALU;
		BRANCH: next_state = CTRL_EXECUTE_BRANCH;
        LOAD: next_state = CTRL_EXECUTE_MEM;
        STORE: next_state = CTRL_EXECUTE_MEM;
        default: next_state = CTRL_FETCH;
      endcase
    end
    //Execute ALU stage
    CTRL_EXECUTE_ALU: begin
      ALU_SRC_A = 0;
      
      if (opcode == ADDI)
        ALU_SRC_B = ALU_B_IMM;
      else
        ALU_SRC_B = ALU_B_REG;
      
      case(opcode)
        ADD: ALU_opcode = ALU_ADD;
		SUB: ALU_opcode = ALU_SUB;
		SHIFT_LEFT: ALU_opcode = ALU_SHIFT_LEFT;
		SHIFT_RIGHT: ALU_opcode = ALU_SHIFT_RIGHT;
		AND: ALU_opcode = ALU_AND;
		OR: ALU_opcode = ALU_OR;
        ADDI: ALU_opcode = ALU_ADD;
		EQUAL: ALU_opcode = ALU_EQUAL;
		LESSTHANEQUAL: ALU_opcode = ALU_LESSTHANEQUAL;
		GREATTHANEQUAL: ALU_opcode = ALU_GREATTHANEQUAL;
		LESSTHAN: ALU_opcode = ALU_LESSTHAN;
		GREATTHAN: ALU_opcode = ALU_GREATTHAN;
		NOT: ALU_opcode = ALU_NOT;
        default: ALU_opcode = ALU_ADD;
      endcase
      next_state = CTRL_WRITEBACK_ALU;
    end
    
    //Execute Branch
    CTRL_EXECUTE_BRANCH: begin
      PC_Write_Cond = 1;
      PC_Source = PC_SRC_BRANCH;
      next_state = CTRL_FETCH;
    end
      
    //Execute memory stage, load/store memory address
    CTRL_EXECUTE_MEM: begin
      ALU_SRC_A = 0;
      ALU_SRC_B = ALU_B_IMM;
      ALU_opcode = ALU_ADD;
      
      case(opcode)
        LOAD: next_state = CTRL_MEM_READ;
		STORE: next_state = CTRL_MEM_WRITE;
        default: next_state = CTRL_FETCH;
      endcase
    end
    
    //Read from memory
    CTRL_MEM_READ: begin
      MemRead = 1;
      next_state = CTRL_WRITEBACK_MEM;
    end
    
    //Write to memory, go back to fetch more instructions
    CTRL_MEM_WRITE: begin
      MemWrite = 1;
      next_state = CTRL_FETCH;
    end
      
    //Writeback ALU to register
    CTRL_WRITEBACK_ALU: begin
      RegWrite = 1;
      Reg_Destination = 1;
      MemtoReg = 0;
      next_state = CTRL_FETCH;
    end
      
    //Writeback memory to register
    CTRL_WRITEBACK_MEM: begin
      RegWrite = 1;
      Reg_Destination = 0;
      MemtoReg = 1;
      next_state = CTRL_FETCH;
    end
      
    //When in doubt, Reboot!
    default: begin
      next_state = CTRL_REBOOT;
    end
      
    endcase
  end
endmodule

`endif