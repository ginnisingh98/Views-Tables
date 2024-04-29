--------------------------------------------------------
--  DDL for Package Body PAY_JP_DEF_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_DEF_ARCHIVE" as
/* $Header: pyjpdefc.pkb 120.2.12010000.2 2009/04/27 14:51:29 spattem ship $ */
--
-- Constants
--
c_package		constant varchar2(31) := 'pay_jp_def_archive.';
c_organization_iv_name	constant pay_input_values_f.name%type := 'COM_ITX_INFO_WITHHOLD_AGENT_ENTRY_VALUE';
c_tax_type_iv_name	constant pay_input_values_f.name%type := 'COM_ITX_INFO_ITX_TYPE_ENTRY_VALUE';
--
-- Global Variables
--
g_payroll_action_id		number;
g_business_group_id		number;
g_effective_date		date;
g_legislation_code		per_business_groups_perf.legislation_code%type;
g_payroll_id			number;
g_organization_id		number;
g_process_assignments_flag	varchar2(1);
--
-- Procedures for ARCHIVE process
--
-- |-------------------------------------------------------------------|
-- |----------------------< initialization_code >----------------------|
-- |-------------------------------------------------------------------|
procedure initialization_code(p_payroll_action_id in number)
is
	c_proc				constant varchar2(61) := c_package || 'initialization_code';
	cursor csr is
		select	ppa.business_group_id,
			ppa.effective_date,
			ppa.legislative_parameters,
			bg.legislation_code
		from	per_business_groups_perf	bg,
			pay_payroll_actions		ppa
		where	ppa.payroll_action_id = p_payroll_action_id
		and	bg.business_group_id = ppa.business_group_id;
	l_rec	csr%rowtype;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	if g_payroll_action_id is null
	or g_payroll_action_id <> p_payroll_action_id then
		hr_utility.trace('cache not available');
		--
		open csr;
		fetch csr into l_rec;
		if csr%notfound then
			close csr;
			fnd_message.set_name('PAY', 'PAY_34985_INVALID_PAY_ACTION');
			fnd_message.raise_error;
		end if;
		close csr;
		--
		g_payroll_action_id		:= p_payroll_action_id;
		g_effective_date		:= l_rec.effective_date;
		g_business_group_id		:= l_rec.business_group_id;
		g_legislation_code		:= l_rec.legislation_code;
		g_payroll_id			:= fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ID', l_rec.legislative_parameters));
		g_organization_id		:= fnd_number.canonical_to_number(pay_core_utils.get_parameter('ORGANIZATION_ID', l_rec.legislative_parameters));
		g_process_assignments_flag	:= pay_core_utils.get_parameter('PROCESS_ASSIGNMENTS_FLAG', l_rec.legislative_parameters);
	end if;
	--
	hr_utility.trace('payroll_action_id        : ' || g_payroll_action_id);
	hr_utility.trace('business_group_id        : ' || g_business_group_id);
	hr_utility.trace('effective_date           : ' || g_effective_date);
	hr_utility.trace('legislation_code         : ' || g_legislation_code);
	hr_utility.trace('payroll_id               : ' || g_payroll_id);
	hr_utility.trace('organization_id          : ' || g_organization_id);
	hr_utility.trace('process_assignments_flag : ' || g_process_assignments_flag);
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end initialization_code;
-- |-------------------------------------------------------------------|
-- |-------------------------< archive_pact >--------------------------|
-- |-------------------------------------------------------------------|
procedure archive_pact(p_payroll_action_id in number)
is
	c_proc			constant varchar2(61) := c_package || 'archive_pact';
	l_exists		varchar2(1);
	l_action_information_id	number;
	l_object_version_number	number;
	cursor csr_exists is
		select	'Y'
		from	pay_jp_def_pact_v
		where	payroll_action_id = p_payroll_action_id;
	cursor csr_org is
		select	hoi2.org_information1							tax_office_name,
			hoi1.org_information1							salary_payer_name,
			hoi1.org_information6 || hoi1.org_information7 || hoi1.org_information8	salary_payer_address
		from	hr_organization_information	hoi2,
			hr_organization_information	hoi1,
			hr_all_organization_units	hou
		where	hou.organization_id = g_organization_id
		and	hoi1.organization_id(+) = hou.organization_id
		and	hoi1.org_information_context(+) = 'JP_TAX_SWOT_INFO'
		and	hoi2.organization_id(+) = hou.organization_id
		and	hoi2.org_information_context(+) = 'JP_ITAX_WITHHELD_INFO';
	l_org_rec	csr_org%rowtype;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	-- Archive only if PA level is not archived.
	-- This is to avoid the issue of Mark for Retry which does not kick range_code.
	--
	open csr_exists;
	fetch csr_exists into l_exists;
	if csr_exists%notfound then
		open csr_org;
		fetch csr_org into l_org_rec;
		if csr_org%notfound then
			fnd_message.set_name('PAY', 'PAY_JP_INVALID_SWOT');
			fnd_message.raise_error;
		end if;
		close csr_org;
		--
		hr_utility.trace('tax_office_name      : ' || l_org_rec.tax_office_name);
		hr_utility.trace('salary_payer_name    : ' || l_org_rec.salary_payer_name);
		hr_utility.trace('salary_payer_address : ' || l_org_rec.salary_payer_address);
		--
		pay_jp_def_api.create_pact(
			P_VALIDATE			=> false,
			P_PAYROLL_ACTION_ID		=> p_payroll_action_id,
			P_EFFECTIVE_DATE		=> g_effective_date,
			P_PAYROLL_ID			=> g_payroll_id,
			P_ORGANIZATION_ID		=> g_organization_id,
			P_SUBMISSION_PERIOD_STATUS	=> 'C',
			P_SUBMISSION_START_DATE		=> null,
			P_SUBMISSION_END_DATE		=> null,
			P_TAX_OFFICE_NAME		=> l_org_rec.tax_office_name,
			P_SALARY_PAYER_NAME		=> l_org_rec.salary_payer_name,
			P_SALARY_PAYER_ADDRESS		=> l_org_rec.salary_payer_address,
			P_ACTION_INFORMATION_ID		=> l_action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_object_version_number);
	end if;
	close csr_exists;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end archive_pact;
