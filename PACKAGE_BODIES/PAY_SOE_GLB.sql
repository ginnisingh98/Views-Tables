--------------------------------------------------------
--  DDL for Package Body PAY_SOE_GLB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SOE_GLB" as
/* $Header: pysoeglb.pkb 120.8.12010000.5 2009/06/18 04:30:41 pgongada ship $ */
--
l_sql long;
g_debug boolean := hr_utility.debug_enabled;
g_max_action number;
g_min_action number;

--
--
/* ---------------------------------------------------------------------
Function : SetParameters

Text
------------------------------------------------------------------------ */
function setParameters(p_assignment_action_id in number) return varchar2 is
--
cursor getParameters(c_assignment_action_id in number) is
select pa.payroll_id
--,      to_number(to_char(pa.effective_date,'J')) effective_date
,replace(substr(FND_DATE.DATE_TO_CANONICAL(pa.effective_date),1,10),'/','-') jsqldate       --YYYY-MM-DD
,'' || pa.effective_date || '' effective_date
,      aa.assignment_id
,      pa.business_group_id
,      aa.tax_unit_id
,''''  || bg.currency_code || '''' currency_code
,action_type
,fc.name currency_name
from   pay_payroll_actions pa
,      pay_assignment_actions aa
,      per_business_groups bg
,      fnd_currencies_vl fc
where  aa.assignment_action_id = p_assignment_action_id
and    aa.payroll_action_id = pa.payroll_action_id
and    pa.business_group_id = bg.business_group_id
and    fc.currency_code = bg.currency_code
and rownum = 1;

cursor getActions is
select assignment_action_id
from pay_assignment_actions
where level =
  (select max(level)
   from pay_assignment_actions
   connect by source_action_id =  prior assignment_action_id
   start with assignment_action_id = p_assignment_action_id)
connect by source_action_id =  prior assignment_action_id
start with assignment_action_id = p_assignment_action_id;

l_action_type pay_payroll_actions.action_type%type;

cursor lockedActions is
select locked_action_id,
       action_sequence
from pay_action_interlocks,
     pay_assignment_actions
where locking_action_id = p_assignment_action_id
and locked_action_id = assignment_action_id
order by action_sequence desc;

--
l_parameters varchar2(2000);
l_action_count number;
l_actions varchar2(2000);
l_max_action number;
l_min_action number;
l_assignment_action_id number;
--
begin
--
   if g_debug then
     hr_utility.set_location('Entering pay_soe_glb.setParameters', 10);
   end if;
   --
   -- Prepay change
   select action_type
   into l_action_type
   from  pay_payroll_actions pa
        ,pay_assignment_actions aa
   where  aa.assignment_action_id = p_assignment_action_id
   and    aa.payroll_action_id = pa.payroll_action_id;

   /* exception
         when no_data_found then
   */

   l_action_count := 0;
   l_max_action := 0;
   l_min_action := 0;

   if l_action_type in ('P','U') then
      for a in lockedActions loop
          l_action_count := l_action_count + 1;
          l_actions := l_actions || a.locked_action_id|| ',';
          if l_max_action = 0 then
             l_max_action := a.locked_action_id;
          end if;
          l_min_action := a.locked_action_id;
      end loop;
   else
      for a in getActions loop
          l_action_count := l_action_count + 1;
          l_actions := l_actions || a.assignment_action_id|| ',';
      end loop;
   end if;

   l_actions := substr(l_actions,1,length(l_actions)-1);
   --
   if l_action_type in ( 'P','U' ) then
      l_assignment_action_id := l_max_action; -- for Prepays, effective date is date of
   else                                       -- latest run action.
      l_assignment_action_id := p_assignment_action_id;
   end if;

   for p in getParameters(l_assignment_action_id) loop
       l_parameters := 'PAYROLL_ID:'        ||p.payroll_id        ||':'||
                       'JSQLDATE:'          ||p.jsqldate          ||':'||
                       'EFFECTIVE_DATE:'    ||p.effective_date    ||':'||
                       'ASSIGNMENT_ID:'     ||p.assignment_id     ||':'||
                       'BUSINESS_GROUP_ID:' ||p.business_group_id ||':'||
                       'TAX_UNIT_ID:'       ||p.tax_unit_id       ||':'||
                       'G_CURRENCY_CODE:'   ||p.currency_code     ||':'||
                       'PREPAY_MAX_ACTION:' ||l_max_action        ||':'||
                       'PREPAY_MIN_ACTION:' ||l_min_action        ||':'||
                       'CURRENCY_NAME:'     ||p.currency_name     ||':'||
                       'ASSIGNMENT_ACTION_ID:'||p_assignment_action_id||':';
       if g_debug then
          hr_utility.trace('p_payroll_id = ' || p.payroll_id);
          hr_utility.trace('jsqldate = ' || p.jsqldate);
          hr_utility.trace('effective_date = ' || p.effective_date);
          hr_utility.trace('assignment_id = ' || p.assignment_id);
          hr_utility.trace('business_group_id = ' || p.business_group_id);
          hr_utility.trace('tax_unit_id = ' || p.tax_unit_id);
          hr_utility.trace('g_currency_code = ' || g_currency_code);
          hr_utility.trace('action_clause = ' || l_actions);
       end if;
       g_currency_code := p.currency_code;
       l_action_type := p.action_type;
   end loop;
   --
   if l_action_count = 1 then
      l_parameters := l_parameters || 'ACTION_CLAUSE:' ||
                         ' = '||l_actions ||':';
   else
      l_parameters := l_parameters ||  'ACTION_CLAUSE:' ||
                         ' in ('||l_actions ||')' ||':';
   end if;
   --
   if g_debug then
     hr_utility.trace('l_parameters = ' || l_parameters);
     hr_utility.set_location('Leaving pay_soe_glb.setParameters', 20);
   end if;
   --
   return l_parameters;
