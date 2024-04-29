--------------------------------------------------------
--  DDL for Package Body PAY_CA_EOY_RL2_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EOY_RL2_ARCHIVE" as
/* $Header: pycarl2a.pkb 120.11.12010000.4 2009/09/23 11:17:03 aneghosh ship $ */

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

   Description : Canadian EOY RL2 Archiver Process

   Change List

   Date         Name        Vers   Bug No   Description

   30-SEP-2002  SSattini    115.0           Created
   22-OCT-2002  SSattini    115.1  2618558  Earlier Box O used to archive
                                            Beneficiary SIN but for YE-2002
                                            it has changed and currently
                                            Box O archives 'Withdrawal under
                                            the Home Buyers Plan' value.
                                            Also changed the queries
                                            in eoy_archive_date,
                                            eoy_action_creation to
                                            improve the performance.
   01-NOV-2002  SSattini    115.2  2647945  Renamed balance names for RL2
                                            'Income Earned After death' to
                                            'Income earned after death RRSP
                                             or RRIF' and
                                            'Withdrawal under the LPP' to
                                            'Withdrawal under the Lifelong
                                             Learning Plan'.
   15-NOV-2002  SSattini    115.3  2671025  Range cursor sql stmt was
                                            erroring out with invalid number,
                                            corrected it for HRNOV02 bugfix.
   19-NOV-2002  SSattini    115.4  2675144  RL2 Box N was archiving beneficiary
                                            name earlier, changed to archive
                                            beneficiary sin.
   22-NOV-2002  SSattini    115.5  2681250  Fixed the archiving of employee
                                            address.
   02-DEC-2002  SSattini    115.6           Added 'nocopy' for out and in out
                                            parameters, GSCC compliance.
   27-AUG-2003  SSouresr    115.7           If the new balance 'RL2 No Gross Earnings'
                                            is non zero then archiving will take place
                                            even if gross earnings is zero
   25-SEP-2003  mmukherj    115.8           Bugfix 3162038. The range cursor was
                                            checking segment1 of softcoded
                                            keyflex .But in the new flexfield
                                            structure with multi-gre T4A/RL2
                                            GRE will be in segment12.
   06-NOV-2003  SSouresr    115.9           Changed Archiver to use Prov Reporting
                                            Est instead of Quebec Business Number
   08-JAN-2004  SSouresr    115.10          A new flag will be archived on the
                                            employee level if any negative balances
                                            exist.
   20-FEB-2004  SSattini    115.11 3356533  Modified the cursor c_get_asg_act_id
                                            and removed cursor c_all_gres_for_person
                                            because we not using it.  Part of fix
                                            for 11510 bug#3356533.
   22-MAR-2004  SSouresr    115.12 3513423  The extra person information data is now
                                            retrieved through the cursor
                                            c_get_person_extra_info. This cursor only
                                            picks up the override data set corresponding
                                            with the Archiver's PRE.
   07-JUN-2004  SSattini    115.13 3638928  Modified the cursor
                                            c_get_asg_act_id and
                                            c_get_max_asg_act_id to get max
                                            asgact_id based on person_id.
                                            Fix for bug#3638928.
   07-JUN-2004  SSattini    115.14 3638928  Fixed the GSCC Error
   30-JUL-2004  SSouresr    115.15 3687849  Records are now archived against the primary
                                            assignment id
   05-NOV-2004  SSouresr    115.16          The RL2 No Gross Earnings balance should be
                                            retrieved across all GREs
   10-NOV-2004  SSouresr    115.17          Modified to use tables instead of views
                                            to remove problems with security groups
   28-NOV-2004  SSouresr    115.19          Added date range to c_get_max_asg_act_id
   29-NOV-2004  SSouresr    115.20          Modified c_footnote_info to only return RL2
                                            footnotes
   04-MAR-2005  SSouresr    115.21          The province code for the employer address with
                                            a Canadian International style is now archived
   08-AUG-2005  mmukherj    115.22          The procedure eoy_archinit has been
                                            modified to set the minimum chunk
                                            no, which is required to re archive
                                            the data while retrying the Archiver
                                            in the payroll action level.
                                            Bugfix: #4525642
   17-AUG-2005  SSattini    115.23 3531136  Modified eoy_archive_data to archive
                                            Source of income 'Other' as footnotes,
                                            Also added Box L and O validation
                                            Bug#3358604.
   21-OCT-2005  SSouresr    115.24          The negative balance flag is archived as Y
                                            if any of the RL2 footnotes is negative
   29-NOV-2005  SSouresr    115.25          The first parameter passed to c_get_max_asg_act_id
                                            for footnotes was changed from assignment_id to person_id
   10-FEB-2006  SSouresr    115.26          Added RL2 Amendment functionality and removed
                                            references to hr_soft_coding_key_flex
   14-FEB-2006  SSouresr    115.27          CAEOY RL2 EMPLOYEE INFO2 is now archived for the RL2 process
                                            as well as the RL2 Amendment Process
   24-Apr-2006  ssmukher    115.28          Modified the sqlstr string  variable in the procedure
                                            eoy_range_cursor for bug #5120627 fix.
   24-APR-2006  ssouresr    115.29          ln_index and ln_footnote_index were taken out of a
                                            conditional statement to prevent the error message
                                            NULL index table key value from occurring
                                            The function compare_archive_data was also modified
                                            for the situation where either the original RL2 or
                                            the amended RL2 have not been archived
   04-AUG-2006  YDEVI      115.30           RL2 archiver will used
                                            PAY_CA_EOY_RL2_S instead of
                                            PAY_CA_EOY_RL1_S. to generate
                                            sequence number
   18-AUG-2006  meshah     115.31  5202869  For performance issue modified the
                                            cursor c_eoy_qbin.Removed the table
                                            per_people_f and also disabled
                                            few indexes to make sure the query
                                            takes the correct path. With this
                                            change the cost of the query has
                                            increased but the path taken is
                                            better.
   28-AUG-2006  meshah      115.32  5495704 the way indexes were disabled has
                                            been changed from using +0 to ||.
   09-APR-2009  sapalani    115.33  6768167 Added Function gen_rl2_pdf_seq to
                                            generate sequence number for RL2 PDFs.
   08-MAY-2009  sapalani    115.34  8500723 Added Function getnext_seq_num to
                                            calculate and add check digit for
                                            PDF sequence number before archiving.
   23-SEP-2009  aneghosh    115.35  8921055 Added the pre_printed_slip no to the
                                            function compare_archive_data so that
                                            changes in original slip number will
                                            also set the AMENDMENT_FLAG to Y.
