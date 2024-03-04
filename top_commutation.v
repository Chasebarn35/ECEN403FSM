//`timescale 1ns / 1ps



//Data is done BigEnding, [5:4] for Desired Load is A, so on so forth
//ABC
//AABBCC
//AAAAAABBBBBBCCCCCC

//CLK is defaulted to 50k Hz input
//rst is 1 for reset, 0 for function
//start starts when it goes to 1, off when 0
//rst st | Out
//0   0  | 0
//0   1  | 1
//1   0  | 0
//1   1  | 0


//When any short is signalled, I want it to be unable to be reset, as I want
//whatver short has appeared to be investigated, and the device to be atleast
//power cycled

module top_commutation(
	input wire clk, //internal clock
	input wire rst, //reset pin from MCU
	input wire start, //start pin from MCU, START IS ON THE SW
	input wire [2:0]shorts, //Shorts from each phase 
	input wire [2:0] CurrentSign, //Current of each phase ABC
	input wire [5:0] DesiredLoad, //Desired load for each phase from MCU AABBCC
	output reg [17:0] Sout, //OUTPUT 
	output wire short
);


reg _short;
assign short = _short;
reg _rst;
wire [17:0] _Sout; //output to be ANDed with Short output


FSM PhaseA(
	clk,
	_rst,
	DesiredLoad[5:4],
	CurrentSign[2],
	_Sout[17:12]);

FSM PhaseB(
	clk,
	_rst,
	DesiredLoad[3:2],
	CurrentSign[1],
	_Sout[11:6]);

FSM PhaseC(
	clk,
	_rst,
	DesiredLoad[1:0],
	CurrentSign[0],
	_Sout[5:0]);

initial begin
	_short <= 0;
	_rst <= 0;
	Sout <= 18'b0;
end

always @(posedge clk) begin
	if(shorts) begin _short = 1; end
end

always @(posedge clk) begin
	_rst = !(!rst && start);
end

always @(posedge clk) begin
	Sout <= short ? 18'b0 : _Sout;
end




endmodule
