--------------------------------------------------------
--  DDL for Package Body PAY_1099R_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_1099R_DATA" AS
/* $Header: py1099rd.pkb 115.7 99/07/17 05:40:51 porting ship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_1099R_data

    Description :  Sets up the data to provide 1099R reporting.

    Uses        :

    Change List
    -----------
     Date        Name     Vers    Bug No     Description
     ----        ----     ----    ------     -----------
     07-AUG-96   ATAYLOR  40.0               Created.
     28-SEP-96   HEKIM    40.1               All format definitions stored in plsql
					        tables to be called in a loop.
     8-OCT-96    HEKIM    40.2               Added block definition for states.
     12-NOV-96   HEKIM    40.3               Cleaned up loop, and took out state blocks
					        which use k-record.
     13-NOV-96   GPERRY   40.4               Added Exit Statement.
     20-DEC-96   HEKIM    40.5               Added NY and MI formats.
     31-JAN-97   HEKIM    40.6               Added transmitter info for WV
     26-FEB-97   HEKIM    40.7               Changed state blocks to follow state cursor
     06-MAR-97   HEKIM    40.8               NY now follows 1099R modified SQWL formula.
     20-MAR-97   HEKIM    40.9               Changed K record structure for 1099R_FED
     04-FEB-98   EKIM     40.10              Added Georgia for '1099R_State'report format.
     26-MAY-98   NBRISTOW 40.14              Added report_category to
                                             pay_report_format_mappings.
     05-OCT-98   AHANDA   40.15    765557    Added code to make the 1099R
                                             mag run on the Archiver Process
                                             and NC format.
     20-NOV-98   AHANDA   40.19    755093    Changed Report Definition for the EOY-III
                                             patch.
     04-DEC-98   AHANDA   40.20              Changed Report Definition for Kansas and Iowa
     07-DEC-98   AHANDA   40.21              Changed script to create the 1099R_STATE report
                                             defn. first and then create the 1099R_STATE_NFED.
     07-DEC-98   AHANDA   40.22/110.4        Changed the frequency for
                                             TIB4_INTERMEDIATE_TOTALS for North Carolina
     17-DEC-98   AHANDA   40.23/110.5        Changed the format for South Carolina as
                                             they added a K record.
     16-JAN-98   AHANDA   40.25/110.6        Changed no no of columns returned
															by magw2_transmitter to 12
     27-JAN-99  AHANDA    40.26/110.7 808958 Modified the Report format for 1099R_STATE to
                                             include NM, AR. Also changed the script to first
                                             delete all the report formats and then insert.
--
     08-MAR-99  MREID          110.8 845184  Changed dbms_output calls to use
                                             hr_utility
/**/
----------------------------------------------------------------------------------------
-- Name
--   setup
-- Purpose
--   Sets up structure of 1099R Federal and State reports for the generic
--   magnetic tape harness.
-- Arguments
--   None
-- Notes:
--   This file contains the following report definitions:
--  1099R_FED : Federal 1099R format
--  1099R_STATE : Federal 1099R format with variations, omits k-records
--  1099R_WV  : Custom 1099R format for West Virginia
--  1099R_IND : 1099R format for Indiana
--  1099R_MI  : 1099R format for Michigan
--  1099R_NY  : 1099R format for New York
--  1099R_NC  : 1099R format for North Carolina
----------------------------------------------------------------------------------------
/**/
--
PROCEDURE Setup IS
--
  -- Define table structures to hold parameter details.
  --
  -- note: the parameter prefix 'lt' denotes a local table
  --                            'li' denotes a local table index
  --Report Definitions
  lt_report_format   		char30_data_table;
  lt_report_qualifier   	char30_data_table;
  lt_desc            		char250_data_table;
  --
  -- Tables to account for multiple report qualifiers for each report format
  lt_rptq_first			numeric_data_table; --start index into lt_report_qualifier
  lt_rptq_last			numeric_data_table; --end index into lt_report_qualifier
  --
  --Block Definitions
  --
  lt_B_mag_block_id     	numeric_data_table;
  -- Note: lt_B_mag_block_id holds the id's for the current format being processed
  --
  lt_B_block_name       	char30_data_table;
  lt_B_cursor_name      	char250_data_table;
  lt_B_no_column_ret    	numeric_data_table;
  lt_B_validate         	boolean_data_table;
  --
  --Formula Definitions
  --
  lt_F_formula_name     	char250_data_table;
  --
  lt_F_mag_block_id     	numeric_data_table;
  -- used to index into lt_B_mag_block_id
  --
  lt_F_next_block_id    	numeric_data_table;
  lt_F_last_run_exec_mode  	char30_data_table;
  lt_F_overflow_mode      	char30_data_table;
  lt_F_sequence         	numeric_data_table;
  lt_F_frequency       		numeric_data_table;
  lt_F_validate         	boolean_data_table;
  --
  --
  lt_F_total 			numeric_data_table; --# of record defs for a format
  lt_B_total 			numeric_data_table; --# of block defs for a format
  --
  l_report_type      		VARCHAR2(10) := '1099R';
  l_formula_id    		number;  -- Holds the id of a formula.
  l_main_block_flag		VARCHAR2(10);
