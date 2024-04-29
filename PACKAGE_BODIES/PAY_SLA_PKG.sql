--------------------------------------------------------
--  DDL for Package Body PAY_SLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SLA_PKG" AS
/* $Header: pysla.pkb 120.13.12010000.2 2008/08/14 05:27:54 priupadh ship $ */
--
/*
 * ***************************************************************************
--
  Copyright (c) Oracle Corporation (UK) Ltd 1993,1994. All Rights Reserved.
--
  PRODUCT
    Oracle*Payroll
--
  NAME
    PAY_SLA_PKG  - Payroll support for SLA (Sub Ledger Accounting)
--
--
  DESCRIPTION
--
  MODIFIED          DD-MON-YYYY
  120.13.12000000.2  priupadh 14-Aug-2008 Bug 7283055
                                 Function get_conversion_type  Return CONVERSION_TYPE in
                                 place of USER_CONVERSION_TYPE
  120.13  A.Logue   18-Oct-2006  Handle un-specified payroll ids
                                 in Costing processes in delete_event.
  120.12  A.Logue   16-Oct-2006  Handle un-specified payroll ids
                                 in Costing processes.
  120.11  A.Logue   13-Oct-2006  Subtle change to
                                 ESITMATE_COST_REVERSAL event type
                                 code.
                                 Improved rule names to include
                                 segment names.
  120.10  A.Logue   05-Oct-2006  Use Chart of Account name in
                                 create_custom_adrs.
  120.9   A.Logue   04-Oct-2006  Added create_custom_adrs.
                                 Bug 5531729.
  120.8   A.Logue   04-Sep-2006  Added delete_event to support rollback
                                 of a Transfer to SLA (if events not
                                 completed).
                                 Also simplified Postprocessing.
                                 Bug 5510388.
  120.7   A.Logue   15-Aug-2006  Correct entity_type_code passed to
                                 XLA_EVENTS_PUB_PKG.create_event, and
                                 initialise event_status in pay_xla_events.
  120.6   A.Logue   15-Jun-2006  Fix GSCC error.
  120.5   A.Logue   25-May-2006  Mark payroll action as complete if
                                 all actions are complete in Postprocessing.
  120.4   A.Logue   25-Nov-2005  Added stub preaccounting, postaccounting
                                 and extract procedures for unused SLA hooks.
  120.3   A.Logue   22-Nov-2005  Postprocessing procedure.
  120.1   A.Logue   16-Nov-2005  Added various procedures and functions.
  115.0   A.Logue   07-Oct-2005	 Created.
--
  DESCRIPTION
    Payroll support for SLA (Sub Ledger Accounting)

    SLA is new in R12. This file exists to avoid breaking dual maintenance on
    TGL files between 11.5 and R12.

*/
--
-- Caches for get_conversion_type
--
g_business_group_id pay_payroll_actions.business_group_id%TYPE := null;
g_currency_type     gl_daily_rates.conversion_type%TYPE := null;
g_conversion_date   date := null;
--
-- Caches for get_accounting_date
--
g_revb_acc_date_mode pay_action_parameter_values.parameter_value%TYPE := null;
g_tgl_date_used pay_action_parameter_values.parameter_value%TYPE := null;
--
-- Caches for get_ecost_accounting_date
--
g_payroll_id      pay_all_payrolls_f.payroll_id%TYPE;
g_cost_date       date := null;
g_accounting_date date := null;
--
PROCEDURE trans_asg_costs
        (i_assignment_action_id NUMBER)
IS
--
-- Cursor to et distinct accounting dates for a Payment Cost action
--
CURSOR payment_account_dates (c_action_id NUMBER)
IS
SELECT DISTINCT accounting_date
FROM   pay_payment_costs
WHERE  assignment_action_id = c_action_id;
--
t_payroll_action_id        NUMBER;
c_assignment_action_id     NUMBER;
r_assignment_action_id     NUMBER;
c_payroll_action_id        NUMBER;
r_payroll_action_id        NUMBER;
r_action_type              pay_payroll_actions.action_type%TYPE;
r_assignment_id            NUMBER;
c_action_type              pay_payroll_actions.action_type%TYPE;
c_effective_date           DATE;
l_ledger_id                pay_all_payrolls_f.gl_set_of_books_id%TYPE;
l_accounting_date          DATE;
l_rev_accounting_date      DATE;
l_event_id                 NUMBER;
--
l_event_source_info        xla_events_pub_pkg.t_event_source_info;
l_security_context         xla_events_pub_pkg.t_security;
BEGIN
--
   hr_utility.set_location('pay_sla_pkg.trans_asg_costs',10);
