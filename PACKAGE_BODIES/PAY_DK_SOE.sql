--------------------------------------------------------
--  DDL for Package Body PAY_DK_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_SOE" AS
/* $Header: pydksoe.pkb 120.0.12000000.2 2007/03/05 09:43:17 nprasath noship $ */
   --
   --
g_debug boolean := hr_utility.debug_enabled;
-----------------------------------------------------------------------------------------
-- function for fetching the Legal Entity CVR Number or Pension Provider

FUNCTION get_cvr_or_pension
( p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
  p_effective_date IN Date,
  p_org_information_context IN VARCHAR2 )
return VARCHAR2

IS
l_cvr_number NUMBER;
l_pension_provider VARCHAR2(240);
l_return_value VARCHAR2(240);

BEGIN
    BEGIN

	IF p_org_information_context = 'DK_LEGAL_ENTITY_DETAILS'
	 THEN
	   	OPEN pay_dk_soe.csr_get_cvr_number (p_assignment_id,p_effective_date);
		FETCH pay_dk_soe.csr_get_cvr_number INTO l_cvr_number;

		IF pay_dk_soe.csr_get_cvr_number%NOTFOUND
	     THEN l_cvr_number := NULL;
	    END IF;

		CLOSE pay_dk_soe.csr_get_cvr_number;
		l_return_value := to_char(l_cvr_number);

	ELSIF p_org_information_context = 'DK_PENSION_PROVIDER_DETAILS'
	 THEN
	   	OPEN pay_dk_soe.csr_get_pension_provider (p_assignment_id,p_effective_date);
		FETCH pay_dk_soe.csr_get_pension_provider INTO l_pension_provider;

	    IF pay_dk_soe.csr_get_pension_provider%NOTFOUND
	     THEN l_pension_provider := NULL;
	    END IF;

		CLOSE pay_dk_soe.csr_get_pension_provider;
		l_return_value := l_pension_provider;

	END IF;

    END;

RETURN l_return_value;

END get_cvr_or_pension;
-----------------------------------------------------------------------------------------

-- function for fetching the Union Membership

FUNCTION get_union_membership
( p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
  p_effective_date IN Date )
return varchar2

IS
l_union_membership varchar2(240);
BEGIN
    BEGIN

        select lkp.meaning
        into l_union_membership
        from per_all_assignments_f  asg
            ,hr_soft_coding_keyflex scl
            ,hr_lookups  lkp
        where lkp.lookup_type = 'DK_UNION_MEMBERSHIP'
        and lkp.lookup_code = scl.segment5
        and lkp.enabled_flag = 'Y'
        and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
        and p_effective_date between asg.effective_start_date and effective_end_date
        and asg.assignment_id = p_assignment_id;

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
         l_union_membership := NULL;

    END;

RETURN l_union_membership;

END get_union_membership;


-----------------------------------------------------------------------------------------

-- function for fetching the Bank Registration Number

FUNCTION get_bank_reg_number
(p_external_account_id IN NUMBER)
return varchar2

IS
l_bank_reg_number varchar2(240);
BEGIN
    BEGIN

	  IF p_external_account_id = NULL

		THEN
		        l_bank_reg_number := NULL;

		ELSE
		        select pea.segment1
        		into l_bank_reg_number
		        from pay_external_accounts	pea
		        where pea.external_account_id=p_external_account_id;

	  END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
         l_bank_reg_number := NULL;

    END;

RETURN l_bank_reg_number;

END get_bank_reg_number;

-----------------------------------------------------------------------------------------

