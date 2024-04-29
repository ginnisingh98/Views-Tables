--------------------------------------------------------
--  DDL for Package Body PAY_EOSURVEY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EOSURVEY_PKG" as
/* $Header: pyuseosy.pkb 120.2.12000000.2 2007/07/16 17:29:57 rpasumar noship $ */
/*Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Name        :This package defines the cursors needed for EO Survey report.

REM Change List:
REM ------------
REM
REM Name           Date       Version Bug     Text
REM -------------- ---------- ------- ------- ------------------------------
REM fusman        02-APR-01    115.0          Created
REM fusman        13-may-01    115.1          Added Change list and mesgs.
REM fusman        15-may-01    115.2          Changed the comments.
REM fusman        17-may-01    115.3          Added the check condition for the dates.
REM fusman        29-jun-01    115.4          Changed the date setting.
REM vbanner       28-jun-04    115.6          GSCC changes (dbdrv etc).
REM vbanner       28-jun-04    115.7          Further GSCC changes (to_date etc).
REM ynegoro       19-JUL-04    115.8 3730282  Added substr(p_location_name,1,80)
REM                                             to insert a record into
REM                                             pay_us_rpt_totals
REM                                           Changed promotion procedure
REM ynegoro       28-SEP-04    115.9 3894120  Changed the length of fein
REM                                           in TYPE establishment
REM ynegoro       05-OCT-04   115.10 3886008  Added l_hours_worked is NULL
REM                                           in hire_of_fte procedure
REM ynegoro       14-OCT-04   115.12 3940867  Changed parameters to open
REM                                           assignment_details cursor in
REM                                           find_persons procuedure
REM ynegoro       14-OCT-04   115.13 3940867  Changed c_person_infm cursor
REM                                           comment out max(ppf1.effective_start_date)
REM ynegoro       15-OCT-04   115.14          Added new parameters to
REM                                           hire_or_fte procedure
REM                                  3941606  Added minority procedure call
REM                                           when applicant's racecode is NULL
REM                                  3954458  Added c_check_future_termination
REM                                           cursor for FTE count
REM ynegoro       18-OCT-04   115.15          Changed assignment_details
REM ynegoro       19-OCT-04   115.16 3941606  Added c_get_updated_racecode cursor
REM ynegoro       19-OCT-04   115.17 3954458  Changed paremeter from p_period_start
REM                                           to p_eff_start_date to open
REM                                           c_check_future_termination cursor
REM                                  3878442  Added 'EMP_APL' to include
REM                                           APPLICANT cont in app_fire_count
REM ynegoro       20-OCT-04   115.18 3954458  Changed c_app_term_assignment
REM                                           to pick up terminated employees
REM                                           who are rehired.
REM ynegoro       21-OCT-04   115.19 3963090  Changed promotion procedure to
REM                                           pick up multiple promotions
REM ynegoro       22-OCT-04   115.20 3878442  Defined the following variables
REM                                           as local variables
REM                                               m_app_count
REM                                               f_app_count
REM                                               m_terminate_count
REM                                               f_terminate_count
REM                                               m_hire_count
REM                                               f_hire_count
REM                                               m_fte_count
REM                                               f_fte_count
REM                                               m_promotion_count
REM                                               f_promotion_count
REM ynegoro       03-NOV-04 115.21   3993335  Added p_eff_start_date and
REM                                           p_eff_end_date parameters to
REM                                           promotion procedure
REM ynegoro       15-JUN-05 115.22   4434130  Updated c_app_term_assignments,
REM                                           c_persons,c_person_infm cursors
REM                                           to pick up rehired employees in
REM                                           different job group
REM ynegoro       20-JUN-05 115.23   4445250  Updated c_persons cursor to
REM                                           pick up correct terminated
REM                                           employees
REM rpasumar     15-JUL-2007 115.24   5982927 Modified the report so that
REM                                                                        it won't consider the changes to eeo1 job categories
REM                                                                        and US ethnic group lookup changes.
REM ========================================================================



--------------------Global variables-------------------------------------------
To store the establishment information and fein number this table is
declared globally. */

TYPE establishment IS RECORD(
     entity_id per_gen_hierarchy_nodes.entity_id%TYPE,
     hierarchy_node_id per_gen_hierarchy_nodes.hierarchy_node_id%TYPE,
     fein  varchar2(100),          -- BUG3894120
     location_name varchar2(1000),
     est_flag varchar2(1));
est_rec establishment;
TYPE est IS TABLE OF est_rec%TYPE
INDEX BY BINARY_INTEGER;
est_infm est;

   minority_code number;
   ethnic_group_code  varchar2(2);
   monetary_comp number :=null;
   tenure_years number :=0;
   tenure_months number :=0;
   l_est_flag varchar2(1);
   l_est_name varchar2(100);
   l_est_fein varchar2(100);
   l_est_id number;
   fte_flag varchar2(1);

   p_fein     varchar2(100);
   p_location_name varchar2(100);
   l_seq_num number;

PROCEDURE app_fire_count (p_est_entity_id            in number,
                          p_hierarchy_version_id     in number,
                          p_period_start             in date,
                          p_period_end               in date,
                          p_seq_num                  in number)
