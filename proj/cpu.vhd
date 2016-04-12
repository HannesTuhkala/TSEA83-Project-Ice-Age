library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu
	port (
		a1 : in ???
		a2 : out ???);
end CPU;

architecture behavioral of cpu is

begin

end behavioral;


entity program_memory is
	port (clk : in std_logic;
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
end program_memory;

architecture behavioral of program_memory is
	-- Deklaration av ett dubbelportat block-RAM
	-- med 512 adresser av 32 bitars bredd.
	type ram_t is array(0 to 511) of
		std_logic_vector(31 downto 0);
		
	-- Nollställ alla bitar på alla adresser
	signal ram : ram_t := (others => (others => '0'));
	
begin

PROCESS(clk)
BEGIN
	if (rising_edge(clk)) then
		
		-- synkron skrivning/läsning port 1
		if (ce1 = '0') then
			if (rw1 = '0') then
				ram(adress1) <= data1;
			else 
				data1 <= (adress1);
			end if;
		end if;
		
		-- synkron läsning port 2
		if (ce2 = '0') then
			if (rw2 = '0') then
				data2 <= ram(adress2);
			end if;
		end if;
	end if;
END PROCESS;
end behavioral;