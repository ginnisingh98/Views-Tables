--------------------------------------------------------
--  DDL for Package Body PAY_GB_PAYROLL_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_PAYROLL_ACTIONS_PKG" as
/* $Header: pypra04t.pkb 120.6.12010000.3 2009/06/23 10:39:28 rlingama ship $ */

/* Constants */

  G_USER_TABLE_NAME 		varchar2(30) := 'SOE Balances';

  -- DataBase Items
  -- these are the database items used for the values displayed
  --
  G_TAX_PERIOD_ITEM   varchar2(40) := 'PAY_STATUTORY_PERIOD_NUMBER';
  G_TAX_REFNO_ITEM    varchar2(40) := 'SCL_PAY_GB_TAX_REFERENCE';
  G_TAX_CODE_ITEM     varchar2(40) := 'PAYE_DETAILS_TAX_CODE_ENTRY_VALUE';
  G_TAX_BASIS_ITEM    varchar2(40) := 'PAYE_DETAILS_TAX_BASIS_ENTRY_VALUE';
  G_NI_CATEGORY_ITEM  varchar2(40) := 'NI_CATEGORY_ENTRY_VALUE';
--G_TAX_PHONE_NUM     varchar2(40) := 'SCL_PAY_GB_TAX_OFFICE_PHONE_NUMBER';

  -- variables used for cache values
  G_PAYROLL_ACTION_ID pay_payroll_actions.payroll_action_id%type;
  G_TAX_PHONE  hr_organization_information.org_information8%type;
  --
  -- Balance Items
  --
  -- the following are the database items used to retrieve the balances
  -- for this form and report
  --
  G_GROSS_PAY_BALANCE      varchar2(30) := 'GROSS_PAY_ASG_YTD';
  G_TAXABLE_PAY_BALANCE    varchar2(30) := 'TAXABLE_PAY_ASG_TD_YTD';
  G_PAYE_BALANCE           varchar2(30) := 'PAYE_ASG_TD_YTD';
  G_PAYE_TRANSFER          varchar2(30) := 'PAYE_ASG_TRANSFER_PTD';
  G_NIABLE_PAY_BALANCE     varchar2(30) := 'NIABLE_PAY_ASG_TD_YTD';
  G_NI_A_EMPLOYEE_BALANCE  varchar2(30) := 'NI_A_EMPLOYEE_ASG_TD_YTD';
  G_NI_B_EMPLOYEE_BALANCE  varchar2(30) := 'NI_B_EMPLOYEE_ASG_TD_YTD';
  G_NI_D_EMPLOYEE_BALANCE  varchar2(30) := 'NI_D_EMPLOYEE_ASG_TD_YTD';
  G_NI_G_EMPLOYEE_BALANCE  varchar2(30) := 'NI_G_EMPLOYEE_ASG_TD_YTD';
  G_NI_F_EMPLOYEE_BALANCE  varchar2(30) := 'NI_F_EMPLOYEE_ASG_TD_YTD';
  G_NI_L_EMPLOYEE_BALANCE  varchar2(30) := 'NI_L_EMPLOYEE_ASG_TD_YTD';
  G_NI_J_EMPLOYEE_BALANCE  varchar2(30) := 'NI_J_EMPLOYEE_ASG_TD_YTD';
  G_NI_E_EMPLOYEE_BALANCE  varchar2(30) := 'NI_E_EMPLOYEE_ASG_TD_YTD';
  G_NI_S_EMPLOYEE_BALANCE  varchar2(30) := 'NI_S_EMPLOYEE_ASG_TD_YTD';
  G_NI_F_EMPLOYEE_TRANSFER varchar2(30) := 'NI_F_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_G_EMPLOYEE_TRANSFER varchar2(30) := 'NI_G_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_A_EMPLOYEE_TRANSFER varchar2(30) := 'NI_A_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_B_EMPLOYEE_TRANSFER varchar2(30) := 'NI_B_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_D_EMPLOYEE_TRANSFER varchar2(30) := 'NI_D_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_E_EMPLOYEE_TRANSFER varchar2(30) := 'NI_E_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_J_EMPLOYEE_TRANSFER varchar2(30) := 'NI_J_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_L_EMPLOYEE_TRANSFER varchar2(30) := 'NI_L_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_S_EMPLOYEE_TRANSFER varchar2(30) := 'NI_S_EMPLOYEE_ASG_TRANSFER_PTD';
  G_NI_F_ABLE_BALANCE      varchar2(30) := 'NI_F_ABLE_ASG_TD_YTD';
  G_NI_G_ABLE_BALANCE      varchar2(30) := 'NI_G_ABLE_ASG_TD_YTD';
  G_NI_A_ABLE_BALANCE      varchar2(30) := 'NI_A_ABLE_ASG_TD_YTD';
  G_NI_B_ABLE_BALANCE      varchar2(30) := 'NI_B_ABLE_ASG_TD_YTD';
  G_NI_D_ABLE_BALANCE      varchar2(30) := 'NI_D_ABLE_ASG_TD_YTD';
  G_NI_E_ABLE_BALANCE      varchar2(30) := 'NI_E_ABLE_ASG_TD_YTD';
  G_NI_J_ABLE_BALANCE      varchar2(30) := 'NI_J_ABLE_ASG_TD_YTD';
  G_NI_L_ABLE_BALANCE      varchar2(30) := 'NI_L_ABLE_ASG_TD_YTD';
  G_NI_S_ABLE_BALANCE      varchar2(30) := 'NI_S_ABLE_ASG_TD_YTD';
  G_NI_EMPLOYER_BALANCE    varchar2(30) := 'NI_EMPLOYER_ASG_TD_YTD';
  G_NI_EMPLOYER_TRANSFER   varchar2(30) := 'NI_EMPLOYER_ASG_TRANSFER_PTD';
  G_NIABLE_PAY_TRANSFER    varchar2(30) := 'NIABLE_PAY_ASG_TRANSFER_PTD';
  G_NI_F_ABLE_TRANSFER     varchar2(30) := 'NI_F_ABLE_ASG_TRANSFER_PTD';
  G_NI_G_ABLE_TRANSFER     varchar2(30) := 'NI_G_ABLE_ASG_TRANSFER_PTD';
  G_NI_A_ABLE_TRANSFER     varchar2(30) := 'NI_A_ABLE_ASG_TRANSFER_PTD';
  G_NI_B_ABLE_TRANSFER     varchar2(30) := 'NI_B_ABLE_ASG_TRANSFER_PTD';
  G_NI_D_ABLE_TRANSFER     varchar2(30) := 'NI_D_ABLE_ASG_TRANSFER_PTD';
  G_NI_E_ABLE_TRANSFER     varchar2(30) := 'NI_E_ABLE_ASG_TRANSFER_PTD';
  G_NI_J_ABLE_TRANSFER     varchar2(30) := 'NI_J_ABLE_ASG_TRANSFER_PTD';
  G_NI_L_ABLE_TRANSFER     varchar2(30) := 'NI_L_ABLE_ASG_TRANSFER_PTD';
  G_NI_S_ABLE_TRANSFER     varchar2(30) := 'NI_S_ABLE_ASG_TRANSFER_PTD';

  G_GROSS_PAY_PTD_BALANCE  varchar2(30) := 'GROSS_PAY_ASG_PROC_PTD';
  G_TAXABLE_PAY_TRANSFER   varchar2(30) := 'TAXABLE_PAY_ASG_TRANSFER_PTD';

  G_SUPERAN_BALANCE        varchar2(31) := 'SUPERANNUATION_TOTAL_ASG_TD_YTD';

  G_NI_A_TOTAL             varchar2(30) := 'NI_A_TOTAL_ASG_TD_PTD';
  G_NI_B_TOTAL             varchar2(30) := 'NI_B_TOTAL_ASG_TD_PTD';
  G_NI_D_TOTAL             varchar2(30) := 'NI_D_TOTAL_ASG_TD_PTD';
  G_NI_E_TOTAL             varchar2(30) := 'NI_E_TOTAL_ASG_TD_PTD';
  G_NI_F_TOTAL             varchar2(30) := 'NI_F_TOTAL_ASG_TD_PTD';
  G_NI_G_TOTAL             varchar2(30) := 'NI_G_TOTAL_ASG_TD_PTD';
  G_NI_J_TOTAL             varchar2(30) := 'NI_J_TOTAL_ASG_TD_PTD';
  G_NI_L_TOTAL             varchar2(30) := 'NI_L_TOTAL_ASG_TD_PTD';
  G_NI_S_TOTAL             varchar2(30) := 'NI_S_TOTAL_ASG_TD_PTD';

  G_NI_C_EMPLOYER          varchar2(30) := 'NI_C_EMPLOYER_ASG_TD_YTD';
  G_NI_S_EMPLOYER          varchar2(30) := 'NI_S_EMPLOYER_ASG_TD_YTD';

--
  -- Balance Types
  --
  -- the following are the types associated with the above balances
  --
  g_gross_pay_type      varchar2(30) := 'Gross Pay';
  g_taxable_pay_type    varchar2(30) := 'Taxable Pay';
  g_paye_type           varchar2(30) := 'PAYE';
  g_niable_pay_type     varchar2(30) := 'NIable Pay';
  g_ni_a_employee_type  varchar2(30) := 'NI A Employee';
  g_ni_b_employee_type  varchar2(30) := 'NI B Employee';
  g_ni_d_employee_type  varchar2(30) := 'NI D Employee';
  g_ni_e_employee_type  varchar2(30) := 'NI E Employee';
  g_ni_f_employee_type  varchar2(30) := 'NI F Employee';
  g_ni_g_employee_type  varchar2(30) := 'NI G Employee';
  g_ni_j_employee_type  varchar2(30) := 'NI J Employee';
  g_ni_l_employee_type  varchar2(30) := 'NI L Employee';
  g_ni_s_employee_type  varchar2(30) := 'NI S Employee';

  g_ni_a_able_type      varchar2(30) := 'NI A Able';
  g_ni_b_able_type      varchar2(30) := 'NI B Able';
  g_ni_d_able_type      varchar2(30) := 'NI D Able';
  g_ni_e_able_type      varchar2(30) := 'NI E Able';
  g_ni_f_able_type      varchar2(30) := 'NI F Able';
  g_ni_g_able_type      varchar2(30) := 'NI G Able';
  g_ni_j_able_type      varchar2(30) := 'NI J Able';
  g_ni_l_able_type      varchar2(30) := 'NI L Able';
  g_ni_s_able_type      varchar2(30) := 'NI S Able';

  g_ni_a_total_type     varchar2(30) := 'NI A Total';
  g_ni_b_total_type     varchar2(30) := 'NI B Total';
  g_ni_d_total_type     varchar2(30) := 'NI D Total';
  g_ni_e_total_type     varchar2(30) := 'NI E Total';
  g_ni_f_total_type     varchar2(30) := 'NI F Total';
  g_ni_g_total_type     varchar2(30) := 'NI G Total';
  g_ni_j_total_type     varchar2(30) := 'NI J Total';
  g_ni_l_total_type     varchar2(30) := 'NI L Total';
  g_ni_s_total_type     varchar2(30) := 'NI S Total';

  g_ni_employer_type    varchar2(30) := 'NI Employer';

  g_superan_total_type  varchar2(30) := 'Superannuation Total';

  g_ni_c_employer_type  varchar2(30) := 'NI C Employer';
  g_ni_s_employer_type  varchar2(30) := 'NI S Employer';

--
  -- Dimension suffixes
  --
  -- the following are the different balance dimension suffixes used by
  -- the balance items
  --
  g_year_to_date      varchar2(30) := '_ASG_YTD';
  g_tax_district_ytd  varchar2(30) := '_ASG_TD_YTD';
  g_period_to_date    varchar2(30) := '_ASG_TRANSFER_PTD';

  g_proc_period_to_date varchar2(30) := '_ASG_PROC_PTD';

--
  -- The NI Total for each category
  --
  g_ni_a_total_value  number;
  g_ni_b_total_value  number;
  g_ni_d_total_value  number;
  g_ni_e_total_value  number;
  g_ni_f_total_value  number;
  g_ni_g_total_value  number;
  g_ni_j_total_value  number;
  g_ni_l_total_value  number;
  g_ni_s_total_value  number;

  -- Table Declaration
  --
  --
  -- PLSQL Table of Record is allowed only from PLSQL 2.3
  --
