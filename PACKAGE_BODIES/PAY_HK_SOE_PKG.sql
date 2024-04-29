--------------------------------------------------------
--  DDL for Package Body PAY_HK_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_SOE_PKG" as
/* $Header: pyhksoe.pkb 120.9.12010000.2 2008/08/06 07:22:54 ubhat ship $ */

  g_debug             boolean;
  g_package           constant varchar2(100) := 'pay_hk_soe_pkg.';
  g_sql               long;

  ------------------------------------------------------------------------
  -- Define global variable to store defined_balance_id's and the
  -- corresponding balance values for BBR.
  ------------------------------------------------------------------------
  p_balance_value_tab_payment pay_balance_pkg.t_balance_value_tab;
  p_balance_value_tab_ytd     pay_balance_pkg.t_balance_value_tab;
  p_context_table             pay_balance_pkg.t_context_tab;
  p_result_table              pay_balance_pkg.t_detailed_bal_out_tab;

  ------------------------------------------------------------------------
  -- Returns the Currency Code for the Business Group.
  ------------------------------------------------------------------------
  function business_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type is

  v_currency_code  fnd_currencies.currency_code%type;

  cursor currency_code
      (c_business_group_id  hr_organization_units.business_group_id%type) is
    select fcu.currency_code
    from   hr_organization_information hoi,
           hr_organization_units hou,
           fnd_currencies fcu
    where  hou.business_group_id       = c_business_group_id
    and    hou.organization_id         = hoi.organization_id
    and    hoi.org_information_context = 'Business Group Information'
    and    fcu.issuing_territory_code  = hoi.org_information9;

begin
  open currency_code (p_business_group_id);
  fetch currency_code into v_currency_code;
  close currency_code;

  return v_currency_code;

