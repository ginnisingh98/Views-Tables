--------------------------------------------------------
--  DDL for Package Body PAY_PAYWSMEE2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYWSMEE2_PKG" as
/* $Header: pywsmee2.pkb 115.5 2003/02/13 17:17:30 swinton ship $ */
--
--------------------------------------------------------------------------------
g_coverage		constant pay_input_values_f.name%type := 'Coverage';
g_ee_contributions	constant pay_input_values_f.name%type := 'EE Contr';
g_er_contributions	constant pay_input_values_f.name%type := 'ER Contr';
--------------------------------------------------------------------------------

procedure lock_row (
--
p_effective_date                        date,
p_element_entry_id                      number,
p_effective_start_date                  date,
p_effective_end_date                    date,
p_cost_allocation_keyflex_id            number,
p_assignment_id                         number,
p_element_link_id                       number,
p_original_entry_id                     number,
p_creator_type                          varchar2,
p_entry_type                            varchar2,
p_comment_id                            number,
p_creator_id                            number,
p_reason                                varchar2,
p_target_entry_id                       number,
p_date_earned				date,
p_personal_payment_method_id		number,
p_attribute_category                    varchar2,
p_attribute1                            varchar2,
p_attribute2                            varchar2,
p_attribute3                            varchar2,
p_attribute4                            varchar2,
p_attribute5                            varchar2,
p_attribute6                            varchar2,
p_attribute7                            varchar2,
p_attribute8                            varchar2,
p_attribute9                            varchar2,
p_attribute10                           varchar2,
p_attribute11                           varchar2,
p_attribute12                           varchar2,
p_attribute13                           varchar2,
p_attribute14                           varchar2,
p_attribute15                           varchar2,
p_attribute16                           varchar2,
p_attribute17                           varchar2,
p_attribute18                           varchar2,
p_attribute19                           varchar2,
p_attribute20                           varchar2
-- --
,
p_entry_information_category            varchar2,
p_entry_information1                    varchar2,
p_entry_information2                    varchar2,
p_entry_information3                    varchar2,
p_entry_information4                    varchar2,
p_entry_information5                    varchar2,
p_entry_information6                    varchar2,
p_entry_information7                    varchar2,
p_entry_information8                    varchar2,
p_entry_information9                    varchar2,
p_entry_information10                   varchar2,
p_entry_information11                   varchar2,
p_entry_information12                   varchar2,
p_entry_information13                   varchar2,
p_entry_information14                   varchar2,
p_entry_information15                   varchar2,
p_entry_information16                   varchar2,
p_entry_information17                   varchar2,
p_entry_information18                   varchar2,
p_entry_information19                   varchar2,
p_entry_information20                   varchar2,
p_entry_information21                   varchar2,
p_entry_information22                   varchar2,
p_entry_information23                   varchar2,
p_entry_information24                   varchar2,
p_entry_information25                   varchar2,
p_entry_information26                   varchar2,
p_entry_information27                   varchar2,
p_entry_information28                   varchar2,
p_entry_information29                   varchar2,
p_entry_information30                   varchar2
) is
--
cursor existing_row is
select *
from   pay_element_entries_f
where  element_entry_id = p_element_entry_id
and p_effective_date between effective_start_date and effective_end_date
for update of element_entry_id      nowait;
--
locked_row existing_row%rowtype;
--
begin
--
open existing_row;
fetch existing_row into locked_row;
if (existing_row%notfound) then
  close existing_row;
  raise no_data_found;
else
  close existing_row;
