--------------------------------------------------------
--  DDL for Package Body PAY_JP_ITAX_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ITAX_ARCHIVE_PKG" as
/* $Header: pyjpiarc.pkb 120.26.12010000.3 2009/11/12 08:37:12 keyazawa ship $ */
--
-- Constants
--
c_package			CONSTANT VARCHAR2(31)	:= 'pay_jp_itax_archive_pkg.';
c_checked			CONSTANT VARCHAR2(2)	:= '*';
--
-- Global Variables
--
g_old_fixed_rate_kanji		VARCHAR2(80) := fnd_message.get_string('PAY', 'PAY_JP_YEA_FIXED_RATE');
g_old_fixed_rate_kana		VARCHAR2(80) := fnd_message.get_string('PAY', 'PAY_JP_YEA_FIXED_RATE_KANA');
g_old_national_pens_kanji	VARCHAR2(80) := fnd_message.get_string('PAY', 'PAY_JP_NATIONAL_PENSION');
g_old_national_pens_kana	VARCHAR2(80) := fnd_message.get_string('PAY', 'PAY_JP_NATIONAL_PENSION_KANA');
g_new_fixed_rate_kanji		VARCHAR2(80) := fnd_message.get_string('PAY', 'PAY_JP_ITAX_FIXED_RATE');
g_new_fixed_rate_kana		VARCHAR2(80) := fnd_message.get_string('PAY', 'PAY_JP_ITAX_FIXED_RATE_KANA');
g_new_national_pens_kanji	VARCHAR2(80) := fnd_message.get_string('PAY', 'PAY_JP_ITAX_NATIONAL_PENSION');
g_new_national_pens_kana	VARCHAR2(80) := fnd_message.get_string('PAY', 'PAY_JP_ITAX_NATIONAL_PENS_KANA');
--
g_payroll_action_id		number;
g_business_group_id		number;
g_bg_dpnt_ref_type		varchar2(30);
g_effective_date		date;
g_payroll_id			number;
g_soy				date;
g_eoy				date;
g_itax_organization_id		number;
g_include_terminated_flag	varchar2(1);
g_termination_date_from		date;
g_termination_date_to		date;
g_inherit_archive_flag		varchar2(1);
g_rearchive_flag		varchar2(1);
g_publication_period_status	varchar2(1);
g_publication_start_date	date;
g_publication_end_date		date;
--
FUNCTION check_when_true(p_condition in boolean) return varchar2
is
begin
	if p_condition then
		return c_checked;
	else
		return null;
	end if;
end check_when_true;
--
/* Commented out. bug.6168642
FUNCTION decode_value(
	p_condition	in boolean,
	p_value1	in varchar2,
	p_value2	in varchar2) return varchar2
is
begin
	if p_condition then
		return p_value1;
	else
		return p_value2;
	end if;
end decode_value;
*/
--
PROCEDURE jp_date(
	p_date		in date,
	p_meiji		out nocopy varchar2,
	p_taishou	out nocopy varchar2,
	p_shouwa	out nocopy varchar2,
	p_heisei	out nocopy varchar2,
	p_year		out nocopy varchar2,
	p_month		out nocopy varchar2,
	p_day		out nocopy varchar2)
is
	l_era_code	varchar2(1);
	l_char_date	varchar2(7);
begin
	hr_utility.trace('jp_date: ' || p_date);
	--
	if p_date is not null then
		l_char_date := hr_jp_standard_pkg.to_jp_char(p_date, 'EYYMMDD');
		l_era_code := substr(l_char_date, 1, 1);
		--
		p_meiji		:= check_when_true(l_era_code = 'M');
		p_taishou	:= check_when_true(l_era_code = 'T');
		p_shouwa	:= check_when_true(l_era_code = 'S');
		p_heisei	:= check_when_true(l_era_code = 'H');
		p_year		:= substr(l_char_date, 2, 2);
		p_month		:= substr(l_char_date, 4, 2);
		p_day		:= substr(l_char_date, 6, 2);
	end if;
end jp_date;
--
-- +------------------------------------------------------------------------------------------------+
-- |< INITIALIZATION_CODE >-------------------------------------------------------------------------|
-- |This sets the global contexts(PAYROLL_ID) for formulas.-----------------------------------------|
-- +------------------------------------------------------------------------------------------------+
PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
IS
	c_proc				CONSTANT VARCHAR2(61) := c_package || 'INITIALIZATION_CODE';
	l_legislative_parameters	pay_payroll_actions.legislative_parameters%type;
BEGIN
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if g_payroll_action_id is null or g_payroll_action_id <> p_payroll_action_id then
		hr_utility.trace('cache not available.');
		--
		select	business_group_id,
			effective_date,
			legislative_parameters
		into	g_business_group_id,
			g_effective_date,
			l_legislative_parameters
		from	pay_payroll_actions
		where	payroll_action_id = p_payroll_action_id;
		--
		-- "Assignment Set" cannot be implemented because of localization strategy
		-- at the moment.
		--
		g_soy				:= trunc(g_effective_date, 'YYYY');
		g_eoy				:= add_months(g_soy, 12) - 1;
		g_payroll_id			:= fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ID', l_legislative_parameters));
		g_itax_organization_id		:= fnd_number.canonical_to_number(pay_core_utils.get_parameter('ITAX_ORGANIZATION_ID', l_legislative_parameters));
		g_include_terminated_flag	:= nvl(pay_core_utils.get_parameter('INCLUDE_TERMINATED_FLAG', l_legislative_parameters), 'Y');
		g_termination_date_from		:= fnd_date.canonical_to_date(pay_core_utils.get_parameter('TERMINATION_DATE_FROM', l_legislative_parameters));
		g_termination_date_to		:= fnd_date.canonical_to_date(pay_core_utils.get_parameter('TERMINATION_DATE_TO', l_legislative_parameters));
		g_inherit_archive_flag		:= nvl(pay_core_utils.get_parameter('INHERIT_ARCHIVE_FLAG', l_legislative_parameters), 'Y');
		g_rearchive_flag		:= nvl(pay_core_utils.get_parameter('REARCHIVE_FLAG', l_legislative_parameters), 'N');
		g_publication_period_status	:= nvl(pay_core_utils.get_parameter('PUBLICATION_PERIOD_STATUS', l_legislative_parameters), 'C');
		g_publication_start_date	:= fnd_date.canonical_to_date(pay_core_utils.get_parameter('PUBLICATION_START_DATE', l_legislative_parameters));
		g_publication_end_date		:= fnd_date.canonical_to_date(pay_core_utils.get_parameter('PUBLICATION_END_DATE', l_legislative_parameters));
		g_bg_dpnt_ref_type		:= per_jp_ctr_utility_pkg.bg_itax_dpnt_ref_type(g_business_group_id);
		--
		g_payroll_action_id	:= p_payroll_action_id;
	end if;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 20);
END INITIALIZATION_CODE;
--
-- +------------------------------------------------------------------------------------------------+
-- |< RANGE_CODE >----------------------------------------------------------------------------------|
-- |The "p_sqlstr" fetches person_id with assignment action that should do the archive.-------------|
-- +------------------------------------------------------------------------------------------------+
PROCEDURE RANGE_CODE(
	p_payroll_action_id	IN NUMBER,
	p_sqlstr		OUT NOCOPY VARCHAR2)
IS
	c_proc	CONSTANT VARCHAR2(61) := c_package || 'RANGE_CODE';
BEGIN
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	initialization_code(p_payroll_action_id);
	--
	p_sqlstr :=
'SELECT	DISTINCT per.person_id
FROM	pay_payroll_actions	ppa,
	per_all_people_f	per
WHERE	ppa.payroll_action_id = :payroll_action_id
AND	per.business_group_id + 0 = ppa.business_group_id
ORDER BY per.person_id';
	--
	hr_utility.set_location('Leaving: ' || c_proc, 20);