--

--
  l_case_count 			number := 9; --number of formats
  li_case      			number;
  li_btab 			number := 1;
  li_ftab 			number := 1;
  l_f_id          		number;
  l_mag_block_id  		number;
  l_next_block_id 		number;
--
   -- Note that l_message is used throughout this module to hold the
   -- message which will be displayed if an exception is raised.
   --
   l_message            VARCHAR2(200);
--
BEGIN
----------------------------------------------------------------------------------------
   --
   --Note: Block 1 is  always the starting block, and is the only block
   --      with  p_main_block_flag  set to 'Y'.
   --      Block 1 has information on one Payer that is nominated as the
   --             "Transmitter" for each report. This block will also be used to maintain
   --            report level totals defined in the "F" record.
   --
/**/
----------------------------------------------------------------------------------------
-- Federal 1099R format definition
----------------------------------------------------------------------------------------
  --
  lt_B_total(1) := 4;
  lt_F_total(1) := 6;
  lt_report_format(1) := '1099R_FED';
  lt_desc(1) :='1099R Federal ';
  --
  lt_rptq_first(1) := 1;
  lt_rptq_last(1)  := 1;
  lt_report_qualifier(1)  :='FED'; --Federal
--
-- 1099R_FED Block 1: Payer that is nominated as the "Transmitter"
--
   lt_B_block_name(li_btab)       := 'US_1099R_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_transmitter';
   lt_B_no_column_ret(li_btab)    := 10;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_FED Block 2: Payer "A" Record.
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_PAYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.US_1099r_payer';
   lt_B_no_column_ret(li_btab)    := 6;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_FED Block 3: Payee "B" Record.
--
   li_btab := li_btab + 1;

   lt_B_block_name(li_btab)       := 'US_1099R_PAYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_payee';
   lt_B_no_column_ret(li_btab)    := 16;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_FED Block 4: State Process "K" Record.
--
   li_btab := li_btab + 1;

   lt_B_block_name(li_btab)       := 'US_1099R_STATE_PROCESS';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_state_process';
   lt_B_no_column_ret(li_btab)    := 2;
   lt_B_validate(li_btab)   	  := false;
--
/**/
--
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
-- 1099R_FED Formula
--
--
-- 1099R_FED Formula to write "T" Record
--
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_FED Formula to write "F" Record - End of transmission.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_FILE_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_FED Formula to write "A" Record.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYER';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_FED Formula to write "C" Record. End of payer control totals.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYER_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 2; --block 2
   lt_F_next_block_id(li_ftab)    	:= 4; --block 4
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
/**/
--
-- 1099R_FED Formula to write "B" Records. Payees.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYEES';
   lt_F_mag_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_FED Formula to write "K" Record. State Totals
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_STATE_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 4;  --block 4
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

