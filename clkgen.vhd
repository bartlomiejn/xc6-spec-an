library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkgen is
	port (
		reset: in std_logic;
		in_clk: in std_logic; 
		
		clk_div1: out std_logic;
		clk_div64: out std_logic; 
		clk_div512: out std_logic
	);
end clkgen;

architecture rtl of clkgen is
	signal counter: unsigned(8 downto 0) := (others => '0');
	signal i_clk: std_logic := '0';
begin
	process (reset, in_clk)
	begin
		if reset = '1' then
			counter <= (others => '0');
			i_clk <= '0';
		else
			i_clk <= in_clk;
			if rising_edge(in_clk) then
				counter <= counter + 1;
			end if;
		end if;
	end process;

	clk_div1 <= i_clk;
	clk_div64 <= counter(5);
	clk_div512 <= counter(8);

end rtl;

