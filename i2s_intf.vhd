library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity i2s_master_intf is
	Port (
		I2S_SYSCLK: in std_logic; -- System clock (24.576MHz)
		I2S_DATA: in std_logic;
		
		I2S_MCLK: out std_logic; -- Master clock
		I2S_LRCLK: out std_logic; -- Word clock
		I2S_BCLK: out std_logic -- Bit clock - 32bit per sample (24bit + 8bit padding), dual channel
	);
end i2s_master_intf;

architecture rtl of i2s_master_intf is
	signal i_sysclk: std_logic;
	signal i_mclk: std_logic;
	signal i_lrclk: std_logic;
	signal i_bclk: std_logic;
	
	signal sr: std_logic_vector(31 downto 0);
	signal sr_out: std_logic;
begin
	I2S_SYSCLK_IBUF: IBUF
		port map (
			I => I2S_SYSCLK,
			O => i_sysclk
		);

	clk_gen : entity work.clk_gen(rtl)
		port map (
			in_clk => i_sysclk,
			clk_div1 => i_mclk,
			clk_div64 => i_bclk,
			clk_div512 => i_lrclk 
		);

	shift_in: process(i_mclk, i_lrclk, i_bclk)
	begin
		if rising_edge(i_bclk) then
			sr <= sr(sr'high - 1 downto sr'low) & I2S_DATA;
			sr_out <= sr(sr'high);
		end if;
	end process;
	
	I2S_MCLK <= i_mclk;
	I2S_LRCLK <= i_lrclk;
	I2S_BCLK <= i_bclk;

end rtl;

