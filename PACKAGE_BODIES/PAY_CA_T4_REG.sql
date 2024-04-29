--------------------------------------------------------
--  DDL for Package Body PAY_CA_T4_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_T4_REG" AS
/* $Header: pycat4rg.pkb 120.3.12010000.2 2008/11/14 13:01:56 sapalani ship $ */
function get_user_entity_id(p_user_name varchar2) return number is

begin

declare

  cursor cur_user_entity_id is
  select user_entity_id
  from   ff_database_items
  where  user_name = p_user_name;

  l_user_entity_id	ff_database_items.user_entity_id%TYPE;

begin

  open  cur_user_entity_id;

  fetch cur_user_entity_id
  into  l_user_entity_id;

  close cur_user_entity_id;

  return l_user_entity_id;

end;
end;

----------------------------------- range_cursor ----------------------------------

procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
  l_payroll_id number;
  leg_param    pay_payroll_actions.legislative_parameters%type;

  l_uid_caeoy_tax_year    number;
  l_uid_caeoy_tax_unit_id number;
  l_uid_caeoy_prov_of_emp number;
  l_uid_caeoy_person_id   number;
--
begin

   --hr_utility.trace_on('Y','ORACLE');
   hr_utility.trace('begining of range_cursor 1 ');

   select legislative_parameters
     into leg_param
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

   l_uid_caeoy_tax_year    := get_user_entity_id('CAEOY_TAXATION_YEAR');
   l_uid_caeoy_tax_unit_id := get_user_entity_id('CAEOY_TAX_UNIT_ID');
   l_uid_caeoy_prov_of_emp :=
                          get_user_entity_id('CAEOY_PROVINCE_OF_EMPLOYMENT');
   l_uid_caeoy_person_id   := get_user_entity_id('CAEOY_PERSON_ID');



/* pay reg code */

   sqlstr := 'select distinct to_number(fai4.value)
                from    ff_archive_items fai1,
                        ff_archive_items fai2,
                        ff_archive_items fai3,
                        ff_archive_items fai4,
			pay_payroll_actions     ppa,
                        pay_assignment_actions  paa
                 where  ppa.payroll_action_id    = :payroll_action_id
                 and    fai1.user_entity_id = ' || l_uid_caeoy_tax_year ||
                 ' and  fai1.value =
                 	     nvl(pay_ca_t4_reg.get_parameter(''TAX_YEAR'',
                             ppa.legislative_parameters),fai1.value)
                   and  fai1.context1 = paa.payroll_action_id
                   and  fai2.user_entity_id = ' || l_uid_caeoy_tax_unit_id ||
                 ' and  fai2.value          =
                             nvl(pay_ca_t4_reg.get_parameter(''GRE_ID'',
                             ppa.legislative_parameters),fai2.value)
                   and  fai2.context1 = paa.payroll_action_id
                   and  fai3.user_entity_id = ' || l_uid_caeoy_prov_of_emp ||
                 ' and  fai3.value          =
                        nvl(pay_ca_t4_reg.get_parameter(''PROV_CD'',
                                   ppa.legislative_parameters),fai3.value)
                   and  fai3.context1 = paa.assignment_action_id
                   and  fai4.user_entity_id = ' || l_uid_caeoy_person_id ||
                 ' and  fai4.context1 = paa.assignment_action_id
                   and  fai4.value  = nvl(pay_ca_t4_reg.get_parameter(''PER_ID'',
                                          ppa.legislative_parameters),fai4.value)
		   order by to_number(fai4.value)';

	hr_utility.trace('End of range_cursor 2 ');

end range_cursor;
---------------------------------- action_creation -------------------------
--
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is


