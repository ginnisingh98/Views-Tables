--------------------------------------------------------
--  DDL for Package Body PAY_CA_EOY_RL1_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EOY_RL1_ARCHIVE" as
/* $Header: pycarlar.pkb 120.17.12010000.15 2010/02/23 19:49:22 sneelapa ship $ */

/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description : Package and procedure to build sql for payroll processes.

   Change List

   Date         Name        Vers   Bug No   Description

   14-JAN-2000  M.Mukherjee 110.0           Created
   18-JAN-2000  M.Mukherjee 110.1           Taken out trace_on and archiving
                                            QBN at PA level
   18-JAN-2000  M.Mukherjee 110.2           Archiving taxation year
   21-JAN-2000  M.Mukherjee 110.3           Archiving BOXO balances
   27-JAN-2000  M.Mukherjee 110.4           Put the check for not to take
                                            put T4A earnings in Gross Earnings
                                            which is Box A
   31-JAN-2000  M.Mukherjee 110.4           If condition for T4A/Gross earning
                                            combinations are written differently
   31-JAN-2000  M.Mukherjee 110.5           Corrected condition so that it does
                                            not archive employees who does not
                                            have payroll runs for that QC_ID
   02-FEB-2000  M.Mukherjee 110.6           Taking Quebec ID no 16 chars
                                            every where and stopped archiving
                                            non quebec employees
   16-MAY-2000  M.Mukherjee 115.3         Changed the report_type to RL1
   10-JUL-2000  V.PANDYA    115.4       Added Existance of record in
					PAY_ACTION_CONTEXT for Juridiction Code
 					for QC in Range Cursor and Action
					Creation query so it takes only those
					employees who have been paid in Quebec.
   18-AUG-2000  M.Mukherjee 115.5       Added RL1_SLIP_NUMBER archiving
   31-AUG-2000  M.Mukherjee 115.6,115.7 Added footnote,CPP, BOXO  archiving
   18-SEP-2000  V.PANDYA    115.8       Remove assignment_id condition to get
                                        asg.actid for more asgid.
   20-SEP-2000  mmukherj    115.11     Corrected footnote archiving logic
   20-SEP-2000  V.PANDYA    115.12     Corrected footnote archiving logic
   18-OCT-2000  M.Mukherjee 115.13-15  Corrected footnote archiving logic and
                                       slip number archiving logic.
   20-OCT-2000  M.Mukherjee 115.16-17  Corrected slip number archiving logic.
   30-OCT-2000  M.Mukherjee 115.18     Corrected slip number archiving logic
                                       instead of global variable, a sequence
                                       will be used , because global variable
                                       is not effective across diff sessions
                                       so it will not work in a multi threaded
                                       environment.
   30-OCT-2000  M.Mukherjee 115.19     balance_feeds are being checked for
                                       that business group id.Bug1482190
   06-DEC-2000  M.Mukherjee 115.20     added to_char(hoi.organization_id) in
                                       c_eoy_qbin cursor, it was returning
                                       invalid_number.
   08-DEC-2000  M.Mukherjee 115.21     added business group in the select
                                       queries, otherwise it will fetch
                                       duplicate data.
   08-DEC-2000  M.Mukherjee 115.22     changed comments double dash to
                                       slash/star,
                                       otherwise adchkdrv will fail
   08-DEC-2000  VPandya     115.23,26  Trying to solve PI on driver
                                       says to replace dashes
   12-DEC-2000  MMukherjee  115.27     Added parameter l_has_been_paid to
                                       avoid archiving 0 salary records.
   13-DEC-2000  MMukherjee  115.28     Stopped assignment action creation
                                       if the employee has not been paid
                                       anything in that year, even though
                                       there is payroll run.
   29-DEC-2000 P.Ganguly    115.29     Added a check if Taxable Benefits
                                       for Federal is present then subtract
				       it from the gross earnings.
   08-NOV-2001 VPandya      115.30     Added QPP Basic Exemption, QPP Exempt
                                       Earnings. Archiving RL1 NonBox Footnotes
                                       in pay_action_information table.
   10-NOV-2001 vpandya      115.31     Added set veify off at top as per GSCC.
   12-NOV-2001 vpandya      115.32     Added dbdrv line.
   27-DEC-2001 vpandya      115.33     Archiving new DBI
                                       CAEOY_EMPLOYEE_DATE_OF_BIRTH
   08-Jan-2002 vpandya      115.34     Archiving new DBI
                                       CAEOY_EMPLOYEE_HIRE_DATE
   02-Jul-2002 vpandya      115.36     Commented out below clause while getting
                                       max-assignment action id query
                                       AND pac1.assignment_id  = l_asgid
   01-Aug-2002 vpandya      115.37     Indention of archive_data and not include
                                       status indian(BOXR) in to Gross Earnings
                                       (BOXA).
   10-Aug-2002 mmukherj     115.38     Bugfix for #2458533. The cursor
                                       employer_info has been changed so that
                                       it checks the business_group_id.
   16-Aug-2002 vpandya      115.39     Bugfix for 2192914:archiving termination
                                       date.
                                       Archiving transmitter name instead of
                                       transmitter org id in DBI
                                       CAEOY_RL1_TRANSMITTER_NAME(ref.2192914)
   21-Aug-2002 vpandya      115.40     Bugfix for 2449408:archiving DBI
                                       CAEOY_RL1_ACCOUNTING_CONTACT_LANGUAGE
                                       Changed cursor employer_info, added
                                       column org_information19 for Archiving
                                       Accounting Resource Language, also given
                                       alias to all information columns.
   06-Oct-2002 vpandya      115.41     Changed archiver to archive Box-O
                                       footnote.
   08-Oct-2002 vpandya      115.43     Initializing variables l_footnote_amount
                                       and l_footnote_amount_ue to avoid
                                       duplicate archiving of footnotes.
   22-Oct-2002 vpandya      115.44     Bug 2681250: changed cursor c_get_addr
                                       of eoy_archive_data. If country is CA
                                       take data from region_1 to get province
                                       code and if it is US take data from
                                       region_2 to get state code.
   02-DEC-2002  vpandya     115.45     Added nocopy with out parameter
                                       as per GSCC.
   06-DEC-2002  vpandya     115.46     Bug 2698320,RL1 BOX-O codes RA to RZ
                                       should be excluded from BOX A on the RL1.
                                       Done using ln_boxo_exclude_from_boxa.
   11-DEC-2002  vpandya     115.47     Bug 2698320,not excluding Box-O amount of
                                       T4A/RL1 GRE from Box-A. Put this cond.
                                       getting balance in ln_balance_value first
                                       and summing up after for the same balance
                                       for different GREs.
   27-AUG-2003 ssouresr     115.49     If the balance 'RL1 No Gross Earnings' is
                                       non zero then archiving takes place even
                                       if Gross Earnings is zero.
                                       Also the balance 'RL1 Non Taxable Earnings'
                                       is deducted from Gross Earnings.
   18-Sep-2003  vpandya     115.50     Archiving dates in canonical format
                                       (YYYY/MM/DD HH:MI:SS) using
                                       fnd_date.date_to_canonical_to_date
                                       instead of using to_char with default
                                       format to fix gscc date conversion error.
   21-OCT-2003 ssouresr     115.51     Added RL1 Amendment Archiving logic
                                       in eoy_archive_data procedure. Also
                                       added new local function
                                       compare_archive_data used for RL1
                                       Amendment Archiver.
                                       The organization_id of the Prov Reporting
                                       Est will now be used instead of the QIN
  04-NOV-2003 ssouresr      115.52     Converted the pre printed form number
                                       select to a cursor as more than one
                                       record can be returned
  10-NOV-2003 ssouresr      115.53     Archiving pre printed form number both
                                       for RL1 and RL1 Amendment. This will
                                       ensure that the function
                                       compare_archive_data compares the
                                       correct data.
  12-NOV-2003 ssouresr      115.54     Modified the function
                                       compare_archive_data so that if the
                                       number of archived items to be compared
                                       is different then the amendment flag is
                                       set to Y without checking all the
                                       individual data records.
  21-FEB-2004 pganguly     115.55      Fixed bug# 3459723. Changed the cursor
                                       c_get_asg_id so that it picks
                                       assignment of type 'E' only.
  02-APR-2004 ssattini     115.56      11510 Changes to fix bug#3356533.
                                       Added new cursor c_get_max_asg_act_id
                                       in action_creation procedure. Modified
                                       cursor c_all_gres_for_person and added
                                       two new cursors c_get_max_asgactid_jd,
                                       c_get_max_asgactid in eoy_archive_data
                                       procedure.
  23-APR-2004 ssouresr     115.57      Modified the cursor cur_non_box_mesg to
                                       stop returning duplicate nonbox footnotes
  06-JUN-2004 ssattini     115.60      Modified the cursors
                                       c_get_max_asg_act_id,
                                       c_get_max_asgactid_jd and
                                       c_get_max_asgactid to get max asgact_id
                                       based on person_id. Bug fix bug#3638928.
  05-AUG-2004 ssouresr     115.61      Footnote codes for BoxQ can now be
                                       archived Also added check to make sure
                                       an appropriate error message is written
                                       to the log if no transmitter has been
                                       specified for the PRE. Bug#3353450.
  05-AUG-2004 ssattini     115.62      Modified the cursor cur_non_box_mesg
                                       to archive the balance adjustments
                                       for Non-Box footnotes. Fix bug#3641353.
  10-AUG-2004 ssouresr     115.63      Added the negative balance flag bug#3311402
                                       Also modified the non box footnote logic
                                       so that the amounts for identical footnote
                                       codes are summed up bug#3641308
  01-SEP-2004 ssouresr     115.64      BoxO can now have a negative balance
                                       Bug 3863016, previously negative values
                                       for this box were being ignored
  02-SEP-2004 ssouresr     115.65      Changed to use the function get_parameter
                                       to retrieve PRE_ORGANIZATION_ID
  04-OCT-2004 ssouresr     115.66      The negative balance flag is archived as Y
                                       when either a box or nonbox footnote is negative
  05-NOV-2004 ssouresr     115.67      RL1 No Gross Earnings needs to be retrieved
                                       across GREs
  08-NOV-2004 ssouresr     115.68      All footnotes were reviewed.
                                       BOXL and BOXO RW do not require any footnotes.
                                       BOXO RX and BOX RY are not valid anymore. Also
                                       BOXR has been changed to only have footnote
                                       code 14 (Income from an office or employment)
  17-NOV-2004 ssouresr     115.70      BoxO Code is now archived correctly
  18-NOV-2004 ssouresr     115.71      Added BOXO_RR to list of balances to archive
  19-NOV-2004 ssouresr     115.72      Footnotes for Gross Earnings(BOXA) are now archived
                                       and archiving of BOXO_RZ has been removed
  28-NOV-2004 ssouresr     115.73      Modified the cursor c_footnote_info to only return
                                       RL1 footnotes, was previously returning RL2 footnotes
                                       as well.
  28-NOV-2004 ssouresr     115.74      Added date range to the latest assignment action cursor
  29-NOV-2004 ssouresr     115.75      RL1 footnotes should be archived with Jurisdiction QC
  30-NOV-2004 ssouresr     115.76      Archiving CAEOY_QPP_REDUCED_SUBJECT_PER_JD_YTD for BoxG
  02-FEB-2005 ssouresr     115.77      NonBox Footnotes with a value of 0 are not archived
  04-MAR-2005 ssouresr     115.78      The archiver uses a new NonBox Footnote Element which
                                       has a Jurisdiction input value from the beginning of 2006
  26-APR-2005 ssouresr     115.79      The archiver will now recognize amendments made
                                       only to non box footnotes
  05-AUG-2005 saurgupt     115.80      Bug 4517693: Added Address_line3 for RL1 archiver.
  08-AUG-2005 mmukherj     115.81          The procedure eoy_archinit has been
                                            modified to set the minimum chunk
                                            no, which is required to re archive
                                            the data while retrying the Archiver
                                            in the payroll action level.
                                            Bugfix: #4525642
  31-AUG-2005 ssouresr     115.82      New RL1 Nonbox footnote for Taxable Benefits without pay
  27-SEP-2005 ssouresr     115.83      Corrected footnote condition in the function
                                       compare_archive_data
  10-NOV-2005 ssouresr     115.84      Added Footnote for BOXO RN
  07-FEB-2006 ssouresr     115.85      Modified range cursor and main action creation
                                       query to remove the table hr_soft_coding_keyflex
  13-Apr-2006 ssmukher     115.86      Modified the sqlstr statement in eoy_range_cursor
                                       procedure for Bug #5120627 fix
  07-Aug-2006 ydevi        115.87 5096509 Archiver archives two PPIP EE Withheld
                                          and PPIP EE Taxable into database itens
					                                CAEOY_PPIP_EE_WITHHELD_PER_JD_YTD
					                                and CAEOY_PPIP_EE_TAXABLE_PER_JD_YTD
					                                respectively
  18-AUG-2006 meshah       115.88 5202869 For performance reason changed the
                                          query to remove per_people_f and
                                          also disabled some indexes. With this
                                          change the cost of the query
                                          increases however now the path taken
                                          is now more correct. Cursor
                                          c_eoy_qbin has been changed.
  28-AUG-2006  meshah      115.89 5495704 the way indexes were disabled has
                                          been changed from using +0 to ||
  16-Nov-2006  ydevi       115.90 5159150 archiving RL1_BOXV and RL1_BOXW
                                          into db item CAEOY_RL1_BOXV_PER_JD_YTD
					                                and CAEOY_RL1_BOXW_PER_JD_YTD
  21-Dec-2006  ssmukher    115.91 5706335 Archiving BoxI value into DBI
                                          CAEOY_PPIP_REDUCED_SUBJECT_PER_JD_YTD
  05-Feb-2007  meshah      115.92 5768390 Removed the if condition that would
                                          not populate boxA when the GRE type
                                          is T4A/RL1
  21-Aug-2007  amigarg     115.93 5558604 Added date track and enabled flag
  					                              condtion in c_footnote_info
  21-Sep-2007  amigarg     115.95 6440125 added date track condition in employee
					                                archiving
  10-Jan-2008  sapalani    115.96 6525899 Added check to not to archive the
					                                RL1_BOXO_AMOUNT_RW balance from 2007
  13-Nov-2008  sapalani    115.97 7555410 Added check to not to archive the
					                                RL1_BOXO_AMOUNT_RF balance from 2008.
                                          Added code to archive balance
                                          RL1_BOXO_AMOUNT_RX starting from 2008.
  25-Nov-2008  sapalani    115.98 7555410 Modified cursor cur_non_box_mesg to
                                          pick only active footnotes.
  25-Mar-2009  sapalani	  115.100 8366352 Added new cursor c_non_box_lookup to
                                          fetch and archive only active non box
                                          footnotes. Removed this logic from
                                          cursor cur_non_box_mesg.
  10-Apr-2009  sapalani   115.101 6768167 Added function gen_rl1_pdf_seq to
                                          generate sequence number for RL1 PDF.
                                          The generated sequence numeber is
                                          archived in eoy_archive_data.
  08-May-2009  sapalani   115.102 8500723 Added function getnext_seq_num to
                                          calculate check digit for PDF sequence.
                                          In function gen_rl1_pdf_seq added call
                                          to ff_archive_api.create_archive_item.
                                          This archives CAEOY_RL1_PDF_SEQ_NUMBER
                                          when PDF is run for a period and
                                          archive item doesn't exist in that
                                          period.
  17-Aug-2009 sapalani    115.103 8732218 In function gen_rl1_pdf_seq, replaced
                                          call to ff_archive_api.update_archive
                                          _item with direct update statement.
  09-Sep-2009 sapalani    115.104 6853279 Added order by clause to cursor
                                          cur_non_box_mesg.
  24-Nov-2009 sneelapa    115.105 9135372 Modified eoy_archive_data procedure to
                                          archive data for BOX O new codes.
  07-Dec-2009 sneelapa    115.106 9177694 Modified IF Condition to END of
                                          c_non_box_lookup CURSOR LOOP.
  18-Dec-2009 aneghosh    115.107 9215185 Modified cursor c_get_emp_rl1box_data
                                          to ignore 'CAEOY_RL1_PDF_SEQ_NUMBER'
                                          while comparing the data across two
                                          archivers to set 'CAEOY_RL1_AMENDMENT_FLAG'.
  22-Feb-2010 sneelapa    115.109 9184985 Obsoleted 115.108 version, as issue was found
                                          during QA testing.  Modified current package
                                          with 115.107 as base.
                                          Modified eoy_archive_data procedure.
                                          Modified cursor cur_non_box_mesg
                                          Added run_paa.assignment_id = arch_paa.assignment_id
                                          condition for improving performance.
  22-Feb-2010 sneelapa    115.110 9184985 Modified eoy_archive_data procedure.
                                          Modified cursor cur_non_box_mesg
                                          Added cp_start_date parameter and modified WHERE
                                          conditions to use this date and avoid TO_CHAR function.
                                          TO_CHAR function was hindering the performance.
 */


   sqwl_range varchar2(4000);
   eoy_gre_range varchar2(4000);
   eoy_all_qbin varchar2(4000);


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
       and  Ue.creator_type         = 'B';

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
  Purpose   : The dates are dependent on the report being run
              For T4 it is year end dates.

  Arguments :
  Notes     :
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

   if    p_report_type = 'RL1' then

     /* Year End Pre-process is a yearly process where the identifier
        indicates the year eg. 1998. The expected values for the example
        should be
           p_period_end        31-DEC-1998
           p_quarter_start     01-OCT-1998
           p_quarter_end       31-DEC-1998
           p_year_start        01-JAN-1998
           p_year_end          31-DEC-1998
     */

     p_period_end    := add_months(trunc(p_effective_date, 'Y'),12) - 1;
     p_quarter_start := trunc(p_period_end, 'Q');
     p_quarter_end   := p_period_end;

   /* For EOY */

   end if;

   p_year_start := trunc(p_effective_date, 'Y');
   p_year_end   := add_months(trunc(p_effective_date, 'Y'),12) - 1;

 end get_dates;


  /* Name    : get_selection_information
  Purpose    : Returns information used in the selection of people to be reported on.
  Arguments  :

  The following values are returned :

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
  p_group_by_medicare    in out nocopy boolean,
  p_tax_unit_context     in out nocopy boolean,
  p_jurisdiction_context in out nocopy boolean
 ) is

 begin

   /* Depending on the report being processed, derive all the information
      required to be able to select the people to report on. */

   if    p_report_type = 'RL1'  then

     /* Default settings for Year End Preprocess. */

     hr_utility.trace('in getting selection information ');
     p_period_start         := p_year_start;
     p_period_end           := p_year_end;
