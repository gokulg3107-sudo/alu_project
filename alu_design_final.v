module alu_design #(parameter size = 4, size_cmd = 4)(clk, rst, ce, inp_valid, mode, cmd, opa, opb, cin, err, res, oflow, cout, g, l, e);
input clk, rst, ce, cin, mode;

input [1:0] inp_valid;
input [size_cmd - 1: 0] cmd;
input [size - 1: 0] opa, opb;
output reg [2 * size - 1: 0] res;
output reg oflow, err, g, l, e;
output cout;

wire clk_gated;
assign clk_gated = clk & ce;

reg [1:0] count;
reg [2 * size - 1: 0] temp;
reg [size - 1: 0] temp_opa, temp_opb;
reg temp_err;

assign cout = (err) ? 1'b0 :
              (mode) ? ((cmd == 0 || cmd == 2) ? res[size] : 1'b0)
                     : 1'b0;
always@(*)begin
        case(cmd)
                1: oflow = (opa < opb) & mode;
                3: oflow = ((opa < opb) | (opa == opb & cin == 1)) & mode;
                default: oflow = 1'b0;
        endcase
end

always @(posedge clk or posedge rst)begin
        if(rst)begin
                count <= 2'd0;
        end
        else begin
                if (cmd == 9 | cmd == 10)begin
                        if (count == 2'd2) count <= 0;
                        else count <= count + 1;
                end
                else count <= 0;
        end
end

always @(posedge clk or posedge rst)begin
        if(rst) begin
                res <= {2 * size{1'b0}};
                {err, g, l, e} <= 4'd0;
        end
        else if(mode) begin
                err <= 1'b0;
                {g, l, e} <= 3'd0;
                case(cmd)
                0: begin
                        if(inp_valid == 2'b11)
                                res <= opa + opb;
                        else err <= 1'b1;
                end
                1: begin
                        if(inp_valid == 2'b11)
                                res <= opa - opb;
                        else err <= 1'b1;
                end
                2: begin
                        if(inp_valid == 2'b11)
                                res <= opa + opb + cin;
                        else err <= 1'b1;
                end
                3: begin
                        if(inp_valid == 2'b11)
                                res <= opa - opb - cin;
                        else err <= 1'b1;
                end
                4: begin
                        if(inp_valid[0] == 1'b1) res <= opa + 1'b1;
                        else err <= 1'b1;
                end
                5: begin
                        if(inp_valid[0] == 1'b1) res <= opa - 1'b1;
                        else err <= 1'b1;
                end
                6: begin
                        if(inp_valid[1] == 1'b1) res <= opb + 1'b1;
                        else err <= 1'b1;
                end
                7: begin
                        if(inp_valid[1] == 1'b1) res <= opb - 1'b1;
                        else err <= 1'b1;
                end
                8: begin
                        res <= 0;
                        if(inp_valid == 2'b11)begin
                                if (opa == opb) {g, l, e} <= 3'b001;
                                else if (opa > opb) {g, l, e} <= 3'b100;
                                else {g, l, e} <= 3'b010;
                        end
                        else err <= 1'b1;
                end
                9: begin
                        if(count == 0) begin
                                if(inp_valid == 2'b11) begin
                                    temp     <= (opa + 1) * (opb + 1);
                                    temp_opa <= opa; // capture for pipelining if needed
                                    temp_err <= 1'b0;
                                end
                                else
                                    temp_err <= 1'b1;
                        end
                        else if(count == 1) begin
                        end
                        else if(count == 2) begin
                                err <= temp_err;
                                res <= temp;
                                if(inp_valid == 2'b11) begin
                                    temp     <= (opa + 1) * (opb + 1);
                                    temp_opa <= opa;
                                    temp_err <= 1'b0;
                                end
                                else temp_err <= 1'b1;
                        end
                end

                10: begin
                        if(count == 0) begin
                                if(inp_valid == 2'b11) begin
                                        temp     <= (opa << 1) * opb;
                                        temp_err <= 1'b0;
                                end
                                else temp_err <= 1'b1;
                        end
                        else if(count == 1) begin
                        end
                        else if(count == 2) begin
                                err <= temp_err;
                                res <= temp;

                                if(inp_valid == 2'b11) begin
                                        temp     <= (opa << 1) * opb;
                                        temp_err <= 1'b0;
                                end
                                else temp_err <= 1'b1;
                        end
                end
                11: begin
                        if(inp_valid == 2'b11) begin
                                res <= $signed(opa) + $signed(opb);
                                if ($signed(opa) == $signed(opb))      {g,l,e} <= 3'b001;
                                else if ($signed(opa) > $signed(opb))  {g,l,e} <= 3'b100;
                                else                                    {g,l,e} <= 3'b010;
                        end
                        else err <= 1;
                end
                12: begin
                        if(inp_valid == 2'b11) begin
                                res <= $signed(opa) - $signed(opb);
                                if ($signed(opa) == $signed(opb))      {g,l,e} <= 3'b001;
                                else if ($signed(opa) > $signed(opb))  {g,l,e} <= 3'b100;
                                else                                    {g,l,e} <= 3'b010;
                        end
                        else err <= 1;
                end
                endcase
        end

        else begin
                err <= 1'b0;
                {g, l, e} <= 3'd0;
                case(cmd)
                0: begin
                        if(inp_valid == 2'b11) res <= {{size{1'b0}}, opa & opb};
                        else err <= 1'b1;
                end
                1: begin
                        if(inp_valid == 2'b11) res <= {{size{1'b0}}, ~(opa & opb)};
                        else err <= 1'b1;
                end
                2: begin
                        if(inp_valid == 2'b11) res <= {{size{1'b0}}, (opa | opb)};
                        else err <= 1'b1;
                end
                3: begin
                        if(inp_valid == 2'b11) res <= {{size{1'b0}}, ~(opa | opb)};
                        else err <= 1'b1;
                end
                4: begin
                        if(inp_valid == 2'b11) res <= {{size{1'b0}}, (opa ^ opb)};
                        else err <= 1'b1;
                end
                5: begin
                        if(inp_valid == 2'b11) res <= {{size{1'b0}}, (opa ~^ opb)};
                        else err <= 1'b1;
                end
                6: begin
                        if(inp_valid[0] == 1'b1) res <= {{size{1'b0}}, (~opa)};
                        else err <= 1'b1;
                end
                7: begin
                        if(inp_valid[1] == 1'b1) res <= {{size{1'b0}}, (~opb)};
                        else err <= 1'b1;
                end
                8: begin
                        if(inp_valid[0] == 1'b1) res <= {{size{1'b0}}, (opa >> 1)};
                        else err <= 1'b1;
                end
                9: begin
                        if(inp_valid[1] == 1'b1) res <= {{size{1'b0}}, (opa << 1)};
                        else err <= 1'b1;
                end
                10: begin
                        if(inp_valid[0] == 1'b1) res <= {{size{1'b0}}, (opb >> 1)};
                        else err <= 1'b1;
                end
                11: begin
                        if(inp_valid[1] == 1'b1) res <= {{size{1'b0}}, (opb << 1)};
                        else err <= 1'b1;
                end
                12: begin
                        if(inp_valid == 2'b11)begin
                                if (|opb[size-1:3]) err <= 1;
                                else begin
                                case(opb[2:0])
                                        0: res <= {{size{1'b0}}, (opa )};
                                        1: res <= {{size{1'b0}}, (opa << 1)};
                                        2: res <= {{size{1'b0}}, (opa << 2)};
                                        3: res <= {{size{1'b0}}, (opa << 3)};
                                        4: res <= {{size{1'b0}}, (opa << 4)};
                                        5: res <= {{size{1'b0}}, (opa << 5)};
                                        6: res <= {{size{1'b0}}, (opa << 6)};
                                        7: res <= {{size{1'b0}}, (opa << 7)};
                                        default: res <= {{size{1'b0}}, (opa )};
                                endcase
                                end
                        end
                        else err <= 1'b1;
                end
                13: begin
                        if(inp_valid == 2'b11)begin
                                if (|opb[size-1:3]) err <= 1;
                                else begin
                                        case(opb[2:0])
                                        0: res <= {{size{1'b0}}, (opa )};
                                        1: res <= {{size{1'b0}}, (opa >> 1)};
                                        2: res <= {{size{1'b0}}, (opa >> 2)};
                                        3: res <= {{size{1'b0}}, (opa >> 3)};
                                        4: res <= {{size{1'b0}}, (opa >> 4)};
                                        5: res <= {{size{1'b0}}, (opa >> 5)};
                                        6: res <= {{size{1'b0}}, (opa >> 6)};
                                        7: res <= {{size{1'b0}}, (opa >> 7)};
                                        default: res <= {{size{1'b0}}, (opa)};
                                endcase
                                end
                        end
                        else err <= 1'b1;
                end
                endcase
        end
end
endmodule
