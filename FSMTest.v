`timescale 1ns / 1ps


`define TESTCOUNT 32
`define HalfClock 50
`define ClockPeriod `HalfClock * 2
`define LAA 2'b01
`define LBB 2'b10
`define LCC 2'b11
`define NUL 2'b00




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
reg CURRSIGN;
reg SHORT;
reg [7:0] passed;
reg [15:0] watchdog;

// Output
wire [5:0] Sout;

//Instantiate Unit Under Test
FSM uut (
	.clk(CLK),
	.rst(rst),
	.start(start),
	.DesiredLoad(DesiredLoad),
	.CurrentSign(CURRSIGN),
	.Short(SHORT),
	.Sout(Sout)
);

initial begin
	rst = 1;
	passed = 0;
	DesiredLoad = `NUL;
	start = 0;
	SHORT = 0;

	watchdog = 0;

	#(1 * `ClockPeriod);
	#1
	@(posedge CLK);
	@(negedge CLK);
	@(posedge CLK);
	rst = 0;

	//TEST 1, INITIAL START THAT THERE IS NO OUTPUT
	passTest(Sout,6'b000000, "Initial Start", passed);
	DesiredLoad = `LAA;
	while(watchdog <= 5)
		begin
			@(posedge CLK);
			@(negedge CLK);
		end
	passTest(Sout,6'b000000, "Starting before Start Pin Enable", passed);

	start = 1;
	while(watchdog <= 10)
		begin
			@(posedge CLK);
			@(negedge CLK);
		end
	passTest(Sout,6'b110000, "Starting with SAA", passed);
	DesiredLoad = `LBB;
	while(watchdog <= 20)
		begin
			@(posedge CLK);
			@(negedge CLK);
		end
	passTest(Sout,6'b001100, "Changing to SBB", passed);
	CURRSIGN = ~CURRSIGN;
	DesiredLoad = `LAA;

	while(watchdog <= 30)
		begin
			@(posedge CLK);
			@(negedge CLK);
		end
	passTest(Sout,6'b110000, "Negative Current SAA", passed);

	//The Short Test
	SHORT = 1;
	@(posedge CLK);
	@(negedge CLK);
	SHORT = 0;
	DesiredLoad = `LCC;
	while(watchdog <= 32)
		begin
			@(posedge CLK);
			@(negedge CLK);
		end
	passTest(Sout,6'b000000, "Shorted", passed);


	allPassed(passed,6);
	$finish;
end

initial begin
	CLK = 0;
	CURRSIGN = 1;
end

always begin
	#`HalfClock CLK = ~CLK;
	#`HalfClock CLK = ~CLK;
	watchdog = watchdog + 1;
end
endmodule