IS

   /* This cursor picks up all the establishments and locations for a given
    hierarchy version id. If an establishment is given then it picks up the
    locations under that establishment and including the entity_id of that est.*/

   CURSOR c_est_loc
       (l_est_id per_gen_hierarchy_nodes.entity_id%type,
        l_hierarchy_version_id per_gen_hierarchy_versions.hierarchy_version_id%type)
   IS
     SELECT entity_id,parent_hierarchy_node_id
     FROM per_gen_hierarchy_nodes
     WHERE hierarchy_version_id = l_hierarchy_version_id
     AND (
         (
           entity_id = nvl(l_est_id,entity_id)
           AND node_type ='EST'
         )
        OR
          (
             parent_hierarchy_node_id in(select hierarchy_node_id from per_gen_hierarchy_nodes
                                     where hierarchy_version_id =l_hierarchy_version_id
                                     and   entity_id = nvl(l_est_id,entity_id)
                                     and node_type = 'EST')
            AND node_type = 'LOC'
         )
      );


  /* This cursor picks up the applicants and the terminated employees
   from the given location.*/

  CURSOR c_app_term_assignments
    ( l_location_id per_gen_hierarchy_nodes.entity_id%type,
      l_period_end date,
      l_period_start per_assignments_f.effective_start_date%type
     )
  IS
  /* Retrieve applicants only */
  SELECT paf.assignment_id,
         paf.person_id,
         pj.job_information1 job_category,
         paf.assignment_status_type_id
        ,'APPLICANT'
  FROM  per_assignments_f paf,
        per_jobs pj,
        per_assignment_status_types past,
        fnd_common_lookups fcl
  WHERE paf.assignment_status_type_id = past.assignment_status_type_id
   AND --((
                   paf.assignment_type = 'A'
                    and paf.effective_end_date >= l_period_start
                    and paf.effective_start_date <= l_period_end
       --)
       --        or (paf.assignment_type = 'E'
       --            and paf.primary_flag = 'Y'
       --            and paf.effective_start_date between
       --                  l_period_start and l_period_end)
       --                         )
   AND paf.effective_start_Date = (select max(paf1.effective_Start_date)
                                    from per_assignments_f paf1
                                    where paf1.assignment_id = paf.assignment_id
                                    and paf1.effective_start_Date <=l_period_end
                                    and paf1.assignment_status_type_id =
                                                        paf.assignment_Status_type_id)
  --AND past.per_system_status in ('ACTIVE_APL','ACCEPTED','TERM_ASSIGN','SUSP_ASSIGN')
  AND past.per_system_status in ('ACTIVE_APL','ACCEPTED','SUSP_ASSIGN')
  AND pj.job_id = paf.job_id
  AND pj.job_information1 = fcl.lookup_code
  AND fcl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
  AND fcl.lookup_code <> '10'
  AND paf.location_id = l_location_id
  UNION
  /* Retrieve terminated employees only */
  SELECT paf.assignment_id
        ,paf.person_id
        ,pj.job_information1 job_category
        ,paf.assignment_status_type_id
        ,ppt.system_person_type
  FROM  per_people_f ppf
       ,per_assignments_f paf
       ,per_periods_of_service pps
       ,per_person_types ppt
       ,per_jobs pj
       ,fnd_common_lookups fcl
  WHERE pps.person_id			= paf.person_id
  and pps.actual_termination_date is not null
  and pps.actual_termination_date
	between l_period_start and l_period_end
  /* BUG4434130
  and ppf.effective_start_date =
               (select max(ppf2.effective_start_date)
                from per_people_f ppf2
                where ppf2.person_id = ppf.person_id
                and ppf2.current_employee_flag is null
               )
   */
   and pps.date_start = ppf.effective_start_date
   and pps.actual_termination_date between
       ppf.effective_start_date and ppf.effective_end_date
   -- End of BUG4434130
   and ppf.person_id			= paf.person_id
   and pps.actual_termination_date between
       paf.effective_start_date and paf.effective_end_date
   and ppf.person_type_id = ppt.person_type_id
   And paf.assignment_type		= 'E'
   And paf.primary_flag			= 'Y'
   AND pj.job_id = paf.job_id
   AND pj.job_information1 = fcl.lookup_code
   AND fcl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
   AND fcl.lookup_code <> '10'
   AND paf.location_id = l_location_id
  order by 2;


  /* This cursor picks up the person's information.*/

  CURSOR c_persons
     (l_person_id per_people_f.person_id%type,
      l_period_start date,
      l_period_end date)
   is
   select ppf.per_information1   race_code
         ,ppf.sex                sex
         ,ppt.system_person_type person_type
         ,pj.job_information1    job_category -- BUG4434130
   from   per_people_f       ppf
         ,per_person_types   ppt
         ,per_assignments_f  paf              -- BUG4434130
         ,per_jobs           pj               -- BUG4434130
   where  ppf.effective_start_date <= l_period_end
   and    ppf.effective_end_date >= l_period_start
   and    ppf.person_type_id = ppt.person_type_id
   -- and    ppt.system_person_type not in ( 'EMP_APL','EMP')
   and    ppt.system_person_type <> 'EMP'     -- BUG3878442
   and    ppf.effective_start_Date
             = (select max(effective_Start_date)
                from per_people_f ppf1
                where ppf1.person_type_id = ppf.person_type_id
                and ppf1.effective_start_Date <=l_period_end
                and ppf1.person_id =ppf.person_id
               )
   and ppt.system_person_type in ('APL','APL_EX_APL','EX_APL','EX_EMP_APL','EMP_APL') -- BUG3878442
   and    ppf.person_id = l_person_id
   -- BUG4434130
   and    paf.person_id            = ppf.person_id
   and    paf.effective_start_date = ppf.effective_start_date
   and    paf.job_id               = pj.job_id
   -- End of BUG4434130
   -- BUG4434130
   /* Retrieve terminated employees */
   UNION
   select ppf.per_information1   race_code
         ,ppf.sex                sex
         ,'EX_EMP'               person_type
         ,pj.job_information1    job_category
   from   per_people_f           ppf
         ,per_periods_of_service pps
         ,per_assignments_f      paf
         ,per_jobs               pj
   where  ppf.person_id = l_person_id
   and    pps.person_id = ppf.person_id
   and    pps.actual_termination_date is not null
   and    pps.actual_termination_date between
              l_period_start and l_period_end
   and    paf.person_id = ppf.person_id
   and    pps.date_start = ppf.effective_start_date    -- BUG4445250
   and    paf.effective_start_date = ppf.effective_start_date
   and    paf.job_id = pj.job_id;
   -- End of BUG4434130


   /* An assignment_type of 'A' is checked if its an ACCEPTED assignment.*/

   CURSOR applicant_accepted(l_asgn_status_id
                             per_assignment_status_types.assignment_status_type_id%type)
   is
   select 'x'
   from   per_assignment_status_types
   where  per_system_status = 'ACCEPTED'
   and    assignment_status_type_id = l_asgn_status_id;

 /* This cursor checks if applicant was also an ACTIVE_APL in the same period.
   If he had both the status in the same period then he should be counted just once.*/

   CURSOR applicant_active(l_asgn_id per_assignments_f.assignment_id%type,
                           l_period_start date,
                           l_period_end   date)
   is
   select 'x'
   from per_assignments_f paf,
        per_assignment_Status_types past
   where paf.assignment_id = l_asgn_id
   and paf.assignment_type = 'A'
   and paf.assignment_status_type_id = past.assignment_status_type_id
   and past.per_system_status = 'ACTIVE_APL'
   and  paf.effective_start_date >= l_period_start
   and paf.effective_end_date <= l_period_end;


  CURSOR c_race_code
     (l_person_id per_people_f.person_id%type,
      l_period_start date,
      l_period_end   date)
   is
   select ppf.per_information1   race_code,
          ppt.system_person_type person_type
   from   per_people_f     ppf
         ,per_person_types ppt
         ,per_periods_of_service pps
   where  ppf.effective_start_date <= l_period_end
   and    ppf.effective_end_date >= l_period_start
   and    ppf.per_information1 is not NULL
   and    ppf.person_type_id = ppt.person_type_id
   and    ppt.system_person_type  = 'EMP'
   and    pps.person_id = ppf.person_id
   and    ppf.effective_start_date = pps.date_start
   and    ppf.person_id = l_person_id;

   fein               varchar2(30);
   location_name      varchar2(100);
   ethnic_group_code  varchar2(2);
   l_app_count        varchar2(1) := null;
   l_entity_id        number;
   l_version_id       number;
   l_person_id        number;
   l_accepted_flag    varchar2(1);
   l_active_flag      varchar2(1);
   l_race_code        varchar2(40); -- BUG3941606
   l_person_type      varchar2(40); -- BUG3941606
   l_package          varchar2(70);


   -- Defined local variables BUG3878442
   m_app_count number:=0;
   f_app_count number:=0;
   m_terminate_count number :=0;
   f_terminate_count number :=0;
   m_hire_count number :=0;
   f_hire_count number :=0;
   m_fte_count number :=0;
   f_fte_count number :=0;
   m_promotion_count number :=0;
   f_promotion_count number :=0;

   begin
   --hr_utility.trace_on(null,'ORACLE');
   l_package := 'pay_eosurvey_pkg.app_fire_count';

   hr_utility.trace('==============================app_fire_count==================================');
   hr_utility.set_location('Entering.. ' || l_package,10);
   fte_flag:='N';

   FOR est in c_est_loc(p_est_entity_id ,
                        p_hierarchy_version_id )
     LOOP

       hr_utility.trace('Inside Loop1.location_id = ' || est.entity_id);

      /* For the selected location assignments are picked up.*/

     FOR app_term in c_app_term_assignments( est.entity_id
                                            ,p_period_end,p_period_start)
       LOOP
           hr_utility.trace('Inside Loop2.assignment id = '|| to_char(app_term.assignment_id));

           hr_utility.trace('l_person_id        = '||to_char(l_person_id));
           hr_utility.trace('app_term.person_id = '||to_char(app_term.person_id));
           hr_utility.set_location(l_package||':person_id='||app_term.person_id,20);
           hr_utility.trace('assignment_id      = '||to_char(app_term.assignment_id));

           /*An assignment will be picked up twice if it has two different status
           in the same period for the same person.To avoid running the person
           loop twice checking is done here.*/

           IF (l_person_id IS NULL OR l_person_id <> app_term.person_id) THEN

              hr_utility.set_location(l_package||':person_id='||app_term.person_id,30);
              hr_utility.trace('assignment_id      = '||app_term.assignment_id);

              FOR per in c_persons(app_term.person_id,
                                   p_period_start,
                                   p_period_end)
                LOOP

                hr_utility.set_location(l_package||':person_id='||app_term.person_id,40);
                hr_utility.trace('Inside Loop3.Person_id = '||app_term.person_id);
                hr_utility.trace('Person_type = '||per.person_type);
                hr_utility.trace('Job_category= '||per.job_category);

                /*If the assignment is an Applicant then he is checked for ACCEPTED
                 and checked for ACTIVE_APL also*/

                -- IF per.person_type in ('APL','APL_EX_APL','EX_EMP_APL') then
                IF per.person_type in ('APL','APL_EX_APL','EX_EMP_APL','EMP_APL') then  -- BUG3878442
                   hr_utility.set_location(l_package||':person_id='||app_term.person_id,50);

                   OPEN applicant_accepted(app_term.assignment_status_type_id);
                   FETCH applicant_accepted into l_accepted_flag;
                   hr_utility.trace('After applicant_accepted. l_accepted_flag = '
                                                  ||l_accepted_flag);

                   IF applicant_accepted%found and l_accepted_flag IS NOT NULL THEN

                      CLOSE applicant_accepted;
                      hr_utility.set_location(l_package||':person_id='||app_term.person_id,60);

                      /* The applicant has a status ACCEPTED.
                       Check if he is also with the status ACTIVE_APL in the same period.*/

                      OPEN applicant_active(app_term.assignment_id,
                                            p_period_Start,
                                            p_period_end);
                      FETCH applicant_active into l_active_flag;
                       hr_utility.trace('After applicant_active. l_active_flag = '
                                                  ||l_active_flag);

                      /*If not then count him as an applicant.Which means that this
                       applicant was with the status just ACCEPTED.*/

                      IF applicant_active%notfound and l_active_flag IS NULL THEN

                         CLOSE applicant_active;
                         hr_utility.set_location(l_package||':person_id='||app_term.person_id,70);
                         hr_utility.trace('After applicant_active%notfound ');
                         male_female_count(per.sex,
                                           m_app_count,
                                           f_app_count);
                      ELSE

                         CLOSE applicant_active;
                         hr_utility.set_location(l_package||':person_id='||app_term.person_id,80);

                      END IF;

                  ELSE /* The applicant is with status ACTIVE_APL. So count him.*/

                      hr_utility.set_location(l_package||':person_id='||app_term.person_id,90);
                      hr_utility.trace('The applicant is with status ACTIVE_APL. So count him.');
                       CLOSE applicant_accepted;
                       male_female_count(per.sex,
                                         m_app_count,
                                         f_app_count);
                  END IF;

               ELSIF per.person_type = 'EX_EMP' then      -- BUG4434130
                      hr_utility.set_location(l_package||':person_id='||app_term.person_id,100);
                      hr_utility.set_location(l_package||':asg_id   ='||app_term.assignment_id,101);
                      hr_utility.set_location(l_package||':job_category='||per.job_category,102);

                      hr_utility.trace('Person is TERMINATED = '||app_term.person_id);

                      male_female_count(per.sex,
                                       m_terminate_count,
                                       f_terminate_count);

               END IF;
               hr_utility.set_location(l_package||':person_id='||app_term.person_id,110);


             /* To categorise on what ethnic group they are belonging this procedure
              is called.*/

             IF (per.person_type in ('APL','APL_EX_APL','EX_APL','EX_EMP_APL')
                AND per.race_code is NULL) THEN

                hr_utility.set_location(l_package||':person_id='||app_term.person_id,120);
                hr_utility.trace('Race code is null.so setting the value to 0');
                hr_utility.trace('For person '||to_char(app_term.person_id));

                --
                -- The following statements are added by BUG3491606
                --
                open c_race_code(app_term.person_id
                                ,p_period_start
                                ,p_period_end);
                fetch c_race_code into l_race_code, l_person_type;
                if c_race_code%FOUND then
                  close c_race_code;
                  hr_utility.set_location(l_package||':person_id='||app_term.person_id,130);
                  hr_utility.trace('l_race_code   = ' || l_race_code);
                  hr_utility.trace('l_person_type = ' || l_person_type);

                  minority(per.sex
                          ,l_race_code
                          ,minority_code
                          ,ethnic_group_code);
                else
                  close c_race_code;
                  hr_utility.set_location(l_package||':person_id='||app_term.person_id,140);
                  ethnic_group_code:= 0;
                  minority_code:=null;
                end if;


             ELSE

                hr_utility.set_location(l_package||':person_id='||app_term.person_id,150);
                hr_utility.trace('Race code is not null.so calling the pkg minority');
                hr_utility.trace('person_id        = '||app_term.person_id);
                hr_utility.trace('per.person_type  = '||per.person_type);
                hr_utility.trace('per_information1 = '||per.race_code);

                minority(per.sex,
                         per.race_code,
                         minority_code,
                         ethnic_group_code);
             END IF;

             hr_utility.set_location(l_package||':person_id='||app_term.person_id,160);
             hr_utility.trace('After calling minority before inserting');

             /* The location_id is compared with the entity_id of the establishment.
              It is also compared with the parent_hierarchy_node_id.If it is equal
              then the fein and location_name is passed.*/

              For i in 1..est_infm.count LOOP

                     IF est_infm(i).entity_id = est.entity_id THEN

                       hr_utility.trace('entity_id = '|| est.entity_id);

                       l_est_name:=est_infm(i).location_name;
                       l_est_fein:=est_infm(i).fein;
                       l_est_flag:=est_infm(i).est_flag;
                       l_est_id:=est_infm(i).entity_id;

                       EXIT ;
                     ELSIF est_infm(i).hierarchy_node_id=est.parent_hierarchy_node_id THEN

                        hr_utility.trace('location LOC = '|| est.entity_id);

                        l_est_name:=est_infm(i).location_name;
                        l_est_fein:=est_infm(i).fein;
                        l_est_flag:='N';
                        l_est_id:=est_infm(i).entity_id;
                        EXIT ;

                     END IF;

                 END LOOP;

                 hr_utility.set_location(l_package||':person_id='||app_term.person_id,170);
                 p_insert(
                          l_est_id,
                          p_seq_num,
                          est.entity_id,
                          l_est_name,
                          l_est_fein,
                          app_term.assignment_id,
                          app_term.person_id,
                          per.job_category,  -- app_term.job_category, BUG4434130
                          per.race_code,
                          per.person_type,
                          m_app_count,
                          f_app_count,
                          m_hire_count,
                          f_hire_count,
                          m_terminate_count,
                          f_terminate_count,
                          m_promotion_count,
                          f_promotion_count,
                          m_fte_count,
                          f_fte_count,
                          monetary_comp,
                          tenure_years,
                          tenure_months,
                          minority_code,
                          ethnic_group_code,
                          l_est_flag,
                          fte_flag);

                  -- Initialize local variables
                  m_app_count:=0;
                  f_app_count:=0;
                  m_hire_count:=0;
                  f_hire_count:=0;
                  m_terminate_count:=0;
                  f_terminate_count:=0;
                  m_promotion_count:=0;
                  f_promotion_count:=0;
                  m_fte_count:=0;
                  f_fte_count:=0;

                end loop;

                l_person_id:=app_term.person_id;

              END IF;
                          hr_utility.set_location(l_package||':person_id='||app_term.person_id,180);
                          hr_utility.trace('After fifth loop');
             end loop;
                          hr_utility.set_location(l_package,190);
                          hr_utility.trace('Afterfourth loop');
         end loop;
        hr_utility.trace('==============================end  app_fire_count==================================');

        hr_utility.set_location('Leaving.. ' || l_package,200);
 end  app_fire_count;


