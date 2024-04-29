--------------------------------------------------------
--  DDL for Package Body PYW2DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYW2DATA" as
 /* $Header: pyw2data.pkb 115.10 99/07/17 06:49:13 porting ship $ */
 /*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
 Name
   pyw2data
 Purpose
   Sets up the data to provide W2 and State Quarterly Wage Reporting.
 Notes
   This data is US specific.
 History
   29-Mar-95  	J.S.Hobbs	40.0	Date created.
   14-Jun-95  	allee		40.0	arcs'd in
   15-Jun-95  	allee			commented out all state formats
   16-Jun-95 	allee			Changed hardcoded bg_id = 63 -> 3
   27-Jun-95    allee			commented out the TIB4_Supplement
					Changed a sequence to 2
   14-Aug-95	allee			Changed the call to lookup formula.
					Now  BG_ID = NULL and leg_code = 'US'
   14-Aug-95	allee			Changed Basic Information -> Binfo
					Change lookup formula's cursor to
					restrict by leg_code and not by
					bg_id
   15-Aug-95	allee			Changed the overflow flag from
					'R' -> 'N' (Note: This might have
					fixed the problem concerning picking
					up employees)

   29-Sep-95    allee			Changed the overflow flag back to 'R'

   30-Sep-95    allee			Added TIB4_DUMMY to ensure that
					TIB4_EMPLOYEE gets called

   01-Dec-95    allee			Added information to handle the
					ICESA and SSA_SQWL formats

   21-Dec-95    allee			Changed the Employer and Employee
					Level Cursors.

   16-Jan-96    allee			Add the other formats.

   23-Jan-96    allee			Removed User errors.  Commented
					out all the formats dependent
					SQWL formulas, so that we can deliver
					a kosher Prod10
  26-Jan-96   rquance			Added a / and exit for the p10 patch
  01-FEB-96   ramurthy        		Added the formula ICESA_TOTAL2 to
					the ICESA
  27-Feb-96   allee			Added formats: IASQWL, RISQWL,
					HISQWL.  Rhode Island and
					Hawaii used to be an SSA STATE.
	  				Note: I currently set the frequency
					to one for testing purposes.
  29-Feb-96   allee			Added Washington and Mississippi.
  26-MAY-98   nbristow                  Added report_category.

  15-JUL-98	  vmehta		Moved 'KY' from SSA format to ICESA
							for SQWL
  22-JUL-98	 vmehta			Added code to populate 'magtape resilience'
							data in pay_report_format_mappings_f
							Folded in changes from patch 702840.
							New formulae for Washington SQWL
							New Format definition for Connecticut
							SQWL (bug 704503)
  08-aug-1998 vmehta		Added code to make MagW2 'magtape resilience'
							compliant.
  11-aug-1998 vmehta		Changed block definitions for Ohio and
							Indiana W2. The cursors oh_in_employee and
							ohstw2_supp and instw2_supp fetch 8 columns each
							as opposed to 10.
							changed block defn. for ohstw2_supp to fetch 10
							columns due to the added parameter
							TRANSFER_SCHOOL_DISTRICT
							Changed block definition for magw2_transmitter to
							fetch 8 columns instead of 6
 11-sep-1998 vmehta	       Moved Kansas(KS) to ICESA format from SSA.
 06-oct-1998 vmehta	ARCS'd in 40.41 as 40.43
							*********************************************
							40.42 is for release 10.6 only
							*******************************************
 06-oct-1998 vmehta	Added the following new formats as part of SQWL
							Q3 1998 patch.
							South Dakota (Diskette)
							Maryland (Diskette)
							Illinois (Diskette)
							Oregon (FTP)
							North Dakota (FTP)
							Louisiana (Quality Jobs Program)
 11-Jan-1999 vmehta  40.45 Changed the number of columns fetched for
									magw2_transmitter to support 2678 filing.
 16-Jan-1999 vmehta  40.46 Changed the number of columns fetched for
					(110.11)w2_transmitter and instw2_supp

 ***************************************************************************
 **************************************************************************

 18-Feb-1999 VMehta 110.12 Removed the SQWL part from this file and moved it
						   to pysqdata.pkb because the program had become
						   too large for startup database.
 ****************************************************************************
 ****************************************************************************
 ============================================================================*/
 --
 -- Date constants representing the start and end of time.sqlk
 --
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
 --
  -----------------------------------------------------------------------------
  -- Name
  --   lookup_formula
  -- Purpose
  --   Given a formula name it returns its id.
  -- Arguments
  -- Notes
  -----------------------------------------------------------------------------
 --
 function lookup_formula
 (
  p_session_date      date,
  p_business_group_id number,
  p_legislation_code  varchar2,
  p_formula_name      varchar2
 ) return number is
   --
   -- Local variable to hold formula_id from cursor fetch.
   --
   formula_id number;
   --
   -- Get the formula id for the specified formula.
   --
   cursor csr_formula is
     select FM.formula_id
     from   ff_formulas_f FM
     where  FM.legislation_code  = p_legislation_code
       and  FM.formula_name      = upper(p_formula_name)
       and  p_session_date between FM.effective_start_date
			       and FM.effective_end_date;
   --
 begin
   --
   open  csr_formula;
   fetch csr_formula into formula_id;
   if csr_formula%notfound then
     close csr_formula;
     raise NO_DATA_FOUND;
   end if;
   close csr_formula;
   --
   return (formula_id);
   --
 end lookup_formula;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   setup
  -- Purpose
  --   Sets up data to provide W2 and State Quarterly Wage reporting.
  -- Arguments
  --   None
  -- Notes
  -----------------------------------------------------------------------------
 --
 procedure setup is
   --
   -- Holds the name of the report format.
   --
   L_REPORT_FORMAT varchar2(30);
   --
   -- Holds the ID's of created blocks.
   --
   L_BLOCK1        number;
   L_BLOCK2        number;
   L_BLOCK3        number;
   L_BLOCK4        number;
   L_BLOCK5        number;
   --
   -- Holds the ID of a formula.
   --
   L_FORMULA_ID    number;
   --
 begin
   --
   --------------------------------------------------------------------------
   --                          Federal W2 format                            -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'FED', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_employer'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_employee'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'TIB4_BINFO')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'R'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
