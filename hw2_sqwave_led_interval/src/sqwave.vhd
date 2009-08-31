-----------------------------------------------------------------------------
--assignment 2: 
--2)	Generate 10Hz, 5Hz and 2Hz square wave (50% duty cycle) from 50MGz system clock. 
--      Output that to one of I/O socket; using oscilloscope to capture the waveform.
--a.	SW[2],  used as enable/disable the function.
--b.	South button switch, as async-reset to initialize the function.
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.numeric_std.all;

entity sqwave is
   generic (led_cnt_bit  : integer :=8);
   --generic (led_cnt_bit  : integer :=16);
    port(
            clk_50m        : in std_logic;                        --synchronous clock
            btn_south      : in std_logic;                        --push button
            sw             : in  std_logic_vector (3 downto 0);   --dip switch

            tst_p0         : out std_logic;                       --10 Hz square wave, 50% duty cycle
            led            : out std_logic_vector (7 downto 0)
        );
end sqwave;

architecture rtl of sqwave is
   ---------- component start ----------
   component cnt
      generic (n:       integer :=8);
      port (
              clk            : in std_logic;
              rst            : in std_logic;

              cnt_ini        : in std_logic_vector(n-1 downto 0);   --initial value of counter
              cnt_ld         : in std_logic;                        --load initial
              cnt_en         : in std_logic;                        --enable count
              cnt_end        : in std_logic_vector(n-1 downto 0);   --end value of count

              cnt_o          : out std_logic_vector(n-1 downto 0);  --output of count
              cnt_e          : out std_logic                        --indicator of end
           );
   end component;
   ---------- signal start ----------
   --input 
   signal clk              : std_logic;
   signal led3_o        : std_logic := '0';
   signal led4_o        : std_logic := '0';
   signal led5_o        : std_logic := '0';
   signal cnt_o1        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal cnt_o2        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal cnt_o3        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal cnt_o4        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal cnt_o5        : std_logic_vector(led_cnt_bit-1 downto 0);      --led counter output
   signal cnt_trg1      : std_logic := '0';                          --trigger to lit next led
   signal cnt_trg2      : std_logic := '0';                          --trigger to lit next led
   signal cnt_trg3      : std_logic := '0';                          --trigger to lit next led
   signal cnt_trg4      : std_logic := '0';                          --trigger to lit next led
   signal cnt_trg5      : std_logic := '0';                          --trigger to lit next led
   --output
   signal arst             : std_logic;                          
   signal led_cnt_ld       : std_logic;                          --led counter load signal
   signal sqwave_o          : std_logic    := '0'; 

begin

   cnt1: cnt 
      generic map (n    =>led_cnt_bit)
      --generic map (n    =>16)
      port map 
      (  
         clk            =>clk,
         --clk            =>clk_50m,
         rst            =>arst,

         cnt_ini        =>x"01",
         --cnt_ini        =>led_cnt_init,
         --cnt_ld         =>led_cnt_ld,
         cnt_ld         =>'0',
         cnt_en         =>'1',
         cnt_end        =>x"FA",  --250d

         cnt_e          =>cnt_trg1, 
         cnt_o          =>cnt_o1
      );

   cnt2: cnt 
      generic map (n    =>led_cnt_bit)
      port map 
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>cnt_trg1,
         cnt_end        =>x"FA",  --250d 

         cnt_e          =>cnt_trg2, 
         cnt_o          =>cnt_o2
      );

   cnt3: cnt 
      --10Hz = > 0.1s    
      --50*10^6/10=5000000;  5000000/250/250=80; 80/2=40)
      generic map (n    =>led_cnt_bit)
      port map 
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>cnt_trg2,
         cnt_end        =>x"28",  --40d

         cnt_e          =>cnt_trg3, 
         cnt_o          =>cnt_o3
      );

   cnt4: cnt 
      --5Hz = > 0.2s     
      --50*10^6/5=10000000;  10000000/250/250=160; 160/2=80
      generic map (n    =>led_cnt_bit)
      port map 
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>cnt_trg2,
         cnt_end        =>x"50",  --80d

         cnt_e          =>cnt_trg4, 
         cnt_o          =>cnt_o4
      );

   cnt5: cnt 
      --2Hz => 0.5s     
      --50*10^6/2=25000000;  25000000/250/250=400; 400/2=200
      generic map (n    =>led_cnt_bit)
      port map 
      (  
         clk            =>clk,
         rst            =>arst,

         cnt_ini        =>x"01",
         cnt_ld         =>'0',
         cnt_en         =>cnt_trg2,
         cnt_end        =>x"C8",  --200d

         cnt_e          =>cnt_trg5, 
         cnt_o          =>cnt_o5
      );

   clk <= clk_50m;
   arst <= '1' when (btn_south='1') else '0';
   led_cnt_ld <= '1' when arst = '1' else '0';

   --square wave output
   sqwave_p: process (clk, arst)
   begin
       if arst = '1' then
           sqwave_o <= '0';
       elsif rising_edge(clk) then
           if sw(2)='1' then
               --if enable
               if cnt_trg3='1' and sw(0)='1' and sw(1)='0' and sw(3)='0' then
                   --10 Hz
                   sqwave_o <= not sqwave_o;
               elsif cnt_trg4='1' and sw(0)='1' and sw(1)='1' and sw(3)='0' then
                   --5 Hz
                   sqwave_o <= not sqwave_o;
               elsif cnt_trg5='1' and sw(0)='1' and sw(1)='1' and sw(3)='1' then
                   --2 Hz
                   sqwave_o <= not sqwave_o;
               end if;
           end if;
       end if;
   end process;
   tst_p0 <= sqwave_o;

   led_cnt_p: process (clk, arst)
   begin
       if arst = '1' then
           led3_o <= '0';
           led4_o <= '0';
           led5_o <= '0';
       elsif rising_edge(clk) then
           if sw(2)='1' then
              --if enable
               if cnt_trg3='1' and sw(0)='1' and sw(1)='0' and sw(3)='0' then
                  --10 Hz
                   led3_o <= not led3_o;
               elsif cnt_trg4='1' and sw(0)='1' and sw(1)='1' and sw(3)='0' then
                  --5 Hz
                   led4_o <= not led4_o;
               elsif cnt_trg5='1' and sw(0)='1' and sw(1)='1' and sw(3)='1' then
                  --2 Hz
                   led5_o <= not led5_o;
               end if;
           end if;
       end if;
   end process;
   led(3) <= led3_o;
   led(4) <= led4_o;
   led(5) <= led5_o;

   led(2 downto 0) <= "000";
   led(7 downto 6) <= "00";

end rtl;
