--------------------------------------------------------
--  DDL for Package Body PAY_CA_EOY_T4_AMEND_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EOY_T4_AMEND_REG" AS
/* $Header: pycat4cr.pkb 120.4 2006/10/17 00:08:37 meshah noship $ */
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

    Name        : pay_ca_eoy_t4_amend_reg

    Description : This Package is used by T4 Amendment Register
                  and T4 Amendment Paper Reports.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    07-SEP-2003 SSattini   115.0            Created.
    08-SEP-2003 SSattini   115.1            Removed for update clause
                                            from sort_action procedure.
    17-SEP-2003 SSattini   115.2            Corrected the variables used
                                            to substitute token values in
                                            messages.
    20-OCT-2003 SSattini   115.3            Added p_report_type parameter
                                            to get_payroll_action_info
                                            procedure, to check whether
                                            report is Register or Paper.
    01-SEP-2004 SSouresr   115.4            Made changes to the package to
                                            support multi assignments
                                            and also removed unnecessary
                                            joins to per_assignments_f
    27-SEP-2004 SSouresr   115.5            Corrected action_creation for
                                            scenario with assignment set but
                                            no GRE
    22-NOV-2004 SSouresr   115.6            Replaced tables with views and also
                                            added an exists clause to the main
                                            cursors in action_creation
    07-MAR-2005  SSouresr  115.7            Removed extra payroll_action_id from
                                            the range cursor
    29-MAY-2005 SSouresr   115.8            Updating the gre just before calling
                                            action_creation when no gre parameter
                                            has been given. This removes duplicates
    15-JUN-2005 SSouresr   115.9            Replaced views with tables in sort_action
                                            as this was causing Assertion failure
    21-JUN-2005 SSouresr   115.10           Security Profile changes to c_all_gres
    16-OCT-2006 meshah     115.11  5528944  Added order by to the range cursor
                                            queries.
  *****************************************************************************/

   gv_package        VARCHAR2(100) := 'pay_ca_eoy_t4_amend_reg';
   gv_procedure_name VARCHAR2(100);

  /*****************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for  T4 Amendment PAPER.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_start_date        - Start date of T4 Amendment PAPER
               p_end_date          - End date of T4 Amendment PAPER
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
                                   ,p_prov_cd              out nocopy varchar2
                                   ,p_report_type          out nocopy varchar2
                                   )
  IS
    cursor c_payroll_Action_info (cp_payroll_action_id in number) is
      select to_number(pay_ca_eoy_t4_amend_reg.get_parameter(
                         'GRE_ID',ppa.legislative_parameters)),
             to_number(pay_ca_eoy_t4_amend_reg.get_parameter(
                          'PER_ID',ppa.legislative_parameters)),
             to_number(pay_ca_eoy_t4_amend_reg.get_parameter(
                          'ASG_SET_ID',ppa.legislative_parameters)),
             pay_ca_eoy_t4_amend_reg.get_parameter(
                          'MODE',ppa.legislative_parameters),
             effective_date,
             start_date,
             business_group_id,
             pay_ca_eoy_t4_amend_reg.get_parameter(
                          'PROV_CD',ppa.legislative_parameters),
             report_type
        from pay_payroll_actions ppa
       where ppa.payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_tax_unit_id       NUMBER := 0;
    ln_person_id         NUMBER := 0;
    ln_asg_set           NUMBER := 0;
    lv_print             varchar2(10);
    lv_prov_cd           varchar2(5);
    lv_report_type       varchar2(50);

   BEGIN
       hr_utility.trace('Entered get_payroll_action_info');
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ln_tax_unit_id,
                                        ln_person_id,
                                        ln_asg_set,
                                        lv_print,
                                        ld_end_date,
                                        ld_start_date,
                                        ln_business_group_id,
                                        lv_prov_cd,
                                        lv_report_type;
       close c_payroll_action_info;

       hr_utility.trace('ld_end_date = '   || to_char(ld_end_date));
       hr_utility.trace('ld_start_date = ' || to_char(ld_start_date));
       hr_utility.trace('ln_tax_unit_id = '|| to_char(ln_tax_unit_id));
       hr_utility.trace('ln_person_id = '  || to_char(ln_person_id));
       hr_utility.trace('ln_asg_set = '    || to_char(ln_asg_set));
       hr_utility.trace('lv_prov_cd = '    || lv_prov_cd);

       p_end_date          := ld_end_date;
       p_start_date        := ld_start_date;
       p_business_group_id := ln_business_group_id;
       p_tax_unit_id       := ln_tax_unit_id;
       p_person_id         := ln_person_id;
       p_asg_set           := ln_asg_set;
       p_print             := lv_print;
       p_prov_cd           := lv_prov_cd;
       p_report_type       := lv_report_type;

       hr_utility.trace('Leaving get_payroll_action_info');

  EXCEPTION
    when others then
       hr_utility.trace('Error in ' || gv_procedure_name ||
                         to_char(sqlcode) || '-' || sqlerrm);
       raise hr_utility.hr_error;

  END get_payroll_action_info;


  /******************************************************************
   Name      : range_cursor
   Purpose   : This returns the select statement that is
               used to created the range rows for the
               T4 Amendment PAPER.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE range_cursor(
                    p_payroll_action_id in number
                   ,p_sqlstr           out nocopy  varchar2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_tax_unit_id       NUMBER;
    ln_person_id         NUMBER := 0;
    ln_asg_set           NUMBER := 0;
    lv_sql_string        VARCHAR2(32000);
    ln_eoy_pactid        number;
    lv_print             varchar2(10):=null;
    lv_error_mesg        varchar2(100);
    ln_agent_tax_unit_id pay_assignment_actions.tax_unit_id%type;
    ln_year              number;
    lv_prov_cd           varchar2(5);
    lv_report_type       varchar2(50);

  BEGIN
     hr_utility.trace('Entered range_cursor');
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
                            ,p_prov_cd           => lv_prov_cd
                            ,p_report_type       => lv_report_type);

      ln_year := to_number(to_char(ld_end_date,'YYYY'));

      hr_utility.trace('Checking for Preprocess Agent GRE setup');

     if ln_person_id is not null then

        lv_sql_string :=
         'select distinct asg.person_id person_id
            from per_assignments_f asg
           where person_id = ' || ln_person_id ||
         ' and :payroll_action_id > 0';

        hr_utility.trace('Range for person_id not null');

     elsif ln_asg_set is not null then

        lv_sql_string :=
           'select distinct paf.person_id
             from hr_assignment_set_amendments asgset,
                  per_assignments_f paf
            where assignment_set_id = ' || ln_asg_set || '
              and asgset.assignment_id = paf.assignment_id
              and asgset.include_or_exclude = ''I''
              and :payroll_action_id > 0
            order by paf.person_id';

        hr_utility.trace('Range for asg_set not null');

     elsif ln_tax_unit_id is not NULL then

       lv_sql_string :=
        'select distinct paf.person_id
         from pay_payroll_actions ppa_arch,
              pay_assignment_actions paa_arch,
              per_assignments_f paf,
              pay_payroll_actions ppa
        where paa_arch.assignment_id = paf.assignment_id
          and ppa.payroll_action_id = :payroll_action_id
          and ppa_arch.business_group_id = ppa.business_group_id
          and ppa_arch.effective_date = ppa.effective_date
          and ppa_arch.report_type = ''CAEOY_T4_AMEND_PP''
          and paa_arch.tax_unit_id = '|| ln_tax_unit_id ||'
          and paa_arch.action_status = ''C''
          and ppa_arch.payroll_action_id = paa_arch.payroll_action_id
        order by paf.person_id ';

     else

       lv_sql_string :=
        'select distinct paf.person_id
         from pay_payroll_actions ppa_arch,
              pay_assignment_actions paa_arch,
              per_assignments_f paf,
              pay_payroll_actions ppa
        where paa_arch.assignment_id = paf.assignment_id
          and ppa.payroll_action_id = :payroll_action_id
          and ppa_arch.business_group_id = ppa.business_group_id
          and ppa_arch.effective_date = ppa.effective_date
          and ppa_arch.report_type = ''CAEOY_T4_AMEND_PP''
          and paa_arch.action_status = ''C''
          and ppa_arch.payroll_action_id = paa_arch.payroll_action_id
        order by paf.person_id ';

    end if;

     p_sqlstr := lv_sql_string;
     hr_utility.trace('p_sqlstr = ' ||p_sqlstr);

     hr_utility.trace('Leaving range_cursor');

  END range_cursor;


  /************************************************************
   Name      : action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the T4 Amendment Report process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/

  PROCEDURE action_creation(
                 p_payroll_action_id   in number
                ,p_start_person_id     in number
                ,p_end_person_id       in number
                ,p_chunk               in number)

  IS

    ln_assignment_id          NUMBER := 0;
    ln_tax_unit_id            NUMBER := 0;
    ld_effective_date         DATE;
    ln_asg_action_id          NUMBER := 0;
    ln_primary_assignment_id  NUMBER := 0;
    ln_yepp_aaid              NUMBER := 0;
    ln_payroll_action_id      NUMBER := 0;
    ln_t4amend_reg_asg_action NUMBER := 0;
    lv_year                   VARCHAR2(4);

    ld_end_date               DATE;
    ld_start_date             DATE;
    ln_business_group_id      NUMBER;
    ln_person_id              NUMBER := 0 ;
    ln_set_person_id          NUMBER := 0 ;
    ln_asg_set                NUMBER := 0 ;
    lv_print                  varchar2(10);
    lv_prov_cd                varchar2(5);

    lv_report_type            pay_payroll_actions.report_type%TYPE ;
    ln_asg_act_to_lock        pay_assignment_actions.assignment_action_id%TYPE;
    ln_second_last_arch_action pay_assignment_actions.assignment_action_id%TYPE;
    ln_prev_yepp_lock_action  pay_assignment_actions.assignment_action_id%TYPE;


    lv_serial_number          VARCHAR2(30);
    lv_employee_number        per_people_f.employee_number%type;
    lv_message                varchar2(100):= null;
    lv_full_name              per_people_f.full_name%type;
    lv_record_name            varchar2(100);
    lv_prev_report_type       pay_payroll_actions.report_type%TYPE;
    ln_prev_lock_action       pay_assignment_actions.assignment_action_id%TYPE;
    ln_prev_w2c_action_id     pay_assignment_actions.assignment_action_id%TYPE;
    ln_serial_number          pay_assignment_actions.serial_number%TYPE;
    ln_gre_id                 NUMBER;
    ln_gre_parameter          NUMBER;
    lv_ppr_report_type        varchar2(50);

   CURSOR c_selected_asg_set(cp_start_person in number
                            ,cp_end_person in number
                            ,cp_asg_set in number
                            ,cp_effective_date in date) is
   select distinct paf.person_id
   from hr_assignment_set_amendments asgset,
        per_assignments_f  paf,
        pay_payroll_actions    ppa,
        pay_assignment_actions paa
   where asgset.assignment_set_id = cp_asg_set
   and asgset.include_or_exclude = 'I'
   and paf.assignment_id = asgset.assignment_id
   and paf.person_id between cp_start_person
                         and cp_end_person
   and ppa.business_group_id = ln_business_group_id
   and ppa.report_type = 'CAEOY_T4_AMEND_PP'
   and ppa.payroll_action_id = paa.payroll_action_id
   and paa.tax_unit_id = nvl(ln_tax_unit_id, paa.tax_unit_id)
   and paa.action_status = 'C'
   and ppa.effective_date = cp_effective_date
   and paf.person_id = to_number(paa.serial_number);

   /* Cursor c_all_gres to select T4 Amendment GRE based on Business Group
      and effective date  */
   CURSOR c_all_gres(cp_bg_id number,
                     cp_eff_date date) IS
   select hou.organization_id
   from hr_organization_information hoi,
        hr_all_organization_units   hou
   where hou.business_group_id  = cp_bg_id
   AND hou.organization_id = hoi.organization_id
   AND hou.date_from <= cp_eff_date
   AND nvl(hou.date_to,fnd_date.canonical_to_date('4712/12/31 00:00:00'))
       >= cp_eff_date
   AND hoi.org_information_context = 'Canada Employer Identification'
   AND hoi.org_information5 = 'T4/RL1'
   AND exists ( SELECT 1
                FROM pay_payroll_actions ppa ,
                     pay_assignment_actions paa
                WHERE ppa.report_type = 'CAEOY_T4_AMEND_PP'
                AND ppa.report_qualifier = 'CAEOY_T4_AMEND_PPQ'
                AND ppa.business_group_id  = cp_bg_id
                AND ppa.effective_date = cp_eff_date
                AND paa.payroll_action_id = ppa.payroll_action_id
                AND paa.tax_unit_id = hou.organization_id);

   cursor c_all_asg(cp_bg_id number,
                 cp_gre number,
                 cp_eff_date date,
                 cp_start_person number,
                 cp_end_person number) is
   select distinct paa_arch.serial_number
   from  pay_payroll_actions ppa_arch,
         pay_assignment_actions paa_arch
   where ppa_arch.business_group_id =  cp_bg_id
   and ppa_arch.report_type = 'CAEOY_T4_AMEND_PP'
   AND ppa_arch.report_qualifier = 'CAEOY_T4_AMEND_PPQ'
   and ppa_arch.effective_date = cp_eff_date
   and ppa_arch.action_status = 'C'
   and paa_arch.payroll_action_id = ppa_arch.payroll_action_id
   and paa_arch.action_status = 'C'
   and paa_arch.tax_unit_id = nvl(cp_gre,paa_arch.tax_unit_id)
   and to_number(paa_arch.serial_number) between
                 cp_start_person and cp_end_person;



   PROCEDURE action_creation (p_person_id in NUMBER)
   IS

     CURSOR get_latest_t4amend_dtls (cp_person_id      in number
                                    ,cp_tax_unit_id in number
                                    ,cp_effective_date in date) is
       select ppa.report_type,
              paa.assignment_id,
              paa.assignment_action_id,
              paa.tax_unit_id
       from pay_payroll_actions ppa,
            pay_assignment_actions paa
       where paa.serial_number = to_char(cp_person_id)
       and paa.tax_unit_id = nvl(cp_tax_unit_id,paa.tax_unit_id)
       and ppa.business_group_id = ln_business_group_id
       and paa.action_status = 'C'
       and ppa.payroll_action_id = paa.payroll_action_id
       and ppa.effective_date = cp_effective_date
       and ppa.report_type = 'CAEOY_T4_AMEND_PP'
       and not exists (select 1
                       from pay_action_interlocks
                       where locked_action_id = paa.assignment_action_id)
       and exists (select 1
                   from per_assignments_f paf
                   where paf.assignment_id = paa.assignment_id
                   and   paf.effective_start_date <= cp_effective_date
                   and   paf.effective_end_date   >= trunc(cp_effective_date,'Y'))
       order by paa.assignment_action_id desc;

     CURSOR get_all_t4amend_dtls (cp_person_id      in number
                                 ,cp_tax_unit_id in number
                                 ,cp_effective_date in date) is
       select ppa.report_type,
              paa.assignment_id,
              paa.assignment_action_id,
              paa.tax_unit_id
       from pay_payroll_actions ppa,
            pay_assignment_actions paa
       where paa.serial_number = to_char(cp_person_id)
       and paa.tax_unit_id = nvl(cp_tax_unit_id,paa.tax_unit_id)
       and ppa.business_group_id = ln_business_group_id
       and paa.action_status = 'C'
       and ppa.payroll_action_id = paa.payroll_action_id
       and ppa.effective_date = cp_effective_date
       and ppa.report_type = 'CAEOY_T4_AMEND_PP'
       and exists (select 1
                   from per_assignments_f paf
                   where paf.assignment_id = paa.assignment_id
                   and   paf.effective_start_date <= cp_effective_date
                   and   paf.effective_end_date   >= trunc(cp_effective_date,'Y'))
       order by paa.assignment_action_id desc;


      CURSOR get_yepp_pact_id(cp_bg_id number,
                              cp_gre number,
                              cp_year date) IS
      select payroll_action_id
      from pay_payroll_actions
      where business_group_id = cp_bg_id
      and report_type = 'T4'
      and report_qualifier = 'CAEOY'
      and action_type = 'X'
      and action_status = 'C'
      and effective_date = cp_year
      and pay_ca_eoy_t4_amend_reg.get_parameter('TRANSFER_GRE',
                                                 legislative_parameters)
          = to_char(cp_gre);


     CURSOR get_warning_dtls_for_ee(cp_person_id in number) is
       select substr(full_name,1,48), employee_number
         from per_people_f
        where person_id = cp_person_id
        order by effective_end_date desc;

     CURSOR c_get_fed_amend_flag(cp_asg_act_id         number
                              ,cp_uid_t4amend_flag number
                              ,cp_province varchar2) IS
     select fai2.value,faic.context
     from ff_archive_items fai2,
          ff_archive_item_contexts faic,
          ff_contexts fc
     where fai2.context1 = cp_asg_act_id
     AND fai2.user_entity_id = cp_uid_t4amend_flag
     AND fai2.archive_item_id = faic.archive_item_id
     AND faic.context = nvl(rtrim(cp_province), faic.context)
     AND faic.context_id = fc.context_id
     AND fc.context_name = 'JURISDICTION_CODE';


     CURSOR c_get_ue_id(cp_user_name varchar2) IS
     select user_entity_id
     from ff_database_items
     where user_name = cp_user_name;

     lv_gross_earn_value varchar2(30);
     lv_jurisdiction     varchar2(10);
     lv_prov_of_emp      varchar2(10);
     lv_fed_amend_flag   varchar2(5);
     ln_gross_earn_ue_id number;
     ln_yepp_pact_id     number;
     ln_gre_id_null      number;
     ln_iteration        number :=0;

   BEGIN

     open c_get_ue_id('CAEOY_T4_AMENDMENT_FLAG');
     fetch c_get_ue_id into ln_gross_earn_ue_id;
     close c_get_ue_id;

