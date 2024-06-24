`timescale 1ns / 1ps
 
module LiftController(d_up,d_down,f,p_dir,rfloor,clk, reset);
input  [3:0] d_up; //single bit input from each floor.1 means uprequest, 0 means no request for up direction
input [3:0] d_down; //single bit input from each floor.1 means request for going down, 0 means no request for going down
input [4:0] f; //[fl4, fl3, fl2, fl1, fl0]  request forfloor 4, 3, 2, 1 respectively. 
output reg [1:0] p_dir; //The lift will move in up/down direction in next clock; 10means up, 01means downand 00 implies it will stay in the current floor and 11 is invalid. 
input clk , reset;
output reg[2:0]rfloor; //next stop of the lift

parameter S0 = 4'd1 , U01 = 4'd2, D01 = 4'd3,  S1 = 4'd4, U12 = 4'd5, D12 = 4'd6, S2 = 4'd7, U23 = 4'd8, D23 = 4'd9, S3 = 4'd10,  U34 = 4'd11, D34 = 4'd12, S4= 4'd13 , M = 4'd14;
reg [2:0] pfloor;
reg [1:0] count;
reg [1:0] ndir;
reg [4:0] pstate , nstate;
reg [2:0] nfloor;
reg[1:0] pdir ;
reg rdir;

//reg [25:0] counter = 26'd0;
//parameter DIVISOR = 26'b11111111111111111111111111;
// reg clk_out;
//always @(posedge clk) begin
//    counter <= counter +26'd1;
//    if (counter >= DIVISOR - 1) begin
//        counter <= 26'd0;
//        clk_out <= ~clk_out;
//    end
//end

always @(posedge clk) begin
    if(reset) begin 
        pstate = S0;
        pfloor = 3'd0;
    end 
    else begin
         pstate = nstate;
         pfloor = nfloor;
    end
end

always @(posedge clk) begin
    if(reset) begin
        nstate = S0;
        rfloor = 3'd0;
        count = 2'd0;
        nfloor = 3'd0;
        pdir = 2'b10;
        p_dir = 2'b00;
        ndir = 2'b00;
    end else begin
        case (pstate)
            S0: begin 
                    if(f[1] == 1) begin 
                        rfloor = 3'd1; rdir = 1'b1;
                    end else if(f[2] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b1;
                    end else if(f[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1;
                    end else if(f[4] == 1) begin 
                        rfloor = 3'd4; rdir = 1'b1;
                    end else if(d_up[1] == 1) begin 
                        rfloor = 3'd1; rdir = 1'b1;
                    end else if(d_down[0] == 1) begin 
                        rfloor = 3'd1; rdir = 1'b0;
                    end else if(d_up[2] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b1;
                    end else if(d_down[1] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b0;
                    end else if(d_up[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1;
                    end else if(d_down[2] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b0;
                    end else if(d_down[3] == 1) begin 
                        rfloor = 3'd4; rdir = 1'b0;
                    end
                    if (rfloor != 3'd0) begin 
                        nstate = U01; nfloor = 3'd0; pdir = 2'b10; ndir = 2'b10;
                    end else begin 
                        nstate = S0; nfloor = 3'd0; ndir = 2'b00;
                    end
                    if(f == 5'd0 && d_up == 4'd0 && d_down == 4'd0) begin nstate = S0; nfloor = 3'd0; ndir = 2'b00; end
                end
            U01:begin 
                    if(f[1] == 1) begin 
                        rfloor = 3'd1; rdir = 1'b1;
                    end else if(f[2] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b1;
                    end else if(f[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1;
                    end else if(f[4] == 1) begin 
                        rfloor = 3'd4; rdir = 1'b1;
                    end else if(d_up[1] == 1) begin 
                        rfloor = 3'd1; rdir = 1'b1;
                    end  else if(d_up[2] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b1;
                    end else if(d_up[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1;
                    end  else if(d_down[3] == 1) begin 
                        rfloor = 3'd4; rdir = 1'b0;
                    end
                    if(count == 2'd2) begin 
                        count = 0; 
                        if(ndir == 2'b00) begin 
                            nstate = S1;
                            nfloor = 3'd1;
                        end else begin 
                            nstate = M;
                            nfloor = 3'd1;
                        end
                    end else begin 
                        nstate = U01;
                        count = count + 1; 
                        if(f[1] == 1) begin 
                            ndir = 2'b00;
                        end else if (rfloor == 3'd4 || rdir == 1) begin 
                            if(d_up[1] == 1) ndir = 2'b00;
                        end 
                    end
                    pdir = 2'b10; 
                end
            S1: begin 
                    if (rfloor == 3'd1) begin
                        if(rdir) begin 
                            if(f[2] == 1) begin 
                                rfloor = 3'd2; rdir = 1'b1;
                            end else if(f[3] == 1) begin 
                                rfloor = 3'd3; rdir = 1'b1;
                            end else if(f[4] == 1) begin 
                                rfloor = 3'd4; rdir = 1'b1;
                            end if(d_up[2] == 1) begin 
                                rfloor = 3'd2; rdir = 1'b1;
                            end else if(d_down[1] == 1) begin 
                                rfloor = 3'd2; rdir = 1'b0;
                            end else if(d_up[3] == 1) begin 
                                rfloor = 3'd3; rdir = 1'b1;
                            end else if(d_down[2] == 1) begin 
                                rfloor = 3'd3; rdir = 1'b0;
                            end else if(d_down[3] == 1) begin 
                                rfloor = 3'd4; rdir = 1'b0;
                            end
                            if(rfloor == 3'd1) begin 
                                if(f[0] == 1) begin 
                                    rfloor = 3'd0; rdir = 1'b0;pdir = 2'b01;
                                end else if(d_up[0] == 1) begin 
                                    rfloor = 3'd0; rdir = 1'b0;pdir = 2'b01;
                                end      
                            end else pdir = 2'b10;
                            if (rfloor != 3'd1) begin 
                                if(pdir == 2'b10) begin
                                    nstate = U12; ndir = 2'b10;
                                end else begin 
                                    nstate = D01; ndir = 2'b01; 
                                end
                            end else begin 
                                nstate = S1; nfloor = 3'd1; ndir = 2'b00;
                            end
                        end else begin 
                            if(f[0] == 1) begin 
                                rfloor = 3'd0; rdir = 1'b0;
                            end else if(d_up[0] == 1) begin 
                                rfloor = 3'd0; rdir = 1'b1;
                            end
                            if(rfloor == 3'd1) begin 
                                if(f != 5'd0) begin 
                                    if(f[2] == 1) begin 
                                        rfloor = 3'd2; rdir = 1'b1;
                                    end else if(f[3] == 1) begin 
                                        rfloor = 3'd3; rdir = 1'b1;
                                    end else if(f[4] == 1) begin 
                                        rfloor = 3'd4; rdir = 1'b1;
                                    end
                                end else if (d_up != 4'd0 || d_down != 4'd0) begin 
                                    if(d_up[2] == 1) begin 
                                        rfloor = 3'd2; rdir = 1'b1;pdir =  2'b10;
                                    end else if(d_down[1] == 1) begin 
                                        rfloor = 3'd2; rdir = 1'b0;pdir =  2'b10;
                                    end else if(d_up[3] == 1) begin 
                                        rfloor = 3'd3; rdir = 1'b1;pdir =  2'b10;
                                    end else if(d_down[2] == 1) begin 
                                        rfloor = 3'd3; rdir = 1'b0;pdir =  2'b10;
                                    end else if(d_down[3] == 1) begin 
                                        rfloor = 3'd4; rdir = 1'b0;pdir =  2'b10;
                                    end 
                                end
                            end else pdir =  2'b01;
                            if (rfloor != 3'd1) begin 
                                if(pdir ==  2'b10) begin
                                    nstate = U12; ndir = 2'b10;
                                end else begin 
                                    nstate = D01; ndir = 2'b01; 
                                end
                            end else begin 
                                nstate = S1; nfloor = 3'd1; ndir = 2'b00;
                            end
                        end
                    end else begin 
                        if(pdir ==  2'b10) begin 
                            nstate = U12; ndir = 2'b10; 
                        end else begin 
                            nstate = D01; ndir = 2'b01;
                        end
                    end
                    if(f == 5'd0 && d_up == 4'd0 && d_down == 4'd0) begin nstate = S1; nfloor = 3'd1; ndir = 2'b00; end
                end
            D01:begin 
                    if(count == 2'd2) begin 
                        count = 0; 
                        nstate = S0;
                        nfloor = 0;
                    end else begin 
                        nstate = D01;
                        count = count + 1; 
                        ndir = 2'b00;
                    end
                    pdir =  2'b01; 
                end
            U12:begin 
                     if(f[2] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b1;
                    end else if(f[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1;
                    end else if(f[4] == 1) begin 
                        rfloor = 3'd4; rdir = 1'b1;
                    end  else if(d_up[2] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b1;
                    end else if(d_up[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1;
                    end  else if(d_down[3] == 1) begin 
                        rfloor = 3'd4; rdir = 1'b0;
                    end
                    if(count == 2'd2) begin 
                        count = 0; 
                        if(ndir == 2'b00) begin 
                            nstate = S2;
                            nfloor = 3'd2;
                        end else begin 
                            nstate = M;
                            nfloor = 3'd2;
                        end
                    end else begin 
                        nstate = U12;
                        count = count + 1; 
                        if(f[2] == 1) begin 
                            ndir = 2'b00;
                        end else if (rfloor == 3'd4 || rdir == 1) begin 
                            if(d_up[2] == 1) ndir = 2'b00;
                        end 
                    end
                    pdir =  2'b10; 
                end
            D12:begin 
                     if(f[1] == 1) begin 
                           rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01;
                       end else if(f[0] == 1) begin 
                           rfloor = 3'd0; rdir = 1'b0;pdir =  2'b01;
                       end  else if(d_down[0] == 1) begin 
                           rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01; 
                       end else if(d_up[0] == 1) begin 
                           rfloor = 3'd0; rdir = 1'b1;pdir =  2'b01;
                       end
                    if(count == 2'd2) begin 
                        count = 0; 
                        if(ndir == 2'b00) begin 
                            nstate = S1;
                            nfloor = 3'd1;
                        end else begin 
                            nstate = M;
                            nfloor = 3'd1;
                        end
                    end else begin 
                        nstate = D12;
                        count = count + 1; 
                        if(f[1] == 1) begin 
                            ndir = 2'b00;
                        end else if (rfloor == 3'd0 || rdir == 0) begin 
                            if(d_down[0] == 1) ndir = 2'b00;
                        end 
                    end
                    pdir =  2'b01; 
                end
            S2:begin 
                    if (rfloor == 3'd2) begin
                        if(rdir) begin
                            if(f[3] == 1) begin 
                                rfloor = 3'd3; rdir = 1'b1;
                            end else if(f[4] == 1) begin 
                                rfloor = 3'd4; rdir = 1'b1;
                            end else if(d_up[3] == 1) begin 
                                rfloor = 3'd3; rdir = 1'b1;
                            end else if(d_down[2] == 1) begin 
                                rfloor = 3'd3; rdir = 1'b0;
                            end else if(d_down[3] == 1) begin 
                                rfloor = 3'd4; rdir = 1'b0;
                            end
                            if(rfloor == 3'd2) begin 
                                if(f[1] == 1) begin 
                                    rfloor = 3'd1; rdir = 1'b0; pdir =  2'b01;
                                end else if(f[0] == 1) begin 
                                    rfloor = 3'd0; rdir = 1'b0; pdir =  2'b01;
                                end else if(d_up[1] == 1) begin 
                                    rfloor = 3'd1; rdir = 1'b1; pdir = 2'b01;
                                end else if(d_down[0] == 1) begin 
                                    rfloor = 3'd1; rdir = 1'b0; pdir =  2'b01;
                                end else if(d_up[0] == 1) begin 
                                    rfloor = 3'd0; rdir = 1'b1; pdir =  2'b01;
                                end 
                            end else pdir =  2'b10;
                            if (rfloor != 3'd2) begin 
                                if(pdir ==  2'b10) begin
                                    nstate = U23; ndir = 2'b10;
                                end else begin 
                                    nstate = D12; ndir = 2'b01; 
                                end
                            end else begin 
                                nstate = S2; nfloor = 3'd2; ndir = 2'b00;
                            end
                        end else begin 
                            if(f[1] == 1) begin 
                                rfloor = 3'd1; rdir = 1'b0;
                            end else if(f[0] == 1) begin 
                                rfloor = 3'd0; rdir = 1'b0;
                            end else if(d_up[1] == 1) begin 
                                rfloor = 3'd1; rdir = 1'b1; 
                            end else if(d_down[0] == 1) begin 
                                rfloor = 3'd1; rdir = 1'b0; 
                            end else if(d_up[0] == 1) begin 
                                rfloor = 3'd0; rdir = 1'b1;
                            end
                            if(rfloor == 3'd2) begin 
                                if(f[3] == 1) begin 
                                    rfloor = 3'd3; rdir = 1'b1;pdir =  2'b10;
                                end else if(f[4] == 1) begin 
                                    rfloor = 3'd4; rdir = 1'b1;pdir =  2'b10;
                                end if(d_up[3] == 1) begin 
                                    rfloor = 3'd3; rdir = 1'b1;pdir =  2'b10;
                                end else if(d_down[2] == 1) begin 
                                    rfloor = 3'd3; rdir = 1'b0;pdir =  2'b10;
                                end else if(d_down[3] == 1) begin 
                                    rfloor = 3'd4; rdir = 1'b0;pdir =  2'b10;
                                end 
                            end else pdir =  2'b01;
                            if (rfloor != 3'd2) begin 
                                if(pdir ==  2'b10) begin
                                    nstate = U23; ndir = 2'b10;
                                end else begin 
                                    nstate = D12; ndir = 2'b01; 
                                end
                            end else begin 
                                nstate = S2; nfloor = 3'd2; ndir = 2'b00;
                            end
                        end
                    end else begin 
                        if(pdir ==  2'b10) begin 
                            nstate = U23; ndir = 2'b10; 
                        end else begin 
                            nstate = D12; ndir = 2'b01;
                        end
                    end
                    if(f == 5'd0 && d_up == 4'd0 && d_down == 4'd0) begin nstate = S2; nfloor = 3'd2; ndir = 2'b00; end
                end
            U23:begin 
                    if(f[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1;
                    end else if(f[4] == 1) begin 
                        rfloor = 3'd4; rdir = 1'b1;
                    end  else if(d_up[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1;
                    end  else if(d_down[3] == 1) begin 
                        rfloor = 3'd4; rdir = 1'b0;
                    end
                    if(count == 2'd2) begin 
                        count = 0; 
                        if(ndir == 2'b00) begin 
                            nstate = S3;
                            nfloor = 3'd3;
                        end else begin 
                            nstate = M;
                            nfloor = 3'd3;
                        end
                    end else begin 
                        nstate = U23;
                        count = count + 1; 
                        if(f[3] == 1) begin 
                            ndir = 2'b00;
                        end else if (rfloor == 3'd4 || rdir == 1) begin 
                            if(d_up[3] == 1) ndir = 2'b00;
                        end 
                    end
                    pdir =  2'b10; 
                end
            D23:begin 
                   if(f[2] == 1) begin 
                       rfloor = 3'd2; rdir = 1'b0;pdir =  2'b01;
                   end else if(f[1] == 1) begin 
                       rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01;
                   end else if(f[0] == 1) begin 
                       rfloor = 3'd0; rdir = 1'b0;pdir =  2'b01;
                   end  else if(d_down[1] == 1) begin 
                       rfloor = 3'd2; rdir = 1'b0;pdir =  2'b01;
                   end  else if(d_down[0] == 1) begin 
                       rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01; 
                   end else if(d_up[0] == 1) begin 
                       rfloor = 3'd0; rdir = 1'b1;pdir =  2'b01;
                   end
                    if(count == 2'd2) begin 
                        count = 0; 
                        if(ndir == 2'b00) begin 
                            nstate = S2;
                            nfloor = 3'd2;
                        end else begin 
                            nstate = M;
                            nfloor = 3'd2;
                    end
                    end else begin 
                        nstate = D23;
                        count = count + 1; 
                        if(f[2] == 1) begin 
                            ndir = 2'b00;
                        end else if (rfloor == 3'd0 || rdir == 0) begin 
                            if(d_down[1] == 1) ndir = 2'b00;
                        end 
                    end
                    pdir =  2'b01; 
                end
            S3:begin 
                    if (rfloor == 3'd3) begin
                        if(rdir) begin
                            if(f[4] == 1) begin 
                                rfloor = 3'd4; rdir = 1'b1;
                            end else if(d_down[3] == 1) begin 
                                rfloor = 3'd4; rdir = 1'b0;
                            end
                            if(rfloor == 3'd3) begin 
                                if(f[2] == 1) begin 
                                    rfloor = 3'd2; rdir = 1'b0; pdir =  2'b01;
                                end else if(f[1] == 1) begin 
                                    rfloor = 3'd1; rdir = 1'b0; pdir =  2'b01;
                                end else if(f[0] == 1) begin 
                                    rfloor = 3'd0; rdir = 1'b0; pdir = 2'b01;
                                end else if(d_up[2] == 1) begin 
                                    rfloor = 3'd2; rdir = 1'b1; pdir = 2'b01;
                                end else if(d_down[1] == 1) begin 
                                    rfloor = 3'd2; rdir = 1'b0; pdir =  2'b01;
                                end else if(d_up[1] == 1) begin 
                                    rfloor = 3'd1; rdir = 1'b1; pdir =  2'b01;
                                end else if(d_down[0] == 1) begin 
                                    rfloor = 3'd1; rdir = 1'b0; pdir =  2'b01;
                                end else if(d_up[0] == 1) begin 
                                    rfloor = 3'd0; rdir = 1'b1; pdir =  2'b01;
                                end 
                            end else pdir =  2'b10;
                            if (rfloor != 3'd3) begin 
                                if(pdir ==  2'b10) begin
                                    nstate = U34; ndir = 2'b10;
                                end else begin 
                                    nstate = D23; ndir = 2'b01; 
                                end
                            end else begin 
                                nstate = S3; nfloor = 3'd3; ndir = 2'b00;
                            end
                        end else begin 
                            if(f[2] == 1) begin 
                                rfloor = 3'd2; rdir = 1'b0;
                            end else if(f[1] == 1) begin 
                                rfloor = 3'd1; rdir = 1'b0;
                            end else if(f[0] == 1) begin 
                                rfloor = 3'd0; rdir = 1'b0;
                            end else if(d_up[2] == 1) begin 
                                rfloor = 3'd2; rdir = 1'b1; 
                            end else if(d_down[1] == 1) begin 
                                rfloor = 3'd2; rdir = 1'b0;
                            end else if(d_up[1] == 1) begin 
                                rfloor = 3'd1; rdir = 1'b1; 
                            end else if(d_down[0] == 1) begin 
                                rfloor = 3'd1; rdir = 1'b0; 
                            end else if(d_up[0] == 1) begin 
                                rfloor = 3'd0; rdir = 1'b1;
                            end
                            if(rfloor == 3'd3) begin 
                                if(f[4] == 1) begin 
                                    rfloor = 3'd4; rdir = 1'b1;pdir =  2'b10;
                                end else if(d_down[3] == 1) begin 
                                    rfloor = 3'd4; rdir = 1'b0;pdir =  2'b10;
                                end 
                            end else pdir =  2'b01;
                            if (rfloor != 3'd3) begin 
                                if(pdir ==  2'b10) begin
                                    nstate = U34; ndir = 2'b10;
                                end else begin 
                                    nstate = D23; ndir = 2'b01; 
                                end
                            end else begin 
                                nstate = S3; nfloor = 3'd3; ndir = 2'b00;
                            end
                        end
                    end else begin 
                        if(pdir ==  2'b10) begin 
                            nstate = U34; ndir = 2'b10; 
                        end else begin 
                            nstate = D23; ndir = 2'b01;
                        end
                    end
                    if(f == 5'd0 && d_up == 4'd0 && d_down == 4'd0) begin nstate = S3; nfloor = 3'd3; ndir = 2'b00; end
                end
            U34:begin
                    if(count == 2'd2) begin 
                        count = 0; 
                        nstate = S4;
                        nfloor = 3'd4;
                    end else begin 
                        nstate = U34;
                        count = count + 1; 
                        ndir = 2'b00;
                    end
                    pdir =  2'b10; 
                end
            D34:begin 
                   if(f[3] == 1) begin 
                       rfloor = 3'd3; rdir = 1'b0;pdir =  2'b01;
                   end else if(f[2] == 1) begin 
                       rfloor = 3'd2; rdir = 1'b0;pdir =  2'b01;
                   end else if(f[1] == 1) begin 
                       rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01;
                   end else if(f[0] == 1) begin 
                       rfloor = 3'd0; rdir = 1'b0;pdir =  2'b01;
                   end else if(d_down[2] == 1) begin 
                       rfloor = 3'd3; rdir = 1'b0;pdir =  2'b01;
                   end else if(d_down[1] == 1) begin 
                       rfloor = 3'd2; rdir = 1'b0;pdir =  2'b01;
                   end  else if(d_down[0] == 1) begin 
                       rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01; 
                   end else if(d_up[0] == 1) begin 
                       rfloor = 3'd0; rdir = 1'b1;pdir =  2'b01;
                   end
                    if(count == 2'd2) begin 
                        count = 0; 
                        if(ndir == 2'b00) begin 
                            nstate = S3;
                            nfloor = 3'd3;
                        end else begin 
                            nstate = M;
                            nfloor = 3'd3;
                        end
                    end else begin 
                        nstate = D34;
                        count = count + 1; 
                        if(f[3] == 1) begin 
                            ndir = 2'b00;
                        end else if (rfloor == 3'd0 || rdir == 0) begin 
                            if(d_down[2] == 1) ndir = 2'b00;
                        end 
                    end
                    pdir =  2'b01; 
                end     
             M : begin 
                     if(pdir ==  2'b10) begin 
                        case(pfloor) 
                            3'd1 : begin nstate = U12; 
                                         if(f[2] == 1) begin 
                                            rfloor = 3'd2; rdir = 1'b1;
                                        end else if(f[3] == 1) begin 
                                            rfloor = 3'd3; rdir = 1'b1;
                                        end else if(f[4] == 1) begin 
                                            rfloor = 3'd4; rdir = 1'b1;
                                        end  else if(d_up[2] == 1) begin 
                                            rfloor = 3'd2; rdir = 1'b1;
                                        end else if(d_up[3] == 1) begin 
                                            rfloor = 3'd3; rdir = 1'b1;
                                        end  else if(d_down[3] == 1) begin 
                                            rfloor = 3'd4; rdir = 1'b0;
                                        end
                                   end
                            3'd2:  begin nstate = U23; 
                                        if(f[3] == 1) begin 
                                           rfloor = 3'd3; rdir = 1'b1;
                                       end else if(f[4] == 1) begin 
                                           rfloor = 3'd4; rdir = 1'b1;
                                       end  else if(d_up[3] == 1) begin 
                                           rfloor = 3'd3; rdir = 1'b1;
                                       end  else if(d_down[3] == 1) begin 
                                           rfloor = 3'd4; rdir = 1'b0;
                                       end
                                  end
                            3'd3 : begin nstate= U34; end
                        endcase
                        pdir =  2'b10;
                        ndir = 2'b10;
                    end
                 else begin 
                        case(pfloor) 
                            3'd1 :begin nstate = D01; end
                            3'd2: begin nstate = D12;
                                      if(f[1] == 1) begin 
                                          rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01;
                                      end else if(f[0] == 1) begin 
                                          rfloor = 3'd0; rdir = 1'b0;pdir =  2'b01;
                                      end  else if(d_down[0] == 1) begin 
                                          rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01; 
                                      end else if(d_up[0] == 1) begin 
                                          rfloor = 3'd0; rdir = 1'b1;pdir =  2'b01;
                                      end
                                 end
                            3'd3 : begin nstate= D23;  
                                         if(f[2] == 1) begin 
                                             rfloor = 3'd2; rdir = 1'b0;pdir =  2'b01;
                                         end else if(f[1] == 1) begin 
                                             rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01;
                                         end else if(f[0] == 1) begin 
                                             rfloor = 3'd0; rdir = 1'b0;pdir =  2'b01;
                                         end  else if(d_down[1] == 1) begin 
                                             rfloor = 3'd2; rdir = 1'b0;pdir =  2'b01;
                                         end  else if(d_down[0] == 1) begin 
                                             rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01; 
                                         end else if(d_up[0] == 1) begin 
                                             rfloor = 3'd0; rdir = 1'b1;pdir =  2'b01;
                                         end
                                   end
                        endcase
                        pdir =  2'b01;
                        ndir = 2'b01;
                    end
             end
            S4:begin      
                    if(f[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b0;pdir =  2'b01;
                    end else if(f[2] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b0;pdir =  2'b01;
                    end else if(f[1] == 1) begin 
                        rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01;
                    end else if(f[0] == 1) begin 
                        rfloor = 3'd0; rdir = 1'b0;pdir =  2'b01;
                    end else if(d_up[3] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b1; pdir =  2'b01;
                    end else if(d_down[2] == 1) begin 
                        rfloor = 3'd3; rdir = 1'b0;pdir =  2'b01;
                    end else if(d_up[2] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b1; pdir =  2'b01;
                    end else if(d_down[1] == 1) begin 
                        rfloor = 3'd2; rdir = 1'b0;pdir =  2'b01;
                    end else if(d_up[1] == 1) begin 
                        rfloor = 3'd1; rdir = 1'b1;pdir =  2'b01; 
                    end else if(d_down[0] == 1) begin 
                        rfloor = 3'd1; rdir = 1'b0;pdir =  2'b01; 
                    end else if(d_up[0] == 1) begin 
                        rfloor = 3'd0; rdir = 1'b1;pdir =  2'b01;
                    end
                    if (rfloor != 3'd4) begin                      
                        nstate = D34; ndir = 2'b01; 
                    end else begin 
                        nstate = S4; nfloor = 3'd4; ndir = 2'b00;
                    end                       
                    if(f == 5'd0 && d_up == 4'd0 && d_down == 4'd0) begin nstate = S4; nfloor = 3'd4; ndir = 2'b00; end
                end
        endcase
        p_dir = pdir;
        if(f == 5'd0 && d_up == 4'd0 && d_down == 4'd0)p_dir = 2'b00;
        end
end
endmodule