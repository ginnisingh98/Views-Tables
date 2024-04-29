--------------------------------------------------------
--  DDL for Package Body PAY_JP_WIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_WIC_PKG" as
/* $Header: pyjpwic.pkb 120.22.12010000.7 2009/11/19 09:41:16 keyazawa ship $ */
--
-- Constants
--
c_package			constant varchar2(31) := 'pay_jp_wic_pkg.';
FIXED_RATE_TAX_REDUCTION	constant varchar2(30) := 'FIXED_RATE_TAX_REDUCTION';
NP_PREM				constant varchar2(30) := 'NP_PREM';
DEPENDENT			constant varchar2(30) := 'DEPENDENT';
PREV_JOB			constant varchar2(30) := 'PREV_JOB';
HOUSING_TAX_REDUCTION		constant varchar2(30) := 'HOUSING_TAX_REDUCTION';
HOUSING_LOAN_INFO constant varchar2(30) := 'HOUSING_LOAN_INFO';
DISASTER_TAX_REDUCTION		constant varchar2(30) := 'DISASTER_TAX_REDUCTION';
ITW				constant varchar2(30) := 'ITW';
WTM				constant varchar2(30) := 'WTM';
--
  NP_PREM_CONC constant varchar2(30) := 'NP_PREM_CONC';
--
  c_date_fmt_itw varchar2(30) := 'EYY.MM.DD';
  c_space_separator varchar2(1) := ' ';
  c_comma_separator varchar2(1) := ',';
  c_bracket_left varchar2(1) := '(';
  c_bracket_right varchar2(1) := ')';
--
-- Global Variables
--
type t_prompt is record(
  yen                          varchar2(80),
  fixed_rate_tax_reduction     varchar2(80),
  national_pens_prem           varchar2(80),
  prev_job                     varchar2(80),
  taxable_income               varchar2(80),
  si_prem                      varchar2(80),
  mutual_aid_prem              varchar2(80),
  itax                         varchar2(80),
  terminated                   varchar2(80),
  housing_tax_reduction        varchar2(80),
  residence_date               varchar2(80),
  unclaimed_housing_tax_reduct varchar2(80),
  -- 2007/06/07
  housing_tax_reduction_long   varchar2(80),
  total_housing_tax_reduction  varchar2(80),
  --
  disaster_tax_reduction       varchar2(80),
  husband                      varchar2(80),
  wife                         varchar2(80),
  date_format                  varchar2(80),
  other                        varchar2(80),
  count                        varchar2(80),
  --
  housing_loan_itw             varchar2(200),
  housing_res_date_itw         varchar2(200),
  housing_loan_balance_itw     varchar2(200),
  housing_loan_type_wtm        varchar2(200),
  housing_count_wtm            varchar2(200),
  housing_res_date_wtm         varchar2(200),
  housing_loan_balance_wtm     varchar2(200),
  np_prem_itw                  varchar2(200),
  housing_loan_type_gen_itw    varchar2(200),
  housing_loan_type_ext_itw    varchar2(200),
  housing_loan_type_etq_itw    varchar2(200)
  --
);
g_prompt_kanji			t_prompt;
g_prompt_kana			t_prompt;
--
type t_taxable_income_exempt_elm is record(
	element_type_id		number,
	net_taxable_income_iv	number,
	taxable_income_iv	number,
	prev_taxable_income_iv	number,
	prev_si_prem_iv		number,
--	prev_itax_iv		number,
	taxable_income_adj_iv	number,
	si_prem_adj_iv		number,
	mutual_aid_prem_adj_iv	number,
	itax_adj_iv		number);
g_taxable_income_exempt_elm	t_taxable_income_exempt_elm;
--
type t_net_annual_itax_elm is record(
	element_type_id			number,
	net_annual_itax_iv		number,
	housing_tax_reduction_iv	number,
	net_housing_tax_reduction_iv	number,
	fixed_rate_tax_reduction_iv	number);
g_net_annual_itax_elm		t_net_annual_itax_elm;
--
g_total_income_exempt_asg_run	number;
g_itax_adjustment_asg_ytd	number;
--g_itax_asg_ytd			number;
--
type t_ins_prem_exempt_elm is record(
	element_type_id			number,
	si_prem_iv			number,
	mutual_aid_prem_iv		number,
	li_prem_exempt_iv		number,
	pp_prem_iv			number,
	ai_prem_exempt_iv		number,
	long_ai_prem_iv			number,
	spouse_sp_exempt_iv		number,
	spouse_net_taxable_income_iv	number);
g_ins_prem_exempt_elm	t_ins_prem_exempt_elm;
--
type t_dep_exempt_elm is record(
	element_type_id		number,
	disabled_iv		number,
	aged_iv			number,
	widow_iv		number,
	working_student_iv	number,
	spouse_type_iv		number,
	spouse_disabled_iv	number,
	num_deps_iv		number,
	num_ageds_iv		number,
	num_aged_parents_lt_iv	number,
	num_specifieds_iv	number,
	num_disableds_iv	number,
	num_svr_disableds_iv	number,
	num_svr_disableds_lt_iv	number);
g_dep_exempt_elm		t_dep_exempt_elm;
g_dep_exempt_result_elm		t_dep_exempt_elm;
--
/*
type t_description_elm is record(
	element_type_id		number,
	override_flag_iv	number,
	description_iv		number,
	mag_override_flag_iv	number,
	mag_description_iv	number,
	description_2_iv	number,
	description_3_iv	number,
	description_4_iv	number,
	description_5_iv	number,
	mag_description_2_iv	number,
	mag_description_3_iv	number,
	mag_description_4_iv	number,
	mag_description_5_iv	number);
g_description_elm		t_description_elm;
*/
g_desc_element_type_id	number;
--
type t_housing_loan_info_elm is record(
  element_type_id number,
  res_date_iv     number,
  loan_type_iv    number,
  loan_balance_iv number);
g_housing_loan_info_elm t_housing_loan_info_elm;
--
type t_itax_info_elm is record(
	element_type_id		number,
	foreigner_flag_iv	number);
g_itax_info_elm			t_itax_info_elm;
--
g_prev_job_elm			number;
--
type t_housing_tax_reduction_elm is record(
	element_type_id		number,
	residence_date_iv	number);
g_housing_tax_reduction_elm	t_housing_tax_reduction_elm;
--
type t_yea_ins_prem_sp_exm_info_elm is record(
  element_type_id		    number,
  national_pens_prem_iv number);
g_yea_ins_prem_sp_exm_info_elm t_yea_ins_prem_sp_exm_info_elm;
--
-- |-------------------------------------------------------------------|
-- |--------------------------< to_jp_char >---------------------------|
-- |-------------------------------------------------------------------|
function to_jp_char(
	p_date		in date,
	p_date_format	in varchar2) return varchar2
is
	l_dummy		varchar2(255);
begin
	--
	-- PL/SQL "to_char" has bug which does not work with "NLS" parameters.
	-- We here use ORACLE "to_char" as a workaround.
	--
	if p_date is not null then
		select	to_char(p_date, p_date_format, 'NLS_CALENDAR=''Japanese Imperial''')
		into	l_dummy
		from	dual;
	end if;
	--
	return l_dummy;
end to_jp_char;
-- |-------------------------------------------------------------------|
-- |-------------------------< decode_value >--------------------------|
-- |-------------------------------------------------------------------|
function decode_value(
	p_condition	in boolean,
	p_value1	in number,
	p_value2	in number default null) return number
is
begin
	if p_condition then
		return p_value1;
	else
		return p_value2;
	end if;
end decode_value;
-- |-------------------------------------------------------------------|
-- |-------------------< get_withholding_tax_info >--------------------|
-- |-------------------------------------------------------------------|
-- This procedure grosses up from table PAY_JP_PRE_TAX used for
-- 1) derive current employer's payment for YEAed assignments
-- 2) derive non-YEAed amount including previous SWOTs' amount
procedure get_withholding_tax_info(
	p_assignment_action_id		in number,
	p_assignment_id			in number,
	p_action_sequence		in number,
	p_effective_date		in date,
	p_itax_organization_id		in number,
	p_itax_category			in varchar2,
	p_itax_yea_category		in varchar2,
	p_withholding_tax_info		out nocopy t_tax_info)
is
	c_proc		constant varchar2(61) := c_package || 'get_withholding_tax_info';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if p_itax_yea_category = '0' then
		hr_utility.set_location(c_proc, 11);
		--
		-- Grossup "Taxable Earnings", "Income Tax" etc.
		-- with the same "SWOT".
		--
		select	nvl(sum(taxable_amt), 0),
			nvl(sum(mutual_aid), 0),
			nvl(sum(si_prem), 0),
			nvl(sum(itax), 0),
			nvl(sum(itax_adjustment), 0),
			nvl(sum(disaster_tax_reduction), 0)
		into	p_withholding_tax_info.taxable_income,
			p_withholding_tax_info.mutual_aid_prem,
			p_withholding_tax_info.si_prem,
			p_withholding_tax_info.itax,
			p_withholding_tax_info.itax_adjustment,
			p_withholding_tax_info.disaster_tax_reduction
		from	pay_jp_wic_assacts_v2
		where	assignment_id = p_assignment_id
		and	action_sequence <= p_action_sequence
		and	effective_date >= trunc(p_effective_date, 'YYYY')
		and	itax_organization_id = p_itax_organization_id;
	else
		hr_utility.set_location(c_proc, 12);
		--
		-- Grossup "Taxable Earnings", "Income Tax" etc.
		-- with the same "Tax Category" and "SWOT".
		--
		select	nvl(sum(taxable_amt), 0),
			nvl(sum(mutual_aid), 0),
			nvl(sum(si_prem), 0),
			nvl(sum(itax), 0),
			nvl(sum(itax_adjustment), 0),
			nvl(sum(disaster_tax_reduction), 0)
		into	p_withholding_tax_info.taxable_income,
			p_withholding_tax_info.mutual_aid_prem,
			p_withholding_tax_info.si_prem,
			p_withholding_tax_info.itax,
			p_withholding_tax_info.itax_adjustment,
			p_withholding_tax_info.disaster_tax_reduction
		from	pay_jp_wic_assacts_v2
		where	assignment_id = p_assignment_id
		and	action_sequence <= p_action_sequence
		and	effective_date >= trunc(p_effective_date, 'YYYY')
		and	(
				(p_itax_category in ('M_KOU', 'D_KOU') and itax_category in ('M_KOU', 'D_KOU'))
			or	(p_itax_category in ('M_OTSU', 'D_OTSU') and itax_category in ('M_OTSU', 'D_OTSU'))
			or	(p_itax_category = 'D_HEI' and itax_category = 'D_HEI')
			)
		and	itax_organization_id = p_itax_organization_id;
	end if;
	--
	hr_utility.set_location(c_proc, 20);
	--
	-- When current assignment_action_id is "YEA",
	-- add the adjustment amount processed in YEA process.
	-- Note if future assacts exist after YEA, it is not regarded as YEA,
	-- it is just normal payment. In this case, no adjustment amount in YEA
	-- is included to the total amount(Skip when null or '-1').
	--
	if p_itax_yea_category <> '-1' then
		hr_utility.set_location(c_proc, 21);
		--
		p_withholding_tax_info.taxable_income	:= p_withholding_tax_info.taxable_income
							 + nvl(pay_jp_balance_pkg.get_result_value_number(g_taxable_income_exempt_elm.element_type_id, g_taxable_income_exempt_elm.taxable_income_adj_iv, p_assignment_action_id), 0);
		p_withholding_tax_info.si_prem		:= p_withholding_tax_info.si_prem
							 + nvl(pay_jp_balance_pkg.get_result_value_number(g_taxable_income_exempt_elm.element_type_id, g_taxable_income_exempt_elm.si_prem_adj_iv, p_assignment_action_id), 0);
		p_withholding_tax_info.mutual_aid_prem	:= p_withholding_tax_info.mutual_aid_prem
							 + nvl(pay_jp_balance_pkg.get_result_value_number(g_taxable_income_exempt_elm.element_type_id, g_taxable_income_exempt_elm.mutual_aid_prem_adj_iv, p_assignment_action_id), 0);
		p_withholding_tax_info.itax		:= p_withholding_tax_info.itax
							 + nvl(pay_jp_balance_pkg.get_result_value_number(g_taxable_income_exempt_elm.element_type_id, g_taxable_income_exempt_elm.itax_adj_iv, p_assignment_action_id), 0);
	end if;
	--
	p_withholding_tax_info.mutual_aid_prem		:= decode_value(p_withholding_tax_info.mutual_aid_prem <> 0, p_withholding_tax_info.mutual_aid_prem);
	p_withholding_tax_info.disaster_tax_reduction	:= decode_value(p_withholding_tax_info.disaster_tax_reduction <> 0, p_withholding_tax_info.disaster_tax_reduction);
	p_withholding_tax_info.withholding_itax		:= p_withholding_tax_info.itax + p_withholding_tax_info.itax_adjustment;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end get_withholding_tax_info;
-- |-------------------------------------------------------------------|
-- |-------------------------< get_prev_jobs >-------------------------|
-- |-------------------------------------------------------------------|
-- Private Procedure
procedure get_prev_jobs(
	p_assignment_id			in number,
	p_action_sequence		in number,
	p_business_group_id		in number,
	p_effective_date		in date,
	p_date_earned			in date,
	p_itax_organization_id		in number,
	p_person_id			in number,
	p_prev_jobs			out nocopy t_prev_jobs)
is
	c_proc				constant varchar2(61) := c_package || 'get_prev_jobs';
	l_withholding_tax_info		t_tax_info;
	l_prev_job_info			t_prev_job_info;
	l_found				boolean;
	l_upgrade_status		varchar2(1);
	--
	cursor csr_swot is
		select	wic.assignment_action_id,
			wic.assignment_id,
			wic.action_sequence,
			wic.effective_date,
			wic.itax_organization_id,
			wic.itax_category,
			wic.itax_yea_category,
			hoi.org_information1							SALARY_PAYER_NAME_KANJI,
			hoi.org_information2							SALARY_PAYER_NAME_KANA,
			hoi.org_information6 || hoi.org_information7 || hoi.org_information8	SALARY_PAYER_ADDRESS_KANJI,
			hoi.org_information9 || hoi.org_information10 || hoi.org_information11	SALARY_PAYER_ADDRESS_KANA
		from	hr_organization_information	hoi,
			pay_jp_wic_assacts_v		wic
		where	wic.assignment_id = p_assignment_id
		and	wic.action_sequence < p_action_sequence
		and	wic.effective_date >= trunc(p_effective_date, 'YYYY')
		and	wic.itax_organization_id <> p_itax_organization_id
-- The following condition removed because dimension (in YEA) can not handle this case.
--		and	wic.itax_category in ('M_KOU', 'D_KOU', 'D_HEI')
		and	hoi.organization_id(+) = wic.itax_organization_id
		and	hoi.org_information_context(+) = 'JP_TAX_SWOT_INFO'
		order by wic.action_sequence desc;
	--
	cursor csr_job_pem is
		-- Added nvl(*, 0) except for mutual_aid_prem
		select	nvl(fnd_number.canonical_to_number(pem_information3), 0)	taxable_income,
			nvl(fnd_number.canonical_to_number(pem_information4), 0)	si_prem,
			fnd_number.canonical_to_number(pem_information5)		mutual_aid_prem,
			nvl(fnd_number.canonical_to_number(pem_information6), 0)	itax,
			end_date						termination_date,
			decode(employer_country, null, 'N', 'JP', 'N', 'Y')	foreign_address_flag,
			employer_name						salary_payer_name_kanji,
			employer_address					salary_payer_address_kanji,
			pem_information1					salary_payer_name_kana,
			pem_information2					salary_payer_address_kana
		from	per_previous_employers
		where	person_id = p_person_id
		--
		-- Bug.4159708. Added new segment "Tax Year"(PEM_INFORMATION7)
		--
		and	pem_information_category = 'JP'
		and	p_effective_date >= nvl(end_date, p_effective_date)
		and	(
				(
					pem_information7 is not null
				and	fnd_number.canonical_to_number(pem_information7) = to_number(to_char(p_effective_date, 'YYYY'))
				)
			or	(	pem_information7 is null
				and	end_date >= trunc(p_effective_date, 'YYYY')
				)
			)
		order by end_date desc;
	--
	cursor csr_job_pee is
		-- Removed nvl(*, 0) from mutual_aid_prem
		select	nvl(sum(decode(piv.display_sequence, 1, to_number(peev.screen_entry_value))), 0)				taxable_income,
			nvl(sum(decode(piv.display_sequence, 2, to_number(peev.screen_entry_value))), 0)				si_prem,
			sum(decode(piv.display_sequence, 3, to_number(peev.screen_entry_value)))					mutual_aid_prem,
			nvl(sum(decode(piv.display_sequence, 4, to_number(peev.screen_entry_value))), 0)				itax,
			min(decode(piv.display_sequence, 5, fnd_date.canonical_to_date(peev.screen_entry_value)))			termination_date,
			nvl(min(decode(piv.display_sequence, 6, peev.screen_entry_value)), 'N')						foreign_address_flag,
			min(decode(piv.display_sequence, 7, peev.screen_entry_value))							salary_payer_address_kana,
			min(decode(piv.display_sequence, 8, peev.screen_entry_value))							salary_payer_address_kanji,
			min(decode(piv.display_sequence, 9, peev.screen_entry_value))							salary_payer_name_kana,
			min(decode(piv.display_sequence, 10, peev.screen_entry_value))							salary_payer_name_kanji
		from	pay_input_values_f		piv,
			pay_element_entry_values_f	peev,
			pay_element_entries_f		pee,
			pay_element_links_f		pel
		where	pel.element_type_id = g_prev_job_elm
		and	pel.business_group_id + 0 = p_business_group_id
		and	p_date_earned
			between pel.effective_start_date and pel.effective_end_date
		and	pee.assignment_id = p_assignment_id
		and	pee.element_link_id = pel.element_link_id
		and	p_date_earned
			between pee.effective_start_date and pee.effective_end_date
		and	peev.element_entry_id = pee.element_entry_id
		and	peev.effective_start_date = pee.effective_start_date
		and	peev.effective_end_date = pee.effective_end_date
		and	piv.input_value_id = peev.input_value_id
		and	p_date_earned
			between piv.effective_start_date and piv.effective_end_date
		group by pee.element_entry_id
		order by termination_date desc;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	for l_rec in csr_swot loop
		--
		-- If the same itax_organization_id exist, existing information is replaced
		-- by subsequent information, and the total amount is grossed up.
		-- No need to call get_certificate_info because itax_yea_category of previous
		-- employers' is "null" or "-1".
		--
		get_withholding_tax_info(
			p_assignment_action_id		=> l_rec.assignment_action_id,
			p_assignment_id			=> l_rec.assignment_id,
			p_action_sequence		=> l_rec.action_sequence,
			p_effective_date		=> l_rec.effective_date,
			p_itax_organization_id		=> l_rec.itax_organization_id,
			p_itax_category			=> l_rec.itax_category,
			p_itax_yea_category		=> l_rec.itax_yea_category,
			p_withholding_tax_info		=> l_withholding_tax_info);
		--
		l_found := false;
		for i in 1..p_prev_jobs.count loop
			l_prev_job_info := p_prev_jobs(i);
			--
			if l_prev_job_info.itax_organization_id = l_rec.itax_organization_id then
				l_prev_job_info.taxable_income	:= l_prev_job_info.taxable_income + l_withholding_tax_info.taxable_income;
				-- mutual_aid_prem can be <null>, so remember to use nvl before adding.
				if l_withholding_tax_info.mutual_aid_prem <> 0 then
					l_prev_job_info.mutual_aid_prem	:= nvl(l_prev_job_info.mutual_aid_prem, 0) + l_withholding_tax_info.mutual_aid_prem;
				end if;
				l_prev_job_info.si_prem		:= l_prev_job_info.si_prem + l_withholding_tax_info.si_prem;
				l_prev_job_info.itax		:= l_prev_job_info.itax + l_withholding_tax_info.withholding_itax;
				--
				p_prev_jobs(i) := l_prev_job_info;
				l_found := true;
				exit;
			end if;
		end loop;
		--
		if not l_found then
			l_prev_job_info := null;
			--
			l_prev_job_info.itax_organization_id		:= l_rec.itax_organization_id;
			l_prev_job_info.taxable_income			:= l_withholding_tax_info.taxable_income;
			l_prev_job_info.mutual_aid_prem			:= l_withholding_tax_info.mutual_aid_prem;
			l_prev_job_info.mutual_aid_prem			:= decode_value(l_prev_job_info.mutual_aid_prem <> 0, l_prev_job_info.mutual_aid_prem);
			l_prev_job_info.si_prem				:= l_withholding_tax_info.si_prem;
			l_prev_job_info.itax				:= l_withholding_tax_info.withholding_itax;
			l_prev_job_info.foreign_address_flag		:= 'N';
			l_prev_job_info.salary_payer_address_kanji	:= l_rec.salary_payer_address_kanji;
			l_prev_job_info.salary_payer_address_kana	:= l_rec.salary_payer_address_kana;
			l_prev_job_info.salary_payer_name_kanji		:= l_rec.salary_payer_name_kanji;
			l_prev_job_info.salary_payer_name_kana		:= l_rec.salary_payer_name_kana;
			--
			-- Bug.5116358
			-- Changed not to set termination_date for previous SWOTs
			-- in the same company.
			--
