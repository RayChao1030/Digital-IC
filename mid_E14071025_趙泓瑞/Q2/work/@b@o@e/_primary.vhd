library verilog;
use verilog.vl_types.all;
entity BOE is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        data_num        : in     vl_logic_vector(2 downto 0);
        data_in         : in     vl_logic_vector(7 downto 0);
        result          : out    vl_logic_vector(10 downto 0)
    );
end BOE;
