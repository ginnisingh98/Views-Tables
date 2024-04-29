--------------------------------------------------------
--  DDL for Package PAY_HK_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_SOE_PKG" AUTHID CURRENT_USER as
/* $Header: pyhksoe.pkh 120.2.12010000.1 2008/07/27 22:48:58 appldev ship $ */

  function get_balance_id
     (p_balance_name                in pay_balance_types.balance_name%type,
      p_dimension_name              in pay_balance_dimensions.dimension_name%type)
  return pay_defined_balances.defined_balance_id%type;

  procedure balance_totals
    (p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_tax_unit_id                 in pay_assignment_actions.tax_unit_id%type,
     p_total_earnings_this_pay     out nocopy number,
     p_total_earnings_ytd          out nocopy number,
     p_total_deductions_this_pay   out nocopy number,
     p_total_deductions_ytd        out nocopy number,
     p_net_pay_this_pay            out nocopy number,
     p_net_pay_ytd                 out nocopy number,
     p_direct_payments_this_pay    out nocopy number,
     p_direct_payments_ytd         out nocopy number,
     p_total_payment_this_pay      out nocopy number,
     p_total_payment_ytd           out nocopy number);

  function business_currency_code
    (p_business_group_id            in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type;

  /* Bug 4210525, Added variables */
  g_def_bal_id_populated_payment   boolean;
  g_def_bal_id_populated_ytd       boolean;

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
RETURN LONG;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DEDUCTIONS                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Deductions Region        --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_deductions(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;


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
RETURN LONG;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCES                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for balances                 --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_balances(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCES                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for balances                 --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
-- Bug 5396046                                                          --
--------------------------------------------------------------------------
FUNCTION get_payment_methods(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;

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
RETURN LONG;

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
RETURN LONG;

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
RETURN LONG;

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
RETURN LONG;

end pay_hk_soe_pkg;

/
