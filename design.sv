// design.sv
`include "control.sv"
`include "alu.sv"
`include "data_processing.sv"
`include "instruction_field.sv"
`include "misc.sv"
`include "instruction_mem.sv"
`include "data_mem.sv"

module dataPath(clk, reboot);
  input clk;
  input reboot;

  reg [0:DATABUS_MSB] PC;
  initial begin
    PC = PROG_START;
  end
  
  reg [0:DATABUS_MSB] MDR;
  
  wire [0:DATABUS_MSB] raw_instruction;

  reg [0:30] IR;
  always @(posedge clk) begin
    if (IR_Write)
      IR <= raw_instruction[0:30];
  end
  
  wire [0:3] opcode;
  wire [0:NUM_REGFILE_BITS-1] rs;
  wire [0:NUM_REGFILE_BITS-1] rd;
  wire [0:NUM_REGFILE_BITS-1] rt;
  wire [0:11] imm_raw;

  instruction_field ifield(
    .instruction(IR),
    .opcode(opcode),
    .rs(rs),
    .rd(rd),
    .rt(rt),
    .immediate(imm_raw)
  );

  wire [0:DATABUS_MSB] imm_sign_ext;
  assign imm_sign_ext = {{24{imm_raw[0]}}, imm_raw};

  wire IR_Write;
  wire MemtoReg;
  wire MemWrite;
  wire MemRead;
  wire PC_Write;
  wire PC_Write_Cond;
  wire Reg_Destination;
  wire RegWrite;
  wire ALU_SRC_A;
  wire [0:1] ALU_SRC_B;
  wire [0:3] ALU_opcode;
  wire [0:1] PC_Source;
  wire [0:3] state_check;
  wire CarryOut;
  wire Zero;
  wire oVerflow;
  wire Negative;

  control ctrl(
    .clk(clk),
    .reboot(reboot),
    .opcode(opcode),
    .CarryOut(CarryOut),
    .Zero(Zero),
    .Negative(Negative),
    .oVerflow(oVerflow),
    .IR_Write(IR_Write),
    .MemtoReg(MemtoReg),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .PC_Write(PC_Write),
    .PC_Write_Cond(PC_Write_Cond),
    .Reg_Destination(Reg_Destination),
    .RegWrite(RegWrite),
    .ALU_SRC_A(ALU_SRC_A),
    .ALU_SRC_B(ALU_SRC_B),
    .ALU_opcode(ALU_opcode),
    .PC_Source(PC_Source),
    .state_check(state_check)
  );

  wire [0:DATABUS_MSB] alu_out;
  wire [0:DATABUS_MSB] reg_data2;
  wire [0:DATABUS_MSB] mem_data;
  
  //This was the key component missing in my original file
  //The CPU calculated the address correctly, but the data in the memory
  //was not stored anywhere properly and kept getting overwritten. The
  //MDR forces memory to latch to the memory read stage, so that way
  //this error doesn't happen.
  always @(posedge clk or posedge reboot) begin
    if (reboot)
      MDR <= 0;
    else if (state_check == CTRL_MEM_READ)
      MDR <= mem_data;
  end
  
  data_processing dp(
    .clk(clk),
    .ALU_SRC_A(ALU_SRC_A),
    .ALU_SRC_B(ALU_SRC_B),
    .MemtoReg(MemtoReg),
    .Reg_Destination(Reg_Destination),
    .RegWrite(RegWrite),
    .opcode(ALU_opcode),
    .rs(rs),
    .rd(rd),
    .rt(rt),
    .immediate(imm_sign_ext),
    .PC(PC),
    .mem_data(MDR),
    .alu_out(alu_out),
    .reg_data2(reg_data2),
    .CarryOut(CarryOut),
    .Negative(Negative),
    .Zero(Zero),
    .oVerflow(oVerflow)
  );

  reg [0:DATABUS_MSB] ALUout_reg;
  always @(posedge clk or posedge reboot) begin
    if (reboot)
      ALUout_reg <= '0;
    else if (state_check == CTRL_EXECUTE_MEM)
      ALUout_reg <= alu_out;
  end

  // Latch branch target during decode of a branch instruction only.
  // At DECODE, the ALU computes PC + sign_ext(imm) = branch target address.
  reg [0:DATABUS_MSB] branch_target;

  always @(posedge clk or posedge reboot) begin
    if (reboot)
      branch_target <= PROG_START;
    else if (state_check == CTRL_DECODE && opcode == BRANCH)
      branch_target <= alu_out;
  end

  // Latch the Zero flag during EXECUTE_ALU, while the ALU is still performing the actual instruction operation such as LTE.
// This is important because during WRITEBACK_ALU, the control signals go back to their default values, so the live ALU may no longer be doing LTE.
  reg Zero_latch;

  always @(posedge clk or posedge reboot) begin
    if (reboot)
      Zero_latch <= 1'b1; // default branch-not-taken condition
    else if (state_check == CTRL_EXECUTE_ALU)
      Zero_latch <= Zero;
  end
  
  instruction_mem i_mem(
    .addr(PC[25:35]),
    .instruction(raw_instruction)
  );

  data_mem d_mem(
    .clk(clk),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .addr(ALUout_reg[25:35]),
    .write_data(reg_data2),
    .read_data(mem_data)
  );

  // PC update logic:
  // On reboot, reset to PROG_START.
  // On conditional branch, jump to branch_target
  // if the latched Zero flag is 0 (meaning the previous compare was TRUE,
  //     LTE returned 1 which is non-zero, so Zero=0).
  // On unconditional PC_Write (FETCH increment, ADDI immediate add),
  //     update PC from the live ALU output.
  always @(posedge clk or posedge reboot) begin
    if (reboot)
      PC <= PROG_START;
    else begin
      if (PC_Write_Cond && ~Zero_latch)
        PC <= branch_target;
      else if (PC_Write)
        PC <= alu_out;
    end
  end

endmodule