end business_currency_code;

  ------------------------------------------------------------------------
  -- Sums the Balances for This Pay and YTD, according to the parameters.
  ------------------------------------------------------------------------
  function get_balance_id
     (p_balance_name      in pay_balance_types.balance_name%type,
      p_dimension_name    in pay_balance_dimensions.dimension_name%type)
      return pay_defined_balances.defined_balance_id%type
  is

  p_defined_balance_id pay_defined_balances.defined_balance_id%type;

  cursor balance_id
     (c_balance_name      pay_balance_types.balance_name%type,
      c_dimension_name    pay_balance_dimensions.dimension_name%type) is
    select
      pdb.defined_balance_id
      from pay_balance_types  pbt,
	   pay_defined_balances pdb,
	   pay_balance_dimensions pbd
      where pbt.balance_type_id = pdb.balance_type_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id
      and pbd.dimension_name = c_dimension_name
      and pbt.balance_name = c_balance_name
      and pbt.legislation_code = 'HK' ;

  begin

    open balance_id (p_balance_name,
                     p_dimension_name);

    fetch balance_id into p_defined_balance_id;

    close balance_id;

    return p_defined_balance_id;

  end get_balance_id;

  ------------------------------------------------------------------------
  -- Procedure to merely pass all the balance results back in one hit,
  -- rather than separate calls for each balance.
  ------------------------------------------------------------------------
  procedure balance_totals
    (p_assignment_action_id             in pay_assignment_actions.assignment_action_id%type,
     p_tax_unit_id                      in pay_assignment_actions.tax_unit_id%type,
     p_total_earnings_this_pay         out nocopy number,
     p_total_earnings_ytd              out nocopy number,
     p_total_deductions_this_pay       out nocopy number,
     p_total_deductions_ytd            out nocopy number,
     p_net_pay_this_pay                out nocopy number,
     p_net_pay_ytd                     out nocopy number,
     p_direct_payments_this_pay        out nocopy number,
     p_direct_payments_ytd             out nocopy number,
     p_total_payment_this_pay          out nocopy number,
     p_total_payment_ytd               out nocopy number)
  is

  ------------------------------------------------------------------------
  -- cursor to get the defined balance ids for the various balances --3609072
  ------------------------------------------------------------------------
  CURSOR   c_get_defined_balance_id
  (c_dimension_name        pay_balance_dimensions.dimension_name%type)
  IS
  SELECT   decode(pbt.balance_name, 'GROSS_PAY',1
                                  , 'MANDATORY_DEDUCTIONS',2
                                  , 'INVOLUNTARY_DEDUCTIONS',3
                                  , 'VOLUNTARY_DEDUCTIONS',4
                                  , 'NET',5
                                  , 'DIRECT_PAYMENTS',6
                                  , 'TOTAL_PAYMENTS',7) sort_index,
           pdb.defined_balance_id defined_balance_id
    FROM   pay_balance_types pbt,
           pay_balance_dimensions pbd,
           pay_defined_balances pdb
   WHERE   pbt.balance_name  IN   ('GROSS_PAY'
                                  , 'MANDATORY_DEDUCTIONS'
                                  , 'INVOLUNTARY_DEDUCTIONS'
                                  , 'VOLUNTARY_DEDUCTIONS'
                                  , 'NET'
                                  , 'DIRECT_PAYMENTS'
                                  , 'TOTAL_PAYMENTS')
     AND   pbd.dimension_name = c_dimension_name
     AND   pbt.balance_type_id      = pdb.balance_type_id
     AND   pbd.balance_dimension_id = pdb.balance_dimension_id
     AND   pbt.legislation_code     = 'HK'
   ORDER BY sort_index;

    v_defined_balance_id          number;
    v_gross_pay_this_run          number;
    v_gross_pay_ytd               number;
    v_mandatory_ded_this_run      number;
    v_mandatory_ded_ytd           number;
    v_involuntary_ded_this_run    number;
    v_involuntary_ded_ytd         number;
    v_voluntary_ded_this_run      number;
    v_voluntary_ded_ytd           number;
    v_net_pay_this_run            number;
    v_net_pay_ytd                 number;
    v_direct_pay_this_run         number;
    v_direct_pay_ytd              number;
    v_total_pay_this_run          number;
    v_total_pay_ytd               number;

  begin

   IF g_debug THEN
      hr_utility.trace('Entering:' || 'pay_hk_soe.total_balances');
   END IF;


   /*------------- for payment values -----------------*/

   /* populate a table for defined balance ids of PAYMENT balances.Bug 3609072*/

   if not g_def_bal_id_populated_payment then /*Bug 4210525 */

     FOR csr_rec IN c_get_defined_balance_id('_PAYMENTS')
      LOOP
         p_balance_value_tab_payment(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;

      END LOOP;
      g_def_bal_id_populated_payment := TRUE; /*Bug 4210525 */


   end if;
    -- Set the TAX_UNIT_ID context. Needed for LE_YTD balances.

    p_context_table(1).tax_unit_id := p_tax_unit_id;

   /* get the balances using BBR. Bug 3609072 */

    pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id
                             ,p_defined_balance_lst=>p_balance_value_tab_payment
                             ,p_context_lst => p_context_table
                             ,p_output_table=> p_result_table);

    v_gross_pay_this_run       := p_result_table(1).balance_value;
    v_mandatory_ded_this_run   := p_result_table(2).balance_value;
    v_involuntary_ded_this_run := p_result_table(3).balance_value;
    v_voluntary_ded_this_run   := p_result_table(4).balance_value;
    v_net_pay_this_run         := p_result_table(5).balance_value;
    v_direct_pay_this_run      := p_result_table(6).balance_value;
    v_total_pay_this_run       := p_result_table(7).balance_value;

    if g_debug THEN
      hr_utility.trace('_PAYMENTS balances');
      hr_utility.trace('GROSS_PAY-->' || p_result_table(1).balance_value);
      hr_utility.trace('MANDATORY_DEDUCTIONS-->' || p_result_table(2).balance_value);
      hr_utility.trace('INVOLUNTARY_DEDUCTIONS-->' || p_result_table(3).balance_value);
      hr_utility.trace('VOLUNTARY_DEDUCTIONS-->' || p_result_table(4).balance_value);
      hr_utility.trace('NET-->' || p_result_table(5).balance_value);

      hr_utility.trace('DIRECT_PAYMENTS-->' || p_result_table(6).balance_value);
      hr_utility.trace('TOTAL_PAYMENTS-->' || p_result_table(7).balance_value);
    end if;


   /*----------------------------------- for YTD values --------------------*/

   /* populate a table for defined balance ids of  ytd balances  */

   if not g_def_bal_id_populated_ytd then /* Bug 4210525 */
     FOR csr_rec IN c_get_defined_balance_id('_ASG_LE_YTD')
      LOOP
         p_balance_value_tab_ytd(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;

     END LOOP;
     g_def_bal_id_populated_ytd := TRUE; /* Bug 4210525 */

   end if;

   /* get the balances using BBR. Bug 3609072 */

   pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                               p_defined_balance_lst=>p_balance_value_tab_ytd,
                               p_context_lst =>p_context_table,
                               p_output_table=>p_result_table);

    v_gross_pay_ytd       := p_result_table(1).balance_value;
    v_mandatory_ded_ytd   := p_result_table(2).balance_value;
    v_involuntary_ded_ytd := p_result_table(3).balance_value;
    v_voluntary_ded_ytd   := p_result_table(4).balance_value;
    v_net_pay_ytd         := p_result_table(5).balance_value;
    v_direct_pay_ytd      := p_result_table(6).balance_value;
    v_total_pay_ytd       := p_result_table(7).balance_value;

    if g_debug THEN
      hr_utility.trace('_ASG_LE_YTD balances');
      hr_utility.trace('GROSS_PAY-->' || p_result_table(1).balance_value);
      hr_utility.trace('MANDATORY_DEDUCTIONS-->' || p_result_table(2).balance_value);
      hr_utility.trace('INVOLUNTARY_DEDUCTIONS-->' || p_result_table(3).balance_value);
      hr_utility.trace('VOLUNTARY_DEDUCTIONS-->' || p_result_table(4).balance_value);
      hr_utility.trace('NET-->' || p_result_table(5).balance_value);
      hr_utility.trace('DIRECT_PAYMENTS-->' || p_result_table(6).balance_value);
      hr_utility.trace('TOTAL_PAYMENTS-->' || p_result_table(7).balance_value);
    end if;


