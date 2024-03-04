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
reg [1:0] DesiredLoad;
reg CURRSIGN;
reg SHORT;


// UUT
reg [7:0] passed;

// Output
wire [5:0] Sout;

//Instantiate Unit Under Test
FSM uut (
	.clk(CLK),
	.rst(rst),
	.DesiredLoad(DesiredLoad),
	.CurrentSign(CURRSIGN),
	.Sout(Sout)
);

initial begin
	rst = 1;
	passed = 0;
	DesiredLoad = `NUL;
	SHORT = 0;

	#(1 * `ClockPeriod);
	#1

	//TEST 1, INITIAL START THAT THERE IS NO OUTPUT
	passTest(Sout,6'b000000, "Initial Start", passed);

	DesiredLoad = `LAA;
	#(4*`ClockPeriod)
	passTest(Sout,6'b000000, "Starting before rst Drop", passed);

	rst = 0;
	#(2*`ClockPeriod)
	passTest(Sout,6'b110000, "SAA Initial", passed);

	DesiredLoad = `LBB;
	#(2*`ClockPeriod)
	passTest(Sout,6'b100000, "SAA to S1", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b101000, "S1 to S2", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b001000, "S2 to S5", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b001100, "S5 to SBB", passed);
	#(10*`ClockPeriod)


	DesiredLoad = `LCC;
	#(2*`ClockPeriod)
	passTest(Sout,6'b001000, "SBB to S5", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b001010, "S5 to S6", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000010, "S6 to S10", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000011, "S10 to SCC", passed);

	DesiredLoad = `LAA;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000010, "SCC to S10", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b100010, "S10 to S9", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b100000, "S9 to S1", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b110000, "S1 to SAA", passed);

	rst = 1;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000000, "Reset to No Output", passed);
	DesiredLoad = `LBB;
	rst = 0;
	#(2*`ClockPeriod)
	passTest(Sout,6'b001100, "Reset to SBB", passed);

	DesiredLoad = `LAA;
	#(2*`ClockPeriod)
	passTest(Sout,6'b001000, "SBB to S5", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b101000, "S5 to S2", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b100000, "S2 to S1", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b110000, "S1 to SAA", passed);
	
	DesiredLoad = `LCC;
	#(2*`ClockPeriod)
	passTest(Sout,6'b100000, "SAA to S1", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b100010, "S1 to S9", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000010, "S9 to S10", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000011, "S10 to SCC", passed);

	DesiredLoad = `LBB;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000010, "SCC to S10", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b001010, "S10 to S6", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b001000, "S6 to S5", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b001100, "S5 to SBB", passed);


	CURRSIGN=0;
	rst = 1;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000000, "Reset to No Output", passed);
	DesiredLoad = `LCC;
	rst = 0;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000011, "Reset to SCC,negCurr", passed);

	DesiredLoad = `LAA;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000001, "SCC to S8", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b010001, "S8 to S12", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b010000, "S12 to S11", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b110000, "S12 to SAA", passed);

	DesiredLoad = `LBB;
	#(2*`ClockPeriod)
	passTest(Sout,6'b010000, "SAA to S11", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b010100, "S11 to S3", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000100, "S3 to S4", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b001100, "S4 to SBB", passed);

	DesiredLoad = `LCC;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000100, "SBB to S4", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000101, "S4 to S7", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000001, "S7 to S8", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000011, "S8 to SCC", passed);

	DesiredLoad = `LBB;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000001, "SCC to S8", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000101, "S8 to S7", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000100, "S7 to S4", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b001100, "S4 to SBB", passed);

	DesiredLoad = `LAA;
	#(2*`ClockPeriod)
	passTest(Sout,6'b000100, "SBB to S4", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b010100, "S4 to S3", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b010000, "S3 to S11", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b110000, "S11 to SAA", passed);

	DesiredLoad = `LCC;
	#(2*`ClockPeriod)
	passTest(Sout,6'b010000, "SAA to S11", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b010001, "S11 to S12", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000001, "S12 to S8", passed);
	#(2*`ClockPeriod)
	passTest(Sout,6'b000011, "S8 to SCC", passed);
	#(10*`ClockPeriod)







	allPassed(passed,55);
	$finish;
end

initial begin
	CLK = 1;
	CURRSIGN = 1;
end

always begin
	#`HalfClock CLK = ~CLK;
	#`HalfClock CLK = ~CLK;
end
endmodule
