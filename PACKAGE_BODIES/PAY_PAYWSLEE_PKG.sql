--------------------------------------------------------
--  DDL for Package Body PAY_PAYWSLEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYWSLEE_PKG" as
/* $Header: paywslee.pkb 120.1 2006/05/05 01:31:06 pgongada noship $ */
--
procedure get_input_value_names (
--
p_element_type_id	in	       number,
p_name1			in out	nocopy varchar2,
p_name2			in out	nocopy varchar2,
p_name3			in out	nocopy varchar2,
p_name4			in out	nocopy varchar2,
p_name5			in out	nocopy varchar2,
p_name6			in out	nocopy varchar2,
p_name7			in out	nocopy varchar2,
p_name8			in out	nocopy varchar2,
p_name9			in out	nocopy varchar2,
p_name10		in out	nocopy varchar2,
p_name11		in out	nocopy varchar2,
p_name12		in out	nocopy varchar2,
p_name13		in out	nocopy varchar2,
p_name14		in out	nocopy varchar2,
p_name15		in out	nocopy varchar2) is
--
cursor set_of_input_values is
	--
	select	input_value_tl.name
	--
	from	pay_input_values_f_tl INPUT_VALUE_TL,
                pay_input_values_f INPUT_VALUE
	--
	where	input_value.element_type_id	= p_element_type_id
        and     input_value_tl.input_value_id  = input_value.input_value_id
        and     userenv('LANG') = input_value_tl.language
	and	input_value.effective_start_date =
		(select min (element.effective_start_date)
		from	pay_element_types_f	ELEMENT
		where	element.element_type_id = p_element_type_id)
		--
	order by	input_value.display_sequence,
			input_value_tl.name;
			--
input_value_number	integer;
--
begin
--
-- Nullify the parameters before populating them (because we may not replace
-- all 15 names)
--
p_name1		:= null;
p_name2		:= null;
p_name3		:= null;
p_name4		:= null;
p_name5		:= null;
p_name6		:= null;
p_name7		:= null;
p_name8		:= null;
p_name9		:= null;
p_name10	:= null;
p_name11	:= null;
p_name12	:= null;
p_name13	:= null;
p_name14	:= null;
p_name15	:= null;
--
-- Fetch all the input values
--
for fetched_input_value in set_of_input_values LOOP
  --
  input_value_number := set_of_input_values%rowcount; -- loop index flag
  --
  -- Now we need to put the input value names into the right parameters
  -- to pass back to the form
  --
  if input_value_number = 1 then
    --
    p_name1		:= fetched_input_value.name;
    --
  elsif input_value_number = 2 then
    --
    p_name2		:= fetched_input_value.name;
    --
  elsif input_value_number = 3 then
    --
    p_name3		:= fetched_input_value.name;
    --
  elsif input_value_number = 4 then
    --
    p_name4		:= fetched_input_value.name;
    --
  elsif input_value_number = 5 then
    --
    p_name5		:= fetched_input_value.name;
    --
  elsif input_value_number = 6 then
    --
    p_name6		:= fetched_input_value.name;
    --
  elsif input_value_number = 7 then
    --
    p_name7		:= fetched_input_value.name;
    --
  elsif input_value_number = 8 then
    --
    p_name8		:= fetched_input_value.name;
    --
  elsif input_value_number = 9 then
    --
    p_name9		:= fetched_input_value.name;
    --
  elsif input_value_number = 10 then
    --
    p_name10		:= fetched_input_value.name;
    --
  elsif input_value_number = 11 then
    --
    p_name11		:= fetched_input_value.name;
    --
  elsif input_value_number = 12 then
    --
    p_name12		:= fetched_input_value.name;
    --
  elsif input_value_number = 13 then
    --
    p_name13		:= fetched_input_value.name;
    --
  elsif input_value_number = 14 then
    --
    p_name14		:= fetched_input_value.name;
    --
  elsif input_value_number = 15 then
    --
    p_name15		:= fetched_input_value.name;
    --
  end if;
  --
