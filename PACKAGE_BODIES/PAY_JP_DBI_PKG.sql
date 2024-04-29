--------------------------------------------------------
--  DDL for Package Body PAY_JP_DBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_DBI_PKG" as
/* $Header: pyjpdbi.pkb 120.2 2006/12/06 06:34:31 keyazawa noship $ */
--
procedure translate
is
	l_upper_limit		hr_lookups.meaning%type;
	l_lower_limit		hr_lookups.meaning%type;
	l_max			hr_lookups.meaning%type;
	l_min			hr_lookups.meaning%type;
	--
	l_user_name		ff_database_items.user_name%type;
	l_tl_user_name		ff_database_items_tl.translated_user_name%type;
	--
	cursor csr_tab(p_range_or_match in varchar2) is
		select	b.user_table_id,
			b.user_table_name,
			b.user_row_title,
			tl.user_table_name	tl_user_table_name,
			tl.user_row_title	tl_user_row_title
		from	pay_user_tables		b,
			pay_user_tables_tl	tl
		where	b.range_or_match = p_range_or_match
		and	b.legislation_code = 'JP'
		and	b.business_group_id is null
		and	tl.user_table_id = b.user_table_id
		and	tl.language = 'JA';
	--
	cursor csr_row(p_user_table_id in number) is
		select	b.row_low_range_or_name,
			tl.row_low_range_or_name	tl_row_low_range_or_name
		from	pay_user_rows_f		b,
			pay_user_rows_f_tl	tl
		where	b.user_table_id = p_user_table_id
		and	b.legislation_code = 'JP'
		and	b.business_group_id is null
		and	tl.user_row_id = b.user_row_id
		and	tl.language = 'JA'
		group by
			b.user_row_id,
			b.row_low_range_or_name,
			tl.row_low_range_or_name;
	--
	cursor csr_col(p_user_table_id in number) is
		select	b.user_column_name,
			tl.user_column_name	tl_user_column_name
		from	pay_user_columns	b,
			pay_user_columns_tl	tl
		where	b.user_table_id = p_user_table_id
		and	b.legislation_code = 'JP'
		and	b.business_group_id is null
		and	tl.user_column_id = b.user_column_id
		and	tl.language = 'JA';
	--
	function ja_installed return boolean
	is
		l_dummy		varchar2(1);
		l_installed	boolean;
		--
		cursor csr is
		select	'Y'
		from	fnd_languages
		where	language_code = 'JA'
		and	installed_flag in ('B', 'I');
	begin
		open csr;
		fetch csr into l_dummy;
		l_installed := csr%found;
		close csr;
		--
		return l_installed;
	end ja_installed;
	--
	function decode_lookup(
		p_lookup_type	in varchar2,
		p_lookup_code	in varchar2) return varchar2
	is
		l_meaning	hr_lookups.meaning%type;
	begin
    -- need to refer to fnd_lookup_values
    -- because JA japanese dbi suffix should be derived
    -- when adpatch runs with US lang.
		select	meaning
		into	l_meaning
		from	fnd_lookup_values
		where	lookup_type = p_lookup_type
		and	view_application_id = 3
		and	lookup_code = p_lookup_code
		and	security_group_id = 0
		and	language = 'JA';
		--
		return l_meaning;
	end decode_lookup;
	--
	procedure update_tl_row(
		p_user_name		in varchar2,
		p_tl_user_name		in varchar2)
	is
		l_user_entity_id	number;
		l_tl_user_name		ff_database_items_tl.translated_user_name%type;
		l_new_tl_user_name	ff_database_items_tl.translated_user_name%type;
                l_got_error             boolean;
		--
		cursor csr is
			select	u.user_entity_id
			from	ff_database_items	d,
				ff_user_entities	u
			where	d.user_name = p_user_name
			and	u.user_entity_id = d.user_entity_id
			and	u.legislation_code = 'JP';
	begin
		open csr;
		fetch csr into l_user_entity_id;
		if csr%found then
			select	translated_user_name
			into	l_tl_user_name
			from	ff_database_items_tl
			where	user_name = p_user_name
			and	user_entity_id = l_user_entity_id
			and	language = 'JA';
			--
			-- Update only when the user_name is different.
			--
			l_new_tl_user_name := ff_dbi_utils_pkg.str2dbiname(p_tl_user_name);
			if l_tl_user_name <> l_new_tl_user_name then
				--
				-- Following procedure will be changed to delete compiled info
				-- if the translated DBI is used in fastformulas,
				-- and log the message to fix those formulas.
				--
				ff_database_items_pkg.update_seeded_tl_rows(
					x_user_name		=> p_user_name,
					x_user_entity_id	=> l_user_entity_id,
					x_language		=> 'JA',
					x_translated_user_name	=> l_new_tl_user_name,
					x_description		=> null,
                                        x_got_error             => l_got_error);
			end if;
		end if;
		close csr;
	end update_tl_row;
