module mem_LUT (
  input [4:0] address,
  output logic [7:0] data
);

 logic [7:0] lut [0:31];

  initial begin
    lut[0] = 60;
    lut[1] = 61;
    lut[2] = 62;
    lut[3] = 63;
    lut[4] = 64;
    lut[5] = 65;
    lut[6] = 66;
    lut[7] = 67;
    lut[8] = 68;
    lut[9] = 69;
    lut[10] = 70;
    lut[11] = 71;
    lut[12] = 72;
    lut[13] = 73;
    lut[14] = 74;
    lut[15] = 75;
    lut[16] = 76;
    lut[17] = 77;
    lut[18] = 78;
    lut[19] = 79;
    lut[20] = 80;
    lut[31] = 32;
    lut[30] = 31;           // amazing coding style
  end

  always_comb begin
    data = lut[address];
  end

endmodule
