--------------------------------------------------------
--  DDL for Package Body PAY_US_SQWL_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_SQWL_ARCHIVE" as
/* $Header: pyussqwl.pkb 120.12.12010000.11 2010/04/13 06:40:09 emunisek ship $ */

/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Description : Package and procedure to build sql for payroll processes.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  --------------------------------
   13-Apr-2010  emunisek    115.72 9561700  Added date check condition in
                                            cursor get_previous_fl_taxable
   12-Apr-2010  emunisek    115.71 9561700  Made changes to use the maximum
                                            effective date of Assignment's
                                            payroll actions in Balance Call
                                            if the assignment ends in between
                                            the Quarter for FL SQWL.
   30-Mar-2010  emunisek    115.68 9356178  Modified to fetch the balances in archive_data
                                            for Florida SQWL based on virtual date
   24-Mar-2010  emunisek    115.67 9356178  Reorganized the code as per the suggestions
                                            made in codereview.
   23-Mar-2010  emunisek    115.66 9356178  Made changes to make file GSCC Compliant
   23-Mar-2010  emunisek    115.65 9356178  Added code to archive Florida SQWL
                                            related data to procedure archive_data
   06-Jun-2008  mikarthi    115.63 6774422  Changed _cursor c_get_latest_asg
                                            for improving performance
   14-Mar-2007  saurgupt    115.62 5152728  Changed the range_cursor and action_creation to
                                            improve perf. In range_cursor, removed pay_payrolls_f.
   07-Apr-2006  sudedas     115.60 4344959  changing preprocess_check, cursor (c_chk_asg_wp)
   01-Feb-2006  sudedas     115.59 4890376  Removing hr_organization_information
                                            from action_creation cursors (including
					    LA,CT) as the checks are there for range_cursor
   24-JAN-2006  sackumar    115.58 4869678  Modified the c_get_latest_asg cursor in
					    archive_data procedure.removed the +0 from
					    the query to enable the indexes.
   16-AUG-2005  sudedas     115.55          Adding some trace messages for
                                            procedure archive_asg_locs.
   10-AUG-2005  sudedas     115.54 4349864  action_creation is modified to
                                            enable Range Person ID functionality
					    for LA, PR and CT (non-profit)
   24-JUN-2005  sudedas     115.53 4310812  action_creation is modified for
					    State of Maine.
   22-JUN-2005  sudedas     115.52 4310812  range_cursor is changed to include
                                            Maine like California.
   30-MAY-2005  sudedas     115.51 3843134  action_creation is modified for performance
   25-MAY-2005  sudedas     115.50 4310812  action_creation and report_person_on_tape
                                            is modified for Maine Sqwl.
   24-Nov-2004  saikrish    115.48          Commented the trace.
   22-Nov-2004  saikrish    115.47 3923296  Changed get_selection_information to check
                                            SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD for Indiana
   28-OCT-2004  saikrish    115.46 3923296  Changed get_selection_information to check
                                            SUI_ER_GROSS_PER_JD_GRE_QTD for Indiana
   22-OCT-2004  jgoswami    115.45          Fix Check Patch error
   30-SEP-2004  jgoswami    115.44 3925772  modified archive_data, modified
                                            cursor c_get_latest_asg to check for
                                            all assignments for person which are
                                            valid and paid in quarter.
   01-MAR-2004  jgoswami    115.43 3416806  modified action_creation cursors to check for
                                            assignment_type of Employee only.
                                            Clean Package, removed unnecessary code.
   19-FEB-2004  jgoswami    115.42 3331021  modified archive_data, remove query with RULE hint
                                            and added cursor c_get_latest_asg
   21-JAN-2004  jgoswami    115.41 3388513  Changed the criteria for picking up the emps
                                            in fourth quarter.
                                            check for SIT_SUBJ_WHABLE_PER_JD_GRE_YTD,
                                            SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD,
                                            SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD.
   18-DEC-2003  jgoswami    115.40 3324974  comment correctly to initialize
                                            l_prev_tax_unit_id  to -99999999.
   04-DEC-2003  fusman      115.39 3281209  Checked the checking criteria for NY
                                            in fourth quarter.
   30-JUL-2003  fusman      115.38 2922028  Changed the criteria for picking up the emps
                                            for NY on fourth QTR.
   07-JUL-2003  sodhingr    115.37          changed the cursor c_state_pr,c_ct_non_profit,
					    c_state,c_state_la_quality for performance.
					    Added the check for
					    asg.effective_end_date   >= l_period_start
      					    and  asg.effective_start_date <= l_period_end
					    instead of  ppa.effective_date between
					    ASG.effective_start_date and ASG.effective_end_date
   02-Jun-2003  fusman      115.36 2965887  Checked for archive type in chk_gre_archive
                                            and inserted archive_type in ff_archive_items.
   28-MAY-2003  tmehra      115.35 2981455  Made changes to the action_creation
                                            Added code to error out in case
                                            if the wage plan is missing at both
                                            the Asg and the GRE level for CA.
   27-MAY-2003  tmehra      115.34          Made changes to the c_chk_asg_wp
                                            cursor, The Asg's with NULL SUI
                                            ID does not get falgged off now.
   22-MAY-2003  tmehra      115.33 2707698  Replaced c_dup_orgn_info
                                            cursor with a new select
                                            statement due to performance
                                            issues.
   19-MAY-2003  tmehra      115.32          Made changes to the archiver
                                            Pre-Process c_chk_gre_wp cursor.
   15-MAY-2003  tmehra      115.31          Made changes to the archiver
                                            Pre-Process.
   07-MAY-2003  tmehra      115.30          Merged Single and Multi Wage Plan
                                            logic for California.
   23-APR-2003  tclewis     115.29 2924361  added a order by paf.effective_end_date
                                            to the cursor c_asg_loc_end.
                                            this is to return the latest
                                            location id in the cursor.
   30-MAR-2003  sodhingr    115.28          changed the cursor csr_defined_balance
                                            in the function bal_db_item to join
                                            with the legislation_code = 'US'

   18-MAR-2003  sodhingr    115.27          changed the cursor c_state_pr, to
					    compare effective_date between
					    l_period_start and l_period_end
					    instead of comparing between l_period_start
					    and l_period start.
   25-FEB-2003  sodhingr    115.22 2717128  Changed the cursors c_state ,
					    c_ct_non_profit,c_state_la_quality
					    for performance.
				   2809506  changed the cursor c_asg_loc_end for
					    performance, commenting the redundant
					    join with business group id
   12-FEB-2002  sodhingr    115.21 2779152  Changed action_creation, added the
					    cursor c_state_pr, for PR.
   11-SEP-2002   sodhingr   115.20 2549213 Changed the foloowing cursors to user
					   per_all_assignments_f instead of per_assignments_f
					   c_ct_non_profit, c_state_la_quality, c_state
   30-MAY-2002   asasthan   115.19 2396909  For MMREF states SQWLs now
                                            give warning when there is
                                            no W2 Reporting Rules set up
                                            for transmitter GRE.
                                            Removed following procedures
                                            that were earlier used by EOY
                                            process and are not reqd by
                                            SQWL process. These are

                                            PROCEDURE EOY_RANGE_CURSOR
                                            PROCEDURE EOY_ACTION_CREATION
                                            PROCEDURE EOY_ARCHIVE_DATA
                                            PROCEDURE EOY_ARCHINIT

   25-MAR-2002   asasthan   115.18          Added ORDERED hint in action
                                             creation cursor
   20-MAR-2002   djoshi     115.17          Initalized l_prev_tax_unit_id
                                             to -9999999;
   21-FEB-2002   asasthan   115.16          Fix for Bug 2123699
                                            Changed l_value > 0 in action
                                            creation to l_value <> 0 to
                                            create assignment actions for
                                            -ve SUI_ER_SUBJ_WHABLE_PER_JD_GRE
                                            _QTD assignments.
                                            Also made similar changes
                                            in residence_in_state and
                                            report_person_on_tape.

  05-DEC-2001   asasthan    115.15          Changed for MA SQWLs 2138109
  18-OCT-2001   tmehra      115.14          Replaced the following cursors
                                             -  c_archive_wage_plan_code_rts
                                             -  c_archive_wage_plan_code_rtm
                                            with
                                             -  c_archive_wage_plan_code
                                            to improve performance.
                                            Also modified archive_data
  12-OCT-2001   vmehta      115.13          Modified c_state cursor for
                                            improving performance.
                                            Also modified archive_data
  05-JUN-2001 tclewis       115.4           Added procedure archive_asg_locs.  This
                                            will archive the Assignment locations as of
                                            the 12th of the month, for each month of the
                                            quarter.

  11/16/2000    asasthan    115.8  1494215  Added A_SIT_PRE_TAX_REDNS_PER_JD_GRE_QTD
                                            and A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD
                                            to update_ff_archive_items.
  22-AUG-2000  ashgupta     110.12 1382408  Changed the SQL statement of
                                            c_rts_dup_wage cursor. This SQL was
                                            changed due to Fidelity issue. Now
                                            the cursor does not check for Multi
                                            ple wage plan codes across the
                                            assignments of a person. It just
                                            checks that each individual assgn-
                                            ment should not be having more than
                                            one wage plan code. It takes care
                                            of only paid assignments.
  19-JUL-2000  ashgupta     40.14  1354144  Changed the SQL statement of
                                            c_rts_dup_wage cursor. This SQL was
                                            changed due to Fidelity performance
                                            problem.
   12-JUN-2000  asasthan    115.5  update till Q2 2000 changes and includes
                                    the 11i fnd_date and fnd_number changes
  22-MAY-2000  ashgupta     40.12  1237099  Added the error messages in the
                                            preprocess_check function
  02-MAR-2000  rpotnuru   40.11    1220213  Terminated Employees not showing for $th Qtr
                                            NY sqwl. Range cursor date range will now the whole
                                            Year for NY 4th Qtr SQWL.
  08-FEB-2000  ashgupta   40.9              SQWL changes for city of Oakland
                                            Added code in archinit
                                                          archive_data
                                                          range_cursor
                                            Added a new fn preprocess_check
                                            This was done for the enhancement
                                            req 1063413
  03_DEC-1999  asasthan   40.6    1093595
  03-DEC-1999  rpotnuru   40.5    1095096  NY sqwl for 4th qtr  date range is Year St to
                                   1085774  Year End. so for reporting QTD balances
                                            setting a flag in pay_assignment_actions
                                            if the employee doesnt have balances for the QTD.
                                            Added function update_ff_archive_item.

   17-NOV-1999  asasthan                    Performance Tuning 1079787
   27-OCT-1999  RPOTNURU    110.0           Bug fix  976472

   25-oct-1999  djoshi	                    added the A_SS_EE_WAGE_BASE and
                                            A_SS_EE_WAGE rate to archive the data
                                            related to bug 983094 and 101435

   01-sep-1999  achauhan                    While archiving the employer data
                                            add the context of pay_payroll_actions
                                            to ff_archive_item_contexts.
   11-aug-1999  achauhan                    Added the call to
                                            eoy_archive_gre_data in the
                                            eoy_range_cursor procedure. This is
                                            being done to handle the situation
                                            of archiving employer level data
                                            even when there are no employees in
                                            a GRE.
   10-aug-1999  achauhan                    In the archive_data routine,
                                            removed the use of payroll_action_id
                                            >= 0.
   04-Aug-1999  VMehta                Changed eoy_archive_data to improve performance.
   02-Jun-1999  meshah                      added new cursors in the range and action
					    creation cursors to check for non profit
					    gre's for the state of connecticut.

   08-mar-1999  VMehta                      Added nvl while checking for l_1099R_ind
                                            to correct the Louisiana quality jobs program
                                            tape processing.
   26-jan-1999  VMehta                      Modified function report_person_on_tape to
                                            return false for all states except California
                                            and Massachusetts.
   24-Jan-1999  VMehta             805012   Added function report_person_on_tape to perform
                                            check for retirees having SIT w/h in california.
   06-Jan-1999  MReid                       Changed c_eoy_gre cursor to disable
                                            business_group_id index on ppa side
   30-dec-1998  vmehta             709641   Look at SUI_ER_SUBJ_WHABLE instead of SUI_ER_GROSS
                                            for picking up people for SQWL . This makes sure
                                            that only people with SUI wages are picked up.
   27-dec-1998  vmehta                      Corrected the cursor in action creation to get the
                                            tax_unit_name from pay_assignment_actions.
   21-DEC-1998  achauhan                    Changed the cursor in action creation to get the
                                            assignments from the pay_assignment_actions table.

   08-DEC-1998  vmehta                      Removed grouping by on assignment_id while creating
                                            assignment_ids
   08-DEC-1998  nbristow                    Updated the c_state cursor to use
                                            an exists rather than a join.
   07-DEC-1998  nbristow                    Resolved some issues introduced by
                                            40.13.
   04-DEC-1998  vmehta             750802   Changed the cursors/logic to
                                            pick up people who live in
                                            California for the California SQWL.
   29-NOV-1998  nbristow                    Changes to the SQWL code,
                                            now using pay_us_asg_reporting.
   25-Sep-1998	vmehta                      Changed the range cursor and
                                            the assignment_action creation
                                            cursors to support Louisiana
                                            Quality Jobs Program Reporting.
   08-aug-1998  achauhan                    Added the routines for eoy -
                                            Year End Pre-Process
   18-MAY-1998  NBRISTOW                    sqwl_range cursor now checks
                                            the tax_unit_id etc.
   06-MAY-1998  NBRISTOW

   14-MAR-2005 sackumar  115.49  4222032    Change in the Range Cursor removing redundant
					    use of bind Variable (:payroll_action_id)
   */


   function chk_gre_archive (p_payroll_action_id number) return boolean;
   procedure create_archive (p_user_entity_id in number,
                            p_context1       in number,
                            p_value          in varchar2,
                            p_sequence       in pay_us_sqwl_archive.number_data_type_table,
                            p_context        in pay_us_sqwl_archive.char240_data_type_table,
                            p_context_id     in pay_us_sqwl_archive.number_data_type_table);

   sqwl_range varchar2(4000);



 /* Name    : bal_db_item
  Purpose   : Given the name of a balance DB item as would be seen in a fast formula
              it returns the defined_balance_id of the balance it represents.
  Arguments :
  Notes     : A defined balance_id is required by the PLSQL balance function.
 */

 function bal_db_item
 (
  p_db_item_name varchar2
 ) return number is

 /* Get the defined_balance_id for the specified balance DB item. */

   cursor csr_defined_balance is
     select fnd_number.canonical_to_number(UE.creator_id)
     from  ff_user_entities  UE,
           ff_database_items DI
     where  DI.user_name            = p_db_item_name
       and  UE.user_entity_id       = DI.user_entity_id
       and  Ue.creator_type         = 'B'
       and  UE.legislation_code     = 'US';

   l_defined_balance_id pay_defined_balances.defined_balance_id%type;

 begin

   open csr_defined_balance;
   fetch csr_defined_balance into l_defined_balance_id;
   if csr_defined_balance%notfound then
     close csr_defined_balance;
     raise hr_utility.hr_error;
   else
     close csr_defined_balance;
   end if;

   return (l_defined_balance_id);

 end bal_db_item;


 /* Name    : get_dates
  Purpose   : The dates are dependent on the report being run i.e.
              a W2 report shows information for a tax year while
              a SQWL report shows information for a quarter within
              a tax year.
  Arguments :
  Notes     :
 */

 procedure get_dates
 (
  p_report_type    in     varchar2,
  p_effective_date in     date,
  p_period_end     in out nocopy  date,
  p_quarter_start  in out nocopy  date,
  p_quarter_end    in out nocopy  date,
  p_year_start     in out nocopy  date,
  p_year_end       in out nocopy  date
 ) is
 begin



     /* Report is SQWL ie. a quarterly report where the identifier indicates the
        quarter eg. 0395
        p_period_end        31-MAR-1995
        p_quarter_start     01-JAN-1995
        p_quarter_end       31-MAR-1995
        p_year_start        01-JAN-1995
        p_year_end          31-DEC-1995
     */

     p_quarter_start := trunc(p_effective_date, 'Q');
     p_quarter_end   := add_months(trunc(p_effective_date, 'Q'),3) - 1;
     p_period_end    := p_quarter_end;

     p_year_start := trunc(p_effective_date, 'Y');
     p_year_end   := add_months(trunc(p_effective_date, 'Y'),12) - 1;

 end get_dates;


  /* Name    : get_selection_information
  Purpose    : Returns information used in the selection of people to be reported on.
  Arguments  :

  The following values are returned :-

    p_period_start         - The start of the period over which to select
                             the people.
    p_period_end           - The end of the period over which to select
                             the people.
    p_defined_balance_id   - The balance which must be non zero for each
                             person to be included in the report.
    p_group_by_gre         - should the people be grouped by GRE.
    p_group_by_medicare    - Should the people ,be grouped by medicare
                             within GRE NB. this is not currently supported.
    p_tax_unit_context     - Should the TAX_UNIT_ID context be set up for
                             the testing of the balance.
    p_jurisdiction_context - Should the JURISDICTION_CODE context be set up
                             for the testing of the balance.

  Notes      : This routine provides a way of coding explicit rules for
               individual reports where they are different from the
               standard selection criteria for the report type ie. in
               NY state the selection of people in the 4th quarter is
               different from the first 3.
  */

 procedure get_selection_information
 (

  /* Identifies the type of report, the authority for which it is being run,
     and the period being reported. */
  p_report_type          varchar2,
  p_state                varchar2,
  p_quarter_start        date,
  p_quarter_end          date,
  p_year_start           date,
  p_year_end             date,
  /* Information returned is used to control the selection of people to
     report on. */
  p_period_start         in out nocopy  date,
  p_period_end           in out nocopy  date,
  p_defined_balance_id   in out nocopy  number,
  p_group_by_gre         in out nocopy  boolean,
  p_group_by_medicare    in out nocopy  boolean,
  p_tax_unit_context     in out nocopy  boolean,
  p_jurisdiction_context in out nocopy  boolean
 ) is

 begin

   /* Depending on the report being processed, derive all the information
      required to be able to select the people to report on. */


     /* State Quarterly Wage Listings. */

   if p_report_type = 'SQWL' then

     /*  New York state settings NB. the difference is that the criteria for
         selecting people in the 4th quarter is different to that used for the
         first 3 quarters of the tax year. */

     if p_state = 'NY' then

       if instr(to_char(p_quarter_end,'MM'), '12') = 0 then

         /* Period is one of the first 3 quarters of tax year. */

         p_period_start         := p_quarter_start;
         p_period_end           := p_quarter_end;
         p_defined_balance_id   := bal_db_item('SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD');

       else

         /* Period is the last quarter of the year.*/

         p_period_start         := p_year_start;
         p_period_end           := p_year_end;
         --p_defined_balance_id   := bal_db_item('REGULAR_EARNINGS_PER_GRE_YTD'); /*Bug:2922028*/
         p_defined_balance_id   := bal_db_item('SIT_SUBJ_WHABLE_PER_JD_GRE_YTD'); /*Bug:3388513*/

       end if;

       /* Values are set independent of quarter being reported on. */

       p_group_by_gre         := TRUE;
       p_group_by_medicare    := TRUE;
       p_tax_unit_context     := TRUE;
       p_jurisdiction_context := TRUE;

     else

       /* Default settings for State Quarterly Wage Listing. */
 	hr_utility.set_location ('State',1);
       p_period_start         := p_quarter_start;
       p_period_end           := p_quarter_end;
       p_defined_balance_id   := bal_db_item('SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD');
       p_group_by_gre         := TRUE;
       p_group_by_medicare    := TRUE;
       p_tax_unit_context     := TRUE;
       p_jurisdiction_context := TRUE;

		hr_utility.set_location ('p_period_start -> '|| p_period_start,1);
		hr_utility.set_location ('p_period_end -> '|| p_period_end,1);
		hr_utility.set_location ('p_defined_balance -> SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD',1);
		hr_utility.set_location ('p_defined_balance_id -> '|| p_defined_balance_id,1);

     end if;

   else   /* An invalid report type has been passed so fail. */

     raise hr_utility.hr_error;

   end if;

 end get_selection_information;


 /* Name      : lookup_jurisdiction_code
    Purpose   : Given a state code ie. AL it returns the jurisdiction code that
                represents that state.
    Arguments :
    Notes     :
 */

 function lookup_jurisdiction_code
 (
  p_state varchar2
 ) return varchar2 is

   /* Get the jurisdiction_code for the specified state code. */

   cursor csr_jurisdiction_code is
     select SR.jurisdiction_code
     from   pay_state_rules SR
     where  SR.state_code = p_state;

   l_jurisdiction_code pay_state_rules.jurisdiction_code%type;

 begin

   open csr_jurisdiction_code;
   fetch csr_jurisdiction_code into l_jurisdiction_code;
   if csr_jurisdiction_code%notfound then
     close csr_jurisdiction_code;
     raise hr_utility.hr_error;
   else
     close csr_jurisdiction_code;
   end if;

   return (l_jurisdiction_code);

 end lookup_jurisdiction_code;


  ---------------------------------------------------------------------------
  -- Name
  --   check_residence_state
  -- Purpose
  --  This checks that the state of residence for the given assignment id
  --  is the same as that passed in. Used
  --  in this package to determine if a person has lived in the state of
  --  MA. Such people need to be reported on SQWL for MA.
  -- Arguments
  --  Assignment Id
  --  Period Start Date
  --  Period End Date
  --  State
  ---------------------------------------------------------------------------