--  Check mode here
     if lv_print = 'RECENT' then
         open get_latest_t4amend_dtls(p_person_id
                               ,ln_tax_unit_id
                               ,ld_end_date);

         loop

         fetch get_latest_t4amend_dtls into lv_report_type
                                     ,ln_primary_assignment_id
                                     ,ln_asg_act_to_lock
                                     ,ln_gre_id_null;
         if get_latest_t4amend_dtls%notfound then

             if ln_iteration = 0 then

               open get_warning_dtls_for_ee(p_person_id);
               fetch get_warning_dtls_for_ee into lv_full_name
                                                 ,lv_employee_number;
               close get_warning_dtls_for_ee;

               hr_utility.trace('get_latest_t4amend_dtls not found');
               hr_utility.trace('p_person_id :'||to_char(p_person_id));

               if lv_ppr_report_type = 'PYT4PRAMEND' then
                  lv_record_name := 'T4 Amend Paper Report';
               else
                  lv_record_name := 'T4 Amend Register Report';
               end if;
               lv_message := 'T4 Amend Preprocess was not run for this employee';

               pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','A');
               pay_core_utils.push_token('record_name',lv_record_name);
               pay_core_utils.push_token('name_or_number',lv_full_name);
               pay_core_utils.push_token('description',lv_message);
             end if;

             exit;
         end if;

         ln_iteration := ln_iteration + 1;

         if get_latest_t4amend_dtls%found then

              begin

                open c_get_fed_amend_flag(ln_asg_act_to_lock,
                                          ln_gross_earn_ue_id,
                                          lv_prov_cd);

                loop -- check amend flag for each province

                lv_fed_amend_flag := 'N';
                fetch c_get_fed_amend_flag into lv_fed_amend_flag,
                                                lv_prov_of_emp;
                   hr_utility.trace('lv_fed_amend_flag : '||lv_fed_amend_flag);
                   hr_utility.trace('lv_prov_of_emp : '||lv_prov_of_emp);
                   exit when c_get_fed_amend_flag%NOTFOUND;

                 if c_get_fed_amend_flag%FOUND then

                   if lv_fed_amend_flag = 'Y' then

                     if ln_gre_parameter is NULL then
                        ln_tax_unit_id := ln_gre_id_null;
                     end if;

                      open get_yepp_pact_id(ln_business_group_id,
                                            ln_tax_unit_id,
                                            ld_end_date);
                      fetch get_yepp_pact_id into ln_yepp_pact_id;
                      close get_yepp_pact_id;

                  /* Create an assignment action for this person */
                   hr_utility.trace('get_latest_t4amend_dtls found ');
                   hr_utility.trace('Report Type: '||lv_report_type);

                   select pay_assignment_actions_s.nextval
                    into ln_t4amend_reg_asg_action
                   from dual;

                    hr_utility.trace('New T4 Amend Action = ' ||
                                      to_char(ln_t4amend_reg_asg_action));

                    /* Insert into pay_assignment_actions. */
                    hr_nonrun_asact.insact(ln_t4amend_reg_asg_action
                                     ,ln_primary_assignment_id
                                     ,p_payroll_action_id
                                     ,p_chunk
                                     ,ln_tax_unit_id);

                    if ln_gre_parameter is NULL then
                       ln_tax_unit_id := '';
                    end if;

                   /***********************************************************
                   ** Update the serial number column with Province_code,
                   ** Archiver assignment_action and Archiver Payroll_action_id
                   ** so that we need not refer back in the reports. This
                   ** logic works for both T4 Amendment Register and T4 Register
                   ** reports.
                   ***********************************************************/
                   ln_serial_number := lv_prov_of_emp||
                                       lpad(to_char(ln_asg_act_to_lock),14,0)||
                                       lpad(to_char(ln_yepp_pact_id),14,0);

                   update pay_assignment_actions aa
                     set aa.serial_number = ln_serial_number
                   where  aa.assignment_action_id = ln_t4amend_reg_asg_action;
                   hr_utility.trace('lv_prov_of_emp: '||substr(ln_serial_number,1,2));
                   hr_utility.trace('Archiver Asg Act :'||substr(ln_serial_number,3,14));
                   hr_utility.trace('Archiver PactID :'||substr(ln_serial_number,17,14));

                    hr_utility.trace('Locking Action'||ln_t4amend_reg_asg_action);
                    hr_utility.trace('ln_serial_number :' || ln_serial_number);

               end if; -- lv_fed_amend_flag = 'Y'

              end if; -- c_get_fed_amend_flag%FOUND

              end loop; -- end of check amend flag for each province
              close c_get_fed_amend_flag;

             end;

         end if; /* get_latest_t4amend_dtls found*/

         end loop; /* get_latest_t4amend_dtls loop */
         close get_latest_t4amend_dtls;