/**/
-- ---------------------------------------------------------------------
-- States which use New 1220, without slight modifications
-- ---------------------------------------------------------------------
   lt_report_format(2) := '1099R_STATE';
   lt_B_total(2) := 3;
   lt_F_total(2) := 5;
   lt_desc(2)   :='--States which use 1220, with or without modifications';
   lt_rptq_first(2) := 2;
   lt_rptq_last(2)  := 24;
   --
   lt_report_qualifier(2)   := 'KS'; --Kansas
   lt_report_qualifier(3)   := 'IA'; --Iowa
   lt_report_qualifier(4)   := 'CT'; --Connecticut
   lt_report_qualifier(5)   := 'AZ'; --Arizona
   lt_report_qualifier(6)   := 'ME'; --Maine
   lt_report_qualifier(7)   := 'NE'; --Nebraska
   lt_report_qualifier(8)   := 'CA'; --California
   lt_report_qualifier(9)   := 'MD'; --Maryland
   lt_report_qualifier(10)  := 'DC'; --District of Columbia
   lt_report_qualifier(11)  := 'MA'; --Massachusettes
   lt_report_qualifier(12)  := 'MS'; --Mississippi
   lt_report_qualifier(13)  := 'ID'; --Idaho
   lt_report_qualifier(14)  := 'DE'; --Delaware
   lt_report_qualifier(15)  := 'MO'; --Missouri
   lt_report_qualifier(16)  := 'NJ'; --New Jersey
   lt_report_qualifier(17)  := 'ND'; --North Dakota
   lt_report_qualifier(18)  := 'OK'; --Oklahoma
   lt_report_qualifier(19)  := 'PA'; --Pennsylvania
   lt_report_qualifier(20)  := 'MN'; --Minnesota
   lt_report_qualifier(21)  := 'WI'; --Wisconsin
   lt_report_qualifier(22)  := 'GA'; --Georgia
   lt_report_qualifier(23)  := 'NM'; --New Mexico
   lt_report_qualifier(24)  := 'AR'; --Arkansas

--
-- 1099R_STATE Block 1: Payer that is nominated as the "Transmitter"
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_transmitter';
   lt_B_no_column_ret(li_btab)    := 10;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_STATE Block 2: Payer/Transmitter "A" Record.
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_PAYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_payer';
   lt_B_no_column_ret(li_btab)    := 6;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_STATE Block 3: Payee "B" Record.
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_PAYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.state_1099r_payee';
   lt_B_no_column_ret(li_btab)    := 16;
   lt_B_validate(li_btab)   	  := false;
--
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
-- 1099R_STATE Formula.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_STATE Formula to write "F" Record - End of transmission.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_FILE_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_STATE Formula to write "A" Record.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYER';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_STATE Formula to write "C" Record. End of payer control totals.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYER_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 2; --block 2
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_STATE Formula to write "B" Records. Payees---------------------------------------
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYEES';
   lt_F_mag_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

/**/
-- ---------------------------------------------------------------------
-- South Carolina use 1220 with or without slight modifications
-- but they have a K record if SIT > 0
-- ---------------------------------------------------------------------
   lt_report_format(3) := '1099R_SC';
   lt_B_total(3) := 4;
   lt_F_total(3) := 6;
   lt_desc(3)   :='--South Carolina uses 1220, with modifications';
   lt_rptq_first(3) := 25;
   lt_rptq_last(3)  := 25;
   lt_report_qualifier(25)   := 'SC'; --South Carolina
--
-- 1099R_SC Block 1: Payer that is nominated as the "Transmitter"
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_transmitter';
   lt_B_no_column_ret(li_btab)    := 10;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_SC Block 2: Payer/Transmitter "A" Record.
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_PAYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_payer';
   lt_B_no_column_ret(li_btab)    := 6;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_SC Block 3: Payee "B" Record.
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_PAYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.state_1099r_payee';
   lt_B_no_column_ret(li_btab)    := 16;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_SC Block 4: State Process "K" Record.
--
   li_btab := li_btab + 1;

   lt_B_block_name(li_btab)       := 'US_1099R_STATE_PROCESS';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_state_process';
   lt_B_no_column_ret(li_btab)    := 2;
   lt_B_validate(li_btab)   	  := false;

--
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
-- 1099R_SC Formula.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_SC Formula to write "F" Record - End of transmission.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_FILE_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_SC Formula to write "A" Record.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYER';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_SC Formula to write "C" Record. End of payer control totals.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYER_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 2; --block 2
   lt_F_next_block_id(li_ftab)    	:= 4;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_SC Formula to write "B" Records. Payees---------------------------------------
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_PAYEES';
   lt_F_mag_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

--
-- 1099R_SC Formula to write "K" Record. State Totals
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_STATE_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 4;  --block 4
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

/**/
-- ---------------------------------------------------------------------
-- States which use 1220, with or without slight modifications
-- ---------------------------------------------------------------------
   lt_report_format(4) := '1099R_STATE_NFED';
   lt_B_total(4) := 3;
   lt_F_total(4) := 5;
   lt_desc(4)   :='--States which do not use 1220';
   lt_rptq_first(4) := 26;
   lt_rptq_last(4)  := 26;
   --
   lt_report_qualifier(26)  := 'MT'; --Montana

