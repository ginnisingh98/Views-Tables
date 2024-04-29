--------------------------------------------------------
--  DDL for Package Body PAY_CA_T4A_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_T4A_REG" AS
/* $Header: pycat4ar.pkb 120.1.12010000.2 2009/09/02 11:32:13 sapalani ship $ */

----------------------------- range_cursor ----------------------------------

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

procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
  l_payroll_id number;
  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_uid_tax_year     ff_user_entities.user_entity_id%TYPE;
  l_uid_tax_unit_id  ff_user_entities.user_entity_id%TYPE;
  l_uid_person_id    ff_user_entities.user_entity_id%TYPE;
--
begin
  --hr_utility.trace_on('Y','ORACLE');
  hr_utility.trace('begining of range_cursor 1 ');

  select
    legislative_parameters
  into
    leg_param
  from
    pay_payroll_actions ppa
  where ppa.payroll_action_id = pactid;

   l_uid_tax_year    := get_user_entity_id('CAEOY_TAXATION_YEAR');
   l_uid_tax_unit_id := get_user_entity_id('CAEOY_TAX_UNIT_ID');
   l_uid_person_id   := get_user_entity_id('CAEOY_PERSON_ID');

   sqlstr := 'select distinct to_number(fai3.value)
                from    ff_archive_items fai1,
                        ff_archive_items fai2,
                        ff_archive_items fai3,
                        pay_payroll_actions     ppa,
                        pay_assignment_actions  paa
                 where  ppa.payroll_action_id    = :payroll_action_id
                 and    fai1.user_entity_id = ' || l_uid_tax_year ||
                 ' and    fai1.value =
                        nvl(pay_ca_t4a_reg.get_parameter(''TAX_YEAR'',ppa.legislative_parameters),fai1.value)
                 and    fai2.user_entity_id = ' || l_uid_tax_unit_id ||
                 ' and    fai2.value           =
                  nvl(pay_ca_t4a_reg.get_parameter(''GRE_ID'',ppa.legislative_parameters),fai2.value)
                 and    fai1.context1        = fai2.context1
                 and    paa.payroll_action_id= fai2.context1
                 and    paa.assignment_action_id=fai3.context1
                 and    fai3.user_entity_id = ' || l_uid_person_id ||
                 ' and    fai3.value =
                  nvl(pay_ca_t4a_reg.get_parameter(''PER_ID'',ppa.legislative_parameters),fai3.value)
                 order by to_number(fai3.value)';

	hr_utility.trace('End of range_cursor 2 ');

end range_cursor;
------------------------- action_creation ----------------------------------

procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

  lockingactid  number;
  lockedactid   number;
  l_asg_set_id  number;
  l_asg_id      number;
  l_tax_unit_id number;
  l_year        varchar2(4);
  l_bus_group_id number;
  l_year_start  date;
  l_year_end    date;
  l_t4areg_tax_unit_id number;
  l_effective_date date;
  l_report_type varchar2(80);
  l_legislative_parameters varchar2(240);
  l_uid_caeoy_tax_year	   ff_user_entities.user_entity_id%TYPE;
  l_uid_caeoy_tax_unit_id  ff_user_entities.user_entity_id%TYPE;
  l_arch_pactid            pay_payroll_actions.payroll_action_id%TYPE;
  l_session_date           pay_payroll_actions.effective_date%TYPE;
  lv_per_id                varchar2(30);

   cursor c_all_gres is
   select   distinct to_number(fai2.value) tax_unit_id,
     payroll_action_id arch_pactid,
     ppa.effective_date
   from pay_payroll_actions ppa,
     ff_archive_items fai1,
     ff_archive_items fai2
   where fai1.user_entity_id = l_uid_caeoy_tax_year
   and fai1.value      = l_year
   and fai2.context1 = fai1.context1
   and fai2.user_entity_id = l_uid_caeoy_tax_unit_id
   and ppa.payroll_action_id = fai1.context1
   and ppa.report_type = 'T4A'
   and ppa.report_qualifier = 'CAEOY'
   and ppa.report_category = 'CAEOY'
   and ppa.action_type = 'X'
   and ppa.business_group_id+0 = l_bus_group_id;

   cursor cur_gre is
   select payroll_action_id arch_pactid,
          ppa.effective_date
   from pay_payroll_actions ppa,
        ff_archive_items fai1,
        ff_archive_items fai2
   where fai1.user_entity_id = l_uid_caeoy_tax_year
   and fai1.value      = l_year
   and ppa.payroll_action_id = fai1.context1
   and  ppa.report_type = 'T4A'
   and ppa.report_qualifier = 'CAEOY'
   and ppa.report_category = 'CAEOY'
   and ppa.action_type = 'X'
   and ppa.business_group_id + 0 = l_bus_group_id
   and fai1.context1    = fai2.context1
   and fai2.user_entity_id = l_uid_caeoy_tax_unit_id
   and fai2.value = to_char(l_t4areg_tax_unit_id);

   cursor c_all_asg(p_arch_pactid number) is
   select
     paf.assignment_id       assignment_id,
     paa.assignment_action_id,
     paa.payroll_action_id
   from
     per_assignments_f paf,
     pay_assignment_actions paa
   where
     paf.person_id >= stperson and
     paf.person_id <= endperson and
     paf.primary_flag = 'Y' and
     paf.assignment_type = 'E' and
     paf.business_group_id = l_bus_group_id and
     paf.effective_start_date  = (select max(paf2.effective_start_date)
                                     from per_assignments_f paf2
                                     where paf2.assignment_id= paf.assignment_id
                                     and paf2.primary_flag = 'Y'
                                     and paf2.effective_start_date
                                         <= l_session_date) and --l_year_end
     paf.effective_end_date    >= l_year_start and
     paf.assignment_id = paa.assignment_id and
     paa.payroll_action_id = p_arch_pactid;