end;
--
/* ---------------------------------------------------------------------
Function : SetParameters

Text
------------------------------------------------------------------------ */
function setParameters(p_person_id in number, p_assignment_id in number, p_effective_date date) return varchar2 is
   cursor csr_get_asg_id is
   select assignment_id
   from   per_all_assignments_f
   where  person_id = p_person_id
   and    p_effective_date between effective_start_date and effective_end_date;

   /* Bug#6887749
    * Removed join with per_time_periods to fetch the latest assignment action
    * id of the assignment irrespective of the session date.*/
   cursor csr_get_action_id (asg_id number) is
   select to_number(substr(max(to_char(pa.effective_date,'J')||lpad(aa.assignment_action_id,15,'0')),8))
   from   pay_payroll_actions    pa,
          pay_assignment_actions aa
         -- per_time_periods       ptp
   where  aa.action_status = 'C'
   and    pa.payroll_action_id = aa.payroll_action_id
   and    aa.assignment_id = asg_id
   --and    ptp.payroll_id = pa.payroll_id
   --and    pa.effective_date <= ptp.regular_payment_date
   --and    p_effective_date between ptp.start_date and ptp.end_date
   and    pa.action_type in ('P','Q','R','U')
   order by pa.effective_date desc ;

   l_assignment_action_id  number;
   l_assignment_id         number;
begin
  --
  if g_debug then
     hr_utility.set_location('Entering pay_soe_glb.setParameters', 10);
  end if;
  --
  l_assignment_id := p_assignment_id;
  if l_assignment_id is null then
     open csr_get_asg_id;
     fetch csr_get_asg_id into l_assignment_id;
     close csr_get_asg_id;
  end if;

  open csr_get_action_id(l_assignment_id);
  fetch csr_get_action_id into l_assignment_action_id;
  close csr_get_action_id;

  /* Bug # 6887749
  *  If there is no assignment action for this employee then the cursor returns
  *  null, so we are passing -1 to java layer to raise error message.*/
  if (l_assignment_action_id is null) then
     return '-1';
  else
     return pay_soe_glb.setParameters(l_assignment_action_id);
  end if;
  --
end;
--
/* ---------------------------------------------------------------------
Function : Employee

Returns SQL string for retrievening Employee information based on
assignment ID and effective date derived from the assignment action ID
passed onto the SOE module
------------------------------------------------------------------------ */
function Employee(p_assignment_action_id in number) return long is
--
begin
   --
   if g_debug then
     hr_utility.set_location('Entering pay_soe_glb.Employee', 10);
   end if;
   --
l_sql :=
'Select org.name COL01
        ,job.name COL02
        ,loc.location_code COL03
        ,grd.name COL04
        ,pay.payroll_name COL05
        ,pos.name COL06
        ,hr_general.decode_organization(:tax_unit_id) COL07
        ,pg.group_name COL08
        ,peo.national_identifier COL09
        ,employee_number COL10
        ,hl.meaning      COL11
        ,assignment_number COL12
        ,nvl(ppb1.salary,''0'') COL13
  from   per_all_people_f             peo
        ,per_all_assignments_f        asg
        ,hr_all_organization_units_vl org
        ,per_jobs_vl                  job
        ,per_all_positions            pos
        ,hr_locations                 loc
        ,per_grades_vl                grd
        ,pay_payrolls_f               pay
        ,pay_people_groups            pg
        ,hr_lookups                   hl
        ,(select ppb2.pay_basis_id
                ,ppb2.business_group_id
                ,ee.assignment_id
                ,eev.screen_entry_value       salary
          from   per_pay_bases                ppb2
                ,pay_element_entries_f        ee
                ,pay_element_entry_values_f   eev
          where  ppb2.input_value_id          = eev.input_value_id
          and    ee.element_entry_id          = eev.element_entry_id
          and    :effective_date              between ee.effective_start_date
                                              and ee.effective_end_date
          and    :effective_date              between eev.effective_start_date
                                              and eev.effective_end_date
          ) ppb1
  where  asg.assignment_id   = :assignment_id
    and  :effective_date
  between asg.effective_start_date and asg.effective_end_date
    and  asg.person_id       = peo.person_id
    and  :effective_date
  between peo.effective_start_date and peo.effective_end_date
    and  asg.position_id     = pos.position_id(+)
    and  asg.job_id          = job.job_id(+)
    and  asg.location_id     = loc.location_id(+)
    and  asg.grade_id        = grd.grade_id(+)
    and  asg.people_group_id = pg.people_group_id(+)
    and  asg.payroll_id      = pay.payroll_id(+)
    and  :effective_date
  between pay.effective_start_date(+) and pay.effective_end_date(+)
    and  asg.organization_id = org.organization_id
    and  :effective_date
  between org.date_from and nvl(org.date_to, :effective_date)
    and  asg.pay_basis_id    = ppb1.pay_basis_id(+)
    and  asg.assignment_id   = ppb1.assignment_id(+)
    and  asg.business_group_id = ppb1.business_group_id(+)
  and hl.application_id (+) = 800
  and hl.lookup_type (+) =''NATIONALITY''
  and hl.lookup_code (+) =peo.nationality';
--
   --
   if g_debug then
     hr_utility.set_location('Leaving pay_soe_glb.Employee', 20);
   end if;
   --
return l_sql;
--
end Employee;
--
--
/* ---------------------------------------------------------------------
Function : Period

Text
------------------------------------------------------------------------ */
function Period(p_assignment_action_id in number) return long is
--
l_action_type varchar2(2);
cursor periodDates is
select pa.action_type from
        pay_payroll_actions pa
,       pay_assignment_actions aa
where   pa.payroll_action_id = aa.payroll_action_id
and     aa.assignment_action_id = p_assignment_action_id;

