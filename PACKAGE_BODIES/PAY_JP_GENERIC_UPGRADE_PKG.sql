--------------------------------------------------------
--  DDL for Package Body PAY_JP_GENERIC_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_GENERIC_UPGRADE_PKG" as
/* $Header: pyjpgupg.pkb 120.14.12010000.2 2009/07/08 09:17:45 keyazawa ship $ */
--
-- Constants
--
c_package	constant varchar2(31) := 'pay_jp_generic_upgrade_pkg.';
type t_numbers is table of number index by binary_integer;
--
-- Global Variables
--
g_num_errors		number := 0;
g_element_type_ids	t_numbers;
--
g_debug boolean := hr_utility.debug_enabled;
--
-- |-------------------------------------------------------------------|
-- |----------------------< get_upgrade_status >-----------------------|
-- |-------------------------------------------------------------------|
function get_upgrade_status(
	p_upgrade_short_name	in varchar2,
	p_legislation_code	in varchar2) return varchar2
is
	l_upgrade_status	pay_upgrade_status.status%type;
	--
	cursor csr_upgrade_status is
		select	status
		from	pay_upgrade_status	s,
			pay_upgrade_definitions	d
		where	d.short_name = p_upgrade_short_name
		and	s.upgrade_definition_id = d.upgrade_definition_id
--		and	s.business_group_id is null
		and	s.legislation_code = p_legislation_code;
begin
	open csr_upgrade_status;
	fetch csr_upgrade_status into l_upgrade_status;
	if csr_upgrade_status%notfound then
		l_upgrade_status := null;
	end if;
	close csr_upgrade_status;
	--
	return l_upgrade_status;
end get_upgrade_status;
-- |-------------------------------------------------------------------|
-- |---------------------< get_business_group_id >---------------------|
-- |-------------------------------------------------------------------|
function get_business_group_id(p_legislation_code in varchar2) return varchar2
is
	l_business_group_id	number;
	--
	-- Do not use per_business_groups_perf which does not return
	-- "Disabled" business groups.
	--
	cursor csr_bg is
		select	organization_id
		from	hr_organization_information
		where	org_information_context = 'Business Group Information'
		and	org_information9 = p_legislation_code
		and	rownum = 1;
begin
	open csr_bg;
	fetch csr_bg into l_business_group_id;
	if csr_bg%notfound then
		l_business_group_id := null;
	end if;
	close csr_bg;
	--
	return l_business_group_id;
