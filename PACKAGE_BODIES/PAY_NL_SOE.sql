--------------------------------------------------------
--  DDL for Package Body PAY_NL_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_SOE" as
/* $Header: pynlsoer.pkb 120.3.12000000.2 2007/02/28 10:27:01 shmittal noship $ */
g_package  varchar2(33) := ' PAY_NL_SOE.';
l_sql long;
g_debug boolean := hr_utility.debug_enabled;
g_max_action number;
g_min_action number;


/* ---------------------------------------------------------------------
Function : Get_Spl_Tax_Ind

Text     : Returns the Concatenated Special Indicators Value
------------------------------------------------------------------------ */
function Get_Spl_Tax_Ind(p_spl_ind VARCHAR2) return varchar2 IS
	l_Special_Indicator VARCHAR2(32000);
	l_SPL_IND1   varchar2(2);
	l_SPL_IND2   varchar2(2);
	l_SPL_IND3   varchar2(2);
	l_SPL_IND4   varchar2(2);
	l_SPL_IND5   varchar2(2);
	l_SPL_IND6   varchar2(2);
	l_SPL_IND7   varchar2(2);
	l_SPL_IND8   varchar2(2);
	l_SPL_IND9   varchar2(2);
	l_SPL_IND10   varchar2(2);
	l_SPL_IND11   varchar2(2);
	l_SPL_IND12   varchar2(2);
	l_SPL_IND13   varchar2(2);


BEGIN
	--Fetch Split Special Indicators
	pay_nl_tax_pkg.get_spl_inds	(P_SPL_IND =>p_spl_ind
				,P_SPL_IND1=>l_SPL_IND1
				,P_SPL_IND2=>l_SPL_IND2
				,P_SPL_IND3=>l_SPL_IND3
				,P_SPL_IND4=>l_SPL_IND4
				,P_SPL_IND5=>l_SPL_IND5
				,P_SPL_IND6=>l_SPL_IND6
				,P_SPL_IND7=>l_SPL_IND7
				,P_SPL_IND8=>l_SPL_IND8
				,P_SPL_IND9=>l_SPL_IND9
				,P_SPL_IND10=>l_SPL_IND10
				,P_SPL_IND11=>l_SPL_IND11
				,P_SPL_IND12=>l_SPL_IND12
				,P_SPL_IND13=>l_SPL_IND13);
	--Conctenate the Individual Special Indicators concatenate to l_Special_Indicator
	IF l_SPL_IND1 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND1;
	END IF;
	IF l_SPL_IND2 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND2;
	END IF;
	IF l_SPL_IND3 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND3;
	END IF;
	IF l_SPL_IND4 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND4;
	END IF;
	IF l_SPL_IND5 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND5;
	END IF;
	IF l_SPL_IND6 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND6;
	END IF;
	IF l_SPL_IND7 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND7;
	END IF;
	IF l_SPL_IND8 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND8;
	END IF;
	IF l_SPL_IND9 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND9;
	END IF;
	IF l_SPL_IND10 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND10;
	END IF;
	IF l_SPL_IND11 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND11;
	END IF;
	IF l_SPL_IND12 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND12;
	END IF;
	IF l_SPL_IND13 IS NOT NULL THEN
		l_Special_Indicator := l_Special_Indicator||' '||l_SPL_IND13;
	END IF;
	return l_Special_Indicator;

EXCEPTION
	WHEN OTHERS THEN
		return l_Special_Indicator;
END;