END RANGE_CODE;
--
-- +------------------------------------------------------------------------------------------------+
-- |< ASSIGNMENT_ACTION_CODE >----------------------------------------------------------------------|
-- |This package procedure further restricts and creates the assignment action.---------------------|
-- +------------------------------------------------------------------------------------------------+
PROCEDURE ASSIGNMENT_ACTION_CODE(
	p_payroll_action_id	IN NUMBER,
	p_start_person_id	IN NUMBER,
	p_end_person_id		IN NUMBER,
	p_chunk			IN NUMBER)
IS
	c_proc			CONSTANT VARCHAR2(61) := c_package || 'ASSIGNMENT_ACTION_CODE';
	l_locking_action_id	NUMBER;
	--
	-- Currently, 1 assignment action is created for each assignment,
	-- then multiple certificate archive data is created under each assignment action.
	-- This will be changed "1 assignment action for each certificate"
	-- in next major release.
	--
	-- This archive process not only archives data but also validates existing archive data.
	-- Performance against multiple records of PER_ALL_ASSIGNMENTS_F with the same ASSIGNMENT_ID
	-- can be ignored because "exists" validation is performed only once for each ASSIGNMENT_ID.
	--
	-- Cursor is changed not to check archive data as follows.
	-- Assignment action is created for each assignment returned by view
	-- pay_jp_wic_assacts_v for usability.
	-- It is recommended not to specify "Payroll" and "Withholding Agent"
	-- parameters which will be confusing for user when archive is created
	-- for inappropriate assact in the middle of the year.
	-- "Assignment Set" will be the best solution.
	--
	cursor csr_asg is
	select	distinct
		asg.assignment_id
	from	per_all_assignments_f	asg
	where	asg.person_id
		between p_start_person_id and p_end_person_id
	and	asg.business_group_id + 0 = g_business_group_id
	and	asg.assignment_type = 'E'
	and	asg.effective_start_date <= g_effective_date
	and	asg.effective_end_date >= g_soy
	and	(
/*
			--
			-- The reason why this SQL uses exists statement, not using UNION ALL,
			-- is the latter "exists" statement performance is worse than former
			-- "exists" statement. If former "exists" statement returns "true",
			-- then latter "exists" is not checked.
			--
			exists(
				select	null
				from	pay_jp_itax_person_v2	person,
					pay_jp_itax_arch_v2	arch
				where	person.assignment_id = asg.assignment_id
				and	person.effective_date
					between g_soy and g_effective_date
				and	((g_itax_organization_id is null) or (person.itax_organization_id = g_itax_organization_id))
				and	(	(	g_include_terminated_flag = 'Y'
						and	(	(g_termination_date_from is null and g_termination_date_to is null)
							or	person.actual_termination_date
								between nvl(g_termination_date_from, person.actual_termination_date)
								and     nvl(g_termination_date_to, person.actual_termination_date)
							)
						)
					or	(g_include_terminated_flag = 'N' and person.actual_termination_date is null)
					)
				and	arch.action_context_id = person.action_context_id
				and	arch.effective_date = person.effective_date
				and	((g_payroll_id is null) or (arch.payroll_id = g_payroll_id))
			)
		or
*/
			exists(
				select	null
				from	pay_jp_wic_assacts_v	wic
				where	wic.assignment_id = asg.assignment_id
				and	wic.effective_date
					between g_soy and g_effective_date
				and	((g_itax_organization_id is null) or (wic.itax_organization_id = g_itax_organization_id))
				and	((g_payroll_id is null) or (wic.payroll_id = g_payroll_id))
				and	(	(	g_include_terminated_flag = 'Y'
						and	(	(g_termination_date_from is null and g_termination_date_to is null)
							or	wic.actual_termination_date
								between nvl(g_termination_date_from, wic.actual_termination_date)
								and     nvl(g_termination_date_to, wic.actual_termination_date)
							)
						)
					or	(g_include_terminated_flag = 'N' and wic.actual_termination_date is null)
					)
/* Following check is removed for inappropriate archive data deletion in ARCHIVE_CODE
				and	(
						g_rearchive_flag = 'Y'
					or	not exists(
							select	null
							from	pay_jp_itax_arch_v2	v
							where	v.assignment_id = wic.assignment_id
							-- effective_date validation is for performance reason.
							and	v.effective_date = wic.effective_date
							and	v.assignment_action_id = wic.assignment_action_id)
					)
*/
			)
		);
BEGIN
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	initialization_code(p_payroll_action_id);
	--
	-- RANGE_PERSON_ID, PAY_ACTION_PARAMETER_GROUPS(PAY_REPORT_FORMAT_PARAMETERS)
	-- is not supported in this release.
	--
	FOR l_asg in csr_asg LOOP
		hr_utility.set_location('Entering: ' || c_proc, 20);
		--
		SELECT	pay_assignment_actions_s.nextval
		INTO	l_locking_action_id
		FROM	dual;
		--
		hr_nonrun_asact.insact(
			lockingactid	=> l_locking_action_id,
			assignid	=> l_asg.assignment_id,
			pactid		=> p_payroll_action_id,
			chunk		=> p_chunk);
	END LOOP;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
END ASSIGNMENT_ACTION_CODE;
-- +------------------------------------------------------------------------------------------------+
-- |< create_action_information >-------------------------------------------------------------------|
-- |Private procedure.------------------------------------------------------------------------------|
-- +------------------------------------------------------------------------------------------------+
procedure create_action_information(p_action_information_rec in out nocopy pay_action_information%rowtype)
is
	l_id	number;
	l_ovn	number;
begin
	pay_action_information_api.create_action_information(
		P_VALIDATE			=> false,
		P_ACTION_CONTEXT_ID		=> p_action_information_rec.ACTION_CONTEXT_ID,
		P_ACTION_CONTEXT_TYPE		=> p_action_information_rec.ACTION_CONTEXT_TYPE,
		P_ACTION_INFORMATION_CATEGORY	=> p_action_information_rec.ACTION_INFORMATION_CATEGORY,
		P_EFFECTIVE_DATE		=> p_action_information_rec.EFFECTIVE_DATE,
		P_ASSIGNMENT_ID			=> p_action_information_rec.ASSIGNMENT_ID,
		P_ACTION_INFORMATION1		=> p_action_information_rec.ACTION_INFORMATION1,
		P_ACTION_INFORMATION2		=> p_action_information_rec.ACTION_INFORMATION2,
		P_ACTION_INFORMATION3		=> p_action_information_rec.ACTION_INFORMATION3,
		P_ACTION_INFORMATION4		=> p_action_information_rec.ACTION_INFORMATION4,
		P_ACTION_INFORMATION5		=> p_action_information_rec.ACTION_INFORMATION5,
		P_ACTION_INFORMATION6		=> p_action_information_rec.ACTION_INFORMATION6,
		P_ACTION_INFORMATION7		=> p_action_information_rec.ACTION_INFORMATION7,
		P_ACTION_INFORMATION8		=> p_action_information_rec.ACTION_INFORMATION8,
		P_ACTION_INFORMATION9		=> p_action_information_rec.ACTION_INFORMATION9,
		P_ACTION_INFORMATION10		=> p_action_information_rec.ACTION_INFORMATION10,
		P_ACTION_INFORMATION11		=> p_action_information_rec.ACTION_INFORMATION11,
		P_ACTION_INFORMATION12		=> p_action_information_rec.ACTION_INFORMATION12,
		P_ACTION_INFORMATION13		=> p_action_information_rec.ACTION_INFORMATION13,
		P_ACTION_INFORMATION14		=> p_action_information_rec.ACTION_INFORMATION14,
		P_ACTION_INFORMATION15		=> p_action_information_rec.ACTION_INFORMATION15,
		P_ACTION_INFORMATION16		=> p_action_information_rec.ACTION_INFORMATION16,
		P_ACTION_INFORMATION17		=> p_action_information_rec.ACTION_INFORMATION17,
		P_ACTION_INFORMATION18		=> p_action_information_rec.ACTION_INFORMATION18,
		P_ACTION_INFORMATION19		=> p_action_information_rec.ACTION_INFORMATION19,
		P_ACTION_INFORMATION20		=> p_action_information_rec.ACTION_INFORMATION20,
		P_ACTION_INFORMATION21		=> p_action_information_rec.ACTION_INFORMATION21,
		P_ACTION_INFORMATION22		=> p_action_information_rec.ACTION_INFORMATION22,
		P_ACTION_INFORMATION23		=> p_action_information_rec.ACTION_INFORMATION23,
		P_ACTION_INFORMATION24		=> p_action_information_rec.ACTION_INFORMATION24,
		P_ACTION_INFORMATION25		=> p_action_information_rec.ACTION_INFORMATION25,
		P_ACTION_INFORMATION26		=> p_action_information_rec.ACTION_INFORMATION26,
		P_ACTION_INFORMATION27		=> p_action_information_rec.ACTION_INFORMATION27,
		P_ACTION_INFORMATION28		=> p_action_information_rec.ACTION_INFORMATION28,
		P_ACTION_INFORMATION29		=> p_action_information_rec.ACTION_INFORMATION29,
		P_ACTION_INFORMATION30		=> p_action_information_rec.ACTION_INFORMATION30,
		P_ACTION_INFORMATION_ID		=> p_action_information_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_action_information_rec.object_version_number);
