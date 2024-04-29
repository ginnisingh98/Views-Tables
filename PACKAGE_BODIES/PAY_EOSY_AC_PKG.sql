--------------------------------------------------------
--  DDL for Package Body PAY_EOSY_AC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EOSY_AC_PKG" AS
/* $Header: pyuseoac.pkb 120.0.12000000.2 2007/07/16 17:31:14 rpasumar noship $ */
/*
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
   *  ma    for EO Survey report.
   26-Apr-2001  fusman      115.0

   Name:    This package defines the cursors needed to run
            EO Survey  Multi-Threaded

   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   25-Apr-01    fusman      115.0   Created.
   28-JUN-04    vbanner     115.1   Changed to pass GSCC.
   30-SEP-04    ynegoro     115.2   Changed c_actions cursor and range_cursor
                                    by BUG3886008
   01-OCT-04    ynegoro     115.3   Changed c_actions cursor
   04-OCT-04    ynegoro     115.4   Changed c_actions cursor to pick up
                                    terminated employee
   25-OCT-04    ynegoro     115.5   Changed c_actions cursor in action_creation
                                    BUG3941460 and BUG3964366
   29-OCT-04    ynegoro             Changed range_cursor and c_actions
                                    cursor BUG3958260
   04-NOV-04    ynegoro     115.6   Deleted previous change for BUG3958260
                                    3958260 is not a bug.
   16-JUL-07      rpasumar     115.7  To report a person whose ethnic origin is blank.
*/

 --------------------------- range_cursor ---------------------------------
 PROCEDURE range_cursor (pactid in number,
                         sqlstr out nocopy varchar2) is
   l_payroll_id number;
   leg_param    pay_payroll_actions.legislative_parameters%type;
   l_package    varchar2(70);

