--------------------------------------------------------
--  DDL for Package Body PAY_PAYWSQEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYWSQEE_PKG" as
/* $Header: paywsqee.pkb 120.2.12010000.1 2008/07/27 21:57:57 appldev ship $ */
--
g_dummy	number(1);
--------------------------------------------------------------------------------
procedure GET_INPUT_VALUE_DETAILS (
--
-- Returns the input value details for the element selected by an LOV
--
p_element_type_id	number,
p_effective_date	date,
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
-- UOM
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
-- Value Set Id
p_value_set_id1  in out nocopy number,
p_value_set_id2  in out nocopy number,
p_value_set_id3  in out nocopy number,
p_value_set_id4  in out nocopy number,
p_value_set_id5  in out nocopy number,
p_value_set_id6  in out nocopy number,
p_value_set_id7  in out nocopy number,
p_value_set_id8  in out nocopy number,
p_value_set_id9  in out nocopy number,
p_value_set_id10  in out nocopy number,
p_value_set_id11  in out nocopy number,
p_value_set_id12  in out nocopy number,
p_value_set_id13  in out nocopy number,
p_value_set_id14  in out nocopy number,
p_value_set_id15  in out nocopy number
) is
--
cursor SET_OF_INPUT_VALUES is
	--
	select	iv.input_value_id,
		ivtl.name,
		iv.lookup_type,
		iv.uom,
      iv.value_set_id
		--
	from	pay_input_values_f iv,
                pay_input_values_f_tl ivtl
		--
	where	p_effective_date between iv.effective_start_date
					and iv.effective_end_date
	and	iv.element_type_id	= p_element_type_id
        and     ivtl.INPUT_VALUE_ID     = iv.INPUT_VALUE_ID
        and     ivtl.LANGUAGE           = userenv('LANG')
	order by iv.display_sequence, iv.name;
	--
input_value_number	integer;
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
-- UOM
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
-- Value Set Id
p_value_set_id1   := NULL;
p_value_set_id2   := NULL;
p_value_set_id3   := NULL;
p_value_set_id4   := NULL;
p_value_set_id5   := NULL;
p_value_set_id6   := NULL;
p_value_set_id7   := NULL;
p_value_set_id8   := NULL;
p_value_set_id9   := NULL;
p_value_set_id10  := NULL;
p_value_set_id11  := NULL;
p_value_set_id12  := NULL;
p_value_set_id13  := NULL;
p_value_set_id14  := NULL;
p_value_set_id15  := NULL;
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
  if input_value_number = 1 then
    --
    -- assign the out parameters
    --
    p_input_value_id1 	:= fetched_input_value.input_value_id;
    p_name1		:= fetched_input_value.name;
    p_lookup_type1	:= fetched_input_value.lookup_type;
    p_uom1		:= fetched_input_value.uom;
    p_value_set_id1 := fetched_input_value.value_set_id;
    --
  elsif input_value_number =2 then
--
    p_input_value_id2 	:= fetched_input_value.input_value_id;
    p_name2		:= fetched_input_value.name;
    p_lookup_type2	:= fetched_input_value.lookup_type;
    p_uom2		:= fetched_input_value.uom;
    p_value_set_id2 := fetched_input_value.value_set_id;
--
  elsif input_value_number =3 then
--
    p_input_value_id3 	:= fetched_input_value.input_value_id;
    p_name3		:= fetched_input_value.name;
    p_lookup_type3	:= fetched_input_value.lookup_type;
    p_uom3		:= fetched_input_value.uom;
    p_value_set_id3 := fetched_input_value.value_set_id;
--
  elsif input_value_number =4 then
--
    p_input_value_id4 	:= fetched_input_value.input_value_id;
    p_name4		:= fetched_input_value.name;
    p_lookup_type4	:= fetched_input_value.lookup_type;
    p_uom4		:= fetched_input_value.uom;
    p_value_set_id4 := fetched_input_value.value_set_id;
--
  elsif input_value_number =5 then
--
    p_input_value_id5 	:= fetched_input_value.input_value_id;
    p_name5		:= fetched_input_value.name;
    p_lookup_type5	:= fetched_input_value.lookup_type;
    p_uom5		:= fetched_input_value.uom;
    p_value_set_id5 := fetched_input_value.value_set_id;
--
  elsif input_value_number =6 then