/*     p_defined_balance_id   := bal_db_item('GROSS_EARNINGS_PER_GRE_YTD'); */
     p_defined_balance_id   := 0;
     p_group_by_gre         := FALSE;
     p_group_by_medicare    := FALSE;
     p_tax_unit_context     := FALSE;
     p_jurisdiction_context := FALSE;

   /* For EOY  end */

   /* An invalid report type has been passed so fail. */

   else
     hr_utility.trace('in error of getting selection information ');

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


  /*
     Name      : get_user_entity_id
     Purpose   : This gets the user_entity_id for a specific database item name.
     Arguments : p_dbi_name > database item name.
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
                                     || p_dbi_name);
    raise hr_utility.hr_error;

  end get_user_entity_id;


  /*
     Name      : get_footnote_user_entity_id
     Purpose   : This gets the user_entity_id for a specific database item name.
                 and it does not raise error if the the user entity is not found
     Arguments : p_dbi_name > database item name.
     Notes     :
  */

  function get_footnote_user_entity_id (p_dbi_name in varchar2)
                              return number is
  l_user_entity_id  number;

  begin

    if p_dbi_name is not null then
       begin
         select user_entity_id
         into l_user_entity_id
         from ff_database_items
         where user_name = p_dbi_name;

         return l_user_entity_id;

         exception
         when others then
         hr_utility.trace('skipping the record because no dbi of name:'
                                       || p_dbi_name);
         return 0;
       end;
    end if;

    return 0;

  end get_footnote_user_entity_id;

  /*
     Name      : compare_archive_data
     Purpose   : compares Provincial YEPP data and Provincial YE Amendment Data
     Arguments : p_assignment_action_id -> Assignment_action_id
                 p_locked_action_id     -> YEPP Assignment_action_id
                 p_jurisdiction         -> Jurisdiction_code

     Notes     : Used for Provincial YE Amendment Pre-Process (YE-2003)
  */

  FUNCTION compare_archive_data(p_assignment_action_id in number,
                                p_locked_action_id     in number,
                                p_jurisdiction         in varchar2)
  RETURN VARCHAR2 IS
  TYPE act_info_rec IS RECORD
   (archive_context1 number(25),
    archive_ue_id    number(25),
    archive_value    varchar2(240));

  TYPE footnote_rec IS RECORD
   (message varchar2(240)
   ,value   varchar2(240));

  TYPE number_data_type_table IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

  TYPE action_info_table IS TABLE OF act_info_rec
  INDEX BY BINARY_INTEGER;

  TYPE footnote_table IS TABLE OF footnote_rec
  INDEX BY BINARY_INTEGER;

  ltr_amend_arch_data action_info_table;
  ltr_yepp_arch_data action_info_table;
  ltr_amend_emp_data action_info_table;
  ltr_yepp_emp_data action_info_table;
  ltr_emp_ue_id number_data_type_table;

  ltr_amend_footnote      footnote_table;
  ltr_yepp_footnote       footnote_table;
  ln_yepp_footnote_count  number;
  ln_amend_footnote_count number;

  cursor c_get_nonbox_footnote(cp_asg_act_id number) is
  select action_information4,
         action_information5
  from pay_action_information
  where action_context_id = cp_asg_act_id
  and   action_information_category = 'CA FOOTNOTES'
  and   action_context_type = 'AAP'
  and   action_information6 = 'RL1'
  order by action_information4;

-- Cursor to get archived values based on Asg_act_id,jurisdiction
  CURSOR c_get_emp_rl1box_data(cp_asg_act_id number) IS
  SELECT fai1.context1,
         fdi1.user_entity_id,
         fai1.value
  FROM ff_archive_items fai1,
       ff_database_items fdi1,
       ff_archive_item_contexts faic,
       ff_contexts fc
  WHERE fai1.user_entity_id = fdi1.user_entity_id
  AND fai1.archive_item_id  = faic.archive_item_id
  AND fc.context_id         = faic.context_id
  AND fc.context_name       = 'JURISDICTION_CODE'
  AND faic.context          = 'QC'
  AND fai1.CONTEXT1         = cp_asg_act_id
  AND fdi1.user_name       NOT IN ('CAEOY_RL1_AMENDMENT_FLAG','CAEOY_RL1_PDF_SEQ_NUMBER')  --For Bug 9215185
  ORDER BY fdi1.user_name;

-- Cursor to get archived values based on Asg_act_id
  CURSOR c_get_employee_data(cp_asg_act_id number,
                             cp_dbi_ue_id number) IS
  SELECT fai.context1,fai.user_entity_id,fai.value
  FROM   ff_archive_items   fai
  WHERE  fai.user_entity_id = cp_dbi_ue_id
  AND    fai.context1       = cp_asg_act_id;

  i number;
  j number;
  ln_box number;
  ln_amend_box number;

  lv_flag varchar2(2):= 'N';

    begin

   /* Initialization Process */
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

      if ltr_amend_footnote.count > 0 then
         ltr_amend_footnote.delete;
      end if;

      if ltr_yepp_footnote.count > 0 then
         ltr_yepp_footnote.delete;
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
      ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_CITY');

      j := j+1;
      ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_PROVINCE');

      j := j+1;
      ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_COUNTRY');

      j := j+1;
      ltr_emp_ue_id(j) := get_user_entity_id('CAEOY_EMPLOYEE_POSTAL_CODE');

   /* Populate RL1 Amendment Box Data for an assignment_action */
      open c_get_emp_rl1box_data(p_assignment_action_id);
      hr_utility.trace('Populating RL1 Amendment Box Data ');
      hr_utility.trace('P_assignment_action_id :'||to_char(p_assignment_action_id));
      ln_amend_box := 0;
      loop
         fetch c_get_emp_rl1box_data into ltr_amend_arch_data(ln_amend_box);
         exit when c_get_emp_rl1box_data%NOTFOUND;

         hr_utility.trace('ln_amend_box :'||to_char(ln_amend_box));
         hr_utility.trace('Archive_Context1: '||to_char(ltr_amend_arch_data(ln_amend_box).archive_context1));
         hr_utility.trace('Archive_UE_id: '||to_char(ltr_amend_arch_data(ln_amend_box).archive_ue_id));
         hr_utility.trace('Archive_Value: '||ltr_amend_arch_data(ln_amend_box).archive_value);
         ln_amend_box := ln_amend_box + 1;
      end loop;

      close c_get_emp_rl1box_data;

   /* Populate RL1 Amendment Employee Data for an assignment_action */
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


   /* Populate RL1 YEPP Box Data for an assignment_action */
      open c_get_emp_rl1box_data(p_locked_action_id);
      hr_utility.trace('Populating RL1 YEPP Box Data ');
      hr_utility.trace('P_locked_action_id :'||to_char(p_locked_action_id));
      ln_box := 0;
      loop
         fetch c_get_emp_rl1box_data into ltr_yepp_arch_data(ln_box);
         exit when c_get_emp_rl1box_data%NOTFOUND;

         hr_utility.trace('ln_box :'||to_char(ln_box));
         hr_utility.trace('Archive_Context1: '||to_char(ltr_yepp_arch_data(ln_box).archive_context1));
         hr_utility.trace('Archive_UE_id: '||to_char(ltr_yepp_arch_data(ln_box).archive_ue_id));
         hr_utility.trace('Archive_Value: '||ltr_yepp_arch_data(ln_box).archive_value);
         ln_box := ln_box + 1;
      end loop;

      close c_get_emp_rl1box_data;

   /* Populate RL1 YEPP Employee Data for an assignment_action */
      hr_utility.trace('Populating YEPP Employee Data ');
      hr_utility.trace('P_locked_action_id :'||to_char(P_locked_action_id));

      for i in 0 .. j
      loop
         open c_get_employee_data(p_locked_action_id, ltr_emp_ue_id(i));
         fetch c_get_employee_data into ltr_yepp_emp_data(i);
         exit when c_get_employee_data%NOTFOUND;

         hr_utility.trace('I :'||to_char(i));
         hr_utility.trace('Archive_Context1: '||to_char(ltr_yepp_emp_data(i).archive_context1));
         hr_utility.trace('Archive_UE_id: '||to_char(ltr_yepp_emp_data(i).archive_ue_id));
         hr_utility.trace('Archive_Value: '||ltr_yepp_emp_data(i).archive_value);

         close c_get_employee_data;
      end loop;

   /* Populate RL1 Amendment Footnotes */
      open c_get_nonbox_footnote(p_assignment_action_id);

      hr_utility.trace('Populating RL1 Amendment Footnote ');

      ln_amend_footnote_count := 0;
      loop
         fetch c_get_nonbox_footnote into ltr_amend_footnote(ln_amend_footnote_count);
         exit when c_get_nonbox_footnote%NOTFOUND;

         hr_utility.trace('Amend Message: '||ltr_amend_footnote(ln_amend_footnote_count).message);
         hr_utility.trace('Amend Value: '||ltr_amend_footnote(ln_amend_footnote_count).value);

         ln_amend_footnote_count := ln_amend_footnote_count + 1;
      end loop;

      close c_get_nonbox_footnote;

   /* Populate RL1 YEPP Footnotes */
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


   /* Compare RL1 Amendment Box Data and RL1 YEPP Box Data for an
      assignment_action */

      hr_utility.trace('Comparing RL1 Amend and RL1 YEPP Box Data ');

      if ln_box <> ln_amend_box then
         lv_flag := 'Y';
      elsif ln_box = ln_amend_box then
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
                   hr_utility.trace('Archive_UE_id with differnt value :'||
                                          to_char(ltr_yepp_arch_data(i).archive_ue_id));
                   exit;
               end if;

            end if;

         end loop;

      end if;

   /* Compare RL1 Employee Data and RL1 YEPP Employee Data for an
      assignment_action */
      If lv_flag <> 'Y' then

       hr_utility.trace('Comparing RL1 Amend and RL1 YEPP Employee Data ');
       for i in ltr_yepp_emp_data.first..ltr_yepp_emp_data.last
       loop
          if (ltr_yepp_emp_data(i).archive_ue_id =
              ltr_amend_emp_data(i).archive_ue_id) then

             hr_utility.trace('ltr_yepp_emp_data(i).archive_value : '||
                                            ltr_yepp_emp_data(i).archive_value);
             hr_utility.trace('ltr_amend_emp_data(i).archive_value: '||
                                            ltr_amend_emp_data(i).archive_value);

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

   /* Compare RL1 Amendment Footnotes and RL1 YEPP Footnotes for an
      assignment_action */

     hr_utility.trace('Comparing RL1 Amend and RL1 YEPP Footnotes');

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

end compare_archive_data;


 /*
  Name    : eoy_action_creation
  Purpose   : This creates the assignment actions for a specific chunk
              of people to be archived by the year end preprocess.
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
   l_object_version_number  number;
   l_some_warning  boolean;
   l_counter                number;
   l_user_entity_name_tab    pay_ca_eoy_rl1_archive.char240_data_type_table;
   l_user_entity_value_tab    pay_ca_eoy_rl1_archive.char240_data_type_table;
   l_user_entity_name     varchar2(240);

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
   l_archive_item_id               number;

   /* Variable holding the balance to be tested. */

   l_defined_balance_id     pay_defined_balances.defined_balance_id%type;

   /* Indicator variables used to control how the people are grouped. */

   l_group_by_gre           boolean := FALSE;
   l_group_by_medicare      boolean := FALSE;

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
   l_province       pay_payroll_actions.report_qualifier%type;
   l_value          number;
   l_effective_date date;
   l_quarter_start  date;
   l_quarter_end    date;
   l_year_start     date;
   l_year_end       date;
   lockingactid     number;
   l_max_aaid       number;
   l_pre_organization_id varchar2(17);
   l_prev_pre_organization_id varchar2(17);
   l_primary_asg    pay_assignment_actions.assignment_id%type;
   ln_no_gross_earnings number;
   ln_nontaxable_earnings number;


   /* For Year End Preprocess we have to archive the assignments
      belonging to a GRE  */

   /* For Year End Preprocess we can also archive the assignments
      belonging to all GREs  */
/*
   CURSOR c_eoy_qbin IS
     SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            ASG.effective_end_date      effective_end_date
     FROM   per_all_assignments_f      ASG,
            pay_all_payrolls_f         PPY,
            hr_soft_coding_keyflex SCL
     WHERE  ASG.business_group_id + 0  = l_bus_group_id
       AND  ASG.person_id between stperson and endperson
       AND  ASG.assignment_type        = 'E'
       AND  ASG.effective_start_date  <= l_period_end
       AND  ASG.effective_end_date    >= l_period_start
       AND  SCL.soft_coding_keyflex_id = ASG.soft_coding_keyflex_id
       AND  (
        (rtrim(ltrim(SCL.segment1))  in
       (select to_char(hoi.organization_id)
        from hr_organization_information hoi
        where hoi.org_information_context =  'Canada Employer Identification'
        and hoi.org_information2  = l_pre_organization_id))
         or
        (rtrim(ltrim(SCL.segment11))  in
       (select to_char(hoi.organization_id)
        from hr_organization_information hoi
        where hoi.org_information_context =  'Canada Employer Identification'
        and hoi.org_information2  = l_pre_organization_id))
       )
       AND  PPY.payroll_id             = ASG.payroll_id
      and exists ( select 'X' from pay_action_contexts pac, ff_contexts fc
                    where pac.assignment_id = asg.assignment_id
                    and   pac.context_id = fc.context_id
		    and   fc.context_name = 'JURISDICTION_CODE'
                     and pac.context_value = 'QC' )
     ORDER  BY 1, 3 DESC, 2; */

