--------------------------------------------------------
--  DDL for Package Body PAY_JP_RETRO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_RETRO_PKG" as
/* $Header: pyjpretr.pkb 120.3 2005/11/16 23:47:48 keyazawa noship $ */
--------------------------------------------------------------------------------
	g_assignment_id 	number;
	g_effective_date 	date;
	g_assignment_action_id 	number;
--
	g_sal3_diff		number;
	g_sal2_diff		number;
	g_sal1_diff		number;
	g_sal3_paid		number;
	g_sal2_paid		number;
	g_sal1_paid		number;
	g_material3_diff	number;
	g_material2_diff	number;
	g_material1_diff	number;
	g_material3_paid	number;
	g_material2_paid	number;
	g_material1_paid	number;
--	In current version of "Retro pay by action" only supports UOM="Money".
--	That is, it's impossible to backpay UOM="Number".
--	g_payment_days3_diff	number;
--	g_payment_days2_diff	number;
--	g_payment_days1_diff	number;
--	g_payment_days3_paid	number;
--	g_payment_days2_paid	number;
--	g_payment_days1_paid	number;
--	No need to backpay fixed salary.
--	g_fixed_sal3_diff	number;
--	g_fixed_sal2_diff	number;
--	g_fixed_sal1_diff	number;
--	g_fixed_sal3_paid	number;
--	g_fixed_sal2_paid	number;
--	g_fixed_sal1_paid	number;
	g_retro_diff_value	number;
--
--	Modified length for UTF8.
--	g_sal 			varchar2(30);
--	g_material		varchar2(30);
	g_sal 			varchar2(40);
	g_material		varchar2(40);
--	g_payment_days		varchar2(30);
--	g_fixed_sal		varchar2(30);

--
	g_id_fetched		BOOLEAN := FALSE;
--
	g_retro_paid3		number;
	g_retro_paid2		number;
	g_retro_paid1		number;

	g_sal_id          number := hr_jp_id_pkg.balance_type_id('B_COM_SAN_GEP_SAL_ERN_MONEY', null, 'JP');
	g_material_id     number := hr_jp_id_pkg.balance_type_id('B_COM_SAN_GEP_SAL_ERN_KIND', null, 'JP');
--	g_payment_days_id number := hr_jp_id_pkg.balance_type_id('B_COM_SAN_GEP_PAY_BASE_DAYS', null, 'JP');
--	g_fixed_sal_id    number := hr_jp_id_pkg.balance_type_id('B_GEP_FIXED_WAGE', null, 'JP');

-------------------------------------------------------------
	FUNCTION get_retropayments(
-------------------------------------------------------------
		p_assignment_id 	number,
		p_date_earned 		date)
	RETURN number
	IS
	        l_apply_mth_3			varchar2(7);
	        l_apply_mth_2			varchar2(7);
	        l_apply_mth_1			varchar2(7);
	        p_apply_mth			varchar2(7);
	        l_start_gtr			date;
	        l_end_gtr			date;
		l_return_flg			number;
--		l_min_sal_action_seq		number;
--		l_min_material_action_seq	number;
--		l_min_action_seq		number;
		l_min_effective_date		date;

--
		--cursor csr_sg_sal_si is
		--	select balance_type_id
		--	from pay_balance_types
		--	where balance_name = g_sal;
		--cursor csr_sg_sal_material_si is
		--	select balance_type_id
		--	from pay_balance_types
		--	where balance_name = g_material;
