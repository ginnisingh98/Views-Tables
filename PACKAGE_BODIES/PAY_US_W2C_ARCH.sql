--------------------------------------------------------
--  DDL for Package Body PAY_US_W2C_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W2C_ARCH" AS
/* $Header: pyusw2cp.pkb 120.1.12010000.3 2009/03/05 06:54:53 asgugupt ship $ */
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

    Name        : pay_us_w2c_arch

    Description : This procedure is used by  W-2C Pre-Process
                  to archive data for W-2C Corrections Reporting.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    02-AUG-2002 asasthan   115.0            Created.
    07-FEB-2003 asasthan   115.3            Closed the prev_w2 cursor.
    07-FEB-2003 asasthan   115.6            added distinct person_id for
                                            asg_set
    11-FEB-2003 asasthan   115.9            Removed ref to hr_us_w2_mt
    18-FEB-2003 asasthan   115.10           replaced ln_person_id with
                                            p_person_id within action_creation
    19-FEB-2003 asasthan   115.11           changed get_prev curosor
                                            added date effective join
    19-FEB-2003 asasthan   115.12           added SSN to log message
    27-FEB-2003 asasthan   115.13           changed message text - doc review
    15-SEP-2003 rsethupa   115.14  2819817  created cursor to pick up the
                                            latest processed primary assignment
                                            in the w2c_action_creation
                                            procedure.
    12-NOV-2004 meshah     115.15  4009534  increased the length of variable
                                            lv_message to 150.
    15-NOV-2004 meshah     115.16           fixed gscc error File_Sql_6
    29-MAR-2005 sackumar   115.17  4222032  Change in the Range Cursor removing redundant
					    use of bind Variable (:payroll_action_id)
    02-AUG-2005 rsethupa   115.18  4349941  Added end_date check to cursor
                                            c_selected_asg_set in w2c_action_creation
                                            procedure for Perf Improvement
    31-MAR-2008 asgugupt   115.19  6909112  Set ln_primary_assignment_id properly
                                            for secondary assignment in
                                            procedure w2c_action_creation
    05-MAR-2009 asgugupt   115.20  6349762  Adding Order by clause in Range Cursor
  *****************************************************************************/

   gv_package        VARCHAR2(100) := 'pay_us_w2c_arch';
   gv_procedure_name VARCHAR2(100);



  /*****************************************************************************
   Name      : get_eoy_action_info
   Purpose   : This returns the Payroll Action level
               information for  YREND Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of EOY
               p_w2c_date          - End date of W2C Pre Process
  ******************************************************************************/
  PROCEDURE get_eoy_action_info(p_w2c_eff_date in date
                               ,p_w2c_tax_unit_id in number
                               ,p_eoy_pactid    out nocopy number
                                )
  IS

    CURSOR get_eoy_info(cp_w2c_eff_date in date
                        ,cp_w2c_tax_unit_id in number) is
    select ppa.payroll_action_id
      from pay_payroll_actions ppa
     where ppa.report_type = 'YREND'
       and ppa.effective_date =  cp_w2c_eff_date
     and pay_us_w2c_arch.get_parameter('TRANSFER_GRE',ppa.legislative_parameters)
                              = cp_w2c_tax_unit_id;

   ln_eoy_pactid number :=0;

   BEGIN

       hr_utility.trace('Entered get_eoy_action_info');

       open get_eoy_info(p_w2c_eff_date
                        ,p_w2c_tax_unit_id);

       hr_utility.trace('Opened get_eoy_info');

       fetch get_eoy_info into ln_eoy_pactid;

       hr_utility.trace('Fetched get_eoy_info ');

       close get_eoy_info;

       hr_utility.trace('Closed get_eoy_info ');

       p_eoy_pactid        := ln_eoy_pactid;

       hr_utility.trace('ln_eoy_pactid = ' ||
                            to_char(ln_eoy_pactid));
       hr_utility.trace('Leaving get_eoy_action_info');

  EXCEPTION
    when others then
       hr_utility.trace('Error in ' || gv_procedure_name ||
                         to_char(sqlcode) || '-' || sqlerrm);
       raise hr_utility.hr_error;

  END get_eoy_action_info;

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
                                   ,p_asg_set              out nocopy number
                                   )
  IS
    cursor c_payroll_Action_info (cp_payroll_action_id in number) is
      select  to_number(pay_us_w2c_arch.get_parameter(
                          'TRANSFER_GRE',ppa.legislative_parameters)),
              to_number(pay_us_w2c_arch.get_parameter(
                          'PER_ID',ppa.legislative_parameters)),
              to_number(pay_us_w2c_arch.get_parameter(
                          'SSN',ppa.legislative_parameters)),
              to_number(pay_us_w2c_arch.get_parameter(
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
    ln_tax_unit_id       NUMBER := 0;
    ln_person_id         NUMBER := 0;
    ln_asg_set           NUMBER := 0;
    lv_ssn               per_people_f.national_identifier%TYPE;
    lv_year              VARCHAR2(4) := 0;

   BEGIN
       hr_utility.trace('Entered get_payroll_action_info');
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ln_tax_unit_id,
                                        ln_person_id,
                                        lv_ssn,
                                        ln_asg_set,
                                        lv_year,
                                        ld_end_date,
                                        ld_start_date,
                                        ln_business_group_id;
       close c_payroll_action_info;

       hr_utility.trace('ld_end_date = '   || to_char(ld_end_date));
       hr_utility.trace('ld_start_date = ' || to_char(ld_start_date));
       hr_utility.trace('ln_tax_unit_id = '|| to_char(ln_tax_unit_id));
       hr_utility.trace('ln_person_id = '  || to_char(ln_person_id));
       hr_utility.trace('lv_ssn = '        || lv_ssn);
       hr_utility.trace('ln_asg_set = '    || to_char(ln_asg_set));
       hr_utility.trace('lv_year = '       || lv_year);

       p_end_date          := ld_end_date;
       p_start_date        := ld_start_date;
       p_business_group_id := ln_business_group_id;
       p_tax_unit_id       := ln_tax_unit_id;
       p_person_id         := ln_person_id;
       p_asg_set           := ln_asg_set;

       hr_utility.trace('Leaving get_payroll_action_info');

  EXCEPTION
    when others then
       hr_utility.trace('Error in ' || gv_procedure_name ||
                         to_char(sqlcode) || '-' || sqlerrm);
       raise hr_utility.hr_error;

  END get_payroll_action_info;



  /******************************************************************
   Name      : w2c_range_cursor
   Purpose   : This returns the select statement that is
               used to created the range rows for the
               W-2C Archiver.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE w2c_range_cursor(
                    p_payroll_action_id in number
                   ,p_sqlstr           out nocopy  varchar2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_tax_unit_id       NUMBER;
    ln_person_id         NUMBER := 0;
    lv_ssn               per_people_f.national_identifier%TYPE ;
    ln_asg_set           NUMBER := 0;
    lv_year              VARCHAR2(4) := 0;
    lv_sql_string  VARCHAR2(32000);
    ln_eoy_pactid        number;

  BEGIN
     hr_utility.trace('Entered w2c_range_cursor');
     hr_utility.trace('p_payroll_action_id = ' ||
                             to_char(p_payroll_action_id));

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_tax_unit_id       => ln_tax_unit_id
                            ,p_person_id         => ln_person_id
                            ,p_asg_set           => ln_asg_set);

     if ln_person_id is not null then

        lv_sql_string :=
         'select distinct asg.person_id person_id
            from per_all_assignments_f asg
           where person_id = ' || to_char(ln_person_id) ||
         ' and :p_payroll_action_id is not null';

        hr_utility.trace('Range for person_id not null');

     elsif ln_asg_set is not null then

        lv_sql_string :=
           'select distinct paf.person_id
             from hr_assignment_set_amendments asgset,
                  per_all_assignments_f paf
            where assignment_set_id = ''' || ln_asg_set || '''
              and asgset.assignment_id = paf.assignment_id
              and asgset.include_or_exclude = ''I''
              and :payroll_action_id is not null order by paf.person_id';

        hr_utility.trace('Range for asg_set not null');
    end if;

     p_sqlstr := lv_sql_string;
     hr_utility.trace('p_sqlstr = ' ||p_sqlstr);



     hr_utility.trace('Leaving w2c_range_cursor');
  END w2c_range_cursor;


  /************************************************************
   Name      : w2c_action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the W2C Archiver process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/

  PROCEDURE w2c_action_creation(
                 p_payroll_action_id   in number
                ,p_start_person_id     in number
                ,p_end_person_id       in number
                ,p_chunk               in number)

  IS

    ln_assignment_id        NUMBER := 0;
    ln_tax_unit_id          NUMBER := 0;
    ld_effective_date       DATE ;
    ln_asg_action_id        NUMBER := 0;
    ln_primary_assignment_id   NUMBER := 0;
    ln_yepp_aaid            NUMBER := 0;
    ln_payroll_action_id    NUMBER := 0;
    ln_w2c_asg_action       NUMBER := 0;
    lv_year                 VARCHAR2(4) := 0;

    ld_end_date             DATE;
    ld_start_date           DATE;
    ln_business_group_id    NUMBER;
    ln_person_id            NUMBER := 0 ;
    ln_person_id_sel        NUMBER := 0 ;
    lv_ssn                  per_people_f.national_identifier%TYPE ;
    ln_asg_set              NUMBER := 0 ;
    ln_prev_asg_action_id   NUMBER := 0;
    ln_prev_assignment_id   NUMBER := 0;
    ln_prev_tax_unit_id     NUMBER := 0;
    ld_prev_effective_date  DATE   ;
    lv_report_type          pay_payroll_actions.report_type%TYPE ;
    ln_asg_act_to_lock      pay_assignment_actions.assignment_action_id%TYPE;


    lv_serial_number        VARCHAR2(30);
    ln_eoy_pactid  number:= 0;
    lv_national_identifier  per_all_people_f.national_identifier%type;
    lv_message              varchar2(150):= null;
    lv_full_name            per_all_people_f.full_name%type;
    lv_name                 varchar2(50);
    lv_record_name   varchar2(50);
--bug 6909112 starts here
     l_tmp_asg_id       per_all_assignments_f.assignment_id%TYPE;
--bug 6909112 ends here


   CURSOR c_selected_asg_set(cp_start_person in number
                            ,cp_end_person in number
                            ,cp_asg_set in number
                            ,cp_eoy_pactid in number
			    ,cp_year_start_date in date) is
      select distinct paf.person_id
        from hr_assignment_set_amendments asgset,
             per_all_assignments_f paf
       where assignment_set_id = cp_asg_set
         and asgset.include_or_exclude = 'I'
         and paf.assignment_id = asgset.assignment_id
         --and exists (select 1 from pay_assignment_actions paa
         --           where paa.assignment_id = asgset.assignment_id
         --             and paa.payroll_action_id = cp_eoy_pactid)
         and paf.person_id between cp_start_person
                                   and cp_end_person
         and paf.effective_end_date >= cp_year_start_date;  /* Bug 4349941 */

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
            per_assignments_f paf
      where paa.assignment_id = paf.assignment_id
        and paf.person_id = cp_person_id
        and paf.effective_start_date <= cp_effective_date
        and paf.effective_end_date >= cp_start_date
        and paa.tax_unit_id = cp_tax_unit_id
        and paa.action_status = 'C'
        and ppa.payroll_action_id = paa.payroll_action_id
        and ppa.effective_date = cp_effective_date
        and ppa.report_type in ('YREND', 'W2C_PRE_PROCESS', 'W-2C PAPER')
        and paf.effective_end_date   =
              (SELECT max(paf1.effective_end_date)
               FROM   per_assignments_f paf1
               WHERE paf1.assignment_id = paf.assignment_id
               AND    paf1.effective_start_date <= ppa.effective_date
              )
      order by paa.assignment_action_id desc;


   CURSOR get_warning_dtls_for_ee(cp_person_id in number) is
      select substr(full_name,1,31), substr(national_identifier,1,11)
        from per_all_people_f
       where person_id = cp_person_id
       ORDER BY effective_end_date desc;


   /* Cursor to pick up latest processed primary assignment for
   rehired employee*/

   CURSOR get_rehired_emp (cp_person_id in number,cp_tax_unit_id in number
                           ,cp_start_date in date, cp_end_date in date) is
   SELECT   max(paa.assignment_id)
              FROM
                     pay_assignment_actions     paa,
                     per_assignments_f      paf,
                     pay_payroll_actions        ppa,
                     pay_action_classifications pac
             WHERE   paf.person_id     = cp_person_id
               AND   paa.assignment_id = paf.assignment_id
               and   paf.primary_flag  = 'Y'
               AND   paa.tax_unit_id   = cp_tax_unit_id
               and   ppa.action_status ='C'
               and   paa.action_status  = 'C'
               AND   paa.payroll_action_id = ppa.payroll_action_id
               AND   ppa.action_type = pac.action_type
               AND   pac.classification_name = 'SEQUENCED'
               AND   ppa.effective_date BETWEEN paf.effective_start_date
                                            AND paf.effective_end_date
               AND   ppa.effective_date BETWEEN  cp_start_date and
                                                 cp_end_date;


   BEGIN

      /*need to determine if the selected person has
        any unprinted W2Cs. In this case we would not
        create an action for him. Messages should be pushed in the
        logs saying why his action was not created.

         Actions will be created if

         #1 there is a YEPP action not followed by a
            W2C_PRE_PROCESS action

         #2 there is a W2C_PRE_PROCESS action for this person
            which is followed by a W2C report process */

        open get_prev_w2c_dtls(p_person_id
                              ,ln_tax_unit_id
                              ,ld_end_date
                              ,ld_start_date);
        fetch get_prev_w2c_dtls into  lv_report_type
                                     ,ln_primary_assignment_id
                                     ,ln_asg_act_to_lock;
        if get_prev_w2c_dtls%notfound then

           open get_warning_dtls_for_ee(p_person_id);
           fetch get_warning_dtls_for_ee into lv_full_name
                                              ,lv_national_identifier;
           hr_utility.trace('lv_full_name ='||lv_full_name);
           hr_utility.trace('lv_national_identifier ='||lv_national_identifier);
           lv_name := lv_full_name || ', SSN '||lv_national_identifier;


           close get_warning_dtls_for_ee;

           lv_record_name := 'W-2c Pre-Process';
           lv_message := 'The Year End Pre-Process was not run for this employee';

               /* push message into pay_message_lines */
               pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','P');
               pay_core_utils.push_token('record_name',lv_record_name);
               pay_core_utils.push_token('name_or_number',lv_name);
               pay_core_utils.push_token('description',lv_message);

        end if;


        if get_prev_w2c_dtls%found then
           if lv_report_type in ('YREND', 'W-2C PAPER') then

               /* Create an assignment action for this person */
               select pay_assignment_actions_s.nextval
                 into ln_w2c_asg_action
                 from dual;
               hr_utility.trace('New w2c Action = ' ||
                                   to_char(ln_w2c_asg_action));

               /* Insert into pay_assignment_actions. */
               hr_utility.trace('creating asg action');

               /*Bug No. 2819817- pick up latest processed primary assignment
                 In case a terminated employee is rehired and paid, the
                 latest processed assignment is picked. */
--bug 6909112 starts here
            l_tmp_asg_id:=ln_primary_assignment_id;
--bug 6909112 ends here
               open get_rehired_emp(p_person_id
                                    ,ln_tax_unit_id
                                    ,ld_start_date
                                    ,ld_end_date);
               fetch get_rehired_emp into ln_primary_assignment_id;
--bug 6909112 starts here
               if ln_primary_assignment_id is null then
                   ln_primary_assignment_id:=l_tmp_asg_id;
               end if;
--bug 6909112 ends here
               close get_rehired_emp;
               hr_nonrun_asact.insact(ln_w2c_asg_action
                                     ,ln_primary_assignment_id
                                     ,p_payroll_action_id
                                     ,p_chunk
                                     ,ln_tax_unit_id);

               /* Update the serial number column with the person id
                  so that the W2C report will not have
                  to do an additional checking against the assignment
                  table */

               hr_utility.trace('updating asg action');

               update pay_assignment_actions aa
                  set aa.serial_number = p_person_id
                where  aa.assignment_action_id = ln_w2c_asg_action;

               /* Interlock the yepp/last w2c report
                   action with current w2c action */

               hr_utility.trace('Locking Action = ' || ln_w2c_asg_action);
               hr_utility.trace('Locked Action = '  || ln_asg_act_to_lock);
               hr_nonrun_asact.insint(ln_w2c_asg_action
                                     ,ln_asg_act_to_lock);

           elsif lv_report_type = 'W2C_PRE_PROCESS' then


               open get_warning_dtls_for_ee(p_person_id);
               fetch get_warning_dtls_for_ee into lv_full_name
                                                 ,lv_national_identifier;
               hr_utility.trace('lv_full_name ='||lv_full_name);
               hr_utility.trace('lv_national_identifier ='||lv_national_identifier);
               lv_name := lv_full_name || ', SSN '||lv_national_identifier;

               close get_warning_dtls_for_ee;

               lv_record_name := 'W-2c Pre-Process';
               lv_message := 'An unprinted W-2c exists';

               /* push message into pay_message_lines */
               pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','P');
               pay_core_utils.push_token('record_name',lv_record_name);
               pay_core_utils.push_token('name_or_number',lv_name);
               pay_core_utils.push_token('description',lv_message);
           end if; /* report type */

        end if; /* employee found*/

        close get_prev_w2c_dtls;

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
                            ,p_tax_unit_id       => ln_tax_unit_id
                            ,p_person_id         => ln_person_id
                            ,p_asg_set           => ln_asg_set);

     get_eoy_action_info(ld_end_date
                        ,ln_tax_unit_id
                        ,ln_eoy_pactid);

     /* PERSON ID IS NOT NULL */

     if ln_person_id is not null then

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
                                 ,ln_asg_set
                                 ,ln_eoy_pactid
				 ,ld_start_date) ;
        hr_utility.trace('Opened cusor c_selected_asg_set');
        loop
           fetch c_selected_asg_set into ln_person_id_sel ;
           if c_selected_asg_set%notfound then
              hr_utility.trace('No Person found for reporting in this chunk');
              exit;
           end if;

        hr_utility.trace('ln_person_id after c_selected_asg_set = '||to_char(ln_person_id));

         action_creation(ln_person_id_sel);

        end loop;

        close c_selected_asg_set;

     end if; /*  ln_person_id or lv_ssn is not null */

  END w2c_action_creation;

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

--Begin
--hr_utility.trace_on(null,'W2C');


end pay_us_w2c_arch;

/
