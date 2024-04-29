--------------------------------------------------------
--  DDL for Package Body PAY_CA_EOY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EOY_ARCHIVE" as
/* $Header: pycayear.pkb 120.20.12010000.11 2009/12/31 10:11:47 sneelapa ship $ */

/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Description : Package and procedure to build sql for payroll processes.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   03-JAN-2000  M.Mukherjee 110.0           Created
   04-JAN-2000  M.Mukherjee 110.1         Changed the name to hr_ca_tax_units_v
                                          from  hr_ca_tax_units_v_temp
   12-JAN-2000  M.Mukherjee 110.2         Changed the name of report type
   31-JAN-2000  M.Mukherjee 110.4         ADDED archiving of QPP balances
   03-FEB-2000  M.Mukherjee 110.6         Corrected exempt_flags archiving
   04-FEB-2000  M.Mukherjee 110.7         Corrected exempt_flags archiving
   07-FEB-2000  M.Mukherjee 110.8         Corrected exempt_flags archiving
                                          put it inside if condition
   07-FEB-2000  M.Mukherjee 115.0,115.1,115.2 Upported in 115, changed the name
                                          of database items and tested the
                                          exempt flag query
   14-APR-2000  S.Sattineni 115.3         Changed the pay_ca_emp_all_fedtax_info
                                          to pay_ca_emp_all_fedtax_info_v
   16-MAY-2000  M.Mukherjee 115.4         Changed the report_type to T4
   30-JUN-2000  P.Ganguly   115.5	  Subtracted QC only Taxable Benefits
					  from Gross Earnings in case of
					  Quebec jurisdiction -
					  eoy_archive_data - Procedure.
   18-AUG-2000  M. Mukherjee 115.7        Changes for Magtapes
                                          added  registration number archiving
   05-SEP-2000  M. Mukherjee 115.8        Added error message for no
                                          transmitter GRE.
   14-SEP-2000  P.Ganguly    115.12       Added the Null value check
                                          for result and qc_result.
   15-SEP-2000  P.Ganguly    115.13       Added a check if CPP and QPP is
					  0 and the employee is < 17, > 70
					  CAEOY_CPP_QPP_EXEMPT should archive
					  'X'
   20-SEP-2000  M. Mukherjee 115.15       Changed the name of QC only Taxable
                                          benefit
                                          to 'Taxable Benefits for Quebec'
   21-SEP-2000  M. Mukherjee 115.16       Corrected archiving of registration
                                          no
   03-OCT-2000  M. Mukherjee 115.17-115.20Corrected archiving of registration
                                          no
   11-OCT-2000  SSattineni   115.21       Corrected archiving of
                                          Accounting_Contact_Name for Employer
                                          Info
   13-NOV-2001  P.Ganguly    115.22       Changed the cursor get_person_info so
                                          that it picks up middle_names rather
                                          than pre_adjunct_name. Also added
                                          CAEOY_CPP_BASIC_EXEMPTION_PER_JD_GRE
                                          _YTD and CAEOY_CPP_EXEMPT_PER_JD_GRE
                                          _YTD for Year End Exception Report.
   13-NOV-2001  P.Ganguly    115.23       Added set verify off
   14-NOV-2001  P.Ganguly    115.24       Added dbdrv command.
   11-DEC-2001  P.Ganguly    115.25       Changed the cursor employer_info into
                                          two cursors cur_employer_info and
                                          cur_transmitter_info because of
                                          performance issues.
   18-DEC-2001  P.Ganguly     115.26      Changed the cursor employer_info into
                                          two - employer_info and cur_employer_
                                          info.
   18-DEC-2001  P.Ganguly     115.27      Added \ at the end of first dbdrv.
   20-DEC-2001  P.Ganguly     115.28      Changed the cursor cur_employer_info-
                                          removed the check org_information2=
                                          '904'
   04-JAN-2002  SSattini      115.29      Changed the dbdrv line
   24-JAN-2002  P.Ganguly     115.30      Added a check in the cursor
                                          c_get_asg_id so that it picks up
                                          assignments of type 'E'
   14-NOV-2002  P.Ganguly     115.31      Fixed bug# 2667016. Removed the
                                          Group level balance calls.
   25-NOV-2002  P.Ganguly     115.32      Fixed Bug# 2598777. While archiving
                                          CAEOY_T4_BOX52_PER_JD_GRE_YTD added
                                          a round() to round the amount for
                                          Box 52.
   02-DEC-2002  P.Ganguly     115.36      Added nocopy in the out parameter.
   03-DEC-2002  P.Ganguly     115.37      Fixed Bug# 2690890. Called a function
                                          pay_ca_rl1_reg.get_primary_address
                                          to get the employee's primary address
                                          .
   09-DEC-2002  P.Ganguly     115.38      Added a new dbi CAEOY_GRE_EI_RATE
                                          to archive the EI_RATE of each GRE.
   18-DEC-2002  P.Ganguly     115.39      Fixed Bug# 2707038.  Changed the
                                          procedure eoy_archive_data. The amt
                                          against other information code
                                          31/53/77 is subtracted from Box 14.
                                          Code 53/77 has been started
                                          archiving as per Bug# 2707038.
                                          Fixed Bug# 2599468. While archiving
                                          Registration Number for box 50 a
                                          check is introduced to check the
                                          value of Box 52. If Box 52 is > than
                                          0 then the highest reg no against
                                          Box 52 is archived. If Box 52 <= 0
                                          then Reg No against box 20 is
                                          archived.
   27-AUG-2003 SSOURESR      115.41       If new balance 'T4 No Gross Earnings'
                                          is not zero then archiving will
                                          proceed Also the new balance 'T4 Non
                                          Taxable Earnings' will be deducted
                                          from Gross Earnings. Bugs 2594600 and
                                          2954727
   27-AUG-2003 mmukherj      115.42       Bugfix for #2953960. If transmiiter
                                          GRE is not properly setup it will give
                                          an error message.
   05-SEP-2003 SSattineni    115.43       Added T4 Amendment Archiving logic
                                          in eoy_archive_data procedure. Also
                                          added new local function
                                          compare_archive_data used for T4
                                          Amendment Archiver.
   06-NOV-2003 SSattineni    115.45       Added code to archive T4 Employment
                                          code in eoy_archive_data procedure.
                                          Fix for bug#2141132.
   07-NOV-2003 SSouresr      115.46       Employees that only have non taxable
                                          earnings should not be archived. Added
                                          check for this #3137707.
   19-NOV-2003 SSouresr      115.47       The function compare_archive_data was
                                          changed so that correct comparisons
                                          are made for archived null values.
   03-DEC-2003 SSattineni    115.48       Added code to archive
                                          CAEOY_T4_NEGATIVE_BALANCE_EXISTS flag
                                          to avoid negative balances employees
                                          in T4 Magnetic Media and Paper.
   03-DEC-2003 SSattineni    115.49       Fixed the bug#3284220.  Modified
                                          compare_archive_data function to
                                          consider if there are any new
                                          db_items archived by amendment and
                                          not archived by YEPP then return
                                          amendment flag 'Y'.
   04-DEC-2003 PGanguly      115.50       Fixed the bug# 3298050. Changed the
                                          cursor c_eoy_gre so that it checks
                                          for data in the pay_assignment_actions
                                          and pay_payroll_actions via EXIST
                                          clause rather than direct join. Also
                                          removed the tax_unit_id from the
                                          select clause as this cursor selects
                                          the data for a particular GRE.
   05-DEC-2003 SSattineni    115.51       The Negative Balance Exists flag
                                          was archiving incorrect for some
                                          employees, so initialised the
                                          flag value with 'N'.
   05-FEB-2004 SSattineni    115.52       Fixed the bug#3422384, added
                                          additional logic to archive the
                                          CPP/QPP Exempt flag and EI Exempt
                                          flag correctly for an employee.
   06-FEB-2004 mmukherj      115.53       Added cursor c_get_latest_actid to
                                          improve performance of getting latest
                                          assignment action id.
   19-FEB-2004 SSattineni    115.55       Modified c_get_date_of_birth cursor
                                          to address the terminated employees
                                          issue for Box 28 validation. Part of
                                          fix#3422384.
   02-JUL-2004 mmukherj      115.56       Modified c_eoy_gre further to make
                                          it more performant.
   09-AUG-2004 SSattineni    115.58       Modified eoy_action_creation procedure
                                          to check 'T4 Non Taxable Earnings',
                                          'Gross Earnings' and 'T4 No Gross
                                          Earnings' balance values before
                                          creating the assignment action for T4.
                                          Fix for bug#3267520.
   20-AUG-2004 rigarg        115.59       Fix for bug#3564076
                                          Added archiver for DBI's for Technical
                                          Contact Extension and EMail.
   24-AUG-2004 ssmukher      115.60       Fix for bug# 3447439.Modified the
                                          cursor c_get_latest_asg to fetch the
                                          earn date and assignment action id.
                                          This earn date will be used to fetch
                                          the CPP/QPP and EE exempt flag for
                                          an employee in a particular province.
   02-NOV-2004 rigarg        115.61       Fix for bug# 3973040. Removed
                                          Transmitter Code 904 check.
   10-NOV-2004  ssouresr     115.63       Modified to use tables instead of
                                          views to remove problems with
                                          security groups
   12-NOV-2004  ssouresr     115.64       Added a date range to the cursor
                                          c_get_latest_asg to make sure records
                                          are only picked up in the year
   22-NOV-2004  mmukherj     115.65       bugfix #4025926
   01-DEC-2004  mmukherj     115.66       Archiving QPP Reduced Subject. Because
                                          this amunt has to be printed in BOX26
                                          for QC employee. Bugfix 4031227.
   02-DEC-2004  ssouresr     115.67       Added error message for security group
   07-DEC-2004  ssouresr     115.68       Removed the changes made for 3447439
                                          in 115.60
                                          as this was impacting performance
   08-JUN-2005  ssouresr     115.69       Removed error message for security
                                          group
   13-JUN-2005  mmukherj     115.70       Bug fix #4026689. Added call to
                                          eoy_archive_gre_data in
                                          eoy_archive_data.  So that when the
                                          Retry process calls eoy_archive_data,
                                          it re-archives the employer and
                                          transmitter data.
   29-JUL-2005  ssmukher     115.71       Bug Fix #4034155 Added code to remove
                                          the other information amounts from
                                          the Box 14
   03-AUG-2005  ssmukher     115.72       Bug Fix #4034155 Added code for
                                          checking the other information
                                          amt total not to exceed the gross
                                          earnings total displayed in Box 14.
                                          Also modified the check condition for
                                          flag l_negative_balance_exists
                                          in eoy_archive_data procedure.
   05-AUG-2005  saurgupt     115.73       Bug 4517693: Added Address_line3 for
                                          T4 archiver.
   11-Aug-2005  ssmukher     115.74       Bug 4547415  Substracted the amount
                                          associated with code 31,53 and 78
                                          from the Grosss Earnings(box 14)
   26-AUG-2005 mmukherj     115.75        Commented out the use of two cursors
                                          c_eoy_all and eoy_all_range. Since
                                          GRE is a mandatory parameter for
                                          Federal Yearend Archiver Process
                                          these two cursors will never be used.
   14-Sep-2005  ssmukher     115.76       Bug Fix 4028693 .Archive 0 value for
                                          'Gross Earnings' when the Employment
                                          code is either 11,12,13 and 17
   26-OCT-2005  ssouresr     115.77       range_cursor has been modified to
                                          avoid using hr_soft_coding_keyflex
   04-NOV-2005  ssouresr     115.78       Removed archiving of the Federal Youth
                                          Hire indicator flag
   4-NOV-2005   pganguly     115.79       Fixed bug# 4033041. Commented out
                                          archiver code for T4_BOX50.
   3-MAR-2006   ssmukher     115.80       Fixed Bug #5041252 .Removed the
                                          per_all_assignments_f table check
                                          from the select statement in the
                                          procedure eoy_archive_data to fetch
                                          the CPP/QPP exempt flag
                                          from pay_ca_emp_prov_tax_info_f.
   25-Jul-2006  ssmukher     115.81       Made modification in the
                                          eoy_archive_data procedure to
                                          incorporate the PPIP tax.
   28-AUG-2006  pganguly     115.82       Fixed bug# 4025900. Changed the code
                                          for Box 14 so that it subtracts OTHER
                                          _INFORMATION71 before archiving.
   30-Aug-2007  ssmukher     115.83       Bug 5706114 fix.T4 Box44 and T4 Box20
                                          should not be reported for Status
                                          indian employee.Modified the proc
                                          eoy_archive_data.
   4-SEPT-2007 ssmukher      115.84       Fix for bug# 3447439.Modified the
                                          cursor c_get_latest_asg in
                                          eoy_archive_data to fetch the
                                          earn date and assignment action id.
                                          This earn date will be used to fetch
                                          the CPP/QPP and EI exempt flag for
                                          an employee in a particular province.
   6-SEPT-2007 amigarg       115.85       Fix for bug# 5698016.Added the
                                          T4_other_info_amount for code 81-85.
   19-SEP-2007 amigarg       115.87       Fix for bug# 6399498.archived the
                                          registration number for status_indian
   11-DEC-2007 tclewis       115.88       In the package eoy_action_creation modified
                                          The cursor c_eoy_gre  removed the subquery
                                          Modified the cursor c_get_latest_asg added
                                          Hints.

   19-SEP-2008 sneelapa      115.89       Fix for bug# 6399498.
                                          During QA testing bug 6399498 was reopened.

                                          Modified CURSOR LOOP of c_balance_feed_info
                                          and IF condition before CURSOR LOOP
                                          so that c_balance_feed_info CURSOR will
                                          get the "registration number" value
                                          of T4_BOX52 Element incase of Status Indian Employee
                                          and for non status indian employee get
                                          the reg number of T4_BOX52 if value
                                          for T4_BOX52 exists else get reg number
                                          of T4_BOX20.

   23-SEP-2008 sneelapa      115.91       Fix for bug# 6399498.

   25-SEP-2008 sneelapa      115.93       Fix for bug# 6399498.
                                          Modified CURSOR Query of c_balance_feed_info
                                          previous version of package date was hardcoded
                                          as '31-DEC-4712', which is against coding standards.

   26-SEP-2008 sneelapa      115.95       Fix for bug# 6399498.
                                          Modified CURSOR Query of c_balance_feed_info
                                          WHERE Condition pee.effective_start_date >= l_year_start
                                          is modified as
                                          pee.effective_start_date <= l_year_end
                                          IF an Employee is having two PA elements
                                          One attached in 2006 and second one in 2008
                                          and Archiver is run for 2008, 2006 Element was
                                          not picked up.
   30-OCT-2009 aneghosh      115.96       Fix for Bug 8576897.
                                          Removed the deduction of Box 53 from
                                          Box14.

   09-DEC-2009 sneelapa      115.97       Fix for Bug 9135405.
                                          Modified eoy_archive_data procedure to
                                          archive data for T4 Other Info new codes.

   31-DEC-2009 sneelapa      115.98       Fix for Bug 9135405.
                                          Modified eoy_archive_data procedure to
                                          not to include Other Info Codes 66 to 69
                                          in Gross Income (Box 14).
*/


   sqwl_range varchar2(4000);
   eoy_gre_range varchar2(4000);
   eoy_all_range varchar2(4000);

/* Returns the value of a legislative_parameter from pay_payroll_actions  */

function get_parameter(name in varchar2,
                       parameter_list varchar2)
