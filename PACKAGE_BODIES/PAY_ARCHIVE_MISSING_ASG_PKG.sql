--------------------------------------------------------
--  DDL for Package Body PAY_ARCHIVE_MISSING_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ARCHIVE_MISSING_ASG_PKG" as
/* $Header: payusyem.pkb 120.0 2005/10/17 18:18:28 djoshi noship $ */
/*
   Copyright (c) Oracle Corporation 2005. All rights reserved
--
   Name        : PAY_ARCHIVE_MISSING_ASG_PKG
   Description : This package contains the logic for Multi-threading of the
                 Year End Archive Missing Assignments Report
--
   Change List
   -----------
   Date         Name        Vers   Bug       Description
   -----------  ----------  -----  --------  ----------------------------------
   10-AUG-2005  rsethupa    115.0            Created
   05-sep-2005  rsethupa    115.1            Delete records from PAY_US_RPT_TOTALS
                                             in DEINIT code
   13-Sep-2005  sdhole      115.3  4577187   Changed the report type from YEMA to
                                             YREND_YEMA.
   16-Sep-2005  sdhole      115.4  4613898   Modified ARCHIVE_INIT,ARCHIVE_DEINIT,
                                             ARCHIVE_INIT,ARCHIVE_CODE procedures.
   23-sep-2005  djoshi      115.5  462035    Modified the Package.
                                             1. Archive Init commented
                                             2. Archive_code modified
*/
----------------------------------- range_cursor ----------------------------------
--

procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

--
lv_legislative_param varchar2(240);
begin


   hr_utility.trace('Reached range_cursor');
   hr_utility.trace('PACTID = '||to_char(pactid));

   select legislative_parameters
   into lv_legislative_param
   from pay_payroll_actions
   where payroll_action_id = pactid;

   sqlstr := 'SELECT distinct ASG.person_id
      FROM per_all_assignments_f ASG,
           pay_us_asg_reporting PUAR,
           pay_payroll_actions PPA
     WHERE PPA.payroll_action_id = :payroll_action_id
       AND PUAR.tax_unit_id = pay_us_payroll_utils.get_parameter(
                             ''TRANSFER_GRE'',
                             legislative_parameters)
       AND PUAR.assignment_id = ASG.assignment_id
       AND ASG.assignment_type = ''E''
       AND ASG.effective_start_date <= PPA.effective_date
       AND ASG.effective_end_date >= PPA.start_date
       AND ASG.business_group_id + 0 = PPA.business_group_id
       AND ASG.payroll_id is not null
     ORDER BY ASG.person_id';

   hr_utility.trace(sqlstr);

   exception when others then
      hr_utility.trace('Error in range_cursor - '||to_char(sqlcode) || '-' || sqlerrm);

end range_cursor;

