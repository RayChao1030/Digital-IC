library verilog;
use verilog.vl_types.all;
entity RCA is
    port(
        s               : out    vl_logic_vector(7 downto 0);
        Carry_out       : out    vl_logic;
        x               : in     vl_logic_vector(7 downto 0);
        y               : in     vl_logic_vector(7 downto 0);
        Carry_in        : in     vl_logic
    );
end RCA;
