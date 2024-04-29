--------------------------------------------------------
--  DDL for Package Body PAY_MWS_RPDEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MWS_RPDEF" as
/* $Header: pymwsrpd.pkb 115.2 99/07/17 06:17:24 porting ship $ */

procedure setup is

  /* Report Definitions */

  l_report_type      		VARCHAR2(30);
  l_report_format   		VARCHAR2(30);
  l_report_qualifier   		VARCHAR2(30);
  l_desc            		VARCHAR2(250);

  /* Block Definitions */

  lt_B_mag_block_id     	numeric_data_type_table;
  /* Note: lt_B_mag_block_id holds the id's for the current format being
     processed */
  lt_B_block_name       	char30_data_type_table;
  lt_B_cursor_name      	char250_data_type_table;
  lt_B_no_column_ret    	numeric_data_type_table;
  lt_B_validate         	boolean_data_type_table;

  /* Formula Definitions */

  lt_F_formula_name     	char250_data_type_table;
  lt_F_mag_block_id     	numeric_data_type_table;
  -- used to index into lt_B_mag_block_id
  lt_F_next_block_id    	numeric_data_type_table;
  lt_F_last_run_exec_mode  	char30_data_type_table;
  lt_F_overflow_mode      	char30_data_type_table;
  lt_F_sequence         	numeric_data_type_table;
  lt_F_frequency       		numeric_data_type_table;
  lt_F_validate         	boolean_data_type_table;

  l_record_total 			number;
  -- # of record defs for a format
  l_block_total 			number;
  -- # of block defs for a format
  l_formula_id    		number;
  -- Holds the id of a formula.
  l_main_block_flag		VARCHAR2(10);
  l_block_count			number;
  l_formula_count		number;
  li_btab 			number := 1;
  li_ftab 			number := 1;
  l_f_id          		number;
  l_mag_block_id  		number;
  l_next_block_id 		number;
  l_message		        VARCHAR2(200);

