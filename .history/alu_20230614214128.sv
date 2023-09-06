// combinational -- no clock
// sample -- change as desired
module alu(
  input[3:0] alu_cmd,    // ALU instructions
  input[7:0] inA, inB,	 // 8-bit wide data path
  input      sc_i,       // shift_carry in
  input		 pari_in,
  output logic[7:0] rslt,
  output logic sc_o,     // shift_carry out
               pari,     // reduction XOR (output)
			   zero      // NOR (output)
);

always_comb begin 
 rslt = 8'b0;            
 sc_o = 1'b0;    
 zero = !rslt;
 pari = ^rslt;
 case(alu_cmd)
	0: // add 2 8-bit unsigned; automatically makes carry-out
	  {sc_o, rslt} = inA + inB + sc_i;
	1: // sub (shanky)
	  {sc_o, rslt} = inA - inB + sc_i;
	2: // left_shift
	  {sc_o, rslt} = {inA, sc_i};
	3: // arithmetic right shift (alternative syntax -- works like left shift)
	  {rslt, sc_o} = {inA[7], inA};
	4: // logical right shift
	  {rslt, sc_o} = {sc_i, inA};
	5: // not
	  rslt = !inA;
	6: // bitwise AND
	  rslt = inA & inB;
	7: // bitwise XOR
	  rslt = inA ^ inB;
	8: // mul
	  rslt = inA * inB;
 endcase
end
   
endmodule