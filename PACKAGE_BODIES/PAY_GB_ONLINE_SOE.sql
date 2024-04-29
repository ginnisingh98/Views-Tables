--------------------------------------------------------
--  DDL for Package Body PAY_GB_ONLINE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_ONLINE_SOE" as
/* $Header: pygbsoer.pkb 120.3 2006/05/04 07:50 kthampan noship $ */

g_package  varchar2(33) := ' PAY_GB_ONLINE_SOE.';

------------------------------------------------------------------------
--- Function : checkPrePayment
---
--- Text : check for pre payment
------------------------------------------------------------------------
FUNCTION checkPrepayment(p_assignment_action_id number) return number is
  l_action_type          varchar2(1);
  l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;
  --
  cursor csr_get_action_type is
  select pact.action_type
  from   pay_assignment_actions assact,
         pay_payroll_actions pact
  where  assact.assignment_action_id = p_assignment_action_id
  and    pact.payroll_action_id = assact.payroll_action_id;
  --
  cursor csr_get_latest_interlocked is
  select assact.assignment_action_id
  from   pay_assignment_actions assact,
         pay_action_interlocks loc
  where  loc.locking_action_id = p_assignment_action_id
  and    assact.assignment_action_id = loc.locked_action_id
  order by assact.action_sequence desc;
BEGIN
    -- get the action type
    open csr_get_action_type;
    fetch csr_get_action_type into l_action_type;
    close csr_get_action_type;

    if l_action_type in ('P', 'U') then
       open  csr_get_latest_interlocked;
       fetch csr_get_latest_interlocked into l_assignment_action_id;
       close csr_get_latest_interlocked;
    else
       l_assignment_action_id := p_assignment_action_id;
    end if;

    return l_assignment_action_id;
END checkPrepayment;

---------------------------------------------------------------------
--- Function : getEmployerBalance
---
--- Text : get Employer balances
---------------------------------------------------------------------
FUNCTION getEmployerBalance(p_assignment_action_id number) return number is

 l_ni_a_total_value number;
 l_ni_b_total_value number;
 l_ni_d_total_value number;
 l_ni_e_total_value number;
 l_ni_f_total_value number;
 l_ni_g_total_value number;
 l_ni_l_total_value number;
 l_ni_j_total_value number;
 l_ni_s_total_value number;
 l_temp_balance     number;
 l_employer_balance number;
 l_tax_district_ytd varchar2(20);

BEGIN

  l_ni_a_total_value := 0;
  l_ni_b_total_value := 0;
  l_ni_d_total_value := 0;
  l_ni_e_total_value := 0;
  l_ni_f_total_value := 0;
  l_ni_g_total_value := 0;
  l_ni_l_total_value := 0;
  l_ni_j_total_value := 0;
  l_ni_s_total_value := 0;
  l_temp_balance     := 0;
  l_employer_balance := 0;
  l_tax_district_ytd := '_ASG_TD_YTD';


  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'A') = 1 THEN
     l_ni_a_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI A Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'B') = 1 THEN
     l_ni_b_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI B Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'D') = 1 THEN
     l_ni_d_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI D Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'E') = 1 THEN
     l_ni_e_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI E Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'F') = 1 THEN
     l_ni_f_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI F Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'G') = 1 THEN
     l_ni_g_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI G Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'L') = 1 THEN
     l_ni_l_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI L Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'J') = 1 THEN
     l_ni_j_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI J Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'S') = 1 THEN
     l_ni_s_total_value := pay_gb_payroll_actions_pkg.report_balance_items
                          (p_balance_name => 'NI S Total',
                           p_dimension => l_tax_district_ytd,
                           p_assignment_action_id => p_assignment_action_id);
  end if;

  l_employer_balance := l_ni_a_total_value + l_ni_b_total_value + l_ni_d_total_value
                      + l_ni_e_total_value + l_ni_f_total_value + l_ni_g_total_value
                      + l_ni_j_total_value + l_ni_l_total_value + l_ni_s_total_value;

  l_temp_balance := pay_gb_payroll_actions_pkg.report_all_ni_balance
                    (p_balance_name => 'NI Employee',
                     p_dimension => l_tax_district_ytd,
                     p_assignment_action_id => p_assignment_action_id);

  l_employer_balance := l_employer_balance - l_temp_balance;

  l_temp_balance := pay_gb_payroll_actions_pkg.report_balance_items
                    (p_balance_name => 'NI C Employer',
                     p_dimension => l_tax_district_ytd,
                     p_assignment_action_id => p_assignment_action_id);

  l_employer_balance := l_employer_balance + l_temp_balance;

  l_temp_balance := pay_gb_payroll_actions_pkg.report_balance_items
                    (p_balance_name => 'NI S Employer',
                     p_dimension => l_tax_district_ytd,
                     p_assignment_action_id => p_assignment_action_id);

  l_employer_balance := l_employer_balance + l_temp_balance;

  return l_employer_balance;