--
 FUNCTION check_residence_state (
	p_assignment_id NUMBER,
	p_period_start  DATE,
	p_period_end	DATE,
	p_state			VARCHAR2,
	p_effective_end_date DATE
 ) RETURN BOOLEAN IS

 l_resides_true		VARCHAR2(1);
 BEGIN

	BEGIN
	SELECT '1'
	INTO l_resides_true
	FROM dual
	WHERE EXISTS (
		SELECT '1'
		FROM per_assignments_f paf,
		  per_addresses pad
		WHERE paf.assignment_id = p_assignment_id AND
		  paf.person_id = pad.person_id AND
		  pad.date_from <= p_period_end AND
		  NVL(pad.date_to ,p_period_end) >= p_period_start AND
		  pad.region_2 = p_state AND
		  pad.primary_flag = 'Y');
    EXCEPTION when no_data_found then
	   l_resides_true := '0';
    END;

	hr_utility.trace('l_resides_true =' || l_resides_true);

	IF (l_resides_true = '1' AND
			pay_balance_pkg.get_value(bal_db_item('GROSS_EARNINGS_PER_GRE_QTD'),
			p_assignment_id, least(p_period_end, p_effective_end_date)) <> 0) THEN

		hr_utility.trace('Returning TRUE from check_residence_state');

		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END; -- check_residence_state

  ---------------------------------------------------------------------------
  -- Name
  --   report_person_on_tape
  -- Purpose
  --  This checks various state specific criteria to decide whether the given
  --  person should be reported on the tape.
  -- Arguments
  --  Assignment Id
  --  Period Start Date
  --  Period End Date
  --  State
  --  Effective End Date
  --  1099R_ind
  ---------------------------------------------------------------------------
--
 FUNCTION report_person_on_tape (
	p_assignment_id NUMBER,
	p_period_start  DATE,
	p_period_end	DATE,
	p_state			VARCHAR2,
	p_effective_end_date DATE,
	p_1099R_ind    VARCHAR2
 ) RETURN BOOLEAN IS
 l_ret_value 				BOOLEAN := FALSE;
 l_resides_in_state 		BOOLEAN;
 BEGIN
       IF (p_state = 'MA' ) THEN

                l_resides_in_state := check_residence_state(p_assignment_id,
                p_period_start, p_period_end, p_state, p_effective_end_date);

                l_ret_value := l_resides_in_state;


      END IF;


        IF (p_state = 'CA') THEN

            IF (p_1099R_ind = 'Y') THEN

             l_ret_value := (pay_balance_pkg.get_value(
                bal_db_item('SIT_WITHHELD_PER_JD_GRE_QTD') , p_assignment_id,
                least(p_period_end, p_effective_end_date)) <> 0 );


            ELSE

             l_ret_value := (pay_balance_pkg.get_value(
                bal_db_item('SIT_GROSS_PER_JD_GRE_QTD') , p_assignment_id,
                least(p_period_end, p_effective_end_date)) <> 0 );

            END IF;
        END IF;
        /* Check for ME Bug# 4310812 */
        IF  (p_state = 'ME') THEN
           IF (p_1099R_ind = 'Y') THEN

             l_ret_value := (pay_balance_pkg.get_value(
                bal_db_item('SIT_SUBJ_WHABLE_PER_JD_GRE_QTD') , p_assignment_id,
                least(p_period_end, p_effective_end_date)) <> 0 );
           END IF ;
        END IF ;
        /* Ending Check for ME Bug# 4310812 */

        return l_ret_value;


 END; --report_person_on_tape

  /* Name      : get_user_entity_id
     Purpose   : This gets the user_entity_id for a specific database item name.
     Arguments : p_dbi_name -> database item name.
     Notes     :
  */

  function get_user_entity_id (p_dbi_name in varchar2)
                              return number is
  l_user_entity_id  number;

  begin

    select user_entity_id
    into l_user_entity_id
    from ff_database_items
    where user_name = p_dbi_name;

    return l_user_entity_id;

    exception
    when others then
    hr_utility.trace('Error while getting the user_entity_id'
                                     || to_char(sqlcode));
    raise hr_utility.hr_error;

  end get_user_entity_id;

 /* Name    : action_creation
  Purpose   : This creates the assignment actions for a specific chunk.
  Arguments :
  Notes     :
 */

procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is



   /* Variables used to hold the select columns from the SQL statement.*/

   l_person_id              number;
   l_assignment_id          number;
   l_tax_unit_id            number;
   l_effective_end_date     date;

   /* Variables used to hold the values used as bind variables within the
      SQL statement. */

   l_bus_group_id           number;
   l_period_start           date;
   l_period_end             date;

   /* Variables used to hold the details of the payroll and assignment actions
      that are created. */

   l_payroll_action_created boolean := false;
   l_payroll_action_id      pay_payroll_actions.payroll_action_id%type;
   l_assignment_action_id   pay_assignment_actions.assignment_action_id%type;


   /* Variable holding the balance to be tested. */

   l_defined_balance_id     pay_defined_balances.defined_balance_id%type;

   /* Indicator variables used to control how the people are grouped. */

   l_group_by_gre           boolean := FALSE;
   l_group_by_medicare      boolean := FALSE;

   /* Indicator variables used to control which contexts are set up for
      balance. */

   l_tax_unit_context       boolean := FALSE;
   l_jurisdiction_context   boolean := FALSE;

   /* Indicator variable used to check if the GRE has a default wage plan */

   l_gre_wage_plan_exist   BOOLEAN  := FALSE;

   /* Variables used to hold the current values returned within the loop for
      checking against the new values returned from within the loop on the
      next iteration. */

   l_prev_person_id         per_people_f.person_id%type;
   l_prev_asg_id            per_assignments_f.assignment_id%type;
   l_prev_tax_unit_id       hr_organization_units.organization_id%type;

   /* Variable to hold the jurisdiction code used as a context for state
      reporting. */

   l_jurisdiction_code      varchar2(30);

   /* general process variables */

   l_report_type    pay_payroll_actions.report_type%type;
   l_report_cat     pay_payroll_actions.report_category%type;
   l_state          pay_payroll_actions.report_qualifier%type;
   l_report_format  pay_report_format_mappings_f.report_format%type; -- Bug# 3843134
   l_value          number;
   l_value_sit      number ; --4310812
   l_person_on      boolean ; --4349864
   l_effective_date date;
   l_quarter_start  date;
   l_quarter_end    date;
   l_year_start     date;
   l_year_end       date;
	l_1099R_ind      varchar2(2);
   lockingactid     number;
----------
    /*This select is same as cursor c_state except the check for
      NVL(HOI.org_information16, 'No') = 'Yes'*/

  CURSOR c_state_la_quality IS
    SELECT
            ASG.person_id              person_id,
            ASG.assignment_id          assignment_id,
            paa.tax_unit_id            tax_unit_id,
            ppa.effective_date          effective_end_date
    FROM    per_all_assignments_f          ASG,
            pay_assignment_actions      paa,
            pay_payroll_actions        ppa
    WHERE  ppa.effective_date between l_period_start
                                  and l_period_end
      and  ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
      and  paa.payroll_action_id = ppa.payroll_action_id
      and  paa.assignment_id = ASG.assignment_id
      /*added to ignore skipped assignment */
      and  paa.action_status <> 'S'
  --  and  ppa.effective_date between ASG.effective_start_date and ASG.effective_end_date
            /* Added for Performance, 01-JUL-2003 */
      and  asg.effective_end_date   >= l_period_start
      and  asg.effective_start_date <= l_period_end

      and  ASG.business_group_id + 0  =  l_bus_group_id
      and  ASG.person_id between stperson and endperson
      and  ASG.assignment_type        = 'E'
      and ASG.business_group_id = ppa.business_group_id -- 5152728
      and exists (select '1'
                    from pay_us_asg_reporting puar,
                          pay_state_rules SR
                    where SR.state_code  = l_state
                      and substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
                      and ASG.assignment_id = puar.assignment_id
                  )
    ORDER  BY 1, 3, 4 DESC, 2 ;

