--------------------------------------------------------
--  DDL for Package Body PER_JP_CTR_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_CTR_UTILITY_PKG" as
/* $Header: pejpctru.pkb 120.1 2005/11/28 22:02:05 ttagawa noship $ */
--
-- Constants
--
c_package			constant varchar2(31) := 'per_jp_ctr_utility_pkg.';
c_default_itax_dpnt_ref_type	constant hr_lookups.lookup_code%type := 'CTR_EE';
c_kou_information_type		constant per_contact_extra_info_f.information_type%TYPE := 'JP_ITAX_DEPENDENT';
c_otsu_information_type		constant per_contact_extra_info_f.information_type%TYPE := 'JP_ITAX_DEPENDENT_ON_OTHER_PAY';
c_husband_kanji			constant hr_lookups.meaning%type := fnd_message.get_string('PAY', 'PAY_JP_HUSBAND');
c_husband_kana			constant hr_lookups.meaning%type := hr_jp_standard_pkg.upper_kana(fnd_message.get_string('PAY', 'PAY_JP_HUSBAND_KANA'));
c_wife_kanji			constant hr_lookups.meaning%type := fnd_message.get_string('PAY', 'PAY_JP_WIFE');
c_wife_kana			constant hr_lookups.meaning%type := hr_jp_standard_pkg.upper_kana(fnd_message.get_string('PAY', 'PAY_JP_WIFE_KANA'));
--
-- Global Variables
-- Cache Information
--
g_itax_dpnt_rec	t_itax_dpnt_rec;
--
type t_bg_itax_dpnt_rec is record(
	business_group_id	number,
	ref_type		hr_lookups.lookup_code%type);
g_bg_itax_dpnt_rec	t_bg_itax_dpnt_rec;
-- ----------------------------------------------------------------------------
-- |------------------------< bg_itax_dpnt_ref_type >-------------------------|
-- ----------------------------------------------------------------------------
function bg_itax_dpnt_ref_type(p_business_group_id in number) return varchar2
is
	cursor csr_bg is
		select	org_information2
		from	hr_organization_information
		where	organization_id = p_business_group_id
		and	org_information_context = 'JP_BUSINESS_GROUP_INFO';
begin
	--
	-- Use cache if available
	--
	if (g_bg_itax_dpnt_rec.business_group_id is null)
	or (g_bg_itax_dpnt_rec.business_group_id <> p_business_group_id) then
		g_bg_itax_dpnt_rec.business_group_id := p_business_group_id;
		--
		open csr_bg;
		fetch csr_bg into g_bg_itax_dpnt_rec.ref_type;
		if (csr_bg%notfound) or (g_bg_itax_dpnt_rec.ref_type is null) then
			g_bg_itax_dpnt_rec.ref_type := c_default_itax_dpnt_ref_type;
		end if;
		close csr_bg;
	end if;
	--
	return g_bg_itax_dpnt_rec.ref_type;
end bg_itax_dpnt_ref_type;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_itax_dpnt_info >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to derive dependent information from
--   PER_CONTACT_RELATIONSHIPS
--   PER_CONTACT_EXTRA_INFO_F
--
-- ----------------------------------------------------------------------------
procedure get_itax_dpnt_info(
	p_assignment_id			in number,
	p_itax_type			in varchar2,
	p_effective_date		in date,
	p_itax_dpnt_rec		 out nocopy t_itax_dpnt_rec,
	p_use_cache			in boolean default TRUE)
is
	l_proc			varchar2(61) := c_package || 'get_itax_dpnt_info';
	l_effective_date	date := p_effective_date;
	l_soy			date;
	l_eoy			date;
	l_information_type	per_contact_extra_info_f.information_type%TYPE;
	l_index			number := 0;
	--
	-- Note that the age used below is January 1st in the next calendar year.
	-- Normally, effective date used is date paid, but if contact person is deceased,
	-- date_of_death is used as effective date instead.
	--
