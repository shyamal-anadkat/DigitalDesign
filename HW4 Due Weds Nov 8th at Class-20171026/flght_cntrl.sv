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
wire signed [16:0] ptch_err, yaw_err, roll_err;
wire signed [9:0]  ptch_err_sat, yaw_err_sat, roll_err_sat;
wire signed [9:0]  ptch_D_diff, roll_D_diff, yaw_D_diff;
wire signed [9:0] ptch_pterm, yaw_pterm, roll_pterm;
wire signed [11:0] ptch_dterm, yaw_dterm, roll_dterm;

wire signed [5:0] ptch_D_diff_sat, roll_D_diff_sat, yaw_D_diff_sat;
wire signed [12:0] frnt_spd_sum, back_spd_sum, left_spd_sum, right_spd_sum;
wire [10:0] frnt_spd_sat, back_spd_sat, left_spd_sat, right_spd_sat;

///////////////////////////////////////////////////////////////
// some Parameters to keep things more generic and flexible //
/////////////////////////////////////////////////////////////

  localparam CAL_SPEED = 11'h1B0;		// speed to run motors at during inertial calibration
  localparam MIN_RUN_SPEED = 13'h200;	// minimum speed while running  
  localparam D_COEFF = 6'b00111;		// D coefficient in PID control = +7
  
  localparam MAX_10 = 10'h1FF;
  localparam MIN_10 = 10'h200;
  localparam MAX_6 = 6'h1F;
  localparam MIN_6 = 6'h20;
  localparam MAX_11 = 11'h7FF;
  
/// OK...rest is up to you...good luck! ///

//ptch, roll, yaw err calculations 
assign ptch_err = ptch - d_ptch;

//signed-err-sat 17 to 10
assign ptch_err_sat = (ptch_err[16]) ?           
((&ptch_err[15:9]) ? ptch_err[9:0] : MIN_10) :  
((|ptch_err[15:9]) ? MAX_10: ptch_err[9:0]);

assign roll_err = roll - d_roll;
assign roll_err_sat = (roll_err[16]) ?           
((&roll_err[15:9]) ? roll_err[9:0] : MIN_10) :  
((|roll_err[15:9]) ? MAX_10: roll_err[9:0]);


assign yaw_err =  yaw -  d_yaw;
assign yaw_err_sat = (yaw_err[16]) ?           
((&yaw_err[15:9]) ? yaw_err[9:0] : MIN_10) :  
((|yaw_err[15:9]) ? MAX_10: yaw_err[9:0]);

//Shift on vld
always_ff @(posedge clk, negedge rst_n)begin
	if (!rst_n) begin
		for (x = 0; x < D_QUEUE_DEPTH; x=x+1) begin
			prev_ptch_err[x] <= 10'h000;
			prev_roll_err[x] <= 10'h000;
			prev_yaw_err[x] <= 10'h000;
		end
	end
	else if (vld) begin
		for (x = D_QUEUE_DEPTH-1; x > 0; x=x-1) begin
			prev_ptch_err[x] <= prev_ptch_err[x - 1];
			prev_roll_err[x] <= prev_roll_err[x - 1];
			prev_yaw_err[x] <= prev_yaw_err[x - 1];
		end
		prev_ptch_err[0] <= ptch_err_sat;
		prev_roll_err[0] <= roll_err_sat;
		prev_yaw_err[0] <= yaw_err_sat;
	end
end

//PTCH
assign ptch_D_diff = ptch_err_sat - prev_ptch_err[D_QUEUE_DEPTH-1];
//saturate ptch_D_Diff [9:0] 10 to 6 bits 
assign ptch_D_diff_sat = (ptch_D_diff[9]) ?           
((&ptch_D_diff[8:6]) ? ptch_D_diff[5:0] : MIN_6) :     
((|ptch_D_diff[8:6]) ? MAX_6 : ptch_D_diff[5:0]);
//signed multiply
assign ptch_dterm = ($signed(D_COEFF) * ptch_D_diff_sat);
//ptch_pterm = (5/8) * ptch_err_sat OR [1/2(p) + 1/8(p)]
assign ptch_pterm = ((ptch_err_sat >>> 1) + (ptch_err_sat >>> 3)); 


