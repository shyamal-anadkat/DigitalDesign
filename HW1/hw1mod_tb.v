module hw1mod_tb();

reg clk;
reg sig_in;

wire q;

hw1mod iDUT(.q(q), .clk(clk), .d(sig_in));

always begin 
clk = 0;
sig_in = 0;

repeat(2) @(negedge clk);
sig_in = 1; 
repeat(1) @(negedge clk);
#3;

if(!q) begin
	$display("ERROR);
end 

repeat(2) @(posedge clk);
sig_in = 0;
repeat(2) @(negedge clk);
sig_in = 1; 
repeat(2) @(posedge clk);
sig_in = 0;

repeat(2) @(negedge clk);
sig_in = 1; 
repeat(2) @(posedge clk);
sig_in = 0;

repeat(1) @(negedge clk);
sig_in = 0; 
repeat(1) @(posedge clk);
sig_in = 1;

$stop();
end 

always
  #10 clk <= ~clk;		// toggle clock every 10 time units

endmodule