--	cursor csr_dpnt(p_information_type varchar2) is
--		select	/*+ ORDERED */
----			v.effective_date,
----			v.date_of_birth,
----			v.date_of_death,
--			v.contact_type,
--			cei.contact_extra_info_id,
--			/* Note to add 1 day to effective_date(This is JP legal age calculation rule). */
--			trunc(months_between(
--				decode(v.effective_date, v.date_of_death, v.date_of_death, l_eoy) + 1,
--				v.date_of_birth) / 12)	AGE,
--			--
--			-- The following 2 flags are available only for "KOU",
--			-- not available for "OTSU".
--			--
--			decode(cei.information_type, c_kou_information_type, cei.cei_information1, null)		AGED_DPNT_PARENTS_LT_TYPE,
--			decode(cei.information_type, c_kou_information_type, cei.cei_information6, null)		DSBL_TYPE,
--			decode(v.contact_type, 'S', decode(v.sex, 'F', c_wife_kanji, c_husband_kanji), hrl1.meaning)	D_CONTACT_TYPE_KANJI,
--			decode(v.contact_type, 'S', decode(v.sex, 'F', c_wife_kana, c_husband_kana), hrl2.meaning)	D_CONTACT_TYPE_KANA,
--			v.last_name_kanji,
--			v.first_name_kanji,
--			v.last_name_kana,
--			v.first_name_kana
--		from	(
--				select	ctr.contact_relationship_id,
--					ctr.contact_type,
--					ctr.date_start,
--					ctr.date_end,
--					per.sex,
--					per.per_information18							LAST_NAME_KANJI,
--					per.per_information19							FIRST_NAME_KANJI,
--					per.last_name								LAST_NAME_KANA,
--					per.first_name								FIRST_NAME_KANA,
--					per.date_of_birth,
--					per.date_of_death,
--					nvl(least(per.date_of_death, l_effective_date), l_effective_date)	EFFECTIVE_DATE,
--					to_number(ctr.cont_information2)					SEQUENCE
--				from	per_all_assignments_f		asg,
--					per_contact_relationships	ctr,
--					per_all_people_f		per
--				where	asg.assignment_id = p_assignment_id
--				and	l_effective_date
--					between asg.effective_start_date and asg.effective_end_date
--				and	ctr.person_id = asg.person_id
--				/* Only primary contact relationship */
--				and	ctr.cont_information1 = 'Y'
--				/* We need to take deceased case into consideration. When deceased,
--				   we need to get information as of date_of_death, not effective_date.
--				   Here only narrows date range within calendar year. */
--				and	nvl(ctr.date_end, l_soy) >= l_soy
--				and	nvl(ctr.date_start, l_effective_date) <= l_effective_date
--				and	per.person_id = ctr.contact_person_id
--				and	(
--							(
--								l_effective_date
--								between per.effective_start_date and per.effective_end_date
--							)
--						or	(
--								per.effective_start_date = per.start_date
--							and	not exists(
--									select	null
--									from	per_all_people_f	per2
--									where	per2.person_id = per.person_id
--									and	l_effective_date
--										between per2.effective_start_date and per2.effective_end_date)
--							)
--					)
--				/* Deceased person is available until the end of year in which the effective_date falls. */
--				and	nvl(trunc(per.date_of_death, 'YYYY'), l_soy) >= l_soy
--			)				v,
--			per_contact_extra_info_f	cei,
--			hr_lookups			hrl1,
--			hr_lookups			hrl2
--		/* Here again narrows CTR date range either date_of_death or effective_date. */
--		where	v.effective_date
--			between nvl(v.date_start, v.effective_date) and nvl(v.date_end, v.effective_date)
--		and	cei.contact_relationship_id(+) = v.contact_relationship_id
--		and	cei.information_type(+) = p_information_type
--		and	v.effective_date
--			between cei.effective_start_date(+) and cei.effective_end_date(+)
--		/* We need to get spouse CTR information even the CTR does not have CEI information. */
--		and	((v.contact_type = 'S') or (cei.information_type is not null))
--		and	hrl1.lookup_type = 'CONTACT'
--		and	hrl1.lookup_code = v.contact_type
--		and	hrl2.lookup_type(+) = 'JP_CONTACT_KANA'
--		and	hrl2.lookup_code(+) = hrl1.lookup_code
--		order by
--			decode(v.contact_type, 'S', 1, 2),
--			v.sequence,
--			v.date_of_birth,
--			decode(v.sex, 'F', 2, 1),
--			v.last_name_kana,
--			v.first_name_kana;
	cursor csr_dpnt(p_information_type varchar2) is
		select	/*+ ORDERED PUSH_SUBQ */
			ctr.contact_type,
			cei.contact_extra_info_id,
			/* Note to add 1 day to effective_date(This is JP legal age calculation rule). */
			trunc(months_between(
				decode(nvl(least(per.date_of_death, l_effective_date), l_effective_date), per.date_of_death, per.date_of_death, l_eoy) + 1,
				per.date_of_birth) / 12)	AGE,
			--
			-- The following 2 flags are available only for "KOU",
			-- not available for "OTSU".
			--
			decode(cei.information_type, c_kou_information_type, cei.cei_information1, null)			AGED_DPNT_PARENTS_LT_TYPE,
			decode(cei.information_type, c_kou_information_type, cei.cei_information6, null)			DSBL_TYPE,
			decode(ctr.contact_type, 'S', decode(per.sex, 'F', c_wife_kanji, c_husband_kanji), hrl1.meaning)	D_CONTACT_TYPE_KANJI,
			decode(ctr.contact_type, 'S', decode(per.sex, 'F', c_wife_kana, c_husband_kana), hrl2.meaning)		D_CONTACT_TYPE_KANA,
			per.per_information18	LAST_NAME_KANJI,
			per.per_information19	FIRST_NAME_KANJI,
			per.last_name		LAST_NAME_KANA,
			per.first_name		FIRST_NAME_KANA
		from	per_all_assignments_f		asg,
			per_contact_relationships	ctr,
			per_contact_extra_info_f	cei,
			per_all_people_f		per,
			hr_lookups			hrl1,
			hr_lookups			hrl2
		where	asg.assignment_id = p_assignment_id
		and	l_effective_date
			between asg.effective_start_date and asg.effective_end_date
		and	ctr.person_id = asg.person_id
		and	cei.contact_relationship_id(+) = ctr.contact_relationship_id
		and	cei.information_type(+) = p_information_type
		and	l_effective_date
			between cei.effective_start_date(+) and cei.effective_end_date(+)
		/* We need to get "Spouse" CTR information even
		   1) CTR does not have CEI information.
		   2) CTR does not exist as of effective_date. */
		and	(	cei.information_type is not null
			or	(
					ctr.contact_type = 'S'
				and	l_effective_date
					between nvl(ctr.date_start, l_effective_date) and nvl(ctr.date_end, l_effective_date)
				)
			)
		and	per.person_id = ctr.contact_person_id
		and	(
					(
						l_effective_date
						between per.effective_start_date and per.effective_end_date
					)
				or	(
						per.effective_start_date = per.start_date
					and	not exists(
							select	null
							from	per_all_people_f	per2
							where	per2.person_id = per.person_id
							and	l_effective_date
								between per2.effective_start_date and per2.effective_end_date)
					)
			)
		and	hrl1.lookup_type = 'CONTACT'
		and	hrl1.lookup_code = ctr.contact_type
		and	hrl2.lookup_type(+) = 'JP_CONTACT_KANA'
		and	hrl2.lookup_code(+) = hrl1.lookup_code
		order by
			decode(ctr.contact_type, 'S', 1, 2),
			to_number(ctr.cont_information2),
			per.date_of_birth,
			decode(per.sex, 'F', 2, 1),
			per.last_name,
			per.first_name;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	-- If p_effective_date is null, use session_date as effective_date.
	-- Never cache effective_date into package global variables
	-- which will cause inconsistency when retropay is run.
	--
	if l_effective_date is null then
		select	effective_date
		into	l_effective_date
		from	fnd_sessions
		where	session_id = userenv('sessionid');
	end if;
	l_soy := trunc(l_effective_date, 'YYYY');
	l_eoy := add_months(l_soy, 12) - 1;