---------------------------------- action_creation ----------------------------------
--
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

   CURSOR c_actions
   (
    cp_year_start DATE
   ,cp_year_end DATE
   ,cp_tax_unit_id NUMBER
   ,cp_start_person_id NUMBER
   ,cp_end_person_id NUMBER
   ) is

   SELECT distinct paf.assignment_id asg_id,
                   paa.assignment_action_id assact
     FROM per_all_assignments_f  paf,
          pay_assignment_actions paa,
          pay_payroll_actions ppa,
          pay_payrolls_f ppf,
          pay_us_asg_reporting puar
    WHERE paf.assignment_id = paa.assignment_id
      AND paf.assignment_id = puar.assignment_id
      AND puar.tax_unit_id = cp_tax_unit_id
      AND paf.assignment_type = 'E'
      AND paf.effective_start_date <= add_months(ppa.effective_date, 12) - 1
      AND paf.effective_end_date   >= ppa.effective_date
      AND ppa.payroll_action_id = paa.payroll_action_id
      AND ppa.action_type in ('R','B','Q','V','I')
      AND ppa.business_group_id = paf.business_group_id
      AND ppa.effective_date between cp_year_start
          AND cp_year_end
      AND ppa.payroll_id = ppf.payroll_id
      AND ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
      AND ppf.payroll_id >= 0
      AND paa.tax_unit_id =  cp_tax_unit_id
      AND paf.person_id between cp_start_person_id and cp_end_person_id
      AND not exists (SELECT 1
                        FROM pay_payroll_actions ppa,
                             pay_assignment_actions paa
                       WHERE ppa.report_type = 'YREND'
                         AND ppa.action_status = 'C'
                         AND ppa.effective_date = cp_year_end
                         AND to_number(substr(legislative_parameters,
                                       instr(legislative_parameters,'TRANSFER_GRE=')+
                                       length('TRANSFER_GRE='))) = cp_tax_unit_id
                         AND ppa.payroll_action_id = paa.payroll_action_id
                         AND paa.action_status = 'C'
                         AND ppa.business_group_id = paf.business_group_id
                         AND paa.serial_number = to_char(paf.person_id))
   ORDER BY paf.assignment_id;


   CURSOR c_actions_range_person
   (
    cp_year_start DATE
   ,cp_year_end DATE
   ,cp_tax_unit_id NUMBER
   ,cp_start_person_id NUMBER
   ,cp_end_person_id NUMBER
   ) is

   SELECT distinct paf.assignment_id asg_id,
                   paa.assignment_action_id assact
     FROM per_all_assignments_f  paf,
          pay_assignment_actions paa,
          pay_payroll_actions ppa,
          pay_payrolls_f ppf,
          pay_us_asg_reporting puar,
          pay_population_ranges ppr
    WHERE paf.assignment_id = paa.assignment_id
      AND paf.assignment_id = puar.assignment_id
      AND puar.tax_unit_id = cp_tax_unit_id
      AND paf.assignment_type = 'E'
      AND paf.person_id = ppr.person_id
      AND ppr.chunk_number = chunk
      AND ppr.payroll_action_id = pactid
      AND paf.effective_start_date <= add_months(ppa.effective_date, 12) - 1
      AND paf.effective_end_date   >= ppa.effective_date
      AND ppa.payroll_action_id = paa.payroll_action_id
      AND ppa.action_type in ('R','B','Q','V','I')
      AND ppa.business_group_id = paf.business_group_id
      AND ppa.effective_date between cp_year_start
          AND cp_year_end
      AND ppa.payroll_id = ppf.payroll_id
      AND ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
      AND ppf.payroll_id >= 0
      AND paa.tax_unit_id =  cp_tax_unit_id
      AND paf.person_id between cp_start_person_id and cp_end_person_id
      AND not exists (SELECT 1
                        FROM pay_payroll_actions ppa,
                             pay_assignment_actions paa
                       WHERE ppa.report_type = 'YREND'
                         AND ppa.action_status = 'C'
                         AND ppa.effective_date = cp_year_end
                         AND to_number(substr(legislative_parameters,
                                       instr(legislative_parameters,'TRANSFER_GRE=')+
                                       length('TRANSFER_GRE='))) = cp_tax_unit_id
                         AND ppa.payroll_action_id = paa.payroll_action_id
                         AND paa.action_status = 'C'
                         AND ppa.business_group_id = paf.business_group_id
                         AND paa.serial_number = to_char(paf.person_id))
   ORDER BY paf.assignment_id;

--
   l_effective_date DATE;
   lockingactid NUMBER;
   lockedactid NUMBER;
   l_year_start DATE;
   l_year_end DATE;
   lv_range_person_on BOOLEAN;
   l_eoy_tax_unit_id NUMBER;
   assignid NUMBER;
   l_action NUMBER;
   l_step number;

   begin
      hr_utility.trace('Entering action_creation');

      l_step := 1;
      select effective_date,
             pay_us_payroll_utils.get_parameter(
                                                'TRANSFER_GRE',
                                                legislative_parameters)
        into g_effective_date,
             g_tax_unit_id
        from pay_payroll_actions
       where payroll_action_id = pactid;

      l_year_start := trunc(g_effective_date, 'Y');
      l_year_end := add_months(trunc(g_effective_date, 'Y'),12) -1;
      hr_utility.trace('year start '|| to_char(l_year_start,'dd-mm-yyyy'));
      hr_utility.trace('year end '|| to_char(l_year_end,'dd-mm-yyyy'));

      lv_range_person_on := pay_ac_utility.range_person_on(
                               p_report_type      => 'YREND_YEMA'
                              ,p_report_format    => 'YEMA_ARCH'
                              ,p_report_qualifier => 'FED'
                              ,p_report_category  => 'RT');

      l_step := 2;
      IF lv_range_person_on THEN
         hr_utility.trace ('Person ranges are ON');
         OPEN c_actions_range_person(l_year_start,
                                     l_year_end,
                                     g_tax_unit_id,
                                     stperson,
                                     endperson);
      ELSE
         hr_utility.trace ('Person ranges are OFF');
         OPEN c_actions(
                     l_year_start,
                     l_year_end,
                     g_tax_unit_id,
                     stperson,
                     endperson
                    );
      END IF;

      l_step := 3;
      loop
         IF lv_range_person_on THEN
            FETCH c_actions_range_person INTO assignid,lockedactid;
            EXIT WHEN c_actions_range_person%NOTFOUND;
         ELSE
            FETCH c_actions INTO assignid,lockedactid;
            EXIT WHEn c_actions%NOTFOUND;
            hr_utility.trace('assignid = ' || assignid);
            hr_utility.trace('lockedactid = ' || lockedactid);
         END IF;

         select pay_assignment_actions_s.nextval
           into lockingactid
           from dual;

         l_step := 4;
         -- insert the action record.
         hr_nonrun_asact.insact(lockingactid =>lockingactid,
         object_id   =>assignid,
         pactid      =>pactid,
         chunk       =>chunk,
         greid       =>g_tax_unit_id);

         hr_utility.trace('inserted into temp object actions - ' || lockingactid);

      end loop;

      if lv_range_person_on then
         close c_actions_range_person;
      else
         close c_actions;
      end if;

      hr_utility.trace('leaving action_creation');
      exception
      when others then
         raise_application_error(-20001,'Error in action_creation in Step ' || l_step);
