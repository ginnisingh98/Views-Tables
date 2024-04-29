--------------------------------------------------------
--  DDL for Package PAY_US_MAGTAPE_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MAGTAPE_REPORTING" AUTHID CURRENT_USER as
 /* $Header: pyusmrep.pkh 115.26 2003/08/12 11:31:52 fusman ship $ */
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_magtape_reporting

  Purpose

    The purpose of this package is to support the generation of magnetic tape
    reports for US legilsative requirements. Specifically this covers federal
    and state W2's and also State Quarterly Wage Listing's.

  Notes

    The generation of each magnetic tape report is a two stage process i.e.

    1. Create a payroll action identifying the magnetic tape report being
       generated. Populate a set of assignment actions with each one
       identifying a person to be included in the report.

    2. Submit a request to run the generic magnetic tape process which will
       drive off the data created in stage one. This will result in the
       production of a structured ascii file which can be transferred to
       magnetic tape and sent to the relevant authority.

  History
  ----------------------------------------------------------------------
  Date          |   Author      | Ver  | Remarks
 -----------------------------------------------------------------------
  10-Feb-1995   J.S.Hobbs         40.0  Created.

  22 Jun 1995   allee		        Change pre_payment_id ->
				        chunk_number
  04 Aug 1995   ALLEE	                added level_cnt NUMBER

  29 Sep 1995   allee		        Changed chunk_number ->
				        Serial Number.  Although the serial
                                        number is a varchar2, ORACLE
                                        implicitly does the data conversion.

  09 Jan 1996   allee		        Changed serial_number -> tax_unit_id.
				        Sunil said it was in CASE.

  11 Feb 1996   allee		        Made run_magtape and lookup_format
                                        public Tuned the SQWL_employer cursor.
				        Made bal_db_item public for the
                                        resubmission routine.

  26 Feb 1996   allee		        Fixed #343239 by adding to the order by
				        clause in the employee level cursor.
  17-APR-1998   bhoman                  Changes made to support SQWL
                                        diskette reporting.
  08-AUG-1998   vmehta	                Changed cursors for ohio/indiana W2
                                        to make them
				        date tracked compliant.
				        Added new cursor to handle highly
                                        compensated people for State W2s.
  17-aug-1998   vmehta	                Changed cursors TIB4_TRANSMITTER and
			                OHSTW2_SUPPLEMENTAL to set up the
			                TRANSFER_SCHOOL_DISTRICT parameter to
                                        get the 'OH' school_district_code.
  30-OCT-1999   rpotnuru                bug 976472.

  03-DEC-1999   rpotnuru  110.5         bugs 1095096, 1085774.
                                        Removed serial_number is null check
                                        from sqwl_employeer and
                                        sqwl_employee cursors. In case of
                                        NYSQWL this column is populated
                                        with 1 if the employee doesnt have
                                        QTD balances for 4th qtr
                                        while  generating 4th qtr New York
                                        SQWL report.
  10-FEB-2000   ashgupta  40.27         Added code to take care of City of
                                        Oakland Multi Wage Plan Changes. Enh
                                        Req 1063413
  16-MAR-2000  ashgupta   40.28         changed the sqwl_employer_s cursor
                                        so as to select ' ' instead on null.
                                        This has to be done since SQWL report
                                        was failing on r11 database if null
                                        was used. So to make both r10.7 and r11
                                        aligned this change was done. Otherwise
                                        null work fine in r10.7
  12-JUN-2000  asasthan   115.5         in sync till Q2 2000 and includes
                                        fnd_date changes

  19-SEP-2001  tmehra     40.31         Changing sqwl_employee_s cursor to
                                        remove TRANSFER_WAGE_PLAN parameter.
                                        This parameter is now set in Employer
                                        Formula and is passed on to the
                                        Employee formula.

  25-FEB-2002  asasthan   115.7         Modified sqwl_transmitter cursor
                                        for performance Bug 2176726.
                                        Three unions have been removed.
                                         #  As "FED" report_qualifier
                                           is not true for SQWLs this condition
                                           was removed..
                                         # Also Transmitter is always
                                           mandatory for SQWLs so the join
                                           for null transmitter has been removed

  04-MAR-2002  asasthan   115.8         Added New Cursors Bug 2103126
                                        mmrf_sqwl_submitter cursor
                                        mmrf_sqwl_employer cursor
                                        mmrf_sqwl_employee cursor
  16-MAY-2002  asasthan   115.9         Added business_group_id as
                                        a paramter to the mmrf_sqwl_transmitter
                                        cursor. This was required by funtion.
  16-JUL-2002  sodhingr   115.10        Added RULE hint to the cursor
					sqwl_employee for bug 2464463.
  16-JUL-2002  sodhingr   115.10        Added RULE hint to the cursor
                                        mmrf_sqwl_employee for bug 2464463
					(performance issue for Georgia).
  18-JUL-2002  sodhingr   115.12,13     Added RULE hint to the cursor
                                        mmrf_sqwl_employee,sqwl_employee_s,
				        sqwl_employee_m for bug 2464463
  22-AUG-2002  rpinjala   115.14        Changed the mmrf_sqwl_transmitter cursor
                                        to add the transfer_report_category which is used
                                        in the MMRF_SUBMITTER_DUMMY_SQWL so that header for
                                        a02, a03 for CA RTM has diff. names.
  28-AUG-2002  sodhingr   115.15        Removed the RULE hint from the following cursors
					and remove the call to pay_magtape_generic.date_earned
					instead checking the same condition in a subquery instead
					of function call to improve the performance issue reported
					in bug 2464463.
					mmrf_sqwl_employee,sqwl_employee,sqwl_employee_s,sqwl_employee_m
  10-SEP-2002  sodhingr   115.16        Changed the condition for effective start date as <= instead of just
					equal to (=) in the following cursors.
					mmrf_sqwl_employee,sqwl_employee,sqwl_employee_s,sqwl_employee_m
  11-SEP-2002  sodhingr   15.17        Added the condition :
					      AND LEAST(SS.effective_end_date, PA.effective_date)
				              between PE.effective_start_date and PE.effective_end_date
				       for bug 2464463
  01-OCT-2002  sodhingr   15.18        For bug 2604618,changed the following cursors.
					mmrf_sqwl_employee,sqwl_employee_s,sqwl_employee_m
  10-NOV-2002 sodhingr    115.19       Added new cursor mmrf_nysqwl_employer for NY MMREF as the
					employers should be sorted by EIN not by the name(bug 2451245)
  10-FEB-2002 sodhingr    115.20	changed the cursor mmrf_sqwl_transmitter, to remove the dependency
					on W2 reporting rules for SQWL, bug 2752145
  19-MAR-2003 sodhingr    115.21        changed the cursor sqwl_employee_jurisdiction to get the data from
                                        archive tables  instead of live table. This is changed for
                                        bug 2852640
  15-MAY-2003 fusman      115.22        changed the cursor sqwl_employer to add business_group_id

  15-MAY-2003 tmehra      115.23        Removed the sqwl_employer_s and sqwl_employee_s cursors
                                        as part of the RTS and RTM category merger for CA.
  06-AUG-2003 fusman      115.24        3094891. Moved all the sqwl cursors to pay_us_sqwl_archive package header.
 ============================================================================*/


  -----------------------------------------------------------------------------
  -- Name
  --   lookup_format
  -- Purpose
  --   Find the format to be applied when generating the report.
  -- Arguments
  -- Notes
  -- SQWLD - p_media_type parameter
  -----------------------------------------------------------------------------
 --
 function lookup_format
 (
  p_period_end  in date,
  p_report_type in varchar2,
  p_state       in varchar2,
  p_media_type  in varchar2 := NULL
 ) return varchar2;

  -----------------------------------------------------------------------------
  -- Name
  --   bal_db_item
  -- Purpose
  --   Given the name of a balance DB item as would be seen in a fast formula
  --   it returns the defined_balance_id of the balance it represents.
  -- Arguments
  -- Notes
  --   A defined +balance_id is required by the PLSQL balance function.
  -----------------------------------------------------------------------------
 --
 function bal_db_item
 (
  p_db_item_name varchar2
 ) return number;

  -----------------------------------------------------------------------------
  -- Name
  --   redo
  -- Purpose
  --   Calls the procedure run_magtape directly from SRS. This procedure
  --   handles the error buffer and return code interface with SRS.
  --   We are going to derive all the  parameters from the vi
  -- Arguments
  -- Notes
  -----------------------------------------------------------------------------
 procedure redo
 (
  errbuf               out nocopy  varchar2,
  retcode              out nocopy  number,
  p_payroll_action_id  in varchar2
 );
 --
  -----------------------------------------------------------------------------
  -- Name
  --   run_magtape
  -- Purpose
  --   Submits the magnetic tape process to be run by the concurrent manager.
  --   We also define the name of the output and the format here
  -- Arguments
  -- Notes
  -- SQWLD - p_media_type parameter
  -----------------------------------------------------------------------------
 --


 procedure run_magtape
 (
  p_effective_date     date,
  p_report_type        varchar2,
  p_payroll_action_id  varchar2,
  p_state              varchar2,
  p_reporting_year     varchar2,
  p_reporting_quarter  varchar2,
  p_trans_legal_co_id  varchar2,
  p_media_type  in varchar2 := NULL
 );

  -----------------------------------------------------------------------------
  -- Name
  --   run
  -- Purpose
  --   This is the main procedure responsible for generating the list of
  --   assignment actions and then submitting the request to produce the
  --   magnetic tape report.
  -- Arguments
  --   errbuf              - error message string passed back to SRS.
  --   retcode             - error code passed back to SRS ie.
  --                           0 - Success
  --                           1 - Warning
  --                           2 - Error
  --   p_business_group_id - business group the user is running under when the
  --                         report is generated.
  --   p_report_type       - either 'W2' or 'SQWL'
  --   p_state             - either 'FED' for federal or the state code of a
  --                         state eg. PA for Pennsylvania
  --   p_quarter           - identifies the quarter being reported eg. 03 is
  --                         the 1st quarter.  This is defaulted to '12' for
  --                         the W2 Report
  --   p_year              - identifies the year being reported on.
  --   p_trans_legal_co_id - identifies the Transmitter Tax Unit.
  -- Notes
  --   This procedure is invoked from the SRS screens.
  -- SQWLD - p_media_type parameter
  -----------------------------------------------------------------------------
 --
 procedure run
 (
  errbuf               out nocopy  varchar2,
  retcode              out nocopy  number,
  p_business_group_id   in number,
  p_report_type         in varchar2,
  p_state               in varchar2,
  p_quarter             in varchar2,
  p_year                in varchar2,
  p_trans_legal_co_id   in number,
  p_media_type  in varchar2 := NULL
 );
 --
end pay_us_magtape_reporting;

 

/
