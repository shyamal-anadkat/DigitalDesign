/* Test Module for saturate.v
*  Shyamal Anadkat ECE551 HW2 
*/
module saturate_tb ();

//stimulus 
reg [16:0] unsigned_err, signed_err;
reg [9:0]  signed_D_diff;

//pass/fail signal
reg pass; 

//check for outputs
wire [9:0] unsigned_err_sat, signed_err_sat;
wire [5:0] signed_D_diff_sat;


saturate iDUT (.unsigned_err(unsigned_err), 
	.signed_err(signed_err), 
	.signed_D_diff(signed_D_diff), 
	.unsigned_err_sat(unsigned_err_sat), 
	.signed_err_sat(signed_err_sat), 
	.signed_D_diff_sat(signed_D_diff_sat));

initial begin
	$display("### Starting simulation ###");
	pass = 1; 

unsigned_err = 17'b00010101010101010; //should saturate
signed_D_diff = 10'b1111111111;       //should not saturate
signed_err = 17'b00000000000011111;	  //should not saturate

#5;			//wait 5 time units 
if(unsigned_err_sat != 10'b0111111111  || signed_err_sat!= 10'b0000011111 || signed_D_diff_sat != 6'b111111) begin 
	$display("### FAILED 1st scenario ###");
	pass = 0;
end

unsigned_err = 17'b01110101010101010;  //shld saturate
signed_D_diff = 10'b0000000111;        //shld not saturate
signed_err = 17'b11000000000011111;    //shld saturate

#5;			//wait 5 time units 
if(unsigned_err_sat != 10'b0111111111  || signed_err_sat!= 10'b1000000000 || signed_D_diff_sat != 6'b000111) begin 
	$display("### FAILED 2nd scenario ###");
	pass = 0;
end

unsigned_err = 17'b00000000110101010;  //shld not saturate
signed_D_diff = 10'b1010000111;        //shld saturate
signed_err = 17'b00000010000011111;    //shld saturate

#5;			//wait 5 time units 
if(unsigned_err_sat != 10'b0110101010  || signed_err_sat!= 10'b0111111111 || signed_D_diff_sat != 6'b100000) begin 
	$display("### FAILED 3rd scenario ###");
	pass = 0;
end

if(pass) begin
	$display("### SUCCESS: All tests passed. ###");
end
$stop();		//stop simulation
end 


endmodule