--
    p_input_value_id6 	:= fetched_input_value.input_value_id;
    p_name6		:= fetched_input_value.name;
    p_lookup_type6	:= fetched_input_value.lookup_type;
    p_uom6		:= fetched_input_value.uom;
    p_value_set_id6 := fetched_input_value.value_set_id;
--
  elsif input_value_number =7 then
--
    p_input_value_id7 	:= fetched_input_value.input_value_id;
    p_name7		:= fetched_input_value.name;
    p_lookup_type7	:= fetched_input_value.lookup_type;
    p_uom7		:= fetched_input_value.uom;
    p_value_set_id7 := fetched_input_value.value_set_id;
--
  elsif input_value_number =8 then
--
    p_input_value_id8 	:= fetched_input_value.input_value_id;
    p_name8		:= fetched_input_value.name;
    p_lookup_type8	:= fetched_input_value.lookup_type;
    p_uom8		:= fetched_input_value.uom;
    p_value_set_id8 := fetched_input_value.value_set_id;
--
  elsif input_value_number =9 then
--
    p_input_value_id9 	:= fetched_input_value.input_value_id;
    p_name9		:= fetched_input_value.name;
    p_lookup_type9	:= fetched_input_value.lookup_type;
    p_uom9		:= fetched_input_value.uom;
    p_value_set_id9 := fetched_input_value.value_set_id;
--
  elsif input_value_number =10 then
--
    p_input_value_id10 		:= fetched_input_value.input_value_id;
    p_name10			:= fetched_input_value.name;
    p_lookup_type10		:= fetched_input_value.lookup_type;
    p_uom10			:= fetched_input_value.uom;
    p_value_set_id10 := fetched_input_value.value_set_id;
--
  elsif input_value_number =11 then
--
    p_input_value_id11 		:= fetched_input_value.input_value_id;
    p_name11			:= fetched_input_value.name;
    p_lookup_type11		:= fetched_input_value.lookup_type;
    p_uom11			:= fetched_input_value.uom;
    p_value_set_id11 := fetched_input_value.value_set_id;
--
  elsif input_value_number =12 then
--
    p_input_value_id12 		:= fetched_input_value.input_value_id;
    p_name12			:= fetched_input_value.name;
    p_lookup_type12		:= fetched_input_value.lookup_type;
    p_uom12			:= fetched_input_value.uom;
    p_value_set_id12 := fetched_input_value.value_set_id;
--
  elsif input_value_number =13 then
--
    p_input_value_id13 		:= fetched_input_value.input_value_id;
    p_name13			:= fetched_input_value.name;
    p_lookup_type13		:= fetched_input_value.lookup_type;
    p_uom13			:= fetched_input_value.uom;
    p_value_set_id13 := fetched_input_value.value_set_id;
--
  elsif input_value_number =14 then
--
    p_input_value_id14 		:= fetched_input_value.input_value_id;
    p_name14			:= fetched_input_value.name;
    p_lookup_type14		:= fetched_input_value.lookup_type;
    p_uom14			:= fetched_input_value.uom;
    p_value_set_id14 := fetched_input_value.value_set_id;
--
  elsif input_value_number =15 then
--
    p_input_value_id15 		:= fetched_input_value.input_value_id;
    p_name15			:= fetched_input_value.name;
    p_lookup_type15		:= fetched_input_value.lookup_type;
    p_uom15			:= fetched_input_value.uom;
    p_value_set_id15 := fetched_input_value.value_set_id;
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
procedure GET_INPUT_VALUE_DETAILS (
--
-- Returns the input value details for the element selected by an LOV
--
p_element_type_id	number,
p_effective_date	date,
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
p_lookup_type15		in out nocopy varchar2
) is
--
cursor SET_OF_INPUT_VALUES is
	--
	select	iv.input_value_id,
		ivtl.name,
		iv.lookup_type,
		iv.uom
		--
	from	pay_input_values_f iv,
                pay_input_values_f_tl ivtl
		--
	where	p_effective_date between iv.effective_start_date
					and iv.effective_end_date
	and	iv.element_type_id	= p_element_type_id
        and     ivtl.INPUT_VALUE_ID     = iv.INPUT_VALUE_ID
        and     ivtl.LANGUAGE           = userenv('LANG')
	order by iv.display_sequence, iv.name;
	--
input_value_number	integer;
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
  if input_value_number = 1 then
    --
    -- assign the out parameters
    --
    p_input_value_id1 	:= fetched_input_value.input_value_id;
    p_name1		:= fetched_input_value.name;
    p_lookup_type1	:= fetched_input_value.lookup_type;
    --
  elsif input_value_number =2 then
