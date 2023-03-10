---------------------------------------------------------------------------------------
-- Engineer: IBRAHIM AYAZ                                                            --
-- Create Date: 02.03.2023 16:30:00                                                  --
-- Design Name: RECEIVER_UART.vhd                                                    --
--                                                                                   --
-- Description: Digital design for the receiver part of the UART communication       --
-- protocol.                                                                         --
--                                                                                   --
-- Output: The output data is a parallel UART data.                                  --
---------------------------------------------------------------------------------------

--! Library declaration
library IEEE;
use IEEE.std_logic_1164.all;

entity RECEIVER_UART is
    generic (
        CLK_FREQ_c                  :   integer := 100_000_000;                                 --! Clock frequency 
        BAUDRATE_c                  :   integer := 115_200;                                     --! UART baudrate
        COUNTER_RECEIVER_LIMIT_c    :   integer := 8                                            --! Selected UART data bit width
    );
    port (
        -- Input signals
        CLK                     :   in  std_logic;                                              --! Clock port
        RESET                   :   in  std_logic;                                              --! Reset port
        RE_DATA_IN_i            :   in  std_logic;                                              --! RX input data port
        -- Output signals
        RE_DONE_o               :   out std_logic;                                              --! RX done port
        RE_DATA_OUT_o           :   out std_logic_vector (7 downto 0)                           --! RX output data port
    );
end entity RECEIVER_UART;

architecture rtl of RECEIVER_UART is

    --! Signal declarations
    type state_type is (S_IDLE, S_START, S_RECEIVE, S_STOP);                                    --! Type for the states
    signal PS, NS                   :   state_type := S_IDLE;                                   --! Present and Next State signal's declaration

    constant COUNTER_FREQ_LIMIT_c   :   integer := (CLK_FREQ_c / BAUDRATE_c);                   --! Limit value for the counter
    signal COUNTER_FREQ             :   integer range 0 to COUNTER_FREQ_LIMIT_c := 0;           --! Counter signal
    signal COUNTER_RECEIVE          :   integer range 0 to COUNTER_RECEIVER_LIMIT_c := 0;       --! Counter signal for the receive state
    signal RE_SHFT                  :   std_logic_vector (7 downto 0) := (others => '0') ;      --! Shift register for the receive state
    signal COUNTER_EN               :   std_logic := '0';                                       --! Counter enabling signal
    signal COUNTER_DONE             :   std_logic := '0';                                       --! Done signal for the counter

    signal REG_IN                   :   std_logic := '0';                                       --! Register for the input data  
    signal REG_OUT                  :   std_logic_vector (7 downto 0) := (others => '0');       --! Register for the output data
    signal REG_DONE                 :   std_logic := '0';                                       --! Register for the done signal

begin

    --! Input assignments
    REG_IN <= RE_DATA_IN_i;

    --! Counting is provided with this process and be used by the FSM's process
    COUNTER_FREQ_P: process (CLK, RESET)
    begin
        if (RESET = '1') then
            COUNTER_FREQ <= 0;
            COUNTER_DONE <= '0';
        elsif (rising_edge(CLK)) then
            if (COUNTER_EN = '1') then
                if (PS <= S_START) then
                    if (COUNTER_FREQ = ((COUNTER_FREQ_LIMIT_c / 2) - 1)) then
                        COUNTER_FREQ <= 0;
                        COUNTER_DONE <= '1';
                    else
                        COUNTER_FREQ <= COUNTER_FREQ + 1;
                        COUNTER_DONE <= '0';
                    end if;
                else
                    if (COUNTER_FREQ = (COUNTER_FREQ_LIMIT_c - 1)) then
                        COUNTER_FREQ <= 0;
                        COUNTER_DONE <= '1';
                    else
                        COUNTER_FREQ <= COUNTER_FREQ + 1;
                        COUNTER_DONE <= '0';
                    end if;
                end if;
            else
                COUNTER_FREQ <= 0;
                COUNTER_DONE <= '0';
            end if;
        end if;
    end process COUNTER_FREQ_P;

    --! FSM's states are synchronized in this state
    FSM_SYNC_P: process (CLK, RESET)
    begin
        if (RESET = '1') then
            PS              <= S_IDLE;
        elsif rising_edge(CLK) then
            PS              <= NS;
        end if;
    end process;

    --! States are defined in this process
    FSM_P: process (PS, REG_IN, COUNTER_DONE)
    begin
        case (PS) is
            when (S_IDLE) =>
                if (RESET = '1') then
                    REG_OUT     <= (others => '0');
                end if;
                NS              <= S_IDLE;
                COUNTER_RECEIVE <= 0;
                COUNTER_EN      <= '0';
                RE_SHFT         <= (others => '0');
                REG_DONE        <= '0';
                if ((REG_IN = '0') and (RESET = '0')) then
                    COUNTER_EN  <= '1';
                    NS          <= S_START;
                end if;
            when (S_START) =>
                if (COUNTER_DONE = '1') then
                    if (REG_IN = '0') then
                        NS          <= S_RECEIVE;
                    else
                        NS          <= S_IDLE;
                    end if;
                end if;
            when (S_RECEIVE) =>
                if (COUNTER_RECEIVE = (COUNTER_RECEIVER_LIMIT_c - 1)) then
                    if (COUNTER_DONE = '1') then
                        REG_OUT         <= (REG_IN) & (RE_SHFT (7 downto 1));
                        NS              <= S_STOP;
                    end if;
                else
                    if (COUNTER_DONE = '1') then
                        RE_SHFT         <= (REG_IN) & (RE_SHFT (7 downto 1));
                        COUNTER_RECEIVE <= COUNTER_RECEIVE + 1;   
                    end if;
                end if;
            when (S_STOP) =>
                if (COUNTER_DONE = '1') then
                    COUNTER_EN  <= '0';
                    REG_DONE    <= '1';
                    NS          <= S_IDLE;
                end if;
            when others =>
                COUNTER_RECEIVE <= 0;
                COUNTER_EN      <= '0';
                RE_SHFT         <= (others => '0');
                REG_OUT         <= (others => '0');
                REG_DONE        <= '0';
                NS              <= S_IDLE;
        end case;  
    end process FSM_P;

    --! Output assignments
    RE_DATA_OUT_o <= (REG_OUT) when (RESET = '0') else
                     ((others => '0'));

    RE_DONE_o     <= (REG_DONE) when (RESET = '0') else
                    ('0');

end architecture;