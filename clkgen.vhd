library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkgen is
	port (
		reset: in std_logic;
		in_clk: in std_logic; 
		
		clk_div1: out std_logic;
		clk_div2: out std_logic; 
		clk_div128: out std_logic
	);
end clkgen;

architecture rtl of clkgen is
	signal counter: unsigned(6 downto 0) := (others => '0');
	signal i_clk: std_logic := '0';
begin

	count_in_clk: process (reset, in_clk)
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
	clk_div2 <= not(counter(0));
	
	gen_clk_div128: process (reset, in_clk)
	begin
		if reset = '1' then
			clk_div128 <= '0';
		elsif falling_edge(in_clk) then
			clk_div128 <= std_logic(counter(6));
		end if;
	end process;

end rtl;

