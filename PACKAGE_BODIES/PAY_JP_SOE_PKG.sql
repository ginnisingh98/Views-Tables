--------------------------------------------------------
--  DDL for Package Body PAY_JP_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_SOE_PKG" AS
/* $Header: pyjpsoe.pkb 120.3 2006/12/11 07:29:13 ttagawa noship $ */
--
-- Constants
--
c_nonres	CONSTANT VARCHAR2(80) := 'Non Resident';
--
-- Global variables.
--
TYPE id_t IS RECORD(
	SAL_ITAX_CATEGORY_IV		NUMBER,
	SAL_NR_ITAX_IV			NUMBER,
	BON_ITAX_CATEGORY_IV		NUMBER,
	BON_NR_ITAX_IV			NUMBER,
	SP_BON_ITAX_CATEGORY_IV		NUMBER,
	SP_BON_NR_ITAX_IV		NUMBER,
	YEA_ITAX_CATEGORY_IV		NUMBER,
	YEA_CATEGORY_IV			NUMBER);
/*
	--
	-- Only Resident balances except for allowance balance.
	--
	SAL_ALLOWANCE_BAL		NUMBER,
	SAL_SAL_TAXABLE_BAL		NUMBER,
	SAL_MAT_TAXABLE_BAL		NUMBER,
	BON_ALLOWANCE_BAL		NUMBER,
	BON_SAL_TAXABLE_BAL		NUMBER,
	BON_MAT_TAXABLE_BAL		NUMBER,
	SP_BON_ALLOWANCE_BAL		NUMBER,
	SP_BON_SAL_TAXABLE_BAL		NUMBER,
	SP_BON_MAT_TAXABLE_BAL		NUMBER,
	SI_PREM_BAL			NUMBER,
	ITAX_BAL			NUMBER,
	YEA_ITAX_BAL			NUMBER);
*/
g_id			id_t;
g_defined_balance_lst	pay_balance_pkg.t_balance_value_tab;
-------------------------------------------------------------------------------
FUNCTION messages_exist_flag(
	p_source_id		IN NUMBER,
	p_source_type		IN VARCHAR2) RETURN VARCHAR2
-------------------------------------------------------------------------------
-- Returns 'Y' or 'N' which indicates message lines exist or not in
-- PAY_MESSAGE_LINES table. In most environment, you would specify
-- p_source_type = 'A' when source_id means assignment_action_id.
-------------------------------------------------------------------------------
IS
	l_messages_exist	VARCHAR2(1);
	CURSOR csr_messages_exist IS
		select	'Y'
		from	dual
		where	exists(
				select	NULL
				from	pay_message_lines	pml
				where	pml.source_id = p_source_id
				and	pml.source_type = p_source_type);
BEGIN
	open csr_messages_exist;
	fetch csr_messages_exist into l_messages_exist;
	if csr_messages_exist%NOTFOUND then
		l_messages_exist := 'N';
	end if;
	close csr_messages_exist;
	--
	-- Return value.
	--
	return l_messages_exist;
