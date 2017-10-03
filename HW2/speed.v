module speed (ptch_D_diff,ptch_err_sat,thrst,frnt_spd_calc);

input signed [5:0] ptch_D_diff;     
input signed [9:0] ptch_err_sat;	
input [8:0] thrst;		            
output signed [12:0] frnt_spd_calc;

localparam MIN_RUN_SPEED = 13'h0200;

wire signed [9:0] ptch_dterm, ptch_pterm;
wire signed [9:0] w1, w2; 

//ptch_dterm = ptch_D_diff * 9
assign ptch_dterm = ptch_D_diff * $signed(9);


//ptch_pterm = (5/8) * ptch_err_sat OR [1/2(p) + 1/8(p)]
assign w1 = ptch_err_sat >>> 1;
assign w2 = ptch_err_sat >>> 3; 
assign ptch_pterm = w1 + w2; 

//frnt_spd_calc = MIN_RUN_SPEED + thrst – ptch_pterm – ptch_dterm
//also sign extending pterm and dterm to 13 bits 
assign frnt_spd_calc = MIN_RUN_SPEED + thrst 
- {{3{ptch_pterm[9]}}, ptch_pterm[9:0]} - {{3{ptch_dterm[9]}}, ptch_dterm[9:0]};

endmodule