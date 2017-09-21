//** Shyamal H Anadkat **//
module hw1mod_tb();

reg clk;
reg d;

wire q;

// instance of tristate DUT
hw1mod iDUT(.q(q), .clk(clk), .d(d));

always begin
clk = 0;
d = 0;
repeat(2) @(negedge clk);

d = 1;
repeat(2) @(negedge clk);
#3;

// check on posedge after some delay
if(!q) begin
	$display("ERROR");
end 

d = 0;
repeat(2) @(posedge clk);
#3;

// check on pos edge after some delay
if(q) begin
	$display("ERROR");
end

d = 1;
repeat(2) @(negedge clk);
d = 0;
repeat(2) @(posedge clk);
d = 1;
repeat(2) @(posedge clk);
d = 0;

$display("TEST PASSED");
$stop();
end

always
#10 clk <=~clk; // toggle clock every 10 time units

endmodule