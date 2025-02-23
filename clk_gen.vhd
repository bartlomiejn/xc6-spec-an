library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_gen is
	Port (
		in_clk: in std_logic; 
		
		clk_div1: out std_logic;
		clk_div64: out std_logic; 
		clk_div512: out std_logic
	);
end clk_gen;

architecture rtl of clk_gen is
	signal counter: unsigned(8 downto 0) := (others => "0");
begin
	process (in_clk)
	begin
		if rising_edge(in_clk) then
			counter <= counter + 1;
		end if;
	end process;

	clk_div1 <= o_mclk;
	clk_div64 <= counter(5);
	clk_div512 <= counter(8);

end rtl;

