library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu is
	port (
		clk: in std_logic;
		a1 : in ???;
		a2 : out ???);
end cpu;

architecture behavioral of cpu is
	
	----------------------------------------------------
	---------------------program_memory-----------------
	----------------------------------------------------
	-- declaration of a doubleported block-ram
	-- with 512 addresses of 32 bits width.
	type pm_t is array(0 to 511) of
		std_logic_vector(31 downto 0);
		
	-- reset all bits on all adresses
	signal pm : pm_t := (others => (others => '0'));
	
	-- port 1
	signal data : std_logic_vector(31 downto 0); -- our instruction, which is 32 bits long.
	

	--------------------------------------------------
	--------------end of program memory---------------
	--------------------------------------------------
	
	signal pc : in std_logic_vector(8 downto 0) :=(others => '0');
	signal pc1 : in std_logic_vector(8 downto 0):=(others => '0');
	signal pc2 : in std_logic_vector(8 downto 0):=(others => '0');

	alias op_kod

begin
	------------PC-MUX----------------------------------------------------------------------------------------------------------------------------------------------------------
	with select <=

	-------- program memory ---------
	process(clk)
	begin
		if (rising_edge(clk)) then
			-- READ PROGRAM INSTRUCTION -- 
			data <= pm(pc); -- ev lägg till skrivning 
		end if;
	end process;
	-------- end program memory -------
	--program counter--
	process(clk)
	begin
		if (rising_edge(clk)) then

		end if;
	end process;


end behavioral;