/* bug 8497345 - conmmented out balance_name_table,balance_value_table PL/SQL table as defiend in specification */
-- TYPE balance_name_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  TYPE balance_suffix_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE balance_id_table IS TABLE OF NUMBER(9) INDEX BY BINARY_INTEGER;
--  TYPE balance_value_table IS TABLE OF NUMBER(12,2) INDEX BY BINARY_INTEGER;

  g_balance_name	balance_name_table;
  g_balance_suffix	balance_suffix_table;
  g_balance_id		balance_id_table;
  g_displayed_balance   balance_name_table;
  g_displayed_value	balance_value_table;

  g_empty_balances	balance_name_table;
  g_empty_values	balance_value_table;

  g_table_dim		NUMBER := 0;	-- Table Dimension

  g_tax_code_id		NUMBER;
  g_tax_basis_id	NUMBER;
  g_category_id		NUMBER;
  g_paye_tax_code_id    NUMBER;
  g_paye_tax_basis_id   NUMBER;

  g_user_narrative_column_id	NUMBER;
  g_user_sequence_column_id 	NUMBER;

--
--
------------------------------------------------------------------------------
--
procedure get_input_values_id
is

CURSOR csr_input_value_id (l_element_name VARCHAR2,
                           l_piv_name     VARCHAR2) IS
SELECT input_value_id
FROM   pay_input_values_f piv,
       pay_element_types_f pet
WHERE  piv.element_type_id = pet.element_type_id
AND    pet.element_name = l_element_name
AND    pet.legislation_code = 'GB'
AND    piv.name = l_piv_name;

begin

  OPEN  csr_input_value_id('PAYE Details','Tax Code');
  FETCH csr_input_value_id INTO g_tax_code_id;
  CLOSE csr_input_value_id;

  OPEN  csr_input_value_id('PAYE Details','Tax Basis');
  FETCH csr_input_value_id INTO g_tax_basis_id;
  CLOSE csr_input_value_id;

  OPEN  csr_input_value_id('NI','Category');
  FETCH csr_input_value_id INTO g_category_id;
  CLOSE csr_input_value_id;

  OPEN  csr_input_value_id('PAYE','Tax Code');
  FETCH csr_input_value_id INTO g_paye_tax_code_id;
  CLOSE csr_input_value_id;

  OPEN  csr_input_value_id('PAYE','Tax Basis');
  FETCH csr_input_value_id INTO g_paye_tax_basis_id;
  CLOSE csr_input_value_id;

end get_input_values_id;


procedure total_payment (p_assignment_action_id in number,
			 p_total_payment out nocopy number) is
-- Bug 2553453, removed call to fnd_number.canonical_to_number from query
-- as conversion already handled in view, and extra call causes problems in
-- calculation when working in non-GB environment
cursor csr_payment is
   select sum(result_value)
          from pay_gb_pay_values_v
   where base_classification_name in ('Earnings','Direct Net', 'Direct Payment')
     and p_assignment_action_id = assignment_action_id;
--
begin
--
  open csr_payment;
  fetch csr_payment into p_total_payment;
  close csr_payment;
--
end total_payment;
--
--
------------------------------------------------------------------------------
--
procedure total_deduct (p_assignment_action_id in number,
		        p_total_deduct out nocopy number) is
-- Bug 2553453, removed call to fnd_number.canonical_to_number from query
-- as conversion already handled in view, and extra call causes problems in
-- calculation when working in non-GB environment
cursor csr_deduct  is select sum(result_value)
		      from pay_gb_pay_values_v
		      where base_classification_name in
			('Pre Statutory', 'Statutory', 'Court Orders',
			'Pre Tax Deductions','PAYE','NI','Voluntary Deductions',
                        'Pre NI Deductions','Pre Tax and NI Deductions')
		      and p_assignment_action_id = assignment_action_id;
--
begin
--
  open csr_deduct;
  fetch csr_deduct into p_total_deduct;
  close csr_deduct;
--
end total_deduct;
--
-------------------------------------------------------------------------
--
-- sets the context for which a database item is to be retrieved and returns
-- whether context has been set correctly
--
function set_database_context (p_database_item in varchar2,
                               p_payroll_action_id in number   default null,
                               p_date_earned       in varchar2 default null,
                               p_assignment_id     in number   default null)
return boolean is
--
begin
--
  if p_database_item = G_TAX_PERIOD_ITEM then
  --
    if p_payroll_action_id is not null then
    --
      pay_balance_pkg.set_context ('payroll_action_id',
                                   to_char(p_payroll_action_id));
      --
      return true;
    --
    else
    --
      return false;
    --
    end if;
  --
  elsif p_database_item = G_TAX_REFNO_ITEM then
  --
    if p_date_earned is not null and
       p_assignment_id is not null then
    --
      pay_balance_pkg.set_context ('date_earned',
                                   p_date_earned);
      --
      pay_balance_pkg.set_context ('assignment_id',
                                   to_char(p_assignment_id));
      --
      return true;
    --
    else
    --
      return false;
    --
    end if;
  --
  end if;
--
end;
--
-------------------------------------------------------------------------
--
-- returns the value associated with a given database item assuming that the
-- correct context has already been set
--
function database_item (p_database_item in varchar2) return varchar2 is
--
  -- constants for calls to database items
  --
  l_business_group_id number       := null;
  l_legislation_code  varchar2(30) := 'GB';
--
begin
--
  return pay_balance_pkg.run_db_item
                     (p_database_name    => p_database_item,
                      p_bus_group_id     => l_business_group_id,
                      p_legislation_code => l_legislation_code);
--
end;
--
-------------------------------------------------------------------------
-- replaces the tax code, tax basis and category retrievals from database
-- items
--
FUNCTION get_tax_details(p_run_assignment_action_id number,
                         p_input_value_id           number,
                         p_paye_input_value_id      number,
                         p_date_earned              varchar2)
RETURN varchar2
IS
--
-- Retrieve the details via the element entry values table
--
 cursor element_type_value(p_assig_act_id NUMBER) is
   SELECT peev.screen_entry_value
   FROM pay_element_entry_values_f peev,
        pay_element_entries_f    pee,
        pay_assignment_actions   paa
   WHERE  pee.element_entry_id = peev.element_entry_id
   AND    pee.assignment_id    = paa.assignment_id
   AND    paa.assignment_action_id  = p_assig_act_id
   AND    peev.input_value_id +0  = p_input_value_id
   AND    to_date(p_date_earned, 'YYYY/MM/DD')
   BETWEEN
          pee.effective_start_date
      AND pee.effective_end_date
   AND  to_date(p_date_earned, 'YYYY/MM/DD')
   BETWEEN
          peev.effective_start_date
      AND peev.effective_end_date;
 --
 -- Retrieve the details via the run result
 --
 cursor result_type_value(p_piv_id NUMBER, p_assig_act_id NUMBER) is
     SELECT    result_value
     FROM      pay_run_result_values   prr,
               pay_run_results         pr,
               pay_element_types_f     pet,
               pay_input_values_f      piv
     WHERE     pr.assignment_action_id   =   p_assig_act_id
     and       pr.element_type_id        =   pet.element_type_id
     and       pr.run_result_id          =   prr.run_result_id
     and       prr.input_value_id        =   piv.input_value_id
     and       pet.element_type_id       =   piv.element_type_id
     and       piv.input_value_id        =   p_piv_id
     and       piv.business_group_id     IS NULL
     and       piv.legislation_code      =  'GB'
     and       to_date(p_date_earned, 'YYYY/MM/DD')
               between piv.effective_start_date
               and piv.effective_end_date
     and       to_date(p_date_earned, 'YYYY/MM/DD')
               between pet.effective_start_date
               and pet.effective_end_date
     and       pr.run_result_id = (select nvl(max(pr1.run_result_id),pr.run_result_id)
                                       from   pay_run_results pr1
                                       where  pr1.assignment_action_id = p_assig_act_id
                                       and    pr1.element_type_id  = pr.element_type_id
                                       and    pr1.status = 'P');

 --
 -- Get the child action
 --
 cursor get_child_action(p_assig_act_id number) is
 select assignment_action_id
 from   pay_assignment_actions
 where  source_action_id = p_assig_act_id
 order by action_sequence desc;

--
 l_legislation_code  varchar2(30) := 'GB';
 pay_result_value          varchar2 (60);
 error_string              varchar2 (60);
 l_child_act_id      number;
--
BEGIN
--
  error_string := to_char(p_input_value_id);

-- Check for child action
  open get_child_action(p_run_assignment_action_id);
  fetch get_child_action into l_child_act_id;
  close get_child_action;

  if (l_child_act_id is null) then
     l_child_act_id := p_run_assignment_action_id;
  end if;

--
-- Retrieve the value from the PAYE run result
--

  open result_type_value(p_paye_input_value_id, l_child_act_id);
  fetch result_type_value into pay_result_value;
  close result_type_value;

--
-- If the PAYE run result is null, retrieve the value from
-- the PAYE Details run result
--

  if pay_result_value is null then

     open result_type_value(p_input_value_id, l_child_act_id);
     fetch result_type_value into pay_result_value;
     close result_type_value;

  end if;

--
-- The run result values are null, so use the element entry value
--

  if pay_result_value is null then

    open element_type_value(l_child_act_id);
    fetch element_type_value into pay_result_value;
    close element_type_value;

  end if;
--
  return pay_result_value;
--
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		pay_result_value := NULL;
		hr_utility.trace('TEST pay_result_value : NULL ');
		return pay_result_value;
--
END get_tax_details;
--
-------------------------------------------------------------------------
--
-- retrieves the values to be displayed by calling database items
--
procedure get_database_items (p_assignment_id     in     number,
                              p_run_assignment_action_id in number,
                              p_date_earned       in     varchar2,
                              p_payroll_action_id in     number,
                              p_tax_period        in out nocopy varchar2,
                              p_tax_refno         in out nocopy varchar2,
                              p_tax_code          in out nocopy varchar2,
                              p_tax_basis         in out nocopy varchar2,
                              p_ni_category       in out nocopy varchar2) is
--
   l_tax_basis varchar2(30);
--
begin
--
  get_input_values_id;

  -- set context for Tax Period database item and retrieve it
  --
  if set_database_context (p_database_item     => G_TAX_PERIOD_ITEM,
                           p_payroll_action_id => p_payroll_action_id) then
  --
    p_tax_period  := database_item (G_TAX_PERIOD_ITEM);
  --
  --
  --
  -- set context for the Tax Refno database item, which is also
  -- used for the remaining items, and retrieve the remaining items
  --
  if set_database_context (p_database_item     => G_TAX_REFNO_ITEM,
                           p_date_earned       => p_date_earned,
                           p_assignment_id     => p_assignment_id) then
  --
    p_tax_refno   := database_item (G_TAX_REFNO_ITEM);
    --
    p_tax_code    := get_tax_details(p_run_assignment_action_id,
                                     g_tax_code_id,
                                     g_paye_tax_code_id,
                                     p_date_earned);
     -- database_item (G_TAX_CODE_ITEM);
    --
    l_tax_basis   := get_tax_details(p_run_assignment_action_id,
                                     g_tax_basis_id,
                                     g_paye_tax_basis_id,
                                     p_date_earned);
     -- database_item (G_TAX_BASIS_ITEM);
    --
    -- Tax Basis is translated into its meaning
    --
    --p_tax_basis   := hr_general.decode_lookup ('GB_TAX_BASIS', l_tax_basis);
      if l_tax_basis = 'C' then p_tax_basis := 'Cumulative';
                           else p_tax_basis := 'Non Cumul.';
      end if;
    --
    p_ni_category := get_tax_details(p_run_assignment_action_id,
                                     g_category_id,
                                     g_category_id,
                                     p_date_earned);
     --  database_item (G_NI_CATEGORY_ITEM);
  --
  end if;
  end if;
--
end;
--
procedure get_report_db_items (p_assignment_id     in     number,
                               p_run_assignment_action_id in number,
			       p_date_earned       in     varchar2,
			       p_payroll_action_id in     number,
			       p_tax_period        in out nocopy varchar2,
			       p_tax_refno         in out nocopy varchar2,
			       p_tax_phone	   in out nocopy varchar2,
			       p_tax_code          in out nocopy varchar2,
			       p_tax_basis         in out nocopy varchar2,
			       p_ni_category       in out nocopy varchar2) is
--
  l_tax_basis varchar2(30);
--
begin
--
  get_input_values_id;

  -- set context for Tax Period database item and retrieve it
  --
  if set_database_context (p_database_item     => G_TAX_PERIOD_ITEM,
			   p_payroll_action_id => p_payroll_action_id) then
  --
    p_tax_period  := database_item (G_TAX_PERIOD_ITEM);
  --
  --
  -- set context for the Tax Refno database item, which is also
  -- used for the remaining items, and retrieve the remaining items
  --
  if set_database_context (p_database_item     => G_TAX_REFNO_ITEM,
                           p_date_earned       => p_date_earned,
                           p_assignment_id     => p_assignment_id) then
  --
    p_tax_refno   := database_item (G_TAX_REFNO_ITEM);
    --
