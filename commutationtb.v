//`timescale 1ns / 1ps


`define TESTCOUNT 32 
`define QuartClock 25
`define HalfClock 50 
`define ClockPeriod `HalfClock * 2 
`define SAA 6'b110000
`define SBB 6'b001100
`define SCC 6'b000011
`define LAA 2'b01 
`define LBB 2'b10 
`define LCC 2'b11 
`define NUL 2'b00 


module commutationTB; 

initial 
begin         
$dumpfile("Comm.vcd");         
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
reg PLL;
reg CLK;
reg RST;
reg START;
reg [2:0] SHORTS;
reg [2:0] CURRSIGNS;
reg [5:0] D_LOAD;

// UUT
reg [7:0] passed;

// Outputs
wire [17:0] SOUT;
wire SHORT;

top_commutation uut (
	.clk(PLL),
	.rst(RST),
	.start(START),
	.shorts(SHORTS),
	.CurrentSign(CURRSIGNS),
	.DesiredLoad(D_LOAD),
	.Sout(SOUT),
	.short(SHORT)
);

initial begin
	RST = 1;
	passed = 0;
	D_LOAD = {`NUL,`NUL,`NUL};
	START = 0;
	SHORTS = 3'b000;



	#(1 * `ClockPeriod);
	RST = 0;

	//TEST 1, INITIAL START FOR NO OUTPUT
	passTest(SOUT,18'b0, "Initial start", passed);
	D_LOAD = {`LAA,`LBB,`LCC};

	#(4*`ClockPeriod)
	passTest(SOUT,18'b0, "Check Before Start", passed);

	START = 1;
	#(2*`ClockPeriod)
	passTest(SOUT,{`SAA,`SBB,`SCC}, "Reset to SAABBCC", passed);

	D_LOAD = {`LBB,`LCC,`LAA};
	#(5*`ClockPeriod)
	passTest(SOUT,{`SBB,`SCC,`SAA}, "SAABBCC to SBBCCAA", passed);

	D_LOAD = {`LCC,`LAA,`LBB};
	#(5*`ClockPeriod)
	passTest(SOUT,{`SCC,`SAA,`SBB}, "SBBCCAA to SCCAABB", passed);

	CURRSIGNS = 3'b110;

	D_LOAD = {`LBB,`LCC,`LAA};
	#(5*`ClockPeriod)
	passTest(SOUT,{`SBB,`SCC,`SAA}, "SCCAABB to SBBCCAA Curr", passed);

	RST = 1;
	#(2 * `ClockPeriod);
	passTest(SOUT,18'b0, "Reset", passed);

	RST = 0;
	D_LOAD = {`LAA,`LAA,`LBB};
	#(5*`ClockPeriod)
	passTest(SOUT,{`SAA,`SAA,`SBB}, "Reset to SAAAABB", passed);

	SHORTS = 3'b110;
	#(2*`ClockPeriod)
	passTest(SOUT,18'b0, "Shorted", passed);

	SHORTS = 3'b0;
	#(2*`ClockPeriod)
	passTest(SOUT,18'b0, "Shorted After Pulse Off", passed);


	allPassed(passed,10);
	$finish;
end


initial begin
	CLK = 1;
	PLL = 1;
	CURRSIGNS = 3'b0;
end

always begin
	#`QuartClock PLL = ~PLL;
	#`QuartClock PLL = ~PLL;
end

always begin
	#`HalfClock CLK = ~CLK;
	#`HalfClock CLK = ~CLK;
end
endmodule