//ROLL
assign roll_D_diff = roll_err_sat - prev_roll_err[D_QUEUE_DEPTH-1];
assign roll_D_diff_sat = (roll_D_diff[9]) ?           
((&roll_D_diff[8:6]) ? roll_D_diff[5:0] : MIN_6) :     
((|roll_D_diff[8:6]) ? MAX_6 : roll_D_diff[5:0]);

assign roll_dterm = ($signed(D_COEFF) * roll_D_diff_sat);
assign roll_pterm = ((roll_err_sat >>> 1) + (roll_err_sat >>> 3)); 

//YAW
assign yaw_D_diff  = yaw_err_sat - prev_yaw_err[D_QUEUE_DEPTH-1];

assign yaw_D_diff_sat = (yaw_D_diff[9]) ?           
((&yaw_D_diff[8:6]) ? yaw_D_diff[5:0] : MIN_6) :     
((|yaw_D_diff[8:6]) ? MAX_6 : yaw_D_diff[5:0]);

assign yaw_dterm =  ($signed(D_COEFF) * yaw_D_diff_sat);
assign yaw_pterm =  ((yaw_err_sat >>> 1) +  (yaw_err_sat >>> 3)); 



//Front_speed = thrst + MIN_RUN_SPEED – ptch_Pterm – ptch_Dterm – yaw_Pterm – yaw_Dterm
assign frnt_spd_sum = 
MIN_RUN_SPEED + 
{4'h0, thrst} - 
{{3{ptch_pterm[9]}}, ptch_pterm} -
{ptch_dterm[11], ptch_dterm} -
{{3{yaw_pterm[9]}}, yaw_pterm} -
{yaw_dterm[11], yaw_dterm};

//Back_speed = thrst + MIN_RUN_SPEED + ptch_Pterm + ptch_Dterm – yaw_Pterm – yaw_Dterm
assign back_spd_sum =
MIN_RUN_SPEED + 
{4'h0, thrst} +
{{3{ptch_pterm[9]}}, ptch_pterm} +
{ptch_dterm[11], ptch_dterm} -
{{3{yaw_pterm[9]}}, yaw_pterm} -
{yaw_dterm[11], yaw_dterm};


//Left_speed = thrst + MIN_RUN_SPEED - roll_Pterm - roll_Dterm + yaw_Pterm + yaw_Dterm
assign left_spd_sum = 
MIN_RUN_SPEED + 
{4'h0, thrst} -
{{3{roll_pterm[9]}}, roll_pterm} -
{roll_dterm[11], roll_dterm} +
{{3{yaw_pterm[9]}}, yaw_pterm} +
{yaw_dterm[11], yaw_dterm};

//Right_speed = thrst + MIN_RUN_SPEED + roll_Pterm + roll_Dterm + yaw_Pterm + yaw_Dterm
assign right_spd_sum = 
MIN_RUN_SPEED + 
{4'h0, thrst} +
{{3{roll_pterm[9]}}, roll_pterm} +
{roll_dterm[11], roll_dterm} +
{{3{yaw_pterm[9]}}, yaw_pterm} +
{yaw_dterm[11], yaw_dterm};

//saturate 13 to 11 bits (unsigned)

assign frnt_spd_sat  = (|frnt_spd_sum[12:11]) ? MAX_11 : frnt_spd_sum[10:0];	
assign back_spd_sat  = (|back_spd_sum[12:11]) ? MAX_11 : back_spd_sum[10:0];	
assign left_spd_sat  = (|left_spd_sum[12:11]) ? MAX_11 : left_spd_sum[10:0];	
assign right_spd_sat = (|right_spd_sum[12:11]) ? MAX_11 : right_spd_sum[10:0];	

//calibration 
assign frnt_spd = inertial_cal ? CAL_SPEED : frnt_spd_sat;
assign bck_spd = inertial_cal ? CAL_SPEED : back_spd_sat;
assign lft_spd = inertial_cal ? CAL_SPEED : left_spd_sat;
assign rght_spd = inertial_cal ? CAL_SPEED : right_spd_sat;

endmodule // flght_cntrl