// sample top level design
module top_level(
  input        clk, reset, req, 
  output logic done);
  parameter D = 12,             // program counter width
    A = 3;             		  // ALU command bit width
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire        RegWrite;
  wire[3:0]   regA,regB,wr_reg;
  wire[7:0]   datA,datB,		  // from RegFile
              muxB, mem_lut_out, alu_lut_out,
			  rslt,               // alu output
        mem_in,
        mem_out, mem_addr,
  wire[4:0] immed;
  wire        mov;
  logic sc_in,   				  // shift/carry out from/to ALU
   		pariQ,              	  // registered parity flag from ALU
		zeroQ;                    // registered zero flag from ALU 
  // wire  relj;                     // from control to PC; relative jump enable
  wire absj;
  wire  pari,
        zero,
		sc_clr,
		sc_en,
        MemWrite,
        MemtoReg,
        ALUSrc;		              // immediate switch
  wire[A-1:0] alu_cmd;
  wire[8:0]   mach_code;          // machine code
  wire[2:0] rd_addrA, rd_adrB;    // address pointers to reg_file
// fetch subassembly
  PC #(.D(D)) 					  // D sets program counter width
     pc1 (.reset            ,
         .clk              ,
		 // .reljump_en (relj),
		 .absjump_en (absj),
		 .target           ,
		 .prog_ctr          );

     // contains machine code
  instr_ROM ir1(.prog_ctr,
               .mach_code);

  PC_LUT #(.D(D)) pc_lut (
    .addr  (immed),
    .target          
  );

     // control decoder
  Control #(.opwidth(4)) ctl1(
    .instr(mach_code),
    .datA,
    .datB,
    .mem_out,
    .mem_lut_out,
    .Branch  (absj)  , 
    .MemtoReg(MemtoReg),
    .MemWrite , 
    .ALUSrc   , 
    .RegWrite   ,     
    .regA,
    .regB,
    .wr_addr(wr_reg),
    .dat_in,
    .mem_in,
    .mem_addr,
    .immed,
    .alu_rslt(rslt),
    .ALUOp(alu_cmd)
  );

  mem_LUT mem_lut(
    .address(immed),
    .data(mem_lut_out)
  );

  alu_LUT alu_lut(
    .address(immed),
    .data(alu_lut_out)
  );

  // assign rd_addrA = mach_code[2:0];
  // assign rd_addrB = mach_code[5:3];
  // assign rd_addr_out = mach_code[3:0];
  // assign muxMov = 0;
  assign muxALU = ALUSrc ? alu_lut_out : datB;
  // assign muxMem = MemSrc ? immed_mem : datA;

  alu alu1(
     .alu_cmd,
     .inA    (datA),
		 .inB    (muxALU),
		 .sc_i   (sc),   // output from sc register
		 .rslt       ,
		 .sc_o   (sc_o), // input to sc register
		 .pari  );  

  dat_mem dm1(.dat_in(mem_in)  ,  // from reg_file
    .clk           ,
    .wr_en  (MemWrite), // stores
    .addr   (mem_addr),
    .dat_out(mem_out)
  );

  reg_file rf1(
    .dat_in,	   
    .clk         ,
    .wr_en   (RegWrite),      // loads, most ops
    .rd_addrA(regA),
    .rd_addrB(regB),
    .wr_addr (wr_reg),
    .datA_out(datA),
    .datB_out(datB)
  ); 

// registered flags from ALU
  always_ff @(posedge clk) begin
    pariQ <= pari;
	zeroQ <= zero;
    if(sc_clr)
	  sc_in <= 'b0;
    else if(sc_en)
      sc_in <= sc_o;
  end

  assign done = prog_ctr == 128;
 
endmodule