end get_business_group_id;
/*
-- |-------------------------------------------------------------------|
-- |---------------------< set_upgrade_completed >---------------------|
-- |-------------------------------------------------------------------|
procedure set_upgrade_completed(
	p_upgrade_short_name	in varchar2,
	p_legislation_code	in varchar2)
is
begin
	--
	-- Do not set status to "Completed" directly which will fail.
	-- At first "Processing" then "Completed".
	--
	hr_update_utility.setUpdateProcessing(
		p_update_name		=> p_upgrade_short_name,
		p_business_group_id	=> null,
		p_legislation_code	=> p_legislation_code);
	hr_update_utility.setUpdateComplete(
		p_update_name		=> p_upgrade_short_name,
		p_business_group_id	=> null,
		p_legislation_code	=> p_legislation_code);
end set_upgrade_completed;
*/
-- |-------------------------------------------------------------------|
-- |--------------------< validate_pay_jp_pre_tax >--------------------|
-- |-------------------------------------------------------------------|
procedure validate_pay_jp_pre_tax(p_valid_upgrade out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'validate_pay_jp_pre_tax';
	--
	cursor csr_exists is
	/*	Obsoleted for performance reasons
	        select	'TRUE'
		from	dual
		where	exists(
				select	null
				from	pay_jp_pre_tax		ppt,
					pay_assignment_actions	paa
				where	paa.action_status = 'C'
				and	ppt.assignment_action_id = paa.assignment_action_id
				and	ppt.action_status = 'C'); */
/*
		--Bug 4256063---
		 select  'TRUE'
		 from  pay_jp_pre_tax    ppt,
		       pay_assignment_actions  paa
		 where paa.action_status = 'C'
		   and ppt.assignment_action_id = paa.assignment_action_id
		   and ppt.action_status = 'C'
		   and rownum =1 ;
*/
                 select 'TRUE'
                 from   pay_action_information  pai,
                        pay_assignment_actions  paa
                 where  paa.action_status = 'C'
                 and    pai.action_information_category = 'JP_PRE_TAX_1'
                 and    pai.action_context_type = 'AAP'
                 and    pai.action_information1 = paa.assignment_action_id
                 and    rownum =1 ;

begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_exists;
	fetch csr_exists into p_valid_upgrade;
	if csr_exists%notfound then
		p_valid_upgrade := 'FALSE';
	end if;
	close csr_exists;
	--
	hr_utility.trace(p_valid_upgrade);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end validate_pay_jp_pre_tax;
-- |-------------------------------------------------------------------|
-- |--------------------< qualify_pay_jp_pre_tax >---------------------|
-- |-------------------------------------------------------------------|
procedure qualify_pay_jp_pre_tax(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'qualify_pay_jp_pre_tax';
	--
	cursor csr_ppt is
/*
		select	'Y'
		from	dual
		where	exists(
				select	null
				from	pay_jp_pre_tax		ppt,
					pay_assignment_actions	paa
				where	paa.assignment_id = p_assignment_id
				and	paa.action_status = 'C'
				and	ppt.assignment_action_id = paa.assignment_action_id
				and	ppt.action_status = 'C');
*/
                select  'Y'
                from    pay_action_information  pai,
                        pay_assignment_actions  paa
                where   paa.assignment_id = p_assignment_id
                and     paa.action_status = 'C'
                and     pai.action_information_category = 'JP_PRE_TAX_1'
                and     pai.action_context_type = 'AAP'
                and     pai.action_information1 = paa.assignment_action_id
                and     rownum = 1;

begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_ppt;
	fetch csr_ppt into p_qualifier;
	if csr_ppt%notfound then
		p_qualifier := 'N';
	end if;
	close csr_ppt;
	--
	hr_utility.trace(p_assignment_id || ' : ' || p_qualifier);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end qualify_pay_jp_pre_tax;
-- |-------------------------------------------------------------------|
-- |----------------< upgrade_disaster_tax_reduction >-----------------|
-- |-------------------------------------------------------------------|
procedure upgrade_disaster_tax_reduction(p_assignment_id in number)
is
	c_proc		constant varchar2(61) := c_package || 'upgrade_disaster_tax_reduction';
	--
	l_defined_balance_id	number;
	l_balance		number;
	--
	cursor csr_assact is
          select  pai.action_information29 disaster_tax_reduction,
                  pai.action_information_id,
                  paa.assignment_action_id
          from    pay_action_information  pai,
                  pay_assignment_actions  paa
          where   paa.assignment_id = p_assignment_id
          and     paa.action_status = 'C'
          and     pai.action_information_category = 'JP_PRE_TAX_1'
          and     pai.action_context_type = 'AAP'
          and     pai.action_information1 = paa.assignment_action_id
          for update of pai.action_information_id nowait;
/*
		select	ppt.rowid,
			paa.assignment_action_id,
			ppt.disaster_tax_reduction
		from	pay_jp_pre_tax		ppt,
			pay_assignment_actions	paa
		where	paa.assignment_id = p_assignment_id
		and	paa.action_status = 'C'
		and	ppt.assignment_action_id = paa.assignment_action_id
		and	ppt.action_status = 'C'
		for update of ppt.pre_tax_id nowait;
*/
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	hr_utility.trace('assignment_id: ' || p_assignment_id);
	--
	-- When the following sql fails, it means JP post install has not
	-- completed successfully because qualify procedure guarantees that
	-- JP post install had been completed before.
	-- To fix no_data_found error here, need to complete JP post install
	-- before applying this.
	--
	select	creator_id
	into	l_defined_balance_id
	from	ff_user_entities
	where	user_entity_name = 'B_YEA_GRACE_ITX_ASG_RUN'
	and	legislation_code = 'JP'
	and	creator_type = 'B';
	--
	for l_assact in csr_assact loop
		l_balance := pay_balance_pkg.get_value(l_defined_balance_id, l_assact.assignment_action_id);
		--
		if l_balance <> l_assact.disaster_tax_reduction then
             update  pay_action_information
             set     action_information29 = l_balance --Disaster Tax Reduction
             where   action_information_id = l_assact.action_information_id;
/*
			update	pay_jp_pre_tax
			set	disaster_tax_reduction = l_balance
			where	rowid = l_assact.rowid;
*/
			--
			hr_utility.trace(l_assact.disaster_tax_reduction || ' --> ' || l_balance);
		end if;
	end loop;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end upgrade_disaster_tax_reduction;
-- |-------------------------------------------------------------------|
-- |-----------------------< validate_prev_job >-----------------------|
-- |-------------------------------------------------------------------|
procedure validate_prev_job(p_valid_upgrade out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'validate_prev_job';
	--
	cursor csr_exists is
		select	'TRUE'
		from	dual
		where	exists(
				select	null
				from	pay_element_types_f	pet,
					pay_element_links_f	pel,
					pay_element_entries_f	pee
				where	pet.element_name = 'YEA_PREV_EMP_INFO'
				and	pet.legislation_code = 'JP'
				and	pel.element_type_id = pet.element_type_id
				and	pee.element_link_id = pel.element_link_id);
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_exists;
	fetch csr_exists into p_valid_upgrade;
	if csr_exists%notfound then
		p_valid_upgrade := 'FALSE';
	end if;
	close csr_exists;
	--
	hr_utility.trace(p_valid_upgrade);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end validate_prev_job;
-- |-------------------------------------------------------------------|
-- |-----------------------< qualify_prev_job >------------------------|
-- |-------------------------------------------------------------------|
procedure qualify_prev_job(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'qualify_prev_job';
	--
	cursor csr_ee is
		select	'Y'
		from	dual
		where	exists(
				select	null
				from	pay_element_types_f	pet,
					pay_element_links_f	pel,
					pay_element_entries_f	pee
				where	pet.element_name = 'YEA_PREV_EMP_INFO'
				and	pet.legislation_code = 'JP'
				and	pel.element_type_id = pet.element_type_id
				and	pee.assignment_id = p_assignment_id
				and	pee.element_link_id = pel.element_link_id);
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	-- No need to check whether the assignment is "Payroll" assignment or not
	-- not to raise error when creating previous employers by API because
	-- non-recurring entries cannot be created for non-Payroll assignments.
	--
	open csr_ee;
	fetch csr_ee into p_qualifier;
	if csr_ee%notfound then
		p_qualifier := 'N';
	end if;
	close csr_ee;
	--
	hr_utility.trace(p_assignment_id || ' : ' || p_qualifier);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end qualify_prev_job;
-- |-------------------------------------------------------------------|
-- |-----------------------< upgrade_prev_job >------------------------|
-- |-------------------------------------------------------------------|
procedure upgrade_prev_job(p_assignment_id in number)
is
	c_proc			constant varchar2(61) := c_package || 'upgrade_prev_job';
	--
	l_business_group_id	number;
	l_person_id		number;
	l_effective_date	date;
	--
	l_party_id		number;
--	l_bg_name		per_business_groups_perf.name%type;
	l_full_name		per_all_people_f.full_name%type;
	--
	cursor csr_ee is
		select	employment_income,
			si_prems,
			mutual_aid_prem,
			withholding_tax,
			termination_date,
			foreign_flag,
			employer_address_kana,
			employer_address,
			employer_name_kana,
			employer_name
		from	(
			select	/*+ ORDERED USE_NL(PEL PEE PEEV PIV) */
				nvl(fnd_number.canonical_to_number(min(decode(piv.display_sequence, 1, peev.screen_entry_value))), 0)	employment_income,
				nvl(fnd_number.canonical_to_number(min(decode(piv.display_sequence, 2, peev.screen_entry_value))), 0)	si_prems,
				nvl(fnd_number.canonical_to_number(min(decode(piv.display_sequence, 3, peev.screen_entry_value))), 0)	mutual_aid_prem,
				nvl(fnd_number.canonical_to_number(min(decode(piv.display_sequence, 4, peev.screen_entry_value))), 0)	withholding_tax,
				fnd_date.canonical_to_date(min(decode(piv.display_sequence, 5, peev.screen_entry_value)))		termination_date,
				nvl(min(decode(piv.display_sequence, 6, peev.screen_entry_value)), 'N')					foreign_flag,
				hr_jp_standard_pkg.to_hankaku(min(decode(piv.display_sequence, 7, peev.screen_entry_value)))						employer_address_kana,
				min(decode(piv.display_sequence, 8, peev.screen_entry_value))						employer_address,
				hr_jp_standard_pkg.to_hankaku(min(decode(piv.display_sequence, 9, peev.screen_entry_value)))		employer_name_kana,
				min(decode(piv.display_sequence, 10, peev.screen_entry_value))		employer_name
			from	pay_element_types_f		pet,
				pay_element_links_f		pel,
				pay_element_entries_f		pee,
				pay_element_entry_values_f	peev,
				pay_input_values_f		piv
			where	pet.element_name = 'YEA_PREV_EMP_INFO'
			and	pet.legislation_code = 'JP'
			and	pel.element_type_id = pet.element_type_id
			and	pel.business_group_id + 0 = l_business_group_id
			and	pel.effective_start_date
				between pet.effective_start_date and pet.effective_end_date
			and	pee.assignment_id = p_assignment_id
			and	pee.element_link_id = pel.element_link_id
			and	pee.effective_start_date
				between pel.effective_start_date and pel.effective_end_date
			and	peev.element_entry_id = pee.element_entry_id
			and	peev.effective_start_date = pee.effective_start_date
			and	peev.effective_end_date = pee.effective_end_date
			and	piv.input_value_id = peev.input_value_id
			and	peev.effective_start_date
				between piv.effective_start_date and pee.effective_end_date
			group by
				pee.element_entry_id,
				pee.effective_start_date,
				pee.effective_end_date
			)
		group by
			employment_income,
			si_prems,
			mutual_aid_prem,
			withholding_tax,
			termination_date,
			foreign_flag,
			employer_address_kana,
			employer_address,
			employer_name_kana,
			employer_name;
	cursor csr_prev_employer(
		p_person_id		number,
		p_employer_name		varchar2,
		p_foreign_flag		varchar2,
		p_termination_date	date) is
		select	previous_employer_id,
			object_version_number,
			employer_country,
			employer_address,
			end_date
		from	per_previous_employers
		where	person_id = p_person_id
		and	(
				replace(upper(hr_jp_standard_pkg.upper_kana(hr_jp_standard_pkg.to_hankaku(employer_name))), ' ') =
					replace(upper(hr_jp_standard_pkg.upper_kana(hr_jp_standard_pkg.to_hankaku(p_employer_name))), ' ')
			)
		and	(
					end_date = p_termination_date
				or	(end_date is null and p_termination_date is not null)
				or	(end_date is not null and p_termination_date is null)
			)
		and	(
				(p_foreign_flag = 'N' and nvl(employer_country, 'JP') = 'JP')
				or
				(p_foreign_flag = 'Y' and employer_country <> 'JP')
			)
		and	rownum <= 1
		for update of previous_employer_id;
	l_prev_employer		csr_prev_employer%rowtype;
begin
	begin
		hr_utility.set_location('Entering: ' || c_proc, 10);
		hr_utility.trace('assignment_id: ' || p_assignment_id);
		--
		select	business_group_id,
			person_id,
			effective_start_date
		into	l_business_group_id,
			l_person_id,
			l_effective_date
		from	per_all_assignments_f asg
		where	assignment_id = p_assignment_id
		and	rownum <= 1;
		--
		select	per.party_id,
--			bg.name,
			per.full_name
		into	l_party_id,
--			l_bg_name,
			l_full_name
		from	per_all_people_f		per,
			per_business_groups_perf	bg
		where	per.person_id = l_person_id
		and	l_effective_date
			between per.effective_start_date and per.effective_end_date
		and	bg.business_group_id = per.business_group_id;
		--
		hr_utility.set_location(c_proc, 20);
		--
		-- When the following sql fails, it means JP post install has not
		-- completed successfully because qualify procedure guarantees that
		-- JP post install had been completed before.
		-- To fix no_data_found error here, need to complete JP post install
		-- before applying this.
		--
		for l_prev_job in csr_ee loop
			hr_utility.set_location(c_proc, 30);
			--
			hr_utility.trace('employment_income    : ' || l_prev_job.employment_income);
			hr_utility.trace('si_prems             : ' || l_prev_job.si_prems);
			hr_utility.trace('mutual_aid_prem      : ' || l_prev_job.mutual_aid_prem);
			hr_utility.trace('withholding_tax      : ' || l_prev_job.withholding_tax);
			hr_utility.trace('termination_date     : ' || l_prev_job.termination_date);
			hr_utility.trace('foreign_flag         : ' || l_prev_job.foreign_flag);
			hr_utility.trace('employer_address_kana: ' || l_prev_job.employer_address_kana);
			hr_utility.trace('employer_address     : ' || l_prev_job.employer_address);
			hr_utility.trace('employer_name_kana   : ' || l_prev_job.employer_name_kana);
			hr_utility.trace('employer_name        : ' || l_prev_job.employer_name);
			--
			open csr_prev_employer(	l_person_id,
						l_prev_job.employer_name,
						l_prev_job.foreign_flag,
						l_prev_job.termination_date);
			fetch csr_prev_employer into l_prev_employer;
			--
			-- Update is only for the following cases (note address is not checked).
			-- 1) Employer Name for both EE and PEM are not null and not different.
			-- 2) Termination Date is not different.
			-- 3) Country is not different.
			--
			if csr_prev_employer%found then
				hr_utility.trace('Updating PER_PREVIOUS_EMPLOYERS...');
				--
				if l_prev_employer.end_date is null then
					l_prev_employer.end_date := l_prev_job.termination_date;
				end if;
				--
				if l_prev_employer.employer_address is null then
					l_prev_employer.employer_address := l_prev_job.employer_address;
				end if;
				--
				if l_prev_employer.employer_country is null then
					if l_prev_job.foreign_flag = 'Y' then
						l_prev_employer.employer_country := 'US';
					else
						l_prev_employer.employer_country := 'JP';
					end if;
				end if;
				--
				hr_previous_employment_api.update_previous_employer(
					P_EFFECTIVE_DATE		=> l_effective_date,
					P_PREVIOUS_EMPLOYER_ID		=> l_prev_employer.previous_employer_id,
					P_END_DATE			=> l_prev_employer.end_date,
					P_EMPLOYER_ADDRESS		=> l_prev_employer.employer_address,
					P_EMPLOYER_COUNTRY		=> l_prev_employer.employer_country,
					P_PEM_INFORMATION_CATEGORY	=> 'JP',
					P_PEM_INFORMATION1		=> l_prev_job.employer_name_kana,
					P_PEM_INFORMATION2		=> l_prev_job.employer_address_kana,
					P_PEM_INFORMATION3		=> fnd_number.number_to_canonical(l_prev_job.employment_income),
					P_PEM_INFORMATION4		=> fnd_number.number_to_canonical(l_prev_job.si_prems),
					P_PEM_INFORMATION5		=> fnd_number.number_to_canonical(l_prev_job.mutual_aid_prem),
					P_PEM_INFORMATION6		=> fnd_number.number_to_canonical(l_prev_job.withholding_tax),
					P_OBJECT_VERSION_NUMBER		=> l_prev_employer.object_version_number);
			else
				hr_utility.trace('Inserting PER_PREVIOUS_EMPLOYERS...');
				--
				l_prev_employer := null;
				--
				if l_prev_job.foreign_flag = 'Y' then
					l_prev_employer.employer_country := 'US';
				else
					l_prev_employer.employer_country := 'JP';
				end if;
				--
				hr_previous_employment_api.create_previous_employer(
					P_EFFECTIVE_DATE		=> l_effective_date,
					P_BUSINESS_GROUP_ID		=> l_business_group_id,
					P_PERSON_ID			=> l_person_id,
					P_PARTY_ID			=> l_party_id,
					P_END_DATE			=> l_prev_job.termination_date,
					P_EMPLOYER_NAME			=> l_prev_job.employer_name,
					P_EMPLOYER_COUNTRY		=> l_prev_employer.employer_country,
					P_EMPLOYER_ADDRESS		=> l_prev_job.employer_address,
					P_PEM_INFORMATION_CATEGORY	=> 'JP',
					P_PEM_INFORMATION1		=> l_prev_job.employer_name_kana,
					P_PEM_INFORMATION2		=> l_prev_job.employer_address_kana,
					P_PEM_INFORMATION3		=> fnd_number.number_to_canonical(l_prev_job.employment_income),
					P_PEM_INFORMATION4		=> fnd_number.number_to_canonical(l_prev_job.si_prems),
					P_PEM_INFORMATION5		=> fnd_number.number_to_canonical(l_prev_job.mutual_aid_prem),
					P_PEM_INFORMATION6		=> fnd_number.number_to_canonical(l_prev_job.withholding_tax),
					P_PREVIOUS_EMPLOYER_ID		=> l_prev_employer.previous_employer_id,
					P_OBJECT_VERSION_NUMBER		=> l_prev_employer.object_version_number);
			end if;
			close csr_prev_employer;
		end loop;
		--
		hr_utility.set_location('Leaving: ' || c_proc, 100);
	exception
		when app_exception.application_exception then
			app_exception.raise_exception;
	end;
exception
	when others then
		if g_num_errors = 0 then
			fnd_file.put_line(fnd_file.log, fnd_message.get_string('PAY', 'PAY_JP_RETRY_JP_PREV_JOB_UPG'));
			fnd_file.put_line(fnd_file.log,
				rpad(fnd_message.get_string('PER', 'OH_FULL_NAME'), 30) || ' ' ||
				fnd_message.get_string('FND', 'FND_MESSAGE_TYPE_ERROR'));
			fnd_file.put_line(fnd_file.log, rpad('-', 30, '-') || ' ' || rpad('-', 100, '-'));
		end if;
		g_num_errors := g_num_errors + 1;
		--
		fnd_file.put_line(fnd_file.log, rpad(l_full_name, 30) || ' ' || sqlerrm);
		raise;
end upgrade_prev_job;
-- |-------------------------------------------------------------------|
-- |-------------------< entries_or_results_exist >--------------------|
-- |-------------------------------------------------------------------|
function entries_or_results_exist(p_legislation_code in varchar2) return boolean
is
	c_proc		constant varchar2(61) := c_package || 'entries_or_results_exist';
	l_exists	varchar2(1);
	--
	-- Check whether either any element entries or run results exist.
	--
	cursor csr_exists is
		select	'Y'
		from	dual
		where	exists(
				select	/*+ ORDERED
					    NO_MERGE(BG)
					    USE_NL(PEL PEE)
					    INDEX(PEL PAY_ELEMENT_LINKS_F_FK11)
					    INDEX(PEE PAY_ELEMENT_ENTRIES_F_N4) */
					null
				from	per_business_groups_perf	bg,
					pay_element_links_f		pel,
					pay_element_entries_f		pee
				where	bg.legislation_code = p_legislation_code
				and	pel.business_group_id = bg.business_group_id
				and	pee.element_link_id = pel.element_link_id)
		or	exists(
				select	/*+ ORDERED
					    NO_MERGE(BG)
					    USE_NL(PPA PAA PRR)
					    INDEX(PPA PAY_PAYROLL_ACTIONS_FK1)
					    INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N50)
					    INDEX(PRR PAY_RUN_RESULTS_N50) */
					null
				from	per_business_groups_perf	bg,
					pay_payroll_actions		ppa,
					pay_assignment_actions		paa,
					pay_run_results			prr
				where	bg.legislation_code = p_legislation_code
				and	ppa.business_group_id = bg.business_group_id
				and	paa.payroll_action_id = ppa.payroll_action_id
				and	prr.assignment_action_id = paa.assignment_action_id);
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_exists;
	fetch csr_exists into l_exists;
	if csr_exists%notfound then
		l_exists := 'N';
	end if;
	close csr_exists;
	--
	hr_utility.trace('Exists? : ' || l_exists);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
	--
	return (l_exists = 'Y');
end entries_or_results_exist;
-- |-------------------------------------------------------------------|
-- |-------------------< entries_or_results_exist >--------------------|
-- |-------------------------------------------------------------------|
function entries_or_results_exist(p_element_type_id in number) return boolean
is
	c_proc		constant varchar2(61) := c_package || 'entries_or_results_exist';
	l_exists	varchar2(1);
	--
	-- Check whether either any element entries or run results exist.
	--
	cursor csr_exists is
		select	'Y'
		from	dual
		where	exists(
				select	/*+ ORDERED
					    USE_NL(PEE)
					    INDEX(PEL PAY_ELEMENT_LINKS_F_N7)
					    INDEX(PEE PAY_ELEMENT_ENTRIES_F_N4) */
					null
				from	pay_element_links_f	pel,
					pay_element_entries_f	pee
				where	pel.element_type_id = p_element_type_id
				and	pee.element_link_id = pel.element_link_id)
		or	exists(
				select	null
				from	pay_run_results		prr
				where	prr.element_type_id = p_element_type_id);
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_exists;
	fetch csr_exists into l_exists;
	if csr_exists%notfound then
		l_exists := 'N';
	end if;
	close csr_exists;
	--
	hr_utility.trace('Exists? : ' || l_exists);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
	--
	return (l_exists = 'Y');
end entries_or_results_exist;
-- |-------------------------------------------------------------------|
-- |-------------------< entries_or_results_exist >--------------------|
-- |-------------------------------------------------------------------|
function entries_or_results_exist(p_assignment_id in number) return boolean
is
	c_proc		constant varchar2(61) := c_package || 'entries_or_results_exist';
	l_exists	varchar2(1);
	--
	-- Check whether either any element entries or run results exist.
	--
	cursor csr_exists is
		select	'Y'
		from	dual
		where	exists(
				select	null  -- Removed the Hint Bug# 4674234
				from	pay_element_entries_f	pee
				where	pee.assignment_id = p_assignment_id)
		or	exists(
				select	null
				from	pay_assignment_actions	paa,
					pay_run_results		prr
				where	paa.assignment_id = p_assignment_id
				and	prr.assignment_action_id = paa.assignment_action_id);
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_exists;
	fetch csr_exists into l_exists;
	if csr_exists%notfound then
		l_exists := 'N';
	end if;
	close csr_exists;
	--
	hr_utility.trace(p_assignment_id || ' : ' || l_exists);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
	--
	return (l_exists = 'Y');
end entries_or_results_exist;
-- |-------------------------------------------------------------------|
-- |-------------------< entries_or_results_exist >--------------------|
-- |-------------------------------------------------------------------|
function entries_or_results_exist(
	p_assignment_id		in number,
	p_element_type_id	in number) return boolean
is
	c_proc		constant varchar2(61) := c_package || 'entries_or_results_exist';
	l_exists	varchar2(1);
	--
	-- Check whether either any element entries or run results exist.
	--
	cursor csr_exists is
		select	'Y'
		from	dual
		where	exists(
				select	/*+ ORDERED
					    USE_NL(PEE)
					    INDEX(PEL PAY_ELEMENT_LINKS_F_N7)
					    INDEX(PEE PAY_ELEMENT_ENTRIES_F_N51) */
					null
				from	pay_element_links_f	pel,
					pay_element_entries_f	pee
				where	pel.element_type_id = p_element_type_id
				and	pee.assignment_id = p_assignment_id
				and	pee.element_link_id = pel.element_link_id)
		or	exists(
                               -- Removed Hint on PAA as per Bug# 4674234.
				select	/*+ ORDERED
					    USE_NL(PRR)
					    INDEX(PRR PAY_RUN_RESULTS_N50) */
					null
				from	pay_assignment_actions	paa,
					pay_run_results		prr
				where	paa.assignment_id = p_assignment_id
				and	prr.assignment_action_id = paa.assignment_action_id
				and	prr.element_type_id = p_element_type_id);
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_exists;
	fetch csr_exists into l_exists;
	if csr_exists%notfound then
		l_exists := 'N';
	end if;
	close csr_exists;
	--
	hr_utility.trace(p_assignment_id || ' : ' || l_exists);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
	--
	return (l_exists = 'Y');
end entries_or_results_exist;
-- |-------------------------------------------------------------------|
-- |--------------------< sync_link_input_values >---------------------|
-- |-------------------------------------------------------------------|
procedure sync_link_input_values(p_element_type_id in number)
is
	c_proc			constant varchar2(61) := c_package || 'sync_link_input_values';
	--
	l_link_input_value_id		number;
	l_effective_start_date		date;
	l_effective_end_date		date;
	l_object_version_number		number;
	l_pay_basis_warning		boolean;
	--
	cursor csr_link is
		select	pel.element_link_id,
			piv.input_value_id,
			min(pel.effective_start_date)	effective_start_date,
			max(pel.effective_end_date)	effective_end_date
		from	pay_element_links_f	pel,
			pay_input_values_f	piv
		where	pel.element_type_id = p_element_type_id
		and	piv.element_type_id = pel.element_type_id
		and	pel.effective_start_date
			between piv.effective_start_date and piv.effective_end_date
		and	not exists(
				select	null
				from	pay_link_input_values_f	pliv
				where	pliv.element_link_id = pel.element_link_id
				and	pliv.input_value_id = piv.input_value_id)
		group by pel.element_link_id, piv.input_value_id;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if p_element_type_id is not null then
		for l_rec in csr_link loop
			hr_utility.trace('******************************');
			hr_utility.trace('element_link_id      : ' || l_rec.element_link_id);
			hr_utility.trace('input_value_id       : ' || l_rec.input_value_id);
			hr_utility.trace('effective_start_date : ' || l_rec.effective_start_date);
			hr_utility.trace('effective_end_date   : ' || l_rec.effective_end_date);
			--
			pay_link_input_values_api.create_liv_internal(
				P_EFFECTIVE_DATE		=> l_rec.effective_start_date,
				P_ELEMENT_LINK_ID		=> l_rec.element_link_id,
				P_INPUT_VALUE_ID		=> l_rec.input_value_id,
				P_COSTED_FLAG			=> 'N',
				P_DEFAULT_VALUE			=> null, -- Not used
				P_MAX_VALUE			=> null, -- Not used
				P_MIN_VALUE			=> null, -- Not used
				P_WARNING_OR_ERROR		=> null, -- Not used
				P_LINK_INPUT_VALUE_ID		=> l_link_input_value_id,
				P_EFFECTIVE_START_DATE		=> l_effective_start_date,
				P_EFFECTIVE_END_DATE		=> l_effective_end_date,
				P_OBJECT_VERSION_NUMBER		=> l_object_version_number,
				P_PAY_BASIS_WARNING		=> l_pay_basis_warning);
			--
			hr_utility.trace('------------------------------');
			hr_utility.trace('link_input_value_id  : ' || l_link_input_value_id);
			hr_utility.trace('effective_start_date : ' || l_effective_start_date);
			hr_utility.trace('effective_end_date   : ' || l_effective_end_date);
		end loop;
	end if;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end sync_link_input_values;
-- |-------------------------------------------------------------------|
-- |-------------------< sync_entries_and_results >--------------------|
-- |-------------------------------------------------------------------|
procedure sync_entries_and_results(
	p_assignment_id		in number,
	p_element_type_id	in number)
is
	c_proc			constant varchar2(61) := c_package || 'sync_entries_and_results';
	--
	l_rule_mode		pay_legislation_rules.rule_mode%type;
	l_found			boolean;
	l_business_group_id	number;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if p_element_type_id is not null then
		--
		-- Before running this SQL, PAY_LINK_INPUT_VALUES needs to be populated.
		--
		insert into pay_element_entry_values_f(
			ELEMENT_ENTRY_VALUE_ID,
			EFFECTIVE_START_DATE,
			EFFECTIVE_END_DATE,
			INPUT_VALUE_ID,
			ELEMENT_ENTRY_ID,
			SCREEN_ENTRY_VALUE)
		select	/*+ ORDERED
			    USE_NL(PEL PLIV PIV)
			    INDEX(PEE PAY_ELEMENT_ENTRIES_F_N50)
			    INDEX(PEL PAY_ELEMENT_LINKS_F_PK)
			    INDEX(PLIV PAY_LINK_INPUT_VALUES_F_U50)
			    INDEX(PIV PAY_INPUT_VALUES_F_PK) */
			pay_element_entry_values_s.nextval,
			pee.effective_start_date,
			pee.effective_end_date,
			pliv.input_value_id,
			pee.element_entry_id,
			decode(piv.hot_default_flag, 'Y', null, nvl(pliv.default_value, piv.default_value))
		from	pay_element_entries_f	pee,
			pay_element_links_f	pel,
			pay_link_input_values_f	pliv,
			pay_input_values_f	piv
		where	pee.assignment_id = p_assignment_id
		and	pel.element_link_id = pee.element_link_id
		and	pee.effective_start_date
			between pel.effective_start_date and pel.effective_end_date
		and	pel.element_type_id = p_element_type_id
		and	pliv.element_link_id = pel.element_link_id
		and	pee.effective_start_date
			between pliv.effective_start_date and pliv.effective_end_date
		and	piv.input_value_id = pliv.input_value_id
		and	pee.effective_start_date
			between piv.effective_start_date and piv.effective_end_date
		and	not exists(
				/* If required, add hint in the following sql. */
				select	null
				from	pay_element_entry_values_f	peev
				where	peev.element_entry_id = pee.element_entry_id
				and	peev.effective_start_date = pee.effective_start_date
				and	peev.effective_end_date = pee.effective_end_date
				and	peev.input_value_id = piv.input_value_id);
		--
		hr_utility.trace('assignment_id   : ' || p_assignment_id);
		hr_utility.trace('element_type_id : ' || p_element_type_id);
		hr_utility.trace(sql%rowcount || ' rows inserted into pay_element_entry_values_f');
		--
		-- Check RR_SPARSE legislation rule
		--
		pay_core_utils.get_legislation_rule(
			'RR_SPARSE',
			'JP',
			l_rule_mode,
			l_found);
		--
		-- Check ENABLE_RR_SPARSE generic upgrade
		--
		if l_rule_mode = 'Y' then
			select	distinct
				business_group_id
			into	l_business_group_id
			from	per_all_assignments_f
			where	assignment_id = p_assignment_id;
			--
			l_rule_mode := pay_core_utils.get_upgrade_status(l_business_group_id, 'ENABLE_RR_SPARSE');
		end if;
		-- When RR_SPARSE, create "null" result values only
		-- for 'E'(Entry) or 'R'(Reversal) run results.
		-- No need to create for 'I'(Indirect) and 'V'(Reversed Indirect).
		--
		if l_rule_mode = 'Y' then
			null;
--
-- Bug.4360429
-- No "null" result values need to be created when sparse matrix is enabled.
--
--			insert into pay_run_result_values(
--				INPUT_VALUE_ID,
--				RUN_RESULT_ID,
--				RESULT_VALUE)
--			select	/*+ ORDERED
--				    USE_NL(PRR PPA PIV)
--				    INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N1)
--				    INDEX(PRR PAY_RUN_RESULTS_N50)
--				    INDEX(PPA PAY_PAYROLL_ACTIONS_PK)
--				    INDEX(PIV PAY_INPUT_VALUES_F_N50) */
--				piv.input_value_id,
--				prr.run_result_id,
--				null
--			from	pay_assignment_actions		paa,
--				pay_run_results		 	prr,
--				pay_payroll_actions		ppa,
--				pay_input_values_f		piv
--			where	paa.assignment_id = p_assignment_id
--			and	prr.assignment_action_id = paa.assignment_action_id
--			and	prr.element_type_id = p_element_type_id
--			and	prr.source_type in ('E', 'R')
--			and	ppa.payroll_action_id = paa.payroll_action_id
--			and	piv.element_type_id = prr.element_type_id
--			and	ppa.effective_date
--				between piv.effective_start_date and piv.effective_end_date
--			and	not exists(
--					/* If required, add hint in the following sql. */
--					select	null
--					from	pay_run_result_values	prrv
--					where	prrv.run_result_id = prr.run_result_id
--					and	prrv.input_value_id = piv.input_value_id);
--			--
--			hr_utility.trace(sql%rowcount || ' rows inserted into pay_run_result_values (RR_SPARSE)');
		--
		-- When not RR_SPARSE, create "null" result values for all appropriate run results.
		--
		else
                  /* Removed ORDERED and USE_NL hints to
fix Bug 5232799 */
			insert into pay_run_result_values(
				INPUT_VALUE_ID,
				RUN_RESULT_ID,
				RESULT_VALUE)
			select  /*+ INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N51)
                                    INDEX(PRR PAY_RUN_RESULTS_N50)
                                    INDEX(PPA PAY_PAYROLL_ACTIONS_PK)
                                    INDEX(PIV PAY_INPUT_VALUES_F_N50) */
				piv.input_value_id,
				prr.run_result_id,
				null
			from	pay_assignment_actions		paa,
				pay_run_results		 	prr,
				pay_payroll_actions		ppa,
				pay_input_values_f		piv
			where	paa.assignment_id = p_assignment_id
			and	prr.assignment_action_id = paa.assignment_action_id
			and	prr.element_type_id = p_element_type_id
			and	ppa.payroll_action_id = paa.payroll_action_id
			and	piv.element_type_id = prr.element_type_id
			and	ppa.effective_date
				between piv.effective_start_date and piv.effective_end_date
			and	not exists(
					/* If required, add hint in the following sql. */
					select	null
					from	pay_run_result_values	prrv
					where	prrv.run_result_id = prr.run_result_id
					and	prrv.input_value_id = piv.input_value_id);
			--
			hr_utility.trace(sql%rowcount || ' rows inserted into pay_run_result_values');
		end if;
	end if;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end sync_entries_and_results;
-- |-------------------------------------------------------------------|
-- |----------------------< get_element_type_id >----------------------|
-- |-------------------------------------------------------------------|
procedure get_element_type_id(
	p_element_name		in varchar2,
	p_element_type_ids	in out nocopy t_numbers)
is
	l_element_type_id	number;
	--
	cursor csr_id is
		select	distinct
			element_type_id
		from	pay_element_types_f
		where	element_name = p_element_name
		and	business_group_id is null
		and	legislation_code = 'JP';
begin
	open csr_id;
	fetch csr_id into l_element_type_id;
	if csr_id%found then
		hr_utility.trace(p_element_name || ': ' || l_element_type_id);
		p_element_type_ids(p_element_type_ids.count + 1) := l_element_type_id;
	else
		hr_utility.trace(p_element_name || ' NOT found!');
	end if;
	close csr_id;
end get_element_type_id;
-- |-------------------------------------------------------------------|
-- |--------------------------< init_pay_a >---------------------------|
-- |-------------------------------------------------------------------|
procedure init_pay_a
is
	c_proc		constant varchar2(61) := c_package || 'init_pay_a';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if g_element_type_ids.count = 0 then
		hr_utility.trace('Not cached.');
		--
		get_element_type_id('INI_SAL2', g_element_type_ids);
		get_element_type_id('INI_BON2', g_element_type_ids);
		get_element_type_id('INI_SPB1', g_element_type_ids);
		get_element_type_id('INI_YEA2', g_element_type_ids);
		get_element_type_id('COM_ITX_INFO', g_element_type_ids);
		get_element_type_id('SAL_HI_PREM_PROC', g_element_type_ids);
		get_element_type_id('SAL_WP_PREM_PROC', g_element_type_ids);
		get_element_type_id('SAL_ITX', g_element_type_ids);
		get_element_type_id('BON_HI_PREM_PROC', g_element_type_ids);
		get_element_type_id('BON_WP_PREM_PROC', g_element_type_ids);
		get_element_type_id('BON_ITX', g_element_type_ids);
		get_element_type_id('SPB_ITX', g_element_type_ids);
		get_element_type_id('YEA_PREV_EMP_INFO', g_element_type_ids);
		get_element_type_id('YEA_ADJ_INFO', g_element_type_ids);
		get_element_type_id('YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT', g_element_type_ids);
		get_element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_INFO', g_element_type_ids);
		get_element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_RSLT', g_element_type_ids);
		get_element_type_id('YEA_HOUSING_LOAN_TAX_CREDIT', g_element_type_ids);
		get_element_type_id('YEA_WITHHOLD_TAX_REPORT_INFO', g_element_type_ids);
		get_element_type_id('GEP_ADJ_INFO', g_element_type_ids);
		get_element_type_id('SAN_ADJ_INFO', g_element_type_ids);
		get_element_type_id('SAN_REPORT_RMKS_RSLT', g_element_type_ids);
	end if;
	--
--	for i in 1..g_element_type_ids.count loop
--		hr_utility.trace(i || ': ' || g_element_type_ids(i));
--	end loop;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end init_pay_a;
-- |-------------------------------------------------------------------|
-- |------------------------< validate_pay_a >-------------------------|
-- |-------------------------------------------------------------------|
procedure validate_pay_a(p_valid_upgrade out nocopy varchar2)
is
	c_proc			constant varchar2(61) := c_package || 'validate_pay_a';
	--
	l_element_type_id1	number;
	l_element_type_id2	number;
	l_element_type_id3	number;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	-- At first, upgrade PAY_LINK_INPUT_VALUES_F.
	--
	init_pay_a;
	--
	for i in 1..g_element_type_ids.count loop
		pay_jp_generic_upgrade_pkg.sync_link_input_values(g_element_type_ids(i));
	end loop;
	--
	if entries_or_results_exist(p_legislation_code => 'JP') then
		p_valid_upgrade := 'TRUE';
	else
		p_valid_upgrade := 'FALSE';
	end if;
	--
	hr_utility.trace(p_valid_upgrade);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end validate_pay_a;
-- |-------------------------------------------------------------------|
-- |-------------------------< qualify_pay_a >-------------------------|
-- |-------------------------------------------------------------------|
procedure qualify_pay_a(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'qualify_pay_a';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if entries_or_results_exist(p_assignment_id => p_assignment_id) then
		p_qualifier := 'Y';
	else
		p_qualifier := 'N';
	end if;
	--
	hr_utility.trace(p_assignment_id || ' : ' || p_qualifier);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end qualify_pay_a;
-- |-------------------------------------------------------------------|
-- |----------------------< upgrade_pay_a >----------------------------|
-- |-------------------------------------------------------------------|
procedure upgrade_pay_a(p_assignment_id in number)
is
	c_proc		constant varchar2(61) := c_package || 'upgrade_pay_a';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	init_pay_a;
	--
	for i in 1..g_element_type_ids.count loop
		sync_entries_and_results(p_assignment_id, g_element_type_ids(i));
	end loop;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end upgrade_pay_a;
-- |-------------------------------------------------------------------|
-- |-------------------< validate_itax_description >-------------------|
-- |-------------------------------------------------------------------|
procedure validate_itax_description(
	p_valid_upgrade out nocopy varchar2
)
is
--
	c_proc			constant varchar2(61) := c_package || 'validate_itax_description';
--
begin
--
	hr_utility.set_location('Entering: ' || c_proc, 10);
--
	--
	-- At first, upgrade PAY_LINK_INPUT_VALUES_F.
	--
  if g_element_type_ids.count = 0 then
  --
    get_element_type_id('YEA_WITHHOLD_TAX_REPORT_INFO', g_element_type_ids);
  --
  end if;
--
  for i in 1..g_element_type_ids.count loop
  --
    pay_jp_generic_upgrade_pkg.sync_link_input_values(g_element_type_ids(i));
	--
  end loop;
--
	if entries_or_results_exist(p_legislation_code => 'JP') then
		p_valid_upgrade := 'TRUE';
	else
		p_valid_upgrade := 'FALSE';
	end if;
--
	hr_utility.trace(p_valid_upgrade);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end validate_itax_description;
-- |-------------------------------------------------------------------|
-- |-------------------< qualify_itax_description >--------------------|
-- |-------------------------------------------------------------------|
procedure qualify_itax_description(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2
)
is
	c_proc		constant varchar2(61) := c_package || 'qualify_itax_description';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if entries_or_results_exist(p_assignment_id => p_assignment_id) then
		p_qualifier := 'Y';
	else
		p_qualifier := 'N';
	end if;
	--
	hr_utility.trace(p_assignment_id || ' : ' || p_qualifier);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end qualify_itax_description;
-- |-------------------------------------------------------------------|
-- |-------------------< upgrade_itax_description >--------------------|
-- |-------------------------------------------------------------------|
procedure upgrade_itax_description(
	p_assignment_id in number
)
is
	c_proc		constant varchar2(61) := c_package || 'upgrade_itax_description';
begin
--
	hr_utility.set_location('Entering: ' || c_proc, 10);
--
  if g_element_type_ids.count = 0 then
  --
    get_element_type_id('YEA_WITHHOLD_TAX_REPORT_INFO', g_element_type_ids);
  --
  end if;
--
  for i in 1..g_element_type_ids.count loop
  --
		sync_entries_and_results(p_assignment_id, g_element_type_ids(i));
	--
  end loop;
--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end upgrade_itax_description;
-- |-------------------------------------------------------------------|
-- |--------------------< validate_code_jp_pre_tax >-------------------|
-- |-------------------------------------------------------------------|
procedure validate_code_jp_pre_tax(p_valid_upgrade out nocopy varchar2)
is
  c_proc     constant varchar2(61) := c_package || 'validate_code_jp_pre_tax';
  --
  cursor csr_exists is
    select 'TRUE'
    from   pay_jp_pre_tax_old      ppt,
           pay_assignment_actions  paa
    where  paa.action_status = 'C'
    and    ppt.assignment_action_id = paa.assignment_action_id
    and    ppt.assignment_action_id NOT IN (
           select action_information1
           from   pay_action_information
           where  action_information_category = 'JP_PRE_TAX_1'
           and    action_context_type = 'AAP')
    and    rownum =1;

begin
  hr_utility.set_location('Entering: ' || c_proc, 10);
  --
  open csr_exists;
  fetch csr_exists into p_valid_upgrade;
  if csr_exists%notfound then
    p_valid_upgrade := 'FALSE';
  end if;
  close csr_exists;
  --
  hr_utility.trace(p_valid_upgrade);
  hr_utility.set_location('Leaving: ' || c_proc, 100);
end validate_code_jp_pre_tax;
-- |-------------------------------------------------------------------|
-- |--------------------< qualifying_jp_pre_tax >----------------------|
-- |-------------------------------------------------------------------|
procedure qualifying_jp_pre_tax(
  p_assignment_id  in  number,
  p_qualifier      out nocopy varchar2)
is
  c_proc  constant varchar2(61) := c_package || 'qualifying_jp_pre_tax';
  --
  cursor csr_ppt is
    select 'Y'
    from   pay_jp_pre_tax_old      ppt,
           pay_assignment_actions  paa
    where  paa.assignment_id = p_assignment_id
    and    paa.action_status = 'C'
    and    ppt.assignment_action_id = paa.assignment_action_id
    and    ppt.assignment_action_id NOT IN (
           select action_information1
           from   pay_action_information
           where  action_information_category = 'JP_PRE_TAX_1'
           and    action_context_type = 'AAP')
    and    rownum = 1;

begin
  hr_utility.set_location('Entering: ' || c_proc, 10);
  --
  open csr_ppt;
  fetch csr_ppt into p_qualifier;
  if csr_ppt%notfound then
    p_qualifier := 'N';
  end if;
  close csr_ppt;
  --
  hr_utility.trace(p_assignment_id || ' : ' || p_qualifier);
  hr_utility.set_location('Leaving: ' || c_proc, 100);
end qualifying_jp_pre_tax;
-- |-------------------------------------------------------------------|
-- |----------------------< upgrade_jp_pre_tax >-----------------------|
-- |-------------------------------------------------------------------|
procedure upgrade_jp_pre_tax(p_assignment_id in number)
is
  c_proc  constant varchar2(61) := c_package || 'upgrade_jp_pre_tax';
        --
  l_person_id                per_all_assignments_f.person_id%TYPE;
  l_period_of_service_id     per_all_assignments_f.period_of_service_id%TYPE;
  l_date_start               per_periods_of_service.date_start%TYPE;
  l_leaving_reason           per_periods_of_service.leaving_reason%TYPE;
  l_actual_termination_date  per_periods_of_service.actual_termination_date%TYPE;
  l_employment_category      per_all_assignments.employment_category%TYPE;
  l_effective_date           pay_payroll_actions.effective_date%TYPE;
        --
  l_action_info_id1          pay_action_information.action_information_id%TYPE;
  l_action_info_id2          pay_action_information.action_information_id%TYPE;
  l_ovn                      pay_action_information.object_version_number%TYPE;
  --
  cursor csr_pre_tax is
    select  ppt.*, ppa.effective_date
    from    pay_jp_pre_tax_old     ppt,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
    where   paa.assignment_id = p_assignment_id
    and     paa.assignment_action_id = ppt.assignment_action_id
    and     paa.payroll_action_id = ppa.payroll_action_id
    and not exists ( select 1
                     from   pay_action_information pai
                     where  ppt.assignment_action_id = pai.action_information1
                     and    paa.assignment_id = pai.assignment_id
                     and    pai.action_information_category = 'JP_PRE_TAX_1'
                     and    pai.action_context_type = 'AAP'
                   )
    for update of ppt.pre_tax_id;

begin
  begin
    hr_utility.set_location('Entering: ' || c_proc, 10);
    hr_utility.trace('assignment_id: ' || p_assignment_id);
    --
    for l_pre_tax in csr_pre_tax
    loop
      hr_utility.set_location(c_proc, 20);
      --
      l_effective_date := l_pre_tax.effective_date;
      --
      select asg.person_id,
             asg.period_of_service_id,
             pds.date_start,
             pds.leaving_reason,
             pds.actual_termination_date,
             asg.employment_category
      into   l_person_id,
             l_period_of_service_id,
             l_date_start,
             l_leaving_reason,
             l_actual_termination_date,
             l_employment_category
      from   per_all_assignments_f  asg,
             per_periods_of_service pds
      where  asg.assignment_id = p_assignment_id
      and    l_effective_date between asg.effective_start_date and asg.effective_end_date
      and    pds.period_of_service_id = asg.period_of_service_id;
      --
      hr_utility.trace('salary_category      : ' || l_pre_tax.salary_category);
      hr_utility.trace('taxable_sal_amt      : ' || l_pre_tax.taxable_sal_amt);
      hr_utility.trace('taxable_mat_amt      : ' || l_pre_tax.taxable_mat_amt);
      hr_utility.trace('previous_taxable_amt : ' || l_pre_tax.previous_taxable_amt);
      hr_utility.trace('hi_organization_id   : ' || l_pre_tax.hi_organization_id);
      hr_utility.trace('hi_prem_ee           : ' || l_pre_tax.hi_prem_ee);
      hr_utility.trace('hi_prem_er           : ' || l_pre_tax.hi_prem_er);
      hr_utility.trace('wp_organization_id   : ' || l_pre_tax.wp_organization_id);
      hr_utility.trace('wp_prem_ee           : ' || l_pre_tax.wp_prem_ee);
      hr_utility.trace('wp_prem_er           : ' || l_pre_tax.wp_prem_er);
      hr_utility.trace('wpf_organization_id  : ' || l_pre_tax.wpf_organization_id);
      hr_utility.trace('wpf_prem_ee          : ' || l_pre_tax.wpf_prem_ee);
      hr_utility.trace('wpf_prem_er          : ' || l_pre_tax.wpf_prem_er);
      hr_utility.trace('ui_organization_id   : ' || l_pre_tax.ui_organization_id);
      hr_utility.trace('ui_category          : ' || l_pre_tax.ui_category);
      hr_utility.trace('ui_prem_ee           : ' || l_pre_tax.ui_prem_ee);
      hr_utility.trace('ui_sal_amt           : ' || l_pre_tax.ui_sal_amt);
      hr_utility.trace('wai_organization_id  : ' || l_pre_tax.wai_organization_id);
      hr_utility.trace('wai_category         : ' || l_pre_tax.wai_category);
      hr_utility.trace('wai_sal_amt          : ' || l_pre_tax.wai_sal_amt);
      hr_utility.trace('itax_organization_id : ' || l_pre_tax.itax_organization_id);
      hr_utility.trace('itax_category        : ' || l_pre_tax.itax_category);
      hr_utility.trace('itax_yea_category    : ' || l_pre_tax.itax_yea_category);
      hr_utility.trace('itax                 : ' || l_pre_tax.itax);
      hr_utility.trace('itax_adjustment      : ' || l_pre_tax.itax_adjustment);
      hr_utility.trace('previous_itax        : ' || l_pre_tax.previous_itax);
      hr_utility.trace('ltax_organization_id : ' || l_pre_tax.ltax_organization_id);
      hr_utility.trace('ltax_district_code   : ' || l_pre_tax.ltax_district_code);
      hr_utility.trace('ltax_swot_no         : ' || l_pre_tax.ltax_swot_no);
      hr_utility.trace('ltax                 : ' || l_pre_tax.ltax);
      hr_utility.trace('ltax_lumpsum         : ' || l_pre_tax.ltax_lumpsum);
      hr_utility.trace('sp_ltax              : ' || l_pre_tax.sp_ltax);
      hr_utility.trace('sp_ltax_income       : ' || l_pre_tax.sp_ltax_income);
      hr_utility.trace('sp_ltax_shi          : ' || l_pre_tax.sp_ltax_shi);
      hr_utility.trace('sp_ltax_to           : ' || l_pre_tax.sp_ltax_to);
      hr_utility.trace('ci_prem_ee           : ' || l_pre_tax.ci_prem_ee);
      hr_utility.trace('ci_prem_er           : ' || l_pre_tax.ci_prem_er);
      hr_utility.trace('mutual_aid           : ' || l_pre_tax.mutual_aid);
      hr_utility.trace('disaster_tax_reduction : ' || l_pre_tax.disaster_tax_reduction);
      hr_utility.trace('sp_ltax_district_code  : ' || l_pre_tax.sp_ltax_district_code);
      --
      pay_action_information_api.create_action_information
      (
           p_action_information_id          =>  l_action_info_id1
           ,p_action_context_id             =>  l_pre_tax.assignment_action_id
           ,p_action_context_type           =>  'AAP'
           ,p_object_version_number         =>  l_ovn
           ,p_effective_date                =>  l_effective_date
           ,p_assignment_id                 =>  p_assignment_id
           ,p_action_information_category   =>  'JP_PRE_TAX_1'
           ,p_action_information1      =>  fnd_number.number_to_canonical(l_pre_tax.assignment_action_id)
           ,p_action_information2      =>  fnd_number.number_to_canonical(l_pre_tax.taxable_sal_amt)
           ,p_action_information3      =>  fnd_number.number_to_canonical(l_pre_tax.taxable_mat_amt)
           ,p_action_information4      =>  fnd_number.number_to_canonical(l_person_id)
           ,p_action_information5      =>  l_pre_tax.hi_organization_id
           ,p_action_information6      =>  fnd_number.number_to_canonical(l_pre_tax.hi_prem_ee)
           ,p_action_information7      =>  fnd_number.number_to_canonical(l_pre_tax.hi_prem_er)
           ,p_action_information8      =>  l_pre_tax.wp_organization_id
           ,p_action_information9      =>  fnd_number.number_to_canonical(l_pre_tax.wp_prem_ee)
           ,p_action_information10     =>  fnd_number.number_to_canonical(l_pre_tax.wp_prem_er)
           ,p_action_information11     =>  l_pre_tax.wpf_organization_id
           ,p_action_information12     =>  fnd_number.number_to_canonical(l_pre_tax.wpf_prem_ee)
           ,p_action_information13     =>  l_pre_tax.salary_category
           ,p_action_information14     =>  fnd_number.number_to_canonical(l_pre_tax.mutual_aid)
           ,p_action_information15     =>  fnd_number.number_to_canonical(l_period_of_service_id)
           ,p_action_information16     =>  to_char(l_date_start,'YYYY/MM/DD')
           ,p_action_information17     =>  l_leaving_reason
           ,p_action_information18     =>  to_char(l_actual_termination_date,'YYYY/MM/DD')
           ,p_action_information19     =>  l_pre_tax.ui_organization_id
           ,p_action_information20     =>  fnd_number.number_to_canonical(l_pre_tax.ui_prem_ee)
           ,p_action_information21     =>  l_pre_tax.itax_organization_id
           ,p_action_information22     =>  l_pre_tax.itax_category
           ,p_action_information23     =>  l_pre_tax.itax_yea_category
           ,p_action_information24     =>  fnd_number.number_to_canonical(l_pre_tax.itax)
           ,p_action_information25     =>  fnd_number.number_to_canonical(l_pre_tax.itax_adjustment)
           ,p_action_information26     =>  fnd_number.number_to_canonical(l_pre_tax.pre_tax_id)
           ,p_action_information29     =>  fnd_number.number_to_canonical(l_pre_tax.disaster_tax_reduction)
           ,p_action_information30     =>  l_employment_category
          );

     pay_action_information_api.create_action_information
     (
            p_action_information_id         =>  l_action_info_id2
           ,p_action_context_id             =>  l_pre_tax.assignment_action_id
           ,p_action_context_type           =>  'AAP'
           ,p_object_version_number         =>  l_ovn
           ,p_effective_date                =>  l_effective_date
           ,p_assignment_id                 =>  p_assignment_id
           ,p_action_information_category   =>  'JP_PRE_TAX_2'
           ,p_action_information1      =>  l_pre_tax.assignment_action_id
           ,p_action_information3      =>  l_pre_tax.ltax_district_code
           ,p_action_information5      =>  fnd_number.number_to_canonical(l_pre_tax.ltax)
           ,p_action_information6      =>  fnd_number.number_to_canonical(l_pre_tax.ltax_lumpsum)
           ,p_action_information7      =>  fnd_number.number_to_canonical(l_pre_tax.sp_ltax)
           ,p_action_information8      =>  fnd_number.number_to_canonical(l_pre_tax.sp_ltax_income)
           ,p_action_information9      =>  fnd_number.number_to_canonical(l_pre_tax.sp_ltax_shi)
           ,p_action_information10     =>  fnd_number.number_to_canonical(l_pre_tax.sp_ltax_to)
           ,p_action_information11     =>  fnd_number.number_to_canonical(l_pre_tax.ci_prem_ee)
           ,p_action_information12     =>  fnd_number.number_to_canonical(l_pre_tax.ci_prem_er)
           ,p_action_information13     =>  fnd_number.number_to_canonical(0)
           ,p_action_information14     =>  l_pre_tax.ui_category
           ,p_action_information15     =>  l_pre_tax.sp_ltax_district_code
           ,p_action_information16     =>  fnd_number.number_to_canonical(l_pre_tax.ui_sal_amt)
           ,p_action_information17     =>  l_pre_tax.wai_organization_id
           ,p_action_information18     =>  l_pre_tax.wai_category
           ,p_action_information19     =>  fnd_number.number_to_canonical(l_pre_tax.wai_sal_amt)
           ,p_action_information20     =>  fnd_number.number_to_canonical(l_pre_tax.wpf_prem_er)
           ,p_action_information21     =>  fnd_number.number_to_canonical(0)
     );

     end loop;
   --
   hr_utility.set_location('Leaving: ' || c_proc, 100);
   --
   exception
     when app_exception.application_exception then
       app_exception.raise_exception;
   end;
   --
exception
  when others then
    if g_num_errors = 0 then
      fnd_file.put_line(fnd_file.log, fnd_message.get_string('PAY', 'PAY_JP_RETRY_JP_PRE_TAX_UPG'));
      fnd_file.put_line(fnd_file.log,
       rpad(fnd_message.get_string('PAY', 'PAY_JP_ASSIGNMENT_ID'), 30) || ' ' ||       fnd_message.get_string('FND', 'FND_MESSAGE_TYPE_ERROR'));
      fnd_file.put_line(fnd_file.log, rpad('-', 30, '-') || ' ' || rpad('-', 100, '-'));
    end if;
    g_num_errors := g_num_errors + 1;
    --
    fnd_file.put_line(fnd_file.log, rpad(p_assignment_id, 30) || ' ' || sqlerrm);
    raise;
end upgrade_jp_pre_tax;
-- |-------------------------------------------------------------------|
-- |-------------------< validate_yea_national_pens >------------------|
-- |-------------------------------------------------------------------|
-- pay_upgrade_definitions.validate_procedure is revoked from hr_update_utility (hrglobal)
procedure validate_yea_national_pens(
  p_valid_upgrade out nocopy varchar2)
is
--
  c_proc  constant varchar2(61) := c_package || 'validate_yea_national_pens';
--
begin
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  if g_element_type_ids.count = 0 then
  --
    get_element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_INFO', g_element_type_ids);
  --
  end if;
--
  for i in 1..g_element_type_ids.count loop
    -- At first, upgrade PAY_LINK_INPUT_VALUES_F.
    pay_jp_generic_upgrade_pkg.sync_link_input_values(g_element_type_ids(i));
    --
  end loop;
--
  if entries_or_results_exist('JP') then
    p_valid_upgrade := 'TRUE';
  else
    p_valid_upgrade := 'FALSE';
  end if;
--
  hr_utility.trace(p_valid_upgrade);
--
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end validate_yea_national_pens;
-- |-------------------------------------------------------------------|
-- |------------------< qualify_yea_national_pens >--------------------|
-- |-------------------------------------------------------------------|
-- pay_upgrade_definitions.qualifying_procedure is revoked from pay_generic_upgrade
procedure qualify_yea_national_pens(
  p_assignment_id in number,
  p_qualifier     out nocopy varchar2)
is
  c_proc  constant varchar2(61) := c_package || 'qualify_yea_national_pens';
begin
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  if entries_or_results_exist(p_assignment_id => p_assignment_id) then
    p_qualifier := 'Y';
  else
    p_qualifier := 'N';
  end if;
--
  hr_utility.trace(p_assignment_id || ' : ' || p_qualifier);
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end qualify_yea_national_pens;
-- |-------------------------------------------------------------------|
-- |-------------------< upgrade_yea_national_pens >-------------------|
-- |-------------------------------------------------------------------|
procedure upgrade_yea_national_pens(
  p_assignment_id in number)
is
  c_proc  constant varchar2(61) := c_package || 'upgrade_yea_national_pens';
begin
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  if g_element_type_ids.count = 0 then
  --
    get_element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_INFO', g_element_type_ids);
  --
  end if;
--
	for i in 1..g_element_type_ids.count loop
	--
		sync_entries_and_results(p_assignment_id, g_element_type_ids(i));
	--
	end loop;
--
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end upgrade_yea_national_pens;
-- |-------------------------------------------------------------------|
-- |--------------------< init_yea_earthquake_ins >--------------------|
-- |-------------------------------------------------------------------|
procedure init_yea_earthquake_ins
is
	c_proc		constant varchar2(61) := c_package || 'init_yea_earthquake_ins';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if g_element_type_ids.count = 0 then
		hr_utility.trace('Not cached.');
		--
		get_element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_INFO', g_element_type_ids);
		get_element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_RSLT', g_element_type_ids);
		get_element_type_id('INI_YEA2', g_element_type_ids);
		get_element_type_id('YEA_INS_PREM_EXM_DECLARE_INFO', g_element_type_ids);
	end if;
	--
	for i in 1..g_element_type_ids.count loop
		hr_utility.trace(i || ': ' || g_element_type_ids(i));
	end loop;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end init_yea_earthquake_ins;
-- |-------------------------------------------------------------------|
-- |------------------< validate_yea_earthquake_ins >------------------|
-- |-------------------------------------------------------------------|
-- pay_upgrade_definitions.validate_procedure is revoked from hr_update_utility (hrglobal)
procedure validate_yea_earthquake_ins(p_valid_upgrade out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'validate_yea_earthquake_ins';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	-- At first, upgrade PAY_LINK_INPUT_VALUES_F.
	--
	init_yea_earthquake_ins;
	--
	for i in 1..g_element_type_ids.count loop
		pay_jp_generic_upgrade_pkg.sync_link_input_values(g_element_type_ids(i));
	end loop;
	--
	if entries_or_results_exist(p_legislation_code => 'JP') then
		p_valid_upgrade := 'TRUE';
	else
		p_valid_upgrade := 'FALSE';
	end if;
	--
	hr_utility.trace(p_valid_upgrade);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end validate_yea_earthquake_ins;
-- |-------------------------------------------------------------------|
-- |------------------< qualify_yea_earthquake_ins >-------------------|
-- |-------------------------------------------------------------------|
-- pay_upgrade_definitions.qualifying_procedure is revoked from pay_generic_upgrade
procedure qualify_yea_earthquake_ins(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'qualify_yea_earthquake_ins';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if entries_or_results_exist(p_assignment_id => p_assignment_id) then
		p_qualifier := 'Y';
	else
		p_qualifier := 'N';
	end if;
	--
	hr_utility.trace(p_assignment_id || ' : ' || p_qualifier);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end qualify_yea_earthquake_ins;
-- |-------------------------------------------------------------------|
-- |------------------< upgrade_yea_earthquake_ins >-------------------|
-- |-------------------------------------------------------------------|
procedure upgrade_yea_earthquake_ins(p_assignment_id in number)
is
	c_proc		constant varchar2(61) := c_package || 'upgrade_yea_earthquake_ins';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	init_yea_earthquake_ins;
	--
	for i in 1..g_element_type_ids.count loop
		sync_entries_and_results(p_assignment_id, g_element_type_ids(i));
	end loop;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end upgrade_yea_earthquake_ins;
-- |-------------------------------------------------------------------|
-- |---------------------< validate_itw_archive >----------------------|
-- |-------------------------------------------------------------------|
procedure validate_itw_archive(p_valid_upgrade out nocopy varchar2)
is
	c_proc				constant varchar2(61) := c_package || 'validate_itw_archive';
	l_legislative_parameters	pay_payroll_actions.legislative_parameters%type;
	l_payroll_id			number;
	l_itax_organization_id		number;
	l_include_terminated_flag	varchar2(1);
	l_termination_date_from		date;
	l_termination_date_to		date;
	l_rearchive_flag		varchar2(1);
	l_inherit_archive_flag		varchar2(1);
	l_publication_period_status	varchar2(1);
	l_publication_start_date	date;
	l_publication_end_date		date;
	--
	l_id				number;
	l_ovn				number;
	--
	cursor csr_pacts is
	select	payroll_action_id,
		effective_date,
		legislative_parameters
	from	pay_payroll_actions	ppa
	where	ppa.action_type = 'X'
	and	ppa.report_type = 'JPTW'
	and	ppa.report_qualifier = 'JP'
	and	ppa.report_category = 'ARCHIVE'
--	and	ppa.action_status <> 'P'
	and	pay_core_utils.get_parameter('INCLUDE_TERMINATED_FLAG', legislative_parameters) is null;
/*
	and	not exists(
			select	null
			from	pay_action_information	pai
			where	pai.action_context_id = ppa.payroll_action_id
			and	pai.action_context_type = 'PA'
			and	pai.action_information_category = 'JP_ITAX_PACT');
*/
	--
	procedure concat_parameter(
		p_token_name	in varchar2,
		p_token_value	in varchar2)
	is
		l_separator	varchar2(1);
	begin
		if p_token_name is not null and p_token_value is not null then
			if l_legislative_parameters is not null then
				l_legislative_parameters := l_legislative_parameters || ' ';
			end if;
			--
			if instr(p_token_value, ' ') > 0 then
				l_separator := '|';
			end if;
			--
			l_legislative_parameters := l_legislative_parameters
						 || p_token_value || ' '
						 || p_token_name || '='
						 || l_separator || p_token_value || l_separator;
		end if;
	end concat_parameter;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	p_valid_upgrade := 'FALSE';
	--
	for l_pact in csr_pacts loop
		p_valid_upgrade := 'TRUE';
		--
		l_payroll_id			:= fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL', l_pact.legislative_parameters));
		l_itax_organization_id		:= fnd_number.canonical_to_number(pay_core_utils.get_parameter('SWOT', l_pact.legislative_parameters));
		l_include_terminated_flag	:= 'Y';
		l_termination_date_from		:= null;
		l_termination_date_to		:= null;
		l_rearchive_flag		:= 'Y';
		l_inherit_archive_flag		:= 'Y';
		l_publication_period_status	:= 'O';
		l_publication_start_date	:= fnd_date.canonical_to_date(pay_core_utils.get_parameter('OPEN_DATE', l_pact.legislative_parameters));
		l_publication_end_date		:= fnd_date.canonical_to_date(pay_core_utils.get_parameter('CLOSE_DATE', l_pact.legislative_parameters));
		--
		l_legislative_parameters := null;
		concat_parameter('PAYROLL_ID', fnd_number.number_to_canonical(l_payroll_id));
		concat_parameter('ITAX_ORGANIZATION_ID', fnd_number.number_to_canonical(l_itax_organization_id));
		concat_parameter('INCLUDE_TERMINATED_FLAG', l_include_terminated_flag);
		concat_parameter('TERMINATION_DATE_FROM', fnd_date.date_to_canonical(l_termination_date_from));
		concat_parameter('TERMINATION_DATE_TO', fnd_date.date_to_canonical(l_termination_date_to));
		concat_parameter('REARCHIVE_FLAG', l_rearchive_flag);
		concat_parameter('INHERIT_ARCHIVE_FLAG', l_inherit_archive_flag);
		concat_parameter('PUBLICATION_PERIOD_STATUS', l_publication_period_status);
		concat_parameter('PUBLICATION_START_DATE', fnd_date.date_to_canonical(l_publication_start_date));
		concat_parameter('PUBLICATION_END_DATE', fnd_date.date_to_canonical(l_publication_end_date));
		concat_parameter('UPGRADE_FLAG', 'Y');
		--
		hr_utility.trace('payroll_action_id: ' || l_pact.payroll_action_id);
		hr_utility.trace('legislative_parameters: ' || l_legislative_parameters);
		--
		update	pay_payroll_actions
		set	legislative_parameters = l_legislative_parameters
		where	payroll_action_id = l_pact.payroll_action_id;
		--
		pay_action_information_api.create_action_information(
			p_validate			=> false,
			p_action_context_id		=> l_pact.payroll_action_id,
			p_action_context_type		=> 'PA',
			p_action_information_category	=> 'JP_ITAX_PACT',
			p_effective_date		=> l_pact.effective_date,
			p_action_information1		=> fnd_number.number_to_canonical(l_payroll_id),
			p_action_information2		=> fnd_number.number_to_canonical(l_itax_organization_id),
			p_action_information3		=> l_include_terminated_flag,
			p_action_information4		=> fnd_date.date_to_canonical(l_termination_date_from),
			p_action_information5		=> fnd_date.date_to_canonical(l_termination_date_to),
			p_action_information6		=> l_publication_period_status,
			p_action_information7		=> fnd_date.date_to_canonical(l_publication_start_date),
			p_action_information8		=> fnd_date.date_to_canonical(l_publication_end_date),
			p_action_information_id		=> l_id,
			p_object_version_number		=> l_ovn);
	end loop;
	--
	hr_utility.trace(p_valid_upgrade);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end validate_itw_archive;
-- |-------------------------------------------------------------------|
-- |----------------------< qualify_itw_archive >----------------------|
-- |-------------------------------------------------------------------|
procedure qualify_itw_archive(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'qualify_itw_archive';
	--
	-- Old archiver does not have PACT level archive data.
	-- This checks whether the archive needs to be upgraded or not
	-- using PACT level archive data.
	--
	cursor csr_upgrade_required is
	select	'Y'
	from	dual
	where	exists(
			select	null
			from	pay_assignment_actions	paa,
				pay_payroll_actions	ppa
			where	paa.assignment_id = p_assignment_id
			and	paa.action_status = 'C'
			and	ppa.payroll_action_id = paa.payroll_action_id
			and	ppa.action_type = 'X'
			and	ppa.report_type = 'JPTW'
			and	ppa.report_qualifier = 'JP'
			and	ppa.report_category = 'ARCHIVE'
			and	pay_core_utils.get_parameter('UPGRADE_FLAG', ppa.legislative_parameters) = 'Y');
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_upgrade_required;
	fetch csr_upgrade_required into p_qualifier;
	if csr_upgrade_required%notfound then
		p_qualifier := 'N';
	end if;
	close csr_upgrade_required;
	--
	hr_utility.trace(p_assignment_id || ': ' || p_qualifier);
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end qualify_itw_archive;
-- |-------------------------------------------------------------------|
-- |-----------------------< to_canonical_date >-----------------------|
-- |-------------------------------------------------------------------|
function to_canonical_date(p_str in varchar2) return varchar2
is
	l_str		varchar2(30) := p_str;
begin
	if l_str is not null then
		if length(l_str) = 7 then
			l_str := fnd_date.date_to_canonical(hr_jp_standard_pkg.to_jp_date(l_str, 'EYYMMDD'));
		elsif length(l_str) = 10 then
			l_str := fnd_date.date_to_canonical(to_date(l_str, 'YYYY/MM/DD'));
		end if;
	end if;
	--
	return l_str;
end to_canonical_date;
-- |-------------------------------------------------------------------|
-- |----------------------< upgrade_itw_archive >----------------------|
-- |-------------------------------------------------------------------|
procedure upgrade_itw_archive(p_assignment_id in number)
is
	c_proc		constant varchar2(61) := c_package || 'validate_itw_archive';
	--
	l_varchar2_tbl			hr_jp_standard_pkg.t_varchar2_tbl;
	l_itw_user_desc_kanji1		varchar2(240);
	l_itw_user_desc_kanji2		varchar2(240);
	l_dummy				varchar2(32767);
	l_wtm_user_desc_kanji1		varchar2(240);
	l_wtm_user_desc_kanji2		varchar2(240);
	l_wtm_user_desc_kana1		varchar2(240);
	l_wtm_user_desc_kana2		varchar2(240);
	--
	cursor csr is
	select	person.rowid			person_rowid,
		arch.rowid			arch_rowid,
		arch.action_information16 ||
		arch.action_information17 ||
		arch.action_information18 ||
		arch.action_information19 ||
		arch.action_information20	ITW_USER_DESC_KANJI,
		arch.action_information21 ||
		arch.action_information22 ||
		arch.action_information23 ||
		arch.action_information24 ||
		arch.action_information25	WTM_USER_DESC,
		other2.rowid			other2_rowid,
		other2.action_information13	ITW_OVERRIDE_FLAG,
		other2.action_information14	WTM_OVERRIDE_FLAG,
		other2.ACTION_INFORMATION23	ITW_SYSTEM_DESC1_KANJI,
		other2.ACTION_INFORMATION15	ITW_SYSTEM_DESC2_KANJI_1,
		other2.ACTION_INFORMATION16	ITW_SYSTEM_DESC2_KANJI_2,
		other2.ACTION_INFORMATION19	WTM_SYSTEM_DESC_KANJI_1,
		other2.ACTION_INFORMATION20	WTM_SYSTEM_DESC_KANJI_2,
		other2.ACTION_INFORMATION21	WTM_SYSTEM_DESC_KANA_1,
		other2.ACTION_INFORMATION22	WTM_SYSTEM_DESC_KANA_2
	from	pay_assignment_actions	paa,
		pay_payroll_actions	ppa,
		pay_action_information	person,
		pay_action_information	arch,
		pay_action_information	other2
	where	paa.assignment_id = p_assignment_id
	and	paa.action_status = 'C'
	and	ppa.payroll_action_id = paa.payroll_action_id
	and	ppa.action_type = 'X'
	and	ppa.report_type = 'JPTW'
	and	ppa.report_qualifier = 'JP'
	and	ppa.report_category = 'ARCHIVE'
	and	pay_core_utils.get_parameter('UPGRADE_FLAG', ppa.legislative_parameters) = 'Y'
	and	person.action_context_id = paa.assignment_action_id
	and	person.action_context_type = 'AAP'
	and	person.action_information_category = 'JP_ITAX_PERSON'
	and	arch.action_context_id = person.action_context_id
	and	arch.action_context_type = 'AAP'
	and	arch.action_information_category = 'JP_ITAX_ARCH'
	and	arch.effective_date = person.effective_date
	and	other2.action_context_id = person.action_context_id
	and	other2.action_context_type = 'AAP'
	and	other2.action_information_category = 'JP_ITAX_OTHER2'
	and	other2.effective_date = person.effective_date
	for update of
		person.action_information_id,
		other2.action_information_id nowait;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	for l_rec in csr loop
		--
		-- JP_ITAX_PERSON
		--
		update	pay_action_information
		set	action_information11 = to_canonical_date(action_information11),
			action_information13 = to_canonical_date(action_information13),
			action_information25 = to_canonical_date(action_information25),
--			action_information27 = 'O'
			action_information27 = null
		where	rowid = l_rec.person_rowid;
		--
		-- JP_ITAX_ARCH
		--
		update	pay_action_information
		set	action_information12 = to_canonical_date(action_information12)
		where	rowid = l_rec.arch_rowid;
		--
		-- JP_ITAX_OTHER2
		--
		-- ITW User Description
		--
		l_dummy := rtrim(substrb(l_rec.itw_user_desc_kanji, 1, 300));
		hr_jp_standard_pkg.to_table(l_dummy, 240, l_varchar2_tbl);
		l_itw_user_desc_kanji1 := hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 1);
		l_itw_user_desc_kanji2 := hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 2);
		--
		-- ITW System Description
		--
		if l_rec.itw_override_flag = 'Y' then
			l_rec.ITW_SYSTEM_DESC1_KANJI	:= null;
			l_rec.ITW_SYSTEM_DESC2_KANJI_1	:= null;
			l_rec.ITW_SYSTEM_DESC2_KANJI_2	:= null;
		else
			l_rec.ITW_SYSTEM_DESC1_KANJI	:= rtrim(substrb(l_rec.ITW_SYSTEM_DESC1_KANJI, 1, 240));
			--
			l_dummy := rtrim(substrb(l_rec.ITW_SYSTEM_DESC2_KANJI_1 || l_rec.ITW_SYSTEM_DESC2_KANJI_2, 1, 300));
			hr_jp_standard_pkg.to_table(l_dummy, 240, l_varchar2_tbl);
			l_rec.ITW_SYSTEM_DESC2_KANJI_1	:= hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 1);
			l_rec.ITW_SYSTEM_DESC2_KANJI_2	:= hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 2);
		end if;
		--
		-- WTM User Description
		--
		l_dummy := hr_jp_standard_pkg.to_zenkaku(l_rec.wtm_user_desc);
		l_dummy := substr(l_dummy, 1, 100);
		hr_jp_standard_pkg.to_table(l_dummy, 240, l_varchar2_tbl);
		l_wtm_user_desc_kanji1 := hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 1);
		l_wtm_user_desc_kanji2 := hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 2);
		--
		l_dummy := hr_jp_standard_pkg.upper_kana(hr_jp_standard_pkg.to_hankaku(l_rec.wtm_user_desc, '?'));
		l_dummy := substr(l_dummy, 1, 100);
		hr_jp_standard_pkg.to_table(l_dummy, 240, l_varchar2_tbl);
		l_wtm_user_desc_kana1 := hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 1);
		l_wtm_user_desc_kana2 := hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 2);
		--
		-- WTM System Description
		--
		if l_rec.wtm_override_flag = 'Y' then
			l_rec.WTM_SYSTEM_DESC_KANJI_1	:= null;
			l_rec.WTM_SYSTEM_DESC_KANJI_2	:= null;
			l_rec.WTM_SYSTEM_DESC_KANA_1	:= null;
			l_rec.WTM_SYSTEM_DESC_KANA_2	:= null;
		else
			l_dummy := hr_jp_standard_pkg.to_zenkaku(l_rec.WTM_SYSTEM_DESC_KANJI_1 || l_rec.WTM_SYSTEM_DESC_KANJI_2);
			l_dummy := substr(l_dummy, 1, 100);
			hr_jp_standard_pkg.to_table(l_dummy, 240, l_varchar2_tbl);
			l_rec.WTM_SYSTEM_DESC_KANJI_1	:= hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 1);
			l_rec.WTM_SYSTEM_DESC_KANJI_2	:= hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 2);
			--
			l_dummy := hr_jp_standard_pkg.upper_kana(hr_jp_standard_pkg.to_hankaku(l_rec.WTM_SYSTEM_DESC_KANA_1 || l_rec.WTM_SYSTEM_DESC_KANA_2, '?'));
			l_dummy := substr(l_dummy, 1, 100);
			hr_jp_standard_pkg.to_table(l_dummy, 240, l_varchar2_tbl);
			l_rec.WTM_SYSTEM_DESC_KANA_1	:= hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 1);
			l_rec.WTM_SYSTEM_DESC_KANA_2	:= hr_jp_standard_pkg.get_index_at(l_varchar2_tbl, 2);
		end if;
		--
		update	pay_action_information
		set	ACTION_INFORMATION23 = l_rec.ITW_SYSTEM_DESC1_KANJI,
			ACTION_INFORMATION15 = l_rec.ITW_SYSTEM_DESC2_KANJI_1,
			ACTION_INFORMATION16 = l_rec.ITW_SYSTEM_DESC2_KANJI_2,
			ACTION_INFORMATION19 = l_rec.WTM_SYSTEM_DESC_KANJI_1,
			ACTION_INFORMATION20 = l_rec.WTM_SYSTEM_DESC_KANJI_2,
			ACTION_INFORMATION21 = l_rec.WTM_SYSTEM_DESC_KANA_1,
			ACTION_INFORMATION22 = l_rec.WTM_SYSTEM_DESC_KANA_2,
			action_information25 = l_itw_user_desc_kanji1,
			action_information26 = l_itw_user_desc_kanji2,
			action_information27 = l_wtm_user_desc_kanji1,
			action_information28 = l_wtm_user_desc_kanji2,
			action_information29 = l_wtm_user_desc_kana1,
			action_information30 = l_wtm_user_desc_kana2
		where	rowid = l_rec.other2_rowid;
	end loop;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end upgrade_itw_archive;
