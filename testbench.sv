// testbench.sv
`ifndef TESTBENCH_SV
`define TESTBENCH_SV

module tb();

  reg clk;
  reg reboot;

  dataPath uut(.clk(clk),
               .reboot(reboot));

  // ------------------------------------------------------------
  // Opcode localparams
  // ------------------------------------------------------------
  localparam [0:3] OP_ADD = 4'b0000;
  localparam [0:3] OP_ADDI = 4'b0110;
  localparam [0:3] OP_LTE = 4'b1000;
  localparam [0:3] OP_BRANCH = 4'b1101;
  localparam [0:3] OP_LOAD = 4'b1110;
  localparam [0:3] OP_STORE = 4'b1111;

  // ------------------------------------------------------------
  // Program 1 data addresses
  // ------------------------------------------------------------
  localparam [0:11] A_ADDR = 12'h010;
  localparam [0:11] B_ADDR = 12'h020;
  localparam [0:11] C_ADDR = 12'h030;

  // NOP = ADDI r0, r0, 0
  localparam [0:35] NOP_INSTR = {OP_ADDI, 5'd0, 5'd0, 5'd0, 12'd0, 5'b0};

  // ------------------------------------------------------------
  // Clock
  // ------------------------------------------------------------
  initial clk = 0;
  always #5 clk = ~clk;

  // ------------------------------------------------------------
  // Reset task
  // Releases reboot on negative edge to avoid clock/reset race
  // ------------------------------------------------------------
  task automatic reset_cpu();
    begin
      reboot = 1'b1;
      repeat(3) @(posedge clk);
      @(negedge clk);
      reboot = 1'b0;
    end
  endtask
              
  // ------------------------------------------------------------
  // Clear register file
  // ------------------------------------------------------------
  task automatic clear_regs();
    begin
      for (int i = 0; i < 32; i++) begin
        uut.dp.regf.reg_mem[i] = 36'd0;
      end
    end
  endtask

  // ------------------------------------------------------------
  // Clear instruction memory region
  // ------------------------------------------------------------
  task automatic clear_imem_region(input int start_addr, input int end_addr);
    begin
      for (int i = start_addr; i <= end_addr; i++) begin
        uut.i_mem.mem[i] = 36'd0;
      end
    end
  endtask

  // ------------------------------------------------------------
  // Main simulation
  // ------------------------------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    reboot = 1'b1;

    // IMPORTANT:
    // Let all module initial blocks finish first.
    // Without this delay, instruction_mem and data_mem may clear
    // Program 1 after the testbench loads it.
    
    //NOP required in between instruction
    //I honestly don't know why, but I don't have hazard control
    //so I can only imagine it's that.
    #1;

    // ============================================================
    // PROGRAM 1:
    //
    // A = 0x10
    // B = 0x20
    // C = 0x30
    //
    // mem[0x10] = 20
    // mem[0x20] = 22
    //
    // Expected:
    // mem[0x30] = 42
    //
    // Assembly:
    // LOAD  r1, mem[0x10]
    // LOAD  r2, mem[0x20]
    // ADD   r3, r1, r2
    // STORE r3, mem[0x30]
    // ============================================================

    clear_regs();
    clear_imem_region(11'h400, 11'h420);

    // Initialize data memory
    uut.d_mem.mem[A_ADDR] = 36'd20;
    uut.d_mem.mem[B_ADDR] = 36'd22;
    uut.d_mem.mem[C_ADDR] = 36'd0;

    // Format:
    // {opcode, rs, rt, rd, immediate, padding}
    
    // LOAD r1, mem[0x10]
    // rs = r0
    // rt = r1
    // rd = unused
    // immediate = 0x10
    uut.i_mem.mem[11'h400] = {OP_LOAD,  5'd0, 5'd1, 5'd0, A_ADDR, 5'b0};

    // NOP
    uut.i_mem.mem[11'h401] = NOP_INSTR;

    // LOAD r2, mem[0x20]
    // rs = r0
    // rt = r2
    // rd = unused
    // immediate = 0x20
    uut.i_mem.mem[11'h402] = {OP_LOAD,  5'd0, 5'd2, 5'd0, B_ADDR, 5'b0};

    // NOP
    uut.i_mem.mem[11'h403] = NOP_INSTR;

    // ADD r3, r1, r2
    // rs = r1
    // rt = r2
    // rd = r3
    uut.i_mem.mem[11'h404] = {OP_ADD,   5'd1, 5'd2, 5'd3, 12'd0, 5'b0};

    // NOP before STORE so r3 has time to write back
    uut.i_mem.mem[11'h405] = NOP_INSTR;

    // STORE r3, mem[0x30]
    // STORE writes reg_data2, which comes from rt.
    // rs = r0
    // rt = r3
    // rd = unused
    // immediate = 0x30
    uut.i_mem.mem[11'h406] = {OP_STORE, 5'd0, 5'd3, 5'd0, C_ADDR, 5'b0};

    // Safe NOP after store
    uut.i_mem.mem[11'h407] = NOP_INSTR;

    reset_cpu();
    //4 Users if there were any
    $display("============================================================");
    $display("=== Program 1: C = A + B using memory addresses ===");
    $display("A address = 0x10, B address = 0x20, C address = 0x30");
    $display("mem[0x10] = 20, mem[0x20] = 22");
    $display("Expected: mem[0x30] = 42");
    $display("============================================================");

    repeat(150) @(posedge clk);
	//Makes it easier to find my output when scrolling through terminal output
    $display("Program 1 Results:");
    $display("mem[0x10] = %0d expected 20", uut.d_mem.mem[A_ADDR]);
    $display("mem[0x20] = %0d expected 22", uut.d_mem.mem[B_ADDR]);
    $display("mem[0x30] = %0d expected 42", uut.d_mem.mem[C_ADDR]);

    $display("r1(A)=%0d r2(B)=%0d r3(C)=%0d expected 20, 22, 42",
             uut.dp.regf.reg_mem[1],
             uut.dp.regf.reg_mem[2],
             uut.dp.regf.reg_mem[3]);
	//Easy check to see if my computer is working or not
    if ((uut.d_mem.mem[A_ADDR] == 36'd20) &&
        (uut.d_mem.mem[B_ADDR] == 36'd22) &&
        (uut.d_mem.mem[C_ADDR] == 36'd42)) begin
      $display("PROGRAM 1 PASSED");
    end
    else begin
      $display("PROGRAM 1 FAILED");
    end


    // ============================================================
    // PROGRAM 2:
    //
    // sum = 0;
    // for(i = 0; i <= 10; i++) begin
    //   sum += i;
    // end
    //
    // Register use:
    // r1 = i
    // r2 = sum
    // r3 = 10
    // r4 = 1
    // r5 = comparison result from LTE
    //
    // Expected:
    // r1 = 11
    // r2 = 55
    // ============================================================

    reboot = 1'b1;
    @(negedge clk);

    clear_regs();
    clear_imem_region(11'h400, 11'h420);

    // r1 = i = 0
    uut.i_mem.mem[11'h400] = {OP_ADDI,   5'd0, 5'd0, 5'd1, 12'd0,   5'b0};
    uut.i_mem.mem[11'h401] = NOP_INSTR;

    // r2 = sum = 0
    uut.i_mem.mem[11'h402] = {OP_ADDI,   5'd0, 5'd0, 5'd2, 12'd0,   5'b0};
    uut.i_mem.mem[11'h403] = NOP_INSTR;

    // r3 = 10
    uut.i_mem.mem[11'h404] = {OP_ADDI,   5'd0, 5'd0, 5'd3, 12'd10,  5'b0};
    uut.i_mem.mem[11'h405] = NOP_INSTR;

    // r4 = 1
    uut.i_mem.mem[11'h406] = {OP_ADDI,   5'd0, 5'd0, 5'd4, 12'd1,   5'b0};
    uut.i_mem.mem[11'h407] = NOP_INSTR;

    // Loop starts at 0x408
    // sum = sum + i
    uut.i_mem.mem[11'h408] = {OP_ADD,    5'd2, 5'd1, 5'd2, 12'd0,   5'b0};
    uut.i_mem.mem[11'h409] = NOP_INSTR;

    // i = i + 1
    uut.i_mem.mem[11'h40A] = {OP_ADD,    5'd1, 5'd4, 5'd1, 12'd0,   5'b0};
    uut.i_mem.mem[11'h40B] = NOP_INSTR;

    // r5 = i <= 10
    uut.i_mem.mem[11'h40C] = {OP_LTE,    5'd1, 5'd3, 5'd5, 12'd0,   5'b0};

    // No NOP between LTE and BRANCH.
    // Instruction at 0x40D.
    // After fetch, PC = 0x40E.
    // Target = 0x408.
    // Offset = 0x408 - 0x40E = -6 = 12'hFFA.
    uut.i_mem.mem[11'h40D] = {OP_BRANCH, 5'd0, 5'd0, 5'd0, 12'hFFA, 5'b0};

    // Safe NOP after loop exits
    uut.i_mem.mem[11'h40E] = NOP_INSTR;

    reset_cpu();

    $display("============================================================");
    $display("=== Program 2: summing from 0 to 10 ===");
    $display("Expected: r1 = 11 and r2 = 55");
    $display("============================================================");

    repeat(2000) @(posedge clk);

    $display("Program 2 Results:");
    $display("r1(i)   = %0d expected 11", uut.dp.regf.reg_mem[1]);
    $display("r2(sum) = %0d expected 55", uut.dp.regf.reg_mem[2]);

    if ((uut.dp.regf.reg_mem[1] == 36'd11) &&
        (uut.dp.regf.reg_mem[2] == 36'd55)) begin
      $display("PROGRAM 2 PASSED");
    end
    else begin
      $display("PROGRAM 2 FAILED");
    end

    $display("============================================================");
    $display("=== Simulation Complete ===");
    $display("============================================================");

    $finish;
  end

endmodule

`endif