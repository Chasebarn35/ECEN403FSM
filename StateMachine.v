`timescale 1ns / 1ps
`define BAD 4'b0000 
`define S01 4'b0001 
`define S02 4'b0010 
`define S03 4'b0011
`define S04 4'b0100 
`define S05 4'b0101
`define S06 4'b0110
`define S07 4'b0111
`define S08 4'b1000
`define S09 4'b1001
`define S10 4'b1010
`define S11 4'b1011
`define S12 4'b1100
`define SAA 4'b1101
`define SBB 4'b1110
`define SCC 4'b1111
`define LAAP 3'b101
`define LAAN 3'b001
`define LBBP 3'b110
`define LBBN 3'b010
`define LCCP 3'b111
`define LCCN 3'b011
`define LAA 2'b01
`define LBB 2'b10
`define LCC 2'b11
`define NUL 2'b00


/*
This creates a finite state machine that controls the safe commutation
Each state machine has 3 unique Inputs
The first bit represents the source phase current sign
the next 2 bits represent the desired Load
The State machines share
1 clock input
1 reset input
1 start input
1 Short input
the state machines output
6 gate driver outputs
This ensures proper commutation, as seen in (Filho et al., 2012)

This gives 33 total I/O Pins
*/

       module FSM(
	       input clk,
	       input rst,
	       input start,
	       input [1:0] DesiredLoad,
	       input CurrentSign,
	       input Short,
	       output reg [5:0] Sout
       );

       reg [3:0] State, NextState;
       always @(posedge clk or posedge clk or posedge Short)
       begin
	       if(rst || Short)
		       State <=`BAD;
	       else
		       State <= NextState;
       end

       always @(posedge rst or posedge clk or posedge Short)
       begin
	       case(State)
		       `S01:
		       begin
			       Sout <= 6'b100000;
			       case(DesiredLoad)
				       `LAA: begin NextState = `SAA; end
				       `LBB: begin NextState = `S02; end
				       `LCC: begin NextState = `S09; end
			       endcase
		       end
		       `S02:	
		       begin
			       Sout <= 6'b101000;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S01; end
				       `LBB: begin NextState = `S05; end
				       `LCC: begin NextState = `S05; end //TODO
			       endcase
		       end
		       `S03:	
		       begin
			       Sout <= 6'b010100;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S11; end
				       `LBB: begin NextState = `S04; end
				       `LCC: begin NextState = `S04; end //TODO
			       endcase
		       end
		       `S04:	
		       begin
			       Sout <= 6'b000100;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S03; end
				       `LBB: begin NextState = `SBB; end
				       `LCC: begin NextState = `S07; end
			       endcase
		       end
		       `S05:	
		       begin
			       Sout <= 6'b001000;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S02; end
				       `LBB: begin NextState = `SBB; end
				       `LCC: begin NextState = `S06; end
			       endcase
		       end
		       `S06:	
		       begin
			       Sout <= 6'b001010;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S05; end //TODO
				       `LBB: begin NextState = `S05; end
				       `LCC: begin NextState = `S10; end
			       endcase
		       end
		       `S07:	
		       begin
			       Sout <= 6'b000101;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S04; end //TODO
				       `LBB: begin NextState = `S04; end
				       `LCC: begin NextState = `SCC; end
			       endcase
		       end
		       `S08:	
		       begin
			       Sout <= 6'b000001;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S12; end
				       `LBB: begin NextState = `S07; end
				       `LCC: begin NextState = `SCC; end
			       endcase
		       end
		       `S09:	
		       begin
			       Sout <= 6'b100010;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S01; end
				       `LBB: begin NextState = `S01; end //TODO
				       `LCC: begin NextState = `S10; end
			       endcase
		       end
		       `S10:	
		       begin
			       Sout <= 6'b000010;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S09; end
				       `LBB: begin NextState = `S06; end
				       `LCC: begin NextState = `SCC; end
			       endcase
		       end
		       `S11:	
		       begin
			       Sout <= 6'b010000;
			       case(DesiredLoad)
				       `LAA: begin NextState = `SAA; end
				       `LBB: begin NextState = `S03; end
				       `LCC: begin NextState = `S12; end
			       endcase
		       end
		       `S12:	
		       begin
			       Sout <= 6'b010001;
			       case(DesiredLoad)
				       `LAA: begin NextState = `S11; end
				       `LBB: begin NextState = `S11; end //TODO
				       `LCC: begin NextState = `S08; end
			       endcase
		       end
		       `SAA:	
		       begin
			       Sout <= 6'b110000;
			       case({CurrentSign,DesiredLoad})
				       `LAAP: begin NextState = `SAA; end
				       `LAAN: begin NextState = `SAA; end
				       `LBBP: begin NextState = `S01; end
				       `LBBN: begin NextState = `S11; end
				       `LCCP: begin NextState = `S01; end
				       `LCCN: begin NextState = `S11; end
			       endcase

		       end
		       `SBB:	
		       begin
			       Sout <= 6'b001100;
			       case({CurrentSign,DesiredLoad})
				       `LAAP: begin NextState = `S05; end
				       `LAAN: begin NextState = `S04; end
				       `LBBP: begin NextState = `SBB; end
				       `LBBN: begin NextState = `SBB; end
				       `LCCP: begin NextState = `S05; end
				       `LCCN: begin NextState = `S04; end
			       endcase
		       end
		       `SCC:	
		       begin
			       Sout <= 6'b000011;
			       case({CurrentSign,DesiredLoad})
				       `LAAP: begin NextState = `S10; end
				       `LAAN: begin NextState = `S08; end
				       `LBBP: begin NextState = `S10; end
				       `LBBN: begin NextState = `S08; end
				       `LCCP: begin NextState = `SCC; end
				       `LCCN: begin NextState = `SCC; end
			       endcase
		       end
		       `BAD:	
		       begin
			       Sout <= 6'b000000;
			       if(Short)
				       NextState = `BAD; 
			       else
				       case(DesiredLoad)
					       `LAA: begin NextState = `SAA; end
					       `LBB: begin NextState = `SBB; end
					       `LCC: begin NextState = `SCC; end
					       `NUL: begin NextState = `BAD; end
				       endcase
			       end
		       endcase
	       end

	       endmodule
