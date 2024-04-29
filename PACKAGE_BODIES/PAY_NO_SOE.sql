--------------------------------------------------------
--  DDL for Package Body PAY_NO_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_SOE" AS
/* $Header: pynosoe.pkb 120.0.12000000.1 2007/05/20 09:29:05 rlingama noship $ */
   --
   --
l_sql long;
g_debug boolean := hr_utility.debug_enabled;


/* ---------------------------------------------------------------------
Function : Elements1 (For the Earnings Section on the Norway SOE)

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
Function : getElements

Text
------------------------------------------------------------------------ */
function getElements(p_assignment_action_id number
                    ,p_element_set_name varchar2) return long is
begin
--
   --
   if g_debug then
     hr_utility.set_location('Entering pay_no_soe.getElements', 10);
   end if;
   --
   --
   if p_element_set_name is null then
     l_sql := null;
   else
   --

-- the sql statement below has been modfied for Norway SOE from the global SOE sql
-- added join with table pay_element_classifications to fetch the classification name
-- if the element classification is 'Earnings Adjustment', a negative value of rrv.result_value is taken
-- else the rrv.result_value is taken as it is

     l_sql :=
'select /*+ ORDERED */ nvl(ettl.reporting_name,et.element_type_id) COL01
,        nvl(ettl.reporting_name,ettl.element_name) COL02
,        to_char(sum(decode(ec.classification_name,
                            ''Earnings Adjustment''
			    ,( 0 - FND_NUMBER.CANONICAL_TO_NUMBER(rrv.result_value))
			    ,FND_NUMBER.CANONICAL_TO_NUMBER(rrv.result_value))
			    ),fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
,        decode(count(*),1,''1'',''2'') COL17 -- destination indicator
,        decode(count(*),1,max(rr.run_result_id),max(et.element_type_id)) COL18
from pay_assignment_actions aa
,    pay_run_results rr
,    pay_run_result_values rrv
,    pay_input_values_f iv
,    pay_input_values_f_tl ivtl
,    pay_element_types_f et
,    pay_element_types_f_tl ettl
,    pay_element_classifications ec
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
and   et.CLASSIFICATION_ID = ec.CLASSIFICATION_ID
and   exists (select 1
              from   pay_element_set_members esm
                    ,pay_element_sets es
              where  et.element_type_id = esm.element_type_id
              and   iv.element_type_id = et.element_type_id
              and   esm.element_set_id = es.element_set_id
              and ( es.BUSINESS_GROUP_ID IS NULL
                 OR es.BUSINESS_GROUP_ID = :business_group_id )
              AND ( es.LEGISLATION_CODE IS NULL
                 OR es.LEGISLATION_CODE = '':legislation_code'' )
              and   es.element_set_name = '''|| p_element_set_name ||''' )
group by nvl(ettl.reporting_name,ettl.element_name)
, ettl.reporting_name
,nvl(ettl.reporting_name,et.element_type_id)
order by nvl(ettl.reporting_name,ettl.element_name)';
   --
   end if;
--

  --
   if g_debug then
     hr_utility.set_location('Leaving pay_no_soe.getElements', 20);
   end if;
   --
return l_sql;
--
end getElements;
--


   -- End of the Package

END pay_no_soe;

/
