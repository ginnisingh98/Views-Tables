--------------------------------------------------------
--  DDL for Package Body HR_JPRTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JPRTS" AS
/* $Header: pyjprts.pkb 120.4.12010000.2 2010/03/02 02:49:05 keyazawa ship $ */
/* ------------------------------------------------------------------------------------ */
--  Global variable for DIMENSION_RESETDATE,DIMENSION_RESET_LAST_DATE,
--		        DIMENSION_RESET_DATE_USERDEF and DIM_RESET_LAST_DATE_USERDEF
	g_reset_identifier	CONSTANT VARCHAR2(7):=' RESET ';
--
-- Fiscal Year Start Date
-- If not entered, January 1st is used instead.
-- Bug.2597843
--
cursor csr_fiscal_year_start_date(p_business_group_id	number) is
	SELECT	fnd_date.canonical_to_date(org_information11)
	FROM	hr_organization_information
	WHERE	org_information_context = 'Business Group Information'
	AND	organization_id = p_business_group_id;
g_business_group_id		number;
g_fiscal_year_start_date	date;

/* ------------------------------------------------------------------------------------
-- SPAN_START
-- return the general dimension's start of the span (year/quarter/week)
-- ------------------------------------------------------------------------------------ */
FUNCTION span_start(
	p_input_date	DATE,
	p_frequency		NUMBER,
	p_start_dd_mm	VARCHAR2)
RETURN DATE
IS
	l_year			NUMBER(4);
	l_start			DATE;
	l_start_base_high	date;
	l_start_base_low	date;
	l_start_dd_mm		varchar2(6);
	l_correct_format	BOOLEAN;
    l_p_frequency number;
    l_p_start_dd_mm varchar2(10);
BEGIN
-- To solve gscc error
    l_p_frequency := nvl(p_frequency,1);
    l_p_start_dd_mm := nvl(p_start_dd_mm,'01-01-');
--
	l_year := TO_NUMBER(TO_CHAR(p_input_date,'YYYY'));
--
	/* -- Check that the passed in start of year
	-- is in the correct format. Add a hyphen if one is missing
	-- from the end, and ensure DD-MM- only has 6 characters.
	-- If none of these 2 criteria are met, return null. */
--
	if length(l_p_start_dd_mm) = 5 and instr(l_p_start_dd_mm,'-',-1) = 3 then
		l_start_dd_mm := l_p_start_dd_mm||'-';
		l_correct_format := TRUE;
	elsif length(l_p_start_dd_mm) = 6 and instr(l_p_start_dd_mm,'-',-1) = 6 then
		l_start_dd_mm := l_p_start_dd_mm;
		l_correct_format := TRUE;
	else
		l_correct_format := FALSE;
	end if;
--
	if l_correct_format then
		IF p_input_date >= TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY') THEN
			l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY');
		ELSE
