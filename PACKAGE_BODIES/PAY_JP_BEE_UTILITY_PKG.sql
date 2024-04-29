--------------------------------------------------------
--  DDL for Package Body PAY_JP_BEE_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_BEE_UTILITY_PKG" as
/* $Header: pyjpbeeu.pkb 115.1 2002/12/06 11:52:12 ytohya noship $ */
--
-- Constants
--
c_package		constant varchar2(31) := 'pay_jp_bee_utility_pkg.';
c_prompt_lookup_type	constant hr_lookups.lookup_type%TYPE := 'JP_BEE_UTIL_PROMPT';
-- ----------------------------------------------------------------------------
-- |---------------------------< entry_value_tbl >----------------------------|
-- ----------------------------------------------------------------------------
function entry_value_tbl(
	p_value1	varchar2 default hr_api.g_varchar2,
	p_value2	varchar2 default hr_api.g_varchar2,
	p_value3	varchar2 default hr_api.g_varchar2,
	p_value4	varchar2 default hr_api.g_varchar2,
	p_value5	varchar2 default hr_api.g_varchar2,
	p_value6	varchar2 default hr_api.g_varchar2,
	p_value7	varchar2 default hr_api.g_varchar2,
	p_value8	varchar2 default hr_api.g_varchar2,
	p_value9	varchar2 default hr_api.g_varchar2,
	p_value10	varchar2 default hr_api.g_varchar2,
	p_value11	varchar2 default hr_api.g_varchar2,
	p_value12	varchar2 default hr_api.g_varchar2,
	p_value13	varchar2 default hr_api.g_varchar2,
	p_value14	varchar2 default hr_api.g_varchar2,
	p_value15	varchar2 default hr_api.g_varchar2) return t_varchar2_tbl
is
	l_entry_value_tbl	t_varchar2_tbl;
	--
	procedure set_entry_value(
		p_index	in number,
		p_value	in varchar2)
	is
	begin
		if (p_value is null) or (p_value <> hr_api.g_varchar2) then
			l_entry_value_tbl(p_index) := p_value;
		end if;
	end set_entry_value;
begin
	set_entry_value(1, p_value1);
	set_entry_value(2, p_value2);
	set_entry_value(3, p_value3);
	set_entry_value(4, p_value4);
	set_entry_value(5, p_value5);
	set_entry_value(6, p_value6);
	set_entry_value(7, p_value7);
	set_entry_value(8, p_value8);
	set_entry_value(9, p_value9);
	set_entry_value(10, p_value10);
	set_entry_value(11, p_value11);
	set_entry_value(12, p_value12);
	set_entry_value(13, p_value13);
	set_entry_value(14, p_value14);
	set_entry_value(15, p_value15);
	--
	return l_entry_value_tbl;
end entry_value_tbl;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_upload_date >----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_upload_date(
	p_time_period_id		in number,
	p_upload_date			in date,
	p_period_start_date	 out nocopy date,
	p_period_end_date	 out nocopy date)
is
	l_proc	varchar2(61) := c_package || 'chk_upload_date';
	cursor csr_time_period is
		select	start_date,
			end_date
		from	per_time_periods
		where	time_period_id = p_time_period_id;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	-- p_upload_date must be within the payroll period specified.
	-- Here checks whether p_upload_date is really within current payroll period.
	--
	open csr_time_period;
	fetch csr_time_period into p_period_start_date, p_period_end_date;
	if (csr_time_period%NOTFOUND)
	or not (p_upload_date between p_period_start_date and p_period_end_date) then
		close csr_time_period;
		fnd_message.set_name('PAY', 'PAY_JP_BEE_UTIL_INV_UPLD_DATE');
		fnd_message.set_token('UPLOAD_DATE', fnd_date.date_to_chardate(p_upload_date));
		fnd_message.set_token('PERIOD_START_DATE', fnd_date.date_to_chardate(p_period_start_date));
		fnd_message.set_token('PERIOD_END_DATE', fnd_date.date_to_chardate(p_period_end_date));
		fnd_message.raise_error;
	end if;
	close csr_time_period;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end chk_upload_date;
-- ----------------------------------------------------------------------------
-- |----------------------< chk_date_effective_changes >----------------------|
-- ----------------------------------------------------------------------------
procedure chk_date_effective_changes(
	p_action_if_exists		in varchar2,
	p_reject_if_future_changes	in varchar2,
	p_date_effective_changes	in out nocopy varchar2)
