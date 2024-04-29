--------------------------------------------------------
--  DDL for Package Body PAY_US_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ARCHIVE" as
/* $Header: pyusarch.pkb 120.15.12010000.4 2009/08/10 10:38:36 svannian ship $ */

/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Description : Package and procedure to build sql for payroll processes.

   Change List
   -----------
    Date         Name        Vers   Bug No   Description
    -----------  ----------  -----  -------  -----------------------------------
    18-Sep-2007                     5517938  Archived First Yr Roth Contrib
                                             from Person EIT.
    18-Sep-2007                              Reverting Back the Changes done
                                             in 115.100
    06-SEP-2007  sudedas   115.100  5517938  Archiving Year of Prior Deferral
                                             For Roth 401(k)/403(b)
    28-AUG-2007 vaprakas   115.99            Fix of bug 5065406
                                    5744676  l_jd_done_tab, l_jd_name_done_tab
                                             need to be Cleared for each Employee.
    03-AUG-2007  sudedas     115.98 3973766  Job Development Fee (AL) need not
                                             to be Archived.
    05-JAN-2007  sackumar    115.97 5745950  Modified cursor c_get_disability_plan_scl_info
    13-DEC-2006  kvsankar    115.96 5696031  Modified cursor c_get_latest_asg
                                             to remove the order by clause.
    13-NOV-2006  sodhingr    115.95 5656018  removed fnd_date.canonical_to_date
                                             for A_ONLINE_W2
    30-AUG-2006  sodhingr    115.94 5499805  Added a check to archive null if
                                             if View Online W2 profile option
                                             is blank
    29-AUG-2006  sodhingr    115.93 3829668  Employees added to archive will have
                                             A_W2_CORRECTED = 'N',checking the
                                             value of A_ADD_ARCHIVE to decide if
                                             A_W2_CORRECTED should be N. Also,
                                             changed eoy_archive_gre_data to
                                             archive A_VIEW_ONLINE_W2 with the
                                             archive level of ER REARCH

    28-AUG-2006  sodhingr    115.92 4947859  Changed eoy_archive_data to archive
                                             A_W2_CORRECTED and eoy_archive_gre_data
                                             to archive, A_VIEW_ONLINE_W2
    11-AUG_2006  saurgupt    115.91 4544792  Replace DBI
                                             A_EXTRA_ASSIGNMENT_INFORMATION_PAY_US_DISABILITY_PLAN_INFO_DF_PLAN_ID
                                             with A_SCL_ASG_US_NJ_PLAN_ID. Removed the cursor
                                             c_get_disability_plan_eit_info with c_get_disability_plan_scl_info.
    29-AUG-2005  rsethupa    115.90 4163949  Modified cursor c_get_asg_id to
                                             pick only the Primary Assignment
    10-AUG-2005  rsethupa    115.89          Added code to enter message into
                                             PAY_MESSAGE_LINES
    08-AUG-2005  rsethupa    115.88 4137906  Suppressed Time Info in
                                             A_ARCHIVE_DATE
    17-NOV-2004  ahanda      115.87          Added support to RANGE_PERSON_ID
    18-AUG-2004  meshah      115.86          storing city jd in plsql table
                                             was missing. added back again
    18-AUG-2004  meshah      115.85          now deleting l_jd_done_tab per
                                             employee. Refer to note where we
                                             are deleting the table.
                                             Still getting the city, county
                                             and state from plsql table.
    11-AUG-2004  meshah      115.84          Archiving the sysdate for each
                                             employee. This will be used to mark
                                             W-2s as reissued or ammended.
    06-AUG-2004  meshah      115.83 2149544  Added a check in range_cursor to
                                             check for multiple submissions.
    05-AUG-2004  meshah      115.82          moved plsql tables l_jd_done_tab
                                             and l_jd_name_done_tab from body
                                             to the header.
                                             Added new procedure deinit.
    04-AUG-2004  meshah      115.81          Fixed gscc error. File Sql 6
    04-AUG-2004  meshah      115.80          moved variable eoy_gre_range
                                             within the range cursor.
                                             removed archiving of data that will
                                             not be used from 2004 onwards.
                                             removed extra code from
                                             eoy_action_creation.
                                             Changed eoy_archinit, now getting
                                             payroll action data irrespective of
                                             report type.
                                             eoy)archive_data - now saving the
                                             city, county and state abbrev in a
                                             plsql table. Not deleting the
                                             l_jd_done_tab table per employee.
                                             changed c_get_city and c_get_county
                                             cursor to check for tax exists
                                             within the cursor.
                                             Moved all the code of getting the
                                             user_entity_id into archinit, so
                                             that it is executed only once.
    23-JAN-2004  ahanda      115.79          Modifed select stmt to get the
                                             Spouse SSN for PR GRE to get the
                                             last row valid for the year.
    04-DEC-2003  sodhingr    115.75          Correct the values being passed to
                                             pay_us_sqwl_udf.get_employment_code
    26-NOV-2003  sodhingr    115.74 2219097  Changed package eoy_archive_data
                                             and eoy_archive_gre_data to archive
                                             government_employer flag and
                                             changed logic to archive
                                             employement code for all employees
                                             even if the GRE is non-govement.
    06-NOV-2003  sodhingr    115.73 2084862  Archiving Disability plan code
                                             required for NJ magnetic tape
                                    3234690  Archiving 1099R distribution code
    24-OCT-2003  sodhingr    115.72 3207279  Added the check for language='US'
                                             in the cursor csr_defined_balance
    23-SEP-2003  sodhingr    115.71 3155042  Changed  the cursor c_balance to
                                            get meaning from fnd_lokkup_values
                                            instead of fnd_common_lookups to fix
                                            performance issue
    04-SEP-2003  sodhingr    115.70 2219097 Changed procedure eoy_archive_data
                                            to archive medicare, SS and thei
                                            employement code
    05-AUG-2003  sodhingr    115.68 2901349 Commented the cursor c_eoy_all and
                                            eoy_all_range as GRE is manadatory
                                            parameter for year end process so
                                            these cursors will never be used.
                                            Also, changed cursor eoy_gre_range
                                            to join with pay_us_asg_reporting
                                            instead of hr_soft_coding_keyflex.
                                            This will ensure that assignments
                                            are picked up year end preprocess
                                            even if GRE is no longer valid for
                                            that assignment.
    05-AUG-2003  sodhingr    115.68 2753184 Change the logic to archive school
                                            districtonly once. If the residence
                                            address is changed and the school
                                            district remains the same then
                                            archiver
                                            was archiving it twice, one when
                                            archiving the city school district
                                            and other when archiving the county
                                            school district
    18-JUN-2003  sodhingr    115.67 3011003 Commented the cursors
                                            c_get_defined_balance_id,
                                            c_get_puerto_rico_bal,
                                            c_get_1099r_bal and using
                                            pay_us_payroll_utils.
                                            c_get_defined_balance_id
    18-jun-2003  sodhingr    115.66 3011003 Changed the cursors
                                            c_get_defined_balance_id,
                                            c_get_puerto_rico_bal,
                                            c_get_1099r_bal to add
                                            join with creator_type = 'B'
    27-DEC-2002  asasthan    115.65 2727539 changes to c_get_latest_asg cursor
                                            to also pick reversal actions
    24-DEC-2002  asasthan    115.65         changes to c_get_latest_asg cursor
                                            to pick the correct action for
                                            balance call
    02-DEC-2002  asasthan    115.64         nocopy changes for gscc comp
    08-NOV-2002  asasthan    115.63 2589239 Suppressed effective_date index in
                                            archive_data procedure for
                                            pay_payroll_actions in
                                            c_get_latest_asg cursor
    31-OCT-2002  asasthan    115.62 2589239 Suppressed effective_date index of
                                            pay_payroll_actions in
                                            c_get_latest_asg cursor
    23-SEP-2002  asasthan    115.61 2590094 Archiving of BOX 12 cursor change
    18-SEP-2002  fusman      115.60         Updated re-archiving changes.
    17-SEP-2002  asasthan    115.59         Added archiving of W2 Transmitter
    13-SEP-2002  fusamn     115.58          Added update if null so that mags
                                            will not be affected.
    06-SEP-2002  asasthan   115.57          Moved trace_on within range_code
    06-SEP-2002  asasthan   115.56          To correct Employer Rearch print
                                            process.
                                            Changes for 1099 Magnetic rules
                                            to be included in Emp REarch.
    06-SEP-2002  asasthan   115.55          Employer Rearch was inserting rows
                                            into ff_archive_items instead of
                                            updating values. l_old_value made
                                            null instead of 'Null'.
                                            Also added more contexts for
                                            Employer Rearch process to
                                            handle
                                            FEDERAL TAX RULES
                                            FED TAX UNIT INFORMATION
    04-SEP-2002  asasthan   115.54          Modified local variables l_old_value                                            ,l_rowid_found ,l_fed_state_value                                                to 240 instead of 100 varchar2
    29-AUG-2002  fusman     115.53          Added new value in the State Re-archive process.
    29-AUG-2002  fusman     115.52          Added a null check for the archived value.
    29-AUG-2002  asasthan   115.51          Further changes for 1099 balances
    28-AUG-2002  asasthan   115.49          Changed Names of 1099 balances
                                            to Other EE Annuity Contract Amt
                                            and Unrealized Net ER Sec Apprec.
                                            Used plsql table for 1099R
                                            balance feed checking
                                            Reverted to old range code
                                            that uses
                                            hr_soft_coding_keyflex
                                            Balance calls for PR use plsql tab
    28-AUG-2002  fusman     115.48          Added changes for employer re-archive process.
    27-AUG-2002  asasthan   115.47          Added function get_parameter
    27-AUG-2002  asasthan   115.46          Added function get_report_type
                                            so as to suppress the
                                            call for eoy_archive_gre_data
                                            for W2C_PRE_PROCESS.
    23-AUG-2002  asasthan   115.45          Added global_variable for                                                       report_type
    23-AUG-2002  asasthan   115.44          Changed names for 2 1099R balances
    22-AUG-2002  asasthan   115.43          Checking for feeds for 1099R GREs
                                            and cached user entities for
                                            1099 and PR balances
                                            GREs.
    19-AUG-2002  asasthan   115.42 2491268  Changes for Puerto Rico and 1099R
    19-AUG-2002  asasthan   115.41 2245457  Changes to archive W2 BOX 12
                                            information thro' the
                                            package and not thro' the formula.
    15-AUG-2002  asasthan   115.40 2200920  Changed Range Cursor to go off
                                            tax_unit_id of
                                            pay_assignment_actions and not
                                            hr_soft_coding_keyflex
                                   2503639  Archiving Territory Balances
                                            with Dimension of PER_GRE_YTD
                                            and not PER_JD_GRE_YTD.
    18-JUN-2002  ahanda     115.39 2412644  Correct Hint Syntax.
    01-APR-2002  asasthan   115.38 2249870  modified Index Hint addded in
                                            115.36 to use
                                            PAY_ASSIGNMENT_ACTIONS_N51 instead
                                            of PAY_ASSIGNMENT_ACTIONS_N1
    22-JAN-2002  jgoswami   115.37          added checkfile command
    28-DEC-2001  jgoswami   115.36 2161771  Added Index Hint in exist part of
                                            the sql statement for c_eoy_gre in
                                            eoy_action_creation procedure.
    04-DEC-2001  jgoswami   115.35          Added Data related to Puerto Rico
                                            A_MARITAL_STATUS,
                                            A_CON_NATIONAL_IDENTIFIER
    30-NOV-2001  jgoswami   115.34          added dbdrv command
    09-NOV-2001  jgoswami   115.33          Added archive_type to ff_archive_items
                                             insert for Payroll Action level.
    15-OCT-2001  jgoswami   115.32          Added cursor c_get_latest_asg in
                                            eoy_action_creation and eoy_archive_data
                                            for improving performance and removed the
                                            expensive query statement.
                                            Remove code for SQWL and W2.
    02-SEP-2001   ssarma    40.57           modified error handling to take care
                                            of exceptions other than no_data_found.
    28-AUG-2001   ssarma    40.55           TERRITORY DBI. name change.
    28-AUG-2001   ssarma    40.54           TERRITORY.DBIs.should include JD
                                            as a context.
    27-AUG-2001   ssarma    40.52           TERRITORY_TAXABLE_ALLOWANCE_PER_GRE_YTD
                                            instead of
                                            TERRITORY_TAXABLE_ALLOWANCES_PER_GRE_YTD
    23-AUG-2001   djoshi    40.49           removed comment as per sanjay
    22-AUG-2001   ssarma    40.48           Revamp of create_archive,
                                            eoy_archive_gre_data and
                                            eoy_archive_data procedures
                                            for employer level re-archive.
                                            Tables used instead of variables
                                            for user_entity_id and value in
                                            create_archive.

    14-aug-2001   djoshi    40.47           Changed the Database item name
                                            A_TERRITORY_TAXABLE_RETIREMENT_CONTRIBUTION_PER_GRE_YTD to
                                            A_TERRITORY_RETIREMENT_CONTRIB_PER_GRE_YTD

    14-AUG-2001   SSarma    40.46           EOY 2001: Changes for security.
                                            per_all_assignments_f instead of
                                            per_assignmentes_f.
                                            New items archived for Employer.
                                            Legislation code checks for
                                            ff_user_entities join.
                                            Specific archiving for Puerto Rico.

   03-Aug-2000   ssarma     40.43           EOY 2000: Changes to city, county cursors
                                            Checks for formula compilation.
                                            Check to see if jurisdiction has been
                                            archived - city, county, state.
                                            Change to eoy action creation cursor.
                                            Change to select which gets latest assignment
                                            action.
                                            Filter for selecting employees bases on 5
                                            balances.
   20-JAN-2000   ahanda      40.42          Changed the c_eoy_gre cursor
                                            to go of the per_assignments_f
                                            as a driving table instead of
                                            pay_payroll_actions.
   12-dec-1999   ahanda      40.41          Added check in c_get_county and
                                            c_get_state cursor to bypass the
                                            picking up of user defined city tax
                                            records.
   10-dec-1999   achauhan    40.40          In c_get_city cursor added a check
                                            to bypass the picking up of user
                                            defined city tax records.Since we do
                                            not withhold taxes for user defined
                                            cities, we do not need to archive them.
    27-oct-1999  djoshi      40.39          Modified the file to have the
                                            fed_informaiton_context = '401K LIMITS'
                                            added to the A_SS_EE_wage_BASE and
                                            A_SS_EE_WAGE_RATE.
    25-oct-1999  djoshi	     40.37          added the A_SS_EE_WAGE_BASE and
                                            A_SS_EE_WAGE rate to archive the data
                                            related to bug 983094 and 101435
   01-sep-1999  achauhan     40.33          While archiving the employer data
                                            add the context of pay_payroll_actions
                                            to ff_archive_item_contexts.
   11-aug-1999  achauhan     40.32          Added the call to
                                            eoy_archive_gre_data in the
                                            eoy_range_cursor procedure. This is
                                            being done to handle the situation
                                            of archiving employer level data
                                            even when there are no employees in
                                            a GRE.
   10-aug-1999  achauhan     40.31          In the archive_data routine,
                                            removed the use of payroll_action_id
                                            >= 0.
   04-Aug-1999  VMehta       40.30     Changed eoy_archive_data to improve
                                            performance.
   02-Jun-1999  meshah       40.25          added new cursors in the range and action
					    creation cursors to check for non profit
					    gre's for the state of connecticut.

   08-mar-1999  VMehta      40.24           Added nvl while checking for l_1099R_ind
                                            to correct the Louisiana quality jobs program
                                            tape processing.
   26-jan-1999  VMehta      40.23           Modified function report_person_on_tape to
                                            return false for all states except California
                                            and Massachusetts.
   24-Jan-1999  VMehta      40.22  805012   Added function report_person_on_tape to perform
                                            check for retirees having SIT w/h in california.
   06-Jan-1999  MReid       40.21           Changed c_eoy_gre cursor to disable
                                            business_group_id index on ppa side
   30-dec-1998  vmehta      40.20  709641   Look at SUI_ER_SUBJ_WHABLE instead of SUI_ER_GROSS
                                            for picking up people for SQWL . This makes sure
                                            that only people with SUI wages are picked up.
   27-dec-1998  vmehta      40.19           Corrected the cursor in action creation to get the
                                            tax_unit_name from pay_assignment_actions.
   21-DEC-1998  achauhan    40.18           Changed the cursor in action creation to get the
                                            assignments from the pay_assignment_actions table.

   08-DEC-1998  vmehta      40.17           Removed grouping by on assignment_id while creating
                                            assignment_ids
   08-DEC-1998  nbristow    40.16           Updated the c_state cursor to use
                                            an exists rather than a join.
   07-DEC-1998  nbristow    40.15           Resolved some issues introduced by
                                            40.13.
   04-DEC-1998  vmehta      40.14  750802   Changed the cursors/logic to
                                            pick up people who live in
                                            California for the California SQWL.
   29-NOV-1998  nbristow    40.13           Changes to the SQWL code,
                                            now using pay_us_asg_reporting.
   25-Sep-1998	vmehta      40.5            Changed the range cursor and
                                            the assignment_action creation
                                            cursors to support Louisiana
                                            Quality Jobs Program Reporting.
   08-aug-1998  achauhan    40.2            Added the routines for eoy -
                                            Year End Pre-Process
   18-MAY-1998  NBRISTOW    40.1            sqwl_range cursor now checks
                                            the tax_unit_id etc.
   06-MAY-1998  NBRISTOW    40.0            Created.
   27-OCT-1999  RPOTNURU    110.16          Bug fix  976472
   30-Dec-2008  skpatil	    115.103         Archiving acces code for PR at eoy_archive_ge_data(6928011)