--			l_prev_job_info.termination_date		:= l_rec.effective_date;
			--
			p_prev_jobs(p_prev_jobs.count + 1) := l_prev_job_info;
		end if;
	end loop;
	--
	hr_utility.set_location(c_proc, 20);
	--
	pay_core_utils.get_upgrade_status(
		P_BUS_GRP_ID	=> p_business_group_id,
		P_SHORT_NAME	=> 'JP_PREV_JOB',
		P_STATUS	=> l_upgrade_status,
		P_RAISE_ERROR	=> true);
	--
	if l_upgrade_status = 'Y' then
		hr_utility.set_location(c_proc, 21);
		--
		for l_rec in csr_job_pem loop
			l_prev_job_info := null;
			--
			-- itax_organization_id is null in element entry case.
			--
			l_prev_job_info.taxable_income			:= l_rec.taxable_income;
			l_prev_job_info.mutual_aid_prem			:= l_rec.mutual_aid_prem;
			l_prev_job_info.si_prem				:= l_rec.si_prem;
			l_prev_job_info.itax				:= l_rec.itax;
			l_prev_job_info.foreign_address_flag		:= l_rec.foreign_address_flag;
			l_prev_job_info.salary_payer_address_kanji	:= l_rec.salary_payer_address_kanji;
			l_prev_job_info.salary_payer_address_kana	:= l_rec.salary_payer_address_kana;
			l_prev_job_info.salary_payer_name_kanji		:= l_rec.salary_payer_name_kanji;
			l_prev_job_info.salary_payer_name_kana		:= l_rec.salary_payer_name_kana;
			l_prev_job_info.termination_date		:= l_rec.termination_date;
			--
			p_prev_jobs(p_prev_jobs.count + 1) := l_prev_job_info;
		end loop;
	else
		hr_utility.set_location(c_proc, 22);
		--
		for l_rec in csr_job_pee loop
			l_prev_job_info := null;
			--
			-- itax_organization_id is null in element entry case.
			--
			l_prev_job_info.taxable_income			:= l_rec.taxable_income;
			l_prev_job_info.mutual_aid_prem			:= l_rec.mutual_aid_prem;
			l_prev_job_info.si_prem				:= l_rec.si_prem;
			l_prev_job_info.itax				:= l_rec.itax;
			l_prev_job_info.foreign_address_flag		:= l_rec.foreign_address_flag;
			l_prev_job_info.salary_payer_address_kanji	:= l_rec.salary_payer_address_kanji;
			l_prev_job_info.salary_payer_address_kana	:= l_rec.salary_payer_address_kana;
			l_prev_job_info.salary_payer_name_kanji		:= l_rec.salary_payer_name_kanji;
			l_prev_job_info.salary_payer_name_kana		:= l_rec.salary_payer_name_kana;
			l_prev_job_info.termination_date		:= l_rec.termination_date;
			--
			p_prev_jobs(p_prev_jobs.count + 1) := l_prev_job_info;
		end loop;
	end if;
	--
	hr_utility.set_location(c_proc, 30);
	--
	for i in 1..p_prev_jobs.count loop
		p_prev_jobs(i).mutual_aid_prem := decode_value(p_prev_jobs(i).mutual_aid_prem <> 0, p_prev_jobs(i).mutual_aid_prem);
	end loop;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end get_prev_jobs;
--
function convert_prev_jobs(p_prev_jobs	t_prev_jobs) return t_prev_job_info
is
	l_prev_jobs_count	number;
	l_prev_job_info		t_prev_job_info;
begin
	l_prev_jobs_count := p_prev_jobs.count;
	--
	-- Null to clear default values when no prev jobs found.
	--
	if l_prev_jobs_count = 0 then
		l_prev_job_info := null;
	else
		for i in 1..l_prev_jobs_count loop
			if i = 1 then
				l_prev_job_info := p_prev_jobs(i);
				--
				l_prev_job_info.salary_payer_address_kanji	:= hr_jp_standard_pkg.to_zenkaku(l_prev_job_info.salary_payer_address_kanji);
				l_prev_job_info.salary_payer_address_kana	:= hr_jp_standard_pkg.upper_kana(
											hr_jp_standard_pkg.to_hankaku(l_prev_job_info.salary_payer_address_kana, '?'));
				--
				if l_prev_jobs_count > 1 then
					l_prev_job_info.salary_payer_name_kanji := ltrim(  l_prev_job_info.salary_payer_name_kanji
											|| ' '
											|| g_prompt_kanji.other
											|| to_char(l_prev_jobs_count - 1)
											|| g_prompt_kanji.count);
					--
					l_prev_job_info.salary_payer_name_kana := ltrim(   l_prev_job_info.salary_payer_name_kana
											|| ' '
											|| g_prompt_kana.other
											|| to_char(l_prev_jobs_count - 1)
											|| g_prompt_kana.count);
				end if;
				--
				l_prev_job_info.salary_payer_name_kanji		:= hr_jp_standard_pkg.to_zenkaku(l_prev_job_info.salary_payer_name_kanji);
				l_prev_job_info.salary_payer_name_kana		:= hr_jp_standard_pkg.upper_kana(
											hr_jp_standard_pkg.to_hankaku(l_prev_job_info.salary_payer_name_kana, '?'));
			else
				l_prev_job_info.taxable_income	:= l_prev_job_info.taxable_income + p_prev_jobs(i).taxable_income;
				-- mutual_aid_prem can be <null>, so remember to use nvl before adding.
				if p_prev_jobs(i).mutual_aid_prem <> 0 then
					l_prev_job_info.mutual_aid_prem	:= nvl(l_prev_job_info.mutual_aid_prem, 0) + p_prev_jobs(i).mutual_aid_prem;
				end if;
				l_prev_job_info.si_prem		:= l_prev_job_info.si_prem + p_prev_jobs(i).si_prem;
				l_prev_job_info.itax		:= l_prev_job_info.itax + p_prev_jobs(i).itax;
			end if;
		end loop;
	end if;
	--
	return l_prev_job_info;
end convert_prev_jobs;
--
function convert_housing_tbl(
  p_effective_date    in date,
  p_itax_yea_category in varchar2,
  p_certificate_info  in t_certificate_info,
  p_housing_tbl       in t_housing_tbl)
return t_housing_info
is
--
  l_total_housing_loan number;
  l_housing_info t_housing_info;
--
begin
--
  l_total_housing_loan := p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct;
--
  l_housing_info.residence_date_1 := null;
  l_housing_info.loan_count       := null;
  l_housing_info.payable_loan     := null;
  l_housing_info.loan_type_1      := null;
  l_housing_info.loan_balance_1   := null;
  l_housing_info.residence_date_2 := null;
  l_housing_info.loan_type_2      := null;
  l_housing_info.loan_balance_2   := null;
--
  -- l_total_housing_loan is null in case p_itax_yea_category = '0'
  if l_total_housing_loan <> 0
  and p_certificate_info.unclaimed_housing_tax_reduct <> 0 then
  --
    l_housing_info.payable_loan := l_total_housing_loan;
  --
  end if;
--
  if to_number(to_char(p_effective_date,'YYYY')) > 2009
  or (to_number(to_char(p_effective_date,'YYYY')) = 2009
     and to_number(to_char(p_effective_date,'MM')) >= 4) then
  --
    -- p_housing_tbl exists in case when p_itax_yea_category = '0' and l_total_housing_loan <> 0
    -- should not related with p_certificate_info.unclaimed_housing_tax_reduct in efile
  --
    if p_housing_tbl.count > 0 then
    --
      l_housing_info.loan_count := p_housing_tbl.count;
    --
      <<loop_housing_tbl>>
      for i in 1..p_housing_tbl.count loop
      --
        if i > 2 then
        --
          exit loop_housing_tbl;
        --
        end if;
      --
        if i = 1 then
        --
          l_housing_info.residence_date_1 := p_housing_tbl(i).residence_date;
          l_housing_info.loan_type_1      := p_housing_tbl(i).loan_type;
        --
          if (p_housing_tbl.count > 1
          or (p_housing_tbl.count = 1 and p_housing_tbl(1).loan_type = '03')) then
          --
            l_housing_info.loan_balance_1 := p_housing_tbl(i).loan_balance;
          --
          end if;
        --
        elsif i = 2 then
        --
          l_housing_info.residence_date_2 := p_housing_tbl(i).residence_date;
          l_housing_info.loan_type_2      := p_housing_tbl(i).loan_type;
          l_housing_info.loan_balance_2   := p_housing_tbl(i).loan_balance;
        --
        end if;
      --
      end loop loop_housing_tbl;
    --
    end if;
  --
  elsif (to_number(to_char(p_effective_date,'YYYY')) = 2009
        and to_number(to_char(p_effective_date,'MM')) < 4) then
  --
    if p_itax_yea_category = '0'
    and l_total_housing_loan <> 0 then
    --
      l_housing_info.loan_count := 1;
    --
      l_housing_info.residence_date_1 := p_certificate_info.housing_residence_date;
    --
    end if;
  --
  end if;