is
	l_proc	varchar2(61) := c_package || 'chk_date_effective_changes';
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	-- Date Effective Changes is available only when "Update",
	-- not available when "Insert" and "Reject".
	--
	if p_action_if_exists in ('I', 'R') then
		p_date_effective_changes := null;
	--
	-- 1. Date Effective Changes is null for "Update" case, set to "Update/Change Insert"
	-- 2. Date Effective Changes "Override" is available only when Reject If Future Changes is set to "No".
	--    If set to "Yes", set Date Effective Changes to "Update/Change Insert".
	--
	elsif (p_date_effective_changes is null)
	or    ((p_reject_if_future_changes = 'Y') and (p_date_effective_changes = 'O')) then
		p_date_effective_changes := 'U';
	end if;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end chk_date_effective_changes;
-- ----------------------------------------------------------------------------
-- |--------------------------------< get_iv >--------------------------------|
-- ----------------------------------------------------------------------------
procedure get_iv(
	p_element_type_id		in number,
	p_effective_date		in date,
	p_eev_rec		 out nocopy t_eev_rec)
is
	l_proc		varchar2(61) := c_package || 'get_iv';
	--
	cursor csr_iv is
		select	ivtl.name,
			iv.mandatory_flag,
			iv.hot_default_flag,
			iv.lookup_type,
			iv.default_value,
			null,
			null
		from	pay_input_values_f_tl	ivtl,
			pay_input_values_f	iv
		where	iv.element_type_id = p_element_type_id
		and	p_effective_date
			between iv.effective_start_date and iv.effective_end_date
		and	ivtl.input_value_id = iv.input_value_id
		and	ivtl.language = userenv('LANG')
		order by iv.display_sequence;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	open csr_iv;
	fetch csr_iv bulk collect into
		p_eev_rec.name_tbl,
		p_eev_rec.mandatory_flag_tbl,
		p_eev_rec.hot_default_flag_tbl,
		p_eev_rec.lookup_type_tbl,
		p_eev_rec.default_value_tbl,
		p_eev_rec.liv_default_value_tbl,
		p_eev_rec.entry_value_tbl;
	close csr_iv;
	--
/*
	for i in 1..p_eev_rec.entry_value_tbl.count loop
		hr_utility.trace('**********');
		hr_utility.trace('name              : ' || p_eev_rec.name_tbl(i));
		hr_utility.trace('mandatory_flag    : ' || p_eev_rec.mandatory_flag_tbl(i));
		hr_utility.trace('hot_default_flag  : ' || p_eev_rec.hot_default_flag_tbl(i));
		hr_utility.trace('lookup_type       : ' || p_eev_rec.lookup_type_tbl(i));
		hr_utility.trace('default_value     : ' || p_eev_rec.default_value_tbl(i));
--		hr_utility.trace('liv_default_value : ' || p_eev_rec.liv_default_value_tbl(i));
--		hr_utility.trace('entry_value       : ' || p_eev_rec.entry_value_tbl(i));
	end loop;
*/
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end get_iv;
-- ----------------------------------------------------------------------------
-- |--------------------------------< get_ee >--------------------------------|
-- ----------------------------------------------------------------------------
procedure get_ee(
	p_assignment_id			in number,
	p_element_type_id		in number,
	p_effective_date		in date,
	p_ee_rec		 out nocopy t_ee_rec,
	p_eev_rec		 out nocopy t_eev_rec)