/* bug 5202869. For performance reason changed the query to remove per_people_f
   and also disabled some indexes. With this change the cost of the query
   increases however now the path taken is now more correct.
*/
   CURSOR c_eoy_qbin IS
   SELECT   asg.person_id          person_id,
            asg.assignment_id      assignment_id,
            asg.effective_end_date effective_end_date
     FROM  per_all_assignments_f  asg,
           pay_assignment_actions paa,
           pay_payroll_actions    ppa
     WHERE ppa.effective_date between l_period_start
                                  and l_period_end
     AND  ppa.action_type in ('R','Q','V','B','I')
     AND  ppa.business_group_id  +0 = l_bus_group_id
     AND  ppa.payroll_action_id = paa.payroll_action_id
     AND  paa.tax_unit_id in (select hoi.organization_id
                              from hr_organization_information hoi
                              where hoi.org_information_context ||''=  'Canada Employer Identification'
                              and hoi.org_information2  = l_pre_organization_id
                              and hoi.org_information5 in ('T4/RL1','T4A/RL1'))
     AND  paa.assignment_id = asg.assignment_id
     AND  ppa.business_group_id = asg.business_group_id +0
     AND  asg.person_id between stperson and endperson
     AND  asg.assignment_type  = 'E'
     AND  ppa.effective_date between asg.effective_start_date
                                 and asg.effective_end_date
     AND EXISTS (select 1
                 from pay_action_contexts pac,
                      ff_contexts         fc
                 where pac.assignment_id = paa.assignment_id
                 and   pac.assignment_action_id = paa.assignment_action_id
                 and   pac.context_id = fc.context_id
                 and   fc.context_name ||'' = 'JURISDICTION_CODE'
                 and   pac.context_value ||'' = 'QC')
  ORDER  BY 1, 3 DESC, 2;

      cursor c_all_qbin_gres is
       select hoi.organization_id
        from hr_organization_information hoi
        where hoi.org_information_context =  'Canada Employer Identification'
        and hoi.org_information2  = l_pre_organization_id;

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

    /* Added cursor for 11510 Changes Bug#3356533. Changed cursor to get
       max asgact_id based on person_id, fix for bug#3638928. */
    CURSOR c_get_max_asg_act_id(cp_person_id number,
                                  cp_tax_unit_id number,
                                  cp_period_start date,
                                  cp_period_end date) IS
    select paa.assignment_action_id
    from pay_assignment_actions     paa,
         per_all_assignments_f      paf,
         per_all_people_f ppf,
         pay_payroll_actions        ppa,
         pay_action_classifications pac
    where ppf.person_id = cp_person_id
    and paf.person_id = ppf.person_id
    and paa.assignment_id = paf.assignment_id
    and paa.tax_unit_id   = cp_tax_unit_id
    and ppa.payroll_action_id = paa.payroll_action_id
    and ppa.effective_date between cp_period_start and cp_period_end
    and ppa.effective_date between ppf.effective_start_date
        and ppf.effective_end_date
    and ppa.effective_date between paf.effective_start_date
        and paf.effective_end_date
    and ppa.action_type = pac.action_type
    and pac.classification_name = 'SEQUENCED'
    order by paa.action_sequence desc;

   begin

     /* Get the report type, report qualifier, business group id and the
        gre for which the archiving has to be done */

     hr_utility.trace('getting report type ');

     select effective_date,
            report_type,
            business_group_id,
            pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                      legislative_parameters)
     into   l_effective_date,
            l_report_type,
            l_bus_group_id,
            l_pre_organization_id
     from pay_payroll_actions
     where payroll_action_id = pactid;

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
          l_group_by_medicare,
          l_tax_unit_context,
          l_jurisdiction_context);

     hr_utility.trace('Out of get selection information');
        open c_eoy_qbin;

     /* Loop for all rows returned for SQL statement. */

     hr_utility.trace('Entering loop');

     loop

           fetch c_eoy_qbin
                            into l_person_id,
                                 l_assignment_id,
                                 l_effective_end_date;

           exit when c_eoy_qbin%NOTFOUND;


        /* If the new row is the same as the previous row according to the way
           the rows are grouped then discard the row ie. grouping by PRE
           organization id requires a single row for each person / PRE
           combination. */

        hr_utility.trace('Prov Reporting Est organization id '|| l_pre_organization_id);
        hr_utility.trace('previous pre_organization_id is '||
                                    l_prev_pre_organization_id);
        hr_utility.trace('person_id is '||
                                    to_char(l_person_id));
        hr_utility.trace('previous person_id is '||
                                    to_char(l_prev_person_id));

        if (l_person_id   = l_prev_person_id   and
            l_pre_organization_id = l_prev_pre_organization_id) then

          hr_utility.trace('Not creating assignment action');

        else
          /* Check whether the person has 0 payment or not */

          l_value := 0;
          ln_no_gross_earnings   := 0;
          ln_nontaxable_earnings := 0;

          open c_all_qbin_gres;
          loop
            fetch c_all_qbin_gres into l_tax_unit_id;
            exit when c_all_qbin_gres%NOTFOUND;

            /* select the maximum assignment action id, removed the select stmt
               and replaced it with cursor c_get_max_asg_act_id 11510 Changes
               Bug#3356533. Passing person_id to fix bug#3638928 */
            begin
             open c_get_max_asg_act_id(l_person_id,
                                       l_tax_unit_id,
                                       l_period_start,
                                       l_period_end);
             fetch c_get_max_asg_act_id into l_max_aaid;
             if c_get_max_asg_act_id%NOTFOUND then
                l_max_aaid := -9999;
             end if;
             close c_get_max_asg_act_id;

     end;

        if l_max_aaid <> -9999 then
               l_value := l_value +
                   nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                   ('Gross Earnings',
                   'YTD' ,
                    l_max_aaid,
                    l_assignment_id ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_bus_group_id,
                    'QC'
                   ),0) ;

               ln_no_gross_earnings := ln_no_gross_earnings +
                   nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                   ('RL1 No Gross Earnings',
                   'YTD' ,
                    l_max_aaid,
                    l_assignment_id ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_bus_group_id,
                    'QC'
                   ),0);

               ln_nontaxable_earnings := ln_nontaxable_earnings +
                   nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                   ('RL1 Non Taxable Earnings',
                   'YTD' ,
                    l_max_aaid,
                    l_assignment_id ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_bus_group_id,
                    'QC'
                   ),0);
         end if; /* end l_max_id <> -9999 */
      end loop;
      close c_all_qbin_gres;
    /* end of checking whether the person has 0 payment */

          hr_utility.trace('prev person is '|| to_char(l_prev_person_id));
          hr_utility.trace('person is '|| to_char(l_person_id));
          hr_utility.trace('assignment is '|| to_char(l_assignment_id));


          /* Have a new unique row according to the way the rows are grouped.
             The inclusion of the person is dependent on having a non zero
             balance.
             If the balance is non zero then an assignment action is created to
             indicate their inclusion in the magnetic tape report. */

          /* Set up the context of tax unit id */

          hr_utility.trace('Setting context');

         /* Only create assignment actions if Gross Earnings are not 0 and are not
            made up of only nontaxable earnings or the No Gross Earnings balance is
            non zero */

         if (((l_value <> 0) and
              (ln_nontaxable_earnings <> l_value)) or
             (ln_no_gross_earnings <> 0)) then

          /* Get the primary assignment */
          open c_get_asg_id(l_person_id);
          fetch c_get_asg_id into l_primary_asg;

          if c_get_asg_id%NOTFOUND then
             close c_get_asg_id;
             raise hr_utility.hr_error;
          else
             close c_get_asg_id;
          end if;

          /* Create the assignment action to represnt the person / tax unit
             combination. */

          select pay_assignment_actions_s.nextval
          into   lockingactid
          from   dual;

          /* Insert into pay_assignment_actions. */

          hr_utility.trace('creating assignment action');

/* Passing tax unit id as null */

          hr_nonrun_asact.insact(lockingactid,l_primary_asg,
                                 pactid,chunk,null);

          /* Update the serial number column with the person id
             so that the mag routine and the RL1 view will not have
             to do an additional checking against the assignment
             table */

          hr_utility.trace('updating assignment action' || to_char(lockingactid));

          update pay_assignment_actions aa
          set    aa.serial_number = to_char(l_person_id)
          where  aa.assignment_action_id = lockingactid;


/* Since the API checks the presence of a row in pay_report_format_items for
   action type AAC and PA , check it here also to avoid API error */
/*
  l_counter := 1;
  l_user_entity_name := 'CAEOY_RL1_QUEBEC_BN';

          hr_utility.trace('Archiving AAC level data for ' || to_char(lockingactid));
 ff_archive_api.create_archive_item(
  p_archive_item_id => l_archive_item_id
  ,p_user_entity_id => get_user_entity_id(l_user_entity_name)
  ,p_archive_value   => l_pre_organization_id
  ,p_archive_type   => 'AAC'
  ,p_action_id       => lockingactid
  ,p_legislation_code => 'CA'
  ,p_object_version_number  => l_object_version_number
  ,p_some_warning           => l_some_warning
);
          hr_utility.trace('Archived AAC level data');
*/

/* I have to enter data in new archive table also with archive type as AAC, ie
assignment_action_creation */
      end if; /* end of l_value <> 0 OR ln_no_gross_earnings <> 0 */
     end if; /* end of l_person_id <> l_prev_person_id */

     /* Record the current values for the next time around the loop. */

     l_prev_person_id   := l_person_id;
     l_prev_pre_organization_id := l_pre_organization_id;

   end loop;

          hr_utility.trace('Action creation done');
 close c_eoy_qbin;

 end eoy_action_creation;



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



  /* Name      : eoy_archive_gre_data
     Purpose   : This performs the CA specific employer data archiving.
     Arguments :
     Notes     :
  */

  PROCEDURE eoy_archive_gre_data(p_payroll_action_id   in number,
                                 p_pre_organization_id in varchar2)
  IS

  l_user_entity_id               number;
  l_taxunit_context_id           number;
  l_jursd_context_id             number;
  l_value                        varchar2(240);
  l_sit_uid                      number;
  l_sui_uid                      number;
  l_fips_uid                     number;
  l_seq_tab                      pay_ca_eoy_rl1_archive.number_data_type_table;
  l_context_id_tab               pay_ca_eoy_rl1_archive.number_data_type_table;
  l_context_val_tab              pay_ca_eoy_rl1_archive.char240_data_type_table;
  l_user_entity_name_tab         pay_ca_eoy_rl1_archive.char240_data_type_table;
  l_user_entity_value_tab        pay_ca_eoy_rl1_archive.char240_data_type_table;
  l_arch_gre_step                number := 0;
  l_archive_item_id              number;
  l_town_or_city                 varchar2(240);
  l_province_code                varchar2(240);
  l_postal_code                  varchar2(240);
  l_organization_id_of_qin       number;
  l_transmitter_org_id           number;
  l_country_code                 varchar2(240);
  l_transmitter_name             varchar2(240);
  l_Transmitter_Type_Indicator   varchar2(240);
  l_transmitter_gre_ind          varchar2(240);
  l_Transmitter_number           varchar2(240);
  l_transmitter_addr_line_1      varchar2(240);
  l_transmitter_addr_line_2      varchar2(240);
  l_transmitter_addr_line_3      varchar2(240);
  l_transmitter_city             varchar2(240);
  l_transmitter_province         varchar2(240);
  l_transmitter_postal_code      varchar2(240);
  l_transmitter_country          varchar2(240);
  l_rl_data_type                 varchar2(240);
  l_rl_package_type              varchar2(240);
  l_rl_source_of_slips           varchar2(240);
  l_technical_contact_name       varchar2(240);
  l_technical_contact_phone      varchar2(240);
  l_technical_contact_area_code  varchar2(240);
  l_technical_contact_extension  varchar2(240);
  l_technical_contact_language   varchar2(240);
  l_accounting_contact_name      varchar2(240);
  l_accounting_contact_phone     varchar2(240);
  l_accounting_contact_area_code varchar2(240);
  l_accounting_contact_extension varchar2(240);
  l_accounting_contact_language  varchar2(240);
  l_proprietor_sin               varchar2(240);
  l_name                         varchar2(240);
  l_employer_ein                 varchar2(240);
  l_address_line_1               varchar2(240);
  l_address_line_2               varchar2(240);
  l_address_line_3               varchar2(240);
  l_counter                      number := 0;
  l_object_version_number        number;
  l_business_group_id            varchar2(240);
  l_some_warning                 boolean;
  l_step                         number := 0;
  l_taxation_year                varchar2(4);
  l_rl1_last_slip_number         number ;
  l_employer_info_found          varchar2(1);
  l_max_slip_number              varchar2(80);

  cursor employer_info is
  select target1.organization_id,
         target2.name,
         target2.business_group_id,
         target1.ORG_INFORMATION2 Prov_Identi_Number,
         target1.ORG_INFORMATION7 Type_of_Transmitter,
         target1.ORG_INFORMATION5 Transmitter_Number,
         target1.ORG_INFORMATION4 Type_of_Data,
         target1.ORG_INFORMATION6 Type_of_Package,
         target1.ORG_INFORMATION8 Source_of_RL_slips_used,
         target1.ORG_INFORMATION9 Tech_Res_Person_Name,
         target1.ORG_INFORMATION11 Tech_Res_Phone,
         target1.ORG_INFORMATION10 Tech_Res_Area_Code,
         target1.ORG_INFORMATION12 Tech_Res_Extension,
         decode(target1.ORG_INFORMATION13,'E','A',
                       target1.ORG_INFORMATION13) Tech_Res_Language,
         target1.ORG_INFORMATION14 Acct_Res_Person_Name,
         target1.ORG_INFORMATION16 Acct_Res_Phone,
         target1.ORG_INFORMATION15 Acct_Res_Area_Code,
         target1.ORG_INFORMATION17 Acct_Res_Extension,
         decode(target1.ORG_INFORMATION19,'E','A',
                        target1.ORG_INFORMATION19) Acct_Res_Language,
         substr(target1.ORG_INFORMATION18,1,8) RL1_Slip_Number,
         decode(target1.org_information3,'Y',target1.organization_id,
                                             target1.ORG_INFORMATION20),
         target1.ORG_INFORMATION3
  from   hr_organization_information target1 ,
         hr_all_organization_units target2
  where  target1.organization_id   = to_number(p_pre_organization_id)
  and    target2.business_group_id = l_business_group_id
  and    target2.organization_id   = target1.organization_id
  and    target1.org_information_context = 'Prov Reporting Est';

  /* payroll action level database items */

  BEGIN

    /*hr_utility.trace_on('Y','RL1'); */

    select to_char(effective_date,'YYYY'),business_group_id
    into   l_taxation_year,l_business_group_id
    from   pay_payroll_actions
    where  payroll_action_id = p_payroll_action_id;

    open employer_info;

    fetch employer_info
    into   l_organization_id_of_qin,
           l_name,                        l_business_group_id,
           l_employer_ein,
           l_Transmitter_Type_Indicator,  l_transmitter_number,
           l_rl_data_type,                l_rl_package_type,
           l_rl_source_of_slips,
           l_technical_contact_name,      l_technical_contact_phone,
           l_technical_contact_area_code, l_technical_contact_extension,
           l_technical_contact_language,  l_accounting_contact_name,
           l_accounting_contact_phone ,
           l_accounting_contact_area_code ,
           l_accounting_contact_extension ,
           l_accounting_contact_language,
           l_rl1_last_slip_number,
           l_transmitter_org_id,
           l_transmitter_gre_ind;

    l_arch_gre_step := 40;
    hr_utility.trace('eoy_archive_gre_data 1');

    if employer_info%FOUND then

       close employer_info;
       hr_utility.trace('got employer data  ');

       l_employer_info_found := 'Y';

       begin
         select
             L.ADDRESS_LINE_1
           , L.ADDRESS_LINE_2
           , L.ADDRESS_LINE_3
           , L.TOWN_OR_CITY
           , DECODE(L.STYLE,'US',L.REGION_2,'CA',L.REGION_1,'CA_GLB',L.REGION_1,' ')
           , replace(L.POSTAL_CODE,' ')
           , L.COUNTRY
         into
            l_address_line_1
          , l_address_line_2
          , l_address_line_3
          , l_town_or_city
          , l_province_code
          , l_postal_code
          , l_country_code
         from  hr_all_organization_units O,
               hr_locations_all L
         where L.LOCATION_ID = O.LOCATION_ID
         AND O.ORGANIZATION_ID = l_organization_id_of_qin;

         /* Find out the highest slip number for that transmitter */

         if l_transmitter_gre_ind = 'Y' then

            l_transmitter_org_id :=  l_organization_id_of_qin;

            l_transmitter_addr_line_1 := l_address_line_1;
            l_transmitter_addr_line_2 := l_address_line_2;
            l_transmitter_addr_line_3 := l_address_line_3;
            l_transmitter_city        := l_town_or_city;
            l_transmitter_province    := l_province_code;
            l_transmitter_postal_code := l_postal_code;
            l_transmitter_country     := l_country_code;

         end if;

         exception when no_data_found then
           l_address_line_1 := NULL;
           l_address_line_2 := NULL;
           l_address_line_3 := NULL;
           l_town_or_city   := NULL;
           l_province_code  := NULL;
           l_postal_code    := NULL;
           l_country_code   := NULL;
       end;

       begin
         select name
         into   l_transmitter_name
         from   hr_all_organization_units
         where  organization_id = l_transmitter_org_id;

         EXCEPTION
           when no_data_found then
             l_transmitter_name := null;
       end;

    else
       l_employer_ein               := 'TEST_DATA';
       l_address_line_1             := 'TEST_DATA';
       l_address_line_2             := 'TEST_DATA';
       l_address_line_3             := 'TEST_DATA';
       l_town_or_city               := 'TEST_DATA';
       l_province_code              := 'TEST_DATA';
       l_postal_code                := 'TEST_DATA';
       l_country_code               := 'TEST_DATA';
       l_name                       := 'TEST_DATA';
       l_transmitter_name           := 'TEST_DATA';
       l_transmitter_addr_line_1    := 'TEST_DATA';
       l_transmitter_addr_line_2    := 'TEST_DATA';
       l_transmitter_addr_line_3    := 'TEST_DATA';
       l_transmitter_city           := 'TEST_DATA';
       l_transmitter_province       := 'TEST_DATA';
       l_transmitter_postal_code    := 'TEST_DATA';
       l_transmitter_country        := 'TEST_DATA';
       l_technical_contact_name     := 'TEST_DATA';
       l_technical_contact_phone    := 'TEST_DATA';
       l_technical_contact_language := 'TEST_DATA';
       l_accounting_contact_name    := 'TEST_DATA';
       l_accounting_contact_phone   := 'TEST_DATA';
       l_accounting_contact_language:= 'TEST_DATA';
       l_proprietor_sin             := 'TEST_DATA';
       l_arch_gre_step              := 424;

       hr_utility.trace('eoy_archive_gre_data 2');
       close employer_info;

       hr_utility.set_message(801,'PAY_74014_NO_TRANSMITTER_ORG');
       hr_utility.set_message_token('ORGIND','GRE');
       hr_utility.raise_error;
    end if;

    /* archive Releve 1 data */

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_QUEBEC_BN';
    l_user_entity_value_tab(l_counter) := l_employer_ein;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_PRE_ORG_ID';
    l_user_entity_value_tab(l_counter) := p_pre_organization_id;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_NUMBER';
    l_user_entity_value_tab(l_counter) := l_transmitter_number;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_DATA_TYPE';
    l_user_entity_value_tab(l_counter) := l_rl_data_type;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_PACKAGE_TYPE';
    l_user_entity_value_tab(l_counter) := l_rl_package_type;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_TYPE';
    l_user_entity_value_tab(l_counter) := l_Transmitter_Type_Indicator;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_SOURCE_OF_SLIPS';
    l_user_entity_value_tab(l_counter) := l_rl_source_of_slips;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_TAXATION_YEAR';
    l_user_entity_value_tab(l_counter) := l_taxation_year;

    l_arch_gre_step := 428;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_COUNTRY';
    l_user_entity_value_tab(l_counter) := l_transmitter_country;

    l_arch_gre_step := 429;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_NAME';
    l_user_entity_value_tab(l_counter) := l_transmitter_name;

    l_arch_gre_step := 4210;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_ADDRESS_LINE1';
    l_user_entity_value_tab(l_counter) := l_transmitter_addr_line_1;

    l_arch_gre_step := 4211;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_ADDRESS_LINE2';
    l_user_entity_value_tab(l_counter) := l_transmitter_addr_line_2;

    --  Bug 4517693
    l_arch_gre_step := 4212;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_ADDRESS_LINE3';
    l_user_entity_value_tab(l_counter) := l_transmitter_addr_line_3;

    l_arch_gre_step := 4213;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_CITY';
    l_user_entity_value_tab(l_counter) := l_transmitter_city;

    l_arch_gre_step := 4214;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_PROVINCE';
    l_user_entity_value_tab(l_counter) := l_transmitter_province;

