--------------------------------------------------------
--  DDL for Package Body PAY_IN_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_SOE_PKG" AS
/* $Header: pyinsoer.pkb 120.1.12010000.2 2008/08/06 07:29:09 ubhat ship $ */

   g_package     CONSTANT VARCHAR2(100) := 'pay_in_soe_pkg.';
   g_debug       BOOLEAN;
   g_sql         LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EMPLOYEE                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Personal Information     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_employee(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
  l_reg_legal_name VARCHAR2(150);

  CURSOR csr_reg_legal_name
  IS
  SELECT  hoi2.org_information4
  FROM     per_assignments_f peaf
          ,hr_soft_coding_keyflex hrscf
          ,hr_organization_information hoi
          ,hr_organization_units hou
          ,hr_organization_information hoi2
          , pay_assignment_actions        paa
          , pay_payroll_actions           ppa
  WHERE
      paa.assignment_action_id    = p_assignment_action_id
  AND paa.payroll_action_id       = ppa.payroll_action_id
  AND peaf.assignment_id          = paa.assignment_id
  AND ppa.effective_date    BETWEEN peaf.effective_start_date
                                      AND peaf.effective_end_date
  AND   peaf.soft_coding_keyflex_id=hrscf.soft_coding_keyflex_id
  AND   hoi.organization_id=hrscf.segment1
  AND   hoi.org_information_context='PER_IN_INCOME_TAX_DF'
  AND   hou.organization_id=hoi.org_information4
  AND   hoi2.organization_id=hoi.org_information4
  AND   hoi2.org_information_context='PER_IN_COMPANY_DF';

BEGIN

   l_procedure := g_package || 'get_employee';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

   OPEN  csr_reg_legal_name;
   FETCH csr_reg_legal_name INTO l_reg_legal_name;
   CLOSE csr_reg_legal_name;

   --
g_sql :=
'SELECT org.name COL01
        ,job.name COL02
        ,loc.location_code COL03
        ,grd.name COL04
        ,pay.payroll_name COL05
        ,pos.name COL06
        ,'''||l_reg_legal_name||''' COL07
        ,pg.group_name COL08
        ,peo.national_identifier COL09
        ,employee_number COL10
        ,hl.meaning      COL11
        ,assignment_number COL12
        ,nvl(ppb1.salary,''0'') COL13
  FROM   per_all_people_f             peo
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
  WHERE  asg.assignment_id   = :assignment_id
    AND  :effective_date
  BETWEEN asg.effective_start_date and asg.effective_end_date
    AND  asg.person_id       = peo.person_id
    AND  :effective_date
  BETWEEN peo.effective_start_date and peo.effective_end_date
    AND  asg.position_id     = pos.position_id(+)
    AND  asg.job_id          = job.job_id(+)
    AND  asg.location_id     = loc.location_id(+)
    AND  asg.grade_id        = grd.grade_id(+)
    AND  asg.people_group_id = pg.people_group_id(+)
    AND  asg.payroll_id      = pay.payroll_id(+)
    AND  :effective_date
  BETWEEN pay.effective_start_date(+) and pay.effective_end_date(+)
    AND  asg.organization_id = org.organization_id
    AND  :effective_date
  BETWEEN org.date_from and nvl(org.date_to, :effective_date)
    AND  asg.pay_basis_id    = ppb1.pay_basis_id(+)
    AND  asg.assignment_id   = ppb1.assignment_id(+)
    AND  asg.business_group_id = ppb1.business_group_id(+)
    AND hl.application_id (+) = 800
    AND hl.lookup_type (+) =''NATIONALITY''
    AND hl.lookup_code (+) =peo.nationality';
   --

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

 RETURN g_sql;

END get_employee;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_FUR_PERSON_INFO                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Further Person           --
--                  Information Region                                  --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_fur_person_info(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);

BEGIN

   l_procedure := g_package || 'get_fur_person_info';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

   g_sql :=
   'SELECT   TO_CHAR(paf.date_of_birth,''DD-MON-YYYY'') COL01
            ,TO_CHAR(paf.original_date_of_hire,''DD-MON-YYYY'') COL02
            ,paf.per_information4      COL03
            ,paf.per_information8      COL04
            ,paf.per_information9      COL06
            ,paf.per_information10     COL05
            ,hr_general.decode_lookup(''IN_RESIDENTIAL_STATUS'',paf.per_information7)  COL07
    FROM   per_all_people_f             paf
          ,per_all_assignments_f        asg
    WHERE
         asg.assignment_id = '':assignment_id''
     AND  :effective_date
          BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND asg.person_id     =  paf.person_id
     AND  :effective_date
          BETWEEN paf.effective_start_date AND paf.effective_end_date';

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

 RETURN g_sql;

END get_fur_person_info;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PERIOD                                          --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Payroll Processing       --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_period(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
  l_action_type VARCHAR2(2);

  CURSOR periodDates IS
  SELECT action_type FROM
           pay_payroll_actions pa
          ,per_time_periods tp
          ,pay_assignment_actions aa
  WHERE   pa.payroll_action_id = aa.payroll_action_id
  AND     pa.effective_date = tp.regular_payment_date
  AND     pa.payroll_id = tp.payroll_id
  AND     aa.assignment_action_id = p_assignment_action_id;

BEGIN

   l_procedure := g_package || 'get_period';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

   open periodDates;
   fetch periodDates into l_action_type;
   close periodDates;

   if l_action_type is not null then
      if l_action_type in ( 'P','U' ) then
         g_sql :=
        'select tp1.period_name || decode(tp2.period_name, tp1.period_name, null, '' - '' ||  tp2.period_name) COL01
	 ,fnd_date.date_to_displaydate(tp1.start_date)  COL02
	 ,fnd_date.date_to_displaydate(pa2.effective_date) COL03
         ,fnd_date.date_to_displaydate(tp2.end_date)   COL04
 	 ,fnd_date.date_to_displaydate(aa1.start_date) COL05
 	 ,fnd_date.date_to_displaydate(aa2.end_date)    COL06
         ,tp1.period_type COL07
	 from pay_payroll_actions pa1
            ,pay_payroll_actions pa2
	    ,per_time_periods tp1
            ,per_time_periods tp2
	    ,pay_assignment_actions aa1
            ,pay_assignment_actions aa2
	 where pa1.payroll_action_id = aa1.payroll_action_id
 	 and pa1.effective_date = tp1.regular_payment_date
	 and pa1.payroll_id = tp1.payroll_id
 	 and aa1.assignment_action_id = :PREPAY_MIN_ACTION
         and pa2.payroll_action_id = aa2.payroll_action_id
         and pa2.effective_date = tp2.regular_payment_date
         and pa2.payroll_id = tp2.payroll_id
         and aa2.assignment_action_id = :PREPAY_MAX_ACTION';
      else
         g_sql :=
         'select tp.period_name COL01
         ,fnd_date.date_to_displaydate(tp.end_date)   COL04
         ,fnd_date.date_to_displaydate(pa.effective_date) COL03
         ,fnd_date.date_to_displaydate(aa.start_date) COL05
         ,fnd_date.date_to_displaydate(aa.end_date)    COL06
         ,fnd_date.date_to_displaydate(tp.start_date)  COL02
         ,tp.period_type COL07
         from pay_payroll_actions pa
         ,per_time_periods tp
         ,pay_assignment_actions aa
         where pa.payroll_action_id = aa.payroll_action_id
         and pa.effective_date = tp.regular_payment_date
         and pa.payroll_id = tp.payroll_id
         and aa.assignment_action_id = :assignment_action_id';
      end if;
  else
     g_sql :=
     'select tp.period_name COL01
     ,fnd_date.date_to_displaydate(tp.end_date)   COL04
     ,fnd_date.date_to_displaydate(pa.effective_date) COL03
     ,fnd_date.date_to_displaydate(aa.start_date) COL05
     ,fnd_date.date_to_displaydate(aa.end_date)    COL06
     ,fnd_date.date_to_displaydate(tp.start_date)  COL02
     ,tp.period_type COL07
     from pay_payroll_actions pa
     ,per_time_periods tp
     ,pay_assignment_actions aa
     where pa.payroll_action_id = aa.payroll_action_id
     and pa.time_period_id = tp.time_period_id
     and aa.assignment_action_id = :assignment_action_id';
  end if;
   --

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

 RETURN g_sql;

END get_period;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GETELEMENTS                                         --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to return SQL for some regions in the SOE  --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                  p_classification_name           VARCHAR2            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION getelements(p_assignment_action_id IN NUMBER
                    ,p_classification_name  IN VARCHAR2
                    ) RETURN LONG
IS
  l_procedure VARCHAR2(50);

BEGIN

   l_procedure := g_package || 'getelements';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

   IF (p_classification_name = 'Earnings') THEN
           g_sql:=' SELECT DECODE(classification_name,
                                  ''Earnings'', element_reporting_name,
                                  ''Paid Monetary Perquisite'', SUBSTR(element_reporting_name, 0, LENGTH(element_reporting_name) - 8)) COL02
                         , TO_CHAR( DECODE(foreign_currency_code,NULL,amount,amount/exchange_rate)
                                  , fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
                     FROM pay_in_asg_elements_v
                    WHERE assignment_action_id     = ' || p_assignment_action_id || '
                      AND ( classification_name      = ''' || p_classification_name || '''
                         OR classification_name      = ''Paid Monetary Perquisite'')
                      AND amount <> 0
                      ORDER BY COL02';

   ELSE
           g_sql:='SELECT element_reporting_name COL02
                        , TO_CHAR( DECODE(foreign_currency_code,NULL,amount,amount/exchange_rate)
                                 , fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
                     FROM pay_in_asg_elements_v
                    WHERE assignment_action_id     = ' || p_assignment_action_id || '
                      AND classification_name      = ''' || p_classification_name || '''
                      AND amount <> 0
                      ORDER BY element_reporting_name';
   END IF;
   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);
   RETURN g_sql;
  --
END getelements;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EARNINGS                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Earnings Region          --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_earnings(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);

BEGIN

    l_procedure := g_package || 'get_earnings';
    pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements(p_assignment_action_id => p_assignment_action_id
                      ,p_classification_name  => 'Earnings'
                      );

    pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

END get_earnings;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DEDUCTIONS                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Deductions Region        --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_deductions(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);

BEGIN

    l_procedure := g_package || 'get_deductions';
    pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Deductions'
                      );

    pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

END get_deductions;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ADVANCES                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Advances Region          --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_advances(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := g_package || 'get_advances';
    pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Advances'
                      );

    pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

END get_advances;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_FRINGE_BENEFITS                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Fringe Benefits Region   --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_fringe_benefits(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := g_package || 'get_fringe_benefits';
    pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Fringe Benefits'
                      );

    pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

END get_fringe_benefits;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PERQUISITES                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Perquisites Region       --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_perquisites(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := g_package || 'get_perquisites';
    pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Perquisites'
                      );

    pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

END get_perquisites;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EMPLOYER_CHARGES                                --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Employer Charges         --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_employer_charges(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := g_package || 'get_employer_charges';
    pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Employer Charges'
                      );

     pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

END get_employer_charges;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TERM_PAYMENTS                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Termination Payments     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_term_payments(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
  l_procedure VARCHAR2(50);
BEGIN

    l_procedure := g_package || 'get_term_payments';
    pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

    RETURN getElements( p_assignment_action_id => p_assignment_action_id
                      , p_classification_name  => 'Termination Payments'
                      );

     pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

END get_term_payments;

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

CURSOR csr_get_tax_till_date
IS
SELECT SUM(pay_balance_pkg.get_value( pdb.defined_balance_id, p_assignment_action_id)) COL16
             FROM pay_balance_types              pbt
                , pay_balance_dimensions         pbd
                , pay_defined_balances           pdb
            WHERE pbt.balance_name          IN ( 'F16 Income Tax till Date'
                                               , 'F16 Surcharge till Date'
                                               , 'F16 Education Cess till Date'
					       , 'F16 Sec and HE Cess till Date')
              AND pbd.dimension_name           = '_ASG_PTD'
              AND pbt.legislation_code         = 'IN'
              AND pbd.legislation_code         = 'IN'
              AND pbd.balance_dimension_id     = pdb.balance_dimension_id
              AND pbt.balance_type_id          = pdb.balance_type_id;

   l_procedure VARCHAR2(50);
   l_tax_till_date NUMBER;

BEGIN

   l_procedure := g_package || 'get_balances';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

   OPEN  csr_get_tax_till_date;
   FETCH csr_get_tax_till_date INTO l_tax_till_date;
   CLOSE csr_get_tax_till_date;

   g_sql := 'SELECT DECODE(pbt.balance_name,''F16 Salary Under Section 17'',''Salary (Section 17(1))'',
                                            ''F16 Value of Perquisites'',''Value of Perquisites (Section 17(2))'',
                                            ''F16 Profit in lieu of Salary'',''Profit in lieu of salary (Section 17(3))'',
                                            ''F16 Allowances Exempt'',''Allowances under Sec 10''
                                           ,SUBSTR(pbt.balance_name,5)) COL04
                  , DECODE(pbt.balance_name,''F16 Income Tax till Date'',
                           TO_CHAR('||l_tax_till_date||'
                             ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)),
                           TO_CHAR(pay_balance_pkg.get_value( pdb.defined_balance_id,'|| p_assignment_action_id ||')
                             ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40))) COL16
             FROM pay_balance_types              pbt
                , pay_balance_dimensions         pbd
                , pay_defined_balances           pdb
            WHERE pbt.balance_name          IN ( ''F16 Salary Under Section 17''
                                               , ''F16 Value of Perquisites''
                                               , ''F16 Profit in lieu of Salary''
                                               , ''F16 Gross Salary''
                                               , ''F16 Allowances Exempt''
                                               , ''F16 Deductions under Sec 16''
                                               , ''F16 Total Chapter VI A Deductions''
                                               , ''F16 Total Income''
                                               , ''F16 Tax on Total Income''
                                               , ''F16 Total Tax payable''
                                               , ''F16 Income Tax till Date''
                                               , ''F16 Balance Tax'')
              AND pbd.dimension_name           = ''_ASG_PTD''
              AND pbt.legislation_code         = ''IN''
              AND pbd.legislation_code         = ''IN''
              AND pbd.balance_dimension_id     = pdb.balance_dimension_id
              AND pbt.balance_type_id          = pdb.balance_type_id
              ORDER BY (DECODE (pbt.balance_name,''F16 Salary Under Section 17'',1
                                               , ''F16 Value of Perquisites'',2
                                               , ''F16 Profit in lieu of Salary'',3
                                               , ''F16 Gross Salary'',4
                                               , ''F16 Allowances Exempt'',5
                                               , ''F16 Deductions under Sec 16'',6
                                               , ''F16 Total Chapter VI A Deductions'',7
                                               , ''F16 Total Income'',8
                                               , ''F16 Tax on Total Income'',9
                                               , ''F16 Total Tax payable'',10
                                               , ''F16 Income Tax till Date'',11
                                               , ''F16 Balance Tax'',12,999))';

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

   RETURN g_sql;