--
    p_input_value_id2 	:= fetched_input_value.input_value_id;
    p_name2		:= fetched_input_value.name;
    p_lookup_type2	:= fetched_input_value.lookup_type;
--
  elsif input_value_number =3 then
--
    p_input_value_id3 	:= fetched_input_value.input_value_id;
    p_name3		:= fetched_input_value.name;
    p_lookup_type3	:= fetched_input_value.lookup_type;

--
  elsif input_value_number =4 then
--
    p_input_value_id4 	:= fetched_input_value.input_value_id;
    p_name4		:= fetched_input_value.name;
    p_lookup_type4	:= fetched_input_value.lookup_type;
--
  elsif input_value_number =5 then
--
    p_input_value_id5 	:= fetched_input_value.input_value_id;
    p_name5		:= fetched_input_value.name;
    p_lookup_type5	:= fetched_input_value.lookup_type;
--
  elsif input_value_number =6 then
--
    p_input_value_id6 	:= fetched_input_value.input_value_id;
    p_name6		:= fetched_input_value.name;
    p_lookup_type6	:= fetched_input_value.lookup_type;
--
  elsif input_value_number =7 then
--
    p_input_value_id7 	:= fetched_input_value.input_value_id;
    p_name7		:= fetched_input_value.name;
    p_lookup_type7	:= fetched_input_value.lookup_type;
--
  elsif input_value_number =8 then
--
    p_input_value_id8 	:= fetched_input_value.input_value_id;
    p_name8		:= fetched_input_value.name;
    p_lookup_type8	:= fetched_input_value.lookup_type;
--
  elsif input_value_number =9 then
--
    p_input_value_id9 	:= fetched_input_value.input_value_id;
    p_name9		:= fetched_input_value.name;
    p_lookup_type9	:= fetched_input_value.lookup_type;
--
  elsif input_value_number =10 then
--
    p_input_value_id10 		:= fetched_input_value.input_value_id;
    p_name10			:= fetched_input_value.name;
    p_lookup_type10		:= fetched_input_value.lookup_type;
--
  elsif input_value_number =11 then
--
    p_input_value_id11 		:= fetched_input_value.input_value_id;
    p_name11			:= fetched_input_value.name;
    p_lookup_type11		:= fetched_input_value.lookup_type;
--
  elsif input_value_number =12 then
--
    p_input_value_id12 		:= fetched_input_value.input_value_id;
    p_name12			:= fetched_input_value.name;
    p_lookup_type12		:= fetched_input_value.lookup_type;
--
  elsif input_value_number =13 then
--
    p_input_value_id13 		:= fetched_input_value.input_value_id;
    p_name13			:= fetched_input_value.name;
    p_lookup_type13		:= fetched_input_value.lookup_type;
--
  elsif input_value_number =14 then
--
    p_input_value_id14 		:= fetched_input_value.input_value_id;
    p_name14			:= fetched_input_value.name;
    p_lookup_type14		:= fetched_input_value.lookup_type;
--
  elsif input_value_number =15 then
--
    p_input_value_id15 		:= fetched_input_value.input_value_id;
    p_name15			:= fetched_input_value.name;
    p_lookup_type15		:= fetched_input_value.lookup_type;
--
    exit; -- stop looping after the fifteenth input value
--
  end if;
--
end loop;
--
end get_input_value_details;

----------
function paylink_request_id (
--
-- Starts paylink process via concurrent manager
-- Returns TRUE if the request was successfully submitted
--
	p_business_group_id	 number,
        p_mode                   varchar2,
	p_batch_id		 number,
        p_wait                   varchar2 default 'N',
        p_act_parameter_group_id number   default null) return number is
--
v_request_id	number := 0;
v_pac_id        pay_payroll_actions.payroll_action_id%TYPE;
v_batch_status  pay_batch_headers.batch_status%TYPE := null;
--
l_wait_outcome BOOLEAN;
l_phase        VARCHAR2(80);
l_status       VARCHAR2(80);
l_dev_phase    VARCHAR2(80);
l_dev_status   VARCHAR2(80);
l_message      VARCHAR2(80);
l_max_wait_sec       number;
l_interval_wait_sec  number;
l_default_parameter_group_id number(9);
--

