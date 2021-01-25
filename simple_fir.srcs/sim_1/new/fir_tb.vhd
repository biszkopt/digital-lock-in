-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.std_logic_textio.all;

library STD;
use STD.textio.all;


entity fir_tb is
end;

architecture bench of fir_tb is

component fir
    generic (
        INPUT_RESOLUTION : integer;
        OUTPUT_RESOLUTION : integer;
     
        b0 : integer;
        b1 : integer;
        b2 : integer;
        b3 : integer;
        b4 : integer;
        b5 : integer;
        b6 : integer;
        b7 : integer 
    );
    Port ( 
        clk: in std_logic;
        data_in: in signed(INPUT_RESOLUTION-1 downto 0);
        data_out: out signed(OUTPUT_RESOLUTION-1 downto 0);
        en: in std_logic;
        start: in std_logic;
        reset: in std_logic
    );
end component;

component mixer
    Port (
        data_in : in signed(14 downto 0);
        ref_in : in signed(14 downto 0);
        data_out : out signed(28 downto 0);
        clk : std_logic
    );
end component;

component scaler
    generic (
        INPUT_RESOLUTION : integer;
        OUTPUT_RESOLUTION : integer;
        DIVISION_FACTOR : std_logic_vector
        );
    Port (
        data_in : in signed(INPUT_RESOLUTION-1 downto 0);
        data_out : out signed(OUTPUT_RESOLUTION-1 downto 0)
    );
end component;

component phase_shifter
    Generic (
           INPUT_RESOLUTION : integer;
           SAMPLES_DELAY : integer
           );
    Port ( 
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           data_in : in signed(INPUT_RESOLUTION - 1 downto 0);
           data_out : out signed(INPUT_RESOLUTION - 1 downto 0)
           );
end component;

  -- common
  signal clk: std_logic;
  signal en: std_logic;
  signal start: std_logic;
  signal reset: std_logic;
  
  -- fir1
  signal data_in: signed(7 downto 0); -- also system in
  signal fir1_to_mixer: signed(14 downto 0);

  -- mixer
  signal ref_in: signed(14 downto 0);
  signal mixer_to_fir2: signed(28 downto 0);
  
  -- fir2
  signal fir2_to_scaler: signed(56 downto 0);
  
  -- scaler
  signal data_out: signed(15 downto 0);
  
  -- phase shifter
  signal phase_shifter_to_mixer_iq: signed(14 downto 0);
  
  -- mixer in quadrature
  signal mixer_iq_to_fir2_iq: signed(28 downto 0);
  
  -- fir2 in quadrature
  signal fir2_iq_to_scaler_iq: signed(56 downto 0);
  
  -- scaler
  signal data_out_iq: signed(15 downto 0);
   

  constant clock_period: time := 20 ns;
  signal stop_the_clock: boolean;

   constant FILTER_ORDER: integer := 7;

   -- file related
   constant filename_in: string := "C:\Users\Win81\Vivado\Projects\simple_fir\data_in.txt";
   constant filename_lo: string := "C:\Users\Win81\Vivado\Projects\simple_fir\lo_in.txt";
   constant filename_out: string := "C:\Users\Win81\Vivado\Projects\simple_fir\data_out.txt";
   constant filename_out_iq: string := "C:\Users\Win81\Vivado\Projects\simple_fir\data_out_iq.txt";
   
   file fptr_in : text;
   file fptr_lo : text;
   file fptr_out : text;
   file fptr_out_iq : text;