is
	l_proc		varchar2(61) := c_package || 'get_ee';
	--
	cursor csr_ee is
		select	/*+ ORDERED */
			ee.element_entry_id,
			ee.effective_start_date,
			ee.effective_end_date,
			ee.element_link_id,
			ee.cost_allocation_keyflex_id,
			cak.concatenated_segments,
			cak.segment1,
			cak.segment2,
			cak.segment3,
			cak.segment4,
			cak.segment5,
			cak.segment6,
			cak.segment7,
			cak.segment8,
			cak.segment9,
			cak.segment10,
			cak.segment11,
			cak.segment12,
			cak.segment13,
			cak.segment14,
			cak.segment15,
			cak.segment16,
			cak.segment17,
			cak.segment18,
			cak.segment19,
			cak.segment20,
			cak.segment21,
			cak.segment22,
			cak.segment23,
			cak.segment24,
			cak.segment25,
			cak.segment26,
			cak.segment27,
			cak.segment28,
			cak.segment29,
			cak.segment30,
			ee.reason,
			ee.attribute_category,
			ee.attribute1,
			ee.attribute2,
			ee.attribute3,
			ee.attribute4,
			ee.attribute5,
			ee.attribute6,
			ee.attribute7,
			ee.attribute8,
			ee.attribute9,
			ee.attribute10,
			ee.attribute11,
			ee.attribute12,
			ee.attribute13,
			ee.attribute14,
			ee.attribute15,
			ee.attribute16,
			ee.attribute17,
			ee.attribute18,
			ee.attribute19,
			ee.attribute20,
			ee.entry_information_category,
			ee.entry_information1,
			ee.entry_information2,
			ee.entry_information3,
			ee.entry_information4,
			ee.entry_information5,
			ee.entry_information6,
			ee.entry_information7,
			ee.entry_information8,
			ee.entry_information9,
			ee.entry_information10,
			ee.entry_information11,
			ee.entry_information12,
			ee.entry_information13,
			ee.entry_information14,
			ee.entry_information15,
			ee.entry_information16,
			ee.entry_information17,
			ee.entry_information18,
			ee.entry_information19,
			ee.entry_information20,
			ee.entry_information21,
			ee.entry_information22,
			ee.entry_information23,
			ee.entry_information24,
			ee.entry_information25,
			ee.entry_information26,
			ee.entry_information27,
			ee.entry_information28,
			ee.entry_information29,
			ee.entry_information30,
			ee.date_earned,
			ee.personal_payment_method_id,
			ee.subpriority
		from	per_all_assignments_f		asg,
			pay_element_links_f		el,
			pay_element_entries_f		ee,
			pay_cost_allocation_keyflex	cak
		where	asg.assignment_id = p_assignment_id
		and	p_effective_date
			between asg.effective_start_date and asg.effective_end_date
		and	el.element_type_id = p_element_type_id
		and	el.business_group_id + 0 = asg.business_group_id
		and	p_effective_date
			between el.effective_start_date and el.effective_end_date
		and	ee.assignment_id = asg.assignment_id
		and	ee.element_link_id = el.element_link_id
		and	p_effective_date
			between ee.effective_start_date and ee.effective_end_date
		and	ee.entry_type = 'E'
		and	cak.cost_allocation_keyflex_id(+) = ee.cost_allocation_keyflex_id;
	cursor csr_eev is
		select	/*+ ORDERED */
			ivtl.name,
			iv.mandatory_flag,
			iv.hot_default_flag,
			iv.lookup_type,
			iv.default_value,
			liv.default_value,
			eev.screen_entry_value
		from	pay_element_entry_values_f	eev,
			pay_link_input_values_f		liv,
			pay_input_values_f		iv,
			pay_input_values_f_tl		ivtl
		where	eev.element_entry_id = p_ee_rec.element_entry_id
		and	eev.effective_start_date = p_ee_rec.effective_start_date
		and	eev.effective_end_date = p_ee_rec.effective_end_date
		and	liv.element_link_id = p_ee_rec.element_link_id
		and	liv.input_value_id = eev.input_value_id
		and	p_effective_date
			between liv.effective_start_date and liv.effective_end_date
		and	iv.input_value_id = liv.input_value_id
		and	p_effective_date
			between iv.effective_start_date and iv.effective_end_date
		and	ivtl.input_value_id = iv.input_value_id
		and	ivtl.language = userenv('LANG')
		order by iv.display_sequence;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	open csr_ee;
	fetch csr_ee into p_ee_rec;
	--
	hr_utility.trace('element_entry_id     : ' || to_char(p_ee_rec.element_entry_id));
	hr_utility.trace('effective_start_date : ' || to_char(p_ee_rec.effective_start_date));
	hr_utility.trace('effective_end_date   : ' || to_char(p_ee_rec.effective_end_date));
	hr_utility.trace('element_link_id      : ' || to_char(p_ee_rec.element_link_id));
	--
	-- If element entry exists, derive element entry values
	--
	if csr_ee%FOUND then
		hr_utility.set_location(l_proc, 15);
		--
		open csr_eev;
		fetch csr_eev bulk collect into
			p_eev_rec.name_tbl,
			p_eev_rec.mandatory_flag_tbl,
			p_eev_rec.hot_default_flag_tbl,
			p_eev_rec.lookup_type_tbl,
			p_eev_rec.default_value_tbl,
			p_eev_rec.liv_default_value_tbl,
			p_eev_rec.entry_value_tbl;
		close csr_eev;
		--