-- 1099R_STATE_NFED Block 1: Payer that is nominated as the "Transmitter"
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_NFED_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_transmitter';
   lt_B_no_column_ret(li_btab)    := 10;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_STATE_NFED Block 2: Payer/Transmitter "A" Record.
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_NFED_PAYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_payer';
   lt_B_no_column_ret(li_btab)    := 6;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_STATE_NFED Block 3: Payee "B" Record.
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_NFED_PAYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.state_1099r_payee';
   lt_B_no_column_ret(li_btab)    := 16;
   lt_B_validate(li_btab)   	  := false;
--
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
-- 1099R_STATE_NFED Formula.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_NFED_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_STATE_NFED Formula to write "F" Record - End of transmission.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_NFED_FILE_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_STATE_NFED Formula to write "A" Record.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'STATE_1099R_PAYER';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_STATE_NFED Formula to write "C" Record. End of payer control totals.
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_NFED_PAYER_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 2; --block 2
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_STATE_NFED Formula to write "B" Records. Payees---------------------------------------
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'STATE_1099R_PAYEES';
   lt_F_mag_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
/**/
----------------------------------------------------------------------------------------
--1099R custom format for West Virginia
----------------------------------------------------------------------------------------
   lt_report_format(5) := '1099R_WV';
   lt_B_total(5) := 3;
   lt_F_total(5) := 5;
   lt_desc(5)   :='West Virginia 1099R';

   lt_rptq_first(5) := 27;
   lt_rptq_last(5)  := 27;
   --
   lt_report_qualifier(27)  := 'WV';  --West Virginia
---------------------------------------------------------------------------------------
--
-- 1099R_WV Block 1: Payer that is nominated as the "Transmitter"--------------------
---
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_NFED_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.us_1099r_transmitter';
   lt_B_no_column_ret(li_btab)    := 10;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_WV Block 1: Payer/Transmitter "A" Record.----------------------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_NFED_PAYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.US_1099r_payer';
   lt_B_no_column_ret(li_btab)    := 6;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_WV Block 2: Payee "B" Record.----------------------------------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_1099R_NFED_PAYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_1099r_mag_reporting.state_1099r_payee';
   lt_B_no_column_ret(li_btab)    := 16;
   lt_B_validate(li_btab)   	  := false;
--
----------------------------------------------------------------------------------------
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
--1099R_WV Formula---------------------------------------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_NFED_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
---
-- 1099R_WV Formula to write transmitter details.
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_NFED_FILE_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_WV Formula to write "E" Record-----------------------------------------------
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'WV_1099R_PAYER';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
-- 1099R_WV Formula to write transmitter file details
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_1099R_NFED_PAYER_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 2; --block 2
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
--
--
-- 1099R_WV Formula to write "W" Records. Payees---------------------------------------
--
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'WV_1099R_PAYEES';
   lt_F_mag_block_id(li_ftab)    	:= 3 ;  --block 3
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

------------------------------------------------------------------------------------------
--1099R custom format for Indiana
-- Indiana requires the TIB4 format for 1099R reporting
--  identical structure is taken from the W2 Reporting.
----------------------------------------------------------------------------------------
   lt_report_format(6) := '1099R_IND';
   lt_B_total(6) := 4;
   lt_F_total(6) := 7;
   lt_desc(6)   :='Indiana 1099R';
   --
   lt_rptq_first(6) := 28;
   lt_rptq_last(6)  := 28;
   --
   lt_report_qualifier(28)  := 'IN';  --IN
----------------------------------------------------------------------------------------
--
-- 1099R_IND Block 1: Payer that is nominated as the "Transmitter"--------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'IN_1099R_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.magw2_transmitter';
   lt_B_no_column_ret(li_btab)    := 12;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_IND Block 2: EMPLOYER --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'IN_1099R_EMPLOYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.st_magw2_employer';
   lt_B_no_column_ret(li_btab)    := 12;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_IND Block 3: EMPLOYEE --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'IN_1099R_EMPLOYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.oh_in_employee';
   lt_B_no_column_ret(li_btab)    := 8;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_IND Block 4: SUPPLEMENTAL --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'IN_1099R_SUPP';
     lt_B_cursor_name(li_btab)    := 'pay_us_1099r_mag_reporting.state_1099r_payee';
   lt_B_no_column_ret(li_btab)    := 16;
   lt_B_validate(li_btab)   	  := false;

