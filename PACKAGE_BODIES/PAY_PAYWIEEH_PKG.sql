--------------------------------------------------------
--  DDL for Package Body PAY_PAYWIEEH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYWIEEH_PKG" as
/* $Header: paywieeh.pkb 115.1 99/07/17 05:40:01 porting ship $ */
--
--
--
--
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1994 Oracle Corporation		       |
|                          Redwood Shores, California, USA		       |
|                               All rights reserved.			       |
+==============================================================================+
Name
	Element Entry History Form Package
Purpose
	To provide information required by the PAYWIEEH form
History
--
	25 Oct 94	N Simpson	Created
40.1	24 Nov 94	R Fine          Suppressed index on business_group_id
------??-----
40.5    26 Jun 97       M.Lisiecki      Changed GET_ENTRY_VALUE_DETAILS
					cursor set_of_entry_values to improve
					performance.
115.1   23 Feb 99       J. Moyano       MLS changes
*/
--------------------------------------------------------------------------------
procedure GET_ENTRY_VALUE_DETAILS (
--
-- Returns the element entry values along with all their inherited properties
-- for each element entry selected by a query in the form
--
p_element_entry_id	number,
p_element_link_id	number,
p_effective_date	date,
p_name1			in out varchar2,
p_name2			in out varchar2,
p_name3			in out varchar2,
p_name4			in out varchar2,
p_name5			in out varchar2,
p_name6			in out varchar2,
p_name7			in out varchar2,
p_name8			in out varchar2,
p_name9			in out varchar2,
p_name10		in out varchar2,
p_name11		in out varchar2,
p_name12		in out varchar2,
p_name13		in out varchar2,
p_name14		in out varchar2,
p_name15		in out varchar2,
p_uom1			in out varchar2,
p_uom2			in out varchar2,
p_uom3			in out varchar2,
p_uom4			in out varchar2,
p_uom5			in out varchar2,
p_uom6			in out varchar2,
p_uom7			in out varchar2,
p_uom8			in out varchar2,
p_uom9			in out varchar2,
p_uom10			in out varchar2,
p_uom11			in out varchar2,
p_uom12			in out varchar2,
p_uom13			in out varchar2,
p_uom14			in out varchar2,
p_uom15			in out varchar2,
p_screen_entry_value1	in out varchar2,
p_screen_entry_value2	in out varchar2,
p_screen_entry_value3	in out varchar2,
p_screen_entry_value4	in out varchar2,
p_screen_entry_value5	in out varchar2,
p_screen_entry_value6	in out varchar2,
p_screen_entry_value7	in out varchar2,
p_screen_entry_value8	in out varchar2,
p_screen_entry_value9	in out varchar2,
p_screen_entry_value10	in out varchar2,
p_screen_entry_value11	in out varchar2,
p_screen_entry_value12	in out varchar2,
p_screen_entry_value13	in out varchar2,
p_screen_entry_value14	in out varchar2,
p_screen_entry_value15	in out varchar2) is
--
-- Bug 510150. Changed cursor's from clause to prevent it from using
-- pay_input_values_f as a driving table and prevented usage of index
-- PAY_LINK_INPUT_VALUES_F_N2 iby adding 0 to the link.input_value_id
-- column, to improve performance.26-Jun-1997.mlisieck.

cursor SET_OF_ENTRY_VALUES is
	select	type_tl.name,
		type.uom,
		decode (type.lookup_type,
			null, decode (type.hot_default_flag,
					'N', entry.screen_entry_value,
					'Y', nvl (entry.screen_entry_value, nvl (link.default_value, type.default_value))),
			hr_general.decode_lookup (type.lookup_type,
						decode (type.hot_default_flag,
							'N', entry.screen_entry_value,
							'Y', nvl (entry.screen_entry_value,
								nvl (link.default_value,
									type.default_value))))) SCREEN_ENTRY_VALUE
	from    pay_input_values_f_tl           TYPE_TL,
                pay_input_values_f              TYPE,
		pay_element_entry_values_f	ENTRY,
		pay_link_input_values_f		LINK
	where   link.element_link_id  = p_element_link_id
        and	entry.element_entry_id = p_element_entry_id
	and	link.input_value_id = entry.input_value_id + 0
	and	type.input_value_id = entry.input_value_id
	and	type_tl.input_value_id = type.input_value_id
        and     userenv('LANG') = type_tl.language
	and	p_effective_date = entry.effective_start_date
	and	entry.effective_start_date between link.effective_start_date
					and link.effective_end_date
	and	entry.effective_start_date between type.effective_start_date
					and type.effective_end_date
	order by type.display_sequence, type_tl.name;
	--
