library verilog;
use verilog.vl_types.all;
entity FA is
    port(
        s               : out    vl_logic;
        Carry_out       : out    vl_logic;
        x               : in     vl_logic;
        y               : in     vl_logic;
        Carry_in        : in     vl_logic
    );
end FA;
