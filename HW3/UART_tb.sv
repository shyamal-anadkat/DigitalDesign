/*Self-checking testbench for UART TX + RX */
module UART_tb();

// Stimuli 
logic clk, rst_n, trmt, RX, clr_rdy, rdy;
logic [7:0] tx_data, cmd;
logic tx_done, fail; 


//instantiate UART_TX DUT
UART_tx  iDUT_TX(.clk(clk), 
	.rst_n(rst_n), 
	.trmt(trmt), 
	.tx_data(tx_data), 
	.TX(RX), 
	.tx_done(tx_done));

//instantiate UART_RX DUT
UART_rcv iDUT_RX(
	.clk(clk), 
	.rst_n(rst_n), 
	.RX(RX), 
	.clr_rdy(clr_rdy), 
	.rdy(rdy), 
	.cmd(cmd));


always
#10 clk = ~clk;

initial
begin
	rst_n = 0;
	clk = 0; 
	trmt = 0; 
	fail = 0;
	clr_rdy = 0;
	@(negedge(clk));
	rst_n = 1;

	#4;
	rst_n = 1; 

	$display("Starting self-checking tests >>>");

// exhausively + self-checking test all values of tx_data
for (tx_data = 0; tx_data < 8'hFF; tx_data = tx_data + 1)
begin 

	trmt = 1; 
	repeat(10)@(negedge clk);
	trmt = 0; 
	repeat(2604 * 10) @(negedge(clk));
	if(rdy) begin
		//assert fail if rcv doesn't get tx_data
		if(cmd == tx_data) begin  
			//$display("Iteration: %d PASSED!", tx_data);
		end else begin
			fail = 1;
			$display("Iteration: %d FAILED! >>>", tx_data);
			$stop;
		end
		//if not rdy then assert fail 
	end else begin
		fail = 1;
		$display("FAILED! >>>");
		$stop;
	end
end

//todo: test for clr_rdy

if(!fail) begin
	$display("TESTS PASSED >>>");
end
$stop;
end


endmodule