end create_action_information;
-- +------------------------------------------------------------------------------------------------+
-- |< ARCHIVE_CODE >--------------------------------------------------------------------------------|
-- |This sets the context for the assignment level contexts(ASSIGNMENT_ID).-------------------------|
-- +------------------------------------------------------------------------------------------------+
PROCEDURE ARCHIVE_CODE(
  p_assignment_action_id IN NUMBER,
  p_effective_date       IN DATE)
IS
--
  c_proc CONSTANT VARCHAR2(61) := c_package || 'ARCHIVE_CODE';
--
  l_assignment_id number;
  l_archive boolean;
  l_action_information_ids fnd_table_of_number := fnd_table_of_number();
 --
  l_dummy varchar2(255);
  l_certificate_info pay_jp_wic_pkg.t_certificate_info;
  l_withholding_tax_info pay_jp_wic_pkg.t_tax_info;
  l_submission_required_flag varchar2(1);
  l_prev_job_info pay_jp_wic_pkg.t_prev_job_info;
  l_housing_info pay_jp_wic_pkg.t_housing_info;
  l_adr_effective_date    date;
--
  l_itw_user_desc_kanji varchar2(32767);
  l_itw_descriptions    pay_jp_wic_pkg.t_descriptions;
  l_wtm_user_desc       varchar2(32767);
  l_wtm_user_desc_kanji varchar2(32767);
  l_wtm_user_desc_kana  varchar2(32767);
  l_wtm_descriptions    pay_jp_wic_pkg.t_descriptions;
--
  l_itw_system_desc1_kanji varchar2(32767);
  l_itw_system_desc2_kanji varchar2(32767);
  l_wtm_system_desc_kanji  varchar2(32767);
  l_wtm_system_desc_kana   varchar2(32767);
  l_varchar2_tbl           hr_jp_standard_pkg.t_varchar2_tbl;
--
  l_person_rec  pay_action_information%rowtype;
  l_arch_rec    pay_action_information%rowtype;
  l_tax_rec     pay_action_information%rowtype;
  l_other_rec   pay_action_information%rowtype;
  l_other2_rec  pay_action_information%rowtype;
  l_housing_rec pay_action_information%rowtype;
--
  cursor  csr_wic(cp_assignment_id number)
  is
  select  wic.assignment_action_id,
          wic.action_sequence,
          wic.payroll_id,
          nvl(pay.prl_information1, g_bg_dpnt_ref_type) dpnt_ref_type,
          nvl(fnd_date.canonical_to_date(pay_core_utils.get_parameter('ITAX_DPNT_EFFECTIVE_DATE', wic.legislative_parameters)),wic.effective_date) dpnt_effective_date,
          wic.effective_date,
          wic.date_earned,
          wic.itax_organization_id,
          wic.itax_category,
          wic.itax_yea_category,
          wic.person_id,
          wic.date_start,
          wic.leaving_reason,
          wic.actual_termination_date,
          wic.employment_category
  from    pay_jp_wic_assacts_v  wic,
          pay_all_payrolls_f  pay
  where   wic.assignment_id = cp_assignment_id
  and     wic.effective_date
          between g_soy and g_effective_date
  and     ((g_itax_organization_id is null) or (wic.itax_organization_id = g_itax_organization_id))
  and     ((g_payroll_id is null) or (wic.payroll_id = g_payroll_id))
  --
  -- Do not check termination_date in ARCHIVE_CODE here
  -- which has already been validated in ASSIGNMENT_ACTION_CODE.
  --
  /*
  and ( ( g_include_terminated_flag = 'Y'
      and ( (g_termination_date_from is null and g_termination_date_to is null)
        or  wic.actual_termination_date
          between nvl(g_termination_date_from, wic.actual_termination_date)
          and     nvl(g_termination_date_to, wic.actual_termination_date)
        )
      )
    or  (g_include_terminated_flag = 'N' and wic.actual_termination_date is null)
    )
  */
  and pay.payroll_id = wic.payroll_id
  and wic.effective_date
      between pay.effective_start_date and pay.effective_end_date
  order by wic.effective_date;
--
  -- Used when g_rearchive_flag = 'N'
  -- to check whether the assact is already archived or not.
--
  cursor csr_prev_archive(
    cp_assignment_id        number,
    cp_effective_date       date,
    cp_assignment_action_id number)
  is
  select  person.action_information_id
  from    pay_jp_itax_arch_v2 arch,
          pay_jp_itax_person_v2 person
  where arch.assignment_id = cp_assignment_id
  -- effective_date validation is for performance reason.
  and   arch.effective_date = cp_effective_date
  and   arch.assignment_action_id = cp_assignment_action_id
  and   person.action_context_id = arch.action_context_id
  and   person.effective_date = arch.effective_date;
--
  -- Used when g_inherit_archive_flag = 'Y'
  -- to inherit description information under new archive assact.
  -- The archive derived by this cursor will be removed.
--
  cursor csr_replace_archive(
    cp_assignment_id        number,
    cp_itax_organization_id number,
    cp_itax_category        varchar2)
  is
  select  person.action_information_id,
          person.action_context_id,
          person.effective_date,
          other2.ITW_USER_DESC_KANJI,
          other2.WTM_USER_DESC_KANJI,
          other2.WTM_USER_DESC_KANA
  from    pay_jp_itax_person_v2 person,
          pay_jp_itax_arch_v2 arch,
          pay_jp_itax_other2_v2 other2
  where   person.assignment_id = cp_assignment_id
  and     person.effective_date
          between g_soy and g_eoy
  and     person.itax_organization_id = cp_itax_organization_id
  and     arch.action_context_id = person.action_context_id
  and     arch.effective_date = person.effective_date
  and     arch.itax_category = cp_itax_category
  and     other2.action_context_id = person.action_context_id
  and     other2.effective_date = person.effective_date
  for     update of person.action_information_id nowait
  order by person.effective_date;
--
  -- When g_rearchive_flag = 'Y' then all records derived by the
  -- following cursor will be deleted.
  -- When g_rearchive_flag = 'N' then all records except for records
  -- derived by csr_prev_archive or created by current assact
  -- stored in "cp_action_information_ids" will be deleted.