--
   SELECT pa.payroll_action_id,
          pa1.assignment_id,
          pa1.assignment_action_id,
          ppa1.payroll_action_id,
          ppa1.action_type,
          ppa1.effective_date
   INTO   t_payroll_action_id,
          r_assignment_id,
          c_assignment_action_id,
          c_payroll_action_id,
          c_action_type,
          c_effective_date
   FROM   pay_assignment_actions   pa,  -- TGL assignment action
          pay_action_interlocks    pi,  -- interlock to cost
          pay_assignment_actions   pa1, -- cost assignment action
          pay_payroll_actions      ppa1 -- cost payroll action
   WHERE  pa.assignment_action_id  = i_assignment_action_id
   AND    pi.locking_action_id     = pa.assignment_action_id
   AND    pa1.assignment_action_id = pi.locked_action_id
   AND    ppa1.payroll_action_id   = pa1.payroll_action_id
   AND    ppa1.action_type         IN ('C', 'S', 'EC', 'CP');

   -- initialise xla structures
   l_event_source_info.application_id := 801;
   l_event_source_info.legal_entity_id := null;
   l_event_source_info.transaction_number := to_char(i_assignment_action_id);
   l_event_source_info.entity_type_code := 'ASSIGNMENTS';

   --
   -- Calls to XLA_EVENTS_PUB_PKG.create_event
   -- (or XLA_EVENTS_PUB_PKG.create_bulk_events)
   --

   if (c_action_type IN ('C', 'S')) then
      --
      -- Costing or Retrocosting : event class COSTS
      --
      hr_utility.set_location('pytrgl.trans_ass_costs',20);
      --
      SELECT pa2.assignment_action_id,
             ppa2.payroll_action_id,
             ppa2.action_type,
             pap.gl_set_of_books_id,
             pay_sla_pkg.get_accounting_date
                         (ppa2.action_type, c_effective_date,
                          ppa2.effective_date, ppa2.date_earned)
      INTO   r_assignment_action_id,
             r_payroll_action_id,
             r_action_type,
             l_ledger_id,
             l_accounting_date
      FROM   pay_assignment_actions   pa,  -- TGL assignment action
             pay_action_interlocks    pi2, -- interlock to run
             pay_assignment_actions   pa2, -- run assignment action
             pay_payroll_actions      ppa2,-- run payroll action
             pay_all_payrolls_f       pap
      WHERE  pa.assignment_action_id  = i_assignment_action_id
      AND    pi2.locking_action_id    = pa.assignment_action_id
      AND    pa2.assignment_action_id = pi2.locked_action_id
      AND    ppa2.payroll_action_id   = pa2.payroll_action_id
      AND    ppa2.action_type         NOT IN ('C', 'S', 'EC')
      AND    pap.payroll_id           = ppa2.payroll_id
      AND    ppa2.effective_date BETWEEN pap.effective_start_date
                                     AND pap.effective_end_date;

      l_event_source_info.ledger_id := l_ledger_id;

      if (c_action_type = 'C') then
         --
         -- Raise COST event type event
         -- on tid i_assignment_action_id, date l_accounting_date
         --

         l_event_source_info.source_id_int_1  := i_assignment_action_id;
         --l_event_source_info.source_id_date_1 := l_accounting_date;
         l_event_source_info.source_id_char_1 := to_char(l_accounting_date, 'YYYY/MM/DD');

         l_event_id := XLA_EVENTS_PUB_PKG.create_event (
                            p_event_source_info => l_event_source_info,
                            p_event_type_code   => 'COST',
                            p_event_date        => l_accounting_date,
                            p_event_status_code => 'U',
                            p_valuation_method  => null,
                            p_security_context  => l_security_context
                       );
         --
         -- create entry in pay_xla_events
         --
         insert into pay_xla_events (assignment_action_id, event_id,
                                     accounting_date, event_status)
         values (i_assignment_action_id, l_event_id, l_accounting_date, 'U');
         --
      else
         --
         -- Raise RETRO_COST event type event
         -- on tid i_assignment_action_id, date l_accounting_date
         --

         l_event_source_info.source_id_int_1  := i_assignment_action_id;
         --l_event_source_info.source_id_date_1 := l_accounting_date;
         l_event_source_info.source_id_char_1 := to_char(l_accounting_date, 'YYYY/MM/DD');

         l_event_id := XLA_EVENTS_PUB_PKG.create_event (
                            p_event_source_info => l_event_source_info,
                            p_event_type_code   => 'RETRO_COST',
                            p_event_date        => l_accounting_date,
                            p_event_status_code => 'U',
                            p_valuation_method  => null,
                            p_security_context  => l_security_context
                       );

         --
         -- create entry in pay_xla_events
         --
         insert into pay_xla_events (assignment_action_id, event_id,
                                     accounting_date, event_status)
         values (i_assignment_action_id, l_event_id, l_accounting_date, 'U');
         --
      end if;

   elsif (c_action_type = 'EC') then
      --
      -- Estimate Costing : event class ESTIMATE_COSTS
      --
      hr_utility.set_location('pytrgl.trans_ass_costs',30);
      --
      SELECT pay_sla_pkg.get_ecost_accounting_date
                         (pera.payroll_id, c_effective_date),
             pap.gl_set_of_books_id
      INTO   l_rev_accounting_date,
             l_ledger_id
      FROM   per_all_assignments_f   pera,
             pay_all_payrolls_f      pap
      WHERE  pera.assignment_id    = r_assignment_id
      AND    c_effective_date BETWEEN pera.effective_start_date
                                  AND pera.effective_end_date
      AND    pap.payroll_id        = pera.payroll_id
      AND    c_effective_date BETWEEN pap.effective_start_date
                                  AND pap.effective_end_date;

      l_event_source_info.ledger_id := l_ledger_id;

      --
      -- Raise ESTIMATE_COST event type event
      -- on tid i_assignment_action_id, date c_effective_date
      --

      l_event_source_info.source_id_int_1  := i_assignment_action_id;
      --l_event_source_info.source_id_date_1 := c_effective_date;
      l_event_source_info.source_id_char_1 := to_char(c_effective_date, 'YYYY/MM/DD');

      l_event_id := XLA_EVENTS_PUB_PKG.create_event (
                            p_event_source_info => l_event_source_info,
                            p_event_type_code   => 'ESTIMATE_COST',
                            p_event_date        => c_effective_date,
                            p_event_status_code => 'U',
                            p_valuation_method  => null,
                            p_security_context  => l_security_context
                    );

      --
      -- create entry in pay_xla_events
      --
      insert into pay_xla_events (assignment_action_id, event_id,
                                  accounting_date, event_status)
      values (i_assignment_action_id, l_event_id, c_effective_date, 'U');
      --
      -- Raise ESTIMATE_COST_REVERSAL event type event
      -- on tid i_assignment_action_id, date l_rev_accounting_date
      --

      l_event_source_info.source_id_int_1  := i_assignment_action_id;
      --l_event_source_info.source_id_date_1 := l_rev_accounting_date;
      l_event_source_info.source_id_char_1 := to_char(l_rev_accounting_date,
                                                      'YYYY/MM/DD');

      l_event_id := XLA_EVENTS_PUB_PKG.create_event (
                            p_event_source_info => l_event_source_info,
                            p_event_type_code   => 'ESITMATE_COST_REVERSAL',
                            p_event_date        => l_rev_accounting_date,
                            p_event_status_code => 'U',
                            p_valuation_method  => null,
                            p_security_context  => l_security_context
                    );

      --
      --
      -- create entry in pay_xla_events
      --
      insert into pay_xla_events (assignment_action_id, event_id,
                                  accounting_date, event_status)
      values (i_assignment_action_id, l_event_id, l_rev_accounting_date, 'U');
      --
   else
      --
      -- Payment Costs
      --
      -- create distinct ones for each different date for payment costs
      --

      SELECT pap.gl_set_of_books_id
      INTO   l_ledger_id
      FROM   per_all_assignments_f   pera,
             pay_all_payrolls_f      pap
      WHERE  pera.assignment_id    = r_assignment_id
      AND    c_effective_date BETWEEN pera.effective_start_date
                                  AND pera.effective_end_date
      AND    pap.payroll_id        = pera.payroll_id
      AND    c_effective_date BETWEEN pap.effective_start_date
                                  AND pap.effective_end_date;

      l_event_source_info.ledger_id := l_ledger_id;
      l_event_source_info.source_id_int_1  := i_assignment_action_id;

      for account_date in payment_account_dates (c_assignment_action_id) loop

         --
         -- Raise PAYMENT_COST event type event
         -- on tid i_assignment_action_id, date account_date.accouting_date
         --

         --l_event_source_info.source_id_date_1 := account_date.accounting_date;
         l_event_source_info.source_id_char_1 :=
                            to_char(account_date.accounting_date, 'YYYY/MM/DD');

         l_event_id := XLA_EVENTS_PUB_PKG.create_event (
                            p_event_source_info => l_event_source_info,
                            p_event_type_code   => 'PAYMENT_COST',
                            p_event_date        => account_date.accounting_date,
                            p_event_status_code => 'U',
                            p_valuation_method  => null,
                            p_security_context  => l_security_context
                    );

         --
         -- create entry in pay_xla_events (assignment_action_id, event_id, date)
         --
         insert into pay_xla_events (assignment_action_id, event_id,
                                     accounting_date, event_status)
         values (i_assignment_action_id, l_event_id, account_date.accounting_date, 'U');

      end loop;

   end if;
