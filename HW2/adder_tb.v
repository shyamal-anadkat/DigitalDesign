/*exhaustive test-bench for adder mod*/
module adder_tb ();

//stimulus
reg [4:0] A, B;
reg [1:0] cin;
wire [3:0] sum;
wire co;

//fail sig :ERR if asserted
reg fail; 

//instantiate DUT
adder iDUT(
	.Sum(sum), 
	.co (co), 
	.A  (A[3:0]), 
	.B  (B[3:0]), 
	.cin(cin[0]));

initial begin
	//init stimuli
	A    = 4'b0000;
	B    = 4'b0000;
	cin  = 1'b0;
	fail = 0; 
	#5; //wait 5 time units
	$display("### Starting simulation/testing ###");

	// for cin 0, 1 test all values of A and B. 
	// one bit extra to avoid infinite loop
	for(cin = 0; cin < 2 ; cin = cin+ 1) begin
		for(A = 0; A < 16; A=A+1)
		begin
			for(B = 0; B < 16; B=B+1)
			begin 
				#5;
				if((A+B+cin) == {co, sum})
					$display("%d + %d PASSED", A, B);
				else
				begin
					fail = 1; 
					$display("%d + %d FAILED", A, B);
					$stop();
				end
			end
		end
	end
	if(!fail) begin
		$display("##### SUCCESS: Test Passed #####");
		$stop();
	end
end
endmodule