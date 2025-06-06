library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity i2s_receiver is
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
end i2s_receiver;

architecture rtl of i2s_receiver is
	constant word_sz: natural := 24;
	
	signal i_sysclk: std_logic;
	signal i_mclk: std_logic;
	signal i_lrclk: std_logic;
	signal i_bclk: std_logic;
	signal i_data: std_logic;
	
	signal sr_sample: std_logic_vector(31 downto 0) := (others => '0');
	signal sr_valid: std_logic;
	signal sr_count: unsigned(4 downto 0);
	signal sr_collecting: std_logic;
	signal sr_channel_left: std_logic;
	
	signal last_bclk: std_logic;
	signal last_lrclk: std_logic;
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
			clk_div2 => i_bclk,
			clk_div128 => i_lrclk 
		);

	shift_in: process(i_mclk)
	begin
		if I2S_I_RESET = '1' then
			sr_sample <= (others => '0');
			sr_valid <= '0';
			sr_count <= b"00000";
			sr_collecting <= '0';
			sr_channel_left <= '0';
			last_bclk <= '0';
			last_lrclk <= '0';
		elsif rising_edge(i_mclk) then
			last_bclk <= i_bclk;
			last_lrclk <= i_lrclk;
			
			-- Start of new frame
			if i_lrclk /= last_lrclk then
				sr_collecting <= '1';
				sr_count <= b"00000";
				
				if i_lrclk = '0' then
					sr_channel_left <= '1';
				else
					sr_channel_left <= '0';
				end if;
			-- Shifting frame into SR
			elsif sr_collecting = '1' then
				-- BCLK rising edge
				if (i_bclk = '1') and (last_bclk = '0') then
					sr_sample(23 - to_integer(unsigned(sr_count))) <= i_data;
					
					if sr_count = word_sz then
						-- Sample ready
						sr_valid <= '1';
						sr_collecting <= '0';
						sr_count <= b"00000";
					else
						-- Continue
						sr_count <= sr_count + 1;
					end if;
				end if;
			end if;			
		end if;
	end process;
	
	I2S_O_MCLK <= i_mclk;
	I2S_O_LRCLK <= i_lrclk;
	I2S_O_BCLK <= i_bclk;
	I2S_O_TDATA <= sr_sample;
	I2S_O_TVALID <= sr_valid;

end rtl;