begin

  l_block_total := 6;
  l_record_total := 9;
  l_report_type := 'MWSMR';
  l_report_format := 'MWSR';
  l_report_qualifier := 'FED';
  l_desc := 'Multiple Worksite Magnetic Report';

   /* Block 1 : Transmitter Block */
   lt_B_block_name(li_btab)       := 'US_MWS_TRANSMITTER';
   lt_B_cursor_name(li_btab)      := 'pay_mws_magtape_reporting.us_mws_transmitter';
   lt_B_no_column_ret(li_btab)    := 26;
   lt_B_validate(li_btab)   	  := false;

   /* Block 2 : State Block */
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_MWS_STATE';
   lt_B_cursor_name(li_btab)      := 'pay_mws_magtape_reporting.us_mws_state';
   lt_B_no_column_ret(li_btab)    := 4;
   lt_B_validate(li_btab)   	  := false;


   /* Block 3 : SUI Block */
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_MWS_SUI';
   lt_B_cursor_name(li_btab)      := 'pay_mws_magtape_reporting.us_mws_sui';
   lt_B_no_column_ret(li_btab)    := 6;
   lt_B_validate(li_btab)   	  := false;

   /* Block 4 : Worksite Block */
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_MWS_WORKSITE';
   lt_B_cursor_name(li_btab)      := 'pay_mws_magtape_reporting.us_mws_worksite';
   lt_B_no_column_ret(li_btab)    := 24;
   lt_B_validate(li_btab)   	  := false;

   /* Block 5 : Worksite Organization Block */
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_MWS_WORKSITE_ORGANIZATION';
   lt_B_cursor_name(li_btab)      := 'pay_mws_magtape_reporting.us_mws_worksite_organization';
   lt_B_no_column_ret(li_btab)    := 4;
   lt_B_validate(li_btab)   	  := false;

   /* Block 6 : Organization Employees Block */
   li_btab := li_btab + 1;
   lt_B_block_name(li_btab)       := 'US_MWS_ORGANIZATION_EMPLOYEES';
   lt_B_cursor_name(li_btab)      := 'pay_mws_magtape_reporting.us_mws_organization_employees';
   lt_B_no_column_ret(li_btab)    := 10;
   lt_B_validate(li_btab)   	  := false;


   /* Record definitions. Describe sequence of records, hierarchy and the
   structure of each record ( by formula ).
   */
   /* Formula to get the Transmitter details */
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_TRANSMITTER';
   lt_F_mag_block_id(li_ftab)    	:= 1;
   lt_F_next_block_id(li_ftab)    	:= 2;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

   /* Formula to write the Transmitter record */
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_TRANS_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 1;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

   /* Formula to get the state */
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_GET_STATE';
   lt_F_mag_block_id(li_ftab)    	:= 2;
   lt_F_next_block_id(li_ftab)    	:= 3;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

   /* Formula to get the SUI A/C*/
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_GET_SUI';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= 4;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

   /* Formula to write the SUI totals record */
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_SUI_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 3;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

   /* Formula to get the worksite */
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_GET_WORKSITE';
   lt_F_mag_block_id(li_ftab)    	:= 4;
   lt_F_next_block_id(li_ftab)    	:= 5;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

   /* Formula to write the worksite totals record*/
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_WORKSITE_TOTALS';
   lt_F_mag_block_id(li_ftab)    	:= 4;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 2;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

   /* Formula to get the Organizations for the worksite*/
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_GET_ORGANIZATION';
   lt_F_mag_block_id(li_ftab)    	:= 5;
   lt_F_next_block_id(li_ftab)    	:= 6;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;

   /* Formula to get the employees for the Organization */
   li_ftab := li_ftab + 1;
   lt_F_formula_name(li_ftab)    	:= 'US_MWS_GET_EMPLOYEES';
   lt_F_mag_block_id(li_ftab)    	:= 6;
   lt_F_next_block_id(li_ftab)    	:= NULL;
   lt_F_last_run_exec_mode(li_ftab)  	:= 'N';
   lt_F_overflow_mode(li_ftab)      	:= 'N';
   lt_F_sequence(li_ftab)        	:= 1;
   lt_F_frequency(li_ftab)       	:= NULL;
   lt_F_validate(li_ftab)         	:= false;


   /* Delete existing block and record definitions for the MWS Report */

   hr_utility.trace('Insert definition for ' || l_report_format);
   hr_utility.trace(l_desc);

   hr_utility.trace('Deleting magnetic records...');

   delete from PAY_MAGNETIC_RECORDS
   where  MAGNETIC_BLOCK_ID in
	(select mgb.MAGNETIC_BLOCK_ID
	 from   PAY_MAGNETIC_BLOCKS mgb
	 where  mgb.REPORT_FORMAT = l_report_format);

    hr_utility.trace('Deleting magnetic blocks');

    delete from PAY_MAGNETIC_BLOCKS mgb
   	  where  mgb.REPORT_FORMAT = l_report_format;

    hr_utility.trace('Deleting report format mappings...');

    delete from PAY_REPORT_FORMAT_MAPPINGS_F rfm
    	 where  rfm.REPORT_FORMAT = l_report_format;

    /* Insert into pay_report_format_mappings_f  */

         hr_utility.trace('Inserting the report qualifier : '||
			 l_report_qualifier);

         insert into PAY_REPORT_FORMAT_MAPPINGS_F
	        ( REPORT_TYPE,
	          REPORT_QUALIFIER,
                  REPORT_CATEGORY,
	          REPORT_FORMAT,
	          EFFECTIVE_START_DATE,
	          EFFECTIVE_END_DATE )
         values ( l_report_type,
	          l_report_qualifier,
                  'RT',
	          l_report_format,
	          c_start_date,
	          c_end_date );

     /* Insert blocks into PAY_MAGNETIC_BLOCKS and get the magnetic block id
	for each of the block in lt_B_mag_block_id */

     for l_block_count IN 1..l_block_total loop

       hr_utility.trace('Inserting block ' || lt_B_block_name(l_block_count));
       l_message := 'Error inserting block ' || lt_B_block_name(l_block_count);

       /* Only the first block can be the main block */
       if l_block_count = 1 then
          l_main_block_flag := 'Y';
       else l_main_block_flag := 'N';
       end if;

       Pay_Mgb_Ins.Ins
         ( p_magnetic_block_id  =>  lt_B_mag_block_id(l_block_count),
           p_block_name         =>  lt_B_block_name(l_block_count),
           p_main_block_flag    =>  l_main_block_flag,
           p_report_format      =>  l_report_format,
           p_cursor_name        =>  lt_B_cursor_name(l_block_count),
           p_no_column_returned =>  lt_B_no_column_ret(l_block_count),
           p_validate           =>  lt_B_validate(l_block_count));
     end loop;

     /* Insert Formulas into PAY_MAGNETIC_RECORDS */

     for l_formula_count in 1..l_record_total loop

         hr_utility.trace('Inserting record def. for formula '
                           || lt_F_formula_name(l_formula_count));

         l_message:='Error inserting record def. for formula '
                           || lt_F_formula_name(l_formula_count);

         l_f_id := Pay_Mag_Utils.Lookup_Formula
			( p_session_date      => c_start_date,
			  p_business_group_id => NULL,
			  p_legislation_code  =>'US',
			  p_formula_name      => lt_F_formula_name(l_formula_count));

         if l_f_id  is NULL then
            hr_utility.trace('Could not find formula id');
         else  hr_utility.trace('Successfully found formula id');
         end if;

         /* Since lt_F_mag_block_id is used to index into lt_B_mag_block_id,
            take care of NULL values */

         if lt_F_mag_block_id(l_formula_count) is NULL then
            hr_utility.trace( 'Error  :NULL block id not allowed');
         else l_mag_block_id  := lt_B_mag_block_id(lt_F_mag_block_id(l_formula_count));
         end if;

         if lt_F_next_block_id(l_formula_count) is NULL then
            l_next_block_id := NULL;
         else l_next_block_id := lt_B_mag_block_id(lt_F_next_block_id(l_formula_count));
         end if;

         hr_utility.trace( 'Formula_id 	   = '|| l_f_id);
         hr_utility.trace( 'magnetic_block_id = '|| l_mag_block_id);
         hr_utility.trace( 'next_block_id     = '|| l_next_block_id);
         hr_utility.trace( 'last_run_exec_mode = '|| lt_F_last_run_exec_mode(l_formula_count));
         hr_utility.trace( 'overflow_mode   = '|| lt_F_overflow_mode(l_formula_count));
         hr_utility.trace( 'sequence        = '|| lt_F_sequence(l_formula_count));
         hr_utility.trace( 'frequency       = '|| lt_F_frequency(l_formula_count));

         Pay_Mgr_Ins.Ins
         ( p_formula_id		    => l_f_id,
           p_magnetic_block_id      => l_mag_block_id,
           p_next_block_id          => l_next_block_id,
           p_last_run_executed_mode => lt_F_last_run_exec_mode(l_formula_count),
           p_overflow_mode          => lt_F_overflow_mode(l_formula_count),
           p_sequence               => lt_F_sequence(l_formula_count),
           p_frequency              => lt_F_frequency(l_formula_count),
           p_validate               => lt_F_validate(l_formula_count));

      end loop;

      hr_utility.trace('Successfully created '|| l_report_format
			 || ' format mapping..');

      hr_utility.trace('Issuing commit ...');
      commit;

     exception
     when others then
      hr_utility.trace( l_message||' - ORA '||to_char(SQLCODE));
      hr_utility.trace(l_message || ' - Ora: '|| to_char(sqlcode));

    hr_utility.trace('END REPORT DEFINITION PROCESS                                  ');
end setup;

end pay_mws_rpdef;

/
