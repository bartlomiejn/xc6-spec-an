library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity i2s_rcvr is
	Port (
		I2S_I_RESET: in std_logic;
		I2S_I_SYSCLK: in std_logic; -- System clock (24.576MHz)
		I2S_I_DATA: in std_logic; 
		I2S_I_TREADY: in std_logic;
		
		I2S_O_MCLK: out std_logic; -- Master clock
		I2S_O_LRCLK: out std_logic; -- Word clock
		I2S_O_BCLK: out std_logic; -- Bit clock - 32bit per sample (24bit + 8bit padding), dual channel
		I2S_O_TDATA: out std_logic_vector(31 downto 0);
		I2S_O_TVALID: out std_logic
	);
end i2s_rcvr;

architecture rtl of i2s_rcvr is
	constant word_sz: natural := 32;
	
	signal i_sysclk: std_logic;
	signal i_mclk: std_logic;
	signal i_lrclk: std_logic;
	signal i_bclk: std_logic;
	signal i_data: std_logic;
	
	signal sr_sample: std_logic_vector(31 downto 0);
	signal sr_valid: std_logic;
	signal sr_count: unsigned(4 downto 0);
begin
	I2S_SYSCLK_IBUF: IBUF
		port map (
			I => I2S_I_SYSCLK,
			O => i_sysclk
		);
	
	I2S_DATA_IBUF: IBUF
		port map (
			I => I2S_I_DATA,
			O => i_data
		);

	clkgen: entity work.clkgen(rtl)
		port map (
			in_clk => i_sysclk,
			reset => I2S_I_RESET,
			clk_div1 => i_mclk,
			clk_div64 => i_bclk,
			clk_div512 => i_lrclk 
		);

	shift_in: process(i_bclk)
	begin
		if I2S_I_RESET = '1' then
			sr_sample <= (others => '0');
			sr_valid <= '0';
			sr_count <= b"00000";
		elsif rising_edge(i_bclk) then
			sr_sample <= sr_sample(sr_sample'high - 1 downto sr_sample'low) & i_data;
			sr_count <= sr_count + 1;
			
			if sr_count = word_sz then
				sr_valid <= '1';
				sr_count <= b"00000";
			else
				sr_valid <= '0';
			end if;
		end if;
	end process;
	
	I2S_O_MCLK <= i_mclk;
	I2S_O_LRCLK <= i_lrclk;
	I2S_O_BCLK <= i_bclk;
	I2S_O_TDATA <= sr_sample;
	I2S_O_TVALID <= sr_valid;

end rtl;

