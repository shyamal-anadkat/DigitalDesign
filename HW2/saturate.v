module saturate (unsigned_err, 
	signed_err, signed_D_diff, 
	unsigned_err_sat, 
	signed_err_sat, 
	signed_D_diff_sat);

input [15:0] unsigned_err, signed_err;
input [9:0]  signed_D_diff;

output [9:0] unsigned_err_sat, signed_err_sat;
output [5:0] signed_D_diff_sat;

assign unsigned_err_sat = (unsigned_err[15:10] == 6'b000000) ? 
						   unsigned_err[9:0] :  10'b0111111111;

//check for negative

endmodule