begin

  fir1: fir 
  generic map (
               INPUT_RESOLUTION => 8,
               OUTPUT_RESOLUTION => 15,
        
               b0   => 8,
               b1   => -14,
               b2   => 3,
               b3   => 68,
               b4   => 68,
               b5   => 3,
               b6   => -14,
               b7   => 8
  )
  port map (clk      => clk,
            data_in  => data_in,
            data_out => fir1_to_mixer,
            en       => en,
            start    => start,
            reset    => reset );
            
  mixer_in_phase: mixer
  port map (    data_in     => fir1_to_mixer,
                ref_in      => ref_in,
                data_out    => mixer_to_fir2,
                clk => clk 
                );
                
  fir2: fir 
  generic map (
               INPUT_RESOLUTION => 29,
               OUTPUT_RESOLUTION => 57,
                    
               b0   => 8723754,
               b1   => 29616455,
               b2   => 45622067,
               b3   => 59828855,
               b4   => 59828855,
               b5   => 45622067,
               b6   => 29616455,
               b7   => 8723754
               )
  port map (clk      => clk,
            data_in  => mixer_to_fir2,
            data_out => fir2_to_scaler,
            en       => en,
            start    => start,
            reset    => reset );
                      
            
  scaler1: scaler
  generic map(
            INPUT_RESOLUTION => 57,
            OUTPUT_RESOLUTION => 16,
            DIVISION_FACTOR => "011111111111111111111111111111111111111111"
            )
  port map (data_in     => fir2_to_scaler,
            data_out    => data_out);
            
  phase_shifter1: phase_shifter
  generic map(
            INPUT_RESOLUTION => 15,
            SAMPLES_DELAY => 1
            )
  port map(
            data_in => ref_in,
            data_out => phase_shifter_to_mixer_iq,
            clk => clk,
            reset => reset
           );   
          
  mixer_iq: mixer
  port map (    data_in     => fir1_to_mixer,
                ref_in      => phase_shifter_to_mixer_iq,
                data_out    => mixer_iq_to_fir2_iq,
                clk => clk 
                );
                
  fir2_iq: fir 
  generic map (
               INPUT_RESOLUTION => 29,
               OUTPUT_RESOLUTION => 57,
                    
               b0   => 8723754,
               b1   => 29616455,
               b2   => 45622067,
               b3   => 59828855,
               b4   => 59828855,
               b5   => 45622067,
               b6   => 29616455,
               b7   => 8723754
               )
  port map (clk      => clk,
            data_in  => mixer_iq_to_fir2_iq,
            data_out => fir2_iq_to_scaler_iq,
            en       => en,
            start    => start,
            reset    => reset );
            
              scaler_iq: scaler
  generic map(
            INPUT_RESOLUTION => 57,
            OUTPUT_RESOLUTION => 16,
            DIVISION_FACTOR => "011111111111111111111111111111111111111111"
            )
  port map (data_in     => fir2_iq_to_scaler_iq,
            data_out    => data_out_iq);                            
                                  

  stimulus: process
  
  
    -- file related
    constant FILE_IN_BITS  : integer := 8;
    variable matlab_data   : integer;
    variable lo_signal   : integer;

    
    variable fstatus       : file_open_status;
    variable file_line     : line;
  
  begin
  
    -- Put initialisation code here

    reset <= '1';
    en <= '0';
    start <= '0';
    data_in <= (others => '0');
    
    ref_in <= (others => '0');
            
    wait for 10 ns;
    reset <= '0';
    wait for 240 ns;
    
    en <= '1';
    wait for 32 ns;
    
    -- Put test bench stimulus code here
    
    start <= '1';
    wait for 60 ns;
    
    -- file related
    file_open(fstatus, fptr_in, filename_in, read_mode);
    file_open(fstatus, fptr_lo, filename_lo, read_mode);
    file_open(fstatus, fptr_out, filename_out, write_mode);
    file_open(fstatus, fptr_out_iq, filename_out_iq, write_mode);
    
    -- zdecydowaæ czy pierwsza iteracja oddzielnie, ¿eby zapisywane dane do pliku nie ³apa³y niepotrzebnego zera
    wait for 10 ns;
    
    while (not endfile(fptr_in)) loop
    
        wait for 10 ns;
        
        -- signal in
        readline(fptr_in, file_line);
        read(file_line, matlab_data);
        data_in <= to_signed(matlab_data,8);
        
        wait for 10 ns;

        -- local oscillator in -- MUST BE DELAYED (one clock cycle?) RELATIVE TO SIGNAL INPUT TO PROPERLY SYNCHRONISE WITH LATTER ELEMENTS
        readline(fptr_lo, file_line);
        read(file_line, lo_signal);
        ref_in <= to_signed(lo_signal,15);
        
        -- write output data to file
        write(file_line, std_logic_vector(data_out), left, 5); 
        writeline(fptr_out, file_line);
        
        write(file_line, std_logic_vector(data_out_iq), left, 5); 
        writeline(fptr_out_iq, file_line);
    end loop;
    
    -- keep writing values till filter response zeroes
    for i in 0 to FILTER_ORDER loop
        wait for 20 ns;
        data_in  <= (others => '0');
        write(file_line, std_logic_vector(data_out), left, 5); 
        writeline(fptr_out, file_line);
    end loop;
    
    
    wait for 200 ns;
    start <= '0';
    wait for 40 ns;
    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    wait for 60 ns;
    
    file_close(fptr_in);
    file_close(fptr_out);


    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  