*/
   eoy_gre_range varchar2(4000);
   eoy_all_range varchar2(4000);
   g_pact_creation_date  Date;

 /* Name    : bal_db_item
  Purpose   : Given the name of a balance DB item as would be seen in a fast formula
              it returns the defined_balance_id of the balance it represents.
  Arguments :
  Notes     : A defined balance_id is required by the PLSQL balance function.
 */

 FUNCTION bal_db_item ( p_db_item_name varchar2)
 return number
 IS

 /* Get the defined_balance_id for the specified balance DB item. */

   cursor csr_defined_balance is
     select to_number(UE.creator_id)
     from  ff_user_entities  UE,
           ff_database_items DI
     where  DI.user_name            = p_db_item_name
       and  UE.user_entity_id       = DI.user_entity_id
       and  Ue.creator_type         = 'B'
       and  UE.legislation_code     = 'US';

   l_defined_balance_id pay_defined_balances.defined_balance_id%type;

 BEGIN
   --hr_utility.trace('p_db_item_name is '||p_db_item_name);

   open csr_defined_balance;
   fetch csr_defined_balance into l_defined_balance_id;
   if csr_defined_balance%notfound then
     close csr_defined_balance;
     raise hr_utility.hr_error;
   else
     close csr_defined_balance;
   end if;

   --hr_utility.trace('l_defined_balance_id is '||to_char(l_defined_balance_id));
   return (l_defined_balance_id);

 END bal_db_item;


 /*****************************************************************************
  Name      : get_payroll_action_info
  Purpose   : This returns the Payroll Action level
              information for  W-2C Archiver.
  Arguments : p_payroll_action_id - Payroll_Action_id of archiver
              p_start_date        - Start date of Archiver
              p_end_date          - End date of Archiver
              p_business_group_id - Business Group ID
 ******************************************************************************/
 PROCEDURE get_payroll_action_info(p_payroll_action_id     in number
                                  ,p_end_date             out nocopy date
                                  ,p_start_date           out nocopy date
                                  ,p_business_group_id    out nocopy number
                                  ,p_tax_unit_id          out nocopy number
                                  ,p_person_id            out nocopy number
                                  ,p_ssn                  out nocopy varchar2
                                  ,p_asg_set              out nocopy number
                                  ,p_year                 out nocopy number
                                  ,p_creation_date        out nocopy date
                                  )
 IS
    cursor c_payroll_Action_info (cp_payroll_action_id in number) is
      select
        to_number(pay_us_payroll_utils.get_parameter('TRANSFER_GRE',
                                                     ppa.legislative_parameters)),
        to_number(pay_us_payroll_utils.get_parameter('PER_ID',ppa.legislative_parameters)),
        pay_us_payroll_utils.get_parameter('SSN',ppa.legislative_parameters),
        to_number(pay_us_payroll_utils.get_parameter('ASG_SET',ppa.legislative_parameters)),
        to_number(pay_us_payroll_utils.get_parameter('YEAR',ppa.legislative_parameters)),
        effective_date,
        start_date,
        business_group_id,
        creation_date
      from pay_payroll_actions ppa
     where ppa.payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_tax_unit_id       NUMBER := 0;
    ln_person_id         NUMBER := 0;
    ln_asg_set           NUMBER := 0;
    ln_ssn               NUMBER;
    ln_year              NUMBER := 0;
    ln_creation_date     DATE;

   BEGIN
       hr_utility.trace('Entered get_payroll_action_info');
       open c_payroll_action_info(p_payroll_action_id);
       hr_utility.trace('Opened c_payroll_action_info ');

       fetch c_payroll_action_info into ln_tax_unit_id,
                                        ln_person_id,
                                        ln_ssn,
                                        ln_asg_set,
                                        ln_year,
                                        ld_end_date,
                                        ld_start_date,
                                        ln_business_group_id,
                                        ln_creation_date;
       hr_utility.trace('Fetched c_payroll_action_info ');

       close c_payroll_action_info;

       hr_utility.trace('Closed c_payroll_action_info ');
       p_end_date          := ld_end_date;
       p_start_date        := ld_start_date;
       p_business_group_id := ln_business_group_id;
       p_tax_unit_id       := ln_tax_unit_id;
       p_person_id         := ln_person_id;
       p_ssn               := ln_ssn;
       p_asg_set           := ln_asg_set;
       p_year              := ln_year;
       p_creation_date     := fnd_date.canonical_to_date(
                    substr(fnd_date.date_to_canonical(ln_creation_date),1,10));

       hr_utility.trace('ld_end_date = ' ||
                            to_char(ld_end_date));
       hr_utility.trace('ld_start_date = ' ||
                            to_char(ld_start_date));
       hr_utility.trace('ln_tax_unit_id = ' ||
                            to_char(ln_tax_unit_id));
       hr_utility.trace('ln_person_id = ' ||
                            to_char(ln_person_id));
       hr_utility.trace('ln_ssn = ' ||
                            ln_ssn);
       hr_utility.trace('ln_asg_set = ' ||
                            to_char(ln_asg_set));
       hr_utility.trace('ln_year = ' ||
                            to_char(ln_year));
       hr_utility.trace('ln_creation_date = ' ||
                            to_char(ln_creation_date));

       hr_utility.trace('Leaving get_payroll_action_info');
  EXCEPTION
    when others then
       hr_utility.trace('Error in ' ||
                         to_char(sqlcode) || '-' || sqlerrm);
       raise hr_utility.hr_error;

  END get_payroll_action_info;

  /*********************************************************************
   Name      : get_report_type
   Purpose   : This function returns the report_type
               ( eg W2C_PRE_PROCESS , YREND) of the archive process.
   Arguments :
   Notes     :
  *********************************************************************/
  FUNCTION get_report_type( p_payroll_action_id  in number)

  RETURN VARCHAR2

  IS

  cursor c_get_report_type is
  select report_type
    from pay_payroll_actions ppa
   where ppa.payroll_action_id = p_payroll_action_id;


  BEGIN

     hr_utility.trace('g_report_type before call ='||g_report_type);

      open c_get_report_type;
      fetch c_get_report_type into g_report_type;

      if c_get_report_type%NOTFOUND then
         raise_application_error(-20001,'get_report_type: Payroll Action data not found');
      end if;
      close c_get_report_type;
     hr_utility.trace('g_report_type after call ='||g_report_type);

  RETURN (g_report_type);

  END get_report_type;

  /*********************************************************************
   Name      : get_puerto_rico_info
   Purpose   : This function returns Y if the GRE for the archive
               process is a Puerto Rico GRE.
               It also builds the plsql tale with defined balance
               id of the Puerto Rico balances.
   Arguments :
   Notes     :
  *********************************************************************/
  FUNCTION get_puerto_rico_info(
                p_tax_unit_id      in number)
  RETURN VARCHAR2
  IS


  lv_puerto_rico_flag                varchar2(1) := 'N';
  l_step                             number;
  ln_count                           number := 0;
  lv_balance_name                    VARCHAR2(80) := '';
  lv_balance_dimension               VARCHAR2(80) := '';
  lv_user_entity_name                ff_user_entities.user_entity_name%TYPE;
  lv_arch_user_entity_name           ff_user_entities.user_entity_name%TYPE;
  ln_arch_user_entity_id             NUMBER;
  ln_defined_balance_id              number := 0;
  ln_user_entity_id                  number := 0;

    cursor c_puerto_rico_gre_info (cp_tax_unit_id  in number) is
      select 'Y'
        from hr_organization_information
       where organization_id = cp_tax_unit_id
         and org_information16 = 'P'
         and org_information_context = 'W2 Reporting Rules';

/*    cursor c_get_puerto_rico_bal is
        select pbt.balance_name,pdb.defined_balance_id,fue.user_entity_name
         from ff_user_entities fue,
              pay_defined_balances pdb,
              pay_balance_dimensions pbd,
              pay_balance_types pbt
        where pbt.balance_name in  (
                                     'Territory Pension Annuity',
                                     'Territory Reimb Expenses',
                                     'Territory Taxable Comm',
                                     'Territory Taxable Allow',
                                     'Territory Taxable TIPS',
                                     'Territory Retire Contrib'
                                    )
          and pbd.database_item_suffix= '_PER_GRE_YTD'
          and pbt.balance_type_id = pdb.balance_type_id
          and pbd.balance_dimension_id = pdb.balance_dimension_id
          and fue.creator_id = pdb.defined_balance_id
	  and fue.creator_type = 'B'
          and ((pbt.legislation_code = 'US' and
                pbt.business_group_id is null)
            or (pbt.legislation_code is null and
                pbt.business_group_id is not null))
          and ((pbd.legislation_code ='US' and
                pbd.business_group_id is null)
            or (pbd.legislation_code is null and
                pbd.business_group_id is not null)) ;
*/

    cursor c_get_arch_user_entity (cp_live_database_item  in varchar2) is
        select fue.user_entity_id
         from ff_user_entities fue
        where fue.user_entity_name = cp_live_database_item
          and ((fue.legislation_code = 'US' and
                fue.business_group_id is null)
            or (fue.legislation_code is null and
                fue.business_group_id is not null)) ;

  BEGIN
       pay_us_archive.ltr_pr_balances.delete;

     BEGIN

     l_step := 19;
     hr_utility.trace('Checking for Puerto Rico GRE');

     open  c_puerto_rico_gre_info(p_tax_unit_id);
     fetch c_puerto_rico_gre_info into g_puerto_rico_gre;
     hr_utility.trace('g_puerto_rico_gre = '||g_puerto_rico_gre);

     if c_puerto_rico_gre_info%NOTFOUND then
        g_puerto_rico_gre := 'N';
     else
              /* build the user_entity_id in plsql tables for Puerto Rico */

              BEGIN

              /* Init variables */

              lv_arch_user_entity_name := '';
              lv_user_entity_name := '';
              lv_balance_name := '';
              ln_count := 0 ;

              lv_balance_dimension := '_PER_GRE_YTD';

              pay_us_archive.ltr_pr_balances(1).balance_name := 'Territory Pension Annuity' ;
	      pay_us_archive.ltr_pr_balances(2).balance_name := 'Territory Reimb Expenses' ;
	      pay_us_archive.ltr_pr_balances(3).balance_name := 'Territory Taxable Comm' ;
	      pay_us_archive.ltr_pr_balances(4).balance_name := 'Territory Taxable Allow' ;
	      pay_us_archive.ltr_pr_balances(5).balance_name := 'Territory Taxable TIPS' ;
	      pay_us_archive.ltr_pr_balances(6).balance_name := 'Territory Retire Contrib' ;

              hr_utility.trace('Opening pay_us_payroll_utils.c_get_defined_balance_id');

	      loop
		  ln_count := ln_count + 1;
		  IF ln_count > 6 THEN
			exit;
		  END IF;
                  open pay_us_payroll_utils.c_get_defined_balance_id(pay_us_archive.ltr_pr_balances(ln_count).balance_name,
                                    lv_balance_dimension,
                                    NULL);
	          -- open c_get_puerto_rico_bal;

                  lv_arch_user_entity_name := '';
                  lv_user_entity_name := '';
                  lv_balance_name := '';
                  ln_defined_balance_id := '';

              fetch pay_us_payroll_utils.c_get_defined_balance_id
	      into ln_defined_balance_id,
                   lv_user_entity_name;

              hr_utility.trace('Fetched pay_us_payroll_utils.c_get_defined_balance_id '
                                ||lv_balance_name);

                  if pay_us_payroll_utils.c_get_defined_balance_id%NOTFOUND then
                     hr_utility.trace('Going to exit' );
                     exit;
                  end if;

             l_step := 19.1;

             lv_arch_user_entity_name := 'A_'||lv_user_entity_name;

             hr_utility.trace('lv_arch_user_entity_name = '
                                  ||lv_arch_user_entity_name);
             l_step := 19.2;
                 open c_get_arch_user_entity(lv_arch_user_entity_name);

                 fetch c_get_arch_user_entity into ln_arch_user_entity_id;

                     if c_get_arch_user_entity%notfound then
                        hr_utility.trace('Archived user_entity_id not found');
                        hr_utility.raise_error;
                     end if;
                 close c_get_arch_user_entity;
                 hr_utility.trace('ln_arch_user_entity_id = ' ||
                                  to_char(ln_arch_user_entity_id));
                 hr_utility.trace('ln_defined_balance_id = ' ||
                                  to_char(ln_defined_balance_id));

             l_step := 19.3;

            -- pay_us_archive.ltr_pr_balances(ln_count).balance_name := lv_balance_name ;
             pay_us_archive.ltr_pr_balances(ln_count).defined_balance := ln_defined_balance_id ;
             pay_us_archive.ltr_pr_balances(ln_count).user_entity_id := ln_arch_user_entity_id ;
             close pay_us_payroll_utils.c_get_defined_balance_id;
            end loop;

            hr_utility.trace('Closed cursor');

            l_step := 19.4;
           END; /* Building Puerto Rico user entities */

         end if;
     close c_puerto_rico_gre_info;

     l_step := 20;
     END; /* Puerto Rico Info */

      return (g_puerto_rico_gre);

  END get_puerto_rico_info;

  /*********************************************************************
   Name      : get_1099r_info
   Purpose   : This function returns Y if the GRE for the archive
               process is a 1099R GRE.
               It also builds the plsql tale with defined balance
               id of the 1099R balances.
   Arguments :
   Notes     :
  *********************************************************************/
  FUNCTION get_1099r_info(
                p_tax_unit_id      in number)
  RETURN VARCHAR2
  IS

  l_step                             number;
  ln_count                           number := 0;
  lv_balance_name                    VARCHAR2(500) := '';
  lv_balance_dimension               VARCHAR2(80) := '';
  lv_user_entity_name                ff_user_entities.user_entity_name%TYPE;
  lv_arch_user_entity_name           ff_user_entities.user_entity_name%TYPE;
  ln_arch_user_entity_id             NUMBER;
  ln_defined_balance_id              number := 0;
  ln_user_entity_id                  number := 0;
  lv_1099r_flag                      varchar2(5) := null;
  lv_feed_flag                       varchar2(1) := 'N';
  lv_all_1099_balances		     VARCHAR2(500);

    cursor c_1099_gre_info(cp_tax_unit_id  in number) is
       select hoi.org_information2
         from hr_organization_information hoi
        where hoi.organization_id = cp_tax_unit_id
          and hoi.org_information_context  = '1099R Magnetic Report Rules';

    cursor c_balance_feed_info(cp_balance_name  in varchar2) is
    select 'Y' from pay_balance_types pbt
     where pbt.balance_name = cp_balance_name
       and((pbt.legislation_code = 'US' and
            pbt.business_group_id is null)
        or(pbt.legislation_code is null and
           pbt.business_group_id is not null))
   and exists (
     select balance_feed_id  from pay_balance_feeds_f feed
      where feed.balance_type_id = pbt.balance_type_id
        and((feed.legislation_code = 'US' and
             feed.business_group_id is null)
         or(feed.legislation_code is null and
           feed.business_group_id is not null))
           );

/*    cursor c_get_1099r_bal is
        select pbt.balance_name,pdb.defined_balance_id,fue.user_entity_name
         from ff_user_entities fue,
              pay_defined_balances pdb,
              pay_balance_dimensions pbd,
              pay_balance_types pbt
        where pbt.balance_name in  (
                                     'Capital Gain',
                                     'EE Contributions Or Premiums',
                                     'Other EE Annuity Contract Amt',
                                     'Total EE Contributions',
                                     'Unrealized Net ER Sec Apprec'
                                    )
          and pbd.database_item_suffix= '_PER_GRE_YTD'
          and pbt.balance_type_id = pdb.balance_type_id
          and pbd.balance_dimension_id = pdb.balance_dimension_id
          and fue.creator_id = pdb.defined_balance_id
	  and fue.creator_type = 'B'
          and ((pbt.legislation_code = 'US' and
                pbt.business_group_id is null)
            or (pbt.legislation_code is null and
                pbt.business_group_id is not null))
          and ((pbd.legislation_code ='US' and
                pbd.business_group_id is null)
            or (pbd.legislation_code is null and
                pbd.business_group_id is not null)) ;
*/

    cursor c_get_arch_user_entity (cp_live_database_item  in varchar2) is
        select fue.user_entity_id
         from ff_user_entities fue
        where fue.user_entity_name = cp_live_database_item
          and ((fue.legislation_code = 'US' and
                fue.business_group_id is null)
            or (fue.legislation_code is null and
                fue.business_group_id is not null)) ;

  BEGIN

     BEGIN

     pay_us_archive.ltr_1099_bal.delete;
     l_step := 21;
     hr_utility.trace('Checking for 1099R GRE');

     open  c_1099_gre_info(p_tax_unit_id);

     fetch c_1099_gre_info into g_1099R_transmitter_code;

     hr_utility.trace('g_1099R_transmitter_code = '||g_1099R_transmitter_code);

       if c_1099_gre_info%NOTFOUND then
          g_1099R_transmitter_code := null;
       end if;

       if g_1099R_transmitter_code is not null then

       /* build the user_entity_id in plsql tables for 1099R GRE */

       BEGIN

       /* Init variables */

       lv_arch_user_entity_name := '';
       lv_user_entity_name := '';
       lv_balance_name := '';
       ln_count := 0 ;
       ln_defined_balance_id := 0 ;

       lv_balance_dimension := '_PER_GRE_YTD';

       hr_utility.trace('Opening pay_us_payroll_utils.c_get_defined_balance_id');

	 pay_us_archive.ltr_1099_bal(1).balance_name := 'Capital Gain' ;
	 pay_us_archive.ltr_1099_bal(2).balance_name := 'EE Contributions Or Premiums' ;
	 pay_us_archive.ltr_1099_bal(3).balance_name := 'Other EE Annuity Contract Amt' ;
	 pay_us_archive.ltr_1099_bal(4).balance_name := 'Total EE Contributions' ;
	 pay_us_archive.ltr_1099_bal(5).balance_name := 'Unrealized Net ER Sec Apprec' ;


       loop
	 ln_count := ln_count + 1;
	 IF ln_count > 5 THEN
	    exit;
	 END IF;
	 open pay_us_payroll_utils.c_get_defined_balance_id(pay_us_archive.ltr_1099_bal(ln_count).balance_name,
                                    lv_balance_dimension,
                                    NULL);
--       open c_get_1099r_bal;


          lv_arch_user_entity_name := '';
          lv_user_entity_name := '';
          lv_balance_name := '';
          ln_defined_balance_id := 0;

          fetch pay_us_payroll_utils.c_get_defined_balance_id
          into ln_defined_balance_id
               ,lv_user_entity_name;

          hr_utility.trace('Fetched pay_us_payroll_utils.c_get_defined_balance_id '
                            ||lv_balance_name);

          if pay_us_payroll_utils.c_get_defined_balance_id%NOTFOUND then
             exit;
          end if;

          l_step := 21.1;

          lv_arch_user_entity_name := 'A_'||lv_user_entity_name;

          hr_utility.trace('lv_arch_user_entity_name = '
                                ||lv_arch_user_entity_name);
          l_step := 21.2;
          open c_get_arch_user_entity(lv_arch_user_entity_name);

          fetch c_get_arch_user_entity into ln_arch_user_entity_id;

          if c_get_arch_user_entity%notfound then
             hr_utility.trace('Archived user_entity_id not found');
             hr_utility.raise_error;
          end if;
          close c_get_arch_user_entity;
          hr_utility.trace('ln_arch_user_entity_id = ' ||
                            to_char(ln_arch_user_entity_id));
          hr_utility.trace('ln_defined_balance_id = ' ||
                            to_char(ln_defined_balance_id));

          l_step := 21.3;

--          pay_us_archive.ltr_1099_bal(ln_count).balance_name := lv_balance_name ;
          pay_us_archive.ltr_1099_bal(ln_count).defined_balance := ln_defined_balance_id ;
          pay_us_archive.ltr_1099_bal(ln_count).user_entity_id := ln_arch_user_entity_id ;
          close pay_us_payroll_utils.c_get_defined_balance_id;

      end loop;
            hr_utility.trace('Closed cursor');

            l_step := 21.4;

      END; /* Building 1099R user entities */


        /* check whether these balances have been fed or not */

        for j in pay_us_archive.ltr_1099_bal.first ..
                  pay_us_archive.ltr_1099_bal.last loop

        lv_feed_flag := 'N';

        l_step := 21.5;
        open  c_balance_feed_info(pay_us_archive.ltr_1099_bal(j).balance_name);

         fetch c_balance_feed_info into lv_feed_flag;

         l_step := 21.6;
         hr_utility.trace('lv_feed_flag = '||lv_feed_flag);

            if c_balance_feed_info%NOTFOUND then
               lv_feed_flag := 'N';
               l_step := 21.7;
             pay_us_archive.ltr_1099_bal(j).feed_info := 'N';

            else

            l_step := 21.8;
            pay_us_archive.ltr_1099_bal(j).feed_info := lv_feed_flag;
            end if;
         close c_balance_feed_info ;

            l_step := 21.9;

        end loop;

        end if; /*g_1099R_transmitter_code */

       close c_1099_gre_info;

     l_step := 22;

     END; /* 1099R GRE Info */

      return (g_1099R_transmitter_code);

  END get_1099r_info;

  /*********************************************************************
   Name      : get_pre_tax_info
               Builds the plsql table with box 12 info
   Arguments :
   Notes     :
  *********************************************************************/
  FUNCTION get_pre_tax_info(
                p_tax_unit_id      in number,
                p_business_group_id in number)
  RETURN VARCHAR2
  IS

  l_step                             number;
  ln_count                           number := 0;
  lv_balance_name                    VARCHAR2(80) := '';
  lv_balance_dimension               VARCHAR2(80) := '';
  lv_user_entity_name                ff_user_entities.user_entity_name%TYPE;
  lv_arch_user_entity_name           ff_user_entities.user_entity_name%TYPE;
  ln_arch_user_entity_id             NUMBER;
  ln_defined_balance_id              number := 0;
  ln_user_entity_id                  number := 0;

 cursor c_balance is
/*
     select meaning
       from fnd_common_lookups
      where application_id = 801
        and lookup_type = 'W2 BOX 12'
        and enabled_flag = 'Y'
*/
      select meaning
      from  fnd_lookup_values flv,
            fnd_lookup_types flt
      where flv.lookup_type = flt.lookup_type
      and application_id = 801
      and flt.lookup_type = 'W2 BOX 12'
      and enabled_flag = 'Y'
      and language = 'US';