/*--  This is original
    l_arch_gre_step := 4212;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_CITY';
    l_user_entity_value_tab(l_counter) := l_transmitter_city;

    l_arch_gre_step := 4213;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_PROVINCE';
    l_user_entity_value_tab(l_counter) := l_transmitter_province;
*/

    l_arch_gre_step := 4215;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TRANSMITTER_POSTAL_CODE';
    l_user_entity_value_tab(l_counter) := l_transmitter_postal_code;

    l_arch_gre_step := 4216;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TECHNICAL_CONTACT_NAME';
    l_user_entity_value_tab(l_counter) := l_technical_contact_name;

    l_arch_gre_step := 4217;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_TECHNICAL_CONTACT_PHONE';
    l_user_entity_value_tab(l_counter) := l_technical_contact_phone;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  :=
                                       'CAEOY_RL1_TECHNICAL_CONTACT_AREA_CODE';
    l_user_entity_value_tab(l_counter) := l_technical_contact_area_code;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  :=
                                       'CAEOY_RL1_TECHNICAL_CONTACT_EXTENSION';
    l_user_entity_value_tab(l_counter) := l_technical_contact_extension;

    l_arch_gre_step := 4218;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  :=
                                       'CAEOY_RL1_TECHNICAL_CONTACT_LANGUAGE';
    l_user_entity_value_tab(l_counter) := l_technical_contact_language;

    l_arch_gre_step := 4219;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_ACCOUNTING_CONTACT_NAME';
    l_user_entity_value_tab(l_counter) := l_accounting_contact_name;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  :=
                                       'CAEOY_RL1_ACCOUNTING_CONTACT_AREA_CODE';
    l_user_entity_value_tab(l_counter) := l_accounting_contact_area_code;

    l_arch_gre_step := 42110;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_ACCOUNTING_CONTACT_PHONE';
    l_user_entity_value_tab(l_counter) := l_accounting_contact_phone ;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  :=
                                       'CAEOY_RL1_ACCOUNTING_CONTACT_EXTENSION';
    l_user_entity_value_tab(l_counter) := l_accounting_contact_extension;

    l_arch_gre_step := 4218;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  :=
                                       'CAEOY_RL1_ACCOUNTING_CONTACT_LANGUAGE';
    l_user_entity_value_tab(l_counter) := l_accounting_contact_language;

    l_arch_gre_step := 42111;
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_EMPLOYER_NAME';

    l_user_entity_value_tab(l_counter) := 'TEST_DATA';
    l_user_entity_value_tab(l_counter) := l_name;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_EMPLOYER_ADDRESS_LINE1';
    l_user_entity_value_tab(l_counter) := l_address_line_1;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_EMPLOYER_ADDRESS_LINE2';
    l_user_entity_value_tab(l_counter) := l_address_line_2;

    -- Bug 4517693
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_EMPLOYER_ADDRESS_LINE3';
    l_user_entity_value_tab(l_counter) := l_address_line_3;