-- check Mode here
      elsif lv_print = 'HISTORICAL' then

         open get_all_t4amend_dtls(p_person_id
                                  ,ln_tax_unit_id
                                  ,ld_end_date);
         lv_report_type := null;
         ln_primary_assignment_id := 0;
         ln_asg_act_to_lock := 0;
         ln_gre_id_null := 0;

         hr_utility.trace('lv_print :'||lv_print);

         loop

         fetch get_all_t4amend_dtls into lv_report_type
                                             ,ln_primary_assignment_id
                                             ,ln_asg_act_to_lock
                                             ,ln_gre_id_null;
         if get_all_t4amend_dtls%notfound then
            hr_utility.trace('get_all_t4amend_dtls not found ');
            exit;
         end if;

              open c_get_fed_amend_flag(ln_asg_act_to_lock,
                                          ln_gross_earn_ue_id,
                                          lv_prov_cd);
              loop -- check fed_amend_flag for each province

                lv_fed_amend_flag := 'N';
              fetch c_get_fed_amend_flag into lv_fed_amend_flag,
                                                lv_prov_of_emp;
                   hr_utility.trace('lv_fed_amend_flag : '||lv_fed_amend_flag);
                   hr_utility.trace('lv_prov_of_emp : '||lv_prov_of_emp);
                   exit when c_get_fed_amend_flag%NOTFOUND;

               if c_get_fed_amend_flag%FOUND then

                 if lv_fed_amend_flag = 'Y' then

                     if ln_gre_parameter is NULL then
                        ln_tax_unit_id := ln_gre_id_null;
                     end if;

                      open get_yepp_pact_id(ln_business_group_id,
                                            ln_tax_unit_id,
                                            ld_end_date);
                      fetch get_yepp_pact_id into ln_yepp_pact_id;
                      close get_yepp_pact_id;


                   hr_utility.trace('get_all_t4amend_dtls found ');
                   hr_utility.trace('Report Type: '||lv_report_type);

                  /* Create an assignment action for this person */

                   select pay_assignment_actions_s.nextval
                    into ln_t4amend_reg_asg_action
                   from dual;
                   hr_utility.trace('New T4 Amend Action = ' || ln_t4amend_reg_asg_action);

                   /* Insert into pay_assignment_actions. */
                   hr_nonrun_asact.insact(ln_t4amend_reg_asg_action
                                       ,ln_primary_assignment_id
                                       ,p_payroll_action_id
                                       ,p_chunk
                                       ,ln_tax_unit_id);

                    if ln_gre_parameter is NULL then
                       ln_tax_unit_id := '';
                    end if;

                   /***********************************************************
                   ** Update the serial number column with Province_code,
                   ** Archiver assignment_action and Archiver Payroll_action_id
                   ** so that we need not refer back in the reports. This
                   ** logic works for both T4 Amendment Register and T4 Register
                   ** reports.
                   ***********************************************************/
                   ln_serial_number := lv_prov_of_emp||
                                       lpad(to_char(ln_asg_act_to_lock),14,0)||
                                       lpad(to_char(ln_yepp_pact_id),14,0);
                      hr_utility.trace('lv_prov_of_emp: '||substr(ln_serial_number,1,2));
                      hr_utility.trace('Archiver Asg Act :'||substr(ln_serial_number,3,14));
                      hr_utility.trace('Archiver PactID :'||substr(ln_serial_number,17,14));

                   update pay_assignment_actions aa
                   set aa.serial_number = ln_serial_number
                   where  aa.assignment_action_id = ln_t4amend_reg_asg_action;

                 end if; -- lv_amend_flag = 'Y' condition

               end if; -- c_get_fed_amend_flag%found condition
               end loop; -- check fed_amend_flag for each province
               close c_get_fed_amend_flag;

          end loop; -- loop for get_all_t4amend_dtls
          close get_all_t4amend_dtls;

      end if; /* lv_print check i.e, mode */

   END action_creation;

  BEGIN
     hr_utility.trace('Entered action_creation ');
     hr_utility.trace('p_payroll_action_id = '|| to_char(p_payroll_action_id));
     hr_utility.trace('p_start_person_id ='|| to_char(p_start_person_id));
     hr_utility.trace('p_end_person_id = '|| to_char(p_end_person_id));
     hr_utility.trace('p_chunk  = '       || to_char(p_chunk));

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_tax_unit_id       => ln_gre_parameter
                            ,p_person_id         => ln_person_id
                            ,p_asg_set           => ln_asg_set
                            ,p_print             => lv_print
                            ,p_prov_cd           => lv_prov_cd
                            ,p_report_type       => lv_ppr_report_type);

     hr_utility.trace('lv_ppr_report_type: '||lv_ppr_report_type);

     ln_tax_unit_id := ln_gre_parameter;

     /* PERSON ID IS NOT NULL */
     if ln_person_id is not null then
        action_creation(p_start_person_id);

     elsif ln_asg_set is not null then

        hr_utility.trace('Entered Asg Set logic');
        hr_utility.trace('Asg Set ='||to_char(ln_asg_set));
        hr_utility.trace('p_start_person_id ='||to_char(p_start_person_id));
        hr_utility.trace('End Person ='||to_char(p_end_person_id));

        open c_selected_asg_set  (p_start_person_id
                                 ,p_end_person_id
                                 ,ln_asg_set
                                 ,ld_end_date);
        hr_utility.trace('Opened cusor c_selected_asg_set');
        loop
           fetch c_selected_asg_set into ln_set_person_id;
           if c_selected_asg_set%notfound then
              hr_utility.trace('c_selected_asg_set not found ');
              hr_utility.trace('No Person found for reporting in this chunk');
              exit;
           end if;

           action_creation(ln_set_person_id);

        end loop;
        close c_selected_asg_set;

     elsif ln_tax_unit_id is not null then

        hr_utility.trace('Entered GRE not null logic');
        hr_utility.trace('GRE  ='||to_char(ln_tax_unit_id));
        hr_utility.trace('p_start_person_id ='||to_char(p_start_person_id));
        hr_utility.trace('End Person ='||to_char(p_end_person_id));

        open c_all_asg  (ln_business_group_id,
                         ln_tax_unit_id,
                         ld_end_date,
                         p_start_person_id,
                         p_end_person_id);
        hr_utility.trace('Opened cusor c_all_asg');

        loop
           fetch c_all_asg into ln_set_person_id;
           if c_all_asg%notfound then
              hr_utility.trace('c_all_asg not found ');
              hr_utility.trace('No Person found for reporting in this chunk');
              exit;
           end if;

           action_creation(ln_set_person_id);

        end loop;
        close c_all_asg;

     else

        hr_utility.trace('Entered All GRE logic');

        open c_all_gres(ln_business_group_id,
                        ld_end_date);

        loop -- c_all_gres

          fetch c_all_gres into ln_gre_id;
          if c_all_gres%NOTFOUND then
             hr_utility.trace('c_all_gres NOT FOUND');
             exit;
          end if;

             hr_utility.trace('GRE  ='||to_char(ln_gre_id));
             hr_utility.trace('p_start_person_id ='||to_char(p_start_person_id));
             hr_utility.trace('End Person ='||to_char(p_end_person_id));

           open c_all_asg  (ln_business_group_id,
                            ln_gre_id,
                            ld_end_date,
                            p_start_person_id,
                            p_end_person_id);
            hr_utility.trace('Opened cusor c_all_asg');

            loop -- c_all_asg
              fetch c_all_asg into ln_set_person_id;
              if c_all_asg%notfound then
                 hr_utility.trace('c_all_asg not found ');
                 hr_utility.trace('No Person found for reporting in this chunk');
                 exit;
              end if;

              ln_tax_unit_id := ln_gre_id;
              action_creation(ln_set_person_id);

            end loop; -- c_all_asg
            close c_all_asg;

        end loop; -- c_all_gres
        close c_all_gres;

     end if; /*  ln_person_id */

  END action_creation;