end if;
--
if (
(   locked_row.element_entry_id = p_element_entry_id
or (    locked_row.element_entry_id is null and p_element_entry_id is null))
and (   (locked_row.effective_start_date = p_effective_start_date)
or (    (locked_row.effective_start_date is null)
and (p_effective_start_date is null)))
and (   (locked_row.effective_end_date = p_effective_end_date)
or (    (locked_row.effective_end_date is null)
and (p_effective_end_date is null)))
and (   (locked_row.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
)
or (    (locked_row.cost_allocation_keyflex_id is null)
and (p_cost_allocation_keyflex_id is null)))
and (   (locked_row.assignment_id = p_assignment_id)
or (    (locked_row.assignment_id is null)
and (p_assignment_id is null)))
and (   (locked_row.element_link_id = p_element_link_id)
or (    (locked_row.element_link_id is null)
and (p_element_link_id is null)))
and (   (locked_row.original_entry_id = p_original_entry_id)
or (    (locked_row.original_entry_id is null)
and (p_original_entry_id is null)))
and (   (locked_row.creator_type = p_creator_type)
or (    (locked_row.creator_type is null)
and (p_creator_type is null)))
and (   (locked_row.entry_type = p_entry_type)
or (    (locked_row.entry_type is null)
and (p_entry_type is null)))
and (   (locked_row.comment_id = p_comment_id)
or (    (locked_row.comment_id is null)
and (p_comment_id is null)))
and (   (locked_row.creator_id = p_creator_id)
or (    (locked_row.creator_id is null)
and (p_creator_id is null)))
and (   (locked_row.reason = p_reason)
or (    (locked_row.reason is null)
and (p_reason is null)))
and (   (locked_row.target_entry_id = p_target_entry_id)
or (    (locked_row.target_entry_id is null)
and (p_target_entry_id is null)))
and (   (locked_row.attribute_category = p_attribute_category)
or (    (locked_row.attribute_category is null)
and (p_attribute_category is null)))
and (   (locked_row.attribute1 = p_attribute1)
or (    (locked_row.attribute1 is null)
and (p_attribute1 is null)))
and (   (locked_row.attribute2 = p_attribute2)
or (    (locked_row.attribute2 is null)
and (p_attribute2 is null)))
and (   (locked_row.attribute3 = p_attribute3)
or (    (locked_row.attribute3 is null)
and (p_attribute3 is null)))
and (   (locked_row.attribute4 = p_attribute4)
or (    (locked_row.attribute4 is null)
and (p_attribute4 is null)))
and (   (locked_row.attribute5 = p_attribute5)
or (    (locked_row.attribute5 is null)
and (p_attribute5 is null)))
and (   (locked_row.attribute6 = p_attribute6)
or (    (locked_row.attribute6 is null)
and (p_attribute6 is null)))
and (   (locked_row.attribute7 = p_attribute7)
or (    (locked_row.attribute7 is null)
and (p_attribute7 is null)))
and (   (locked_row.attribute8 = p_attribute8)
or (    (locked_row.attribute8 is null)
and (p_attribute8 is null)))
and (   (locked_row.attribute9 = p_attribute9)
or (    (locked_row.attribute9 is null)
and (p_attribute9 is null)))
and (   (locked_row.attribute10 = p_attribute10)
or (    (locked_row.attribute10 is null)
and (p_attribute10 is null)))
and (   (locked_row.attribute11 = p_attribute11)
or (    (locked_row.attribute11 is null)
and (p_attribute11 is null)))
and (   (locked_row.attribute12 = p_attribute12)
or (    (locked_row.attribute12 is null)
and (p_attribute12 is null)))
and (   (locked_row.attribute13 = p_attribute13)
or (    (locked_row.attribute13 is null)
and (p_attribute13 is null)))
and (   (locked_row.attribute14 = p_attribute14)
or (    (locked_row.attribute14 is null)
and (p_attribute14 is null)))
and (   (locked_row.attribute15 = p_attribute15)
or (    (locked_row.attribute15 is null)
and (p_attribute15 is null)))
and (   (locked_row.attribute16 = p_attribute16)
or (    (locked_row.attribute16 is null)
and (p_attribute16 is null)))
and (   (locked_row.attribute17 = p_attribute17)
or (    (locked_row.attribute17 is null)
and (p_attribute17 is null)))
and (   (locked_row.attribute18 = p_attribute18)
or (    (locked_row.attribute18 is null)
and (p_attribute18 is null)))
and (   (locked_row.attribute19 = p_attribute19)
or (    (locked_row.attribute19 is null)
and (p_attribute19 is null)))
and (   locked_row.attribute20 = p_attribute20
or (    locked_row.attribute20 is null and p_attribute20 is null))
-- begin --
and (   locked_row.entry_information_category = p_entry_information_category
or (    locked_row.entry_information_category is null and p_entry_information_category is null))
and (   locked_row.entry_information1 = p_entry_information1
or (    locked_row.entry_information1 is null and p_entry_information1 is null))
and (   locked_row.entry_information2 = p_entry_information2
or (    locked_row.entry_information2 is null and p_entry_information2 is null))
and (   locked_row.entry_information3 = p_entry_information3
or (    locked_row.entry_information3 is null and p_entry_information3 is null))
and (   locked_row.entry_information4 = p_entry_information4
or (    locked_row.entry_information4 is null and p_entry_information4 is null))
and (   locked_row.entry_information5 = p_entry_information5
or (    locked_row.entry_information5 is null and p_entry_information5 is null))
and (   locked_row.entry_information6 = p_entry_information6
or (    locked_row.entry_information6 is null and p_entry_information6 is null))
and (   locked_row.entry_information7 = p_entry_information7
or (    locked_row.entry_information7 is null and p_entry_information7 is null))
and (   locked_row.entry_information8 = p_entry_information8
or (    locked_row.entry_information8 is null and p_entry_information8 is null))
and (   locked_row.entry_information9 = p_entry_information9
or (    locked_row.entry_information9 is null and p_entry_information9 is null))
and (   locked_row.entry_information10 = p_entry_information10
or (    locked_row.entry_information10 is null and p_entry_information10 is null))
and (   locked_row.entry_information11 = p_entry_information11
or (    locked_row.entry_information11 is null and p_entry_information11 is null))
and (   locked_row.entry_information12 = p_entry_information12
or (    locked_row.entry_information12 is null and p_entry_information12 is null))
and (   locked_row.entry_information13 = p_entry_information13
or (    locked_row.entry_information13 is null and p_entry_information13 is null))
and (   locked_row.entry_information14 = p_entry_information14
or (    locked_row.entry_information14 is null and p_entry_information14 is null))
and (   locked_row.entry_information15 = p_entry_information15
or (    locked_row.entry_information15 is null and p_entry_information15 is null))
and (   locked_row.entry_information16 = p_entry_information16
or (    locked_row.entry_information16 is null and p_entry_information16 is null))
and (   locked_row.entry_information17 = p_entry_information17
or (    locked_row.entry_information17 is null and p_entry_information17 is null))
and (   locked_row.entry_information18 = p_entry_information18
or (    locked_row.entry_information18 is null and p_entry_information18 is null))
and (   locked_row.entry_information19 = p_entry_information19
or (    locked_row.entry_information19 is null and p_entry_information19 is null))
and (   locked_row.entry_information20 = p_entry_information20
or (    locked_row.entry_information20 is null and p_entry_information20 is null))
and (   locked_row.entry_information21 = p_entry_information21
or (    locked_row.entry_information21 is null and p_entry_information21 is null))
and (   locked_row.entry_information22 = p_entry_information22
or (    locked_row.entry_information22 is null and p_entry_information22 is null))
and (   locked_row.entry_information23 = p_entry_information23
or (    locked_row.entry_information23 is null and p_entry_information23 is null))
and (   locked_row.entry_information24 = p_entry_information24
or (    locked_row.entry_information24 is null and p_entry_information24 is null))
and (   locked_row.entry_information25 = p_entry_information25
or (    locked_row.entry_information25 is null and p_entry_information25 is null))
and (   locked_row.entry_information26 = p_entry_information26
or (    locked_row.entry_information26 is null and p_entry_information26 is null))
and (   locked_row.entry_information27 = p_entry_information27
or (    locked_row.entry_information27 is null and p_entry_information27 is null))
and (   locked_row.entry_information28 = p_entry_information28
or (    locked_row.entry_information28 is null and p_entry_information28 is null))
and (   locked_row.entry_information29 = p_entry_information29
or (    locked_row.entry_information29 is null and p_entry_information29 is null))
and (   locked_row.entry_information30 = p_entry_information30
or (    locked_row.entry_information30 is null and p_entry_information30 is null))
-- end --
and (   locked_row.date_earned = p_date_earned
or (    locked_row.date_earned is null and p_date_earned is null))
and (   locked_row.personal_payment_method_id = p_personal_payment_method_id
or (    locked_row.personal_payment_method_id is null and p_personal_payment_method_id is null))
) then
  return;
