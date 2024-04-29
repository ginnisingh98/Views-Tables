--------------------------------------------------------
--  DDL for Package Body PAY_CONSUMED_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CONSUMED_ENTRY" as
/* $Header: pyconsum.pkb 120.2.12010000.1 2008/07/27 22:22:34 appldev ship $ */
--
--
FUNCTION consumed_entry (	p_date_earned	IN DATE,
				p_payroll_id	IN NUMBER,
				p_ele_entry_id	IN NUMBER) RETURN VARCHAR2 IS
--
-- Checks for "consumed" element entry (context) in skip rule for earnings
-- and deductions.  Payroll Action's DATE_EARNED must be between the
-- EARNED period dates.  Have PAY_EARNED_PERIOD_START_DATE and
-- PAY_EARNED_PERIOD_END_DATE been requested from core?!?  For now we'll
-- derive these period dates in the UDF based on the "date earned" context.
--
v_consumed	VARCHAR2(1)	:= 'N';
v_reversed	VARCHAR2(1)	:= 'N';
l_period_start	DATE;
l_period_end	DATE;
g_debug boolean := hr_utility.debug_enabled;
--
BEGIN
--
if g_debug then
   hr_utility.set_location('consumed_entry', 10);
end if;
--
-- Find EARNED period dates
--
SELECT  start_date,
	end_date
INTO	l_period_start,
	l_period_end
FROM	per_time_periods
WHERE	payroll_id 					= p_payroll_id
AND	p_date_earned BETWEEN start_date AND end_date;
--
if g_debug then
   hr_utility.set_location('consumed_entry', 20);
end if;
--
SELECT	/*+ INDEX(PPA PAY_PAYROLL_ACTIONS_PK)*/
        DECODE(COUNT(PRR.run_result_id), 0, 'N', 'Y')
INTO	v_consumed
FROM	pay_run_results		PRR,
	pay_assignment_actions	ASA,
	pay_payroll_actions	PPA
WHERE	PRR.source_id			= p_ele_entry_id
AND	PRR.source_type		IN ('E', 'I')
AND     PRR.status		in ('P', 'PA', 'R', 'O')
AND	ASA.assignment_action_id	= PRR.assignment_action_id
AND	PPA.payroll_action_id		= ASA.payroll_action_id
--
-- Check whether the run_result has been revered.
AND     not exists (select null
                    from pay_run_results prr2
                    where prr2.source_id = PRR.run_result_id
                      and prr2.source_type in ('R', 'V'))
AND	PPA.date_earned		BETWEEN l_period_start
				AND	l_period_end;
--
if g_debug then
   hr_utility.set_location('consumed_entry', 39);
end if;

RETURN v_consumed;

exception when NO_DATA_FOUND then
  if g_debug then
     hr_utility.set_location('consumed_entry', 40);
  end if;
  RETURN v_consumed;
--
END consumed_entry;

end pay_consumed_entry;

/
