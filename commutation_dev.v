`ifndef LAA
`define LAA 2'b01
`define LBB 2'b10
`define LCC 2'b11  
`define NUL 2'b00  
`endif

//Data is done BigEnding, [5:4] for Desired Load is A, so on so forth
//ABC
//AABBCC
//AAAAAABBBBBBCCCCCC

module commutation_dev(
	input wire clk,
	//input wire rst,
	input wire [4:0] SW,
	output reg [4:0] LED
);

//Inputs
//clk
reg rst;
wire START;
reg SHORT;
reg [2:0] CURRSIGNS;
reg [5:0] D_LOAD;

assign START = SW[4];//5th SWITCH


//Input Simulation
reg[18:0] currentTimerA;
reg[18:0] currentTimerB;
reg[18:0] currentTimerC;

//Outputs
wire [5:0] SoutA;
wire [5:0] SoutB;
wire [5:0] SoutC;

top_commutation uut (
	.clk(clk),
	.rst(rst),
	.start(START),
	.short(SHORT),
	.CurrentSign(CURRSIGNS),
	.DesiredLoad(D_LOAD),
	.Sout({SoutA,SoutB,SoutC})
);

initial begin
	rst = 1;
	LED <= 5'b0;
	D_LOAD = {`NUL,`NUL,`NUL};
	SHORT = 0;
	CURRSIGNS <= 3'b110;
	currentTimerA = 0;//Initial Phase is 0
	currentTimerB = 277778;//416667 * 2/3
	currentTimerC = 138889;//416667 * 1/3
end
//Assuming that this is running at 50MHz, I want to change the current sign every 120Hz.
//This 50M/120=416667, repeat for each
//This is temporary, just to simulate current signs
always @(posedge clk) begin
	if(currentTimerA >= 416667) begin
		CURRSIGNS[2] <= ~CURRSIGNS[2];
		currentTimerA = 0;
	end
	if(currentTimerB >= 416667) begin
		CURRSIGNS[1] <= ~CURRSIGNS[1];
		currentTimerB = 0;
	end
	if(currentTimerC >= 416667) begin
		CURRSIGNS[0] <= ~CURRSIGNS[0];
		currentTimerC = 0;
	end
	currentTimerA = currentTimerA + 19'b1;
	currentTimerB = currentTimerB + 19'b1;
	currentTimerC = currentTimerC + 19'b1;
end


always @(posedge clk)
begin
	if(SW[3]) begin
		SHORT = 1; //TEMPORARY SHORT ACT, ARBITRARY SHORTAGE
	end
	if(SW[4]) begin
		rst = 0;
	end
end




always @(posedge clk)
begin
	case(SW[2:0])
		3'b000: //Display BBCCc of A
		begin 
		LED <= {SoutA[3:0],CURRSIGNS[2]};
	end
	3'b001: //Display BBCCc of B
	begin 
	LED <= {SoutB[3:0],CURRSIGNS[1]};
end
3'b010: //Dispaly BBCCc of C
begin 
LED <= {SoutC[3:0],CURRSIGNS[0]};
end
3'b011: 
begin //Display AADLc of A
LED <= {SoutA[5:4],D_LOAD[5:4],CURRSIGNS[2]};
		end
		3'b100: 
		begin //Display AADLc of B
		LED <= {SoutB[5:4],D_LOAD[3:2],CURRSIGNS[1]};
	end
	3'b101: 
	begin //Display AADLc of C
	LED <= {SoutC[5:4],D_LOAD[1:0],CURRSIGNS[0]};
end
default: 
begin
	LED <= 5'b1;
end
	endcase
end




endmodule
