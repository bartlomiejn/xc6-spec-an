LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
library std;
use std.textio.all;

ENTITY tb_i2s_receiver IS
END tb_i2s_receiver;

ARCHITECTURE behavior OF tb_i2s_receiver IS
	COMPONENT i2s_receiver
		PORT(
			I2S_I_RESET : IN  std_logic;
			I2S_I_SYSCLK : IN  std_logic;
			I2S_I_DATA : IN  std_logic;
			I2S_I_TREADY : IN  std_logic;
			I2S_O_MCLK : OUT  std_logic;
			I2S_O_LRCLK : OUT  std_logic;
			I2S_O_BCLK : OUT  std_logic;
			I2S_O_TDATA : OUT  std_logic_vector(31 downto 0);
			I2S_O_TVALID : OUT  std_logic
		);
	END COMPONENT;

	--Inputs
	signal I2S_I_RESET : std_logic := '0';
	signal I2S_I_SYSCLK : std_logic := '0';
	signal I2S_I_DATA : std_logic := '0';
	signal I2S_I_TREADY : std_logic := '0';

	--Outputs
	signal I2S_O_MCLK : std_logic;
	signal I2S_O_LRCLK : std_logic;
	signal I2S_O_BCLK : std_logic;
	signal I2S_O_TDATA : std_logic_vector(31 downto 0);
	signal I2S_O_TVALID : std_logic;

	-- Stimulus signals
	signal I2S_O_MCLK_count : integer := 0;
	signal I2S_O_LRCLK_count : integer := 0;
	signal I2S_O_BCLK_count : integer := 0;

	signal i2s_mock_left : std_logic_vector(31 downto 0)
	    := "11000011010110100000111100011000";
	signal i2s_mock_right : std_logic_vector(31 downto 0)
		:= "00111100101001011111000011100111";

	-- Stimulus periods
	constant I2S_I_SYSCLK_period : time := 40.6901 ns *4; -- 24.576MHz
	constant I2S_I_RESET_period : time := 100 ns;
	constant test_period : time := I2S_I_SYSCLK_period * 2048;
	constant total_period : time := test_period + I2S_I_RESET_period;
BEGIN

	uut: i2s_receiver
		port map (
			I2S_I_RESET => I2S_I_RESET,
			I2S_I_SYSCLK => I2S_I_SYSCLK,
			I2S_I_DATA => I2S_I_DATA,
			I2S_I_TREADY => I2S_I_TREADY,
			I2S_O_MCLK => I2S_O_MCLK,
			I2S_O_LRCLK => I2S_O_LRCLK,
			I2S_O_BCLK => I2S_O_BCLK,
			I2S_O_TDATA => I2S_O_TDATA,
			I2S_O_TVALID => I2S_O_TVALID
		);

	stimulus_sysclk: process
	begin
		while now < test_period + I2S_I_RESET_period loop
			I2S_I_SYSCLK <= '0';
			wait for I2S_I_SYSCLK_period;
			I2S_I_SYSCLK <= '1';
			wait for I2S_I_SYSCLK_period;
		end loop;
	end process stimulus_sysclk;

	stimulus_data: process
		variable i : integer;
	begin
		-- Left channel mock data
		wait until rising_edge(I2S_O_LRCLK);
		for i in 0 to 31 loop
			I2S_I_DATA <= i2s_mock_left(i);
			wait until falling_edge(I2S_O_MCLK);
		end loop;

		-- Right channel mock data
		wait until falling_edge(I2S_O_LRCLK);
		for i in 0 to 31 loop
			I2S_I_DATA <= i2s_mock_right(i);
			wait until falling_edge(I2S_O_MCLK);
		end loop;
	end process stimulus_data;

   stimulus_reset: process
   begin
		I2S_I_RESET <= '1';
		wait for I2S_I_RESET_period;
		I2S_I_RESET <= '0';
		wait;
	end process;

	-- Output clock counters
	count_ticks_I2S_O_MCLK: process(I2S_O_MCLK)
	begin
		if rising_edge(I2S_O_MCLK) then
			I2S_O_MCLK_count <= I2S_O_MCLK_count + 1;
		end if;
	end process;

	count_ticks_I2S_O_LRCLK: process(I2S_O_LRCLK)
	begin
		if rising_edge(I2S_O_LRCLK) then
			I2S_O_LRCLK_count <= I2S_O_LRCLK_count + 1;
		end if;
	end process;

	count_ticks_I2S_O_BCLK: process(I2S_O_BCLK)
	begin
		if rising_edge(I2S_O_BCLK) then
			I2S_O_BCLK_count <= I2S_O_BCLK_count + 1;
		end if;
	end process;

	-- Generate report
	test_clocks: process
		variable L: line;
	begin
		wait for I2S_I_RESET_period;
		
		assert I2S_O_MCLK_count = 0 and I2S_O_LRCLK_count = 0 and I2S_O_BCLK_count = 0
			report "Clocks should not pulse when reset is asserted"
			severity error;
			
		wait for test_period;

		write(L, string'("I2S_O_MCLK ticks: "));
		write(L, I2S_O_MCLK_count);
		writeline(output, L);

		write(L, string'("I2S_O_LRCLK ticks: "));
		write(L, I2S_O_LRCLK_count);
		writeline(output, L);

		write(L, string'("I2S_O_BCLK ticks: "));
		write(L, I2S_O_BCLK_count);
		writeline(output, L);

		assert I2S_O_BCLK_count = 512 and I2S_O_LRCLK_count = 8 and I2S_O_MCLK_count = 1024
			report "Output clocks did not pulse expected number of times"
			severity error;

		wait;
	end process;

END;


