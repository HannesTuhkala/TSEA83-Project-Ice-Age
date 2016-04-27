library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
entity cpu is
	port (
		clk: in std_logic;
		playerXY : out std_logic_vector(7 downto 0);-- Player coordinate
		playerTransition : out std_logic_vector(7 downto 0);    -- Used to output how far the player has moved between two tiles. Exact data layout tbd
		joystick: in std_logic_vector(7 downto 0);
		mapm_addres : in std_logic_vector(7 downto 0);		--Addres by which graphics component can select type of tile in tilemem
		tile : out std_logic_vector(1 downto 0); 		--Tile type at mapm_addres
		

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
        	--lowest 4 denote row. "1-" denotes ground, "01" 
		--denotes rock, "00" denotes ice.
        type mapm_t is array(0 to 255) of 
			std_logic_vector(7 downto 0); 
	signal mapm : mapm_t := (others => (others => '0')); 
	----FLAGS----   
	signal z : std_logic := '0';
	signal n : std_logic := '0';
	--------------------------------------------------
	-------------------END OF ALU---------------------
	--------------------------------------------------
	
	--------------------------------------------------
	--------------PROGRAM COUNTER---------------------
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
	signal mux_1 : std_logic_vector(31 downto 0) := (others => '0');
	signal mux_2 : std_logic_vector(31 downto 0) := (others => '0');
	
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

begin
	-------------- REGISTER -----------------
	PROCESS(clk)
	begin
		if (rising_edge(clk)) then
			utA <= reg(IR1_term1);
			utB <= reg(IR1_term2);
			playerX <= reg(valdadress);
			reg(joystick adress) <= joystick
			if (IR3_op = "0001"|| IR3_op = "0011" || 
			   IR3_op = "0100" || IR3_op = "0101" ||
			   IR3_op = "0110") then

				reg(IR3_fA) <= ALU_out;
			end if;
		end if;
	END PROCESS;

	------------- END Register --------------

	-------- Program Memory ---------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			pm_instruction <= pm(PC);
		end if;
	END PROCESS;
	-------- END Program Memory -------

	----- Jump logic
	-------- MUX 1 --------						--needs fix
	with ? select
	mux_1 <= pm_instruction when ?,
			"0000" when others;
	------- END MUX 1 -------

	----- Stall logic
	-------- MUX 2 --------						--needs fix
	with ? select 
	mux_2 <= ir1 when ?,
			"0000" when others;
	------- END MUX 2 -------

	--------- Internal Registers -------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
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
			-- If IR1_op code is equal to the OP code for branch or Branch on flag (and correct flag is set).
			if (IR1_op = "1011" || (IR1_op = "1010" && ((IR1_am2(0) = '0' && z = '1')||(IR1_am2(0) = '1' && n = '1')))) then
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

	--------------- ALU ------------------
	PROCESS(clk)
	BEGIN
		if (rising_edge(clk)) then
			if (IR2_op = "0001") then	-- Move
				res <= B2;
			end if;
			
			if (IR2_op = "0011") then	--Add
				res <= A2 + B2;
			end if;
			
			if (IR2_op = "0100" || IR2_op = "1000") then   -- Sub or Comp; differed by whether register stores value
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
				res <= A2 * B2;
			end if;
			
			if (IR2_op = "0110") then   -- Shift
				if (am2(1) = '1') then 	-- Right Shift
					res(6 downto 0) <= A2(7 downto 1);
					if (am2(0) = '1')then -- arithmethric shift
						res(7) <= A2(7);
					else 
						res(7) <= '0';
					end if;
				else 
					res(7 downto 1) <= A2(6 downto 0);
					res(0 <= '0');
				end if;
			end if;
			
			if (IR2_op = "0111") then   -- Collision detector
				case B2(1 downto 0) is	-- detect rocks
					when "00" => z <= mapm(A2 - 16)(0);	--up
					when "01" => z <= mapm(A2 + 16)(0);	--down
					when "10" => z <= mapm(A2 - 1 )(0);	--left
					when "11" => z <= mapm(A2 + 1 )(0);	--right
				end case;
				n <= mapm(A2)(1); -- detect ground
			end if;
			
			if (IR2_op = "1001") then   -- set flag
				if (am2(1) = '1') then
					z <= am2(0);
				else 
					n <= am2(0);
				end if;
			end if;
			-- branch, branch on flag, nop and halt does not affect alu
			
			tile <= mapm(mapm_addres);	-- outputs requested pixel to pixel selector
		end if;
	end PROCESS;
	
end behavioral;