--
  lockingactid  number;
  lockedactid   number;
  l_asg_set_id  number;
  l_asg_id      number;
  l_prov_cd     ff_archive_item_contexts.context%TYPE;
  l_province    ff_archive_item_contexts.context%TYPE;
  l_tax_unit_id number;
  l_year        varchar2(4);
  l_bus_group_id number;
  l_year_start   date;
  l_year_end     date;
  l_t4reg_tax_unit_id      number;
  l_effective_date         date;
  l_report_type            varchar2(80);
  l_legislative_parameters varchar2(500);
  lv_per_id                varchar2(30);

  lv_negative_bal_flag     varchar2(10);
  lv_neg_bal_mesg          varchar2(100);
  lv_person_type           varchar2(20);
  lv_message_level         varchar2(20);
  lv_message               varchar2(500);

  lv_sin                   varchar2(20);
  lv_employee_full_name    varchar2(300);
  lv_employee_last_name    varchar2(200);
  lv_employee_name         varchar2(200);

--
   l_uid_caeoy_tax_unit_id   ff_user_entities.user_entity_id%TYPE;
   l_uid_caeoy_tax_year	     ff_user_entities.user_entity_id%TYPE;
   l_arch_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE;
   l_uid_caeoy_gross_earning ff_user_entities.user_entity_id%TYPE;
   l_session_date	     pay_payroll_actions.effective_date%TYPE;

   cursor c_all_gres is
   SELECT
     pay_ca_t4_reg.get_parameter('TRANSFER_GRE', ppa.legislative_parameters),
     ppa.payroll_action_id,
     ppa.effective_date
   FROM
     pay_payroll_actions ppa
   WHERE
     ppa.report_type = 'T4' AND
     ppa.report_category = 'CAEOY' and
     ppa.report_qualifier = 'CAEOY' and
     ppa.business_group_id = l_bus_group_id and
     ppa.effective_date = l_year_end and
     ppa.action_status = 'C';

-- The following cursor will only be used when the tax_unit_id
-- (GRE name) is passed while submitting the SRS for T4 Paper
-- Report.

  CURSOR cur_arch_paid(p_tax_unit_id number) IS
  SELECT
    ppa.payroll_action_id,
    ppa.effective_date
  FROM
    pay_payroll_actions ppa
  WHERE
    ppa.report_type = 'T4' AND
    ppa.report_category = 'CAEOY' and
    ppa.report_qualifier = 'CAEOY' and
    ppa.business_group_id = l_bus_group_id and
    pay_ca_t4_reg.get_parameter('TRANSFER_GRE', ppa.legislative_parameters)
                 = to_char(p_tax_unit_id) and
    ppa.effective_date = l_year_end and
    ppa.action_status = 'C';

cursor c_all_asg(p_arch_pactid number
                ,p_prov        varchar2) is
select paf.assignment_id       assignment_id,
  faic.context prov_cd,
  paa.assignment_action_id,
  paa.payroll_action_id
from  per_assignments_f paf,
  pay_assignment_actions paa,
  ff_archive_items fai,
  ff_contexts fc,
  ff_archive_item_contexts faic
where paf.person_id between stperson
                  and   endperson
  and   paf.primary_flag = 'Y'
  and   paf.effective_start_date  = (select max(paf2.effective_start_date)
                                     from per_assignments_f paf2
                                     where paf2.assignment_id= paf.assignment_id
                                     and paf2.primary_flag = 'Y'
                                     and paf2.effective_start_date
                                         <= l_session_date) --l_year_end
  and   paf.effective_end_date    >= l_year_start
  and   paa.payroll_action_id = p_arch_pactid
  and   paa.assignment_id = paf.assignment_id
  and   paa.assignment_action_id = fai.context1
  and   fai.user_entity_id = l_uid_caeoy_gross_earning
  and   fai.archive_item_id = faic.archive_item_id
  and   faic.context = nvl(rtrim(p_prov), faic.context)
  and   faic.context_id = fc.context_id
  and   fc.context_name = 'JURISDICTION_CODE';

/* Added this to run the report for Single Person enter at SRS level*/
cursor c_single_asg(p_arch_pactid number
                   ,p_per_id      varchar2
                   ,p_prov        varchar2) is
select paf.assignment_id       assignment_id,
  faic.context prov_cd,
  paa.assignment_action_id,
  paa.payroll_action_id
