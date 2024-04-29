--------------------------------------------------------
--  DDL for Package Body PAY_CA_T4AEOY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_T4AEOY_ARCHIVE" as
/*$Header: pycayt4a.pkb 120.9.12010000.3 2009/12/04 12:54:04 aneghosh ship $ */
/*
**
** Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
**
** Description : Package and procedure to build sql for payroll processes.
**
** Change List
** -----------
** Date         Name        Vers   Bug No   Description
** -----------  ----------  -----  -------  -----------------------------------
** 03-JAN-2000  M.Mukherjee 115.0           Created
** 18-AUG-2000  M.Mukherjee 115.3           Added footnote generation and
**                                          registration number
** 28-AUG-2000  M.Mukherjee 115.4           Added box38 footnote code archiving
** 28-AUG-2000  M.Mukherjee 115.7           Changed the footnote archiving so
**                                          that it does not try to archive
**                                          null user_entities
** 21-SEP-2000  M.Mukherjee 115.9           Corrected archiving of registration
**                                          number.
** 25-SEP-2000  M.Mukherjee 115.10          Corrected archiving of footnots
** 27-SEP-2000  M.Mukherjee 115.11          Corrected archiving of registration
**                                          number,technical_contact info and
**                                          accounting contact_info
** 30-OCT-2000  M.Mukherjee 115.13          balance_feeds are being checked for
**                                          that business group id.Bug1482190
** 31-OCT-2000  SSattini    115.15          Corrected the box38 footnote code
**                                          to fix bug:1483943
** 13-DEC-2000  MMukherjee  115.16          Stopped assignment action creation
**                                          if the employeehas not been paid
**                                          anything in that year, even though
**                                          there is payroll run.
** 28-NOV-2001  SSattini    115.17          Corrected the 'Employee Initial'
**                                          to fix bug:1474421 and
**                                          modified employer_info cursor
**                                          to avoid the hr_ca_tax_units_v
**                                          view and improve performance.
**                                          Also added T4A_BOX27 balance
**                                          check to archive the
**                                          CAEOY_T4A_BOX27_14_PER_GRE_YTD
**                                          footnote code 14 based on BOX27.
** 15-MAR-2002  rsirigir   115.18           Bug 2254026, included checkfile
**                                          in order to comply with GSCC
**                                          standards
** 28-MAY-2002  SSattini   115.19           Fixed the bug#2175045 by adding
**                                          cur_non_box_mesg cursor and code
**                                          in procedure eoy_archive_data.
**                                          The T4A Nonbox footnotes are
**                                          archived into
**                                          pay_action_information table.
** 25-JUL-2002  SSattini   115.21           changed the balance name from
**                                          'T4A_BOX32' to 'T4A_BOX34'
**                                          to open c_reg_balance_feed_info
**                                          cursor for bugfix:2408456.
**                                          Added else part to fulfill reqt
**                                          if Pension Plan Registration
**                                          number is not there for balance
**                                          T4A_BOX34 then check in the
**                                          balance T4A_BOX32 and archive the
**                                          pension adjustment registration
**                                          number.  Also added two new cursors
**                                          c_ele_processed_for_emp and
**                                          cur_info_element_amt to check
**                                          elements fed to balances are
**                                          processed for that employee.
** 28-AUG-2002  SSattini   115.22           Fixed the bug#2426517, added
**                                          some validations to avoid un-
**                                          necessary footnote archiving
**                                          also corrected archiving of
**                                          CAEOY_T4A_FOOTNOTE_CODE used
**                                          for T4A_BOX38 in T4A reports.
**                                          Removed c_ele_processed_for_emp
**                                          and cur_info_element_amt cursors
**                                          and removed some validations
**                                          that refer to the cursors,
**                                          because used wrong setup to fix
**                                          bug#2408456 earlier and in this
**                                          version fixed bug#2408456 with
**                                          right test setup.
** 09-SEP-2002  SSattini   115.23           Fixed the bug#2426517, added
**                                          one local variable for single
**                                          footnote archiving, also
**                                          corrected archiving of box38.
**
** 13-SEP-2002  SSouresr   115.24           Fixed the bug#2561691, Added
**                                          conditions to the c_get_asg_id
**                                          cursor so that the primary
**                                          assignment is selected.
** 05-NOV-2002  SSattini   115.25           Fixed the bug#2449037, archiving
**                                          CAEOY_T4A_FOOTNOTE_CODE after
**                                          checking t4a nonbox footnotes
**                                          for an employee, so that nonbox
**                                          footnote code is archived and
**                                          displayed in T4A Box38.
** 07-NOV-2002  SSattini   115.26           Fixed the bug#2598802, archiving
**                                          GRE's 'Fed Magnetic Reporting'
**                                          using separate cursor
**                                          c_get_gre_acct_info in
**                                          eoy_archive_gre_data procedure.
**                                          Changed the cursor employer_info
**                                          in eoy_archive_gre_data procedure
**                                          removed the part that archives
**                                          GRE 'Fed Magnetic Reporting'.
** 12-NOV-2002  SSattini   115.27           Removed unnecessary archiving
**                                          of db items with dimension
**                                          _GRE_YTD from eoy_archive_gre_data
**                                          procedure, those db items are
**                                          CAEOY_T4_BOX20_GRE_YTD
**                                          CAEOY_FED_WITHHELD_GRE_YTD
**                                          CAEOY_T4_BOX52_GRE_YTD
**                                          CAEOY_EI_EE_TAXABLE_GRE_YTD
**                                          CAEOY_CPP_ER_LIABILITY_GRE_YTD
**                                          CAEOY_EI_ER_LIABILITY_GRE_YTD.
**
** 02-DEC-2002  SSattini   115.28           Added 'nocopy' for out and in out
**                                          parameters, GSCC compliance.
** 04-DEC-2002  SSattini   115.29           Fixed the bug#2695047, changed
**                                          employee address portion.
**                                          If country is CA then the province
**                                          value should be archived from
**                                          region_1 and if US then from
**                                          region_2.
** 06-DEC-2002  SSattini   115.30           Fixed the bug#2598777, archiving
**                                          PA amounts in dollars only.
**
** 27-AUG-2003 SSouresr    115.33           If the new balance 'T4A No Gross
**                                          Earnings'
**                                          is non zero then archiving will
**                                          take place even if Gross Earnings is
**                                          zero.
** 18-SEP-2003 mmukherj    115.34           Added proper error message if
**                                          transmitter GRE is not found.
**
** 30-OCT-2003  SSattini   115.35  2696309  Added functionality to archive
**                                          Pension Plan Registration Numbers
**                                          in pay_action_information table
**                                          to be reported in T4A Summary
**                                          record (Employer Level).
** 02-FEB-2004  SSattini    115.38          Tuned c_eoy_gre cursor in
**                                          action_creation procedure to fix
**                                          performance bug#3416511.
** 02-JUL-2004  mmukherj    115.39          Tuned c_get_latest_asg cursor
**                                          bug#3358776.
** 06-AUG-2004  SSattini    115.40          Modified cursor cur_non_box_mesg
**                                          to archive balance adjustments
**                                          for Non-box footnotes. Bug#3641353.
**
** 10-AUG-2004  ssouresr    115.42          Added the negative balance flag bug#3311402
**                                          Also modified the non box footnote logic
**                                          so that the amounts for identical footnote
**                                          codes are summed up bug#3641308
** 24-AUG-2004  mmukherj    115.43          Archiving two more dbis
**                                          CAEOY_TECHNICAL_CONTACT_EMAIL
**                                          CAEOY_TECHNICAL_CONTACT_EXTN
**                                          needed for T4A XML Magatpe.
**
** 02-OCT-2004  ssouresr    115.45          Employee Address is now archived
**                                          for terminated employees
** 02-OCT-2004  ssouresr    115.46          The negative balance flag will be
**                                          archived as Y if any box or nonbox
**                                          footnote is negative
** 03-NOV-2004  rigarg      115.47 3922311, Modified the cursor employer_info
**                                 3973040  to remove check for transmitter code 901.
**
** 10-NOV-2004  ssouresr    115.48          Modified to use tables instead of views
**                                          to remove problems with security groups
** 19-NOV-2004  mmukherj    115.49          bigfix 3913784
** 24-NOV-2004  mmukherj    115.50          Changed the code so that if the
**                                          accounting contact info for GRE is
**                                          not there then it archives the
**                                          accounting contact info of Transmitter
** 02-DEC-2004  ssouresr    115.51          Added error message for security group
** 06-DEC-2004  mmukherj    115.52          Fix for not archiving the registration
**                                          no if archiver value is null.
** 08-DEC-2004  mmukherj    115.53          Fix for PA registration no archiving.#3913784
** 14-SEP-2004  ssouresr    115.54          Added T4A Archiver Amendment functionality
**                                          by creating function compare_archive_data
**                                          and using it to archive the T4A amendment
**                                          flag
** 01-FEB-2005  mmukherj    115.55          Fix for single footnote #4107278
**                                          nonbox footnote #4118500 added.
** 02-FEB-2005  ssouresr    115.56          Nonbox footnotes with a value of zero
**                                          will not be archived. In addition if the
**                                          same nonbox footnote is processed multiple
**                                          times this will be considered as only one
**                                          footnote count for the purposes of box38
** 04-MAR-2005 ssouresr     115.57          The archiver uses a new NonBox Footnote Element
**                                          which has a Jurisdiction input value from the
**                                          beginning of 2006
** 26-APR-2005 ssouresr     115.58          The archiver will now recognize amendments
**                                          made only to non box footnotes
** 08-JUN-2005 ssouresr     115.59          Removed error message for security group
** 15-JUL-2005 mmukherj     115.60          Bug fix #4026689. Added call to
**                                          eoy_archive_gre_data in eoy_archive_data.
**                                          So that when the Retry process calls
**                                          eoy_archive_data, it re-archives the employer
**                                          and transmitter data.
** 05-AUG-2005 saurgupt     115.61          Bug 4517693: Added Address_line3 for
**                                          T4A archiver.
** 26-AUG-2005 mmukherj     115.62          Commented out the use two cursors
**                                          c_eoy_all and eoy_all_range. Since GRE is
**                                          a mandatory parameter for Federal
**                                          Yearend Archiver Process these two cursors
**                                          will never be used.
** 06-sep-2005 mmukherj     115.63          g_archive_flag is set to 'Y' after
**                                          archiving the GRE data. Otherwise it was
**                                          archiving Employer data multiple times
**                                          in some cases where there are more than one
**                                          chunks used in the process.
** 27-SEP-2005 ssouresr     115.64          Corrected the footnote condition in the
**                                          function compare_archive_data
** 06-OCT-2005 ssouresr     115.65          Modified the range cursor to avoid the use
**                                          of hr_soft_coding_keyflex.
** 26-OCT-2005 ssouresr     115.66          Modified the range cursor to add order hint
** 22-AUG-2007 ssmukher     115.67          Bug 4021563 Added code for Status
**                                          Indian employee in eoy_archive_data
**                                          procedure.
** 12-NOV-2009 aneghosh     115.69          T4A changes for 2009. Bug 9091935.
** 04-DEC-2009 aneghosh     115.70          Bug9160298. Back-tracked the changes
**                                          done for Bug9091935 as it proved to be
**                                          unnecessary and caused regression.
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

     token_val := name||'=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ', start_ptr);

/* if there is no spaces use then length of the string  */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;

/*      Did we find the token  */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;

     return par_value;

end get_parameter;

/*
** Name    : bal_db_item
** Purpose : Given the name of a balance DB item as would be seen in
**           a fast formula it returns the defined_balance_id of the
**           balance it represents.
** Arguments :
** Notes     : A defined balance_id is required by the PLSQL balance function.
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
     raise hr_utility.hr_error;
   else
     close csr_defined_balance;
   end if;

   return (l_defined_balance_id);

 end bal_db_item;

/*
** Name      : get_dates
** Purpose   : The dates are dependent on the report being run
**             For T4 it is year end dates.
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

   if    p_report_type = 'T4A' then
/*
**     Year End Pre-process is a yearly process where the identifier
**     indicates the year eg. 1998. The expected values for the example
**     should be
**        p_period_end        31-DEC-1998
**        p_quarter_start     01-OCT-1998
**        p_quarter_end       31-DEC-1998
**        p_year_start        01-JAN-1998
**        p_year_end          31-DEC-1998
*/

     p_period_end    := add_months(trunc(p_effective_date, 'Y'),12) - 1;
     p_quarter_start := trunc(p_period_end, 'Q');
     p_quarter_end   := p_period_end;

/* For EOY */

   end if;

   p_year_start := trunc(p_effective_date, 'Y');
   p_year_end   := add_months(trunc(p_effective_date, 'Y'),12) - 1;

 end get_dates;

/*
** Name    : get_selection_information
** Purpose : Returns information used in the selection of people to
**           be reported on.
** Arguments  :
**
** The following values are returned :-
**
** p_period_start         - The start of the period over which to select
**                          the people.
** p_period_end           - The end of the period over which to select
**                          the people.
** p_defined_balance_id   - The balance which must be non zero for each
**                             person to be included in the report.
**    p_group_by_gre         - should the people be grouped by GRE.
**    p_tax_unit_context     - Should the TAX_UNIT_ID context be set up for
**                             the testing of the balance.
**    p_jurisdiction_context - Should the JURISDICTION_CODE context be set up
**                             for the testing of the balance.
**
**  Notes      : This routine provides a way of coding explicit rules for
**               individual reports where they are different from the
**               standard selection criteria for the report type ie. in
**               NY state the selection of people in the 4th quarter is
**               different from the first 3.
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
   report on.  */

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

   if    p_report_type = 'T4A'  then

/*      Default settings for Year End Pre-process. */

     p_period_start         := p_year_start;
     p_period_end           := p_year_end;
     p_defined_balance_id   := bal_db_item('GROSS_EARNINGS_PER_GRE_YTD');
     p_group_by_gre         := FALSE;
     p_tax_unit_context     := TRUE;
     p_jurisdiction_context := FALSE;

/*    For EOY - end  */

/* An invalid report type has been passed so fail.  */

   else

     raise hr_utility.hr_error;

   end if;

 end get_selection_information;



/*
**  Name      : eoy_action_creation
**  Purpose   : This creates the assignment actions for a specific chunk
**              of people to be archived by the year end pre-process.
**  Arguments :
**  Notes     :
*/

 procedure eoy_action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is



