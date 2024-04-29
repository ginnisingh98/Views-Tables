--------------------------------------------------------
--  DDL for Package Body PYSQDATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYSQDATA" as
 /* $Header: pysqdata.pkb 115.1 99/07/17 06:33:12 porting ship $ */
 /*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
 Name
   pysqdata
 Purpose
   Sets up the data to provide State Quarterly Wage Reporting.
 Notes
   This data is US specific.
 History
 ****************************************************************************
 18-Feb-1999     VMehta     110.0   Created this file from pyw2data.pkb
									by moving the SQWL specific stuff
									to reduce the original program size.
									For changes made before 18-Feb-1999
									please look at pyw2data.pkb
 02-Mar-1999     VMehta     40.2     Added Diskette/FTP report format mappings
				     for states(1 Qtr. 1999).

 04-MAR-1999     Asasthan   40.3    Added dummy employer formula for Florida Diskette.
                 meshah     contd.  Inserted the formula definition for Iowa Tape(ICESA).
 12-mar-1999     VMehta     40.4    Removed the Diskette formats for CA, FL, TX
												ID, OK, NJ and MS. Will be provided at a
												later date
                                    Modified format for Connecticut.
 16-mar-1999     VMehta     40.5(110.1)    Added FTP format for Illinois
 ***************************************************************************

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
   --                         ICESA format                                  -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'ICESA';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.
   --
-- 17-Jan-1995 The Current List of ICESA States

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL'  , 'AL', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'AZ', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'CA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'CO', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'IA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'IL', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL' ,  'IN', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'KS', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'ME', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'KY', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'MD', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'MA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'MN', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'MO', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'MT', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'NV', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'NC', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'OK', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'PA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'SC', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'SD', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'TN', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'TX', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'VT', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'WV', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);

--  End  ICESA Data

   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'ICESA_TRANSMITTER')
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
						 'ICESA_BINFO')
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
						 'ICESA_FINAL')
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
						 'ICESA_EMPLOYER')
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
						 'ICESA_TOTAL')
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
                                                 'ICESA_TOTAL2')
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
						 'ICESA_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --

   --
   --------------------------------------------------------------------------
   --                         SSA_SQWL format                               -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'SSA_SQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.
   --
-- 17-Jan-1996 The Current List of SSA_SQWL States


   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL'  , 'AR', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'DE', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'LA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'NE', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'NH', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'OR', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'UT', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'VA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'WI', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);


-- End Test Data

-- End finished SSA_SQWL Data

   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'SSA_SQWL_TRANSMITTER')
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
						 'SSA_SQWL_BINFO')
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
						 'SSA_SQWL_FINAL')
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
						 'SSA_SQWL_EMPLOYER')
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
						 'SSA_SQWL_TOTAL')
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
						 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --

   --
   --------------------------------------------------------------------------
   --                      North Dakota SQWL format                         -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'NDSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);

   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'ND', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'ICESA_EMPLOYER')
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
                                                 'ICESA_TOTAL')
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
                                                 'ICESA_TOTAL2')
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
                                                 'ICESA_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   --
   --------------------------------------------------------------------------
   --                         Alaska SQWL format                            -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'AKSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'AK', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'DUMMY_SQWL_EMPLOYER')
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
						 'AKSQWL_TOTAL')
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
						 'AKSQWL_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   --
   --------------------------------------------------------------------------
   --                           Idaho SQWL format                           -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'IDSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'ID', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
                                                 'IDSQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   --------------------------------------------------------------------------
   --                District of Columbia SQWL format                       -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'DCSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'DC', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
                                                 'DCSQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
    --
  --
   --------------------------------------------------------------------------
   --                      Puerto Rico SQWL format                          -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'PRSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'PR', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
                                                 'PRSQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
    --
  --
   --------------------------------------------------------------------------
   --                      Indiana SQWL format                              -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'INSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.
/*
   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'IN', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'DUMMY_SQWL_TRANSMITTER')
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
						 'INSQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'INSQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
*/
   --------------------------------------------------------------------------
   --                     New Jersey SQWL format                            -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'NJSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'NJ', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'NJSQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'NJSQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'NJSQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --

   --------------------------------------------------------------------------
   --                      Georgia SQWL format                              -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'GASQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'GA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'GASQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
    --

   --------------------------------------------------------------------------
   --                      New Mexico SQWL format                           -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'NMSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'NM', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'NMSQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'NMSQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
    --

   --------------------------------------------------------------------------
   --                      New York SQWL format                             -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'NYSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'NY', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'NYSQWL_TRANSMITTER')
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
						 'NYSQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'NYSQWL_EMPLOYER')
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
						 'NYSQWL_TOTAL')
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
						 'NYSQWL_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --

   --
   --------------------------------------------------------------------------
   --                           Ohio SQWL format                            -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'OHSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'OH', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'OHSQWL_EMPLOYER')
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
						 'SSA_SQWL_TOTAL')
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
						 'OHSQWL_EMPLOYEE')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --

