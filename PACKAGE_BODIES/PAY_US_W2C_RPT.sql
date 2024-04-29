--------------------------------------------------------
--  DDL for Package Body PAY_US_W2C_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W2C_RPT" AS
/* $Header: pyusw2cr.pkb 120.3.12010000.2 2009/03/05 06:52:39 asgugupt ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_w2c_rpt

    Description : This procedure is used by  Employee W-2C Report

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    10-AUG-2003 asasthan   115.0            Created.
    10-AUG-2003 irgonzal   115.1            Modified get_payroll_action_info:
                                            Removed to_number function for
                                            PRINT parameter.

    10-AUG-2003 asasthan   115.9            Added logic for Print 'ALL'.
    19-FEB-2003 asasthan   115.10           changed get_prev curosors
                                            added date effective join
    25-OCT-2004 schauhan   115.11  3601799  Added selection criteria for "All"
                                            if the report is Run with print
                                            option "Reprint All W2c".
                                            Made changes to  w2crpt_range_cursor
					    and w2crpt_action_creation Cursor.
    05-NOV-2004 schauhan   115.12           Added 'Distinct' to the Range Cursor
                                            w2crpt_range_cursor.
    22-NOV-2004 ahanda     115.13  3601799  Fixed issue in the bug. Changed the
                                            action creation, range and sort
                                            procedures.
    16-DEC-2004 ahanda     115.14  4039440  Changed sort code to reduce length
                                            to get around c-code issue.
    14-MAR-2005 sackumar   115.15  4222032  Change in the Range Cursor removing redundant
					    use of bind Variable (:payroll_action_id)
    04-AUG-2005 pragupta   115.16  3679317  Change in procedure sort_action. Removed
                                            +0 from paf and hou for removing FTS and
					    performance improvement
    14-MAR-2006 ppanda     115.17  4583575  To reduce the shared memory per_all_assignments_f
                                            used instead of  per_assignments_f.
    31-MAR-2006 sodhingr   115.18  5111088  removed the comment from sort_cursor to fix signal
                                            11 error.
    05-MAR-2009 asgugupt   115.19  6349762  Adding Order by clause in Range Cursor
*****************************************************************************/

   gv_package        VARCHAR2(100);
   gv_procedure_name VARCHAR2(100);

  /*****************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for  W-2C PAPER.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_start_date        - Start date of W-2C PAPER
               p_end_date          - End date of W-2C PAPER
               p_business_group_id - Business Group ID
  *****************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     in number
                                   ,p_end_date             out nocopy date
                                   ,p_start_date           out nocopy date
                                   ,p_business_group_id    out nocopy number
                                   ,p_tax_unit_id          out nocopy number
                                   ,p_person_id            out nocopy number
                                   ,p_asg_set              out nocopy number
                                   ,p_print                out nocopy varchar2
                                   ,p_sort_option1         out nocopy varchar2
                                   ,p_sort_option2         out nocopy varchar2
                                   ,p_sort_option3         out nocopy varchar2
                                   ,p_session_date         out nocopy date
                                   )
  IS
    cursor c_payroll_Action_info (cp_payroll_action_id in number) is
      select
          pay_us_payroll_utils.get_parameter('TRANSFER_GRE',ppa.legislative_parameters),
          pay_us_payroll_utils.get_parameter('PER_ID',ppa.legislative_parameters),
          pay_us_payroll_utils.get_parameter('ASG_SET',ppa.legislative_parameters),
          pay_us_payroll_utils.get_parameter('PRINT',ppa.legislative_parameters),
          effective_date,
          start_date,
          business_group_id,
          pay_us_payroll_utils.get_parameter('S1',ppa.legislative_parameters),
          pay_us_payroll_utils.get_parameter('S2',ppa.legislative_parameters),
          pay_us_payroll_utils.get_parameter('S3',ppa.legislative_parameters),
          to_date(pay_us_payroll_utils.get_parameter('EFFECTIVE_DATE',
                                               ppa.legislative_parameters)
                 ,'dd-mon-yyyy')
        from pay_payroll_actions ppa
       where ppa.payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_tax_unit_id       NUMBER;
    ln_person_id         NUMBER;
    ln_asg_set           NUMBER;
    lv_print             VARCHAR2(60);
    lv_sort1             VARCHAR2(60);
    lv_sort2             VARCHAR2(60);
    lv_sort3             VARCHAR2(60);
    ld_session_date      DATE;

  BEGIN
    hr_utility.trace('Entered get_payroll_action_info');
    ln_tax_unit_id := 0;
    ln_person_id   := 0;
    ln_asg_set     := 0;
    open c_payroll_action_info(p_payroll_action_id);
    fetch c_payroll_action_info into ln_tax_unit_id,
                                     ln_person_id,
                                     ln_asg_set,
                                     lv_print,
                                     ld_end_date,
                                     ld_start_date,
                                     ln_business_group_id,
                                     lv_sort1,
                                     lv_sort2,
                                     lv_sort3,
                                     ld_session_date;
    close c_payroll_action_info;

    hr_utility.trace('ld_end_date = '   || to_char(ld_end_date));
    hr_utility.trace('ld_start_date = ' || to_char(ld_start_date));
    hr_utility.trace('ln_tax_unit_id = '|| to_char(ln_tax_unit_id));
    hr_utility.trace('ln_person_id = '  || to_char(ln_person_id));
    hr_utility.trace('ln_asg_set = '    || to_char(ln_asg_set));

    p_end_date          := ld_end_date;
    p_start_date        := ld_start_date;
    p_business_group_id := ln_business_group_id;
    p_tax_unit_id       := ln_tax_unit_id;
    p_person_id         := ln_person_id;
    p_asg_set           := ln_asg_set;
    p_print             := lv_print;
    p_sort_option1      := lv_sort1;
    p_sort_option2      := lv_sort2;
    p_sort_option3      := lv_sort3;
    p_session_date      := ld_session_date;

    hr_utility.trace('Leaving get_payroll_action_info');

  EXCEPTION
    when others then
       hr_utility.trace('Error in ' || gv_procedure_name ||
                         to_char(sqlcode) || '-' || sqlerrm);
       raise hr_utility.hr_error;

  END get_payroll_action_info;


  /******************************************************************
   Name      : w2crpt_range_cursor
   Purpose   : This returns the select statement that is
               used to created the range rows for the
               W-2C PAPER.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE w2crpt_range_cursor(
                    p_payroll_action_id in number
                   ,p_sqlstr           out nocopy  varchar2)
  IS
    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_tax_unit_id       NUMBER;
    ln_person_id         NUMBER;
    ln_asg_set           NUMBER;
    lv_sort1             VARCHAR2(60);
    lv_sort2             VARCHAR2(60);
    lv_sort3             VARCHAR2(60);
    ld_session_date      DATE;

    lv_sql_string        VARCHAR2(32000);
    ln_eoy_pactid        number;
    lv_print             varchar2(10);
    lv_error_mesg        varchar2(100);
    ln_agent_tax_unit_id pay_assignment_actions.tax_unit_id%type;
    ln_year              number;

  BEGIN
     hr_utility.trace('Entered w2crpt_range_cursor');
     ln_person_id  := 0;
     ln_asg_set    := 0;
     lv_print      := null;
     hr_utility.trace('p_payroll_action_id = ' ||
                             to_char(p_payroll_action_id));

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_tax_unit_id       => ln_tax_unit_id
                            ,p_person_id         => ln_person_id
                            ,p_asg_set           => ln_asg_set
                            ,p_print             => lv_print
                            ,p_sort_option1      => lv_sort1
                            ,p_sort_option2      => lv_sort2
                            ,p_sort_option3      => lv_sort3
                            ,p_session_date      => ld_session_date);

     -- Bug 3601799  - Added condition.
     IF ln_person_id IS NOT NULL OR ln_asg_set IS NOT NULL THEN
        ln_year := to_number(to_char(ld_end_date,'YYYY'));

        hr_utility.trace('Checking for Preprocess Agent GRE setup');
        hr_us_w2_rep.get_agent_tax_unit_id(ln_business_group_id
                                          ,ln_year
                                          ,ln_agent_tax_unit_id
                                          ,lv_error_mesg   ) ;

        if lv_error_mesg is not null then
           if substr(lv_error_mesg,1,45) is not null then
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',' ');
              pay_core_utils.push_token('description',substr(lv_error_mesg,1,45));
           end if;

           if substr(lv_error_mesg,46,45) is not null then
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',' ');
              pay_core_utils.push_token('description',substr(lv_error_mesg,46,45));
           end if;

           if substr(lv_error_mesg,91,45) is not null then
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',' ');
              pay_core_utils.push_token('description',substr(lv_error_mesg,91,45));
           end if;

           if substr(lv_error_mesg,136,45) is not null then
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',' ');
              pay_core_utils.push_token('description',substr(lv_error_mesg,136,45));
           end if;

           hr_utility.raise_error;

        end if;


        if ln_person_id is not null then

           lv_sql_string :=
            'select distinct asg.person_id person_id
               from per_all_assignments_f asg
              where person_id = ' || ln_person_id ||
            ' and :p_payroll_action_id is not null ';

           hr_utility.trace('Range for person_id not null');

        elsif ln_asg_set is not null then

           lv_sql_string :=
              'select distinct paf.person_id
                from hr_assignment_set_amendments asgset,
                     per_all_assignments_f paf
               where assignment_set_id = ' || ln_asg_set || '
                 and asgset.assignment_id = paf.assignment_id
                 and asgset.include_or_exclude = ''I''
                 and :payroll_action_id is not null order by paf.person_id';

           hr_utility.trace('Range for asg_set not null');
        end if;

     -- Bug 3601799
     -- This query string will be executed when for All parameter is passed.
     ELSE
        lv_sql_string :=
          'select distinct paa.serial_number
	     from pay_assignment_actions paa,
	          pay_payroll_actions ppa
	    where ppa.report_type = ''W2C_PRE_PROCESS''
	     and ppa.effective_date = add_months(''' || ld_start_date || ''',12) -1
	     and ppa.business_group_id+0 = ' || ln_business_group_id ||'
	     and ltrim(rtrim(
                    substr(ppa.legislative_parameters,
                           instr(ppa.legislative_parameters,''TRANSFER_GRE='')
                           + length(''TRANSFER_GRE='')
                          ,instr(ppa.legislative_parameters,'' '',2))))
                       =  to_char(' || ln_tax_unit_id || ')
	     and paa.payroll_action_id = ppa.payroll_action_id
	     and paa.action_status = ''C''
	     and paa.tax_unit_id = ' || ln_tax_unit_id || '
	     and :payroll_action_id is not null
	   order by paa.serial_number';

	hr_utility.trace('Range for all the persons.');
     END IF;

     p_sqlstr := lv_sql_string;
     hr_utility.trace('p_sqlstr = ' ||p_sqlstr);
     hr_utility.trace('Leaving w2crpt_range_cursor');
  END w2crpt_range_cursor;


  /************************************************************
   Name      : w2crpt_action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the W2C Report process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE w2crpt_action_creation(
                 p_payroll_action_id   in number
                ,p_start_person_id     in number
                ,p_end_person_id       in number
                ,p_chunk               in number)

  IS

    ln_assignment_id          NUMBER;
    ln_tax_unit_id            NUMBER;
    ld_effective_date         DATE ;
    ln_asg_action_id          NUMBER;
    ln_primary_assignment_id  NUMBER;
    ln_yepp_aaid              NUMBER;
    ln_payroll_action_id      NUMBER;
    ln_w2c_asg_action         NUMBER;
    lv_year                   VARCHAR2(4);

    ld_end_date               DATE;
    ld_start_date             DATE;
    ln_business_group_id      NUMBER;
    ln_person_id              NUMBER;
    ln_set_person_id          NUMBER;
    ln_asg_set                NUMBER;
    lv_print                  varchar2(10);
    lv_sort1                  VARCHAR2(60);
    lv_sort2                  VARCHAR2(60);
    lv_sort3                  VARCHAR2(60);
    ld_session_date           DATE;

    lv_report_type            pay_payroll_actions.report_type%TYPE ;
    ln_asg_act_to_lock        pay_assignment_actions.assignment_action_id%TYPE;
    ln_second_last_arch_action pay_assignment_actions.assignment_action_id%TYPE;
    ln_prev_yepp_lock_action  pay_assignment_actions.assignment_action_id%TYPE;


    lv_serial_number          VARCHAR2(30);
    lv_employee_number        per_all_people_f.employee_number%type;
    lv_message                varchar2(50);
    lv_full_name              per_all_people_f.full_name%type;
    lv_record_name            varchar2(50);
    lv_prev_report_type       pay_payroll_actions.report_type%TYPE;
    ln_prev_lock_action       pay_assignment_actions.assignment_action_id%TYPE;
    ln_prev_w2c_action_id     pay_assignment_actions.assignment_action_id%TYPE;
    ln_serial_number          pay_assignment_actions.serial_number%TYPE;

    CURSOR c_selected_asg_set(cp_start_person in number
                             ,cp_end_person in number
                             ,cp_asg_set in number) is
      select distinct paf.person_id
        from hr_assignment_set_amendments asgset,
             per_all_assignments_f paf
       where assignment_set_id = cp_asg_set
         and asgset.include_or_exclude = 'I'
         and paf.assignment_id = asgset.assignment_id
         and paf.person_id between cp_start_person
                               and cp_end_person;

    -- Bug 3601799
    -- This Cursor is opened when report is run for All persons.
    -- This will only happen for Re-prints
    CURSOR c_select_all_person(cp_start_person in number,
			       cp_end_person in number,
			       cp_start_date in date,
                               cp_business_group_id in number,
			       cp_tax_unit_id in number) IS
      select distinct paf.person_id
        from pay_assignment_actions paa,
             pay_payroll_actions ppa,
             per_all_assignments_f paf
       where ppa.report_type = 'W-2C PAPER'
         and ppa.report_category = 'REPORT'
         and ppa.report_qualifier = 'DEFAULT'
         and ppa.effective_date = add_months(cp_start_date,12) -1
         and ppa.business_group_id = cp_business_group_id
         and ppa.legislative_parameters like '%' || cp_tax_unit_id || '%'
	 and paa.payroll_action_id = ppa.payroll_action_id
	 and paa.action_status = 'C'
	 and paa.tax_unit_id = cp_tax_unit_id
         and paf.assignment_id = paa.assignment_id
         and paf.effective_end_date   =
               (SELECT max(paf1.effective_end_date)
                  FROM per_all_assignments_f paf1
                 WHERE paf1.assignment_id = paf.assignment_id
                   AND paf1.effective_start_date <= ppa.effective_date)
         and paf.person_id between cp_start_person and cp_end_person;


    PROCEDURE action_creation (p_person_id in NUMBER)
    IS

      CURSOR get_prev_w2c_dtls (cp_person_id      in number
                               ,cp_tax_unit_id in number
                               ,cp_effective_date in date
                               ,cp_start_date in date) is
        select ppa.report_type, paa.assignment_id,
               paa.assignment_action_id
          from pay_payroll_actions ppa,
               pay_assignment_actions paa,
               per_all_assignments_f paf
         where paa.assignment_id = paf.assignment_id
           and paf.person_id = cp_person_id
           and paf.effective_start_date <= cp_effective_date
           and paf.effective_end_date >= cp_start_date
           and paa.tax_unit_id = cp_tax_unit_id
           and paa.action_status = 'C'
           and ppa.payroll_action_id = paa.payroll_action_id
           and ppa.effective_date = cp_effective_date
           and ppa.report_type in ('W2C_PRE_PROCESS','W-2C PAPER')
           and paf.effective_end_date   =
               (SELECT max(paf1.effective_end_date)
                  FROM per_all_assignments_f paf1
                 WHERE paf1.assignment_id = paf.assignment_id
                   AND paf1.effective_start_date <= ppa.effective_date)
        order by paa.assignment_action_id desc;

      CURSOR get_prev_w2c_reprint_dtls (cp_person_id         in number
                                       ,cp_tax_unit_id       in number
                                       ,cp_effective_date    in date
                                       ,cp_start_date        in date
                                       ,cp_business_group_id in number) is
        select ppa.report_type, paa.assignment_id,
               paa.assignment_action_id
          from pay_payroll_actions ppa,
               pay_assignment_actions paa,
               per_all_assignments_f paf
         where paa.assignment_id = paf.assignment_id
           and paf.person_id = cp_person_id
           and paf.effective_start_date <= cp_effective_date
           and paf.effective_end_date >= cp_start_date
           and paa.tax_unit_id = cp_tax_unit_id
           and paa.action_status = 'C'
           and ppa.payroll_action_id = paa.payroll_action_id
           and ppa.effective_date = cp_effective_date
           and ppa.report_type = 'W2C_PRE_PROCESS'
           and ppa.report_category = 'RT'
           and ppa.report_qualifier = 'FED'
           and ppa.business_group_id = cp_business_group_id
           and paf.effective_end_date   =
               (SELECT max(paf1.effective_end_date)
                  FROM per_all_assignments_f paf1
                 WHERE paf1.assignment_id = paf.assignment_id
                   AND paf1.effective_start_date <= ppa.effective_date)
           and exists (select 1
                         from pay_action_interlocks pai,
                              pay_assignment_actions paa_paper,
                              pay_payroll_Actions ppa_paper
                        where pai.locked_action_id = paa.assignment_action_id
                          and paa_paper.assignment_Action_id = pai.locking_action_id
                          and ppa_paper.payroll_Action_id = paa_paper.payroll_Action_id
                          and ppa_paper.report_type = 'W-2C PAPER'
                          and ppa_paper.report_category = 'REPORT'
                          and ppa_paper.report_qualifier = 'DEFAULT'
                          and ppa_paper.effective_date = cp_effective_date
                          and ppa_paper.business_group_id = cp_business_group_id)
       order by paa.assignment_action_id desc;

      CURSOR get_interlocked_action(cp_w2cpp_action in number)is
        select ppa.report_type,
               paa.assignment_action_id,
               substr(paa.serial_number, 1,15) prev_action_id
          from pay_payroll_actions ppa,
               pay_assignment_actions paa,
               pay_action_interlocks pai
         where pai.locking_action_id = cp_w2cpp_action
           and paa.assignment_action_id = pai.locked_action_id
           and ppa.payroll_action_id = paa.payroll_action_id;


      CURSOR get_warning_dtls_for_ee(cp_person_id in number) is
        select substr(full_name,1,48), employee_number
          from per_all_people_f
         where person_id = cp_person_id
        order by effective_end_date desc;

    BEGIN
      if lv_print = 'NEW' then
         open get_prev_w2c_dtls(p_person_id
                               ,ln_tax_unit_id
                               ,ld_end_date
                               ,ld_start_date);
         fetch get_prev_w2c_dtls into lv_report_type
                                     ,ln_primary_assignment_id
                                     ,ln_asg_act_to_lock;
         if get_prev_w2c_dtls%notfound then
            open get_warning_dtls_for_ee(p_person_id);
            fetch get_warning_dtls_for_ee into lv_full_name
                                              ,lv_employee_number;
            close get_warning_dtls_for_ee;

            lv_record_name := 'W2C Report';
            lv_message := 'No W2c archive actions exist for this employee';

            pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','P');
            pay_core_utils.push_token('record_name',lv_record_name);
            pay_core_utils.push_token('name_or_number',lv_full_name);
            pay_core_utils.push_token('description',lv_message);
         end if;

         if get_prev_w2c_dtls%found then
            if lv_report_type in ('W2C_PRE_PROCESS') then
               /* Create an assignment action for this person */
               select pay_assignment_actions_s.nextval
                 into ln_w2c_asg_action
                 from dual;
               hr_utility.trace('New w2c Action = ' || ln_w2c_asg_action);

               /* Insert into pay_assignment_actions. */
               hr_nonrun_asact.insact(ln_w2c_asg_action
                                     ,ln_primary_assignment_id
                                     ,p_payroll_action_id
                                     ,p_chunk
                                     ,ln_tax_unit_id);

               /**********************************************************
               ** Get the second last archive action for this employee
               ** The First W2C_PRE_PROCESS locks YREND
               ** but the subsequent W2C_PRE_PROCESS will lock
               ** the W-2C PAPER process
               ***********************************************************/
               open get_interlocked_action(ln_asg_act_to_lock);
               fetch get_interlocked_action into lv_prev_report_type
                                                ,ln_prev_yepp_lock_action
                                                ,ln_prev_w2c_action_id;
               if get_interlocked_action%notfound then
                  close get_interlocked_action;
                  hr_utility.raise_error;
               end if;
               close get_interlocked_action;

               if lv_prev_report_type = 'YREND' then
                  ln_second_last_arch_action := ln_prev_yepp_lock_action;
               elsif lv_prev_report_type = 'W-2C PAPER' then
                  ln_second_last_arch_action := ln_prev_w2c_action_id;
               end if;

               /***************************************************************
               ** Update the serial number column with the assignment action
               ** of the last two archive processes
               ***************************************************************/
               ln_serial_number := lpad(ln_asg_act_to_lock,15,0)||
                                   lpad(ln_second_last_arch_action,15,0);

               update pay_assignment_actions aa
                  set aa.serial_number = ln_serial_number
                where  aa.assignment_action_id = ln_w2c_asg_action;

               /***************************************************************
               ** Interlock last w2c archive action with current w2c rep action
               ***************************************************************/
               hr_utility.trace('Locking Action'||ln_w2c_asg_action);
               hr_utility.trace('Locked Action' || ln_asg_act_to_lock);
               hr_nonrun_asact.insint(ln_w2c_asg_action
                                     ,ln_asg_act_to_lock);

            elsif lv_report_type = 'W-2C PAPER' then

               open get_warning_dtls_for_ee(p_person_id);
               fetch get_warning_dtls_for_ee into lv_full_name
                                                 ,lv_employee_number;

               close get_warning_dtls_for_ee;

               lv_record_name := 'W2C Report';
               lv_message := 'No new w2c archive actions exist '||
                             'for this employee';

               pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','P');
               pay_core_utils.push_token('record_name',lv_record_name);
               pay_core_utils.push_token('name_or_number',lv_full_name);
               pay_core_utils.push_token('description',lv_message);

            end if; /* report type */

         end if; /* employee found*/
         close get_prev_w2c_dtls;

      elsif lv_print = 'ALL' then

         open get_prev_w2c_reprint_dtls(p_person_id
                                       ,ln_tax_unit_id
                                       ,ld_end_date
                                       ,ld_start_date
                                       ,ln_business_group_id);
         lv_report_type := null;
         ln_primary_assignment_id := 0;
         ln_asg_act_to_lock := 0;

         loop
            fetch get_prev_w2c_reprint_dtls into lv_report_type
                                                ,ln_primary_assignment_id
                                                ,ln_asg_act_to_lock;
            if get_prev_w2c_reprint_dtls%notfound then
               exit;
            end if;

            /* Create an assignment action for this person */
            select pay_assignment_actions_s.nextval
              into ln_w2c_asg_action
              from dual;
            hr_utility.trace('New w2c Action = ' || ln_w2c_asg_action);

            /* Insert into pay_assignment_actions. */
            hr_nonrun_asact.insact(ln_w2c_asg_action
                                  ,ln_primary_assignment_id
                                  ,p_payroll_action_id
                                  ,p_chunk
                                  ,ln_tax_unit_id);

            /**********************************************************
            ** Get the second last archive action for this employee
            ** The First W2C_PRE_PROCESS locks YREND
            ** but the subsequent W2C_PRE_PROCESS will lock
            ** the W-2C PAPER process
            ***********************************************************/
            open get_interlocked_action(ln_asg_act_to_lock);
            fetch get_interlocked_action into lv_prev_report_type
                                             ,ln_prev_yepp_lock_action
                                             ,ln_prev_w2c_action_id;
            if get_interlocked_action%notfound then
               close get_interlocked_action;
               hr_utility.raise_error;
            end if;
            close get_interlocked_action;

            if lv_prev_report_type = 'YREND' then
               ln_second_last_arch_action := ln_prev_yepp_lock_action;
            elsif lv_prev_report_type = 'W-2C PAPER' then
               ln_second_last_arch_action := ln_prev_w2c_action_id;
            end if;

            /***************************************************************
            ** Update the serial number column with the assignment action
            ** of the last two archive processes
            ***************************************************************/
            ln_serial_number := lpad(ln_asg_act_to_lock,15,0)||
                                lpad(ln_second_last_arch_action,15,0);

            update pay_assignment_actions aa
               set aa.serial_number = ln_serial_number
             where  aa.assignment_action_id = ln_w2c_asg_action;

         end loop;
         close get_prev_w2c_reprint_dtls;

      end if; /* NEW */

   END action_creation;

  BEGIN
    hr_utility.trace('Entered action_creation ');
    ln_assignment_id          := 0;
    ln_tax_unit_id            := 0;
    ln_asg_action_id          := 0;
    ln_primary_assignment_id  := 0;
    ln_yepp_aaid              := 0;
    ln_payroll_action_id      := 0;
    ln_w2c_asg_action         := 0;
    lv_year                   := 0;

    ln_person_id              := 0 ;
    ln_set_person_id          := 0 ;
    ln_asg_set                := 0 ;
    lv_message                := null;

    hr_utility.trace('p_payroll_action_id = '|| to_char(p_payroll_action_id));
    hr_utility.trace('p_start_person_id ='|| to_char(p_start_person_id));
    hr_utility.trace('p_end_person_id = '|| to_char(p_end_person_id));
    hr_utility.trace('p_chunk  = '       || to_char(p_chunk));

    get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                           ,p_start_date        => ld_start_date
                           ,p_end_date          => ld_end_date
                           ,p_business_group_id => ln_business_group_id
                           ,p_tax_unit_id       => ln_tax_unit_id
                           ,p_person_id         => ln_person_id
                           ,p_asg_set           => ln_asg_set
                           ,p_print             => lv_print
                           ,p_sort_option1      => lv_sort1
                           ,p_sort_option2      => lv_sort2
                           ,p_sort_option3      => lv_sort3
                           ,p_session_date      => ld_session_date);

    /* PERSON ID IS NOT NULL */
    if ln_person_id is not null then
       action_creation(p_start_person_id);

    /* ASSIGNMENT SET ID IS NOT NULL */
    elsif ln_asg_set is not null then
       hr_utility.trace('Entered Asg Set logic');
       hr_utility.trace('Asg Set ='||to_char(ln_asg_set));
       hr_utility.trace('p_start_person_id ='||to_char(p_start_person_id));
       hr_utility.trace('End Person ='||to_char(p_end_person_id));

       open c_selected_asg_set(p_start_person_id
                              ,p_end_person_id
                              ,ln_asg_set);
       hr_utility.trace('Opened cusor c_selected_asg_set');
       loop
          fetch c_selected_asg_set into ln_set_person_id;
          if c_selected_asg_set%notfound then
             hr_utility.trace('No Person found for reporting in this chunk');
             exit;
          end if;

          action_creation(ln_set_person_id);

       end loop;
       close c_selected_asg_set;

    -- Bug 3601799 -- Added this elsif if the report is run for All.
    /* PERSON ID and ASSIGNMENT SET ID are NULL */
    elsif ln_person_id is null and ln_asg_set is null then
       hr_utility.trace('Report run for All persons Logic.');
       open c_select_all_person(p_start_person_id
                               ,p_end_person_id
                               ,ld_start_date
                               ,ln_business_group_id
                               ,ln_tax_unit_id);
       hr_utility.trace('Opened cusor c_select_all_person');
       loop
          fetch c_select_all_person into ln_person_id;
          if c_select_all_person%notfound then
             hr_utility.trace('No Person found for reporting in this chunk.');
             exit;
          end if;

          action_creation(ln_person_id);
       end loop;
       close c_select_all_person;
    end if; /*  ln_person_id */

  END w2crpt_action_creation;


  /************************************************************
   Name      : sort_action
   Purpose   : This sorts the assignment actions based on the
               sort options given when submitting the W2C Report
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE sort_action(p_payroll_action_id in     varchar2
                       ,p_sql_string        in out nocopy varchar2
                       ,p_sql_length           out nocopy   number)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_person_id         NUMBER;
    ln_set_person_id     NUMBER;
    ln_asg_set           NUMBER;
    ln_tax_unit_id       NUMBER;
    lv_print             VARCHAR2(10);
    lv_sort1             VARCHAR2(60);
    lv_sort2             VARCHAR2(60);
    lv_sort3             VARCHAR2(60);
    ld_session_date      DATE;

  BEGIN

    get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                           ,p_start_date        => ld_start_date
                           ,p_end_date          => ld_end_date
                           ,p_business_group_id => ln_business_group_id
                           ,p_tax_unit_id       => ln_tax_unit_id
                           ,p_person_id         => ln_person_id
                           ,p_asg_set           => ln_asg_set
                           ,p_print             => lv_print
                           ,p_sort_option1      => lv_sort1
                           ,p_sort_option2      => lv_sort2
                           ,p_sort_option3      => lv_sort3
                           ,p_session_date      => ld_session_date
                           );

    if  ld_end_date > ld_session_date then
        ld_session_date := ld_end_date;
    end if;

    hr_utility.trace('Beginning of the sort_action cursor');
    p_sql_string :=
      'select mt.rowid
         from hr_organization_units hou, hr_locations_all hl,
              per_periods_of_service pps, per_all_assignments_f paf,
              pay_assignment_actions mt
        where mt.payroll_action_id = :p_payroll_action_id
          and paf.assignment_id = mt.assignment_id -- Bug 3679317 ( +0 removed)
          and paf.effective_start_date = (select max(paf2.effective_start_date)
                  from per_all_assignments_f paf2 where paf2.assignment_id = paf.assignment_id
                   and paf2.effective_start_date <= to_date(''' || to_char(ld_end_date,'dd-mon-yyyy') || ''',''dd-mon-yyyy''))
          and paf.effective_end_date >= to_date('''|| to_char(ld_start_date,'dd-mon-yyyy') ||''',''dd-mon-yyyy'')
          and paf.assignment_type = ''E'' and hou.organization_id = paf.organization_id
          and pps.period_of_service_id = paf.period_of_service_id
          and pps.person_id = paf.person_id and hl.location_id = paf.location_id
          and hou.business_group_id = '''|| ln_business_group_id ||'''
order by decode('''||lv_sort1||''', ''Employee_Name'',
 hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_LAST_NAME'')||'' ''
 ||hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_FIRST_NAME'')||'' ''
 ||substr(hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_MIDDLE_NAMES''),1,1),
 ''SSN'',nvl(hr_us_w2_rep.get_per_item( to_number(substr(mt.serial_number,1,15)), ''A_PER_NATIONAL_IDENTIFIER''),
 ''Applied For''),
''Zip_Code'',hr_us_w2_rep.get_w2_postal_code( paf.person_id,to_date('''|| to_char(ld_session_date,'dd-mon-yyyy') ||''',''dd-mon-yyyy'')),
 ''Organization'',hou.name, ''Location'',hl.location_code,
 ''Termination_Reason'',decode(leaving_reason,null,''ZZ'',hr_us_w2_rep.get_leav_reason(leaving_reason)),
  hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_LAST_NAME'')||'' ''
 ||hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_FIRST_NAME'')||'' ''
 ||substr(hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_MIDDLE_NAMES''),1,1)),
 decode('''||lv_sort2||''', ''Employee_Name'',
 hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_LAST_NAME'')||'' ''
 ||hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,5)), ''A_PER_FIRST_NAME'')||'' ''
 ||substr(hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_MIDDLE_NAMES''),1,1),
  ''SSN'',nvl(hr_us_w2_rep.get_per_item(
 to_number(substr(mt.serial_number,1,15)), ''A_PER_NATIONAL_IDENTIFIER''), ''Applied For''),
 ''Zip_Code'',hr_us_w2_rep.get_w2_postal_code( paf.person_id,to_date('''|| to_char(ld_session_date,'dd-mon-yyyy') ||''',''dd-mon-yyyy'')),
  ''Organization'',hou.name, ''Location'',hl.location_code,
  ''Termination_Reason'',decode(leaving_reason,null,''ZZ'',hr_us_w2_rep.get_leav_reason(leaving_reason)),
  hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_LAST_NAME'')||'' ''
  ||hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_FIRST_NAME'')||'' ''
  ||substr(hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_MIDDLE_NAMES''),1,1)),
 decode('''||lv_sort3||''', ''Employee_Name'', hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)),
 ''A_PER_LAST_NAME'')||'' ''
 ||hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,5)), ''A_PER_FIRST_NAME'')||'' ''
 ||substr(hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_MIDDLE_NAMES''),1,1),
 ''SSN'',nvl(hr_us_w2_rep.get_per_item( to_number(substr(mt.serial_number,1,5)), ''A_PER_NATIONAL_IDENTIFIER''),
 ''Applied For''), ''Zip_Code'',hr_us_w2_rep.get_w2_postal_code( paf.person_id,to_date('''||to_char(ld_session_date, 'dd-mon-yyyy')||''',''dd-mon-yyyy'')),
 ''Organization'',hou.name, ''Location'',hl.location_code, ''Termination_Reason'',decode(leaving_reason,null,''ZZ'',
 hr_us_w2_rep.get_leav_reason(leaving_reason)),
 hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_LAST_NAME'')||'' ''
 ||hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,15)), ''A_PER_FIRST_NAME'')||'' ''
 ||substr(hr_us_w2_rep.get_per_item(to_number(substr(mt.serial_number,1,5)), ''A_PER_MIDDLE_NAMES''),1,1))';


      p_sql_length := length(p_sql_string); -- return the length of the string.
      hr_utility.trace('End of the sort_Action cursor');
  END sort_action;

BEGIN
--   hr_utility.trace_on(null,'W2CRPT');
   gv_package := 'pay_us_w2c_rpt';

END pay_us_w2c_rpt;

/
