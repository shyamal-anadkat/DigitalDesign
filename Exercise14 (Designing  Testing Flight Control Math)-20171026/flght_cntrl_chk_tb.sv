module flght_cntrl_chk_tb ();

reg clk;
reg[9:0] i;
///////////////////////////////////|
reg [107:0] stim_mem [0:999];  
reg [107:0] stim;    
reg [43:0] response;
reg [43:0] expected_mem [0:999];
///////////////////////////////////|

//////////////////////////////////////
// Declare wires for outputs of DUT /
////////////////////////////////////
//wire [10:0] frnt_spd,bck_spd,lft_spd,rght_spd;
//wire [10:0] exp_frnt_spd, exp_bck_spd, exp_lft_spd, exp_rght_spd;

/*
There are 1000 vectors of stimulus and
response. Read each file into a memory using
$readmemh.

Loop through the 1000 vectors and apply the
stimulus vectors to the inputs as specified.
Then wait till #1 time unit after the rise of clk
and compare the DUT outputs to the response
vector (self check). Do all 1000 vectors match?
*/


//////////////////////
// Instantiate DUT //
////////////////////
  flght_cntrl iDUT(.clk(clk),
	.rst_n(stim[107]),
	.vld(stim[106]),
	.d_ptch(stim[104:89]),
	.d_roll(stim[88:73]),
	.d_yaw(stim[72:57]),
	.ptch(stim[56:41]),
	.roll(stim[40:25]),
	.yaw(stim[24:9]),
	.thrst(stim[8:0]),
	.inertial_cal(stim[105]),
	.frnt_spd(response[43:33]),
	.bck_spd(response[32:22]),
	.lft_spd(response[21:11]),
	.rght_spd(response[10:0]));


initial begin
$readmemh("flght_cntrl_stim.hex",stim_mem);
$readmemh("flght_cntrl_resp.hex",expected_mem);

clk = 0;

for(i = 0; i < 1000; i = i + 1) 
begin 
   
   stim = stim_mem[i];
   @(posedge clk); //so that we are #1 afte clk rise.
   #1;

	if(response == expected_mem[i]) begin
		$display("SUCCESS: i = %d , expected: %h and response: %h", 
			i, expected_mem[i] , response);
	end else begin 
		$display("ERR: i = %d , stim: %h , expected: %h and response: %h not same.", 
			i, stim, expected_mem[i] , response);
		//$stop();
	end
end


$display("***SUCCESS: TESTS PASSED***");
$stop();
end

always
  #5 clk = ~clk;

endmodule