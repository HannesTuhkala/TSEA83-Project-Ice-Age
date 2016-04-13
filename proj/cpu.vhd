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
	-- Declaration of a doubleported block-RAM
	-- with 512 addresses of 32 bits width.
	type ram_t is array(0 to 511) of
		std_logic_vector(31 downto 0);
		
	-- Reset all bits on all adresses
	signal ram : ram_t := (others => (others => '0'));
	
	-- port 1
	adress1 : in std_logic_vector(8 downto 0);
	rw1 : in std_logic; -- Read/Write flag for port 1
	ce1 : in std_logic; -- Count enable flag for port 1
	data1 : inout std_logic_vector(31 downto 0); -- Our instruction, which is 32 bits long.
	
	-- port 2
	adress2 : in std_logic_vector(8 downto 0);
	rw2 : in std_logic; -- Read/Write flag for port 2
	ce2 : in std_logic; -- Count enable flag for port 2
	data2 : out std_logic_vector(31 downto 0)); -- Our instruction, which is 32 bits long.

	--------------------------------------------------
	--------------END OF PROGRAM MEMORY---------------
	--------------------------------------------------

begin

	-------- Program Memory ---------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			-- synchronized read/write port 1
			if (ce1 = '0') then
				if (rw1 = '0') then
					ram(adress1) <= data1;
				else 
					data1 <= (adress1);
				end if;
			end if;
			
			-- synchronized read port 2
			if (ce2 = '0') then
				if (rw2 = '0') then
					data2 <= ram(adress2); -- Ev lägg till skrivning 
				end if;
			end if;
		end if;
	END PROCESS;
	-------- END Program Memory -------


end behavioral;
