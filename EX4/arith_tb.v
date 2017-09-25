/* Shyamal H Anadkat -- Ex04 */
module arith_tb();

reg [7:0] stm_a, stm_b; //stimulus for a and b 
reg stm_sub; 			//stimulus for SUB

wire [7:0] sum_mon;		//monitor sum
wire ov_mon;	        //monitor ov

arith iDUT(.A(stm_a),
	.B(stm_b),
	.SUB(stm_sub),
	.SUM(sum_mon),
	.OV(ov_mon));

initial begin

//*****TO TEST*****//
//SUM = A+B if SUB is low
//SUM = A-B if SUB is high
//OV signal if result too +ve/-ve for 8-bit signed

// sanity tests for SUB low 
stm_a = 8'hA5;
stm_b = 8'h5A;
stm_sub = 0;
#5;			//wait 5 time units 
// self-checking A+B with expected result
if(sum_mon != (stm_a+stm_b) || ov_mon) begin
	$display("ERROR: incorrect sum calculation (SUB low)");
end 

stm_a = 8'hA1;
stm_b = 8'hD;
stm_sub = 0;
#5;			//wait 5 time units 
// self-checking A+B with expected result
if(sum_mon != (stm_a+stm_b) || ov_mon) begin
	$display("ERROR: incorrect sum calculation (SUB low)");
end 


// sanity tests for SUB high
stm_a = 8'hF;
stm_b = 8'hA;
stm_sub = 1;
#5;
// self-checking for A-B with expected result
if(sum_mon != (stm_a-stm_b) || ov_mon) begin
	$display("ERROR: incorrect subtracion calculation (SUB high)");
end 
stm_a = 8'h74;
stm_b = 8'hA;
stm_sub = 1;
#5;
if(sum_mon != (stm_a-stm_b) || ov_mon) begin
	$display("ERROR: incorrect subtracion calculation (SUB high)");
end 


// self-checking test for (+ve) overflow 
stm_a = 8'h7F;
stm_b = 8'h7F;
stm_sub = 0;
#5;
if(sum_mon != (stm_a+stm_b) || ~ov_mon) begin
	$display("ERROR: did not detect positive overflow.");
end 

// self-checking test for (-ve) overflow 
stm_a = 8'hFF;
stm_b = 8'hFF;
stm_sub = 1;
#5;
if(sum_mon != (stm_a-stm_b) || ~ov_mon) begin
	$display("ERROR: did not detect negative overflow.");
end

$display("SUCCESS: All tests passed.");
$stop();		//stop simulation
end 

endmodule