-- Set the output balance amounts.

  p_total_earnings_this_pay      := v_gross_pay_this_run;
  p_total_deductions_this_pay    := v_mandatory_ded_this_run +
                                    v_involuntary_ded_this_run +
                                    v_voluntary_ded_this_run;
  p_net_pay_this_pay             := v_net_pay_this_run;
  p_direct_payments_this_pay     := v_direct_pay_this_run;
  p_total_payment_this_pay       := v_total_pay_this_run;

  p_total_earnings_ytd           := v_gross_pay_ytd;
  p_total_deductions_ytd         := v_mandatory_ded_ytd +
                                    v_involuntary_ded_ytd +
                                    v_voluntary_ded_ytd;
  p_net_pay_ytd                  := v_net_pay_ytd;
  p_direct_payments_ytd          := v_direct_pay_ytd;
  p_total_payment_ytd            := v_total_pay_ytd;


  if g_debug then
       hr_utility.trace('Leaving:' || 'pay_hk_soe.total_balances');
  end if;

end balance_totals;

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
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION getelements(p_assignment_action_id IN NUMBER
                    ,p_classification_name  IN VARCHAR2
                    ) RETURN LONG
IS
  l_assignment_action_id pay_assignment_actions.assignment_action_id%type;

  CURSOR csr_locked_action_id
  IS
    SELECT max(locked_action_id)
      FROM pay_action_interlocks
     WHERE locking_action_id = p_assignment_action_id;