return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ', start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;

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
     select to_number(UE.creator_id)
     from  ff_user_entities  UE,
           ff_database_items DI
     where  DI.user_name            = p_db_item_name
       and  UE.user_entity_id       = DI.user_entity_id
       and  Ue.creator_type         = 'B'
       and  UE.legislation_code     = 'CA';

   l_defined_balance_id pay_defined_balances.defined_balance_id%type;

 begin

   open csr_defined_balance;
   fetch csr_defined_balance into l_defined_balance_id;
   if csr_defined_balance%notfound then
     close csr_defined_balance;
     hr_utility.raise_error;
   else
     close csr_defined_balance;
   end if;

   return (l_defined_balance_id);

 end bal_db_item;


 /* Name    : get_dates
  Purpose   : The dates are dependent on the report being run
              For T4 it is year end dates.

 */

 procedure get_dates
 (
  p_report_type    in     varchar2,
  p_effective_date in     date,
  p_period_end     in out nocopy date,
  p_quarter_start  in out nocopy date,
  p_quarter_end    in out nocopy date,
  p_year_start     in out nocopy date,
  p_year_end       in out nocopy date
 ) is
  begin

    if p_report_type = 'T4' then

      p_period_end    := add_months(trunc(p_effective_date, 'Y'),12) - 1;
      p_quarter_start := trunc(p_period_end, 'Q');
      p_quarter_end   := p_period_end;

    end if;

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
  p_quarter_start        date,
  p_quarter_end          date,
  p_year_start           date,
  p_year_end             date,
  /* Information returned is used to control the selection of people to
     report on. */
  p_period_start         in out nocopy date,
  p_period_end           in out nocopy date,
  p_defined_balance_id   in out nocopy number,
  p_group_by_gre         in out nocopy boolean,
  p_tax_unit_context     in out nocopy boolean,
  p_jurisdiction_context in out nocopy boolean
 ) is

 begin

   /* Depending on the report being processed, derive all the information
      required to be able to select the people to report on. */

   if    p_report_type = 'T4'  then

     /* Default settings for Year End Pre-process. */

     p_period_start         := p_year_start;
     p_period_end           := p_year_end;
     p_defined_balance_id   := bal_db_item('GROSS_EARNINGS_PER_GRE_YTD');
     p_group_by_gre         := FALSE;
     p_tax_unit_context     := TRUE;
     p_jurisdiction_context := FALSE;

   /* For EOY - end */

   /* An invalid report type has been passed so fail. */

   else

     hr_utility.raise_error;

   end if;

 end get_selection_information;




 /* Name    : eoy_action_creation
  Purpose   : This creates the assignment actions for a specific chunk
              of people to be archived by the year end pre-process.
  Arguments :
  Notes     :
 */

 procedure eoy_action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is



   /* Variables used to hold the select columns from the SQL statement.*/

   l_person_id              number;
   l_assignment_id          number;
   l_tax_unit_id            number;
   l_eoy_tax_unit_id            number;
   l_effective_end_date     date;
  l_archive_item_id               number;
  l_user_entity_name_tab    pay_ca_eoy_archive.char240_data_type_table;

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

   /* Indicator variables used to control which contexts are set up for
      balance. */

   l_tax_unit_context       boolean := FALSE;
   l_jurisdiction_context   boolean := FALSE;

   /* Variables used to hold the current values returned within the loop for
      checking against the new values returned from within the loop on the
      next iteration. */

   l_prev_person_id         per_all_people_f.person_id%type;
   l_prev_tax_unit_id       hr_all_organization_units.organization_id%type;

   /* Variable to hold the jurisdiction code used as a context for state
      reporting. */

   l_jurisdiction_code      varchar2(30);

   /* general process variables */

   l_report_type    pay_payroll_actions.report_type%type;
   l_province          pay_payroll_actions.report_qualifier%type;
   l_value          number;
   l_effective_date date;
   l_quarter_start  date;
   l_quarter_end    date;
   l_year_start     date;
   l_year_end       date;
   lockingactid     number;
   l_primary_asg    pay_assignment_actions.assignment_id%type;
   l_legislative_parameters    varchar2(240);


   /* For Year End Preprocess we have to archive the assignments
      belonging to a GRE  */
/*
   CURSOR c_eoy_gre IS
     SELECT ASG.person_id            person_id,
            ASG.assignment_id        assignment_id,
            ASG.effective_end_date   effective_end_date
     FROM
       per_all_assignments_f ASG
     WHERE
        ASG.business_group_id = l_bus_group_id AND
        asg.assignment_type = 'E' AND
        ASG.person_id between stperson and  endperson AND
        EXISTS
        (SELECT 1
         FROM pay_payroll_actions ppa,
              pay_assignment_actions paa
         WHERE
              ppa.business_group_id = l_bus_group_id AND
              ppa.payroll_action_id = paa.payroll_action_id AND
              ppa.action_type in ('R','Q','V','B','I') AND
              ppa.effective_date BETWEEN ASG.effective_start_date AND
                                         ASG.effective_end_date AND
              ppa.effective_date between l_period_start AND
                                l_period_end AND
              paa.assignment_id = ASG.assignment_id AND
              paa.tax_unit_id = l_eoy_tax_unit_id)
     ORDER  BY 1, 3 DESC, 2;
 */

  CURSOR c_eoy_gre IS
    SELECT  /*+ Ordered
                INDEX (asg PER_ASSIGNMENTS_F_N12)
                INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                INDEX(ppa PAY_PAYROLL_ACTIONS_PK) */
            DISTINCT ASG.person_id   person_id
      FROM
            per_all_assignments_f      ASG,
            pay_assignment_actions paa,
            pay_payroll_actions ppa

     WHERE  ppa.effective_date between l_period_start
                               and l_period_end
     and  ppa.action_type in ('R','Q','V','B','I')
     and  ppa.action_status = 'C'
     and  ppa.business_group_id + 0 = l_bus_group_id
     and  ppa.payroll_action_id = paa.payroll_action_id
     and  paa.tax_unit_id = l_eoy_tax_unit_id
     and  paa.action_status = 'C'
     and  paa.assignment_id = ASG.assignment_id
     and  ppa.business_group_id = ASG.business_group_id +0
     and  ppa.effective_date between ASG.effective_start_date
                             and  ASG.effective_end_date
     AND  ASG.person_id between stperson and endperson
     AND  ASG.assignment_type  = 'E';

--Original query:
/*    SELECT  DISTINCT
            ASG.person_id               person_id
      FROM
            per_all_assignments_f      ASG,
            pay_all_payrolls_f         PPY
     WHERE  exists
           (select /*+ INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                       INDEX(ppa PAY_PAYROLL_ACTIONS_PK) */
/*                   'x'
              from pay_payroll_actions ppa,
                   pay_assignment_actions paa
             where ppa.effective_date between l_period_start
                                          and l_period_end
               and  ppa.action_type in ('R','Q','V','B','I')
               and  ppa.action_status = 'C'
               and  ppa.business_group_id + 0 = l_bus_group_id
               and  ppa.payroll_action_id = paa.payroll_action_id
               and  paa.tax_unit_id = l_eoy_tax_unit_id
               and  paa.action_status = 'C'
               and  paa.assignment_id = ASG.assignment_id
               and  ppa.business_group_id = ASG.business_group_id +0
               and  ppa.effective_date between ASG.effective_start_date
                                           and  ASG.effective_end_date)
       AND  ASG.person_id between stperson and endperson
       AND  ASG.assignment_type  = 'E'
       AND  PPY.payroll_id       = ASG.payroll_id;
*/

/* Commented c_eoy_all, because Tax Unit id is a mandatory parameter
   in archiver process, this cursor will never be used */
/*
   CURSOR c_eoy_all IS
     SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            to_number(SCL.segment1)     tax_unit_id,
            ASG.effective_end_date      effective_end_date
     FROM   per_all_assignments_f      ASG,
            hr_soft_coding_keyflex SCL,
            pay_all_payrolls_f         PPY
     WHERE  ASG.business_group_id + 0  = l_bus_group_id
       AND  ASG.person_id between stperson and endperson
       AND  ASG.assignment_type        = 'E'
       AND  ASG.effective_start_date  <= l_period_end
       AND  ASG.effective_end_date    >= l_period_start
       AND  SCL.soft_coding_keyflex_id = ASG.soft_coding_keyflex_id
       AND  PPY.payroll_id             = ASG.payroll_id
     ORDER  BY 1, 3, 4 DESC, 2;
 */
   /* Get the primary assignment for the given person_id */

   CURSOR c_get_asg_id (p_person_id number) IS
     SELECT assignment_id
     from per_all_assignments_f paf
     where person_id = p_person_id
     and   primary_flag = 'Y'
     and   paf.effective_start_date  <= l_period_end
     and   paf.effective_end_date    >= l_period_start
     and   paf.assignment_type = 'E'
     ORDER BY assignment_id desc;

     /* Cursor to get the latest assignment_action_id based
        on person_id. Bug#3267520 */
            CURSOR c_get_latest_asg(p_person_id number ) IS
            select /*+ Ordered
                       INDEX (asg PER_ASSIGNMENTS_F_N12)
                       INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                       INDEX(ppa PAY_PAYROLL_ACTIONS_PK) */
                paa.assignment_action_id
              from  per_all_assignments_f      paf,
                    pay_assignment_actions     paa,
                    pay_payroll_actions        ppa,
                    pay_action_classifications pac
              where paf.person_id     = p_person_id
               and paa.assignment_id = paf.assignment_id
               and paa.tax_unit_id   = l_tax_unit_id
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
                    and paa.source_action_id is null))
               order by paa.action_sequence desc;


/* Original Query:
            select paa.assignment_action_id
              from pay_assignment_actions     paa,
                   per_all_assignments_f      paf,
                   pay_payroll_actions        ppa,
                   pay_action_classifications pac
              where paf.person_id     = p_person_id
               and paa.assignment_id = paf.assignment_id
               and paa.tax_unit_id   = l_tax_unit_id
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
                    and paa.source_action_id is null))
               order by paa.action_sequence desc;
*/

    /* local variables Bug#3267520 */
     ln_non_taxable_earnings number(30);
     ln_gross_earnings       number(30);
     ln_no_gross_earnings    number(30);
     ln_max_aa_id            number;

   begin

     /* Get the report type, report qualifier, business group id and the
        gre for which the archiving has to be done */

     hr_utility.trace('getting report type ');

     select effective_date,
            report_type,
            business_group_id,
            legislative_parameters
     into   l_effective_date,
            l_report_type,
            l_bus_group_id,
            l_legislative_parameters
     from pay_payroll_actions
     where payroll_action_id = pactid;

   l_eoy_tax_unit_id := get_parameter('TRANSFER_GRE',l_legislative_parameters);

     hr_utility.trace('getting dates');

     get_dates(l_report_type,
               l_effective_date,
               l_period_end,
               l_quarter_start,
               l_quarter_end,
               l_year_start,
               l_year_end);

     hr_utility.trace('getting selection information');
     hr_utility.trace('report type '|| l_report_type);
     hr_utility.trace('quarter start '|| to_char(l_quarter_start,'dd-mm-yyyy'));
     hr_utility.trace('quarter end '|| to_char(l_quarter_end,'dd-mm-yyyy'));
     hr_utility.trace('year start '|| to_char(l_year_start,'dd-mm-yyyy'));
     hr_utility.trace('year end '|| to_char(l_year_end,'dd-mm-yyyy'));

     get_selection_information
         (l_report_type,
          l_quarter_start,
          l_quarter_end,
          l_year_start,
          l_year_end,
          l_period_start,
          l_period_end,
          l_defined_balance_id,
          l_group_by_gre,
          l_tax_unit_context,
          l_jurisdiction_context);

     /*
        if l_eoy_tax_unit_id <> 99999 then
        open c_eoy_gre;
     end if;
      else
        open c_eoy_all;
      */
        open c_eoy_gre;

     /* Loop for all rows returned for SQL statement. */

     hr_utility.trace('Entering loop');

     loop

        if l_eoy_tax_unit_id <> 99999 then

           hr_utility.trace('Fetching person id');

           fetch c_eoy_gre into l_person_id;

           l_tax_unit_id := l_eoy_tax_unit_id;

           exit when c_eoy_gre%NOTFOUND;
/*
        else

           fetch c_eoy_all into l_person_id,
                                l_assignment_id,
                                l_tax_unit_id,
                                l_effective_end_date;

           exit when c_eoy_all%NOTFOUND;
*/
        end if;


        /* If the new row is the same as the previous row according to the way
           the rows are grouped then discard the row ie. grouping by GRE
           requires a single row for each person / GRE combination. */

           hr_utility.trace('tax unit id is '|| to_char(l_tax_unit_id));
           hr_utility.trace('previous tax unit id is '||
                                    to_char(l_prev_tax_unit_id));

        if ( l_person_id   = l_prev_person_id   and
             l_tax_unit_id = l_prev_tax_unit_id) then

          hr_utility.trace('Not creating Asg_action, duplicate');
          null;

        else

          hr_utility.trace('prev person is '|| to_char(l_prev_person_id));
          hr_utility.trace('person is '|| to_char(l_person_id));
          hr_utility.trace('assignment is '|| to_char(l_assignment_id));


          /* Have a new unique row according to the way the rows are grouped.
             The inclusion of the person is dependent on having a non zero
             balance. If the balance is non zero then an assignment action
             is created to indicate their inclusion in the T4 Magnetic Media
             and T4 Paper Reports. */

          /* Get the primary assignment */
          open c_get_asg_id(l_person_id);
          fetch c_get_asg_id into l_primary_asg;
          if c_get_asg_id%NOTFOUND then
             close c_get_asg_id;
             hr_utility.trace('Primary Asg Not found');
             hr_utility.raise_error;
          else
             close c_get_asg_id;
          end if;


          /* Bug#3267520, checking if any earnings exists or not */
             ln_max_aa_id := null;
             ln_non_taxable_earnings := 0;
             ln_gross_earnings       := 0;
             ln_no_gross_earnings    := 0;

          begin
            open c_get_latest_asg(l_person_id );
            fetch c_get_latest_asg into ln_max_aa_id;
            close c_get_latest_asg;
            hr_utility.trace('Action creation Max assignment_action_id : ' ||
                              to_char(ln_max_aa_id));

             exception
               when no_data_found then
                  ln_max_aa_id := -9999;
                  raise_application_error(-20001,
                       'Balance Assignment Action does not exist for : '
                             ||to_char(l_person_id));
          end;

          hr_utility.trace('Setting context');
          pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
          pay_ca_balance_view_pkg.set_context ('ASSIGNMENT_ACTION_ID',ln_max_aa_id);

            ln_non_taxable_earnings :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                           ('T4 Non Taxable Earnings',
                            'YTD',ln_max_aa_id,l_primary_asg,NULL,'PER',
                            l_tax_unit_id,l_bus_group_id,NULL),0);
            hr_utility.trace('T4 Non Taxable Earnings :'||
                            to_char(ln_non_taxable_earnings));

            ln_gross_earnings :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                           ('Gross Earnings',
                            'YTD',ln_max_aa_id,l_primary_asg,NULL,'PER' ,

                            l_tax_unit_id, l_bus_group_id, NULL),0);
            hr_utility.trace('Gross Earnings :'||
                            to_char(ln_gross_earnings));

            ln_no_gross_earnings :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                           ('T4 No Gross Earnings',
                            'YTD',ln_max_aa_id, l_primary_asg,NULL,'PER' ,
                            l_tax_unit_id, l_bus_group_id, NULL),0);
            hr_utility.trace('T4 No Gross Earnings :'||
                            to_char(ln_no_gross_earnings));

          /* End of adding code for bug#3267520, below If condition
             is also part of this bug fix */

           If (((ln_gross_earnings <> 0) and
               (ln_non_taxable_earnings <> ln_gross_earnings)) or
               (ln_no_gross_earnings <> 0)) then

             /* Create the assignment action to archive T4 details */

             select pay_assignment_actions_s.nextval
             into   lockingactid
             from   dual;

             /* Insert into pay_assignment_actions. */

              hr_utility.trace('creating assignment action');

              hr_nonrun_asact.insact(lockingactid,l_primary_asg,
                                     pactid,chunk,l_tax_unit_id);

             /* Update the serial number column with the person id
                so that we can use in the Magnetic Media process
                to do an additional check against the assignment table */

              hr_utility.trace('updating assignment action');

              update pay_assignment_actions aa
              set    aa.serial_number = to_char(l_person_id)
              where  aa.assignment_action_id = lockingactid;

              hr_utility.trace('Created Assignment action'||
                                           to_char(lockingactid));

           End if; --Checking Gross Earnings, No Gross Earnings, NonTaxable Earn

     end if; -- validation l_person_id = l_prev_person_id

     /* Record the current values for the next time around the loop. */

     l_prev_person_id   := l_person_id;
     l_prev_tax_unit_id := l_tax_unit_id;

   end loop;

   if l_eoy_tax_unit_id <> 99999 then
      close c_eoy_gre;