END messages_exist_flag;
-------------------------------------------------------------------------------
FUNCTION retro_entries_processed_flag(p_creator_id IN NUMBER) RETURN VARCHAR2
-------------------------------------------------------------------------------
-- Returns 'Y' or 'N' which indicates retro entries are processed or not by
-- subsequent assignment actions.
-- p_creator_id is assignment action with action_type = 'G'.
-- If one of entries created by retro assignment action is unprocessed,
-- this function returns 'N'.
-------------------------------------------------------------------------------
IS
	l_entries_processed	VARCHAR2(1);

	-- Added by Shashi
	-- This is used to check the applicability of Advanced Retropay at Business Group Level
	l_use_advanced_retropay HR_ORGANIZATION_INFORMATION.ORG_INFORMATION4%TYPE;

	CURSOR csr_retro_entries_processed IS
		select	'N'
		from	dual
		where	exists(
				select  1
				from	pay_run_results		prr,
					pay_element_entries_f	pee,
					pay_assignment_actions  paa
				where	pee.creator_id = p_creator_id
				and     paa.assignment_id = pee.assignment_id
				and     paa.assignment_action_id  = p_creator_id
				and	pee.creator_type = 'R'
				and	prr.source_id(+) = pee.element_entry_id
				--
				-- Necessary to specify source_type because source_type of
				-- reversal assignment action means source run_result_id.
				--
				and	prr.source_type(+) = 'E'
				and	nvl(prr.status,'U') = 'U'
				and     rownum =1);

	-- Below cursor is added to check the status of entry processing for Advanced Retropay.
	-- Added by Shashi on 4th April, 2005
	----------START-------------

	CURSOR csr_adv_ret_entries_processed IS
		select	'N'
		from	dual
		where	exists(
				select  1
				from	pay_run_results		prr,
					pay_element_entries_f	pee,
					pay_assignment_actions  paa
				where	pee.creator_id = p_creator_id
				and     paa.assignment_id = pee.assignment_id
				and     paa.assignment_action_id  = p_creator_id
				and	(pee.creator_type = 'RR' or pee.creator_type = 'EE')
				and	prr.source_id(+) = pee.element_entry_id
				--
				-- Necessary to specify source_type because source_type of
				-- reversal assignment action means source run_result_id.
				--
				and	prr.source_type(+) = 'E'
				and	nvl(prr.status,'U') = 'U'
				and     rownum =1);

	------------END-------------

BEGIN

		-- Below query is used to get the usage of advanced retropay at business group level.
		-- Added by Shashi on 4th April, 2005
		----------START-------------
		BEGIN

		  SELECT NVL(org.org_information4, 'N')
		  INTO   l_use_advanced_retropay
		  FROM   pay_assignment_actions paa,
		  			hr_organization_information org,
		  			per_all_assignments asg
		  WHERE  paa.assignment_action_id = p_creator_id
		  AND    paa.assignment_id = asg.assignment_id
		  AND    org.organization_id = asg.business_group_id
		  AND    org.org_information_context LIKE 'JP_BUSINESS_GROUP_INFO';

		EXCEPTION

		  WHEN NO_DATA_FOUND THEN

			l_use_advanced_retropay := 'N';
		  WHEN OTHERS THEN
		    hr_utility.set_location('Error in retro_entries_processed_flag',99);
		    raise;

		END;
		------------END-------------

    if l_use_advanced_retropay = 'N' then

		open csr_retro_entries_processed;
		fetch csr_retro_entries_processed into l_entries_processed;
		if csr_retro_entries_processed%NOTFOUND then
			l_entries_processed := 'Y';
		end if;
		close csr_retro_entries_processed;

    else

		open csr_adv_ret_entries_processed;
		fetch csr_adv_ret_entries_processed into l_entries_processed;
		if csr_adv_ret_entries_processed%NOTFOUND then
			l_entries_processed := 'Y';
		end if;
		close csr_adv_ret_entries_processed;

	end if;

	--
	-- Return value.
	--
	return l_entries_processed;
END retro_entries_processed_flag;
-------------------------------------------------------------------------------
FUNCTION entry_processed_flag(
	p_element_entry_id	IN NUMBER,
	p_effective_start_date	IN DATE,
	p_effective_end_date	IN DATE) RETURN VARCHAR2
-------------------------------------------------------------------------------
-- Returns 'Y' or 'N' which indicates specified entry is processed or not
-- in the period with PAY_PAYROLL_ACTIONS.effective_date between
-- p_effective_start_date and p_effective_end_date.
-- If the entry is processed once without reversal, then returns 'Y'.
-- Even if the entry is deleted, this function returns correct value.
-------------------------------------------------------------------------------
IS
	l_entry_processed	VARCHAR2(1);
	l_result_status		PAY_RUN_RESULTS.STATUS%TYPE;
	CURSOR csr_result_status IS
		select	prr.status
		from	pay_payroll_actions	ppa,
			pay_assignment_actions	paa,
			pay_run_results		prr
		where	prr.source_id = p_element_entry_id
		--
		-- Necessary to specify source_type because source_type of
		-- reversal assignment action means source run_result_id.
		--
		and	prr.source_type = 'E'
		and	paa.assignment_action_id = prr.assignment_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id
		and	ppa.effective_date
			between p_effective_start_date and p_effective_end_date
		and	not exists(
				select	NULL
				from	pay_run_results	prr2
				where	prr2.source_id = prr.run_result_id
				and	prr2.source_type = 'R')
		order by decode(prr.status,'U',1,2);
