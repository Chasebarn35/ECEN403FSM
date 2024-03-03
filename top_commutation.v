//`timescale 1ns / 1ps



//Data is done BigEnding, [5:4] for Desired Load is A, so on so forth
//ABC
//AABBCC
//AAAAAABBBBBBCCCCCC

// input wire [4:0] SW, //Temporary Switches

module top_commutation(
	input wire clk, //internal clock
	input wire rst, //reset pin from MCU
	input wire start, //start pin from MCU, START IS ON THE SW
	input wire [2:0]shorts, //Shorts from each phase 
	input wire [2:0] CurrentSign, //Current of each phase ABC
	input wire [5:0] DesiredLoad, //Desired load for each phase from MCU AABBCC
	output wire [17:0] Sout, //OUTPUT 
	output wire short
);


wire [5:0] SoutA;
wire [5:0] SoutB;
wire [5:0] SoutC;
wire short;
wire start;
assign start = SW[4];//5th SWITCH
reg shortReg;
assign short = shortReg;
//assign short = shorts[0] | shorts[1] | shorts[2];
wire [17:0] Sout; //OUTPUT FINAL
reg [2:0] CurrentSign;
reg[18:0] currentTimerA;
reg[18:0] currentTimerB;
reg[18:0] currentTimerC;


FSM PhaseA(
	clk,
	rst,
	DesiredLoad[5:4],
	CurrentSign[2],
	Sout[17:12]);

FSM PhaseB(
	clk,
	rst,
	DesiredLoad[3:2],
	CurrentSign[1],
	Sout[11:6);

FSM PhaseC(
	clk,
	rst,
	DesiredLoad[1:0],
	CurrentSign[0],
	Sout[5:0]);

initial begin
	CurrentSign <= 3'b110;
	currentTimerA = 0;//Initial Phase is 0
	currentTimerB = 277778;//417 * 2/3
	currentTimerC = 138889;//417 * 1/3
	shortReg = 0;
end
//Assuming that this is running at 50MHz, I want to change the current sign every 120Hz.
//This 50M/120=416667, repeat for each
//This is temporary, just to simulate current signs
always @(posedge clk) begin
	if(currentTimerA >= 416667) begin
		CurrentSign[2] <= ~CurrentSign[2];
		currentTimerA = 0;
	end
	if(currentTimerB >= 416667) begin
		CurrentSign[1] <= ~CurrentSign[1];
		currentTimerB = 0;
	end
	if(currentTimerC >= 416667) begin
		CurrentSign[0] <= ~CurrentSign[0];
		currentTimerC = 0;
	end
	currentTimerA = currentTimerA + 19'b1;
	currentTimerB = currentTimerB + 19'b1;
	currentTimerC = currentTimerC + 19'b1;
end


always @(posedge clk) begin
	if(SW[3] || shortReg) begin
		shortReg <= 1; //TEMPORARY SHORT ACT
		SoutTemp <= 5'b1;
	end
	else begin
	casez(SW[2:0])
		3'b000: begin
			SoutTemp <= {SoutA[3:0],CurrentSign[2]};
		end
		3'b001: begin
			SoutTemp <= {SoutB[3:0],CurrentSign[1]};
		end
		3'b010: begin
			SoutTemp <= {SoutC[3:0],CurrentSign[0]};
		end
		3'b011: begin
			SoutTemp <= {SoutA[5:4],DesiredLoad[5:4],CurrentSign[2]};
		end
		3'b100: begin
			SoutTemp <= {SoutB[5:4],DesiredLoad[3:2],CurrentSign[1]};
		end
		3'b101: begin
			SoutTemp <= {SoutC[5:4],DesiredLoad[1:0],CurrentSign[0]};
		end
		default: begin
			SoutTemp <= 5'b0;
		end
	endcase
	end
end



//assign Sout = short ? 18'b0 : {SoutA,SoutB,SoutC}; TODO

endmodule