END get_balances;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PAYMENT_DETAILS                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Payment Details Region   --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_payment_details(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

l_procedure VARCHAR2(50);

BEGIN

   l_procedure := g_package || 'get_payment_details';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

   g_sql := 'SELECT org_payment_method_name                              COL01
                 , pay_soe_util.getBankDetails('':legislation_code''
                                              ,NVL(ppm.external_account_id,opm.external_account_id)
                                              ,''BANK_NAME''
                                              ,NULL) || '','' ||
                   pay_soe_util.getBankDetails('':legislation_code''
                                              ,NVL(ppm.external_account_id,opm.external_account_id)
                                               ,''BANK_BRANCH''
                                              ,NULL)                     COL02
                 , pay_soe_util.getBankDetails('':legislation_code''
                                              ,NVL(ppm.external_account_id,opm.external_account_id)
                                              ,''BANK_ACCOUNT_NUMBER''
                                              ,NULL)                     COL03
                 , TO_CHAR(:G_CURRENCY_CODE)                             COL04
                 , pay_soe_util.getBankDetails('':legislation_code''
                                              ,NVL(ppm.external_account_id,opm.external_account_id)
                                              ,''BANK_BRANCH''
                                              ,NULL)                     COL05
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
   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

   RETURN g_sql;

END get_payment_details;

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

   l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_procedure VARCHAR2(100);

   CURSOR csr_prepayment
   IS
   SELECT MAX(locked_action_id)
   FROM   pay_action_interlocks
   WHERE  locking_action_id = p_assignment_action_id;

   CURSOR csr_get_bg_id
   IS
   SELECT ppa.business_group_id
   FROM pay_payroll_actions    ppa
       ,pay_assignment_actions paa
   WHERE ppa.payroll_action_id    = paa.payroll_action_id
   AND paa.assignment_action_id   = p_assignment_action_id;


BEGIN

   l_procedure := g_package || 'get_other_element_information';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

   OPEN csr_prepayment;
   FETCH csr_prepayment INTO l_assignment_action_id;
   CLOSE csr_prepayment;

   IF l_assignment_action_id IS NOT NULL THEN
        p_assignment_action_id := l_assignment_action_id;
   END IF;

   OPEN  csr_get_bg_id;
   FETCH csr_get_bg_id INTO l_business_group_id;
   CLOSE csr_get_bg_id;

   g_sql :=
    'SELECT org.org_information7 COL02
          , prv.result_value COL16
       FROM pay_run_result_values  prv,
            pay_run_results        prr,
            hr_organization_information_v org
      WHERE prr.status IN (''P'',''PA'')
        AND org.organization_id = ' || l_business_group_id || '
        AND org.org_information_context = ''Business Group:SOE Detail''
        AND org.org_information1       = ''ELEMENT''
        AND prv.run_result_id          = prr.run_result_id
        AND prr.assignment_action_id   = ' || p_assignment_action_id || '
        AND prr.element_type_id        = org.org_information2
        AND prv.input_value_id         = org.org_information3
        AND prv.result_value IS NOT NULL
       ORDER BY org.org_information7';

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

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
   l_procedure VARCHAR2(100);

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

   l_procedure := g_package || 'get_other_balance_information';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

   OPEN  csr_get_date_earned;
   FETCH csr_get_date_earned INTO l_date_earned, l_business_group_id;
   CLOSE csr_get_date_earned;

   OPEN  csr_get_tax_unit_id;
   FETCH csr_get_tax_unit_id INTO l_tax_unit_id;
   CLOSE csr_get_tax_unit_id;

   g_sql := 'SELECT org.org_information7 COL02
                  , TO_CHAR(pay_balance_pkg.get_value( pdb.defined_balance_id
                                                      , ' || p_assignment_action_id || ')
                           ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
              FROM pay_defined_balances           pdb
                  , hr_organization_information_v  org
              WHERE org.organization_id = ' || l_business_group_id || '
                AND org.org_information_context = ''Business Group:SOE Detail''
                AND org.org_information1        = ''BALANCE''
                AND pdb.balance_type_id         = org.org_information4
                AND pdb.balance_dimension_id    = org.org_information5';

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

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

   l_procedure := g_package || 'get_annual_leave_information';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

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

  /* Bug 6914353 - Added check to call accrual calculations function
                   only if Accrual Plan ID is available */
   IF csr_get_annual_leave_details%FOUND
   THEN

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

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);
   ELSE
        CLOSE csr_get_annual_leave_details;
   END IF;

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
   l_procedure VARCHAR2(50);

BEGIN

   l_procedure := g_package || 'get_leave_taken';
   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

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

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

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
   l_procedure VARCHAR2(50);

BEGIN

   l_procedure := g_package || 'get_messages';

   pay_in_utils.set_location (g_debug,'Entering ' || l_procedure,10);

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

   pay_in_utils.set_location (g_debug,'Leaving ' || l_procedure,20);

   RETURN g_sql;

END get_messages;

END pay_in_soe_pkg;

/