BEGIN
	open csr_result_status;
	fetch csr_result_status into l_result_status;
	if csr_result_status%NOTFOUND then
		l_entry_processed := 'N';
	else
		if l_result_status = 'U' then
			l_entry_processed := 'N';
		else
			l_entry_processed := 'Y';
		end if;
	end if;
	close csr_result_status;
	--
	-- Return value.
	--
	return l_entry_processed;
END entry_processed_flag;
-------------------------------------------------------------------------------
Function lock_action(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2) return lock_action_t
-------------------------------------------------------------------------------
-- p_locking_action_type allows the following values.
-- 'P','C','T','V','M'
-- In case of 'M', p_lock_action_id = locked pre_payment_id.
-------------------------------------------------------------------------------
Is
	Cursor csr_lock_action is
		select	paa.assignment_action_id,
			paa.action_status,
			paa.object_version_number,
			ppa.payroll_action_id,
			ppa.action_type,
			ppa.effective_date
		from	pay_payroll_actions		ppa,
			pay_assignment_actions		paa,
			pay_action_interlocks		pai
		where	pai.locked_action_id = p_locked_action_id
		and	paa.assignment_action_id = pai.locking_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id
		and	ppa.action_type = p_locking_action_type;
	Cursor csr_prepay_lock_action is
		select	paa.assignment_action_id,
			paa.action_status,
			paa.object_version_number,
			ppa.payroll_action_id,
			ppa.action_type,
			ppa.effective_date
		from	pay_payroll_actions		ppa,
			pay_assignment_actions		paa,
			pay_action_interlocks		pai
		where	pai.locked_action_id = p_locked_action_id
		and	paa.assignment_action_id = pai.locking_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id
		and	ppa.action_type in ('P','U');
	Cursor csr_payment_lock_action is
		select  /*+ ORDERED
                    INDEX(PAA PAY_ASSIGNMENT_ACTIONS_FK2)
                    INDEX(PPA PAY_PAYROLL_ACTIONS_PK) */
                paa.assignment_action_id,
			    paa.action_status,
			    paa.object_version_number,
			    ppa.payroll_action_id,
			    ppa.action_type,
			    ppa.effective_date
		from	pay_assignment_actions	paa,
			    pay_payroll_actions	ppa
		where	paa.pre_payment_id = p_locked_action_id
		and	    ppa.payroll_action_id = paa.payroll_action_id
		and	not exists(
				select  /*+ ORDERED
                            INDEX(PAI PAY_ACTION_INTERLOCKS_FK2)
                            INDEX(PAA2 PAY_ASSIGNMENT_ACTIONS_PK)
                            INDEX(PPA2 PAY_PAYROLL_ACTIONS_PK) */
                        NULL
				from	pay_action_interlocks	pai,
				    	pay_assignment_actions	paa2,
                        pay_payroll_actions	ppa2
				where	pai.locked_action_id = paa.assignment_action_id
				and     paa2.assignment_action_id = pai.locking_action_id
				and     ppa2.payroll_action_id = paa2.payroll_action_id
				and     ppa2.action_type = 'D');
	l_lock_action	lock_action_t;
Begin
	if p_locking_action_type = 'P' then
		open csr_prepay_lock_action;
		fetch csr_prepay_lock_action into l_lock_action;
		if csr_prepay_lock_action%NOTFOUND then
			l_lock_action := NULL;
		end if;
		close csr_prepay_lock_action;
	elsif p_locking_action_type = 'M' then
		open csr_payment_lock_action;
		fetch csr_payment_lock_action into l_lock_action;
		if csr_payment_lock_action%NOTFOUND then
			l_lock_action := NULL;
		end if;
		close csr_payment_lock_action;
	else
		open csr_lock_action;
		fetch csr_lock_action into l_lock_action;
		if csr_lock_action%NOTFOUND then
			l_lock_action := NULL;
		end if;
		close csr_lock_action;
	end if;

	return l_lock_action;