BEGIN

   hr_utility.trace('Entering: ' || 'pay_hk_soe.getelements');

   OPEN  csr_locked_action_id;
   FETCH csr_locked_action_id INTO l_assignment_action_id;
   CLOSE csr_locked_action_id;

   IF l_assignment_action_id IS NULL THEN

        g_sql:=' SELECT element_reporting_name COL02
                 , TO_CHAR(amount,  fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
              FROM pay_hk_asg_elements_v
             WHERE assignment_action_id = ' || p_assignment_action_id || '
               AND (classification_name  like  ''%''||''' || p_classification_name || ''' ||''%'')
          ORDER BY element_reporting_name';

   ELSE

        g_sql:=' SELECT phaev.element_reporting_name COL02
                 , TO_CHAR(phaev.amount,  fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
              FROM pay_hk_asg_elements_v phaev,
                   pay_action_interlocks pai
             WHERE pai.locked_action_id = phaev.assignment_action_id
               AND  pai.locking_action_id = ' || p_assignment_action_id || '
               AND (phaev.classification_name  like  ''%''||''' || p_classification_name || ''' ||''%'')
          ORDER BY phaev.element_reporting_name';

   END IF;

   hr_utility.trace ('Leaving: ' || 'pay_hk_soe.getelements');
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
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_earnings(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

BEGIN

    hr_utility.trace ('Entering: ' || 'pay_hk_soe.get_earnings');
    RETURN getElements(p_assignment_action_id => p_assignment_action_id
                      ,p_classification_name  => 'Earnings'
                      );

END get_earnings;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DEDUCTIONS                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Earnings Region          --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_deductions(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

BEGIN

    hr_utility.trace ('Entering: ' || 'pay_hk_soe.get_deductions');
    RETURN getElements(p_assignment_action_id => p_assignment_action_id
                      ,p_classification_name  => 'Deductions'
                      );

END get_deductions;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EMPLOYER_LIABILITIES                            --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Employer Liabilities     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_employer_liabilities(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

BEGIN

    hr_utility.trace ('Entering: ' || 'pay_hk_soe.get_employer_liabilities');
    RETURN getElements(p_assignment_action_id => p_assignment_action_id
                      ,p_classification_name  => 'Employer Liabilities'
                      );

END get_employer_liabilities;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCES                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Balances Region          --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_balances( p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

   l_date_earned DATE;
   l_tax_unit_id NUMBER;
   l_assignment_action_id     pay_assignment_actions.assignment_action_id%type;
   l_dimension                pay_balance_dimensions.dimension_name%type;

   CURSOR csr_locked_action_id
   IS
     SELECT max(locked_action_id)
       FROM pay_action_interlocks
      WHERE locking_action_id = p_assignment_action_id;

   CURSOR csr_get_date_earned
   IS
     SELECT ppa.date_earned, paa.tax_unit_id
       FROM pay_payroll_actions    ppa
          , pay_assignment_actions paa
      WHERE ppa.payroll_action_id    = paa.payroll_action_id
        AND paa.assignment_action_id = p_assignment_action_id;

BEGIN

   hr_utility.trace('Entering: '|| 'pay_hk_soe_pkg.get_balances');

   OPEN  csr_locked_action_id;
   FETCH csr_locked_action_id INTO l_assignment_action_id;
   CLOSE csr_locked_action_id;

   IF l_assignment_action_id IS NULL THEN
     l_dimension := '_ASG_LE_RUN';
     l_assignment_action_id := p_assignment_action_id;
   ELSE
     l_dimension := '_ASG_LE_PTD';
   END IF;

   OPEN  csr_get_date_earned;
   FETCH csr_get_date_earned INTO l_date_earned, l_tax_unit_id;
   CLOSE csr_get_date_earned;

   g_sql := 'SELECT /*+ USE_NL(pbt) */ NVL(pbt.reporting_name, pbt.balance_name) COL04
                  , TO_CHAR(pay_balance_pkg.get_value( pdb_ptd.defined_balance_id
                               , ' || l_assignment_action_id || '
                               , ' || l_tax_unit_id || '
                               , NULL
                               , NULL
                               , NULL
                               , NULL
                               , fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(l_date_earned) || ''')
                               , NULL
                               , NULL)
                        , fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
                  , TO_CHAR(pay_balance_pkg.get_value( pdb_ytd.defined_balance_id
                               , ' || l_assignment_action_id || '
                               , ' || l_tax_unit_id || '
                               , NULL
                               , NULL
                               , NULL
                               , NULL
                        , fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(l_date_earned) || ''')
                               , NULL
                               , NULL)
                        , fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL18
             FROM pay_balance_types              pbt
                , pay_balance_dimensions         pbd_ptd
                , pay_balance_dimensions         pbd_ytd
                , pay_defined_balances           pdb_ptd
                , pay_defined_balances           pdb_ytd
            WHERE   pbt.balance_name  IN   (''GROSS_PAY''
                                          , ''MANDATORY_DEDUCTIONS''
                                          , ''INVOLUNTARY_DEDUCTIONS''
                                          , ''VOLUNTARY_DEDUCTIONS''
                                          , ''NET''
                                          , ''DIRECT_PAYMENTS''
                                          , ''TOTAL_PAYMENTS'')
              AND pbd_ptd.dimension_name       = '''|| l_dimension ||'''
              AND pbd_ytd.dimension_name       = ''_ASG_LE_YTD''
              AND pbt.legislation_code         = ''HK''
              AND pbd_ptd.legislation_code     = ''HK''
              AND pbd_ytd.legislation_code     = ''HK''
              AND pbd_ptd.balance_dimension_id = pdb_ptd.balance_dimension_id
              AND pbt.balance_type_id          = pdb_ptd.balance_type_id
              AND pbd_ytd.balance_dimension_id = pdb_ytd.balance_dimension_id
              AND pbt.balance_type_id          = pdb_ytd.balance_type_id
              ORDER BY decode(pbt.balance_name, ''GROSS_PAY'',1
                                  , ''MANDATORY_DEDUCTIONS'',2
                                  , ''INVOLUNTARY_DEDUCTIONS'',3
                                  , ''VOLUNTARY_DEDUCTIONS'',4
                                  , ''NET'',5
                                  , ''DIRECT_PAYMENTS'',6
                                  , ''TOTAL_PAYMENTS'',7)';

   hr_utility.trace('Leaving: ' || 'pay_hk_soe_pkg.get_balances');

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
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_payment_methods(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS
BEGIN

   hr_utility.trace('Entering: '|| 'pay_hk_soe_pkg.get_payment_methods');

  g_sql := 'SELECT /*+
INDEX(opm PAY_ORG_PAYMENT_METHODS_F_PK) */
                org_payment_method_name                               COL01
                 , pay_soe_util.getBankDetails('':legislation_code''
                                              ,ppm.external_account_id
                                              ,''BANK_NAME''
                                              ,NULL)                     COL02
                 , pay_soe_util.getBankDetails('':legislation_code''
                                              ,ppm.external_account_id
                                              ,''BANK_ACCOUNT_NUMBER''
                                              ,NULL)                     COL03
                 , TO_CHAR(:G_CURRENCY_CODE)                             COL04
                 , to_char(pp.value
                    ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40))  COL16
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

   hr_utility.trace('Leaving: ' || 'pay_hk_soe_pkg.get_payment_methods');

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
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_other_element_information(p_assignment_action_id IN OUT NOCOPY pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

   l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_effective_date pay_payroll_actions.effective_date%TYPE;

   CURSOR csr_prepayment
   IS
   SELECT MAX(locked_action_id)
   FROM   pay_action_interlocks
   WHERE  locking_action_id = p_assignment_action_id;

   CURSOR csr_get_bg_id
   IS
   SELECT ppa.business_group_id,ppa.effective_date
   FROM pay_payroll_actions    ppa
       ,pay_assignment_actions paa
   WHERE ppa.payroll_action_id    = paa.payroll_action_id
   AND paa.assignment_action_id   = p_assignment_action_id;

BEGIN

   hr_utility.trace('Entering: ' || 'pay_hk_soe_pkg.get_other_element_information');

   OPEN csr_prepayment;
   FETCH csr_prepayment INTO l_assignment_action_id;
   CLOSE csr_prepayment;

   IF l_assignment_action_id IS NOT NULL THEN
        p_assignment_action_id := l_assignment_action_id;
   END IF;

   OPEN  csr_get_bg_id;
   FETCH csr_get_bg_id INTO l_business_group_id,l_effective_date;
   CLOSE csr_get_bg_id;

   g_sql :=
    'SELECT org.org_information7 COL02
          , to_char(sum(prv.result_value)) COL16 /* BUG 5972299 */
       FROM pay_run_result_values  prv,
            pay_run_results        prr,
            hr_organization_information_v org,
	    pay_input_values_f pivf
      WHERE prr.status IN (''P'',''PA'')
        AND org.organization_id = ' || l_business_group_id || '
        AND org.org_information_context = ''Business Group:SOE Detail''
        AND org.org_information1       = ''ELEMENT''
        AND prv.run_result_id          = prr.run_result_id
	AND pivf.input_value_id        = prv.input_value_id
	AND ''' || l_effective_date || ''' between pivf.effective_start_date and pivf.effective_end_date
	AND substr(pivf.uom,1,1) IN (''M'',''I'',''H'')
        AND prr.assignment_action_id   = ' || p_assignment_action_id || '
        AND prr.element_type_id        = org.org_information2
        AND prv.input_value_id         = org.org_information3
        AND prv.result_value IS NOT NULL
	group by prr.element_type_id,
	         org.org_information7
        union all
        SELECT org.org_information7 COL02
          , to_char(prv.result_value) COL16
       FROM pay_run_result_values  prv,
            pay_run_results        prr,
            hr_organization_information_v org,
	    pay_input_values_f pivf
      WHERE prr.status IN (''P'',''PA'')
        AND org.organization_id = ' || l_business_group_id || '
        AND org.org_information_context = ''Business Group:SOE Detail''
        AND org.org_information1       = ''ELEMENT''
        AND prv.run_result_id          = prr.run_result_id
	AND pivf.input_value_id        = prv.input_value_id
	AND ''' || l_effective_date || ''' between pivf.effective_start_date and pivf.effective_end_date
	AND substr(pivf.uom,1,1) NOT IN (''M'',''I'',''H'')
        AND prr.assignment_action_id   = ' || p_assignment_action_id || '
        AND prr.element_type_id        = org.org_information2
        AND prv.input_value_id         = org.org_information3
        AND prv.result_value IS NOT NULL';

   hr_utility.trace('Leaving: ' || 'pay_hk_soe_pkg.get_other_element_information');

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
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_other_balance_information(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG
IS

   l_date_earned DATE;
   l_tax_unit_id NUMBER;
   l_business_group_id per_business_groups.business_group_id%TYPE;
   l_assignment_action_id     pay_assignment_actions.assignment_action_id%type;

   CURSOR csr_locked_action_id
   IS
     SELECT max(locked_action_id)
       FROM pay_action_interlocks
      WHERE locking_action_id = p_assignment_action_id;

   CURSOR csr_get_date_earned
   IS
     SELECT ppa.date_earned, ppa.business_group_id, paa.tax_unit_id
       FROM pay_payroll_actions    ppa
          , pay_assignment_actions paa
      WHERE ppa.payroll_action_id    = paa.payroll_action_id
        AND paa.assignment_action_id = p_assignment_action_id;

BEGIN


   hr_utility.trace('Entering: ' || 'pay_hk_soe_pkg.get_other_balance_information');

   OPEN  csr_locked_action_id;
   FETCH csr_locked_action_id INTO l_assignment_action_id;
   CLOSE csr_locked_action_id;

   IF l_assignment_action_id IS NULL THEN
     l_assignment_action_id := p_assignment_action_id;
   END IF;

   OPEN  csr_get_date_earned;
   FETCH csr_get_date_earned INTO l_date_earned, l_business_group_id, l_tax_unit_id;
   CLOSE csr_get_date_earned;

   g_sql := 'SELECT org.org_information7 COL02
                  , TO_CHAR(pay_balance_pkg.get_value( pdb.defined_balance_id
                               , ' || l_assignment_action_id || '
                               , ' || l_tax_unit_id || '
                               , NULL
                               , NULL
                               , NULL
                               , NULL
                               , fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(l_date_earned) || ''')
                               , NULL
                               , NULL)
                           ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
              FROM pay_defined_balances           pdb
                  , hr_organization_information_v  org
              WHERE org.organization_id = ' || l_business_group_id || '
                AND org.org_information_context = ''Business Group:SOE Detail''
                AND org.org_information1        = ''BALANCE''
                AND pdb.balance_type_id         = org.org_information4
                AND pdb.balance_dimension_id    = org.org_information5
                AND pay_balance_pkg.get_value( pdb.defined_balance_id
                               , ' || l_assignment_action_id || '
                               , ' || l_tax_unit_id || '
                               , NULL
                               , NULL
                               , NULL
                               , NULL
                               , fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(l_date_earned) || ''')
                               , NULL
                               , NULL) <> 0';

   hr_utility.trace('Leaving: ' || 'pay_hk_soe_pkg.get_other_balance_information');

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
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_annual_leave_info(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
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
      AND     pap.accrual_category        = 'HKAL'
      AND     ppa.action_type            IN ('R','Q')
      AND     ppa.action_status           = 'C'
      AND     ppa.date_earned       BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
      AND     ppa.date_earned       BETWEEN pel.effective_start_date
                                    AND     pel.effective_end_date
      AND     ppa.date_earned       BETWEEN pee.effective_start_date
                                    AND     pee.effective_end_date
      AND     paa.assignment_action_id    = p_payroll_assignment_action_id;

/*Bug 6074090 Added parameter c_assignment_action_id as date earned is not populated for pre payment action id,
  Date earned of Payroll needs to be fetched */

   CURSOR csr_get_date_earned(c_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE)
   IS
     SELECT ppa.date_earned
       FROM pay_payroll_actions    ppa
          , pay_assignment_actions paa
      WHERE ppa.payroll_action_id    = paa.payroll_action_id
        AND paa.assignment_action_id = c_assignment_action_id;

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

BEGIN


   hr_utility.trace('Entering: ' || 'pay_hk_soe_pkg.get_annual_leave_information');

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

    /* Bug 6928705 - Added check to call accrual calculations function
    only if Accrual Plan ID is available */
   IF csr_get_annual_leave_details%FOUND
   THEN

   CLOSE csr_get_annual_leave_details;

   OPEN  csr_get_date_earned(l_assignment_action_id); /*Bug 6074090 */
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
                  , TO_CHAR(' || l_annual_leave_balance|| ',fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
                  , ''' || l_uom                  || ''' COL03
             FROM DUAL';

   hr_utility.trace('Leaving: ' || 'pay_hk_soe_pkg.get_annual_leave_information');

   ELSE
        CLOSE csr_get_annual_leave_details;
   END IF;

   RETURN g_sql;



END get_annual_leave_info;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LEAVE_TAKEN                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Leave Taken Region       --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
-- Bug 5396046                                                          --
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


   hr_utility.trace('Entering: ' || 'pay_hk_soe_pkg.get_leave_taken');

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
            ,hr_general.decode_lookup(''HOURS_OR_DAYS'',pat.HOURS_OR_DAYS) COL04
            ,TO_CHAR(decode(pet.processing_type,''R'',to_number(prrv.result_value),nvl(pab.absence_days,pab.absence_hours))) COL16
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


   hr_utility.trace('Leaving: ' || 'pay_hk_soe_pkg.get_leave_taken');

   RETURN g_sql;

END get_leave_taken;

begin
   g_def_bal_id_populated_payment := FALSE; /* Bug 4210525 */
   g_def_bal_id_populated_ytd     := FALSE; /* Bug 4210525 */
   g_debug := hr_utility.debug_enabled;

end pay_hk_soe_pkg;

/
