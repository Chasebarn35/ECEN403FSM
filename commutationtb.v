//`timescale 1ns / 1ps


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
reg RST;
reg START;
reg [2:0] SHORTS;
reg [2:0] CURRSIGNS;
reg [5:0] D_LOAD;

// UUT
reg [7:0] passed;
reg [15:0] watchdog;

// Outputs
reg [17:0] SOUT;
reg SHORT;

top_commutation uut (
	.clk(CLK),
	.rst(RST),
	.start(START),
	.shorts(SHORTS),
	.CurrentSign(CURRSIGNS),
	.DesiredLoad(D_LOAD),
	.Sout(SOUT),
	.short(SHORT)
);

initial begin
	rst = 1;
	passed = 0;
	DesiredLoad = {`NUL,`NUL,`NUL};
	start = 0;
	shorts = 3'b000;

	watchdog = 0;