End lock_action;
-------------------------------------------------------------------------------
Function lock_status(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2) return lock_status_t
-------------------------------------------------------------------------------
-- p_locking_action_type allows the following values.
-- 'M','T'
-- This function never returns NULL.
-------------------------------------------------------------------------------
Is
	Cursor csr_lock_status is
		/* This select statement returns only 1 row. */
		select	decode(count(*),0,'U','C'),
			/* When not locked, that means the following statement returns no rows,
			   max(decode(paa.action_status,'C',NULL,'E',2,1)) returns NULL. */
			decode(max(decode(paa.action_status,'C',NULL,'E',2,1)),NULL,'C',1,'I','E')
		from	pay_payroll_actions		ppa,
			pay_assignment_actions		paa,
			pay_action_interlocks		pai
		where	pai.locked_action_id = p_locked_action_id
		and	paa.assignment_action_id = pai.locking_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id
		and	ppa.action_type = p_locking_action_type;
	Cursor csr_prepay_lock_status is
		/* This select statement returns only 1 row. */
		select	decode(count(decode(ppa2.payroll_action_id,NULL,paa.assignment_action_id,NULL)),count(distinct ppp.pre_payment_id),'C',0,'U','I'),
			decode(max(decode(decode(ppa2.payroll_action_id,NULL,paa.action_status,NULL),'C',NULL,NULL,NULL,'E',2,1)),NULL,'C',1,'I','E')
		from	pay_payroll_actions		ppa2,
			pay_assignment_actions		paa2,
			pay_action_interlocks		pai,
			pay_assignment_actions		paa,
			pay_pre_payments		ppp
		where	ppp.assignment_action_id = p_locked_action_id
		and	paa.pre_payment_id(+) = ppp.pre_payment_id
		/* "H"(Cheque) action can be locked by "D"(Void) only once. */
		and	pai.locked_action_id(+) = paa.assignment_action_id
		and	paa2.assignment_action_id(+) = pai.locking_action_id
		and	ppa2.payroll_action_id(+) = paa2.payroll_action_id
		and	ppa2.action_type(+) = 'D';
	l_lock_status	lock_status_t;
Begin
	if p_locked_action_id is NULL then
		l_lock_status.lock_status := 'U';
		l_lock_status.action_status := 'C';
	else
		if p_locking_action_type = 'M' then
			open csr_prepay_lock_status;
			fetch csr_prepay_lock_status into l_lock_status;
			close csr_prepay_lock_status;
		else
			open csr_lock_status;
			fetch csr_lock_status into l_lock_status;
			close csr_lock_status;
		end if;
	end if;

	return l_lock_status;
End lock_status;
-------------------------------------------------------------------------------
Function get_lock_action_val(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2,
	p_attribute		IN VARCHAR2) return VARCHAR2
-------------------------------------------------------------------------------
Is
	l_lock_action	lock_action_t;
	l_return_val	varchar2(30);
Begin
	l_lock_action := lock_action(
				p_locked_action_id,
				p_locking_action_type);

	if p_attribute = 'action_status' then
		l_return_val := l_lock_action.action_status;
	elsif p_attribute = 'action_type' then
		l_return_val := l_lock_action.action_type;
	else
		l_return_val := NULL;
	end if;

	return l_return_val;
end get_lock_action_val;
-------------------------------------------------------------------------------
Function get_lock_action_num(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2,
	p_attribute		IN VARCHAR2) return NUMBER
-------------------------------------------------------------------------------
Is
	l_lock_action	lock_action_t;
	l_return_num	number;
Begin
	l_lock_action := lock_action(
				p_locked_action_id,
				p_locking_action_type);

	if p_attribute = 'assignment_action_id' then
		l_return_num := l_lock_action.assignment_action_id;
	elsif p_attribute = 'object_version_number' then
		l_return_num := l_lock_action.object_version_number;
	elsif p_attribute = 'payroll_action_id' then
		l_return_num := l_lock_action.payroll_action_id;
	else
		l_return_num := NULL;
	end if;

	return l_return_num;
end get_lock_action_num;
-------------------------------------------------------------------------------
Function get_lock_status_val(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2,
	p_attribute		IN VARCHAR2) return VARCHAR2
-------------------------------------------------------------------------------
Is
	l_lock_action	lock_status_t;
	l_return_val	varchar2(30);