--	        --cursor csr_sg_payment_days is
--	        --        select balance_type_id
--	        --        from pay_balance_types
--	        --        where balance_name = g_payment_days;
--	        --cursor csr_sg_fixed_sal is
--	        --        select balance_type_id
--	        --        from pay_balance_types
--	        --        where balance_name = g_fixed_sal;
	BEGIN
		p_apply_mth	:= to_char(p_date_earned, 'YYYY-MM');
		l_apply_mth_3	:= to_char(add_months(p_date_earned, -3), 'YYYY-MM');
		l_apply_mth_2	:= to_char(add_months(p_date_earned, -2), 'YYYY-MM');
		l_apply_mth_1	:= to_char(add_months(p_date_earned, -1), 'YYYY-MM');
		l_start_gtr	:= add_months(p_date_earned, -3);
		l_end_gtr	:= last_day(add_months(p_date_earned, -1));

		--if not g_id_fetched then
			--open csr_sg_sal_si;
			--fetch csr_sg_sal_si into g_sal_id;
			--close csr_sg_sal_si;

			--open csr_sg_sal_material_si;
			--fetch csr_sg_sal_material_si into g_material_id;
			--close csr_sg_sal_material_si;

--			--open csr_sg_payment_days;
--			--fetch csr_sg_payment_days into g_payment_days_id;
--			--close csr_sg_payment_days;

--			--open csr_sg_fixed_sal;
--			--fetch csr_sg_fixed_sal into g_fixed_sal_id;
--			--close csr_sg_fixed_sal;

		--	g_id_fetched := TRUE;
		--end if;

