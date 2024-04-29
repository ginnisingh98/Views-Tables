--------------------------------------------------------
--  DDL for Package Body PAY_IN_PAYSLIP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_PAYSLIP_UTILS" AS
/* $Header: pyinpslp.pkb 120.2 2006/05/27 18:40:33 statkar noship $ */

  --
  g_package          VARCHAR2(100);
  g_debug            BOOLEAN ;
  --
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : YTD_BALANCE                                         --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to YTD values of a balance                --
  --                  for a given assignment_action_id                    --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id NUMBER                       --
  --                  p_balance_name         VARCHAR2                     --
  --            OUT : p_ytd_balance          NUMBER                       --
  --                                                                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE ytd_balance
    (
      p_assignment_action_id  IN  NUMBER
     ,p_balance_name          IN  VARCHAR2
     ,p_ytd_balance           OUT NOCOPY NUMBER
    )
  IS
  --
    l_ytd_balance       NUMBER;
    l_procedure         VARCHAR2(100);
    l_message                       VARCHAR2(250);
    --
    CURSOR c_balance_value
      (
        p_dimension_name        VARCHAR2
      )
    IS
      SELECT nvl(pay_balance_pkg.get_value(pdb.defined_balance_id,p_assignment_action_id),0)
      FROM   pay_balance_dimensions pbd
            ,pay_defined_balances pdb
            ,pay_balance_types pbt
      WHERE  pbt.balance_name         = p_balance_name
      AND    pbd.dimension_name       = p_dimension_name
      AND    pbt.balance_type_id      = pdb.balance_type_id
      AND    pbd.balance_dimension_id = pdb.balance_dimension_id
      AND    pbt.legislation_code     = 'IN';
    --

  --
  BEGIN
  --
      l_procedure := g_package||'ytd_balance';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

       IF g_debug THEN
          pay_in_utils.trace ('**************************************************','********************');
          pay_in_utils.trace ('p_assignment_action_id',p_assignment_action_id);
          pay_in_utils.trace ('p_balance_name',p_balance_name);
          pay_in_utils.trace ('**************************************************','********************');
       END IF;
       pay_in_utils.trace('Fetching value of ',p_balance_name||'_ASG_RUN');
       pay_in_utils.set_location(g_debug,l_procedure,20);

       OPEN  c_balance_value('_ASG_RUN');
       FETCH c_balance_value INTO l_ytd_balance;
       CLOSE c_balance_value;

       pay_in_utils.trace(p_balance_name||'_ASG_RUN ',l_ytd_balance);
       pay_in_utils.set_location(g_debug,l_procedure,30);
       p_ytd_balance      := l_ytd_balance;

       IF g_debug THEN
          pay_in_utils.trace ('**************************************************','********************');
          pay_in_utils.trace ('p_ytd_balance',p_ytd_balance);
          pay_in_utils.trace ('**************************************************','********************');
       END IF;

       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
  --
   EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,40);
       pay_in_utils.trace(l_message,l_procedure);

      IF c_balance_value%ISOPEN THEN
        CLOSE c_balance_value;
      END IF;
      RAISE;
  --
  END ytd_balance;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : BALANCE_TOTALS                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to return PTD and YTD values of the       --
  --                  values of taxable_earnings,non_taxable_earnings,    --
  --                  voluntary_deductions and statutory_deductions for a --
  --                  given assignment_action_id                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id       NUMBER                 --
  --            OUT : p_gross_salary_les_alw_ytd   NUMBER                 --
  --                  p_deductions_us_16_ytd       NUMBER                 --
  --                  p_gross_salary_ytd           NUMBER                 --
  --                  p_deductions_chapter_VIa_ytd NUMBER                 --
  --                  p_total_income_ytd           NUMBER                 --
  --                  p_tax_on_total_income_ytd    NUMBER                 --
  --                  p_rebates_us_88_ytd          NUMBER                 --
  --                  p_income_tax_ytd             NUMBER                 --
  --                  p_statutory_deductions_ytd   NUMBER                 --
  --                                                                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE balance_totals
    (
      p_assignment_action_id              IN  NUMBER
     ,p_gross_salary_les_alw_ytd          OUT NOCOPY NUMBER
     ,p_deductions_us_16_ytd              OUT NOCOPY NUMBER
     ,p_gross_salary_ytd                  OUT NOCOPY NUMBER
     ,p_deductions_chapter_VIa_ytd        OUT NOCOPY NUMBER
     ,p_total_income_ytd                  OUT NOCOPY NUMBER
     ,p_tax_on_total_income_ytd           OUT NOCOPY NUMBER
     ,p_rebates_us_88_ytd                 OUT NOCOPY NUMBER
     ,p_income_tax_ytd                    OUT NOCOPY NUMBER
    )
  IS
  --
    l_procedure                     VARCHAR2(100);
    l_message                       VARCHAR2(250);


    l_deductions_us_16_ytd          NUMBER;
    l_gross_salary_ytd              NUMBER;
    l_deductions_chapter_VIa_ytd    NUMBER;
    l_total_income_ytd              NUMBER;
    l_tax_on_total_income_ytd       NUMBER;
    l_rebates_us_88_ytd             NUMBER;
    l_income_tax_ytd                NUMBER;
    l_gross_sal_less_alw_ytd        NUMBER;
    l_rebates_sec88_ytd             NUMBER;
    l_rebates_sec88b_ytd            NUMBER;
    l_rebates_sec88c_ytd            NUMBER;
    l_rebates_sec88d_ytd            NUMBER;

  --
  BEGIN
    l_procedure := g_package||'balance_totals';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    -- Call procedure to get Current and YTD balances for Payment Summary Totals

       IF g_debug THEN
          pay_in_utils.trace ('**************************************************','********************');
          pay_in_utils.trace ('p_assignment_action_id',p_assignment_action_id);
          pay_in_utils.trace ('**************************************************','********************');
       END IF;

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Gross Salary less Allowances'
                 ,p_ytd_balance           => l_gross_sal_less_alw_ytd
                );

     pay_in_utils.trace('l_gross_sal_less_alw_ytd ',l_gross_sal_less_alw_ytd);
     pay_in_utils.set_location(g_debug,l_procedure,20);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Income Chargeable Under head Salaries'
                 ,p_ytd_balance           => l_gross_salary_ytd
                );
     pay_in_utils.trace('l_gross_salary_ytd ',l_gross_salary_ytd);
     pay_in_utils.set_location(g_debug,l_procedure,30);
     l_deductions_us_16_ytd := l_gross_sal_less_alw_ytd - l_gross_salary_ytd;
     pay_in_utils.trace('l_deductions_us_16_ytd ',l_deductions_us_16_ytd);
     pay_in_utils.set_location(g_debug,l_procedure,40);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Total Chapter VI A Deductions'
                 ,p_ytd_balance           => l_deductions_chapter_VIa_ytd
                );

    pay_in_utils.trace('l_deductions_chapter_VIa_ytd ',l_deductions_chapter_VIa_ytd);
    pay_in_utils.set_location(g_debug,l_procedure,50);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Total Income'
                 ,p_ytd_balance           => l_total_income_ytd
                );

    pay_in_utils.trace('l_total_income_ytd ',l_total_income_ytd);
           pay_in_utils.set_location(g_debug,l_procedure,60);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Tax on Total Income'
                 ,p_ytd_balance           => l_tax_on_total_income_ytd
                );

    pay_in_utils.trace('l_tax_on_total_income_ytd ',l_tax_on_total_income_ytd);
           pay_in_utils.set_location(g_debug,l_procedure,70);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Rebate 88'
                 ,p_ytd_balance           => l_rebates_sec88_ytd
                );

    pay_in_utils.trace('l_rebates_sec88_ytd ',l_rebates_sec88_ytd);
    pay_in_utils.set_location(g_debug,l_procedure,80);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Rebate 88B'
                 ,p_ytd_balance           => l_rebates_sec88b_ytd
                );

    pay_in_utils.trace('l_rebates_sec88b_ytd ',l_rebates_sec88b_ytd);
    pay_in_utils.set_location(g_debug,l_procedure,90);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Rebate 88C'
                 ,p_ytd_balance           => l_rebates_sec88c_ytd
                );

    pay_in_utils.trace('l_rebates_sec88c_ytd ',l_rebates_sec88c_ytd);
    pay_in_utils.set_location(g_debug,l_procedure,100);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 Rebate 88D'
                 ,p_ytd_balance           => l_rebates_sec88d_ytd
                );

    pay_in_utils.trace('l_rebates_sec88d_ytd ',l_rebates_sec88d_ytd);
    pay_in_utils.set_location(g_debug,l_procedure,110);
    l_rebates_us_88_ytd := l_rebates_sec88_ytd + l_rebates_sec88b_ytd + l_rebates_sec88c_ytd + l_rebates_sec88d_ytd;
    pay_in_utils.trace('l_rebates_us_88_ytd ',l_rebates_us_88_ytd);
    pay_in_utils.set_location(g_debug,l_procedure,120);

    ytd_balance (
                  p_assignment_action_id  => p_assignment_action_id
                 ,p_balance_name          => 'F16 TDS'
                 ,p_ytd_balance           => l_income_tax_ytd
                );
    pay_in_utils.trace('l_income_tax_ytd ',l_income_tax_ytd);
    pay_in_utils.set_location(g_debug,l_procedure,130);

    p_gross_salary_les_alw_ytd       := l_gross_sal_less_alw_ytd;
    p_deductions_us_16_ytd           := l_deductions_us_16_ytd;
    p_gross_salary_ytd               := l_gross_salary_ytd;
    p_deductions_chapter_VIa_ytd     := l_deductions_chapter_VIa_ytd;
    p_total_income_ytd               := l_total_income_ytd;
    p_tax_on_total_income_ytd        := l_tax_on_total_income_ytd;
    p_rebates_us_88_ytd              := l_rebates_us_88_ytd;
    p_income_tax_ytd                 := l_income_tax_ytd;

    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_gross_salary_les_alw_ytd',p_gross_salary_les_alw_ytd);
       pay_in_utils.trace('p_deductions_us_16_ytd',p_deductions_us_16_ytd);
       pay_in_utils.trace('p_gross_salary_ytd',p_gross_salary_ytd);
       pay_in_utils.trace('p_deductions_chapter_VIa_ytd',p_deductions_chapter_VIa_ytd);
       pay_in_utils.trace('p_total_income_ytd',p_total_income_ytd);
       pay_in_utils.trace('p_tax_on_total_income_ytd',p_tax_on_total_income_ytd);
       pay_in_utils.trace('p_rebates_us_88_ytd',p_rebates_us_88_ytd);
       pay_in_utils.trace('p_income_tax_ytd',p_income_tax_ytd);
       pay_in_utils.trace('**************************************************','********************');
    END IF;

       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,140);

  --
  END balance_totals;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_EXCHANGE_RATE                                   --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : Function to return the exchange rate for a given    --
  --                  FROM and TO currency                                --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_from_currency      VARCHAR2                       --
  --                  p_to_currency        VARCHAR2                       --
  --                  p_eff_date           DATE                           --
  --                  p_business_group_id  NUMBER                         --
  --            OUT : N/A                                                 --
  --         RETURN : NUMBER                                              --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Replaced %TYPE with actual data type --
  --                                 in parameter list.                   --
  --------------------------------------------------------------------------
  --
  FUNCTION get_exchange_rate
    (
      p_from_currency           IN VARCHAR2
     ,p_to_currency             IN VARCHAR2
     ,p_eff_date                IN DATE
     ,p_business_group_id       IN NUMBER
    )
  RETURN NUMBER IS
  --
    --
    CURSOR c_rate
    IS
      SELECT gdr.conversion_rate
      FROM   gl_daily_rates            gdr
            ,gl_daily_conversion_types gdct
      WHERE  gdr.conversion_type       = gdct.conversion_type
      AND    gdr.from_currency         = p_from_currency
      AND    gdr.to_currency           = p_to_currency
      AND    gdr.conversion_date       = p_eff_date
      AND    gdct.user_conversion_type = (
                                           SELECT  puci.value
                                           FROM    pay_user_column_instances_f puci
                                                  ,pay_user_rows_f pur
                                                  ,pay_user_columns puc
                                                  ,pay_user_tables put
                                           WHERE   puci.user_row_id          = pur.user_row_id
                                           AND     puci.user_column_id       = puc.user_column_id
                                           AND     pur.user_table_id         = put.user_table_id
                                           AND     puc.user_table_id         = put.user_table_id
                                           AND     puci.business_group_id    = p_business_group_id
                                           AND     pur.ROW_LOW_RANGE_OR_NAME = 'PAY'
                                           AND     put.user_table_name       = 'EXCHANGE_RATE_TYPES'
                                         );
    --
    l_rate          NUMBER;
    l_procedure     VARCHAR2(100);
    l_message                       VARCHAR2(250);
  --
  BEGIN
  --
     l_procedure := g_package || 'get_exchange_rate';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


       IF g_debug THEN
          pay_in_utils.trace ('**************************************************','********************');
          pay_in_utils.trace ('p_from_currency',p_from_currency);
          pay_in_utils.trace ('p_to_currency',p_to_currency);
          pay_in_utils.trace ('p_eff_date',p_eff_date);
          pay_in_utils.trace ('p_business_group_id',p_business_group_id);
          pay_in_utils.trace ('**************************************************','********************');
       END IF;

    IF p_from_currency <> p_to_currency THEN
    --
       OPEN c_rate;
       FETCH c_rate INTO l_rate;
       IF c_rate%NOTFOUND THEN
       --
         l_rate := null;
       --
       END IF;
       CLOSE c_rate;

    --
    ELSE
    --
      l_rate := null;
    --
    END IF;
    pay_in_utils.trace ('**************************************************','********************');
    pay_in_utils.trace('l_rate',l_rate);
    pay_in_utils.trace ('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
    RETURN(l_rate);
  --
   EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,40);
       pay_in_utils.trace(l_message,l_procedure);

     IF c_rate%ISOPEN THEN
        CLOSE c_rate;
      END IF;
      RAISE;
  --
  END get_exchange_rate;

--
BEGIN
g_package := 'pay_in_payslip_utils.';
END pay_in_payslip_utils;

/