/*
   else
      close c_eoy_all;
*/
   end if;


 end eoy_action_creation;



  /*
     Name      : get_user_entity_id
     Purpose   : This gets the user_entity_id for a specific database item name.
     Arguments : p_dbi_name -> database item name.
     Notes     :
  */

  function get_user_entity_id (p_dbi_name in varchar2)
           return number is
  l_user_entity_id  number;

  begin

    select fdi.user_entity_id
    into l_user_entity_id
    from ff_database_items fdi,
         ff_user_entities  fui
    where user_name = p_dbi_name
    and   fdi.user_entity_id = fui.user_entity_id
    and   fui.legislation_code = 'CA';

    return l_user_entity_id;

    exception
    when others then
    hr_utility.trace('Error while getting the user_entity_id for '
                                     || p_dbi_name);
    hr_utility.raise_error;

  end get_user_entity_id;



  /*
     Name      : compare_archive_data
     Purpose   : compares Federal YEPP data and Federal YE Amendment Data
     Arguments : p_assignment_action_id -> Assignment_action_id
                 p_locked_action_id     -> YEPP Assignment_action_id
                 p_jurisdiction         -> Jurisdiction_code

     Notes     : Used specifically for Federal YE Amendment Pre-Process (YE-2003)
  */

Function compare_archive_data(p_assignment_action_id in number
                              ,p_locked_action_id in number
                              ,p_jurisdiction in varchar2
                              ) return varchar2 is
TYPE act_info_rec IS RECORD
   ( archive_context1      number(25)
      ,archive_ue_id    number(25)
      ,archive_value    varchar2(240)
   );

TYPE number_data_type_table IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE action_info_table IS TABLE OF act_info_rec
 INDEX BY BINARY_INTEGER;

ltr_amend_arch_data action_info_table;
ltr_yepp_arch_data action_info_table;
ltr_amend_emp_data action_info_table;
ltr_yepp_emp_data action_info_table;
ltr_emp_ue_id number_data_type_table;

-- Cursor to get archived values based on Asg_act_id,jurisdiction
cursor c_get_emp_t4box_data(cp_asg_act_id number,
                            cp_jurisdiction varchar2) is
SELECT fai1.context1,fdi1.user_entity_id,fai1.value
FROM FF_ARCHIVE_ITEMS FAI1,
     ff_database_items fdi1,
     ff_archive_item_contexts faic,
     ff_contexts fc
WHERE FAI1.USER_ENTITY_ID = fdi1.user_entity_id
and fai1.archive_item_id = faic.archive_item_id
and fc.context_id = faic.context_id
and fc.context_name = 'JURISDICTION_CODE'
and faic.context = cp_jurisdiction
AND FAI1.CONTEXT1 = cp_asg_act_id
AND fdi1.user_name <> 'CAEOY_T4_AMENDMENT_FLAG'
order by fdi1.user_name;

-- Cursor to get archived values based on Asg_act_id
cursor c_get_employee_data(cp_asg_act_id number,
                           cp_dbi_ue_id number) is
select fai.context1,fai.user_entity_id,fai.value
from   ff_archive_items   fai
where  fai.user_entity_id = cp_dbi_ue_id
and    fai.context1  =    cp_asg_act_id;

i number;
j number;
lv_flag varchar2(2);
ln_yepp_box_count number;
ln_amend_box_count number;


 begin
--   hr_utility.trace_on('Y','TEST');
   /* Initialization Process */
    lv_flag := 'N';
    if ltr_amend_arch_data.count > 0 then
       ltr_amend_arch_data.delete;
    end if;

    if ltr_yepp_arch_data.count > 0 then
       ltr_yepp_arch_data.delete;
    end if;

    if ltr_amend_emp_data.count > 0 then
       ltr_amend_emp_data.delete;
    end if;

    if ltr_yepp_emp_data.count > 0 then
       ltr_yepp_emp_data.delete;
    end if;

    if ltr_emp_ue_id.count > 0 then
       ltr_emp_ue_id.delete;
    end if;


    j := 0;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_INITIAL');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_FIRST_NAME');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_LAST_NAME');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_SIN');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_NUMBER');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_ADDRESS_LINE1');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_ADDRESS_LINE2');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_ADDRESS_LINE3');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_ADDRESS_LINE4');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_CITY');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_PROVINCE');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_COUNTRY');

    j := j+1;
    ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_POSTAL_CODE');


   /* Populate T4 Amendment Box Data for an assignment_action */
     open c_get_emp_t4box_data(p_assignment_action_id,p_jurisdiction);
      hr_utility.trace('Populating T4 Amendment Box Data ');
      hr_utility.trace('P_assignment_action_id :'||to_char(p_assignment_action_id));
     ln_amend_box_count := 0;
     loop
        fetch c_get_emp_t4box_data into ltr_amend_arch_data(ln_amend_box_count);
        exit when c_get_emp_t4box_data%NOTFOUND;

        hr_utility.trace('I :'||to_char(ln_amend_box_count));
        hr_utility.trace('Archive_Context1: '||to_char(ltr_amend_arch_data(ln_amend_box_count).archive_context1));
        hr_utility.trace('Archive_UE_id: '||to_char(ltr_amend_arch_data(ln_amend_box_count).archive_ue_id));
        hr_utility.trace('Archive_Value: '||ltr_amend_arch_data(ln_amend_box_count).archive_value);
        ln_amend_box_count := ln_amend_box_count + 1;
     end loop;

     close c_get_emp_t4box_data;

   /* Populate T4 Amendment Employee Data for an assignment_action */
         hr_utility.trace('Populating Amendment Employee Data ');
         hr_utility.trace('P_assignment_action_id :'||to_char(p_assignment_action_id));
     for i in 0 .. j
     loop
        open c_get_employee_data(p_assignment_action_id,ltr_emp_ue_id(i));
        fetch c_get_employee_data into ltr_amend_emp_data(i);

        hr_utility.trace('I :'||to_char(i));
        hr_utility.trace('Archive_Context1: '||to_char(ltr_amend_emp_data(i).archive_context1));
        hr_utility.trace('Archive_UE_id: '||to_char(ltr_amend_emp_data(i).archive_ue_id));
        hr_utility.trace('Archive_Value: '||ltr_amend_emp_data(i).archive_value);

        close c_get_employee_data;
     end loop;


   /* Populate T4 YEPP Box Data for an assignment_action */
     open c_get_emp_t4box_data(p_locked_action_id,p_jurisdiction);
      hr_utility.trace('Populating T4 YEPP Box Data ');
      hr_utility.trace('P_locked_action_id :'||to_char(p_locked_action_id));
      ln_yepp_box_count := 0;
     loop
        fetch c_get_emp_t4box_data into ltr_yepp_arch_data(ln_yepp_box_count);
        exit when c_get_emp_t4box_data%NOTFOUND;

        hr_utility.trace('I :'||to_char(ln_yepp_box_count));
        hr_utility.trace('Archive_Context1: '||to_char(ltr_yepp_arch_data(ln_yepp_box_count).archive_context1));
        hr_utility.trace('Archive_UE_id: '||to_char(ltr_yepp_arch_data(ln_yepp_box_count).archive_ue_id));
        hr_utility.trace('Archive_Value: '||ltr_yepp_arch_data(ln_yepp_box_count).archive_value);
        ln_yepp_box_count := ln_yepp_box_count + 1;
     end loop;

     close c_get_emp_t4box_data;

   /* Populate T4 YEPP Employee Data for an assignment_action */
         hr_utility.trace('Populating YEPP Employee Data ');
         hr_utility.trace('P_locked_action_id :'||to_char(P_locked_action_id));
     for i in 0 .. j
     loop
        open c_get_employee_data(P_locked_action_id,ltr_emp_ue_id(i));
        fetch c_get_employee_data into ltr_yepp_emp_data(i);
        exit when c_get_employee_data%NOTFOUND;

        hr_utility.trace('I :'||to_char(i));
        hr_utility.trace('Archive_Context1: '||to_char(ltr_yepp_emp_data(i).archive_context1));
        hr_utility.trace('Archive_UE_id: '||to_char(ltr_yepp_emp_data(i).archive_ue_id));
        hr_utility.trace('Archive_Value: '||ltr_yepp_emp_data(i).archive_value);

        close c_get_employee_data;
     end loop;

   /* Compare T4 Amendment Box Data and T4 YEPP Box Data for an
      assignment_action */

     hr_utility.trace('Comparing T4 Amend and T4 YEPP Box Data ');

     if ln_yepp_box_count <> ln_amend_box_count then
         lv_flag := 'Y';
     elsif ln_yepp_box_count = ln_amend_box_count then
      for i in ltr_yepp_arch_data.first..ltr_yepp_arch_data.last
       loop
          if (ltr_yepp_arch_data(i).archive_ue_id =
              ltr_amend_arch_data(i).archive_ue_id) then

               if ((ltr_yepp_arch_data(i).archive_value <>
                    ltr_amend_arch_data(i).archive_value) or
                   (ltr_yepp_arch_data(i).archive_value is null and
                    ltr_amend_arch_data(i).archive_value is not null) or
                   (ltr_yepp_arch_data(i).archive_value is not null and
                    ltr_amend_arch_data(i).archive_value is null)) then

                lv_flag := 'Y';
                hr_utility.trace('Archive_UE_id with differnt value :'||to_char(ltr_yepp_arch_data(i).archive_ue_id));
                exit;
             end if;
          end if;
       end loop;
     end if;

   /* Compare T4 Employee Data and T4 YEPP Employee Data for an
      assignment_action */
     If lv_flag <> 'Y' then

     hr_utility.trace('Comparing T4 Amend and T4 YEPP Employee Data ');
     for i in ltr_yepp_emp_data.first..ltr_yepp_emp_data.last
       loop
          if (ltr_yepp_emp_data(i).archive_ue_id =
              ltr_amend_emp_data(i).archive_ue_id) then

             if ((ltr_yepp_emp_data(i).archive_value <>
                  ltr_amend_emp_data(i).archive_value) or
                 (ltr_yepp_emp_data(i).archive_value is null and
                  ltr_amend_emp_data(i).archive_value is not null) or
                 (ltr_yepp_emp_data(i).archive_value is not null and
                  ltr_amend_emp_data(i).archive_value is null)) then

                 lv_flag := 'Y';
                 hr_utility.trace('Archive_UE_id with different value :'||
                                 to_char(ltr_yepp_arch_data(i).archive_ue_id));
                 exit;
             end if;
          end if;
       end loop;

     End if; -- p_flag <> 'Y'

    /* If there is no value difference for Entire Employee data then set
       flag to 'N' */

     if lv_flag <> 'Y' then
        lv_flag := 'N';
        hr_utility.trace('No value difference for an Employee Asg Action: '||
                          to_char(p_assignment_action_id));
     end if;

        hr_utility.trace('lv_flag :'||lv_flag);
     return lv_flag;
--        hr_utility.trace_off;
end compare_archive_data;



  /* Name      : eoy_archive_gre_data
     Purpose   : This performs the CA specific employer data archiving.
     Arguments :
     Notes     :
  */

  procedure eoy_archive_gre_data(p_payroll_action_id in number,
                                 p_tax_unit_id       in number,
                                 p_transmitter_gre_id in number)
  is

  l_user_entity_id          number;
  l_taxunit_context_id      number;
  l_jursd_context_id        number;
  l_value                   varchar2(240);
  l_sit_uid                 number;
  l_sui_uid                 number;
  l_fips_uid                number;
  l_counter                 number;
  l_seq_tab                 pay_ca_eoy_archive.number_data_type_table;
  l_context_id_tab          pay_ca_eoy_archive.number_data_type_table;
  l_context_val_tab         pay_ca_eoy_archive.char240_data_type_table;
  l_user_entity_name_tab    pay_ca_eoy_archive.char240_data_type_table;
  l_balance_type_tab        pay_ca_eoy_archive.char240_data_type_table;
  l_user_entity_value_tab   pay_ca_eoy_archive.char240_data_type_table;
  l_arch_gre_step           number := 0;
  l_name                    varchar2(240);
  l_business_group_id       number;
  l_seq                     number;
  l_context_id              number;
  l_context_val             varchar2(240);
  l_employer_ein            varchar2(240);
  l_address_line_1          varchar2(240);
  l_address_line_2          varchar2(240);
  l_address_line_3          varchar2(240);
  l_town_or_city            varchar2(240);
  l_province_code           varchar2(240);
  l_postal_code             varchar2(240);
  l_country_code            varchar2(240);
  l_accounting_contact_name varchar2(240);
  l_accounting_contact_phone varchar2(240);
  l_accounting_contact_area_code varchar2(240);
  l_technical_contact_area_code varchar2(240);
  l_accounting_contact_extension varchar2(240);
  l_proprietor_sin_1         varchar2(240);
  l_proprietor_sin_2         varchar2(240);
  l_transmitter_name         varchar2(240);
  l_transmitter_type_indicator    varchar2(240);
  l_transmitter_type_code         varchar2(240);
  l_transmitter_data_type_code    varchar2(240);
  l_transmitter_number            varchar2(240);
  l_transmitter_addr_line_1       varchar2(240);
  l_transmitter_addr_line_2       varchar2(240);
  l_transmitter_addr_line_3       varchar2(240);
  l_transmitter_city              varchar2(240);
  l_transmitter_province          varchar2(240);
  /*l_Federal_Youth_Hire_Ind        varchar2(80); */
  l_transmitter_postal_code       varchar2(240);
  l_transmitter_country           varchar2(240);
  l_transmitter_orgid             number;
  l_technical_contact_name        varchar2(240);
  l_technical_contact_phone       varchar2(240);
  l_technical_contact_extn        varchar2(240);
  l_technical_contact_email       varchar2(240);
  l_technical_contact_language    varchar2(240);
  l_object_version_number         number;
  l_some_warning                  boolean;
  l_archive_item_id               number;
  l_taxation_year                 varchar2(240);
  l_effective_date                date;
  result                          number;
  employer_info_found             varchar2(1);
  l_ei_rate                       number;

  cursor cur_bg(p_tax_unit_id1 number) is
  select
    business_group_id
  from
    hr_all_organization_units
  where
    organization_id = p_tax_unit_id1;

  cursor employer_info is
  select
    nvl(hoi6.ORG_INFORMATION9,hou.name) GRE_stat_report_name,
    hoi6.ORG_INFORMATION1 Employer_identification_number,
    hl.ADDRESS_LINE_1 GRE_addrline1,
    hl.ADDRESS_LINE_2 GRE_addrline2,
    hl.ADDRESS_LINE_3 GRE_addrline3,
    hl.TOWN_OR_CITY   GRE_town_or_city,
    DECODE(hl.STYLE , 'US' , hl.REGION_2 ,
                       'CA' , hl.REGION_1 ,
                       'CA_GLB',hl.region_1, ' ')  GRE_province,
    hl.POSTAL_CODE GRE_postal_code,
    hl.COUNTRY     GRE_country,
    hoi6.org_information3 ei_rate
  from
    hr_all_organization_units hou,
    hr_organization_information hoi6,
    hr_locations_all hl
  where
    hou.organization_id = p_tax_unit_id
    and hou.organization_id = hoi6.organization_id
    and hoi6.org_information_context = 'Canada Employer Identification'
    and hoi6.org_information5 in ('T4/RL1','T4/RL2')
    and hou.location_id = hl.location_id;

  cursor cur_employer_info is
  select
    hoi5.ORG_INFORMATION10 GRE_acct_contact_name,
    hoi5.ORG_INFORMATION12 GRE_acct_contact_phone,
    hoi5.ORG_INFORMATION11 GRE_acct_contact_area_code,
    hoi5.ORG_INFORMATION13 GRE_acct_contact_extn,
    hoi5.ORG_INFORMATION14 GRE_Proprietor_SIN#1,
    hoi5.ORG_INFORMATION15 GRE_Proprietor_SIN#2/*,
    hoi5.ORG_INFORMATION16 GRE_Fedyouth_hire_Prgind*/
  from
    hr_organization_information hoi5
  where
    hoi5.organization_id = p_tax_unit_id
    and hoi5.org_information_context = 'Fed Magnetic Reporting';

  cursor cur_transmitter_info is
  select
    nvl(hoi3.ORG_INFORMATION9,hou.name) trans_stat_report_name,
    hl.ADDRESS_LINE_1 trans_addrline1,
    hl.ADDRESS_LINE_2 trans_addrline2,
    hl.ADDRESS_LINE_3 trans_addrline3,
    hl.TOWN_OR_CITY   trans_town_or_city,
    DECODE(hl.STYLE , 'US', hl.REGION_2,
                      'CA', hl.REGION_1,
                      'CA_GLB',hl.region_1, ' ')  trans_province,
    hl.POSTAL_CODE trans_postal_code,
    hl.COUNTRY     trans_country,
    hoi2.org_information5 trans_type_indicator,
    hoi2.ORG_INFORMATION4 trans_number,
    hoi2.ORG_INFORMATION2 trans_type_code,
    hoi2.ORG_INFORMATION3 trans_datatype_code,
    hoi2.ORG_INFORMATION6 trans_tech_contact_name,
    hoi2.ORG_INFORMATION8 trans_tech_contact_phone,
    hoi2.ORG_INFORMATION7 trans_tech_contact_areacode,
    hoi2.ORG_INFORMATION9 trans_tech_contact_lang,
    hoi2.ORG_INFORMATION17 trans_tech_contact_extn,
    hoi2.ORG_INFORMATION18 trans_tech_contact_email
  from
    hr_all_organization_units hou,
    hr_organization_information hoi2,
    hr_organization_information hoi3,
    hr_locations_all hl
  where
    hou.organization_id = p_transmitter_gre_id
    and hou.organization_id = hoi2.organization_id
    and hoi2.org_information_context = 'Fed Magnetic Reporting'
    and hoi2.org_information1 = 'Y'