/*
		dbms_output.put_line('g_sal_id : '||g_sal_id);
		dbms_output.put_line('g_material_id : '||g_material_id);
		dbms_output.put_line('g_payment_days_id : '||g_payment_days_id);
		dbms_output.put_line('g_fixed_sal_id : '||g_fixed_sal_id);
*/
--
--
-- calculate the adjustments to the balance this is made up of 2 figures
--      1. what retropayments have been made by other runs that should
--         should have been paid on this run
--      2  minus retropayments paid in this run that should have been
--         paid on another run - note these are not just excluded they are
--         extra negative adjustments that need to be applied to the
--         unadjusted balance to arrive at an adjusted balance
--      we achieve this in a single select for performance reasons. The
--      decode implements the complex rules saying
--              is it for this balance
--                      is it for this month
--                              is it plus or minus
--      BACT payroll action where the money should have been earned
--      PACT Payroll action where the money was earned
--      PEE  element entry for the retropay element
--      One rule that is true for Geppen/Santei and not true for
--      ASG_RETRO_RUN is that we don't include retropayments paid
--      later that should have been paid in this period. These
--      are excluded in the where clause(i.e. no retro-Geppen)


    SELECT /*+ ORDERED
               INDEX(BACT_ASSACT PAY_ASSIGNMENT_ACTIONS_N1)
               INDEX(PEPD PAY_ENTRY_PROCESS_DETAILS_FK2)
               INDEX(BACT PAY_PAYROLL_ACTIONS_PK)
               INDEX(RR PAY_RUN_RESULTS_N51)
               INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS_PK)
               INDEX(PACT PAY_PAYROLL_ACTIONS_PK)
               INDEX(PEE PAY_ELEMENT_ENTRIES_F_PK)
               INDEX(TARGET PAY_RUN_RESULT_VALUES_N50)
               INDEX(FEED PAY_BALANCE_FEEDS_F_N2) */
           -- retro salary diff(adjusted amount to pay actually)
           -- = retro salary to pay at target month(BACT) - retro salary paid at target month(PACT)
           nvl(sum(decode(FEED.balance_type_id,
             g_sal_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * (decode(to_char(BACT.effective_date,'YYYY-MM'),l_apply_mth_3,1,0)
                 + decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_3,-1,0)))),0),
           nvl(sum(decode(FEED.balance_type_id,
             g_sal_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * (decode(to_char(BACT.effective_date,'YYYY-MM'),l_apply_mth_2,1,0)
                 + decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_2,-1,0)))),0),
           nvl(sum(decode(FEED.balance_type_id,
             g_sal_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * (decode(to_char(BACT.effective_date,'YYYY-MM'),l_apply_mth_1,1,0)
                 + decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_1,-1,0)))),0),
           -- retro salary paid(actual paid retro salary at the month)(PACT)
           nvl(sum(decode(FEED.balance_type_id,
             g_sal_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_3,1))),0),
           nvl(sum(decode(FEED.balance_type_id,
             g_sal_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_2,1))),0),
           nvl(sum(decode(FEED.balance_type_id,
             g_sal_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_1,1))),0),
           -- retro salary materials diff
           -- = retro salary to pay at target month(BACT) - retro salary paid at target month(PACT)
           nvl(sum(decode(FEED.balance_type_id,
             g_material_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * (decode(to_char(BACT.effective_date,'YYYY-MM'),l_apply_mth_3,1,0)
                 + decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_3,-1,0)))),0),
           nvl(sum(decode(FEED.balance_type_id,
             g_material_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * (decode(to_char(BACT.effective_date,'YYYY-MM'),l_apply_mth_2,1,0)
                 + decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_2,-1,0)))),0),
           nvl(sum(decode(FEED.balance_type_id,
             g_material_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * (decode(to_char(BACT.effective_date,'YYYY-MM'),l_apply_mth_1,1,0)
                 + decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_1,-1,0)))),0),
           -- retro salary materials paid(actual paid retro salary at the month)(PACT)
           nvl(sum(decode(FEED.balance_type_id,
             g_material_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_3,1))),0),
           nvl(sum(decode(FEED.balance_type_id,
             g_material_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_2,1))),0),
           nvl(sum(decode(FEED.balance_type_id,
             g_material_id,fnd_number.canonical_to_number(TARGET.result_value)
               * FEED.scale
               * decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_1,1))),0),
           -- Minimum Action Sequence of Retro assact(not Target assact)
           min(decode(balance_type_id, g_sal_id, BACT.effective_date, g_material_id, BACT.effective_date)),
           -- exists check for retro salary paid (paid retro salary at the month)(PACT)
           nvl(sum(decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_3,1)),0),
           nvl(sum(decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_2,1)),0),
           nvl(sum(decode(to_char(PACT.effective_date,'YYYY-MM'),l_apply_mth_1,1)),0)
    INTO   g_sal3_diff,
           g_sal2_diff,
           g_sal1_diff,
           g_sal3_paid,
           g_sal2_paid,
           g_sal1_paid,
           g_material3_diff,
           g_material2_diff,
           g_material1_diff,
           g_material3_paid,
           g_material2_paid,
           g_material1_paid,
           l_min_effective_date,
           g_retro_paid3,
           g_retro_paid2,
           g_retro_paid1
    -- 1) pay_element_entries_f.source_id is no index so that all query cause bad performance. reject.
    --   target assact(use assignment_id)
    --   target pact(use effective_date)
    --   target result(use status)
    --   retro entries(use creator_type,entry_type)
    --   retro assact
    --   retro pact
    --   target result value
    --   target feed(use balance_type_id)
    -- 2) probably this way will perform better.
    --   retro entries(use assignment_id,creator_type,entry_type)
    --   target result(use status)
    --   target assact
    --   target pact(use effective_date)
    --   retro assact
    --   retro pact
    --   target result value
    --   target feed(use balance_type_id)
    FROM   pay_assignment_actions    BACT_ASSACT, -- retro assact
           pay_entry_process_details PEPD,        -- retro entries
           pay_payroll_actions       BACT,        -- retro pact
           pay_run_results           RR,          -- target result
           pay_assignment_actions    ASSACT,      -- target assact
           pay_payroll_actions       PACT,        -- target pact
           pay_element_entries_f     PEE,         -- retro element entries
           pay_run_result_values     TARGET,      -- target result value
           pay_balance_feeds_f       FEED
    WHERE  BACT_ASSACT.assignment_id = p_assignment_id
    and    PEPD.source_asg_action_id = BACT_ASSACT.assignment_action_id
    and    BACT.payroll_action_id = BACT_ASSACT.payroll_action_id
    and    RR.source_id = PEPD.element_entry_id
    and    RR.status in ('P','PA')
    and    ASSACT.assignment_action_id = RR.assignment_action_id
    and    PACT.payroll_action_id = ASSACT.payroll_action_id
    and    PACT.effective_date
           between l_start_gtr and l_end_gtr
    and    PEE.element_entry_id = PEPD.element_entry_id
    and    PACT.date_earned
           between PEE.effective_start_date and PEE.effective_end_date
    and    TARGET.run_result_id = RR.run_result_id
    and    nvl(TARGET.result_value,'0') <> '0'
    and    FEED.input_value_id = TARGET.input_value_id
    and    FEED.balance_type_id in (g_sal_id, g_material_id)
    and    PACT.effective_date
           between FEED.effective_start_date and FEED.effective_end_date;

		l_return_flg := 0;

		if l_min_effective_date is not NULL then

      SELECT /*+ ORDERED
                 INDEX(BACT_ASSACT PAY_ASSIGNMENT_ACTIONS_N1)
                 INDEX(PEPD PAY_ENTRY_PROCESS_DETAILS_FK2)
                 INDEX(BACT PAY_PAYROLL_ACTIONS_PK)
                 INDEX(RR PAY_RUN_RESULTS_N51)
                 INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS_PK)
                 INDEX(PACT PAY_PAYROLL_ACTIONS_PK)
                 INDEX(PEE PAY_ELEMENT_ENTRIES_F_PK)
                 INDEX(TARGET PAY_RUN_RESULT_VALUES_N50)
                 INDEX(FEED PAY_BALANCE_FEEDS_F_N2) */
             nvl(sum(fnd_number.canonical_to_number(target.result_value)),0)
      INTO   g_retro_diff_value
      FROM   pay_assignment_actions    BACT_ASSACT,
             pay_entry_process_details PEPD,
             pay_payroll_actions       BACT,
             pay_run_results           RR,
             pay_assignment_actions    ASSACT,
             pay_payroll_actions       PACT,
             pay_element_entries_f     PEE,
             pay_run_result_values     TARGET,
             pay_balance_feeds_f       FEED
      WHERE  BACT_ASSACT.assignment_id = p_assignment_id
      and    PEPD.source_asg_action_id = BACT_ASSACT.assignment_action_id
      and    BACT.payroll_action_id = BACT_ASSACT.payroll_action_id
      and    to_char(BACT.effective_date,'YYYYMM')=to_char(l_min_effective_date,'YYYYMM')
      and    RR.source_id = PEPD.element_entry_id
      and    RR.status in ('P','PA')
      and    ASSACT.assignment_action_id = RR.assignment_action_id
      and    PACT.payroll_action_id = ASSACT.payroll_action_id
      and    PACT.effective_date
             between l_start_gtr and l_end_gtr
      and    PEE.element_entry_id = PEPD.element_entry_id
      and    PACT.date_earned
             between PEE.effective_start_date and PEE.effective_end_date
      and    TARGET.run_result_id = RR.run_result_id
      and    nvl(TARGET.result_value,'0') <> '0'
      and    FEED.input_value_id = TARGET.input_value_id
      and    FEED.balance_type_id in (g_sal_id, g_material_id)
      and    PACT.effective_date
             between FEED.effective_start_date and FEED.effective_end_date;

		else
			g_retro_diff_value := 0;
		end if;

		return l_return_flg;
	END;