else
  fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
  app_exception.raise_exception;
end if;
--
end lock_row;


procedure GET_INPUT_VALUE_DETAILS (
--
-- Returns the input value details for the element selected by an LOV
--
p_element_link_id	number,
p_element_type_id	number,
p_effective_date	date,
p_input_currency_code	varchar2,
p_contributions_used	varchar2,
p_input_value_id1	in out nocopy number,
p_input_value_id2	in out nocopy number,
p_input_value_id3	in out nocopy number,
p_input_value_id4	in out nocopy number,
p_input_value_id5	in out nocopy number,
p_input_value_id6	in out nocopy number,
p_input_value_id7	in out nocopy number,
p_input_value_id8	in out nocopy number,
p_input_value_id9	in out nocopy number,
p_input_value_id10	in out nocopy number,
p_input_value_id11	in out nocopy number,
p_input_value_id12	in out nocopy number,
p_input_value_id13	in out nocopy number,
p_input_value_id14	in out nocopy number,
p_input_value_id15	in out nocopy number,
p_name1			in out nocopy varchar2,
p_name2			in out nocopy varchar2,
p_name3			in out nocopy varchar2,
p_name4			in out nocopy varchar2,
p_name5			in out nocopy varchar2,
p_name6			in out nocopy varchar2,
p_name7			in out nocopy varchar2,
p_name8			in out nocopy varchar2,
p_name9			in out nocopy varchar2,
p_name10		in out nocopy varchar2,
p_name11		in out nocopy varchar2,
p_name12		in out nocopy varchar2,
p_name13		in out nocopy varchar2,
p_name14		in out nocopy varchar2,
p_name15		in out nocopy varchar2,
p_uom1			in out nocopy varchar2,
p_uom2			in out nocopy varchar2,
p_uom3			in out nocopy varchar2,
p_uom4			in out nocopy varchar2,
p_uom5			in out nocopy varchar2,
p_uom6			in out nocopy varchar2,
p_uom7			in out nocopy varchar2,
p_uom8			in out nocopy varchar2,
p_uom9			in out nocopy varchar2,
p_uom10			in out nocopy varchar2,
p_uom11			in out nocopy varchar2,
p_uom12			in out nocopy varchar2,
p_uom13			in out nocopy varchar2,
p_uom14			in out nocopy varchar2,
p_uom15			in out nocopy varchar2,
p_hot_default_flag1	in out nocopy varchar2,
p_hot_default_flag2	in out nocopy varchar2,
p_hot_default_flag3	in out nocopy varchar2,
p_hot_default_flag4	in out nocopy varchar2,
p_hot_default_flag5	in out nocopy varchar2,
p_hot_default_flag6	in out nocopy varchar2,
p_hot_default_flag7	in out nocopy varchar2,
p_hot_default_flag8	in out nocopy varchar2,
p_hot_default_flag9	in out nocopy varchar2,
p_hot_default_flag10	in out nocopy varchar2,
p_hot_default_flag11	in out nocopy varchar2,
p_hot_default_flag12	in out nocopy varchar2,
p_hot_default_flag13	in out nocopy varchar2,
p_hot_default_flag14	in out nocopy varchar2,
p_hot_default_flag15	in out nocopy varchar2,
p_mandatory_flag1	in out nocopy varchar2,
p_mandatory_flag2	in out nocopy varchar2,
p_mandatory_flag3	in out nocopy varchar2,
p_mandatory_flag4	in out nocopy varchar2,
p_mandatory_flag5	in out nocopy varchar2,
p_mandatory_flag6	in out nocopy varchar2,
p_mandatory_flag7	in out nocopy varchar2,
p_mandatory_flag8	in out nocopy varchar2,
p_mandatory_flag9	in out nocopy varchar2,
p_mandatory_flag10	in out nocopy varchar2,
p_mandatory_flag11	in out nocopy varchar2,
p_mandatory_flag12	in out nocopy varchar2,
p_mandatory_flag13	in out nocopy varchar2,
p_mandatory_flag14	in out nocopy varchar2,
p_mandatory_flag15	in out nocopy varchar2,
p_formula_id1		in out nocopy number,
p_formula_id2		in out nocopy number,
p_formula_id3		in out nocopy number,
p_formula_id4		in out nocopy number,
p_formula_id5		in out nocopy number,
p_formula_id6		in out nocopy number,
p_formula_id7		in out nocopy number,
p_formula_id8		in out nocopy number,
p_formula_id9		in out nocopy number,
p_formula_id10		in out nocopy number,
p_formula_id11		in out nocopy number,
p_formula_id12		in out nocopy number,
p_formula_id13		in out nocopy number,
p_formula_id14		in out nocopy number,
p_formula_id15		in out nocopy number,
p_lookup_type1		in out nocopy varchar2,
p_lookup_type2		in out nocopy varchar2,
p_lookup_type3		in out nocopy varchar2,
p_lookup_type4		in out nocopy varchar2,
p_lookup_type5		in out nocopy varchar2,
p_lookup_type6		in out nocopy varchar2,
p_lookup_type7		in out nocopy varchar2,
p_lookup_type8		in out nocopy varchar2,
p_lookup_type9		in out nocopy varchar2,
p_lookup_type10		in out nocopy varchar2,
p_lookup_type11		in out nocopy varchar2,
p_lookup_type12		in out nocopy varchar2,
p_lookup_type13		in out nocopy varchar2,
p_lookup_type14		in out nocopy varchar2,
p_lookup_type15		in out nocopy varchar2,
p_value_set_id1    in out nocopy number,
p_value_set_id2    in out nocopy number,
p_value_set_id3    in out nocopy number,
p_value_set_id4    in out nocopy number,
p_value_set_id5    in out nocopy number,
p_value_set_id6    in out nocopy number,
p_value_set_id7    in out nocopy number,
p_value_set_id8    in out nocopy number,
p_value_set_id9    in out nocopy number,
p_value_set_id10    in out nocopy number,
p_value_set_id11    in out nocopy number,
p_value_set_id12    in out nocopy number,
p_value_set_id13    in out nocopy number,
p_value_set_id14    in out nocopy number,
p_value_set_id15    in out nocopy number,
p_min_value1		in out nocopy varchar2,
p_min_value2		in out nocopy varchar2,
p_min_value3		in out nocopy varchar2,
p_min_value4		in out nocopy varchar2,
p_min_value5		in out nocopy varchar2,
p_min_value6		in out nocopy varchar2,
p_min_value7		in out nocopy varchar2,
p_min_value8		in out nocopy varchar2,
p_min_value9		in out nocopy varchar2,
p_min_value10		in out nocopy varchar2,
p_min_value11		in out nocopy varchar2,
p_min_value12		in out nocopy varchar2,
p_min_value13		in out nocopy varchar2,
p_min_value14		in out nocopy varchar2,
p_min_value15		in out nocopy varchar2,
p_max_value1		in out nocopy varchar2,
p_max_value2		in out nocopy varchar2,
p_max_value3		in out nocopy varchar2,
p_max_value4		in out nocopy varchar2,
p_max_value5		in out nocopy varchar2,
p_max_value6		in out nocopy varchar2,
p_max_value7		in out nocopy varchar2,
p_max_value8		in out nocopy varchar2,
p_max_value9		in out nocopy varchar2,
p_max_value10		in out nocopy varchar2,
p_max_value11		in out nocopy varchar2,
p_max_value12		in out nocopy varchar2,
p_max_value13		in out nocopy varchar2,
p_max_value14		in out nocopy varchar2,
p_max_value15		in out nocopy varchar2,
p_default_value1	in out nocopy varchar2,
p_default_value2	in out nocopy varchar2,
p_default_value3	in out nocopy varchar2,
p_default_value4	in out nocopy varchar2,
p_default_value5	in out nocopy varchar2,
p_default_value6	in out nocopy varchar2,
p_default_value7	in out nocopy varchar2,
p_default_value8	in out nocopy varchar2,
p_default_value9	in out nocopy varchar2,
p_default_value10	in out nocopy varchar2,
p_default_value11	in out nocopy varchar2,
p_default_value12	in out nocopy varchar2,
p_default_value13	in out nocopy varchar2,
p_default_value14	in out nocopy varchar2,
p_default_value15	in out nocopy varchar2,
p_warning_or_error1	in out nocopy varchar2,
p_warning_or_error2	in out nocopy varchar2,
p_warning_or_error3	in out nocopy varchar2,
p_warning_or_error4	in out nocopy varchar2,
p_warning_or_error5	in out nocopy varchar2,
p_warning_or_error6	in out nocopy varchar2,
p_warning_or_error7	in out nocopy varchar2,
p_warning_or_error8	in out nocopy varchar2,
p_warning_or_error9	in out nocopy varchar2,
p_warning_or_error10	in out nocopy varchar2,
p_warning_or_error11	in out nocopy varchar2,
p_warning_or_error12	in out nocopy varchar2,
p_warning_or_error13	in out nocopy varchar2,
p_warning_or_error14	in out nocopy varchar2,
p_warning_or_error15	in out nocopy varchar2) is
--
-- If the element is a type A benefit plan and it has only
-- one coverage type, then we can help the user by defaulting
-- the coverage and contribution input values
--
cursor csr_default_coverage is
	--
	select	coverage.meaning,
		benefit.employee_contribution,
		benefit.employer_contribution
		--
	from	ben_benefit_contributions_f	BENEFIT,
		hr_lookups			COVERAGE
		--
	where	coverage.lookup_type = 'US_BENEFIT_COVERAGE'
	and	coverage.lookup_code = benefit.coverage_type
	and	benefit.element_type_id = p_element_type_id
	and	p_effective_date between benefit.effective_start_date
					and benefit.effective_end_date
	and	1 = (select count (*)
			from ben_benefit_contributions_f BENEFIT2
			where benefit2.element_type_id = p_element_type_id
			and p_effective_date between benefit2.effective_start_date
						and benefit2.effective_end_date)
					;
	--