Begin

   l_package := 'pay_eosy_ac_pkg.range_cursor';
   --hr_utility.trace_on(null,'fusman');
   hr_utility.set_location('Entering.. ' || l_package,10);

   sqlstr:=
         'select  distinct paf.person_id
          from       pay_payroll_actions ppa, -- pyugen
                     per_gen_hierarchy_nodes pghn,
                     per_assignments_f paf,
                     per_assignment_status_types past,
                     per_jobs pj,
                     fnd_common_lookups fcl
          where ppa.payroll_action_id = :pactid
          AND pghn.hierarchy_version_id = pay_eosy_ac_pkg.get_parameter
                                                  (''HI_VER_ID'',ppa.legislative_parameters)
          AND (
                (
                  entity_id = nvl(pay_eosy_ac_pkg.get_parameter
                                                  (''EST_ID'',ppa.legislative_parameters),pghn.entity_id)
                  AND node_type =''EST''
                )
        OR
          (
             parent_hierarchy_node_id in(SELECT hierarchy_node_id
                                         FROM per_gen_hierarchy_nodes
                                         WHERE hierarchy_version_id =pay_eosy_ac_pkg.get_parameter
                                                                      (''HI_VER_ID'',ppa.legislative_parameters)
                                         AND   entity_id = nvl(pay_eosy_ac_pkg.get_parameter
                                                                      (''EST_ID'',ppa.legislative_parameters),entity_id)
                                         AND node_type = ''EST'')
            AND node_type = ''LOC''
         )
      )
          and paf.location_id = pghn.entity_id
          and paf.assignment_status_type_id = past.assignment_status_type_id
          and past.per_system_Status = ''ACTIVE_ASSIGN''
          and paf.effective_start_Date = (select max(effective_Start_date)
                                    from per_assignments_f paf1
                                    where paf1.assignment_id = paf.assignment_id
                                    and paf1.effective_start_Date <=ppa.start_Date
                                 -- and paf1.effective_end_date >=ppa.start_date
                                    and paf1.effective_end_date >=trunc(ppa.start_date,''Y'')   -- BUG3886008
                                    and paf1.assignment_status_type_id =
                                                        paf.assignment_Status_type_id
                                    and paf1.primary_flag = ''Y''
--                                    and paf1.location_id = paf.location_id -- BUG3958260
                                    )
            and paf.assignment_type = ''E''
            and paf.primary_flag=''Y''
            AND paf.job_id = pj.job_id
            AND pj.job_information1= fcl.lookup_code
            AND fcl.lookup_type = ''US_EEO1_JOB_CATEGORIES''
            /*AND exists
                  (SELECT ''x'' from per_people_f
                   WHERE  person_id = paf.person_id
                   AND    per_information1 is not null)*/
            order by paf.person_id';

   hr_utility.trace('pactid = ' || pactid);
   hr_utility.set_location('Leaving.. ' || l_package,20);
   --hr_utility.trace_off;
 END range_cursor;


 ----------------------------- action_creation --------------------------------
 PROCEDURE action_creation( pactid    in number,
                            stperson  in number,
                            endperson in number,
                            chunk     in number)
 IS

  cursor c_actions(pactid    number,
                   stperson  number,
                   endperson number,
                   l_start_date date,
                   l_end_date   date,
                   l_version_id number,
                   l_est_id     number ) is
  SELECT  paa.assignment_action_id,
          paf.assignment_id,
          paf.person_id,
          paa.tax_unit_id,
          paf.location_id
  FROM    pay_assignment_actions paa,
          pay_payroll_actions ppa,
          per_assignments_f paf,
          per_jobs pj,
          per_gen_hierarchy_nodes pghn,
       -- per_assignment_status_types past, -- BUG3886008
          fnd_common_lookups fcl
  WHERE   ppa.effective_date between  l_start_date and l_end_date

  AND     ppa.action_type in ('R','Q','I')
  AND     ppa.action_status = 'C'
  AND     paa.payroll_action_id = ppa.payroll_action_id
  AND     paa.action_status = 'C'
  AND     paa.action_sequence IN (
                 SELECT MAX(paa2.action_sequence)
                   FROM pay_action_classifications pac,
                        pay_payroll_actions ppa2,
                        pay_assignment_actions paa2,
                        per_assignments_f paf1
                  WHERE paf1.person_id = paf.person_id
                    AND paa2.assignment_id = paf1.assignment_id
                    AND paf1.primary_flag  = 'Y'             -- BUG3941460
                    AND paa2.tax_unit_id = paa.tax_unit_id
                    AND ppa2.payroll_action_id = paa2.payroll_action_id
                    AND ppa2.action_type = pac.action_type
                    AND pac.classification_name = 'SEQUENCED'
                    AND paa2.action_status = 'C'             -- BUG3886008
                    AND ppa2.effective_date <= l_end_Date    -- BUG3964366
                    --AND ppa2.effective_date between paf1.effective_start_date
                    --   and paf1.effective_end_date          -- BUG3958260
                    --AND paf1.location_id = paf.location_id   -- BUG3958260
                    )

  AND     paf.assignment_id = paa.assignment_id
  AND     paf.person_id between stperson and endperson
  AND     paf.location_id = pghn.entity_id
  ANd     pghn.hierarchy_version_id = l_version_id
  AND     (
           (
            pghn.entity_id = nvl(l_est_id,pghn.entity_id)
            AND pghn.node_type ='EST'
          )
        OR
          (
             pghn.parent_hierarchy_node_id
                           in(select pghn2.hierarchy_node_id
                                from per_gen_hierarchy_nodes pghn2
                               where pghn2.hierarchy_version_id =l_version_id
                               and   pghn2.entity_id = nvl(l_est_id,pghn2.entity_id)
                               and pghn2.node_type = 'EST')
            AND pghn.node_type = 'LOC'
         )
       )
--  AND     paf.assignment_status_type_id = past.assignment_status_type_id
--  AND     past.per_system_Status = 'ACTIVE_ASSIGN'   -- BUG3886008
  AND     paf.effective_start_Date = (select max(effective_Start_date)
                                    from per_assignments_f paf1
                                    where paf1.assignment_id = paf.assignment_id
                                    and paf1.effective_start_Date <=l_end_date
                                    and paf1.effective_end_date >= l_start_date
                                 --   and paf1.assignment_status_type_id =
                                 --                      paf.assignment_Status_type_id
                                    and paf1.primary_flag = 'Y'
                                    and paf1.location_id = paf.location_id --BUG3958260
                                    )