end action_creation;


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

l_param varchar2(240);
l_business_group_id number;
l_start_date date;
l_end_date date;
l_leg_code varchar2(2);
l_count number;
l_bal_attribute_name varchar2(100);
l_step number;

begin
--
   hr_utility.trace('entering archive_init');
--
   g_payroll_action_id := p_payroll_action_id;
--
/*   l_count := 0;
   l_step := 1;
--
   select ppa.legislative_parameters,
          ppa.business_group_id,
          ppa.start_date,
          ppa.effective_date
     into l_param,
          l_business_group_id,
          l_start_date,
          l_end_date
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = p_payroll_action_id;

   l_step := 2;
   open c_get_leg_code(l_business_group_id);
   fetch c_get_leg_code into l_leg_code;
   close c_get_leg_code;

   l_step := 3;
   open c_get_bal_attributes(l_leg_code);
   loop
   fetch c_get_bal_attributes into l_bal_attribute_name;
      exit when c_get_bal_attributes%NOTFOUND;

      ltr_def_bal_status(l_count).attribute := l_bal_attribute_name;
      open c_get_bal_attribute_id(ltr_def_bal_status(l_count).attribute);
      fetch c_get_bal_attribute_id into ltr_def_bal_status(l_count).attribute_id;
      close c_get_bal_attribute_id;

      l_step := 4;
      g_run_balance_status := pay_us_payroll_utils.check_balance_status
                                         (l_start_date,
                                          l_business_group_id,
                                          l_bal_attribute_name,
                                          l_leg_code);

      hr_utility.trace('g_run_balance_status = '||g_run_balance_status);

      l_count := l_count + 1;

   end loop;
   close c_get_bal_attributes;
   l_step := 5;

   hr_utility.trace('leaving archive_init');

   exception when no_data_found then
      raise_application_error(-20001,'In Archive_Init No Data Found In Step '|| l_step);
*/

end ARCHIVE_INIT;


---------------------------------- archive_code ----------------------------------