/* ---------------------------------------------------------------------
Function : Tax_Info

Text     : Fetches Tax Information
------------------------------------------------------------------------ */
 FUNCTION Tax_Info(p_assignment_action_id NUMBER) RETURN LONG IS
  l_sql       LONG;
  l_defbal_id NUMBER;
  l_Travel_Allowance  NUMBER;
  l_Sea_Days_Discount  NUMBER;
  l_ABW_Allowance  NUMBER;
  l_ABW_Allowance_Stoppage  NUMBER;
  l_WAO_Allowance  NUMBER;
  l_ZVW_Contribution  NUMBER;
  l_sp_percentage_rate pay_run_result_values.result_value%TYPE;
  l_prev_tax_income pay_run_result_values.result_value%TYPE;
  l_Tax_Code pay_run_result_values.result_value%TYPE;
  l_Tax_Table varchar2(5000);
  l_Tax_Reduction varchar2(5000);
  l_Labour_Tax_Reduction varchar2(5000);
  l_Special_Indicators pay_run_result_values.result_value%TYPE;
  l_Senior_Tax_Reduction varchar2(5000);
  l_locked_assignment_action_id pay_action_interlocks.locked_action_id%TYPE;
  l_context_id NUMBER;

  CURSOR cur_spl_rate(lp_assignment_action_id NUMBER,
  lp_element_name VARCHAR2,lp_input_value_name VARCHAR2) IS
	select prrv.result_value
	from pay_run_result_values prrv,
	pay_run_results prr,
	pay_element_types_f pet,
	pay_input_values_f piv,
	pay_assignment_actions paa,
	pay_payroll_actions ppa
	where prrv.run_result_id = prr.run_result_id
	and paa.assignment_action_id=lp_assignment_action_id
	and prr.assignment_action_id = paa.assignment_action_id
	and paa.payroll_action_id= ppa.payroll_action_id
	and pet.element_type_id = piv.element_type_id
	and pet.element_name=lp_element_name
	and piv.name =lp_input_value_name
	and piv.input_value_id = prrv.input_value_id
        and pet.legislation_code = 'NL'
        and piv.legislation_code = 'NL'
	and ppa.date_earned between pet.effective_start_date and pet.effective_end_date
	and ppa.date_earned between piv.effective_start_date and piv.effective_end_date;

 cursor getLockedActionid is
  select max(locked_action_id) from pay_action_interlocks where locking_action_id = p_assignment_action_id;

 cursor get_context_id is
  select context_id from ff_contexts where context_name = 'SOURCE_TEXT';

 BEGIN
  --
  --
  -- Mapping....
  --
  -- COL16 : Special Tax Rate Percentage
  -- COL17 : Previous Year Taxable Income
  -- COL01 : Tax Code
  -- COL02 : Tax Table Colour
  -- COL03 : Tax Reduction
  -- COL07 : Labour Tax Reduction
  -- COL05 : Additional Senior Tax Reduction
  -- COL06 : Special Tax Indicators
  -- COL18 : Travel Allowance
  -- COL19 : Sea Days Discount
  -- COL20 : ABW Allowance
  -- COL21 : ABW Allowance Tax Stoppage
  -- COL22 : WAO Allowance
  -- COL23 : ZVW Contribution

  --Fetch locked assignment action id for prepayments
  open getLockedActionid;
     fetch getLockedActionid into l_locked_assignment_action_id;
     close getLockedActionid;
     if l_locked_assignment_action_id is null then
         l_locked_assignment_action_id := p_assignment_action_id;
     end if;
  --Fetch Special Tax Rate Percentage
  OPEN cur_spl_rate(l_locked_assignment_action_id,'Special Tax Deduction','Percentage Rate') ;
  FETCH cur_spl_rate INTO l_sp_percentage_rate;
  CLOSE cur_spl_rate;

  --Fetch Previous Year Taxable Income
  OPEN cur_spl_rate(l_locked_assignment_action_id,'Special Tax Deduction','Previous Year Taxable Income');
  FETCH cur_spl_rate INTO l_prev_tax_income;
  CLOSE cur_spl_rate;

  --Fetch Tax code
   OPEN cur_spl_rate(l_locked_assignment_action_id,'Standard Tax Deduction','Tax Code');
     FETCH cur_spl_rate INTO l_Tax_Code;
  CLOSE cur_spl_rate;

  --Fetch Tax Table Colour
  OPEN cur_spl_rate(l_locked_assignment_action_id,'Standard Tax Deduction','Tax Table');
       FETCH cur_spl_rate INTO l_Tax_Table;
    CLOSE cur_spl_rate;
  l_Tax_Table := hr_general.decode_lookup('NL_TAX_TABLE',l_Tax_Table);
  l_Tax_Table := replace(l_Tax_table,'''','||fnd_global.local_chr(39)');

  --Fetch Tax Reduction Flag
  OPEN cur_spl_rate(l_locked_assignment_action_id,'Standard Tax Deduction','Tax Reduction Flag');
       FETCH cur_spl_rate INTO l_Tax_Reduction;
    CLOSE cur_spl_rate;
    l_Tax_Reduction := hr_general.decode_lookup('HR_NL_REPORT_LABELS',l_Tax_Reduction);
    l_Tax_Reduction := replace(l_Tax_Reduction,'''','||fnd_global.local_chr(39)');

  --Fetch Labour Tax Reduction Flag
  OPEN cur_spl_rate(l_locked_assignment_action_id,'Standard Tax Deduction','Labour Tax Reduction Flag');
     FETCH cur_spl_rate INTO l_Labour_Tax_Reduction;
  CLOSE cur_spl_rate;
 l_Labour_Tax_Reduction := hr_general.decode_lookup('HR_NL_YES_NO',l_Labour_Tax_Reduction);
 l_Labour_Tax_Reduction := replace(l_Labour_Tax_Reduction,'''','||fnd_global.local_chr(39)');

   --Fetch Additional Senior Tax Reduction Flag
   OPEN cur_spl_rate(l_locked_assignment_action_id,'Standard Tax Deduction','Additional Senior Tax Flag');
        FETCH cur_spl_rate INTO l_Senior_Tax_Reduction;
     CLOSE cur_spl_rate;
 l_Senior_Tax_Reduction := hr_general.decode_lookup('HR_NL_YES_NO',l_Senior_Tax_Reduction);
 l_Senior_Tax_Reduction := replace(l_Senior_Tax_Reduction,'''','||fnd_global.local_chr(39)');

  --Fetch Special Tax Indicators
  OPEN cur_spl_rate(l_locked_assignment_action_id,'Standard Tax Deduction','Special Indicators');
       FETCH cur_spl_rate INTO l_Special_Indicators;
    CLOSE cur_spl_rate;

  l_sp_percentage_rate:= NVL(l_sp_percentage_rate,0);
  l_prev_tax_income:= NVL(l_prev_tax_income,0);
    -- Fetch Balances
  --
  l_defbal_id := PAY_NL_GENERAL.GET_DEFINED_BALANCE_ID('TAX_TRAVEL_ALLOWANCE_ASG_PTD');
  l_Travel_Allowance  := NVL(pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id),0);

  l_defbal_id := PAY_NL_GENERAL.GET_DEFINED_BALANCE_ID('TAX_SEA_DAYS_DISCOUNT_ASG_PTD');
  l_Sea_Days_Discount  := NVL(pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id),0);

  l_defbal_id := PAY_NL_GENERAL.GET_DEFINED_BALANCE_ID('TAX_ABW_ALLOWANCE_ASG_PTD');
  l_ABW_Allowance  := NVL(pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id),0);

  l_defbal_id := PAY_NL_GENERAL.GET_DEFINED_BALANCE_ID('TAX_ABW_ALLOWANCE_STOPPAGE_ASG_PTD');
  l_ABW_Allowance_Stoppage  := NVL(pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id),0);

  l_defbal_id := PAY_NL_GENERAL.GET_DEFINED_BALANCE_ID('TAX_WAO_ALLOWANCE_ASG_PTD');
  l_WAO_Allowance  := NVL(pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id),0);

  l_defbal_id := PAY_NL_GENERAL.GET_DEFINED_BALANCE_ID('EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_PTD');

  open get_context_id;
  fetch get_context_id into l_context_id;
  close get_context_id;
  l_ZVW_Contribution  := NVL(pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id, null, null, l_context_id, 'ZVW', null, null ),0);
  l_defbal_id := PAY_NL_GENERAL.GET_DEFINED_BALANCE_ID('EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_PTD');
  l_ZVW_Contribution  := l_ZVW_Contribution + NVL(pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id, null, null, l_context_id, 'ZVW', null, null ),0);
  l_defbal_id := PAY_NL_GENERAL.GET_DEFINED_BALANCE_ID('NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_PTD');
  l_ZVW_Contribution  := l_ZVW_Contribution + NVL(pay_balance_pkg.get_value(l_defbal_id, p_assignment_action_id, null, null, l_context_id, 'ZVW', null, null ),0);

  l_sql :=
  'SELECT TO_CHAR('||l_sp_percentage_rate|| ',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16 '||
	 ',TO_CHAR('||l_prev_tax_income||',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL17 '||
         ','''||l_Tax_Code||''' COL01 '||
	 ',REPLACE('''||l_Tax_Table||''',''||fnd_global.local_chr(39)'',fnd_global.local_chr(39)) COL02 '||
	 ',REPLACE('''||l_Tax_Reduction||''',''||fnd_global.local_chr(39)'',fnd_global.local_chr(39)) COL03 '||
	 ',REPLACE('''||l_Labour_Tax_Reduction||''',''||fnd_global.local_chr(39)'',fnd_global.local_chr(39)) COL07 '||
	 ',REPLACE('''||l_Senior_Tax_Reduction||''',''||fnd_global.local_chr(39)'',fnd_global.local_chr(39)) COL05 '||
	 ','''||l_Special_Indicators||''' COL06 ' ||
	 ',TO_CHAR('''||TO_CHAR(l_Travel_Allowance)||''',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL18 '
	 ||',TO_CHAR('''||TO_CHAR(l_Sea_Days_Discount)||''',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL19 '
	 ||',TO_CHAR('''||TO_CHAR(l_ABW_Allowance)||''',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL20 '
	 ||',TO_CHAR('''||TO_CHAR(l_ABW_Allowance_Stoppage)||''',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL21 '
	 ||',TO_CHAR('''||TO_CHAR(l_WAO_Allowance)||''',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL22 '
	 ||',TO_CHAR('''||TO_CHAR(l_ZVW_Contribution)||''',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL23 '||
           'FROM dual';
  --
  RETURN l_sql;
  --
 END tax_info;


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
'select  nvl(ettl.reporting_name,et.element_type_id) COL01
,        nvl(ettl.reporting_name,ettl.element_name) COL02
,               pay_nl_general.get_iv_run_result(rr.run_result_id,et.element_type_id,''SI Type Name'') COL03
,       decode(pay_nl_general.get_iv_run_result(rr.run_result_id,et.element_type_id,''SI Type Name''),null,'' '',
        '' and pay_nl_general.get_iv_run_result('' || max(rr.run_result_id) || '','' || max(et.element_type_id)
        || '','' || ''''''SI Type Name'''''' || '') ='' || ''pay_nl_general.get_iv_run_result(run_result_id,element_type_id,''
        || ''''''SI Type Name'''''' || '')'')  COL04
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
and   ivtl.language = userenv(''LANG'')
and   ettl.language = userenv(''LANG'')
and   et.element_type_id = esm.element_type_id
and   esm.element_set_id = es.element_set_id
and ( es.BUSINESS_GROUP_ID IS NULL
   OR es.BUSINESS_GROUP_ID = :business_group_id )
AND ( es.LEGISLATION_CODE IS NULL
   OR es.LEGISLATION_CODE = '':legislation_code'' )
and   es.element_set_name = '''|| p_element_set_name ||'''
group by nvl(ettl.reporting_name,ettl.element_name)
, ettl.reporting_name
,pay_nl_general.get_iv_run_result(rr.run_result_id,et.element_type_id,''SI Type Name'')
,nvl(ettl.reporting_name,et.element_type_id)
order by nvl(ettl.reporting_name,ettl.element_name),nvl(ettl.reporting_name,et.element_type_id)';
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
Function : Elements2

Text     :Returns the SQL for the Deductions Region of the SOE
------------------------------------------------------------------------ */
function Elements2(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS2'));
end Elements2;


/* ---------------------------------------------------------------------
Function : getBalances

Text     : Constructs the SQL for the Balances and YTD Values Region of SOE
           similar to Core Function - pay_soe_glb.getBalances
           Only difference-Returns SI Type Name by calling
           pay_nl_general.get_sit_type_name
------------------------------------------------------------------------ */
function getBalances(p_assignment_action_id number
                    ,p_balance_attribute varchar2) return long is
--
TYPE balance_type_lst_rec is RECORD (balance_name pay_balance_types.balance_name%TYPE
				    ,balance_type_id pay_balance_types.balance_type_id%TYPE
                                    ,reporting_name pay_balance_types.reporting_name%TYPE
                                    ,dimension_name pay_balance_dimensions.dimension_name%TYPE
                                    ,defined_balance_name pay_balance_types.reporting_name%TYPE
                                    ,defined_balance_id pay_defined_balances.defined_balance_id%TYPE);
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
locked_assignment_action_id pay_action_interlocks.locked_action_id%TYPE;
--
l_defined_balance_lst pay_balance_pkg.t_balance_value_tab;
l_context_lst         pay_balance_pkg.t_context_tab;
l_output_table        pay_balance_pkg.t_detailed_bal_out_tab;
--
i number;
--
--
/* bug 4253982 */
cursor getAsgActions(l_assignment_action_id number,l_eff_date date) is
select paa.assignment_action_id from
	pay_assignment_actions paa,
	pay_payroll_actions ppa
where  paa.assignment_id =
       ( select assignment_id
         from   pay_assignment_actions
         where  assignment_action_id = l_assignment_action_id
       )
and    paa.action_status = 'C'
and    paa.assignment_action_id < l_assignment_action_id
and    paa.payroll_action_id = ppa.payroll_action_id
and    ppa.date_earned >= trunc(l_eff_date,'Y')
order by paa.assignment_action_id desc;

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
,      bt.balance_type_id
,      NVL(NVL(oi.org_information7,bt.reporting_name),bt.balance_name) defined_balance_name
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
and   oi.organization_id = l_business_group_id
order by NVL(LPAD(oi.ORG_INFORMATION8,15,0),0),NVL(NVL(oi.org_information7,bt.reporting_name),bt.balance_name);
--
cursor getRBContexts is
select rb.TAX_UNIT_ID
,      rb.JURISDICTION_CODE
,      rb.SOURCE_ID
,      rb.SOURCE_TEXT
,      rb.SOURCE_NUMBER
,      rb.SOURCE_TEXT2
from pay_run_balances rb
where rb.ASSIGNMENT_ID = l_assignment_id
and   l_action_sequence >= rb.action_sequence
and   rb.effective_date >= l_earliest_ctx_date;
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
l_si_type_name pay_run_result_values.result_value%TYPE;
--
cursor getLockedActionid is
  select max(locked_action_id) from pay_action_interlocks where locking_action_id = p_assignment_action_id;
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
  open getLockedActionid;
     fetch getLockedActionid into locked_assignment_action_id;
     close getLockedActionid;
     if locked_assignment_action_id is null then
         locked_assignment_action_id := p_assignment_action_id;
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
       l_balance_type_lst(db.defined_balance_id).balance_type_id :=
                              db.balance_type_id;
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
 l_si_type_name := NULL;
 IF l_output_table(i).source_text IS NOT NULL THEN
 	l_si_type_name := pay_nl_general.get_sit_type_name(l_balance_type_lst(l_output_table(i).defined_balance_id).balance_type_id
 	,locked_assignment_action_id,l_effective_date,l_output_table(i).source_text);

	/* Bug 4253982 */
	IF l_si_type_name IS NULL THEN

		FOR l_asg_actions in getAsgActions(locked_assignment_action_id,l_effective_date) loop

		l_si_type_name := pay_nl_general.get_sit_type_name(l_balance_type_lst(l_output_table(i).defined_balance_id).balance_type_id
		,l_asg_actions.assignment_action_id,l_effective_date,l_output_table(i).source_text);
		IF l_si_type_name IS NOT NULL THEN
		  EXIT;
		END IF;
		END LOOP;
	END IF;
	/* end Bug 4253982 */
 END IF;
 pay_soe_util.setValue('12',l_si_type_name,FALSE,FALSE);
 pay_soe_util.setValue(16,to_char(l_output_table(i).balance_value,
                         fnd_currency.get_format_mask(substr(PAY_SOE_GLB.g_currency_code,2,3),40)),FALSE,FALSE);
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

/* ---------------------------------------------------------------------
Function : Balances1

Text     : Displays the Balances in the Balances Region
------------------------------------------------------------------------ */
function Balances1(p_assignment_action_id number) return long is
begin
  return getBalances(p_assignment_action_id
                    ,pay_soe_util.getConfig('BALANCES1'));
end Balances1;
--
/* ---------------------------------------------------------------------
Function : Balances2

Text     : Displays the Balances in the YTD Values Region
------------------------------------------------------------------------ */
function Balances2(p_assignment_action_id number) return long is
begin
  return getBalances(p_assignment_action_id
                    ,pay_soe_util.getConfig('BALANCES2'));
end Balances2;
END PAY_NL_SOE;

/
