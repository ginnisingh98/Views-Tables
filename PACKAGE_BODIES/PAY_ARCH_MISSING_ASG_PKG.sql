--------------------------------------------------------
--  DDL for Package Body PAY_ARCH_MISSING_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ARCH_MISSING_ASG_PKG" AS
/* $Header: pymissarch.pkb 120.4.12010000.2 2010/01/06 08:58:29 aneghosh ship $ */

/******************************************************************************

   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disCLOSEd to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************
--
   Name        : PAY_ARCH_MISSING_ASG_PKG
   Description : This package contains the logic for Multi-threading of the
                 Year End Archive Missing Assignments Report
--
   Change List
   -----------
     Date         Name        Vers     Bug No    Description
     -----------  ----------  -------  -------   ------------------------------
     25-OCT-2005  rdhingra    115.0    4674183   Code transferred from
                                                 payusyem.pkb. US specific
                                                 calls removed
     15-NOV-2005  rdhingra    115.1    4737510   Correct g_effective_date sent
                                                 while opening cursors in
                                                 ARCHIVE_CODE.
                                                 Cursor c_non_zero_run_result
                                                 modified to check correct
                                                 effective date.
     30-NOV-2005  rdhingra    115.2    YEPhaseII Call to
                                                 pay_ac_utility.range_person_on
                                                 in action_creation made generic
     19-JAN-2007  ydevi       115.3    4886285   adding the condition for
                                                  RL1 and RL2 PRE in range_cursor
					          and action creation
					          Inside archive_code the cursor
						  c_non_zero_run_balance and
						  c_non_zero_run_result is handled
						  by ref cursor so that RL1 and
						  RL2 PRE can be handled
     06-JAN-2010 aneghosh     115.4    9240092    Added pay_payroll_actions in the
                                                  join condition in the select query
                                                  for c_non_zero_run_balance.

******************************************************************************/

g_package  varchar2(80) := 'pay_arch_missing_asg_pkg.';

----------------------------------- range_cursor ------------------------------
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

-- Get legislation code
CURSOR c_get_leg_code(cp_business_group_id NUMBER
                     ) IS
SELECT legislation_code
  FROM per_business_groups
 WHERE business_group_id = cp_business_group_id;
--
lv_legislative_param   VARCHAR2(240);
lv_legislation_code    VARCHAR2(2);
lv_rc_where            VARCHAR2(10000);
l_proc                 VARCHAR2(240);
ln_business_group_id   NUMBER;