--
    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_EMPLOYER_CITY';
    l_user_entity_value_tab(l_counter) := l_town_or_city;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_EMPLOYER_PROVINCE';
    l_user_entity_value_tab(l_counter) := l_province_code;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_EMPLOYER_COUNTRY';
    l_user_entity_value_tab(l_counter) := l_country_code;

    l_counter := l_counter + 1;
    l_user_entity_name_tab(l_counter)  := 'CAEOY_RL1_EMPLOYER_POSTAL_CODE';
    l_user_entity_value_tab(l_counter) := l_postal_code;

    l_arch_gre_step := 50;
    l_arch_gre_step := 51;

    /* Other employer level data for RL-1 total is to be discussed ,
       whether it is for Quebec only or not */

    g_archive_flag := 'Y';

    for i in 1..l_counter loop

      /*
      Since the API checks the presence of a row in pay_report_format_items for
      action type AAC and PA , check it here also to avoid API error To be done
      */

      l_arch_gre_step := 52;

      /*hr_utility.trace_on('Y','RL1'); */

      hr_utility.trace('user_entity id is : ' || l_user_entity_name_tab(i));

      ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id
        ,p_user_entity_id       => get_user_entity_id(l_user_entity_name_tab(i))
        ,p_archive_value        => l_user_entity_value_tab(i)
        ,p_archive_type         => 'PA'
        ,p_action_id            => p_payroll_action_id
        ,p_legislation_code     => 'CA'
        ,p_object_version_number=> l_object_version_number
        ,p_some_warning         => l_some_warning
        );
        l_arch_gre_step := 53;
    end loop;

    EXCEPTION
     when others then
       g_archive_flag := 'N';
       hr_utility.trace('Error in eoy_archive_gre_data at step :' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
       if l_arch_gre_step = 40 then
          hr_utility.set_message(801,'PAY_74014_NO_TRANSMITTER_ORG');
          hr_utility.set_message_token('ORGIND','ORG');
       end if;
      hr_utility.raise_error;

  END eoy_archive_gre_data;

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

  /* Name      : getnext_seq_num
     Purpose   : Calculates and inserts check digit to PDF sequence number
  */

FUNCTION getnext_seq_num (p_curr_seq IN NUMBER)
  RETURN NUMBER IS
    l_seq_number   number;
    l_check_number number;
  BEGIN

     l_check_number := mod(p_curr_seq,7);
     hr_utility.trace('l_check_number ='|| l_check_number);
     l_seq_number := (p_curr_seq * 10) + l_check_number;
     hr_utility.trace('l_seq_number ='|| l_seq_number);
     return l_seq_number;
  END;


  /* Name      : gen_rl1_pdf_seq
     Purpose   : Generates sequence number for RL1 PDF. Bug 6768167.
  */

FUNCTION gen_rl1_pdf_seq(p_aaid number,
                           p_reporting_year varchar2,
                           p_jurisdiction varchar2,
                           called_from varchar2)
  return varchar2 is

  cursor c_get_arch_seq_num(cp_aaid varchar2,
                          cp_jurisdiction varchar2) is
  SELECT fai1.value, fai1.archive_item_id, fai1.object_version_number
  FROM FF_ARCHIVE_ITEMS FAI1,
     ff_database_items fdi1,
     ff_archive_item_contexts faic,
     ff_contexts fc
  WHERE FAI1.USER_ENTITY_ID = fdi1.user_entity_id
    and fdi1.user_name = 'CAEOY_RL1_PDF_SEQ_NUMBER'
    and fai1.archive_item_id = faic.archive_item_id
    and fc.context_id = faic.context_id
    and fc.context_name = 'JURISDICTION_CODE'
    and faic.context = cp_jurisdiction
    and fai1.context1 = cp_aaid;

  cursor c_get_seq_num_range(cp_run_year varchar2) is
	select ROW_LOW_RANGE_OR_NAME range_start,
		     ROW_HIGH_RANGE range_end
	from 	pay_user_tables put,
		    pay_user_rows_f pur
	where pur.USER_TABLE_ID=put.USER_TABLE_ID
		and put.USER_TABLE_NAME = 'RL1 PDF Sequence Range'
		and fnd_date.string_to_date('31/12/'||cp_run_year,'DD/MM/YYYY')
			   between pur.EFFECTIVE_START_DATE and pur.EFFECTIVE_END_DATE;

  /*cursor c_get_act_info(aaid number) is
      select ACTION_INFORMATION_ID, OBJECT_VERSION_NUMBER
      from pay_action_information
      where action_context_id = aaid
            and action_information_category='CAEOY RL2 EMPLOYEE INFO2';
  */

  l_final_seq_num varchar2(25);
  l_start_seq_num varchar2(25);
  l_end_seq_num   varchar2(25);
  l_seq_offset    number;
  l_obj_ver       number;
  l_warning       boolean;
  l_archive_item_id   number;

  begin
    hr_utility.trace('In pay_ca_eoy_rl1_archive.gen_rl1_pdf_seq     10');

    if (called_from = 'XMLPROC') then
      hr_utility.trace('In pay_ca_eoy_rl1_archive.gen_rl1_pdf_seq     20');

      open c_get_arch_seq_num(p_aaid, p_jurisdiction);
      fetch c_get_arch_seq_num into l_final_seq_num,l_archive_item_id,l_obj_ver;
      close c_get_arch_seq_num;

      if (l_final_seq_num is not null) then
        return l_final_seq_num;
      end if;

    end if;

    l_start_seq_num := null;
    open c_get_seq_num_range(p_reporting_year);
    fetch c_get_seq_num_range into l_start_seq_num,l_end_seq_num;
    close c_get_seq_num_range;

    if (l_start_seq_num is not null) then
      hr_utility.trace('In pay_ca_eoy_rl1_archive.gen_rl1_pdf_seq     30');

      select PAY_CA_RL1_PDF_SEQ_COUNT_S.nextval into l_seq_offset
      from dual;
      l_final_seq_num := getnext_seq_num(l_start_seq_num + l_seq_offset);

    elsif (called_from ='ARCHIVER') then
      l_final_seq_num := null;

    end if;

    if (called_from ='XMLPROC') then
    	if(l_archive_item_id is null) then  --If DBI is not archived when PDF is run
    	    hr_utility.trace('In pay_ca_eoy_rl1_archive.gen_rl1_pdf_seq     40');

					ff_archive_api.create_archive_item(
          p_archive_item_id        => l_archive_item_id
         ,p_user_entity_id         => get_user_entity_id('CAEOY_RL1_PDF_SEQ_NUMBER')
         ,p_archive_value          => l_final_seq_num
         ,p_archive_type           => 'AAP'
         ,p_action_id              => p_aaid
         ,p_legislation_code       => 'CA'
         ,p_object_version_number  => l_obj_ver
         ,p_context_name1          => 'JURISDICTION_CODE'
         ,p_context1               => 'QC'
         ,p_some_warning           => l_warning
         );
			else -- If DBI is archived but with null value then update it with new value
			  hr_utility.trace ('In pay_ca_eoy_rl1_archive.gen_rl1_pdf_seq     50');

			  /* Commented for bug 8732218
        ff_archive_api.update_archive_item( p_archive_item_id => l_archive_item_id
                                          ,p_effective_date => fnd_date.string_to_date('31/12/'||p_reporting_year,'DD/MM/YYYY')
                                          --,p_validate  in     boolean  default false
                                          ,p_archive_value => l_final_seq_num
                                          ,p_object_version_number => l_obj_ver
                                          ,p_some_warning => l_warning ); */

        update ff_archive_items set VALUE= l_final_seq_num
			  where ARCHIVE_ITEM_ID= l_archive_item_id;

      end if;
    end if;

    return l_final_seq_num;

end gen_rl1_pdf_seq;


  /* Name      : eoy_archive_data
     Purpose   : This performs the CA specific employee context setting for the
                 Year End PreProcess.
     Arguments :
     Notes     :
  */

  PROCEDURE eoy_archive_data(p_assactid in number,
                             p_effective_date in date) IS

    l_aaid               pay_assignment_actions.assignment_action_id%type;
    l_aaid1              pay_assignment_actions.assignment_action_id%type;
    l_aaseq              pay_assignment_actions.action_sequence%type;
    l_asgid              pay_assignment_actions.assignment_id%type;
    l_date_earned        date;
    l_tax_unit_id        pay_assignment_actions.tax_unit_id%type;
    l_reporting_type     varchar2(240);
    l_prev_tax_unit_id   pay_assignment_actions.tax_unit_id%type := null;
    l_business_group_id  number;
    l_year_start         date;
    l_year_end           date;
    l_context_no         number := 60;
    l_count              number := 0;
    l_jurisdiction       varchar2(11);
    l_province_uei       ff_user_entities.user_entity_id%type;
    l_county_uei         ff_user_entities.user_entity_id%type;
    l_city_uei           ff_user_entities.user_entity_id%type;
    l_county_sd_uei      ff_user_entities.user_entity_id%type;
    l_city_sd_uei        ff_user_entities.user_entity_id%type;
    l_province_abbrev    pay_us_states.state_abbrev%type;
    l_county_name        pay_us_counties.county_name%type;
    l_city_name          pay_us_city_names.city_name%type;
    l_cnt_sd_name        pay_us_county_school_dsts.school_dst_name%type;
    l_cty_sd_name        pay_us_city_school_dsts.school_dst_name%type;
    l_step               number := 0;
    l_county_code        varchar2(3);
    l_city_code          varchar2(4);
    l_jursd_context_id   ff_contexts.context_id%type;
    l_taxunit_context_id ff_contexts.context_id%type;
    l_seq_tab            pay_ca_eoy_rl1_archive.number_data_type_table;
    l_context_id_tab     pay_ca_eoy_rl1_archive.number_data_type_table;
    l_context_val_tab    pay_ca_eoy_rl1_archive.char240_data_type_table;
    l_chunk              number;
    l_payroll_action_id  number;
    l_person_id          number;
    l_defined_balance_id number;
    l_archive_item_id    number;
    l_date_of_birth      date;
    l_hire_date          date;
    l_termination_date   date;
    l_first_name         varchar2(240);
    l_middle_name        varchar2(240);
    l_last_name          varchar2(240);
    l_employee_number    varchar2(240);
    l_pre_name_adjunct   varchar2(240);
    l_employee_phone_no  varchar2(240);
    l_address_line1      varchar2(240);
    l_address_line2      varchar2(240);
    l_address_line3      varchar2(240);
    l_town_or_city       varchar2(80);
    l_province_code      varchar2(80);
    l_postal_code        varchar2(80);
    l_telephone_number   varchar2(80);
    l_country_code       varchar2(80);
    l_counter             number := 0;

    l_count_start_for_boxo       number := 0;
    l_count_end_for_boxo         number := 0;
    l_count_for_boxo_code        number := 0;
    l_pre_organization_id     varchar2(80);
    l_national_identifier        varchar2(240);
    l_user_entity_value_tab_boxo number := 0;
    l_user_entity_code_tab_boxo  VARCHAR2(4) := NULL;
    l_object_version_number      number;
    l_rl1_slip_number_last_digit number;
    l_rl1_slip_number            number;

    l_some_warning              boolean;
    result                      number;
    l_no_of_payroll_run         number := 0;
    l_has_been_paid             varchar2(3) := 'N';
    l_user_entity_name_tab      pay_ca_eoy_rl1_archive.char240_data_type_table;
    l_user_entity_value_tab     pay_ca_eoy_rl1_archive.char240_data_type_table;
    l_balance_type_tab          pay_ca_eoy_rl1_archive.char240_data_type_table;
    l_footnote_balance_type_tab varchar2(80);
    l_footnote_code             varchar2(30);
    l_footnote_balance          varchar2(80);
    l_footnote_amount           number       := 0;
    old_l_footnote_code         varchar2(80) := null;
    old_balance_type_tab        varchar2(80) := null;
    l_footnote_code_ue          varchar2(80);
    l_footnote_amount_ue        varchar2(80);
    l_no_of_fn_codes            number := 0;
    l_value                     number := 0;
    l_transmitter_name1         varchar2(80);
    l_rl1_last_slip_number      number;
    l_rl1_curr_slip_number      number;
    l_max_slip_number           varchar2(80);
    fed_result	                number;
    non_taxable_earnings        number;
    l_negative_balance_exists   varchar2(5);
    l_boxr_flag                 varchar2(5);

    ln_balance_value            NUMBER := 0;
    ln_no_gross_earnings        NUMBER := 0;

    l_messages                VARCHAR2(240);
    l_prev_messages           VARCHAR2(240);
    l_mesg_amt                NUMBER(12,2);
    l_total_mesg_amt          NUMBER(12,2);

    l_action_information_id_1 NUMBER ;
    l_object_version_number_1 NUMBER ;
    ln_tax_unit_id            NUMBER ;
    ln_prev_tax_unit_id       NUMBER ;
    ld_eff_date               DATE ;
    ld_prev_eff_date          DATE ;
    ln_assignment_action_id   NUMBER;

    ln_status_indian          NUMBER := 0;
    ln_boxo_exclude_from_boxa NUMBER := 0;
    lv_footnote_bal           varchar2(80);

  /* added these 3 new variables for 11510 changes bug#3356533 */
    l_ft_aaid               pay_assignment_actions.assignment_action_id%type;
    l_ft_tax_unit_id        pay_assignment_actions.tax_unit_id%type;
    l_ft_reporting_type     varchar2(240);
    lv_serial_number        varchar2(30);

  /* new variables added for Provincial YE Amendment PP */
    lv_fapp_effective_date   varchar2(5);
    ln_fapp_pre_org_id       number;
    lv_fapp_report_type      varchar2(20);
    ln_fapp_locked_action_id number;
    lv_fapp_prov             varchar2(5);
    lv_fapp_flag             varchar2(2):= 'N';
    lv_fapp_locked_actid_reptype varchar2(20);
    ln_fapp_prev_amend_actid number;

  /* new variables added for pre-printed form number  */
    lv_eit_year              varchar2(30);
    lv_eit_pre_org_id        varchar2(40);
    lv_eit_form_no           varchar2(20);
    ln_form_no_archived      varchar2(2);

    lv_footnote_element      varchar2(50);

    lv_max_pensionable_earnings    number;
    lv_qpp_pensionable_earnings    number;
    lv_cpp_pensionable_earnings    number;
    lv_total_pensionable_earnings  number;
    lv_taxable_benefit_with_no_rem number;

    lv_non_box_lookup        number;

  /* !!Report type 'RL1' or 'RL2' in the GRE might have
     to be checked too-Check */

  cursor c_all_gres(asgactid number) is
  select hoi.organization_id ,
         hoi.org_information5
  from   pay_payroll_actions ppa,
         pay_assignment_actions paa,
         hr_organization_information hoi
  where  paa.assignment_action_id    = asgactid
  and    ppa.payroll_action_id       = paa.payroll_action_id
  and    hoi.org_information2        =
                 pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                            ppa.legislative_parameters)
  and    hoi.org_information_context = 'Canada Employer Identification'
  and    hoi.org_information5 in ('T4/RL1','T4A/RL1')
  order by organization_id;

  cursor c_all_gres_for_footnote(asgactid number) is
  select hoi.organization_id ,
         hoi.org_information5
  from   pay_payroll_actions ppa,
         pay_assignment_actions paa,
         hr_organization_information hoi
  where  paa.assignment_action_id    = asgactid
  and    ppa.payroll_action_id       = paa.payroll_action_id
  and    hoi.org_information2        =
                 pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                            ppa.legislative_parameters)
  and    hoi.org_information_context = 'Canada Employer Identification'
  and    hoi.org_information5 in ('T4/RL1','T4A/RL1')
  order by organization_id;

  /* !!To calculate CPP withheld select all the GREs
     the person has worked in */

  /* 11510 changes for bug#3356533, replaced the old query for
     cursor c_all_gres_for_person with this to improve performance.
     Using assignment_id instead of assignment_action_id
  */
  cursor c_all_gres_for_person(cp_asg_id number,cp_eff_date date) is
  select distinct paa.tax_unit_id
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_all_assignments_f paf
  where paa.assignment_id = cp_asg_id
  and   paf.assignment_id = cp_asg_id
  and   paf.assignment_id = paa.assignment_id
  and   paa.action_status = 'C'
  and   ppa.payroll_action_id = paa.payroll_action_id
  and   ppa.effective_date <= cp_eff_date
  and   ppa.action_type in ('R', 'Q')
  and   ppa.effective_date between paf.effective_start_date and paf.effective_end_date
  and exists ( select 1 from pay_run_types_f prt
               where prt.legislation_code = 'CA'
               and   prt.run_type_id = paa.run_type_id
               and   prt.run_method  <> 'C' );

  /* Get the jurisdiction code of all the cities
     for the person_id corresponding to the
     assignment_id . Take it from pay_action_context table. */

  cursor c_get_province is
  select distinct context_value
  from   pay_action_contexts pac
  where  pac.assignment_id = l_asgid;

  cursor  c_footnote_info(p_balance_name varchar2) is
  select distinct pet.element_information19,
         pbt1.balance_name
  from   pay_balance_feeds_f pbf,
         pay_balance_types pbt,
         pay_balance_types pbt1,
         pay_input_values_f piv,
         pay_element_types_f pet,
         fnd_lookup_values   flv
  where  pbt.balance_name          = p_balance_name
  and    pbf.balance_type_id       = pbt.balance_type_id
  and    pbf.input_value_id        = piv.input_value_id
  and    piv.element_type_id       = pet.element_type_id
  and    pbt1.balance_type_id      = pet.element_information10
  and    pet.business_group_id     = l_business_group_id
  and    pet.element_information19 = flv.lookup_code
  and    flv.lookup_type           = 'PAY_CA_RL1_FOOTNOTES'
  --bug 5558604 starts
  and    flv.enabled_flag          = 'Y'
  and    l_date_earned between nvl(flv.start_Date_active,l_date_earned)
         and  nvl(flv.end_date_Active,l_date_earned)
  --bug 5558604 starts
  and    flv.language              = userenv('LANG')
  order by pet.element_information19;

  cursor c_get_addr is
  select addr.address_line1,
         addr.address_line2,
         addr.address_line3,
         addr.town_or_city,
         decode(addr.country,'CA', addr.region_1 , 'US' , addr.region_2 , ' '),
         replace(addr.postal_code,' '),
         addr.telephone_number_1,
         country.territory_code
  from   per_addresses          addr,
         fnd_territories_vl     country
  where addr.person_id      = l_person_id
  and	addr.primary_flag   = 'Y'
  and   l_date_earned  between nvl(addr.date_from, l_date_earned)
                          and  nvl(addr.date_to, l_date_earned)
  and	country.territory_code    = addr.country
  order by date_from desc;

  /* Modified the cursor to fix bug#3641353 and added
     action_type 'B' to consider Balance Adjustments */
  cursor cur_non_box_mesg( cp_asgactid in number,
                           cp_eff_date in date,
                           cp_start_date in date ) is
   select /*+ index (PET PAY_ELEMENT_TYPES_F_PK) */  distinct prrv1.result_value,
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
  where arch_paa.assignment_action_id = cp_asgactid
  and   arch_ppa.payroll_action_id    = arch_paa.payroll_action_id
  and   hou.business_group_id  + 0       = arch_ppa.business_group_id
  and   hou.organization_id           = hoi.organization_id
  and   hoi.org_information2          =  pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                                         arch_ppa.legislative_parameters)
  and   hoi.org_information_context   = 'Canada Employer Identification'
  and   run_paa.assignment_id = arch_paa.assignment_id
  and   run_paa.tax_unit_id           = hou.organization_id
  and   run_ppa.payroll_action_id     =  run_paa.payroll_action_id
  and   run_ppa.action_type           in ( 'R', 'Q','B' )
  and   run_ppa.effective_date between cp_start_date and cp_eff_date
  and   run_paa.action_status         = 'C'
  and   pet.element_name          = lv_footnote_element --'RL1 NonBox Footnotes'
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
  and   cp_eff_date
               between arch_paf.effective_start_date
                   and arch_paf.effective_end_date
  and   all_paf.person_id     = arch_paf.person_id
  and   cp_eff_date
               between all_paf.effective_start_date
                   and all_paf.effective_end_date
  and   run_paa.assignment_id     = all_paf.assignment_id
  and exists (select 1
              from pay_action_contexts pac,ff_contexts ffc
              where ffc.context_name          = 'JURISDICTION_CODE'
              and   pac.context_id + 0        = ffc.context_id
              and   pac.assignment_id         = run_paa.assignment_id
              and   pac.context_value         = 'QC')
  order by 1;                                        --Bug 6853279
 /* and exists (select 1                             --Bug 7555410
              from hr_lookups hrl
              where hrl.lookup_code=prrv1.result_value
              and lookup_type='PAY_CA_RL1_NONBOX_FOOTNOTES'
              and cp_eff_date
                   between nvl(hrl.start_date_active,to_date('1900/01/01','YYYY/MM/DD'))
                   and nvl(hrl.end_date_active,to_date('4712/12/31','YYYY/MM/DD'))) */


 /*For performance of non box footnote amounts - bug 8227027 */
 cursor c_non_box_lookup is
            select 1
              from hr_lookups hrl
              where hrl.lookup_code=l_messages
              and lookup_type='PAY_CA_RL1_NONBOX_FOOTNOTES'
              and p_effective_date
                   between nvl(hrl.start_date_active,to_date('1900/01/01','YYYY/MM/DD'))
                   and nvl(hrl.end_date_active,to_date('4712/12/31','YYYY/MM/DD'));


