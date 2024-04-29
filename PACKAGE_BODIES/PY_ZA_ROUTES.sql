--------------------------------------------------------
--  DDL for Package Body PY_ZA_ROUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_ROUTES" AS
/* $Header: pyzarout.pkb 120.2 2005/07/04 02:29:29 kapalani noship $ */
------------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL TAX PERIOD balance dimension
--
FUNCTION ASG_TAX_PTD (p_assignment_action_id  NUMBER,
                      p_balance_type_id       NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_ASG_TAX_PTD      (assact_id  IN NUMBER,
                                  baltype    IN NUMBER) is
--
   select
        nvl(sum(TARGET.result_value * FEED.scale),0)
   from
         pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_payroll_actions    BACT,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
   and   FEED.balance_type_id            = baltype
   and   FEED.input_value_id             = TARGET.input_value_id
   and   TARGET.run_result_id            = RR.run_result_id
   and   RR.assignment_action_id         = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id        = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   RR.status in ('P','PA')
   and   PACT.time_period_id             = BACT.time_period_id
   and   ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
   and   ASSACT.assignment_id            = BAL_ASSACT.assignment_id;
--
BEGIN
--
     open cur_ASG_TAX_PTD(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_TAX_PTD INTO l_balance;
     close cur_ASG_TAX_PTD;
--
RETURN l_balance;
--
END ASG_TAX_PTD;
--
------------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL TAX YEAR balance dimension
--
FUNCTION ASG_TAX_YTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_ASG_TAX_YTD      (assact_id  IN NUMBER,
                                  baltype    IN NUMBER) is
--
   select
     nvl(sum(TARGET.result_value * FEED.scale),0)
   from
     pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_payroll_actions    BACT,
         per_time_periods       BPTP,
         per_time_periods       PPTP,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
   and   FEED.balance_type_id            = baltype
   and   FEED.input_value_id             = TARGET.input_value_id
   and   TARGET.run_result_id            = RR.run_result_id
   and   RR.assignment_action_id         = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id        = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   BACT.time_period_id                     = BPTP.time_period_id
   and   PACT.time_period_id                     = PPTP.time_period_id
   and   RR.status in ('P','PA')
   and   PPTP.prd_information1           = BPTP.prd_information1
   and   ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
   and   ASSACT.assignment_id            = BAL_ASSACT.assignment_id;
--
BEGIN
--
     open cur_ASG_TAX_YTD(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_TAX_YTD INTO l_balance;
     close cur_ASG_TAX_YTD;
--
RETURN l_balance;
--
END ASG_TAX_YTD;
--
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL TAX QUARTER balance dimension
--
FUNCTION ASG_TAX_QTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_ASG_TAX_QTD      (assact_id  IN NUMBER,
                                  baltype    IN NUMBER) is
--
   select
     nvl(sum(TARGET.result_value * FEED.scale),0)
   from
     pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_payroll_actions    BACT,
         per_time_periods       BPTP,
         per_time_periods       PPTP,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
   and   FEED.balance_type_id            = baltype
   and   FEED.input_value_id             = TARGET.input_value_id
   and   TARGET.run_result_id            = RR.run_result_id
   and   RR.assignment_action_id         = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id        = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   BACT.time_period_id                     = BPTP.time_period_id
   and   PACT.time_period_id                     = PPTP.time_period_id
   and   RR.status in ('P','PA')
   and   PPTP.prd_information1           = BPTP.prd_information1
   and   PPTP.prd_information2           = BPTP.prd_information2
   and   ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
   and   ASSACT.assignment_id            = BAL_ASSACT.assignment_id;
--
BEGIN
--
     open cur_ASG_TAX_QTD(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_TAX_QTD INTO l_balance;
     close cur_ASG_TAX_QTD;
--
RETURN l_balance;
--
END ASG_TAX_QTD;
--
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL TAX MONTH balance dimension
--
FUNCTION ASG_TAX_MTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
   cursor cur_ASG_TAX_MTD      (assact_id  IN NUMBER,
                                  baltype    IN NUMBER) is
--
   select
     nvl(sum(TARGET.result_value * FEED.scale),0)
   from
     pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_payroll_actions    BACT,
         per_time_periods       BPTP,
         per_time_periods       PPTP,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
   and   FEED.balance_type_id            = baltype
   and   FEED.input_value_id             = TARGET.input_value_id
   and   TARGET.run_result_id            = RR.run_result_id
   and   RR.assignment_action_id         = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id        = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   BACT.time_period_id                     = BPTP.time_period_id
   and   PACT.time_period_id                     = PPTP.time_period_id
   and   RR.status in ('P','PA')
   and   PPTP.pay_advice_date            = BPTP.pay_advice_date
   and   ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
   and   ASSACT.assignment_id            = BAL_ASSACT.assignment_id;
--
BEGIN
--
     open cur_ASG_TAX_MTD(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_TAX_MTD INTO l_balance;
     close cur_ASG_TAX_MTD;
--
RETURN l_balance;
--
END ASG_TAX_MTD;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL CALENDAR PERIOD balance dimension
--
FUNCTION ASG_CAL_PTD (p_assignment_action_id  NUMBER,
                      p_balance_type_id       NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_ASG_CAL_PTD      (assact_id  IN NUMBER,
                                  baltype    IN NUMBER) is
--
   select
        nvl(sum(TARGET.result_value * FEED.scale),0)
   from
         pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_payroll_actions    BACT,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
   and   FEED.balance_type_id            = baltype
   and   FEED.input_value_id             = TARGET.input_value_id
   and   TARGET.run_result_id            = RR.run_result_id
   and   RR.assignment_action_id         = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id        = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   RR.status in ('P','PA')
   and   PACT.time_period_id             = BACT.time_period_id
   and   ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
   and   ASSACT.assignment_id            = BAL_ASSACT.assignment_id;
--
BEGIN
--
     open cur_ASG_CAL_PTD(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_CAL_PTD INTO l_balance;
     close cur_ASG_CAL_PTD;
--
RETURN l_balance;
--
END ASG_CAL_PTD;
--
--------------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL CALENDAR YEAR balance dimension
--
FUNCTION ASG_CAL_YTD (p_assignment_action_id  NUMBER,
                      p_balance_type_id       NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_ASG_CAL_YTD      (assact_id  IN NUMBER,
                                  baltype    IN NUMBER) is
--
   select
        nvl(sum(TARGET.result_value * FEED.scale),0)
   from
         pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_payroll_actions    BACT,
         per_time_periods       BPTP,
         per_time_periods       PPTP,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
   and   FEED.balance_type_id            = baltype
   and   FEED.input_value_id             = TARGET.input_value_id
   and   TARGET.run_result_id            = RR.run_result_id
   and   RR.assignment_action_id         = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id        = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   BACT.time_period_id                     = BPTP.time_period_id
   and   PACT.time_period_id                     = PPTP.time_period_id
   and   RR.status in ('P','PA')
   and   PPTP.prd_information3           = BPTP.prd_information3
   and   ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
   and   ASSACT.assignment_id            = BAL_ASSACT.assignment_id;
--
BEGIN
--
     open cur_ASG_CAL_YTD(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_CAL_YTD INTO l_balance;
     close cur_ASG_CAL_YTD;
--
RETURN l_balance;
--
END ASG_CAL_YTD;
--
--------------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL CALENDAR MONTH balance dimension
--
FUNCTION ASG_CAL_MTD (p_assignment_action_id  NUMBER,
                      p_balance_type_id       NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_ASG_CAL_MTD      (assact_id  IN NUMBER,
                                  baltype    IN NUMBER) is
--
   select
        nvl(sum(TARGET.result_value * FEED.scale),0)
   from
         pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_payroll_actions    BACT,
         per_time_periods       BPTP,
         per_time_periods       PPTP,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
   and   FEED.balance_type_id            = baltype
   and   FEED.input_value_id             = TARGET.input_value_id
   and   TARGET.run_result_id            = RR.run_result_id
   and   RR.assignment_action_id         = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id        = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   BACT.time_period_id                     = BPTP.time_period_id
   and   PACT.time_period_id                     = PPTP.time_period_id
   and   RR.status in ('P','PA')
   and   PPTP.pay_advice_date            = BPTP.pay_advice_date
   and   ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
   and   ASSACT.assignment_id            = BAL_ASSACT.assignment_id;
--
BEGIN
--
     open cur_ASG_CAL_MTD(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_CAL_MTD INTO l_balance;
     close cur_ASG_CAL_MTD;
--
RETURN l_balance;
--
END ASG_CAL_MTD;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL INCEPTION-TO-DATE balance dimension
--
FUNCTION ASG_ITD (p_assignment_action_id  NUMBER,
                  p_balance_type_id       NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_ASG_ITD      (assact_id  IN NUMBER,
                              baltype    IN NUMBER) is
--
   select
        nvl(sum(TARGET.result_value * FEED.scale),0)
   from
         pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_payroll_actions    BACT,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
   and   FEED.balance_type_id         = baltype
   and   FEED.input_value_id          = TARGET.input_value_id
   and   TARGET.run_result_id         = RR.run_result_id
   and   RR.assignment_action_id      = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id     = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   RR.status in ('P','PA')
   and   ASSACT.action_sequence      <= BAL_ASSACT.action_sequence
   and   ASSACT.assignment_id         = BAL_ASSACT.assignment_id;
--
BEGIN
--
     open cur_ASG_ITD(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_ITD INTO l_balance;
     close cur_ASG_ITD;
--
RETURN l_balance;
--
END ASG_ITD;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL RUN balance dimension
--
FUNCTION ASG_RUN (p_assignment_action_id  NUMBER,
                  p_balance_type_id       NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_ASG_RUN      (assact_id  IN NUMBER,
                              baltype    IN NUMBER) is
--
   select
        nvl(sum(TARGET.result_value * FEED.scale),0)
   from
         pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT
   where ASSACT.assignment_action_id = assact_id
   and   FEED.balance_type_id        = baltype
   and   FEED.input_value_id         = TARGET.input_value_id
   and   TARGET.run_result_id        = RR.run_result_id
   and   RR.assignment_action_id     = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id    = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   RR.status in ('P','PA');
--
BEGIN
--
     open cur_ASG_RUN(p_assignment_action_id, p_balance_type_id);
     FETCH cur_ASG_RUN INTO l_balance;
     close cur_ASG_RUN;
--
RETURN l_balance;
--
END ASG_RUN;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL PAYMENTS balance dimension
--
FUNCTION PAYMENTS (p_assignment_action_id  NUMBER,
                           p_balance_type_id       NUMBER)
RETURN NUMBER
IS
--
   l_balance    NUMBER;
--
     cursor cur_PAYMENTS (assact_id  IN NUMBER,
                              baltype    IN NUMBER) is
--
   select
        nvl(sum(TARGET.result_value * FEED.scale),0)
   from
         pay_balance_feeds_f    FEED,
         pay_run_result_values  TARGET,
         pay_run_results        RR,
         pay_payroll_actions    PACT,
         pay_assignment_actions ASSACT,
         pay_action_interlocks  INTLK,
         pay_payroll_actions    BACT,
         pay_assignment_actions BAL_ASSACT
   where BAL_ASSACT.assignment_action_id = assact_id
   and   BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
   and   FEED.balance_type_id            = baltype
   and   FEED.input_value_id             = TARGET.input_value_id
   and   TARGET.run_result_id            = RR.run_result_id
   and   RR.assignment_action_id         = ASSACT.assignment_action_id
   and   ASSACT.payroll_action_id        = PACT.payroll_action_id
   and   PACT.effective_date between
         FEED.effective_start_date and FEED.effective_end_date
   and   RR.status in ('P','PA')
   and   ASSACT.assignment_action_id     = INTLK.locked_action_id
   and   INTLK.locking_action_id         = BAL_ASSACT.assignment_action_id
   and   BACT.action_type in ('P','U')
   and   PACT.action_type               <> 'V'   /* not reversals */
   and   ASSACT.assignment_id            = BAL_ASSACT.assignment_id
   and   not exists
      (select null
       from pay_payroll_actions    RPACT,
            pay_assignment_actions RASSACT,
            pay_action_interlocks  RINTLK
       where ASSACT.assignment_action_id = RINTLK.locked_action_id
       and   RINTLK.locking_action_id    = RASSACT.assignment_action_id
       and   RPACT.payroll_action_id     = RASSACT.payroll_action_id
       and   RPACT.action_type           = 'V');
--
BEGIN
--
     open cur_PAYMENTS(p_assignment_action_id, p_balance_type_id);
     FETCH cur_PAYMENTS INTO l_balance;
     close cur_PAYMENTS;
--
RETURN l_balance;
--
END PAYMENTS;
--
--------------------------------------------------------------------------------
--
END py_za_routes;

/
