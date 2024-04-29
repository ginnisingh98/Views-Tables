--------------------------------------------------------
--  DDL for Package PAY_CN_PAYSLIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_PAYSLIP" AUTHID CURRENT_USER AS
/* $Header: pycnpslp.pkh 120.0.12010000.2 2008/12/05 06:09:12 rsaharay ship $ */

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
  --------------------------------------------------------------------------
  --
  PROCEDURE current_and_ytd_balances
    (
      p_prepaid_tag                   IN  VARCHAR2
     ,p_assignment_action_id          IN  NUMBER
     ,p_balance_name                  IN  VARCHAR2
     ,p_current_balance               OUT NOCOPY NUMBER
     ,p_ytd_balance                   OUT NOCOPY NUMBER
    );

  --

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
    );

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_RUN_RESULT_VALUE                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to run_result_value of a given            --
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
  --
  PROCEDURE get_run_result_value
    (
      p_assignment_action_id          IN  NUMBER
     ,p_element_name                  IN  VARCHAR2
     ,p_input_value_name              IN  VARCHAR2
     ,p_value                         OUT NOCOPY NUMBER
    );

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
  --------------------------------------------------------------------------
  --
  FUNCTION get_exchange_rate
    (
      p_from_currency                 IN VARCHAR2
     ,p_to_currency                   IN VARCHAR2
     ,p_eff_date                      IN DATE
     ,p_business_group_id             IN NUMBER
    )
  RETURN NUMBER;
  --

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
  RETURN VARCHAR2;
END pay_cn_payslip;

/
