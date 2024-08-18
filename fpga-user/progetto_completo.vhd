library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity progetto_completo is
	port (
		CK, SCK : in std_logic;
		nSS     : in std_logic;
		RST     : in std_logic;
		MOSI    : in std_logic;
		MISO    : out std_logic
	);
end entity;

architecture structure of progetto_completo is

	--**********************************************************************************
	--* Definizione segnali interni
	--**********************************************************************************

	signal RD, WR           : std_logic;
	signal ADD_OUT          : std_logic_vector(7 downto 0);
	signal DIN_OUT, MEM_OUT : std_logic_vector(15 downto 0);
	signal ADD_OUT_CONV     : integer range 0 to 255; -- memory address in formato integer

	--**********************************************************************************
	--* Dichiarazione component
	--**********************************************************************************

	component spi is
		port (
			CK, SCK : in std_logic;
			nSS     : in std_logic;
			RST     : in std_logic;
			A       : buffer std_logic_vector(7 downto 0);
			DIN     : out std_logic_vector(15 downto 0);
			DOUT    : in std_logic_vector(15 downto 0);
			RD, WR  : out std_logic; -- segnali di controllo per memoria
			MOSI    : in std_logic;
			MISO    : out std_logic
		);
	end component;

	component MEM is
		generic (N : integer := 16);
		port (
			clk      : in std_logic;
			wr       : in std_logic;                        -- write (attivo alto)
			rd       : in std_logic;                        -- read (attivo alto)
			address  : in integer range 0 to 255;           -- 8 bit
			data_in  : in std_logic_vector(N - 1 downto 0); -- 16 bit
			data_out : out std_logic_vector(N - 1 downto 0) -- 16 bit
		);
	end component;

begin

	ADD_OUT_CONV <= to_integer(unsigned(ADD_OUT));

	SPI_INTERFACE : spi
	port map(
		CK   => CK,
		SCK  => SCK,
		nSS  => nSS,
		RST  => RST,
		A    => ADD_OUT,
		DIN  => DIN_OUT,
		DOUT => MEM_OUT,
		RD   => RD,
		WR   => WR,
		MOSI => MOSI,
		MISO => MISO
	);
	MEMORY : mem
	generic map(N => 16)
	port map(
		clk      => CK,
		address  => ADD_OUT_CONV,
		data_in  => DIN_OUT,
		wr       => WR,
		rd       => RD,
		data_out => MEM_OUT
	);

end structure;