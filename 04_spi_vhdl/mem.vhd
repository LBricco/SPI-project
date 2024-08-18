--**********************************************************************************
--* Memoria di tipo register file con capacità 256xN
--* Gli indirizzi cono codificati su 8 bit (quindi abbiamo 256 locazioni 0-255)
--* Il parallelismo dei dati è pari a N bit (generic)
--**********************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM is
	generic (N : integer := 16);
	port (
		CK   : in std_logic;
		WR   : in std_logic;                        --write (attivo alto)
		RD   : in std_logic;                        --read (attivo alto)
		ADDR : in integer range 0 to 255;           --8 bit
		D    : in std_logic_vector(N - 1 downto 0); --16 bit
		Q    : out std_logic_vector(N - 1 downto 0) --16 bit
	);
end MEM;

architecture structure of MEM is

	type ram_array is array (0 to 255) of std_logic_vector (N - 1 downto 0);
	signal ram : ram_array;

begin

	process (CK)
	begin
		if (CK'event and CK = '1') then -- fronte di salita del CK
			if (WR = '1') then          -- scrittura
				ram(ADDR) <= D;
			elsif (RD = '1') then       -- lettura
				Q <= ram(ADDR);
			end if;
		end if;
	end process;

end structure;