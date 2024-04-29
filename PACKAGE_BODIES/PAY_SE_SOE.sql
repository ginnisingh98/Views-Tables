--------------------------------------------------------
--  DDL for Package Body PAY_SE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_SOE" as
/* $Header: pysesoer.pkb 120.0 2005/05/29 08:37:54 appldev noship $ */
--
l_sql long;
g_debug boolean := hr_utility.debug_enabled;
g_max_action number;
g_min_action number;

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
l_sql :=
'select /*+ ORDERED */ nvl(ettl.reporting_name,et.element_type_id) COL01
,        nvl(ettl.reporting_name,ettl.element_name) COL02
,        hoi.org_information2 COL03
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
,    hr_organization_information hoi
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
and hoi.organization_id = :business_group_id
and hoi.org_information_context (+)=''SE_SOE_ELEMENT_ADD_DETAILS''
and nvl(hoi.org_information1,et.element_type_id) = et.element_type_id
group by nvl(ettl.reporting_name,ettl.element_name)
, ettl.reporting_name, hoi.org_information2
,nvl(ettl.reporting_name,et.element_type_id)
order by nvl(ettl.reporting_name,ettl.element_name)';
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
Function : getInformation

Text
------------------------------------------------------------------------ */
function getInformation(p_assignment_action_id number
                       ,p_element_set_name varchar2) return long is
begin
--
hr_utility.trace('in getInformation' || p_element_set_name || p_assignment_action_id);
l_sql :=
'select  distinct ettl.element_name COL01
,        nvl(ettl.reporting_name, ettl.element_name) COL02      -- for BUG 3880887
,        ivtl.name COL03
,        rrv.result_value COL04
,        1  COL05  -- to indicate that we should drilldown directly to run_result_values
,        hoi.org_information2 COL06
,        rr.run_result_id COL18
from pay_assignment_actions aa
,    pay_run_results rr
,    pay_run_result_values rrv
,    pay_input_values_f iv
,    pay_input_values_f_tl ivtl
,    pay_element_types_f et
,    pay_element_types_f_tl ettl
,    pay_element_set_members esm
,    pay_element_sets es
,    hr_organization_information oi
,    hr_organization_information hoi
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
and   et.element_type_id = esm.element_type_id
and ( esm.BUSINESS_GROUP_ID IS NULL
   OR esm.BUSINESS_GROUP_ID = :business_group_id)
AND ( esm.LEGISLATION_CODE IS NULL
   OR esm.LEGISLATION_CODE = '':legislation_code'')
and   esm.element_set_id = es.element_set_id
and ( es.BUSINESS_GROUP_ID IS NULL
   OR es.BUSINESS_GROUP_ID = :business_group_id)
AND ( es.LEGISLATION_CODE IS NULL
   OR es.LEGISLATION_CODE =  '':legislation_code'' )
and   es.element_set_name = ''' || p_element_set_name || '''
--
and   oi.org_information1 = ''ELEMENT''
--
and   oi.org_information_context = ''Business Group:SOE Detail''
and   oi.organization_id = :business_group_id
and   hoi.organization_id = :business_group_id
and   hoi.org_information_context (+)=''SE_SOE_ELEMENT_ADD_DETAILS''
and   nvl(hoi.org_information1,et.element_type_id) = et.element_type_id';
--
return l_sql;
end getInformation;
--
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

end pay_se_soe;

/