--
return l_housing_info;
--
end convert_housing_tbl;
--
-- |-------------------------------------------------------------------|
-- |------------------< get_basic_certificate_info >-------------------|
-- |-------------------------------------------------------------------|
-- Source function for ITT, get_basic_certificate_info (source function for ITW, WTP, wrapper ITW Archive) (called from gci_s : gci_s_b)
procedure get_basic_certificate_info(
	p_assignment_action_id		in number,
	p_assignment_id			in number,
	p_action_sequence		in number,
	p_effective_date		in date,
	p_itax_organization_id		in number,
	p_itax_category			in varchar2,
	p_itax_yea_category		in varchar2,
	p_employment_category		in varchar2,
	p_certificate_info		out nocopy t_tax_info,
	p_submission_required_flag	out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'get_basic_certificate_info (1)';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if p_itax_yea_category = '0' then
		hr_utility.set_location(c_proc, 21);
		--
		p_certificate_info.taxable_income	:= nvl(pay_jp_balance_pkg.get_result_value_number(g_taxable_income_exempt_elm.element_type_id, g_taxable_income_exempt_elm.taxable_income_iv, p_assignment_action_id), 0);
		p_certificate_info.mutual_aid_prem	:= nvl(pay_jp_balance_pkg.get_result_value_number(g_ins_prem_exempt_elm.element_type_id, g_ins_prem_exempt_elm.mutual_aid_prem_iv, p_assignment_action_id), 0);
		p_certificate_info.mutual_aid_prem	:= decode_value(p_certificate_info.mutual_aid_prem <> 0, p_certificate_info.mutual_aid_prem);
		p_certificate_info.si_prem		:= nvl(pay_jp_balance_pkg.get_result_value_number(g_ins_prem_exempt_elm.element_type_id, g_ins_prem_exempt_elm.si_prem_iv, p_assignment_action_id), 0);
/*
		p_certificate_info.itax			:= pay_jp_balance_pkg.get_balance_value(g_itax_asg_ytd, p_assignment_action_id)
						 	+ nvl(pay_jp_balance_pkg.get_result_value_number(g_taxable_income_exempt_elm.element_type_id, g_taxable_income_exempt_elm.prev_itax_iv, p_assignment_action_id), 0)
						 	+ nvl(pay_jp_balance_pkg.get_result_value_number(g_taxable_income_exempt_elm.element_type_id, g_taxable_income_exempt_elm.itax_adj_iv, p_assignment_action_id), 0);
*/
		p_certificate_info.itax_adjustment	:= pay_jp_balance_pkg.get_balance_value(g_itax_adjustment_asg_ytd, p_assignment_action_id);
		p_certificate_info.withholding_itax	:= nvl(pay_jp_balance_pkg.get_result_value_number(g_net_annual_itax_elm.element_type_id, g_net_annual_itax_elm.net_annual_itax_iv, p_assignment_action_id), 0);
		p_certificate_info.itax			:= p_certificate_info.withholding_itax - p_certificate_info.itax_adjustment;
		--
		-- No need to calculate Disaster Tax Reduction in case of YEA because it should be ZERO.
		--
	else
		hr_utility.set_location(c_proc, 22);
		--
		-- Derive tax information withheld by current employer.
		--
		get_withholding_tax_info(
			p_assignment_action_id		=> p_assignment_action_id,
			p_assignment_id			=> p_assignment_id,
			p_action_sequence		=> p_action_sequence,
			p_effective_date		=> p_effective_date,
			p_itax_organization_id		=> p_itax_organization_id,
			p_itax_category			=> p_itax_category,
			p_itax_yea_category		=> p_itax_yea_category,
			p_withholding_tax_info		=> p_certificate_info);
	end if;
	--
	hr_utility.set_location(c_proc, 30);
	--
	-- Check whether this Tax Receipt is required to submit to Tax Office or not.
	--
	p_submission_required_flag := 'N';
	if to_number(to_char(p_effective_date, 'YYYY')) between 0 and 4712 then
		if p_itax_yea_category = '0' then
			if p_employment_category = 'JP_EX' then
				if p_certificate_info.taxable_income > 1500000 then
					p_submission_required_flag := 'Y';
				end if;
			else
				if p_certificate_info.taxable_income > 5000000 then
					p_submission_required_flag := 'Y';
				end if;
			end if;
		else
			if p_itax_category in ('M_KOU', 'D_KOU') then
				if p_employment_category = 'JP_EX' then
					if p_certificate_info.taxable_income > 500000 then
						p_submission_required_flag := 'Y';
					end if;
				else
					if p_certificate_info.taxable_income > 2500000 then
						p_submission_required_flag := 'Y';
					end if;
				end if;
			else
				if p_certificate_info.taxable_income > 500000 then
					p_submission_required_flag := 'Y';
				end if;
			end if;
		end if;
	end if;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end get_basic_certificate_info;
--
-- Following is deprecated.
--
procedure get_certificate_info(
	p_assignment_action_id		in number,
	p_assignment_id			in number,
	p_action_sequence		in number,
	p_effective_date		in date,
	p_itax_organization_id		in number,
	p_itax_category			in varchar2,
	p_itax_yea_category		in varchar2,
	p_employment_category		in varchar2,
	p_person_id			in number,
	p_business_group_id		in number,
	p_date_earned			in date,
	p_certificate_info		out nocopy t_tax_info,
	p_submission_required_flag	out nocopy varchar2,
	p_withholding_tax_info		out nocopy t_tax_info,
	p_prev_jobs			out nocopy t_prev_jobs)
is
begin
	get_certificate_info(
		p_assignment_action_id		=> p_assignment_action_id,
		p_assignment_id			=> p_assignment_id,
		p_action_sequence		=> p_action_sequence,
		p_effective_date		=> p_effective_date,
		p_itax_organization_id		=> p_itax_organization_id,
		p_itax_category			=> p_itax_category,
		p_itax_yea_category		=> p_itax_yea_category,
		p_employment_category		=> p_employment_category,
		p_person_id			=> p_person_id,
		p_business_group_id		=> p_business_group_id,
		p_date_earned			=> p_date_earned,
		p_certificate_info		=> p_certificate_info,
		p_submission_required_flag	=> p_submission_required_flag,
		p_withholding_tax_info		=> p_withholding_tax_info);
	--
	get_prev_jobs(
		p_assignment_id			=> p_assignment_id,
		p_action_sequence		=> p_action_sequence,
		p_business_group_id		=> p_business_group_id,
		p_effective_date		=> p_effective_date,
		p_date_earned			=> p_date_earned,
		p_itax_organization_id		=> p_itax_organization_id,
		p_person_id			=> p_person_id,
		p_prev_jobs			=> p_prev_jobs);
end get_certificate_info;
-- |-------------------------------------------------------------------|
-- |---------------------------< get_dpnts >---------------------------|
-- |-------------------------------------------------------------------|
-- Private Procedure
procedure get_dpnts(
	p_dpnt_ref_type		in varchar2,
	p_assignment_id		in number,
	p_itax_category		in varchar2,
	p_dpnt_effective_date	in date,
	p_person_id		in number,
	p_effective_date	in date,
	p_sex			in varchar2,
	p_dpnts			out nocopy t_dpnts)
is
	c_proc			constant varchar2(61) := c_package || 'get_dpnts';
	l_index			number := 0;
	l_dpnt_rec		per_jp_ctr_utility_pkg.t_itax_dpnt_rec;
	--
	cursor csr_dep is
		select	/*+ ORDERED USE_NL(PER) */
			per.last_name		LAST_NAME_KANA,
			per.per_information18	LAST_NAME_KANJI,
			per.first_name		FIRST_NAME_KANA,
			per.per_information19	FIRST_NAME_KANJI,
			per.date_of_birth,
			decode(ctr.contact_type, 'S', decode(p_sex, 'F', g_prompt_kanji.husband, g_prompt_kanji.wife),
				hr_general.decode_lookup('CONTACT', ctr.contact_type))						D_CONTACT_TYPE_KANJI,
			decode(ctr.contact_type, 'S', decode(p_sex, 'F', g_prompt_kana.husband, g_prompt_kana.wife),
				hr_jp_standard_pkg.to_hankaku(hr_general.decode_lookup('JP_CONTACT_KANA', ctr.contact_type)))	D_CONTACT_TYPE_KANA
		from	per_contact_relationships	ctr,
			per_all_people_f		per
		where	ctr.person_id = p_person_id
		and	ctr.dependent_flag = 'Y'
		and	p_effective_date
			between nvl(ctr.date_start, p_effective_date) and nvl(ctr.date_end, p_effective_date)
		and	per.person_id = ctr.contact_person_id
		and	(	p_effective_date
				between per.effective_start_date and per.effective_end_date
			or	(
					per.effective_start_date = per.start_date
				and	not exists(
						select	null
						from	per_all_people_f	per2
						where	per2.person_id = per.person_id
						and	p_effective_date
							between per2.effective_start_date and per2.effective_end_date)
				)
			)
		order by
			decode(ctr.contact_type, 'S', 1, 2),
			per.date_of_birth,
			decode(per.sex, 'M', 1, 'F', 2, 3),
			per.last_name,
			per.first_name;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if p_itax_category in ('M_KOU', 'M_OTSU', 'D_KOU', 'D_OTSU') then
		hr_utility.set_location(c_proc, 20);
		--
		if p_dpnt_ref_type like 'CEI%' then
			hr_utility.set_location(c_proc, 21);
			--
			-- No need to care for performance issue for multiple calls of the following PL/SQL function.
			-- The following function caches the output variable result for the same input parameter values.
			--
			per_jp_ctr_utility_pkg.get_itax_dpnt_info(
				p_assignment_id		=> p_assignment_id,
				p_itax_type		=> p_itax_category,
				p_effective_date	=> p_dpnt_effective_date,
				p_itax_dpnt_rec		=> l_dpnt_rec);
			--
			for i in 1..l_dpnt_rec.contact_type_tbl.count loop
				l_index := l_index + 1;
				--
				p_dpnts(l_index).contact_type_kanji	:= l_dpnt_rec.d_contact_type_kanji_tbl(i);
				p_dpnts(l_index).contact_type_kana	:= l_dpnt_rec.d_contact_type_kana_tbl(i);
				p_dpnts(l_index).last_name_kanji	:= l_dpnt_rec.last_name_kanji_tbl(i);
				p_dpnts(l_index).last_name_kana		:= l_dpnt_rec.last_name_kana_tbl(i);
				p_dpnts(l_index).first_name_kanji	:= l_dpnt_rec.first_name_kanji_tbl(i);
				p_dpnts(l_index).first_name_kana	:= l_dpnt_rec.first_name_kana_tbl(i);
			end loop;
		else
			hr_utility.set_location(c_proc, 22);
			--
			for l_rec in csr_dep loop
				l_index := l_index + 1;
				--
				p_dpnts(l_index).contact_type_kanji	:= l_rec.d_contact_type_kanji;
				p_dpnts(l_index).contact_type_kana	:= l_rec.d_contact_type_kana;
				p_dpnts(l_index).last_name_kanji	:= l_rec.last_name_kanji;
				p_dpnts(l_index).last_name_kana		:= l_rec.last_name_kana;
				p_dpnts(l_index).first_name_kanji	:= l_rec.first_name_kanji;
				p_dpnts(l_index).first_name_kana	:= l_rec.first_name_kana;
			end loop;
		end if;
	end if;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end get_dpnts;
--
-- ----------------------------------------------------------------------------
-- get_housing_tbl
-- ----------------------------------------------------------------------------
--
procedure get_housing_tbl(
  p_assignment_id in number,
  p_date_earned in date,
  p_housing_tbl out nocopy t_housing_tbl)
is
--
  c_proc constant varchar2(61) := c_package||'get_housing';
--
  l_cnt number := 0;
--
  cursor csr_housing
  is
  select /*+ ORDERED
             USE_NL(PIV_1, PIV_3, PLIV_1, PLIV_2, PLIV_3, PEE, PEEV_1, PEEV_2, PEEV_3)
             INDEX(PIV_1 PAY_INPUT_VALUES_F_PK)
             INDEX(PIV_3 PAY_INPUT_VALUES_F_PK)
             INDEX(PLIV_1 PAY_LINK_INPUT_VALUES_F_N2)
             INDEX(PLIV_2 PAY_LINK_INPUT_VALUES_F_N2)
             INDEX(PLIV_3 PAY_LINK_INPUT_VALUES_F_N2)
             INDEX(PEE PAY_ELEMENT_ENTRIES_F_N51)
             INDEX(PEEV_1 PAY_ELEMENT_ENTRY_VALUES_F_N50)
             INDEX(PEEV_2 PAY_ELEMENT_ENTRY_VALUES_F_N50)
             INDEX(PEEV_3 PAY_ELEMENT_ENTRY_VALUES_F_N50) */
         decode(piv_1.uom,'D',fnd_date.canonical_to_date(peev_1.screen_entry_value),null) residence_date,
         peev_2.screen_entry_value loan_type,
         decode(piv_3.uom,'M',fnd_number.canonical_to_number(peev_3.screen_entry_value),null) loan_balance
  from   pay_input_values_f piv_1,
         pay_input_values_f piv_3,
         pay_link_input_values_f pliv_1,
         pay_link_input_values_f pliv_2,
         pay_link_input_values_f pliv_3,
         pay_element_entries_f pee,
         pay_element_entry_values_f peev_1,
         pay_element_entry_values_f peev_2,
         pay_element_entry_values_f peev_3
  where  piv_1.input_value_id = g_housing_loan_info_elm.res_date_iv
  and    p_date_earned
         between piv_1.effective_start_date and piv_1.effective_end_date
  and    piv_3.input_value_id = g_housing_loan_info_elm.loan_balance_iv
  and    p_date_earned
         between piv_3.effective_start_date and piv_3.effective_end_date
  and    pliv_1.input_value_id = piv_1.input_value_id
  and    p_date_earned
         between pliv_1.effective_start_date and pliv_1.effective_end_date
  and    pliv_2.input_value_id = g_housing_loan_info_elm.loan_type_iv
  and    p_date_earned
         between pliv_2.effective_start_date and pliv_2.effective_end_date
  and    pliv_3.input_value_id = piv_3.input_value_id
  and    p_date_earned
         between pliv_3.effective_start_date and pliv_3.effective_end_date
  and    pee.element_link_id = pliv_1.element_link_id
  and    pee.element_link_id = pliv_2.element_link_id
  and    pee.element_link_id = pliv_3.element_link_id
  and    pee.assignment_id = p_assignment_id
  and    pee.entry_type = 'E'
  and    p_date_earned
         between pee.effective_start_date and pee.effective_end_date
  and    peev_1.element_entry_id = pee.element_entry_id
  and    peev_1.input_value_id = pliv_1.input_value_id
  and    peev_1.effective_start_date = pee.effective_start_date
  and    peev_1.effective_end_date = pee.effective_end_date
  and    peev_2.element_entry_id = pee.element_entry_id
  and    peev_2.input_value_id = pliv_2.input_value_id
  and    peev_2.effective_start_date = pee.effective_start_date
  and    peev_2.effective_end_date = pee.effective_end_date
  and    peev_3.element_entry_id = pee.element_entry_id
  and    peev_3.input_value_id = pliv_3.input_value_id
  and    peev_3.effective_start_date = pee.effective_start_date
  and    peev_3.effective_end_date = pee.effective_end_date
  order by 1, 2;
--
  l_csr_housing csr_housing%rowtype;
--
begin
--
  hr_utility.set_location('Entering: '||c_proc,10);
--
  open csr_housing;
  loop
  --
    fetch csr_housing into l_csr_housing;
    exit when csr_housing%notfound;
  --
    l_cnt := l_cnt + 1;
  --
    p_housing_tbl(l_cnt).residence_date := l_csr_housing.residence_date;
    p_housing_tbl(l_cnt).loan_type      := l_csr_housing.loan_type;
    p_housing_tbl(l_cnt).loan_balance   := l_csr_housing.loan_balance;
  --
  end loop;
  close csr_housing;
--
  hr_utility.set_location('Leaving: '||c_proc,100);
--
end get_housing_tbl;
--
-- |-------------------------------------------------------------------|
-- |----------------------< get_ee_description >-----------------------|
-- |-------------------------------------------------------------------|
procedure get_ee_description(
	p_assignment_id		in number,
	p_business_group_id	in number,
	p_effective_date	in date,
	p_itw_override_flag	out nocopy varchar2,
	p_itw_description1	out nocopy varchar2,
	p_itw_description2	out nocopy varchar2,
	p_itw_description3	out nocopy varchar2,
	p_itw_description4	out nocopy varchar2,
	p_itw_description5	out nocopy varchar2,
	p_wtm_override_flag	out nocopy varchar2,
	p_wtm_description1	out nocopy varchar2,
	p_wtm_description2	out nocopy varchar2,
	p_wtm_description3	out nocopy varchar2,
	p_wtm_description4	out nocopy varchar2,
	p_wtm_description5	out nocopy varchar2)
is
	c_proc		constant varchar2(61) := c_package || 'get_ee_description';
	--
	cursor csr_eev is
		select	/*+ ORDERD USE_NL(PEE PEEV PIV) */
			nvl(min(decode(piv.display_sequence, 1, peev.screen_entry_value)), 'N')	itw_override_flag,
			min(decode(piv.display_sequence, 2, peev.screen_entry_value))		itw_description1,
			min(decode(piv.display_sequence, 3, peev.screen_entry_value))		itw_description2,
			min(decode(piv.display_sequence, 4, peev.screen_entry_value))		itw_description3,
			min(decode(piv.display_sequence, 5, peev.screen_entry_value))		itw_description4,
			min(decode(piv.display_sequence, 6, peev.screen_entry_value))		itw_description5,
			nvl(min(decode(piv.display_sequence, 7, peev.screen_entry_value)), 'N')	wtm_override_flag,
			min(decode(piv.display_sequence, 8, peev.screen_entry_value))		wtm_description1,
			min(decode(piv.display_sequence, 9, peev.screen_entry_value))		wtm_description2,
			min(decode(piv.display_sequence, 10, peev.screen_entry_value))		wtm_description3,
			min(decode(piv.display_sequence, 11, peev.screen_entry_value))		wtm_description4,
			min(decode(piv.display_sequence, 12, peev.screen_entry_value))		wtm_description5
		from	pay_element_links_f		pel,
			pay_element_entries_f		pee,
			pay_element_entry_values_f	peev,
			pay_input_values_f		piv
		where	pel.element_type_id = g_desc_element_type_id
		and	pel.business_group_id = p_business_group_id
		and	p_effective_date
			between pel.effective_start_date and pel.effective_end_date
		and	pee.assignment_id = p_assignment_id
		and	pee.element_link_id = pel.element_link_id
		and	pee.entry_type = 'E'
		and	p_effective_date
			between pee.effective_start_date and pee.effective_end_date
		and	peev.element_entry_id = pee.element_entry_id
		and	peev.effective_start_date = pee.effective_start_date
		and	peev.effective_end_date = pee.effective_end_date
		and	piv.input_value_id = peev.input_value_id
		and	p_effective_date
			between piv.effective_start_date and piv.effective_end_date
		group by pee.element_entry_id;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	open csr_eev;
	fetch csr_eev into
		p_itw_override_flag,
		p_itw_description1,
		p_itw_description2,
		p_itw_description3,
		p_itw_description4,
		p_itw_description5,
		p_wtm_override_flag,
		p_wtm_description1,
		p_wtm_description2,
		p_wtm_description3,
		p_wtm_description4,
		p_wtm_description5;
	if csr_eev%notfound then
		hr_utility.trace('EE not found.');
		--
		p_itw_override_flag	:= 'N';
		p_itw_description1	:= null;
		p_itw_description2	:= null;
		p_itw_description3	:= null;
		p_itw_description4	:= null;
		p_itw_description5	:= null;
		p_wtm_override_flag	:= 'N';
		p_wtm_description1	:= null;
		p_wtm_description2	:= null;
		p_wtm_description3	:= null;
		p_wtm_description4	:= null;
		p_wtm_description5	:= null;
	end if;
	close csr_eev;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end get_ee_description;
--
-- called from gci_b, gci_itw_arc
--
procedure get_ee_description(
	p_assignment_id		in number,
	p_business_group_id	in number,
	p_effective_date	in date,
	p_itw_override_flag	out nocopy varchar2,
	p_itw_description	out nocopy varchar2,
	p_wtm_override_flag	out nocopy varchar2,
	p_wtm_description	out nocopy varchar2)
is
	l_itw_description1	pay_element_entry_values.screen_entry_value%type;
	l_itw_description2	pay_element_entry_values.screen_entry_value%type;
	l_itw_description3	pay_element_entry_values.screen_entry_value%type;
	l_itw_description4	pay_element_entry_values.screen_entry_value%type;
	l_itw_description5	pay_element_entry_values.screen_entry_value%type;
	l_wtm_description1	pay_element_entry_values.screen_entry_value%type;
	l_wtm_description2	pay_element_entry_values.screen_entry_value%type;
	l_wtm_description3	pay_element_entry_values.screen_entry_value%type;
	l_wtm_description4	pay_element_entry_values.screen_entry_value%type;
	l_wtm_description5	pay_element_entry_values.screen_entry_value%type;
begin
	get_ee_description(
		p_assignment_id		=> p_assignment_id,
		p_business_group_id	=> p_business_group_id,
		p_effective_date	=> p_effective_date,
		p_itw_override_flag	=> p_itw_override_flag,
		p_itw_description1	=> l_itw_description1,
		p_itw_description2	=> l_itw_description2,
		p_itw_description3	=> l_itw_description3,
		p_itw_description4	=> l_itw_description4,
		p_itw_description5	=> l_itw_description5,
		p_wtm_override_flag	=> p_wtm_override_flag,
		p_wtm_description1	=> l_wtm_description1,
		p_wtm_description2	=> l_wtm_description2,
		p_wtm_description3	=> l_wtm_description3,
		p_wtm_description4	=> l_wtm_description4,
		p_wtm_description5	=> l_wtm_description5);
	--
	p_itw_description := l_itw_description1
			  || l_itw_description2
			  || l_itw_description3
			  || l_itw_description4
			  || l_itw_description5;
	p_wtm_description := l_wtm_description1
			  || l_wtm_description2
			  || l_wtm_description3
			  || l_wtm_description4
			  || l_wtm_description5;
end get_ee_description;
-- |-------------------------------------------------------------------|
-- |------------------------< add_description >------------------------|
-- |-------------------------------------------------------------------|
procedure add_description(
	p_description_type	in varchar2,
	p_description_kanji	in varchar2,
	p_description_kana	in varchar2 default null,
	p_descriptions		in out nocopy t_descriptions)
is
	l_index		number;
begin
	l_index := p_descriptions.count + 1;
	--
	-- PAYJPITW outputs mixed Kanji/Kana characters
	-- into description field, so do not use
	-- hr_jp_standard_pkg.to_zenkaku.
	-- Use hr_jp_standard_pkg.to_zenkaku just before
	-- outputting those in reports, e.g. PAYJPWTM.
	--
	p_descriptions(l_index).description_type	:= p_description_type;
	p_descriptions(l_index).description_kanji	:= p_description_kanji;
--	p_descriptions(l_index).description_kana	:= hr_jp_standard_pkg.upper_kana(
--								hr_jp_standard_pkg.to_hankaku(p_description_kana, '?'));
	p_descriptions(l_index).description_kana	:= hr_jp_standard_pkg.to_hankaku(p_description_kana, '?');
end add_description;
-- |-------------------------------------------------------------------|
-- |-----------------------< get_descriptions >------------------------|
-- |-------------------------------------------------------------------|
procedure get_descriptions(
  p_assignment_id     in number,
  p_person_id         in number,
  p_effective_date    in date,
  p_itax_yea_category in varchar2,
  p_certificate_info  in t_certificate_info,
  p_last_name_kanji   in varchar2,
  p_last_name_kana    in varchar2,
  p_dpnts             in t_dpnts,
  p_prev_jobs         in t_prev_jobs,
  p_housing_tbl       in t_housing_tbl,
  p_report_type       in varchar2, --> ITW/WTM
  p_descriptions      out nocopy t_descriptions)
is
--
  c_proc      constant varchar2(61) := c_package || 'get_descriptions';
--
  l_description_kanji varchar2(32767);
  l_description_kana  varchar2(32767);
  l_separator         varchar2(1);
--
  procedure add_desc(
    p_description_type in varchar2,
    p_prefix_kanji     in varchar2,
    p_prefix_kana      in varchar2,
    p_amount           in number,
    p_min_length_kanji in number,
    p_min_length_kana  in number)
  is
  --
    l_description_kanji varchar2(32767);
    l_description_kana  varchar2(32767);
    l_length            number;
  --
  begin
  --
    l_description_kanji := to_char(p_amount);
    l_description_kana := l_description_kanji;
  --
    if p_min_length_kanji is not null or p_min_length_kana is not null then
    --
      l_length := nvl(length(l_description_kanji), 0);
    --
      if l_length < p_min_length_kanji then
      --
        l_description_kanji := lpad(
              nvl(l_description_kanji, ' '),
              p_min_length_kanji,
              ' ');
      --
      end if;
    --
      if l_length < p_min_length_kana then
      --
        l_description_kana := lpad(
              nvl(l_description_kana, ' '),
              p_min_length_kana,
              ' ');
      --
      end if;
    --
    end if;
  --
    l_description_kanji := p_prefix_kanji
            || l_description_kanji
            || g_prompt_kanji.yen;
  --
    l_description_kana := p_prefix_kana
           || l_description_kana
           || g_prompt_kana.yen;
  --
    add_description(
      p_description_type,
      l_description_kanji,
      l_description_kana,
      p_descriptions);
  --
  end add_desc;
--
  procedure add_fixed_rate_description(
    p_fixed_rate_tax_reduction in number,
    p_length_kanji             in number default null,
    p_length_kana              in number default null)
  is
  begin
  --
    add_desc(
      FIXED_RATE_TAX_REDUCTION,
      g_prompt_kanji.fixed_rate_tax_reduction,
      g_prompt_kana.fixed_rate_tax_reduction,
      p_fixed_rate_tax_reduction,
      p_length_kanji,
      p_length_kana);
  --
  end add_fixed_rate_description;
--
  procedure add_np_prem_description(
    p_np_prem      in number,
    p_length_kanji in number default null,
    p_length_kana  in number default null)
  is
  begin
  --
    add_desc(
      NP_PREM,
      g_prompt_kanji.national_pens_prem,
      g_prompt_kana.national_pens_prem,
      p_np_prem,
      p_length_kanji,
      p_length_kana);
  --
  end add_np_prem_description;
--
  -- following procedure are available since april in 2009
  procedure proc_housing_loan1
  is
  --
    l_loan_type_kanji varchar2(2000);
    l_loan_type_kana varchar2(2000);
    l_total_housing_loan number;
  --
  begin
  --
    if to_number(to_char(p_effective_date,'YYYY')) > 2009
    or (to_number(to_char(p_effective_date,'YYYY')) = 2009
       and to_number(to_char(p_effective_date,'MM')) >= 4) then
    --
      if p_report_type = 'ITW' then
      --
        l_total_housing_loan := p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct;
      --
        -- always prompt should be printed (in accordance with guidance of national tax agency)
        l_description_kanji := g_prompt_kanji.housing_loan_itw;
        l_description_kana  := g_prompt_kana.housing_loan_itw;
      --
        if p_itax_yea_category = '0'
        and l_total_housing_loan <> 0
        and p_certificate_info.unclaimed_housing_tax_reduct <> 0 then
        --
          l_description_kanji := l_description_kanji||to_char(l_total_housing_loan)||g_prompt_kanji.yen;
          l_description_kana  := l_description_kana||to_char(l_total_housing_loan)||g_prompt_kana.yen;
        --
        else
        --
          l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.yen;
          l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.yen;
        --
        end if;
      --
      -- following routine has been moved to proc_housing_loan2 to reorder sequence of item
      --
      --  -- always prompt should be printed (in accordance with guidance of national tax agency)
      --  l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.housing_res_date_itw;
      --  l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.housing_res_date_itw;
      --
      --  if p_itax_yea_category = '0'
      --  and l_total_housing_loan <> 0
      --  and p_housing_tbl.count <> 0 then
      --  --
      --    if p_housing_tbl.count = 1 then
      --    --
      --      l_description_kanji := l_description_kanji||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(1).residence_date,c_date_fmt_itw);
      --      l_description_kana  := l_description_kana||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(1).residence_date,c_date_fmt_itw);
      --    --
      --    end if;
      --  --
      --    if (p_housing_tbl.count > 1
      --    or (p_housing_tbl.count = 1 and p_housing_tbl(1).loan_type = '03')) then
      --    --
      --      for i in 1..p_housing_tbl.count loop
      --      --
      --        l_loan_type_kanji := null;
      --        l_loan_type_kana := null;
      --      --
      --        if i = 1 then
      --        --
      --        -- this skip in case loan_type = 03
      --        --
      --          if p_housing_tbl.count <> 1 then
      --          --
      --            l_description_kanji := l_description_kanji||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,c_date_fmt_itw);
      --            l_description_kana  := l_description_kana||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,c_date_fmt_itw);
      --          --
      --          end if;
      --        --
      --        else
      --        --
      --          l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.housing_res_date_itw||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,c_date_fmt_itw);
      --          l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.housing_res_date_itw||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,c_date_fmt_itw);
      --        --
      --        end if;
      --      --
      --      -- return multiple resident date only in case unclaimed reduciton = 0, type, balance are not required. (ie. payable_loan = total_housing_loan <> 0)
      --      --
      --        if p_certificate_info.unclaimed_housing_tax_reduct <> 0 then
      --        --
      --          l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.housing_loan_balance_itw;
      --          l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.housing_loan_balance_itw;
      --        --
      --          if p_housing_tbl(i).loan_type is not null then
      --          --
      --            if p_housing_tbl(i).loan_type in ('01','02') then
      --            --
      --              l_loan_type_kanji := g_prompt_kanji.housing_loan_type_gen_itw;
      --              l_loan_type_kana := g_prompt_kana.housing_loan_type_gen_itw;
      --            --
      --            elsif p_housing_tbl(i).loan_type = '03' then
      --            --
      --              l_loan_type_kanji := g_prompt_kanji.housing_loan_type_ext_itw;
      --              l_loan_type_kana := g_prompt_kana.housing_loan_type_ext_itw;
      --            --
      --            elsif p_housing_tbl(i).loan_type = '04' then
      --            --
      --              l_loan_type_kanji := g_prompt_kanji.housing_loan_type_etq_itw;
      --              l_loan_type_kana := g_prompt_kana.housing_loan_type_etq_itw;
      --            --
      --            end if;
      --          --
      --            l_description_kanji := l_description_kanji||c_space_separator||l_loan_type_kanji;
      --            l_description_kana  := l_description_kana||c_space_separator||l_loan_type_kana;
      --          --
      --          end if;
      --        --
      --          if p_housing_tbl(i).loan_balance is not null then
      --          --
      --            l_description_kanji := l_description_kanji||c_space_separator||to_char(p_housing_tbl(i).loan_balance)||g_prompt_kanji.yen;
      --            l_description_kana  := l_description_kana||c_space_separator||to_char(p_housing_tbl(i).loan_balance)||g_prompt_kana.yen;
      --          --
      --          else
      --          --
      --            l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.yen;
      --            l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.yen;
      --          --
      --          end if;
      --        --
      --        end if;
      --      --
      --      end loop;
      --    --
      --    end if;
      --  --
      --  end if;
      --
        add_description(
          HOUSING_TAX_REDUCTION,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      elsif p_report_type = 'WTM' then
      --
      -- p_housing_tbl exists in case when p_itax_yea_category = '0' and total_housing_loan <> 0
      --
        if p_housing_tbl.count > 2 then
        --
          for i in 3..p_housing_tbl.count loop
          --
            l_description_kanji :=
              g_prompt_kanji.housing_loan_type_wtm||c_bracket_left||to_char(i)||g_prompt_kanji.housing_count_wtm||c_bracket_right||
              p_housing_tbl(i).loan_type||c_space_separator||
              g_prompt_kanji.housing_res_date_wtm||c_bracket_left||to_char(i)||g_prompt_kanji.housing_count_wtm||c_bracket_right||
              hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,g_prompt_kanji.date_format)||c_space_separator||
              g_prompt_kanji.housing_loan_balance_wtm||c_bracket_left||to_char(i)||g_prompt_kanji.housing_count_wtm||c_bracket_right||
              to_char(p_housing_tbl(i).loan_balance)||g_prompt_kanji.yen;
            l_description_kana :=
              g_prompt_kana.housing_loan_type_wtm||c_bracket_left||to_char(i)||g_prompt_kana.housing_count_wtm||c_bracket_right||
              p_housing_tbl(i).loan_type||c_space_separator||
              g_prompt_kana.housing_res_date_wtm||c_bracket_left||to_char(i)||g_prompt_kana.housing_count_wtm||c_bracket_right||
              hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,g_prompt_kana.date_format)||c_space_separator||
              g_prompt_kana.housing_loan_balance_wtm||c_bracket_left||to_char(i)||g_prompt_kana.housing_count_wtm||c_bracket_right||
              to_char(p_housing_tbl(i).loan_balance)||g_prompt_kana.yen;
          --
            add_description(
              HOUSING_TAX_REDUCTION,
              l_description_kanji,
              l_description_kana,
              p_descriptions);
          --
          end loop;
        --
        end if;
      --
      end if;
    --
    -- data source between jan and mar is different from source since april
    -- but it should be compliant with 2009 format
    --
    elsif (to_number(to_char(p_effective_date,'YYYY')) = 2009
          and to_number(to_char(p_effective_date,'MM')) < 4) then
    --
    -- no action for WTM because it should work for p_housing_tbl.count > 2
    --
      if p_report_type = 'ITW' then
      --
        l_total_housing_loan := p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct;
      --
        -- always prompt should be printed (in accordance with guidance of national tax agency)
        l_description_kanji := g_prompt_kanji.housing_loan_itw;
        l_description_kana  := g_prompt_kana.housing_loan_itw;
      --
        if p_itax_yea_category = '0'
        and l_total_housing_loan <> 0
        and p_certificate_info.unclaimed_housing_tax_reduct <> 0 then
        --
          l_description_kanji := l_description_kanji||to_char(l_total_housing_loan)||g_prompt_kanji.yen;
          l_description_kana  := l_description_kana||to_char(l_total_housing_loan)||g_prompt_kana.yen;
        --
        else
        --
          l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.yen;
          l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.yen;
        --
        end if;
      --
      -- following routine has been moved to proc_housing_loan2 to reorder sequence of item
      --
      --  -- always prompt should be printed (in accordance with guidance of national tax agency)
      --  l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.housing_res_date_itw;
      --  l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.housing_res_date_itw;
      ----
      --  if p_itax_yea_category = '0'
      --  and l_total_housing_loan <> 0 then
      --  --
      --    l_description_kanji := l_description_kanji||hr_jp_standard_pkg.to_jp_char(p_certificate_info.housing_residence_date,c_date_fmt_itw);
      --    l_description_kana  := l_description_kana||hr_jp_standard_pkg.to_jp_char(p_certificate_info.housing_residence_date,c_date_fmt_itw);
      --  --
      --  end if;
      --
        add_description(
          HOUSING_TAX_REDUCTION,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      end if;
    --
    end if;
  --
  end proc_housing_loan1;
--
  -- this is required to list as order payable loan, national pension, housing info by tax agency guide
  procedure proc_housing_loan2
  is
  --
    l_loan_type_kanji varchar2(2000);
    l_loan_type_kana varchar2(2000);
    l_total_housing_loan number;
  --
  begin
  --
    if to_number(to_char(p_effective_date,'YYYY')) > 2009
    or (to_number(to_char(p_effective_date,'YYYY')) = 2009
       and to_number(to_char(p_effective_date,'MM')) >= 4) then
    --
      if p_report_type = 'ITW' then
      --
        l_total_housing_loan := p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct;
      --
      -- following routine has been moved to proc_housing_loan1 to reorder sequence of item
      --
      --  -- always prompt should be printed (in accordance with guidance of national tax agency)
      --  l_description_kanji := g_prompt_kanji.housing_loan_itw;
      --  l_description_kana  := g_prompt_kana.housing_loan_itw;
      ----
      --  if p_itax_yea_category = '0'
      --  and l_total_housing_loan <> 0
      --  and p_certificate_info.unclaimed_housing_tax_reduct <> 0 then
      --  --
      --    l_description_kanji := l_description_kanji||to_char(l_total_housing_loan)||g_prompt_kanji.yen;
      --    l_description_kana  := l_description_kana||to_char(l_total_housing_loan)||g_prompt_kana.yen;
      --  --
      --  else
      --  --
      --    l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.yen;
      --    l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.yen;
      --  --
      --  end if;
      --
      --  -- always prompt should be printed (in accordance with guidance of national tax agency)
      --  l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.housing_res_date_itw;
      --  l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.housing_res_date_itw;
        l_description_kanji := g_prompt_kanji.housing_res_date_itw;
        l_description_kana  := g_prompt_kana.housing_res_date_itw;
      --
        if p_itax_yea_category = '0'
        and l_total_housing_loan <> 0
        and p_housing_tbl.count <> 0 then
        --
          if p_housing_tbl.count = 1 then
          --
            l_description_kanji := l_description_kanji||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(1).residence_date,c_date_fmt_itw);
            l_description_kana  := l_description_kana||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(1).residence_date,c_date_fmt_itw);
          --
          end if;
       --
          if (p_housing_tbl.count > 1
          or (p_housing_tbl.count = 1 and p_housing_tbl(1).loan_type = '03')) then
          --
            for i in 1..p_housing_tbl.count loop
            --
              l_loan_type_kanji := null;
              l_loan_type_kana := null;
            --
              if i = 1 then
              --
              -- this skip in case loan_type = 03
              --
                if p_housing_tbl.count <> 1 then
                --
                  l_description_kanji := l_description_kanji||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,c_date_fmt_itw);
                  l_description_kana  := l_description_kana||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,c_date_fmt_itw);
                --
                end if;
              --
              else
              --
                l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.housing_res_date_itw||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,c_date_fmt_itw);
                l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.housing_res_date_itw||hr_jp_standard_pkg.to_jp_char(p_housing_tbl(i).residence_date,c_date_fmt_itw);
              --
              end if;
            --
            -- return multiple resident date only in case unclaimed reduciton = 0, type, balance are not required. (ie. payable_loan = total_housing_loan <> 0)
            --
              if p_certificate_info.unclaimed_housing_tax_reduct <> 0 then
              --
                l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.housing_loan_balance_itw;
                l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.housing_loan_balance_itw;
              --
                if p_housing_tbl(i).loan_type is not null then
                --
                  if p_housing_tbl(i).loan_type in ('01','02') then
                  --
                    l_loan_type_kanji := g_prompt_kanji.housing_loan_type_gen_itw;
                    l_loan_type_kana := g_prompt_kana.housing_loan_type_gen_itw;
                  --
                  elsif p_housing_tbl(i).loan_type = '03' then
                  --
                    l_loan_type_kanji := g_prompt_kanji.housing_loan_type_ext_itw;
                    l_loan_type_kana := g_prompt_kana.housing_loan_type_ext_itw;
                  --
                  elsif p_housing_tbl(i).loan_type = '04' then
                  --
                    l_loan_type_kanji := g_prompt_kanji.housing_loan_type_etq_itw;
                    l_loan_type_kana := g_prompt_kana.housing_loan_type_etq_itw;
                  --
                  end if;
                --
                  l_description_kanji := l_description_kanji||c_space_separator||l_loan_type_kanji;
                  l_description_kana  := l_description_kana||c_space_separator||l_loan_type_kana;
                --
                end if;
              --
                if p_housing_tbl(i).loan_balance is not null then
                --
                  l_description_kanji := l_description_kanji||c_space_separator||to_char(p_housing_tbl(i).loan_balance)||g_prompt_kanji.yen;
                  l_description_kana  := l_description_kana||c_space_separator||to_char(p_housing_tbl(i).loan_balance)||g_prompt_kana.yen;
                --
                else
                --
                  l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.yen;
                  l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.yen;
                --
                end if;
              --
              end if;
            --
            end loop;
          --
          end if;
        --
        end if;
      --
        add_description(
          HOUSING_LOAN_INFO,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      end if;
    --
    -- data source between jan and mar is different from source since april
    -- but it should be compliant with 2009 format
    --
    elsif (to_number(to_char(p_effective_date,'YYYY')) = 2009
          and to_number(to_char(p_effective_date,'MM')) < 4) then
    --
      if p_report_type = 'ITW' then
      --
        l_total_housing_loan := p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct;
      --
      -- following routine has been moved to proc_housing_loan1 to reorder sequence of item
      --
      --  -- always prompt should be printed (in accordance with guidance of national tax agency)
      --  l_description_kanji := g_prompt_kanji.housing_loan_itw;
      --  l_description_kana  := g_prompt_kana.housing_loan_itw;
      ----
      --  if p_itax_yea_category = '0'
      --  and l_total_housing_loan <> 0
      --  and p_certificate_info.unclaimed_housing_tax_reduct <> 0 then
      --  --
      --    l_description_kanji := l_description_kanji||to_char(l_total_housing_loan)||g_prompt_kanji.yen;
      --    l_description_kana  := l_description_kana||to_char(l_total_housing_loan)||g_prompt_kana.yen;
      --  --
      --  else
      --  --
      --    l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.yen;
      --    l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.yen;
      --  --
      --  end if;
      --
      --  -- always prompt should be printed (in accordance with guidance of national tax agency)
      --  l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.housing_res_date_itw;
      --  l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.housing_res_date_itw;
        l_description_kanji := g_prompt_kanji.housing_res_date_itw;
        l_description_kana  := g_prompt_kana.housing_res_date_itw;
      --
        if p_itax_yea_category = '0'
        and l_total_housing_loan <> 0 then
        --
          l_description_kanji := l_description_kanji||hr_jp_standard_pkg.to_jp_char(p_certificate_info.housing_residence_date,c_date_fmt_itw);
          l_description_kana  := l_description_kana||hr_jp_standard_pkg.to_jp_char(p_certificate_info.housing_residence_date,c_date_fmt_itw);
        --
        end if;
      --
        add_description(
          HOUSING_LOAN_INFO,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      end if;
    --
    end if;
  --
  end proc_housing_loan2;
--
  procedure proc_np_prem
  is
  begin
  --
    if p_report_type = 'ITW' then
    --
      -- always prompt should be printed (in accordance with guidance of national tax agency)
      l_description_kanji := g_prompt_kanji.np_prem_itw;
      l_description_kana  := g_prompt_kana.np_prem_itw;
    --
      if p_itax_yea_category = '0'
      and p_certificate_info.national_pens_prem <> 0 then
      --
        l_description_kanji := l_description_kanji||to_char(p_certificate_info.national_pens_prem)||g_prompt_kanji.yen;
        l_description_kana  := l_description_kana||to_char(p_certificate_info.national_pens_prem)||g_prompt_kana.yen;
      --
      else
      --
        l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.yen;
        l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.yen;
      --
      end if;
    --
      -- use NP_PREM_CONC to concatenate with other description, rather than using line1
      add_description(
        NP_PREM_CONC,
        l_description_kanji,
        l_description_kana,
        p_descriptions);
    --
    else
    --
      -- take same behavior with previous
      if p_itax_yea_category = '0' then
      --
        -- use NP_PREM_CONC to concatenate with other description, rather than using line1
        add_desc(
          NP_PREM_CONC,
          g_prompt_kanji.national_pens_prem,
          g_prompt_kana.national_pens_prem,
          p_certificate_info.national_pens_prem,
          null,
          null);
      --
      end if;
    --
    end if;
  --
  end proc_np_prem;
--
  procedure proc_prev_job
  is
  begin
  --
    if p_itax_yea_category = '0' then
    --
      for i in 1..p_prev_jobs.count loop
      --
      -- salary
      --
        l_description_kanji := g_prompt_kanji.prev_job||g_prompt_kanji.taxable_income||to_char(p_prev_jobs(i).taxable_income)||g_prompt_kanji.yen;
        l_description_kana  := g_prompt_kana.prev_job||g_prompt_kana.taxable_income||to_char(p_prev_jobs(i).taxable_income)||g_prompt_kana.yen;
      --
      -- social insurance premium
      --
        l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.si_prem||to_char(p_prev_jobs(i).si_prem)||g_prompt_kanji.yen;
        l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.si_prem||to_char(p_prev_jobs(i).si_prem)||g_prompt_kana.yen;
      --
      -- small-enterprise mutual aid premium
      --
        if p_prev_jobs(i).mutual_aid_prem <> 0 then
        --
          l_description_kanji := l_description_kanji||'('||g_prompt_kanji.mutual_aid_prem||to_char(p_prev_jobs(i).mutual_aid_prem)||g_prompt_kanji.yen||')';
          l_description_kana  := l_description_kana||'('||g_prompt_kana.mutual_aid_prem||to_char(p_prev_jobs(i).mutual_aid_prem)||g_prompt_kana.yen||')';
        --
        end if;
      --
      -- income tax
      --
        l_description_kanji := l_description_kanji||c_space_separator||g_prompt_kanji.itax||to_char(p_prev_jobs(i).itax)||g_prompt_kanji.yen;
        l_description_kana  := l_description_kana||c_space_separator||g_prompt_kana.itax||to_char(p_prev_jobs(i).itax)||g_prompt_kana.yen;
      --
      -- salary payer address
      --
        if p_prev_jobs(i).salary_payer_address_kanji is not null then
        --
          l_description_kanji := l_description_kanji||c_space_separator||p_prev_jobs(i).salary_payer_address_kanji;
        --
        end if;
        --
        if p_prev_jobs(i).salary_payer_address_kana is not null then
        --
          l_description_kana  := l_description_kana||c_space_separator||p_prev_jobs(i).salary_payer_address_kana;
        --
        end if;
      --
      -- salary payer name
      --
        if p_prev_jobs(i).salary_payer_name_kanji is not null then
        --
          l_description_kanji := l_description_kanji||c_space_separator||p_prev_jobs(i).salary_payer_name_kanji;
        --
        end if;
      --
        if p_prev_jobs(i).salary_payer_name_kana is not null then
        --
          l_description_kana  := l_description_kana||c_space_separator||p_prev_jobs(i).salary_payer_name_kana;
        --
        end if;
      --
      -- termination date
      -- Now to_char(''Japanese Imperial'') does not work in PL/SQL.
      -- Here uses to_char of ORACLE as a workaround.
      --
        if p_prev_jobs(i).termination_date is not null then
        --
          l_description_kanji := l_description_kanji||c_space_separator||hr_jp_standard_pkg.to_jp_char(p_prev_jobs(i).termination_date,g_prompt_kanji.date_format)||g_prompt_kanji.terminated;
          l_description_kana  := l_description_kana||c_space_separator||hr_jp_standard_pkg.to_jp_char(p_prev_jobs(i).termination_date,g_prompt_kana.date_format)||g_prompt_kana.terminated;
        --
        end if;
      --
        add_description(
          PREV_JOB,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      end loop;
    --
    end if;
  --
  end proc_prev_job;
--
  procedure proc_dependent
  is
  begin
  --
    --
    -- dependent
    --
    -- Omit last_name when different as follows.
    -- 1) null/null -> omit last_name
    -- 2) null/B    -> omit last_name
    -- 3) A/null    -> omit last_name
    -- 4) A/A       -> omit last_name
    -- 5) A/B       -> Never omit last_name
    --
    for i in 1..p_dpnts.count loop
    --
      if (p_dpnts(i).last_name_kana <> p_last_name_kana)
      or (p_dpnts(i).last_name_kanji <> p_last_name_kanji) then
      --
        l_description_kanji := p_dpnts(i).contact_type_kanji||c_space_separator||p_dpnts(i).last_name_kanji||p_dpnts(i).first_name_kanji;
        l_description_kana  := p_dpnts(i).contact_type_kana||c_space_separator||p_dpnts(i).last_name_kana||p_dpnts(i).first_name_kana;
      --
      else
      --
        l_description_kanji := p_dpnts(i).contact_type_kanji||c_space_separator||p_dpnts(i).first_name_kanji;
        l_description_kana  := p_dpnts(i).contact_type_kana||c_space_separator||p_dpnts(i).first_name_kana;
      --
      end if;
    --
      add_description(
        DEPENDENT,
        l_description_kanji,
        l_description_kana,
        p_descriptions);
    --
    end loop;
  --
  end proc_dependent;