END getEmployerBalance;

---------------------------------------------------------------------
--- Function : getBalances
---
--- Text     : Similar to core function : pay_soe_glb.getBalances
---            This fuction will check for prepayment run.  If action is
---            from prepayment, we will use latest run instead
---------------------------------------------------------------------
FUNCTION getBalances(p_assignment_action_id number ,p_balance_attribute varchar2) return long is

TYPE balance_type_lst_rec is RECORD (balance_name varchar2(80)
                                    ,reporting_name varchar2(80)
                                    ,dimension_name varchar2(80)
                                    ,defined_balance_name varchar2(80)
                                    ,defined_balance_id number);
TYPE balance_type_lst_tab is TABLE of balance_type_lst_rec INDEX BY BINARY_INTEGER;
--
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
l_calculated_balance number;
l_display  boolean;
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
cursor csr_get_DBal is
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
   OR bad.LEGISLATION_CODE = 'GB')
and   bad.attribute_id = ba.attribute_id
and   ba.defined_balance_id = db.defined_balance_id
and   db.balance_dimension_id = bd.balance_dimension_id
and   db.balance_type_id = bt.balance_type_id
and   bt.language = userenv('LANG')
and   oi.org_information1 = 'BALANCE'
and   oi.org_information4 = to_char(bt.balance_type_id)
and   oi.org_information5 = to_char(db.balance_dimension_id)
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
BEGIN
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

    i := 0;

    for db in csr_get_DBal loop
        i := i + 1;
        l_defined_balance_lst(i).defined_balance_id := db.defined_balance_id;
        l_balance_type_lst(db.defined_balance_id).balance_name := db.balance_name;
        l_balance_type_lst(db.defined_balance_id).reporting_name := db.reporting_name;
        l_balance_type_lst(db.defined_balance_id).defined_balance_name:= db.defined_balance_name;
        l_balance_type_lst(db.defined_balance_id).dimension_name := db.dimension_name;
        l_balance_type_lst(db.defined_balance_id).defined_balance_id := db.defined_balance_id;
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

    i := 0;
    if l_save_asg_run_bal = 'Y' then
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
            pay_soe_util.setValue('01',l_balance_type_lst(l_output_table(i).defined_balance_id).balance_name,TRUE,FALSE);
     	    pay_soe_util.setValue('02',l_balance_type_lst(l_output_table(i).defined_balance_id).reporting_name,FALSE,FALSE);
            pay_soe_util.setValue('03',l_balance_type_lst(l_output_table(i).defined_balance_id).dimension_name,FALSE,FALSE);
            pay_soe_util.setValue('04',l_balance_type_lst(l_output_table(i).defined_balance_id).defined_balance_name,FALSE,FALSE);
            pay_soe_util.setValue('16',to_char(l_output_table(i).balance_value,
                         fnd_currency.get_format_mask(substr(PAY_SOE_GLB.g_currency_code,2,3),40)),FALSE,FALSE);
            pay_soe_util.setValue('06',to_char(l_output_table(i).defined_balance_id),FALSE,TRUE);
         end if;
       end loop;
    end if;

    l_display := FALSE;
    l_calculated_balance := pay_gb_payroll_actions_pkg.report_all_ni_balance('NI Able',p_assignment_action_id,'_ASG_TD_YTD');
    hr_utility.trace('NI Able : ' || l_calculated_balance);
    if l_calculated_balance <> 0 then
      l_display := TRUE;
      pay_soe_util.setValue('01',null,TRUE,FALSE);
      pay_soe_util.setValue('02',null,FALSE,FALSE);
      pay_soe_util.setValue('03','ASG_TD_YTD',FALSE,FALSE);
      pay_soe_util.setValue('04','NIable YTD',FALSE,FALSE);
      pay_soe_util.setValue('16',to_char(l_calculated_balance,
                 fnd_currency.get_format_mask(substr(PAY_SOE_GLB.g_currency_code,2,3),40)),FALSE,FALSE);
      pay_soe_util.setValue('06',null,FALSE,TRUE);
    end if;

    l_calculated_balance := pay_gb_payroll_actions_pkg.report_all_ni_balance('NI Able',p_assignment_action_id,'_ASG_TRANSFER_PTD');
    hr_utility.trace('NI Able PTD : ' || l_calculated_balance);
    if l_calculated_balance <> 0 then
      l_display := TRUE;
      pay_soe_util.setValue('01',null,TRUE,FALSE);
      pay_soe_util.setValue('02',null,FALSE,FALSE);
      pay_soe_util.setValue('03','ASG_TRANSFER_PTD',FALSE,FALSE);
      pay_soe_util.setValue('04','NIable PTD',FALSE,FALSE);
      pay_soe_util.setValue('16',to_char(l_calculated_balance,
                 fnd_currency.get_format_mask(substr(PAY_SOE_GLB.g_currency_code,2,3),40)),FALSE,FALSE);
      pay_soe_util.setValue('06',null,FALSE,TRUE);
    end if;

    l_calculated_balance := pay_gb_payroll_actions_pkg.report_all_ni_balance('NI Employee',p_assignment_action_id,'_ASG_TD_YTD');
    hr_utility.trace('NI Employee : ' || l_calculated_balance);
    if l_calculated_balance <> 0 then
      l_display := TRUE;
      pay_soe_util.setValue('01',null,TRUE,FALSE);
      pay_soe_util.setValue('02',null,FALSE,FALSE);
      pay_soe_util.setValue('03','ASG_TD_YTD',FALSE,FALSE);
      pay_soe_util.setValue('04','NI Ees YTD',FALSE,FALSE);
      pay_soe_util.setValue('16',to_char(l_calculated_balance,
                 fnd_currency.get_format_mask(substr(PAY_SOE_GLB.g_currency_code,2,3),40)),FALSE,FALSE);
      pay_soe_util.setValue('06',null,FALSE,TRUE);
    end if;

    l_calculated_balance := getEmployerBalance(p_assignment_action_id);
    hr_utility.trace('NI Employee : ' || l_calculated_balance);
    if l_calculated_balance <> 0 then
      l_display := TRUE;
      pay_soe_util.setValue('01',null,TRUE,FALSE);
      pay_soe_util.setValue('02',null,FALSE,FALSE);
      pay_soe_util.setValue('03','ASG_TD_YTD',FALSE,FALSE);
      pay_soe_util.setValue('04','NI Ers YTD',FALSE,FALSE);
      pay_soe_util.setValue('16',to_char(l_calculated_balance,
                 fnd_currency.get_format_mask(substr(PAY_SOE_GLB.g_currency_code,2,3),40)),FALSE,FALSE);
      pay_soe_util.setValue('06',null,FALSE,TRUE);
    end if;

    if balCount > 0 or l_display then
       return pay_soe_util.genCursor;
    else
       return ('select null COL01 from dual where 1=0');
    end if;