/* Added this to run the report for Single Person enter at SRS level*/
  cursor c_single_asg(p_arch_pactid number
                     ,p_per_id varchar2 ) is
  select paf.assignment_id       assignment_id,
         paa.assignment_action_id,
         paa.payroll_action_id
  from  per_assignments_f paf,
        pay_assignment_actions paa
  where paf.person_id between stperson
                      and     endperson
  and   paf.primary_flag = 'Y'
  and   paf.assignment_type = 'E'
  and   paf.business_group_id = l_bus_group_id
  and   paf.effective_start_date  = (select max(paf2.effective_start_date)
                                     from per_assignments_f paf2
                                     where paf2.assignment_id= paf.assignment_id
                                     and paf2.primary_flag = 'Y'
                                     and paf2.effective_start_date
                                         <= l_session_date)
  and   paf.effective_end_date    >= l_year_start
  and   paa.payroll_action_id = p_arch_pactid
  and   paa.assignment_id = paf.assignment_id
  and   paa.serial_number = p_per_id;

/* Added this new cursor to fix bug#2135545 and this
   will be used only if Assignment Set is passed for T4A reports */

   cursor c_all_asg_in_asgset(p_arch_pactid number) is
   select
     paf.assignment_id       assignment_id,
     paa.assignment_action_id,
     paa.payroll_action_id
   from
     per_assignments_f paf,
     pay_assignment_actions paa
   where
     paf.person_id >= stperson and
     paf.person_id <= endperson and
     paf.primary_flag = 'Y' and
     paf.assignment_type = 'E' and
     paf.business_group_id = l_bus_group_id and
     paf.effective_start_date  = (select max(paf2.effective_start_date)
                                     from per_assignments_f paf2
                                     where paf2.assignment_id= paf.assignment_id
                                     and paf2.primary_flag = 'Y'
                                     and paf2.effective_start_date
                                         <= l_session_date) and --l_year_end
     paf.effective_end_date    >= l_year_start and
     paf.assignment_id = paa.assignment_id and
     paa.payroll_action_id = p_arch_pactid and
     exists ( select 1 /* Selected Assignment Set */
                     from hr_assignment_set_amendments hasa
                     where hasa.assignment_set_id  = l_asg_set_id
                     and hasa.assignment_id   = paf.assignment_id
                     and upper(hasa.include_or_exclude) = 'I');

lv_serial_number varchar2(30);
ln_arch_asgact_id number;
ln_arch_pact_id number;


