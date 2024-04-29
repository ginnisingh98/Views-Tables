--------------------------------------------------------
--  DDL for Package Body PAY_PL_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_SOE" as
/* $Header: pyplsoep.pkb 120.0 2005/10/14 03:53:12 mseshadr noship $ */

l_sql long;
g_debug boolean := hr_utility.debug_enabled;

function employee(p_assignment_action_id in number)
					   return long is
begin


l_sql := 'select papf.full_name        COL01,
                 papf.employee_number COL02, /* Employee Number */
                 pay_pl_utility.pay_pl_nip_format(papf.PER_INFORMATION1) COL03, /* NIP */
                 pap.name        COL04,   /* Position */
                 papf.national_identifier COL05,  /* PESEL */
                 hr_general.decode_lookup(''PL_CONTRACT_CATEGORY'',haaf.segment3)         COL07,	    /* Contract Category */
                 hr_general.decode_lookup(decode(haaf.segment3,''NORMAL'',''PL_CONTRACT_TYPE_NORMAL'',''CIVIL'',
                                                ''PL_CONTRACT_TYPE_CIVIL''),haaf.segment4)      COL08,      /* Contract Type */
                 hou.name          COL09,  /* Organization Name */
                 hr_general.decode_lookup(''NATIONALITY'',papf.nationality)         COL11,  /* Nationality */
                 hr_general.decode_lookup(''PL_CITIZENSHIP'',papf.per_information8)  COL12   /* Citizenship */
           from  per_all_people_f papf,
                 per_all_assignments_f paaf,
                 hr_soft_coding_keyflex haaf,
                 hr_organization_units hou,
                 per_all_positions pap
           where paaf.payroll_id = :payroll_id and
                :effective_date between papf.effective_start_date and papf.effective_end_date and
                :effective_date between paaf.effective_start_date and paaf.effective_end_date and
                 paaf.assignment_id = :assignment_id and
                 paaf.business_group_id = :business_group_id and
                 papf.business_group_id = :business_group_id and
                 papf.person_id = paaf.person_id and
                 haaf.SOFT_CODING_KEYFLEX_ID = paaf.soft_coding_keyflex_id and
                 hou.organization_id = paaf.organization_id and
                 pap.position_id (+) = paaf.position_id';


return l_sql;
end employee;

-- This function is used in the Tax Information region of the SOE
function tax_information(p_assignment_action_id in number)
					   return long is
begin

l_sql := 'select payroll.payroll_name  COL01,  /* Payroll Name */
                 hou1.name COL02, /* Tax Office */
                 hr_general.decode_lookup(''PL_OLDAGE_PENSION_RIGHTS'',papf.per_information4) COL03, /* Old Age/Pension Rights */
                 case to_char(trunc(trunc(months_between(:effective_date,papf.date_of_birth)/12)/16))
                     when ''0'' then hr_general.decode_lookup(''PL_DISABILITY_CATEGORY'',4)
                     else hr_general.decode_lookup(''PL_DISABILITY_CATEGORY'',nvl(pdf.dis_category,0))  end COL04, /*Disability Code */
                 hr_general.decode_lookup(decode(paye.contract_category,''CIVIL'',''PL_CIVIL_RATE_OF_TAX''
                                                                                 ,''PL_NORMAL_RATE_OF_TAX''),paye.rate_of_tax)    COL05,   /* Rate of Tax */
                 hr_general.decode_lookup(''PL_INCOME_REDUCTION'',paye.income_reduction)  COL06, /* Income Reduction */
                 hr_general.decode_lookup(''PL_TAX_REDUCTION'',paye.tax_reduction)    COL07,  /* Tax Reduction */
                 hr_general.decode_lookup(''YES_NO'',paye.tax_calc_with_spouse_child) COL08,   /* Tax Calculation with Spouse/Child */
                 sii.emp_social_security_info COL09  /* SII Code */
            from pay_all_payrolls_f payroll,
                 hr_organization_units hou1,
                 per_all_people_f      papf,
                 per_all_assignments_f paaf,
                 (select max(CATEGORY) dis_category
                     from per_disabilities_f
                    where person_id =
                         (select person_id from per_all_assignments_f where assignment_id = :ASSIGNMENT_ID and rownum = 1)
                      and :effective_date between effective_start_date and effective_end_date )pdf,
                 pay_pl_sii_details_f sii,
                 per_assignment_status_types past,
                 pay_pl_paye_details_f paye,
                 hr_soft_coding_keyflex keyflex
           where payroll.payroll_id = :payroll_id and
                 paaf.assignment_id = :assignment_id and
                 paaf.person_id = papf.person_id and
                 :effective_date between papf.effective_start_date and papf.effective_end_date and
                 :effective_date between paaf.effective_start_date and paaf.effective_end_date and
                 papf.per_information6 = hou1.organization_id and
                 keyflex.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id and
                 decode(keyflex.segment3,
                                    ''CIVIL'',:assignment_id,
                                                     decode(past.per_system_status,''TERM_ASSIGN'',:assignment_id,papf.person_id)) = sii.per_or_asg_id and
                :effective_date between sii.effective_start_date and sii.effective_end_date and
                 decode(keyflex.segment3,
                                    ''CIVIL'',:assignment_id,
                                                     decode(past.per_system_status,''TERM_ASSIGN'',:assignment_id,papf.person_id)) = paye.per_or_asg_id and
                :effective_date between paye.effective_start_date and paye.effective_end_date and
                sii.business_group_id = :business_group_id and
                paye.business_group_id = :business_group_id and
                past.assignment_status_type_id = paaf.assignment_status_type_id';

