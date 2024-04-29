--------------------------------------------------------
--  DDL for Package Body PAY_JP_ITAX_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ITAX_REPORT_PKG" as
/* $Header: pyjpirep.pkb 120.8.12000000.7 2007/07/17 08:38:45 ttagawa noship $ */
--
-- Constants
--
c_package	CONSTANT VARCHAR2(31)	:= 'pay_jp_itax_report_pkg.';
c_lf		constant varchar2(1) := fnd_global.local_chr(10);
--
-- Global Variables
--
g_currency_format_mask		varchar2(30);
D7				fnd_new_messages.message_text%type;
C1				fnd_new_messages.message_text%type;
C2				fnd_new_messages.message_text%type;
C3				fnd_new_messages.message_text%type;
C4				fnd_new_messages.message_text%type;
C5				fnd_new_messages.message_text%type;
C6				fnd_new_messages.message_text%type;
C7				fnd_new_messages.message_text%type;
C8				fnd_new_messages.message_text%type;
C9				fnd_new_messages.message_text%type;
C10				fnd_new_messages.message_text%type;
C11				fnd_new_messages.message_text%type;
C12				fnd_new_messages.message_text%type;
C13				fnd_new_messages.message_text%type;
C14				fnd_new_messages.message_text%type;
C15				fnd_new_messages.message_text%type;
C16				fnd_new_messages.message_text%type;
C17				fnd_new_messages.message_text%type;
--
-- Large XML will elapse more heap size for XML transformation,
-- which will raise OutOfMemoryError.
-- Increasing maximum heap size(-Xmx128MB) is not right solution.
--
g_index		number := 0;
g_chunk_size	number := 100;
type t_rec is record(
	assignment_id		number,
	effective_date		date,
	D1			varchar2(240),
	D2			varchar2(240),
	D3			varchar2(240),
	D4			varchar2(240),
	D5			varchar2(240),
	D70			varchar2(240),
	D71			varchar2(240),
	D6			varchar2(240),
	D8			varchar2(240),
	D9			varchar2(240),
	D10			varchar2(240),
	D11			varchar2(240),
	D12			varchar2(240),
	D13			varchar2(240),
	D14			varchar2(240),
	D15			varchar2(240),
	D16			varchar2(240),
	D17			varchar2(240),
	D18			varchar2(240),
	D19			varchar2(240),
	D20			varchar2(240),
	D21			varchar2(240),
	D22			varchar2(240),
	D23			varchar2(240),
	D24			varchar2(240),
	D25			varchar2(240),
	D26			varchar2(240),
	D27			varchar2(240),
	D28			varchar2(240),
	D29			varchar2(240),
	D30			varchar2(240),
	D31			varchar2(240),
	D32			varchar2(240),
	SYSTEM_DESCRIPTION	varchar2(480),
	USER_DESCRIPTION	varchar2(480),
	D34			varchar2(240),
	D35			varchar2(240),
	D36			varchar2(240),
	D37			varchar2(240),
	D38			varchar2(240),
	D39			varchar2(240),
	D40			varchar2(240),
	D41			varchar2(240),
	D42			varchar2(240),
	D43			varchar2(240),
	D44			varchar2(240),
	D45			varchar2(240),
	D46			varchar2(240),
	D47			varchar2(240),
	D48			varchar2(240),
	D49			varchar2(240),
	D50			varchar2(240),
	D51			varchar2(240),
	HIRE_DATE		date,
	ACTUAL_TERMINATION_DATE	date,
/* bug.6208573
	D52			number,
	D53			number,
	D54			number,
*/
	D55			varchar2(240),
	D56			varchar2(240),
	D57			varchar2(240),
	D58			varchar2(240),
	D59			number,
	D60			number,
	D61			number,
	D62			varchar2(240),
	D63			varchar2(240),
	D64			varchar2(240),
	D65			varchar2(240),
	D66			varchar2(240),
	D67			varchar2(240),
	D68			varchar2(240),
	D69			varchar2(240),
	include_or_exclude	hr_assignment_set_amendments.include_or_exclude%type);
