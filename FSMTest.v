`timescale 1ns / 1ps


`define TESTCOUNT 32
`define HalfClock 30
`define ClockPeriod `HalfClock * 2

module FSMTest;

initial
begin
	$dumpfile("FSM.vcd");
	$dumpvars;
end


task passTest;
	input [5:0] actualOut, expectedOut;
	input [`TESTCOUNT*6:0] testType;
	inout [7:0] passed;
	if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
	else $display ("%s failed: %x should be %x", testType, actualOut, expectedOut);
endtask

task allPassed;
	input [7:0] passed;
	input [7:0] numTests;

	if(passed == numTests) $display ("All tests passed");
	else $display("Some tests failed: %d of %d passed", passed, numTests);
endtask

// Inputs
reg CLK;
reg rst;
reg start;
reg [1:0] DesiredLoad;
reg CurrentSign;
reg Short;
reg [7:0] passed;

// Output
wire [5:0] Sout;

//Instantiate Unit Under Test
FSM uut (
	.clk(CLK),
	.rst(rst),
	.start(start),
	.DesiredLoad(DesiredLoad),
	.CurrentSign(CurrentSign),
	.Short(Short),
	.Sout(Sout)
);

initial begin
	rst = 1;
	start = 0;
	passed = 0;

	#(1 * `ClockPeriod);
	#1
	@(posedge CLK);
	@(negedge CLK);
	@(posedge CLK);

	//TEST 1, INITIAL START THAT THERE IS NO OUTPUT
	passTest(Sout,6'b000000, "Initial Start", passed);

	allPassed(passed,1);
	$finish;
end

initial begin
	CLK = 0;
end

always begin
	#`HalfClock CLK = ~CLK;
	#`HalfClock CLK = ~CLK;
end
endmodule
