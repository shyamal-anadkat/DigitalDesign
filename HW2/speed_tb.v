module speed_tb ();

//stimuli
reg [5:0]  ptch_D_diff;    //signed
reg [9:0]  ptch_err_sat;   //signed
reg [8:0]  thrst;		   //unsigned
wire[12:0] frnt_spd_calc;

speed iDUT(.ptch_D_diff  (ptch_D_diff),
		   .ptch_err_sat (ptch_err_sat),
		   .thrst        (thrst),
		   .frnt_spd_calc(frnt_spd_calc));


initial begin
$display("### Starting simulation ###");

ptch_D_diff = 6'b001001; //9
ptch_err_sat = 10'b0000001000; //8
thrst = 9'b000100001; //33
#5;
$display("ptch_dterm: %d", iDUT.ptch_dterm);
$display("ptch_pterm: %d", iDUT.ptch_pterm);
$display("frnt_spd_calc: %d", frnt_spd_calc);

$display("Expected: ", 13'h0200 + thrst - 
	$signed((5/8) * $signed(ptch_err_sat)) - $signed($signed(ptch_D_diff) * $signed(9)));

$stop();		//stop simulation
end 

endmodule