---------------------------------------------------------------------------------------
-- Engineer: IBRAHIM AYAZ                                                            --
-- Create Date: 10.03.2023 18:00:00                                                  --
-- Design Name: UART_TOP_LOOPBACK.vhd                                                --
--                                                                                   --
-- Description: Digital design for the TOP module of the UART communication          --
-- protocol. (Loopback design)                                                       --
--                                                                                   --
-- Output: The output data is a parallel UART data.                                  --
---------------------------------------------------------------------------------------

--! Library declaration
library IEEE;
use IEEE.std_logic_1164.all;

entity UART_TOP_LOOPBACK is
    generic (
        CLK_FREQ_c              :   integer := 100_000_000;                         --! Clock frequency 
        BAUDRATE_c              :   integer := 115_200;                             --! UART baudrate
        COUNTER_SEND_LIMIT_c    :   integer := 8;                                   --! Selected UART data bit width
        COUNTER_STOP_LIMIT_c    :   integer := 2                                    --! Stop state width
    );
    port (
        -- Input signals
        CLK                     :   in  std_logic;                                  --! Clock port
        RESET                   :   in  std_logic;                                  --! Reset port
        TR_DATA_EN              :   in  std_logic;                                  --! Data enable port which is asserted by the data sender to the TX
        TR_DATA_IN_i            :   in  std_logic_vector (7 downto 0);              --! TX input data port
        -- Output signals
        TR_READY_o              :   out std_logic;                                  --! TX ready port
        TR_DONE_o               :   out std_logic;                                  --! TX done port
        RE_DONE_o               :   out std_logic;                                  --! RX done port
        RE_DATA_OUT_o           :   out std_logic_vector (7 downto 0)               --! RX output data port
    );
end entity UART_TOP_LOOPBACK;

architecture rtl of UART_TOP_LOOPBACK is

    --! Component declarations
    component TRANSMITTER_UART is
        generic (
            CLK_FREQ_c              :   integer := 100_000_000; 
            BAUDRATE_c              :   integer := 115_200; 
            COUNTER_SEND_LIMIT_c    :   integer := 8; 
            COUNTER_STOP_LIMIT_c    :   integer := 2 
        );
        port (
            --! Input signals
            CLK                     :   in  std_logic;
            RESET                   :   in  std_logic;
            TR_DATA_EN              :   in  std_logic;
            TR_DATA_IN_i            :   in  std_logic_vector (7 downto 0);
            --! Output signals
            TR_READY_o              :   out std_logic;
            TR_DONE_o               :   out std_logic;
            TR_DATA_OUT_o           :   out std_logic
        );
    end component;

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

    -- Signal declarations
    signal TR_DATA_OUT  : std_logic := '0';                                         --! TX output data intermediate signal
    signal RE_DATA_IN   : std_logic := '0';                                         --! RX input data intermediate signal

begin

    --! TX to RX data connection
    RE_DATA_IN <= TR_DATA_OUT;

    -- Component instantiations
    --! TX instantiation
    TR_PM: TRANSMITTER_UART
    generic map (
        CLK_FREQ_c              =>   CLK_FREQ_c, 
        BAUDRATE_c              =>   BAUDRATE_c, 
        COUNTER_SEND_LIMIT_c    =>   COUNTER_SEND_LIMIT_c, 
        COUNTER_STOP_LIMIT_c    =>   COUNTER_STOP_LIMIT_c
    )
    port map (
        CLK                     =>   CLK,
        RESET                   =>   RESET,
        TR_DATA_EN              =>   TR_DATA_EN,
        TR_DATA_IN_i            =>   TR_DATA_IN_i,
        TR_READY_o              =>   TR_READY_o,
        TR_DONE_o               =>   TR_DONE_o,
        TR_DATA_OUT_o           =>   TR_DATA_OUT
    );

    --! RX instantiation
    RE_PM: RECEIVER_UART
    generic map (
        CLK_FREQ_c                  =>   CLK_FREQ_c, 
        BAUDRATE_c                  =>   BAUDRATE_c, 
        COUNTER_RECEIVER_LIMIT_c    =>   COUNTER_SEND_LIMIT_c 
    )
    port map (
        CLK                         =>   CLK,
        RESET                       =>   RESET,
        RE_DATA_IN_i                =>   RE_DATA_IN,
        RE_DONE_o                   =>   RE_DONE_o,
        RE_DATA_OUT_o               =>   RE_DATA_OUT_o
    );

end architecture;