--    p_tax_phone   := database_item (G_TAX_PHONE_NUM);
--    no database item as yet available for tax office telephone
--    cache the value that doesn't change unless payroll action changes
if nvl(g_payroll_action_id,-1) <> p_payroll_action_id then
	select max(org_information8) into g_tax_phone
			from pay_payrolls_f p,
                             pay_payroll_actions pact,
			     hr_soft_coding_keyflex flex,
			     hr_organization_information org
		where p.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
		and org.ORG_INFORMATION_CONTEXT = 'Tax Details References'
		and org.org_information1 = flex.segment1
		and p.business_group_id = org.organization_id
		and pact.payroll_action_id = p_payroll_action_id
		and pact.payroll_id = p.payroll_id
		and pact.effective_date between
             		p.effective_start_date and p.effective_end_date;

			g_payroll_action_id := p_payroll_action_id;
			end if;
			p_tax_phone := g_tax_phone;
--
    --
    p_tax_code    := get_tax_details(p_run_assignment_action_id,
                                     g_tax_code_id,
                                     g_paye_tax_code_id,
                                     p_date_earned);
           -- database_item (G_TAX_CODE_ITEM);
    --
    l_tax_basis   := get_tax_details(p_run_assignment_action_id,
                                     g_tax_basis_id,
                                     g_paye_tax_basis_id,
                                     p_date_earned);
           -- database_item (G_TAX_BASIS_ITEM);
    --
    -- Tax Basis is translated into its meaning
    --
    --p_tax_basis   := hr_general.decode_lookup ('GB_TAX_BASIS', l_tax_basis,p_date_earned);
      if l_tax_basis = 'C' then p_tax_basis := 'Cumulative';
                           else p_tax_basis := 'Non Cumul.';
      end if;
    --
    p_ni_category := get_tax_details(p_run_assignment_action_id,
                                     g_category_id,
                                     g_category_id,
                                     p_date_earned);
    -- database_item (G_NI_CATEGORY_ITEM);
  --
  --
  end if;
  end if;
--
end;
--
------------------------------------------------------------------------------
--
-- returns the defined balance ID associated with a given balance database
-- item - the balance is defined in terms of its type and the balance
-- dimension
--
-- Bug 358634 included legislation_code to reduce number of values returned
--
function defined_balance_id (p_balance_type     in varchar2,
                             p_dimension_suffix in varchar2) return number is
--
  l_legislation_code  varchar2(30) := 'GB';
--

  l_table_index	NUMBER;
  l_found	BOOLEAN := FALSE;

  l_balance_name	VARCHAR2(80);
  l_balance_suffix	VARCHAR2(30);

  CURSOR c_defined_balance IS
	SELECT
 		defined_balance_id
	FROM
                pay_defined_balances PDB,
                pay_balance_dimensions PBD,
                pay_balance_types_tl PBT_TL,
                pay_balance_types PBT
        WHERE   PBT_TL.balance_type_id = PBT.balance_type_id
        and     userenv('LANG') = PBT_TL.language
        AND     PBT_TL.balance_name = p_balance_type
        AND     nvl(PBT.legislation_code,l_legislation_code) = l_legislation_code
        AND     PDB.balance_type_id = PBT.balance_type_id
        AND     PBD.balance_dimension_id = PDB.balance_dimension_id
        AND     nvl(PDB.legislation_code,l_legislation_code) = l_legislation_code
        AND     PBD.database_item_suffix = p_dimension_suffix;


--
  l_result number;
--
begin
--

  -- g_table_dim	this variable holds the table dimension

  l_table_index := 1;
  --
  hr_utility.trace(' Index :' || TO_CHAR(l_table_index));
  hr_utility.trace(' Dim   :' || TO_CHAR(g_table_dim));
  --
  LOOP
	IF l_table_index > g_table_dim THEN
		EXIT;
	END IF;
	l_balance_name := g_balance_name(l_table_index);
	l_balance_suffix := g_balance_suffix(l_table_index);

	IF l_balance_name = p_balance_type AND l_balance_suffix = p_dimension_suffix THEN
		l_result := g_balance_id(l_table_index);
		l_found := TRUE;
		hr_utility.trace(' FOUND !!!!! ');
		EXIT;
	END IF;
        l_table_index := l_table_index + 1;
  END LOOP;
  --
  hr_utility.trace(' Index :' || TO_CHAR(l_table_index));
  --
  IF l_found = FALSE THEN -- calculate and insert the new value in the table.
	--
	hr_utility.trace(' NOT FOUND, inserted IN position : ' || TO_CHAR(l_table_index));
	--
	open c_defined_balance;
	fetch c_defined_balance into l_result;
	close c_defined_balance;

        g_balance_name(l_table_index) := p_balance_type;
        g_balance_suffix(l_table_index) := p_dimension_suffix;
        g_balance_id(l_table_index) := l_result;
        g_table_dim := g_table_dim + 1;

  END IF;
  --
  --
  return l_result;
end;
--
------------------------------------------------------------------------------
--
-- returns the value associated with a given balance database item
-- this is derived by translating the balance name into its balance type
-- and dimension
-- using the type and dimesnion to derive the defined balance ID
-- using the defined balance ID to obtain the current value for the balance
-- for the given assignment action ID
--
function balance_item_value (p_balance_name         in varchar2,
                             p_assignment_action_id in number) return number is
--
  l_balance_name         varchar2(30);
  l_balance_type         varchar2(30);
  l_dimension_suffix     varchar2(30);
  l_defined_balance_id   number;
--
begin
--
if p_balance_name = G_GROSS_PAY_BALANCE then
  --
    l_balance_type     := g_gross_pay_type;
    l_dimension_suffix := g_year_to_date;
  --
  elsif p_balance_name = G_TAXABLE_PAY_BALANCE then
  --
    l_balance_type     := g_taxable_pay_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_PAYE_BALANCE then
  --
    l_balance_type     := g_paye_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NIABLE_PAY_BALANCE then
  --
    l_balance_type     := g_niable_pay_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_A_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_a_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_B_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_b_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_D_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_d_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_E_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_e_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  --
  elsif p_balance_name = G_NI_F_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_f_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_G_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_g_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_J_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_j_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_L_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_l_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_S_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_s_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_A_TOTAL then
  --
    l_balance_type     := g_ni_a_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_B_TOTAL then
  --
    l_balance_type     := g_ni_b_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_D_TOTAL then
  --
    l_balance_type     := g_ni_d_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_E_TOTAL then
  --
    l_balance_type     := g_ni_e_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_F_TOTAL then
  --
    l_balance_type     := g_ni_f_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_G_TOTAL then
  --
    l_balance_type     := g_ni_g_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_J_TOTAL then
  --
    l_balance_type     := g_ni_j_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_L_TOTAL then
  --
    l_balance_type     := g_ni_l_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_S_TOTAL then
  --
    l_balance_type     := g_ni_s_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  end if;
  --
  --
  -- derive defined balance ID
  --
  l_defined_balance_id := defined_balance_id
                               (p_balance_type     => l_balance_type,
                                p_dimension_suffix => l_dimension_suffix);
  --
  --
  return pay_balance_pkg.get_value
                            (p_defined_balance_id   => l_defined_balance_id,
                             p_assignment_action_id => p_assignment_action_id);
  --
  --
end;
--
--
-------------------------------------------------------------------------------
--
PROCEDURE find_user_table_values
	 (p_user_row_name 	in	varchar2,
	  p_business_group_id	in	number,
	  p_seq_no		in out nocopy	number) is
--
CURSOR  c_find_row_values IS
SELECT	puci.value intval
FROM	pay_user_rows pur,
  	pay_user_columns puc,
  	pay_user_tables put,
  	pay_user_column_instances puci
WHERE	put.user_table_name = g_user_table_name
AND	put.business_group_id is NULL
AND	put.legislation_code = 'GB'
AND	puc.user_column_name = 'Sequence'
AND	puc.user_table_id = put.user_table_id
AND	puc.business_group_id is NULL
AND	puc.legislation_code = 'GB'
AND	puci.user_column_id = puc.user_column_id
AND     puci.business_group_id = p_business_group_id
AND	pur.user_row_id = puci.user_row_id
AND	pur.row_low_range_or_name = p_user_row_name;

begin

for rec in c_find_row_values loop

		p_seq_no := rec.intval;

end loop;

end;
--
-----------------------------------------------------------------------------------
--
-- Returns the balances for the report.
--
function report_balance_items (p_balance_name         in varchar2,
			       p_dimension	      in varchar2,
			       p_assignment_action_id in number) return number is
--
  l_defined_balance_id   number;
--
begin
--
  --
  -- derive defined balance ID
  --
  l_defined_balance_id := defined_balance_id
			       (p_balance_type     => p_balance_name,
				p_dimension_suffix => p_dimension);
  --

--
  if l_defined_balance_id is null
  then
  	return 0;
  else
        return pay_balance_pkg.get_value
                  (p_defined_balance_id   => l_defined_balance_id,
                   p_assignment_action_id => p_assignment_action_id);
  end if;
--
end;
--
-------------------------------------------------------------------------------
-- This section includes overloaded definitions of the functions:
-- report_balance_items and get_report_balances. This is to support any possible
-- bespoke reports using calls to these functions. Development has changed these
-- functions to include extra in parameters following new SOE functionality delivered
-- with 1999 EOY3 under bug 879804. mlisieck 16-Jul-99
--
-- Returns the balances for the report.
--
function report_balance_items (p_balance_name         in varchar2,
			       p_assignment_action_id in number) return number is
--
  l_balance_type         varchar2(30);
  l_dimension_suffix     varchar2(30);
  l_defined_balance_id   number;
--
begin
--
  if p_balance_name = G_GROSS_PAY_BALANCE then
  --
    l_balance_type     := g_gross_pay_type;
    l_dimension_suffix := g_year_to_date;
  --
  elsif p_balance_name = G_TAXABLE_PAY_BALANCE then
  --
    l_balance_type     := g_taxable_pay_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_PAYE_BALANCE then
  --
    l_balance_type     := g_paye_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_PAYE_TRANSFER then
  --
    l_balance_type     := g_paye_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NIABLE_PAY_BALANCE then
  --
    l_balance_type     := g_niable_pay_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_A_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_a_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_B_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_b_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_D_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_d_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_E_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_e_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_F_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_f_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_G_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_G_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_J_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_j_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_L_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_l_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_S_EMPLOYEE_BALANCE then
  --
    l_balance_type     := g_ni_s_employee_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_A_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_a_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_B_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_b_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_D_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_d_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_E_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_e_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_F_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_f_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_G_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_g_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_J_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_j_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_L_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_l_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_S_EMPLOYEE_TRANSFER then
  --
    l_balance_type     := g_ni_s_employee_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_A_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_a_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_B_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_b_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_D_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_d_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_E_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_e_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_F_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_f_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_G_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_g_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_J_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_j_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_L_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_l_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_S_ABLE_BALANCE then
  --
    l_balance_type     := g_ni_s_able_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_EMPLOYER_BALANCE then
  --
    l_balance_type     := g_ni_employer_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_EMPLOYER_TRANSFER then
  --
    l_balance_type     := g_ni_employer_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NIABLE_PAY_TRANSFER then
  --
    l_balance_type     := g_niable_pay_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_A_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_a_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_B_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_b_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_D_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_d_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_E_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_e_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_F_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_f_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_G_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_g_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_J_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_j_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_L_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_l_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_S_ABLE_TRANSFER then
  --
    l_balance_type     := g_ni_s_able_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_GROSS_PAY_PTD_BALANCE then
  --
    l_balance_type     := g_gross_pay_type;
    l_dimension_suffix := g_proc_period_to_date;
  --
  elsif p_balance_name = G_TAXABLE_PAY_TRANSFER then
  --
    l_balance_type     := g_taxable_pay_type;
    l_dimension_suffix := g_period_to_date;
  --
  elsif p_balance_name = G_NI_A_TOTAL then
  --
    l_balance_type     := g_ni_a_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_B_TOTAL then
  --
    l_balance_type     := g_ni_b_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_D_TOTAL then
  --
    l_balance_type     := g_ni_d_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_E_TOTAL then
  --
    l_balance_type     := g_ni_e_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_F_TOTAL then
  --
    l_balance_type     := g_ni_f_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_G_TOTAL then
  --
    l_balance_type     := g_ni_g_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_J_TOTAL then
  --
    l_balance_type     := g_ni_j_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_L_TOTAL then
  --
    l_balance_type     := g_ni_l_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_S_TOTAL then
  --
    l_balance_type     := g_ni_s_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_SUPERAN_BALANCE then
  --
    l_balance_type     := g_superan_total_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_C_EMPLOYER then
  --
    l_balance_type     := g_ni_c_employer_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_NI_S_EMPLOYER then
  --
    l_balance_type     := g_ni_s_employer_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  end if;
  --
  -- derive defined balance ID
  --
  l_defined_balance_id := defined_balance_id
			       (p_balance_type     => l_balance_type,
				p_dimension_suffix => l_dimension_suffix);
  --
  return pay_balance_pkg.get_value
		(p_defined_balance_id   => l_defined_balance_id,
		 p_assignment_action_id => p_assignment_action_id);