END getBalances;

---------------------------------------------------------------------
--- Function : Balances1
---
--- Text     : Displays the Balances in the Balances Region
---------------------------------------------------------------------
function Balances1(p_assignment_action_id number) return long is
begin
  return getBalances(checkPrepayment(p_assignment_action_id)
                    ,pay_soe_util.getConfig('BALANCES1'));
end Balances1;

--
---------------------------------------------------------------------
--- Function : Balances2
---
--- Text     : Displays the Balances in the Balances Region
---------------------------------------------------------------------
function Balances2(p_assignment_action_id number) return long is
begin
  return pay_soe_glb.balances2(checkPrepayment(p_assignment_action_id));
end Balances2;

---------------------------------------------------------------------
--- Function : Balances3
---
--- Text     : Displays the Balances in the Balances Region
---------------------------------------------------------------------
function Balances3(p_assignment_action_id number) return long is
begin
  return pay_soe_glb.balances3(checkPrepayment(p_assignment_action_id));
end Balances3;

---------------------------------------------------------------------
--- Function : Tax_Info
---
--- Text     : Fetches Tax Information
---------------------------------------------------------------------
 FUNCTION Tax_Info(p_assignment_action_id NUMBER) RETURN LONG IS
   cursor getInfo is
   select ppa.date_earned,
          ppa.payroll_action_id,
          paa.assignment_id
   from   pay_payroll_actions ppa,
          pay_assignment_actions paa
   where  paa.assignment_action_id = p_assignment_action_id
   and    paa.payroll_action_id = ppa.payroll_action_id;

   cursor getTaxPhone(p_payroll_act number) is
   select max(org_information8)
   from   pay_payrolls_f p,
          pay_payroll_actions pact,
          hr_soft_coding_keyflex flex,
          hr_organization_information org
   where  p.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   and    org.org_information_context = 'Tax Details References'
   and    org.org_information1 = flex.segment1
   and    p.business_group_id = org.organization_id
   and    pact.payroll_action_id = p_payroll_act
   and    pact.payroll_id = p.payroll_id
   and    pact.effective_date between p.effective_start_date and p.effective_end_date;

  res           getInfo%rowtype;
  l_tax_period  varchar2(30);
  l_tax_ref     varchar2(30);
  l_tax_code    varchar2(30);
  l_tax_basis   varchar2(30);
  l_ni_cat      varchar2(30);
  l_tax_phone   varchar2(30);
  l_asg_act_id  number;
  l_sql         long;
