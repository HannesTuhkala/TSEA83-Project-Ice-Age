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
	type reg_t is array(0 to 31) of 
		std_logic_vector(0 downto 7);		
	-- Reset all bits on all adresses
	signal pm : pm_t := (others => (others => '0'));
	signal reg : reg_t :=(others => (others => '0'));
	-- NOTE: adress == pc
	signal adress : std_logic_vector(8 downto 0) := (others => '0'); -- Our adress, which is 9 bits long.
	
	-- NOTE: pm_instruction is the current instruction taken from program memory
	signal pm_instruction : std_logic_vector(31 downto 0); -- Our instruction, which is 32 bits long.
	--------------------------------------------------
	--------------END OF PROGRAM MEMORY---------------
	--------------------------------------------------

	--------------------------------------------------
	--------------PROGRAM COUNTER---------------------
	--------------------------------------------------
	signal PC : std_logic_vector(8 downto 0) := (others => '0');
	signal PC1 : std_logic_vector(8 downto 0) := (others => '0');
	signal PC2 : std_logic_vector(8 downto 0) := (others => '0');
	--------------------------------------------------
	------------END OF PROGRAM COUNTER----------------
	--------------------------------------------------
	-------------INTERNAL SIGNALS-------------------
	signal reg_enable : std_logic_vector(1 downto 0) := (others =>'0');
	signal utA : std_logic_vector(8 downto 0) :=(others=> '0');
	signal utB : std_logic_vector(8 downto 0) :=(others => '0');







	-------------------------------------------------
	--------------INTERNAL REGISTERS-----------------
	-------------------------------------------------
	signal IR1 : std_logic_vector(31 downto 0) := (others => '0');
	signal IR2 : std_logic_vector(31 downto 0) := (others => '0');
	signal IR3 : std_logic_vector(31 downto 0) := (others => '0');
	signal IR4 : std_logic_vector(31 downto 0) := (others => '0');
	signal mux_1 : std_logic_vector(31 downto 0) := (others => '0');
	signal mux_2 : std_logic_vector(31 downto 0) := (others => '0');
	
	-------------------ALIAS-------------------------
	alias IR1_op : std_logic_vector(3 downto 0) is IR1(31 downto 28);
	alias IR2_op : std_logic_vector(3 downto 0) is IR2(31 downto 28);
	alias IR3_op : std_logic_vector(3 downto 0) is IR3(31 downto 28);
	
	alias IR1_am1 : std_logic_vector(1 downto 0) is IR1(27 downto 26);
	alias IR2_am1 : std_logic_vector(1 downto 0) is IR2(27 downto 26);
	alias IR3_am1 : std_logic_vector(1 downto 0) is IR3(27 downto 26);
	
	alias IR1_term1 : std_logic_vector(7 downto 0) is IR1(25 downto 18);
	alias IR2_term1 : std_logic_vector(7 downto 0) is IR2(25 downto 18);
	alias IR3_term1 : std_logic_vector(7 downto 0) is IR3(25 downto 18);

	alias IR1_am2 : std_logic_vector(1 downto 0) is IR1(17 downto 16);
	alias IR2_am2 : std_logic_vector(1 downto 0) is IR2(17 downto 16);
	alias IR3_am2 : std_logic_vector(1 downto 0) is IR3(17 downto 16);

	alias IR1_term2 : std_logic_vector(7 downto 0) is IR1(15 downto 8);
	alias IR2_term2 : std_logic_vector(7 downto 0) is IR2(15 downto 8);
	alias IR3_term2 : std_logic_vector(7 downto 0) is IR3(15 downto 8);

	alias IR1_fA : std_logic_vector(7 downto 0) is IR1(7 downto 0);
	alias IR2_fA : std_logic_vector(7 downto 0) is IR2(7 downto 0);
	alias IR3_fA : std_logic_vector(7 downto 0) is IR3(7 downto 0);

	-------------------------------------------------
	------------END OF INTERNAL REGISTERS------------
	-------------------------------------------------




	----------------DATAREGISTER-------------------------------
	-----------------------------------------------------------
begin
	PROCESS(clk)
	begin
		if (rising_edge(clk)) then
			if(IR			
		end if;
	END PROCESS;
	-------- Program Memory ---------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			pm_instruction <= pm(adress);
		end if;
	END PROCESS;
	-------- END Program Memory -------

	----- Jump logic
	-------- MUX 1 --------
	with ? select
	mux_1 <= pm_instruction when ?,
			"nop instruction" when others;
	------- END MUX 1 -------

	----- Stall logic
	-------- MUX 2 --------
	with ? select 
	mux_2 <= ir1 when ?,
			"nop instruction" when others;
	------- END MUX 2 -------

	--------- Internal Registers -------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			IR4 <= IR3;
			IR3 <= IR2;
			IR2 <= mux_2;
			IR1 <= mux_1; 
		end if;
	END PROCESS;
	------- END Internal Registers -------	

	-------- Program Counter --------
	
	-------- END Program Counter ------


end behavioral;