/*
		for i in 1..p_eev_rec.entry_value_tbl.count loop
			hr_utility.trace('**********');
			hr_utility.trace('name              : ' || p_eev_rec.name_tbl(i));
			hr_utility.trace('mandatory_flag    : ' || p_eev_rec.mandatory_flag_tbl(i));
			hr_utility.trace('hot_default_flag  : ' || p_eev_rec.hot_default_flag_tbl(i));
			hr_utility.trace('lookup_type       : ' || p_eev_rec.lookup_type_tbl(i));
			hr_utility.trace('default_value     : ' || p_eev_rec.default_value_tbl(i));
			hr_utility.trace('liv_default_value : ' || p_eev_rec.liv_default_value_tbl(i));
			hr_utility.trace('entry_value       : ' || p_eev_rec.entry_value_tbl(i));
		end loop;
*/
	--
	-- If element entry does not exist, derive input values definition.
	-- Note link input value default value is not derived because element link is unknown.
	-- It is not smart way to derive element_link_id here which should be done BEE validation process.
	--
	else
		hr_utility.set_location(l_proc, 16);
		--
		p_ee_rec := null;
		--
		get_iv(
			p_element_type_id	=> p_element_type_id,
			p_effective_date	=> p_effective_date,
			p_eev_rec		=> p_eev_rec);
	end if;
	close csr_ee;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end get_ee;
-- ----------------------------------------------------------------------------
-- |-------------------------------< set_eev >--------------------------------|
-- ----------------------------------------------------------------------------
procedure set_eev(
	p_ee_rec			in t_ee_rec,
	p_eev_rec			in t_eev_rec,
	p_value_if_null_tbl		in t_varchar2_tbl,
	p_new_value_tbl			in out nocopy t_varchar2_tbl,
	p_is_different		 out nocopy boolean)
is
	l_proc		varchar2(61) := c_package || 'set_eev';
	--
	l_index		number;
	l_default_value	pay_input_values_f.default_value%TYPE;
	l_entry_value	pay_element_entry_values_f.screen_entry_value%TYPE;
	l_new_value	pay_element_entry_values_f.screen_entry_value%TYPE;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	-- If element entry does not exist.
	-- In this case, delete the entry from PL/SQL table for non-enterable input values.
	--
	if p_ee_rec.element_entry_id is null then
		p_is_different	:= true;
		l_index		:= p_new_value_tbl.first;
		while l_index is not null loop
			hr_utility.trace('Set IV' || to_char(l_index));
			--
			if p_eev_rec.mandatory_flag_tbl(l_index) = 'X' then
				hr_utility.trace('entry_value not enterable.');
				--
				-- delete the entry from PL/SQL table.
				--
				p_new_value_tbl.delete(l_index);
			end if;
			--
			l_index := p_new_value_tbl.next(l_index);
		end loop;
	--
	-- If element entry exists.
	-- Compare each new_value with the current entry_value.
	--
	else
		p_is_different := false;
		for i in 1..p_eev_rec.mandatory_flag_tbl.count loop
			hr_utility.trace('Compare IV' || to_char(i));
			--
			-- Current entry_value is inherited in the following cases.
			-- 1. The input value is not user enterable.
			-- 2. The entry_value is not target to be transfered.
			-- Note that current value will be inherited regardless of BEE value
			-- for non-enterable input value.
			--
			if p_eev_rec.mandatory_flag_tbl(i) = 'X' then
				hr_utility.trace('entry_value not enterable.');
				--
				-- delete the entry from PL/SQL table.
				-- If the entry does not exist, nothing happens.
				--
				p_new_value_tbl.delete(i);
			elsif not p_new_value_tbl.exists(i) then
				hr_utility.trace('entry_value not target.');
				p_new_value_tbl(i) := p_eev_rec.entry_value_tbl(i);
			else
				if p_eev_rec.hot_default_flag_tbl(i) = 'Y' then
					l_default_value	:= nvl(p_eev_rec.liv_default_value_tbl(i), p_eev_rec.default_value_tbl(i));
					l_entry_value	:= nvl(nvl(p_eev_rec.entry_value_tbl(i), l_default_value), p_value_if_null_tbl(i));
					l_new_value	:= nvl(nvl(p_new_value_tbl(i), l_default_value), p_value_if_null_tbl(i));
				else
					l_default_value	:= p_eev_rec.liv_default_value_tbl(i);
					l_entry_value	:= nvl(p_eev_rec.entry_value_tbl(i), p_value_if_null_tbl(i));
					l_new_value	:= nvl(p_new_value_tbl(i), p_value_if_null_tbl(i));
				end if;
				--
				-- If new_value is different from current entry_value,
				-- override it with the new_value. Or inherit the existing value.
				--
				if l_new_value <> l_entry_value then
					hr_utility.trace('IV different');
					--
					p_is_different := true;
					--
					-- Set new entry value to PL/SQL table l_entry_value
					-- When the following condition, entry_value can be null.
					-- 1. When entry value is the same value as hot defaulted value.
					-- 2. When entry value is the same value as "value when null"
					--    and default_value is also null.
					--
					if p_new_value_tbl(i) is not null then
						if ((p_eev_rec.hot_default_flag_tbl(i) = 'Y') and (l_new_value = l_default_value))
						or ((p_eev_rec.mandatory_flag_tbl(i) = 'N') and (l_default_value is null) and (l_new_value = p_value_if_null_tbl(i))) then
							p_new_value_tbl(i) := null;
						end if;
					end if;
				else
					hr_utility.trace('IV same');
					p_new_value_tbl(i) := p_eev_rec.entry_value_tbl(i);
				end if;
			end if;
		end loop;
	end if;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end set_eev;
