--------------------------------------------------------
--  DDL for Package Body PAY_CA_EOY_RL2_AMEND_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EOY_RL2_AMEND_ARCH" AS
/* $Header: pycarl2ca.pkb 120.1.12010000.4 2009/09/09 05:15:03 aneghosh ship $ */
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

    Name        : pay_ca_eoy_rl2_amend_arch

    Description : This procedure is used by RL2 Amendment PreProcess
                  to archive data for RL2 Amendment Paper Report.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    17-JAN-2006 SSouresr   115.0            Created.
    11-OCT-2006 meshah     115.1    5528944 Added order by clause in the range
                                            cursor queries.
    17-JUN-2009 aneghosh   115.2    8316787 Modified the locking mechanism.
    24-AUG-2009 aneghosh   115.3    8316787 Removed locking of RL2_AMD_MAG and
                                            RL1_XML_MAG.
    09-SEP-2009 aneghosh   115.4    8316787 Removed  RL2_AMD_MAG and
                                            RL1_XML_MAG from cursor
                                            get_prev_rl2_amend_dtls.
   ****************************************************************************/

   gv_package        VARCHAR2(100) := 'pay_ca_eoy_rl2_amend_arch';
   gv_procedure_name VARCHAR2(100);


  /*****************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for  Provincial YE Amendment Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_start_date        - Start date of Archiver
               p_end_date          - End date of Archiver
               p_business_group_id - Business Group ID
  ******************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     in number
                                   ,p_end_date             out nocopy date
                                   ,p_start_date           out nocopy date
                                   ,p_business_group_id    out nocopy number
                                   ,p_pre_org_id           out nocopy number
                                   ,p_person_id            out nocopy number
                                   ,p_asg_set              out nocopy number
                                   ,p_year                 out nocopy varchar2)
  IS
    cursor c_payroll_Action_info (cp_payroll_action_id in number) is
      select  to_number(pay_ca_eoy_rl2_amend_arch.get_parameter(
                          'PRE_ORGANIZATION_ID',ppa.legislative_parameters)),
              to_number(pay_ca_eoy_rl2_amend_arch.get_parameter(
                          'PER_ID',ppa.legislative_parameters)),
              to_number(pay_ca_eoy_rl2_amend_arch.get_parameter(
                          'SSN',ppa.legislative_parameters)),
              to_number(pay_ca_eoy_rl2_amend_arch.get_parameter(
                          'ASG_SET',ppa.legislative_parameters)),
             to_char(effective_date,'YYYY') ,
             effective_date,
             start_date,
             business_group_id
        from pay_payroll_actions ppa
       where ppa.payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_pre_org_id        NUMBER := 0;
    ln_person_id         NUMBER := 0;
    ln_asg_set           NUMBER := 0;
    lv_sin               per_all_people_f.national_identifier%TYPE;
    lv_year              VARCHAR2(4);

   BEGIN
       hr_utility.trace('Entered get_payroll_action_info');
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ln_pre_org_id,
                                        ln_person_id,
                                        lv_sin,
                                        ln_asg_set,
                                        lv_year,
                                        ld_end_date,
                                        ld_start_date,
                                        ln_business_group_id;
       close c_payroll_action_info;

       hr_utility.trace('ld_end_date = '   || to_char(ld_end_date));
       hr_utility.trace('ld_start_date = ' || to_char(ld_start_date));
       hr_utility.trace('ln_pre_org_id = ' || to_char(ln_pre_org_id));
       hr_utility.trace('ln_person_id = '  || to_char(ln_person_id));
       hr_utility.trace('lv_sin = '        || lv_sin);
       hr_utility.trace('ln_asg_set = '    || to_char(ln_asg_set));
       hr_utility.trace('lv_year = '       || lv_year);

       p_end_date          := ld_end_date;
       p_start_date        := ld_start_date;
       p_business_group_id := ln_business_group_id;
       p_pre_org_id        := ln_pre_org_id;
       p_person_id         := ln_person_id;
       p_asg_set           := ln_asg_set;
       p_year              := lv_year;

       hr_utility.trace('Leaving get_payroll_action_info');

  EXCEPTION
    when others then
       hr_utility.trace('Error in ' || gv_procedure_name ||
                         to_char(sqlcode) || '-' || sqlerrm);
       raise hr_utility.hr_error;

  END get_payroll_action_info;



  /******************************************************************
   Name      : eoy_range_cursor
   Purpose   : This returns the select statement that is
               used to create the range rows for the
               Provincial YE Amendment Pre-Process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE eoy_range_cursor(
                    p_payroll_action_id in number
                   ,p_sqlstr           out nocopy  varchar2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_pre_org_id        NUMBER;
    ln_person_id         NUMBER := 0;
    lv_sin               per_all_people_f.national_identifier%TYPE ;
    ln_asg_set           NUMBER := 0;
    lv_year              VARCHAR2(4);
    lv_sql_string        VARCHAR2(32000);
    ln_eoy_pactid        number;
    lv_record_name       varchar2(80);
    lv_message           varchar2(100) := null;

  BEGIN
     hr_utility.trace('Entered eoy_range_cursor');
     hr_utility.trace('p_payroll_action_id = ' ||
                             to_char(p_payroll_action_id));

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_pre_org_id        => ln_pre_org_id
                            ,p_person_id         => ln_person_id
                            ,p_asg_set           => ln_asg_set
                            ,p_year              => lv_year);

     if ln_person_id is not null then

        lv_sql_string :=
         'select distinct asg.person_id person_id
            from per_all_assignments_f asg
           where person_id = ' || to_char(ln_person_id) ||
         ' and :p_payroll_action_id > 0';

        hr_utility.trace('Range for person_id not null');

     elsif ln_asg_set is not null then

        lv_sql_string :=
           'select distinct paf.person_id
             from hr_assignment_set_amendments asgset,
                  per_all_assignments_f paf
            where assignment_set_id = ' || to_char(ln_asg_set) || '
              and asgset.assignment_id = paf.assignment_id
              and asgset.include_or_exclude = ''I''
              and :payroll_action_id > 0
            order by paf.person_id';

        hr_utility.trace('Range for asg_set not null');

     else

        lv_record_name := 'Provincial Amendment Pre-Process';
        lv_message := 'No Employee or Assignment Set specified';

               /* push message into pay_message_lines */
        pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','P');
        pay_core_utils.push_token('record_name',substr(lv_record_name,1,50));
        pay_core_utils.push_token('name_or_number','');
        pay_core_utils.push_token('description',substr(lv_message,1,50));

        lv_sql_string :=
         'select distinct asg.person_id person_id
          from per_all_assignments_f asg
          where person_id =  0
           and :p_payroll_action_id > 0
          order by asg.person_id ';

        hr_utility.trace('No person is selected as ln_person_id and ln_asg_set are null');

     end if;

     p_sqlstr := lv_sql_string;
     hr_utility.trace('p_sqlstr = ' ||p_sqlstr);

     hr_utility.trace('Leaving eoy_range_cursor');
  END eoy_range_cursor;


  /************************************************************
   Name      : eoy_action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the Provincial YE Amendment Pre-process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/

  PROCEDURE eoy_action_creation(
                 p_payroll_action_id   in number
                ,p_start_person_id     in number
                ,p_end_person_id       in number
                ,p_chunk               in number)

  IS

    ln_assignment_id        NUMBER := 0;
    ln_pre_org_id           NUMBER := 0;
    ld_effective_date       DATE ;
    ln_asg_action_id        NUMBER := 0;
    ln_primary_assignment_id   NUMBER := 0;
    ln_yepp_aaid            NUMBER := 0;
    ln_payroll_action_id    NUMBER := 0;
    ln_rl2amend_asg_action  NUMBER := 0;
    lv_year                 VARCHAR2(4);

    ld_end_date             DATE;
    ld_start_date           DATE;
    ln_business_group_id    NUMBER;
    ln_person_id            NUMBER := 0 ;
    ln_person_id_sel        NUMBER := 0 ;
    lv_sin                  per_all_people_f.national_identifier%TYPE ;
    ln_asg_set              NUMBER := 0 ;
    ln_prev_asg_action_id   NUMBER := 0;
    ln_prev_assignment_id   NUMBER := 0;
    ld_prev_effective_date  DATE   ;
    lv_report_type          pay_payroll_actions.report_type%TYPE ;
    ln_asg_act_to_lock      pay_assignment_actions.assignment_action_id%TYPE;


    lv_serial_number        VARCHAR2(30);
    ln_eoy_pactid           number := 0;
    lv_national_identifier  per_all_people_f.national_identifier%type;
    lv_message              varchar2(100):= null;
    lv_full_name            per_all_people_f.full_name%type;
    lv_name                 varchar2(100);
    lv_record_name          varchar2(80);


   CURSOR c_selected_asg_set(cp_start_person in number
                            ,cp_end_person in number
                            ,cp_asg_set in number) is
      select distinct paf.person_id
      from hr_assignment_set_amendments asgset,
           per_all_assignments_f  paf,
           pay_assignment_actions paa,
           pay_payroll_actions    ppa
      where
       (pay_ca_eoy_rl2_amend_arch.get_parameter('PRE_ORGANIZATION_ID',
                     ppa.legislative_parameters) = to_char(ln_pre_org_id)
OR  pay_ca_eoy_rl2_amend_arch.get_parameter('TRANSMITTER_PRE',
                     ppa.legislative_parameters) = to_char(ln_pre_org_id))
AND asgset.assignment_set_id = cp_asg_set
      and asgset.include_or_exclude = 'I'
      and paf.assignment_id = asgset.assignment_id
      and paf.person_id between cp_start_person
                            and cp_end_person
      and ppa.report_type IN ('RL2', 'CAEOY_RL2_AMEND_PP')
      and to_char(ppa.effective_date,'YYYY') = lv_year
      and ppa.business_group_id+0 = ln_business_group_id
--      and pay_ca_eoy_rl2_amend_arch.get_parameter('PRE_ORGANIZATION_ID',
--                     ppa.legislative_parameters) = to_char(ln_pre_org_id)
      and paa.payroll_action_id = ppa.payroll_action_id
      and paa.action_status = 'C'
      and paf.person_id = to_number(paa.serial_number);

   PROCEDURE action_creation (p_person_id in NUMBER)
   IS

     CURSOR get_prev_rl2_amend_dtls (cp_person_id      in number
                                    ,cp_pre_org_id     in number
                                    ,cp_effective_date in date) is
     select ppa.report_type,
            paa.assignment_id,
            paa.assignment_action_id
      from pay_payroll_actions ppa,
           pay_assignment_actions paa
      where  (pay_ca_eoy_rl2_amend_arch.get_parameter('PRE_ORGANIZATION_ID',
                     ppa.legislative_parameters) = to_char(ln_pre_org_id)
OR  pay_ca_eoy_rl2_amend_arch.get_parameter('TRANSMITTER_PRE',
                     ppa.legislative_parameters) = to_char(ln_pre_org_id))
AND to_number(paa.serial_number) = cp_person_id
--      and pay_ca_eoy_rl2_amend_arch.get_parameter('PRE_ORGANIZATION_ID',
--                     ppa.legislative_parameters) = to_char(cp_pre_org_id)
      and paa.action_status = 'C'
      and ppa.business_group_id+0 = ln_business_group_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and ppa.effective_date = cp_effective_date
      and ppa.report_type IN ('RL2', 'CAEOY_RL2_AMEND_PP')
      order by paa.assignment_action_id desc;

   CURSOR get_warning_dtls_for_ee(cp_person_id in number) is
      select substr(full_name,1,31), substr(national_identifier,1,11)
        from per_all_people_f
       where person_id = cp_person_id
       ORDER BY effective_end_date desc;


   BEGIN

      /* Actions will be created if

         #1 there is a YEPP action not followed by a
            RL2 Amendment Archiver action

         #2 there is already a Previous RL2 Amendment Archiver
            action for this person
      */

        open get_prev_rl2_amend_dtls(p_person_id
                                    ,ln_pre_org_id
                                    ,ld_end_date);
        fetch get_prev_rl2_amend_dtls into  lv_report_type
                                           ,ln_primary_assignment_id
                                           ,ln_asg_act_to_lock;
           hr_utility.trace('lv_report_type ='||lv_report_type);
           hr_utility.trace('ln_primary_assignment_id ='||
                              to_char(ln_primary_assignment_id));
           hr_utility.trace('ln_asg_act_to_lock ='||
                              to_char(ln_asg_act_to_lock));

        if get_prev_rl2_amend_dtls%notfound then

           hr_utility.trace('get_prev_rl2_amend_dtls Not Found');
           hr_utility.trace('Warning Message Generated');
           hr_utility.trace('p_person_id ='||to_char(p_person_id));

           open get_warning_dtls_for_ee(p_person_id);
           fetch get_warning_dtls_for_ee into lv_full_name
                                             ,lv_national_identifier;

           hr_utility.trace('lv_full_name ='||lv_full_name);
           hr_utility.trace('lv_national_identifier ='||lv_national_identifier);

           lv_name := lv_full_name || ', SIN '||lv_national_identifier;

           close get_warning_dtls_for_ee;

           lv_record_name := 'RL2 Amendment Pre-Process';
           lv_message := 'Prov YE Preprocess was not run for this employee';

               /* push message into pay_message_lines */
           pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','A');
           pay_core_utils.push_token('record_name',substr(lv_record_name,1,50));
           pay_core_utils.push_token('name_or_number',substr(lv_name,1,50));
           pay_core_utils.push_token('description',substr(lv_message,1,50));

        end if;


        if get_prev_rl2_amend_dtls%found then
           hr_utility.trace('get_prev_rl2_amend_dtls Found');

           if lv_report_type in ('RL2', 'CAEOY_RL2_AMEND_PP') then

               /* Create an assignment action for this person */
               select pay_assignment_actions_s.nextval
                 into ln_rl2amend_asg_action
                 from dual;
               hr_utility.trace('New RL2 Amendment Action = ' ||
                                   to_char(ln_rl2amend_asg_action));

               /* Insert into pay_assignment_actions. */
               -- hr_utility.trace('creating asg. action');
               hr_nonrun_asact.insact(ln_rl2amend_asg_action
                                     ,ln_primary_assignment_id
                                     ,p_payroll_action_id
                                     ,p_chunk
                                     ,null);

               /* Update the serial number column with the person id
                  so that the RL2 Amendment report will not have
                  to do an additional checking against the assignment
                  table */

               -- hr_utility.trace('updating asg. action');

               update pay_assignment_actions aa
                  set aa.serial_number = to_char(p_person_id)
                where  aa.assignment_action_id = ln_rl2amend_asg_action;

               /* Interlock the YEPP or Previous RL2 Amendment Archiver
                   action for current RL2 Amendment Pre-process action */

               hr_utility.trace('Locking Action = ' || to_char(ln_rl2amend_asg_action));
               hr_utility.trace('Locked Action = '  || to_char(ln_asg_act_to_lock));
               hr_nonrun_asact.insint(ln_rl2amend_asg_action
                                     ,ln_asg_act_to_lock);

           end if; /* report type */

        end if; /* employee found*/

        close get_prev_rl2_amend_dtls;
        hr_utility.trace('closed get_prev_rl2_amend_dtls');
   END action_creation;

  BEGIN

     hr_utility.trace('Entered eoy_action_creation ');
     hr_utility.trace('p_payroll_action_id = '|| to_char(p_payroll_action_id));
     hr_utility.trace('p_start_person_id ='|| to_char(p_start_person_id));
     hr_utility.trace('p_end_person_id = '|| to_char(p_end_person_id));
     hr_utility.trace('p_chunk  = '       || to_char(p_chunk));

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_pre_org_id        => ln_pre_org_id
                            ,p_person_id         => ln_person_id
                            ,p_asg_set           => ln_asg_set
                            ,p_year              => lv_year);

     /* PERSON ID IS NOT NULL */

     if ln_person_id is not null then

        hr_utility.trace('Entered PersonId logic');
        action_creation(p_start_person_id);

     elsif ln_asg_set is not null then

        hr_utility.trace('Entered Asg Set logic');
        hr_utility.trace('Asg Set ='||to_char(ln_asg_set));

        ln_person_id_sel := 0;

        hr_utility.trace('p_start_person_id ='||to_char(p_start_person_id));
        hr_utility.trace('End Person ='||to_char(p_end_person_id));
        hr_utility.trace('Asg Set ='||to_char(ln_asg_set));
        hr_utility.trace('EOY Pactid ='||to_char(ln_eoy_pactid));

        open c_selected_asg_set  (p_start_person_id
                                 ,p_end_person_id
                                 ,ln_asg_set);
        hr_utility.trace('Opened cusor c_selected_asg_set');
        loop
           fetch c_selected_asg_set into ln_person_id_sel ;
           if c_selected_asg_set%notfound then
              hr_utility.trace('No Person found for reporting in this chunk');
              exit;
           end if;

        hr_utility.trace('ln_person_id after c_selected_asg_set = '||to_char(ln_person_id_sel));

         action_creation(ln_person_id_sel);

        end loop;

        close c_selected_asg_set;

     end if; /*  ln_person_id or lv_sin is not null */

  END eoy_action_creation;

FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin

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

end get_parameter;

Begin
null;

end pay_ca_eoy_rl2_amend_arch;

/