-- Added for Bug# 4349864
-- Used when RANGE_PERSON_ID functionality is available

  CURSOR c_state_la_quality_person_on IS
    SELECT
            ASG.person_id              person_id,
            ASG.assignment_id          assignment_id,
            paa.tax_unit_id            tax_unit_id,
            ppa.effective_date          effective_end_date
    FROM    per_all_assignments_f          ASG,
            pay_assignment_actions      paa,
            pay_payroll_actions        ppa,
            pay_population_ranges   ppr
    WHERE  ppa.effective_date between l_period_start
                                  and l_period_end
      and  ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
      and  paa.payroll_action_id = ppa.payroll_action_id
      and  paa.assignment_id = ASG.assignment_id
      /*added to ignore skipped assignment */
      and  paa.action_status <> 'S'
  --  and  ppa.effective_date between ASG.effective_start_date and ASG.effective_end_date
            /* Added for Performance, 01-JUL-2003 */
      and  asg.effective_end_date   >= l_period_start
      and  asg.effective_start_date <= l_period_end

      and  ASG.business_group_id + 0  =  l_bus_group_id
      --and  ASG.person_id between stperson and endperson
      and  ppr.payroll_action_id = pactid
      and  ppr.chunk_number = chunk
      and  ppr.person_id = ASG.person_id
      and  ASG.assignment_type        = 'E'
      and ASG.business_group_id = ppa.business_group_id -- 5152728
      and exists (select '1'
                    from pay_us_asg_reporting puar,
                          pay_state_rules SR
                    where SR.state_code  = l_state
                      and substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
                      and ASG.assignment_id = puar.assignment_id
                  )
    ORDER  BY 1, 3, 4 DESC, 2 ;

  CURSOR c_state IS
    SELECT
            ASG.person_id              person_id,
            ASG.assignment_id          assignment_id,
            paa.tax_unit_id            tax_unit_id,
            ppa.effective_date          effective_end_date
    FROM    per_all_assignments_f          ASG,
            pay_assignment_actions      paa,
            pay_payroll_actions        ppa
    WHERE  ppa.effective_date between l_period_start
                                  and l_period_end
      and  ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
      and  paa.payroll_action_id = ppa.payroll_action_id
      and  paa.assignment_id = ASG.assignment_id
      /*added to ignore skipped assignment */
      and  paa.action_status <> 'S'
    --  and  ppa.effective_date between ASG.effective_start_date and ASG.effective_end_date
            /* Added for Performance, 01-JUL-2003 */
      and  asg.effective_end_date   >= l_period_start
      and  asg.effective_start_date <= l_period_end

      and  ASG.business_group_id + 0  =  l_bus_group_id
      and  ASG.person_id between stperson and endperson
      and  ASG.assignment_type        = 'E'
      and ASG.business_group_id = ppa.business_group_id -- 5152728
      and exists (select '1'
                    from pay_us_asg_reporting puar,
                          pay_state_rules SR
                    where SR.state_code  = l_state
                      and substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
                      and ASG.assignment_id = puar.assignment_id
                  )
    ORDER  BY 1, 3, 4 DESC, 2 ;

-- Added for Bug# 3843134 (Performance Issue)
-- Used when RANGE_PERSON_ID functionality is available

  CURSOR c_state_person_on IS
    SELECT
            ASG.person_id              person_id,
            ASG.assignment_id          assignment_id,
            paa.tax_unit_id            tax_unit_id,
            ppa.effective_date          effective_end_date
    FROM    per_all_assignments_f          ASG,
            pay_assignment_actions      paa,
            pay_payroll_actions        ppa,
            pay_population_ranges      ppr
    WHERE  ppa.effective_date between l_period_start
                                  and l_period_end
      and  ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
      and  paa.payroll_action_id = ppa.payroll_action_id
      and  paa.assignment_id = ASG.assignment_id
      /*added to ignore skipped assignment */
      and  paa.action_status <> 'S'
    --  and  ppa.effective_date between ASG.effective_start_date and ASG.effective_end_date
            /* Added for Performance, 01-JUL-2003 */
      and  asg.effective_end_date   >= l_period_start
      and  asg.effective_start_date <= l_period_end

      and  ASG.business_group_id + 0  =  l_bus_group_id
    --  and  ASG.person_id between stperson and endperson
      and ppr.payroll_action_id = pactid
      and ppr.chunk_number = chunk
      and asg.person_id = ppr.person_id
      and ASG.assignment_type        = 'E'
      and ASG.business_group_id = ppa.business_group_id -- 5152728
      and exists (select '1'
                    from pay_us_asg_reporting puar,
                          pay_state_rules SR
                    where SR.state_code  = l_state
                      and substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
                      and ASG.assignment_id = puar.assignment_id
                  )
    ORDER  BY 1, 3, 4 DESC, 2 ;

    /*This select in c_ct_non_profit is same as cursor c_state except the check for
      NVL(HOI.org_information20, 'No') = 'Yes'*/

  CURSOR c_ct_non_profit IS
    SELECT
            ASG.person_id              person_id,
            ASG.assignment_id          assignment_id,
            paa.tax_unit_id            tax_unit_id,
            ppa.effective_date          effective_end_date
    FROM    per_all_assignments_f          ASG,
            pay_assignment_actions      paa,
            pay_payroll_actions        ppa
    WHERE  ppa.effective_date between l_period_start
                                  and l_period_end
      and  ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
      and  paa.payroll_action_id = ppa.payroll_action_id
      and  paa.assignment_id = ASG.assignment_id
      /*added to ignore skipped assignment */
      and  paa.action_status <> 'S'
      --  and  ppa.effective_date between ASG.effective_start_date and ASG.effective_end_date
            /* Added for Performance, 01-JUL-2003 */
      and  asg.effective_end_date   >= l_period_start
      and  asg.effective_start_date <= l_period_end

      and  ASG.business_group_id + 0  =  l_bus_group_id
      and  ASG.person_id between stperson and endperson
      and  ASG.assignment_type        = 'E'
      and exists (select '1'
                    from pay_us_asg_reporting puar,
                          pay_state_rules SR
                    where SR.state_code  = l_state
                      and substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
                      and ASG.assignment_id = puar.assignment_id
                  )
    ORDER  BY 1, 3, 4 DESC, 2 ;

-- Added for Bug# 4349864
-- Used when RANGE_PERSON_ID functionality is available

  CURSOR c_ct_non_profit_person_on IS
    SELECT
            ASG.person_id              person_id,
            ASG.assignment_id          assignment_id,
            paa.tax_unit_id            tax_unit_id,
            ppa.effective_date          effective_end_date
    FROM    per_all_assignments_f          ASG,
            pay_assignment_actions      paa,
            pay_payroll_actions        ppa,
            pay_population_ranges  ppr
    WHERE  ppa.effective_date between l_period_start
                                  and l_period_end
      and  ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
      and  paa.payroll_action_id = ppa.payroll_action_id
      and  paa.assignment_id = ASG.assignment_id
      /*added to ignore skipped assignment */
      and  paa.action_status <> 'S'
      --  and  ppa.effective_date between ASG.effective_start_date and ASG.effective_end_date
            /* Added for Performance, 01-JUL-2003 */
      and  asg.effective_end_date   >= l_period_start
      and  asg.effective_start_date <= l_period_end

      and  ASG.business_group_id + 0  =  l_bus_group_id
      --and  ASG.person_id between stperson and endperson
      and ppr.payroll_action_id = pactid
      and ppr.chunk_number = chunk
      and ppr.person_id = ASG.person_id
      and  ASG.assignment_type        = 'E'
      and exists (select '1'
                    from pay_us_asg_reporting puar,
                          pay_state_rules SR
                    where SR.state_code  = l_state
                      and substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
                      and ASG.assignment_id = puar.assignment_id
                  )
    ORDER  BY 1, 3, 4 DESC, 2 ;

-------

   CURSOR c_state_pr IS
     SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            paa.tax_unit_id             tax_unit_id,
            ppa.effective_date          effective_end_date
     FROM   per_all_assignments_f           ASG,
            pay_assignment_actions      paa,
            pay_payroll_actions         ppa,
            hr_organization_information HOI_PR
     WHERE  ppa.effective_date between l_period_start and l_period_end
       AND  ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
       AND  paa.payroll_action_id = ppa.payroll_action_id
       AND  hoi_pr.organization_id =  paa.tax_unit_id
       AND  HOI_pr.org_information_context = 'W2 Reporting Rules'
       AND  NVL(HOI_pr.org_information16, 'A') = 'P'
       AND  paa.assignment_id = ASG.assignment_id
      /*added to ignore skipped assignment */
      and  paa.action_status <> 'S'
    --  and  ppa.effective_date between ASG.effective_start_date and ASG.effective_end_date
            /* Added for Performance, 01-JUL-2003 */
       and  asg.effective_end_date   >= l_period_start
       and  asg.effective_start_date <= l_period_end

       AND  ASG.business_group_id + 0   =  l_bus_group_id
       AND  ASG.person_id between stperson and endperson
      and  ASG.assignment_type        = 'E'
       AND EXISTS (select 'x'
                     from pay_us_asg_reporting puar,
                          pay_state_rules             SR
                    where substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
                      and ASG.assignment_id = puar.assignment_id
                      and puar.tax_unit_id = hoi_pr.organization_id
                      and SR.state_code = l_state)
/*      there shouldn't be any dependency on state tax rules
		    AND EXISTS (select 'x'
                   from   hr_organization_information HOI
                   where hoi.organization_id = hoi_pr.organization_id
                   AND  HOI.org_information_context = 'State Tax Rules'
                   AND  HOI.org_information1 = l_state
                   AND  NVL(HOI.org_information16, 'No') = 'No'
                   AND  NVL(HOI.org_information20, 'No') = 'No')           */
     ORDER  BY 1, 3, 4 DESC, 2;

-- Added for Bug# 4349864
-- Used when RANGE_PERSON_ID functionality is available

   CURSOR c_state_pr_person_on IS
     SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            paa.tax_unit_id             tax_unit_id,
            ppa.effective_date          effective_end_date
     FROM   per_all_assignments_f           ASG,
            pay_assignment_actions      paa,
            pay_payroll_actions         ppa,
            hr_organization_information HOI_PR,
            pay_population_ranges ppr
     WHERE  ppa.effective_date between l_period_start and l_period_end
       AND  ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
       AND  paa.payroll_action_id = ppa.payroll_action_id
       AND  hoi_pr.organization_id =  paa.tax_unit_id
       AND  HOI_pr.org_information_context = 'W2 Reporting Rules'
       AND  NVL(HOI_pr.org_information16, 'A') = 'P'
       AND  paa.assignment_id = ASG.assignment_id
      /*added to ignore skipped assignment */
      and  paa.action_status <> 'S'
    --  and  ppa.effective_date between ASG.effective_start_date and ASG.effective_end_date
            /* Added for Performance, 01-JUL-2003 */
       and  asg.effective_end_date   >= l_period_start
       and  asg.effective_start_date <= l_period_end

       AND  ASG.business_group_id + 0   =  l_bus_group_id
       --AND  ASG.person_id between stperson and endperson
      and ppr.payroll_action_id = pactid
      and ppr.chunk_number = chunk
      and ppr.person_id = ASG.person_id
      and  ASG.assignment_type        = 'E'
       AND EXISTS (select 'x'
                     from pay_us_asg_reporting puar,
                          pay_state_rules             SR
                    where substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
                      and ASG.assignment_id = puar.assignment_id
                      and puar.tax_unit_id = hoi_pr.organization_id
                      and SR.state_code = l_state)
/*      there shouldn't be any dependency on state tax rules
		    AND EXISTS (select 'x'
                   from   hr_organization_information HOI
                   where hoi.organization_id = hoi_pr.organization_id
                   AND  HOI.org_information_context = 'State Tax Rules'
                   AND  HOI.org_information1 = l_state
                   AND  NVL(HOI.org_information16, 'No') = 'No'
                   AND  NVL(HOI.org_information20, 'No') = 'No')           */
     ORDER  BY 1, 3, 4 DESC, 2;

/* California Multi Wage Plan Requirement */

CURSOR c_chk_gre_wp (p_tax_unit_id  number) IS
SELECT count(*) ct
  FROM hr_organization_information
 WHERE organization_id  = p_tax_unit_id
   AND org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO'
   AND org_information1         = 'CA'
   AND org_information4         = 'Y';

CURSOR c_chk_asg_wp (p_assignment_id  number) IS
SELECT count(*) ct
  FROM per_assignment_extra_info paei
 WHERE paei.assignment_id            = p_assignment_id
   AND paei.information_type         = 'PAY_US_ASG_STATE_WAGE_PLAN_CD'
   AND paei.aei_information1         = 'CA'
   AND paei.aei_information3 IS NOT NULL;


--
   begin
     hr_utility.trace('Entered action creation');

  /* added initalization for l_prev_tax_unit_id */

    l_prev_tax_unit_id := -99999999;

  /* Return details used to control the selection of people to report on ie.
      the SQL statement to run, the period over which to look for the people,
      how to group the people, etc... */

   select effective_date,
          report_type,
          report_qualifier,
		  report_category,
          business_group_id
   into   l_effective_date,
          l_report_type,
          l_state,
		  l_report_cat,
          l_bus_group_id
   from pay_payroll_actions
   where payroll_action_id = pactid;


	hr_utility.set_location ('actio_creation',1);
--
   get_dates(l_report_type,
             l_effective_date,
             l_period_end,
             l_quarter_start,
             l_quarter_end,
             l_year_start,
             l_year_end);

	hr_utility.set_location ('actio_creation',2);