--
end;
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
PROCEDURE get_report_balances (p_assignment_action_id in     number,
			       p_label_1              in out nocopy varchar2,
			       p_value_1              in out nocopy number,
			       p_label_2              in out nocopy varchar2,
			       p_value_2              in out nocopy number,
			       p_label_3              in out nocopy varchar2,
			       p_value_3              in out nocopy number,
			       p_label_4              in out nocopy varchar2,
			       p_value_4              in out nocopy number,
			       p_label_5              in out nocopy varchar2,
			       p_value_5              in out nocopy number,
			       p_label_6              in out nocopy varchar2,
			       p_value_6              in out nocopy number,
			       p_label_7              in out nocopy varchar2,
			       p_value_7              in out nocopy number,
			       p_label_8              in out nocopy varchar2,
			       p_value_8              in out nocopy number,
			       p_label_9              in out nocopy varchar2,
			       p_value_9              in out nocopy number,
			       p_label_a              in out nocopy varchar2,
			       p_value_a              in out nocopy number,
			       p_label_b              in out nocopy varchar2,
			       p_value_b              in out nocopy number,
			       p_label_c              in out nocopy varchar2,
			       p_value_c              in out nocopy number) is
--
  l_ni_a_employee_value    number	:=0;
  l_ni_b_employee_value    number	:=0;
  l_ni_d_employee_value    number	:=0;
  l_ni_e_employee_value    number	:=0;
  l_ni_f_employee_value    number       :=0;
  l_ni_g_employee_value    number       :=0;
  l_ni_j_employee_value    number       :=0;
  l_ni_l_employee_value    number       :=0;
  l_ni_s_employee_value    number       :=0;

  l_ni_a_able_balance      number	:=0;
  l_ni_b_able_balance      number	:=0;
  l_ni_d_able_balance      number	:=0;
  l_ni_e_able_balance      number	:=0;
  l_ni_f_able_balance      number       :=0;
  l_ni_g_able_balance      number       :=0;
  l_ni_j_able_balance      number       :=0;
  l_ni_l_able_balance      number       :=0;
  l_ni_s_able_balance      number       :=0;

  l_ni_a_able_transfer     number	:=0;
  l_ni_b_able_transfer     number	:=0;
  l_ni_d_able_transfer     number	:=0;
  l_ni_e_able_transfer     number	:=0;
  l_ni_f_able_transfer     number       :=0;
  l_ni_g_able_transfer     number       :=0;
  l_ni_j_able_transfer     number       :=0;
  l_ni_l_able_transfer     number       :=0;
  l_ni_s_able_transfer     number       :=0;

  l_ni_a_total             number	:=0;
  l_ni_b_total             number	:=0;
  l_ni_d_total             number	:=0;
  l_ni_e_total             number	:=0;
  l_ni_f_total             number       :=0;
  l_ni_g_total             number       :=0;
  l_ni_j_total             number       :=0;
  l_ni_l_total             number       :=0;
  l_ni_s_total             number       :=0;

  l_ni_abdefg_total          number	:=0;
  l_ni_c_employer            number :=0;
  l_ni_s_employer            number :=0;

--
BEGIN
--
  -- if the assignment action id is not specified then do nothing
  --
  if p_assignment_action_id is null then
  --
    return;
  --
  end if;
  --
  --
  p_label_1 := 'Gross YTD';
  --
  p_value_1 := report_balance_items
		(p_balance_name         => G_GROSS_PAY_BALANCE,
		 p_assignment_action_id => p_assignment_action_id);
  --
  --
  p_label_2 := 'Gross PTD';
  --
  p_value_2 := report_balance_items
		(p_balance_name         => G_GROSS_PAY_PTD_BALANCE,
		 p_assignment_action_id => p_assignment_action_id);
  --
  --
  p_label_3 := 'Taxable YTD';
  --
  p_value_3 := report_balance_items
		(p_balance_name         => G_TAXABLE_PAY_BALANCE,
		 p_assignment_action_id => p_assignment_action_id);
  --
  --
  p_label_4 := 'Taxable PTD ';
  --
  p_value_4 := report_balance_items
		(p_balance_name         => G_TAXABLE_PAY_TRANSFER,
		 p_assignment_action_id => p_assignment_action_id);
  --
  --
  p_label_5 := 'PAYE YTD';
  --
  p_value_5 := report_balance_items
		(p_balance_name         => G_PAYE_BALANCE,
		 p_assignment_action_id => p_assignment_action_id);
  --
  --
  ------------------------------------------------------------------------
  --                        NI CALCULATION                              --
  ------------------------------------------------------------------------
  --