--
END trans_asg_costs;
--
PROCEDURE postprocessing
        (p_application_id  NUMBER,
         p_accounting_mode VARCHAR2)
IS

  CURSOR xla_events_cur IS
  SELECT XPAE.event_id event_id,
         XPAE.event_type_code event_type_code,
         XPAE.SOURCE_ID_INT_1 event_aa_id,
         XPAE.ledger_id ledger_id
  FROM   XLA_POST_ACCTG_EVENTS_V XPAE,
         GL_SETS_OF_BOOKS GSOB,
         PAY_XLA_EVENTS PAYE
  WHERE XPAE.ledger_id = GSOB.set_of_books_id
    AND PAYE.event_id = XPAE.event_id
    AND PAYE.event_status <> 'C';

BEGIN
--
   hr_utility.set_location('pay_sla_pkg.post_process_event',10);
--
   IF (p_application_id <> 801) THEN
      RETURN;
   END IF;
--
   --
   -- If not in Final Mode do nothing (eg Draft)
   --
   IF (p_accounting_mode <> 'F') THEN
      RETURN;
   END IF;
--
   for xlarec in xla_events_cur loop
--
      hr_utility.set_location('pay_sla_pkg.post_process_event',10);
--
      --
      -- Mark the Events as complete
      --
      UPDATE pay_xla_events
      SET event_status = 'C'
      WHERE event_id = xlarec.event_id;
