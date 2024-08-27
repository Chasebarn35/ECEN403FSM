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
	input wire [2:0] shorts, //Short pin from MCU
	output wire [2:0] CurrentSign, //TEMPORARY Current of each phase ABC
	input wire [5:0] DesiredLoad, //Desired load for each phase from MCU AABBCC
	output reg [17:0] Sout, //OUTPUT 
	output wire shorted  //OUTPUT to MCU
);

//ADC WIRING
wire locked;
wire PLLOut;
reg ValidCommand;//DONE
reg[5:0] C_CHANNEL;//0 -> 2 repeatedly
wire IGNORED;//command start and end
reg C_READY;
wire R_VALID;
wire[2:0] R_CHANNEL;
wire[11:0] TMPDATA;

	
	PLL	PLL_inst (
	.areset ( RST ),
	.inclk0 ( clk ),
	.c0 ( PLLOut ),
	.locked ( locked )
	);


ADC u0 (
		.clock_clk              (clk),              //          clock.clk
		.reset_sink_reset_n     (RST),     			//     reset_sink.reset_n
		.adc_pll_clock_clk      (PLLOut),      		//  adc_pll_clock.clk
		.adc_pll_locked_export  (locked),  			// adc_pll_locked.export
		.command_valid          (ValidCommand),     //        command.valid
		.command_channel        (C_CHANNEL),        //               .channel
		.command_startofpacket  (IGNORED),  		//               .startofpacket
		.command_endofpacket    (IGNORED),    		//               .endofpacket
		.command_ready          (C_READY),          //               .ready
		.response_valid         (R_VALID),          //       response.valid
		.response_channel       (R_CHANNEL),        //               .channel
		.response_data          (TMPDATA),          //               .data
		.response_startofpacket (IGNORED), 			//               .startofpacket
		.response_endofpacket   (IGNORED)    		//               .endofpacket
	);


reg _short;
reg _rst;
wire [17:0] _Sout; //output to be ANDed with Short output
assign shorted = _short; //TODO TEST CASES
assign CurrentSign = CURRSIGNS;
reg [2:0] CURRSIGNS;
reg [1:0] ADCState;

FSM PhaseA(
	clk,
	_rst,
	DesiredLoad[5:4],
	CURRSIGNS[2],
	_Sout[17:12]);

FSM PhaseB(
	clk,
	_rst,
	DesiredLoad[3:2],
	CURRSIGNS[1],
	_Sout[11:6]);

FSM PhaseC(
	clk,
	_rst,
	DesiredLoad[1:0],
	CURRSIGNS[0],
	_Sout[5:0]);

initial begin
	_short <= 0;
	_rst <= 0;
	Sout <= 18'b0;
	ValidCommand <= 1;
	end

always @(posedge clk) begin
	if(shorts) begin _short = 1; end
end

always @(posedge clk) begin
	_rst = !(!rst && start);
end

always @(posedge clk) begin
	Sout <= _short ? 18'b0 : _Sout;
	
end

//ADC SETUP TODO
always @(posedge clk) begin
	if(RST) begin
		ADCState <= 2'b00;
		CURRSIGNS <= 3'b000;
	end else begin
		case(ADCState)
			2'b00: begin 
				if(locked) begin ADCState <= 2'b01; end
			end
			2'b01: begin
			C_CHANNEL <= (C_CHANNEL + 1) % 3;	//modulo to be between 0 and 2 
				if(R_VALID) begin
					if(TMPDATA > 6'b100000) 
					begin	CURRSIGNS[R_CHANNEL] <= 1;	end
					else 
					begin CURRSIGNS[R_CHANNEL] <= 0; end
				end
		end
		endcase
	end
end



endmodule
