library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_spi_simple is
end tb_spi_simple;

architecture behavioral of tb_spi_simple is

	-- segnali di appoggio
	signal clock   : std_logic := '0';              -- main clock
	signal s_clock : std_logic := '0';              -- system clock
	signal nSS_spi : std_logic := '1';              -- slave select
	signal s_mosi  : std_logic := '1';              -- MOSI seriale
	signal s_miso  : std_logic := 'Z';              -- MISO seriale
	signal MOSI_wr : std_logic_vector(31 downto 0); -- vettore dati per WR
	signal MOSI_rd : std_logic_vector(15 downto 0); -- vettore dati per RD
	signal reset   : std_logic;                     -- reset esterno

	-- dichiarazione UUT
	component top_level is
		port (
			CK   : in std_logic;
			SCK  : in std_logic;
			nSS  : in std_logic;
			RST  : in std_logic;
			MOSI : in std_logic;
			MISO : out std_logic
		);
	end component;

begin

	-- istanza UUT
	TB_SPI : top_level
	port map(
		CK => clock, SCK => s_clock,
		nSS => nSS_spi, RST => reset,
		MOSI => s_mosi, MISO => s_miso
	);

	-- Process CK (clock FPGA, periodo 200 ns, f=5 MHz)
	CK_process : process
	begin
		wait for 50 ns;
		clock <= not clock;
	end process CK_process;

	-- Process di lettura e scrittura
	RD_WR_process : process
	begin
		reset <= '1';
		wait for 0.1 ns;
		reset <= '0';

		-- PRIMA SCRITTURA: w01090b
		-- CMD 00100000 '20' (w)
		-- ADD 00000001 '01'
		-- DIN 0000100100001011 '090b'
		-- 00100000 00000001 0000100100001011
		MOSI_wr <= "00100000" & "00000001" & "0000100100001011";
		nSS_spi <= '0';
		wait for 100 ns;

		for i in 0 to 31 loop --invio dati su mosi
			s_mosi  <= MOSI_wr(31 - i);
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		wait for 200 ns;
		nSS_spi <= '1';
		wait for 400 ns;

		-- SECONDA SCRITTURA: w02aaaa
		-- CMD 00100000 '20' (w)
		-- ADD 00000010 '02'
		-- DIN 1010101010101010 'aaaa'
		-- 00100000 00000010 1010101010101010
		MOSI_wr <= "00100000" & "00000010" & "1010101010101010";
		nSS_spi <= '0';
		wait for 100 ns;

		for i in 0 to 31 loop --invio dati su mosi
			s_mosi  <= MOSI_wr(31 - i);
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		wait for 200 ns;
		nSS_spi <= '1';
		wait for 200 ns;

		-- TERZA SCRITTURA: w0509ef
		-- CMD 00100000 '20' (w)
		-- ADD 00000101 '05'
		-- DIN 1010101010101010 '09ef'
		-- 00100000 00000101 0000100111101111
		MOSI_wr <= "00100000" & "00000101" & "0000100111101111";
		nSS_spi <= '0';
		wait for 100 ns;

		for i in 0 to 31 loop
			s_mosi  <= MOSI_wr(31 - i);
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		wait for 200 ns;
		nSS_spi <= '1';
		wait for 400 ns;

		-- PRIMA LETTURA: r02
		-- CMD 00100001 '21' (r)
		-- ADD 00000010 '02'
		-- 00100001 00000010
		MOSI_rd <= "00100001" & "00000010";
		nSS_spi <= '0';
		wait for 1 us;

		for i in 0 to 15 loop --invio dati su mosi
			s_mosi  <= MOSI_rd(15 - i);
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		for i in 0 to 18 loop -- aspetto il dato
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		nSS_spi <= '1';
		wait for 200 ns;

		-- SECONDA LETTURA: r01
		-- CMD 00100001 '21' (r)
		-- ADD 00000001 '01'
		-- 00100001 00000001
		MOSI_rd <= "00100001" & "00000001";
		nSS_spi <= '0';
		wait for 1 us;

		for i in 0 to 15 loop
			s_mosi  <= MOSI_rd(15 - i);
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		for i in 0 to 18 loop
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		nSS_spi <= '1';
		wait for 200 ns;

		-- TERZA LETTURA: r05
		-- CMD 00100001 '21' (r)
		-- ADD 00000101 '05'
		-- 00100001 00000101
		MOSI_rd <= "00100001" & "00000101";
		nSS_spi <= '0';
		wait for 1 us;

		for i in 0 to 15 loop
			s_mosi  <= MOSI_rd(15 - i);
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		for i in 0 to 18 loop
			s_clock <= '1';
			wait for 500 ns;
			s_clock <= '0';
			wait for 500 ns;
		end loop;

		nSS_spi <= '1';
		wait;

	end process RD_WR_process;

end architecture;