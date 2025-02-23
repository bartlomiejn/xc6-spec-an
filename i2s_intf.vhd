library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2s_master_intf is
	Port (
		sysclk: in std_logic; -- System clock (24.576MHz)
		data: in std_logic;
		
		mclk: out std_logic; -- Master clock
		lrclk: out std_logic; -- Word clock
		bclk: out std_logic -- Bit clock - 32bit per sample (24bit + 8bit padding), dual channel
		
		
	);
end i2s_master_intf;

architecture rtl of i2s_master_intf is
	signal i_mclk: std_logic;
	signal i_lrclk: std_logic;
	signal i_bclk: std_logic;
	
	signal sr: std_logic_vector(31 downto 0) := (others => "0");
	signal sr_out: std_logic;
begin
	clk_gen : entity clk_gen(rtl)
		port map (
			in_clk => sysclk,
			clk_div1 => i_mclk,
			clk_div64 => i_bclk,
			clk_div512 => i_lrclk 
		);

	process(i_mclk, i_lrclk, i_bclk)
	begin
		if rising_edge(i_bclk) then
			sr_in <= sr_in(sr'high - 1 downto sr'low) & data;
			sr_out <= sr(sr'high);
		end if;
	end process;
	
	mclk <= i_mclk;
	lrclk <= i_lrclk;
	bclk <= i_bclk;

end rtl;