-- |-------------------------------------------------------------------|
-- |--------------------------< range_code >---------------------------|
-- |-------------------------------------------------------------------|
procedure range_code(
	p_payroll_action_id		in number,
	p_sqlstr			out nocopy varchar2)
is
	c_proc			constant varchar2(61) := c_package || 'range_code';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	initialization_code(p_payroll_action_id);
	--
	archive_pact(p_payroll_action_id);
	--
	-- When "process assignments flag" is set to no, no assignment actions are created.
	--
	if g_process_assignments_flag = 'N' then
		p_sqlstr := 'select 1 from dual where :payroll_action_id < 0';
	else
		p_sqlstr :=
'select	distinct per.person_id
from	per_all_people_f	per,
	pay_payroll_actions	ppa
where	ppa.payroll_action_id = :payroll_action_id
and  ppa.business_group_id + 0 = per.business_group_id
order by per.person_id';
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end range_code;
-- |-------------------------------------------------------------------|
-- |--------------------< assignment_action_code >---------------------|
-- |-------------------------------------------------------------------|
procedure assignment_action_code(
	p_payroll_action_id		in number,
	p_start_person_id		in number,
	p_end_person_id			in number,
	p_chunk_number			in number)
is
	c_proc			constant varchar2(61) := c_package || 'assignment_action_code';
	l_tax_type		pay_element_entry_values_f.screen_entry_value%type;
	l_organization_id	number;
	l_assignment_action_id	number;
	--
	cursor csr_asg is
		select	asg.assignment_id
		from	per_all_assignments_f	asg,
			per_periods_of_service	pds
		where	pds.person_id
			between p_start_person_id and p_end_person_id
		and	pds.business_group_id + 0 = g_business_group_id
		and	g_effective_date
			between pds.date_start and nvl(pds.final_process_date, g_effective_date)
		and	asg.period_of_service_id = pds.period_of_service_id
		and     asg.primary_flag         = 'Y' /*Added by JSAJJA, as per Bug 8435426*/
		and	g_effective_date
			between asg.effective_start_date and asg.effective_end_date
		and	asg.payroll_id + 0 = g_payroll_id;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
  -- Reset global variable in case of multiple threads.
	initialization_code(p_payroll_action_id);
  --
	for l_asg_rec in csr_asg loop
		pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(g_effective_date));
		pay_balance_pkg.set_context('ASSIGNMENT_ID', fnd_number.number_to_canonical(l_asg_rec.assignment_id));
		l_organization_id := pay_balance_pkg.run_db_item(c_organization_iv_name, g_business_group_id, g_legislation_code);
		--
		if l_organization_id = g_organization_id then
			l_tax_type := pay_balance_pkg.run_db_item(c_tax_type_iv_name, g_business_group_id, g_legislation_code);
			if l_tax_type in ('M_KOU', 'D_KOU') then
				hr_utility.trace('assignment_id : ' || l_asg_rec.assignment_id);
				--
				select	pay_assignment_actions_s.nextval
				into	l_assignment_action_id
				from	dual;
				--
				hr_nonrun_asact.insact(
					lockingactid	=> l_assignment_action_id,
					assignid	=> l_asg_rec.assignment_id,
					pactid		=> p_payroll_action_id,
					chunk		=> p_chunk_number,
					greid		=> null);
			end if;
		end if;
	end loop;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end assignment_action_code;