--
--    GET_PLSQL_GLOBAL
--    retrieve a PLSQL global from the session
--
-------------------------------------------------------------
	FUNCTION GET_PLSQL_GLOBAL(
-------------------------------------------------------------
		p_global_name	in varchar2,
		p_mth_ago	in number,
		p_type		in varchar2 )
		-- p_type('DIFF', 'PAID', 'SUPPOSED')
	RETURN number is
		l_value number;

		cursor csr_sg_sal is
			select balance_name
			from pay_balance_types
			where balance_type_id = g_sal_id;
		cursor csr_sg_sal_material is
			select balance_name
			from pay_balance_types
			where balance_type_id = g_material_id;
--	        --cursor csr_sg_payment_days is
--	        --        select balance_name
--	        --        from pay_balance_types
--	        --        where balance_type_id = g_payment_days_id;
--	        --cursor csr_sg_fixed_sal is
--	        --        select balance_name
--	        --        from pay_balance_types
--	        --        where balance_type_id = g_fixed_sal_id;
	BEGIN
		l_value := 0;

		if not g_id_fetched then
			open csr_sg_sal;
			fetch csr_sg_sal into g_sal;
			close csr_sg_sal;

			open csr_sg_sal_material;
			fetch csr_sg_sal_material into g_material;
			close csr_sg_sal_material;

