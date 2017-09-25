module adder_tb ();

//stimulus
reg [3:0] A, B;
reg cin;
wire [3:0] sum;
wire co;

reg [3:0] sum_exp;
reg co_exp;


//instantiate DUT
adder iDUT(
	.Sum(sum), 
	.co (co), 
	.A  (A), 
	.B  (B), 
	.cin(cin));

always@(*)
	{co_exp, sum_exp} = A + B + cin;


initial begin
	A = 4'b0000;
	B = 4'b0000;
	cin = 1'b0;
	#5;
	$display("### Starting simulation ###");

	for(A = 0; A < 16; A=A+1)
	begin
		for(B = 0; B < 16; B=B+1)
		begin
			if(co == co_exp && sum == sum_exp)
				$display("Passed");
			else
			begin
				$display("Failed");
			end
		end
	end
end

endmodule