--
  procedure proc_disaster
  is
  begin
  --
    if p_itax_yea_category <> '0' then
    --
    -- disaster tax reduction
    --
      if p_certificate_info.tax_info.disaster_tax_reduction <> 0 then
      --
        l_description_kanji := g_prompt_kanji.disaster_tax_reduction||to_char(p_certificate_info.tax_info.disaster_tax_reduction)||g_prompt_kanji.yen;
        l_description_kana  := g_prompt_kana.disaster_tax_reduction||to_char(p_certificate_info.tax_info.disaster_tax_reduction)||g_prompt_kana.yen;
      --
        add_description(
          DISASTER_TAX_REDUCTION,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      end if;
    --
    end if;
  --
  end proc_disaster;
--
begin
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  if to_number(to_char(p_effective_date,'YYYY')) >= 2009 then
  --
    hr_utility.set_location(c_proc, 1009);
  --
    proc_housing_loan1;
  --
    hr_utility.set_location(c_proc, 2009);
  --
    proc_np_prem;
  --
    hr_utility.set_location(c_proc, 3009);
  --
    proc_housing_loan2;
  --
    hr_utility.set_location(c_proc, 4009);
  --
    proc_prev_job;
  --
    hr_utility.set_location(c_proc, 5009);
  --
    proc_dependent;
  --
    hr_utility.set_location(c_proc, 6009);
  --
    proc_disaster;
  --
  -- basically, pass following routine only before 2009, so not maintain since 2010
  else
  --
    hr_utility.set_location(c_proc, 1000);
  --
    -- ************************
    -- FIXED_RATE_TAX_REDUCTION
    -- NP_PREM
    -- ************************
    if p_itax_yea_category = '0' then
    --
      if p_report_type = ITW then
      --
        if to_number(to_char(p_effective_date, 'YYYY')) <= 2006 then
          add_fixed_rate_description(p_certificate_info.fixed_rate_tax_reduction, 6, 6);
        end if;
        --
        if to_number(to_char(p_effective_date, 'YYYY')) >= 2005 then
          add_np_prem_description(p_certificate_info.national_pens_prem, 4, 3);
        end if;
      --
      else
      --
        if to_number(to_char(p_effective_date, 'YYYY')) <= 2006 then
          add_fixed_rate_description(p_certificate_info.fixed_rate_tax_reduction);
        end if;
        --
        if to_number(to_char(p_effective_date, 'YYYY')) >= 2005 then
          add_np_prem_description(p_certificate_info.national_pens_prem);
        end if;
      --
      end if;
    --
    else
    --
      if p_report_type = ITW then
      --
        if to_number(to_char(p_effective_date, 'YYYY')) <= 2006 then
          add_fixed_rate_description(null, 6, 6);
        end if;
      --
        if to_number(to_char(p_effective_date, 'YYYY')) >= 2005 then
          add_np_prem_description(null, 4, 3);
        end if;
      --
      end if;
    --
    end if;
    --
    hr_utility.set_location(c_proc, 2000);
    --
    -- ************************
    -- DEPENDENT
    -- ************************
    -- Omit last_name when different as follows.
    -- 1) null/null -> omit last_name
    -- 2) null/B    -> omit last_name
    -- 3) A/null    -> omit last_name
    -- 4) A/A       -> omit last_name
    -- 5) A/B       -> Never omit last_name
    --
    for i in 1..p_dpnts.count loop
    --
      if (p_dpnts(i).last_name_kana <> p_last_name_kana)
      or (p_dpnts(i).last_name_kanji <> p_last_name_kanji) then
      --
        l_description_kanji := p_dpnts(i).contact_type_kanji ||
                 ' ' ||
                 p_dpnts(i).last_name_kanji ||
                 p_dpnts(i).first_name_kanji;
      --
        l_description_kana  := p_dpnts(i).contact_type_kana ||
                 ' ' ||
                 p_dpnts(i).last_name_kana ||
                 p_dpnts(i).first_name_kana;
      --
      else
      --
        l_description_kanji := p_dpnts(i).contact_type_kanji ||
                 ' ' ||
                 p_dpnts(i).first_name_kanji;
      --
        l_description_kana  := p_dpnts(i).contact_type_kana ||
                 ' ' ||
                 p_dpnts(i).first_name_kana;
      --
      end if;
    --
      add_description(
        DEPENDENT,
        l_description_kanji,
        l_description_kana,
        p_descriptions);
    --
    end loop;
    --
    hr_utility.set_location(c_proc, 3000);
    --
    -- The following information is available only for YEAed assact.
    --
    if p_itax_yea_category = '0' then
    --
      hr_utility.set_location(c_proc, 3100);
      --
      -- ************************
      -- PREV_JOB
      -- ************************
      for i in 1..p_prev_jobs.count loop
      --
      -- <Salary>
      --
        l_description_kanji := g_prompt_kanji.prev_job ||
                 g_prompt_kanji.taxable_income ||
                 to_char(p_prev_jobs(i).taxable_income) ||
                 g_prompt_kanji.yen;
      --
        l_description_kana  := g_prompt_kana.prev_job ||
                 g_prompt_kana.taxable_income ||
                 to_char(p_prev_jobs(i).taxable_income) ||
                 g_prompt_kana.yen;
      --
      -- <Social Insurance Premium>
      --
        l_description_kanji := l_description_kanji || ' ' ||
                 g_prompt_kanji.si_prem ||
                 to_char(p_prev_jobs(i).si_prem) ||
                 g_prompt_kanji.yen;
      --
        l_description_kana  := l_description_kana || ' ' ||
                 g_prompt_kana.si_prem ||
                 to_char(p_prev_jobs(i).si_prem) ||
                 g_prompt_kana.yen;
      --
      -- <Small-enterprise Mutual Aid Premium>
      --
        if p_prev_jobs(i).mutual_aid_prem <> 0 then
        --
          l_description_kanji := l_description_kanji || '(' ||
                   g_prompt_kanji.mutual_aid_prem ||
                   to_char(p_prev_jobs(i).mutual_aid_prem) ||
                   g_prompt_kanji.yen || ')';
        --
          l_description_kana  := l_description_kana || '(' ||
                   g_prompt_kana.mutual_aid_prem ||
                   to_char(p_prev_jobs(i).mutual_aid_prem) ||
                   g_prompt_kana.yen || ')';
        --
        end if;
      --
      -- <Income Tax>
      --
        l_description_kanji := l_description_kanji || ' ' ||
                 g_prompt_kanji.itax ||
                 to_char(p_prev_jobs(i).itax) ||
                 g_prompt_kanji.yen;
      --
        l_description_kana  := l_description_kana || ' ' ||
                 g_prompt_kana.itax ||
                 to_char(p_prev_jobs(i).itax) ||
                 g_prompt_kana.yen;
      --
      -- <Salary Payer Address>
      --
        if p_prev_jobs(i).salary_payer_address_kanji is not null then
        --
          l_description_kanji := l_description_kanji || ' ' ||
                   p_prev_jobs(i).salary_payer_address_kanji;
        --
        end if;
        --
        if p_prev_jobs(i).salary_payer_address_kana is not null then
        --
          l_description_kana  := l_description_kana || ' ' ||
                   p_prev_jobs(i).salary_payer_address_kana;
        --
        end if;
      --
      -- <Salary Payer Name>
      --
        if p_prev_jobs(i).salary_payer_name_kanji is not null then
        --
          l_description_kanji := l_description_kanji || ' ' ||
                   p_prev_jobs(i).salary_payer_name_kanji;
        --
        end if;
      --
        if p_prev_jobs(i).salary_payer_name_kana is not null then
        --
          l_description_kana  := l_description_kana || ' ' ||
                   p_prev_jobs(i).salary_payer_name_kana;
        --
        end if;
      --
      -- <Termination Date>
      -- Now to_char(''Japanese Imperial'') does not work in PL/SQL.
      -- Here uses to_char of ORACLE as a workaround.
      --
        if p_prev_jobs(i).termination_date is not null then
        --
          l_description_kanji := l_description_kanji || ' ' ||
                   hr_jp_standard_pkg.to_jp_char(p_prev_jobs(i).termination_date, g_prompt_kanji.date_format) ||
                   g_prompt_kanji.terminated;
        --
          l_description_kana  := l_description_kana || ' ' ||
                   hr_jp_standard_pkg.to_jp_char(p_prev_jobs(i).termination_date, g_prompt_kana.date_format) ||
                   g_prompt_kana.terminated;
        --
        end if;
      --
        add_description(
          PREV_JOB,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      end loop;
      --
      hr_utility.set_location(c_proc, 3200);
      --
      -- ************************
      -- HOUSING_TAX_REDUCTION
      -- ************************
      -- Date: 2007/06/07
      -- If statement condition changed to print when "Total" housing tax reduction <> "0"
      -- even "Net" housing tax reduction = "0".
      --
      if p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct <> 0
      and (p_certificate_info.housing_residence_date is not null or p_certificate_info.unclaimed_housing_tax_reduct <> 0) then
      --
        if to_number(to_char(p_effective_date, 'YYYY')) <= 2006 then
        --
          l_description_kanji := g_prompt_kanji.housing_tax_reduction || '(';
          l_description_kana  := g_prompt_kana.housing_tax_reduction || '(';
        --
        else
        --
          l_description_kanji := g_prompt_kanji.housing_tax_reduction_long || '(';
          l_description_kana  := g_prompt_kana.housing_tax_reduction_long || '(';
        --
        end if;
      --
        if p_certificate_info.housing_residence_date is not null then
        --
          l_description_kanji := l_description_kanji ||
                   g_prompt_kanji.residence_date ||
                   hr_jp_standard_pkg.to_jp_char(p_certificate_info.housing_residence_date, g_prompt_kanji.date_format);
        --
          l_description_kana  := l_description_kana ||
                   g_prompt_kana.residence_date ||
                   hr_jp_standard_pkg.to_jp_char(p_certificate_info.housing_residence_date, g_prompt_kana.date_format);
        --
          l_separator := ' ';
        --
        end if;
      --
        if p_certificate_info.unclaimed_housing_tax_reduct <> 0 then
        --
          if to_number(to_char(p_effective_date, 'YYYY')) <= 2006 then
          --
            l_description_kanji := l_description_kanji || l_separator ||
                     g_prompt_kanji.unclaimed_housing_tax_reduct ||
                     to_char(p_certificate_info.unclaimed_housing_tax_reduct) ||
                     g_prompt_kanji.yen;
            l_description_kana  := l_description_kana || l_separator ||
                     g_prompt_kana.unclaimed_housing_tax_reduct ||
                     to_char(p_certificate_info.unclaimed_housing_tax_reduct) ||
                     g_prompt_kana.yen;
          --
          elsif to_number(to_char(p_effective_date,'YYYY')) = 2008 then
          --
            if not (p_certificate_info.housing_residence_date is not null
                   and p_certificate_info.housing_residence_date >= to_date('2007/01/01','YYYY/MM/DD')) then
            --
              l_description_kanji :=
                l_description_kanji || l_separator ||
                g_prompt_kanji.total_housing_tax_reduction ||
                to_char(p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct) ||
                g_prompt_kanji.yen;
              l_description_kana :=
                l_description_kana || l_separator ||
                g_prompt_kana.total_housing_tax_reduction ||
                to_char(p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct) ||
                g_prompt_kana.yen;
            --
            end if;
          --
          else
          --
            l_description_kanji :=
              l_description_kanji || l_separator ||
              g_prompt_kanji.total_housing_tax_reduction ||
              to_char(p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct) ||
              g_prompt_kanji.yen;
            l_description_kana :=
              l_description_kana || l_separator ||
              g_prompt_kana.total_housing_tax_reduction ||
              to_char(p_certificate_info.housing_tax_reduction + p_certificate_info.unclaimed_housing_tax_reduct) ||
              g_prompt_kana.yen;
          --
          end if;
        --
        end if;
        --
        l_description_kanji := l_description_kanji || ')';
        l_description_kana  := l_description_kana || ')';
        --
        add_description(
          HOUSING_TAX_REDUCTION,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      end if;
    --
    else
    --
      hr_utility.set_location(c_proc, 3300);
    --
    -- ************************
    -- DISASTER_TAX_REDUCTION
    -- ************************
    --
      if p_certificate_info.tax_info.disaster_tax_reduction <> 0 then
      --
        l_description_kanji := g_prompt_kanji.disaster_tax_reduction ||
                 to_char(p_certificate_info.tax_info.disaster_tax_reduction) ||
                 g_prompt_kanji.yen;
      --
        l_description_kana  := g_prompt_kana.disaster_tax_reduction ||
                 to_char(p_certificate_info.tax_info.disaster_tax_reduction) ||
                 g_prompt_kana.yen;
      --
        add_description(
          DISASTER_TAX_REDUCTION,
          l_description_kanji,
          l_description_kana,
          p_descriptions);
      --
      end if;
    --
    end if;
  --
  end if;
--
  hr_utility.set_location('Leaving: ' || c_proc, 10000);
--
end get_descriptions;
--
-- Wrapper function for existing user program (for previous behavior)
--
procedure get_descriptions(
  p_assignment_id     in number,
  p_person_id         in number,
  p_effective_date    in date,
  p_itax_yea_category in varchar2,
  p_certificate_info  in t_certificate_info,
  p_last_name_kanji   in varchar2,
  p_last_name_kana    in varchar2,
  p_dpnts             in t_dpnts,
  p_prev_jobs         in t_prev_jobs,
  p_report_type       in varchar2, --> ITW/WTM
  p_descriptions      out nocopy t_descriptions)
is
--
  l_housing_tbl t_housing_tbl;
--
begin
--
  get_descriptions(
    p_assignment_id     => p_assignment_id,
    p_person_id         => p_person_id,
    p_effective_date    => p_effective_date,
    p_itax_yea_category => p_itax_yea_category,
    p_certificate_info  => p_certificate_info,
    p_last_name_kanji   => p_last_name_kanji,
    p_last_name_kana    => p_last_name_kana,
    p_dpnts             => p_dpnts,
    p_prev_jobs         => p_prev_jobs,
    p_housing_tbl       => l_housing_tbl,
    p_report_type       => p_report_type,
    p_descriptions      => p_descriptions);
--
end get_descriptions;
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
-- Wrapper function for ITT
procedure get_certificate_info(
	p_assignment_action_id		in number,
	p_assignment_id			in number,
	p_action_sequence		in number,
	p_effective_date		in date,
	p_itax_organization_id		in number,
	p_itax_category			in varchar2,
	p_itax_yea_category		in varchar2,
	p_employment_category		in varchar2,
	p_person_id			in number,
	p_business_group_id		in number,
	p_date_earned			in date,
	p_certificate_info		out nocopy t_tax_info,
	p_submission_required_flag	out nocopy varchar2,
	p_withholding_tax_info		out nocopy t_tax_info)
is
	c_proc		constant varchar2(61) := c_package || 'get_certificate_info (ITT)';
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	get_basic_certificate_info(
		p_assignment_action_id		=> p_assignment_action_id,
		p_assignment_id			=> p_assignment_id,
		p_action_sequence		=> p_action_sequence,
		p_effective_date		=> p_effective_date,
		p_itax_organization_id		=> p_itax_organization_id,
		p_itax_category			=> p_itax_category,
		p_itax_yea_category		=> p_itax_yea_category,
		p_employment_category		=> p_employment_category,
		p_certificate_info		=> p_certificate_info,
		p_submission_required_flag	=> p_submission_required_flag);
	--
	hr_utility.set_location(c_proc, 20);
	--
	if p_itax_yea_category = '0' then
		hr_utility.set_location(c_proc, 21);
		--
		--
		-- Derive withholding tax information by current employer.
		--
		get_withholding_tax_info(
			p_assignment_action_id		=> p_assignment_action_id,
			p_assignment_id			=> p_assignment_id,
			p_action_sequence		=> p_action_sequence,
			p_effective_date		=> p_effective_date,
			p_itax_organization_id		=> p_itax_organization_id,
			p_itax_category			=> p_itax_category,
			p_itax_yea_category		=> p_itax_yea_category,
			p_withholding_tax_info		=> p_withholding_tax_info);
	else
		hr_utility.set_location(c_proc, 22);
		--
		--
		-- For non-YEAed employees, current employer's payment with same tax category
		-- are shown in certificates. So just copy p_certificate_info to p_withholding_tax_info.
		--
		p_withholding_tax_info := p_certificate_info;
	end if;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
end get_certificate_info;
-- |-------------------------------------------------------------------|
-- |---------------------< get_basic_certificate_info >----------------|
-- |-------------------------------------------------------------------|
--
-- Source function for ITW, WTM, the wrapper for Archive (called from gci_b, gci_itw_arc : gci_s)
--
procedure get_basic_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_employment_category      in varchar2,
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_jobs                out nocopy t_prev_jobs,
  p_housing_tbl              out nocopy t_housing_tbl)
is
--
  c_proc        constant varchar2(61) := c_package || 'get_basic_certificate_info (2)';
--
  l_dpnt_rec             per_jp_ctr_utility_pkg.t_itax_dpnt_rec;
  l_disabled_type        varchar2(30);
  l_aged_type            varchar2(30);
  l_widow_type           varchar2(30);
  l_working_student_type varchar2(30);
  l_spouse_type          varchar2(30);
  l_spouse_disabled_type varchar2(30);
  l_num_deps             number;
  l_num_ageds            number;
  l_num_aged_parents_lt  number;
  l_num_specifieds       number;
  l_num_disableds        number;
  l_num_svr_disableds    number;
  l_num_svr_disableds_lt number;
  l_dummy                varchar2(1);
  l_dummy_number         number;
--
  cursor csr_spouse is
  select  'Y'
  from  per_contact_relationships ctr
  where ctr.person_id = p_person_id
  and   ctr.contact_type = 'S'
  and   p_effective_date
        between nvl(ctr.date_start, p_effective_date) and nvl(ctr.date_end, p_effective_date);
--
begin
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  get_basic_certificate_info(
    p_assignment_action_id     => p_assignment_action_id,
    p_assignment_id            => p_assignment_id,
    p_action_sequence          => p_action_sequence,
    p_effective_date           => p_effective_date,
    p_itax_organization_id     => p_itax_organization_id,
    p_itax_category            => p_itax_category,
    p_itax_yea_category        => p_itax_yea_category,
    p_employment_category      => p_employment_category,
    p_certificate_info         => p_certificate_info.tax_info,
    p_submission_required_flag => p_submission_required_flag);
--
  hr_utility.set_location(c_proc, 20);
--
  --
  -- The following information is specific only for YEAed assignments.
  --
  if p_itax_yea_category = '0' then
  --
    hr_utility.set_location(c_proc, 21);
  --
    p_certificate_info.net_taxable_income
      := nvl(pay_jp_balance_pkg.get_result_value_number(g_taxable_income_exempt_elm.element_type_id,g_taxable_income_exempt_elm.net_taxable_income_iv,p_assignment_action_id),0);
  --
    p_certificate_info.spouse_sp_exempt
      := nvl(pay_jp_balance_pkg.get_result_value_number(g_ins_prem_exempt_elm.element_type_id,g_ins_prem_exempt_elm.spouse_sp_exempt_iv,p_assignment_action_id),0);
  --
    if p_certificate_info.spouse_sp_exempt <> 0 then
    --
      p_certificate_info.spouse_net_taxable_income
        := nvl(pay_jp_balance_pkg.get_result_value_number(g_ins_prem_exempt_elm.element_type_id,g_ins_prem_exempt_elm.spouse_net_taxable_income_iv,p_assignment_action_id),0);
    --
    end if;
  --
    -- Date: 2007/06/07
    -- "Personal Pension Premium" should be printed only when "Personal Pension Premium" <> 0.
  --
    p_certificate_info.li_prem_exempt := nvl(pay_jp_balance_pkg.get_result_value_number(g_ins_prem_exempt_elm.element_type_id,g_ins_prem_exempt_elm.li_prem_exempt_iv,p_assignment_action_id),0);
  --
    if p_certificate_info.li_prem_exempt <> 0 then
    --
      l_dummy_number := nvl(pay_jp_balance_pkg.get_result_value_number(g_ins_prem_exempt_elm.element_type_id,g_ins_prem_exempt_elm.pp_prem_iv,p_assignment_action_id),0);
    --
      if l_dummy_number <> 0 then
      --
        p_certificate_info.pp_prem := l_dummy_number;
      --
      end if;
    --
    end if;
  --
    -- Date: 2007/06/07
    -- "Long-term Accident Insurance Premium" should be printed only when "Long-term Accident Insurance Premium" <> 0.
  --
    p_certificate_info.ai_prem_exempt := nvl(pay_jp_balance_pkg.get_result_value_number(g_ins_prem_exempt_elm.element_type_id,g_ins_prem_exempt_elm.ai_prem_exempt_iv,p_assignment_action_id),0);
  --
    if p_certificate_info.ai_prem_exempt <> 0 then
    --
      l_dummy_number := nvl(pay_jp_balance_pkg.get_result_value_number(g_ins_prem_exempt_elm.element_type_id,g_ins_prem_exempt_elm.long_ai_prem_iv,p_assignment_action_id),0);
    --
      if l_dummy_number <> 0 then
      --
        p_certificate_info.long_ai_prem := l_dummy_number;
      --
      end if;
    --
    end if;
  --
    p_certificate_info.total_income_exempt := pay_jp_balance_pkg.get_balance_value(g_total_income_exempt_asg_run, p_assignment_action_id);
  --
    -- Date: 2007/06/07
    -- There's possibility when "Housing Tax Reduction" > 0, but "Net Housing Tax Reduction" = 0.
    -- This occurs when annual tax is zero. In this case, "Housing Tax Reduction Information" should
    -- be printed on "Description" field.
  --
    p_certificate_info.housing_tax_reduction
      := nvl(pay_jp_balance_pkg.get_result_value_number(g_net_annual_itax_elm.element_type_id,g_net_annual_itax_elm.net_housing_tax_reduction_iv,p_assignment_action_id),0);
  --
    l_dummy_number := nvl(pay_jp_balance_pkg.get_result_value_number(g_net_annual_itax_elm.element_type_id,g_net_annual_itax_elm.housing_tax_reduction_iv,p_assignment_action_id),0);
  --
    if l_dummy_number <> 0 then
    --
      if to_number(to_char(p_effective_date,'YYYY')) < 2009
      or (to_number(to_char(p_effective_date,'YYYY')) = 2009
         and to_number(to_char(p_effective_date,'MM')) < 4) then
      --
        p_certificate_info.housing_residence_date := pay_jp_balance_pkg.get_entry_value_date(g_housing_tax_reduction_elm.residence_date_iv,p_assignment_id,p_date_earned);
      --
      end if;
    --
      p_certificate_info.unclaimed_housing_tax_reduct := l_dummy_number - p_certificate_info.housing_tax_reduction;
    --
    end if;
  --
    if to_number(to_char(p_effective_date, 'YYYY')) <= 2006 then
    --
      p_certificate_info.fixed_rate_tax_reduction
        := nvl(pay_jp_balance_pkg.get_result_value_number(g_net_annual_itax_elm.element_type_id,g_net_annual_itax_elm.fixed_rate_tax_reduction_iv,p_assignment_action_id),0);
    --
    else
    --
      p_certificate_info.fixed_rate_tax_reduction := 0;
    --
    end if;
  --
    if to_number(to_char(p_effective_date, 'YYYY')) >= 2005 then
    --
      p_certificate_info.national_pens_prem := nvl(pay_jp_balance_pkg.get_entry_value_number(g_yea_ins_prem_sp_exm_info_elm.national_pens_prem_iv,p_assignment_id,p_date_earned),0);
    --
    else
    --
      p_certificate_info.national_pens_prem := 0;
    --
    end if;
  --
    if to_number(to_char(p_effective_date,'YYYY')) > 2009
    or (to_number(to_char(p_effective_date,'YYYY')) = 2009
       and to_number(to_char(p_effective_date,'MM')) >= 4) then
    --
    -- should get p_housing_tbl in only following case
    --
    -- from performance reason, not get for all to check if entry exists
    -- actually desired to accept in case total_housing_loan (dummy_number) is 0 if residence date is set.
    --
      if p_itax_yea_category = '0'
      and l_dummy_number <> 0 then
      --
        get_housing_tbl(
          p_assignment_id  => p_assignment_id,
          p_date_earned    => p_date_earned,
          p_housing_tbl    => p_housing_tbl);
      --
      end if;
    --
    end if;
  --
    hr_utility.set_location(c_proc, 22);
  --
    get_prev_jobs(
      p_assignment_id        => p_assignment_id,
      p_action_sequence      => p_action_sequence,
      p_business_group_id    => p_business_group_id,
      p_effective_date       => p_effective_date,
      p_date_earned          => p_date_earned,
      p_itax_organization_id => p_itax_organization_id,
      p_person_id            => p_person_id,
      p_prev_jobs            => p_prev_jobs);
  --
  end if;
  --
  hr_utility.set_location(c_proc, 30);
  --
  -- Dependents Information
  --
  if p_itax_category in ('M_KOU', 'M_OTSU', 'D_KOU', 'D_OTSU') then
  --
    if p_itax_yea_category = '0' then
    --
      hr_utility.set_location(c_proc, 31);
    --
      l_disabled_type := nvl(pay_jp_balance_pkg.get_result_value_char(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.disabled_iv,p_assignment_action_id),'0');
    --
      if to_number(to_char(p_effective_date,'YYYY')) < 2005 then
      --
        l_aged_type := nvl(pay_jp_balance_pkg.get_result_value_char(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.aged_iv,p_assignment_action_id),'0');
      --
      end if;
    --
      l_widow_type := nvl(pay_jp_balance_pkg.get_result_value_char(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.widow_iv,p_assignment_action_id),'0');
      l_working_student_type := nvl(pay_jp_balance_pkg.get_result_value_char(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.working_student_iv,p_assignment_action_id),'0');
    --
      l_spouse_type := nvl(pay_jp_balance_pkg.get_result_value_char(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.spouse_type_iv,p_assignment_action_id),'0');
      l_spouse_disabled_type := nvl(pay_jp_balance_pkg.get_result_value_char(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.spouse_disabled_iv,p_assignment_action_id),'0');
    --
      l_num_deps := nvl(pay_jp_balance_pkg.get_result_value_number(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.num_deps_iv,p_assignment_action_id),0);
      l_num_ageds := nvl(pay_jp_balance_pkg.get_result_value_number(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.num_ageds_iv,p_assignment_action_id),0);
      l_num_aged_parents_lt := nvl(pay_jp_balance_pkg.get_result_value_number(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.num_aged_parents_lt_iv,p_assignment_action_id),0);
      l_num_specifieds := nvl(pay_jp_balance_pkg.get_result_value_number(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.num_specifieds_iv,p_assignment_action_id),0);
      l_num_disableds := nvl(pay_jp_balance_pkg.get_result_value_number(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.num_disableds_iv,p_assignment_action_id),0);
      l_num_svr_disableds := nvl(pay_jp_balance_pkg.get_result_value_number(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.num_svr_disableds_iv,p_assignment_action_id),0);
      l_num_svr_disableds_lt := nvl(pay_jp_balance_pkg.get_result_value_number(g_dep_exempt_result_elm.element_type_id,g_dep_exempt_result_elm.num_svr_disableds_lt_iv,p_assignment_action_id),0);
    --
    else
    --
      hr_utility.set_location(c_proc, 32);
    --
      l_disabled_type := nvl(pay_jp_balance_pkg.get_entry_value_char(g_dep_exempt_elm.disabled_iv,p_assignment_id,p_date_earned),'0');
    --
      if to_number(to_char(p_effective_date,'YYYY')) < 2005 then
      --
        l_aged_type := nvl(pay_jp_balance_pkg.get_entry_value_char(g_dep_exempt_elm.aged_iv,p_assignment_id,p_date_earned),'0');
      --
      end if;
    --
      l_widow_type := nvl(pay_jp_balance_pkg.get_entry_value_char(g_dep_exempt_elm.widow_iv,p_assignment_id,p_date_earned),'0');
      l_working_student_type := nvl(pay_jp_balance_pkg.get_entry_value_char(g_dep_exempt_elm.working_student_iv,p_assignment_id,p_date_earned),'0');
    --
      l_spouse_type := pay_jp_balance_pkg.get_entry_value_char(g_dep_exempt_elm.spouse_type_iv,p_assignment_id,p_date_earned);
      l_spouse_disabled_type := pay_jp_balance_pkg.get_entry_value_char(g_dep_exempt_elm.spouse_disabled_iv,p_assignment_id,p_date_earned);
    --
      l_num_deps := pay_jp_balance_pkg.get_entry_value_number(g_dep_exempt_elm.num_deps_iv,p_assignment_id,p_date_earned);
      l_num_ageds := pay_jp_balance_pkg.get_entry_value_number(g_dep_exempt_elm.num_ageds_iv,p_assignment_id,p_date_earned);
      l_num_aged_parents_lt := pay_jp_balance_pkg.get_entry_value_number(g_dep_exempt_elm.num_aged_parents_lt_iv,p_assignment_id,p_date_earned);
      l_num_specifieds := pay_jp_balance_pkg.get_entry_value_number(g_dep_exempt_elm.num_specifieds_iv,p_assignment_id,p_date_earned);
      l_num_disableds := pay_jp_balance_pkg.get_entry_value_number(g_dep_exempt_elm.num_disableds_iv,p_assignment_id,p_date_earned);
      l_num_svr_disableds := pay_jp_balance_pkg.get_entry_value_number(g_dep_exempt_elm.num_svr_disableds_iv,p_assignment_id,p_date_earned);
      l_num_svr_disableds_lt := pay_jp_balance_pkg.get_entry_value_number(g_dep_exempt_elm.num_svr_disableds_lt_iv,p_assignment_id,p_date_earned);
    --
      -- Derive Dependent Information based on Income Tax Dependent Control Method.
      -- This flag is set at "Payroll Developer DF" or "Org Developer DF"(Business Group level).
      -- The value set in "Payroll Developer DF" has higher priority than "Org Developer DF".
      -- Here does not do the cross validation for each dependent deduction like FastFormula.
      -- This dynamic deriving routine is available when YEA is not processed.
    --
      if p_dpnt_ref_type = 'CEI' then
      --
        hr_utility.set_location(c_proc, 33);
      --
        if l_spouse_type is null
        or l_spouse_disabled_type is null
        or l_num_deps is null
        or l_num_ageds is null
        or l_num_aged_parents_lt is null
        or l_num_specifieds is null
        or l_num_disableds is null
        or l_num_svr_disableds is null
        or l_num_svr_disableds_lt is null then
        --
          per_jp_ctr_utility_pkg.get_itax_dpnt_info(
            p_assignment_id  => p_assignment_id,
            p_itax_type      => p_itax_category,
            p_effective_date => p_dpnt_effective_date,
            p_itax_dpnt_rec  => l_dpnt_rec);
        --
          l_spouse_type := nvl(l_spouse_type,l_dpnt_rec.spouse_type);
          l_spouse_disabled_type := nvl(l_spouse_disabled_type,l_dpnt_rec.dpnt_spouse_dsbl_type);
          l_num_deps := nvl(l_num_deps,l_dpnt_rec.dpnts);
          l_num_ageds := nvl(l_num_ageds,l_dpnt_rec.aged_dpnts);
          l_num_aged_parents_lt := nvl(l_num_aged_parents_lt,l_dpnt_rec.aged_dpnt_parents_lt);
          l_num_specifieds := nvl(l_num_specifieds,l_dpnt_rec.young_dpnts);
          l_num_disableds := nvl(l_num_disableds,l_dpnt_rec.dsbl_dpnts);
          l_num_svr_disableds := nvl(l_num_svr_disableds,l_dpnt_rec.svr_dsbl_dpnts);
          l_num_svr_disableds_lt := nvl(l_num_svr_disableds_lt,l_dpnt_rec.svr_dsbl_dpnts_lt);
        --
        end if;
      --
      else
      --
        hr_utility.set_location(c_proc, 34);
      --
        l_spouse_type := nvl(l_spouse_type,'0');
        l_spouse_disabled_type := nvl(l_spouse_disabled_type,'0');
        l_num_deps := nvl(l_num_deps,0);
        l_num_ageds := nvl(l_num_ageds,0);
        l_num_aged_parents_lt := nvl(l_num_aged_parents_lt,0);
        l_num_specifieds := nvl(l_num_specifieds,0);
        l_num_disableds := nvl(l_num_disableds,0);
        l_num_svr_disableds := nvl(l_num_svr_disableds,0);
        l_num_svr_disableds_lt := nvl(l_num_svr_disableds_lt,0);
      --
      end if;
    --
    end if;
  --
    hr_utility.set_location(c_proc, 34);
  --
    if p_itax_category in ('M_KOU','D_KOU') then
    --
      hr_utility.set_location(c_proc, 35);
    --
      if l_spouse_type = '2' then
      --
        p_certificate_info.dep_spouse_exists_kou  := 'Y';
      --
      elsif l_spouse_type = '3' then
      --
        p_certificate_info.dep_spouse_exists_kou  := 'Y';
        p_certificate_info.aged_spouse_exists   := 'Y';
      --
      else
      --
        p_certificate_info.dep_spouse_not_exist_kou := 'Y';
      --
      end if;
    --
      p_certificate_info.num_specifieds_kou := l_num_specifieds;
      p_certificate_info.num_aged_parents_lt := l_num_aged_parents_lt;
      p_certificate_info.num_ageds_kou := l_num_aged_parents_lt + l_num_ageds;
      p_certificate_info.num_deps_kou := greatest(l_num_deps - (l_num_specifieds + l_num_aged_parents_lt + l_num_ageds), 0);
    --
      p_certificate_info.num_svr_disableds_lt := l_num_svr_disableds_lt;
      p_certificate_info.num_svr_disableds := l_num_svr_disableds;
      p_certificate_info.num_disableds := l_num_disableds;
    --
      if l_spouse_disabled_type = '1' then
      --
        p_certificate_info.num_disableds := p_certificate_info.num_disableds + 1;
      --
      elsif l_spouse_disabled_type = '2' then
      --
        p_certificate_info.num_svr_disableds := p_certificate_info.num_svr_disableds + 1;
      --
      elsif l_spouse_disabled_type = '3' then
      --
        p_certificate_info.num_svr_disableds_lt := p_certificate_info.num_svr_disableds_lt + 1;
      --
      end if;
    --
      p_certificate_info.num_svr_disableds := p_certificate_info.num_svr_disableds + p_certificate_info.num_svr_disableds_lt;
    --
      p_certificate_info.num_specifieds_kou := decode_value(p_certificate_info.num_specifieds_kou > 0, p_certificate_info.num_specifieds_kou);
      p_certificate_info.num_aged_parents_lt := decode_value(p_certificate_info.num_aged_parents_lt > 0, p_certificate_info.num_aged_parents_lt);
      p_certificate_info.num_ageds_kou := decode_value(p_certificate_info.num_ageds_kou > 0, p_certificate_info.num_ageds_kou);
      p_certificate_info.num_deps_kou := decode_value(p_certificate_info.num_deps_kou  > 0, p_certificate_info.num_deps_kou );
      p_certificate_info.num_svr_disableds_lt := decode_value(p_certificate_info.num_svr_disableds_lt > 0, p_certificate_info.num_svr_disableds_lt);
      p_certificate_info.num_svr_disableds := decode_value(p_certificate_info.num_svr_disableds > 0, p_certificate_info.num_svr_disableds);
      p_certificate_info.num_disableds := decode_value(p_certificate_info.num_disableds > 0, p_certificate_info.num_disableds);
    --
      if l_disabled_type = '2' then
      --
        p_certificate_info.svr_disabled_flag := 'Y';
      --
      elsif l_disabled_type = '1' then
      --
        p_certificate_info.disabled_flag := 'Y';
      --
      end if;
    --
      if to_number(to_char(p_effective_date,'YYYY')) < 2005 then
      --
        if l_aged_type = '1' then
        --
          p_certificate_info.aged_flag := 'Y';
        --
        end if;
      --
      end if;
    --
      if l_widow_type = '2' then
      --
        if p_sex = 'F' then
        --
          p_certificate_info.sp_widow_flag := 'Y';
        --
        else
        --
          p_certificate_info.widower_flag := 'Y';
        --
        end if;
      --
      elsif l_widow_type = '1' then
      --
        if p_sex = 'F' then
        --
          p_certificate_info.widow_flag := 'Y';
        --
        else
        --
          p_certificate_info.widower_flag := 'Y';
        --
        end if;
      --
      end if;
    --
      if l_working_student_type = '1' then
      --
        p_certificate_info.working_student_flag := 'Y';
      --
      end if;
    --
    elsif p_itax_category in ('M_OTSU','D_OTSU') then
    --
      hr_utility.set_location(c_proc, 36);
    --
      if l_spouse_type = '2' then
      --
        p_certificate_info.dep_spouse_exists_otsu := 'Y';
      --
      elsif l_spouse_type = '3' then
      --
        p_certificate_info.dep_spouse_exists_otsu := 'Y';
        p_certificate_info.aged_spouse_exists   := 'Y';
      --
      else
        p_certificate_info.dep_spouse_not_exist_otsu  := 'Y';
      --
      end if;
    --
      p_certificate_info.num_specifieds_otsu  := l_num_specifieds;
      p_certificate_info.num_ageds_otsu := l_num_aged_parents_lt + l_num_ageds;
      p_certificate_info.num_deps_otsu := greatest(l_num_deps - (l_num_specifieds + l_num_aged_parents_lt + l_num_ageds), 0);
    --
      p_certificate_info.num_specifieds_otsu := decode_value(p_certificate_info.num_specifieds_otsu > 0, p_certificate_info.num_specifieds_otsu);
      p_certificate_info.num_ageds_otsu := decode_value(p_certificate_info.num_ageds_otsu > 0, p_certificate_info.num_ageds_otsu);
      p_certificate_info.num_deps_otsu := decode_value(p_certificate_info.num_deps_otsu > 0, p_certificate_info.num_deps_otsu);
    --
    end if;
  --
  end if;
--
  hr_utility.set_location(c_proc, 40);
--
  --
  -- Husband Exists
  --
--
  if to_number(to_char(p_effective_date,'YYYY')) < 2005 then
  --
    if p_sex = 'F' then
    --
      open csr_spouse;
      fetch csr_spouse into l_dummy;
      if csr_spouse%found then
        p_certificate_info.husband_exists := 'Y';
      end if;
      close csr_spouse;
    --
    end if;
  --
  end if;
--
  -- Minor is free from Local Tax.
  -- The age used here needs to be calculated as of Jan 1st in the next calendar year.
  -- If an employee is under 20 years old as of Jan 1st, he/she is "Minor".
  -- The way how to calculate age in Japanese law is slightly different from normal way,
  -- an employee's age is incremented on the previous day of the date of birth.
  -- As a result, we need to calculate age as of "Jan 1st + 1" = "Jan 2nd".
  -- Note "Aged" is calculated as of "End of Calendar Year" which is different from this case.
--
  if floor(months_between(add_months(trunc(p_effective_date, 'YYYY'), 12) + 1, p_date_of_birth) / 12) < 20 then
  --
    p_certificate_info.minor_flag := 'Y';
  --
  end if;
--
  --
  -- Otsu
  --
--
  if p_itax_category in ('M_OTSU', 'D_OTSU') then
  --
    p_certificate_info.otsu_flag := 'Y';
  --
  end if;
--
  --
  -- Deceased Termination
  --
--
  if p_leaving_reason like 'D%' then
  --
    p_certificate_info.deceased_termination_flag := 'Y';
  --
  end if;
--
  --
  -- Disastered
  --
--
  if p_certificate_info.tax_info.disaster_tax_reduction <> 0 then
  --
    p_certificate_info.disastered_flag := 'Y';
  --
  end if;
--
  --
  -- Foreigner
  --
--
  if pay_jp_balance_pkg.get_entry_value_char(g_itax_info_elm.foreigner_flag_iv, p_assignment_id, p_date_earned) = 'Y' then
  --
    p_certificate_info.foreigner_flag := 'Y';
  --
  end if;
--
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end get_basic_certificate_info;
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
--
-- Wrapper function for the wrapper function for WTM, ITW (called from gci_wtm, gci_itw_b : gci_b)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_jobs                out nocopy t_prev_jobs,
  p_housing_tbl              out nocopy t_housing_tbl)