--
  cursor csr_delete_archives(
    cp_assignment_id          number,
    cp_action_information_ids fnd_table_of_number)
  is
  select  person.action_information_id,
          person.action_context_id,
          person.effective_date
  from    pay_jp_itax_person_v2 person,
          pay_jp_itax_arch_v2 arch
  where person.assignment_id = cp_assignment_id
  and   person.effective_date
        between g_soy and g_effective_date
  -- bug.5657929
  and   person.action_information_category = 'JP_ITAX_PERSON'
  and   person.action_information_id not in (
      select  *
      from    table(cp_action_information_ids))
  and   ((g_itax_organization_id is null) or (person.itax_organization_id = g_itax_organization_id))
  and   arch.action_context_id = person.action_context_id
  and   arch.effective_date = person.effective_date
  and   ((g_payroll_id is null) or (arch.payroll_id = g_payroll_id))
  for update of person.action_information_id nowait;
--
  cursor csr_per(
    cp_assignment_id      number,
    cp_effective_date     date,
    cp_adr_effective_date date)
  is
  select  per.employee_number,
          per.last_name last_name_kana,
          per.first_name first_name_kana,
          per.per_information18 last_name_kanji,
          per.per_information19 first_name_kanji,
          per.sex,
          per.date_of_birth,
          nvl(adrr.address_id, adrc.address_id) address_id,
          rtrim(substrb(decode(adrr.address_id, null,
            adrc.region_1 || adrc.region_2 || adrc.region_3,
            adrr.region_1 || adrr.region_2 || adrr.region_3), 1, 240)) address_kana,
          rtrim(substrb(decode(adrr.address_id, null,
            adrc.address_line1 || adrc.address_line2 || adrc.address_line3,
            adrr.address_line1 || adrr.address_line2 || adrr.address_line3), 1, 240)) address_kanji,
          decode(adrr.address_id, null, adrc.country, adrr.country) country,
          decode(adrr.address_id, null, adrc.town_or_city, adrr.town_or_city) district_code,
          asg.organization_id
  from  per_all_assignments_f asg,
        per_all_people_f    per,
        per_addresses     adrr,
        per_addresses     adrc
  where asg.assignment_id = cp_assignment_id
  and   cp_effective_date
        between asg.effective_start_date and asg.effective_end_date
  and   per.person_id = asg.person_id
  and   cp_effective_date
        between per.effective_start_date and per.effective_end_date
  and   adrr.person_id(+) = per.person_id
  and   adrr.address_type(+) = 'JP_R'
  and   cp_adr_effective_date
        between adrr.date_from(+) and nvl(adrr.date_to(+), cp_adr_effective_date)
  and   adrc.person_id(+) = per.person_id
  and   adrc.address_type(+) = 'JP_C'
  and   cp_adr_effective_date
        between adrc.date_from(+) and nvl(adrc.date_to(+), cp_adr_effective_date);
--
  l_per_rec csr_per%rowtype;
--
  cursor csr_swot(cp_itax_organization_id number)
  is
  select  hoi2.org_information3 reference_number,
          lpad(hoi2.org_information4, 10, '0') reference_number1,
          hoi2.org_information5 reference_number2,
          rtrim(substrb(hoi1.org_information6 || hoi1.org_information7 || hoi1.org_information8, 1, 240)) salary_payer_address_kanji,
          hoi1.org_information1     salary_payer_name_kanji,
          hoi1.org_information12      salary_payer_telephone_number,
          hoi2.org_information2     tax_office_number
  from    hr_all_organization_units hou,
          hr_organization_information hoi1,
          hr_organization_information hoi2
  where   hou.organization_id = cp_itax_organization_id
  and     hoi1.organization_id(+) = hou.organization_id
  and     hoi1.org_information_context(+) = 'JP_TAX_SWOT_INFO'
  and     hoi2.organization_id(+) = hou.organization_id
  and     hoi2.org_information_context(+) = 'JP_ITAX_WITHHELD_INFO';
--
  l_swot_rec  csr_swot%rowtype;
--
  procedure concat_description(
    p_src         in out nocopy varchar2,
    p_description in varchar2,
    p_separator   in varchar2)
  is
  begin
    if p_description is not null then
      if p_src is not null then
        p_src := p_src || p_separator;
      end if;
      --
      p_src := p_src || p_description;
    end if;
  end concat_description;
--
  function get_index_at(
    p_varchar2_tbl  in hr_jp_standard_pkg.t_varchar2_tbl,
    p_index   in number) return varchar2
  is
  begin
    if p_varchar2_tbl.exists(p_index) then
      return p_varchar2_tbl(p_index);
    else
      return null;
    end if;
  end get_index_at;
--
  /*
  procedure log_description(
    p_system_description  in varchar2,
    p_user_description  in varchar2,
    p_is_zenkaku    in boolean)
  is
    l_description varchar2(32767);
    l_separator varchar2(10) := ',';
  begin
    if p_system_description is null then
      l_description := p_user_description;
    elsif p_user_description is null then
      l_description := p_system_description;
    else
      if p_is_zenkaku then
        l_separator := hr_jp_standard_pkg.to_zenkaku(l_separator);
      end if;
      --
      l_description := p_system_description || l_separator || p_user_description;
    end if;
    --
    if length(l_description) > 100 then
      fnd_message.set_name('PAY', 'PAY_JP_ITW_ARCHIVE_DESC_WARN');
      fnd_message.set_token('ACTION_INFORMATION_ID', null);
      fnd_message.set_token('EMPLOYEE_NUMBER', null);
      fnd_message.set_token('FULL_NAME', null);
      fnd_message.set_token('SWOT_NAME', null);
      fnd_message.set_token('TAX_TYPE', null);
      fnd_message.set_token('DESCRIPTION', l_description);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    end if;
  end log_description;
  */
--
  procedure delete_archive(
    p_action_information_id in number,
    p_action_context_id in number,
    p_effective_date  in date)
  is
    l_count   number;
  begin
  --
    -- Currently, the unique key is (action_context_id, effective_date),
    -- which needs to be changed to (action_context_id) to fix potential bugs.
  --
    select  count(*)
    into  l_count
    from  pay_jp_itax_person_v2
    where action_context_id = p_action_context_id
    and   action_information_id <> p_action_information_id;
  --
    -- When multiple archives exist, delete the correponding action info only.
    -- If not, rollback the assignment action itself.
  --
    if l_count > 0 then
      delete
      from  pay_action_information
      where action_context_type = 'AAP'
      and   action_context_id = p_action_context_id
      and   effective_date = p_effective_date;
    else
      py_rollback_pkg.rollback_ass_action(p_action_context_id);
    end if;
  --
    fnd_message.set_name('PAY', 'PAY_JP_ITW_ARCHIVE_DELETED');
    fnd_message.set_token('ACTION_INFORMATION_ID', p_action_information_id);
    fnd_message.set_token('EMPLOYEE_NUMBER', null);
    fnd_message.set_token('FULL_NAME', null);
    fnd_message.set_token('SWOT_NAME', null);
    fnd_message.set_token('TAX_TYPE', null);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  --
  end delete_archive;
--
BEGIN
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  -- Lock first(not latest) record on PER_ALL_ASSIGNMENTS_F
  -- to suppress other PAYJPITW processes archive the same information
  -- at the same time.
--
  select  asg.assignment_id
  into    l_assignment_id
  from    pay_assignment_actions  paa,
          per_all_assignments_f asg
  where   paa.assignment_action_id = p_assignment_action_id
  and     asg.assignment_id = paa.assignment_id
  and     asg.effective_start_date <= g_effective_date
  and     asg.effective_end_date >= g_soy
  and     not exists(
    select  null
    from    per_all_assignments_f asg2
    where   asg2.assignment_id = asg.assignment_id
    and     asg2.effective_start_date < asg.effective_start_date
    and     asg2.effective_end_date >= g_soy)
  for update of asg.assignment_id nowait;