--    and hoi2.org_information2 = '904'  --comented for bug 3973040
    and hou.organization_id = hoi3.organization_id
    and hoi3.org_information_context = 'Canada Employer Identification'
    and hou.location_id = hl.location_id;

begin
/* payroll action level database items */

    l_arch_gre_step := 30;

 /* Archive the Employer level data */

   --hr_utility.trace_on('Y','CAEOY');
     hr_utility.trace('getting employer data  ');

     open cur_bg(p_tax_unit_id);
     fetch
       cur_bg
     into
       l_business_group_id;
     close cur_bg;

     open employer_info;
     fetch employer_info
     into
       l_name,
       l_employer_ein,
       l_address_line_1,
       l_address_line_2,
       l_address_line_3,
       l_town_or_city,
       l_province_code,
       l_postal_code,
       l_country_code,
       l_ei_rate;

     if employer_info%NOTFOUND then

       hr_utility.trace('cannot find employer data  ');
       employer_info_found := 'N';

       l_employer_ein := null;
       l_address_line_1 := null;
       l_address_line_2 := null;
       l_address_line_3 := null;
       l_town_or_city := null;
       l_province_code := null;
       l_postal_code := null;
       l_country_code := null;
       l_name         := null;

       close employer_info;

     else

       close employer_info;
       hr_utility.trace('Employer data found !!!! ');
       employer_info_found := 'Y';

     end if;

     open cur_employer_info;
     fetch cur_employer_info
     into
       l_accounting_contact_name,
       l_accounting_contact_phone ,
       l_accounting_contact_area_code,
       l_accounting_contact_extension,
       l_proprietor_sin_1,
       l_proprietor_sin_2;/*,
       l_federal_youth_hire_ind*/

     if cur_employer_info%NOTFOUND then

       hr_utility.trace('cannot find employer data 2 ');
       employer_info_found := 'N';

       l_proprietor_sin_1 := null;
       l_proprietor_sin_2 := null;
      /* l_federal_youth_hire_ind := null; */
       l_accounting_contact_name := null;
       l_accounting_contact_phone := null;
       l_accounting_contact_area_code := null;
       l_accounting_contact_extension  := null;
       l_accounting_contact_area_code := null;
       l_accounting_contact_extension  := null;

       close cur_employer_info;

     else

       close cur_employer_info;
       hr_utility.trace('Employer data found 2 !!!! ');
       employer_info_found := 'Y';

     end if;

     open cur_transmitter_info;
     fetch cur_transmitter_info
     into
       l_transmitter_name,
       l_transmitter_addr_line_1,
       l_transmitter_addr_line_2,
       l_transmitter_addr_line_3,
       l_transmitter_city,
       l_transmitter_province,
       l_transmitter_postal_code,
       l_transmitter_country,
       l_Transmitter_Type_Indicator,
       l_Transmitter_number,
       l_Transmitter_Type_code,
       l_Transmitter_data_type_code,
       l_technical_contact_name,
       l_technical_contact_phone,
       l_technical_contact_area_code,
       l_technical_contact_language,
       l_technical_contact_extn,
       l_technical_contact_email;

     if cur_transmitter_info%NOTFOUND then

       close cur_transmitter_info;
       hr_utility.trace('Transmitter information not found');

       l_transmitter_name := null;
       l_transmitter_addr_line_1 := null;
       l_transmitter_addr_line_2 := null;
       l_transmitter_addr_line_3 := null;
       l_transmitter_city := null;
       l_transmitter_province := null;
       l_transmitter_postal_code := null;
       l_transmitter_country := null;
       l_Transmitter_Type_Indicator := null;
       l_Transmitter_number := null;
       l_Transmitter_Type_code := null;
       l_Transmitter_data_type_code := null;
       l_technical_contact_name := null;
       l_technical_contact_phone := null;
       l_technical_contact_area_code := null;
       l_technical_contact_language := null;

       employer_info_found := 'N';

       hr_utility.set_message(801,'PAY_74014_NO_TRANSMITTER_ORG');
       hr_utility.set_message_token('ORGIND','GRE');
      /* push message into pay_message_lines */
      pay_core_utils.push_message(801,'PAY_74014_NO_TRANSMITTER_ORG','P');
      pay_core_utils.push_token('ORGIND','GRE');
              hr_utility.raise_error;

     else

       close cur_transmitter_info;
       employer_info_found := 'Y';

     end if;

begin

     select to_char(effective_date,'YYYY'),
     add_months(trunc(effective_date, 'Y'),12) - 1
     into   l_taxation_year,
            l_effective_date
     from pay_payroll_actions
     where payroll_action_id = p_payroll_action_id;

exception when no_data_found then
        l_taxation_year := null;
        l_effective_date := null;

end;

 select context_id
 into l_taxunit_context_id
 from ff_contexts
 where context_name = 'TAX_UNIT_ID';

 l_counter := 0;
 l_arch_gre_step := 40;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TAXATION_YEAR';
 l_user_entity_value_tab(l_counter)  := l_taxation_year;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TAX_UNIT_ID';
 l_user_entity_value_tab(l_counter)  := p_tax_unit_id;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_COUNTRY';
 l_user_entity_value_tab(l_counter)  := l_transmitter_country;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter)  := 'CAEOY_TRANSMITTER_NAME';
 l_user_entity_value_tab(l_counter) := l_transmitter_name;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter)  := 'CAEOY_TRANSMITTER_ADDRESS_LINE1';
 l_user_entity_value_tab(l_counter) := l_transmitter_addr_line_1;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_ADDRESS_LINE2';
 l_user_entity_value_tab(l_counter) := l_transmitter_addr_line_2;

-- Bug 4517693
 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_ADDRESS_LINE3';
 l_user_entity_value_tab(l_counter) := l_transmitter_addr_line_3;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_CITY';
 l_user_entity_value_tab(l_counter) := l_transmitter_city;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_PROVINCE';
 l_user_entity_value_tab(l_counter) := l_transmitter_province;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_POSTAL_CODE';
 l_user_entity_value_tab(l_counter) := l_transmitter_postal_code;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_TYPE_INDICATOR';
 l_user_entity_value_tab(l_counter) := l_transmitter_type_indicator;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_NUMBER';
 l_user_entity_value_tab(l_counter) := l_transmitter_number;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_TYPE_CODE';
 l_user_entity_value_tab(l_counter) := l_transmitter_type_code;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TRANSMITTER_DATA_TYPE_CODE';
 l_user_entity_value_tab(l_counter) := l_transmitter_data_type_code;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TECHNICAL_CONTACT_NAME';
 l_user_entity_value_tab(l_counter) := l_technical_contact_name;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TECHNICAL_CONTACT_PHONE';
 l_user_entity_value_tab(l_counter) := l_technical_contact_phone;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TECHNICAL_CONTACT_AREA_CODE';
 l_user_entity_value_tab(l_counter) := l_technical_contact_area_code;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TECHNICAL_CONTACT_EXTN';
 l_user_entity_value_tab(l_counter) := l_technical_contact_extn;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TECHNICAL_CONTACT_EMAIL';
 l_user_entity_value_tab(l_counter) := l_technical_contact_email;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_TECHNICAL_CONTACT_LANGUAGE';
 l_user_entity_value_tab(l_counter) := l_technical_contact_language;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_ACCOUNTING_CONTACT_NAME';
 l_user_entity_value_tab(l_counter) := l_accounting_contact_name;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_ACCOUNTING_CONTACT_PHONE';
 l_user_entity_value_tab(l_counter) := l_accounting_contact_phone ;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_ACCOUNTING_CONTACT_AREA_CODE';
 l_user_entity_value_tab(l_counter) := l_accounting_contact_area_code ;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_ACCOUNTING_CONTACT_EXTENSION';
 l_user_entity_value_tab(l_counter) := l_accounting_contact_extension ;


 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_NAME';
 l_user_entity_value_tab(l_counter) := l_name;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_IDENTIFICATION_NUMBER';
 l_user_entity_value_tab(l_counter) := l_employer_ein;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_ADDRESS_LINE1';
 l_user_entity_value_tab(l_counter) := l_address_line_1;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_ADDRESS_LINE2';
 l_user_entity_value_tab(l_counter) := l_address_line_2;

-- Bug 4517693
 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_ADDRESS_LINE3';
 l_user_entity_value_tab(l_counter) := l_address_line_3;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_CITY';
 l_user_entity_value_tab(l_counter) := l_town_or_city;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_PROVINCE';
 l_user_entity_value_tab(l_counter) := l_province_code;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_COUNTRY';
 l_user_entity_value_tab(l_counter) := l_country_code;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYER_POSTAL_CODE';
 l_user_entity_value_tab(l_counter) := l_postal_code;


 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_PROPRIETOR_SIN1';
 l_user_entity_value_tab(l_counter) := l_proprietor_sin_1;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_PROPRIETOR_SIN2';
 l_user_entity_value_tab(l_counter) := l_proprietor_sin_2;

/* l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter):='CAEOY_FEDERAL_YOUTH_HIRE_PROGRAM_INDICATOR';
 l_user_entity_value_tab(l_counter) := l_federal_youth_hire_ind; */

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_GRE_EI_RATE';
 l_user_entity_value_tab(l_counter) := l_ei_rate;

 for i in 1..l_counter loop

 l_arch_gre_step := 42;
      hr_utility.trace('calling archive API ' || l_user_entity_name_tab(i));
 ff_archive_api.create_archive_item(
  p_archive_item_id => l_archive_item_id
  ,p_user_entity_id  => get_user_entity_id(l_user_entity_name_tab(i))
  ,p_archive_value   => l_user_entity_value_tab(i)
  ,p_archive_type    => 'PA'
  ,p_action_id       => p_payroll_action_id
  ,p_legislation_code => 'CA'
  ,p_object_version_number  => l_object_version_number
  ,p_some_warning           => l_some_warning
   );
      hr_utility.trace('Ended calling archive API');
 l_arch_gre_step := 47;

end loop;

   g_archive_flag := 'Y';
exception
     when others then
      g_archive_flag := 'N';
      hr_utility.trace('Error in eoy_archive_gre_data at step :' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
      if l_arch_gre_step = 30 and l_transmitter_name is null then
       hr_utility.set_message(801,'PAY_74014_NO_TRANSMITTER_ORG');
       hr_utility.set_message_token('ORGIND','GRE');
      end if;

      hr_utility.raise_error;

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
               where fai.context1 = p_payroll_action_id
               and archive_type = 'PA');
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
      l_step                    number := 0;

 cursor c_get_min_chunk is
 select min(paa.chunk_number)
 from pay_assignment_actions paa
 where paa.payroll_action_id = p_payroll_action_id;
begin
      open c_get_min_chunk;
      fetch c_get_min_chunk into g_min_chunk;
         l_step := 1;
         if c_get_min_chunk%NOTFOUND then
           g_min_chunk := -1;
           raise_application_error(-20001,'eoy_archinit: Assignment actions not created!!!');
         end if;
      close c_get_min_chunk;

      hr_utility.set_location ('eoy_archinit min chunk is ' || to_char(g_min_chunk),12);
      l_step := 2;
      l_archive := chk_gre_archive(p_payroll_action_id);

      l_step := 3;
      hr_utility.trace ('eoy_archinit g_archive_flag is ' || g_archive_flag);
  exception
   when others then
        raise_application_error(-20001,'eoy_archinit at '
                                   ||to_char(l_step)||' - '||to_char(sqlcode) || '-' || sqlerrm);
