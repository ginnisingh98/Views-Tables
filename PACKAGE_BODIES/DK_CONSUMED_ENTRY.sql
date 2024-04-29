--------------------------------------------------------
--  DDL for Package Body DK_CONSUMED_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DK_CONSUMED_ENTRY" as
 /* $Header: pydkconsum.pkb 120.0.12010000.2 2009/10/28 12:19:15 knadhan noship $ */


FUNCTION consumed_entry_spl (	p_date_earned	IN DATE,
				p_payroll_id	IN NUMBER,
				p_asg_id	IN NUMBER) RETURN VARCHAR2 IS

v_consumed	VARCHAR2(1)	:= 'N';
v_reversed	VARCHAR2(1)	:= 'N';
l_period_start	DATE;
l_period_end	DATE;
g_debug boolean := hr_utility.debug_enabled;
--
BEGIN
--
if g_debug then
   hr_utility.set_location('consumed_entry spl', 10);
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
   hr_utility.set_location('consumed_entry spl', 20);
end if;
--
SELECT	DECODE(COUNT(PRR.run_result_id), 0, 'N', 'Y')
INTO	v_consumed
FROM	pay_run_results		PRR,
	pay_assignment_actions	ASA,
	pay_payroll_actions	PPA
WHERE
ASA.assignment_id			= p_asg_id
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
   hr_utility.set_location('consumed_entry spl', 39);
end if;

RETURN v_consumed;

exception when NO_DATA_FOUND then
  if g_debug then
     hr_utility.set_location('consumed_entry spl', 40);
  end if;
  RETURN v_consumed;
--
END consumed_entry_spl;

FUNCTION consumed_entry_indirect (	p_date_earned	IN DATE,
				p_payroll_id	IN NUMBER,
				p_ele_entry_id	IN NUMBER
				) RETURN VARCHAR2 IS

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
/*
SELECT	DECODE(COUNT(PRR.run_result_id), 0, 'N', 'Y')
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
*/
select DECODE(COUNT(PRR.run_result_id), 0, 'N', 'Y')
INTO	v_consumed
FROM	pay_run_results		PRR,
	pay_assignment_actions	ASA,
	pay_payroll_actions	PPA,
 pay_run_result_values PRVV
,pay_input_values_f PIVF
,pay_element_types_f PET
WHERE	PRR.source_id			= p_ele_entry_id
AND	PRR.source_type		IN ('E', 'I')
AND     PRR.status		in ('P', 'PA', 'R', 'O')
AND PRR.run_result_id=PRVV.run_result_id
AND	ASA.assignment_action_id	= PRR.assignment_action_id
AND	PPA.payroll_action_id		= ASA.payroll_action_id
AND pivf.name in ('Termination Accrual Days','Termination Next Entit Days',
                  'Termination Curr Entit Days','Termination Accrual Amount',
		  'Termination Next Entit Pay','Termination Curr Entit Pay')
AND pivf.input_Value_id=prvv.input_value_id
AND pivf.element_type_id=PRR.element_type_id
AND PET.element_name='Holiday Bank Information'
AND PET.element_type_id=PIVF.element_type_id
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
END consumed_entry_indirect;

END DK_CONSUMED_ENTRY;

/