--
-- -------------------------------------------------------------------------
-- qualify_hi_smr_data
-- -------------------------------------------------------------------------
-- run by pay_generic_upgrade.action_creation
-- do_qualification run before calling hr_nonrun_asact.insact in create_object_action
procedure qualify_hi_smr_data(
  p_assignment_id in number,
  p_qualifier out nocopy varchar2)
is
--
  l_proc varchar2(80) := c_package||'qualify_hi_smr_data';
--
  l_valid_delete varchar2(1) := 'N';
--
  l_ass_info hr_jp_data_migration_pkg.t_ass_hi_smr_rec;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_assignment_id : '||to_char(p_assignment_id));
  end if;
--
  hr_jp_data_migration_pkg.init_def_hi_smr_data;
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('hr_jp_data_migration_pkg.g_skip_qualify : '||hr_jp_data_migration_pkg.g_skip_qualify);
    hr_utility.trace('hr_jp_data_migration_pkg.g_upd_mode     : '||hr_jp_data_migration_pkg.g_upd_mode);
    hr_utility.trace('hr_jp_data_migration_pkg.g_mig_date     : '||to_char(hr_jp_data_migration_pkg.g_mig_date,'YYYY/MM/DD'));
  end if;
--
  if hr_jp_data_migration_pkg.g_skip_qualify = 'N' then
  --
    if g_debug then
      hr_utility.set_location(l_proc,20);
    end if;
  --
  -- print header for each threads but it is ok because just log.
    hr_jp_data_migration_pkg.qualify_hi_smr_hd(
      p_assignment_id => p_assignment_id);
  --
    if g_debug then
      hr_utility.set_location(l_proc,30);
    end if;
  --
    l_ass_info := hr_jp_data_migration_pkg.get_ass_info(
                    p_assignment_id  => p_assignment_id,
                    p_effective_date => hr_jp_data_migration_pkg.g_mig_date);
  --
    if g_debug then
      hr_utility.set_location(l_proc,40);
      hr_utility.trace('l_ass_info.ass_id : '||to_char(l_ass_info.ass_id));
    end if;
  --
    hr_jp_data_migration_pkg.val_mig_smr_assact(
      p_business_group_id   => l_ass_info.bg_id,
      p_business_group_name => l_ass_info.bg_name,
      p_assignment_id       => p_assignment_id,
      p_assignment_number   => l_ass_info.ass_num,
      p_session_date        => hr_jp_data_migration_pkg.g_mig_date,
      p_valid_delete        => l_valid_delete);
  --
    if g_debug then
      hr_utility.set_location(l_proc,50);
      hr_utility.trace('l_valid_delete : '||l_valid_delete);
    end if;
  --
    p_qualifier := l_valid_delete;
  --
  -- never come here at this moment.
  -- notice: include following case in target because skip qualify.
  --         1. ee null
  --         2. ee already updated (manual update)
  --         3. future entry exists
  --         4. in update mode applied month is future (>= p_session_date)
  --         5. mr is null
  else
  --
    p_qualifier := 'Y';
  --
    if g_debug then
      hr_utility.set_location(l_proc,60);
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('p_qualifier : '||p_qualifier);
    hr_utility.set_location(l_proc,1000);
  end if;