end eoy_archinit;


  /* Name      : eoy_archive_data
     Purpose   : This performs the CA specific employee context setting for the
                 Year End PreProcess.
     Arguments :
     Notes     :
  */

  PROCEDURE eoy_archive_data(p_assactid in number,
                             p_effective_date in date) IS

  l_aaid                    pay_assignment_actions.assignment_action_id%type;
  l_aaseq                   pay_assignment_actions.action_sequence%type;
  l_asgid                   pay_assignment_actions.assignment_id%type;
  l_date_earned             date;
  l_user_entity_name_tab    pay_ca_eoy_archive.char240_data_type_table;
  l_balance_type_tab        pay_ca_eoy_archive.char240_data_type_table;
  l_user_entity_value_tab   pay_ca_eoy_archive.char240_data_type_table;
  l_tax_unit_id             pay_assignment_actions.tax_unit_id%type;
  l_business_group_id       pay_assignment_actions.tax_unit_id%type;
  l_year_start              date;
  l_year_end                date;
  l_context_no              number := 60;
  l_count                   number := 0;
  l_jurisdiction            varchar2(11);
  l_province_uei            ff_user_entities.user_entity_id%type;
  l_county_uei              ff_user_entities.user_entity_id%type;
  l_city_uei                ff_user_entities.user_entity_id%type;
  l_county_sd_uei           ff_user_entities.user_entity_id%type;
  l_city_sd_uei             ff_user_entities.user_entity_id%type;
  l_province_abbrev         pay_us_states.state_abbrev%type;
  l_county_name             pay_us_counties.county_name%type;
  l_city_name               pay_us_city_names.city_name%type;
  l_cnt_sd_name             pay_us_county_school_dsts.school_dst_name%type;
  l_cty_sd_name             pay_us_city_school_dsts.school_dst_name%type;
  l_step                    number := 0;
  l_county_code             varchar2(3);
  l_city_code               varchar2(4);
  l_jursd_context_id        ff_contexts.context_id%type;
  l_taxunit_context_id      ff_contexts.context_id%type;
  l_seq_tab                 pay_ca_eoy_archive.number_data_type_table;
  l_context_id_tab          pay_ca_eoy_archive.number_data_type_table;
  l_context_val_tab         pay_ca_eoy_archive.char240_data_type_table;
  l_chunk                   number;
  l_payroll_action_id       number;
  l_defined_balance_id      number;
  l_result                  number;
  l_person_id               number;
  l_organization_id         number;
  l_location_id             number;
  l_first_name              varchar2(240);
  l_last_name               varchar2(240);
  l_employee_number         varchar2(240);
  l_national_identifier     varchar2(240);
  l_middle_names            per_all_people_f.middle_names%TYPE;
  l_employee_phone_no       varchar2(240);
  l_address_line1           varchar2(240);
  l_address_line2           varchar2(240);
  l_address_line3           varchar2(240);
  l_address_line4           varchar2(240);
  l_town_or_city            varchar2(80);
  l_province_code           varchar2(80);
  l_postal_code             varchar2(80);
  l_telephone_number        varchar2(80);
  l_country_code            varchar2(80);
  l_counter                 number;
  l_archive_item_id         number;
  result                    number;
  earning_exists            number := 0;
  ln_non_taxable_earnings   number := 0;
  ln_no_gross_earnings      number := 0;
  ln_gross_earnings         number := 0;
  l_object_version_number   number;
  l_context_id              number;
  l_context_val             varchar2(80);
  l_some_warning            boolean;
  l_cpp_exempt_flag         varchar2(80);
  l_ei_exempt_flag          varchar2(80);
  /* Added by ssmukher for PPIP tax implementation */
  l_ppip_exempt_flag        varchar2(80);
  qc_result		    number;
  l_inputs                  ff_exec.inputs_t;
  l_outputs                 ff_exec.outputs_t;
  l_return_value            varchar2(240);
  l_invalid_mesg            varchar2(240);
  l_invalid_sin             varchar2(240);
  l_formula_id              number;
  l_effective_start_date    date;
  l_value                   number;
  old_l_value               number;
  l_legislative_parameters  varchar2(240);
  l_footnote_code           varchar2(10);
  l_footnote_balance        varchar2(80);
  l_registration_no         varchar2(150);
  old_l_registration_no     varchar2(150);
  l_balance_name            varchar2(150);
  l_negative_balance_exists varchar2(5) ;
  l_person_arch_step        number;
  l_cpp_ee_withheld_pjgy    number;
  l_qpp_ee_withheld_pjgy    number;
  l_ei_ee_withheld_pjgy     number;
  addr                      pay_ca_rl1_reg.primaryaddress;
  l_user_entity_id          ff_user_entities.user_entity_id%TYPE;

  other_info_amount31       number;
  other_info_amount53       number;
  other_info_amount78       number;
  other_info_amount71       number;

  -- code start for Bug 5698016
  other_info_amount81       number;
  other_info_amount82       number;
  other_info_amount83       number;
  other_info_amount84       number;
  other_info_amount85       number;
  -- code ended for Bug 5698016

  -- code start for Bug 9135405
  other_info_amount66       number;
  other_info_amount67       number;
  other_info_amount68       number;
  other_info_amount69       number;
  -- code ended for Bug 9135405

  box_52_exists             varchar2(1) ;
  l_balance_name1           pay_balance_types.balance_name%TYPE;
  lv_empcode_prov           varchar2(20);
  lv_employment_code        varchar2(20);
  lv_serial_number          varchar2(30);
  ld_date_of_birth          date;
  lv_under18_flag    varchar2(2);
  lv_over70_flag    varchar2(2);
  ln_cpp_ee_taxable_pjgy     number;
  ln_qpp_ee_taxable_pjgy     number ;
  ln_ei_ee_taxable_pjgy      number ;
  lv_cpp_archive_exempt_flag varchar2(20);
  lv_ei_archive_exempt_flag  varchar2(20);
/* Added by ssmukher for PPIP tax implementation */
  lv_ppip_archive_exempt_flag varchar2(20);
  l_ppip_ee_withheld_pjgy       number;
  ln_ppip_ee_taxable_pjgy       number;

  lv_qpp_exempt_flag          varchar2(20) ;

  /* Added for Bug 4028693 */
  l_box14_flag               char(1);

  /* new variables added for Federal YE Amendment PP */
  ld_fapp_effective_date   date;
  lv_fapp_report_type      varchar2(20);
  ln_fapp_locked_action_id number;
  lv_fapp_prov             varchar2(5);
  lv_fapp_flag             varchar2(2);
  lv_fapp_locked_actid_reptype varchar2(20);
  ln_fapp_prev_amend_actid number;

  l_transmitter_gre_id    number;

  l_status_indian         varchar2(1);
 /* Added new variable for Bug 3447439 by ssmukher*/
  lv_actual_date date;

  -- l_screen_entry_value added by sneelapa for bug 6399498
  l_screen_entry_value    pay_element_entry_values_f.screen_entry_value%type;

  CURSOR get_person_info(p_asgid number) IS
  SELECT
    PEOPLE.person_id,
    PEOPLE.first_name,
    PEOPLE.last_name,
    PEOPLE.employee_number,
    replace(PEOPLE.national_identifier,' '),
    PEOPLE.middle_names,
    ASSIGN.organization_id,
    ASSIGN.location_id
  FROM
    per_all_assignments_f  ASSIGN,
    per_all_people_f       PEOPLE
  WHERE   ASSIGN.assignment_id = p_asgid
  and     l_date_earned BETWEEN ASSIGN.effective_start_date
                                           AND ASSIGN.effective_end_date
    AND	PEOPLE.person_id     = ASSIGN.person_id
    AND PEOPLE.effective_end_date = (select max(effective_end_date) from
                                   per_all_people_f PEOPLE1
                                   where PEOPLE1.person_id = PEOPLE.person_id);

    /* Get the jurisdiction code of all the cities
       for the person_id corresponding to the
       assignment_id . Take it from pay_action_context table. */

    cursor c_get_province(p_asgid number) is
     select distinct context_value
     from   pay_action_contexts pac
     where  pac.assignment_id = p_asgid;

  /* for testing , since there is no data in pay_action_contexts table */
    cursor c_get_test_province is
     select province_abbrev
     from   pay_ca_provinces_v pac;

-- l_business_group_id condition added by sneelapa, for bug 6399498
/*
     cursor  c_balance_feed_info (p_balance_name varchar2) is
           select nvl(pet.element_information20,'NOT FOUND'),
                  pbt1.balance_name
           from pay_balance_feeds_f pbf,
                pay_balance_types pbt,
                pay_balance_types pbt1,
                pay_input_values_f piv,
                pay_element_types_f pet
           where pbt.balance_name = p_balance_name
           and   pbf.balance_type_id = pbt.balance_type_id
           and   pbf.input_value_id = piv.input_value_id
           and   piv.element_type_id = pet.element_type_id
           and   pbt1.balance_type_id = pet.element_information10
--           and   pet.element_information_category = 'CA_EARNINGS'
          and   pet.business_group_id = l_business_group_id
           and   pet.element_information20 is not null;
*/

--CURSOR c_balance_feed_info is modified by sneelapa for bug 6399498
--   For issue reported by QA during testing of above bug.
    cursor  c_balance_feed_info (p_balance_name varchar2) is
        select nvl(pet.element_information20,'NOT FOUND'),
                  pbt1.balance_name,
                  pev.screen_entry_value
        from pay_balance_feeds_f pbf,
                pay_balance_types pbt,
                pay_balance_types pbt1,
                pay_input_values_f piv,
                pay_element_types_f pet,
                pay_element_entries_f pee,
                pay_element_entry_values_f pev
           where pbt.balance_name = p_balance_name
           and pee.assignment_id = l_asgid
           and   pbf.balance_type_id = pbt.balance_type_id
           and   pbf.input_value_id = piv.input_value_id
           and   piv.element_type_id = pet.element_type_id
           and   pbt1.balance_type_id = pet.element_information10
           and   pet.business_group_id = l_business_group_id
           and   pet.element_information20 is not null
           and   pet.element_type_id = pee.element_type_id
--           and   trunc(p_effective_date) between pee.effective_start_date and pee.effective_end_date
           and   ((pee.effective_start_date <= l_year_end
                    and pee.effective_end_date = to_date('31-12-4712','DD-MM-RRRR'))
                    or
                    (pee.effective_end_date between l_year_start and l_year_end))
--           and   trunc(p_effective_date) between pev.effective_start_date and pev.effective_end_date
           and   ((pev.effective_start_date <= l_year_end
                    and pev.effective_end_date = to_date('31-12-4712','DD-MM-RRRR'))
                    or
                    (pev.effective_end_date between l_year_start and l_year_end))
           and   pee.element_entry_id = pev.element_entry_id
--           and fnd_number.canonical_to_number(pev.screen_entry_value) >= 0
--           and   pet.element_information_category = 'CA_EARNINGS'
--           and   pev.input_value_id = piv.input_value_id
          ;


  cursor cur_bg(p_tax_unit_id1 number) is
  select business_group_id
  from hr_all_organization_units
  where organization_id = p_tax_unit_id1;

/* New cursors added for Federal YE Amendment Pre-Process Validation */
  CURSOR c_get_fapp_prov_emp(cp_assignment_action_id number) IS
  select fai.value
  from   ff_archive_items   fai,
         ff_database_items  fdi
  where  fdi.user_entity_id = fai.user_entity_id
  and    fai.context1  = cp_assignment_action_id
  and    fdi.user_name = 'CAEOY_PROVINCE_OF_EMPLOYMENT';

  CURSOR c_get_fapp_lkd_actid_rtype(cp_locked_actid number) IS
  select ppa.report_type
  from pay_payroll_actions ppa,pay_assignment_actions paa
  where paa.assignment_action_id = cp_locked_actid
  and ppa.payroll_action_id = paa.payroll_action_id;

  CURSOR c_get_fapp_locked_action_id(cp_locking_act_id number) IS
  select locked_action_id
  from pay_action_interlocks
  where locking_action_id = cp_locking_act_id;


/* cursor to get the T4 Employment Code, Bug#2141132 */
   cursor c_get_employment_code(cp_gre varchar2,
                                cp_person_id number) IS
   select pei_information2,
          pei_information3
   from per_people_extra_info
   where person_id = cp_person_id
     and pei_information_category = 'ADDITIONAL_T4_INFORMATION'
     and pei_information1 = cp_gre;

/* Modified the cursor for bug fix 3447439 */
  CURSOR c_get_latest_asg(p_person_id number,
                          p_jurisdiction varchar2) IS
  select /*+ Ordered */
         paa.assignment_action_id,
         ppa.date_earned
  from  per_all_assignments_f      paf,
        pay_assignment_actions     paa,
        pay_payroll_actions        ppa,
        pay_action_classifications pac,
        pay_action_contexts pac1,
        ff_contexts         fc
  where paf.person_id     = p_person_id
    and paa.assignment_id = paf.assignment_id
    and paa.tax_unit_id   = l_tax_unit_id
    and paa.payroll_action_id = ppa.payroll_action_id
    and ppa.action_type = pac.action_type
    and pac.classification_name = 'SEQUENCED'
    and ppa.effective_date +0 between paf.effective_start_date
                                  and paf.effective_end_date
    and ppa.effective_date +0 between l_year_start
                                  and l_year_end
    and ((nvl(paa.run_type_id, ppa.run_type_id) is null
        and  paa.source_action_id is null)
         or (nvl(paa.run_type_id, ppa.run_type_id) is not null
        and paa.source_action_id is not null )
         or (ppa.action_type = 'V' and ppa.run_type_id is null
        and paa.run_type_id is not null
        and paa.source_action_id is null))
    and pac1.assignment_action_id = paa.assignment_action_id
    and pac1.context_id     = fc.context_id
    and fc.context_name    = 'JURISDICTION_CODE'
    and pac1.context_value  =  p_jurisdiction
   order by paa.action_sequence desc;

/* Modified cursor c_get_latest_asg by ssmukher for Bug 3447439 */
/*
               cursor  c_get_latest_asg(cp_person_id number,
                                        cp_tax_unit_id number,
                                        cp_jurisdiction varchar2) is
               select paa.assignment_action_id,
                      ppa.date_earned
	       from pay_assignment_actions     paa,
	            per_all_assignments_f      paf,
	            per_all_people_f ppf,
	            pay_payroll_actions        ppa,
	            pay_action_classifications pac,
	            pay_action_contexts pac1,
	            ff_contexts         fc
	       where ppf.person_id = cp_person_id
	       and paf.person_id = ppf.person_id
	       and paf.assignment_id = paa.assignment_id
	       and paa.tax_unit_id   = cp_tax_unit_id
	       and ppa.payroll_action_id = paa.payroll_action_id
               and ppa.effective_date+0 between l_year_start
                                            and l_year_end
	       and ppa.effective_date between ppf.effective_start_date
	                                  and ppf.effective_end_date
	       and ppa.effective_date between paf.effective_start_date
	                                  and paf.effective_end_date
	       and ppa.action_type = pac.action_type
	       and pac.classification_name = 'SEQUENCED'
	       and pac1.assignment_action_id = paa.assignment_action_id
	       and pac1.context_id     = fc.context_id
	       and fc.context_name     = 'JURISDICTION_CODE'
	       and pac1.context_value  =  cp_jurisdiction
   	       order by paa.action_sequence desc;
*/

  /* cursor to get date_of_birth for an employee to check EI and CPP Exempt */
   cursor c_get_date_of_birth(ln_person_id number
                             ,ld_eff_date date) is
   select ppf.date_of_birth
   from per_all_people_f ppf
   where ppf.person_id = ln_person_id
   and  ppf.effective_end_date  = (select max(ppf2.effective_end_date)
                                     from per_all_people_f ppf2
                                     where ppf2.person_id= ln_person_id
                                     and ppf2.effective_start_date
                                         <= ld_eff_date);

/* This cursor fetches the Status Indian flag for a assignment */
CURSOR c_get_status_indian(cp_assign number,
                              cp_effec_date date) IS
   select ca_tax_information1
   from   pay_ca_emp_fed_tax_info_f pca
   where  pca.assignment_id = cp_assign
    and   cp_effec_date between pca.effective_start_date and
          pca.effective_end_date;
