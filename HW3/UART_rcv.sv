module UART_rcv (clk, rst_n, RX, clr_rdy, rdy, cmd);

//////////////////////////////////////////////////////////////////////
input logic clk, rst_n; //100MHz system clock & active low reset
input logic RX;         //Serial data carrying command from host computer

//Asserted to knock down the rdy signal. 
input logic clr_rdy;

//Asserted when a byte has been received. Falls
//when new start bit comes, or when clr_rdy knocks
//it down.
output logic rdy;
output logic [7:0] cmd;  //Byte received (serves as command to LA)
//////////////////////////////////////////////////////////////////////

logic RX_ff1, RX_ff2;


//double RX flop (metastability)
always_ff @(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		 RX_ff1 <= 1'b0;
		 RX_ff2 <= 1'b0;
	end else begin
		 RX_ff1 <= RX;
		 RX_ff2 <= RX_ff1;
	end
end






endmodule