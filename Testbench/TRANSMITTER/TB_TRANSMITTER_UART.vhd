-- Library declaration
library IEEE;
use IEEE.std_logic_1164.all;

entity TB_TRANSMITTER_UART is
    generic (
        CLK_FREQ_c              :   integer := 100_000_000; 
        BAUDRATE_c              :   integer := 10_000_000; 
        COUNTER_SEND_LIMIT_c    :   integer := 8; 
        COUNTER_STOP_LIMIT_c    :   integer := 2 
    );
end entity TB_TRANSMITTER_UART;

architecture TB_TRANSMITTER_UART_rtl of TB_TRANSMITTER_UART is

    component TRANSMITTER_UART is
        generic (
            CLK_FREQ_c              :   integer := 100_000_000; 
            BAUDRATE_c              :   integer := 115_200; 
            COUNTER_SEND_LIMIT_c    :   integer := 8; 
            COUNTER_STOP_LIMIT_c    :   integer := 2 
        );
        port (
            -- Input signals
            CLK                     :   in  std_logic;
            RESET                   :   in  std_logic;
            TR_DATA_EN              :   in  std_logic;
            TR_DATA_IN_i            :   in  std_logic_vector (7 downto 0);
            -- Output signals
            TR_READY_o              :   out std_logic;
            TR_DONE_o               :   out std_logic;
            TR_DATA_OUT_o           :   out std_logic
        );
    end component;

    signal CLK                     :   std_logic    := '0';
    signal RESET                   :   std_logic    := '0';
    signal TR_DATA_EN              :   std_logic    := '0';
    signal TR_DATA_IN_i            :   std_logic_vector (7 downto 0) := (others => '0');
    signal TR_READY_o              :   std_logic;
    signal TR_DONE_o               :   std_logic;
    signal TR_DATA_OUT_o           :   std_logic;
    constant CLK_PERIOD            :   time := (10 ns);

begin

    UART_TRANSMITTER_DUT: TRANSMITTER_UART 
    generic map (
        CLK_FREQ_c              =>  CLK_FREQ_c,    
        BAUDRATE_c              =>  BAUDRATE_c,
        COUNTER_SEND_LIMIT_c    =>  COUNTER_SEND_LIMIT_c,
        COUNTER_STOP_LIMIT_c    =>  COUNTER_STOP_LIMIT_c
    )
    port map (
        CLK                     =>  CLK,
        RESET                   =>  RESET,
        TR_DATA_EN              =>  TR_DATA_EN, 
        TR_DATA_IN_i            =>  TR_DATA_IN_i,
        TR_READY_o              =>  TR_READY_o,
        TR_DONE_o               =>  TR_DONE_o,
        TR_DATA_OUT_o           =>  TR_DATA_OUT_o
    );

    CLK_PERIOD_P: process
    begin
        CLK <= '0';
        wait for (CLK_PERIOD/2);
        CLK <= '1';
        wait for (CLK_PERIOD/2);
    end process CLK_PERIOD_P;

    STIMULI_P: process
    begin

        RESET <= '1';
        wait for (CLK_PERIOD * 3);
        RESET <= '0';

        wait until (TR_READY_o = '1');
        TR_DATA_EN   <= '1';
        TR_DATA_IN_i <= x"51";
        wait for (CLK_PERIOD * 2);
        TR_DATA_EN <= '0';

        wait until (TR_READY_o = '1');
        TR_DATA_EN <= '1';
        TR_DATA_IN_i <= x"A3";
        wait for (CLK_PERIOD * 2);
        TR_DATA_EN <= '0';

        RESET <= '1';
        wait for (CLK_PERIOD * 3);
        RESET <= '0';

        wait until (TR_READY_o = '1');
        TR_DATA_EN <= '1';
        TR_DATA_IN_i <= x"D7";
        wait for (CLK_PERIOD * 2);
        TR_DATA_EN <= '0';

        wait until (TR_READY_o = '1');
        TR_DATA_EN <= '1';
        TR_DATA_IN_i <= x"38";
        wait for (CLK_PERIOD * 2);
        TR_DATA_EN <= '0';

        wait until (TR_READY_o = '1');

        wait for (CLK_PERIOD * 250);
        assert false
            report "SIM DONE"
            severity failure;

    end process STIMULI_P;

end TB_TRANSMITTER_UART_rtl;