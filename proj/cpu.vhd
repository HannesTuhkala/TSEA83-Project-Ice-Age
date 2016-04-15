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
	-- Reset all bits on all addresses
	signal pm : pm_t := (others => (others => '0'));
	
	-- NOTE: pm_instruction is the current instruction taken from program memory
	signal pm_instruction : std_logic_vector(31 downto 0); -- Our instruction, which is 32 bits long.
	--------------------------------------------------
	--------------END OF PROGRAM MEMORY---------------
	--------------------------------------------------

	--------------------------------------------------
	--------------PROGRAM COUNTER---------------------
	--------------------------------------------------
	signal stall : bit := '0';
	signal branch : bit := '0'; -- set 1 if IR1_op is branch, else set to 0.
	signal PC_out : std_logic_vector(8 downto 0);
	signal PC : std_logic_vector(8 downto 0) := (others => '0');
	signal PC1 : std_logic_vector(8 downto 0) := (others => '0');
	signal PC2 : std_logic_vector(8 downto 0) := (others => '0');
	--------------------------------------------------
	------------END OF PROGRAM COUNTER----------------
	--------------------------------------------------

	--------------------------------------------------
	------------------DATA MEMORY---------------------
	--------------------------------------------------
	-- Declaration of a block-RAM
	-- with 256 addresses of 2 bits width.
	type dm_t is array(0 to 255) of
		std_logic_vector(1 downto 0);
	
	-- Reset all bits on addresses
	signal dm : dm_t := (others => (others => '0'));

	signal dm_address : std_logic_vector(7 downto 0) := (others => '0');
	signal dm_out : std_logic_vector(1 downto 0);
	signal dm_in : std_logic_vector(7 downto 0);
	--------------------------------------------------
	---------------END OF DATA MEMORY-----------------
	--------------------------------------------------

	--------------------------------------------------
	-------------------REGISTER-----------------------
	--------------------------------------------------
	type reg_t is array(0 to 31) of 
		std_logic_vector(0 downto 7);		

	signal reg : reg_t := (others => (others => '0'));

	signal reg_enable : std_logic_vector(1 downto 0) := (others => '0');
	signal utA : std_logic_vector(8 downto 0) := (others => '0');
	signal utB : std_logic_vector(8 downto 0) := (others => '0');
	-------------------------------------------------
	----------------END OF REGISTER------------------
	-------------------------------------------------

	-------------------------------------------------
	--------------INTERNAL REGISTERS-----------------
	-------------------------------------------------
	signal IR1 : std_logic_vector(31 downto 0) := (others => '0');
	signal IR2 : std_logic_vector(31 downto 0) := (others => '0');
	signal IR3 : std_logic_vector(31 downto 0) := (others => '0');
	signal IR4 : std_logic_vector(31 downto 0) := (others => '0');
	signal mux_1 : std_logic_vector(31 downto 0) := (others => '0');
	signal mux_2 : std_logic_vector(31 downto 0) := (others => '0');
	
	-------------------ALIAS IR-------------------------
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



	-------------------------------------------------
	----------------DATAREGISTER---------------------
	-------------------------------------------------
begin
	
	--------------REGISTER-----------------
	PROCESS(clk)
	begin
		if (rising_edge(clk)) then
			utA <= reg(IR1_term1);
			utB <= reg(IR1_term2);

			-- ce1 = 1 då IR3_op är ett par speciella värden, vi får gå igenom vilka.
			if (ce1 = '1') then
				reg(IR3_fA) <= ALU_out;
			end if;
		end if;
	END PROCESS;

	-------------END Register--------------

	-------- Program Memory ---------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			pm_instruction <= pm(PC_out);
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
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			-- If IR1_op code is equal to the OP code for branch.
			if (IR1_op(3 downto 1) = "101") then
				branch <= '1';
				PC2 <= PC1 + IR1(25 downto 17); -- calculate next address in case of branch
			else
				branch <= '0';
				PC2 <= PC1;
			end if;

			PC1 <= PC; -- delay

			if (stall = '0') then
				if (branch = '1') then
					PC <= PC2;
					PC_out <= PC2;
				else
					PC_out <= PC + 1;
					PC <= PC + 1; -- may want to change the number to increment by, depening on how pm is implemented
				end if;
			end if;
		end if;
	END PROCESS;
	-------- END Program Counter ------

	---------- Data Memory ------------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			if (IR3_op = "0010") then
				dm(dm_address) <= dm_in;
			else
				dm_out <= dm(dm_address);
			end if;
		end if;
	END PROCESS;
	-------- END Data Memory ---------

end behavioral;