Begin
	l_lock_action := lock_status(
				p_locked_action_id,
				p_locking_action_type);

	if p_attribute = 'lock_status' then
		l_return_val := l_lock_action.lock_status;
	elsif p_attribute = 'action_status' then
		l_return_val := l_lock_action.action_status;
	else
		l_return_val := NULL;
	end if;

	return l_return_val;
end get_lock_status_val;
-------------------------------------------------------------------------------
FUNCTION get_effective_date(
        p_effective_date        IN DATE,
        p_assignment_id         IN NUMBER) RETURN DATE
-------------------------------------------------------------------------------
-- When a assignment exists in the year but does not exist on session_date,
-- nearest date ESD or EED will be returned to effective_date.
-------------------------------------------------------------------------------
IS
        CURSOR csr_get_effective_date IS
        select  nvl( nvl( min(decode(greatest(least(p_effective_date,paa.effective_end_date), paa.effective_start_date),p_effective_date,p_effective_date)),
                          max(decode(greatest(paa.effective_end_date,p_effective_date),p_effective_date,paa.effective_end_date))),
                     min(decode(least(p_effective_date, paa.effective_start_date),p_effective_date, paa.effective_start_date)) ) EFFECTIVE_DATE
        from    per_all_assignments_f paa
        where   to_number(to_char(p_effective_date, 'YYYY'))
                  between to_number(to_char(paa.effective_start_date, 'YYYY'))
                  and to_number(to_char(paa.effective_end_date, 'YYYY'))
        and     paa.assignment_id = p_assignment_id;
        l_effective_date DATE;
BEGIN
        OPEN csr_get_effective_date;
        FETCH csr_get_effective_date INTO l_effective_date;
        CLOSE csr_get_effective_date;

        RETURN l_effective_date;
END get_effective_date;
-------------------------------------------------------------------------------
PROCEDURE lock_row(
		p_assignment_action_id		IN NUMBER,
		p_object_version_number		IN NUMBER)
-------------------------------------------------------------------------------
-- This procedure locks pay_assignment_actions table for "ROLLBACK" or
-- "MARK FOR RETRY".
-------------------------------------------------------------------------------
IS
	l_object_version_number	NUMBER;
	CURSOR csr_obj IS
		select	paa.object_version_number
		from	pay_assignment_actions	paa
		where	paa.assignment_action_id=p_assignment_action_id
		for update;
BEGIN
	open csr_obj;
	fetch csr_obj into l_object_version_number;
	--
	-- If record not found, issue error "Record is deleted".
	--
	if csr_obj%NOTFOUND then
		close csr_obj;
		fnd_message.set_name('FND','FORM_RECORD_DELETED');
		fnd_message.raise_error;
	end if;
	close csr_obj;
	--
	-- If object_version_number is different, issue error "Record is changed".
	--
	if l_object_version_number <> p_object_version_number then
		fnd_message.set_name('FND','FORM_RECORD_CHANGED');
		fnd_message.raise_error;
	end if;
END lock_row;
-------------------------------------------------------------------------------
PROCEDURE rollback(
	p_validate		IN BOOLEAN DEFAULT FALSE,
	p_rollback_mode		IN VARCHAR2,
	p_assignment_action_id	IN NUMBER,
	p_payroll_action_id	IN NUMBER,
	p_action_type		IN VARCHAR2)
-------------------------------------------------------------------------------
-- Issue "ROLLBACK" or "MARK FOR RETRY" for specified assignment action.
-------------------------------------------------------------------------------
IS
	l_dml_mode	VARCHAR2(30);
	l_count		number;