--	hr_utility.trace('L_EFFECTIVE_DATE : ' || fnd_date.date_to_chardate(l_effective_date));
--	hr_utility.trace('L_SOY            : ' || fnd_date.date_to_chardate(l_soy));
--	hr_utility.trace('L_EOY            : ' || fnd_date.date_to_chardate(l_eoy));
	--
	-- If cache is available, use cache.
	--
	if  p_use_cache
	and g_itax_dpnt_rec.assignment_id = p_assignment_id
	and g_itax_dpnt_rec.itax_type = p_itax_type
	and g_itax_dpnt_rec.effective_date = l_effective_date then
		hr_utility.trace('Cache is available.');
		--
		p_itax_dpnt_rec := g_itax_dpnt_rec;
	--
	-- Cache is not available, derive directly from CTR and CEI.
	--
	else
		hr_utility.trace('Cache is NOT available. Derive from CTR and CEI.');
		--
		-- Initialization for "p_itax_dpnt_rec" is automatically done by "OUT" parameter.
		--
		p_itax_dpnt_rec.assignment_id	:= p_assignment_id;
		p_itax_dpnt_rec.itax_type	:= p_itax_type;
		p_itax_dpnt_rec.effective_date	:= l_effective_date;
		--
		-- Income Tax Type "KOU"
		--
		if p_itax_type in ('M_KOU', 'D_KOU', 'M_OTSU', 'D_OTSU') then
			hr_utility.trace('Taxation Type : ' || p_itax_type);
			--
			if p_itax_type in ('M_KOU', 'D_KOU') then
				l_information_type := c_kou_information_type;
			else
				l_information_type := c_otsu_information_type;
			end if;
			--
			for l_dpnt in csr_dpnt(l_information_type) loop
				hr_utility.trace('**********');