--
  -- Fetch same year's data
--
  for l_wic_rec in csr_wic(l_assignment_id) loop
  --
    hr_utility.set_location(c_proc, 20);
  --
    l_archive := true;
  --
    -- Check whether the wic assact is already archived or not
    -- when g_rearchive_flag = 'N'. If found, skip processing
    -- this wic assact.
  --
    if g_rearchive_flag = 'N' then
    --
      for l_archive_rec in csr_prev_archive(l_assignment_id, l_wic_rec.effective_date, l_wic_rec.assignment_action_id) loop
        l_archive := false;
        l_action_information_ids.extend;
        l_action_information_ids(l_action_information_ids.last) := l_archive_rec.action_information_id;
      end loop;
    --
    end if;
  --
    if l_archive then
    --
      l_adr_effective_date := nvl(l_wic_rec.actual_termination_date, g_eoy + 1);
    --
    -- Personal Information
    --
      open csr_per(l_assignment_id, l_wic_rec.effective_date, l_adr_effective_date);
      fetch csr_per into l_per_rec;
      if csr_per%notfound then
        close csr_per;
        raise no_data_found;
      end if;
      close csr_per;
    --
      hr_utility.set_location(c_proc, 30);
    --
    -- Employer Information
    --
      open csr_swot(l_wic_rec.itax_organization_id);
      fetch csr_swot into l_swot_rec;
      if csr_swot%notfound then
        close csr_swot;
        raise no_data_found;
      end if;
      close csr_swot;
    --
      hr_utility.set_location(c_proc, 40);
    --
    -- Certificate Information
    --
    -- Never call "pay_jp_wic_pkg.get_certificate_info" multiple times
    -- which will cause severe performance loss.
    -- Also never call debugging "pay_jp_wic_pkg.get_certificate_info"
    -- which is only for debugging purpose.
    --
      pay_jp_wic_pkg.get_certificate_info(
        p_assignment_action_id     => l_wic_rec.assignment_action_id,
        p_assignment_id            => l_assignment_id,
        p_action_sequence          => l_wic_rec.action_sequence,
        p_business_group_id        => g_business_group_id,
        p_effective_date           => l_wic_rec.effective_date,
        p_date_earned              => l_wic_rec.date_earned,
        p_itax_organization_id     => l_wic_rec.itax_organization_id,
        p_itax_category            => l_wic_rec.itax_category,
        p_itax_yea_category        => l_wic_rec.itax_yea_category,
        p_dpnt_ref_type            => l_wic_rec.dpnt_ref_type,
        p_dpnt_effective_date      => l_wic_rec.dpnt_effective_date,
        p_person_id                => l_wic_rec.person_id,
        p_sex                      => l_per_rec.sex,
        p_date_of_birth            => l_per_rec.date_of_birth,
        p_leaving_reason           => l_wic_rec.leaving_reason,
        p_last_name_kanji          => l_per_rec.last_name_kanji,
        p_last_name_kana           => l_per_rec.last_name_kana,
        p_employment_category      => l_wic_rec.employment_category,
        p_certificate_info         => l_certificate_info,
        p_submission_required_flag => l_submission_required_flag,
        p_prev_job_info            => l_prev_job_info,
        p_housing_info             => l_housing_info,
        p_withholding_tax_info     => l_withholding_tax_info,
        p_itw_description          => l_itw_user_desc_kanji,
        p_itw_descriptions         => l_itw_descriptions,
        p_wtm_description          => l_wtm_user_desc,
        p_wtm_descriptions         => l_wtm_descriptions);
    --
      l_wtm_user_desc_kanji := l_wtm_user_desc;
      l_wtm_user_desc_kana  := l_wtm_user_desc;
    --
      hr_utility.set_location(c_proc, 50);
    --
      -- Get old description and replace system derived description with those if available,
      -- then delete all archive data.
      -- This specification seems to be confusing for user, there's possibility to
      -- comment out the following code.
      -- Fixed to replace not only ITW but also WTM description.
      -- Note old override flag is not checked.
    --
      for l_archive_rec in csr_replace_archive(
        l_assignment_id,
        l_wic_rec.itax_organization_id,
        l_wic_rec.itax_category) loop
      --
        hr_utility.set_location(c_proc, 61);
      --
        if g_inherit_archive_flag = 'Y' then
        --
          l_itw_user_desc_kanji := l_archive_rec.itw_user_desc_kanji;
          l_wtm_user_desc_kanji := l_archive_rec.wtm_user_desc_kanji;
          l_wtm_user_desc_kana  := l_archive_rec.wtm_user_desc_kana;
        /*
        --
          fnd_message.set_name('PAY', 'PAY_JP_ITW_ARCHIVE_INHERITED');
          fnd_message.set_token('ACTION_INFORMATION_ID', null);
          fnd_message.set_token('EMPLOYEE_NUMBER', null);
          fnd_message.set_token('FULL_NAME', null);
          fnd_message.set_token('SWOT_NAME', null);
          fnd_message.set_token('TAX_TYPE', null);
          fnd_message.set_token('SRC_ACTION_INFORMATION_ID', null);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
        --
        */
        --
        end if;
      --
        delete_archive(
          l_archive_rec.action_information_id,
          l_archive_rec.action_context_id,
          l_archive_rec.effective_date);
      --
      end loop;
    --
      hr_utility.set_location(c_proc, 70);
    --
    -- JP_ITAX_PERSON
    --
      l_person_rec.action_context_id           := p_assignment_action_id;
      l_person_rec.action_context_type         := 'AAP';
      l_person_rec.action_information_category := 'JP_ITAX_PERSON';
      l_person_rec.effective_date              := l_wic_rec.effective_date;
      l_person_rec.assignment_id               := l_assignment_id;
      l_person_rec.action_information1         := l_per_rec.employee_number;
      l_person_rec.action_information2         := l_per_rec.last_name_kana;
      l_person_rec.action_information3         := l_per_rec.first_name_kana;
      l_person_rec.action_information4         := l_per_rec.last_name_kanji;
      l_person_rec.action_information5         := l_per_rec.first_name_kanji;
      l_person_rec.action_information6         := l_per_rec.sex;
      l_person_rec.action_information7         := fnd_number.number_to_canonical(l_per_rec.address_id);
      l_person_rec.action_information8         := l_per_rec.address_kana;
      l_person_rec.action_information9         := l_per_rec.address_kanji;
      l_person_rec.action_information10        := l_per_rec.country;
      l_person_rec.action_information11        := fnd_date.date_to_canonical(l_wic_rec.date_start);
      l_person_rec.action_information12        := l_wic_rec.leaving_reason;
      l_person_rec.action_information13        := fnd_date.date_to_canonical(l_per_rec.date_of_birth);
    --
      jp_date(
        p_date    => l_per_rec.date_of_birth,
        p_meiji   => l_person_rec.action_information14,
        p_taishou => l_person_rec.action_information15,
        p_shouwa  => l_person_rec.action_information16,
        p_heisei  => l_person_rec.action_information17,
        p_year    => l_person_rec.action_information18,
        p_month   => l_person_rec.action_information19,
        p_day     => l_person_rec.action_information20);
     --
     /* Bug.6208573. 21/22/23 obsolete.
     --
      jp_date(
        p_date    => nvl(l_wic_rec.actual_termination_date, l_wic_rec.date_start),
        p_meiji   => l_dummy,
        p_taishou => l_dummy,
        p_shouwa  => l_dummy,
        p_heisei  => l_dummy,
        p_year    => l_person_rec.action_information21,
        p_month   => l_person_rec.action_information22,
        p_day     => l_person_rec.action_information23);
     --
     */
     --
      l_person_rec.action_information24 := fnd_number.number_to_canonical(l_wic_rec.itax_organization_id);
      l_person_rec.action_information25 := fnd_date.date_to_canonical(l_wic_rec.actual_termination_date);
      l_person_rec.action_information26 := fnd_number.number_to_canonical(l_per_rec.organization_id);
      l_person_rec.action_information28 := l_per_rec.district_code;
    --
    -- JP_ITAX_ARCH
    --
      l_arch_rec.action_context_id           := p_assignment_action_id;
      l_arch_rec.action_context_type         := 'AAP';
      l_arch_rec.action_information_category := 'JP_ITAX_ARCH';
      l_arch_rec.effective_date              := l_wic_rec.effective_date;
      l_arch_rec.assignment_id               := l_assignment_id;
      l_arch_rec.action_information1         := fnd_number.number_to_canonical(l_wic_rec.person_id);
      l_arch_rec.action_information2         := fnd_number.number_to_canonical(l_wic_rec.assignment_action_id);
      l_arch_rec.action_information3         := fnd_number.number_to_canonical(l_wic_rec.payroll_id);
      l_arch_rec.action_information4         := l_swot_rec.reference_number;
      l_arch_rec.action_information5         := l_swot_rec.reference_number1;
      l_arch_rec.action_information6         := l_swot_rec.reference_number2;
      l_arch_rec.action_information7         := fnd_number.number_to_canonical(l_wic_rec.action_sequence);
      l_arch_rec.action_information8         := l_swot_rec.salary_payer_address_kanji;
      l_arch_rec.action_information9         := l_swot_rec.salary_payer_name_kanji;
      l_arch_rec.action_information10        := l_swot_rec.salary_payer_telephone_number;
      l_arch_rec.action_information11        := l_swot_rec.tax_office_number;
      l_arch_rec.action_information12        := fnd_date.date_to_canonical(l_wic_rec.date_earned);
      l_arch_rec.action_information13        := l_wic_rec.employment_category;
      l_arch_rec.action_information14        := l_wic_rec.itax_category;
      l_arch_rec.action_information15        := l_wic_rec.itax_yea_category;
      l_arch_rec.action_information30        := l_submission_required_flag;
    --
    -- JP_ITAX_TAX
    --
      l_tax_rec.action_context_id           := p_assignment_action_id;
      l_tax_rec.action_context_type         := 'AAP';
      l_tax_rec.action_information_category := 'JP_ITAX_TAX';
      l_tax_rec.effective_date              := l_wic_rec.effective_date;
      l_tax_rec.assignment_id               := l_assignment_id;
      l_tax_rec.action_information1         := fnd_number.number_to_canonical(l_certificate_info.tax_info.taxable_income);
      l_tax_rec.action_information2         := fnd_number.number_to_canonical(l_certificate_info.net_taxable_income);
      l_tax_rec.action_information3         := fnd_number.number_to_canonical(l_certificate_info.total_income_exempt);
      l_tax_rec.action_information4         := fnd_number.number_to_canonical(l_certificate_info.tax_info.withholding_itax);
      l_tax_rec.action_information5         := fnd_number.number_to_canonical(l_withholding_tax_info.withholding_itax);
      l_tax_rec.action_information6         := fnd_number.number_to_canonical(l_certificate_info.spouse_sp_exempt);
      l_tax_rec.action_information7         := fnd_number.number_to_canonical(l_certificate_info.tax_info.si_prem);
      l_tax_rec.action_information8         := fnd_number.number_to_canonical(l_certificate_info.tax_info.mutual_aid_prem);
      l_tax_rec.action_information9         := fnd_number.number_to_canonical(l_certificate_info.li_prem_exempt);
      l_tax_rec.action_information10        := fnd_number.number_to_canonical(l_certificate_info.ai_prem_exempt);
      l_tax_rec.action_information11        := fnd_number.number_to_canonical(l_certificate_info.housing_tax_reduction);
      l_tax_rec.action_information12        := fnd_number.number_to_canonical(l_withholding_tax_info.itax_adjustment);
      l_tax_rec.action_information13        := fnd_number.number_to_canonical(l_certificate_info.spouse_net_taxable_income);
      l_tax_rec.action_information14        := fnd_number.number_to_canonical(l_certificate_info.pp_prem);
      l_tax_rec.action_information15        := fnd_number.number_to_canonical(l_certificate_info.long_ai_prem);
      l_tax_rec.action_information16        := fnd_number.number_to_canonical(l_certificate_info.tax_info.disaster_tax_reduction);
      l_tax_rec.action_information17        := l_prev_job_info.salary_payer_address_kana;
      l_tax_rec.action_information18        := l_prev_job_info.salary_payer_address_kanji;
      l_tax_rec.action_information19        := l_prev_job_info.salary_payer_name_kana;
      l_tax_rec.action_information20        := l_prev_job_info.salary_payer_name_kanji;
    --
      -- bug.6168642
      -- Fixed to set null when no prev jobs exist.
      --l_tax_rec.action_information21      := decode_value(l_prev_job_info.foreign_address_flag = 'Y', '1', '0');
    --
      if l_prev_job_info.foreign_address_flag = 'Y' then
        l_tax_rec.action_information21 := '1';
      elsif l_prev_job_info.foreign_address_flag = 'N' then
        l_tax_rec.action_information21 := '0';
      else
        l_tax_rec.action_information21 := null;
      end if;
    --
      l_tax_rec.action_information22 := fnd_number.number_to_canonical(l_prev_job_info.taxable_income);
      l_tax_rec.action_information23 := fnd_number.number_to_canonical(l_prev_job_info.itax);
      l_tax_rec.action_information24 := fnd_number.number_to_canonical(l_prev_job_info.si_prem);
    --
      jp_date(
        p_date    => l_prev_job_info.termination_date,
        p_meiji   => l_dummy,
        p_taishou => l_dummy,
        p_shouwa  => l_dummy,
        p_heisei  => l_dummy,
        p_year    => l_tax_rec.action_information25,
        p_month   => l_tax_rec.action_information26,
        p_day     => l_tax_rec.action_information27);
    --
    -- housing_residence_date will be null since april 2009
    --
      jp_date(
        p_date    => l_certificate_info.housing_residence_date,
        p_meiji   => l_dummy,
        p_taishou => l_dummy,
        p_shouwa  => l_dummy,
        p_heisei  => l_dummy,
        p_year    => l_tax_rec.action_information28,
        p_month   => l_tax_rec.action_information29,
        p_day     => l_tax_rec.action_information30);
    --
    -- JP_ITAX_OTHER
    --
      l_other_rec.action_context_id           := p_assignment_action_id;
      l_other_rec.action_context_type         := 'AAP';
      l_other_rec.action_information_category := 'JP_ITAX_OTHER';
      l_other_rec.effective_date              := l_wic_rec.effective_date;
      l_other_rec.assignment_id               := l_assignment_id;
      -- Dependent Spouse
      l_other_rec.action_information1  := check_when_true(l_certificate_info.dep_spouse_exists_kou = 'Y');
      l_other_rec.action_information2  := check_when_true(l_certificate_info.dep_spouse_not_exist_kou = 'Y');
      l_other_rec.action_information3  := check_when_true(l_certificate_info.dep_spouse_exists_otsu = 'Y');
      l_other_rec.action_information4  := check_when_true(l_certificate_info.dep_spouse_not_exist_otsu = 'Y');
      l_other_rec.action_information5  := check_when_true(l_certificate_info.aged_spouse_exists = 'Y');
      -- Dependents
      l_other_rec.action_information6  := fnd_number.number_to_canonical(l_certificate_info.num_specifieds_kou);
      l_other_rec.action_information7  := fnd_number.number_to_canonical(l_certificate_info.num_specifieds_otsu);
      l_other_rec.action_information8  := fnd_number.number_to_canonical(l_certificate_info.num_aged_parents_lt);
      l_other_rec.action_information9  := fnd_number.number_to_canonical(l_certificate_info.num_ageds_kou);
      l_other_rec.action_information10 := fnd_number.number_to_canonical(l_certificate_info.num_ageds_otsu);
      l_other_rec.action_information11 := fnd_number.number_to_canonical(l_certificate_info.num_deps_kou);
      l_other_rec.action_information12 := fnd_number.number_to_canonical(l_certificate_info.num_deps_otsu);
      -- Disableds
      l_other_rec.action_information13 := fnd_number.number_to_canonical(l_certificate_info.num_svr_disableds_lt);
      l_other_rec.action_information14 := fnd_number.number_to_canonical(l_certificate_info.num_svr_disableds);
      l_other_rec.action_information15 := fnd_number.number_to_canonical(l_certificate_info.num_disableds);
      -- Other Additional Info
      l_other_rec.action_information16 := check_when_true(l_certificate_info.husband_exists = 'Y');
      l_other_rec.action_information17 := check_when_true(l_certificate_info.minor_flag = 'Y');
      l_other_rec.action_information18 := check_when_true(l_certificate_info.otsu_flag = 'Y');
      l_other_rec.action_information19 := check_when_true(l_certificate_info.svr_disabled_flag = 'Y');
      l_other_rec.action_information20 := check_when_true(l_certificate_info.disabled_flag = 'Y');
      l_other_rec.action_information21 := check_when_true(l_certificate_info.aged_flag = 'Y');
      l_other_rec.action_information22 := check_when_true(l_certificate_info.widow_flag = 'Y');
      l_other_rec.action_information23 := check_when_true(l_certificate_info.sp_widow_flag = 'Y');
      l_other_rec.action_information24 := check_when_true(l_certificate_info.widower_flag = 'Y');
      l_other_rec.action_information25 := check_when_true(l_certificate_info.working_student_flag = 'Y');
      l_other_rec.action_information26 := check_when_true(l_certificate_info.deceased_termination_flag = 'Y');
      l_other_rec.action_information27 := check_when_true(l_certificate_info.disastered_flag = 'Y');
      l_other_rec.action_information28 := check_when_true(l_certificate_info.foreigner_flag = 'Y');
      --
      l_other_rec.action_information29 := check_when_true(l_wic_rec.date_start is not null);
      l_other_rec.action_information30 := check_when_true(l_wic_rec.actual_termination_date is not null);
    --
    -- JP_ITAX_OTHER2
    --
      l_other2_rec.action_context_id           := p_assignment_action_id;
      l_other2_rec.action_context_type         := 'AAP';
      l_other2_rec.action_information_category := 'JP_ITAX_OTHER2';
      l_other2_rec.effective_date              := l_wic_rec.effective_date;
      l_other2_rec.assignment_id               := l_assignment_id;
      l_other2_rec.action_information1         := fnd_number.canonical_to_number(g_business_group_id);
    --
      hr_utility.set_location(c_proc, 80);
    --
    -- Construct ITW description
    --
      l_itw_system_desc1_kanji := null;
      l_itw_system_desc2_kanji := null;
    --
      for i in 1..l_itw_descriptions.count loop
      --
        hr_utility.trace('itw description: ' || l_itw_descriptions(i).description_type);
      --
      -- Following replace is only for PAYJPITW pdf files.
      --
        if l_itw_descriptions(i).description_type = 'FIXED_RATE_TAX_REDUCTION' then
        --
          l_itw_descriptions(i).description_kanji := replace(l_itw_descriptions(i).description_kanji,g_old_fixed_rate_kanji,g_new_fixed_rate_kanji);
          l_itw_descriptions(i).description_kana := replace(l_itw_descriptions(i).description_kana,g_old_fixed_rate_kana,g_new_fixed_rate_kana);
        --
        elsif l_itw_descriptions(i).description_type = 'NP_PREM' then
        --
          l_itw_descriptions(i).description_kanji := replace(l_itw_descriptions(i).description_kanji,g_old_national_pens_kanji,g_new_national_pens_kanji);
          l_itw_descriptions(i).description_kana := replace(l_itw_descriptions(i).description_kana,g_old_national_pens_kana,g_new_national_pens_kana);
        --
        end if;
      --
      -- following routine will not be used since 2009, description type is NP_PREM_CONC
      --
        if l_itw_descriptions(i).description_type in ('FIXED_RATE_TAX_REDUCTION', 'NP_PREM') then
        --
          concat_description(l_itw_system_desc1_kanji,l_itw_descriptions(i).description_kanji,' ');
        --
        else
        --
          concat_description(l_itw_system_desc2_kanji,l_itw_descriptions(i).description_kanji,',');
        --
        end if;
      --
      end loop;
    --
    -- Construct WTM description
    --
      l_wtm_system_desc_kanji := null;
      l_wtm_system_desc_kana  := null;
    --
      for i in 1..l_wtm_descriptions.count loop
      --
        hr_utility.trace('wtm description: ' || l_wtm_descriptions(i).description_type);
      --
        concat_description(l_wtm_system_desc_kanji,l_wtm_descriptions(i).description_kanji,',');
        concat_description(l_wtm_system_desc_kana,l_wtm_descriptions(i).description_kana,',');
      --
      end loop;
    --
      l_wtm_system_desc_kanji := hr_jp_standard_pkg.to_zenkaku(l_wtm_system_desc_kanji);
      l_wtm_system_desc_kana  := hr_jp_standard_pkg.upper_kana(hr_jp_standard_pkg.to_hankaku(l_wtm_system_desc_kana, '?'));
      l_wtm_user_desc_kanji   := hr_jp_standard_pkg.to_zenkaku(l_wtm_user_desc_kanji);
      l_wtm_user_desc_kana    := hr_jp_standard_pkg.upper_kana(hr_jp_standard_pkg.to_hankaku(l_wtm_user_desc_kana, '?'));
    --
      hr_utility.trace('***** original descriptions *****');
      hr_utility.trace('itw_system_desc1_kanji: ' || l_itw_system_desc1_kanji);
      hr_utility.trace('itw_system_desc2_kanji: ' || l_itw_system_desc2_kanji);
      hr_utility.trace('itw_user_desc_kanji   : ' || l_itw_user_desc_kanji);
      hr_utility.trace('wtm_system_desc_kanji : ' || l_wtm_system_desc_kanji);
      hr_utility.trace('wtm_system_desc_kana  : ' || l_wtm_system_desc_kana);
      hr_utility.trace('wtm_user_desc_kanji   : ' || l_wtm_user_desc_kanji);
      hr_utility.trace('wtm_user_desc_kana    : ' || l_wtm_user_desc_kana);
    --
      l_itw_system_desc1_kanji := rtrim(substrb(l_itw_system_desc1_kanji, 1, 240));
      l_itw_system_desc2_kanji := rtrim(substrb(l_itw_system_desc2_kanji, 1, 300));
      l_itw_user_desc_kanji    := rtrim(substrb(l_itw_user_desc_kanji, 1, 300));
      l_wtm_system_desc_kanji  := substr(l_wtm_system_desc_kanji, 1, 100);
      l_wtm_system_desc_kana   := substr(l_wtm_system_desc_kana, 1, 100);
      l_wtm_user_desc_kanji    := substr(l_wtm_user_desc_kanji, 1, 100);
      l_wtm_user_desc_kana     := substr(l_wtm_user_desc_kana, 1, 100);
    --
      hr_utility.trace('***** truncated descriptions *****');
      hr_utility.trace('itw_system_desc1_kanji: ' || l_itw_system_desc1_kanji);
      hr_utility.trace('itw_system_desc2_kanji: ' || l_itw_system_desc2_kanji);
      hr_utility.trace('itw_user_desc_kanji   : ' || l_itw_user_desc_kanji);
      hr_utility.trace('wtm_system_desc_kanji : ' || l_wtm_system_desc_kanji);
      hr_utility.trace('wtm_system_desc_kana  : ' || l_wtm_system_desc_kana);
      hr_utility.trace('wtm_user_desc_kanji   : ' || l_wtm_user_desc_kanji);
      hr_utility.trace('wtm_user_desc_kana    : ' || l_wtm_user_desc_kana);
    --
    /*
    --
    -- If number of characters for WTM exceeds 100, output to log file
    -- to warn to user.
    --
      log_description(l_wtm_system_desc_kanji, l_wtm_user_desc_kanji, true);
      log_description(l_wtm_system_desc_kana, l_wtm_user_desc_kana, true);
    --
    */
    --
    -- Never use substrb(240) to split string over 240 bytes,
    -- which will truncate multibyte characters.
    --
      l_other2_rec.action_information23 := l_itw_system_desc1_kanji;
    --
      hr_jp_standard_pkg.to_table(l_itw_system_desc2_kanji, 240, l_varchar2_tbl);
      l_other2_rec.action_information15 := get_index_at(l_varchar2_tbl, 1);
      l_other2_rec.action_information16 := get_index_at(l_varchar2_tbl, 2);
    --
      hr_jp_standard_pkg.to_table(l_itw_user_desc_kanji, 240, l_varchar2_tbl);
      l_other2_rec.action_information25 := get_index_at(l_varchar2_tbl, 1);
      l_other2_rec.action_information26 := get_index_at(l_varchar2_tbl, 2);
    --
      hr_jp_standard_pkg.to_table(l_wtm_system_desc_kanji, 240, l_varchar2_tbl);
      l_other2_rec.action_information19 := get_index_at(l_varchar2_tbl, 1);
      l_other2_rec.action_information20 := get_index_at(l_varchar2_tbl, 2);
    --
      hr_jp_standard_pkg.to_table(l_wtm_system_desc_kana, 240, l_varchar2_tbl);
      l_other2_rec.action_information21 := get_index_at(l_varchar2_tbl, 1);
      l_other2_rec.action_information22 := get_index_at(l_varchar2_tbl, 2);
    --
      hr_jp_standard_pkg.to_table(l_wtm_user_desc_kanji, 240, l_varchar2_tbl);
      l_other2_rec.action_information27 := get_index_at(l_varchar2_tbl, 1);
      l_other2_rec.action_information28 := get_index_at(l_varchar2_tbl, 2);
    --
      hr_jp_standard_pkg.to_table(l_wtm_user_desc_kana, 240, l_varchar2_tbl);
      l_other2_rec.action_information29 := get_index_at(l_varchar2_tbl, 1);
      l_other2_rec.action_information30 := get_index_at(l_varchar2_tbl, 2);
    --
      hr_utility.set_location(c_proc, 90);
    --
    -- JP_ITAX_HOUSING
    --
      l_housing_rec.action_context_id           := p_assignment_action_id;
      l_housing_rec.action_context_type         := 'AAP';
      l_housing_rec.assignment_id               := l_assignment_id;
      l_housing_rec.effective_date              := l_wic_rec.effective_date;
      l_housing_rec.action_information_category := 'JP_ITAX_HOUSING';
      l_housing_rec.action_information1         := fnd_number.number_to_canonical(l_housing_info.payable_loan);
      l_housing_rec.action_information2         := fnd_number.number_to_canonical(l_housing_info.loan_count);
      l_housing_rec.action_information3         := fnd_date.date_to_canonical(l_housing_info.residence_date_1);
      l_housing_rec.action_information4         := l_housing_info.loan_type_1;
      l_housing_rec.action_information5         := fnd_number.number_to_canonical(l_housing_info.loan_balance_1);
      l_housing_rec.action_information6         := fnd_date.date_to_canonical(l_housing_info.residence_date_2);
      l_housing_rec.action_information7         := l_housing_info.loan_type_2;
      l_housing_rec.action_information8         := fnd_number.number_to_canonical(l_housing_info.loan_balance_2);
    --
    -- Create the data
    --
      create_action_information(l_person_rec);
      l_action_information_ids.extend;
      l_action_information_ids(l_action_information_ids.last) := l_person_rec.action_information_id;
    --
      create_action_information(l_arch_rec);
      create_action_information(l_tax_rec);
      create_action_information(l_other_rec);
      create_action_information(l_other2_rec);
      create_action_information(l_housing_rec);
    --
    end if;
  --
  end loop;