begin

  hr_utility.trace('begining of action creation 1 '||to_char(pactid));

  /* get report type and effective date */

   select
     effective_date,
     report_type,
     business_group_id,
     legislative_parameters
   into
     l_effective_date,
     l_report_type,
     l_bus_group_id,
     l_legislative_parameters
   from
     pay_payroll_actions
   where
     payroll_action_id = pactid;

   hr_utility.trace('begining of action creation 2 '||
                             to_char(l_bus_group_id));

   hr_utility.trace('legislative parameters is '||l_legislative_parameters);
   hr_utility.trace('Start Person ID = '||to_char(stperson));
   hr_utility.trace('End Person ID = '||to_char(endperson));
   hr_utility.trace('Chunk # = '||to_char(chunk));

   l_year := pay_ca_t4a_reg.get_parameter('TAX_YEAR',l_legislative_parameters);
   l_year_start := trunc(to_date(l_year,'YYYY'), 'Y');
   l_year_end   := add_months(trunc(to_date(l_year,'YYYY'), 'Y'),12) - 1;
   l_asg_set_id := pay_ca_t4a_reg.get_parameter('ASG_SET_ID',
                                                 l_legislative_parameters);
   lv_per_id    := pay_ca_t4a_reg.get_parameter('PER_ID',l_legislative_parameters);

   hr_utility.trace('begining of action creation 3 '||
                 l_year||to_char(l_year_start)||to_char(l_year_end));

   l_t4areg_tax_unit_id := to_number(pay_ca_t4a_reg.get_parameter('GRE_ID',
                   l_legislative_parameters));
   l_uid_caeoy_tax_year    := get_user_entity_id('CAEOY_TAXATION_YEAR');
   l_uid_caeoy_tax_unit_id := get_user_entity_id('CAEOY_TAX_UNIT_ID');

   hr_utility.trace('begining of action creation 4 '
                ||to_char(l_t4areg_tax_unit_id));

  if l_t4areg_tax_unit_id is not null then

    hr_utility.trace(' Tax Unit ID is passed = '|| to_char(l_t4areg_tax_unit_id));

    open cur_gre;

    fetch cur_gre
    into l_arch_pactid,
         l_session_date;

    close cur_gre;

  /* Added this validation to fix bug#2135545 */

    if l_asg_set_id is not null then
      open c_all_asg_in_asgset(l_arch_pactid);
    elsif lv_per_id is not null then
      open c_single_asg(l_arch_pactid, lv_per_id);
    else
      open c_all_asg(l_arch_pactid);
    end if;

    loop

      hr_utility.trace('l_t4areg_tax_unit_id is = ' ||
                       to_char(l_t4areg_tax_unit_id));

      l_tax_unit_id := l_t4areg_tax_unit_id;


      hr_utility.trace('begining of if condition 5 '||to_char(l_tax_unit_id));

      /* Added this validation to fix bug#2135545 */
      if l_asg_set_id is not null then
        fetch c_all_asg_in_asgset into l_asg_id,
                                       ln_arch_asgact_id,
                                       ln_arch_pact_id;
        exit when c_all_asg_in_asgset%notfound;
      elsif lv_per_id is not null then
        fetch c_single_asg into l_asg_id,
                                ln_arch_asgact_id,
                                ln_arch_pact_id;
        exit when c_single_asg%notfound;
      else
        fetch c_all_asg into l_asg_id,
                             ln_arch_asgact_id,
                             ln_arch_pact_id;
        exit when c_all_asg%notfound;
      end if;

      hr_utility.trace('Begining of if part loop for c_all_asg 10 '||
                                  to_char(l_asg_id));

      select  pay_assignment_actions_s.nextval
      into  lockingactid
      from dual;

      hr_nonrun_asact.insact(lockingactid,
                           l_asg_id,
                           pactid,
                           chunk,
                           l_tax_unit_id);

      hr_utility.trace('in if loop after calling hr_nonrun_asact.insact pkg 11 '||to_char(l_asg_id));

      /* Added this to implement T4A Register and T4A Amendment Register
         using the same report file */

      lv_serial_number := lpad(to_char(ln_arch_asgact_id),14,0)||
                          lpad(to_char(ln_arch_pact_id),14,0);

      /* Bug 4932662 - Negative balance is marked in serial_number for T4A PDF */
      if (l_report_type = 'PAYCAT4APDF') then
				lv_serial_number := lv_serial_number ||trim(pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id ,
									                                  'CAEOY_T4A_NEGATIVE_BALANCE_EXISTS'));
			end if;

      hr_utility.trace('lv_serial_number :' ||lv_serial_number);

      update pay_assignment_actions paa
      set paa.serial_number = lv_serial_number
      where paa.assignment_action_id = lockingactid;

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

   hr_utility.trace('All the GREs will be processed !!!');

   open c_all_gres;
   loop

     fetch c_all_gres
     into
       l_tax_unit_id,
       l_arch_pactid,
       l_session_date;

     exit when c_all_gres%notfound;

     hr_utility.trace('l_tax_unit_id = ' || to_char(l_tax_unit_id));
     hr_utility.trace('l_arch_pactid = ' || to_char(l_arch_pactid));

     if l_asg_set_id is not null then
       open c_all_asg_in_asgset(l_arch_pactid);
     elsif lv_per_id is not null then
       open c_single_asg (l_arch_pactid, lv_per_id);
     else
       open c_all_asg(l_arch_pactid);
     end if;

     loop

     /* Added this validation to fix bug#2135545 */
       if l_asg_set_id is not null then
         fetch c_all_asg_in_asgset into l_asg_id,
                                        ln_arch_asgact_id,
                                        ln_arch_pact_id;
         exit when c_all_asg_in_asgset%notfound;
       elsif lv_per_id is not null then
         fetch c_single_asg into l_asg_id,
                                 ln_arch_asgact_id,
                                 ln_arch_pact_id;
         exit when c_single_asg%notfound;
       else
         hr_utility.trace(' Fetching c_all_asg !!!');
         fetch c_all_asg into l_asg_id,
                              ln_arch_asgact_id,
                              ln_arch_pact_id;
         exit when c_all_asg%notfound;
       end if;

       select pay_assignment_actions_s.nextval
       into   lockingactid
       from   dual;

       hr_nonrun_asact.insact(lockingactid,
                              l_asg_id,
                              pactid,
                              chunk,
                              l_tax_unit_id);

       hr_utility.trace('in if loop after calling hr_nonrun_asact.insact pkg 9 '||
                                to_char(l_asg_id));

      /* Added this to implement T4A Register and T4A Amendment Register
         using the same report file */

       lv_serial_number := lpad(to_char(ln_arch_asgact_id),14,0)||
                           lpad(to_char(ln_arch_pact_id),14,0);

       /* Bug 4932662 - Negative balance is marked in serial_number for T4A PDF */
       if (l_report_type = 'PAYCAT4APDF') then
			   	lv_serial_number := lv_serial_number ||trim(pay_ca_archive_utils.get_archive_value(ln_arch_asgact_id ,
									                                  'CAEOY_T4A_NEGATIVE_BALANCE_EXISTS'));
		   end if;

       hr_utility.trace('lv_serial_number :' ||lv_serial_number);

       update pay_assignment_actions paa
       set paa.serial_number = lv_serial_number
       where paa.assignment_action_id = lockingactid;

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