----------------------------------------------------------------------------------------
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
--1099R_IND Formula-------------------------------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)           := 'IN_1099R_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)           := 1;  --block 1
   lt_F_next_block_id(li_ftab)          := 2;
   lt_F_last_run_exec_mode(li_ftab)     := 'N';
   lt_F_overflow_mode(li_ftab)          := 'N';
   lt_F_sequence(li_ftab)               := 1;
   lt_F_frequency(li_ftab)              := NULL;
   lt_F_validate(li_ftab)               := false;

-- 1099R_IND Formula to write "x" Record-----------------------------------------------
  --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)           := 'IN_1099R_FINAL';  --TIB4_FINAL
   lt_F_mag_block_id(li_ftab)           := 1;  --block 1
   lt_F_next_block_id(li_ftab)          := NULL;
   lt_F_last_run_exec_mode(li_ftab)     := 'N';
   lt_F_overflow_mode(li_ftab)          := 'N';
   lt_F_sequence(li_ftab)               := 2;
   lt_F_frequency(li_ftab)              := NULL;
   lt_F_validate(li_ftab)               := false;

-- 1099R_IND Formula to write "x" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)           := 'IN_1099R_EMPLOYER'; -- TIB4_EMPLOYER
   lt_F_mag_block_id(li_ftab)           := 2;
   lt_F_next_block_id(li_ftab)          := 3;
   lt_F_last_run_exec_mode(li_ftab)     := 'N';
   lt_F_overflow_mode(li_ftab)          := 'N';
   lt_F_sequence(li_ftab)               := 1;
   lt_F_frequency(li_ftab)              := NULL;
   lt_F_validate(li_ftab)               := false;

-- 1099R_IND Formula to write "x" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)           := 'IN_1099R_TOTAL';
   lt_F_mag_block_id(li_ftab)           := 2;
   lt_F_next_block_id(li_ftab)          := NULL;
   lt_F_last_run_exec_mode(li_ftab)     := 'N';
   lt_F_overflow_mode(li_ftab)          := 'N';
   lt_F_sequence(li_ftab)               := 2;
   lt_F_frequency(li_ftab)              := NULL;
   lt_F_validate(li_ftab)               := false;

-- 1099R_IND Formula to write "x" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)           :=  'TIB4_DUMMY';
   lt_F_mag_block_id(li_ftab)           := 3;
   lt_F_next_block_id(li_ftab)          := NULL;
   lt_F_last_run_exec_mode(li_ftab)     := 'N';
   lt_F_overflow_mode(li_ftab)          := 'N';
   lt_F_sequence(li_ftab)               := 1;
   lt_F_frequency(li_ftab)              := NULL;
   lt_F_validate(li_ftab)               := false;
   --
-- 1099R_IND Formula to write "E" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)           := 'TIB4_EMPLOYEE';
   lt_F_mag_block_id(li_ftab)           := 3;
   lt_F_next_block_id(li_ftab)          := 4;
   lt_F_last_run_exec_mode(li_ftab)     := 'N';
   lt_F_overflow_mode(li_ftab)          := 'N';
   lt_F_sequence(li_ftab)               := 2;
   lt_F_frequency(li_ftab)              := NULL;
   lt_F_validate(li_ftab)               := false;
   --
-- 1099R_IND Formula to write "S" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)           := 'IN_1099R_SUPPLEMENTAL'; -- TIB4_SUPPLEMENTAL
   lt_F_mag_block_id(li_ftab)           := 4;
   lt_F_next_block_id(li_ftab)          := NULL;
   lt_F_last_run_exec_mode(li_ftab)     := 'N';
   lt_F_overflow_mode(li_ftab)          := 'N';
   lt_F_sequence(li_ftab)               := 1;
   lt_F_frequency(li_ftab)              := NULL;
   lt_F_validate(li_ftab)               := false;


/**/
------------------------------------------------------------------------------------------
--1099R custom format for Michigan
-- Michigan requires the TIB4 format for 1099R reporting
--  identical structure is taken from the W2 Reporting.
----------------------------------------------------------------------------------------
   lt_report_format(7) := '1099R_MI';
   lt_B_total(7) := 3;
   lt_F_total(7) := 7;
   lt_desc(7)   :='Michigan 1099R';
   --
   lt_rptq_first(7) := 29;
   lt_rptq_last(7)  := 29;
   --
   lt_report_qualifier(29):= 'MI';