begin
   --
   if g_debug then
     hr_utility.set_location('Entering pay_soe_glb.Period', 10);
   end if;
   --

   open periodDates;
   fetch periodDates into l_action_type;
   close periodDates;

   if l_action_type is not null then
      if l_action_type in ( 'P','U' ) then
         l_sql :=
         'select tp1.period_name || decode(tp2.period_name, tp1.period_name, null, '' - '' ||  tp2.period_name) COL01
         ,fnd_date.date_to_displaydate(tp1.end_date)   COL04
 	 ,fnd_date.date_to_displaydate(pa2.effective_date) COL03
 	 ,fnd_date.date_to_displaydate(aa1.start_date) COL05
 	 ,fnd_date.date_to_displaydate(aa2.end_date)    COL06
	 ,fnd_date.date_to_displaydate(tp1.start_date)  COL02
         ,tp1.period_type COL07
	 from pay_all_payrolls_f pp1
            ,pay_all_payrolls_f pp2
            ,pay_payroll_actions pa1
            ,pay_payroll_actions pa2
	    ,per_time_periods tp1
            ,per_time_periods tp2
	    ,pay_assignment_actions aa1
            ,pay_assignment_actions aa2
	 where pa1.payroll_action_id = aa1.payroll_action_id
	 --We are considering effective_date(Date Paid) which some
     --localizations may allows the user to change. Its the same
     --case for the Date Earned as well. Its better to use
     --time period id which is consistent.
 	 /*and pa1.effective_date +nvl(pp1.pay_date_offset,0) =
                                   tp1.regular_payment_date*/
     and pa1.time_period_id = tp1.time_period_id
	 and pa1.payroll_id = tp1.payroll_id
 	 and aa1.assignment_action_id = :PREPAY_MAX_ACTION
         and pa2.payroll_action_id = aa2.payroll_action_id
         --We are considering effective_date(Date Paid) which some
         --localizations may allows the user to change. Its the same
         --case for the Date Earned as well. Its better to use
         --time period id which is consistent.
         /*and pa2.effective_date +nvl(pp2.pay_date_offset,0) =
                                   tp2.regular_payment_date*/
         and pa2.time_period_id = tp2.time_period_id
         and pa2.payroll_id = tp2.payroll_id
         and aa2.assignment_action_id = :PREPAY_MIN_ACTION
         and pa1.payroll_id = pp1.payroll_id
         and pa1.effective_date between pp1.effective_start_date
                                    and pp1.effective_end_date
         and pa2.payroll_id = pp2.payroll_id
         and pa2.effective_date between pp2.effective_start_date
                                    and pp2.effective_end_date';
      else
         l_sql :=
         'select tp.period_name COL01
         ,fnd_date.date_to_displaydate(tp.end_date)   COL04
         ,fnd_date.date_to_displaydate(pa.effective_date) COL03
         ,fnd_date.date_to_displaydate(aa.start_date) COL05
         ,fnd_date.date_to_displaydate(aa.end_date)    COL06
         ,fnd_date.date_to_displaydate(tp.start_date)  COL02
         ,tp.period_type COL07
         from pay_payroll_actions pa
         ,per_time_periods tp
         ,pay_assignment_actions aa
         where pa.payroll_action_id = aa.payroll_action_id
         and pa.effective_date = tp.regular_payment_date
         and pa.payroll_id = tp.payroll_id
         and aa.assignment_action_id = :assignment_action_id';
      end if;
  else
     l_sql :=
     'select tp.period_name COL01
     ,fnd_date.date_to_displaydate(tp.end_date)   COL04
     ,fnd_date.date_to_displaydate(pa.effective_date) COL03
     ,fnd_date.date_to_displaydate(aa.start_date) COL05
     ,fnd_date.date_to_displaydate(aa.end_date)    COL06
     ,fnd_date.date_to_displaydate(tp.start_date)  COL02
     ,tp.period_type COL07
     from pay_payroll_actions pa
     ,per_time_periods tp
     ,pay_assignment_actions aa
     where pa.payroll_action_id = aa.payroll_action_id
     and pa.time_period_id = tp.time_period_id
     and aa.assignment_action_id = :assignment_action_id';
  end if;
   --
   --
   if g_debug then
     hr_utility.set_location('Leaving pay_soe_glb.Period', 20);
   end if;
   --
return l_sql;
end Period;
--
/* ---------------------------------------------------------------------
Function : getElements

Text
------------------------------------------------------------------------ */
function getElements(p_assignment_action_id number
                    ,p_element_set_name varchar2) return long is
begin
--
   --
   if g_debug then
     hr_utility.set_location('Entering pay_soe_glb.getElements', 10);
   end if;
   --
   -- Bugfix 5724212
   -- Return null if p_element_set_name is NULL (since the SQL statement below
   -- will not fetch any rows anyway).
   --
   if p_element_set_name is null then
     l_sql := null;
   else
   --
     l_sql := 'select /*+ ORDERED */ nvl(ettl.reporting_name,et.element_type_id) COL01