cursor csr_pay_acts is
  select pac.payroll_action_id
    from pay_payroll_actions pac
   where pac.action_type = 'BEE'
     and pac.batch_id = p_batch_id
     and pac.batch_process_mode = 'TRANSFER'
   order by pac.payroll_action_id;
--
--
cursor cur_max is
  select fnd_number.canonical_to_number(parameter_value)
    from pay_action_parameters
   where parameter_name = 'BEE_MAX_WAIT_SEC';
--
cursor cur_intw is
  select fnd_number.canonical_to_number(parameter_value)
    from pay_action_parameters
   where parameter_name = 'BEE_INTERVAL_WAIT_SEC';
--
--
  function get_default_action_param
   return VARCHAR2 is

      Cursor csr_get_parameter_id(r_action_parameter_group_name varchar2) is
       select to_char(action_parameter_group_id)
        from  pay_action_parameter_groups
       where  action_parameter_group_name=r_action_parameter_group_name;

      Cursor csr_get_cp_defaults is
         select default_type,default_value
           from FND_DESCR_FLEX_COLUMN_USAGES
          where descriptive_flexfield_name='$SRS$.PAYLINK'
            and end_user_column_name='Action Parameter Group';
      l_cp_defaults csr_get_cp_defaults%rowtype;
      l_return      varchar2(2000);

   begin
      open  csr_get_cp_defaults;
      fetch csr_get_cp_defaults into l_cp_defaults;
      close csr_get_cp_defaults;

      if l_cp_defaults.default_type = 'S'
         and instr(l_cp_defaults.default_value,':') < 1
      then  --instr to ignore defaults with block references

          execute immediate l_cp_defaults.default_value into l_return;

      elsif l_cp_defaults.default_type='C' then

          open  csr_get_parameter_id(l_cp_defaults.default_value);
          fetch csr_get_parameter_id into l_return;
          close csr_get_parameter_id;

      elsif l_cp_defaults.default_type = 'P' then

           l_return := fnd_profile.value(l_cp_defaults.default_value);

      end if;

     --if there is an error or default type is not in S,C,P return null value
     --,so that action parameter group is picked from profile

       return to_number(l_return);

   exception
      when others then --ignore errors and  pick up from profile
           return null;
   end;
begin
--
v_batch_status := batch_overall_status(p_batch_id);
--
-- IF the batch is already transferred then only allow purge.
-- IF the batch is partially transferred then allow transfer and purge.
-- IF the batch has status mismatch then don't submit anything.
if (v_batch_status = 'ST' and p_mode in ('VALIDATE')) or
   (v_batch_status = 'T' and p_mode in ('VALIDATE','TRANSFER')) or
   (v_batch_status = 'P') or
   (v_batch_status = 'SM') then
   return (null);
end if;
--
open csr_pay_acts;
fetch csr_pay_acts into v_pac_id;
close csr_pay_acts;
--
if p_mode = 'PURGE' then
--
v_request_id :=  fnd_request.submit_request (
--
        'PER',
        'PAYLINK(PURGE)',
        null,
        null,
        null,
        p_business_group_id,
        'PURGE',
        p_batch_id);
--
elsif p_mode = 'ROLLBACK' and v_pac_id is not null then
v_request_id :=  fnd_request.submit_request (
--
        'PAY',
        'ROLLBACK',
        null,
        null,
        null,
        'ROLLBACK',
        v_pac_id,
        null);
--
elsif p_mode = 'TRANSFER' and v_pac_id is not null then
v_request_id :=  fnd_request.submit_request (
--
        'PAY',
        'RETRY',
        null,
        null,
        null,
        'RERUN',
        v_pac_id);
else

 --5718633 115.27 try to pick action_parameter_group from
 --the default value attached to Action Parameter Group in BEE CP

 l_default_parameter_group_id := get_default_action_param;

 if l_default_parameter_group_id is null
 then
     l_default_parameter_group_id := p_act_parameter_group_id ;
 end if;
v_request_id :=  fnd_request.submit_request (
--
	'PER',
	'PAYLINK',
	null,
	null,
	null,
	'BATCHEE',
	p_mode,
	p_batch_id,
        l_default_parameter_group_id);
end if;

if ( v_request_id <> 0 ) then
  commit;