----------------------------------------------------------------------------------------
--
-- 1099R_MI Block 1: Payer that is nominated as the "Transmitter"--------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'MI_1099R_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.magw2_transmitter';
   lt_B_no_column_ret(li_btab)    := 12;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_MI Block 2: EMPLOYER --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'MI_1099R_EMPLOYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.st_magw2_employer';
   lt_B_no_column_ret(li_btab)    := 12;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_MI Block 3: EMPLOYEE --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'MI_1099R_EMPLOYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.st_magw2_employee';
   lt_B_no_column_ret(li_btab)    := 8;
   lt_B_validate(li_btab)   	  := false;

----------------------------------------------------------------------------------------
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
--1099R_MI Formula-------------------------------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'IN_1099R_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= 2;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_MI Formula to write "x" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'IN_1099R_FINAL'; --DUMMY_TIB4_FINAL
   lt_F_mag_block_id(li_ftab)    	:= 1; --block 1
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
-- 1099R_MI Formula  ----------------------------------------------------------------
   --
   li_ftab := li_ftab + 1;
     lt_F_formula_name(li_ftab)    	:= 'IN_1099R_EMPLOYER'; --TIB4_EMPLOYER
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_MI Formula to write "x" Record-----------------------------------------------
  --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'IN_1099R_TOTAL';--DUMMY_TIB4_TOTAL
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_MI Formula to write "x" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:=  'TIB4_DUMMY';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_MI Formula to write "E" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'TIB4_EMPLOYEE'; --required
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'R';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_MI Formula to write "S" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:=  'TIB4_SUPPLEMENTAL'; --required
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 3;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
   --
-------------------------------------------------------------------------------------------
/**/
------------------------------------------------------------------------------------------
--1099R custom format for New York
--  New York requires the SQWL format for 1099R reporting
--  identical structure is taken from pyw2data
----------------------------------------------------------------------------------------
   lt_report_format(8) := '1099R_NY';
   lt_B_total(8) := 3;
   lt_F_total(8) := 5;
   lt_desc(8)   :='New York 1099R';
   --
   lt_rptq_first(8) := 30;
   lt_rptq_last(8)  := 30;
   --
   lt_report_qualifier(30):= 'NY';
----------------------------------------------------------------------------------------
--
-- 1099R_NY Block 1: Payer that is nominated as the "Transmitter"--------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'NY_1099R_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.magw2_transmitter';
   lt_B_no_column_ret(li_btab)    := 12;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_NY Block 2: EMPLOYER --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'NY_1099R_EMPLOYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.st_magw2_employer';
   lt_B_no_column_ret(li_btab)    := 12;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_NY Block 3: EMPLOYEE --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'NY_1099R_EMPLOYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.st_magw2_employee';
   lt_B_no_column_ret(li_btab)    := 8;
   lt_B_validate(li_btab)   	  := false;

----------------------------------------------------------------------------------------
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
--1099R_NY Formula-------------------------------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'NY_1099R_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NY Formula to write "x" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'NY_1099R_FINAL';
   lt_F_mag_block_id(li_ftab)    	:= 1; --block 1
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;
-- 1099R_NY Formula  ----------------------------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'NY_1099R_EMPLOYER';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NY Formula to write "x" Record-----------------------------------------------
  --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'NY_1099R_TOTAL';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NY Formula to write "x" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:=  'NY_1099R_EMPLOYEE';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-------------------------------------------------------------------------------------------
/**/
------------------------------------------------------------------------------------------
--1099R custom format for North Carolina
--  North Carolina requires the W2 format for 1099R reporting
--  identical structure is taken from pyw2data
----------------------------------------------------------------------------------------
   lt_report_format(9) := '1099R_NC';
   lt_B_total(9) := 3;
   lt_F_total(9) := 10;
   lt_desc(9)   :='North Carolina 1099R';
   --
   lt_rptq_first(9) := 31;
   lt_rptq_last(9)  := 31;
   --
   lt_report_qualifier(31):= 'NC';
----------------------------------------------------------------------------------------
--
-- 1099R_NC Block 1: Payer that is nominated as the "Transmitter"--------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'NC_1099R_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.magw2_transmitter';
   lt_B_no_column_ret(li_btab)    := 12;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_NC Block 2: EMPLOYER --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'NC_1099R_EMPLOYER';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.st_magw2_employer';
   lt_B_no_column_ret(li_btab)    := 12;
   lt_B_validate(li_btab)   	  := false;
--
-- 1099R_NC Block 3: EMPLOYEE --------------------
--
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'NC_1099R_EMPLOYEE';
   lt_B_cursor_name(li_btab)      := 'pay_us_magw2_reporting.st_magw2_employee';
   lt_B_no_column_ret(li_btab)    := 8;
   lt_B_validate(li_btab)   	  := false;