---------------------------------- sort_action ------------------------------

PROCEDURE sort_action
(
   payactid   in     varchar2,
   sqlstr     in out nocopy varchar2,
   len        out nocopy   number
) is

  l_dt               date;
  l_year             number ;
  l_gre_id           pay_assignment_actions.tax_unit_id%type;
  l_per_id           per_assignments_f.person_id%type;
  l_sort1            varchar2(60);
  l_sort2            varchar2(60);
  l_sort3            varchar2(60);
  l_year_start       date;
  l_year_end         date;
  l_print            varchar2(20);
  l_asg_set_id       hr_assignment_set_amendments.assignment_set_id%TYPE;
  l_bg_id pay_payroll_actions.business_group_id%type ;

begin

   begin
   select pay_ca_eoy_t4_amend_reg.get_parameter('GRE_ID',ppa.legislative_parameters),
          pay_ca_eoy_t4_amend_reg.get_parameter('PER_ID',ppa.legislative_parameters),
          pay_ca_eoy_t4_amend_reg.get_parameter('ASG_SET_ID',ppa.legislative_parameters),
          pay_ca_eoy_t4_amend_reg.get_parameter('P_S1',ppa.legislative_parameters),
          pay_ca_eoy_t4_amend_reg.get_parameter('P_S2',ppa.legislative_parameters),
          pay_ca_eoy_t4_amend_reg.get_parameter('P_S3',ppa.legislative_parameters),
          pay_ca_eoy_t4_amend_reg.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),
          pay_ca_eoy_t4_amend_reg.get_parameter('MODE',ppa.legislative_parameters),
          ppa.effective_date,
          ppa.start_date,
          ppa.business_group_id
   into   l_gre_id,
          l_per_id,
          l_asg_set_id,
          l_sort1,
          l_sort2,
          l_sort3,
          l_dt, --session_date
          l_print,
          l_year_end,
          l_year_start,
          l_bg_id
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = payactid;

    exception when no_data_found then
            hr_utility.trace('Error in Sort Procedure - getting legislative param');
            raise;

    end;

    if  l_year_end > l_dt then
        l_dt := l_year_end;
    end if;

    hr_utility.trace('Beginning of the sort_action cursor');