/*    cursor c_get_defined_balance_id (
              cp_balance_name  in varchar2,
               cp_balance_dimension in varchar2,
               cp_business_group_id in number ) is
        select pdb.defined_balance_id,fue.user_entity_name
         from ff_user_entities fue,
              pay_defined_balances pdb,
              pay_balance_dimensions pbd,
              pay_balance_types pbt
        where pbt.balance_name = cp_balance_name
          and pbd.database_item_suffix= cp_balance_dimension
          and pbt.balance_type_id = pdb.balance_type_id
          and pbd.balance_dimension_id = pdb.balance_dimension_id
          and fue.creator_id = pdb.defined_balance_id
	  and fue.creator_type = 'B'
          and ((pbt.legislation_code = 'US' and
                pbt.business_group_id is null)
            or (pbt.legislation_code is null and
                pbt.business_group_id = cp_business_group_id))
          and ((pbd.legislation_code ='US' and
                pbd.business_group_id is null)
            or (pbd.legislation_code is null and
                pbd.business_group_id = cp_business_group_id)) ;
*/
    cursor c_get_arch_user_entity (cp_live_database_item  in varchar2) is
        select fue.user_entity_id
         from ff_user_entities fue
        where fue.user_entity_name = cp_live_database_item
          and ((fue.legislation_code = 'US' and
                fue.business_group_id is null)
            or (fue.legislation_code is null and
                fue.business_group_id is not null)) ;



  BEGIN
      pay_us_archive.ltr_pre_tax_bal.delete;

      hr_utility.trace('p_business_group_id = '||to_char(p_business_group_id));
      hr_utility.trace('p_tax_unit_id = '||to_char(p_tax_unit_id));
     BEGIN

      l_step := 14;

       hr_utility.trace('Opening c_balance cursor to get lookup codes');

       lv_balance_dimension := '_PER_GRE_YTD';
       g_pre_tax_info := 'Y' ;
       open c_balance;

       loop
       lv_arch_user_entity_name := '';
       lv_user_entity_name := '';
       ln_defined_balance_id := 0 ;

       fetch c_balance into lv_balance_name ;
       hr_utility.trace('Fetched c_balance '||lv_balance_name);
       if c_balance%NOTFOUND then
       hr_utility.trace('Going to exit' );
          exit;
       end if;

      l_step := 15;
      open pay_us_payroll_utils.c_get_defined_balance_id(lv_balance_name,
                                    lv_balance_dimension,
                                    p_business_group_id);

      fetch pay_us_payroll_utils.c_get_defined_balance_id
      into ln_defined_balance_id,
           lv_user_entity_name;

      lv_arch_user_entity_name := 'A_'||lv_user_entity_name;

      hr_utility.trace('lv_arch_user_entity_name = '||lv_arch_user_entity_name);

      if pay_us_payroll_utils.c_get_defined_balance_id%FOUND then

      hr_utility.trace('Into found loop of Box 12  ');
      hr_utility.trace('ln_defined_balance_id = '||to_char(ln_defined_balance_id));

      l_step := 16;
      open c_get_arch_user_entity(lv_arch_user_entity_name);

      fetch c_get_arch_user_entity into ln_arch_user_entity_id;

      if c_get_arch_user_entity%notfound then
         hr_utility.trace('Archived user_entity_id not found');
         hr_utility.raise_error;
      end if;
      close c_get_arch_user_entity;
      hr_utility.trace('ln_arch_user_entity_id = ' ||
                           to_char(ln_arch_user_entity_id));
      hr_utility.trace('ln_defined_balance_id = ' ||
                           to_char(ln_defined_balance_id));

      l_step := 17;
       ln_count := ln_count + 1;


       pay_us_archive.ltr_pre_tax_bal(ln_count).balance_name := lv_balance_name ;
       pay_us_archive.ltr_pre_tax_bal(ln_count).defined_balance := ln_defined_balance_id ;
       pay_us_archive.ltr_pre_tax_bal(ln_count).user_entity_id := ln_arch_user_entity_id ;

      end if;
      close pay_us_payroll_utils.c_get_defined_balance_id;

      end loop;
      close c_balance;

       hr_utility.trace('Closed cursor');

      l_step := 18;
     END; /* Box 12 Info */

      return (g_pre_tax_info);

  END get_pre_tax_info;


 ------------------------------------------------------------------------
 /* Name    : eoy_action_creation
  Purpose   : This creates the assignment actions for a specific chunk
              of people to be archived by the year end pre-process.
  Arguments :
  Notes     :
 */
 ------------------------------------------------------------------------
 PROCEDURE eoy_action_creation(pactid    in number,
                               stperson  in number,
                               endperson in number,
                               chunk     in number)
 IS

   /* Variables used to hold the select columns from the SQL statement.*/
   l_person_id          number;
   l_tax_unit_id        number;

   l_eoy_tax_unit_id    number;
   l_effective_date     date;
   l_bus_group_id       number;

   l_primary_asg        pay_assignment_actions.assignment_id%type;
   l_bal_aaid           pay_assignment_actions.assignment_action_id%type;

   /* Variables used to check if RANGE_PERSON_ID is enabled */
   l_range_person       BOOLEAN;

   /* Variables used to hold the current values returned within the loop for
      checking against the new values returned from within the loop on the
      next iteration. */
   l_prev_person_id     per_people_f.person_id%type;
   l_prev_tax_unit_id   hr_organization_units.organization_id%type;

   /* Variable to hold the jurisdiction code used as a context for state
      reporting. */
   l_jurisdiction_code  varchar2(30);

   /* general process variables */
   l_value              number;
   l_year_start         date;
   l_year_end           date;
   lockingactid         number;
   /* message variables */
   l_mesg               varchar2(100);
   l_record_name        varchar2(100);

   /* For Year End Preprocess we have to archive the assignments
      belonging to a GRE including the 1099R GRE */
   CURSOR c_eoy_gre(cp_period_start      in date
                   ,cp_period_end        in date
                   ,cp_tax_unit_id       in number
                   ,cp_business_group_id in number
                   ,cp_start_person_id   in number
                   ,cp_end_person_id     in number) is
     SELECT DISTINCT
            ASG.person_id person_id
       FROM per_all_assignments_f      ASG,
            pay_all_payrolls_f         PPY
      WHERE exists
           (select /*+ INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                       INDEX(ppa PAY_PAYROLL_ACTIONS_PK) */
                   'x'
              from pay_payroll_actions ppa,
                   pay_assignment_actions paa
             where ppa.effective_date between cp_period_start
	                                  and cp_period_end
               and  ppa.action_type in ('R','Q','V','B','I')
               and  ppa.action_status = 'C'
               and  ppa.business_group_id + 0 = cp_business_group_id
               and  ppa.payroll_action_id = paa.payroll_action_id
               and  paa.tax_unit_id = cp_tax_unit_id
               and  paa.action_status = 'C'
               and  paa.assignment_id = ASG.assignment_id
               and  ppa.business_group_id = ASG.business_group_id +0
               and  ppa.effective_date between ASG.effective_start_date
                                           and  ASG.effective_end_date)
        AND ASG.person_id between cp_start_person_id and cp_end_person_id
        AND ASG.assignment_type = 'E'
        AND PPY.payroll_id = ASG.payroll_id;

   CURSOR c_eoy_gre_person_on(cp_period_start      in date
                             ,cp_period_end        in date
                             ,cp_tax_unit_id       in number
                             ,cp_business_group_id in number
                             ,cp_payroll_Action_id in number
                             ,cp_chunk_number      in number) is
     select DISTINCT
            asg.person_id person_id
       from pay_population_ranges ppr,
            per_all_assignments_f asg,
            pay_all_payrolls_f    ppy
      where exists
            (select /*+ INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                        INDEX(ppa PAY_PAYROLL_ACTIONS_PK) */
                   'x'
               from pay_payroll_actions ppa,
                    pay_assignment_actions paa
              where ppa.effective_date between cp_period_start
                                           and cp_period_end
                and  ppa.action_type in ('R','Q','V','B','I')
                and  ppa.action_status = 'C'
                and  ppa.business_group_id + 0 = cp_business_group_id
                and  ppa.payroll_action_id = paa.payroll_action_id
                and  paa.tax_unit_id = cp_tax_unit_id
                and  paa.action_status = 'C'
                and  paa.assignment_id = asg.assignment_id
                and  ppa.business_group_id = asg.business_group_id +0
                and  ppa.effective_date between asg.effective_start_date
                                            and asg.effective_end_date)
        and asg.person_id = ppr.person_id
        and ppr.payroll_Action_id = cp_payroll_Action_id
        and ppr.chunk_number = cp_chunk_number
        and asg.assignment_type = 'E'
        and ppy.payroll_id = asg.payroll_id;

   /* Get the primary assignment for the given person_id */
   CURSOR c_get_asg_id(cp_person_id    in number
                      ,cp_period_start in date
                      ,cp_period_end   in date) IS
     SELECT assignment_id
     from per_all_assignments_f paf
     where person_id = cp_person_id
     and   primary_flag = 'Y'
     and   assignment_type = 'E'
     and   paf.effective_start_date = (select max(paf2.effective_start_date)
		                                   from per_all_assignments_f paf2
		                                  where paf2.primary_flag = 'Y'
		                                    and paf2.assignment_type = 'E'
		                                    and paf2.effective_start_date <= cp_period_end
		                                    and paf2.effective_end_date >= cp_period_start
		                                    and paf2.person_id = paf.person_id
		                                ) /* Bug 4163949 - Added above sub query */
     ORDER BY assignment_id desc;

   -- Bug 5696031
   -- Modified the cursor to remove the order by clause that was there before.
   -- The select clause has been modified to get the Assignment Action ID
   -- associated with Maximum Action Sequence
   /* Get the latest assignment for the given person_id */
   CURSOR c_get_latest_asg(cp_person_id number
                          ,cp_tax_unit_id  in number
                          ,cp_period_start in date
                          ,cp_period_end   in date) IS
     select fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')
                                                 ||lpad(paa.assignment_action_id,15,'0')),16))
     from pay_assignment_actions     paa,
          per_all_assignments_f      paf,
          pay_payroll_actions        ppa,
          pay_action_classifications pac
     where paf.person_id = cp_person_id
     and paa.assignment_id = paf.assignment_id
     and paa.tax_unit_id   = cp_tax_unit_id
     and paa.payroll_action_id = ppa.payroll_action_id
     and ppa.action_type = pac.action_type
     and pac.classification_name = 'SEQUENCED'
     and ppa.effective_date +0 between paf.effective_start_date
                                   and paf.effective_end_date
     and ppa.effective_date +0 between cp_period_start
                                   and cp_period_end
     and ((nvl(paa.run_type_id, ppa.run_type_id) is null and
           paa.source_action_id is null)
       or (nvl(paa.run_type_id, ppa.run_type_id) is not null and
           paa.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           paa.run_type_id is not null and
           paa.source_action_id is null));

 BEGIN

   /* Get the report type, report qualifier, business group id and the
      gre for which the archiving has to be done */