cursor SET_OF_INPUT_VALUES is
	--
	select	type.input_value_id,
		type_tl.name,
		type.uom,
		type.lookup_type,
      type.value_set_id,
		type.formula_id,
		decode (type.hot_default_flag,
			'N',link.warning_or_error,
			nvl (link.warning_or_error,
				type.warning_or_error)) WARNING_OR_ERROR,
		type.mandatory_flag,
		decode (p_contributions_used,
			'Y',decode (type.name,
					g_er_contributions, 'Y',
					g_ee_contributions, 'Y',
					type.hot_default_flag),
			type.hot_default_flag) HOT_DEFAULT_FLAG,
		decode(type.hot_default_flag,'N',link.min_value,
                       nvl(link.min_value,type.min_value)) MIN_VALUE,
		decode(type.hot_default_flag,'N',link.max_value,
                       nvl(link.max_value,type.max_value)) MAX_VALUE,
                pay_paywsmee_pkg.formatted_default (	link.default_value,
							type.default_value,
							type.uom,
							type.hot_default_flag,
							p_contributions_used,
							type.name,
							p_input_currency_code,
							type.lookup_type,
                     type.value_set_id) DEFAULT_VALUE
		--
	from	pay_input_values_f	TYPE,
                pay_input_values_f_tl   TYPE_TL,
		pay_link_input_values_f	LINK
		--
	where	type_tl.input_value_id = type.input_value_id
        and     userenv('LANG') = type_tl.language
        and     p_effective_date between type.effective_start_date
					and type.effective_end_date
	and	p_effective_date between link.effective_start_date
					and link.effective_end_date
	and	p_element_link_id	= link.element_link_id
	and	type.input_value_id	= link.input_value_id
	order by type.display_sequence, type.name;
	--