/* New cursors added for Provincial YE Amendment Pre-Process Validation */
  CURSOR c_get_fapp_prov_emp(cp_assignment_action_id number) IS
  select fai.value
  from   ff_archive_items   fai,
         ff_database_items  fdi
  where  fdi.user_entity_id = fai.user_entity_id
  and    fai.context1  = cp_assignment_action_id
  and    fdi.user_name = 'CAEOY_RL1_PROVINCE_OF_EMPLOYMENT';

  CURSOR c_get_fapp_lkd_actid_rtype(cp_locked_actid number) IS
  select ppa.report_type
  from pay_payroll_actions ppa,pay_assignment_actions paa
  where paa.assignment_action_id = cp_locked_actid
  and ppa.payroll_action_id = paa.payroll_action_id;

  CURSOR c_get_fapp_locked_action_id(cp_locking_act_id number) IS
  select locked_action_id
  from pay_action_interlocks
  where locking_action_id = cp_locking_act_id;

  CURSOR c_get_preprinted_form_no (cp_person_id  number,
                                   cp_pre_org_id number) IS
  select pei_information5,
         pei_information6,
         pei_information7
  from  per_people_extra_info
  where person_id        = cp_person_id
  and   pei_information6 = to_char(cp_pre_org_id)
  and   pei_information_category = 'PAY_CA_RL1_FORM_NO';

  /* 11510 Changes Bug#3356533. Changed the cursor to get max asgact_id
     based on person_id, to fix bug#3638928. */
  CURSOR c_get_max_asgactid_jd(cp_person_id number,
                              cp_tax_unit_id number,
                              cp_period_start date,
                              cp_period_end date
                             ) IS
  select /*+ Ordered */ paa.assignment_action_id
  from          per_all_people_f ppf,
       per_all_assignments_f      paf,
       pay_assignment_actions     paa,
       pay_payroll_actions        ppa,
       pay_action_classifications pac,
       pay_action_contexts pac1,
       ff_contexts         fc
  where ppf.person_id = cp_person_id
   and paf.person_id = ppf.person_id
   and paf.assignment_id = paa.assignment_id
   and paa.tax_unit_id   = cp_tax_unit_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and ppa.effective_date between cp_period_start and cp_period_end
   and ppa.effective_date between ppf.effective_start_date
                              and ppf.effective_end_date
   and ppa.effective_date between paf.effective_start_date
                              and paf.effective_end_date
   and ppa.action_type = pac.action_type
   and pac.classification_name = 'SEQUENCED'
   AND pac1.assignment_action_id = paa.assignment_action_id
   AND pac1.context_id     = fc.context_id
   AND fc.context_name    = 'JURISDICTION_CODE'
   AND pac1.context_value  = 'QC'
   order by paa.action_sequence desc;

  /* 11510 changes for bug#3356533.  Changed the cursor to get max asgact_id
     based on person_id, to fix bug#3638928. */
   CURSOR c_get_max_asgactid(cp_person_id number,
                             cp_tax_unit_id number,
                             cp_period_start date,
                             cp_period_end date) IS
   select paa.assignment_action_id
   from pay_assignment_actions     paa,
        per_all_assignments_f      paf,
        per_all_people_f ppf,
        pay_payroll_actions        ppa,
        pay_action_classifications pac
   where ppf.person_id = cp_person_id
   and paf.person_id =  ppf.person_id
   and paf.assignment_id = paa.assignment_id
   and paa.tax_unit_id   = cp_tax_unit_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and ppa.effective_date between cp_period_start and cp_period_end
   and ppa.effective_date between ppf.effective_start_date
       and ppf.effective_end_date
   and ppa.effective_date between paf.effective_start_date
       and paf.effective_end_date
   and ppa.action_type = pac.action_type
   and pac.classification_name = 'SEQUENCED'
   order by paa.action_sequence desc;


  BEGIN

    --hr_utility.trace_on(null,'RL1');
    hr_utility.set_location ('archive_data',1);
    hr_utility.trace('getting assignment');

    l_negative_balance_exists   := 'N';
    lv_qpp_pensionable_earnings := 0;
    l_step := 1;

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
    FROM   pay_assignment_actions aa
    WHERE   aa.assignment_action_id = p_assactid;

    /* If the chunk of the assignment is same as the minimun chunk
       for the payroll_action_id and the gre data has not yet been
       archived then archive the gre data i.e. the employer data */

    if l_chunk = g_min_chunk and g_archive_flag = 'N' then

       hr_utility.trace('eoy_archive_data archiving employer data');
       hr_utility.trace('l_payroll_action_id '|| to_char(l_payroll_action_id));

       select pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                        legislative_parameters),
              business_group_id
       into   l_pre_organization_id,l_business_group_id
       from   pay_payroll_actions
       where  payroll_action_id = l_payroll_action_id;

       eoy_archive_gre_data(p_payroll_action_id =>l_payroll_action_id,
                            p_pre_organization_id=>l_pre_organization_id);

       hr_utility.trace('eoy_archive_data archived employer data');

    end if;

    hr_utility.set_location ('archive_data',2);

    hr_utility.trace('assignment '|| to_char(l_asgid));
    hr_utility.trace('date_earned '|| to_char(l_date_earned));
    hr_utility.trace('tax_unit_id '|| to_char(l_tax_unit_id));
    hr_utility.trace('business_group_id '|| to_char(l_business_group_id));

    /* Derive the beginning and end of the effective year */

    hr_utility.trace('getting begin and end dates');

    l_step := 2;

    l_year_start := trunc(p_effective_date, 'Y');
    l_year_end   := add_months(trunc(p_effective_date, 'Y'),12) - 1;

    hr_utility.trace('year start '|| to_char(l_year_start));
    hr_utility.trace('year end '|| to_char(l_year_end));

    if to_number(to_char(l_year_end,'YYYY')) > 2005 then
       lv_footnote_element := 'RL1 Non Box Footnotes';
    else
       lv_footnote_element := 'RL1 NonBox Footnotes';
    end if;

    /* Initialise the PL/SQL table before populating it */

    hr_utility.trace('Initialising Pl/SQL table');

    l_step := 3;

    /* Get the context_id for 'Jurisdiction' from ff_contexts */

    l_step := 5;

    select context_id
    into   l_jursd_context_id
    from   ff_contexts
    where  context_name = 'JURISDICTION_CODE';

    select context_id
    into   l_taxunit_context_id
    from   ff_contexts
    where  context_name = 'TAX_UNIT_ID';

    l_step := 6;

    l_jurisdiction := 'QC';

    l_step := 12;

    l_count := l_count + 1;

    hr_utility.trace('archiving CAEOY_RL1_PROVINCE_OF_EMPLOYMENT');

    ff_archive_api.create_archive_item(
     /*p_validate      => 'TRUE' */
       p_archive_item_id       => l_archive_item_id
      ,p_user_entity_id        =>
                        get_user_entity_id('CAEOY_RL1_PROVINCE_OF_EMPLOYMENT')
      ,p_archive_value         => l_jurisdiction
      ,p_archive_type          => 'AAP'
      ,p_action_id             => p_assactid
      ,p_legislation_code      => 'CA'
      ,p_object_version_number => l_object_version_number
      ,p_some_warning          => l_some_warning
      );

     hr_utility.trace('archived caeoy_rl1_employment_province');

    /* We can archive the balance level dbis also because for employee level
       balances jurisdiction is always a context. */

    hr_utility.trace('max assignment_action_id : ' || to_char(l_aaid));

    pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',l_aaid);
    pay_balance_pkg.set_context('JURISDICTION_CODE', l_jurisdiction);

    hr_utility.trace('Archiving the balance dbi ' || l_jurisdiction);

    /* RL1 Slip number generation */

    begin

      select decode(hoi.org_information3,'Y',hoi.organization_id,
                                              hoi.org_information20)
      into   l_transmitter_name1
      from   pay_payroll_actions ppa,
             hr_organization_information hoi,
             hr_all_organization_units hou
      WHERE  hou.business_group_id = ppa.business_group_id
      and    hoi.organization_id = hou.organization_id
      and    hoi.org_information_context='Prov Reporting Est'
      and    hoi.organization_id =
                 pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                            ppa.legislative_parameters )
      and    ppa.payroll_action_id =  l_payroll_action_id
      and    hoi.org_information4  = 'P01';

      hr_utility.trace('l_transmitter ' || l_transmitter_name1);

      hr_utility.trace('3');

      if l_transmitter_name1 is not null then

          select to_number(target.ORG_INFORMATION18)
          into   l_rl1_last_slip_number
          from   hr_organization_information target
          where  target.organization_id = l_transmitter_name1
          and    target.org_information_context = 'Prov Reporting Est'
          and    target.ORG_INFORMATION3        = 'Y';

      else
          hr_utility.set_message(801,'PAY_74014_NO_TRANSMITTER_ORG');
          hr_utility.set_message_token('ORGIND','PRE');
          hr_utility.raise_error;
      end if;

      hr_utility.trace('2');

      select l_rl1_last_slip_number + pay_ca_eoy_rl1_s.nextval - 1
      into   l_rl1_curr_slip_number from dual;

      hr_utility.trace('1');

      select mod(l_rl1_curr_slip_number,7)
      into   l_rl1_slip_number_last_digit
      from   dual;

      hr_utility.trace('l_rl1_slip_number_last_digit : '||
                        l_rl1_slip_number_last_digit);

      l_rl1_slip_number := (l_rl1_curr_slip_number)||
                            l_rl1_slip_number_last_digit;

      hr_utility.trace('l_rl1_slip_number : ' || l_rl1_slip_number);

      hr_utility.trace('l_rl1_curr_slip_number : '||l_rl1_curr_slip_number);
    end;

    l_count := 0;

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_GROSS_EARNINGS_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'Gross Earnings';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_QPP_EE_WITHHELD_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'QPP EE Withheld';
    /**********************************************************/
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_PPIP_EE_WITHHELD_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'PPIP EE Withheld';
    /****************************tombi******************/
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_EI_EE_WITHHELD_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'EI EE Withheld';

    /* Quebec Income tax withheld */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_PROV_WITHHELD_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'PROV Withheld';

    /* Registered pension plan */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXD_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXD';

    /* Union Dues */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXF_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXF';

    /* Pensionable Earnings under Quebec pension plan */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_QPP_EE_TAXABLE_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'QPP EE Taxable';

    /**********************************************/
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_PPIP_EE_TAXABLE_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'PPIP EE Taxable';
    /***************tombi************************/

    /* QPP EE Basic Exemption ( EOY 2001 for YE Exemption Report ) */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_QPP_BASIC_EXEMPTION_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'QPP EE Basic Exemption';

    /* QPP Exempt  ( EOY 2001 for YE Exemption Report ) */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_QPP_EXEMPT_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'QPP Exempt';

    /* QPP Reduced Subject for Box G (EOY 2004) */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_QPP_REDUCED_SUBJECT_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'QPP Reduced Subject';

    /* PPIP Reduced Subject for Box I (EOY 2006) */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_PPIP_REDUCED_SUBJECT_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'PPIP Reduced Subject';

    /* Meals and accommodations */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXV_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXV';
    --l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXH_PER_JD_YTD';
    --l_balance_type_tab(l_count)     := 'RL1_BOXH';

    /* Use of a motor vehicle for personal purpose */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXW_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXW';
    --l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXI_PER_JD_YTD';
    --l_balance_type_tab(l_count)     := 'RL1_BOXI';

    /* Contribution paid by the employer by the employer under
       a private health */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXJ_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXJ';

    /* Trips made by residents of designated remote areas */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXK_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXK';

    /* Other Benefits */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXL_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXL';

    /* Commissions included in amount in box A */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXM_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXM';

    /* Charitable Donations */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXN_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXN';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RA_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RA';
    l_count_start_for_boxo          := l_count;

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RB_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RB';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RC_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RC';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RD_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RD';

    /* Bug 7555410 */
    IF ( to_number(to_char(l_year_end,'YYYY')) < 2008) then
      l_count := l_count + 1;
      l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RF_PER_JD_YTD';
      l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RF';
    END IF;

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RG_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RG';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RH_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RH';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RI_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RI';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RJ_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RJ';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RK_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RK';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RL_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RL';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RM_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RM';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RN_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RN';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RO_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RO';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RP_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RP';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RQ_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RQ';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RR_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RR';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RS_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RS';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RT_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RT';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RU_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RU';

    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RV_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RV';

    --Bug 6525899. Added check to not to archive this balance from 2007
    IF ( to_number(to_char(l_year_end,'YYYY')) < 2007) then
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RW_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RW';
    END IF;
   --End  6525899

    /* Added balance RL1_BOXO_AMOUNT_RX for Bug 7555410 */
    IF ( to_number(to_char(l_year_end,'YYYY')) >= 2008) then
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_RX_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_RX';
    END IF;

    /* Added balance RL1_BOXO_AMOUNT_CA for Bug 9135372 */
    IF ( to_number(to_char(l_year_end,'YYYY')) >= 2009) then
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_CA_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_CA';
    END IF;

    /* Added balance RL1_BOXO_AMOUNT_CB for Bug 9135372 */
    IF ( to_number(to_char(l_year_end,'YYYY')) >= 2009) then
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_CB_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_CB';
    END IF;

    /* Added balance RL1_BOXO_AMOUNT_CC for Bug 9135372 */
    IF ( to_number(to_char(l_year_end,'YYYY')) >= 2009) then
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXO_AMOUNT_CC_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXO_AMOUNT_CC';
    END IF;

    l_count_end_for_boxo := l_count;

    /* Contributions to a multi-employer insurance plan */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXP_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXP';

    /* Deferred salary or wages */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXQ_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXQ';

    /* Tax exempt income paid to an Indian */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXR_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'PROV STATUS INDIAN Subject';

    /* Tips received */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXS_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXS';

    /* Tips allocated */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXT_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXT';

    /* Phased retirement */
    l_count := l_count + 1;
    l_user_entity_name_tab(l_count) := 'CAEOY_RL1_BOXU_PER_JD_YTD';
    l_balance_type_tab(l_count)     := 'RL1_BOXU';

    hr_utility.trace('Assignment action id is ' || to_char(p_assactid));

    for i in 1 .. l_count
    loop
        hr_utility.trace('Initialising values');
        l_user_entity_value_tab(i) := 0;
    end loop;

    open c_all_gres(p_assactid);

    loop

      hr_utility.trace('Fetching all GREs');
      fetch c_all_gres into l_tax_unit_id,l_reporting_type;
      exit when c_all_gres%NOTFOUND;

      hr_utility.trace('Tax unit id is ' || to_char(l_tax_unit_id));
      hr_utility.trace('Asgid is ' || to_char(l_asgid));
      hr_utility.trace('Person id is ' || lv_serial_number);
      hr_utility.trace('Reporting_type is ' || l_reporting_type);
      hr_utility.trace('Effective date is  ' || to_char(p_effective_date));

      begin
        /* Removed select stmt to get max asgact_id and replaced it with
           cursor c_get_max_asgactid_jd. 11510 Changes Bug#3356533.
           Changed the cursor to get max asgact_id based on person_id to
           fix bug#3638928 */
        open c_get_max_asgactid_jd(to_number(lv_serial_number),
                                  l_tax_unit_id,
                                  l_year_start,
                                  l_year_end);
        fetch c_get_max_asgactid_jd into l_aaid;
        close c_get_max_asgactid_jd;

         hr_utility.trace('l_aaid  is ' || to_char(l_aaid));
         hr_utility.trace('l_count  is ' || to_char(l_count));

         ln_no_gross_earnings := ln_no_gross_earnings +
               nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                      ('RL1 No Gross Earnings',
                       'YTD' ,
                        l_aaid,
                        l_asgid,
                        NULL,
                        'PER' ,
                        l_tax_unit_id,
                        l_business_group_id,
                        'QC'
                       ),0);

         l_no_of_payroll_run := l_no_of_payroll_run + 1;

         select target1.business_group_id
         into   l_business_group_id
         from   hr_all_organization_units target1
         where  target1.organization_id = l_tax_unit_id;

         if l_tax_unit_id <> l_prev_tax_unit_id  or
            l_prev_tax_unit_id is null then

            hr_utility.trace('l_business_group_id  is '||l_business_group_id);

            pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
            pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',l_aaid);
            Pay_balance_pkg.set_context('JURISDICTION_CODE', 'QC');

            for i in 1 .. l_count
            loop

              hr_utility.trace('l_balance_type  is ' || l_balance_type_tab(i));
              hr_utility.trace('i is ' || i);

              /* T4A earnings should not go to BOX A of RL1 */

/* bug 5768390
              if l_reporting_type = 'T4A/RL1' and
                 l_balance_type_tab(i) = 'Gross Earnings'
              then
                null;
              else
bug 5768390 */

                /*     l_user_entity_value_tab(i) := 0;  */

                if l_balance_type_tab(i) = 'Gross Earnings' then

                   fed_result :=
                     nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                           ('Taxable Benefits for Federal',
                            'YTD' ,
                             l_aaid,
                             l_asgid ,
                             NULL,
                             'PER' ,
                             l_tax_unit_id,
                             l_business_group_id,
                             'QC'
                            ),0);

                   non_taxable_earnings :=
                     nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                           ('RL1 Non Taxable Earnings',
                            'YTD' ,
                             l_aaid,
                             l_asgid ,
                             NULL,
                             'PER' ,
                             l_tax_unit_id,
                             l_business_group_id,
                             'QC'
                            ),0);

                   hr_utility.trace('Fed Result = ' || fed_result);
                   hr_utility.trace('Non Taxable Earnings = ' || non_taxable_earnings);
                else
                   fed_result := 0;
                   non_taxable_earnings := 0;
                   hr_utility.trace('Fed Result = ' || fed_result);
                   hr_utility.trace('Non Taxable Earnings = ' || non_taxable_earnings);
                end if;

                ln_balance_value :=
                      nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                             ( l_balance_type_tab(i),
                              'YTD' ,
                               l_aaid,
                               l_asgid ,
                               NULL,
                               'PER' ,
                               l_tax_unit_id,
                               l_business_group_id,
                               'QC'
                              ),0);

                /* Get QPP Pensionable Earnings for use when processing nonbox footnotes */
                if l_balance_type_tab(i) = 'QPP EE Taxable' then
                   lv_qpp_pensionable_earnings := lv_qpp_pensionable_earnings + ln_balance_value;
                end if;

                hr_utility.trace('Balance value is '|| ln_balance_value);

                if ln_balance_value  <> 0 then
                   l_has_been_paid := 'Y';
                   if l_balance_type_tab(i) = 'PROV STATUS INDIAN Subject' then
                      ln_status_indian := ln_status_indian +
                                          ln_balance_value;
                   end if;
                end if;

                if instr(l_balance_type_tab(i), 'RL1_BOXO') > 0 and
                   ln_balance_value  <> 0 then

/* bug 5768390
                   if l_reporting_type <> 'T4A/RL1' then
   bug 5768390 */
                      ln_boxo_exclude_from_boxa  := ln_boxo_exclude_from_boxa +
                                                    ln_balance_value;
/* bug 5768390
                   end if;
   bug 5768390 */


                   hr_utility.trace('REPORT_TYPE '||l_reporting_type);
                   hr_utility.trace('TAX_UNIT_ID '||l_tax_unit_id);
                   hr_utility.trace('ASSIGNMENT_ACTION_ID '||l_aaid);
                   hr_utility.trace('Assignemnt ID '|| l_asgid);
                   hr_utility.trace('ln_boxo_exclude_from_boxa '||
                                  ln_boxo_exclude_from_boxa);

                end if;
                l_user_entity_value_tab(i) := l_user_entity_value_tab(i) +
                                              ln_balance_value           -
                                              fed_result                 -
                                              non_taxable_earnings;

/* bug 5768390
              end if;
   bug 5768390 */

              hr_utility.trace('archive value is '||l_user_entity_value_tab(i));
              l_prev_tax_unit_id  :=  l_tax_unit_id ;

            end loop;
         end if;

         exception
           when no_data_found then
           hr_utility.trace('This Tax unit id has no payroll run, so skip it');
      end;
    end loop;
    close c_all_gres;

    hr_utility.trace('l_no_of_payroll_run is ' || l_no_of_payroll_run);

    if ((l_no_of_payroll_run > 0) and
        ((l_has_been_paid = 'Y') or (ln_no_gross_earnings <> 0)) ) then