--
   get_selection_information
     (l_report_type,
      l_state,
      l_quarter_start,
      l_quarter_end,
      l_year_start,
      l_year_end,
      l_period_start,
      l_period_end,
      l_defined_balance_id,
      l_group_by_gre,
      l_group_by_medicare,
      l_tax_unit_context,
      l_jurisdiction_context);

	hr_utility.set_location ('actio_creation',3);

   --
   -- Get the jurisdiction code for the state if appropriate.
   --
   if l_jurisdiction_context then
     l_jurisdiction_code := lookup_jurisdiction_code(l_state);
   end if;
   -- Check for the Range Person ID Functionality

   /* Initializing variable */
   l_person_on  := FALSE ; --4349864

   Begin
        select report_format
        into   l_report_format
        from   pay_report_format_mappings_f
        where  report_type = l_report_type
        and    report_qualifier = l_state
        and    report_category = l_report_cat ;
   Exception
        When Others Then
            l_report_format := Null ;
   End ;

   l_person_on := pay_ac_utility.range_person_on( p_report_type => l_report_type,
                                          p_report_format => l_report_format,
                                          p_report_qualifier => l_state,
                                          p_report_category => l_report_cat) ;

   --
   -- Open up a cursor for processing a SQL statement.
   --
   if (l_state = 'LA' and l_report_cat = 'RTLAQ') then
       if l_person_on then
         OPEN c_state_la_quality_person_on ;
       else
         OPEN c_state_la_quality;
       end if ;
   elsif (l_state = 'CT' and l_report_cat = 'RTCTN') then
        if l_person_on then
          OPEN c_ct_non_profit_person_on ;
        else
          OPEN c_ct_non_profit;
        end if ;
   elsif (l_state = 'PR') THEN
        if l_person_on then
          OPEN c_state_pr_person_on ;
        else
          OPEN c_state_pr;
        end if ;
   else
        if l_person_on then
          OPEN c_state_person_on ;
       else
          OPEN c_state;
       end if ;
   end if;

   --
   -- Loop for all rows returned for SQL statement.
   --

   LOOP
   if (l_state = 'LA' and l_report_cat = 'RTLAQ') then
     hr_utility.set_location ('actio_creation',4);
     if l_person_on then
	 FETCH c_state_la_quality_person_on INTO l_person_id,
	                                         l_assignment_id,
						 l_tax_unit_id,
						 l_effective_end_date;
	 EXIT WHEN c_state_la_quality_person_on%NOTFOUND;
     else
	 FETCH c_state_la_quality INTO l_person_id,
				       l_assignment_id,
				       l_tax_unit_id,
				       l_effective_end_date;
         EXIT WHEN c_state_la_quality%NOTFOUND;
     end if ;

   elsif (l_state = 'CT' and l_report_cat = 'RTCTN') then
      hr_utility.set_location ('actio_creation',4);
      if l_person_on then
         FETCH c_ct_non_profit_person_on INTO l_person_id,
                                              l_assignment_id,
                                              l_tax_unit_id,
                                              l_effective_end_date;
         EXIT WHEN c_ct_non_profit_person_on%NOTFOUND;
      else
         FETCH c_ct_non_profit INTO l_person_id,
                                    l_assignment_id,
                                    l_tax_unit_id,
                                    l_effective_end_date;
         EXIT WHEN c_ct_non_profit%NOTFOUND;
      end if ;

   elsif (l_state = 'PR') THEN
      hr_utility.set_location ('actio_creation',4);
      if  l_person_on then
         FETCH c_state_pr_person_on INTO l_person_id,
                                         l_assignment_id,
                                         l_tax_unit_id,
                                         l_effective_end_date;
          EXIT WHEN c_state_pr_person_on%NOTFOUND;
       else
          FETCH c_state_pr INTO l_person_id,
                                l_assignment_id,
                                l_tax_unit_id,
                                l_effective_end_date;
          EXIT WHEN c_state_pr%NOTFOUND;
       end if ;

   else
       hr_utility.set_location ('actio_creation',5);
       -- If it is on then fetch from c_state_person_on cursor else c_state
       if l_person_on then
	 FETCH c_state_person_on INTO   l_person_id,
                                         l_assignment_id,
					 l_tax_unit_id,
					 l_effective_end_date;
         EXIT WHEN c_state_person_on%NOTFOUND;
       else
         FETCH c_state INTO l_person_id,
		            l_assignment_id,
		            l_tax_unit_id,
			    l_effective_end_date;
			    --l_1099R_ind;
         EXIT WHEN c_state%NOTFOUND;
       end If ;

   end if;

     --
     -- If the new row is the same as the previous row according to the way
     -- the rows are grouped then discard the row ie. grouping by GRE
     -- requires a single row for each person / GRE combination.
     --
     if (l_group_by_gre                         and
          l_person_id       = l_prev_person_id   and
          l_tax_unit_id     = l_prev_tax_unit_id
           ) then
        --
        -- Do nothing.
        --
        null;
        --
        -- Have a new unique row according to the way the rows are grouped.
        -- The inclusion of the person is dependent on having a non zero
        -- balance.
        -- If the balance is non zero then an assignment action is created to
        -- indicate their inclusion in the magnetic tape report.
        --
     else
			hr_utility.set_location ('actio_creation',6);
        --
        -- Set up contexts required to test the balance.
        --
        -- Set up TAX_UNIT_ID context if appropriate.
        --
        if l_tax_unit_context then
           pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
        end if;
        --
        -- Set up JURISDICTION_CODE context if appropriate.
        --
        if l_jurisdiction_context then
           pay_balance_pkg.set_context('JURISDICTION_CODE',l_jurisdiction_code);
        end if;
        --
        --
        -- Check the balance.
        --
          if (l_tax_unit_id <> l_prev_tax_unit_id)
          then
             begin
                select 'Y'
                into l_1099R_ind
                from hr_organization_information
                where organization_id = l_tax_unit_id
                and org_information_context = '1099R Magnetic Report Rules';
             exception
                when no_data_found then
                   l_1099R_ind := null;
             end;
          end if;
		  if (nvl(l_1099R_ind, 'N') <> 'Y') then
			  l_value := pay_balance_pkg.get_value
							  (l_defined_balance_id,
                   				           l_assignment_id,
							least(l_period_end,l_effective_end_date));
	  --4310812
               If l_state = 'ME' Then
                 l_value_sit := pay_balance_pkg.get_value(bal_db_item('SIT_SUBJ_WHABLE_PER_JD_GRE_QTD') ,
                                                         l_assignment_id,
                                                         least(l_period_end, l_effective_end_date)) ;

                 If nvl(l_value,0) <> 0 and nvl(l_value_sit,0) <> 0 Then
                     l_value := greatest(l_value,l_value_sit) ;
                 Elsif nvl(l_value,0) = 0 and nvl(l_value_sit,0) <> 0 Then
                     l_value := l_value_sit ;
                 End If ;
              End If ; -- end check for ME Non 1099R GRE


                     if (l_value = 0 AND l_state = 'NY') then /*Check for NY Bug:2922028*/

                         hr_utility.trace('Entered NY Checking ');

                        if instr(to_char(l_quarter_end,'MM'), '12') <> 0 then /*Check for Last Quarter*/

                           hr_utility.trace('Last Quarter.Check the values for SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD');

			   l_value := pay_balance_pkg.get_value
				     (bal_db_item('SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD'),
                   				   l_assignment_id,
						   least(l_period_end,l_effective_end_date));

                           hr_utility.trace('Value of SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD = '||l_value);

                              if l_value = 0 then /*Check for SUBJ_WHABLE*/

                                 hr_utility.trace('Value of SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD is 0');

                                 If l_effective_end_date < l_quarter_start THEN /*l_effective_end_date checking */
                                                                                /*Bug:3281209*/

                                    hr_utility.trace('l_effective_end_date < l_quarter_start');
                                    l_value := 0;

                                 ELSE

                                    l_value := pay_balance_pkg.get_value
                                                          (bal_db_item('SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD'),
                                                           l_assignment_id,
                                                           least(l_period_end,l_effective_end_date));

                                    hr_utility.trace('Value of SUI_ER_SUBJ_WHABLE_PER = '||l_value);

                                 End if; /*l_effective_end_date checking */

                              end if; /*Check for SUBJ_WHABLE*/

                        end if; /*Check for Last Quarter*/

                     end if; /*Check for NY*/

	  else
              l_value := 0;
        end if;

		hr_utility.trace('l_value = ' || to_char(l_value));
		hr_utility.trace('l_assignment_id = ' || to_char(l_assignment_id));
		hr_utility.trace('l_period_start = ' || l_period_start);
		hr_utility.trace('l_quarter_start = ' || l_quarter_start);
		hr_utility.trace('l_period_end = ' || l_period_end);
		hr_utility.trace('l_state = ' || l_state);
		hr_utility.trace('l_effective_end_date = ' || l_effective_end_date);
		hr_utility.trace('l_1099R_ind = ' || l_1099R_ind);

      if ((l_value <> 0) OR
				 report_person_on_tape(l_assignment_id, l_period_start,
				 l_period_end, l_state, l_effective_end_date, l_1099R_ind)) then
			hr_utility.set_location ('actio_creation',7);
          --
          -- Have found a person that needs to be reported in the federal W2 so
          -- need to create an assignment action for it.


          -- California Multi Wage Plan requirement
          -- Check if the state is CA and Asg has a wage plan
          -- defined or it can default to the Wage Plan defined
          -- at the GRE level. Other wise error out.


             IF l_state = 'CA' THEN

             -- Check if the GRE has a wage Plan defined

               l_gre_wage_plan_exist := TRUE;

               FOR c_rec IN  c_chk_gre_wp (l_tax_unit_id)
               LOOP

                 IF c_rec.ct = 0 THEN
                    l_gre_wage_plan_exist := FALSE;
                 END IF;

               END LOOP;

               IF l_gre_wage_plan_exist = FALSE THEN

                  FOR c_rec IN c_chk_asg_wp (l_assignment_id)
                  LOOP
                      IF c_rec.ct = 0  THEN
                           hr_utility.set_message(801, 'PAY_7024_USERTAB_BAD_ROW_VALUE');
                           hr_utility.set_message_token('FORMAT',' wage plan not defined at GRE');
                           hr_utility.raise_error;
                      END IF;
                  END LOOP;

               END IF;

            END IF;
          --
          -- If the payroll action has not been created yet i.e. this is the
          -- first assignment action then create it.
          --
          --
          -- Create the assignment action to represnt the person / tax unit
          -- combination.
          --
            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;
--
            -- insert into pay_assignment_actions.
            hr_nonrun_asact.insact(lockingactid,l_assignment_id,
                                   pactid,chunk,l_tax_unit_id);
				hr_utility.set_location ('actio_creation',8);

           archive_asg_locs( lockingactid, pactid, l_assignment_id);



        end if;
     end if;
     --
     -- Record the current values for the next time around the loop.
     --
     l_prev_person_id   := l_person_id;
     l_prev_asg_id      := l_assignment_id;
     l_prev_tax_unit_id := l_tax_unit_id;
     --
   END LOOP;
end action_creation;

 /* Name      : archinit
    Purpose   : This performs the US specific initialisation section.
    Arguments :
    Notes     :
 */


 procedure archinit(p_payroll_action_id in number) is
      jurisdiction_code      pay_state_rules.jurisdiction_code%TYPE;
      l_state                VARCHAR2(30);
      l_report_cat           pay_report_format_mappings_f.report_category%TYPE;

  /* Bug 773937 */
      l_archive            boolean:= FALSE;

      cursor c_get_min_chunk is
      select min(paa.chunk_number)
      from pay_assignment_actions paa
      where paa.payroll_action_id = p_payroll_action_id;

  /* End of Bug 773937 */

begin
      hr_utility.set_location ('archinit',1);

         -- Derive state
      select report_qualifier,
             report_category
      into l_state,
           l_report_cat
      from pay_payroll_actions
      where payroll_action_id = p_payroll_action_id;

/* Added the select of report_category field in the above SQL on
   10-FEB-2000 by Ashu Gupta (ashgupta) */

      hr_utility.set_location ('archinit',2);

         -- Get jurisdiction code and store as a context
      IF l_state <> 'FED' THEN
         SELECT sr.jurisdiction_code
            INTO jurisdiction_code
            FROM pay_state_rules sr
            WHERE sr.state_code = l_state;

/* Bug 976472 */
      g_sqwl_state := l_state;
      g_sqwl_jursd := jurisdiction_code;
/* End Bug 976472 */
      g_report_cat := l_report_cat;

/* Added the g_report_cat variable on 10-FEB-2000 by Ashu Gupta (ashgupta).
   This variable will be used in archive_data procedure to decide the report
   category */

      pay_balance_pkg.set_context ('JURISDICTION_CODE',jurisdiction_code);
    END IF;
/* Bug 773937 */
      hr_utility.set_location ('archinit getting min chunk number',10);
      open c_get_min_chunk;
      fetch c_get_min_chunk into g_min_chunk;
      if c_get_min_chunk%NOTFOUND then
           g_min_chunk := -1;
           hr_utility.set_location ('archinit min chunk is -1',11);
           raise hr_utility.hr_error;
      end if;
      close c_get_min_chunk;

        /* Check if GRE level data has been archived or not and set the g_archive_flag to Y or N*/
        l_archive := chk_gre_archive(p_payroll_action_id);

/* END of Bug 773937 */

  exception
   when others then
     raise;
end archinit;

 /* Name      : eoy_get_jursd_level
    Purpose   : This returns the jurisdiction level of the non balance
                database items.
    Arguments :
    Notes     :
 */

 function eoy_get_jursd_level(p_route_id  number,
                        p_user_entity_id number) return number is
 l_jursd_value   number:= 0;

 begin

 select frpv.value
 into l_jursd_value
 from ff_route_parameter_values frpv,
      ff_route_parameters frp
 where   frpv.route_parameter_id = frp.route_parameter_id
 and   frpv.user_entity_id = p_user_entity_id
 and   frp.route_id = p_route_id
 and   frp.parameter_name = 'Jursd. Level';

 return(l_jursd_value);

 exception
 when no_data_found then
  return(0);
 when others then
  hr_utility.trace('Error while getting the jursd. value ' ||
          to_char(sqlcode));

 end eoy_get_jursd_level;



  procedure create_archive (p_user_entity_id in number,
                            p_context1       in number,
                            p_value          in varchar2,
                            p_sequence       in pay_us_sqwl_archive.number_data_type_table,
                            p_context        in pay_us_sqwl_archive.char240_data_type_table,
                            p_context_id     in pay_us_sqwl_archive.number_data_type_table) is
  l_step    number := 0;

  begin

          l_step := 1;

          insert into ff_archive_items
          (ARCHIVE_ITEM_ID,
           USER_ENTITY_ID,
           CONTEXT1,
           VALUE,
           ARCHIVE_TYPE)
          values
          (ff_archive_items_s.nextval,
           p_user_entity_id,
           p_context1,
           p_value,
           'PPA'); /* Bug:2965887 */

          l_step := 2;

          for i in p_sequence.first .. p_sequence.last
          loop
              insert into ff_archive_item_contexts
              (ARCHIVE_ITEM_ID,
               SEQUENCE_NO,
               CONTEXT,
               CONTEXT_ID)
               values
              (ff_archive_items_s.currval,
               p_sequence(i),
               p_context(i),
               p_context_id(i));
          end loop;

          exception
          when others then
            if l_step = 1 then
              hr_utility.trace('Error while inserting into ff_archive_items'
                                     || to_char(sqlcode));
              raise hr_utility.hr_error;

            elsif l_step = 2 then
              hr_utility.trace('Error while inserting into ff_archive_item_contexts'
                                     || to_char(sqlcode));
              raise hr_utility.hr_error;

            end if;

   end create_archive;

 /* Bug 773937 */

  /* Name      : archive_gre_data
     Purpose   : This performs the US specific employer data archiving.
     Arguments :
     Notes     :
  */

  procedure archive_gre_data(p_payroll_action_id in number,
                             p_tax_unit_id       in number)
  is

  l_user_entity_id          number;
  l_tax_context_id          number;
  l_jursd_context_id        number;
  l_value                   varchar2(240);
  l_seq_tab                 pay_us_sqwl_archive.number_data_type_table;
  l_context_id_tab          pay_us_sqwl_archive.number_data_type_table;
  l_context_val_tab         pay_us_sqwl_archive.char240_data_type_table;
  l_arch_gre_step           number := 0;

  l_state_code              pay_us_states.state_code%type;

  l_from                    number;
  l_to                      number;
  l_length                  number;

  begin

   /* Get the context_id for 'TAX_UNIT_ID' */

    l_arch_gre_step := 10;

    select context_id
    into l_tax_context_id
    from ff_contexts
    where context_name = 'TAX_UNIT_ID';

    /* Get the context_id for 'JURISDICTION_CODE' */

    l_arch_gre_step := 20;

    select context_id
    into l_jursd_context_id
    from ff_contexts
    where context_name = 'JURISDICTION_CODE';


    /* get the state code for the state abbrev */
    /* Start Position of State */
    select INSTR(legislative_parameters,'TRANSFER_STATE=')
                               + LENGTH('TRANSFER_STATE=')
    into l_from
    from pay_payroll_actions
    where payroll_action_id = p_payroll_action_id;


    /* End position of state in legislative parameters */
    select INSTR(legislative_parameters,'TRANSFER_REPORTING_YEAR=')
    into l_to
    from pay_payroll_actions
    where payroll_action_id = p_payroll_action_id;

    l_length := l_to - l_from - 1 ;

     Select state_code
     into l_state_code
     from pay_us_states
     where state_abbrev = (
                 select substr(legislative_parameters,l_from, l_length )
                 from pay_payroll_actions
                 where payroll_action_id = p_payroll_action_id);

      /* Archive the Taxable wage Base */

   l_user_entity_id := get_user_entity_id('A_SUI_TAXABLE_WAGE_BASE');

   l_arch_gre_step := 21;

   begin
       select to_char(sti.sui_er_wage_limit)
       into   l_value
       from   pay_us_state_tax_info_f sti,
              pay_payroll_actions ppa
       where ppa.payroll_action_id =  p_payroll_action_id
       and sti.state_code = l_state_code
       and ppa.effective_date  between sti.effective_start_date
           and sti.effective_end_date
       and sti.sta_information_category = 'State tax limit rate info';

    exception
          when no_data_found then
            l_value := null;
    end;

     /* Initialise the PL/SQL tables */
      l_arch_gre_step := 22;

       l_seq_tab.delete;
       l_context_id_tab.delete;
       l_context_val_tab.delete;

      /* Assign  value to PL/SQL tables */

       l_arch_gre_step := 23;

        l_seq_tab(1) := 1;
        l_context_id_tab(1) := l_tax_context_id;
        l_context_val_tab(1) := to_char(p_tax_unit_id);
        l_seq_tab(2) := 2;
        l_context_id_tab(2) := l_jursd_context_id;
        l_context_val_tab(2) := l_state_code || '-000-0000';

        l_arch_gre_step := 24;

        create_archive (p_user_entity_id => l_user_entity_id,
                        p_context1       => p_payroll_action_id,
                        p_value          => l_value,
                        p_sequence       => l_seq_tab,
                        p_context        => l_context_val_tab,
                        p_context_id     => l_context_id_tab);

        g_archive_flag := 'Y';
     exception
        when others then
        g_archive_flag := 'N';

   end archive_gre_data;
  /* End of Bug 773937 */


  /* Name      : chk_gre_archive
     Purpose   : Function to check if the employer level data has been archived
                 or not.
     Arguments :
     Notes     :
  */

  function chk_gre_archive (p_payroll_action_id number) return boolean is

  l_flag varchar2(1);

  cursor c_chk_payroll_action is
     select 'Y'
     from dual
     where exists (select null
               from ff_archive_items fai
               where fai.context1 = p_payroll_action_id
               and archive_type = 'PPA'); /* Bug:2965887 */
  begin

     hr_utility.trace('chk_gre_archive - checking g_archive_flag');

     if g_archive_flag = 'Y' then
        hr_utility.trace('chk_gre_archive - g_archive_flag is Y');
        return (TRUE);
     else

       hr_utility.trace('chk_gre_archive - opening cursor');

       open c_chk_payroll_action;
       fetch c_chk_payroll_action into l_flag;
       if c_chk_payroll_action%FOUND then
          hr_utility.trace('chk_gre_archive - found in cursor');
          g_archive_flag := 'Y';
       else
          hr_utility.trace('chk_gre_archive - not found in cursor');
          g_archive_flag := 'N';
       end if;

       hr_utility.trace('chk_gre_archive - closing cursor');
       close c_chk_payroll_action;
       if g_archive_flag = 'Y' then
          hr_utility.trace('chk_gre_archive - returning true');
          return (TRUE);
       else
          hr_utility.trace('chk_gre_archive - returning false');
          return(FALSE);
       end if;
     end if;
  end chk_gre_archive;


  /* Name      : archive_data
     Purpose   : This performs the US specific employee context setting for the SQWL
                 report.
     Arguments :
     Notes     :
  */

  procedure archive_data(p_assactid in number, p_effective_date in date) is

    aaid           pay_assignment_actions.assignment_action_id%type;
    aaseq          pay_assignment_actions.action_sequence%type;
    asgid          pay_assignment_actions.assignment_id%type;
    date_earned    date;
    eff_date       date;
    l_year_start   date;
    l_year_end     date;
    taxunitid      pay_assignment_actions.tax_unit_id%type;
    l_period_start date;
    l_period_end   date;

  /* Bug 773937 */
    l_chunk                   number;
    l_payroll_action_id       number;
  /* End of Bug 773937 */