Procedure ARCHIVE_CODE (p_assignment_action_id IN NUMBER,
                        p_effective_date in date
                       ) IS

   CURSOR c_non_zero_run_balance(cp_assignment_id number,
                                 cp_effective_date DATE,
                                 cp_tax_unit_id number,
                                 cp_bal_attribute_id number
                                ) IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS(
                 select 1
                 from pay_run_balances prb,
                      pay_balance_attributes pba,
                      pay_assignment_actions paa
                      where paa.assignment_id = cp_assignment_id
                      AND paa.tax_unit_id = cp_tax_unit_id
                      AND paa.tax_unit_id = prb.tax_unit_id
                      AND paa.assignment_Action_id = prb.assignment_Action_id
                      AND prb.effective_date between add_months(cp_effective_date,-12)+1
                               and cp_effective_date
                      and prb.defined_balance_id = pba.defined_balance_id
                      and pba.attribute_id = cp_bal_attribute_id );

   CURSOR c_non_zero_run_result(cp_assignment_id  number,
                                cp_effective_date date,
                                cp_tax_unit_id    number) is
   SELECT 1 FROM dual
   WHERE EXISTS (SELECT 1
                   FROM pay_run_results prr,
                        pay_run_result_values prrv,
                        pay_input_values_f piv,
                        pay_assignment_actions paa,
                        pay_payroll_actions ppa,
                        pay_payrolls_f ppf
                  WHERE paa.assignment_id = cp_assignment_id
                    AND paa.tax_unit_id = cp_tax_unit_id
                    AND prr.assignment_Action_id = paa.assignment_Action_id
                    AND ppa.payroll_action_id = paa.payroll_action_id
                    AND ppa.action_type in ('R','B','Q','V','I')
                    AND ppa.effective_date between cp_effective_date
                                        AND add_months(cp_effective_date, 12) - 1
                    AND ppa.payroll_id = ppf.payroll_id
                    AND ppa.effective_date between ppf.effective_start_date
                        AND ppf.effective_end_date
                    AND ppf.payroll_id > 0
                    AND prrv.run_result_id = prr.run_result_id
                    AND prrv.result_value <> '0'
                    AND piv.input_value_id = prrv.input_value_id
                    AND ppa.effective_date between piv.effective_Start_date
                                               AND piv.effective_end_date
                    AND piv.uom = 'M'
                    and exists (select '1'
                                  from pay_balance_feeds_f pbf
                                 where piv.input_value_id = pbf.input_value_id
                                   and ppa.effective_date between pbf.effective_Start_date
                                                            AND pbf.effective_end_date
                               )
                );


CURSOR c_get_session_id IS
SELECT userenv('sessionid')
  FROM dual;

lv_result_value number:=0;
lv_count number;
l_asgid pay_assignment_actions.assignment_id%TYPE;
l_chunk number;
l_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
lv_session_id number;
l_step number;

begin

   hr_utility.trace('entering archive_code');

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
   hr_utility.trace('lv_session_id = '|| lv_session_id);
   close c_get_session_id;
      g_run_balance_status := 'N';

   if g_run_balance_status = 'Y' then
      for lv_count in ltr_def_bal_status.first..ltr_def_bal_status.last loop
         if lv_result_value = 0 then

            l_step := 2;
            open c_non_zero_run_balance(l_asgid,
                                        trunc(g_effective_date,'Y'),
                                        g_tax_unit_id,
                                        ltr_def_bal_status(lv_count).attribute_id);

            fetch c_non_zero_run_balance into lv_result_value;
            if c_non_zero_run_balance%NOTFOUND then
               l_step := 3;
               null;
            end if;
            close c_non_zero_run_balance;
         end if;
      end loop;
   else -- Run Balance Status is 'N'
      hr_utility.trace('opened c_non_zero_run_result');
      hr_utility.trace('l_asgid = '|| l_asgid);
      hr_utility.trace('g_effective_date = '||trunc(g_effective_date,'Y'));
      hr_utility.trace('g_tax_unit_id = '||g_tax_unit_id);

      l_step := 4;
      OPEN  c_non_zero_run_result(l_asgid,
                                  trunc(g_effective_date,'Y'),
                                  g_tax_unit_id);
      FETCH c_non_zero_run_result into lv_result_value;
      hr_utility.trace('lv_result_value = '||lv_result_value);
      CLOSE c_non_zero_run_result;

   end if;

      l_step := 5;
      if lv_result_value = 1 then
--
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
                               g_tax_unit_id,
                               l_asgid,
                               'YEAR END MISSING ASSIGNMENTS',
			        l_payroll_action_id);
--




         hr_utility.trace('assignment_id = ' || l_asgid);
      end if;

   hr_utility.trace('leaving archive_code');

   exception
   when others then
         raise_application_error(-20001,'Error in archive_code in Step ' || l_step);

   end ARCHIVE_CODE;


---------------------------------- archive_deinit ----------------------------------

Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER) IS

begin
--
    select effective_date,
           pay_us_payroll_utils.get_parameter('TRANSFER_GRE',
                                              legislative_parameters)
    into   g_effective_date,
           g_tax_unit_id
    from pay_payroll_actions
    where payroll_action_id = p_payroll_action_id;
--
   hr_utility.trace('entering archive_deinit');
--
   pay_us_yepp_miss_assign_pkg.select_employee(p_payroll_action_id,
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
--hr_utility.trace_on(null,'YREND_YEMA');
end pay_archive_missing_asg_pkg;


/