from  per_assignments_f paf,
  pay_assignment_actions paa,
  ff_archive_items fai,
  ff_contexts fc,
  ff_archive_item_contexts faic
where paf.person_id between stperson
                  and   endperson
  and   paf.primary_flag = 'Y'
  and   paf.effective_start_date  = (select max(paf2.effective_start_date)
                                     from per_assignments_f paf2
                                     where paf2.assignment_id= paf.assignment_id
                                     and paf2.primary_flag = 'Y'
                                     and paf2.effective_start_date
                                         <= l_session_date) --l_year_end
  and   paf.effective_end_date    >= l_year_start
  and   paa.payroll_action_id = p_arch_pactid
  and   paa.assignment_id = paf.assignment_id
  and   paa.serial_number = p_per_id
  and   paa.assignment_action_id = fai.context1
  and   fai.user_entity_id = l_uid_caeoy_gross_earning
  and   fai.archive_item_id = faic.archive_item_id
  and   faic.context = nvl(rtrim(p_prov), faic.context)
  and   faic.context_id = fc.context_id
  and   fc.context_name = 'JURISDICTION_CODE';

/* Added this new cursor to fix bug#2135545 and this
   will be used only if Assignment Set is passed for T4 reports */

cursor c_all_asg_in_asgset(p_arch_pactid number
                          ,p_prov        varchar2) is
select paf.assignment_id       assignment_id,
  faic.context prov_cd,
  paa.assignment_action_id,
  paa.payroll_action_id
from per_assignments_f paf,
  pay_assignment_actions paa,
  ff_archive_items fai,
  ff_archive_item_contexts faic,
  ff_contexts fc
where paf.person_id >= stperson
  and   paf.person_id <= endperson
  and   paf.primary_flag = 'Y'
  and   paf.effective_start_date  = (select max(paf2.effective_start_date)
                                     from per_assignments_f paf2
                                     where paf2.assignment_id= paf.assignment_id
                                     and paf2.primary_flag = 'Y'
                                     and paf2.effective_start_date
                                         <= l_session_date) --l_year_end
  and   paf.effective_end_date    >= l_year_start
  and   paa.payroll_action_id = p_arch_pactid
  and   paa.assignment_id = paf.assignment_id
  and   paa.assignment_action_id = fai.context1
  and   fai.user_entity_id = l_uid_caeoy_gross_earning
  and   fai.archive_item_id = faic.archive_item_id
  and   faic.context = nvl(rtrim(p_prov), faic.context)
  and   faic.context_id = fc.context_id
  and   fc.context_name = 'JURISDICTION_CODE'
 AND exists (  select 1 /* Selected Assignment Set */
                 from hr_assignment_set_amendments hasa
               where hasa.assignment_set_id         = l_asg_set_id
                  and hasa.assignment_id             = paf.assignment_id
                  and upper(hasa.include_or_exclude) = 'I');

lv_serial_number varchar2(30);
ln_arch_asgact_id number;
ln_arch_pact_id number;

begin

  hr_utility.trace('begining of action creation 1 '||to_char(pactid));
  hr_utility.trace('Start Person ID = ' || to_char(stperson));
  hr_utility.trace('End Person ID = ' || to_char(endperson));
  hr_utility.trace('Chunk # = ' || to_char(chunk));