--
   end loop;
--
END postprocessing;
--
FUNCTION get_conversion_type
        (i_business_group_id NUMBER,
         i_conversion_date   DATE)
RETURN VARCHAR2 IS

CURSOR get_conv_type(p_user_currency_type gl_daily_conversion_types.user_conversion_type%type) IS
SELECT  conversion_type
FROM  gl_daily_conversion_types gdct
WHERE  gdct.user_conversion_type = p_user_currency_type;

   l_user_currency_type VARCHAR2(30);
   l_currency_type VARCHAR2(30);
BEGIN
--
   hr_utility.set_location('Entering pay_sla_pkg.get_conversion_type',10);
--
   if (g_business_group_id is not null) and
      (i_business_group_id = g_business_group_id) and
      (i_conversion_date   = g_conversion_date) then
   --
      l_currency_type := g_currency_type;
   --
   else
   --
      l_user_currency_type := hruserdt.get_table_value(i_business_group_id,
                           'EXCHANGE_RATE_TYPES', 'Conversion Rate Type',
                           'PAY',i_conversion_date);

   hr_utility.set_location('In pay_sla_pkg.get_conversion_type l_user_currency_type '||l_user_currency_type,15);
/*Begin Bug 7283055 USER_CONVERSION_TYPE was getting returned need to return Conversion Type */
      open get_conv_type(l_user_currency_type);
      fetch get_conv_type into l_currency_type;
      close get_conv_type;

      g_currency_type := l_currency_type;
      g_business_group_id := i_business_group_id;
      g_conversion_date := i_conversion_date;
   --
   end if;
   hr_utility.set_location('In pay_sla_pkg.get_conversion_type l_currency_type '||l_currency_type,20);
   hr_utility.set_location('In pay_sla_pkg.get_conversion_type g_currency_type '||g_currency_type,30);
   hr_utility.set_location('Leaving pay_sla_pkg.get_conversion_type',40);