----------------------------------------------------------------------------------------
-- Record definitions. Describe sequence of records, hierarchy and the
-- structure of each record ( by formula ).
--1099R_NC Formula-------------------------------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'TIB4_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;  --block 1
   lt_F_next_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula to write "x" Record-----------------------------------------------
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'TIB4_FINAL';
   lt_F_mag_block_id(li_ftab)    	:= 1; --block 1
   lt_F_next_block_id(li_ftab)    	:= Null;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula  ----------------------------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'TIB4_EMPLOYER';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= 3;  --block 3
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula to write "x" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'TIB4_INTERMEDIATE_TOTAL';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula to write "x" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'TIB4_TOTAL';
   lt_F_mag_block_id(li_ftab)    	:= 2;  --block 2
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 3;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula to write "x" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:=  'TIB4_DUMMY';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula to write "x" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:=  'NCTIB4_SUPPLEMENTAL';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula to write "x" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:=  'TIB4_EMPLOYEE';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 3;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula to write "x" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:=  'W2_TIB4_SUPPLEMENTAL';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 4;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

-- 1099R_NC Formula to write "x" Record-----------------------------------------------
   --
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:=  'TIB4_INTERMEDIATE_TOTAL';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 5;
   lt_F_frequency(li_ftab)       	:= 41;
   lt_F_validate(li_ftab)         	:= false;

