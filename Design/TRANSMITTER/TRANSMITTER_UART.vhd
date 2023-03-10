---------------------------------------------------------------------------------------
-- Engineer: IBRAHIM AYAZ                                                            --
-- Create Date: 01.03.2023 18:00:00                                                  --
-- Design Name: TRANSMITTER_UART.vhd                                                 --
--                                                                                   --
-- Description: Digital design for the transmitter part of the UART communication    --
-- protocol.                                                                         --
--                                                                                   --
-- Output: The output data is a serialized UART data.                                --
---------------------------------------------------------------------------------------

-- Library declaration
library IEEE;
use IEEE.std_logic_1164.all;

entity TRANSMITTER_UART is
    generic (
        CLK_FREQ_c              :   integer := 100_000_000;                 --! Clock frequency
        BAUDRATE_c              :   integer := 115_200;                     --! UART baudrate
        COUNTER_SEND_LIMIT_c    :   integer := 8;                           --! Selected UART data bit width
        COUNTER_STOP_LIMIT_c    :   integer := 2                            --! Stop state width
    );
    port (
        -- Input signals
        CLK                     :   in  std_logic;                          --! Clock port
        RESET                   :   in  std_logic;                          --! Reset port
        TR_DATA_EN              :   in  std_logic;                          --! Data enable port which is asserted by the data sender to the TX
        TR_DATA_IN_i            :   in  std_logic_vector (7 downto 0);      --! TX input data port
        -- Output signals
        TR_READY_o              :   out std_logic;                          --! TX ready port
        TR_DONE_o               :   out std_logic;                          --! TX done port
        TR_DATA_OUT_o           :   out std_logic                           --! TX output data port
    );
end TRANSMITTER_UART;

architecture TRANSMITTER_UART_rtl of TRANSMITTER_UART is

    --! Signal declarations
    type state_type is (S_IDLE, S_START, S_SEND, S_STOP);                                   --! Type for the states
    signal PS, NS                   :   state_type := S_IDLE;                               --! Present and Next State signal's declaration

    constant COUNTER_FREQ_LIMIT_c   :   integer := (CLK_FREQ_c / BAUDRATE_c);               --! Limit value for the counter
    signal COUNTER_FREQ             :   integer range 0 to COUNTER_FREQ_LIMIT_c := 0;       --! Counter signal
    signal COUNTER_SEND             :   integer range 0 to COUNTER_SEND_LIMIT_c := 0;       --! Counter signal for the send state
    signal COUNTER_STOP             :   integer range 0 to COUNTER_STOP_LIMIT_c := 0;       --! Counter signal for the stop state
    signal TR_SHFT                  :   std_logic_vector (7 downto 0) := (others => '0') ;  --! Shift register for the send state
    signal COUNTER_EN               :   std_logic := '0';                                   --! Counter enabling signal
    signal COUNTER_DONE             :   std_logic := '0';                                   --! Done signal for the counter

    signal DATA_IN                  :   std_logic_vector (7 downto 0) := (others => '0');   --! Register for the input data
    signal REG_OUT                  :   std_logic := '0';                                   --! Register for the output data
    signal REG_DONE                 :   std_logic := '0';                                   --! Register for the output done signal

begin

    --! Input assignments
    DATA_IN <= TR_DATA_IN_i;

    --! Counting is provided with this process and be used by the FSM's process
    COUNTER_FREQ_P: process (CLK, RESET)
    begin
        if (RESET = '1') then
            COUNTER_FREQ <= 0;
            COUNTER_DONE <= '0';
        elsif (rising_edge(CLK)) then
            if (COUNTER_EN) then
                if (COUNTER_FREQ = (COUNTER_FREQ_LIMIT_c - 1)) then
                    COUNTER_FREQ <= 0;
                    COUNTER_DONE <= '1';
                else
                    COUNTER_FREQ <= COUNTER_FREQ + 1;
                    COUNTER_DONE <= '0';
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
    end process FSM_SYNC_P;

    --! States are defined in this process
    FSM_P: process (PS, TR_DATA_EN, COUNTER_DONE)
    begin
        case (PS) is
            when (S_IDLE) =>
                NS                  <= S_IDLE;
                REG_OUT             <= '1';
                REG_DONE            <= '0';
                TR_SHFT             <= (others => '0');
                COUNTER_EN          <= '0';
                COUNTER_SEND        <= 0;
                COUNTER_STOP        <= 0;
                if ((TR_DATA_EN = '1') and (RESET = '0')) then
                    REG_OUT         <= '0';
                    COUNTER_EN      <= '1';
                    NS              <= S_START;
                end if; 
            when (S_START) =>
                if (COUNTER_DONE = '1') then
                    TR_SHFT         <= DATA_IN;
                    NS              <= S_SEND; 
                end if;
            when (S_SEND) =>
                REG_OUT                 <= TR_SHFT (0);
                if (COUNTER_SEND = (COUNTER_SEND_LIMIT_c - 1)) then
                    if (COUNTER_DONE = '1') then
                        NS              <= S_STOP;
                    end if;
                else
                    if (COUNTER_DONE = '1') then
                        TR_SHFT         <= TR_SHFT (0) & TR_SHFT (7 downto 1);
                        COUNTER_SEND    <= COUNTER_SEND + 1;
                    end if;
                end if;
            when (S_STOP) =>
                REG_OUT                 <= '1';
                if (COUNTER_STOP = (COUNTER_STOP_LIMIT_c - 1)) then
                    if (COUNTER_DONE = '1') then
                        COUNTER_EN      <= '0';
                        REG_DONE        <= '1';
                        TR_SHFT         <= (others => '0');
                        NS              <= S_IDLE;
                    end if;
                else
                    if (COUNTER_DONE = '1') then
                        COUNTER_STOP    <= COUNTER_STOP + 1;
                    end if;
                end if;
            when others =>
                REG_OUT         <= '1';
                REG_DONE        <= '0';
                TR_SHFT         <= (others => '0');
                COUNTER_EN      <= '0';
                COUNTER_SEND    <= 0;
                COUNTER_STOP    <= 0;
                NS              <= S_IDLE;
        end case;  
    end process FSM_P;

    --! Output assignments
    TR_READY_o    <= ('1') when ((PS = S_IDLE) and (RESET = '0')) else
                     ('0');

    TR_DATA_OUT_o <= (REG_OUT) when (RESET = '0') else
                     ('1');

    TR_DONE_o     <= (REG_DONE) when (RESET = '0') else
                     ('0');
    
end TRANSMITTER_UART_rtl;