/* get report type and effective date */

  select effective_date,
    report_type,
    business_group_id,
    legislative_parameters
  into   l_effective_date,
    l_report_type,
    l_bus_group_id,
    l_legislative_parameters
  from pay_payroll_actions
  where payroll_action_id = pactid;

  hr_utility.trace('begining of action creation 2 '||to_char(l_bus_group_id));
  hr_utility.trace('legislative parameters is '||l_legislative_parameters);

  l_year := pay_ca_t4_reg.get_parameter('TAX_YEAR',l_legislative_parameters);
  l_year_start := trunc(to_date(l_year,'YYYY'), 'Y');
  l_year_end   := add_months(trunc(to_date(l_year,'YYYY'), 'Y'),12) - 1;
  l_asg_set_id := pay_ca_t4_reg.get_parameter('ASG_SET_ID',l_legislative_parameters);
  l_province   := pay_ca_t4_reg.get_parameter('PROV_CD',l_legislative_parameters);

  l_t4reg_tax_unit_id := to_number(pay_ca_t4_reg.get_parameter('GRE_ID',
                                   l_legislative_parameters));

  lv_per_id := pay_ca_t4_reg.get_parameter('PER_ID',
                                   l_legislative_parameters);

  hr_utility.trace('begining of action creation 4 '||
                                         to_char(l_t4reg_tax_unit_id));

  l_uid_caeoy_tax_year      := get_user_entity_id('CAEOY_TAXATION_YEAR');
  l_uid_caeoy_tax_unit_id   := get_user_entity_id('CAEOY_TAX_UNIT_ID');
  l_uid_caeoy_gross_earning
             := get_user_entity_id('CAEOY_GROSS_EARNINGS_PER_JD_GRE_YTD');

 if l_t4reg_tax_unit_id <> 99999 then

    l_tax_unit_id := l_t4reg_tax_unit_id;

    open cur_arch_paid(l_tax_unit_id);
    fetch cur_arch_paid into
          l_arch_payroll_action_id,
          l_session_date;
    close cur_arch_paid;

    /* Added this validation to fix bug#2135545 */
    if l_asg_set_id is not null then
       open c_all_asg_in_asgset(l_arch_payroll_action_id,
                                l_province);
    /* to run for single employee entered at SRS level */
    elsif lv_per_id is not null then
       open c_single_asg(l_arch_payroll_action_id,
                         lv_per_id,
                         l_province);
    else
       open c_all_asg(l_arch_payroll_action_id,
                      l_province);
    end if;

    hr_utility.trace('begining of if condition 5 '||to_char(l_tax_unit_id));

 else

    open c_all_gres;

    hr_utility.trace('else condition after open c_all_gres c_all_asg cursor 6 ');

 end if;


  if l_t4reg_tax_unit_id <> 99999 then
  loop

    /* Added this validation to fix bug#2135545 */
    if l_asg_set_id is not null then
      fetch c_all_asg_in_asgset into l_asg_id,
                                      l_prov_cd,
                                      ln_arch_asgact_id,
                                      ln_arch_pact_id;
       exit when c_all_asg_in_asgset%notfound;
    /* added to run for single employee entered at SRS level */
    elsif lv_per_id is not null then
      fetch c_single_asg into l_asg_id,
                           l_prov_cd,
                           ln_arch_asgact_id,
                           ln_arch_pact_id;
      exit when c_single_asg%notfound;
    else
      fetch c_all_asg into l_asg_id,
                           l_prov_cd,
                           ln_arch_asgact_id,
                           ln_arch_pact_id;
      exit when c_all_asg%notfound;
    end if;


    hr_utility.trace('Begining of if part loop for c_all_asg 10 '||
                                                 to_char(l_asg_id));


    lv_negative_bal_flag := 'N';
    if l_report_type in ('PYT4PR','T4_XML') then

      lv_negative_bal_flag :=
          pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id,
                                                 l_prov_cd,
                                                 'JURISDICTION_CODE',
                                                 'CAEOY_T4_NEGATIVE_BALANCE_EXISTS');
    end if;

    if (lv_negative_bal_flag = 'N' or
        lv_negative_bal_flag is null) then

         select pay_assignment_actions_s.nextval
         into   lockingactid
         from   dual;

         hr_nonrun_asact.insact(lockingactid,
                                l_asg_id,
                                pactid,
                                chunk,
                                l_tax_unit_id);
         hr_utility.trace('in if loop after calling hr_nonrun_asact.insact pkg 11 '
                                                              ||to_char(l_asg_id));
         /* Added this to implement T4 Register and T4 Amendment Register
            using the same report file */

         lv_serial_number := l_prov_cd||lpad(to_char(ln_arch_asgact_id),14,0)||
                             lpad(to_char(ln_arch_pact_id),14,0);

         hr_utility.trace('lv_serial_number :' ||lv_serial_number);

         update pay_assignment_actions paa
         set paa.serial_number = lv_serial_number
         where paa.assignment_action_id = lockingactid;

    else

         lv_sin := pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id,
                                                         'CAEOY_EMPLOYEE_SIN');

         lv_sin := ltrim(rtrim(replace(lv_sin, ' ')));
         lv_sin := substr(lv_sin,1,3)||' '||substr(lv_sin,4,3)||' '||substr(lv_sin,7,3);

         lv_employee_name := pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id,
                                                                    'CAEOY_EMPLOYEE_FIRST_NAME');

         lv_employee_last_name := pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id,
                                                                         'CAEOY_EMPLOYEE_LAST_NAME');

         lv_employee_full_name := lv_employee_last_name ||','|| lv_employee_name;

         lv_neg_bal_mesg := pay_ca_t4_reg.get_label('PAY_CA_LABELS','EOY_NEG_BAL');
         lv_person_type  := pay_ca_t4_reg.get_label('PERSON_TYPE','EMP');
         lv_message_level:= pay_ca_t4_reg.get_label('MESSAGE_LEVEL','W');

         lv_message:= lv_message_level||':'|| lv_person_type ||':'|| substr(lv_employee_full_name,1,45) ||
                      '(' || lv_sin || ') ' || lv_neg_bal_mesg;

         pay_core_utils.push_message(801,'HR_ELE_ENTRY_FORMULA_HINT','A');
         pay_core_utils.push_token('FORMULA_TEXT',lv_message);

    end if;

  end loop;

    /* Added this validation to fix bug#2135545 */
    if l_asg_set_id is not null then
      close c_all_asg_in_asgset;
    elsif lv_per_id is not null then
      close c_single_asg;
    else
      close c_all_asg;
    end if;
    hr_utility.trace('End of cursor c_all_asg 12');

  else

    loop
    fetch c_all_gres into
          l_tax_unit_id,
          l_arch_payroll_action_id,
          l_session_date;

    hr_utility.trace('Begining of else loop for c_all_gres 7 '||to_char(l_tax_unit_id));
    exit when c_all_gres%notfound;

    /* Added this validation to fix bug#2135545 */
    if l_asg_set_id is not null then
      open c_all_asg_in_asgset(l_arch_payroll_action_id,
                               l_province);
    elsif lv_per_id is not null then
      open c_single_asg(l_arch_payroll_action_id,
                        lv_per_id,
                        l_province);
    else
      open c_all_asg(l_arch_payroll_action_id,
                     l_province);
    end if;

    loop
    /* Added this validation to fix bug#2135545 */
    if l_asg_set_id is not null then
      fetch c_all_asg_in_asgset into l_asg_id,
                                     l_prov_cd,
                                     ln_arch_asgact_id,
                                     ln_arch_pact_id;
      exit when c_all_asg_in_asgset%notfound;
     /* added to run for single employee entered at SRS level */
    elsif lv_per_id is not null then
      fetch c_single_asg into l_asg_id,
                           l_prov_cd,
                           ln_arch_asgact_id,
                           ln_arch_pact_id;
      exit when c_single_asg%notfound;
    else
      fetch c_all_asg into l_asg_id,
                           l_prov_cd,
                           ln_arch_asgact_id,
                           ln_arch_pact_id;
      exit when c_all_asg%notfound;
    end if;

    hr_utility.trace('Begining of loop for c_all_asg 8 '||to_char(l_asg_id));

    lv_negative_bal_flag := 'N';
    if l_report_type in ('PYT4PR','T4_XML') then

      lv_negative_bal_flag :=
          pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id,
                                                 l_prov_cd,
                                                 'JURISDICTION_CODE',
                                                 'CAEOY_T4_NEGATIVE_BALANCE_EXISTS');
    end if;

    if (lv_negative_bal_flag = 'N' or
        lv_negative_bal_flag is null) then

         select pay_assignment_actions_s.nextval
         into   lockingactid
         from   dual;

         hr_nonrun_asact.insact(lockingactid,
                                l_asg_id,
                                pactid,
                                chunk,
                                l_tax_unit_id);

         hr_utility.trace('in if loop after calling hr_nonrun_asact.insact pkg 9 '
                                                        ||to_char(l_asg_id));

         /* Added this to implement T4 Register and T4 Amendment Register
            using the same report file */

         lv_serial_number := l_prov_cd||lpad(to_char(ln_arch_asgact_id),14,0)||
                             lpad(to_char(ln_arch_pact_id),14,0);

         hr_utility.trace('lv_serial_number :' ||lv_serial_number);

         update pay_assignment_actions paa
         set paa.serial_number = lv_serial_number
         where paa.assignment_action_id = lockingactid;

    else

         lv_sin := pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id,
                                                         'CAEOY_EMPLOYEE_SIN');

         lv_sin := ltrim(rtrim(replace(lv_sin, ' ')));
         lv_sin := substr(lv_sin,1,3)||' '||substr(lv_sin,4,3)||' '||substr(lv_sin,7,3);

         lv_employee_name := pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id,
                                                                    'CAEOY_EMPLOYEE_FIRST_NAME');

         lv_employee_last_name := pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id,
                                                                         'CAEOY_EMPLOYEE_LAST_NAME');

         lv_employee_full_name := lv_employee_last_name ||','|| lv_employee_name;

         lv_neg_bal_mesg := pay_ca_t4_reg.get_label('PAY_CA_LABELS','EOY_NEG_BAL');
         lv_person_type  := pay_ca_t4_reg.get_label('PERSON_TYPE','EMP');
         lv_message_level:= pay_ca_t4_reg.get_label('MESSAGE_LEVEL','W');

         lv_message:= lv_message_level||':'|| lv_person_type ||':'|| substr(lv_employee_full_name,1,45) ||                      '(' || lv_sin || ') ' || lv_neg_bal_mesg;

         pay_core_utils.push_message(801,'HR_ELE_ENTRY_FORMULA_HINT','A');
         pay_core_utils.push_token('FORMULA_TEXT',lv_message);

    end if;

    end loop;

    /* Added this validation to fix bug#2135545 */
    if l_asg_set_id is not null then
      close c_all_asg_in_asgset;
    elsif lv_per_id is not null then
      close c_single_asg;
    else
      close c_all_asg;
    end if;

  end loop;
  close c_all_gres;
  end if;

   hr_utility.trace('End of If Condition for Loop 13');

