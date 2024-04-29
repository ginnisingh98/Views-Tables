--------------------------------------------------------
--  DDL for Package Body PAY_AE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AE_SOE" AS
/* $Header: pyaesoer.pkb 120.5.12010000.2 2010/01/04 09:38:19 bkeshary ship $ */

/*Function to pick up employee details*/

 FUNCTION employees(p_assignment_action_id NUMBER) RETURN LONG IS
  l_sql       LONG;
 BEGIN
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
        ,hl.meaning	COL10
	  ,asg.assignment_number COL11
 	  ,hl1.meaning ||'' ''|| peo.full_name    COL12
        , decode(peo.per_information3,peo.per_information3,peo.per_information3||'' '',null) || decode(peo.per_information4,peo.per_information4,peo.per_information4||'' '',null)
           || decode(peo.per_information5,peo.per_information5,peo.per_information5||'' '',null) || decode(peo.per_information6,peo.per_information6,peo.per_information6||'' '',null)  COL14
        from   per_all_people_f             peo
        ,per_all_assignments_f        asg
        ,hr_all_organization_units_vl org
        ,per_jobs_vl                  job
        ,per_all_positions            pos
        ,hr_locations                 loc
        ,per_grades_vl                grd
        ,pay_payrolls_f               pay
        ,pay_people_groups            pg
    ,hr_lookups					  hl
    ,hr_lookups					  hl1
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
    and :effective_date
  between org.date_from and nvl(org.date_to, :effective_date)
  and hl.application_id (+) = 800
  and hl.lookup_type (+) =''AE_NATIONALITY''
  and hl.lookup_code (+) =peo.per_information18
  and hl1.application_id (+) = 800
  and hl1.lookup_type (+)=''TITLE''
  and hl1.lookup_code (+)=peo.title';
return l_sql;
end employees;
--

function getBalances(p_assignment_action_id number
                    ,p_balance_attribute varchar2) return long is
--
TYPE balance_type_lst_rec is RECORD (balance_name varchar2(80)
                                    ,reporting_name varchar2(80)
                                    ,dimension_name varchar2(80)
                                    ,defined_balance_name varchar2(80)
                                    ,defined_balance_id number
                                    , meaning_uom varchar2(100));
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
l_balance_uom varchar2(40);
l_meaning_uom varchar2(100);
l_currency_code varchar2(100);
balCount number;
--
l_defined_balance_lst pay_balance_pkg.t_balance_value_tab;
l_context_lst         pay_balance_pkg.t_context_tab;
l_output_table        pay_balance_pkg.t_detailed_bal_out_tab;
--
i number;

l_nat varchar2(80);
l_local_nat  varchar2(80);
--
l_rr_processed	varchar2(1);
l_si_ele_id	number;
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
--
cursor getParameters(c_assignment_action_id in number) is
select ''''  || bg.currency_code || '''' currency_code
from   pay_payroll_actions pa
,      pay_assignment_actions aa
,      per_business_groups bg
where  aa.assignment_action_id = p_assignment_action_id
and    aa.payroll_action_id = pa.payroll_action_id
and    pa.business_group_id = bg.business_group_id
and rownum = 1;
--
cursor getDBal is
select ba.defined_balance_id
,      bd.dimension_name
,      bd.period_type
,      bt.balance_name
,      bt.reporting_name
,      nvl(oi.org_information7,nvl(bt.reporting_name,bt.balance_name)) defined_balance_name
,      pbt.balance_uom
,      hl.meaning
from   pay_balance_attributes ba
,      pay_bal_attribute_definitions bad
,      pay_defined_balances db
,      pay_balance_dimensions bd
,      pay_balance_types_tl bt
,      hr_organization_information oi
,      pay_balance_types pbt
,      hr_lookups hl
where  bad.attribute_name = p_balance_attribute
and ( bad.BUSINESS_GROUP_ID IS NULL
   OR bad.BUSINESS_GROUP_ID = l_business_group_id)
AND ( bad.LEGISLATION_CODE IS NULL
   OR bad.LEGISLATION_CODE = l_legislation_code)
