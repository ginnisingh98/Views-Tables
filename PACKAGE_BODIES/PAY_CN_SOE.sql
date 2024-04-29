--------------------------------------------------------
--  DDL for Package Body PAY_CN_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_SOE" AS
/* $Header: pycnsoe.pkb 120.7.12010000.2 2008/12/05 06:17:15 rsaharay ship $ */

   g_package     CONSTANT VARCHAR2(100) := 'pay_cn_soe.';
   g_debug       BOOLEAN;
   g_sql         LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GETELEMENTS                                         --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to return SQL for for regions of SOE       --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                  p_classification_name           VARCHAR2            --
--                  p_desc_column                   VARCHAR2            --
--                  p_pay_column                    VARCHAR2            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION getelements(p_assignment_action_id IN NUMBER
                    ,p_classification_name  IN VARCHAR2
                    ) RETURN LONG
IS
  l_procedure VARCHAR2(50);
  l_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;

  CURSOR csr_prepayments_action_id
  IS
    SELECT locking_action_id
      FROM pay_action_interlocks
     WHERE locked_action_id = p_assignment_action_id;
BEGIN

   l_procedure := 'getelements';
   hr_cn_api.set_location (g_debug,'Entering ' || l_procedure,10);

   OPEN  csr_prepayments_action_id;
   FETCH csr_prepayments_action_id INTO l_assignment_action_id;
   CLOSE csr_prepayments_action_id;

   IF l_assignment_action_id IS NULL THEN
      l_assignment_action_id := p_assignment_action_id;
   END IF;

   g_sql:='SELECT element_reporting_name COL02
                , TO_CHAR( DECODE(foreign_currency_code,NULL,amount,amount/exchange_rate)
		         , fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
             FROM pay_cn_asg_elements_v
            WHERE assignment_action_id     = ' || l_assignment_action_id || '
              AND classification_name      = ''' || p_classification_name || '''';

   hr_cn_api.set_location (g_debug,'Leaving ' || l_procedure,10);

   RETURN g_sql;

END getelements;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAXABLE_EARNINGS                                --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Earnings Region          --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_taxable_earnings(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := 'get_taxable_earnings';
    hr_cn_api.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements(p_assignment_action_id => p_assignment_action_id
                      ,p_classification_name  => 'Taxable Earnings'
                      );

END get_taxable_earnings;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_NON_TAXABLE_EARNINGS                            --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Non Taxable Earnings     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_non_taxable_earnings(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := 'get_non_taxable_earnings';
    hr_cn_api.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Non Taxable Earnings'
                      );

END get_non_taxable_earnings;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_statutory_deductions                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Statutory Deductions     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_statutory_deductions(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := 'get_statutory_deductions';
    hr_cn_api.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Statutory Deductions'
                      );

END get_statutory_deductions;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_non_statutory_deductions                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Statutory Deductions     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_non_statutory_deductions(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := 'get_non_statutory_deductions';
    hr_cn_api.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Pre Tax Non Statutory Deductions'
                      );

END get_non_statutory_deductions;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_VOLUNTARY_DEDUCTIONS                            --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Voluntary Deductions     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_voluntary_deductions(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := 'get_voluntary_deductions';
    hr_cn_api.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Voluntary Dedn'
                      );

END get_voluntary_deductions;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCES                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Balances Region          --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_balances( p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

   l_sql LONG;
   l_date_earned DATE;
   l_tax_unit_id NUMBER;

   CURSOR csr_get_date_earned
   IS
     SELECT ppa.date_earned
       FROM pay_payroll_actions    ppa
          , pay_assignment_actions paa
      WHERE ppa.payroll_action_id    = paa.payroll_action_id
        AND paa.assignment_action_id = p_assignment_action_id;

   CURSOR csr_get_tax_unit_id
   IS
     SELECT hsck.segment1
       FROM hr_soft_coding_keyflex        hsck
          , per_assignments_f             paf
          , pay_assignment_actions        paa
          , pay_payroll_actions           ppa
      WHERE hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
        AND paa.assignment_action_id    = p_assignment_action_id
        AND paa.payroll_action_id       = ppa.payroll_action_id
        AND paf.assignment_id           = paa.assignment_id
        AND ppa.effective_date    BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date;

BEGIN

   OPEN  csr_get_date_earned;
   FETCH csr_get_date_earned INTO l_date_earned;
   CLOSE csr_get_date_earned;

   OPEN  csr_get_tax_unit_id;
   FETCH csr_get_tax_unit_id INTO l_tax_unit_id;
   CLOSE csr_get_tax_unit_id;

   g_sql := 'SELECT NVL(pbt.reporting_name, pbt.balance_name) COL04
                  , TO_CHAR(pay_balance_pkg.get_value( pdb_ptd.defined_balance_id
                                                     , ' || p_assignment_action_id || '
						     , ' || l_tax_unit_id || '
						     , NULL
						     , NULL
						     , NULL
						     , NULL
						     , fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(l_date_earned) || ''')
						     , NULL
						     , NULL
						     )
                           ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
                  , TO_CHAR(pay_balance_pkg.get_value( pdb_ytd.defined_balance_id
                                                     , ' || p_assignment_action_id || '
						     , ' || l_tax_unit_id || '
						     , NULL
						     , NULL
						     , NULL
						     , NULL
						     , fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(l_date_earned) || ''')
						     , NULL
						     , NULL
						     )
                           ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL18
             FROM pay_balance_types              pbt
                , pay_balance_dimensions         pbd_ptd
                , pay_balance_dimensions         pbd_ytd
                , pay_defined_balances           pdb_ptd
                , pay_defined_balances           pdb_ytd
            WHERE pbt.balance_name          IN ( ''Taxable Earnings''
                                               , ''Non Taxable Earnings''
                                               , ''Statutory Deductions''
                                               , ''Voluntary Deductions''
                                               , ''Special Payments''
                                               , ''Employer Liabilities''
					       , ''Pre Tax Non Statutory Deductions'')
              AND pbd_ptd.dimension_name       = ''_ASG_PTD''
              AND pbd_ytd.dimension_name       = ''_ASG_YTD''
              AND pbt.legislation_code         = ''CN''
              AND pbd_ptd.legislation_code     = ''CN''
              AND pbd_ytd.legislation_code     = ''CN''
              AND pbd_ptd.balance_dimension_id = pdb_ptd.balance_dimension_id
              AND pbt.balance_type_id          = pdb_ptd.balance_type_id
              AND pbd_ytd.balance_dimension_id = pdb_ytd.balance_dimension_id
              AND pbt.balance_type_id          = pdb_ytd.balance_type_id
              ORDER BY DECODE(pbt.balance_name,''Taxable Earnings'',''Taxable Earnings'')
                     , DECODE(pbt.balance_name,''Non Taxable Earnings'',''Non Taxable Earnings'')
		     , DECODE(pbt.balance_name,''Pre Tax Non Statutory Deductions'',''Pre Tax Non Statutory Deductions'')
                     , DECODE(pbt.balance_name,''Statutory Deductions'',''Statutory Deductions'')
                     , DECODE(pbt.balance_name,''Voluntary Deductions'',''Voluntary Deductions'')';

   RETURN g_sql;

END get_balances;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PAYMENT_METHODS                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Payments Method Region   --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_payment_methods(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
BEGIN

  g_sql := 'SELECT org_payment_method_name                               COL01
                 , TO_CHAR(:G_CURRENCY_CODE)                             COL04
                 , pay_soe_util.getBankDetails('':legislation_code''
                                              ,ppm.external_account_id
                                              ,''BANK_NAME''
                                              ,NULL)                     COL02
                 , pay_soe_util.getBankDetails('':legislation_code''
                                              ,ppm.external_account_id
                                              ,''BANK_BRANCH''
                                              ,NULL)                     COL05
                 , pay_soe_util.getBankDetails('':legislation_code''
                                              ,ppm.external_account_id
                                              ,''BANK_ACCOUNT_NUMBER''
                                              ,NULL)                     COL03
                 , to_char(pp.value
	                  ,fnd_currency.get_format_mask(:G_CURRENCY_CODE
		                                       ,40)
                          )                                              COL16
              FROM pay_pre_payments               pp
                 , pay_personal_payment_methods_f ppm
                 , pay_org_payment_methods_f      opm
                 , pay_payment_types_tl           pt
             WHERE pp.assignment_action_id IN
                            (SELECT ai.locking_action_id
                               FROM pay_action_interlocks ai
                              WHERE ai.locked_action_id :action_clause)
               AND pp.personal_payment_method_id = ppm.personal_payment_method_id(+)
               AND :effective_date         BETWEEN ppm.effective_start_date(+)
	                                       AND ppm.effective_end_date(+)
               AND pp.org_payment_method_id      = opm.org_payment_method_id
               AND :effective_date         BETWEEN opm.effective_start_date
	                                       AND opm.effective_end_date
               AND opm.payment_type_id           = pt.payment_type_id
               AND pt.language                   = USERENV(''LANG'')';
--
  RETURN g_sql;

END get_payment_methods;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_OTHER_ELEMENT_INFORMATION                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Other Element            --
--                  Information Region                                  --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_other_element_information(p_assignment_action_id IN OUT NOCOPY pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

CURSOR csr_prepayment
IS
SELECT MAX(locked_action_id)
FROM   pay_action_interlocks
WHERE  locking_action_id = p_assignment_action_id;

l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;


BEGIN

OPEN csr_prepayment;
FETCH csr_prepayment INTO l_assignment_action_id;
CLOSE csr_prepayment;

IF l_assignment_action_id IS NOT NULL THEN
     p_assignment_action_id := l_assignment_action_id;
END IF;

g_sql :=
 'SELECT org.org_information7 COL02
       , prv.result_value COL16
    FROM pay_run_result_values  prv,
         pay_run_results        prr,
         hr_organization_information_v org
   WHERE prr.status IN (''P'',''PA'')
     AND org.org_information_context = ''Business Group:SOE Detail''
     AND org.org_information1       = ''ELEMENT''
     AND prv.run_result_id          = prr.run_result_id
     AND prr.assignment_action_id   = ' || p_assignment_action_id || '
     AND prr.element_type_id        = org.org_information2
     AND prv.input_value_id         = org.org_information3
     AND prv.result_value IS NOT NULL';

 RETURN g_sql;


END get_other_element_information;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_OTHER_BALANCE_INFORMATION                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Other Balance            --
--                  Information Region                                  --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_other_balance_information(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

   l_date_earned DATE;
   l_tax_unit_id NUMBER;
   l_business_group_id per_business_groups.business_group_id%TYPE;

   CURSOR csr_get_date_earned
   IS
     SELECT ppa.date_earned, ppa.business_group_id
       FROM pay_payroll_actions    ppa
          , pay_assignment_actions paa
      WHERE ppa.payroll_action_id    = paa.payroll_action_id
        AND paa.assignment_action_id = p_assignment_action_id;

   CURSOR csr_get_tax_unit_id
   IS
     SELECT hsck.segment1
       FROM hr_soft_coding_keyflex        hsck
          , per_assignments_f             paf
          , pay_assignment_actions        paa
          , pay_payroll_actions           ppa
      WHERE hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
        AND paa.assignment_action_id    = p_assignment_action_id
        AND paa.payroll_action_id       = ppa.payroll_action_id
        AND paf.assignment_id           = paa.assignment_id
        AND ppa.effective_date    BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date;

BEGIN

   OPEN  csr_get_date_earned;
   FETCH csr_get_date_earned INTO l_date_earned, l_business_group_id;
   CLOSE csr_get_date_earned;

   OPEN  csr_get_tax_unit_id;
   FETCH csr_get_tax_unit_id INTO l_tax_unit_id;
   CLOSE csr_get_tax_unit_id;

   g_sql := 'SELECT org.org_information7 COL02
                  , TO_CHAR(pay_balance_pkg.get_value( pdb.defined_balance_id
                                                     , ' || p_assignment_action_id || '
						     , ' || l_tax_unit_id || '
						     , NULL
						     , NULL
						     , NULL
						     , NULL
						     , fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(l_date_earned) || ''')
						     , NULL
						     , NULL
						     )
                           ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
	       FROM pay_defined_balances           pdb
                  , hr_organization_information_v  org
              WHERE org.organization_id = ' || l_business_group_id || '
                AND org.org_information_context = ''Business Group:SOE Detail''
                AND org.org_information1        = ''BALANCE''
                AND pdb.balance_type_id         = org.org_information4
                AND pdb.balance_dimension_id    = org.org_information5';

   RETURN g_sql;

END get_other_balance_information;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ANNUAL_LEAVE_INFORMATION                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Annual Leave             --
--                  Information Region                                  --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_annual_leave_information(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

CURSOR csr_get_annual_leave_details(p_payroll_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
IS
      SELECT  pap.accrual_plan_name
             ,hr_general_utilities.get_lookup_meaning('US_PTO_ACCRUAL',pap.accrual_category)
             ,hr_general.decode_lookup('HOURS_OR_DAYS',pap.accrual_units_of_measure)
             ,ppa.payroll_id
             ,pap.business_group_id
             ,pap.accrual_plan_id
	     ,paa.assignment_id
      FROM    pay_accrual_plans             pap
             ,pay_element_types_f           pet
             ,pay_element_links_f           pel
             ,pay_element_entries_f         pee
             ,pay_assignment_actions        paa
             ,pay_payroll_actions           ppa
      WHERE   pet.element_type_id         = pap.accrual_plan_element_type_id
      AND     pel.element_type_id         = pet.element_type_id
      AND     pee.element_link_id         = pel.element_link_id
      AND     paa.assignment_id           = pee.assignment_id
      AND     ppa.payroll_action_id       = paa.payroll_action_id
      AND     ppa.action_type            IN ('R','Q')
      AND     ppa.action_status           = 'C'
      AND     ppa.date_earned       BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
      AND     ppa.date_earned       BETWEEN pel.effective_start_date
                                    AND     pel.effective_end_date
      AND     ppa.date_earned       BETWEEN pee.effective_start_date
                                    AND     pee.effective_end_date
      AND     paa.assignment_action_id    = p_payroll_assignment_action_id;

   CURSOR csr_get_date_earned
   IS
     SELECT ppa.date_earned
       FROM pay_payroll_actions    ppa
          , pay_assignment_actions paa
      WHERE ppa.payroll_action_id    = paa.payroll_action_id
        AND paa.assignment_action_id = p_assignment_action_id;

CURSOR csr_prepayment
IS
SELECT MAX(locked_action_id)
FROM   pay_action_interlocks
WHERE  locking_action_id = p_assignment_action_id;

l_plan_name         pay_accrual_plans.accrual_plan_name%TYPE;
l_accrual_category  pay_accrual_plans.accrual_category%TYPE;
l_uom               pay_accrual_plans.accrual_units_of_measure%TYPE;
l_payroll_id        pay_payrolls_f.payroll_id%TYPE;
l_business_group_id per_business_groups.business_group_id%TYPE;
l_accrual_plan_id   pay_accrual_plans.accrual_plan_id%TYPE;
l_assignment_id     per_assignments_f.assignment_id%TYPE;
l_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE;
l_annual_leave_balance       NUMBER;
l_ovn                        NUMBER;
l_leave_taken                NUMBER;
l_start_date                 DATE;
l_end_date                   DATE;
l_accrual_end_date           DATE;
l_date_earned                DATE;
l_accrual                    NUMBER;
l_total_leave_taken          NUMBER;
l_procedure                  VARCHAR2(100);

BEGIN

OPEN csr_prepayment;
FETCH csr_prepayment INTO l_assignment_action_id;
CLOSE csr_prepayment;

   IF l_assignment_action_id IS NULL THEN
        l_assignment_action_id := p_assignment_action_id;
   END IF;

   OPEN  csr_get_annual_leave_details(l_assignment_action_id);
   FETCH csr_get_annual_leave_details
    INTO l_plan_name
       , l_accrual_category
       , l_uom
       , l_payroll_id
       , l_business_group_id
       , l_accrual_plan_id
       , l_assignment_id;
   CLOSE csr_get_annual_leave_details;

   OPEN  csr_get_date_earned;
   FETCH csr_get_date_earned INTO l_date_earned;
   CLOSE csr_get_date_earned;


   per_accrual_calc_functions.get_net_accrual
        ( p_assignment_id     => l_assignment_id
        , p_plan_id           => l_accrual_plan_id
        , p_payroll_id        => l_payroll_id
        , p_business_group_id => l_business_group_id
        , p_calculation_date  => l_date_earned
        , p_start_date        => l_start_date
        , p_end_date          => l_end_date
        , p_accrual_end_date  => l_accrual_end_date
        , p_accrual           => l_accrual
        , p_net_entitlement   => l_annual_leave_balance
        );

   g_sql := 'SELECT ''' || l_plan_name            || ''' COL01
                  , ''' || l_uom                  || ''' COL02
		  , TO_CHAR(' || l_annual_leave_balance|| ',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
	       FROM DUAL';

   RETURN g_sql;

END get_annual_leave_information;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LEAVE_TAKEN                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Leave Taken Region       --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_leave_taken(p_assignment_action_id IN OUT NOCOPY pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

CURSOR csr_prepayment
IS
SELECT MAX(locked_action_id)
FROM   pay_action_interlocks
WHERE  locking_action_id = p_assignment_action_id;

l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;

BEGIN

OPEN csr_prepayment;
FETCH csr_prepayment INTO l_assignment_action_id;
CLOSE csr_prepayment;

IF l_assignment_action_id IS NOT NULL THEN
      p_assignment_action_id := l_assignment_action_id;
END IF;


   g_sql :=
      '      SELECT pet.reporting_name                                                                                          COL01
            ,TO_CHAR(decode(pet.processing_type,''R'',greatest(pab.date_start,PTP.START_DATE),pab.date_start),''DD-Mon-YYYY'')  COL02
            ,TO_CHAR(decode(pet.processing_type,''R'',least(pab.date_end,PTP.END_DATE),pab.date_end),''DD-Mon-YYYY'')           COL03
            ,TO_CHAR(decode(pet.processing_type,''R'',to_number(prrv.result_value),nvl(pab.absence_days,pab.absence_hours))
	            ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40))                                                         COL16
      FROM   pay_assignment_actions           paa
            ,pay_payroll_actions              ppa
            ,pay_run_results                  prr
            ,pay_run_result_values            prrv
            ,per_time_periods                 ptp
            ,pay_element_types_f              pet
            ,pay_input_values_f               piv
            ,pay_element_entries_f            pee
            ,per_absence_attendance_types     pat
            ,per_absence_attendances          pab
      WHERE  paa.assignment_action_id       = ' || p_assignment_action_id || '
      AND    ppa.payroll_action_id          = paa.payroll_action_id
      AND    ppa.action_type               IN (''Q'',''R'')
      AND    ptp.time_period_id             = ppa.time_period_id
      AND    paa.assignment_action_id       = prr.assignment_action_id
      AND    pet.element_type_id            = prr.element_type_id
      AND    pet.element_type_id            = piv.element_type_id
      AND    piv.input_value_id             = pat.input_value_id
      AND    pat.absence_attendance_type_id = pab.absence_attendance_type_id
      AND    pab.absence_attendance_id      = pee.creator_id
      AND    pee.creator_type               = ''A''
      AND    pee.assignment_id              = paa.assignment_id
      AND    pee.element_entry_id           = prr.source_id
      AND    piv.input_value_id             = prrv.input_value_id
      AND    prr.run_result_id              = prrv.run_result_id
      AND    ppa.effective_date       BETWEEN pet.effective_start_date
                                          AND pet.effective_end_date
      AND    ppa.effective_date       BETWEEN pee.effective_start_date
                                          AND pee.effective_end_date
      AND    ppa.effective_date       BETWEEN piv.effective_start_date
                                          AND piv.effective_end_date';


   RETURN g_sql;

END get_leave_taken;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_MESSAGES                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Messages Region          --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_messages(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

CURSOR csr_prepayment
IS
SELECT MAX(locked_action_id)
FROM   pay_action_interlocks
WHERE  locking_action_id = p_assignment_action_id;

l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;

BEGIN


OPEN csr_prepayment;
FETCH csr_prepayment INTO l_assignment_action_id;
CLOSE csr_prepayment;

IF l_assignment_action_id IS NULL THEN
   l_assignment_action_id := p_assignment_action_id;
END IF;

   g_sql := 'SELECT ppa.pay_advice_message COL01
               FROM pay_payroll_actions          ppa
                  , pay_assignment_actions       paa
              WHERE ppa.payroll_action_id      = paa.payroll_action_id
                AND paa.assignment_action_id   = ' || l_assignment_action_id;

   RETURN g_sql;

END get_messages;

END pay_cn_soe;

/