/*  Variables used to hold the select columns from the SQL statement. */

   l_person_id              number;
   l_assignment_id          number;
   l_tax_unit_id            number;
   l_eoy_tax_unit_id            number;
   l_effective_end_date     date;
  l_archive_item_id               number;
  l_user_entity_name_tab    pay_ca_t4aeoy_archive.char240_data_type_table;

/* Variables used to hold the values used as bind variables within the
   SQL statement.  */

   l_bus_group_id           number;
   l_period_start           date;
   l_period_end             date;

/* Variables used to hold the details of the payroll and assignment actions
   that are created.  */

   l_payroll_action_created boolean := false;
   l_payroll_action_id      pay_payroll_actions.payroll_action_id%type;
   l_assignment_action_id   pay_assignment_actions.assignment_action_id%type;

/* Variable holding the balance to be tested. */

   l_defined_balance_id     pay_defined_balances.defined_balance_id%type;

/* Indicator variables used to control how the people are grouped. */

   l_group_by_gre           boolean := FALSE;

/* Indicator variables used to control which contexts are set up for
   balance.   */

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
   l_province       pay_payroll_actions.report_qualifier%type;
   l_value          number;
   old_l_value          number;
   l_registration_no    varchar2(150);
   l_balance_name       varchar2(150);
   l_effective_date date;
   l_quarter_start  date;
   l_quarter_end    date;
   l_year_start     date;
   l_year_end       date;
   lockingactid     number;
   l_primary_asg    pay_assignment_actions.assignment_id%type;
   l_legislative_parameters    varchar2(240);
   l_max_aaid       number;


   /* For Year End Preprocess we have to archive the assignments
      belonging to a GRE  */
   /*
   CURSOR c_eoy_gre IS
     SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            paa.tax_unit_id             tax_unit_id,
            ASG.effective_end_date      effective_end_date
     FROM   per_all_assignments_f      ASG,
	    pay_assignment_actions paa,
	    pay_payroll_actions    ppa
     WHERE  ppa.payroll_action_id >= 0
     AND    ppa.effective_date between l_period_start
				and l_period_end
     AND  ppa.action_type in ('R','Q','V','B','I')
     AND  ppa.business_group_id + 0 = l_bus_group_id
     AND  ppa.payroll_action_id = paa.payroll_action_id
     AND  paa.tax_unit_id = l_eoy_tax_unit_id
     AND  paa.assignment_id = ASG.assignment_id
     AND  ppa.business_group_id = ASG.business_group_id +0
     AND  ASG.person_id + 0 between stperson and endperson
     AND  ASG.assignment_type        = 'E'
     AND  ppa.effective_date between ASG.effective_start_date
                               AND  ASG.effective_end_date
     ORDER  BY 1, 3, 4 DESC, 2;
    */

   /* Tuned c_eoy_gre for bug#3416511 */
   CURSOR c_eoy_gre IS
    SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            paa.tax_unit_id             tax_unit_id,
            ASG.effective_end_date      effective_end_date
     FROM   per_all_assignments_f      ASG,
            pay_assignment_actions paa,
            pay_payroll_actions    ppa,
            per_all_people_f ppf
     WHERE  ppa.effective_date between l_period_start
                                and l_period_end
     AND  ppa.action_type in ('R','Q','V','B','I')
     AND  ppa.business_group_id  +0 = l_bus_group_id
     AND  ppa.payroll_action_id = paa.payroll_action_id
     AND  paa.tax_unit_id = l_eoy_tax_unit_id
     AND  paa.assignment_id = ASG.assignment_id
     AND  ppa.business_group_id = ASG.business_group_id +0
     AND  ppf.person_id between stperson and endperson
     AND  ASG.person_id = ppf.person_id
     AND  ASG.assignment_type  = 'E'
     AND  ppa.effective_date between ASG.effective_start_date
                               AND  ASG.effective_end_date
     AND  ppa.effective_date between ppf.effective_start_date
                               AND  ppf.effective_end_date
     ORDER  BY 1, 3, 4 DESC, 2;


/* Commented c_eoy_all, because Tax Unit id is a mandatory parameter
   in archiver process, this cursor will never be used */
/*
   CURSOR c_eoy_all IS
     SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            to_number(SCL.segment11)     tax_unit_id,
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
     and   assignment_type = 'E'
     and   paf.effective_start_date  <= l_period_end
     and   paf.effective_end_date    >= l_period_start
     ORDER BY assignment_id desc;

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

   l_eoy_tax_unit_id := pycadar_pkg.get_parameter('TRANSFER_GRE',l_legislative_parameters);

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

     if l_eoy_tax_unit_id <> 99999 then
        open c_eoy_gre;
/*     else
        open c_eoy_all;
*/
     end if;

     /* Loop for all rows returned for SQL statement. */

     hr_utility.trace('Entering loop');

     loop

        if l_eoy_tax_unit_id <> 99999 then

           hr_utility.trace('Fetching person id');

           fetch c_eoy_gre into l_person_id,
                                l_assignment_id,
                                l_tax_unit_id,
                                l_effective_end_date;

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
          null;

        else

          hr_utility.trace('prev person is '|| to_char(l_prev_person_id));
          hr_utility.trace('person is '|| to_char(l_person_id));
          hr_utility.trace('assignment is '|| to_char(l_assignment_id));


          /* Have a new unique row according to the way the rows are grouped.
          ** The inclusion of the person is dependent on having a non zero
          ** balance.
          ** If the balance is non zero then an assignment action is created to
          ** indicate their inclusion in the magnetic tape report. */

          /* Set up the context of tax unit id */

          hr_utility.trace('Setting context');

          if l_tax_unit_context then
             pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
          end if;

   begin
            select paa1.assignment_action_id
              into l_max_aaid
              from pay_assignment_actions     paa1,
                   per_all_assignments_f          paf2,
                   pay_payroll_actions        ppa2,
                   pay_action_classifications pac2
             where paf2.person_id     = l_person_id
               and paa1.assignment_id = paf2.assignment_id
               and paa1.tax_unit_id   = l_tax_unit_id
               and paa1.payroll_action_id = ppa2.payroll_action_id
               and ppa2.action_type = pac2.action_type
               and pac2.classification_name = 'SEQUENCED'
               and ppa2.effective_date between paf2.effective_start_date
                                           and paf2.effective_end_date
               and ppa2.effective_date between l_period_start and
                                               l_period_end
               and not exists (select ''
                               FROM pay_action_classifications pac,
                                    pay_payroll_actions ppa,
                                    pay_assignment_actions paa,
                                    per_all_assignments_f paf1
                               WHERE paf1.person_id = l_person_id
                               AND paa.assignment_id = paf1.assignment_id
                               AND paa.tax_unit_id = l_tax_unit_id
                               AND ppa.payroll_action_id = paa.payroll_action_id
                               AND ppa.effective_date between l_period_start
                                                      and l_period_end
                               AND paa.action_sequence > paa1.action_sequence
                               AND pac.action_type = ppa.action_type
                               AND pac.classification_name = 'SEQUENCED')
                and rownum < 2;
     exception
             when no_data_found then
                  l_max_aaid := -9999;
     end;

          /* Get the primary assignment */
          open c_get_asg_id(l_person_id);
          fetch c_get_asg_id into l_primary_asg;
          if c_get_asg_id%NOTFOUND then
             close c_get_asg_id;
             raise hr_utility.hr_error;
          else
             close c_get_asg_id;
          end if;

  if l_max_aaid <> -9999 then  /* Max Assignment action id */
   if (  (pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'Gross Earnings',
                   'YTD' , l_max_aaid, l_primary_asg , NULL, 'PER' ,
                    l_tax_unit_id, l_bus_group_id, NULL)
               <> 0) OR
         (pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'T4A No Gross Earnings',
                   'YTD' , l_max_aaid, l_primary_asg , NULL, 'PER' ,
                    l_tax_unit_id, l_bus_group_id, NULL)
               <> 0) ) then
          /* Create the assignment action to represnt the person / tax unit
             combination. */

          select pay_assignment_actions_s.nextval
          into   lockingactid
          from   dual;

          /* Insert into pay_assignment_actions. */

          hr_utility.trace('creating assignment action');

          hr_nonrun_asact.insact(lockingactid,l_primary_asg,
                                 pactid,chunk,l_tax_unit_id);

          /* Update the serial number column with the person id
          ** so that the mag routine and the W2 view will not have
          ** to do an additional checking against the assignment
          ** table
          */

          hr_utility.trace('updating assignment action');

          update pay_assignment_actions aa
          set    aa.serial_number = to_char(l_person_id)
          where  aa.assignment_action_id = lockingactid;
       end if; /* End of Gross Earning <> 0 */
      end if ; /*l_max_aaid <> -9999 */
     end if;  /* End of l_person_id <> l_prev_person_id */

     /* Record the current values for the next time around the loop. */

     l_prev_person_id   := l_person_id;
     l_prev_tax_unit_id := l_tax_unit_id;

   end loop;

   if l_eoy_tax_unit_id <> 99999 then
      close c_eoy_gre;
/*   else
      close c_eoy_all;
*/
   end if;


 end eoy_action_creation;



  /*
  ** Name      : get_user_entity_id
  ** Purpose   : This gets the user_entity_id for a specific database item name.
  ** Arguments : p_dbi_name -> database item name.
  ** Notes     :
  */

  function get_user_entity_id (p_dbi_name in varchar2)
           return number is
  l_user_entity_id  number;

  begin

    hr_utility.trace('getting the user_entity_id for '
                                     || p_dbi_name);
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
                                     || p_dbi_name ||'**');
    raise hr_utility.hr_error;

  end get_user_entity_id;

  /* Name      : get_footnote_user_entity_id
  ** Purpose   : This gets the user_entity_id for a specific database item name.
  **             and it does not raise error if the the user entity is not found
  **   Arguments : p_dbi_name -> database item name.
  ** Notes     :
  */

  function get_footnote_user_entity_id (p_dbi_name in varchar2)
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
                                     || p_dbi_name ||'***');
    return 0;

  end get_footnote_user_entity_id;

  /*
     Name      : compare_archive_data
     Purpose   : compares Federal YEPP data and Federal YE Amendment Data
     Arguments : p_assignment_action_id -> Assignment_action_id
                 p_locked_action_id     -> YEPP Assignment_action_id

     Notes     : Used specifically for Federal YE Amendment Pre-Process (YE-2004)
  */

function compare_archive_data(p_assignment_action_id in number
                             ,p_locked_action_id in number
                             ) return varchar2 is
TYPE act_info_rec IS RECORD
   (archive_context1 number(25)
   ,archive_ue_id    number(25)
   ,archive_value    varchar2(240));

TYPE footnote_rec IS RECORD
   (message varchar2(240)
   ,value   varchar2(240));

TYPE action_info_table IS TABLE OF act_info_rec
 INDEX BY BINARY_INTEGER;

TYPE footnote_table IS TABLE OF footnote_rec
 INDEX BY BINARY_INTEGER;

-- Cursor to get archived values based on asg_act_id

cursor c_get_emp_t4a_data (cp_asg_act_id   number) is
SELECT fai1.context1,
       fdi1.user_entity_id,
       fai1.value
FROM ff_archive_items fai1,
     ff_database_items fdi1
WHERE fai1.user_entity_id = fdi1.user_entity_id
AND fai1.context1         = cp_asg_act_id
AND fdi1.user_name       <> 'CAEOY_T4A_AMENDMENT_FLAG'
order by fdi1.user_name;

cursor c_get_nonbox_footnote(cp_asg_act_id number) is
select action_information4,
       action_information5
from pay_action_information
where action_context_id = cp_asg_act_id
and   action_information_category = 'CA FOOTNOTES'
and   action_context_type = 'AAP'
and   action_information6 = 'T4A'
order by action_information4;


i number;
lv_flag             varchar2(2);
ltr_amend_arch_data action_info_table;
ltr_yepp_arch_data  action_info_table;
ln_yepp_box_count   number;
ln_amend_box_count  number;