/*
   --
   --------------------------------------------------------------------------
   --                         IASQWL format                               -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'IASQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
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
   values ('SQWL'  , 'IA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'SSA_SQWL_TRANSMITTER')
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
						 'SSA_SQWL_BINFO')
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
						 'IASQWL_FINAL')
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
						 'IASQWL_EMPLOYER')
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
                                                 'IASQWL_INTERMEDIATE_TOTAL')
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
						 'IASQWL_TOTAL')
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
						 'IASQWL_SUPPLEMENTAL')
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
						 'IASQWL_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => 41
     ,p_validate               => false);
   --
*/
   --------------------------------------------------------------------------
   --                         FLSQWL format                                 -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'FLSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
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
   values ('SQWL'  , 'FL', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'FLSQWL_TRANSMITTER')
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
                                                 'FLSQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'FLSQWL_EMPLOYER')
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
                                                 'FLSQWL_INTERMEDIATE_TOTAL')
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
                                                 'FLSQWL_TOTAL')
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
                                                 'FLSQWL_SUPPLEMENTAL')
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
                                                 'FLSQWL_INTERMEDIATE_TOTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => 41
     ,p_validate               => false);
   --
   --------------------------------------------------------------------------
   --                  Rhode Island SQWL format                             -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'RISQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'RI', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'SSA_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --

   --
   --------------------------------------------------------------------------
   --                       Wyoming SQWL format                             -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'WYSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'WY', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
                                                 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --

   --------------------------------------------------------------------------
   --                      Michigan SQWL format                             -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'MISQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'MI', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);

   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'SSA_SQWL_EMPLOYER')
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
                                                 'SSA_SQWL_TOTAL')
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
                                                 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   --------------------------------------------------------------------------
   --                        Hawaii SQWL format                             -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'HISQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'HI', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'SSA_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'SSA_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --

   --------------------------------------------------------------------------
   --                      Washington  SQWL format                          -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'WASQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'WA', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'WASQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'WASQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'WASQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
    --

   --------------------------------------------------------------------------
   --                      Connecticut (SSA E, S and F only) SQWL format              -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'CTSQWL';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'CT', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'SSA_SQWL_EMPLOYER')
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
                                                 'CTSQWL_TOTAL')
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
						 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
    --
   --------------------------------------------------------------------------
   --                      ICESA_S (S Record only) SQWL format              -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'ICESA_S';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'MS', 'RT',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'ICESA_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
    --
   --
   --------------------------------------------------------------------------
   --                          SD diskette format
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'SDSQWLD';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.
   --
   insert into pay_report_format_mappings_f
          (REPORT_TYPE,
           REPORT_QUALIFIER,
           REPORT_CATEGORY,
           REPORT_FORMAT,
		   RANGE_CODE,
		   ASSIGNMENT_ACTION_CODE,
		   INITIALIZATION_CODE,
		   ARCHIVE_CODE,
		   MAGNETIC_CODE,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE)
   values ('SQWL' ,  'SD', 'PD', L_REPORT_FORMAT,
		   'pay_us_archive.range_cursor',
		   'pay_us_archive.action_creation',
		   'pay_us_archive.archinit',
		   'pay_us_archive.archive_data',
		   'pay_magtape_generic.new_formula',
			START_OF_TIME, END_OF_TIME);
   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'SDSQWLD_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
                                                 'SDSQWLD_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --------------------------------------------------------------------------
   --                  MDSQWLD (Maryland Diskette) SQWL format              -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'MDSQWLD';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'MD', 'PD',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'MDSQWLD_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'MDSQWLD_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --------------------------------------------------------------------------
   --                  ILSQWLD (Illinois Diskette) SQWL format              -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'ILSQWLD';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.
   --
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
   values ('SQWL'  , 'IL', 'PD',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'ICESA_TRANSMITTER')
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
						 'ICESA_BINFO')
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
						 'ICESA_FINAL')
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
						 'ICESA_EMPLOYER')
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
						 'ICESA_TOTAL')
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
                                                 'ICESA_TOTAL2')
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
						 'ICESA_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --------------------------------------------------------------------------
   --          LAQJPT (Louisiana Quality Jobs Tape) SQWL format             -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'LAQJPT';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.
   --
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
   values ('SQWL'  , 'LA', 'RTLAQ',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'SSA_SQWL_TRANSMITTER')
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
						 'SSA_SQWL_BINFO')
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
						 'SSA_SQWL_FINAL')
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
						 'SSA_SQWL_EMPLOYER')
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
						 'SSA_SQWL_TOTAL')
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
						 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --------------------------------------------------------------------------
   --          ORSQWLF (Oregon FTP) SQWL format             -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'ORSQWLF';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.
   --
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
   values ('SQWL'  , 'OR', 'FTP',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'SSA_SQWL_TRANSMITTER')
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
						 'SSA_SQWL_BINFO')
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
						 'SSA_SQWL_FINAL')
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
						 'SSA_SQWL_EMPLOYER')
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
						 'SSA_SQWL_TOTAL')
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
						 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                      North Dakota SQWL (FTP)format                    -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'NDSQWLF';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);

   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'ND', 'FTP',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'ICESA_EMPLOYER')
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
                                                 'ICESA_TOTAL')
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
                                                 'ICESA_TOTAL2')
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
                                                 'ICESA_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);

   --
   --------------------------------------------------------------------------
   --                         ICESA (Diskette/FTP) format                   -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'ICESAD';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.
   --