end loop;
--
end get_input_value_names;
--------------------------------------------------------------------------------
procedure get_input_value_names (
--
p_rows                  in out  nocopy number,
p_element_type_id       in             number,
p_ivn_tab               in out  nocopy IvnTabType) is
--
cursor set_of_input_values is
        --
        select  input_value_tl.name
        --
        from    pay_input_values_f_tl INPUT_VALUE_TL,
                pay_input_values_f INPUT_VALUE
        --
        where   input_value.element_type_id     = p_element_type_id
        and     input_value_tl.input_value_id  = input_value.input_value_id
        and     userenv('LANG') = input_value_tl.language
        and     input_value.effective_start_date =
                (select min (element.effective_start_date)
                from    pay_element_types_f     ELEMENT
                where   element.element_type_id = p_element_type_id)
        order by        input_value.display_sequence,
                        input_value_tl.name;
                        --
--
begin
--
p_rows := 0;
--
for fetched_input_value in set_of_input_values LOOP
  --
  p_rows  := p_rows  + 1;
  p_ivn_tab(p_rows) := fetched_input_value.name;
--
end loop;
--
end get_input_value_names;
--------------------------------------------------------------------
procedure get_entry_details (
--
p_element_entry_id	in	       number,
p_element_link_id	in	       number,
p_assignment_id		in	       number,
p_effective_end_date	in	       date,
p_full_name		in out	nocopy varchar2,
p_assignment_number	in out	nocopy varchar2,
p_screen_entry_value1	in out	nocopy varchar2,
p_screen_entry_value2	in out	nocopy varchar2,
p_screen_entry_value3	in out	nocopy varchar2,
p_screen_entry_value4	in out	nocopy varchar2,
p_screen_entry_value5	in out	nocopy varchar2,
p_screen_entry_value6	in out	nocopy varchar2,
p_screen_entry_value7	in out	nocopy varchar2,
p_screen_entry_value8	in out	nocopy varchar2,
p_screen_entry_value9	in out	nocopy varchar2,
p_screen_entry_value10	in out	nocopy varchar2,
p_screen_entry_value11	in out	nocopy varchar2,
p_screen_entry_value12	in out	nocopy varchar2,
p_screen_entry_value13	in out	nocopy varchar2,
p_screen_entry_value14	in out	nocopy varchar2,
p_screen_entry_value15	in out	nocopy varchar2,
p_uom1			in out	nocopy varchar2,
p_uom2			in out	nocopy varchar2,
p_uom3			in out	nocopy varchar2,
p_uom4			in out	nocopy varchar2,
p_uom5			in out	nocopy varchar2,
p_uom6			in out	nocopy varchar2,
p_uom7			in out	nocopy varchar2,
p_uom8			in out	nocopy varchar2,
p_uom9			in out	nocopy varchar2,
p_uom10			in out	nocopy varchar2,
p_uom11			in out	nocopy varchar2,
p_uom12			in out	nocopy varchar2,
p_uom13			in out	nocopy varchar2,
p_uom14			in out	nocopy varchar2,
p_uom15			in out	nocopy varchar2) is
--
cursor asgt_details is
	--
	select	person.full_name,
		asgt.assignment_number
	from	per_people_f		PERSON,
		per_assignments_f2	ASGT
	where	person.person_id 	= asgt.person_id
	and	asgt.assignment_id	= p_assignment_id
	and	p_effective_end_date between asgt.effective_start_date
					and asgt.effective_end_date
	and	p_effective_end_date between person.effective_start_date
					and person.effective_end_date;
	--
cursor set_of_entry_values is
	--
	select	entry.screen_entry_value,
		type.uom,
		type.hot_default_flag,
		type.lookup_type,
		type.value_set_id,
		nvl (link.default_value, type.default_value) HOT_DEFAULT_VALUE
	from	pay_element_entry_values_f	ENTRY,
		pay_link_input_values_f		LINK,
		pay_input_values_f		TYPE
	where	entry.element_entry_id = p_element_entry_id
	and	link.element_link_id = p_element_link_id
	and	link.input_value_id = entry.input_value_id
	and	type.input_value_id = entry.input_value_id
	and	p_effective_end_date = entry.effective_end_date
	and	p_effective_end_date between link.effective_start_date
					and link.effective_end_date
	and	p_effective_end_date between type.effective_start_date
					and type.effective_end_date
	order by type.display_sequence, type.name;
	--