input_value_number	integer;
v_coverage		varchar2 (60);
v_EE_contr		varchar2 (60);
v_ER_contr		varchar2 (60);
--
begin
--
-- First, nullify all the entry values to ensure that we overwrite any
-- previous fetches
--
p_input_value_id1 := null;
p_input_value_id2 := null;
p_input_value_id3 := null;
p_input_value_id4 := null;
p_input_value_id5 := null;
p_input_value_id6 := null;
p_input_value_id7 := null;
p_input_value_id8 := null;
p_input_value_id9 := null;
p_input_value_id10 := null;
p_input_value_id11 := null;
p_input_value_id12 := null;
p_input_value_id13 := null;
p_input_value_id14 := null;
p_input_value_id15 := null;

--
p_name1 := null;
p_name2 := null;
p_name3 := null;
p_name4 := null;
p_name5 := null;
p_name6 := null;
p_name7 := null;
p_name8 := null;
p_name9 := null;
p_name10 := null;
p_name11 := null;
p_name12 := null;
p_name13 := null;
p_name14 := null;
p_name15 := null;

--
p_uom1 := null;
p_uom2 := null;
p_uom3 := null;
p_uom4 := null;
p_uom5 := null;
p_uom6 := null;
p_uom7 := null;
p_uom8 := null;
p_uom9 := null;
p_uom10 := null;
p_uom11 := null;
p_uom12 := null;
p_uom13 := null;
p_uom14 := null;
p_uom15 := null;

--
p_hot_default_flag1 := null;
p_hot_default_flag2 := null;
p_hot_default_flag3 := null;
p_hot_default_flag4 := null;
p_hot_default_flag5 := null;
p_hot_default_flag6 := null;
p_hot_default_flag7 := null;
p_hot_default_flag8 := null;
p_hot_default_flag9 := null;
p_hot_default_flag10 := null;
p_hot_default_flag11 := null;
p_hot_default_flag12 := null;
p_hot_default_flag13 := null;
p_hot_default_flag14 := null;
p_hot_default_flag15 := null;

--
p_mandatory_flag1 := null;
p_mandatory_flag2 := null;
p_mandatory_flag3 := null;
p_mandatory_flag4 := null;
p_mandatory_flag5 := null;
p_mandatory_flag6 := null;
p_mandatory_flag7 := null;
p_mandatory_flag8 := null;
p_mandatory_flag9 := null;
p_mandatory_flag10 := null;
p_mandatory_flag11 := null;
p_mandatory_flag12 := null;
p_mandatory_flag13 := null;
p_mandatory_flag14 := null;
p_mandatory_flag15 := null;

--
p_formula_id1 := null;
p_formula_id2 := null;
p_formula_id3 := null;
p_formula_id4 := null;
p_formula_id5 := null;
p_formula_id6 := null;
p_formula_id7 := null;
p_formula_id8 := null;
p_formula_id9 := null;
p_formula_id10 := null;
p_formula_id11 := null;
p_formula_id12 := null;
p_formula_id13 := null;
p_formula_id14 := null;
p_formula_id15 := null;

