-- Library declaration
library IEEE;
use IEEE.std_logic_1164.all;

entity TB_RECEIVER_UART is
    generic (
        CLK_FREQ_c                  :   integer := 100_000_000; 
        BAUDRATE_c                  :   integer := 115_200; 
        COUNTER_RECEIVER_LIMIT_c    :   integer := 8  
    );
end entity TB_RECEIVER_UART;

architecture rtl of TB_RECEIVER_UART is

    component RECEIVER_UART is
        generic (
            CLK_FREQ_c                  :   integer := 100_000_000; 
            BAUDRATE_c                  :   integer := 115_200; 
            COUNTER_RECEIVER_LIMIT_c    :   integer := 8  
        );
        port (
            -- Input signals
            CLK                     :   in  std_logic;
            RESET                   :   in  std_logic;
            RE_DATA_IN_i            :   in  std_logic;
            -- Output signals
            RE_DONE_o               :   out std_logic;
            RE_DATA_OUT_o           :   out std_logic_vector (7 downto 0)
        );
    end component;

    signal CLK                     :   std_logic;
    signal RESET                   :   std_logic;
    signal RE_DATA_IN_i            :   std_logic;
    signal RE_DONE_o               :   std_logic;
    signal RE_DATA_OUT_o           :   std_logic_vector (7 downto 0);

    constant CLK_PERIOD            :    time    := (10 ns);
    constant COUNTER_FREQ          :    time    := (8.68 us);

    signal STIMULI_DATA            :    std_logic_vector (7 downto 0) := x"00";
    signal UART_DATA_PACK          :    std_logic_vector (9 downto 0);

begin

    RE_INST: RECEIVER_UART 
        generic map (
            CLK_FREQ_c                  => CLK_FREQ_c,
            BAUDRATE_c                  => BAUDRATE_c,
            COUNTER_RECEIVER_LIMIT_c    => COUNTER_RECEIVER_LIMIT_c
        )
        port map (
            CLK                     => CLK,
            RESET                   => RESET,
            RE_DATA_IN_i            => RE_DATA_IN_i,
            RE_DONE_o               => RE_DONE_o,
            RE_DATA_OUT_o           => RE_DATA_OUT_o 
        );

    CLK_P: process
    begin
        CLK <= '0';
        wait for (CLK_PERIOD/2);
        CLK <= '1';
        wait for (CLK_PERIOD/2);
    end process CLK_P;

    UART_DATA_PACK <= (('1') & (STIMULI_DATA) & ('0'));
    
    STIMULI_P: process
    begin
        RE_DATA_IN_i <= '0';

        -- RESET condition
        wait for (CLK_PERIOD);
        RESET <= '1';
        wait for (CLK_PERIOD * 5);
        RESET <= '0';
        wait for (CLK_PERIOD * 5);
        
        STIMULI_DATA <= x"55";
        for i in 0 to 9 loop
            RE_DATA_IN_i <= UART_DATA_PACK (i);
            wait for (COUNTER_FREQ);
        end loop;
        RE_DATA_IN_i <= '1';
        wait for (COUNTER_FREQ);

        STIMULI_DATA <= x"DC";
        for i in 0 to 9 loop
            RE_DATA_IN_i <= UART_DATA_PACK (i);
            wait for (COUNTER_FREQ);
        end loop;
        RE_DATA_IN_i <= '1';
        wait for (COUNTER_FREQ);

        STIMULI_DATA <= x"7A";
        for i in 0 to 9 loop
            RE_DATA_IN_i <= UART_DATA_PACK (i);
            wait for (COUNTER_FREQ);
        end loop;
        RE_DATA_IN_i <= '1';
        wait for (COUNTER_FREQ);

        STIMULI_DATA <= x"AB";
        for i in 0 to 9 loop
            RE_DATA_IN_i <= UART_DATA_PACK (i);
            wait for (COUNTER_FREQ);
        end loop;
        RE_DATA_IN_i <= '1';
        wait for (COUNTER_FREQ);

        wait for (CLK_PERIOD * 2500);
        assert false
            report "SIM DONE"
            severity failure;
    end process STIMULI_P;

end architecture;