---------------------------------- sort_action ---------------------------------

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
                           decode(pay_ca_t4_reg.get_parameter(''P_S2'',
                                                  ppa1.legislative_parameters),
                                        ''GRE'',hou1.name,
                                        ''ORGANIZATION'',hou.name,
                                        ''LOCATION'',loc.location_code,null),
                           decode(pay_ca_t4_reg.get_parameter(''P_S3'',
                                     ppa1.legislative_parameters),
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

function get_label(p_lookup_type in VARCHAR2,
                    p_lookup_code in VARCHAR2)
return VARCHAR2 is
cursor csr_label_meaning is
select meaning
from hr_lookups
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code;

  l_label_meaning  varchar2(80);
begin
  open csr_label_meaning;

    fetch csr_label_meaning into l_label_meaning;
    if csr_label_meaning%NOTFOUND then
      l_label_meaning       := NULL;
    end if;
  close csr_label_meaning;

  return l_label_meaning;
end get_label;


function get_label(p_lookup_type in VARCHAR2,
                    p_lookup_code in VARCHAR2,
                    p_person_language in varchar2)
return VARCHAR2 is
cursor csr_label_meaning is
select 1 ord, meaning
from  fnd_lookup_values
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code
and ( ( p_person_language is null and language = 'US' ) or
      ( p_person_language is not null and language = p_person_language ) )
union all
select 2 ord, meaning
from  fnd_lookup_values
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code
and ( language = 'US' and p_person_language is not null
      and language <> p_person_language )
order by 1;

  l_order number;
  l_label_meaning  varchar2(80);
begin
  open csr_label_meaning;

   fetch csr_label_meaning into l_order, l_label_meaning;
    if csr_label_meaning%NOTFOUND then
      l_label_meaning       := NULL;
    end if;
  close csr_label_meaning;

   return l_label_meaning;
end get_label;

end pay_ca_t4a_reg;

/
