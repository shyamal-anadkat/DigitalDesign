module SPI_mstr16_tb_TA();

  logic clk, rst_n;

  logic MISO, done, SS_n, SCLK, MOSI, wrt;
  logic [15:0] cmd;
  logic [15:0] rd_data;
  integer i;

ADC128S iDUT_slave(
  .clk(clk),
  .rst_n(rst_n),
  .SS_n(SS_n),
  .SCLK(SCLK),
  .MISO(MISO),
  .MOSI(MOSI));

SPI_mstr16  iDUT_master(.clk(clk), 
  .rst_n(rst_n), 
  .cmd(16'h0000), 
  .wrt(wrt), .MISO(MISO), 
  .MOSI(MOSI), .SS_n(SS_n), 
  .SCLK(SCLK), .done(done), 
  .rd_data(rd_data));


  initial begin
   clk = 0;
   rst_n = 0;
   wrt = 0;

   @(posedge clk)
   @(negedge clk)
   rst_n = 1;

   for(i = 0; i < 100 ; i = i + 1) begin
     @(posedge clk);
     wrt = 1;
     @(posedge clk);
     wrt = 0;
   		@(posedge done) // or @(done) we have sent the channel number #


       wrt = 1;
       @(posedge clk);
       wrt = 0;
       @(posedge done);

       if(done) begin
       			// display error
             $display("Error in DONE");
             //$stop;
       			// stop
          end

   		@(posedge done);  // we have our data

   		if( rd_data != (16'hC00 - (i*8'h10))) begin
     			// display error
           $display("Error");
           $stop;  
      			// stop
         end
       end  

       $display("all tests passed");
       $stop;   

     end


     always 
     #1 clk = ~clk;


   endmodule