--------------------------------------------------------
--  DDL for Package Body HR_JPDRB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JPDRB" AS
/* $Header: pyjpdrb.pkb 115.7 2004/05/14 02:49:35 keyazawa ship $ */
/* ------------------------------------------------------------------------------------ */
--
/* ------------------------------------------------------------------------------------
--
--	FUNCTION get_balance
--
-- ------------------------------------------------------------------------------------ */
/* -- find out whether the balance exists in the latest balances table,
-- using get_latest_balance.
-- Check expiry of the balance if assignment action lower , using functionality
-- of expiry chk from pyjpbal.
-- If we do need the route code, the balance type id and dimension is going to have
-- to be known. Then, hr_jprte and hr_routes can be called accordingly. This can be acheived
-- using a get_route function (here) that performs necessary calculation
-- Person level balances -  calls hr_jpbal, as there is a lot of calculation before hitting route. */
--
/* ------------------------------------------------------------------------------------
--
--			FUNCTION get_balance
-- 				Date Mode
--
-- The theory behind this is that we can check whether the balance has
-- expired before getting it, due to the fact that we navigate back to the
-- last assignment action and use the effective (session) date passed in
-- as criteria for expiry checking
--
-- ------------------------------------------------------------------------------------ */
FUNCTION get_balance (p_assignment_id		IN NUMBER,
		      p_defined_balance_id	IN NUMBER,
		      p_effective_date		IN DATE)
RETURN NUMBER IS
--
	l_assignment_action_id		NUMBER;
	l_dimension_jp_type		VARCHAR2(15);
	l_balance			NUMBER;
	l_expired			BOOLEAN;
