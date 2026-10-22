// Self-checking testbench. Simulation delays belong here, not in the RTL.
module tb_adder;
  timeunit 1ns;
  timeprecision 1ps;

  logic [7:0] a, b;
  logic [8:0] sum;
  adder dut (.a(a), .b(b), .sum(sum));

  task automatic check(input logic [7:0] lhs, rhs,
                       input logic [8:0] expected);
    a = lhs;
    b = rhs;
    #1;  // Allow combinational logic to settle before checking the output.
    if (sum !== expected)
      $fatal(1, "%0d + %0d: expected %0d, got %0d", a, b, expected, sum);
    $display("PASS: %0d + %0d = %0d", a, b, sum);
  endtask

  initial begin
    check(8'd19,  8'd23,  9'd42);
    check(8'd0,   8'd0,   9'd0);
    check(8'd255, 8'd1,   9'd256);  // Catch a dropped carry bit.
    check(8'd255, 8'd255, 9'd510);
    $display("ALL ADDER TESTS PASSED");
    $finish;
  end
endmodule