/* The following variables were added on 08-FEB-2000 by Ashu Gupta(ashgupta) to
   take care of archiving of Wage Plan Codes in California */

    l_user_entity_id           NUMBER;
    l_context_id_assignment_id NUMBER;
    l_quarter_start            DATE  ;
    l_quarter_end              DATE  ;
    l_wage_plan_code           per_assignment_extra_info.aei_information3%TYPE;
    l_assignment_id            NUMBER;

    l_wage_plan_ct             NUMBER := 0;      -- Added by tmehra

/* Bug 976472 */

    l_jurisdiction varchar2(11);
    l_count        number := 0;
    l_context_no   number := 0;
    l_temp_var     number := 0;

    /* Get the jurisdiction code of all the cities
       for the person_id corresponding to the
       assignment_id */

    cursor c_get_city is
     select distinct pcty.jurisdiction_code pcty
     from   pay_us_emp_city_tax_rules_f pcty,
            per_assignments_f paf1,
            per_assignments_f paf
     where  paf.assignment_id = asgid
     and    paf.effective_end_date >= l_year_start
     and    paf.effective_start_date <= l_year_end
     and    paf1.person_id = paf.person_id
     and    paf1.effective_end_date >= l_year_start
     and    paf1.effective_start_date <= l_year_end
     and    pcty.assignment_id = paf1.assignment_id
     and    pcty.effective_start_date <= l_year_end
     and    pcty.effective_end_date >= l_year_start
     and    pcty.jurisdiction_code in ('33-005-2010',
                                       '33-047-2010',
                                       '33-061-2010',
                                       '33-081-2010',
                                       '33-085-2010',
                                       '33-119-3230');
/* End Bug 976472 */

     /* Added by Ashu on 07-FEB-2000 to archive the Wage Plan Codes.
        A_SCL_US_ASG_CA_WAGE_PLAN_CODE is no longer present in
        ICESA_SUPPLEMENTAL formula. Therefore archiver will not archive this
        database item. The following cursor is executed when the category is
        RTM in case of California. Enhancement Req 1063413 */


--      CURSOR c_archive_wage_plan_code_rtm IS
--         SELECT DISTINCT aei_information3     ,
--                         paf1.assignment_id
--         FROM   per_assignment_extra_info paei,
--                pay_us_asg_reporting      puar,
--                pay_us_states             pus ,
--                per_assignments_f         paf1,
--                per_assignments_f         paf
--         WHERE  paf.assignment_id   = asgid
--         AND    date_earned BETWEEN paf.effective_start_date
--                                       AND paf.effective_end_date
--         AND    paf1.person_id             = paf.person_id
--         AND    paf1.effective_start_date <= l_quarter_end
--         AND    paf1.effective_end_date   >= l_quarter_start
--         AND    pus.state_abbrev           = g_sqwl_state
--         AND    puar.assignment_id         = paf1.assignment_id
--         AND    puar.tax_unit_id           = taxunitid
--         AND    substr(puar.jurisdiction_code,1,2) = pus.state_code
--         AND    paf1.assignment_id         = paei.assignment_id
--         AND    paei.aei_information1   = g_sqwl_state
--         AND    paei.information_type   = 'PAY_US_ASG_STATE_WAGE_PLAN_CD'
--         AND    EXISTS(
--                SELECT NULL
--                FROM   pay_payroll_actions    ppa1,
--                       pay_assignment_actions paa1,
--                       pay_us_asg_reporting   puar1
--                WHERE  paa1.assignment_id = paf1.assignment_id
--                AND    ppa1.payroll_action_id = paa1.payroll_action_id
--                AND    puar1.assignment_id    = paf1.assignment_id
--                AND    puar1.tax_unit_id      = puar.tax_unit_id
--                AND    ppa1.action_type in ('R', 'Q', 'V', 'B', 'I')
--                AND    ppa1.effective_date BETWEEN l_quarter_start
--                                           AND     l_quarter_end
--                                           AND     ppa1.effective_date BETWEEN
--                                                     paf1.effective_start_date
--                                                     AND paf1.effective_end_date
--              );
--
--
--
--   /* Added by Ashu on 10-FEB-2000 to archive the Wage Plan Codes.
--        A_SCL_US_ASG_CA_WAGE_PLAN_CODE is no longer present in
--        ICESA_SUPPLEMENTAL formula. Therefore archiver will not archive this
--        database item. The following cursor is executed when the category is
--        RTS in case of California. The need to have external join is to make
--        sure that the people with No Wage Plan Code have record in
--        ff_archive_tems table. This way these persons will be selected in
--        sqwl_employee_s cursor . Enhancement Req 1063413 */
--
--
--     CURSOR c_archive_wage_plan_code_rts IS
--         SELECT DISTINCT aei_information3     ,
--                         paf1.assignment_id
--         FROM   per_assignment_extra_info paei,
--                pay_us_asg_reporting      puar,
--                pay_us_states             pus ,
--                per_assignments_f         paf1,
--                per_assignments_f         paf
--         WHERE  paf.assignment_id   = asgid
--         AND    date_earned BETWEEN paf.effective_start_date
--                                       AND paf.effective_end_date
--         AND    paf1.person_id             = paf.person_id
--         AND    paf1.effective_start_date <= l_quarter_end
--         AND    paf1.effective_end_date   >= l_quarter_start
--         AND    pus.state_abbrev           = g_sqwl_state
--         AND    puar.assignment_id         = paf1.assignment_id
--         AND    puar.tax_unit_id           = taxunitid
--         AND    substr(puar.jurisdiction_code,1,2) = pus.state_code
--         AND    paf1.assignment_id         = paei.assignment_id(+)
--         AND    paei.aei_information1(+)   = g_sqwl_state
--         AND    paei.information_type(+)   = 'PAY_US_ASG_STATE_WAGE_PLAN_CD'
--         AND    EXISTS(
--                SELECT NULL
--                FROM   pay_payroll_actions    ppa1,
--                       pay_assignment_actions paa1,
--                       pay_us_asg_reporting   puar1
--                WHERE  paa1.assignment_id     = paf1.assignment_id
--                AND    ppa1.payroll_action_id = paa1.payroll_action_id
--                AND    puar1.assignment_id    = paf1.assignment_id
--                AND    puar1.tax_unit_id      = puar.tax_unit_id
--                AND    ppa1.action_type in ('R', 'Q', 'V', 'B', 'I')
--                AND    ppa1.effective_date BETWEEN l_quarter_start
--                                           AND     l_quarter_end
--                                           AND     ppa1.effective_date BETWEEN
--                                                      paf1.effective_start_date
--                                                   AND  paf1.effective_end_date
--              );



/*
   Due to the performance issues raised by Internal/In-House the above two
   cursors have been replaced with the following by  tmehra 18-OCT-2001
*/

     CURSOR c_archive_wage_plan_code IS
         SELECT DISTINCT aei_information3
         FROM   per_assignment_extra_info paei
         WHERE  paei.assignment_id       = asgid
         AND    paei.aei_information1    = g_sqwl_state
         AND    paei.information_type    = 'PAY_US_ASG_STATE_WAGE_PLAN_CD';

-- The following cursor was added by tmehra on 07-MAY-2003
-- This cursor get the default Wage Plan defined at the GRE level
-- if the Asg level Wage Plan is missing.


    CURSOR c_gre_wage_plan_code IS
    SELECT  hoi.org_information3 wage_plan
       FROM  hr_organization_information hoi
      WHERE  hoi.org_information_context = 'PAY_US_STATE_WAGE_PLAN_INFO'
        AND  hoi.organization_id    = taxunitid
        AND  hoi.org_information1   = g_sqwl_state
        AND  hoi.org_information4   = 'Y';

   /* Get the latest assignment for the given assisignment_id ,person_id */
/* Commented out and modified query for improving  performance (bug 6774422)
  CURSOR c_get_latest_asg(p_assignment_id number ) IS
            select paa.assignment_action_id,
                   ppa.effective_date
              from pay_assignment_actions     paa,
                   per_all_assignments_f      paf,
                   pay_payroll_actions        ppa,
                   pay_action_classifications pac,
                   per_all_assignments_f      paf1
             where paf1.assignment_id = p_assignment_id
               and paf.person_id     = paf1.person_id
               and paa.assignment_id = paf.assignment_id
               and paa.tax_unit_id   = taxunitid
               and paa.payroll_action_id = ppa.payroll_action_id
               and ppa.action_type = pac.action_type
               and pac.classification_name = 'SEQUENCED'
               and ppa.effective_date between paf.effective_start_date
                                           and paf.effective_end_date
               and ppa.effective_date between l_period_start and
                                               l_period_end
               and ((nvl(paa.run_type_id, ppa.run_type_id) is null
               and  paa.source_action_id is null)
                or (nvl(paa.run_type_id, ppa.run_type_id) is not null
               and paa.source_action_id is not null )
               or (ppa.action_type = 'V' and ppa.run_type_id is null
                    and paa.run_type_id is not null
                    and paa.source_action_id is null))
               order by paa.action_sequence desc;

*/

 /* This is the modified new cursor (bug 6774422)**/
 CURSOR c_get_latest_asg(p_assignment_id number ) IS
            SELECT /*+ORDERED*/
	            PAA.ASSIGNMENT_ACTION_ID,
	            PPA.EFFECTIVE_DATE
	    FROM    PER_ALL_ASSIGNMENTS_F PAF1,
	            PER_ALL_ASSIGNMENTS_F PAF ,
	            PAY_ASSIGNMENT_ACTIONS PAA,
	            PAY_PAYROLL_ACTIONS PPA   ,
	            PAY_ACTION_CLASSIFICATIONS PAC
	    WHERE   PAF1.ASSIGNMENT_ID      = p_assignment_id
	        AND PAF.PERSON_ID           = PAF1.PERSON_ID
	        AND PAA.ASSIGNMENT_ID       = PAF.ASSIGNMENT_ID
	        AND PAA.TAX_UNIT_ID         = taxunitid
	        AND PAA.PAYROLL_ACTION_ID   = PPA.PAYROLL_ACTION_ID
	        AND PPA.ACTION_TYPE         = PAC.ACTION_TYPE
	        AND PAC.CLASSIFICATION_NAME = 'SEQUENCED'
	        AND PPA.EFFECTIVE_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
	        AND PPA.EFFECTIVE_DATE BETWEEN l_period_start AND l_period_end
	        AND ((NVL(PAA.RUN_TYPE_ID, PPA.RUN_TYPE_ID) IS NULL
	        AND PAA.SOURCE_ACTION_ID                    IS NULL)
	         OR (NVL(PAA.RUN_TYPE_ID, PPA.RUN_TYPE_ID)  IS NOT NULL
	        AND PAA.SOURCE_ACTION_ID                    IS NOT NULL )
	         OR (PPA.ACTION_TYPE                         = 'V'
	        AND PPA.RUN_TYPE_ID                         IS NULL
	        AND PAA.RUN_TYPE_ID                         IS NOT NULL
	        AND PAA.SOURCE_ACTION_ID                    IS NULL))
	   ORDER BY PAA.ACTION_SEQUENCE DESC;

/*Modified for Florida SQWL Bug#9356178*/
/*For Florida SQWL starting from Q1 2010, the filing authority is validating the employee
balances and is expecting the credit to be given for Out of State SUI taxable wages of the
employee in Florida Taxable.But since the same requirement is not mandatory in taxation,
the Florida Taxable is adjusted and the value is archived with the dbi
SUI_ER_FL_ADJ_TAXABLE_PER_JD_GRE_QTD and this new value is used in SQWL reporting*/

CURSOR get_defined_balance_id  IS
  select pdb.defined_balance_id,pbd.dimension_name
    from pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
   where pbt.legislation_code = 'US'
     and pbt.balance_name = 'SUI ER Taxable'
     and pbd.dimension_name in ('Person in JD within GRE Quarter to Date',
                                'Person in JD within GRE Year to Date',
                                'Person within Government Reporting Entity Year to Date')
     and pbd.legislation_code = 'US'
     and pdb.balance_type_id = pbt.balance_type_id
     and pdb.balance_dimension_id = pbd.balance_dimension_id;