--
   return(l_currency_type);
--
END get_conversion_type;
--
FUNCTION get_accounting_date
         (run_action_type     VARCHAR2,
          cost_effective_date DATE,
          run_effective_date  DATE,
          run_date_earned     DATE)
RETURN DATE IS
   l_accounting_date DATE;
BEGIN
--
   hr_utility.set_location('pay_sla_pkg.get_accounting_date',10);
--
   if (run_action_type in ('B', 'V')) then
      --
      -- For Reversals and Balance Adjustments
      -- eff date of cost if TGL_REVB_ACC_DATE = 'E'
      -- otherwise eff date of rev/ba
      if (g_revb_acc_date_mode is null) then
         begin
            select parameter_value
              into g_revb_acc_date_mode
              from pay_action_parameters
             where parameter_name = 'TGL_REVB_ACC_DATE';
          exception
            when others then
               g_revb_acc_date_mode := 'P';
          end;
      end if;

      if g_revb_acc_date_mode = 'C' then
          l_accounting_date := cost_effective_date;
      else
          l_accounting_date := run_effective_date;
      end if;
--
   else
      --
      -- For Runs and Quickpays
      -- run date earned if TGL_DATE_USED = 'E'
      -- otherwise eff date of run
      --
      if (g_tgl_date_used is null) then
         begin
            select parameter_value
              into g_tgl_date_used
              from pay_action_parameters
             where parameter_name = 'TGL_DATE_USED';
          exception
            when others then
               g_tgl_date_used := 'P';
          end;
      end if;

      if g_tgl_date_used = 'E' then
          l_accounting_date := run_date_earned;
      else
          l_accounting_date := run_effective_date;
      end if;
   end if;
--
   return(l_accounting_date);
--
END get_accounting_date;
--
FUNCTION get_ecost_accounting_date
         (ecost_payroll_id    NUMBER,
          cost_effective_date DATE)
RETURN DATE IS
   l_accounting_date DATE;
BEGIN
--
   hr_utility.set_location('pay_sla_pkg.get_ecost_accounting_date',10);
--
   --
   -- For Estimate Costs
   -- negation deltas at end of payroll period only
   -- ecost period end date of TGL_DATE_USED = 'E' or = 'EVE'
   -- otherwise period pay_advice_date + payroll pay_date_offset(!)
   --
   if (g_payroll_id is not null) and
      (ecost_payroll_id = g_payroll_id) and
      (cost_effective_date = g_cost_date) then
      l_accounting_date := g_accounting_date;
   else
--
      if (g_tgl_date_used is null) then
         begin
            select parameter_value
              into g_tgl_date_used
              from pay_action_parameters
             where parameter_name = 'TGL_DATE_USED';
         exception
            when others then
               g_tgl_date_used := 'P';
         end;
      end if;

      SELECT /*+ ORDERED */
             decode(g_tgl_date_used, 'E', ptp.end_date,
                                   'EVE', ptp.end_date,
                    ptp.pay_advice_date + pay.pay_date_offset)
      INTO   l_accounting_date
      FROM   pay_all_payrolls_f      pay,
             per_time_periods        ptp
      WHERE  pay.payroll_id        = ecost_payroll_id
      AND    cost_effective_date BETWEEN pay.effective_start_date
                                     AND pay.effective_end_date
      AND    ptp.payroll_id        = pay.payroll_id
      AND    cost_effective_date BETWEEN ptp.start_date
                                     AND ptp.end_date;

      g_payroll_id := ecost_payroll_id;
      g_cost_date := cost_effective_date;
      g_accounting_date := l_accounting_date;