--   hr_utility.trace_on(null,'yepp');

   hr_utility.trace('In eoy_action_creation');
   hr_utility.trace('getting payroll action data');

   select effective_date,
          business_group_id,
          to_number(substr(legislative_parameters,
                     instr(legislative_parameters,'TRANSFER_GRE=')
                     + length('TRANSFER_GRE=')))
     into l_effective_date,
          l_bus_group_id,
          l_eoy_tax_unit_id
     from pay_payroll_actions
    where payroll_action_id = pactid;

   l_year_start := trunc(l_effective_date, 'Y');
   l_year_end   := add_months(trunc(l_effective_date, 'Y'),12) -1;
   hr_utility.trace('year start '|| to_char(l_year_start,'dd-mm-yyyy'));
   hr_utility.trace('year end '|| to_char(l_year_end,'dd-mm-yyyy'));

   l_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => 'YREND'
                          ,p_report_format    => 'YEPARCH'
                          ,p_report_qualifier => 'FED'
                          ,p_report_category  => 'RT');

   if l_eoy_tax_unit_id <> 99999 then
      if l_range_person then
         open c_eoy_gre_person_on(l_year_start
                                 ,l_year_end
                                 ,l_eoy_tax_unit_id
                                 ,l_bus_group_id
                                 ,pactid
                                 ,chunk);
      else
         open c_eoy_gre(l_year_start
                       ,l_year_end
                       ,l_eoy_tax_unit_id
                       ,l_bus_group_id
                       ,stperson
                       ,endperson);
      end if;

      loop
         if l_range_person then
            fetch c_eoy_gre_person_on into l_person_id;
            hr_utility.trace('Person ID = '|| to_char(l_person_id));
            exit when c_eoy_gre_person_on%NOTFOUND;
         else
            fetch c_eoy_gre into l_person_id;
            hr_utility.trace('Person ID = '|| to_char(l_person_id));
            exit when c_eoy_gre%NOTFOUND;
         end if;

         l_tax_unit_id := l_eoy_tax_unit_id;

         /* If the new row is the same as the previous row according to the way
            the rows are grouped then discard the row ie. grouping by GRE
            requires a single row for each person / GRE combination. */
         hr_utility.trace('tax unit id is '|| to_char(l_tax_unit_id));
         hr_utility.trace('previous tax unit id is '||
                           to_char(l_prev_tax_unit_id));

         if (l_person_id   = l_prev_person_id   and
             l_tax_unit_id = l_prev_tax_unit_id) then
             null;
         else
             hr_utility.trace('prev person is '|| to_char(l_prev_person_id));
             hr_utility.trace('person is '|| to_char(l_person_id));

             /* Have a new unique row according to the way the rows are grouped.
                The inclusion of the person is dependent on having a non zero
                balance.
                If the balance is non zero then an assignment action is created to
                indicate their inclusion in the magnetic tape report. */

             open c_get_latest_asg(l_person_id
                                  ,l_tax_unit_id
                                  ,l_year_start
                                  ,l_year_end);
             fetch c_get_latest_asg into l_bal_aaid;
             if c_get_latest_asg%notfound then
                l_bal_aaid := -9999;
                close c_get_latest_asg;
                raise_application_error(-20001,'Balance Assignment Action ' ||
                                               'does not exist for : '      ||
                                               to_char(l_person_id));
             end if;
             hr_utility.trace('l_bal_aaid in action creation code'||to_char(l_bal_aaid));
             if c_get_latest_asg%ISOPEN then
                close c_get_latest_asg;
             end if;

             if l_bal_aaid <> -9999 then  /* Assignment action in year */
                /* Set up the context of tax unit id */
                hr_utility.trace('Setting context');
                pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);

                hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
                hr_utility.trace('defined_balance_id = '||
                                  to_char(bal_db_item('GROSS_EARNINGS_PER_GRE_YTD')));

                l_value :=  nvl(pay_balance_pkg.get_value
                               (p_defined_balance_id
                                     => bal_db_item('GROSS_EARNINGS_PER_GRE_YTD'),
                                p_assignment_action_id => l_bal_aaid),0);

                if l_value = 0 then
                   hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
                   hr_utility.trace('defined_balance_id = '||
                                     to_char(bal_db_item('W2_NONTAX_SICK_PER_GRE_YTD')));

                   l_value := nvl(pay_balance_pkg.get_value
                           (p_defined_balance_id
                                 => bal_db_item('W2_NONTAX_SICK_PER_GRE_YTD'),
                            p_assignment_action_id => l_bal_aaid),0);

                   if l_value = 0 then
                      hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
                      hr_utility.trace('defined_balance_id = '||
                                        to_char(bal_db_item('W2_EXPENSE_REIMB_PER_GRE_YTD')));

                      l_value := nvl(pay_balance_pkg.get_value
                                    (p_defined_balance_id
                                          => bal_db_item('W2_EXPENSE_REIMB_PER_GRE_YTD'),
                                     p_assignment_action_id => l_bal_aaid),0);

                      if l_value = 0 then
                         hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
                         hr_utility.trace('defined_balance_id = '||
                                           to_char(bal_db_item('W2_QUAL_MOVE_PER_GRE_YTD')));

                         l_value := nvl(pay_balance_pkg.get_value
                                       (p_defined_balance_id
                                            => bal_db_item('W2_QUAL_MOVE_PER_GRE_YTD'),
                                        p_assignment_action_id => l_bal_aaid),0);

                         if l_value = 0 then
                            hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
                            hr_utility.trace('defined_balance_id = '||
                                     to_char(bal_db_item('W2_NO_GROSS_EARNINGS_PER_GRE_YTD')));

                            l_value := nvl(pay_balance_pkg.get_value
                                          (p_defined_balance_id
                                            => bal_db_item('W2_NO_GROSS_EARNINGS_PER_GRE_YTD'),
                                           p_assignment_action_id => l_bal_aaid),0);

                         end if; /* W2_NO_GROSS_EARNINGS_PER_GRE_YTD */
                      end if; /* W2_QUAL_MOVE_PER_GRE_YTD */
                   end if; /* W2_EXPENSE_REIMB_PER_GRE_YTD */
                end if; /* W2_NONTAX_SICK_PER_GRE_YTD */

                if l_value <> 0 then
                   /* Get the primary assignment */
                   open c_get_asg_id(l_person_id
                                    ,l_year_start
                                    ,l_year_end);
                   fetch c_get_asg_id into l_primary_asg;
                   if c_get_asg_id%NOTFOUND then
                      close c_get_asg_id;
		      /* Added to show message in PAY_MESSAGE_LINES */
		      l_mesg := 'Primary Assignment Not Found for Person '|| to_char(l_person_id);
		      l_record_name := 'Person '|| to_char(l_person_id);
                      pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','A');
		      pay_core_utils.push_token('record_name',l_record_name);
		      pay_core_utils.push_token('description',l_mesg);
                      raise_application_error(-20001,'Primary Assignment Not Found ' ||
                                                     'for person ' || to_char(l_person_id));
                   end if;
                   if c_get_asg_id%ISOPEN then
                      close c_get_asg_id;
                   end if;

                   /* Create the assignment action to represnt the person / tax unit
                      combination. */
                   select pay_assignment_actions_s.nextval
                     into lockingactid
                     from dual;

                   /* Insert into pay_assignment_actions. */
                   hr_utility.trace('creating asg action');

                   hr_nonrun_asact.insact(lockingactid,l_primary_asg,
                                          pactid,chunk,l_tax_unit_id);

                   /* Update the serial number column with the person id
                      so that the mag routine and the W2 view will not have
                      to do an additional checking against the assignment
                      table */
                   hr_utility.trace('updating asg action');

                   update pay_assignment_actions aa
                   set    aa.serial_number = to_char(l_person_id)
                   where  aa.assignment_action_id = lockingactid;

                end if; /* l_value <> 0 */
             end if; /* l_bal_aaid <> -9999 */
          end if;   /* l_person and l_tax_unit are different */

        /* Record the current values for the next time around the loop. */
        l_prev_person_id   := l_person_id;
        l_prev_tax_unit_id := l_tax_unit_id;
      end loop;
      if l_range_person then
         close c_eoy_gre_person_on;
      else
         close c_eoy_gre;
      end if;
   end if;

 END eoy_action_creation;


 /* Name      : get_user_entity_id
    Purpose   : This gets the user_entity_id for a specific database item name.
    Arguments : p_dbi_name -> database item name.
    Notes     :
 */
 FUNCTION get_user_entity_id (p_dbi_name in varchar2)
                              return number is
  l_user_entity_id  number;

  begin
    --hr_utility.trace('p_dbi_name is '||p_dbi_name);

    select fdi.user_entity_id
    into l_user_entity_id
    from ff_database_items fdi,
         ff_user_entities  fue
    where fdi.user_name = p_dbi_name
      and fue.user_entity_id = fdi.user_entity_id
      and fue.legislation_code = 'US';

    --hr_utility.trace('user_entity_id  is '||to_char(l_user_entity_id));
    return l_user_entity_id;

    exception
    when others then
         raise_application_error(-20001,'Error getting user_entity_id for DBI : '
                       ||p_dbi_name||' - '||to_char(sqlcode) || '-' || sqlerrm);
  end get_user_entity_id;

  procedure create_archive (p_user_entity_id in pay_us_archive.number_data_type_table,
                            p_context1       in number,
                            p_value          in pay_us_archive.char240_data_type_table,
                            p_sequence       in pay_us_archive.number_data_type_table,
                            p_context        in pay_us_archive.char240_data_type_table,
                            p_context_id     in pay_us_archive.number_data_type_table,
                            p_archive_level  in varchar2 default 'EE') is

  l_step             number        := 0;
  l_tax_context_id   number        := 0;
  l_jursd_context_id number        := 0;
  l_jd               varchar2(11)  := null;
  l_tuid             number        := 0;
  l_rowid_found      varchar2(240);
  l_archive_type     ff_archive_items.archive_type%type;
  l_rearch           boolean        :=FALSE;
  l_fed_state_value  varchar2(240);
  l_old_value        varchar2(240):= null;
  l_new_value        varchar2(240):= null;

  begin

           l_step := 1;

      if p_archive_level in('ER','ER REARCH') then /* Employer Level Archive */

         if p_archive_level = 'ER REARCH' THEN

            l_rearch := TRUE;

         end if;

             l_archive_type := 'PA';
             select context_id
               into l_tax_context_id
               from ff_contexts
               where context_name = 'TAX_UNIT_ID';

             l_step := 2;

             select context_id
               into l_jursd_context_id
               from ff_contexts
              where context_name = 'JURISDICTION_CODE';

             l_step := 3;
             for i in p_sequence.first .. p_sequence.last
             loop
                 if p_context_id(i) = l_jursd_context_id then
                    l_jd := p_context(i);
                 elsif p_context_id(i) = l_tax_context_id then
                    l_tuid := p_context(i);
                 end if;
             end loop;


           if l_jd is null then          /* Federal Level Archive */

              l_fed_state_value := 'Federal';

            l_step := 4;
            for j in p_user_entity_id.first .. p_user_entity_id.last
             loop
              begin
              select rowid,fai.value into l_rowid_found,l_old_value
                from ff_archive_items fai
               where user_entity_id = p_user_entity_id(j)
                 and context1       = p_context1
                 and exists (select 'x' from ff_archive_item_contexts faic
                              where fai.archive_item_id = faic.archive_item_id
                                and faic.context_id = l_tax_context_id
                                and faic.context    = l_tuid );
              exception when no_data_found then
                        l_rowid_found := null;
                        l_old_value   := Null;
              end;

             hr_utility.trace('l_old_value = '||l_old_value);

              IF l_rowid_found IS NOT NULL THEN

                 IF (  l_rearch
                       AND (nvl( p_value(j),'-*9999999') <> nvl(l_old_value ,'-*9999999')
                            ))  THEN

                    BEGIN
                       hr_utility.trace('B4 update of value ');
                       update ff_archive_items
                       set value = p_value(j)
                       where rowid  = l_rowid_found;

                    EXCEPTION WHEN OTHERS  THEN
                             hr_utility.trace('In others error for update -200 ');
                    END;

                    l_new_value := p_value(j);
                    hr_utility.trace('Updating Non null value in re-arch with new value = '
                                            ||p_value(j));

                   /* calling the print procedure only if we have not null update */

                    pay_us_er_rearch.print_er_rearch_data( p_user_entity_id(j),
                                                   l_fed_state_value,
                                                   l_old_value,
                                                   l_new_value);


                 ELSE

                    /* Smart archive call from any other Solution */
                    /* here requirement is that update only if null */

                    IF (l_old_value is NULL
                       AND  p_value(j) is not NULL
                       AND  (not l_rearch) ) THEN

                    BEGIN
                       update ff_archive_items
                       set value = p_value(j)
                       where rowid  = l_rowid_found;
                    EXCEPTION WHEN OTHERS  THEN
                             hr_utility.trace('In others error for update -210 ');
                    END;

                       l_new_value := p_value(j);
                       hr_utility.trace('Updating for other process  new value = '||p_value(j));

                    END IF; /* smart archive call */

                 END IF; /* End l_rearch */

              ELSE /* Archive row does not exist */

                 hr_utility.trace('No rowid found ');
                 insert into ff_archive_items
                    (ARCHIVE_ITEM_ID,
                     USER_ENTITY_ID,
                     CONTEXT1,
                     VALUE,
                     ARCHIVE_TYPE)
                    values
                    (ff_archive_items_s.nextval,
                     p_user_entity_id(j),
                     p_context1,
                     p_value(j),
                     l_archive_type);

                     l_step := 8;

                     l_new_value := p_value(j);

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
              END IF;  /* End if of if l_rowid_found is not null  */

               /* Re-intializing value to null  */

               l_old_value := null;
               l_new_value := null;
               hr_utility.trace('assigned null values before loop end');

             END LOOP; /*  for j in p_user_entity_id.firs  */

           ELSE /* State Level Employer Archive */

            l_step := 5;
            l_fed_state_value := 'State';
            for j in p_user_entity_id.first .. p_user_entity_id.last
            loop
              begin
                  select rowid,fai.value into l_rowid_found,l_old_value
                    from ff_archive_items fai
                   where user_entity_id = p_user_entity_id(j)
                     and context1       = p_context1
                     and exists (select 'x' from ff_archive_item_contexts faic
                                  where fai.archive_item_id = faic.archive_item_id
                                    and faic.context_id = l_tax_context_id
                                    and faic.context    = l_tuid )
                     and exists (select 'x' from ff_archive_item_contexts faic
                                  where fai.archive_item_id = faic.archive_item_id
                                    and faic.context_id = l_jursd_context_id
                                    and faic.context    = l_jd );
              exception when no_data_found then
                        l_rowid_found := null;
                        l_old_value := Null;
              end;


              if l_rowid_found is not null then

                 if l_old_value is null then

                    update ff_archive_items fai
                    set value = p_value(j)
                    where rowid = l_rowid_found;
                    l_new_value := p_value(j);

                 else

                    if l_rearch then

                       update ff_archive_items fai
                       set value = p_value(j)
                       where rowid = l_rowid_found;

                       l_new_value := p_value(j);

                    end if;

                 end if;


              else
                 insert into ff_archive_items
                    (ARCHIVE_ITEM_ID,
                     USER_ENTITY_ID,
                     CONTEXT1,
                     VALUE,
                     ARCHIVE_TYPE)
                    values
                    (ff_archive_items_s.nextval,
                     p_user_entity_id(j),
                     p_context1,
                     p_value(j),
                     l_archive_type);

                     l_step := 8;

                     l_new_value := p_value(j);

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
              end if;

              if l_rearch then

                   if (l_old_value  is null and  l_new_value is not null)
                      or (nvl(l_old_value,'-*9999999') <> nvl(l_new_value,'-*9999999') ) then

                      pay_us_er_rearch.print_er_rearch_data( p_user_entity_id(j),
                                                  l_fed_state_value,
                                                  l_old_value,
                                                  l_new_value);

                   end if;

               end if;

            end loop;
           end if;
      else /* EE Archive */
                     l_step := 9;

                 for j in p_user_entity_id.first .. p_user_entity_id.last
                 loop
                    insert into ff_archive_items
                    (ARCHIVE_ITEM_ID,
                     USER_ENTITY_ID,
                     CONTEXT1,
                     VALUE)
                    values
                    (ff_archive_items_s.nextval,
                     p_user_entity_id(j),
                     p_context1,
                     p_value(j));

                     l_step := 10;

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
                 end loop;
      end if; /* p_archive_level is EE */
  exception
       when others then
            hr_utility.trace('Error in create archive at step '||to_char(l_step)||' - '
                                   || to_char(sqlcode));
            raise_application_error(-20001,'Error in create archive at step '
                                   ||to_char(l_step)||' - '||to_char(sqlcode) || '-' || sqlerrm);
  end create_archive;

  /* Name      : eoy_archive_gre_data
     Purpose   : This performs the US specific employer data archiving.
     Arguments :
     Notes     :
  */

  procedure eoy_archive_gre_data(p_payroll_action_id in number,
                                 p_tax_unit_id       in number,
                                 p_jd_type           in varchar2 default 'ALL',
                                 p_state_code        in varchar2 default 'ALL')
  is

  l_user_entity_id_tab      pay_us_archive.number_data_type_table;
  l_tax_context_id          number;
  l_jursd_context_id        number;
  l_value1                  varchar2(240);
  l_value2                  varchar2(240);
  l_value3                  varchar2(240);
  l_value4                  varchar2(240);
  l_value5                  varchar2(240);
  l_value6                  varchar2(240);
  l_value7                  varchar2(240);
  l_value8                  varchar2(240);
  l_value9                  varchar2(240);
  l_value10                 varchar2(240);
  l_value11                 varchar2(240);
  l_value12                 varchar2(240);
  l_value13                 varchar2(240);
  l_value14                 varchar2(240);
  l_value15                 varchar2(240);
  l_value16                 varchar2(240);
  l_value17                 varchar2(240);
  l_value18                 varchar2(240);
  l_value19                 varchar2(240);
  l_value20                 varchar2(240);
  l_value_tab               pay_us_archive.char240_data_type_table;
  l_sit_uid                 number;
  l_sui_uid                 number;
  l_fips_uid                number;
  l_seq_tab                 pay_us_archive.number_data_type_table;
  l_context_id_tab          pay_us_archive.number_data_type_table;
  l_context_val_tab         pay_us_archive.char240_data_type_table;
  l_arch_gre_step           number := 0;
  l_archive_level           varchar2(240);

  ld_end_date          DATE;
  ld_start_date        DATE;
  ln_business_group_id NUMBER;
  ln_person_id         NUMBER := 0;
  ln_asg_set           NUMBER := 0;
  ln_ssn               NUMBER;
  ln_year              NUMBER := 0;
  l_tax_unit_id        NUMBER;
  l_w2_profile_option     VARCHAR2(10);

  cursor c_get_state_code is
  select state_code
  from   pay_us_states pus,
         hr_organization_information hoi
  where  hoi.organization_id = p_tax_unit_id
  and    hoi.org_information_context || '' = 'State Tax Rules'
  and    pus.state_abbrev = hoi.org_information1
  and    pus.state_code   = decode(p_state_code,'ALL',pus.state_code,p_state_code);

  begin

    l_arch_gre_step := 10;
    /* Get the context_id for 'TAX_UNIT_ID' */
    select context_id
    into l_tax_context_id
    from ff_contexts
    where context_name = 'TAX_UNIT_ID';

    l_arch_gre_step := 20;
    /* Get the context_id for 'JURISDICTION_CODE' */

    select context_id
    into l_jursd_context_id
    from ff_contexts
    where context_name = 'JURISDICTION_CODE';

    l_arch_gre_step := 30;


  IF p_jd_type in ('ALL','View Online W2 Profile') then -- bug 	4947859

      get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_tax_unit_id       => l_tax_unit_id
                            ,p_person_id         => ln_person_id
                            ,p_ssn               => ln_ssn
                            ,p_asg_set           => ln_asg_set
                            ,p_year              => ln_year
                            ,p_creation_date     => g_pact_creation_date);


      hr_utility.trace('ln_year '||to_char(ld_end_date,'YYYY'));

      l_user_entity_id_tab(1) := get_user_entity_id('A_VIEW_ONLINE_W2');
      l_w2_profile_option := fnd_profile.value('HR_VIEW_ONLINE_W2');
      IF l_w2_profile_option IS NOT NULL THEN
         l_value_tab(1) := to_char(ld_end_date, 'YYYY')+1||'/'
                                ||l_w2_profile_option;
      ELSE
          l_value_tab(1) := null;
      END IF;

      l_seq_tab(1) := 1;
      l_context_id_tab(1) := l_tax_context_id;
      l_context_val_tab(1) := p_tax_unit_id;


       l_arch_gre_step := 35;

       create_archive (p_user_entity_id => l_user_entity_id_tab,
                    p_context1       => p_payroll_action_id,
                    p_value          => l_value_tab,
                    p_sequence       => l_seq_tab,
                    p_context        => l_context_val_tab,
                    p_context_id     => l_context_id_tab,
                    p_archive_level  => 'ER REARCH');

  END IF;

  IF p_jd_type in ('ALL','FED 401K LIMITS') then
      /* Archive the SS EE wage Base */
      /* Archive the SS EE wage rate */

   l_arch_gre_step := 40;
   begin
      select ss_ee_wage_limit,
             ss_ee_rate
        into l_value1,l_value2
        from pay_us_federal_tax_info_f puftif,
             pay_payroll_actions ppa
       where ppa.payroll_action_id = p_payroll_action_id
         and ppa.effective_date between puftif.effective_start_date and effective_end_date
         and puftif.fed_information_category = '401K LIMITS';
   exception
        when no_data_found then
             l_value1 := null;
             l_value2 := null;
             hr_utility.trace('Error in eoy_archive_gre_data at step : ' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
   end;

     /* Initialise the PL/SQL tables */

       l_user_entity_id_tab.delete;
       l_value_tab.delete;
       l_seq_tab.delete;
       l_context_id_tab.delete;
       l_context_val_tab.delete;

      /* Assign  value to PL/SQL tables */

    l_arch_gre_step := 50;

    l_user_entity_id_tab(1) := get_user_entity_id('A_SS_EE_WAGE_BASE');
    l_user_entity_id_tab(2) := get_user_entity_id('A_SS_EE_WAGE_RATE');
    l_value_tab(1) := l_value1;
    l_value_tab(2) := l_value2;
    l_seq_tab(1) := 1;
    l_context_id_tab(1) := l_tax_context_id;
    l_context_val_tab(1) := p_tax_unit_id;

    l_arch_gre_step := 60;

    create_archive (p_user_entity_id => l_user_entity_id_tab,
                    p_context1       => p_payroll_action_id,
                    p_value          => l_value_tab,
                    p_sequence       => l_seq_tab,
                    p_context        => l_context_val_tab,
                    p_context_id     => l_context_id_tab,
                    p_archive_level  => 'ER');
    end if;

    IF p_jd_type in ('ALL','FED TAX UNIT INFORMATION'
                     , 'FED TAX UNIT INFORMATION REARCH'
                     ,'FED 1099R MAGNETIC REPORT RULES REARCH') then  /*bug 5065406 */
    /* Archive the Employer country code */

      l_arch_gre_step := 70;

    IF p_jd_type = 'FED TAX UNIT INFORMATION REARCH' THEN

       l_archive_level := 'ER REARCH';

    ELSE

       l_archive_level := 'ER';

    END IF;


    begin
       select hrl.country,
              substr(hou.name,1,240),
              substr(hoi.org_information1,1,240)
       into   l_value1,
              l_value2,
              l_value3
       from   hr_locations hrl,
              hr_all_organization_units hou,
              hr_organization_information hoi
       where  hou.organization_id = p_tax_unit_id
       and    hoi.organization_id = hou.organization_id
       and    hoi.org_information_context||'' = 'Employer Identification'
       and    hrl.location_id = hou.location_id;

       exception
       when no_data_found then
          l_value1 := null;
          l_value2 := null;
          l_value3 := null;
             hr_utility.trace('Error in eoy_archive_gre_data at step : ' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
    end;

    /* Initialise the PL/SQL tables */

    l_user_entity_id_tab.delete;
    l_value_tab.delete;
    l_seq_tab.delete;
    l_context_id_tab.delete;
    l_context_val_tab.delete;

    /* Assign values to the PL/SQL tables */

    l_arch_gre_step := 80;

    l_user_entity_id_tab(1) := get_user_entity_id('A_TAX_UNIT_COUNTRY_CODE');
    l_user_entity_id_tab(2) := get_user_entity_id('A_TAX_UNIT_NAME');
    l_user_entity_id_tab(3) := get_user_entity_id('A_TAX_UNIT_EMPLOYER_IDENTIFICATION_NUMBER');
    l_value_tab(1) := l_value1;
    l_value_tab(2) := l_value2;
    l_value_tab(3) := l_value3;
    l_seq_tab(1) := 1;
    l_context_id_tab(1) := l_tax_context_id;
    l_context_val_tab(1) := p_tax_unit_id;

    l_arch_gre_step := 90;

    create_archive (p_user_entity_id => l_user_entity_id_tab,
                    p_context1       => p_payroll_action_id,
                    p_value          => l_value_tab,
                    p_sequence       => l_seq_tab,
                    p_context        => l_context_val_tab,
                    p_context_id     => l_context_id_tab,
                    p_archive_level  => l_archive_level );

    end if;

    IF p_jd_type in ('ALL','FED 1099R MAGNETIC REPORT RULES',
                    'FED 1099R MAGNETIC REPORT RULES REARCH') then
    /* Archive the 1099R transmitter reporting rules */
      l_arch_gre_step := 100;

    IF p_jd_type = 'FED 1099R MAGNETIC REPORT RULES REARCH' THEN

       l_archive_level := 'ER REARCH';

    ELSE

       l_archive_level := 'ER';

    END IF;

    begin
    select substr(hoi.org_information2,1,240),
           substr(hoi.org_information1,1,240)
    into   l_value1,
           l_value2
    from   hr_organization_information hoi
    where  hoi.organization_id = p_tax_unit_id
    and    hoi.org_information_context || '' = '1099R Magnetic Report Rules';
       exception
       when no_data_found then
          l_value1 := null;
          l_value2 := null;
             hr_utility.trace('Error in eoy_archive_gre_data at step : ' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
    end;

    /* Initialise the PL/SQL tables */

    l_user_entity_id_tab.delete;
    l_value_tab.delete;
    l_seq_tab.delete;
    l_context_id_tab.delete;
    l_context_val_tab.delete;

    /* Assign values to the PL/SQL tables */
    l_arch_gre_step := 110;
    l_user_entity_id_tab(1) :=  get_user_entity_id('A_US_1099R_TRANSMITTER_CODE');
    l_user_entity_id_tab(2) :=  get_user_entity_id('A_US_1099R_TRANSMITTER_INDICATOR');
    l_value_tab(1) := l_value1;
    l_value_tab(2) := l_value2;
    l_seq_tab(1) := 1;
    l_context_id_tab(1) := l_tax_context_id;
    l_context_val_tab(1) := p_tax_unit_id;

    l_arch_gre_step := 120;

    hr_utility.trace('l_user_entity_name = '||l_user_entity_id_tab(1));
    hr_utility.trace('value = '||l_value1);
    hr_utility.trace('l_user_entity_name = '||l_user_entity_id_tab(2));
    hr_utility.trace('value = '||l_value2);

    create_archive (p_user_entity_id => l_user_entity_id_tab,
                    p_context1       => p_payroll_action_id,
                    p_value          => l_value_tab,
                    p_sequence       => l_seq_tab,
                    p_context        => l_context_val_tab,
                    p_context_id     => l_context_id_tab,
                    p_archive_level  => l_archive_level);

    l_arch_gre_step := 130;

    begin

    select substr(hoi2.org_information3,1,240),
           substr(hoi2.org_information4,1,240)
    into l_value1, l_value2
    from hr_organization_information hoi2,
         hr_organization_information hoi
    where hoi.organization_id = p_tax_unit_id
    and   hoi.org_information_context||'' = '1099R Magnetic Report Rules'
    and   hoi.org_information_context = hoi2.org_information_context
    and   hoi.org_information2 = hoi2.org_information2
    and   hoi2.org_information1 = 'Y';

    exception
    when no_data_found then
      l_value1 := null;
      l_value2 := null;
             hr_utility.trace('Error in eoy_archive_gre_data at step : ' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
    when too_many_rows then
      l_value1 := null;
      l_value2 := null;
             raise_application_error(-20001,'Error getting US_1099R_BUREAU_INDICATOR at step :  '
                                   ||to_char(l_arch_gre_step)||' - '||to_char(sqlcode) || '-' || sqlerrm);
   end;
    /* Initialise the PL/SQL tables */

    l_user_entity_id_tab.delete;
    l_value_tab.delete;
    l_seq_tab.delete;
    l_context_id_tab.delete;
    l_context_val_tab.delete;

    /* Assign values to the PL/SQL tables */

    l_arch_gre_step := 140;
    l_user_entity_id_tab(1) :=  get_user_entity_id('A_US_1099R_BUREAU_INDICATOR');
    l_user_entity_id_tab(2) :=  get_user_entity_id('A_US_1099R_COMBINED_FED_STATE_FILER');
    l_value_tab(1) := l_value1;
    l_value_tab(2) := l_value2;
    l_seq_tab(1) := 1;
    l_context_id_tab(1) := l_tax_context_id;
    l_context_val_tab(1) := p_tax_unit_id;

    l_arch_gre_step := 150;

    hr_utility.trace('l_user_entity_name = '||l_user_entity_id_tab(1));
    hr_utility.trace('value = '||l_value1);
    hr_utility.trace('l_user_entity_name = '||l_user_entity_id_tab(2));
    hr_utility.trace('value = '||l_value2);

    create_archive (p_user_entity_id => l_user_entity_id_tab,
                    p_context1       => p_payroll_action_id,
                    p_value          => l_value_tab,
                    p_sequence       => l_seq_tab,
                    p_context        => l_context_val_tab,
                    p_context_id     => l_context_id_tab,
                    p_archive_level  => l_archive_level);

   end if; /* 1099R Archive only */

   IF p_jd_type in ('ALL','FED W2 REPORTING RULES',
                     'FED W2 REPORTING RULES REARCH') then

     /* Archive the W2 Reporting Rules data */

    l_arch_gre_step := 160;

    IF p_jd_type = 'FED W2 REPORTING RULES REARCH' THEN

       l_archive_level := 'ER REARCH';

    ELSE

       l_archive_level := 'ER';

    END IF;

    begin
    select
          --hoi.org_information6  value1,
          hoi.org_information8  value2,
          hoi.org_information9  value3,
          hoi.org_information10 value4,
          hoi.org_information11 value5,
          hoi.org_information12 value6,
          hoi.org_information13 value7,
          hoi.org_information14 value8,
          hoi.org_information15 value9,
          hoi.org_information16 value10,
          --hoi.org_information2  value11,
          --hoi.org_information3  value12,
          --hoi.org_information4  value13,
          --hoi.org_information5  value14,
          --hoi.org_information7  value15, /* Job Development Fee (AL) */
          hoi.org_information1  value16,
	    hoi.org_information19 value19   -- Bug 6928011 access code (PR)
    into
           --l_value1,
           l_value2,
           l_value3,
           l_value4,
           l_value5,
           l_value6,
           l_value7,
           l_value8,
           l_value9,
           l_value10,
           --l_value11,
           --l_value12,
           --l_value13,
           --l_value14,
           --l_value15, /* Job Development Fee (AL) */
           l_value16,
	     l_value19  -- Bug 6928011 access code (PR)
    from   hr_organization_information hoi
    where  hoi.organization_id = p_tax_unit_id
    and    hoi.org_information_context || '' = 'W2 Reporting Rules';
    exception
    when no_data_found then
           --l_value1  := null;
           l_value2  := null;
           l_value3  := null;
           l_value4  := null;
           l_value5  := null;
           l_value6  := null;
           l_value7  := null;
           l_value8  := null;
           l_value9  := null;
           l_value10 := null;
           --l_value11 := null;
           --l_value12 := null;
           --l_value13 := null;
           --l_value14 := null;
           --l_value15 := null; /* Job Development Fee (AL) */
           l_value16 := null;
	     l_value19 := null; -- Bug 6928011 access code ( PR)
             hr_utility.trace('Error in eoy_archive_gre_data at step :' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
   end;


    /* Initialise the PL/SQL tables */

    l_user_entity_id_tab.delete;
    l_value_tab.delete;
    l_seq_tab.delete;
    l_context_id_tab.delete;
    l_context_val_tab.delete;

    /* Assign values to the PL/SQL tables */

    l_arch_gre_step := 170;
/*
    l_user_entity_id_tab(1) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_BLOCKING_FACTOR');
    l_user_entity_id_tab(2) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_W2_2678_FILER');
    l_user_entity_id_tab(3) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_COMPANY_NAME');
    l_user_entity_id_tab(4) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_CONTACT_NAME');
    l_user_entity_id_tab(5) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_NOTIFICATION_METHOD');
    l_user_entity_id_tab(6) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_PREPARER');
    l_user_entity_id_tab(7) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_TERMINATED_GRE_INDICATOR');
    l_user_entity_id_tab(8) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_THIRD_PARTY_SICK_PAY');
    l_user_entity_id_tab(9) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_OTHER_EIN');
    l_user_entity_id_tab(10) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_TAX_JURISDICTION');

    l_user_entity_id_tab(11) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_COMPUTER');
    l_user_entity_id_tab(12) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_INTERNAL_LABELLING');
    l_user_entity_id_tab(13) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_DENSITY');
    l_user_entity_id_tab(14) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_RECORDING_CODE');
    l_user_entity_id_tab(15) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_AL_JOB_DEVELOPMENT_FEE');
    l_user_entity_id_tab(16) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_W_2_TRANSMITTER');

    l_value_tab(1)  := l_value1;
    l_value_tab(2)  := l_value2;
    l_value_tab(3)  := l_value3;
    l_value_tab(4)  := l_value4;
    l_value_tab(5)  := l_value5;
    l_value_tab(6)  := l_value6;
    l_value_tab(7)  := l_value7;
    l_value_tab(8)  := l_value8;
    l_value_tab(9)  := l_value9;
    l_value_tab(10) := l_value10;
    l_value_tab(11) := l_value11;
    l_value_tab(12) := l_value12;
    l_value_tab(13) := l_value13;
    l_value_tab(14) := l_value14;
    l_value_tab(15) := l_value15;
    l_value_tab(16) := l_value16;
*/
    l_user_entity_id_tab(1) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_W2_2678_FILER');
    l_user_entity_id_tab(2) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_COMPANY_NAME');
    l_user_entity_id_tab(3) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_CONTACT_NAME');
    l_user_entity_id_tab(4) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_NOTIFICATION_METHOD');
    l_user_entity_id_tab(5) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_PREPARER');
    l_user_entity_id_tab(6) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_TERMINATED_GRE_INDICATOR');
    l_user_entity_id_tab(7) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_THIRD_PARTY_SICK_PAY');
    l_user_entity_id_tab(8) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_OTHER_EIN');
    l_user_entity_id_tab(9) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_TAX_JURISDICTION');
    --l_user_entity_id_tab(10) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_AL_JOB_DEVELOPMENT_FEE');
    l_user_entity_id_tab(10) :=  get_user_entity_id('A_LC_W2_REPORTING_RULES_ORG_W_2_TRANSMITTER');
    l_user_entity_id_tab(11) := get_user_entity_id ('A_LC_W2_REPORTING_RULES_ORG_ACCESS_CODE'); /* Bug 6928011 access code (PR) */

    l_value_tab(1)  := l_value2;
    l_value_tab(2)  := l_value3;
    l_value_tab(3)  := l_value4;
    l_value_tab(4)  := l_value5;
    l_value_tab(5)  := l_value6;
    l_value_tab(6)  := l_value7;
    l_value_tab(7)  := l_value8;
    l_value_tab(8)  := l_value9;
    l_value_tab(9) := l_value10;
    --l_value_tab(10) := l_value15; /* Job Development Fee (AL) */
    l_value_tab(10) := l_value16;
    l_value_tab(11) := l_value19; /* Bug 6928011 access code (PR) */

    l_seq_tab(1) := 1;
    l_context_id_tab(1) := l_tax_context_id;
    l_context_val_tab(1) := p_tax_unit_id;

    l_arch_gre_step := 180;

    create_archive (p_user_entity_id => l_user_entity_id_tab,
                    p_context1       => p_payroll_action_id,
                    p_value          => l_value_tab,
                    p_sequence       => l_seq_tab,
                    p_context        => l_context_val_tab,
                    p_context_id     => l_context_id_tab,
                    p_archive_level  => l_archive_level);

  end if; /* W2 Reporting Rules */

    IF p_jd_type in ('ALL','FEDERAL TAX RULES'
                     ,'FEDERAL TAX RULES REARCH') then
       l_arch_gre_step := 190;

    IF p_jd_type = 'FEDERAL TAX RULES REARCH' THEN

       l_archive_level := 'ER REARCH';

    ELSE

       l_archive_level := 'ER';

    END IF;
    l_arch_gre_step := 191;

     begin
       select hoi.org_information4  value1,
              hoi.org_information8  value2
         into l_value1,
              l_value2
         from hr_organization_information hoi
        where hoi.organization_id = p_tax_unit_id
          and hoi.org_information_context || '' = 'Federal Tax Rules';
       exception
         when no_data_found then
              l_value1  := null;
              l_value2  := null;
             hr_utility.trace('Error in eoy_archive_gre_data at step : ' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
       end;

       l_user_entity_id_tab.delete;
       l_value_tab.delete;
       l_seq_tab.delete;
       l_context_id_tab.delete;
       l_context_val_tab.delete;

       /* Assign values to the PL/SQL tables */

       l_arch_gre_step := 200;
       l_user_entity_id_tab(1) :=  get_user_entity_id('A_LC_FEDERAL_TAX_RULES_ORG_TYPE_OF_EMPLOYMENT');
       l_value_tab(1) := l_value1;
       l_seq_tab(1) := 1;
       l_context_id_tab(1) := l_tax_context_id;
       l_context_val_tab(1) := p_tax_unit_id;

       l_arch_gre_step := 201;
       l_user_entity_id_tab(2) :=  get_user_entity_id('A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER');
       l_value_tab(2) := l_value2;

       hr_utility.trace('A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER '||l_user_entity_id_tab(2));
       hr_utility.trace('Value for A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER '||l_value_tab(2));

       l_arch_gre_step := 210;
       create_archive (p_user_entity_id => l_user_entity_id_tab,
                       p_context1       => p_payroll_action_id,
                       p_value          => l_value_tab,
                       p_sequence       => l_seq_tab,
                       p_context        => l_context_val_tab,
                       p_context_id     => l_context_id_tab,
                       p_archive_level  => l_archive_level);
     end if;

  IF p_jd_type in ('ALL','STATE TAX RULES','STATE TAX RULES REARCH') then

    /* Archive the state information for all the states
       in the GRE, for which the state tax rules have been
       maintained under the 'State Tax Rules' */

    l_arch_gre_step := 220;

    IF p_jd_type = 'STATE TAX RULES REARCH' THEN

       l_archive_level := 'ER REARCH';

    ELSE

       l_archive_level := 'ER';

    END IF;


    l_fips_uid := get_user_entity_id('A_FIPS_CODE_JD');
    l_sit_uid :=  get_user_entity_id('A_STATE_TAX_RULES_ORG_SIT_COMPANY_STATE_ID');
    l_sui_uid :=  get_user_entity_id('A_STATE_TAX_RULES_ORG_SUI_COMPANY_STATE_ID');

    /* Initialise the PL/SQL tables */

    l_user_entity_id_tab.delete;
    l_value_tab.delete;
    l_seq_tab.delete;
    l_context_id_tab.delete;
    l_context_val_tab.delete;

    l_arch_gre_step := 230;

     for c_state in c_get_state_code
     loop

        l_arch_gre_step := 240;
        /* Archive the FIPS Code for a state code */
        /* Archive the company SIT state id */
        /* Archive the company SUI state id */

        begin
          select to_char(rules.fips_code)              value1,
                 ltrim(rtrim(target.org_information3)) value2,
                 ltrim(rtrim(target.org_information2)) value3
            into l_value1,
                 l_value2,
                 l_value3
            from pay_state_rules rules,
                 pay_us_states pus,
                 hr_organization_information target
            where substr(rules.jurisdiction_code, 1, 2) = c_state.state_code
              and target.organization_id = p_tax_unit_id
              and target.org_information_context || '' = 'State Tax Rules'
              and target.org_information1 = pus.state_abbrev
              and pus.state_code = c_state.state_code;
            exception
            when no_data_found then
              l_value1 := null;
              l_value2 := null;
              l_value3 := null;
             hr_utility.trace('Error in eoy_archive_gre_data at step : ' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
        end;

        l_user_entity_id_tab.delete;
        l_value_tab.delete;
        l_seq_tab.delete;
        l_context_id_tab.delete;
        l_context_val_tab.delete;

        /* Assign values to the PL/SQL tables */

        l_user_entity_id_tab(1) := l_fips_uid;
        l_user_entity_id_tab(2) := l_sit_uid;
        l_user_entity_id_tab(3) := l_sui_uid;
        l_value_tab(1)          := l_value1;
        l_value_tab(2)          := l_value2;
        l_value_tab(3)          := l_value3;
        l_seq_tab(1)            := 1;
        l_context_id_tab(1)     := l_tax_context_id;
        l_context_val_tab(1)    := p_tax_unit_id;
        l_seq_tab(2)            := 2;
        l_context_id_tab(2)     := l_jursd_context_id;
        l_context_val_tab(2)    := c_state.state_code || '-000-0000';

        l_arch_gre_step := 250;

        create_archive (p_user_entity_id => l_user_entity_id_tab,
                        p_context1       => p_payroll_action_id,
                        p_value          => l_value_tab,
                        p_sequence       => l_seq_tab,
                        p_context        => l_context_val_tab,
                        p_context_id     => l_context_id_tab,
                        p_archive_level  => l_archive_level);
     end loop;
  END IF; /* State Archive */

   g_archive_flag := 'Y';

  exception
     when others then
          g_archive_flag := 'N';
           Raise_application_error(-20001,'Error in eoy_archive_gre_data after step : ' ||
                             to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
  end eoy_archive_gre_data;

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
               where fai.context1 = p_payroll_action_id);
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

 /* Name      : eoy_archinit
    Purpose   : This performs the context initialization for the year end
                pre-process.
    Arguments :
    Notes     :
 */

 procedure eoy_archinit(p_payroll_action_id in number) is

 l_jurisdiction_code                VARCHAR2(30);
 l_tax_unit_id                      NUMBER(15);
 l_archive                          boolean:= FALSE;
 l_formula_name                     ff_formulas_f.formula_name%TYPE;
 l_step                             number;
 ld_end_date          DATE;
 ld_start_date        DATE;
 ln_business_group_id NUMBER;
 ln_person_id         NUMBER := 0;
 ln_asg_set           NUMBER := 0;
 ln_ssn               NUMBER;
 ln_year              NUMBER := 0;

 cursor c_get_min_chunk is
 select min(paa.chunk_number)
 from pay_assignment_actions paa
 where paa.payroll_action_id = p_payroll_action_id;


begin

     --hr_utility.trace_on(null,'PYUSARCH_DBG');

     hr_utility.set_location ('eoy_archinit',1);


     l_jurisdiction_code := '99-999-9999';

      /* Check to see if all the relevant formulas have been compiled */
     l_step := 1;


     begin
      select ff.formula_name
             into l_formula_name
        from ff_formulas_f     ff,
             ff_compiled_info_f fci
       where ff.formula_name = 'US_YEP_BOX_12'
         and fci.formula_id = ff.formula_id;
     exception
        when no_data_found then
           raise_application_error(-20001,'eoy_archinit:US_YEP_BOX_12 formula not compiled');
     end;


     l_step := 2;
     begin
      select ff.formula_name
             into l_formula_name
        from ff_formulas_f     ff,
             ff_compiled_info_f fci
       where ff.formula_name = 'US_YEP_BOX_14'
         and fci.formula_id = ff.formula_id;
     exception
        when no_data_found then
           raise_application_error(-20001,'eoy_archinit:US_YEP_BOX_14 formula not compiled');
     end;

     l_step := 3;
     begin
      select ff.formula_name
             into l_formula_name
        from ff_formulas_f     ff,
             ff_compiled_info_f fci
       where ff.formula_name = 'US_YEP_FEDERAL'
         and fci.formula_id = ff.formula_id;
     exception
        when no_data_found then
           raise_application_error(-20001,'eoy_archinit:US_YEP_FEDERAL formula not compiled');
     end;

     l_step := 4;
     begin
      select ff.formula_name
             into l_formula_name
        from ff_formulas_f     ff,
             ff_compiled_info_f fci
       where ff.formula_name = 'US_YEP_LOCALITY'
         and fci.formula_id = ff.formula_id;
     exception
        when no_data_found then
           raise_application_error(-20001,'eoy_archinit:US_YEP_LOCALITY formula not compiled');
     end;

     l_step := 5;
     begin
      select ff.formula_name
             into l_formula_name
        from ff_formulas_f     ff,
             ff_compiled_info_f fci
       where ff.formula_name = 'US_YEP_STATE'
         and fci.formula_id = ff.formula_id;
     exception
        when no_data_found then
           raise_application_error(-20001,'eoy_archinit:US_YEP_STATE formula not compiled');
     end;

     l_step := 6;
     pay_balance_pkg.set_context ('JURISDICTION_CODE',l_jurisdiction_code);

      hr_utility.set_location ('eoy_archinit',2);

      /* Get the tax unit id and set it up as the context */
      l_step := 7;
/*
     pay_us_archive.g_report_type := pay_us_archive.get_report_type(p_payroll_action_id);
     if g_report_type <> 'W2C_PRE_PROCESS' then

        select to_number(substr(legislative_parameters,
        instr(legislative_parameters,'TRANSFER_GRE=')+ length('TRANSFER_GRE='))),
         business_group_id
         into l_tax_unit_id,
              ln_business_group_id
         from pay_payroll_actions
        where payroll_action_id = p_payroll_action_id;

      else

      get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_tax_unit_id       => l_tax_unit_id
                            ,p_person_id         => ln_person_id
                            ,p_ssn               => ln_ssn
                            ,p_asg_set           => ln_asg_set
                            ,p_year              => ln_year
                            ,p_creation_date     => g_pact_creation_date);


      end if;
*/

      get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_tax_unit_id       => l_tax_unit_id
                            ,p_person_id         => ln_person_id
                            ,p_ssn               => ln_ssn
                            ,p_asg_set           => ln_asg_set
                            ,p_year              => ln_year
                            ,p_creation_date     => g_pact_creation_date);


      hr_utility.set_location ('eoy_archinit',3);

      l_step := 8;
      pay_balance_pkg.set_context ('TAX_UNIT_ID',l_tax_unit_id);

      l_step := 9;
      hr_utility.set_location ('eoy_archinit getting min chunk number',10);

      open c_get_min_chunk;
      fetch c_get_min_chunk into g_min_chunk;
         l_step := 10;
         if c_get_min_chunk%NOTFOUND then
           g_min_chunk := -1;
           raise_application_error(-20001,'eoy_archinit: Assignment actions not created!!!');
         end if;
      close c_get_min_chunk;

      hr_utility.set_location ('eoy_archinit min chunk is ' || to_char(g_min_chunk),12);
      l_step := 11;
      l_archive := chk_gre_archive(p_payroll_action_id);

      l_step := 12;
      hr_utility.trace ('eoy_archinit g_archive_flag is ' || g_archive_flag);

      pay_us_archive.g_report_type := pay_us_archive.get_report_type(p_payroll_action_id);
      pay_us_archive.g_puerto_rico_gre        := pay_us_archive.get_puerto_rico_info(l_tax_unit_id) ;
      pay_us_archive.g_1099R_transmitter_code := pay_us_archive.get_1099r_info(l_tax_unit_id) ;
      pay_us_archive.g_pre_tax_info           := pay_us_archive.get_pre_tax_info(l_tax_unit_id,
                                                                              ln_business_group_id) ;
      if pay_us_sqwl_udf.chk_govt_employer(p_tax_unit_id =>l_tax_unit_id) then
        pay_us_archive.g_govt_employer  := 'Y';
      else
        pay_us_archive.g_govt_employer  := 'N';
      end if;


      l_step := 13;

      select context_id
      into g_jursd_context_id
      from ff_contexts
      where context_name = 'JURISDICTION_CODE';

      select context_id
      into g_tax_unit_context_id
      from ff_contexts
      where context_name = 'TAX_UNIT_ID';

      /* get the user_entity_id of the dbis A_STATE_ABBREV, A_COUNTY_NAME,
         A_CITY_NAME, A_COUNTY_SD_NAME and A_CITY_SD_NAME */

      l_step := 14;

      g_state_uei :=  get_user_entity_id('A_STATE_ABBREV');

      l_step := 15;

      g_county_uei :=  get_user_entity_id('A_COUNTY_NAME');

      l_step := 16;

      g_city_uei :=  get_user_entity_id('A_CITY_NAME');

      l_step := 17;

      g_county_sd_uei :=  get_user_entity_id('A_COUNTY_SD_NAME');

      l_step := 18;

      g_city_sd_uei :=  get_user_entity_id('A_CITY_SD_NAME');

      l_step := 19;

      g_per_marital_status := get_user_entity_id('A_PER_MARITAL_STATUS');

      l_step := 20;

      g_con_national_identifier := get_user_entity_id('A_CON_NATIONAL_IDENTIFIER');

      l_step := 21;

      g_taxable_amount_unknown := get_user_entity_id('A_TAXABLE_AMOUNT_UNKNOWN');

      l_step := 22;

      g_total_distributions := get_user_entity_id('A_TOTAL_DISTRIBUTIONS');

      l_step := 23;

      g_emp_distribution_percent := get_user_entity_id('A_EMPLOYEE_DISTRIBUTION_PERCENT');

      l_step := 24;

      g_total_distribution_percent := get_user_entity_id('A_TOTAL_DISTRIBUTION_PERCENT');

      l_step := 25;

      g_distribution_code_for_1099r := get_user_entity_id('A_DISTRIBUTION_CODE_FOR_1099R');

      l_step := 26;
      -- Added For bug# 5517938
      g_first_yr_roth_contrib := get_user_entity_id('A_FIRST_YEAR_ROTH_CONTRIB');

      -- Bug 4544792
      -- g_disability_plan_id := get_user_entity_id('A_EXTRA_ASSIGNMENT_INFORMATION_PAY_US_DISABILITY_PLAN_INFO_DF_PLAN_ID');

      g_disability_plan_id := get_user_entity_id('A_SCL_ASG_US_NJ_PLAN_ID');
      g_nj_flipp_id := get_user_entity_id('A_SCL_ASG_US_FLIPP_ID');
      l_step := 27;

      g_archive_date := get_user_entity_id('A_ARCHIVE_DATE');

      l_step := 28;

      g_w2_corrected := get_user_entity_id('A_W2_CORRECTED');

      l_step := 29;

      g_view_online_w2 := get_user_entity_id('A_VIEW_ONLINE_W2');


  exception
   when others then
        raise_application_error(-20001,'eoy_archinit at '
                                   ||to_char(l_step)||' - '||to_char(sqlcode) || '-' || sqlerrm);
end eoy_archinit;

  /* Name      : delete_ff_archive
     Purpose   : Delete from ff_archive and context
     Arguments :
     Notes     :
  */

PROCEDURE delete_ff_archive (p_context number,
                             p_archive_name IN VARCHAR2) IS

CURSOR c_get_ff_arch IS
    select fai.archive_item_id
    from ff_archive_items fai,
         ff_user_entities fue
    where context1 =p_context
    and fai.user_entity_id = fue.user_entity_id
    and user_entity_name = p_archive_name ;

 l_archive_itemid NUMBER;

BEGIN
    hr_utility.trace('p_archive_name '||p_archive_name);
    hr_utility.trace('context1 '||p_context);

    OPEN c_get_ff_arch;
    FETCH c_get_ff_arch INTO l_archive_itemid;
    CLOSE c_get_ff_arch;


    hr_utility.trace('l_archive_itemid '||l_archive_itemid);

    delete from ff_archive_item_contexts
    where archive_item_id = l_archive_itemid;

    delete from ff_archive_items
    where archive_item_id = l_archive_itemid;

END;

  /* Name      : print_w2_corrected
     Purpose   : Returns if 'corrected; should be printed on W-2
     Arguments :
     Notes     :
  */
Function print_w2_corrected (l_payroll_action_id IN number
                             ,p_assactid    IN NUMBER
                             ,l_taxunitid   IN NUMBER)
RETURN VARCHAR2 IS
  l_corrected_date VARCHAR2(20);
  l_profile_date   VARCHAR2(20);
  l_add_archive    VARCHAR2(10);
BEGIN

        l_corrected_date := fnd_date.canonical_to_date(
                             substr(fnd_date.date_to_canonical(sysdate),1,10));
        hr_utility.trace('Archive Date : ' || l_corrected_date);

        l_profile_date := fnd_date.canonical_to_date(
                      pay_us_archive_util.get_archive_value(l_payroll_action_id,
                                                       'A_VIEW_ONLINE_W2',
                                                        l_taxunitid));


        l_add_archive :=    pay_us_archive_util.get_archive_value(p_assactid,
                                                       'A_ADD_ARCHIVE',
                                                        l_taxunitid);


         hr_utility.trace('View Online W2 Profile date'||l_profile_date);
         hr_utility.trace('l_add_archive '||l_add_archive);

         IF nvl(l_add_archive,'N') = 'Y' THEN
             delete_ff_archive(p_assactid,'A_ADD_ARCHIVE');
             return 'N';
         ELSIF g_pact_creation_date = l_corrected_date THEN
             return '';
         ELSIF l_corrected_date > l_profile_date THEN
             return 'Y';
         END IF;

         RETURN '';
END;

  /* Name      : eoy_archive_data
     Purpose   : This performs the US specific employee context setting for the
                 Year End PreProcess.
     Arguments :
     Notes     :
  */

procedure eoy_archive_data(p_assactid in number, p_effective_date in date) is

    l_aaid                     pay_assignment_actions.assignment_action_id%type;
    l_aaseq                    pay_assignment_actions.action_sequence%type;
    l_asgid                    pay_assignment_actions.assignment_id%type;
    l_date_earned              date;
    l_taxunitid                pay_assignment_actions.tax_unit_id%type;
    l_year_start               date;
    l_year_end                 date;
    l_context_no               number := 60;
    l_count                    number := 0;
    l_jurisdiction             varchar2(11);
    l_state_uei                ff_user_entities.user_entity_id%type;
    l_county_uei               ff_user_entities.user_entity_id%type;
    l_city_uei                 ff_user_entities.user_entity_id%type;
    l_county_sd_uei            ff_user_entities.user_entity_id%type;
    l_city_sd_uei              ff_user_entities.user_entity_id%type;
    l_state_abbrev             pay_us_states.state_abbrev%type;
    l_county_name              pay_us_counties.county_name%type;
    l_city_name                pay_us_city_names.city_name%type;
    l_cnt_sd_name              pay_us_county_school_dsts.school_dst_name%type;
    l_cty_sd_name              pay_us_city_school_dsts.school_dst_name%type;
    l_step                     number := 0;
    l_county_code              varchar2(3);
    l_city_code                varchar2(4);
    l_person_id                per_people_f.person_id%type;
    l_jursd_context_id         ff_contexts.context_id%type;
    l_user_entity_id_tab       pay_us_archive.number_data_type_table;
    l_user_entity_tab          pay_us_archive.char240_data_type_table;
    l_defined_balance_id_tab   pay_us_archive.number_data_type_table;
    l_value_tab                pay_us_archive.char240_data_type_table;
    l_balance_feed_tab         pay_us_archive.char240_data_type_table;
    l_seq_tab                  pay_us_archive.number_data_type_table;
    l_context_id_tab           pay_us_archive.number_data_type_table;
    l_context_val_tab          pay_us_archive.char240_data_type_table;
    --l_jd_done_tab              pay_us_archive.char240_data_type_table;
    --l_jd_name_done_tab         pay_us_archive.char240_data_type_table;
    l_chunk                    number;
    l_payroll_action_id        number;
    l_chk_state_archive        varchar2(1);
    l_chk_county_archive       varchar2(1);
    l_chk_cnt_sd_archive       varchar2(1);
    l_chk_city_sd_archive      varchar2(1);
    l_true                     varchar2(1);
    l_marital_status           per_people_f.marital_status%type;
    l_con_national_identifier  per_people_f.national_identifier%type;
    l_archive_item_id          ff_archive_items.archive_item_id%type;
    l_object_version_number    number(9);
    l_some_warning             boolean;
    lv_value                   ff_archive_items.value%type := null;
    l_taxable_amount_unknown   varchar(150) := null;
    l_total_distributions      varchar(150) := null;
    l_ee_distribution_percent  varchar(150) := null;
    l_total_distribution_percent varchar(150) := null;
    l_index  number := 0;
    lv_medicare_withheld       number;
    lv_ss_withheld             number;
    l_tax_unit_context_id      number;
    l_disability_plan_id       varchar2(150) := null;
    l_nj_flipp_id              varchar2(150) := null;
    l_distribution_code        varchar2(150) := '7'; /* Default it to 7,Normaldistribution code */
    l_first_yr_roth_contrib    varchar2(10); -- Bug# 5517938
    l_mesg                     varchar(50);

    l_jd_index                 number := 0;
    l_add_archive              varchar2(10);
    --
    -- Following variables Added For Bug# 5517938
    -- reverting back changes for Bug# 5517938

    /* Get the jurisdiction code of all the cities
       for the person_id corresponding to the
       assignment_id */


    cursor c_get_city is
     select distinct pcty.jurisdiction_code pcty
     from   pay_us_city_tax_info_f cti,
            pay_us_emp_city_tax_rules_f pcty,
            per_all_assignments_f paf1
   where    paf1.person_id = l_person_id
     and    paf1.effective_end_date >= l_year_start
     and    paf1.effective_start_date <= l_year_end
     and    pcty.assignment_id = paf1.assignment_id
     and    pcty.effective_start_date <= l_year_end
     and    pcty.effective_end_date >= l_year_start
     and    substr(pcty.city_code,1,1) <> 'U'
     and    pcty.jurisdiction_code = cti.jurisdiction_code
     and    ( cti.city_tax = 'Y'
     or       cti.head_tax = 'Y') /* 7628554 */
     and    cti.effective_start_date <= l_year_end
     and    cti.effective_end_date >= l_year_start;

    /* Get the jurisdiction code of all the counties
       for the person_id corresponding to the assignment_id */
/*
    cursor c_get_county is
     select distinct pcnt.jurisdiction_code
     from   pay_us_emp_county_tax_rules_f pcnt,
            per_all_assignments_f paf1
     where  paf1.person_id = l_person_id
     and    paf1.effective_end_date >= l_year_start
     and    paf1.effective_start_date <= l_year_end
     and    pcnt.assignment_id = paf1.assignment_id
     and    pcnt.effective_start_date <= l_year_end
     and    pcnt.effective_end_date >= l_year_start;
*/

    cursor c_get_county is
     select distinct pcnt.jurisdiction_code
     from   pay_us_county_tax_info_f cnti,
            pay_us_emp_county_tax_rules_f pcnt,
            per_all_assignments_f paf1
     where  paf1.person_id = l_person_id
     and    paf1.effective_end_date >= l_year_start
     and    paf1.effective_start_date <= l_year_end
     and    pcnt.assignment_id = paf1.assignment_id
     and    pcnt.effective_start_date <= l_year_end
     and    pcnt.effective_end_date >= l_year_start
     and    pcnt.jurisdiction_code = cnti.jurisdiction_code
     and    cnti.county_tax = 'Y'
     and    cnti.effective_start_date <= l_year_end
     and    cnti.effective_end_date >= l_year_start;


    /* Get the jurisdiction code of all the states
       for the person_id corresponding to the assignment_id */
/*
    cursor c_get_state is
     select distinct pst.jurisdiction_code
     from   pay_us_state_tax_info_f sti,
            pay_us_emp_state_tax_rules_f pst,
            per_all_assignments_f paf1
     where  paf1.person_id = l_person_id
     and    paf1.effective_end_date >= l_year_start
     and    paf1.effective_start_date <= l_year_end
     and    paf1.assignment_id = pst.assignment_id
     and    pst.effective_start_date <= l_year_end
     and    pst.effective_end_date >= l_year_start
     and    sti.state_code = pst.state_code
     and    sti.sit_exists = 'Y'
     and    sti.effective_start_date <= l_year_end
     and    sti.effective_end_date >= l_year_start;
*/

    cursor c_get_state is
     select distinct pst.jurisdiction_code
     from   pay_us_emp_state_tax_rules_f pst,
            per_all_assignments_f paf1
     where  paf1.person_id = l_person_id
     and    paf1.effective_end_date >= l_year_start
     and    paf1.effective_start_date <= l_year_end
     and    paf1.assignment_id = pst.assignment_id
     and    pst.effective_start_date <= l_year_end
     and    pst.effective_end_date >= l_year_start;

    cursor c_get_cnt_sd is
     select distinct pcnt.state_code || '-'|| pcnt.school_district_code,
            pcnt.county_code
     from   pay_us_emp_county_tax_rules_f pcnt,
            per_all_assignments_f paf1
     where  paf1.person_id = l_person_id
     and    paf1.effective_end_date >= l_year_start
     and    paf1.effective_start_date <= l_year_end
     and    paf1.assignment_id = pcnt.assignment_id
     and    pcnt.school_district_code is not null
     and    pcnt.effective_start_date <= l_year_end
     and    pcnt.effective_end_date >= l_year_start;

    cursor c_get_cty_sd is
     select distinct pcty.state_code || '-'|| pcty.school_district_code,
            county_code,
            city_code
     from   pay_us_emp_city_tax_rules_f pcty,
            per_all_assignments_f paf1
     where  paf1.person_id = l_person_id
     and    paf1.effective_end_date >= l_year_start
     and    paf1.effective_start_date <= l_year_end
     and    pcty.assignment_id = paf1.assignment_id
     and    pcty.school_district_code is not null
     and    pcty.effective_start_date <= l_year_end
     and    pcty.effective_end_date >= l_year_start;

 -- Bug 5696031
 -- Modified the cursor to remove the order by clause that was there before.
 -- The select clause has been modified to get the Assignment Action ID
 -- associated with Maximum Action Sequence
 CURSOR c_get_latest_asg(p_person_id number ) IS
            select fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')
                                                 ||lpad(paa.assignment_action_id,15,'0')),16))
              from pay_assignment_actions     paa,
                   per_all_assignments_f      paf,
                   pay_payroll_actions        ppa,
                   pay_action_classifications pac
             where paf.person_id     = p_person_id
               and paa.assignment_id = paf.assignment_id
               and paa.tax_unit_id   = l_taxunitid
               and paa.payroll_action_id = ppa.payroll_action_id
               and ppa.action_type = pac.action_type
               and pac.classification_name = 'SEQUENCED'
               and ppa.effective_date +0 between paf.effective_start_date
                                           and paf.effective_end_date
               and ppa.effective_date +0 between l_year_start and
                                               l_year_end
               and ((nvl(paa.run_type_id, ppa.run_type_id) is null
               and  paa.source_action_id is null)
                or (nvl(paa.run_type_id, ppa.run_type_id) is not null
               and paa.source_action_id is not null )
               or (ppa.action_type = 'V' and ppa.run_type_id is null
                    and paa.run_type_id is not null
                    and paa.source_action_id is null));

       CURSOR c_get_1099_eit_info(cp_assignment_id in number ) IS
        select aei_information1,
               aei_information2,
               aei_information3,
               aei_information4
         from  per_assignment_extra_info
        where information_type =  'PAY_US_PENSION_REPORTING'
          and assignment_id = cp_assignment_id;

       CURSOR c_get_1099_distribution_info(cp_person_id in number,
                                           cp_tax_unit_id in number) IS
       select pei_information2
       from  per_people_extra_info target
       where person_id = cp_person_id
       and target.pei_information1 = cp_tax_unit_id
       and information_type= 'PAY_US_PENSION_REPORTING';

       --
       --
       CURSOR c_get_first_yr_roth_contrib(cp_person_id in number,
                                          cp_tax_unit_id in number) IS
       select pei_information3
       from  per_people_extra_info target
       where person_id = cp_person_id
       and target.pei_information1 = cp_tax_unit_id
       and information_type= 'PAY_US_PENSION_REPORTING';

       CURSOR c_get_disability_plan_scl_info(cp_assignment_id in number , cp_tax_unit_id in number) IS
       select hsck.segment19
         from per_all_assignments_f paf , hr_soft_coding_keyflex hsck
        where assignment_id = cp_assignment_id and
              paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id and
              hsck.segment1 = to_char(cp_tax_unit_id) and
	      paf.effective_end_date = (select max(effective_end_date)
                                          from per_all_assignments_f paf1 , hr_soft_coding_keyflex hsck1
                                         where paf1.assignment_id = paf.assignment_id and
                                               paf1.soft_coding_keyflex_id = hsck1.soft_coding_keyflex_id and
                                               hsck1.segment1 =  hsck.segment1);

       /* Bug # 8251746 */
       CURSOR c_get_flipp_scl_info(cp_assignment_id in number , cp_tax_unit_id in number) IS
       select hsck.segment20
         from per_all_assignments_f paf , hr_soft_coding_keyflex hsck
        where assignment_id = cp_assignment_id and
              paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id and
              hsck.segment1 = to_char(cp_tax_unit_id) and
	      paf.effective_end_date = (select max(effective_end_date)
                                          from per_all_assignments_f paf1 , hr_soft_coding_keyflex hsck1
                                         where paf1.assignment_id = paf.assignment_id and
                                               paf1.soft_coding_keyflex_id = hsck1.soft_coding_keyflex_id and
                                               hsck1.segment1 =  hsck.segment1);

/* This cursor is removed because now the NJ Disablily Plan ID will be stored in segment19 of
   Soft Coded KFF.
       CURSOR c_get_disability_plan_eit_info(cp_assignment_id in number) IS
        select aei_information1
         from  per_assignment_extra_info
        where information_type =  'PAY_US_DISABILITY_PLAN_INFO'
          and assignment_id = cp_assignment_id;
*/

-- Adding the Following Cursor to Archive
-- Year of Designated Roth Contribution

          CURSOR c_prior_def_yr_roth(cp_asg_act_id IN NUMBER
                                    ,cp_asg_id IN NUMBER
                                    ,cp_ele_info1 IN VARCHAR2) IS
          SELECT TARGET.result_value
            FROM pay_assignment_actions  BAL_ASSACT
          ,      pay_payroll_actions     BACT
          ,      per_all_assignments_f   ASS
          ,      pay_assignment_actions  ASSACT
          ,      pay_payroll_actions     PACT
          ,      pay_run_results         RR
          ,      pay_run_result_values   TARGET
          ,      pay_input_values_f      PIV
          ,      pay_element_entries_f   peef
          ,      pay_element_types_f     petf
        where  BAL_ASSACT.assignment_action_id = cp_asg_act_id
        and    ASS.assignment_id = cp_asg_id
        and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
        and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
        and    ASSACT.assignment_id = ASS.assignment_id
        and    ASSACT.payroll_action_id = PACT.payroll_action_id
        and    RR.assignment_action_id = ASSACT.assignment_action_id
        and    TARGET.run_result_id    = RR.run_result_id
        and    TARGET.input_value_id = PIV.input_value_id
        and    PIV.NAME = 'Year of Prior Deferral'
        and    RR.element_entry_id = peef.element_entry_id
        and    RR.entry_type = 'E'
        and    peef.element_type_id = petf.element_type_id
        and    petf.element_information_category = 'US_VOLUNTARY DEDUCTIONS'
        and    petf.element_information1 = cp_ele_info1
        and    PACT.effective_date between PIV.effective_start_date
                                       and PIV.effective_end_date
        and    PACT.effective_date between peef.effective_start_date
                                       and peef.effective_end_date
        and    PACT.effective_date between petf.effective_start_date
                                       and petf.effective_end_date
        and    RR.status in ('P','PA')
        and    ASSACT.assignment_id = ASS.assignment_id
        and    ASS.person_id = (select person_id from per_all_assignments_f START_ASS
                                where START_ASS.assignment_id = BAL_ASSACT.assignment_id
                                and rownum = 1)
        and    PACT.effective_date between ASS.effective_start_date
                                    and ASS.effective_end_date;

  begin

      --hr_utility.trace_on(null,'yepp');

      hr_utility.trace('.....AAID is ' || to_char(p_assactid));

      hr_utility.trace('Archive Data');
      hr_utility.set_location ('archive_data',1);
      hr_utility.trace('getting assignment');

      l_step := 1;

      SELECT aa.assignment_id,
            pay_magtape_generic.date_earned (p_effective_date,aa.assignment_id),
            aa.tax_unit_id,
            aa.chunk_number,
            aa.payroll_action_id,
            to_number(aa.serial_number)
            into l_asgid,
                 l_date_earned,
                 l_taxunitid,
                 l_chunk,
                 l_payroll_action_id,
                 l_person_id
        FROM pay_assignment_actions aa
        WHERE aa.assignment_action_id = p_assactid;

        /* If the chunk of the assignment is same as the minimun chunk
           for the payroll_action_id and the gre data has not yet been
           archived then archive the gre data i.e. the employer data */

        l_step := 2;

        hr_utility.trace('Chunk Number is : ' || to_char(l_chunk));

        if l_chunk = g_min_chunk and g_archive_flag = 'N' then

           l_step := 3;
           hr_utility.trace('eoy_archive_data archiving employer data');

           if g_report_type <> 'W2C_PRE_PROCESS' then

              eoy_archive_gre_data(
                               p_payroll_action_id => l_payroll_action_id,
                               p_tax_unit_id        => l_taxunitid,
                               p_jd_type            => 'ALL',
                               p_state_code         => 'ALL');
           else
              g_archive_flag := 'Y';
           end if ;

           l_step := 4;
           hr_utility.trace('eoy_archive_data archived employer data');
        end if;

      hr_utility.set_location ('archive_data',2);

      hr_utility.trace('assignment  '|| to_char(l_asgid));
      hr_utility.trace('person id   '|| to_char(l_person_id));
      hr_utility.trace('date_earned '|| to_char(l_date_earned));
      hr_utility.trace('tax_unit_id '|| to_char(l_taxunitid));

      /* Derive the beginning and end of the effective year */

      hr_utility.trace('getting begin and end dates');

      l_step := 5;

      l_year_start := trunc(p_effective_date, 'Y');
      l_year_end   := add_months(trunc(p_effective_date, 'Y'),12) - 1;

      hr_utility.trace('year start '|| to_char(l_year_start));
      hr_utility.trace('year end '|| to_char(l_year_end));

      open c_get_latest_asg(l_person_id );
      fetch c_get_latest_asg into l_aaid;
         hr_utility.trace('l_aaid in archive code '||to_char(l_aaid));
      close c_get_latest_asg;


      /* Initialise the PL/SQL table before populating it */

      hr_utility.trace('Initialising Pl/SQL table');

      l_step := 6;

      for i in 1..l_context_no loop

          pay_archive.g_context_values.name(i) := NULL;
          pay_archive.g_context_values.value(i) := NULL;

      end loop;

      pay_archive.g_context_values.sz := 0;

      /* Set up the assignment id, date earned and tax unit id contexts */

      l_step := 7;

      l_count := l_count + 1;
      pay_archive.g_context_values.name(l_count) := 'ASSIGNMENT_ID';
      pay_archive.g_context_values.value(l_count) := l_asgid;
      l_count := l_count + 1;
      pay_archive.g_context_values.name(l_count) := 'DATE_EARNED';
      pay_archive.g_context_values.value(l_count) := fnd_date.date_to_canonical(l_date_earned);
      l_count := l_count + 1;
      pay_archive.g_context_values.name(l_count) := 'TAX_UNIT_ID';
      pay_archive.g_context_values.value(l_count) := l_taxunitid;

      hr_utility.trace('Initialised Pl/SQL table');

      /* Get the context_id for 'Jurisdiction' from ff_contexts */

      l_step := 8;
/*
      select context_id
      into l_jursd_context_id
      from ff_contexts
      where context_name = 'JURISDICTION_CODE';

      select context_id
      into l_tax_unit_context_id
      from ff_contexts
      where context_name = 'TAX_UNIT_ID';
*/

      /* get the user_entity_id of the dbis A_STATE_ABBREV, A_COUNTY_NAME,
         A_CITY_NAME, A_COUNTY_SD_NAME and A_CITY_SD_NAME */
/*
      l_step := 9;

      l_state_uei :=  get_user_entity_id('A_STATE_ABBREV');

      l_step := 10;

      l_county_uei :=  get_user_entity_id('A_COUNTY_NAME');

      l_step := 11;

      l_city_uei :=  get_user_entity_id('A_CITY_NAME');

      l_step := 12;

      l_county_sd_uei :=  get_user_entity_id('A_COUNTY_SD_NAME');

      l_step := 13;

      l_city_sd_uei :=  get_user_entity_id('A_CITY_SD_NAME');
*/

      l_step := 14;
      /* Now, set up the jurisdiction context for the db items that
         need the jurisdiction as a context */

      l_true := 'N';
      open c_get_city;
      loop

          hr_utility.trace('In city loop ');

          l_step := 15;

          fetch c_get_city into l_jurisdiction;
          exit when c_get_city%NOTFOUND;

          hr_utility.trace('assignment  '|| to_char(l_asgid));
          hr_utility.trace('City JD is ' || l_jurisdiction);

          l_step := 16;

          l_count := l_count + 1;
          pay_archive.g_context_values.name(l_count) := 'JURISDICTION_CODE';
          pay_archive.g_context_values.value(l_count) := l_jurisdiction;

          /* Insert rows into ff_archive_items and ff_archive_item_contexts
             for the city, county and state */

          l_step := 17;

          l_jd_index := replace(l_jurisdiction,'-');

          if l_jd_name_done_tab.exists(l_jd_index) then

             l_city_name := l_jd_name_done_tab(l_jd_index).jd_name;
             hr_utility.trace('Getting City Name from cache '|| l_city_name);

          else

             hr_utility.trace('Getting City Name from DB');

             select city_name
               into l_city_name
             from pay_us_city_names pcn
             where pcn.state_code = substr(l_jurisdiction,1,2)
             and   pcn.county_code = substr(l_jurisdiction,4,3)
             and   pcn.city_code = substr(l_jurisdiction,8,4)
             and   pcn.primary_flag = 'Y';

             l_jd_name_done_tab(l_jd_index).jd_name := l_city_name;

          end if;

          hr_utility.trace('Archiving the city ' || l_jurisdiction);

          l_balance_feed_tab.delete;
          l_defined_balance_id_tab.delete;
          l_user_entity_id_tab.delete;
          l_value_tab.delete;
          l_seq_tab.delete;
          l_context_id_tab.delete;
          l_context_val_tab.delete;
          l_index := 0;

          /* Assign values to the PL/SQL tables */

          l_step := 18;
          l_user_entity_id_tab(1) := g_city_uei;
          l_value_tab(1)          := l_city_name;
          l_seq_tab(1)            := 1;
          l_context_id_tab(1)     := g_jursd_context_id;
          l_context_val_tab(1)    := l_jurisdiction;


          create_archive (p_user_entity_id => l_user_entity_id_tab,
                          p_context1       => p_assactid,
                          p_value          => l_value_tab,
                          p_sequence       => l_seq_tab,
                          p_context        => l_context_val_tab,
                          p_context_id     => l_context_id_tab);

          l_jd_done_tab(nvl(l_jd_done_tab.last+1,1)) := l_context_val_tab(1);

      end loop;
      close c_get_city;

      hr_utility.trace('Out of city loop ');

      l_step := 19;
      open c_get_county;
      loop

          hr_utility.trace('In county loop ');

          l_step := 20;

          fetch c_get_county into l_jurisdiction;
          exit when c_get_county%NOTFOUND;

          hr_utility.trace('assignment  '|| to_char(l_asgid));
          hr_utility.trace('County JD is ' || l_jurisdiction);

          l_jd_index := replace(l_jurisdiction,'-');

          l_step := 21;
          l_true := 'N';
          l_chk_county_archive := 'N';

          if l_jd_done_tab.last is not null then

            for i in 1..l_jd_done_tab.last LOOP

             if substr(l_jd_done_tab(i),1,7) = substr(l_jurisdiction,1,7) then
              l_true := 'Y';
             end if;

             if l_jd_done_tab(i) = l_jurisdiction then
               l_chk_county_archive := 'Y';
               exit;
             end if;

            end loop;

          end if;

        if l_true = 'N' then
          l_count := l_count + 1;
          pay_archive.g_context_values.name(l_count) := 'JURISDICTION_CODE';
          pay_archive.g_context_values.value(l_count) := l_jurisdiction;
        end if;

          /* Now archive the county */

        if l_chk_county_archive = 'N' then

          l_step := 22;

          if l_jd_name_done_tab.exists(l_jd_index) then

             l_county_name := l_jd_name_done_tab(l_jd_index).jd_name;
             hr_utility.trace('Getting County Name from cache '|| l_county_name);

          else

             hr_utility.trace('Getting County Name from DB');

             select county_name
               into l_county_name
             from pay_us_counties puc
             where puc.state_code = substr(l_jurisdiction,1,2)
             and   puc.county_code = substr(l_jurisdiction,4,3);

             l_jd_name_done_tab(l_jd_index).jd_name := l_county_name;

          end if; /* l_jd_name_done_tab.exists(l_jd_index) */

       end if; /* l_chk_county_archive = 'N' */


       l_step := 23;

       hr_utility.trace('Archive county '||substr(l_jurisdiction,1,7)||'0000');

       l_user_entity_id_tab.delete;
       l_value_tab.delete;
       l_seq_tab.delete;
       l_context_id_tab.delete;
       l_context_val_tab.delete;

       /* Assign values to the PL/SQL tables */

       l_step := 24;

       l_user_entity_id_tab(1) := g_county_uei;
       l_value_tab(1)          := l_county_name;
       l_seq_tab(1)            := 1;
       l_context_id_tab(1)     := g_jursd_context_id;
       l_context_val_tab(1)    := substr(l_jurisdiction,1,7) || '0000';

       create_archive (p_user_entity_id => l_user_entity_id_tab,
                       p_context1       => p_assactid,
                       p_value          => l_value_tab,
                       p_sequence       => l_seq_tab,
                       p_context        => l_context_val_tab,
                       p_context_id     => l_context_id_tab);

       l_jd_done_tab(nvl(l_jd_done_tab.last+1,1)) := l_context_val_tab(1);

      end loop;
      close c_get_county;

      hr_utility.trace('Out of county loop ');

      l_step := 25;

      open c_get_state;
      loop

          hr_utility.trace('In state loop ');
          fetch c_get_state into l_jurisdiction;
          exit when c_get_state%NOTFOUND;

          hr_utility.trace('assignment  '|| to_char(l_asgid));
          hr_utility.trace('State JD is ' || l_jurisdiction);

          l_jd_index := replace(l_jurisdiction,'-');

          l_true := 'N';
          l_chk_state_archive := 'N';

          if l_jd_done_tab.last is not null then

            for i in 1..l_jd_done_tab.last LOOP

             if substr(l_jd_done_tab(i),1,2) = substr(l_jurisdiction,1,2) then
                l_true := 'Y';
             end if;

             if l_jd_done_tab(i) = l_jurisdiction then
                l_chk_state_archive := 'Y';
                exit;
             end if;

            end loop;

          end if; /* l_jd_done_tab.last is not null */


       if l_true = 'N' then
          l_count := l_count + 1;
          pay_archive.g_context_values.name(l_count) := 'JURISDICTION_CODE';
          pay_archive.g_context_values.value(l_count) := l_jurisdiction;
       end if;

       if l_chk_state_archive = 'N' then

          if l_jd_name_done_tab.exists(l_jd_index) then

             l_state_abbrev := l_jd_name_done_tab(l_jd_index).jd_name;
             hr_utility.trace('Getting State Abbrev from cache '|| l_state_abbrev);

          else

             hr_utility.trace('Getting State Abbrev from DB');

             l_step := 26;

             select state_abbrev
               into l_state_abbrev
             from pay_us_states pus
             where pus.state_code = substr(l_jurisdiction,1,2);

              l_jd_name_done_tab(l_jd_index).jd_name := l_state_abbrev;

          end if; /* l_jd_name_done_tab.exists(l_jd_index) */

      end if; /* l_chk_state_archive = 'N' */

          l_step := 27;

          hr_utility.trace('Archive state' ||l_jurisdiction);

          l_user_entity_id_tab.delete;
          l_value_tab.delete;
          l_seq_tab.delete;
          l_context_id_tab.delete;
          l_context_val_tab.delete;

          /* Assign values to the PL/SQL tables */

          l_step := 28;

          hr_utility.trace('Value of g_state_uei is : ' || to_char(g_state_uei));

          l_user_entity_id_tab(1) := g_state_uei;
          l_value_tab(1)          := l_state_abbrev;
          l_seq_tab(1)            := 1;
          l_context_id_tab(1)     := g_jursd_context_id;
          l_context_val_tab(1)    := substr(l_jurisdiction,1,3) || '000-0000';

          create_archive (p_user_entity_id => l_user_entity_id_tab,
                          p_context1       => p_assactid,
                          p_value          => l_value_tab,
                          p_sequence       => l_seq_tab,
                          p_context        => l_context_val_tab,
                          p_context_id     => l_context_id_tab);

         l_jd_done_tab(nvl(l_jd_done_tab.last+1,1)) := l_context_val_tab(1);

      end loop;
      close c_get_state;

      hr_utility.trace('Out of state loop ');

      l_step := 39;

      open c_get_cnt_sd;
      loop
          l_step := 40;
          hr_utility.trace('In sd loop ');
          fetch c_get_cnt_sd into l_jurisdiction,l_county_code;
          exit when c_get_cnt_sd%NOTFOUND;

          l_step := 41;
          l_true := 'N';
          l_chk_cnt_sd_archive := 'N';

          if l_jd_done_tab.last is not null then
            for i in 1..l_jd_done_tab.last LOOP
             if substr(l_jd_done_tab(i),1,8) = substr(l_jurisdiction,1,8) then
                l_true := 'Y';
             end if;
             if l_jd_done_tab(i) = l_jurisdiction then
                l_chk_cnt_sd_archive := 'Y';
             end if;
            end loop;
          end if;

          if l_true = 'N' then
              l_count := l_count + 1;
              pay_archive.g_context_values.name(l_count) := 'JURISDICTION_CODE';
              pay_archive.g_context_values.value(l_count) := substr(l_jurisdiction,1,8);
          end if;
          l_step := 42;

          if l_chk_cnt_sd_archive = 'N' then
          	select school_dst_name
          	into l_cnt_sd_name
          	from pay_us_county_school_dsts pcs
          	where pcs.state_code = substr(l_jurisdiction,1,2)
          	and   pcs.county_code = l_county_code
          	and   school_dst_code = substr(l_jurisdiction,4,5);

        	 l_step := 43;

          	l_user_entity_id_tab.delete;
          	l_value_tab.delete;
          	l_seq_tab.delete;
          	l_context_id_tab.delete;
	        l_context_val_tab.delete;

          	/* Assign values to the PL/SQL tables */

          	l_step := 44;

          	--l_user_entity_id_tab(1) := l_county_sd_uei;
          	l_user_entity_id_tab(1) := g_county_sd_uei;
          	l_value_tab(1)          := l_cnt_sd_name;
          	l_seq_tab(1)            := 1;
          	--l_context_id_tab(1)     := l_jursd_context_id;
          	l_context_id_tab(1)     := g_jursd_context_id;
          	l_context_val_tab(1)    :=  substr(l_jurisdiction,1,8);

	        create_archive (p_user_entity_id => l_user_entity_id_tab,
       		                p_context1       => p_assactid,
               	                p_value          => l_value_tab,
                    	        p_sequence       => l_seq_tab,
                          	p_context        => l_context_val_tab,
                          	p_context_id     => l_context_id_tab);

                l_jd_done_tab(nvl(l_jd_done_tab.last+1,1)) := l_context_val_tab(1);
          else
                NULL; /* County school district already archived */
          end if;

      end loop;
      close c_get_cnt_sd;

      hr_utility.trace('Out of cnt_sd loop ');

      l_step := 45;

      open c_get_cty_sd;
      loop

          hr_utility.trace('In cty_sd loop ');

          l_step := 46;

          fetch c_get_cty_sd into l_jurisdiction,l_county_code, l_city_code;
          exit when c_get_cty_sd%NOTFOUND;

          l_step := 47;
          l_true := 'N';
          l_chk_city_sd_archive := 'N';

          if l_jd_done_tab.last is not null then
            for i in 1..l_jd_done_tab.last LOOP
             if substr(l_jd_done_tab(i),1,8) = substr(l_jurisdiction,1,8) then
                l_true := 'Y';
             end if;
             if l_jd_done_tab(i) = l_jurisdiction then
                l_chk_city_sd_archive := 'Y';
             end if;
            end loop;
          end if;

          if l_true = 'N' then

              l_count := l_count + 1;
              pay_archive.g_context_values.name(l_count) := 'JURISDICTION_CODE';
              pay_archive.g_context_values.value(l_count) := substr(l_jurisdiction,1,8);
          end if;
          l_step := 48;

          if l_chk_city_sd_archive = 'N' then

         	select school_dst_name
          	into l_cty_sd_name
          	from pay_us_city_school_dsts pcs
          	where pcs.state_code = substr(l_jurisdiction,1,2)
          	and   pcs.county_code = l_county_code
          	and   pcs.city_code = l_city_code
          	and   school_dst_code = substr(l_jurisdiction,4,5);

          	l_step := 49;

          	l_user_entity_id_tab.delete;
          	l_value_tab.delete;
          	l_seq_tab.delete;
          	l_context_id_tab.delete;
          	l_context_val_tab.delete;

          	/* Assign values to the PL/SQL tables */

          	l_step := 50;

          	--l_user_entity_id_tab(1) := l_city_sd_uei;
          	l_user_entity_id_tab(1) := g_city_sd_uei;
          	l_value_tab(1)          := l_cty_sd_name;
          	l_seq_tab(1)            := 1;
          	--l_context_id_tab(1)     := l_jursd_context_id;
          	l_context_id_tab(1)     := g_jursd_context_id;
          	l_context_val_tab(1)    := substr(l_jurisdiction,1,8);

          	create_archive (p_user_entity_id => l_user_entity_id_tab,
               	                p_context1       => p_assactid,
                                p_value          => l_value_tab,
                                p_sequence       => l_seq_tab,
                                p_context        => l_context_val_tab,
                                p_context_id     => l_context_id_tab);

     	  	l_jd_done_tab(nvl(l_jd_done_tab.last+1,1)) := l_context_val_tab(1);
     	  else
          	NULL; /* City school district already archived */
      	  end if;
      end loop;
      close c_get_cty_sd;

      hr_utility.trace('Out of cty_sd loop ');

      l_step := 51;

      /* Set the no. of contexts */
      pay_archive.g_context_values.sz := l_count;

      if l_count = 1 then
    --   pay_balance_pkg.set_context ('JURISDICTION_CODE',lt_jursd_context(1));
    --     lt_jursd_context(1) := NULL;
         hr_utility.trace('One context only name : ' || pay_archive.g_context_values.name(1));
         hr_utility.trace('One context only value : ' || pay_archive.g_context_values.value(1));
      else
       for i in 1..l_count loop
         hr_utility.trace('Multiple context name : ' || pay_archive.g_context_values.name(i));
         hr_utility.trace('Multiple context value : ' || pay_archive.g_context_values.value(i));
         -- hr_utility.trace('Multiple context ('|| to_char(i)||') : ' || lt_jursd_context(i));
       end loop;
      end if;

      hr_utility.trace('g_context_values.sz : ' || pay_archive.g_context_values.sz);

      /* Flush all jurisdiction contexts */

         hr_utility.trace('l_jd_done_tab....first : '|| l_jd_done_tab.first);
         hr_utility.trace('l_jd_done_tab....last : '|| l_jd_done_tab.last);

      if l_jd_done_tab.count > 0 then

         for i in l_jd_done_tab.first .. l_jd_done_tab.last loop

             hr_utility.trace('l_jd_done_tab.... value of : '|| i ||' is '|| l_jd_done_tab(i) );

         end loop;

      end if;

/* We need to clear out the table per employee. There is some relation
   with the jd stored in this table and the jd context that is stored
   when making call to JD specific balances. However we are chaching
   the names of the JD to avoid the DB calls */

      l_jd_done_tab.delete;

      l_step := 52;

        for ln_count in pay_us_archive.ltr_pre_tax_bal.first ..
                  pay_us_archive.ltr_pre_tax_bal.last loop

            l_step := 53;

            lv_value := nvl(pay_balance_pkg.get_value
           (p_defined_balance_id   => pay_us_archive.ltr_pre_tax_bal(ln_count).defined_balance,
            p_assignment_action_id => l_aaid),0);

            l_step := 54;
            hr_utility.trace('lv_value is '||lv_value);

            ff_archive_api.create_archive_item(
                p_archive_item_id   => l_archive_item_id,
                p_user_entity_id    => pay_us_archive.ltr_pre_tax_bal(ln_count).user_entity_id,
                p_archive_value     => lv_value,
                p_archive_type      => '',
                p_action_id         => p_assactid,
                p_legislation_code  => 'US',
                p_object_version_number => l_object_version_number,
                p_some_warning              => l_some_warning,
                p_context_name1  => 'TAX_UNIT_ID',
                p_context1  => l_taxunitid);

            l_step := 55;

        end loop;


      l_step := 56;


         /* Puerto Rico Specific Archive */

      if g_puerto_rico_gre = 'Y' then

          hr_utility.trace('Entered Puerto Rico GRE ');

          l_step := 57;
          l_user_entity_id_tab.delete;
          l_value_tab.delete;
          l_seq_tab.delete;
          l_context_id_tab.delete;
          l_context_val_tab.delete;
          l_defined_balance_id_tab.delete;
          l_balance_feed_tab.delete;
          l_index := 0;

          begin

               select  ppf.marital_status
                  into l_marital_status
               from per_people_f ppf
               where ppf.person_id = l_person_id
                 and l_date_earned  between ppf.effective_start_date
                                  and ppf.effective_end_date;


          exception when no_data_found then
                   l_marital_status := null;
          end;

          begin

              select  ppf.national_identifier
                 into l_con_national_identifier
              from per_people_f ppf,
                   per_contact_relationships ctr
              where ctr.person_id = ppf.person_id
                and ctr.contact_person_id = l_person_id
             /* and ctr.personal_flag = 'Y'*/
                and ctr.contact_type = 'S'
                and l_date_earned  between ppf.effective_start_date
                                    and ppf.effective_end_date
                and ctr.date_start =
                         (select max(ctr1.date_start)
                          from per_contact_relationships ctr1
                          where ctr1.person_id = l_person_id
                            and ctr1.date_start <= l_year_end
                            and nvl(ctr1.date_end,
                                    fnd_date.canonical_to_date('4712/12/31 00:00:00'))
                                      >= l_year_start);


          exception when no_data_found then
                   l_con_national_identifier := null;
          end;

          hr_utility.trace('Maritial Status = '||l_marital_status);
          hr_utility.trace('Contact National Identifier = '||l_con_national_identifier);

          pay_balance_pkg.set_context('TAX_UNIT_ID',l_taxunitid);

          l_step := 58;

           for k in pay_us_archive.ltr_pr_balances.first ..
                  pay_us_archive.ltr_pr_balances.last loop

               l_index := l_user_entity_id_tab.count + 1;

               l_user_entity_id_tab(l_index) := pay_us_archive.ltr_pr_balances(k).user_entity_id;
               l_defined_balance_id_tab(l_index) := pay_us_archive.ltr_pr_balances(k).defined_balance;
               l_value_tab(l_index) := nvl(pay_balance_pkg.get_value
                     (p_defined_balance_id =>l_defined_balance_id_tab(l_index) ,
                          p_assignment_action_id => l_aaid),0);

           end loop;


          l_step := 64;
          --l_user_entity_id_tab(7)  := get_user_entity_id('A_PER_MARITAL_STATUS');
          l_user_entity_id_tab(7)  := g_per_marital_status;

          l_step := 65;
          --l_user_entity_id_tab(8)  := get_user_entity_id('A_CON_NATIONAL_IDENTIFIER');
          l_user_entity_id_tab(8)  := g_con_national_identifier;

          l_step := 66;

          l_step := 72;
          l_value_tab(7) := l_marital_status;

          l_step := 73;
          l_value_tab(8) := l_con_national_identifier;

          l_step := 74;

          l_seq_tab(1)         := 1;
          --l_context_id_tab(1)  := l_tax_unit_context_id;
          l_context_id_tab(1)  := g_tax_unit_context_id;
          l_context_val_tab(1) := l_taxunitid;

          create_archive (p_user_entity_id => l_user_entity_id_tab,
                          p_context1       => p_assactid,
                          p_value          => l_value_tab,
                          p_sequence       => l_seq_tab,
                          p_context        => l_context_val_tab,
                          p_context_id     => l_context_id_tab);

         end if; /* Special archiving for Puerto Rico */

         l_step := 75;

         /* 1099R 2002 */


         if g_1099R_transmitter_code is not null then
          hr_utility.trace('Into g_1099r_transmitter_code not equal to null');
          l_step := 76;

          l_user_entity_id_tab.delete;
          l_defined_balance_id_tab.delete;
          l_balance_feed_tab.delete;
          l_value_tab.delete;
          l_seq_tab.delete;
          l_context_id_tab.delete;
          l_context_val_tab.delete;
          l_index := 0;

          hr_utility.trace('Deleted plsql tables ');

          begin

             open  c_get_1099_eit_info(l_asgid);
             hr_utility.trace('Opened c_get_1099_eit_info ');
             fetch c_get_1099_eit_info into l_taxable_amount_unknown
                                           ,l_total_distributions
                                           ,l_ee_distribution_percent
                                           ,l_total_distribution_percent;

                   if c_get_1099_eit_info%NOTFOUND then
                      l_taxable_amount_unknown := null ;
                      l_total_distributions := null ;
                      l_ee_distribution_percent := null ;
                      l_total_distribution_percent := null ;
                   end if;
             close c_get_1099_eit_info;



          exception when no_data_found then
                   l_marital_status := null;
          end;

          hr_utility.trace('l_taxable_amount_unknown = '||l_taxable_amount_unknown);
          hr_utility.trace('l_total_distributions = '||l_total_distributions);
          hr_utility.trace('l_ee_distribution_percent='||l_ee_distribution_percent);
          hr_utility.trace('l_total_distribution_percent = '||l_total_distribution_percent);


          pay_balance_pkg.set_context('TAX_UNIT_ID',l_taxunitid);

          l_step := 77;

          for m in pay_us_archive.ltr_1099_bal.first ..
                  pay_us_archive.ltr_1099_bal.last loop

          l_index := l_user_entity_id_tab.count + 1;

          l_user_entity_id_tab(l_index) := pay_us_archive.ltr_1099_bal(m).user_entity_id;
          l_defined_balance_id_tab(l_index) := pay_us_archive.ltr_1099_bal(m).defined_balance;
          l_balance_feed_tab(l_index) := pay_us_archive.ltr_1099_bal(m).feed_info;

          if l_balance_feed_tab(l_index)  = 'Y' then

               l_value_tab(l_index) := nvl(pay_balance_pkg.get_value
                     (p_defined_balance_id =>l_defined_balance_id_tab(l_index) ,
                          p_assignment_action_id => l_aaid),0);
          else
               l_value_tab(l_index) := 0;
          end if;

          end loop;

          l_step := 78;

          open  c_get_1099_distribution_info(l_person_id,l_taxunitid);
          hr_utility.trace('Opened c_get_1099_distribution_info ');

          l_step := 79;

          fetch c_get_1099_distribution_info into l_distribution_code;

          if c_get_1099_distribution_info%NOTFOUND then
                 l_distribution_code := '7' ;
          elsif  c_get_1099_distribution_info%ROWCOUNT > 1 then
             l_mesg :='Person id '||to_char(l_person_id)||' has multiple distribution code for one GRE';
             pay_core_utils.push_message(801,'PAY_EXCEPTION','A');
             pay_core_utils.push_token('description',substr(l_mesg,1,50));
             hr_utility.raise_error;
          end if;

          close c_get_1099_distribution_info;
          --
	  --
	  open c_get_first_yr_roth_contrib(l_person_id,l_taxunitid);
          fetch c_get_first_yr_roth_contrib into l_first_yr_roth_contrib;
	  if c_get_first_yr_roth_contrib%NOTFOUND then
	     l_first_yr_roth_contrib := NULL;
	  end if;

          l_step := 83;
          --l_user_entity_id_tab(6)  := get_user_entity_id('A_TAXABLE_AMOUNT_UNKNOWN');
          l_user_entity_id_tab(6)  := g_taxable_amount_unknown;

          l_step := 84;
          --l_user_entity_id_tab(7)  := get_user_entity_id('A_TOTAL_DISTRIBUTIONS');
          l_user_entity_id_tab(7)  := g_total_distributions;

          l_step := 85;
          --l_user_entity_id_tab(8)  := get_user_entity_id('A_EMPLOYEE_DISTRIBUTION_PERCENT');
          l_user_entity_id_tab(8)  := g_emp_distribution_percent;

          l_step := 86;
          --l_user_entity_id_tab(9)  := get_user_entity_id('A_TOTAL_DISTRIBUTION_PERCENT');
          l_user_entity_id_tab(9)  := g_total_distribution_percent;

          l_step := 87;
          --l_user_entity_id_tab(10)  := get_user_entity_id('A_DISTRIBUTION_CODE_FOR_1099R');
          l_user_entity_id_tab(10)  := g_distribution_code_for_1099r;
          --
	  -- Added For bug# 5517938
          l_user_entity_id_tab(11) := g_first_yr_roth_contrib;

          l_step := 88;

          l_value_tab(6) := l_taxable_amount_unknown;

          l_step := 89;
          l_value_tab(7) := l_total_distributions;

          l_step := 90;
          l_value_tab(8) := l_ee_distribution_percent;

          l_step := 91;
          l_value_tab(9) := l_total_distribution_percent;

          l_step := 92;
          l_value_tab(10) := l_distribution_code;

          l_step := 93;
          l_value_tab(11) := l_first_yr_roth_contrib;

          l_seq_tab(1)         := 1;
          --l_context_id_tab(1)  := l_tax_unit_context_id;
          l_context_id_tab(1)  := g_tax_unit_context_id;
          l_context_val_tab(1) := l_taxunitid;

          create_archive (p_user_entity_id => l_user_entity_id_tab,
                          p_context1       => p_assactid,
                          p_value          => l_value_tab,
                          p_sequence       => l_seq_tab,
                          p_context        => l_context_val_tab,
                          p_context_id     => l_context_id_tab);

         end if; /* Special archiving for 1099R GRE */

         l_step := 94;

         hr_utility.trace('max assignment_action_id : ' || to_char(l_aaid));
         pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID',l_aaid);
         pay_archive.balance_aa := l_aaid;

          l_step := 95;
          pay_balance_pkg.set_context('TAX_UNIT_ID',l_taxunitid);

          l_user_entity_id_tab.delete;
          l_user_entity_tab.delete;
          l_value_tab.delete;

          l_user_entity_tab(1) := 'SS_EE_TAXABLE_PER_GRE_YTD';
          l_user_entity_tab(2) := 'SS_EE_WITHHELD_PER_GRE_YTD';
          l_user_entity_tab(3) := 'MEDICARE_EE_TAXABLE_PER_GRE_YTD';
          l_user_entity_tab(4) := 'MEDICARE_EE_WITHHELD_PER_GRE_YTD';

          l_user_entity_id_tab(1) := get_user_entity_id('A_'||l_user_entity_tab(1));
          l_user_entity_id_tab(2) := get_user_entity_id('A_'||l_user_entity_tab(2));
          l_user_entity_id_tab(3) := get_user_entity_id('A_'||l_user_entity_tab(3));
          l_user_entity_id_tab(4) := get_user_entity_id('A_'||l_user_entity_tab(4));


          for ln_count in 1..4 loop

            l_step := 96;

            hr_utility.trace('l_user_entity_tab('||ln_count||')is '||l_user_entity_tab(ln_count));
            hr_utility.trace('l_user_entity_id_tab('||ln_count||')is '||l_user_entity_id_tab(ln_count));

            l_value_tab(ln_count) := nvl(pay_balance_pkg.get_value
                             (p_defined_balance_id =>bal_db_item(l_user_entity_tab(ln_count)),
                              p_assignment_action_id => l_aaid),0);

            l_step := 97;
            hr_utility.trace('lv_value is '||l_value_tab(ln_count));

            ff_archive_api.create_archive_item(
                p_archive_item_id   => l_archive_item_id,
                p_user_entity_id    => l_user_entity_id_tab(ln_count),
                p_archive_value     => l_value_tab(ln_count),
                p_archive_type      => '',
                p_action_id         => p_assactid,
                p_legislation_code  => 'US',
                p_object_version_number => l_object_version_number,
                p_some_warning              => l_some_warning,
                p_context_name1  => 'TAX_UNIT_ID',
                p_context1  => l_taxunitid);

            hr_utility.trace('l_archive_item_id is '||to_char(l_archive_item_id));

            l_step := 98;

        end loop;

        l_step := 99;


        lv_medicare_withheld := l_value_tab(4) ;
        hr_utility.trace('lv_medicare_withheld is '||lv_medicare_withheld);

        l_step := 100;

        lv_ss_withheld := l_value_tab(2) ;
        hr_utility.trace('lv_ss_withheld is '||lv_ss_withheld);

        l_step := 101;

        l_user_entity_id_tab.delete;
        l_value_tab.delete;
        l_seq_tab.delete;
        l_context_id_tab.delete;
        l_context_val_tab.delete;

        if pay_us_archive.g_govt_employer = 'Y' then

             hr_utility.trace('Goverment employer is ');
             l_step := 102;
             l_value_tab(1) := pay_us_sqwl_udf.get_employment_code(
                             p_medicare_wh => lv_medicare_withheld,
                             p_ss_wh => lv_ss_withheld);
             hr_utility.trace('lv_value is '||l_value_tab(1));

             l_step := 103;
        else
             l_step := 103.1;
             l_value_tab(1) := 'R';
        end if;

        l_user_entity_id_tab(1) := get_user_entity_id('A_ASG_GRE_EMPLOYMENT_TYPE_CODE');

        l_step := 104;
        hr_utility.trace('l_user_entity_id_tab is '||l_user_entity_id_tab(1));
        l_seq_tab(1)         := 1;
        --l_context_id_tab(1)  := l_tax_unit_context_id;
        l_context_id_tab(1)  := g_tax_unit_context_id;
        l_context_val_tab(1) := l_taxunitid;

        l_step := 105;
        create_archive (p_user_entity_id => l_user_entity_id_tab,
                        p_context1       => p_assactid,
                        p_value          => l_value_tab,
                        p_sequence       => l_seq_tab,
                        p_context        => l_context_val_tab,
                        p_context_id     => l_context_id_tab);

        l_step := 106;

        l_user_entity_id_tab.delete;
        l_value_tab.delete;
        l_seq_tab.delete;
        l_context_id_tab.delete;
        l_context_val_tab.delete;

        l_step := 107;

	 -- Bug 4544792 : Removed the cursor c_get_disability_plan_eit_info
        open  c_get_disability_plan_scl_info(l_asgid,l_taxunitid);
        hr_utility.trace('Opened c_get_disability_plan_scl_info ');
        fetch c_get_disability_plan_scl_info
          into l_disability_plan_id;

/*
        open  c_get_disability_plan_eit_info(l_asgid);
        hr_utility.trace('Opened c_get_disability_plan_eit_info ');
        fetch c_get_disability_plan_eit_info
          into l_disability_plan_id;
*/
        if c_get_disability_plan_scl_info%NOTFOUND then
            l_disability_plan_id := null;
          end if;
        close c_get_disability_plan_scl_info;

        hr_utility.trace('l_disability_plan_id = '||l_disability_plan_id);
        l_user_entity_id_tab(1) := g_disability_plan_id;
        l_value_tab(1) := l_disability_plan_id;

       l_step := 108;
       hr_utility.trace('l_user_entity_id_tab is '||l_user_entity_id_tab(1));
       hr_utility.trace(' l_value_tab is '||l_value_tab(1));
       l_seq_tab(1)         := 1;
       --l_context_id_tab(1)  := l_tax_unit_context_id;
       l_context_id_tab(1)  := g_tax_unit_context_id;
       l_context_val_tab(1) := l_taxunitid;

       create_archive (p_user_entity_id => l_user_entity_id_tab,
                       p_context1       => p_assactid,
                       p_value          => l_value_tab,
                       p_sequence       => l_seq_tab,
                       p_context        => l_context_val_tab,
                       p_context_id     => l_context_id_tab);

       l_step := 108;

       /* Bug # 8251746 */
        l_user_entity_id_tab.delete;
       l_value_tab.delete;
       l_seq_tab.delete;
       l_context_id_tab.delete;
       l_context_val_tab.delete;

        open  c_get_flipp_scl_info(l_asgid,l_taxunitid);
        hr_utility.trace('Opened c_get_flipp_scl_info ');
        fetch c_get_flipp_scl_info
          into l_nj_flipp_id;

         if c_get_flipp_scl_info%NOTFOUND then
            l_nj_flipp_id := null;
          end if;
        close c_get_flipp_scl_info;
        hr_utility.trace('l_nj_flipp_id = '||l_nj_flipp_id);
        l_user_entity_id_tab(1) := g_nj_flipp_id;
        l_value_tab(1) := l_nj_flipp_id;

       hr_utility.trace('l_user_entity_id_tab is '||l_user_entity_id_tab(1));
       hr_utility.trace(' l_value_tab is '||l_value_tab(1));
       l_seq_tab(1)         := 1;
       --l_context_id_tab(1)  := l_tax_unit_context_id;
       l_context_id_tab(1)  := g_tax_unit_context_id;
       l_context_val_tab(1) := l_taxunitid;
       create_archive (p_user_entity_id => l_user_entity_id_tab,
                       p_context1       => p_assactid,
                       p_value          => l_value_tab,
                       p_sequence       => l_seq_tab,
                       p_context        => l_context_val_tab,
                       p_context_id     => l_context_id_tab);



-- A_ARCHIVE_DATE

       l_user_entity_id_tab.delete;
       l_value_tab.delete;
       l_seq_tab.delete;
       l_context_id_tab.delete;
       l_context_val_tab.delete;

       l_step := 109;

       l_user_entity_id_tab(1) := g_archive_date;
       /* Bug# 4137906 - Time Info not required for the Date. So suppressing it */
       l_value_tab(1) := substr(fnd_date.date_to_canonical(sysdate),1,10);

       l_step := 110;
       hr_utility.trace('l_user_entity_id_tab is '||l_user_entity_id_tab(1));
       hr_utility.trace(' l_value_tab is '||l_value_tab(1));
       l_seq_tab(1)         := 1;
       --l_context_id_tab(1)  := l_tax_unit_context_id;
       l_context_id_tab(1)  := g_tax_unit_context_id;
       l_context_val_tab(1) := l_taxunitid;


       create_archive (p_user_entity_id => l_user_entity_id_tab,
                       p_context1       => p_assactid,
                       p_value          => l_value_tab,
                       p_sequence       => l_seq_tab,
                       p_context        => l_context_val_tab,
                       p_context_id     => l_context_id_tab);

       l_step := 111;

       l_user_entity_id_tab(1) := g_w2_corrected;
       l_add_archive :=pay_us_archive_util.get_archive_value(p_assactid,
                                                            'A_ADD_ARCHIVE',
                                                             l_taxunitid);

       IF l_add_archive = 'Y'  THEN
           l_value_tab(1) := 'N';
       ELSE
          l_value_tab(1) := print_w2_corrected(l_payroll_action_id,
                                               p_assactid,
                                               l_taxunitid);
       END IF;

       l_step := 112;
       hr_utility.trace('l_user_entity_id_tab is '||l_user_entity_id_tab(1));
       hr_utility.trace(' l_value_tab is '||l_value_tab(1));
       l_seq_tab(1)         := 1;
       l_context_id_tab(1)  := g_tax_unit_context_id;
       l_context_val_tab(1) := l_taxunitid;

       create_archive (p_user_entity_id => l_user_entity_id_tab,
                       p_context1       => p_assactid,
                       p_value          => l_value_tab,
                       p_sequence       => l_seq_tab,
                       p_context        => l_context_val_tab,
                       p_context_id     => l_context_id_tab);

       l_step := 113;

       l_user_entity_id_tab.delete;
       l_value_tab.delete;
       l_seq_tab.delete;
       l_context_id_tab.delete;
       l_context_val_tab.delete;

    -- Starting From Year 2007 we will archive Year of Designated Roth
    -- Contribution for 401(k) and 403(b) [Bug# 5517938]
    -- Reverting back changes as not Needed.
    -- End of Change For [Bug# 5517938]

	-- We have to clear the l_jd_done_tab and
	-- l_jd_name_done_tab before processing the next_employee
	-- Reference Bug# 5744676

	   l_jd_done_tab.delete;
	   l_jd_name_done_tab.delete;


        hr_utility.trace_off;

  exception when others then

         raise_application_error(-20001,'Error in eoy_archive_data at step : '
                                 ||to_char(l_step)||' - '||to_char(sqlcode) || '-' || sqlerrm);


 END eoy_archive_data;


 /* Name      : eoy_range_cursor
    Purpose   : This returns the select statement that is used to created the
                range rows for the Year End Pre-Process.
    Arguments :
    Notes     :
 */
 PROCEDURE eoy_range_cursor (pactid in number, sqlstr out nocopy varchar2) is
   l_eoy_tax_unit_id    number;
   l_archive            boolean:= FALSE;
   l_step               number;

   l_eoy_bg_id   pay_payroll_actions.business_group_id%TYPE;
   l_start_date  pay_payroll_actions.start_date%TYPE;

   l_processed   varchar2(20);
   l_mesg        varchar2(100);

   l_gre_name    hr_organization_units.name%TYPE;

 BEGIN

   l_step := 1;
   hr_utility.trace('In eoy_range_cursor');

   eoy_gre_range := 'SELECT distinct ASG.person_id
      FROM  per_all_assignments_f  ASG,
            pay_us_asg_reporting puar,
            pay_payroll_actions    PPA
     WHERE  PPA.payroll_action_id      = :payroll_action_id
       AND puar.tax_unit_id = substr(legislative_parameters,
                                         instr(legislative_parameters,''TRANSFER_GRE='')+ length(''TRANSFER_GRE=''))
       AND  asg.assignment_id = puar.assignment_id
       AND  ASG.business_group_id + 0  = PPA.business_group_id
       AND  ASG.assignment_type        = ''E''
       AND  ASG.effective_start_date  <= PPA.effective_date
       AND  ASG.effective_end_date    >= PPA.start_date
       AND  ASG.payroll_id is not null
     ORDER  BY ASG.person_id';

   select to_number(substr(legislative_parameters,INSTR(legislative_parameters,
          'TRANSFER_GRE=')+LENGTH('TRANSFER_GRE='),15)), business_group_id, start_date
     into l_eoy_tax_unit_id, l_eoy_bg_id, l_start_date
     from pay_payroll_actions
    where payroll_action_id = pactid;

   hr_utility.trace('TUI is : ' || to_char(l_eoy_tax_unit_id));
   hr_utility.trace('BG is : ' || to_char(l_eoy_bg_id));
   hr_utility.trace('Start Date is : ' || to_char(l_start_date));

   /* for bug 2149544 */
   begin
      l_processed := 'Z';

      select hou.name into l_gre_name
        from hr_organization_information hoi,
             hr_organization_units hou
        where hoi.org_information_context = 'CLASS'
          and hoi.org_information1 = 'HR_LEGAL'
          and hoi.organization_id = hou.organization_id
          and hou.business_group_id = l_eoy_bg_id
          and hou.organization_id = l_eoy_tax_unit_id;

      select 'X' into l_processed
        from pay_payroll_actions ppa1
        where ppa1.report_type = 'YREND'
          AND ppa1.business_group_id + 0 = l_eoy_bg_id
          AND ppa1.start_date = l_start_date
          AND ppa1.payroll_action_id <> pactid
          AND to_char(l_eoy_tax_unit_id) =
                         substr(ltrim(rtrim( ppa1.legislative_parameters)),
                          instr(ppa1.legislative_parameters,'TRANSFER_GRE=')+ length('TRANSFER_GRE='));

      hr_utility.trace('Value of l_processed is : ' || l_processed);


      if l_processed = 'X' then
         hr_utility.trace('Value of l_processed is : ' || l_processed);
         l_mesg :='Error : GRE '||''''|| l_gre_name|| ''''||' has already been archived';
         pay_core_utils.push_message(801,'PAY_EXCEPTION_ERROR','P');
         pay_core_utils.push_token('description',l_mesg);
         hr_utility.raise_error;
      end if;

     exception
         when no_data_found then
           null; /* meaning this is the only run */

         when too_many_rows then
           l_mesg :='Error : GRE '||''''|| l_gre_name|| ''''||' has already been archived';
           pay_core_utils.push_message(801,'PAY_EXCEPTION_ERROR','P');
           pay_core_utils.push_token('description',l_mesg);
           hr_utility.raise_error;

     end;


     l_step := 2;
     if l_eoy_tax_unit_id <> -99999 then
     l_step := 3;
        sqlstr := eoy_gre_range;
     l_step := 4;
        l_archive := chk_gre_archive(pactid);
     l_step := 5;

        if g_archive_flag = 'N' then
           l_step := 6;
           hr_utility.trace('eoy_range_cursor archiving employer data');
           eoy_archive_gre_data(p_payroll_action_id => pactid,
                               p_tax_unit_id        => l_eoy_tax_unit_id,
                               p_jd_type            => 'ALL',
                               p_state_code         => 'ALL');
           l_step := 7;
            hr_utility.trace('eoy_range_cursor archiving employer data');
        end if;
     else
        l_step := 8;
        sqlstr := eoy_all_range;
        l_step := 9;
     end if;

  exception when others then
            hr_utility.trace('eoy_range_cursor at : '
                                 ||to_char(l_step)||' - '||to_char(sqlcode) || '-' || sqlerrm);
 END eoy_range_cursor;


 PROCEDURE eoy_deinit( p_payroll_action_id in number)
 IS

 BEGIN

   /* Clear of the plsql table we have been maintaining to store
      the jurisdiction code and name */
   l_jd_done_tab.delete;
   l_jd_name_done_tab.delete;

 END eoy_deinit;
--begin

--hr_utility.trace_on(null,'pyusarch');

END pay_us_archive;

/
