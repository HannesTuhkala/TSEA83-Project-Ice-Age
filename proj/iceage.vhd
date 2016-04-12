entity iceage
	port (
		c1 : in ???;
		c2 : out ???;
		c3 : out ???);
end iceage;

architecture behavioral of iceage is

	component cpu
		port (
			a1 : in ???;
			a2 : out ???);
	end component cpu;
	
	component graphic
		port (
			b1 : in ???;
			b2 : out ???;
			b3 : out ???);
	end component graphic;
	
	signal x : ???;
	
begin
	U0 : cpu port map(a1=>c1, a2=>x);
	U1 : graphic port map(b1=>x, b2=>c2, b3=>c3);

end behavioral;