-- |-------------------------------------------------------------------|
-- |------------------------< archive_assact >-------------------------|
-- |-------------------------------------------------------------------|
procedure archive_assact(
	p_assignment_action_id		in number,
	p_effective_date		in date)
is
	c_proc			constant varchar2(61) := c_package || 'archive_assact';
	l_assignment_id		number;
	l_tax_type		pay_element_entry_values_f.screen_entry_value%type;
	l_action_information_id	number;
	l_object_version_number	number;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	select	assignment_id
	into	l_assignment_id
	from	pay_assignment_actions
	where	assignment_action_id = p_assignment_action_id;
	--
	-- Derive Tax Type input value
	--
	pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(p_effective_date));
	pay_balance_pkg.set_context('ASSIGNMENT_ID', fnd_number.number_to_canonical(l_assignment_id));
	l_tax_type := pay_balance_pkg.run_db_item(c_tax_type_iv_name, g_business_group_id, g_legislation_code);
	--
	if l_tax_type not in ('M_KOU', 'D_KOU') then
		fnd_message.set_name('PAY', 'PAY_JP_INVALID_TAX_TYPE');
		fnd_message.raise_error;
	else
		pay_jp_def_api.create_assact(
			P_VALIDATE			=> false,
			P_ASSIGNMENT_ACTION_ID		=> p_assignment_action_id,
			P_EFFECTIVE_DATE		=> p_effective_date,
			P_ASSIGNMENT_ID			=> l_assignment_id,
			P_TAX_TYPE			=> l_tax_type,
			P_TRANSACTION_STATUS		=> 'U',
			P_FINALIZED_DATE		=> null,
			P_FINALIZED_BY			=> null,
			P_USER_COMMENTS			=> null,
			P_ADMIN_COMMENTS		=> null,
			P_TRANSFER_STATUS		=> 'U',
			P_EXPIRY_DATE			=> null,
			P_ACTION_INFORMATION_ID		=> l_action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_object_version_number);
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end archive_assact;
-- |-------------------------------------------------------------------|
-- |---------------------< deinitialization_code >---------------------|
-- |-------------------------------------------------------------------|
procedure deinitialization_code(p_payroll_action_id in number)
is
	c_proc			constant varchar2(61) := c_package || 'deinitialization_code';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
  -- invoke in case of mark for retry.
	initialization_code(p_payroll_action_id);
  --
	archive_pact(p_payroll_action_id);
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end deinitialization_code;
--
end pay_jp_def_archive;

/
