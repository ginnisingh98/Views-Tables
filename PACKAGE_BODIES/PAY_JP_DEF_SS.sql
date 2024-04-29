--------------------------------------------------------
--  DDL for Package Body PAY_JP_DEF_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_DEF_SS" as
/* $Header: pyjpdefs.pkb 120.5.12010000.2 2009/10/14 13:34:51 keyazawa ship $ */
--
-- Constants
--
c_package			constant varchar2(31) := 'pay_jp_def_ss.';
c_def_elm			constant number := hr_jp_id_pkg.element_type_id('YEA_DEP_EXM_PROC', null, 'JP');
c_disability_type_iv		constant varchar2(30) := hr_jp_id_pkg.input_value_id(c_def_elm, 'DISABLE_TYPE');
c_aged_type_iv			constant varchar2(30) := hr_jp_id_pkg.input_value_id(c_def_elm, 'ELDER_TYPE');
c_widow_type_iv			constant varchar2(30) := hr_jp_id_pkg.input_value_id(c_def_elm, 'WIDOW_TYPE');
c_working_student_type_iv	constant varchar2(30) := hr_jp_id_pkg.input_value_id(c_def_elm, 'WORKING_STUDENT_TYPE');
c_spouse_dep_type_iv		constant varchar2(30) := hr_jp_id_pkg.input_value_id(c_def_elm, 'SPOUSE_TYPE');
c_spouse_disability_type_iv	constant varchar2(30) := hr_jp_id_pkg.input_value_id(c_def_elm, 'SPOUSE_DISABLE_TYPE');
c_num_deps_iv			constant number := hr_jp_id_pkg.input_value_id(c_def_elm, 'NUM_OF_DEP');
c_num_ageds_iv			constant number := hr_jp_id_pkg.input_value_id(c_def_elm, 'NUM_OF_ELDER_DEP');
c_num_aged_parents_iv		constant number := hr_jp_id_pkg.input_value_id(c_def_elm, 'NUM_OF_ELDER_PARENT_LT');
c_num_specifieds_iv		constant number := hr_jp_id_pkg.input_value_id(c_def_elm, 'NUM_OF_SPECIFIC_DEP');
c_num_disableds_iv		constant number := hr_jp_id_pkg.input_value_id(c_def_elm, 'NUM_OF_GEN_DISABLED');
c_num_svr_disableds_iv		constant number := hr_jp_id_pkg.input_value_id(c_def_elm, 'NUM_OF_SEV_DISABLED');
c_num_svr_disableds_lt_iv	constant number := hr_jp_id_pkg.input_value_id(c_def_elm, 'NUM_OF_SEV_DISABLED_LT');
-- |---------------------------------------------------------------------------|
-- |-----------------------< ee_datetrack_update_mode >------------------------|
-- |---------------------------------------------------------------------------|
function ee_datetrack_update_mode(
	p_element_entry_id		in number,
	p_effective_start_date		in date,
	p_effective_end_date		in date,
	p_effective_date		in date) return varchar2
is
	l_datetrack_mode	varchar2(30);
	l_exists		varchar2(1);
	cursor csr_future_exists is
		select	'Y'
		from	dual
		where	exists(
				select	null
				from	pay_element_entries_f
				where	element_entry_id = p_element_entry_id
				and	effective_start_date = p_effective_end_date + 1);
begin
	if p_effective_start_date = p_effective_date then
		l_datetrack_mode := 'CORRECTION';
	else
		open csr_future_exists;
		fetch csr_future_exists into l_exists;
		if csr_future_exists%notfound then
			l_datetrack_mode := 'UPDATE';
		else
			l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
		end if;
	end if;
	--
	return l_datetrack_mode;
end ee_datetrack_update_mode;
-- |---------------------------------------------------------------------------|
-- |-----------------------< cei_datetrack_update_mode >-----------------------|
-- |---------------------------------------------------------------------------|
function cei_datetrack_update_mode(
	p_contact_extra_info_id		in number,
	p_effective_start_date		in date,
	p_effective_end_date		in date,
	p_effective_date		in date) return varchar2
is
	l_datetrack_mode	varchar2(30);
	l_exists		varchar2(1);
	cursor csr_future_exists is
		select	'Y'
		from	dual
		where	exists(
				select	null
				from	per_contact_extra_info_f
				where	contact_extra_info_id = p_contact_extra_info_id
				and	effective_start_date = p_effective_end_date + 1);
begin
	if p_effective_start_date = p_effective_date then
		l_datetrack_mode := 'CORRECTION';
	else
		open csr_future_exists;
		fetch csr_future_exists into l_exists;
		if csr_future_exists%notfound then
			l_datetrack_mode := 'UPDATE';
		else
			l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
		end if;
	end if;
	--
	return l_datetrack_mode;
end cei_datetrack_update_mode;
-- |---------------------------------------------------------------------------|
-- |-----------------------< cei_datetrack_delete_mode >-----------------------|
-- |---------------------------------------------------------------------------|
function cei_datetrack_delete_mode(
	p_contact_extra_info_id		in number,
	p_effective_start_date		in date,
	p_effective_end_date		in date,
	p_effective_date		in date) return varchar2
is
	l_datetrack_mode	varchar2(30);
	l_exists		varchar2(1);
	cursor csr_past_exists is
		select	'Y'
		from	dual
		where	exists(
				select	null
				from	per_contact_extra_info_f
				where	contact_extra_info_id = p_contact_extra_info_id
				and	effective_end_date = p_effective_start_date - 1);
begin
	if p_effective_start_date = p_effective_date then
		open csr_past_exists;
		fetch csr_past_exists into l_exists;
		if csr_past_exists%notfound then
			l_datetrack_mode := 'ZAP';
		else
			l_datetrack_mode := 'DELETE';
		end if;
	else
		l_datetrack_mode := 'DELETE';
	end if;
	--
	return l_datetrack_mode;
end cei_datetrack_delete_mode;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< full_name >-------------------------------|
-- |---------------------------------------------------------------------------|
function full_name(
	p_person_id			in number,
	p_effective_date		in date) return varchar2
is
	l_full_name		per_all_people_f.full_name%type;
	cursor csr_full_name is
		select	trim(per_information18 || ' ' || per_information19)
		from	per_all_people_f
		where	person_id = p_person_id
		and	p_effective_date
			between effective_start_date and effective_end_date;
	cursor csr_full_name2 is
		select	trim(per_information18 || ' ' || per_information19)
		from	per_all_people_f
		where	person_id = p_person_id
		and	start_date = effective_start_date;
begin
	if p_person_id is not null then
		open csr_full_name;
		fetch csr_full_name into l_full_name;
		if csr_full_name%notfound then
			open csr_full_name2;
			fetch csr_full_name2 into l_full_name;
			close csr_full_name2;
		end if;
		close csr_full_name;
	end if;
	--
	return l_full_name;
end full_name;
-- |---------------------------------------------------------------------------|
-- |----------------------------< insert_session >-----------------------------|
-- |---------------------------------------------------------------------------|
procedure insert_session(p_effective_date in date)
is
	l_rowid		rowid;
	cursor csr_session is
		select	rowid
		from	fnd_sessions
		where	session_id = userenv('sessionid')
		for update nowait;
begin
	open csr_session;
	fetch csr_session into l_rowid;
	if csr_session%notfound then
		insert into fnd_sessions(
			session_id,
			effective_date)
		values(	userenv('sessionid'),
			p_effective_date);
	else
		update	fnd_sessions
		set	effective_date = p_effective_date
		where	rowid = l_rowid;
	end if;
	close csr_session;
end insert_session;
-- |---------------------------------------------------------------------------|
-- |----------------------------< delete_session >-----------------------------|
-- |---------------------------------------------------------------------------|
procedure delete_session
is
begin
	delete
	from	fnd_sessions
	where	session_id = userenv('sessionid');
end delete_session;
-- |---------------------------------------------------------------------------|
-- |--------------------------------< changed >--------------------------------|
-- |---------------------------------------------------------------------------|
function changed(
	value1		in varchar2,
	value2		in varchar2) return boolean
is
begin
	if nvl(value1, hr_api.g_varchar2) <> nvl(value2, hr_api.g_varchar2) then
		return true;
	else
		return false;
	end if;
end changed;
--
function changed(
	value1		in number,
	value2		in number) return boolean
is
begin
	if nvl(value1, hr_api.g_number) <> nvl(value2, hr_api.g_number) then
		return true;
	else
		return false;
	end if;
end changed;
--
function changed(
	value1		in date,
	value2		in date) return boolean
is
begin
	if nvl(value1, hr_api.g_date) <> nvl(value2, hr_api.g_date) then
		return true;
	else
		return false;
	end if;
end changed;
-- |---------------------------------------------------------------------------|
-- |------------------------< check_submission_period >------------------------|
-- |---------------------------------------------------------------------------|
function check_submission_period(p_action_information_id in number) return date
is
	cursor csr_pact is
		select	submission_period_status,
			submission_start_date,
			submission_end_date
		from	pay_jp_def_pact_v	pact,
			pay_assignment_actions	paa,
			pay_jp_def_assact_v	assact
		where	assact.action_information_id = p_action_information_id
		and	paa.assignment_action_id = assact.assignment_action_id
		and	pact.payroll_action_id = paa.payroll_action_id;
	l_pact_rec	csr_pact%rowtype;
	l_sysdate	date;
begin
	open csr_pact;
	fetch csr_pact into l_pact_rec;
	close csr_pact;
	--
	if l_pact_rec.submission_period_status = 'C' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_PERIOD_CLOSED');
		fnd_message.raise_error;
	end if;
	--
	l_sysdate := sysdate;
	--
	if l_sysdate < nvl(l_pact_rec.submission_start_date, l_sysdate) then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_PERIOD_NOT_STARTED');
		fnd_message.raise_error;
	end if;
	--
	if l_sysdate > nvl(l_pact_rec.submission_end_date, l_sysdate) then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_PERIOD_EXPIRED');
		fnd_message.raise_error;
	end if;
	--
	return l_sysdate;
end check_submission_period;
--
procedure check_submission_period(p_action_information_id in number)
is
	l_submission_date	date;
begin
	l_submission_date := check_submission_period(p_action_information_id);
end check_submission_period;
-- |---------------------------------------------------------------------------|
-- |------------------------------< get_sqlerrm >------------------------------|
-- |---------------------------------------------------------------------------|
function get_sqlerrm return varchar2
is
begin
	if sqlcode = -20001 then
		declare
			l_sqlerrm	varchar2(2000) := fnd_message.get;
		begin
			if l_sqlerrm is not null then
				return l_sqlerrm;
			else
				return sqlerrm;
			end if;
		end;
	else
		return sqlerrm;
	end if;
end get_sqlerrm;
--
--
--
--
--
-- |---------------------------------------------------------------------------|
-- |----------------------------< transfer_entry >-----------------------------|
-- |---------------------------------------------------------------------------|
procedure transfer_entry(
  p_rec in out nocopy pay_jp_def_entry_v%rowtype,
  p_business_group_id in number)
