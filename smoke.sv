// The original installation smoke test: compile and run a tiny SV program.
module smoke;
  initial begin
    int sum;
    sum = 19 + 23;
    if (sum != 42) $fatal(1, "Arithmetic check failed");
    $display("PASS: Verilator simulation produced %0d", sum);
    $finish;
  end
endmodule
