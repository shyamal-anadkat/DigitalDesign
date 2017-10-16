module UART_tx_tb ();

	logic clk, rst_n, trmt;
	logic [7:0] tx_data;
	logic TX, tx_done; 


//instantiate UART_TX DUT
UART_tx  iDUT(.clk(clk), 
	.rst_n(rst_n), 
	.trmt(trmt), 
	.tx_data(tx_data), 
	.TX(TX), 
	.tx_done(tx_done));


initial begin
	rst_n = 0;
	clk = 0;
	trmt = 0;
	tx_data = 0;
	#5;
	rst_n = 1;
	tx_data = 8'b10101010;
	#5;
	trmt = 1;
	#5;
	trmt = 0; 
	#(10*7000)
	rst_n = 1; 
	tx_data = 8'b01111011;
	#5;
	trmt = 1;
	#5;
	trmt = 0; 
	#(10*7000)

	$stop;
end

always #1 clk = ~clk;

endmodule