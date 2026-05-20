// data_processing.sv
`ifndef DATA_PROCESSING_SV
`define DATA_PROCESSING_SV
`include "parameters.sv"
`include "alu.sv"
`include "regfile.sv"
`include "misc.sv"

module data_processing(clk, ALU_SRC_A, ALU_SRC_B, MemtoReg, Reg_Destination,
                       RegWrite, opcode, rs, rt, rd, immediate, PC, mem_data,
                       alu_out, reg_data2, CarryOut, Zero, oVerflow, Negative);

  input             clk;
  input             ALU_SRC_A;
  input [0:1]       ALU_SRC_B;
  input             MemtoReg;
  input             Reg_Destination;
  input             RegWrite;
  input [0:3]       opcode;
  input [0:NUM_REGFILE_BITS-1] rs;
  input [0:NUM_REGFILE_BITS-1] rt;
  input [0:NUM_REGFILE_BITS-1] rd;
  input [0:DATABUS_MSB]        immediate;
  input [0:DATABUS_MSB]        PC;
  input [0:DATABUS_MSB]        mem_data;

  output [0:DATABUS_MSB]       alu_out;
  output [0:DATABUS_MSB]       reg_data2;
  output                       CarryOut;
  output                       Zero;
  output                       oVerflow;
  output                       Negative;

  wire [0:DATABUS_MSB] read_data1;
  wire [0:DATABUS_MSB] read_data2;
  wire [0:DATABUS_MSB] A;
  wire [0:DATABUS_MSB] B;
  wire [0:DATABUS_MSB] write_data;
  wire [0:NUM_REGFILE_BITS-1] write_addr;

  // Latch ALU result so it stays stable during WRITEBACK
  // Without this, ALU computes garbage during WRITEBACK and
  // the register file receives the wrong value
  reg [0:DATABUS_MSB] alu_out_reg;
  always @(posedge clk) begin
    alu_out_reg <= alu_out;
  end

  // MUX: ALU input A — 0=reg data1, 1=PC
  mux2x1_data mux_A(
    .data_in0(read_data1),
    .data_in1(PC),
    .select(ALU_SRC_A),
    .data_out(A)
  );

  // MUX: ALU input B — 00=reg, 01=immediate, 10=const 1
  mux3x1_data mux_B(
    .data_in0(read_data2),
    .data_in1(immediate),
    .data_in2({{(DATABUS_MSB){1'b0}}, 1'b1}),
    .select(ALU_SRC_B),
    .data_out(B)
  );

  // MUX: write address — 0=rt, 1=rd
  mux2x1_addr mux_waddr(
    .data_in0(rt),
    .data_in1(rd),
    .select(Reg_Destination),
    .data_out(write_addr)
  );

  // MUX: write data — 0=latched ALU result, 1=memory data
  // Uses alu_out_reg (registered) not alu_out (live) so the
  // EXECUTE result is still available during WRITEBACK
  mux2x1_data mux_wdata(
    .data_in0(alu_out_reg),
    .data_in1(mem_data),
    .select(MemtoReg),
    .data_out(write_data)
  );

  // ALU
  ALU alu(
    .bus1(A),
    .bus2(B),
    .ALUout(alu_out),
    .opcode(opcode),
    .CarryOut(CarryOut),
    .Negative(Negative),
    .Zero(Zero),
    .oVerflow(oVerflow)
  );

  // Register file
  regfile regf(
    .clk(clk),
    .read_addr1(rs),
    .read_addr2(rt),
    .write_addr(write_addr),
    .read_data1(read_data1),
    .read_data2(read_data2),
    .write_data(write_data),
    .write_enable(RegWrite)
  );

  assign reg_data2 = read_data2;

endmodule
`endif