--        		l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year -1),'DD-MM-YYYY');
			l_start := add_months(TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY'),-12);
		END IF;
/* -- cater for weekly based frequency based on 52 per annum */
		IF l_p_frequency IN (52,26,13) THEN
--			l_start := p_input_date - MOD(p_input_date - l_start,7 * 52/l_p_frequency);
			l_start := p_input_date - MOD(to_number(p_input_date - l_start),7 * 52/l_p_frequency);
		ELSE
/* -- cater for monthly based frequency based on 12 per annum */
			if l_p_frequency <= 12 then
				l_start := ADD_MONTHS(l_start, (12/l_p_frequency) * TRUNC(MONTHS_BETWEEN(p_input_date,l_start)/(12/l_p_frequency)));
/* -- cater for frequency under 12 per annum. */
			else
			        l_start_base_low := ADD_MONTHS(l_start, trunc((12/l_p_frequency) * TRUNC(MONTHS_BETWEEN(p_input_date,l_start)/(12/l_p_frequency))));
			        l_start_base_high :=l_start_base_low + trunc((add_months(trunc(p_input_date,'MM'),1)-trunc(p_input_date,'MM')) * (12/l_p_frequency));
				if l_start_base_high > p_input_date then
					l_start := l_start_base_low;
				else
					l_start := l_start_base_high;
				end if;
			end if;
		END IF;
	end if;
--
RETURN l_start;
END span_start;
--
/* ------------------------------------------------------------------------------------
-- SPAN_END
-- return the end of the span (year/quarter/week)
-- (Originally it is used as returning the end of the person level (statutory) period.)
-- ------------------------------------------------------------------------------------ */
FUNCTION span_end(
        p_input_date            DATE,
        p_frequency             NUMBER,
        p_end_dd_mm           VARCHAR2)
RETURN DATE
IS
        l_year			NUMBER(4);
        l_end			DATE;
	l_end_base_high		date;
	l_end_base_low		date;
        l_end_dd_mm		varchar2(6);
        l_correct_format	BOOLEAN;
    l_p_frequency number;
    l_p_end_dd_mm varchar2(10);
BEGIN
-- To solve gscc error
    l_p_frequency := nvl(p_frequency,1);
    l_p_end_dd_mm := nvl(p_end_dd_mm,'01-01-');
--
	l_year := TO_NUMBER(TO_CHAR(p_input_date,'YYYY'));
--
	/* -- Check that the passed in start of year
	-- is in the correct format. Add a hyphen if one is missing
	-- from the end, and ensure DD-MM- only has 6 characters.
	-- If none of these 2 criteria are met, return null. */
--
	if length(l_p_end_dd_mm) = 5 and instr(l_p_end_dd_mm,'-',-1) = 3 then
		l_end_dd_mm := l_p_end_dd_mm||'-';
		l_correct_format := TRUE;
	elsif length(l_p_end_dd_mm) = 6 and instr(l_p_end_dd_mm,'-',-1) = 6 then
		l_end_dd_mm := l_p_end_dd_mm;
		l_correct_format := TRUE;
	else
		l_correct_format := FALSE;
	end if;
--
	if l_correct_format then
		IF p_input_date >= TO_DATE(l_end_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY') THEN
			l_end := TO_DATE(l_end_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY');
		ELSE
--			l_end := TO_DATE(l_end_dd_mm||TO_CHAR(l_year -1),'DD-MM-YYYY');
			l_end := add_months(TO_DATE(l_end_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY'),-12);
		END IF;
/* -- cater for weekly based frequency based on 52 per annum */
		IF l_p_frequency IN (52,26,13) THEN
--			l_end := p_input_date - MOD(p_input_date - l_end, 7 * (52/l_p_frequency)) + ((7 * 52/l_p_frequency)-1);
			l_end := (p_input_date - MOD(TO_NUMBER(p_input_date - l_end), 7 * (52/l_p_frequency)) + (7 * 52/l_p_frequency)-1);
		ELSE
/* -- cater for monthly based frequency based on 12 per annum */
			if l_p_frequency <= 12 then
				l_end := (add_months (ADD_MONTHS(l_end, (12/l_p_frequency)
					* TRUNC(MONTHS_BETWEEN(p_input_date,l_end)/(12/l_p_frequency))),(12/l_p_frequency)) -1);
/* -- cater for frequency under 12 per annum. */
			else
			        l_end_base_low := ADD_MONTHS(l_end, trunc((12/l_p_frequency) * TRUNC(MONTHS_BETWEEN(p_input_date,l_end)/(12/l_p_frequency))));
			        l_end_base_high :=l_end_base_low + trunc((add_months(trunc(p_input_date,'MM'),1)-trunc(p_input_date,'MM')) * (12/l_p_frequency));
				if l_end_base_high > p_input_date then
					l_end := l_end_base_low;
				else
					l_end := l_end_base_high;
				end if;
--			        l_end := (l_end + trunc((add_months(trunc(p_input_date,'MM'),1)-trunc(p_input_date,'MM')) * (12/l_p_frequency)) -1);
			        l_end := (l_end + trunc((add_months(trunc(l_end,'MM'),1)-trunc(l_end,'MM')) * (12/l_p_frequency)) -1);
			end if;
		END IF;
	end if;
--
RETURN l_end;
END span_end;
--
/* ------------------------------------------------------------------------------------
-- SPAN_START_FISICAL_YEAR
-- return the start of fisical year dimension's span (year/quarter/week)
-- ------------------------------------------------------------------------------------ */
FUNCTION span_start_fisical_year(
	p_input_date		DATE,
	p_business_group_id	NUMBER)
RETURN DATE
IS
	l_start_date	date;
/*
	l_year	NUMBER(4);
	l_start	DATE;
	l_start_date    VARCHAR2(11);
	l_start_date_year	number(4);
--
	cursor csr_start_date
	is
	SELECT	to_char(nvl(FND_DATE.CANONICAL_TO_DATE(org_information11),to_date(to_char(p_input_date,'YYYY')||'/04/01','YYYY/MM/DD')),'DD-MM-YYYY')
	FROM	hr_organization_information
	WHERE	org_information_context='Business Group Information'
	AND	organization_id = p_business_group_id;
*/
BEGIN
--
/* -- select from Org. Develper PDF */
/*
	open csr_start_date;
	fetch csr_start_date into l_start_date;
	close csr_start_date;
--
	l_year := TO_NUMBER(TO_CHAR(p_input_date,'YYYY'));
	l_start_date_year := to_number(substrb(l_start_date,7,4));
--
	IF substrb(l_start_date,1,6) = '29-02-' then
		-- if l_start_date_year > l_year then
			if mod(l_start_date_year - l_year,4) <> 0 then
				l_start_date := '28-02-'||to_char(l_start_date_year);
			end if;
		-- elsif l_start_date_year < l_year then
		--	if mod(l_year - l_start_date_year,4) <> 0 then
		--		l_start_date := '28-02-'||to_char(l_start_date_year);
		--	end if;
		-- end if;
	END IF;
	IF p_input_date >= to_date(substrb(l_start_date,1,6) ||TO_CHAR(l_year),'DD-MM-YYYY') THEN
		l_start := to_date(substrb(l_start_date,1,6) ||TO_CHAR(l_year),'DD-MM-YYYY');
	ELSE
--		l_start := to_date(substrb(l_start_date,1,6) ||TO_CHAR(l_year -1),'DD-MM-YYYY');
		l_start := add_months(to_date(substrb(l_start_date,1,6) ||TO_CHAR(l_year),'DD-MM-YYYY'),-12);
	END IF;
--
RETURN l_start;
*/
	--
	-- Bug.2597843
	--
	if p_business_group_id = g_business_group_id then
		l_start_date := g_fiscal_year_start_date;
	else
		open csr_fiscal_year_start_date(p_business_group_id);
		fetch csr_fiscal_year_start_date into l_start_date;
		close csr_fiscal_year_start_date;
		if l_start_date is null then
			l_start_date := trunc(p_input_date, 'YYYY');
		end if;
		--
		-- Cache the fiscal year start date of current business group
		--
		g_business_group_id		:= p_business_group_id;
		g_fiscal_year_start_date	:= l_start_date;
	end if;
	--
	l_start_date := add_months(l_start_date, floor(months_between(p_input_date, l_start_date) / 12) * 12);
	--
	return l_start_date;
END span_start_fisical_year;
--
/* ------------------------------------------------------------------------------------
-- SPAN_END_FISICAL_YEAR
-- return the end of fisical year dimension's span (year/quarter/week)
-- ------------------------------------------------------------------------------------ */
FUNCTION span_end_fisical_year(
	p_input_date		DATE,
	p_business_group_id	NUMBER)
RETURN DATE
IS
	l_start_date	date;
	l_end_date	date;
/*
	l_year			NUMBER(4);
	l_start			DATE;
	l_end			DATE;
	l_start_date	   	VARCHAR2(11);
	l_start_date_year	number(4);
--
	cursor csr_start_date
	is
	SELECT	to_char(nvl(FND_DATE.CANONICAL_TO_DATE(org_information11),to_date(to_char(p_input_date,'YYYY')||'/04/01','YYYY/MM/DD')),'DD-MM-YYYY')
	FROM	hr_organization_information
	WHERE	org_information_context='Business Group Information'
	AND	organization_id = p_business_group_id;
*/
BEGIN
--
/* -- select from Org. Develper PDF */
/*
	open csr_start_date;
	fetch csr_start_date into l_start_date;
	close csr_start_date;
--
	l_year := TO_NUMBER(TO_CHAR(p_input_date,'YYYY'));
	l_start_date_year := to_number(substrb(l_start_date,7,4));
--
	IF substrb(l_start_date,1,6) = '29-02-' then
		-- if l_start_date_year > l_year then
			if mod(l_start_date_year - l_year,4) <> 0 then
				l_start_date := '28-02-'||to_char(l_start_date_year);
			end if;
		-- elsif l_start_date_year < l_year then
		--	if mod(l_year - l_start_date_year,4) <> 0 then
		--		l_start_date := '28-02-'||to_char(l_start_date_year);
		--	end if;
		-- end if;
	END IF;
	IF p_input_date >= to_date(substrb(l_start_date,1,6) ||TO_CHAR(l_year),'DD-MM-YYYY') THEN
		l_start := to_date(substrb(l_start_date,1,6) ||TO_CHAR(l_year),'DD-MM-YYYY');
	ELSE
--		l_start := to_date(substrb(l_start_date,1,6) ||TO_CHAR(l_year -1),'DD-MM-YYYY');
		l_start := add_months(to_date(substrb(l_start_date,1,6) ||TO_CHAR(l_year),'DD-MM-YYYY'),-12);
	END IF;
--
	l_end := add_months(l_start,12) - 1;
--
RETURN l_end;
*/
	--
	-- Bug.2597843
	--
	l_end_date := add_months(span_start_fisical_year(p_input_date, p_business_group_id), 12) - 1;
	--
	return l_end_date;
END span_end_fisical_year;
--
/* ------------------------------------------------------------------------------------
-- DIMENSION_RESET_DATE
-- what is the latest reset date for a particular dimension
-- ------------------------------------------------------------------------------------ */
FUNCTION dimension_reset_date(
	p_dimension_name	VARCHAR2,
	p_user_date 		DATE)
RETURN DATE
IS
	l_start_dd_mm		VARCHAR2(6);
	l_period_from_date	DATE;
	l_frequency		NUMBER;
	l_start_reset		NUMBER;
	l_reset_pos		NUMBER;
BEGIN
--	l_frequency		:= TO_NUMBER(SUBSTRB(p_dimension_name, 58, 2));
--	l_start_dd_mm		:= SUBSTRB(p_dimension_name, 46, 5) || '-';
	l_reset_pos		:= INSTRB(p_dimension_name,g_reset_identifier);
--
	IF l_reset_pos > 0 THEN
	  l_frequency		:= TO_NUMBER(SUBSTRB(p_dimension_name,l_reset_pos + 7, 2));
	  l_start_dd_mm		:= SUBSTRB(p_dimension_name, l_reset_pos - 5, 5) || '-';
	ELSE
	  l_frequency		:= NULL;
	  l_start_dd_mm		:= NULL;
	END IF;
	l_period_from_date	:= span_start(p_user_date, l_frequency, l_start_dd_mm);
--
RETURN l_period_from_date;
END dimension_reset_date;
--
/* ------------------------------------------------------------------------------------
-- DIMENSION_RESET_LAST_DATE
-- what is the latest reset last date for a particular dimension
-- ------------------------------------------------------------------------------------ */
FUNCTION dimension_reset_last_date(
	p_dimension_name	VARCHAR2,
	p_user_date 		DATE)
RETURN DATE
IS
	l_end_dd_mm		VARCHAR2(6);
	l_period_last_date	DATE;
	l_frequency		NUMBER;
	l_end_reset		NUMBER;
	l_reset_pos		NUMBER;
BEGIN
--	l_frequency		:= TO_NUMBER(SUBSTRB(p_dimension_name, 58, 2));
--	l_end_dd_mm		:= SUBSTRB(p_dimension_name, 46, 5) || '-';
	l_reset_pos		:= INSTRB(p_dimension_name,g_reset_identifier);
--
	IF l_reset_pos > 0 THEN
	  l_frequency		:= TO_NUMBER(SUBSTRB(p_dimension_name,l_reset_pos + 7, 2));
	  l_end_dd_mm		:= SUBSTRB(p_dimension_name, l_reset_pos - 5, 5) || '-';
	ELSE
	  l_frequency		:= NULL;
	  l_end_dd_mm		:= NULL;
	END IF;
	l_period_last_date	:= span_end(p_user_date, l_frequency, l_end_dd_mm);
--
RETURN l_period_last_date;
END dimension_reset_last_date;
--
/* ------------------------------------------------------------------------------------
-- DIMENSION_RESET_DATE_USERDEF
-- what is the latest reset date for a particular dimension REPORT use ONLY.
-- ------------------------------------------------------------------------------------ */
FUNCTION dimension_reset_date_userdef(
	p_dimension_name	VARCHAR2,
	p_user_date 		DATE,
	p_storage_type		VARCHAR2,
	p_storage_name		VARCHAR2,
	p_business_group_id	NUMBER)
RETURN DATE
IS
	l_start_dd_mm		VARCHAR2(7);
	l_period_from_date	DATE;
	l_frequency		NUMBER;
	l_start			NUMBER;
	l_reset_pos		NUMBER;
BEGIN
--   	l_frequency:=TO_NUMBER(SUBSTRB(p_dimension_name, 58, 2));
--
/*
	l_reset_pos		:= INSTRB(p_dimension_name,g_reset_identifier);
	IF l_reset_pos > 0 THEN
	  l_frequency		:= TO_NUMBER(SUBSTRB(p_dimension_name,l_reset_pos + 7, 2));
	ELSE
	  l_frequency		:= NULL;
	END IF;
*/
--
	IF p_storage_type = 'FLEX' THEN --(Org. Developer Flex)
		l_period_from_date := span_start_fisical_year(
						p_user_date,
						p_business_group_id);
	END IF;
--
RETURN l_period_from_date;
END dimension_reset_date_userdef;
--
/* ------------------------------------------------------------------------------------
-- DIM_RESET_LAST_DATE_USERDEF
-- what is the latest reset date for a particular dimension REPORT use ONLY.
-- ------------------------------------------------------------------------------------ */
FUNCTION dim_reset_last_date_userdef(
	p_dimension_name	VARCHAR2,
	p_user_date 		DATE,
	p_storage_type		VARCHAR2,
	p_storage_name		VARCHAR2,
	p_business_group_id	NUMBER)
RETURN DATE
IS
	l_end_dd_mm		VARCHAR2(7);
	l_period_last_date	DATE;
	l_frequency		NUMBER;
	l_end			NUMBER;
	l_reset_pos		NUMBER;
BEGIN
--   	l_frequency:=TO_NUMBER(SUBSTRB(p_dimension_name, 58, 2));
--
/*
	l_reset_pos		:= INSTRB(p_dimension_name,g_reset_identifier);
	IF l_reset_pos > 0 THEN
	  l_frequency		:= TO_NUMBER(SUBSTRB(p_dimension_name,l_reset_pos + 7, 2));
	ELSE
	  l_frequency		:= NULL;
	END IF;
*/
--
	IF p_storage_type = 'FLEX' THEN --(Org. Developer Flex)
		l_period_last_date := span_end_fisical_year(
						p_user_date,
						p_business_group_id);
	END IF;
--
RETURN l_period_last_date;
END dim_reset_last_date_userdef;
--
/* ------------------------------------------------------------------------------------
-- CALC_BALANCE_FOR_DATE_EARNED
-- General function for accumulating a balance between two dates
-- The object of date is DATE_EARNED.
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_bal_date_earned(
		p_assignment_id		IN NUMBER,
		p_balance_type_id	IN NUMBER,	-- balance
		p_from_date		IN DATE,	-- since effective date of
		p_to_date		IN DATE,	-- sum up to this date
		p_action_sequence	IN NUMBER)	-- sum up to this sequence
RETURN NUMBER
IS
l_defined_balance_id 	PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
l_balance	NUMBER;
--
--	cursor	csr_assignment_action_id
--	is
--	SELECT	ASSACT.assignment_action_id
--	FROM	pay_payroll_actions		PACT,
--		pay_assignment_actions		ASSACT
--	WHERE	ASSACT.assignment_id = P_ASSIGNMENT_ID
--	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
--	AND	PACT.date_earned >= P_FROM_DATE
--	AND	(	(	PACT.date_earned < P_TO_DATE)
--		or	(	PACT.date_earned = P_TO_DATE
--			and	ASSACT.action_sequence <= P_ACTION_SEQUENCE));
--
	cursor csr_balance
	is
--	SELECT	/*+ RULE */
--	SELECT	/* Hint removed : see bug :4256073 */
  select  /*+ ORDERED
              USE_NL(FEED)
              INDEX(FEED PAY_BALANCE_FEEDS_F_N50) */
		NVL(SUM(FND_NUMBER.CANONICAL_TO_NUMBER(TARGET.result_value) * FEED.scale),0)
	FROM	pay_assignment_actions		ASSACT,
		pay_payroll_actions		PACT,
		pay_run_results			RR,
		pay_run_result_values		TARGET,
		pay_balance_feeds_f		FEED
	WHERE	ASSACT.assignment_id = P_ASSIGNMENT_ID
--	AND	ASSACT.action_sequence <= NVL(P_ACTION_SEQUENCE,ASSACT.action_sequence)
	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
	AND	PACT.date_earned >= P_FROM_DATE
	AND	(	(	PACT.date_earned < P_TO_DATE)
		or	(	PACT.date_earned = P_TO_DATE
			and	ASSACT.action_sequence <= P_ACTION_SEQUENCE))
	AND	RR.assignment_action_id = ASSACT.assignment_action_id
	AND	RR.status IN ('P','PA')
	AND	TARGET.run_result_id = RR.run_result_id
	AND	nvl(TARGET.result_value, '0') <> '0'
	AND	FEED.input_value_id = TARGET.input_value_id
	AND	FEED.balance_type_id = P_BALANCE_TYPE_ID
--	AND	PACT.effective_date
	AND	PACT.date_earned
		BETWEEN	FEED.effective_start_date AND FEED.effective_end_date;
BEGIN
--l_balance := 0;
--l_defined_balance_id := PAY_JP_BALANCE_PKG.GET_DEFINED_BALANCE_ID(p_balance_type_id,p_assignment_id,p_to_date);

--IF l_defined_balance_id is not null THEN
--	FOR c_assignment_action_id IN csr_assignment_action_id LOOP
--	 	l_balance := l_balance + pay_balance_pkg.get_value(l_defined_balance_id, c_assignment_action_id.assignment_action_id);
--	END LOOP;
--ELSE
	open csr_balance;
	fetch csr_balance into l_balance;
	close csr_balance;
--END IF;

--
RETURN l_balance;
END calc_bal_date_earned;
--
/* ------------------------------------------------------------------------------------
-- CALC_BALANCE_FOR_EFF_DATE
-- General function for accumulating a balance between two dates
-- The object of date is EFFECTIVE_DATE.
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_bal_eff_date(
		p_assignment_id		IN NUMBER,
		p_balance_type_id	IN NUMBER,	-- balance
		p_from_date		IN DATE,	-- since effective date of
		p_to_date		IN DATE,	-- sum up to this date
		p_action_sequence	IN NUMBER)	-- sum up to this sequence
RETURN NUMBER
IS
l_assignment_action_id	PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE;
l_defined_balance_id 	PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
l_balance	NUMBER;
--
--	cursor	csr_assignment_action_id
--	is
--	SELECT	ASSACT.assignment_action_id
--	from	pay_payroll_actions	PACT,
--		pay_assignment_actions	ASSACT
--	WHERE	ASSACT.assignment_id = p_assignment_id
--	AND	ASSACT.action_sequence <= NVL(p_action_sequence, ASSACT.action_sequence)
--	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
--	AND	PACT.action_type <> 'V'
--	AND	PACT.effective_date >= p_from_date
--	AND	PACT.effective_date <= p_to_date
--	AND	NOT EXISTS(
--		SELECT	NULL
--		FROM	pay_payroll_actions	RPACT,
--			pay_assignment_actions	RASSACT,
--			pay_action_interlocks	RINTL
--		WHERE	RINTL.locked_action_id = ASSACT.assignment_action_id
--		AND	RASSACT.assignment_action_id = RINTL.locking_action_id
--		AND	RPACT.payroll_action_id = RASSACT.payroll_action_id
--		AND	RPACT.action_type = 'V');
--
--
/* -- This cursor have to check target ASSACT isn't locked by Reversal ASSACT. */
	cursor csr_balance
	is
--	SELECT	/*+ RULE */
	SELECT	/*+ ORDERED */
		NVL(SUM(FND_NUMBER.CANONICAL_TO_NUMBER(TARGET.result_value) * FEED.scale),0)
	FROM	(	select	/*+ ORDERED */
				ASSACT.assignment_action_id,
				PACT.effective_date
			from	pay_assignment_actions	ASSACT,
				pay_payroll_actions	PACT
			WHERE	ASSACT.assignment_id = p_assignment_id
			AND	ASSACT.action_sequence <= NVL(p_action_sequence, ASSACT.action_sequence)
			AND	PACT.payroll_action_id = ASSACT.payroll_action_id
			AND	PACT.action_type <> 'V'
			AND	PACT.effective_date >= p_from_date
			AND	PACT.effective_date <= p_to_date
			AND	NOT EXISTS(
					SELECT	NULL
					FROM	pay_payroll_actions	RPACT,
						pay_assignment_actions	RASSACT,
						pay_action_interlocks	RINTL
					WHERE	RINTL.locked_action_id = ASSACT.assignment_action_id
					AND	RASSACT.assignment_action_id = RINTL.locking_action_id
					AND	RPACT.payroll_action_id = RASSACT.payroll_action_id
					AND	RPACT.action_type = 'V')) V1,
		pay_run_results		RR,
		pay_run_result_values	TARGET,
		pay_balance_feeds_f	FEED
	WHERE	RR.assignment_action_id = V1.assignment_action_id
	AND	RR.status IN ('P','PA')
	AND	TARGET.run_result_id = RR.run_result_id
	AND	nvl(TARGET.result_value, '0') <> '0'
	AND	FEED.input_value_id = TARGET.input_value_id
	AND	FEED.balance_type_id = p_balance_type_id
	AND	V1.effective_date
		BETWEEN	FEED.effective_start_date AND FEED.effective_end_date;
BEGIN
--l_balance := 0;
--l_defined_balance_id := PAY_JP_BALANCE_PKG.GET_DEFINED_BALANCE_ID(p_balance_type_id,p_assignment_id,p_to_date);
--
--IF l_defined_balance_id is not null THEN
--	FOR c_assignment_action_id IN csr_assignment_action_id LOOP
--	 	l_balance := l_balance + pay_balance_pkg.get_value(l_defined_balance_id, c_assignment_action_id.assignment_action_id);
--	END LOOP;
--ELSE
	open csr_balance;
	fetch csr_balance into l_balance;
	close csr_balance;
--END IF;
--
RETURN l_balance;
END calc_bal_eff_date;
--
/* ------------------------------------------------------------------------------------
-- ASG_FYTD_JP
-- JP Specific function for accumulating a balance using assignment_action_id.
-- This function is to accumulate values for the dimension of Financial Year to Date.
-- ------------------------------------------------------------------------------------ */
FUNCTION asg_fytd_jp(
	p_assignment_action_id	IN NUMBER,
	p_balance_type_id	IN NUMBER)  -- balance
RETURN NUMBER
IS
l_defined_balance_id 	PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
l_balance	NUMBER;
--
--	cursor csr_assignment_action_id(assact_id	IN NUMBER,
--				baltype	IN NUMBER)
--	is
--	SELECT	/*+ ORDERED */
--		ASSACT.assignment_action_id
--	FROM	(	select	/*+ ORDERED */
--				BAL_ASSACT.assignment_id	assignment_id,
--				BAL_ASSACT.action_sequence	action_sequence,
--				BACT.date_earned		date_earned,
--				add_months(
--					nvl(fnd_date.canonical_to_date(HROG.org_information11), trunc(BACT.date_earned, 'YYYY')),
--					floor(
--						months_between(	BACT.date_earned,
--								nvl(fnd_date.canonical_to_date(HROG.org_information11), trunc(BACT.date_earned, 'YYYY')))
--					/ 12) * 12)	start_date
--			from	pay_assignment_actions		BAL_ASSACT,
--				pay_payroll_actions		BACT,
--				hr_organization_information	HROG
--			where	BAL_ASSACT.assignment_action_id = assact_id
--			and	BACT.payroll_action_id = BAL_ASSACT.payroll_action_id
--			and	HROG.organization_id = BACT.business_group_id
--			and	HROG.org_information_context = 'Business Group Information') V1,
--		pay_assignment_actions	ASSACT,
--		pay_payroll_actions	PACT
--	WHERE	ASSACT.assignment_id = V1.assignment_id
--	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
--	AND	PACT.date_earned >= V1.start_date
--	AND	(	(	PACT.date_earned < V1.date_earned)
--		or	(	PACT.date_earned = V1.date_earned
--			and	ASSACT.action_sequence <= V1.action_sequence));
--
/* -- This cursor have to check target ASSACT isn't locked by Reversal ASSACT. */
	cursor csr_balance(assact_id	IN NUMBER,
				baltype	IN NUMBER)
	is
--	SELECT	/*+ RULE */
	SELECT /*+ ORDERED
             INDEX(FEED PAY_BALANCE_FEEDS_F_N50) */
		NVL(SUM(FND_NUMBER.CANONICAL_TO_NUMBER(TARGET.result_value) * FEED.scale),0)
	FROM
		(	select	BAL_ASSACT.assignment_id	assignment_id,
				BAL_ASSACT.action_sequence	action_sequence,
--				BACT.action_type		action_type,
				BACT.date_earned		date_earned,
				--
				-- When null, apply 1st January
				--
				add_months(
					nvl(fnd_date.canonical_to_date(HROG.org_information11), trunc(BACT.date_earned, 'YYYY')),
					floor(
						months_between(	BACT.date_earned,
								nvl(fnd_date.canonical_to_date(HROG.org_information11), trunc(BACT.date_earned, 'YYYY')))
					/ 12) * 12)	start_date
			from	hr_organization_information	HROG,
				pay_payroll_actions		BACT,
				pay_assignment_actions		BAL_ASSACT
			where	BAL_ASSACT.assignment_action_id = assact_id
			and	BACT.payroll_action_id = BAL_ASSACT.payroll_action_id
			and	HROG.organization_id = BACT.business_group_id
			and	HROG.org_information_context = 'Business Group Information') V1,
		pay_assignment_actions	ASSACT,
		pay_payroll_actions	PACT,
		pay_run_results		RR,
		pay_run_result_values	TARGET,
		pay_balance_feeds_f	FEED
	WHERE	ASSACT.assignment_id = V1.assignment_id
	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
--	AND	ASSACT.action_sequence <= decode(V1.action_type,'N',ASSACT.action_sequence,V1.action_sequence)
/* --	AND	(	(V1.action_type = 'N')
--		or	(	V1.action_type <> 'N'
--			AND ASSACT.action_sequence <= NVL(V1.action_sequence,ASSACT.action_sequence))) */
	--
	-- The system guarantees assignment actions ordered by effective_date as sequential action,
	-- but does not guarantee actions ordered by date_earned as sequential action.
	--
	AND	PACT.date_earned >= V1.start_date
	AND	(	(	PACT.date_earned < V1.date_earned)
		or	(	PACT.date_earned = V1.date_earned
			and	ASSACT.action_sequence <= V1.action_sequence))
	AND	RR.assignment_action_id = ASSACT.assignment_action_id
	AND	RR.status IN ('P','PA')
	AND	TARGET.run_result_id = RR.run_result_id
	AND	nvl(TARGET.result_value, '0') <> '0'
	AND	FEED.input_value_id = TARGET.input_value_id
	AND	FEED.balance_type_id = baltype
	AND	PACT.date_earned
		BETWEEN	FEED.effective_start_date AND FEED.effective_end_date;
BEGIN
--l_balance := 0;
--l_defined_balance_id := PAY_JP_BALANCE_PKG.GET_DEFINED_BALANCE_ID(p_balance_type_id,p_assignment_action_id);
--
--IF l_defined_balance_id is not null THEN
--	FOR c_assignment_action_id IN csr_assignment_action_id(p_assignment_action_id, p_balance_type_id) LOOP
--	 	l_balance := l_balance + pay_balance_pkg.get_value(l_defined_balance_id, c_assignment_action_id.assignment_action_id);
--	END LOOP;
--ELSE
	open csr_balance(p_assignment_action_id, p_balance_type_id);
	fetch csr_balance into l_balance;
	close csr_balance;
--END IF;
--
RETURN l_balance;
END asg_fytd_jp;
--
/* ------------------------------------------------------------------------------------
-- RETRO_JP
-- The calculation of this dimension should be included in hr_routes.
-- General function for accumulating a balance using assignment_action_id
-- Actually, this function will not be used
-- because user does not need to know the calculated value.
-- ------------------------------------------------------------------------------------ */
FUNCTION retro_jp(
	p_assignment_action_id	IN NUMBER,
	p_balance_type_id	IN NUMBER)	-- balance
RETURN NUMBER
IS
l_defined_balance_id 	PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
l_balance		NUMBER;
--
BEGIN
--
l_defined_balance_id := PAY_JP_BALANCE_PKG.GET_DEFINED_BALANCE_ID(p_balance_type_id,p_assignment_action_id);

IF l_defined_balance_id is not null THEN
	l_balance := pay_balance_pkg.get_value(l_defined_balance_id, p_assignment_action_id);
-- Removed csr_balance cursor as _ASG_RETRO_RUN balance dimension
-- would not be available in R12, so the code related to it has been
-- obsoleted. Commented the below code as per Bug# 5033803.
/*
ELSE
	open csr_balance(p_assignment_action_id, p_balance_type_id);
	fetch csr_balance into l_balance;
	close csr_balance;
*/
END IF;
--
RETURN l_balance;
END retro_jp;
--
END hr_jprts;

/