/* Function : Employee

Returns SQL string for retrievening Employee information based on
assignment ID and effective date derived from the assignment action ID
passed onto the SOE module
------------------------------------------------------------------------ */
function Employee(p_assignment_action_id in number) return long is
--
l_sql long;
begin

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
        ,peo.FIRST_NAME COL14
        ,peo.MIDDLE_NAMES COL15
        ,peo.LAST_NAME COL16
        ,nvl(pay_dk_soe.get_cvr_or_pension(:assignment_id,:effective_date,''DK_LEGAL_ENTITY_DETAILS''), '''')  COL17
        ,nvl(pay_dk_soe.get_cvr_or_pension(:assignment_id,:effective_date,''DK_PENSION_PROVIDER_DETAILS''), '''')  COL18
        ,nvl(pay_dk_soe.get_union_membership(:assignment_id,:effective_date), '''')  COL19
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
return l_sql;
--
end Employee;
-----------------------------------------------------------------------------------------


/* Function : Period

 Returns Payroll Period Information
------------------------------------------------------------------------ */
function Period(p_assignment_action_id in number) return long is
--
l_sql long;
l_action_type varchar2(2);
cursor periodDates is
select action_type from
        pay_payroll_actions pa
,       per_time_periods tp
,       pay_assignment_actions aa
where   pa.payroll_action_id = aa.payroll_action_id
and     pa.effective_date = tp.regular_payment_date
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
         ,fnd_date.date_to_displaydate(tp1.DEFAULT_DD_DATE)  COL08
	 	 from pay_payroll_actions pa1
         ,pay_payroll_actions pa2
	     ,per_time_periods tp1
         ,per_time_periods tp2
	     ,pay_assignment_actions aa1
         ,pay_assignment_actions aa2
	 	 where pa1.payroll_action_id = aa1.payroll_action_id
	 	 and pa1.effective_date = tp1.regular_payment_date
		 and pa1.payroll_id = tp1.payroll_id
	 	 and aa1.assignment_action_id = :PREPAY_MAX_ACTION
         and pa2.payroll_action_id = aa2.payroll_action_id
         and pa2.effective_date = tp2.regular_payment_date
         and pa2.payroll_id = tp2.payroll_id
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
         ,fnd_date.date_to_displaydate(tp.DEFAULT_DD_DATE)  COL08
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
     ,fnd_date.date_to_displaydate(tp.DEFAULT_DD_DATE)  COL08
     from pay_payroll_actions pa
     ,per_time_periods tp
     ,pay_assignment_actions aa
     where pa.payroll_action_id = aa.payroll_action_id
     and pa.time_period_id = tp.time_period_id
     and aa.assignment_action_id = :assignment_action_id';
  end if;
   --

return l_sql;
end Period;
--

-----------------------------------------------------------------------------------------

/* Function : PrePayments

  Returns Payment Information
------------------------------------------------------------------------ */
function PrePayments(p_assignment_action_id number) return long is
--
l_sql long;
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
,nvl(pay_dk_soe.get_bank_reg_number(ppm.external_account_id), '''') COL05
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

/* Added for Pension changes */

/* ---------------------------------------------------------------------
Function : get_pp_name

Returns Pension Provider Name to be appended in Pension elements' names
------------------------------------------------------------------------ */


function get_pp_name(p_effective_date date
                    ,p_run_result_id number)
                     return varchar2 is

 /* Changes made to to_number used in csr_get_pp_name */
cursor csr_get_pp_name(p_effective_date date ,p_run_result_id number) is
select hou.name
from
     pay_run_result_values rrv
,    pay_input_values_f iv
,    hr_organization_units hou
where rrv.run_result_id = p_run_result_id
and   rrv.input_value_id = iv.input_value_id
and   iv.name = 'Third Party Payee'
and   p_effective_date between
       iv.effective_start_date and iv.effective_end_date
and   hou.organization_id = FND_NUMBER.CANONICAL_TO_NUMBER(rrv.result_value)
and   p_effective_date between hou.date_from and nvl(hou.date_to, p_effective_date);

rec_get_pp_name  csr_get_pp_name%rowtype;

begin

open csr_get_pp_name(p_effective_date, p_run_result_id);
fetch csr_get_pp_name into rec_get_pp_name;
close csr_get_pp_name;

return  rec_get_pp_name.name;

end  get_pp_name;




/* ---------------------------------------------------------------------
Function : getElements

Returns Element Information
------------------------------------------------------------------------ */
function getElements(p_assignment_action_id number
                    ,p_element_set_name varchar2)
		    return long is
l_sql long;

begin
--

l_sql :=
'select /*+ ORDERED */ nvl(ettl.reporting_name,et.element_type_id) COL01
,        nvl(ettl.reporting_name,ettl.element_name)||
                     decode( nvl(ettl.reporting_name,ettl.element_name)
		            ,''Pension'', '' ( ''||pay_dk_soe.get_pp_name(:effective_date,max(rr.run_result_id))||'' )''
		            ,''Employer Pension'', '' ( ''||pay_dk_soe.get_pp_name(:effective_date,max(rr.run_result_id))||'' )''
		            ,''Retro Pension'', '' ( ''||pay_dk_soe.get_pp_name(:effective_date,max(rr.run_result_id))||'' )''
		            ,''Retro Employer Pension'','' ( ''||pay_dk_soe.get_pp_name(:effective_date,max(rr.run_result_id))||'' )'') COL02
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
/*Changed for Pension provider break up */
,        nvl(ettl.reporting_name,ettl.element_name)||
                     decode( nvl(ettl.reporting_name,ettl.element_name)
		            ,''Pension'', '' ( ''||pay_dk_soe.get_pp_name(:effective_date,rr.run_result_id)||'' )''
		            ,''Employer Pension'', '' ( ''||pay_dk_soe.get_pp_name(:effective_date,rr.run_result_id)||'' )''
		            ,''Retro Pension'', '' ( ''||pay_dk_soe.get_pp_name(:effective_date,rr.run_result_id)||'' )''
		            ,''Retro Employer Pension'','' ( ''||pay_dk_soe.get_pp_name(:effective_date,rr.run_result_id)||'' )'')
order by nvl(ettl.reporting_name,ettl.element_name)';



return l_sql;
--
end getElements;
--

/* ---------------------------------------------------------------------
Function : SetParameters
Function : Elements1

Text
------------------------------------------------------------------------ */
function Elements1(p_assignment_action_id number) return long is
begin
  return getElements(p_assignment_action_id
                    ,pay_soe_util.getConfig('ELEMENTS1'));
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

/* Added for display of Pension Provider balances */

/* ---------------------------------------------------------------------
Function : getBalances

Text : Modified version of pay_dk_soe.getBalances with ORG_ID support
and customized display of values for Pension Provider balances in DK.
------------------------------------------------------------------------ */
function getBalances(p_assignment_action_id number
		    ) return long is
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

/* Added for display of Pension Provider balances */
l_org_needed_chr  varchar2(10);
--
l_defined_balance_lst pay_balance_pkg.t_balance_value_tab;
l_context_lst         pay_balance_pkg.t_context_tab;
l_output_table        pay_balance_pkg.t_detailed_bal_out_tab;
--
i number;
/* Added for display of Pension Provider balances */
j number;
temp pay_balance_pkg.t_detailed_bal_out_tab;
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

/* Modified for display of Pension Provider balances */
cursor getDBal is
select db.defined_balance_id
,      bd.dimension_name
,      bd.period_type
,      bt.balance_name
,      bt.reporting_name
,      nvl(bt.reporting_name,bt.balance_name) defined_balance_name
from
       pay_defined_balances db
,      pay_balance_dimensions bd
,      pay_balance_types_tl bt
where db.balance_dimension_id = bd.balance_dimension_id
and   db.balance_type_id = bt.balance_type_id
and   bt.language = userenv('LANG')
and   bd.legislation_code ='DK'
and   bd.database_item_suffix IN ('_PP_ASG_PTD','_PP_ASG_YTD','_PP_PAYMENTS');
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
/* Added for display of Pension Provider balances */
,      decode(l_org_needed_chr,
              'Y', pay_balance_pkg.find_context('ORGANIZATION_ID'
                                               ,rr.run_result_id)
                                               ,null)      organization_id
  from pay_assignment_actions aa,
       pay_payroll_actions    pa,
       pay_run_results        rr
 where   aa.ASSIGNMENT_ID = l_assignment_id
   and   aa.assignment_action_id = rr.assignment_action_id
   and   l_action_sequence >= aa.action_sequence
   and   aa.payroll_action_id = pa.payroll_action_id
   and   pa.effective_date >= l_earliest_ctx_date;

/* Added for display of Pension Provider balances */

CURSOR csr_get_org_name( p_org_id number) IS
SELECT name
FROM hr_organization_units
WHERE organization_id =	p_org_id ;

l_org_name VARCHAR(80);

CURSOR csr_get_params( p_assignment_action_id NUMBER)  IS
    SELECT ''''  || bg.currency_code || '''' currency_code
    FROM   pay_payroll_actions      pa
    ,      pay_assignment_actions   aa
    ,      per_business_groups      bg
    WHERE  aa.assignment_action_id  = p_assignment_action_id
    AND    aa.payroll_action_id     = pa.payroll_action_id
    AND    pa.business_group_id     = bg.business_group_id
    AND    rownum                   = 1;

rec_get_params	csr_get_params%ROWTYPE;


--
begin
   --

   if g_debug then
     hr_utility.set_location('Entering pay_dk_soe.getBalances', 10);
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
     hr_utility.set_location('pay_dk_soe.getBalances', 20);
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
        hr_utility.set_location('pay_dk_soe.getBalances', 30);
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
        hr_utility.set_location('pay_dk_soe.getBalances', 40);
      end if;
     -- Check whether the SOURCE_ID, SOURCE_TEXT contexts are used.
     l_si_needed_chr := 'N';
     l_st_needed_chr := 'N';
     l_sn_needed_chr := 'N';
     l_st2_needed_chr := 'N';
     /* Added for display of Pension Provider balances */
     l_org_needed_chr :='N';
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
     /* Added for display of Pension Provider balances */
     pay_core_utils.get_leg_context_iv_name('ORGANIZATION_ID',
                                            l_legislation_code,
                                            l_inp_val_name,
                                            l_found);
     if (l_found = TRUE) then
      l_org_needed_chr := 'Y';
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
          /* Added for display of Pension Provider balances */
          l_context_lst(i).ORGANIZATION_ID := ctx.ORGANIZATION_ID;
      end loop;
   end if;
   --
   --
   if g_debug then
     hr_utility.set_location('pay_dk_soe.getBalances', 50);
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
     hr_utility.set_location('pay_dk_soe.getBalances', 60);
   end if;
   --

 /* Sort the data in PL/SQL table according to organization_id */
 for i in l_output_table.first..l_output_table.last loop
   for j in l_output_table.first..l_output_table.last-i loop
      if(l_output_table(j).organization_id > l_output_table(j+1).organization_id) then
         temp(i) := l_output_table(j);
	 l_output_table(j) := l_output_table(j+1);
	 l_output_table(j+1) := temp(i);
      end if;
   end loop;
 end loop;

 for i in l_output_table.first..l_output_table.last loop
   if l_output_table(i).balance_value <> 0 then
     balCount := balCount + 1;

     /* Added for display of Pension Provider balances */
     OPEN  csr_get_org_name(l_output_table(i).organization_id);
     FETCH csr_get_org_name INTO l_org_name;
     CLOSE csr_get_org_name;

     OPEN csr_get_params(p_assignment_action_id);
     FETCH csr_get_params INTO rec_get_params;
     CLOSE csr_get_params;

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

 /* Added for display of Pension Provider balances */
 pay_soe_util.setValue('12',l_output_table(i).organization_id,FALSE,FALSE);
 pay_soe_util.setValue('13',l_org_name,FALSE,FALSE);

 pay_soe_util.setValue(16,to_char(l_output_table(i).balance_value,
                         fnd_currency.get_format_mask(substr(rec_get_params.currency_code,2,3),40)),FALSE,FALSE);
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


   --
   -- End of the Package

END pay_dk_soe;

/
