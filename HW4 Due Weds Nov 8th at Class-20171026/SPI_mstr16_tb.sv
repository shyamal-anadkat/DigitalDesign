module SPI_mstr16_tb();

  logic clk, rst_n;

  logic SS_n;
  logic SCLK;  
  logic MOSI;  
  logic done;
  logic [15:0] rd_data;

  logic wrt; 
  logic MISO;
  logic [15:0] exp_resp;      
  logic [15:0] rd_skip;

  ADC128S iDUT_slv(
    .clk(clk),
    .rst_n(rst_n),
    .SS_n(SS_n),
    .SCLK(SCLK),
    .MISO(MISO),
    .MOSI(MOSI));

  SPI_mstr16  iDUT_mstr(.clk(clk), 
    .rst_n(rst_n), 
    .cmd(16'h0000), 
    .wrt(wrt), .MISO(MISO), 
    .MOSI(MOSI), .SS_n(SS_n), 
    .SCLK(SCLK), .done(done), 
    .rd_data(rd_data));

  initial begin 

    clk = 0;
    rst_n = 0;
    #1;
    rst_n = 1;
    rd_skip = 0;

    for(exp_resp = 16'hC00; exp_resp >= 16'h000;) begin
      @(posedge clk) wrt = 1; 
      @(posedge clk) wrt = 0;
      #2000;

      if(done) begin
        if(rd_data != exp_resp) begin
          $display("ERROR iter: %d, rd_data: %h, exp_resp: %h", rd_skip, rd_data, exp_resp);
          $stop; 
        end
    end
    else begin
      $stop; 
    end
    rd_skip = rd_skip + 1;
    if(rd_skip % 2 == 0)
      exp_resp = exp_resp - 16'h10;
  end
  $stop; 
end 

always
#1 clk = ~clk;

endmodule