is
	c_proc			constant varchar2(61) := c_package || '.transfer_entry';
	l_esd			date;
	l_eed			date;
	l_warning		boolean;
	l_element_link_id	number;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace('status : ' || p_rec.status);
	--
	if p_rec.status = 'I' then
		l_element_link_id := hr_entry_api.get_link(
					p_assignment_id		=> p_rec.assignment_id,
					p_element_type_id	=> c_def_elm,
					p_session_date		=> p_rec.effective_date);
		--
		pay_element_entry_api.create_element_entry(
			p_validate			=> false,
			p_effective_date		=> p_rec.effective_date,
			p_business_group_id		=> p_business_group_id,
			p_assignment_id			=> p_rec.assignment_id,
			p_element_link_id		=> l_element_link_id,
			p_entry_type			=> 'E',
			p_input_value_id1		=> c_disability_type_iv,
			p_input_value_id2		=> c_aged_type_iv,
			p_input_value_id3		=> c_widow_type_iv,
			p_input_value_id4		=> c_working_student_type_iv,
			p_input_value_id5		=> c_spouse_dep_type_iv,
			p_input_value_id6		=> c_spouse_disability_type_iv,
			p_input_value_id7		=> c_num_deps_iv,
			p_input_value_id8		=> c_num_ageds_iv,
			p_input_value_id9		=> c_num_aged_parents_iv,
			p_input_value_id10		=> c_num_specifieds_iv,
			p_input_value_id11		=> c_num_disableds_iv,
			p_input_value_id12		=> c_num_svr_disableds_iv,
			p_input_value_id13		=> c_num_svr_disableds_lt_iv,
			p_entry_value1			=> p_rec.disability_type,
			p_entry_value2			=> p_rec.aged_type,
			p_entry_value3			=> p_rec.widow_type,
			p_entry_value4			=> p_rec.working_student_type,
			p_entry_value5			=> p_rec.spouse_dep_type,
			p_entry_value6			=> p_rec.spouse_disability_type,
			p_entry_value7			=> fnd_number.number_to_canonical(p_rec.num_deps),
			p_entry_value8			=> fnd_number.number_to_canonical(p_rec.num_ageds),
			p_entry_value9			=> fnd_number.number_to_canonical(p_rec.num_aged_parents_lt),
			p_entry_value10			=> fnd_number.number_to_canonical(p_rec.num_specifieds),
			p_entry_value11			=> fnd_number.number_to_canonical(p_rec.num_disableds),
			p_entry_value12			=> fnd_number.number_to_canonical(p_rec.num_svr_disableds),
			p_entry_value13			=> fnd_number.number_to_canonical(p_rec.num_svr_disableds_lt),
			p_element_entry_id		=> p_rec.element_entry_id,
			p_object_version_number		=> p_rec.ee_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed,
			p_create_warning		=> l_warning);
		--
		pay_jp_def_api.update_entry(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_ELEMENT_ENTRY_ID		=> p_rec.element_entry_id,
			P_EE_OBJECT_VERSION_NUMBER	=> p_rec.ee_object_version_number);
	elsif p_rec.status = 'Q' then
		if changed(p_rec.disability_type	, p_rec.disability_type_o)
		or changed(p_rec.aged_type		, p_rec.aged_type_o)
		or changed(p_rec.widow_type		, p_rec.widow_type_o)
		or changed(p_rec.working_student_type	, p_rec.working_student_type_o)
		or changed(p_rec.spouse_dep_type	, p_rec.spouse_dep_type_o)
		or changed(p_rec.spouse_disability_type	, p_rec.spouse_disability_type_o)
		or changed(p_rec.num_deps		, p_rec.num_deps_o)
		or changed(p_rec.num_ageds		, p_rec.num_ageds_o)
		or changed(p_rec.num_aged_parents_lt	, p_rec.num_aged_parents_lt_o)
		or changed(p_rec.num_specifieds		, p_rec.num_specifieds_o)
		or changed(p_rec.num_disableds		, p_rec.num_disableds_o)
		or changed(p_rec.num_svr_disableds	, p_rec.num_svr_disableds_o)
		or changed(p_rec.num_svr_disableds_lt	, p_rec.num_svr_disableds_lt_o) then
			pay_element_entry_api.update_element_entry(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_business_group_id		=>  p_business_group_id,
				p_datetrack_update_mode		=> p_rec.datetrack_update_mode,
				p_element_entry_id		=> p_rec.element_entry_id,
				p_object_version_number		=> p_rec.ee_object_version_number,
				p_input_value_id1		=> c_disability_type_iv,
				p_input_value_id2		=> c_aged_type_iv,
				p_input_value_id3		=> c_widow_type_iv,
				p_input_value_id4		=> c_working_student_type_iv,
				p_input_value_id5		=> c_spouse_dep_type_iv,
				p_input_value_id6		=> c_spouse_disability_type_iv,
				p_input_value_id7		=> c_num_deps_iv,
				p_input_value_id8		=> c_num_ageds_iv,
				p_input_value_id9		=> c_num_aged_parents_iv,
				p_input_value_id10		=> c_num_specifieds_iv,
				p_input_value_id11		=> c_num_disableds_iv,
				p_input_value_id12		=> c_num_svr_disableds_iv,
				p_input_value_id13		=> c_num_svr_disableds_lt_iv,
				p_entry_value1			=> p_rec.disability_type,
				p_entry_value2			=> p_rec.aged_type,
				p_entry_value3			=> p_rec.widow_type,
				p_entry_value4			=> p_rec.working_student_type,
				p_entry_value5			=> p_rec.spouse_dep_type,
				p_entry_value6			=> p_rec.spouse_disability_type,
				p_entry_value7			=> fnd_number.number_to_canonical(p_rec.num_deps),
				p_entry_value8			=> fnd_number.number_to_canonical(p_rec.num_ageds),
				p_entry_value9			=> fnd_number.number_to_canonical(p_rec.num_aged_parents_lt),
				p_entry_value10			=> fnd_number.number_to_canonical(p_rec.num_specifieds),
				p_entry_value11			=> fnd_number.number_to_canonical(p_rec.num_disableds),
				p_entry_value12			=> fnd_number.number_to_canonical(p_rec.num_svr_disableds),
				p_entry_value13			=> fnd_number.number_to_canonical(p_rec.num_svr_disableds_lt),
				-- Aged Type can be defaulted to '0' after 2005/01/01
				-- even user enterable is "No".
				p_override_user_ent_chk		=> 'Y',
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed,
				p_update_warning		=> l_warning);
			--
			p_rec.status := 'U';
			--
			pay_jp_def_api.update_entry(
				P_VALIDATE			=> false,
				P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
				P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
				P_STATUS			=> p_rec.status,
				P_EE_OBJECT_VERSION_NUMBER	=> p_rec.ee_object_version_number);
		end if;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end transfer_entry;
-- |---------------------------------------------------------------------------|
-- |----------------------------< rollback_entry >-----------------------------|
-- |---------------------------------------------------------------------------|
procedure rollback_entry(
  p_rec in out nocopy pay_jp_def_entry_v%rowtype,
  p_business_group_id in number)
