`ifndef LAA
`define LAA 2'b01
`define LBB 2'b10
`define LCC 2'b11  
`define NUL 2'b00  
`endif

//Data is done BigEndian, [5:4] for Desired Load is A, so on so forth
//ABC
//AABBCC
//AAAAAABBBBBBCCCCCC

module commutation_dev(
	input wire clk,
	input wire [5:0] D_LOAD,
	//input wire rst,
	input wire [4:0] SW,
	input wire SHORT,
	output reg [4:0] LED,
	output wire [17:0] SOUT,
	output reg [2:0] VOLTOUT
);

//Inputs
wire RST;
wire START;
wire [2:0] CURRSIGNS;
assign START = SW[3];
//assign SHORT = SW[3];//4th SWITCH
assign RST   = SW[2];//3rd Switch

//Input Simulation output to MCU
reg[18:0] VoltTimerA;
reg[18:0] VoltTimerB;
reg[18:0] VoltTimerC;

//Intermediate Outputs
//wire [5:0] SoutA;
//wire [5:0] SoutB;
//wire [5:0] SoutC;
wire SHORTED;


	
	
top_commutation uut (
	.clk(clk),
	.rst(RST),
	.start(START),
	.shorts({2'b0,SHORT}),
	.CurrentSign(CURRSIGNS),
	.DesiredLoad(D_LOAD),
	.Sout(SOUT),
	.shorted(SHORTED)
);

initial begin
	LED <= 5'b0;
	VOLTOUT <= 3'b110;
	VoltTimerA = 0;//Initial Phase is 0
	VoltTimerB = 277778;//416667 * 2/3
	VoltTimerC = 138889;//416667 * 1/3
end
//Assuming that this is running at 50MHz, I want to change the current sign every 120Hz.
//This 50M/120=416667, repeat for each
//This is temporary, just to simulate current signs
always @(posedge clk) begin
	if(VoltTimerA >= 416667) begin
		VOLTOUT[2] <= ~VOLTOUT[2];
		VoltTimerA = 0;
	end
	if(VoltTimerB >= 416667) begin
		VOLTOUT[1] <= ~VOLTOUT[1];
		VoltTimerB = 0;
	end
	if(VoltTimerC >= 416667) begin
		VOLTOUT[0] <= ~VOLTOUT[0];
		VoltTimerC = 0;
	end
	VoltTimerA = VoltTimerA + 19'b1;
	VoltTimerB = VoltTimerB + 19'b1;
	VoltTimerC = VoltTimerC + 19'b1;
end


always @(posedge clk)
begin
	LED <= {CURRSIGNS,SHORTED,1'b0};
end




endmodule