procedure find_persons(p_pactid in pay_assignment_actions.payroll_action_id%type
                      ,p_thread in number)

is

  /* This cursor picks up the legislative_paramters and the end date for the
     the given pactid . */

   CURSOR c_leg_param(l_pact_id pay_assignment_actions.payroll_action_id%type)
   IS
   SELECT ppa.legislative_parameters,ppa.start_date,ppa.effective_date
   FROM   pay_payroll_actions ppa
   WHERE  ppa.payroll_action_id =l_pact_id;

   /* This cursor picks up the defined balance_id for the new balance
      EO Regular Salary YTD */

   CURSOR c_defined_balance_id
   IS
   SELECT pdb.defined_balance_id
   FROM   pay_defined_balances   pdb,
          pay_balance_dimensions pbd,
          pay_balance_types      pbt
   WHERE pdb.balance_dimension_id = pbd.balance_dimension_id
   AND   pbd.database_item_suffix = '_ASG_YTD'
   AND   pbd.legislation_code = 'US'
   AND   pdb.balance_type_id = pbt.balance_type_id
   AND   pbt.balance_name = 'EO Regular Salary Year to Date'
   AND   pbt.legislation_code = 'US'
   AND   pdb.legislation_code = 'US';

   /* This cursor picks up all the establishments for a given hierarchy_version_id.
    If an establishment is specified then it picks up the infm for that est alone. */

   CURSOR c_est_id(l_version_id per_gen_hierarchy_nodes.hierarchy_version_id%type,
                l_entity_id  per_gen_hierarchy_nodes.entity_id%type)
   IS
   SELECT entity_id,hierarchy_node_id
   FROM   per_gen_hierarchy_nodes
   WHERE  node_type = 'EST'
   AND    entity_id =nvl(l_entity_id,entity_id)
   AND    hierarchy_version_id = l_version_id;

   /* This cursor picks up all the assignment actions that has been
    inserted in pay_assignment_Actions for a specific chunk and pactid.
    It also picks up the person_id stored in serial_number. */

   CURSOR c_fte_asgn(l_pactid pay_payroll_actions.payroll_action_id%type,
                   l_chunk pay_assignment_actions.chunk_number%type)
   IS
   SELECT assignment_action_id,
          assignment_id,
          serial_number,
          source_action_id location_id
   FROM   pay_assignment_actions
   WHERE  payroll_action_id = l_pactid
   AND    chunk_number = l_chunk;

   /* This cursor picks up the max of asact_id which has been locked in pay_action_interlocks.
    this was selected during action creation. */

   CURSOR c_max_asact_id(l_locking_asact_id pay_assignment_actions.assignment_action_id%type)
   IS
   SELECT locked_action_id
   FROM   pay_action_interlocks
   WHERE  locking_action_id = l_locking_asact_id;

   /* This cursor selects the person information like race, job_category only for employees
    and EMP_APL. */

   CURSOR c_person_infm( l_person_id per_assignments_f.person_id%type,
                      l_period_start date,
                      l_period_end date)

   IS

   SELECT  ppf.sex,
           ppf.person_id,
           ppt.system_person_type person_type,
           ppf.effective_start_Date eff_Start,
           ppf.effective_end_date eff_end,
           ppf.per_information1 race,
           ppf.person_type_id,pps.date_start service_start
   FROM    per_people_f ppf,
           per_person_types ppt,
           per_periods_of_service pps
   WHERE   ( (   ppt.system_person_type = 'EMP'
          /* BUG4434130
                 and ppf.effective_start_date
                            = (select max(ppf1.effective_start_date)
                               from per_people_f ppf1
                               where ppf1.person_type_id = ppf.person_type_id
                                  and ppf1.person_id = ppf.person_id
                                  and ppf1.effective_start_date<=l_period_end
                                  )
          */
                 and ppf.effective_start_Date <=l_period_end
                 and ppf.effective_end_date >= l_period_start
                 and pps.date_start = ppf.effective_start_date -- BUG4434130
              )
          OR
              (  ppt.system_person_type = 'EMP_APL'
                 and ppf.effective_start_date
                        = (select max(ppf2.effective_Start_date)
                           from per_people_f ppf2
                           where ppf2.person_id = ppf.person_id
                           and ppf2.person_type_id = ppf.person_type_id
                           and ppf2.effective_start_Date <=l_period_end
                           and ppf2.effective_end_date >= l_period_start
                          )
               )
         )
       and ppf.person_id =l_person_id
       and ppt.person_type_id = ppf.person_type_id
       and pps.person_id = ppf.person_id;

   CURSOR assignment_details(l_person_id per_people_f.person_id%TYPE,
                             l_location_id per_assignments_f.location_id%TYPE,
                             l_person_type per_person_types.system_person_type%TYPE,
                             l_period_start date,
                             l_period_end date)
   IS
   SELECT distinct paf.person_id,
          pj.job_information1 job,
          paf.assignment_type
         ,paf.assignment_id
         ,paf.effective_start_date
         ,paf.effective_end_date
   FROM  per_assignments_f paf,
         per_jobs pj,
         fnd_common_lookups fcl
   WHERE  paf.person_id =l_person_id
   AND    pj.job_id = paf.job_id
   AND    ( ( paf.assignment_type = 'A'
            and l_person_type = 'EMP_APL'
           )
       or (paf.assignment_type = 'E'
           and l_person_type = 'EMP'
          )
        )
   AND paf.effective_start_Date <= l_period_end
   AND paf.effective_end_Date >=   l_period_start
   AND paf.location_id = l_location_id
   AND pj.job_information1=fcl.lookup_code
   AND fcl.lookup_code <> '10'
   AND fcl.lookup_type = 'US_EEO1_JOB_CATEGORIES';


 l_est_entity_id number;
 l_hierarchy_version_id number;
 l_min_hours number;
 l_defined_balance_id number;
 l_leg_param pay_payroll_actions.legislative_parameters%type;
 l_period_end date;
 l_period_start date;
 l_est_count number;
 l_max_asact_id pay_assignment_Actions.assignment_action_id%type;
 l_location_id per_assignments_f.location_id%TYPE;
 l_person_id per_people_f.person_id%type;
 l_job varchar2(10);
 l_assignment_type varchar2(10);
 l_package varchar2(70);
 l_effective_start_date date; -- BUG3940867
 l_effective_end_date   date; -- BUG3940867
 l_assignment_id        number; -- 18-OCT-04
 l_asg_eff_start_date date; -- BUG3958260
 l_asg_eff_end_date   date; -- BUG3958260