end if;
--
if p_wait = 'Y' and v_request_id <> 0 then
  -- Attempt to find out the BEE Concurrent manager max wait time
  -- and polling interval time from pay_action_parameters. If values
  -- cannot be found in this table then default to a max wait of 600
  -- seconds and polling interval of 2 seconds.
  --
  open cur_max;
  fetch cur_max into l_max_wait_sec;
  if cur_max %notfound then
    close cur_max;
    -- Value not in table, set to the default
    l_max_wait_sec := 600;
  else
    close cur_max;
  end if;
  --
  open cur_intw;
  fetch cur_intw into l_interval_wait_sec;
  if cur_intw %notfound then
    close cur_intw;
    -- Value not in table, set to the default
    l_interval_wait_sec := 2;
  else
    close cur_intw;
  end if;
  --
  -- Waits for request to finish on the concurrent manager.
  -- Or gives up if the maximum wait time is reached.
  --
  l_wait_outcome := fnd_concurrent.wait_for_request(
                           request_id => v_request_id,
                           interval   => l_interval_wait_sec,
                           max_wait   => l_max_wait_sec,
                           phase      => l_phase,
                           status     => l_status,
                           dev_phase  => l_dev_phase,
                           dev_status => l_dev_status,
                           message    => l_message);
end if;
--
return (v_request_id);
--
end paylink_request_id;
--------------------------------------------------------------------------------
function next_batch_sequence (p_batch_id number) return number is
--
-- Returns the next available batch sequence
-- to maintain a sequence of batch lines within a particular batch
--
v_batch_sequence	number := null;
--
cursor csr_next_batch_sequence is
	select	nvl (max (batch_sequence), 0) +1
	from	pay_batch_lines
	where	batch_id = p_batch_id;
	--
begin
--
open csr_next_batch_sequence;
fetch csr_next_batch_sequence into v_batch_sequence;
close csr_next_batch_sequence;
--
return v_batch_sequence;
--
end next_batch_sequence;
--------------------------------------------------------------------------------
function batch_overall_status (p_batch_id number) return varchar2 is
--
-- Derives the overall status of the batch header, control totals and lines
--
valid_lines_exist	boolean := FALSE;
error_lines_exist	boolean := FALSE;
unprocessed_lines_exist	boolean := FALSE;
transferred_lines_exist	boolean := FALSE;
header_transferred      boolean := FALSE;
header_processing       boolean := FALSE;
--
cursor csr_status is
	select	control_status STATUS
	from	pay_batch_control_totals
	where	batch_id = p_batch_id
	union
	select	batch_line_status
	from	pay_batch_lines
	where	batch_id = p_batch_id
	union
	select	batch_status
	from	pay_batch_headers
	where	batch_id = p_batch_id
        union
        select  'Y'
        from    pay_batch_headers bth
        where   bth.batch_id = p_batch_id
        and     bth.batch_status = 'T'
        -- and     not exists
        --         (select null
        --          from   pay_batch_control_totals ctl
        --          where ctl.batch_id = bth.batch_id
        --          and   ctl.control_status <> 'T')
        order by 1 desc;
        --
begin
--
for distinct_status in csr_status LOOP
  --
  if distinct_status.status = 'E' then
    error_lines_exist := TRUE;
    exit; -- we do not need to know the rest
    --
  elsif distinct_status.status = 'U' then
    unprocessed_lines_exist := TRUE;
    --
  elsif distinct_status.status = 'T' then
    transferred_lines_exist := TRUE;
    --
  elsif distinct_status.status = 'V' then
    valid_lines_exist := TRUE;
    --
  elsif distinct_status.status = 'Y' then
    header_transferred := TRUE;
    --
  elsif distinct_status.status = 'P' then
    header_processing := TRUE;
    --
  end if;
  --
  -- we do not need to know the rest if it is the following case.
  if (header_transferred and
      (unprocessed_lines_exist or valid_lines_exist or error_lines_exist))
     or (not header_transferred and error_lines_exist) then
     --
     exit;
     --
  end if;
--
end loop;
--
if header_processing then
  return 'P'; -- batch is currently under process.
elsif header_transferred
        and NOT unprocessed_lines_exist
        and NOT valid_lines_exist
        and NOT error_lines_exist then
  return 'T'; -- all lines (if exists) has been transferred.
elsif header_transferred then
  return 'ST'; -- some lines might not have transferred.
elsif error_lines_exist then
  return 'E'; -- there is at least one error line
elsif unprocessed_lines_exist
        and NOT transferred_lines_exist then
  return 'U'; -- there is at least one unprocessed line
elsif valid_lines_exist
	and NOT transferred_lines_exist
	and NOT unprocessed_lines_exist then
  return 'V'; -- all lines are valid
