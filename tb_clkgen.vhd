LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_clkgen IS
END tb_clkgen;
 
ARCHITECTURE test OF tb_clkgen IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT clk_gen
    PORT(
         in_clk : IN  std_logic;
         clk_div1 : OUT  std_logic;
         clk_div64 : OUT  std_logic;
         clk_div512 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal in_clk : std_logic := '0';

 	--Outputs
   signal clk_div1 : std_logic;
   signal clk_div64 : std_logic;
   signal clk_div512 : std_logic;

   -- Clock period definitions
   constant in_clk_period : time := 10 ns;
   constant clk_div1_period : time := 10 ns;
   constant clk_div64_period : time := 10 ns;
   constant clk_div512_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: clk_gen PORT MAP (
          in_clk => in_clk,
          clk_div1 => clk_div1,
          clk_div64 => clk_div64,
          clk_div512 => clk_div512
        );

   -- Clock process definitions
   in_clk_process :process
   begin
		in_clk <= '0';
		wait for in_clk_period/2;
		in_clk <= '1';
		wait for in_clk_period/2;
   end process;
 
   clk_div1_process :process
   begin
		clk_div1 <= '0';
		wait for clk_div1_period/2;
		clk_div1 <= '1';
		wait for clk_div1_period/2;
   end process;
 
   clk_div64_process :process
   begin
		clk_div64 <= '0';
		wait for clk_div64_period/2;
		clk_div64 <= '1';
		wait for clk_div64_period/2;
   end process;
 
   clk_div512_process :process
   begin
		clk_div512 <= '0';
		wait for clk_div512_period/2;
		clk_div512 <= '1';
		wait for clk_div512_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for in_clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