begin
   --hr_utility.trace_on(null,'ORACLE');
   l_package := 'pay_eosurvey_pkg.find_persons';

   hr_utility.trace('===============================  find_persons==================================');

   hr_utility.set_location('Entering.. ' || l_package,10);
   hr_utility.trace('The p_pactid   = '||to_char(p_pactid));
   hr_utility.trace('The thread     = '||to_char(p_thread));

   hr_utility.trace('The parameters');
   hr_utility.trace('l_hierarchy_vsn_id = '||to_char(l_hierarchy_version_id));
   hr_utility.trace('l_est_entity_id = '||to_char(l_est_entity_id));
   hr_utility.trace('l_seq_num       = '||to_char(l_seq_num));

   OPEN c_leg_param(p_pactid);
   FETCH c_leg_param INTO l_leg_param,l_period_end,l_period_start;
   CLOSE c_leg_param;

   hr_utility.trace('l_period_start  = '||to_char(l_period_start));
   hr_utility.trace('l_period_end    = '||to_char(l_period_end));

   /* All the parameters are picked up from the legislative parameters.*/

   l_hierarchy_version_id := pay_eosy_ac_pkg.get_parameter
                                  ('HI_VER_ID',l_leg_param);
   l_est_entity_id := pay_eosy_ac_pkg.get_parameter
                                  ('EST_ID',l_leg_param);
   l_min_hours := pay_eosy_ac_pkg.get_parameter
                                  ('MIN_HRS',l_leg_param);
   l_seq_num:=pay_eosy_ac_pkg.get_parameter
                                  ('S_N',l_leg_param);

        /* The establishment information is calculated using
         a procedure gre_name and the values are stored in the table.*/


   l_est_count:=1;

   FOR est_id in c_est_id(l_hierarchy_version_id,l_est_entity_id)
      LOOP

              hr_utility.trace('Before calling gre');

              IF p_thread = 1 THEN

                 job_race_insert(est_id.entity_id,
                                 l_seq_num);
              END IF;

              gre_name(est_id.entity_id,
                       l_hierarchy_version_id,
                       p_fein,
                       p_location_name);

              hr_utility.trace('After calling gre');

              est_infm(l_est_count).entity_id:=est_id.entity_id;
              est_infm(l_est_count).hierarchy_node_id:=est_id.hierarchy_node_id;
              est_infm(l_est_count).fein:=p_fein;
              est_infm(l_est_count).location_name:=p_location_name;
              est_infm(l_est_count).est_flag:='Y';

              -- Bug# 5982927
	      update pay_us_rpt_totals
              set gre_name = p_fein,
                  location_name = p_location_name
              where session_id = est_id.entity_id
              and business_group_id = l_seq_num;

              commit;

              l_est_count :=l_est_count+1;

             hr_utility.trace('After inserting the values.entity_id = '|| est_id.entity_id);

   END LOOP;

           hr_utility.trace('After est_id loop before c_defined_balance_id loop');

   IF p_thread = 1 THEN

          /* This procedure is called to find out the applicants and the terminations.
           Just the version_id is passed from which the locations should be calculated
           within the procedure. */

           hr_utility.trace('before calling app_fire_count');

           app_fire_count(l_est_entity_id,
                          l_hierarchy_version_id,
                          l_period_start,
                          l_period_end,
                          l_seq_num);

           hr_utility.trace('after calling app_fire_count');

   END IF;

   OPEN c_defined_balance_id;
   FETCH c_defined_balance_id INTO l_defined_balance_id;
   CLOSE c_defined_balance_id;

   hr_utility.trace('l_defined_balance_id = '||to_char(l_defined_balance_id));
   hr_utility.trace('full time assignments are picked up');

    /* All the assignments are picked up and their corresponding
               person_id and location_id also. */

   hr_utility.set_location(l_package,20);
   --FOR fte_asgn in c_fte_asgn(p_pactid,p_thread)
   FOR fte_asgn in c_fte_asgn(p_pactid,p_thread)
    LOOP
       hr_utility.set_location(l_package,30);
       hr_utility.trace('fte_asgn.assignment_action_id = ' || fte_asgn.assignment_action_id);
       hr_utility.trace('fte_asgn.person_id            = '||fte_asgn.serial_number);
       hr_utility.trace('fte_asgn.assignment_id        = ' || fte_asgn.assignment_id);

       OPEN c_max_asact_id(fte_asgn.assignment_action_id);
       FETCH c_max_asact_id INTO l_max_asact_id;
       CLOSE c_max_asact_id;
       hr_utility.trace('l_max_asact_id  = ' || l_max_asact_id);

       FOR per in c_person_infm(fte_asgn.serial_number,l_period_start,l_period_end)
         LOOP
             /*This cursor picks up the person records for each person_type EMP and EMP_APL
             if exists.*/

            hr_utility.set_location(l_package,40);
            hr_utility.trace('per.person_type = '||per.person_type);
            hr_utility.trace('per.eff_start   = '||per.eff_start);
            hr_utility.trace('per.eff_end     = '||per.eff_end);

             /*This cursor gets the location and job information.*/
            --
            -- the following if statements are added by BUG3940867
            --
            if (per.eff_start < l_period_start) then
              l_effective_start_date := l_period_start;
            else
              l_effective_start_date := per.eff_start;
            end if;

            if (per.eff_end > l_period_end) then
              l_effective_end_date := l_period_end;
            else
              l_effective_end_date := per.eff_end;
            end if;
            OPEN assignment_details(fte_asgn.serial_number
                                   ,fte_asgn.location_id
                                   ,per.person_type
                                   ,l_effective_start_date -- l_period_start
                                   ,l_effective_end_date   -- l_period_end
                                   );
            FETCH assignment_details INTO l_person_id,l_job,l_assignment_type
                                         ,l_assignment_id   -- 18-OCT-04
                                         ,l_asg_eff_start_date
                                         ,l_asg_eff_end_date;

            hr_utility.trace('preson_id.l_job   = '||fte_asgn.serial_number|| '.' ||l_job);
            hr_utility.trace('l_assignment_type = '||l_assignment_type);
            hr_utility.trace('l_assignment_id   = '||l_assignment_id);
            hr_utility.trace('l_asg_eff_start_date= '||l_asg_eff_start_date);
            hr_utility.trace('l_asg_eff_end_date  = '||l_asg_eff_end_date);

            if (l_effective_start_date < l_asg_eff_start_date) then
               l_effective_start_date := l_asg_eff_start_date;
               hr_utility.set_location(l_package,45);
            end if;

            IF assignment_details%FOUND THEN


            /*This procedure calculates the tenure,new hire,fte and monetary infm.*/

              hr_utility.set_location(l_package,50);
              hire_or_fte(l_assignment_id,     --   fte_asgn.assignment_id, 18-OCT-04
                          fte_asgn.serial_number,
                          l_period_start,
                          l_period_end,
                          per.eff_start,
                          per.eff_end,
                          per.service_start,
                          l_assignment_type,
                          per.sex,
                          l_job,
                          per.race,
                          per.person_type,
                          fte_asgn.location_id,
                          l_hierarchy_version_id,
                          l_min_hours,
                          l_defined_balance_id,
                          l_max_asact_id,
                          l_seq_num
                         ,l_effective_start_date -- BUG3940867
                         ,l_effective_end_date   -- BUG3940867
                         );
            END IF;
            CLOSE assignment_details;

           END LOOP;
    END LOOP;
    hr_utility.trace('=============================== END find_persons==================================');
    hr_utility.set_location('Leaving.... ' || l_package,100);