--
   end if;
--
   return(l_accounting_date);
--
END get_ecost_accounting_date;
--
-- Stub for XLA preaccounting hook
--
PROCEDURE preaccounting
        (p_application_id     NUMBER,
         p_ledger_id          NUMBER,
         p_process_category   VARCHAR2,
         p_end_date           DATE,
         p_accounting_mode    VARCHAR2,
         p_valuation_method   VARCHAR2,
         p_security_id_int_1  NUMBER,
         p_security_id_int_2  NUMBER,
         p_security_id_int_3  NUMBER,
         p_security_id_char_1 VARCHAR2,
         p_security_id_char_2 VARCHAR2,
         p_security_id_char_3 VARCHAR2,
         p_report_request_id  NUMBER)
IS
BEGIN
--
   hr_utility.set_location('pay_sla_pkg.preaccounting',10);
--
END preaccounting;
--
-- Stub for XLA postaccounting hook
--
PROCEDURE postaccounting
        (p_application_id     NUMBER,
         p_ledger_id          NUMBER,
         p_process_category   VARCHAR2,
         p_end_date           DATE,
         p_accounting_mode    VARCHAR2,
         p_valuation_method   VARCHAR2,
         p_security_id_int_1  NUMBER,
         p_security_id_int_2  NUMBER,
         p_security_id_int_3  NUMBER,
         p_security_id_char_1 VARCHAR2,
         p_security_id_char_2 VARCHAR2,
         p_security_id_char_3 VARCHAR2,
         p_report_request_id  NUMBER)
IS
BEGIN
--
   hr_utility.set_location('pay_sla_pkg.postaccounting',10);
--
END postaccounting;
--
--
-- Stub for XLA extract hook
--
PROCEDURE extract
        (p_application_id     NUMBER,
         p_accounting_mode    VARCHAR2)
IS
BEGIN
--
   hr_utility.set_location('pay_sla_pkg.extract',10);
--
END extract;
--
-- Delet_event : called form rollback code
--
PROCEDURE delete_event
        (i_assignment_action_id NUMBER)
IS
  CURSOR xla_events_cur IS
  SELECT PAYE.event_id event_id,
         PAYE.accounting_date
  FROM   PAY_XLA_EVENTS PAYE
  WHERE PAYE.assignment_action_id = i_assignment_action_id;

  l_completed_events number;
  l_ledger_id                pay_all_payrolls_f.gl_set_of_books_id%TYPE;
  l_event_source_info        xla_events_pub_pkg.t_event_source_info;
  l_security_context         xla_events_pub_pkg.t_security;

