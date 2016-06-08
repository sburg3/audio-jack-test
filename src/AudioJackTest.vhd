----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/23/2016 04:21:59 PM
-- Design Name: 
-- Module Name: AudioJackTest - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AudioJackTest is
    Port ( CLK100MHZ : in STD_LOGIC;
           AUD_PWM : out STD_LOGIC;
           AUD_SD : out STD_LOGIC;
           vauxn3 : in STD_LOGIC;
           vauxp3 : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR(15 downto 0));
end AudioJackTest;

architecture Behavioral of AudioJackTest is

component PWMDriver is
    Generic ( WIDTH : integer := 12);
    Port ( clk_100 : in STD_LOGIC;
           pwm_level : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           pwm_out : out STD_LOGIC);
end component;

COMPONENT xadc_wiz_0
  PORT (
    di_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    daddr_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    den_in : IN STD_LOGIC;
    dwe_in : IN STD_LOGIC;
    drdy_out : OUT STD_LOGIC;
    do_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    dclk_in : IN STD_LOGIC;
    vp_in : IN STD_LOGIC;
    vn_in : IN STD_LOGIC;
    vauxp3 : IN STD_LOGIC;
    vauxn3 : IN STD_LOGIC;
    channel_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    eoc_out : OUT STD_LOGIC;
    alarm_out : OUT STD_LOGIC;
    eos_out : OUT STD_LOGIC;
    busy_out : OUT STD_LOGIC
  );
END COMPONENT;

signal adc_result : std_logic_vector(15 downto 0);
signal pwm_int : std_logic;
signal pwm_input : std_logic_vector(11 downto 0);
signal enable : std_logic;
signal ready : std_logic;

begin

pd0 : PWMDriver
port map (
    clk_100 => CLK100MHZ,
    pwm_level => pwm_input,
    pwm_out => pwm_int
);

xw0 : xadc_wiz_0
  PORT MAP (
    di_in => (others => '0'),
    daddr_in => "0010011",
    den_in => enable,
    dwe_in => '0',
    drdy_out => ready,
    do_out => adc_result,
    dclk_in => CLK100MHZ,
    vp_in => '0',
    vn_in => '0',
    vauxp3 => vauxp3,
    vauxn3 => vauxn3,
    channel_out => open,
    eoc_out => enable,
    alarm_out => open,
    eos_out => open,
    busy_out => open
  );

AUD_SD <= '1';
AUD_PWM <= '0' when pwm_int = '0' else 'Z';
--LED <= adc_result(15 downto 4);

ld: for i in 0 to 15 generate
begin
    LED(i) <= '1' when unsigned(adc_result(15 downto 4)) > (1536+i*64) else '0';
end generate ld;

process(CLK100MHZ)
begin
    if rising_edge(CLK100MHZ) then
        if ready = '1' then
            pwm_input <= adc_result(15 downto 4);
        end if;
    end if;
end process;

end Behavioral;
