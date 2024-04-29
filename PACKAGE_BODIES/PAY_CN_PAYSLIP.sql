--------------------------------------------------------
--  DDL for Package Body PAY_CN_PAYSLIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_PAYSLIP" AS
/* $Header: pycnpslp.pkb 120.1.12010000.3 2008/12/05 06:13:55 rsaharay ship $ */

  --
  g_package_name   VARCHAR2(100);
  --
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CURRENT_AND_YTD_BALANCES                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to return PTD and YTD values of a balance --
  --                  for a given assignment_action_id                    --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_prepaid_tag          VARCHAR2                     --
  --                  p_assignment_action_id NUMBER                       --
  --                  p_balance_name         VARCHAR2                     --
  --            OUT : p_current_balance      NUMBER                       --
  --                  p_ytd_balance          NUMBER                       --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Replaced %TYPE with actual data type --
  --                                 in parameter list.                   --
  --                                 Changed parameters for cursor        --
  --                                 c_balance_value                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE current_and_ytd_balances
    (
      p_prepaid_tag           IN  VARCHAR2
     ,p_assignment_action_id  IN  NUMBER
     ,p_balance_name          IN  VARCHAR2
     ,p_current_balance       OUT NOCOPY NUMBER
     ,p_ytd_balance           OUT NOCOPY NUMBER
    )
  IS
  --
    l_curr_balance      NUMBER;
    l_ytd_balance       NUMBER;
    l_procedure         VARCHAR2(100);
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
      AND    pbt.legislation_code     = 'CN';
    --

  --
  BEGIN
  --
    --
       l_procedure := g_package_name || '.current_and_ytd_balances';
       hr_utility.set_location('Entering '||l_procedure,10);
       --
       hr_utility.set_location('Fetching value of ' ||p_balance_name|| '_ASG_PTD',20);

       OPEN  c_balance_value('_ASG_PTD');
       FETCH c_balance_value INTO l_curr_balance;
       CLOSE c_balance_value;

       hr_utility.set_location('Fetching value of '||p_balance_name||'_ASG_PTD',30);

       OPEN  c_balance_value('_ASG_YTD');
       FETCH c_balance_value INTO l_ytd_balance;
       CLOSE c_balance_value;

       p_current_balance  := l_curr_balance;
       p_ytd_balance      := l_ytd_balance;

       --
       hr_utility.set_location('Leaving '||l_procedure,40);
  --
  EXCEPTION
  --
    WHEN others THEN
      hr_utility.set_location('Error in '||l_procedure,50);
      IF c_balance_value%ISOPEN THEN
        CLOSE c_balance_value;
      END IF;
      RAISE;
  --
  END current_and_ytd_balances;

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
  --             IN : p_prepaid_tag                    VARCHAR2           --
  --                  p_assignment_action_id           NUMBER             --
  --            OUT : p_taxable_earnings_current       NUMBER             --
  --                  p_non_taxable_earnings_current   NUMBER             --
  --                  p_voluntary_deductions_current   NUMBER             --
  --                  p_statutory_deductions_current   NUMBER             --
  --                  p_pre_tax_deductions_current     NUMBER             --
  --                  p_taxable_earnings_ytd           NUMBER             --
  --                  p_non_taxable_earnings_ytd       NUMBER             --
  --                  p_voluntary_deductions_ytd       NUMBER             --
  --                  p_statutory_deductions_ytd       NUMBER             --
  --                  p_pre_tax_deductions_ytd         NUMBER             --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Replaced %TYPE with actual data type --
  --                                 in parameter list.                   --
  --                                 Added EXCEPTION block.               --
  -- 115.2 03-SEP-2003    bramajey   Added code to get the value of       --
  --                                 Severance Earnings,                  --
  --                                 Special Payments Separate            --
  --                                 and Special Payments Spread balance  --
  --                                 and add them tp 'Taxable Earnings'   --
  -- 115.3 17-OCT-2003    vinaraya   Added code to include the 'Direct    --
  --                                 Payments' balance values in 'Non     --
  --                                 Taxable Earnings' Balance values for --
  --                                 bug 3198882                          --
  -- 115.4 05-Apr-2004    bramajey   Added calls to                       --
  --                                 'CURRENT_AND_YTD_BALANCES'           --
  --                                 to fetch 'Retro Taxable              --
  --                                 Earnings','Retro Statutory           --
  --                                 Deductions' and 'Retro               --
  --                                 Special Payments'                    --
  -- 115.5 05-Aug-2004    snekkala   Added calls to                       --
  --                                 'CURRENT_AND_YTD_BALANCES'           --
  --                                 to fetch 'Variable Yearly Earnings'  --
  --                                 and 'Retro Variable Yearly Earnings' --
  -- 115.6 05-Aug-2004    snekkala   Removed the coding errors            --
  -- 115.7 20-Jul-2005    rpalli     Bug4303538: Yearly Annual Bonus      --
  --       			     Implementation			  --
  -- 115.8 01-Dec-2008    rsaharay   Added code for Pre Tax Non Statutory --
  --                                 Deductions                           --
  --------------------------------------------------------------------------
  --

  PROCEDURE balance_totals
    (
      p_prepaid_tag                   IN  VARCHAR2
     ,p_assignment_action_id          IN  NUMBER
     ,p_taxable_earnings_current      OUT NOCOPY NUMBER
     ,p_non_taxable_earnings_current  OUT NOCOPY NUMBER
     ,p_voluntary_deductions_current  OUT NOCOPY NUMBER
     ,p_statutory_deductions_current  OUT NOCOPY NUMBER
     ,p_pre_tax_deductions_current    OUT NOCOPY NUMBER
     ,p_taxable_earnings_ytd          OUT NOCOPY NUMBER
     ,p_non_taxable_earnings_ytd      OUT NOCOPY NUMBER
     ,p_voluntary_deductions_ytd      OUT NOCOPY NUMBER
     ,p_statutory_deductions_ytd      OUT NOCOPY NUMBER
     ,p_pre_tax_deductions_ytd        OUT NOCOPY NUMBER
    )
  IS
  --
    l_procedure                       VARCHAR2(100);
    l_tot_taxable_earnings_current    NUMBER;
    l_taxable_earnings_current        NUMBER;
    l_sev_earnings_current            NUMBER;
    l_spec_separate_current           NUMBER;
    l_spec_spread_current             NUMBER;
    l_non_taxable_earnings_current    NUMBER;
    l_voluntary_deductions_current    NUMBER;
    l_statutory_deductions_current    NUMBER;
    l_pre_tax_deductions_current      NUMBER;
    l_tot_taxable_earnings_ytd        NUMBER;
    l_taxable_earnings_ytd            NUMBER;
    l_sev_earnings_ytd                NUMBER;
    l_spec_separate_ytd               NUMBER;
    l_spec_spread_ytd                 NUMBER;
    l_non_taxable_earnings_ytd        NUMBER;
    l_voluntary_deductions_ytd        NUMBER;
    l_statutory_deductions_ytd        NUMBER;
    l_pre_tax_deductions_ytd          NUMBER;

    -- Bug 4303538
    -- Declare Variables
    l_annual_bonus_current            NUMBER;
    l_annual_bonus_ytd                NUMBER;
    l_retro_ann_bonus_current         NUMBER;
    l_retro_ann_bonus_ytd            NUMBER;

    -- Bug 3290973
    -- Declare Variables
    l_retro_tax_earnings_current      NUMBER;
    l_retro_tax_earnings_ytd          NUMBER;
    l_retro_stat_ded_current          NUMBER;
    l_retro_stat_ded_ytd              NUMBER;
    l_retro_spec_pay_current          NUMBER;
    l_retro_spec_pay_ytd              NUMBER;
    l_retro_pre_tax_ded_current            NUMBER;
    l_retro_pre_tax_ded_ytd                NUMBER;
    l_tot_stat_ded_current            NUMBER;
    l_tot_stat_ded_ytd                NUMBER;
    l_tot_pre_tax_ded_current            NUMBER;
    l_tot_pre_tax_ded_ytd                NUMBER;

    --
    -- Bug 3812288
    -- Declare Variables
    --
    l_var_yrly_pay_current            NUMBER;
    l_var_yrly_pay_ytd                NUMBER;
    l_retro_var_yrly_current          NUMBER;
    l_retro_var_yrly_ytd              NUMBER;

    /************* Bug 3198882: Changes Start   *******************************************/
    /************* Local variables to store 'Direct Payment' PTD and YTD balances *********/

    l_dir_payments_current            NUMBER;
    l_dir_payments_ytd                NUMBER;
    l_tot_non_taxable_earnings_cur    NUMBER;
    l_tot_non_taxable_earnings_ytd    NUMBER;

  --
  BEGIN
  --
    l_procedure := g_package_name || '.balance_totals';
    hr_utility.set_location('Entering '||l_procedure,10);

    -- Call procedure to get Current and YTD balances for Payment Summary Totals

    hr_utility.set_location('Fetching value of Taxable Earnings balance',20);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Taxable Earnings'
                              ,p_current_balance       => l_taxable_earnings_current
                              ,p_ytd_balance           => l_taxable_earnings_ytd
                             );


    -- Bug 3116630 starts
    -- The following balances should be added up to 'Taxable Earnings' Balance
    --
    hr_utility.set_location('Fetching value of Severance Earnings balance',22);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Severance Earnings'
                              ,p_current_balance       => l_sev_earnings_current
                              ,p_ytd_balance           => l_sev_earnings_ytd
                             );

    -- Bug 4303538 starts
    -- The following balance should be added up to 'Taxable Earnings' Balance
    --
    hr_utility.set_location('Fetching value of Annual Bonus balance',24);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Annual Bonus'
                              ,p_current_balance       => l_annual_bonus_current
                              ,p_ytd_balance           => l_annual_bonus_ytd
                             );
    -- Bug 4303538 ends

    hr_utility.set_location('Fetching value of Special Payments Separate balance',25);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Special Payments Separate'
                              ,p_current_balance       => l_spec_separate_current
                              ,p_ytd_balance           => l_spec_separate_ytd
                             );


    hr_utility.set_location('Fetching value of Special Payments Spread balance',27);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Special Payments Spread'
                              ,p_current_balance       => l_spec_spread_current
                              ,p_ytd_balance           => l_spec_spread_ytd
                             );

    -- Bug 3290973 Starts
    -- Fetch 'Retro Taxable Earnings' and 'Retro Special Payments' Balances and them
    -- to 'Taxable Earnings' Balance

    hr_utility.set_location('Fetching value of Retro Taxable Earnings balance',28);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Retro Taxable Earnings'
                              ,p_current_balance       => l_retro_tax_earnings_current
                              ,p_ytd_balance           => l_retro_tax_earnings_ytd
                             );

    hr_utility.set_location('Fetching value of Retro Special Payments  balance',28);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Retro Special Payments'
                              ,p_current_balance       => l_retro_spec_pay_current
                              ,p_ytd_balance           => l_retro_spec_pay_ytd
                             );

    -- Bug 4303538 starts
    -- The following balance should be added up to 'Taxable Earnings' Balance
    --
    hr_utility.set_location('Fetching value of Retro Annual Bonus balance',28);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Retro Annual Bonus'
                              ,p_current_balance       => l_retro_ann_bonus_current
                              ,p_ytd_balance           => l_retro_ann_bonus_ytd
                             );
    -- Bug 4303538 ends

    hr_utility.set_location('Fetching value of Variable Yearly Earnings balance',28);

    --
    -- Bug 3812288 Changes start
    --
    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Variable Yearly Earnings'
                              ,p_current_balance       => l_var_yrly_pay_current
                              ,p_ytd_balance           => l_var_yrly_pay_ytd
                             );

    hr_utility.set_location('Fetching value of Retro Variable yearly Earnings balance',28);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Retro Variable Yearly Earnings'
                              ,p_current_balance       => l_retro_var_yrly_current
                              ,p_ytd_balance           => l_retro_var_yrly_ytd
                             );


    -- Add the balances
    --
    l_tot_taxable_earnings_current := l_taxable_earnings_current   + l_sev_earnings_current
                                    + l_spec_separate_current      + l_spec_spread_current
                                    + l_retro_tax_earnings_current + l_retro_spec_pay_current
				    + l_var_yrly_pay_current       + l_retro_var_yrly_current
                                    + l_annual_bonus_current       + l_retro_ann_bonus_current;

    l_tot_taxable_earnings_ytd     := l_taxable_earnings_ytd     + l_sev_earnings_ytd
                                    + l_spec_separate_ytd        + l_spec_spread_ytd
                                    + l_retro_tax_earnings_ytd   + l_retro_spec_pay_ytd
				    + l_var_yrly_pay_ytd         + l_retro_var_yrly_ytd
   	                            + l_annual_bonus_ytd         + l_retro_ann_bonus_ytd;


    --
    -- Bug 3812288 Changes end
    --
    -- Bug 3290973 ends

    -- Bug 3116630 ends

    hr_utility.set_location('Fetching value of Non Taxable Earnings balance',30);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Non Taxable Earnings'
                              ,p_current_balance       => l_non_taxable_earnings_current
                              ,p_ytd_balance           => l_non_taxable_earnings_ytd
                             );

    -- Bug 3198882 : Changes Start
    -- Included the 'Direct Payments' PTD and YTD balance values in 'Non Taxable Earnings'
    -- PTD and YTD balances for archival

    hr_utility.set_location('Fetching Value of Direct payments balance',35);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Direct Payments'
                              ,p_current_balance       => l_dir_payments_current
                              ,p_ytd_balance           => l_dir_payments_ytd
                             );

    -- Add the 'Direct Payments' Balance Values to 'Non Taxable Earnings' balance values

    l_tot_non_taxable_earnings_cur := l_non_taxable_earnings_current + l_dir_payments_current;
    l_tot_non_taxable_earnings_ytd := l_non_taxable_earnings_ytd + l_dir_payments_ytd;

    -- Bug 3198882 : Changes End

    hr_utility.set_location('Fetching value of Voluntary Deductions balance',40);


    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Voluntary Deductions'
                              ,p_current_balance       => l_voluntary_deductions_current
                              ,p_ytd_balance           => l_voluntary_deductions_ytd
                             );

    hr_utility.set_location('Fetching value of Statutory Deductions balance',50);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Statutory Deductions'
                              ,p_current_balance       => l_statutory_deductions_current
                              ,p_ytd_balance           => l_statutory_deductions_ytd
                             );

    -- Bug 3290973 Starts
    -- Fetch 'Retro Statutory Deductions' and it
    -- to 'Statutory Deductions' Balance

    hr_utility.set_location('Fetching value of Retro Statutory Deductions balance',52);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Retro Statutory Deductions'
                              ,p_current_balance       => l_retro_stat_ded_current
                              ,p_ytd_balance           => l_retro_stat_ded_ytd
                             );

    -- Add the Balances

    l_tot_stat_ded_current := l_statutory_deductions_current + l_retro_stat_ded_current;
    l_tot_stat_ded_ytd     := l_statutory_deductions_ytd     + l_retro_stat_ded_ytd;

    hr_utility.set_location('Fetching value of Pre Tax Non Statutory Deductions balance',53);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Pre Tax Non Statutory Deductions'
                              ,p_current_balance       => l_pre_tax_deductions_current
                              ,p_ytd_balance           => l_pre_tax_deductions_ytd
                             );


    hr_utility.set_location('Fetching value of Retro Pre Tax Non Statutory Deductions balance',54);

    current_and_ytd_balances (
                               p_prepaid_tag           => p_prepaid_tag
                              ,p_assignment_action_id  => p_assignment_action_id
                              ,p_balance_name          => 'Retro Pre Tax Non Statutory Deductions'
                              ,p_current_balance       => l_retro_pre_tax_ded_current
                              ,p_ytd_balance           => l_retro_pre_tax_ded_ytd
                             );




    l_tot_pre_tax_ded_current := l_pre_tax_deductions_current + l_retro_pre_tax_ded_current;
    l_tot_pre_tax_ded_ytd     := l_pre_tax_deductions_ytd     + l_retro_pre_tax_ded_ytd;


    p_taxable_earnings_current       :=  l_tot_taxable_earnings_current;
    p_voluntary_deductions_current   :=  l_voluntary_deductions_current;
    p_statutory_deductions_current   :=  l_tot_stat_ded_current;
    p_pre_tax_deductions_current     :=  l_tot_pre_tax_ded_current;
    p_taxable_earnings_ytd           :=  l_tot_taxable_earnings_ytd;
    p_voluntary_deductions_ytd       :=  l_voluntary_deductions_ytd;
    p_statutory_deductions_ytd       :=  l_tot_stat_ded_ytd;
    p_pre_tax_deductions_ytd         :=  l_tot_pre_tax_ded_ytd;

    -- Bug 3290973 ends

    -- Bug 3198882 : Changes Start

    p_non_taxable_earnings_current   :=  l_tot_non_taxable_earnings_cur;
    p_non_taxable_earnings_ytd       :=  l_tot_non_taxable_earnings_ytd;

    -- Bug 3198882 : Changes End

    hr_utility.set_location('Leaving '||l_procedure,55);

  --
  EXCEPTION
  --
    WHEN others THEN
      hr_utility.set_location('Error in '||l_procedure,60);
      RAISE;
  --
  END balance_totals;


   --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_RUN_RESULT_VALUE                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to return run_result_value of a given     --
  --                  element name and input value name for a given       --
  --                  payroll assignment_action_id                        --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --                  p_assignment_action_id NUMBER                       --
  --                  p_element_name         VARCHAR2                     --
  --                  p_input_value_name     VARCHAR2                     --
  --            OUT : p_value                NUMBER                       --
  --                                                                      --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 03-SEP-2003    bramajey   Initial Version                      --
  -- 115.1 14-Sep-2004    snekkala   Added condition to check if          --
  --                                 run result value exists or not       --
  -- 115.2  28-May-2008   dduvvuri   Added fnd_number.canonical_to_number
  --                                 in the cursor before selecting the
  --                                 run result value.
  --------------------------------------------------------------------------
  --
  PROCEDURE get_run_result_value
    (
      p_assignment_action_id          IN  NUMBER
     ,p_element_name                  IN  VARCHAR2
     ,p_input_value_name              IN  VARCHAR2
     ,p_value                         OUT NOCOPY NUMBER
    )
  IS
  --
    CURSOR csr_value
    IS
    --
      SELECT  fnd_number.canonical_to_number(prrv.result_value)
      FROM    pay_assignment_actions paa
             ,pay_payroll_actions    ppa
             ,pay_element_types_f    pet
             ,pay_input_values_f     piv
             ,pay_run_results        prr
             ,pay_run_result_values  prrv
       WHERE  paa.assignment_action_id = p_assignment_action_id
       AND    ppa.payroll_action_id    = paa.payroll_action_id
       AND    ppa.action_type         IN ('Q','R')
       AND    ppa.action_status        = 'C'
       AND    paa.assignment_action_id = prr.assignment_action_id
       AND    pet.element_name         = p_element_name
       AND    pet.legislation_code     = 'CN'
       AND    pet.element_type_id      = prr.element_type_id
       AND    prr.run_result_id        = prrv.run_result_id
       AND    pet.element_type_id      = piv.element_type_id
       AND    piv.name                 = p_input_value_name
       AND    piv.input_value_id       = prrv.input_value_id
       AND    ppa.effective_date BETWEEN piv.effective_start_date
                                     AND piv.effective_end_date
       AND    ppa.effective_date BETWEEN pet.effective_start_date
                                     AND pet.effective_end_date;
    --
    l_procedure     VARCHAR2(100);
    l_value         NUMBER;
  --
  BEGIN
  --
    l_procedure := g_package_name || '.get_value';
    hr_utility.set_location('Entering '||l_procedure,10);

    OPEN csr_value;

    FETCH csr_value
        INTO l_value;
    --
    -- Bug 3771856 Changes start
    -- Sparse matrix
    --
    IF csr_value%NOTFOUND THEN
        l_value:=0;
    END IF;
    --
    -- Bug 3771856 Changes end
    --
    CLOSE csr_value;

    p_value := l_value;

    hr_utility.set_location('Leaving '||l_procedure,10);
  --
  EXCEPTION
  --
    WHEN others THEN
       IF csr_value%ISOPEN THEN
       --
         CLOSE csr_value;
       --
       END IF;
  --
  END get_run_result_value;
  --



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
  --
  BEGIN
  --
    l_procedure := g_package_name || '.get_exchange_rate';
    hr_utility.set_location('Entering '||l_procedure,10);

    IF p_from_currency <> p_to_currency THEN
    --
       hr_utility.set_location('Opening cursor c_rate ', 20);

       OPEN c_rate;
       FETCH c_rate INTO l_rate;
       IF c_rate%NOTFOUND THEN
       --
         l_rate := null;
       --
       END IF;
       CLOSE c_rate;

       hr_utility.set_location('Closing cursor c_rate ',30);
    --
    ELSE
    --
      l_rate := null;
    --
    END IF;
    RETURN(l_rate);

    hr_utility.set_location('Leaving '||l_procedure,40);
  --
  EXCEPTION
  --
    WHEN others THEN
      hr_utility.set_location('Error in '||l_procedure,50);
      IF c_rate%ISOPEN THEN
        CLOSE c_rate;
      END IF;
      RAISE;
  --
  END get_exchange_rate;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : BUSINESS_CURRENCY_CODE                              --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : Function to return business_currency_code for       --
  --                  given business_group_id                             --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id  NUMBER                         --
  --            OUT : N/A                                                 --
  --         RETURN : VARCHAR2                                            --
  --------------------------------------------------------------------------
  --
  FUNCTION business_currency_code
    (
      p_business_group_id  IN NUMBER
    )
  RETURN VARCHAR2
  IS
  --
    l_currency_code  VARCHAR2(15);
    l_procedure      VARCHAR2(100);

    --
    CURSOR c_currency_code
    IS
      SELECT fcu.currency_code
      FROM   hr_organization_information hoi,
             hr_organization_units hou,
             fnd_currencies fcu
      WHERE  hou.business_group_id       = p_business_group_id
      AND    hou.organization_id         = hoi.organization_id
      AND    hoi.org_information_context = 'Business Group Information'
      AND    fcu.issuing_territory_code  = hoi.org_information9;
    --
  --
  BEGIN
  --
    l_procedure :=  g_package_name || '.business_currency_code';
    hr_utility.set_location('Entering '||l_procedure,10);

    hr_utility.set_location('Opening cursor c_currency_code',20);

    OPEN c_currency_code ;
    FETCH c_currency_code INTO l_currency_code;
    CLOSE c_currency_code;

    hr_utility.set_location('Closing cursor c_currency_code',30);

    hr_utility.set_location('Leaving '||l_procedure,40);

    RETURN l_currency_code;
  --
  EXCEPTION
  --
    WHEN others THEN
      hr_utility.set_location('Error in '||l_procedure,50);
      IF c_currency_code%ISOPEN THEN
        CLOSE c_currency_code;
      END IF;
      RAISE;
  --
  END business_currency_code;

BEGIN
   g_package_name := 'pay_cn_payslip';
--
END pay_cn_payslip;

/