END find_persons;


         PROCEDURE p_insert (
                          p_entity_id           in  number,
                          p_seq_num             in  number,
                          p_location_id         in  number,
                          p_location_name       in  varchar2,
                          fein                  in  varchar2 ,
                          p_assignment_id       in  number ,
                          p_person_id           in  number ,
                          p_job_category        in  varchar2,
                          p_race_code           in  varchar2  ,
                          p_person_type         in  varchar2,
                          p_m_app_count         in  number ,
                          p_f_app_count         in  number ,
                          p_m_hire_count        in  number ,
                          p_f_hire_count        in  number ,
                          p_m_terminate_count   in  number ,
                          p_f_terminate_count   in  number ,
                          p_m_promotion_count   in  number ,
                          p_f_promotion_count   in  number ,
                          p_m_fte_count         in  number ,
                          p_f_fte_count         in  number ,
                          p_monetary_comp       in  number ,
                          p_tenure_years        in  number ,
                          p_tenure_months       in  number ,
                          p_minority_code       in  varchar2,
                          p_ethnic_group_code   in  varchar2,
                          p_est_flag            in  varchar2,
                          p_fte_flag            in  varchar2)
        IS
        n number;
        l_ethnic_group_code number;

        BEGIN
                hr_utility.trace('=============================== p_insert==================================');
                hr_utility.trace('-------------------');
                hr_utility.trace('p_entity_id       = ' || to_char(p_entity_id));
                hr_utility.trace('business_group_id = ' || to_char(p_seq_num));
                hr_utility.trace('p_person_id       = ' || to_char(p_person_id));
                hr_utility.trace('p_assignment_id   = ' || to_char(p_assignment_id));
                hr_utility.trace('location_id       = ' || to_char(p_entity_id));
                hr_utility.trace('p_job_category    = ' || p_job_category);
                hr_utility.trace('p_m_hire_count    = ' || p_m_hire_count);
                hr_utility.trace('p_f_hire_count    = ' || p_f_hire_count);
                hr_utility.trace('p_m_app_count     = ' || p_m_app_count);
                hr_utility.trace('p_f_app_count     = ' || p_f_app_count);
                hr_utility.trace('p_m_terminate_cnt = ' || p_m_terminate_count);
                hr_utility.trace('p_f_terminate_cnt = ' || p_f_terminate_count);
                hr_utility.trace('p_m_promotion_cnt = ' || p_m_promotion_count);
                hr_utility.trace('p_f_promotion_cnt = ' || p_f_promotion_count);
                hr_utility.trace('p_m_fte_count     = ' || p_m_fte_count);
                hr_utility.trace('p_f_fte_count     = ' || p_f_fte_count);
                hr_utility.trace('p_minority_code   = ' || p_minority_code);
                hr_utility.trace('p_tenure_years    = ' || p_tenure_years);
                hr_utility.trace('p_tenure_months   = ' || p_tenure_months);
                hr_utility.trace('gre_name          = ' || fein);
                hr_utility.trace('p_ethnic_grp_code = ' || p_ethnic_group_code);

                /*Inserting the records twice if the person is in
                  either once of the following race:
                  Hispanic or Latino (White race only) Hispanic or Latino (all other races) */

                IF p_ethnic_group_code in ('7','8') THEN

                   n:=2;
                   l_ethnic_group_code := p_ethnic_group_code;

                ELSIF p_ethnic_group_code IS NULL THEN

                    l_ethnic_group_code:=null;
                    n:=0;

                ELSE

                    n:=1;
                    l_ethnic_group_code := p_ethnic_group_code;

                END IF;

                FOR i in 1 .. n LOOP

                    IF i = 2 then
                       l_ethnic_group_code:=6;
                    END If;

                       INSERT INTO pay_us_rpt_totals
                       ( session_id,
                         business_group_id,
                         location_id,
                         location_name,
                         gre_name,
                         tax_unit_id,
                         organization_id,
                         attribute1,
                         attribute2,
                         attribute3,
                         value1,
                         value2,
                         value3,
                         value4,
                         value5,
                         value6,
                         value7,
                         value8,
                         value9,
                         value10,
                         value11,
                         value12,
                         value13,
                         value14,
                         attribute4,
                         attribute5,
                         attribute6)

                         Values
                         (p_entity_id,
                          p_seq_num,
                          p_location_id         ,
                          substr(p_location_name,1,80)     ,
                          fein                 ,
                          p_assignment_id      ,
                          p_person_id          ,
                          p_job_category      ,
                          p_race_code           ,
                          p_person_type       ,
                          nvl(p_m_app_count,0)          ,
                          nvl(p_f_app_count,0)          ,
                          nvl(p_m_hire_count,0)         ,
                          nvl(p_f_hire_count,0)         ,
                          nvl(p_m_terminate_count,0)    ,
                          nvl(p_f_terminate_count,0)    ,
                          nvl(p_m_promotion_count,0)    ,
                          nvl(p_f_promotion_count,0)    ,
                          nvl(p_m_fte_count,0)          ,
                          nvl(p_f_fte_count,0)          ,
                          nvl(p_monetary_comp,0)        ,
                          p_tenure_years         ,
                          p_tenure_months        ,
                          p_minority_code       ,
                          l_ethnic_group_code   ,
                          p_est_flag,
                          p_fte_flag
                          );

                  END LOOP;
                  hr_utility.trace('After Inserting. Resetting the counts. ');
/* BUG3878442
                  m_app_count:=0;
                  f_app_count:=0;
                  m_hire_count:=0;
                  f_hire_count:=0;
                  m_terminate_count:=0;
                  f_terminate_count:=0;
                  m_promotion_count:=0;
                  f_promotion_count:=0;
                  m_fte_count:=0;
                  f_fte_count:=0;
*/
                  monetary_comp:=0;
                  tenure_years:=0;
                  tenure_months:=0;
                  minority_code:=0;
                  ethnic_group_code:=null;
                  l_est_id:=0;
                  l_est_flag:=null;
                  l_est_name:=null;
                  fte_flag :=null;
    hr_utility.trace('===============================  end p_insert==================================');
end p_insert;

    procedure hire_or_fte (p_assignment_id         in number,
                           p_person_id             in number,
                           p_period_start          in date,
                           p_period_end            in date,
                           p_eff_start_date        in date,
                           p_eff_end_date          in date,
                           p_per_actual_start_date in date,
                           p_assignment_type       in varchar2,
                           p_sex                   in varchar2,
                           p_job                   in varchar2,
                           p_race                  in varchar2,
                           p_person_type           in varchar2,
                           p_location_id           in number,
                           p_hierarchy_version_id  in number,
                           p_min_hours             in number,
                           p_defined_balance_id    in number,
                           p_max_asact_id          in number,
                           p_seq_num               in number
                          ,p_effective_start_date  in date    -- BUG3940867
                          ,p_effective_end_date    in date    -- BUG3940867
                          )
                          is

    /*This cursor selects the parent_hierarchy_node_id for the selected
    entity_id. */

    CURSOR c_loc_hierarchy_id (l_location_id per_gen_hierarchy_nodes.entity_id%type,
                               l_hierarchy_version_id per_gen_hierarchy_nodes.hierarchy_version_id%type)
    IS
    SELECT parent_hierarchy_node_id
    FROM   per_gen_hierarchy_nodes
    WHERE  entity_id = l_location_id
    AND    hierarchy_version_id = l_hierarchy_version_id;

    /*If the report is not run for the recently concluded calendar year
    then the asact_id should be calculated for the recently concluded
    calendar year which is selected here.*/

    CURSOR asact_id(c_assignment_id per_assignments_f.assignment_id%type,
                    c_period_end date)
    IS
    SELECT to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                             paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE paa.assignment_id = c_assignment_id
    AND   ppa.payroll_action_id = paa.payroll_action_id
    AND   ppa.effective_date <= c_period_end
    AND   ppa.action_type in ('R', 'Q', 'I');

    -- This cursor checks an employee will terminate in future date
    -- BUG3954458
    cursor c_check_future_termination(p_person_id  in number
                                     ,p_start_date in date
                                     ,p_end_date   in date)
    is
    select 1
    from per_people_f ppf
        ,per_periods_of_service pps
    where ppf.person_id = p_person_id
    and   ppf.effective_start_date < p_end_date
    and   ppf.effective_end_date > p_start_date
    and   pps.person_id = ppf.person_id
    and   pps.actual_termination_date between
          p_start_date and p_end_date
    and   ppf.effective_start_date =
              (select max(ppf2.effective_start_date)
              from  per_people_f ppf2
              where ppf2.person_id = ppf.person_id
              and   ppf2.effective_start_date < p_end_date
              and   ppf2.effective_end_date > p_start_date
          );

   CURSOR c_get_updated_racecode( l_person_id per_assignments_f.person_id%type,
                      l_period_start date,
                      l_period_end date)

   IS

   SELECT  ppt.system_person_type person_type,
           ppf.effective_start_Date eff_Start,
           ppf.effective_end_date eff_end,
           ppf.per_information1 race
   FROM    per_people_f ppf,
           per_person_types ppt,
           per_periods_of_service pps
   WHERE   ( (   ppt.system_person_type = 'EMP'
                 and ppf.effective_start_date
                               = (select max(effective_start_date)
                               from per_people_f
                             where person_type_id = ppf.person_type_id
                             and person_id = ppf.person_id
                             and effective_start_date<=l_period_end
                                    )
              )
          OR
              (        ppt.system_person_type = 'EMP_APL'
                       and ppf.effective_start_date = (select max(effective_Start_date)
                                                         from per_people_f
                                                         where person_id = ppf.person_id
                                                         and person_type_id = ppf.person_type_id
                                                         and effective_start_Date <=l_period_end
                                                         and effective_end_date >= l_period_start
                                                        )
               )
         )
       and ppf.person_id =l_person_id
       and ppt.person_type_id = ppf.person_type_id
       and pps.person_id = ppf.person_id;

    l_hours_worked    per_assignments_f.normal_hours%type;
    l_asact_id        pay_assignment_actions.assignment_action_id%type;
    l_year varchar2(4);
    calendar_period_start date;
    calendar_period_end   date;
    calendar_next_period_start date;
    p_cal_period_start date;
    l_parent_hierarchy_node_id per_gen_hierarchy_nodes.parent_hierarchy_node_id%type;
    cal_monetary_comp number:=0;
    l_package varchar2(70);
    l_exists  varchar2(1);
    l_race    varchar2(20);
    l_effective_start_date date;
    l_effective_end_date   date;
    l_person_type          varchar2(20);

    -- Defined local variables BUG3878442
    m_app_count number:=0;
    f_app_count number:=0;
    m_terminate_count number :=0;
    f_terminate_count number :=0;
    m_hire_count number :=0;
    f_hire_count number :=0;
    m_fte_count number :=0;
    f_fte_count number :=0;
    m_promotion_count number :=0;
    f_promotion_count number :=0;


    BEGIN

      l_package := 'pay_eosurvey.hire_or_fte';

      /*The year from the start date is calculated. */