begin

 -- hr_utility.trace_on(1,'ORACLE');

  l_negative_balance_exists := 'N';
  box_52_exists  := 'N';
  lv_under18_flag := 'N';
  lv_over70_flag  := 'N';
  ln_cpp_ee_taxable_pjgy := 0;
  ln_qpp_ee_taxable_pjgy := 0;
  ln_ei_ee_taxable_pjgy  := 0;
  lv_cpp_archive_exempt_flag := Null;
  lv_ei_archive_exempt_flag  := Null;
  lv_ppip_archive_exempt_flag := Null;
  lv_qpp_exempt_flag         := Null;
  lv_fapp_flag   := 'N';
  l_count := 0;
  hr_utility.trace('p_assactida value '||p_assactid);
  hr_utility.trace('getting assignment');


  SELECT
    aa.assignment_id,
    pay_magtape_generic.date_earned (p_effective_date,aa.assignment_id),
    aa.tax_unit_id,
    aa.chunk_number,
    aa.payroll_action_id,
    aa.serial_number
  INTO
    l_asgid,
    l_date_earned,
    l_tax_unit_id,
    l_chunk,
    l_payroll_action_id,
    lv_serial_number
  FROM
    pay_assignment_actions aa
  WHERE
    aa.assignment_action_id = p_assactid;

  l_year_start := trunc(p_effective_date, 'Y');
  l_year_end   := add_months(trunc(p_effective_date, 'Y'),12) - 1;

  OPEN cur_bg(l_tax_unit_id);
  FETCH
    cur_bg
  INTO
    l_business_group_id;
  CLOSE cur_bg;

  l_step := 1;

/*Bug 5706114  Fetching the Status Indian flag */

     open c_get_status_indian(l_asgid,p_effective_date);
     fetch c_get_status_indian
     into  l_status_indian;
     close c_get_status_indian;

/* Call the archive_gre_data procedure */
   if l_chunk = g_min_chunk and g_archive_flag = 'N' then
     select org_information11
     into l_transmitter_gre_id
     from hr_organization_information
     where  organization_id = l_tax_unit_id
     and    org_information_context = 'Canada Employer Identification';

           l_step := 3;
           hr_utility.trace('eoy_archive_data archiving employer data');
            eoy_archive_gre_data(l_payroll_action_id,
                                 l_tax_unit_id,
                                 l_transmitter_gre_id);

          l_step := 4;
          hr_utility.trace('eoy_archive_data archived employer data');
        end if;

  /* Now, set up the jurisdiction context for the db items that
  need the jurisdiction as a context.Here we are archiving all the
  jurisdictions we got from pay_action_contexts for all assignment_actions.
  So even though a particular assignment_action is for aparticular jurisdiction
  the archiver table has data for all the jurisdictions, but values of
  irrelevant jurisdictions will be 0  */

  /* Change it to c_get_province later on */
  OPEN c_get_test_province;
  LOOP

  /* initializing local variables used for T4 Box 28 for each
     jurisdiction part of fix for bug#3422384 */
  lv_over70_flag := 'N';
  lv_under18_flag := 'N';
  l_cpp_exempt_flag := NULL;
  l_ei_exempt_flag := NULL;
  l_ppip_exempt_flag := NULL;
  l_cpp_ee_withheld_pjgy := 0;
  ln_cpp_ee_taxable_pjgy := 0;
  lv_cpp_archive_exempt_flag := NULL;
  lv_qpp_exempt_flag := NULL;
  l_qpp_ee_withheld_pjgy := 0;
  ln_qpp_ee_taxable_pjgy := 0;
  l_ei_exempt_flag := NULL;
  l_ei_ee_withheld_pjgy := 0;
  ln_ei_ee_taxable_pjgy := 0;
  l_ppip_ee_withheld_pjgy := 0;
  ln_ppip_ee_taxable_pjgy := 0;
  lv_ei_archive_exempt_flag := NULL;
  lv_ppip_archive_exempt_flag  := Null;
  ld_date_of_birth := NULL;


  /* Initialise l_count */
  l_count := 0;
  l_step := 11;

  FETCH c_get_test_province
  INTO l_jurisdiction;

  hr_utility.trace('In jurisdiction loop ' || l_jurisdiction);
  EXIT WHEN c_get_test_province%NOTFOUND;

/*
  SELECT
    paa1.assignment_action_id
  INTO
    l_aaid
  FROM
    pay_assignment_actions paa1,
    per_all_assignments_f      paf2
  WHERE
    paa1.assignment_id = paf2.assignment_id
    and   paa1.tax_unit_id = l_tax_unit_id
    and (paa1.action_sequence , paf2.person_id) =
      (SELECT MAX(paa.action_sequence), paf.person_id
       FROM   pay_action_classifications pac,
              pay_payroll_actions ppa,
              pay_assignment_actions paa,
              per_all_assignments_f paf1,
              per_all_assignments_f paf
        WHERE paf.assignment_id = l_asgid
          AND paf1.person_id = paf.person_id
          AND paa.tax_unit_id = l_tax_unit_id
          AND paa.assignment_id = paf1.assignment_id
          AND paa.payroll_action_id = ppa.payroll_action_id
          AND ppa.action_type = pac.action_type
          AND pac.classification_name = 'SEQUENCED'
          AND ppa.effective_date <= p_effective_date
        group by paf.person_id)
    and rownum < 2;
*/
          begin

            open c_get_latest_asg(lv_serial_number,l_jurisdiction);
            fetch c_get_latest_asg into l_aaid,lv_actual_date;
            close c_get_latest_asg;

            hr_utility.trace('max assignment_action_id : ' || to_char(l_aaid));

          exception
             when no_data_found then
                  l_aaid := -9999;
                  raise_application_error(-20001,'Balance Assignment Action does not exist for : '
                       ||to_char(l_person_id));
          end;

  pay_ca_balance_view_pkg.set_context ('ASSIGNMENT_ACTION_ID',l_aaid);
  pay_ca_balance_view_pkg.set_context( 'JURISDICTION_CODE', l_jurisdiction);

  hr_utility.trace('Archiving the balance dbi ' || l_jurisdiction);

  /* Assign values to the PL/SQL tables */

  l_step := 16;

  l_seq_tab(1) := 1;
  l_context_id_tab(1)  := l_jursd_context_id;
  l_context_val_tab(1) := l_jurisdiction;

  l_seq_tab(2) := 2;
  l_context_id_tab(2)  := l_taxunit_context_id;
  l_context_val_tab(2) := l_tax_unit_id;

  pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
  pay_ca_balance_view_pkg.set_context ('ASSIGNMENT_ACTION_ID',l_aaid);
  pay_ca_balance_view_pkg.set_context( 'JURISDICTION_CODE', l_jurisdiction);

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count)  := 'CAEOY_GROSS_EARNINGS_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)  := 'Gross Earnings';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_CPP_EE_WITHHELD_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'CPP EE Withheld';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_QPP_EE_WITHHELD_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'QPP EE Withheld';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_EI_EE_WITHHELD_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'EI EE Withheld';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_FED_WITHHELD_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'FED Withheld';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_EI_EE_TAXABLE_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'EI EE Taxable';

   IF l_jurisdiction  ='QC' THEN

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_PPIP_EE_WITHHELD_PER_JD_GRE_YTD';
      l_balance_type_tab(l_count)     := 'PPIP EE Withheld';


      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_PPIP_EE_TAXABLE_PER_JD_GRE_YTD';
      l_balance_type_tab(l_count)     := 'PPIP EE Taxable';

   END IF;

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_CPP_EE_TAXABLE_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'CPP EE Taxable';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_QPP_EE_TAXABLE_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'QPP EE Taxable';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_CPP_EE_RSUBJECT_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'CPP Reduced Subject';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_QPP_EE_RSUBJECT_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'QPP Reduced Subject';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_BOX20_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_BOX20';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_BOX44_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_BOX44';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_BOX46_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_BOX46';

  /* l_count := l_count + 1
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_BOX50_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_BOX50'; */

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_BOX52_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_BOX52';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT30_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_OTHER_INFO_AMOUNT30';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT32_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT32';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT33_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT33';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT34_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT34';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT35_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT35';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT36_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT36';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT37_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT37';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT38_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT38';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT39_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT39';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT40_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT40';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT41_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT41';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT42_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT42';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT43_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT43';

  /* Modification for bug 9135405 starts here. */

  hr_utility.trace('l_year_end is '|| to_char(l_year_end,'yyyy'));

  IF ( to_number(to_char(l_year_end,'YYYY')) >= 2010) then
    hr_utility.trace('inside if condition l_year_end '|| to_char(l_year_end,'yyyy'));

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT66_PER_JD_GRE_YTD';
    l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT66';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT67_PER_JD_GRE_YTD';
    l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT67';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT68_PER_JD_GRE_YTD';
    l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT68';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT69_PER_JD_GRE_YTD';
    l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT69';

  END IF;

  /* Modification for bug 9135405 ends here. */

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT70_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT70';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT71_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT71';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT72_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT72';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT73_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT73';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT74_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT74';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT75_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT75';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT76_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT76';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT77_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT77';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT79_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT79';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT80_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'T4_OTHER_INFO_AMOUNT80';

-- change started for  Bug 5698016

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT81_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_OTHER_INFO_AMOUNT81';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT82_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_OTHER_INFO_AMOUNT82';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT83_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_OTHER_INFO_AMOUNT83';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT84_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_OTHER_INFO_AMOUNT84';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count) := 'CAEOY_T4_OTHER_INFO_AMOUNT85_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count)     := 'T4_OTHER_INFO_AMOUNT85';

  ---  change ended for  Bug 5698016


  l_count := l_count + 1;
  l_user_entity_name_tab(l_count)
            := 'CAEOY_CPP_BASIC_EXEMPTION_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'CPP EE Basic Exemption';

  l_count := l_count + 1;
  l_user_entity_name_tab(l_count)
               := 'CAEOY_CPP_EXEMPT_PER_JD_GRE_YTD';
  l_balance_type_tab(l_count) := 'CPP Exempt';


  ln_non_taxable_earnings :=
      nvl(pay_ca_balance_pkg.call_ca_balance_get_value
             ('T4 Non Taxable Earnings',
              'YTD',l_aaid,l_asgid,NULL,'PER',
              l_tax_unit_id,l_business_group_id,l_jurisdiction),0);

  ln_gross_earnings :=
      nvl(pay_ca_balance_pkg.call_ca_balance_get_value
             ('Gross Earnings',
              'YTD' , l_aaid, l_asgid , NULL, 'PER' ,
              l_tax_unit_id, l_business_group_id, l_jurisdiction),0);

  ln_no_gross_earnings :=
      nvl(pay_ca_balance_pkg.call_ca_balance_get_value
             ('T4 No Gross Earnings',
              'YTD' , l_aaid, l_asgid , NULL, 'PER' ,
              l_tax_unit_id, l_business_group_id, l_jurisdiction),0);

  if (((ln_gross_earnings <> 0) and
       (ln_non_taxable_earnings <> ln_gross_earnings)) or
      (ln_no_gross_earnings <> 0)) then

    hr_utility.trace('Jurisdiction is **  ' || l_jurisdiction);
    earning_exists := 1;
    ff_archive_api.create_archive_item(
      p_archive_item_id => l_archive_item_id
     ,p_user_entity_id => get_user_entity_id('CAEOY_PROVINCE_OF_EMPLOYMENT')
     ,p_archive_value  => l_jurisdiction
     ,p_archive_type   => 'AAP'
     ,p_action_id      => p_assactid
     ,p_legislation_code => 'CA'
     ,p_object_version_number  => l_object_version_number
     ,p_context_name1          => 'JURISDICTION_CODE'
     ,p_context1               => l_jurisdiction
     ,p_context_name2          => 'TAX_UNIT_ID'
     ,p_context2               => l_tax_unit_id
     ,p_some_warning           => l_some_warning
    );

    for i in 1 .. l_count
    loop
      result := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( l_balance_type_tab(i),
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                 ) ;

      if result is null then
        result := 0;
      end if;

      if l_user_entity_name_tab(i) = 'CAEOY_CPP_EE_WITHHELD_PER_JD_GRE_YTD' then
        l_cpp_ee_withheld_pjgy := result;
      elsif
        l_user_entity_name_tab(i) = 'CAEOY_QPP_EE_WITHHELD_PER_JD_GRE_YTD' then
        l_qpp_ee_withheld_pjgy := result;
      elsif
        l_user_entity_name_tab(i) = 'CAEOY_EI_EE_WITHHELD_PER_JD_GRE_YTD' then
        l_ei_ee_withheld_pjgy := result;
      elsif
        l_user_entity_name_tab(i) = 'CAEOY_T4_BOX52_PER_JD_GRE_YTD' then
        result := round(result);
        hr_utility.trace('box_52 Result = ' || to_char(result));
        if result > 0 then
          box_52_exists := 'Y';
          hr_utility.trace('box_52_exists');
        end if;
      /* bug#3422384 Box26, Box24 */
      elsif l_user_entity_name_tab(i) = 'CAEOY_CPP_EE_TAXABLE_PER_JD_GRE_YTD' then
        ln_cpp_ee_taxable_pjgy := result;
      elsif l_user_entity_name_tab(i) = 'CAEOY_QPP_EE_TAXABLE_PER_JD_GRE_YTD' then
        ln_qpp_ee_taxable_pjgy := result;
      elsif l_user_entity_name_tab(i) = 'CAEOY_EI_EE_TAXABLE_PER_JD_GRE_YTD' then
        ln_ei_ee_taxable_pjgy := result;
      end if;

      /* Added by ssmukher for PPIP Implementaton */
      if l_jurisdiction = 'QC' then
         if  l_user_entity_name_tab(i) = 'CAEOY_PPIP_EE_TAXABLE_PER_JD_GRE_YTD' then
             ln_ppip_ee_taxable_pjgy := result;
         elsif
             l_user_entity_name_tab(i) = 'CAEOY_PPIP_EE_WITHHELD_PER_JD_GRE_YTD' then
             l_ppip_ee_withheld_pjgy := result;
         end if;
      end if;

      if l_jurisdiction = 'QC' and
        l_balance_type_tab(i) = 'Gross Earnings' then

        hr_utility.trace('Calculating QC only taxable benefit');
        hr_utility.trace('l_aaid ' || to_char(l_aaid));
        hr_utility.trace('l_asgid ' || to_char(l_asgid));
        hr_utility.trace('l_tax_unit_id ' || to_char(l_tax_unit_id));
        hr_utility.trace('l_business_group_id '||to_char(l_business_group_id));
        hr_utility.trace('l_jurisdiction ' || l_jurisdiction);

        qc_result := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'Taxable Benefits for Quebec',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

       hr_utility.trace('qc_result is' || to_char(qc_result));

       if qc_result is null then
	 qc_result := 0;
       end if;

       result := result - qc_result;

    end if;

    if l_balance_type_tab(i) = 'Gross Earnings' then

      other_info_amount31 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT31',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

      other_info_amount53 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT53',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

      /* Added by ssmukher for Bug 4547415 */

      other_info_amount78 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT78',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;


      other_info_amount71 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT71',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

-- code started for bug 5698016


other_info_amount81 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT81',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

other_info_amount82 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT82',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

other_info_amount83 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT83',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

/*
other_info_amount84 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT84',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

other_info_amount85 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT85',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;
*/
-- code ended for bug 5698016

-- code ended for bug 9135405
IF ( to_number(to_char(l_year_end,'YYYY')) >= 2010) then
  other_info_amount66 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT66',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

  other_info_amount67 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT67',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

  other_info_amount68 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT68',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;

  other_info_amount69 := pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4_OTHER_INFO_AMOUNT69',
                   'YTD' ,
                    l_aaid,
                    l_asgid ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_business_group_id,
                    l_jurisdiction
                   ) ;