begin

   l_proc := g_package||'range_cursor';
   hr_utility.set_location(l_proc, 10);
   hr_utility.trace('PACTID = '||to_char(pactid));

   select ppa.legislative_parameters,
          ppa.business_group_id
   into lv_legislative_param, ln_business_group_id
   from pay_payroll_actions ppa
   where payroll_action_id = pactid;

   hr_utility.set_location(l_proc, 20);

   open c_get_leg_code(ln_business_group_id);
   fetch c_get_leg_code into lv_legislation_code;
   close c_get_leg_code;

   hr_utility.set_location(l_proc, 30);

   BEGIN
        EXECUTE IMMEDIATE 'BEGIN PAY_'||lv_legislation_code||
                          '_ARCHIVE_RULES.RANGE_CURSOR(:a, :b); END;'
                USING IN pactid, OUT lv_rc_where;

        hr_utility.set_location(l_proc, 40);

        EXCEPTION WHEN others THEN
          hr_utility.set_location(l_proc, 50);
          NULL;
   END;

   hr_utility.set_location(l_proc, 60);

   sqlstr := 'SELECT distinct ASG.person_id
      FROM per_all_assignments_f ASG,
           pay_payroll_actions PPA
     WHERE PPA.payroll_action_id = :payroll_action_id
       AND ASG.business_group_id = PPA.business_group_id
       AND ASG.payroll_id is not null
       AND ASG.assignment_type = ''E''
       AND ASG.effective_start_date <= PPA.effective_date
       AND ASG.effective_end_date >= PPA.start_date
       AND EXISTS ( --CHECKING THAT ATLEAST ONE ASSIGN ACT EXIST
                    SELECT 1
                      FROM pay_assignment_actions paa
                     WHERE paa.assignment_id = ASG.assignment_id
		     AND PAA.action_status = ''C'''
                     ||lv_rc_where||
		  ')
     ORDER BY ASG.person_id';

   hr_utility.trace(sqlstr);

   exception when others then
      hr_utility.trace('Error in range_cursor - '||to_char(sqlcode) || '-' || sqlerrm);

end range_cursor;

---------------------------------- action_creation ----------------------------------
PROCEDURE action_creation(pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER) IS

   -- Get legislation code
   CURSOR c_get_leg_code(cp_business_group_id NUMBER
                        ) IS
   SELECT legislation_code
     FROM per_business_groups
    WHERE business_group_id = cp_business_group_id;

   -- Get report_format
   CURSOR c_get_report_format(cp_report_type      VARCHAR2,
                              cp_report_qualifier VARCHAR2,
                              cp_report_category  VARCHAR2,
                              cp_start_date       DATE,
                              cp_end_date         DATE
             ) IS
     SELECT report_format
       FROM pay_report_format_mappings_f
      WHERE report_type = cp_report_type
        AND report_qualifier = cp_report_qualifier
        AND report_category = cp_report_category
        AND cp_start_date BETWEEN effective_start_date AND effective_end_date
        AND cp_end_date BETWEEN effective_start_date AND effective_end_date;



--
   l_effective_date     DATE;
   l_year_start         DATE;
   l_year_end           DATE;
   lockingactid         NUMBER;
   lockedactid          NUMBER;
   l_eoy_tax_unit_id    NUMBER;
   assignid             NUMBER;
   l_action             NUMBER;
   l_step               NUMBER;
   l_proc               VARCHAR2(240);
   lv_ac_where          VARCHAR2(10000);
   lv_legislation_code  VARCHAR2(2);
   lv_report_type       VARCHAR2(30);
   lv_report_format     VARCHAR2(30);
   lv_report_qualifier  VARCHAR2(30);
   lv_report_category   VARCHAR2(30);
   lv_range_person_on   BOOLEAN;
   ln_business_group_id NUMBER;

   TYPE RefCurType IS REF CURSOR;
   c_actions                RefCurType;
   c_actions_sql            VARCHAR2(10000);

   BEGIN

      l_proc := g_package||'action_creation';
      hr_utility.set_location(l_proc, 10);

      l_step := 1;
      SELECT  effective_date
             ,pay_core_utils.get_parameter('TRANSFER_GRE',legislative_parameters)
             ,business_group_id
             ,report_type
             ,report_qualifier
             ,report_category
        INTO g_effective_date,
             g_tax_unit_id,
             ln_business_group_id,
             lv_report_type,
             lv_report_qualifier,
             lv_report_category
        FROM pay_payroll_actions
       WHERE payroll_action_id = pactid;


      hr_utility.trace('g_effective_date:'|| to_char(g_effective_date,'dd-mm-yyyy'));
      hr_utility.trace('g_tax_unit_id:'|| to_char(g_tax_unit_id));
      hr_utility.trace('business_group_id:'|| to_char(ln_business_group_id));
      hr_utility.trace('report_type:'|| lv_report_type);
      hr_utility.trace('report_qualifier:'|| lv_report_qualifier);
      hr_utility.trace('report_category:'|| lv_report_category);

      open c_get_leg_code(ln_business_group_id);
      fetch c_get_leg_code into lv_legislation_code;
      close c_get_leg_code;

      l_year_start := trunc(g_effective_date, 'Y');
      l_year_end := add_months(trunc(g_effective_date, 'Y'),12) -1;
      hr_utility.trace('year start '|| to_char(l_year_start,'dd-mm-yyyy'));
      hr_utility.trace('year end '|| to_char(l_year_end,'dd-mm-yyyy'));

      open c_get_report_format(lv_report_type, lv_report_qualifier,
                               lv_report_category, l_year_start, l_year_end);
      fetch c_get_report_format into lv_report_format;
      close c_get_report_format;
      hr_utility.trace('report_format:'|| lv_report_format);


      lv_range_person_on := pay_ac_utility.range_person_on(
                               p_report_type      => lv_report_type
                              ,p_report_format    => lv_report_format
                              ,p_report_qualifier => lv_report_qualifier
                              ,p_report_category  => lv_report_category
                              );

      l_step := 2;
      hr_utility.set_location(l_proc, 20);

      BEGIN
           EXECUTE IMMEDIATE 'BEGIN PAY_'|| lv_legislation_code ||
                             '_ARCHIVE_RULES.ACTION_CREATION(:a, :b, :c, :d, :e); END;'
                   USING IN pactid, IN stperson, IN endperson, IN chunk, OUT lv_ac_where;

           hr_utility.set_location(l_proc, 30);

           EXCEPTION WHEN others THEN
             hr_utility.set_location(l_proc, 40);
             NULL;
      END;
      l_step := 3;

      IF lv_range_person_on THEN
         hr_utility.trace ('Person ranges are ON');
	 hr_utility.trace('chunk ='|| chunk);
         hr_utility.trace('l_year_start ='|| l_year_start);
         hr_utility.trace('l_year_end ='|| l_year_end);
         hr_utility.trace('stperson ='|| stperson);
         hr_utility.trace('endperson ='|| endperson);
         c_actions_sql :=
           'SELECT distinct paf.assignment_id asg_id,
                   paa.assignment_action_id assact
              FROM per_all_assignments_f  paf,
                   pay_assignment_actions paa,
                   pay_payroll_actions ppa,
                   pay_payrolls_f ppf,
                   pay_population_ranges ppr
             WHERE paf.assignment_id = paa.assignment_id
               AND paf.assignment_type = ''E''
               AND paf.person_id = ppr.person_id
               AND ppr.chunk_number = '|| chunk ||'
               AND ppr.payroll_action_id = '|| pactid ||'
               AND paf.effective_start_date <= add_months(ppa.effective_date, 12) - 1
               AND paf.effective_end_date   >= ppa.effective_date
               AND ppa.payroll_action_id = paa.payroll_action_id
               AND ppa.action_type in (''R'',''B'',''Q'',''V'',''I'')
               AND ppa.business_group_id = paf.business_group_id
               AND ppa.effective_date between '''|| l_year_start ||''' AND '''|| l_year_end ||'''
               AND ppa.payroll_id = ppf.payroll_id
               AND ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
               AND ppf.payroll_id >= 0
               AND paf.person_id between '|| stperson ||' and '|| endperson ||'
               '|| lv_ac_where ||'
          ORDER BY paf.assignment_id';
      ELSE
         hr_utility.trace ('Person ranges are OFF');
         c_actions_sql :=
            'SELECT distinct paf.assignment_id asg_id,
                    paa.assignment_action_id assact
               FROM per_all_assignments_f  paf,
                    pay_assignment_actions paa,
                    pay_payroll_actions ppa,
                    pay_payrolls_f ppf
              WHERE paf.assignment_id = paa.assignment_id
                AND paf.assignment_type = ''E''
                AND paf.effective_start_date <= add_months(ppa.effective_date, 12) - 1
                AND paf.effective_end_date   >= ppa.effective_date
                AND ppa.payroll_action_id = paa.payroll_action_id
                AND ppa.action_type in (''R'',''B'',''Q'',''V'',''I'')
                AND ppa.business_group_id = paf.business_group_id
                AND ppa.effective_date between '''|| l_year_start ||'''
                    AND '''|| l_year_end ||'''
                AND ppa.payroll_id = ppf.payroll_id
                AND ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
                AND ppf.payroll_id >= 0
                AND paf.person_id between '|| stperson ||' and '|| endperson ||'
                '|| lv_ac_where ||'
             ORDER BY paf.assignment_id';
      END IF;
      --hr_utility.trace(c_actions_sql);
      hr_utility.trace('after execution');
      OPEN c_actions FOR c_actions_sql;
      l_step := 4;
      LOOP
         FETCH c_actions INTO assignid,lockedactid;
         EXIT WHEN c_actions%NOTFOUND;
         hr_utility.trace('assignid = ' || assignid);
         hr_utility.trace('lockedactid = ' || lockedactid);


         SELECT pay_assignment_actions_s.nextval
           INTO lockingactid
           FROM dual;

         l_step := 5;
         -- insert the action record.
         hr_nonrun_asact.insact  --no change
            (
             lockingactid =>lockingactid,
             object_id    =>assignid,
             pactid       =>pactid,
             chunk        =>chunk,
             greid        =>g_tax_unit_id  ---it should be passed as null for RL1 and RL2
            );
         hr_utility.trace('inserted into temp object actions - ' || lockingactid);
      END LOOP;
      CLOSE c_actions;

      hr_utility.trace('leaving action_creation');

      EXCEPTION
      WHEN OTHERS THEN
         raise_application_error(-20001,'Error in action_creation in Step ' || l_step);
END action_creation;


---------------------------------- archive_init ----------------------------------

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER) IS

CURSOR c_get_min_chunk is
SELECT min(paa.chunk_number)
FROM pay_assignment_actions paa
WHERE paa.payroll_action_id = p_payroll_action_id;

-- Get Balance Attributes
CURSOR c_get_bal_attributes(cp_leg_code VARCHAR2
                           ) IS
select distinct fcl.lookup_code
  from fnd_common_lookups fcl,
       fnd_lookup_values flv
 where fcl.lookup_type = 'YE_ARCH_REPORTS_BAL_ATTRIBUTES'
   and fcl.lookup_type = flv.lookup_type
   and flv.tag = '+'||cp_leg_code
   and fcl.lookup_code = flv.lookup_code;

-- Get legislation code
CURSOR c_get_leg_code(cp_business_group_id NUMBER
                     ) IS
SELECT legislation_code
  FROM per_business_groups
 WHERE business_group_id = cp_business_group_id;

-- Get Balance Attribute ID
CURSOR c_get_bal_attribute_id(cp_attribute_name varchar2) IS
SELECT attribute_id
  FROM pay_bal_attribute_definitions
 WHERE attribute_name = cp_attribute_name;

l_param               VARCHAR2(240);
l_proc                VARCHAR2(240);
l_bal_attribute_name  VARCHAR2(100);
l_leg_code            VARCHAR2(2);
l_start_date          DATE;
l_end_date            DATE;
l_business_group_id   NUMBER;
l_count               NUMBER;
l_step                NUMBER;


BEGIN

   l_proc := g_package||'archive_init';
   hr_utility.set_location(l_proc, 10);
--
   g_payroll_action_id := p_payroll_action_id;
--
   l_count := 0;
   l_step := 1;
--
   SELECT ppa.legislative_parameters,
          ppa.business_group_id,
          ppa.start_date,
          ppa.effective_date
     INTO l_param,
          l_business_group_id,
          l_start_date,
          l_end_date
     FROM pay_payroll_actions ppa
    WHERE ppa.payroll_action_id = p_payroll_action_id;

   l_step := 2;
   OPEN c_get_leg_code(l_business_group_id);
   FETCH c_get_leg_code INTO l_leg_code;
   CLOSE c_get_leg_code;

   l_step := 3;
   g_run_balance_status := 'N';
   OPEN c_get_bal_attributes(l_leg_code);
   LOOP
      FETCH c_get_bal_attributes INTO l_bal_attribute_name;
      EXIT WHEN c_get_bal_attributes%NOTFOUND;

      ltr_def_bal_status(l_count).attribute := l_bal_attribute_name;
      OPEN c_get_bal_attribute_id(ltr_def_bal_status(l_count).attribute);
      FETCH c_get_bal_attribute_id INTO ltr_def_bal_status(l_count).attribute_id;
      CLOSE c_get_bal_attribute_id;

      l_step := 4;
      g_run_balance_status := pay_us_payroll_utils.check_balance_status
                                         (l_start_date,
                                          l_business_group_id,
                                          l_bal_attribute_name,
                                          l_leg_code);

      hr_utility.trace('Checking Attribute = '|| l_bal_attribute_name);
      hr_utility.trace('g_run_balance_status = '|| g_run_balance_status);

      l_count := l_count + 1;

      IF (g_run_balance_status = 'N') THEN
         EXIT;
      END IF;

   END LOOP;
   CLOSE c_get_bal_attributes;
   l_step := 5;

   hr_utility.trace('Outside g_run_balance_status = '|| g_run_balance_status);
   hr_utility.trace('leaving archive_init');

   EXCEPTION WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001,'In Archive_Init No Data Found In Step '|| l_step);


END ARCHIVE_INIT;


---------------------------------- archive_code ----------------------------------

Procedure ARCHIVE_CODE (p_assignment_action_id IN NUMBER,
                        p_effective_date in date
                       ) IS

CURSOR c_get_session_id IS
SELECT userenv('sessionid')
  FROM dual;

-- Get legislation code
CURSOR c_get_leg_code(cp_business_group_id NUMBER
                     ) IS
SELECT legislation_code
  FROM per_business_groups
 WHERE business_group_id = cp_business_group_id;

lv_result_value number:=0;
lv_count number;
l_asgid pay_assignment_actions.assignment_id%TYPE;
l_chunk number;
l_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
lv_session_id number;
l_step number;
l_proc   VARCHAR2(240);
lv_ac_where          VARCHAR2(10000);
ln_business_group_id   NUMBER;
lv_legislation_code   VARCHAR2(2);

TYPE RefCurType IS REF CURSOR;
c_run_bal_or_result    RefCurType;
c_non_zero_run_balance VARCHAR2(10000);
c_non_zero_run_result  VARCHAR2(10000);

begin

   l_proc := g_package||'archive_code';
   hr_utility.set_location(l_proc, 10);

   l_step := 1;

   SELECT aa.object_id,
          aa.chunk_number,
          aa.payroll_action_id
     into l_asgid,
          l_chunk,
          l_payroll_action_id
     FROM pay_temp_object_actions aa
    WHERE aa.object_action_id = p_assignment_action_id;

   hr_utility.trace('l_asgid = ' || l_asgid);
   hr_utility.trace('l_chunk = ' || l_chunk);
   hr_utility.trace('l_payroll_action_id = ' || l_payroll_action_id);
   hr_utility.trace('g_run_balance_status = ' || g_run_balance_status);

   open c_get_session_id;
   fetch c_get_session_id into g_session_id;
   hr_utility.trace('g_session_id = '|| g_session_id);
   close c_get_session_id;

   select ppa.business_group_id
   into ln_business_group_id
   from pay_payroll_actions ppa
   where payroll_action_id = l_payroll_action_id;

   hr_utility.set_location(l_proc, 20);

   open c_get_leg_code(ln_business_group_id);
   fetch c_get_leg_code into lv_legislation_code;
   close c_get_leg_code;

   hr_utility.set_location(l_proc, 30);

   BEGIN
        EXECUTE IMMEDIATE 'BEGIN PAY_'|| lv_legislation_code ||
                             '_ARCHIVE_RULES.archive_code(:a, :b); END;'
                   USING IN l_payroll_action_id, OUT lv_ac_where;

           hr_utility.set_location(l_proc, 30);

           EXCEPTION WHEN others THEN
             hr_utility.set_location(l_proc, 40);
             NULL;
   END;

   hr_utility.trace('l_asgid = '|| l_asgid);
   hr_utility.trace('g_effective_date = '||g_effective_date);
   hr_utility.trace('g_tax_unit_id = '||g_tax_unit_id);
   if g_run_balance_status = 'Y' then --As of this version all balances should be valid
      for lv_count in ltr_def_bal_status.first..ltr_def_bal_status.last loop
         hr_utility.trace('lv_result_value_1:'||to_char(lv_result_value));
	 hr_utility.trace('attribute_id = '||ltr_def_bal_status(lv_count).attribute_id);
         if lv_result_value = 0 then
            l_step := 2;
	    hr_utility.trace('opened c_non_zero_run_balance');
	    --hr_utility.trace(ltr_def_bal_status(lv_count).attribute_id);
            c_non_zero_run_balance := 'SELECT 1
                              FROM DUAL
                              WHERE EXISTS(
                                select 1
                                from pay_run_balances prb,
                                     pay_balance_attributes pba,
                                     pay_assignment_actions paa,
                                     pay_payroll_actions ppa
                                where paa.assignment_id = '||to_char(l_asgid)||'
                                AND paa.payroll_action_id = ppa.payroll_action_id
                                AND paa.assignment_Action_id = prb.assignment_Action_id
                                AND prb.effective_date between '''||to_char(add_months(g_effective_date,-12)+1)||
                                ''' and '''||to_char(g_effective_date)||'''
                                and prb.defined_balance_id = pba.defined_balance_id
                                and pba.attribute_id = '||to_char(ltr_def_bal_status(lv_count).attribute_id) ||
                                lv_ac_where||')';
		hr_utility.trace('c_non_zero_run_balance='||c_non_zero_run_balance);
		hr_utility.trace('hmmm');
	       open c_run_bal_or_result for c_non_zero_run_balance;
	       hr_utility.trace('hmmm');
               fetch c_run_bal_or_result into lv_result_value;
               hr_utility.trace('lv_result_value_2:'||to_char(lv_result_value));
               if c_run_bal_or_result%NOTFOUND then
                 l_step := 3;
                 lv_result_value := 0;
                 hr_utility.trace('lv_result_value_3:'||to_char(lv_result_value));
               end if;
              close c_run_bal_or_result;
         end if;
      end loop;
   else -- Run Balance Status is 'N'
      hr_utility.trace('opened c_non_zero_run_result');

      l_step := 4;
       c_non_zero_run_result := 'SELECT 1 FROM dual
                             WHERE EXISTS (SELECT 1
                             FROM pay_run_results prr,
                                  pay_run_result_values prrv,
                                  pay_input_values_f piv,
                                  pay_assignment_actions paa,
                                  pay_payroll_actions ppa,
                                  pay_payrolls_f ppf
                             WHERE paa.assignment_id = '||to_char(l_asgid)||'
                             AND prr.assignment_Action_id = paa.assignment_Action_id
                             AND ppa.payroll_action_id = paa.payroll_action_id
                             AND ppa.action_type in (''R'',''B'',''Q'',''V'',''I'')
                             AND ppa.effective_date between '''||to_char(add_months(g_effective_date, -12) + 1)||
                                        '''AND'''|| to_char(g_effective_date)||'''
                             AND ppa.payroll_id = ppf.payroll_id
                             AND ppa.effective_date between ppf.effective_start_date
                                 AND ppf.effective_end_date
                             AND ppf.payroll_id > 0
                             AND prrv.run_result_id = prr.run_result_id
                             AND prrv.result_value <> ''0''
                             AND piv.input_value_id = prrv.input_value_id
                             AND ppa.effective_date between piv.effective_Start_date
                                                        AND piv.effective_end_date
                             AND piv.uom = ''M''
                             and exists (select 1
                                           from pay_balance_feeds_f pbf
                                          where piv.input_value_id = pbf.input_value_id
                                            and ppa.effective_date between pbf.effective_Start_date
                                                                     AND pbf.effective_end_date
                               )'|| lv_ac_where||'
                           )';

      open c_run_bal_or_result for c_non_zero_run_result;
      FETCH c_run_bal_or_result into lv_result_value;
      hr_utility.trace('lv_result_value_4 = '||lv_result_value);
      CLOSE c_run_bal_or_result;

   end if;

      hr_utility.trace('lv_result_value_5:'||to_char(lv_result_value));

      l_step := 5;
      if lv_result_value = 1 then
--
       hr_utility.trace('lv_result_value_6:'||to_char(lv_result_value));
       insert
        into pay_us_rpt_totals(
                               session_id,
                               tax_unit_id,
                               value1,
                               attribute1,
                               location_id
                              )
         values
                              (
                               g_session_id,
                               nvl(g_tax_unit_id,0),
                               l_asgid,  --assignment action id passed by PYUGEN
                               'YEAR END MISSING ASSIGNMENTS',
			        l_payroll_action_id);
--




         hr_utility.trace('assignment_id = ' || l_asgid);
      end if;

   hr_utility.trace('leaving archive_code');

   exception
   when others then
         hr_utility.trace(sqlcode||':'||sqlerrm);
         raise_application_error(-20001,'Error in archive_code in Step ' || l_step);

   end ARCHIVE_CODE;


---------------------------------- archive_deinit ----------------------------------

Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER) IS

l_proc   VARCHAR2(240);

begin

   l_proc := g_package||'archive_deinit';
   hr_utility.set_location(l_proc, 10);

--
    select effective_date,
           pay_core_utils.get_parameter('TRANSFER_GRE',
                                        legislative_parameters)
    into   g_effective_date,
           g_tax_unit_id
    from pay_payroll_actions
    where payroll_action_id = p_payroll_action_id;
--
   hr_utility.trace('g_effective_date ='||g_effective_date);
      hr_utility.trace('g_tax_unit_id ='||g_tax_unit_id);
   pay_yepp_miss_assign_pkg.select_employee(p_payroll_action_id,
                                            g_effective_date,
                                            g_tax_unit_id,
                                            g_session_id);
--
pay_archive.remove_report_actions(p_payroll_action_id);
--
  DELETE FROM pay_us_rpt_totals
   WHERE  attribute1='YEAR END MISSING ASSIGNMENTS'
   AND    location_id = p_payroll_action_id;
--
   hr_utility.trace('leaving archive_deinit');

end ARCHIVE_DEINIT;

--begin
--hr_utility.trace_on(null,'MIS');
END pay_arch_missing_asg_pkg;


/