--				hr_utility.trace('Effective Date : ' || fnd_date.date_to_chardate(l_dpnt.effective_date));
--				hr_utility.trace('Date of Birth  : ' || fnd_date.date_to_chardate(l_dpnt.date_of_birth));
--				hr_utility.trace('Date of Death  : ' || fnd_date.date_to_chardate(l_dpnt.date_of_death));
				hr_utility.trace('Contact Type   : ' || l_dpnt.contact_type);
				hr_utility.trace('Last Name      : ' || l_dpnt.first_name_kana);
				hr_utility.trace('Age            : ' || l_dpnt.age);
				--
				-- If the contact_type is "Spouse"
				--
				if l_dpnt.contact_type = 'S' then
					--
					-- When there are multiple spouses, return warning status.
					--
					if p_itax_dpnt_rec.spouse_type <> '0' then
						p_itax_dpnt_rec.multiple_spouses_warning := true;
					else
						--
						-- If the contact person is dependent
						--
						if l_dpnt.contact_extra_info_id is not null then
							l_index := l_index + 1;
							p_itax_dpnt_rec.contact_type_tbl(l_index)		:= l_dpnt.contact_type;
							p_itax_dpnt_rec.d_contact_type_kanji_tbl(l_index)	:= l_dpnt.d_contact_type_kanji;
							p_itax_dpnt_rec.d_contact_type_kana_tbl(l_index)	:= l_dpnt.d_contact_type_kana;
							p_itax_dpnt_rec.last_name_kanji_tbl(l_index)		:= l_dpnt.last_name_kanji;
							p_itax_dpnt_rec.first_name_kanji_tbl(l_index)		:= l_dpnt.first_name_kanji;
							p_itax_dpnt_rec.last_name_kana_tbl(l_index)		:= l_dpnt.last_name_kana;
							p_itax_dpnt_rec.first_name_kana_tbl(l_index)		:= l_dpnt.first_name_kana;
							--
							-- Spouse Age Check
							--
							if l_dpnt.age >= 70 then
								p_itax_dpnt_rec.spouse_type := '3';
							else
								p_itax_dpnt_rec.spouse_type := '2';
							end if;
							--
							-- Disabled Type Check
							--
							if l_dpnt.dsbl_type = '10' then
								p_itax_dpnt_rec.dpnt_spouse_dsbl_type := '1';
							elsif l_dpnt.dsbl_type = '20' then
								p_itax_dpnt_rec.dpnt_spouse_dsbl_type := '2';
							elsif l_dpnt.dsbl_type = '30' then
								p_itax_dpnt_rec.dpnt_spouse_dsbl_type := '3';
							end if;
						--
						-- In case just Spouse exists.
						-- Note this spouse is just spouse, not deductible spouse.
						--
						else
							p_itax_dpnt_rec.spouse_type		:= '1';
							p_itax_dpnt_rec.dpnt_spouse_dsbl_type	:= '0';
						end if;
					end if;
				--
				-- If the contact_type is not "Spouse"
				--
				else
					l_index := l_index + 1;
					p_itax_dpnt_rec.contact_type_tbl(l_index)		:= l_dpnt.contact_type;
					p_itax_dpnt_rec.d_contact_type_kanji_tbl(l_index)	:= l_dpnt.d_contact_type_kanji;
					p_itax_dpnt_rec.d_contact_type_kana_tbl(l_index)	:= l_dpnt.d_contact_type_kana;
					p_itax_dpnt_rec.last_name_kanji_tbl(l_index)		:= l_dpnt.last_name_kanji;
					p_itax_dpnt_rec.first_name_kanji_tbl(l_index)		:= l_dpnt.first_name_kanji;
					p_itax_dpnt_rec.last_name_kana_tbl(l_index)		:= l_dpnt.last_name_kana;
					p_itax_dpnt_rec.first_name_kana_tbl(l_index)		:= l_dpnt.first_name_kana;
					--
					p_itax_dpnt_rec.dpnts := p_itax_dpnt_rec.dpnts + 1;
					--
					-- Dependent Age Check
					--
					if l_dpnt.age >= 70 then
						--
						-- Aged Dependent Parents and Aged Dependents are mutually exclusive.
						--
						if l_dpnt.aged_dpnt_parents_lt_type = '10' then
							p_itax_dpnt_rec.aged_dpnt_parents_lt := p_itax_dpnt_rec.aged_dpnt_parents_lt + 1;
						else
							p_itax_dpnt_rec.aged_dpnts := p_itax_dpnt_rec.aged_dpnts + 1;
						end if;
					elsif l_dpnt.age between 16 and 22 then
						p_itax_dpnt_rec.young_dpnts := p_itax_dpnt_rec.young_dpnts + 1;
					elsif l_dpnt.age <= 15 then
						p_itax_dpnt_rec.minor_dpnts := p_itax_dpnt_rec.minor_dpnts + 1;
					end if;
					--
					-- Disabled Type Check
					--
					if l_dpnt.dsbl_type = '10' then
						p_itax_dpnt_rec.dsbl_dpnts := p_itax_dpnt_rec.dsbl_dpnts + 1;
					elsif l_dpnt.dsbl_type = '20' then
						p_itax_dpnt_rec.svr_dsbl_dpnts := p_itax_dpnt_rec.svr_dsbl_dpnts + 1;
					elsif l_dpnt.dsbl_type = '30' then
						p_itax_dpnt_rec.svr_dsbl_dpnts_lt := p_itax_dpnt_rec.svr_dsbl_dpnts_lt + 1;
					end if;
				end if;
			end loop;
		end if;
		--
		-- Save into cache to decrease DB access when input parameters are the same.
		-- These cache will be used if this function is called with the same values
		-- for input parameters.
		--
		g_itax_dpnt_rec := p_itax_dpnt_rec;
		--
		hr_utility.trace('**********');
		hr_utility.trace('spouse_type           : ' || p_itax_dpnt_rec.spouse_type);
		hr_utility.trace('dpnt_spouse_dsbl_type : ' || p_itax_dpnt_rec.dpnt_spouse_dsbl_type);
		hr_utility.trace('dpnts                 : ' || to_char(p_itax_dpnt_rec.dpnts));
		hr_utility.trace('aged_dpnts            : ' || to_char(p_itax_dpnt_rec.aged_dpnts));
		hr_utility.trace('aged_dpnt_parents_lt  : ' || to_char(p_itax_dpnt_rec.aged_dpnt_parents_lt));
		hr_utility.trace('young_dpnts           : ' || to_char(p_itax_dpnt_rec.young_dpnts));
		hr_utility.trace('minor_dpnts           : ' || to_char(p_itax_dpnt_rec.minor_dpnts));
		hr_utility.trace('dsbl_dpnts            : ' || to_char(p_itax_dpnt_rec.dsbl_dpnts));
		hr_utility.trace('svr_dsbl_dpnts        : ' || to_char(p_itax_dpnt_rec.svr_dsbl_dpnts));
		hr_utility.trace('svr_dsbl_dpnts_lt     : ' || to_char(p_itax_dpnt_rec.svr_dsbl_dpnts_lt));
		if p_itax_dpnt_rec.multiple_spouses_warning then
			hr_utility.trace('multiple_spouses_warning : TRUE');
		else
			hr_utility.trace('multiple_spouses_warning : FALSE');
		end if;
	end if;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end get_itax_dpnt_info;