--
-- Delete old archive data
--
  for l_archive_rec in csr_delete_archives(l_assignment_id, l_action_information_ids) loop
  --
    delete_archive(
      l_archive_rec.action_information_id,
      l_archive_rec.action_context_id,
      l_archive_rec.effective_date);
  --
  end loop;
--
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
END ARCHIVE_CODE;
-- +------------------------------------------------------------------------------------------------+
-- |< DEINITIALIZATION_CODE >-----------------------------------------------------------------------|
-- +------------------------------------------------------------------------------------------------+
PROCEDURE DEINITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
IS
	c_proc			CONSTANT VARCHAR2(61) := c_package || 'DEINITIALIZATION_CODE';
	l_dummy		varchar2(1);
	l_pact_rec	pay_action_information%rowtype;
	--
	cursor csr_pa_exists is
	select	'Y'
	from	dual
	where	exists(
		select	null
		from	pay_action_information
		where	action_context_id = p_payroll_action_id
		and	action_context_type = 'PA');
	--
	cursor csr_assacts is
	select	paa.assignment_action_id
	from	pay_assignment_actions	paa
	where	paa.payroll_action_id = p_payroll_action_id
	and	paa.action_status = 'C'
	and	not exists(
			select	null
			from	pay_action_information	pai
			where	pai.action_context_id = paa.assignment_action_id
			and	pai.action_context_type = 'AAP');