--			open csr_sg_payment_days;
--			fetch csr_sg_payment_days into g_payment_days;
--			close csr_sg_payment_days;

--			open csr_sg_fixed_sal;
--			fetch csr_sg_fixed_sal into g_fixed_sal;
--			close csr_sg_fixed_sal;

			g_id_fetched := TRUE;
		end if;

		if p_global_name = g_sal then
			if p_type = 'DIFF' then
				if p_mth_ago = 1 then
					l_value := g_sal1_diff;
				elsif p_mth_ago = 2 then
					l_value := g_sal2_diff;
				elsif p_mth_ago = 3 then
					l_value := g_sal3_diff;
				end if;
			elsif p_type = 'PAID' then
				if p_mth_ago = 1 then
					l_value := g_sal1_paid;
				elsif p_mth_ago = 2 then
					l_value := g_sal2_paid;
				elsif p_mth_ago = 3 then
					l_value := g_sal3_paid;
				end if;
			end if;
		elsif p_global_name = g_material then
			if p_type = 'DIFF' then
				if p_mth_ago = 1 then
					l_value := g_material1_diff;
				elsif p_mth_ago = 2 then
					l_value := g_material2_diff;
				elsif p_mth_ago = 3 then
					l_value := g_material3_diff;
				end if;
			elsif p_type = 'PAID' then
				if p_mth_ago = 1 then
					l_value := g_material1_paid;
				elsif p_mth_ago = 2 then
					l_value := g_material2_paid;
				elsif p_mth_ago = 3 then
					l_value := g_material3_paid;
				end if;
			end if;
--		elsif p_global_name = g_payment_days then
--			if p_type = 'DIFF' then
--				if p_mth_ago = 1 then
--					l_value := g_payment_days1_diff;
--				elsif p_mth_ago = 2 then
--					l_value := g_payment_days2_diff;
--				elsif p_mth_ago = 3 then
--					l_value := g_payment_days3_diff;
--				end if;
--			elsif p_type = 'PAID' then
--				if p_mth_ago = 1 then
--					l_value := g_payment_days1_paid;
--				elsif p_mth_ago = 2 then
--					l_value := g_payment_days2_paid;
--				elsif p_mth_ago = 3 then
--					l_value := g_payment_days3_paid;
--				end if;
--			end if;
--		elsif p_global_name = g_fixed_sal then
--			if p_type = 'DIFF' then
--				if p_mth_ago = 1 then
--					l_value := g_fixed_sal1_diff;
--				elsif p_mth_ago = 2 then
--					l_value := g_fixed_sal2_diff;
--				elsif p_mth_ago = 3 then
--					l_value := g_fixed_sal3_diff;
--				end if;
--			elsif p_type = 'PAID' then
--				if p_mth_ago = 1 then
--					l_value := g_fixed_sal1_paid;
--				elsif p_mth_ago = 2 then
--					l_value := g_fixed_sal2_paid;
--				elsif p_mth_ago = 3 then
--					l_value := g_fixed_sal3_paid;
--				end if;
--			end if;
		end if;

		RETURN l_value ;
	END GET_PLSQL_GLOBAL;