is
	c_proc			constant varchar2(61) := c_package || '.rollback_entry';
	l_esd			date;
	l_eed			date;
	l_warning		boolean;
	l_vsd			date;
	l_ved			date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace('status : ' || p_rec.status);
	--
	if p_rec.status = 'I' then
		pay_element_entry_api.delete_element_entry(
			p_validate			=> false,
			p_effective_date		=> p_rec.effective_date,
			p_datetrack_delete_mode		=> 'ZAP',
			p_element_entry_id		=> p_rec.element_entry_id,
			p_object_version_number		=> p_rec.ee_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed,
			p_delete_warning		=> l_warning);
		--
		p_rec.element_entry_id		:= null;
		p_rec.ee_object_version_number	:= null;
		--
		pay_jp_def_api.update_entry(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_ELEMENT_ENTRY_ID		=> p_rec.element_entry_id,
			P_EE_OBJECT_VERSION_NUMBER	=> p_rec.ee_object_version_number);
	elsif p_rec.status = 'U' then
		if p_rec.datetrack_update_mode = 'CORRECTION' then
			pay_element_entry_api.update_element_entry(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_business_group_id		=> p_business_group_id,
				p_datetrack_update_mode		=> p_rec.datetrack_update_mode,
				p_element_entry_id		=> p_rec.element_entry_id,
				p_object_version_number		=> p_rec.ee_object_version_number,
				p_input_value_id1		=> c_disability_type_iv,
				p_input_value_id2		=> c_aged_type_iv,
				p_input_value_id3		=> c_widow_type_iv,
				p_input_value_id4		=> c_working_student_type_iv,
				p_input_value_id5		=> c_spouse_dep_type_iv,
				p_input_value_id6		=> c_spouse_disability_type_iv,
				p_input_value_id7		=> c_num_deps_iv,
				p_input_value_id8		=> c_num_ageds_iv,
				p_input_value_id9		=> c_num_aged_parents_iv,
				p_input_value_id10		=> c_num_specifieds_iv,
				p_input_value_id11		=> c_num_disableds_iv,
				p_input_value_id12		=> c_num_svr_disableds_iv,
				p_input_value_id13		=> c_num_svr_disableds_lt_iv,
				p_entry_value1			=> p_rec.disability_type_o,
				p_entry_value2			=> p_rec.aged_type_o,
				p_entry_value3			=> p_rec.widow_type_o,
				p_entry_value4			=> p_rec.working_student_type_o,
				p_entry_value5			=> p_rec.spouse_dep_type_o,
				p_entry_value6			=> p_rec.spouse_disability_type_o,
				p_entry_value7			=> fnd_number.number_to_canonical(p_rec.num_deps_o),
				p_entry_value8			=> fnd_number.number_to_canonical(p_rec.num_ageds_o),
				p_entry_value9			=> fnd_number.number_to_canonical(p_rec.num_aged_parents_lt_o),
				p_entry_value10			=> fnd_number.number_to_canonical(p_rec.num_specifieds_o),
				p_entry_value11			=> fnd_number.number_to_canonical(p_rec.num_disableds_o),
				p_entry_value12			=> fnd_number.number_to_canonical(p_rec.num_svr_disableds_o),
				p_entry_value13			=> fnd_number.number_to_canonical(p_rec.num_svr_disableds_lt_o),
				-- Aged Type could be defaulted to '0' after 2005/01/01
				-- even user enterable is "No".
				p_override_user_ent_chk		=> 'Y',
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed,
				p_update_warning		=> l_warning);
		else
			--
			-- For UPDATE or UPDATE_CHANGE_INSERT, OVN for previous record
			-- should be current OVN - 1. See API for more details.
			-- !!!!!
			-- This does not work after expired, because OVN of latest record is updated.
			-- At first, lock the current record. If locked successfully,
			-- derive OVN of previous record.
			--
			pay_ele_shd.lck(
				p_effective_date	=> p_rec.effective_date,
				p_datetrack_mode	=> 'CORRECTION',
				p_element_entry_id	=> p_rec.element_entry_id,
				p_object_version_number	=> p_rec.ee_object_version_number,
				p_validation_start_date	=> l_vsd,
				p_validation_end_date	=> l_ved);
			--
			select	object_version_number
			into	p_rec.ee_object_version_number
			from	pay_element_entries_f
			where	element_entry_id = p_rec.element_entry_id
			and	effective_end_date = p_rec.effective_date - 1;
			--
			pay_element_entry_api.delete_element_entry(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date - 1,
				p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
				p_element_entry_id		=> p_rec.element_entry_id,
				p_object_version_number		=> p_rec.ee_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed,
				p_delete_warning		=> l_warning);
		end if;
		--
		p_rec.status := 'Q';
		--
		pay_jp_def_api.update_entry(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_STATUS			=> p_rec.status,
			P_EE_OBJECT_VERSION_NUMBER	=> p_rec.ee_object_version_number);
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end rollback_entry;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< transfer_dep >------------------------------|
-- |---------------------------------------------------------------------------|
procedure transfer_dep(p_rec in out nocopy pay_jp_def_dep_v%rowtype)
is
	c_proc			constant varchar2(61) := c_package || '.transfer_dep';
	l_esd			date;
	l_eed			date;
	l_effective_date	date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace('status : ' || p_rec.status);
	--
	if p_rec.status = 'I' then
		hr_contact_extra_info_api.create_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_rec.effective_date,
			p_contact_relationship_id	=> p_rec.contact_relationship_id,
			p_information_type		=> 'JP_ITAX_DEPENDENT',
			p_cei_information_category	=> 'JP_ITAX_DEPENDENT',
			p_cei_information2		=> p_rec.occupation,
			p_cei_information3		=> fnd_number.number_to_canonical(p_rec.estimated_annual_income),
			p_cei_information4		=> fnd_date.date_to_canonical(p_rec.change_date),
			p_cei_information5		=> p_rec.change_reason,
			p_cei_information6		=> p_rec.disability_type,
			p_cei_information7		=> p_rec.disability_details,
			p_cei_information8		=> p_rec.dep_type,
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'Q' then
		if p_rec.change_date is not null
		or p_rec.change_reason is not null
		or changed(p_rec.dep_type		, p_rec.dep_type_o)
		or changed(p_rec.occupation		, p_rec.occupation_o)
		or changed(p_rec.estimated_annual_income, p_rec.estimated_annual_income_o)
		or changed(p_rec.disability_type	, p_rec.disability_type_o)
		or changed(p_rec.disability_details	, p_rec.disability_details_o) then
			hr_contact_extra_info_api.update_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_datetrack_update_mode		=> p_rec.datetrack_update_mode,
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_cei_information4		=> fnd_date.date_to_canonical(p_rec.change_date),
				p_cei_information5		=> p_rec.change_reason,
				p_cei_information8		=> p_rec.dep_type,
				p_cei_information2		=> p_rec.occupation,
				p_cei_information3		=> fnd_number.number_to_canonical(p_rec.estimated_annual_income),
				p_cei_information6		=> p_rec.disability_type,
				p_cei_information7		=> p_rec.disability_details,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
			--
			p_rec.status := 'U';
			--
			pay_jp_def_api.update_dep(
				P_VALIDATE			=> false,
				P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
				P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
				P_STATUS			=> p_rec.status,
				P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
		end if;
	elsif p_rec.status = 'D' then
		if p_rec.datetrack_delete_mode = 'ZAP' then
			l_effective_date := p_rec.effective_date;
		else
			l_effective_date := p_rec.effective_date - 1;
		end if;
		--
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> l_effective_date,
			p_datetrack_delete_mode		=> p_rec.datetrack_delete_mode,
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		if p_rec.datetrack_delete_mode <> 'ZAP' then
			pay_jp_def_api.update_dep(
				P_VALIDATE			=> false,
				P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
				P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
				P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
		end if;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end transfer_dep;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< rollback_dep >------------------------------|
-- |---------------------------------------------------------------------------|
procedure rollback_dep(p_rec in out nocopy pay_jp_def_dep_v%rowtype)
is
	c_proc			constant varchar2(61) := c_package || '.rollback_dep';
	l_esd			date;
	l_eed			date;
	l_vsd			date;
	l_ved			date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace('status : ' || p_rec.status);
	--
	if p_rec.status = 'I' then
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_rec.effective_date,
			p_datetrack_delete_mode		=> 'ZAP',
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		p_rec.contact_extra_info_id	:= null;
		p_rec.cei_object_version_number	:= null;
		--
		pay_jp_def_api.update_dep(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'U' then
		if p_rec.datetrack_update_mode = 'CORRECTION' then
			hr_contact_extra_info_api.update_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_datetrack_update_mode		=> p_rec.datetrack_update_mode,
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				-- Rollback change_date/change_reason is not supported for CORRECTION mode.
				p_cei_information8		=> p_rec.dep_type_o,
				p_cei_information2		=> p_rec.occupation_o,
				p_cei_information3		=> fnd_number.number_to_canonical(p_rec.estimated_annual_income_o),
				p_cei_information6		=> p_rec.disability_type_o,
				p_cei_information7		=> p_rec.disability_details_o,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		else
			--
			-- For UPDATE or UPDATE_CHANGE_INSERT, OVN for previous record
			-- should be current OVN - 1. See API for more details.
			-- !!!!!
			-- This does not work after expired, because OVN of latest record is updated.
			-- At first, lock the current record. If locked successfully,
			-- derive OVN of previous record.
			--
			per_rei_shd.lck(
				p_effective_date	=> p_rec.effective_date,
				p_datetrack_mode	=> 'CORRECTION',
				p_contact_extra_info_id	=> p_rec.contact_extra_info_id,
				p_object_version_number	=> p_rec.cei_object_version_number,
				p_validation_start_date	=> l_vsd,
				p_validation_end_date	=> l_ved);
			--
			select	object_version_number
			into	p_rec.cei_object_version_number
			from	per_contact_extra_info_f
			where	contact_extra_info_id = p_rec.contact_extra_info_id
			and	effective_end_date = p_rec.effective_date - 1;
			--
			hr_contact_extra_info_api.delete_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date - 1,
				p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		end if;
		--
		p_rec.status := 'Q';
		--
		pay_jp_def_api.update_dep(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_STATUS			=> p_rec.status,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'D' then
		if p_rec.datetrack_delete_mode = 'ZAP' then
			--
			-- Note EFFECTIVE_END_DATE/change_date/change_reason cannot be rollbacked
			-- for ZAP case.
			--
			hr_contact_extra_info_api.create_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_contact_relationship_id	=> p_rec.contact_relationship_id,
				p_information_type		=> 'JP_ITAX_DEPENDENT',
				p_cei_information_category	=> 'JP_ITAX_DEPENDENT',
				p_cei_information2		=> p_rec.occupation_o,
				p_cei_information3		=> fnd_number.number_to_canonical(p_rec.estimated_annual_income_o),
				p_cei_information6		=> p_rec.disability_type_o,
				p_cei_information7		=> p_rec.disability_details_o,
				p_cei_information8		=> p_rec.dep_type_o,
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		else
			hr_contact_extra_info_api.delete_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date - 1,
				p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		end if;
		--
		pay_jp_def_api.update_dep(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end rollback_dep;
-- |---------------------------------------------------------------------------|
-- |----------------------------< transfer_dep_oe >----------------------------|
-- |---------------------------------------------------------------------------|
procedure transfer_dep_oe(p_rec in out nocopy pay_jp_def_dep_oe_v%rowtype)
is
	c_proc			constant varchar2(61) := c_package || '.transfer_dep_oe';
	l_esd			date;
	l_eed			date;
	l_effective_date	date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace('status : ' || p_rec.status);
	--
	if p_rec.status = 'I' then
		hr_contact_extra_info_api.create_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_rec.effective_date,
			p_contact_relationship_id	=> p_rec.contact_relationship_id,
			p_information_type		=> 'JP_ITAX_DEPENDENT_ON_OTHER_EMP',
			p_cei_information_category	=> 'JP_ITAX_DEPENDENT_ON_OTHER_EMP',
			p_cei_information1		=> p_rec.occupation,
			p_cei_information2		=> fnd_date.date_to_canonical(p_rec.change_date),
			p_cei_information3		=> p_rec.change_reason,
			p_cei_information5		=> fnd_number.number_to_canonical(p_rec.oe_contact_relationship_id),
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep_oe(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'Q' then
		if p_rec.change_date is not null
		or p_rec.change_reason is not null
		or changed(p_rec.occupation			, p_rec.occupation_o)
		or changed(p_rec.oe_contact_relationship_id	, p_rec.oe_contact_relationship_id_o) then
			hr_contact_extra_info_api.update_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_datetrack_update_mode		=> p_rec.datetrack_update_mode,
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_cei_information2		=> fnd_date.date_to_canonical(p_rec.change_date),
				p_cei_information3		=> p_rec.change_reason,
				p_cei_information1		=> p_rec.occupation,
				p_cei_information5		=> fnd_number.number_to_canonical(p_rec.oe_contact_relationship_id),
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
			--
			p_rec.status := 'U';
			--
			pay_jp_def_api.update_dep_oe(
				P_VALIDATE			=> false,
				P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
				P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
				P_STATUS			=> p_rec.status,
				P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
		end if;
	elsif p_rec.status = 'D' then
		if p_rec.datetrack_delete_mode = 'ZAP' then
			l_effective_date := p_rec.effective_date;
		else
			l_effective_date := p_rec.effective_date - 1;
		end if;
		--
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> l_effective_date,
			p_datetrack_delete_mode		=> p_rec.datetrack_delete_mode,
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		if p_rec.datetrack_delete_mode <> 'ZAP' then
			pay_jp_def_api.update_dep(
				P_VALIDATE			=> false,
				P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
				P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
				P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
		end if;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end transfer_dep_oe;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< rollback_dep >------------------------------|
-- |---------------------------------------------------------------------------|
procedure rollback_dep_oe(p_rec in out nocopy pay_jp_def_dep_oe_v%rowtype)
is
	c_proc			constant varchar2(61) := c_package || '.rollback_dep_oe';
	l_esd			date;
	l_eed			date;
	l_vsd			date;
	l_ved			date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace('status : ' || p_rec.status);
	--
	if p_rec.status = 'I' then
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_rec.effective_date,
			p_datetrack_delete_mode		=> 'ZAP',
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		p_rec.contact_extra_info_id	:= null;
		p_rec.cei_object_version_number	:= null;
		--
		pay_jp_def_api.update_dep_oe(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'U' then
		if p_rec.datetrack_update_mode = 'CORRECTION' then
			hr_contact_extra_info_api.update_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_datetrack_update_mode		=> p_rec.datetrack_update_mode,
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				-- Rollback change_date/change_reason is not supported for CORRECTION mode.
				p_cei_information1		=> p_rec.occupation_o,
				p_cei_information5		=> fnd_number.number_to_canonical(p_rec.oe_contact_relationship_id_o),
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		else
			--
			-- For UPDATE or UPDATE_CHANGE_INSERT, OVN for previous record
			-- should be current OVN - 1. See API for more details.
			-- !!!!!
			-- This does not work after expired, because OVN of latest record is updated.
			-- At first, lock the current record. If locked successfully,
			-- derive OVN of previous record.
			--
			per_rei_shd.lck(
				p_effective_date	=> p_rec.effective_date,
				p_datetrack_mode	=> 'CORRECTION',
				p_contact_extra_info_id	=> p_rec.contact_extra_info_id,
				p_object_version_number	=> p_rec.cei_object_version_number,
				p_validation_start_date	=> l_vsd,
				p_validation_end_date	=> l_ved);
			--
			select	object_version_number
			into	p_rec.cei_object_version_number
			from	per_contact_extra_info_f
			where	contact_extra_info_id = p_rec.contact_extra_info_id
			and	effective_end_date = p_rec.effective_date - 1;
			--
			hr_contact_extra_info_api.delete_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date - 1,
				p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		end if;
		--
		p_rec.status := 'Q';
		--
		pay_jp_def_api.update_dep_oe(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_STATUS			=> p_rec.status,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'D' then
		if p_rec.datetrack_delete_mode = 'ZAP' then
			--
			-- Note EFFECTIVE_END_DATE/change_date/change_reason cannot be rollbacked
			-- for ZAP case.
			--
			hr_contact_extra_info_api.create_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_contact_relationship_id	=> p_rec.contact_relationship_id,
				p_information_type		=> 'JP_ITAX_DEPENDENT_ON_OTHER_EMP',
				p_cei_information_category	=> 'JP_ITAX_DEPENDENT_ON_OTHER_EMP',
				p_cei_information1		=> p_rec.occupation_o,
				p_cei_information5		=> fnd_number.number_to_canonical(p_rec.oe_contact_relationship_id_o),
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		else
			hr_contact_extra_info_api.delete_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date - 1,
				p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		end if;
		--
		pay_jp_def_api.update_dep_oe(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end rollback_dep_oe;
-- |---------------------------------------------------------------------------|
-- |----------------------------< transfer_dep_os >----------------------------|
-- |---------------------------------------------------------------------------|
procedure transfer_dep_os(p_rec in out nocopy pay_jp_def_dep_os_v%rowtype)
is
	c_proc			constant varchar2(61) := c_package || '.transfer_dep_os';
	l_esd			date;
	l_eed			date;
	l_effective_date	date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace('status : ' || p_rec.status);
	--
	if p_rec.status = 'I' then
		hr_contact_extra_info_api.create_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_rec.effective_date,
			p_contact_relationship_id	=> p_rec.contact_relationship_id,
			p_information_type		=> 'JP_ITAX_DEPENDENT_ON_OTHER_PAY',
			p_cei_information_category	=> 'JP_ITAX_DEPENDENT_ON_OTHER_PAY',
			p_cei_information1		=> p_rec.occupation,
			p_cei_information2		=> p_rec.os_salary_payer_name,
			p_cei_information3		=> p_rec.os_salary_payer_address,
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep_os(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'Q' then
		if changed(p_rec.occupation		, p_rec.occupation_o)
		or changed(p_rec.os_salary_payer_name	, p_rec.os_salary_payer_name_o)
		or changed(p_rec.os_salary_payer_address, p_rec.os_salary_payer_address_o) then
			p_rec.status := 'U';
			--
			hr_contact_extra_info_api.update_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_datetrack_update_mode		=> p_rec.datetrack_update_mode,
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_cei_information1		=> p_rec.occupation,
				p_cei_information2		=> p_rec.os_salary_payer_name,
				p_cei_information3		=> p_rec.os_salary_payer_address,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
			--
			p_rec.status := 'U';
			--
			pay_jp_def_api.update_dep_os(
				P_VALIDATE			=> false,
				P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
				P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
				P_STATUS			=> p_rec.status,
				P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
		end if;
	elsif p_rec.status = 'D' then
		if p_rec.datetrack_delete_mode = 'ZAP' then
			l_effective_date := p_rec.effective_date;
		else
			l_effective_date := p_rec.effective_date - 1;
		end if;
		--
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> l_effective_date,
			p_datetrack_delete_mode		=> p_rec.datetrack_delete_mode,
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		if p_rec.datetrack_delete_mode <> 'ZAP' then
			pay_jp_def_api.update_dep(
				P_VALIDATE			=> false,
				P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
				P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
				P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
		end if;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end transfer_dep_os;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< rollback_dep >------------------------------|
-- |---------------------------------------------------------------------------|
procedure rollback_dep_os(p_rec in out nocopy pay_jp_def_dep_os_v%rowtype)
is
	c_proc			constant varchar2(61) := c_package || '.rollback_dep_os';
	l_esd			date;
	l_eed			date;
	l_vsd			date;
	l_ved			date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	hr_utility.trace('status : ' || p_rec.status);
	--
	if p_rec.status = 'I' then
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_rec.effective_date,
			p_datetrack_delete_mode		=> 'ZAP',
			p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
			p_object_version_number		=> p_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		p_rec.contact_extra_info_id	:= null;
		p_rec.cei_object_version_number	:= null;
		--
		pay_jp_def_api.update_dep_os(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'U' then
		if p_rec.datetrack_update_mode = 'CORRECTION' then
			hr_contact_extra_info_api.update_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_datetrack_update_mode		=> p_rec.datetrack_update_mode,
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_cei_information1		=> p_rec.occupation_o,
				p_cei_information2		=> p_rec.os_salary_payer_name_o,
				p_cei_information3		=> p_rec.os_salary_payer_address_o,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		else
			--
			-- For UPDATE or UPDATE_CHANGE_INSERT, OVN for previous record
			-- should be current OVN - 1. See API for more details.
			-- !!!!!
			-- This does not work after expired, because OVN of latest record is updated.
			-- At first, lock the current record. If locked successfully,
			-- derive OVN of previous record.
			--
			per_rei_shd.lck(
				p_effective_date	=> p_rec.effective_date,
				p_datetrack_mode	=> 'CORRECTION',
				p_contact_extra_info_id	=> p_rec.contact_extra_info_id,
				p_object_version_number	=> p_rec.cei_object_version_number,
				p_validation_start_date	=> l_vsd,
				p_validation_end_date	=> l_ved);
			--
			select	object_version_number
			into	p_rec.cei_object_version_number
			from	per_contact_extra_info_f
			where	contact_extra_info_id = p_rec.contact_extra_info_id
			and	effective_end_date = p_rec.effective_date - 1;
			--
			hr_contact_extra_info_api.delete_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date - 1,
				p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		end if;
		--
		p_rec.status := 'Q';
		--
		pay_jp_def_api.update_dep_os(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_STATUS			=> p_rec.status,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	elsif p_rec.status = 'D' then
		if p_rec.datetrack_delete_mode = 'ZAP' then
			--
			-- Note EFFECTIVE_END_DATE/change_date/change_reason cannot be rollbacked
			-- for ZAP case.
			--
			hr_contact_extra_info_api.create_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date,
				p_contact_relationship_id	=> p_rec.contact_relationship_id,
				p_information_type		=> 'JP_ITAX_DEPENDENT_ON_OTHER_PAY',
				p_cei_information_category	=> 'JP_ITAX_DEPENDENT_ON_OTHER_PAY',
				p_cei_information1		=> p_rec.occupation_o,
				p_cei_information2		=> p_rec.os_salary_payer_name_o,
				p_cei_information3		=> p_rec.os_salary_payer_address_o,
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		else
			hr_contact_extra_info_api.delete_contact_extra_info(
				p_validate			=> false,
				p_effective_date		=> p_rec.effective_date - 1,
				p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
				p_contact_extra_info_id		=> p_rec.contact_extra_info_id,
				p_object_version_number		=> p_rec.cei_object_version_number,
				p_effective_start_date		=> l_esd,
				p_effective_end_date		=> l_eed);
		end if;
		--
		pay_jp_def_api.update_dep_os(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> p_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> p_rec.object_version_number,
			P_CONTACT_EXTRA_INFO_ID		=> p_rec.contact_extra_info_id,
			P_CEI_OBJECT_VERSION_NUMBER	=> p_rec.cei_object_version_number);
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end rollback_dep_os;
--
--
--
--
--
-- |---------------------------------------------------------------------------|
-- |------------------------------< lock_assact >------------------------------|
-- |---------------------------------------------------------------------------|
procedure lock_assact(
	p_action_information_id		in number,
	p_object_version_number		in number,
  p_business_group_id in out nocopy number,
	p_rec				out nocopy pay_jp_def_assact_v%rowtype)
is
--
  cursor csr_bg
  is
  select pa.business_group_id
  from   per_all_assignments_f pa
  where  pa.assignment_id = p_rec.assignment_id
  and    p_rec.effective_date
         between pa.effective_start_date and pa.effective_end_date;
--
begin
--
	select	*
	into	p_rec
	from	pay_jp_def_assact_v
	where	action_information_id = p_action_information_id
	for update nowait;
	--
	if p_rec.object_version_number <> p_object_version_number then
		fnd_message.set_name('FND', 'FND_RECORD_CHANGED_ERROR');
		fnd_message.raise_error;
	end if;
--
  -- assumption is that lock_assact work for same business group against multiple assignments
  -- because archive should processed for one session business group
  if ((p_business_group_id is null
     or p_business_group_id <> g_business_group_id)
  and p_rec.action_information_id is not null) then
  --
    open csr_bg;
    fetch csr_bg into p_business_group_id;
    close csr_bg;
  --
  end if;
--
exception
	when hr_api.object_locked then
		fnd_message.set_name('FND', 'FND_LOCK_RECORD_ERROR');
		fnd_message.raise_error;
	when no_data_found then
		fnd_message.set_name('FND', 'FND_RECORD_DELETED_ERROR');
		fnd_message.raise_error;
end lock_assact;
-- |---------------------------------------------------------------------------|
-- |--------------------------------< do_init >--------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_init(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number)
is
	c_proc			constant varchar2(61) := c_package || 'do_new';
	l_assact_rec		pay_jp_def_assact_v%rowtype;
	l_emp_rec		pay_jp_def_emp_v%rowtype;
	l_entry_rec		pay_jp_def_entry_v%rowtype;
	l_person_id		number;
	l_business_group_id	number;
	l_contact_person_id	number;
	l_action_information_id	number;
	l_object_version_number	number;
	--
	cursor csr_emp(
		p_assignment_id		number,
		p_effective_date	date) is
		select	per.person_id,
			per.business_group_id,
			per.last_name				last_name_kana,
			per.first_name				first_name_kana,
			per.per_information18			last_name,
			per.per_information19			first_name,
			per.date_of_birth,
			per.date_of_death,
			per.sex,
			decode(adrr.address_id, null, adrc.postal_code, adrr.postal_code)	postal_code,
			trim(substrb(decode(adrr.address_id, null,
				adrc.address_line1 || adrc.address_line2 || adrc.address_line3,
				adrr.address_line1 || adrr.address_line2 || adrr.address_line3), 1, 240))
												address
		from	per_addresses			adrc,
			per_addresses			adrr,
			per_all_people_f		per,
			per_all_assignments_f		asg
		where	asg.assignment_id = p_assignment_id
		and	p_effective_date
			between asg.effective_start_date and asg.effective_end_date
		and	per.person_id = asg.person_id
		and	p_effective_date
			between per.effective_start_date and per.effective_end_date
		and	adrr.person_id(+) = per.person_id
		and	adrr.address_type(+) = 'JP_R'
		and	p_effective_date
			between adrr.date_from(+) and nvl(adrr.date_to(+), p_effective_date)
		and	adrc.person_id(+) = per.person_id
		and	adrc.address_type(+) = 'JP_C'
		and	p_effective_date
			between adrc.date_from(+) and nvl(adrc.date_to(+), p_effective_date);
	cursor csr_household_head(
		p_person_id		number,
		p_effective_date	date) is
		select	ctr.contact_relationship_id,
			ctr.contact_person_id,
			ctr.contact_type
		from	per_contact_relationships	ctr
		where	ctr.person_id = p_person_id
		and	ctr.cont_information3 = 'Y'
		and	p_effective_date
			between nvl(ctr.date_start, p_effective_date) and nvl(ctr.date_end, p_effective_date);
	cursor csr_married_flag(
		p_person_id		number,
		p_effective_date	date) is
		select	'Y'
		from	dual
		where	exists(
				select	null
				from	per_contact_relationships	ctr
				where	ctr.person_id = p_person_id
				and	ctr.contact_type = 'S'
				and	p_effective_date
					between nvl(ctr.date_start, p_effective_date) and nvl(ctr.date_end, p_effective_date));
	--
	cursor csr_entry(
		p_business_group_id	number,
		p_assignment_id		number,
		p_effective_date	date) is
		select	pee.element_entry_id,
			pee.effective_start_date,
			pee.effective_end_date,
			pee.object_version_number,
			peev.input_value_id,
			peev.screen_entry_value
		from	pay_element_entry_values_f	peev,
			pay_element_entries_f		pee,
			pay_element_links_f		pel
		where	pel.element_type_id = c_def_elm
		and	pel.business_group_id + 0 = p_business_group_id
		and	p_effective_date
			between pel.effective_start_date and pel.effective_end_date
		and	pee.assignment_id = p_assignment_id
		and	pee.element_link_id = pel.element_link_id
		and	p_effective_date
			between pee.effective_start_date and pee.effective_end_date
		and	pee.entry_type = 'E'
		and	peev.element_entry_id = pee.element_entry_id
		and	peev.effective_start_date = pee.effective_start_date
		and	peev.effective_end_date = pee.effective_end_date;
	--
	cursor csr_dep(
		p_person_id		number,
		p_effective_date	date) is
		select	cei.contact_extra_info_id,
			cei.effective_start_date,
			cei.effective_end_date,
			cei.object_version_number,
			ctr.contact_relationship_id,
			per.last_name						LAST_NAME_KANA,
			per.first_name						FIRST_NAME_KANA,
			per.per_information18					LAST_NAME,
			per.per_information19					FIRST_NAME,
			ctr.contact_type,
			per.date_of_birth,
			per.date_of_death,
			trim(substrb(decode(adrr.address_id, null,
					adrc.address_line1 || adrc.address_line2 || adrc.address_line3,
					adrr.address_line1 || adrr.address_line2 || adrr.address_line3), 1, 240))
										ADDRESS,
			cei.cei_information8					DEP_TYPE,
			cei.cei_information2					OCCUPATION,
			fnd_number.canonical_to_number(cei.cei_information3)	ESTIMATED_ANNUAL_INCOME,
			cei.cei_information6					DISABILITY_TYPE,
			cei.cei_information7					DISABILITY_DETAILS
		from	per_all_people_f		per,
			per_addresses			adrc,
			per_addresses			adrr,
			per_contact_extra_info_f	cei,
			per_contact_relationships	ctr
		where	ctr.person_id = p_person_id
		and	cei.contact_relationship_id = ctr.contact_relationship_id
		and	cei.cei_information_category = 'JP_ITAX_DEPENDENT'
		and	p_effective_date
			between cei.effective_start_date and cei.effective_end_date
		and	adrr.person_id(+) = ctr.contact_person_id
		and	adrr.address_type(+) = 'JP_R'
		and	p_effective_date
			between adrr.date_from(+) and nvl(adrr.date_to(+), p_effective_date)
		and	adrc.person_id(+) = ctr.contact_person_id
		and	adrc.address_type(+) = 'JP_C'
		and	p_effective_date
			between adrc.date_from(+) and nvl(adrc.date_to(+), p_effective_date)
		and	per.person_id = ctr.contact_person_id
		/* CEI guarantees that person record exists as of effective_date */
		and	p_effective_date
			between per.effective_start_date and per.effective_end_date
		order by
			decode(ctr.contact_type, 'S', 1, 2),
			per.date_of_birth,
			per.full_name;
	cursor csr_dep_oe(
		p_person_id		number,
		p_effective_date	date) is
		select	cei.contact_extra_info_id,
			cei.effective_start_date,
			cei.effective_end_date,
			cei.object_version_number,
			ctr.contact_relationship_id,
			per.last_name						LAST_NAME_KANA,
			per.first_name						FIRST_NAME_KANA,
			per.per_information18					LAST_NAME,
			per.per_information19					FIRST_NAME,
			ctr.contact_type,
			per.date_of_birth,
			per.date_of_death,
			trim(substrb(decode(adrr.address_id, null,
					adrc.address_line1 || adrc.address_line2 || adrc.address_line3,
					adrr.address_line1 || adrr.address_line2 || adrr.address_line3), 1, 240))
										ADDRESS,
			cei.cei_information1					OCCUPATION,
			-- Do not return contact_relationship_id
			fnd_number.canonical_to_number(cei.cei_information5)	OE_CONTACT_RELATIONSHIP_ID_O,
			ctr2.contact_relationship_id				OE_CONTACT_RELATIONSHIP_ID,
			ctr2.contact_person_id					OE_CONTACT_PERSON_ID,
			ctr2.contact_type					OE_CONTACT_TYPE,
			trim(substrb(decode(adrr2.address_id, null,
					adrc2.address_line1 || adrc2.address_line2 || adrc2.address_line3,
					adrr2.address_line1 || adrr2.address_line2 || adrr2.address_line3), 1, 240))
										OE_ADDRESS
		from	per_addresses			adrc2,
			per_addresses			adrr2,
			per_contact_relationships	ctr2,
			per_all_people_f		per,
			per_addresses			adrc,
			per_addresses			adrr,
			per_contact_extra_info_f	cei,
			per_contact_relationships	ctr
		where	ctr.person_id = p_person_id
		and	cei.contact_relationship_id = ctr.contact_relationship_id
		and	cei.cei_information_category = 'JP_ITAX_DEPENDENT_ON_OTHER_EMP'
		and	p_effective_date
			between cei.effective_start_date and cei.effective_end_date
		and	adrr.person_id(+) = ctr.contact_person_id
		and	adrr.address_type(+) = 'JP_R'
		and	p_effective_date
			between adrr.date_from(+) and nvl(adrr.date_to(+), p_effective_date)
		and	adrc.person_id(+) = ctr.contact_person_id
		and	adrc.address_type(+) = 'JP_C'
		and	p_effective_date
			between adrc.date_from(+) and nvl(adrc.date_to(+), p_effective_date)
		and	per.person_id = ctr.contact_person_id
		/* CEI guarantees that person record exists as of effective_date */
		and	p_effective_date
			between per.effective_start_date and per.effective_end_date
		/* No need to check date range of CTR */
		and	ctr2.contact_relationship_id(+) = fnd_number.canonical_to_number(cei.cei_information5)
		and	adrr2.person_id(+) = ctr2.contact_person_id
		and	adrr2.address_type(+) = 'JP_R'
		and	p_effective_date
			between adrr2.date_from(+) and nvl(adrr2.date_to(+), p_effective_date)
		and	adrc2.person_id(+) = ctr2.contact_person_id
		and	adrc2.address_type(+) = 'JP_C'
		and	p_effective_date
			between adrc2.date_from(+) and nvl(adrc2.date_to(+), p_effective_date)
		order by
			decode(ctr.contact_type, 'S', 1, 2),
			per.date_of_birth,
			per.full_name;
	cursor csr_dep_os(
		p_person_id		number,
		p_effective_date	date) is
		select	cei.contact_extra_info_id,
			cei.effective_start_date,
			cei.effective_end_date,
			cei.object_version_number,
			ctr.contact_relationship_id,
			per.last_name						LAST_NAME_KANA,
			per.first_name						FIRST_NAME_KANA,
			per.per_information18					LAST_NAME,
			per.per_information19					FIRST_NAME,
			ctr.contact_type,
			per.date_of_birth,
			per.date_of_death,
			cei.cei_information1					OCCUPATION,
			cei.cei_information2					OS_SALARY_PAYER_NAME,
			cei.cei_information3					OS_SALARY_PAYER_ADDRESS
		from	per_all_people_f		per,
			per_contact_extra_info_f	cei,
			per_contact_relationships	ctr
		where	ctr.person_id = p_person_id
		and	cei.contact_relationship_id = ctr.contact_relationship_id
		and	cei.cei_information_category = 'JP_ITAX_DEPENDENT_ON_OTHER_PAY'
		and	p_effective_date
			between cei.effective_start_date and cei.effective_end_date
		and	per.person_id = ctr.contact_person_id
		/* CEI guarantees that person record exists as of effective_date */
		and	p_effective_date
			between per.effective_start_date and per.effective_end_date
		order by
			decode(ctr.contact_type, 'S', 1, 2),
			per.date_of_birth,
			per.full_name;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	lock_assact(p_action_information_id, p_object_version_number, l_business_group_id, l_assact_rec);
	--
	check_submission_period(p_action_information_id);
	--
	if l_assact_rec.transaction_status not in ('U', 'N') then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
		fnd_message.raise_error;
	end if;
	--
	delete
	from	pay_action_information
	where	action_context_id = l_assact_rec.assignment_action_id
	and	action_context_type = 'AAP'
	and	action_information_category <> 'JP_DEF_ASSACT';
	--
	-- JP_DEF_EMP
	--
	open csr_emp(l_assact_rec.assignment_id, l_assact_rec.effective_date);
	fetch csr_emp into
		l_person_id,
		l_business_group_id,
		l_emp_rec.last_name_kana,
		l_emp_rec.first_name_kana,
		l_emp_rec.last_name,
		l_emp_rec.first_name,
		l_emp_rec.date_of_birth,
		l_emp_rec.date_of_death,
		l_emp_rec.sex,
		l_emp_rec.postal_code,
		l_emp_rec.address;
	close csr_emp;
	--
	open csr_household_head(l_person_id, l_assact_rec.effective_date);
	fetch csr_household_head into
		l_emp_rec.household_head_ctr_id,
		l_contact_person_id,
		l_emp_rec.household_head_contact_type;
	if csr_household_head%found then
		l_emp_rec.household_head_full_name := full_name(l_contact_person_id, l_assact_rec.effective_date);
	else
		l_emp_rec.household_head_ctr_id		:= null;
		l_emp_rec.household_head_full_name	:= null;
		l_emp_rec.household_head_contact_type	:= null;
	end if;
	close csr_household_head;
	--
	open csr_married_flag(l_person_id, l_assact_rec.effective_date);
	fetch csr_married_flag into l_emp_rec.married_flag;
	if csr_married_flag%notfound then
		l_emp_rec.married_flag := 'N';
	end if;
	close csr_married_flag;
	--
	-- JP_DEF_ENTRY
	--
	l_entry_rec.status := 'I';
	for l_rec in csr_entry(l_business_group_id, l_assact_rec.assignment_id, l_assact_rec.effective_date) loop
		if csr_entry%rowcount = 1 then
			l_entry_rec.status			:= 'Q';
			l_entry_rec.datetrack_update_mode	:= ee_datetrack_update_mode(l_rec.element_entry_id, l_rec.effective_start_date, l_rec.effective_end_date, l_assact_rec.effective_date);
			l_entry_rec.element_entry_id		:= l_rec.element_entry_id;
			l_entry_rec.ee_object_version_number	:= l_rec.object_version_number;
		end if;
		--
		if l_rec.input_value_id = c_disability_type_iv then
			l_entry_rec.disability_type_o		:= l_rec.screen_entry_value;
		elsif l_rec.input_value_id = c_aged_type_iv then
			l_entry_rec.aged_type_o			:= l_rec.screen_entry_value;
		elsif l_rec.input_value_id = c_widow_type_iv then
			l_entry_rec.widow_type_o		:= l_rec.screen_entry_value;
		elsif l_rec.input_value_id = c_working_student_type_iv then
			l_entry_rec.working_student_type_o	:= l_rec.screen_entry_value;
		elsif l_rec.input_value_id = c_spouse_dep_type_iv then
			l_entry_rec.spouse_dep_type_o		:= l_rec.screen_entry_value;
		elsif l_rec.input_value_id = c_spouse_disability_type_iv then
			l_entry_rec.spouse_disability_type_o	:= l_rec.screen_entry_value;
		elsif l_rec.input_value_id = c_num_deps_iv then
			l_entry_rec.num_deps_o			:= fnd_number.canonical_to_number(l_rec.screen_entry_value);
		elsif l_rec.input_value_id = c_num_ageds_iv then
			l_entry_rec.num_ageds_o			:= fnd_number.canonical_to_number(l_rec.screen_entry_value);
		elsif l_rec.input_value_id = c_num_aged_parents_iv then
			l_entry_rec.num_aged_parents_lt_o	:= fnd_number.canonical_to_number(l_rec.screen_entry_value);
		elsif l_rec.input_value_id = c_num_specifieds_iv then
			l_entry_rec.num_specifieds_o		:= fnd_number.canonical_to_number(l_rec.screen_entry_value);
		elsif l_rec.input_value_id = c_num_disableds_iv then
			l_entry_rec.num_disableds_o		:= fnd_number.canonical_to_number(l_rec.screen_entry_value);
		elsif l_rec.input_value_id = c_num_svr_disableds_iv then
			l_entry_rec.num_svr_disableds_o		:= fnd_number.canonical_to_number(l_rec.screen_entry_value);
		elsif l_rec.input_value_id = c_num_svr_disableds_lt_iv then
			l_entry_rec.num_svr_disableds_lt_o	:= fnd_number.canonical_to_number(l_rec.screen_entry_value);
		end if;
	end loop;
	--
	pay_jp_def_api.create_entry(
		P_ASSIGNMENT_ACTION_ID		=> l_assact_rec.assignment_action_id,
		P_ASSIGNMENT_ID			=> l_assact_rec.assignment_id,
		P_EFFECTIVE_DATE		=> l_assact_rec.effective_date,
		P_STATUS			=> l_entry_rec.status,
		P_DATETRACK_UPDATE_MODE		=> l_entry_rec.datetrack_update_mode,
		P_ELEMENT_ENTRY_ID		=> l_entry_rec.element_entry_id,
		P_EE_OBJECT_VERSION_NUMBER	=> l_entry_rec.ee_object_version_number,
		P_DISABILITY_TYPE		=> '0',
		P_DISABILITY_TYPE_O		=> l_entry_rec.disability_type_o,
		P_AGED_TYPE			=> '0',
		P_AGED_TYPE_O			=> l_entry_rec.aged_type_o,
		P_WIDOW_TYPE			=> '0',
		P_WIDOW_TYPE_O			=> l_entry_rec.widow_type_o,
		P_WORKING_STUDENT_TYPE		=> '0',
		P_WORKING_STUDENT_TYPE_O	=> l_entry_rec.working_student_type_o,
		P_SPOUSE_DEP_TYPE		=> '0',
		P_SPOUSE_DEP_TYPE_O		=> l_entry_rec.spouse_dep_type_o,
		P_SPOUSE_DISABILITY_TYPE	=> '0',
		P_SPOUSE_DISABILITY_TYPE_O	=> l_entry_rec.spouse_disability_type_o,
		P_NUM_DEPS			=> 0,
		P_NUM_DEPS_O			=> l_entry_rec.num_deps_o,
		P_NUM_AGEDS			=> 0,
		P_NUM_AGEDS_O			=> l_entry_rec.num_ageds_o,
		P_NUM_AGED_PARENTS_LT		=> 0,
		P_NUM_AGED_PARENTS_LT_O		=> l_entry_rec.num_aged_parents_lt_o,
		P_NUM_SPECIFIEDS		=> 0,
		P_NUM_SPECIFIEDS_O		=> l_entry_rec.num_specifieds_o,
		P_NUM_DISABLEDS			=> 0,
		P_NUM_DISABLEDS_O		=> l_entry_rec.num_disableds_o,
		P_NUM_SVR_DISABLEDS		=> 0,
		P_NUM_SVR_DISABLEDS_O		=> l_entry_rec.num_svr_disableds_o,
		P_NUM_SVR_DISABLEDS_LT		=> 0,
		P_NUM_SVR_DISABLEDS_LT_O	=> l_entry_rec.num_svr_disableds_lt_o,
		P_ACTION_INFORMATION_ID		=> l_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_entry_rec.object_version_number);
	--
	-- If widower, change the widow_type from "1" to "3".
	--
	l_emp_rec.disability_type	:= nvl(l_entry_rec.disability_type_o, '0');
	-- Obsolete Aged Exemption from 2005/01/01.
	if l_assact_rec.effective_date >= to_date('2005/01/01','YYYY/MM/DD') then
		l_emp_rec.aged_type := '0';
	else
		l_emp_rec.aged_type := nvl(l_entry_rec.aged_type_o, '0');
	end if;
	l_emp_rec.widow_type		:= nvl(l_entry_rec.widow_type_o, '0');
	if l_emp_rec.widow_type = '1' and l_emp_rec.sex = 'M' then
		l_emp_rec.widow_type := '3';
	end if;
	l_emp_rec.working_student_type	:= nvl(l_entry_rec.working_student_type_o, '0');
	--
	pay_jp_def_api.create_emp(
		P_ASSIGNMENT_ACTION_ID		=> l_assact_rec.assignment_action_id,
		P_ASSIGNMENT_ID			=> l_assact_rec.assignment_id,
		P_EFFECTIVE_DATE		=> l_assact_rec.effective_date,
		P_LAST_NAME_KANA		=> l_emp_rec.last_name_kana,
		P_FIRST_NAME_KANA		=> l_emp_rec.first_name_kana,
		P_LAST_NAME			=> l_emp_rec.last_name,
		P_FIRST_NAME			=> l_emp_rec.first_name,
		P_DATE_OF_BIRTH			=> l_emp_rec.date_of_birth,
		P_DATE_OF_DEATH			=> l_emp_rec.date_of_death,
		P_SEX				=> l_emp_rec.sex,
		P_POSTAL_CODE			=> l_emp_rec.postal_code,
		P_ADDRESS			=> l_emp_rec.address,
		P_HOUSEHOLD_HEAD_CTR_ID		=> l_emp_rec.household_head_ctr_id,
		P_HOUSEHOLD_HEAD_FULL_NAME	=> l_emp_rec.household_head_full_name,
		P_HOUSEHOLD_HEAD_CONTACT_TYPE	=> l_emp_rec.household_head_contact_type,
		P_MARRIED_FLAG			=> l_emp_rec.married_flag,
		P_CHANGE_DATE			=> null,
		P_CHANGE_REASON			=> null,
		P_DISABILITY_TYPE		=> l_emp_rec.disability_type,
		P_DISABILITY_DETAILS		=> l_emp_rec.disability_details,
		P_AGED_TYPE			=> l_emp_rec.aged_type,
		P_AGED_DETAILS			=> l_emp_rec.aged_details,
		P_WIDOW_TYPE			=> l_emp_rec.widow_type,
		P_WIDOW_DETAILS			=> l_emp_rec.widow_details,
		P_WORKING_STUDENT_TYPE		=> l_emp_rec.working_student_type,
		P_WORKING_STUDENT_DETAILS	=> l_emp_rec.working_student_details,
		P_ACTION_INFORMATION_ID		=> l_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_emp_rec.object_version_number);
	--
	-- JP_DEF_DEP
	--
	for l_rec in csr_dep(l_person_id, l_assact_rec.effective_date) loop
		pay_jp_def_api.create_dep(
			P_ASSIGNMENT_ACTION_ID		=> l_assact_rec.assignment_action_id,
			P_ASSIGNMENT_ID			=> l_assact_rec.assignment_id,
			P_EFFECTIVE_DATE		=> l_assact_rec.effective_date,
			P_STATUS			=> 'Q',
			p_datetrack_update_mode		=> cei_datetrack_update_mode(l_rec.contact_extra_info_id, l_rec.effective_start_date, l_rec.effective_end_date, l_assact_rec.effective_date),
			p_datetrack_delete_mode		=> cei_datetrack_delete_mode(l_rec.contact_extra_info_id, l_rec.effective_start_date, l_rec.effective_end_date, l_assact_rec.effective_date),
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_cei_object_version_number	=> l_rec.object_version_number,
			p_contact_relationship_id	=> l_rec.contact_relationship_id,
			p_last_name_kana		=> l_rec.last_name_kana,
			p_first_name_kana		=> l_rec.first_name_kana,
			p_last_name			=> l_rec.last_name,
			p_first_name			=> l_rec.first_name,
			p_contact_type			=> l_rec.contact_type,
			p_date_of_birth			=> l_rec.date_of_birth,
			p_date_of_death			=> l_rec.date_of_death,
			p_address			=> l_rec.address,
			p_change_date			=> null,
			p_change_reason			=> null,
			p_dep_type			=> nvl(l_rec.dep_type, '0'),
			p_dep_type_o			=> l_rec.dep_type,
			p_occupation			=> l_rec.occupation,
			p_occupation_o			=> l_rec.occupation,
			p_estimated_annual_income	=> l_rec.estimated_annual_income,
			p_estimated_annual_income_o	=> l_rec.estimated_annual_income,
			p_disability_type		=> nvl(l_rec.disability_type, '0'),
			p_disability_type_o		=> l_rec.disability_type,
			p_disability_details		=> l_rec.disability_details,
			p_disability_details_o		=> l_rec.disability_details,
			P_ACTION_INFORMATION_ID		=> l_action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_object_version_number);
	end loop;
	--
	-- JP_DEF_DEP_OE
	--
	for l_rec in csr_dep_oe(l_person_id, l_assact_rec.effective_date) loop
		pay_jp_def_api.create_dep_oe(
			p_assignment_action_id		=> l_assact_rec.assignment_action_id,
			P_ASSIGNMENT_ID			=> l_assact_rec.assignment_id,
			P_EFFECTIVE_DATE		=> l_assact_rec.effective_date,
			P_STATUS			=> 'Q',
			p_datetrack_update_mode		=> cei_datetrack_update_mode(l_rec.contact_extra_info_id, l_rec.effective_start_date, l_rec.effective_end_date, l_assact_rec.effective_date),
			p_datetrack_delete_mode		=> cei_datetrack_delete_mode(l_rec.contact_extra_info_id, l_rec.effective_start_date, l_rec.effective_end_date, l_assact_rec.effective_date),
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_cei_object_version_number	=> l_rec.object_version_number,
			p_contact_relationship_id	=> l_rec.contact_relationship_id,
			p_last_name_kana		=> l_rec.last_name_kana,
			p_first_name_kana		=> l_rec.first_name_kana,
			p_last_name			=> l_rec.last_name,
			p_first_name			=> l_rec.first_name,
			p_contact_type			=> l_rec.contact_type,
			p_date_of_birth			=> l_rec.date_of_birth,
			p_date_of_death			=> l_rec.date_of_death,
			p_address			=> l_rec.address,
			p_change_date			=> null,
			p_change_reason			=> null,
			p_occupation			=> l_rec.occupation,
			p_occupation_o			=> l_rec.occupation,
			p_oe_contact_relationship_id	=> l_rec.oe_contact_relationship_id,
			p_oe_full_name			=> full_name(l_rec.oe_contact_person_id, l_assact_rec.effective_date),
			p_oe_contact_type		=> l_rec.oe_contact_type,
			p_oe_address			=> l_rec.oe_address,
			p_oe_contact_relationship_id_o	=> l_rec.oe_contact_relationship_id_o,
			P_ACTION_INFORMATION_ID		=> l_action_information_id,
			p_object_version_number		=> l_object_version_number);
	end loop;
	--
	-- JP_DEF_DEP_OS
	--
	for l_rec in csr_dep_os(l_person_id, l_assact_rec.effective_date) loop
		pay_jp_def_api.create_dep_os(
			p_assignment_action_id		=> l_assact_rec.assignment_action_id,
			P_ASSIGNMENT_ID			=> l_assact_rec.assignment_id,
			P_EFFECTIVE_DATE		=> l_assact_rec.effective_date,
			P_STATUS			=> 'Q',
			p_datetrack_update_mode		=> cei_datetrack_update_mode(l_rec.contact_extra_info_id, l_rec.effective_start_date, l_rec.effective_end_date, l_assact_rec.effective_date),
			p_datetrack_delete_mode		=> cei_datetrack_delete_mode(l_rec.contact_extra_info_id, l_rec.effective_start_date, l_rec.effective_end_date, l_assact_rec.effective_date),
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_cei_object_version_number	=> l_rec.object_version_number,
			p_contact_relationship_id	=> l_rec.contact_relationship_id,
			p_last_name_kana		=> l_rec.last_name_kana,
			p_first_name_kana		=> l_rec.first_name_kana,
			p_last_name			=> l_rec.last_name,
			p_first_name			=> l_rec.first_name,
			p_contact_type			=> l_rec.contact_type,
			p_date_of_birth			=> l_rec.date_of_birth,
			p_date_of_death			=> l_rec.date_of_death,
			p_occupation			=> l_rec.occupation,
			p_occupation_o			=> l_rec.occupation,
			p_os_salary_payer_name		=> l_rec.os_salary_payer_name,
			p_os_salary_payer_name_o	=> l_rec.os_salary_payer_name,
			p_os_salary_payer_address	=> l_rec.os_salary_payer_address,
			p_os_salary_payer_address_o	=> l_rec.os_salary_payer_address,
			P_ACTION_INFORMATION_ID		=> l_action_information_id,
			p_object_version_number		=> l_object_version_number);
	end loop;
	--
	l_assact_rec.transaction_status	:= 'N';
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSACTION_STATUS		=> l_assact_rec.transaction_status);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end do_init;
--
procedure do_init(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.do_init';
begin
	savepoint do_init;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	do_init(p_action_information_id, p_object_version_number);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to do_init;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to do_init;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end do_init;
-- |---------------------------------------------------------------------------|
-- |------------------------------< do_finalize >------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_finalize(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_user_comments			in varchar2)
is
	c_proc			constant varchar2(61) := c_package || 'do_finalize';
--
  l_business_group_id number;
--
	l_submission_date	date;
	l_assact_rec		pay_jp_def_assact_v%rowtype;
	l_entry_rec		pay_jp_def_entry_v%rowtype;
	l_emp_rec		pay_jp_def_emp_v%rowtype;
	--
	cursor csr_entry(p_assignment_action_id in number) is
		select	*
		from	pay_jp_def_entry_v
		where	assignment_action_id = p_assignment_action_id
		for update nowait;
	cursor csr_emp(p_assignment_action_id in number) is
		select	*
		from	pay_jp_def_emp_v
		where	assignment_action_id = p_assignment_action_id;
	cursor csr_dep(p_assignment_action_id in number) is
		select	*
		from	pay_jp_def_dep_v
		where	assignment_action_id = p_assignment_action_id
		and	status <> 'D'
		order by decode(contact_type, 'S', 1, 2), date_of_birth, last_name_kana, first_name_kana;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	lock_assact(p_action_information_id, p_object_version_number, l_business_group_id, l_assact_rec);
	--
	l_submission_date := check_submission_period(p_action_information_id);
	--
	if l_assact_rec.transaction_status <> 'N' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
		fnd_message.raise_error;
	end if;
	--
	-- Synchronize JP_DEF_ENTRY
	-- Note all child EOs must be validated before calling this procedure
	-- because FND_MSB_PUB does not support "primary key" which means
	-- OATableBean multi message functionality is not supported in API.
	--
	open csr_entry(l_assact_rec.assignment_action_id);
	fetch csr_entry into l_entry_rec;
	close csr_entry;
	--
	open csr_emp(l_assact_rec.assignment_action_id);
	fetch csr_emp into l_emp_rec;
	close csr_emp;
	--
	l_entry_rec.disability_type		:= l_emp_rec.disability_type;
	l_entry_rec.aged_type			:= l_emp_rec.aged_type;
	if l_emp_rec.widow_type = '3' then
		l_entry_rec.widow_type := '1';
	else
		l_entry_rec.widow_type := l_emp_rec.widow_type;
	end if;
	l_entry_rec.working_student_type	:= l_emp_rec.working_student_type;
	--
	if l_emp_rec.married_flag = 'Y' then
		l_entry_rec.spouse_dep_type := '1';
	else
		l_entry_rec.spouse_dep_type := '0';
	end if;
	--
	-- Initialize new values
	--
	l_entry_rec.spouse_disability_type	:= '0';
	l_entry_rec.num_deps			:= 0;
	l_entry_rec.num_ageds			:= 0;
	l_entry_rec.num_aged_parents_lt		:= 0;
	l_entry_rec.num_specifieds		:= 0;
	l_entry_rec.num_disableds		:= 0;
	l_entry_rec.num_svr_disableds		:= 0;
	l_entry_rec.num_svr_disableds_lt	:= 0;
	--
	for l_rec in csr_dep(l_assact_rec.assignment_action_id) loop
		if l_rec.contact_type = 'S' then
			if l_rec.dep_type = '0' then
				l_entry_rec.spouse_dep_type := '2';
			elsif l_rec.dep_type = '20' then
				l_entry_rec.spouse_dep_type := '3';
			end if;
			--
			if l_rec.disability_type = '10' then
				l_entry_rec.spouse_disability_type := '1';
			elsif l_rec.disability_type = '20' then
				l_entry_rec.spouse_disability_type := '2';
			elsif l_rec.disability_type = '30' then
				l_entry_rec.spouse_disability_type := '3';
			end if;
		else
			l_entry_rec.num_deps := l_entry_rec.num_deps + 1;
			--
			if l_rec.dep_type = '10' then
				l_entry_rec.num_specifieds := l_entry_rec.num_specifieds + 1;
			elsif l_rec.dep_type = '20' then
				l_entry_rec.num_ageds := l_entry_rec.num_ageds + 1;
			elsif l_rec.dep_type = '30' then
				l_entry_rec.num_aged_parents_lt := l_entry_rec.num_aged_parents_lt + 1;
			end if;
			--
			if l_rec.disability_type = '10' then
				l_entry_rec.num_disableds := l_entry_rec.num_disableds + 1;
			elsif l_rec.disability_type = '20' then
				l_entry_rec.num_svr_disableds := l_entry_rec.num_svr_disableds + 1;
			elsif l_rec.disability_type = '30' then
				l_entry_rec.num_svr_disableds_lt := l_entry_rec.num_svr_disableds_lt + 1;
			end if;
		end if;
	end loop;
	--
	pay_jp_def_api.update_entry(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_entry_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_entry_rec.object_version_number,
		P_DISABILITY_TYPE		=> l_entry_rec.disability_type,
		P_AGED_TYPE			=> l_entry_rec.aged_type,
		P_WIDOW_TYPE			=> l_entry_rec.widow_type,
		P_WORKING_STUDENT_TYPE		=> l_entry_rec.working_student_type,
		P_SPOUSE_DEP_TYPE		=> l_entry_rec.spouse_dep_type,
		P_SPOUSE_DISABILITY_TYPE	=> l_entry_rec.spouse_disability_type,
		P_NUM_DEPS			=> l_entry_rec.num_deps,
		P_NUM_AGEDS			=> l_entry_rec.num_ageds,
		P_NUM_AGED_PARENTS_LT		=> l_entry_rec.num_aged_parents_lt,
		P_NUM_SPECIFIEDS		=> l_entry_rec.num_specifieds,
		P_NUM_DISABLEDS			=> l_entry_rec.num_disableds,
		P_NUM_SVR_DISABLEDS		=> l_entry_rec.num_svr_disableds,
		P_NUM_SVR_DISABLEDS_LT		=> l_entry_rec.num_svr_disableds_lt);
	--
	l_assact_rec.transaction_status	:= 'F';
	l_assact_rec.finalized_date	:= l_submission_date;
	l_assact_rec.finalized_by	:= fnd_global.user_id;
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSACTION_STATUS		=> l_assact_rec.transaction_status,
		P_FINALIZED_DATE		=> l_assact_rec.finalized_date,
		P_FINALIZED_BY			=> l_assact_rec.finalized_by,
		P_USER_COMMENTS			=> p_user_comments);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end do_finalize;
--
procedure do_finalize(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_user_comments			in varchar2,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.do_finalize';
begin
	savepoint do_finalize;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	do_finalize(p_action_information_id, p_object_version_number, p_user_comments);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to do_finalize;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to do_finalize;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end do_finalize;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< do_reject >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_reject(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_admin_comments		in varchar2)
is
	c_proc			constant varchar2(61) := c_package || 'do_reject';
--
  l_business_group_id number;
--
	l_assact_rec		pay_jp_def_assact_v%rowtype;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	lock_assact(p_action_information_id, p_object_version_number, l_business_group_id, l_assact_rec);
	--
	check_submission_period(p_action_information_id);
	--
	if l_assact_rec.transaction_status not in ('F', 'A') then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
		fnd_message.raise_error;
	elsif l_assact_rec.transfer_status <> 'U' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_ALREADY_TRANSFERRED');
		fnd_message.raise_error;
	end if;
	--
	delete
	from	pay_action_information
	where	action_context_id = l_assact_rec.assignment_action_id
	and	action_context_type = 'AAP'
	and	action_information_category <> 'JP_DEF_ASSACT';
	--
	l_assact_rec.transaction_status	:= 'U';
	l_assact_rec.finalized_date	:= null;
	l_assact_rec.finalized_by	:= null;
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSACTION_STATUS		=> l_assact_rec.transaction_status,
		P_FINALIZED_DATE		=> l_assact_rec.finalized_date,
		P_FINALIZED_BY			=> l_assact_rec.finalized_by,
		P_ADMIN_COMMENTS		=> p_admin_comments);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end do_reject;
--
procedure do_reject(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_admin_comments		in varchar2,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.do_reject';
begin
	savepoint do_reject;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	do_reject(p_action_information_id, p_object_version_number, p_admin_comments);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to do_reject;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to do_reject;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end do_reject;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< do_return >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_return(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_admin_comments		in varchar2)
is
	c_proc			constant varchar2(61) := c_package || 'do_return';
--
  l_business_group_id number;
--
	l_assact_rec		pay_jp_def_assact_v%rowtype;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	lock_assact(p_action_information_id, p_object_version_number, l_business_group_id, l_assact_rec);
	--
	check_submission_period(p_action_information_id);
	--
	if l_assact_rec.transaction_status not in ('F', 'A') then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
		fnd_message.raise_error;
	elsif l_assact_rec.transfer_status <> 'U' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_ALREADY_TRANSFERRED');
		fnd_message.raise_error;
	end if;
	--
	l_assact_rec.transaction_status	:= 'N';
	l_assact_rec.finalized_date	:= null;
	l_assact_rec.finalized_by	:= null;
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSACTION_STATUS		=> l_assact_rec.transaction_status,
		P_FINALIZED_DATE		=> l_assact_rec.finalized_date,
		P_FINALIZED_BY			=> l_assact_rec.finalized_by,
		P_ADMIN_COMMENTS		=> p_admin_comments);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end do_return;
--
procedure do_return(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_admin_comments		in varchar2,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.do_return';
begin
	savepoint do_return;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	do_return(p_action_information_id, p_object_version_number, p_admin_comments);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to do_return;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to do_return;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end do_return;
-- |---------------------------------------------------------------------------|
-- |------------------------------< do_approve >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_approve(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number)
is
	c_proc			constant varchar2(61) := c_package || 'do_approve';
--
  l_business_group_id number;
--
	l_assact_rec		pay_jp_def_assact_v%rowtype;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	lock_assact(p_action_information_id, p_object_version_number, l_business_group_id, l_assact_rec);
	--
	if l_assact_rec.transaction_status <> 'F' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
		fnd_message.raise_error;
	end if;
	--
	l_assact_rec.transaction_status	:= 'A';
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSACTION_STATUS		=> l_assact_rec.transaction_status);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end do_approve;
--
procedure do_approve(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.do_approve';
begin
	savepoint do_approve;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	do_approve(p_action_information_id, p_object_version_number);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to do_approve;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to do_approve;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end do_approve;
-- |---------------------------------------------------------------------------|
-- |------------------------------< do_approve >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_approve(
	errbuf				out nocopy varchar2,
	retcode				out nocopy varchar2,
	p_payroll_action_id		in varchar2)
is
	l_payroll_action_id	number := fnd_number.canonical_to_number(p_payroll_action_id);
	cursor csr_assact is
		select	aif.action_information_id,
			aif.object_version_number
		from	pay_jp_def_assact_v	aif,
			pay_assignment_actions	paa
		where	paa.payroll_action_id = l_payroll_action_id
		and	paa.action_status = 'C'
		and	aif.assignment_action_id = paa.assignment_action_id
		and	transaction_status = 'F';
begin
	--
	-- retcode
	-- 0 : Success
	-- 1 : Warning
	-- 2 : Error
	--
	retcode := '0';
	--
	for l_rec in csr_assact loop
		begin
			do_approve(
				p_action_information_id		=> l_rec.action_information_id,
				p_object_version_number		=> l_rec.object_version_number);
			commit;
		exception
			when others then
				retcode := '1';
		end;
	end loop;
end do_approve;
-- |---------------------------------------------------------------------------|
-- |------------------------------< do_transfer >------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_transfer(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_create_session		in boolean default true)
is
	c_proc			constant varchar2(61) := c_package || 'do_transfer';
	l_assact_rec		pay_jp_def_assact_v%rowtype;
	l_entry_rec		pay_jp_def_entry_v%rowtype;
	l_dep_rec		pay_jp_def_dep_v%rowtype;
	l_dep_oe_rec		pay_jp_def_dep_oe_v%rowtype;
	l_dep_os_rec		pay_jp_def_dep_os_v%rowtype;
	--
	cursor csr_entry(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_entry_v
		where	assignment_action_id = p_assignment_action_id
		for update nowait;
	--
	-- JP_DEF_DEP
	--
	cursor csr_dep_del(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'D'
		for update nowait;
	cursor csr_dep_upd(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'Q'
		for update nowait;
	cursor csr_dep_ins(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'I'
		for update nowait;
	--
	-- JP_DEF_DEP_OE
	--
	cursor csr_dep_oe_del(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_oe_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'D'
		for update nowait;
	cursor csr_dep_oe_upd(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_oe_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'Q'
		for update nowait;
	cursor csr_dep_oe_ins(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_oe_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'I'
		for update nowait;
	--
	-- JP_DEF_DEP_OS
	--
	cursor csr_dep_os_del(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_os_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'D'
		for update nowait;
	cursor csr_dep_os_upd(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_os_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'Q'
		for update nowait;
	cursor csr_dep_os_ins(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_os_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'I'
		for update nowait;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
--
  if p_create_session then
    g_business_group_id := null;
  end if;
--
	lock_assact(p_action_information_id, p_object_version_number, g_business_group_id, l_assact_rec);
	--
	if l_assact_rec.transaction_status <> 'A' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
		fnd_message.raise_error;
	elsif l_assact_rec.transfer_status <> 'U' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_ALREADY_TRANSFERRED');
		fnd_message.raise_error;
	end if;
	--
	if p_create_session then
		insert_session(l_assact_rec.effective_date);
	end if;
	--
	-- Transfer JP_DEF_ENTRY to PAY_ELEMENT_ENTRIES_F
	--
	for l_rec in csr_entry(l_assact_rec.assignment_action_id) loop
		transfer_entry(l_rec,g_business_group_id);
	end loop;
	--
	-- Transfer the followings.
	--
	--   JP_DEF_DEP    --> PER_CONTACT_EXTRA_INFO_F.JP_DEF_DEP
	--   JP_DEF_DEP_OE --> PER_CONTACT_EXTRA_INFO_F.JP_DEF_DEP_OE
	--   JP_DEF_DEP_OS --> PER_CONTACT_EXTRA_INFO_F.JP_DEF_DEP_OS
	--
	-- The transaction sequence into PER_CONTACT_EXTRA_INFO_F must be
	-- at first "Delele", "Update" and at last "Insert" to avoid API errors.
	--
	-- "Delete" phase
	--
	for l_rec in csr_dep_del(l_assact_rec.assignment_action_id) loop
		transfer_dep(l_rec);
	end loop;
	for l_rec in csr_dep_oe_del(l_assact_rec.assignment_action_id) loop
		transfer_dep_oe(l_rec);
	end loop;
	for l_rec in csr_dep_os_del(l_assact_rec.assignment_action_id) loop
		transfer_dep_os(l_rec);
	end loop;
	--
	-- "Update" phase
	--
	for l_rec in csr_dep_upd(l_assact_rec.assignment_action_id) loop
		transfer_dep(l_rec);
	end loop;
	for l_rec in csr_dep_oe_upd(l_assact_rec.assignment_action_id) loop
		transfer_dep_oe(l_rec);
	end loop;
	for l_rec in csr_dep_os_upd(l_assact_rec.assignment_action_id) loop
		transfer_dep_os(l_rec);
	end loop;
	--
	-- "Insert" phase
	--
	for l_rec in csr_dep_ins(l_assact_rec.assignment_action_id) loop
		transfer_dep(l_rec);
	end loop;
	for l_rec in csr_dep_oe_ins(l_assact_rec.assignment_action_id) loop
		transfer_dep_oe(l_rec);
	end loop;
	for l_rec in csr_dep_os_ins(l_assact_rec.assignment_action_id) loop
		transfer_dep_os(l_rec);
	end loop;
	--
	if p_create_session then
		delete_session;
	end if;
	--
	l_assact_rec.transfer_status	:= 'T';
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSFER_STATUS		=> l_assact_rec.transfer_status);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end do_transfer;
--
procedure do_transfer(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.do_transfer';
begin
	savepoint do_transfer;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	do_transfer(p_action_information_id, p_object_version_number);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to do_transfer;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to do_transfer;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end do_transfer;
-- |---------------------------------------------------------------------------|
-- |------------------------------< do_transfer >------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_transfer(
	errbuf				out nocopy varchar2,
	retcode				out nocopy varchar2,
	p_payroll_action_id		in varchar2)
is
	l_effective_date	date;
	l_payroll_action_id	number := fnd_number.canonical_to_number(p_payroll_action_id);
	--
	cursor csr_assact is
		select	assact.action_information_id,
			assact.object_version_number,
			per.full_name,
			asg.assignment_number
		from	per_all_people_f	per,
			per_all_assignments_f	asg,
			pay_jp_def_assact_v	assact,
			pay_assignment_actions	paa
		where	paa.payroll_action_id = l_payroll_action_id
		and	paa.action_status = 'C'
		and	assact.assignment_action_id = paa.assignment_action_id
		and	assact.transaction_status = 'A'
		and	assact.transfer_status = 'U'
		and	asg.assignment_id = assact.assignment_id
		and	assact.effective_date
			between asg.effective_start_date and asg.effective_end_date
		and	per.person_id = asg.person_id
		and	assact.effective_date
			between per.effective_start_date and per.effective_end_date;
begin
	--
	-- retcode
	-- 0 : Success
	-- 1 : Warning
	-- 2 : Error
	--
	retcode := '0';
	--
--
  g_business_group_id := null;
--
	select	effective_date
	into	l_effective_date
	from	pay_jp_def_pact_v
	where	payroll_action_id = l_payroll_action_id;
	--
	insert_session(l_effective_date);
	commit;
	--
	fnd_file.put_line(fnd_file.output, 'Full Name                                Assignment Number');
	fnd_file.put_line(fnd_file.output, '---------------------------------------- ------------------------------');
	fnd_file.put_line(fnd_file.log,    'Full Name                                Assignment Number');
	fnd_file.put_line(fnd_file.log,    '---------------------------------------- ------------------------------');
	--
	for l_rec in csr_assact loop
		begin
			do_transfer(
				p_action_information_id	=> l_rec.action_information_id,
				p_object_version_number	=> l_rec.object_version_number,
				p_create_session	=> false);
			commit;
			--
			fnd_file.put_line(fnd_file.output, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
		exception
			when others then
				retcode := '1';
				fnd_file.put_line(fnd_file.log, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
				fnd_file.put_line(fnd_file.log, get_sqlerrm);
		end;
	end loop;
	--
	delete_session;
	commit;
end do_transfer;
-- |---------------------------------------------------------------------------|
-- |---------------------------< rollback_transfer >---------------------------|
-- |---------------------------------------------------------------------------|
procedure rollback_transfer(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_create_session		in boolean default true)
is
	c_proc			constant varchar2(61) := c_package || 'rollback_transfer';
	l_assact_rec		pay_jp_def_assact_v%rowtype;
	l_entry_rec		pay_jp_def_entry_v%rowtype;
	l_dep_rec		pay_jp_def_dep_v%rowtype;
	l_dep_oe_rec		pay_jp_def_dep_oe_v%rowtype;
	l_dep_os_rec		pay_jp_def_dep_os_v%rowtype;
	--
	cursor csr_entry(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_entry_v
		where	assignment_action_id = p_assignment_action_id
		for update nowait;
	--
	-- JP_DEF_DEP
	--
	cursor csr_dep_ins(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'I'
		for update nowait;
	cursor csr_dep_upd(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'U'
		for update nowait;
	cursor csr_dep_del(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'D'
		for update nowait;
	--
	-- JP_DEF_DEP_OE
	--
	cursor csr_dep_oe_ins(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_oe_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'I'
		for update nowait;
	cursor csr_dep_oe_upd(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_oe_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'U'
		for update nowait;
	cursor csr_dep_oe_del(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_oe_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'D'
		for update nowait;
	--
	-- JP_DEF_DEP_OS
	--
	cursor csr_dep_os_ins(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_os_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'I'
		for update nowait;
	cursor csr_dep_os_upd(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_os_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'U'
		for update nowait;
	cursor csr_dep_os_del(p_assignment_action_id number) is
		select	*
		from	pay_jp_def_dep_os_v
		where	assignment_action_id = p_assignment_action_id
		and	status = 'D'
		for update nowait;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
--
  if p_create_session then
    g_business_group_id := null;
  end if;
--
	lock_assact(p_action_information_id, p_object_version_number, g_business_group_id, l_assact_rec);
	--
	if l_assact_rec.transfer_status = 'U' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_NOT_TRANSFERRED');
		fnd_message.raise_error;
	elsif l_assact_rec.transfer_status = 'E' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_ALREADY_EXPIRED');
		fnd_message.raise_error;
	end if;
	--
	if p_create_session then
		insert_session(l_assact_rec.effective_date);
	end if;
	--
	-- Rollback Transfer JP_DEF_ENTRY to PAY_ELEMENT_ENTRIES_F
	--
	for l_rec in csr_entry(l_assact_rec.assignment_action_id) loop
		rollback_entry(l_rec,g_business_group_id);
	end loop;
	--
	-- Rollback Transfer the followings.
	--
	--   JP_DEF_DEP    --> PER_CONTACT_EXTRA_INFO_F.JP_DEF_DEP
	--   JP_DEF_DEP_OE --> PER_CONTACT_EXTRA_INFO_F.JP_DEF_DEP_OE
	--   JP_DEF_DEP_OS --> PER_CONTACT_EXTRA_INFO_F.JP_DEF_DEP_OS
	--
	-- The transaction sequence into PER_CONTACT_EXTRA_INFO_F must be
	-- at first "Insert", "Update" and at last "Delete" to avoid API errors.
	--
	-- "Insert" phase
	--
	for l_rec in csr_dep_ins(l_assact_rec.assignment_action_id) loop
		rollback_dep(l_rec);
	end loop;
	for l_rec in csr_dep_oe_ins(l_assact_rec.assignment_action_id) loop
		rollback_dep_oe(l_rec);
	end loop;
	for l_rec in csr_dep_os_ins(l_assact_rec.assignment_action_id) loop
		rollback_dep_os(l_rec);
	end loop;
	--
	-- "Update" phase
	--
	for l_rec in csr_dep_upd(l_assact_rec.assignment_action_id) loop
		rollback_dep(l_rec);
	end loop;
	for l_rec in csr_dep_oe_upd(l_assact_rec.assignment_action_id) loop
		rollback_dep_oe(l_rec);
	end loop;
	for l_rec in csr_dep_os_upd(l_assact_rec.assignment_action_id) loop
		rollback_dep_os(l_rec);
	end loop;
	--
	-- "Delete" phase
	--
	for l_rec in csr_dep_del(l_assact_rec.assignment_action_id) loop
		rollback_dep(l_rec);
	end loop;
	for l_rec in csr_dep_oe_del(l_assact_rec.assignment_action_id) loop
		rollback_dep_oe(l_rec);
	end loop;
	for l_rec in csr_dep_os_del(l_assact_rec.assignment_action_id) loop
		rollback_dep_os(l_rec);
	end loop;
	--
	if p_create_session then
		delete_session;
	end if;
	--
	l_assact_rec.transfer_status	:= 'U';
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSFER_STATUS		=> l_assact_rec.transfer_status);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end rollback_transfer;
--
procedure rollback_transfer(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.rollback_transfer';
begin
	savepoint rollback_transfer;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	rollback_transfer(p_action_information_id, p_object_version_number);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to rollback_transfer;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to rollback_transfer;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end rollback_transfer;
-- |---------------------------------------------------------------------------|
-- |-------------------------------< do_expire >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_expire(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_expiry_date			in date)
is
	c_proc			constant varchar2(61) := c_package || 'do_expire';
--
  l_business_group_id number;
--
	l_assact_rec		pay_jp_def_assact_v%rowtype;
	l_year_end_date		date;
	l_esd			date;
	l_eed			date;
	l_warning		boolean;
	--
	cursor csr_entry(p_assignment_action_id number) is
		select	v.*
		from	pay_jp_def_entry_v	v
		where	v.assignment_action_id = p_assignment_action_id
		and	exists(
				select	null
				from	pay_element_entries_f	pee
				where	pee.element_entry_id = v.element_entry_id
				and	p_expiry_date + 1
					between pee.effective_start_date and pee.effective_end_date)
		for update nowait;
	cursor csr_dep(p_assignment_action_id number) is
		select	v.*
		from	pay_jp_def_dep_v	v
		where	v.assignment_action_id = p_assignment_action_id
		and	status <> 'D'
		and	exists(
				select	null
				from	per_contact_extra_info_f	cei
				where	cei.contact_extra_info_id = v.contact_extra_info_id
				and	p_expiry_date + 1
					between cei.effective_start_date and cei.effective_end_date)
		for update nowait;
	cursor csr_dep_oe(p_assignment_action_id number) is
		select	v.*
		from	pay_jp_def_dep_oe_v	v
		where	v.assignment_action_id = p_assignment_action_id
		and	status <> 'D'
		and	exists(
				select	null
				from	per_contact_extra_info_f	cei
				where	cei.contact_extra_info_id = v.contact_extra_info_id
				and	p_expiry_date + 1
					between cei.effective_start_date and cei.effective_end_date)
		for update nowait;
	cursor csr_dep_os(p_assignment_action_id number) is
		select	v.*
		from	pay_jp_def_dep_os_v	v
		where	v.assignment_action_id = p_assignment_action_id
		and	status <> 'D'
		and	exists(
				select	null
				from	per_contact_extra_info_f	cei
				where	cei.contact_extra_info_id = v.contact_extra_info_id
				and	p_expiry_date + 1
					between cei.effective_start_date and cei.effective_end_date)
		for update nowait;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	hr_api.mandatory_arg_error(c_proc, 'expiry_date', p_expiry_date);
	--
	lock_assact(p_action_information_id, p_object_version_number, l_business_group_id, l_assact_rec);
	--
	if l_assact_rec.transfer_status = 'U' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_NOT_TRANSFERRED_YET');
		fnd_message.raise_error;
	elsif l_assact_rec.transfer_status = 'E' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_ALREADY_EXPIRED');
		fnd_message.raise_error;
	end if;
	--
	l_year_end_date := add_months(trunc(l_assact_rec.effective_date, 'YYYY'), 12) - 1;
	if p_expiry_date < l_assact_rec.effective_date
	or p_expiry_date > l_year_end_date then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_EXPIRY_DATE');
		fnd_message.set_token('EFFECTIVE_DATE', fnd_date.date_to_chardate(l_assact_rec.effective_date));
		fnd_message.set_token('YEAR_END_DATE',  fnd_date.date_to_chardate(l_year_end_date));
		fnd_message.raise_error;
	end if;
	--
	insert_session(p_expiry_date);
	--
	for l_rec in csr_entry(l_assact_rec.assignment_action_id) loop
		pay_element_entry_api.delete_element_entry(
			p_validate			=> false,
			p_effective_date		=> p_expiry_date,
			p_datetrack_delete_mode		=> 'DELETE',
			p_element_entry_id		=> l_rec.element_entry_id,
			p_object_version_number		=> l_rec.ee_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed,
			p_delete_warning		=> l_warning);
		--
		pay_jp_def_api.update_entry(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> l_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_rec.object_version_number,
			P_EE_OBJECT_VERSION_NUMBER	=> l_rec.ee_object_version_number);
	end loop;
	--
	for l_rec in csr_dep(l_assact_rec.assignment_action_id) loop
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_expiry_date,
			p_datetrack_delete_mode		=> 'DELETE',
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_object_version_number		=> l_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> l_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_rec.object_version_number,
			P_CEI_OBJECT_VERSION_NUMBER	=> l_rec.cei_object_version_number);
	end loop;
	--
	for l_rec in csr_dep_oe(l_assact_rec.assignment_action_id) loop
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_expiry_date,
			p_datetrack_delete_mode		=> 'DELETE',
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_object_version_number		=> l_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep_oe(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> l_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_rec.object_version_number,
			P_CEI_OBJECT_VERSION_NUMBER	=> l_rec.cei_object_version_number);
	end loop;
	--
	for l_rec in csr_dep_os(l_assact_rec.assignment_action_id) loop
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> p_expiry_date,
			p_datetrack_delete_mode		=> 'DELETE',
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_object_version_number		=> l_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep_os(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> l_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_rec.object_version_number,
			P_CEI_OBJECT_VERSION_NUMBER	=> l_rec.cei_object_version_number);
	end loop;
	--
	delete_session;
	--
	l_assact_rec.transfer_status	:= 'E';
	l_assact_rec.expiry_date	:= p_expiry_date;
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSFER_STATUS		=> l_assact_rec.transfer_status,
		P_EXPIRY_DATE			=> l_assact_rec.expiry_date);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end do_expire;
--
procedure do_expire(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_expiry_date			in date,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.do_expire';
begin
	savepoint do_expire;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	do_expire(p_action_information_id, p_object_version_number, p_expiry_date);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to do_expire;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to do_expire;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end do_expire;
-- |---------------------------------------------------------------------------|
-- |----------------------------< rollback_expire >----------------------------|
-- |---------------------------------------------------------------------------|
procedure rollback_expire(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number)
is
	c_proc			constant varchar2(61) := c_package || 'rollback_expire';
--
  l_business_group_id number;
--
	l_assact_rec		pay_jp_def_assact_v%rowtype;
	l_esd			date;
	l_eed			date;
	l_warning		boolean;
	--
	cursor csr_entry(
		p_assignment_action_id	number,
		p_expiry_date		date) is
		select	v.*
		from	pay_jp_def_entry_v	v
		where	v.assignment_action_id = p_assignment_action_id
		and	exists(
				select	null
				from	pay_element_entries_f	pee
				where	pee.element_entry_id = v.element_entry_id
				and	p_expiry_date
					between pee.effective_start_date and pee.effective_end_date)
		for update nowait;
	cursor csr_dep(
		p_assignment_action_id	number,
		p_expiry_date		date) is
		select	v.*
		from	pay_jp_def_dep_v	v
		where	v.assignment_action_id = p_assignment_action_id
		and	status <> 'D'
		and	exists(
				select	null
				from	per_contact_extra_info_f	cei
				where	cei.contact_extra_info_id = v.contact_extra_info_id
				and	p_expiry_date
					between cei.effective_start_date and cei.effective_end_date)
		for update nowait;
	cursor csr_dep_oe(
		p_assignment_action_id	number,
		p_expiry_date		date) is
		select	v.*
		from	pay_jp_def_dep_oe_v	v
		where	v.assignment_action_id = p_assignment_action_id
		and	status <> 'D'
		and	exists(
				select	null
				from	per_contact_extra_info_f	cei
				where	cei.contact_extra_info_id = v.contact_extra_info_id
				and	p_expiry_date
					between cei.effective_start_date and cei.effective_end_date)
		for update nowait;
	cursor csr_dep_os(
		p_assignment_action_id	number,
		p_expiry_date		date) is
		select	v.*
		from	pay_jp_def_dep_os_v	v
		where	v.assignment_action_id = p_assignment_action_id
		and	status <> 'D'
		and	exists(
				select	null
				from	per_contact_extra_info_f	cei
				where	cei.contact_extra_info_id = v.contact_extra_info_id
				and	p_expiry_date
					between cei.effective_start_date and cei.effective_end_date)
		for update nowait;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	lock_assact(p_action_information_id, p_object_version_number, l_business_group_id, l_assact_rec);
	--
	if l_assact_rec.transfer_status <> 'E' then
		fnd_message.set_name('PAY', 'PAY_JP_DEF_NOT_EXPIRED_YET');
		fnd_message.raise_error;
	end if;
	--
	insert_session(l_assact_rec.expiry_date);
	--
	for l_rec in csr_entry(l_assact_rec.assignment_action_id, l_assact_rec.expiry_date) loop
		pay_element_entry_api.delete_element_entry(
			p_validate			=> false,
			p_effective_date		=> l_assact_rec.expiry_date,
			p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
			p_element_entry_id		=> l_rec.element_entry_id,
			p_object_version_number		=> l_rec.ee_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed,
			p_delete_warning		=> l_warning);
		--
		pay_jp_def_api.update_entry(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> l_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_rec.object_version_number,
			P_EE_OBJECT_VERSION_NUMBER	=> l_rec.ee_object_version_number);
	end loop;
	--
	for l_rec in csr_dep(l_assact_rec.assignment_action_id, l_assact_rec.expiry_date) loop
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> l_assact_rec.expiry_date,
			p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_object_version_number		=> l_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> l_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_rec.object_version_number,
			P_CEI_OBJECT_VERSION_NUMBER	=> l_rec.cei_object_version_number);
	end loop;
	--
	for l_rec in csr_dep_oe(l_assact_rec.assignment_action_id, l_assact_rec.expiry_date) loop
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> l_assact_rec.expiry_date,
			p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_object_version_number		=> l_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep_oe(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> l_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_rec.object_version_number,
			P_CEI_OBJECT_VERSION_NUMBER	=> l_rec.cei_object_version_number);
	end loop;
	--
	for l_rec in csr_dep_os(l_assact_rec.assignment_action_id, l_assact_rec.expiry_date) loop
		hr_contact_extra_info_api.delete_contact_extra_info(
			p_validate			=> false,
			p_effective_date		=> l_assact_rec.expiry_date,
			p_datetrack_delete_mode		=> 'DELETE_NEXT_CHANGE',
			p_contact_extra_info_id		=> l_rec.contact_extra_info_id,
			p_object_version_number		=> l_rec.cei_object_version_number,
			p_effective_start_date		=> l_esd,
			p_effective_end_date		=> l_eed);
		--
		pay_jp_def_api.update_dep_os(
			P_VALIDATE			=> false,
			P_ACTION_INFORMATION_ID		=> l_rec.action_information_id,
			P_OBJECT_VERSION_NUMBER		=> l_rec.object_version_number,
			P_CEI_OBJECT_VERSION_NUMBER	=> l_rec.cei_object_version_number);
	end loop;
	--
	delete_session;
	--
	l_assact_rec.transfer_status	:= 'T';
	l_assact_rec.expiry_date	:= null;
	--
	pay_jp_def_api.update_assact(
		P_VALIDATE			=> false,
		P_ACTION_INFORMATION_ID		=> l_assact_rec.action_information_id,
		P_OBJECT_VERSION_NUMBER		=> l_assact_rec.object_version_number,
		P_TRANSFER_STATUS		=> l_assact_rec.transfer_status,
		P_EXPIRY_DATE			=> l_assact_rec.expiry_date);
	--
	p_object_version_number := l_assact_rec.object_version_number;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end rollback_expire;
--
procedure rollback_expire(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2)
is
	l_proc		varchar2(61) := c_package || '.rollback_expire';
begin
	savepoint rollback_expire;
	--
	-- Initialise Multiple Message Detection
	--
	hr_multi_message.enable_message_list;
	--
	rollback_expire(p_action_information_id, p_object_version_number);
	--
	p_return_status := hr_multi_message.get_return_status_disable;
exception
	when hr_multi_message.error_message_exist then
		rollback to rollback_expire;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
	when others then
		rollback to rollback_expire;
		if hr_multi_message.unexpected_error_add(l_proc) then
			raise;
		end if;
		p_object_version_number := null;
		p_return_status := hr_multi_message.get_return_status_disable;
end rollback_expire;

--
--
--
--
--
-- |---------------------------------------------------------------------------|
-- |--------------------------< delete_unfinalized >---------------------------|
-- |---------------------------------------------------------------------------|
procedure delete_unfinalized(
	errbuf				out nocopy varchar2,
	retcode				out nocopy varchar2,
	p_payroll_action_id		in varchar2)
is
	l_payroll_action_id	number := fnd_number.canonical_to_number(p_payroll_action_id);
	cursor csr_assact is
		select	paa.assignment_action_id
		from	pay_jp_def_assact_v	aif,
			pay_assignment_actions	paa
		where	paa.payroll_action_id = l_payroll_action_id
		and	aif.assignment_action_id(+) = paa.assignment_action_id
		and	nvl(aif.transaction_status, 'U') not in ('F', 'A');
begin
	--
	-- retcode
	-- 0 : Success
	-- 1 : Warning
	-- 2 : Error
	--
	retcode := '0';
	--
	for l_rec in csr_assact loop
		begin
			py_rollback_pkg.rollback_ass_action(
				p_assignment_action_id	=> l_rec.assignment_action_id,
				p_rollback_mode		=> 'ROLLBACK',
				p_leave_base_table_row	=> false,
				p_all_or_nothing	=> true,
				p_dml_mode		=> 'FULL');
		exception
			when others then
				retcode := '1';
		end;
	end loop;
end delete_unfinalized;
--
/*
begin
	hr_utility.trace_on('F', 'TTAGAWA');
	hr_utility.trace('c_package                   : ' || c_package);
	hr_utility.trace('c_def_elm                   : ' || c_def_elm);
	hr_utility.trace('c_disability_type_iv        : ' || c_disability_type_iv);
	hr_utility.trace('c_aged_type_iv              : ' || c_aged_type_iv);
	hr_utility.trace('c_widow_type_iv             : ' || c_widow_type_iv);
	hr_utility.trace('c_working_student_type_iv   : ' || c_working_student_type_iv);
	hr_utility.trace('c_spouse_dep_type_iv        : ' || c_spouse_dep_type_iv);
	hr_utility.trace('c_spouse_disability_type_iv : ' || c_spouse_disability_type_iv);
	hr_utility.trace('c_num_deps_iv               : ' || c_num_deps_iv);
	hr_utility.trace('c_num_ageds_iv              : ' || c_num_ageds_iv);
	hr_utility.trace('c_num_aged_parents_iv       : ' || c_num_aged_parents_iv);
	hr_utility.trace('c_num_specifieds_iv         : ' || c_num_specifieds_iv);
	hr_utility.trace('c_num_disableds_iv          : ' || c_num_disableds_iv);
	hr_utility.trace('c_num_svr_disableds_iv      : ' || c_num_svr_disableds_iv);
	hr_utility.trace('c_num_svr_disableds_lt_iv   : ' || c_num_svr_disableds_lt_iv);
*/
end pay_jp_def_ss;

/
