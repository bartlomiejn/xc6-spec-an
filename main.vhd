library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
	Port (
		RESET: in std_logic;
		CLK: in std_logic;
		I2S_SYSCLK: in std_logic;
		I2S_DATA: in std_logic;
		
		I2S_MCLK: out std_logic;
		I2S_BCLK: out std_logic;
		I2S_LRCLK: out std_logic
	);
end main;

architecture rtl of main is
	signal i_reset: std_logic;
	signal i_sysclk: std_logic;
	signal i_data: std_logic;
	signal i_clk: std_logic;
	
	signal i_mclk: std_logic;
	signal i_lrclk: std_logic;
	signal i_bclk: std_logic;
	
	signal i_i2s_tready: std_logic;
	signal i_i2s_tdata: std_logic;
	signal i_i2s_tvalid: std_logic;
	
	signal i_fft_s_axis_tdata  : std_logic_vector(15 downto 0);
	signal i_fft_s_axis_tvalid : std_logic;
	signal i_fft_s_axis_tready : std_logic;
	signal i_fft_s_axis_tlast  : std_logic;
	signal i_fft_frame_cnt     : integer range 0 to 1023 := 0; 

	signal i_fft_m_axis_tdata  : std_logic_vector(31 downto 0); -- Complex output
	signal i_fft_m_axis_tvalid : std_logic;
	signal i_fft_m_axis_tready : std_logic := '1';              -- Always accept
	signal i_fft_m_axis_tlast  : std_logic;
begin

	RESET_IBUF: IBUF
		port map (
			I => RESET,
			O => i_reset
		);
		
	CLK_IBUF: IBUF
		port map (
			I => CLK,
			O => i_clk
		);
		
	I2S_SYSCLK_IBUF: IBUF
		port map (
			I => I2S_SYSCLK,
			O => i_sysclk
		);
		
	I2S_DATA_IBUF: IBUF
		port map (
			I => I2S_DATA,
			O => i_data
		);
		
	i2s_rcvr: entity work.i2s_rcvr(rtl)
		port map (
			i2s_i_reset => i_reset,
			i2s_i_sysclk => i_sysclk,
			i2s_i_data => i_data,
			i2s_i_tready => i_i2s_tready,
			i2s_o_mclk => i_mclk,
			i2s_o_lrclk => i_lrclk, 
			i2s_o_bclk => i_bclk,
			i2s_o_tdata => i_i2s_tdata,
			i2s_o_tvalid => i_i2s_tvalid
		);

	fft_fifo: entity fifo_generator_v9_3
		port map (
			s_aresetn => i_reset,
			s_aclk => i_mclk,
			s_axis_tvalid => i_i2s_tvalid,
			s_axis_tready => i_i2s_tready,
			s_axis_tdata => i_i2s_tdata,
			m_aclk => i_clk,
			m_axis_tvalid => i_fft_s_axis_tvalid,
			m_axis_tready => i_fft_s_axis_tready,
			m_axis_tdata => i_fft_s_axis_tdata
		);
		
	fft: entity xfft_v8_0
		port map (
			aclk => i_clk,
			s_axis_config_tdata => (others => '0'),
			s_axis_config_tready => open,
			s_axis_config_tvalid => '0',
			s_axis_data_tdata => i_fft_s_axis_tdata,
			s_axis_data_tready => i_fft_s_axis_tready,
			s_axis_data_tvalid => i_fft_s_axis_tvalid,
			s_axis_data_tlast => i_fft_s_axis_tlast,
			m_axis_data_tdata => i_fft_m_axis_tdata,
			m_axis_data_tready => i_fft_s_axis_tready,
			m_axis_data_tvalid => i_fft_m_axis_tvalid,
			m_axis_data_tlast => i_fft_m_axis_tlast,
			event_frame_started => open,
			event_tlast_unexpected => open,
			event_tlast_missing => open,
			event_status_channel_halt => open,
			event_data_in_channel_halt => open,
			event_data_out_channel_halt => open
		);
		
	I2S_MCLK <= i_mclk;
	I2S_BCLK <= i_bclk;
	I2S_LRCLK <= i_lrclk;

end rtl;