ltr_amend_footnote      footnote_table;
ltr_yepp_footnote       footnote_table;
ln_yepp_footnote_count  number;
ln_amend_footnote_count number;

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

    if ltr_amend_footnote.count > 0 then
       ltr_amend_footnote.delete;
    end if;

    if ltr_yepp_footnote.count > 0 then
       ltr_yepp_footnote.delete;
    end if;

   /* Populate T4A Amendment Footnotes */
     open c_get_nonbox_footnote(p_assignment_action_id);

     hr_utility.trace('Populating T4A Amendment Footnote ');

     ln_amend_footnote_count := 0;
     loop
        fetch c_get_nonbox_footnote into ltr_amend_footnote(ln_amend_footnote_count);
        exit when c_get_nonbox_footnote%NOTFOUND;

        hr_utility.trace('Amend Message: '||ltr_amend_footnote(ln_amend_footnote_count).message);
        hr_utility.trace('Amend Value: '||ltr_amend_footnote(ln_amend_footnote_count).value);

        ln_amend_footnote_count := ln_amend_footnote_count + 1;
     end loop;

     close c_get_nonbox_footnote;

   /* Populate T4A YEPP Footnotes */
     open c_get_nonbox_footnote(p_locked_action_id);

     ln_yepp_footnote_count := 0;
     loop
        fetch c_get_nonbox_footnote into ltr_yepp_footnote(ln_yepp_footnote_count);
        exit when c_get_nonbox_footnote%NOTFOUND;

        hr_utility.trace('YEPP Message: '||ltr_yepp_footnote(ln_yepp_footnote_count).message);
        hr_utility.trace('YEPP Value: '||ltr_yepp_footnote(ln_yepp_footnote_count).value);

        ln_yepp_footnote_count := ln_yepp_footnote_count + 1;
     end loop;

     close c_get_nonbox_footnote;


   /* Populate T4A Amendment Data for an assignment_action */
     open c_get_emp_t4a_data(p_assignment_action_id);

     hr_utility.trace('Populating T4A Amendment Data ');
     hr_utility.trace('P_assignment_action_id :'||to_char(p_assignment_action_id));

     ln_amend_box_count := 0;
     loop
        fetch c_get_emp_t4a_data into ltr_amend_arch_data(ln_amend_box_count);
        exit when c_get_emp_t4a_data%NOTFOUND;

        hr_utility.trace('I :'||to_char(ln_amend_box_count));
        hr_utility.trace('Archive_Context1: '||to_char(ltr_amend_arch_data(ln_amend_box_count).archive_context1));
        hr_utility.trace('Archive_UE_id: '||to_char(ltr_amend_arch_data(ln_amend_box_count).archive_ue_id));
        hr_utility.trace('Archive_Value: '||ltr_amend_arch_data(ln_amend_box_count).archive_value);

        ln_amend_box_count := ln_amend_box_count + 1;
     end loop;

     close c_get_emp_t4a_data;


   /* Populate T4A YEPP Data for an assignment_action */
     open c_get_emp_t4a_data(p_locked_action_id);

     hr_utility.trace('Populating T4A YEPP Data ');
     hr_utility.trace('P_locked_action_id :'||to_char(p_locked_action_id));

     ln_yepp_box_count := 0;
     loop
        fetch c_get_emp_t4a_data into ltr_yepp_arch_data(ln_yepp_box_count);
        exit when c_get_emp_t4a_data%NOTFOUND;

        hr_utility.trace('I :'||to_char(ln_yepp_box_count));
        hr_utility.trace('Archive_Context1: '||to_char(ltr_yepp_arch_data(ln_yepp_box_count).archive_context1));
        hr_utility.trace('Archive_UE_id: '||to_char(ltr_yepp_arch_data(ln_yepp_box_count).archive_ue_id));
        hr_utility.trace('Archive_Value: '||ltr_yepp_arch_data(ln_yepp_box_count).archive_value);

        ln_yepp_box_count := ln_yepp_box_count + 1;
     end loop;

     close c_get_emp_t4a_data;

   /* Compare T4A Amendment Data and T4A YEPP Data for an
      assignment_action */

     hr_utility.trace('Comparing T4A Amend and T4A YEPP Data');

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

   /* Compare T4A Amendment Footnotes and T4A YEPP Footnotes for an
      assignment_action */

     hr_utility.trace('Comparing T4A Amend and T4A YEPP Footnotes');

     if lv_flag <> 'Y' then
       if ln_yepp_footnote_count <> ln_amend_footnote_count then
           lv_flag := 'Y';
       elsif ((ln_yepp_footnote_count = ln_amend_footnote_count) and
              (ln_yepp_footnote_count <> 0)) then
        for i in ltr_yepp_footnote.first..ltr_yepp_footnote.last
         loop
            if (ltr_yepp_footnote(i).message =
                ltr_amend_footnote(i).message) then

                 if ((ltr_yepp_footnote(i).value <>
                      ltr_amend_footnote(i).value) or
                     (ltr_yepp_footnote(i).value is null and
                      ltr_amend_footnote(i).value is not null) or
                     (ltr_yepp_footnote(i).value is not null and
                      ltr_amend_footnote(i).value is null)) then

                    lv_flag := 'Y';
                    hr_utility.trace('Footnote with diff value :'||ltr_yepp_footnote(i).message);
                    exit;
                 end if;
            end if;
         end loop;
       end if;
     end if;

    /* If there is no value difference for Entire Employee data then set
       flag to 'N' */

     if lv_flag <> 'Y' then
        lv_flag := 'N';
        hr_utility.trace('No value difference for an Employee Asg Action: '||
                          to_char(p_assignment_action_id));
     end if;

     hr_utility.trace('lv_flag :'||lv_flag);

     return lv_flag;

--   hr_utility.trace_off;

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
  l_seq_tab                 pay_ca_t4aeoy_archive.number_data_type_table;
  l_context_id_tab          pay_ca_t4aeoy_archive.number_data_type_table;
  l_context_val_tab         pay_ca_t4aeoy_archive.char240_data_type_table;
  l_user_entity_name_tab    pay_ca_t4aeoy_archive.char240_data_type_table;
  l_balance_type_tab        pay_ca_t4aeoy_archive.char240_data_type_table;
  l_user_entity_value_tab   pay_ca_t4aeoy_archive.char240_data_type_table;
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
  l_accounting_contact_extension varchar2(240);

  l_trans_acct_contact_name      varchar2(240);
  l_trans_acct_contact_area_code varchar2(240);
  l_trans_acct_contact_phone     varchar2(240);
  l_trans_acct_contact_extn      varchar2(240);

  l_proprietor_sin_1         varchar2(240);
  l_proprietor_sin_2         varchar2(240);
  l_transmitter_name         varchar2(240);
  l_transmitter_type_indicator    varchar2(240);
  l_transmitter_number           varchar2(240);
  l_transmitter_type_code        varchar2(240);
  l_transmitter_data_type_code    varchar2(240);
  l_transmitter_addr_line_1       varchar2(240);
  l_transmitter_addr_line_2       varchar2(240);
  l_transmitter_addr_line_3       varchar2(240);
  l_transmitter_city              varchar2(240);
  l_transmitter_province          varchar2(240);
  l_Federal_Youth_Hire_Ind        varchar2(80);
  l_transmitter_postal_code       varchar2(240);
  l_transmitter_country           varchar2(240);
  l_transmitter_orgid             number;
  l_technical_contact_name        varchar2(240);
  l_technical_contact_phone       varchar2(240);
  l_technical_contact_area_code varchar2(240);
  l_technical_contact_language    varchar2(240);
  l_technical_contact_email       varchar2(240);
  l_technical_contact_extn    varchar2(240);
  l_object_version_number         number;
  l_some_warning                  boolean;
  l_archive_item_id               number;
  l_taxation_year                 varchar2(240);
  l_effective_date                date;
  result                          number;

/* Alternate query to avoid hr_tax_units_v in t4a archiver */

cursor employer_info is
select  nvl(hoi6.ORG_INFORMATION9,ou2.name) GRE_stat_report_name,
        bg.business_group_id Business_group_id,
        hoi6.ORG_INFORMATION1 Employer_identification_number,
        hl2.ADDRESS_LINE_1 GRE_addrline1,
        hl2.ADDRESS_LINE_2 GRE_addrline2,
        hl2.ADDRESS_LINE_3 GRE_addrline3,
        hl2.TOWN_OR_CITY   GRE_town_or_city,
        DECODE(hl2.STYLE , 'US' , hl2.REGION_2 ,
                           'CA' , hl2.REGION_1 ,
                           'CA_GLB',hl2.region_1, ' ')  GRE_province,
        hl2.POSTAL_CODE GRE_postal_code,
        hl2.COUNTRY     GRE_country,
        nvl(hoi3.ORG_INFORMATION9,ou1.name) trans_stat_report_name,
        hl1.ADDRESS_LINE_1 trans_addrline1,
        hl1.ADDRESS_LINE_2 trans_addrline2,
        hl1.ADDRESS_LINE_3 trans_addrline3,
        hl1.TOWN_OR_CITY   trans_town_or_city,
        DECODE(hl1.STYLE , 'US' , hl1.REGION_2 ,
                           'CA' , hl1.REGION_1 ,
                           'CA_GLB',hl1.region_1, ' ')  trans_province,
        hl1.POSTAL_CODE trans_postal_code,
        hl1.COUNTRY     trans_country,
        hoi2.org_information5 trans_type_indicator,
        hoi2.ORG_INFORMATION4 trans_number,
        hoi2.ORG_INFORMATION2 trans_type_code,
        hoi2.ORG_INFORMATION3 trans_datatype_code,
        hoi2.ORG_INFORMATION6 trans_tech_contact_name,
        hoi2.ORG_INFORMATION8 trans_tech_contact_phone,
        hoi2.ORG_INFORMATION7 trans_tech_contact_areacode,
        hoi2.ORG_INFORMATION9 trans_tech_contact_lang,
        hoi2.ORG_INFORMATION17 trans_tech_contact_extn,
        hoi2.ORG_INFORMATION18 trans_tech_contact_email,
        hoi2.ORG_INFORMATION10 trans_acct_contact_name,
        hoi2.ORG_INFORMATION11 trans_acct_contact_area_code,
        hoi2.ORG_INFORMATION12 trans_acct_contact_phone,
        hoi2.ORG_INFORMATION13 trans_acct_contact_extn
from hr_all_organization_units ou1,        /* transmitter org */
     hr_organization_information hoi1, /* Transmitter GRE to check
                                       GRE/Legal Classification is enabled */
     hr_organization_information hoi2, /* Transmitter GRE to check
                                         'Fed Magnetic Reporting' */
     hr_organization_information hoi3, /* Transmitter GRE to check
                                          'Employer Identification' */
     hr_locations_all hl1,                 /* trans location */
     hr_all_organization_units ou2,        /* GRE Org */
     hr_organization_information hoi4, /* GRE to check GRE/Legal
                                          Classification is enabled */
     hr_organization_information hoi6, /* GRE to check
                                           'Employer Identification'*/
     hr_locations_all hl2,                 /* GRE location */
     per_business_groups bg
where bg.business_group_id = ou1.business_group_id
and bg.legislation_code = 'CA'
and ou1.organization_id = p_transmitter_gre_id
and ou1.organization_id = hoi1.organization_id
and hoi1.org_information_context = 'CLASS'
and hoi1.org_information1 = 'HR_LEGAL'
and hoi1.org_information2 = 'Y'
and ou1.location_id = hl1.location_id
and ou1.organization_id = hoi2.organization_id
and hoi2.org_information_context = 'Fed Magnetic Reporting'
and hoi2.org_information1 = 'Y'
and ou1.organization_id = hoi3.organization_id
and hoi3.org_information_context = 'Canada Employer Identification'
and hoi3.org_information5 in ('T4A/RL1','T4A/RL2')
and bg.business_group_id = ou2.business_group_id
and ou2.organization_id = p_tax_unit_id
and ou2.organization_id = hoi4.organization_id
and hoi4.org_information_context = 'CLASS'
and hoi4.org_information1 = 'HR_LEGAL'
and hoi4.org_information2 = 'Y'
and ou2.location_id = hl2.location_id
and ou2.organization_id = hoi6.organization_id
and hoi6.org_information_context = 'Canada Employer Identification'
and hoi6.ORG_INFORMATION5 in ('T4A/RL1','T4A/RL2');

/* Created this cursor to fix bug#2598802 */
CURSOR c_get_gre_acct_info(cp_gre_id number) IS
select hoi.ORG_INFORMATION10 GRE_acct_contact_name,
        hoi.ORG_INFORMATION12 GRE_acct_contact_phone,
        hoi.ORG_INFORMATION11 GRE_acct_contact_area_code,
        hoi.ORG_INFORMATION13 GRE_acct_contact_extn,
        hoi.ORG_INFORMATION14 GRE_Proprietor_SIN#1,
        hoi.ORG_INFORMATION15 GRE_Proprietor_SIN#2,
        hoi.ORG_INFORMATION16 GRE_Fedyouth_hire_Prgind
from   hr_organization_information hoi
where  hoi.organization_id = cp_gre_id
and    hoi.org_information_context = 'Fed Magnetic Reporting';

begin
  /* payroll action level database items */

    l_arch_gre_step := 30;

  /* Archive the Employer level data */

  begin
     hr_utility.trace('getting employer data  ');

     open employer_info;
     fetch employer_info
     into   l_name,                                l_business_group_id,
            l_employer_ein,                        l_address_line_1,
            l_address_line_2,                      l_address_line_3,
            l_town_or_city,                        l_province_code,
            l_postal_code,                         l_country_code,
            l_transmitter_name,
            l_transmitter_addr_line_1,
            l_transmitter_addr_line_2,             l_transmitter_addr_line_3,
            l_transmitter_city,                    l_transmitter_province,
            l_transmitter_postal_code,             l_transmitter_country,
            l_Transmitter_Type_Indicator,          l_Transmitter_number,
            l_Transmitter_Type_code,               l_Transmitter_data_type_code,
            l_technical_contact_name,              l_technical_contact_phone,
            l_technical_contact_area_code,         l_technical_contact_language,
            l_technical_contact_extn,             l_technical_contact_email,
            l_trans_acct_contact_name, l_trans_acct_contact_area_code,
            l_trans_acct_contact_phone, l_trans_acct_contact_extn;

     /* Added this part to fix bug#2598802 */
     open c_get_gre_acct_info(p_tax_unit_id);
     fetch c_get_gre_acct_info into l_accounting_contact_name,
                               l_accounting_contact_phone ,
                               l_accounting_contact_area_code,
                               l_accounting_contact_extension,
                               l_proprietor_sin_1,
                               l_proprietor_sin_2,
                               l_federal_youth_hire_ind;


     if employer_info%FOUND then
       close employer_info;
       hr_utility.trace('got employer data  ');
     else
        hr_utility.trace('cannot find employer data  ');
        l_employer_ein := null;
        l_address_line_1 := null;
        l_address_line_2 := null;
        l_address_line_3 := null;
        l_town_or_city := null;
        l_province_code := null;
        l_postal_code := null;
        l_country_code := null;
        l_name         := null;
        l_transmitter_name := null;
        l_transmitter_addr_line_1 := null;
        l_transmitter_addr_line_2 := null;
        l_transmitter_addr_line_3 := null;
        l_transmitter_city := null;
        l_transmitter_province := null;
        l_transmitter_postal_code := null;
        l_transmitter_country := null;
        l_technical_contact_name := null;
        l_technical_contact_phone := null;
        l_technical_contact_language := null;

       close employer_info;
       hr_utility.raise_error;
      end if;

     /* Added this part to fix bug#2598802 */
      if c_get_gre_acct_info%found then
         close c_get_gre_acct_info;
      else
         l_accounting_contact_name      := null;
         l_accounting_contact_phone     := null;
         l_accounting_contact_area_code := null;
         l_accounting_contact_extension := null;
         l_proprietor_sin_1             := null;
         l_proprietor_sin_2             := null;
         l_federal_youth_hire_ind       := null;
      end if;

         if l_accounting_contact_name is null then
            l_accounting_contact_name := l_trans_acct_contact_name;
         end if;

         if l_accounting_contact_phone     is null then
           l_accounting_contact_phone :=  l_trans_acct_contact_phone;
         end if;

         if l_accounting_contact_area_code  is null then
           l_accounting_contact_area_code :=  l_trans_acct_contact_area_code;
         end if;

         if l_accounting_contact_extension is null then
           l_accounting_contact_extension :=  l_trans_acct_contact_extn;
         end if;
   end;


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
-- l_user_entity_value_tab(l_counter) := l_transmitter_country;
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