-------------------------------------------------------------
	FUNCTION get_retro_mth(p_mth_ago in number)
-------------------------------------------------------------
	RETURN number is
		l_value number;
	BEGIN
		l_value := 0;

		if p_mth_ago = 1 then
			l_value := g_sal1_paid + g_material1_paid;
		elsif p_mth_ago = 2 then
			l_value := g_sal2_paid + g_material2_paid;
		elsif p_mth_ago = 3 then
			l_value := g_sal3_paid + g_material3_paid;
		end if;

		RETURN l_value ;
	END get_retro_mth;


-------------------------------------------------------------
	FUNCTION get_first_retro_amt
-------------------------------------------------------------
	RETURN number is
	BEGIN
		RETURN g_retro_diff_value;
	END get_first_retro_amt;


-------------------------------------------------------------
	FUNCTION get_first_retro_mth
-------------------------------------------------------------
	RETURN number is
		l_value number;
	BEGIN
		if g_retro_paid3 = 0 then
			if g_retro_paid2 = 0 then
				if g_retro_paid1 = 0 then
					l_value := 0;
				else
					l_value := 1;
				end if;
			else
				l_value := 2;
			end if;
		else
			l_value := 3;
		end if;

		RETURN l_value;
	END get_first_retro_mth;

/************************************************************
Following code is added by T.Tagawa
************************************************************/
-------------------------------------------------------------
	FUNCTION get_legislation_code(
-------------------------------------------------------------
			p_business_group_id	IN NUMBER)
	RETURN VARCHAR2
	IS
		l_legislation_code	PER_BUSINESS_GROUPS.legislation_code%TYPE;
		CURSOR csr_legislation_code IS
			select	org_information9
			from	hr_organization_information
			where	organization_id=p_business_group_id
			and	org_information_context='Business Group Information';
	BEGIN
		open csr_legislation_code;
		fetch csr_legislation_code into l_legislation_code;
		if csr_legislation_code%NOTFOUND then
			l_legislation_code := NULL;
		end if;
		close csr_legislation_code;

		return l_legislation_code;
	END get_legislation_code;

-------------------------------------------------------------
	FUNCTION get_defined_balance_id(
-------------------------------------------------------------
			p_business_group_id	IN NUMBER,
			p_item_name		IN VARCHAR2)
	RETURN NUMBER
	IS
		l_defined_balance_id	NUMBER;
		l_legislation_code	PER_BUSINESS_GROUPS.legislation_code%TYPE;
		cursor csr_defined_balance_id is
			select	UE.creator_id
			from	ff_user_entities	UE,
				ff_database_items	DI
			where	DI.user_name = p_item_name
			and	UE.user_entity_id = DI.user_entity_id
			and	UE.creator_type = 'B'
			and	nvl(UE.business_group_id,p_business_group_id) = p_business_group_id
			and	nvl(UE.legislation_code,l_legislation_code) = l_legislation_code;
	BEGIN
		l_legislation_code := get_legislation_code(p_business_group_id);
		open csr_defined_balance_id;
		fetch csr_defined_balance_id into l_defined_balance_id;
		if csr_defined_balance_id%NOTFOUND then
			l_defined_balance_id := NULL;
		end if;
		close csr_defined_balance_id;

		return l_defined_balance_id;
	END get_defined_balance_id;