return l_sql;

end tax_information;

/* ---------------------------------------------------------------------
Function : getElements
Usage: This is the function used in Earnings/Deductions region.
       This function checks the value present in the profile PAY: PL Statement of Earnings Display Zero
       and displays elements with a zero Pay Value if the profile is set to 'Yes'.
       If the profile is set to 'No' then elements with a zero Pay Value are not displayed.
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
if fnd_profile.value('PAY_PL_SOE_ELEMENTS_DISPLAY') = 'Y' then

l_sql :=
'select /*+ ORDERED */ nvl(ettl.reporting_name,et.element_type_id) COL01
,        nvl(ettl.reporting_name,ettl.element_name) COL02
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
and   ettl.language = userenv(''LANG'')
and   ivtl.language = userenv(''LANG'')
and   et.element_type_id = esm.element_type_id
and   esm.element_set_id = es.element_set_id
and ( es.BUSINESS_GROUP_ID IS NULL
   OR es.BUSINESS_GROUP_ID = :business_group_id )
AND ( es.LEGISLATION_CODE IS NULL
   OR es.LEGISLATION_CODE = '':legislation_code'' )
and   es.element_set_name = '''|| p_element_set_name ||'''
group by nvl(ettl.reporting_name,ettl.element_name)
, ettl.reporting_name
,nvl(ettl.reporting_name,et.element_type_id)
order by nvl(ettl.reporting_name,ettl.element_name)';
--
elsif fnd_profile.value('PAY_PL_SOE_ELEMENTS_DISPLAY') = 'N' then

l_sql :=
'select /*+ ORDERED */ nvl(ettl.reporting_name,et.element_type_id) COL01
,        nvl(ettl.reporting_name,ettl.element_name) COL02
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
and   ettl.language = userenv(''LANG'')
and   ivtl.language = userenv(''LANG'')
and   et.element_type_id = esm.element_type_id
and   esm.element_set_id = es.element_set_id
and ( es.BUSINESS_GROUP_ID IS NULL
   OR es.BUSINESS_GROUP_ID = :business_group_id )
AND ( es.LEGISLATION_CODE IS NULL
   OR es.LEGISLATION_CODE = '':legislation_code'' )
and   es.element_set_name = '''|| p_element_set_name ||'''
and rrv.result_value <> ''0''
group by nvl(ettl.reporting_name,ettl.element_name)
, ettl.reporting_name
,nvl(ettl.reporting_name,et.element_type_id)
order by nvl(ettl.reporting_name,ettl.element_name)';
--


end if;
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
Function : Elements1
Usage: This function is called from the Earnings region (Region5 of SOE)
------------------------------------------------------------------------ */
function Elements1(p_assignment_action_id number) return long is
begin
  hr_utility.trace('Entering elements1');
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS1'));
  hr_utility.trace('Leaving Elements1');
end Elements1;

/* ---------------------------------------------------------------------
Function : SetParameters
Usage: This function is called from the Deductions region (Region6 of SOE)
------------------------------------------------------------------------ */
function Elements2(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS2'));
end Elements2;
--
end pay_pl_soe;

/
