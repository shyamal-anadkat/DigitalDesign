module ESC_test(clk,RST_n,inc,sel_speed,OFF,SPEED,PWM);

	input clk;		// our 50MHz clock from DE0-Nano
	input RST_n;	// from push button, goes to our rst_synch block
	input inc;		// from push button, goes to our PB_release detector
	input sel_speed;		// from slide switch, selects between speed and offset

	output [9:0] OFF;		// offset term to ESC_interface
	output [10:0] SPEED;	// speed term to ESC_interface
	output PWM;				// goes to speed control of ESC

	////////////////////////////////////////
	// Declare any internal signals here //
	//////////////////////////////////////
	wire rst_n;		// global reset to all other blocks, produced by rst_synch
	wire released;	// from PB_release unit, goes high 1 clock with button release
	wire [3:0] cntr1, cntr2;

	/////////////////////////////////////
	// Instantiate reset synchronizer //
	///////////////////////////////////
	rst_synch iRST(.RST_n(RST_n), .clk(clk), .rst_n(rst_n));

	///////////////////////////////////////////////
	// Instantiate push button release detector //
	/////////////////////////////////////////////
	PB_release iPB(.clk(clk), .rst_n(rst_n), .PB(inc), .released(released));

	///////////////////////////////////////////////////////////
	// Instantiate your two 4-bit counter here and also     //
	// hook up their enable inputs.  You may have to infer //
	// some internal signals to make the enable logic     //
	///////////////////////////////////////////////////////
	cnt4 cntrA(.clk(clk), .rst_n(rst_n), .en(sel_speed & released), .cnt(cntr1)); //SPEED
	cnt4 cntrB(.clk(clk), .rst_n(rst_n), .en(~sel_speed & released), .cnt(cntr2)); //OFF


    ///////////////////////////////////////////////////////////////////////////
	// Use assigns to create OFF and SPEED from output of your two counters //
	/////////////////////////////////////////////////////////////////////////
	assign OFF =   {1'b0, cntr2, 5'b0};
	assign SPEED = {cntr1, 7'b0};
	
	///////////////////////////////////////////////////
	// Instantiate ESC_interface (which is the DUT) //
	/////////////////////////////////////////////////
	ESC_interface iDUT(.clk(clk), .rst_n(rst_n), .OFF(OFF), .SPEED(SPEED), .PWM(PWM));

endmodule

