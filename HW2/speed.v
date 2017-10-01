module speed (ptch_D_diff,ptch_err_sat,thrst,frnt_spd_calc);

input [5:0] ptch_D_diff;    //signed
input [9:0] ptch_err_sat;	//signed
input [8:0] thrst;		    //unsigned
output [12:0] frnt_spd_calc;

localparam MIN_RUN_SPEED = 13'h0200;

wire [9:0] ptch_dterm, ptch_pterm;
wire [5:0] w1, w2; 


//ptch_dterm = ptch_D_diff * 9
assign ptch_dterm = ptch_D_diff * $signed(9);


//ptch_pterm = (5/8) * ptch_err_sat
assign w1 = ptch_err_sat >>> 1;
assign w2 = ptch_err_sat >>> 4; 
assign ptch_pterm = $signed(w1) + $signed(w2); 

//frnt_spd_calc = MIN_RUN_SPEED + thrst – ptch_pterm – ptch_dterm
assign frnt_spd_calc = $signed(MIN_RUN_SPEED) + $signed(thrst) - $signed(ptch_pterm) - $signed(ptch_dterm);

endmodule