BEGIN
--
   hr_utility.set_location('pay_sla_pkg.delete_event',10);
   --
   -- Confirm no Completed events for this action
   --
   SELECT count(*)
   INTO l_completed_events
   FROM  pay_xla_events
   WHERE assignment_action_id = i_assignment_action_id
   AND   event_status = 'C';

   IF l_completed_events <> 0 THEN

      --
      -- SLA has processed the event and passed to GL
      --
      hr_utility.set_message (801, 'HR_7507_ACTION_UNDO_INTLOCK');
      hr_utility.raise_error;

   ELSE

      SELECT pap.gl_set_of_books_id
      INTO   l_ledger_id
      FROM   pay_assignment_actions   pa,  -- TGL assignment action
             pay_action_interlocks    pi,  -- interlock to cost
             pay_assignment_actions   pa1, -- cost assignment action
             pay_payroll_actions      ppa1,-- cost payroll action
             pay_all_payrolls_f       pap
      WHERE  pa.assignment_action_id  = i_assignment_action_id
      AND    pi.locking_action_id     = pa.assignment_action_id
      AND    pa1.assignment_action_id = pi.locked_action_id
      AND    ppa1.payroll_action_id   = pa1.payroll_action_id
      AND    ppa1.action_type         IN ('C', 'S', 'EC', 'CP')
      AND    ppa1.payroll_id          = pap.payroll_id (+)
      AND    ppa1.effective_date BETWEEN pap.effective_start_date (+)
                                     AND pap.effective_end_date   (+);

      IF l_ledger_id is null then

         SELECT pap.gl_set_of_books_id
         INTO   l_ledger_id
         FROM   pay_assignment_actions   pa,  -- TGL assignment action
                pay_action_interlocks    pi,  -- interlock to run
                pay_assignment_actions   pa1, -- run assignment action
                pay_payroll_actions      ppa1,-- run payroll action
                pay_all_payrolls_f       pap
         WHERE  pa.assignment_action_id  = i_assignment_action_id
         AND    pi.locking_action_id     = pa.assignment_action_id
         AND    pa1.assignment_action_id = pi.locked_action_id
         AND    ppa1.payroll_action_id   = pa1.payroll_action_id
         AND    ppa1.action_type         IN ('R', 'Q', 'V', 'B')
         AND    ppa1.payroll_id          = pap.payroll_id
         AND    ppa1.effective_date BETWEEN pap.effective_start_date
                                        AND pap.effective_end_date;

      END IF;

      -- initialise xla structures
      l_event_source_info.application_id := 801;
      l_event_source_info.legal_entity_id := null;
      l_event_source_info.ledger_id := l_ledger_id;
      l_event_source_info.transaction_number := to_char(i_assignment_action_id);
      l_event_source_info.entity_type_code := 'ASSIGNMENTS';
      l_event_source_info.source_id_int_1  := i_assignment_action_id;

      for xlarec in xla_events_cur loop

         l_event_source_info.source_id_char_1 := to_char(xlarec.accounting_date,
                                                         'YYYY/MM/DD');

         -- delete the event in SLA
         XLA_EVENTS_PUB_PKG.delete_event (
                            p_event_source_info => l_event_source_info,
                            p_event_id          => xlarec.event_id,
                            p_valuation_method  => null,
                            p_security_context  => l_security_context
         );

      end loop;

      -- delete the event from pay_xla_events
      DELETE from pay_xla_events
      WHERE assignment_action_id = i_assignment_action_id;

   END IF;
--
END delete_event;
--
-- Procedure to create custom ADRs based on their existing PAY-GL flex map
-- Creates a rule (in xla_rules_t) per Chart of Accounts Segment
-- Creates a rule detail (in xla_rule_details_t) for each Payroll Segment
--   mapped to this COA Segment
-- Creats 1 condition (in xla_conditions_t) for each rule detail
--   specifying the Payroll name
--
PROCEDURE create_custom_adrs
IS
 --
 -- cursor to get mapping info
 --
 CURSOR segmaps IS
 SELECT fm.payroll_id, fm.gl_set_of_books_id, gl.chart_of_accounts_id,
        fm.gl_account_segment, fm.payroll_cost_segment,
        fs.id_flex_structure_name coa_name,
        fseg.segment_name coa_seg_name
   FROM pay_payroll_gl_flex_maps fm,
        gl_sets_of_books gl,
        fnd_id_flex_structures_vl fs,
        fnd_id_flex_segments_vl fseg
  WHERE fm.gl_set_of_books_id = gl.set_of_books_id
    AND fs.application_id = 101
    AND fs.id_flex_code = 'GL#'
    AND fs.id_flex_num = gl.chart_of_accounts_id
    AND fseg.application_id = 101
    AND fseg.id_flex_code = 'GL#'
    AND fseg.id_flex_num = gl.chart_of_accounts_id
    AND fseg.application_column_name = fm.gl_account_segment
  ORDER BY gl.chart_of_accounts_id, fm.gl_account_segment;
 --
  l_segment_rule_code xla_rules_t.segment_rule_code%type;
  l_coa_id            xla_rules_t.accounting_coa_id%type;
  l_acc_segment       xla_rules_t.flexfield_segment_code%type;
  l_pay_segment       xla_rules_t.flexfield_segment_code%type;
  l_prev_payroll_id   pay_all_payrolls_f.payroll_id%type := -1;
  l_payroll_name      pay_all_payrolls_f.payroll_name%type;
  l_rule_det_seq      xla_rule_details_t.user_sequence%type;
 --
