library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
	port (
		CK   : in std_logic;
		SCK  : in std_logic;
		nSS  : in std_logic;
		RST  : in std_logic;
		MOSI : in std_logic;
		MISO : out std_logic
	);
end entity;

architecture structure of top_level is

	--**********************************************************************************
	--* Definizione segnali interni
	--**********************************************************************************

	signal RD, WR    : std_logic;                     -- controlli
	signal A_SPI     : std_logic_vector(7 downto 0);  -- memory address (vector)
	signal A_SPI_INT : integer range 0 to 255;        -- memory address (integer)
	signal D_SPI     : std_logic_vector(15 downto 0); -- ingresso memoria
	signal Q_SPI     : std_logic_vector(15 downto 0); -- uscita memoria

	--**********************************************************************************
	--* Dichiarazione component
	--**********************************************************************************

	component spi is
		port (
			CK, SCK : in std_logic;
			nSS     : in std_logic;
			RST     : in std_logic;
			MOSI    : in std_logic;
			MISO    : out std_logic;
			RD, WR  : out std_logic;
			A       : out std_logic_vector(7 downto 0);
			DIN     : out std_logic_vector(15 downto 0);
			DOUT    : in std_logic_vector(15 downto 0)
		);
	end component;

	component MEM is
		generic (N : integer := 16);
		port (
			CK   : in std_logic;
			WR   : in std_logic;
			RD   : in std_logic;
			ADDR : in integer range 0 to 255;
			D    : in std_logic_vector(N - 1 downto 0);
			Q    : out std_logic_vector(N - 1 downto 0)
		);
	end component;

begin

	A_SPI_INT <= to_integer(unsigned(A_SPI));

	SPI_INTERFACE : spi
	port map(
		CK   => CK,
		SCK  => SCK,
		nSS  => nSS,
		RST  => RST,
		A    => A_SPI,
		DIN  => D_SPI,
		DOUT => Q_SPI,
		RD   => RD,
		WR   => WR,
		MOSI => MOSI,
		MISO => MISO
	);

	MEMORY : mem
	generic map(N => 16)
	port map(
		CK   => CK,
		WR   => WR,
		RD   => RD,
		ADDR => A_SPI_INT,
		D    => D_SPI,
		Q    => Q_SPI
	);

end structure;