library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
	port (
		clk: in std_logic;
		a1 : in ???;
		a2 : out ???);
end cpu;

architecture behavioral of cpu is
	
	----------------------------------------------------
	---------------------PROGRAM_MEMORY-----------------
	----------------------------------------------------
	-- Declaration of a block-RAM
	-- with 512 addresses of 32 bits width.
	type pm_t is array(0 to 511) of
		std_logic_vector(31 downto 0);
		
	-- Reset all bits on all adresses
	signal pm : pm_t := (others => (others => '0'));
	
	-- port 1
	signal adress1 : std_logic_vector(8 downto 0);
	signal re1 : std_logic; -- Read flag
	signal data1 : std_logic_vector(31 downto 0); -- Our instruction, which is 32 bits long.
	--------------------------------------------------
	--------------END OF PROGRAM MEMORY---------------
	--------------------------------------------------

	--------------------------------------------------
	--------------PROGRAM COUNTER---------------------
	--------------------------------------------------
	signal PC : std_logic_vector(8 downto 0);
	signal PC1 : std_logic_vector(8 downto 0);
	signal PC2 : std_logic_vector(8 downto 0);
	--------------------------------------------------
	------------END OF PROGRAM COUNTER----------------
	--------------------------------------------------

begin

	-------- Program Memory ---------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			data1 <= (adress1);
		end if;
	END PROCESS;
	-------- END Program Memory -------

	-------- Program Counter --------
	
	-------- END Program Counter ------


end behavioral;