entry_value_number	integer;
--
begin
--
-- Retrieve the person's full name
--
open asgt_details;
fetch asgt_details into p_full_name, p_assignment_number;
close asgt_details;
--
-- Retrieve all the existing element entry values for the element entry
--
for fetched_entry_value in set_of_entry_values LOOP
  --
  entry_value_number := set_of_entry_values%rowcount; -- loop index flag
  --
  if entry_value_number = 1 then
    --
    p_uom1			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value1	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value1 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value1 is not null then
      --
      p_screen_entry_value1	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value1);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value1 is not null then
    --
	p_screen_entry_value1 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value1);
    --
    end if;
    --
  elsif entry_value_number = 2 then
    --
    p_uom2			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value2	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value2 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value2 is not null then
      --
      p_screen_entry_value2	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value2);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value2 is not null then
    --
	p_screen_entry_value2 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value2);
    --
    end if;
    --
  elsif entry_value_number = 3 then
    --
    p_uom3			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value3	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value3 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value3 is not null then
      --
      p_screen_entry_value3	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value3);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value3 is not null then
    --
	p_screen_entry_value3 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value3);
    --
    end if;
    --
  elsif entry_value_number = 4 then
    --
    p_uom4			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value4	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value4 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value4 is not null then
      --
      p_screen_entry_value4	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value4);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value4 is not null then
    --
	p_screen_entry_value4 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value4);
    --
    end if;
    --
  elsif entry_value_number = 5 then
    --
    p_uom5			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value5	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value5 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value5 is not null then
      --
      p_screen_entry_value5	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value5);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value5 is not null then
    --
	p_screen_entry_value5 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value5);
    --
    end if;
    --
  elsif entry_value_number = 6 then
    --
    p_uom6			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value6	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value6 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value6 is not null then
      --
      p_screen_entry_value6	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value6);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value6 is not null then
    --
	p_screen_entry_value6 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value6);
    --
    end if;
    --
  elsif entry_value_number = 7 then
    --
    p_uom7			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value7	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value7 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value7 is not null then
      --
      p_screen_entry_value7	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value7);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value7 is not null then
    --
	p_screen_entry_value7 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value7);
    --
    end if;
    --
  elsif entry_value_number = 8 then
    --
    p_uom8			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value8	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value8 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value8 is not null then
      --
      p_screen_entry_value8	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value8);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value8 is not null then
    --
	p_screen_entry_value8 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value8);
    --
    end if;
    --
  elsif entry_value_number = 9 then
    --
    p_uom9			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value9	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value9 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value9 is not null then
      --
      p_screen_entry_value9	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value9);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value9 is not null then
    --
	p_screen_entry_value9 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value9);
    --
    end if;
    --
  elsif entry_value_number = 10 then
    --
    p_uom10			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value10	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value10 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value10 is not null then
      --
      p_screen_entry_value10	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value10);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value10 is not null then
    --
	p_screen_entry_value10 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value10);
    --
    end if;
    --
  elsif entry_value_number = 11 then
    --
    p_uom11			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value11	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value11 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value11 is not null then
      --
      p_screen_entry_value11	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value11);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value11 is not null then
    --
	p_screen_entry_value11 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value11);
    --
    end if;
    --
  elsif entry_value_number = 12 then
    --
    p_uom12			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value12	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value12 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value12 is not null then
      --
      p_screen_entry_value12	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value12);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value12 is not null then
    --
	p_screen_entry_value12 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value12);
    --
    end if;
    --
  elsif entry_value_number = 13 then
    --
    p_uom13			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value13	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value13 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value13 is not null then
      --
      p_screen_entry_value13	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value13);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value13 is not null then
    --
	p_screen_entry_value13 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value13);
    --
    end if;
    --
  elsif entry_value_number = 14 then
    --
    p_uom14			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value14	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value14 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value14 is not null then
      --
      p_screen_entry_value14	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value14);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value14 is not null then
    --
	p_screen_entry_value14 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value14);
    --
    end if;
    --
  elsif entry_value_number = 15 then
    --
    p_uom15			:= fetched_entry_value.uom;
    --
    if fetched_entry_value.hot_default_flag = 'Y'
    and fetched_entry_value.screen_entry_value is null then
      --
      p_screen_entry_value15	:= fetched_entry_value.hot_default_value;
    else
      p_screen_entry_value15 	:= fetched_entry_value.screen_entry_value;
      --
    end if;
    --
    if fetched_entry_value.lookup_type is not null
    and p_screen_entry_value15 is not null then
      --
      p_screen_entry_value15	:= hr_general.decode_lookup
					(fetched_entry_value.lookup_type,
					p_screen_entry_value15);
      --
    end if;
    --
    if fetched_entry_value.value_set_id is not null
    and p_screen_entry_value15 is not null then
    --
	p_screen_entry_value15 := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_screen_entry_value15);
    --
    end if;
    --
  end if;
  --