,         nvl(orginfo.org_information7,nvl(ettl.reporting_name, ettl.element_name)) COL02
,        to_char(sum(FND_NUMBER.CANONICAL_TO_NUMBER(rrv.result_value)),fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
,        decode(count(*),1,''1'',''2'') COL17 -- destination indicator,
,        decode(count(*),1,max(rr.run_result_id),max(et.element_type_id)) COL18
from pay_assignment_actions aa
,    pay_run_results rr
,    pay_run_result_values rrv
,    pay_input_values_f iv
,    pay_input_values_f_tl ivtl
,    pay_element_types_f et
,    pay_element_types_f_tl ettl
,   hr_organization_information orginfo
where aa.assignment_action_id :action_clause
and   aa.assignment_action_id = rr.assignment_action_id
and   rr.status in (''P'',''PA'')
and   rr.run_result_id = rrv.run_result_id
and   rr.element_type_id = et.element_type_id
and   :effective_date between
       et.effective_start_date and et.effective_end_date
and   et.element_type_id = ettl.element_type_id
and   rrv.input_value_id = iv.input_value_id
and   iv.name = ''Pay Value''
and   :effective_date between
       iv.effective_start_date and iv.effective_end_date
and   iv.input_value_id = ivtl.input_value_id
and   ettl.language = userenv(''LANG'')
and   ivtl.language = userenv(''LANG'')
and   iv.element_type_id = et.element_type_id
and   exists (select 1
              from   pay_element_set_members esm
                    ,pay_element_sets es
              where  et.element_type_id = esm.element_type_id
              and   iv.element_type_id = et.element_type_id
              and   esm.element_set_id = es.element_set_id
              and ( es.BUSINESS_GROUP_ID IS NULL
                 OR es.BUSINESS_GROUP_ID = :business_group_id )
              AND ( es.LEGISLATION_CODE IS NULL
                 OR es.LEGISLATION_CODE = '':legislation_code'')
              and   es.element_set_name = '''|| p_element_set_name ||''')
and   orginfo.org_information1 = ''ELEMENT''
and   orginfo.org_information_context = ''Business Group:SOE Detail''
and   orginfo.organization_id = :business_group_id
and   et.element_type_id (+)= to_number(orginfo.org_information2)
group by nvl(orginfo.org_information7,nvl(ettl.reporting_name, ettl.element_name))
, ettl.reporting_name
,nvl(ettl.reporting_name,et.element_type_id)
UNION ALL
select /*+ ORDERED */ nvl(ettl.reporting_name,et.element_type_id) COL01
,        nvl(ettl.reporting_name,ettl.element_name) COL02
,        to_char(sum(FND_NUMBER.CANONICAL_TO_NUMBER(rrv.result_value)),fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
,        decode(count(*),1,''1'',''2'') COL17 -- destination indicator,
,        decode(count(*),1,max(rr.run_result_id),max(et.element_type_id)) COL18
from pay_assignment_actions aa
,    pay_run_results rr
,    pay_run_result_values rrv
,    pay_input_values_f iv
,    pay_input_values_f_tl ivtl
,    pay_element_types_f et
,    pay_element_types_f_tl ettl
where aa.assignment_action_id :action_clause
and   aa.assignment_action_id = rr.assignment_action_id
and   rr.status in (''P'',''PA'')
and   rr.run_result_id = rrv.run_result_id
and   rr.element_type_id = et.element_type_id
and   :effective_date between
       et.effective_start_date and et.effective_end_date
and   et.element_type_id = ettl.element_type_id
and   rrv.input_value_id = iv.input_value_id
and   iv.name = ''Pay Value''
and   :effective_date between
       iv.effective_start_date and iv.effective_end_date
and   iv.input_value_id = ivtl.input_value_id
and   ettl.language = userenv(''LANG'')
and   ivtl.language = userenv(''LANG'')
and   iv.element_type_id = et.element_type_id
and   exists (select 1
              from   pay_element_set_members esm
                    ,pay_element_sets es
              where  et.element_type_id = esm.element_type_id
              and   iv.element_type_id = et.element_type_id
              and   esm.element_set_id = es.element_set_id
              and ( es.BUSINESS_GROUP_ID IS NULL
                 OR es.BUSINESS_GROUP_ID = :business_group_id)
              AND ( es.LEGISLATION_CODE IS NULL
                 OR es.LEGISLATION_CODE = '':legislation_code'')
              and   es.element_set_name = '''|| p_element_set_name ||''')
AND  not exists (select 1
		 from   hr_organization_information orginfo
                 WHERE  orginfo.org_information1 = ''ELEMENT''
                 and    orginfo.org_information_context = ''Business Group:SOE Detail''
                 and    orginfo.organization_id = :business_group_id
                 and    et.element_type_id = to_number(orginfo.org_information2))
group by nvl(ettl.reporting_name,ettl.element_name)
, ettl.reporting_name
,nvl(ettl.reporting_name,et.element_type_id)
order by COL02';

   --
   end if;
--
   --
   if g_debug then
     hr_utility.set_location('Leaving pay_soe_glb.getElements', 20);
   end if;
   --
return l_sql;
--
end getElements;
--
/* ---------------------------------------------------------------------
Function : getBalances

Text
------------------------------------------------------------------------ */
function getBalances(p_assignment_action_id number
                    ,p_balance_attribute varchar2) return long is
--
TYPE balance_type_lst_rec is RECORD (balance_name varchar2(80)
                                    ,reporting_name varchar2(80)
                                    ,dimension_name varchar2(80)
                                    ,defined_balance_name varchar2(80)
                                    ,defined_balance_id number);
TYPE balance_type_lst_tab is TABLE of balance_type_lst_rec
                             INDEX BY BINARY_INTEGER;
l_balance_type_lst balance_type_lst_tab;
--
l_effective_date date;
l_earliest_ctx_date date;
l_temp_date date;
l_action_sequence number;
l_payroll_id number;
l_assignment_id number;
l_business_group_id number;
l_legislation_code varchar2(30);
l_save_asg_run_bal varchar2(30);
l_inp_val_name  pay_input_values_f.name%type;
l_si_needed_chr varchar2(10);
l_st_needed_chr varchar2(10);
l_sn_needed_chr varchar2(10);
l_st2_needed_chr varchar2(10);
l_found boolean;
balCount number;
--
l_defined_balance_lst pay_balance_pkg.t_balance_value_tab;
l_context_lst         pay_balance_pkg.t_context_tab;
l_output_table        pay_balance_pkg.t_detailed_bal_out_tab;
--
i number;
--
--
cursor getAction is
select pa.payroll_id
,      aa.action_sequence
,      pa.effective_date
,      aa.assignment_id
,      pa.business_group_id
,      bg.legislation_code
,      lrl.rule_mode
from   pay_payroll_actions pa
,      pay_assignment_actions aa
,      per_business_groups bg
,      pay_legislation_rules lrl
where  aa.assignment_action_id = p_assignment_action_id
and    aa.payroll_action_id = pa.payroll_action_id
and    pa.business_group_id = bg.business_group_id
and    lrl.legislation_code(+) = bg.legislation_code
and    lrl.rule_type(+) = 'SAVE_ASG_RUN_BAL';
--
cursor getDBal is
select ba.defined_balance_id
,      bd.dimension_name
,      bd.period_type
,      bt.balance_name
,      bt.reporting_name
,      nvl(oi.org_information7,nvl(bt.reporting_name,bt.balance_name)) defined_balance_name
from   pay_balance_attributes ba
,      pay_bal_attribute_definitions bad
,      pay_defined_balances db
,      pay_balance_dimensions bd
,      pay_balance_types_tl bt
,      hr_organization_information oi
where  bad.attribute_name = p_balance_attribute
and ( bad.BUSINESS_GROUP_ID IS NULL
   OR bad.BUSINESS_GROUP_ID = l_business_group_id)
AND ( bad.LEGISLATION_CODE IS NULL
   OR bad.LEGISLATION_CODE = l_legislation_code)
and   bad.attribute_id = ba.attribute_id
and   ba.defined_balance_id = db.defined_balance_id
and   db.balance_dimension_id = bd.balance_dimension_id
and   db.balance_type_id = bt.balance_type_id
and   bt.language = userenv('LANG')
--
and   oi.org_information1 = 'BALANCE'
--
and   oi.org_information4 = to_char(bt.balance_type_id)
and   oi.org_information5 = to_char(db.balance_dimension_id)
--
and   oi.org_information_context = 'Business Group:SOE Detail'
and   oi.organization_id = l_business_group_id;
--
cursor getRBContexts is
select rb.TAX_UNIT_ID
,      rb.JURISDICTION_CODE
,      rb.SOURCE_ID
,      rb.SOURCE_TEXT
,      rb.SOURCE_NUMBER
,      rb.SOURCE_TEXT2
from pay_run_balances rb
,    pay_assignment_actions aa
,    pay_payroll_actions pa
where rb.ASSIGNMENT_ID = l_assignment_id
and   l_action_sequence >= aa.action_sequence
and   rb.assignment_action_id = aa.assignment_action_id
and   aa.payroll_action_id = pa.payroll_action_id
and   pa.effective_date >= l_earliest_ctx_date;
--
cursor getRRContexts is
select distinct
       aa.tax_unit_id                                       tax_unit_id
,      rr.jurisdiction_code                                 jurisdiction_code
,      decode(l_si_needed_chr,
              'Y', pay_balance_pkg.find_context('SOURCE_ID'
                                               ,rr.run_result_id)
                                               ,null)       source_id
,      decode(l_st_needed_chr,
              'Y', pay_balance_pkg.find_context('SOURCE_TEXT'
                                               ,rr.run_result_id)
                                               ,null)       source_text
,      decode(l_sn_needed_chr,
              'Y', pay_balance_pkg.find_context('SOURCE_NUMBER'
                                               ,rr.run_result_id)
                                               ,null)      source_number
,      decode(l_st2_needed_chr,
              'Y', pay_balance_pkg.find_context('SOURCE_TEXT2'
                                               ,rr.run_result_id)
                                               ,null)      source_text2
  from pay_assignment_actions aa,
       pay_payroll_actions    pa,
       pay_run_results        rr
 where   aa.ASSIGNMENT_ID = l_assignment_id
   and   aa.assignment_action_id = rr.assignment_action_id
   and   l_action_sequence >= aa.action_sequence
   and   aa.payroll_action_id = pa.payroll_action_id
   and   pa.effective_date >= l_earliest_ctx_date;
--
begin
   --
   if g_debug then
     hr_utility.set_location('Entering pay_soe_glb.getBalances', 10);
   end if;
   --
   open getAction;
   fetch getAction into l_payroll_id,
                        l_action_sequence,
                        l_effective_date,
                        l_assignment_id,
                        l_business_group_id,
                        l_legislation_code,
                        l_save_asg_run_bal;
   close getAction;
   --
   l_earliest_ctx_date := l_effective_date;
   --
   i := 0;
   --
   if g_debug then
     hr_utility.set_location('pay_soe_glb.getBalances', 20);
   end if;
   --
   for db in getDBal loop
       i := i + 1;
       --
       l_defined_balance_lst(i).defined_balance_id := db.defined_balance_id;
       --
       l_balance_type_lst(db.defined_balance_id).balance_name :=
                              db.balance_name;
       l_balance_type_lst(db.defined_balance_id).reporting_name :=
                              db.reporting_name;
       l_balance_type_lst(db.defined_balance_id).defined_balance_name:=
                              db.defined_balance_name;
       l_balance_type_lst(db.defined_balance_id).dimension_name :=
                              db.dimension_name;
       l_balance_type_lst(db.defined_balance_id).defined_balance_id :=
                              db.defined_balance_id;
       --
       pay_balance_pkg.get_period_type_start
               (p_period_type => db.period_type
               ,p_effective_date => l_effective_date
               ,p_payroll_id => l_payroll_id
               ,p_start_date => l_temp_date);
       --
       if l_temp_date < l_earliest_ctx_date then
          l_earliest_ctx_date := l_temp_date;
       end if;
   end loop;
   --
   i := 0;
   if l_save_asg_run_bal = 'Y' then
     if g_debug then
        hr_utility.set_location('pay_soe_glb.getBalances', 30);
      end if;
      for ctx in getRBContexts loop
          i := i + 1;
          l_context_lst(i).TAX_UNIT_ID := ctx.TAX_UNIT_ID;
          l_context_lst(i).JURISDICTION_CODE := ctx.JURISDICTION_CODE;
          l_context_lst(i).SOURCE_ID := ctx.SOURCE_ID;
          l_context_lst(i).SOURCE_TEXT := ctx.SOURCE_TEXT;
          l_context_lst(i).SOURCE_NUMBER := ctx.SOURCE_NUMBER;
          l_context_lst(i).SOURCE_TEXT2 := ctx.SOURCE_TEXT2;
      end loop;
   else
      if g_debug then
        hr_utility.set_location('pay_soe_glb.getBalances', 40);
      end if;
     -- Check whether the SOURCE_ID, SOURCE_TEXT contexts are used.
     l_si_needed_chr := 'N';
     l_st_needed_chr := 'N';
     l_sn_needed_chr := 'N';
     l_st2_needed_chr := 'N';
     --
     pay_core_utils.get_leg_context_iv_name('SOURCE_ID',
                                            l_legislation_code,
                                            l_inp_val_name,
                                            l_found);
     if (l_found = TRUE) then
      l_si_needed_chr := 'Y';
     end if;
     --
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT',
                                            l_legislation_code,
                                            l_inp_val_name,
                                            l_found);
     if (l_found = TRUE) then
      l_st_needed_chr := 'Y';
     end if;
     --
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER',
                                            l_legislation_code,
                                            l_inp_val_name,
                                            l_found);
     if (l_found = TRUE) then
      l_sn_needed_chr := 'Y';
     end if;
     --
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT2',
                                            l_legislation_code,
                                            l_inp_val_name,
                                            l_found);
     if (l_found = TRUE) then
      l_st2_needed_chr := 'Y';
     end if;
    --
    --
      for ctx in getRRContexts loop
          i := i + 1;
          l_context_lst(i).TAX_UNIT_ID := ctx.TAX_UNIT_ID;
          l_context_lst(i).JURISDICTION_CODE := ctx.JURISDICTION_CODE;
          l_context_lst(i).SOURCE_ID := ctx.SOURCE_ID;
          l_context_lst(i).SOURCE_TEXT := ctx.SOURCE_TEXT;
          l_context_lst(i).SOURCE_NUMBER := ctx.SOURCE_NUMBER;
          l_context_lst(i).SOURCE_TEXT2 := ctx.SOURCE_TEXT2;
      end loop;
   end if;
   --
   --
   if g_debug then
     hr_utility.set_location('pay_soe_glb.getBalances', 50);
   end if;
   --
   pay_balance_pkg.get_value (p_assignment_action_id => p_assignment_action_id
                             ,p_defined_balance_lst  => l_defined_balance_lst
                             ,p_context_lst          => l_context_lst
                             ,p_output_table         => l_output_table);
   --
    pay_soe_util.clear;
 --
 balCount := 0;
