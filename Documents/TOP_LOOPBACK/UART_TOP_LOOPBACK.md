# Entity: UART_TOP_LOOPBACK 

- **File**: UART_TOP_LOOPBACK.vhd
## Diagram

![Diagram](UART_TOP_LOOPBACK.svg "Diagram")
## Description

 Library declaration
## Generics

| Generic name         | Type    | Value       | Description                  |
| -------------------- | ------- | ----------- | ---------------------------- |
| CLK_FREQ_c           | integer | 100_000_000 | Clock frequency              |
| BAUDRATE_c           | integer | 115_200     | UART baudrate                |
| COUNTER_SEND_LIMIT_c | integer | 8           | Selected UART data bit width |
| COUNTER_STOP_LIMIT_c | integer | 2           | Stop state width             |
## Ports

| Port name     | Direction | Type                          | Description                                                     |
| ------------- | --------- | ----------------------------- | --------------------------------------------------------------- |
| CLK           | in        | std_logic                     | Clock port                                                      |
| RESET         | in        | std_logic                     | Reset port                                                      |
| TR_DATA_EN    | in        | std_logic                     | Data enable port which is asserted by the data sender to the TX |
| TR_DATA_IN_i  | in        | std_logic_vector (7 downto 0) | TX input data port                                              |
| TR_READY_o    | out       | std_logic                     | TX ready port                                                   |
| TR_DONE_o     | out       | std_logic                     | TX done port                                                    |
| RE_DONE_o     | out       | std_logic                     | RX done port                                                    |
| RE_DATA_OUT_o | out       | std_logic_vector (7 downto 0) | RX output data port                                             |
## Signals

| Name        | Type      | Description                        |
| ----------- | --------- | ---------------------------------- |
| TR_DATA_OUT | std_logic | TX output data intermediate signal |
| RE_DATA_IN  | std_logic | RX input data intermediate signal  |
## Instantiations

- TR_PM: TRANSMITTER_UART
  - **Description**
  TX instantiation

- RE_PM: RECEIVER_UART
  - **Description**
  RX instantiation