end loop;
--
end get_entry_details;
--------------------------------------------------------------------------------
procedure get_entry_details (
--
p_rows                  in out  nocopy number,
p_element_entry_id      in             number,
p_element_link_id       in             number,
p_assignment_id         in             number,
p_effective_end_date    in             date,
p_full_name             in out  nocopy varchar2,
p_assignment_number     in out  nocopy varchar2,
p_entry_value_tab       in out  nocopy SevTabType,
p_uom_tab               in out  nocopy UomTabType
) is
--
cursor asgt_details is
        --
        select  person.full_name,
                asgt.assignment_number
        from    per_people_f            PERSON,
                per_assignments_f2      ASGT
        where   person.person_id        = asgt.person_id
        and     asgt.assignment_id      = p_assignment_id
        and     p_effective_end_date between asgt.effective_start_date
                                        and asgt.effective_end_date
        and     p_effective_end_date between person.effective_start_date
                                        and person.effective_end_date;
        --
cursor set_of_entry_values is
        --
        select  entry.screen_entry_value,
                type.uom,
                type.hot_default_flag,
                type.lookup_type,
		type.value_set_id,
                nvl (link.default_value, type.default_value) HOT_DEFAULT_VALUE
        from    pay_element_entry_values_f      ENTRY,
                pay_link_input_values_f         LINK,
                pay_input_values_f              TYPE
        where   entry.element_entry_id = p_element_entry_id
        and     link.element_link_id = p_element_link_id
        and     link.input_value_id = entry.input_value_id
        and     type.input_value_id = entry.input_value_id
        and     p_effective_end_date = entry.effective_end_date
        and     p_effective_end_date between link.effective_start_date
                                        and link.effective_end_date
        and     p_effective_end_date between type.effective_start_date
                                        and type.effective_end_date
        order by type.display_sequence, type.name;
        --
entry_value_number      integer;
--
begin
--
-- Retrieve the person's full name
--
open asgt_details;
fetch asgt_details into p_full_name, p_assignment_number;
close asgt_details;
--
-- Retrieve all the existing element entry values for the element entry
--
p_rows := 0;
for fetched_entry_value in set_of_entry_values LOOP
  --
  p_rows := p_rows + 1;
  p_uom_tab(p_rows)         := fetched_entry_value.uom;
  --
  if fetched_entry_value.hot_default_flag = 'Y'
  and fetched_entry_value.screen_entry_value is null then
    --
    p_entry_value_tab(p_rows) := fetched_entry_value.hot_default_value;
  else
    --
    p_entry_value_tab(p_rows) := fetched_entry_value.screen_entry_value;
  end if;
  --
  if fetched_entry_value.lookup_type is not null
  and p_entry_value_tab(p_rows) is not null then
    --
    p_entry_value_tab(p_rows) := hr_general.decode_lookup
                                        (fetched_entry_value.lookup_type,
                                         p_entry_value_tab(p_rows));
    --
  end if;
  --
  -- Bug # 5199669. Added to support the value sets.
  if fetched_entry_value.value_set_id is not null
  and p_entry_value_tab(p_rows) is not null then
  --
    p_entry_value_tab(p_rows) := pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				p_entry_value_tab(p_rows));
  --
  end if;
  --
end loop;
--
end get_entry_details;

--
end PAY_PAYWSLEE_PKG;

/
