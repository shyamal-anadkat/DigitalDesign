module ESC_interface (clk, rst_n, speed, off, pwm);

input clk, rst_n;    //50MHz clock, asynch ac-low rst
input [10:0] speed;  //how fast to run motor
input [9:0] off;	 //off added to speed
output logic pwm;    //out to ESC to cntrl motor speed

//50,000 base to speed and off to achieve 1ms delay
//multiplyng by ? to promote to 4 bits...(shift left) x 16
//final reset(tail end) from hW2 - SR flop
//rising edge - rollover from 20 bit counter

logic [11:0] compensated_speed;
logic [15:0] promoted_bits;

logic set, reset;
logic [16:0] setting;
logic [19:0] cntr;


//initial comb logic 
always_comb begin 
	assign compensated_speed =  speed + off;
	assign promoted_bits = compensated_speed << 4; 
	assign setting = promoted_bits + 16'd50000;
end


//20 bit cntr flip flop module
always @(posedge clk or negedge rst_n) begin
	assign cntr = (!rst_n) ? 20'h0000: cntr + 1; 
end

//assign set and reset signal for FF
assign reset = (cntr[16:0]>=setting)? 1:0;
assign set = (&cntr==1'b1)? 1:0;


// tailing edge SR logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		pwm <= 1'b0;
	else if (reset) 
		pwm <= 1'b0;
	else if (set) 
		pwm <= 1'b1;
	else 
		pwm <= pwm;
end

endmodule