hr_utility.trace('=============================hire_or_fte==================================');

      hr_utility.set_location('Entering... ' || l_package||':p_person_id = '||p_person_id,10);
      hr_utility.trace('p_assignment_id  = ' || p_assignment_id);
      hr_utility.trace('p_person_id      = ' || p_person_id);
      hr_utility.trace('p_period_start   = ' || p_period_start);
      hr_utility.trace('p_period_end     = ' || p_period_end);
      hr_utility.trace('p_eff_start_date = ' || p_eff_start_date);
      hr_utility.trace('p_eff_end_date   = ' || p_eff_end_date);
      hr_utility.trace('p_per_actl_strt_date= ' || p_per_actual_start_date);
      hr_utility.trace('p_assignment_type= ' || p_assignment_type);
      hr_utility.trace('p_sex            = ' || p_sex);
      hr_utility.trace('p_job            = ' || p_job);
      hr_utility.trace('p_race           = ' || p_race);
      hr_utility.trace('p_person_type    = ' || p_person_type);
      hr_utility.trace('p_location_id    = ' || p_location_id);
      hr_utility.trace('p_hirrchy_vsn_id = ' || p_hierarchy_version_id);
      hr_utility.trace('p_min_hours      = ' || p_min_hours);
      hr_utility.trace('p_defin_balace_id= ' || p_defined_balance_id);
      hr_utility.trace('p_max_asact_id   = ' || p_max_asact_id);
      hr_utility.trace('p_seq_num        = ' || p_seq_num);
      hr_utility.trace('p_effective_start_date= ' || p_effective_start_date);
      hr_utility.trace('p_effective_end_date  = ' || p_effective_end_date);

      hr_utility.set_location(l_package||':p_person_id = '||p_person_id,20);

      monetary_comp:=null;

      l_year:=to_char(p_period_start,'yyyy');

      hr_utility.trace('Calculated year = '||l_year);

      /*It is checked if the period beginning is January. */

      IF p_period_start <> to_date('01-01-'||l_year,'dd-mm-yyyy') THEN
         hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,30);

         /*If not then the period January 1 and December 31 of the most
         recently concluded year is calculated. */

         hr_utility.trace('Period begin is not January.');

         calendar_period_start:=to_date('01-01-'||l_year,'dd-mm-yyyy');
         calendar_period_end:=to_date('31-12-'||l_year,'dd-mm-yyyy');

         /*The next period beginning is also calcualted as this will
         used to check for the new employees joined after the
         beginning of this year. */

         l_year:=l_year+1;
         calendar_next_period_start:=to_date('01-01-'||l_year,'dd-mm-yyyy');

         hr_utility.trace('Calculated calendar_period_start =
                                                 '||to_char(calendar_period_start));
         hr_utility.trace('Calculated calendar_period_end =  '
                                                  ||to_char(calendar_period_end));
         hr_utility.trace('Calculated calendar_next_period_start = '
                                                  ||to_char(calendar_next_period_start));

     ELSE /*The starting period itself is 1st Jan. So setting the variables to null. */
         hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,40);

         hr_utility.trace('Period beginJanuary.So setting the calendar start and end null');

         calendar_period_start:=null;
         calendar_period_end:=null;

     END IF;

     hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,50);
    /*   check if the employee is an applicant. */
     hr_utility.trace('Begin hire_or_fte');

     if p_person_type = 'EMP_APL' and p_assignment_type = 'A' then
        hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,60);
        hr_utility.trace('Check for EMP_APL');
        male_female_count(p_sex,
                          m_app_count,
                          f_app_count);
     end if;

     /* Check if the employee is a hire hired between the report period dates. */

     if p_per_actual_start_date between p_period_start and p_period_end then
       hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,70);

       hr_utility.trace('Check for new hire');
       hr_utility.trace('p_sex = '||p_sex);

       male_female_count(p_sex,
                         m_hire_count,
                         f_hire_count);
     end if;

     hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,80);
     hr_utility.trace('p_eff_start_Date = '||to_char(p_eff_start_Date));
     hr_utility.trace('p_eff_end_date   = '||to_char(p_eff_end_date));
     hr_utility.trace('p_period_start   = '||to_char(p_period_start));
     hr_utility.trace('p_period_end     = '||to_char(p_period_end));
     hr_utility.trace('p_assignment_type= '||p_assignment_type);
     hr_utility.trace('p_person_type    = '||p_person_type);
     hr_utility.trace('p_per_actual_start_date = '||to_char(p_per_actual_start_date));

     /* The employee will be shown twice if he is an EMP_APL in a year.
                  Checking is made */


     if (p_eff_start_Date < p_period_start and
            p_eff_end_date   > p_period_end   and
            p_person_type = 'EMP_APL') or
            (p_person_type = 'EMP'
             and p_assignment_type = 'E' )  then

              hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,90);
              hr_utility.trace('Emp is a fte and non-terminated person.calculate tenure and salary');

              l_hours_worked:=  pay_us_employee_payslip_web.
                                        get_asgn_annual_hours(p_assignment_id,p_period_end);

              hr_utility.trace('hours worked = '||to_char(l_hours_worked));
              hr_utility.trace('p_min_hours  = '||to_char(p_min_hours));

              /*An employee is considered full time only if his working hours
                meet the companys hours specified in the report parameter. */

              if l_hours_worked >= p_min_hours
                 or l_hours_worked is NULL then   -- BUG3886008
                 hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,95);
                 -- If an employee will terminate in the report period,
                 -- the employee should NOT be report under full time employees
                 -- BUG3954458
                 open c_check_future_termination(p_person_id
                                                ,p_eff_start_date  -- p_period_start
                                                ,p_period_end);
                 fetch c_check_future_termination into l_exists;
                 if c_check_future_termination%NOTFOUND then
                   hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,97);
                   fte_flag:='Y';
                   hr_utility.trace('setting fte count');
                   male_female_count(p_sex,
                                     m_fte_count,
                                     f_fte_count);
                 end if;
                 close c_check_future_termination;

                 /* Calculate the tenure.
                    If the report is run for the recent concluded
                    year then the tenure is calculated as a differnce between the persons
                    start date and period_end_Date which will be 31-Dec-yy. */

                 /*If the report is run for the AAP year then
                   the tenure is calculated for the employees based on the recently concluded
                   year. This infm is stored in the local variables:
                   calendar_period_start, calendar_period_end */

                 /* For the new employees tenure is based on the report end period. */

                  IF calendar_period_start IS NOT NULL then

                      /*It means the period_Start date is not 01-Jan-yy */

                      /* new hires joined after the concluded calendar year. */

                      hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,99);
                      IF( p_per_actual_start_date > calendar_next_period_start) then
                            hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,100);

                            tenure_months:=round(mod(months_between(p_period_end,p_per_actual_start_date),12));

                            hr_utility.trace('tenure_months = '||to_char(tenure_months));


                           monetary_comp:= pay_balance_pkg.get_value(p_defined_balance_id,
                                                     p_max_asact_id);
                           hr_utility.trace('monetary_comp for new emp = '||to_char(monetary_comp));

                      ELSE    /*for the employees who have joined before 31-dec-yy
                              calculated calendar_period_end is used to calculate the tenure. */
                            hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,110);

                            OPEN asact_id(p_assignment_id,calendar_period_end);
                            FETCH asact_id INTO l_asact_id;
                            CLOSE asact_id;

                            monetary_comp:= pay_balance_pkg.get_value(p_defined_balance_id,
                                                     l_asact_id);

                            tenure_years:= trunc(months_between(calendar_period_end,p_per_actual_start_date)/12);
                            tenure_months:=round(mod(months_between(calendar_period_end,p_per_actual_start_date),12));

                            hr_utility.trace('tenure calculation for new emp');

                    END IF;

             ELSE    /* The dates are recently concluded year.
                      So the period_end_date is used to calculate the tenure. */

                       hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,120);

                        tenure_years:= trunc(months_between(p_period_end,p_per_actual_start_date)/12);
                        tenure_months:=round(mod(months_between(p_period_end,p_per_actual_start_date),12));

                     /*Asact id calculated in the action_Creation is used here to calcualte the comp. */

                       monetary_comp:= pay_balance_pkg.get_value(p_defined_balance_id,
                                                     p_max_asact_id);

            END IF;


            hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,130);
            hr_utility.trace('tenure_months = '||to_char(tenure_months));
            hr_utility.trace('tenure_years  = '||to_char(tenure_years));
            hr_utility.trace('monetary_comp = '||to_char(monetary_comp));


          /*If the employee is a new hire then his YTD is caculated as follows: */

            IF p_per_actual_start_date between p_period_start and p_period_end then

                   hr_utility.trace('salary calculation for new employees');
                   hr_utility.trace('p_per_actual_start_Date '||to_char(p_per_actual_start_Date));

                   cal_monetary_comp:=round(monetary_comp/(p_period_end-p_per_actual_start_Date)*365/1000,0);
                    hr_utility.trace('New employee comp is = '||to_char(cal_monetary_comp));
            ELSE
                   cal_monetary_comp:=round(monetary_comp/1000,0);

            END IF;



            monetary_comp:=cal_monetary_comp;

            IF tenure_months = 12 THEN

              hr_utility.trace('Tenure months is 12.So setting the month to 0.');

              tenure_years:=tenure_years+1;
              tenure_months:=0;

              hr_utility.trace('Recalculated tenure months = '||to_char(tenure_months));
              hr_utility.trace('Recalculated tenure years = '||to_char(tenure_years));

            END If;

            hr_utility.trace('monetary_comp = '||to_char(cal_monetary_comp));
            hr_utility.trace('After salary and tenure before calling Promotion');

            hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,135);
            promotion(p_assignment_id
                     ,p_sex
                     ,p_period_start
                     ,p_period_end
                     ,p_effective_start_date
                     ,p_effective_end_date
                     ,m_promotion_count
                     ,f_promotion_count);
            hr_utility.trace('After calling Promotion');

            OPEN c_loc_hierarchy_id(p_location_id,p_hierarchy_version_id) ;
            FETCH c_loc_hierarchy_id INTO l_parent_hierarchy_node_id;
            CLOSE c_loc_hierarchy_id ;
            hr_utility.trace('LOCATION_ID ='||p_location_id);
            hr_utility.trace('l_parent_hierarchy_node_id = '||l_parent_hierarchy_node_id);

            For i in 1..est_infm.count LOOP
                    IF (est_infm(i).entity_id = p_location_id) THEN
                       hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,140);
                       hr_utility.trace('This entity is an establishment.');
                       hr_utility.trace('ENTITY_ID ='||to_char(p_location_id));
                       l_est_id:=est_infm(i).entity_id;
                       l_est_name:=est_infm(i).location_name;
                       l_est_fein:=est_infm(i).fein;
                       l_est_flag:='Y';
                       hr_utility.trace('So setting the flag to Y.l_est_flag = '
                                          ||l_est_flag);
                       EXIT ;
                    ELSIF est_infm(i).hierarchy_node_id=l_parent_hierarchy_node_id THEN
                        hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,150);

                        hr_utility.trace('This entity is an LOCATION');
                        hr_utility.trace('LOCATION LOC ='||to_char(p_location_id));

                        l_est_id:=est_infm(i).entity_id;
                        l_est_name:=est_infm(i).location_name;
                        l_est_fein:=est_infm(i).fein;
                        l_est_flag:='N';
                        hr_utility.trace('So setting the flag to N.l_est_flag = '
                                          ||l_est_flag);
                     EXIT ;
                     END IF;
            END LOOP;

            hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,160);
            open c_get_updated_racecode(p_person_id     -- BUG3941606
                                       ,p_period_start
                                       ,p_period_end
                                       );
            fetch c_get_updated_racecode into l_person_type
                                             ,l_effective_start_date
                                             ,l_effective_end_date
                                             ,l_race;

            if c_get_updated_racecode%NOTFOUND then
               hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,165);
               l_race := p_race;
            end if;
            close c_get_updated_racecode;
            hr_utility.trace('l_race = ' || l_race);

            minority(p_sex,
                     l_race,    -- p_race,  18-OCT-04
                     minority_code,
                     ethnic_group_code);

            hr_utility.trace('hire_or_fte. before calling p_insert procedure');

            hr_utility.set_location(l_package||':p_assignment_id = '||p_assignment_id,170);

            p_insert(
                     l_est_id,
                     p_seq_num,
                     p_location_id,
                     l_est_name,
                     l_est_fein,
                     p_assignment_id,
                     p_person_id,
                     p_job,
                     p_race,
                     p_person_type,
                     m_app_count,
                     f_app_count,
                     m_hire_count,
                     f_hire_count,
                     m_terminate_count,
                     f_terminate_count,
                     m_promotion_count,
                     f_promotion_count,
                     m_fte_count,
                     f_fte_count,
                     monetary_comp,
                     tenure_years,
                     tenure_months,
                     minority_code,
                     ethnic_group_code,
                     l_est_flag,
                     fte_flag);

            -- Initialize local variables BUG3878442
            m_app_count:=0;
            f_app_count:=0;
            m_hire_count:=0;
            f_hire_count:=0;
            m_terminate_count:=0;
            f_terminate_count:=0;
            m_promotion_count:=0;
            f_promotion_count:=0;
            m_fte_count:=0;
            f_fte_count:=0;

        end if;    /* hours checking if */

     END IF; /* EMP,EMP_APL checking */

     hr_utility.trace('=============================End hire_or_fte==================================');

     hr_utility.set_location('Leaving.. ' ||l_package||':p_assignment_id = '||p_assignment_id,200);
 end hire_or_fte;


   procedure gre_name(
                      p_entity_id     in  number,
                      p_version_id    in  number,
                      p_fein          out nocopy varchar2,
                      p_location_name out nocopy varchar2)
   is

   /*This cursor finds the fein which is stored in lei_information6
   and reporting name which is stored in lei_information1.
   If the reporting name is not found for the establishment then
   Reporting name not specified is printed. */


   cursor fein_est (c_entity_id per_gen_hierarchy_nodes.entity_id%type)
   is
   select hlei.lei_information6 fein
   from  hr_location_extra_info hlei
   where hlei.location_id = c_entity_id
   and   hlei.information_type = 'Establishment Information';

   cursor est_rpt_name(c_entity_id per_gen_hierarchy_nodes.entity_id%type)
   is
   SELECT lei_information1 rpt_name
   from  hr_location_extra_info
   where location_id = c_entity_id
   and   information_type = 'EEO-1 Specific Information';



   /*This cursor finds the fein infm of the parent. */

   cursor fein_par(c_version_id per_gen_hierarchy_nodes.hierarchy_version_id%type)
   is
   select hoi.org_information3 fein
   from   hr_organization_information hoi,
       per_gen_hierarchy_nodes pghn
   where  hoi.organization_id = pghn.entity_id
   and    pghn.node_type = 'PAR'
   and    pghn.hierarchy_version_id = c_version_id
   and    hoi.org_information_context = 'VETS_EEO_Dup';


   cursor est_name_address (c_entity_id per_gen_hierarchy_nodes.entity_id%type)
   is
   select rtrim(address_line_1)||' '||
       rtrim(address_line_2)||' '||
       rtrim(address_line_3)||' '||
      town_or_city||','||
      country||'-'||
      postal_code
   from hr_locations
   where location_id = c_entity_id;

     l_address        varchar2(1000);
     l_est_gre        hr_location_extra_info.lei_information1%type;
     l_est_name       hr_location_extra_info.lei_information1%type;
     l_par_gre        hr_organization_information.org_information3%type;