-- ----------------------------------------------------------------------------
-- |--------------< Interface Functions for get_itax_dpnt_info >--------------|
-- ----------------------------------------------------------------------------
procedure get_itax_dpnt_info(
	p_assignment_id			in number,
	p_itax_type			in varchar2,
	p_effective_date		in date,
	p_spouse_type		 out nocopy varchar2,
	p_dpnt_spouse_dsbl_type	 out nocopy varchar2,
	p_dpnts			 out nocopy number,
	p_aged_dpnts		 out nocopy number,
	p_aged_dpnt_parents_lt	 out nocopy number,
	p_young_dpnts		 out nocopy number,
	p_minor_dpnts		 out nocopy number,
	p_dsbl_dpnts		 out nocopy number,
	p_svr_dsbl_dpnts	 out nocopy number,
	p_svr_dsbl_dpnts_lt	 out nocopy number,
	p_multiple_spouses_warning out nocopy boolean,
	p_use_cache			in boolean default TRUE)
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec,
		p_use_cache		=> p_use_cache);
	--
	p_spouse_type			:= l_itax_dpnt_rec.spouse_type;
	p_dpnt_spouse_dsbl_type		:= l_itax_dpnt_rec.dpnt_spouse_dsbl_type;
	p_dpnts				:= l_itax_dpnt_rec.dpnts;
	p_aged_dpnts			:= l_itax_dpnt_rec.aged_dpnts;
	p_aged_dpnt_parents_lt		:= l_itax_dpnt_rec.aged_dpnt_parents_lt;
	p_young_dpnts			:= l_itax_dpnt_rec.young_dpnts;
	p_minor_dpnts			:= l_itax_dpnt_rec.minor_dpnts;
	p_dsbl_dpnts			:= l_itax_dpnt_rec.dsbl_dpnts;
	p_svr_dsbl_dpnts		:= l_itax_dpnt_rec.svr_dsbl_dpnts;
	p_svr_dsbl_dpnts_lt		:= l_itax_dpnt_rec.svr_dsbl_dpnts_lt;
	p_multiple_spouses_warning	:= l_itax_dpnt_rec.multiple_spouses_warning;