BEGIN
--
   hr_utility.set_location('pay_sla_pkg.create_custom_adrs',10);
--
    for segmap in segmaps loop

       l_acc_segment := segmap.gl_account_segment;
       l_pay_segment := segmap.payroll_cost_segment;
       l_coa_id := segmap.chart_of_accounts_id;

       l_segment_rule_code := l_acc_segment||'_'||l_coa_id;

       if (segmap.payroll_id <> l_prev_payroll_id) then
          select payroll_name
          into   l_payroll_name
          from   pay_all_payrolls_f
          where  payroll_id = segmap.payroll_id
          and    rownum < 2;

          l_prev_payroll_id := segmap.payroll_id;
       end if;

       -- Create the rule if it doesn't exist

       insert into xla_rules_t (
            application_id,
            amb_context_code,
            segment_rule_type_code,
            segment_rule_code,
            accounting_coa_id,
            flexfield_assign_mode_code,
            flexfield_segment_code,
            enabled_flag,
            name,
            description,
            error_value)
       select
            801,
            'DEFAULT',
            'S',
            l_segment_rule_code,
            l_coa_id,
            'S',
            l_acc_segment,
            'Y',
            'Rule for '||segmap.coa_seg_name|| ' in '||segmap.coa_name,
            'Rule for '||segmap.coa_seg_name|| ' in '||segmap.coa_name,
            0
       from dual
       where not exists
            (select 1
             from xla_rules_t
             where application_id = 801
             and   segment_rule_code = l_segment_rule_code);


       -- Create the rule detail if it doesn't exist

       select count(*)
       into   l_rule_det_seq
       from  xla_rule_details_t
       where application_id = 801
       and   segment_rule_code = l_segment_rule_code;

       insert into xla_rule_details_t (
            application_id,
            amb_context_code,
            segment_rule_type_code,
            segment_rule_code,
            segment_rule_detail_id,
            user_sequence,
            value_type_code,
            value_source_application_id,
            value_source_type_code,
            value_source_code,
            error_value
            )
       select
            801,
            'DEFAULT',
            'S',
            l_segment_rule_code,
            xla_seg_rule_details_s.nextval,
            l_rule_det_seq + 1,
            'S',
            801,
            'S',
            l_pay_segment,
            0
       from dual
       where not exists
            (select 1
             from xla_rule_details_t xrd,
                  xla_conditions_t xc
             where xrd.application_id = 801
             and   xrd.segment_rule_code = l_segment_rule_code
             and   xrd.value_source_code = l_pay_segment
             and   xc.segment_rule_detail_id = xrd.segment_rule_detail_id
             and   xc.value_constant = l_payroll_name);

       -- create the condition if a rule detail was created

       if SQL%ROWCOUNT > 0 then

          insert into xla_conditions_t (
               condition_id,
               application_id,
               amb_context_code,
               segment_rule_detail_id,
               user_sequence,
               value_type_code,
               source_application_id,
               source_type_code,
               source_code,
               line_operator_code,
               value_constant,
               error_value)
          select
               xla_conditions_s.nextval,
               801,
               'DEFAULT',
               xla_seg_rule_details_s.currval,
               1,
               'C',
               801,
               'S',
               'PAYROLL_NAME',
               'E',
               l_payroll_name,
               0
          from dual
          where not exists
               (select 1
                from xla_rule_details_t xrd,
                     xla_conditions_t xc
                where xrd.application_id = 801
                and   xrd.segment_rule_code = l_segment_rule_code
                and   xrd.value_source_code = l_pay_segment
                and   xc.segment_rule_detail_id = xrd.segment_rule_detail_id
                and   xc.value_constant = l_payroll_name);
       end if;

    end loop;

    --
    -- Call XLA API To transfer data
    --
    xla_adr_interface_pkg.upload_rules;
--
END create_custom_adrs;
--
END pay_sla_pkg;

/
