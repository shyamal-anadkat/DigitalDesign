module flght_cntrl(clk,rst_n,vld,inertial_cal,d_ptch,d_roll,d_yaw,ptch,
	roll,yaw,thrst,frnt_spd,bck_spd,lft_spd,rght_spd);

parameter D_QUEUE_DEPTH = 14;		// delay for derivative term

input clk,rst_n;
input vld;									// tells when a new valid inertial reading ready
											// only update D_QUEUE on vld readings
input inertial_cal;							// need to run motors at CAL_SPEED during inertial calibration
input signed [15:0] d_ptch,d_roll,d_yaw;	// desired pitch roll and yaw (from cmd_cfg)
input signed [15:0] ptch,roll,yaw;			// actual pitch roll and yaw (from inertial interface)
input [8:0] thrst;							// thrust level from slider
output [10:0] frnt_spd;						// 11-bit unsigned speed at which to run front motor
output [10:0] bck_spd;						// 11-bit unsigned speed at which to back front motor
output [10:0] lft_spd;						// 11-bit unsigned speed at which to left front motor
output [10:0] rght_spd;						// 11-bit unsigned speed at which to right front motor

///////////////////////////////////////////////////
// Need integer for loop used to create D_QUEUE //
/////////////////////////////////////////////////
integer x;
//////////////////////////////
// Define needed registers //
////////////////////////////								
reg signed [9:0] prev_ptch_err[0:D_QUEUE_DEPTH-1];
reg signed [9:0] prev_roll_err[0:D_QUEUE_DEPTH-1];
reg signed [9:0] prev_yaw_err[0:D_QUEUE_DEPTH-1];	// need previous error terms for D of PD

//////////////////////////////////////////////////////
// You will need a bunch of interal wires declared //
// for intermediate math results...do that here   //
///////////////////////////////////////////////////
logic [16:0] ptch_err, yaw_err, roll_err;
logic [9:0]  ptch_err_sat, yaw_err_sat, roll_err_sat;
logic [9:0]  ptch_D_diff, roll_D_diff, yaw_D_diff;
logic signed [9:0] ptch_pterm, yaw_pterm, roll_pterm;
logic signed [11:0] ptch_dterm, yaw_dterm, roll_dterm;

logic signed [5:0] ptch_D_diff_sat, roll_D_diff_sat, yaw_D_diff_sat;

///////////////////////////////////////////////////////////////
// some Parameters to keep things more generic and flexible //
/////////////////////////////////////////////////////////////

  localparam CAL_SPEED = 11'h1B0;		// speed to run motors at during inertial calibration
  localparam MIN_RUN_SPEED = 13'h200;	// minimum speed while running  
  localparam D_COEFF = 6'b00111;			// D coefficient in PID control = +7
  localparam MAX_10 = 10'b0111111111;
  localparam MIN_10 = 10'b1000000000;
  localparam MAX_6 = 6'b011111;
  localparam MIN_6 = 6'b100000;
  
/// OK...rest is up to you...good luck! ///
assign ptch_err = ptch - d_ptch;
assign roll_err = roll - d_roll;
assign yaw_err =  yaw -  d_yaw;

//signed-err-sat 17 to 10
assign ptch_err_sat = (~ptch_err[16]) ?           //positive ? 
(!(|ptch_err[16:10]) ? ptch_err[9:0] : MAX_10) :  //is any bit in 16:10 unset ? 
((&ptch_err[16:10]) ? ptch_err[9:0]: MIN_10);

assign roll_err_sat = (~roll_err[16]) ?           //positive ? 
(!(|roll_err[16:10]) ? roll_err[9:0] : MAX_10) :  //is any bit in 16:10 unset ? 
((&roll_err[16:10]) ? roll_err[9:0]: MIN_10);

assign yaw_err_sat = (~yaw_err[16]) ?           //positive ? 
(!(|yaw_err[16:10]) ? yaw_err[9:0] : MAX_10) :  //is any bit in 16:10 unset ? 
((&yaw_err[16:10]) ? yaw_err[9:0]: MIN_10);


//saturate ptch_D_Diff [9:0] 10 to 6 bits 
assign ptch_D_diff_sat = (~ptch_D_Diff[9]) ?           
(!(|ptch_D_[9:6]) ? ptch_D_Diff[5:0] : MAX_6) :     
((&ptch_D_diff[9:6]) ? ptch_D_Diff[5:0]: MIN_6);

assign roll_D_diff_sat = (~roll_D_Diff[9]) ?           
(!(|roll_D_[9:6]) ? roll_D_Diff[5:0] : MAX_6) :     
((&roll_D_diff[9:6]) ? roll_D_Diff[5:0]: MIN_6);

assign yaw_D_diff_sat = (~yaw_D_Diff[9]) ?           
(!(|yaw_D_[9:6]) ? yaw_D_Diff[5:0] : MAX_6) :     
((&yaw_D_diff[9:6]) ? yaw_D_Diff[5:0]: MIN_6);


//ptch_pterm = (5/8) * ptch_err_sat OR [1/2(p) + 1/8(p)]
assign ptch_pterm = (ptch_err_sat >>> 1) + (ptch_err_sat >>> 3); 
assign roll_pterm = (roll_err_sat >>> 1) + (roll_err_sat >>> 3); 
assign yaw_pterm =  (yaw_err_sat >>> 1) +  (yaw_err_sat >>> 3); 

assign ptch_D_diff = ptch_err_sat - prev_ptch_err[D_QUEUE_DEPTH-1];
assign roll_D_diff = roll_err_sat - prev_roll_err[D_QUEUE_DEPTH-1];
assign yaw_D_diff  = yaw_err_sat -  prev_yaw_err[D_QUEUE_DEPTH-1];

//signed multiply
assign ptch_dterm = $signed(D_COEFF) * ptch_D_diff_sat;
assign roll_dterm = $signed(D_COEFF) * roll_D_diff_sat;
assign yaw_dterm =  $signed(D_COEFF) *  yaw_D_diff_sat;

always_ff @(posedge clk or negedge rst_n) begin 
	if(!rst_n) begin
		for(x = 0; x < D_QUEUE_DEPTH; x = x + 1) begin
			prev_ptch_err[x] = 10'h000;
			prev_roll_err[x] = 10'h000;
			prev_yaw_err[x] = 10'h000;
		end else if(vld) begin
			for(x = D_QUEUE_DEPTH-1; x > 0; x = x+1) begin
				prev_ptch_err[x] = prev_ptch_err[x-1];
				prev_roll_err[x] = prev_roll_err[x-1];
				prev_yaw_err[x] = prev_yaw_err[x-1];
			end
			prev_ptch_err[0] = ptch_err_sat;
			prev_roll_err[0] = roll_err_sat;
			prev_yaw_err[0] = yaw_err_sat;
		end
	endmodule 