/*Modified to ensure correct behavior for all kinds of
assignments.The earlier cursor had date checks which were
not correct and also it gave duplicate results which can
lead to wrong sum being calculated Correct this in below cursor*/

CURSOR get_previous_fl_taxable  IS
select sum(to_number(nvl(value,'0')))
from ff_archive_items ffai,
     pay_assignment_actions paa,
     pay_payroll_actions ppa
where ffai.user_entity_id = l_user_entity_id
  and ffai.context1=to_char(paa.assignment_action_id)
  and paa.tax_unit_id = taxunitid
  and paa.payroll_action_id = ppa.payroll_action_id
  and ppa.report_type = 'SQWL'
  and ppa.report_qualifier = 'FL'
  and ppa.action_type = 'X'
  and trunc(ppa.effective_date,'YEAR') = trunc(p_effective_date,'YEAR')
  and ppa.effective_date < p_effective_date
  and paa.assignment_id in
  (select distinct paaf2.assignment_id
   from   per_all_assignments_f paaf1,
          per_all_assignments_f paaf2
   where  paaf1.assignment_id = asgid
     and  paaf1.person_id = paaf2.person_id
     and  paaf2.effective_start_date <= p_effective_date);

/* Added for Bug#9561700*/

/*Since we are using the Date Based approach to fetch the Balances
of the assignment, we need to ensure that on the Date we pass for the
assignment, the Assignment record is present.Incase, the employee
is terminated, we need to pass the last effective date applicable to the
assignment to fetch the balances.This we do by referring to the pay_payroll_actions
table to find the maximum effective_date of this person in this Quarter.*/

CURSOR get_effective_date (p_quarter_start_date DATE,
                           p_quarter_end_date DATE) IS
select max(ppa.effective_date)
  from per_all_assignments_f   asg,
       pay_assignment_actions  paa,
       pay_payroll_actions     ppa
 where ppa.effective_date between p_quarter_start_date
                              and p_quarter_end_date
   and ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
   and paa.payroll_action_id = ppa.payroll_action_id
   and paa.assignment_id = asg.assignment_id
   and paa.action_status <> 'S'
   and asg.effective_end_date   >= p_quarter_start_date
   and asg.effective_start_date <= p_quarter_end_date
   and asg.business_group_id = ppa.business_group_id
   and paa.tax_unit_id = taxunitid
   and asg.assignment_id = asgid;
/* End Bug#9561700*/

l_def_bal_id pay_defined_balances.defined_balance_id%TYPE;
l_dimension_name pay_balance_dimensions.dimension_name%TYPE;

l_sui_fl_taxable_qtd number;
l_sui_fl_taxable_ytd number;
l_sui_taxable_ytd number;
l_outstate_sui_taxable_ytd number;
l_previous_fl_taxable number;
l_fl_sui_er_limit number;
l_context_id_tax_unit_id number;
l_context_id_jurisdiction_code number;
l_archive_item_id number;
fl_jurisdiction_code varchar2(11);
l_effective_date date;
l_effective_end_date date;

/* End Bug#9356178*/

  begin
      hr_utility.set_location ('archive_data',1);

      SELECT aa.assignment_id,
            pay_magtape_generic.date_earned (p_effective_date,aa.assignment_id),
            aa.tax_unit_id,
            aa.chunk_number,             /* Bug 773937 */
            aa.payroll_action_id         /* Bug 773937 */
            into asgid,
                 date_earned,
                 taxunitid,
                 l_chunk,                /* Bug 773937 */
                 l_payroll_action_id     /* Bug 773937 */
        FROM pay_assignment_actions aa
        WHERE aa.assignment_action_id = p_assactid;

/*
   The following code was added on 08-FEB-2000 by Ashu Gupta (ashgupta) to
   take care of archiving of Wage Plan Codes in California
*/

    IF (g_sqwl_state = 'FL') THEN

     hr_utility.trace('Adjusting the Florida Taxable');

     l_user_entity_id :=get_user_entity_id('SUI_ER_FL_ADJ_TAXABLE_PER_JD_GRE_QTD');

     fl_jurisdiction_code := '10-000-0000';

     pay_balance_pkg.set_context('TAX_UNIT_ID',taxunitid);

     pay_balance_pkg.set_context('JURISDICTION_CODE',fl_jurisdiction_code);

     /* Modified for Bug#9561700*/
     /* First find out if the Assignment record is ending in between the Quarter.If
        it is not, then call the balance procedure with Quarter End Date.If the Assignment
        record ends in between the Quarter, we need to use find the maximum effective
        date for the assignment from payroll actions and use it in balance calls.*/

     SELECT least(max(effective_end_date),p_effective_date)
     INTO   l_effective_end_date
     FROM   per_all_assignments_f
     WHERE  assignment_id = asgid
     AND    assignment_type = 'E'
     AND    effective_end_date >= add_months(last_day(p_effective_date),-3)+1 ; /*Quarter Start Date */

     IF l_effective_end_date < p_effective_date

     THEN

     open get_effective_date(add_months(last_day(p_effective_date),-3)+1,last_day(p_effective_date));
     fetch get_effective_date into l_effective_date;
     close get_effective_date;

      hr_utility.trace('Modified l_effective_date'||to_char(l_effective_date));

     ELSE

     l_effective_date := p_effective_date;

     hr_utility.trace('Use original l_effective_date'||to_char(l_effective_date));

     END IF;

     /* End Bug#9561700*/

     open get_defined_balance_id;
     fetch get_defined_balance_id into l_def_bal_id,l_dimension_name;

     while get_defined_balance_id%FOUND
     loop

       if l_dimension_name = 'Person in JD within GRE Quarter to Date' then



               l_sui_fl_taxable_qtd := pay_balance_pkg.get_value( l_def_bal_id,
                                                                  asgid,
                                                                  l_effective_date);

        hr_utility.trace('l_sui_fl_taxable_qtd'||l_sui_fl_taxable_qtd);


       elsif l_dimension_name = 'Person in JD within GRE Year to Date' then


               l_sui_fl_taxable_ytd := pay_balance_pkg.get_value( l_def_bal_id,
                                                                  asgid,
                                                                  l_effective_date);

        hr_utility.trace('l_sui_fl_taxable_ytd'||l_sui_fl_taxable_ytd);


       else

               l_sui_taxable_ytd := pay_balance_pkg.get_value( l_def_bal_id,
                                                               asgid,
                                                               l_effective_date);

        hr_utility.trace('l_sui_taxable_ytd'||l_sui_taxable_ytd);

       end if;

       fetch get_defined_balance_id into l_def_bal_id,l_dimension_name;

     end loop;

     close get_defined_balance_id;

        l_outstate_sui_taxable_ytd := l_sui_taxable_ytd - l_sui_fl_taxable_ytd;

        hr_utility.trace('l_outstate_sui_taxable_ytd'||l_outstate_sui_taxable_ytd);

        l_fl_sui_er_limit := hr_us_ff_udf1.get_jit_data ( fl_jurisdiction_code,p_effective_date,'SUI_ER_WAGE_LIMIT');

        hr_utility.trace('l_fl_sui_er_limit'||l_fl_sui_er_limit);

	if l_outstate_sui_taxable_ytd >= l_fl_sui_er_limit
	then

             l_sui_fl_taxable_qtd := 0;

	   hr_utility.trace('l_outstate_sui_taxable_ytd greater than l_fl_sui_er_limit');

        else


	     open get_previous_fl_taxable;

	     fetch get_previous_fl_taxable into l_previous_fl_taxable;

             if l_previous_fl_taxable is NULL then

	      l_previous_fl_taxable := 0;

             end if;

	     close get_previous_fl_taxable;

	     if l_outstate_sui_taxable_ytd + l_previous_fl_taxable >= l_fl_sui_er_limit
	     then

             l_sui_fl_taxable_qtd := 0;

             hr_utility.trace('l_outstate_sui_taxable_ytd and l_previous_fl_taxable greater than l_fl_sui_er_limit');

	     else

	     l_sui_fl_taxable_qtd := least(l_sui_fl_taxable_qtd,l_fl_sui_er_limit - l_outstate_sui_taxable_ytd - l_previous_fl_taxable);

	     end if;

	end if;


       hr_utility.trace('l_sui_fl_taxable_qtd after adjustment is'||l_sui_fl_taxable_qtd);

           INSERT INTO ff_archive_items (archive_item_id,
                                         user_entity_id,
                                         context1,
                                         value)
           VALUES( ff_archive_items_s.NEXTVAL ,
                   l_user_entity_id           ,
                   p_assactid                 ,
                   l_sui_fl_taxable_qtd           );

        hr_utility.trace('Archived the adjusted FL Taxable');

        SELECT context_id
        INTO   l_context_id_tax_unit_id
        FROM   ff_contexts
        WHERE  context_name = 'TAX_UNIT_ID';

	INSERT INTO ff_archive_item_contexts
	(archive_item_id,sequence_no,context,context_id)
	VALUES (ff_archive_items_s.CURRVAL,1,taxunitid,l_context_id_tax_unit_id);

        SELECT context_id
        INTO   l_context_id_jurisdiction_code
        FROM   ff_contexts
        WHERE  context_name = 'JURISDICTION_CODE';

	INSERT INTO ff_archive_item_contexts
	(archive_item_id,sequence_no,context,context_id)
	VALUES (ff_archive_items_s.CURRVAL,1,fl_jurisdiction_code,l_context_id_jurisdiction_code);

    ELSIF (g_sqwl_state = 'CA') THEN

        l_user_entity_id :=get_user_entity_id('A_SCL_ASG_US_CA_WAGE_PLAN_CODE');
        l_quarter_start  := TRUNC(p_effective_date, 'Q');
        l_quarter_end    := ADD_MONTHS(TRUNC(p_effective_date, 'Q'),3) - 1;

        SELECT context_id
        INTO   l_context_id_assignment_id
        FROM   ff_contexts
        WHERE  context_name = 'ASSIGNMENT_ID';

   /* l_user_entity_id, l_context_id_date_earned, l_context_id_assignment_id,
      can be declared as global variables, then there will be no need
      to select their values every time. This will improve performance */
--
--       IF (g_report_cat = 'RTM') THEN
--            OPEN c_archive_wage_plan_code_rtm;
--        ELSIF (g_report_cat = 'RTS') THEN
--            OPEN c_archive_wage_plan_code_rts;
--        END IF;
--
--        LOOP
--            hr_utility.trace('In Archive Wage Plan Code RTM loop ');
--
--            IF (g_report_cat = 'RTM') THEN
--                FETCH c_archive_wage_plan_code_rtm INTO l_wage_plan_code,
--                                                        l_assignment_id ;
--                EXIT WHEN c_archive_wage_plan_code_rtm%NOTFOUND;
--            ELSIF (g_report_cat = 'RTS') THEN
--                FETCH c_archive_wage_plan_code_rts INTO l_wage_plan_code,
--                                                        l_assignment_id ;
--                EXIT WHEN c_archive_wage_plan_code_rts%NOTFOUND;
--            END IF;
--
--
--            INSERT INTO ff_archive_items (archive_item_id,
--                                          user_entity_id,
--                                          context1,
--                                          value)
--            VALUES( ff_archive_items_s.NEXTVAL ,
--                    l_user_entity_id           ,
--                    p_assactid                 ,
--                    l_wage_plan_code           );
--
--
--            INSERT INTO ff_archive_item_contexts (archive_item_id,
--                                                  sequence_no    ,
--                                                  context        ,
--                                                  context_id     )
--            VALUES (ff_archive_items_s.currval,
--                    1                         ,
--                    l_assignment_id           ,
--                    l_context_id_assignment_id);
--        END LOOP;
--        IF (g_report_cat = 'RTM') THEN
--            CLOSE c_archive_wage_plan_code_rtm;
--        ELSIF (g_report_cat = 'RTS') THEN
--            CLOSE c_archive_wage_plan_code_rts;
--        END IF;



/* Due to the performance issues raised by Internal the above code has been replaced
   by tmehra 18-OCT-2001*/

        l_wage_plan_ct := 0;

        FOR c_rec in c_archive_wage_plan_code
        LOOP

           hr_utility.trace('In Archive Wage Plan Code loop ');

           l_wage_plan_code := c_rec.aei_information3;

           INSERT INTO ff_archive_items (archive_item_id,
                                         user_entity_id,
                                         context1,
                                         value)
           VALUES( ff_archive_items_s.NEXTVAL ,
                   l_user_entity_id           ,
                   p_assactid                 ,
                   l_wage_plan_code           );

           INSERT INTO ff_archive_item_contexts (archive_item_id,
                                                 sequence_no    ,
                                                 context        ,
                                                 context_id     )
           VALUES (ff_archive_items_s.currval,
                   1                         ,
                   asgid                     ,
                   l_context_id_assignment_id);

           l_wage_plan_ct := l_wage_plan_ct + 1;

        END LOOP;

        IF l_wage_plan_ct = 0 THEN

          FOR c_rec in c_gre_wage_plan_code
          LOOP

           hr_utility.trace('In Archive GRE Wage Plan Code loop ');

           l_wage_plan_code := c_rec.wage_plan;

          END LOOP;



           INSERT INTO ff_archive_items (archive_item_id,
                                         user_entity_id,
                                         context1,
                                         value)
           VALUES( ff_archive_items_s.NEXTVAL ,
                   l_user_entity_id           ,
                   p_assactid                 ,
                   l_wage_plan_code           );

           INSERT INTO ff_archive_item_contexts (archive_item_id,
                                                 sequence_no    ,
                                                 context        ,
                                                 context_id     )
           VALUES (ff_archive_items_s.currval,
                   1                         ,
                   asgid                     ,
                   l_context_id_assignment_id);

        END IF;

    END IF;



      hr_utility.set_location ('archive_data',2);
/*  Bug 773937 */
        /* If the chunk of the assignment is same as the minimun chunk
           for the payroll_action_id and the gre data has not yet been
           archived then archive the gre data i.e. the employer data */

        if l_chunk = g_min_chunk and g_archive_flag = 'N' then
           hr_utility.trace('archive_data archiving employer data');
           archive_gre_data(p_payroll_action_id => l_payroll_action_id,
                            p_tax_unit_id       => taxunitid);
            hr_utility.trace('archive_data archiving employer data');
        end if;
/* End of Bug 773937 */

      /* Setup contexts */

      pay_balance_pkg.set_context ('ASSIGNMENT_ID', asgid);
      pay_balance_pkg.set_context ('DATE_EARNED',fnd_date.date_to_canonical(date_earned));
/*      pay_balance_pkg.set_context ('DATE_EARNED',fnd_date.date_to_canonical(date_earned,'DD-MON-YYYY')); date format not required */
      pay_balance_pkg.set_context ('TAX_UNIT_ID', taxunitid);

      /* Get the year begin and year end dates */

      l_year_start := trunc(p_effective_date, 'Y');
      l_year_end   := add_months(trunc(p_effective_date, 'Y'),12) - 1;

