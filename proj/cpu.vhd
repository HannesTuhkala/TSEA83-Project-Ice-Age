library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
entity cpu is
	port (
		clk: in std_logic;
		playerXYR : out std_logic_vector(7 downto 0);-- Player coordinate high (each worth 16 pixels)
		playerXYD : out std_logic_vector(7 downto 0);-- Player coordinate low (used for transitions between tiles)
		joystick: in std_logic_vector(7 downto 0);
		mapm_address : in std_logic_vector(7 downto 0);		--Address by which graphics component can select type of tile in tilemem
		tile : out std_logic_vector(1 downto 0) 		--Tile type at mapm_addres
	);
end cpu;

architecture behavioral of cpu is
	
	----------------------------------------------------
	-------------------PROGRAM_MEMORY-------------------
	----------------------------------------------------
	-- Declaration of a block-RAM
	-- with 512 addresses of 32 bits width. -2KB
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
	---------------------ALU--------------------------
	--------------------------------------------------
		        ----Map layout Memory----
        	--mapm is arranged as: highest 4 bits denote column, 
        	--lowest 4 denote row. "10" denotes ground, "01" 
		--denotes rock, "00" denotes ice. Don't use "11" or you'll draw sprites
    type mapm_t is array(0 to 255) of 
			std_logic_vector(1 downto 0); 
	signal mapm : mapm_t := (others => "00");
	
	----FLAGS----   
	signal z : std_logic := '0';
	signal n : std_logic := '0';
	--------------------------------------------------
	-------------------END OF ALU---------------------
	--------------------------------------------------
	
	--------------------------------------------------
	---------------PROGRAM COUNTER--------------------
	--------------------------------------------------
	signal stall : bit := '0';
	signal branch : bit := '0'; -- set 1 if IR1_op is branch, else set to 0.
	signal PC : std_logic_vector(8 downto 0) := (others => '0');
	signal PC1 : std_logic_vector(8 downto 0) := (others => '0');
	--------------------------------------------------
	------------END OF PROGRAM COUNTER----------------
	--------------------------------------------------

	--------------------------------------------------
	-------------------REGISTER-----------------------
	--------------------------------------------------
	type reg_t is array(0 to 63) of 
		std_logic_vector(7 downto 0);	

	signal reg : reg_t := (others => (others => '0'));
	signal tmpB2 : std_logic_vector(1 downto 0);

	signal reg_enable : std_logic_vector(1 downto 0) := (others => '0');
	signal A2 : std_logic_vector(7 downto 0) := (others => '0');
	signal B2 : std_logic_vector(7 downto 0) := (others => '0');
	-------------------------------------------------
	----------------End of register------------------
	-------------------------------------------------

	-------------------------------------------------
	--------------Internal registers-----------------
	-------------------------------------------------
	signal ir1 : std_logic_vector(31 downto 0) := (others => '0');
	signal ir2 : std_logic_vector(31 downto 0) := (others => '0');
	signal ir3 : std_logic_vector(31 downto 0) := (others => '0');
	--signal mux_1 : std_logic_vector(31 downto 0) := (others => '0');
	--signal mux_2 : std_logic_vector(31 downto 0) := (others => '0');
	
	-------------------ALIAS IR-------------------------
	alias IR1_op : std_logic_vector(3 downto 0) is IR1(31 downto 28);
	alias IR2_op : std_logic_vector(3 downto 0) is IR2(31 downto 28);
	alias IR3_op : std_logic_vector(3 downto 0) is IR3(31 downto 28);
	
	
	alias IR1_term1 : std_logic_vector(7 downto 0) is IR1(25 downto 18);

	alias IR1_am2 : std_logic_vector(1 downto 0) is IR1(17 downto 16);
	alias IR2_am2 : std_logic_vector(1 downto 0) is IR2(17 downto 16);
	alias IR3_am2 : std_logic_vector(1 downto 0) is IR3(17 downto 16);

	alias IR1_term2 : std_logic_vector(7 downto 0) is IR1(15 downto 8);

	alias IR3_fA : std_logic_vector(7 downto 0) is IR3(7 downto 0);

	-------------------------------------------------
	------------END OF INTERNAL REGISTERS------------
	-------------------------------------------------

	-------------------------------------------------
	--------------------ALU--------------------------
	-------------------------------------------------
	signal res : std_logic_vector(7 downto 0) := (others => '0');
	-------------------------------------------------
	-------------------END OF ALU--------------------
	-------------------------------------------------