--     hr_utility.trace_on('Y','RL1');
       for i in 1 .. l_count
       loop

         hr_utility.trace('in the create_archive_item loop');
         hr_utility.trace('archive item is ' || l_user_entity_name_tab(i));
         hr_utility.trace('archive value is ');

         /* Archiving footnotes */

         old_l_footnote_code :=  NULL;
         old_balance_type_tab :=  NULL;

         hr_utility.trace('Balance name is '|| l_balance_type_tab(i));
         hr_utility.trace('value tab  is '|| l_user_entity_value_tab(i));

         if l_user_entity_value_tab(i) <> 0 then

            if l_balance_type_tab(i) = 'PROV STATUS INDIAN Subject' then
               l_footnote_balance_type_tab := 'RL1_BOXR';
            elsif l_balance_type_tab(i) = 'Gross Earnings' then
               l_footnote_balance_type_tab := 'RL1_BOXA';
               if ln_status_indian <> 0 then
                  l_user_entity_value_tab(i) := l_user_entity_value_tab(i) -
                                                ln_status_indian;
                  ln_status_indian := 0;
               end if;
               if ln_boxo_exclude_from_boxa <> 0 then
                  l_user_entity_value_tab(i) := l_user_entity_value_tab(i) -
                                                ln_boxo_exclude_from_boxa;
                  ln_boxo_exclude_from_boxa := 0;
               end if;
            else
               l_footnote_balance_type_tab := l_balance_type_tab(i);
            end if;

            if l_footnote_balance_type_tab in ('RL1_BOXA',
                                               'RL1_BOXD',
                                               'RL1_BOXK',
                                               'RL1_BOXR',
                                               'RL1_BOXQ',
                                               'RL1_BOXO_AMOUNT_RL',
                                               'RL1_BOXO_AMOUNT_RN') then
               begin

                 if l_footnote_balance_type_tab = 'RL1_BOXR' then
                    lv_footnote_bal := 'PROV STATUS INDIAN Subject';
                 elsif l_footnote_balance_type_tab = 'RL1_BOXA' then
                    lv_footnote_bal := 'Gross Earnings';
                 else
                    lv_footnote_bal := l_footnote_balance_type_tab;
                 end if;

                 open c_footnote_info(lv_footnote_bal);
                 loop
                   fetch c_footnote_info into l_footnote_code,
                                              l_footnote_balance;
                   exit when c_footnote_info%NOTFOUND;

                   hr_utility.trace('l_footnote_amount_balance is '||
                                     l_footnote_balance);
                   hr_utility.trace('l_footnote_code is '||
                                     l_footnote_code);
                   hr_utility.trace('after fetch if l_footnote_amount_ue is '||
                                     l_footnote_amount_ue);

                  /* Must ensure that BOXR is only used with footnote code 14 */
                  l_boxr_flag := 'Y';
                  if ((l_footnote_balance_type_tab = 'RL1_BOXR') and
                      (l_footnote_code <> '14')) then
                      l_boxr_flag := 'N';
                  end if;

                  if l_boxr_flag = 'Y' then

                     if ( l_footnote_code <>  old_l_footnote_code or
                          old_l_footnote_code is null )
                     then
                        hr_utility.trace('old_l_footnote_code is '||
                                          nvl(old_l_footnote_code,'NULL'));
                        if old_l_footnote_code is not null then

                           l_footnote_amount_ue := 'CAEOY_' ||old_balance_type_tab
                                ||'_'||old_l_footnote_code||'_AMT_PER_JD_YTD';

                           if get_footnote_user_entity_id(l_footnote_amount_ue)<>0
                              and l_footnote_amount <> 0
                           then
                              ff_archive_api.create_archive_item(
                                p_archive_item_id        => l_archive_item_id
                               ,p_user_entity_id         =>
                                  get_footnote_user_entity_id(l_footnote_amount_ue)
                               ,p_archive_value          => l_footnote_amount
                               ,p_archive_type           => 'AAP'
                               ,p_action_id              => p_assactid
                               ,p_legislation_code       => 'CA'
                               ,p_object_version_number  => l_object_version_number
                               ,p_context_name1          => 'JURISDICTION_CODE'
                               ,p_context1               => 'QC'
                               ,p_some_warning           => l_some_warning
                              );

                              if l_footnote_amount < 0 then
                                 l_negative_balance_exists := 'Y';
                              end if;

                           end if;

                        end if;

                        l_footnote_amount := 0;
                        old_l_footnote_code :=  l_footnote_code ;
                        old_balance_type_tab :=  l_footnote_balance_type_tab ;
                        l_footnote_amount_ue := 'CAEOY_' ||
                                    l_footnote_balance_type_tab||
                                    '_'||l_footnote_code||'_AMT_PER_JD_YTD';
                        hr_utility.trace('l_footnote_amount_ue is '||
                                          l_footnote_amount_ue);
                     end if;

                     l_footnote_amount_ue := 'CAEOY_' ||
                                    l_footnote_balance_type_tab||
                                    '_'||l_footnote_code||'_AMT_PER_JD_YTD';
                     l_prev_tax_unit_id := NULL;

                     /* get the footnote_balance */
                     open c_all_gres_for_footnote(p_assactid);
                     loop
                       hr_utility.trace('Fetching all GREs');
                       fetch c_all_gres_for_footnote into l_ft_tax_unit_id,
                                                          l_ft_reporting_type;
                       exit when c_all_gres_for_footnote%NOTFOUND;

                       hr_utility.trace('Tax unit id is ' || l_ft_tax_unit_id);
                       hr_utility.trace('Asgid is ' || l_asgid);
                       hr_utility.trace('Reporting_type is ' || l_ft_reporting_type);
                       hr_utility.trace('Effective date is '|| p_effective_date);
                       begin
                         /* Removed select stmt to get max asgact_id and replaced
                            it with cursor c_get_max_asgactid_jd, reusing the same
                            cursor used above. 11510 Changes Bug#3356533. Changed
                            cursor to get max asg_act_id based on person_id to
                            fix bug#3638928. */
                          open c_get_max_asgactid_jd(to_number(lv_serial_number),
                                                     l_ft_tax_unit_id,
                                                     l_year_start,
                                                     l_year_end);
                          fetch c_get_max_asgactid_jd into l_ft_aaid;
                          close c_get_max_asgactid_jd;

                          hr_utility.trace('l_aaid  is ' || l_ft_aaid);
                          hr_utility.trace('l_count  is ' || l_count);

                          l_no_of_payroll_run := l_no_of_payroll_run + 1;

                          select target1.business_group_id
                          into   l_business_group_id
                          from   hr_all_organization_units target1
                          where  target1.organization_id = l_ft_tax_unit_id;

                          if ( l_ft_tax_unit_id <> l_prev_tax_unit_id  or
                               l_prev_tax_unit_id is null )
                          then
                             hr_utility.trace('l_business_group_id  is ' ||
                                               l_business_group_id);

                             pay_balance_pkg.set_context('TAX_UNIT_ID',
                                                         l_ft_tax_unit_id);
                             pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',
                                                         l_ft_aaid);
                             pay_balance_pkg.set_context('JURISDICTION_CODE', 'QC');

                             l_footnote_amount := l_footnote_amount +
                               nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                              ( l_footnote_balance,
                               'YTD' ,
                                l_ft_aaid,
                                l_asgid ,
                                NULL,
                                'PER' ,
                                l_ft_tax_unit_id,
                                l_business_group_id,
                                'QC'
                               ),0) ;
                          end if;

                          l_prev_tax_unit_id  :=  l_ft_tax_unit_id ;
                          exception
                          when no_data_found then
                          hr_utility.trace('This Tax unit id has no payroll run,'||
                                           ' so skip it');
                        end;
                      end loop;
                      close c_all_gres_for_footnote;

                    /*  end of getting balnce */

                       l_footnote_amount := l_footnote_amount + l_value ;

                       if l_value <> 0 then
                          l_no_of_fn_codes := l_no_of_fn_codes + 1;
                       end if;

                     end if;  /* l_boxr_flag */

                 end loop;  /* c_footnote_info loop */
                 close c_footnote_info;

                 hr_utility.trace('before archiving l_footnote_amount_ue is '||
                                  l_footnote_amount_ue);

                 if get_footnote_user_entity_id(l_footnote_amount_ue) <> 0
                    and l_footnote_amount <> 0 then

                    ff_archive_api.create_archive_item(
                      p_archive_item_id       => l_archive_item_id
                     ,p_user_entity_id         =>
                        get_footnote_user_entity_id(l_footnote_amount_ue)
                     ,p_archive_value          => l_footnote_amount
                     ,p_archive_type           => 'AAP'
                     ,p_action_id              => p_assactid
                     ,p_legislation_code       => 'CA'
                     ,p_object_version_number  => l_object_version_number
                     ,p_context_name1          => 'JURISDICTION_CODE'
                     ,p_context1               => 'QC'
                     ,p_some_warning           => l_some_warning
                    );

                    if l_footnote_amount < 0 then
                       l_negative_balance_exists := 'Y';
                    end if;

                    l_footnote_amount := 0;
                    l_footnote_amount_ue := null;
                  end if;
               end;
            end if;
         end if;

         /* End of footnote archiving */

         /* archive the box balances */
          hr_utility.trace('here1');
	  hr_utility.trace('l_archive_item_id ='|| l_archive_item_id);
	  hr_utility.trace('l_user_entity_name_tab(i) ='|| l_user_entity_name_tab(i));
	  hr_utility.trace('l_user_entity_value_tab(i) ='|| l_user_entity_value_tab(i));
	  hr_utility.trace('p_assactid ='|| p_assactid);
	  hr_utility.trace('l_object_version_number ='|| l_object_version_number);
	 -- hr_utility.trace('l_some_warning ='|| l_some_warning);
         ff_archive_api.create_archive_item(
           /*    p_validate         => 'TRUE' */
           p_archive_item_id        => l_archive_item_id
          ,p_user_entity_id         =>
                     get_user_entity_id(l_user_entity_name_tab(i))
          ,p_archive_value          => l_user_entity_value_tab(i)
          ,p_archive_type           => 'AAP'
          ,p_action_id              => p_assactid
          ,p_legislation_code       => 'CA'
          ,p_object_version_number  => l_object_version_number
          ,p_context_name1          => 'JURISDICTION_CODE'
          ,p_context1               => 'QC'
          ,p_some_warning           => l_some_warning
          );
          hr_utility.trace('after the call');
         if l_user_entity_value_tab(i) < 0 then
            l_negative_balance_exists := 'Y';
         end if;

       end loop;

       /* Archive BOXO, which is sum of all the individual
          balances under BOXO, also determine the correct
          BOXO code that needs to be archived */

       l_user_entity_value_tab_boxo := 0;
       l_count_for_boxo_code        := 0;
       l_user_entity_code_tab_boxo  := NULL;

       for i in l_count_start_for_boxo..l_count_end_for_boxo
       loop

          if to_number(l_user_entity_value_tab(i)) <> 0 then

            l_count_for_boxo_code := l_count_for_boxo_code + 1;

            l_user_entity_code_tab_boxo :=
                   substr(l_user_entity_name_tab(i),23,2);

            l_user_entity_value_tab_boxo :=
                   l_user_entity_value_tab_boxo + l_user_entity_value_tab(i);
          end if;

       end loop;

       if l_count_for_boxo_code > 1 then
          l_user_entity_code_tab_boxo := 'RZ' ;
       end if;

       if l_user_entity_value_tab_boxo < 0 then
          l_negative_balance_exists := 'Y';
       end if;

       ff_archive_api.create_archive_item(
          p_archive_item_id        => l_archive_item_id
         ,p_user_entity_id         =>
                get_user_entity_id('CAEOY_RL1_BOXO_PER_JD_YTD')
         ,p_archive_value          => l_user_entity_value_tab_boxo
         ,p_archive_type           => 'AAP'
         ,p_action_id              => p_assactid
         ,p_legislation_code       => 'CA'
         ,p_object_version_number  => l_object_version_number
         ,p_context_name1          => 'JURISDICTION_CODE'
         ,p_context1               => 'QC'
         ,p_some_warning           => l_some_warning
         );

       ff_archive_api.create_archive_item(
         /*    p_validate           => 'TRUE' */
           p_archive_item_id        => l_archive_item_id
          ,p_user_entity_id         =>
                 get_user_entity_id('CAEOY_RL1_BOXO_CODE_PER_JD_YTD')
          ,p_archive_value          => l_user_entity_code_tab_boxo
          ,p_archive_type           => 'AAP'
          ,p_action_id              => p_assactid
          ,p_legislation_code       => 'CA'
          ,p_object_version_number  => l_object_version_number
          ,p_context_name1          => 'JURISDICTION_CODE'
          ,p_context1               => 'QC'
          ,p_some_warning           => l_some_warning
          );

       /* for box o archiving */

       /* archive RL1 slip number */

       ff_archive_api.create_archive_item(
         /*    p_validate          => 'TRUE' */
          p_archive_item_id        => l_archive_item_id
         ,p_user_entity_id         =>
                get_user_entity_id('CAEOY_RL1_SLIP_NUMBER')
         ,p_archive_value          => l_rl1_slip_number
         ,p_archive_type           => 'AAP'
         ,p_action_id              => p_assactid
         ,p_legislation_code       => 'CA'
         ,p_object_version_number  => l_object_version_number
         ,p_some_warning           => l_some_warning );

       /* archiving RL1 PDF Sequence Number -Bug 6768167*/

       ff_archive_api.create_archive_item(
          p_archive_item_id        => l_archive_item_id
         ,p_user_entity_id         =>
                get_user_entity_id('CAEOY_RL1_PDF_SEQ_NUMBER')
         ,p_archive_value          => gen_rl1_pdf_seq(p_assactid,
                                                      to_char(l_year_end,'YYYY'),
                                                      'QC',
                                                      'ARCHIVER')
         ,p_archive_type           => 'AAP'
         ,p_action_id              => p_assactid
         ,p_legislation_code       => 'CA'
         ,p_object_version_number  => l_object_version_number
         ,p_context_name1          => 'JURISDICTION_CODE'
         ,p_context1               => 'QC'
         ,p_some_warning           => l_some_warning
         );

       /* archive CPP amount  */

       /* 11510 changes done to c_all_gres_for_person cursor
          passing asgid instead of p_assactid */

       open c_all_gres_for_person(l_asgid,p_effective_date);

       result                         := 0;
       lv_cpp_pensionable_earnings    := 0;
       lv_taxable_benefit_with_no_rem := 0;

       loop
         hr_utility.trace('Fetching all GREs for the person');
         fetch c_all_gres_for_person into l_tax_unit_id;
         exit when c_all_gres_for_person%NOTFOUND;

         begin
           /* Removed the select stmt to get max asgact_id and replaced it
              with cursor c_get_max_asgactid. 11510 changes for bug#3356533.
              Changed the cursor to get max asg_act_id based on person_id
              to fix bug#3638928. */
            open c_get_max_asgactid(to_number(lv_serial_number),
                                    l_tax_unit_id,
                                    l_year_start,
                                    l_year_end);
            fetch c_get_max_asgactid into l_aaid1;
            close c_get_max_asgactid;

            result := result +
                   nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                               ('CPP EE Withheld',
                               'YTD' ,
                                l_aaid1,
                                l_asgid,
                                NULL,
                                'PER' ,
                                l_tax_unit_id,
                                l_business_group_id,
                                NULL),0);

            lv_cpp_pensionable_earnings := lv_cpp_pensionable_earnings +
                   nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                              ('CPP EE Taxable',
                               'YTD' ,
                                l_aaid1,
                                l_asgid,
                                NULL,
                                'PER' ,
                                l_tax_unit_id,
                                l_business_group_id,
                                NULL),0);

            lv_taxable_benefit_with_no_rem := lv_taxable_benefit_with_no_rem +
                   nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                              ('Taxable Benefit without Remuneration',
                               'YTD' ,
                                l_aaid1,
                                l_asgid ,
                                NULL,
                                'PER' ,
                                l_tax_unit_id,
                                l_business_group_id,
                                'QC'),0);

         end;
       end loop;
       close c_all_gres_for_person;
       hr_utility.trace('closed all GREs for the person');

       ff_archive_api.create_archive_item(
         /*    p_validate          => 'TRUE' */
          p_archive_item_id        => l_archive_item_id
         ,p_user_entity_id         =>
                get_user_entity_id('CAEOY_CPP_EE_WITHHELD_PER_YTD')
         ,p_archive_value          => result
         ,p_archive_type           => 'AAP'
         ,p_action_id              => p_assactid
         ,p_legislation_code       => 'CA'
         ,p_object_version_number  => l_object_version_number
         ,p_some_warning           => l_some_warning);

       /* End of CPP archiving */
       --hr_utility.trace_off;
    end if;

    hr_utility.trace('Out of province loop ');

    /* Archiving of Non-Box Footnotes */
    begin
      --hr_utility.trace_on('Y','NONBOX');

      /* Archive Nonbox footnote for Taxable Benefits that are processed on their
         own if the total pensionable earnings is less than the maximum bug# 3369317 */

      lv_max_pensionable_earnings   := 0;
      lv_total_pensionable_earnings := 0;

      select fnd_number.canonical_to_number(information_value)
      into lv_max_pensionable_earnings
      from pay_ca_legislation_info
      where information_type = 'MAX_CPP_EARNINGS'
      and   l_year_end  between  start_date
                        and      end_date;

      lv_total_pensionable_earnings := lv_cpp_pensionable_earnings +
                                       lv_qpp_pensionable_earnings;

      if ((lv_max_pensionable_earnings > lv_total_pensionable_earnings) and
          (lv_taxable_benefit_with_no_rem <> 0)) then

                 pay_action_information_api.create_action_information(
                 p_action_information_id => l_action_information_id_1,
                 p_object_version_number => l_object_version_number_1,
                 p_action_information_category => 'CA FOOTNOTES',
                 p_action_context_id           => p_assactid,
                 p_action_context_type         => 'AAP',
                 p_jurisdiction_code           => 'QC',
                 p_tax_unit_id                 => NULL,
                 p_effective_date              => l_year_end,
                 p_assignment_id               => l_asgid,
                 p_action_information1  => NULL,
                 p_action_information2  => NULL,
                 p_action_information3  => NULL,
                 p_action_information4  => '10',  /* QPP - Taxable benefit in kind */
                 p_action_information5  => lv_taxable_benefit_with_no_rem,
                 p_action_information6  => 'RL1',
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
                 p_action_information30 => NULL);

                 if lv_taxable_benefit_with_no_rem < 0 then
                    l_negative_balance_exists := 'Y';
                 end if;
      end if;

      l_total_mesg_amt := 0;
      l_mesg_amt       := 0;
      hr_utility.trace('l_year_start - '||l_year_start);
      open cur_non_box_mesg(p_assactid, p_effective_date,l_year_start);
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
        hr_utility.trace('effective date - '||p_effective_date);

        /* If the same Non Box footnote is processed more than
           once during the year,  then the sum of the associated
           amounts is archived */

        open c_non_box_lookup; -- Bug 8366352
        fetch c_non_box_lookup into lv_non_box_lookup;

        if (c_non_box_lookup%found) then
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
                   p_jurisdiction_code           => 'QC',
                   p_tax_unit_id                 => ln_prev_tax_unit_id,
                   p_effective_date              => ld_prev_eff_date,
                   p_assignment_id               => l_asgid,
                   p_action_information1  => NULL,
                   p_action_information2  => NULL,
                   p_action_information3  => NULL,
                   p_action_information4  => l_prev_messages,
                   p_action_information5  => l_total_mesg_amt,
                   p_action_information6  => 'RL1',
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

                   if l_total_mesg_amt < 0 then
                      l_negative_balance_exists := 'Y';
                   end if;

               end if;

               l_total_mesg_amt := l_mesg_amt;
          else
               l_total_mesg_amt := l_total_mesg_amt + l_mesg_amt;
          end if;
        --  Moved END IF condition to before END LOOP, bug 9177694

        /* end if; --c_non_box_lookup%found

        close c_non_box_lookup; */

        hr_utility.trace('l_total_mesg_amt - '||to_char(l_total_mesg_amt));

        l_prev_messages     := l_messages;
        ln_prev_tax_unit_id := ln_tax_unit_id;
        ld_prev_eff_date    := ld_eff_date;

        end if; --c_non_box_lookup%found

        close c_non_box_lookup;

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
                 p_jurisdiction_code           => 'QC',
                 p_tax_unit_id                 => ln_prev_tax_unit_id,
                 p_effective_date              => ld_prev_eff_date,
                 p_assignment_id               => l_asgid,
                 p_action_information1  => NULL,
                 p_action_information2  => NULL,
                 p_action_information3  => NULL,
                 p_action_information4  => l_prev_messages,
                 p_action_information5  => l_total_mesg_amt,
                 p_action_information6  => 'RL1',
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

                 if l_total_mesg_amt < 0 then
                    l_negative_balance_exists := 'Y';
                 end if;

             end if;

      end if;

      --hr_utility.trace_off;
    end;

    ff_archive_api.create_archive_item(
       p_archive_item_id        => l_archive_item_id
      ,p_user_entity_id         =>
             get_user_entity_id('CAEOY_RL1_NEGATIVE_BALANCE_EXISTS')
      ,p_archive_value          => l_negative_balance_exists
      ,p_archive_type           => 'AAP'
      ,p_action_id              => p_assactid
      ,p_legislation_code       => 'CA'
      ,p_object_version_number  => l_object_version_number
      ,p_context_name1          => 'JURISDICTION_CODE'
      ,p_context1               => 'QC'
      ,p_some_warning           => l_some_warning
     );

    l_count := 0;
    /* Similarly create archive data for employee surname,employee first name,
       employee initial, employee address ,city,province,country,postal code,
       SIN, employee number , business number .
       Not all of them has jurisdiction context.*/

    if ((l_no_of_payroll_run > 0) and
        ((l_has_been_paid = 'Y') or (ln_no_gross_earnings <> 0)) ) then
       begin

