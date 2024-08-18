library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_spi_complete is
end tb_spi_complete;

architecture behavioral of tb_spi_complete is

    -- definizione segnali interni
    signal clock   : std_logic := '0';              -- main clock
    signal s_clock : std_logic := '0';              -- system clock
    signal nSS_spi : std_logic := '1';              -- slave select
    signal reset   : std_logic := '0';              -- reset esterno
    signal s_mosi  : std_logic := '1';              -- MOSI seriale
    signal s_miso  : std_logic := 'Z';              -- MISO seriale
    signal MOSI_wr : std_logic_vector(31 downto 0); -- vettore dati per WR
    signal MOSI_rd : std_logic_vector(15 downto 0); -- vettore dati per RD
    signal MISO_rd : std_logic_vector(15 downto 0); -- vettore restituito su MISO

    -- definizione file di I/O
    file file_WRITE  : text;
    file file_READ   : text;
    file file_OUTPUT : text;

    -- dichiarazione UUT
    component top_level is
        port (
            CK, SCK : in std_logic;
            nSS     : in std_logic;
            RST     : in std_logic;
            MOSI    : in std_logic;
            MISO    : out std_logic
        );
    end component;

begin

    -- istanza UUT
    TB_SPI : top_level
    port map(
        CK => clock, SCK => s_clock,
        RST => reset, nSS => nSS_spi,
        MOSI => s_mosi, MISO => s_miso
    );

    -- Process CK (clock FPGA, periodo 100 ns, f=10 MHz)
    CK_process : process
    begin
        wait for 50 ns;
        clock <= not clock;
    end process CK_process;

    -- Process di scerittura e lettura
    WR_RD_process : process
        variable v_WLINE : line; -- riga file comandi di scrittura
        variable v_RLINE : line; -- riga file comandi di lettura
        variable v_OLINE : line; -- riga file di output risultati
        variable v_wMOSI : std_logic_vector(31 downto 0);
        variable v_rMOSI : std_logic_vector(15 downto 0);
        variable cnt_bit : integer := 15;

    begin

        wait for 100 ns;
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- Apro file di I/O in modalità di lettura/scrittura
        file_open(file_WRITE, "input_wr.txt", read_mode);
        file_open(file_READ, "input_rd.txt", read_mode);
        file_open(file_OUTPUT, "output_results.txt", write_mode);

        -- Leggo da input_wr.txt
        while not endfile(file_WRITE) loop
            readline(file_WRITE, v_WLINE);
            read(v_WLINE, v_wMOSI); -- get data in

            -- scrittura
            MOSI_wr <= v_wMOSI;
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
            wait for 5 us;

        end loop;

        -- Leggo da input_rd.txt
        while not endfile(file_READ) loop
            readline(file_READ, v_RLINE);
            read(v_RLINE, v_rMOSI); -- get data in

            -- lettura
            MOSI_rd <= v_rMOSI;
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
                if (s_miso /= 'Z') then
                    MISO_rd(cnt_bit) <= s_miso;
                    cnt_bit := cnt_bit - 1;
                end if;
                wait for 500 ns;
                s_clock <= '0';
                wait for 500 ns;
            end loop;

            cnt_bit := 15;
            nSS_spi <= '1';
            wait for 2 us;

            -- Scrivo in output_results.txt
            write(v_OLINE, MISO_rd, right, 16);
            writeline(file_OUTPUT, v_OLINE);

        end loop;

        -- Chiudo i file di I/O
        file_close(file_WRITE);
        file_close(file_READ);
        file_close(file_OUTPUT);

        wait;
    end process WR_RD_process;

end architecture;