-- elsif transferred_lines_exist
--      and NOT valid_lines_exist
--  return 'T'; -- all lines are transferred
else
  return 'SM'; -- mismatch of statuses
end if;
--
end batch_overall_status;
--------------------------------------------------------------------------------
procedure get_batch_element_type (
	--
	p_batch_id			number,
	p_element_type_id		in out nocopy number,
	p_element_name			in out nocopy varchar2) is
	--
cursor csr_element is
select  distinct elt.element_type_id, elt.element_name
        from    pay_element_types_f     ELT,
                pay_batch_lines         LINE
        where line.batch_id = p_batch_id and
              line.element_type_id is not null and
              line.element_type_id = elt.element_type_id
union
select  distinct elt.element_type_id, elt.element_name
        from    pay_element_types_f     ELT,
                pay_batch_lines         LINE
        where line.batch_id = p_batch_id and
              line.element_type_id is null and
              upper (line.element_name) = upper(elt.element_name);
	--
begin
--
open csr_element;
fetch csr_element into p_element_type_id, p_element_name;
close csr_element;
--
end get_batch_element_type;
--------------------------------------------------------------------------------
function assignment_number (p_assignment_id number) return varchar2 is
--
-- Returns the assignment number for the assignment id passed in
--
cursor csr_asgt_no is
	select	distinct assignment_number
	from	per_assignments_f2
	where	assignment_id = p_assignment_id;
	--