--
/* -- This gets the most recent assignment action of seq generating type, using
-- the effective date and assignment ID passed in */
--
	cursor get_latest_id_for_effect
	is
	SELECT	TO_NUMBER(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
	FROM	pay_payroll_actions	ppa,
		pay_assignment_actions	paa
	WHERE	paa.assignment_id = p_assignment_id
	AND	ppa.payroll_action_id = paa.payroll_action_id
	AND	ppa.effective_date <= p_effective_date
	AND	ppa.action_type in ('R', 'Q', 'I', 'V', 'B');
--
	cursor get_latest_id_for_earned
	is
    	SELECT	TO_NUMBER(substr(max(lpad(ASSACT.action_sequence,15,'0')||ASSACT.assignment_action_id),16))
	FROM	pay_payroll_actions    PACT,
		pay_assignment_actions ASSACT
	WHERE	ASSACT.assignment_id = p_assignment_id
	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
	AND	PACT.date_earned <= p_effective_date
	AND	PACT.action_type in ('R', 'Q', 'I', 'V', 'B');
--
        cursor balance_dimension
        is
        SELECT	RTRIM(SUBSTRB(DIM.dimension_name,31,15),' ')
        FROM	pay_balance_dimensions  DIM,
        	pay_defined_balances    DB
        WHERE   DB.defined_balance_id = p_defined_balance_id
        AND     DIM.balance_dimension_id = DB.balance_dimension_id;
--
BEGIN
--
	open	balance_dimension;
	fetch	balance_dimension into l_dimension_jp_type;
	close	balance_dimension;
--
	if	l_dimension_jp_type = 'DATE_EARNED' then
	--
		open get_latest_id_for_earned;
		fetch get_latest_id_for_earned into l_assignment_action_id;
		close get_latest_id_for_earned;
	--
	else	--l_dimension_jp_type = 'EFFECTIVE_DATE' or core dimension(l_dimension_jp_type is null)
	--
		open get_latest_id_for_effect;
		fetch get_latest_id_for_effect into l_assignment_action_id;
		close get_latest_id_for_effect;
	--
	end if;
--
	if l_assignment_action_id is null then
		l_balance := 0;
	else
		/* --Check expiry even before getting the VALUE, according to effective date */
		l_expired := balance_expired(
					l_assignment_action_id,
					p_defined_balance_id,
					null,
					p_effective_date,
					null);
		if l_expired = TRUE then
			l_balance := 0;
		else
			/* --get the balance value using the latest assignment action */
			l_balance := get_balance(
					p_assignment_action_id => l_assignment_action_id,
		                      	p_defined_balance_id   => p_defined_balance_id);
		end if;
	end if;
--
RETURN l_balance;
--
END get_balance;
/* ------------------------------------------------------------------------------------
--
--			FUNCTION get_balance
--			Assignment Action Mode
--
-- The theory behind this is that we can check whether the balance has
-- expired before getting it, due to the fact that we navigate back to the
-- last assignment action and use the assigment action id
-- as criteria for expiry checking
--
-- ------------------------------------------------------------------------------------ */
FUNCTION get_balance (p_assignment_action_id IN NUMBER,
		      p_defined_balance_id   IN NUMBER)
RETURN NUMBER IS
--
	l_balance		NUMBER;
--
BEGIN
--
     l_balance := pay_balance_pkg.get_value(
                    p_assignment_action_id => p_assignment_action_id,
                    p_defined_balance_id   => p_defined_balance_id);
--
RETURN l_balance;
END get_balance;
--
/* ------------------------------------------------------------------------------------
--
--		FUNCTION balance_expired
--
-- This function checks the expiry of an action's value ,
-- depending on which dimension type the value is for
--
-- ------------------------------------------------------------------------------------ */
FUNCTION balance_expired (p_assignment_action_id IN NUMBER,
	          p_defined_balance_id   IN NUMBER,
			  p_dimension_name IN VARCHAR2,
 			  p_effective_date       IN DATE,
			  p_action_effective_date IN DATE)
--
RETURN BOOLEAN IS
--
/* --Check the expiry of an action depending on the defined balance's dimension
--type. */
--
	l_dimension_name	VARCHAR2(80);
	l_dimension_jp_type	VARCHAR2(15);
	l_expired		BOOLEAN;
	l_return_date		DATE;
	l_business_group_id	NUMBER(15);
	l_date_earned		DATE;
	l_frequency		NUMBER;
	l_start_dd_mm		VARCHAR2(6);
--
	cursor get_dimension_type(c_defined_balance_id   IN NUMBER)
	IS
	SELECT	pbd.dimension_name
	FROM	pay_balance_dimensions	pbd,
		pay_defined_balances	pdb
	WHERE	pdb.defined_balance_id = c_defined_balance_id
	AND	pbd.balance_dimension_id = pdb.balance_dimension_id;
--
	cursor	csr_business_group
	is
	SELECT	PACT.business_group_id,
		PACT.date_earned
	FROM	pay_payroll_actions	PACT,
		pay_assignment_actions	ASSACT
	WHERE	ASSACT.assignment_action_id = p_assignment_action_id
	AND	PACT.payroll_action_id = ASSACT.payroll_action_id;
--
BEGIN
-- To solve gscc error
	l_expired := FALSE;
--
	open csr_business_group;
	fetch csr_business_group into l_business_group_id, l_date_earned;
	close csr_business_group;
--
	if p_dimension_name is null then	--date mode call
		open get_dimension_type(p_defined_balance_id);
		fetch get_dimension_type into l_dimension_name;
		close get_dimension_type;
--
	else
		l_dimension_name := p_dimension_name;
	end if;
--
	l_dimension_jp_type := RTRIM( SUBSTRB(l_dimension_name,31,15),' ');
--
	if l_dimension_name = hr_jprts.g_asg_run then
		/* --run balance, so call period expiry */
		if p_effective_date > expired_period_date(p_assignment_action_id) then
			l_expired := TRUE;
		end if;
	elsif l_dimension_name  = hr_jprts.g_asg_proc_ptd then
		/* --period balance, so call period expiry */
		if p_effective_date > expired_period_date(p_assignment_action_id) then
			l_expired := TRUE;
		end if;
--
	elsif l_dimension_name = hr_jprts.g_asg_fytd_jp THEN
		/* -- Do not add the function add_months for l_return_date.
		-- Because add_months(1999/02/28,12) => 2000/02/29(actual next term date is 2000/02/28)
		--
		-- Ignore p_action_effective_date because it is not unique to get date_earned
		-- while using effective_date (not action id). Always use action id at that time. */
		l_return_date := hr_jprts.dimension_reset_date_userdef(
							l_dimension_name,
							add_months(l_date_earned,12),
							'FLEX',
							null,
							l_business_group_id);
		/* -- it's wrong because return date must be next term date.
		--l_return_date := hr_jprts.dimension_reset_date_userdef(
		--					l_dimension_name,
		--					l_date_earned,
		--					'FLEX',
		--					null,
		--					l_business_group_id);
		-- if calling function is Date Mode, p_effective_date is session_date.
		-- l_next_start_date = l_return_date */
		if p_effective_date >= l_return_date
		or l_return_date is null then
	        	l_expired := TRUE;
		end if;
--
	/* -- Actually, this function is not used so that hr_routes.retro_jp does not exist. */
	elsif l_dimension_name =  hr_jprts.g_retro then
		if p_effective_date > expired_period_date(p_assignment_action_id) then
			l_expired := TRUE;
		end if;
	elsif l_dimension_name = hr_jprts.g_payment then
		if p_effective_date > expired_period_date(p_assignment_action_id) then
			l_expired := TRUE;
	end if;
/* -- the following treatment does not include ITD. */
	else
		IF l_dimension_jp_type = 'EFFECTIVE_DATE' then
			l_return_date := hr_jprts.dimension_reset_last_date(
						l_dimension_name,
						nvl(p_action_effective_date,(get_action_date(p_assignment_action_id)))) + 1;
			--
			if p_effective_date >= l_return_date
			or l_return_date is null then
		        	l_expired := TRUE;
			end if;
		ELSIF l_dimension_jp_type = 'DATE_EARNED' then
			l_return_date := hr_jprts.dimension_reset_last_date(l_dimension_name,l_date_earned) + 1;
			--
			-- if calling function is Date Mode, p_effective_date is session_date. */
			if p_effective_date >= l_return_date
			or l_return_date is null then
			        l_expired := TRUE;
			end if;
		END IF;
	end if;
--
RETURN l_expired;
--
END balance_expired;
--
/* ------------------------------------------------------------------------------------
--
--		FUNCTION expired_period_date
--
-- This function returns the expiry of an action's time period
--
-- ------------------------------------------------------------------------------------ */
FUNCTION expired_period_date(p_assignment_action_id IN NUMBER)
--
RETURN DATE IS
--
	l_end_date 	DATE;
--
	cursor expired_time_period(c_assignment_action_id IN NUMBER)
	is
	SELECT	ptp.end_date
	FROM	per_time_periods	ptp,
		pay_payroll_actions	ppa,
		pay_assignment_actions	paa
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	ppa.payroll_action_id = paa.payroll_action_id
	AND	ptp.time_period_id = ppa.time_period_id;
--
BEGIN
--
	open expired_time_period(p_assignment_action_id);
	fetch expired_time_period into l_end_date;
	close expired_time_period;
--
RETURN l_end_date;
--
END expired_period_date;
--
/* ------------------------------------------------------------------------------------
--		FUNCTION get_action_date
--		This function gets the effective date of an assignment action
-- ------------------------------------------------------------------------------------ */
FUNCTION get_action_date(p_assignment_action_id IN NUMBER)
RETURN DATE IS
--
	l_effective_date     date;
--
	cursor c_bal_date
	is
	SELECT	ppa.effective_date
	FROM	pay_payroll_actions	ppa,
		pay_assignment_actions	paa
	WHERE	paa.assignment_action_id = p_assignment_action_id
	AND	paa.payroll_action_id = ppa.payroll_action_id;
--
BEGIN
--
	open  c_bal_date;
	fetch c_bal_date into l_effective_date;
		if c_bal_date%NOTFOUND then
			/* --raise_application_error(-20000,'This assignment action is invalid');
			--cant use as violates pragma wnds, so set date to null */
			l_effective_date := null;
		end if;
	close c_bal_date;
--
RETURN l_effective_date;
END get_action_date;
--
END hr_jpdrb;

/
