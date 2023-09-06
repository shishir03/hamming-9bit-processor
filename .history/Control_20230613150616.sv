// control decoder
module Control #(parameter opwidth = 4, mcodebits = 9)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  input logic[7:0] datA, datB, mem_out, mem_lut_out,
  output logic Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite, MemSrc,
  output logic[3:0] regA, regB, wr_addr,
  output logic[7:0] dat_in, mem_in, mem_addr, alu_rslt
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  MemSrc  = 'b0;   // 1: immediate  0: read / write from R0
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	    =   'b1111; // y = a+0;
  opcode    = instr[8:6];
  funct     = instr[5:4];
  wr_addr   = instr[3:0];
  immed     = instr[5:1];
  // sample values only -- use what you need
  case(opcode)    // override defaults with exceptions
    'b000:  begin
      regA = 4'b0;
      regB = 4'b1;
      dat_in = alu_rslt;

      case(funct)
        'b00: ALUOp = 0;
        'b01: ALUOp = 1;
        'b10: begin
          dat_in   = mem_out;
          MemToReg = 'b1;
        end
        'b11: begin
          RegWrite = 'b0;
        end
      endcase
    end
    // I type instructions
    'b001: begin         // lb
      dat_in = mem_out;
      wr_addr = {3'b0, instr[0]};
      MemSrc = 'b1;
      MemtoReg = 'b1;
    end
    'b010: begin         // sb
      reg_a = {3'b0, instr[0]};
      mem_in = datA;
      MemSrc = 'b1;
      RegWrite = 'b0;
    end

    'b011: ALUSrc = 'b1;  // addi
    'b100: Branch = 'b1;  // Branch
    // Move
    'b101: begin
      reg_a = instr[1:4];
      wr_addr = {3'b0, instr[5]};
      dat_in = datA;
    end
    // More R type instructions
    'b110: begin
      regA = 4'b0;
      regB = 4'b1;
      dat_in = alu_rslt;

      case(funct)
        'b00: ALUOp = 2;  // LSL
        'b01: ALUOp = 3;  // ASR
        'b10: ALUOp = 4;  // LSR
        'b11: ALUOp = 5;  // not
      endcase
    end
    'b111: begin
      regA = 4'b0;
      regB = 4'b1;
      dat_in = alu_rslt;

      case(funct)
        'b00: ALUOp = 6;  // and
        'b01: ALUOp = 7;  // or
        'b10: ALUOp = 8;  // mul
      endcase
    end
  endcase

end
	
endmodule