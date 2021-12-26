////////////////////////////////////////////////////////////////////// 
////                                                              //// 
////  File name: eth_phy.v                                        //// 
////                                                              //// 
////  This file is part of the Ethernet IP core project           //// 
////  http://www.opencores.org/projects/ethmac/                   //// 
////                                                              //// 
////  Author(s):                                                  //// 
////      - Tadej Markovic, tadej@opencores.org                   //// 
////                                                              //// 
////  All additional information is available in the README.txt   //// 
////  file.                                                       //// 
////                                                              //// 
////////////////////////////////////////////////////////////////////// 
////                                                              //// 
//// Copyright (C) 2002  Authors                                  //// 
////                                                              //// 
//// This source file may be used and distributed without         //// 
//// restriction provided that this copyright statement is not    //// 
//// removed from the file and that any derivative work contains  //// 
//// the original copyright notice and the associated disclaimer. //// 
////                                                              //// 
//// This source file is free software; you can redistribute it   //// 
//// and/or modify it under the terms of the GNU Lesser General   //// 
//// Public License as published by the Free Software Foundation; //// 
//// either version 2.1 of the License, or (at your option) any   //// 
//// later version.                                               //// 
////                                                              //// 
//// This source is distributed in the hope that it will be       //// 
//// useful, but WITHOUT ANY WARRANTY; without even the implied   //// 
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //// 
//// PURPOSE.  See the GNU Lesser General Public License for more //// 
//// details.                                                     //// 
////                                                              //// 
//// You should have received a copy of the GNU Lesser General    //// 
//// Public License along with this source; if not, download it   //// 
//// from http://www.opencores.org/lgpl.shtml                     //// 
////                                                              //// 
////////////////////////////////////////////////////////////////////// 
//--------------------------------------------------------------------- 
// Copyright (c) 2010 by Lattice Semiconductor Corporation 
//--------------------------------------------------------------------- 
// Disclaimer: 
// 
// This VHDL or Verilog source code is intended as a design reference 
// which illustrates how these types of functions can be implemented. 
// It is the user's responsibility to verify their design for 
// consistency and functionality through the use of formal 
// verification methods. Lattice Semiconductor provides no warranty 
// regarding the use or functionality of this code. 
// 
// -------------------------------------------------------------------- 
// 
// Lattice Semiconductor Corporation 
// 5555 NE Moore Court 
// Hillsboro, OR 97214 
// U.S.A 
// 
// TEL: 1-800-Lattice (USA and Canada) 
// 503-268-8001 (other locations) 
// 
// web: http://www.latticesemi.com/ 
// email: techsupport@latticesemi.com 
// 
// -------------------------------------------------------------------- 
// Code Revision History : 
// -------------------------------------------------------------------- 
// Ver: | Author     |Mod. Date |Changes Made: 
// V1.0 | Peter.Zhou |01/31/10  | 
// 
// -------------------------------------------------------------------- 
//`define SUPPORTED_SPEED_AND_PORT 7'h3F 
//`define EXTENDED_STATUS 1'b0 
//`define PHY_ID1 16'h0013 
//`define PHY_ID2 6'h1E 
//`define MAN_MODEL_NUM 6'h0E 
//`define MAN_REVISION_NUM 4'h2 
//`define ETH_PHY_ADDR 5'h01 
//`define phy_addr 5'h01 
// 
`timescale 1ns/1ps 
module mdio_slave_interface 
			( 
			input rst_n_i, 
			input mdc_i, 
			inout mdio, 
 
			//wishbone interface 
			input clk_i, 
			input rst_i, 
			input [7:0] address_i,			//Address signal OK 
  		input[7:0] data_i,					//Data input signal OK 
  		output reg[7:0] data_o,			//Data output signal OK 
  		input strobe_i,							//Selection pass signal OK 
  		input we_i,									//Write enable signal OK 
  		output reg ack_o 
			); 
/////////////////////// 
////////////////////////////////////////////////////////////////////// 
// 
// PHY management (MIIM) REGISTER definitions 
// 
////////////////////////////////////////////////////////////////////// 
// 
//   Supported registers: 
// 
// Addr | Register Name 
//-------------------------------------------------------------------- 
//   0  | Control reg.     |--> control register,basic register,read and write register 
//   1  | Status reg. #1   |--> normal operation,basic register,read_only register 
//   2  | PHY ID reg. 1    |--> PHY ID register,read_only regisetr 
//   3  | PHY ID reg. 2    |--> PHY ID register,read_only regisetr 
//	 4  | Register4				 |--> Auto-Negotiation advertisement register,read and write register 
//	 5  | Register5			 	 |--> Auto-Negotiation Link Partner ability register,read_only register 
//	 6	| Register6				 |--> Auto-Negotiation expansion register, read_only register 
//	 7	| Register7				 |--> Auto-Negotiation Next Page transmit register, read and write register 
// 	 8  | Register8				 |--> Auto-Negotiation Link Partner Received Next Page register,read_only register 
//	 9	| Register9				 |--> 100BASE-T2 Control register/1000BASE-T2 Control register(Master_Slave),read and write register 
//	10	| Register10			 |-->	100BASE-T2 Control register/1000BASE-T2 Status register(Master_Slave),read only register 
//	11	| Register11			 |--> PSE Control register,read and write register 
//	12	| Register12			 |--> PSE Status register, read_only register 
//	13	| Register13			 |-->	MMD access control register,read and write register 
//	14	| Register14			 |--> MMD access address data register,read and write register 
//	15	| Register15			 |--> Reserved,Extended status register, read_only register 
//---------------------- 
// Addr | Data MEMORY      |-->  for testing 
// 
//-------------------------------------------------------------------- 
reg           control_bit15; // self clearing bit 
reg   [14:10] control_bit14_10; 
reg           control_bit9; // self clearing bit 
reg   [8:0]   control_bit8_0; 
// Status register 
reg   [15:9]  status_bit15_9;// = 7'h3F; 
reg           status_bit8;//    = 1'b0; 
reg           status_bit7 = 1'b0; // reserved 
reg   [6:0]   status_bit6_0	= 7'b0; 
// PHY ID register 1 
reg   [15:0]  phy_id1 = 16'h0013; 
// PHY ID register 2 
reg  	[15:0]  phy_id2 = {6'h1e,6'h0e,4'h2}; 
reg		[4:0]		phy_addr; 
//reg 	[15:0]	 register_9,register_13,register_11; 
//------------------------- 
reg		[15:0]	Register4; 
reg		[15:0]	Register5; 
reg		[15:0]	Register6; 
reg		[15:0]	Register7; 
reg		[15:0]	Register8; 
reg		[15:0]	Register9; 
reg		[15:0]	Register10; 
reg		[15:0]	Register11; 
reg		[15:0]	Register12; 
reg		[15:0]	Register13; 
reg		[15:0]	Register14; 
reg		[15:0]	Register15; 
//--------------------------- 
/*********************************************************************\ 
Signal and Register declare 
\*********************************************************************/ 
parameter 				FSM_JUDGE_ST_0		= 	9'h1; 
parameter 				FSM_JUDGE_ST_1		= 	9'h2; 
parameter 				FSM_JUDGE_OP_0		= 	9'h4; 
parameter 				FSM_JUDGE_OP_1		= 	9'h8; 
parameter 				FSM_RX_PHY_ADD		=		9'h10; 
parameter 				FSM_RX_REG_ADD		=		9'h20; 
parameter					FSM_JUDGE_TA_0		=		9'h40; 
parameter					FSM_JUDGE_TA_1		=		9'h80; 
parameter					FSM_DATA_STATE		= 	9'h100; 
//////////////////////////////////////////////////////////////////////// 
//////////////////////////////////////////////////////////////////////// 
reg 			 				mdio_output; 
reg				 				mdio_output_enable,mdio_output_enable_reg; 
reg				 				mdio_reg; 
reg[4:0]	 				phy_address; 
reg[4:0]	 				reg_address; 
reg[15:0]	 				reg_data_in; 
reg[15:0]	 				reg_data_out; 
reg[15:0]					register_bus_out; 
wire[15:0]				register_bus_in; 
reg[6:0] 					md_transfer_cnt; 
reg								md_transfer_cnt_reset; 
reg								mdio_rd_wr; 
reg								respond_to_all_phy_addr; 
reg 							md_put_reg_data_out; 
reg								md_get_phy_address; 
reg								md_get_reg_address; 
reg								md_get_reg_data_in; 
reg								md_put_reg_data_in; 
// 
reg[8:0]					state; 
//------------------------------------------------------------------- 
assign #1 mdio = mdio_output_enable ? mdio_output : 1'bz ; 
//input mdio register 
always @ ( posedge mdc_i  ) 
if( ~rst_n_i ) begin mdio_reg<=#1 1'b0;end 
else begin mdio_reg <= mdio;end 
// 
reg[3:0]	count; 
always @ ( posedge mdc_i) 
begin 
		if( ~rst_n_i ) 
		begin 
				phy_address	<= 5'b0; 
				reg_address	<= 5'b0; 
				reg_data_in	<= 16'b0; 
				reg_data_out	<= 16'b0; 
				mdio_output	<= 1'b0; 
				count				<= 4'hf; 
		end 
		else 
		begin 
				if( md_get_phy_address ) 
				begin 
						phy_address[4:1] <= phy_address[3:0]; 
      			phy_address[0]   <= mdio_reg; 
				end 
				//else 
				//; 
				// 
				if (md_get_reg_address) 
    		begin 
      			reg_address[4:1] <= reg_address[3:0]; 
      			reg_address[0]   <= mdio_reg; 
    		end 
    		//else 
    		//; 
 
    		if (md_get_reg_data_in) 
    		begin 
      			reg_data_in[15:1] <= reg_data_in[14:0]; 
      			reg_data_in[0]    <= mdio_reg; 
    		end 
    		//else 
    		//; 
    		// 
    		if (mdio_output_enable ) 
    		begin 
      			//mdio_output       <= register_bus_out(count); 
      			count							<= count - 1'b1; 
      			case( count ) 
      			4'h0:mdio_output	<=  register_bus_out[0]; 
      			4'h1:mdio_output	<=  register_bus_out[1]; 
						4'h2:mdio_output	<=  register_bus_out[2]; 
						4'h3:mdio_output	<=  register_bus_out[3]; 
      			4'h4:mdio_output	<=  register_bus_out[4]; 
      			4'h5:mdio_output	<=  register_bus_out[5]; 
						4'h6:mdio_output	<=  register_bus_out[6]; 
						4'h7:mdio_output	<=  register_bus_out[7]; 
						// 
						4'h8:mdio_output	<=  register_bus_out[8]; 
      			4'h9:mdio_output	<=  register_bus_out[9]; 
						4'ha:mdio_output	<=  register_bus_out[10]; 
						4'hb:mdio_output	<=  register_bus_out[11]; 
      			4'hc:mdio_output	<=  register_bus_out[12]; 
      			4'hd:mdio_output	<=  register_bus_out[13]; 
						4'he:mdio_output	<=  register_bus_out[14]; 
						4'hf:mdio_output	<=  register_bus_out[15]; 
						endcase 
      			// 
    		end 
    		else 
    		begin 
    				count	<= 4'hf; 
    		end 
		end 
end 
// 
assign #1 register_bus_in = reg_data_in; 
// 
always @( posedge mdc_i  ) 
begin 
		if( ~rst_n_i ) 
		begin 
				md_transfer_cnt <= 7'd33; 
		end 
		else 
		begin 
				if( md_transfer_cnt_reset ) 
				begin 
						md_transfer_cnt <= 7'd33; 
				end 
				else if( md_transfer_cnt < 7'd64 ) 
				begin 
						md_transfer_cnt <= md_transfer_cnt + 1'b1; 
				end 
				else 
				begin 
						md_transfer_cnt <= 7'd33; 
				end 
		end 
end 
// 
always @( posedge mdc_i ) 
begin 
		if( ~rst_n_i ) 
		begin 
				respond_to_all_phy_addr	<= 1'b0; 
				mdio_output_enable			<= 1'b0; 
				md_transfer_cnt_reset		<= 1'b1; 
				md_get_phy_address			<= 1'b0; 
				md_get_reg_address			<= 1'b0; 
				md_put_reg_data_out			<= 1'b0; 
				md_get_reg_data_in			<= 1'b0; 
				md_put_reg_data_in			<= 1'b0; 
				mdio_rd_wr							<= 1'b0; 
				state										<= FSM_JUDGE_ST_0; 
		end 
		else 
		begin 
				case( state ) 
				// 
				FSM_JUDGE_ST_0: 
				begin 
						md_put_reg_data_in <= 1'b0; 
						if( mdio_reg !== 1'b0 ) 
						begin 
								md_transfer_cnt_reset 	<= 1'b1; 
						end 
						else 
						begin 
								md_transfer_cnt_reset 	<= 1'b0; 
								state										<= FSM_JUDGE_ST_1; 
						end 
				end 
				// 
				FSM_JUDGE_ST_1: 
				begin 
						if( mdio_reg !== 1'b1) 
						begin 
								md_transfer_cnt_reset 	<= 1'b1; 
								state										<= FSM_JUDGE_ST_0; 
						end 
						else 
						begin 
								md_transfer_cnt_reset 	<= 1'b0; 
								state										<= FSM_JUDGE_OP_0; 
						end 
				end 
				// 
				FSM_JUDGE_OP_0: 
				begin 
						state												<= FSM_JUDGE_OP_1; 
						if( mdio_reg === 1'b1 )	begin mdio_rd_wr 	<= 1'b1;end 
						else begin mdio_rd_wr 	<= 1'b0;end 
				end 
				// 
				FSM_JUDGE_OP_1: 
				begin 
						md_get_phy_address <= 1'b1; 
						if((mdio_reg === 1'b0) && (mdio_rd_wr == 1'b1)) 
						begin 
								mdio_rd_wr							<= 1'b1; 
								state										<= FSM_RX_PHY_ADD; 
						end 
						else if((mdio_reg === 1'b1) && (mdio_rd_wr == 1'b0)) 
						begin 
								mdio_rd_wr							<= 1'b0; 
								state										<= FSM_RX_PHY_ADD; 
						end 
						else 
						begin 		//FSM_RX_PHY_ADD 
								md_transfer_cnt_reset 	<= 1'b1; 
								state										<= FSM_JUDGE_ST_0; 
						end 
				end 
				// 
				FSM_RX_PHY_ADD: 
				// 
				begin 
						if( md_transfer_cnt == 7'd40 ) 
						begin 
								md_get_phy_address 			<= 1'b0; 
								md_get_reg_address 			<= 1'b1; 
								//md_put_reg_data_out 		<= 1'b1; 
								state										<= FSM_RX_REG_ADD; 
						end 
						//else 
						//; 
				end 
				// 
				FSM_RX_REG_ADD: 
				// 
				begin 
						if( md_transfer_cnt == 7'd45 ) 
				   	begin 
				   			md_get_reg_address 			<= 1'b0; 
								state										<= FSM_JUDGE_TA_0; 
								if(mdio_rd_wr) 
								begin 
										mdio_output_enable 			<= 1'b1; 
										md_put_reg_data_out 		<= 1'b1; 
								end 
								//else 
								//; 
						end 
						//else 
						//; 
				end 
				// 
				FSM_JUDGE_TA_0: 
				begin 
						md_put_reg_data_out <= 1'b0; 
						if( mdio_rd_wr)	//read 
						begin 
								if( phy_address == phy_addr ) 
								begin 
										mdio_output_enable 			<= 1'b1; 
										state										<= FSM_DATA_STATE; 
								end 
								else 
								begin 
										mdio_output_enable 			<= 1'b0; 
										state										<= FSM_JUDGE_ST_0; 
								end 
						end 
						else	// write 
						begin 
								mdio_output_enable 					<= 1'b0; 
								if( mdio_reg !== 1'b1 ) 
								begin 
										md_transfer_cnt_reset 	<= 1'b1; 
										state 									<= FSM_JUDGE_ST_0; 
								end 
								else 
								begin 
										md_transfer_cnt_reset 	<= 1'b0; 
										state										<= FSM_JUDGE_TA_1; 
								end 
						end 
				end 
				// 
				FSM_JUDGE_TA_1: 
				begin 
						if( mdio_rd_wr == 1'b0 ) 
						begin 
								md_get_reg_data_in <= 1'b1; 
								if( mdio_reg !== 1'b0 ) 
								begin 
										md_transfer_cnt_reset	 <= 1'b1; 
										state										<= FSM_JUDGE_ST_0; 
								end 
								else 
								begin 
								   	state	<= FSM_DATA_STATE; 
								end 
						end 
						else 
						begin 
								md_get_reg_data_in 			<= 1'b0; 
								state										<= FSM_DATA_STATE; 
						end 
				end 
				// 
				FSM_DATA_STATE: 
				begin 
						if( md_transfer_cnt == 7'd63 & mdio_rd_wr	== 1'b0) 
						begin 
								state										<= FSM_JUDGE_ST_0; 
								mdio_output_enable 			<= 1'b0; 
								md_get_reg_data_in 			<= 1'b0; 
								md_transfer_cnt_reset 	<= 1'b1; 
								mdio_rd_wr							<= 1'b0; 
								if (phy_address === phy_addr) 
								begin 
								 		md_put_reg_data_in <= 1'b1; 
								end 
								//else 
								//	 ; 
						end 
						else if( md_transfer_cnt == 7'd62 & mdio_rd_wr	== 1'b1  ) 
						begin 
								state										<= FSM_JUDGE_ST_0; 
								mdio_output_enable 			<= 1'b0; 
								md_get_reg_data_in 			<= 1'b0; 
								md_transfer_cnt_reset 	<= 1'b1; 
								mdio_rd_wr							<= 1'b0; 
						end 
						//else 
						//; 
				end 
				// 
				default: 
				begin 
						state										<= FSM_JUDGE_ST_0; 
				end 
				endcase 
		end 
end 
// 
// 
//always @ (rst_n_i or reg_address or md_put_reg_data_out or control_bit15 
//			or control_bit14_10 or control_bit9 or control_bit8_0 
//			or status_bit15_9 or status_bit8 or status_bit7 or status_bit6_0 
//			or phy_id1 or phy_id2 or Register4 or Register5 or Register6 
//			or Register7 or Register8 or Register9 or Register10 
//			or Register11 or Register12 or Register13 or Register14 or Register15) 
always@(posedge mdc_i) 
begin 
		if( ~rst_n_i ) 
		begin 
				register_bus_out =#1 16'h0; 
		end 
		else if (md_put_reg_data_out) // read enable 
    begin 
      	case (reg_address) 
      	5'h0:    register_bus_out = #1 {control_bit15, control_bit14_10, control_bit9, control_bit8_0}; 
      	5'h1:    register_bus_out = #1 {status_bit15_9, status_bit8, status_bit7, status_bit6_0}; 
      	5'h2:    register_bus_out = #1 phy_id1; 
      	5'h3:    register_bus_out = #1 phy_id2; 
      	// 
      	5'h4:		 register_bus_out = #1 Register4; 
				5'h5:		 register_bus_out = #1 Register5; 
				5'h6:		 register_bus_out = #1 Register6; 
				5'h7:		 register_bus_out = #1 Register7; 
				// 
				5'h8:		 register_bus_out = #1 Register8; 
				5'h9:		 register_bus_out = #1 Register9; 
				5'ha:		 register_bus_out = #1 Register10; 
				5'hb:		 register_bus_out = #1 Register11; 
				// 
				5'hc:		 register_bus_out = #1 Register12; 
				5'hd:		 register_bus_out = #1 Register13; 
				5'he:		 register_bus_out = #1 Register14; 
				5'hf:		 register_bus_out = #1 Register15; 
      	default: register_bus_out = #1 16'hDEAD; 
      	endcase 
    end 
    //else 
    //; 
end 
// 
// Self clear control signals 
reg    self_clear_d0; 
reg    self_clear_d1; 
reg    self_clear_d2; 
reg    self_clear_d3; 
// Self clearing control 
always @ ( posedge mdc_i or negedge rst_n_i ) 
begin 
  	if (!rst_n_i) 
  	begin 
    		self_clear_d0    <= #1 1'b0; 
    		self_clear_d1    <= #1 1'b0; 
    		self_clear_d2    <= #1 1'b0; 
    		self_clear_d3    <= #1 1'b0; 
  	end 
  	else 
  	begin 
    		self_clear_d0    <= #1 md_put_reg_data_in; 
    		self_clear_d1    <= #1 self_clear_d0; 
    		self_clear_d2    <= #1 self_clear_d1; 
    		self_clear_d3    <= #1 self_clear_d2; 
  	end 
end 
// 
// Writing to a selected register 
always@(posedge mdc_i or negedge rst_n_i) 
begin 
  	if ((!rst_n_i) || (control_bit15)) 
  	begin 
      	control_bit15    <= #1 1'b0; 
      	control_bit14_10 <= #1 5'd0; 
      	control_bit9     <= #1 1'b0; 
      	control_bit8_0   <= #1 9'b0; 
				// 
				Register4  			 <= #1 16'b0; 
				Register7  			 <= #1 16'b0; 
				Register9  			 <= #1 16'b0; 
				Register11			 <= #1 16'b0; 
				Register13  		 <= #1 16'b0; 
				Register14 			 <= #1 16'b0; 
  	end 
  	else 
  	begin 
      	// bits that are normaly written 
      	if (md_put_reg_data_in) 
      	begin 
        		case (reg_address) 
        		5'h0:begin control_bit14_10 <= #1 register_bus_in[14:10];control_bit9 <= #1 register_bus_in[9];control_bit8_0 <= #1 register_bus_in[8:0];end 
        		5'h4:begin Register4	<= #1 register_bus_in;end 
        		5'h7:begin Register7	<= #1 register_bus_in;end 
						5'h9:begin Register9	<= #1 register_bus_in;end 
        		5'hb:begin Register11	<= #1 register_bus_in;end 
        		5'hd:begin Register13	<= #1 register_bus_in;end 
        		5'he:begin Register14	<= #1 register_bus_in;end 
        		default:begin        												end 
        		endcase 
      	end 
      	//else 
      	//; 
      	// self cleared bits written 
      	if ((md_put_reg_data_in) && (reg_address == 5'h0)) 
      	begin control_bit15 <= #1 register_bus_in[15];control_bit9  <= #1 register_bus_in[9];end 
      	else if (self_clear_d3) // self cleared bits cleared 
      	begin control_bit15 <= #1 1'b0;control_bit9 <= #1 1'b0;end 
      	//else 
      	//; 
      	// 
    end 
end 
//--------------------------------------------------- 
//wishbone interface 
always @( we_i or strobe_i or address_i or rst_i ) 
if( rst_i )	begin ack_o <= 1'b0;end 
else begin ack_o	<= strobe_i;end 
// 
always @( posedge clk_i) 
begin 
    if( rst_i == 1'b1 ) 
    begin 
				status_bit15_9 	<= 7'h0; 
				status_bit8			<= 1'b0; 
				status_bit7 		<= 1'b0; 
				status_bit6_0		<= 7'h0; 
				phy_id1					<= 16'h0; 
				phy_id2					<= 16'h0; 
				phy_addr			<= 5'd0; 
				Register5				<= 16'd0; 
				Register6				<= 16'd0; 
				Register8				<= 16'd0; 
				Register10			<= 16'd0; 
				Register12			<= 16'd0; 
				Register15			<= 16'd0; 
    end 
    else 
    begin 
    		if ( we_i == 1'b1 && strobe_i == 1'b1 ) 
    		begin 
    				case ( address_i ) 
    				8'h2: begin status_bit15_9<= data_i[7:1];status_bit8<= data_i[0];end 
    				8'h3: begin status_bit7<= data_i[7];status_bit6_0<= data_i[6:0];end 
    				8'h4:	begin phy_id1[15:8]<= data_i;end 
    				8'h5:	begin phy_id1[7:0]<= data_i;end 
    				8'h6:	begin phy_id2[15:8]<= data_i;end 
    				8'h7:	begin phy_id2[7:0]<= data_i;end 
    				8'ha: begin Register5[15:8]<= data_i;end 
    				8'hb: begin Register5[7:0]<= data_i;end 
    				8'hc: begin Register6[15:8]<= data_i;end 
    				8'hd: begin	Register6[7:0]<= data_i;end 
    			 8'h10: begin Register8[15:8]<= data_i;end 
    			 8'h11: begin Register8[7:0]<= data_i;end 
    			 8'h14: begin Register10[15:8]<= data_i;end 
					 8'h15: begin Register10[7:0]<= data_i;end 
    			 8'h18: begin Register12[15:8]<= data_i;end 
					 8'h19: begin Register12[7:0]<= data_i;end 
					 8'h1E: begin Register15[15:8]<= data_i;end 
					 8'h1F: begin Register15[7:0]<= data_i;end 
    			 8'h40: begin phy_addr<= data_i[4:0];end 
    				default:begin  					end 
    				endcase 
    		end 
    		//else 
    		//; 
    end 
end 
 
always @(rst_i or we_i or address_i or control_bit15 or control_bit14_10 or control_bit9 or control_bit8_0 
				or status_bit15_9 or status_bit8 or  status_bit7 or  status_bit6_0 or phy_id1 or phy_id2 or phy_addr 
				or Register4 or Register5 or Register6 or Register7 or Register8 or Register9 or Register10 or Register11  
				or Register12 or Register13 or Register14 or Register15  
				) 
//always @( posedge clk_i ) 
begin 
		if( rst_i == 1'b1 ) 
		begin 
		    data_o	 <= 8'h0; 
		end 
		else 
		begin 
				case( address_i) 
				8'h0:data_o	<= {control_bit15, control_bit14_10, control_bit9, control_bit8_0[8]}; 
				8'h1:data_o	<= {control_bit8_0[7:0]}; 
				8'h2:data_o	<= {status_bit15_9, status_bit8}; 
				8'h3:data_o	<= {status_bit7, status_bit6_0}; 
				8'h4:data_o	<= phy_id1[15:8]; 
				8'h5:data_o	<= phy_id1[7:0]; 
				8'h6:data_o	<= phy_id2[15:8]; 
				8'h7:data_o	<= phy_id2[7:0]; 
				8'h8:data_o <= Register4[15:8]; 
				8'h9:data_o <= Register4[7:0]; 
				8'ha:data_o <= Register5[15:8]; 
    		8'hb:data_o <= Register5[7:0]; 
    		8'hc:data_o <= Register6[15:8]; 
    		8'hd:data_o	<= Register6[7:0]; 
    		8'he:data_o <= Register7[15:8]; 
   			8'hf:data_o <= Register7[7:0]; 
   			8'h10:data_o <= Register8[15:8]; 
   			8'h11:data_o <= Register8[7:0]; 
   			8'h12:data_o <= Register9[15:8]; 
   			8'h13:data_o <= Register9[7:0]; 
   			8'h14:data_o <= Register10[15:8]; 
	 			8'h15:data_o <= Register10[7:0]; 
	 			8'h16:data_o <= Register11[15:8]; 
	 			8'h17:data_o <= Register11[7:0]; 
   			8'h18:data_o <= Register12[15:8]; 
	 			8'h19:data_o <= Register12[7:0]; 
	 			8'h1A:data_o <= Register13[15:8]; 
	 			8'h1B:data_o <= Register13[7:0]; 
	 			8'h1C:data_o <= Register14[15:8]; 
	 			8'h1D:data_o <= Register14[7:0]; 
	 			8'h1E:data_o <= Register15[15:8]; 
	 			8'h1F:data_o <= Register15[7:0]; 
	 			8'h40:data_o <= {3'b0,phy_addr}; 
 				default:data_o <= 8'h00; 
	 			endcase 
	 	end 
end 
// 
endmodule