--
p_lookup_type1 := null;
p_lookup_type2 := null;
p_lookup_type3 := null;
p_lookup_type4 := null;
p_lookup_type5 := null;
p_lookup_type6 := null;
p_lookup_type7 := null;
p_lookup_type8 := null;
p_lookup_type9 := null;
p_lookup_type10 := null;
p_lookup_type11 := null;
p_lookup_type12 := null;
p_lookup_type13 := null;
p_lookup_type14 := null;
p_lookup_type15 := null;

--
p_value_set_id1 := null;
p_value_set_id2 := null;
p_value_set_id3 := null;
p_value_set_id4 := null;
p_value_set_id5 := null;
p_value_set_id6 := null;
p_value_set_id7 := null;
p_value_set_id8 := null;
p_value_set_id9 := null;
p_value_set_id10 := null;
p_value_set_id11 := null;
p_value_set_id12 := null;
p_value_set_id13 := null;
p_value_set_id14 := null;
p_value_set_id15 := null;

--
p_min_value1 := null;
p_min_value2 := null;
p_min_value3 := null;
p_min_value4 := null;
p_min_value5 := null;
p_min_value6 := null;
p_min_value7 := null;
p_min_value8 := null;
p_min_value9 := null;
p_min_value10 := null;
p_min_value11 := null;
p_min_value12 := null;
p_min_value13 := null;
p_min_value14 := null;
p_min_value15 := null;

--
p_max_value1 := null;
p_max_value2 := null;
p_max_value3 := null;
p_max_value4 := null;
p_max_value5 := null;
p_max_value6 := null;
p_max_value7 := null;
p_max_value8 := null;
p_max_value9 := null;
p_max_value10 := null;
p_max_value11 := null;
p_max_value12 := null;
p_max_value13 := null;
p_max_value14 := null;
p_max_value15 := null;

--
p_default_value1 := null;
p_default_value2 := null;
p_default_value3 := null;
p_default_value4 := null;
p_default_value5 := null;
p_default_value6 := null;
p_default_value7 := null;
p_default_value8 := null;
p_default_value9 := null;
p_default_value10 := null;
p_default_value11 := null;
p_default_value12 := null;
p_default_value13 := null;
p_default_value14 := null;
p_default_value15 := null;

--
p_warning_or_error1 := null;
p_warning_or_error2 := null;
p_warning_or_error3 := null;
p_warning_or_error4 := null;
p_warning_or_error5 := null;
p_warning_or_error6 := null;
p_warning_or_error7 := null;
p_warning_or_error8 := null;
p_warning_or_error9 := null;
p_warning_or_error10 := null;
p_warning_or_error11 := null;
p_warning_or_error12 := null;
p_warning_or_error13 := null;
p_warning_or_error14 := null;
p_warning_or_error15 := null;

--
-- Fetch all the input values and their properties
--
for fetched_input_value in set_of_input_values LOOP
  --
  input_value_number := set_of_input_values%rowcount; -- loop index flag
  --
  -- Now we need to put the input value details into the right parameters
  -- to pass back to the form; the comments within the action for
  -- input_value_number = 1 also apply for all the others
  --
  -- First, we need to override the type and link level information if
  -- the element is a type A Benefit Plan
  --
  if p_contributions_used = 'Y' then
    --
    if fetched_input_value.name = g_coverage then
      --
      -- Get the benefit coverage information.
      -- NB Because we know that the coverage input value will always be
      -- ordered before the contribution entry values (because we default the
      -- display sequence and prevent update), we can get the defaults for the
      -- contributions as soon as we come across the coverage input value.
      --
      open csr_default_coverage;
      fetch csr_default_coverage into v_coverage, v_EE_contr, v_ER_contr;
      close csr_default_coverage;
      --
      -- Default the coverage entry value
      --
      fetched_input_value.default_value := v_coverage;
      --
    elsif fetched_input_value.name = g_ee_contributions then
      --
      -- Default the employee contribution entry value
      --
      fetched_input_value.default_value := hr_chkfmt.changeformat (v_EE_contr,
								fetched_input_value.uom,
								p_input_currency_code);
      --
      -- Format it as if it were a hot default
      --
      if fetched_input_value.default_value is not null then
	fetched_input_value.default_value := '"'||fetched_input_value.default_value||'"';
      end if;
      --
    elsif fetched_input_value.name = g_er_contributions then
      --
      -- Default the employer contribution entry value
      --
      fetched_input_value.default_value := hr_chkfmt.changeformat (v_ER_contr,
								fetched_input_value.uom,
								p_input_currency_code);
      --
      --
      -- Format it as if it were a hot default
      --
      if fetched_input_value.default_value is not null then
	fetched_input_value.default_value := '"'||fetched_input_value.default_value||'"';
      end if;
      --
    end if;
    --
  end if;
  --
  if input_value_number = 1 then
    --
    -- assign the out parameters
    --
    p_input_value_id1 	:= fetched_input_value.input_value_id;
    p_uom1		:= fetched_input_value.uom;
    p_name1		:= fetched_input_value.name;
    p_hot_default_flag1	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag1	:= fetched_input_value.mandatory_flag;
    p_warning_or_error1	:= fetched_input_value.warning_or_error;
    p_lookup_type1	:= fetched_input_value.lookup_type;
    p_value_set_id1	:= fetched_input_value.value_set_id;
    p_formula_id1	:= fetched_input_value.formula_id;
    p_min_value1	:= fetched_input_value.min_value;
    p_max_value1	:= fetched_input_value.max_value;
    p_default_value1	:= fetched_input_value.default_value;
    --
  elsif input_value_number =2 then