/* Bug 976472 */
      if g_sqwl_state = 'NY' then

        /* Initialise the global PL/SQL table */

        for i in 1..l_context_no loop

          pay_archive.g_context_values.name(i) := NULL;
          pay_archive.g_context_values.value(i) := NULL;

        end loop;


        /* Get the New York burroughs and the Yonker City if the
           employee has tax records for them */

        open c_get_city;
        loop

          hr_utility.trace('In city loop ');

          fetch c_get_city into l_jurisdiction;
          exit when c_get_city%NOTFOUND;

          l_count := l_count + 1;
          pay_archive.g_context_values.name(l_count) := 'JURISDICTION_CODE';
          pay_archive.g_context_values.value(l_count) := l_jurisdiction;

        end loop;
        close c_get_city;

        If l_count = 0 then
           l_count := l_count + 1;
           pay_archive.g_context_values.name(l_count) := 'JURISDICTION_CODE';
           pay_archive.g_context_values.value(l_count) :=  g_sqwl_jursd;
        end if;
        pay_archive.g_context_values.sz := l_count;

      end if;
/* End Bug 976472 */

      /* To get person level balances you must use the highest assignment action
         of the last paid assignment */
/* Modifying to select effective_date from pay_payroll_actions corrsponding to
   the assignment action selected to solve th e new York SQWL 4th quarter problem */

--Bug 3331021 : Remove Query with  Rule hint and added cursor c_get_latest_asg


        /* Get the effective_date and start_date of the payroll_Action_id */

           select effective_date,
                  start_date
            into  l_period_end,
                  l_period_start
            from  pay_payroll_actions
           where  payroll_action_id = l_payroll_action_id;


          begin
            open c_get_latest_asg(asgid );
                 fetch c_get_latest_asg into aaid,eff_date;
            hr_utility.trace('aaid in action creation code'||to_char(aaid));
            close c_get_latest_asg;

          exception
             when no_data_found then
                  aaid := -9999;
                  raise_application_error(-20001,'Balance Assignment Action does not exist for : '||to_char(asgid));
          end;

/* Updating the serial Number column of pay_assignment_actions with 1 if
   the effective_date of the assignment action id is lying in the
   fourth quarter. */

   if g_sqwl_state = 'NY' and to_char(p_effective_date,'MM-DD') = '12-31'
   THEN
      if(eff_date < trunc(p_effective_date,'Q'))
      THEN
          update pay_assignment_actions paa
          set serial_number = 1
          where paa.assignment_action_id = p_assactid;
      END IF;
   END IF;
      pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID',aaid);
      pay_archive.balance_aa := aaid;

  exception
  when others then
  hr_utility.trace('Problem in archive_data');

  end archive_data;

 /* Name    : update_ff_archive_items
  Purpose   : Given the SQWL payroll_action_id, identifies SQWL assignment actions for which
              serial number is set to 1 (those employee assgnment actions who doesnt have balances
              in the 4th Qtr while running 4th qtr new york SQWL report ) and update QTD balances
              to zero for the assignment action in ff_archive_items.
  Arguments : SQWL Payroll Action ID
 */

/* added A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD and A_SIT_PRE_TAX_REDNS_PER_JD_GRE_QTD
   for bug 1494215 of NY Q4 */

   FUNCTION Update_ff_archive_items (p_payroll_action_id in VARCHAR2)
   return varchar is
   BEGIN
      update ff_archive_items ffai
      set ffai.value = 0
      where ffai.user_entity_id in (
                        select user_entity_id
                        from   ff_database_items
                        where  user_name in ('A_SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD',
                                             'A_SUI_ER_SUBJ_NWHABLE_PER_JD_GRE_QTD',
                                             'A_SUI_ER_125_REDNS_PER_JD_GRE_QTD',
                                             'A_SUI_ER_401_REDNS_PER_JD_GRE_QTD',
                                             'A_SUI_ER_DEP_CARE_REDNS_PER_JD_GRE_QTD',
                                             'A_SUI_ER_TAXABLE_PER_JD_GRE_QTD',
                                             'A_SIT_SUBJ_WHABLE_PER_JD_GRE_QTD',
                                             'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_QTD',
                                             'A_SIT_125_REDNS_PER_JD_GRE_QTD',
                                             'A_SIT_401_REDNS_PER_JD_GRE_QTD',
                                             'A_SIT_DEP_CARE_REDNS_PER_JD_GRE_QTD',
                                             'A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD',
                                             'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_QTD',
                                             'A_SIT_WITHHELD_PER_JD_GRE_QTD')
                           )
      and   ffai.context1 in (
                        select paa.assignment_action_id
                        from   pay_assignment_actions paa,
                               pay_payroll_actions ppa
                        where  ppa.payroll_action_id = paa.payroll_action_id
                        and    ppa.report_type = 'SQWL'
                        and    ppa.report_qualifier = 'NY'
                        and    ppa.payroll_action_id = to_number(p_payroll_action_id)
                        and    paa.serial_number = 1
                       );
     commit;
     return 'Y';

   EXCEPTION
      when OTHERS then
        hr_utility.trace('Error while updating ff_archive_items ');
        return 'N';
   END Update_ff_archive_items;


--Name
--  preprocess_check
--Purpose
--  This function checks if
--      In case of RTS :  No person has got more than one wage plan code. Any
--                        of his/her assignments shpuld be having more than one
--                        wage plan code. If the two assignments for the same
--                        person has different wage plan codes, then also it is
--                        an error.
--     In RTM         : No person should be having a null wage plan code.
--                      In both the cases, only those assignments are taken
--                      into consideration that were paid in the period
--                      concerned. Added as a part of Enhancement Req 1063413
---------------------------------------------------------------------------
FUNCTION preprocess_check
(
    l_pactid                        NUMBER  ,
    l_period_start                  DATE    ,
    l_period_end                    DATE    ,
    l_bus_group_id                  pay_payroll_actions.business_group_id%type,
    l_state                         VARCHAR2,
    l_report_cat                    VARCHAR2
)
RETURN BOOLEAN IS

CURSOR c_chk_asg_wp IS
SELECT count(*) ct
  FROM per_assignments_f paf,
       per_assignment_extra_info paei
 WHERE paf.business_group_id         = l_bus_group_id
   AND paf.effective_end_date       >= l_period_start
   AND paf.effective_start_date     <= l_period_end
   AND paei.information_type         = 'PAY_US_ASG_STATE_WAGE_PLAN_CD'
   AND paei.aei_information1         = l_state /* Added for performance improvement Bug# 4344959 */
   AND paei.assignment_id            = paf.assignment_id
   AND NOT EXISTS (SELECT null
                    FROM hr_organization_information orgi,
                         hr_soft_coding_keyflex sft
                   WHERE orgi.organization_id          = to_number(sft.segment1)
                     AND sft.soft_coding_keyflex_id    = paf.soft_coding_keyflex_id
                     AND orgi.org_information1         = paei.aei_information1
                     AND (orgi.org_information2        = paei.aei_information2
                           OR paei.aei_information2 IS NULL)
                     AND orgi.org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO'
                     AND orgi.org_information3         = paei.aei_information3);



CURSOR c_chk_gre_wp IS
SELECT count(*) ct
  FROM hr_legal_entities org
 WHERE org.business_group_id   = l_bus_group_id
   AND EXISTS (SELECT null
                        FROM  hr_organization_information orgi
                       WHERE  organization_id          = org.organization_id
                         AND  org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO'
                         AND  org_information1         = 'CA')
   AND NOT EXISTS (   SELECT null
                        FROM  hr_organization_information orgi
                       WHERE  organization_id          = org.organization_id
                         AND  org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO'
                         AND  org_information1         = 'CA'
                         AND  org_information4         = 'Y');

