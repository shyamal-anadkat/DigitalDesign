module SPI_mstr16 (SS_n, SCLK, MOSI, done, rd_data, MISO, wrt, cmd, clk, rst_n);

	output logic SS_n, SCLK, MOSI,done;
	output logic [15:0] rd_data;

	input clk, rst_n, MISO;
input wrt;	//high for 1 clk period wld init a SPI transaction
input [15:0] cmd;


//SCLK will be 1/32 of the 50MHz clock
logic [4:0] sclk_div; //cntr for posedge clk
logic [4:0] bit_cntr; //bit-cntr
logic rst_cnt, shft,set_done;
logic smpl, MISO_smpl;

logic [1:0] state, nxt_state;

localparam IDLE = 2'b00;
localparam FRONT_PORCH = 2'b01;
localparam BITS = 2'b10;
localparam BACK_PORCH = 2'b11;


//bit_cntr to know when we shifted 8 bits 
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		bit_cntr <= 5'b00000;
	end else if (rst_cnt) begin 
		bit_cntr <= 5'b00000;
	end else if (shft) begin
		bit_cntr <= bit_cntr + 1;
	end
end

//sclk div bit counter for the CLOCK
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		sclk_div <= 5'b00000;
	else if(rst_cnt) 
		sclk_div <= 5'b10111;
	else
	sclk_div <= sclk_div + 1;
end

assign SCLK = sclk_div[4];


// DONE FLOP
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		done <= 1'b0;
	else if (set_done)
		done <= 1'b1;
	else if (wrt)
		done <= 1'b0;
end

//SLAVE SELECT FLOP
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		SS_n <= 1'b1;
	else if (set_done)
		SS_n <= 1'b1;
	else if (wrt)
		SS_n <= 1'b0;
end

always_ff @(posedge clk) begin
	if(smpl)
		MISO_smpl <= MISO;
end

//rd_data flop (with optional else)
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		rd_data <= 16'b0;
	else if(wrt) 
		rd_data <= cmd;
	else if(shft) 
		rd_data <= {rd_data[14:0], MISO_smpl};
end

//assign MOSI 
assign MOSI = rd_data[15];

always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		state <= IDLE;
	end else begin
		state <= nxt_state;
	end
end

//state machine logic


always_comb begin
	rst_cnt = 1'b0; 
	set_done = 1'b0;
	nxt_state = IDLE;
	shft = 1'b0;

	case(state)

		IDLE: begin 
			rst_cnt = 1'b1;
			if(wrt) begin
				nxt_state = FRONT_PORCH;
			end else begin
				nxt_state = IDLE;
				set_done = 1'b1;
			end
		end

		FRONT_PORCH: begin
			if(sclk_div == 5'b11111) begin
				nxt_state = BITS;
				shft = 1'b1;
			end else begin
				nxt_state = FRONT_PORCH;
			end
		end

		BITS: begin 
			if(bit_cntr==4'b1111) begin
				nxt_state = BACK_PORCH;
			end else if(sclk_div == 5'b01111) begin
				nxt_state = BITS;
				smpl = 1'b1;
			end else if(sclk_div == 5'b11111) begin
				nxt_state = BITS;
				shft = 1'b1;
			end else begin
				nxt_state = BITS;
			end
		end 

		BACK_PORCH: begin 
			if(sclk_div == 5'b01111) begin
				set_done = 1;
				rst_cnt = 1;
				nxt_state = IDLE;
			end else begin
				nxt_state = BACK_PORCH;
			end
		end 
		default: 
		nxt_state = IDLE;
endcase // state
end
endmodule