type t_tbl is table of t_rec index by binary_integer;
g_tbl	t_tbl;
-- |---------------------------------------------------------------------------|
-- |---------------------------------< init >----------------------------------|
-- |---------------------------------------------------------------------------|
procedure init(
	p_tax_year			in number   default null,
	p_itax_organization_id		in number   default null,
	p_exclude_ineligible_flag	in varchar2 default null,
	p_include_terminated_flag	in varchar2 default null,
	p_termination_date_from		in date     default null,
	p_termination_date_to		in date     default null,
	p_assignment_set_id		in number   default null,
	p_action_information_id1	in number   default null,
	p_action_information_id2	in number   default null,
	p_action_information_id3	in number   default null,
	p_action_information_id4	in number   default null,
	p_action_information_id5	in number   default null,
	p_action_information_id6	in number   default null,
	p_action_information_id7	in number   default null,
	p_action_information_id8	in number   default null,
	p_action_information_id9	in number   default null,
	p_action_information_id10	in number   default null,
	p_sort_order			in varchar2 default null,
	p_chunk_size			in number   default 100)
is
	l_concat_ids		varchar2(255);
	l_concat_id_count	number := 0;
	l_select_clause		varchar2(32767);
	l_from_clause		varchar2(32767);
	l_where_clause		varchar2(32767);
	l_order_by_clause	varchar2(255);
	l_formula_id		number;
	l_amendment_type	varchar2(1);
	l_valid			boolean;
--	l_temp_tbl		hr_jp_standard_pkg.t_varchar2_tbl;
	--
	-- Private procedures
	--
	procedure append_action_information_id(p_action_information_id in number)
	is
	begin
		if p_action_information_id is not null then
			if l_concat_ids is not null then
				l_concat_ids := l_concat_ids || ', ';
			end if;
			--
			l_concat_ids := l_concat_ids || p_action_information_id;
			l_concat_id_count := l_concat_id_count + 1;
		end if;
	end append_action_information_id;
	--
	procedure append_select_clause(p_clause in varchar2)
	is
	begin
		l_select_clause := l_select_clause || p_clause || c_lf;
	end append_select_clause;
	--
	procedure append_from_clause(p_clause in varchar2)
	is
	begin
		l_from_clause := l_from_clause || p_clause || c_lf;
	end append_from_clause;
	--
	procedure append_where_clause(p_clause in varchar2)
	is
	begin
		if l_where_clause is null then
			l_where_clause := 'where	' || p_clause || c_lf;
		else
			l_where_clause := l_where_clause || 'and	' || p_clause || c_lf;
		end if;
	end append_where_clause;
