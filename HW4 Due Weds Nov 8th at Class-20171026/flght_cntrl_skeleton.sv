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

///////////////////////////////////////////////////////////////
// some Parameters to keep things more generic and flexible //
/////////////////////////////////////////////////////////////
  
  localparam CAL_SPEED = 11'h1B0;		// speed to run motors at during inertial calibration
  localparam MIN_RUN_SPEED = 13'h200;	// minimum speed while running  
  localparam D_COEFF = 6'b00111;			// D coefficient in PID control = +14
  
  
/// OK...rest is up to you...good luck! ///


  
endmodule 
