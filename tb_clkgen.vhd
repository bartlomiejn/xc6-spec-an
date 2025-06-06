library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
 
entity tb_clkgen is
end tb_clkgen;
 
architecture test of tb_clkgen is 
	--inputs
	signal in_clk : std_logic := '0';
	signal in_rst : std_logic := '0';

 	--outputs
	signal clk_div1 : std_logic;
	signal clk_div2 : std_logic;
	signal clk_div128 : std_logic;
	
	signal cnt_div1 : integer := 0;
	signal cnt_div2 : integer := 0;
	signal cnt_div128 : integer := 0;

	constant in_clk_period : time := 20.35 ns;
	constant reset_period : time := 100 ns;
	constant test_period : time := in_clk_period * 1024;
	
begin
	uut: entity work.clkgen(rtl) port map (
		in_clk => in_clk,
		reset => in_rst,
		clk_div1 => clk_div1,
		clk_div2 => clk_div2,
		clk_div128 => clk_div128
	);

	input_clock: process
	begin
		in_clk <= '0';
		wait for in_clk_period;
		in_clk <= '1';
		wait for in_clk_period;
	end process;
	
	count_div1: process(clk_div1)
	begin
		if rising_edge(clk_div1) then
			cnt_div1 <= cnt_div1 + 1;
		end if;
	end process;
	
	count_div2: process(clk_div2)
	begin
		if rising_edge(clk_div2) then
			cnt_div2 <= cnt_div2 + 1;
		end if;
	end process;
	
	count_div128: process(clk_div128)
	begin
		if rising_edge(clk_div128) then
			cnt_div128 <= cnt_div128 + 1;
		end if;
	end process;

	stimulus: process
	begin
		in_rst <= '1';
		wait for reset_period;
		in_rst <= '0';
		
		assert cnt_div1 = 0 and cnt_div2 = 0 and cnt_div128 = 0
			report "Clocks should not pulse when reset is asserted"
			severity error;

		wait for test_period;

		assert cnt_div1 = 512 and cnt_div2 = 256 and cnt_div128 = 4
			report "Output clocks did not pulse expected number of times"
			severity error;
			
		wait;
	end process;

	report_results: process
		variable L: line;
	begin
		wait for test_period + reset_period;
		
		write(L, string'("div1 ticks: "));
		write(L, cnt_div1);
		writeline(output, L);

		write(L, string'("div2 ticks: "));
		write(L, cnt_div2);
		writeline(output, L);

		write(L, string'("div128 ticks: "));
		write(L, cnt_div128);
		writeline(output, L);

		wait;
	end process;

end;