--  AND     ppa.effective_date between paf.effective_start_Date and paf.effective_end_Date   -- BUG3886008
  AND     paf.assignment_type = 'E'
  AND     paf.primary_flag='Y'
  AND     paf.job_id = pj.job_id
  AND     pj.job_information1= fcl.lookup_code
  AND     fcl.lookup_type = 'US_EEO1_JOB_CATEGORIES';
  /*AND exists
                  (SELECT 'x' from per_people_f ppf2
                   WHERE  ppf2.person_id = paf.person_id
                   AND    ppf2.per_information1 is not null)*/

  CURSOR c_report_parameters(pactid number)
  IS
  SELECT start_date,
         effective_date,
         pay_eosy_ac_pkg.get_parameter('HI_VER_ID',legislative_parameters),
         pay_eosy_ac_pkg.get_parameter('EST_ID',legislative_parameters)
  FROM   pay_payroll_actions
  WHERE  payroll_action_id=pactid;

    lockingactid  number;
    lockedactid   number;
    l_asgnid        number;
    l_person_id   number;
    l_gre_id      number;
    l_start_date date;
    l_end_date   date;
    l_est_id     number;
    l_version_id number;
    l_location_id number;
    l_package    varchar2(70);

    BEGIN

    --hr_utility.trace_on(null,'fusman');

    l_package := 'pay_eosy_ac_pkg.action_creation';
    hr_utility.set_location('Enerring.. '||l_package||':stperson:'||stperson,10);
    hr_utility.trace('pactid    = ' || pactid);
    hr_utility.trace('stperson  = ' || stperson);
    hr_utility.trace('endperson = ' || endperson);
    hr_utility.trace('chunk     = ' || chunk);

    OPEN c_report_parameters(pactid);
    FETCH c_report_parameters INTO l_end_date,l_start_date,l_version_id,l_est_id;
    CLOSE c_report_parameters;

    hr_utility.trace('l_start_date = ' || l_start_date);
    hr_utility.trace('l_end_date   = ' || l_end_date);
    hr_utility.trace('l_version_id = ' || l_version_id);
    hr_utility.trace('l_est_id     = ' || l_est_id);

    hr_utility.set_location(l_package||':stperson:'||stperson,20);
    OPEN c_actions(pactid,stperson,endperson,l_start_date,
                   l_end_date,l_version_id,l_est_id);
    LOOP
      FETCH c_actions INTO lockedactid
                          ,l_asgnid,l_person_id
                          ,l_gre_id,l_location_id;

      IF c_actions%notfound then
        hr_utility.trace('In the c_actions%notfound in action cursor');
        hr_utility.set_location(l_package||':stperson:'||stperson,30);
        EXIT;
      END IF;

      hr_utility.set_location(l_package||':stperson:'||stperson,40);
      --Get the assignment_action_id for creating one for each selected asact_id

      SELECT pay_assignment_actions_s.nextval
      INTO lockingactid
      FROM dual;


      -- insert the action record.
      hr_utility.set_location(l_package||':stperson:'||stperson,50);
      hr_utility.trace('asact_id    = '||to_char(lockedactid));
      hr_utility.trace('l_asgnid    = '||to_char(l_asgnid));
      hr_utility.trace('l_person_id = '||to_char(l_person_id));

      hr_nonrun_asact.insact(lockingactid,l_asgnid,pactid,chunk,l_gre_id);
      UPDATE pay_assignment_actions
      SET serial_number = l_person_id,
          source_action_id  = l_location_id
      WHERE assignment_action_id = lockingactid;

      hr_utility.set_location(l_package||':stperson:'||stperson,60);
      hr_utility.trace('After inserting into pay_assignment_actions, before pay_action_interlock');
     -- insert an interlock to this action.

      hr_nonrun_asact.insint(lockingactid,lockedactid);
      hr_utility.trace('loop ends');

    END LOOP;
    CLOSE c_actions;

    hr_utility.trace('END action_creation');
    hr_utility.set_location('Leaving..  '||l_package||':stperson:'||stperson,100);

    --hr_utility.trace_off;

    END action_creation;

     ---------------------------------- sort_action ----------------------------------
 PROCEDURE sort_action(
               payactid   in     varchar2, /* payroll action id */
               sqlstr     in out nocopy varchar2, /* string holding the sql statement */
               len        out nocopy    number    /* length of the sql string */
               ) is
  BEGIN
      sqlstr :=
            'select paa.rowid
             from   pay_assignment_actions paa /* PYUGEN assignment action */
             where paa.payroll_action_id = :payactid
             for update of paa.assignment_id';

          len := length(sqlstr); -- return the length of the string.

 END sort_action;


     ----------------------------- get_parameter -------------------------------
 FUNCTION get_parameter(name in varchar2,
                        parameter_list varchar2)
 RETURN VARCHAR2
 IS
   start_ptr number;
   end_ptr   number;
   token_val pay_payroll_actions.legislative_parameters%type;
   par_value pay_payroll_actions.legislative_parameters%type;
 BEGIN

     token_val := name || '=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list) + 1;
     end if;

     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;

     return par_value;

 END get_parameter;


  END pay_eosy_ac_pkg;

/