is
--
  c_proc constant varchar2(61) := c_package || 'get_certificate_info (WTM)';
--
  l_itw_override_flag varchar2(1);
  l_itw_description   varchar2(300);
  l_wtm_override_flag varchar2(1);
  l_wtm_description   varchar2(300);
  l_override_flag     varchar2(1);
  l_description       varchar2(300);
  l_report_type       varchar2(3);
--
  l_dpnts t_dpnts;
  l_descriptions t_descriptions;
--
  procedure concat_description(
    p_description        in varchar2,
    p_concat_description in out nocopy varchar2,
    p_separator          in varchar2)
  is
  begin
  --
    if p_description is not null then
    --
      if p_concat_description is not null then
      --
        p_concat_description := p_concat_description || p_separator || p_description;
      --
      else
      --
        p_concat_description := p_description;
      --
      end if;
    --
    end if;
  --
  end concat_description;
--
begin
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  get_basic_certificate_info(
    p_assignment_action_id     => p_assignment_action_id,
    p_assignment_id            => p_assignment_id,
    p_action_sequence          => p_action_sequence,
    p_business_group_id        => p_business_group_id,
    p_effective_date           => p_effective_date,
    p_date_earned              => p_date_earned,
    p_itax_organization_id     => p_itax_organization_id,
    p_itax_category            => p_itax_category,
    p_itax_yea_category        => p_itax_yea_category,
    p_dpnt_ref_type            => p_dpnt_ref_type,
    p_dpnt_effective_date      => p_dpnt_effective_date,
    p_person_id                => p_person_id,
    p_sex                      => p_sex,
    p_date_of_birth            => p_date_of_birth,
    p_leaving_reason           => p_leaving_reason,
    p_employment_category      => p_employment_category,
    p_certificate_info         => p_certificate_info,
    p_submission_required_flag => p_submission_required_flag,
    p_prev_jobs                => p_prev_jobs,
    p_housing_tbl              => p_housing_tbl);
