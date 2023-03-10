-- Library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity TB_UART_TOP_LOOPBACK is
    generic (
        CLK_FREQ_c              :   integer := 100_000_000; 
        BAUDRATE_c              :   integer := 115_200; 
        COUNTER_SEND_LIMIT_c    :   integer := 8; 
        COUNTER_STOP_LIMIT_c    :   integer := 2
    );
end entity TB_UART_TOP_LOOPBACK;

architecture rtl of TB_UART_TOP_LOOPBACK is

    component UART_TOP_LOOPBACK is
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
            RE_DONE_o               :   out std_logic;
            RE_DATA_OUT_o           :   out std_logic_vector (7 downto 0)
        );
    end component;

    signal CLK                     :   std_logic    := '0';
    signal RESET                   :   std_logic    := '0';
    signal TR_DATA_EN              :   std_logic    := '0';
    signal TR_DATA_IN_i            :   std_logic_vector (7 downto 0) := (others => '0');
    signal TR_READY_o              :   std_logic    := '0';
    signal TR_DONE_o               :   std_logic    := '0';
    signal RE_DONE_o               :   std_logic    := '0';
    signal RE_DATA_OUT_o           :   std_logic_vector (7 downto 0) := (others => '0');    

    constant CLK_PERIOD            :   time         := 10 ns;
    constant COUNTER_FREQ          :   time         := 8.68 us;

begin

    TOP_DUT: UART_TOP_LOOPBACK
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
            RE_DONE_o               =>   RE_DONE_o,
            RE_DATA_OUT_o           =>   RE_DATA_OUT_o
        );

    CLK_P:  process
    begin
        CLK <= '0';
        wait for (CLK_PERIOD / 2);
        CLK <= '1';
        wait for (CLK_PERIOD / 2);
    end process;

    STIMULI_P: process
        variable pass_count     :   integer := 0;
        variable fail_count     :   integer := 0;
    begin
        -- Reseting at first
        wait for (COUNTER_FREQ);
        RESET   <= '1';
        wait for (COUNTER_FREQ);
        RESET   <= '0';

        wait for (COUNTER_FREQ);

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"AB";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait until (TR_DONE_o = '1');

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
        end if;

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"BC";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait until (TR_DONE_o = '1');

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
        end if;

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"CD";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait until (TR_DONE_o = '1');

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
            fail_count := fail_count + 1;
        end if;

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"DE";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait until (TR_DONE_o = '1');

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
            fail_count := fail_count + 1;
        end if;

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"EF";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait until (TR_DONE_o = '1');

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
            fail_count := fail_count + 1;
        end if;

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"FF";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait for (COUNTER_FREQ);
        RESET   <= '1';
        wait for (COUNTER_FREQ);
        RESET   <= '0';
        TR_DATA_IN_i     <= x"00";
        wait for (COUNTER_FREQ);

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
            fail_count := fail_count + 1;
        end if;

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"77";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait until (TR_DONE_o = '1');

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
            fail_count := fail_count + 1;
        end if;

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"66";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait until (TR_DONE_o = '1');

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
            fail_count := fail_count + 1;
        end if;

        -- Stimuli generation
        TR_DATA_EN       <= '1';
        TR_DATA_IN_i     <= x"33";
        wait for (COUNTER_FREQ);
        TR_DATA_EN       <= '0';
        wait until (TR_DONE_o = '1');

        -- Output check
        if ((TR_DATA_IN_i = RE_DATA_OUT_o) and (RESET = '0')) then
            report "[PASS] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o);
            pass_count := pass_count + 1;
        else
            assert false
                report "[ERROR] " & "Input data is : 0x" & to_hstring(TR_DATA_IN_i) & " vs Output data is : 0x" & to_hstring(RE_DATA_OUT_o)
                severity WARNING;
            fail_count := fail_count + 1;
        end if;

        -- End of the simulation
        report "Pass count is : " & integer'image(pass_count);
        report "Fail count is : " & integer'image(fail_count);
        assert false
            report "SIM DONE"
            severity failure;
    end process;

end architecture;