if l_output_table.count > 0 then
   --
   if g_debug then
     hr_utility.set_location('pay_soe_glb.getBalances', 60);
   end if;
   --
 for i in l_output_table.first..l_output_table.last loop
   if l_output_table(i).balance_value <> 0 then
     balCount := balCount + 1;
     --
     pay_soe_util.setValue('01'
 ,l_balance_type_lst(l_output_table(i).defined_balance_id).balance_name
           ,TRUE,FALSE);
     pay_soe_util.setValue('02'
 ,l_balance_type_lst(l_output_table(i).defined_balance_id).reporting_name
           ,FALSE,FALSE);
     pay_soe_util.setValue('03'
 ,l_balance_type_lst(l_output_table(i).defined_balance_id).dimension_name
           ,FALSE,FALSE);
     pay_soe_util.setValue('04'
 ,l_balance_type_lst(l_output_table(i).defined_balance_id).defined_balance_name
           ,FALSE,FALSE);
 pay_soe_util.setValue('05',
      hr_general.decode_organization(to_char(l_output_table(i).tax_unit_id))
                      ,FALSE,FALSE);
 pay_soe_util.setValue('06',to_char(l_output_table(i).tax_unit_id),FALSE,FALSE);


 pay_soe_util.setValue('07',l_output_table(i).jurisdiction_code,FALSE,FALSE);
 pay_soe_util.setValue('08',l_output_table(i).source_id,FALSE,FALSE);
 pay_soe_util.setValue('09',l_output_table(i).source_text,FALSE,FALSE);
 pay_soe_util.setValue('10',l_output_table(i).source_number,FALSE,FALSE);
 pay_soe_util.setValue('11',l_output_table(i).source_text2,FALSE,FALSE);

 pay_soe_util.setValue(16,to_char(l_output_table(i).balance_value,
                         fnd_currency.get_format_mask(substr(g_currency_code,2,3),40)),FALSE,FALSE);
 pay_soe_util.setValue(17,to_char(l_output_table(i).defined_balance_id),FALSE,TRUE);

   end if;
 end loop;