begin
	--
	-- Note this only updates FF_DATABASE_ITEMS_TL with JA language.
	-- It is not necessary to check whether the db charset is JA compliant,
	-- because JA installation means that the DB is JA charset compliant.
	--
	if ja_installed and ff_dbi_utils_pkg.translations_supported('JP') then
		l_upper_limit	:= decode_lookup('NAME_TRANSLATIONS', 'UPPER_LIMIT');
		l_lower_limit	:= decode_lookup('NAME_TRANSLATIONS', 'LOWER_LIMIT');
		l_max		:= decode_lookup('NAME_TRANSLATIONS', 'MAX');
		l_min		:= decode_lookup('NAME_TRANSLATIONS', 'MIN');
		--
		-- UDT DBIs for route "PAY_JP_UDT_RANGE_ROUTE1".
		--
		for l_tab in csr_tab('R') loop
			l_user_name	:= ff_dbi_utils_pkg.str2dbiname(
						l_tab.user_table_name || '_' ||
						l_tab.user_row_title ||
						'_UPPER_LIMIT');
			l_tl_user_name	:= ff_dbi_utils_pkg.str2dbiname(
						l_tab.tl_user_table_name || '_' ||
						l_tab.tl_user_row_title || '_' ||
						l_upper_limit);
			update_tl_row(l_user_name, l_tl_user_name);
			--
			l_user_name	:= ff_dbi_utils_pkg.str2dbiname(
						l_tab.user_table_name || '_' ||
						l_tab.user_row_title ||
						'_LOWER_LIMIT');
			l_tl_user_name	:= ff_dbi_utils_pkg.str2dbiname(
						l_tab.tl_user_table_name || '_' ||
						l_tab.tl_user_row_title || '_' ||
						l_lower_limit);
			update_tl_row(l_user_name, l_tl_user_name);
		end loop;
		--
		-- UDT DBIs for route "PAY_JP_UDT_RANGE_ROUTE2".
		--
		for l_tab in csr_tab('R') loop
			for l_col in csr_col(l_tab.user_table_id) loop
				l_user_name	:= ff_dbi_utils_pkg.str2dbiname(
							l_tab.user_table_name || '_' ||
							l_col.user_column_name ||
							'_MAX');
				l_tl_user_name	:= ff_dbi_utils_pkg.str2dbiname(
							l_tab.tl_user_table_name || '_' ||
							l_col.tl_user_column_name || '_' ||
							l_max);
				update_tl_row(l_user_name, l_tl_user_name);
				--
				l_user_name	:= ff_dbi_utils_pkg.str2dbiname(
							l_tab.user_table_name || '_' ||
							l_col.user_column_name ||
							'_MIN');
				l_tl_user_name	:= ff_dbi_utils_pkg.str2dbiname(
							l_tab.tl_user_table_name || '_' ||
							l_col.tl_user_column_name || '_' ||
							l_min);
				update_tl_row(l_user_name, l_tl_user_name);
			end loop;
		end loop;
		--
		-- UDT DBIs for route "PAY_JP_UDT_MATCH_ROUTE".
		--
		for l_tab in csr_tab('M') loop
			for l_row in csr_row(l_tab.user_table_id) loop
				for l_col in csr_col(l_tab.user_table_id) loop
					l_user_name	:= ff_dbi_utils_pkg.str2dbiname(
								l_tab.user_table_name || '_' ||
								l_row.row_low_range_or_name || '_' ||
								l_col.user_column_name);
					l_tl_user_name	:= ff_dbi_utils_pkg.str2dbiname(
								l_tab.tl_user_table_name || '_' ||
								l_row.tl_row_low_range_or_name || '_' ||
								l_col.tl_user_column_name);
					update_tl_row(l_user_name, l_tl_user_name);
				end loop;
			end loop;
		end loop;
		--
		-- JP Specific DBIs
		--
		l_tl_user_name := hr_jp_standard_pkg.get_message('PAY', 'PAY_JP_DBI_PAY_BASE_DAY_MIN_DE', 'JA');
		if l_tl_user_name is not null then
			update_tl_row('G_COM_PAY_BASE_DAYS_MIN_DE', l_tl_user_name);
		end if;
		--
		l_tl_user_name := hr_jp_standard_pkg.get_message('PAY', 'PAY_JP_DBI_EI_LOC_BUS_TYPE', 'JA');
		if l_tl_user_name is not null then
			update_tl_row('PAY_JP_EI_LOCATION_BUSINESS_TYPE', l_tl_user_name);
		end if;
	end if;
end translate;
--
end pay_jp_dbi_pkg;

/