end get_itax_dpnt_info;
--
procedure get_itax_dpnt_info(
	p_assignment_id			in number,
	p_itax_type			in varchar2,
	p_effective_date		in date,
	p_dpnt_spouse_type	 out nocopy varchar2,
	p_dpnt_spouse_dsbl_type	 out nocopy varchar2,
	p_dpnts			 out nocopy number,
	p_aged_dpnts		 out nocopy number,
	p_cohab_aged_asc_dpnts	 out nocopy number,
	p_major_dpnts		 out nocopy number,
	p_minor_dpnts		 out nocopy number,
	p_dsbl_dpnts		 out nocopy number,
	p_svr_dsbl_dpnts	 out nocopy number,
	p_cohab_svr_dsbl_dpnts	 out nocopy number,
	p_multiple_spouses_warning out nocopy boolean,
	p_use_cache			in boolean default TRUE)
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec,
		p_use_cache		=> p_use_cache);
	--
	p_dpnt_spouse_type		:= l_itax_dpnt_rec.spouse_type;
	p_dpnt_spouse_dsbl_type		:= l_itax_dpnt_rec.dpnt_spouse_dsbl_type;
	p_dpnts				:= l_itax_dpnt_rec.dpnts;
	p_aged_dpnts			:= l_itax_dpnt_rec.aged_dpnts;
	p_cohab_aged_asc_dpnts		:= l_itax_dpnt_rec.aged_dpnt_parents_lt;
	p_major_dpnts			:= l_itax_dpnt_rec.young_dpnts;
	p_minor_dpnts			:= l_itax_dpnt_rec.minor_dpnts;
	p_dsbl_dpnts			:= l_itax_dpnt_rec.dsbl_dpnts;
	p_svr_dsbl_dpnts		:= l_itax_dpnt_rec.svr_dsbl_dpnts;
	p_cohab_svr_dsbl_dpnts		:= l_itax_dpnt_rec.svr_dsbl_dpnts_lt;
	p_multiple_spouses_warning	:= l_itax_dpnt_rec.multiple_spouses_warning;