--
  hr_utility.set_location(c_proc, 20);
--
  -- Get Description information
  -- When description on element entry is marked as "Override",
  -- subsequent description will be replaced by this.
--
  get_ee_description(
    p_assignment_id     => p_assignment_id,
    p_business_group_id => p_business_group_id,
    p_effective_date    => p_date_earned,
    p_itw_override_flag => l_itw_override_flag,
    p_itw_description   => l_itw_description,
    p_wtm_override_flag => l_wtm_override_flag,
    p_wtm_description   => l_wtm_description);
--
  hr_utility.set_location(c_proc, 30);
--
  if p_magnetic_media_flag = 'Y' then
  --
    hr_utility.set_location(c_proc, 31);
  --
    l_override_flag := l_wtm_override_flag;
    l_description   := l_wtm_description;
    l_report_type   := WTM;
  --
  else
  --
    hr_utility.set_location(c_proc, 32);
  --
    l_override_flag := l_itw_override_flag;
    l_description   := l_itw_description;
    l_report_type   := ITW;
  --
  end if;
--
  hr_utility.set_location(c_proc, 40);
--
  if l_override_flag = 'Y' then
  --
    hr_utility.set_location(c_proc, 41);
  --
    p_certificate_info.description_kanji := l_description;
    p_certificate_info.description_kana  := hr_jp_standard_pkg.to_hankaku(l_description);
  --
  else
  --
    hr_utility.set_location(c_proc, 42);
  --
    get_dpnts(
      p_dpnt_ref_type       => p_dpnt_ref_type,
      p_assignment_id       => p_assignment_id,
      p_itax_category       => p_itax_category,
      p_dpnt_effective_date => p_dpnt_effective_date,
      p_person_id           => p_person_id,
      p_effective_date      => p_effective_date,
      p_sex                 => p_sex,
      p_dpnts               => l_dpnts);
  --
    hr_utility.set_location(c_proc, 43);
  --
    get_descriptions(
      p_assignment_id     => p_assignment_id,
      p_person_id         => p_person_id,
      p_effective_date    => p_effective_date,
      p_itax_yea_category => p_itax_yea_category,
      p_certificate_info  => p_certificate_info,
      p_last_name_kanji   => p_last_name_kanji,
      p_last_name_kana    => p_last_name_kana,
      p_dpnts             => l_dpnts,
      p_prev_jobs         => p_prev_jobs,
      p_housing_tbl       => p_housing_tbl,
      p_report_type       => l_report_type,
      p_descriptions      => l_descriptions);
  --
    hr_utility.set_location(c_proc, 44);
  --
    -- Construct Description field.
    --
    for i in 1..l_descriptions.count loop
    --
      hr_utility.set_location(c_proc, 45);
    --
      if p_magnetic_media_flag = 'Y' then
      --
        concat_description(l_descriptions(i).description_kanji, p_certificate_info.description_kanji, ',');
        concat_description(l_descriptions(i).description_kana,  p_certificate_info.description_kana, ',');
      --
      else
      --
        if l_descriptions(i).description_type in (FIXED_RATE_TAX_REDUCTION, NP_PREM) then
        --
          concat_description(l_descriptions(i).description_kanji, p_certificate_info.desc_line1_kanji, ' ');
          concat_description(l_descriptions(i).description_kana,  p_certificate_info.desc_line1_kana, ' ');
        --
        else
        --
          concat_description(l_descriptions(i).description_kanji, p_certificate_info.description_kanji, ',');
          concat_description(l_descriptions(i).description_kana,  p_certificate_info.description_kana, ',');
        --
        end if;
      --
      end if;
    --
    end loop;
  --
    concat_description(l_description, p_certificate_info.description_kanji, ',');
    concat_description(hr_jp_standard_pkg.to_hankaku(l_description), p_certificate_info.description_kana, ',');
  --
  end if;
--
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end get_certificate_info;
--
-- Wrapper function for WTM (used this in efile PAYJPWTM, PAYJPSPE : gci_wtm)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_job_info            out nocopy t_prev_job_info,
  p_housing_info             out nocopy t_housing_info)
is
--
  l_housing_tbl t_housing_tbl;
  l_prev_jobs   pay_jp_wic_pkg.t_prev_jobs;
