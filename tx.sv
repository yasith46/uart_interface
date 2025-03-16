module tx(
		input CLK, BAUD, RST, DATA_AVAILABLE,
		input [7:0] DATA,
		input  [1:0] MODE,
		output reg TX,BUSY
	);
	
	typedef enum logic [3:0] {
		tx_idle,
		tx_start,
		tx_send,
		tx_parity,
		tx_stop
	} state_t;
	
	state_t tx_state;
	
	parameter M8N1 = 00,
	          M8E1 = 01,
			    M8O1 = 11;
	
	reg [7:0] buffer;
	reg [2:0] count;
	
	wire parity;
	assign parity = ~(^buffer);
	
	always@(posedge CLK or negedge RST) begin
		if (~RST) begin
			TX <= 1'b1;
			BUSY <= 1'b0;
			buffer <= 8'b0;
			tx_state <= tx_idle;
			count <= 3'b0;
		end else begin
			case (tx_state)
				tx_idle:
					begin
						TX <= 1'b1;
						if (DATA_AVAILABLE) begin
							tx_state <= tx_start;
							BUSY <= 1'b1;
						end else begin
							BUSY <= 1'b0;
						end
					end
					
				tx_start:
					begin
						TX <= 1'b0;
						buffer <= DATA;
						if (BAUD) tx_state <= tx_send;
					end
					
				tx_send:
					begin
						TX <= buffer[count];
						if (count == 3'd7) begin
							if (BAUD) begin
								count <= 3'b0;
								
								if (MODE == M8N1) 
									tx_state <= tx_stop;
								else
									tx_state <= tx_parity;
							end
						end else begin
							if (BAUD) count <= count + 3'd1;
						end
					end
					
				tx_parity:
					begin
						if (MODE == M8E1)
							TX <= parity;
						else
							TX <= ~parity;
							
						if (BAUD) tx_state <= tx_stop;
					end
					
				tx_stop:
					begin
						TX <= 1'b1;
						if (BAUD) begin
							tx_state <= tx_idle;
							BUSY <= 1'b0;
						end
					end
					
				default:
					begin
						TX <= 1'b1;
						BUSY <= 1'b0;
						tx_state <= tx_idle;
					end
			endcase
		end
	end

endmodule 