-- ----------------------------------------------------------------------------
-- |---------------------------------< log >----------------------------------|
-- ----------------------------------------------------------------------------
procedure log(
	p_full_name			in varchar2,
	p_assignment_number		in varchar2,
	p_application_short_name	in varchar2,
	p_message_name			in varchar2,
	p_token1			in varchar2 default null,
	p_value1			in varchar2 default null,
	p_token2			in varchar2 default null,
	p_value2			in varchar2 default null,
	p_token3			in varchar2 default null,
	p_value3			in varchar2 default null,
	p_token4			in varchar2 default null,
	p_value4			in varchar2 default null,
	p_token5			in varchar2 default null,
	p_value5			in varchar2 default null)
is
	l_message_text	varchar2(2000);
	--
	procedure set_token(
		p_token	in varchar2,
		p_value	in varchar2)
	is
	begin
		if p_token is not null then
			fnd_message.set_token(p_token, p_value);
		end if;
	end set_token;
begin
	--
	-- Write log header
	--
	if g_num_of_logs = 0 then
		fnd_file.put_line(fnd_file.log,
			rtrim(
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'FULL_NAME'),         30) || ' ' ||
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'ASSIGNMENT_NUMBER'), 15) || ' ' ||
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'LOG'),               85)
			));
		fnd_file.put_line(fnd_file.log,
			rpad('-', 30, '-') || ' ' ||
			rpad('-', 15, '-') || ' ' ||
			rpad('-', 85, '-')
			);
	end if;
	--
	g_num_of_logs := g_num_of_logs + 1;
	--
	-- Derive message text from fnd_new_messages
	--
	fnd_message.set_name(p_application_short_name, p_message_name);
	set_token(p_token1, p_value1);
	set_token(p_token2, p_value2);
	set_token(p_token3, p_value3);
	set_token(p_token4, p_value4);
	set_token(p_token5, p_value5);
	l_message_text := fnd_message.get;
	--
	-- Write message text
	--
	fnd_file.put_line(fnd_file.log,
		rtrim(
			rpad(p_full_name,         30) || ' ' ||
			rpad(p_assignment_number, 15) || ' ' ||
			rpad(l_message_text,      85)
		));
end log;
-- ----------------------------------------------------------------------------
-- |---------------------------------< out >----------------------------------|
-- ----------------------------------------------------------------------------
procedure out(
	p_full_name			in varchar2,
	p_assignment_number		in varchar2,
	p_effective_date		in date,
	p_change_type			in varchar2,
	p_eev_rec			in t_eev_rec,
	p_new_value_tbl			in t_varchar2_tbl,
	p_write_all			in boolean)
is
	l_index		number;
	l_old_value	hr_lookups.meaning%type;
	l_new_value	hr_lookups.meaning%type;
	l_break		boolean := true;