----------------------------------------------------------------------------------------
  --
  hr_utility.trace('BEGIN 1099R REPORT DEFINITION PROCESS------------------------');
  li_btab := 1;
  li_ftab := 1;
  --
  FOR l_ccount IN 1..l_case_count LOOP
     ------------------------------------------------------
     --Clear existing format definitions and mappings
     ------------------------------------------------------
     hr_utility.trace('Insert definition for ' ||
                       lt_report_format(l_ccount));
     hr_utility.trace(lt_desc(l_ccount));
     hr_utility.trace('   Deleting magnetic records...');
     DELETE FROM pay_magnetic_records
     WHERE  magnetic_block_id IN
		(SELECT pmb.magnetic_block_id
		 FROM   pay_magnetic_blocks pmb,
                        pay_report_format_mappings_f pfm
		 WHERE pmb.report_format = pfm.report_format
                   AND pmb.report_format = lt_report_format(l_ccount)
                   AND pfm.report_category = 'RT');
     --
     hr_utility.trace('   Deleting blocks...');
     DELETE FROM pay_magnetic_blocks pmb
     WHERE  pmb.report_format in
               (SELECT pfm.report_format
                  FROM  pay_report_format_mappings_f pfm
                 WHERE pfm.report_format = lt_report_format(l_ccount)
                   AND pfm.report_category = 'RT');
     --
     hr_utility.trace('   Deleting report format mappings...');
     DELETE FROM pay_report_format_mappings_f rfm
     WHERE  rfm.report_format = lt_report_format(l_ccount)
       AND report_category = 'RT';

  END LOOP;

  FOR l_ccount IN 1..l_case_count LOOP
     --
     -------------------------------------------------------
     --Insert report format mappings
     -------------------------------------------------------
     --
     FOR l_st_count IN lt_rptq_first(l_ccount)..lt_rptq_last(l_ccount) LOOP
         hr_utility.trace('   --Inserting '|| lt_report_qualifier(l_st_count)
                                           || ' report qualifier...');
         INSERT INTO pay_report_format_mappings_f
	        ( report_type,
	          report_qualifier,
	          report_format,
                  report_category,
                  range_code,
                  assignment_action_code,
                  initialization_code,
                  archive_code,
                  magnetic_code,
	          effective_start_date,
	          effective_end_date )
         VALUES ( l_report_type,
	          lt_report_qualifier(l_st_count),
	          lt_report_format(l_ccount),
                  'RT',
                  'pay_us_1099r_mag_reporting.range_cursor',
                  'pay_us_1099r_mag_reporting.mag_1099r_action_creation',
                  null,
                  null,
                  'pay_magtape_generic.new_formula',
	          c_start_of_time,
	          c_end_of_time );
     END LOOP;
     --
     -------------------------------------------------------
     --Insert Blocks
     -------------------------------------------------------
     FOR l_bcount IN 1..lt_B_total(l_ccount) LOOP
       hr_utility.trace(' ');
       hr_utility.trace('Inserting block ' || lt_B_block_name(li_btab));
       l_message := 'Error inserting block ' || lt_B_block_name(li_btab);
       --
       IF l_bcount = 1 THEN     -- only the first block should be starting block
          l_main_block_flag := 'Y';
       ELSE l_main_block_flag := 'N';
       END IF;
       --
       Pay_Mgb_Ins.Ins
         ( p_magnetic_block_id  =>  lt_B_mag_block_id(l_bcount),
           p_block_name         =>  lt_B_block_name(li_btab),
           p_main_block_flag    =>  l_main_block_flag,
           p_report_format      =>  lt_report_format(l_ccount),
           p_cursor_name        =>  lt_B_cursor_name(li_btab),
           p_no_column_returned =>  lt_B_no_column_ret(li_btab),
           p_validate           =>  lt_B_validate(li_btab));
        li_btab := li_btab + 1;
     END LOOP;
     ----------------------------------------------------------
     --Insert Formulas
     ----------------------------------------------------------
     FOR l_fcount IN 1..lt_F_total(l_ccount) LOOP
         hr_utility.trace('-------------');
         hr_utility.trace('Inserting record def with formula '
                           || lt_F_formula_name(li_ftab));
         --
         l_message:='Error inserting record def with formula '
                           || lt_F_formula_name(li_ftab);
         --
         l_f_id := Pay_Mag_Utils.Lookup_Formula
			( p_session_date      => c_start_of_time,
			  p_business_group_id => NULL,
			  p_legislation_code  =>'US',
			  p_formula_name      => lt_F_formula_name(li_ftab));
         --
         IF l_f_id  IS NULL THEN
            hr_utility.trace('Could not find formula id');
         ELSE  hr_utility.trace('Successfully found formula id');
         END IF;
         --
         -- Since lt_F_mag_block_id is used to index into lt_B_mag_block_id,
         -- take care of NULL values
         --
         IF lt_F_mag_block_id(li_ftab) IS NULL THEN
            hr_utility.trace( '--ERROR:NULL block id not allowed');
         ELSE l_mag_block_id  := lt_B_mag_block_id(lt_F_mag_block_id(li_ftab));
         END IF;
         --
         IF lt_F_next_block_id(li_ftab) IS NULL THEN
            l_next_block_id := NULL;
         ELSE l_next_block_id := lt_B_mag_block_id(lt_F_next_block_id(li_ftab));
         END IF;
         --
         hr_utility.trace( '   formula_id 	   = '|| l_f_id);
         hr_utility.trace( '   magnetic_block_id = '|| l_mag_block_id);
         hr_utility.trace( '   next_block_id     = '|| l_next_block_id);
         hr_utility.trace( '   last_run_exec_mode = '|| lt_F_last_run_exec_mode(li_ftab));
         hr_utility.trace( '   overflow_mode   = '|| lt_F_overflow_mode(li_ftab));
         hr_utility.trace( '   sequence        = '|| lt_F_sequence(li_ftab));
         hr_utility.trace( '   frequency       = '|| lt_F_frequency(li_ftab));
         --
         --
         Pay_Mgr_Ins.Ins
         ( p_formula_id 		  => l_f_id,
           p_magnetic_block_id      => l_mag_block_id,
           p_next_block_id          => l_next_block_id,
           p_last_run_executed_mode => lt_F_last_run_exec_mode(li_ftab),
           p_overflow_mode          => lt_F_overflow_mode(li_ftab),
           p_sequence               => lt_F_sequence(li_ftab),
           p_frequency              => lt_F_frequency(li_ftab),
           p_validate               => lt_F_validate(li_ftab));
         --
         li_ftab := li_ftab + 1;
      END LOOP;
      --
      hr_utility.trace('Successfully created '|| lt_report_format(l_ccount)
                                              || ' format mapping..');
      --
  END LOOP; --for each case
  --
------------------------------------------------------------------------------
   --
   -- If no exceptions raised during formatting, commit new structures.
   --
   hr_utility.trace('Commiting structures...');
   COMMIT;
   --
 EXCEPTION                 --Andy Taylor's Generic Exception Handler
      WHEN OTHERS THEN
        --
        hr_utility.trace( l_message||' - ORA '||to_char(SQLCODE));
        hr_utility.trace(fnd_flex_val_api.message);
        --
  --
  --
  hr_utility.trace('END REPORT DEFINITION PROCESS----------------------------------');
end setup;
--
end pay_1099R_data;

/