begin
         hr_utility.trace('=============================== gre_name==================================');
         OPEN fein_est(p_entity_id);
         FETCH fein_est INTO l_est_gre;

         hr_utility.trace('est fein = '||l_est_gre);

         /*If the fein is not found for establishment level
         it is taken from the parent. */

         IF l_est_gre IS NULL OR fein_est%NOTFOUND THEN

            CLOSE fein_est;
            OPEN fein_par(p_version_id);
            FETCH fein_par INTO l_par_gre;

            hr_utility.trace('Est gre not found.Fetching parent GRE');

            IF l_par_gre IS NULL OR fein_par%NOTFOUND THEN

               CLOSE fein_par;
               p_fein:='GRE information not found in both the establishment and parent level';
               hr_utility.trace('Est and parent  gre not found.');

            ELSE

              CLOSE fein_par;
              p_fein:=l_par_gre;
              hr_utility.trace('parent gre found. l_par_gre:='||l_par_gre);

            END IF;

         ELSE

           hr_utility.trace('Est gre found.l_est_gre:='||l_est_gre);
           p_fein:=l_est_gre;
           CLOSE fein_est;

         END IF;

         OPEN est_rpt_name(p_entity_id);
         fetch est_rpt_name into l_est_name;

         IF l_est_name is null or est_rpt_name%NOTFOUND THEN

            hr_utility.trace('Reporting name not specified');
            p_location_name:='Reporting name not specified';

            CLOSE est_rpt_name;
         ELSE

           CLOSE est_rpt_name;

           open est_name_address(p_entity_id);
           fetch est_name_address into l_address;
           close est_name_address;

           p_location_name:=l_est_name||' '||l_address;

           hr_utility.trace('Reporting name specified. '||l_est_name);

        END IF;


       hr_utility.trace('location name = '||p_location_name);
       hr_utility.trace('p_fein = '||p_fein);
       hr_utility.trace('===============================END gre_name==================================');
 end gre_name;


       procedure minority(p_sex                in varchar2,
                          p_race_code          in varchar2,
                          minority_code        out nocopy number,
                          ethnic_group_code    out nocopy varchar2)
      is


      cursor ethnic_race(c_race_code varchar2)
      is
      select decode(lookup_code,'6','American Indian or Alaskan Native',
                          '4','Asian',
                          '5','Native Hawaiian or Other Pacific Islander',
                          '2','Black or African American',
                          '8','Black or African American',
                          '1','White',
                          '9','Hispanic or Latino (White race only)',
                          '3','Hispanic or Latino (all other races)',
                          '10','Hispanic or Latino (all other races)',null)
      from fnd_common_lookups
      where lookup_code = c_race_code
      and lookup_type = 'US_ETHNIC_GROUP';

      l_ethnic_category fnd_common_lookups.meaning%type;


      begin
          hr_utility.trace('=============================== minority==================================');
          open ethnic_race(p_race_code);
          fetch ethnic_race into l_ethnic_category;
          close ethnic_race;

          if l_ethnic_category = 'White'  or
             l_ethnic_category = 'Caucasian' then

               if p_sex = 'M' then
                  minority_code := 4;
               elsif p_sex = 'F' then
                  minority_code := 2;
               end if;

          elsif l_ethnic_category is not null then

               if p_sex = 'M' then
                  minority_code := 3;
               elsif p_sex = 'F' then
                  minority_code := 1;
               end if;

          end if;
     hr_utility.trace('l_ethnic_category = '||l_ethnic_category);

    select decode(l_ethnic_category,'American Indian or Alaskan Native','1',
                                    'Asian','2',
                                    'Native Hawaiian or Other Pacific Islander','3',
                                    'Black or African American','4',
                                    'White','5',
                                    'Hispanic or Latino (White race only)','7',
                                    'Hispanic or Latino (all other races)','8',
                                    null,'0')
                                into ethnic_group_code
                                from dual ;
       hr_utility.trace('ethnic_group_code = '||ethnic_group_code);
        hr_utility.trace('===============================END minority==================================');
    end minority;


    procedure promotion(p_assignment_id             in  number,
                      p_sex                         in  varchar2,
                      p_period_start                in  date,
                      p_period_end                  in  date,
                      p_eff_start_date              in  date,  --BUG
                      p_eff_end_date                in  date,  --BUG
                      m_promotion_count             out nocopy number,
                      f_promotion_count             out nocopy number) is