sqlstr :=  'select paa1.rowid
                   from hr_all_organization_units  hou,
                        hr_all_organization_units  hou1,
                        hr_locations_all           loc,
                        per_all_people_f           ppf,
                        per_all_assignments_f      paf,
                        pay_assignment_actions     paa1,
                        pay_payroll_actions        ppa1
                   where ppa1.payroll_action_id = :p_payroll_action_id
                   and   paa1.payroll_action_id = ppa1.payroll_action_id
                   and   paa1.assignment_id = paf.assignment_id
                   and   paf.effective_start_date  =
                                  (select max(paf2.effective_start_date)
                                   from per_all_assignments_f paf2
                                   where paf2.assignment_id= paf.assignment_id
                                     and paf2.effective_start_date
                                         <= ppa1.effective_date)
                   and   paf.effective_end_date    >= ppa1.start_date
                   and   paf.assignment_type = ''E''
                   and   hou1.organization_id = paa1.tax_unit_id
                   and   hou.organization_id = paf.organization_id
                   and   loc.location_id  = paf.location_id
                   and   ppf.person_id = paf.person_id
                   and   ppf.effective_start_date  =
                                  (select max(ppf2.effective_start_date)
                                   from per_all_people_f ppf2
                                   where ppf2.person_id= paf.person_id
                                     and ppf2.effective_start_date
                                         <= ppa1.effective_date)
                   and   ppf.effective_end_date    >= ppa1.start_date
                   order by
                         decode(pay_ca_t4_reg.get_parameter
                           (''P_S1'',ppa1.legislative_parameters),
                                        ''GRE'',hou1.name,
                                        ''ORGANIZATION'',hou.name,
                                        ''LOCATION'',loc.location_code,null),
                           decode(pay_ca_t4_reg.get_parameter(''P_S2'',ppa1.legislative_parameters),
                                        ''GRE'',hou1.name,
                                        ''ORGANIZATION'',hou.name,
                                        ''LOCATION'',loc.location_code,null),
                           decode(pay_ca_t4_reg.get_parameter(''P_S3'',ppa1.legislative_parameters),
                                        ''GRE'',hou1.name,
                                        ''ORGANIZATION'',hou.name,
                                        ''LOCATION'',loc.location_code,null),
                           ppf.last_name,first_name';


      len := length(sqlstr); -- return the length of the string.
      hr_utility.trace('End of the sort_Action cursor');

end sort_action;


FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
  IS
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;

  BEGIN

     token_val := name||'=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);


     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;

     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;

     return par_value;

  END get_parameter;
Begin
 /*  hr_utility.trace_on(null,'T4AMEND_REG'); */
 null;


end pay_ca_eoy_t4_amend_reg;

/