CURSOR c_dup_orgn_info IS
SELECT count(*) ct
  FROM hr_legal_entities org,
       (select distinct
              a.organization_id,
              a.org_information1,
              a.org_information3
        FROM  hr_organization_information a
       WHERE  org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO') b
 WHERE org.business_group_id   = l_bus_group_id
   AND b.organization_id       = org.organization_id
   AND 1 < (   SELECT count(*)
                        FROM  hr_organization_information orgi
                       WHERE  organization_id          = org.organization_id
                         AND  org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO'
                         AND  org_information1         = b.org_information1
                         AND  org_information3         = b.org_information3);


    l_flag            VARCHAR2(4)                                      ;
    l_wage_plan_code  hr_organization_information.org_information3%TYPE;
    l_company_sui_id  hr_organization_information.org_information2%TYPE;
    l_counter         NUMBER := 0                                      ;
    l_distinct_wage_plan_code NUMBER := 0                              ;


BEGIN
    hr_utility.set_location('pay_us_sqwl_archive.preprocess_check', 10);

    IF (l_report_cat = 'RTM') THEN

            l_counter := 0;

            FOR c_rec IN c_dup_orgn_info
            LOOP

             l_counter := c_rec.ct;

            END LOOP;

            IF (l_counter > 0) THEN
                hr_utility.set_location('pay_us_sqwl_archive.preprocess_check', 30);
                hr_utility.set_message(801, 'PAY_7024_USERTAB_BAD_ROW_VALUE');
                hr_utility.set_message_token('FORMAT', '> 1 row in hoi for wg plcd');
                hr_utility.raise_error;
            END IF;
    END IF;

    IF (l_report_cat = 'RTM') THEN

        l_counter := 0;

        FOR c_rec IN c_chk_gre_wp
        LOOP

          l_counter := c_rec.ct;

        END LOOP;

        IF l_counter > 0 THEN
            hr_utility.set_location('pay_us_sqwl_archive.preprocess_check', 40);
            hr_utility.set_message(801, 'PAY_7024_USERTAB_BAD_ROW_VALUE');
            hr_utility.set_message_token('FORMAT',' Default Wage Plan not marked');
            hr_utility.raise_error;
        END IF;

        l_counter := 0;

        FOR c_rec IN c_chk_asg_wp
        LOOP

          l_counter := c_rec.ct;

        END LOOP;

        IF l_counter > 0 THEN
            hr_utility.set_location('pay_us_sqwl_archive.preprocess_check', 50);
            hr_utility.set_message(801, 'PAY_7024_USERTAB_BAD_ROW_VALUE');
            hr_utility.set_message_token('FORMAT',' wage plan not defined at GRE');
            hr_utility.raise_error;
        END IF;

    END IF;
    RETURN TRUE;
END preprocess_check;

  /* Name      : archive_asg_locs
     Purpose   : This procedure will archive the assignment locations as of the 12
                 of each months during the sqwl quarter.
     Arguments :
     Notes     :
  */

PROCEDURE archive_asg_locs( p_asg_act_id       in number
                             ,p_pay_act_id       in number
                             ,p_asg_id           in number)
  IS

  CURSOR c_asg_loc_mon ( p_ass_act_id   number
                        ,p_mon_of_qtr   number) IS
     SELECT ASG.LOCATION_ID
     FROM  per_assignments_f       ASG
     ,     pay_assignment_actions  ASSACT
     ,     pay_payroll_actions     PACT
     WHERE  ASSACT.assignment_action_id = p_ass_act_id
     AND    ASSACT.payroll_action_id = PACT.payroll_action_id
     AND    ASSACT.assignment_id = ASG.assignment_id
     AND    add_months(trunc (PACT.effective_date, 'Q'), p_mon_of_qtr - 1) + 11
            BETWEEN ASG.effective_start_date
            AND     ASG.Effective_end_date;

  CURSOR c_asg_loc_mon2 ( p_ass_act_id   number
                        ,p_mon_of_qtr   number) IS
     SELECT ASG.LOCATION_ID
     FROM  per_assignments_f       ASG
     ,     pay_assignment_actions  ASSACT
     ,     pay_payroll_actions     PACT
     WHERE  ASSACT.assignment_action_id = p_ass_act_id
     AND    ASSACT.payroll_action_id = PACT.payroll_action_id
     AND    ASSACT.assignment_id = ASG.assignment_id
     AND   ( add_months(trunc (PACT.effective_date, 'Q'), p_mon_of_qtr - 1)
              BETWEEN ASG.effective_start_date
              AND     ASG.Effective_end_date
	    OR last_day(add_months(trunc (PACT.effective_date, 'Q'), p_mon_of_qtr - 1))
	     BETWEEN ASG.effective_start_date
              AND     ASG.Effective_end_date)
     ORDER BY ASG.effective_start_date desc ;

  l_location_id            per_all_assignments_f.location_id%type;
  l_user_entity_id         ff_user_entities.user_entity_id%type;
  l_archive_item_id        ff_archive_items.archive_item_id%type;
  l_object_version_number  ff_archive_items.object_version_number%type;
  l_some_warning           boolean;

  l_procedure              varchar2(16) := 'archive_asg_locs';


  CURSOR c_asg_loc_end (p_ass_acti_id  number) IS
  /*Commenting for bug 2510853
     SELECT paf.location_id
     FROM   per_assignments_f      paf,
            pay_assignment_actions paa,
            pay_payroll_actions    ppa
     WHERE (paa.assignment_action_id = p_ass_acti_id
     AND    paa.payroll_action_id    = ppa.payroll_action_id
     AND    paa.assignment_id        = paf.assignment_id
     AND    ppa.business_group_id    = paf.business_group_id
     AND    ppa.effective_date BETWEEN paf.effective_start_date
                               AND     paf.effective_end_date
           )
     OR    (paa.assignment_action_id = p_ass_acti_id
     AND    paa.payroll_action_id    = ppa.payroll_action_id
     AND    paa.assignment_id        = paf.assignment_id
     AND    ppa.business_group_id    = paf.business_group_id
     AND    paf.effective_end_date   =
              (SELECT max(paf1.effective_end_date)
               FROM   per_assignments_f paf1
               WHERE paf1.assignment_id = paf.assignment_id
               AND    paf1.effective_end_date BETWEEN ppa.start_date
                                              AND     ppa.effective_date
              )
           );
   */

     SELECT paf.location_id
     FROM   per_assignments_f      paf,
            pay_assignment_actions paa,
            pay_payroll_actions    ppa
     WHERE paa.assignment_action_id =    p_ass_acti_id
     AND    paa.payroll_action_id    = ppa.payroll_action_id
     AND    paa.assignment_id        = paf.assignment_id
  -- commenting the redundant join with business group id for bug 2809506
  --   AND    ppa.business_group_id    = paf.business_group_id
     AND   ((ppa.effective_date BETWEEN paf.effective_start_date
                               AND     paf.effective_end_date)
             OR
             (paf.effective_end_date   =
              (SELECT max(paf1.effective_end_date)
               FROM   per_assignments_f paf1
               WHERE paf1.assignment_id = paf.assignment_id
               AND    paf1.effective_end_date BETWEEN ppa.start_date
                                              AND     ppa.effective_date)
             )
            )
       order by paf.effective_end_date desc;

   BEGIN

        hr_utility.set_location('archive_asg_locs.' || l_procedure , 10);
        hr_utility.trace('p_asg_act_id = '||to_char(p_asg_act_id));
        hr_utility.trace('p_asg_id = '||to_char(p_asg_id));
        hr_utility.trace('p_pay_act_id = '||to_char(p_pay_act_id));


  FOR i IN 1 .. 3 LOOP
      OPEN c_asg_loc_mon(p_asg_act_id,
                           i);
      Fetch c_asg_loc_mon into l_location_id;

      IF c_asg_loc_mon%NOTFOUND THEN  /*7429594 */
         -- l_location_id := Null;
	 OPEN c_asg_loc_mon2(p_asg_act_id,
                              i);
          Fetch c_asg_loc_mon2 into l_location_id;
	  hr_utility.trace('Entered into c_asg_loc_mon2 cursor assignment id'||to_char(p_asg_act_id));
	  hr_utility.trace('Entered into c_asg_loc_mon2 cursor location_id '||to_char(l_location_id));
	  IF c_asg_loc_mon2%NOTFOUND THEN
          l_location_id := Null;
	  END IF;

         CLOSE c_asg_loc_mon2;
      END IF;

      CLOSE c_asg_loc_mon;

      IF l_location_id is not NULL THEN

      hr_utility.set_location('archive_asg_locs.' || l_procedure , 20);

        -- set the correct user_entity_id for the archive call
        BEGIN
            SELECT user_entity_id
            INTO   l_user_entity_id
            FROM   ff_user_entities
            WHERE  user_entity_name = 'A_SQWL_LOC_MON_' || to_char(i);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            hr_utility.trace('User entities SQWL_LOC_MON_* not define contact your system administrator');
            raise hr_utility.hr_error;
        END;

         hr_utility.set_location('archive_asg_locs.' || l_procedure , 30);

         -- Call the create archive item api procedure
         ff_archive_api.create_archive_item(
             p_archive_item_id => l_archive_item_id
            ,p_user_entity_id => l_user_entity_id
            ,p_archive_value  => l_location_id
            ,p_archive_type   => 'AAP'
            ,p_action_id      => p_asg_act_id
            ,p_legislation_code => 'US'
            ,p_object_version_number  => l_object_version_number
            ,p_some_warning           => l_some_warning
          );

       IF l_some_warning THEN
          hr_utility.trace('Error occurrecd when creating archive item ');
          raise hr_utility.hr_error;
       END IF;
     END IF;

  END LOOP;

  hr_utility.set_location('archive_asg_locs.' || l_procedure , 40);

  --  Process the location id for the end of the period.
  OPEN  c_asg_loc_end(p_asg_act_id);

  FETCH c_asg_loc_end INTO l_location_id;

  IF c_asg_loc_end%NOTFOUND THEN
      close c_asg_loc_end;
      hr_utility.trace('Error occurrecd when creating archive item ');
      hr_utility.trace('Error occurrecd : Assignment Location not found for p_asg_act_id ='|| to_char(p_asg_act_id));
      raise hr_utility.hr_error;
  END IF;
  close c_asg_loc_end;


        hr_utility.set_location('archive_asg_locs.' || l_procedure , 50);

        -- set the correct user_entity_id for the archive call
        BEGIN
            SELECT user_entity_id
            INTO   l_user_entity_id
            FROM   ff_user_entities
            WHERE  user_entity_name = 'A_SQWL_LOC_QTR_END';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            hr_utility.trace('User entities A_SQWL_LOC_END_QTR not define contact your system administrator');
            raise hr_utility.hr_error;
        END;

         hr_utility.set_location('archive_asg_locs.' || l_procedure , 60);

        -- Call the create archive item api procedure
         ff_archive_api.create_archive_item(
             p_archive_item_id => l_archive_item_id
            ,p_user_entity_id => l_user_entity_id
            ,p_archive_value  => l_location_id
            ,p_archive_type   => 'AAP'
            ,p_action_id      => p_asg_act_id
            ,p_legislation_code => 'US'
            ,p_object_version_number  => l_object_version_number
            ,p_some_warning           => l_some_warning
          );

       IF l_some_warning THEN
          hr_utility.trace('Error occurrecd when creating archive item ');
          hr_utility.trace('Error occurrecd when creating archive item for User entity A_SQWL_LOC_END_QTR');
          raise hr_utility.hr_error;
       END IF;

  EXCEPTION
    WHEN OTHERS THEN
          hr_utility.trace('Error occurrecd when creating archive item ');
	  hr_utility.trace('Error occurrecd when othersof archive_asg_locs ');
          raise hr_utility.hr_error;

 END archive_asg_locs;


  /* Name      : range_cursor
     Purpose   : This returns the select statement that is used to created the
                 range rows.
     Arguments :
     Notes     :
  */

  procedure range_cursor (pactid in number, sqlstr out nocopy  varchar2) is
  l_state             pay_payroll_actions.report_qualifier%type;
  l_report_cat        pay_payroll_actions.report_category%type;
  l_effective_date    pay_payroll_actions.effective_date%type;
  l_start_date        pay_payroll_actions.start_date%type;
  l_business_group_id pay_payroll_actions.business_group_id%type;

  /* Bug  773937 */
  l_tax_unit_id        number;
  l_archive            boolean:= FALSE;

  l_from               number;
  l_to                 number;
  l_length             number;
  l_w2_reporting_rules_exist number;

  /* Local variables used for checking W2 Reporting Rules */
   message_text         VARCHAR2(32000):= null;
   message_preprocess   VARCHAR2(2000) := null;


  /* End of  Bug  773937 */

-- The l_preprocess_flag variable was added by Ashu Gupta (ashgupta)
-- on 08-FEB-2000 to check if any person has an invalid wage plan code

  l_preprocess_flag   BOOLEAN := FALSE;

  cursor c_reporting_rules(cp_tax_unit_id in number) is
  select '1' from hr_organization_information
   where organization_id = cp_tax_unit_id
     and org_information_context = 'W2 Reporting Rules';
  begin

	 SELECT report_qualifier,
		report_category,
                effective_date,
                start_date,
                business_group_id
	 INTO   l_state,
		l_report_cat,
                l_effective_date,
                l_start_date,
                l_business_group_id
         FROM   pay_payroll_actions
	 WHERE  payroll_action_id = pactid;

   hr_utility.trace('Selected from pay_payroll_actions ');

/* Bug 1220213 */
  /* If New York state and last quarter SQWL, then the date range is full year */
  if ( l_state = 'NY' and to_char(l_effective_date,'DD-MON') = '31-DEC' ) then
     l_start_date := trunc(l_start_date,'YYYY');
  end if;
/* End of Bug 1220213 */

     if (l_state = 'LA' and l_report_cat = 'RTLAQ') then
       sqwl_range := 'SELECT distinct ASG.person_id
          FROM   hr_organization_information HOI,
                 per_assignments_f           ASG,
                 pay_us_asg_reporting        puar,
                 pay_state_rules             SR
          WHERE  SR.state_code            = ''' || l_state || '''
            AND  puar.jurisdiction_code like substr(SR.jurisdiction_code  ,1,2)||''%''
            AND  ASG.assignment_id           = puar.assignment_id
            AND  ASG.assignment_type         = ''E''
            AND  ASG.effective_start_date   <= ''' || l_effective_date || '''
            AND  ASG.effective_end_date     >= ''' || l_start_date || '''
            AND  ASG.business_group_id + 0   = ''' || l_business_group_id || '''
	    AND  HOI.organization_id = puar.tax_unit_id
	    AND  HOI.ORG_INFORMATION_CONTEXT = ''State Tax Rules''
	    AND  HOI.ORG_INFORMATION1 = ''' || l_state || '''
	    AND  NVL(HOI.ORG_INFORMATION16,''No'') = ''Yes''
	    AND  not exists (select ''x''
                            from hr_organization_information HOI2
                            where HOI2.organization_id = puar.tax_unit_id
	                    AND  HOI2.ORG_INFORMATION_CONTEXT = ''1099R Magnetic Report Rules''
                            AND  HOI2.ORG_INFORMATION2 is not null)
            AND  ASG.payroll_id is not null
            AND  :payroll_action_id   is not null
          ORDER  BY ASG.person_id';

    elsif (l_state = 'CT' and l_report_cat = 'RTCTN') then
       sqwl_range := 'SELECT distinct ASG.person_id
          FROM   hr_organization_information HOI,
                 per_assignments_f           ASG,
                 pay_us_asg_reporting        puar,
                 pay_state_rules             SR
          WHERE  SR.state_code            = ''' || l_state || '''
            AND  puar.jurisdiction_code like substr(SR.jurisdiction_code  ,1,2)||''%''
            AND  ASG.assignment_id           = puar.assignment_id
            AND  ASG.assignment_type         = ''E''
            AND  ASG.effective_start_date   <= ''' || l_effective_date || '''
            AND  ASG.effective_end_date     >= ''' || l_start_date || '''
            AND  ASG.business_group_id + 0   = ''' || l_business_group_id || '''
	    AND  HOI.organization_id = puar.tax_unit_id
	    AND  HOI.ORG_INFORMATION_CONTEXT = ''State Tax Rules''
	    AND  HOI.ORG_INFORMATION1 = ''' || l_state || '''
	    AND  NVL(HOI.ORG_INFORMATION20,''No'') = ''Yes''
	    AND  not exists (select ''x''
                            from hr_organization_information HOI2
                            where HOI2.organization_id = puar.tax_unit_id
	                    AND  HOI2.ORG_INFORMATION_CONTEXT = ''1099R Magnetic Report Rules''
                            AND  HOI2.ORG_INFORMATION2 is not null)
            AND  ASG.payroll_id is not null
           AND  :payroll_action_id      is not null
           ORDER  BY ASG.person_id';
    else
        IF    (l_state = 'CA') THEN
            l_preprocess_flag :=  preprocess_check(pactid              ,
                                                   l_start_date        ,
                                                   l_effective_date    ,
                                                   l_business_group_id ,
                                                   l_state             ,
                                                   l_report_cat        );
        END IF;
        IF ((l_preprocess_flag = TRUE AND l_state = 'CA') OR
            l_state <> 'CA') THEN
       sqwl_range := 'SELECT distinct ASG.person_id
          FROM   hr_organization_information HOI,
                 per_assignments_f           ASG,
                 pay_us_asg_reporting        puar,
                 pay_state_rules             SR
          WHERE  SR.state_code            = ''' || l_state || '''
            AND  puar.jurisdiction_code like substr(SR.jurisdiction_code  ,1,2)||''%''
            AND  ASG.assignment_id           = puar.assignment_id
            AND  ASG.assignment_type         = ''E''
            AND  ASG.effective_start_date   <= ''' || l_effective_date || '''
            AND  ASG.effective_end_date     >= ''' || l_start_date || '''
            AND  ASG.business_group_id + 0   = ''' || l_business_group_id || '''
            AND  ((''' || l_state || ''' IN ( ''CA'',''ME''))
                   OR (not exists (select ''x''
                            from hr_organization_information HOI2
                            where HOI2.organization_id = puar.tax_unit_id
	                    AND  HOI2.ORG_INFORMATION_CONTEXT = ''1099R Magnetic Report Rules''
                            AND  HOI2.ORG_INFORMATION2 is not null)))
            AND  HOI.organization_id = puar.tax_unit_id
	    AND  HOI.ORG_INFORMATION_CONTEXT = ''State Tax Rules''
	    AND  HOI.ORG_INFORMATION1 = ''' || l_state || '''
	    AND  NVL(HOI.ORG_INFORMATION16,''No'') = ''No''
	    AND  NVL(HOI.ORG_INFORMATION20,''No'') = ''No''
            AND  ASG.payroll_id is not null
            AND  :payroll_action_id      is not null
            ORDER  BY ASG.person_id';

/* commented by saurgupt for testing
       sqwl_range := 'SELECT distinct ASG.person_id
          FROM   pay_payrolls_f              PPY,
              	 hr_organization_information HOI,
                 per_assignments_f           ASG,
                 pay_us_asg_reporting        puar,
                 pay_state_rules             SR
          WHERE  SR.state_code            = ''' || l_state || '''
            AND  substr(SR.jurisdiction_code  ,1,2) =
                                  substr(puar.jurisdiction_code,1,2)
            AND  ASG.assignment_id           = puar.assignment_id
            AND  ASG.assignment_type         = ''E''
            AND  ASG.effective_start_date   <= ''' || l_effective_date || '''
            AND  ASG.effective_end_date     >= ''' || l_start_date || '''
            AND  ASG.business_group_id + 0   = ''' || l_business_group_id || '''
            AND  ((''' || l_state || ''' IN ( ''CA'',''ME''))
                   OR (not exists (select ''x''
                            from hr_organization_information HOI2
                            where HOI2.organization_id = puar.tax_unit_id
	                    AND  HOI2.ORG_INFORMATION_CONTEXT = ''1099R Magnetic Report Rules''
                            AND  HOI2.ORG_INFORMATION2 is not null)))
            AND  HOI.organization_id = puar.tax_unit_id
	    AND  HOI.ORG_INFORMATION_CONTEXT = ''State Tax Rules''
	    AND  HOI.ORG_INFORMATION1 = ''' || l_state || '''
	    AND  NVL(HOI.ORG_INFORMATION16,''No'') = ''No''
	    AND  NVL(HOI.ORG_INFORMATION20,''No'') = ''No''
            AND  PPY.payroll_id              = ASG.payroll_id
            AND  :payroll_action_id      is not null
            ORDER  BY ASG.person_id';
*/
        END IF;

	end if;

        hr_utility.trace('Bulit sqlstr for range ');

	sqlstr := sqwl_range;

        /* Bug 773937 */
        /* Select Tax unit Id from legislative parameters */
        select INSTR(legislative_parameters,'TRANSFER_TRANS_LEGAL_CO_ID=')
                                   + LENGTH('TRANSFER_TRANS_LEGAL_CO_ID=')
        into l_from
        from pay_payroll_actions
        where payroll_action_id = pactid;

        hr_utility.trace('l_from is '||to_char(l_from));


        /* End position of state in legislative parameters */

        select INSTR(legislative_parameters,'TRANSFER_DATE=')
        into l_to
        from pay_payroll_actions
        where payroll_action_id = pactid;

        hr_utility.trace('l_to is '||to_char(l_to));

        l_length := l_to - l_from - 1 ;

        hr_utility.trace('l_length is '||to_char(l_length));

        select fnd_number.canonical_to_number(substr(legislative_parameters, l_from , l_length ))
        into  l_tax_unit_id
        from  pay_payroll_actions
        where payroll_action_id = pactid;

        hr_utility.trace('Transmitter GRS is '||to_char(l_tax_unit_id));
        hr_utility.trace('Report Category is '||l_report_cat);

	/* Commenting this check as there's no need to define W2 reporting rules
	   for SQWL's except for PR, which checks if a GRE is a PR GRE or not.
        if l_report_cat in ('RM', 'RTLAQ') then

            open  c_reporting_rules(l_tax_unit_id);

            fetch c_reporting_rules into l_w2_reporting_rules_exist;

              if c_reporting_rules%NOTFOUND then

                 message_preprocess := 'SQWL process - W2 Reporting Rules Missing';
                 message_text := 'Define these for tax unit id '||to_char(l_tax_unit_id);


                 hr_utility.trace('W2 Reporting rules have not been setup');

                 pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                 pay_core_utils.push_token('record_name',message_preprocess);
                 pay_core_utils.push_token('description',message_text);

              end if;
        close  c_reporting_rules;

        end if;
        */

        hr_utility.trace('Finished with W2 Reporting Rules check ');

        l_archive := chk_gre_archive(pactid);

        hr_utility.trace('after gre archive ');

        if g_archive_flag = 'N' then

           hr_utility.trace('range_cursor archiving employer data');

           archive_gre_data(p_payroll_action_id => pactid,
                            p_tax_unit_id       => l_tax_unit_id);

            hr_utility.trace('range_cursor archiving employer data');

        end if;
        /* End of Bug 773937 */

  end range_cursor;

--begin

--hr_utility.trace_on(null,'sqwl');

end pay_us_sqwl_archive;

/
