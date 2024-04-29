--------------------------------------------------------
--  DDL for Package Body PAY_SA_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SA_SOE" AS
/* $Header: pysasoer.pkb 120.1.12000000.2 2007/06/29 06:37:27 spendhar noship $ */
/*Function to pick up Reference Salary*/
 FUNCTIOn get_reference_salary (p_effective_date	DATE
			       ,p_assignment_action_id NUMBER) RETURN NUMBER IS
  l_defbal_id NUMBER;
  l_balvalue  NUMBER;
  l_lower_base VARCHAR2(10);
  l_upper_base VARCHAR2(10);
/* Cursor to fetch lower limit of gosi base*/
	CURSOR get_lower_base(l_effective_date DATE) IS
	SELECT global_value
	FROM   ff_globals_f
	WHERE  global_name = 'SA_GOSI_BASE_LOWER_LIMIT'
	AND    legislation_code = 'SA'
	AND    business_group_id IS NULL
	AND    l_effective_date BETWEEN effective_start_date
		                    AND effective_end_date;
/* Cursor to fetch upper limit of gosi base*/
	CURSOR get_upper_base(l_effective_date DATE) IS
	SELECT global_value
	FROM   ff_globals_f
	WHERE  global_name = 'SA_GOSI_BASE_UPPER_LIMIT'
	AND    legislation_code = 'SA'
	AND    business_group_id IS NULL
	AND    l_effective_date BETWEEN effective_start_date
		                    AND effective_end_date;
BEGIN
  --
  l_defbal_id :=
PAY_SA_ARCHIVE.GET_DEFINED_BALANCE_ID('GOSI_REFERENCE_EARNINGS_ASG_YTD');
  l_balvalue  := pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id);
	OPEN get_lower_base(p_effective_date);
	  FETCH get_lower_base INTO l_lower_base;
	CLOSE get_lower_base;
	OPEN get_upper_base(p_effective_date);
	  FETCH get_upper_base INTO l_upper_base;
	CLOSE get_upper_base;
	IF(l_balvalue  > to_number(l_upper_base)) THEN
		l_balvalue  := to_number(l_upper_base);
	ELSIF(l_balvalue  < to_number(l_lower_base)) THEN
		l_balvalue  := to_number(l_lower_base);
	END IF;
	return l_balvalue;
END;
/*Function to pick up GOSI information */
 FUNCTION gosi_info(p_assignment_action_id NUMBER) RETURN LONG IS
  l_sql       LONG;
 BEGIN
  --
  -- Mapping....
  --
  -- COL02 : GOSI No
  -- COL03 : Pay annuities
  -- COL04 : Annuities branch joining date
  -- COL05 : Pay hazards
  -- COL06 : Hazards branch joining date
  -- COL07 : GOSI Reference Earnings
  --
  l_sql :=
  'SELECT scl.segment2 COL02
         ,hr_general.decode_lookup(''YES_NO'', scl.segment3) COL03
         ,fnd_date.date_to_displaydate(fnd_date.canonical_to_date(scl.segment4))
COL04
         ,hr_general.decode_lookup(''YES_NO'', scl.segment5) COL05
         ,fnd_date.date_to_displaydate(fnd_date.canonical_to_date(scl.segment6))
COL06 '
  ||   ' ,TO_CHAR(TO_CHAR(pay_sa_soe.get_reference_salary(:effective_date,
:assignment_action_id)),fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL07
' ||
  'FROM   per_all_assignments_f  asg
         ,hr_soft_coding_keyflex scl
   WHERE  asg.assignment_id = :assignment_id
     AND  :effective_date BETWEEN asg.effective_start_date
                              AND asg.effective_end_date
     AND  scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id';
  --
  RETURN l_sql;
  --
 END gosi_info;
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
    ,hl.meaning          COL10
		,asg.assignment_number COL11
		,hl1.meaning ||'' ''|| peo.full_name    COL12
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
  and hl.lookup_type (+) =''NATIONALITY''
  and hl.lookup_code (+) =peo.nationality
  and hl1.application_id (+) = 800
  and hl1.lookup_type (+)=''TITLE''
  and hl1.lookup_code (+)=peo.title';
return l_sql;
end employees;
-----------------------------------------------------------------------------
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
l_rr_processed	varchar2(1);
l_GOSI_ele_id	number;
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
,      nvl(oi.org_information7,nvl(bt.reporting_name,bt.balance_name))
defined_balance_name
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
cursor getGOSIele IS
SELECT element_type_id
FROM  pay_element_types_f
WHERE element_name = 'GOSI'
and   legislation_code = 'SA';
--
cursor getRRstatus(l_ele_id number) IS
SELECT status
FROM pay_run_results rr
WHERE  rr.assignment_action_id = p_assignment_action_id
AND    rr.element_type_id = l_ele_id;
begin
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
   	OPEN getGOSIele;
   	FETCH getGOSIele into l_GOSI_ele_id;
   	CLOSE getGOSIele;
   	OPEN getRRstatus(l_GOSI_ele_id);
   	FETCH getRRstatus into l_rr_processed;
   	CLOSE getRRstatus;
	/* Following OR condition added for GOSI element check to display the
 * balances correctly */
   	If nvl(l_rr_processed,'*') <> 'P' then
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
---------------------------------------------------------------------
function Balances(p_assignment_action_id number) return long is
begin
  return getBalances(p_assignment_action_id
                    ,pay_soe_util.getConfig('BALANCES1'));
end Balances;
---------------------------------------------------------------------
END pay_sa_soe;


/
