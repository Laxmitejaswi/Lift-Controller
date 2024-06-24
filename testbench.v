`timescale 1ns / 1ps
module testbench();
  reg [3:0]d_up; //single bit input from each floor.1 means uprequest, 0 means no request for up directioninput 
  reg [3:0] d_down; //single bit input from each floor.1 means request for going down, 0 means no request for going downinput 
  reg [4:0]floor; 
  reg clk = 1, rst;
  wire [1:0] next_direction;
  wire [2:0] next_floor;
  
  parameter period = 10;
  LiftController l(d_up,d_down,floor,next_direction,next_floor,clk, rst);
  always #(period/2) clk = ~clk;
  initial begin
    rst = 1;
    floor = 5'd0;
    d_up = 4'd0;
    d_down = 4'd0;   
  end
  initial begin
    //    #10 rst = 0; floor = 5'b01000;
    //    #40 d_up = 4'b0100; 
    //    #40 floor = 5'b11000; d_up = 4'b0000;
    //    #40 floor = 5'b10000;
    //    #150 d_down = 4'b0001;
    //    #100 d_up = 4'b1000; 
    //    #60 floor = 5'b00001;
    //    #60 d_down = 4'b0010; d_up = 4'b0000;
    //    #40 d_up = 4'b0010;
    //    #180 floor = 5'b11000;
    #10 rst = 0; d_up = 4'b0100;
    #20 d_down = 4'b1000;
    #50 d_up =  4'd0; floor = 5'b01000;
    #40 floor = 5'd0;
    #40 d_down =  4'd0; floor = 5'b00100; 
    #80 floor = 5'd0;
    #20 d_up = 4'b1000; d_down = 4'b0001;
    #40 d_down = 4'd0; floor = 5'b00001;
    #40 floor = 5'd0;
    #20 d_up = 4'b1100;
    #60 d_up = 4'b1000; floor = 5'b01000;
    #40 d_up = 4'd0; floor = 5'b10000;
    #40 floor = 5'd0;
    #20 floor = 5'b00100;
    #20 d_up = 4'b1000;
    #60 floor = 5'd0;
    #40 floor = 5'b10000;
  end
  initial begin
        $monitor($time,"nstate = %b , nfloor = %b",next_direction, next_floor);
        #520 $finish;
  end
endmodule