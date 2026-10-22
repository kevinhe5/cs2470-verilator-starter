// Combinational RTL: retain the carry bit when adding two 8-bit inputs.
module adder (
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic [8:0] sum
);
  assign sum = {1'b0, a} + {1'b0, b};
endmodule
