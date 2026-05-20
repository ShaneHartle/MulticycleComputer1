`ifndef PARAMETERS_SV
`define PARAMETERS_SV

parameter DATABUS_SIZE = 36;
parameter DATABUS_MSB = DATABUS_SIZE - 1 ;
parameter NUM_REGFILE_BITS = 5;
parameter NUM_REGISTERS = (1 << NUM_REGFILE_BITS) ;
parameter ADDR_SIZE = 11;
parameter ADDR_MSB = ADDR_SIZE - 1;
parameter MEM_DEPTH = 2048;
parameter PROG_START = 11'h400;



parameter ALU_ADD = 0;
parameter ALU_SUB = 1;
parameter ALU_SHIFT_LEFT = 2;
parameter ALU_SHIFT_RIGHT = 3;
parameter ALU_AND = 4;
parameter ALU_OR = 5;
parameter ALU_XOR = 6;
parameter ALU_EQUAL = 7;
parameter ALU_LESSTHANEQUAL = 8;
parameter ALU_GREATTHANEQUAL = 9;
parameter ALU_LESSTHAN = 10;
parameter ALU_GREATTHAN = 11;
parameter ALU_NOT = 12;
parameter ALU_MODULO = 13;
parameter ALU_ADDCARRY = 14;
parameter ALU_REVERSESUB = 15;

//Gotta make sure ISA instruction matches ALU instruction
parameter ADD = 4'b0000;
parameter SUB = 4'b0001;
parameter SHIFT_LEFT = 4'b0010;
parameter SHIFT_RIGHT = 4'b0011;
parameter AND = 4'b0100;
parameter OR = 4'b0101;
parameter ADDI = 4'b0110;
parameter EQUAL = 4'b0111;
parameter LESSTHANEQUAL = 4'b1000;
parameter GREATTHANEQUAL = 4'b1001;
parameter LESSTHAN = 4'b1010;
parameter GREATTHAN = 4'b1011;
parameter NOT = 4'b1100;
parameter BRANCH = 4'b1101;
parameter LOAD = 4'b1110;
parameter STORE = 4'b1111;

//FSM control states
parameter CTRL_FETCH = 4'b0000; //Get instruction
parameter CTRL_DECODE = 4'b0001; //Read registers
parameter CTRL_EXECUTE_ALU = 4'b0010; //ALU R-type instructions
parameter CTRL_EXECUTE_MEM = 4'b0011; //ALU memory address store and load
parameter CTRL_EXECUTE_BRANCH = 4'b0100; //Go through branch
parameter CTRL_MEM_READ = 4'b0101; //Read memory
parameter CTRL_MEM_WRITE = 4'b0110; //Write to memory
parameter CTRL_WRITEBACK_ALU = 4'b0111; //Writeback ALU results to register
parameter CTRL_WRITEBACK_MEM = 4'b1000; //Writeback data in memory to register
parameter CTRL_REBOOT = 4'b1111;

//PC_Source encode
parameter PC_SRC_SEQ = 2'b00; //Move sequentially (normal)
parameter PC_SRC_BRANCH = 2'b01; //Branch, PC
parameter PC_SRC_REG = 2'b10; //Jump to a register

//ALU_SRC_B encode
parameter ALU_B_REG = 2'b00; //R-type instruction
parameter ALU_B_IMM = 2'b01; //I-type instruction
parameter ALU_B_CONST1 = 2'b10; //PC increment

`endif