end get_itax_dpnt_info;
--
function get_itax_spouse_type(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.spouse_type;
end get_itax_spouse_type;
--
function get_itax_dpnt_spouse_type(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.spouse_type;
end get_itax_dpnt_spouse_type;
--
function get_itax_dpnt_spouse_dsbl_type(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.dpnt_spouse_dsbl_type;
end get_itax_dpnt_spouse_dsbl_type;
--
function get_itax_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.dpnts;
end get_itax_dpnts;
--
function get_itax_aged_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.aged_dpnts;
end get_itax_aged_dpnts;
--
function get_itax_cohab_aged_asc_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.aged_dpnt_parents_lt;
end get_itax_cohab_aged_asc_dpnts;
--
function get_itax_aged_dpnt_parents_lt(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.aged_dpnt_parents_lt;
end get_itax_aged_dpnt_parents_lt;
--
function get_itax_young_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.young_dpnts;
end get_itax_young_dpnts;
--
function get_itax_major_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.young_dpnts;
end get_itax_major_dpnts;
--
function get_itax_minor_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.minor_dpnts;
end get_itax_minor_dpnts;
--
function get_itax_dsbl_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.dsbl_dpnts;
end get_itax_dsbl_dpnts;
--
function get_itax_svr_dsbl_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.svr_dsbl_dpnts;
end get_itax_svr_dsbl_dpnts;
--
function get_itax_svr_dsbl_dpnts_lt(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.svr_dsbl_dpnts_lt;
end get_itax_svr_dsbl_dpnts_lt;
--
function get_itax_cohab_svr_dsbl_dpnts(
	p_assignment_id		in number,
	p_itax_type		in varchar2,
	p_effective_date	in date default null) return varchar2
is
	l_itax_dpnt_rec	t_itax_dpnt_rec;
begin
	get_itax_dpnt_info(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_itax_type		=> p_itax_type,
		p_itax_dpnt_rec		=> l_itax_dpnt_rec);
	--
	return l_itax_dpnt_rec.svr_dsbl_dpnts_lt;
end get_itax_cohab_svr_dsbl_dpnts;
--
end per_jp_ctr_utility_pkg;

/