--code fix started for bug 5893569
/*
         select PEOPLE.person_id,
                PEOPLE.first_name,
                PEOPLE.middle_names,
                PEOPLE.last_name,
                PEOPLE.employee_number,
                PEOPLE.date_of_birth,
                replace(PEOPLE.national_identifier,' '),
                PEOPLE.pre_name_adjunct,
                NVL(PHONE.phone_number,PEOPLE.work_telephone)
          into l_person_id,
               l_first_name,
               l_middle_name,
               l_last_name,
               l_employee_number,
               l_date_of_birth,
               l_national_identifier,
               l_pre_name_adjunct,
               l_employee_phone_no
          from per_all_assignments_f  ASSIGN
              ,per_all_people_f       PEOPLE
              ,per_person_types       PTYPE
              ,per_phones             PHONE
              ,fnd_sessions           SES
         where   l_date_earned BETWEEN ASSIGN.effective_start_date
                                           AND ASSIGN.effective_end_date
         and     ASSIGN.assignment_id = l_asgid
         and	PEOPLE.person_id     = ASSIGN.person_id
         and     l_date_earned BETWEEN PEOPLE.effective_start_date
                                           AND PEOPLE.effective_end_date
         and	PTYPE.person_type_id = PEOPLE.person_type_id
         and     PHONE.parent_id (+) = PEOPLE.person_id
         and     PHONE.parent_table (+)= 'PER_ALL_PEOPLE_F'
         and     PHONE.phone_type (+)= 'W1'
         and     l_date_earned
                 BETWEEN NVL(PHONE.date_from,l_date_earned)
                  AND     NVL(PHONE.date_to,l_date_earned)
         and     SES.session_id       = USERENV('SESSIONID');
*/

         select PEOPLE.person_id,
                PEOPLE.first_name,
                PEOPLE.middle_names,
                PEOPLE.last_name,
                PEOPLE.employee_number,
                PEOPLE.date_of_birth,
                replace(PEOPLE.national_identifier,' '),
                PEOPLE.pre_name_adjunct
          into l_person_id,
               l_first_name,
               l_middle_name,
               l_last_name,
               l_employee_number,
               l_date_of_birth,
               l_national_identifier,
               l_pre_name_adjunct
         from   per_all_assignments_f  ASSIGN
                ,per_all_people_f       PEOPLE
         where   ASSIGN.assignment_id =l_asgid
         and     PEOPLE.person_id     = ASSIGN.person_id
         -- code fix started for 6440125
         and      l_date_earned BETWEEN ASSIGN.effective_start_date
                                           AND ASSIGN.effective_end_date
         and     l_date_earned BETWEEN PEOPLE.effective_start_date
                                          AND PEOPLE.effective_end_date;

        --code fix ended for 6440125
--code fix ended for bug 5893569

         exception
         when no_data_found then
            l_first_name := null;
            l_middle_name := null;
            l_last_name := null;
            l_employee_number := null;
            l_national_identifier := null;
            l_pre_name_adjunct := null;
            l_employee_phone_no := null;
            l_date_of_birth     := null;
       end;

       begin

         select max(date_start)
               ,max(actual_termination_date)
         into   l_hire_date
               ,l_termination_date
         from   per_periods_of_service
         where  person_id = l_person_id;

         exception
         when no_data_found then
              l_hire_date := null;
              l_termination_date := null;

       end;

       hr_utility.trace('Before counter of asgid '|| l_asgid);

       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_PERSON_ID';
       l_user_entity_value_tab(l_counter):= l_person_id;

       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_FIRST_NAME';
       l_user_entity_value_tab(l_counter):= l_first_name;

       hr_utility.trace('Before counter 2');
       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_LAST_NAME';
       l_user_entity_value_tab(l_counter):= l_last_name ;

       hr_utility.trace('Before counter 3');
       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_INITIAL';
       l_user_entity_value_tab(l_counter):= l_middle_name ;

       hr_utility.trace('Before counter 3');
       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_SIN';
       l_user_entity_value_tab(l_counter):= l_national_identifier;

       hr_utility.trace('Before counter 3');
       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_DATE_OF_BIRTH';
       l_user_entity_value_tab(l_counter):=
                                fnd_date.date_to_canonical(l_date_of_birth);

       hr_utility.trace('Before counter 3');
       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_HIRE_DATE';
       l_user_entity_value_tab(l_counter):=
                               fnd_date.date_to_canonical(l_hire_date);

       hr_utility.trace('Before counter 3');
       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_TERMINATION_DATE';
       l_user_entity_value_tab(l_counter):=
                               fnd_date.date_to_canonical(l_termination_date);

       hr_utility.trace('Before counter 3');
       l_counter := l_counter + 1;
       l_user_entity_name_tab(l_counter) := 'CAEOY_EMPLOYEE_NUMBER';
       l_user_entity_value_tab(l_counter):= l_employee_number;

       for i in 1 .. l_counter
       loop

         hr_utility.trace('inside create loop '||l_user_entity_value_tab(i));

         ff_archive_api.create_archive_item(
           /*    p_validate          => 'TRUE' */
            p_archive_item_id        => l_archive_item_id
           ,p_user_entity_id         =>
                  get_user_entity_id(l_user_entity_name_tab(i))
           ,p_archive_value          => l_user_entity_value_tab(i)
           ,p_archive_type           => 'AAP'
           ,p_action_id              => p_assactid
           ,p_legislation_code       => 'CA'
           ,p_object_version_number  => l_object_version_number
           ,p_some_warning           => l_some_warning
            );
       end loop;
    end if;

    l_counter := 0;

    if ((l_no_of_payroll_run > 0) and
        ((l_has_been_paid = 'Y') or (ln_no_gross_earnings <> 0)) ) then

       begin
         open c_get_addr;
         fetch c_get_addr into l_address_line1
                              ,l_address_line2
                              ,l_address_line3
                              ,l_town_or_city
                              ,l_province_code
                              ,l_postal_code
                              ,l_telephone_number
                              ,l_country_code;

         if c_get_addr%NOTFOUND then
            l_address_line1 := null;
            l_address_line2 := null;
            l_address_line3 := null;
            l_town_or_city := null;
            l_province_code := null;
            l_postal_code := null;
            l_telephone_number := null;
            l_country_code := null;
         end if;
         close c_get_addr;
       end;

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


       for i in 1 .. l_counter
       loop
         ff_archive_api.create_archive_item(
            p_archive_item_id        => l_archive_item_id
           ,p_user_entity_id         =>
                  get_user_entity_id(l_user_entity_name_tab(i))
           ,p_archive_value          => l_user_entity_value_tab(i)
           ,p_archive_type           => 'AAP'
           ,p_action_id              => p_assactid
           ,p_legislation_code       => 'CA'
           ,p_object_version_number  => l_object_version_number
           ,p_some_warning           => l_some_warning
            );
       end loop;
    end if;

    Begin

      hr_utility.trace('Started Provincial YE Amendment PP Validation ');
      select to_char(effective_date,'YYYY'),
             report_type,
             to_number(pay_ca_eoy_rl1_amend_arch.get_parameter('PRE_ORGANIZATION_ID'
                                                               ,legislative_parameters))
      into lv_fapp_effective_date,
           lv_fapp_report_type,
           ln_fapp_pre_org_id
      from pay_payroll_actions
      where payroll_action_id = l_payroll_action_id;

      hr_utility.trace('Prov Amend Pre-Process Pactid :'||
                         to_char(l_payroll_action_id));
      hr_utility.trace('lv_fapp_report_type :'||lv_fapp_report_type);

      /* Archive the Pre-Printed form number for the RL1 YEPP
         and Amendment Pre-Process if one exists*/

      ln_form_no_archived := 'N';
      open c_get_preprinted_form_no (l_person_id, ln_fapp_pre_org_id);
      loop
        fetch c_get_preprinted_form_no
        into  lv_eit_year,
              lv_eit_pre_org_id,
              lv_eit_form_no;

        exit when c_get_preprinted_form_no%NOTFOUND;

        if ((lv_fapp_effective_date =
               to_char(fnd_date.canonical_to_date(lv_eit_year), 'YYYY')) and
            (ln_fapp_pre_org_id = to_number(lv_eit_pre_org_id)) and
            (ln_form_no_archived = 'N')) then

           ff_archive_api.create_archive_item(
            p_archive_item_id        => l_archive_item_id
           ,p_user_entity_id => get_user_entity_id('CAEOY_RL1_PRE_PRINTED_FORM_NO')
           ,p_archive_value          => lv_eit_form_no
           ,p_archive_type           => 'AAP'
           ,p_action_id              => p_assactid
           ,p_legislation_code       => 'CA'
           ,p_object_version_number  => l_object_version_number
           ,p_context_name1          => 'JURISDICTION_CODE'
           ,p_context1               => 'QC'
           ,p_some_warning           => l_some_warning
           );

           ln_form_no_archived := 'Y';
        end if;

      end loop;

      close c_get_preprinted_form_no;

      if ln_form_no_archived = 'N' then

           ff_archive_api.create_archive_item(
            p_archive_item_id        => l_archive_item_id
           ,p_user_entity_id => get_user_entity_id('CAEOY_RL1_PRE_PRINTED_FORM_NO')
           ,p_archive_value          => NULL
           ,p_archive_type           => 'AAP'
           ,p_action_id              => p_assactid
           ,p_legislation_code       => 'CA'
           ,p_object_version_number  => l_object_version_number
           ,p_context_name1          => 'JURISDICTION_CODE'
           ,p_context1               => 'QC'
           ,p_some_warning           => l_some_warning
           );

      end if;

      IF lv_fapp_report_type = 'CAEOY_RL1_AMEND_PP' then
         begin

           open c_get_fapp_locked_action_id(p_assactid);
           fetch c_get_fapp_locked_action_id into ln_fapp_locked_action_id;
           close c_get_fapp_locked_action_id;

           hr_utility.trace('RL1 Amend PP Action ID : '||to_char(p_assactid));
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
                 hr_utility.trace('Archiving RL1 Amendment Flag :  ' || lv_fapp_flag);

                ff_archive_api.create_archive_item(
                 p_archive_item_id => l_archive_item_id
                ,p_user_entity_id => get_user_entity_id('CAEOY_RL1_AMENDMENT_FLAG')
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
       hr_utility.trace('End of Provincial YE Amendment PP Validation');

      Exception when no_data_found then
        hr_utility.trace('Report type not found for given Payroll_action ');
        null;
    End;
 -- End of Provincial YE Amendment Pre-Process Validation

  end eoy_archive_data;


  /* Name      : eoy_range_cursor
     Purpose   : This returns the select statement that is used to created the
                 range rows for the Year End Pre-Process.
     Arguments :
     Notes     :
  */

  procedure eoy_range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  l_pre_organization_id  varchar2(50);
  l_archive              boolean:= FALSE;
  l_business_group       number;
  l_year_start           date;
  l_year_end             date;

  begin

     select pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                      legislative_parameters),
            trunc(effective_date,'Y'),
            effective_date,
            business_group_id
     into   l_pre_organization_id,
            l_year_start,
            l_year_end,
            l_business_group
     from pay_payroll_actions
     where payroll_action_id = pactid;

     sqlstr :=  'select distinct asg.person_id
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
                and paa.tax_unit_id in
                    (select hoi.organization_id
                     from hr_organization_information hoi
                     where hoi.org_information_context =  ''Canada Employer Identification''
                     and hoi.org_information2  = '''|| l_pre_organization_id ||''''||'
                     and hoi.org_information5 in (''T4/RL1'',''T4A/RL1''))
                and paa.action_status = ''C''
                and paa.assignment_id = asg.assignment_id
                and ppa.business_group_id = asg.business_group_id + 0
                and ppa.effective_date between asg.effective_start_date
                                           and asg.effective_end_date
                and asg.assignment_type = ''E''
                and ppa.payroll_id = ppy.payroll_id
                and ppy.business_group_id = '||to_char(l_business_group)||'
                and exists (select 1
                            from pay_action_contexts pac,
                                 ff_contexts fc
                            where pac.assignment_id = paa.assignment_id
                            and   pac.assignment_action_id = paa.assignment_action_id
                            and   pac.context_id = fc.context_id
                            and   fc.context_name = ''JURISDICTION_CODE''
                            and   pac.context_value = ''QC'' )
                order by asg.person_id';

        l_archive := chk_gre_archive(pactid);
        if g_archive_flag = 'N' then
           hr_utility.trace('eoy_range_cursor archiving employer data');
           /* Now the archiver has provision for archiving payroll_action_level data . So make use of that */
            eoy_archive_gre_data(pactid,
                                 l_pre_organization_id);
           hr_utility.trace('eoy_range_cursor archived employer data');
         end if;

  end eoy_range_cursor;

end pay_ca_eoy_rl1_archive;

/