end if;
 --
 if balCount > 0 then
   return pay_soe_util.genCursor;
 else
   --
   -- Bugfix 5724212
   -- Return null since we are not fetching any rows.
   --
   return null;
   --
 end if;
end getBalances;
--
/* ---------------------------------------------------------------------
Function : getInformation

Text
------------------------------------------------------------------------ */
function getInformation(p_assignment_action_id number
                       ,p_element_set_name varchar2) return long is
begin
--
hr_utility.trace('in getInformation' || p_element_set_name || p_assignment_action_id);
   --
   -- Bugfix 7527825
   -- Added nvl(oi.org_information7, to COL02
   --
   --
   --
   -- Bugfix 5724212
   -- Return null if p_element_set_name is NULL (since the SQL statement below
   -- will not fetch any rows anyway).
   --
   if p_element_set_name is null then
     l_sql := null;
   else
   --
     l_sql :=
'select  distinct ettl.element_name COL01
,        nvl(oi.org_information7,nvl(ettl.reporting_name, ettl.element_name)) COL02      -- for BUG 3880887,7527825
,        ivtl.name COL03
,        rrv.result_value COL04
,        1  COL05  -- to indicate that we should drilldown directly to run_result_values
,        rr.run_result_id COL18
from pay_assignment_actions aa
,    pay_run_results rr
,    pay_run_result_values rrv
,    pay_input_values_f iv
,    pay_input_values_f_tl ivtl
,    pay_element_types_f et
,    pay_element_types_f_tl ettl
,    hr_organization_information oi
where aa.assignment_action_id :action_clause
and   aa.assignment_action_id = rr.assignment_action_id
and   rr.status in (''P'',''PA'')
and   rr.run_result_id = rrv.run_result_id
and   rr.element_type_id = et.element_type_id
and   rrv.input_value_id = iv.input_value_id
and   to_char(iv.input_value_id) = oi.org_information3
and   iv.input_value_id = ivtl.input_value_id
and   ivtl.language = userenv(''LANG'')
and   :effective_date between
       iv.effective_start_date and iv.effective_end_date
and   to_char(et.element_type_id) = oi.org_information2
and   :effective_date between
       et.effective_start_date and et.effective_end_date
and   et.element_type_id = ettl.element_type_id
and   ettl.language = userenv(''LANG'')
and   iv.element_type_id = et.element_type_id
and   exists (select 1
              from   pay_element_set_members esm
                   , pay_element_sets es
              where  et.element_type_id = esm.element_type_id
              and    iv.element_type_id = et.element_type_id
              and ( esm.BUSINESS_GROUP_ID IS NULL
                 OR esm.BUSINESS_GROUP_ID = :business_group_id)
              AND ( esm.LEGISLATION_CODE IS NULL
                 OR esm.LEGISLATION_CODE = '':legislation_code'')
              and   esm.element_set_id = es.element_set_id
              and ( es.BUSINESS_GROUP_ID IS NULL
                 OR es.BUSINESS_GROUP_ID = :business_group_id)
              AND ( es.LEGISLATION_CODE IS NULL
                 OR es.LEGISLATION_CODE =  '':legislation_code'' )
             and   es.element_set_name = ''' || p_element_set_name || ''' )
--
and   oi.org_information1 = ''ELEMENT''
--
and   oi.org_information_context = ''Business Group:SOE Detail''
and   oi.organization_id = :business_group_id';
   --
   end if;
--
return l_sql;
end getInformation;
--
/* ---------------------------------------------------------------------
Function : PrePayments

Text
------------------------------------------------------------------------ */
function PrePayments(p_assignment_action_id number) return long is
begin
l_sql :=
'select ORG_PAYMENT_METHOD_NAME COL01
,pt.payment_type_name COL04
,pay_soe_util.getBankDetails('':legislation_code''
                             ,ppm.external_account_id
                             ,''BANK_NAME''
                             ,null) COL02
,pay_soe_util.getBankDetails('':legislation_code''
                             ,ppm.external_account_id
                             ,''BANK_ACCOUNT_NUMBER''
                     ,fnd_profile.value(''HR_MASK_CHARACTERS'')) COL03
,to_char(pp.value,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
from pay_pre_payments pp
,    pay_personal_payment_methods_f ppm
,    pay_org_payment_methods_f opm
,    pay_payment_types_tl pt
where pp.assignment_action_id in
 (select ai.locking_action_id
  from   pay_action_interlocks ai
  where  ai.locked_action_id :action_clause)
and   pp.personal_payment_method_id = ppm.personal_payment_method_id(+)
and   :effective_date
  between ppm.effective_start_date(+) and ppm.effective_end_date(+)
and   pp.org_payment_method_id = opm.org_payment_method_id
and   :effective_date
  between opm.effective_start_date and opm.effective_end_date
and   opm.payment_type_id = pt.payment_type_id
and   pt.language = userenv(''LANG'')';
--
return l_sql;
end PrePayments;
--
/* ---------------------------------------------------------------------
Function : Message

Text
------------------------------------------------------------------------ */
function Message(p_assignment_action_id number) return long is
begin
 l_sql :=
'select distinct line_text COL01
 from pay_message_lines
 where source_id :action_clause';
--
  return l_sql;
end Message;
--
/* ---------------------------------------------------------------------
Function : Elements1

Text
------------------------------------------------------------------------ */
function Elements1(p_assignment_action_id number) return long is
begin
  hr_utility.trace('Entering elements1');
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS1'));
  hr_utility.trace('Leaving Elements1');
end Elements1;
--
/* ---------------------------------------------------------------------
Function : SetParameters
Function : Elements2

Text
------------------------------------------------------------------------ */
function Elements2(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS2'));
end Elements2;
--
/* ---------------------------------------------------------------------
Function : SetParameters
Function : Elements3

Text
------------------------------------------------------------------------ */
function Elements3(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS3'));
end Elements3;
--
/* ---------------------------------------------------------------------
Function : SetParameters
Function : Elements4

Text
------------------------------------------------------------------------ */
function Elements4(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS4'));
end Elements4;
--
/* ---------------------------------------------------------------------
Function : SetParameters
Function : Elements5

Text
------------------------------------------------------------------------ */
function Elements5(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS5'));
end Elements5;
--
/* ---------------------------------------------------------------------
Function : SetParameters
Function : Elements6

Text
------------------------------------------------------------------------ */
function Elements6(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS6'));
end Elements6;
--
/* ---------------------------------------------------------------------
Function : SetParameters
Function : Information1

Text
------------------------------------------------------------------------ */
function Information1(p_assignment_action_id number) return long is
begin
  hr_utility.trace('in Information1');
  return getInformation(p_assignment_action_id
                    ,pay_soe_util.getConfig('INFORMATION1'));
end Information1;
--
/* ---------------------------------------------------------------------
Function : Balances1

Text
------------------------------------------------------------------------ */
function Balances1(p_assignment_action_id number) return long is
begin
  return getBalances(p_assignment_action_id
                    ,pay_soe_util.getConfig('BALANCES1'));
end Balances1;
--
/* ---------------------------------------------------------------------
Function : Balances2

Text
------------------------------------------------------------------------ */
function Balances2(p_assignment_action_id number) return long is
begin
  return getBalances(p_assignment_action_id
                    ,pay_soe_util.getConfig('BALANCES2'));
end Balances2;
--
/* ---------------------------------------------------------------------
Function : Balances3

Text
------------------------------------------------------------------------ */
function Balances3(p_assignment_action_id number) return long is
begin
  return getBalances(p_assignment_action_id
                    ,pay_soe_util.getConfig('BALANCES3'));
end Balances3;
--
---------------------------------------------------------------------------
-- Function : get_retro_period,  taken from pynlgenr.pkb
-- Function returns the retro period for the given element_entry_id and
-- date_earned
---------------------------------------------------------------------------

function get_retro_period
        (    p_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             p_date_earned in pay_payroll_actions.date_earned%TYPE,
             p_call_type in integer  -- if 0 then return the period, 1 retro_start, 2 retro_end
        ) return varchar2 is

cursor c_get_creator_type(c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
                          c_date_earned in pay_payroll_actions.date_earned%TYPE
                         ) is
SELECT creator_type
FROM pay_element_entries_f pee
WHERE pee.element_entry_id=c_element_entry_id
and c_date_earned between pee.effective_start_date and pee.effective_end_date;


cursor get_retro_period_rr
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is

SELECT ptp.start_date
,ptp.end_date
,ptp.period_num || '/' || to_char(ptp.start_date,'YYYY')
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_run_results prr,
pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
and prr.run_result_id = pee.source_id
and paa.assignment_action_id=prr.assignment_action_id
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='RR'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;


cursor get_retro_period_nr
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is
SELECT ptp.start_date
,ptp.end_date
,ptp.period_num || '/' || to_char(ptp.start_date,'YYYY')
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_run_results prr,
pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
and prr.run_result_id = pee.source_id
and paa.assignment_action_id=prr.assignment_action_id
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='NR'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;


cursor get_retro_period_pr
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is
SELECT ptp.start_date
,ptp.end_date
,ptp.period_num || '/' || to_char(ptp.start_date,'YYYY')
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_run_results prr,
pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
and prr.run_result_id = pee.source_id
and paa.assignment_action_id=prr.assignment_action_id
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='PR'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;


cursor get_retro_period_ee
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is
SELECT ptp.start_date
,ptp.end_date
,ptp.period_num || '/' || to_char(ptp.start_date,'YYYY')
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_element_entries_f pee
WHERE pee.element_entry_id=c_element_entry_id
and  paa.assignment_action_id=pee.source_asg_action_id
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='EE'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;

l_creator_type pay_element_entries_f.creator_type%TYPE;
l_period_obtained_flag number;
l_retro_start_date date;
l_retro_end_date date;
l_period_num_year varchar2(30) :=null;


begin
l_period_obtained_flag:=1;
hr_utility.set_location('Entering: '||l_period_obtained_flag,1);

   OPEN  c_get_creator_type(p_element_entry_id,p_date_earned);
   FETCH c_get_creator_type INTO l_creator_type ;
   CLOSE c_get_creator_type;


   if l_creator_type = 'RR' then
     OPEN get_retro_period_rr(p_element_entry_id,p_date_earned);
     FETCH get_retro_period_rr into  l_retro_start_date,
                                     l_retro_end_date,
                                     l_period_num_year;
     CLOSE get_retro_period_rr;
     l_period_obtained_flag:=1;
   end if;

   if l_creator_type = 'NR' then
     OPEN get_retro_period_nr(p_element_entry_id,p_date_earned);
     FETCH get_retro_period_nr into l_retro_start_date,
                                    l_retro_end_date,
                                    l_period_num_year;
     CLOSE get_retro_period_nr;
     l_period_obtained_flag:=1;
   end if;

   if l_creator_type = 'PR' then
     OPEN get_retro_period_pr(p_element_entry_id,p_date_earned);
     FETCH get_retro_period_pr into l_retro_start_date,
                                    l_retro_end_date,
                                    l_period_num_year;
     CLOSE get_retro_period_pr;
     l_period_obtained_flag:=1;
   end if;

   if l_creator_type = 'EE' then
     OPEN get_retro_period_ee(p_element_entry_id,p_date_earned);
     FETCH get_retro_period_ee into l_retro_start_date,
                                    l_retro_end_date,
                                    l_period_num_year;
     CLOSE get_retro_period_ee;
     l_period_obtained_flag:=1;
   end if;

hr_utility.set_location('Entering element entry id: '||p_element_entry_id,4);
hr_utility.set_location('Entering start date earned : '||p_date_earned,5);
hr_utility.set_location('Entering period obtained flag: '||l_period_obtained_flag,6);

if p_call_type = 1 then
   return l_retro_start_date;
elsif p_call_type = 2 then
   return l_retro_end_date;
elsif p_call_type = 0 then
   return  l_period_num_year;
end if;
end get_retro_period;

end pay_soe_glb;

/
