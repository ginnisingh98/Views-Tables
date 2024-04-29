--------------------------------------------------------
--  DDL for Package PAY_IN_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_SOE_PKG" AUTHID CURRENT_USER AS
/* $Header: pyinsoer.pkh 120.0.12010000.1 2008/07/27 22:54:34 appldev ship $ */

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
RETURN LONG;

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
RETURN LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PERIOD                                          --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Payroll Processing       --
--                  Information Region                                  --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_period(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;

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
FUNCTION get_earnings(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DEDUCTIONS                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Statutory Deductions     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_deductions(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ADVANCES                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Non Taxable Earnings     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_advances(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_FRINGE_BENEFITS                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Voluntary Deductions     --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_fringe_benefits(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PERQUISITES                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return SQL for Perquisites              --
--                  Region                                              --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_assignment_action_id          NUMBER              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_perquisites(p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
RETURN LONG;

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
RETURN LONG;

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
FUNCTION get_payment_details(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
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

END pay_in_soe_pkg;

/
