module rx(
		input CLK, RST, RX,
		input [1:0] MODE,
		output reg DATA_DONE,
		output reg [7:0] DATA,
		output reg PARITY
	);
	
	typedef enum logic [2:0] {
		rx_idle,
		rx_data,
		rx_parity
	} state_t;
	
	parameter M8N1 = 00,
	          M8E1 = 01,
			    M8O1 = 11;
				 
	state_t rx_state;
	
	reg [4:0] sample_count;
	reg [2:0] data_buffer_pos;
	
	always@(posedge CLK or negedge RST) begin
		if (~RST) begin
			rx_state <= rx_idle;
			sample_count <= 5'b0;
			data_buffer_pos <= 3'b0;
			DATA_DONE <= 1'b0;
			
		end else begin	
			sample_count <= sample_count + 5'd1;
			
			case (rx_state)
				rx_idle:
					begin
						if (RX) begin
							sample_count <= 5'b0;
							data_buffer_pos <= 3'b0;
							rx_state <= rx_data;
						end
						
						DATA_DONE <= 1'b0;
					end
					
				rx_data:
					begin
						if (sample_count == 5'd16) begin
							DATA[data_buffer_pos] <= RX;
							data_buffer_pos <= data_buffer_pos + 3'd1;
							
							if (data_buffer_pos == 3'd7) begin
								if (MODE == M8N1) begin
									DATA_DONE <= 1'b1;
									rx_state <= rx_idle;
								end else begin
									rx_state <= rx_parity;
								end
							end
						end
					end
					
				rx_parity:
					begin
						if (sample_count == 5'd16) begin
							PARITY <= RX;
							DATA_DONE <= 1'b1;
							rx_state <= rx_idle;
						end
					end
					
				default:
					begin
						rx_state <= rx_idle;
						sample_count <= 5'b0;
						data_buffer_pos <= 3'b0;
						DATA_DONE <= 1'b0;
					end
			endcase
		end
	end
	
endmodule 