BEGIN
	if p_validate then
		l_dml_mode := 'NONE';
	else
		l_dml_mode := 'NO_COMMIT';
	end if;
	--
	-- Issue "Rollback" process without commiting.
	-- 4615270
	-- Check whether only single assact exists or multiple assacts exist
	-- in current payroll_action_id.
	--
	select	count(*)
	into	l_count
	from	pay_assignment_actions
	where	payroll_action_id = p_payroll_action_id
	and	rownum <= 2;
	--
	-- Rollback/Mark for Retry at assignment action level
	-- when multiple assacts exist in current payroll_action_id.
	--
	if l_count > 1 then
		py_rollback_pkg.rollback_ass_action(
			p_assignment_action_id	=> p_assignment_action_id,
			p_rollback_mode		=> p_rollback_mode,
			p_leave_base_table_row	=> FALSE,
			p_all_or_nothing	=> TRUE,
			p_dml_mode		=> l_dml_mode,
			p_multi_thread		=> FALSE);
	--
	-- Rollback/Mark for Retry at payroll action level
	-- when single assact exists in current payroll_action_id.
	--
	else
		py_rollback_pkg.rollback_payroll_action(
			p_payroll_action_id	=> p_payroll_action_id,
			p_rollback_mode		=> p_rollback_mode,
			p_leave_base_table_row	=> FALSE,
			p_all_or_nothing	=> TRUE,
			p_dml_mode		=> l_dml_mode,
			p_multi_thread		=> FALSE);
	end if;
END rollback;
-------------------------------------------------------------------------------
PROCEDURE reverse_assact(
	p_assignment_action_id	IN NUMBER)
-------------------------------------------------------------------------------
-- Pay attention "Reversal" in this procedure do reverse assignment action
-- with the same payroll_id, consolidation_set_id and effective_date.
-------------------------------------------------------------------------------
IS
	CURSOR csr_assact IS
		select	pay_payroll_actions_s.nextval	PAYROLL_ACTION_ID,
			ppa.business_group_id,
			ppa.effective_date,
			ppa.date_earned,
			ppa.payroll_id,
			ppa.consolidation_set_id,
			ppa.time_period_id
		from	pay_payroll_actions	ppa,
			pay_assignment_actions	paa
		where	paa.assignment_action_id = p_assignment_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id;
	l_rec	csr_assact%ROWTYPE;
BEGIN
	open csr_assact;
	fetch csr_assact into l_rec;
	if csr_assact%NOTFOUND then
		close csr_assact;
	end if;
	close csr_assact;
	--
	-- Insert "Reversal" payroll action.
	--
	insert into pay_payroll_actions(
		PAYROLL_ACTION_ID,
		ACTION_TYPE,
		BUSINESS_GROUP_ID,
		EFFECTIVE_DATE,
		DATE_EARNED,
		PAYROLL_ID,
		CONSOLIDATION_SET_ID,
		TIME_PERIOD_ID,
		ACTION_POPULATION_STATUS,
		ACTION_STATUS,
		OBJECT_VERSION_NUMBER)
	values(	l_rec.payroll_action_id,
		'V',
		l_rec.business_group_id,
		l_rec.effective_date,
		l_rec.date_earned,
		l_rec.payroll_id,
		l_rec.consolidation_set_id,
		l_rec.time_period_id,
		'U',
		'U',
		1);
	--
	-- Main "Reversal" assignment action routine.
	--
	hrassact.reversal(l_rec.payroll_action_id, p_assignment_action_id);
END reverse_assact;
-------------------------------------------------------------------------------
-- This procedure collects balance values etc. without termination payment.
PROCEDURE run_attributes(
	p_assignment_action_id	IN NUMBER,
	p_itax_category		OUT NOCOPY VARCHAR2,
	p_d_itax_category	OUT NOCOPY VARCHAR2,
	p_yea_category		OUT NOCOPY VARCHAR2,
	p_d_yea_category	OUT NOCOPY VARCHAR2,
	p_allowance_ytd		OUT NOCOPY NUMBER,
	p_taxable_ytd		OUT NOCOPY NUMBER,
	p_si_prem_ytd		OUT NOCOPY NUMBER,
	p_itax_ytd		OUT NOCOPY NUMBER)
-------------------------------------------------------------------------------
IS
	l_salary_category	varchar2(30);