-- 01-MAR-1999 The Current List of ICESA Diskette States

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL'  , 'AL', 'FTP',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'IL', 'FTP',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'NC', 'FTP',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
   values ('SQWL'  , 'WV', 'PD',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
   'pay_magtape_generic.new_formula',
   L_REPORT_FORMAT, START_OF_TIME, END_OF_TIME);

--  End  ICESA Data

   --
   -- Block definitions.
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK1
     ,p_block_name         => 'TRANSMITTER'
     ,p_main_block_flag    => 'Y'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'ICESA_TRANSMITTER')
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
						 'ICESA_BINFO')
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
						 'ICESA_FINAL')
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
						 'ICESA_EMPLOYER')
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
						 'ICESA_TOTAL')
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
                                                 'ICESA_TOTAL2')
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
						 'ICESA_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --------------------------------------------------------------------------
   --            ICESA_SD (S Record only) SQWL (Diskette) format            -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'ICESA_SD';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
				    from   pay_magnetic_blocks MGB
				    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'MS', 'PD',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
						 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
						 'ICESA_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   --------------------------------------------------------------------------
   --                       Wyoming SQWL (Diskette) format                  -
   --------------------------------------------------------------------------
   --
   -- Set up report format to be maintained.
   --
   L_REPORT_FORMAT := 'WYSQWLD';
   --
   -- Clear down current format definition and its mappings.
   --
   delete from pay_magnetic_records MGR
   where  MGR.magnetic_block_id in (select MGB.magnetic_block_id
                                    from   pay_magnetic_blocks MGB
                                    where  MGB.report_format = L_REPORT_FORMAT);
   --
   delete from pay_magnetic_blocks MGB
   where  MGB.report_format = L_REPORT_FORMAT;
   --
   delete from pay_report_format_mappings_f RFM
   where  RFM.report_format = L_REPORT_FORMAT;
   --
   -- Report to format definitions.

   insert into pay_report_format_mappings_f
   ( REPORT_TYPE, REPORT_QUALIFIER, REPORT_CATEGORY,
	 RANGE_CODE,
	 ASSIGNMENT_ACTION_CODE,
	 INITIALIZATION_CODE,
	 ARCHIVE_CODE,
	 MAGNETIC_CODE,
     REPORT_FORMAT, EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE )
   values ('SQWL' ,  'WY', 'PD',
   'pay_us_archive.range_cursor',
   'pay_us_archive.action_creation',
   'pay_us_archive.archinit',
   'pay_us_archive.archive_data',
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
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_transmitter'
     ,p_no_column_returned => 6
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK2
     ,p_block_name         => 'EMPLOYER'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employer'
     ,p_no_column_returned => 12
     ,p_validate           => false);
   --
   pay_mgb_ins.ins
     (p_magnetic_block_id  => L_BLOCK3
     ,p_block_name         => 'EMPLOYEE'
     ,p_main_block_flag    => 'N'
     ,p_report_format      => L_REPORT_FORMAT
     ,p_cursor_name        => 'pay_us_magtape_reporting.sqwl_employee'
     ,p_no_column_returned => 8
     ,p_validate           => false);
   --
   -- Record definitions.
   --

   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_TRANSMITTER')
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
                                                 'DUMMY_SQWL_FINAL')
     ,p_magnetic_block_id      => L_BLOCK1
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 2
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
   pay_mgr_ins.ins
     (p_formula_id             => lookup_formula(START_OF_TIME, NULL, 'US',
                                                 'DUMMY_SQWL_EMPLOYER')
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
                                                 'DUMMY_SQWL_TOTAL')
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
                                                 'SSA_SQWL_SUPPLEMENTAL')
     ,p_magnetic_block_id      => L_BLOCK3
     ,p_next_block_id          => NULL
     ,p_last_run_executed_mode => 'N'
     ,p_overflow_mode          => 'N'
     ,p_sequence               => 1
     ,p_frequency              => NULL
     ,p_validate               => false);
   --
	--
   -- Make the data permanent.
   --
   commit;
   --
 end setup;
 --
end pysqdata;


/