*/

   eoy_all_qbin varchar2(4000);

 /* Name    : get_def_bal_id
  Purpose   : Given the name of a balance and balance dimension
              the function returns the defined_balance_id .

  Arguments : balance_name,balance_dimension_name and legislation_code
  Notes     : A defined balance_id is required call pay_balance_pkg.get_value.
 */

 Function get_def_bal_id ( p_balance_name varchar2,
                           p_balance_dimension varchar2,
                           p_legislation_code varchar2)
 return number is

 /* Get the defined_balance_id for the specified balance name and dimension */

   cursor csr_bal_type_id(cp_bal_name varchar2) is
     select balance_type_id
     from pay_balance_types
     where balance_name = cp_bal_name;

   cursor csr_def_bal_id(cp_bal_type_id number,
                         cp_bal_dimension varchar2,
                         cp_legislation_code varchar2) is
   select pdb.defined_balance_id
        from pay_defined_balances pdb,
             pay_balance_dimensions pbd
       where pdb.balance_type_id = cp_bal_type_id
         and pbd.dimension_name = cp_bal_dimension
         and pbd.balance_dimension_id = pdb.balance_dimension_id
          and ((pbd.legislation_code = cp_legislation_code and
                pbd.business_group_id is null)
            or (pbd.legislation_code is null and
                pbd.business_group_id is not null));

   l_defined_balance_id pay_defined_balances.defined_balance_id%type;
   l_balance_type_id pay_balance_types.balance_type_id%type;

 begin

   open csr_bal_type_id(p_balance_name);
   fetch csr_bal_type_id into l_balance_type_id;

   if csr_bal_type_id%notfound then
      close csr_bal_type_id;
      /* need a pop-message */
      hr_utility.trace('Balance name :'||p_balance_name||'doesnot exist');
      raise hr_utility.hr_error;
   else
      close csr_bal_type_id;
   end if;

   open csr_def_bal_id(l_balance_type_id,p_balance_dimension,
                       p_legislation_code);
   fetch csr_def_bal_id into l_defined_balance_id;
   if csr_def_bal_id%notfound then
     close csr_def_bal_id;
      /* need a pop-message */
      hr_utility.trace('Balance Dimension :'||p_balance_dimension||'doesnot exist');
     raise hr_utility.hr_error;
   else
     close csr_def_bal_id;
   end if;

   return (l_defined_balance_id);

 end get_def_bal_id;


 /* Name    : get_dates
  Purpose   : The dates are dependent on the report being run
              For RL2 it is year end dates.
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

   if    p_report_type = 'RL2' then

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
  Purpose    : Returns information used in the selection of people to
               be reported on.
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

   if    p_report_type = 'RL2'  then

     /* Default settings for Year End Preprocess. */

     hr_utility.trace('in getting selection information ');
     p_period_start         := p_year_start;
     p_period_end           := p_year_end;
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

 /* Name      : chk_rl2_footnote
     Purpose   : Function to check whether the RL2 Footnote to be archived
                 is valid or not.
     Arguments :footnote_code
     Notes     :
  */

  function chk_rl2_footnote(p_footnote_code varchar2) return boolean is

  l_flag varchar2(1);

  cursor c_chk_footnote is
     select 'Y'
     from dual
     where exists (select 'X'
               from fnd_lookup_values
               where ((lookup_type = 'PAY_CA_RL2_FOOTNOTES'
                      and lookup_code = p_footnote_code)
                  OR (lookup_type = 'PAY_CA_RL2_AUTOMATIC_FOOTNOTES'
                      and lookup_code = p_footnote_code))
                   );
  begin

     hr_utility.trace('chk_rl2_footnote - checking footnote exists');
     hr_utility.trace('c_chk_footnote - opening cursor');

       open c_chk_footnote;
       fetch c_chk_footnote into l_flag;
       if c_chk_footnote%FOUND then
          hr_utility.trace('c_chk_footnote - found in cursor');
          l_flag := 'Y';
       else
          hr_utility.trace('c_chk_footnote - not found in cursor');
          l_flag := 'N';
       end if;

       hr_utility.trace('c_chk_footnote - closing cursor');
       close c_chk_footnote;

       if l_flag = 'Y' then
          hr_utility.trace('chk_rl2_footnote - returning true');
          return (TRUE);
       else
          hr_utility.trace('chk_rl2_footnote - returning false');
          return(FALSE);
       end if;

  end chk_rl2_footnote;


 /*
  Name      : Initialization_process
  Purpose   : This procedure will delete the plsql tables used for
              archiving the employee and employer data.
  Arguments :
  Notes     :
 */

  procedure initialization_process(p_data varchar2)
  is

  BEGIN

   If p_data = 'EMPLOYEE_DATA' then

    hr_utility.trace('deleting plsql table'|| p_data);

    if pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data.count > 0 then
       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data.delete;
    end if;

    if pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data.count > 0 then
       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data.delete;
    end if;

    if pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2.count > 0 then
       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2.delete;
    end if;

   End if;

   If p_data = 'PRE_DATA' then

    hr_utility.trace('deleting plsql table'|| p_data);

    if pay_ca_eoy_rl2_archive.ltr_ppa_arch_data.count > 0 then
       pay_ca_eoy_rl2_archive.ltr_ppa_arch_data.delete;
    end if;

    if pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data.count > 0 then
       pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data.delete;
    end if;

   End if;

  END initialization_process;


 /*
  Name      : archive_data_records
  Purpose   : This procedure will insert values in to pay_action_information
              table using the plsql table.
  Arguments :
  Notes     :
 */

  procedure archive_data_records(
               p_action_context_id   in number
              ,p_action_context_type in varchar2
              ,p_assignment_id       in number
              ,p_tax_unit_id         in number
              ,p_effective_date      in date
              ,p_tab_rec_data        in pay_ca_eoy_rl2_archive.action_info_table
               )

  IS
     l_action_information_id_1 NUMBER ;
     l_object_version_number_1 NUMBER ;

  BEGIN

     if p_tab_rec_data.count > 0 then
        for i in p_tab_rec_data.first .. p_tab_rec_data.last loop
            hr_utility.trace('Defining category '||
                          p_tab_rec_data(i).action_info_category);
            hr_utility.trace('action_context_id = '|| p_action_context_id);
            hr_utility.trace('jurisdiction_code '||
                           p_tab_rec_data(i).jurisdiction_code);
            hr_utility.trace('act_info1 is'|| p_tab_rec_data(i).act_info1);

            hr_utility.trace('act_info2 is'|| p_tab_rec_data(i).act_info2);

            hr_utility.trace('act_info3 is'|| p_tab_rec_data(i).act_info3);

            hr_utility.trace('act_info4 is'|| p_tab_rec_data(i).act_info4);

            hr_utility.trace('act_info5 is'|| p_tab_rec_data(i).act_info5);

            hr_utility.trace('act_info6 is'|| p_tab_rec_data(i).act_info6);

            hr_utility.trace('act_info30 is'|| p_tab_rec_data(i).act_info30);

            pay_action_information_api.create_action_information(
                p_action_information_id => l_action_information_id_1,
                p_object_version_number => l_object_version_number_1,
                p_action_information_category
                     => p_tab_rec_data(i).action_info_category,
                p_action_context_id    => p_action_context_id,
                p_action_context_type  => p_action_context_type,
                p_jurisdiction_code    => p_tab_rec_data(i).jurisdiction_code,
                p_assignment_id        => p_assignment_id,
                p_tax_unit_id          => p_tax_unit_id,
                p_effective_date       => p_effective_date,
                p_action_information1  => p_tab_rec_data(i).act_info1,
                p_action_information2  => p_tab_rec_data(i).act_info2,
                p_action_information3  => p_tab_rec_data(i).act_info3,
                p_action_information4  => p_tab_rec_data(i).act_info4,
                p_action_information5  => p_tab_rec_data(i).act_info5,
                p_action_information6  => p_tab_rec_data(i).act_info6,
                p_action_information7  => p_tab_rec_data(i).act_info7,
                p_action_information8  => p_tab_rec_data(i).act_info8,
                p_action_information9  => p_tab_rec_data(i).act_info9,
                p_action_information10 => p_tab_rec_data(i).act_info10,
                p_action_information11 => p_tab_rec_data(i).act_info11,
                p_action_information12 => p_tab_rec_data(i).act_info12,
                p_action_information13 => p_tab_rec_data(i).act_info13,
                p_action_information14 => p_tab_rec_data(i).act_info14,
                p_action_information15 => p_tab_rec_data(i).act_info15,
                p_action_information16 => p_tab_rec_data(i).act_info16,
                p_action_information17 => p_tab_rec_data(i).act_info17,
                p_action_information18 => p_tab_rec_data(i).act_info18,
                p_action_information19 => p_tab_rec_data(i).act_info19,
                p_action_information20 => p_tab_rec_data(i).act_info20,
                p_action_information21 => p_tab_rec_data(i).act_info21,
                p_action_information22 => p_tab_rec_data(i).act_info22,
                p_action_information23 => p_tab_rec_data(i).act_info23,
                p_action_information24 => p_tab_rec_data(i).act_info24,
                p_action_information25 => p_tab_rec_data(i).act_info25,
                p_action_information26 => p_tab_rec_data(i).act_info26,
                p_action_information27 => p_tab_rec_data(i).act_info27,
                p_action_information28 => p_tab_rec_data(i).act_info28,
                p_action_information29 => p_tab_rec_data(i).act_info29,
                p_action_information30 => p_tab_rec_data(i).act_info30
                );

           end loop;
     end if;

  END archive_data_records;


 FUNCTION compare_archive_data(p_assignment_action_id in number,
                               p_locked_action_id     in number,
                               l_pre_printed_slip_no in varchar2) -- For Bug 8921055
 RETURN VARCHAR2 IS

  TYPE act_info_rec IS RECORD
   (act_info1       varchar2(240),
    act_info2       varchar2(240),
    act_info3       varchar2(240),
    act_info4       varchar2(240),
    act_info5       varchar2(240),
    act_info6       varchar2(240),
    act_info7       varchar2(240),
    act_info8       varchar2(240),
    act_info9       varchar2(240),
    act_info10      varchar2(240),
    act_info11      varchar2(240),
    act_info12      varchar2(240),
    act_info13      varchar2(240),
    act_info14      varchar2(240),
    act_info15      varchar2(240),
    act_info16      varchar2(240),
    act_info17      varchar2(240),
    act_info18      varchar2(240),
    act_info19      varchar2(240),
    act_info20      varchar2(240),
    act_info21      varchar2(240),
    act_info22      varchar2(240),
    act_info23      varchar2(240),
    act_info24      varchar2(240),
    act_info25      varchar2(240),
    act_info26      varchar2(240),
    act_info27      varchar2(240),
    act_info28      varchar2(240),
    act_info29      varchar2(240),
    act_info30      varchar2(240));

  TYPE act_info_ft_rec IS RECORD
   (message     varchar2(240),
    value       varchar2(240));

  TYPE action_info_table IS TABLE OF act_info_rec
  INDEX BY BINARY_INTEGER;

  TYPE action_info_footnote_table IS TABLE OF act_info_ft_rec
  INDEX BY BINARY_INTEGER;

  ltr_amend_arch_data  action_info_table;
  ltr_yepp_arch_data   action_info_table;
  ltr_amend_footnote   action_info_footnote_table;
  ltr_yepp_footnote    action_info_footnote_table;
  ltr_amend_pre_printed_slipno varchar2(240); -- For Bug 8921055
  ltr_yepp_pre_printed_slipno varchar2(240);  -- For Bug 8921055
  ln_yepp_footnote_count  number;
  ln_amend_footnote_count number;

  cursor c_get_footnotes(cp_asg_act_id number) is
  select action_information4,
         action_information5
  from pay_action_information
  where action_context_id = cp_asg_act_id
  and   action_information_category = 'CA FOOTNOTES'
  and   action_context_type = 'AAP'
  and   action_information6 = 'RL2'
  and   jurisdiction_code   = 'QC'
  order by action_information4;

  cursor c_get_employee_data(cp_asg_act_id number) is
  select nvl(action_information1,'NULL'),
         nvl(action_information2,'NULL'),
         nvl(action_information3,'NULL'),
         nvl(action_information4,'NULL'),
         nvl(action_information5,'NULL'),
         nvl(action_information6,'NULL'),
         nvl(action_information7,'NULL'),
         nvl(action_information8,'NULL'),
         nvl(action_information9,'NULL'),
         nvl(action_information10,'NULL'),
         nvl(action_information11,'NULL'),
         nvl(action_information12,'NULL'),
         nvl(action_information13,'NULL'),
         nvl(action_information14,'NULL'),
         nvl(action_information15,'NULL'),
         nvl(action_information16,'NULL'),
         nvl(action_information17,'NULL'),
         nvl(action_information18,'NULL'),
         nvl(action_information19,'NULL'),
         nvl(action_information20,'NULL'),
         nvl(action_information21,'NULL'),
         nvl(action_information22,'NULL'),
         nvl(action_information23,'NULL'),
         nvl(action_information24,'NULL'),
         nvl(action_information25,'NULL'),
         nvl(action_information26,'NULL'),
         nvl(action_information27,'NULL'),
         nvl(action_information28,'NULL'),
         nvl(action_information29,'NULL'),
         nvl(action_information30,'NULL')
  from pay_action_information
  where action_context_id = cp_asg_act_id
  and   action_information_category = 'CAEOY RL2 EMPLOYEE INFO'
  and   action_context_type = 'AAP'
  and   jurisdiction_code   = 'QC';

  cursor c_get_employee_data2(cp_asg_act_id number) is -- For Bug 8921055
  select nvl(action_information1,'NULL')
  from pay_action_information
  where action_context_id = cp_asg_act_id
  and   action_information_category = 'CAEOY RL2 EMPLOYEE INFO2'
  and   action_context_type = 'AAP'
  and   jurisdiction_code   = 'QC';

  i       number;
  lv_flag varchar2(2);

    begin

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


   /* Populate RL2 Amendment Employee Data for an assignment_action */

      open c_get_employee_data(p_assignment_action_id);

      hr_utility.trace('Populating RL2 Amendment Employee Data ');
      hr_utility.trace('P_assignment_action_id :'||to_char(p_assignment_action_id));

      fetch c_get_employee_data into ltr_amend_arch_data(0);
      close c_get_employee_data;

      hr_utility.trace('ltr_amend_pre_printed_slipno:'||to_char(l_pre_printed_slip_no));

   /* Populate RL2 YEPP Employee Data for an assignment_action */

      open c_get_employee_data(p_locked_action_id);

      hr_utility.trace('Populating RL2 YEPP Employee Data ');
      hr_utility.trace('P_locked_action_id :'||to_char(p_locked_action_id));

      fetch c_get_employee_data into ltr_yepp_arch_data(0);
      close c_get_employee_data;

      open c_get_employee_data2(p_locked_action_id); -- For Bug 8921055

      hr_utility.trace('Populating RL2 YEPP Employee Data2 ');
      hr_utility.trace('P_locked_action_id :'||to_char(p_locked_action_id));

      fetch c_get_employee_data2 into ltr_yepp_pre_printed_slipno;
      hr_utility.trace('ltr_yepp_pre_printed_slipno :'||to_char(ltr_yepp_pre_printed_slipno));
      close c_get_employee_data2;

   /* Populate RL2 Amendment Footnotes */
      open c_get_footnotes(p_assignment_action_id);

      hr_utility.trace('Populating RL2 Amendment Footnote ');

      ln_amend_footnote_count := 0;
      loop
         fetch c_get_footnotes into ltr_amend_footnote(ln_amend_footnote_count);
         exit when c_get_footnotes%NOTFOUND;

         hr_utility.trace('Amend Message: '||ltr_amend_footnote(ln_amend_footnote_count).message);
         hr_utility.trace('Amend Value: '||ltr_amend_footnote(ln_amend_footnote_count).value);

         ln_amend_footnote_count := ln_amend_footnote_count + 1;
      end loop;

      close c_get_footnotes;

   /* Populate RL2 YEPP Footnotes */
      open c_get_footnotes(p_locked_action_id);

      ln_yepp_footnote_count := 0;
      loop
         fetch c_get_footnotes into ltr_yepp_footnote(ln_yepp_footnote_count);
         exit when c_get_footnotes%NOTFOUND;

         hr_utility.trace('YEPP Message: '||ltr_yepp_footnote(ln_yepp_footnote_count).message);
         hr_utility.trace('YEPP Value: '||ltr_yepp_footnote(ln_yepp_footnote_count).value);

         ln_yepp_footnote_count := ln_yepp_footnote_count + 1;
      end loop;

      close c_get_footnotes;

      hr_utility.trace('Comparing RL2 Amend and RL2 YEPP Data ');

      if (ltr_yepp_arch_data.count = ltr_amend_arch_data.count) then

         if (ltr_yepp_arch_data.count <> 0) then

            if ((ltr_yepp_arch_data(0).act_info2 <> ltr_amend_arch_data(0).act_info2) or
                (ltr_yepp_arch_data(0).act_info3 <> ltr_amend_arch_data(0).act_info3) or
                (ltr_yepp_arch_data(0).act_info4 <> ltr_amend_arch_data(0).act_info4) or
                (ltr_yepp_arch_data(0).act_info5 <> ltr_amend_arch_data(0).act_info5) or
                (ltr_yepp_arch_data(0).act_info6 <> ltr_amend_arch_data(0).act_info6) or
                (ltr_yepp_arch_data(0).act_info7 <> ltr_amend_arch_data(0).act_info7) or
                (ltr_yepp_arch_data(0).act_info8 <> ltr_amend_arch_data(0).act_info8) or
                (ltr_yepp_arch_data(0).act_info9 <> ltr_amend_arch_data(0).act_info9) or
                (ltr_yepp_arch_data(0).act_info10 <> ltr_amend_arch_data(0).act_info10) or
                (ltr_yepp_arch_data(0).act_info11 <> ltr_amend_arch_data(0).act_info11) or
                (ltr_yepp_arch_data(0).act_info12 <> ltr_amend_arch_data(0).act_info12) or
                (ltr_yepp_arch_data(0).act_info13 <> ltr_amend_arch_data(0).act_info13) or
                (ltr_yepp_arch_data(0).act_info14 <> ltr_amend_arch_data(0).act_info14) or
                (ltr_yepp_arch_data(0).act_info15 <> ltr_amend_arch_data(0).act_info15) or
                (ltr_yepp_arch_data(0).act_info16 <> ltr_amend_arch_data(0).act_info16) or
                (ltr_yepp_arch_data(0).act_info17 <> ltr_amend_arch_data(0).act_info17) or
                (ltr_yepp_arch_data(0).act_info18 <> ltr_amend_arch_data(0).act_info18) or
                (ltr_yepp_arch_data(0).act_info19 <> ltr_amend_arch_data(0).act_info19) or
                (ltr_yepp_arch_data(0).act_info20 <> ltr_amend_arch_data(0).act_info20) or
                (ltr_yepp_arch_data(0).act_info21 <> ltr_amend_arch_data(0).act_info21) or
                (ltr_yepp_arch_data(0).act_info22 <> ltr_amend_arch_data(0).act_info22) or
                (ltr_yepp_arch_data(0).act_info23 <> ltr_amend_arch_data(0).act_info23) or
                (ltr_yepp_arch_data(0).act_info24 <> ltr_amend_arch_data(0).act_info24) or
                (ltr_yepp_arch_data(0).act_info25 <> ltr_amend_arch_data(0).act_info25) or
                (ltr_yepp_arch_data(0).act_info26 <> ltr_amend_arch_data(0).act_info26) or
                (ltr_yepp_arch_data(0).act_info27 <> ltr_amend_arch_data(0).act_info27) or
                (ltr_yepp_arch_data(0).act_info28 <> ltr_amend_arch_data(0).act_info28) or
                (ltr_yepp_arch_data(0).act_info29 <> ltr_amend_arch_data(0).act_info29))or
                (ltr_yepp_pre_printed_slipno <> l_pre_printed_slip_no) then -- For Bug 8921055

                lv_flag := 'Y';
                hr_utility.trace('lv_flag has been set to Y for Employee Data');
            end if;

         end if;

      else
         lv_flag := 'Y';
         hr_utility.trace('lv_flag has been set to Y for Employee Data');
      end if;


   /* Compare RL2 Amendment Footnotes and RL2 YEPP Footnotes for an
      assignment_action */

      hr_utility.trace('Comparing RL2 Amend and RL2 YEPP Footnotes');

      if lv_flag <> 'Y' then

         if ln_yepp_footnote_count <> ln_amend_footnote_count then

            lv_flag := 'Y';

         elsif ((ln_yepp_footnote_count = ln_amend_footnote_count) and
                (ln_yepp_footnote_count <> 0)) then

            for i in ltr_yepp_footnote.first..ltr_yepp_footnote.last
            loop
              if (ltr_yepp_footnote(i).message = ltr_amend_footnote(i).message) then

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
        hr_utility.trace('No value difference for Asg Action: '||  to_char(p_assignment_action_id));

     end if;

     hr_utility.trace('lv_flag :'||lv_flag);

     return lv_flag;