-------------------------------------------------------------
	FUNCTION get_last_assact(
-------------------------------------------------------------
			p_assignment_id		IN NUMBER,
			p_effective_date_from	IN DATE,
			p_effective_date_to	IN DATE)
	RETURN NUMBER
	IS
		l_last_assact	NUMBER;
		CURSOR csr_last_assact IS
			select	paa.assignment_action_id
			from	pay_action_classifications	pac,
				pay_payroll_actions		ppa,
				pay_assignment_actions		paa
			where	paa.assignment_id=p_assignment_id
			and	ppa.payroll_action_id=paa.payroll_action_id
			and	ppa.effective_date
				between p_effective_date_from and p_effective_date_to
			and	pac.action_type= ppa.action_type
			and	pac.classification_name='SEQUENCED'
			order by paa.action_sequence desc;
	BEGIN
		open csr_last_assact;
		fetch csr_last_assact into l_last_assact;
		if csr_last_assact%NOTFOUND then
			l_last_assact := -1;
		end if;
		close csr_last_assact;

		return l_last_assact;
	END get_last_assact;

/**************************************************************************
 Contents        : BALANCE_FETCH - get a balance at a specified date

 Date        Name            Vers     Bug No   Description
 -----------+---------------+--------+--------+-----------------------+
 21-Jan-1997   ASnell        1                 created
 -----------+---------------+--------+--------+-----------------------+
 --
 --------------------------------------------------------------------------------
                                                                              --
                          BALANCE FETCH                                       --
 cover for PLS balance user exit so it can be called from formula to
 evaluate balances at a date other than the effective date of the payroll run
 parameters:  	assignment_id	formula context
		item_name       database item name for defined balance
 		effective_date  date to evaluate balance for
--                                                                            --
****************************************************************************/
-------------------------------------------------------------
	FUNCTION balance_fetch (
-------------------------------------------------------------
			p_assignment_id		in number,
			p_item_name		in varchar2,
			p_effective_date	in date )
	return number is
		cursor csr_defined_balance is
			select	UE.creator_id
			from	ff_user_entities	UE,
				ff_database_items	DI
			where	DI.user_name = p_item_name
			and	UE.user_entity_id = DI.user_entity_id
			and	UE.creator_type = 'B';

		l_defined_balance_id	pay_defined_balances.defined_balance_id%type;
		g_message_text		varchar2(240);  -- make global
		l_balance		number;
		l_effective_date	date;
	begin
		open csr_defined_balance;
		fetch csr_defined_balance into l_defined_balance_id;
		if csr_defined_balance%notfound then
			close csr_defined_balance;
			g_message_text := 'Balance DB item does not exist';
			raise hr_utility.hr_error;
		end if;
		close csr_defined_balance;

		if p_effective_date is NULL then
			select	effective_date
			into	l_effective_date
			from	fnd_sessions
			where	session_id = userenv('sessionid');
		else
			l_effective_date := p_effective_date;
		end if;

		BEGIN
			l_balance := pay_balance_pkg.get_value(
						l_defined_balance_id,
						p_assignment_id,
						l_effective_date);
                EXCEPTION
			when NO_DATA_FOUND then
				l_balance := 0;
		END;

		return l_balance;
	end balance_fetch;

-------------------------------------------------------------
	FUNCTION get_balance_value(
-------------------------------------------------------------
			p_business_group_id	IN NUMBER,
			p_item_name		IN VARCHAR2,
			p_assignment_action_id	IN NUMBER)
	RETURN NUMBER
	IS
		l_defined_balance_id	NUMBER;
		l_balance_value		NUMBER;
	BEGIN
		l_balance_value := 0;

		if p_assignment_action_id > 0 then
			l_defined_balance_id := get_defined_balance_id(p_business_group_id,p_item_name);

			if l_defined_balance_id is not NULL then
				BEGIN
					l_balance_value := pay_balance_pkg.get_value(
									P_DEFINED_BALANCE_ID	=> l_defined_balance_id,
									P_ASSIGNMENT_ACTION_ID	=> p_assignment_action_id);
		                EXCEPTION
					when NO_DATA_FOUND then
						l_balance_value := 0;
				END;
			end if;
		end if;

		return l_balance_value;
	END get_balance_value;

END pay_jp_retro_pkg;

/