and   bad.attribute_id = ba.attribute_id
and   ba.defined_balance_id = db.defined_balance_id
and   db.balance_dimension_id = bd.balance_dimension_id
and   db.balance_type_id = bt.balance_type_id
and   db.balance_type_id = pbt.balance_type_id
and   pbt.balance_type_id = bt.balance_type_id
and   bt.language = userenv('LANG')
and   oi.org_information1 = 'BALANCE'
and   oi.org_information4 = to_char(bt.balance_type_id)
and   oi.org_information5 = to_char(db.balance_dimension_id)
and   oi.org_information_context = 'Business Group:SOE Detail'
and   oi.organization_id = l_business_group_id
and   hl.lookup_type='UNITS'
and   hl.lookup_code = pbt.balance_uom;
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
cursor getNationality IS
SELECT  person.per_information18
FROM	per_all_people_f person, per_all_assignments_f asg
WHERE	person.person_id = asg.person_id
AND	asg.assignment_id = l_assignment_id
AND	trunc(l_effective_date,'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
AND     trunc(l_effective_date,'MM') between trunc(person.effective_start_date,'MM') and person.effective_end_date;
--
cursor getLocalNat IS
SELECT	org_information1
FROM	HR_ORGANIZATION_INFORMATION
WHERE	ORG_INFORMATION_CONTEXT = 'AE_BG_DETAILS'
AND	ORGANIZATION_ID = l_business_group_id;
--

--
cursor getSIele IS
SELECT element_type_id
FROM  pay_element_types_f
WHERE element_name = 'Social Insurance'
and   legislation_code = 'AE';
--
cursor getRRstatus(l_ele_id number) IS
SELECT status
FROM pay_run_results rr
WHERE  rr.assignment_action_id = p_assignment_action_id
AND    rr.element_type_id = l_ele_id;
--
begin


	 l_nat := null;
	 l_local_nat  := null;
	 l_rr_processed := null;

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
   open getParameters(p_assignment_action_id);
   fetch getParameters into l_currency_code;
   close getParameters;
   --
   i := 0;
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
       l_balance_type_lst(db.defined_balance_id).meaning_uom:=
                              db.meaning;
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


   	OPEN getLocalNat;
   	FETCH getLocalNat INTO l_local_nat;
   	CLOSE getLocalNat;

   	OPEN getNationality;
   	FETCH getNationality INTO l_nat;
   	CLOSE getNationality;

   	OPEN getSIele;
   	FETCH getSIele into l_si_ele_id;
   	CLOSE getSIele;

   	OPEN getRRstatus(l_si_ele_id);
   	FETCH getRRstatus into l_rr_processed;
   	CLOSE getRRstatus;

	/* Following OR condition added for SI element check to display the balances correctly */

   	If l_local_nat <> l_nat OR nvl(l_rr_processed,'*') <> 'P' then
   	/*Logic for non-UAE national */
   	        l_si_needed_chr := 'N';
	        l_st_needed_chr := 'N';
	        l_sn_needed_chr := 'N';
	        l_st2_needed_chr := 'N';

      		for ctx in getRRContexts loop
        		  i := i + 1;
        		  l_context_lst(i).TAX_UNIT_ID := ctx.TAX_UNIT_ID;
        		  l_context_lst(i).JURISDICTION_CODE := ctx.JURISDICTION_CODE;
        		  l_context_lst(i).SOURCE_ID := ctx.SOURCE_ID;
        		  l_context_lst(i).SOURCE_TEXT := ctx.SOURCE_TEXT;
        		  l_context_lst(i).SOURCE_NUMBER := ctx.SOURCE_NUMBER;
        		  l_context_lst(i).SOURCE_TEXT2 := ctx.SOURCE_TEXT2;
      		end loop;
	Else

      	   for ctx in getRBContexts loop
   	       i := i + 1;
   	       l_context_lst(i).TAX_UNIT_ID := ctx.TAX_UNIT_ID;
   	       l_context_lst(i).JURISDICTION_CODE := ctx.JURISDICTION_CODE;
   	       l_context_lst(i).SOURCE_ID := ctx.SOURCE_ID;
   	       l_context_lst(i).SOURCE_TEXT := ctx.SOURCE_TEXT;
   	       l_context_lst(i).SOURCE_NUMBER := ctx.SOURCE_NUMBER;
   	       l_context_lst(i).SOURCE_TEXT2 := ctx.SOURCE_TEXT2;
   	   end loop;

   	End If;

   else
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
   pay_balance_pkg.get_value (p_assignment_action_id => p_assignment_action_id
                             ,p_defined_balance_lst  => l_defined_balance_lst
                             ,p_context_lst          => l_context_lst
                             ,p_output_table         => l_output_table);
   --
    pay_soe_util.clear;
 --
 balCount := 0;
if l_output_table.count > 0 then
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
 pay_soe_util.setValue('15',l_balance_type_lst(l_output_table(i).defined_balance_id).meaning_uom,FALSE,FALSE);
 pay_soe_util.setValue(16,to_char(l_output_table(i).balance_value,
                         fnd_currency.get_format_mask(substr(l_currency_code,2,3),40)),FALSE,FALSE);
 pay_soe_util.setValue(17,to_char(l_output_table(i).defined_balance_id),FALSE,TRUE);
   end if;
 end loop;
end if;
 --
 if balCount > 0 then
   return pay_soe_util.genCursor;
 else
   return ('select null COL01 from dual where 1=0');
   --return null;
 end if;
end getBalances;
--
function Balances(p_assignment_action_id number) return long is
begin
  return getBalances(p_assignment_action_id
                    ,pay_soe_util.getConfig('BALANCES1'));
end Balances;
---------------------------------------------------------------------
FUNCTION period (p_assignment_action_id NUMBER) RETURN LONG IS
--
l_sql Long;
--
l_action_type varchar2(2);
cursor periodDates is
select action_type from
        pay_payroll_actions pa
,       per_time_periods tp
,       pay_assignment_actions aa
where   pa.payroll_action_id = aa.payroll_action_id
--and     pa.effective_date = tp.regular_payment_date
and   pa.date_earned between tp.start_date and tp.end_date /* 9178309 */
and     pa.payroll_id = tp.payroll_id
and     aa.assignment_action_id = p_assignment_action_id;
begin
   open periodDates;
   fetch periodDates into l_action_type;
   close periodDates;
   if l_action_type is not null then
      if l_action_type in ( 'P','U' ) then
         l_sql :=
         'select tp1.period_name || '' - '' ||  tp2.period_name COL01
         ,fnd_date.date_to_displaydate(tp1.end_date)   COL04
 	 ,fnd_date.date_to_displaydate(pa2.effective_date) COL03
 	 ,fnd_date.date_to_displaydate(aa1.start_date) COL05
 	 ,fnd_date.date_to_displaydate(aa2.end_date)    COL06
	 ,fnd_date.date_to_displaydate(tp1.start_date)  COL02
         ,tp1.period_type COL07
	, ppf.payroll_name COL10
	 from pay_payroll_actions pa1
            ,pay_payroll_actions pa2
	    ,per_time_periods tp1
            ,per_time_periods tp2
	    ,pay_assignment_actions aa1
            ,pay_assignment_actions aa2
		,pay_all_payrolls_f ppf
	 where pa1.payroll_action_id = aa1.payroll_action_id
 	 --and pa1.effective_date = tp1.regular_payment_date
	 and pa1.payroll_id = tp1.payroll_id
	 and pa1.date_earned between tp1.start_date and tp1.end_date /* 9178309 */
       and pa1.payroll_id = ppf.payroll_id
       and pa1.effective_date between ppf.effective_start_date and ppf.effective_end_date
 	 and aa1.assignment_action_id = :PREPAY_MAX_ACTION
         and pa2.payroll_action_id = aa2.payroll_action_id
         --and pa2.effective_date = tp2.regular_payment_date
         and pa2.payroll_id = tp2.payroll_id
	 and pa2.date_earned between tp2.start_date and tp2.end_date /* 9178309 */
         and aa2.assignment_action_id = :PREPAY_MIN_ACTION';
      else
         l_sql :=
         'select tp.period_name COL01
         ,fnd_date.date_to_displaydate(tp.end_date)   COL04
         ,fnd_date.date_to_displaydate(pa.effective_date) COL03
         ,fnd_date.date_to_displaydate(aa.start_date) COL05
         ,fnd_date.date_to_displaydate(aa.end_date)    COL06
         ,fnd_date.date_to_displaydate(tp.start_date)  COL02
         ,tp.period_type COL07
	   ,ppf.payroll_name COL10
         from pay_payroll_actions pa
         ,per_time_periods tp
         ,pay_assignment_actions aa
	  , pay_all_payrolls_f ppf
         where pa.payroll_action_id = aa.payroll_action_id
         --and pa.effective_date = tp.regular_payment_date
         and pa.payroll_id = tp.payroll_id
	 and pa.date_earned between tp.start_date and tp.end_date /* 9178309 */
         and pa.payroll_id = ppf.payroll_id
         and pa.effective_date between ppf.effective_start_date and ppf.effective_end_date
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
     ,ppf.payroll_name COL10
     from pay_payroll_actions pa
     ,per_time_periods tp
     ,pay_assignment_actions aa
     ,pay_all_payrolls_f ppf
     where pa.payroll_action_id = aa.payroll_action_id
     and pa.payroll_id = ppf.payroll_id
     and pa.effective_date between ppf.effective_start_date and ppf.effective_end_date
     --and pa.time_period_id = tp.time_period_id
     and pa.payroll_id = tp.payroll_id           /* 9178309 */
     and pa.date_earned between tp.start_date and tp.end_date /* 9178309 */
     and aa.assignment_action_id = :assignment_action_id';
  end if;
   --
return l_sql;
end Period;
--------------------------------------------------------------------
FUNCTION ae_loan_type (p_assignment_action_id NUMBER, p_run_result_id NUMBER , p_effective_date date)
  RETURN VARCHAR2 IS
  CURSOR csr_loan_type IS
	  SELECT hr_general.decode_lookup('AE_LOAN_TYPE',result_value)
	  FROM   pay_run_results         rr
		 ,pay_run_result_values  rrv
		 ,pay_input_values_f     iv
		 ,pay_input_values_f_tl  ivt
		 ,pay_element_types_f    et
		 ,pay_element_types_f_tl ettl
	  WHERE  rr.element_type_id = et.element_type_id
	  AND    iv.input_value_id = rrv.input_value_id
	  AND    iv.name = 'Loan Type'
	  AND    iv.legislation_code = 'AE'
	  AND    p_effective_date between
		 iv.effective_start_date and iv.effective_end_date
	  AND    iv.input_value_id = ivt.input_value_id
	  AND    iv.element_type_id = et.element_type_id
	  AND    p_effective_date between
		 et.effective_start_date and et.effective_end_date
	  AND    et.element_type_id = ettl.element_type_id
	  AND    et.element_name = 'Loan Recovery'
	  AND    et.legislation_code = 'AE'
	  AND    ivt.language = userenv('LANG')
	  AND    ettl.language = userenv('LANG')
	  AND    rr.assignment_action_id = p_assignment_action_id
	  AND    rr.status in ('P','PA')
	  AND    rr.run_result_id = rrv.run_result_id
	  AND    rr.run_result_id = p_run_result_id;
  l_loan_type  VARCHAR2(100);
BEGIN
  l_loan_type := null;
  OPEN csr_loan_type;
  FETCH csr_loan_type INTO l_loan_type;
  CLOSE csr_loan_type;
  IF l_loan_type IS NOT NULL THEN
    l_loan_type := ' '||l_loan_type;
  END IF;
  RETURN l_loan_type;
END ae_loan_type;
--------------------------------------------------------------------
function getElements(p_assignment_action_id number
                    ,p_element_set_name varchar2) return long is
l_sql LONG;
begin
--
l_sql :=
'select  nvl(ettl.reporting_name,et.element_type_id) COL01
,       nvl(ettl.reporting_name,ettl.element_name) || pay_ae_soe.ae_loan_type(rr.assignment_action_id ,rr.run_result_id,:effective_date  ) COL02
,        to_char(sum(FND_NUMBER.CANONICAL_TO_NUMBER(rrv.result_value)),fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
,        decode(count(*),1,''1'',''2'') COL17 -- destination indicator
,        decode(count(*),1,max(rr.run_result_id),max(et.element_type_id)) COL18
from pay_assignment_actions aa
,    pay_run_results rr
,    pay_run_result_values rrv
,    pay_input_values_f iv
,    pay_input_values_f_tl ivtl
,    pay_element_types_f et
,    pay_element_types_f_tl ettl
,    pay_element_set_members esm
,    pay_element_sets es
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
and   rrv.result_value is not null
and   ettl.language = userenv(''LANG'')
and   ivtl.language = userenv(''LANG'')
and   et.element_type_id = esm.element_type_id
and   esm.element_set_id = es.element_set_id
and ( es.BUSINESS_GROUP_ID IS NULL
   OR es.BUSINESS_GROUP_ID = :business_group_id )
AND ( es.LEGISLATION_CODE IS NULL
   OR es.LEGISLATION_CODE = '':legislation_code'' )
and   es.element_set_name = '''|| p_element_set_name ||'''
group by nvl(ettl.reporting_name,ettl.element_name) || pay_ae_soe.ae_loan_type(rr.assignment_action_id ,rr.run_result_id,:effective_date  )
, ettl.reporting_name
,nvl(ettl.reporting_name,et.element_type_id)
order by nvl(ettl.reporting_name,ettl.element_name) || pay_ae_soe.ae_loan_type(rr.assignment_action_id ,rr.run_result_id,:effective_date  )';
--
return l_sql;
--
end getElements;
--
------------------------------------------------------------------------
function Elements2(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS2'));
end Elements2;
------------------------------------------------------------------------
END pay_ae_soe;

/