--
begin
--
  get_certificate_info(
    p_assignment_action_id     => p_assignment_action_id,
    p_assignment_id            => p_assignment_id,
    p_action_sequence          => p_action_sequence,
    p_business_group_id        => p_business_group_id,
    p_effective_date           => p_effective_date,
    p_date_earned              => p_date_earned,
    p_itax_organization_id     => p_itax_organization_id,
    p_itax_category            => p_itax_category,
    p_itax_yea_category        => p_itax_yea_category,
    p_dpnt_ref_type            => p_dpnt_ref_type,
    p_dpnt_effective_date      => p_dpnt_effective_date,
    p_person_id                => p_person_id,
    p_sex                      => p_sex,
    p_date_of_birth            => p_date_of_birth,
    p_leaving_reason           => p_leaving_reason,
    p_last_name_kanji          => p_last_name_kanji,
    p_last_name_kana           => p_last_name_kana,
    p_employment_category      => p_employment_category,
    p_magnetic_media_flag      => p_magnetic_media_flag,
    p_certificate_info         => p_certificate_info,
    p_submission_required_flag => p_submission_required_flag,
    p_prev_jobs                => l_prev_jobs,
    p_housing_tbl              => l_housing_tbl);
--
  p_housing_info := convert_housing_tbl(
                     p_effective_date,
                     p_itax_yea_category,
                     p_certificate_info,
                     l_housing_tbl);
--
  p_prev_job_info := convert_prev_jobs(l_prev_jobs);
--
end get_certificate_info;
--
-- Wrapper function for existing user program (call gci_wtm for previous behavior : gci_wtm_usr)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_job_info            out nocopy t_prev_job_info)
is
--
  l_housing_info t_housing_info;
--
begin
--
  get_certificate_info(
    p_assignment_action_id     => p_assignment_action_id,
    p_assignment_id            => p_assignment_id,
    p_action_sequence          => p_action_sequence,
    p_business_group_id        => p_business_group_id,
    p_effective_date           => p_effective_date,
    p_date_earned              => p_date_earned,
    p_itax_organization_id     => p_itax_organization_id,
    p_itax_category            => p_itax_category,
    p_itax_yea_category        => p_itax_yea_category,
    p_dpnt_ref_type            => p_dpnt_ref_type,
    p_dpnt_effective_date      => p_dpnt_effective_date,
    p_person_id                => p_person_id,
    p_sex                      => p_sex,
    p_date_of_birth            => p_date_of_birth,
    p_leaving_reason           => p_leaving_reason,
    p_last_name_kanji          => p_last_name_kanji,
    p_last_name_kana           => p_last_name_kana,
    p_employment_category      => p_employment_category,
    p_magnetic_media_flag      => p_magnetic_media_flag,
    p_certificate_info         => p_certificate_info,
    p_submission_required_flag => p_submission_required_flag,
    p_prev_job_info            => p_prev_job_info,
    p_housing_info             => l_housing_info);
--
end get_certificate_info;
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
--
-- Wrapper function for ITW (called from gci_itw : gci_itw_b)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_jobs                out nocopy t_prev_jobs,
  p_withholding_tax_info     out nocopy t_tax_info)
is
--
  c_proc constant varchar2(61) := c_package || 'get_certificate_info (ITW)';
--
  l_itw_override_flag varchar2(1);
  l_itw_description   varchar2(300);
  l_wtm_override_flag varchar2(1);
  l_wtm_description   varchar2(300);
--
  l_dpnts t_dpnts;
  l_descriptions t_descriptions;
  l_housing_tbl t_housing_tbl;
--
begin
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  get_certificate_info(
    p_assignment_action_id     => p_assignment_action_id,
    p_assignment_id            => p_assignment_id,
    p_action_sequence          => p_action_sequence,
    p_business_group_id        => p_business_group_id,
    p_effective_date           => p_effective_date,
    p_date_earned              => p_date_earned,
    p_itax_organization_id     => p_itax_organization_id,
    p_itax_category            => p_itax_category,
    p_itax_yea_category        => p_itax_yea_category,
    p_dpnt_ref_type            => p_dpnt_ref_type,
    p_dpnt_effective_date      => p_dpnt_effective_date,
    p_person_id                => p_person_id,
    p_sex                      => p_sex,
    p_date_of_birth            => p_date_of_birth,
    p_leaving_reason           => p_leaving_reason,
    p_last_name_kanji          => p_last_name_kanji,
    p_last_name_kana           => p_last_name_kana,
    p_employment_category      => p_employment_category,
    p_magnetic_media_flag      => p_magnetic_media_flag,
    p_certificate_info         => p_certificate_info,
    p_submission_required_flag => p_submission_required_flag,
    p_prev_jobs                => p_prev_jobs,
    p_housing_tbl              => l_housing_tbl);
--
  hr_utility.set_location(c_proc, 20);
--
  if p_itax_yea_category = '0' then
  --
    hr_utility.set_location(c_proc, 21);
  --
    -- Derive withholding tax information by current employer.
  --
    get_withholding_tax_info(
      p_assignment_action_id => p_assignment_action_id,
      p_assignment_id        => p_assignment_id,
      p_action_sequence      => p_action_sequence,
      p_effective_date       => p_effective_date,
      p_itax_organization_id => p_itax_organization_id,
      p_itax_category        => p_itax_category,
      p_itax_yea_category    => p_itax_yea_category,
      p_withholding_tax_info => p_withholding_tax_info);
  --
  else
  --
    hr_utility.set_location(c_proc, 22);
  --
    -- For non-YEAed employees, current employer's payment with same tax category
    -- are shown in certificates. So just copy p_certificate_info to p_withholding_tax_info.
  --
    p_withholding_tax_info := p_certificate_info.tax_info;
  --
  end if;
--
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end get_certificate_info;
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
--
-- Wrapper function for Archive  (used this in PAYJPITW_ARCHIVE : gci_itw_arc)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_job_info            out nocopy t_prev_job_info,
  p_housing_info             out nocopy t_housing_info,
  p_withholding_tax_info     out nocopy t_tax_info,
  p_itw_description          out nocopy varchar2,
  p_itw_descriptions         out nocopy t_descriptions,
  p_wtm_description          out nocopy varchar2,
  p_wtm_descriptions         out nocopy t_descriptions)
is
--
  c_proc constant varchar2(61) := c_package || 'get_certificate_info (ARC)';
--
  l_dpnts t_dpnts;
  l_housing_tbl t_housing_tbl;
  l_prev_jobs t_prev_jobs;
--
  l_itw_override_flag varchar2(1);
  l_wtm_override_flag varchar2(1);
--
begin
--
  hr_utility.set_location('Entering: ' || c_proc, 10);
--
  get_basic_certificate_info(
    p_assignment_action_id     => p_assignment_action_id,
    p_assignment_id            => p_assignment_id,
    p_action_sequence          => p_action_sequence,
    p_business_group_id        => p_business_group_id,
    p_effective_date           => p_effective_date,
    p_date_earned              => p_date_earned,
    p_itax_organization_id     => p_itax_organization_id,
    p_itax_category            => p_itax_category,
    p_itax_yea_category        => p_itax_yea_category,
    p_dpnt_ref_type            => p_dpnt_ref_type,
    p_dpnt_effective_date      => p_dpnt_effective_date,
    p_person_id                => p_person_id,
    p_sex                      => p_sex,
    p_date_of_birth            => p_date_of_birth,
    p_leaving_reason           => p_leaving_reason,
    p_employment_category      => p_employment_category,
    p_certificate_info         => p_certificate_info,
    p_submission_required_flag => p_submission_required_flag,
    p_prev_jobs                => l_prev_jobs,
    p_housing_tbl              => l_housing_tbl);
--
  hr_utility.set_location(c_proc, 20);
--
  p_housing_info := convert_housing_tbl(
                     p_effective_date,
                     p_itax_yea_category,
                     p_certificate_info,
                     l_housing_tbl);
--
  p_prev_job_info := convert_prev_jobs(l_prev_jobs);
--
  hr_utility.set_location(c_proc, 30);
--
  if p_itax_yea_category = '0' then
  --
  -- Derive withholding tax information by current employer.
  --
    get_withholding_tax_info(
      p_assignment_action_id => p_assignment_action_id,
      p_assignment_id        => p_assignment_id,
      p_action_sequence      => p_action_sequence,
      p_effective_date       => p_effective_date,
      p_itax_organization_id => p_itax_organization_id,
      p_itax_category        => p_itax_category,
      p_itax_yea_category    => p_itax_yea_category,
      p_withholding_tax_info => p_withholding_tax_info);
  --
  else
  --
  -- For non-YEAed employees, current employer's payment with same tax category
  -- are shown in certificates. So just copy p_certificate_info to p_withholding_tax_info.
  --
    p_withholding_tax_info := p_certificate_info.tax_info;
  --
  end if;
--
  hr_utility.set_location(c_proc, 40);
--
  -- Get Description information
  -- When description on element entry is marked as "Override",
  -- subsequent description will be replaced by this.
--
  get_ee_description(
    p_assignment_id     => p_assignment_id,
    p_business_group_id => p_business_group_id,
    p_effective_date    => p_date_earned,
    p_itw_override_flag => l_itw_override_flag,
    p_itw_description   => p_itw_description,
    p_wtm_override_flag => l_wtm_override_flag,
    p_wtm_description   => p_wtm_description);
--
  hr_utility.set_location(c_proc, 50);
--
  if l_itw_override_flag = 'N' or l_wtm_override_flag = 'N' then
  --
    hr_utility.set_location(c_proc, 51);
  --
    get_dpnts(
      p_dpnt_ref_type       => p_dpnt_ref_type,
      p_assignment_id       => p_assignment_id,
      p_itax_category       => p_itax_category,
      p_dpnt_effective_date => p_dpnt_effective_date,
      p_person_id           => p_person_id,
      p_effective_date      => p_effective_date,
      p_sex                 => p_sex,
      p_dpnts               => l_dpnts);
  --
    hr_utility.set_location(c_proc, 52);
  --
    if l_itw_override_flag = 'N' then
    --
      hr_utility.set_location(c_proc, 53);
    --
      get_descriptions(
        p_assignment_id     => p_assignment_id,
        p_person_id         => p_person_id,
        p_effective_date    => p_effective_date,
        p_itax_yea_category => p_itax_yea_category,
        p_certificate_info  => p_certificate_info,
        p_last_name_kanji   => p_last_name_kanji,
        p_last_name_kana    => p_last_name_kana,
        p_dpnts             => l_dpnts,
        p_prev_jobs         => l_prev_jobs,
        p_housing_tbl       => l_housing_tbl,
        p_report_type       => ITW,
        p_descriptions      => p_itw_descriptions);
    --
    end if;
  --
    if l_wtm_override_flag = 'N' then
    --
      hr_utility.set_location(c_proc, 54);
    --
      get_descriptions(
        p_assignment_id     => p_assignment_id,
        p_person_id         => p_person_id,
        p_effective_date    => p_effective_date,
        p_itax_yea_category => p_itax_yea_category,
        p_certificate_info  => p_certificate_info,
        p_last_name_kanji   => p_last_name_kanji,
        p_last_name_kana    => p_last_name_kana,
        p_dpnts             => l_dpnts,
        p_prev_jobs         => l_prev_jobs,
        p_housing_tbl       => l_housing_tbl,
        p_report_type       => WTM,
        p_descriptions      => p_wtm_descriptions);
    --
    end if;
  --
    hr_utility.set_location(c_proc, 55);
  --
  end if;
--
  hr_utility.set_location('Leaving: ' || c_proc, 100);
--
end get_certificate_info;
--
-- Wrapper function for wage ledger (used this in PAYJPWL_ARCHIVE : gci_wl_arc)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_job_info            out nocopy t_prev_job_info,
  p_withholding_tax_info     out nocopy t_tax_info,
  p_itw_description          out nocopy varchar2,
  p_itw_descriptions         out nocopy t_descriptions,
  p_wtm_description          out nocopy varchar2,
  p_wtm_descriptions         out nocopy t_descriptions)
is
--
  l_housing_info t_housing_info;
--
begin
--
  get_certificate_info(
    p_assignment_action_id     => p_assignment_action_id,
    p_assignment_id            => p_assignment_id,
    p_action_sequence          => p_action_sequence,
    p_business_group_id        => p_business_group_id,
    p_effective_date           => p_effective_date,
    p_date_earned              => p_date_earned,
    p_itax_organization_id     => p_itax_organization_id,
    p_itax_category            => p_itax_category,
    p_itax_yea_category        => p_itax_yea_category,
    p_dpnt_ref_type            => p_dpnt_ref_type,
    p_dpnt_effective_date      => p_dpnt_effective_date,
    p_person_id                => p_person_id,
    p_sex                      => p_sex,
    p_date_of_birth            => p_date_of_birth,
    p_leaving_reason           => p_leaving_reason,
    p_last_name_kanji          => p_last_name_kanji,
    p_last_name_kana           => p_last_name_kana,
    p_employment_category      => p_employment_category,
    p_certificate_info         => p_certificate_info,
    p_submission_required_flag => p_submission_required_flag,
    p_prev_job_info            => p_prev_job_info,
    p_housing_info             => l_housing_info,
    p_withholding_tax_info     => p_withholding_tax_info,
    p_itw_description          => p_itw_description,
    p_itw_descriptions         => p_itw_descriptions,
    p_wtm_description          => p_wtm_description,
    p_wtm_descriptions         => p_wtm_descriptions);
--
end get_certificate_info;
--
-- |-------------------------------------------------------------------|
-- |---------------------< set_valid_term_taxable_amt >----------------|
-- |-------------------------------------------------------------------|
procedure set_valid_term_taxable_amt(
  p_valid_term_taxable_amt in number)
is
begin
--
  pay_jp_wic_pkg.g_valid_term_taxable_amt := p_valid_term_taxable_amt;
--
end set_valid_term_taxable_amt;
--
-- |-------------------------------------------------------------------|
-- |----------------------< spr_term_valid >---------------------------|
-- |-------------------------------------------------------------------|
-- Use in Summary Payment Report and ITW with Term Validation
function spr_term_valid(
  p_assignment_action_id  in number,
  p_assignment_id         in number,
  p_action_sequence       in number,
  p_effective_date        in date,
  p_itax_organization_id  in number,
  p_itax_category         in varchar2,
  p_itax_yea_category     in varchar2,
  p_employment_category   in varchar2,
  p_termination_date      in date,
  p_certificate_info      in t_certificate_info default null)
return number
is
--
  l_result number := 0; /* 0 (false) or 1 (true) */
--
	l_certificate_info         t_certificate_info;
  l_submission_required_flag varchar2(1);
--
begin
--
  if p_termination_date is not null then
  --
    if pay_jp_wic_pkg.g_valid_term_taxable_amt is null then
      hr_utility.set_message(800,'HR_7914_CHECK_FMT_NUMBER');
      hr_utility.set_message_token('ARG_NAME','pay_jp_wic_pkg.g_valid_term_taxable_amt');
      hr_utility.set_message_token('ARG_VALUE','pay_jp_wic_pkg.g_valid_term_taxable_amt');
      hr_utility.raise_error;
    end if;
  --
    if p_certificate_info.tax_info.taxable_income is null then
    --
      get_basic_certificate_info(
        p_assignment_action_id     => p_assignment_action_id,
        p_assignment_id            => p_assignment_id,
        p_action_sequence          => p_action_sequence,
        p_effective_date           => p_effective_date,
        p_itax_organization_id     => p_itax_organization_id,
        p_itax_category            => p_itax_category,
        p_itax_yea_category        => p_itax_yea_category,
        p_employment_category      => p_employment_category,
        p_certificate_info         => l_certificate_info.tax_info,
        p_submission_required_flag => l_submission_required_flag);
    --
    else
    --
      l_certificate_info := p_certificate_info;
    --
    end if;
  --
    if l_certificate_info.tax_info.taxable_income <= pay_jp_wic_pkg.g_valid_term_taxable_amt then
    --
      l_result := 1;
    --
    end if;
  --
  end if;
--
return l_result;
--
end spr_term_valid;
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
--
-- Wrapper for ITW with Term Validation (used this in PAYJPITW : gci_itw)
--
procedure get_certificate_info(
  p_assignment_action_id     in number,
  p_assignment_id            in number,
  p_action_sequence          in number,
  p_business_group_id        in number,
  p_effective_date           in date,
  p_date_earned              in date,
  p_itax_organization_id     in number,
  p_itax_category            in varchar2,
  p_itax_yea_category        in varchar2,
  p_dpnt_ref_type            in varchar2,
  p_dpnt_effective_date      in date,
  p_person_id                in number,
  p_sex                      in varchar2,
  p_date_of_birth            in date,
  p_leaving_reason           in varchar2,
  p_last_name_kanji          in varchar2,
  p_last_name_kana           in varchar2,
  p_employment_category      in varchar2,
  p_magnetic_media_flag      in varchar2 default 'N',
  p_termination_date         in date,
  p_certificate_info         out nocopy t_certificate_info,
  p_submission_required_flag out nocopy varchar2,
  p_prev_jobs                out nocopy t_prev_jobs,
  p_withholding_tax_info     out nocopy t_tax_info,
  p_spr_term_valid           out nocopy number)
is
begin
--
  get_certificate_info(
    p_assignment_action_id     => p_assignment_action_id,
    p_assignment_id            => p_assignment_id,
    p_action_sequence          => p_action_sequence,
    p_business_group_id        => p_business_group_id,
    p_effective_date           => p_effective_date,
    p_date_earned              => p_date_earned,
    p_itax_organization_id     => p_itax_organization_id,
    p_itax_category            => p_itax_category,
    p_itax_yea_category        => p_itax_yea_category,
    p_dpnt_ref_type            => p_dpnt_ref_type,
    p_dpnt_effective_date      => p_dpnt_effective_date,
    p_person_id                => p_person_id,
    p_sex                      => p_sex,
    p_date_of_birth            => p_date_of_birth,
    p_leaving_reason           => p_leaving_reason,
    p_last_name_kanji          => p_last_name_kanji,
    p_last_name_kana           => p_last_name_kana,
    p_employment_category      => p_employment_category,
    p_magnetic_media_flag      => p_magnetic_media_flag,
    p_certificate_info         => p_certificate_info,
    p_submission_required_flag => p_submission_required_flag,
    p_prev_jobs                => p_prev_jobs,
    p_withholding_tax_info     => p_withholding_tax_info);
--
  p_spr_term_valid := spr_term_valid(
                        p_assignment_action_id  => p_assignment_action_id,
                        p_assignment_id         => p_assignment_id,
                        p_action_sequence       => p_action_sequence,
                        p_effective_date        => p_effective_date,
                        p_itax_organization_id  => p_itax_organization_id,
                        p_itax_category         => p_itax_category,
                        p_itax_yea_category     => p_itax_yea_category,
                        p_employment_category   => p_employment_category,
                        p_termination_date      => p_termination_date,
                        p_certificate_info      => p_certificate_info);
--
end get_certificate_info;
--
-- |-------------------------------------------------------------------|
-- |---------------------< get_certificate_info >----------------------|
-- |-------------------------------------------------------------------|
-- For debugging purpose. NEVER USE THIS in your product code.
procedure get_certificate_info(
	p_assignment_action_id		in number,
	p_magnetic_media_flag		in varchar2 default 'N',
	p_certificate_info		out nocopy t_certificate_info,
	p_submission_required_flag	out nocopy varchar2,
	p_prev_jobs			out nocopy t_prev_jobs,
	p_withholding_tax_info		out nocopy t_tax_info)
is
	cursor csr_assact is
		select	wic.assignment_id,
			wic.action_sequence,
			wic.business_group_id,
			wic.effective_date,
			wic.date_earned,
			wic.itax_organization_id,
			wic.itax_category,
			wic.itax_yea_category,
			nvl(nvl(pay.prl_information1, hoi.org_information2), 'CTR_EE')	DPNT_REF_TYPE,
			nvl(fnd_date.canonical_to_date(pay_core_utils.get_parameter('ITAX_DPNT_EFFECTIVE_DATE', wic.legislative_parameters)),
				wic.effective_date)					DPNT_EFFECTIVE_DATE,
			per.person_id,
			per.sex,
			per.date_of_birth,
			wic.leaving_reason,
			per.per_information18	LAST_NAME_KANJI,
			per.last_name		LAST_NAME_KANA,
			wic.employment_category
		from	per_all_people_f		per,
			hr_organization_information	hoi,
			pay_all_payrolls_f		pay,
			/* Use V2 instead of V for debugging. */
			pay_jp_wic_assacts_v2		wic
		where	wic.assignment_action_id = p_assignment_action_id
		and	pay.payroll_id = wic.payroll_id
		and	wic.date_earned
			between pay.effective_start_date and pay.effective_end_date
		and	hoi.organization_id(+) = wic.business_group_id
		and	hoi.org_information_context(+) = 'JP_BUSINESS_GROUP_INFO'
		and	per.person_id = wic.person_id
		and	wic.effective_date
			between per.effective_start_date and per.effective_end_date;
