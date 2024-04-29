--------------------------------------------------------
--  DDL for Package PAY_IN_PAYSLIP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_PAYSLIP_UTILS" AUTHID CURRENT_USER AS
/* $Header: pyinpslp.pkh 120.0 2005/05/29 05:52 appldev noship $ */

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
      p_assignment_action_id          IN  NUMBER
     ,p_balance_name                  IN  VARCHAR2
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
    );


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

END pay_in_payslip_utils;

 

/