/*
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
*/

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => 41
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                          State W2 format                             --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'ST_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'AL', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'AZ', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'AR', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'CO', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'DE', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'DC', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'GA', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'ID', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'IL', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'IA', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'KS', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'ME', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'MD', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'MA', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'MN', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'MO', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'MT', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'NE', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'NM', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'ND', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'OK', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'PA', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'PR', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'RI', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'SC', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'UT', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'VA', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'WI', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_BINFO')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'R'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 4
     ,p_frequency              => 41
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                     New Jersey State W2 format                       --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'NJ_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'NJ', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_BINFO')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'R'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'NJTIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 4
     ,p_frequency              => 41
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                   West Virginia State W2 format                      --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'WV_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
	 REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'WV', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'R'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                      Michigan State W2 format                        --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'MI_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'MI', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'LA', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'R'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                  Kentucky State W2 format                            --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'KY_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'KY', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_BINFO')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   --------------------------------------------------------------------------
   --                  Mississippi State W2 format                         --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'MS_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'MS', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_BINFO')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'R'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 4
     ,p_frequency              => 41
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                       Indiana State W2 format                        --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'IN_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'IN', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.oh_in_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);

-- Add
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'IN_SUPP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.instw2_supp'
     ,p_no_column_returned => 12
     ,p_validate           => false);
-- Add
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK5
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);

   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_BINFO')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK5
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK5
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => 41
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                     Connecticut State W2 format                      --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'CT_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'CT', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);

   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_BINFO')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'R'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                        Ohio State W2 format                          --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'OH_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'OH', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);

   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.oh_in_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);

-- Add
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'OHIO_SUPP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.ohstw2_supp'
     ,p_no_column_returned => 10
     ,p_validate           => false);
-- Add
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK5
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);

   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_BINFO')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK5
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK5
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
-- Add
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
-- Add

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                     North Carolina State W2 format                   --
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'NC_TIB4';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB,
					  pay_report_format_mappings_f RFM
				    where  MGB.report_format = RFM.report_format
					AND RFM.report_format = L_REPORT_FORMAT
					AND RFM.report_category = 'RT');
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format in (
	   SELECT report_format
	   FROM pay_report_format_mappings_f
	   WHERE report_format = L_REPORT_FORMAT
	   AND report_category = 'RT');
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT
   and RFM.report_category = 'RT';
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('W2'  , 'NC', 'RT',
   'pay_us_magw2_reporting.range_cursor',
   'pay_us_magw2_reporting.create_assignment_act',
   NULL,
   NULL,
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);

   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.magw2_transmitter'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.st_magw2_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK4
     ,p_block_name         => 'HIGH_COMP'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magw2_reporting.w2_high_comp'
     ,p_no_column_returned => 2
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TRANSMITTER')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK2
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => L_BLOCK4
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_HIGH_COMP')
     ,p_magnetic_block_id      => L_BLOCK4
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYER')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => L_BLOCK3
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK2
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_DUMMY')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'NCTIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'R'
     ,p_sequence               => 3
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'W2_TIB4_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 4
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'TIB4_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 5
     ,p_frequency              => 41
     ,p_validate               => false);


   --
   -- Make the data permanent.
   --
   commit;
   --
 end setup;
 --
end pyw2data;


/