end compare_archive_data;


 /*
  Name      : eoy_action_creation
  Purpose   : This creates the assignment actions for a specific chunk
              of people to be archived by the RL2 Archiver preprocess.
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
   l_eoy_tax_unit_id        number;
   l_effective_end_date     date;
   l_object_version_number  number;
   l_some_warning           boolean;
   l_counter                number;
   l_user_entity_name_tab   pay_ca_eoy_rl2_archive.char240_data_type_table;
   l_user_entity_value_tab  pay_ca_eoy_rl2_archive.char240_data_type_table;
   l_user_entity_name       varchar2(240);

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
   l_archive_item_id        number;

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
   l_pre_org_id     varchar2(17);
   l_prev_pre_org_id varchar2(17);
   l_primary_asg    pay_assignment_actions.assignment_id%type;
   ln_no_gross_earnings number;


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
       AND  rtrim(ltrim(SCL.segment12))  in
       (select to_char(hoi.organization_id)
        from hr_organization_information hoi
        where hoi.org_information_context =  'Canada Employer Identification'
        and hoi.org_information2  = l_pre_org_id
        and hoi.org_information5 = 'T4A/RL2')
       AND  PPY.payroll_id             = ASG.payroll_id
      and exists ( select 'X' from pay_action_contexts pac, ff_contexts fc
                    where pac.assignment_id = asg.assignment_id
                    and   pac.context_id = fc.context_id
		    and   fc.context_name = 'JURISDICTION_CODE'
                     and pac.context_value = 'QC' )
     ORDER  BY 1, 3 DESC, 2; */

