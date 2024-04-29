--------------------------------------------------------
--  DDL for Package Body PAY_NL_WAGE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_WAGE_REPORT_PKG" AS
/* $Header: pynlwrar.pkb 120.7.12010000.15 2010/03/03 09:34:30 rsahai ship $ */
--------------------------------------------------------------------------------
-- Global Variables
--------------------------------------------------------------------------------
--
g_public_org_flag hr_lookups.lookup_type%TYPE;
g_risk_cover_flag hr_lookups.lookup_type%TYPE;
g_contract_code_mapping hr_lookups.lookup_type%TYPE;
g_retro_type VARCHAR2(3);
g_effective_date DATE;
--
--------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters(p_payroll_action_id  IN         NUMBER
                            ,p_business_group_id  OUT NOCOPY NUMBER
                            ,p_start_date         OUT NOCOPY DATE
                            ,p_end_date           OUT NOCOPY DATE
                            ,p_legal_employer     OUT NOCOPY NUMBER
                            ,p_payroll_type       OUT NOCOPY VARCHAR2
                            ,p_seq_no             OUT NOCOPY VARCHAR2) IS
  --
  CURSOR csr_parameter_info (c_payroll_action_id NUMBER) IS
  SELECT get_parameters(c_payroll_action_id, 'Legal_Employer')
        ,get_parameters(c_payroll_action_id, 'Payroll_Type')
        ,get_parameters(c_payroll_action_id, 'Sequence_Number')
        ,start_date
        ,effective_date
        ,business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = c_payroll_action_id;
--
BEGIN
  --
  OPEN csr_parameter_info (p_payroll_action_id);
  FETCH csr_parameter_info INTO  p_legal_employer
                                ,p_payroll_type
                                ,p_seq_no
                                ,p_start_date
                                ,p_end_date
                                ,p_business_group_id;
  CLOSE csr_parameter_info;
  IF p_payroll_type = 'YEARLY' THEN
    p_start_date := to_date('01-01-'||to_char(p_end_date,'YYYY'),'dd-mm-yyyy');
    p_end_date   := to_date('31-12-'||to_char(p_end_date,'YYYY'),'dd-mm-yyyy');
  END IF;
  --
END;
--------------------------------------------------------------------------------
-- GET_PARAMETERS
--------------------------------------------------------------------------------
FUNCTION get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2) RETURN VARCHAR2 IS
  CURSOR csr_parameter_info IS
  SELECT SUBSTR(legislative_parameters,
         INSTR(legislative_parameters,p_token_name)+(LENGTH(p_token_name)+1),
         INSTR(legislative_parameters,' ',INSTR(legislative_parameters,p_token_name))
         -(INSTR(legislative_parameters,p_token_name)+(LENGTH(p_token_name)+1)))
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = p_payroll_action_id;
  --
  l_token_value  VARCHAR2(50);
  --
BEGIN
  --
  OPEN csr_parameter_info;
  FETCH csr_parameter_info INTO l_token_value;
  CLOSE csr_parameter_info;
  return(l_token_value);
END get_parameters;
--------------------------------------------------------------------------------
-- RANGE_CODE
--------------------------------------------------------------------------------
PROCEDURE archive_range_code(p_actid IN  NUMBER
                            ,sqlstr  OUT NOCOPY VARCHAR2)
IS
--
BEGIN
  --
  -- Return Range Cursor
  -- Note: There must be one and only one entry of :payroll_action_id in
  -- the string, and the statement must be ordered by person_id
  --
  sqlstr := 'select distinct person_id '||
            'from per_people_f ppf, '||
            'pay_payroll_actions ppa '||
            'where ppa.payroll_action_id = :payroll_action_id '||
            'and ppa.business_group_id = ppf.business_group_id '||
            'order by ppf.person_id';
  --
EXCEPTION
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
    sqlstr := 'select 1 '||
              '/* ERROR - Employer Details Fetch failed with: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';
    hr_utility.set_location(' Leaving: range code',110);
END archive_range_code;
--------------------------------------------------------------------------------
-- get_defined_balance_id   pay_nl_wage_report_pkg.get_defined_balance_id
--------------------------------------------------------------------------------
FUNCTION get_defined_balance_id(p_balance_name         VARCHAR2
                               ,p_database_item_suffix VARCHAR2) RETURN NUMBER IS
--
    CURSOR csr_get_bal_info(c_balance_name         VARCHAR2
                           ,c_database_item_suffix VARCHAR2) IS
    SELECT pdb.defined_balance_id
    FROM   pay_balance_types pbt
          ,pay_balance_dimensions pbd
          ,pay_defined_balances pdb
    WHERE  pbt.balance_name = c_balance_name
    AND    pbt.legislation_code = 'NL'
    AND    pbd.database_item_suffix = c_database_item_suffix
    AND    pbd.legislation_code = 'NL'
    AND    pdb.balance_type_id = pbt.balance_type_id
    AND    pdb.balance_dimension_id = pbd.balance_dimension_id;
    --
    l_defined_bal_id NUMBER;
    --
--
BEGIN
    --
    l_defined_bal_id := 0;
    --
    OPEN  csr_get_bal_info(p_balance_name,p_database_item_suffix);
    FETCH csr_get_bal_info INTO l_defined_bal_id;
    CLOSE csr_get_bal_info;
    --
    RETURN(l_defined_bal_id);
    --
END get_defined_balance_id;
--
--------------------------------------------------------------------------------
-- populate_balance_table   pay_nl_wage_report_pkg.populate_balance_table
--------------------------------------------------------------------------------
PROCEDURE populate_nom_balance_table(p_payroll_type VARCHAR2) IS
--
    --
    l_index NUMBER;
    l_asg_ptd          VARCHAR2(30);
    l_asg_adj_ptd      VARCHAR2(30);
    l_asg_corr_ptd     VARCHAR2(30);
    l_asg_sit_ptd      VARCHAR2(30);
    l_asg_sit_adj_ptd  VARCHAR2(30);
    l_asg_sit_corr_ptd VARCHAR2(30);
    --
BEGIN
    --
    l_asg_ptd          := '_ASG_PTD';
    l_asg_adj_ptd      := '_ASG_ADJ_PTD';
    l_asg_corr_ptd     := '_ASG_REPORT_CORR_PTD';
    l_asg_sit_ptd      := '_ASG_SIT_PTD';
    l_asg_sit_adj_ptd  := '_ASG_SIT_ADJ_PTD';
    l_asg_sit_corr_ptd := '_ASG_SIT_REPORT_CORR_PTD';
    --
    IF g_retro_type = 'NEW' THEN
      l_asg_adj_ptd := NULL;
      l_asg_corr_ptd := '_ASG_BDATE_PTD';
      l_asg_sit_adj_ptd := NULL;
      l_asg_sit_corr_ptd := '_ASG_BDATE_SIT_PTD';
    END IF;
    --
    IF p_payroll_type = 'YEARLY' THEN
        l_asg_ptd          := '_ASG_TU_YTD';
        l_asg_adj_ptd      := NULL;
        l_asg_corr_ptd     := '_ASG_TU_YTD';
        l_asg_sit_ptd      := '_ASG_TU_SIT_YTD';
        l_asg_sit_adj_ptd  := NULL;
        l_asg_sit_corr_ptd := '_ASG_TU_SIT_YTD';
    END IF;
    --
    g_nom_bal_def_table.delete;
    l_index := 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Standard Taxable Income'; --1
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Standard Taxable Income Current Quarter';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Standard Taxable Income Current Quarter';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'SI Income Standard Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro SI Income Standard Tax'; --5
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro SI Income Standard Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'SI Income Special Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro SI Income Special Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro SI Income Special Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'SI Income Non Taxable'; --10
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro SI Income Non Taxable';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro SI Income Non Taxable';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Special Taxable Income';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Special Taxable Income';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Special Taxable Income'; --15
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Holiday Allowance Payment';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Reservation Holiday Allowance';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Additional Period Wage';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Reservation Additional Period Wage';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage In Money Standard Tax SI'; --20
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Money Standard Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Money Standard Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage In Money Special Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Money Special Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Money Special Tax SI'; --25
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage In Kind Standard Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Kind Standard Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Kind Standard Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage In Kind Special Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Kind Special Tax SI'; --30
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Kind Special Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Tips and Fund Payments Standard Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := NULL;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Tips and Fund Payments Standard Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := NULL;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Tips and Fund Payments Standard Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := NULL;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Tips and Fund Payments Special Tax SI'; --35
    g_nom_bal_def_table(l_index).database_item_suffix := NULL;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Tips and Fund Payments Special Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := NULL;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Tips and Fund Payments Special Tax SI';
    g_nom_bal_def_table(l_index).database_item_suffix := NULL;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Overtime';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Standard Tax Deduction';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Standard Tax Deduction Current Quarter'; --40
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Standard Tax Deduction Current Quarter';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Special Tax Deduction';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Special Tax Deduction';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Special Tax Deduction';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report SI Contribution'; --45
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOB';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOB';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOB';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WGA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WGA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution'; --50
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WGA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'IVA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'IVA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'IVA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOD';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution'; --55
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOD';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOD';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWE';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWE';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWE';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Wage Report SI Contribution'; --60
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'UFO';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'UFO';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro SI Contribution'; --65
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'UFO';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Employee SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Wage Report Retro Employee SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage Report Retro Employee SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Tax Travel Allowance';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Labour Tax Reduction'; -- 70
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Labour Tax Reduction';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Labour Tax Reduction';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Real Social Insurance Days';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Real Social Insurance Days';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Real Social Insurance Days'; -- 75
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Hours Worked';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Tax Sea Days Discount';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'WWB Allowance Paid Alimony';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Directly Paid Alimony';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Employer SI Contribution Non Taxable'; --80
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Employer SI Contribution Non Taxable';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Employer SI Contribution Non Taxable'; -- 82
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Employer ZVW Contribution Special Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Employer ZVW Contribution Special Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Employer ZVW Contribution Special Tax'; --85
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Employer ZVW Contribution Standard Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Employer ZVW Contribution Standard Tax'; -- 87
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Employer ZVW Contribution Standard Tax';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Employer SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Employer SI Contribution';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;  -- 90
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Employer SI Contribution'; --  91
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'ZVW';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Standard Taxable Income'; --   92
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Standard Taxable Income';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Standard Tax Deduction';  -- 94
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Standard Tax Deduction'; --  95
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    -- Wage In Money
    g_nom_bal_def_table(l_index).balance_name := 'Wage In Money Standard Tax Only';  --96
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Money Standard Tax Only';  --  97
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Money Standard Tax Only';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage In Money Special Tax Only';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Money Special Tax Only';  --100
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Money Special Tax Only'; --  101
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    -- Wage In Kind
    g_nom_bal_def_table(l_index).balance_name := 'Wage In Kind Standard Tax Only'; -- 102
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Kind Standard Tax Only';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Kind Standard Tax Only';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Wage In Kind Special Tax Only';  --105
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Kind Special Tax Only';
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Wage In Kind Special Tax Only'; -- 107
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Value Private Usage Company Car';   --108
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Employee Value Private Usage Company Car'; --109
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Child Care Employer Contribution'; --  110
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Employee Life Savings Contribution'; --  111
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Life Cycle Leave Discount'; --  112
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Paid Disability Allowance'; --  113
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Standard Tax Correction'; --  114
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Special Tax Correction'; --  115
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Tax Travel Allowance'; -- 116
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Tax Travel Allowance'; -- 117
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Additional Period Wage'; -- 118
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Additional Period Wage'; -- 119
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Life Cycle Leave Discount'; -- 120
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_corr_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Retro Life Cycle Leave Discount'; -- 121
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_adj_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    g_nom_bal_def_table(l_index).balance_name := 'Employer Life Savings Contribution'; --  122
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_ptd;
    g_nom_bal_def_table(l_index).context := NULL;
    g_nom_bal_def_table(l_index).context_val := NULL;
    l_index := l_index + 1;
    --
--LC 2010--begin
    g_nom_bal_def_table(l_index).balance_name := 'Actual SI Base'; --123
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOB';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Retro Actual SI Base'; --124
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOB';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Actual SI Base'; --125
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOB';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Actual SI Base'; --126
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WGA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Retro Actual SI Base'; --127
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WGA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Actual SI Base'; --128
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WGA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Actual SI Base'; --129
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'IVA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Retro Actual SI Base'; --130
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'IVA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Actual SI Base'; --131
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'IVA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Actual SI Base'; --132
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOD';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Retro Actual SI Base'; --133
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOD';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Actual SI Base'; --134
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WAOD';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Actual SI Base'; --135
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWE';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Retro Actual SI Base'; --136
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWE';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Actual SI Base'; --137
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWE';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Actual SI Base'; --138
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'UFO';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Retro Actual SI Base'; --139
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'UFO';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Actual SI Base'; --140
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'UFO';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Actual SI Base'; --141
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name :='Retro Actual SI Base'; --142
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_corr_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWA';
    l_index := l_index + 1;
    --
    g_nom_bal_def_table(l_index).balance_name := 'Retro Actual SI Base'; --143
    g_nom_bal_def_table(l_index).database_item_suffix := l_asg_sit_adj_ptd;
    g_nom_bal_def_table(l_index).context := 'SOURCE_TEXT';
    g_nom_bal_def_table(l_index).context_val := 'WEWA';
    l_index := l_index + 1;
--LC 2010--end
    --
    FOR i in g_nom_bal_def_table.FIRST..g_nom_bal_def_table.LAST LOOP
        g_nom_bal_def_table(i).defined_balance_id := get_defined_balance_id(g_nom_bal_def_table(i).balance_name
                                                                  ,g_nom_bal_def_table(i).database_item_suffix);
    END LOOP;
    --
END populate_nom_balance_table;
--
--------------------------------------------------------------------------------
-- populate_col_balance_values   pay_nl_wage_report_pkg.populate_col_balance_values
--------------------------------------------------------------------------------
PROCEDURE populate_col_balance_values(p_col_bal_def_table IN OUT NOCOPY BAL_COL_TABLE
                                     ,p_tax_unit_id       IN NUMBER
                                     ,p_effective_date    IN DATE
                                     ,p_balance_date      IN DATE
                                     ,p_type              IN VARCHAR2
                                     ,p_si_provider       IN VARCHAR2
                                     ,p_ass_action_id     IN  NUMBER) IS
--
  l_balance_date DATE;
  l_context_id   NUMBER;
  l_tax_unit_id NUMBER;
  l_date_earned DATE;
  l_source_text  VARCHAR2(30);
  l_source_text2 VARCHAR2(30);
  --
  CURSOR  cur_act_contexts(p_context_name VARCHAR2 )IS
  SELECT  ffc.context_id
  FROM    ff_contexts   ffc
  WHERE   ffc.context_name = p_context_name;
--
BEGIN
  --
  --##--Fnd_file.put_line(FND_FILE.LOG,'#### balance value ');
  --##--Fnd_file.put_line(FND_FILE.LOG,'#### p_effective_date '||p_effective_date);
  --##--Fnd_file.put_line(FND_FILE.LOG,'#### p_tax_unit_id '||p_tax_unit_id);
  --##--Fnd_file.put_line(FND_FILE.LOG,'#### p_col_bal_def_table.count '||p_col_bal_def_table.count);
  --
  FOR i IN p_col_bal_def_table.FIRST..p_col_bal_def_table.LAST LOOP
    p_col_bal_def_table(i).balance_value  := 0;
    p_col_bal_def_table(i).balance_value2 := 0;
    IF p_col_bal_def_table(i).defined_balance_id <> 0 AND
      p_type IN ('CORRECTION','COMPLETE') THEN
      l_balance_date := NULL;
      l_context_id   := NULL;
      l_source_text  := NULL;
      l_source_text2 := NULL;
      l_date_earned  := p_balance_date;
      l_tax_unit_id  := p_tax_unit_id;
      --
      IF p_col_bal_def_table(i).database_item_suffix LIKE '%/_REP/_%' ESCAPE '/'
         OR p_col_bal_def_table(i).database_item_suffix2 LIKE '%/_BDATE/_%' ESCAPE '/' THEN
          l_date_earned  := p_effective_date;
          l_balance_date := p_balance_date;
      END IF;
      --
      IF p_col_bal_def_table(i).database_item_suffix LIKE '%/_ADJ/_%' ESCAPE '/'  THEN
          l_balance_date := p_balance_date;
      END IF;
      --
      IF p_col_bal_def_table(i).database_item_suffix LIKE '%/_SIT/_%' ESCAPE '/' THEN
          OPEN  cur_act_contexts('SOURCE_TEXT');
          FETCH cur_act_contexts INTO l_context_id;
          CLOSE cur_act_contexts;
          l_source_text := p_col_bal_def_table(i).context_val;
      END IF;
      --
      IF p_col_bal_def_table(i).database_item_suffix LIKE '%/_SIP/_%' ESCAPE '/' THEN
          OPEN  cur_act_contexts('SOURCE_TEXT');
          FETCH cur_act_contexts INTO l_context_id;
          CLOSE cur_act_contexts;
          l_source_text := p_col_bal_def_table(i).context_val;
          --
          OPEN  cur_act_contexts('SOURCE_TEXT2');
          FETCH cur_act_contexts INTO l_context_id;
          CLOSE cur_act_contexts;
          l_source_text2 := p_si_provider;
      END IF;
      --
      BEGIN
          p_col_bal_def_table(i).balance_value := pay_balance_pkg.get_value
                                                       (p_defined_balance_id   => p_col_bal_def_table(i).defined_balance_id
                                                       ,p_assignment_action_id => p_ass_action_id
                                                       ,p_tax_unit_id          => l_tax_unit_id
                                                       ,p_jurisdiction_code    => NULL
                                                       ,p_source_id            => NULL
                                                       ,p_source_text          => l_source_text
                                                       ,p_tax_group            => NULL
                                                       ,p_date_earned          => l_date_earned
                                                       ,p_get_rr_route         => NULL
                                                       ,p_get_rb_route         => NULL
                                                       ,p_source_text2         => l_source_text2
                                                       ,p_source_number        => NULL
                                                       ,p_time_def_id          => NULL
                                                       ,p_balance_date         => l_balance_date
                                                       ,p_payroll_id           => NULL);
      EXCEPTION
         WHEN OTHERS THEN
         p_col_bal_def_table(i).balance_value := 0;
         --##--Fnd_file.put_line(FND_FILE.LOG,'####'||p_type||' '||p_col_bal_def_table(i).balance_name||' '||p_col_bal_def_table(i).database_item_suffix||' '||p_col_bal_def_table(i).balance_value||' '||p_col_bal_def_table(i).context_val);
         --Fnd_file.put_line(FND_FILE.LOG,'## p_defined_balance_id ' || p_col_bal_def_table(i).defined_balance_id);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_tax_unit_id ' || l_tax_unit_id);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_source_text ' || l_source_text);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_date_earned ' || l_date_earned);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_source_text2 ' || l_source_text2);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_balance_date ' || l_balance_date);
         --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
      END;
      --##--Fnd_file.put_line(FND_FILE.LOG,'#########'||p_type||' '||p_col_bal_def_table(i).balance_name||' '||p_col_bal_def_table(i).database_item_suffix||' '||p_col_bal_def_table(i).balance_value||' '||p_col_bal_def_table(i).context_val);
      --##--Fnd_file.put_line(FND_FILE.LOG,'######### Defined_balance_id : '||p_col_bal_def_table(i).defined_balance_id);
    END IF;
    --
    IF p_col_bal_def_table(i).defined_balance_id2 <> 0  AND
       p_type IN ('CORR_BALANCE','CORRECTION') THEN
      l_balance_date := NULL;
      l_context_id   := NULL;
      l_source_text  := NULL;
      l_source_text2 := NULL;
      l_date_earned  := p_balance_date;
      l_tax_unit_id  := p_tax_unit_id;
      --
      IF p_col_bal_def_table(i).database_item_suffix2 LIKE '%/_REP/_%' ESCAPE '/'
         OR p_col_bal_def_table(i).database_item_suffix2 LIKE '%/_BDATE/_%' ESCAPE '/' THEN
          l_date_earned  := p_effective_date;
          l_balance_date := p_balance_date;
      END IF;
      --
      IF p_col_bal_def_table(i).database_item_suffix2 LIKE '%/_ADJ/_%' ESCAPE '/' THEN
          l_balance_date := p_balance_date;
      END IF;
      --
      IF p_col_bal_def_table(i).database_item_suffix2 LIKE '%/_SIT/_%' ESCAPE '/' THEN
          OPEN  cur_act_contexts('SOURCE_TEXT');
          FETCH cur_act_contexts INTO l_context_id;
          CLOSE cur_act_contexts;
          l_source_text := p_col_bal_def_table(i).context_val;
      END IF;
      --
      IF p_col_bal_def_table(i).database_item_suffix2 LIKE '%/_SIP/_%' ESCAPE '/' THEN
          OPEN  cur_act_contexts('SOURCE_TEXT');
          FETCH cur_act_contexts INTO l_context_id;
          CLOSE cur_act_contexts;
          l_source_text := p_col_bal_def_table(i).context_val;
          --
          OPEN  cur_act_contexts('SOURCE_TEXT2');
          FETCH cur_act_contexts INTO l_context_id;
          CLOSE cur_act_contexts;
          l_source_text2 := p_si_provider;
      END IF;
      --
      BEGIN
          p_col_bal_def_table(i).balance_value2 := pay_balance_pkg.get_value
                                                   (p_defined_balance_id   => p_col_bal_def_table(i).defined_balance_id2
                                                   ,p_assignment_action_id => p_ass_action_id
                                                   ,p_tax_unit_id          => l_tax_unit_id
                                                   ,p_jurisdiction_code    => NULL
                                                   ,p_source_id            => NULL
                                                   ,p_source_text          => l_source_text
                                                   ,p_tax_group            => NULL
                                                   ,p_date_earned          => l_date_earned
                                                   ,p_get_rr_route         => NULL
                                                   ,p_get_rb_route         => NULL
                                                   ,p_source_text2         => l_source_text2
                                                   ,p_source_number        => NULL
                                                   ,p_time_def_id          => NULL
                                                   ,p_balance_date         => l_balance_date
                                                   ,p_payroll_id           => NULL);
      EXCEPTION
         WHEN OTHERS THEN
         p_col_bal_def_table(i).balance_value2 := 0;
         --Fnd_file.put_line(FND_FILE.LOG,'##'||p_type||' '||p_col_bal_def_table(i).balance_name||' '||p_col_bal_def_table(i).database_item_suffix2||' '||p_col_bal_def_table(i).balance_value2||' '||p_col_bal_def_table(i).context_val);
         --Fnd_file.put_line(FND_FILE.LOG,'## p_defined_balance_id ' || p_col_bal_def_table(i).defined_balance_id2);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_tax_unit_id ' || l_tax_unit_id);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_source_text ' || l_source_text);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_date_earned ' || l_date_earned);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_source_text2 ' || l_source_text2);
         --Fnd_file.put_line(FND_FILE.LOG,'## l_balance_date ' || l_balance_date);
         --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
      END;
      --##--Fnd_file.put_line(FND_FILE.LOG,'#########'||p_type||' '||p_col_bal_def_table(i).balance_name||' '||p_col_bal_def_table(i).database_item_suffix2||' '||p_col_bal_def_table(i).balance_value2||' '||p_col_bal_def_table(i).context_val);
      --##--Fnd_file.put_line(FND_FILE.LOG,'######### Defined_balance_id : '||p_col_bal_def_table(i).defined_balance_id2);
    END IF;
  END LOOP;
END populate_col_balance_values;
--
--------------------------------------------------------------------------------
-- populate_col_balance_table   pay_nl_wage_report_pkg.populate_col_balance_table
--------------------------------------------------------------------------------
PROCEDURE populate_col_balance_table(p_payroll_type           VARCHAR2
                                    ,p_effective_date         DATE
                                    ,p_payroll_action_id      NUMBER
                                    ,p_swmf_col_bal_def_table IN OUT NOCOPY BAL_COL_TABLE) IS
  --
  x NUMBER;
  y NUMBER;
  l_tu_payroll_ptd          VARCHAR2(30);
  l_tu_payroll_adj_ptd      VARCHAR2(30);
  l_tu_payroll_corr_ptd     VARCHAR2(30);
  l_tu_sit_payroll_ptd      VARCHAR2(30);
  l_tu_sit_payroll_adj_ptd  VARCHAR2(30);
  l_tu_sit_payroll_corr_ptd VARCHAR2(30);
  --
  CURSOR csr_chk_corr_ele_exists(c_pay_act_id NUMBER) IS
  SELECT 'Y'
  FROM   DUAL
  WHERE  EXISTS (SELECT /*+ ORDERED */ 1
                 FROM   pay_assignment_actions paa
                       ,pay_action_information pai
                 WHERE  paa.payroll_action_id = c_pay_act_id
                 AND    pai.action_context_id = paa.assignment_action_id
                 AND    pai.action_context_type = 'AAP'
                 AND    pai.action_information_category = 'NL_WR_NOMINATIVE_REPORT_ADD'
                 AND    pai.action_information11 = 'Y');
  --
  l_curr_exits varchar2(1);
  --
BEGIN
  --MONTHLY
  OPEN  csr_chk_corr_ele_exists(p_payroll_action_id);
  FETCH csr_chk_corr_ele_exists INTO l_curr_exits;
  CLOSE csr_chk_corr_ele_exists;
  --
  --Fnd_file.put_line(FND_FILE.LOG,'#### l_curr_exits '||l_curr_exits);
  --
  IF p_payroll_type = 'MONTH' THEN
    l_tu_payroll_ptd          := '_TU_MONTH_PTD';
    l_tu_payroll_adj_ptd      := '_TU_MONTH_ADJ_PTD';
    l_tu_payroll_corr_ptd     := '_TU_MONTH_REP_CORR_PTD';
    l_tu_sit_payroll_ptd      := '_TU_SIT_MONTH_PTD';
    l_tu_sit_payroll_adj_ptd  := '_TU_SIT_MONTH_ADJ_PTD';
    l_tu_sit_payroll_corr_ptd := '_TU_SIT_MONTH_REP_CORR_PTD';
    IF NVL(l_curr_exits,'N') = 'N' THEN
      l_tu_payroll_adj_ptd      := '_TU_MONTH_PTD';
      l_tu_payroll_corr_ptd     := NULL;
      l_tu_sit_payroll_adj_ptd  := '_TU_SIT_MONTH_PTD';
      l_tu_sit_payroll_corr_ptd := NULL;
    END IF;
    IF g_retro_type = 'NEW' THEN
      l_tu_payroll_adj_ptd      := NULL;
      l_tu_payroll_corr_ptd     := '_TU_MONTH_BDATE_PTD';
      l_tu_sit_payroll_adj_ptd  := NULL;
      l_tu_sit_payroll_corr_ptd := '_TU_SIT_MONTH_BDATE_PTD';
    END IF;
  ELSIF p_payroll_type = 'LMONTH' THEN
    l_tu_payroll_ptd          := '_TU_LMONTH_PTD';
    l_tu_payroll_adj_ptd      := '_TU_LMONTH_ADJ_PTD';
    l_tu_payroll_corr_ptd     := '_TU_LMONTH_REP_CORR_PTD';
    l_tu_sit_payroll_ptd      := '_TU_SIT_LMONTH_PTD';
    l_tu_sit_payroll_adj_ptd  := '_TU_SIT_LMONTH_ADJ_PTD';
    l_tu_sit_payroll_corr_ptd := '_TU_SIT_LMONTH_REP_CORR_PTD';
    IF NVL(l_curr_exits,'N') = 'N' THEN
      l_tu_payroll_adj_ptd      := '_TU_LMONTH_PTD';
      l_tu_payroll_corr_ptd     := NULL;
      l_tu_sit_payroll_adj_ptd  := '_TU_SIT_LMONTH_PTD';
      l_tu_sit_payroll_corr_ptd := NULL;
    END IF;
    IF g_retro_type = 'NEW' THEN
      l_tu_payroll_adj_ptd      := NULL;
      l_tu_payroll_corr_ptd     := '_TU_LMONTH_BDATE_PTD';
      l_tu_sit_payroll_adj_ptd  := NULL;
      l_tu_sit_payroll_corr_ptd := '_TU_SIT_LMONTH_BDATE_PTD';
    END IF;
  ELSIF p_payroll_type = 'WEEK' THEN
    l_tu_payroll_ptd          := '_TU_WEEKLY_PTD';
    l_tu_payroll_adj_ptd      := '_TU_WEEKLY_PTD';
    l_tu_payroll_corr_ptd     := NULL;
    l_tu_sit_payroll_ptd      := '_TU_SIT_WEEKLY_PTD';
    l_tu_sit_payroll_adj_ptd  := '_TU_SIT_WEEKLY_PTD';
    l_tu_sit_payroll_corr_ptd := NULL;
  END IF;
  --
  --Fnd_file.put_line(FND_FILE.LOG,' Populating Balanace Table for Collective Report');
  g_col_bal_def_table.delete;
  x:=1;
  g_col_bal_def_table(x).balance_name 		:= 'Standard Taxable Income';   --1
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Standard Taxable Income Current Quarter';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:= NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Special Taxable Income';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Special Taxable Income';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Standard Taxable Income'; --5
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:= NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'SI Income Standard Tax'; --6
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro SI Income Standard Tax';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'SI Income Special Tax';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro SI Income Special Tax';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'SI Income Non Taxable'; -- 10
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Retro SI Income Non Taxable'; --11
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Actual SI Base Employer';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WAOB'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Retro Actual SI Base Employer';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WAOB';
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Actual SI Base';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WAOD'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Retro Actual SI Base'; -- 15
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WAOD';
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Actual SI Base'; --16
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WEWE'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Retro Actual SI Base';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WEWE'    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Actual SI Base'; --18
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'UFO'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Retro Actual SI Base'; --19
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'UFO'    ;
  x := x+1;
    g_col_bal_def_table(x).balance_name 		:= 'Employer ZVW Contribution Standard Tax';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW'  ;  --20
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Employer ZVW Contribution Special Tax';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Employer SI Contribution Non Taxable';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Employer SI Contribution';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW' ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Employer ZVW Contribution Standard Tax';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Employer ZVW Contribution Special Tax';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW'  ; --25
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Employer SI Contribution Non Taxable';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Employer SI Contribution';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW' ; --27
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Standard Tax Deduction'; --28
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Retro Standard Tax Deduction Current Quarter';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL   ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Special Tax Deduction'; --30
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL   ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Retro Special Tax Deduction'; --31
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL   ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Retro Standard Tax Deduction'; --32
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL   ;
  x := x+1;
  g_col_bal_def_table(x).balance_name			:= 'Major Issue Flat Rate Tax Deduction'; --33
  g_col_bal_def_table(x).database_item_suffix 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name	 		:= 'Retro Major Issue Flat Rate Tax Deduction';--34
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val 			:=  NULL ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Single Rate Special Target Tax Deduction'; --35
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Single Rate Special Target Tax Deduction';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Saving Tax Deduction'; --37
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Wage Saving Tax Deduction'; --38
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Premium Saving Tax Deduction';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Premium Saving Tax Deduction'; --40
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Single Rate Exceptional Payment Tax Deduction'; --41
  g_col_bal_def_table(x).database_item_suffix 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Single Rate Exceptional Payment Tax Deduction'; --42
  g_col_bal_def_table(x).database_item_suffix 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		    := 'Gross Up Rate Exceptional Payment Tax Deduction'; --43
  g_col_bal_def_table(x).database_item_suffix 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		    := 'Retro Gross Up Rate Exceptional Payment Tax Deduction';
  g_col_bal_def_table(x).database_item_suffix 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'National Holiday Gift Tax Deduction'; --45
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro National Holiday Gift Tax Deduction';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Gross Up Rate Exceeding Allowance Tax Deduction'; --47
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Gross Up Rate Exceeding Allowance Tax Deduction';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Pre Pension Tax Deduction'; -- 49
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Pre Pension Tax Deduction'; --50
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Tax Subsidy Paid Parental Leave';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  IF p_effective_date >= TO_DATE('01012007','DDMMYYYY') THEN
    g_col_bal_def_table(x).database_item_suffix 	:= NULL;
    g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  END IF;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Wage Tax Subsidy Paid Parental Leave';
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  IF p_effective_date >= TO_DATE('01012007','DDMMYYYY') THEN
    g_col_bal_def_table(x).database_item_suffix 	:= NULL;
    g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  END IF;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Tax Subsidy Long Term Unemployed'; -- 53
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  IF p_effective_date >= TO_DATE('01012007','DDMMYYYY') THEN
    g_col_bal_def_table(x).database_item_suffix 	:= NULL;
    g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  END IF;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Wage Tax Subsidy Long Term Unemployed'; --54
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  IF p_effective_date >= TO_DATE('01012007','DDMMYYYY') THEN
    g_col_bal_def_table(x).database_item_suffix 	:= NULL;
    g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  END IF;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Tax Subsidy Arbo Non Profit'; -- 55   ---problem starts here..
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Tax Subsidy Sea Going EES';  --56
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL    ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Tax Subsidy Education'; --57
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Wage Tax Subsidy Education'; -- 58
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Tax Subsidy Research'; --59
  g_col_bal_def_table(x).database_item_suffix 	:= NULL; -- Bug# 5754707
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report SI Contribution'; --60
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WAOB'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report Retro SI Contribution'; --61
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WAOB'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report SI Contribution';  --62
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WGA'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report Retro SI Contribution'; --63
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WGA'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report SI Contribution'; -- 64
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'IVA'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report Retro SI Contribution'; --65
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'IVA'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report SI Contribution'; --66
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WAOD'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report Retro SI Contribution'; --67
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WAOD'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report SI Contribution'; --68
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WEWE'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report Retro SI Contribution'; --69
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'WEWE'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report SI Contribution'; --70
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'UFO'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report Retro SI Contribution'; --71
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'UFO'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report Employee SI Contribution'; --72
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Report Retro Employee SI Contribution'; --73
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  'SOURCE_TEXT';
  g_col_bal_def_table(x).context_val			:=  'ZVW'  ;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Labour Handicap Discount'; --74
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		    := 'Retro Labour Handicap Discount'; --75
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			    :=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Wage Tax Subsidy EVC'; --76
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Wage Tax Subsidy EVC'; -- 77
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Standard Tax Correction'; --78
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Special Tax Correction'; --79
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Life Cycle Leave Discount'; --80
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  x := x+1;
  g_col_bal_def_table(x).balance_name 		:= 'Retro Life Cycle Leave Discount'; -- 81
  g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
  g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
  g_col_bal_def_table(x).context			:=  NULL;
  g_col_bal_def_table(x).context_val			:=  NULL;
  --
--LC 2010-- begin
  IF p_effective_date >= TO_DATE('01012010','DDMMYYYY') THEN
    x := x+1;
    g_col_bal_def_table(x).balance_name 		:= 'Discount due to Labour Handicap'; --82
    g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
    g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
    g_col_bal_def_table(x).context			:=  NULL;
    g_col_bal_def_table(x).context_val			:=  NULL;
    x := x+1;
    g_col_bal_def_table(x).balance_name 		    := 'Retro Discount due to Labour Handicap'; --83
    g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
    g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
    g_col_bal_def_table(x).context			    :=  NULL;
    g_col_bal_def_table(x).context_val			:=  NULL;
    x := x+1;
    g_col_bal_def_table(x).balance_name 		:= 'Discount for Hired Old Employees'; --84
    g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
    g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
    g_col_bal_def_table(x).context			:=  NULL;
    g_col_bal_def_table(x).context_val			:=  NULL;
    x := x+1;
    g_col_bal_def_table(x).balance_name 		    := 'Retro Discount for Hired Old Employees'; --85
    g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
    g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
    g_col_bal_def_table(x).context			    :=  NULL;
    g_col_bal_def_table(x).context_val			:=  NULL;
    x := x+1;
    g_col_bal_def_table(x).balance_name 		:= 'Discount for Old Employees'; --86
    g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
    g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
    g_col_bal_def_table(x).context			:=  NULL;
    g_col_bal_def_table(x).context_val			:=  NULL;
    x := x+1;
    g_col_bal_def_table(x).balance_name 		    := 'Retro Discount for Old Employees'; --87
    g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
    g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
    g_col_bal_def_table(x).context			    :=  NULL;
    g_col_bal_def_table(x).context_val			:=  NULL;
    x := x+1;
    g_col_bal_def_table(x).balance_name 		    := 'Total Contribution Wage for PMA'; --88
    g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_ptd;
    g_col_bal_def_table(x).database_item_suffix2 	:= NULL;
    g_col_bal_def_table(x).context			    :=  NULL;
    g_col_bal_def_table(x).context_val			:=  NULL;
    x := x+1;
    g_col_bal_def_table(x).balance_name 		    := 'Retro Total Contribution Wage for PMA'; --89
    g_col_bal_def_table(x).database_item_suffix 	:= l_tu_payroll_adj_ptd;
    g_col_bal_def_table(x).database_item_suffix2 	:= l_tu_payroll_corr_ptd;
    g_col_bal_def_table(x).context			    :=  NULL;
    g_col_bal_def_table(x).context_val			:=  NULL;
  END IF;
--LC 2010-- end
  --
  FOR i in g_col_bal_def_table.FIRST..g_col_bal_def_table.LAST LOOP
    IF g_col_bal_def_table(i).database_item_suffix IS NOT NULL THEN
      g_col_bal_def_table(i).defined_balance_id := get_defined_balance_id(g_col_bal_def_table(i).balance_name
                                                              ,g_col_bal_def_table(i).database_item_suffix);
    ELSE
      g_col_bal_def_table(i).defined_balance_id := 0;
    END IF;
    IF g_col_bal_def_table(i).database_item_suffix2 IS NOT NULL THEN
      g_col_bal_def_table(i).defined_balance_id2 := get_defined_balance_id(g_col_bal_def_table(i).balance_name
                                                              ,g_col_bal_def_table(i).database_item_suffix2);
    ELSE
      g_col_bal_def_table(i).defined_balance_id2 := 0;
    END IF;
  END LOOP;
  --
  --
  IF p_payroll_type = 'MONTH' THEN
    l_tu_sit_payroll_ptd      := '_TU_SIP_MONTH_PTD';
    l_tu_sit_payroll_adj_ptd  := '_TU_SIP_MONTH_ADJ_PTD';
    l_tu_sit_payroll_corr_ptd := '_TU_SIP_MONTH_REP_CORR_PTD';
    IF NVL(l_curr_exits,'N') = 'N' THEN
      l_tu_sit_payroll_adj_ptd  := '_TU_SIP_MONTH_PTD';
      l_tu_sit_payroll_corr_ptd := NULL;
    END IF;
    IF g_retro_type = 'NEW' THEN
      l_tu_sit_payroll_adj_ptd  := NULL;
      l_tu_sit_payroll_corr_ptd := '_TU_SIP_MONTH_BDATE_PTD';
    END IF;
  ELSIF p_payroll_type = 'LMONTH' THEN
    l_tu_sit_payroll_ptd      := '_TU_SIP_LMONTH_PTD';
    l_tu_sit_payroll_adj_ptd  := '_TU_SIP_LMONTH_ADJ_PTD';
    l_tu_sit_payroll_corr_ptd := '_TU_SIP_LMONTH_REP_CORR_PTD';
    IF NVL(l_curr_exits,'N') = 'N' THEN
      l_tu_sit_payroll_adj_ptd  := '_TU_SIP_LMONTH_PTD';
      l_tu_sit_payroll_corr_ptd := NULL;
    END IF;
    IF g_retro_type = 'NEW' THEN
      l_tu_sit_payroll_adj_ptd  := NULL;
      l_tu_sit_payroll_corr_ptd := '_TU_SIP_LMONTH_BDATE_PTD';
    END IF;
  ELSIF p_payroll_type = 'WEEK' THEN
    l_tu_sit_payroll_ptd      := '_TU_SIP_WEEKLY_PTD';
    l_tu_sit_payroll_adj_ptd  := '_TU_SIP_WEEKLY_PTD';
    l_tu_sit_payroll_corr_ptd := NULL;
  END IF;
  --
  --p_swmf_col_bal_def_table.delete;
  --Fnd_file.put_line(FND_FILE.LOG,' Populating Balanace Table for SWMF');
  y := 1;
  p_swmf_col_bal_def_table(y).balance_name			:= 'Actual SI Base';--1
  p_swmf_col_bal_def_table(y).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  p_swmf_col_bal_def_table(y).database_item_suffix2 	:= NULL;
  p_swmf_col_bal_def_table(y).context			:=  'SOURCE_TEXT';
  p_swmf_col_bal_def_table(y).context_val			:=  'WEWA'  ;
  y := y+1;
  p_swmf_col_bal_def_table(y).balance_name			:= 'Retro Actual SI Base';
  p_swmf_col_bal_def_table(y).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  p_swmf_col_bal_def_table(y).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  p_swmf_col_bal_def_table(y).context			:=  'SOURCE_TEXT';
  p_swmf_col_bal_def_table(y).context_val			:=  'WEWA'    ;
  y := y+1;
  p_swmf_col_bal_def_table(y).balance_name			:= 'Wage Report SI Contribution';
  p_swmf_col_bal_def_table(y).database_item_suffix 	:= l_tu_sit_payroll_ptd;
  p_swmf_col_bal_def_table(y).database_item_suffix2 	:= NULL;
  p_swmf_col_bal_def_table(y).context			:=  'SOURCE_TEXT';
  p_swmf_col_bal_def_table(y).context_val			:=  'WEWA'  ;
  y := y+1;
  p_swmf_col_bal_def_table(y).balance_name			:= 'Wage Report Retro SI Contribution'; --4
  p_swmf_col_bal_def_table(y).database_item_suffix 	:= l_tu_sit_payroll_adj_ptd;
  p_swmf_col_bal_def_table(y).database_item_suffix2 	:= l_tu_sit_payroll_corr_ptd;
  p_swmf_col_bal_def_table(y).context			:=  'SOURCE_TEXT';
  p_swmf_col_bal_def_table(y).context_val			:=  'WEWA'    ;
  --
  FOR i in p_swmf_col_bal_def_table.FIRST..p_swmf_col_bal_def_table.LAST LOOP
    IF p_swmf_col_bal_def_table(i).database_item_suffix IS NOT NULL THEN
      p_swmf_col_bal_def_table(i).defined_balance_id := get_defined_balance_id(p_swmf_col_bal_def_table(i).balance_name
                                                              ,p_swmf_col_bal_def_table(i).database_item_suffix);
    ELSE
      p_swmf_col_bal_def_table(i).defined_balance_id := 0;
    END IF;
    IF p_swmf_col_bal_def_table(i).database_item_suffix2 IS NOT NULL THEN
      p_swmf_col_bal_def_table(i).defined_balance_id2 := get_defined_balance_id(p_swmf_col_bal_def_table(i).balance_name
                                                              ,p_swmf_col_bal_def_table(i).database_item_suffix2);
    ELSE
      p_swmf_col_bal_def_table(i).defined_balance_id2 := 0;
    END IF;
  END LOOP;
  --Fnd_file.put_line(FND_FILE.LOG,' Populated Balanace Tables');
  --
END populate_col_balance_table;
--
--------------------------------------------------------------------------------
-- populate_coll_bal_table   pay_nl_wage_report_pkg.populate_coll_bal_table
--------------------------------------------------------------------------------
PROCEDURE populate_coll_bal_table(p_actid          IN  NUMBER
                                 ,p_tax_unit_id    IN  NUMBER
                                 ,p_effective_date IN  DATE
                                 ,p_balance_date   IN  DATE
                                 ,p_type           IN  VARCHAR2
                                 ,p_ass_action_id  IN  NUMBER
                                 ,p_payroll_type   IN  VARCHAR2
                                 ,p_emp_total      IN  OUT NOCOPY NUMBER
                                 ,p_collXMLTable   OUT NOCOPY tXMLTable) IS
  --
  CURSOR csr_get_org_tax_data(c_org_id       NUMBER
                             ,c_payroll_type VARCHAR2) IS
  SELECT fnd_date.canonical_to_date(org_information1) start_date
        ,fnd_date.canonical_to_date(org_information2) end_date
        ,org_information3
        ,fnd_number.canonical_to_number(org_information4) amount
        ,org_information5 frequency
        ,org_information6
  FROM   hr_organization_information
  WHERE  organization_id = c_org_id
  AND    org_information_context = 'NL_ORG_FLAT_RATE_TAXATION'
  -- AND    org_information3 = '1' -- Bug# 5754707
  AND    org_information6 = c_payroll_type
  ORDER BY fnd_date.canonical_to_date(org_information1);
  --
  CURSOR csr_get_no_pay_period(c_payroll_type VARCHAR2) IS
  SELECT number_per_fiscal_year
  FROM   per_time_period_types
  WHERE  period_type = DECODE(c_payroll_type,'MONTH','Calendar Month','WEEK','Week','LMONTH','Lunar Month');
  --
  y NUMBER ;
  l_flat_rate_taxation    NUMBER := 0;
  l_major_issue_flat_rate NUMBER := 0;
  l_single_rate_exp_pay   NUMBER := 0;
  l_wage_tax_subsidy      NUMBER := 0;
  l_flat_tax_holidays     NUMBER := 0;
  l_flat_tax_pre_pension  NUMBER := 0; /* 7533686 */
  l_no_pay_period      NUMBER;
  --
BEGIN
  --
  y:=1;
  p_emp_total := 0;
  populate_col_balance_values(g_col_bal_def_table,p_tax_unit_id,p_effective_date,p_balance_date,p_type,NULL,p_ass_action_id);
  --
  OPEN  csr_get_no_pay_period(p_payroll_type);
  FETCH csr_get_no_pay_period INTO l_no_pay_period;
  CLOSE csr_get_no_pay_period;
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~~~ l_no_pay_period '||l_no_pay_period||' ');
  --
  l_flat_rate_taxation := 0;
  -- Bug# 5754707, For Loop modified for all types of Look-up codes.
  FOR csr_rec in csr_get_org_tax_data(p_tax_unit_id,p_payroll_type) LOOP
    IF csr_rec.org_information3 = '1' AND p_effective_date BETWEEN csr_rec.start_date AND NVL(csr_rec.end_date,fnd_date.canonical_to_date('4712/12/31')) THEN
      IF csr_rec.frequency = 'P' THEN
        l_flat_rate_taxation := csr_rec.amount;
      ELSIF csr_rec.frequency = 'A' THEN
        l_flat_rate_taxation := csr_rec.amount/l_no_pay_period;
      END IF;
    END IF;

    IF csr_rec.org_information3 = '2' AND p_effective_date BETWEEN csr_rec.start_date AND NVL(csr_rec.end_date,fnd_date.canonical_to_date('4712/12/31')) THEN
      IF csr_rec.frequency = 'P' THEN
        l_major_issue_flat_rate := csr_rec.amount;
      ELSIF csr_rec.frequency = 'A' THEN
        l_major_issue_flat_rate := csr_rec.amount/l_no_pay_period;
      END IF;
    END IF;

    IF csr_rec.org_information3 = '3' AND p_effective_date BETWEEN csr_rec.start_date AND NVL(csr_rec.end_date,fnd_date.canonical_to_date('4712/12/31')) THEN
      IF csr_rec.frequency = 'P' THEN
        l_single_rate_exp_pay := csr_rec.amount;
      ELSIF csr_rec.frequency = 'A' THEN
        l_single_rate_exp_pay := csr_rec.amount/l_no_pay_period;
      END IF;
    END IF;

    IF csr_rec.org_information3 = '4' AND p_effective_date BETWEEN csr_rec.start_date AND NVL(csr_rec.end_date,fnd_date.canonical_to_date('4712/12/31')) THEN
      IF csr_rec.frequency = 'P' THEN
        l_wage_tax_subsidy := csr_rec.amount;
      ELSIF csr_rec.frequency = 'A' THEN
        l_wage_tax_subsidy := csr_rec.amount/l_no_pay_period;
      END IF;
    END IF;

    /**** Bug 6610259 ****/
    IF csr_rec.org_information3 = '5' AND p_effective_date BETWEEN csr_rec.start_date AND NVL(csr_rec.end_date,fnd_date.canonical_to_date('4712/12/31')) THEN
      IF csr_rec.frequency = 'P' THEN
        l_flat_tax_holidays := csr_rec.amount;
      ELSIF csr_rec.frequency = 'A' THEN
        l_flat_tax_holidays := csr_rec.amount/l_no_pay_period;
      END IF;
    END IF;

    /* 7533686 */
    IF csr_rec.org_information3 = '6' AND p_effective_date BETWEEN csr_rec.start_date AND NVL(csr_rec.end_date,fnd_date.canonical_to_date('4712/12/31')) THEN
      IF csr_rec.frequency = 'P' THEN
        l_flat_tax_pre_pension := csr_rec.amount;
      ELSIF csr_rec.frequency = 'A' THEN
        l_flat_tax_pre_pension := csr_rec.amount/l_no_pay_period;
      END IF;
    END IF;
  END LOOP;
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~~~ l_flat_rate_taxation '||l_flat_rate_taxation||' ');
  --
  p_collXMLTable(y).TagName := 'TotLnLbPh';  -- 1..5
  p_collXMLTable(y).Mandatory:= 'Y';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotLnLbPh'));
  p_collXMLTable(y).Tagvalue := 0;
  FOR i in 1..5 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'TotLnSV';  -- 6..11
  p_collXMLTable(y).Mandatory:= 'Y';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotLnSV'));
  p_collXMLTable(y).Tagvalue := 0;
  FOR i in 6..11 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'PrLnWAOAof';  --12..13
  p_collXMLTable(y).Mandatory:= 'Y';
  IF p_effective_date >= to_date('01012007','DDMMYYYY') THEN
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAof'));
  ELSE
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAof_2006'));
  END IF;
  p_collXMLTable(y).Tagvalue := 0;
  FOR i in 12..13 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  --
  -- LC 2010 -- begin
    IF p_effective_date >= to_date('01012010','DDMMYYYY') THEN
      y:= y+1;
      p_collXMLTable(y).TagName := 'PrLnWaoPma'; --  88..89
      p_collXMLTable(y).Mandatory:= 'Y';
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWaoPma'));
      p_collXMLTable(y).Tagvalue:=0;
      FOR i in 88..89 LOOP
        p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                    + g_col_bal_def_table(i).balance_value2;
      END LOOP;
    END IF;
  -- LC 2010 -- end
  --
  IF g_public_org_flag = 'N' AND g_risk_cover_flag = 'Y' THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrLnWAOAok';  -- 14..15
    p_collXMLTable(y).Mandatory:= 'Y';
    IF p_effective_date >= to_date('01012007','DDMMYYYY') THEN
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAok'));
    ELSE
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAok_2006'));
    END IF;
    p_collXMLTable(y).Tagvalue:=0;
  --IF g_public_org_flag <> 'N' OR g_risk_cover_flag <> 'Y' THEN
  ELSE
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrLnWAOAok';  -- 14..15
    p_collXMLTable(y).Mandatory:= 'Y';
    IF p_effective_date >= to_date('01012007','DDMMYYYY') THEN
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAok'));
    ELSE
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAok_2006'));
    END IF;
    p_collXMLTable(y).Tagvalue:=0;
    FOR i in 14..15 LOOP
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
    END LOOP;
  END IF;
  --
  IF g_public_org_flag = 'N' THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrLnAWF'; -- 16..17
    p_collXMLTable(y).Mandatory:= 'Y';
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnAWF'));
    p_collXMLTable(y).Tagvalue:=0;
    FOR i in 16..17 LOOP
        p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                      + g_col_bal_def_table(i).balance_value2;
    END LOOP;
  ELSE
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrLnAWF'; -- 16..17
    p_collXMLTable(y).Mandatory:= 'Y';
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnAWF'));
    p_collXMLTable(y).Tagvalue:=0;
  END IF;
  --
  --IF g_public_org_flag = 'Y' THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrLnUFO'; --18..19
    p_collXMLTable(y).Mandatory:= 'Y';
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnUFO'));
    p_collXMLTable(y).Tagvalue:=0;
    FOR i in 18..19 LOOP
        p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                      + g_col_bal_def_table(i).balance_value2;
    END LOOP;
  --END IF;
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'TotVergZvw'; --20..27
  p_collXMLTable(y).Mandatory:= 'Y';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotVergZvw'));
  p_collXMLTable(y).Tagvalue:=0;
  FOR i in 20..27 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  --p_emp_total := p_emp_total ;
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'IngLbPh'; --28..32
  p_collXMLTable(y).Mandatory:= 'Y';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('IngLbPh'));
  p_collXMLTable(y).Tagvalue:=0;
  FOR i in 28..32 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  FOR i in 78..79 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  FOR i in 80..81 LOOP -- Subtracting LCLD
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue - (g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2);
  END LOOP;
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'EHPubUitk'; -- 33..34
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHPubUitk'));
  p_collXMLTable(y).Tagvalue:= l_major_issue_flat_rate; -- Bug# 5754707
  /* FOR i in 33..34 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP; */ -- Commented the FOR loop as part of fix to Bug# 5754707
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'EHLnBestKar'; --35..36
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHLnBestKar'));
  p_collXMLTable(y).Tagvalue:=0;
  FOR i in 35..36 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'EHSpLn';  -- 37..38
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHSpLn'));
  p_collXMLTable(y).Tagvalue:=0;
  FOR i in 37..38 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'EHSpPr'; --39..40
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHSpPr'));
  p_collXMLTable(y).Tagvalue:=0;

  IF p_effective_date < to_date('01012008','DDMMYYYY') THEN
   FOR i in 39..40 LOOP        --Dutch Year End Changes 08 This Tag is obsolete as of 08 Wage Report
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
   END LOOP;
  END IF;
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'EHLnNat'; --41-44
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHLnNat'));
  p_collXMLTable(y).Tagvalue:= l_single_rate_exp_pay; -- Bug# 5754707
  /*FOR i in 41..44 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP; */ -- Commented the code as per Bug# 5754707
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'EHFeest'; -- 45..46
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHFeest'));
  p_collXMLTable(y).Tagvalue:=0;
  p_collXMLTable(y).Tagvalue := l_flat_tax_holidays;    /*** Bug 6610259 ***/
  /*FOR i in 45..46 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;*/
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'EHBmVerg'; --47..48
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHBmVerg'));
  p_collXMLTable(y).Tagvalue:=0;
  FOR i in 47..48 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  IF p_effective_date >= TO_DATE('01012007','DDMMYYYY') THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'EHGebrAuto';
    p_collXMLTable(y).Mandatory:= 'N';
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHGebrAuto'));
    p_collXMLTable(y).Tagvalue:=  l_flat_rate_taxation;
  END IF;
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'EHVUT'; -- 49..50
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHVUT'));
  p_collXMLTable(y).Tagvalue:=0;
  p_collXMLTable(y).Tagvalue := l_flat_tax_pre_pension; /* 7533686 */
  /*
  FOR i in 49..50 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP; */

  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  IF p_effective_date < TO_DATE('01012007','DDMMYYYY') THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'AVBetOV'; -- 51..52
    p_collXMLTable(y).Mandatory:= 'N';
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVBetOV'));
    p_collXMLTable(y).Tagvalue:=0;
    FOR i in 51..52 LOOP
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                    + g_col_bal_def_table(i).balance_value2;
    END LOOP;
    p_collXMLTable(y).Tagvalue:=p_collXMLTable(y).Tagvalue * -1;
    p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);
    --
    y:= y+1;
    p_collXMLTable(y).TagName := 'AVLgdWerkl'; -- 53..54
    p_collXMLTable(y).Mandatory:= 'N';
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVLgdWerkl'));
    p_collXMLTable(y).Tagvalue:=0;
    FOR i in 53..54 LOOP
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                    + g_col_bal_def_table(i).balance_value2;
    END LOOP;
    p_collXMLTable(y).Tagvalue:=p_collXMLTable(y).Tagvalue * -1;
    p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);
  END IF;
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'AVArboNP'; -- 55
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVArboNP'));
  p_collXMLTable(y).Tagvalue:=0;
  IF p_effective_date < to_date('01012008','DDMMYYYY') THEN
    p_collXMLTable(y).Tagvalue:= g_col_bal_def_table(55).balance_value ;
    p_collXMLTable(y).Tagvalue:= p_collXMLTable(y).Tagvalue * -1;
  END IF;
  p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'AVZeev'; -- 56
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVZeev'));
  p_collXMLTable(y).Tagvalue:=0;
  p_collXMLTable(y).Tagvalue:= g_col_bal_def_table(56).balance_value ;
  p_collXMLTable(y).Tagvalue:= p_collXMLTable(y).Tagvalue * -1;
  p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);
  y:= y+1;
  p_collXMLTable(y).TagName := 'AVOnd'; -- 57..58
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVOnd'));
  p_collXMLTable(y).Tagvalue:=0;
  p_collXMLTable(y).Tagvalue:=0;
  FOR i in 57..58 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  FOR i in 76..77 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  p_collXMLTable(y).Tagvalue:=p_collXMLTable(y).Tagvalue * -1;
  p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'VrlAVSO'; --59
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('VrlAVSO'));
  p_collXMLTable(y).Tagvalue:=l_wage_tax_subsidy; -- Bug# 5754707
  --p_collXMLTable(y).Tagvalue:= g_col_bal_def_table(59).balance_value ; -- Bug# 5754707
  p_collXMLTable(y).Tagvalue:= p_collXMLTable(y).Tagvalue * -1;
  p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'PrWAOAof'; -- 60..65 WAOB WGA IVA
  p_collXMLTable(y).Mandatory:= 'N';
  IF p_effective_date >= to_date('01012007','DDMMYYYY') THEN
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAof'));
  ELSE
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAof_2006'));
  END IF;
  p_collXMLTable(y).Tagvalue:=0;
  FOR i in 60..65 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --
  IF g_public_org_flag = 'Y' AND g_risk_cover_flag = 'Y' THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrWAOAok'; -- 66..67  WAOD
    p_collXMLTable(y).Mandatory:= 'Y';
    IF p_effective_date >= to_date('01012007','DDMMYYYY') THEN
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAok'));
    ELSE
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAok_2006'));
    END IF;
    p_collXMLTable(y).Tagvalue:=0;
  ELSIF g_public_org_flag = 'N' AND g_risk_cover_flag = 'Y' THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrWAOAok'; -- 66..67  WAOD
    p_collXMLTable(y).Mandatory:= 'Y';
    IF p_effective_date >= to_date('01012007','DDMMYYYY') THEN
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAok'));
    ELSE
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAok_2006'));
    END IF;
    p_collXMLTable(y).Tagvalue:=0;
  ELSE
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrWAOAok'; -- 66..67  WAOD
    p_collXMLTable(y).Mandatory:= 'N';
    IF p_effective_date >= to_date('01012007','DDMMYYYY') THEN
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAok'));
    ELSE
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAok_2006'));
    END IF;
    p_collXMLTable(y).Tagvalue:=0;
    FOR i in 66..67 LOOP
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                    + g_col_bal_def_table(i).balance_value2;
    END LOOP;
    p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  END IF;
  --
  IF g_public_org_flag = 'N' THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrAWF'; -- 68..69 WEWE
    p_collXMLTable(y).Mandatory:= 'N';
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrAWF'));
    p_collXMLTable(y).Tagvalue:=0;
    FOR i in 68..69 LOOP
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                    + g_col_bal_def_table(i).balance_value2;
    END LOOP;
    p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  END IF;
  --
  IF g_public_org_flag = 'Y' THEN
    y:= y+1;
    p_collXMLTable(y).TagName := 'PrUFO'; -- 70..71 UFO
    p_collXMLTable(y).Mandatory:= 'N';
    p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrUFO'));
    p_collXMLTable(y).Tagvalue:=0;
    FOR i in 70..71 LOOP
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                    + g_col_bal_def_table(i).balance_value2;
    END LOOP;
    --p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);  Bug No - 5226068
    p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  END IF;
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'IngBijdrZvw'; -- 72..73 ZVW
  p_collXMLTable(y).Mandatory:= 'N';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('IngBijdrZvw'));
  p_collXMLTable(y).Tagvalue:=0;
  FOR i in 72..73 LOOP
    p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                  + g_col_bal_def_table(i).balance_value2;
  END LOOP;
  p_emp_total := p_emp_total + ROUND(p_collXMLTable(y).Tagvalue);
  --

  -- LC 2010 -- begin
    IF p_effective_date >= to_date('01012010','DDMMYYYY') THEN

      y:= y+1;
      p_collXMLTable(y).TagName := 'PkAgh'; --  82..83
      p_collXMLTable(y).Mandatory:= 'N';
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PkAgh'));
      p_collXMLTable(y).Tagvalue:=0;
      FOR i in 82..83 LOOP
        p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                      + g_col_bal_def_table(i).balance_value2;
      END LOOP;
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue * -1;
      p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);

      y:= y+1;
      p_collXMLTable(y).TagName := 'PkNwArbvOudWn'; --  84..85
      p_collXMLTable(y).Mandatory:= 'N';
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PkNwArbvOudWn'));
      p_collXMLTable(y).Tagvalue:=0;
      FOR i in 84..85 LOOP
        p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                      + g_col_bal_def_table(i).balance_value2;
      END LOOP;
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue * -1;
      p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);

      y:= y+1;
      p_collXMLTable(y).TagName := 'PkInDnstOudWn'; --  86..87
      p_collXMLTable(y).Mandatory:= 'N';
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PkInDnstOudWn'));
      p_collXMLTable(y).Tagvalue:=0;
      FOR i in 86..87 LOOP
        p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                      + g_col_bal_def_table(i).balance_value2;
      END LOOP;
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue * -1;
      p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);
    ELSE
      y:= y+1;
      p_collXMLTable(y).TagName := 'AGHKort'; --  74..75
      p_collXMLTable(y).Mandatory:= 'N';
      p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AGHKort'));
      p_collXMLTable(y).Tagvalue:=0;
      FOR i in 74..75 LOOP
        p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue + g_col_bal_def_table(i).balance_value
                                      + g_col_bal_def_table(i).balance_value2;
      END LOOP;
      p_collXMLTable(y).Tagvalue:=  p_collXMLTable(y).Tagvalue * -1;
      p_emp_total := p_emp_total - ROUND(p_collXMLTable(y).Tagvalue);
    END IF;
  -- LC 2010 -- end
  --
  y:= y+1;
  p_collXMLTable(y).TagName := 'TotTeBet';
  p_collXMLTable(y).Mandatory:= 'Y';
  p_collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotTeBet'));
  p_collXMLTable(y).Tagvalue:=  p_emp_total;
  --
  --
  --FOR i in p_collXMLTable.first..p_collXMLTable.last LOOP
  --  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~~~'||p_collXMLTable(i).TagName||'  '||p_collXMLTable(i).Tagvalue||' ');
  --END LOOP;
END populate_coll_bal_table;
--
--------------------------------------------------------------------------------
-- populate_nom_balance_values   pay_nl_wage_report_pkg.populate_nom_balance_values
--------------------------------------------------------------------------------
PROCEDURE populate_nom_balance_values(p_master_assignment_action_id NUMBER
                                 ,p_assignment_action_id        NUMBER
                                 ,p_effective_date              DATE
                                 ,p_tax_unit_id                 NUMBER
                                 ,p_type                        VARCHAR2
                                 ,p_record_type                 VARCHAR2
                                 ,p_corr_used                   IN OUT NOCOPY VARCHAR2
                                 ,p_balance_values              IN OUT NOCOPY Bal_Value) IS
--
    l_balance_date DATE;
    l_context_id   NUMBER;
    l_source_text  VARCHAR2(50);
    l_source_text2  VARCHAR2(50);
    l_assignment_action_id NUMBER;
    l_context VARCHAR2(1);
    l_tax_unit_id NUMBER;
    --
    CURSOR  cur_act_contexts(p_context_name VARCHAR2 )IS
    SELECT  ffc.context_id
    FROM    ff_contexts   ffc
    WHERE   ffc.context_name = p_context_name;
    --
    CURSOR csr_chk_corr_ele_exists(c_ass_act_id NUMBER) IS
    SELECT 'Y'
    FROM   DUAL
    WHERE  EXISTS (SELECT /*+ ORDERED */ 1
                   FROM   pay_assignment_actions bal_assact
--                         ,pay_payroll_actions    bact
                         ,pay_assignment_actions assact
--                         ,pay_payroll_actions    pact
                         ,pay_element_types_f    adj_petf
                         ,pay_run_results        adj_prr
                   WHERE bal_assact.assignment_action_id = c_ass_act_id -- assignment_action_id
                   --and   bal_assact.payroll_action_id    = bact.payroll_action_id
                   --and   assact.payroll_action_id        = pact.payroll_action_id
                   --and   pact.time_period_id             = bact.time_period_id
                   --and   assact.action_sequence          <= bal_assact.action_sequence
                   and   assact.assignment_id            = bal_assact.assignment_id
                   AND   adj_prr.assignment_action_id    = assact.assignment_action_id
                   AND   adj_prr.status in ('P','PA')
                   AND   adj_petf.element_type_id        = adj_prr.element_type_id
                   AND   adj_petf.element_name           = 'New Wage Report Override'
                   AND   adj_petf.legislation_code       = 'NL');
--
l_corr_ele_exists VARCHAR2(1);
--
BEGIN
    --
    l_corr_ele_exists := 'N';
    p_balance_values.delete;
    OPEN  csr_chk_corr_ele_exists(p_assignment_action_id);
    FETCH csr_chk_corr_ele_exists INTO l_corr_ele_exists;
    IF csr_chk_corr_ele_exists%NOTFOUND THEN
      l_corr_ele_exists := 'N';
    ELSE
      p_corr_used := 'Y';
    END IF;
    CLOSE csr_chk_corr_ele_exists;
    --##--Fnd_file.put_line(FND_FILE.LOG,'#### balance value ');
    --##--Fnd_file.put_line(FND_FILE.LOG,'#### p_master_assignment_action_id '||p_master_assignment_action_id);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#### p_assignment_action_id '||p_assignment_action_id);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#### p_effective_date '||p_effective_date);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#### p_tax_unit_id '||p_tax_unit_id);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#### g_nom_bal_def_table.count '||g_nom_bal_def_table.count);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#### l_corr_ele_exists '||l_corr_ele_exists);
    FOR i IN g_nom_bal_def_table.FIRST..g_nom_bal_def_table.LAST LOOP
      p_balance_values(i).balance_value := 0;
      IF l_corr_ele_exists = 'N' AND (g_nom_bal_def_table(i).database_item_suffix like '%ADJ%'
                                     OR g_nom_bal_def_table(i).database_item_suffix like '%CORR%') THEN
        IF g_nom_bal_def_table(i).database_item_suffix like '%SIT%ADJ%' THEN
            g_nom_bal_def_table(i).database_item_suffix := '_ASG_SIT_PTD';
        ELSIF g_nom_bal_def_table(i).database_item_suffix like '%ADJ%' THEN
            g_nom_bal_def_table(i).database_item_suffix := '_ASG_PTD';
        ELSIF g_nom_bal_def_table(i).database_item_suffix like '%SIT%CORR%' THEN
            g_nom_bal_def_table(i).database_item_suffix := 'CORR_SI';
        ELSIF g_nom_bal_def_table(i).database_item_suffix like '%CORR%' THEN
            g_nom_bal_def_table(i).database_item_suffix := 'CORR';
        ELSE
            g_nom_bal_def_table(i).database_item_suffix := NULL;
            g_nom_bal_def_table(i).defined_balance_id := 0;
        END IF;
      ELSIF l_corr_ele_exists = 'Y' AND g_nom_bal_def_table(i).balance_name LIKE '%Retro%' THEN
        IF g_nom_bal_def_table(i).database_item_suffix like '_ASG_SIT_PTD' THEN
            g_nom_bal_def_table(i).database_item_suffix := '_ASG_SIT_ADJ_PTD';
        ELSIF g_nom_bal_def_table(i).database_item_suffix like '_ASG_PTD' THEN
            g_nom_bal_def_table(i).database_item_suffix := '_ASG_ADJ_PTD';
        ELSIF g_nom_bal_def_table(i).database_item_suffix like 'CORR_SI' THEN
            g_nom_bal_def_table(i).database_item_suffix := '_ASG_SIT_REPORT_CORR_PTD';
        ELSIF g_nom_bal_def_table(i).database_item_suffix like 'CORR' THEN
            g_nom_bal_def_table(i).database_item_suffix := '_ASG_REPORT_CORR_PTD';
        END IF;
      END IF;
      IF g_nom_bal_def_table(i).database_item_suffix IS NOT NULL THEN
        g_nom_bal_def_table(i).defined_balance_id := get_defined_balance_id(g_nom_bal_def_table(i).balance_name
                                                                           ,g_nom_bal_def_table(i).database_item_suffix);
      END IF;
      IF g_nom_bal_def_table(i).defined_balance_id <> 0 AND
         (p_type <> 'INITIAL' OR g_nom_bal_def_table(i).database_item_suffix not in ('_ASG_REPORT_CORR_PTD','_ASG_SIT_REPORT_CORR_PTD','_ASG_BDATE_PTD','_ASG_SIT_BDATE_PTD')) THEN
         --(p_record_type <> 'HR' OR g_nom_bal_def_table(i).database_item_suffix not in ('_ASG_REPORT_CORR_PTD','_ASG_ADJ_PTD'))
        l_assignment_action_id := p_assignment_action_id;
        l_context := 'N';
        l_balance_date := NULL;
        l_context_id := NULL;
        l_source_text := NULL;
        l_source_text2 := NULL;
        --
        IF g_nom_bal_def_table(i).database_item_suffix LIKE '%/_REPORT/_%' ESCAPE '/' OR
           g_nom_bal_def_table(i).database_item_suffix LIKE '%/_BDATE/_%' ESCAPE '/' THEN
            l_balance_date := p_effective_date;
            l_assignment_action_id := p_master_assignment_action_id;
            l_context := 'Y';
        END IF;
        --
        IF g_nom_bal_def_table(i).database_item_suffix LIKE '%/_SIT/_%' ESCAPE '/' THEN
            OPEN  cur_act_contexts('SOURCE_TEXT');
            FETCH cur_act_contexts INTO l_context_id;
            CLOSE cur_act_contexts;
            l_source_text := g_nom_bal_def_table(i).context_val;
            l_context := 'Y';
        END IF;
        --
        IF g_nom_bal_def_table(i).database_item_suffix LIKE '%/_SIP/_%' ESCAPE '/' THEN
            OPEN  cur_act_contexts('SOURCE_TEXT2');
            FETCH cur_act_contexts INTO l_context_id;
            CLOSE cur_act_contexts;
            l_source_text2 := g_nom_bal_def_table(i).context_val;
            l_context := 'Y';
        END IF;
        --
        IF g_nom_bal_def_table(i).database_item_suffix LIKE '%/_TU/_%' ESCAPE '/'  THEN
            l_tax_unit_id := p_tax_unit_id;
            l_context := 'Y';
        END IF;
        --
        IF l_assignment_action_id = 0 OR l_assignment_action_id is NULL THEN
          p_balance_values(i).balance_value := 0;
        ELSE
          IF l_context = 'Y' THEN
            BEGIN
              p_balance_values(i).balance_value := pay_balance_pkg.get_value
                         (p_defined_balance_id   => g_nom_bal_def_table(i).defined_balance_id
                         ,p_assignment_action_id => l_assignment_action_id
                         ,p_tax_unit_id          => l_tax_unit_id
                         ,p_jurisdiction_code    => NULL
                         ,p_source_id            => l_context_id
                         ,p_source_text          => l_source_text
                         ,p_tax_group            => NULL
                         ,p_date_earned          => NULL
                         ,p_get_rr_route         => NULL
                         ,p_get_rb_route         => NULL
                         ,p_source_text2         => l_source_text2
                         ,p_source_number        => NULL
                         ,p_time_def_id          => NULL
                         ,p_balance_date         => l_balance_date
                         ,p_payroll_id           => NULL);
            --##--Fnd_file.put_line(FND_FILE.LOG,'#########'||g_nom_bal_def_table(i).balance_name||' '||g_nom_bal_def_table(i).database_item_suffix||' '||p_balance_values(i).balance_value||' '||g_nom_bal_def_table(i).context_val);
            --##--Fnd_file.put_line(FND_FILE.LOG,'#########defined_balance_id :'||g_nom_bal_def_table(i).defined_balance_id);
            EXCEPTION
              WHEN OTHERS THEN
                 p_balance_values(i).balance_value := 0;
                 --##--Fnd_file.put_line(FND_FILE.LOG,'####'||p_type||' '||g_nom_bal_def_table(i).balance_name||' '||g_nom_bal_def_table(i).database_item_suffix||' '||g_nom_bal_def_table(i).context_val);
                 --Fnd_file.put_line(FND_FILE.LOG,'## p_defined_balance_id ' || g_nom_bal_def_table(i).defined_balance_id);
                 --Fnd_file.put_line(FND_FILE.LOG,'## l_assignment_action_id ' || l_assignment_action_id);
                 --Fnd_file.put_line(FND_FILE.LOG,'## l_tax_unit_id ' || l_tax_unit_id);
                 --Fnd_file.put_line(FND_FILE.LOG,'## l_source_text ' || l_source_text);
                 --Fnd_file.put_line(FND_FILE.LOG,'## l_source_text2 ' || l_source_text2);
                 --Fnd_file.put_line(FND_FILE.LOG,'## l_balance_date ' || l_balance_date);
                 --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
            END;
          ELSE --IF g_nom_bal_def_table(i).database_item_suffix <> '_ASG_ADJ_PTD' THEN
            BEGIN
            p_balance_values(i).balance_value := pay_balance_pkg.get_value(g_nom_bal_def_table(i).defined_balance_id
                                                        ,p_assignment_action_id);
            --##--Fnd_file.put_line(FND_FILE.LOG,'#########'||g_nom_bal_def_table(i).balance_name||' '||g_nom_bal_def_table(i).database_item_suffix||' '||p_balance_values(i).balance_value||' '||g_nom_bal_def_table(i).context_val);
            --##--Fnd_file.put_line(FND_FILE.LOG,'#########defined_balance_id :'||g_nom_bal_def_table(i).defined_balance_id);
            EXCEPTION
              WHEN OTHERS THEN
                 p_balance_values(i).balance_value := 0;
                 --Fnd_file.put_line(FND_FILE.LOG,'##'||p_type||' '||g_nom_bal_def_table(i).balance_name||' '||g_nom_bal_def_table(i).database_item_suffix||' '||g_nom_bal_def_table(i).context_val);
                 --Fnd_file.put_line(FND_FILE.LOG,'## p_defined_balance_id ' || g_nom_bal_def_table(i).defined_balance_id);
                 --Fnd_file.put_line(FND_FILE.LOG,'## l_assignment_action_id ' || l_assignment_action_id);
            END;
          END IF;
        END IF;
      END IF;
    END LOOP;
   --
END populate_nom_balance_values;
/*--------------------------------------------------------------------------------
-- Function to retrieve correction balance for a period
--------------------------------------------------------------------------------
FUNCTION get_corr_bal(p_tax_unit_id IN NUMBER,p_date IN DATE) RETURN NUMBER IS
BEGIN
RETURN 100;
END get_corr_bal;*/
--------------------------------------------------------------------------------
-- SET_COMPANY_TYPE_GLOBALS
--------------------------------------------------------------------------------
PROCEDURE set_company_type(p_actid IN  NUMBER) IS
  --
  CURSOR csr_get_le_info (p_organization_id NUMBER) IS
  SELECT hoi.org_information2 org_id
        ,hoi.org_information5 Public_Org
        ,hoi.org_information6 Own_Risk_Cover
  FROM   hr_organization_information hoi
  WHERE  hoi.org_information_context  = 'NL_LE_TAX_DETAILS'
  AND    hoi.organization_id          = p_organization_id
  AND    EXISTS (SELECT 1
                 FROM   hr_organization_information hoi1
                 WHERE  hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
                 AND    hoi1.org_information_context = 'CLASS'
                 AND    hoi1.organization_id         = hoi.organization_id);
  /*SELECT hoi.org_information2 org_id
        ,hoi.org_information5 Public_Org
        ,hoi.org_information6 Own_Risk_Cover
  FROM   hr_organization_information hoi
        ,hr_organization_information hoi1
  WHERE  hoi.org_information_context  = 'NL_LE_TAX_DETAILS'
  AND    hoi.organization_id          = hoi1.organization_id
  AND    hoi1.organization_id         = p_organization_id
  AND    hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
  AND    hoi1.org_information_context = 'CLASS';*/
  --
  CURSOR csr_own_risk_cover(c_employer_id       NUMBER
                           ,c_business_group_id NUMBER) IS
  SELECT hoi.org_information5  Own_Risk_Cover
        ,hoi.org_information6  Contract_Code_Mapping
  FROM   hr_organization_units hou
        ,hr_organization_information hoi
  WHERE  hoi.org_information_context = 'NL_ORG_WR_INFO'
  AND    hou.business_group_id       = c_business_group_id
  AND    hou.organization_id         = hoi.organization_id
  AND    hou.organization_id         = c_employer_id;
  --
  CURSOR csr_public_org_flag(c_employer_id       NUMBER
                            ,c_business_group_id NUMBER) IS
  SELECT hoi.org_information17  Public_Org
  FROM   hr_organization_units hou,hr_organization_information hoi
  WHERE  hoi.org_information_context = 'NL_ORG_INFORMATION'
  AND    hou.business_group_id       = c_business_group_id
  AND    hou.organization_id         = hoi.organization_id
  AND    hou.organization_id         = c_employer_id;
  --
  CURSOR csr_retro_date(c_business_group_id NUMBER) IS
  select fnd_date.canonical_to_date(org_information5)
  from   hr_organization_information
  where  organization_id = c_business_group_id
  AND    org_information_context = 'NL_BG_INFO';
  --
  l_start_date          DATE;
  l_end_date            DATE;
  l_seq_no              VARCHAR2(50);
  l_tax_unit_id         NUMBER;
  l_payroll_type        VARCHAR2(80);
  l_business_group_id   hr_all_organization_units.business_group_id%TYPE;
  l_hr_tax_unit         hr_all_organization_units.organization_id%TYPE;
  l_risk_cover_flag     hr_lookups.lookup_type%TYPE;
  l_date                DATE;
  --
BEGIN
    --
    pay_nl_wage_report_pkg.get_all_parameters(p_actid
                                             ,l_business_group_id
                                             ,l_start_date
                                             ,l_end_date
                                             ,l_tax_unit_id
                                             ,l_payroll_type
                                             ,l_seq_no);
    --
    g_public_org_flag := NULL;
    g_risk_cover_flag := NULL;
    l_hr_tax_unit     := NULL;
    g_retro_type      := 'OLD';
    g_effective_date  := l_end_date;
    --
    OPEN  csr_get_le_info(l_tax_unit_id);
    FETCH csr_get_le_info INTO l_hr_tax_unit,g_public_org_flag,g_risk_cover_flag;
    CLOSE csr_get_le_info;
    --
    IF  g_public_org_flag IS NULL THEN
        OPEN  csr_public_org_flag(NVL(l_hr_tax_unit,l_tax_unit_id),l_business_group_id);
        FETCH csr_public_org_flag INTO g_public_org_flag;
        CLOSE csr_public_org_flag;
    END IF;
    --
    --IF  g_risk_cover_flag IS NULL THEN
        OPEN  csr_own_risk_cover(NVL(l_hr_tax_unit,l_tax_unit_id),l_business_group_id);
        FETCH csr_own_risk_cover INTO l_risk_cover_flag,g_contract_code_mapping;
        CLOSE csr_own_risk_cover;
    --END IF;
    --
    OPEN  csr_retro_date(l_business_group_id);
    FETCH csr_retro_date INTO l_date;
    CLOSE csr_retro_date;
    --
    g_public_org_flag := NVL(g_public_org_flag,'N');
    g_risk_cover_flag := NVL(NVL(g_risk_cover_flag,l_risk_cover_flag),'N');
    g_contract_code_mapping := NVL(g_contract_code_mapping,'NL_EMPLOYMENT_CATG');
    --
    IF l_date <= l_start_date THEN
      g_retro_type := 'NEW';
    END IF;
    --
END set_company_type;
--------------------------------------------------------------------------------
-- INITIALIZE_CODE   pay_nl_wage_report_pkg.archive_init_code
--------------------------------------------------------------------------------
PROCEDURE archive_init_code(p_actid IN  NUMBER) IS
  l_payroll_type  VARCHAR2(80);
BEGIN
    --
    set_company_type(p_actid);
    ---Done for the yearly report
    l_payroll_type := TO_CHAR(get_parameters(p_actid,'Payroll_Type'));
    populate_nom_balance_table(l_payroll_type);
    --
END archive_init_code;
--------------------------------------------------------------------------------
-- ARCHIVE_DEINIT_CODE_YEARLY
--------------------------------------------------------------------------------
PROCEDURE archive_deinit_code_yearly(p_actid             IN  NUMBER
                                    ,p_business_group_id IN NUMBER
                                    ,p_start_date        IN DATE
                                    ,p_end_date          IN DATE
                                    ,p_tax_unit_id       IN NUMBER
                                    ,p_payroll_type      IN VARCHAR2
                                    ,p_seq_no            IN VARCHAR2)
IS
  -- DECLARE LOCAL VARIABLES
  l_ovn     pay_action_information.object_version_number%type;
  l_action_info_id pay_action_information.action_information_id%type;
  l_business_group_id  hr_all_organization_units.business_group_id%type;
  l_start_date DATE;
  l_end_date DATE;
  l_seq_no             VARCHAR2(50);
  l_emp_total number;
  l_tax_unit_id NUMBER;
  l_payroll_type VARCHAR2(80);
  --CURSORS
  -- Employer's contact and telephone number
  CURSOR csr_get_empr_contact(c_employer_id       NUMBER
                             ,c_business_group_id NUMBER) IS
  SELECT hoi.org_information1  sender_id
        ,hoi.org_information2  contact_name
        ,hoi.org_information3  contact_num
  FROM   hr_organization_units hou,hr_organization_information hoi
  WHERE  hoi.org_information_context = 'NL_ORG_WR_INFO'
  AND    hou.business_group_id       = c_business_group_id
  AND    hou.organization_id         = hoi.organization_id
  AND    hou.organization_id         = c_employer_id;
  --
  -- Employer Tax reg name and Tax reg number
  CURSOR csr_tax_details(c_employer_id       NUMBER
                        ,c_business_group_id NUMBER) IS
  SELECT hoi.org_information14 tax_rep_name
        ,hoi.org_information4 tax_reg_num
  FROM   hr_organization_units hou
        ,hr_organization_information hoi
  WHERE  hoi.org_information_context = 'NL_ORG_INFORMATION'
  AND    hou.business_group_id       = c_business_group_id
  AND    hou.organization_id         = hoi.organization_id
  AND    hou.organization_id         = c_employer_id;
  --
   CURSOR csr_le_hr_mapping_chk (p_organization_id NUMBER) IS
  SELECT hoi.org_information1 tax_ref_no
         ,hoi.org_information2 org_id
         ,hoi.org_information3 tax_rep_name
   FROM   hr_organization_information hoi
         ,hr_organization_information hoi1
   WHERE  hoi.org_information_context  = 'NL_LE_TAX_DETAILS'
   AND    hoi.organization_id          = hoi1.organization_id
   AND    hoi1.organization_id         = p_organization_id
   AND    hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
   AND    hoi1.org_information_context = 'CLASS';
 -- Period dates for Employee records
  -- cursor to get distinct start date and end date for the records archived
   -- CURSOR VARIABLES
  l_empr_contact csr_get_empr_contact%ROWTYPE;
  l_tax_details  csr_tax_details%ROWTYPE;
  --l_period_dates csr_period_dates%ROWTYPE;
  --l_get_sect_risk_grp csr_get_sect_risk_grp%ROWTYPE;
  l_date DATE;
  l_c_base_mon_fd NUMBER;
  l_con_mon_fd NUMBER;
  l_corr_bal NUMBER;
  --l_ret_cor_period csr_ret_cor_period%ROWTYPE;
  l_sector_flag VARCHAR2(1);
  l_sip_sector hr_organization_information.org_information1%TYPE;
  l_risk_grp hr_organization_information.org_information1%TYPE;
  l_c_base_mon_fd_z VARCHAR2(1);
  --
  --#
  --
  empr_flag           VARCHAR2(1);
  empe_flag           VARCHAR2(1);
  l_exception_flag    VARCHAR2(1);
  l_awf               VARCHAR2(1);
  l_tax_ref_no        hr_organization_information.org_information1%TYPE;
  l_tax_rep_name      hr_organization_information.org_information3%TYPE;
  l_hr_tax_unit       hr_all_organization_units.organization_id%TYPE;
  --#
  --
  --
  --csr_employer_info_rec   csr_employer_info%ROWTYPE;
  l_first_emp      VARCHAR2(1);
  y                NUMBER;
  l_sector         hr_organization_information.org_information1%TYPE;
  l_risk_group     hr_organization_information.org_information1%TYPE;
  p_swmf_col_bal_def_table BAL_COL_TABLE;
  l_val NUMBER;
  l_curr_ass_action_id NUMBER;
  l_period_ass_action_id NUMBER;
  --
  l_prev_ass_act_id NUMBER;
  l_prev_end_date   DATE;
  l_prev_corr_bal   NUMBER;
  --
--
BEGIN
  --hr_utility.trace_on(null,'NL_WR');
  --Fnd_file.put_line(FND_FILE.LOG,' Entering deinit code ');
  /*Delete all data archived for the current payroll_action_id - to handle assignment level retry*/
  DELETE  pay_action_information
  WHERE  action_context_id   = p_actid
  AND    action_context_type =  'PA';
  --
  empr_flag        := 'N';
  empe_flag        := 'N';
  l_exception_flag := 'N';
  --
  set_company_type(p_actid);
  OPEN  csr_le_hr_mapping_chk(p_tax_unit_id);
  FETCH csr_le_hr_mapping_chk INTO l_tax_ref_no,l_hr_tax_unit,l_tax_rep_name;
  CLOSE csr_le_hr_mapping_chk;
  --
  -- Get Contact Name and Telephone number
  OPEN csr_get_empr_contact(NVL(l_hr_tax_unit,p_tax_unit_id),p_business_group_id);
  FETCH csr_get_empr_contact INTO l_empr_contact;
  CLOSE csr_get_empr_contact;
  -- Get Tax reg num and Tax rep name
  OPEN csr_tax_details(NVL(l_hr_tax_unit,p_tax_unit_id),p_business_group_id);
  FETCH csr_tax_details INTO l_tax_details;
  CLOSE csr_tax_details;
   --
  l_tax_details.tax_rep_name := NVL(l_tax_rep_name,l_tax_details.tax_rep_name);
  l_tax_details.tax_reg_num := NVL(l_tax_ref_no,l_tax_details.tax_reg_num);
  --
  --Archiving Employee Data NL_WR_EMPLOYER_INFO
  --Fnd_file.put_line(FND_FILE.LOG,' Archiving NL_WR_EMPLOYER_INFO deinit code ');
  pay_action_information_api.create_action_information
  (
    p_action_information_id        =>  l_action_info_id
  , p_action_context_id            =>  p_actid
  , p_action_context_type          =>  'PA'
  , p_object_version_number        =>  l_ovn
  , p_assignment_id                =>  NULL
  , p_effective_date               =>  p_end_date
  , p_source_id                    =>  NULL
  , p_source_text                  =>  NULL
  , p_tax_unit_id                  =>  p_tax_unit_id
  , p_action_information_category  =>  'NL_WR_EMPLOYER_INFO'
  , p_action_information1          =>  p_tax_unit_id
  , p_action_information2          =>  substr(l_empr_contact.sender_id||l_tax_details.tax_reg_num,1,32)
  , p_action_information3          =>  fnd_date.date_to_canonical(sysdate)
  , p_action_information4          =>  substr(l_empr_contact.contact_name,1,35)
  , p_action_information5          =>  substr(l_seq_no,1,6)
  , p_action_information6          =>  substr(l_empr_contact.contact_num,1,25)  --abraghun--7668628-- LC 2009 : Format changed from X(14) to X(25)
  , p_action_information7          =>  'SWO00361ORACLE'  --'BEL00361ORACLE'		--Bug#: 7338209
  , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12)
  , p_action_information9	       =>  substr(l_tax_details.tax_rep_name,1,200)
  , p_action_information10         =>  fnd_date.date_to_canonical(GREATEST(p_start_date,trunc(p_end_date,'Y')))
  , p_action_information11         =>  fnd_date.date_to_canonical(p_end_date)
  , p_action_information12         =>  g_contract_code_mapping
--LC2010--
  , p_action_information13         =>  'SWO00361'
  , p_action_information14         =>  'Oracle Payroll');
--LC2010--
  --Fnd_file.put_line(FND_FILE.LOG,' Archived NL_WR_EMPLOYER_INFO deinit code ');
  --

    --Fnd_file.put_line(FND_FILE.LOG,' Leaving Deinit Code');
--#
 EXCEPTION
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
    --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
    hr_utility.set_location(sqlerrm(sqlcode),110);
END archive_deinit_code_yearly;
--------------------------------------------------------------------------------
-- DEINITIALIZE_CODE   pay_nl_wage_report_pkg.archive_deinit_code
--------------------------------------------------------------------------------
PROCEDURE archive_deinit_code(p_actid IN  NUMBER)
IS
  -- DECLARE LOCAL VARIABLES
  l_ovn     pay_action_information.object_version_number%type;
  l_action_info_id pay_action_information.action_information_id%type;
  l_business_group_id  hr_all_organization_units.business_group_id%type;
  l_start_date DATE;
  l_end_date DATE;
  l_seq_no             VARCHAR2(50);
  l_emp_total number;
  l_tax_unit_id NUMBER;
  l_payroll_type VARCHAR2(80);
  --abraghun--7668628-- Validatation Local Variables--
  l_NR_LnLbPh    NUMBER;
  l_NR_LnSV      NUMBER;
  l_NR_IngLbPh   NUMBER;
  l_NR_PrWAOAof  NUMBER;
  l_NR_PrWAOAok  NUMBER;
  l_NR_PrAWF     NUMBER;
  l_NR_PrWgf     NUMBER;
  l_NR_PrUFO     NUMBER;
  l_NR_BijdrZvw  NUMBER;
  l_NR_VergZvw   NUMBER;

  l_CR_TotLnLbPh   NUMBER;
  l_CR_TotLnSV     NUMBER;
  l_CR_PrLnUFO     NUMBER;
  l_CR_PrLnAWF     NUMBER;
  l_CR_PrLnWAOAok  NUMBER;
  l_CR_PrLnWAOAof  NUMBER;
  l_CR_TotVergZvw  NUMBER;
  l_CR_IngLbPh     NUMBER;
  l_CR_PrWAOAof    NUMBER;
  l_CR_PrWAOAok    NUMBER;
  l_CR_PrAWF       NUMBER;
  l_CR_PrWgf       NUMBER;
  l_CR_PrUFO       NUMBER;
  l_CR_IngBijdrZvw NUMBER;

  --l_CR_TotTeBet    NUMBER;
  --l_CR_TotTeBet_Sum NUMBER;
  --l_CR_Saldo_Sum    NUMBER;
  --l_CR_TotGen      NUMBER;

--  l_SWMF_Sect_Count   NUMBER;
--  l_SWMF_RisGrp_Count NUMBER;
--  l_SWMF_PrWgf        NUMBER;
  l_SWMF_PrLnWgf      NUMBER;

 --abraghun--7668628-- Validatation Local Variables End --

  --CURSORS
  --abraghun--7668628-- Validation Cursors
  CURSOR csr_nominative_sum (c_payroll_action_id  IN NUMBER) IS
                   SELECT
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION5) ,0)))) LnLbPh,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION6) ,0)))) LnSV,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION15),0)))) IngLbPh,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION16),0)))) PrWAOAof,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION17),0)))) PrWAOAok,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION18),0)))) PrAWF,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION19),0)))) PrWgf,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION20),0)))) PrUFO,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION21),0)))) BijdrZvw,
                     fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(pai.ACTION_INFORMATION22),0)))) VergZvw
                   FROM   PAY_ACTION_INFORMATION pai
                     WHERE  ACTION_CONTEXT_ID IN
                       (SELECT ASSIGNMENT_ACTION_ID
                       FROM PAY_ASSIGNMENT_ACTIONS paa
                       WHERE PAYROLL_ACTION_ID=c_payroll_action_id)
                     AND ACTION_INFORMATION_CATEGORY='NL_WR_NOMINATIVE_REPORT'
                     AND ACTION_INFORMATION1='INITIAL';

  CURSOR csr_swmf_sum (c_payroll_action_id IN NUMBER) IS
/*                  SELECT
               COUNT(pai.ACTION_INFORMATION7) Sect,
                   COUNT(pai.ACTION_INFORMATION8) RisGrp,
                   fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(ACTION_INFORMATION10),0)))) PrWgf,
                   fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(ACTION_INFORMATION9),0)))) PrLnWgf
                  FROM   pay_action_information pai
                    WHERE  ACTION_CONTEXT_ID IN
                       (SELECT ASSIGNMENT_ACTION_ID
                       FROM PAY_ASSIGNMENT_ACTIONS paa
                       WHERE PAYROLL_ACTION_ID=c_payroll_action_id)
                   AND ACTION_INFORMATION_CATEGORY ='NL_WR_SWMF_SECTOR_RISK_GROUP';
                   --AND ACTION_INFORMATION1='SWMF'
*/
        SELECT fnd_number.number_to_canonical(ROUND(SUM(NVL(fnd_number.canonical_to_number(PAI1.ACTION_INFORMATION9),0)))) PrLnWgf
                FROM pay_action_information PAI1, pay_action_information PAI2
                    WHERE PAI1.action_context_id = c_payroll_action_id
                    AND PAI1.action_context_id = PAI2.action_context_id
                    AND PAI2.action_context_type = 'PA'
                    AND PAI2.action_information_category = 'NL_WR_EMPLOYER_INFO'
                    AND PAI1.action_information_category ='NL_WR_SWMF_SECTOR_RISK_GROUP'
                    AND PAI1.ACTION_INFORMATION1 ='SWMF'
                    AND PAI1.action_information5 = PAI2.action_information10
                    AND PAI1.action_information6 = PAI2.action_information11;

    /*
        Cursor for Employee Record Mismatch Identification
        BSN/Sofi/NumIV Uniqueness Checks (0036,0037,1036,1037)
        Dropped due to Performance considerations

  CURSOR csr_er_mismatch(c_payroll_action_id  IN NUMBER,
                         c_payroll_type VARCHAR2) IS
                  SELECT * FROM
                    (SELECT
                      ACTION_CONTEXT_ID ER_assactid,
                      TAX_UNIT_ID ER_tax_unit_id,
                      ACTION_INFORMATION10||ACTION_INFORMATION11||ACTION_INFORMATION9 ER_name,
                      ACTION_INFORMATION4 ER_assignment_number,
                      ACTION_INFORMATION8 Sofi,
                      ACTION_INFORMATION5 PersNr,
                      ACTION_INFORMATION18 NumIV,
                      EFFECTIVE_DATE ER_eff_date,
                      ASSIGNMENT_ID ER_assignment_id,
                      count(*) over(partition by ACTION_INFORMATION18,ACTION_INFORMATION8) NumIVSofi,
                      count(*) over(partition by ACTION_INFORMATION18,ACTION_INFORMATION5) NumIVPersNr
                     FROM   pay_action_information pai
                        WHERE  ACTION_CONTEXT_ID IN
                                           (SELECT ASSIGNMENT_ACTION_ID
                                           FROM PAY_ASSIGNMENT_ACTIONS paa
                                           WHERE PAYROLL_ACTION_ID=c_payroll_action_id)
                        AND ACTION_INFORMATION_CATEGORY = 'NL_WR_EMPLOYMENT_INFO'
                        AND ACTION_INFORMATION1=c_payroll_type)
                    WHERE (NumIVPersNr+NumIVSofi)>2;
*/


    --abraghun--7668628-- Cursor to find Correction Reports with same period as Normal Report.
    -- Cursor for Check0022

    CURSOR csr_period_overlap (c_payroll_action_id IN NUMBER) IS
              SELECT
               fnd_date.canonical_to_date(pai1.action_information2) start_date
              ,fnd_date.canonical_to_date(pai1.action_information3) end_date
             	FROM pay_action_information pai1,
                  	 pay_action_information pai2
            		,pay_assignment_actions paa
            	WHERE pai1.action_context_type         = 'AAP'
            	AND   pai2.action_context_type         = 'AAP'
            	AND   pai1.action_information_category = 'NL_WR_EMPLOYMENT_INFO'
            	AND   pai2.action_information_category = 'NL_WR_EMPLOYMENT_INFO'
            	AND   pai1.action_context_id 		  = paa.assignment_action_id
            	AND   pai2.action_context_id 		  = paa.assignment_action_id
            	AND   paa.payroll_action_id 		  = c_payroll_action_id
            	AND   pai1.action_information1 		  = 'INITIAL'
            	AND   pai2.action_information1 		  <>'INITIAL'
            	AND   pai1.action_information2        = pai2.action_information2
            	AND   pai1.action_information3        = pai2.action_information3;

  --abraghun--7668628-- Validation Cursors End

  -- Employer's contact and telephone number
  CURSOR csr_get_empr_contact(c_employer_id       NUMBER
                             ,c_business_group_id NUMBER) IS
  SELECT hoi.org_information1  sender_id
        ,hoi.org_information2  contact_name
        ,hoi.org_information3  contact_num
  FROM   hr_organization_units hou,hr_organization_information hoi
  WHERE  hoi.org_information_context = 'NL_ORG_WR_INFO'
  AND    hou.business_group_id       = c_business_group_id
  AND    hou.organization_id         = hoi.organization_id
  AND    hou.organization_id         = c_employer_id;
  --
  -- Employer Tax reg name and Tax reg number
  CURSOR csr_tax_details(c_employer_id       NUMBER
                        ,c_business_group_id NUMBER) IS
  SELECT hoi.org_information14 tax_rep_name
        ,hoi.org_information4 tax_reg_num
  FROM   hr_organization_units hou
        ,hr_organization_information hoi
  WHERE  hoi.org_information_context = 'NL_ORG_INFORMATION'
  AND    hou.business_group_id       = c_business_group_id
  AND    hou.organization_id         = hoi.organization_id
  AND    hou.organization_id         = c_employer_id;
  --
  -- Period dates for Employee records
  -- cursor to get distinct start date and end date for the records archived
  CURSOR csr_period_dates(c_pact_id     NUMBER) IS
  SELECT DISTINCT pai.Action_Information2 Start_date
        ,pai.action_information3 End_date
  FROM   pay_assignment_actions  paa
        ,pay_action_information  pai
  WHERE  paa.payroll_action_id           = c_pact_id
  AND    paa.assignment_action_id        = pai.action_context_id
  AND    pai.action_information_category = 'NL_WR_EMPLOYMENT_INFO'
  AND    pai.action_information1         IN ('INITIAL','CORRECTION','CORRECT')
  AND    pai.action_context_type         = 'AAP';
  --
  -- Employeer Sector and Risk Group
  CURSOR csr_get_sect_risk_grp(c_employer_id       NUMBER
                              ,c_effective_date    DATE
                              ,c_business_group_id NUMBER)  IS
  SELECT distinct hoi1.org_information5 sector
        ,hoi1.org_information6 risk_group
        ,hoi1.organization_id
  FROM   hr_organization_information hoi1
        ,hr_organization_information hoi2
        ,hr_organization_information hoi3
        ,per_org_structure_versions  posv
  WHERE  hoi2.org_information4 = hoi1.organization_id
  AND    hoi1.org_information5 IS NOT NULL
  AND    hoi1.org_information6 IS NOT NULL
  AND    hoi2.org_information_context= 'NL_SIP'
  AND    hoi1.org_information_context= 'NL_UWV'
  AND    hoi3.organization_id = c_business_group_id
  AND    hoi3.org_information_context= 'NL_BG_INFO'
  --AND    hoi2.org_information7 = 'Y'
  AND    hr_nl_org_info.Get_Tax_Org_Id(posv.ORG_STRUCTURE_VERSION_ID ,hoi2.organization_id) = c_employer_id
  AND    posv.ORGANIZATION_STRUCTURE_ID = TO_NUMBER(hoi3.org_information1)
  AND    c_effective_date BETWEEN posv.date_from
                              AND    nvl(posv.date_to,to_date('31-12-4712','dd-mm-yyyy'))
  AND    c_effective_date BETWEEN fnd_date.canonical_to_date(hoi2.org_information1)
                              AND    nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31-12-4712','dd-mm-yyyy'))
  AND    EXISTS (SELECT 1
                 FROM hr_organization_information hoi4
                 WHERE hoi4.organization_id         = hoi1.organization_id
                 AND   hoi4.org_information_context = 'NL_SIT'
                 AND   ORG_INFORMATION4 = 'WEWA')
  ORDER BY 1,2;
  --
  -- Correction balance total periods
  CURSOR csr_ret_cor_period(c_pact_id NUMBER) IS
  SELECT DISTINCT fnd_date.canonical_to_date(pai.Action_Information2) Start_date
        ,fnd_date.canonical_to_date(pai.action_information3) End_date
  FROM   pay_assignment_actions  paa
        ,pay_action_information  pai
  WHERE  paa.payroll_action_id           = c_pact_id
  AND    paa.assignment_action_id        = pai.action_context_id
  AND    pai.action_information_category = 'NL_WR_EMPLOYMENT_INFO'
  AND    pai.action_information1         IN ('INITIAL','CORRECTION','CORRECT')
  AND    pai.action_context_type         = 'AAP'
  AND    pai.action_information17 = 'PAY';
   --
   --
/*   CURSOR csr_le_hr_mapping_chk (p_organization_id NUMBER) IS
   SELECT hoi.org_information2 org_id
        ,hoi.org_information5 Public_Org
        ,hoi.org_information6 Own_Risk_Cover
   FROM  hr_organization_information hoi
   WHERE hoi.org_information_context  = 'NL_LE_TAX_DETAILS'
   AND   hoi.organization_id          = p_organization_id
   AND   EXISTS (SELECT 1
                 FROM   hr_organization_information hoi1
                 WHERE  hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
                 AND    hoi1.org_information_context = 'CLASS'
                 AND    hoi1.organization_id         = hoi.organization_id); */
  CURSOR csr_le_hr_mapping_chk (p_organization_id NUMBER) IS
  SELECT hoi.org_information1 tax_ref_no
         ,hoi.org_information2 org_id
         ,hoi.org_information3 tax_rep_name
   FROM   hr_organization_information hoi
         ,hr_organization_information hoi1
   WHERE  hoi.org_information_context  = 'NL_LE_TAX_DETAILS'
   AND    hoi.organization_id          = hoi1.organization_id
   AND    hoi1.organization_id         = p_organization_id
   AND    hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
   AND    hoi1.org_information_context = 'CLASS';
   --
   -- CURSOR VARIABLES
  l_empr_contact csr_get_empr_contact%ROWTYPE;
  l_tax_details  csr_tax_details%ROWTYPE;
  --l_period_dates csr_period_dates%ROWTYPE;
  l_get_sect_risk_grp csr_get_sect_risk_grp%ROWTYPE;
  l_date DATE;
  l_c_base_mon_fd NUMBER;
  l_con_mon_fd NUMBER;
  l_corr_bal NUMBER;
  l_ret_cor_period csr_ret_cor_period%ROWTYPE;
  l_sector_flag VARCHAR2(1);
  l_sip_sector hr_organization_information.org_information1%TYPE;
  l_risk_grp hr_organization_information.org_information1%TYPE;
  l_c_base_mon_fd_z VARCHAR2(1);
  --
  --#
  CURSOR csr_get_PA_exception_info(p_payroll_action_id IN NUMBER) IS
  SELECT pai_p.action_information4            Message
        ,fnd_date.date_to_displaydate(fnd_date.canonical_to_date(pai_p.action_information5)) Dt
        ,pai_p.action_information6            Description
        ,substr(pai_p.action_information7,1,30) E_Name
        ,substr(pai_p.action_information8,1,30) E_Number
        ,pai_p.action_context_type            cxt
  FROM   pay_action_information               pai_p
  WHERE  pai_p.action_context_id              = p_payroll_action_id
  AND    pai_p.action_information_category    = 'NL_WR_EXCEPTION_REPORT'
  AND    pai_p.action_context_type            = 'PA'
  ORDER  BY pai_p.action_information8 asc;
  --
  CURSOR csr_get_AAP_exception_info(p_payroll_action_id IN NUMBER) IS
  SELECT pai_p.action_information4            Message
        ,fnd_date.date_to_displaydate(fnd_date.canonical_to_date(pai_p.action_information5)) Dt
        ,pai_p.action_information6            Description
        ,substr(pai_p.action_information7,1,30) E_Name
        ,substr(pai_p.action_information8,1,30) E_Number
        ,pai_p.action_context_type            cxt
  FROM   pay_assignment_actions               paa
        ,pay_action_information               pai_p
  WHERE  paa.payroll_action_id                = p_payroll_action_id
  AND    pai_p.action_context_id             = paa.assignment_action_id
  AND    pai_p.action_information_category    = 'NL_WR_EXCEPTION_REPORT'
  AND    pai_p.action_context_type            = 'AAP'
  ORDER  BY pai_p.action_information8 asc;
  --
  empr_flag           VARCHAR2(1);
  empe_flag           VARCHAR2(1);
  l_exception_flag    VARCHAR2(1);
  l_awf               VARCHAR2(1);
  l_tax_ref_no        hr_organization_information.org_information1%TYPE;
  l_tax_rep_name      hr_organization_information.org_information3%TYPE;
  l_hr_tax_unit       hr_all_organization_units.organization_id%TYPE;
  --#
  --
  CURSOR csr_get_pactid IS
  SELECT DISTINCT paa1.payroll_action_id
  FROM   pay_assignment_actions paa
        ,pay_action_interlocks     pal
        ,pay_assignment_actions paa1
  WHERE  paa.payroll_action_id    = p_actid
  AND    paa.assignment_action_id = pal.locking_action_id
  AND    pal.locked_action_id     = paa1.assignment_action_id
  ORDER BY paa1.payroll_action_id DESC;
  --
  CURSOR csr_employer_info(c_category       VARCHAR2
                          ,c_pactid         NUMBER) IS
  SELECT pai.*
  FROM  pay_action_information pai
  WHERE pai.action_context_type 		  = 'PA'
  AND	  pai.action_context_id   		  = c_pactid
  AND	  pai.action_information_category = c_category;
  --
  CURSOR csr_swmf_employer_info(c_legal_employer NUMBER
                               ,c_start_date     DATE
                               ,c_end_date       DATE) IS
  SELECT action_information7
        ,action_information8
        ,sum(fnd_number.canonical_to_number(action_information9)) action_information9
        ,sum(fnd_number.canonical_to_number(action_information10))action_information10
  FROM  pay_action_information pai
   	   ,pay_payroll_actions	ppa
  WHERE ppa.report_type       = 'NL_WAGES_REP_ARCHIVE'
  AND   ppa.report_qualifier  = 'NL'
  AND   ppa.action_type	     = 'X'
  AND   ppa.action_status 	 = 'C'
  AND	  INSTR(ppa.legislative_parameters,'Payroll_Type=WEEK') <> 0
  AND	  INSTR(ppa.legislative_parameters,'Legal_Employer='||c_legal_employer) <> 0
  AND   ppa.effective_date BETWEEN c_start_date
                               AND c_end_date
  AND   pai.action_context_type 		  = 'PA'
  AND	  pai.action_context_id   		  = ppa.payroll_action_id
  AND	  pai.action_information_category = 'NL_WR_SWMF_SECTOR_RISK_GROUP'
  AND EXISTS ( SELECT 1
               FROM   pay_assignment_actions paa1
                     ,pay_action_interlocks ai
                     ,pay_assignment_actions paa2
               WHERE  paa1.payroll_action_id    = p_actid
               AND    paa1.assignment_action_id = ai.locking_action_id
               AND    ai.locked_action_id       = paa2.assignment_action_id
               AND    paa2.payroll_action_id    = ppa.payroll_action_id)
  GROUP BY action_information7,action_information8;
  --
  CURSOR csr_payroll_get_action_id(c_payroll_action_id NUMBER) IS
  SELECT max(locked_action_id)
  FROM   pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,pay_action_interlocks pai
  WHERE  ppa.payroll_action_id = c_payroll_action_id
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    pai.locking_action_id = paa.assignment_action_id;
  --
  CURSOR csr_payroll_get_action_id2(c_payroll_action_id NUMBER
                                   ,c_start_date        DATE
                                   ,c_end_date          DATE) IS
  SELECT max(paa2.assignment_action_id)
  FROM   pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,pay_action_interlocks pai
        ,pay_assignment_actions paa1
        ,pay_assignment_actions paa2
        ,pay_payroll_actions ppa2
  WHERE  ppa.payroll_action_id = c_payroll_action_id
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    pai.locking_action_id = paa.assignment_action_id
  AND    paa1.assignment_action_id = pai.locked_action_id
  AND    paa1.assignment_id = paa2.assignment_id
  AND    paa2.payroll_action_id = ppa2.payroll_action_id
  AND    ppa.business_group_id = ppa2.business_group_id
  AND    ppa2.effective_date between c_start_date and c_end_date
  AND    ppa2.action_type in ('R','Q')
  AND    ppa2.action_status = 'C';
  --
  CURSOR csr_get_prev_period(c_ass_act_id NUMBER) IS
  SELECT paa2.assignment_action_id, ptp2.end_date
  FROM   pay_assignment_actions paa1
        ,pay_payroll_actions ppa1
        ,pay_assignment_actions paa2
        ,pay_payroll_actions ppa2
        ,per_time_periods ptp1
        ,per_time_periods ptp2
        ,pay_all_payrolls_f ppf1
        ,pay_all_payrolls_f ppf2
  WHERE  paa1.assignment_action_id = c_ass_act_id
  AND    paa1.payroll_action_id    = ppa1.payroll_action_id
  AND    ppa1.payroll_id           = ppf1.payroll_id
  AND    ppa1.time_period_id       = ptp1.time_period_id
  AND    ppf1.period_type          = 'Calendar Month'
  AND    ppf1.period_type          = ppf2.period_type
  AND    paa1.tax_unit_id          = paa2.tax_unit_id
  AND    paa2.payroll_action_id    = ppa2.payroll_action_id
  AND    ppa2.payroll_id           = ppf2.payroll_id
  AND    ppa2.time_period_id       = ptp2.time_period_id
  AND    ptp2.end_date             < ptp1.end_date
  ORDER BY 2 DESC;

  --
  csr_employer_info_rec   csr_employer_info%ROWTYPE;
  l_first_emp      VARCHAR2(1);
  y                NUMBER;
  l_sector         hr_organization_information.org_information1%TYPE;
  l_risk_group     hr_organization_information.org_information1%TYPE;
  p_swmf_col_bal_def_table BAL_COL_TABLE;
  l_val NUMBER;
  l_curr_ass_action_id NUMBER;
  l_period_ass_action_id NUMBER;
  --
  l_prev_ass_act_id NUMBER;
  l_prev_end_date   DATE;
  l_prev_corr_bal   NUMBER;
  --
BEGIN
--  hr_utility.trace_on(null,'NL_WR');
  --Fnd_file.put_line(FND_FILE.LOG,' Entering deinit code ');
  /*Delete all data archived for the current payroll_action_id - to handle assignment level retry*/
  DELETE  pay_action_information
  WHERE  action_context_id   = p_actid
  AND    action_context_type =  'PA';
  --
  empr_flag        := 'N';
  empe_flag        := 'N';
  l_exception_flag := 'N';
  --
  --Fnd_file.put_line(FND_FILE.LOG,'  0 ');
  pay_nl_wage_report_pkg.get_all_parameters(p_actid
                                           ,l_business_group_id
                                           ,l_start_date
                                           ,l_end_date
                                           ,l_tax_unit_id
                                           ,l_payroll_type
                                           ,l_seq_no);
  --Fnd_file.put_line(FND_FILE.LOG,'  1 ');
  set_company_type(p_actid);
IF  l_payroll_type = 'YEARLY' THEN  --
   archive_deinit_code_yearly(p_actid
                            ,l_business_group_id
                            ,l_start_date
                            ,l_end_date
                            ,l_tax_unit_id
                            ,l_payroll_type
                            ,l_seq_no);
  --Fnd_file.put_line(FND_FILE.LOG,'  2 ');
ELSIF l_payroll_type <> 'FOUR_WEEK' THEN
    --
   l_tax_rep_name := NULL;
   l_tax_ref_no   := NULL;
   l_hr_tax_unit  := NULL;
   --
  --Fnd_file.put_line(FND_FILE.LOG,'  3 ');
   OPEN  csr_le_hr_mapping_chk(l_tax_unit_id);
   FETCH csr_le_hr_mapping_chk INTO l_tax_ref_no,l_hr_tax_unit,l_tax_rep_name;
   CLOSE csr_le_hr_mapping_chk;
   --
  --Fnd_file.put_line(FND_FILE.LOG,'  4 ');
   populate_col_balance_table(l_payroll_type,l_end_date,p_actid,p_swmf_col_bal_def_table);
   l_emp_total := 0;
  --
  --Fnd_file.put_line(FND_FILE.LOG,'  5 ');
  -- Get Contact Name and Telephone number
  OPEN csr_get_empr_contact(NVL(l_hr_tax_unit,l_tax_unit_id),l_business_group_id);
  FETCH csr_get_empr_contact INTO l_empr_contact;
  CLOSE csr_get_empr_contact;
  --Fnd_file.put_line(FND_FILE.LOG,'  6 ');
  --
  -- Get Tax reg num and Tax rep name
  OPEN csr_tax_details(NVL(l_hr_tax_unit,l_tax_unit_id),l_business_group_id);
  FETCH csr_tax_details INTO l_tax_details;
  CLOSE csr_tax_details;
  --Fnd_file.put_line(FND_FILE.LOG,'  7 ');
  --
  l_tax_details.tax_rep_name := NVL(l_tax_rep_name,l_tax_details.tax_rep_name);
  l_tax_details.tax_reg_num := NVL(l_tax_ref_no,l_tax_details.tax_reg_num);
  --
  OPEN  csr_payroll_get_action_id(p_actid);
  FETCH csr_payroll_get_action_id INTO l_curr_ass_action_id;
  CLOSE csr_payroll_get_action_id;
  --Fnd_file.put_line(FND_FILE.LOG,'  8 ');
  --
  --
--
IF l_empr_contact.sender_id IS NULL THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_actid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  NULL
      , p_effective_date               =>  l_end_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  l_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_SENDER_ID')
      , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
      , p_action_information6          =>  'Sender ID is null'
      , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
      , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
END IF;
--
IF l_empr_contact.contact_name IS NULL THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_actid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  NULL
      , p_effective_date               =>  l_end_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  l_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_PERSON_NM')
      , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
      , p_action_information6          =>  'Contact Person is null'
      , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
      , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
END IF;
--
IF l_empr_contact.contact_num IS NULL THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_actid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  NULL
      , p_effective_date               =>  l_end_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  l_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_CONTACT_NO')
      , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
      , p_action_information6          =>  'Contact Number is null'
      , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
      , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
END IF;
--
IF l_tax_details.tax_reg_num IS NULL THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_actid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  NULL
      , p_effective_date               =>  l_end_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  l_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_TAX_NO')
      , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
      , p_action_information6          =>  'Tax Registration Number is null'
      , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
      , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
END IF;
--
IF hr_ni_chk_pkg.chk_nat_id_format(l_tax_details.tax_reg_num,'DDDDDDDDDADD') <> upper(l_tax_details.tax_reg_num) OR
   substr(l_tax_details.tax_reg_num,10,1) <> 'L' THEN
    pay_action_information_api.create_action_information
    (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_actid
    , p_action_context_type          =>  'PA'
    , p_object_version_number        =>  l_ovn
    , p_assignment_id                =>  NULL
    , p_effective_date               =>  l_end_date
    , p_source_id                    =>  NULL
    , p_source_text                  =>  NULL
    , p_tax_unit_id                  =>  l_tax_unit_id
    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
    , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_TAX_FORMAT')
    , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
    , p_action_information6          =>  'Tax Registration Number is not in the format 111111111L11'
    , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
    , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
END IF;
--
IF l_tax_details.tax_rep_name IS NULL THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_actid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  NULL
      , p_effective_date               =>  l_end_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  l_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_TAX_NAME')
      , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
      , p_action_information6          =>  'Tax Reporting Name is null'
      , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
      , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
END IF;
--
  --Archiving Employee Data NL_WR_EMPLOYER_INFO
  --Fnd_file.put_line(FND_FILE.LOG,' Archiving NL_WR_EMPLOYER_INFO deinit code ');
  pay_action_information_api.create_action_information
  (
    p_action_information_id        =>  l_action_info_id
  , p_action_context_id            =>  p_actid
  , p_action_context_type          =>  'PA'
  , p_object_version_number        =>  l_ovn
  , p_assignment_id                =>  NULL
  , p_effective_date               =>  l_end_date
  , p_source_id                    =>  NULL
  , p_source_text                  =>  NULL
  , p_tax_unit_id                  =>  l_tax_unit_id
  , p_action_information_category  =>  'NL_WR_EMPLOYER_INFO'
  , p_action_information1          =>  l_tax_unit_id
  , p_action_information2          =>  substr(l_empr_contact.sender_id||l_tax_details.tax_reg_num,1,32)
  , p_action_information3          =>  fnd_date.date_to_canonical(sysdate)
  , p_action_information4          =>  substr(l_empr_contact.contact_name,1,35)
  , p_action_information5          =>  substr(l_seq_no,1,6)
  , p_action_information6          =>  substr(l_empr_contact.contact_num,1,25)  --abraghun--7668628 -- LC 2009: Phone format changed from X(14) to X(25)
  , p_action_information7          =>  'SWO00361ORACLE'  --'BEL00361ORACLE'		--Bug#: 7338209
  , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12)
  , p_action_information9	         =>  substr(l_tax_details.tax_rep_name,1,200)
  , p_action_information10         =>  fnd_date.date_to_canonical(l_start_date)
  , p_action_information11         =>  fnd_date.date_to_canonical(l_end_date)
  , p_action_information12         =>  g_contract_code_mapping
--LC2010--
  , p_action_information13         =>  'SWO00361'
  , p_action_information14         =>  'Oracle Payroll');
--LC2010--
  --Fnd_file.put_line(FND_FILE.LOG,' Archived NL_WR_EMPLOYER_INFO deinit code ');
  --
 FOR l_period_dates_rec  IN csr_period_dates(p_actid) LOOP
 --Fnd_file.put_line(FND_FILE.LOG,' In csr_period_dates '||l_period_dates_rec.End_date);
   l_date := fnd_date.canonical_to_date(l_period_dates_rec.End_date);
   IF l_date >= l_start_date AND l_date <= l_end_date THEN -- COMPLETE RECORD
     --Fnd_file.put_line(FND_FILE.LOG,' If Current Period -- COMPLETE ');
     --Fnd_file.put_line(FND_FILE.LOG,' Calling populate_coll_bal_table for COMPLETE ');
     populate_coll_bal_table(p_actid          => p_actid
                            ,p_tax_unit_id    => l_tax_unit_id
                            ,p_effective_date => l_date
                            ,p_balance_date   => l_date
                            ,p_type           => 'COMPLETE'
                            ,p_ass_action_id  => l_curr_ass_action_id
                            ,p_payroll_type   => l_payroll_type
                            ,p_emp_total      => l_emp_total
                            ,p_collXMLTable   => collXMLTable);
     --Fnd_file.put_line(FND_FILE.LOG,' Populated coll table in deinit code '||collXMLTable.LAST );
    l_sector_flag := 'N';
    --Sector Risk Group NOT to be archived for public sector company.
    --Fnd_file.put_line(FND_FILE.LOG,' Checking Sector Risk Group Information');
    IF  g_public_org_flag = 'N' THEN
        -- Employer Sector and Risk Group
        l_sip_sector := NULL;
        l_risk_grp := NULL;
        l_c_base_mon_fd := 0;
        l_con_mon_fd := 0;
        l_c_base_mon_fd_z := 'N';
        FOR l_get_sect_risk_grp in csr_get_sect_risk_grp(NVL(l_hr_tax_unit,l_tax_unit_id),l_date,l_business_group_id) LOOP
          l_sip_sector := NVL(l_sip_sector,l_get_sect_risk_grp.sector);
          l_risk_grp := NVL(l_risk_grp,l_get_sect_risk_grp.risk_group);
          IF l_sip_sector <> l_get_sect_risk_grp.sector OR l_risk_grp <> l_get_sect_risk_grp.risk_group THEN
            --Fnd_file.put_line(FND_FILE.LOG,' Archiving Sector Risk Group Information');
              pay_action_information_api.create_action_information
              ( p_action_information_id        =>  l_action_info_id
              , p_action_context_id            =>  p_actid
              , p_action_context_type          =>  'PA'
              , p_object_version_number        =>  l_ovn
              , p_assignment_id                =>  NULL
              , p_effective_date               =>  l_end_date
              , p_source_id                    =>  NULL
              , p_source_text                  =>  NULL
               ,p_tax_unit_id                  =>  l_tax_unit_id
              , p_action_information_category  =>  'NL_WR_SWMF_SECTOR_RISK_GROUP'
              , p_action_information1          =>  'SWMF'
              , p_action_information2          =>  NULL
              , p_action_information5          =>  l_period_dates_rec.start_date
              , p_action_information6          =>  l_period_dates_rec.End_date
              , p_action_information7          =>  substr(l_sip_sector,1,3)
              , p_action_information8          =>  substr(l_risk_grp,1,2)
              , p_action_information9          =>  fnd_number.number_to_canonical(ROUND(l_c_base_mon_fd))
              , p_action_information10         =>  fnd_number.number_to_canonical(ROUND(l_con_mon_fd )));
              l_sip_sector := l_get_sect_risk_grp.sector;
              l_risk_grp := l_get_sect_risk_grp.risk_group;
              l_emp_total := l_emp_total + l_con_mon_fd;
              l_sector_flag := 'Y';
              IF l_c_base_mon_fd = 0 THEN
                l_c_base_mon_fd_z := 'Y';
              END IF;
              l_c_base_mon_fd := 0;
              l_con_mon_fd := 0;
          END IF;
          --Fnd_file.put_line(FND_FILE.LOG,' Calling swmf balance ');
          populate_col_balance_values(p_swmf_col_bal_def_table,l_tax_unit_id,l_date,l_date,'COMPLETE',l_get_sect_risk_grp.organization_id,l_curr_ass_action_id);
          --Fnd_file.put_line(FND_FILE.LOG,' Got swmf balance ');
          FOR i in 1..2 LOOP
          l_c_base_mon_fd := l_c_base_mon_fd + p_swmf_col_bal_def_table(i).balance_value + p_swmf_col_bal_def_table(i).balance_value2;
          END LOOP;
          --
          FOR i in 3..4 LOOP
          l_con_mon_fd := l_con_mon_fd + p_swmf_col_bal_def_table(i).balance_value + p_swmf_col_bal_def_table(i).balance_value2;
          END LOOP;
          --
         END LOOP;
        IF l_sip_sector IS NOT NULL OR l_risk_grp IS NOT NULL THEN
          --Fnd_file.put_line(FND_FILE.LOG,' Archiving Sector Risk Group Information');
            pay_action_information_api.create_action_information
            ( p_action_information_id        =>  l_action_info_id
            , p_action_context_id            =>  p_actid
            , p_action_context_type          =>  'PA'
            , p_object_version_number        =>  l_ovn
            , p_assignment_id                =>  NULL
            , p_effective_date               =>  l_end_date
            , p_source_id                    =>  NULL
            , p_source_text                  =>  NULL
             ,p_tax_unit_id                  =>  l_tax_unit_id
            , p_action_information_category  =>  'NL_WR_SWMF_SECTOR_RISK_GROUP'
            , p_action_information1          =>  'SWMF'
            , p_action_information2          =>  NULL
            , p_action_information5          =>  l_period_dates_rec.start_date
            , p_action_information6          =>  l_period_dates_rec.End_date
            , p_action_information7          =>  substr(l_sip_sector,1,3)
            , p_action_information8          =>  substr(l_risk_grp,1,2)
            , p_action_information9          =>  fnd_number.number_to_canonical(ROUND(l_c_base_mon_fd))
            , p_action_information10         =>  fnd_number.number_to_canonical(ROUND(l_con_mon_fd )));
            --l_sip_sector := l_get_sect_risk_grp.sector;
            --l_risk_grp := l_get_sect_risk_grp.risk_group;
            l_emp_total := l_emp_total + l_con_mon_fd;
            l_sector_flag := 'Y' ;
            IF l_c_base_mon_fd = 0 THEN
              l_c_base_mon_fd_z := 'Y';
            END IF;
            l_c_base_mon_fd := 0;
            l_con_mon_fd := 0;
        END IF;
        --
    END IF;
    --
    l_awf := 'N';
    --Fnd_file.put_line(FND_FILE.LOG,' Start loop for collXMLTable');
    FOR  i IN collXMLTable.FIRST..collXMLTable.LAST LOOP
     --##--Fnd_file.put_line(FND_FILE.LOG,'#########'||'COMPLETE '||collXMLTable(i).TagName||' '||collXMLTable(i).TagValue||' '||collXMLTable(i).Mandatory);
     l_val := NULL;
     IF collXMLTable(i).Mandatory = 'Y' or collXMLTable(i).TagValue <> 0 THEN
       IF collXMLTable(i).TagName = 'TotTeBet' THEN
         l_val := l_emp_total;
       END IF;
       pay_action_information_api.create_action_information
       ( p_action_information_id        =>  l_action_info_id
       , p_action_context_id            =>  p_actid
       , p_action_context_type          =>  'PA'
       , p_object_version_number        =>  l_ovn
       , p_tax_unit_id                  =>  l_tax_unit_id
       , p_assignment_id                =>  NULL
       , p_effective_date               =>  l_end_date
       , p_source_id                    =>  NULL
       , p_source_text                  =>  NULL
       , p_action_information_category  =>  'NL_WR_COLLECTIVE_REPORT'
       , p_action_information1          =>  'COMPLETE'
       , p_action_information2          =>  collXMLTable(i).TagName
       , p_action_information3          =>  l_period_dates_rec.start_date
       , p_action_information4          =>  l_period_dates_rec.End_date
       , p_action_information5          =>  collXMLTable(i).TagDesc
       , p_action_information6          =>  fnd_number.number_to_canonical(ROUND(NVL(l_val,collXMLTable(i).TagValue))));
       IF collXMLTable(i).TagName = 'PrLnAWF' AND collXMLTable(i).TagValue <> 0 THEN
         l_awf := 'Y';
       END IF;
      END IF;
       --abraghun--7668628--Validation Data Capture--

      IF collXMLTable(i).TagName = 'TotLnLbPh' THEN
           l_CR_TotLnLbPh := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'TotLnSV' THEN
           l_CR_TotLnSV := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrLnWAOAof' THEN
           l_CR_PrLnWAOAof := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrLnWAOAok' THEN
           l_CR_PrLnWAOAok := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrLnAWF' THEN
           l_CR_PrLnAWF := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrLnUFO' THEN
           l_CR_PrLnUFO := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'TotVergZvw' THEN
           l_CR_TotVergZvw := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'IngLbPh' THEN
           l_CR_IngLbPh := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrWAOAof' THEN
           l_CR_PrWAOAof := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrWAOAok' THEN
           l_CR_PrWAOAok := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrAWF' THEN
           l_CR_PrAWF := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrWgf' THEN
           l_CR_PrWgf := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'PrUFO' THEN
           l_CR_PrUFO := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
         ELSIF collXMLTable(i).TagName = 'IngBijdrZvw' THEN
           l_CR_IngBijdrZvw := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
  /*       ELSIF collXMLTable(i).TagName = 'TotTeBet' THEN
           l_CR_TotTeBet := fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue));
*/
      END IF;

/*
    --abraghun--7668628-- Data Capture for Check0010
    IF collXMLTable(i).TagName IN
                            ('IngLbPh',
                             'EHPubUitk',
                             'EHLnBestKar',
                             'EHSpLn',
                             'EHSpPr',
                             'EHLnNat',
                             'EHFeest',
                             'EHBmVerg',
                             'EHVUT',
                             'PrWAOAof',
                             'PrWAOAok',
                             'PrAWF',
                             'PrUFO',
                             'IngBijdrZvw') THEN

        l_CR_TotTeBet_Sum := fnd_number.number_to_canonical(
                            fnd_number.canonical_to_number(NVL(l_CR_TotTeBet_Sum,0))
                            +ROUND(collXMLTable(i).TagValue));

    ELSIF collXMLTable(i).TagName IN
                           ('AVBetOV',
                            'AVLgdWerkl',
                            'AVArboNP',
                            'AVZeev',
                            'AVOnd',
                            'AGHKort',
                            'VrlAVSO') THEN
        l_CR_TotTeBet_Sum := fnd_number.number_to_canonical(
                            fnd_number.canonical_to_number(NVL(l_CR_TotTeBet_Sum,0))
                            -ROUND(collXMLTable(i).TagValue));

    END IF;


*/

       --abraghun--7668628--Validation Data Capture End--

    END LOOP;


    --
    IF  g_public_org_flag = 'N' THEN
       IF l_sector_flag = 'N' THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_SECTOR')
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  'Mandatory check on Sector'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
          --
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_RISK_GROUP')
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  'No Risk Group'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
        --
        IF l_awf <> 'N' AND l_c_base_mon_fd_z = 'Y' THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_ZERO_BASE_WEWE') -- Message Code should have been '%_WEWA'
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  'Waiting Money Fund contribution base is zero'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
        --
        IF l_awf = 'N' AND l_c_base_mon_fd_z <> 'Y' THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_ZERO_AWF')
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  'AWF contribution base is zero'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
    END IF;
    --#
    --Correction total balance
    l_prev_ass_act_id := NULL;
    --Fnd_file.put_line(FND_FILE.LOG,'Fetching prev period act_id -- CORR_BALANCE ');
    OPEN  csr_get_prev_period(l_curr_ass_action_id);
    FETCH csr_get_prev_period INTO l_prev_ass_act_id, l_prev_end_date;
    CLOSE csr_get_prev_period;
    --Fnd_file.put_line(FND_FILE.LOG,'Prev period End Date -- CORR_BALANCE '||fnd_date.date_to_canonical(l_prev_end_date));
    --Fnd_file.put_line(FND_FILE.LOG,'Prev period act_id -- CORR_BALANCE '||fnd_number.number_to_canonical(l_prev_ass_act_id));
    FOR l_ret_cor_period IN csr_ret_cor_period(p_actid) LOOP
        --Fnd_file.put_line(FND_FILE.LOG,'Calling populate_coll_bal_table -- CORR_BALANCE '||fnd_date.date_to_canonical(l_ret_cor_period.End_date));
        populate_coll_bal_table(p_actid         => p_actid
                               ,p_tax_unit_id   => l_tax_unit_id
                               ,p_effective_date=> l_end_date
                               ,p_balance_date  => l_ret_cor_period.End_date
                               ,p_type          => 'CORR_BALANCE'
                               ,p_ass_action_id => l_curr_ass_action_id
                               ,p_payroll_type  => l_payroll_type
                               ,p_emp_total     => l_corr_bal
                               ,p_collXMLTable  => collXMLTable);
        --Fnd_file.put_line(FND_FILE.LOG,'corr balance -- CORR_BALANCE '||fnd_number.number_to_canonical(l_corr_bal));
        IF l_prev_ass_act_id IS NOT NULL THEN
          populate_coll_bal_table(p_actid         => p_actid
                                 ,p_tax_unit_id   => l_tax_unit_id
                                 ,p_effective_date=> l_prev_end_date
                                 ,p_balance_date  => l_ret_cor_period.End_date
                                 ,p_type          => 'CORR_BALANCE'
                                 ,p_ass_action_id => l_prev_ass_act_id
                                 ,p_payroll_type  => l_payroll_type
                                 ,p_emp_total     => l_prev_corr_bal
                                 ,p_collXMLTable  => collXMLTable);
          l_corr_bal := l_corr_bal - NVL(l_prev_corr_bal,0);
          --Fnd_file.put_line(FND_FILE.LOG,'Prev corr balance -- CORR_BALANCE '||fnd_number.number_to_canonical(l_prev_corr_bal));
        END IF;

        --Fnd_file.put_line(FND_FILE.LOG,' Checking Sector Risk Group Information');
        IF  g_public_org_flag = 'N' THEN
          FOR l_get_sect_risk_grp in csr_get_sect_risk_grp(NVL(l_hr_tax_unit,l_tax_unit_id),l_date,l_business_group_id) LOOP
            --Fnd_file.put_line(FND_FILE.LOG,' Calling swmf balance -- CORR_BALANCE');
            populate_col_balance_values(p_swmf_col_bal_def_table,l_tax_unit_id,l_end_date,l_ret_cor_period.End_date,'CORR_BALANCE',l_get_sect_risk_grp.organization_id,l_curr_ass_action_id);
            --Fnd_file.put_line(FND_FILE.LOG,' Got swmf balance ');
            FOR i in 3..4 LOOP
              l_corr_bal := l_corr_bal + p_swmf_col_bal_def_table(i).balance_value + p_swmf_col_bal_def_table(i).balance_value2;
            END LOOP;
            --
            IF l_prev_ass_act_id IS NOT NULL THEN
              populate_col_balance_values(p_swmf_col_bal_def_table,l_tax_unit_id,l_prev_end_date,l_ret_cor_period.End_date,'CORR_BALANCE',l_get_sect_risk_grp.organization_id,l_prev_ass_act_id);
              --Fnd_file.put_line(FND_FILE.LOG,' Got swmf balance for prev period');
              FOR i in 3..4 LOOP
                l_corr_bal := l_corr_bal - (p_swmf_col_bal_def_table(i).balance_value + p_swmf_col_bal_def_table(i).balance_value2);
              END LOOP;
            END IF;
            --
          END LOOP;
          --
        END IF;
        l_emp_total := l_emp_total + l_corr_bal;
        --Fnd_file.put_line(FND_FILE.LOG,'Archiving NL_WR_COLLECTIVE_REPORT - CORR_BALANCE ');
        pay_action_information_api.create_action_information
          ( p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_action_information_category  =>  'NL_WR_COLLECTIVE_REPORT'
          , p_action_information1          =>  'CORR_BALANCE'
          , p_action_information2          =>  'Saldo'
          , p_action_information3          =>  fnd_date.date_to_canonical(l_ret_cor_period.start_date)
          , p_action_information4          =>  fnd_date.date_to_canonical(l_ret_cor_period.End_date)
          , p_action_information5          =>  HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('Saldo'))
          , p_action_information6          =>  fnd_number.number_to_canonical(ROUND(l_corr_bal)));
/*
        --abraghun--7668628-- Validation Data Capture --Check0011 -Begins
          l_CR_Saldo_Sum := fnd_number.number_to_canonical(
                            fnd_number.canonical_to_number(NVL(l_CR_Saldo_Sum,0))
                            +ROUND(l_corr_bal));
        --abraghun--7668628-- Validation Data Capture --Check0011 -Ends
*/
    END LOOP;
    -- Employer general total
    --Fnd_file.put_line(FND_FILE.LOG,'Archiving NL_WR_COLLECTIVE_REPORT - TOTAL ');
    pay_action_information_api.create_action_information
    (p_action_information_id        =>  l_action_info_id
    ,p_action_context_id            =>  p_actid
    ,p_action_context_type          =>  'PA'
    ,p_object_version_number        =>  l_ovn
    ,p_tax_unit_id                  =>  l_tax_unit_id
    ,p_assignment_id                =>  NULL
    ,p_effective_date               =>  l_end_date
    ,p_source_id                    =>  NULL
    ,p_source_text                  =>  NULL
    ,p_action_information_category  =>  'NL_WR_COLLECTIVE_REPORT'
    ,p_action_information1          =>  'TOTAL'
    ,p_action_information2          =>  'TotGen' -- TAG NAME
    ,p_action_information3          =>  l_period_dates_rec.start_date
    ,p_action_information4          =>  l_period_dates_rec.End_date
    ,p_action_information5          =>  HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotGen')) -- TAG DESCRIPTION
    ,p_action_information6          =>  fnd_number.number_to_canonical(ROUND(l_emp_total)));
/*
        --abraghun--7668628-- Validataion Data Capture --Check0011 -Begins
        l_CR_TotGen := fnd_number.number_to_canonical(ROUND(l_emp_total));
        --abraghun--7668628-- Validataion Data Capture --Check0011 -Ends
*/
  ELSE
    --Fnd_file.put_line(FND_FILE.LOG,' ELSE (Correction Period) -- CORRECTION ');
    OPEN  csr_payroll_get_action_id2(p_actid
                                    ,fnd_date.canonical_to_date(l_period_dates_rec.start_date)
                                    ,fnd_date.canonical_to_date(l_period_dates_rec.End_date));
    FETCH csr_payroll_get_action_id2 INTO l_period_ass_action_id;
    CLOSE csr_payroll_get_action_id2;
    --Fnd_file.put_line(FND_FILE.LOG,'Calling populate_coll_bal_table -- CORRECTION ');
    populate_coll_bal_table(p_actid => p_actid
                            ,p_tax_unit_id => l_tax_unit_id
                            ,p_effective_date => l_end_date
                            ,p_balance_date   => l_date
                            ,p_type => 'CORRECTION'
                            ,p_ass_action_id  => l_period_ass_action_id -- pass that months action id
                            ,p_payroll_type   => l_payroll_type
                            ,p_emp_total => l_emp_total
                            ,p_collXMLTable => collXMLTable);
    -- Employer Sector and Risk Group
    l_sector_flag := 'N';
    --Sector Risk Group NOT to be archived for public sector company. -vv
    --Fnd_file.put_line(FND_FILE.LOG,' Checking Sector Risk Group Information');
    IF  g_public_org_flag = 'N' THEN
        l_sip_sector := NULL;
        l_risk_grp := NULL;
        l_c_base_mon_fd := 0;
        l_con_mon_fd := 0;
        l_c_base_mon_fd_z := 'N';
        FOR l_get_sect_risk_grp in csr_get_sect_risk_grp(NVL(l_hr_tax_unit,l_tax_unit_id),l_date,l_business_group_id) LOOP
          l_sip_sector := NVL(l_sip_sector,l_get_sect_risk_grp.sector);
          l_risk_grp := NVL(l_risk_grp,l_get_sect_risk_grp.risk_group);
          IF l_sip_sector <> l_get_sect_risk_grp.sector OR l_risk_grp <> l_get_sect_risk_grp.risk_group THEN
              --Fnd_file.put_line(FND_FILE.LOG,'Archiving NL_WR_SWMF_SECTOR_RISK_GROUP -- CORRECTION');
              pay_action_information_api.create_action_information
              (
                p_action_information_id        =>  l_action_info_id
              , p_action_context_id            =>  p_actid
              , p_action_context_type          =>  'PA'
              , p_object_version_number        =>  l_ovn
              , p_assignment_id                =>  NULL
              , p_effective_date               =>  l_end_date
              , p_source_id                    =>  NULL
              , p_source_text                  =>  NULL
               ,p_tax_unit_id                  =>  l_tax_unit_id
              , p_action_information_category  =>  'NL_WR_SWMF_SECTOR_RISK_GROUP'
              , p_action_information1          =>  'SWMF'
              , p_action_information2          =>  NULL
              , p_action_information5          =>  l_period_dates_rec.start_date
              , p_action_information6          =>  l_period_dates_rec.End_date
              , p_action_information7          =>  substr(l_sip_sector,1,3)
              , p_action_information8          =>  substr(l_risk_grp,1,2)
              , p_action_information9          =>  fnd_number.number_to_canonical(ROUND(l_c_base_mon_fd))
              , p_action_information10         =>  fnd_number.number_to_canonical(ROUND(l_con_mon_fd)));
              l_sip_sector := l_get_sect_risk_grp.sector;
              l_risk_grp := l_get_sect_risk_grp.risk_group;
              l_emp_total := l_emp_total + l_con_mon_fd;
              l_sector_flag := 'Y';
              IF l_c_base_mon_fd = 0 THEN
                l_c_base_mon_fd_z := 'Y';
              END IF;
              l_c_base_mon_fd := 0;
              l_con_mon_fd := 0;
          END IF;
          --Fnd_file.put_line(FND_FILE.LOG,' Calling swmf balance -- CORRECTION');
          populate_col_balance_values(p_swmf_col_bal_def_table,l_tax_unit_id,l_end_date,l_date,'CORRECTION',l_get_sect_risk_grp.organization_id,l_period_ass_action_id);
          --Fnd_file.put_line(FND_FILE.LOG,' Got swmf balance ');
          l_c_base_mon_fd := 0;
          l_con_mon_fd := 0;
          FOR i in 1..2 LOOP
            l_c_base_mon_fd := l_c_base_mon_fd + p_swmf_col_bal_def_table(i).balance_value + p_swmf_col_bal_def_table(i).balance_value2;
          END LOOP;
          --
          FOR i in 3..4 LOOP
            l_con_mon_fd := l_con_mon_fd + p_swmf_col_bal_def_table(i).balance_value + p_swmf_col_bal_def_table(i).balance_value2;
          END LOOP;
          --l_emp_total := l_emp_total + l_con_mon_fd;
          --
       END LOOP;
       IF l_sip_sector IS NOT NULL OR l_risk_grp IS NOT NULL THEN
           pay_action_information_api.create_action_information
              (
                p_action_information_id        =>  l_action_info_id
              , p_action_context_id            =>  p_actid
              , p_action_context_type          =>  'PA'
              , p_object_version_number        =>  l_ovn
              , p_assignment_id                =>  NULL
              , p_effective_date               =>  l_end_date
              , p_source_id                    =>  NULL
              , p_source_text                  =>  NULL
               ,p_tax_unit_id                  =>  l_tax_unit_id
              , p_action_information_category  =>  'NL_WR_SWMF_SECTOR_RISK_GROUP'
              , p_action_information1          =>  'SWMF'
              , p_action_information2          =>  NULL
              , p_action_information5          =>  l_period_dates_rec.start_date
              , p_action_information6          =>  l_period_dates_rec.End_date
              , p_action_information7          =>  substr(l_sip_sector,1,3)
              , p_action_information8          =>  substr(l_risk_grp,1,2)
              , p_action_information9          =>  fnd_number.number_to_canonical(ROUND(l_c_base_mon_fd))
              , p_action_information10         =>  fnd_number.number_to_canonical(ROUND(l_con_mon_fd)));
              --l_sip_sector := l_get_sect_risk_grp.sector;
              --l_risk_grp := l_get_sect_risk_grp.risk_group;
              l_emp_total := l_emp_total + l_con_mon_fd;
              l_sector_flag := 'Y';
              IF l_c_base_mon_fd = 0 THEN
                l_c_base_mon_fd_z := 'Y';
              END IF;
          END IF;
       --
    END IF;
    l_awf := 'N';
    FOR  i IN collXMLTable.FIRST..collXMLTable.LAST LOOP
      l_val := NULL;
      IF collXMLTable(i).Mandatory = 'Y' or collXMLTable(i).TagValue <> 0 THEN
       --##--Fnd_file.put_line(FND_FILE.LOG,'#########'||'CORRECTION '||collXMLTable(i).TagName||' '||collXMLTable(i).TagValue||' '||collXMLTable(i).Mandatory);
       IF collXMLTable(i).TagName = 'TotTeBet' THEN
         l_val := l_emp_total;
       END IF;
       pay_action_information_api.create_action_information
       (
         p_action_information_id        =>  l_action_info_id
       , p_action_context_id            =>  p_actid
       , p_action_context_type          =>  'PA'
       , p_object_version_number        =>  l_ovn
       , p_tax_unit_id                  =>  l_tax_unit_id
       , p_assignment_id                =>  NULL
       , p_effective_date               =>  l_end_date
       , p_source_id                    =>  NULL
       , p_source_text                  =>  NULL
       , p_action_information_category  =>  'NL_WR_COLLECTIVE_REPORT'
       , p_action_information1          =>  'CORRECTION'
       , p_action_information2          =>  collXMLTable(i).TagName
       , p_action_information3          =>  l_period_dates_rec.start_date
       , p_action_information4          =>  l_period_dates_rec.End_date
       , p_action_information5          =>  collXMLTable(i).TagDesc
       , p_action_information6          =>  fnd_number.number_to_canonical(ROUND(NVL(l_val,collXMLTable(i).TagValue))));
       IF collXMLTable(i).TagName = 'PrLnAWF' AND collXMLTable(i).TagValue <> 0 THEN
         l_awf := 'Y';
       END IF;
     END IF;
    END LOOP;
    --
    IF  g_public_org_flag = 'N' THEN
       IF l_sector_flag = 'N' THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_SECTOR')
          , p_action_information5          =>  l_period_dates_rec.End_date
          , p_action_information6          =>  'Mandatory check on Sector'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
          --
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_RISK_GROUP')
          , p_action_information5          =>  l_period_dates_rec.End_date
          , p_action_information6          =>  'No Risk Group'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
       END IF;
       --
       IF l_awf <> 'N' AND l_c_base_mon_fd_z = 'Y' THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_ZERO_BASE_WEWE') -- Message Code should have been '%_WEWA'
          , p_action_information5          =>  l_period_dates_rec.End_date
          , p_action_information6          =>  'Waiting Money Fund contribution base is zero'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
       END IF;
       --
       IF l_awf = 'N' AND l_c_base_mon_fd_z <> 'Y' THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_ZERO_AWF')
          , p_action_information5          =>  l_period_dates_rec.End_date
          , p_action_information6          =>  'AWF contribution base is zero'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
       END IF;
       --
    END IF;
    --#
  END IF;
 END LOOP;
 --
END IF;
--
l_sector := NULL;
l_risk_group := NULL;
IF l_payroll_type = 'FOUR_WEEK' THEN
    --
    l_first_emp  := 'Y' ;
    --
    FOR csr_get_pactid_rec IN csr_get_pactid LOOP
        IF l_first_emp = 'Y' THEN
        --
            l_first_emp := 'N' ;
            --
            OPEN csr_employer_info('NL_WR_EMPLOYER_INFO',csr_get_pactid_rec.payroll_action_id);
            FETCH csr_employer_info INTO csr_employer_info_rec;
            --
              pay_action_information_api.create_action_information
              (
                p_action_information_id        =>  l_action_info_id
              , p_action_context_id            =>  p_actid
              , p_action_context_type          =>  'PA'
              , p_object_version_number        =>  l_ovn
              , p_assignment_id                =>  NULL
              , p_effective_date               =>  l_end_date
              , p_source_id                    =>  NULL
              , p_source_text                  =>  NULL
              , p_tax_unit_id                  =>  l_tax_unit_id
              , p_action_information_category  =>  'NL_WR_EMPLOYER_INFO'
              , p_action_information1          =>  csr_employer_info_rec.action_information1
              , p_action_information2          =>  csr_employer_info_rec.action_information2
              , p_action_information3          =>  fnd_date.date_to_canonical(sysdate)
              , p_action_information4          =>  csr_employer_info_rec.action_information4
              , p_action_information5          =>  substr(l_seq_no,1,6)
              , p_action_information6          =>  csr_employer_info_rec.action_information6
              , p_action_information7          =>  csr_employer_info_rec.action_information7
              , p_action_information8          =>  csr_employer_info_rec.action_information8
              , p_action_information9	       =>  csr_employer_info_rec.action_information9
              , p_action_information10         =>  fnd_date.date_to_canonical(l_start_date)
              , p_action_information11         =>  fnd_date.date_to_canonical(l_end_date)
              , p_action_information12	       =>  csr_employer_info_rec.action_information12);
            --
            CLOSE csr_employer_info;
            --
            FOR csr_exception_info_rec IN csr_employer_info('NL_WR_EXCEPTION_REPORT',csr_get_pactid_rec.payroll_action_id) LOOP
              pay_action_information_api.create_action_information
              (
                p_action_information_id        =>  l_action_info_id
              , p_action_context_id            =>  p_actid
              , p_action_context_type          =>  'PA'
              , p_object_version_number        =>  l_ovn
              , p_assignment_id                =>  NULL
              , p_effective_date               =>  l_end_date
              , p_source_id                    =>  NULL
              , p_source_text                  =>  NULL
              , p_tax_unit_id                  =>  l_tax_unit_id
              , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
              , p_action_information4          =>  csr_exception_info_rec.action_information4
              , p_action_information5          =>  csr_exception_info_rec.action_information5
              , p_action_information6          =>  csr_exception_info_rec.action_information6
              , p_action_information7          =>  csr_exception_info_rec.action_information7
              , p_action_information8          =>  csr_exception_info_rec.action_information8);
            END LOOP;
            --
              y:= 1;
              collXMLTable(y).TagName := 'TotLnLbPh';
              collXMLTable(y).Mandatory:= 'Y';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotLnLbPh'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'TotLnSV';
              collXMLTable(y).Mandatory:= 'Y';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotLnSV'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'PrLnWAOAof';
              collXMLTable(y).Mandatory:= 'Y';
              IF l_end_date >= to_date('01012007','DDMMYYYY') THEN
                collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAof'));
              ELSE
                collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAof_2006'));
              END IF;
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'PrLnWAOAok';
              collXMLTable(y).Mandatory:= 'Y';
              IF l_end_date >= to_date('01012007','DDMMYYYY') THEN
                collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAok'));
              ELSE
                collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnWAOAok_2006'));
              END IF;
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'PrLnAWF';
              collXMLTable(y).Mandatory:= 'Y';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnAWF'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'PrLnUFO';
              collXMLTable(y).Mandatory:= 'Y';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrLnUFO'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'TotVergZvw';
              collXMLTable(y).Mandatory:= 'Y';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotVergZvw'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'IngLbPh';
              collXMLTable(y).Mandatory:= 'Y';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('IngLbPh'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'EHPubUitk';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHPubUitk'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'EHLnBestKar';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHLnBestKar'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'EHSpLn';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHSpLn'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'EHSpPr';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHSpPr'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'EHLnNat';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHLnNat'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'EHFeest';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHFeest'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'EHBmVerg';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHBmVerg'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1; -- new added
              collXMLTable(y).TagName := 'EHGebrAuto';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHGebrAuto'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'EHVUT';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('EHVUT'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'AVBetOV';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVBetOV'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'AVLgdWerkl';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVLgdWerkl'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'AVArboNP';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVArboNP'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'AVZeev';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVZeev'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'AVOnd';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AVOnd'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'VrlAVSO';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('VrlAVSO'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'PrWAOAof';
              collXMLTable(y).Mandatory:= 'N';
              IF l_end_date >= to_date('01012007','DDMMYYYY') THEN
                collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAof'));
              ELSE
                collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAof_2006'));
              END IF;
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'PrWAOAok';
              collXMLTable(y).Mandatory:= 'Y';
              IF l_end_date >= to_date('01012007','DDMMYYYY') THEN
                collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAok'));
              ELSE
                collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrWAOAok_2006'));
              END IF;
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'PrAWF';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrAWF'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'PrUFO';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('PrUFO'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'IngBijdrZvw';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('IngBijdrZvw'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'AGHKort';
              collXMLTable(y).Mandatory:= 'N';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('AGHKort'));
              collXMLTable(y).Tagvalue := 0;
              --
              y:= y+1;
              collXMLTable(y).TagName := 'TotTeBet';
              collXMLTable(y).Mandatory:= 'Y';
              collXMLTable(y).TagDesc := HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotTeBet'));
              collXMLTable(y).Tagvalue := 0;
              --
        END IF;
        --
        FOR csr_collective_info_rec IN csr_employer_info('NL_WR_COLLECTIVE_REPORT',csr_get_pactid_rec.payroll_action_id) LOOP
            --
            IF csr_collective_info_rec.action_information1 = 'COMPLETE' THEN
                --
                IF csr_collective_info_rec.action_information2 = 'TotLnLbPh' THEN
                    collXMLTable(1).Tagvalue:= NVL(collXMLTable(1).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'TotLnSV' THEN
                    collXMLTable(2).Tagvalue:= NVL(collXMLTable(2).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'PrLnWAOAof' THEN
                    collXMLTable(3).Tagvalue:= NVL(collXMLTable(3).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'PrLnWAOAok' THEN
                    collXMLTable(4).Tagvalue:= NVL(collXMLTable(4).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'PrLnAWF' THEN
                    collXMLTable(5).Tagvalue:= NVL(collXMLTable(5).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'PrLnUFO' THEN
                    collXMLTable(6).Tagvalue:= NVL(collXMLTable(6).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'TotVergZvw' THEN
                    collXMLTable(7).Tagvalue:= NVL(collXMLTable(7).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'IngLbPh' THEN
                    collXMLTable(8).Tagvalue:= NVL(collXMLTable(8).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHPubUitk' THEN
                    collXMLTable(9).Tagvalue:= NVL(collXMLTable(9).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHLnBestKar' THEN
                    collXMLTable(10).Tagvalue:= NVL(collXMLTable(10).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHSpLn' THEN
                    collXMLTable(11).Tagvalue:= NVL(collXMLTable(11).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHSpPr' THEN
                    collXMLTable(12).Tagvalue:= NVL(collXMLTable(12).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHLnNat' THEN
                    collXMLTable(13).Tagvalue:= NVL(collXMLTable(13).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHFeest' THEN
                    collXMLTable(14).Tagvalue:= NVL(collXMLTable(14).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHBmVerg' THEN
                    collXMLTable(15).Tagvalue:= NVL(collXMLTable(15).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHGebrAuto' AND l_end_date >= TO_DATE('01012007','DDMMYYYY') THEN -- EHGebrAuto
                    collXMLTable(16).Tagvalue:= NVL(collXMLTable(16).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'EHVUT' THEN
                    collXMLTable(17).Tagvalue:= NVL(collXMLTable(17).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'AVBetOV' AND l_end_date < TO_DATE('01012007','DDMMYYYY') THEN
                    collXMLTable(18).Tagvalue:= NVL(collXMLTable(18).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'AVLgdWerkl' AND l_end_date < TO_DATE('01012007','DDMMYYYY') THEN
                    collXMLTable(19).Tagvalue:= NVL(collXMLTable(19).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'AVArboNP' THEN
                    collXMLTable(20).Tagvalue:= NVL(collXMLTable(20).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'AVZeev' THEN
                    collXMLTable(21).Tagvalue:= NVL(collXMLTable(21).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'AVOnd' THEN
                    collXMLTable(22).Tagvalue:= NVL(collXMLTable(22).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'VrlAVSO' THEN
                    collXMLTable(23).Tagvalue:= NVL(collXMLTable(23).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'PrWAOAof' THEN
                    collXMLTable(24).Tagvalue:= NVL(collXMLTable(24).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'PrWAOAok' THEN
                    collXMLTable(25).Tagvalue:= NVL(collXMLTable(25).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'PrAWF' THEN
                    collXMLTable(26).Tagvalue:= NVL(collXMLTable(26).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'PrUFO' THEN
                    collXMLTable(27).Tagvalue:= NVL(collXMLTable(27).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'IngBijdrZvw' THEN
                    collXMLTable(28).Tagvalue:= NVL(collXMLTable(28).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'AGHKort' THEN
                    collXMLTable(29).Tagvalue:= NVL(collXMLTable(29).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                ELSIF csr_collective_info_rec.action_information2 = 'TotTeBet' THEN
                    collXMLTable(30).Tagvalue:= NVL(collXMLTable(30).Tagvalue,0)
                                                + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
                END IF;
                --
            ELSIF csr_collective_info_rec.action_information1 = 'TOTAL' THEN
                l_emp_total := NVL(l_emp_total,0)
                             + fnd_number.canonical_to_number(csr_collective_info_rec.action_information6);
            END IF;
            --
        END LOOP;
        --
    --
    END LOOP;
    --
    FOR csr_swmf_info_rec IN csr_swmf_employer_info(l_tax_unit_id,l_start_date,l_end_date) LOOP --(csr_get_pactid_rec.payroll_action_id) LOOP
        --
          l_sector        := csr_swmf_info_rec.action_information7;
          l_risk_group    := csr_swmf_info_rec.action_information8;
          l_c_base_mon_fd := csr_swmf_info_rec.action_information9;
          l_con_mon_fd    := csr_swmf_info_rec.action_information10;
          --
          pay_action_information_api.create_action_information
          (p_action_information_id        =>  l_action_info_id
          ,p_action_context_id            =>  p_actid
          ,p_action_context_type          =>  'PA'
          ,p_object_version_number        =>  l_ovn
          ,p_assignment_id                =>  NULL
          ,p_effective_date               =>  l_end_date
          ,p_source_id                    =>  NULL
          ,p_source_text                  =>  NULL
          ,p_tax_unit_id                  =>  l_tax_unit_id
          ,p_action_information_category  =>  'NL_WR_SWMF_SECTOR_RISK_GROUP'
          ,p_action_information1          =>  'SWMF'
          ,p_action_information2          =>  NULL
          ,p_action_information5          =>  fnd_date.date_to_canonical(l_start_date)
          ,p_action_information6          =>  fnd_date.date_to_canonical(l_end_date)
          ,p_action_information7          =>  l_sector
          ,p_action_information8          =>  l_risk_group
          ,p_action_information9          =>  fnd_number.number_to_canonical(ROUND(l_c_base_mon_fd))
          ,p_action_information10         =>  fnd_number.number_to_canonical(ROUND(l_con_mon_fd )));
    END LOOP;
    --
    FOR  i IN collXMLTable.FIRST..collXMLTable.LAST LOOP
     IF collXMLTable(i).Mandatory = 'Y' or collXMLTable(i).TagValue <> 0 THEN
       pay_action_information_api.create_action_information
       ( p_action_information_id        =>  l_action_info_id
       , p_action_context_id            =>  p_actid
       , p_action_context_type          =>  'PA'
       , p_object_version_number        =>  l_ovn
       , p_tax_unit_id                  =>  l_tax_unit_id
       , p_assignment_id                =>  NULL
       , p_effective_date               =>  l_end_date
       , p_source_id                    =>  NULL
       , p_source_text                  =>  NULL
       , p_action_information_category  =>  'NL_WR_COLLECTIVE_REPORT'
       , p_action_information1          =>  'COMPLETE'
       , p_action_information2          =>  collXMLTable(i).TagName
       , p_action_information3          =>  fnd_date.date_to_canonical(l_start_date)
       , p_action_information4          =>  fnd_date.date_to_canonical(l_end_date)
       , p_action_information5          =>  collXMLTable(i).TagDesc
       , p_action_information6          =>  fnd_number.number_to_canonical(ROUND(collXMLTable(i).TagValue)));
      END IF;
    END LOOP;
    --
    pay_action_information_api.create_action_information
    (p_action_information_id        =>  l_action_info_id
    ,p_action_context_id            =>  p_actid
    ,p_action_context_type          =>  'PA'
    ,p_object_version_number        =>  l_ovn
    ,p_tax_unit_id                  =>  l_tax_unit_id
    ,p_assignment_id                =>  NULL
    ,p_effective_date               =>  l_end_date
    ,p_source_id                    =>  NULL
    ,p_source_text                  =>  NULL
    ,p_action_information_category  =>  'NL_WR_COLLECTIVE_REPORT'
    ,p_action_information1          =>  'TOTAL'
    ,p_action_information2          =>  'TotGen' -- TAG NAME
    ,p_action_information3          =>  fnd_date.date_to_canonical(l_start_date)
    ,p_action_information4          =>  fnd_date.date_to_canonical(l_end_date)
    ,p_action_information5          =>  HR_GENERAL.decode_lookup('NL_FORM_LABELS',UPPER('TotGen')) -- TAG DESCRIPTION
    ,p_action_information6          =>  fnd_number.number_to_canonical(ROUND(l_emp_total)));
    --
END IF;
--abraghun--7668628--Validation Procedure
--# Validation Procedure - Check and Raise Exceptions--
  OPEN  csr_nominative_sum(p_actid);
    FETCH csr_nominative_sum INTO
      l_NR_LnLbPh,
      l_NR_LnSV,
      l_NR_IngLbPh,
      l_NR_PrWAOAof,
      l_NR_PrWAOAok,
      l_NR_PrAWF,
      l_NR_PrWgf,
      l_NR_PrUFO,
      l_NR_BijdrZvw,
      l_NR_VergZvw;
    CLOSE csr_nominative_sum;


  OPEN  csr_swmf_sum(p_actid);
    FETCH csr_swmf_sum INTO
     -- l_SWMF_Sect_Count,
     -- l_SWMF_RisGrp_Count,
     -- l_SWMF_PrWgf,
      l_SWMF_PrLnWgf;
    CLOSE csr_swmf_sum;

/*
16 Dec 2008
The validation for the BSN SOFI number duplication will not be done due to
performance reasons. As the person form itself throws a Warning anyway in
case of duplicate SOFI number.

Hence Check0036, Check0037, Check1036, Check1037 are not performed

  --abraghun--7668628-- AAP level Validations --

  FOR er_mismatch IN csr_er_mismatch(p_actid,'INITIAL') LOOP
  --abraghun--7668628--Check0036
    IF(er_mismatch.NumIVSofi>1) THEN
      pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  er_mismatch.ER_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  er_mismatch.ER_assignment_id
          , p_effective_date               =>  er_mismatch.ER_eff_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  er_mismatch.ER_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  'Check0036 failed: Sofi('||er_mismatch.Sofi||') and NumIV('||er_mismatch.NumIV||') combination is not unique'
          , p_action_information5          =>  fnd_date.date_to_canonical(er_mismatch.ER_eff_date)
          , p_action_information6          =>  'Check0036 failed'
          , p_action_information7          =>  er_mismatch.ER_name
          , p_action_information8          =>  er_mismatch.ER_assignment_number);
      END IF;
  --abraghun--7668628--Check0037
    IF(er_mismatch.NumIVPersNr>1) THEN
      pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  er_mismatch.ER_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  er_mismatch.ER_assignment_id
          , p_effective_date               =>  er_mismatch.ER_eff_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  er_mismatch.ER_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  'Check0037 failed: PersNr('||er_mismatch.PersNr||') and NumIV('||er_mismatch.NumIV||') combination is not unique'
          , p_action_information5          =>  fnd_date.date_to_canonical(er_mismatch.ER_eff_date)
          , p_action_information6          =>  'Check0037 failed'
          , p_action_information7          =>  er_mismatch.ER_name
          , p_action_information8          =>  er_mismatch.ER_assignment_number);
    END IF;
   END LOOP;

   FOR er_mismatch IN csr_er_mismatch(p_actid,'WITHDRAWAL') LOOP
  --abraghun--7668628--Check1036
    IF(er_mismatch.NumIVSofi>1) THEN
      pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  er_mismatch.ER_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  er_mismatch.ER_assignment_id
          , p_effective_date               =>  er_mismatch.ER_eff_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  er_mismatch.ER_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  'Check1036 failed: In Withdrawal, Sofi('||er_mismatch.Sofi||') and NumIV('||er_mismatch.NumIV||') combination is not unique'
          , p_action_information5          =>  fnd_date.date_to_canonical(er_mismatch.ER_eff_date)
          , p_action_information6          =>  'Check1036 failed'
          , p_action_information7          =>  er_mismatch.ER_name
          , p_action_information8          =>  er_mismatch.ER_assignment_number);
      END IF;
  --abraghun--7668628--Check1037
    IF(er_mismatch.NumIVPersNr>1) THEN
      pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  er_mismatch.ER_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  er_mismatch.ER_assignment_id
          , p_effective_date               =>  er_mismatch.ER_eff_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  er_mismatch.ER_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  'Check1037 failed: In Withdrawal, PersNr('||er_mismatch.PersNr||') and NumIV('||er_mismatch.NumIV||') combination is not unique'
          , p_action_information5          =>  fnd_date.date_to_canonical(er_mismatch.ER_eff_date)
          , p_action_information6          =>  'Check1037 failed'
          , p_action_information7          =>  er_mismatch.ER_name
          , p_action_information8          =>  er_mismatch.ER_assignment_number);
    END IF;
   END LOOP;
*/
  --abraghun--7668628-- PA Level Validations--

  --abraghun--7668628--Check0001
      IF l_CR_TotLnLbPh <> l_NR_LnLbPh THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','TotLnLbPh');
         fnd_message.set_token('TAGVAL1',l_CR_TotLnLbPh);
         fnd_message.set_token('TAG2','LnLbPh');
         fnd_message.set_token('TAGVAL2',l_NR_LnLbPh);

          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0001 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0001 - '||'Tag TotLnLbPh, (Total wage for taxes). The total amount of wages should be the same as the sum of the individual amounts of wage for taxes.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0002
      IF l_CR_TotLnSV <> l_NR_LnSV THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','TotLnSV');
         fnd_message.set_token('TAGVAL1',l_CR_TotLnSV);
         fnd_message.set_token('TAG2','LnSV');
         fnd_message.set_token('TAGVAL2',l_NR_LnSV);

          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0002 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0002 - '||'Tag TotLnSV, (Total SI wage). The total amount of SI wages should be the same as the sum of the individual amounts of SI wages.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0003
      IF l_CR_IngLbPh <> l_NR_IngLbPh THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','IngLbPh');
         fnd_message.set_token('TAGVAL1',l_CR_IngLbPh);
         fnd_message.set_token('TAG2','IngLbPh');
         fnd_message.set_token('TAGVAL2',l_NR_IngLbPh);
         pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0003 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0003 - '||'Tag IngLbPh, (Deducted Tax). The total amount of deducted tax should be the same as the sum of the individual amounts of deducted Tax.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
--abraghun--7668628--Check0006
      IF l_CR_PrAWF <> l_NR_PrAWF THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','PrAWF');
         fnd_message.set_token('TAGVAL1',l_CR_PrAWF);
         fnd_message.set_token('TAG2','PrAWF');
         fnd_message.set_token('TAGVAL2',l_NR_PrAWF);
         pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0006 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0006 - '||'Tag PrAWF, (Total Contribution WeWe (EE+ER)). The total amount of contribution should be the same as the sum of the individual amounts of WeWe contribution employer + employee.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0008
      IF l_CR_PrUFO <> l_NR_PrUFO THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','PrUFO');
         fnd_message.set_token('TAGVAL1',l_CR_PrUFO);
         fnd_message.set_token('TAG2','PrUFO');
         fnd_message.set_token('TAGVAL2',l_NR_PrUFO);
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0008 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0008 - '||'Tag PrUFO, (Contribution UFO). The total amount of contribution should be the same as the sum of the individual amounts of contribution UFO.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0009
      IF l_CR_TotVergZvw <> l_NR_VergZvw THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','TotVergZvw');
         fnd_message.set_token('TAGVAL1',l_CR_TotVergZvw);
         fnd_message.set_token('TAG2','VergZvw');
         fnd_message.set_token('TAGVAL2',l_NR_VergZvw);
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0009 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0009 - '||'Tag TotVergZvw, (Total amount Zvw allowance). The total amount of Zvw allowance should be the same as the sum of the individual amounts of Zvw allowance.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
          --
/*
  --abraghun--7668628--Check0010
      IF l_CR_TotTeBet <> l_CR_TotTeBet_Sum THEN

         fnd_message.set_name('PER','HR_373541_NL_TOTTEBET_CHECK');
          fnd_message.set_token('TAGVAL1',l_CR_TotTeBet);
          fnd_message.set_token('TAGVAL2',l_CR_TotTeBet_Sum);
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0010 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0010 - '||'Tag TotTeBet, (Total amount to be paid payroll period). The total amount should be the correct sum of the individual total amounts.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
*/
/*
  --abraghun--7668628--Check0011
      IF l_CR_TotGen <>fnd_number.number_to_canonical(
                       fnd_number.canonical_to_number(l_CR_TotTeBet)+
                       fnd_number.canonical_to_number(l_CR_Saldo_Sum)) THEN

          fnd_message.set_name('PER','HR_373542_NL_TOTGEN_CHECK');
          fnd_message.set_token('TAGVAL1',l_CR_TotGen);
          fnd_message.set_token('TAGVAL2',l_CR_TotTeBet);
          fnd_message.set_token('TAGVAL3',l_CR_Saldo_Sum);

           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0011 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0011 - '||'Tag TotGen, (General Total). The total amount should be the correct sum of the total amounts of the normal period and the correction periods.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  */
  --
  --abraghun--7668628--Check0012
      IF l_CR_IngBijdrZvw <> l_NR_BijdrZvw THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','IngBijdrZvw');
         fnd_message.set_token('TAGVAL1',l_CR_IngBijdrZvw);
         fnd_message.set_token('TAG2','BijdrZvw');
         fnd_message.set_token('TAGVAL2',l_NR_BijdrZvw);
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0012 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0012 - '||'Tag IngBijdrZvw, (Total of deducted contribution Zvw). The total amount of contribution Zvw should be the same as the sum of the individual amounts of contribution Zvw.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0016
      IF l_CR_PrWAOAof <> l_NR_PrWAOAof THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','PrWAOAof');
         fnd_message.set_token('TAGVAL1',l_CR_PrWAOAof);
         fnd_message.set_token('TAG2','PrWAOAof');
         fnd_message.set_token('TAGVAL2',l_NR_PrWAOAof);
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0016 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0016 - '||'Tag PrWAOAof, (Total contribution WAO/WGA/IVA). The total amount of contributions should be the same as the sum of the individual amounts of contribution WAO/WGA/IVA.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0021
      IF l_CR_PrWAOAok <> l_NR_PrWAOAok THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','PrWAOAok');
         fnd_message.set_token('TAGVAL1',l_CR_PrWAOAok);
         fnd_message.set_token('TAG2','PrWAOAok');
         fnd_message.set_token('TAGVAL2',l_NR_PrWAOAok);
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0021 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0021 - '||'Tag PrWAOAok, (Total contribution general WAO/WGA Differentiated). The total amount of contributions should be the same as the sum of the individual amounts of WAO/WGA Differentiated.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0018
      IF l_CR_PrWgf <> l_NR_PrWgf THEN
         fnd_message.set_name('PER','HR_373533_NL_TOTAL_EQUAL');
         fnd_message.set_token('TAG1','PrWgf');
         fnd_message.set_token('TAGVAL1',l_CR_PrWgf);
         fnd_message.set_token('TAG2','PrWgf');
         fnd_message.set_token('TAGVAL2',l_NR_PrWgf);
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0018 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0018 - '||'Tag PrWgf, (Total contribution waiting money fund). The total amount of contribution should be the same as the sum of the individual amounts of contribution waiting money fund.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
   --
  --abraghun--7668628--Check0022
     FOR overlap IN csr_period_overlap(p_actid) LOOP
         fnd_message.set_name('PER','HR_373540_NL_PERIOD_OVERLAP');
         fnd_message.set_token('TAGVAL1',overlap.start_date);
         fnd_message.set_token('TAGVAL2',overlap.end_date);
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0022 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0022 - '||'The start and end dates of the correction period cannot be the same as the start and end dates of the normal period.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
       END LOOP;
  --
    --abraghun--7668628--Check0025
      IF l_CR_PrLnWAOAof > l_CR_PrLnWAOAok THEN
         fnd_message.set_name('PER','HR_373536_NL_TOTAL_LTEQ');
         fnd_message.set_token('TAG1','PrLnWAOAof');
         fnd_message.set_token('TAGVAL1',l_CR_PrLnWAOAof);
         fnd_message.set_token('TAG2','PrLnWAOAok');
         fnd_message.set_token('TAGVAL2',l_CR_PrLnWAOAok);
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0025 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0025 - '||'The total amount of "Contribution base WAO/IVA/WGA" (Tag PrLnWAOAof) has to be equal to or less than the total amount of "Contribution base general WAO/WGA Differentiated" (Tag PrLnWAOAok).'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --

    --abraghun--7668628--Check0029
      IF l_CR_PrLnAWF > l_SWMF_PrLnWgf THEN
         fnd_message.set_name('PER','HR_373536_NL_TOTAL_LTEQ');
         fnd_message.set_token('TAG1','PrLnAWF');
         fnd_message.set_token('TAGVAL1',l_CR_PrLnAWF );
         fnd_message.set_token('TAG2','PrLnWgf');
         fnd_message.set_token('TAGVAL2',l_SWMF_PrLnWgf);
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0029 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0029 - '||'The total amount of "Contribution base WeWe (AWF)" (Tag PrLnAWF) has to be equal to or less than the sum of the total amounts of "Contribution base Waiting money fund" (Tag PrLnWgf).'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --

   --abraghun--7668628--Check0026
      IF l_CR_PrWAOAof> 0 AND  l_CR_PrLnWAOAof= 0 THEN
         fnd_message.set_name('PER','HR_373534_NL_TOTAL_GT_ZERO');
         fnd_message.set_token('TAG1','PrWAOAof');
         fnd_message.set_token('TAGVAL1',l_CR_PrWAOAof);
         fnd_message.set_token('TAG2','PrLnWAOAof');

         pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0026 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0026 - '||'When the amount of "Total contribution WAO/WGA/IVA" (Tag PrWAOAof) is greater than zero, the amount of "Contribution base WAO/IVA/WGA" (Tag PrLnWAOAof) cannot be equal to zero.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0028
      IF l_CR_PrWAOAok > 0 AND l_CR_PrLnWAOAok = 0 THEN
         fnd_message.set_name('PER','HR_373534_NL_TOTAL_GT_ZERO');
         fnd_message.set_token('TAG1','PrWAOAok');
         fnd_message.set_token('TAGVAL1',l_CR_PrWAOAok);
         fnd_message.set_token('TAG2','PrLnWAOAok');
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0028 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0028 - '||'When the amount of "Total contribution general WAO/WGA Differentiated" (Tag PrWAOAok) is greater than zero,'||
                                               ' the amount of "Contribution base general WAO/WGA Differentiated" (Tag PrLnWAOAok) cannot be equal to zero.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0030
      IF l_CR_PrAWF > 0 AND l_CR_PrLnAWF = 0 THEN
         fnd_message.set_name('PER','HR_373534_NL_TOTAL_GT_ZERO');
         fnd_message.set_token('TAG1','PrAWF');
         fnd_message.set_token('TAGVAL1',l_CR_PrAWF);
         fnd_message.set_token('TAG2','PrLnAWF');
           pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0030 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0030 - '||'When the amount of "Total Contribution WeWe (AWF)" (Tag PrAWF) is greater than zero, the amount of "Contribution base WeWe (AWF)" (Tag PrLnAWF) cannot be equal to zero.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0031
      IF l_CR_PrUFO > 0 AND l_CR_PrLnUFO = 0 THEN
         fnd_message.set_name('PER','HR_373534_NL_TOTAL_GT_ZERO');
         fnd_message.set_token('TAG1','PrUFO');
         fnd_message.set_token('TAGVAL1',l_CR_PrUFO);
         fnd_message.set_token('TAG2','PrLnUFO');
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0031 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0031 - '||'When the amount of "Total contribution UFO" (Tag PrUFO) is greater than zero, the amount of "Contribution base UFO" (Tag PrLnUFO) cannot be equal to zero.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --
  --abraghun--7668628--Check0035
      IF l_CR_PrWgf >0 AND l_SWMF_PrLnWgf=0 THEN
         fnd_message.set_name('PER','HR_373534_NL_TOTAL_GT_ZERO');
         fnd_message.set_token('TAG1','PrWgf');
         fnd_message.set_token('TAGVAL1',l_CR_PrWgf);
         fnd_message.set_token('TAG2','PrLnWgf');
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_actid
          , p_action_context_type          =>  'PA'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  NULL
          , p_effective_date               =>  l_end_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0035 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(l_end_date)
          , p_action_information6          =>  '0035 - '||'When the amount of "Total contribution waiting money fund" (Tag PrWgf) is greater than zero, the amount of "Contribution base Waiting money fund" (Tag PrLnWgf) cannot be equal to zero.'
          , p_action_information7          =>  substr(l_tax_details.tax_rep_name,1,200)
          , p_action_information8          =>  substr(l_tax_details.tax_reg_num,1,12));
        END IF;
  --

--abraghun--7668628-- Validation Procedure - Check and Raise Exceptions Ends--

--# Exception Report
    FND_FILE.PUT_LINE(fnd_file.output,rpad('-',80,'-') || rpad(hr_general.decode_lookup('NL_FORM_LABELS','WR_EXCEPTION_REPORT'),20,' ') || rpad('-',80,'-'));
    FND_FILE.PUT_LINE(fnd_file.output,rpad(' ',180,' '));
    --
    FOR csr_excpetion_rec IN csr_get_PA_exception_info(p_actid) LOOP
        --
        l_exception_flag := 'Y' ;
        --
        IF  empr_flag = 'N' THEN
            --
            FND_FILE.PUT_LINE(fnd_file.output,rpad('-',180,'-'));
            FND_FILE.PUT_LINE(fnd_file.output,rpad(hr_general.decode_lookup('NL_FORM_LABELS','WR_EMPLOYER_NAME'),32,' ') ||
                                              rpad(hr_general.decode_lookup('NL_FORM_LABELS','WR_EXCEPTION'),148,' '));
            FND_FILE.PUT_LINE(fnd_file.output,rpad('-',180,'-'));
            empr_flag :='Y';
        END IF;
        --
        FND_FILE.PUT_LINE(fnd_file.output,rpad(csr_excpetion_rec.E_Name,32,' ') || csr_excpetion_rec.Message);
        --
    END LOOP;
    --
    FOR csr_excpetion_rec IN csr_get_AAP_exception_info(p_actid) LOOP
        --
        l_exception_flag := 'Y' ;
        --
        IF empe_flag = 'N' THEN
            --
            FND_FILE.PUT_LINE(fnd_file.output,rpad('-',180,'-'));
            FND_FILE.PUT_LINE(fnd_file.output,rpad(hr_general.decode_lookup('NL_FORM_LABELS','WR_ASSIGNMENT_NUMBER'),22,' ') ||
                                              rpad(hr_general.decode_lookup('NL_FORM_LABELS','WR_NAME'),32,' ') ||
                                              rpad(hr_general.decode_lookup('NL_FORM_LABELS','WR_DATE'),13,' ') ||
                                              rpad(hr_general.decode_lookup('NL_FORM_LABELS','WR_EXCEPTION'),113,' '));
            FND_FILE.PUT_LINE(fnd_file.output,rpad('-',180,'-'));
            empe_flag := 'Y';
        END IF;
        --
        FND_FILE.PUT_LINE(fnd_file.output,rpad(substr(csr_excpetion_rec.E_Number,1,20),22,' ') || rpad(csr_excpetion_rec.E_name,32,' ') || rpad(csr_excpetion_rec.dt,13,' ')  || csr_excpetion_rec.Message);
        --
    END LOOP;
    --
    IF l_exception_flag = 'N' THEN
        FND_FILE.PUT_LINE(fnd_file.output , hr_general.decode_lookup('NL_FORM_LABELS','WR_NO_VALIDATION_ERRORS'));
    END IF;
    --Fnd_file.put_line(FND_FILE.LOG,' Leaving Deinit Code');
--#
 EXCEPTION
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
   -- Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
  hr_utility.set_location(sqlerrm(sqlcode),110);
END archive_deinit_code;
--------------------------------------------------------------------------------
-- ACTION_CREATION_CODE
--------------------------------------------------------------------------------
PROCEDURE archive_action_creation (p_actid   IN NUMBER
                                  ,stperson  IN NUMBER
                                  ,endperson IN NUMBER
                                  ,chunk     IN NUMBER) IS
  --
  CURSOR csr_assignments(stperson            NUMBER
                        ,endperson           NUMBER
                        ,c_start_date        DATE
                        ,c_end_date          DATE
                        ,c_business_group_id NUMBER
                        ,c_payroll_type      VARCHAR2
                        ,c_tax_unit_id       NUMBER
                        ,c_paid_flag         VARCHAR2) IS
  SELECT asl.assignment_id assignment_id
        ,paa.assignment_action_id assignment_action_id
  FROM   per_all_assignments_f asl
        ,pay_all_payrolls_f ppf
        ,pay_payroll_actions ppa
        ,pay_assignment_actions paa
        ,per_time_periods  ptp
  WHERE  asl.person_id BETWEEN stperson AND endperson and
         ppf.payroll_id = asl.payroll_id
  AND    ((ppf.period_type = 'Calendar Month'
          AND c_payroll_type = 'MONTH') OR
          (ppf.period_type = 'Week' AND c_payroll_type = 'WEEK')OR
          (ppf.period_type = 'Lunar Month' AND c_payroll_type = 'LMONTH'))
  AND    ppf.payroll_id = ppa.payroll_id
  AND    ppa.action_type in ('R','Q')
  AND    ppa.action_status = 'C'
  AND    paa.source_action_id IS NULL
  AND    paa.tax_unit_id = c_tax_unit_id
  AND    ppa.time_period_id  = ptp.time_period_id
  AND    c_end_date     BETWEEN ptp.start_date
                              AND ptp.end_date
  AND    ppa.payroll_action_id = paa.payroll_action_id
  AND    paa.assignment_id = asl.assignment_id
  AND    asl.effective_start_date <= c_end_date
  AND    asl.effective_end_date   >= c_start_date
  AND    c_end_date       BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date
  AND    asl.business_group_id = ppa.business_group_id
  AND    ppa.business_group_id = c_business_group_id
  AND    (EXISTS (SELECT 1
               FROM   pay_assignment_actions paa1
                     ,pay_run_results prr
               WHERE  paa1.source_action_id = paa.assignment_action_id
               AND    prr.assignment_action_id = paa1.assignment_action_id))
  UNION
  SELECT asl.assignment_id assignment_id
        ,NULL assignment_action_id
  FROM   per_all_assignments_f asl
        ,pay_all_payrolls_f ppf
  WHERE  asl.person_id BETWEEN stperson AND endperson
  AND    c_paid_flag           = 'N'
  AND    ppf.payroll_id        = asl.payroll_id
  AND    asl.assignment_type   = 'E'
  AND    asl.business_group_id = c_business_group_id
  AND    ((ppf.period_type = 'Calendar Month'--,'Lunar Month')
          AND c_payroll_type = 'MONTH') OR
          (ppf.period_type = 'Week' AND c_payroll_type = 'WEEK')OR
          (ppf.period_type = 'Lunar Month' AND c_payroll_type = 'LMONTH'))
  AND    asl.effective_start_date <= c_end_date
  AND    asl.effective_end_date   >= c_start_date
  AND    c_end_date       BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date
  AND    ppf.prl_information_category   = 'NL'
  AND    ((asl.establishment_id = c_tax_unit_id ) OR
          (asl.establishment_id IS NULL AND ppf.PRL_INFORMATION1  = c_tax_unit_id))
  ORDER BY 1;
  --
  CURSOR csr_le_hr_mapping_chk (p_organization_id NUMBER) IS
  SELECT hoi.org_information2 org_id
        ,hoi.org_information4 paid_flag
  FROM   hr_organization_information hoi
  WHERE  hoi.org_information_context  = 'NL_LE_TAX_DETAILS'
  AND    hoi.organization_id          = p_organization_id
  AND    EXISTS (SELECT 1
                 FROM   hr_organization_information hoi1
                 WHERE  hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
                 AND    hoi1.org_information_context = 'CLASS'
                 AND    hoi1.organization_id         = hoi.organization_id);
  --
  CURSOR csr_get_empr_contact(c_employer_id       NUMBER
                             ,c_business_group_id NUMBER) IS
  SELECT hoi.org_information4  paid_flag
  FROM   hr_organization_units hou,hr_organization_information hoi
  WHERE  hoi.org_information_context = 'NL_ORG_WR_INFO'
  AND    hou.business_group_id       = c_business_group_id
  AND    hou.organization_id         = hoi.organization_id
  AND    hou.organization_id         = c_employer_id;
  --
  l_actid                 NUMBER;
  l_legal_employer        hr_all_organization_units.organization_id%type;
  l_start_date            DATE;
  l_end_date              DATE;
  l_business_group_id     NUMBER;
  l_chk_assignment_id     NUMBER;
  l_payroll_type VARCHAR2(10);
  l_seq_no  VARCHAR2(15);
  l_paid_flag             VARCHAR2(15);
  l_hr_tax_unit           hr_all_organization_units.organization_id%TYPE;
  --
    CURSOR csr_persons(stperson            NUMBER
                      ,endperson           NUMBER
                      ,c_start_date        DATE
                      ,c_end_date          DATE
                      ,c_business_group_id NUMBER
                      ,c_payroll_type      VARCHAR2
                      ,c_tax_unit_id       NUMBER) IS
    SELECT MAX(paa.assignment_action_id) assignment_action_id
          ,paa.assignment_id
          ,paaf.person_id
          ,ppa1.effective_date
          ,paaf.primary_flag
    FROM pay_payroll_actions	ppa
        ,pay_payroll_actions	ppa1
        ,pay_assignment_actions paa
        ,per_all_assignments_f	paaf
    WHERE ppa.report_type      = 'NL_WAGES_REP_LOCK'
	AND ppa.report_qualifier   = 'NL'
    AND ppa.action_type	       = 'X'
    AND ppa.action_status 	   = 'C'
	AND ppa1.report_type       = 'NL_WAGES_REP_ARCHIVE'
	AND ppa1.report_qualifier  = 'NL'
    AND ppa1.action_type	   = 'X'
    AND ppa1.action_status 	   = 'C'
    AND INSTR(ppa.legislative_parameters,'REQUEST_ID='||ppa1.payroll_action_id ) <> 0
    AND INSTR(ppa1.legislative_parameters,'Payroll_Type=WEEK') <> 0
    AND ppa1.effective_date BETWEEN c_start_date
                            AND		c_end_date
    AND ppa1.payroll_action_id      = paa.payroll_action_id
    AND paa.assignment_id 	        = paaf.assignment_id
    AND paa.tax_unit_id		        = c_tax_unit_id
    AND paaf.person_id BETWEEN stperson
                       AND     endperson
    AND paaf.effective_start_date <= ppa1.effective_date
    AND paaf.effective_end_date   >= ppa1.start_date
    AND paaf.business_group_id 	   = c_business_group_id
    AND paaf.business_group_id     = ppa.business_group_id
    AND ppa1.business_group_id     = ppa.business_group_id
	GROUP BY paa.assignment_id
            ,paaf.person_id
            ,ppa1.effective_date
            ,paaf.primary_flag
    ORDER BY paaf.person_id
            ,paaf.primary_flag DESC
            ,ppa1.effective_date DESC;
---for yearly report
  CURSOR csr_assignments_yearly(stperson            NUMBER
                        ,endperson           NUMBER
                        ,c_start_date        DATE
                        ,c_end_date          DATE
                        ,c_business_group_id NUMBER
                        ,c_payroll_type      VARCHAR2
                        ,c_tax_unit_id       NUMBER
                        ,c_paid_flag         VARCHAR2) IS
  SELECT DISTINCT asl.assignment_id assignment_id
        ,paa.assignment_action_id assignment_action_id
  FROM   per_all_assignments_f asl
        ,pay_payroll_actions ppa
        ,pay_assignment_actions paa
        ,per_time_periods  ptp
  WHERE  asl.person_id BETWEEN stperson AND endperson and
         ppa.payroll_id = asl.payroll_id
  AND    ppa.action_type in ('R','Q')
  AND    ppa.action_status = 'C'
  AND    paa.source_action_id IS NULL
  AND    paa.tax_unit_id = c_tax_unit_id
  AND    ppa.time_period_id  = ptp.time_period_id
  AND    to_char(ptp.end_date,'RRRR') = to_char(c_start_date,'RRRR')
  AND    ppa.payroll_action_id = paa.payroll_action_id
  AND    paa.assignment_id = asl.assignment_id
  AND    asl.effective_start_date <= c_end_date
  AND    asl.effective_end_date   >= c_start_date
  AND    asl.business_group_id = ppa.business_group_id
  AND    ppa.business_group_id = c_business_group_id
  AND    (EXISTS (SELECT 1
               FROM   pay_assignment_actions paa1
                     ,pay_run_results prr
               WHERE  paa1.source_action_id = paa.assignment_action_id
               AND    prr.assignment_action_id = paa1.assignment_action_id))
UNION
  SELECT asl.assignment_id assignment_id
        ,NULL assignment_action_id
  FROM   per_all_assignments_f asl
        ,pay_all_payrolls_f ppf
  WHERE  asl.person_id BETWEEN stperson AND endperson
  AND    c_paid_flag           = 'N'
  AND    ppf.payroll_id        = asl.payroll_id
  AND    asl.assignment_type   = 'E'
  AND    asl.business_group_id = c_business_group_id
  AND    asl.effective_start_date <= c_end_date
  AND    asl.effective_end_date   >= c_start_date
  AND    ppf.effective_end_date >= c_start_date
  AND    ppf.prl_information_category   = 'NL'
  AND    ((asl.establishment_id = c_tax_unit_id ) OR
          (asl.establishment_id IS NULL AND ppf.PRL_INFORMATION1  = c_tax_unit_id))
          ORDER BY 1,2 desc;
    --
    l_chk_person_id         NUMBER;
  --
BEGIN
    --
    get_all_parameters (p_actid
                       ,l_business_group_id
                       ,l_start_date
                       ,l_end_date
                       ,l_legal_employer
                       ,l_payroll_type
                       ,l_seq_no);
    --
    l_paid_flag := NULL;
    l_hr_tax_unit := NULL;
    --
    OPEN  csr_le_hr_mapping_chk(l_legal_employer);
    FETCH csr_le_hr_mapping_chk INTO l_hr_tax_unit,l_paid_flag;
    CLOSE csr_le_hr_mapping_chk;
    --
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~l_paid_flag :'||l_paid_flag);
    --
    IF l_paid_flag IS NULL THEN
      OPEN  csr_get_empr_contact(NVL(l_hr_tax_unit,l_legal_employer),l_business_group_id);
      FETCH csr_get_empr_contact INTO l_paid_flag;
      CLOSE csr_get_empr_contact;
    END IF;
    --
    l_paid_flag := NVL(l_paid_flag,'N');
    --
    IF l_payroll_type = 'FOUR_WEEK' THEN
        l_chk_person_id := 0;
        FOR csr_persons_rec IN csr_persons(stperson
                                          ,endperson
                                          ,l_start_date
                                          ,l_end_date
                                          ,l_business_group_id
                                          ,l_payroll_type
                                          ,l_legal_employer   )LOOP
            IF csr_persons_rec.person_id <> l_chk_person_id THEN
                --
                l_chk_person_id := csr_persons_rec.person_id;
                --
                SELECT pay_assignment_actions_s.NEXTVAL
                INTO   l_actid
                FROM   dual;
                -- CREATE THE ARCHIVE ASSIGNMENT ACTION
                hr_nonrun_asact.insact(lockingactid => l_actid
                                      ,assignid     => csr_persons_rec.assignment_id
                                      ,pactid       => p_actid
                                      ,chunk        => chunk
                                      ,greid        => l_legal_employer);
                --
            END IF;
            hr_nonrun_asact.insint(l_actid,csr_persons_rec.assignment_action_id);
        END LOOP;
    ELSIF l_payroll_type = 'YEARLY' THEN  ---- for yearly report

      l_chk_assignment_id := 0;
        FOR csr_rec IN csr_assignments_yearly(stperson,endperson,l_start_date,l_end_date,l_business_group_id,l_payroll_type,l_legal_employer,l_paid_flag) LOOP
          IF csr_rec.assignment_id <> l_chk_assignment_id THEN
            l_chk_assignment_id := csr_rec.assignment_id;
            SELECT pay_assignment_actions_s.NEXTVAL
            INTO   l_actid
            FROM   dual;
            --Fnd_file.put_line(FND_FILE.LOG,'#######~~csr_rec.assignment_action_id :'||l_actid||','||csr_rec.assignment_action_id);
            -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
            hr_nonrun_asact.insact(lockingactid => l_actid
                                  ,assignid     => csr_rec.assignment_id
                                  ,pactid       => p_actid
                                  ,chunk        => chunk
                                  ,greid        => l_legal_employer);
            --
          END IF;
          IF csr_rec.assignment_action_id IS NOT NULL THEN
             --Fnd_file.put_line(FND_FILE.LOG,'#######~~hr_nonrun_asact.insint');
            hr_nonrun_asact.insint(l_actid,csr_rec.assignment_action_id);
          END IF;
        END LOOP;
    ELSE
        l_chk_assignment_id := 0;
        --
        FOR csr_rec IN csr_assignments(stperson,endperson,l_start_date,l_end_date,l_business_group_id,l_payroll_type,l_legal_employer,l_paid_flag) LOOP
          IF csr_rec.assignment_id <> l_chk_assignment_id THEN
            l_chk_assignment_id := csr_rec.assignment_id;
            SELECT pay_assignment_actions_s.NEXTVAL
            INTO   l_actid
            FROM   dual;
            -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
            hr_nonrun_asact.insact(lockingactid => l_actid
                                  ,assignid     => csr_rec.assignment_id
                                  ,pactid       => p_actid
                                  ,chunk        => chunk
                                  ,greid        => l_legal_employer);
            --
          END IF;
          IF csr_rec.assignment_action_id IS NOT NULL THEN
            hr_nonrun_asact.insint(l_actid,csr_rec.assignment_action_id);
          END IF;
        END LOOP;
    END IF;
    --
  END archive_action_creation;
--------------------------------------------------------------------------------
-- LOCK_ACTION_CREATION
--------------------------------------------------------------------------------
PROCEDURE lock_action_creation (p_actid   IN NUMBER
                               ,stperson  IN NUMBER
                               ,endperson IN NUMBER
                               ,chunk     IN NUMBER) IS
  --
  CURSOR csr_assignment_actions(p_arc_pactid    NUMBER) IS
  SELECT paa.assignment_action_id
        ,paa.assignment_id
  FROM  pay_assignment_actions paa
       ,per_all_assignments_f  paaf
	   ,pay_payroll_actions	   ppa
  WHERE paa.payroll_action_id = p_arc_pactid
  AND	paa.payroll_action_id = ppa.payroll_action_id
  AND   paaf.person_id BETWEEN stperson
                           AND endperson
  AND   paa.assignment_id     = paaf.assignment_id
  AND   ppa.effective_date BETWEEN paaf.effective_start_date
                               AND paaf.effective_end_date
  ORDER BY paa.assignment_action_id;
  --
  l_actid              NUMBER;
  l_arc_pactid         NUMBER;
  --
BEGIN
    --
    --hr_utility.trace_on(null,'NL_WR');
    --
    l_arc_pactid := TO_NUMBER(get_parameters(p_actid,'REQUEST_ID'));
    --
    FOR csr_rec IN csr_assignment_actions(l_arc_pactid) LOOP
        --
        SELECT pay_assignment_actions_s.NEXTVAL
        INTO   l_actid
        FROM   dual;
        --
        hr_nonrun_asact.insact(lockingactid => l_actid
                              ,assignid     => csr_rec.assignment_id
                              ,pactid       => p_actid
                              ,chunk        => chunk);
        --
        hr_nonrun_asact.insint( lockingactid => l_actid
                               ,lockedactid  => csr_rec.assignment_action_id );
        --
    END LOOP;
    --
END lock_action_creation;
--
--------------------------------------------------------------------------------
-- GET_SCL_DATA
--------------------------------------------------------------------------------
PROCEDURE get_scl_data(p_scl_id            IN NUMBER
                      ,p_effective_date    IN DATE
                      ,p_income_code       IN OUT NOCOPY VARCHAR2
                      ,p_work_pattern      IN OUT NOCOPY VARCHAR2
                      ,p_wage_tax_discount IN OUT NOCOPY VARCHAR2
                      ,p_wage_tax_table    IN OUT NOCOPY VARCHAR2
                      ,p_wage_aow          IN OUT NOCOPY VARCHAR2
                      ,p_wage_wajong       IN OUT NOCOPY VARCHAR2
                      ,p_emp_loan          IN OUT NOCOPY VARCHAR2
                      ,p_transportation    IN OUT NOCOPY VARCHAR2
                      ,p_chk               IN OUT NOCOPY VARCHAR2)
IS
--
CURSOR csr_get_scl_seg(c_scl_id NUMBER) IS
SELECT decode(segment4,'Y','J',segment4)  wage_tax_discount
      ,decode(segment6,'R','J','I','N','S','N')  work_pattern
      ,segment8  income_code
      ,segment11 wage_tax_table
      --,decode(INSTR(NVL(segment10,'00'),'01'),0,(decode(INSTR(segment13,'02'),0,1,3)),2) company_car_use --01/02
      ,decode(INSTR(NVL(segment10,'00'),'71'),0,'N','J') wage_aow
      ,decode(INSTR(NVL(segment10,'00'),'72'),0,'N','J') wage_wajong
      ,decode(INSTR(NVL(segment10,'00'),'43'),0,'N','J') emp_loan
      ,decode(INSTR(NVL(segment10,'00'),'03'),0,'N','J') transportation
FROM   hr_soft_coding_keyflex
WHERE  soft_coding_keyflex_id = c_scl_id;
--
l_wage_tax_discount hr_soft_coding_keyflex.segment13%type;
l_work_pattern      hr_soft_coding_keyflex.segment13%type;
l_income_code       hr_soft_coding_keyflex.segment13%type;
l_wage_tax_table    hr_soft_coding_keyflex.segment13%type;
l_wage_aow          hr_soft_coding_keyflex.segment13%type;
l_wage_wajong       hr_soft_coding_keyflex.segment13%type;
l_emp_loan          hr_soft_coding_keyflex.segment13%type;
l_transportation    hr_soft_coding_keyflex.segment13%type;
--
BEGIN
    --
    OPEN  csr_get_scl_seg(p_scl_id);
    FETCH csr_get_scl_seg INTO l_wage_tax_discount
                              ,l_work_pattern
                              ,l_income_code
                              ,l_wage_tax_table
                            --  ,l_company_car_use
                              ,l_wage_aow
                              ,l_wage_wajong
                              ,l_emp_loan
                              ,l_transportation;
    CLOSE csr_get_scl_seg;
    --
    p_chk := 'N';
    l_wage_tax_table    := NVL(l_wage_tax_table,940);
    l_wage_tax_discount := NVL(l_wage_tax_discount,'N');
    l_work_pattern      := NVL(l_work_pattern,'N');
    IF p_effective_date >= TO_DATE('01012007','DDMMYYYY') THEN
      l_work_pattern := NULL;
      p_work_pattern := NULL;
    END IF;
    --
    IF p_wage_tax_discount <> l_wage_tax_discount OR
       p_work_pattern      <> l_work_pattern      OR
       p_income_code       <> l_income_code       OR
       p_wage_tax_table    <> l_wage_tax_table    OR
       p_wage_aow          <> l_wage_aow          OR
       p_wage_wajong       <> l_wage_wajong       OR
       p_emp_loan          <> l_emp_loan          OR
       p_transportation    <> l_transportation    THEN
       p_chk := 'Y';
    END IF;
    p_wage_tax_discount := l_wage_tax_discount;
    p_work_pattern      := l_work_pattern     ;
    p_income_code       := l_income_code      ;
    p_wage_tax_table    := l_wage_tax_table   ;
    p_wage_aow          := l_wage_aow         ;
    p_wage_wajong       := l_wage_wajong      ;
    p_emp_loan          := l_emp_loan         ;
    p_transportation    := l_transportation   ;
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~p_wage_tax_discount :'||p_wage_tax_discount);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~p_work_pattern      :'||p_work_pattern);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~p_income_code       :'||p_income_code);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~p_wage_tax_table    :'||p_wage_tax_table);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~p_wage_aow          :'||p_wage_aow);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~p_wage_wajong       :'||p_wage_wajong);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~p_emp_loan          :'||p_emp_loan);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~p_transportation    :'||p_transportation);
    --
END get_scl_data;
--
--
--------------------------------------------------------------------------------
-- ARCHIVE_EMP_ADDRESS
--------------------------------------------------------------------------------
PROCEDURE archive_emp_address(p_assactid            NUMBER
                             ,p_person_id           NUMBER
                             ,p_assignment_id       NUMBER
                             ,p_assignment_number   VARCHAR2
                             ,p_name                VARCHAR2
                             ,p_tax_unit_id         NUMBER
                             ,p_m_act_info_id       NUMBER
                             ,p_arc_eff_date        DATE
                             ,p_eff_date            DATE
                             ,p_type                VARCHAR2) IS
--
  CURSOR csr_get_emp_address(c_person_id NUMBER
                            ,c_effective_date DATE) IS
  SELECT  addr.style
         ,addr.address_line1 address_line1
         ,addr.address_line2 address_line2
         ,addr.address_line3 address_line3
         ,addr.town_or_city town_or_city
         ,UPPER(addr.postal_code) postal_code
         ,addr.region_1 street_name
         ,addr.region_2 region_2
         ,addr.region_3 PO_Box_number
         ,addr.country country
         ,addr.telephone_number_1 telephone_number_1
         ,addr.telephone_number_2 telephone_number_2
         ,addr.telephone_number_3 telephone_number_3
         ,addr.add_information13 House_Number
         ,addr.add_information14 House_Number_Addition
  FROM    per_addresses addr
  WHERE   addr.person_id = c_person_id
  AND     addr.primary_flag = 'Y'
  AND     c_effective_date BETWEEN addr.date_from AND
          nvl(addr.date_to,fnd_date.canonical_to_date('4712/12/31'))
  ORDER BY 1 DESC;
  --
  l_addr csr_get_emp_address%ROWTYPE;
  l_ovn     pay_action_information.object_version_number%type;
  l_action_info_id pay_action_information.action_information_id%type;
  l_address_flag    VARCHAR2(1) := 'N';
  l_address_type VARCHAR2(30);
--
BEGIN
  --
  OPEN  csr_get_emp_address(p_person_id,p_eff_date);
  FETCH csr_get_emp_address INTO l_addr;
  IF csr_get_emp_address%FOUND THEN
    l_address_flag  := 'Y';
    IF l_addr.country = 'NL' THEN
      l_address_type := 'EMPLOYEE';
    ELSE
      l_address_type := 'EMPLOYEE FOREIGN';
    END IF;
    --#
    IF p_type IN ('INITIAL','CORRECTION') THEN
        --
        IF (l_addr.style = 'NL' AND l_addr.street_name IS NULL) OR
           (l_addr.style <> 'NL' AND l_addr.address_line1 IS NULL)THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  p_assignment_id
          , p_effective_date               =>  p_arc_eff_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  p_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_STREET')
          , p_action_information5          =>  fnd_date.date_to_canonical(p_eff_date)
          , p_action_information6          =>  'Street name missing in the address'
          , p_action_information7          =>  p_name
          , p_action_information8          =>  p_assignment_number);
        END IF;
        --
        IF l_addr.town_or_city IS NULL THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  p_assignment_id
          , p_effective_date               =>  p_arc_eff_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  p_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_CITY')
          , p_action_information5          =>  fnd_date.date_to_canonical(p_eff_date)
          , p_action_information6          =>  'City name missing in the address'
          , p_action_information7          =>  p_name
          , p_action_information8          =>  p_assignment_number);
        END IF;
        --
        IF l_addr.postal_code IS NULL AND l_addr.style = 'NL' THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  p_assignment_id
          , p_effective_date               =>  p_arc_eff_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  p_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_PO_CODE')
          , p_action_information5          =>  fnd_date.date_to_canonical(p_eff_date)
          , p_action_information6          =>  'Postal Code missing in address'
          , p_action_information7          =>  p_name
          , p_action_information8          =>  p_assignment_number);
        END IF;
        --
        IF l_addr.country IS NULL THEN
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  p_assignment_id
          , p_effective_date               =>  p_arc_eff_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  p_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_COUNTRY')
          , p_action_information5          =>  fnd_date.date_to_canonical(p_eff_date)
          , p_action_information6          =>  'Country is missing in address'
          , p_action_information7          =>  p_name
          , p_action_information8          =>  p_assignment_number);
        END IF;
        --
    END IF;
    --#
    IF l_addr.style = 'NL' THEN
        --#
        IF p_type IN ('INITIAL','CORRECTION') THEN
            --
            IF  hr_ni_chk_pkg.chk_nat_id_format(l_addr.postal_code,'DDDD AA') = upper(l_addr.postal_code) OR
                 hr_ni_chk_pkg.chk_nat_id_format(l_addr.postal_code,'DDDDAA')  = upper(l_addr.postal_code)  THEN
                NULL;
            ELSE
                pay_action_information_api.create_action_information
                (
                  p_action_information_id        =>  l_action_info_id
                , p_action_context_id            =>  p_assactid
                , p_action_context_type          =>  'AAP'
                , p_object_version_number        =>  l_ovn
                , p_assignment_id                =>  p_assignment_id
                , p_effective_date               =>  p_arc_eff_date
                , p_source_id                    =>  NULL
                , p_source_text                  =>  NULL
                , p_tax_unit_id                  =>  p_tax_unit_id
                , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_PO_FORMAT')
                , p_action_information5          =>  fnd_date.date_to_canonical(p_eff_date)
                , p_action_information6          =>  'Postal Code is not in the format 9999XX'
                , p_action_information7          =>  p_name
                , p_action_information8          =>  p_assignment_number);
            END IF;
            --
        END IF;
        --#
      pay_action_information_api.create_action_information (
                          p_action_information_id        =>  l_action_info_id
                         ,p_action_context_id            =>  p_assactid
                         ,p_action_context_type          =>  'AAP'
                         ,p_object_version_number        =>  l_ovn
                         ,p_assignment_id                =>  p_assignment_id
                         ,p_effective_date               =>  p_arc_eff_date
                         ,p_source_id                    =>  NULL
                         ,p_source_text                  =>  NULL
                         ,p_tax_unit_id                  =>  p_tax_unit_id
                         ,p_action_information_category  =>  'ADDRESS DETAILS'
                         ,p_action_information1          =>  p_person_id
                         ,p_action_information5          =>  substr(l_addr.House_Number,1,5)
                         ,p_action_information6          =>  substr(l_addr.House_Number_Addition,1,4)
                         ,p_action_information8          =>  l_addr.town_or_city --substr(l_addr.town_or_city,1,24)
                         ,p_action_information9          =>  substr(l_addr.street_name,1,24)
                         ,p_action_information11         =>  TRIM(substr(l_addr.address_line1||' '||l_addr.PO_Box_number,1,35)) -- Location
                         ,p_action_information12         =>  REPLACE(l_addr.postal_code,' ','')
                         ,p_action_information13         =>  l_addr.country
                         ,p_action_information14         =>  l_address_type
                         ,p_action_information26         =>  p_type
                         ,p_action_information27         =>  p_m_act_info_id); -- add ADD_INFORMATION13 and ADD_INFORMATION14
    ELSE
      IF l_addr.country <> 'NL' THEN
        pay_action_information_api.create_action_information (
                          p_action_information_id        =>  l_action_info_id
                         ,p_action_context_id            =>  p_assactid
                         ,p_action_context_type          =>  'AAP'
                         ,p_object_version_number        =>  l_ovn
                         ,p_assignment_id                =>  p_assignment_id
                         ,p_effective_date               =>  p_arc_eff_date
                         ,p_source_id                    =>  NULL
                         ,p_source_text                  =>  NULL
                         ,p_tax_unit_id                  =>  p_tax_unit_id
                         ,p_action_information_category  =>  'ADDRESS DETAILS'
                         ,p_action_information1          =>  p_person_id
                         ,p_action_information5          =>  SUBSTR(l_addr.address_line1,1,24) -- street
                         ,p_action_information6          =>  SUBSTR(l_addr.address_line2,1,9) -- house nr
                         ,p_action_information7          =>  SUBSTR(l_addr.address_line3,1,35) -- location
                         ,p_action_information8          =>  SUBSTR(l_addr.town_or_city,1,50)
                         ,p_action_information9          =>  l_addr.street_name --SUBSTR(l_addr.street_name,1,24) -- region
                         ,p_action_information12         =>  SUBSTR(l_addr.postal_code,1,9)
                         ,p_action_information13         =>  SUBSTR(l_addr.country,1,2)
                         ,p_action_information14         =>  l_address_type
                         ,p_action_information26         =>  p_type
                         ,p_action_information27         =>  p_m_act_info_id); -- add tel numbers also
      END IF;
    END IF;
  END IF;
  CLOSE csr_get_emp_address;
  --#
  --abraghun--7668628--Check0050 already exists.
  --
  IF  l_address_flag    = 'N' AND p_type IN ('INITIAL','CORRECTION') THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_assactid
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  p_assignment_id
      , p_effective_date               =>  p_arc_eff_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  p_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_ADDRESS')
      , p_action_information5          =>  fnd_date.date_to_canonical(p_eff_date)
      , p_action_information6          =>  'Address details are null'
      , p_action_information7          =>  p_name
      , p_action_information8          =>  p_assignment_number);
  END IF;
  --#
END archive_emp_address;
--
--------------------------------------------------------------------------------
-- ARCHIVE_SECTOR_RISK_GROUP
--------------------------------------------------------------------------------
FUNCTION archive_sector_risk_group( p_actid           NUMBER
                                   ,p_assignment_id   NUMBER
                                   ,p_effective_date  DATE
                                   ,p_tax_unit_id     NUMBER
                                   ,p_mas_act_info_id NUMBER
                                   ,p_start_date      DATE
                                   ,p_end_date        DATE
                                   ,p_emp_start_date  DATE
                                   ,p_emp_end_date    DATE
                                   ,p_payroll_type    VARCHAR2) RETURN VARCHAR2 IS
--
  CURSOR csr_get_emp_risk_grp(c_assignment_id NUMBER) IS
  SELECT DISTINCT hoi.organization_id
        ,hoi.org_information5 sector
        ,hoi.org_information6 risk_group
        ,fnd_date.canonical_to_date(aei.AEI_INFORMATION1) start_date
        ,fnd_date.canonical_to_date(aei.AEI_INFORMATION2) end_date
  FROM   hr_organization_information hoi
        ,per_assignment_extra_info aei
  WHERE  hoi.organization_id = nvl( aei.aei_information8,HR_NL_ORG_INFO.Get_SI_Provider_Info(aei.assignment_id,aei.AEI_INFORMATION3))
  AND    aei.assignment_id = c_assignment_id
  AND    aei.information_type = 'NL_SII'
  AND    aei.aei_information3 IN ('WW','AMI','ZW','WAO')
  AND    hoi.org_information5 IS NOT NULL
  AND    hoi.org_information6 IS NOT NULL
  AND    hoi.org_information_context= 'NL_UWV'
  ORDER  BY 2,3;
  /*SELECT DISTINCT organization_id
        ,org_information5 sector
        ,org_information6 risk_group
  FROM   hr_organization_information
  WHERE  organization_id IN (SELECT HR_NL_ORG_INFO.Get_SI_Provider_Info(assignment_id,AEI_INFORMATION3)
                             FROM   per_assignment_extra_info
                             WHERE  assignment_id = c_assignment_id
                             AND    information_type = 'NL_SII'
                             AND    aei_information3 IN ('WW','AMI'))
  AND    org_information5 IS NOT NULL
  AND    org_information6 IS NOT NULL
  AND    org_information_context= 'NL_UWV';*/
  --AND    rownum < 6;
  --
  l_action_info_id pay_action_information.action_information_id%TYPE;
  l_ovn            pay_action_information.object_version_number%type;
  l_srg_flag       VARCHAR2(1);
  l_srg_flag_52    VARCHAR2(1);
  l_start_date     DATE;
  l_end_date       DATE;
  l_sector         VARCHAR2(30);
  l_risk_grp       VARCHAR2(30);

--
BEGIN
  --
  l_srg_flag    := 'N';
  l_srg_flag_52 := 'N';
  l_start_date  := p_start_date;
  l_end_date    := p_end_date;
  l_sector      := 'X';
  l_risk_grp    := 'X';
  --
  IF p_emp_start_date BETWEEN p_start_date AND p_end_date THEN
    l_start_date  := p_emp_start_date;
  END IF;
  IF p_emp_end_date BETWEEN p_start_date AND p_end_date THEN
    l_end_date  := p_emp_end_date;
  END IF;
  --
  FOR l_rec IN csr_get_emp_risk_grp(p_assignment_id) LOOP
    IF ( (NVL(l_rec.end_date,l_end_date) >= l_end_date) OR
         (p_payroll_type = 'YEARLY' AND NVL(l_rec.end_date,l_end_date) >= l_start_date))
       AND l_rec.start_date <= l_end_date
       AND l_sector <> l_rec.sector  AND l_risk_grp <> l_rec.risk_group THEN
    --IF NVL(l_rec.end_date,l_end_date) >= l_start_date AND l_rec.start_date <= l_end_date THEN
      /*IF l_rec.start_date BETWEEN p_start_date AND p_end_date  AND
         l_rec.start_date >= NVL(l_start_date,l_rec.start_date)THEN
         l_start_date := l_rec.start_date;
      END IF;
      IF l_rec.end_date BETWEEN p_start_date AND p_end_date  AND
         l_rec.start_date >= NVL(l_end_date,l_rec.start_date)THEN
         l_end_date := l_rec.end_date;
      END IF;*/
      --
      pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_actid
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  p_assignment_id
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
       ,p_tax_unit_id                  =>  p_tax_unit_id
      , p_action_information_category  =>  'NL_WR_SWMF_SECTOR_RISK_GROUP'
      , p_action_information1          =>  'SECTOR_RISK_GROUP'
      , p_action_information2          =>  p_mas_act_info_id
      , p_action_information5          =>  fnd_date.date_to_canonical(l_start_date)
      , p_action_information6          =>  fnd_date.date_to_canonical(LEAST(l_end_date,NVL(l_rec.end_date,l_end_date)))
      , p_action_information7          =>  l_rec.sector
      , p_action_information8          =>  l_rec.risk_group
      , p_action_information9          =>  NULL
      , p_action_information10         =>  NULL);
      --
      l_srg_flag  := 'Y';
      IF l_rec.sector = '52' THEN
        l_srg_flag_52 := 'Y';
      END IF;
      --
      l_risk_grp := l_rec.risk_group;
      l_sector   := l_rec.sector;
      --
    END IF;
      --
  END LOOP;
  /*OPEN  csr_get_emp_risk_grp(p_assignment_id);
  FETCH csr_get_emp_risk_grp INTO l_sector_rec;
  IF csr_get_emp_risk_grp%found THEN
    pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_actid
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  p_assignment_id
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
       ,p_tax_unit_id                  =>  p_tax_unit_id
      , p_action_information_category  =>  'NL_WR_SWMF_SECTOR_RISK_GROUP'
      , p_action_information1          =>  'SECTOR_RISK_GROUP'
      , p_action_information2          =>  p_mas_act_info_id
      , p_action_information5          =>  fnd_date.date_to_canonical(p_start_date)
      , p_action_information6          =>  fnd_date.date_to_canonical(p_end_date)
      , p_action_information7          =>  l_sector_rec.sector
      , p_action_information8          =>  l_sector_rec.risk_group
      , p_action_information9          =>  NULL
      , p_action_information10         =>  NULL);
      --
    l_srg_flag  := 'Y';
    IF l_sector_rec.sector = '52' THEN
        l_srg_flag_52 := 'Y';
    END IF;
  END IF;
  CLOSE csr_get_emp_risk_grp; */
  --
  IF l_srg_flag_52 = 'Y' THEN
    l_srg_flag := 'Z';
  END IF;
  --
  RETURN l_srg_flag;
  --
END archive_sector_risk_group;
--
--------------------------------------------------------------------------------
-- GET_NOMINATIVE_DATA
--------------------------------------------------------------------------------
PROCEDURE get_nominative_data(p_bal_tab         Bal_Value
                             ,p_nom_bal_value   IN OUT NOCOPY Bal_Value) IS
--
BEGIN
    --
    FOR i in 1..36 LOOP --LC 2010-- increased from 29 to 36
        p_nom_bal_value(i).balance_value := 0;
    END LOOP;
    --
    FOR i in 1..3 LOOP -- Wage LB/PH
        p_nom_bal_value(1).balance_value := p_nom_bal_value(1).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    FOR i in 92..93 LOOP
        p_nom_bal_value(1).balance_value := p_nom_bal_value(1).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
        FOR i in 13..15 LOOP
        p_nom_bal_value(1).balance_value := p_nom_bal_value(1).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
    FOR i in 4..12 LOOP -- SI Income
        p_nom_bal_value(2).balance_value := p_nom_bal_value(2).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
    FOR i in 13..15 LOOP    -- 'SP RATE TAXABLE INCOME'
        p_nom_bal_value(3).balance_value := p_nom_bal_value(3).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
    p_nom_bal_value(4).balance_value := p_bal_tab(16).balance_value; -- 'HOLIDAY ALLW'
    p_nom_bal_value(5).balance_value := p_bal_tab(17).balance_value; -- 'RESERVATION HOLIDAY ALLW'
    p_nom_bal_value(6).balance_value := p_bal_tab(18).balance_value + p_bal_tab(118).balance_value
                                        + p_bal_tab(119).balance_value; -- 'ADDITIONAL PERIOD WAGE'
    p_nom_bal_value(7).balance_value := p_bal_tab(19).balance_value; -- 'R ADDITIONAL PERIOD WAGE'
    --
    FOR i in 20..25 LOOP -- 'WAGE_MONEY'
        p_nom_bal_value(8).balance_value := p_nom_bal_value(8).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
--Bug# 7110638
    /*FOR i in 96..101 LOOP
        p_nom_bal_value(8).balance_value := p_nom_bal_value(8).balance_value + p_bal_tab(i).balance_value;
    END LOOP;*/
--Bug# 7110638
    --
    FOR i in 26..31 LOOP  -- 'WAGE_KIND'
        p_nom_bal_value(9).balance_value := p_nom_bal_value(9).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
--Bug# 7110638
    /*FOR i in 102..107 LOOP
        p_nom_bal_value(9).balance_value := p_nom_bal_value(9).balance_value + p_bal_tab(i).balance_value;
    END LOOP;*/
--Bug# 7110638
    --
    p_nom_bal_value(10).balance_value := p_bal_tab(38).balance_value;  -- 'OT_WAGE'
    --
    FOR i in 39..44 LOOP -- 'WAGE_TAX'
        p_nom_bal_value(11).balance_value := p_nom_bal_value(11).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    FOR i in 94..95 LOOP
        p_nom_bal_value(11).balance_value := p_nom_bal_value(11).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    FOR i in 114..115 LOOP
        p_nom_bal_value(11).balance_value := p_nom_bal_value(11).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
    FOR i in 45..53 LOOP -- 'WAO_CONTRBUTION_AOF' all 16 WAOB - WGA - IVA   45..53
        p_nom_bal_value(12).balance_value := p_nom_bal_value(12).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
    IF g_public_org_flag = 'N' AND g_risk_cover_flag = 'Y' THEN
      p_nom_bal_value(13).balance_value := 0;
    ELSIF g_public_org_flag = 'Y' AND g_risk_cover_flag = 'Y' THEN
      p_nom_bal_value(13).balance_value := 0;
    ELSE
      FOR i in 54..56 LOOP -- 'WAO_CONTRBUTION_AOK' all 16 WAOD
        p_nom_bal_value(13).balance_value := p_nom_bal_value(13).balance_value + p_bal_tab(i).balance_value;
      END LOOP;
    END IF;
    --
    IF g_public_org_flag = 'Y' THEN
      p_nom_bal_value(14).balance_value := NULL;
    ELSE
      FOR i in 57..59 LOOP -- 'WW_AWF' WEWE all emp
        p_nom_bal_value(14).balance_value := p_nom_bal_value(14).balance_value + p_bal_tab(i).balance_value;
      END LOOP;
    END IF;
    --
    IF g_public_org_flag = 'Y' THEN
      p_nom_bal_value(15).balance_value := NULL;
    ELSE
      FOR i in 60..62 LOOP -- 'c_WAITING_MONEY_FUND'  all 16 - WEWA
        p_nom_bal_value(15).balance_value := p_nom_bal_value(15).balance_value + p_bal_tab(i).balance_value;
      END LOOP;
    END IF;
    --
    IF g_public_org_flag = 'Y' THEN
      FOR i in 63..65 LOOP -- 'UFO_CONTRIBUTION'  all 16 UFO 63..65
        p_nom_bal_value(16).balance_value := p_nom_bal_value(16).balance_value + p_bal_tab(i).balance_value;
      END LOOP;
    ELSE
      p_nom_bal_value(16).balance_value := NULL;
    END IF;
    --
    FOR i in 66..68 LOOP -- 'ZVW_CONTRIBUTION' -- all emp ZVW 66..68
        p_nom_bal_value(17).balance_value := p_nom_bal_value(17).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
    FOR i in 80..91 LOOP -- 'ZVW_ALLW' all empr zvw -different balances  80..91
        p_nom_bal_value(18).balance_value := p_nom_bal_value(18).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
    p_nom_bal_value(19).balance_value := p_bal_tab(69).balance_value + p_bal_tab(116).balance_value + p_bal_tab(117).balance_value;
    --
    FOR i in 70..72 LOOP -- 'LABOUR DISC'
        p_nom_bal_value(20).balance_value := p_nom_bal_value(20).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --p_nom_bal_value(20).balance_value := p_nom_bal_value(20).balance_value * -1;
    --
    FOR i in 73..75 LOOP -- 'SI_DAYS'
        p_nom_bal_value(21).balance_value := p_nom_bal_value(21).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    p_nom_bal_value(21).balance_value := ROUND(p_nom_bal_value(21).balance_value);
    --
    p_nom_bal_value(22).balance_value := ROUND(p_bal_tab(76).balance_value); -- 'NO_HOURS'
    p_nom_bal_value(23).balance_value := p_bal_tab(77).balance_value; -- 'AMOUNT_SEE_DISCONT_DAYS'
    p_nom_bal_value(24).balance_value := p_bal_tab(78).balance_value; -- 'WWB-ALL_ALIMONY'
    p_nom_bal_value(25).balance_value := p_bal_tab(79).balance_value; -- 'DIRECTLY_PAID_ALIMONY'
    --
    p_nom_bal_value(26).balance_value := ROUND(p_bal_tab(108).balance_value); -- 'Private Company Car '
    p_nom_bal_value(27).balance_value := p_bal_tab(109).balance_value; -- 'Employee Private Company Car'
    p_nom_bal_value(28).balance_value := p_bal_tab(110).balance_value; -- 'Contribution Child Care'
    p_nom_bal_value(29).balance_value := p_bal_tab(111).balance_value + p_bal_tab(122).balance_value; -- 'Life Saving Scheme'
    p_nom_bal_value(30).balance_value := p_bal_tab(112).balance_value + p_bal_tab(120).balance_value
                                         + p_bal_tab(121).balance_value; -- 'Life Cycle Leave Discount'
    p_nom_bal_value(31).balance_value := p_bal_tab(113).balance_value; -- 'Paid Disability Allowance'
    --
    p_nom_bal_value(11).balance_value := p_nom_bal_value(11).balance_value - NVL(p_nom_bal_value(30).balance_value,0);
    --
--LC 2010 -- begin
    -- Changed 123..131 to 123..125 to remove IVA and WGA and have only WAOB.
    FOR i in 123..125 LOOP -- 'Employee Contribution Base WAOB 123..125
        p_nom_bal_value(32).balance_value := p_nom_bal_value(32).balance_value + p_bal_tab(i).balance_value;
    END LOOP;
    --
    IF g_public_org_flag = 'N' AND g_risk_cover_flag = 'Y' THEN
      p_nom_bal_value(33).balance_value := 0;
    ELSIF g_public_org_flag = 'Y' AND g_risk_cover_flag = 'Y' THEN
      p_nom_bal_value(33).balance_value := 0;
    ELSE
      FOR i in 132..134 LOOP -- 'Employee Contribution base general WAO/WGA Differentiated  132..134
        p_nom_bal_value(33).balance_value := p_nom_bal_value(33).balance_value + p_bal_tab(i).balance_value;
      END LOOP;
    END IF;
    --
    IF g_public_org_flag = 'Y' THEN
      p_nom_bal_value(34).balance_value := 0;
    ELSE
      FOR i in 135..137 LOOP -- 'Employee Contribution base WW_AWF-  WEWE all emp
        p_nom_bal_value(34).balance_value := p_nom_bal_value(34).balance_value + p_bal_tab(i).balance_value;
      END LOOP;
    END IF;
    --
    IF g_public_org_flag = 'Y' THEN
      p_nom_bal_value(35).balance_value := 0;
    ELSE
      FOR i in 141..143 LOOP -- 'Contribution base WAITING_MONEY_FUND'   - WEWA
        p_nom_bal_value(35).balance_value := p_nom_bal_value(35).balance_value + p_bal_tab(i).balance_value;
      END LOOP;
    END IF;
    --
--    IF g_public_org_flag = 'Y' THEN
      FOR i in 138..140 LOOP --  Employee UFO_CONTRIBUTION'  all 16 UFO
        p_nom_bal_value(36).balance_value := p_nom_bal_value(36).balance_value + p_bal_tab(i).balance_value;
      END LOOP;
--    ELSE
--      p_nom_bal_value(36).balance_value := 0;
--    END IF;
    --
--LC 2010 -- end
    --archive_nominative_date
    --
END get_nominative_data;
--
--------------------------------------------------------------------------------
-- ARCHIVE_NOMINATIVE_DATA
--------------------------------------------------------------------------------
PROCEDURE archive_nominative_data(p_assactid              NUMBER
                                 ,p_assignment_id         NUMBER
                                 ,p_tax_unit_id           NUMBER
                                 ,p_effective_date        DATE
                                 ,p_date                  DATE
                                 ,p_type                  VARCHAR2
                                 ,p_master_action_info_id NUMBER
                                 ,p_name                  VARCHAR2
                                 ,p_corr_used             VARCHAR2
                                 ,p_payroll_type          VARCHAR2
                                 ,p_nom_bal_value         IN OUT NOCOPY Bal_Value) IS
--
l_ovn     pay_action_information.object_version_number%type;
l_action_info_id pay_action_information.action_information_id%type;
--
BEGIN
  IF p_nom_bal_value(14).balance_value <> 0 AND p_nom_bal_value(16).balance_value <> 0 THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_assactid
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  p_assignment_id
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  p_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_UFO_AND_AWF')
      , p_action_information5          =>  fnd_date.date_to_canonical(p_date)
      , p_action_information6          =>  'UFO Contributions and AWF Contributions exist'
      , p_action_information7          =>  p_name
      , p_action_information8          =>  p_assignment_id);
  END IF;
  --
  IF  p_nom_bal_value(14).balance_value <> 0 AND  p_nom_bal_value(15).balance_value = 0 THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_assactid
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  p_assignment_id
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  p_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_ZERO_WEWA')
      , p_action_information5          =>  fnd_date.date_to_canonical(p_date)
      , p_action_information6          =>  'Waiting Money Fund contribution is zero'
      , p_action_information7          =>  p_name
      , p_action_information8          =>  p_assignment_id);
  END IF;
  --
  IF  p_nom_bal_value(14).balance_value = 0 AND  p_nom_bal_value(15).balance_value <> 0 THEN
      pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_assactid
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  p_assignment_id
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_tax_unit_id                  =>  p_tax_unit_id
      , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
      , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_ZERO_WEWE')
      , p_action_information5          =>  fnd_date.date_to_canonical(p_date)
      , p_action_information6          =>  'AWF contribution is zero'
      , p_action_information7          =>  p_name
      , p_action_information8          =>  p_assignment_id);
  END IF;
  --#
  -- Optional fields to be supressed in the report - hence passing NULL instead of 0 -vv
  FOR i IN 23..25 LOOP
     IF (p_nom_bal_value(i).balance_value = 0 ) THEN
         p_nom_bal_value(i).balance_value := NULL;
     END IF;
  END LOOP;
  --
  IF g_effective_date < TO_DATE('01012007','DDMMYYYY') THEN
    p_nom_bal_value(30).balance_value := NULL;
    p_nom_bal_value(31).balance_value := NULL;
  ELSE
    --p_nom_bal_value(28).balance_value := NULL;  Bug 5902666
    p_nom_bal_value(28).balance_value := 0;  --Bug 5902666
    p_nom_bal_value(15).balance_value := p_nom_bal_value(15).balance_value + p_nom_bal_value(30).balance_value;
  END IF;
  --
  IF p_payroll_type = 'YEARLY' THEN
    p_nom_bal_value(4).balance_value  := NULL;
    p_nom_bal_value(5).balance_value  := NULL;
    p_nom_bal_value(6).balance_value  := NULL;
    p_nom_bal_value(7).balance_value  := NULL;
    p_nom_bal_value(8).balance_value  := NULL;
    p_nom_bal_value(9).balance_value  := NULL;
    p_nom_bal_value(10).balance_value := NULL;
    p_nom_bal_value(21).balance_value := NULL;
    p_nom_bal_value(22).balance_value := NULL;
    p_nom_bal_value(28).balance_value := NULL;
    --p_nom_bal_value(30).balance_value := NULL;  --ENh# 6968464
    p_nom_bal_value(31).balance_value := NULL;
  END IF;
  --
  pay_action_information_api.create_action_information (
    p_action_information_id        =>  l_action_info_id
  , p_action_context_id            =>  p_assactid
  , p_action_context_type          =>  'AAP'
  , p_object_version_number        =>  l_ovn
  , p_assignment_id                =>  p_assignment_id
  , p_effective_date               =>  p_effective_date
  , p_action_information_category  =>  'NL_WR_NOMINATIVE_REPORT'
  , p_tax_unit_id                  =>  p_tax_unit_id
  , p_action_information1          =>  p_type
  , p_action_information2          =>  p_master_action_info_id
  , p_action_information5          =>  fnd_number.number_to_canonical(p_nom_bal_value(1).balance_value)
  , p_action_information6          =>  fnd_number.number_to_canonical(p_nom_bal_value(2).balance_value)
  , p_action_information7          =>  fnd_number.number_to_canonical(p_nom_bal_value(3).balance_value)  -- 'SP RATE TAXABLE INCOME'
  , p_action_information8          =>  fnd_number.number_to_canonical(p_nom_bal_value(4).balance_value)  -- 'HOLIDAY ALLW' ** Not req for YEarly report
  , p_action_information9          =>  fnd_number.number_to_canonical(p_nom_bal_value(5).balance_value)  -- 'RESERVATION HOLIDAY ALLW' ** Not req for YEarly report
  , p_action_information10         =>  fnd_number.number_to_canonical(p_nom_bal_value(6).balance_value)  -- 'ADDITIONAL PERIOD WAGE' ** Not req for YEarly report
  , p_action_information11         =>  fnd_number.number_to_canonical(p_nom_bal_value(7).balance_value)  -- 'R ADDITIONAL PERIOD WAGE' ** Not req for YEarly report
  , p_action_information12         =>  fnd_number.number_to_canonical(p_nom_bal_value(8).balance_value)  -- 'WAGE_MONEY' ** Not req for YEarly report
  , p_action_information13         =>  fnd_number.number_to_canonical(p_nom_bal_value(9).balance_value)  -- 'WAGE_KIND' ** Not req for YEarly report
  , p_action_information14         =>  fnd_number.number_to_canonical(p_nom_bal_value(10).balance_value) -- 'OT_WAGE' ** Not req for YEarly report
  , p_action_information15         =>  fnd_number.number_to_canonical(p_nom_bal_value(11).balance_value) -- 'WAGE_TAX'
  , p_action_information16         =>  fnd_number.number_to_canonical(p_nom_bal_value(12).balance_value) -- 'WAO_CONTRBUTION_AOF'
  , p_action_information17         =>  fnd_number.number_to_canonical(p_nom_bal_value(13).balance_value) -- 'WAO_CONTRBUTION_AOK'
  , p_action_information18         =>  fnd_number.number_to_canonical(p_nom_bal_value(14).balance_value) -- 'WW_AWF'
  , p_action_information19         =>  fnd_number.number_to_canonical(p_nom_bal_value(15).balance_value) -- 'c_WAITING_MONEY_FUND'
  , p_action_information20         =>  fnd_number.number_to_canonical(p_nom_bal_value(16).balance_value) -- 'UFO_CONTRIBUTION'
  , p_action_information21         =>  fnd_number.number_to_canonical(p_nom_bal_value(17).balance_value) -- 'ZVW_CONTRIBUTION'
  , p_action_information22         =>  fnd_number.number_to_canonical(p_nom_bal_value(18).balance_value) -- 'ZVW_ALLW'
  , p_action_information23         =>  fnd_number.number_to_canonical(p_nom_bal_value(19).balance_value) -- 'TRAVEL ALLW'
  , p_action_information24         =>  fnd_number.number_to_canonical(p_nom_bal_value(20).balance_value) -- 'LABOUR DISC'
  , p_action_information25         =>  fnd_number.number_to_canonical(p_nom_bal_value(21).balance_value) -- 'SI_DAYS' ** Not req for YEarly report
  , p_action_information26         =>  fnd_number.number_to_canonical(p_nom_bal_value(22).balance_value) -- 'NO_HOURS' ** Not req for YEarly report
  , p_action_information27         =>  fnd_number.number_to_canonical(p_nom_bal_value(23).balance_value) -- 'AMOUNT_SEE_DISCONT_DAYS'
  , p_action_information28         =>  fnd_number.number_to_canonical(p_nom_bal_value(24).balance_value) -- 'WWB-ALL_ALIMONY'
  , p_action_information29         =>  fnd_number.number_to_canonical(p_nom_bal_value(25).balance_value)); -- 'DIRECTLY_PAID_ALIMONY');
--
  pay_action_information_api.create_action_information (
    p_action_information_id        =>  l_action_info_id
  , p_action_context_id            =>  p_assactid
  , p_action_context_type          =>  'AAP'
  , p_object_version_number        =>  l_ovn
  , p_assignment_id                =>  p_assignment_id
  , p_effective_date               =>  p_effective_date
  , p_action_information_category  =>  'NL_WR_NOMINATIVE_REPORT_ADD'
  , p_tax_unit_id                  =>  p_tax_unit_id
  , p_action_information1          =>  p_type
  , p_action_information2          =>  p_master_action_info_id
  , p_action_information5          =>  fnd_number.number_to_canonical(p_nom_bal_value(26).balance_value)  -- 'Private Company Car'
  , p_action_information6          =>  fnd_number.number_to_canonical(p_nom_bal_value(27).balance_value)  -- 'Employee Private Company Car'
  , p_action_information7          =>  fnd_number.number_to_canonical(p_nom_bal_value(28).balance_value)  -- 'Contribution Child Care' ** Not req for YEarly report
  , p_action_information8          =>  fnd_number.number_to_canonical(p_nom_bal_value(29).balance_value)  -- 'Life Saving Scheme'
  , p_action_information9          =>  fnd_number.number_to_canonical(p_nom_bal_value(30).balance_value)  -- 'Applied Amount of Life Cycle Leave Discount' ** Not req for YEarly report
  , p_action_information10         =>  fnd_number.number_to_canonical(p_nom_bal_value(31).balance_value)
  , p_action_information11         =>  NVL(p_corr_used,'N')  -- 'Allowance paid on top of paid disability'  ** Not req for YEarly report
  --LC 2010--begin
  , p_action_information12         =>  fnd_number.number_to_canonical(p_nom_bal_value(32).balance_value)  --PrLnWao
  , p_action_information13         =>  fnd_number.number_to_canonical(p_nom_bal_value(33).balance_value)  --PrLnWaoWga
  , p_action_information14         =>  fnd_number.number_to_canonical(p_nom_bal_value(34).balance_value)  --PrLnWwAwf
  , p_action_information15         =>  fnd_number.number_to_canonical(p_nom_bal_value(35).balance_value)  --PrLnPrSectFnds
  , p_action_information16         =>  fnd_number.number_to_canonical(p_nom_bal_value(36).balance_value)  --PrLnUfo
  );
  --LC 2010--end
  --
END archive_nominative_data;
--------------------------------------------------------------------------------
-- GET_ASSIGNMENT_EXTRA_INFO
--------------------------------------------------------------------------------
PROCEDURE get_assignment_extra_info(p_assignment_id    IN NUMBER
                                   ,p_surrogate_key    IN NUMBER
                                   ,p_eff_date         IN DATE
                                   ,p_start_date       IN DATE
                                   ,p_end_date         IN DATE
                                   ,p_labour_rel_code  IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
                                   ,p_ins_duty_code    IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
                                   ,p_FZ_Code          IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
                                   ,p_handicapped_code IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
                                   ,p_wao_insured      IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
                                   ,p_ww_insured       IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
                                   ,p_zw_insured       IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
                                   ,p_zvw_situation    IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
         /*LC 2010*/               ,p_marginal_empl    IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
         /*LC 2010*/               ,p_wm_old_rule      IN OUT NOCOPY PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type
                                   ,p_chk              IN OUT NOCOPY VARCHAR2) IS
--
  CURSOR csr_get_ass_extra_info(c_a_extra_info_id NUMBER) IS
  SELECT fnd_date.canonical_to_date(aei_information1) start_date
        ,fnd_date.canonical_to_date(aei_information2) end_date
        ,aei_information3   info1
        ,aei_information15  info2
        ,aei_information_category
  FROM   per_assignment_extra_info
  WHERE  assignment_extra_info_id = c_a_extra_info_id
  AND    aei_information_category IN ('NL_LBR','NL_INF','NL_TML','NL_LHI','NL_SII',
'NL_MEI','NL_WMR');/*LC 2010*/
  --
  CURSOR csr_get_all_ass_extra_info(c_assignment_id NUMBER) IS
  SELECT fnd_date.canonical_to_date(aei_information1) start_date
        ,fnd_date.canonical_to_date(aei_information2) end_date
        ,aei_information3  info1
        ,aei_information15 info2
        ,aei_information_category
  FROM   per_assignment_extra_info
  WHERE  assignment_id = c_assignment_id
  AND    aei_information_category IN ('NL_LBR','NL_INF','NL_TML','NL_LHI','NL_SII',
'NL_MEI','NL_WMR') /*LC 2010*/
--9257875
    AND    p_end_date BETWEEN fnd_date.canonical_to_date(aei_information1)
           AND nvl(fnd_date.canonical_to_date(aei_information2),to_date('31-12-4712','dd-mm-yyyy'))
--9257875
  ORDER BY 1 DESC;
  --
    --rsahai--Labour Handicapped discount - New Code 7 Changes : 2009 changes - START
    CURSOR csr_all_ass_extra_info_code6_9(c_assignment_id NUMBER) IS
    SELECT aei_information3  info1
    FROM   per_assignment_extra_info
    WHERE  assignment_id = c_assignment_id
    AND    aei_information_category = 'NL_LHI'
    AND    p_end_date BETWEEN fnd_date.canonical_to_date(aei_information1)
           AND nvl(fnd_date.canonical_to_date(aei_information2),to_date('31-12-4712','dd-mm-yyyy'))
    AND    aei_information3 not in ('0','1','2','3','4');

    CURSOR csr_get_ass_bdate(c_assignment_id NUMBER) IS
    select papf.date_of_birth, TRUNC(MONTHS_BETWEEN(p_end_date,papf.date_of_birth)/12) Age
    from
    per_all_people_f papf,
    per_all_assignments_f paaf
    where paaf.assignment_id = c_assignment_id
    AND papf.person_id = paaf.person_id
    AND p_end_date between paaf.effective_start_date and paaf.effective_end_date
    AND p_end_date between papf.effective_start_date and papf.effective_end_date
    AND papf.date_of_birth is not null;
      --rsahai--Labour Handicapped discount - New Code 7 Changes : 2009 changes - End
  --
  l_labour_rel_code   PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_ins_duty_code     PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_FZ_Code           PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_handicapped_code  PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_wao_insured       PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_ww_insured        PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zw_insured        PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zvw_situation     PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_labour_rel_code1  PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_ins_duty_code1    PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_FZ_Code1          PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_handicapped_code1 PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_wao_insured1      PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_ww_insured1       PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zw_insured1       PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zvw_situation1    PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  --rsahai--Labour Handicapped discount - New Code 7 Changes : 2009 changes - START
  l_handicapped_code_new PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_bdate  date;
  l_age number;
  --rsahai--Labour Handicapped discount - New Code 7 Changes : 2009 changes - END
  l_marginal_empl     PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_wm_old_rule       PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_marginal_empl1    PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_wm_old_rule1      PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;

--
BEGIN
--
  l_labour_rel_code1  := p_labour_rel_code ;
  l_ins_duty_code1    := p_ins_duty_code   ;
  l_FZ_Code1          := p_FZ_Code         ;
  l_handicapped_code1 := p_handicapped_code;
  l_wao_insured1      := NVL(p_wao_insured,'N');
  l_ww_insured1       := NVL(p_ww_insured,'N');
  l_zw_insured1       := NVL(p_zw_insured,'N');
  l_zvw_situation1    := p_zvw_situation;
  l_marginal_empl1    := p_marginal_empl; /*LC 2010*/
  l_wm_old_rule1      := p_wm_old_rule;   /*LC 2010*/
  --
  l_labour_rel_code   := NULL;
  l_ins_duty_code     := NULL;
  l_FZ_Code           := NULL;
  l_handicapped_code  := NULL;
  l_wao_insured       := NULL;
  l_ww_insured        := NULL;
  l_zw_insured        := NULL;
  l_zvw_situation     := NULL;
  l_marginal_empl     := NULL;   /*LC 2010*/
  l_wm_old_rule       := NULL;   /*LC 2010*/

  --rsahai--Labour Handicapped discount - New Code 7 Changes : 2009 changes - START
  l_handicapped_code_new := NULL;
  l_bdate             := NULL;
  l_age               := NULL;
  --rsahai--Labour Handicapped discount - New Code 7 Changes : 2009 changes - END

  --
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ Inside get_assignment_extra_info'||p_assignment_id);
  IF p_surrogate_key IS NULL THEN
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_surrogate_key is null');
    FOR i in csr_get_all_ass_extra_info(p_assignment_id) LOOP
      IF p_eff_date BETWEEN i.start_date AND NVL(i.end_date,fnd_date.canonical_to_date('4712/12/31'))
	  OR p_end_date BETWEEN i.start_date AND NVL(i.end_date,fnd_date.canonical_to_date('4712/12/31'))  --9257875
        OR (i.start_date <= p_end_date  AND NVL(i.end_date,p_end_date) >= p_start_date AND p_eff_date < fnd_date.canonical_to_date('2006/01/01')) THEN -- SR 5531106.992
        --
        IF i.aei_information_category = 'NL_LBR' AND l_labour_rel_code IS NULL THEN
          l_labour_rel_code := i.info1;
        ELSIF i.aei_information_category = 'NL_INF' AND l_ins_duty_code IS NULL THEN
          l_ins_duty_code := i.info1;
        ELSIF i.aei_information_category = 'NL_TML' AND l_FZ_Code IS NULL THEN
          l_FZ_Code := i.info1;
        ELSIF i.aei_information_category = 'NL_LHI' AND l_handicapped_code IS NULL THEN
          l_handicapped_code := i.info1;
        ELSIF i.aei_information_category = 'NL_SII' THEN
          IF i.info1 IN ('AMI','WAO') AND l_wao_insured IS NULL THEN
            l_wao_insured := 'J';
          END IF;
          IF i.info1 IN ('AMI','WW') AND l_ww_insured IS NULL THEN
            l_ww_insured := 'J';
          END IF;
          IF  i.info1 IN ('AMI','ZW') AND l_zw_insured IS NULL THEN
            l_zw_insured := 'J';
          END IF;
          IF  i.info1 IN ('AMI','ZVW') AND l_zvw_situation IS NULL THEN
            l_zvw_situation := i.info2;
          END IF;
--LC 2010--begin
        ELSIF i.aei_information_category = 'NL_MEI' THEN
          IF i.info1='Y' THEN
            l_marginal_empl := 'J';
          END IF;
        ELSIF i.aei_information_category = 'NL_WMR' THEN
          IF i.info1='Y' THEN
            l_wm_old_rule := 'J';
          END IF;
--LC 2010--end
          --
        END IF;
      END IF;
    END LOOP;
  ELSE
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_surrogate_key is not null');
    FOR i in csr_get_ass_extra_info(p_surrogate_key) LOOP
      --IF p_eff_date BETWEEN i.start_date AND NVL(i.end_date,to_date('31124712','ddmmyyyy')) THEN--IF i.start_date <= p_end_date  AND NVL(i.end_date,p_end_date) >= p_start_date THEN
        IF i.aei_information_category = 'NL_LBR' THEN
          l_labour_rel_code := i.info1;
        ELSIF i.aei_information_category = 'NL_INF' THEN
          l_ins_duty_code := i.info1;
        ELSIF i.aei_information_category = 'NL_TML' THEN
          l_FZ_Code := i.info1;
        ELSIF i.aei_information_category = 'NL_LHI' THEN
          l_handicapped_code := i.info1;
        ELSIF i.aei_information_category = 'NL_SII' THEN
            l_wao_insured := 'N';
            l_ww_insured  := 'N';
            l_zw_insured  := 'N';
          IF i.info1 IN ('AMI','WAO') THEN
            l_wao_insured := 'J';
          END IF;
          IF i.info1 IN ('AMI','WW') THEN
            l_ww_insured := 'J';
          END IF;
          IF  i.info1 IN ('AMI','ZW') THEN
            l_zw_insured := 'J';
          END IF;
          IF  i.info1 IN ('AMI','ZVW') THEN
            l_zvw_situation := i.info2;
          END IF;
--LC 2010--begin
        ELSIF i.aei_information_category = 'NL_MEI' THEN
          IF i.info1='Y' THEN
            l_marginal_empl := 'J';
          END IF;
        ELSIF i.aei_information_category = 'NL_WMR' THEN
          IF i.info1='Y' THEN
            l_wm_old_rule := 'J';
          END IF;
--LC 2010--end
        END IF;
      --END IF;
    END LOOP;
  END IF;


    --rsahai--Labour Handicapped discount - New Code 7 Changes : 2009 changes - START

    OPEN csr_all_ass_extra_info_code6_9(p_assignment_id);
    FETCH csr_all_ass_extra_info_code6_9 INTO l_handicapped_code_new;
    CLOSE csr_all_ass_extra_info_code6_9;

    OPEN csr_get_ass_bdate(p_assignment_id);
    FETCH csr_get_ass_bdate INTO l_bdate, l_age;
    CLOSE csr_get_ass_bdate;

    IF l_handicapped_code_new is NULL AND l_age >= 62 AND l_age < 65
    THEN
     l_handicapped_code := '7';
    ELSIF l_handicapped_code_new IS NOT NULL
    THEN
     l_handicapped_code := l_handicapped_code_new;
    END IF;

    --rsahai--Labour Handicapped discount - New Code 7 Changes : 2009 changes - END
   --
  p_labour_rel_code  := l_labour_rel_code ;
  p_ins_duty_code    := l_ins_duty_code   ;
  p_FZ_Code          := l_FZ_Code         ;
  p_handicapped_code := l_handicapped_code;
  p_wao_insured      := NVL(l_wao_insured,'N');
  p_ww_insured       := NVL(l_ww_insured,'N');
  p_zw_insured       := NVL(l_zw_insured,'N');
  p_zvw_situation    := l_zvw_situation;
  p_marginal_empl    := l_marginal_empl; /*LC 2010*/
  p_wm_old_rule      := l_wm_old_rule;   /*LC 2010*/
  p_chk := 'N';
  IF nvl(p_labour_rel_code,'X')  <> nvl(l_labour_rel_code1,'X')  OR
     nvl(p_ins_duty_code,'X')    <> nvl(l_ins_duty_code1,'X')    OR
     nvl(p_FZ_Code,'X')          <> nvl(l_FZ_Code1,'X')          OR
     nvl(p_handicapped_code,'X') <> nvl(l_handicapped_code1,'X') OR
     nvl(p_wao_insured,'X')      <> nvl(l_wao_insured1,'X')      OR
     nvl(p_ww_insured,'X')       <> nvl(l_ww_insured1,'X')       OR
     nvl(p_zw_insured,'X')       <> nvl(l_zw_insured1,'X')       OR
     nvl(p_zvw_situation,'X')    <> nvl(l_zvw_situation1,'X')    OR
     nvl(p_marginal_empl,'X')    <> nvl(l_marginal_empl1,'X')    OR /*LC 2010*/
     nvl(p_wm_old_rule,'X')      <> nvl(l_wm_old_rule1,'X')      THEN/*LC 2010*/
     p_chk := 'Y';
  END IF;
  --
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_labour_rel_code '||p_labour_rel_code );
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_ins_duty_code   '||p_ins_duty_code   );
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_FZ_Code         '||p_FZ_Code         );
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_handicapped_code'||p_handicapped_code);
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_wao_insured     '||p_wao_insured     );
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_ww_insured      '||p_ww_insured      );
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_zw_insured      '||p_zw_insured      );
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_zvw_situation   '||p_zvw_situation   );
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_marginal_empl   '||p_marginal_empl   );
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######~~ p_wm_old_rule     '||p_wm_old_rule   );
--
END get_assignment_extra_info;
--
--------------------------------------------------------------------------------
-- COPY
--------------------------------------------------------------------------------
PROCEDURE copy(p_copy_from IN OUT NOCOPY pay_interpreter_pkg.t_detailed_output_table_type
              ,p_from      IN            NUMBER
              ,p_copy_to   IN OUT NOCOPY pay_interpreter_pkg.t_detailed_output_table_type
              ,p_to        IN            NUMBER) IS
BEGIN
  --
  p_copy_to(p_to).dated_table_id    := p_copy_from(p_from).dated_table_id;
  p_copy_to(p_to).datetracked_event := p_copy_from(p_from).datetracked_event;
  p_copy_to(p_to).surrogate_key     := p_copy_from(p_from).surrogate_key;
  p_copy_to(p_to).update_type       := p_copy_from(p_from).update_type;
  p_copy_to(p_to).column_name       := p_copy_from(p_from).column_name;
  p_copy_to(p_to).effective_date    := p_copy_from(p_from).effective_date;
  p_copy_to(p_to).old_value         := p_copy_from(p_from).old_value;
  p_copy_to(p_to).new_value         := p_copy_from(p_from).new_value;
  p_copy_to(p_to).change_values     := p_copy_from(p_from).change_values;
  p_copy_to(p_to).proration_type    := p_copy_from(p_from).proration_type;
  p_copy_to(p_to).change_mode       := p_copy_from(p_from).change_mode;
  p_copy_to(p_to).element_entry_id  := p_copy_from(p_from).element_entry_id;
  --
END copy;
--
--------------------------------------------------------------------------------
-- SORT_CHANGES
--------------------------------------------------------------------------------
PROCEDURE sort_changes(p_detail_tab IN OUT NOCOPY pay_interpreter_pkg.t_detailed_output_table_type) IS
  --
  l_temp_table pay_interpreter_pkg.t_detailed_output_table_type;
  --
BEGIN
  IF p_detail_tab.count > 0 THEN
    FOR i IN p_detail_tab.first..p_detail_tab.last LOOP
      --x :=  i + 1;
      FOR j IN i+1..p_detail_tab.last LOOP
        IF p_detail_tab(j).effective_date < p_detail_tab(i).effective_date THEN
          copy(p_detail_tab,j,l_temp_table,1);
          copy(p_detail_tab,i,p_detail_tab,j);
          copy(l_temp_table,1,p_detail_tab,i);
        END IF;
      END LOOP;
    END LOOP;
  END IF;
  --
  /*IF p_detail_tab.count > 0 THEN
  FOR i IN p_detail_tab.first..p_detail_tab.last LOOP
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######~Record    : '||i);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######dated_table_id    : '||p_detail_tab(i).dated_table_id);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######datetracked_event : '||p_detail_tab(i).datetracked_event);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######surrogate_key     : '||p_detail_tab(i).surrogate_key);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######update_type     	: '||p_detail_tab(i).update_type);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######column_name       : '||p_detail_tab(i).column_name);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######effective_date    : '||p_detail_tab(i).effective_date);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######old_value         : '||p_detail_tab(i).old_value);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######new_value         : '||p_detail_tab(i).new_value);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######change_values     : '||p_detail_tab(i).change_values);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######proration_type    : '||p_detail_tab(i).proration_type);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######change_mode       : '||p_detail_tab(i).change_mode);
    --##--Fnd_file.put_line(FND_FILE.LOG,'#######element_entry_id  : '||p_detail_tab(i).element_entry_id);
  END LOOP;
  END IF;*/
  --
END sort_changes;
--
--------------------------------------------------------------------------------
-- GET_ASSIGNMENT_CHANGES
--------------------------------------------------------------------------------
PROCEDURE get_assignment_changes(p_assignment_id  IN            NUMBER
                                ,p_start_date     IN            DATE
                                ,p_end_date       IN            DATE
                                ,p_ass_start_date IN            DATE
                                ,p_event_group_id IN            pay_event_groups.event_group_id%TYPE
                                ,p_detail_tab     IN OUT NOCOPY pay_interpreter_pkg.t_detailed_output_table_type) IS
  CURSOR csr_get_element_entries(c_assignment_id NUMBER
                                ,c_eff_date      DATE) IS
  SELECT peef.element_entry_id
  FROM   pay_element_entries_f peef
        ,pay_element_types_f   pet
  WHERE  pet.element_name     IN ('Holiday Coupons','Incidental Income Decrease','Additional Allowance','Company Car Private Usage')
  AND    pet.legislation_code = 'NL'
  AND    peef.assignment_id   = c_assignment_id
  AND    peef.element_type_id = pet.element_type_id
  AND    c_eff_date     BETWEEN peef.effective_start_date
                            AND peef.effective_end_date
  AND    c_eff_date     BETWEEN pet.effective_start_date
                            AND pet.effective_end_date;
  --
  CURSOR csr_get_table_id(c_table_name VARCHAR2) IS
  SELECT dated_table_id
  FROM   pay_dated_tables
  WHERE  TABLE_NAME = c_table_name;
  --
  CURSOR csr_get_eit_effective_date(c_a_extra_info_id NUMBER) IS
  SELECT fnd_date.canonical_to_date(aei_information1) start_date
  FROM   per_assignment_extra_info
  WHERE  assignment_extra_info_id = c_a_extra_info_id
  AND    aei_information_category IN ('NL_LBR','NL_INF','NL_TML','NL_LHI','NL_SII'--);
,'NL_MEI','NL_WMR'); /*LC 2010*/
  --
  l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
  l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
  l_detail_tab          pay_interpreter_pkg.t_detailed_output_table_type;
  l_pro_type_tab        pay_interpreter_pkg.t_proration_type_table_type;
  --
  l_index  NUMBER;
  l_cnt    NUMBER;
  l_eff_date DATE;
  l_table1 pay_dated_tables.dated_table_id%type;
  l_table2 pay_dated_tables.dated_table_id%type;
  l_table3 pay_dated_tables.dated_table_id%type;
  --
BEGIN
  --
  OPEN csr_get_table_id('PAY_ELEMENT_ENTRIES_F');
  FETCH csr_get_table_id INTO l_table1;
  CLOSE csr_get_table_id;
  --
  OPEN csr_get_table_id('PAY_ELEMENT_ENTRY_VALUES_F');
  FETCH csr_get_table_id INTO l_table2;
  CLOSE csr_get_table_id;
  --
  OPEN csr_get_table_id('PER_ASSIGNMENT_EXTRA_INFO');
  FETCH csr_get_table_id INTO l_table3;
  CLOSE csr_get_table_id;
  --
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######dated_table_id   PAY_ELEMENT_ENTRIES_F : '||l_table1);
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######dated_table_id   PAY_ELEMENT_ENTRY_VALUES_F : '||l_table1);
  --##--Fnd_file.put_line(FND_FILE.LOG,'#######dated_table_id   PER_ASSIGNMENT_EXTRA_INFO : '||l_table1);
  l_cnt := 1;
  FOR c_rec IN csr_get_element_entries(p_assignment_id,p_end_date) LOOP
    --##--Fnd_file.put_line(FND_FILE.LOG,'####### Calling interpretor for element_entry_id : '||c_rec.element_entry_id);
    BEGIN
    pay_interpreter_pkg.entry_affected(
       p_element_entry_id      => c_rec.element_entry_id
      ,p_assignment_action_id  => NULL
      ,p_assignment_id         => p_assignment_id
      ,p_mode                  => 'REPORTS'
      ,p_process               => 'P'
      ,p_event_group_id        => p_event_group_id
      ,p_process_mode          => 'ENTRY_CREATION_DATE' --ENTRY_CREATION_DATE
      ,p_start_date            => p_start_date - 1
      ,p_end_date              => p_end_date + 1
      ,t_detailed_output       => l_detail_tab
      ,t_proration_dates       => l_proration_dates
      ,t_proration_change_type => l_proration_changes
      ,t_proration_type        => l_pro_type_tab );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_detail_tab.delete;
            --##--Fnd_file.put_line(FND_FILE.LOG,'####### in Exception NO_DATA_FOUND Elements');
        WHEN OTHERS THEN
            l_detail_tab.delete;
            --##--Fnd_file.put_line(FND_FILE.LOG,'####### in Exception OTHERS Elements');
    END;
    --
    l_index := p_detail_tab.count;
    --##--Fnd_file.put_line(FND_FILE.LOG,'####### No of records fetched  : '||l_detail_tab.count);
    IF l_detail_tab.count <> 0 THEN
      FOR i IN l_detail_tab.first..l_detail_tab.last LOOP
        IF (l_cnt = 1 OR (l_detail_tab(i).dated_table_id = l_table1 OR l_detail_tab(i).dated_table_id = l_table2))
           AND l_detail_tab(i).effective_date <= p_end_date  THEN
          --##--Fnd_file.put_line(FND_FILE.LOG,'####### Table  : '||l_detail_tab(i).dated_table_id);
          --##--Fnd_file.put_line(FND_FILE.LOG,'####### column : '||l_detail_tab(i).column_name);
          IF l_detail_tab(i).column_name LIKE 'AEI_INFORMATION%' OR
            l_detail_tab(i).dated_table_id = l_table3 THEN
            OPEN  csr_get_eit_effective_date(l_detail_tab(i).surrogate_key);
            FETCH csr_get_eit_effective_date INTO l_eff_date;
            IF csr_get_eit_effective_date%FOUND THEN
              --##--Fnd_file.put_line(FND_FILE.LOG,'####### Element entry effective date  : '||l_eff_date);
              IF l_eff_date <= p_end_date AND l_eff_date >= to_date('01-01-'||to_char(p_start_date,'YYYY'),'dd-mm-yyyy') THEN
                l_index := l_index + 1;
                p_detail_tab(l_index).dated_table_id    := l_detail_tab(i).dated_table_id;
                p_detail_tab(l_index).datetracked_event := l_detail_tab(i).datetracked_event;
                p_detail_tab(l_index).surrogate_key     := l_detail_tab(i).surrogate_key;
                p_detail_tab(l_index).update_type       := l_detail_tab(i).update_type;
                p_detail_tab(l_index).column_name       := l_detail_tab(i).column_name;
                p_detail_tab(l_index).effective_date    := GREATEST(l_eff_date,p_ass_start_date);
                p_detail_tab(l_index).old_value         := l_detail_tab(i).old_value;
                p_detail_tab(l_index).new_value         := l_detail_tab(i).new_value;
                p_detail_tab(l_index).change_values     := l_detail_tab(i).change_values;
                p_detail_tab(l_index).proration_type    := l_detail_tab(i).proration_type;
                p_detail_tab(l_index).change_mode       := l_detail_tab(i).change_mode;
              END IF;
            END IF;
            CLOSE csr_get_eit_effective_date;
          ELSIF l_detail_tab(i).effective_date >= to_date('01-01-'||to_char(p_start_date,'YYYY'),'dd-mm-yyyy') THEN
            l_index := l_index + 1;
            p_detail_tab(l_index).dated_table_id    := l_detail_tab(i).dated_table_id;
            p_detail_tab(l_index).datetracked_event := l_detail_tab(i).datetracked_event;
            p_detail_tab(l_index).surrogate_key     := l_detail_tab(i).surrogate_key;
            p_detail_tab(l_index).update_type       := l_detail_tab(i).update_type;
            p_detail_tab(l_index).column_name       := l_detail_tab(i).column_name;
            p_detail_tab(l_index).effective_date    := GREATEST(l_detail_tab(i).effective_date,p_ass_start_date);
            p_detail_tab(l_index).old_value         := l_detail_tab(i).old_value;
            p_detail_tab(l_index).new_value         := l_detail_tab(i).new_value;
            p_detail_tab(l_index).change_values     := l_detail_tab(i).change_values;
            p_detail_tab(l_index).proration_type    := l_detail_tab(i).proration_type;
            p_detail_tab(l_index).change_mode       := l_detail_tab(i).change_mode;
            IF (l_detail_tab(i).dated_table_id = l_table1 OR l_detail_tab(i).dated_table_id = l_table2) THEN
              p_detail_tab(l_index).element_entry_id:= l_detail_tab(i).element_entry_id;
            END IF;
          END IF;
        END IF;
      END LOOP;
    END IF;
    l_cnt := l_cnt + 1;
  END LOOP;
  IF l_cnt = 1 THEN
    --##--Fnd_file.put_line(FND_FILE.LOG,'####### Calling interpretor for assignment : '||p_assignment_id);
    BEGIN
    pay_interpreter_pkg.entry_affected(
       p_element_entry_id      => NULL
      ,p_assignment_action_id  => NULL
      ,p_assignment_id         => p_assignment_id
      ,p_mode                  => 'REPORTS'
      ,p_process               => 'P'
      ,p_event_group_id        => p_event_group_id
      ,p_process_mode          => 'ENTRY_CREATION_DATE' --ENTRY_CREATION_DATE
      ,p_start_date            => p_start_date
      ,p_end_date              => p_end_date
      ,t_detailed_output       => l_detail_tab
      ,t_proration_dates       => l_proration_dates
      ,t_proration_change_type => l_proration_changes
      ,t_proration_type        => l_pro_type_tab );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_detail_tab.delete;
            --##--Fnd_file.put_line(FND_FILE.LOG,'####### in Exception NO_DATA_FOUND ');
        WHEN OTHERS THEN
            l_detail_tab.delete;
            --##--Fnd_file.put_line(FND_FILE.LOG,'####### in Exception OTHERS ');
    END;
    --##--Fnd_file.put_line(FND_FILE.LOG,'####### No of records fetched  : '||l_detail_tab.count);
    --
    l_index := p_detail_tab.count;
    IF l_detail_tab.count <> 0 THEN
      FOR i IN l_detail_tab.first..l_detail_tab.last LOOP
        --##--Fnd_file.put_line(FND_FILE.LOG,'####### Table  : '||l_detail_tab(i).dated_table_id);
        --##--Fnd_file.put_line(FND_FILE.LOG,'####### column : '||l_detail_tab(i).column_name);
        IF l_detail_tab(i).effective_date <= p_end_date  THEN
          IF l_detail_tab(i).column_name LIKE 'AEI_INFORMATION%'
             OR l_detail_tab(i).dated_table_id = l_table3 THEN
            --Fnd_file.put_line(FND_FILE.LOG,'~~~~~ get_assignment_changes 14');
            OPEN  csr_get_eit_effective_date(l_detail_tab(i).surrogate_key);
            FETCH csr_get_eit_effective_date INTO l_eff_date;
            IF csr_get_eit_effective_date%FOUND THEN
              --##--Fnd_file.put_line(FND_FILE.LOG,'####### Element entry effective date  : '||l_eff_date);
              IF l_eff_date <= p_end_date AND l_eff_date >= to_date('01-01-'||to_char(p_start_date,'YYYY'),'dd-mm-yyyy') THEN
                l_index := l_index + 1;
                p_detail_tab(l_index).dated_table_id    := l_detail_tab(i).dated_table_id;
                p_detail_tab(l_index).datetracked_event := l_detail_tab(i).datetracked_event;
                p_detail_tab(l_index).surrogate_key     := l_detail_tab(i).surrogate_key;
                p_detail_tab(l_index).update_type       := l_detail_tab(i).update_type;
                p_detail_tab(l_index).column_name       := l_detail_tab(i).column_name;
                p_detail_tab(l_index).effective_date    := GREATEST(l_eff_date,p_ass_start_date);
                p_detail_tab(l_index).old_value         := l_detail_tab(i).old_value;
                p_detail_tab(l_index).new_value         := l_detail_tab(i).new_value;
                p_detail_tab(l_index).change_values     := l_detail_tab(i).change_values;
                p_detail_tab(l_index).proration_type    := l_detail_tab(i).proration_type;
                p_detail_tab(l_index).change_mode       := l_detail_tab(i).change_mode;
              END IF;
            END IF;
            CLOSE csr_get_eit_effective_date;
          ELSIF l_detail_tab(i).effective_date >= to_date('01-01-'||to_char(p_start_date,'YYYY'),'dd-mm-yyyy') THEN
            l_index := l_index + 1;
            p_detail_tab(l_index).dated_table_id    := l_detail_tab(i).dated_table_id;
            p_detail_tab(l_index).datetracked_event := l_detail_tab(i).datetracked_event;
            p_detail_tab(l_index).surrogate_key     := l_detail_tab(i).surrogate_key;
            p_detail_tab(l_index).update_type       := l_detail_tab(i).update_type;
            p_detail_tab(l_index).column_name       := l_detail_tab(i).column_name;
            p_detail_tab(l_index).effective_date    := GREATEST(l_detail_tab(i).effective_date,p_ass_start_date);
            p_detail_tab(l_index).old_value         := l_detail_tab(i).old_value;
            p_detail_tab(l_index).new_value         := l_detail_tab(i).new_value;
            p_detail_tab(l_index).change_values     := l_detail_tab(i).change_values;
            p_detail_tab(l_index).proration_type    := l_detail_tab(i).proration_type;
            p_detail_tab(l_index).change_mode       := l_detail_tab(i).change_mode;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;
 EXCEPTION
    WHEN OTHERS THEN
        --Fnd_file.put_line(FND_FILE.LOG,' in Exception get_assignment_changes');
        NULL;
END get_assignment_changes;
--
--------------------------------------------------------------------------------
-- GET_ASSIGNMENT_CHANGES
--------------------------------------------------------------------------------
PROCEDURE remove_withdrawal_period_chg(p_rec_changes_init IN            Rec_Changes
                                     ,p_rec_changes      IN OUT NOCOPY Rec_Changes) IS
l_period_start_date DATE;
l_cnt NUMBER;
BEGIN
  p_rec_changes.delete;
  l_period_start_date := TO_DATE('01-01-0001','dd-mm-yyyy');
  l_cnt := 1;
  FOR i IN p_rec_changes_init.first..p_rec_changes_init.last LOOP
    --Fnd_file.put_line(FND_FILE.LOG,' '||p_rec_changes_init(i).effective_date||' update type'||p_rec_changes_init(i).update_type||'  retro'|| p_rec_changes_init(i).retro||' period start '||p_rec_changes_init(i).period_start_date);
    IF p_rec_changes_init(i).effective_date >= to_date('01-01-2006','dd-mm-yyyy') THEN
    IF p_rec_changes_init(i).period_start_date <> l_period_start_date THEN
       -- OR p_rec_changes_init(i).retro = 'WITHDRAWAL' THEN
      p_rec_changes(l_cnt).dated_table_id    := p_rec_changes_init(i).dated_table_id;
      p_rec_changes(l_cnt).datetracked_event := p_rec_changes_init(i).datetracked_event;
      p_rec_changes(l_cnt).surrogate_key     := p_rec_changes_init(i).surrogate_key;
      p_rec_changes(l_cnt).update_type       := p_rec_changes_init(i).update_type;
      p_rec_changes(l_cnt).column_name       := p_rec_changes_init(i).column_name;
      p_rec_changes(l_cnt).effective_date    := p_rec_changes_init(i).effective_date;
      p_rec_changes(l_cnt).old_value         := p_rec_changes_init(i).old_value;
      p_rec_changes(l_cnt).new_value         := p_rec_changes_init(i).new_value;
      p_rec_changes(l_cnt).change_values     := p_rec_changes_init(i).change_values;
      p_rec_changes(l_cnt).proration_type    := p_rec_changes_init(i).proration_type;
      p_rec_changes(l_cnt).change_mode       := p_rec_changes_init(i).change_mode;
      p_rec_changes(l_cnt).period_start_date := p_rec_changes_init(i).period_start_date;
      p_rec_changes(l_cnt).period_end_date   := p_rec_changes_init(i).period_end_date;
      p_rec_changes(l_cnt).retro             := p_rec_changes_init(i).retro;
      l_cnt := l_cnt + 1;
      IF p_rec_changes_init(i).retro = 'WITHDRAWAL' THEN
        l_period_start_date := p_rec_changes_init(i).period_start_date;
      END IF;
    END IF;
    END IF;
  END LOOP;
END remove_withdrawal_period_chg;
--------------------------------------------------------------------------------
-- CHK_EVENTS
--------------------------------------------------------------------------------
PROCEDURE chk_events(p_assactid       NUMBER
                    ,p_assignment_id  NUMBER
                    ,p_effective_date DATE
                    ,p_business_gr_id NUMBER
                    ,l_tax_unit_id    NUMBER
                    ,p_chk_start_date DATE
                    ,p_chk_end_date   DATE
                    ,p_payroll_type   VARCHAR2) IS
  --
  --
  CURSOR csr_get_emp_data(c_assignment_id  NUMBER
                         ,c_effective_date DATE) IS
  SELECT pap.person_id
        ,pap.national_identifier sofi_number
        ,pap.employee_number
        ,pap.nationality
        ,pap.date_of_birth dob
        ,pap.pre_name_adjunct prefix
        ,pap.last_name
        ,UPPER(replace(replace(pap.per_information1,'.',''),' ','')) initials
        ,decode(pap.sex,'M',1,'F',2,NULL) gender
        ,paaf.assignment_id
        ,paaf.change_reason
        ,paaf.assignment_number
        ,paaf.assignment_sequence
        ,paaf.employment_category
        ,paaf.employee_category
        ,paaf.collective_agreement_id
        ,paaf.effective_start_date
        ,paaf.soft_coding_keyflex_id
        ,paaf.assignment_status_type_id
        ,paaf.payroll_id
        ,paaf.primary_flag
  FROM   per_all_assignments_f paaf
        ,per_all_people_f pap
  WHERE  paaf.assignment_id          = c_assignment_id
  AND    paaf.person_id              = pap.person_id
  AND    c_effective_date   BETWEEN paaf.effective_start_date
                                AND paaf.effective_end_date
  AND    c_effective_date   BETWEEN pap.effective_start_date
                                AND pap.effective_end_date;
  --
  /*CURSOR csr_emp_termination_date(c_assignment_id NUMBER) IS
  SELECT pps.date_start emp_start_date
        ,pps.actual_termination_date emp_termination_date
        ,paaf.primary_flag
  FROM   per_all_assignments_f paaf
        ,per_periods_of_service pps
  WHERE  paaf.assignment_id          = c_assignment_id
  AND    pps.person_id               = paaf.person_id
  AND    pps.period_of_service_id = paaf.period_of_service_id;*/
  --
  CURSOR csr_get_cao_code(c_collective_agreement_id NUMBER) IS
  SELECT pca.cag_information1
  FROM   per_collective_agreements pca
  WHERE  pca.collective_agreement_id = c_collective_agreement_id
  AND    pca.cag_information_category= 'NL';
  --
  CURSOR csr_chk_emp_reported(c_assignment_id NUMBER) IS
  SELECT 'Y'
  FROM   DUAL
  WHERE  EXISTS(SELECT /*+ ORDERED */ 1
                 FROM   pay_assignment_actions paa
                       ,pay_payroll_actions ppa
                       ,pay_action_interlocks pai
                       ,pay_assignment_actions pal
                       ,pay_payroll_actions ppl
                 WHERE  paa.assignment_id = c_assignment_id
                 AND    paa.payroll_action_id = ppa.payroll_action_id
                 AND    ppa.report_type       = 'NL_WAGES_REP_ARCHIVE'
                 AND    ppa.report_qualifier  = 'NL'
                 AND    ppa.report_category   = 'ARCHIVE'
                 AND    ppa.action_status     ='C'
                 AND    paa.assignment_action_id = pai.locked_action_id
                 AND    pai.locking_action_id    = pal.assignment_action_id
                 AND    pal.payroll_action_id    = ppl.payroll_action_id
                 AND    ppl.report_type      = 'NL_WAGES_REP_LOCK'
                 AND    ppl.report_qualifier = 'NL'
                 AND    ppl.report_category  = 'ARCHIVE'
                 AND    ppl.action_status    ='C');
  --
  --
  CURSOR csr_get_element_details(c_ass_act_id     NUMBER
                                ,c_effective_date DATE) IS
  SELECT  prr.rowid row_id
         ,prr.element_entry_id
         ,min(decode(piv.name, 'Report Type', rrv.RESULT_VALUE, null)) Retro_type
         ,min(decode(piv.name, 'Period', rrv.RESULT_VALUE, null)) Period
  FROM    pay_run_results prr
         ,pay_run_result_values rrv
         ,pay_input_values_f piv
         ,pay_element_types_f pet
  WHERE   prr.run_result_id        = rrv.run_result_id
  AND     rrv.input_value_id + 0   = piv.input_value_id
  AND     piv.element_type_id      = pet.element_type_id
  AND     prr.element_type_id      = pet.element_type_id
  AND     prr.assignment_action_id = c_ass_act_id
  AND     pet.element_name         = 'New Wage Report Override'
  AND     pet.legislation_code     = 'NL'
  AND     c_effective_date        BETWEEN piv.effective_start_date AND piv.effective_end_date
  AND     c_effective_date        BETWEEN pet.effective_start_date AND pet.effective_end_date
  GROUP BY prr.rowid
          ,prr.element_entry_id
  ORDER BY 4,3 DESC;
  --
  CURSOR csr_get_retro_periods(c_assignment_action_id NUMBER
                              ,c_date                 DATE) IS
  SELECT DISTINCT ptp.start_date start_date
        ,ptp.end_date end_date
  FROM   pay_run_results prr
        ,pay_element_entries_f pee
        ,pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,per_time_periods ptp
  WHERE  prr.assignment_action_id = paa.assignment_action_id
  AND    prr.element_type_id      = pee.element_type_id
  AND    pee.creator_type         IN ('RR','EE')
  AND    pee.assignment_id        = paa.assignment_id
  AND    paa.assignment_action_id = c_assignment_action_id
  AND    prr.start_date           > c_date
  AND    paa.payroll_action_id   = ppa.payroll_action_id
  AND    ptp.payroll_id          = ppa.payroll_id
  AND    prr.start_date           BETWEEN ptp.start_date and ptp.end_date
  ORDER  by 1;
  --
  /*CURSOR csr_get_corr_retro_periods(c_assignment_action_id NUMBER
                                   ,c_assignment_id        NUMBER
                                   ,c_effective_date       DATE) IS
  SELECT rr1.start_date  , rc.short_name,rr1.element_entry_id
        ,rr1.end_date
  FROM   pay_run_results rr1 -- Retro element
        ,pay_run_results rr2 -- Normal Element
        ,pay_element_span_usages esu
        ,pay_retro_component_usages rcu
        ,pay_retro_components rc
        ,pay_element_entries_f pee1
        ,pay_element_entries_f pee2
        ,pay_retro_assignments pra
        ,pay_retro_entries pre
  WHERE rr1.assignment_action_id = c_assignment_action_id
  AND   rr2.assignment_action_id = rr1.assignment_action_id
  AND   rr1.element_type_id = esu.retro_element_type_id
  AND   esu.retro_component_usage_id = rcu.retro_component_usage_id
  AND   rcu.creator_id = rr2.element_type_id
  AND  rcu.creator_type   = 'ET' -- check
  AND   rr1.element_entry_id = pee1.element_entry_id
  AND   pee1.creator_type  = 'RR'
  AND   pee1.creator_id  = pra.retro_assignment_action_id
  AND   pra.assignment_id = c_assignment_id
--  AND   pra.assignment_id = pee1.assignment_id
  AND   pra.retro_assignment_id = pre.retro_assignment_id
  AND   rr2.element_entry_id = pee2.element_entry_id
  AND   pee2.element_entry_id = pre.element_entry_id
  AND   pre.retro_component_id = rc.retro_component_id
  AND   rc.legislation_code = 'NL'
  AND   rc.short_name = 'Standard'
  AND   c_effective_date between pee1.effective_start_date and pee1.effective_end_date
  AND   c_effective_date between pee2.effective_start_date and pee2.effective_end_date;*/
  --
  CURSOR csr_get_corr_retro_periods(c_assignment_action_id NUMBER
                                   ,c_effective_date       DATE) IS
  SELECT DISTINCT ptp.start_date
        ,ptp.end_date
  FROM   pay_run_results rr1 -- Retro element
        ,pay_element_span_usages esu
        ,pay_retro_component_usages rcu
        ,pay_retro_components rc
        ,pay_element_entries_f pee1
        ,pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,per_time_periods ptp
  WHERE paa.assignment_action_id = c_assignment_action_id
  AND   rr1.assignment_action_id = paa.assignment_action_id
  AND   rr1.element_entry_id = pee1.element_entry_id
  AND   pee1.creator_type  = 'RR'
  AND   rr1.element_type_id = esu.retro_element_type_id
  AND   esu.retro_component_usage_id = rcu.retro_component_usage_id
  AND   rcu.creator_type   = 'ET' -- check
  AND   rcu.retro_component_id = rc.retro_component_id
  AND   rc.legislation_code = 'NL'
  AND   rc.short_name = 'Standard'
  AND   c_effective_date between pee1.effective_start_date and pee1.effective_end_date
  AND   paa.payroll_action_id   = ppa.payroll_action_id
  AND   ptp.payroll_id          = ppa.payroll_id
  AND   rr1.start_date           BETWEEN ptp.start_date and ptp.end_date
  ORDER BY 1;

  /*SELECT rr.start_date
        ,rr.end_date
  FROM   pay_run_results rr
        ,pay_element_span_usages esu
        ,pay_retro_component_usages rcu
        ,pay_retro_components rc
  WHERE rr.assignment_action_id = c_assignment_action_id
  AND   rr.element_type_id = esu.retro_element_type_id
  AND   esu.retro_component_usage_id = rcu.retro_component_usage_id
  AND   rcu.retro_component_id    = rc.retro_component_id
  AND   rc.legislation_code = 'NL'
  AND   rc.short_name = 'Standard';*/
  --
  CURSOR csr_get_assignment_action_id(c_assignment_id NUMBER
                                     ,c_date          DATE) IS
  SELECT max(paa.assignment_action_id) assignment_action_id
  FROM   pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,per_time_periods ptp
  WHERE  paa.assignment_id      = c_assignment_id
  AND    ppa.payroll_action_id  = paa.payroll_action_id
  AND    ppa.action_type        IN ('R','Q')
  AND    paa.ACTION_STATUS      = 'C'
  AND    ppa.ACTION_STATUS      = 'C'
  --AND    ppa.date_earned between c_start_date AND c_end_date;
  AND    ppa.time_period_id = ptp.time_period_id
  AND    c_date BETWEEN ptp.start_date AND ptp.end_date;
  --
  CURSOR csr_get_assignment_action_id2(c_assignment_id NUMBER
                                      ,c_date          DATE) IS
  SELECT max(paa.assignment_action_id) assignment_action_id
  FROM   pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,per_time_periods ptp
  WHERE  paa.assignment_id      = c_assignment_id
  AND    ppa.payroll_action_id  = paa.payroll_action_id
  AND    ppa.action_type        IN ('R','Q','I','B')
  AND    paa.ACTION_STATUS      = 'C'
  AND    ppa.ACTION_STATUS      = 'C'
--  AND    ppa.date_earned between c_start_date AND c_end_date;
  AND    ppa.time_period_id = ptp.time_period_id
  AND    c_date BETWEEN ptp.start_date AND ptp.end_date;
  --
  CURSOR csr_get_shared_types(c_code           VARCHAR2
                            ,c_business_gr_id NUMBER
                            ,c_lookup         VARCHAR2) IS
  SELECT business_group_id,system_type_cd
  FROM   per_shared_types
  WHERE  lookup_type        = c_lookup --'NL_NATIONALITY'
  AND    information1       = c_code
  AND    (business_group_id = c_business_gr_id
          OR business_group_id is NULL)
  ORDER BY 1;
  --
  CURSOR csr_get_period(c_payroll_id NUMBER,c_date DATE) IS
  SELECT ptp.start_date,ptp.end_date
  FROM   per_time_periods ptp
  WHERE  ptp.payroll_id = c_payroll_id
  AND    c_date between ptp.start_date and ptp.end_date;
  --
  CURSOR csr_get_table_id(c_table_name VARCHAR2) IS
  SELECT dated_table_id
  FROM   pay_dated_tables
  WHERE  TABLE_NAME = c_table_name; -- in ('PAY_ELEMENT_ENTRY_VALUES_F','PAY_ELEMENT_ENTRIES_F');
  --
  CURSOR csr_get_element_det(c_element_name   VARCHAR2
                            ,c_input_val_name VARCHAR2
                            ,c_assignment_id  NUMBER
                            ,c_eff_date       DATE) IS
  SELECT peev.screen_entry_value
  FROM   pay_element_types_f pet
        ,pay_input_values_f piv
        ,pay_element_entries_f peef
        ,pay_element_entry_values_f peev
  WHERE  pet.element_name = c_element_name
  AND    pet.element_type_id = piv.element_type_id
  AND    piv.name = c_input_val_name
  AND    pet.legislation_code  = 'NL'
  AND    piv.legislation_code  = 'NL'
  AND    peef.assignment_id    = c_assignment_id
  AND    peef.element_entry_id = peev.element_entry_id
  AND    peef.element_type_id  = pet.element_type_id
  AND    peev.input_value_id   = piv.input_value_id
  AND    c_eff_date            BETWEEN piv.effective_start_date
                                   AND piv.effective_end_date
  AND    c_eff_date            BETWEEN pet.effective_start_date
                                   AND pet.effective_end_date
  AND    c_eff_date            BETWEEN peev.effective_start_date
                                   AND peev.effective_end_date
  AND    c_eff_date            BETWEEN peef.effective_start_date
                                   AND peef.effective_end_date;
  --
  CURSOR csr_get_element_name2(c_element_entry_value_id NUMBER
                              ,c_eff_date               DATE) IS
  SELECT pet.element_name
        ,peev.screen_entry_value
  FROM   pay_element_types_f pet
        ,pay_element_entries_f peef
        ,pay_element_entry_values_f peev
  WHERE  peev.element_entry_value_id = c_element_entry_value_id
  AND    peev.element_entry_id       = peef.element_entry_id
  AND    peef.element_type_id        = pet.element_type_id
  AND    pet.legislation_code        = 'NL'
  AND    c_eff_date            BETWEEN pet.effective_start_date
                                   AND pet.effective_end_date
  AND    c_eff_date            BETWEEN peev.effective_start_date
                                   AND peev.effective_end_date
  AND    c_eff_date            BETWEEN peef.effective_start_date
                                   AND peef.effective_end_date;
  --
  CURSOR csr_get_element_name1(c_element_entry_id NUMBER
                              ,c_eff_date         DATE) IS
  SELECT pet.element_name
        ,peev.screen_entry_value
  FROM   pay_element_types_f pet
        ,pay_element_entries_f peef
        ,pay_element_entry_values_f peev
  WHERE  peef.element_entry_id = c_element_entry_id
  AND    peev.element_entry_id = peef.element_entry_id
  AND    peef.element_type_id  = pet.element_type_id
  AND    pet.legislation_code        = 'NL'
  AND    c_eff_date      BETWEEN pet.effective_start_date
                             AND pet.effective_end_date
  AND    c_eff_date      BETWEEN peev.effective_start_date
                             AND peev.effective_end_date
  AND    c_eff_date      BETWEEN peef.effective_start_date
                             AND peef.effective_end_date; /*assuming one input value*/
  --
  CURSOR csr_get_eit_cao(c_assignment_id NUMBER) IS
  SELECT aei_information5
  FROM   per_assignment_extra_info
  WHERE  assignment_id = c_assignment_id
  AND    aei_information_category IN ('NL_CADANS_INFO');
  --
  CURSOR csr_ass_start_date(c_assignment_id NUMBER) IS
  SELECT min(effective_start_date)
        --,decode(max(effective_end_date),to_date('31-12-4712','dd-mm-yyyy'),null,max(effective_end_date))
  FROM   per_all_assignments_F paaf
        ,PER_ASSIGNMENT_STATUS_TYPES  ast
  WHERE  paaf.assignment_id = c_assignment_id
  AND    paaf.assignment_status_type_id  = ast.assignment_status_type_id
  AND    ast.per_system_status = 'ACTIVE_ASSIGN';
  --
  CURSOR csr_ass_end_date(c_assignment_id NUMBER) IS
  SELECT decode(max(effective_end_date),to_date('31-12-4712','dd-mm-yyyy'),null,max(effective_end_date))
  FROM   per_all_assignments_F paaf
        ,PER_ASSIGNMENT_STATUS_TYPES  ast
  WHERE  paaf.assignment_id = c_assignment_id
  AND    paaf.assignment_status_type_id  = ast.assignment_status_type_id
  AND    ast.per_system_status <> 'TERM_ASSIGN';
  --
  CURSOR csr_ass_end_date2(c_assignment_id NUMBER) IS
  SELECT min(effective_start_date)
  FROM   per_all_assignments_F paaf
        ,PER_ASSIGNMENT_STATUS_TYPES  ast
  WHERE  paaf.assignment_id = c_assignment_id
  AND    paaf.assignment_status_type_id  = ast.assignment_status_type_id
  AND    ast.per_system_status = 'TERM_ASSIGN';

  /* 8328995 */
  cursor csr_numiv_override(p_asg_id number) is
   select aei_information1 NUMIV_OVERRIDE
   from per_assignment_extra_info
   where assignment_id = p_asg_id
     and aei_information_category = 'NL_NUMIV_OVERRIDE';
  l_numiv_override NUMBER;

  -- /*LC 2010 */ begin
  CURSOR csr_get_small_job_detail(c_assignment_action_id  NUMBER
                                 ,c_eff_date       DATE) IS
    SELECT prrv.result_value
    FROM   pay_run_result_values prrv
          ,pay_input_values_f piv
          ,pay_element_types_f pet
          ,pay_run_results prr
    WHERE  pet.element_name = 'Small Job Indicator'
    AND    pet.element_type_id = piv.element_type_id
    AND    piv.name = 'Exempt Small Jobs'
    AND    pet.legislation_code  = 'NL'
    AND    piv.legislation_code  = 'NL'
    AND    prrv.input_value_id   = piv.input_value_id
    AND    prr.run_result_id     = prrv.run_result_id
    AND    prr.element_type_id   = pet.element_type_id
    AND    prr.assignment_action_id = c_assignment_action_id
    AND    prr.status in ('P','PA')
    AND    c_eff_date            BETWEEN piv.effective_start_date
                                     AND piv.effective_end_date
    AND    c_eff_date            BETWEEN pet.effective_start_date
                                     AND pet.effective_end_date;

    CURSOR csr_get_other_assignments(c_assg_id           NUMBER
                                    ,c_start_date        DATE
                                    ,c_end_date          DATE
                                    ,c_business_group_id NUMBER
                                    ,c_tax_unit_id       NUMBER
                                    ,c_payroll_type      VARCHAR2) IS
      SELECT  distinct asl.assignment_id assignment_id
      FROM   per_all_assignments_f asl
            ,per_all_assignments_f asl2
            ,pay_all_payrolls_f ppf
            ,pay_payroll_actions ppa
            ,pay_assignment_actions paa
            ,per_time_periods  ptp
      WHERE  asl.person_id = asl2.person_id
      AND    asl2.assignment_id = c_assg_id
      AND    ppf.payroll_id = asl.payroll_id
      AND    ((ppf.period_type = 'Calendar Month' AND c_payroll_type = 'MONTH') OR
              (ppf.period_type = 'Week' AND c_payroll_type = 'WEEK') OR
              (ppf.period_type = 'Lunar Month' AND c_payroll_type = 'LMONTH'))
      AND    ppf.payroll_id = ppa.payroll_id
      AND    ppa.action_type in ('R','Q')
      AND    ppa.action_status = 'C'
      AND    paa.source_action_id IS NULL
      AND    paa.tax_unit_id = c_tax_unit_id
      AND    ppa.business_group_id = c_business_group_id
      AND    ppa.time_period_id  = ptp.time_period_id
      AND    c_end_date     BETWEEN ptp.start_date
                                AND ptp.end_date
      AND    ppa.payroll_action_id = paa.payroll_action_id
      AND    paa.assignment_id = asl.assignment_id
      AND    asl.effective_start_date <= c_end_date
      AND    asl.effective_end_date   >= c_start_date
      AND    c_end_date       BETWEEN ppf.effective_start_date
                                  AND ppf.effective_end_date;
  -- /*LC 2010 */ end
  --
  --soft_coding_keyflex_id
  l_nationality         per_shared_types.INFORMATION1%type;
  l_assignment_catg     per_shared_types.INFORMATION1%type;
  l_assignment_catg_old per_shared_types.INFORMATION1%type;
  l_emp_rec           csr_get_emp_data%rowtype;
  l_rec_changes       Rec_Changes;
  l_rec_changes_init  Rec_Changes;
  l_master_action_info_id pay_action_information.action_information_id%type;
  l_action_info_id pay_action_information.action_information_id%TYPE;
  l_period_start_date DATE;
  l_period_end_date   DATE;
  l_rec_start_date    DATE;
  l_emp_end_date      DATE;
  -- SCL Segment variables
  l_income_code       hr_soft_coding_keyflex.segment1%type;
  l_work_pattern      hr_soft_coding_keyflex.segment1%type;
  l_wage_tax_discount hr_soft_coding_keyflex.segment1%type;
  l_wage_tax_table    hr_soft_coding_keyflex.segment1%type;
  l_wage_aow          hr_soft_coding_keyflex.segment1%type;
  l_wage_wajong       hr_soft_coding_keyflex.segment1%type;
  l_emp_loan          hr_soft_coding_keyflex.segment1%type;
  l_transportation    hr_soft_coding_keyflex.segment1%type;
  --
  l_labour_rel_code   PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_ins_duty_code     PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_FZ_Code           PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_handicapped_code  PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_wao_insured       PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_ww_insured        PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zw_insured        PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zvw_situation     PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zvw_defaulted     VARCHAR2(1);
  l_zvw_small_jobs    VARCHAR2(1);/* LC 2010*/
  l_marginal_empl     PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;/* LC 2010*/
  l_wm_old_rule       PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;/* LC 2010*/
  --
  l_small_job         pay_run_result_values.result_value%TYPE; /*LC 2010*/
  l_assg_small_job    pay_run_result_values.result_value%TYPE; /*LC 2010*/
  --
  l_detail_tab          pay_interpreter_pkg.t_detailed_output_table_type;
  l_event_group_id      pay_event_groups.event_group_id%TYPE;
  l_assignment_id       NUMBER;
  l_event_group_name  VARCHAR2(50)  := 'NL_WAGES_REPORT_EVG';
  l_chk VARCHAR2(2);
  l_chg_pending VARCHAR2(2);
  --l_chk_primary VARCHAR2(2);
  l_chk_emp_reported VARCHAR2(1);
  l_archive_emp_info VARCHAR2(1);
  p_date DATE;
  l_retro VARCHAR2(10);
  l_type  VARCHAR2(10);
  l_ovn     pay_action_information.object_version_number%type;
  l_cao_code per_collective_agreements.CAG_INFORMATION1%type;
  l_old_cao_code per_collective_agreements.CAG_INFORMATION1%type;
  l_bal_value Bal_Value;
  l_nom_bal_value Bal_Value;
  l_ret_table Ret_Table;
  l_assignment_action_id NUMBER;
  l_master_assignment_action_id  NUMBER;
  l_other_assignment_action_id   NUMBER; /*LC 2010*/
  l_retro_type VARCHAR2(10);
  l_retro_done VARCHAR2(10);
  ele_end_date DATE;
  l_surrogate_key NUMBER;
  l_bg   NUMBER;
  l_table1 pay_dated_tables.dated_table_id%type;
  l_table2 pay_dated_tables.dated_table_id%type;
  l_table3 pay_dated_tables.dated_table_id%type;
  l_ass_start_date DATE;
  l_ass_end_date DATE;
  --
  l_holiday_coupen  pay_element_entry_values_f.screen_entry_value%TYPE;
  l_income_increase pay_element_entry_values_f.screen_entry_value%TYPE;
  l_add_allowance   pay_element_entry_values_f.screen_entry_value%TYPE;
  l_company_car_use pay_element_entry_values_f.screen_entry_value%TYPE;
  l_val             pay_element_entry_values_f.screen_entry_value%TYPE;
  l_element_name    VARCHAR2(30);
  --
  l_cnt1 NUMBER;
  l_cnt2 NUMBER;
  l_cnt3 NUMBER;
  r_index NUMBER;
  --
  l_srg_flag VARCHAR2(1);
  l_corr_used VARCHAR2(1);
  --
  CURSOR get_scl_id(c_assignment_id NUMBER
                   ,c_start_date    DATE) IS
  SELECT paaf.soft_coding_keyflex_id
  FROM   per_all_assignments_f paaf
  WHERE  assignment_id = c_assignment_id
  AND    c_start_date BETWEEN paaf.effective_start_date
                      AND     paaf.effective_end_date;
  --
  CURSOR csr_get_col_agreement_id (c_assignment_id NUMBER
                                  ,c_eff_date      DATE) IS
  SELECT collective_agreement_id
  FROM   per_All_assignments_F
  WHERE  assignment_id = c_assignment_id
  AND    c_eff_date BETWEEN effective_start_date AND effective_end_date;
  --
  l_scl_id    per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  --
  l_initial_flag    VARCHAR2(1);
  l_emp_seq per_all_Assignments_f.assignment_number%type;
  --
BEGIN
  --Fnd_file.put_line(FND_FILE.LOG,' Start chk_events');
  --Fnd_file.put_line(FND_FILE.LOG,' Assignment ID :'||p_assignment_id);
  l_assignment_id  := p_assignment_id;
  -- Correction Record Starts
  l_event_group_id := pqp_utilities.get_event_group_id(p_business_group_id    => p_business_gr_id
                                                      ,p_event_group_name     => l_event_group_name);
  -- Fetch assignment start date and end date
  --OPEN  csr_emp_termination_date(l_assignment_id);
  --FETCH csr_emp_termination_date INTO l_ass_start_date,l_ass_end_date,l_chk_primary;
  --CLOSE csr_emp_termination_date;
  --IF NVL(l_chk_primary,'N') <> 'Y' THEN
  OPEN  csr_ass_start_date(l_assignment_id);
  FETCH csr_ass_start_date INTO l_ass_start_date;
  CLOSE csr_ass_start_date;
  --
  OPEN  csr_ass_end_date(l_assignment_id);
  FETCH csr_ass_end_date INTO l_ass_end_date;
  CLOSE csr_ass_end_date;
  --
  /*IF l_ass_start_date IS NULL AND l_ass_end_date IS NULL THEN -- Bug - 5868094
    OPEN  csr_ass_end_date2(l_assignment_id);
    FETCH csr_ass_end_date2 INTO l_ass_end_date;
    CLOSE csr_ass_end_date2;
    l_ass_start_date := l_ass_end_date;
  END IF;*/
  --
  --END IF;
  --Invoke the date track interpreter only for Monthly Payroll
  IF p_payroll_type = 'MONTH' OR p_payroll_type = 'LMONTH' THEN
    --Fnd_file.put_line(FND_FILE.LOG,' Call Interpretor '||l_assignment_id);
    get_assignment_changes(l_assignment_id
                          ,p_chk_start_date
                          ,p_chk_end_date
                          ,l_ass_start_date
                          ,l_event_group_id
                          ,l_detail_tab);
    --Fnd_file.put_line(FND_FILE.LOG,' Total Change Records :'||l_detail_tab.COUNT);
    --Fnd_file.put_line(FND_FILE.LOG,' Change Records for Assignment   : '||l_assignment_id);
    sort_changes(l_detail_tab);
    --
    OPEN csr_get_table_id('PAY_ELEMENT_ENTRIES_F');
    FETCH csr_get_table_id INTO l_table1;
    CLOSE csr_get_table_id;
    --
    OPEN csr_get_table_id('PAY_ELEMENT_ENTRY_VALUES_F');
    FETCH csr_get_table_id INTO l_table2;
    CLOSE csr_get_table_id;
    --
    OPEN csr_get_table_id('PER_ASSIGNMENT_EXTRA_INFO');
    FETCH csr_get_table_id INTO l_table3;
    CLOSE csr_get_table_id;
    --
    OPEN  csr_get_emp_data(l_assignment_id,LEAST(p_chk_end_date,NVL(l_ass_end_date,p_chk_end_date)));
    FETCH csr_get_emp_data INTO l_emp_rec;
    CLOSE csr_get_emp_data;
    --
    IF l_emp_rec.change_reason NOT IN ('NL1','NL2','NL3','NL4','NL5') THEN
        l_emp_rec.change_reason := NULL;
    END IF;
    --
    l_period_start_date := to_date('01-01-0001','dd-mm-yyyy');
    l_period_end_date   := to_date('01-01-0001','dd-mm-yyyy');
    l_rec_start_date    := to_date('01-01-0001','dd-mm-yyyy');
    --
    r_index := 1;
    --
    l_master_assignment_action_id := NULL;
    l_assignment_action_id := NULL;
    OPEN  csr_get_assignment_action_id(l_assignment_id,p_chk_start_date);
    FETCH csr_get_assignment_action_id INTO l_master_assignment_action_id;
    CLOSE csr_get_assignment_action_id;
    --
    --Fnd_file.put_line(FND_FILE.LOG,' Checking retro for Assignment_action_id :'||l_master_assignment_action_id);
    --
    l_retro_done := 'N';
    IF l_master_assignment_action_id IS NOT NULL THEN
      FOR l_element_rec in csr_get_element_details(l_master_assignment_action_id,p_chk_end_date) LOOP
        l_retro_type := 'HR';
        ele_end_date := fnd_date.canonical_to_date(l_element_rec.period);
        --
        IF l_element_rec.Retro_type = 'WITHDRAWAL' AND l_element_rec.period IS NOT NULL THEN
          OPEN  csr_get_period(l_emp_rec.payroll_id, ele_end_date);
          FETCH csr_get_period INTO l_period_start_date,l_period_end_date;
          CLOSE csr_get_period;
          --Fnd_file.put_line(FND_FILE.LOG,' WITHDRAWAL For Period : '||l_period_start_date);
          IF l_rec_start_date < l_period_start_date THEN
            l_ret_table(r_index).start_date := l_period_start_date;
            l_ret_table(r_index).end_date   := l_period_end_date;
            l_ret_table(r_index).retro_type := l_element_rec.retro_type;--l_retro_type;
            r_index := r_index + 1;
            l_rec_start_date := l_period_start_date;
          END IF;
        ELSIF l_element_rec.Retro_type = 'CORRECTION' AND g_retro_type = 'OLD' THEN
          IF l_retro_done = 'N' THEN
            FOR csr_retro_rec IN csr_get_retro_periods(l_master_assignment_action_id,l_rec_start_date) LOOP
              IF l_element_rec.period IS NULL THEN
                l_ret_table(r_index).start_date := csr_retro_rec.start_date;
                l_ret_table(r_index).end_date   := csr_retro_rec.end_date;
                l_ret_table(r_index).retro_type := 'PAY';--l_retro_type;
                r_index := r_index + 1;
                l_rec_start_date := csr_retro_rec.start_date;
                l_retro_done := 'Y';
              ELSIF csr_retro_rec.end_date = ele_end_date THEN
                l_ret_table(r_index).start_date := csr_retro_rec.start_date;
                l_ret_table(r_index).end_date   := csr_retro_rec.end_date;
                l_ret_table(r_index).retro_type := 'PAY';--l_retro_type;
                r_index := r_index + 1;
                l_rec_start_date := csr_retro_rec.start_date;
              END IF;
            END LOOP;
          END IF;
        END IF;
      END LOOP;
    END IF;
    --
    IF g_retro_type = 'NEW' THEN
      FOR csr_retro_rec in csr_get_corr_retro_periods(l_master_assignment_action_id,p_chk_end_date) LOOP
        l_ret_table(r_index).start_date := csr_retro_rec.start_date;
        l_ret_table(r_index).end_date   := csr_retro_rec.end_date;
        l_ret_table(r_index).retro_type := 'PAY';--l_retro_type;
        r_index := r_index + 1;
      END LOOP;
    END IF;
    --
    --Fnd_file.put_line(FND_FILE.LOG,'  Retro table count : '||l_ret_table.count);
    --Fnd_file.put_line(FND_FILE.LOG,'  Hr table count : '||l_detail_tab.count);
    --
    l_cnt3 := 0;
    l_cnt1 := 1;
    l_cnt2 := 1;
    --
    l_period_start_date := to_date('01-01-0001','dd-mm-yyyy');
    l_period_end_date   := to_date('01-01-0001','dd-mm-yyyy');
    --
    --Fnd_file.put_line(FND_FILE.LOG,'  Merging retro and  HR data table: ');
    LOOP
      EXIT WHEN l_detail_tab.count < l_cnt1 OR l_ret_table.count < l_cnt2;
      l_cnt3 := l_cnt3 + 1;
      IF l_detail_tab(l_cnt1).effective_date <  l_ret_table(l_cnt2).start_date THEN
        IF l_detail_tab(l_cnt1).effective_date < l_period_start_date
               OR l_detail_tab(l_cnt1).effective_date > l_period_end_date THEN
                --
                --Fnd_file.put_line(FND_FILE.LOG,'  Payroll : '||l_emp_rec.payroll_id);
                IF l_emp_rec.payroll_id IS NULL THEN
                  EXIT;
                END IF;
                --
                OPEN  csr_get_period(l_emp_rec.payroll_id, l_detail_tab(l_cnt1).effective_date);
                FETCH csr_get_period INTO l_period_start_date,l_period_end_date;
                CLOSE csr_get_period;
                --
                l_retro := 'HR';
                --
        END IF;
        --
        l_rec_changes_init(l_cnt3).dated_table_id    := l_detail_tab(l_cnt1).dated_table_id;
        l_rec_changes_init(l_cnt3).datetracked_event := l_detail_tab(l_cnt1).datetracked_event;
        l_rec_changes_init(l_cnt3).surrogate_key     := l_detail_tab(l_cnt1).surrogate_key;
        l_rec_changes_init(l_cnt3).update_type       := l_detail_tab(l_cnt1).update_type;
        l_rec_changes_init(l_cnt3).column_name       := l_detail_tab(l_cnt1).column_name;
        l_rec_changes_init(l_cnt3).effective_date    := l_detail_tab(l_cnt1).effective_date;
        l_rec_changes_init(l_cnt3).old_value         := l_detail_tab(l_cnt1).old_value;
        l_rec_changes_init(l_cnt3).new_value         := l_detail_tab(l_cnt1).new_value;
        l_rec_changes_init(l_cnt3).change_values     := l_detail_tab(l_cnt1).change_values;
        l_rec_changes_init(l_cnt3).proration_type    := l_detail_tab(l_cnt1).proration_type;
        l_rec_changes_init(l_cnt3).change_mode       := l_detail_tab(l_cnt1).change_mode;
        l_rec_changes_init(l_cnt3).period_start_date := l_period_start_date;
        l_rec_changes_init(l_cnt3).period_end_date   := l_period_end_date;
        l_rec_changes_init(l_cnt3).retro             := l_retro;
        --
        l_cnt1 := l_cnt1 + 1;
        --
      ELSIF l_detail_tab(l_cnt1).effective_date >  l_ret_table(l_cnt2).end_date THEN
        l_rec_changes_init(l_cnt3).dated_table_id    := NULL;
        l_rec_changes_init(l_cnt3).datetracked_event := NULL;
        l_rec_changes_init(l_cnt3).surrogate_key     := NULL;
        l_rec_changes_init(l_cnt3).update_type       := 'RETRO';
        l_rec_changes_init(l_cnt3).column_name       := NULL;
        l_rec_changes_init(l_cnt3).effective_date    := l_ret_table(l_cnt2).start_date;
        l_rec_changes_init(l_cnt3).old_value         := NULL;
        l_rec_changes_init(l_cnt3).new_value         := NULL;
        l_rec_changes_init(l_cnt3).change_values     := NULL;
        l_rec_changes_init(l_cnt3).proration_type    := NULL;
        l_rec_changes_init(l_cnt3).change_mode       := NULL;
        l_rec_changes_init(l_cnt3).period_start_date := l_ret_table(l_cnt2).start_date;
        l_rec_changes_init(l_cnt3).period_end_date   := l_ret_table(l_cnt2).end_date;
        l_rec_changes_init(l_cnt3).retro             := l_ret_table(l_cnt2).retro_type;
        l_period_start_date := l_ret_table(l_cnt2).start_date;
        l_period_end_date   := l_ret_table(l_cnt2).end_date;
        l_retro             := l_ret_table(l_cnt2).retro_type;
        l_cnt2 := l_cnt2 + 1;
      ELSE
        l_rec_changes_init(l_cnt3).dated_table_id    := l_detail_tab(l_cnt1).dated_table_id;
        l_rec_changes_init(l_cnt3).datetracked_event := l_detail_tab(l_cnt1).datetracked_event;
        l_rec_changes_init(l_cnt3).surrogate_key     := l_detail_tab(l_cnt1).surrogate_key;
        l_rec_changes_init(l_cnt3).update_type       := l_detail_tab(l_cnt1).update_type;
        l_rec_changes_init(l_cnt3).column_name       := l_detail_tab(l_cnt1).column_name;
        l_rec_changes_init(l_cnt3).effective_date    := l_detail_tab(l_cnt1).effective_date;
        l_rec_changes_init(l_cnt3).old_value         := l_detail_tab(l_cnt1).old_value;
        l_rec_changes_init(l_cnt3).new_value         := l_detail_tab(l_cnt1).new_value;
        l_rec_changes_init(l_cnt3).change_values     := l_detail_tab(l_cnt1).change_values;
        l_rec_changes_init(l_cnt3).proration_type    := l_detail_tab(l_cnt1).proration_type;
        l_rec_changes_init(l_cnt3).change_mode       := l_detail_tab(l_cnt1).change_mode;
        l_rec_changes_init(l_cnt3).period_start_date := l_ret_table(l_cnt2).start_date;
        l_rec_changes_init(l_cnt3).period_end_date   := l_ret_table(l_cnt2).end_date;
        l_rec_changes_init(l_cnt3).retro             := l_ret_table(l_cnt2).retro_type;
        l_period_start_date := l_ret_table(l_cnt2).start_date;
        l_period_end_date   := l_ret_table(l_cnt2).end_date;
        l_retro             := l_ret_table(l_cnt2).retro_type;
        l_cnt1 := l_cnt1 + 1;
        l_cnt2 := l_cnt2 + 1;
      END IF;
    END LOOP;
    --
    LOOP EXIT WHEN l_detail_tab.count < l_cnt1 ;
      IF l_detail_tab(l_cnt1).effective_date < l_period_start_date
         OR l_detail_tab(l_cnt1).effective_date > l_period_end_date THEN
        -- chk if employee doesn't have a payroll
        --Fnd_file.put_line(FND_FILE.LOG,' Payroll : '||l_emp_rec.payroll_id);
        IF l_emp_rec.payroll_id IS NULL THEN
          EXIT;
        END IF;
        --
        OPEN  csr_get_period(l_emp_rec.payroll_id, l_detail_tab(l_cnt1).effective_date);
        FETCH csr_get_period INTO l_period_start_date,l_period_end_date;
        CLOSE csr_get_period;
        --
        l_retro := 'HR';
        --
      END IF;
      --
      l_cnt3 := l_cnt3 + 1;
      l_rec_changes_init(l_cnt3).dated_table_id    := l_detail_tab(l_cnt1).dated_table_id;
      l_rec_changes_init(l_cnt3).datetracked_event := l_detail_tab(l_cnt1).datetracked_event;
      l_rec_changes_init(l_cnt3).surrogate_key     := l_detail_tab(l_cnt1).surrogate_key;
      l_rec_changes_init(l_cnt3).update_type       := l_detail_tab(l_cnt1).update_type;
      l_rec_changes_init(l_cnt3).column_name       := l_detail_tab(l_cnt1).column_name;
      l_rec_changes_init(l_cnt3).effective_date    := l_detail_tab(l_cnt1).effective_date;
      l_rec_changes_init(l_cnt3).old_value         := l_detail_tab(l_cnt1).old_value;
      l_rec_changes_init(l_cnt3).new_value         := l_detail_tab(l_cnt1).new_value;
      l_rec_changes_init(l_cnt3).change_values     := l_detail_tab(l_cnt1).change_values;
      l_rec_changes_init(l_cnt3).proration_type    := l_detail_tab(l_cnt1).proration_type;
      l_rec_changes_init(l_cnt3).change_mode       := l_detail_tab(l_cnt1).change_mode;
      l_rec_changes_init(l_cnt3).period_start_date := l_period_start_date;
      l_rec_changes_init(l_cnt3).period_end_date   := l_period_end_date;
      l_rec_changes_init(l_cnt3).retro             := l_retro;
      --
      l_cnt1 := l_cnt1 + 1;
    END LOOP;
    --
    LOOP EXIT WHEN  l_ret_table.count < l_cnt2;
      --
      l_cnt3 := l_cnt3 + 1;
      l_rec_changes_init(l_cnt3).dated_table_id    := NULL;
      l_rec_changes_init(l_cnt3).datetracked_event := NULL;
      l_rec_changes_init(l_cnt3).surrogate_key     := NULL;
      l_rec_changes_init(l_cnt3).update_type       := 'RETRO';
      l_rec_changes_init(l_cnt3).column_name       := NULL;
      l_rec_changes_init(l_cnt3).effective_date    := l_ret_table(l_cnt2).start_date;
      l_rec_changes_init(l_cnt3).old_value         := NULL;
      l_rec_changes_init(l_cnt3).new_value         := NULL;
      l_rec_changes_init(l_cnt3).change_values     := NULL;
      l_rec_changes_init(l_cnt3).proration_type    := NULL;
      l_rec_changes_init(l_cnt3).change_mode       := NULL;
      l_rec_changes_init(l_cnt3).period_start_date := l_ret_table(l_cnt2).start_date;
      l_rec_changes_init(l_cnt3).period_end_date   := l_ret_table(l_cnt2).end_date;
      l_rec_changes_init(l_cnt3).retro             := l_ret_table(l_cnt2).retro_type;
      l_cnt2 := l_cnt2 + 1;
      --
    END LOOP;
    --Fnd_file.put_line(FND_FILE.LOG,' Total Records in Merged Table : '||l_rec_changes_init.count);
    --
    IF l_rec_changes_init.count <> 0 THEN
      remove_withdrawal_period_chg(l_rec_changes_init,l_rec_changes);
    END IF;
    --
  END IF; -- IF p_payroll_type = 'MONTH' OR 'LMONTH'
  --
  l_emp_end_date := NULL;
  IF l_ass_end_date <= p_chk_end_date THEN
    l_emp_end_date := l_ass_end_date;
  END IF;
  p_date := LEAST(p_chk_end_date,NVL(l_emp_end_date,p_chk_end_date));
  --l_start_date :=
  IF l_rec_changes.COUNT <> 0 THEN
     p_date := l_rec_changes(1).effective_date;
  END IF;
  --Fnd_file.put_line(FND_FILE.LOG,' Get employee Data on    : '||p_date);
  OPEN  csr_get_emp_data(l_assignment_id,p_date);
  FETCH csr_get_emp_data INTO l_emp_rec;
  CLOSE csr_get_emp_data;
  --
  l_emp_seq := NULL;
  IF p_chk_end_date  >= TO_DATE('01012007','DDMMYYYY') THEN
    l_emp_seq := l_emp_rec.assignment_sequence;
  END IF;
  --
  IF l_emp_rec.change_reason NOT IN ('NL1','NL2','NL3','NL4','NL5') THEN
      l_emp_rec.change_reason := NULL;
  END IF;
  --
  OPEN  csr_get_shared_types(l_emp_rec.nationality,p_business_gr_id,'NL_NATIONALITY');
  FETCH csr_get_shared_types INTO l_bg,l_nationality;
  CLOSE csr_get_shared_types;
  --
  IF  g_contract_code_mapping = 'NL_EMPLOYMENT_CATG' THEN
      OPEN  csr_get_shared_types(l_emp_rec.employment_category,p_business_gr_id,g_contract_code_mapping);
      FETCH csr_get_shared_types INTO l_bg,l_assignment_catg;
      CLOSE csr_get_shared_types;
  ELSE
      OPEN  csr_get_shared_types(l_emp_rec.employee_category,p_business_gr_id,g_contract_code_mapping);
      FETCH csr_get_shared_types INTO l_bg,l_assignment_catg;
      CLOSE csr_get_shared_types;
  END IF;
  --
  l_income_code       := 'N';
  l_work_pattern      := 'N';
  l_wage_tax_discount := 'N';
  l_wage_tax_table    := 'N';
  l_wage_aow          := 'N';
  l_wage_wajong       := 'N';
  l_emp_loan          := 'N';
  l_transportation    := 'N';
  --Fnd_file.put_line(FND_FILE.LOG,' Get scl Data '||l_emp_rec.soft_coding_keyflex_id);
  get_scl_data(l_emp_rec.soft_coding_keyflex_id
              ,p_chk_end_date
              ,l_income_code
              ,l_work_pattern      -- specific income code.
              ,l_wage_tax_discount
              --,l_company_car_use
              ,l_wage_tax_table
              ,l_wage_aow
              ,l_wage_wajong
              ,l_emp_loan
              ,l_transportation
              ,l_chk);
  --
  l_surrogate_key  := NULL;
  --Fnd_file.put_line(FND_FILE.LOG,' Get Assignment EIT Data :'||l_assignment_id||' l_surrogate_key :'||l_surrogate_key);
  get_assignment_extra_info(l_assignment_id  -- pick data for p_date
                           ,l_surrogate_key
                           ,p_date
                           ,p_chk_start_date
                           ,p_chk_end_date
                           ,l_labour_rel_code
                           ,l_ins_duty_code
                           ,l_FZ_Code
                           ,l_handicapped_code
                           ,l_wao_insured
                           ,l_ww_insured
                           ,l_zw_insured
                           ,l_zvw_situation
                           ,l_marginal_empl /* LC 2010*/
                           ,l_wm_old_rule   /* LC 2010*/
                           ,l_chk);
  --LC 2010--begin
  l_zvw_small_jobs := NULL;
  l_small_job := NULL;
  FOR assignments IN csr_get_other_assignments(p_assignment_id
                                              ,p_chk_start_date
                                              ,p_chk_end_date
                                              ,p_business_gr_id
                                              ,l_tax_unit_id
                                              ,p_payroll_type)   LOOP

   l_other_assignment_action_id := NULL;
   l_assg_small_job := NULL;
    OPEN  csr_get_assignment_action_id(assignments.assignment_id,p_chk_start_date);
    FETCH csr_get_assignment_action_id INTO l_other_assignment_action_id;
    CLOSE csr_get_assignment_action_id;

    IF l_other_assignment_action_id IS NOT NULL THEN
      OPEN  csr_get_small_job_detail(l_other_assignment_action_id,p_date);
      FETCH csr_get_small_job_detail INTO l_assg_small_job;
      CLOSE csr_get_small_job_detail;
    END IF;

    IF l_assg_small_job IS NOT NULL THEN
      IF l_assg_small_job = 'N' THEN
        l_small_job := 'N';
        EXIT;
      ELSIF (l_small_job = 'F' OR l_small_job IS NULL) AND l_assg_small_job = 'F' THEN
        l_small_job := 'F';
      END IF;
    END IF;
  END LOOP;

  IF l_small_job = 'F' THEN
    IF l_zvw_situation <> 'J' OR l_zvw_situation IS NULL THEN
      l_zvw_situation := 'J';
      l_zvw_small_jobs := 'D';  --Defaulted
    END IF;
    IF l_ins_duty_code <> 'F' THEN
      l_ins_duty_code := l_ins_duty_code||'F'; --Append F
    END IF;
  ELSIF l_small_job = 'N' AND l_zvw_situation ='J' THEN
    l_zvw_small_jobs := 'W';  --Warning
  END IF;
  --LC 2010--end
  --
  l_zvw_defaulted := NULL;
  IF l_zvw_situation IS NULL THEN
    l_zvw_situation := 'A';
    l_zvw_defaulted := 'Y';
  END IF;
  --
  OPEN  csr_get_element_det('Holiday Coupons','Receiving Coupons',l_assignment_id,p_date);
  FETCH csr_get_element_det INTO l_holiday_coupen;
  CLOSE csr_get_element_det;
  IF l_holiday_coupen = 'Y' THEN
    l_holiday_coupen := 'J';
  END IF;
  --
  OPEN  csr_get_element_det('Incidental Income Decrease','Decrease Code',l_assignment_id,p_date);
  FETCH csr_get_element_det INTO l_income_increase;
  CLOSE csr_get_element_det;
  --
  OPEN  csr_get_element_det('Additional Allowance','Receiving Allowance',l_assignment_id,p_date);
  FETCH csr_get_element_det INTO l_add_allowance;
  CLOSE csr_get_element_det;
  IF p_chk_end_date  >= TO_DATE('01012007','DDMMYYYY') THEN
    l_add_allowance := NULL;
  ELSIF l_add_allowance = 'Y' THEN
    l_add_allowance := 'J';
  END IF;
  --
  OPEN  csr_get_element_det('Company Car Private Usage','Code Usage',l_assignment_id,p_date);
  FETCH csr_get_element_det INTO l_company_car_use;
  CLOSE csr_get_element_det;
  --
  --Fnd_file.put_line(FND_FILE.LOG,'  Get Element Data :');
  --Fnd_file.put_line(FND_FILE.LOG,'  l_holiday_coupen :'||l_holiday_coupen);
  --Fnd_file.put_line(FND_FILE.LOG,'  l_income_increase :'||l_income_increase);
  --Fnd_file.put_line(FND_FILE.LOG,'  l_add_allowance :'||l_add_allowance);
  --Fnd_file.put_line(FND_FILE.LOG,'  l_company_car_use :'||l_company_car_use);
  --
  IF l_emp_rec.collective_agreement_id IS NULL THEN
    OPEN  csr_get_eit_cao(l_emp_rec.assignment_id);
    FETCH csr_get_eit_cao INTO l_cao_code;
    CLOSE csr_get_eit_cao;
    --Fnd_file.put_line(FND_FILE.LOG,' Collective Agreement id null get from eit :'||l_cao_code);
  ELSE
    OPEN  csr_get_cao_code(l_emp_rec.collective_agreement_id);
    FETCH csr_get_cao_code INTO l_cao_code;
    CLOSE csr_get_cao_code;
    --Fnd_file.put_line(FND_FILE.LOG,' Collective Agreement id not null get from collective agreement table. :'||l_cao_code);
  END IF;
  l_old_cao_code := l_cao_code;
  l_archive_emp_info := 'Y';
  l_initial_flag     := 'N';
  --
  l_type := 'CORRECTION';
    --
  l_chk_emp_reported := 'N';
  l_period_start_date := TO_DATE('01-01-0001','dd-mm-yyyy');
  IF  l_rec_changes.COUNT <> 0 THEN
    FOR i IN l_rec_changes.FIRST..l_rec_changes.LAST LOOP
      --
      IF l_rec_changes(i).retro = 'WITHDRAWAL' THEN
        OPEN  csr_get_emp_data(l_assignment_id,l_rec_changes(i).effective_date);
        FETCH csr_get_emp_data INTO l_emp_rec;
        CLOSE csr_get_emp_data;
        --
        IF l_emp_rec.change_reason NOT IN ('NL1','NL2','NL3','NL4','NL5') THEN
            l_emp_rec.change_reason := NULL;
        END IF;
        --
        --Fnd_file.put_line(FND_FILE.LOG,' Creating NL_WR_EMPLOYMENT_INFO Infor Record for Type : WITHDRAWAL '||' Date :'||l_rec_changes(i).period_start_date);
        l_emp_end_date := NULL;
        IF l_ass_end_date <= l_rec_changes(i).period_end_date THEN
          l_emp_end_date := l_ass_end_date;
        END IF;
        --
        IF  l_rec_changes(i).effective_date BETWEEN p_chk_start_date AND p_chk_end_date THEN --p_chk_start_date >= l_period_start_date AND p_chk_start_date <= l_period_end_date THEN
          l_type := 'INITIAL';
        ELSIF l_chk_emp_reported = 'N' OR g_effective_date >= TO_DATE('01012007','DDMMYYYY')  THEN
          l_type := 'CORRECTION';
        ELSE
          l_type := 'CORRECT';
        END IF;
        --Fnd_file.put_line(FND_FILE.LOG,' l_type :'||l_type);
        --Fnd_file.put_line(FND_FILE.LOG,' g_effective_date :'||fnd_date.date_to_canonical(g_effective_date));
        --
	/* 8328995 */
	l_numiv_override:=null;
	OPEN csr_numiv_override(p_assignment_id);
	FETCH csr_numiv_override INTO l_numiv_override;
	CLOSE csr_numiv_override;

        pay_action_information_api.create_action_information (
             p_action_information_id        =>  l_master_action_info_id
            ,p_action_context_id            =>  p_assactid
            ,p_action_context_type          =>  'AAP'
            ,p_object_version_number        =>  l_ovn
            ,p_assignment_id                =>  l_emp_rec.assignment_id
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_tax_unit_id                  =>  l_tax_unit_id
            ,p_action_information_category  =>  'NL_WR_EMPLOYMENT_INFO'
            ,p_action_information1          =>  'WITHDRAWAL'
            ,p_action_information2          =>  fnd_date.date_to_canonical(GREATEST(l_rec_changes(i).period_start_date,trunc(l_rec_changes(i).period_end_date,'Y')))
            ,p_action_information3          =>  fnd_date.date_to_canonical(l_rec_changes(i).period_end_date)
            ,p_action_information4          =>  l_emp_rec.assignment_number
            ,p_action_information5          =>  l_emp_rec.employee_number
            ,p_action_information6          =>  l_emp_rec.change_reason
            ,p_action_information8          =>  l_emp_rec.sofi_number
            ,p_action_information7          =>  l_emp_rec.person_id
            ,p_action_information9          =>  l_emp_rec.Initials
            ,p_action_information10         =>  l_emp_rec.prefix
            ,p_action_information11         =>  l_emp_rec.last_name
            ,p_action_information12         =>  fnd_date.date_to_canonical(l_emp_rec.dob)
            ,p_action_information13         =>  l_nationality
            ,p_action_information14         =>  l_emp_rec.gender
            ,p_action_information15         =>  fnd_date.date_to_canonical(l_ass_start_date)-- assignment_start_date
            ,p_action_information16         =>  fnd_date.date_to_canonical(l_emp_end_date)
            ,p_action_information17         =>  l_rec_changes(i).retro
            ,p_action_information18         =>  nvl(l_numiv_override,l_emp_seq)); -- 8328995
      ELSE
        --
        --Fnd_file.put_line(FND_FILE.LOG,' Change in Table:'||l_rec_changes(i).dated_table_id||' Column '||l_rec_changes(i).column_name||' Type : '||l_rec_changes(i).update_type);
        --Fnd_file.put_line(FND_FILE.LOG,' Effective_date:'||l_rec_changes(i).effective_date||' start date '||l_rec_changes(i).period_start_date||' end date : '||l_rec_changes(i).period_end_date);
        IF l_type <> 'INITIAL' AND
           l_rec_changes(i).effective_date BETWEEN p_chk_start_date AND p_chk_end_date AND
           l_rec_changes(i).effective_date <> GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date) AND
           l_archive_emp_info <> 'N'THEN
           --
              --Fnd_file.put_line(FND_FILE.LOG,' Creating NL_WR_EMPLOYMENT_INFO Infor Record for Type : INITIAL'||' Date :'||l_rec_changes(i).period_start_date);
              l_emp_end_date := NULL;
              IF l_ass_end_date <= l_rec_changes(i).period_end_date THEN
                l_emp_end_date := l_ass_end_date;
              END IF;
              OPEN  csr_get_emp_data(l_assignment_id,NVL(l_emp_end_date,p_chk_end_date));
              FETCH csr_get_emp_data INTO l_emp_rec;
              CLOSE csr_get_emp_data;
              --
              IF l_emp_rec.change_reason NOT IN ('NL1','NL2','NL3','NL4','NL5') THEN
                  l_emp_rec.change_reason := NULL;
              END IF;
              --
	      /* 8328995 */
	        l_numiv_override:=null;
	        OPEN csr_numiv_override(p_assignment_id);
	        FETCH csr_numiv_override INTO l_numiv_override;
	        CLOSE csr_numiv_override;

              pay_action_information_api.create_action_information (
                   p_action_information_id        =>  l_master_action_info_id
                  ,p_action_context_id            =>  p_assactid
                  ,p_action_context_type          =>  'AAP'
                  ,p_object_version_number        =>  l_ovn
                  ,p_assignment_id                =>  l_emp_rec.assignment_id
                  ,p_effective_date               =>  p_effective_date
                  ,p_source_id                    =>  NULL
                  ,p_source_text                  =>  NULL
                  ,p_tax_unit_id                  =>  l_tax_unit_id
                  ,p_action_information_category  =>  'NL_WR_EMPLOYMENT_INFO'
                  ,p_action_information1          =>  'INITIAL'
                  ,p_action_information2          =>  fnd_date.date_to_canonical(GREATEST(l_rec_changes(i).period_start_date,trunc(l_rec_changes(i).period_end_date,'Y')))
                  ,p_action_information3          =>  fnd_date.date_to_canonical(l_rec_changes(i).period_end_date)
                  ,p_action_information4          =>  l_emp_rec.assignment_number
                  ,p_action_information5          =>  l_emp_rec.employee_number
                  ,p_action_information6          =>  l_emp_rec.change_reason
                  ,p_action_information8          =>  l_emp_rec.sofi_number
                  ,p_action_information7          =>  l_emp_rec.person_id
                  ,p_action_information9          =>  l_emp_rec.Initials
                  ,p_action_information10         =>  l_emp_rec.prefix
                  ,p_action_information11         =>  l_emp_rec.last_name
                  ,p_action_information12         =>  fnd_date.date_to_canonical(l_emp_rec.dob)
                  ,p_action_information13         =>  l_nationality
                  ,p_action_information14         =>  l_emp_rec.gender
                  ,p_action_information15         =>  fnd_date.date_to_canonical(l_ass_start_date)
                  ,p_action_information16         =>  fnd_date.date_to_canonical(l_emp_end_date)
                  ,p_action_information17         =>  l_rec_changes(i).retro
                  ,p_action_information18         =>  nvl(l_numiv_override,l_emp_seq)); -- 8328995
                --
                l_archive_emp_info := 'N';
                --
                OPEN  get_scl_id(l_emp_rec.assignment_id,GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date));
                FETCH get_scl_id INTO l_scl_id;
                CLOSE get_scl_id;
                --
                l_income_code       := 'N';
                l_work_pattern      := 'N';
                l_wage_tax_discount := 'N';
                l_wage_tax_table    := 'N';
                l_wage_aow          := 'N';
                l_wage_wajong       := 'N';
                l_emp_loan          := 'N';
                l_transportation    := 'N';
                --
                get_scl_data(l_scl_id --l_emp_rec.soft_coding_keyflex_id
                            ,p_chk_end_date
                            ,l_income_code
                            ,l_work_pattern      -- specific income code.
                            ,l_wage_tax_discount
                            --,l_company_car_use
                            ,l_wage_tax_table
                            ,l_wage_aow
                            ,l_wage_wajong
                            ,l_emp_loan
                            ,l_transportation
                            ,l_chk);
                --
                l_surrogate_key  := NULL;
                get_assignment_extra_info(l_assignment_id
                                         ,l_surrogate_key
                                         ,GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date)
                                         ,p_chk_start_date
                                         ,p_chk_end_date
                                         ,l_labour_rel_code
                                         ,l_ins_duty_code
                                         ,l_FZ_Code
                                         ,l_handicapped_code
                                         ,l_wao_insured
                                         ,l_ww_insured
                                         ,l_zw_insured
                                         ,l_zvw_situation
                                         ,l_marginal_empl /* LC 2010*/
                                         ,l_wm_old_rule   /* LC 2010*/
                                         ,l_chk);
                --LC 2010--begin
                l_zvw_small_jobs := NULL;
                l_small_job := NULL;
                FOR assignments IN csr_get_other_assignments(l_assignment_id
                                                            ,p_chk_start_date
                                                            ,p_chk_end_date
                                                            ,p_business_gr_id
                                                            ,l_tax_unit_id
                                                            ,p_payroll_type)   LOOP

                 l_other_assignment_action_id := NULL;
                 l_assg_small_job := NULL;
                  OPEN  csr_get_assignment_action_id(assignments.assignment_id,p_chk_start_date);
                  FETCH csr_get_assignment_action_id INTO l_other_assignment_action_id;
                  CLOSE csr_get_assignment_action_id;

                  IF l_other_assignment_action_id IS NOT NULL THEN
                    OPEN  csr_get_small_job_detail(l_other_assignment_action_id,GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date));
                    FETCH csr_get_small_job_detail INTO l_assg_small_job;
                    CLOSE csr_get_small_job_detail;
                  END IF;

                  IF l_assg_small_job IS NOT NULL THEN
                    IF l_assg_small_job = 'N' THEN
                      l_small_job := 'N';
                      EXIT;
                    ELSIF (l_small_job = 'F' OR l_small_job IS NULL) AND l_assg_small_job = 'F' THEN
                      l_small_job := 'F';
                    END IF;
                  END IF;
                END LOOP;

                  IF l_small_job = 'F' THEN
                    IF l_zvw_situation <> 'J' OR l_zvw_situation IS NULL THEN
                      l_zvw_situation := 'J';
                      l_zvw_small_jobs := 'D';  --Defaulted
                    END IF;
                    IF l_ins_duty_code <> 'F' THEN
                      l_ins_duty_code := l_ins_duty_code||'F'; --Append F
                    END IF;
                  ELSIF l_small_job = 'N' AND l_zvw_situation ='J' THEN
                    l_zvw_small_jobs := 'W';  --Warning
                  END IF;
                --LC 2010--end
                --
                l_zvw_defaulted := NULL;
                IF l_zvw_situation IS NULL THEN
                  l_zvw_situation := 'A';
                  l_zvw_defaulted := 'Y';
                END IF;
                --
                OPEN  csr_get_element_det('Holiday Coupons','Receiving Coupons',l_assignment_id,GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date));
                FETCH csr_get_element_det INTO l_holiday_coupen;
                CLOSE csr_get_element_det;
                IF l_holiday_coupen = 'Y' THEN
                  l_holiday_coupen := 'J';
                END IF;
                --
                OPEN  csr_get_element_det('Incidental Income Decrease','Decrease Code',l_assignment_id,GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date));
                FETCH csr_get_element_det INTO l_income_increase;
                CLOSE csr_get_element_det;
                --
                OPEN  csr_get_element_det('Additional Allowance','Receiving Allowance',l_assignment_id,GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date));
                FETCH csr_get_element_det INTO l_add_allowance;
                CLOSE csr_get_element_det;
                IF p_chk_end_date  >= TO_DATE('01012007','DDMMYYYY') THEN
                  l_add_allowance := NULL;
                ELSIF l_add_allowance = 'Y' THEN
                  l_add_allowance := 'J';
                END IF;
                --
                OPEN  csr_get_element_det('Company Car Private Usage','Code Usage',l_assignment_id,GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date));
                FETCH csr_get_element_det INTO l_company_car_use;
                CLOSE csr_get_element_det;
                --
                --Fnd_file.put_line(FND_FILE.LOG,' Creating NL_WR_INCOME_PERIOD Infor Record for Type : INITIAL');
                pay_action_information_api.create_action_information (
                    p_action_information_id        =>  l_action_info_id
                  , p_action_context_id            =>  p_assactid
                  , p_action_context_type          =>  'AAP'
                  , p_object_version_number        =>  l_ovn
                  , p_assignment_id                =>  l_emp_rec.assignment_id
                  , p_effective_date               =>  p_effective_date
                  , p_action_information_category  =>  'NL_WR_INCOME_PERIOD'
                  , p_tax_unit_id                  =>  l_tax_unit_id
                  , p_action_information1          =>  'INITIAL'
                  , p_action_information2          =>  l_master_action_info_id
                  , p_action_information5          =>  fnd_date.date_to_canonical(GREATEST(GREATEST(l_rec_changes(i).period_start_date,l_ass_start_date),trunc(l_rec_changes(i).period_end_date,'Y'))) /*** EOY 0708 ...Start Date Income Peiod ***/
                  , p_action_information6          =>  l_income_code
                  , p_action_information7          =>  l_labour_rel_code
                  , p_action_information8          =>  l_ins_duty_code
                  , p_action_information9          =>  l_assignment_catg
                  , p_action_information10         =>  l_FZ_Code
                  , p_action_information11         =>  l_work_pattern
                  , p_action_information12         =>  l_cao_code
                  , p_action_information13         =>  l_handicapped_code
                  , p_action_information14         =>  l_wage_tax_discount
                  , p_action_information15         =>  l_company_car_use
                  , p_action_information16         =>  l_wage_tax_table
                  , p_action_information17         =>  l_wao_insured
                  , p_action_information18         =>  l_ww_insured
                  , p_action_information19         =>  l_zw_insured
                  , p_action_information20         =>  NVL(l_zvw_situation,'A')
                  , p_action_information21         =>  l_holiday_coupen
                  , p_action_information22         =>  l_wage_aow
                  , p_action_information23         =>  l_wage_wajong
                  , p_action_information24         =>  l_emp_loan
                  , p_action_information25         =>  l_transportation
                  , p_action_information26         =>  l_income_increase
                  , p_action_information27         =>  l_add_allowance
                  , p_action_information28         =>  l_marginal_empl/* LC 2010*/
                  , p_action_information29         =>  l_wm_old_rule);/* LC 2010*/
                --
                l_initial_flag := 'Y';
                l_type         := 'INITIAL';
                --
        END IF;
        l_chk := 'Y';
        IF l_rec_changes(i).update_type = 'U' AND
           l_rec_changes(i).column_name = 'EFFECTIVE_START_DATE' AND
           l_rec_changes(i).dated_table_id NOT IN (l_table1,l_table2) AND
           l_chg_pending  = 'N' THEN
            l_chk := 'N';
        END IF;
        --
        IF l_chk = 'Y' THEN
          IF l_rec_changes(i).column_name = 'COLLECTIVE_AGREEMENT_ID' THEN
            l_emp_rec.collective_agreement_id := l_rec_changes(i).new_value;
            IF l_rec_changes(i).new_value IS NULL THEN
              OPEN  csr_get_col_agreement_id(l_assignment_id,l_rec_changes(i).effective_date);
              FETCH csr_get_col_agreement_id INTO l_emp_rec.collective_agreement_id;
              CLOSE csr_get_col_agreement_id;
            END IF;
            l_cao_code := NULL;
            OPEN  csr_get_cao_code(l_emp_rec.collective_agreement_id);
            FETCH csr_get_cao_code INTO l_cao_code;
            CLOSE csr_get_cao_code;
            IF NVL(l_old_cao_code,-1) = NVL(l_cao_code,-1) THEN
              l_chk := 'N';
            END IF;
            IF p_date = l_rec_changes(i).effective_date THEN
              l_chk := 'Y';
            END IF;
            l_old_cao_code := l_cao_code;
            --Fnd_file.put_line(FND_FILE.LOG,' Change in collective agreement ID New val :'||l_cao_code);
            --
          ELSIF l_rec_changes(i).column_name = 'CHANGE_REASON' THEN
            --Fnd_file.put_line(FND_FILE.LOG,' Change in change_reason New val :'||l_rec_changes(i).new_value);
            --l_emp_rec.CHANGE_REASON := l_rec_changes(i).new_value;
            IF l_rec_changes(i).new_value IN ('NL1','NL2','NL3','NL4','NL5') THEN
                l_emp_rec.CHANGE_REASON := l_rec_changes(i).new_value;
            END IF;
            IF l_chg_pending <> 'Y' THEN
                l_chk := 'N';
            ELSE
                l_chk := 'Y';
            END IF;
          --ELSIF l_rec_changes(i).column_name = 'EMPLOYMENT_CATEGORY' THEN
          ELSIF (g_contract_code_mapping = 'NL_EMPLOYMENT_CATG' AND l_rec_changes(i).column_name = 'EMPLOYMENT_CATEGORY') OR
             (g_contract_code_mapping = 'NL_EMPLOYEE_CATG' AND l_rec_changes(i).column_name = 'EMPLOYEE_CATEGORY') THEN
            l_emp_rec.employment_category := l_rec_changes(i).new_value; -- only certain category changes needs to be monitored
            l_assignment_catg_old := l_assignment_catg;
            OPEN  csr_get_shared_types(l_emp_rec.employment_category,p_business_gr_id,g_contract_code_mapping);
            FETCH csr_get_shared_types INTO l_bg,l_assignment_catg;
            CLOSE csr_get_shared_types;
            IF l_assignment_catg_old <> 'O' AND
               l_assignment_catg_old <> 'B' AND
               l_assignment_catg <> 'O' AND
               l_assignment_catg <> 'B' AND
               l_assignment_catg <> l_assignment_catg_old AND
               l_income_code NOT IN ('11','12','13','14','15','18')THEN
                 l_chk := 'N';
            END IF;
            IF p_date = l_rec_changes(i).effective_date THEN
              l_chk := 'Y';
            END IF;
            --Fnd_file.put_line(FND_FILE.LOG,' Change in assignment category New val :'||l_assignment_catg);
            --
          ELSIF ((g_contract_code_mapping = 'NL_EMPLOYMENT_CATG' AND l_rec_changes(i).column_name = 'EMPLOYEE_CATEGORY') OR
             (g_contract_code_mapping = 'NL_EMPLOYEE_CATG' AND l_rec_changes(i).column_name = 'EMPLOYMENT_CATEGORY')) AND
             l_chg_pending = 'N' THEN
             l_chk := 'N';

          ELSIF l_rec_changes(i).column_name = 'ASSIGNMENT_STATUS_TYPE_ID' THEN
            l_emp_rec.ASSIGNMENT_STATUS_TYPE_ID := l_rec_changes(i).new_value;
          ELSIF l_rec_changes(i).column_name = 'SOFT_CODING_KEYFLEX_ID' THEN
            SELECT soft_coding_keyflex_id
            INTO   l_emp_rec.soft_coding_keyflex_id
            FROM   per_all_assignments_f
            WHERE  assignment_id = l_assignment_id
            AND    l_rec_changes(i).effective_date BETWEEN effective_start_date AND effective_end_date;
            --
            --Fnd_file.put_line(FND_FILE.LOG,' Change in SCL New val :'||l_rec_changes(i).new_value);
            get_scl_data(l_emp_rec.soft_coding_keyflex_id
                        ,p_chk_end_date
                        ,l_income_code
                        ,l_work_pattern      -- income code
                        ,l_wage_tax_discount
                       -- ,l_company_car_use
                        ,l_wage_tax_table
                        ,l_wage_aow
                        ,l_wage_wajong
                        ,l_emp_loan
                        ,l_transportation
                        ,l_chk);
            IF p_date = l_rec_changes(i).effective_date THEN
              l_chk := 'Y';
            END IF;
            --Fnd_file.put_line(FND_FILE.LOG,' Change in SCL New val :'||l_rec_changes(i).new_value||l_chk);
          ELSIF (l_rec_changes(i).column_name LIKE 'AEI_INFORMATION%')
            OR l_rec_changes(i).dated_table_id = l_table3 THEN
            --Fnd_file.put_line(FND_FILE.LOG,' Change in EIT New val :'||l_rec_changes(i).surrogate_key);
            IF i <> l_rec_changes.count THEN
              IF l_rec_changes(i).dated_table_id <> l_rec_changes(i+1).dated_table_id OR
                l_rec_changes(i).effective_date <> l_rec_changes(i+1).effective_date THEN
                get_assignment_extra_info(l_assignment_id
                             ,NULL  --l_rec_changes(i).surrogate_key
                             ,l_rec_changes(i).effective_date
                             ,l_rec_changes(i).period_start_date
                             ,l_rec_changes(i).period_end_date
                             ,l_labour_rel_code
                             ,l_ins_duty_code
                             ,l_FZ_Code
                             ,l_handicapped_code
                             ,l_wao_insured
                             ,l_ww_insured
                             ,l_zw_insured
                             ,l_zvw_situation
                             ,l_marginal_empl
                             ,l_wm_old_rule
                             ,l_chk);
                --
                --LC 2010--begin
                l_zvw_small_jobs := NULL;
                l_small_job := NULL;
                FOR assignments IN csr_get_other_assignments(l_assignment_id
                                                            ,l_rec_changes(i).period_start_date
                                                            ,l_rec_changes(i).period_end_date
                                                            ,p_business_gr_id
                                                            ,l_tax_unit_id
                                                            ,p_payroll_type)   LOOP
                   l_other_assignment_action_id := NULL;
                   l_assg_small_job := NULL;
                    OPEN  csr_get_assignment_action_id(assignments.assignment_id,l_rec_changes(i).period_start_date);
                    FETCH csr_get_assignment_action_id INTO l_other_assignment_action_id;
                    CLOSE csr_get_assignment_action_id;

                    IF l_other_assignment_action_id IS NOT NULL THEN
                      OPEN  csr_get_small_job_detail(l_other_assignment_action_id,l_rec_changes(i).effective_date);
                      FETCH csr_get_small_job_detail INTO l_assg_small_job;
                      CLOSE csr_get_small_job_detail;
                    END IF;

                    IF l_assg_small_job IS NOT NULL THEN
                      IF l_assg_small_job = 'N' THEN
                        l_small_job := 'N';
                        EXIT;
                      ELSIF (l_small_job = 'F' OR l_small_job IS NULL) AND l_assg_small_job = 'F' THEN
                        l_small_job := 'F';
                      END IF;
                    END IF;
                END LOOP;


                  IF l_small_job = 'F' THEN
                    IF l_zvw_situation <> 'J' OR l_zvw_situation IS NULL THEN
                      l_zvw_situation := 'J';
                      l_zvw_small_jobs := 'D';  --Defaulted
                    END IF;
                    IF l_ins_duty_code <> 'F' THEN
                      l_ins_duty_code := l_ins_duty_code||'F'; --Append F
                    END IF;
                  ELSIF l_small_job = 'N' AND l_zvw_situation ='J' THEN
                    l_zvw_small_jobs := 'W';  --Warning
                  END IF;
                --LC 2010--end
                --
                l_zvw_defaulted := NULL;
                IF l_zvw_situation IS NULL THEN
                  l_zvw_situation := 'A';
                  l_zvw_defaulted := 'Y';
                END IF;
                --
                IF p_date = l_rec_changes(i).effective_date THEN
                  l_chk := 'Y';
                END IF;
              ELSE
                l_chk := 'N';
                --Fnd_file.put_line(FND_FILE.LOG,' IGNORING CHANGE : Next change on same effective date and same table');
              END IF;
            ELSE
              get_assignment_extra_info(l_assignment_id
                             ,NULL--l_rec_changes(i).surrogate_key
                             ,l_rec_changes(i).effective_date
                             ,l_rec_changes(i).period_start_date
                             ,l_rec_changes(i).period_end_date
                             ,l_labour_rel_code
                             ,l_ins_duty_code
                             ,l_FZ_Code
                             ,l_handicapped_code
                             ,l_wao_insured
                             ,l_ww_insured
                             ,l_zw_insured
                             ,l_zvw_situation
                             ,l_marginal_empl
                             ,l_wm_old_rule
                             ,l_chk);
                --LC 2010--begin
                l_zvw_small_jobs := NULL;
                l_small_job := NULL;
                FOR assignments IN csr_get_other_assignments(l_assignment_id
                                                              ,l_rec_changes(i).period_start_date
                                                              ,l_rec_changes(i).period_end_date
                                                              ,p_business_gr_id
                                                              ,l_tax_unit_id
                                                              ,p_payroll_type)   LOOP

                   l_other_assignment_action_id := NULL;
                   l_assg_small_job := NULL;
                    OPEN  csr_get_assignment_action_id(assignments.assignment_id,l_rec_changes(i).period_start_date);
                    FETCH csr_get_assignment_action_id INTO l_other_assignment_action_id;
                    CLOSE csr_get_assignment_action_id;

                    IF l_other_assignment_action_id IS NOT NULL THEN
                      OPEN  csr_get_small_job_detail(l_other_assignment_action_id,l_rec_changes(i).effective_date);
                      FETCH csr_get_small_job_detail INTO l_assg_small_job;
                      CLOSE csr_get_small_job_detail;
                    END IF;

                    IF l_assg_small_job IS NOT NULL THEN
                      IF l_assg_small_job = 'N' THEN
                        l_small_job := 'N';
                        EXIT;
                      ELSIF (l_small_job = 'F' OR l_small_job IS NULL) AND l_assg_small_job = 'F' THEN
                        l_small_job := 'F';
                      END IF;
                    END IF;
                  END LOOP;
                  IF l_small_job = 'F' THEN
                    IF l_zvw_situation <> 'J' OR l_zvw_situation IS NULL THEN
                      l_zvw_situation := 'J';
                      l_zvw_small_jobs := 'D';  --Defaulted
                    END IF;
                    IF l_ins_duty_code <> 'F' THEN
                      l_ins_duty_code := l_ins_duty_code||'F'; --Append F
                    END IF;
                  ELSIF l_small_job = 'N' AND l_zvw_situation ='J' THEN
                    l_zvw_small_jobs := 'W';  --Warning
                  END IF;
                --LC 2010--end
                --
                l_zvw_defaulted := NULL;
                IF l_zvw_situation IS NULL THEN
                  l_zvw_situation := 'A';
                  l_zvw_defaulted := 'Y';
                END IF;
                --
                IF p_date = l_rec_changes(i).effective_date THEN
                  l_chk := 'Y';
                END IF;
            END IF;
          ELSIF l_rec_changes(i).dated_table_id = l_table1 THEN
            OPEN  csr_get_element_name1(l_rec_changes(i).surrogate_key,l_rec_changes(i).effective_date);
            FETCH csr_get_element_name1 INTO l_element_name, l_val;
            CLOSE csr_get_element_name1;
            IF l_element_name IN ('Holiday Coupons','Additional Allowance') AND
               l_val = 'Y' THEN
               l_val := 'J';
            END IF;
            --
            IF l_element_name = 'Holiday Coupons' THEN
              IF NVL(l_holiday_coupen,'X')  = l_val THEN
                l_chk := 'N';
              END IF;
              l_holiday_coupen  := l_val;
            ELSIF l_element_name = 'Incidental Income Decrease'  THEN
              IF NVL(l_income_increase,'X')  = l_val THEN
                l_chk := 'N';
              END IF;
              l_income_increase := l_val;
            ELSIF l_element_name = 'Additional Allowance'  THEN
              IF p_chk_end_date  >= TO_DATE('01012007','DDMMYYYY') THEN
                l_val := NULL;
                l_chk := 'N';
              ELSIF NVL(l_add_allowance,'X')  = l_val THEN
                l_chk := 'N';
              END IF;
              l_add_allowance  := l_val;
            ELSIF l_element_name = 'Company Car Private Usage'  THEN
              IF NVL(l_company_car_use,'X')  = l_val THEN
                l_chk := 'N';
              END IF;
              l_company_car_use  := l_val;
            ELSE
              l_chk := 'N';
            END IF;
            IF p_date = l_rec_changes(i).effective_date THEN
              l_chk := 'Y';
            END IF;
            --Fnd_file.put_line(FND_FILE.LOG,' Change in Element entry New val :'||l_rec_changes(i).surrogate_key||l_chk);
            --
          ELSIF l_rec_changes(i).dated_table_id = l_table2 THEN
            OPEN  csr_get_element_name2(l_rec_changes(i).surrogate_key,l_rec_changes(i).effective_date);
            FETCH csr_get_element_name2 INTO l_element_name, l_val;
            CLOSE csr_get_element_name2;
            IF l_element_name IN ('Holiday Coupons','Additional Allowance') AND
               l_val = 'Y' THEN
               l_val := 'J';
            END IF;
            --
            IF l_element_name = 'Holiday Coupons' THEN
              IF NVL(l_holiday_coupen,'X')  = l_val THEN
                l_chk := 'N';
              END IF;
              l_holiday_coupen  := l_val;
            ELSIF l_element_name = 'Incidental Income Decrease'  THEN
              IF NVL(l_income_increase,'X')  = l_val THEN
                l_chk := 'N';
              END IF;
              l_income_increase := l_val;
            ELSIF l_element_name = 'Additional Allowance'  THEN
              IF p_chk_end_date  >= TO_DATE('01012007','DDMMYYYY') THEN
                l_val := NULL;
                l_chk := 'N';
              ELSIF NVL(l_add_allowance,'X')  = l_val THEN
                l_chk := 'N';
              END IF;
              l_add_allowance  := l_val;
            ELSIF l_element_name = 'Company Car Private Usage'  THEN
              IF NVL(l_company_car_use,'X')  = l_val THEN
                l_chk := 'N';
              END IF;
              l_company_car_use  := l_val;
            ELSE
              l_chk := 'N';
            END IF;
            IF p_date = l_rec_changes(i).effective_date THEN
              l_chk := 'Y';
            END IF;
            --Fnd_file.put_line(FND_FILE.LOG,' Change in Element entry values New val :'||l_rec_changes(i).surrogate_key||l_chk);
            --
          END IF;
          --
          IF l_chg_pending = 'Y' THEN
            l_chk := 'Y';
          END IF;
          --
          IF i <> l_rec_changes.count THEN
            IF  l_rec_changes(i).effective_date = l_rec_changes(i + 1).effective_date THEN
              --Fnd_file.put_line(FND_FILE.LOG,' IGNORING CHANGE : Next change on same effective date');
              l_chk := 'N';
              l_chg_pending := 'Y';
            END IF;
          END IF;
          --
          /*IF  i <> l_rec_changes.count AND
              l_rec_changes(i).effective_date BETWEEN p_chk_start_date AND p_chk_end_date AND
              l_rec_changes(i).update_type = 'C' AND
              l_rec_changes(i).dated_table_id <> l_table3 THEN
              --Fnd_file.put_line(FND_FILE.LOG,' IGNORING CHANGE : Correction in current period');
              l_chk := 'N';
          END IF; */
          --
          IF l_chk = 'Y' THEN
            IF l_period_start_date <> l_rec_changes(i).period_start_date
             --OR l_rec_changes(i).column_name = 'CHANGE_REASON'
            THEN
              l_period_start_date := l_rec_changes(i).period_start_date;
              l_period_end_date   := l_rec_changes(i).period_end_date;
              --
              --archive employment info and address context
              --
              IF l_chk_emp_reported = 'N' AND g_effective_date < TO_DATE('01012007','DDMMYYYY') THEN --## for removing correction rec
                OPEN  csr_chk_emp_reported(l_emp_rec.assignment_id);
                FETCH csr_chk_emp_reported INTO l_chk_emp_reported;
                IF csr_chk_emp_reported%notfound THEN
                    l_chk_emp_reported := 'N';
                END IF;
                CLOSE csr_chk_emp_reported;
              END IF;
              --
              IF  l_rec_changes(i).effective_date BETWEEN p_chk_start_date AND p_chk_end_date THEN --p_chk_start_date >= l_period_start_date AND p_chk_start_date <= l_period_end_date THEN
                l_type := 'INITIAL';
              ELSIF l_chk_emp_reported = 'N' OR g_effective_date >= TO_DATE('01012007','DDMMYYYY') THEN --## for removing correction rec
                l_type := 'CORRECTION';
              ELSE
                l_type := 'CORRECT';
              END IF;
              --Fnd_file.put_line(FND_FILE.LOG,' l_type :'||l_type);
              --Fnd_file.put_line(FND_FILE.LOG,' g_effective_date :'||fnd_date.date_to_canonical(g_effective_date));
              --
              l_emp_end_date := NULL;
              IF l_ass_end_date <= l_period_end_date THEN
                l_emp_end_date := l_ass_end_date;
              END IF;
              --
              IF l_type = 'INITIAL' THEN
                OPEN  csr_get_emp_data(l_assignment_id,NVL(l_emp_end_date,p_chk_end_date));
                FETCH csr_get_emp_data INTO l_emp_rec;
                CLOSE csr_get_emp_data;
              ELSE
                OPEN  csr_get_emp_data(l_assignment_id,l_rec_changes(i).effective_date);
                FETCH csr_get_emp_data INTO l_emp_rec;
                CLOSE csr_get_emp_data;
              END IF;
              --
              IF l_emp_rec.change_reason NOT IN ('NL1','NL2','NL3','NL4','NL5') THEN
                  l_emp_rec.change_reason := NULL;
              END IF;
              --
              IF l_archive_emp_info <> 'N'  THEN
              --Fnd_file.put_line(FND_FILE.LOG,' Creating NL_WR_EMPLOYMENT_INFO INfor Record for Type :'||l_type||' Date :'||l_period_start_date);
	      /* 8328995 */
                  l_numiv_override:=null;
	          OPEN csr_numiv_override(p_assignment_id);
	          FETCH csr_numiv_override INTO l_numiv_override;
	          CLOSE csr_numiv_override;
              pay_action_information_api.create_action_information (
                   p_action_information_id        =>  l_master_action_info_id
                  ,p_action_context_id            =>  p_assactid
                  ,p_action_context_type          =>  'AAP'
                  ,p_object_version_number        =>  l_ovn
                  ,p_assignment_id                =>  l_emp_rec.assignment_id
                  ,p_effective_date               =>  p_effective_date
                  ,p_source_id                    =>  NULL
                  ,p_source_text                  =>  NULL
                  ,p_tax_unit_id                  =>  l_tax_unit_id
                  ,p_action_information_category  =>  'NL_WR_EMPLOYMENT_INFO'
                  ,p_action_information1          =>  l_type
                  ,p_action_information2          =>  fnd_date.date_to_canonical(GREATEST(l_period_start_date,trunc(l_period_end_date,'Y')))
                  ,p_action_information3          =>  fnd_date.date_to_canonical(l_period_end_date)
                  ,p_action_information4          =>  l_emp_rec.assignment_number
                  ,p_action_information5          =>  l_emp_rec.employee_number
                  ,p_action_information6          =>  l_emp_rec.change_reason
                  ,p_action_information8          =>  l_emp_rec.sofi_number
                  ,p_action_information7          =>  l_emp_rec.person_id
                  ,p_action_information9          =>  l_emp_rec.Initials
                  ,p_action_information10         =>  l_emp_rec.prefix
                  ,p_action_information11         =>  l_emp_rec.last_name
                  ,p_action_information12         =>  fnd_date.date_to_canonical(l_emp_rec.dob)
                  ,p_action_information13         =>  l_nationality
                  ,p_action_information14         =>  l_emp_rec.gender
                  ,p_action_information15         =>  fnd_date.date_to_canonical(l_ass_start_date)-- assignment_start_date
                  ,p_action_information16         =>  fnd_date.date_to_canonical(l_emp_end_date)
                  ,p_action_information17         =>  l_rec_changes(i).retro
                  ,p_action_information18         =>  nvl(l_numiv_override,l_emp_seq)); -- 8328995
                --Check0044 Check1044
                IF l_emp_rec.sofi_number is null AND l_emp_rec.employee_number is null THEN
                  --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0044/1044 - '||fnd_message.get_string('PER','HR_373537_NL_EMPNO_MANDATORY')
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0044/1044 - '||'When the "BSN/Sofi-number" (Tag SofiNr) is not reported the record "Employee number" (Tag PersNr) is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;


                --abraghun--7668628--Check0046 Check0047 Check0048 Check0049
                IF l_emp_rec.sofi_number is not null AND l_wage_tax_table <> 940 THEN
                 fnd_message.set_name('PER','HR_373535_NL_NON940_MANDATORY');

                   --abraghun--7668628--Check0046
                   IF l_emp_rec.last_name is null THEN
                  --
                    fnd_message.set_token('TAGVAL1',l_wage_tax_table);
                    fnd_message.set_token('TAG2','SignNm');

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0046 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0046 - '||'When "BSN/Sofi-number" (Tag SofiNr) is reported and "Code wage tax table" (Tag LbTab) is not equal to 940 the "Last Name" (Tag SignNm) cannot be empty / is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;

                  --abraghun--7668628--Check0047
                   IF l_emp_rec.dob is null THEN
                  --
                    fnd_message.set_token('TAGVAL1',l_wage_tax_table);
                    fnd_message.set_token('TAG2','Gebdat');

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0047 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0047 - '||'When "BSN/Sofi-number" (Tag SofiNr) is reported and "Code wage tax table" (Tag LbTab) is not equal to 940 the "Date of birth" (Tag Gebdat) cannot be empty / is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;

                   --abraghun--7668628--Check0048
                   IF l_nationality is null THEN
                  --
                    fnd_message.set_token('TAGVAL1',l_wage_tax_table);
                    fnd_message.set_token('TAG2','Nat');

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0048 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0048 - '||'When "BSN/Sofi-number" (Tag SofiNr) is reported and "Code wage tax table" (Tag LbTab) is not equal to 940 the "Nationality" (Tag Nat) cannot be empty / is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;

                  --abraghun--7668628--Check0049
                  IF l_emp_rec.gender is null THEN
                  --
                    fnd_message.set_token('TAGVAL1',l_wage_tax_table);
                    fnd_message.set_token('TAG2','Gesl');

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0049 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0049 - '||'When "BSN/Sofi-number" (Tag SofiNr) is reported and "Code wage tax table" (Tag LbTab) is not equal to 940 the "Gender" (Tag Gesl) cannot be empty / is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              END IF;
                      --
              --abraghun--7668628--Check0039
        IF l_ass_start_date > l_period_end_date  THEN
               fnd_message.set_name('PER','HR_373543_NL_DATE_LTEQ');
               fnd_message.set_token('TAG1','DatAanv');
               fnd_message.set_token('TAGVAL1',fnd_date.date_to_canonical(l_ass_start_date));
               fnd_message.set_token('TAG2','DatEindTv');
               fnd_message.set_token('TAGVAL2',fnd_date.date_to_canonical(l_period_end_date));
                         --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0039 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0039 - '||'The "Start date income relation" (Tag DatAanv) has to be lower than or equal to the "End date period" (Tag DatEindTv) within one report or one correction report.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              --
        --
              --abraghun--7668628--Check0040

              --abraghun--8552196--Mistake in Validation Corrected
                --Old: (DatEind>=DatAanvTv)
                --New: (DatEind<=DatEindTv)


        IF l_emp_end_date is not null
        --and l_emp_end_date < GREATEST(l_period_start_date,trunc(l_period_end_date,'Y')) THEN
        and l_emp_end_date > l_period_end_date THEN

               --fnd_message.set_name('PER','HR_373544_NL_DATE_GTEQ');
               fnd_message.set_name('PER','HR_373543_NL_DATE_LTEQ');
               fnd_message.set_token('TAG1','DatEind');
               fnd_message.set_token('TAGVAL1',fnd_date.date_to_canonical(l_emp_end_date));
               --fnd_message.set_token('TAG2','DatAanvTv');
               --fnd_message.set_token('TAGVAL2',fnd_date.date_to_canonical(GREATEST(l_period_start_date,trunc(l_period_end_date,'Y'))));
               fnd_message.set_token('TAG2','DatEindTv');
               fnd_message.set_token('TAGVAL2',fnd_date.date_to_canonical(l_period_end_date));


                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0040 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    --, p_action_information6          =>  '0040 - '||'The "End date income relation" (Tag DatEind) has to be higher than or equal to the "Start date period" (Tag DatAanvTv) within one report or one correction report.'
                    , p_action_information6          =>  '0040 - '||'The "End date income relation" (Tag DatEind) has to be lower than or equal to the "End date period" (Tag DatEindTv) within one report or one correction report.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              --
              --abraghun--7668628--Check0041
        IF l_emp_end_date is not null and l_emp_end_date < l_ass_start_date THEN
                         --
               fnd_message.set_name('PER','HR_373544_NL_DATE_GTEQ');
               fnd_message.set_token('TAG1','DatEind');
               fnd_message.set_token('TAGVAL1',fnd_date.date_to_canonical(l_emp_end_date));
               fnd_message.set_token('TAG2','DatAanv');
               fnd_message.set_token('TAGVAL2',fnd_date.date_to_canonical(l_ass_start_date));

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0041 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0041 - '||'The "End date income relation" (Tag DatEind) has to be higher than or equal to the "Start date income relation" (Tag DatAanv).'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              --
              --abraghun--7668628--Check0042
                IF l_emp_rec.change_reason is not null AND l_labour_rel_code <> 11 THEN
                  --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0042 - '||fnd_message.get_string('PER','HR_373545_NL_RDNEINDFLX_CHECK1')
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0042 - '||'The "Code reason end of Income relation Flex worker" is only allowed when the "Code kind of labour relation" (Tag CdAard) is equal to 11.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              --
              --abraghun--7668628--Check0043
                IF l_emp_rec.change_reason is not null AND l_emp_end_date is null THEN
                  --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0043 - '||fnd_message.get_string('PER','HR_373546_NL_RDNEINDFLX_CHECK2')
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0043 - '||'The "Code reason end of Income relation Flex worker" is only allowed when the "End date income relation" (Tag DatEind) is reported.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
                  --
                --abraghun--7668628--validation ends

              END IF;
              l_archive_emp_info := 'Y';
              --
              --IF l_type = 'INITIAL' OR l_type = 'CORRECTION' THEN
              -- archive employee address
              --Fnd_file.put_line(FND_FILE.LOG,' Archiving Employee Address Record for Type :'||l_type);
              IF l_type = 'INITIAL' OR l_type = 'CORRECTION' THEN
                archive_emp_address(p_assactid
                                 ,l_emp_rec.person_id
                                 ,l_emp_rec.assignment_id
                                 ,l_emp_rec.assignment_number
                                 ,l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                                 ,l_tax_unit_id
                                 ,l_master_action_info_id
                                 ,p_effective_date
                                 ,NVL(l_emp_end_date,l_period_end_date)
                                 ,l_type);
               ELSE
                 archive_emp_address(p_assactid
                                 ,l_emp_rec.person_id
                                 ,l_emp_rec.assignment_id
                                 ,l_emp_rec.assignment_number
                                 ,l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                                 ,l_tax_unit_id
                                 ,l_master_action_info_id
                                 ,p_effective_date
                                 ,l_rec_changes(i).effective_date
                                 ,l_type);
               END IF;
               -- archive sector information for assignment
               --Fnd_file.put_line(FND_FILE.LOG,' Archiving Sector Risk Group Record for Type :'||l_type);
               l_srg_flag := archive_sector_risk_group(p_assactid
                                                      ,l_emp_rec.assignment_id
                                                      ,p_effective_date
                                                      ,l_tax_unit_id
                                                      ,l_master_action_info_id
                                                      ,l_period_start_date
                                                      ,l_period_end_date
                                                      ,l_ass_start_date
                                                      ,l_emp_end_date
                                                      ,p_payroll_type);
              --#
              IF l_srg_flag = 'N' AND (l_wao_insured = 'Y' OR l_ww_insured = 'Y' OR l_zw_insured = 'Y') THEN
                  --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_ASG_RISK_GRP')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  'Assignment has no Sector or Risk Group'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
              END IF;
              --#
               --
               --archive nominative info
              l_assignment_action_id := NULL;
              OPEN  csr_get_assignment_action_id2(l_assignment_id,l_period_start_date);
              FETCH csr_get_assignment_action_id2 INTO l_assignment_action_id;
              CLOSE csr_get_assignment_action_id2;
              --
              IF l_rec_changes(i).retro = 'PAY' OR l_type = 'INITIAL' OR l_type = 'CORRECTION' THEN
                l_corr_used := 'N';
                populate_nom_balance_values(l_master_assignment_action_id
                                           ,l_assignment_action_id
                                           ,l_period_end_date
                                           ,l_tax_unit_id
                                           ,l_type
                                           ,l_rec_changes(i).retro
                                           ,l_corr_used
                                           ,l_bal_value);
                --
                get_nominative_data(l_bal_value,l_nom_bal_value);
                --
                --Fnd_file.put_line(FND_FILE.LOG,' Creating NL_WR_NOMINATIVE_REPORT  Record for Type :'||l_type);
                archive_nominative_data(p_assactid
                                       ,l_emp_rec.assignment_id
                                       ,l_tax_unit_id
                                       ,p_effective_date
                                       ,l_rec_changes(i).effective_date
                                       ,l_type
                                       ,l_master_action_info_id
                                       ,l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                                       ,l_corr_used
                                       ,p_payroll_type
                                       ,l_nom_bal_value);
              END IF;
               --
               l_chk_emp_reported := 'Y';
              --END IF;
            END IF;
            l_chg_pending := 'N';
            --
            --IF l_rec_changes(i).column_name <> 'CHANGE_REASON' OR
            --   l_rec_changes(i).column_name IS NOT NULL THEN
--LC 2010--begins
                IF l_zvw_small_jobs = 'D' THEN
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  fnd_message.get_string('PER','HR_373549_NL_ZVW_J_DEFAULT')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  'Contribution Exempt Small Job is applicable. Therefore, the ZVW code is set to J.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                END IF;
                IF l_zvw_small_jobs = 'W' THEN
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  fnd_message.get_string('PER','HR_373550_NL_ZVW_J_WARNING')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  'The ZVW code is set to J when Contribution Exempt Small Job is not applicable.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                END IF;
--LC 2010--ends

                --#
                IF l_zvw_defaulted = 'Y' THEN
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_ZVW_CODE_INSURED')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  'Code ZVW is defaulted to - A'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                END IF;
                --
                --abraghun--7668628--Check0053 -- already exists.
                --
                IF l_income_code IN (11,12,13,14,15,18) AND l_labour_rel_code IS NULL THEN
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0053 - '||fnd_message.get_string('PER','HR_NL_INVALID_LABOR_CODE')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  '0053 - '||'Labor Relation code is null'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                END IF;
                --
                --abraghun--7668628--Check0055 - already exists.
                --
                IF l_income_code IN (11,12,13,14,15,18) AND l_assignment_catg IS NULL THEN
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0055 - '||fnd_message.get_string('PER','HR_NL_INVALID_CONTRACT_CODE')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  '0055 - '||'Code contract for limited or unlimited time is null'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                END IF;
                --
                IF l_income_code IN (11,12,13,14,15,18) AND l_work_pattern IS NULL AND g_effective_date < TO_DATE('01012007','DDMMYYYY') THEN
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_WORK_PATTERN')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  'Indication regular work pattern is null'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                END IF;
                --
                IF l_srg_flag = 'Z' AND l_FZ_Code IS NULL THEN
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_TEMP_LABOR_CODE')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  'Temp Labor Code is null'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                END IF;
                --
                IF l_company_car_use = 4 AND g_effective_date > to_date('01012007','ddmmyyyy') THEN
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_COMPANY_CAR_USE')
                    , p_action_information5          =>  fnd_date.date_to_canonical(l_rec_changes(i).effective_date)
                    , p_action_information6          =>  'Company Car Usage code invalid'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                END IF;
                --#
                --Fnd_file.put_line(FND_FILE.LOG,' Creating NL_WR_INCOME_PERIOD INfor Record for Type :'||l_type||GREATEST(l_rec_changes(i).effective_date,l_ass_start_date));
                pay_action_information_api.create_action_information (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_action_information_category  =>  'NL_WR_INCOME_PERIOD'
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information1          =>  l_type
                    , p_action_information2          =>  l_master_action_info_id
                    , p_action_information5          =>  fnd_date.date_to_canonical(GREATEST(GREATEST(l_rec_changes(i).effective_date,l_ass_start_date),trunc(l_rec_changes(i).period_end_date,'Y'))) /*** EOY 0708 ...Start Date Income Peiod ***/
                    , p_action_information6          =>  l_income_code
                    , p_action_information7          =>  l_labour_rel_code
                    , p_action_information8          =>  l_ins_duty_code
                    , p_action_information9          =>  l_assignment_catg
                    , p_action_information10         =>  l_FZ_Code
                    , p_action_information11         =>  l_work_pattern
                    , p_action_information12         =>  l_cao_code
                    , p_action_information13         =>  l_handicapped_code
                    , p_action_information14         =>  l_wage_tax_discount
                    , p_action_information15         =>  l_company_car_use
                    , p_action_information16         =>  l_wage_tax_table
                    , p_action_information17         =>  l_wao_insured
                    , p_action_information18         =>  l_ww_insured
                    , p_action_information19         =>  l_zw_insured
                    , p_action_information20         =>  NVL(l_zvw_situation,'A')
                    , p_action_information21         =>  l_holiday_coupen
                    , p_action_information22         =>  l_wage_aow
                    , p_action_information23         =>  l_wage_wajong
                    , p_action_information24         =>  l_emp_loan
                    , p_action_information25         =>  l_transportation
                    , p_action_information26         =>  l_income_increase
                    , p_action_information27         =>  l_add_allowance
                    , p_action_information28         =>  l_marginal_empl/*LC 2010*/
                    , p_action_information29         =>  l_wm_old_rule);/*LC 2010*/

                --abraghun--7668628--Validation Code
    --abraghun--7668628--Check0054
    IF l_income_code=18 AND l_labour_rel_code <> 18 THEN
       pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  '0054 - '||fnd_message.get_string('PER','HR_373539_NL_CDAARD_CHECK')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  '0054 - '||'The "Code kind of labour relation" (Tag CdAard) has to be 18 when "Income Code" (Tag SrtIV) is equal to 18.'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --
    --abraghun--7668628--Check0056
    --
    IF l_income_code IN (11,12,13,14,15,17,18) AND l_cao_code IS NULL THEN

    --HR_373531_NL_SRTIV_MANDATORY When SrtIV is equal to &SRTIV, &TAG is mandatory.
         fnd_message.set_name('PER','HR_373531_NL_SRTIV_MANDATORY');
         fnd_message.set_token('SRTIV',l_income_code);
         fnd_message.set_token('TAG','CAO');


        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  '0056 - '||fnd_message.get
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  '0056 - '||'When the "Income Code" (Tag SrtIV) is equal to 11, 12, 13, 14, 15, 17 or 18, the "Code CAO" (Tag CAO) is mandatory.'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;

    --abraghun--8552196--Check0057 Check0058 Check0059 Removed--
    /* Commenting out Starts
    --abraghun--7668628--Check0057 Check0058 Check0059--
    --
    IF (months_between(l_period_end_date,l_emp_rec.dob)/12)>=65 THEN
      --abraghun--7668628--Check0057
      IF l_wao_insured = 'J' THEN
        fnd_message.set_name('PER','HR_373532_NL_AGE65_CHECKS');
        fnd_message.set_token('AGE',ROUND(months_between(l_period_end_date,l_emp_rec.dob)/12));
        fnd_message.set_token('TAG','IndWAO');
        pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0057 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0057 - '||'When the employee reaches the age of 65 in the current period (the age is 65 on the last day of the period), the "Indication WAO/IVA/WGA insured" (Tag IndWAO) cannot be equal to "J".'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);
      END IF;
      --abraghun--7668628--Check0058
      IF l_ww_insured = 'J' THEN
        fnd_message.set_name('PER','HR_373532_NL_AGE65_CHECKS');
        fnd_message.set_token('AGE',ROUND(months_between(l_period_end_date,l_emp_rec.dob)/12));
        fnd_message.set_token('TAG','IndWW');
        pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0058 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0058 - '||'When the employee reaches the age of 65 in the current period (the age is 65 on the last day of the period), the "Indication WW insured" (Tag IndWW) cannot be equal to "J".'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);
      END IF;
      --abraghun--7668628--Check0059
      IF l_zw_insured = 'J' THEN
         fnd_message.set_name('PER','HR_373532_NL_AGE65_CHECKS');
         fnd_message.set_token('AGE',ROUND(months_between(l_period_end_date,l_emp_rec.dob)/12));
         fnd_message.set_token('TAG','IndZW');
         pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0059 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0059 - '||'When the employee reaches the age of 65 in the current period (the age is 65 on the last day of the period), the "Indication ZW insured" (Tag IndZW) cannot be equal to "J".'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);

      END IF;
    END IF;

    Commenting out Ends-- */
    --abraghun--8552196--Check0057 Check0058 Check0059 Removed--

/*
    --abraghun--7668628--Check0060
    IF l_wage_tax_table in (221,224,225) AND NVL(l_zvw_situation,'A')<>'G' THEN

      fnd_message.set_name('PER','HR_373538_NL_CDZVW_CHECKS');
      fnd_message.set_token('TAGVAL1','G');
      fnd_message.set_token('TAGVAL2',l_wage_tax_table);

       pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0060 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0060 - '||'The "Indication insurance situation Zvw" (Tag CdZvw) can only be equal to "G" when "Code wage tax table" (Tag LbTab) is equal to 221, 224 or 225.'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);
    --abraghun--7668628--Check0061
    ELSIF l_wage_tax_table =220 AND NVL(l_zvw_situation,'A')<>'H' THEN

      fnd_message.set_name('PER','HR_373538_NL_CDZVW_CHECKS');
      fnd_message.set_token('TAGVAL1','H');
      fnd_message.set_token('TAGVAL2',l_wage_tax_table);

      pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0061 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0061 - '||'The "Indication insurance situation Zvw" (Tag CdZvw) can only be equal to "H" when "Code wage tax table" (Tag LbTab) is equal to 220.'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);

    END IF;
*/
    --abraghun--7668628--Validation Code Ends
                --
                l_initial_flag := 'N';
                --
          END IF;
        END IF;
      END IF;
      --
    END LOOP;
  END IF;
  IF l_rec_changes.COUNT = 0  OR l_type <> 'INITIAL' OR l_initial_flag = 'Y' THEN
    l_type := 'INITIAL';
    --Fnd_file.put_line(FND_FILE.LOG,' No HR or Payroll Change : Creating NL_WR_EMPLOYMENT_INFO Information Record for Type :'||l_type);
    -- archive employment Information
    l_emp_end_date := NULL;
    IF l_ass_end_date <= p_chk_end_date THEN
      l_emp_end_date := l_ass_end_date;
    END IF;
    --
    IF l_initial_flag <> 'Y' THEN
    /* 8328995 */
        l_numiv_override:=null;
	OPEN csr_numiv_override(p_assignment_id);
	FETCH csr_numiv_override INTO l_numiv_override;
	CLOSE csr_numiv_override;
     pay_action_information_api.create_action_information (
         p_action_information_id        =>  l_master_action_info_id
        ,p_action_context_id            =>  p_assactid
        ,p_action_context_type          =>  'AAP'
        ,p_object_version_number        =>  l_ovn
        ,p_assignment_id                =>  l_emp_rec.assignment_id
        ,p_effective_date               =>  p_effective_date
        ,p_source_id                    =>  NULL
        ,p_source_text                  =>  NULL
        ,p_tax_unit_id                  =>  l_tax_unit_id
        ,p_action_information_category  =>  'NL_WR_EMPLOYMENT_INFO'
        ,p_action_information1          =>  l_type
        ,p_action_information2          =>  fnd_date.date_to_canonical(GREATEST(p_chk_start_date,trunc(p_chk_end_date,'Y')))
        ,p_action_information3          =>  fnd_date.date_to_canonical(p_chk_end_date)
        ,p_action_information4          =>  l_emp_rec.assignment_number
        ,p_action_information5          =>  l_emp_rec.employee_number
        ,p_action_information8          =>  l_emp_rec.sofi_number
        ,p_action_information6          =>  l_emp_rec.change_reason
        ,p_action_information7          =>  l_emp_rec.person_id
        ,p_action_information9          =>  l_emp_rec.Initials
        ,p_action_information10         =>  l_emp_rec.prefix
        ,p_action_information11         =>  l_emp_rec.last_name
        ,p_action_information12         =>  fnd_date.date_to_canonical(l_emp_rec.dob)
        ,p_action_information13         =>  l_nationality
        ,p_action_information14         =>  l_emp_rec.gender
        ,p_action_information15         =>  fnd_date.date_to_canonical(l_ass_start_date)-- assignment_start_date
        ,p_action_information16         =>  fnd_date.date_to_canonical(l_emp_end_date)
        ,p_action_information17         =>  NULL
        ,p_action_information18         =>  nvl(l_numiv_override,l_emp_seq)); -- 8328995
             --abraghun--7668628--Validation begins
                --
                --abraghun--7668628--Check0044 Check1044
                IF l_emp_rec.sofi_number is null AND l_emp_rec.employee_number is null THEN
                  --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0044/1044 - '||fnd_message.get_string('PER','HR_373537_NL_EMPNO_MANDATORY')
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0044/1044 - '||'When the "BSN/Sofi-number" (Tag SofiNr) is not reported the record "Employee number" (Tag PersNr) is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;

                --abraghun--7668628--Check0046 Check0047 Check0048 Check0049
                IF l_emp_rec.sofi_number is not null AND l_wage_tax_table <> 940 THEN
                 fnd_message.set_name('PER','HR_373535_NL_NON940_MANDATORY');

                   --abraghun--7668628--Check0046
                   IF l_emp_rec.last_name is null THEN
                  --
                    fnd_message.set_token('TAGVAL1',l_wage_tax_table);
                    fnd_message.set_token('TAG2','SignNm');

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0046 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0046 - '||'When "BSN/Sofi-number" (Tag SofiNr) is reported and "Code wage tax table" (Tag LbTab) is not equal to 940 the "Last Name" (Tag SignNm) cannot be empty / is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;

                  --abraghun--7668628--Check0047
                   IF l_emp_rec.dob is null THEN
                  --
                    fnd_message.set_token('TAGVAL1',l_wage_tax_table);
                    fnd_message.set_token('TAG2','Gebdat');

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0047 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0047 - '||'When "BSN/Sofi-number" (Tag SofiNr) is reported and "Code wage tax table" (Tag LbTab) is not equal to 940 the "Date of birth" (Tag Gebdat) cannot be empty / is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;

                   --abraghun--7668628--Check0048
                   IF l_nationality is null THEN
                  --
                    fnd_message.set_token('TAGVAL1',l_wage_tax_table);
                    fnd_message.set_token('TAG2','Nat');

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0048 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0048 - '||'When "BSN/Sofi-number" (Tag SofiNr) is reported and "Code wage tax table" (Tag LbTab) is not equal to 940 the "Nationality" (Tag Nat) cannot be empty / is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;

                  --abraghun--7668628--Check0049
                  IF l_emp_rec.gender is null THEN
                  --
                    fnd_message.set_token('TAGVAL1',l_wage_tax_table);
                    fnd_message.set_token('TAG2','Gesl');

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0049 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0049 - '||'When "BSN/Sofi-number" (Tag SofiNr) is reported and "Code wage tax table" (Tag LbTab) is not equal to 940 the "Gender" (Tag Gesl) cannot be empty / is mandatory.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              END IF;
              --
              --abraghun--7668628--Check0039
        IF l_ass_start_date > p_chk_end_date  THEN
                         --
               fnd_message.set_name('PER','HR_373543_NL_DATE_LTEQ');
               fnd_message.set_token('TAG1','DatAanv');
               fnd_message.set_token('TAGVAL1',fnd_date.date_to_canonical(l_ass_start_date));
               fnd_message.set_token('TAG2','DatEindTv');
               fnd_message.set_token('TAGVAL2',fnd_date.date_to_canonical(p_chk_end_date));

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0039 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0039 - '||'The "Start date income relation" (Tag DatAanv) has to be lower than or equal to the "End date period" (Tag DatEindTv) within one report or one correction report.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              --
        --
              --abraghun--7668628--Check0040

              --abraghun--8552196--Mistake in Validation Corrected
                --Old: (DatEind>=DatAanvTv)
                --New: (DatEind<=DatEindTv)

        IF l_emp_end_date is not null
        --and l_emp_end_date < GREATEST(p_chk_start_date,trunc(p_chk_end_date,'Y')) THEN
        and l_emp_end_date > p_chk_end_date THEN

               --fnd_message.set_name('PER','HR_373544_NL_DATE_GTEQ');
               fnd_message.set_name('PER','HR_373543_NL_DATE_LTEQ');
               fnd_message.set_token('TAG1','DatEind');
               fnd_message.set_token('TAGVAL1',fnd_date.date_to_canonical(l_emp_end_date));
               --fnd_message.set_token('TAG2','DatAanvTv');
               --fnd_message.set_token('TAGVAL2',fnd_date.date_to_canonical(GREATEST(p_chk_start_date,trunc(p_chk_end_date,'Y'))));
               fnd_message.set_token('TAG2','DatEindTv');
               fnd_message.set_token('TAGVAL2',fnd_date.date_to_canonical(p_chk_end_date));

                         --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0040 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    --, p_action_information6          =>  '0040 - '||'The "End date income relation" (Tag DatEind) has to be higher than or equal to the "Start date period" (Tag DatAanvTv) within one report or one correction report.'
                    , p_action_information6          =>  '0040 - '||'The "End date income relation" (Tag DatEind) has to be lower than or equal to the "End date period" (Tag DatEindTv) within one report or one correction report.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              --
              --abraghun--7668628--Check0041
        IF l_emp_end_date is not null and l_emp_end_date < l_ass_start_date THEN
                         --
               fnd_message.set_name('PER','HR_373544_NL_DATE_GTEQ');
               fnd_message.set_token('TAG1','DatEind');
               fnd_message.set_token('TAGVAL1',fnd_date.date_to_canonical(l_emp_end_date));
               fnd_message.set_token('TAG2','DatAanv');
               fnd_message.set_token('TAGVAL2',fnd_date.date_to_canonical(l_ass_start_date));

                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0041 - '||fnd_message.get
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0041 - '||'The "End date income relation" (Tag DatEind) has to be higher than or equal to the "Start date income relation" (Tag DatAanv).'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
              --
              --abraghun--7668628--Check0042
                IF l_emp_rec.change_reason is not null AND l_labour_rel_code <> 11 THEN
                  --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0042 - '||fnd_message.get_string('PER','HR_373545_NL_RDNEINDFLX_CHECK1')
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0042 - '||'The "Code reason end of Income relation Flex worker" is only allowed when the "Code kind of labour relation" (Tag CdAard) is equal to 11.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
            --
            --abraghun--7668628--Check0043
                IF l_emp_rec.change_reason is not null AND l_emp_end_date is null THEN
                  --
                    pay_action_information_api.create_action_information
                    (
                      p_action_information_id        =>  l_action_info_id
                    , p_action_context_id            =>  p_assactid
                    , p_action_context_type          =>  'AAP'
                    , p_object_version_number        =>  l_ovn
                    , p_assignment_id                =>  l_emp_rec.assignment_id
                    , p_effective_date               =>  p_effective_date
                    , p_source_id                    =>  NULL
                    , p_source_text                  =>  NULL
                    , p_tax_unit_id                  =>  l_tax_unit_id
                    , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
                    , p_action_information4          =>  '0043 - '||fnd_message.get_string('PER','HR_373546_NL_RDNEINDFLX_CHECK2')
                    , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
                    , p_action_information6          =>  '0043 - '||'The "Code reason end of Income relation Flex worker" is only allowed when the "End date income relation" (Tag DatEind) is reported.'
                    , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                    , p_action_information8          =>  l_emp_rec.assignment_number);
                  --
                  END IF;
       --abraghun--7668628--validation ends


    END IF;
    -- archive address information
    --Fnd_file.put_line(FND_FILE.LOG,' Archiving Employee Address Record for Type :'||l_type);
    archive_emp_address(p_assactid
                       ,l_emp_rec.person_id
                       ,l_emp_rec.assignment_id
                       ,l_emp_rec.assignment_number
                       ,l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                       ,l_tax_unit_id
                       ,l_master_action_info_id
                       ,p_effective_date
                       ,NVL(l_emp_end_date,p_effective_date)
                       ,l_type);
    -- archive sector information for assignment
    --Fnd_file.put_line(FND_FILE.LOG,' Archiving Sector Risk Group Record for Type :'||l_type);
    l_srg_flag := archive_sector_risk_group(p_assactid
                                         ,l_emp_rec.assignment_id
                                         ,p_effective_date
                                         ,l_tax_unit_id
                                         ,l_master_action_info_id
                                         ,p_chk_start_date
                                         ,p_chk_end_date
                                         ,l_ass_start_date
                                         ,l_emp_end_date
                                         ,p_payroll_type);
    --#
    IF l_srg_flag = 'N' AND (l_wao_insured = 'Y' OR l_ww_insured = 'Y' OR l_zw_insured = 'Y') THEN
        --
          pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_ASG_RISK_GRP')
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  'Assignment has no Sector or Risk Group'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);
        --
    END IF;
    --#
--LC 2010--begins
    IF l_zvw_small_jobs = 'D' THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  fnd_message.get_string('PER','HR_373549_NL_ZVW_J_DEFAULT')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  'Contribution Exempt Small Job is applicable. Therefore, the ZVW code is set to J.'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    IF l_zvw_small_jobs = 'W' THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  fnd_message.get_string('PER','HR_373550_NL_ZVW_J_WARNING')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  'The ZVW code is set to J when Contribution Exempt Small Job is not applicable.'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
--LC 2010--ends
    --#
    IF l_zvw_defaulted = 'Y' THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_ZVW_CODE_INSURED')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  'Code ZVW is defaulted to - A'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --
    --abraghun--8552196--Check0053 - Prefixed Errorcode to existing Error message.
    IF l_income_code IN (11,12,13,14,15,18) AND l_labour_rel_code IS NULL THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  '0053 - '||fnd_message.get_string('PER','HR_NL_INVALID_LABOR_CODE')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  '0053 - '||'Labor Relation code is null'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --
    --abraghun--8552196--Check0055 - Prefixed Errorcode to existing Error message.
    IF l_income_code IN (11,12,13,14,15,18) AND l_assignment_catg IS NULL THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  '0055 - '||fnd_message.get_string('PER','HR_NL_INVALID_CONTRACT_CODE')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  '0055 - '||'Code contract for limited or unlimited time is null'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --
    IF l_income_code IN (11,12,13,14,15,18) AND l_work_pattern IS NULL AND g_effective_date < TO_DATE('01012007','DDMMYYYY') THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_WORK_PATTERN')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  'Indication regular work pattern is null'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --
    IF l_srg_flag = 'Z' AND l_FZ_Code IS NULL THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_TEMP_LABOR_CODE')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  'Temp Labor Code is null'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --
    IF l_company_car_use = 4 AND g_effective_date > to_date('01012007','ddmmyyyy') THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  fnd_message.get_string('PER','HR_NL_INVALID_COMPANY_CAR_USE')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  'Company Car Usage code invalid'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --#
    IF l_initial_flag <> 'Y' THEN
    --archive Income period information
    --Fnd_file.put_line(FND_FILE.LOG,' Archiving NL_WR_INCOME_PERIOD Record for Type :'||l_type);
        pay_action_information_api.create_action_information (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_action_information_category  =>  'NL_WR_INCOME_PERIOD'
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information1          =>  l_type
        , p_action_information2          =>  l_master_action_info_id
        , p_action_information5          =>  fnd_date.date_to_canonical(GREATEST(GREATEST(p_chk_start_date,l_ass_start_date),trunc(p_chk_end_date,'Y'))) /*** EOY 0708 ...Start Date Income Peiod ***/
        , p_action_information6          =>  l_income_code
        , p_action_information7          =>  l_labour_rel_code
        , p_action_information8          =>  l_ins_duty_code
        , p_action_information9          =>  l_assignment_catg
        , p_action_information10         =>  l_FZ_Code
        , p_action_information11         =>  l_work_pattern
        , p_action_information12         =>  l_cao_code
        , p_action_information13         =>  l_handicapped_code
        , p_action_information14         =>  l_wage_tax_discount
        , p_action_information15         =>  l_company_car_use
        , p_action_information16         =>  l_wage_tax_table
        , p_action_information17         =>  l_wao_insured
        , p_action_information18         =>  l_ww_insured
        , p_action_information19         =>  l_zw_insured
        , p_action_information20         =>  NVL(l_zvw_situation,'A')
        , p_action_information21         =>  l_holiday_coupen--'holiday coupen'
        , p_action_information22         =>  l_wage_aow
        , p_action_information23         =>  l_wage_wajong
        , p_action_information24         =>  l_emp_loan
        , p_action_information25         =>  l_transportation
        , p_action_information26         =>  l_income_increase--'INCOME DECREASE' -- A1
        , p_action_information27         =>  l_add_allowance--'ADDITIONAL ALLW');
        , p_action_information28         =>  l_marginal_empl/*LC 2010*/ --PMA
        , p_action_information29         =>  l_wm_old_rule);/*LC 2010*/ --WgldOudRegl

    --abraghun--7668628--Validation Code
    --abraghun--7668628--Check0054
    IF l_income_code=18 AND l_labour_rel_code <> 18 THEN
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  '0054 - '||fnd_message.get_string('PER','HR_373539_NL_CDAARD_CHECK')
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  '0054 - '||'The "Code kind of labour relation" (Tag CdAard) has to be 18 when "Income Code" (Tag SrtIV) is equal to 18.'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --
    --abraghun--7668628--Check0056
    --
    IF l_income_code IN (11,12,13,14,15,17,18) AND l_cao_code IS NULL THEN
        fnd_message.set_name('PER','HR_373531_NL_SRTIV_MANDATORY');
        fnd_message.set_token('SRTIV',l_income_code);
        fnd_message.set_token('TAG','CAO');
        pay_action_information_api.create_action_information
        (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_assactid
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  l_emp_rec.assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  NULL
        , p_source_text                  =>  NULL
        , p_tax_unit_id                  =>  l_tax_unit_id
        , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
        , p_action_information4          =>  '0056 - '||fnd_message.get
        , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
        , p_action_information6          =>  '0056 - '||'When the "Income Code" (Tag SrtIV) is equal to 11, 12, 13, 14, 15, 17 or 18, the "Code CAO" (Tag CAO) is mandatory.'
        , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
        , p_action_information8          =>  l_emp_rec.assignment_number);
    END IF;
    --
    --abraghun--8552196--Check0057 Check0058 Check0059 Removed--
    /*Commenting out Starts
--abraghun--7668628--Check0057 Check0058 Check0059--
    --

    IF (months_between(p_effective_date,l_emp_rec.dob)/12)>=65 THEN

      --abraghun--7668628--Check0057
      IF l_wao_insured = 'J' THEN
        fnd_message.set_name('PER','HR_373532_NL_AGE65_CHECKS');
        fnd_message.set_token('AGE',ROUND(months_between(p_effective_date,l_emp_rec.dob)/12));
        fnd_message.set_token('TAG','IndWAO');
        pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0057 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0057 - '||'When the employee reaches the age of 65 in the current period (the age is 65 on the last day of the period), the "Indication WAO/IVA/WGA insured" (Tag IndWAO) cannot be equal to "J".'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);
      END IF;
      --abraghun--7668628--Check0058
      IF l_ww_insured = 'J' THEN
        fnd_message.set_name('PER','HR_373532_NL_AGE65_CHECKS');
        fnd_message.set_token('AGE',ROUND(months_between(p_effective_date,l_emp_rec.dob)/12));
        fnd_message.set_token('TAG','IndWW');
        pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0058 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0058 - '||'When the employee reaches the age of 65 in the current period (the age is 65 on the last day of the period), the "Indication WW insured" (Tag IndWW) cannot be equal to "J".'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);
      END IF;
      --abraghun--7668628--Check0059
      IF l_zw_insured = 'J' THEN
         fnd_message.set_name('PER','HR_373532_NL_AGE65_CHECKS');
         fnd_message.set_token('AGE',ROUND(months_between(p_effective_date,l_emp_rec.dob)/12));
         fnd_message.set_token('TAG','IndZW');
         pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0059 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0059 - '||'When the employee reaches the age of 65 in the current period (the age is 65 on the last day of the period), the "Indication ZW insured" (Tag IndZW) cannot be equal to "J".'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);

      END IF;
    END IF;
    Commneting out Ends */
    --abraghun--8552196--Check0057 Check0058 Check0059 Removed--
    --
/*
    --abraghun--7668628--Check0060
    IF l_wage_tax_table in (221,224,225) AND NVL(l_zvw_situation,'A')<>'G' THEN
      fnd_message.set_name('PER','HR_373538_NL_CDZVW_CHECKS');
      fnd_message.set_token('TAGVAL1','G');
      fnd_message.set_token('TAGVAL2',l_wage_tax_table);

       pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0060 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0060 - '||'The "Indication insurance situation Zvw" (Tag CdZvw) can only be equal to "G" when "Code wage tax table" (Tag LbTab) is equal to 221, 224 or 225.'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);
    --abraghun--7668628--Check0061
    ELSIF l_wage_tax_table =220 AND NVL(l_zvw_situation,'A')<>'H' THEN

      fnd_message.set_name('PER','HR_373538_NL_CDZVW_CHECKS');
      fnd_message.set_token('TAGVAL1','H');
      fnd_message.set_token('TAGVAL2',l_wage_tax_table);

      pay_action_information_api.create_action_information
          (
            p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_assactid
          , p_action_context_type          =>  'AAP'
          , p_object_version_number        =>  l_ovn
          , p_assignment_id                =>  l_emp_rec.assignment_id
          , p_effective_date               =>  p_effective_date
          , p_source_id                    =>  NULL
          , p_source_text                  =>  NULL
          , p_tax_unit_id                  =>  l_tax_unit_id
          , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
          , p_action_information4          =>  '0061 - '||fnd_message.get
          , p_action_information5          =>  fnd_date.date_to_canonical(p_effective_date)
          , p_action_information6          =>  '0061 - '||'The "Indication insurance situation Zvw" (Tag CdZvw) can only be equal to "H" when "Code wage tax table" (Tag LbTab) is equal to 220.'
          , p_action_information7          =>  l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
          , p_action_information8          =>  l_emp_rec.assignment_number);

    END IF;
*/
    --abraghun--7668628--Validation Code Ends

    END IF;
    --archive nominative info
    OPEN  csr_get_assignment_action_id2(l_assignment_id,p_chk_start_date);
    FETCH csr_get_assignment_action_id2 INTO l_master_assignment_action_id;
    CLOSE csr_get_assignment_action_id2;
    --Fnd_file.put_line(FND_FILE.LOG,' Calling populate_nom_balance_values for Type :'||l_type);
    l_corr_used := 'N';
    populate_nom_balance_values(l_master_assignment_action_id
                               ,l_master_assignment_action_id
                               ,p_chk_end_date
                               ,l_tax_unit_id
                               ,l_type
                               ,'HR'
                               ,l_corr_used
                               ,l_bal_value);
    --Fnd_file.put_line(FND_FILE.LOG,' Calling get_nominative_data for Type :'||l_type);
    get_nominative_data(l_bal_value,l_nom_bal_value);
    --Fnd_file.put_line(FND_FILE.LOG,' Archiving NL_WR_NOMINATIVE Record for Type :'||l_type);
    archive_nominative_data(p_assactid
                           ,l_emp_rec.assignment_id
                           ,l_tax_unit_id
                           ,p_effective_date
                           ,p_effective_date
                           ,l_type
                           ,l_master_action_info_id
                           ,l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                           ,l_corr_used
                           ,p_payroll_type
                           ,l_nom_bal_value);
  END IF;
  --Fnd_file.put_line(FND_FILE.LOG,' Leaving chk_events');
  EXCEPTION
    WHEN OTHERS THEN
        --Fnd_file.put_line(FND_FILE.LOG,' Others. Assignment :'||l_assignment_id);
        --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
        NULL;
END chk_events;
--------------------------------------------------------------------------------
-- ARCHIVE_CONSOLIDATE
--------------------------------------------------------------------------------
PROCEDURE archive_consolidate(p_assactid       NUMBER
                             ,p_assignment_id  NUMBER
                             ,p_effective_date DATE
                             ,p_business_gr_id NUMBER
                             ,l_tax_unit_id    NUMBER
                             ,p_start_date     DATE
                             ,p_end_date       DATE
                             ,p_payroll_type   VARCHAR2) IS
    --
    CURSOR csr_action_info(c_category       VARCHAR2
                          ,c_type           VARCHAR2
                          ,c_assignment_id  NUMBER) IS
    SELECT pai.*
    FROM pay_action_interlocks pal
        ,pay_action_information pai
    WHERE pal.locking_action_id     = p_assactid
    AND	pal.locked_action_id	    = pai.action_context_id
    AND pai.action_context_type     = 'AAP'
    AND pai.action_information_category = c_category
    AND pai.assignment_id               = c_assignment_id
    AND pai.action_information1         = c_type
    ORDER BY pai.effective_date DESC;
    --
    CURSOR csr_get_income_start_date(c_assactid        NUMBER
                                    ,c_assignment_id   NUMBER) IS
    SELECT MIN(fnd_date.canonical_to_date(action_information5))
    FROM   pay_action_interlocks pal
          ,pay_action_information pai
    WHERE  pal.locking_action_id           = c_assactid
    AND	   pal.locked_action_id	           = pai.action_context_id
    AND    pai.action_context_type         = 'AAP'
    AND    pai.action_information_category = 'NL_WR_INCOME_PERIOD'
    AND    pai.assignment_id               = c_assignment_id
    AND    pai.action_information1         = 'INITIAL';
    --
    CURSOR csr_get_sector_start_date(c_assactid        NUMBER
                                    ,c_assignment_id   NUMBER
                                    ,c_sector          VARCHAR2
                                    ,c_risk_grp        VARCHAR2) IS
    SELECT MIN(fnd_date.canonical_to_date(action_information5))
    FROM   pay_action_interlocks pal
          ,pay_action_information pai
    WHERE  pal.locking_action_id           = c_assactid
    AND	   pal.locked_action_id	           = pai.action_context_id
    AND    pai.action_context_type         = 'AAP'
    AND    pai.action_information_category = 'NL_WR_SWMF_SECTOR_RISK_GROUP'
    AND    pai.assignment_id               = c_assignment_id
    AND    pai.action_information1         = 'SECTOR_RISK_GROUP'
    AND    pai.action_information7         = c_sector
    AND    pai.action_information8         = c_risk_grp;
    --
    CURSOR csr_exception_info(c_category       VARCHAR2
                             ,c_assactid        NUMBER) IS
    SELECT pai.*
    FROM  pay_action_information pai
    WHERE pai.action_context_id	  = c_assactid
    AND	  pai.action_context_type = 'AAP'
    AND	  pai.action_information_category = c_category;
    --
    CURSOR csr_ip_srg_info(c_category       VARCHAR2
                          ,c_type           VARCHAR2
                          ,c_actinfid       NUMBER) IS
    SELECT pai.*
    FROM  pay_action_information pai
    WHERE pai.action_context_type         = 'AAP'
    AND   pai.action_information2         = fnd_number.number_to_canonical(c_actinfid)
    AND   pai.action_information_category = c_category
    AND   pai.action_information1         = c_type    ;
    --
    CURSOR csr_address_info(c_category          VARCHAR2
                           ,c_type              VARCHAR2
                           ,c_actinfid          NUMBER
                           ,c_action_context_id NUMBER) IS
    SELECT pai.*
    FROM  pay_action_information pai
    WHERE pai.action_context_type         = 'AAP'
    AND   pai.action_information27        = fnd_number.number_to_canonical(c_actinfid)
    AND   pai.action_context_id           = c_action_context_id
    AND   pai.action_information_category = c_category
    AND   pai.action_information26        = c_type    ;
    --
    CURSOR csr_nominative_info(c_category       VARCHAR2
                              ,c_type           VARCHAR2
                              ,c_assactid       NUMBER) IS
    select sum(fnd_number.canonical_to_number(pai.action_information5))		sum5
          ,sum(fnd_number.canonical_to_number(pai.action_information6))     sum6
          ,sum(fnd_number.canonical_to_number(pai.action_information7))     sum7
          ,sum(fnd_number.canonical_to_number(pai.action_information8))     sum8
          ,sum(fnd_number.canonical_to_number(pai.action_information9))     sum9
          ,sum(fnd_number.canonical_to_number(pai.action_information10))    sum10
          ,sum(fnd_number.canonical_to_number(pai.action_information11))    sum11
          ,sum(fnd_number.canonical_to_number(pai.action_information12))    sum12
          ,sum(fnd_number.canonical_to_number(pai.action_information13))    sum13
          ,sum(fnd_number.canonical_to_number(pai.action_information14))    sum14
          ,sum(fnd_number.canonical_to_number(pai.action_information15))    sum15
          ,sum(fnd_number.canonical_to_number(pai.action_information16))    sum16
          ,sum(fnd_number.canonical_to_number(pai.action_information17))    sum17
          ,sum(fnd_number.canonical_to_number(pai.action_information18))    sum18
          ,sum(fnd_number.canonical_to_number(pai.action_information19))    sum19
          ,sum(fnd_number.canonical_to_number(pai.action_information20))    sum20
          ,sum(fnd_number.canonical_to_number(pai.action_information21))    sum21
          ,sum(fnd_number.canonical_to_number(pai.action_information22))    sum22
          ,sum(fnd_number.canonical_to_number(pai.action_information23))    sum23
          ,sum(fnd_number.canonical_to_number(pai.action_information24))    sum24
          ,sum(fnd_number.canonical_to_number(pai.action_information25))    sum25
          ,sum(fnd_number.canonical_to_number(pai.action_information26))    sum26
          ,sum(fnd_number.canonical_to_number(pai.action_information27))    sum27
          ,sum(fnd_number.canonical_to_number(pai.action_information28))    sum28
          ,sum(fnd_number.canonical_to_number(pai.action_information29))    sum29
    from pay_action_interlocks  pal
        ,pay_action_information pai
    where pal.locking_action_id     = c_assactid
    AND	pal.locked_action_id	    = pai.action_context_id
    AND pai.action_context_type     = 'AAP'
    AND pai.action_information_category = c_category
    AND pai.action_information1         = c_type    ;
    --
    l_ovn                   pay_action_information.object_version_number%TYPE;
    l_action_info_id        pay_action_information.action_information_id%TYPE;
    l_master_action_info_id pay_action_information.action_information_id%TYPE;
    l_empt_action_info_id   pay_action_information.action_information_id%TYPE;
    l_action_context_id     pay_action_information.action_context_id%TYPE;
    l_date DATE;
    --
BEGIN
    --
    --Fnd_file.put_line(FND_FILE.LOG,'~~## IN ARCHIVE_CODE');
    --
    FOR csr_action_info_rec IN csr_action_info('NL_WR_EMPLOYMENT_INFO','INITIAL',p_assignment_id) LOOP
        --
        l_empt_action_info_id := csr_action_info_rec.action_information_id;
        l_action_context_id := csr_action_info_rec.action_context_id;
        --
        pay_action_information_api.create_action_information (
             p_action_information_id        =>  l_master_action_info_id
            ,p_action_context_id            =>  p_assactid
            ,p_action_context_type          =>  'AAP'
            ,p_object_version_number        =>  l_ovn
            ,p_assignment_id                =>  csr_action_info_rec.assignment_id
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_tax_unit_id                  =>  l_tax_unit_id
            ,p_action_information_category  =>  'NL_WR_EMPLOYMENT_INFO'
            ,p_action_information1          =>  'INITIAL'
            ,p_action_information2          =>  fnd_date.date_to_canonical(GREATEST(p_start_date,trunc(p_end_date,'Y')))
            ,p_action_information3          =>  fnd_date.date_to_canonical(p_end_date)
            ,p_action_information4          =>  csr_action_info_rec.action_information4
            ,p_action_information5          =>  csr_action_info_rec.action_information5
            ,p_action_information6          =>  csr_action_info_rec.action_information6
            ,p_action_information7          =>  csr_action_info_rec.action_information7
            ,p_action_information8          =>  csr_action_info_rec.action_information8
            ,p_action_information9          =>  csr_action_info_rec.action_information9
            ,p_action_information10         =>  csr_action_info_rec.action_information10
            ,p_action_information11         =>  csr_action_info_rec.action_information11
            ,p_action_information12         =>  csr_action_info_rec.action_information12
            ,p_action_information13         =>  csr_action_info_rec.action_information13
            ,p_action_information14         =>  csr_action_info_rec.action_information14
            ,p_action_information15         =>  csr_action_info_rec.action_information15
            ,p_action_information16         =>  csr_action_info_rec.action_information16
            ,p_action_information17         =>  csr_action_info_rec.action_information17
            ,p_action_information18         =>  csr_action_info_rec.action_information18);
        --
        FOR csr_exception_info_rec IN csr_exception_info('NL_WR_EXCEPTION_REPORT',csr_action_info_rec.action_context_id) LOOP
            pay_action_information_api.create_action_information
            (
              p_action_information_id        =>  l_action_info_id
            , p_action_context_id            =>  p_assactid
            , p_action_context_type          =>  'AAP'
            , p_object_version_number        =>  l_ovn
            , p_assignment_id                =>  p_assignment_id
            , p_effective_date               =>  p_effective_date
            , p_source_id                    =>  NULL
            , p_source_text                  =>  NULL
            , p_tax_unit_id                  =>  l_tax_unit_id
            , p_action_information_category  =>  'NL_WR_EXCEPTION_REPORT'
            , p_action_information4          =>  csr_exception_info_rec.action_information4
            , p_action_information5          =>  csr_exception_info_rec.action_information5
            , p_action_information6          =>  csr_exception_info_rec.action_information6
            , p_action_information7          =>  csr_exception_info_rec.action_information7
            , p_action_information8          =>  csr_exception_info_rec.action_information8);
        END LOOP;
        --
        EXIT;
        --
    END LOOP;
    --
    FOR csr_ip_info_rec IN csr_ip_srg_info('NL_WR_INCOME_PERIOD','INITIAL',l_empt_action_info_id) LOOP
        --
        OPEN csr_get_income_start_date(p_assactid,p_assignment_id);
        FETCH csr_get_income_start_date INTO l_date;
        CLOSE csr_get_income_start_date;
        --Fnd_file.put_line(FND_FILE.LOG,'~~## IN NL_WR_INCOME_PERIOD');
        --Fnd_file.put_line(FND_FILE.LOG,'~~## l_empt_action_info_id '||l_empt_action_info_id);
        pay_action_information_api.create_action_information (
             p_action_information_id        =>  l_action_info_id
            ,p_action_context_id            =>  p_assactid
            ,p_action_context_type          =>  'AAP'
            ,p_object_version_number        =>  l_ovn
            ,p_assignment_id                =>  csr_ip_info_rec.assignment_id
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_tax_unit_id                  =>  l_tax_unit_id
            ,p_action_information_category  =>  'NL_WR_INCOME_PERIOD'
            ,p_action_information1          =>  'INITIAL'
            ,p_action_information2          =>  fnd_number.number_to_canonical(l_master_action_info_id)
            ,p_action_information3          =>  csr_ip_info_rec.action_information3
            ,p_action_information4          =>  csr_ip_info_rec.action_information4
            ,p_action_information5          =>  fnd_date.date_to_canonical(l_date) --fnd_date.date_to_canonical(p_start_date)
            ,p_action_information6          =>  csr_ip_info_rec.action_information6
            ,p_action_information7          =>  csr_ip_info_rec.action_information7
            ,p_action_information8          =>  csr_ip_info_rec.action_information8
            ,p_action_information9          =>  csr_ip_info_rec.action_information9
            ,p_action_information10         =>  csr_ip_info_rec.action_information10
            ,p_action_information11         =>  csr_ip_info_rec.action_information11
            ,p_action_information12         =>  csr_ip_info_rec.action_information12
            ,p_action_information13         =>  csr_ip_info_rec.action_information13
            ,p_action_information14         =>  csr_ip_info_rec.action_information14
            ,p_action_information15         =>  csr_ip_info_rec.action_information15
            ,p_action_information16         =>  csr_ip_info_rec.action_information16
            ,p_action_information17         =>  csr_ip_info_rec.action_information17
            ,p_action_information18         =>  csr_ip_info_rec.action_information18
            ,p_action_information19         =>  csr_ip_info_rec.action_information19
            ,p_action_information20         =>  csr_ip_info_rec.action_information20
            ,p_action_information21         =>  csr_ip_info_rec.action_information21
            ,p_action_information22         =>  csr_ip_info_rec.action_information22
            ,p_action_information23         =>  csr_ip_info_rec.action_information23
            ,p_action_information24         =>  csr_ip_info_rec.action_information24
            ,p_action_information25         =>  csr_ip_info_rec.action_information25
            ,p_action_information26         =>  csr_ip_info_rec.action_information26
            ,p_action_information27         =>  csr_ip_info_rec.action_information27);
    --
    END LOOP;
    --
    FOR csr_srg_info_rec IN csr_ip_srg_info('NL_WR_SWMF_SECTOR_RISK_GROUP','SECTOR_RISK_GROUP',l_empt_action_info_id) LOOP
        --
        OPEN csr_get_sector_start_date(p_assactid,p_assignment_id,csr_srg_info_rec.action_information7,csr_srg_info_rec.action_information8);
        FETCH csr_get_sector_start_date INTO l_date;
        CLOSE csr_get_sector_start_date;
        --Fnd_file.put_line(FND_FILE.LOG,'~~## IN NL_WR_SWMF_SECTOR_RISK_GROUP');
        pay_action_information_api.create_action_information (
             p_action_information_id        =>  l_action_info_id
            ,p_action_context_id            =>  p_assactid
            ,p_action_context_type          =>  'AAP'
            ,p_object_version_number        =>  l_ovn
            ,p_assignment_id                =>  csr_srg_info_rec.assignment_id
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_tax_unit_id                  =>  l_tax_unit_id
            ,p_action_information_category  =>  'NL_WR_SWMF_SECTOR_RISK_GROUP'
            ,p_action_information1          =>  'SECTOR_RISK_GROUP'
            ,p_action_information2          =>  fnd_number.number_to_canonical(l_master_action_info_id)
            ,p_action_information5          =>  fnd_date.date_to_canonical(l_date)--fnd_date.date_to_canonical(p_start_date)
            ,p_action_information6          =>  csr_srg_info_rec.action_information6--fnd_date.date_to_canonical(p_end_date)
            ,p_action_information7          =>  csr_srg_info_rec.action_information7
            ,p_action_information8          =>  csr_srg_info_rec.action_information8
            ,p_action_information9          =>  csr_srg_info_rec.action_information9
            ,p_action_information10         =>  csr_srg_info_rec.action_information10);
    --
    END LOOP;
    --
    FOR csr_address_info_rec IN csr_address_info('ADDRESS DETAILS','INITIAL',l_empt_action_info_id,l_action_context_id) LOOP
        --
        --Fnd_file.put_line(FND_FILE.LOG,'~~## IN ADD Det');
        pay_action_information_api.create_action_information (
             p_action_information_id        =>  l_action_info_id
            ,p_action_context_id            =>  p_assactid
            ,p_action_context_type          =>  'AAP'
            ,p_object_version_number        =>  l_ovn
            ,p_assignment_id                =>  csr_address_info_rec.assignment_id
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_tax_unit_id                  =>  l_tax_unit_id
            ,p_action_information_category  =>  'ADDRESS DETAILS'
            ,p_action_information1          =>  csr_address_info_rec.action_information1
            ,p_action_information5          =>  csr_address_info_rec.action_information5
            ,p_action_information6          =>  csr_address_info_rec.action_information6
            ,p_action_information7          =>  csr_address_info_rec.action_information7
            ,p_action_information8          =>  csr_address_info_rec.action_information8
            ,p_action_information9          =>  csr_address_info_rec.action_information9
            ,p_action_information10         =>  csr_address_info_rec.action_information10
            ,p_action_information11         =>  csr_address_info_rec.action_information11
            ,p_action_information12         =>  csr_address_info_rec.action_information12
            ,p_action_information13         =>  csr_address_info_rec.action_information13
            ,p_action_information14         =>  csr_address_info_rec.action_information14
            ,p_action_information26         =>  'INITIAL'
            ,p_action_information27         =>  fnd_number.number_to_canonical(l_master_action_info_id));
    --
    END LOOP;
    --
    FOR csr_nominative_info_rec IN csr_nominative_info('NL_WR_NOMINATIVE_REPORT','INITIAL',p_assactid) LOOP
        --
        --Fnd_file.put_line(FND_FILE.LOG,'~~## IN NL_WR_NOMINATIVE_REPORT');
        pay_action_information_api.create_action_information (
             p_action_information_id        =>  l_action_info_id
            ,p_action_context_id            =>  p_assactid
            ,p_action_context_type          =>  'AAP'
            ,p_object_version_number        =>  l_ovn
            ,p_assignment_id                =>  p_assignment_id
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_tax_unit_id                  =>  l_tax_unit_id
            ,p_action_information_category  =>  'NL_WR_NOMINATIVE_REPORT'
            ,p_action_information1          =>  'INITIAL'
            ,p_action_information2          =>  fnd_number.number_to_canonical(l_master_action_info_id)
            ,p_action_information3          =>  NULL
            ,p_action_information4          =>  NULL
            ,p_action_information5          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum5,2))
            ,p_action_information6          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum6,2))
            ,p_action_information7          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum7,2))
            ,p_action_information8          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum8,2))
            ,p_action_information9          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum9,2))
            ,p_action_information10         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum10,2))
            ,p_action_information11         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum11,2))
            ,p_action_information12         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum12,2))
            ,p_action_information13         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum13,2))
            ,p_action_information14         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum14,2))
            ,p_action_information15         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum15,2))
            ,p_action_information16         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum16,2))
            ,p_action_information17         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum17,2))
            ,p_action_information18         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum18,2))
            ,p_action_information19         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum19,2))
            ,p_action_information20         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum20,2))
            ,p_action_information21         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum21,2))
            ,p_action_information22         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum22,2))
            ,p_action_information23         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum23,2))
            ,p_action_information24         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum24,2))
            ,p_action_information25         =>  fnd_number.number_to_canonical(csr_nominative_info_rec.sum25)
            ,p_action_information26         =>  fnd_number.number_to_canonical(csr_nominative_info_rec.sum26)
            ,p_action_information27         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum27,2))
            ,p_action_information28         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum28,2))
            ,p_action_information29         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum29,2)));
    --
    END LOOP;
    --
    FOR csr_nominative_info_rec IN csr_nominative_info('NL_WR_NOMINATIVE_REPORT_ADD','INITIAL',p_assactid) LOOP
        --
        --Fnd_file.put_line(FND_FILE.LOG,'~~## IN NL_WR_NOMINATIVE_REPORT');
        pay_action_information_api.create_action_information (
             p_action_information_id        =>  l_action_info_id
            ,p_action_context_id            =>  p_assactid
            ,p_action_context_type          =>  'AAP'
            ,p_object_version_number        =>  l_ovn
            ,p_assignment_id                =>  p_assignment_id
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_tax_unit_id                  =>  l_tax_unit_id
            ,p_action_information_category  =>  'NL_WR_NOMINATIVE_REPORT_ADD'
            ,p_action_information1          =>  'INITIAL'
            ,p_action_information2          =>  fnd_number.number_to_canonical(l_master_action_info_id)
            ,p_action_information3          =>  NULL
            ,p_action_information4          =>  NULL
            ,p_action_information5          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum5,2))
            ,p_action_information6          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum6,2))
            ,p_action_information7          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum7,2))
            ,p_action_information8          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum8,2))
            ,p_action_information9          =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum9,2))
            ,p_action_information10         =>  fnd_number.number_to_canonical(ROUND(csr_nominative_info_rec.sum10,2)));
    --
    END LOOP;
    --
END archive_consolidate;
--------------------------------------------------------------------------------
-- POPULATE_NOM_BALNC_VAL_YRLY
--------------------------------------------------------------------------------
PROCEDURE populate_nom_balnc_val_yrly(p_master_assignment_action_id NUMBER
                                 ,p_assignment_action_id        NUMBER
                                 ,p_effective_date              DATE
                                 ,p_tax_unit_id                 NUMBER
                                 ,p_type                        VARCHAR2
                                 ,p_record_type                 VARCHAR2
                                 ,p_corr_used                   IN OUT NOCOPY VARCHAR2
                                 ,p_balance_values              IN OUT NOCOPY Bal_Value) IS --SR2
--
    l_balance_date DATE;
    l_context_id   NUMBER;
    l_source_text  VARCHAR2(50);
    l_source_text2  VARCHAR2(50);
    l_assignment_action_id NUMBER;
    l_context VARCHAR2(1);
    l_tax_unit_id NUMBER;
    --
    CURSOR  cur_act_contexts(p_context_name VARCHAR2 )IS
    SELECT  ffc.context_id
    FROM    ff_contexts   ffc
    WHERE   ffc.context_name = p_context_name;
--
BEGIN
    --
    p_balance_values.delete;
    FOR i IN g_nom_bal_def_table.FIRST..g_nom_bal_def_table.LAST LOOP
      p_balance_values(i).balance_value := 0;
      /*IF g_nom_bal_def_table(i).database_item_suffix IS NOT NULL THEN
        g_nom_bal_def_table(i).defined_balance_id := get_defined_balance_id(g_nom_bal_def_table(i).balance_name
                                                                           ,g_nom_bal_def_table(i).database_item_suffix);
        Fnd_file.put_line(FND_FILE.LOG,'#### g_nom_bal_def_table(i).defined_balance_id '||g_nom_bal_def_table(i).defined_balance_id);
      END IF;*/
      IF g_nom_bal_def_table(i).defined_balance_id <> 0  THEN
        Fnd_file.put_line(FND_FILE.LOG,'#### Point 1');
        l_assignment_action_id := p_assignment_action_id;
        l_context := 'N';
        l_balance_date := NULL;
        l_context_id := NULL;
        l_source_text := NULL;
        l_source_text2 := NULL;
        l_tax_unit_id := p_tax_unit_id;
        --
        IF g_nom_bal_def_table(i).database_item_suffix LIKE '%/_SIT/_%' ESCAPE '/' THEN
            OPEN  cur_act_contexts('SOURCE_TEXT');
            FETCH cur_act_contexts INTO l_context_id;
            CLOSE cur_act_contexts;
            l_source_text := g_nom_bal_def_table(i).context_val;
            l_context := 'Y';
        END IF;
        --
        Fnd_file.put_line(FND_FILE.LOG,'#### p_assignment_action_id '||p_assignment_action_id);
        IF p_assignment_action_id = 0 OR p_assignment_action_id is NULL THEN
          p_balance_values(i).balance_value := 0;
        ELSE
          IF l_context = 'Y' THEN
            BEGIN
            Fnd_file.put_line(FND_FILE.LOG,'#### Point 2');
              p_balance_values(i).balance_value := pay_balance_pkg.get_value
                         (p_defined_balance_id   => g_nom_bal_def_table(i).defined_balance_id
                         ,p_assignment_action_id => l_assignment_action_id
                         ,p_tax_unit_id          => p_tax_unit_id
                         ,p_jurisdiction_code    => NULL
                         ,p_source_id            => l_context_id
                         ,p_source_text          => l_source_text
                         ,p_tax_group            => NULL
                         ,p_date_earned          => NULL
                         ,p_get_rr_route         => NULL
                         ,p_get_rb_route         => NULL
                         ,p_source_text2         => l_source_text2
                         ,p_source_number        => NULL
                         ,p_time_def_id          => NULL
                         ,p_balance_date         => l_balance_date
                         ,p_payroll_id           => NULL);
            Fnd_file.put_line(FND_FILE.LOG,'#########p_balance_values(i).balance_value'||p_balance_values(i).balance_value);
            EXCEPTION
              WHEN OTHERS THEN
                 p_balance_values(i).balance_value := 0;
            END;
          ELSE
            BEGIN
              Fnd_file.put_line(FND_FILE.LOG,'#### Point 3');
              p_balance_values(i).balance_value := pay_balance_pkg.get_value
                         (p_defined_balance_id   => g_nom_bal_def_table(i).defined_balance_id
                         ,p_assignment_action_id => l_assignment_action_id
                         ,p_tax_unit_id          => p_tax_unit_id
                         ,p_jurisdiction_code    => NULL
                         ,p_source_id            => NULL
                         ,p_source_text          => NULL
                         ,p_tax_group            => NULL
                         ,p_date_earned          => NULL
                         ,p_get_rr_route         => NULL
                         ,p_get_rb_route         => NULL
                         ,p_source_text2         => NULL
                         ,p_source_number        => NULL
                         ,p_time_def_id          => NULL
                         ,p_balance_date         => NULL
                         ,p_payroll_id           => NULL);
            Fnd_file.put_line(FND_FILE.LOG,'#########'||p_balance_values(i).balance_value);
            EXCEPTION
              WHEN OTHERS THEN
                 p_balance_values(i).balance_value := 0;
            END;
          END IF;
        END IF;
      END IF;
    END LOOP;
   --
END populate_nom_balnc_val_yrly;
--------------------------------------------------------------------------------
-- ARCHIVE_YEAR_END
--------------------------------------------------------------------------------
PROCEDURE archive_year_end(p_assactid       NUMBER
                          ,p_assignment_id  NUMBER
                          ,p_effective_date DATE
                          ,p_business_gr_id NUMBER
                          ,p_tax_unit_id    NUMBER
                          ,p_chk_start_date DATE
                          ,p_chk_end_date   DATE
                          ,p_payroll_type   VARCHAR2) IS


CURSOR csr_get_emp_data(c_assignment_id  NUMBER
                         ,c_effective_date DATE) IS
  SELECT pap.person_id
        ,pap.national_identifier sofi_number
        ,pap.employee_number
        ,pap.nationality
        ,pap.date_of_birth dob
        ,pap.pre_name_adjunct prefix
        ,pap.last_name
        ,UPPER(replace(replace(pap.per_information1,'.',''),' ','')) initials
        ,decode(pap.sex,'M',1,'F',2,NULL) gender
        ,paaf.assignment_id
        ,paaf.change_reason
        ,paaf.assignment_number
        ,paaf.assignment_sequence
        ,paaf.employment_category
        ,paaf.employee_category
        ,paaf.collective_agreement_id
        ,paaf.effective_start_date
        ,paaf.soft_coding_keyflex_id
        ,paaf.assignment_status_type_id
        ,paaf.payroll_id
        ,paaf.primary_flag
  FROM   per_all_assignments_f paaf
        ,per_all_people_f pap
  WHERE  paaf.assignment_id          = c_assignment_id
  AND    paaf.person_id              = pap.person_id
  AND    c_effective_date   BETWEEN paaf.effective_start_date
                                AND paaf.effective_end_date
  AND    c_effective_date   BETWEEN pap.effective_start_date
                                AND pap.effective_end_date;
  --
  CURSOR csr_get_cao_code(c_collective_agreement_id NUMBER) IS
  SELECT pca.cag_information1
  FROM   per_collective_agreements pca
  WHERE  pca.collective_agreement_id = c_collective_agreement_id
  AND    pca.cag_information_category= 'NL';
  --
  CURSOR csr_get_assignment_action_id(c_assignment_id NUMBER
                                     ,c_date          DATE) IS
  SELECT max(paa.assignment_action_id) assignment_action_id
  FROM   pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,per_time_periods ptp
  WHERE  paa.assignment_id      = c_assignment_id
  AND    ppa.payroll_action_id  = paa.payroll_action_id
  AND    ppa.action_type        IN ('R','Q')
  AND    paa.ACTION_STATUS      = 'C'
  AND    ppa.ACTION_STATUS      = 'C'
  --AND    ppa.date_earned between c_start_date AND c_end_date;
  AND    ppa.time_period_id = ptp.time_period_id
  AND    c_date BETWEEN ptp.start_date AND ptp.end_date;
  --
  CURSOR csr_get_assignment_action_id2(c_assignment_id NUMBER
                                      ,c_date          DATE
                                      ,c_end_date      DATE) IS
  SELECT max(paa.assignment_action_id) assignment_action_id
  FROM   pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,per_time_periods ptp
  WHERE  paa.assignment_id      = c_assignment_id
  AND    ppa.payroll_action_id  = paa.payroll_action_id
  AND    ppa.action_type        IN ('R','Q','I','B')
  AND    paa.ACTION_STATUS      = 'C'
  AND    ppa.ACTION_STATUS      = 'C'
--  AND    ppa.date_earned between c_start_date AND c_end_date;
  AND    ppa.time_period_id = ptp.time_period_id
  AND    ptp.end_date BETWEEN c_date AND c_end_date;
  --
  CURSOR csr_get_shared_types(c_code           VARCHAR2
                            ,c_business_gr_id NUMBER
                            ,c_lookup         VARCHAR2) IS
  SELECT business_group_id,system_type_cd
  FROM   per_shared_types
  WHERE  lookup_type        = c_lookup --'NL_NATIONALITY'
  AND    information1       = c_code
  AND    (business_group_id = c_business_gr_id
          OR business_group_id is NULL)
  ORDER BY 1;
  --
  CURSOR csr_get_period(c_payroll_id NUMBER,c_date DATE) IS
  SELECT ptp.start_date,ptp.end_date
  FROM   per_time_periods ptp
  WHERE  ptp.payroll_id = c_payroll_id
  AND    c_date between ptp.start_date and ptp.end_date;
  --
  CURSOR csr_get_element_det(c_element_name   VARCHAR2
                            ,c_input_val_name VARCHAR2
                            ,c_assignment_id  NUMBER
                            ,c_eff_date       DATE) IS
  SELECT peev.screen_entry_value
  FROM   pay_element_types_f pet
        ,pay_input_values_f piv
        ,pay_element_entries_f peef
        ,pay_element_entry_values_f peev
  WHERE  pet.element_name = c_element_name
  AND    pet.element_type_id = piv.element_type_id
  AND    piv.name = c_input_val_name
  AND    pet.legislation_code  = 'NL'
  AND    piv.legislation_code  = 'NL'
  AND    peef.assignment_id    = c_assignment_id
  AND    peef.element_entry_id = peev.element_entry_id
  AND    peef.element_type_id  = pet.element_type_id
  AND    peev.input_value_id   = piv.input_value_id
  AND    c_eff_date            BETWEEN piv.effective_start_date
                                   AND piv.effective_end_date
  AND    c_eff_date            BETWEEN pet.effective_start_date
                                   AND pet.effective_end_date
  AND    c_eff_date            BETWEEN peev.effective_start_date
                                   AND peev.effective_end_date
  AND    c_eff_date            BETWEEN peef.effective_start_date
                                   AND peef.effective_end_date;
  --
  CURSOR csr_get_element_name2(c_element_entry_value_id NUMBER
                              ,c_eff_date               DATE) IS
  SELECT pet.element_name
        ,peev.screen_entry_value
  FROM   pay_element_types_f pet
        ,pay_element_entries_f peef
        ,pay_element_entry_values_f peev
  WHERE  peev.element_entry_value_id = c_element_entry_value_id
  AND    peev.element_entry_id       = peef.element_entry_id
  AND    peef.element_type_id        = pet.element_type_id
  AND    pet.legislation_code        = 'NL'
  AND    c_eff_date            BETWEEN pet.effective_start_date
                                   AND pet.effective_end_date
  AND    c_eff_date            BETWEEN peev.effective_start_date
                                   AND peev.effective_end_date
  AND    c_eff_date            BETWEEN peef.effective_start_date
                                   AND peef.effective_end_date;
  --
  CURSOR csr_get_element_name1(c_element_entry_id NUMBER
                              ,c_eff_date         DATE) IS
  SELECT pet.element_name
        ,peev.screen_entry_value
  FROM   pay_element_types_f pet
        ,pay_element_entries_f peef
        ,pay_element_entry_values_f peev
  WHERE  peef.element_entry_id = c_element_entry_id
  AND    peev.element_entry_id = peef.element_entry_id
  AND    peef.element_type_id  = pet.element_type_id
  AND    pet.legislation_code        = 'NL'
  AND    c_eff_date      BETWEEN pet.effective_start_date
                             AND pet.effective_end_date
  AND    c_eff_date      BETWEEN peev.effective_start_date
                             AND peev.effective_end_date
  AND    c_eff_date      BETWEEN peef.effective_start_date
                             AND peef.effective_end_date; /*assuming one input value*/
  --
  CURSOR csr_get_eit_cao(c_assignment_id NUMBER) IS
  SELECT aei_information5
  FROM   per_assignment_extra_info
  WHERE  assignment_id = c_assignment_id
  AND    aei_information_category IN ('NL_CADANS_INFO');
  --
  CURSOR csr_ass_start_date(c_assignment_id NUMBER) IS
  SELECT min(effective_start_date)
        --,decode(max(effective_end_date),to_date('31-12-4712','dd-mm-yyyy'),null,max(effective_end_date))
  FROM   per_all_assignments_F paaf
        ,PER_ASSIGNMENT_STATUS_TYPES  ast
  WHERE  paaf.assignment_id = c_assignment_id
  AND    paaf.assignment_status_type_id  = ast.assignment_status_type_id
  AND    ast.per_system_status = 'ACTIVE_ASSIGN';
  --
  CURSOR csr_ass_end_date(c_assignment_id NUMBER) IS
  SELECT decode(max(effective_end_date),to_date('31-12-4712','dd-mm-yyyy'),null,max(effective_end_date))
  FROM   per_all_assignments_F paaf
        ,PER_ASSIGNMENT_STATUS_TYPES  ast
  WHERE  paaf.assignment_id = c_assignment_id
  AND    paaf.assignment_status_type_id  = ast.assignment_status_type_id
  AND    ast.per_system_status <> 'TERM_ASSIGN';
  --
  CURSOR csr_ass_end_date2(c_assignment_id NUMBER) IS
  SELECT min(effective_start_date)
  FROM   per_all_assignments_F paaf
        ,PER_ASSIGNMENT_STATUS_TYPES  ast
  WHERE  paaf.assignment_id = c_assignment_id
  AND    paaf.assignment_status_type_id  = ast.assignment_status_type_id
  AND    ast.per_system_status = 'TERM_ASSIGN';
  --
  -- /*LC 2010 */ begin
  CURSOR csr_get_small_job_detail(c_assignment_action_id  NUMBER
                                 ,c_eff_date       DATE) IS
    SELECT prrv.result_value
    FROM   pay_run_result_values prrv
          ,pay_input_values_f piv
          ,pay_element_types_f pet
          ,pay_run_results prr
    WHERE  pet.element_name = 'Small Job Indicator'
    AND    pet.element_type_id = piv.element_type_id
    AND    piv.name = 'Exempt Small Jobs'
    AND    pet.legislation_code  = 'NL'
    AND    piv.legislation_code  = 'NL'
    AND    prrv.input_value_id   = piv.input_value_id
    AND    prr.run_result_id     = prrv.run_result_id
    AND    prr.element_type_id   = pet.element_type_id
    AND    prr.assignment_action_id = c_assignment_action_id
    AND    prr.status in ('P','PA')
    AND    c_eff_date            BETWEEN piv.effective_start_date
                                     AND piv.effective_end_date
    AND    c_eff_date            BETWEEN pet.effective_start_date
                                     AND pet.effective_end_date;

  CURSOR csr_get_other_assignments(c_assg_id           NUMBER
                                  ,c_start_date        DATE
                                  ,c_end_date          DATE
                                  ,c_business_group_id NUMBER
                                  ,c_tax_unit_id       NUMBER) IS
   SELECT  distinct asl.assignment_id assignment_id
    FROM   per_all_assignments_f asl
          ,per_all_assignments_f asl2
          ,pay_payroll_actions ppa
          ,pay_assignment_actions paa
          ,per_time_periods  ptp
    WHERE  asl.person_id = asl2.person_id
    AND    asl2.assignment_id = c_assg_id
    AND    ppa.payroll_id = asl.payroll_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.source_action_id IS NULL
    AND    paa.tax_unit_id = c_tax_unit_id
    AND    ppa.business_group_id = c_business_group_id
    AND    ppa.time_period_id  = ptp.time_period_id
    AND    to_char(ptp.end_date,'RRRR') = to_char(c_start_date,'RRRR')
    AND    ppa.payroll_action_id = paa.payroll_action_id
    AND    paa.assignment_id = asl.assignment_id
    AND    asl.effective_start_date <= c_end_date
    AND    asl.effective_end_date   >= c_start_date;
    -- /*LC 2010 */ end
   /* 8328995 */
  cursor csr_numiv_override(p_asg_id number) is
  select aei_information1 NUMIV_OVERRIDE
  from per_assignment_extra_info
  where assignment_id = p_asg_id
    and aei_information_category = 'NL_NUMIV_OVERRIDE';
   l_numiv_override NUMBER;

  --soft_coding_keyflex_id
  l_nationality         per_shared_types.INFORMATION1%type;
  l_assignment_catg     per_shared_types.INFORMATION1%type;
  l_assignment_catg_old per_shared_types.INFORMATION1%type;
  l_emp_rec           csr_get_emp_data%rowtype;
  l_rec_changes       Rec_Changes;
  l_rec_changes_init  Rec_Changes;
  l_master_action_info_id pay_action_information.action_information_id%type;
  l_action_info_id pay_action_information.action_information_id%TYPE;
  l_period_start_date DATE;
  l_period_end_date   DATE;
  l_rec_start_date    DATE;
  l_emp_end_date      DATE;
  -- SCL Segment variables
  l_income_code       hr_soft_coding_keyflex.segment1%type;
  l_work_pattern      hr_soft_coding_keyflex.segment1%type;
  l_wage_tax_discount hr_soft_coding_keyflex.segment1%type;
  l_wage_tax_table    hr_soft_coding_keyflex.segment1%type;
  l_wage_aow          hr_soft_coding_keyflex.segment1%type;
  l_wage_wajong       hr_soft_coding_keyflex.segment1%type;
  l_emp_loan          hr_soft_coding_keyflex.segment1%type;
  l_transportation    hr_soft_coding_keyflex.segment1%type;
  --
  l_labour_rel_code   PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_ins_duty_code     PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_FZ_Code           PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_handicapped_code  PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_wao_insured       PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_ww_insured        PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zw_insured        PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zvw_situation     PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;
  l_zvw_defaulted     VARCHAR2(1);
  l_zvw_small_jobs   VARCHAR2(1);/* LC 2010*/
  l_marginal_empl    PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;/* LC 2010*/
  l_wm_old_rule      PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION1%type;/* LC 2010*/
  --
  l_small_job        pay_run_result_values.result_value%TYPE; /*LC 2010*/
  l_assg_small_job   pay_run_result_values.result_value%TYPE; /*LC 2010*/
  --
  l_assignment_id       NUMBER;
  l_chk VARCHAR2(2);
  p_date DATE;
  l_retro VARCHAR2(10);
  l_type  VARCHAR2(10);
  l_ovn     pay_action_information.object_version_number%type;
  l_cao_code per_collective_agreements.CAG_INFORMATION1%type;
  l_old_cao_code per_collective_agreements.CAG_INFORMATION1%type;
  l_bal_value Bal_Value;
  l_nom_bal_value Bal_Value;
  l_ret_table Ret_Table;
  l_assignment_action_id NUMBER;
  l_master_assignment_action_id  NUMBER;
  l_other_assignment_action_id   NUMBER; /*LC 2010*/
  ele_end_date DATE;
  l_bg   NUMBER;
  l_table1 pay_dated_tables.dated_table_id%type;
  l_table2 pay_dated_tables.dated_table_id%type;
  l_table3 pay_dated_tables.dated_table_id%type;
  l_ass_start_date DATE;
  l_ass_end_date DATE;
  --
  l_holiday_coupen  pay_element_entry_values_f.screen_entry_value%TYPE;
  l_income_increase pay_element_entry_values_f.screen_entry_value%TYPE;
  l_add_allowance   pay_element_entry_values_f.screen_entry_value%TYPE;
  l_company_car_use pay_element_entry_values_f.screen_entry_value%TYPE;
  l_val             pay_element_entry_values_f.screen_entry_value%TYPE;
  l_element_name    VARCHAR2(30);
  --
  l_cnt1 NUMBER;
  l_cnt2 NUMBER;
  l_cnt3 NUMBER;
  --
  l_srg_flag VARCHAR2(1);
  l_corr_used VARCHAR2(1);
  --
  CURSOR get_scl_id(c_assignment_id NUMBER
                   ,c_start_date    DATE) IS
  SELECT paaf.soft_coding_keyflex_id
  FROM   per_all_assignments_f paaf
  WHERE  assignment_id = c_assignment_id
  AND    c_start_date BETWEEN paaf.effective_start_date
                      AND     paaf.effective_end_date;
  --
  CURSOR csr_get_col_agreement_id (c_assignment_id NUMBER
                                  ,c_eff_date      DATE) IS
  SELECT collective_agreement_id
  FROM   per_All_assignments_F
  WHERE  assignment_id = c_assignment_id
  AND    c_eff_date BETWEEN effective_start_date AND effective_end_date;
  --
  --
  l_asg_id NUMBER;
  l_pay_act_id NUMBER;
  --
  l_scl_id    per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  --
  l_initial_flag    VARCHAR2(1);
  l_emp_seq per_all_Assignments_f.assignment_number%type;
  --
BEGIN
  --Fnd_file.put_line(FND_FILE.LOG,' Start chk_events');
  --Fnd_file.put_line(FND_FILE.LOG,' Assignment ID :'||p_assignment_id);
  l_assignment_id  := p_assignment_id;
  --
  OPEN  csr_ass_start_date(l_assignment_id);
  FETCH csr_ass_start_date INTO l_ass_start_date;
  CLOSE csr_ass_start_date;
  --
  OPEN  csr_ass_end_date(l_assignment_id);
  FETCH csr_ass_end_date INTO l_ass_end_date;
  CLOSE csr_ass_end_date;
  --
  l_emp_end_date := NULL;
  IF l_ass_end_date <= p_chk_end_date THEN
    l_emp_end_date := l_ass_end_date;
  END IF;
  p_date := LEAST(p_chk_end_date,NVL(l_emp_end_date,p_chk_end_date));
  --Fnd_file.put_line(FND_FILE.LOG,' Get employee Data on    : '||p_date);
  OPEN  csr_get_emp_data(l_assignment_id,p_date);
  FETCH csr_get_emp_data INTO l_emp_rec;
  CLOSE csr_get_emp_data;
  --
  l_emp_seq := NULL;
  IF p_chk_end_date  >= TO_DATE('01012007','DDMMYYYY') THEN
    l_emp_seq := l_emp_rec.assignment_sequence;
  END IF;
  --
  IF l_emp_rec.change_reason NOT IN ('NL1','NL2','NL3','NL4','NL5') THEN
      l_emp_rec.change_reason := NULL;
  END IF;
  --
  OPEN  csr_get_shared_types(l_emp_rec.nationality,p_business_gr_id,'NL_NATIONALITY');
  FETCH csr_get_shared_types INTO l_bg,l_nationality;
  CLOSE csr_get_shared_types;
  --
  l_type := 'INITIAL';
   /* 8328995 */
        l_numiv_override:=null;
	OPEN csr_numiv_override(p_assignment_id);
	FETCH csr_numiv_override INTO l_numiv_override;
	CLOSE csr_numiv_override;

   pay_action_information_api.create_action_information (
    p_action_information_id        =>  l_master_action_info_id
   ,p_action_context_id            =>  p_assactid
   ,p_action_context_type          =>  'AAP'
   ,p_object_version_number        =>  l_ovn
   ,p_assignment_id                =>  l_emp_rec.assignment_id
   ,p_effective_date               =>  p_effective_date
   ,p_source_id                    =>  NULL
   ,p_source_text                  =>  NULL
   ,p_tax_unit_id                  =>  p_tax_unit_id
   ,p_action_information_category  =>  'NL_WR_EMPLOYMENT_INFO'
   ,p_action_information1          =>  l_type
   ,p_action_information2          =>  fnd_date.date_to_canonical(GREATEST(p_chk_start_date,trunc(p_chk_end_date,'Y')))
   ,p_action_information3          =>  fnd_date.date_to_canonical(p_chk_end_date)
   ,p_action_information4          =>  l_emp_rec.assignment_number
   ,p_action_information5          =>  l_emp_rec.employee_number
   ,p_action_information6          =>  l_emp_rec.change_reason
   ,p_action_information8          =>  l_emp_rec.sofi_number
   ,p_action_information7          =>  l_emp_rec.person_id
   ,p_action_information9          =>  NULL -- l_emp_rec.Initials
   ,p_action_information10         =>  NULL -- l_emp_rec.prefix
   ,p_action_information11         =>  l_emp_rec.last_name
   ,p_action_information12         =>  fnd_date.date_to_canonical(l_emp_rec.dob)
   ,p_action_information13         =>  NULL -- l_nationality
   ,p_action_information14         =>  NULL -- l_emp_rec.gender
   ,p_action_information15         =>  fnd_date.date_to_canonical(l_ass_start_date)-- assignment_start_date
   ,p_action_information16         =>  fnd_date.date_to_canonical(l_ass_end_date)
   ,p_action_information17         =>  NULL
   ,p_action_information18         =>  nvl(l_numiv_override,l_emp_seq));   -- 8328995

  IF  g_contract_code_mapping = 'NL_EMPLOYMENT_CATG' THEN
      OPEN  csr_get_shared_types(l_emp_rec.employment_category,p_business_gr_id,g_contract_code_mapping);
      FETCH csr_get_shared_types INTO l_bg,l_assignment_catg;
      CLOSE csr_get_shared_types;
  ELSE
      OPEN  csr_get_shared_types(l_emp_rec.employee_category,p_business_gr_id,g_contract_code_mapping);
      FETCH csr_get_shared_types INTO l_bg,l_assignment_catg;
      CLOSE csr_get_shared_types;
  END IF;
  --
  l_income_code       := 'N';
  l_work_pattern      := 'N';
  l_wage_tax_discount := 'N';
  l_wage_tax_table    := 'N';
  l_wage_aow          := 'N';
  l_wage_wajong       := 'N';
  l_emp_loan          := 'N';
  l_transportation    := 'N';
  --Fnd_file.put_line(FND_FILE.LOG,' Get scl Data '||l_emp_rec.soft_coding_keyflex_id);
  get_scl_data(l_emp_rec.soft_coding_keyflex_id
              ,p_chk_end_date
              ,l_income_code
              ,l_work_pattern
              ,l_wage_tax_discount
              ,l_wage_tax_table
              ,l_wage_aow
              ,l_wage_wajong
              ,l_emp_loan
              ,l_transportation
              ,l_chk);
  --Fnd_file.put_line(FND_FILE.LOG,' Get Assignment EIT Data :'||l_assignment_id);
  get_assignment_extra_info(l_assignment_id  -- pick data for p_date
                           ,NULL
                           ,p_date
                           ,p_chk_start_date
                           ,p_chk_end_date
                           ,l_labour_rel_code
                           ,l_ins_duty_code
                           ,l_FZ_Code
                           ,l_handicapped_code
                           ,l_wao_insured
                           ,l_ww_insured
                           ,l_zw_insured
                           ,l_zvw_situation
                           ,l_marginal_empl /* LC 2010*/
                           ,l_wm_old_rule   /* LC 2010*/
                           ,l_chk);
  --
  --LC 2010--begin
  l_zvw_small_jobs := NULL;
  l_small_job := NULL;
    FOR assignments IN csr_get_other_assignments(l_assignment_id
                                                        ,p_chk_start_date
                                                        ,p_chk_end_date
                                                        ,p_business_gr_id
                                                        ,p_tax_unit_id)   LOOP

     l_other_assignment_action_id := NULL;
     l_assg_small_job := NULL;
      OPEN  csr_get_assignment_action_id(assignments.assignment_id,p_chk_start_date);
      FETCH csr_get_assignment_action_id INTO l_other_assignment_action_id;
      CLOSE csr_get_assignment_action_id;

      IF l_other_assignment_action_id IS NOT NULL THEN
        OPEN  csr_get_small_job_detail(l_other_assignment_action_id,p_date);
        FETCH csr_get_small_job_detail INTO l_assg_small_job;
        CLOSE csr_get_small_job_detail;
      END IF;

      IF l_assg_small_job IS NOT NULL THEN
        IF l_assg_small_job = 'N' THEN
          l_small_job := 'N';
          EXIT;
        ELSIF (l_small_job = 'F' OR l_small_job IS NULL) AND l_assg_small_job = 'F' THEN
          l_small_job := 'F';
        END IF;
      END IF;
    END LOOP;
  IF l_small_job = 'F' THEN
    IF l_zvw_situation <> 'J' OR l_zvw_situation IS NULL THEN
      l_zvw_situation := 'J';
      l_zvw_small_jobs := 'D';  --Defaulted to J
    END IF;
    IF l_ins_duty_code <> 'F' THEN
      l_ins_duty_code := l_ins_duty_code||'F'; --Append F
    END IF;
  ELSIF l_small_job = 'N' AND l_zvw_situation ='J' THEN
    l_zvw_small_jobs := 'W';  --Warning because of J when no Small Job Excempt
  END IF;
  --LC 2010--end
  --
  l_zvw_defaulted := NULL;
  IF l_zvw_situation IS NULL THEN
    l_zvw_situation := 'A';
    l_zvw_defaulted := 'Y';
  END IF;
  --
  /*OPEN  csr_get_element_det('Holiday Coupons','Receiving Coupons',l_assignment_id,p_date);
  FETCH csr_get_element_det INTO l_holiday_coupen;
  CLOSE csr_get_element_det;
  IF l_holiday_coupen = 'Y' THEN
    l_holiday_coupen := 'J';
  END IF;
  --
  OPEN  csr_get_element_det('Incidental Income Decrease','Decrease Code',l_assignment_id,p_date);
  FETCH csr_get_element_det INTO l_income_increase;
  CLOSE csr_get_element_det;
  --
  OPEN  csr_get_element_det('Additional Allowance','Receiving Allowance',l_assignment_id,p_date);
  FETCH csr_get_element_det INTO l_add_allowance;
  CLOSE csr_get_element_det;
  IF p_chk_end_date  >= TO_DATE('01012007','DDMMYYYY') THEN
    l_add_allowance := NULL;
  ELSIF l_add_allowance = 'Y' THEN
    l_add_allowance := 'J';
  END IF; */
  --
  OPEN  csr_get_element_det('Company Car Private Usage','Code Usage',l_assignment_id,p_date);
  FETCH csr_get_element_det INTO l_company_car_use;
  CLOSE csr_get_element_det;
  --
  --Fnd_file.put_line(FND_FILE.LOG,'  Get Element Data :');
  --Fnd_file.put_line(FND_FILE.LOG,'  l_company_car_use :'||l_company_car_use);
  --
 /* IF l_emp_rec.collective_agreement_id IS NULL THEN
    OPEN  csr_get_eit_cao(l_emp_rec.assignment_id);
    FETCH csr_get_eit_cao INTO l_cao_code;
    CLOSE csr_get_eit_cao;
    --Fnd_file.put_line(FND_FILE.LOG,' Collective Agreement id null get from eit :'||l_cao_code);
  ELSE
    OPEN  csr_get_cao_code(l_emp_rec.collective_agreement_id);
    FETCH csr_get_cao_code INTO l_cao_code;
    CLOSE csr_get_cao_code;
    --Fnd_file.put_line(FND_FILE.LOG,' Collective Agreement id not null get from collective agreement table. :'||l_cao_code);
  END IF;*/

  pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  p_assactid
     , p_action_context_type          =>  'AAP'
     , p_object_version_number        =>  l_ovn
     , p_assignment_id                =>  l_emp_rec.assignment_id
     , p_effective_date               =>  p_effective_date
     , p_action_information_category  =>  'NL_WR_INCOME_PERIOD'
     , p_tax_unit_id                  =>  p_tax_unit_id
     , p_action_information1          =>  l_type
     , p_action_information2          =>  l_master_action_info_id
     , p_action_information5          =>  fnd_date.date_to_canonical(GREATEST(GREATEST(p_chk_start_date,l_ass_start_date),trunc(p_chk_end_date,'Y'))) /*** EOY 0708 ...Start Date Income Peiod ***/
     , p_action_information6          =>  l_income_code
     , p_action_information7          =>  l_labour_rel_code
     , p_action_information8          =>  l_ins_duty_code
     , p_action_information9          =>  l_assignment_catg
     , p_action_information10         =>  l_FZ_Code
     , p_action_information11         =>  NULL -- l_work_pattern
     , p_action_information12         =>  NULL -- l_cao_code
     , p_action_information13         =>  l_handicapped_code
     , p_action_information14         =>  l_wage_tax_discount
     , p_action_information15         =>  l_company_car_use
     , p_action_information16         =>  l_wage_tax_table
     , p_action_information17         =>  l_wao_insured
     , p_action_information18         =>  l_ww_insured
     , p_action_information19         =>  l_zw_insured
     , p_action_information20         =>  NVL(l_zvw_situation,'A')
     , p_action_information21         =>  NULL -- l_holiday_coupen
     , p_action_information22         =>  l_wage_aow
     , p_action_information23         =>  l_wage_wajong
     , p_action_information24         =>  l_emp_loan
     , p_action_information25         =>  l_transportation
     , p_action_information26         =>  NULL -- l_income_increase
     , p_action_information27         =>  NULL -- l_add_allowance);
     , p_action_information28         =>  l_marginal_empl/* LC 2010*/
     , p_action_information29         =>  l_wm_old_rule);  /* LC 2010*/

   --Fnd_file.put_line(FND_FILE.LOG,' Creating NL_WR_EMPLOYMENT_INFO INfor Record for Type :'||l_type||' Date :'||l_period_start_date);
   --
   -- archive employee address not required for YEarly report
      /*archive_emp_address(p_assactid -- address not req for year end rep
                     ,l_emp_rec.person_id
                     ,l_emp_rec.assignment_id
                     ,l_emp_rec.assignment_number
                     ,l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                     ,p_tax_unit_id
                     ,l_master_action_info_id
                     ,p_effective_date
                     ,NVL(l_emp_end_date,p_chk_end_date)
                     ,l_type);*/
   -- archive sector information for assignment
   --Fnd_file.put_line(FND_FILE.LOG,' Archiving Sector Risk Group Record for Type :'||l_type);
   l_srg_flag := archive_sector_risk_group(p_assactid
                                          ,l_emp_rec.assignment_id
                                          ,p_effective_date
                                          ,p_tax_unit_id
                                          ,l_master_action_info_id
                                          ,p_chk_start_date
                                          ,p_chk_end_date
                                          ,l_ass_start_date
                                          ,l_emp_end_date
                                          ,p_payroll_type);
   --archive nominative info
  l_assignment_action_id := NULL;
  OPEN  csr_get_assignment_action_id2(l_emp_rec.assignment_id,p_chk_start_date,p_chk_end_date);
  FETCH csr_get_assignment_action_id2 INTO l_assignment_action_id;
  CLOSE csr_get_assignment_action_id2;
  Fnd_file.put_line(FND_FILE.LOG,' l_assignment_action_id in year-end:'||l_assignment_action_id);         --
  populate_nom_balnc_val_yrly(l_assignment_action_id
                             ,l_assignment_action_id
                             ,l_period_end_date
                             ,p_tax_unit_id
                             ,l_type
                             ,'HR'
                             ,l_corr_used
                             ,l_bal_value);
   Fnd_file.put_line(FND_FILE.LOG,' l_bal_value :'||l_bal_value(1).balance_value||','||l_bal_value(2).balance_value);              --
   get_nominative_data(l_bal_value,l_nom_bal_value);
   --
   Fnd_file.put_line(FND_FILE.LOG,' l_nom_bal_value :'||l_nom_bal_value(1).balance_value);
   archive_nominative_data(p_assactid
                          ,l_emp_rec.assignment_id
                          ,p_tax_unit_id
                          ,p_effective_date
                          ,p_effective_date
                          ,l_type
                          ,l_master_action_info_id
                          ,l_emp_rec.prefix || l_emp_rec.last_name || l_emp_rec.Initials
                          ,l_corr_used
                          ,p_payroll_type
                          ,l_nom_bal_value);
  EXCEPTION
    WHEN OTHERS THEN
        --Fnd_file.put_line(FND_FILE.LOG,' Others. Assignment :'||l_assignment_id);
        --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
        NULL;
END archive_year_end;
--------------------------------------------------------------------------------
-- ARCHIVE_CODE
--------------------------------------------------------------------------------
PROCEDURE archive_code (p_assactid       in number,
                        p_effective_date in date) IS
  --
  l_assignment_id per_all_assignments_f.assignment_id%type;
  l_business_group_id NUMBER;
  l_pactid            NUMBER;
  l_end_date          DATE;
  l_start_date        DATE;
  l_tax_unit_id       NUMBER;
  l_payroll_type      VARCHAR2(10);
  l_seq_no            VARCHAR2(15);
  --
BEGIN
    -- get Employee data
    --hr_utility.trace_on(null,'NL_WR');
    --
    --Fnd_file.put_line(FND_FILE.LOG,' Entering Archive Code for Assignment :'||p_assactid);
    select payroll_action_id,assignment_id
    into   l_pactid, l_assignment_id
    from   pay_assignment_actions
    where  assignment_action_id = p_assactid;
    --
    get_all_parameters (l_pactid
                       ,l_business_group_id
                       ,l_start_date
                       ,l_end_date
                       ,l_tax_unit_id
                       ,l_payroll_type
                       ,l_seq_no);
    --
    IF l_payroll_type = 'FOUR_WEEK' THEN
        --Fnd_file.put_line(FND_FILE.LOG,' Calling  archive_consolidate');
        archive_consolidate(p_assactid,l_assignment_id,p_effective_date,l_business_group_id,l_tax_unit_id,l_start_date,l_end_date,l_payroll_type);
    ELSIF l_payroll_type = 'YEARLY' THEN
        --Fnd_file.put_line(FND_FILE.LOG,' Calling  archive_year_end');
        archive_year_end(p_assactid,l_assignment_id,p_effective_date,l_business_group_id,l_tax_unit_id,l_start_date,l_end_date,l_payroll_type);
    ELSE
        --Fnd_file.put_line(FND_FILE.LOG,' Calling  chk_events');
        chk_events(p_assactid,l_assignment_id,p_effective_date,l_business_group_id,l_tax_unit_id,l_start_date,l_end_date,l_payroll_type);
    END IF;
    --Fnd_file.put_line(FND_FILE.LOG,' Leaving Archive Code');
    --
END archive_code;
--
--------------------------------------------------------------------------------
-- GET_ARCHIVE_DETAILS
--------------------------------------------------------------------------------
FUNCTION get_archive_details(p_actid IN  NUMBER) RETURN VARCHAR2
IS
--
  CURSOR csr_get_org_name (c_payroll_action_id NUMBER) IS
  SELECT action_information9
  FROM   pay_action_information pai
  WHERE  action_context_id           = c_payroll_action_id
  AND    action_context_type         = 'PA'
  AND    action_information_category = 'NL_WR_EMPLOYER_INFO';
  --
  CURSOR csr_chk_exception (c_payroll_action_id NUMBER) IS
  SELECT 'EXCEPTION'
  FROM   DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   pay_action_information pai
                 WHERE  action_context_id           = c_payroll_action_id
                 AND    action_information_category = 'NL_WR_EXCEPTION_REPORT')
  OR     EXISTS (SELECT 1
                 FROM   pay_assignment_actions paa
                       ,pay_action_information pai
                 WHERE  paa.payroll_action_id           = c_payroll_action_id
                 AND    pai.action_context_id           = paa.assignment_action_id
                 AND    pai.action_information_category = 'NL_WR_EXCEPTION_REPORT');
  --
  l_business_group_id NUMBER;
  l_end_date          DATE;
  l_start_date        DATE;
  l_tax_unit_id       NUMBER;
  l_payroll_type      VARCHAR2(10);
  l_seq_no            VARCHAR2(15);
  l_return_string     VARCHAR2(1000);
  l_tax_rep_name      PAY_ACTION_INFORMATION.ACTION_INFORMATION7%TYPE;
  l_exception         VARCHAR2(20);
--
BEGIN
  --
  pay_nl_wage_report_pkg.get_all_parameters(p_actid
                     ,l_business_group_id
                     ,l_start_date
                     ,l_end_date
                     ,l_tax_unit_id
                     ,l_payroll_type
                     ,l_seq_no);
  --
  OPEN  csr_get_org_name(p_actid);
  FETCH csr_get_org_name INTO l_tax_rep_name;
  CLOSE csr_get_org_name;
  --
  l_exception := 'NOEXCEPTION';
  OPEN  csr_chk_exception(p_actid);
  FETCH csr_chk_exception INTO l_exception;
  CLOSE csr_chk_exception;
  --
  l_return_string := rpad(fnd_date.date_to_displaydate(l_start_date),15)||'- '||rpad(fnd_date.date_to_displaydate(l_end_date),15);
  l_return_string := l_return_string ||'- '||rpad(HR_GENERAL.decode_lookup('NL_WR_PERIOD_TYPE',l_payroll_type),40);
  l_return_string := l_return_string ||'- '||rpad(l_tax_rep_name,40);
  l_return_string := l_return_string ||'- '||rpad(HR_GENERAL.decode_lookup('NL_FORM_LABELS',l_exception),25);
  --
  RETURN(l_return_string);
  --
END get_archive_details;
--
END pay_nl_wage_report_pkg;

/
