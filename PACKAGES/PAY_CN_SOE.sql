--------------------------------------------------------
--  DDL for Package PAY_CN_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_SOE" AUTHID CURRENT_USER AS
/* $Header: pycnsoe.pkh 120.2.12010000.2 2008/12/05 06:16:14 rsaharay ship $ */

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
RETURN LONG;

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
RETURN LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_STATUTORY_DEDUCTIONS                            --
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
RETURN LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_NON_STATUTORY_DEDUCTIONS                            --
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
RETURN LONG;


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
RETURN LONG;

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
RETURN LONG;

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
--                                                                      --
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
--                                                                      --
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
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_annual_leave_information(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
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
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_leave_taken(p_assignment_action_id IN OUT NOCOPY pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;

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
RETURN LONG;

END pay_cn_soe;

/