begin
	append_select_clause(
'select	person.assignment_id
,	person.effective_date
,	to_char(PERSON.EFFECTIVE_DATE, ''YYYY'')					D1
,	hr_jp_standard_pkg.to_jp_char(PERSON.EFFECTIVE_DATE, ''EE'')			D2
,	to_number(hr_jp_standard_pkg.to_jp_char(PERSON.EFFECTIVE_DATE, ''YY''))		D3
,	ADDRESS_KANJI									D4
,	ltrim(rtrim(LAST_NAME_KANA || '' '' || FIRST_NAME_KANA))			D5
,	LAST_NAME_KANA									D70
,	FIRST_NAME_KANA									D71
,	ltrim(rtrim(LAST_NAME_KANJI || '' '' || FIRST_NAME_KANJI))			D6
,	TAX.TAXABLE_INCOME								D8
,	TAX.NET_TAXABLE_INCOME								D9
,	TAX.TOTAL_INCOME_EXEMPT								D10
,	TAX.WITHHOLDING_ITAX								D11
,	TAX.MUTUAL_AID_PREMIUM								D12
,	OTHER.DEPENDENT_SPOUSE_EXISTS_KOU						D13
,	OTHER.DEPENDENT_SPOUSE_NO_EXIST_KOU						D14
,	OTHER.DEPENDENT_SPOUSE_EXISTS_OTSU						D15
,	OTHER.DEPENDENT_SPOUSE_NO_EXIST_OTSU						D16
,	OTHER.AGED_SPOUSE_EXISTS							D17
,	TAX.SPOUSE_SPECIAL_EXEMPT							D18
,	OTHER.NUM_SPECIFIEDS_KOU							D19
,	OTHER.NUM_SPECIFIEDS_OTSU							D20
,	OTHER.NUM_AGED_PARENTS_PARTIAL							D21
,	OTHER.NUM_AGEDS_KOU								D22
,	OTHER.NUM_AGEDS_OTSU								D23
,	OTHER.NUM_DEPENDENTS_KOU							D24
,	OTHER.NUM_DEPENDENTS_OTSU							D25
,	OTHER.NUM_SPECIAL_DISABLEDS_PARTIAL						D26
,	OTHER.NUM_SPECIAL_DISABLEDS							D27
,	OTHER.NUM_DISABLEDS								D28
,	TAX.SOCIAL_INSURANCE_PREMIUM							D29
,	TAX.LIFE_INSURANCE_PREMIUM_EXEMPT						D30
,	TAX.DAMAGE_INSURANCE_PREMIUM_EXEM						D31
,	TAX.HOUSING_TAX_REDUCTION							D32
,	OTHER2.ITW_SYSTEM_DESC2_KANJI							SYSTEM_DESCRIPTION
,	OTHER2.ITW_USER_DESC_KANJI							USER_DESCRIPTION
,	TAX.SPOUSE_NET_TAXABLE_INCOME							D34
,	TAX.PRIVATE_PENSION_PREMIUM							D35
,	TAX.LONG_DAMAGE_INSURANCE_PREMIUM						D36
,	OTHER.HUSBAND_EXISTS								D37
,	OTHER.MINOR									D38
,	OTHER.OTSU									D39
,	OTHER.SPECIAL_DISABLED								D40
,	OTHER.DISABLED									D41
,	OTHER.AGED									D42
,	OTHER.WIDOW									D43
,	OTHER.SPECIAL_WIDOW								D44
,	OTHER.WIDOWER									D45
,	OTHER.WORKING_STUDENT								D46
,	OTHER.DECEASED_TERMINATION							D47
,	OTHER.DISASTERED								D48
,	OTHER.FOREIGNER									D49
,	OTHER.EMPLOYED									D50
,	OTHER.UNEMPLOYED								D51
,	fnd_date.canonical_to_date(PERSON.JP_DATE_START)				HIRE_DATE
,	fnd_date.canonical_to_date(PERSON.ACTUAL_TERMINATION_DATE)			ACTUAL_TERMINATION_DATE
/* bug.6208573. ACTION_INFORMATION21/22/23 obsolete.
,	to_number(PERSON.EMPLOYMENT_DATE_YEAR)						D52
,	to_number(PERSON.EMPLOYMENT_DATE_MONTH)						D53
,	to_number(PERSON.EMPLOYMENT_DATE_DAY)						D54
*/
,	PERSON.DATE_OF_BIRTH_MEIJI							D55
,	PERSON.DATE_OF_BIRTH_TAISHOU							D56
,	PERSON.DATE_OF_BIRTH_SHOUWA							D57
,	PERSON.DATE_OF_BIRTH_HEISEI							D58
,	to_number(PERSON.DATE_OF_BIRTH_YEAR)						D59
,	to_number(PERSON.DATE_OF_BIRTH_MONTH)						D60
,	to_number(PERSON.DATE_OF_BIRTH_DAY)						D61
,	ARCH.EMPLOYER_ADDRESS								D62
,	ARCH.EMPLOYER_NAME								D63
,	ARCH.EMPLOYER_TELEPHONE_NUMBER							D64
,	ARCH.TAX_OFFICE_NUMBER								D65
,	ARCH.REFERENCE_NUMBER								D66
,	TAX.WITHHOLDING_ITAX2								D67
,	TAX.ITAX_ADJUSTMENT2								D68
,	OTHER2.ITW_SYSTEM_DESC1_KANJI							D69');
	--
	append_from_clause(
'from	pay_jp_itax_person_v	person
,	pay_jp_itax_arch_v	arch
,	pay_jp_itax_tax_v	tax
,	pay_jp_itax_other_v	other
,	pay_jp_itax_other2_v2	other2');
	--
	-- P_ACTION_INFORMATION_IDXX
	--
	append_action_information_id(p_action_information_id1);
	append_action_information_id(p_action_information_id2);
	append_action_information_id(p_action_information_id3);
	append_action_information_id(p_action_information_id4);
	append_action_information_id(p_action_information_id5);
	append_action_information_id(p_action_information_id6);
	append_action_information_id(p_action_information_id7);
	append_action_information_id(p_action_information_id8);
	append_action_information_id(p_action_information_id9);
	append_action_information_id(p_action_information_id10);
	--
	if l_concat_id_count > 0 then
		if l_concat_id_count = 1 then
			append_where_clause('person.action_information_id = ' || l_concat_ids);
		else
			append_where_clause('person.action_information_id in (' || l_concat_ids || ')');
		end if;
	end if;
	--
	-- P_ITAX_ORGANIZATION_ID
	--
	if p_itax_organization_id is not null then
		append_where_clause('person.itax_organization_id = ''' || fnd_number.number_to_canonical(p_itax_organization_id) || '''');
	end if;
	--
	-- P_TAX_YEAR
	--
	if p_tax_year is not null then
		append_where_clause('to_char(person.effective_date, ''YYYY'') = ''' || to_char(p_tax_year, 'FM0999') || '''');
	end if;
	--
	-- P_INCLUDE_TERMINATED_FLAG
	-- P_TERMINATION_DATE_FROM
	-- P_TERMINATION_DATE_TO
	--
	if p_include_terminated_flag = 'N' then
		append_where_clause('person.actual_termination_date is null');
	elsif p_include_terminated_flag = 'Y' then
		if p_termination_date_from is not null then
			if p_termination_date_to is not null then
				append_where_clause(
'fnd_date.canonical_to_date(person.actual_termination_date)
between	fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(p_termination_date_from) || ''')
and	fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(p_termination_date_to) || ''')');
			else
				append_where_clause(
					'fnd_date.canonical_to_date(person.actual_termination_date) >= fnd_date.canonical_to_date(''' ||
					fnd_date.date_to_canonical(p_termination_date_from) || ''')');
			end if;
		else
			if p_termination_date_to is not null then
				append_where_clause(
					'fnd_date.canonical_to_date(person.actual_termination_date) <= fnd_date.canonical_to_date(''' ||
					fnd_date.date_to_canonical(p_termination_date_to) || ''')');
			end if;
		end if;
	end if;
	--
	-- P_ASSIGNMENT_SET_ID
	--
	if p_assignment_set_id is not null then
		hr_jp_ast_utility_pkg.get_assignment_set_info(p_assignment_set_id, l_formula_id, l_amendment_type);
		--
		if l_amendment_type <> 'N' then
			append_select_clause(',	amd.include_or_exclude');
			append_from_clause(',	hr_assignment_set_amendments	amd');
			--
			if l_formula_id is null and l_amendment_type <> 'E' then
				append_where_clause(
'amd.assignment_set_id = ' || p_assignment_set_id || '
and	amd.assignment_id = person.assignment_id
and	amd.include_or_exclude = ''I''');
			else
				append_where_clause(
'amd.assignment_set_id(+) = ' || p_assignment_set_id || '
and	amd.assignment_id(+) = person.assignment_id
and	nvl(amd.include_or_exclude, ''I'') <> ''E''');
			end if;
		else
			append_select_clause(',	null');
		end if;
	else
		append_select_clause(',	null');
	end if;
	--
	append_where_clause(
'arch.action_context_id = person.action_context_id
and	arch.effective_date = person.effective_date');
	--
	-- P_EXCLUDE_INELIGIBLE_FLAG
	--
	if p_exclude_ineligible_flag = 'Y' then
		append_where_clause('arch.submission_required_flag = ''Y''');
	end if;
	--
	append_where_clause(
'tax.action_context_id = person.action_context_id
and	tax.effective_date = person.effective_date
and	other.action_context_id = person.action_context_id
and	other.effective_date = person.effective_date
and	other2.action_context_id = person.action_context_id
and	other2.effective_date = person.effective_date');
	--
	-- P_SORT_ORDER
	--
	if p_sort_order = 'DISTRICT_CODE' then
		l_order_by_clause := 'order by person.district_code, lpad(person.employee_number, 30)';
	elsif p_sort_order = 'EMPLOYEE_NUMBER' then
		l_order_by_clause := 'order by lpad(person.employee_number, 30)';
	else
		l_order_by_clause := null;
	end if;
	--
/*
	hr_jp_standard_pkg.to_table(l_select_clause || l_from_clause || l_where_clause || l_order_by_clause, 255, l_temp_tbl);
	for i in 1..l_temp_tbl.count loop
		dbms_output.put_line(l_temp_tbl(i));
	end loop;
*/
	--
	execute immediate
		l_select_clause ||
		l_from_clause   ||
		l_where_clause  ||
		l_order_by_clause
	bulk collect into g_tbl;
	--
	for i in 1..g_tbl.count loop
		l_valid := true;
		--
		-- Validate by Assignment Set FastFormula.
		--
		if l_formula_id is not null and g_tbl(i).include_or_exclude is null then
			l_valid := hr_jp_ast_utility_pkg.formula_validate(
					p_formula_id		=> l_formula_id,
					p_assignment_id		=> g_tbl(i).assignment_id,
					p_effective_date	=> g_tbl(i).effective_date,
					p_populate_fs		=> true);
		end if;
		--
		if not l_valid then
			g_tbl.delete(i);
		end if;
	end loop;
	--
	g_index := g_tbl.next(0);
	g_chunk_size := p_chunk_size;
end init;
-- |---------------------------------------------------------------------------|
-- |--------------------------------< getXML >---------------------------------|
-- |---------------------------------------------------------------------------|
--
-- DBMS_XMLGEN/DBMS_XMLQUERY cannot be used because of Assignment Set validation.
--
function getXML return clob
is
	l_clob			clob;
	l_description		varchar2(2000);
	l_counter		number := 1;
	l_jp_date		varchar2(6);
	--
	procedure append_tag(p_tag in varchar2)
	is
		l_value		varchar2(2000);
	begin
		l_value := p_tag || c_lf;
		dbms_lob.writeAppend(l_clob, length(l_value), l_value);
	end append_tag;
	--
	procedure append_item(
		p_tag		in varchar2,
		p_value		in varchar2)
	is
		l_value		varchar2(2000);
	begin
		if p_value is not null then
			l_value := '<' || p_tag || '>' || dbms_xmlgen.convert(p_value) || '</' || p_tag || '>' || c_lf;
			dbms_lob.writeAppend(l_clob, length(l_value), l_value);
			--
			-- Workaround for XDO bug.6129128
			--
			l_value := '<' || p_tag || '_2>' || dbms_xmlgen.convert(p_value) || '</' || p_tag || '_2>' || c_lf;
			dbms_lob.writeAppend(l_clob, length(l_value), l_value);
			l_value := '<' || p_tag || '_3>' || dbms_xmlgen.convert(p_value) || '</' || p_tag || '_3>' || c_lf;
			dbms_lob.writeAppend(l_clob, length(l_value), l_value);
			l_value := '<' || p_tag || '_4>' || dbms_xmlgen.convert(p_value) || '</' || p_tag || '_4>' || c_lf;
			dbms_lob.writeAppend(l_clob, length(l_value), l_value);
		end if;
	end append_item;
	--
	procedure append_item(
		p_tag		in varchar2,
		p_value		in number)
	is
	begin
		if p_value is not null then
			append_item(p_tag, fnd_number.number_to_canonical(p_value));
		end if;
	end append_item;
	--
	procedure append_item(
		p_tag		in varchar2,
		p_value		in date)
	is
	begin
		if p_value is not null then
			append_item(p_tag, fnd_date.date_to_canonical(p_value));
		end if;
	end append_item;
begin
	if g_index is not null then
		--
		-- Construct XML
		--
		dbms_lob.createTemporary(l_clob, true, dbms_lob.call);
		dbms_lob.open(l_clob, dbms_lob.lob_readwrite);
		append_tag('<?xml version="1.0"?>');
		append_tag('<ROWSET>');
		--
		while g_index is not null and (g_chunk_size <= 0 or l_counter <= g_chunk_size) loop
			append_tag('<G1>');
			--
			append_item('D1', g_tbl(g_index).D1);
			append_item('D2', g_tbl(g_index).D2);
			append_item('D3', g_tbl(g_index).D3);
			append_item('D4', g_tbl(g_index).D4);
			append_item('D5', g_tbl(g_index).D5);
			append_item('D70', g_tbl(g_index).D70);
			append_item('D71', g_tbl(g_index).D71);
			append_item('D6', g_tbl(g_index).D6);
			append_item('D8', g_tbl(g_index).D8);
			append_item('D9', g_tbl(g_index).D9);
			append_item('D10', g_tbl(g_index).D10);
			append_item('D11', g_tbl(g_index).D11);
			append_item('D12', g_tbl(g_index).D12);
			append_item('D13', g_tbl(g_index).D13);
			append_item('D14', g_tbl(g_index).D14);
			append_item('D15', g_tbl(g_index).D15);
			append_item('D16', g_tbl(g_index).D16);
			append_item('D17', g_tbl(g_index).D17);
			append_item('D18', g_tbl(g_index).D18);
			append_item('D19', g_tbl(g_index).D19);
			append_item('D20', g_tbl(g_index).D20);
			append_item('D21', g_tbl(g_index).D21);
			append_item('D22', g_tbl(g_index).D22);
			append_item('D23', g_tbl(g_index).D23);
			append_item('D24', g_tbl(g_index).D24);
			append_item('D25', g_tbl(g_index).D25);
			append_item('D26', g_tbl(g_index).D26);
			append_item('D27', g_tbl(g_index).D27);
			append_item('D28', g_tbl(g_index).D28);
			append_item('D29', g_tbl(g_index).D29);
			append_item('D30', g_tbl(g_index).D30);
			append_item('D31', g_tbl(g_index).D31);
			append_item('D32', g_tbl(g_index).D32);
			--
			if g_tbl(g_index).user_description is null then
				l_description := g_tbl(g_index).system_description;
			elsif g_tbl(g_index).system_description is null then
				l_description := g_tbl(g_index).user_description;
			else
				l_description := g_tbl(g_index).system_description || ',' || g_tbl(g_index).user_description;
			end if;
			--
			append_item('D33', l_description);
			--
			append_item('D34', g_tbl(g_index).D34);
			append_item('D35', g_tbl(g_index).D35);
			append_item('D36', g_tbl(g_index).D36);
			append_item('D37', g_tbl(g_index).D37);
			append_item('D38', g_tbl(g_index).D38);
			append_item('D39', g_tbl(g_index).D39);
			append_item('D40', g_tbl(g_index).D40);
			append_item('D41', g_tbl(g_index).D41);
			append_item('D42', g_tbl(g_index).D42);
			append_item('D43', g_tbl(g_index).D43);
			append_item('D44', g_tbl(g_index).D44);
			append_item('D45', g_tbl(g_index).D45);
			append_item('D46', g_tbl(g_index).D46);
			append_item('D47', g_tbl(g_index).D47);
			append_item('D48', g_tbl(g_index).D48);
			append_item('D49', g_tbl(g_index).D49);
			append_item('D50', g_tbl(g_index).D50);
			append_item('D51', g_tbl(g_index).D51);
			--
			-- bug.6208573
			-- "Hire Date" and "Actual Termination Date" must be maintained separately,
			-- so ACTION_INFORMATION21/22/23 of JP_ITAX_PERSON context are obsolete.
			--
			if  g_tbl(g_index).hire_date is not null
			and g_tbl(g_index).actual_termination_date is not null then
				l_jp_date := hr_jp_standard_pkg.to_jp_char(g_tbl(g_index).hire_date, 'YYMMDD');
				append_item('D52_U', to_number(substr(l_jp_date, 1, 2)));
				append_item('D53_U', to_number(substr(l_jp_date, 3, 2)));
				append_item('D54_U', to_number(substr(l_jp_date, 5, 2)));
				--
				l_jp_date := hr_jp_standard_pkg.to_jp_char(g_tbl(g_index).actual_termination_date, 'YYMMDD');
				append_item('D52_L', to_number(substr(l_jp_date, 1, 2)));
				append_item('D53_L', to_number(substr(l_jp_date, 3, 2)));
				append_item('D54_L', to_number(substr(l_jp_date, 5, 2)));
			elsif g_tbl(g_index).hire_date is not null
			   or g_tbl(g_index).actual_termination_date is not null then
				l_jp_date := hr_jp_standard_pkg.to_jp_char(
						nvl(g_tbl(g_index).hire_date,
						    g_tbl(g_index).actual_termination_date), 'YYMMDD');
				append_item('D52_C', to_number(substr(l_jp_date, 1, 2)));
				append_item('D53_C', to_number(substr(l_jp_date, 3, 2)));
				append_item('D54_C', to_number(substr(l_jp_date, 5, 2)));
			end if;
			--
			-- Backward Compatibility
			--
			if g_tbl(g_index).hire_date is not null
			or g_tbl(g_index).actual_termination_date is not null then
				l_jp_date := hr_jp_standard_pkg.to_jp_char(
						nvl(g_tbl(g_index).actual_termination_date,
						    g_tbl(g_index).hire_date), 'YYMMDD');
				append_item('D52', to_number(substr(l_jp_date, 1, 2)));
				append_item('D53', to_number(substr(l_jp_date, 3, 2)));
				append_item('D54', to_number(substr(l_jp_date, 5, 2)));
			end if;
/*
			append_item('D52', g_tbl(g_index).D52);
			append_item('D53', g_tbl(g_index).D53);
			append_item('D54', g_tbl(g_index).D54);
*/
			--
			append_item('D55', g_tbl(g_index).D55);
			append_item('D56', g_tbl(g_index).D56);
			append_item('D57', g_tbl(g_index).D57);
			append_item('D58', g_tbl(g_index).D58);
			append_item('D59', g_tbl(g_index).D59);
			append_item('D60', g_tbl(g_index).D60);
			append_item('D61', g_tbl(g_index).D61);
			append_item('D62', g_tbl(g_index).D62);
			append_item('D63', g_tbl(g_index).D63);
			append_item('D64', g_tbl(g_index).D64);
			append_item('D65', g_tbl(g_index).D65);
			append_item('D66', g_tbl(g_index).D66);
			append_item('D67', g_tbl(g_index).D67);
			append_item('D68', g_tbl(g_index).D68);
			append_item('D69', g_tbl(g_index).D69);
			--
			append_item('D7', D7);
			append_item('C1', C1);
			append_item('C2', C2);
			append_item('C3', C3);
			append_item('C4', C4);
			append_item('C5', C5);
			append_item('C6', C6);
			append_item('C7', C7);
			append_item('C8', C8);
			append_item('C9', C9);
			append_item('C10', C10);
			append_item('C11', C11);
			append_item('C12', C12);
			append_item('C13', C13);
			append_item('C14', C14);
			append_item('C15', C15);
			append_item('C16', C16);
			append_item('C17', C17);
			--
--			append_item('PAGE_BREAK', ' ');
			append_tag('<PAGE_BREAK>  </PAGE_BREAK>');
			--
			append_tag('</G1>');
			--
			g_index := g_tbl.next(g_index);
			l_counter := l_counter + 1;
		end loop;
		--
		append_tag('</ROWSET>');
	end if;
	--
	-- Remember to call freeTemporary after the usage.
	--
	return l_clob;
exception
	when others then
		if l_clob is not null then
			dbms_lob.freeTemporary(l_clob);
		end if;
		raise;
end getXML;
-- |---------------------------------------------------------------------------|
-- |--------------------------------< getXML >---------------------------------|
-- |---------------------------------------------------------------------------|
function getXML(p_action_information_id in number) return clob
is
begin
	init(p_action_information_id1 => p_action_information_id);
	--
	return getXML;
end getXML;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< gen_bulk_xml >------------------------------|
-- |---------------------------------------------------------------------------|
-- Deprecated. Use getXML instead.
PROCEDURE gen_bulk_xml(
	p_archive_id	in varchar2,
	p_xml		out nocopy clob)
IS
BEGIN
	p_xml := getXML(p_archive_id);
END gen_bulk_xml;
-- |---------------------------------------------------------------------------|
-- |------------------------------< gen_per_xml >------------------------------|
-- |---------------------------------------------------------------------------|
-- Deprecated. Use getXML instead.
PROCEDURE gen_per_xml(
	p_archive_id	in varchar2,
	p_year		out nocopy number,
	p_xml		out nocopy clob)
IS
	l_year	number;
BEGIN
	gen_bulk_xml(
		p_archive_id	=> p_archive_id,
		p_xml		=> p_xml);
	--
	select	to_number(to_char(PERSON.EFFECTIVE_DATE, 'YYYY'))
	into	p_year
	from	pay_jp_itax_person_v	person
	where	person.action_information_id = p_archive_id;
END gen_per_xml;
--
BEGIN
	D7  := fnd_message.get_string('PAY', 'PAY_JP_WIC_EARNINGS_TYPE');
	C1  := fnd_message.get_string('PAY', 'PAY_JP_ITW_NUMBER');
	C2  := fnd_message.get_string('PAY', 'PAY_JP_ITW_KANA_NAME');
	C3  := fnd_message.get_string('PAY', 'PAY_JP_ITW_JOB_NAME');
	C4  := fnd_message.get_string('PAY', 'PAY_JP_ITW_EX_SPOUSE');
	C5  := fnd_message.get_string('PAY', 'PAY_JP_ITW_EX_SELF');
	C6  := fnd_message.get_string('PAY', 'PAY_JP_ITW_DESCRIPTION');
	C7  := fnd_message.get_string('PAY', 'PAY_JP_ITW_PHONE');
	C8  := fnd_message.get_string('PAY', 'PAY_JP_ITW_YEAR');
	C9  := fnd_message.get_string('PAY', 'PAY_JP_ITW_WITHIN');
	C10 := fnd_message.get_string('PAY', 'PAY_JP_ITW_EXIST');
	C11 := fnd_message.get_string('PAY', 'PAY_JP_ITW_NOT_EXIST');
	C12 := fnd_message.get_string('PAY', 'PAY_JP_ITW_FOLLOW');
	C13 := fnd_message.get_string('PAY', 'PAY_JP_ITW_COUNT');
	C14 := fnd_message.get_string('PAY', 'PAY_JP_ITW_MEIJI');
	C15 := fnd_message.get_string('PAY', 'PAY_JP_ITW_TAISHOU');
	C16 := fnd_message.get_string('PAY', 'PAY_JP_ITW_SHOWA');
	C17 := fnd_message.get_string('PAY', 'PAY_JP_ITW_HEISEI');
END;

/