--
    p_input_value_id2 	:= fetched_input_value.input_value_id;
    p_uom2		:= fetched_input_value.uom;
    p_name2		:= fetched_input_value.name;
    p_hot_default_flag2	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag2	:= fetched_input_value.mandatory_flag;
    p_warning_or_error2	:= fetched_input_value.warning_or_error;
    p_lookup_type2	:= fetched_input_value.lookup_type;
    p_value_set_id2  := fetched_input_value.value_set_id;
    p_formula_id2	:= fetched_input_value.formula_id;
    p_min_value2	:= fetched_input_value.min_value;
    p_max_value2	:= fetched_input_value.max_value;
    p_default_value2	:= fetched_input_value.default_value;
--
  elsif input_value_number =3 then
--
    p_input_value_id3 	:= fetched_input_value.input_value_id;
    p_uom3		:= fetched_input_value.uom;
    p_name3		:= fetched_input_value.name;
    p_hot_default_flag3	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag3	:= fetched_input_value.mandatory_flag;
    p_warning_or_error3	:= fetched_input_value.warning_or_error;
    p_lookup_type3	:= fetched_input_value.lookup_type;
    p_value_set_id3  := fetched_input_value.value_set_id;
    p_formula_id3	:= fetched_input_value.formula_id;
    p_min_value3	:= fetched_input_value.min_value;
    p_max_value3	:= fetched_input_value.max_value;
    p_default_value3	:= fetched_input_value.default_value;
--
  elsif input_value_number =4 then
--
    p_input_value_id4 	:= fetched_input_value.input_value_id;
    p_uom4		:= fetched_input_value.uom;
    p_name4		:= fetched_input_value.name;
    p_hot_default_flag4	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag4	:= fetched_input_value.mandatory_flag;
    p_warning_or_error4	:= fetched_input_value.warning_or_error;
    p_lookup_type4	:= fetched_input_value.lookup_type;
    p_value_set_id4  := fetched_input_value.value_set_id;
    p_formula_id4	:= fetched_input_value.formula_id;
    p_min_value4	:= fetched_input_value.min_value;
    p_max_value4	:= fetched_input_value.max_value;
    p_default_value4	:= fetched_input_value.default_value;
--
  elsif input_value_number =5 then
--
    p_input_value_id5 	:= fetched_input_value.input_value_id;
    p_uom5		:= fetched_input_value.uom;
    p_name5		:= fetched_input_value.name;
    p_hot_default_flag5	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag5	:= fetched_input_value.mandatory_flag;
    p_warning_or_error5	:= fetched_input_value.warning_or_error;
    p_lookup_type5	:= fetched_input_value.lookup_type;
    p_value_set_id5  := fetched_input_value.value_set_id;
    p_formula_id5	:= fetched_input_value.formula_id;
    p_min_value5	:= fetched_input_value.min_value;
    p_max_value5	:= fetched_input_value.max_value;
    p_default_value5	:= fetched_input_value.default_value;
--
  elsif input_value_number =6 then
--
    p_input_value_id6 	:= fetched_input_value.input_value_id;
    p_uom6		:= fetched_input_value.uom;
    p_name6		:= fetched_input_value.name;
    p_hot_default_flag6	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag6	:= fetched_input_value.mandatory_flag;
    p_warning_or_error6	:= fetched_input_value.warning_or_error;
    p_lookup_type6	:= fetched_input_value.lookup_type;
    p_value_set_id6  := fetched_input_value.value_set_id;
    p_formula_id6	:= fetched_input_value.formula_id;
    p_min_value6	:= fetched_input_value.min_value;
    p_max_value6	:= fetched_input_value.max_value;
    p_default_value6	:= fetched_input_value.default_value;
--
  elsif input_value_number =7 then
--
    p_input_value_id7 	:= fetched_input_value.input_value_id;
    p_uom7		:= fetched_input_value.uom;
    p_name7		:= fetched_input_value.name;
    p_hot_default_flag7	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag7	:= fetched_input_value.mandatory_flag;
    p_warning_or_error7	:= fetched_input_value.warning_or_error;
    p_lookup_type7	:= fetched_input_value.lookup_type;
    p_value_set_id7  := fetched_input_value.value_set_id;
    p_formula_id7	:= fetched_input_value.formula_id;
    p_min_value7	:= fetched_input_value.min_value;
    p_max_value7	:= fetched_input_value.max_value;
    p_default_value7	:= fetched_input_value.default_value;
--
  elsif input_value_number =8 then
--
    p_input_value_id8 	:= fetched_input_value.input_value_id;
    p_uom8		:= fetched_input_value.uom;
    p_name8		:= fetched_input_value.name;
    p_hot_default_flag8	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag8	:= fetched_input_value.mandatory_flag;
    p_warning_or_error8	:= fetched_input_value.warning_or_error;
    p_lookup_type8	:= fetched_input_value.lookup_type;
    p_value_set_id8  := fetched_input_value.value_set_id;
    p_formula_id8	:= fetched_input_value.formula_id;
    p_min_value8	:= fetched_input_value.min_value;
    p_max_value8	:= fetched_input_value.max_value;
    p_default_value8	:= fetched_input_value.default_value;