begin
	-------------- REGISTER -----------------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			A2 <= reg(to_integer(unsigned(IR1_term1)));
			if ir1_am2 = "01" then
				B2 <= reg(to_integer(unsigned(IR1_term2)));
			else 
				b2 <= ir1_term2;
			end if;
			playerXYR <= reg(0);	-- Player Y and X position are stored in register 0 and 1.
			playerXYD <= reg(1);
			reg(2) <= joystick;		-- We store the joystick value in register 2.

			if (IR3_op = "0001" or IR3_op = "0011" or IR3_op = "0100" or IR3_op = "0101" or IR3_op = "0110") then
				reg(to_integer(unsigned(IR3_fA))) <= res;
			end if;
		end if;
	END PROCESS;

	------------- END Register --------------

	-------- END Program Memory -------

	----- Jump logic
	-------- MUX 1 --------						--needs fix YES
	--with ? select
	--mux_1 <= pm_instruction when ?,
	--		"0000" when others;
	------- END MUX 1 -------

	----- Stall logic
	-------- MUX 2 --------						--needs fix YES
	--with ? select 
	--mux_2 <= ir1 when ?,
	--		"0000" when others;
	------- END MUX 2 -------

	--------- Internal Registers -------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			IR3 <= IR2;
			IR2 <= IR1;
			IR1 <= pm(to_integer(unsigned(PC))); 
		end if;
	END PROCESS;
	------- END Internal Registers -------	

	-------- Program Counter --------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			-- If IR1_op code is equal to the OP code for branch or Branch on flag (and correct flag is set).
			if (IR1_op = "1011" or (IR1_op = "1010" and ((IR1_am2(0) = '0' and z = '1') or (IR1_am2(0) = '1' and n = '1')))) then
				branch <= '1';
			else
				branch <= '0';
			end if;
		
			PC1 <= PC; -- delay

			if (stall = '0') then
				if (branch = '1') then
					PC <= PC1 + IR1(25 downto 17);
				else
					PC <= PC + 1;
				end if;
			end if;
		end if;
	END PROCESS;
	-------- END Program Counter ------



	tmpB2 <= B2(1 downto 0);
	--------------- ALU ------------------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			if (IR2_op = "0001") then	-- Move
				res <= B2;
			end if;
			
			if (IR2_op = "0010") then  --map editor
				mapm(to_integer(unsigned(A2))) <= tmpB2;
			elsif (IR2_op = "0111") then   --collision detector
				res(7 downto 2) <= (others => '0');
				res(1 downto 0) <= mapm(to_integer(unsigned(B2)));
			end if;

			if (IR2_op = "0011") then	--Add
				res <= A2 + B2;
			end if;
			
			if (IR2_op = "0100" or IR2_op = "1000") then   -- Sub or Comp; differed by whether register stores value
				res <= A2 - B2;
				
				if(A2 < B2) then 
					n <= '1';
				else 
					n <= '0';
				end if;

				if(A2 = B2) then
					z <= '1';
				else 
					z <= '0';
				end if; 
			end if;

			if (IR2_op = "0101") then   --Mult
				res <= "00000000"; --A2 * B2;
			end if;
			
			if (IR2_op = "0110") then   -- Shift
				if (IR2_am2(1) = '1') then 	-- Right Shift
					res(6 downto 0) <= A2(7 downto 1);
					if (IR2_am2(0) = '1')then -- arithmethric shift
						res(7) <= A2(7);
					else 
						res(7) <= '0';
					end if;
				else 
					res(7 downto 1) <= A2(6 downto 0);
					res(0) <= '0';
				end if;
			end if;
			
						
			if (IR2_op = "1001") then   -- set flag
				if (IR2_am2(1) = '1') then
					z <= IR2_am2(0);
				else 
					n <= IR2_am2(0);
				end if;
			end if;
			-- branch, branch on flag, nop and halt does not affect alu
			
			-- TODO FIX: mapm bredd �r 8 bitar, tile �r bara 2 bitar
			tile <= mapm(to_integer(unsigned(mapm_address)));	-- outputs requested pixel to pixel selector
		end if;
	end PROCESS;
	
end behavioral;