BEGIN
	--
	-- Get Income Tax Category and YEA Category.
	--
	pay_jp_custom_pkg.get_itax_category(
		P_ASSIGNMENT_ACTION_ID	=> p_assignment_action_id,
		P_SALARY_CATEGORY	=> l_salary_category,
		P_ITAX_CATEGORY		=> p_itax_category,
		P_ITAX_YEA_CATEGORY	=> p_yea_category);
	--
	-- Setup output variables.
	--
	if p_itax_category = 'NON_RES' then
		p_d_itax_category := c_nonres;
	else
		p_d_itax_category := hr_general.decode_lookup('JP_ITAX_TYPE', p_itax_category);
	end if;
	--
	p_d_yea_category := hr_general.decode_lookup('JP_YEA_PROCESS_STATUS', p_yea_category);
	--
	-- Reset balance values (this is optional operation).
	--
	for i in 1..g_defined_balance_lst.count loop
		g_defined_balance_lst(i).balance_value := 0;
	end loop;
	--
	-- Get balance values using "bulk" get_value.
	--
	pay_balance_pkg.get_value(
		P_ASSIGNMENT_ACTION_ID	=> p_assignment_action_id,
		P_DEFINED_BALANCE_LST	=> g_defined_balance_lst);
	--
	p_allowance_ytd := g_defined_balance_lst(1).balance_value;
	p_taxable_ytd	:= g_defined_balance_lst(2).balance_value
			 + g_defined_balance_lst(3).balance_value;
	p_si_prem_ytd	:= g_defined_balance_lst(4).balance_value;
	p_itax_ytd	:= g_defined_balance_lst(5).balance_value
			 + g_defined_balance_lst(6).balance_value;
END run_attributes;
-------------------------------------------------------------------------------
--
BEGIN
	--
	-- Package initialize routine.
	--
	-- Used to determine Income Tax Category.
	--
	g_id.SAL_ITAX_CATEGORY_IV	:= hr_jp_id_pkg.input_value_id(
									'SAL_ITX',
									'ITX_TYPE',NULL,'JP');
	g_id.SAL_NR_ITAX_IV		:= hr_jp_id_pkg.input_value_id(
									'SAL_ITX_NRES',
									'Pay Value',NULL,'JP');
	g_id.BON_ITAX_CATEGORY_IV	:= hr_jp_id_pkg.input_value_id(
									'BON_ITX',
									'ITX_TYPE',NULL,'JP');
	g_id.BON_NR_ITAX_IV		:= hr_jp_id_pkg.input_value_id(
									'BON_ITX_NRES',
									'Pay Value',NULL,'JP');
	g_id.SP_BON_ITAX_CATEGORY_IV	:= hr_jp_id_pkg.input_value_id(
									'SPB_ITX',
									'ITX_TYPE',NULL,'JP');
	g_id.SP_BON_NR_ITAX_IV		:= hr_jp_id_pkg.input_value_id(
									'SPB_ITX_NRES',
									'Pay Value',NULL,'JP');
	g_id.YEA_ITAX_CATEGORY_IV	:= hr_jp_id_pkg.input_value_id(
									'YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT',
									'ITX_TYPE',NULL,'JP');
	g_id.YEA_CATEGORY_IV		:= hr_jp_id_pkg.input_value_id(
									'YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT',
									'INCLUDE_FLAG',NULL,'JP');
	--
	-- Currently there's no exact way to distinguish Resident or Nonresident
	-- (when Itax element is not assigned to a assignment). So need to fetch
	-- not only Resident balances but also Non-resident balances.
	-- Pay attention Termination Payment is not included.
	--
	-- Only Resident balances except for allowance balance.
	--
	g_defined_balance_lst(1).defined_balance_id := hr_jp_id_pkg.defined_balance_id('B_YEA_ERN',		'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01', null, 'JP');
	g_defined_balance_lst(2).defined_balance_id := hr_jp_id_pkg.defined_balance_id('B_YEA_TXBL_ERN_MONEY',	'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01', null, 'JP');
	g_defined_balance_lst(3).defined_balance_id := hr_jp_id_pkg.defined_balance_id('B_YEA_TXBL_ERN_KIND',	'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01', null, 'JP');
	g_defined_balance_lst(4).defined_balance_id := hr_jp_id_pkg.defined_balance_id('B_YEA_SAL_DCT_SI_PREM','_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01', null, 'JP');
	g_defined_balance_lst(5).defined_balance_id := hr_jp_id_pkg.defined_balance_id('B_YEA_WITHHOLD_ITX',	'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01', null, 'JP');
	g_defined_balance_lst(6).defined_balance_id := hr_jp_id_pkg.defined_balance_id('B_YEA_TAX_PAY',	'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01', null, 'JP');
END pay_jp_soe_pkg;

/
