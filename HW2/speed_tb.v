/* Self-checking testbench for speed.v module */
module speed_tb ();

//stimuli
reg [5:0]  ptch_D_diff;    //signed
reg [9:0]  ptch_err_sat;   //signed
reg [8:0]  thrst;		   //unsigned
wire[12:0] frnt_spd_calc;
reg [12:0] expected;
reg fail;
reg debug;

speed iDUT(.ptch_D_diff  (ptch_D_diff),
	.ptch_err_sat (ptch_err_sat),
	.thrst        (thrst),
	.frnt_spd_calc(frnt_spd_calc));

initial begin
	fail = 0;  //pass/fail signal
	debug = 0; //switch to 1 to print signals and debug
	$display("### Starting simulation ###");

//########## SCENARIO 1 ###########//
ptch_D_diff = 6'h0F; 
ptch_err_sat = 10'h0E2; 
thrst = 9'h0A0; 
expected = 13'h0200 + thrst - 
$signed(((5 * $signed(ptch_err_sat))/8)) - $signed($signed(ptch_D_diff) * $signed(9));
#5;

if(debug) begin
	$display("ptch_dterm: %d", iDUT.ptch_dterm);
	$display("ptch_pterm: %d", iDUT.ptch_pterm);
	$display("frnt_spd_calc: %h", frnt_spd_calc);
end

if(frnt_spd_calc != expected) begin
	$display("FAILED. Expected: %h", expected);
	fail = 1; 
end

//########## SCENARIO 2 (+ve, +ve) ###########//

ptch_D_diff = 6'b001001; //9
ptch_err_sat = 10'b0000001000; //8
thrst = 9'b000100001; //33
expected = 13'h0200 + thrst - 
$signed(((5 * $signed(ptch_err_sat))/8)) - $signed($signed(ptch_D_diff) * $signed(9));
#5;

if(debug) begin
	$display("ptch_dterm: %d", iDUT.ptch_dterm);
	$display("ptch_pterm: %d", iDUT.ptch_pterm);
	$display("frnt_spd_calc: %h", frnt_spd_calc);
end

if(frnt_spd_calc != expected) begin
	$display("FAILED. Expected: %h", expected);
	fail = 1; 
end

//########## SCENARIO 3 <-ve, -ve> ###########//

ptch_D_diff = 6'b101001; //9
ptch_err_sat = 10'b1100001000; //8
thrst = 9'b000100001; //33
expected = 13'h0200 + thrst - 
$signed(((5 * $signed(ptch_err_sat))/8)) - $signed($signed(ptch_D_diff) * $signed(9));
#5;

if(debug) begin
	$display("ptch_dterm: %d", iDUT.ptch_dterm);
	$display("ptch_pterm: %d", iDUT.ptch_pterm);
	$display("frnt_spd_calc: %h", frnt_spd_calc);
end

if(frnt_spd_calc != expected) begin
	$display("FAILED. Expected: %h", expected);
	fail = 1; 
end


//########## SCENARIO 4 <+ve, -ve> ###########//

ptch_D_diff = 6'b101001; //9
ptch_err_sat = 10'b0100001000; //8
thrst = 9'b001100001; //33
expected = 13'h0200 + thrst - 
$signed(((5 * $signed(ptch_err_sat))/8)) - $signed($signed(ptch_D_diff) * $signed(9));
#5;

if(debug) begin
	$display("ptch_dterm: %d", iDUT.ptch_dterm);
	$display("ptch_pterm: %d", iDUT.ptch_pterm);
	$display("frnt_spd_calc: %h", frnt_spd_calc);
end

if(frnt_spd_calc != expected) begin
	$display("FAILED. Expected: %h", expected);
	fail = 1; 
end

//########## SCENARIO 5 <-ve, +ve> ###########//

ptch_D_diff = 6'b010001; 
ptch_err_sat = 10'b1000000000; 
thrst = 9'b001100001; 
expected = 13'h0200 + thrst - 
$signed(((5 * $signed(ptch_err_sat))/8)) - $signed($signed(ptch_D_diff) * $signed(9));
#5;

if(debug) begin
	$display("ptch_dterm: %d", iDUT.ptch_dterm);
	$display("ptch_pterm: %d", iDUT.ptch_pterm);
	$display("frnt_spd_calc: %h", frnt_spd_calc);
end

if(frnt_spd_calc != expected) begin
	$display("FAILED TEST-5. Expected: %h", expected);
	fail = 1; 
end

//###### END OF TEST BENCH ######//
if(!fail) begin
	$display("### SUCCESS ! TESTS PASSED ###");
end

$stop();		//stop simulation
end 

endmodule