end action_creation;

---------------------------------- sort_action -----------------------------
procedure sort_action
(
   payactid   in     varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out nocopy    number        /* length of the sql string */
) is
   begin
	hr_utility.trace('Start of Sort_Action 1');

      sqlstr :=  'select paa1.rowid
                   from hr_all_organization_units  hou,
                        hr_all_organization_units  hou1,
                        hr_locations_all           loc,
                        per_all_people_f           ppf,
                        per_all_assignments_f      paf,
                        pay_assignment_actions     paa1,
                        pay_payroll_actions        ppa1
                   where ppa1.payroll_action_id = :pactid
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
                           ppf.last_name,first_name
                   for update of paa1.assignment_action_id';

      len := length(sqlstr); -- return the length of the string.
	hr_utility.trace('End of Sort_Action 2');
   end sort_action;
--
------------------------------ get_parameter -------------------------------
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;
--
function get_label(p_lookup_type in varchar2,
                   p_lookup_code in varchar2) return varchar2 is

  l_meaning  hr_lookups.meaning%TYPE;

  CURSOR cur_get_meaning IS
  SELECT hl.meaning
  FROM hr_lookups hl
  WHERE hl.lookup_type = p_lookup_type AND
    hl.lookup_code = p_lookup_code;

BEGIN

  OPEN cur_get_meaning;
  FETCH cur_get_meaning
  INTO  l_meaning;
  if cur_get_meaning%NOTFOUND then
    l_meaning := NULL;
  end if;

  CLOSE cur_get_meaning;

  RETURN l_meaning;

END get_label; -- get_label

end pay_ca_t4_reg;

/