end if;
-- code ended for bug 9135405



     result := result - (NVL(other_info_amount31,0)
                      -- + NVL(other_info_amount53,0) --Fix for Bug8576897
                       + NVL(other_info_amount78,0)
                       + NVL(other_info_amount71,0)

-- code started for bug 5698016
                       + NVL(other_info_amount81,0)
                       + NVL(other_info_amount82,0)
                       + NVL(other_info_amount83,0)
/*
                       + NVL(other_info_amount84,0)
                       + NVL(other_info_amount85,0)
*/
-- code ended for bug 5698016

-- code started for bug 9135405
                       + NVL(other_info_amount66,0)
                       + NVL(other_info_amount67,0)
                       + NVL(other_info_amount68,0)
                       + NVL(other_info_amount69,0)
-- code ended for bug 9135405
                       + ln_non_taxable_earnings);

    hr_utility.trace(' Gross Earnings = ' || to_char(result));

    /* Added for Bug 4028693 */
          open c_get_employment_code(to_char(l_tax_unit_id),
                                 to_number(lv_serial_number));

          loop
               fetch c_get_employment_code
               into   lv_empcode_prov,
                      lv_employment_code;
               exit when c_get_employment_code%NOTFOUND;

              if lv_employment_code is not null and
                 lv_employment_code in ('11','12','13','17') then

                 l_box14_flag := 'Y';
                 Exit;
              else
                 l_box14_flag := 'N';
              end if;

          end loop;

          close c_get_employment_code;

          lv_empcode_prov := null;
          lv_employment_code := null;

          if l_box14_flag = 'Y' then
             result := 0;
          end if;
  /* end of changes for bug 4028693 */

    end if;

   If (l_status_indian = 'Y' AND
     (l_balance_type_tab(i) IN
      ('T4_BOX20','T4_BOX44'))) then
       result := 0;
   end if;

    ff_archive_api.create_archive_item(
         p_archive_item_id => l_archive_item_id
        ,p_user_entity_id => get_user_entity_id(l_user_entity_name_tab(i))
        ,p_archive_value  => result
        ,p_archive_type   => 'AAP'
        ,p_action_id      => p_assactid
        ,p_legislation_code => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning
     );

   /* Negative balance flag */
   /* Modified by ssmukher for Bug 4547415 */
    if result < 0 or other_info_amount31 < 0 or other_info_amount53 < 0
       or other_info_amount78 < 0 then

       l_negative_balance_exists := 'Y';

    end if;

    end loop;

    hr_utility.trace(' Archiver Asg Act Id = ' || to_char(p_assactid));
    hr_utility.trace(' Negative Balance Exists Flag = ' || l_negative_balance_exists);

      /* Archiving the Negative Balance Exists Flag Bug#3289072 */
      if l_negative_balance_exists = 'Y' then
          l_user_entity_id :=
             get_user_entity_id('CAEOY_T4_NEGATIVE_BALANCE_EXISTS');

        ff_archive_api.create_archive_item(
         p_archive_item_id        => l_archive_item_id
        ,p_user_entity_id         => l_user_entity_id
        ,p_archive_value          => l_negative_balance_exists
        ,p_archive_type           => 'AAP'
        ,p_action_id              => p_assactid
        ,p_legislation_code       => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning);

       else
        l_user_entity_id :=
             get_user_entity_id('CAEOY_T4_NEGATIVE_BALANCE_EXISTS');

        ff_archive_api.create_archive_item(
         p_archive_item_id        => l_archive_item_id
        ,p_user_entity_id         => l_user_entity_id
        ,p_archive_value          => 'N'
        ,p_archive_type           => 'AAP'
        ,p_action_id              => p_assactid
        ,p_legislation_code       => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning);

      end if;

    /* The following other_info_amounts are archived outside
    the main loop, otherwise the balance call would have been
    twice for each of them as they needed to be subtracted
    from the Gross Earnings */
    /* Modified by ssmukher for bug 4034155 */
    for i in 1..3 loop

      if i = 1 then
         l_user_entity_id :=
             get_user_entity_id('CAEOY_T4_OTHER_INFO_AMOUNT31_PER_JD_GRE_YTD');
         result := other_info_amount31;
      elsif i = 2 then
         l_user_entity_id :=
             get_user_entity_id('CAEOY_T4_OTHER_INFO_AMOUNT53_PER_JD_GRE_YTD');
         result := other_info_amount53 ;
     /* Added by ssmukher for bug 4547415 */
      elsif i = 3 then
         l_user_entity_id :=
             get_user_entity_id('CAEOY_T4_OTHER_INFO_AMOUNT78_PER_JD_GRE_YTD');
         result := other_info_amount78 ;
      end if;

      ff_archive_api.create_archive_item(
         p_archive_item_id => l_archive_item_id
        ,p_user_entity_id => l_user_entity_id
        ,p_archive_value  => result
        ,p_archive_type   => 'AAP'
        ,p_action_id      => p_assactid
        ,p_legislation_code => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning);

    end loop; -- End loop other information archived after Amount
              -- is subtracted from Gross Earnings.


    l_negative_balance_exists := 'N';

    /* Archiving Exempt flags separately */
    hr_utility.trace('I am archiving CPP-QPP exempt flags for ' ||
                                                 to_char(l_asgid));
    hr_utility.trace('effective date is ' || to_char(p_effective_date));

    /* Bug#3422384, checking whether the employee age is under 18 or over 70 */
       open c_get_date_of_birth(to_number(lv_serial_number),p_effective_date);
       fetch c_get_date_of_birth into ld_date_of_birth;
       close c_get_date_of_birth;

       if ld_date_of_birth is NULL then
          hr_utility.trace('Employee date of birth is NULL satisfied ');
          lv_over70_flag := 'N';
          lv_under18_flag := 'N';
       else
          hr_utility.trace('Employee date of birth found ');

          /* Backing out the changes made in 115.60 */
    /*    if (( add_months(trunc(ld_date_of_birth,'MONTH'),(18*12)+1)) <= lv_actual_date ) then
                if ( lv_actual_date >= ( add_months(trunc(ld_date_of_birth,'MONTH'),(70*12)+1))) then */
          if ((add_months(trunc(ld_date_of_birth,'MONTH'),(18*12)+1)) <= p_effective_date) then
                if (p_effective_date >= (add_months(trunc(ld_date_of_birth,'MONTH'),(70*12)+1))) then
                        lv_over70_flag := 'Y';
                else
                        lv_over70_flag := 'N';
                end if;
          else
                lv_under18_flag := 'Y';

          end if;
       end if;

    BEGIN
    /* Removed the per_all_assignments_f join the select stmt for bug fix 5041252 */
     SELECT decode(target.CPP_QPP_EXEMPT_FLAG,'Y','X',NULL),
       decode(target.EI_EXEMPT_FLAG,'Y','X',NULL)
     INTO   l_cpp_exempt_flag,
       l_ei_exempt_flag
     FROM   pay_ca_emp_fed_tax_info_f      target
     WHERE   target.assignment_id         = l_asgid
       and lv_actual_date/*p_effective_date*/ between target.effective_start_date
       and target.effective_end_date;

    exception when no_data_found then
      l_cpp_exempt_flag := NULL;
      l_ei_exempt_flag := null;
    end;

    /* Added extra validation to fix bug#3422384. For CPP
       1. If employee age is under 18 or over 70
          and Box16,Box26 = 0 then cpp_exempt_flag ='X'
       2. If cpp_exempt_flag in tax_information form is 'Y' and
          and Box16,Box26 = 0 then cpp_exempt_flag ='X'
       3. If employee age turned into 18 or over 70 mid year
          and Box16,Box26 > 0 and cpp_exempt_flag is 'Y' in
          tax form then cpp_exempt_flag = ?
    */

    IF l_jurisdiction <> 'QC' THEN

      IF (lv_under18_flag = 'Y' or lv_over70_flag = 'Y') and
         (l_cpp_ee_withheld_pjgy = 0) and (ln_cpp_ee_taxable_pjgy = 0) THEN

          lv_cpp_archive_exempt_flag := 'X';
      Elsif (l_cpp_exempt_flag = 'X') and (l_cpp_ee_withheld_pjgy = 0)
             and (ln_cpp_ee_taxable_pjgy = 0) THEN

          lv_cpp_archive_exempt_flag := 'X';
      END IF;

    END IF;


    IF l_jurisdiction = 'QC' THEN

      BEGIN
        SELECT decode(target.QPP_EXEMPT_FLAG,'Y','X',NULL),
	       decode(target.PPIP_EXEMPT_FLAG,'Y','X',NULL)
        INTO lv_qpp_exempt_flag,
	     l_ppip_exempt_flag
        FROM pay_ca_emp_prov_tax_info_f      target
        WHERE target.assignment_id         = l_asgid
        and target.province_code         = 'QC'
        and lv_actual_date/*p_effective_date */ between target.effective_start_date
        and target.effective_end_date;
        EXCEPTION
        WHEN no_data_found THEN
         lv_qpp_exempt_flag := NULL;
         l_ppip_exempt_flag := NULL;
      END;

      /* Added extra validation to fix bug#3422384. For QPP
         1. If employee is under 18
            and Box17,Box26 = 0 then qpp_exempt_flag= 'X'
         2. If qpp_exempt_flag in tax_information form is 'Y' and
            and Box17,Box26 = 0 then qpp_exempt_flag= 'X'
         3. If employee age turned into 18 mid year
            and Box17,Box26 > 0 and qpp_exempt_flag is 'Y' in
            tax form then qpp_exempt_flag = ?
      */
      IF (lv_under18_flag = 'Y') and (l_qpp_ee_withheld_pjgy = 0)
         and (ln_qpp_ee_taxable_pjgy = 0) THEN
         lv_cpp_archive_exempt_flag := 'X';
      Elsif (lv_qpp_exempt_flag = 'X') and (l_qpp_ee_withheld_pjgy = 0)
         and (ln_qpp_ee_taxable_pjgy = 0) THEN
         lv_cpp_archive_exempt_flag := 'X';
      END IF;

      /* Added by ssmukher for PPIP Implementation */
      IF (l_ppip_exempt_flag = 'X' and l_ppip_ee_withheld_pjgy = 0
          and ln_ppip_ee_taxable_pjgy = 0) THEN

          lv_ppip_archive_exempt_flag := 'X';
      END IF;

         ff_archive_api.create_archive_item(
         p_archive_item_id => l_archive_item_id
        ,p_user_entity_id => get_user_entity_id('CAEOY_PPIP_EXEMPT')
        ,p_archive_value  => lv_ppip_archive_exempt_flag
        ,p_archive_type   => 'AAP'
        ,p_action_id      => p_assactid
        ,p_legislation_code => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning
       );

    END IF;


    /* changed to archive lv_cpp_archive_exempt_flag instead of l_cpp_exempt_flag
       to fix bug#3422384 */
    ff_archive_api.create_archive_item(
         p_archive_item_id => l_archive_item_id
        ,p_user_entity_id => get_user_entity_id('CAEOY_CPP_QPP_EXEMPT')
        ,p_archive_value  => lv_cpp_archive_exempt_flag
        ,p_archive_type   => 'AAP'
        ,p_action_id      => p_assactid
        ,p_legislation_code => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning
       );

       hr_utility.trace('I am archiving EI exempt flag');

     /* Added extra validation to fix bug#3422384. For EI
         1. If ei_exempt_flag in tax_information form is 'Y' and
            and Box18,Box24 = 0 then ei_exempt_flag= 'X'
     */

    IF (l_ei_exempt_flag = 'X' and l_ei_ee_withheld_pjgy = 0
        and ln_ei_ee_taxable_pjgy = 0) THEN

         lv_ei_archive_exempt_flag := 'X';

    END IF;

    hr_utility.trace('assignment id ' || to_char(l_asgid) || '**');
    hr_utility.trace('cpp exempt flag is ' || lv_cpp_archive_exempt_flag || '**');
    hr_utility.trace('ei exempt flag is ' || lv_ei_archive_exempt_flag || '**');

    ff_archive_api.create_archive_item(
         p_archive_item_id => l_archive_item_id
        ,p_user_entity_id => get_user_entity_id('CAEOY_EI_EXEMPT')
        ,p_archive_value  => lv_ei_archive_exempt_flag
        ,p_archive_type   => 'AAP'
        ,p_action_id      => p_assactid
        ,p_legislation_code => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning
       );

    hr_utility.trace('I have archived exempt flags');


   /* Archiving T4 Employment Code */
      open c_get_employment_code(to_char(l_tax_unit_id),
                                 to_number(lv_serial_number));
      loop -- c_get_emp_code
        fetch c_get_employment_code into lv_empcode_prov,
                                       lv_employment_code;
        exit when c_get_employment_code%NOTFOUND;

        if lv_empcode_prov is not null and
           lv_empcode_prov = l_jurisdiction then

         ff_archive_api.create_archive_item(
         p_archive_item_id => l_archive_item_id
        ,p_user_entity_id => get_user_entity_id('CAEOY_EMPLOYMENT_CODE')
        ,p_archive_value  => lv_employment_code
        ,p_archive_type   => 'AAP'
        ,p_action_id      => p_assactid
        ,p_legislation_code => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning
       );

        hr_utility.trace('Archived Employment code single prov');

      else

        ff_archive_api.create_archive_item(
         p_archive_item_id => l_archive_item_id
        ,p_user_entity_id => get_user_entity_id('CAEOY_EMPLOYMENT_CODE')
        ,p_archive_value  => lv_employment_code
        ,p_archive_type   => 'AAP'
        ,p_action_id      => p_assactid
        ,p_legislation_code => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'JURISDICTION_CODE'
        ,p_context1               => l_jurisdiction
        ,p_context_name2          => 'TAX_UNIT_ID'
        ,p_context2               => l_tax_unit_id
        ,p_some_warning           => l_some_warning
       );

        hr_utility.trace('Archived employment code all prov');

       end if;

     end loop; -- c_get_employment_code

     close c_get_employment_code;
     /* End of Employement Code archiving */

   end if;

  end loop;

  /* start registration number archiving */

  l_registration_no := NULL;
  old_l_value := 0;
  l_value := 0;

  --hr_utility.trace_on('Y','ORACLE');

  hr_utility.trace('l_aaid is ' || to_char(l_aaid));
  hr_utility.trace('l_asgid is ' || to_char(l_asgid));
  hr_utility.trace('l_tax_unit_id is ' || to_char(l_tax_unit_id));
  hr_utility.trace('l_business group_id is ' || to_char(l_business_group_id));

  begin


