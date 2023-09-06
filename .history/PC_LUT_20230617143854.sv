module PC_LUT #(parameter D=10)(
  input       [3:0] addr,	   
  output logic [D-1:0] target);

  logic [D-1:0] lut [0:15];

  initial begin
    lut[0] = 0;
    lut[1] = 11;
    lut[2] = 80;         // shift
    lut[3] = 68;        // correct
    lut[4] = 116;         // end
    lut[5] = 53;         // lsbshift
    lut[6] = 56;          // next
    lut[7] = 59;         // beginshiftloop
    lut[8] = 77;         // lsbxor
    lut[9] = 20;
    lut[10] = 1;         // start
    lut[11] = 44;        // corrections start
  end

  always_comb begin
    target = lut[addr];
  end

endmodule

/*

	   pc = 4    0000_0000_0100	  4
	             1111_1111_1111	 -1

                 0000_0000_0011   3

				 (a+b)%(2**12)


   	  1111_1111_1011      -5
      0000_0001_0100     +20
	  1111_1111_1111      -1
	  0000_0000_0000     + 0


  */