begin
	--
	-- Write output header
	--
	if g_num_of_outs = 0 then
		fnd_file.put_line(fnd_file.output,
			rtrim(
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'FULL_NAME'),         30) || ' ' ||
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'ASSIGNMENT_NUMBER'), 15) || ' ' ||
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'CHANGE_DATE'),       11) || ' ' ||
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'CHANGE_TYPE'),        4) || ' ' ||
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'INPUT_VALUE'),       14) || ' ' ||
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'BEFORE_CHANGE'),     26) || ' ' ||
				rpad(hr_general.decode_lookup(c_prompt_lookup_type, 'AFTER_CHANGE'),      26)
			));
		fnd_file.put_line(fnd_file.output,
			rpad('-', 30, '-') || ' ' ||
			rpad('-', 15, '-') || ' ' ||
			rpad('-', 11, '-') || ' ' ||
			rpad('-',  4, '-') || ' ' ||
			rpad('-', 14, '-') || ' ' ||
			rpad('-', 26, '-') || ' ' ||
			rpad('-', 26, '-')
			);
	end if;
	--
	g_num_of_outs := g_num_of_outs + 1;
	--
	l_index := p_new_value_tbl.first;
	while l_index is not null loop
		l_old_value := p_eev_rec.entry_value_tbl(l_index);
		l_new_value := p_new_value_tbl(l_index);
		--
		-- The data is written in the following cases.
		-- 1. p_write_all is set to "True".
		-- 2. new_value is different from old_value.
		--
		if (p_write_all)
		or (nvl(l_new_value, hr_api.g_varchar2) <> nvl(l_old_value, hr_api.g_varchar2)) then
			if p_eev_rec.lookup_type_tbl(l_index) is not null then
				l_old_value := hr_general.decode_lookup(p_eev_rec.lookup_type_tbl(l_index), l_old_value);
				l_new_value := hr_general.decode_lookup(p_eev_rec.lookup_type_tbl(l_index), l_new_value);
			end if;
			--
			-- Write output data.
			-- The heading some items are only written in the first record
			-- which is similar to "BREAK ON" on SQL*Plus.
			--
			if l_break then
				l_break := false;
				--
				fnd_file.put_line(fnd_file.output,
					rtrim(
						rpad(p_full_name,                                                  30) || ' ' ||
						rpad(p_assignment_number,                                          15) || ' ' ||
						rpad(fnd_date.date_to_chardate(p_effective_date),                  11) || ' ' ||
						rpad(hr_general.decode_lookup(c_prompt_lookup_type, p_change_type), 4) || ' ' ||
						rpad(p_eev_rec.name_tbl(l_index),                                  14) || ' ' ||
						rpad(nvl(l_old_value, ' '),                                        26) || ' ' ||
						rpad(nvl(l_new_value, ' '),                                        26)
					));
			else
				fnd_file.put_line(fnd_file.output,
					rtrim(
						rpad(' ',                           30) || ' ' ||
						rpad(' ',                           15) || ' ' ||
						rpad(' ',                           11) || ' ' ||
						rpad(' ',                            4) || ' ' ||
						rpad(p_eev_rec.name_tbl(l_index),   14) || ' ' ||
						rpad(nvl(l_old_value, ' '),         26) || ' ' ||
						rpad(nvl(l_new_value, ' '),         26)
					));
			end if;
		end if;
		--
		l_index := p_new_value_tbl.next(l_index);
	end loop;
end out;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_batch_line >---------------------------|
-- ----------------------------------------------------------------------------
procedure create_batch_line(
	p_batch_id			in number,
	p_assignment_id			in number,
	p_assignment_number		in varchar2,
	p_element_type_id		in number,
	p_element_name			in varchar2,
	p_effective_date		in date,
	p_ee_rec			in t_ee_rec,
	p_eev_rec			in t_eev_rec,
	p_batch_line_id		 out nocopy number,
	p_object_version_number	 out nocopy number)