/*
Bug 5202869. For performance issue modified the cursor c_eoy_qbin.
Removed the table per_people_f and also disabled few indexes to make
sure the query takes the correct path. With this change the cost of
the query has increased but the path taken is better.
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
                              and hoi.org_information2  = l_pre_org_id
                              and hoi.org_information5 = 'T4A/RL2')
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
                 and   fc.context_name || '' = 'JURISDICTION_CODE'
                 and   pac.context_value ||'' = 'QC')
  ORDER  BY 1, 3 DESC, 2;

      cursor c_all_qbin_gres is
       select hoi.organization_id
        from hr_organization_information hoi
        where hoi.org_information_context =  'Canada Employer Identification'
        and hoi.org_information2  = l_pre_org_id
        and hoi.org_information5 = 'T4A/RL2';

   /* Get the assignment for the given person_id */

   CURSOR c_get_asg_id (p_person_id number) IS
     SELECT assignment_id
     from per_all_assignments_f paf
     where person_id = p_person_id
     and   assignment_type = 'E'
     and   primary_flag = 'Y'
     and   paf.effective_start_date  <= l_period_end
     and   paf.effective_end_date    >= l_period_start
     ORDER BY assignment_id desc;

   /* Cursor to get the latest payroll run assignment_action_id
      for a person with a given tax_unit_id and for that year.
      11510 bug# fix. Changed the cursor to get asgact_id based on
      person_id to fix bug#3638928 */

            CURSOR c_get_asg_act_id(cp_person_id number,
                           cp_tax_unit_id number,
                           cp_period_start date,
                           cp_period_end date) IS
            select paa.assignment_action_id
            from pay_assignment_actions     paa,
                   per_all_assignments_f      paf,
                   per_all_people_f  ppf,
                   pay_payroll_actions        ppa,
                   pay_action_classifications pac
            where  ppf.person_id = cp_person_id
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
            pay_ca_eoy_rl1_amend_arch.get_parameter('PRE_ORGANIZATION_ID',
                                                    legislative_parameters)
     into   l_effective_date,
            l_report_type,
            l_bus_group_id,
            l_pre_org_id
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

           fetch c_eoy_qbin into l_person_id,
                                 l_assignment_id,
                                 l_effective_end_date;

           exit when c_eoy_qbin%NOTFOUND;


        /* If the new row is the same as the previous row according to the way
           the rows are grouped then discard the row ie. grouping by Prov Reporting
           Est requires a single row for each person / PRE combination. */

           hr_utility.trace('Prov Reporting Est is '
                                   || l_pre_org_id);
           hr_utility.trace('previous Prov Reporting Est is '||
                                    l_prev_pre_org_id);
           hr_utility.trace('person_id is '||
                                    to_char(l_person_id));
           hr_utility.trace('previous person_id is '||
                                    to_char(l_prev_person_id));

        if (l_person_id  = l_prev_person_id   and
            l_pre_org_id = l_prev_pre_org_id) then

          hr_utility.trace('Not creating assignment action');

        else
          /* Check whether the person has 0 payment or not */

          l_value := 0;
          ln_no_gross_earnings := 0;

          open c_all_qbin_gres;
          loop
            fetch c_all_qbin_gres into l_tax_unit_id;
            exit when c_all_qbin_gres%NOTFOUND;

            /* select the maximum assignment action id. Fix for bug#3638928 */

           begin

             open c_get_asg_act_id(l_person_id,l_tax_unit_id,
                                   l_period_start,l_period_end);
             fetch c_get_asg_act_id into l_max_aaid;

               if c_get_asg_act_id%NOTFOUND then
                 pay_core_utils.push_message(801,
                                           'PAY_74038_EOY_EXCP_NO_PAYROLL','A');
                 pay_core_utils.push_token('person','Person id: '
                                             ||to_char(l_person_id));
                 pay_core_utils.push_token('reporting_year','Reporting Year: '
                                            ||to_char(l_effective_date,'YYYY'));

                 l_max_aaid := -9999;
               end if;
             close c_get_asg_act_id;
         end; /* end for select of max assignment action id */

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
                   ('RL2 No Gross Earnings',
                    'YTD' ,
                    l_max_aaid,
                    l_assignment_id ,
                    NULL,
                    'PER' ,
                    l_tax_unit_id,
                    l_bus_group_id,
                    'QC'
                   ),0) ;
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

       if ((l_value <> 0) or (ln_no_gross_earnings <> 0)) then
          /* Get the primary assignment */
          open c_get_asg_id(l_person_id);
          fetch c_get_asg_id into l_primary_asg;

          if c_get_asg_id%NOTFOUND then
             close c_get_asg_id;
             pay_core_utils.push_message(800,'HR_74004_ASSIGNMENT_ABSENT','A');
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

          hr_utility.trace('creating assignment_action');

          /* Passing tax unit id as null */

          hr_nonrun_asact.insact(lockingactid,l_primary_asg,
                                 pactid,chunk,null);

          /* Update the serial number column with the person id
             so that the mag routine and the RL2 view will not have
             to do an additional checking against the assignment
             table
          */

          hr_utility.trace('updating assignment_action' || to_char(lockingactid));

          update pay_assignment_actions aa
          set    aa.serial_number = to_char(l_person_id)
          where  aa.assignment_action_id = lockingactid;

       end if; /* end if l_value <> 0 or ln_no_gross_earnings <> 0 */

     end if; /* end if l_person_id = l_prev_person_id */

     /* Record the current values for the next time around the loop. */

     l_prev_person_id  := l_person_id;
     l_prev_pre_org_id := l_pre_org_id;

   end loop;

          hr_utility.trace('Action creation done');
 close c_eoy_qbin;

 end eoy_action_creation;


  /* Name      : eoy_archive_gre_data
     Purpose   : This performs the CA specific employer data archiving.
     Arguments :
     Notes     :
  */

  PROCEDURE eoy_archive_gre_data(p_payroll_action_id      in number,
                                 p_pre_org_id             in varchar2)
  IS

  l_user_entity_id               number;
  l_taxunit_context_id           number;
  l_jursd_context_id             number;
  l_value                        varchar2(240);
  l_sit_uid                      number;
  l_sui_uid                      number;
  l_fips_uid                     number;
  l_seq_tab                      pay_ca_eoy_rl2_archive.number_data_type_table;
  l_context_id_tab               pay_ca_eoy_rl2_archive.number_data_type_table;
  l_context_val_tab              pay_ca_eoy_rl2_archive.char240_data_type_table;
  l_user_entity_name_tab         pay_ca_eoy_rl2_archive.char240_data_type_table;
  l_user_entity_value_tab        pay_ca_eoy_rl2_archive.char240_data_type_table;
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
  l_org_name                     varchar2(240);
  l_employer_ein                 varchar2(240);
  l_address_line_1               varchar2(240);
  l_address_line_2               varchar2(240);
  l_address_line_3               varchar2(240);
  l_counter                      number := 0;
  l_object_version_number        number;
  l_business_group_id            number;
  l_some_warning                 boolean;
  l_step                         number := 0;
  l_taxation_year                varchar2(4);
  l_rl2_last_slip_number         number ;
  l_employer_info_found          varchar2(1);
  l_max_slip_number              varchar2(80);
  l_effective_date               date;

     ln_index number;
     ln_index2 number;

     l_action_information_id_1 NUMBER ;
     l_object_version_number_1 NUMBER ;

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
         substr(target1.ORG_INFORMATION18,1,8) RL2_Slip_Number,
         decode(target1.org_information3,'Y',target1.organization_id,
                                             to_number(target1.ORG_INFORMATION20)),
         target1.ORG_INFORMATION3
  from   hr_organization_information target1,
         hr_all_organization_units   target2
  where  target1.organization_id   = to_number(p_pre_org_id)
  and    target2.business_group_id = l_business_group_id
  and    target2.organization_id   = target1.organization_id
  and    target1.org_information_context = 'Prov Reporting Est'
  and    target1.org_information4 = 'P02';

  /* payroll action level database items */

  BEGIN

    /* hr_utility.trace_on('Y','RL2'); */

    initialization_process('PRE_DATA');

    select to_char(effective_date,'YYYY'),business_group_id,effective_date
    into   l_taxation_year,l_business_group_id,l_effective_date
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
           l_rl2_last_slip_number,
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
           , DECODE(L.STYLE ,'US',L.REGION_2,'CA',L.REGION_1,'CA_GLB',L.REGION_1,' ')
           , replace(L.POSTAL_CODE,' ')
           , L.COUNTRY
           , O.name
         into
            l_address_line_1
          , l_address_line_2
          , l_address_line_3
          , l_town_or_city
          , l_province_code
          , l_postal_code
          , l_country_code
          , l_org_name
         from  hr_all_organization_units O,
               hr_locations_all L
         where L.LOCATION_ID = O.LOCATION_ID
         AND O.ORGANIZATION_ID = l_organization_id_of_qin;

         /* Find out the highest slip number for that transmitter */

         if l_transmitter_gre_ind = 'Y' then

            l_transmitter_org_id :=  l_organization_id_of_qin;

            l_transmitter_name        := l_org_name;
            l_transmitter_addr_line_1 := l_address_line_1;
            l_transmitter_addr_line_2 := l_address_line_2;
            l_transmitter_addr_line_3 := l_address_line_3;
            l_transmitter_city        := l_town_or_city;
            l_transmitter_province    := l_province_code;
            l_transmitter_postal_code := l_postal_code;
            l_transmitter_country     := l_country_code;

         end if;

         exception when no_data_found then
           l_transmitter_name := NULL;
           l_address_line_1 := NULL;
           l_address_line_2 := NULL;
           l_address_line_3 := NULL;
           l_town_or_city   := NULL;
           l_province_code  := NULL;
           l_postal_code    := NULL;
           l_country_code   := NULL;
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

       pay_core_utils.push_message(801,'PAY_74014_NO_TRANSMITTER_ORG','A');
       pay_core_utils.push_token('orgind','Prov Reporting Est: '
                                        ||p_pre_org_id);
       hr_utility.raise_error;
    end if;  /* end if for employer_info%FOUND */


    /* archive Releve 2 data */

    ln_index  := pay_ca_eoy_rl2_archive.ltr_ppa_arch_data.count;
    ln_index2  := pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data.count;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).action_info_category
                                         := 'CAEOY TRANSMITTER INFO';

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).jurisdiction_code
                                         := null;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info1
                                         := 'RL2';

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info2
                                         := l_employer_ein;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info3
                                         := l_transmitter_number;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info4
                                         := l_rl_data_type;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info5
                                        := l_rl_package_type;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info6
                                        := l_Transmitter_Type_Indicator;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info7
                                        := l_rl_source_of_slips;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info8
                                        := l_taxation_year;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info9
                                        := l_transmitter_country;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info10
                                        := l_transmitter_name;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info11
                                        := l_transmitter_addr_line_1;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info12
                                        := l_transmitter_addr_line_2;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info13
                                        := l_transmitter_addr_line_3;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info14
                                        := l_transmitter_city;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info15
                                        := l_transmitter_province;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info16
                                        := l_transmitter_postal_code;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info17
                                        := l_technical_contact_name;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info18
                                        := l_technical_contact_area_code;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info19
                                        := l_technical_contact_phone;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info20
                                        := l_technical_contact_extension;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info21
                                        := l_technical_contact_language;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info22
                                         := l_accounting_contact_name;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info23
                                       := l_accounting_contact_area_code;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info24
                                        := l_accounting_contact_phone ;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info25
                                       := l_accounting_contact_extension;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info26
                                       := l_accounting_contact_language;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_data(ln_index).act_info27
                                       := p_pre_org_id;

      /* Archive Employer Data */
      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).action_info_category
                                         := 'CAEOY EMPLOYER INFO';

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).jurisdiction_code
                                         := null;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info1
                                       := 'RL2';

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info2
                                       := l_name;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info3
                                         := l_address_line_1;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info4
                                         := l_address_line_2;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info5
                                         := l_address_line_3;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info6
                                         := l_town_or_city;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info7
                                         := l_province_code;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info8
                                         := l_country_code;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data(ln_index2).act_info9
                                         := l_postal_code;

    l_arch_gre_step := 50;
    l_arch_gre_step := 51;

    /* Other employer level data for RL-2 total is to be discussed ,
       whether it is for Quebec only or not */

    g_archive_flag := 'Y';

   /* Inserting rows into pay_action_information table
      Transmitter PRE Information  */

      if ltr_ppa_arch_data.count >0 then
         hr_utility.trace('Archiving PRE Data');
         archive_data_records(
             p_action_context_id  => p_payroll_action_id
            ,p_action_context_type=> 'PA'
            ,p_assignment_id      => null
            ,p_tax_unit_id        => null
            ,p_effective_date     => l_effective_date
            ,p_tab_rec_data       => pay_ca_eoy_rl2_archive.ltr_ppa_arch_data);
      end if;

    /* Inserting rows into pay_action_information table
       Employer Information (Could be just a PRE or Transmitter PRE) */

      if pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data.count >0 then
         hr_utility.trace('Archiving Employer Data');
         archive_data_records(
           p_action_context_id  => p_payroll_action_id
          ,p_action_context_type=> 'PA'
          ,p_assignment_id      => null
          ,p_tax_unit_id        => null
          ,p_effective_date     => l_effective_date
          ,p_tab_rec_data       => pay_ca_eoy_rl2_archive.ltr_ppa_arch_er_data);
      end if;

    EXCEPTION
     when others then
       g_archive_flag := 'N';
       hr_utility.trace('Error in eoy_archive_gre_data at step :' ||
               to_char(l_arch_gre_step) || 'sqlcode : ' || to_char(sqlcode));
       if l_arch_gre_step = 40 then
       pay_core_utils.push_message(801,'PAY_74014_NO_TRANSMITTER_ORG','A');
       pay_core_utils.push_token('orgind','Prov Reporting Est: '
                                        ||p_pre_org_id);
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
     from pay_action_information
     where action_information1 = 'RL2'
     and action_context_id = p_payroll_action_id;

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
     Purpose   : Calculates and inserts check digit to PDF sequence number - 8500723
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

  /* Function to generate sequence number for RL2 PDFs - Bug 6768167*/

 function gen_rl2_pdf_seq(p_aaid number,
                           p_reporting_year varchar2,
                           called_from varchar2)
  return varchar2 is

  cursor c_get_arch_seq_num(cp_aaid number) is
      select action_information3,
             ACTION_INFORMATION_ID,
             OBJECT_VERSION_NUMBER
      from pay_action_information
      where action_information_category = 'CAEOY RL2 EMPLOYEE INFO2'
            and action_context_id = cp_aaid;

  cursor c_get_seq_num_range(cp_run_year varchar2) is
	select ROW_LOW_RANGE_OR_NAME range_start,
		     ROW_HIGH_RANGE range_end
	from 	pay_user_tables put,
		    pay_user_rows_f pur
	where pur.USER_TABLE_ID=put.USER_TABLE_ID
		and put.USER_TABLE_NAME = 'RL2 PDF Sequence Range'
		and fnd_date.string_to_date('31/12/'||cp_run_year,'DD/MM/YYYY')
			  between pur.EFFECTIVE_START_DATE and pur.EFFECTIVE_END_DATE;

  l_final_seq_num varchar2(25);
  l_start_seq_num varchar2(25);
  l_end_seq_num   varchar2(25);
  l_seq_offset    number;
  l_obj_ver       number;
  l_act_info_id   number;

  begin

    hr_utility.trace('In pay_ca_eoy_rl2_archive.gen_rl2_pdf_seq     10');

    if (called_from = 'XMLPROC') then
      hr_utility.trace('In pay_ca_eoy_rl2_archive.gen_rl2_pdf_seq     20');
      open c_get_arch_seq_num(p_aaid);
      fetch c_get_arch_seq_num into l_final_seq_num,l_act_info_id,l_obj_ver;
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
      hr_utility.trace('In pay_ca_eoy_rl2_archive.gen_rl2_pdf_seq     30');

      select PAY_CA_RL2_PDF_SEQ_COUNT_S.nextval into l_seq_offset
      from dual;
      l_final_seq_num := getnext_seq_num(l_start_seq_num + l_seq_offset); --Bug 8500723
    elsif (called_from ='ARCHIVER') then
      l_final_seq_num := null;
    end if;

    if (called_from ='XMLPROC') then
      hr_utility.trace('In pay_ca_eoy_rl2_archive.gen_rl2_pdf_seq     40');

      pay_action_information_api.update_action_information(p_action_information_id=>l_act_info_id,
                                                           p_object_version_number=>l_obj_ver,
                                                           p_action_information3=>l_final_seq_num);

    end if;

    return l_final_seq_num;

  end gen_rl2_pdf_seq;


  /* Name      : eoy_archive_data
     Purpose   : This is the main procedure to archive the whole employee
                 data along with balance values for RL2 Archiver PreProcess.

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
    l_seq_tab            pay_ca_eoy_rl2_archive.number_data_type_table;
    l_context_id_tab     pay_ca_eoy_rl2_archive.number_data_type_table;
    l_context_val_tab    pay_ca_eoy_rl2_archive.char240_data_type_table;
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
    l_pre_org_id                 varchar2(80);
    l_national_identifier        varchar2(240);
    l_user_entity_value_tab_boxo number := 0;
    l_user_entity_code_tab_boxo  VARCHAR2(4) := NULL;
    l_object_version_number      number;
    l_rl2_slip_number_last_digit number;
    l_rl2_slip_number            number;
    l_negative_balance_exists    varchar2(2);

    l_max_assactid              number;
    l_some_warning              boolean;
    result                      number;
    l_no_of_payroll_run         number := 0;
    l_has_been_paid             varchar2(3);
    l_user_entity_name_tab      pay_ca_eoy_rl2_archive.char240_data_type_table;
    l_user_entity_value_tab     pay_ca_eoy_rl2_archive.char240_data_type_table;
    l_balance_type_tab          pay_ca_eoy_rl2_archive.char240_data_type_table;
    l_footnote_balance_type_tab varchar2(80);
    l_footnote_code             varchar2(30);
    l_footnote_balance          varchar2(80);
    l_footnote_amount           number;
    old_l_footnote_code         varchar2(80) := null;
    old_balance_type_tab        varchar2(80) := null;
    l_footnote_code_ue          varchar2(80);
    l_footnote_amount_ue        varchar2(80);
    l_no_of_fn_codes            number := 0;
    l_value                     number := 0;
    l_transmitter_id            number;
    l_rl2_last_slip_number      number;
    l_rl2_curr_slip_number      number;
    l_max_slip_number           varchar2(80);
    fed_result	                number;

    l_messages  varchar2(240);
    l_mesg_amt  number(12,2) := 0;

    l_action_information_id_1 NUMBER ;
    l_object_version_number_1 NUMBER ;
    ln_tax_unit_id            NUMBER ;
    ld_eff_date               DATE ;

    ln_status_indian          NUMBER := 0;
    ln_index                  NUMBER;
    ln_footnote_index         NUMBER;
    l_rl2_tax_unit_id         pay_assignment_actions.tax_unit_id%type;
    lv_footnote_bal           varchar2(80);

    l_rl2_source_of_income     varchar2(150);
    l_per_eit_source_of_income varchar2(150);
    l_pre_source_of_income     varchar2(150);
    l_per_eit_description      varchar2(150);
    l_pre_description          varchar2(150);
    l_per_eit_beneficiary_id   varchar2(20);
    l_beneficiary_name         varchar2(150);
    l_beneficiary_sin          varchar2(20);
    ln_no_gross_earnings       NUMBER := 0;

    ln_defined_balance_id pay_defined_balances.defined_balance_id%type;
    lv_serial_number           varchar2(30);
    lv_BoxL_excess_amt         varchar2(30);
    lv_BoxO_excess_amt         varchar2(30);
    lv_BoxL_Maxlimit           varchar2(30);
    lv_BoxO_Maxlimit           varchar2(30);

  /* new variables added for Provincial YE Amendment PP */
    lv_fapp_effective_date        varchar2(5);
    ln_fapp_pre_org_id            number;
    lv_fapp_report_type           varchar2(20);
    ln_fapp_locked_action_id      number;
    lv_fapp_flag                  varchar2(2):= 'N';

  /* new variables added for pre-printed form number  */
    lv_eit_year              varchar2(30);
    lv_eit_pre_org_id        varchar2(40);
    lv_eit_form_no           varchar2(20);
    l_pre_printed_slip_no    varchar2(20); -- For Bug 8921055

  cursor c_get_fapp_locked_action_id(cp_locking_act_id number) is
  select locked_action_id
  from pay_action_interlocks
  where locking_action_id = cp_locking_act_id;

  cursor c_get_preprinted_form_no (cp_person_id  number,
                                   cp_pre_org_id number) is
  select pei_information5,
         pei_information6,
         pei_information7
  from  per_people_extra_info
  where person_id        = cp_person_id
  and   pei_information6 = to_char(cp_pre_org_id)
  and   pei_information_category = 'PAY_CA_RL2_FORM_NO';

  /* Cursor to get the all gre values that are under the archived
     transmitter PRE */
  cursor c_all_gres(asgactid number) is
  select hoi.organization_id ,
         hoi.org_information5
  from   pay_action_information pac,
         pay_assignment_actions paa,
         hr_organization_information hoi
  where  paa.assignment_action_id    = asgactid
  and    pac.action_context_id       = paa.payroll_action_id
  and    pac.action_information_category  = 'CAEOY TRANSMITTER INFO'
  and    pac.action_information1     = 'RL2'
  and    pac.action_information27    =  hoi.org_information2
  and    hoi.org_information_context = 'Canada Employer Identification'
  order by 1;

  /* Cursor to get the all gre values that are under the archived
     transmitter PRE */
  cursor c_all_gres_for_footnote(asgactid number) is
  select hoi.organization_id ,
         hoi.org_information5
  from   pay_action_information pac,
         pay_assignment_actions paa,
         hr_organization_information hoi
  where  paa.assignment_action_id    = asgactid
  and    pac.action_context_id       = paa.payroll_action_id
  and    pac.action_information_category  = 'CAEOY TRANSMITTER INFO'
  and    pac.action_information1     = 'RL2'
  and    pac.action_information27    =  hoi.org_information2
  and    hoi.org_information_context = 'Canada Employer Identification'
  order by 1;


  /* c_all_gres_for_person cursor because we not using anymore, 11510 bugfix */

  /* Cursor to get the all the footnote elements that
     are fed to the given balance name */
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
  and    flv.lookup_type           = 'PAY_CA_RL2_FOOTNOTES'
  and    flv.language              = userenv('LANG')
  order by pet.element_information19;

  /* Cursor to get the employee primary address */
  cursor c_get_pri_addr(cp_person_id      in number
                    ,cp_date_earned   in date) is
  select address_line1,
              address_line2,
              address_line3,
              town_or_city,
              decode(country,'US',region_2,'CA',region_1,null),
              replace(postal_code,' '),
              country
        from per_addresses pa
       where pa.person_id =  cp_person_id
         and pa.primary_flag = 'Y'
         and cp_date_earned between pa.date_from
                                   and nvl(pa.date_to, cp_date_earned);

  /* Cursor to get the employee secondary address */
  cursor c_get_sec_addr(cp_person_id      in number
                    ,cp_date_earned   in date) is
  select address_line1,
              address_line2,
              address_line3,
              town_or_city,
              decode(country,'US',region_2,'CA',region_1,null),
              replace(postal_code,' '),
              country
        from per_addresses pa
       where pa.person_id =  cp_person_id
         and pa.primary_flag <> 'Y'
         and cp_date_earned between pa.date_from
                                   and nvl(pa.date_to, cp_date_earned)
  order by pa.date_from desc;

  /* Cursor to get the employee details */
  cursor c_get_emp_detail(cp_asg_id number) is
         select PEOPLE.person_id,
                PEOPLE.first_name,
                PEOPLE.middle_names,
                PEOPLE.last_name,
                PEOPLE.employee_number,
                PEOPLE.date_of_birth,
                replace(PEOPLE.national_identifier,' '),
                PEOPLE.pre_name_adjunct
         from   per_all_assignments_f  ASSIGN
                ,per_all_people_f       PEOPLE
         where   ASSIGN.assignment_id = cp_asg_id
         and     PEOPLE.person_id     = ASSIGN.person_id
         and     PEOPLE.effective_end_date =
                               (select max(effective_end_date)
                                from per_all_people_f PEOPLE1
                                where PEOPLE1.person_id = PEOPLE.person_id);


  /* Query to get the max asg_act_id for a payroll run in a given year
     with tax_unit_id, asg_id and effective_date as parameters. Changed
     cursor to get max asgact_id based on person_id, fix for bug#3638928 */
   CURSOR c_get_max_asg_act_id(cp_person_id number,
                              cp_tax_unit_id number,
                              cp_period_start date,
                              cp_period_end   date) IS
          select paa.assignment_action_id
          from pay_assignment_actions     paa,
               per_all_assignments_f      paf,
               per_all_people_f           ppf,
               pay_payroll_actions        ppa,
               pay_action_classifications pac,
               pay_action_contexts pac1,
               ff_contexts         fc
           where ppf.person_id = cp_person_id
               and paf.person_id     = ppf.person_id
               and paa.assignment_id = paf.assignment_id
               and paa.tax_unit_id   =  cp_tax_unit_id
               and paa.payroll_action_id = ppa.payroll_action_id
               and ppa.action_type = pac.action_type
               and pac.classification_name = 'SEQUENCED'
               and ppa.effective_date between paf.effective_start_date
                                          and paf.effective_end_date
               and ppa.effective_date between ppf.effective_start_date
                                          and ppf.effective_end_date
               and ppa.effective_date between cp_period_start and cp_period_end
               AND pac1.assignment_action_id = paa.assignment_action_id
               AND pac1.assignment_id = paa.assignment_id
               AND fc.context_id = pac1.context_id
               AND fc.context_name    = 'JURISDICTION_CODE'
               AND pac1.context_value  = 'QC'
               order by paa.action_sequence desc;

    CURSOR c_get_person_extra_info (cp_person_id  number,
                                    cp_pre_org_id varchar2) IS
         select pei_information2,
                pei_information3,
                pei_information4
         from per_people_extra_info
         where person_id = cp_person_id
         and pei_information1 = cp_pre_org_id
         and pei_information_category = 'PAY_CA_RL2_INFORMATION';

    /* Bug#3358604, Cursor to get RL2 Box L and O Max Limits for validation */
    CURSOR c_get_rl2box_limits(cp_lookup_code varchar2,
	                           cp_eff_date date) IS
	     select information_value
		 from pay_ca_legislation_info
		 where lookup_type = 'RL2ARCHIVE'
		 and lookup_code = cp_lookup_code
		 and cp_eff_date between start_date and end_date;

  BEGIN

    --hr_utility.trace_on(null,'RL2');
    hr_utility.set_location ('archive_data',1);
    hr_utility.trace('getting assignment');
    l_negative_balance_exists   := 'N';
    l_has_been_paid             := 'N';

    lv_BoxL_Excess_amt := '0';
    lv_BoxO_Excess_amt := '0';

    initialization_process('EMPLOYEE_DATA');

       l_step := 1;
      begin

       SELECT aa.assignment_id,
              pay_magtape_generic.date_earned
                     (p_effective_date,aa.assignment_id),
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
       WHERE  aa.assignment_action_id = p_assactid;

       l_rl2_tax_unit_id := l_tax_unit_id;

       select pay_ca_eoy_rl1_amend_arch.get_parameter('PRE_ORGANIZATION_ID',
                                                      legislative_parameters),
              business_group_id
       into   l_pre_org_id,
              l_business_group_id
       from   pay_payroll_actions
       where  payroll_action_id = l_payroll_action_id;

       exception when no_data_found then
         /* need a pop-message */
         hr_utility.trace('assignment_action_id doesnot exist to archive emp_info'
                           ||to_char(p_assactid));
      end;

    /* If the chunk of the assignment is same as the minimun chunk
       for the payroll_action_id and the gre data has not yet been
       archived then archive the gre data i.e. the employer data */

    if l_chunk = g_min_chunk and g_archive_flag = 'N' then

       hr_utility.trace('eoy_archive_data archiving employer data');
       hr_utility.trace('l_payroll_action_id '|| to_char(l_payroll_action_id));
       hr_utility.trace('l_pre_org_id '|| l_pre_org_id);

       eoy_archive_gre_data(p_payroll_action_id =>l_payroll_action_id,
                            p_pre_org_id=>l_pre_org_id);

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

    /* We can archive the balance level dbis also because for employee level
       balances jurisdiction is always a context. */

    hr_utility.trace('max assignment_action_id : ' || to_char(l_aaid));

    pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',l_aaid);
    pay_balance_pkg.set_context('JURISDICTION_CODE', l_jurisdiction);

    hr_utility.trace('Archiving the balance dbi ' || l_jurisdiction);

    /* RL2 Slip number generation */

    begin
      select decode(hoi.org_information3,'Y',hoi.organization_id,
                                              hoi.org_information20)
      into   l_transmitter_id
      from   hr_organization_information hoi,
             hr_all_organization_units hou
      WHERE  hou.business_group_id = l_business_group_id
      and    hoi.organization_id = hou.organization_id
      and    hoi.org_information_context = 'Prov Reporting Est'
      and    hoi.organization_id = to_number(l_pre_org_id)
      and    hoi.org_information4 = 'P02';


      hr_utility.trace('l_transmitter_id : ' || to_char(l_transmitter_id));

      hr_utility.trace('3');

      select to_number(target.ORG_INFORMATION18)
      into   l_rl2_last_slip_number
      from   hr_organization_information target
      where  target.organization_id = l_transmitter_id
      and    target.org_information_context = 'Prov Reporting Est'
      and    target.ORG_INFORMATION3        = 'Y';

      hr_utility.trace('l_rl2_last_slip_number b4 adding sequence= '|| l_rl2_last_slip_number);

      select l_rl2_last_slip_number + pay_ca_eoy_rl2_s.nextval - 1
      into   l_rl2_curr_slip_number from dual;

      hr_utility.trace('1');

      l_rl2_slip_number_last_digit := mod(l_rl2_curr_slip_number,7);

      hr_utility.trace('l_rl2_curr_slip_number : '||l_rl2_curr_slip_number);
      hr_utility.trace('l_rl2_slip_number_last_digit : '||
                        l_rl2_slip_number_last_digit);

      l_rl2_slip_number := (l_rl2_curr_slip_number)||
                            l_rl2_slip_number_last_digit;

      hr_utility.trace('l_rl2_slip_number : ' || l_rl2_slip_number);

       begin
         select hoi.org_information1,hoi.org_information2
         into   l_pre_source_of_income,l_pre_description
         from   hr_organization_information hoi
         where  hoi.organization_id = l_transmitter_id
         and    hoi.org_information_context = 'Prov Reporting Est2';

         exception
           when no_data_found then
           hr_utility.trace('No RL2 Source of Income at PRE level');
           hr_utility.trace('l_transmitter_id :'||to_char(l_transmitter_id));
           l_pre_source_of_income := NULL;
           l_pre_description := NULL;
       end;

      exception
           when no_data_found then
           hr_utility.trace('Problem in generation of RL2 Slip Number');
           hr_utility.trace('l_transmitter_id :'||to_char(l_transmitter_id));
           /* need a pop-message if rl2 slip number not generated */
           l_rl2_slip_number := 0;

    end;

    /* Initialise the PL/SQL table before populating it */
    hr_utility.trace('Initialising Pl/SQL table');

    l_count := 0;

    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'Gross Earnings';

    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'QPP EE Withheld';

    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'EI EE Withheld';

    -- Quebec Income tax withheld (used for RL2 Box J)
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'PROV Withheld';

    -- RL2 Box A Registered Plan
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'Life Annuity Payments registered plan';

    -- RL2 Box A Unregistered Plan
    l_count := l_count + 1;
    l_balance_type_tab(l_count)  := 'Life Annuity Payments Unregistered plan';

    -- RL2 Box B
    l_count := l_count + 1;
    l_balance_type_tab(l_count) := 'Benefits from RRSP RRIF DPSP and Annuities';

    -- RL2 Box C
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'Other Payments';

    -- RL2 Box D
    l_count := l_count + 1;
    l_balance_type_tab(l_count)
                 := 'Refund of RRSP Premiums paid to surviving spouse';

    -- RL2 Box E
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'Benefits at the time of death';

    -- RL2 Box F
    l_count := l_count + 1;
    l_balance_type_tab(l_count) := 'Refund of Undeducted RRSP contributions';

    -- RL2 Box G
    l_count := l_count + 1;
    l_balance_type_tab(l_count)
              := 'Taxable Amount revoked registration RRSP or RRIF';

    -- RL2 Box H
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'Other Income RRSP or RRIF';

    -- RL2 Box I
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     :=
                       'Amount entitlement deduction for RRSP or RRIF';

    -- RL2 Box K
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     :=
                       'Income earned after death RRSP or RRIF';

    -- RL2 Box L
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     :=
                       'Withdrawal under the Lifelong Learning Plan';

    -- RL2 Box M
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'Tax Paid Amounts';

    -- RL2 Box O
    l_count := l_count + 1;
    l_balance_type_tab(l_count)     := 'Withdrawal under the Home Buyers Plan';

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
      hr_utility.trace('Person_id is ' || lv_serial_number);
      hr_utility.trace('Asgid is ' || to_char(l_asgid));
      hr_utility.trace('Reporting_type is ' || l_reporting_type);
      hr_utility.trace('Effective date is  ' || to_char(p_effective_date));

      begin
        /* Getting Payroll Run Level Max Assignment Action Id for
           the given tax_unit_id in the reporting year. Fix for bug#3638928 */

           open c_get_max_asg_act_id(to_number(lv_serial_number),
                                     l_tax_unit_id,
                                     l_year_start,
                                     l_year_end);
           fetch c_get_max_asg_act_id into l_aaid;
           close c_get_max_asg_act_id;

         hr_utility.trace('l_aaid  is ' || to_char(l_aaid));
         hr_utility.trace('l_count  is ' || to_char(l_count));

         ln_no_gross_earnings := ln_no_gross_earnings +
               nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                      ('RL2 No Gross Earnings',
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

         if l_tax_unit_id <> l_prev_tax_unit_id  or
            l_prev_tax_unit_id is null then

            hr_utility.trace('l_business_group_id  is '||to_char(l_business_group_id));

            pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
            pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',l_aaid);
            Pay_balance_pkg.set_context('JURISDICTION_CODE', 'QC');

            for i in 1 .. l_count
            loop

              hr_utility.trace('l_balance_type  is ' || l_balance_type_tab(i));
              hr_utility.trace('i is ' || i);

              -- T4A earnings should not go to BOX A of RL2

              if l_reporting_type = 'T4A/RL2' and
                 l_balance_type_tab(i) = 'Gross Earnings'
              then
                null;
              else
               --     l_user_entity_value_tab(i) := 0;

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

                      hr_utility.trace('Fed Result = ' || fed_result);
                   else
                      fed_result := 0;
                      hr_utility.trace('Fed Result = ' || fed_result);
                   end if;/*end if for l_balance_type_tab(i)='Gross Earnings' */

                /* Based on defined_balance_id get the balance value
                   for each assignment action */

                ln_defined_balance_id :=
                          get_def_bal_id(l_balance_type_tab(i),
                                         'Person in JD within GRE Year to Date',
                                         'CA');

                l_user_entity_value_tab(i) := l_user_entity_value_tab(i) +
                        nvl(pay_balance_pkg.get_value(ln_defined_balance_id,
                                                      l_aaid),0);

                if l_user_entity_value_tab(i) <> 0 then
                   l_has_been_paid := 'Y';
                   if l_balance_type_tab(i) = 'FED STATUS INDIAN Subject' then
                      ln_status_indian := l_user_entity_value_tab(i);
                   end if;
                end if;

              end if;  -- end if for 'T4A/RL2' validation

              hr_utility.trace('Balance Type is '||l_balance_type_tab(i));
              hr_utility.trace('archive value is '||l_user_entity_value_tab(i));
              l_prev_tax_unit_id  :=  l_tax_unit_id ;

            end loop; -- end loop for all balances plsql table
         end if; --end if for l_tax_unit_id <> l_prev_tax_unit_id validation

         exception
           when no_data_found then
           hr_utility.trace('This Tax unit id has no payroll run, so skip it');
           /* need a pop-message asgid has no payroll run in tax-unit-id */
      end;
    end loop;
    close c_all_gres;

    hr_utility.trace('l_no_of_payroll_run is ' || l_no_of_payroll_run);

    ln_index  := pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data.count;
    ln_footnote_index := pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data.count;

    hr_utility.trace('ln_index :'||to_char(ln_index));
    hr_utility.trace('ln_footnote_index :'||to_char(ln_footnote_index));

   if ((l_no_of_payroll_run > 0) and
       ((l_has_been_paid = 'Y') or (ln_no_gross_earnings <> 0)) ) then

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info1
                                                 := l_rl2_slip_number;
       for i in 1 .. l_count
       loop

         hr_utility.trace('in the employee info archive loop');
         hr_utility.trace('Balance name is '|| l_balance_type_tab(i));
         hr_utility.trace('value tab  is '|| l_user_entity_value_tab(i));
         /*
         lv_BoxL_excess_amt := '0';
         lv_BoxO_excess_amt := '0';
         */

         if l_balance_type_tab(i) =
                 'Life Annuity Payments registered plan' then
            pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info3
                                             := l_user_entity_value_tab(i);
            hr_utility.trace('ln_index :'||to_char(ln_index));

         elsif l_balance_type_tab(i) =
                    'Life Annuity Payments Unregistered plan' then

            pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info3
             := to_number
             (pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info3)
               + to_number(nvl(l_user_entity_value_tab(i),0));

         elsif l_balance_type_tab(i) =
             'Benefits from RRSP RRIF DPSP and Annuities' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info4
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) = 'Other Payments' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info5
                                                := l_user_entity_value_tab(i);
             hr_utility.trace('Box C :'||pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info5);

         elsif l_balance_type_tab(i) =
                    'Refund of RRSP Premiums paid to surviving spouse' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info6
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) = 'Benefits at the time of death' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info7
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) =
                             'Refund of Undeducted RRSP contributions' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info8
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) =
          'Taxable Amount revoked registration RRSP or RRIF' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info9
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) = 'Other Income RRSP or RRIF' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info10
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) =
                       'Amount entitlement deduction for RRSP or RRIF' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info11
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) = 'PROV Withheld' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info12
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) =
                      'Income earned after death RRSP or RRIF' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info13
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i) =
                      'Withdrawal under the Lifelong Learning Plan' then

               /* Bug#3358604, if Box L is more than $10,000.00 put excess
	          amount in Box C */
		  open c_get_rl2box_limits('BOXL_MAXLIMIT',p_effective_date);
                  fetch c_get_rl2box_limits into lv_boxL_Maxlimit;
		  close c_get_rl2box_limits;

        	  if to_number(l_user_entity_value_tab(i)) > to_number(lv_boxL_Maxlimit) then

                     lv_BoxL_excess_amt :=  to_char(to_number(l_user_entity_value_tab(i))
				                    - to_number(lv_boxL_Maxlimit)) ;
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info14
                                                := lv_boxL_Maxlimit;
                  else
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info14
                                                := l_user_entity_value_tab(i);
		  end if;

         elsif l_balance_type_tab(i) = 'Tax Paid Amounts' then
             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info15
                                                := l_user_entity_value_tab(i);

         elsif l_balance_type_tab(i)
                              = 'Withdrawal under the Home Buyers Plan' then

               /* Bug#3358604, if Box O is more than $20,000.00 put excess
	          amount in Box C */
	          open c_get_rl2box_limits('BOXO_MAXLIMIT',p_effective_date);
		  fetch c_get_rl2box_limits into lv_boxO_Maxlimit;
		  close c_get_rl2box_limits;

      		  if to_number(l_user_entity_value_tab(i)) > to_number(lv_boxO_Maxlimit) then

                     lv_BoxO_excess_amt :=  to_char(to_number(l_user_entity_value_tab(i))
				                           - to_number(lv_boxO_Maxlimit));
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info17
                                                := lv_boxO_Maxlimit;
                  else
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info17
                                                := l_user_entity_value_tab(i);
		  end if;

         end if;


         hr_utility.trace('value tab  is '|| l_user_entity_value_tab(i));

         if to_number(nvl(l_user_entity_value_tab(i),'0')) < 0 then

            hr_utility.trace('Negative balance exists');
            l_negative_balance_exists := 'Y';
         end if;

         if l_user_entity_value_tab(i) <> 0 then

            if l_balance_type_tab(i)
                        = 'Life Annuity Payments Unregistered plan' then
                begin

                  /* RL2 Automatic Footnote Archive Start */
                  l_footnote_code := 'BOXA';
                  if chk_rl2_footnote(l_footnote_code) then

                     l_footnote_amount
                           := to_number(nvl(l_user_entity_value_tab(i),0));
                     ln_footnote_index := ln_footnote_index;
                     hr_utility.trace(' Box A ln_footnote_index :'
                                       ||to_char(ln_footnote_index));

                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).action_info_category := 'CA FOOTNOTES';
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).jurisdiction_code := 'QC';
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).act_info4 := l_footnote_code;
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).act_info5 :=
                                                   to_char(l_footnote_amount);
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).act_info6 := 'RL2';

                     if l_footnote_amount < 0 then

                         hr_utility.trace('Negative balance exists');
                         l_negative_balance_exists := 'Y';
                     end if;

                  end if; /* end if for chk_rl2_footnote */
                end ; /* end of RL2 Automatic footnote archive */
            else
               l_footnote_balance_type_tab := l_balance_type_tab(i);
            end if; /* end if for l_balance_type_tab(i)= 'Life Annuity...' */

            if l_footnote_balance_type_tab in
                       ('Benefits from RRSP RRIF DPSP and Annuities',
                                               'Other Payments') then
               begin

                   hr_utility.trace('RL2 Footnote archive start ');
                   lv_footnote_bal := l_footnote_balance_type_tab;
                   l_footnote_code := NULL;
                   old_l_footnote_code := NULL;
                   l_footnote_amount := 0;

                 open c_footnote_info(lv_footnote_bal);
                   hr_utility.trace('lv_footnote_bal is '||lv_footnote_bal);

                 loop
                   fetch c_footnote_info into l_footnote_code,
                                              l_footnote_balance;
                   exit when c_footnote_info%NOTFOUND;

                   hr_utility.trace('l_footnote_amount_balance is '||
                                     l_footnote_balance);
                   hr_utility.trace('l_footnote_code is '||
                                     l_footnote_code);

                  if ( l_footnote_code <>  old_l_footnote_code or
                       old_l_footnote_code is null )
                  then
                     if old_l_footnote_code is not null then

                        hr_utility.trace('old_l_footnote_code is '||
                                                  old_l_footnote_code);
                        hr_utility.trace('l_footnote_amount is '||
                                           to_char(l_footnote_amount));

                        if chk_rl2_footnote(old_l_footnote_code) and
                           l_footnote_amount <> 0 then

                            hr_utility.trace('RL2 footnote archiving ');
                            ln_footnote_index := ln_footnote_index + 1;
                            hr_utility.trace('old_l_ftcode ln_footnote_index :'
                                       ||to_char(ln_footnote_index));

                             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                               (ln_footnote_index).action_info_category
                                                 := 'CA FOOTNOTES';

                             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                             (ln_footnote_index).jurisdiction_code := 'QC';

                             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                             (ln_footnote_index).act_info4
                                                  := old_l_footnote_code;

                             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                             (ln_footnote_index).act_info5
                                                := to_char(l_footnote_amount);

                             pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                             (ln_footnote_index).act_info6 := 'RL2';

                             if l_footnote_amount < 0 then

                                 hr_utility.trace('Negative balance exists');
                                 l_negative_balance_exists := 'Y';
                             end if;

                        end if;/* end if for chk_rl2_footnote */

                     end if; /* end if for old_l_footnote_code not null */

                     l_footnote_amount := 0;
                     old_l_footnote_code :=  l_footnote_code ;
                     old_balance_type_tab :=  l_footnote_balance_type_tab ;

                  end if; /* end if for l_footnote_code<>old_l_footnote_code*/

                  l_prev_tax_unit_id := NULL;

                  -- get the footnote_balance

                  open c_all_gres_for_footnote(p_assactid);
                  loop
                    hr_utility.trace('Fetching all GREs for footnotes');
                    fetch c_all_gres_for_footnote into l_tax_unit_id,
                                                       l_reporting_type;
                    exit when c_all_gres_for_footnote%NOTFOUND;

                    hr_utility.trace('Tax unit id is ' || l_tax_unit_id);
                    hr_utility.trace('Asgid is ' || l_asgid);
                    hr_utility.trace('Reporting_type is ' || l_reporting_type);
                    hr_utility.trace('Effective date is '|| p_effective_date);

                    begin
                      open c_get_max_asg_act_id(to_number(lv_serial_number),
                                                l_tax_unit_id,
                                                l_year_start,
                                                l_year_end);
                      fetch c_get_max_asg_act_id into l_aaid;
                      close c_get_max_asg_act_id;

                      hr_utility.trace('l_aaid  is ' || l_aaid);
                      hr_utility.trace('l_count  is ' || l_count);

                      l_no_of_payroll_run := l_no_of_payroll_run + 1;

                      if ( l_tax_unit_id <> l_prev_tax_unit_id  or
                           l_prev_tax_unit_id is null )
                      then
                         pay_balance_pkg.set_context('TAX_UNIT_ID',
                                                     l_tax_unit_id);
                         pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',
                                                     l_aaid);
                         pay_balance_pkg.set_context('JURISDICTION_CODE', 'QC');

                         l_footnote_amount := l_footnote_amount +
                           nvl(pay_ca_balance_pkg.call_ca_balance_get_value
                          ( l_footnote_balance,
                           'YTD' ,
                            l_aaid,
                            l_asgid ,
                            NULL,
                            'PER' ,
                            l_tax_unit_id,
                            l_business_group_id,
                            'QC'
                           ),0) ;

                            hr_utility.trace('l_footnote_amount  is '
                                               || to_char(l_footnote_amount));
                      end if;

                      l_prev_tax_unit_id  :=  l_tax_unit_id ;
                      exception
                         when no_data_found then
                         /* need a pop-message asgid has not payrollrun in tx*/
                         hr_utility.trace('This Tax unit id has no payroll run'
                                           ||' so skip it');
                    end;
                  end loop;
                  close c_all_gres_for_footnote;

                    --  end of getting balance

                   if l_footnote_amount <> 0 then
                      l_no_of_fn_codes := l_no_of_fn_codes + 1;
                      hr_utility.trace('l_no_of_fn_codes  is '
                                              || l_no_of_fn_codes);
                   end if;

                 end loop;  -- c_footnote_info loop
                 close c_footnote_info;

                 -- Archiving the last footnote code and amount
                 if chk_rl2_footnote(l_footnote_code) and
                    l_footnote_amount <> 0 then

                    hr_utility.trace('p_assactid  is ' ||to_char(p_assactid));
                    hr_utility.trace('before ftnote archive l_footnote_code is '
                                     || l_footnote_code);
                    hr_utility.trace('l_footnote_amount  is '
                                     || to_char(l_footnote_amount));

                     hr_utility.trace('RL2 footnote archiving ');
                     ln_footnote_index := ln_footnote_index + 1;
                     hr_utility.trace('after close c_footnote_info ln_footnote_index :'
                                       ||to_char(ln_footnote_index));

                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).action_info_category := 'CA FOOTNOTES';
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).jurisdiction_code := 'QC';
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).act_info4 := l_footnote_code;
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).act_info5 := to_char(l_footnote_amount);
                     pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                     (ln_footnote_index).act_info6 := 'RL2';

                     if l_footnote_amount < 0 then

                         hr_utility.trace('Negative balance exists');
                         l_negative_balance_exists := 'Y';
                     end if;

                  end if;/* end if for chk_rl2_footnote */

               end;
                   hr_utility.trace('RL2 Footnote archive end ');
            end if; /* end if for l_footnote_balance_type_tab in validation */
         -- End of footnote archiving

         end if; /* end if for l_user_entity_value_tab(i) <>0 */

       end loop; /* end loop for plsql table balances */

       /* Bug#3358604 Adding Box L,O excess Amount to Box C */
         hr_utility.trace('lv_BoxL_excess_amt : '||lv_BoxL_excess_amt);
         hr_utility.trace('lv_BoxO_excess_amt : '||lv_BoxO_excess_amt);

         if ((lv_BoxL_Excess_amt > 0) or (lv_BoxO_Excess_amt > 0)) then
              pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info5
              := to_char(NVL(to_number(pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info5),0)
                 + to_number(lv_BoxL_excess_amt) + to_number(lv_BoxO_excess_amt));
              hr_utility.trace('Box C : '||pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info5);
         end if;

       /* Set the Negative Balance Flag for Archiving */
       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info30
                                               := l_negative_balance_exists;

       hr_utility.trace('after loop act_info4 is: '
            || pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info4);

    end if; /* end if for ((l_no_of_payroll_run >0) and (l_has_been_paid='Y'))*/

    --  Need to Archive Non-Box Footnotes, will be done next year

    l_count := 0;
    -- Similarly create archive data for employee surname,employee first name,
    --   employee initial, employee address ,city,province,country,postal code,
    --   SIN, employee number , business number .
    --   Not all of them has jurisdiction context.

    if ((l_no_of_payroll_run > 0) and
        ((l_has_been_paid = 'Y') or (ln_no_gross_earnings <> 0)) ) then

       begin

         open c_get_emp_detail(l_asgid);
         fetch c_get_emp_detail into
               l_person_id,
               l_first_name,
               l_middle_name,
               l_last_name,
               l_employee_number,
               l_date_of_birth,
               l_national_identifier,
               l_pre_name_adjunct;

              if c_get_emp_detail%NOTFOUND then

                 /* need a pop-message employee basic data absent */
                 l_first_name := null;
                 l_middle_name := null;
                 l_last_name := null;
                 l_employee_number := null;
                 l_national_identifier := null;
                 l_pre_name_adjunct := null;
                 l_employee_phone_no := null;
                 l_date_of_birth     := null;
              end if;
          close c_get_emp_detail;
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

         open c_get_person_extra_info(l_person_id, l_pre_org_id);
         fetch c_get_person_extra_info into
                     l_per_eit_source_of_income,
                     l_per_eit_description,
                     l_per_eit_beneficiary_id;

         if c_get_person_extra_info%NOTFOUND then
              close c_get_person_extra_info;
              l_per_eit_source_of_income := null;
              l_per_eit_description      := null;
              l_per_eit_beneficiary_id   := null;
         else
              close c_get_person_extra_info;
         end if;

         if l_per_eit_beneficiary_id is not null then
            begin
              select  ppf.full_name,
                      replace(ppf.national_identifier,' ')
                into  l_beneficiary_name,
                      l_beneficiary_sin
              from per_all_people_f ppf
              where ppf.person_id = to_number(l_per_eit_beneficiary_id);

              exception when no_data_found then
                      l_beneficiary_name := null;
                      l_beneficiary_sin  := null;
            end;
         end if;


       if l_per_eit_source_of_income is not null then
          if l_per_eit_source_of_income = 'OTHER' then
             l_rl2_source_of_income := l_per_eit_source_of_income||':'||
                                       l_per_eit_description;

             -- Added Source of Income 'Other' to be archived as footnote Bug#3531136
                ln_footnote_index := ln_footnote_index + 1;
                hr_utility.trace('Archiving Source of Income Other as Footnote ln_footnote_index :'
                                 ||to_char(ln_footnote_index));

                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).action_info_category := 'CA FOOTNOTES';
                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).jurisdiction_code := 'QC';
                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).act_info4 := l_rl2_source_of_income;
                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).act_info5 := '0';
                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).act_info6 := 'RL2';
          else
             l_rl2_source_of_income := l_per_eit_source_of_income;
          end if;
       else
          if l_pre_source_of_income = 'OTHER' then
             l_rl2_source_of_income := l_pre_source_of_income||':'||
                                       l_pre_description;

             -- Added Source of Income 'Other' to be archived as footnote Bug#3531136
                ln_footnote_index := ln_footnote_index + 1;
                hr_utility.trace('Archiving Source of Income Other as Footnote ln_footnote_index :'
                                 ||to_char(ln_footnote_index));

                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).action_info_category := 'CA FOOTNOTES';
                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).jurisdiction_code := 'QC';
                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).act_info4 := l_rl2_source_of_income;
                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).act_info5 := '0';
                pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data
                (ln_footnote_index).act_info6 := 'RL2';
          else
             l_rl2_source_of_income := l_pre_source_of_income;
          end if;
       end if;


       hr_utility.trace('Before counter of asgid '|| l_asgid);

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).action_info_category
                                  := 'CAEOY RL2 EMPLOYEE INFO';

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).jurisdiction_code
                                  := l_jurisdiction;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info2
                                  := l_rl2_source_of_income;

       -- RL2 Box N SIN of Spouse
       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info16
                                  := l_beneficiary_sin;

       hr_utility.trace('Employee Info ln_index: '||to_char(ln_index));
       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info18
                                  := l_first_name;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info20
                                  := l_last_name ;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info19
                                  := l_middle_name ;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info28
                                  := l_national_identifier;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info29
                                  := l_employee_number;

    end if;

    if ((l_no_of_payroll_run > 0) and
        ((l_has_been_paid = 'Y') or (ln_no_gross_earnings <> 0)) ) then

       begin
         open c_get_pri_addr(l_person_id,l_date_earned);
         fetch c_get_pri_addr into l_address_line1
                              ,l_address_line2
                              ,l_address_line3
                              ,l_town_or_city
                              ,l_province_code
                              ,l_postal_code
                              ,l_country_code;
            if c_get_pri_addr%NOTFOUND then
               open c_get_sec_addr(l_person_id,l_date_earned);
               fetch c_get_sec_addr into l_address_line1
                              ,l_address_line2
                              ,l_address_line3
                              ,l_town_or_city
                              ,l_province_code
                              ,l_postal_code
                              ,l_country_code;
                if c_get_sec_addr%NOTFOUND then
                   pay_core_utils.push_message(800,'HR_74010_NO_RES_ADDRESS','A');

                   l_address_line1 := null;
                   l_address_line2 := null;
                   l_address_line3 := null;
                   l_town_or_city  := null;
                   l_province_code := null;
                   l_postal_code   := null;
                   l_telephone_number := null;
                   l_country_code  := null;
                end if;
                close c_get_sec_addr;
            end if; /* c_get_pri_addr%NOTFOUND */
         close c_get_pri_addr;
       end;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info21
                                := l_address_line1;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info22
                                := l_address_line2;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info23
                                := l_address_line3;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info24
                                := l_town_or_city;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info25
                                := l_province_code;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info27
                                := l_country_code;

       pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data(ln_index).act_info26
                                := l_postal_code;

    end if;

       /* Inserting rows into pay_action_information table
          RL2 Employee Data Archived */

      if pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data.count >0 then
         archive_data_records(
           p_action_context_id  => p_assactid
          ,p_action_context_type=> 'AAP'
          ,p_assignment_id      => l_asgid
          ,p_tax_unit_id        => l_rl2_tax_unit_id
          ,p_effective_date     => p_effective_date
          ,p_tab_rec_data       => pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data);
           ln_index := null;
      end if;

      if pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data.count >0 then
         archive_data_records(
           p_action_context_id  => p_assactid
          ,p_action_context_type=> 'AAP'
          ,p_assignment_id      => l_asgid
          ,p_tax_unit_id        => l_rl2_tax_unit_id
          ,p_effective_date     => p_effective_date
          ,p_tab_rec_data       => pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_ft_data);
           ln_footnote_index := null;
      end if;

      --hr_utility.trace_on('Y','SAM');
      hr_utility.trace('Started Provincial YE Amendment');

      select to_char(effective_date,'YYYY'),
             report_type,
             to_number(pay_ca_eoy_rl1_amend_arch.get_parameter('PRE_ORGANIZATION_ID',
                                                               legislative_parameters))
      into lv_fapp_effective_date,
           lv_fapp_report_type,
           ln_fapp_pre_org_id
      from pay_payroll_actions
      where payroll_action_id = l_payroll_action_id;

      hr_utility.trace('lv_fapp_report_type :'||lv_fapp_report_type);


         /* Archive the Pre-Printed form number for the RL2
            Amendment Pre-Process if one exists*/

      ln_index  := pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2.count;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2(ln_index).action_info_category
                                     := 'CAEOY RL2 EMPLOYEE INFO2';

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2(ln_index).jurisdiction_code
                                     := l_jurisdiction;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2(ln_index).act_info1
                                     := null;

      open c_get_preprinted_form_no (l_person_id, ln_fapp_pre_org_id);
      loop
        fetch c_get_preprinted_form_no
        into  lv_eit_year,
              lv_eit_pre_org_id,
              lv_eit_form_no;

        exit when c_get_preprinted_form_no%NOTFOUND;

        if ((lv_fapp_effective_date =
               to_char(fnd_date.canonical_to_date(lv_eit_year), 'YYYY')) and
            (ln_fapp_pre_org_id = to_number(lv_eit_pre_org_id))) then

           pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2(ln_index).act_info1
                                            := lv_eit_form_no;
        end if;

      end loop;

      close c_get_preprinted_form_no;
      -- For Bug 8921055
      l_pre_printed_slip_no := pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2(ln_index).act_info1;

      if lv_fapp_report_type = 'CAEOY_RL2_AMEND_PP' then

         open c_get_fapp_locked_action_id(p_assactid);
         fetch c_get_fapp_locked_action_id into ln_fapp_locked_action_id;
         close c_get_fapp_locked_action_id;

         hr_utility.trace('RL2 Amend Action ID : '||to_char(p_assactid));
         hr_utility.trace('ln_fapp_locked_action_id :'||  to_char(ln_fapp_locked_action_id));

       -- For Bug 8921055
         lv_fapp_flag := compare_archive_data(p_assactid,
                                              ln_fapp_locked_action_id,l_pre_printed_slip_no);

      end if; -- report type validation for FAPP

      hr_utility.trace('Archiving RL2 Amendment Flag : ' || lv_fapp_flag);
      pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2(ln_index).act_info2
                                          := lv_fapp_flag;

      pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2(ln_index).act_info3 :=
                                    gen_rl2_pdf_seq(p_assactid,
                                                    to_char(p_effective_date,'YYYY'),
                                                    'ARCHIVER');

      if pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2.count >0 then
         archive_data_records(
           p_action_context_id  => p_assactid
          ,p_action_context_type=> 'AAP'
          ,p_assignment_id      => l_asgid
          ,p_tax_unit_id        => l_rl2_tax_unit_id
          ,p_effective_date     => p_effective_date
          ,p_tab_rec_data       => pay_ca_eoy_rl2_archive.ltr_ppa_arch_ee_data2);
           ln_index := null;
      end if;

      hr_utility.trace('End of Provincial YE Amendment PP Validation');

  end eoy_archive_data;


    -- Name      : eoy_range_cursor
    -- Purpose   : This returns the select statement that is used to created
    --             the range rows for the Year End Pre-Process.
    -- Arguments :
    -- Notes     :


  procedure eoy_range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  l_pre_org_id         varchar2(50);
  l_archive            boolean:= FALSE;
  l_business_group     number;
  l_year_start         date;
  l_year_end           date;

  begin

     select pay_ca_eoy_rl1_amend_arch.get_parameter('PRE_ORGANIZATION_ID',
                                                    legislative_parameters),
            trunc(effective_date,'Y'),
            effective_date,
            business_group_id
     into   l_pre_org_id,
            l_year_start,
            l_year_end,
            l_business_group
     from pay_payroll_actions
     where payroll_action_id = pactid;

     hr_utility.trace('in range cursor step 1');

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
                        and hoi.org_information2  = '''|| l_pre_org_id ||''''||'
                        and hoi.org_information5 = ''T4A/RL2'')
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
           /* Now the archiver has provision for archiving
              payroll_action_level data . So make use of that */
            eoy_archive_gre_data(pactid,
                                 l_pre_org_id);
           hr_utility.trace('eoy_range_cursor archived employer data');
         end if;

  end eoy_range_cursor;



end pay_ca_eoy_rl2_archive;

/