/* if box_52_exists = 'Y' then
    l_balance_name1 := 'T4_BOX52';
    box_52_exists   := 'N';
  --else -- commented by sneelapa for bug 6399498
  elsif nvl(l_status_indian,'N') = 'N' then
    l_balance_name1 := 'T4_BOX20';
  end if;
*/
  l_balance_name1 := 'T4_BOX52';
  box_52_exists   := 'N';

  hr_utility.trace('BOX name is ' || l_balance_name1);
  hr_utility.trace('l_asgid ' || l_asgid);
  hr_utility.trace('l_business_group_id ' || l_business_group_id);
  hr_utility.trace('p_effective_date ' || to_char(p_effective_date));

  open c_balance_feed_info(l_balance_name1);
  fetch c_balance_feed_info into l_registration_no, l_balance_name, l_screen_entry_value;

  hr_utility.trace('CURSOR count ' || c_balance_feed_info%rowcount);

  if c_balance_feed_info%rowcount = 0 and nvl(l_status_indian,'N') = 'N' then
    l_balance_name1 := 'T4_BOX20';
    if c_balance_feed_info%isopen then
      close c_balance_feed_info;
    end if;
  end if;

  hr_utility.trace('BOX name is ' || l_balance_name1);
  if not c_balance_feed_info%isopen then
        open c_balance_feed_info(l_balance_name1);
        fetch c_balance_feed_info into l_registration_no, l_balance_name, l_screen_entry_value;
      hr_utility.trace('CURSOR count BOX20 is ' || c_balance_feed_info%rowcount);
  end if;

  loop
  hr_utility.trace('start of c_balance_feed_info CURSOR');
  exit when c_balance_feed_info%NOTFOUND;

  -- exception handling added by sneelapa for bug 6399498
  -- screen_entry_value will be NON NUMERIC data for certain Element Entry Values
  -- For example: Jurisdistiction.

  begin

  -- if condition added by sneelapa for bug 6399498
  if fnd_number.canonical_to_number(l_screen_entry_value) >= 0 then

    l_value := pay_ca_balance_pkg.call_ca_balance_get_value
                    ( l_balance_name,
                     'YTD' ,
                      l_aaid,
                      l_asgid,
                      NULL,
                      'PER' ,
                      l_tax_unit_id,
                      l_business_group_id,
                      NULL );

    if l_value is null then
      l_value := 0;
    end if;

    hr_utility.trace('l_value  is ' || to_char(l_value));
    hr_utility.trace('old_l_value  is ' || old_l_value);
    hr_utility.trace('old_l_registration_no  is ' || old_l_registration_no);
    hr_utility.trace('l_registration_no  is ' || l_registration_no);

    if l_registration_no <> 'NOT FOUND' then
      if old_l_registration_no is null and l_value <> 0 then
        old_l_registration_no := l_registration_no;
      end if;

  -- modified for bug 6399498
  --    if old_l_value >= l_value then
      if old_l_value > l_value then
        l_registration_no := old_l_registration_no;
  -- modified for bug 6399498
  --    elsif old_l_value < l_value then
      elsif old_l_value <= l_value then
        old_l_value := l_value;
        old_l_registration_no := l_registration_no;
      end if;
    end if;

    end if; -- if fnd_number.canonical_to_number(pev.screen_entry_value) >= 0 then

    exception
    when others then
      null;
    end;

    fetch c_balance_feed_info into l_registration_no,l_balance_name, l_screen_entry_value;
  end loop;

  close c_balance_feed_info;

  hr_utility.trace('old_l_value  is ' || to_char(old_l_value));
  hr_utility.trace('l_registration no  is ' || l_registration_no);

-- modified for bug 6399498, for QA reported issue in this bug.
--  if  l_registration_no is not null and old_l_value <> 0 then
  if  l_registration_no is not null then

  hr_utility.trace('l_registration no  is ' || 'archiving');
  --  hr_utility.trace_off;

    ff_archive_api.create_archive_item(
       p_archive_item_id => l_archive_item_id
      ,p_user_entity_id =>
          get_user_entity_id('CAEOY_T4_EMPLOYEE_REGISTRATION_NO')
      ,p_archive_value  => l_registration_no
      ,p_archive_type   => 'AAP'
      ,p_action_id      => p_assactid
      ,p_legislation_code => 'CA'
      ,p_object_version_number  => l_object_version_number
      ,p_some_warning           => l_some_warning
      );
  end if;
  end;

  /* end registration number archiving */

  begin
  l_counter := 0;
  hr_utility.trace('selecting people');

  open get_person_info(l_asgid);

  fetch get_person_info
  into
    l_person_id,
    l_first_name,
    l_last_name,
    l_employee_number,
    l_national_identifier,
    l_middle_names,
    l_organization_id,
    l_location_id;

  l_person_arch_step := 1;
  /* Validations for magtape and exception report */

  /* SIN validation */
  if l_national_identifier is not null then
    select formula_id,
      effective_start_date
    into   l_formula_id,
      l_effective_start_date
    from   ff_formulas_f
    where  formula_name='NI_VALIDATION'
      and business_group_id is null
      and legislation_code='CA'
      and sysdate between effective_start_date and effective_end_date;

ff_exec.init_formula(l_formula_id,l_effective_start_date,l_inputs,l_outputs);
for l_in_cnt in
   l_inputs.first..l_inputs.last
   loop
      if l_inputs(l_in_cnt).name='NATIONAL_IDENTIFIER' then
         l_inputs(l_in_cnt).value := l_national_identifier;
      end if;
   end loop;
   ff_exec.run_formula(l_inputs,l_outputs);

   for l_out_cnt in
   l_outputs.first..l_outputs.last
   loop
       hr_utility.trace('inside loop for SIN validation');
      if l_outputs(l_out_cnt).name='RETURN_VALUE' then
         l_return_value := l_outputs(l_out_cnt).value;
      end if;
      if l_outputs(l_out_cnt).name='INVALID_MESG' then
         l_invalid_mesg := l_outputs(l_out_cnt).value;
      end if;
   end loop;

   if l_return_value = 'INVALID_ID' then
     l_invalid_sin := 'Y';
   else
     l_invalid_sin := 'N';
   end if;
else
 l_invalid_sin := 'A';
end if;

l_person_arch_step := 2;
       hr_utility.trace('selected people');
         /* Initialise l_count */
          l_count := 0;

--hr_utility.trace_on('Y','ORACLE');

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_PERSON_ID';
 l_user_entity_value_tab(l_counter) := l_person_id;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_FIRST_NAME';
 l_user_entity_value_tab(l_counter) := l_first_name;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_LAST_NAME';
 l_user_entity_value_tab(l_counter) := l_last_name;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_INITIAL';
 l_user_entity_value_tab(l_counter) := l_middle_names;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_SIN';
 l_user_entity_value_tab(l_counter) := l_national_identifier;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_SIN_INVALID';
 l_user_entity_value_tab(l_counter) := l_invalid_sin;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_NUMBER';
 l_user_entity_value_tab(l_counter) := l_employee_number;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_T4_ORGANIZATION_ID';
 l_user_entity_value_tab(l_counter) := l_organization_id;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_T4_LOCATION_ID';
 l_user_entity_value_tab(l_counter) := l_location_id;

 if  earning_exists = 1 then
  for i in 1..l_counter loop

    l_context_id := l_taxunit_context_id;
    l_context_val := l_tax_unit_id;

  ff_archive_api.create_archive_item(
--   p_validate      => 'TRUE'
   p_archive_item_id => l_archive_item_id
  ,p_user_entity_id => get_user_entity_id(l_user_entity_name_tab(i))
  ,p_archive_value  => l_user_entity_value_tab(i)
  ,p_archive_type   => 'AAP'
  ,p_action_id      => p_assactid
  ,p_legislation_code => 'CA'
  ,p_object_version_number  => l_object_version_number
  ,p_some_warning           => l_some_warning
   );
  end loop;
 end if;
 exception when no_data_found then
              l_first_name := null;
              l_last_name := null;
              l_employee_number := null;
              l_national_identifier := null;
              l_middle_names := null;
              l_employee_phone_no := null;
              hr_utility.raise_error;
           when others then
              hr_utility.trace('Error in archiving person '||
                              to_char(l_person_id) || 'at step :' ||
                              to_char(l_person_arch_step) ||
                              'sqlcode : ' || to_char(sqlcode));
end;

  addr := pay_ca_rl1_reg.get_primary_address(l_person_id,p_effective_date);

  l_address_line1 := addr.addr_line_1;
  l_address_line2 := addr.addr_line_2;
  l_address_line3 := addr.addr_line_3;
  l_town_or_city  := addr.city;
  l_province_code := addr.province;
  l_postal_code   := replace(addr.postal_code,' ');
  l_country_code  := addr.addr_line_5;

 hr_utility.trace('selected address');

 l_counter := 0;
 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_ADDRESS_LINE1';
 l_user_entity_value_tab(l_counter) := l_address_line1;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_ADDRESS_LINE2';
 l_user_entity_value_tab(l_counter) := l_address_line2;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_ADDRESS_LINE3';
 l_user_entity_value_tab(l_counter) := l_address_line3;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_ADDRESS_LINE4';
 l_user_entity_value_tab(l_counter) := l_address_line4;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_CITY';
 l_user_entity_value_tab(l_counter) := l_town_or_city;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_PROVINCE';
 l_user_entity_value_tab(l_counter) := l_province_code;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_COUNTRY';
 l_user_entity_value_tab(l_counter) := l_country_code;

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_POSTAL_CODE';
 l_user_entity_value_tab(l_counter) := l_postal_code;

/*
 l_counter := l_counter + 1;
 l_user_entity_value_tab(l_counter) := 'CAEOY_EMPLOYEE_BUSINESS_NUMBER';
 l_user_entity_name_tab(l_counter) := 'To be decided';
*/
if  earning_exists = 1 then
 for i in 1..l_counter loop

    l_context_id := l_taxunit_context_id;
    l_context_val := l_tax_unit_id;

       hr_utility.trace('archiving address');
 ff_archive_api.create_archive_item(
   p_archive_item_id => l_archive_item_id
  ,p_user_entity_id => get_user_entity_id(l_user_entity_name_tab(i))
  ,p_archive_value  => l_user_entity_value_tab(i)
  ,p_archive_type   => 'AAP'
  ,p_action_id      => p_assactid
  ,p_legislation_code => 'CA'
  ,p_object_version_number  => l_object_version_number
  ,p_some_warning           => l_some_warning
   );
       hr_utility.trace('archived address');
  end loop;
  end if;
       hr_utility.trace('end of eoy_archive_data');
      l_step := 37;


-- Federal YE Amendment Pre-Process Validation (T4 Amendmendment Archiver code)

   Begin

     hr_utility.trace('Started Federal YE Amendment PP Validation ');
     select effective_date,report_type
     into ld_fapp_effective_date,lv_fapp_report_type
     from pay_payroll_actions
     where payroll_action_id = l_payroll_action_id;

     hr_utility.trace('Fed Amend Pre-Process Pactid :'||
                        to_char(l_payroll_action_id));
     hr_utility.trace('lv_fapp_report_type :'||lv_fapp_report_type);

     IF lv_fapp_report_type = 'CAEOY_T4_AMEND_PP' then
        begin

          open c_get_fapp_locked_action_id(p_assactid);
          fetch c_get_fapp_locked_action_id into ln_fapp_locked_action_id;
          close c_get_fapp_locked_action_id;

          hr_utility.trace('T4 Amend PP Action ID : '||to_char(p_assactid));
          hr_utility.trace('ln_fapp_locked_action_id :'||
                              to_char(ln_fapp_locked_action_id));
          open c_get_fapp_lkd_actid_rtype(ln_fapp_locked_action_id);
          fetch c_get_fapp_lkd_actid_rtype
                into lv_fapp_locked_actid_reptype;
          close c_get_fapp_lkd_actid_rtype;
          hr_utility.trace('lv_fapp_locked_actid_reptype :'||
                                  lv_fapp_locked_actid_reptype);

          open c_get_fapp_prov_emp(p_assactid);
          loop
            fetch c_get_fapp_prov_emp into lv_fapp_prov;
            exit when c_get_fapp_prov_emp%NOTFOUND;
            hr_utility.trace('lv_fapp_prov : '||lv_fapp_prov);
            lv_fapp_flag := compare_archive_data(p_assactid,
                                                 ln_fapp_locked_action_id,
                                                 lv_fapp_prov);

             if lv_fapp_flag = 'Y' then

                hr_utility.trace('Jurisdiction is :  ' || lv_fapp_prov);
                hr_utility.trace('Archiving T4 Amendment Flag is :  ' || lv_fapp_flag);

               ff_archive_api.create_archive_item(
                p_archive_item_id => l_archive_item_id
               ,p_user_entity_id => get_user_entity_id('CAEOY_T4_AMENDMENT_FLAG'
)
               ,p_archive_value          => lv_fapp_flag
               ,p_archive_type           => 'AAP'
               ,p_action_id              => p_assactid
               ,p_legislation_code       => 'CA'
               ,p_object_version_number  => l_object_version_number
               ,p_context_name1          => 'JURISDICTION_CODE'
               ,p_context1               => lv_fapp_prov
               ,p_context_name2          => 'TAX_UNIT_ID'
               ,p_context2               => l_tax_unit_id
               ,p_some_warning           => l_some_warning
               );

             end if;

          end loop;
          close c_get_fapp_prov_emp;

        end; -- report_type validation

      END IF; -- report type validation for FAPP
      hr_utility.trace('End of Federal YE Amendment PP Validation');

     Exception when no_data_found then
       hr_utility.trace('Report type not found for given Payroll_action ');
       null;
   End;
-- End of Federal YE Amendment Pre-Process Validation

  end eoy_archive_data;


  /* Name      : eoy_range_cursor
     Purpose   : This returns the select statement that is used to created the
                 range rows for the Year End Pre-Process.
     Arguments :
     Notes     :
  */

  procedure eoy_range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  l_legislative_parameters    varchar2(240);
  l_eoy_tax_unit_id    number;
  l_transmitter_gre_id number;
  l_archive            boolean:= FALSE;
  l_business_group     number;
  l_year_start         date;
  l_year_end           date;


  begin

   --hr_utility.trace_on('Y','ORACLE');

     select legislative_parameters,
            trunc(effective_date,'Y'),
            effective_date,
            business_group_id
     into   l_legislative_parameters,
            l_year_start,
            l_year_end,
            l_business_group
     from pay_payroll_actions
     where payroll_action_id = pactid;

     hr_utility.trace('legislative prameter is '|| l_legislative_parameters);
     l_eoy_tax_unit_id := get_parameter('TRANSFER_GRE',l_legislative_parameters);

     select org_information11
     into l_transmitter_gre_id
     from hr_organization_information
     where  organization_id = l_eoy_tax_unit_id
     and    org_information_context = 'Canada Employer Identification';

     hr_utility.trace('Transfer GRE is '|| to_char(l_eoy_tax_unit_id));
     hr_utility.trace('Transmitter GRE is '|| to_char(l_transmitter_gre_id));

     if l_eoy_tax_unit_id <> -99999 then

        sqlstr := 'select /*+ ORDERED INDEX (PPY PAY_PAYROLLS_F_FK2,
                                             PPA PAY_PAYROLL_ACTIONS_N51,
                                             PAA PAY_ASSIGNMENT_ACTIONS_N50,
                                             ASG PER_ASSIGNMENTS_F_PK,
                                             PPA1 PAY_PAYROLL_ACTIONS_PK)
                              USE_NL(PPY, PPA, PAA, ASG, PPA1) */
                         distinct asg.person_id
                   from pay_all_payrolls_f ppy,
                        pay_payroll_actions ppa,
                        pay_assignment_actions paa,
                        per_all_assignments_f asg,
                        pay_payroll_actions ppa1
                   where ppa1.payroll_action_id = :payroll_action_id
                   and   ppa.effective_date between
                               fnd_date.canonical_to_date('''||
                                             fnd_date.date_to_canonical(l_year_start)||''') and
                               fnd_date.canonical_to_date('''||
                                             fnd_date.date_to_canonical(l_year_end)||''')
                   and ppa.action_type in (''R'',''Q'',''V'',''B'',''I'')
                   and ppa.action_status = ''C''
                   and ppa.business_group_id + 0 = '||to_char(l_business_group)||'
                   and ppa.payroll_action_id = paa.payroll_action_id
                   and paa.tax_unit_id = '|| to_char(l_eoy_tax_unit_id)||'
                   and paa.action_status = ''C''
                   and paa.assignment_id = asg.assignment_id
                   and ppa.business_group_id = asg.business_group_id + 0
                   and ppa.effective_date between asg.effective_start_date
                                              and asg.effective_end_date
                   and asg.assignment_type = ''E''
                   and ppa.payroll_id = ppy.payroll_id
                   and ppy.business_group_id = '||to_char(l_business_group)||'
                   order by asg.person_id';

        l_archive := chk_gre_archive(pactid);

        if g_archive_flag = 'N' then

           hr_utility.trace('eoy_range_cursor archiving employer data');

          /* now the archiver has provision for archiving payroll_action_level
             data. So make use of that */

            hr_utility.trace('eoy_range_cursor archiving employer data');

            eoy_archive_gre_data(pactid,
                                 l_eoy_tax_unit_id,
                                 l_transmitter_gre_id);
        end if;

     end if;

  end eoy_range_cursor;

end pay_ca_eoy_archive;


/