-- Added by Saurabh for bug 4517693
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

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter):='CAEOY_FEDERAL_YOUTH_HIRE_PROGRAM_INDICATOR';
 l_user_entity_value_tab(l_counter) := l_federal_youth_hire_ind;

 for i in 1..l_counter loop

 l_arch_gre_step := 42;
      hr_utility.trace('calling archive API ' || l_user_entity_name_tab(i));
 ff_archive_api.create_archive_item(
--   p_validate        => 'TRUE'
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

/* Removed the unnecessary archiving of db items with dimension _GRE_YTD */

   --hr_utility.trace_off;
      g_archive_flag := 'Y';
  exception
     when others then
      g_archive_flag := 'N';
    if l_transmitter_name is null then
       hr_utility.set_message(801,'PAY_74014_NO_TRANSMITTER_ORG');
       hr_utility.set_message_token('ORGIND','GRE');
      /* push message into pay_message_lines */
      pay_core_utils.push_message(801,'PAY_74014_NO_TRANSMITTER_ORG','P');
      pay_core_utils.push_token('ORGIND','GRE');
              hr_utility.raise_error;
    else
      hr_utility.trace('Error in eoy_archive_gre_data at step :' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
              hr_utility.set_message(801, 'PAY_34957_ARCPROC_MUST_EXIST');
              hr_utility.raise_error;
     end if;
      raise hr_utility.hr_error;

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

  procedure eoy_archive_data(p_assactid in number, p_effective_date in date) is

    l_aaid           pay_assignment_actions.assignment_action_id%type;
    l_aaseq          pay_assignment_actions.action_sequence%type;
    l_asgid          pay_assignment_actions.assignment_id%type;
    l_date_earned    date;
    l_user_entity_name_tab    pay_ca_t4aeoy_archive.char240_data_type_table;
    l_balance_type_tab         pay_ca_t4aeoy_archive.char240_data_type_table;
    l_user_entity_value_tab   pay_ca_t4aeoy_archive.char240_data_type_table;
    l_tax_unit_id      pay_assignment_actions.tax_unit_id%type;
    l_business_group_id      pay_assignment_actions.tax_unit_id%type;
    l_year_start     date;
    l_year_end       date;
    l_context_no     number := 60;
    l_count          number := 0;
    l_jurisdiction   varchar2(11);
    l_province_uei      ff_user_entities.user_entity_id%type;
    l_county_uei     ff_user_entities.user_entity_id%type;
    l_city_uei       ff_user_entities.user_entity_id%type;
    l_county_sd_uei  ff_user_entities.user_entity_id%type;
    l_city_sd_uei    ff_user_entities.user_entity_id%type;
    l_province_abbrev   pay_us_states.state_abbrev%type;
    l_county_name    pay_us_counties.county_name%type;
    l_city_name      pay_us_city_names.city_name%type;
    l_cnt_sd_name    pay_us_county_school_dsts.school_dst_name%type;
    l_cty_sd_name    pay_us_city_school_dsts.school_dst_name%type;
    l_step           number := 0;
    l_county_code    varchar2(3);
    l_city_code      varchar2(4);
    l_jursd_context_id ff_contexts.context_id%type;
    l_taxunit_context_id ff_contexts.context_id%type;
    l_seq_tab                 pay_ca_t4aeoy_archive.number_data_type_table;
    l_context_id_tab          pay_ca_t4aeoy_archive.number_data_type_table;
    l_context_val_tab         pay_ca_t4aeoy_archive.char240_data_type_table;
    l_chunk                   number;
    l_payroll_action_id       number;
    l_defined_balance_id      number;
    l_result      number;
    l_person_id               number;
    l_organization_id               number;
    l_location_id               number;
    l_first_name                 varchar2(240);
    l_last_name                  varchar2(240);
    l_employee_number            varchar2(240);
    l_national_identifier        varchar2(240);
    l_pre_name_adjunct           varchar2(240);
    l_middle_names               varchar2(240);
    l_employee_phone_no          varchar2(240);
    l_work_telephone          varchar2(240);
    l_address_line1              varchar2(240);
    l_address_line2                  varchar2(240);
    l_address_line3                  varchar2(240);
    l_address_line4                  varchar2(240);
    l_town_or_city                  varchar2(80);
    l_province_code                  varchar2(80);
    l_postal_code                  varchar2(80);
    l_telephone_number                  varchar2(80);
    l_country_code                  varchar2(80);
    l_counter                       number;
    l_archive_item_id               number;
    result                       number := 0;
    earning_exists               number := 0;
    l_object_version_number number;
    l_context_id number;
    l_context_val varchar2(80);
    l_some_warning boolean;
    l_cpp_exempt_flag                  varchar2(80);
    l_ei_exempt_flag                  varchar2(80);
    l_footnote_code              varchar2(10);
    l_box38_footnote_code              varchar2(10) := NULL;
    l_footnote_balance              varchar2(80);
    l_footnote_amount              number;
    old_l_footnote_code varchar2(80) := null;
    l_footnote_code_ue varchar2(80);
    l_box38_footnote_code_ue varchar2(80);
    l_footnote_amount_ue varchar2(80);
    l_no_of_fn_codes  number := 0;
    l_box38_count  number := 0;
    l_value  number := 0;
    old_l_value  number := 0;
    old_l_value1  number := 0;
    old_l_value2  number := 0;
    arch_l_value  number := 0;
    l_registration_no    varchar2(150);
    old_l_registration_no    varchar2(150);
    old_l_registration_no1    varchar2(150);
    old_l_registration_no2    varchar2(150);
    arch_l_registration_no    varchar2(150);
    l_balance_name       varchar2(150);
    l_single_footnote_code varchar2(10);
    lv_serial_number          varchar2(30);
    l_negative_balance_exists   varchar2(5);

  /* new variables added for Federal YE Amendment PP */
   ld_fapp_effective_date       date;
   lv_fapp_report_type          varchar2(20);
   ln_fapp_locked_action_id     number;
   lv_fapp_flag                 varchar2(2);
   lv_fapp_locked_actid_reptype varchar2(20);

/* T4A Nonbox footnote variables */
   l_messages                VARCHAR2(240);
   l_prev_messages           VARCHAR2(240);
   l_mesg_amt                NUMBER(16,2);
   l_total_mesg_amt          NUMBER(16,2);
   ln_tax_unit_id            NUMBER;
   ln_prev_tax_unit_id       NUMBER;
   ld_eff_date               DATE;
   ld_prev_eff_date          DATE;
   ln_assignment_action_id   NUMBER;
   l_context_value           VARCHAR2(50);
   l_action_information_id_1 NUMBER ;
   l_object_version_number_1 NUMBER ;

/* T4A_Registration_no variables part of bug fix 2408456 */
   l_check_flag varchar2(2);
   l_element_type_id number(20);
   l_run_result_id number(20);
   l_ele_proc_eff_date date;
   l_info_ele_amt varchar2(20);
   l_ele_classification_id number(20);
   l_ele_classification_name varchar2(50);

   lv_emplr_regno varchar2(20);
   lv_emplr_regno1 varchar2(20);
   lv_emplr_regno2 varchar2(20);
   ln_emplr_regamt number(30);
   ln_emplr_regamt1 number(30);
   ln_emplr_regamt2 number(30);

   lv_footnote_element      varchar2(50);
   l_transmitter_gre_id    number;

   l_status_indian  varchar2(1);
     /* cursor used to archive the footnote code values */
     cursor  c_balance_feed_info (p_balance_name varchar2) is
           select distinct pet.element_information18,
                  pbt1.balance_name
           from pay_balance_feeds_f pbf,
                pay_balance_types   pbt,
                pay_balance_types   pbt1,
                pay_input_values_f  piv,
                pay_element_types_f pet,
                fnd_lookup_values   flv
           where pbt.balance_name          = p_balance_name
           and   pbf.balance_type_id       = pbt.balance_type_id
           and   pbf.input_value_id        = piv.input_value_id
           and   piv.element_type_id       = pet.element_type_id
           and   pet.business_group_id     = l_business_group_id
           and   pbt1.balance_type_id      = pet.element_information10
           and   pet.element_information18 = flv.lookup_code
           and   flv.lookup_type           = 'PAY_CA_T4A_FOOTNOTES'
           and   flv.language              = userenv('LANG')
           order by pet.element_information18;

     /* cursor used to archive the Pension Adjustment Registration Number */
     cursor  c_reg_balance_feed_info (p_balance_name varchar2) is
           select nvl(pet.element_information20,'NOT FOUND'),
                  pbt1.balance_name,pet.element_type_id,
                  pet.classification_id
           from pay_balance_feeds_f pbf,
                pay_balance_types pbt,
                pay_balance_types pbt1,
                pay_input_values_f piv,
                pay_element_types_f pet
           where pbt.balance_name = p_balance_name
           and   pbf.balance_type_id = pbt.balance_type_id
           and   pbf.input_value_id = piv.input_value_id
           and   piv.element_type_id = pet.element_type_id
           and   pet.business_group_id = l_business_group_id
           and   pbt1.balance_type_id = pet.element_information10
--           and   pet.element_information_category = 'CA_EARNINGS'
           and   pet.element_information20 is not null;

        /* Cursor for T4A Nonbox Footnote archive to fix bug#2175045 */
         /* Modified the cur_non_box_mesg cursor to fix bug#3641353.
            Kept the Jurisdiction context validation because of performance
            for T4A Reporting and added action_type 'B' Balance Adj's */
         CURSOR cur_non_box_mesg( cp_asgact_id in number,
                                  cp_eff_date  in date) is
          select distinct prrv1.result_value,
                prrv2.result_value,
                hoi.organization_id,
                run_ppa.effective_date,
                run_paa.assignment_action_id
          from pay_run_result_values prrv1
            , pay_run_result_values prrv2
            , pay_run_results prr
            , pay_element_types_f pet
            , pay_input_values_f piv1
            , pay_input_values_f piv2
            , pay_assignment_actions run_paa
            , pay_payroll_actions run_ppa
            , pay_assignment_actions arch_paa
            , pay_payroll_actions arch_ppa
            , per_all_assignments_f arch_paf
            , per_all_assignments_f all_paf
            , hr_all_organization_units hou
            , hr_organization_information hoi
         where arch_paa.assignment_action_id = cp_asgact_id
         and   arch_ppa.payroll_action_id    = arch_paa.payroll_action_id
         and   hou.business_group_id         = arch_ppa.business_group_id
         and   hou.organization_id           = hoi.organization_id
         and   hoi.organization_id          =
                 to_number(pycadar_pkg.get_parameter('TRANSFER_GRE',arch_ppa.legislative_parameters))
         and   hoi.org_information_context   = 'Canada Employer Identification'
         and   hoi.org_information5 IN ('T4A/RL1','T4A/RL2')
         and   run_paa.tax_unit_id           = hou.organization_id
         and   run_ppa.payroll_action_id     =  run_paa.payroll_action_id
         and   run_ppa.action_type           in ( 'R', 'Q', 'B' )
         and   to_char(run_ppa.effective_date,'YYYY' ) =
                                  to_char(cp_eff_date,'YYYY')
         and   run_paa.action_status         = 'C'
         and   pet.element_name = lv_footnote_element --'T4A NonBox Footnotes'
         and   prr.assignment_action_id  = run_paa.assignment_action_id
         and   prr.element_type_id       = pet.element_type_id
         and   piv1.element_type_id      = pet.element_type_id
         and   piv1.name                 = 'Message'
         and   prrv1.run_result_id       = prr.run_result_id
         and   prrv1.input_value_id      = piv1.input_value_id
         and   piv2.element_type_id      = pet.element_type_id
         and   piv2.name                 = 'Amount'
         and   prrv2.run_result_id       = prrv1.run_result_id
         and   prrv2.input_value_id      = piv2.input_value_id
         and   arch_paf.assignment_id        = arch_paa.assignment_id
         and   to_char(cp_eff_date,'YYYY')
               between to_char(arch_paf.effective_start_date,'YYYY')
               and to_char(arch_paf.effective_end_date,'YYYY')
         and   all_paf.person_id     = arch_paf.person_id
         and   to_char(cp_eff_date,'YYYY')
               between to_char(all_paf.effective_start_date,'YYYY')
               and to_char(all_paf.effective_end_date,'YYYY')
         and   run_paa.assignment_id     = all_paf.assignment_id
         and exists (select 1
		     from pay_action_contexts pac,ff_contexts ffc
                     where ffc.context_name          = 'JURISDICTION_CODE'
                     and   pac.context_id            = ffc.context_id
                     and   pac.assignment_id         = run_paa.assignment_id);


         /* Cursor to check the Employer Level PP Registration Number
            Bug fix#2696309 */
         CURSOR c_get_emplr_reg_no(cp_tax_unit_id varchar2
                                  ,cp_payroll_action_id number
                                  ,cp_reg_no varchar2
                                  ,cp_eff_date date) IS
         select action_information4,to_number(action_information5)
         from pay_action_information
         where action_context_id = cp_payroll_action_id
         and effective_date = cp_eff_date
         AND tax_unit_id = cp_tax_unit_id
         and action_information_category = 'CAEOY PENSION PLAN INFO'
         AND ACTION_INFORMATION4 = cp_reg_no;

  CURSOR c_get_latest_asg(p_person_id number ) IS
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


/* New cursors added for Federal YE Amendment Pre-Process Validation */

  CURSOR c_get_fapp_lkd_actid_rtype(cp_locked_actid number) IS
  select ppa.report_type
  from pay_payroll_actions ppa,pay_assignment_actions paa
  where paa.assignment_action_id = cp_locked_actid
  and ppa.payroll_action_id = paa.payroll_action_id;

  CURSOR c_get_fapp_locked_action_id(cp_locking_act_id number) IS
  select locked_action_id
  from pay_action_interlocks
  where locking_action_id = cp_locking_act_id;

/* New cursor for checking for the employee been a Status Indian */
   CURSOR c_get_status_indian(cp_assign number,
                              cp_effec_date date) IS
   select ca_tax_information1
   from   pay_ca_emp_fed_tax_info_f pca
   where  pca.assignment_id = cp_assign
    and   cp_effec_date between pca.effective_start_date and
          pca.effective_end_date;

  begin

--    hr_utility.trace_on('Y','ORACLEMM');

      l_count := 0;
      l_box38_footnote_code := '00';
      l_negative_balance_exists := 'N';

      hr_utility.set_location ('archive_data',1);
      hr_utility.trace('getting assignment for asgactid'|| to_char(p_assactid));


      SELECT aa.assignment_id,
            pay_magtape_generic.date_earned (p_effective_date,aa.assignment_id),
            aa.tax_unit_id,
            aa.chunk_number,
            aa.payroll_action_id,
            aa.serial_number
            into l_asgid,
                 l_date_earned,
                 l_tax_unit_id,
                 l_chunk,
                 l_payroll_action_id,
                 lv_serial_number
        FROM pay_assignment_actions aa
        WHERE aa.assignment_action_id = p_assactid;

/*Bug 4021563  Fetching the Status Indian flag */
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
       else
          g_archive_flag := 'Y';
        end if;


      l_year_start := trunc(p_effective_date, 'Y');
      l_year_end   := add_months(trunc(p_effective_date, 'Y'),12) - 1;

      if to_number(to_char(l_year_end,'YYYY')) > 2005 then
         lv_footnote_element := 'T4A Non Box Footnotes';
      else
         lv_footnote_element := 'T4A NonBox Footnotes';
      end if;

      hr_utility.trace('l_date_earned : '|| to_char(l_date_earned));

/* YE-2001 change to avoid hr_ca_tax_units_v view */
      select business_group_id
      into l_business_group_id
      from hr_all_organization_units
      where organization_id = l_tax_unit_id;

      l_step := 1;

/*
     select paa1.assignment_action_id
     into l_aaid
     from pay_assignment_actions paa1,
          per_all_assignments_f      paf2
     where paa1.assignment_id = paf2.assignment_id
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
            open c_get_latest_asg(lv_serial_number );
                 fetch c_get_latest_asg into l_aaid;
            close c_get_latest_asg;
  hr_utility.trace('max assignment_action_id : ' || to_char(l_aaid));

          exception
             when no_data_found then
                  l_aaid := -9999;
                  raise_application_error(-20001,'Balance Assignment Action does not exist for : '
                       ||to_char(l_person_id));
          end;
      hr_utility.trace('max assignment_action_id : ' || to_char(l_aaid));
      hr_utility.trace('l_tax_unit_id : ' || to_char(l_tax_unit_id));
      hr_utility.trace('l_asgid : ' || to_char(l_asgid));



          /* Assign values to the PL/SQL tables */

          l_step := 16;


          l_seq_tab(2) := 2;
          l_context_id_tab(2)  := l_taxunit_context_id;
          l_context_val_tab(2) := l_tax_unit_id;

/*
      l_count := l_count + 1;
      l_user_entity_name_tab(l_count)  := 'CAEOY_GROSS_EARNINGS_PER_GRE_YTD';
      l_balance_type_tab(l_count)  := 'Gross Earnings';
*/

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX16_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX16';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX18_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX18';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX20_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX20';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_FED_WITHHELD_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'FED Withheld';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX24_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX24';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX26_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX26';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX27_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX27';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX28_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX28';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX30_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX30';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX32_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX32';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX34_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX34';
/*
      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX36_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX36';
*/
      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX40_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX40';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX42_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX42';

      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_T4A_BOX46_PER_GRE_YTD';
      l_balance_type_tab(l_count)     := 'T4A_BOX46';

/*    Initializing variables as part of bug fix#2426517 */
      l_box38_footnote_code := '00';
      l_box38_count         := 0;

   if (  (pay_ca_balance_pkg.call_ca_balance_get_value
                  ( 'Gross Earnings',
                   'YTD' , l_aaid, l_asgid , NULL, 'PER' ,
                    l_tax_unit_id, l_business_group_id, NULL)
               <> 0) OR
         (pay_ca_balance_pkg.call_ca_balance_get_value
                 ( 'T4A No Gross Earnings',
                   'YTD' , l_aaid, l_asgid , NULL, 'PER' ,
                    l_tax_unit_id, l_business_group_id, NULL)
               <> 0) ) then

       earning_exists := 1;

          hr_utility.trace('starting loop for balances');

      for i in 1 .. l_count
      loop
       result := 0;
        /* Now, set up the jurisdiction context for the db items that
           need the jurisdiction as a context.Here we are archiving all the
           jurisdictions we got from pay_action_contexts for all
           assignment_actions. So even though a particular assignment_action
           is for aparticular jurisdiction the archiver table has data for
           all the jurisdictions, but values of irrelevant jurisdictions will
           be 0  */

        /* To get balances you must use the highest assignment action . Since
           T4A does not have Jurisdiction specific balances first we have to
           sum up balances for all jurisdictions. */

           pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
           pay_ca_balance_view_pkg.set_context ('ASSIGNMENT_ACTION_ID',l_aaid);

           hr_utility.trace('i is ' ||to_char(i));
           hr_utility.trace('Balance type is ' ||l_balance_type_tab(i));
           hr_utility.trace('AAID is ' || to_char(l_aaid));
           hr_utility.trace('ASGID is ' || to_char(l_asgid));
           hr_utility.trace('Tax_unit_id is ' || to_char(l_tax_unit_id));
           hr_utility.trace('Business_group_id is ' || to_char(l_business_group_id));

          result := result + pay_ca_balance_pkg.call_ca_balance_get_value
                    ( l_balance_type_tab(i),
                      'YTD' ,
                      l_aaid,
                      l_asgid,
                      NULL,
                      'PER' ,
                      l_tax_unit_id,
                      l_business_group_id,
                      NULL
                     );

/* start footnote archiving */

    l_footnote_code         := NULL;
    l_footnote_balance      := NULL;
    l_footnote_amount       := 0;
    old_l_footnote_code     := NULL;
    l_footnote_code_ue      := NULL;
    l_box38_footnote_code_ue:= NULL;
    l_footnote_amount_ue    := NULL;
    l_no_of_fn_codes        := 0;
    l_value                 := 0;
    old_l_value             := 0;
    old_l_value1             := 0;
    old_l_value2             := 0;
    l_count                 := 0;
    l_single_footnote_code  := NULL;

  if result <> 0 then

         /* hr_utility.trace_on('Y','T4AARCH');  */
            hr_utility.trace('Result is ' || to_char(result));
         /* Check the footnote amounts and codes and archive them */
         /* Check which elements has fed the balance and what are their
            footnotes and if the primary balance for that element is 0 or not */

       if l_balance_type_tab(i) in (  'T4A_BOX16',
                                        'T4A_BOX18',
                                        'T4A_BOX24',
                                        'T4A_BOX26',
                                        'T4A_BOX27',
                                        'T4A_BOX28',
                                        'T4A_BOX32',
                                        'T4A_BOX40') then
        begin
         hr_utility.trace('Footnote Archiving Start for Asg_act_id: '||to_char(p_assactid));
          hr_utility.trace('balance_type - values before c_balance_feed_info'||l_balance_type_tab(i));
          hr_utility.trace('l_box38_footnote_code: '||l_box38_footnote_code);
          hr_utility.trace('l_footnote_code : '||l_footnote_code);
          hr_utility.trace('l_no_of_fn_codes :'||l_no_of_fn_codes);
          hr_utility.trace('l_footnote_amount :'||to_char(l_footnote_amount));
          hr_utility.trace('old_l_footnote_code :'||old_l_footnote_code);
          hr_utility.trace('l_box38_count :'||l_box38_count);

          open c_balance_feed_info(l_balance_type_tab(i));

            hr_utility.trace('balance_type '||l_balance_type_tab(i));

            loop

              hr_utility.trace('begin of loop c_balance_feed_info '|| l_count);
              hr_utility.trace('666 l_count '|| l_count);
              hr_utility.trace('666 p_assactid '|| p_assactid);
              fetch c_balance_feed_info into l_footnote_code, l_footnote_balance;
                if l_balance_type_tab(i) = 'T4A_BOX24'
                   and l_footnote_code = '10(BOX24)' then
                  l_footnote_code := '10A';
                end if;

                exit when c_balance_feed_info%NOTFOUND;
                l_count := l_count + 1;

                hr_utility.trace('l_footnote_balance '||l_footnote_balance);
                hr_utility.trace('l_footnotecode '||l_footnote_code);
                hr_utility.trace('old_l_footnotecode '||old_l_footnote_code);
                if l_footnote_code <> old_l_footnote_code then /* footnote
                                                                  changed */
                  if old_l_footnote_code is not null then /* not the first
                                                             record */

                    hr_utility.trace('archive ft_amount_ue'
                                          ||l_footnote_amount_ue);
                    hr_utility.trace('archive ft_amount'
                                          ||to_char(l_footnote_amount));
                    if get_footnote_user_entity_id(l_footnote_amount_ue) <> 0
                       and l_footnote_amount <> 0 then

                       l_footnote_amount_ue := 'CAEOY_' || l_balance_type_tab(i) ||'_'||old_l_footnote_code||'_AMT_PER_GRE_YTD';

                       ff_archive_api.create_archive_item(
                           p_archive_item_id => l_archive_item_id
                          ,p_user_entity_id => get_footnote_user_entity_id(l_footnote_amount_ue)
                          ,p_archive_value  => l_footnote_amount
                          ,p_archive_type   => 'AAP'
                          ,p_action_id      => p_assactid
                          ,p_legislation_code => 'CA'
                          ,p_object_version_number  => l_object_version_number
                          ,p_context_name1          => 'TAX_UNIT_ID'
                          ,p_context1               => l_tax_unit_id
                          ,p_some_warning           => l_some_warning
                          );

                       l_no_of_fn_codes := l_no_of_fn_codes + 1;
                       l_box38_count := l_box38_count + 1;
                       l_single_footnote_code := old_l_footnote_code;

                       if l_footnote_amount < 0 then
                          l_negative_balance_exists := 'Y';
                       end if;

                    end if;
                   l_footnote_amount := 0;
                   old_l_footnote_code :=  l_footnote_code ;
                  end if;
                end if; /* end of if l_footnote_code <>  old_l_footnote_code  */

              old_l_footnote_code :=  l_footnote_code ;
              l_footnote_amount_ue := 'CAEOY_' || l_balance_type_tab(i) ||'_'||old_l_footnote_code||'_AMT_PER_GRE_YTD';


              l_value := pay_ca_balance_pkg.call_ca_balance_get_value
                         ( l_footnote_balance,
                           'YTD' ,
                           l_aaid,
                           l_asgid,
                           NULL,
                           'PER' ,
                           l_tax_unit_id,
                           l_business_group_id,
                           NULL );

               hr_utility.trace('666 l_footnote_balance '|| l_footnote_balance);
               hr_utility.trace('666 l_value '|| l_value);
               l_footnote_amount := l_footnote_amount + l_value ;

               /* to fix bug#2426517 added one more validation to if stmt */
/*               if (l_value <> 0 and
                 get_footnote_user_entity_id(l_footnote_amount_ue) <> 0 ) then

                 l_no_of_fn_codes := l_no_of_fn_codes + 1;
                 l_box38_count := l_box38_count + 1;
                 l_single_footnote_code := l_footnote_code;

                 hr_utility.trace('chk l_no_of_fn_codes '|| l_no_of_fn_codes);
                 hr_utility.trace('chk l_box38_count '|| l_box38_count);
                 hr_utility.trace('chk l_single_footnote_code '|| l_single_footnote_code);
               end if;
*/
               hr_utility.trace('end of loop record over for balance: '|| l_balance_type_tab(i));
           end loop;
         close c_balance_feed_info;

         if  l_footnote_code is not null and
             l_footnote_amount_ue is not null and
             l_footnote_amount <> 0 and
             get_footnote_user_entity_id(l_footnote_amount_ue) <> 0
         then
             hr_utility.trace('666archive footnote amount '|| l_footnote_amount);
             hr_utility.trace('666archive footnote amount ue'|| l_footnote_amount_ue);

             ff_archive_api.create_archive_item(
               p_archive_item_id => l_archive_item_id
              ,p_user_entity_id => get_footnote_user_entity_id(l_footnote_amount_ue)
              ,p_archive_value  => l_footnote_amount
              ,p_archive_type   => 'AAP'
              ,p_action_id      => p_assactid
              ,p_legislation_code => 'CA'
              ,p_object_version_number  => l_object_version_number
              ,p_context_name1          => 'TAX_UNIT_ID'
              ,p_context1               => l_tax_unit_id
              ,p_some_warning           => l_some_warning
              );

             l_no_of_fn_codes := l_no_of_fn_codes + 1;
             l_box38_count := l_box38_count + 1;
             l_single_footnote_code := l_footnote_code;

             if l_footnote_amount < 0 then
                l_negative_balance_exists := 'Y';
             end if;

          end if;

              hr_utility.trace('666archive l_no_of_fn_codes '|| l_no_of_fn_codes);
           if l_no_of_fn_codes > 1 then
              l_footnote_code := '13';
              hr_utility.trace('666archive footnote code '|| l_footnote_code);
              /* changed here as part of bugfix#2426517 */
           elsif l_no_of_fn_codes = 1 then
              l_footnote_code := l_single_footnote_code;
              hr_utility.trace('666archive footnote code '|| l_single_footnote_code);
           elsif l_no_of_fn_codes = 0 then
              l_footnote_code := '00';
              hr_utility.trace('666archive footnote code '|| l_footnote_code);
           end if;

           l_footnote_code_ue := 'CAEOY_' || l_balance_type_tab(i) || '_FOOTNOTE_CODE';

           hr_utility.trace('before archiving l_footnote_code_ue is '|| l_footnote_code_ue);
           /* Part of fix for bug#2426517, to avoid unnecessary archiving
              of footnote code added one more condiftion to if stmt before
              archiving the footnote code for the corresponding BOX balance */

             if l_footnote_code is not null and l_no_of_fn_codes > 0 and
                get_footnote_user_entity_id(l_footnote_code_ue) <> 0 then

                hr_utility.trace('l_footnote_code_ue:'|| l_footnote_code_ue);
                hr_utility.trace('l_footnote_code:'|| l_footnote_code);
                hr_utility.trace('l_single_footnote_code:'|| l_single_footnote_code);
                ff_archive_api.create_archive_item(
            --    p_validate      => 'TRUE'
                  p_archive_item_id => l_archive_item_id
                 ,p_user_entity_id => get_footnote_user_entity_id(l_footnote_code_ue)
                 ,p_archive_value  => l_footnote_code
                 ,p_archive_type   => 'AAP'
                 ,p_action_id      => p_assactid
                 ,p_legislation_code => 'CA'
                 ,p_object_version_number  => l_object_version_number
                 ,p_context_name1          => 'TAX_UNIT_ID'
                 ,p_context1               => l_tax_unit_id
                 ,p_some_warning           => l_some_warning
                 );
             end if;

          /* assigning value to box38_footnote_code */

             hr_utility.trace('999 l_box38_count '|| l_box38_count);
             /* initialised l_box38_footnote_code before checking
                gross earnings to this assignment action fix#2426517 */

	     if l_box38_count > 1 then
                l_box38_footnote_code := '13';
                hr_utility.trace('666 l_box38_footnote_code '||l_box38_footnote_code);
                /* Added one more condition to archive correct footnote code
                   value for box38 as part of bug fix#2426517 and assigned
                   l_single_footnote_code to l_box38_footnote_code variable */
             elsif l_box38_count = 1 and l_no_of_fn_codes > 0 then
                   l_box38_footnote_code := l_single_footnote_code;
                   hr_utility.trace('666 l_box38_footnote_code '||l_box38_footnote_code);
             end if;

         end;
        end if;
       end if;
       /** End of Footnote archiving **/

       --hr_utility.trace_off;

         hr_utility.trace('for Asg_Act_id :'||to_char(p_assactid));
         hr_utility.trace('l_user_entity_name_tab(i) is ' || l_user_entity_name_tab(i));
         hr_utility.trace('Result is ' || to_char(result));

         /* Added this condition to fix bug#2598777 */
         if  l_user_entity_name_tab(i) = 'CAEOY_T4A_BOX34_PER_GRE_YTD' then
             result := round(result);
         end if;
/* Bug 4021563 Added code for Status Indian type employee */
       if (l_balance_type_tab(i) in (  'T4A_BOX16', 'T4A_BOX18',
                                        'T4A_BOX26',
                                        'T4A_BOX27',
                                        'T4A_BOX28') and l_status_indian = 'Y') then
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
            ,p_context_name1          => 'TAX_UNIT_ID'
            ,p_context1               => l_tax_unit_id
            ,p_some_warning           => l_some_warning
            );

         if result < 0  then
            l_negative_balance_exists := 'Y';
         end if;

     end loop; /* for archiving all T4A Balances */

        /** Start box38 footnote archiving **/
        hr_utility.trace('for Asg_Act_id :'||to_char(p_assactid));
        hr_utility.trace('Archiving CAEOY_T4A_FOOTNOTE_CODE ');
        hr_utility.trace('l_box38_footnote_code '||l_box38_footnote_code);

    /** box38 footnote archive has been moved after nonbox footnote archive **/

    /* start registration number archiving */

        l_registration_no := NULL;
        old_l_registration_no := NULL;
        arch_l_registration_no := NULL;
        old_l_value := 0;
        old_l_registration_no1 := NULL;
        old_l_value1 := 0;
        old_l_registration_no2 := NULL;
        old_l_value2 := 0;
        arch_l_value := 0;
        l_value := 0;

        begin

          open c_reg_balance_feed_info('T4A_BOX34');

          loop

           fetch c_reg_balance_feed_info into l_registration_no,l_balance_name,
                 l_element_type_id,l_ele_classification_id;
           exit when c_reg_balance_feed_info%NOTFOUND;

            hr_utility.trace('checking for T4A_BOX34');
            hr_utility.trace('p_assactid:'||to_char(p_assactid));
            hr_utility.trace('l_asgid:'||to_char(l_asgid));
            hr_utility.trace('l_registration_no:'||l_registration_no);
            hr_utility.trace('l_balance_name:'||l_balance_name);
            hr_utility.trace('l_element_type_id:'||to_char(l_element_type_id));
            hr_utility.trace('before c_ele_processed cur l_check_flag:'||l_check_flag);
            hr_utility.trace('l_ele_classification_id:'||to_char(l_ele_classification_id));

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

            hr_utility.trace('before check null l_value:'||to_char(l_value));
             if l_value is null then
                  l_value := 0;
             end if;

            hr_utility.trace('after check null l_value:'||to_char(l_value));


            /* Condition to check the amounts and determine the registration
               number to archive Bug fix 2408456 */
               if old_l_value = 0 then
                     hr_utility.trace('in reg1');
                 old_l_value := l_value;
                 old_l_registration_no := l_registration_no;
               elsif old_l_value1 = 0 then
                     hr_utility.trace('in reg2');
                 old_l_value1 := l_value;
                 old_l_registration_no1 := l_registration_no;
               elsif old_l_value2 = 0 then
                     hr_utility.trace('in reg3');
                 old_l_value2 := l_value;
                 old_l_registration_no2 := l_registration_no;
               else
                if l_value > nvl(old_l_value,0) then
                 hr_utility.trace('old_l1');
                 old_l_value := l_value;
                 old_l_registration_no := l_registration_no;
                elsif l_value > nvl(old_l_value1,0) then
                 hr_utility.trace('old_2');
                 old_l_value1 := l_value;
                 old_l_registration_no1 := l_registration_no;
                elsif l_value > nvl(old_l_value2,0) then
                 old_l_value2 := l_value;
                 old_l_registration_no2 := l_registration_no;
                end if;
             end if;
            /* End of Condition to check amounts Bug fix 2408456 */

           end loop;
         close c_reg_balance_feed_info;
                    if old_l_value > old_l_value1 then
                     hr_utility.trace('in reg4');
                           if old_l_value> old_l_value2 then
                               arch_l_registration_no := old_l_registration_no;
                               arch_l_value := old_l_value;
                           else
                              arch_l_registration_no := old_l_registration_no2;
                                arch_l_value := old_l_value2;
                           end if;
                   else
                     if old_l_value1>old_l_value2 then
                             arch_l_registration_no := old_l_registration_no1;
                             arch_l_value := old_l_value1;
                           else
                              arch_l_registration_no := old_l_registration_no2;
                                arch_l_value := old_l_value2;
                           end if;
                     end if;

           /* archive registration number derived from T4A_BOX34 */
             if  arch_l_registration_no is not null and arch_l_value > 0 then

               ff_archive_api.create_archive_item(
               --  p_validate      => 'TRUE'
                   p_archive_item_id => l_archive_item_id
                  ,p_user_entity_id => get_user_entity_id('CAEOY_T4A_EMPLOYEE_REGISTRATION_NO')
                  ,p_archive_value  => arch_l_registration_no
                  ,p_archive_type   => 'AAP'
                  ,p_action_id      => p_assactid
                  ,p_legislation_code => 'CA'
                  ,p_object_version_number  => l_object_version_number
                  ,p_some_warning           => l_some_warning
                  );
               end if;

             /* Bug fix#2696309, Employer level Pension Plan Register Number */
                        hr_utility.trace('Start of Employer Level PP Reg no ');

             if  old_l_registration_no is not null  and old_l_value  >0 then
                           hr_utility.trace('in reg1 pay_action_information');
                     hr_utility.trace('in old_l_value = ' || to_char(old_l_value));
                     hr_utility.trace('in old_l_reg = ' || old_l_registration_no);

                        open c_get_emplr_reg_no(to_char(l_tax_unit_id),
                                                l_payroll_action_id
                                                ,old_l_registration_no
                                               ,p_effective_date);
                        fetch c_get_emplr_reg_no into lv_emplr_regno,ln_emplr_regamt;
                        if c_get_emplr_reg_no%FOUND then
                     hr_utility.trace('in ln_emplr_regamt = ' || to_char(ln_emplr_regamt));

                           ln_emplr_regamt := ln_emplr_regamt + old_l_value;

                           update pay_action_information
                           set action_information5 = to_char(ln_emplr_regamt)
                           where action_context_id = l_payroll_action_id
                           and   tax_unit_id = l_tax_unit_id
                           and   effective_date = p_effective_date
                           and action_information_category = 'CAEOY PENSION PLAN INFO'
                           AND ACTION_INFORMATION4 = old_l_registration_no;


                        else

                     hr_utility.trace('in reg1 insert pay_action_information');
                          -- insert a new record into pay_action_information

                        pay_action_information_api.create_action_information(
                        p_action_information_id => l_action_information_id_1,
                        p_object_version_number => l_object_version_number_1,
                        p_action_information_category => 'CAEOY PENSION PLAN INFO',
                        p_action_context_id           => l_payroll_action_id,
                        p_action_context_type         => 'PA',
                        p_jurisdiction_code           => NULL,
                        p_tax_unit_id                 => l_tax_unit_id,
                        p_effective_date              => p_effective_date,
                        p_action_information1  => NULL,
                        p_action_information2  => NULL,
                        p_action_information3  => NULL,
                        p_action_information4  => old_l_registration_no,
                        p_action_information5  => to_char(old_l_value),
                        p_action_information6  => NULL,
                        p_action_information7  => NULL,
                        p_action_information8  => NULL,
                        p_action_information9  => NULL,
                        p_action_information10 => NULL,
                        p_action_information11 => NULL,
                        p_action_information12 => NULL,
                        p_action_information13 => NULL,
                        p_action_information14 => NULL,
                        p_action_information15 => NULL,
                        p_action_information16 => NULL,
                        p_action_information17 => NULL,
                        p_action_information18 => NULL,
                        p_action_information19 => NULL,
                        p_action_information20 => NULL,
                        p_action_information21 => NULL,
                        p_action_information22 => NULL,
                        p_action_information23 => NULL,
                        p_action_information24 => NULL,
                        p_action_information25 => NULL,
                        p_action_information26 => NULL,
                        p_action_information27 => NULL,
                        p_action_information28 => NULL,
                        p_action_information29 => NULL,
                        p_action_information30 => NULL
                        );

                    end if; -- c_get_emplr_reg_no%FOUND
                    close c_get_emplr_reg_no;
                   end if;

             if  old_l_registration_no1 is not null   and old_l_value1  >0 then
                           hr_utility.trace('in reg2 pay_action_information');

                     hr_utility.trace('in old_l_value1 = ' || to_char(old_l_value1));
                     hr_utility.trace('in old_l_reg1 = ' || old_l_registration_no1);

                        open c_get_emplr_reg_no(to_char(l_tax_unit_id),
                                                l_payroll_action_id
                                               , old_l_registration_no1
                                               ,p_effective_date);
                        fetch c_get_emplr_reg_no into lv_emplr_regno1,ln_emplr_regamt1;
                        if c_get_emplr_reg_no%FOUND then

                     hr_utility.trace('in ln_emplr_regamt1 = ' || to_char(ln_emplr_regamt1));

                           ln_emplr_regamt1 := ln_emplr_regamt1 + old_l_value1;

                           update pay_action_information
                           set action_information5 = to_char(ln_emplr_regamt1)
                           where action_context_id = l_payroll_action_id
                           and   tax_unit_id = l_tax_unit_id
                           and   effective_date = p_effective_date
                           and action_information_category = 'CAEOY PENSION PLAN INFO'
                           AND ACTION_INFORMATION4 = old_l_registration_no1;

                        else
                     hr_utility.trace('in reg2 insert pay_action_information');

                          -- insert a new record into pay_action_information

                        pay_action_information_api.create_action_information(
                        p_action_information_id => l_action_information_id_1,
                        p_object_version_number => l_object_version_number_1,
                        p_action_information_category => 'CAEOY PENSION PLAN INFO',
                        p_action_context_id           => l_payroll_action_id,
                        p_action_context_type         => 'PA',
                        p_jurisdiction_code           => NULL,
                        p_tax_unit_id                 => l_tax_unit_id,
                        p_effective_date              => p_effective_date,
                        p_action_information1  => NULL,
                        p_action_information2  => NULL,
                        p_action_information3  => NULL,
                        p_action_information4  => old_l_registration_no1,
                        p_action_information5  => to_char(old_l_value1),
                        p_action_information6  => NULL,
                        p_action_information7  => NULL,
                        p_action_information8  => NULL,
                        p_action_information9  => NULL,
                        p_action_information10 => NULL,
                        p_action_information11 => NULL,
                        p_action_information12 => NULL,
                        p_action_information13 => NULL,
                        p_action_information14 => NULL,
                        p_action_information15 => NULL,
                        p_action_information16 => NULL,
                        p_action_information17 => NULL,
                        p_action_information18 => NULL,
                        p_action_information19 => NULL,
                        p_action_information20 => NULL,
                        p_action_information21 => NULL,
                        p_action_information22 => NULL,
                        p_action_information23 => NULL,
                        p_action_information24 => NULL,
                        p_action_information25 => NULL,
                        p_action_information26 => NULL,
                        p_action_information27 => NULL,
                        p_action_information28 => NULL,
                        p_action_information29 => NULL,
                        p_action_information30 => NULL
                        );

                    end if; -- c_get_emplr_reg_no%FOUND
                    close c_get_emplr_reg_no;
                     end if;

             if  old_l_registration_no2 is not null and old_l_value2 > 0 then
                           hr_utility.trace('in reg3 pay_action_information');
                     hr_utility.trace('in old_l_value2 = ' || to_char(old_l_value2));
                     hr_utility.trace('in old_l_reg2 = ' || old_l_registration_no2);
                        open c_get_emplr_reg_no(to_char(l_tax_unit_id),
                                                l_payroll_action_id
                                               , old_l_registration_no2
                                               ,p_effective_date);
                        fetch c_get_emplr_reg_no into lv_emplr_regno2,ln_emplr_regamt2;
                        if c_get_emplr_reg_no%FOUND then

                     hr_utility.trace('in ln_emplr_regamt2 = ' || to_char(ln_emplr_regamt2));

                           ln_emplr_regamt2 := ln_emplr_regamt2 + old_l_value2;

                           update pay_action_information
                           set action_information5 = to_char(ln_emplr_regamt2)
                           where action_context_id = l_payroll_action_id
                           and   tax_unit_id = l_tax_unit_id
                           and   effective_date = p_effective_date
                           and action_information_category = 'CAEOY PENSION PLAN INFO'
                           AND ACTION_INFORMATION4 = old_l_registration_no2;

                           hr_utility.trace('Updated pay_action_information');

                        else
                     hr_utility.trace('in reg3 insert pay_action_information');

                          -- insert a new record into pay_action_information

                        pay_action_information_api.create_action_information(
                        p_action_information_id => l_action_information_id_1,
                        p_object_version_number => l_object_version_number_1,
                        p_action_information_category => 'CAEOY PENSION PLAN INFO',
                        p_action_context_id           => l_payroll_action_id,
                        p_action_context_type         => 'PA',
                        p_jurisdiction_code           => NULL,
                        p_tax_unit_id                 => l_tax_unit_id,
                        p_effective_date              => p_effective_date,
                        p_action_information1  => NULL,
                        p_action_information2  => NULL,
                        p_action_information3  => NULL,
                        p_action_information4  => old_l_registration_no2,
                        p_action_information5  => to_char(old_l_value2),
                        p_action_information6  => NULL,
                        p_action_information7  => NULL,
                        p_action_information8  => NULL,
                        p_action_information9  => NULL,
                        p_action_information10 => NULL,
                        p_action_information11 => NULL,
                        p_action_information12 => NULL,
                        p_action_information13 => NULL,
                        p_action_information14 => NULL,
                        p_action_information15 => NULL,
                        p_action_information16 => NULL,
                        p_action_information17 => NULL,
                        p_action_information18 => NULL,
                        p_action_information19 => NULL,
                        p_action_information20 => NULL,
                        p_action_information21 => NULL,
                        p_action_information22 => NULL,
                        p_action_information23 => NULL,
                        p_action_information24 => NULL,
                        p_action_information25 => NULL,
                        p_action_information26 => NULL,
                        p_action_information27 => NULL,
                        p_action_information28 => NULL,
                        p_action_information29 => NULL,
                        p_action_information30 => NULL
                        );

                    end if; -- c_get_emplr_reg_no%FOUND
                    close c_get_emplr_reg_no;
                  end if;


                 /* Added else part to fix bug#2408456
                    if the registration number doesn't exist for the elements
                    that are fed to balance T4A_BOX34 then check the elements
                    that are fed to balance T4A_BOX32 and archive it */

        l_registration_no := NULL;
        old_l_registration_no := NULL;
        arch_l_registration_no := NULL;
        old_l_value := 0;
        old_l_registration_no1 := NULL;
        old_l_value1 := 0;
        old_l_registration_no2 := NULL;
        old_l_value2 := 0;
        arch_l_value := 0;
        l_value := 0;

             if  old_l_registration_no is null or
                 old_l_registration_no1 is null or
                 old_l_registration_no2 is null  then

                 l_registration_no := NULL;
                 old_l_registration_no := NULL; old_l_value := 0;
                 old_l_registration_no1 := NULL;
                 old_l_value1 := 0;
                 old_l_registration_no2 := NULL;
                 old_l_value2 := 0;
                 l_value := 0;
        arch_l_registration_no := NULL;
        arch_l_value := 0;
                 begin

                    open c_reg_balance_feed_info('T4A_BOX32');

                      loop
                        fetch c_reg_balance_feed_info into l_registration_no,
                              l_balance_name,l_element_type_id,
                              l_ele_classification_id;
                        exit when c_reg_balance_feed_info%NOTFOUND;

                        hr_utility.trace('checking for T4A_BOX32 ');
                        hr_utility.trace('p_assactid:'||to_char(p_assactid));
                        hr_utility.trace('l_asgid:'||to_char(l_asgid));
                        hr_utility.trace('l_registration_no:'||l_registration_no);
                        hr_utility.trace('l_balance_name:'||l_balance_name);
                        hr_utility.trace('l_element_type_id:'||to_char(l_element_type_id));

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


                        hr_utility.trace('l_value:'||to_char(l_value));
                        if l_value is null then
                           l_value := 0;
                        end if;

                        hr_utility.trace('before checking the new validation ');
                        hr_utility.trace('l_value :'||to_char(l_value));
                        hr_utility.trace('l_registration_no:'||l_registration_no);
                        hr_utility.trace('old_l_value :'||to_char(old_l_value));
                        hr_utility.trace('old_l_registration_no:'||old_l_registration_no);

                        /* Condition to check the amounts and determine the
                           registration number to archive Bug fix 2408456 */

                        if l_value > nvl(old_l_value,0) then

                            old_l_value := l_value;
                            old_l_registration_no := l_registration_no;
                elsif l_value > nvl(old_l_value1,0) then
                 old_l_value1 := l_value;
                 old_l_registration_no1 := l_registration_no;
                elsif l_value > nvl(old_l_value2,0) then
                 old_l_value2 := l_value;
                 old_l_registration_no2 := l_registration_no;

                end if;
                        /* End of Condition to check amounts Bug fix 2408456 */

         end loop;
                    close c_reg_balance_feed_info;

                    if old_l_value > old_l_value1 then
                           if old_l_value> old_l_value2 then
                              arch_l_registration_no := old_l_registration_no;
                               arch_l_value := old_l_value;
                           else
                              arch_l_registration_no := old_l_registration_no2;
                              arch_l_value := old_l_value2;
                           end if;
                   else
                     if old_l_value1>old_l_value2 then
                            arch_l_registration_no := old_l_registration_no1;
                            arch_l_value := old_l_value1;
                           else
                             arch_l_registration_no := old_l_registration_no2;
                            arch_l_value := old_l_value2;
                           end if;
                   end if;
             if  arch_l_registration_no is not null and arch_l_value > 0 then

               ff_archive_api.create_archive_item(
               --  p_validate      => 'TRUE'
                   p_archive_item_id => l_archive_item_id
                  ,p_user_entity_id => get_user_entity_id('CAEOY_T4A_EMPLOYEE_REGISTRATION_NO')
                  ,p_archive_value  => arch_l_registration_no
                  ,p_archive_type   => 'AAP'
                  ,p_action_id      => p_assactid
                  ,p_legislation_code => 'CA'
                  ,p_object_version_number  => l_object_version_number
                  ,p_some_warning           => l_some_warning
                  );
               end if;
                    if  old_l_registration_no is not null and old_l_value > 0 then


                        /* Bug fix#2696309, Employer level Pension Plan Register Number */

                        hr_utility.trace('Start of Employer Level PP Reg no ');
                     hr_utility.trace('in old_l_value = ' || to_char(old_l_value));
                     hr_utility.trace('in old_l_reg = ' || old_l_registration_no);
                        open c_get_emplr_reg_no(to_char(l_tax_unit_id),
                                                l_payroll_action_id
                                               ,old_l_registration_no
                                               ,p_effective_date);
                        fetch c_get_emplr_reg_no into lv_emplr_regno,ln_emplr_regamt;
                        if c_get_emplr_reg_no%FOUND then
                     hr_utility.trace('in ln_emplr_regamt = ' || to_char(ln_emplr_regamt));
                           ln_emplr_regamt := ln_emplr_regamt + old_l_value;

                           update pay_action_information
                           set action_information5 = to_char(ln_emplr_regamt)
                           where action_context_id = l_payroll_action_id
                           and tax_unit_id = l_tax_unit_id
                           and effective_date = p_effective_date
                           and action_information_category = 'CAEOY PENSION PLAN INFO'
                           AND ACTION_INFORMATION4 = old_l_registration_no;

                        else
                          -- insert a new record into pay_action_information

                        pay_action_information_api.create_action_information(
                        p_action_information_id => l_action_information_id_1,
                        p_object_version_number => l_object_version_number_1,
                        p_action_information_category => 'CAEOY PENSION PLAN INFO',
                        p_action_context_id    => l_payroll_action_id,
                        p_action_context_type  => 'PA',
                        p_jurisdiction_code    => NULL ,
                        p_tax_unit_id          => l_tax_unit_id,
                        p_effective_date       => p_effective_date,
                        p_assignment_id        => l_asgid,
                        p_action_information1  => NULL,
                        p_action_information2  => NULL,
                        p_action_information3  => NULL,
                        p_action_information4  => old_l_registration_no,
                        p_action_information5  => to_char(old_l_value),
                        p_action_information6  => NULL,
                        p_action_information7  => NULL,
                        p_action_information8  => NULL,
                        p_action_information9  => NULL,
                        p_action_information10 => NULL,
                        p_action_information11 => NULL,
                        p_action_information12 => NULL,
                        p_action_information13 => NULL,
                        p_action_information14 => NULL,
                        p_action_information15 => NULL,
                        p_action_information16 => NULL,
                        p_action_information17 => NULL,
                        p_action_information18 => NULL,
                        p_action_information19 => NULL,
                        p_action_information20 => NULL,
                        p_action_information21 => NULL,
                        p_action_information22 => NULL,
                        p_action_information23 => NULL,
                        p_action_information24 => NULL,
                        p_action_information25 => NULL,
                        p_action_information26 => NULL,
                        p_action_information27 => NULL,
                        p_action_information28 => NULL,
                        p_action_information29 => NULL,
                        p_action_information30 => NULL
                        );

                    end if; -- c_get_emplr_reg_no%FOUND
                    close c_get_emplr_reg_no;
                    end if;
                    if  old_l_registration_no1 is not null and old_l_value1 > 0 then


                        /* Bug fix#2696309, Employer level Pension Plan Register Number */

                        hr_utility.trace('Start of Employer Level PP Reg no ');
                     hr_utility.trace('in old_l_value1 = ' || to_char(old_l_value1));
                     hr_utility.trace('in old_l_reg1 = ' || old_l_registration_no1);

                        open c_get_emplr_reg_no(to_char(l_tax_unit_id),
                                                l_payroll_action_id
                                               ,old_l_registration_no1
                                               ,p_effective_date);
                        fetch c_get_emplr_reg_no into lv_emplr_regno1,ln_emplr_regamt1;
                        if c_get_emplr_reg_no%FOUND then
                     hr_utility.trace('in ln_emplr_regamt1 = ' || to_char(ln_emplr_regamt1));
                           ln_emplr_regamt1 := ln_emplr_regamt1 + old_l_value1;

                           update pay_action_information
                           set action_information5 = to_char(ln_emplr_regamt1)
                           where action_context_id = l_payroll_action_id
                           and tax_unit_id = l_tax_unit_id
                           and effective_date = p_effective_date
                           and action_information_category = 'CAEOY PENSION PLAN INFO'
                           AND ACTION_INFORMATION4 = old_l_registration_no1;

                        else
                          -- insert a new record into pay_action_information

                        pay_action_information_api.create_action_information(
                        p_action_information_id => l_action_information_id_1,
                        p_object_version_number => l_object_version_number_1,
                        p_action_information_category => 'CAEOY PENSION PLAN INFO',
                        p_action_context_id    => l_payroll_action_id,
                        p_action_context_type  => 'PA',
                        p_jurisdiction_code    => NULL ,
                        p_tax_unit_id          => l_tax_unit_id,
                        p_effective_date       => p_effective_date,
                        p_assignment_id        => l_asgid,
                        p_action_information1  => NULL,
                        p_action_information2  => NULL,
                        p_action_information3  => NULL,
                        p_action_information4  => old_l_registration_no1,
                        p_action_information5  => to_char(old_l_value1),
                        p_action_information6  => NULL,
                        p_action_information7  => NULL,
                        p_action_information8  => NULL,
                        p_action_information9  => NULL,
                        p_action_information10 => NULL,
                        p_action_information11 => NULL,
                        p_action_information12 => NULL,
                        p_action_information13 => NULL,
                        p_action_information14 => NULL,
                        p_action_information15 => NULL,
                        p_action_information16 => NULL,
                        p_action_information17 => NULL,
                        p_action_information18 => NULL,
                        p_action_information19 => NULL,
                        p_action_information20 => NULL,
                        p_action_information21 => NULL,
                        p_action_information22 => NULL,
                        p_action_information23 => NULL,
                        p_action_information24 => NULL,
                        p_action_information25 => NULL,
                        p_action_information26 => NULL,
                        p_action_information27 => NULL,
                        p_action_information28 => NULL,
                        p_action_information29 => NULL,
                        p_action_information30 => NULL
                        );

                    end if; -- c_get_emplr_reg_no%FOUND
                    close c_get_emplr_reg_no;

                    end if; /* for old_l_registration_no1 is not null derived
                               from T4A_BOX32 */

                    if  old_l_registration_no2 is not null and old_l_value2 > 0 then

                        /* Bug fix#2696309, Employer level Pension Plan Register Number */

                        hr_utility.trace('Start of Employer Level PP Reg no ');
                     hr_utility.trace('in old_l_value2 = ' || to_char(old_l_value2));
                     hr_utility.trace('in old_l_reg2 = ' || old_l_registration_no2);

                        open c_get_emplr_reg_no(to_char(l_tax_unit_id),
                                                l_payroll_action_id
                                               ,old_l_registration_no2
                                               ,p_effective_date);
                        fetch c_get_emplr_reg_no into lv_emplr_regno2,ln_emplr_regamt2;
                     hr_utility.trace('in ln_emplr_regamt2 = ' || to_char(ln_emplr_regamt2));
                        if c_get_emplr_reg_no%FOUND then
                           ln_emplr_regamt2 := ln_emplr_regamt2 + old_l_value2;

                           update pay_action_information
                           set action_information5 = to_char(ln_emplr_regamt2)
                           where action_context_id = l_payroll_action_id
                           and tax_unit_id = l_tax_unit_id
                           and effective_date = p_effective_date
                           and action_information_category = 'CAEOY PENSION PLAN INFO'
                           AND ACTION_INFORMATION4 = old_l_registration_no2;

                        else
                          -- insert a new record into pay_action_information

                        pay_action_information_api.create_action_information(
                        p_action_information_id => l_action_information_id_1,
                        p_object_version_number => l_object_version_number_1,
                        p_action_information_category => 'CAEOY PENSION PLAN INFO',
                        p_action_context_id    => l_payroll_action_id,
                        p_action_context_type  => 'PA',
                        p_jurisdiction_code    => NULL ,
                        p_tax_unit_id          => l_tax_unit_id,
                        p_effective_date       => p_effective_date,
                        p_assignment_id        => l_asgid,
                        p_action_information1  => NULL,
                        p_action_information2  => NULL,
                        p_action_information3  => NULL,
                        p_action_information4  => old_l_registration_no2,
                        p_action_information5  => to_char(old_l_value2),
                        p_action_information6  => NULL,
                        p_action_information7  => NULL,
                        p_action_information8  => NULL,
                        p_action_information9  => NULL,
                        p_action_information10 => NULL,
                        p_action_information11 => NULL,
                        p_action_information12 => NULL,
                        p_action_information13 => NULL,
                        p_action_information14 => NULL,
                        p_action_information15 => NULL,
                        p_action_information16 => NULL,
                        p_action_information17 => NULL,
                        p_action_information18 => NULL,
                        p_action_information19 => NULL,
                        p_action_information20 => NULL,
                        p_action_information21 => NULL,
                        p_action_information22 => NULL,
                        p_action_information23 => NULL,
                        p_action_information24 => NULL,
                        p_action_information25 => NULL,
                        p_action_information26 => NULL,
                        p_action_information27 => NULL,
                        p_action_information28 => NULL,
                        p_action_information29 => NULL,
                        p_action_information30 => NULL
                        );

                    end if; -- c_get_emplr_reg_no%FOUND
                    close c_get_emplr_reg_no;

                    end if; /* for old_l_registration_no2 is not null derived
                               from T4A_BOX32 */


                end;

                /* End of bug fix for bug      #2408456 */
             end if; /* for old_l_registration_no is not null derived
                      from T4A_BOX34 */
           end;
           /* end registration number archiving */
  else
       hr_utility.trace('result is 0');

  end if; /* end if for result <> 0 condition */

/* Need to add the T4A Nonbox Footnote archiving code to fix bug#2175045 */
begin

   l_total_mesg_amt := 0;
   l_mesg_amt       := 0;

   open cur_non_box_mesg(p_assactid, p_effective_date);
   loop
      fetch cur_non_box_mesg into l_messages,
                                  l_mesg_amt,
                                  ln_tax_unit_id,
                                  ld_eff_date,
                                  ln_assignment_action_id;

      if cur_non_box_mesg%notfound then
         exit;
      end if;

      hr_utility.trace('l_messages - '||l_messages);
      hr_utility.trace('l_mesg_amt - '||to_char(l_mesg_amt));

     /* If the same Non Box footnote is processed more than
        once during the year,  then the sum of the associated
        amounts is archived */

      if ((l_messages <> l_prev_messages) and
          (l_prev_messages is not null)) then

             hr_utility.trace('l_prev_messages - '||l_prev_messages);

             if l_total_mesg_amt <> 0 then

                 pay_action_information_api.create_action_information(
                 p_action_information_id => l_action_information_id_1,
                 p_object_version_number => l_object_version_number_1,
                 p_action_information_category => 'CA FOOTNOTES',
                 p_action_context_id           => p_assactid,
                 p_action_context_type         => 'AAP',
                 p_jurisdiction_code           => NULL,
                 p_tax_unit_id                => ln_prev_tax_unit_id,
                 p_effective_date             => ld_prev_eff_date,
                 p_assignment_id              => l_asgid,
                 p_action_information1  => NULL,
                 p_action_information2  => NULL,
                 p_action_information3  => NULL,
                 p_action_information4  => l_prev_messages,
                 p_action_information5  => l_total_mesg_amt,
                 p_action_information6  => 'T4A',
                 p_action_information7  => NULL,
                 p_action_information8  => NULL,
                 p_action_information9  => NULL,
                 p_action_information10 => NULL,
                 p_action_information11 => NULL,
                 p_action_information12 => NULL,
                 p_action_information13 => NULL,
                 p_action_information14 => NULL,
                 p_action_information15 => NULL,
                 p_action_information16 => NULL,
                 p_action_information17 => NULL,
                 p_action_information18 => NULL,
                 p_action_information19 => NULL,
                 p_action_information20 => NULL,
                 p_action_information21 => NULL,
                 p_action_information22 => NULL,
                 p_action_information23 => NULL,
                 p_action_information24 => NULL,
                 p_action_information25 => NULL,
                 p_action_information26 => NULL,
                 p_action_information27 => NULL,
                 p_action_information28 => NULL,
                 p_action_information29 => NULL,
                 p_action_information30 => NULL
                 );

                 if l_box38_footnote_code = '00' then
                    l_box38_footnote_code := l_prev_messages;
                 else
                    if l_box38_footnote_code <> '13' then
                       l_box38_footnote_code := '13';
                    end if;
                 end if;

                 if l_total_mesg_amt < 0 then
                     l_negative_balance_exists := 'Y';
                 end if;

             end if;

             l_total_mesg_amt := l_mesg_amt;
      else
             l_total_mesg_amt := l_total_mesg_amt + l_mesg_amt;
      end if;

      hr_utility.trace('l_total_mesg_amt - '||to_char(l_total_mesg_amt));

      l_prev_messages     := l_messages;
      ln_prev_tax_unit_id := ln_tax_unit_id;
      ld_prev_eff_date    := ld_eff_date;

   end loop;

   close cur_non_box_mesg;

   if (l_prev_messages is not null) then

        hr_utility.trace('l_prev_messages - '||l_prev_messages);
        hr_utility.trace('l_total_mesg_amt - '||to_char(l_total_mesg_amt));

        if l_total_mesg_amt <> 0 then

            pay_action_information_api.create_action_information(
            p_action_information_id => l_action_information_id_1,
            p_object_version_number => l_object_version_number_1,
            p_action_information_category => 'CA FOOTNOTES',
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_jurisdiction_code           => NULL,
            p_tax_unit_id                => ln_prev_tax_unit_id,
            p_effective_date             => ld_prev_eff_date,
            p_assignment_id              => l_asgid,
            p_action_information1  => NULL,
            p_action_information2  => NULL,
            p_action_information3  => NULL,
            p_action_information4  => l_prev_messages,
            p_action_information5  => l_total_mesg_amt,
            p_action_information6  => 'T4A',
            p_action_information7  => NULL,
            p_action_information8  => NULL,
            p_action_information9  => NULL,
            p_action_information10 => NULL,
            p_action_information11 => NULL,
            p_action_information12 => NULL,
            p_action_information13 => NULL,
            p_action_information14 => NULL,
            p_action_information15 => NULL,
            p_action_information16 => NULL,
            p_action_information17 => NULL,
            p_action_information18 => NULL,
            p_action_information19 => NULL,
            p_action_information20 => NULL,
            p_action_information21 => NULL,
            p_action_information22 => NULL,
            p_action_information23 => NULL,
            p_action_information24 => NULL,
            p_action_information25 => NULL,
            p_action_information26 => NULL,
            p_action_information27 => NULL,
            p_action_information28 => NULL,
            p_action_information29 => NULL,
            p_action_information30 => NULL
            );

            if l_box38_footnote_code = '00' then
               l_box38_footnote_code := l_prev_messages;
            else
               if l_box38_footnote_code <> '13' then
                  l_box38_footnote_code := '13';
               end if;
            end if;

            if l_total_mesg_amt < 0 then
               l_negative_balance_exists := 'Y';
            end if;

        end if;

   end if;

end; /* End of T4A Nonbox Footnote Archive end of bugfix#2175045 */

/* Archive the negative balance flag */
     ff_archive_api.create_archive_item(
         p_archive_item_id => l_archive_item_id
        ,p_user_entity_id  => get_user_entity_id('CAEOY_T4A_NEGATIVE_BALANCE_EXISTS')
        ,p_archive_value   => l_negative_balance_exists
        ,p_archive_type           => 'AAP'
        ,p_action_id              => p_assactid
        ,p_legislation_code       => 'CA'
        ,p_object_version_number  => l_object_version_number
        ,p_context_name1          => 'TAX_UNIT_ID'
        ,p_context1               => l_tax_unit_id
        ,p_some_warning           => l_some_warning
        );

/* T4A Box 38 Footnote code archiving */
             ff_archive_api.create_archive_item(
               p_archive_item_id => l_archive_item_id
              ,p_user_entity_id => get_user_entity_id('CAEOY_T4A_FOOTNOTE_CODE')
              ,p_archive_value  => l_box38_footnote_code
              ,p_archive_type   => 'AAP'
              ,p_action_id      => p_assactid
              ,p_legislation_code => 'CA'
              ,p_object_version_number  => l_object_version_number
              ,p_context_name1          => 'TAX_UNIT_ID'
              ,p_context1               => l_tax_unit_id
              ,p_some_warning           => l_some_warning
              );
/* End of t4a box 38 archive */

begin
l_counter := 0;
       hr_utility.trace('selecting people');

select PEOPLE.person_id,
       PEOPLE.first_name,
       PEOPLE.last_name,
       PEOPLE.employee_number,
       PEOPLE.WORK_TELEPHONE,
       replace(PEOPLE.national_identifier,' '),
       PEOPLE.middle_names, /* Bug:1474421 Changed pre_name_adjunct to middle_names */
       ASSIGN.organization_id,
       ASSIGN.location_id
 into l_person_id,
      l_first_name,
      l_last_name,
      l_employee_number,
      l_work_telephone,
      l_national_identifier,
      l_middle_names, /* changed variable l_pre_name_adjunct to l_middle_names */
      l_organization_id,
      l_location_id
 from
        per_all_assignments_f  ASSIGN
,       per_all_people_f       PEOPLE
,       per_person_types       PTYPE
,       fnd_sessions           SES
where   l_date_earned BETWEEN ASSIGN.effective_start_date
                                           AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id = l_asgid
and	PEOPLE.person_id     = ASSIGN.person_id
and     l_date_earned BETWEEN PEOPLE.effective_start_date
                                           AND PEOPLE.effective_end_date
and	PTYPE.person_type_id = PEOPLE.person_type_id
and     SES.session_id       = USERENV('SESSIONID')   ;
       exception
   when no_data_found then
      l_first_name := null;
      l_last_name := null;
      l_employee_number := null;
      l_work_telephone := null;
      l_national_identifier := null;
      l_middle_names := null; /* changed variable l_pre_name_adjunct
                                     to l_middle_names */
      hr_utility.raise_error;
    end;

begin
       select PHONE.phone_number
       into l_employee_phone_no
       from     per_phones             PHONE ,
       fnd_sessions           SES
       where     PHONE.parent_id (+) = l_person_id
       and     PHONE.parent_table (+)= 'PER_ALL_PEOPLE_F'
       and     PHONE.phone_type (+)= 'W1'
       and     l_date_earned BETWEEN NVL(PHONE.date_from,SES.effective_date)
       AND     NVL(PHONE.date_to,SES.effective_date)
       and     SES.session_id       = USERENV('SESSIONID')   ;
   exception
   when no_data_found then
      l_employee_phone_no := l_work_telephone;
    end;

       hr_utility.trace('selected people');
         /* Initialise l_count */
          l_count := 0;

/* hr_utility.trace_on('Y','ORACLE'); */

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
 l_user_entity_value_tab(l_counter) := l_middle_names;  /* changed variable
                                       l_pre_name_adjunct to l_middle_names */

 l_counter := l_counter + 1;
 l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_SIN';
 l_user_entity_value_tab(l_counter) := l_national_identifier;

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

 begin
       hr_utility.trace('selecting address');

       select addr.address_line1,
              addr.address_line2,
              addr.address_line3,
              addr.town_or_city,
              decode(addr.country,'CA',addr.region_1,'US',addr.region_2,' '),
              replace(addr.postal_code,' '),
              addr.telephone_number_1,
              country.territory_code
       into   l_address_line1,
              l_address_line2,
              l_address_line3,
              l_town_or_city,
              l_province_code,
              l_postal_code,
              l_telephone_number,
              l_country_code
       from per_addresses      addr,
            fnd_territories_vl country
       where addr.person_id     = l_person_id
       and   addr.primary_flag  = 'Y'
       and   p_effective_date
                   between nvl(addr.date_from,p_effective_date)
                   and     nvl(addr.date_to, p_effective_date)
       and   country.territory_code = addr.country;
       exception
       when no_data_found then
       l_address_line1 := null;
       l_address_line2 := null;
       l_address_line3 := null;
       l_address_line4 := null;
       l_town_or_city := null;
       l_province_code := null;
       l_postal_code := null;
       l_telephone_number := null;
       l_country_code := null;
 end;

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

 -- Federal YE Amendment Pre-Process Validation (T4A Amendment Archiver code)

   Begin

     hr_utility.trace('Started Federal YE Amendment PP Validation ');

     select effective_date,
            report_type
     into   ld_fapp_effective_date,
            lv_fapp_report_type
     from pay_payroll_actions
     where payroll_action_id = l_payroll_action_id;

     hr_utility.trace('Fed Amend Pre-Process Pactid :'||
                        to_char(l_payroll_action_id));
     hr_utility.trace('lv_fapp_report_type :'||lv_fapp_report_type);

     if lv_fapp_report_type = 'CAEOY_T4A_AMEND_PP' then

        begin

          open c_get_fapp_locked_action_id(p_assactid);
          fetch c_get_fapp_locked_action_id
          into ln_fapp_locked_action_id;

          close c_get_fapp_locked_action_id;

          hr_utility.trace('T4A Amend PP Action ID : '||to_char(p_assactid));
          hr_utility.trace('ln_fapp_locked_action_id :'||
                              to_char(ln_fapp_locked_action_id));

          open c_get_fapp_lkd_actid_rtype(ln_fapp_locked_action_id);
          fetch c_get_fapp_lkd_actid_rtype
          into lv_fapp_locked_actid_reptype;

          close c_get_fapp_lkd_actid_rtype;

          hr_utility.trace('lv_fapp_locked_actid_reptype :'||
                                  lv_fapp_locked_actid_reptype);

          lv_fapp_flag := compare_archive_data(p_assactid,
                                               ln_fapp_locked_action_id);

          if lv_fapp_flag = 'Y' then

             hr_utility.trace('Archiving T4A Amendment Flag is :  ' || lv_fapp_flag);

             ff_archive_api.create_archive_item(
             p_archive_item_id => l_archive_item_id
            ,p_user_entity_id => get_user_entity_id('CAEOY_T4A_AMENDMENT_FLAG')
            ,p_archive_value          => lv_fapp_flag
            ,p_archive_type           => 'AAP'
            ,p_action_id              => p_assactid
            ,p_legislation_code       => 'CA'
            ,p_object_version_number  => l_object_version_number
            ,p_context_name1          => 'TAX_UNIT_ID'
            ,p_context1               => l_tax_unit_id
            ,p_some_warning           => l_some_warning
            );

          end if;

        end; -- report_type validation

      end if; -- report type validation for FAPP
      hr_utility.trace('End of Federal YE Amendment PP Validation');

     exception when no_data_found then
       hr_utility.trace('Report type not found for given Payroll_action ');
       null;
   end;

-- End of Federal YE Amendment Pre-Process Validation

  end eoy_archive_data;


  /* Name      : eoy_range_cursor
     Purpose   : This returns the select statement that is used to created the
                 range rows for the Year End Pre-Process.
     Arguments :
     Notes     :
  */

  procedure eoy_range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  l_legislative_parameters  varchar2(240);
  l_eoy_tax_unit_id         number;
  l_transmitter_gre_id      number;
  l_archive                 boolean:= FALSE;
  l_business_group          number;
  l_year_start              date;
  l_year_end                date;

  begin

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

     l_eoy_tax_unit_id := pycadar_pkg.get_parameter('TRANSFER_GRE',l_legislative_parameters);

     select org_information11
     into l_transmitter_gre_id
     from hr_organization_information
     where  organization_id = l_eoy_tax_unit_id
     and    org_information_context = 'Canada Employer Identification'
     and    org_information5        in ('T4A/RL1','T4A/RL2');

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

        -- now the archiver has provision for archiving payroll_action_level data .
        -- So make use of that

            hr_utility.trace('eoy_range_cursor archiving employer data');

            eoy_archive_gre_data(pactid,
                                 l_eoy_tax_unit_id,
                                 l_transmitter_gre_id);
        end if;

     end if;

  end eoy_range_cursor;

end pay_ca_t4aeoy_archive;

/