--
end qualify_hi_smr_data;
--
-- -------------------------------------------------------------------------
-- migrate_hi_smr_data
-- -------------------------------------------------------------------------
-- run by pay_generic_upgrade.upgrade_data
procedure migrate_hi_smr_data(
  p_assignment_id in number)
is
--
  l_proc varchar2(80) := c_package||'migrate_hi_smr_data';
--
  l_ass_info hr_jp_data_migration_pkg.t_ass_hi_smr_rec;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_assignment_id : '||to_char(p_assignment_id));
  end if;
--
  -- need to reset for retry, qualify_obs_data is not called in retry process.
  hr_jp_data_migration_pkg.init_def_hi_smr_data;
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('hr_jp_data_migration_pkg.g_skip_qualify : '||hr_jp_data_migration_pkg.g_skip_qualify);
    hr_utility.trace('hr_jp_data_migration_pkg.g_upd_mode     : '||hr_jp_data_migration_pkg.g_upd_mode);
    hr_utility.trace('hr_jp_data_migration_pkg.g_mig_date     : '||to_char(hr_jp_data_migration_pkg.g_mig_date,'YYYY/MM/DD'));
  end if;
--
  -- print header for each threads but it is ok because just log.
  hr_jp_data_migration_pkg.migrate_hi_smr_hd(
    p_assignment_id => p_assignment_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
  end if;
--
  l_ass_info := hr_jp_data_migration_pkg.get_ass_info(
                  p_assignment_id  => p_assignment_id,
                  p_effective_date => hr_jp_data_migration_pkg.g_mig_date);
--
  if g_debug then
    hr_utility.set_location(l_proc,30);
    hr_utility.trace('l_ass_info.ass_id : '||to_char(l_ass_info.ass_id));
  end if;
--
  -- for api use
  hr_jp_data_migration_pkg.insert_session(
    p_effective_date => hr_jp_data_migration_pkg.g_mig_date);
  --
  hr_jp_data_migration_pkg.mig_smr_assact(
    p_business_group_id   => l_ass_info.bg_id,
    p_business_group_name => l_ass_info.bg_name,
    p_assignment_id       => p_assignment_id,
    p_assignment_number   => l_ass_info.ass_num,
    p_session_date        => hr_jp_data_migration_pkg.g_mig_date,
    p_hi_mr               => null);
--
  -- delete session is invalid, cause no data found.
  --hr_jp_data_migration_pkg.delete_session;
  --
  -- commit is invalid in archive loop for ORA-01002
  -- automatically commit will be executed for each assignment in archive process.
  --  commit;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end migrate_hi_smr_data;
--
-- -------------------------------------------------------------------------
-- init_adj_ann_std_bon
-- -------------------------------------------------------------------------
procedure init_adj_ann_std_bon
is
--
  c_proc constant varchar2(61) := c_package||'init_adj_ann_std_bon';
--
begin
--
  if g_debug then
    hr_utility.set_location('Entering: ' || c_proc, 10);
  end if;
--
  if g_element_type_ids.count = 0 then
  --
    if g_debug then
      hr_utility.trace('Not cached.');
    end if;
  --
    get_element_type_id('BON_HI_ADJ_INFO', g_element_type_ids);
    get_element_type_id('BON_HI_STD_BON', g_element_type_ids);
  --
  end if;
--
  for i in 1..g_element_type_ids.count loop
  --
    if g_debug then
      hr_utility.trace(i || ': ' || g_element_type_ids(i));
    end if;
  --
  end loop;
--
  if g_debug then
    hr_utility.set_location('Leaving: ' || c_proc, 100);
  end if;
--
end init_adj_ann_std_bon;
--
-- -------------------------------------------------------------------------
-- validate_adj_ann_std_bon
-- -------------------------------------------------------------------------
-- pay_upgrade_definitions.validate_procedure is revoked from hr_update_utility (hrglobal)
procedure validate_adj_ann_std_bon(
  p_valid_upgrade out nocopy varchar2)
is
--
  c_proc  constant varchar2(61) := c_package || 'validate_adj_ann_std_bon';
--
begin
--
  if g_debug then
    hr_utility.set_location('Entering: ' || c_proc, 10);
  end if;
--
  init_adj_ann_std_bon;
--
  for i in 1..g_element_type_ids.count loop
    -- At first, upgrade PAY_LINK_INPUT_VALUES_F.
    pay_jp_generic_upgrade_pkg.sync_link_input_values(g_element_type_ids(i));
    --
  end loop;
--
  if entries_or_results_exist('JP') then
    p_valid_upgrade := 'TRUE';
  else
    p_valid_upgrade := 'FALSE';
  end if;
--
  if g_debug then
    hr_utility.trace(p_valid_upgrade);
    hr_utility.set_location('Leaving: ' || c_proc, 100);
  end if;
--
end validate_adj_ann_std_bon;
--
-- -------------------------------------------------------------------------
-- qualify_adj_ann_std_bon
-- -------------------------------------------------------------------------
-- pay_upgrade_definitions.qualifying_procedure is revoked from pay_generic_upgrade
procedure qualify_adj_ann_std_bon(
  p_assignment_id in number,
  p_qualifier     out nocopy varchar2)
is
  c_proc  constant varchar2(61) := c_package || 'qualify_adj_ann_std_bon';
begin
--
  if g_debug then
    hr_utility.set_location('Entering: ' || c_proc, 10);
  end if;
--
  if entries_or_results_exist(p_assignment_id => p_assignment_id) then
    p_qualifier := 'Y';
  else
    p_qualifier := 'N';
  end if;
--
  hr_utility.trace(p_assignment_id || ' : ' || p_qualifier);
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end qualify_adj_ann_std_bon;
--
-- -------------------------------------------------------------------------
-- upgrade_adj_ann_std_bon
-- -------------------------------------------------------------------------
procedure upgrade_adj_ann_std_bon(
  p_assignment_id in number)
is
  c_proc  constant varchar2(61) := c_package || 'upgrade_adj_ann_std_bon';
begin
--
  if g_debug then
    hr_utility.set_location('Entering: ' || c_proc, 10);
  end if;
--
  init_adj_ann_std_bon;
--
	for i in 1..g_element_type_ids.count loop
    sync_entries_and_results(p_assignment_id, g_element_type_ids(i));
	end loop;
--
  if g_debug then
    hr_utility.set_location('Leaving: ' || c_proc, 100);
  end if;
--
end upgrade_adj_ann_std_bon;
--
/*
-- |-------------------------------------------------------------------|
-- |------------------------< submit_request >-------------------------|
-- |-------------------------------------------------------------------|
function submit_request(
	p_legislation_code		in varchar2,
	p_upgrade_short_name		in varchar2,
	p_validate_procedure		in varchar2,
	p_application_short_name	in varchar2,
	p_concurrent_program_name	in varchar2) return number
is
	l_dummy			varchar2(30);
	l_business_group_id	number;
	l_valid_request		boolean;
	l_request_id		number;
	l_phase			varchar2(255);
	l_status		varchar2(255);
	l_dev_phase		varchar2(255);
	l_dev_status		varchar2(255);
	l_message		varchar2(255);
	l_valid_upgrade		varchar2(10) := 'TRUE';
	--
	cursor csr_upgrade_def is
		select	upgrade_definition_id,
			upgrade_method,
			upgrade_level,
			legislation_code,
			legislatively_enabled
		from	pay_upgrade_definitions
		where	short_name = p_upgrade_short_name;
	l_upgrade_def	csr_upgrade_def%rowtype;
	--
	cursor csr_upgrade_leg(p_upgrade_definition_id number) is
		select	'Y'
		from	pay_upgrade_legislations
		where	upgrade_definition_id = p_upgrade_definition_id
		and	legislation_code = p_legislation_code;
	--
	cursor csr_upgrade_status(p_upgrade_definition_id number) is
		select	status
		from	pay_upgrade_status
		where	upgrade_definition_id = p_upgrade_definition_id
		and	business_group_id is null
		and	legislation_code = p_legislation_code;
	--
	-- Do not use per_business_groups_perf which does not return
	-- "Disabled" business groups.
	--
	cursor csr_bg is
		select	organization_id
		from	hr_organization_information
		where	org_information_context = 'Business Group Information'
		and	org_information9 = p_legislation_code
		and	rownum <= 1;
	--
	cursor csr_user_resp is
		select	g.user_id,
			g.responsibility_id,
			g.responsibility_application_id
		from	fnd_responsibility	r,
			fnd_user_resp_groups	g,
			fnd_user		u
		where	u.user_name = 'SYSADMIN'
		and	g.user_id = u.user_id
		and	g.security_group_id = 0
		and	r.application_id = g.responsibility_application_id
		and	r.responsibility_id = g.responsibility_id
		and	r.responsibility_key = 'SYSTEM_ADMINISTRATOR';
	--
	procedure raise_error(
		p_message	in varchar2,
		p_token		in varchar2 default null)
	is
	begin
		if p_token is null then
			raise_application_error(-20001, p_message || ': ' || p_upgrade_short_name);
		else
			raise_application_error(-20001, p_message || ': ' || p_upgrade_short_name || ', ' || p_token);
		end if;
	end raise_error;
	--
	procedure set_upgrade_completed
	is
	begin
		pay_generic_upgrade.set_upgrade_status(
			p_upg_def_id	=> l_upgrade_def.upgrade_definition_id,
			p_upg_lvl	=> 'L',
			p_bus_grp	=> null,
			p_leg_code	=> p_legislation_code,
			p_status	=> 'P');
		pay_generic_upgrade.set_upgrade_status(
			p_upg_def_id	=> l_upgrade_def.upgrade_definition_id,
			p_upg_lvl	=> 'L',
			p_bus_grp	=> null,
			p_leg_code	=> p_legislation_code,
			p_status	=> 'C');
	end set_upgrade_completed;
begin
	--
	-- Validate Input Parameters
	--
	open csr_upgrade_def;
	fetch csr_upgrade_def into l_upgrade_def;
	if csr_upgrade_def%notfound then
		close csr_upgrade_def;
		raise_error('Specified Upgrade Definition not found');
	end if;
	close csr_upgrade_def;
	--
	if l_upgrade_def.upgrade_method <> 'PYUGEN' then
		raise_error('Only Upgrade Method "PYUGEN" is supported', l_upgrade_def.upgrade_method);
	end if;
	--
	if l_upgrade_def.upgrade_level <> 'L' then
		raise_error('Only Upgrade Level "L" is supported', l_upgrade_def.upgrade_level);
	end if;
	--
	if l_upgrade_def.legislation_code is not null then
		if l_upgrade_def.legislation_code <> p_legislation_code then
			raise_error('Inconsistent legislation', l_upgrade_def.legislation_code);
		end if;
	else
		if l_upgrade_def.legislatively_enabled = 'Y' then
			open csr_upgrade_leg(l_upgrade_def.upgrade_definition_id);
			fetch csr_upgrade_leg into l_dummy;
			if csr_upgrade_leg%notfound then
				close csr_upgrade_leg;
				raise_error('Upgrade Definition is not legislatively available', p_legislation_code);
			end if;
			close csr_upgrade_leg;
		end if;
	end if;
	--
	-- Make sure the data update has not been performed already.
	-- pay_core_utils.get_upgrade_status cannot be used for
	-- legislative upgrade which requires business_group_id as mandatory parameter.
	-- There's possibility that business groups within "p_legislation_code" are not created yet at this point.
	--
	open csr_upgrade_status(l_upgrade_def.upgrade_definition_id);
	fetch csr_upgrade_status into l_dummy;
	if csr_upgrade_status%notfound then
		--
		-- To run concurrent program "Generic Upgrade Mechanism" at legislation level,
		-- it is required to derive business_group_id of one of business groups within "p_legislation_code".
		--
		open csr_bg;
		fetch csr_bg into l_business_group_id;
		--
		-- When no business group for specified legislation is available,
		-- stamp the legislation upgrade as "Completed".
		-- Note to stamp "Processing", then "Completed" to suppress error.
		--
		if csr_bg%notfound then
			set_upgrade_completed;
		else
			--
			-- Check pending or running concurrent program exists in FND_CONCURRENT_REQUESTS.
			--
			l_valid_request := fnd_concurrent.get_request_status(
						request_id	=> l_request_id,
						appl_shortname	=> p_application_short_name,
						program		=> p_concurrent_program_name,
						phase		=> l_phase,
						status		=> l_status,
						dev_phase	=> l_dev_phase,
						dev_status	=> l_dev_status,
						message		=> l_message);
			--
			-- When no request or no pending/running request found,
			-- submit request.
			--
			l_request_id := null;
			if (not l_valid_request) or (l_valid_request and l_dev_phase not in ('PENDING', 'RUNNING')) then
				--
				-- Execute validate procedure only when set.
				--
				if p_validate_procedure is not null then
					execute immediate 'begin ' || p_validate_procedure || '(:a); end;' using out l_valid_upgrade;
				end if;
				--
				if l_valid_upgrade = 'TRUE' then
					for l_rec in csr_user_resp loop
						fnd_global.apps_initialize(
							user_id		=> l_rec.user_id,
							resp_id		=> l_rec.responsibility_id,
							resp_appl_id	=> l_rec.responsibility_application_id);
					end loop;
					--
					l_request_id := fnd_request.submit_request (
								application	=> p_application_short_name,
								program		=> p_concurrent_program_name,
								argument1	=> 'ARCHIVE',						-- Process Name
								argument2	=> 'GENERIC_UPGRADE',					-- Report Type
								argument3	=> 'DEFAULT',						-- Rpt Qual
								argument4	=> null,						-- Start Date
								argument5	=> null,						-- End Date
								argument6	=> 'PROCESS',						-- Rpt Category
								argument7	=> fnd_number.number_to_canonical(l_business_group_id),	-- Business Grp
								argument8	=> null,						-- Mag File Nme
								argument9	=> null,						-- Rep File Nme
								argument10	=> fnd_number.number_to_canonical(l_upgrade_def.upgrade_definition_id),	-- ID
								argument11	=> p_upgrade_short_name,				-- Short Name
								argument12	=> 'UPG_DEF_NAME=' || p_upgrade_short_name);		-- Upgrade Name
					if l_request_id = 0 then
						hr_utility.raise_error;
					end if;
				else
					set_upgrade_completed;
				end if;
			end if;
		end if;
		close csr_bg;
	end if;
	close csr_upgrade_status;
	--
	return l_request_id;
end submit_request;
*/
--
--begin
--	hr_utility.trace_on('F', 'TTAGAWA');
end pay_jp_generic_upgrade_pkg;

/