begin
  open  getInfo;
  fetch getInfo into res;
  close getInfo;

  open  getTaxPhone(res.payroll_action_id);
  fetch getTaxPhone into l_tax_phone;
  close getTaxPhone;

  l_asg_act_id := checkPrepayment(p_assignment_action_id);

  pay_gb_payroll_actions_pkg.get_database_items
         (p_assignment_id            => res.assignment_id,
          p_run_assignment_action_id => l_asg_act_id,
          p_date_earned              => to_char(res.date_earned,'YYYY/MM/DD'),
          p_payroll_action_id        => res.payroll_action_id,
          p_tax_period               => l_tax_period,
          p_tax_refno                => l_tax_ref,
          p_tax_code                 => l_tax_code,
          p_tax_basis                => l_tax_basis,
          p_ni_category              => l_ni_cat);

   pay_soe_util.clear;
   pay_soe_util.setValue('01',l_tax_period,TRUE ,FALSE);
   pay_soe_util.setValue('02',l_tax_ref   ,FALSE,FALSE);
   pay_soe_util.setValue('03',l_tax_phone ,FALSE,FALSE);
   pay_soe_util.setValue('04',l_tax_code  ,FALSE,FALSE);
   pay_soe_util.setValue('05',l_tax_basis ,FALSE,FALSE);
   pay_soe_util.setValue('06',l_ni_cat    ,FALSE,TRUE);

   return pay_soe_util.genCursor;
end Tax_Info;

---------------------------------------------------------------------
--- Function : SetParameters
---
--- Text     : Set paramters
---------------------------------------------------------------------
function setParameters(p_assignment_action_id in number) return varchar2 is
begin
      return (pay_soe_glb.setParameters(p_assignment_action_id));
end setParameters;

---------------------------------------------------------------------
--- Function : SetParameters (Overload function)
---
--- Text     : Set parameters
---------------------------------------------------------------------
function setParameters(p_person_id in number, p_assignment_id in number, p_effective_date date) return varchar2 is

   cursor csr_get_asg_id is
   select assignment_id
   from   per_all_assignments_f
   where  person_id = p_person_id
   and    p_effective_date between effective_start_date and effective_end_date;

   cursor csr_get_action_id(asg_id number) is
   select to_number(substr(max(to_char(pa.effective_date,'J')||lpad(aa.assignment_action_id,15,'0')),8))
   from   pay_payroll_actions    pa,
          pay_assignment_actions aa,
          per_time_periods       ptp
   where  aa.action_status = 'C'
   and    pa.payroll_action_id = aa.payroll_action_id
   and    aa.assignment_id = asg_id
   and    ptp.payroll_id = pa.payroll_id
   and    pa.effective_date <= ptp.regular_payment_date
   and    p_effective_date between ptp.start_date and ptp.end_date
   and    pa.action_type in ('P','Q','R','U');

   l_assignment_action_id  number;
   l_assignment_id         number;

begin
      l_assignment_id := p_assignment_id;
      if l_assignment_id is null then
         open csr_get_asg_id;
         fetch csr_get_asg_id into l_assignment_id;
         close csr_get_asg_id;
      end if;

      open csr_get_action_id(l_assignment_id);
      fetch csr_get_action_id into l_assignment_action_id;
      close csr_get_action_id;

      return (pay_soe_glb.setParameters(l_assignment_action_id));

end setParameters;

end pay_gb_online_soe;

/