--
  elsif input_value_number =9 then
--
    p_input_value_id9 	:= fetched_input_value.input_value_id;
    p_uom9		:= fetched_input_value.uom;
    p_name9		:= fetched_input_value.name;
    p_hot_default_flag9	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag9	:= fetched_input_value.mandatory_flag;
    p_warning_or_error9	:= fetched_input_value.warning_or_error;
    p_lookup_type9	:= fetched_input_value.lookup_type;
    p_value_set_id9  := fetched_input_value.value_set_id;
    p_formula_id9	:= fetched_input_value.formula_id;
    p_min_value9	:= fetched_input_value.min_value;
    p_max_value9	:= fetched_input_value.max_value;
    p_default_value9	:= fetched_input_value.default_value;
--
  elsif input_value_number =10 then
--
    p_input_value_id10 		:= fetched_input_value.input_value_id;
    p_uom10			:= fetched_input_value.uom;
    p_name10			:= fetched_input_value.name;
    p_hot_default_flag10	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag10		:= fetched_input_value.mandatory_flag;
    p_warning_or_error10	:= fetched_input_value.warning_or_error;
    p_lookup_type10		:= fetched_input_value.lookup_type;
    p_value_set_id10  := fetched_input_value.value_set_id;
    p_formula_id10		:= fetched_input_value.formula_id;
    p_min_value10	:= fetched_input_value.min_value;
    p_max_value10	:= fetched_input_value.max_value;
    p_default_value10	:= fetched_input_value.default_value;
--
  elsif input_value_number =11 then
--
    p_input_value_id11 		:= fetched_input_value.input_value_id;
    p_uom11			:= fetched_input_value.uom;
    p_name11			:= fetched_input_value.name;
    p_hot_default_flag11	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag11		:= fetched_input_value.mandatory_flag;
    p_warning_or_error11	:= fetched_input_value.warning_or_error;
    p_lookup_type11		:= fetched_input_value.lookup_type;
    p_value_set_id11  := fetched_input_value.value_set_id;
    p_formula_id11		:= fetched_input_value.formula_id;
    p_min_value11	:= fetched_input_value.min_value;
    p_max_value11	:= fetched_input_value.max_value;
    p_default_value11	:= fetched_input_value.default_value;
--
  elsif input_value_number =12 then
--
    p_input_value_id12 		:= fetched_input_value.input_value_id;
    p_uom12			:= fetched_input_value.uom;
    p_name12			:= fetched_input_value.name;
    p_hot_default_flag12	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag12		:= fetched_input_value.mandatory_flag;
    p_warning_or_error12	:= fetched_input_value.warning_or_error;
    p_lookup_type12		:= fetched_input_value.lookup_type;
    p_value_set_id12  := fetched_input_value.value_set_id;
    p_formula_id12		:= fetched_input_value.formula_id;
    p_min_value12	:= fetched_input_value.min_value;
    p_max_value12	:= fetched_input_value.max_value;
    p_default_value12	:= fetched_input_value.default_value;
--
  elsif input_value_number =13 then
--
    p_input_value_id13 		:= fetched_input_value.input_value_id;
    p_uom13			:= fetched_input_value.uom;
    p_name13			:= fetched_input_value.name;
    p_hot_default_flag13	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag13		:= fetched_input_value.mandatory_flag;
    p_warning_or_error13	:= fetched_input_value.warning_or_error;
    p_lookup_type13		:= fetched_input_value.lookup_type;
    p_value_set_id13  := fetched_input_value.value_set_id;
    p_formula_id13		:= fetched_input_value.formula_id;
    p_min_value13	:= fetched_input_value.min_value;
    p_max_value13	:= fetched_input_value.max_value;
    p_default_value13	:= fetched_input_value.default_value;
--
  elsif input_value_number =14 then
--
    p_input_value_id14 		:= fetched_input_value.input_value_id;
    p_uom14			:= fetched_input_value.uom;
    p_name14			:= fetched_input_value.name;
    p_hot_default_flag14	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag14		:= fetched_input_value.mandatory_flag;
    p_warning_or_error14	:= fetched_input_value.warning_or_error;
    p_lookup_type14		:= fetched_input_value.lookup_type;
    p_value_set_id14  := fetched_input_value.value_set_id;
    p_formula_id14		:= fetched_input_value.formula_id;
    p_min_value14	:= fetched_input_value.min_value;
    p_max_value14	:= fetched_input_value.max_value;
    p_default_value14	:= fetched_input_value.default_value;
--
  elsif input_value_number =15 then
--
    p_input_value_id15 		:= fetched_input_value.input_value_id;
    p_uom15			:= fetched_input_value.uom;
    p_name15			:= fetched_input_value.name;
    p_hot_default_flag15	:= fetched_input_value.hot_default_flag;
    p_mandatory_flag15		:= fetched_input_value.mandatory_flag;
    p_warning_or_error15	:= fetched_input_value.warning_or_error;
    p_lookup_type15		:= fetched_input_value.lookup_type;
    p_value_set_id15  := fetched_input_value.value_set_id;
    p_formula_id15		:= fetched_input_value.formula_id;
    p_min_value15	:= fetched_input_value.min_value;
    p_max_value15	:= fetched_input_value.max_value;
    p_default_value15	:= fetched_input_value.default_value;
--
    exit; -- stop looping after the fifteenth input value
--
  end if;
--
end loop;
--
end get_input_value_details;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
end PAY_PAYWSMEE2_PKG;

/