/*-----------------------------------
    cursor promotion_check(l_assignment_id per_assignments_f.assignment_id%type) is
    select 'Y'
    from per_assignment_extra_info
    where aei_information_category = 'Promotion'
    and   to_date(aei_information1,'dd-mm-yyyy') between
          p_period_start and p_period_end
    and   assignment_id = l_assignment_id;


      begin
            hr_utility.trace('=============================== promotion==================================');
           open promotion_check(p_assignment_id);
           If promotion_check%FOUND then
              male_female_count(p_sex,
                                m_promotion_count,
                                f_promotion_count);
            else
               hr_utility.trace('No promotion');
           end if;
            hr_utility.trace('===============================END promotion==================================');


----------*/
      --
      --  Replaced promotion prcedure to call fastformula BUG#3730282
      --
    cursor csr_get_person_info is
           select  business_group_id
                  ,person_id
                  ,effective_start_date   -- BUG3963090
                  ,effective_end_date     -- BUG3963090
           from per_all_assignments_f
           where assignment_id = p_assignment_id
           and effective_start_date <= p_eff_end_date
           and effective_end_date >= p_eff_start_date;



    l_count       number;
    l_total_count number;   -- BUG3963090
    l_period_start date;
    l_period_end   date;

   begin

    hr_utility.trace('=============== promotion =================');
    hr_utility.trace('p_assignment_id   = ' || p_assignment_id);
    hr_utility.trace('p_period_start    = ' || p_period_start);
    hr_utility.trace('p_period_end      = ' || p_period_end);
    hr_utility.trace('p_eff_start_date  = ' || p_eff_start_date);
    hr_utility.trace('p_eff_end_date    = ' || p_eff_end_date);

    l_total_count := 0;

    --
    -- Added 'for loop' to pick up multiple promotions by BUG3963090
    --
    for prom_asgn in csr_get_person_info loop
      hr_utility.trace('business_group_id  = ' || prom_asgn.business_group_id);
      hr_utility.trace('person_id          = ' || prom_asgn.person_id);
      hr_utility.trace('effective_start_dat= ' || prom_asgn.effective_start_date);
      hr_utility.trace('effective_end_date = ' || prom_asgn.effective_end_date);
      if prom_asgn.effective_start_date < p_period_start then
         l_period_start := p_period_start;
      else
         l_period_start := prom_asgn.effective_start_date;
      end if;
      if prom_asgn.effective_end_date > p_period_end then
         l_period_end := p_period_end;
      else
         l_period_end := prom_asgn.effective_end_date;
      end if;

      hr_utility.trace('l_period_start    = ' || l_period_start);
      hr_utility.trace('l_period_end      = ' || l_period_end);

      hr_utility.trace('============ call per_fastformula_event ===========');
      l_count := per_fastformula_events_utility.per_fastformula_event
                        (  'PROMOTION'
                          ,'Promotion'
                          ,prom_asgn.business_group_id -- l_business_group_id
                          ,prom_asgn.person_id          -- l_person_id
                          ,l_period_start
                          ,l_period_end
                         );

      hr_utility.trace('========== return from per_fastformula_event =======');
      hr_utility.trace('l_count            = ' || l_count);
      l_total_count := l_total_count + l_count;
      hr_utility.trace('l_total_count      = ' || l_total_count);
    end loop;

    if p_sex = 'M' then
       m_promotion_count := l_total_count;
       hr_utility.trace('m_promotion_cout  = ' || m_promotion_count);
    elsif p_sex = 'F' then
       f_promotion_count := l_total_count;
       hr_utility.trace('f_promotion_cout  = ' || f_promotion_count);
    end if;

    hr_utility.trace('================ End promotion =================');
  end promotion;

    procedure male_female_count(p_sex     in varchar2,
                                p_male_count   out nocopy number,
                                p_female_count out nocopy number)
    is

    begin
          hr_utility.trace('=============================== male_female_count==================================');
          IF p_sex = 'M' THEN
             p_male_count:=1;
          ELSIF p_sex = 'F' THEN
             p_female_count:=1;
          END IF;
          hr_utility.trace('p_male_count = '||to_char(p_male_count));
          hr_utility.trace('p_female_count = '||to_char(p_female_count));
           hr_utility.trace('===============================END male_female_count==================================');

    end male_female_count;

     procedure job_race_insert(p_entity_id in number,
                               p_seq_num   in number)
     is


     CURSOR eeo1_job_code
     IS
     SELECT lookup_code
     FROM   fnd_common_lookups
     WHERE  lookup_type = 'US_EEO1_JOB_CATEGORIES'
     AND    lookup_code <> '10';


     BEGIN

         hr_utility.trace('=============================== job_race_insert==================================');
        FOR job_code in eeo1_job_code LOOP
            FOR i in 0 .. 8 LOOP
                INSERT INTO pay_us_rpt_totals
                           (session_id,
                            business_group_id,
                            attribute1,
                            attribute4,
                            attribute6)
                         Values
                            (p_entity_id,
                             p_seq_num,
                             job_code.lookup_code,
                             i,
                             'Y');
               hr_utility.trace('job_code = '||job_code.lookup_code);
               hr_utility.trace('ethnic code = '||to_char(i));
            END LOOP;
      END LOOP;

      FOR i in 1 ..4 LOOP
           FOR job_code in eeo1_job_code LOOP
               INSERT INTO pay_us_rpt_totals
                           (session_id,
                            business_group_id,
                            attribute1,
                            value14,
                            attribute6)
                       Values
                            (p_entity_id,
                             p_seq_num,
                             job_code.lookup_code,
                             i,
                             'Y');
             END LOOP;
      END LOOP;
          hr_utility.trace('===============================END job_race_insert==================================');

    END job_race_insert;

end pay_eosurvey_pkg;

/
