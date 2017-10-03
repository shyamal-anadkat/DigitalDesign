module saturate (unsigned_err, 
	signed_err, signed_D_diff, 
	unsigned_err_sat, 
	signed_err_sat, 
	signed_D_diff_sat);

input [16:0] unsigned_err, signed_err;
input [9:0]  signed_D_diff;

output [9:0] unsigned_err_sat, signed_err_sat;
output [5:0] signed_D_diff_sat;


localparam MAX_10 = 10'b0111111111;
localparam MIN_10 = 10'b1000000000;
localparam MAX_6 = 6'b011111;
localparam MIN_6 = 6'b100000;

// unsigned-err-sat
assign unsigned_err_sat = (|unsigned_err[16:10]) ?   //are any bits set in 16:10? 
MAX_10 : unsigned_err[9:0];					         //if so highest +ve

//signed-err-sat 
assign signed_err_sat = (~signed_err[16]) ?           //positive ? 
(!(|signed_err[16:10]) ? signed_err[9:0] : MAX_10) :  //is any bit in 16:10 unset ? 
((&signed_err[16:10]) ? signed_err[9:0]: MIN_10);

//signed-D-diff
assign signed_D_diff_sat = ~(signed_D_diff[9]) ?        //positive ?
(!(|signed_D_diff[9:6]) ? signed_D_diff[5:0] : MAX_6) : //is any bit in 16:10 unset ?
((&signed_D_diff[9:6]) ? signed_D_diff[5:0]: MIN_6);

endmodule