BEGIN
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_pa_exists;
	fetch csr_pa_exists into l_dummy;
	if csr_pa_exists%notfound then
		hr_utility.set_location(c_proc, 20);
		--
		initialization_code(p_payroll_action_id);
		--
		-- JP_ITAX_PACT
		--
		l_pact_rec.action_context_id		:= p_payroll_action_id;
		l_pact_rec.action_context_type		:= 'PA';
		l_pact_rec.action_information_category	:= 'JP_ITAX_PACT';
		l_pact_rec.effective_date		:= g_effective_date;
		l_pact_rec.action_information1		:= fnd_number.number_to_canonical(g_payroll_id);
		l_pact_rec.action_information2		:= fnd_number.number_to_canonical(g_itax_organization_id);
		l_pact_rec.action_information3		:= g_include_terminated_flag;
		l_pact_rec.action_information4		:= fnd_date.date_to_canonical(g_termination_date_from);
		l_pact_rec.action_information5		:= fnd_date.date_to_canonical(g_termination_date_to);
		l_pact_rec.action_information6		:= g_publication_period_status;
		l_pact_rec.action_information7		:= fnd_date.date_to_canonical(g_publication_start_date);
		l_pact_rec.action_information8		:= fnd_date.date_to_canonical(g_publication_end_date);
		--
		create_action_information(l_pact_rec);
	end if;
	--
	-- Delete completed assignment actions without PAY_ACTION_INFORMATION.
	--
	for l_rec in csr_assacts loop
		py_rollback_pkg.rollback_ass_action(l_rec.assignment_action_id);
	end loop;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
END DEINITIALIZATION_CODE;
--
END PAY_JP_ITAX_ARCHIVE_PKG;

/