/*
  l_ni_a_total := report_balance_items
			 (p_balance_name         => G_NI_A_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_b_total := report_balance_items
			 (p_balance_name         => G_NI_B_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_d_total := report_balance_items
			 (p_balance_name         => G_NI_D_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_e_total := report_balance_items
			 (p_balance_name         => G_NI_E_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_f_total := report_balance_items
                         (p_balance_name         => G_NI_F_TOTAL,
                         p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_g_total := report_balance_items
                         (p_balance_name         => G_NI_G_TOTAL,
                         p_assignment_action_id => p_assignment_action_id);
  --
*/
  -------------------------------------------------------------------------
  -- IF l_ni_a_total <> 0 THEN
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'A') = 1 THEN
	  l_ni_a_total := report_balance_items
			 (p_balance_name         => G_NI_A_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
	  l_ni_a_able_balance := report_balance_items
			 (p_balance_name         => G_NI_A_ABLE_BALANCE,
			 p_assignment_action_id => p_assignment_action_id);
	  l_ni_a_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_A_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
	  l_ni_a_employee_value := report_balance_items
			   (p_balance_name         => G_NI_A_EMPLOYEE_BALANCE,
			   p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
  -- IF l_ni_b_total <> 0 THEN
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'B') = 1 THEN
	  l_ni_b_total := report_balance_items
			 (p_balance_name         => G_NI_B_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
	  l_ni_b_able_balance := report_balance_items
			 (p_balance_name         => G_NI_B_ABLE_BALANCE,
			 p_assignment_action_id => p_assignment_action_id);
	  l_ni_b_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_B_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
	  l_ni_b_employee_value := report_balance_items
			   (p_balance_name         => G_NI_B_EMPLOYEE_BALANCE,
			   p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
 --  IF l_ni_d_total <> 0 THEN
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'D') = 1 THEN
	  l_ni_d_total := report_balance_items
			 (p_balance_name         => G_NI_D_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
	  l_ni_d_able_balance := report_balance_items
			 (p_balance_name         => G_NI_D_ABLE_BALANCE,
			 p_assignment_action_id => p_assignment_action_id);
	  l_ni_d_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_D_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
	  l_ni_d_employee_value := report_balance_items
			   (p_balance_name         => G_NI_D_EMPLOYEE_BALANCE,
			   p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
 -- IF l_ni_e_total <> 0 THEN
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'E') = 1 THEN
	  l_ni_e_total := report_balance_items
			 (p_balance_name         => G_NI_E_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
	  l_ni_e_able_balance := report_balance_items
			 (p_balance_name         => G_NI_E_ABLE_BALANCE,
			 p_assignment_action_id => p_assignment_action_id);
	  l_ni_e_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_E_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
	  l_ni_e_employee_value := report_balance_items
			   (p_balance_name         => G_NI_E_EMPLOYEE_BALANCE,
			   p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
 -- IF l_ni_f_total <> 0 THEN
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'F') = 1 THEN
	  l_ni_f_total := report_balance_items
			 (p_balance_name         => G_NI_f_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
          l_ni_f_able_balance := report_balance_items
                         (p_balance_name         => G_NI_F_ABLE_BALANCE,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_f_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_F_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_f_employee_value := report_balance_items
                           (p_balance_name         => G_NI_F_EMPLOYEE_BALANCE,
                           p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
 -- IF l_ni_g_total <> 0 THEN
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'G') = 1 THEN
	  l_ni_g_total := report_balance_items
			 (p_balance_name         => G_NI_G_TOTAL,
			 p_assignment_action_id => p_assignment_action_id);
          l_ni_g_able_balance := report_balance_items
                         (p_balance_name         => G_NI_G_ABLE_BALANCE,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_g_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_G_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_g_employee_value := report_balance_items
                           (p_balance_name         => G_NI_G_EMPLOYEE_BALANCE,
                           p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'J') = 1 THEN
          l_ni_j_total := report_balance_items
                         (p_balance_name         => G_NI_J_TOTAL,
                          p_assignment_action_id => p_assignment_action_id);
          l_ni_j_able_balance := report_balance_items
                         (p_balance_name         => G_NI_J_ABLE_BALANCE,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_j_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_J_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_j_employee_value := report_balance_items
                           (p_balance_name         => G_NI_J_EMPLOYEE_BALANCE,
                           p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'L') = 1 THEN
          l_ni_l_total := report_balance_items
                         (p_balance_name         => G_NI_L_TOTAL,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_l_able_balance := report_balance_items
                         (p_balance_name         => G_NI_L_ABLE_BALANCE,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_l_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_L_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_l_employee_value := report_balance_items
                           (p_balance_name         => G_NI_L_EMPLOYEE_BALANCE,
                           p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
  IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'S') = 1 THEN
          l_ni_s_total := report_balance_items
                         (p_balance_name         => G_NI_S_TOTAL,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_s_able_balance := report_balance_items
                         (p_balance_name         => G_NI_S_ABLE_BALANCE,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_s_able_transfer := report_balance_items
                         (p_balance_name         => G_NI_S_ABLE_TRANSFER,
                         p_assignment_action_id => p_assignment_action_id);
          l_ni_s_employee_value := report_balance_items
                           (p_balance_name         => G_NI_S_EMPLOYEE_BALANCE,
                           p_assignment_action_id => p_assignment_action_id);
  END IF;
  --
  l_ni_abdefg_total := l_ni_a_total + l_ni_b_total +
                       l_ni_d_total + l_ni_e_total +
                       l_ni_f_total + l_ni_g_total +
                       l_ni_j_total + l_ni_l_total +
                       l_ni_s_total;

  p_label_6 := 'NIable YTD';
  p_value_6 := l_ni_a_able_balance + l_ni_b_able_balance +
	       l_ni_d_able_balance + l_ni_e_able_balance +
               l_ni_f_able_balance + l_ni_g_able_balance +
               l_ni_j_able_balance + l_ni_l_able_balance +
               l_ni_s_able_balance;
  --
  p_label_7 := 'NIable PTD';
  p_value_7 := l_ni_a_able_transfer + l_ni_b_able_transfer +
               l_ni_d_able_transfer + l_ni_e_able_transfer +
               l_ni_f_able_transfer + l_ni_g_able_transfer +
               l_ni_j_able_transfer + l_ni_l_able_transfer +
               l_ni_s_able_transfer;
  --
  p_label_8 := 'NI Ees YTD';
  p_value_8 := l_ni_a_employee_value + l_ni_b_employee_value +
	       l_ni_d_employee_value + l_ni_e_employee_value +
               l_ni_f_employee_value + l_ni_g_employee_value +
               l_ni_j_employee_value + l_ni_l_employee_value +
               l_ni_s_employee_value;
  --
  l_ni_c_employer := report_balance_items
		(p_balance_name         => G_NI_C_EMPLOYER,
		 p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_s_employer := report_balance_items
		(p_balance_name         => G_NI_S_EMPLOYER,
		 p_assignment_action_id => p_assignment_action_id);
  --
  p_label_9:= 'NI Ers YTD';
--  p_value_b := report_balance_items
--		(p_balance_name         => G_NI_EMPLOYER_BALANCE,
--		 p_assignment_action_id => p_assignment_action_id);
-- G_NI_EMPLOYER is not forced to be a latest balance in NI formula, so use:
-- NI_x_EMPLOYER = NI_x_TOTAL - NI_x_EMPLOYEE
  p_value_9 := l_ni_abdefg_total - p_value_a
              + l_ni_c_employer + l_ni_s_employer;
--
  p_label_a := 'Superan YTD';
  p_value_a := report_balance_items
		(p_balance_name         => G_SUPERAN_BALANCE,
		 p_assignment_action_id => p_assignment_action_id);
  --
END;
--
-- End of overloded function definitions for bug 879804.
--
-------------------------------------------------------------------------------
--
-- calculates the balance across NI categories A B D E F G
-- eg. NI Total = NI A Total + NI B Total + NI D Total + ...
--
-- The NI Total for each category has already been determined. It is only worth
-- looking for other NI balances if the NI Total for the category is not zero.
--
function report_all_ni_balance (p_balance_name in varchar2,
		           p_assignment_action_id in number,
		           p_dimension in varchar2) return number is

l_total number := 0;
l_all_cat_total number := 0;

l_A_balance varchar2(80);
l_B_balance varchar2(80);
l_D_balance varchar2(80);
l_E_balance varchar2(80);
l_F_balance varchar2(80);
l_G_balance varchar2(80);
l_J_balance varchar2(80);
l_L_balance varchar2(80);
l_S_balance varchar2(80);
--
begin
--

l_A_balance := replace(p_balance_name,'NI ','NI A ');
l_B_balance := replace(p_balance_name,'NI ','NI B ');
l_D_balance := replace(p_balance_name,'NI ','NI D ');
l_E_balance := replace(p_balance_name,'NI ','NI E ');
l_F_balance := replace(p_balance_name,'NI ','NI F ');
l_G_balance := replace(p_balance_name,'NI ','NI G ');
l_J_balance := replace(p_balance_name,'NI ','NI J ');
l_L_balance := replace(p_balance_name,'NI ','NI L ');
l_S_balance := replace(p_balance_name,'NI ','NI S ');

--	if g_ni_a_total_value <> 0
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'A') = 1 then
		l_total := report_balance_items(p_balance_name => l_A_balance,
					p_dimension => p_dimension,
					p_assignment_action_id => p_assignment_action_id);

		l_all_cat_total := l_all_cat_total + nvl(l_total,0);
	end if;


	--if g_ni_b_total_value <> 0
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'B') = 1 then
		l_total := report_balance_items(p_balance_name => l_B_balance,
					p_dimension => p_dimension,
					p_assignment_action_id => p_assignment_action_id);

		l_all_cat_total := l_all_cat_total + nvl(l_total,0);
	end if;


	-- if g_ni_d_total_value <> 0
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'D') = 1 then
		l_total := report_balance_items(p_balance_name => l_D_balance,
					p_dimension => p_dimension,
					p_assignment_action_id => p_assignment_action_id);

		l_all_cat_total := l_all_cat_total + nvl(l_total,0);
	end if;

	-- if g_ni_e_total_value <> 0
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'E') = 1 then
		l_total := report_balance_items(p_balance_name => l_E_balance,
					p_dimension => p_dimension,
					p_assignment_action_id => p_assignment_action_id);

		l_all_cat_total := l_all_cat_total + nvl(l_total,0);
	end if;

--	if g_ni_f_total_value <> 0
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'F') = 1 then
		l_total := report_balance_items(p_balance_name => l_F_balance,
					p_dimension => p_dimension,
					p_assignment_action_id => p_assignment_action_id);

		l_all_cat_total := l_all_cat_total + nvl(l_total,0);
	end if;

	-- if g_ni_g_total_value <> 0
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'G') = 1 then
		l_total := report_balance_items(p_balance_name => l_G_balance,
					p_dimension => p_dimension,
					p_assignment_action_id => p_assignment_action_id);

		l_all_cat_total := l_all_cat_total + nvl(l_total,0);
	end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'J') = 1 then
                l_total := report_balance_items(p_balance_name => l_J_balance,
                                        p_dimension => p_dimension,
                                        p_assignment_action_id => p_assignment_action_id);

                l_all_cat_total := l_all_cat_total + nvl(l_total,0);
        end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'L') = 1 then
                l_total := report_balance_items(p_balance_name => l_L_balance,
                                        p_dimension => p_dimension,
                                        p_assignment_action_id => p_assignment_action_id);

                l_all_cat_total := l_all_cat_total + nvl(l_total,0);
        end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'S') = 1 then
                l_total := report_balance_items(p_balance_name => l_S_balance,
                                        p_dimension => p_dimension,
                                        p_assignment_action_id => p_assignment_action_id);

                l_all_cat_total := l_all_cat_total + nvl(l_total,0);
        end if;


  return l_all_cat_total;
--
end report_all_ni_balance;
--
-------------------------------------------------------------------------
--
-- The NI Employer Balance is not forced to be the latest balance in NI formula,
-- so the following is used :
--    NI_x_EMPLOYER = NI_x_TOTAL - NI_x_EMPLOYEE + NI_C_EMPLOYER + NI_S_EMPLOYER
--
function report_employer_balance (p_assignment_action_id in number) return number is

l_temp_balance number := 0;
l_employer_balance number := 0;

begin
  --
  -- The NI Total for each category has already been established, so the NI Total for
  -- all categories is the sum of the NI Total for each individual category
  --
	l_employer_balance := g_ni_a_total_value + g_ni_b_total_value + g_ni_d_total_value
			      + g_ni_e_total_value + g_ni_f_total_value + g_ni_g_total_value
                              + g_ni_j_total_value + g_ni_l_total_value + g_ni_s_total_value;

	l_temp_balance := report_all_ni_balance
				(p_balance_name => 'NI Employee',
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);

	l_employer_balance := l_employer_balance - l_temp_balance;

	l_temp_balance := report_balance_items
        			(p_balance_name => 'NI C Employer',
        			 p_dimension => g_tax_district_ytd,
        			p_assignment_action_id => p_assignment_action_id);

	l_employer_balance := l_employer_balance + l_temp_balance;

	l_temp_balance := report_balance_items
        			(p_balance_name => 'NI S Employer',
        			 p_dimension => g_tax_district_ytd,
        			 p_assignment_action_id => p_assignment_action_id);

	l_employer_balance := l_employer_balance + l_temp_balance;

	return l_employer_balance;
--
end;
--
-------------------------------------------------------------------------------
--
PROCEDURE get_balance_items (p_assignment_action_id in     number,
                             p_gross_pay            in out nocopy number,
                             p_taxable_pay          in out nocopy number,
                             p_paye                 in out nocopy number,
                             p_niable_pay           in out nocopy number,
                             p_ni_paid              in out nocopy number) is
--
  l_ni_a_employee_value    number;
  l_ni_b_employee_value    number;
  l_ni_d_employee_value    number;
  l_ni_e_employee_value    number;
  l_ni_f_employee_value    number;
  l_ni_g_employee_value    number;
  l_ni_j_employee_value    number;
  l_ni_l_employee_value    number;
  l_ni_s_employee_value    number;

--
BEGIN
--
  -- if the assignment action id is not specified then do nothing
  --
  if p_assignment_action_id is null then
  --
    return;
  --
  end if;
  --
  p_gross_pay   := balance_item_value
                      (p_balance_name         => G_GROSS_PAY_BALANCE,
                       p_assignment_action_id => p_assignment_action_id);
  --
  p_taxable_pay := balance_item_value
                      (p_balance_name         => G_TAXABLE_PAY_BALANCE,
                       p_assignment_action_id => p_assignment_action_id);
  --
  p_paye        := balance_item_value
                      (p_balance_name         => G_PAYE_BALANCE,
                       p_assignment_action_id => p_assignment_action_id);
  --
  p_niable_pay  := balance_item_value
                      (p_balance_name         => G_NIABLE_PAY_BALANCE,
                       p_assignment_action_id => p_assignment_action_id);
  --
  --
  l_ni_a_employee_value := balance_item_value
                            (p_balance_name         => G_NI_A_EMPLOYEE_BALANCE,
                             p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_b_employee_value := balance_item_value
                           (p_balance_name         => G_NI_B_EMPLOYEE_BALANCE,
                            p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_d_employee_value := balance_item_value
                           (p_balance_name         => G_NI_D_EMPLOYEE_BALANCE,
                            p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_e_employee_value := balance_item_value
                           (p_balance_name         => G_NI_E_EMPLOYEE_BALANCE,
                            p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_f_employee_value := balance_item_value
                           (p_balance_name         => G_NI_F_EMPLOYEE_BALANCE,
                            p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_g_employee_value := balance_item_value
                           (p_balance_name         => G_NI_G_EMPLOYEE_BALANCE,
                            p_assignment_action_id => p_assignment_action_id);
   --
  l_ni_j_employee_value := balance_item_value
                           (p_balance_name         => G_NI_J_EMPLOYEE_BALANCE,
                            p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_l_employee_value := balance_item_value
                           (p_balance_name         => G_NI_L_EMPLOYEE_BALANCE,
                            p_assignment_action_id => p_assignment_action_id);
  --
  l_ni_s_employee_value := balance_item_value
                           (p_balance_name         => G_NI_S_EMPLOYEE_BALANCE,
                            p_assignment_action_id => p_assignment_action_id);
  --
  p_ni_paid     := l_ni_a_employee_value + l_ni_b_employee_value +
                   l_ni_d_employee_value + l_ni_e_employee_value +
                   l_ni_f_employee_value + l_ni_g_employee_value +
                   l_ni_j_employee_value + l_ni_l_employee_value +
                   l_ni_s_employee_value;
--
END;
--
-----------------------------------------------------------------------
--
PROCEDURE get_report_balances (p_assignment_action_id in     number,
			       p_business_group_id    in     number,
			       p_label_1              in out nocopy varchar2,
			       p_value_1              in out nocopy number,
			       p_label_2              in out nocopy varchar2,
			       p_value_2              in out nocopy number,
			       p_label_3              in out nocopy varchar2,
			       p_value_3              in out nocopy number,
			       p_label_4              in out nocopy varchar2,
			       p_value_4              in out nocopy number,
			       p_label_5              in out nocopy varchar2,
			       p_value_5              in out nocopy number,
			       p_label_6              in out nocopy varchar2,
			       p_value_6              in out nocopy number,
			       p_label_7              in out nocopy varchar2,
			       p_value_7              in out nocopy number,
			       p_label_8              in out nocopy varchar2,
			       p_value_8              in out nocopy number,
			       p_label_9              in out nocopy varchar2,
			       p_value_9              in out nocopy number,
			       p_label_a              in out nocopy varchar2,
			       p_value_a              in out nocopy number,
			       p_label_b              in out nocopy varchar2,
			       p_value_b              in out nocopy number,
			       p_label_c              in out nocopy varchar2,
			       p_value_c              in out nocopy number) is
--
--
CURSOR c_selected_balances IS
  SELECT pur.row_low_range_or_name row_name,
  	 puci.value user_desc
  FROM	 pay_user_rows pur,
  	 pay_user_columns puc,
  	 pay_user_tables put,
  	 pay_user_column_instances puci
  WHERE	 put.user_table_name = g_user_table_name
  AND	 put.legislation_code = 'GB'
  AND	 puc.user_column_name = 'Narrative'
  AND	 puc.user_table_id = put.user_table_id
  AND	 puc.legislation_code = 'GB'
  AND	 puci.user_column_id = puc.user_column_id
  AND	 puci.value IS NOT NULL
  AND    puci.business_group_id = p_business_group_id
  AND	 pur.user_row_id = puci.user_row_id;
--
CURSOR c_balance_check(user_balance varchar2) IS
  SELECT 1
  FROM   pay_balance_types pbt,
 	 pay_balance_dimensions pbd,
	 pay_defined_balances pdb
  WHERE  pdb.balance_type_id = pbt.balance_type_id
  AND	 pdb.balance_dimension_id = pbd.balance_dimension_id
  AND    pbt.balance_name = user_balance
  AND	 nvl(pbt.legislation_code,'GB') = 'GB'
  AND	 nvl(pbd.legislation_code,'GB') = 'GB'
  AND	 nvl(pdb.legislation_code,'GB') = 'GB';

CURSOR csr_user_defined_balance(row_name varchar2) is
  SELECT pbt.balance_name,
         pbd.database_item_suffix
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
  WHERE  pbt.balance_type_id = pdb.balance_type_id
  AND    pbd.balance_dimension_id = pdb.balance_dimension_id
  AND    row_name = pbt.balance_name || pbd.database_item_suffix;

CURSOR csr_get_action_type(c_assignment_action_id number) is
  SELECT ppa.action_type
  FROM   pay_payroll_actions ppa,
         pay_assignment_actions paa
  WHERE  ppa.payroll_action_id = paa.payroll_action_id
  AND    paa.assignment_action_id = c_assignment_action_id;

l_calculated_employer number;
l_calculated_balance number := 0;
l_display_count number := 1;
l_balance_check number;
l_balance_name varchar2(80);
l_dimension varchar2(80);
l_user_bal_dim varchar2(150);
l_user_desc varchar2(30);
l_seq_no number;
l_bal_ix binary_integer;
l_max_seq_no number := 1000;
l_user_defined_row_cnt number := 0;
l_action_type varchar2(5);
l_prepayment_id number;
--
BEGIN
--
  -- if the assignment action id is not specified then do nothing
  --
  if p_assignment_action_id is null then
  --
    return;
  --
  end if;
  --
  --
  -- initialise the plsql tables and the NI total balances
  --
	g_displayed_balance := g_empty_balances;
	g_displayed_value  := g_empty_values;

	g_ni_a_total_value := 0;
	g_ni_b_total_value := 0;
	g_ni_d_total_value := 0;
	g_ni_e_total_value := 0;
	g_ni_f_total_value := 0;
	g_ni_g_total_value := 0;
        g_ni_j_total_value := 0;
        g_ni_l_total_value := 0;
        g_ni_s_total_value := 0;

  --
  -- establish the total NI balance for each category. This is done now to
  -- cut down on processing when individual NI balances are retrieved later.
  --
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'A') = 1 THEN
    	g_ni_a_total_value := report_balance_items
				(p_balance_name => g_ni_a_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'B') = 1 THEN
	g_ni_b_total_value := report_balance_items
				(p_balance_name => g_ni_b_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'D') = 1 THEN
	g_ni_d_total_value := report_balance_items
				(p_balance_name => g_ni_d_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'E') = 1 THEN
	g_ni_e_total_value := report_balance_items
				(p_balance_name => g_ni_e_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'F') = 1 THEN
	g_ni_f_total_value := report_balance_items
				(p_balance_name => g_ni_f_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'G') = 1 THEN
	g_ni_g_total_value := report_balance_items
				(p_balance_name => g_ni_g_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'J') = 1 THEN
        g_ni_j_total_value := report_balance_items
                                (p_balance_name => g_ni_j_total_type,
                                 p_dimension => g_tax_district_ytd,
                                 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'L') = 1 THEN
        g_ni_l_total_value := report_balance_items
                                (p_balance_name => g_ni_l_total_type,
                                 p_dimension => g_tax_district_ytd,
                                 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'S') = 1 THEN
        g_ni_s_total_value := report_balance_items
                                (p_balance_name => g_ni_s_total_type,
                                 p_dimension => g_tax_district_ytd,
                                 p_assignment_action_id => p_assignment_action_id);
         end if;

        OPEN csr_get_action_type(p_assignment_action_id);
        FETCH csr_get_action_type INTO l_action_type;
        CLOSE csr_get_action_type;
  --
  -- if the action type is Q or R, check to see whether or not the PrePayment has been run
  --
        if l_action_type in ('Q','R') then
          BEGIN
           l_prepayment_id := pay_core_utils.get_pp_action_id(l_action_type,p_assignment_action_id);
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_prepayment_id  := NULL;
          END;
        end if;
  --
        for rec in c_selected_balances loop

		l_user_defined_row_cnt := l_user_defined_row_cnt + 1;

                if rec.row_name like '%USER-REG'
                then
                  l_user_bal_dim := replace(rec.row_name,'  USER-REG');
                  open csr_user_defined_balance(l_user_bal_dim);
                  fetch csr_user_defined_balance into l_balance_name,
                                                      l_dimension;
                  close csr_user_defined_balance;
                else
                  l_balance_name := substr(rec.row_name,1,(instr(rec.row_name,' ',-1,1) - 1));
                  l_dimension := substr(rec.row_name,instr(rec.row_name,' ',-1,1));
                  l_dimension := replace(l_dimension,' ','_');
                end if;

          -- if the prepayment hasn't been run then use SOE_RUN dimension instead of PAYMENTS
          --
             if l_prepayment_id IS NULL then
                  l_dimension := replace(l_dimension,'PAYMENTS','SOE_RUN');
             end if;

        	open c_balance_check(l_balance_name);
        	fetch c_balance_check into l_balance_check;
  --
  -- if the balance is not in the pay_balance_types table, then it is a balance for all
  -- NI categories and its value is determined differently
  --
 	      	if c_balance_check%NOTFOUND
        	then
	       		l_calculated_balance := report_all_ni_balance
        					(p_balance_name => l_balance_name,
        					 p_dimension => l_dimension,
        					 p_assignment_action_id => p_assignment_action_id);
        	else
			if l_balance_name = 'NI Employer'
			then
				l_calculated_balance := report_employer_balance
							 (p_assignment_action_id => p_assignment_action_id);
			else
	        		l_calculated_balance := report_balance_items
        						 (p_balance_name => l_balance_name,
        						  p_dimension => l_dimension,
        						  p_assignment_action_id => p_assignment_action_id);
        		end if;
        	end if;

        	close c_balance_check;
  --
  -- only balances with non-zero values should be returned for display
  --
            	if l_calculated_balance <> 0
        	then
  --
			find_user_table_values(rec.row_name,
					       p_business_group_id,
					       l_seq_no);
	--
	-- if the sequence number is either not defined or is a duplicate then
	-- the balance is sorted to the end
	--
			if g_displayed_balance.EXISTS(l_seq_no) or l_seq_no is NULL
			then
				l_seq_no := l_max_seq_no;
				l_max_seq_no := l_max_seq_no + 10;
			end if;

        		g_displayed_balance(l_seq_no) := rec.user_desc;
               		g_displayed_value(l_seq_no) := l_calculated_balance;
        		l_display_count := l_display_count + 1;

        	end if;
  --
	end loop;
  --
  -- If no rows have been defined in the user defined table, then a default set of balances
  -- will be displayed, if they have non-zero values
  --
	if l_user_defined_row_cnt = 0
        then

	        l_display_count := 1;

		l_calculated_balance := report_balance_items
				 	(p_balance_name => 'Gross Pay',
					 p_dimension => '_ASG_YTD',
					 p_assignment_action_id => p_assignment_action_id);
	        if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'Gross YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_balance_items
					(p_balance_name => 'Gross Pay',
					 p_dimension => '_ASG_PROC_PTD',
					 p_assignment_action_id => p_assignment_action_id);
	        if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'Gross PTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_balance_items
					(p_balance_name => 'Taxable Pay',
				  	 p_dimension => '_ASG_TD_YTD',
				  	 p_assignment_action_id => p_assignment_action_id);
	        if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'Taxable YTD';
         	      	g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_balance_items
					(p_balance_name => 'Taxable Pay',
					 p_dimension => '_ASG_TRANSFER_PTD',
					 p_assignment_action_id => p_assignment_action_id);
        	if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'Taxable PTD';
              	 	g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_balance_items
					(p_balance_name => 'PAYE',
					 p_dimension => '_ASG_TD_YTD',
					 p_assignment_action_id => p_assignment_action_id);
        	if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'PAYE YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_all_ni_balance
					(p_balance_name => 'NI Able',
					 p_dimension => '_ASG_TD_YTD',
					 p_assignment_action_id => p_assignment_action_id);
 	       if l_calculated_balance <> 0
	       then
        		g_displayed_balance(l_display_count) := 'NIable YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

	       l_calculated_balance := report_all_ni_balance
				       (p_balance_name => 'NI Able',
					p_dimension => '_ASG_TRANSFER_PTD',
				 	p_assignment_action_id => p_assignment_action_id);
               if l_calculated_balance <> 0
               then
        		g_displayed_balance(l_display_count) := 'NIable PTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

	       l_calculated_balance := report_all_ni_balance
				       (p_balance_name => 'NI Employee',
				        p_dimension => '_ASG_TD_YTD',
				        p_assignment_action_id => p_assignment_action_id);
       	       if l_calculated_balance <> 0
               then
        		g_displayed_balance(l_display_count) := 'NI Ees YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

               l_calculated_balance := report_employer_balance
	   		               (p_assignment_action_id => p_assignment_action_id);
               if l_calculated_balance <> 0
               then
        		g_displayed_balance(l_display_count) := 'NI Ers YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

	       l_calculated_balance := report_balance_items
				       (p_balance_name => 'Superannuation Total',
				        p_dimension => '_ASG_TD_YTD',
				        p_assignment_action_id => p_assignment_action_id);
               if l_calculated_balance <> 0
               then
        		g_displayed_balance(l_display_count) := 'Superan YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

    end if;
  --
  -- the pl/sql table must hold 12 rows, so add dummy rows if less then 12 rows have
  -- been created
  --
	while l_display_count < 13 loop
		l_max_seq_no := l_max_seq_no + 10;
		g_displayed_balance(l_max_seq_no) := null;
		g_displayed_value(l_max_seq_no) := null;
		l_display_count := l_display_count + 1;
	end loop;
  --
  -- populate the output paramters from the pl/sql table
  --
	l_bal_ix := g_displayed_balance.first;
	p_label_1 := g_displayed_balance(l_bal_ix);
	p_value_1 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_2 := g_displayed_balance(l_bal_ix);
	p_value_2 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_3 := g_displayed_balance(l_bal_ix);
	p_value_3 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_4 := g_displayed_balance(l_bal_ix);
	p_value_4 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_5 := g_displayed_balance(l_bal_ix);
	p_value_5 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_6 := g_displayed_balance(l_bal_ix);
	p_value_6 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_7 := g_displayed_balance(l_bal_ix);
	p_value_7 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_8 := g_displayed_balance(l_bal_ix);
	p_value_8 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_9 := g_displayed_balance(l_bal_ix);
	p_value_9 := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_a := g_displayed_balance(l_bal_ix);
	p_value_a := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_b := g_displayed_balance(l_bal_ix);
	p_value_b := g_displayed_value(l_bal_ix);

	l_bal_ix := g_displayed_balance.next(l_bal_ix);
	p_label_c := g_displayed_balance(l_bal_ix);
	p_value_c := g_displayed_value(l_bal_ix);
  --
  --
  END;

/* Start of bug#8497345*/
/* Created overloaded procedure same as get_report_balances */
/* bug#8497345 - Commented out the variables as now we need the return the PL/SQL table variables*/
PROCEDURE get_report_balances (p_assignment_action_id in     number,
			       p_business_group_id    in     number,
                               g_displayed_balance    in out nocopy balance_name_table,
                               g_displayed_value      in out nocopy balance_value_table) is
--
--
CURSOR c_selected_balances IS
  SELECT pur.row_low_range_or_name row_name,
  	 puci.value user_desc
  FROM	 pay_user_rows pur,
  	 pay_user_columns puc,
  	 pay_user_tables put,
  	 pay_user_column_instances puci
  WHERE	 put.user_table_name = g_user_table_name
  AND	 put.legislation_code = 'GB'
  AND	 puc.user_column_name = 'Narrative'
  AND	 puc.user_table_id = put.user_table_id
  AND	 puc.legislation_code = 'GB'
  AND	 puci.user_column_id = puc.user_column_id
  AND	 puci.value IS NOT NULL
  AND    puci.business_group_id = p_business_group_id
  AND	 pur.user_row_id = puci.user_row_id;
--
CURSOR c_balance_check(user_balance varchar2) IS
  SELECT 1
  FROM   pay_balance_types pbt,
 	 pay_balance_dimensions pbd,
	 pay_defined_balances pdb
  WHERE  pdb.balance_type_id = pbt.balance_type_id
  AND	 pdb.balance_dimension_id = pbd.balance_dimension_id
  AND    pbt.balance_name = user_balance
  AND	 nvl(pbt.legislation_code,'GB') = 'GB'
  AND	 nvl(pbd.legislation_code,'GB') = 'GB'
  AND	 nvl(pdb.legislation_code,'GB') = 'GB';

CURSOR csr_user_defined_balance(row_name varchar2) is
  SELECT pbt.balance_name,
         pbd.database_item_suffix
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
  WHERE  pbt.balance_type_id = pdb.balance_type_id
  AND    pbd.balance_dimension_id = pdb.balance_dimension_id
  AND    row_name = pbt.balance_name || pbd.database_item_suffix;

CURSOR csr_get_action_type(c_assignment_action_id number) is
  SELECT ppa.action_type
  FROM   pay_payroll_actions ppa,
         pay_assignment_actions paa
  WHERE  ppa.payroll_action_id = paa.payroll_action_id
  AND    paa.assignment_action_id = c_assignment_action_id;

l_calculated_employer number;
l_calculated_balance number := 0;
l_display_count number := 1;
l_balance_check number;
l_balance_name varchar2(80);
l_dimension varchar2(80);
l_user_bal_dim varchar2(150);
l_user_desc varchar2(30);
l_seq_no number;
l_bal_ix binary_integer;
l_max_seq_no number := 1000;
l_user_defined_row_cnt number := 0;
l_action_type varchar2(5);
l_prepayment_id number;
--
BEGIN
--
  -- if the assignment action id is not specified then do nothing
  --
  if p_assignment_action_id is null then
  --
    return;
  --
  end if;
  --
  --
  -- initialise the plsql tables and the NI total balances
  --
	g_displayed_balance := g_empty_balances;
	g_displayed_value  := g_empty_values;

	g_ni_a_total_value := 0;
	g_ni_b_total_value := 0;
	g_ni_d_total_value := 0;
	g_ni_e_total_value := 0;
	g_ni_f_total_value := 0;
	g_ni_g_total_value := 0;
        g_ni_j_total_value := 0;
        g_ni_l_total_value := 0;
        g_ni_s_total_value := 0;

  --
  -- establish the total NI balance for each category. This is done now to
  -- cut down on processing when individual NI balances are retrieved later.
  --
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'A') = 1 THEN
    	g_ni_a_total_value := report_balance_items
				(p_balance_name => g_ni_a_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;
 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'B') = 1 THEN
	g_ni_b_total_value := report_balance_items
				(p_balance_name => g_ni_b_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'D') = 1 THEN
	g_ni_d_total_value := report_balance_items
				(p_balance_name => g_ni_d_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'E') = 1 THEN
	g_ni_e_total_value := report_balance_items
				(p_balance_name => g_ni_e_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'F') = 1 THEN
	g_ni_f_total_value := report_balance_items
				(p_balance_name => g_ni_f_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'G') = 1 THEN
	g_ni_g_total_value := report_balance_items
				(p_balance_name => g_ni_g_total_type,
				 p_dimension => g_tax_district_ytd,
				 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'J') = 1 THEN
        g_ni_j_total_value := report_balance_items
                                (p_balance_name => g_ni_j_total_type,
                                 p_dimension => g_tax_district_ytd,
                                 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'L') = 1 THEN
        g_ni_l_total_value := report_balance_items
                                (p_balance_name => g_ni_l_total_type,
                                 p_dimension => g_tax_district_ytd,
                                 p_assignment_action_id => p_assignment_action_id);
         end if;

 IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(p_assignment_action_id,'S') = 1 THEN
        g_ni_s_total_value := report_balance_items
                                (p_balance_name => g_ni_s_total_type,
                                 p_dimension => g_tax_district_ytd,
                                 p_assignment_action_id => p_assignment_action_id);
         end if;

        OPEN csr_get_action_type(p_assignment_action_id);
        FETCH csr_get_action_type INTO l_action_type;
        CLOSE csr_get_action_type;
  --
  -- if the action type is Q or R, check to see whether or not the PrePayment has been run
  --
        if l_action_type in ('Q','R') then
          BEGIN
           l_prepayment_id := pay_core_utils.get_pp_action_id(l_action_type,p_assignment_action_id);
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_prepayment_id  := NULL;
          END;
        end if;
  --
        for rec in c_selected_balances loop

		l_user_defined_row_cnt := l_user_defined_row_cnt + 1;

                if rec.row_name like '%USER-REG'
                then
                  l_user_bal_dim := replace(rec.row_name,'  USER-REG');
                  open csr_user_defined_balance(l_user_bal_dim);
                  fetch csr_user_defined_balance into l_balance_name,
                                                      l_dimension;
                  close csr_user_defined_balance;
                else
                  l_balance_name := substr(rec.row_name,1,(instr(rec.row_name,' ',-1,1) - 1));
                  l_dimension := substr(rec.row_name,instr(rec.row_name,' ',-1,1));
                  l_dimension := replace(l_dimension,' ','_');
                end if;

          -- if the prepayment hasn't been run then use SOE_RUN dimension instead of PAYMENTS
          --
             if l_prepayment_id IS NULL then
                  l_dimension := replace(l_dimension,'PAYMENTS','SOE_RUN');
             end if;

        	open c_balance_check(l_balance_name);
        	fetch c_balance_check into l_balance_check;
  --
  -- if the balance is not in the pay_balance_types table, then it is a balance for all
  -- NI categories and its value is determined differently
  --
 	      	if c_balance_check%NOTFOUND
        	then
	       		l_calculated_balance := report_all_ni_balance
        					(p_balance_name => l_balance_name,
        					 p_dimension => l_dimension,
        					 p_assignment_action_id => p_assignment_action_id);
        	else
			if l_balance_name = 'NI Employer'
			then
				l_calculated_balance := report_employer_balance
							 (p_assignment_action_id => p_assignment_action_id);
			else
	        		l_calculated_balance := report_balance_items
        						 (p_balance_name => l_balance_name,
        						  p_dimension => l_dimension,
        						  p_assignment_action_id => p_assignment_action_id);
        		end if;
        	end if;

        	close c_balance_check;
  --
  -- only balances with non-zero values should be returned for display
  --
            	if l_calculated_balance <> 0
        	then
  --
			find_user_table_values(rec.row_name,
					       p_business_group_id,
					       l_seq_no);
	--
	-- if the sequence number is either not defined or is a duplicate then
	-- the balance is sorted to the end
	--
			if g_displayed_balance.EXISTS(l_seq_no) or l_seq_no is NULL
			then
				l_seq_no := l_max_seq_no;
				l_max_seq_no := l_max_seq_no + 10;
			end if;

        		g_displayed_balance(l_seq_no) := rec.user_desc;
               		g_displayed_value(l_seq_no) := l_calculated_balance;
        		l_display_count := l_display_count + 1;

        	end if;
  --
	end loop;
  --
  -- If no rows have been defined in the user defined table, then a default set of balances
  -- will be displayed, if they have non-zero values
  --
	if l_user_defined_row_cnt = 0
        then

	        l_display_count := 1;

		l_calculated_balance := report_balance_items
				 	(p_balance_name => 'Gross Pay',
					 p_dimension => '_ASG_YTD',
					 p_assignment_action_id => p_assignment_action_id);
	        if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'Gross YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_balance_items
					(p_balance_name => 'Gross Pay',
					 p_dimension => '_ASG_PROC_PTD',
					 p_assignment_action_id => p_assignment_action_id);
	        if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'Gross PTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_balance_items
					(p_balance_name => 'Taxable Pay',
				  	 p_dimension => '_ASG_TD_YTD',
				  	 p_assignment_action_id => p_assignment_action_id);
	        if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'Taxable YTD';
         	      	g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_balance_items
					(p_balance_name => 'Taxable Pay',
					 p_dimension => '_ASG_TRANSFER_PTD',
					 p_assignment_action_id => p_assignment_action_id);
        	if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'Taxable PTD';
              	 	g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_balance_items
					(p_balance_name => 'PAYE',
					 p_dimension => '_ASG_TD_YTD',
					 p_assignment_action_id => p_assignment_action_id);
        	if l_calculated_balance <> 0
        	then
        		g_displayed_balance(l_display_count) := 'PAYE YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
		end if;

		l_calculated_balance := report_all_ni_balance
					(p_balance_name => 'NI Able',
					 p_dimension => '_ASG_TD_YTD',
					 p_assignment_action_id => p_assignment_action_id);
 	       if l_calculated_balance <> 0
	       then
        		g_displayed_balance(l_display_count) := 'NIable YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

	       l_calculated_balance := report_all_ni_balance
				       (p_balance_name => 'NI Able',
					p_dimension => '_ASG_TRANSFER_PTD',
				 	p_assignment_action_id => p_assignment_action_id);
               if l_calculated_balance <> 0
               then
        		g_displayed_balance(l_display_count) := 'NIable PTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

	       l_calculated_balance := report_all_ni_balance
				       (p_balance_name => 'NI Employee',
				        p_dimension => '_ASG_TD_YTD',
				        p_assignment_action_id => p_assignment_action_id);
       	       if l_calculated_balance <> 0
               then
        		g_displayed_balance(l_display_count) := 'NI Ees YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

               l_calculated_balance := report_employer_balance
	   		               (p_assignment_action_id => p_assignment_action_id);
               if l_calculated_balance <> 0
               then
        		g_displayed_balance(l_display_count) := 'NI Ers YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

	       l_calculated_balance := report_balance_items
				       (p_balance_name => 'Superannuation Total',
				        p_dimension => '_ASG_TD_YTD',
				        p_assignment_action_id => p_assignment_action_id);
               if l_calculated_balance <> 0
               then
        		g_displayed_balance(l_display_count) := 'Superan YTD';
               		g_displayed_value(l_display_count) := l_calculated_balance;
		 	l_display_count := l_display_count + 1;
	       end if;

    end if;

   /* End of bug#8497345*/
  --
  --
  END;
--
-------------------------------------------------------------------------------
--
procedure formula_inputs_wf (p_session_date             in     date,
			     p_payroll_exists           in out nocopy varchar2,
			     p_assignment_action_id     in out nocopy number,
			     p_run_assignment_action_id in out nocopy number,
			     p_assignment_id            in     number,
			     p_payroll_action_id        in out nocopy number,
			     p_date_earned              in out nocopy varchar2) is
-- select the latest prepayments action for this individual and get the
-- details of the last run that that action locked
cursor csr_formula is
select /*+ ORDERED USE_NL(paa,ppa,rpaa,rppa) */
        to_char(nvl(rppa.date_earned,rppa.effective_date),'YYYY/MM/DD'),
        rpaa.payroll_action_id,
        rpaa.assignment_action_id,
        paa.assignment_action_id
from    pay_assignment_actions paa,
        pay_payroll_actions ppa,
        pay_assignment_actions rpaa,
        pay_payroll_actions rppa
where  paa.payroll_action_id = ppa.payroll_action_id
and    rppa.payroll_action_id = rpaa.payroll_action_id
and    paa.assignment_id = rpaa.assignment_id
and    paa.assignment_action_id =
        (select
          to_number(substr(max(to_char(pa.effective_date,'J')||lpad(aa.assignment_action_id,15,'0')),8))
          from   pay_payroll_actions pa,
                  pay_assignment_actions aa
          where  pa.action_type in ('U','P')
          and    aa.action_status = 'C'
          and   pa.payroll_action_id = aa.payroll_action_id
          and aa.assignment_id = p_assignment_id
          and pa.effective_date <= p_session_date)
and    ppa.action_type in ('P', 'U')
and    rpaa.assignment_id = p_assignment_id
and    rpaa.action_sequence =
        (select max(aa.action_sequence)
         from   pay_assignment_actions aa,
                pay_action_interlocks loc
         where loc.locked_action_id = aa.assignment_action_id
         and loc.locking_action_id = paa.assignment_action_id);

-- Copied from HR_GBBAL.get_latest_action_id, include action type P and U
cursor csr_formula_2 is
SELECT /*+ USE_NL(paa, ppa) */
  --fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) /*Bug 4775025*/
  to_number(substr(max(to_char(ppa.effective_date,'J')||lpad(paa.assignment_action_id,15,'0')),8))
  FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = p_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
   /* Commented below code, removed action_types 'B' and 'I' for bug fix 4775025*/
   /* AND  (paa.source_action_id is not null
          or ppa.action_type in ('U','P'))*/
    AND  ppa.effective_date <= p_session_date
    AND  ppa.action_type  in ('R', 'Q', 'U', 'P')
    AND  paa.action_status = 'C';

cursor csr_formula_3(p_assig_act_id  NUMBER) is
select to_char(nvl(ppa.date_earned,ppa.effective_date),'YYYY/MM/DD'),
       paa.payroll_action_id
from   pay_payroll_actions ppa,
       pay_assignment_actions paa
where  paa.assignment_action_id = p_assig_act_id
and    ppa.payroll_action_id = paa.payroll_action_id;

cursor csr_formula_4(p_assig_act_id NUMBER) is
select pact.action_type
from   pay_assignment_actions assact,
       pay_payroll_actions pact
where  assact.assignment_action_id = p_assignment_action_id
and    pact.payroll_action_id = assact.payroll_action_id;

cursor csr_formula_5(p_assig_act_id NUMBER) is
select assact.assignment_action_id
from   pay_assignment_actions assact,
       pay_action_interlocks loc
where  loc.locking_action_id = p_assignment_action_id
and    assact.assignment_action_id = loc.locked_action_id
order  by assact.action_sequence desc;

--
l_assignment_action_id NUMBER;
l_action_type   varchar2(1);
--
begin
  --
  l_assignment_action_id := null;
  --
   -- open csr_formula;
  -- fetch csr_formula into p_date_earned,
  --                     p_payroll_action_id,
  --                     p_run_assignment_action_id,
  --                     p_assignment_action_id;
  open csr_formula_2;
  fetch csr_formula_2 into p_assignment_action_id;
  close csr_formula_2;

  if p_assignment_action_id is NOT NULL then
     p_payroll_exists := 'TRUE';

     open csr_formula_4(p_assignment_action_id);
     fetch csr_formula_4 into l_action_type;
     close csr_formula_4;

     if l_action_type in ('P','U') then
        open csr_formula_5(p_assignment_action_id);
        fetch csr_formula_5 into p_run_assignment_action_id;
        close csr_formula_5;
        -- Bug 4584572
     else
        p_run_assignment_action_id := p_assignment_action_id;
     end if;

     open csr_formula_3(p_run_assignment_action_id);
     fetch csr_formula_3 into p_date_earned,
                              p_payroll_action_id;
     close csr_formula_3;

  end if;
  -- if csr_formula_2%FOUND then
  --   p_payroll_exists := 'TRUE';
  -- end if;
  -- close csr_formula;
  --
end formula_inputs_wf;
--
procedure formula_inputs_hc (p_assignment_action_id in out nocopy number,
                             p_run_assignment_action_id in out nocopy number,
			     p_assignment_id        in out nocopy number,
			     p_payroll_action_id    in out nocopy number,
			     p_date_earned          in out nocopy varchar2) is
-- if the action is a run then return the run details
-- if the action is a prepayment return the latest run details locked
cursor csr_formula is
-- find what type of action this is
               select pact.action_type , assact.assignment_id
                             from pay_assignment_actions assact,
                             pay_payroll_actions pact
		    where   assact.assignment_action_id = p_assignment_action_id
                    and     pact.payroll_action_id = assact.payroll_action_id
;
cursor csr_formula_2 is
-- for prepayment action find the latest interlocked run
               select assact.assignment_action_id
                             from pay_assignment_actions assact,
                                  pay_action_interlocks loc
                      where loc.locking_action_id = p_assignment_action_id
                      and   assact.assignment_action_id = loc.locked_action_id
                      order by assact.action_sequence desc
;
cursor csr_formula_3 is
-- for run action check if its been prepaid
               select assact.assignment_action_id
                             from pay_assignment_actions assact,
                                  pay_payroll_actions pact,
                                  pay_action_interlocks loc
                      where loc.locked_action_id = p_assignment_action_id
                      and   assact.assignment_action_id = loc.locking_action_id
                      and   pact.payroll_action_id = assact.payroll_action_id
                      and   pact.action_type in ('P','U') /* prepayments only */
                      order by assact.action_sequence desc
;
cursor csr_formula_4 is
-- now find the date earned and payroll action of the run action
               select pact.payroll_action_id,
               to_char(nvl(pact.date_earned,pact.effective_date),'YYYY/MM/DD')
                             from pay_assignment_actions assact,
                             pay_payroll_actions pact
                where   assact.assignment_action_id = p_run_assignment_action_id
                   and     pact.payroll_action_id = assact.payroll_action_id
;
--
l_action_type varchar2(1);
--
begin
--
  open csr_formula;
  fetch csr_formula into l_action_type, p_assignment_id;
  close csr_formula;
--
  if l_action_type in ('P', 'U') then
     open csr_formula_2;
     fetch csr_formula_2 into p_run_assignment_action_id;
     close csr_formula_2;

     -- Bug 4584572
     -- if its a run action it may or may not have been prepaid

-- Comment out this bit of code because it will always return the prepayment's action_id
-- regardless the type of run being selected.

--   else
--        p_run_assignment_action_id := p_assignment_action_id;
--
--   begin
--        open csr_formula_3;
--        fetch csr_formula_3 into p_assignment_action_id;
--        close csr_formula_3;
--        exception when NO_DATA_FOUND then
--        p_assignment_action_id := p_run_assignment_action_id;
--   end;
  else
     p_run_assignment_action_id := p_assignment_action_id;
  end if;
-- fetch payroll details
  open csr_formula_4;
  fetch csr_formula_4 into p_payroll_action_id,
                           p_date_earned;
  close csr_formula_4;
--

  -- following code superceeded by code above to try and address performance
  -- problem 303467 - some change in functionality so retain old logic as
  -- reference AS 24-AUG-95
--  open csr_formula;
----  fetch csr_formula into p_date_earned,
--			 p_payroll_action_id,
--			 p_assignment_id,
--			 p_run_assignment_action_id,
 --                        p_assignment_action_id;
 --close csr_formula;
 --            to_char(nvl(rppa.date_earned,rppa.effective_date),'YYYY/MM/DD'),
--                         rpaa.payroll_action_id,
--			     rpaa.assignment_id,
--                            rpaa.assignment_action_id,
--                           paa.assignment_action_id
--                   from   pay_assignment_actions paa,
--                         pay_payroll_actions ppa,
--                        pay_assignment_actions rpaa,
--			     pay_payroll_actions rppa
--                     where  paa.payroll_action_id = ppa.payroll_action_id
--                    and    rppa.payroll_action_id = rpaa.payroll_action_id
--                   and    paa.assignment_action_id = p_assignment_action_id
--                  and (   ppa.action_type in ('R', 'Q')
--		      and    paa.action_status = 'C'
--		      and    rpaa.assignment_action_id = p_assignment_action_id
--                     or ( ppa.action_type in ('P', 'U')
--                    and rpaa.action_sequence =
--                           (select max(aa.action_sequence)
--                           from   pay_assignment_actions aa,
--                                 pay_action_interlocks loc
--	           where loc.locked_action_id = aa.assignment_action_id
--                       and loc.locking_action_id = p_assignment_action_id)))
--;
  --
end formula_inputs_hc;
--
procedure get_home_add(p_person_id IN NUMBER,
                       p_add1 IN out nocopy VARCHAR2,
                       p_add2 IN out nocopy VARCHAR2,
                       p_add3 IN out nocopy VARCHAR2,
                       p_reg1 IN out nocopy VARCHAR2,
                       p_reg2 IN out nocopy VARCHAR2,
                       p_reg3 IN out nocopy VARCHAR2,
                       p_twnc IN out nocopy VARCHAR2) is
--
cursor homeadd is
select pad.address_line1,
       pad.address_line2,
       pad.address_line3,
       l.meaning,
       pad.postal_code,
       pad.region_3,
       pad.town_or_city
from   per_addresses pad,
       hr_lookups l
where  pad.person_id = p_person_id
and    pad.primary_flag = 'Y'
and    l.lookup_type(+) = 'GB_COUNTY'
and    l.lookup_code(+) = pad.region_1
and    sysdate between nvl(pad.date_from, sysdate)
                   and nvl(pad.date_to,   sysdate);
--
begin
--
open homeadd;
--
fetch homeadd into p_add1,
                   p_add2,
                   p_add3,
                   p_reg1,
                   p_reg2,
                   p_reg3,
                   p_twnc;
--
close homeadd;

end get_home_add;
--
procedure get_work_add(p_location_id IN NUMBER,
                       p_add1 IN out nocopy VARCHAR2,
                       p_add2 IN out nocopy VARCHAR2,
                       p_add3 IN out nocopy VARCHAR2,
                       p_reg1 IN out nocopy VARCHAR2,
                       p_reg2 IN out nocopy VARCHAR2,
                       p_reg3 IN out nocopy VARCHAR2,
                       p_twnc IN out nocopy VARCHAR2) is
--
cursor workadd is
select
       hrl.address_line_1,
       hrl.address_line_2,
       hrl.address_line_3,
       l.meaning,
       hrl.region_2,
       hrl.region_3,
       hrl.town_or_city
from   hr_locations hrl,
       hr_lookups l
where  hrl.location_id = p_location_id
and    l.lookup_type(+) = 'GB_COUNTY'
and    l.lookup_code(+) = hrl.region_1;
--
begin
--
open workadd;
--
fetch workadd into p_add1,
                   p_add2,
                   p_add3,
                   p_reg1,
                   p_reg2,
                   p_reg3,
                   p_twnc;
--
close workadd;
--
end get_work_add;
--
-----------------------------------------------------------------------
--
procedure add_new_soe_balance (p_business_group_id in number,
	  	               p_balance_name 	 in varchar2,
	     	               p_dimension_name	 in varchar2) is

--
-- when a new balance/dimension is added to the system this procedure
-- should be called to add the new balance/dimension to the SOE Balance
-- table
--

cursor c_find_table_id is
select put.user_table_id
from   pay_user_tables put
where  put.user_table_name = g_user_table_name
and    put.business_group_id is NULL
and    put.legislation_code = 'GB';

cursor csr_dimension_suffix is
select decode(legislation_code,
              'GB',replace(database_item_suffix,database_item_suffix,
                           ' ' || substr(database_item_suffix,2)),
              database_item_suffix || '  USER-REG')
from   pay_balance_dimensions pbd
where  dimension_name = p_dimension_name;

l_user_table_id number;
l_user_row_id   number;
l_legislation_code varchar2(2);
l_dimension_suffix varchar2(40);

begin

open  c_find_table_id;
fetch c_find_table_id into l_user_table_id;
close c_find_table_id;

select pay_user_rows_s.nextval into l_user_row_id
from  dual;

if p_business_group_id is null
then
     l_legislation_code := 'GB';
else
     l_legislation_code := null;
end if;

open  csr_dimension_suffix;
fetch csr_dimension_suffix into l_dimension_suffix;
close csr_dimension_suffix;

-- the column row_low_range or name is varchar2(80), so the
-- total length of the balance name + dimension name cannot
-- be more then 80 characters

if length(p_balance_name || l_dimension_suffix) > 80
then
-- message('SOE Balances has not been updated');
  null;
else
  insert into PAY_USER_ROWS_F
     (USER_ROW_ID,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      USER_TABLE_ID,
      ROW_LOW_RANGE_OR_NAME,
      DISPLAY_SEQUENCE,
      LEGISLATION_SUBGROUP,
      ROW_HIGH_RANGE)
  values
     (l_user_row_id,
      to_date('1900/01/01','YYYY/MM/DD'),
      to_date('4712/12/31','YYYY/MM/DD'),
      p_business_group_id,
      l_legislation_code,
      l_user_table_id,
      p_balance_name || l_dimension_suffix,
      NULL,
      NULL,
      NULL);
end if;

end add_new_soe_balance;
--
-------------------------------------------------------------------------------
--
procedure add_new_soe_balance(p_balance_name 	 in varchar2,
	     	              p_dimension_name	 in varchar2) is

cursor c_find_table_id is
select put.user_table_id
from   pay_user_tables put
where  put.user_table_name = g_user_table_name
and    put.business_group_id is NULL
and    put.legislation_code = 'GB';

cursor c_check_row_exists(l_user_table_id number) is
select 1
from   pay_user_rows_f pur,
       pay_balance_dimensions pbd
where  pur.row_low_range_or_name =
       p_balance_name ||
         replace(pbd.database_item_suffix,pbd.database_item_suffix,
                   ' '|| substr(pbd.database_item_suffix,2))
and    pbd.dimension_name = p_dimension_name
and    pur.user_table_id = l_user_table_id;

l_user_table_id number;
l_check_row number;

begin

open  c_find_table_id;
fetch c_find_table_id into l_user_table_id;
close c_find_table_id;

open  c_check_row_exists(l_user_table_id);
fetch c_check_row_exists into l_check_row;

if c_check_row_exists%NOTFOUND
then

  add_new_soe_balance(NULL,
  		      p_balance_name,
  		      p_dimension_name);

end if;

close c_check_row_exists;

end add_new_soe_balance;
--
---------------------------------------------------------------------------------
--
function GET_SALARY (
--
           p_pay_basis_id   number,
           p_assignment_id  number,
           p_effective_date date)   return varchar2  is
--
-- clone of hr_general.get_salary but fetcH At a given date
-- This cursor gets the screen_entry_value from pay_element_entry_values_f.
-- This is the salary amount
-- obtained when the pay basis isn't null. The pay basis and assignment_id
-- are passed in by the view. A check is made on the effective date of
-- pay_element_entry_values_f and pay_element_entries_f as they're datetracked.
--
cursor csr_lookup is
       select sum(eev.screen_entry_value)
       from   pay_element_entry_values_f eev,
              per_pay_bases              ppb,
              pay_element_entries_f       pe
       where  ppb.pay_basis_id  +0 = p_pay_basis_id
       and    pe.assignment_id     = p_assignment_id
       and    eev.input_value_id   = ppb.input_value_id
       and    eev.element_entry_id = pe.element_entry_id

       and    eev.input_value_id   = ppb.input_value_id
       and    eev.element_entry_id = pe.element_entry_id
       and    p_effECtive_date between
                        eev.effective_start_date and eev.effective_end_date
       and    p_EFfective_date between
                        pe.effective_start_date and pe.effective_end_date;
--
  v_meaning          varchar2(60) := null;
begin
  --
  -- Only open the cursor if the parameter may retrieve anything
  -- In practice, p_assignment_id is always going to be non null;
  -- p_pay_basis_id may be null, though. If it is, don't bother trying
  -- to fetch a salary.
  --
  -- If we do have a pay basis, try and get a salary. There may not be one,
  -- in which case no problem: just return null.
  --
    if p_pay_basis_id is not null and p_assignment_id is not null then
      open csr_lookup;
      fetch csr_lookup into v_meaning;
      close csr_lookup;

    end if;
  --
  -- Return the salary value, if this does not exist, return a null value.
  --
  return v_meaning;
end get_salary;

-----------------------------------------------------------------------


END PAY_GB_PAYROLL_ACTIONS_PKG;

/
