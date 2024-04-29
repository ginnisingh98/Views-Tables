--------------------------------------------------------
--  DDL for Package Body PAY_JP_GET_MONTH_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_GET_MONTH_BALANCE_PKG" as
/* $Header: pyjpgmbl.pkb 115.1 99/10/08 06:54:33 porting ship $ */
----------------------------------------------------------------------------------
--                                                                              --
--                          GET_MONTH_BALANCE                                   --
-- sum run results for a given balance for a calendar month
-- parameters:  business_group_id	Formula context
--		assignment_id	Formula context
--		balance name	parameter to select balance feedS
--		months_prior    how many months to go back
--                                                                              --
----------------------------------------------------------------------------------
	FUNCTION get_month_balance(
		p_business_group_id	NUMBER,
		p_assignment_id		NUMBER,
		p_balance_name		VARCHAR2,
		p_months_prior		NUMBER)
	RETURN NUMBER IS
		l_effective_date date;
		l_balance_type_id number;
		l_end_month_date date;
		l_start_month_date date;
		l_balance number;
	BEGIN
		select balance_type_id
		into	l_balance_type_id
		from	pay_balance_types
		where	balance_name = p_balance_name
		and	((business_group_id is null and legislation_code = 'JP')
			or business_group_id = p_business_group_id);

		select	effective_date,
			add_months(last_day(effective_date),(-1 * abs(p_months_prior))),
			add_months(last_day(effective_date), (-1 + (-1 * abs(p_months_prior)))) + 1
        	into	l_effective_date,
			l_end_month_date,
			l_start_month_date
		from	fnd_sessions
		where	session_id = userenv('sessionid');

		BEGIN
			SELECT	NVL(SUM(TARGET.result_value * FEED.scale),0)
			INTO	l_balance
			FROM
				pay_run_result_values	TARGET,
				pay_balance_feeds_f	FEED,
				pay_run_results		RR,
				pay_payroll_actions	PACT,
				pay_assignment_actions	ASSACT
			WHERE	ASSACT.assignment_id = p_assignment_id
			AND	ASSACT.payroll_action_id = PACT.payroll_action_id
			AND	PACT.effective_date
				between l_start_month_date and l_end_month_date
			AND	RR.assignment_action_id = ASSACT.assignment_action_id
			AND	RR.status IN ('P','PA')
			AND	FEED.balance_type_id = l_balance_type_id
			AND	PACT.effective_date
				between FEED.effective_start_date and FEED.effective_end_date
			AND	TARGET.run_result_id = RR.run_result_id
			AND	TARGET.input_value_id = FEED.input_value_id
			AND	NVL(TARGET.result_value,'0') <> '0';
		END;

		RETURN l_balance;
	end get_month_balance;
----------------------------------------------------------------------------------
--                                                                              --
--                          GET_MONTH_ADJUSTMENTS
-- sum run results for a given balance for a calendar month where the results
-- belong to either adjustment or reversal actions.
--
-- parameters:  business_group_id	Formula context
--		assignment_id	Formula context
--		balance name	parameter to select balance feedS
--		months_prior    how many months to go back
--                                                                              --
----------------------------------------------------------------------------------
	FUNCTION get_month_adjustments(
		p_business_group_id	NUMBER,
		p_assignment_id		NUMBER,
		p_balance_name		VARCHAR2,
		p_months_prior		NUMBER)
	RETURN NUMBER IS
		l_effective_date	DATE;
		l_balance_type_id	NUMBER;
		l_end_month_date	DATE;
		l_start_month_date	DATE;
		l_balance		NUMBER;
	BEGIN
		select	balance_type_id
		into	l_balance_type_id
		from	pay_balance_types
		where	balance_name = P_BALANCE_NAME
		and	((business_group_id is null and legislation_code = 'JP')
			or business_group_id = p_business_group_id);

		select	effective_date,
			add_months(last_day(effective_date),(-1 * abs(p_months_prior))),
			add_months(last_day(effective_date), (-1 + (-1 * abs(p_months_prior)))) + 1
		into	l_effective_date,
			l_end_month_date,
			l_start_month_date
		from	fnd_sessions
		where	session_id = userenv('sessionid');

		BEGIN
			SELECT	NVL(SUM(TARGET.result_value * FEED.scale),0)
			INTO	l_balance
			FROM	pay_run_result_values	TARGET,
				pay_balance_feeds_f	FEED,
				pay_run_results		RR,
				pay_payroll_actions	PACT,
				pay_assignment_actions	ASSACT
			WHERE	ASSACT.assignment_id = p_assignment_id
			AND	ASSACT.payroll_action_id = PACT.payroll_action_id
			AND	PACT.action_type IN ('B','V')
			AND	PACT.effective_date
				between l_start_month_date and l_end_month_date
			AND	RR.assignment_action_id = ASSACT.assignment_action_id
			AND	RR.status IN ('P','PA')
			AND	FEED.balance_type_id = l_balance_type_id
			AND	PACT.effective_date
				between FEED.effective_start_date and FEED.effective_end_date
			AND	TARGET.run_result_id = RR.run_result_id
			AND	TARGET.input_value_id = FEED.input_value_id
			AND	NVL(TARGET.result_value,'0') <> '0';
		END;

		RETURN l_balance;
	END get_month_adjustments;
END pay_jp_get_month_balance_pkg;

/
