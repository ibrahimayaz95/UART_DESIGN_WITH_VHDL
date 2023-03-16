# Entity: RECEIVER_UART 

- **File**: RECEIVER_UART.vhd
## Diagram

![Diagram](RECEIVER_UART.svg "Diagram")
## Description

 Library declaration
## Generics

| Generic name             | Type    | Value       | Description                  |
| ------------------------ | ------- | ----------- | ---------------------------- |
| CLK_FREQ_c               | integer | 100_000_000 | Clock frequency              |
| BAUDRATE_c               | integer | 115_200     | UART baudrate                |
| COUNTER_RECEIVER_LIMIT_c | integer | 8           | Selected UART data bit width |
## Ports

| Port name     | Direction | Type                          | Description         |
| ------------- | --------- | ----------------------------- | ------------------- |
| CLK           | in        | std_logic                     | Clock port          |
| RESET         | in        | std_logic                     | Reset port          |
| RE_DATA_IN_i  | in        | std_logic                     | RX input data port  |
| RE_DONE_o     | out       | std_logic                     | RX done port        |
| RE_DATA_OUT_o | out       | std_logic_vector (7 downto 0) | RX output data port |
## Signals

| Name            | Type                                        | Description                                 |
| --------------- | ------------------------------------------- | ------------------------------------------- |
| PS              | state_type                                  | Present and Next State signal's declaration |
| NS              | state_type                                  | Present and Next State signal's declaration |
| COUNTER_FREQ    | integer range 0 to COUNTER_FREQ_LIMIT_c     | Counter signal                              |
| COUNTER_RECEIVE | integer range 0 to COUNTER_RECEIVER_LIMIT_c | Counter signal for the receive state        |
| RE_SHFT         | std_logic_vector (7 downto 0)               | Shift register for the receive state        |
| COUNTER_EN      | std_logic                                   | Counter enabling signal                     |
| COUNTER_DONE    | std_logic                                   | Done signal for the counter                 |
| REG_IN          | std_logic                                   | Register for the input data                 |
| REG_OUT         | std_logic_vector (7 downto 0)               | Register for the output data                |
| REG_DONE        | std_logic                                   | Register for the done signal                |
## Constants

| Name                 | Type    | Value                     | Description                 |
| -------------------- | ------- | ------------------------- | --------------------------- |
| COUNTER_FREQ_LIMIT_c | integer | (CLK_FREQ_c / BAUDRATE_c) | Limit value for the counter |
## Types

| Name       | Type                                                                                                                                             | Description         |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------- |
| state_type | (S_IDLE,<br><span style="padding-left:20px"> S_START,<br><span style="padding-left:20px"> S_RECEIVE,<br><span style="padding-left:20px"> S_STOP) | Type for the states |
## Processes
- COUNTER_FREQ_P: ( CLK, RESET )
  - **Description**
  Counting is provided with this process and be used by the FSM's process 
- FSM_SYNC_P: ( CLK, RESET )
  - **Description**
  FSM's states are synchronized in this state 
- FSM_P: ( PS, REG_IN, COUNTER_DONE )
  - **Description**
  States are defined in this process 
