--*********************************************************************
--  saed_mc : SRAM_128_12 Vhdl description                          *
--  ---------------------------------------------------------------   *
--  Filename      : /home/rsomvan/VSLI_598/eecs598-02-fa-2023/verilog/LMS/memory/mc_work/SRAM_128_12.vhdl                         *
--  SRAM name     : SRAM_128_12                                       *
--  Word width    : 12    bits                                        *
--  Word number   : 128                                               *
--  Adress width  : 7     bits                                        *
--  ---------------------------------------------------------------   *
--  Creation date : Wed December 06 2023                              *
--*********************************************************************

use std.textio.all;
Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
entity SRAM_128_12 is
	port (
		A   : in  std_logic_vector( 6  downto 0 );
		O   : out std_logic_vector( 11  downto 0 );
		I   : in  std_logic_vector( 11  downto 0 );
		WEB  : in  std_logic;
		CSB  : in  std_logic;
		OEB  : in  std_logic;
		CE  : in  std_logic
	);

end SRAM_128_12 ;

architecture SRAM_128_12_behaviour of SRAM_128_12 is
begin
	mem: process
		constant numAddr: natural := 7;
		constant numWords: natural := 128;
		constant wordLength: natural := 12;

		constant nw_m: natural := numWords-1;
		constant wl_m: natural := wordLength-1;
		constant low_address: natural := 0;
		constant high_address: natural := nw_m;
		subtype word is std_logic_vector( wl_m downto 0 );
		type memory_array is
			array (natural range low_address to high_address) of word;
		variable mem: memory_array;
		variable address   : natural;
		variable data_out1 : word;
		

	begin
		O <= "ZZZZZZZZZZZZ";
	

		loop

			if  ((CSB = '0') and (CE= '1') and (CE'event )  and (CE'last_value = '0'))	then
	 			address := conv_integer( A );
 				if WEB = '0' then
             			mem( address ) := I(wl_m downto 0);
            				elsif WEB = '1' then
						data_out1 := mem( address );
						if OEB = '0' then
							O <= data_out1;
						else 
							O <= "ZZZZZZZZZZZZ";
						end if;
					else
						O <= "ZZZZZZZZZZZZ";
				end if;
			end if;

			if ( OEB = '0') then
				O <= data_out1;
				else
					O <= "ZZZZZZZZZZZZ";
			    end if;
				wait on CE, OEB;
		end loop;
	end process;

end SRAM_128_12_behaviour;