v_asgt_no	varchar2(80);
--
begin
--
open csr_asgt_no;
fetch csr_asgt_no into v_asgt_no;
close csr_asgt_no;
--
return v_asgt_no;
--
end assignment_number;
--------------------------------------------------------------------------------
procedure populate_context_items (
--
--******************************************************************************
-- Populate form initialisation information
--******************************************************************************
--
p_business_group_id		in number,	       -- User's business group
p_cost_allocation_structure 	in out nocopy varchar2 -- Keyflex structure
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
procedure check_name_uniqueness (
--
-- Check that the batch name is unique within business group
--
p_business_group_id	number,
p_batch_name		varchar2,
p_batch_id		number) is
--
cursor csr_name is
	select	1
	from	pay_batch_headers
	where	(batch_id <> p_batch_id or p_batch_id is null)
	and	business_group_id = p_business_group_id
	and	upper (batch_name) = upper (p_batch_name);
	--
begin
--
open csr_name;
fetch csr_name into g_dummy;
--
if csr_name%found then
  close csr_name;
  fnd_message.set_name ('PAY', 'HR_BATCH_NAME_CLASH');
  fnd_message.raise_error;
else
  close csr_name;
end if;
--
end check_name_uniqueness;
--------------------------------------------------------------------------------
function create_batches_request_id (
--
-- Starts create_batches process via concurrent manager
-- Returns TRUE if the request was successfully submitted
--
p_header_name                varchar2,
p_header_id                  number,
p_reason                     varchar2,
p_business_group_id          number,
p_effective_start_date       date,
p_effective_s_date       date,
p_effective_e_date       date,
p_element_type_id            number,
p_payroll_id                 number,
p_assignment_set_id          number,
p_cost_allocation_keyflex_id number,
p_mix_transfer_flag          varchar2,
p_value_1                    varchar2,
p_value_2                    varchar2,
p_value_3                    varchar2,
p_value_4                    varchar2,
p_value_5                    varchar2,
p_value_6                    varchar2,
p_value_7                    varchar2,
p_value_8                    varchar2,
p_value_9                    varchar2,
p_value_10                   varchar2,
p_value_11                   varchar2,
p_value_12                   varchar2,
p_value_13                   varchar2,
p_value_14                   varchar2,
p_value_15                   varchar2,
p_attribute_category         varchar2,
p_attribute1                 varchar2,
p_attribute2                 varchar2,
p_attribute3                 varchar2,
p_attribute4                 varchar2,
p_attribute5                 varchar2,
p_attribute6                 varchar2,
p_attribute7                 varchar2,
p_attribute8                 varchar2,
p_attribute9                 varchar2,
p_attribute10                varchar2,
p_attribute11                varchar2,
p_attribute12                varchar2,
p_attribute13                varchar2,
p_attribute14                varchar2,
p_attribute15                varchar2,
p_attribute16                varchar2,
p_attribute17                varchar2,
p_attribute18                varchar2,
p_attribute19                varchar2,
p_attribute20                varchar2,
p_entry_information_category varchar2,
p_entry_information1         varchar2,
p_entry_information2         varchar2,
p_entry_information3         varchar2,
p_entry_information4         varchar2,
p_entry_information5         varchar2,
p_entry_information6         varchar2,
p_entry_information7         varchar2,
p_entry_information8         varchar2,
p_entry_information9         varchar2,
p_entry_information10        varchar2,
p_entry_information11        varchar2,
p_entry_information12        varchar2,
p_entry_information13        varchar2,
p_entry_information14        varchar2,
p_entry_information15        varchar2,
p_entry_information16        varchar2,
p_entry_information17        varchar2,
p_entry_information18        varchar2,
p_entry_information19        varchar2,
p_entry_information20        varchar2,
p_entry_information21        varchar2,
p_entry_information22        varchar2,
p_entry_information23        varchar2,
p_entry_information24        varchar2,
p_entry_information25        varchar2,
p_entry_information26        varchar2,
p_entry_information27        varchar2,
p_entry_information28        varchar2,
p_entry_information29        varchar2,
p_entry_information30        varchar2,
p_date_earned                date,
p_subpriority                number,
p_element_set_id	     number default null,
p_customized_restriction_id  number default null,
p_act_parameter_group_id     number default null
)
return number is
--
  v_request_id	number := 0;
--
begin
  --
  v_request_id :=  fnd_request.submit_request(
                               'PAY',
	                       'PYCBTC',
                               null,
	                       null,
            	               null,
	                       p_business_group_id,
                               fnd_date.date_to_canonical(p_effective_start_date),
                               p_element_type_id,
                               p_payroll_id,
                               p_assignment_set_id,
                               p_cost_allocation_keyflex_id,
                               p_mix_transfer_flag,
			       p_value_1,
                               p_value_2,
                               p_value_3,
                               p_value_4,
                               p_value_5,
                               p_value_6,
                               p_value_7,
                               p_value_8,
                               p_value_9,
                               p_value_10,
                               p_value_11,
                               p_value_12,
                               p_value_13,
                               p_value_14,
                               p_value_15,
                               p_attribute_category,
                               p_attribute1,
                               p_attribute2,
                               p_attribute3,
                               p_attribute4,
                               p_attribute5,
                               p_attribute6,
                               p_attribute7,
                               p_attribute8,
                               p_attribute9,
                               p_attribute10,
                               p_attribute11,
                               p_attribute12,
                               p_attribute13,
                               p_attribute14,
                               p_attribute15,
                               p_attribute16,
                               p_attribute17,
                               p_attribute18,
                               p_attribute19,
                               p_attribute20,
			       p_header_name,
			       p_header_id,
			       p_reason,
                               fnd_date.date_to_canonical(p_effective_s_date),
                               fnd_date.date_to_canonical(p_effective_e_date),
                               fnd_date.date_to_canonical(p_date_earned),
                               null,
                               p_subpriority,
                               p_entry_information_category,
                               p_entry_information1,
                               p_entry_information2,
                               p_entry_information3,
                               p_entry_information4,
                               p_entry_information5,
                               p_entry_information6,
                               p_entry_information7,
                               p_entry_information8,
                               p_entry_information9,
                               p_entry_information10,
                               p_entry_information11,
                               p_entry_information12,
                               p_entry_information13,
                               p_entry_information14,
                               p_entry_information15,
                               p_entry_information16,
                               p_entry_information17,
                               p_entry_information18,
                               p_entry_information19,
                               p_entry_information20,
                               p_entry_information21,
                               p_entry_information22,
                               p_entry_information23,
                               p_entry_information24,
                               p_entry_information25,
                               p_entry_information26,
                               p_entry_information27,
                               p_entry_information28,
                               p_entry_information29,
                               p_entry_information30,
                               p_element_set_id,
                               p_customized_restriction_id,
                               p_act_parameter_group_id
	                      );
if ( v_request_id <> 0 ) then
  commit;
end if;
--
return (v_request_id);
--
end create_batches_request_id;
--------------------------------------------------------------------------------
--
function convert_internal_to_display
  (p_element_type_id               in     varchar2,
   p_input_value                   in     varchar2,
   p_input_value_number            in     number,
   p_session_date                  in     date,
   p_batch_id                      in     number
  ) return varchar2 is
--
   --
   l_bee_iv_upgrade  varchar2(1);
   --
   l_display_value   varchar2(80) := p_input_value;
   l_internal_value  varchar2(80) := p_input_value;
   l_dummy           varchar2(100);
   --
   l_uom_value       pay_input_values_f.UOM%TYPE;
   l_lookup_type     pay_input_values_f.LOOKUP_TYPE%TYPE;
   l_value_set_id    pay_input_values_f.VALUE_SET_ID%TYPE;
   l_currency_code   pay_element_types_f.input_currency_code%TYPE;
   l_count           number;
   l_found           number;
   --
   cursor csr_valid_lookup
          (p_lookup_type varchar2,
           p_lookup_code varchar2) is
       select HL.meaning
         from hr_lookups HL
        where HL.lookup_type = p_lookup_type
          and HL.lookup_code = p_lookup_code;
   --
   cursor csr_iv is
       select inv.UOM,
              inv.LOOKUP_TYPE,
              inv.VALUE_SET_ID,
              etp.input_currency_code
       from   pay_input_values_f  inv,
              pay_element_types_f etp
       where  inv.element_type_id   = p_element_type_id
       and    etp.element_type_id   = p_element_type_id
       and    p_session_date between inv.effective_start_date
                               and     inv.effective_end_date
       and    p_session_date between etp.effective_start_date
                               and     etp.effective_end_date
       order by inv.display_sequence
       ,        inv.name;
--
   cursor csr_bg_id is
      select bth.business_group_id
        from pay_batch_headers bth
       where bth.batch_id = p_batch_id;
   --
   l_business_group_id pay_batch_headers.business_group_id%TYPE;
begin
--
   begin
      --
      open csr_bg_id;
      fetch csr_bg_id into l_business_group_id;
      close csr_bg_id;
      --
      pay_core_utils.get_upgrade_status(l_business_group_id,'BEE_IV_UPG',l_bee_iv_upgrade);
      --
   exception
      when others then
         l_bee_iv_upgrade := 'E';
   end;
--
   --
   -- Check whether the upgrade process is in progress.
   --
   if l_bee_iv_upgrade = 'E' then
      hr_utility.set_message(800, 'HR_449106_BEE_UPGRADING');
      hr_utility.raise_error;
   end if;
--
--
   if p_input_value is null then
      return p_input_value;
   end if;
--
   l_count := 1;
   l_found := 0;
   for p_iv_rec in csr_iv loop
       --
       if l_count = p_input_value_number then
          l_uom_value       := p_iv_rec.uom;
          l_lookup_type     := p_iv_rec.LOOKUP_TYPE;
          l_value_set_id    := p_iv_rec.VALUE_SET_ID;
          l_currency_code   := p_iv_rec.input_currency_code;
          --
          l_found := 1;
          exit;
       end if;
       --
       l_count := l_count + 1;
       --
   end loop;
--
   if l_found = 0 then
      return p_input_value;
   end if;
--
--
   if l_bee_iv_upgrade = 'N' then
      --
      -- BEE now handles input value of date in canonical format.
      -- However the EE API expects the data in the DD-MON-YYYY format.
      -- The DD-MON-YYYY is the default format of the fnd_date.
      --
      if l_uom_value = 'D' then
         begin
            l_display_value :=   fnd_date.date_to_displaydate(
                                            fnd_date.canonical_to_date(p_input_value));
         exception
            when others then
                 raise;
         end;
      else
         l_display_value := p_input_value;
      end if;
      --
   else
      --
      if (l_lookup_type is not null and
          l_internal_value is not null) then
         --
         open csr_valid_lookup(l_lookup_type, l_internal_value);
         fetch csr_valid_lookup into l_display_value ;
         close csr_valid_lookup;
         --
      elsif (l_value_set_id is not null and
             l_internal_value is not null) then
         --
         l_display_value := pay_input_values_pkg.decode_vset_value(
                              l_value_set_id, l_internal_value);
         --
      else
         --
         hr_chkfmt.changeformat (
            l_internal_value, 		/* the value to be formatted (out - display) */
            l_display_value, 	/* the formatted value on output (out - canonical) */
            l_uom_value,			/* the format to check */
            l_currency_code );
         --
      end if;
      --
   end if;
   --
   return l_display_value;
--
exception
   when others then
      hr_utility.set_message ('PAY','PAY_6306_INPUT_VALUE_FORMAT');
      hr_utility.set_message_token ('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', l_uom_value ));
      hr_utility.raise_error;
--
end convert_internal_to_display;
--
end PAY_PAYWSQEE_PKG;

/