is
	l_proc		varchar2(61) := c_package || 'create_batch_line';
	l_bee_rowid	rowid;
	l_value_1	pay_batch_lines.value_1%TYPE;
	l_value_2	pay_batch_lines.value_2%TYPE;
	l_value_3	pay_batch_lines.value_3%TYPE;
	l_value_4	pay_batch_lines.value_4%TYPE;
	l_value_5	pay_batch_lines.value_5%TYPE;
	l_value_6	pay_batch_lines.value_6%TYPE;
	l_value_7	pay_batch_lines.value_7%TYPE;
	l_value_8	pay_batch_lines.value_8%TYPE;
	l_value_9	pay_batch_lines.value_9%TYPE;
	l_value_10	pay_batch_lines.value_10%TYPE;
	l_value_11	pay_batch_lines.value_11%TYPE;
	l_value_12	pay_batch_lines.value_12%TYPE;
	l_value_13	pay_batch_lines.value_13%TYPE;
	l_value_14	pay_batch_lines.value_14%TYPE;
	l_value_15	pay_batch_lines.value_15%TYPE;
	--
	function decode_entry_value(p_index in number) return varchar2
	is
		l_value	pay_batch_lines.value_1%TYPE;
	begin
		if p_eev_rec.entry_value_tbl.exists(p_index) then
			if p_eev_rec.lookup_type_tbl(p_index) is null then
				l_value := p_eev_rec.entry_value_tbl(p_index);
			else
				l_value := hr_general.decode_lookup(p_eev_rec.lookup_type_tbl(p_index), p_eev_rec.entry_value_tbl(p_index));
			end if;
			--
			hr_utility.trace(rpad('value_' || to_char(p_index), 8) || ' : ' || l_value);
		end if;
		--
		return l_value;
	end decode_entry_value;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	l_value_1 := decode_entry_value(1);
	l_value_2 := decode_entry_value(2);
	l_value_3 := decode_entry_value(3);
	l_value_4 := decode_entry_value(4);
	l_value_5 := decode_entry_value(5);
	l_value_6 := decode_entry_value(6);
	l_value_7 := decode_entry_value(7);
	l_value_8 := decode_entry_value(8);
	l_value_9 := decode_entry_value(9);
	l_value_10 := decode_entry_value(10);
	l_value_11 := decode_entry_value(11);
	l_value_12 := decode_entry_value(12);
	l_value_13 := decode_entry_value(13);
	l_value_14 := decode_entry_value(14);
	l_value_15 := decode_entry_value(15);
	--
	-- Create BEE Line into PAY_BATCH_LINES
	--
	pay_batch_element_entry_api.create_batch_line(
		p_validate			=> false,
		p_session_date			=> p_effective_date,
		p_batch_id			=> p_batch_id,
		p_assignment_id 		=> p_assignment_id,
		p_assignment_number		=> p_assignment_number,
		p_attribute_category		=> p_ee_rec.attribute_category,
		p_attribute1			=> p_ee_rec.attribute1,
		p_attribute2			=> p_ee_rec.attribute2,
		p_attribute3			=> p_ee_rec.attribute3,
		p_attribute4			=> p_ee_rec.attribute4,
		p_attribute5			=> p_ee_rec.attribute5,
		p_attribute6			=> p_ee_rec.attribute6,
		p_attribute7			=> p_ee_rec.attribute7,
		p_attribute8			=> p_ee_rec.attribute8,
		p_attribute9			=> p_ee_rec.attribute9,
		p_attribute10			=> p_ee_rec.attribute10,
		p_attribute11			=> p_ee_rec.attribute11,
		p_attribute12			=> p_ee_rec.attribute12,
		p_attribute13			=> p_ee_rec.attribute13,
		p_attribute14			=> p_ee_rec.attribute14,
		p_attribute15			=> p_ee_rec.attribute15,
		p_attribute16			=> p_ee_rec.attribute16,
		p_attribute17			=> p_ee_rec.attribute17,
		p_attribute18			=> p_ee_rec.attribute18,
		p_attribute19			=> p_ee_rec.attribute19,
		p_attribute20			=> p_ee_rec.attribute20,
		p_entry_information_category	=> p_ee_rec.entry_information_category,
		p_entry_information1		=> p_ee_rec.entry_information1,
		p_entry_information2		=> p_ee_rec.entry_information2,
		p_entry_information3		=> p_ee_rec.entry_information3,
		p_entry_information4		=> p_ee_rec.entry_information4,
		p_entry_information5		=> p_ee_rec.entry_information5,
		p_entry_information6		=> p_ee_rec.entry_information6,
		p_entry_information7		=> p_ee_rec.entry_information7,
		p_entry_information8		=> p_ee_rec.entry_information8,
		p_entry_information9		=> p_ee_rec.entry_information9,
		p_entry_information10		=> p_ee_rec.entry_information10,
		p_entry_information11		=> p_ee_rec.entry_information11,
		p_entry_information12		=> p_ee_rec.entry_information12,
		p_entry_information13		=> p_ee_rec.entry_information13,
		p_entry_information14		=> p_ee_rec.entry_information14,
		p_entry_information15		=> p_ee_rec.entry_information15,
		p_entry_information16		=> p_ee_rec.entry_information16,
		p_entry_information17		=> p_ee_rec.entry_information17,
		p_entry_information18		=> p_ee_rec.entry_information18,
		p_entry_information19		=> p_ee_rec.entry_information19,
		p_entry_information20		=> p_ee_rec.entry_information20,
		p_entry_information21		=> p_ee_rec.entry_information21,
		p_entry_information22		=> p_ee_rec.entry_information22,
		p_entry_information23		=> p_ee_rec.entry_information23,
		p_entry_information24		=> p_ee_rec.entry_information24,
		p_entry_information25		=> p_ee_rec.entry_information25,
		p_entry_information26		=> p_ee_rec.entry_information26,
		p_entry_information27		=> p_ee_rec.entry_information27,
		p_entry_information28		=> p_ee_rec.entry_information28,
		p_entry_information29		=> p_ee_rec.entry_information29,
		p_entry_information30		=> p_ee_rec.entry_information30,
		p_date_earned			=> p_ee_rec.date_earned,
		p_personal_payment_method_id	=> p_ee_rec.personal_payment_method_id,
		p_subpriority			=> p_ee_rec.subpriority,
		p_concatenated_segments 	=> p_ee_rec.concatenated_segments ,
		p_cost_allocation_keyflex_id	=> p_ee_rec.cost_allocation_keyflex_id,
		p_effective_date		=> p_effective_date,
		p_element_name			=> p_element_name,
		p_element_type_id		=> p_element_type_id,
		p_entry_type			=> 'E',
		p_reason			=> p_ee_rec.reason,
		p_segment1			=> p_ee_rec.segment1,
		p_segment2			=> p_ee_rec.segment2,
		p_segment3			=> p_ee_rec.segment3,
		p_segment4			=> p_ee_rec.segment4,
		p_segment5			=> p_ee_rec.segment5,
		p_segment6			=> p_ee_rec.segment6,
		p_segment7			=> p_ee_rec.segment7,
		p_segment8			=> p_ee_rec.segment8,
		p_segment9			=> p_ee_rec.segment9,
		p_segment10			=> p_ee_rec.segment10,
		p_segment11			=> p_ee_rec.segment11,
		p_segment12			=> p_ee_rec.segment12,
		p_segment13			=> p_ee_rec.segment13,
		p_segment14			=> p_ee_rec.segment14,
		p_segment15			=> p_ee_rec.segment15,
		p_segment16			=> p_ee_rec.segment16,
		p_segment17			=> p_ee_rec.segment17,
		p_segment18			=> p_ee_rec.segment18,
		p_segment19			=> p_ee_rec.segment19,
		p_segment20			=> p_ee_rec.segment20,
		p_segment21			=> p_ee_rec.segment21,
		p_segment22			=> p_ee_rec.segment22,
		p_segment23			=> p_ee_rec.segment23,
		p_segment24			=> p_ee_rec.segment24,
		p_segment25			=> p_ee_rec.segment25,
		p_segment26			=> p_ee_rec.segment26,
		p_segment27			=> p_ee_rec.segment27,
		p_segment28			=> p_ee_rec.segment28,
		p_segment29			=> p_ee_rec.segment29,
		p_segment30			=> p_ee_rec.segment30,
		p_value_1			=> l_value_1,
		p_value_2			=> l_value_2,
		p_value_3			=> l_value_3,
		p_value_4			=> l_value_4,
		p_value_5			=> l_value_5,
		p_value_6			=> l_value_6,
		p_value_7			=> l_value_7,
		p_value_8			=> l_value_8,
		p_value_9			=> l_value_9,
		p_value_10			=> l_value_10,
		p_value_11			=> l_value_11,
		p_value_12			=> l_value_12,
		p_value_13			=> l_value_13,
		p_value_14			=> l_value_14,
		p_value_15			=> l_value_15,
		p_batch_line_id 		=> p_batch_line_id,
		p_object_version_number 	=> p_object_version_number);
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end create_batch_line;
--
end pay_jp_bee_utility_pkg;

/