begin
	for l_rec in csr_assact loop
		get_certificate_info(
			p_assignment_action_id		=> p_assignment_action_id,
			p_assignment_id			=> l_rec.assignment_id,
			p_action_sequence		=> l_rec.action_sequence,
			p_business_group_id		=> l_rec.business_group_id,
			p_effective_date		=> l_rec.effective_date,
			p_date_earned			=> l_rec.date_earned,
			p_itax_organization_id		=> l_rec.itax_organization_id,
			p_itax_category			=> l_rec.itax_category,
			p_itax_yea_category		=> l_rec.itax_yea_category,
			p_dpnt_ref_type			=> l_rec.dpnt_ref_type,
			p_dpnt_effective_date		=> l_rec.dpnt_effective_date,
			p_person_id			=> l_rec.person_id,
			p_sex				=> l_rec.sex,
			p_date_of_birth			=> l_rec.date_of_birth,
			p_leaving_reason		=> l_rec.leaving_reason,
			p_last_name_kanji		=> l_rec.last_name_kanji,
			p_last_name_kana		=> l_rec.last_name_kana,
			p_employment_category		=> l_rec.employment_category,
			p_magnetic_media_flag		=> p_magnetic_media_flag,
			p_certificate_info		=> p_certificate_info,
			p_submission_required_flag	=> p_submission_required_flag,
			p_prev_jobs			=> p_prev_jobs,
			p_withholding_tax_info		=> p_withholding_tax_info);
	end loop;
end get_certificate_info;
-- |-------------------------------------------------------------------|
-- |----------------------< ass_set_validation >-----------------------|
-- |-------------------------------------------------------------------|
FUNCTION ass_set_validation(
	p_assignment_set_id	in NUMBER,
	p_assignment_id		in NUMBER,
	p_effective_date	in DATE) RETURN NUMBER
IS
BEGIN
	--
	-- Bug.4863756
	-- Now this is just wrapper of hr_jp_ast_utility_pkg.assignment_set_validate.
	--
	if hr_jp_ast_utility_pkg.assignment_set_validate(
		p_assignment_set_id,
		p_assignment_id,
		p_effective_date,
		'N') = 'Y' then
		return 1;
	else
		return 0;
	end if;
END ass_set_validation;
--
-- Package Initialization
--
begin
	g_prompt_kanji.yen				:= fnd_message.get_string('PAY', 'PAY_JP_JBA_MONEY_SUFFIX');
	g_prompt_kanji.fixed_rate_tax_reduction		:= fnd_message.get_string('PAY', 'PAY_JP_YEA_FIXED_RATE');
	g_prompt_kanji.national_pens_prem		:= fnd_message.get_string('PAY', 'PAY_JP_NATIONAL_PENSION');
	g_prompt_kanji.prev_job				:= fnd_message.get_string('PAY', 'PAY_JP_PREVIOUS_EMPLOYMENT');
	g_prompt_kanji.taxable_income			:= fnd_message.get_string('PAY', 'PAY_JP_SALARY');
	g_prompt_kanji.si_prem				:= fnd_message.get_string('PAY', 'PAY_JP_TRANS_SI');
	g_prompt_kanji.mutual_aid_prem			:= fnd_message.get_string('PAY', 'PAY_JP_WITHIN');
	g_prompt_kanji.itax				:= fnd_message.get_string('PAY', 'PAY_JP_TAX');
	g_prompt_kanji.terminated			:= fnd_message.get_string('PAY', 'PAY_JP_TERM');
	g_prompt_kanji.housing_tax_reduction		:= fnd_message.get_string('PAY', 'PAY_JP_HOUSING_DEDUCTION');
	g_prompt_kanji.residence_date			:= fnd_message.get_string('PAY', 'PAY_JP_RES_START_DATE');
	g_prompt_kanji.unclaimed_housing_tax_reduct	:= fnd_message.get_string('PAY', 'PAY_JP_DEDUCTIONS_NOT_TAKEN');
	-- 2007/06/07
	g_prompt_kanji.housing_tax_reduction_long	:= fnd_message.get_string('PAY', 'PAY_JP_HOUSING_DEDUCTION_LONG');
	g_prompt_kanji.total_housing_tax_reduction	:= fnd_message.get_string('PAY', 'PAY_JP_AVAILABLE_AMOUNT');
	--
	g_prompt_kanji.disaster_tax_reduction		:= fnd_message.get_string('PAY', 'PAY_JP_GRACE_TAX_AMOUNT');
	g_prompt_kanji.husband				:= fnd_message.get_string('PAY', 'PAY_JP_HUSBAND');
	g_prompt_kanji.wife				:= fnd_message.get_string('PAY', 'PAY_JP_WIFE');
	g_prompt_kanji.date_format			:=	'FMYY"' || fnd_message.get_string('PER', 'HR_JP_YY') ||
								'"MM"' || fnd_message.get_string('PER', 'HR_JP_MM') ||
								'"DD"' || fnd_message.get_string('PER', 'HR_JP_DD') || '"';
	g_prompt_kanji.other				:= fnd_message.get_string('PAY', 'PAY_JP_TRANS_OTHER');
	g_prompt_kanji.count				:= fnd_message.get_string('PAY', 'PAY_JP_TRANS_COUNT');
	--
	g_prompt_kana.yen				:= fnd_message.get_string('PAY', 'PAY_JP_JBA_MONEY_SUFFIX_KANA');
	g_prompt_kana.fixed_rate_tax_reduction		:= fnd_message.get_string('PAY', 'PAY_JP_YEA_FIXED_RATE_KANA');
	g_prompt_kana.national_pens_prem		:= fnd_message.get_string('PAY', 'PAY_JP_NATIONAL_PENSION_KANA');
	g_prompt_kana.prev_job				:= fnd_message.get_string('PAY', 'PAY_JP_PREV_EMPLOYMENT_KANA');
	g_prompt_kana.taxable_income			:= fnd_message.get_string('PAY', 'PAY_JP_TRANS_SALARY_KANA');
	g_prompt_kana.si_prem				:= fnd_message.get_string('PAY', 'PAY_JP_TRANS_SI_KANA');
	g_prompt_kana.mutual_aid_prem			:= fnd_message.get_string('PAY', 'PAY_JP_WITHIN_KANA');
	g_prompt_kana.itax				:= fnd_message.get_string('PAY', 'PAY_JP_TAX_KANA');
	g_prompt_kana.terminated			:= fnd_message.get_string('PAY', 'PAY_JP_TRANS_TERM_KANA');
	g_prompt_kana.housing_tax_reduction		:= fnd_message.get_string('PAY', 'PAY_JP_HOUSING_DEDUCTION_KANA');
	g_prompt_kana.residence_date			:= fnd_message.get_string('PAY', 'PAY_JP_RES_START_DATE_KANA');
	g_prompt_kana.unclaimed_housing_tax_reduct	:= fnd_message.get_string('PAY', 'PAY_JP_DCT_NOT_TAKEN_KANA');
	-- 2007/06/07
	g_prompt_kana.housing_tax_reduction_long	:= fnd_message.get_string('PAY', 'PAY_JP_HOUSING_DCT_LONG_KANA');
	g_prompt_kana.total_housing_tax_reduction	:= fnd_message.get_string('PAY', 'PAY_JP_AVAILABLE_AMOUNT_KANA');
	--
	g_prompt_kana.disaster_tax_reduction		:= fnd_message.get_string('PAY', 'PAY_JP_GRACE_TAX_AMOUNT_KANA');
	g_prompt_kana.husband				:= fnd_message.get_string('PAY', 'PAY_JP_HUSBAND_KANA');
	g_prompt_kana.wife				:= fnd_message.get_string('PAY', 'PAY_JP_WIFE_KANA');
	g_prompt_kana.date_format			:=	'FMYY"' || fnd_message.get_string('PAY', 'PAY_JP_TRANS_YY_KANA') ||
								'"MM"' || fnd_message.get_string('PAY', 'PAY_JP_TRANS_MM_KANA') ||
								'"DD"' || fnd_message.get_string('PAY', 'PAY_JP_TRANS_DD_KANA') || '"';
	g_prompt_kana.other				:= fnd_message.get_string('PAY', 'PAY_JP_TRANS_OTHER_KANA');
	g_prompt_kana.count				:= fnd_message.get_string('PAY', 'PAY_JP_TRANS_COUNT_KANA');
	--
--
  -- since april in 2009
  g_prompt_kanji.housing_loan_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_ITW');
  g_prompt_kanji.housing_res_date_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_RD_ITW');
  g_prompt_kanji.housing_loan_balance_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_BAL_ITW');
  g_prompt_kanji.housing_loan_type_wtm := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_TYPE_WTM');
  g_prompt_kanji.housing_count_wtm := fnd_message.get_string('PAY','PAY_JP_WIC_P_CNT_WTM');
  g_prompt_kanji.housing_res_date_wtm := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_RD_WTM');
  g_prompt_kanji.housing_loan_balance_wtm := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_BAL_WTM');
  g_prompt_kanji.np_prem_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_NP_ITW');
  g_prompt_kanji.housing_loan_type_gen_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_GEN_ITW');
  g_prompt_kanji.housing_loan_type_ext_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_EXT_ITW');
  g_prompt_kanji.housing_loan_type_etq_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_ETQ_ITW');
  --
  g_prompt_kana.housing_loan_itw  := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_ITW_K');
  g_prompt_kana.housing_res_date_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_RD_ITW_K');
  g_prompt_kana.housing_loan_balance_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_BAL_ITW_K');
  g_prompt_kana.housing_loan_type_wtm := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_TYPE_WTM_K');
  g_prompt_kana.housing_count_wtm := fnd_message.get_string('PAY','PAY_JP_WIC_P_CNT_WTM_K');
  g_prompt_kana.housing_res_date_wtm := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_RD_WTM_K');
  g_prompt_kana.housing_loan_balance_wtm := fnd_message.get_string('PAY','PAY_JP_WIC_P_HLD_BAL_WTM_K');
  g_prompt_kana.np_prem_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_NP_ITW_K');
  g_prompt_kana.housing_loan_type_gen_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_GEN_ITW_K');
  g_prompt_kana.housing_loan_type_ext_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_EXT_ITW_K');
  g_prompt_kana.housing_loan_type_etq_itw := fnd_message.get_string('PAY','PAY_JP_WIC_P_ETQ_ITW_K');
--
	g_taxable_income_exempt_elm.element_type_id		:= hr_jp_id_pkg.element_type_id('YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT', null, 'JP');
	g_taxable_income_exempt_elm.net_taxable_income_iv	:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'Pay Value');
	g_taxable_income_exempt_elm.taxable_income_iv		:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'PAY_AMT');
	g_taxable_income_exempt_elm.prev_taxable_income_iv	:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'PREV_EMP_INCOME');
	g_taxable_income_exempt_elm.prev_si_prem_iv		:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'PREV_EMP_SI_PREM');
--	g_taxable_income_exempt_elm.prev_itax_iv		:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'PREV_EMP_ITX');
	g_taxable_income_exempt_elm.taxable_income_adj_iv	:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'ADJ_EMP_INCOME');
	g_taxable_income_exempt_elm.si_prem_adj_iv		:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'ADJ_SI_PREM');
	g_taxable_income_exempt_elm.mutual_aid_prem_adj_iv	:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'ADJ_SMALL_COMPANY_MUTUAL_AID_PREM');
	g_taxable_income_exempt_elm.itax_adj_iv			:= hr_jp_id_pkg.input_value_id(g_taxable_income_exempt_elm.element_type_id, 'ADJ_ITX');
	--
	g_net_annual_itax_elm.element_type_id			:= hr_jp_id_pkg.element_type_id('YEA_NET_ANNUAL_TAX', null, 'JP');
	g_net_annual_itax_elm.net_annual_itax_iv		:= hr_jp_id_pkg.input_value_id(g_net_annual_itax_elm.element_type_id, 'Pay Value');
	g_net_annual_itax_elm.housing_tax_reduction_iv		:= hr_jp_id_pkg.input_value_id(g_net_annual_itax_elm.element_type_id, 'HOUSING_LOAN_TAX_CREDIT');
	g_net_annual_itax_elm.net_housing_tax_reduction_iv	:= hr_jp_id_pkg.input_value_id(g_net_annual_itax_elm.element_type_id, 'ACTUAL_HOUSING_LOAN_TAX_CREDIT');
	g_net_annual_itax_elm.fixed_rate_tax_reduction_iv	:= hr_jp_id_pkg.input_value_id(g_net_annual_itax_elm.element_type_id, 'YEA_PROPORTIONAL_DCT');
	--
	g_total_income_exempt_asg_run				:= hr_jp_id_pkg.defined_balance_id('B_YEA_INCOME_EXM',
									'_ASG_RUN', null, 'JP');
	g_itax_adjustment_asg_ytd				:= hr_jp_id_pkg.defined_balance_id('B_YEA_TAX_PAY',
									'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01', null, 'JP');
--	g_itax_asg_ytd						:= hr_jp_id_pkg.defined_balance_id('B_YEA_WITHHOLD_ITX',
--									'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01', null, 'JP');
	--
	g_ins_prem_exempt_elm.element_type_id			:= hr_jp_id_pkg.element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_RSLT', null, 'JP');
	g_ins_prem_exempt_elm.si_prem_iv			:= hr_jp_id_pkg.input_value_id(g_ins_prem_exempt_elm.element_type_id, 'SI_PREM_DCT');
	g_ins_prem_exempt_elm.mutual_aid_prem_iv		:= hr_jp_id_pkg.input_value_id(g_ins_prem_exempt_elm.element_type_id, 'SMALL_COMPANY_MUTUAL_AID_PREM');
	g_ins_prem_exempt_elm.li_prem_exempt_iv			:= hr_jp_id_pkg.input_value_id(g_ins_prem_exempt_elm.element_type_id, 'LIFE_INS_PREM_EXM');
	g_ins_prem_exempt_elm.pp_prem_iv			:= hr_jp_id_pkg.input_value_id(g_ins_prem_exempt_elm.element_type_id, 'INDIVIDUAL_PENSION_PREM');
	g_ins_prem_exempt_elm.ai_prem_exempt_iv			:= hr_jp_id_pkg.input_value_id(g_ins_prem_exempt_elm.element_type_id, 'NONLIFE_INS_PREM_EXM');
	g_ins_prem_exempt_elm.long_ai_prem_iv			:= hr_jp_id_pkg.input_value_id(g_ins_prem_exempt_elm.element_type_id, 'LONG_TERM_NONLIFE_INS_PREM');
	g_ins_prem_exempt_elm.spouse_sp_exempt_iv		:= hr_jp_id_pkg.input_value_id(g_ins_prem_exempt_elm.element_type_id, 'SPOUSE_SP_EXM');
	g_ins_prem_exempt_elm.spouse_net_taxable_income_iv	:= hr_jp_id_pkg.input_value_id(g_ins_prem_exempt_elm.element_type_id, 'SPOUSE_INCOME');
	--
	g_dep_exempt_elm.element_type_id		:= hr_jp_id_pkg.element_type_id('YEA_DEP_EXM_PROC', null, 'JP');
	g_dep_exempt_elm.disabled_iv			:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'DISABLE_TYPE');
	g_dep_exempt_elm.aged_iv			:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'ELDER_TYPE');
	g_dep_exempt_elm.widow_iv			:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'WIDOW_TYPE');
	g_dep_exempt_elm.working_student_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'WORKING_STUDENT_TYPE');
	g_dep_exempt_elm.spouse_type_iv			:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'SPOUSE_TYPE');
	g_dep_exempt_elm.spouse_disabled_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'SPOUSE_DISABLE_TYPE');
	g_dep_exempt_elm.num_deps_iv			:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'NUM_OF_DEP');
	g_dep_exempt_elm.num_ageds_iv			:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'NUM_OF_ELDER_DEP');
	g_dep_exempt_elm.num_aged_parents_lt_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'NUM_OF_ELDER_PARENT_LT');
	g_dep_exempt_elm.num_specifieds_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'NUM_OF_SPECIFIC_DEP');
	g_dep_exempt_elm.num_disableds_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'NUM_OF_GEN_DISABLED');
	g_dep_exempt_elm.num_svr_disableds_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'NUM_OF_SEV_DISABLED');
	g_dep_exempt_elm.num_svr_disableds_lt_iv	:= hr_jp_id_pkg.input_value_id(g_dep_exempt_elm.element_type_id, 'NUM_OF_SEV_DISABLED_LT');
	--
	g_dep_exempt_result_elm.element_type_id		:= hr_jp_id_pkg.element_type_id('YEA_DEP_EXM_TYPE_RSLT', null, 'JP');
	g_dep_exempt_result_elm.disabled_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'DISABLE_TYPE');
	g_dep_exempt_result_elm.aged_iv			:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'ELDER_TYPE');
	g_dep_exempt_result_elm.widow_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'WIDOW_TYPE');
	g_dep_exempt_result_elm.working_student_iv	:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'WORKING_STUDENT_TYPE');
	g_dep_exempt_result_elm.spouse_type_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'SPOUSE_TYPE');
	g_dep_exempt_result_elm.spouse_disabled_iv	:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'SPOUSE_DISABLE_TYPE');
	g_dep_exempt_result_elm.num_deps_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'NUM_OF_DEP');
	g_dep_exempt_result_elm.num_ageds_iv		:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'NUM_OF_ELDER_DEP');
	g_dep_exempt_result_elm.num_aged_parents_lt_iv	:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'NUM_OF_ELDER_PARENT_LT');
	g_dep_exempt_result_elm.num_specifieds_iv	:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'NUM_OF_SPECIFIC_DEP');
	g_dep_exempt_result_elm.num_disableds_iv	:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'NUM_OF_GEN_DISABLED');
	g_dep_exempt_result_elm.num_svr_disableds_iv	:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'NUM_OF_SEV_DISABLED');
	g_dep_exempt_result_elm.num_svr_disableds_lt_iv	:= hr_jp_id_pkg.input_value_id(g_dep_exempt_result_elm.element_type_id, 'NUM_OF_SEV_DISABLED_LT');
	--
/*
	g_description_elm.element_type_id		:= hr_jp_id_pkg.element_type_id('YEA_WITHHOLD_TAX_REPORT_INFO', null, 'JP');
	g_description_elm.override_flag_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'OVERRIDE_FLAG');
	g_description_elm.description_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD');
	g_description_elm.mag_override_flag_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'OVERRIDE_FOR_FILE_FLAG');
	g_description_elm.mag_description_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD_FOR_FILE');
	--Added for ITAX REPORT Enhancement
	g_description_elm.description_2_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD2');
	g_description_elm.description_3_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD3');
	g_description_elm.description_4_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD4');
	g_description_elm.description_5_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD5');
	g_description_elm.mag_description_2_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD2_FOR_FILE');
	g_description_elm.mag_description_3_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD3_FOR_FILE');
	g_description_elm.mag_description_4_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD4_FOR_FILE');
	g_description_elm.mag_description_5_iv		:= hr_jp_id_pkg.input_value_id(g_description_elm.element_type_id, 'DESC_FIELD5_FOR_FILE');
*/
	g_desc_element_type_id				:= hr_jp_id_pkg.element_type_id('YEA_WITHHOLD_TAX_REPORT_INFO', null, 'JP');
	--
	g_itax_info_elm.element_type_id			:= hr_jp_id_pkg.element_type_id('COM_ITX_INFO', null, 'JP');
	g_itax_info_elm.foreigner_flag_iv		:= hr_jp_id_pkg.input_value_id(g_itax_info_elm.element_type_id, 'FOREIGNER_FLAG');
	--
	g_prev_job_elm					:= hr_jp_id_pkg.element_type_id('YEA_PREV_EMP_INFO', null, 'JP');
	--
	g_housing_tax_reduction_elm.element_type_id	:= hr_jp_id_pkg.element_type_id('YEA_HOUSING_LOAN_TAX_CREDIT', null, 'JP');
	g_housing_tax_reduction_elm.residence_date_iv	:= hr_jp_id_pkg.input_value_id(g_housing_tax_reduction_elm.element_type_id, 'RES_START_DATE');
	--
	g_yea_ins_prem_sp_exm_info_elm.element_type_id	:= hr_jp_id_pkg.element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_INFO',null,'JP');
	g_yea_ins_prem_sp_exm_info_elm.national_pens_prem_iv := hr_jp_id_pkg.input_value_id(g_yea_ins_prem_sp_exm_info_elm.element_type_id,'NATIONAL_PENSION_PREM');
	--
--
  g_housing_loan_info_elm.element_type_id := hr_jp_id_pkg.element_type_id('YEA_HOUSING_LOAN_INFO',null,'JP');
  g_housing_loan_info_elm.res_date_iv     := hr_jp_id_pkg.input_value_id(g_housing_loan_info_elm.element_type_id,'RES_DATE');
  g_housing_loan_info_elm.loan_type_iv    := hr_jp_id_pkg.input_value_id(g_housing_loan_info_elm.element_type_id,'LOAN_TYPE');
  g_housing_loan_info_elm.loan_balance_iv := hr_jp_id_pkg.input_value_id(g_housing_loan_info_elm.element_type_id,'LOAN_BALANCE');
--
--	hr_utility.trace_on('F', 'TTAGAWA');
end pay_jp_wic_pkg;

/