entry_value_number	integer;
--
begin
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
    p_name1			:= fetched_entry_value.name;
    p_screen_entry_value1 	:= fetched_entry_value.screen_entry_value;
      --
  elsif entry_value_number = 2 then
    --
    p_uom2			:= fetched_entry_value.uom;
    p_name2			:= fetched_entry_value.name;
    p_screen_entry_value2 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 3 then
    --
    p_uom3			:= fetched_entry_value.uom;
    p_name3			:= fetched_entry_value.name;
    p_screen_entry_value3 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 4 then
    --
    p_uom4			:= fetched_entry_value.uom;
    p_name4			:= fetched_entry_value.name;
    p_screen_entry_value4 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 5 then
    --
    p_uom5			:= fetched_entry_value.uom;
    p_name5			:= fetched_entry_value.name;
    p_screen_entry_value5 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 6 then
    --
    p_uom6			:= fetched_entry_value.uom;
    p_name6			:= fetched_entry_value.name;
    p_screen_entry_value6 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 7 then
    --
    p_uom7			:= fetched_entry_value.uom;
    p_name7			:= fetched_entry_value.name;
    p_screen_entry_value7 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 8 then
    --
    p_uom8			:= fetched_entry_value.uom;
    p_name8			:= fetched_entry_value.name;
    p_screen_entry_value8 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 9 then
    --
    p_uom9			:= fetched_entry_value.uom;
    p_name9			:= fetched_entry_value.name;
    p_screen_entry_value9 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 10 then
    --
    p_uom10			:= fetched_entry_value.uom;
    p_name10			:= fetched_entry_value.name;
    p_screen_entry_value10 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 11 then
    --
    p_uom11			:= fetched_entry_value.uom;
    p_name11			:= fetched_entry_value.name;
    p_screen_entry_value11 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 12 then
    --
    p_uom12			:= fetched_entry_value.uom;
    p_name12			:= fetched_entry_value.name;
    p_screen_entry_value12 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 13 then
    --
    p_uom13			:= fetched_entry_value.uom;
    p_name13			:= fetched_entry_value.name;
    p_screen_entry_value13 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 14 then
    --
    p_uom14			:= fetched_entry_value.uom;
    p_name14			:= fetched_entry_value.name;
    p_screen_entry_value14 	:= fetched_entry_value.screen_entry_value;
    --
  elsif entry_value_number = 15 then
    --
    p_uom15			:= fetched_entry_value.uom;
    p_name15			:= fetched_entry_value.name;
    p_screen_entry_value15 	:= fetched_entry_value.screen_entry_value;
    --
  end if;
  --
end loop;
--
end get_entry_value_details;
--------------------------------------------------------------------------------
procedure populate_context_items (
--
--******************************************************************************
-- Populate form initialisation information
--******************************************************************************
--
p_business_group_id		in number,	-- User's business group
p_cost_allocation_structure 	in out varchar2-- Keyflex structure
) is
--
-- Define how to retrieve Keyflex structure information
--
cursor keyflex_structure is
	select	cost_allocation_structure
	from	per_business_groups_perf
	where	business_group_id + 0 = p_business_group_id;
--
begin
--
-- Fetch Keyflex information
--
open keyflex_structure;
fetch keyflex_structure into p_cost_allocation_structure;
close keyflex_structure;
--
end populate_context_items;
--------------------------------------------------------------------------------
end PAY_PAYWIEEH_PKG;

/
