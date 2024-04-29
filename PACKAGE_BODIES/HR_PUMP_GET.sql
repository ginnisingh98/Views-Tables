--------------------------------------------------------
--  DDL for Package Body HR_PUMP_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PUMP_GET" as
/* $Header: hrdpget.pkb 120.1 2005/07/08 20:10:10 ssattini noship $ */
/*
  NOTES
    Please refer to the package header for documentation on these
    functions.
*/
/*---------------------------------------------------------------------------*/
/*----------------------- constant definitions ------------------------------*/
/*---------------------------------------------------------------------------*/
END_OF_TIME   constant date := to_date('4712/12/31', 'YYYY/MM/DD');
START_OF_TIME constant date := to_date('0001/01/01', 'YYYY/MM/DD');
HR_API_G_VARCHAR2 constant varchar2(128) := hr_api.g_varchar2;
HR_API_G_NUMBER constant number := hr_api.g_number;
HR_API_G_DATE constant date := hr_api.g_date;

/*---------------------------------------------------------------------------*/
/*------------- internal Get ID functions data structures -------------------*/
/*---------------------------------------------------------------------------*/

------------------------------ user_key_to_id ----------------------------------
/*
  NAME
    user_key_to_id
  DESCRIPTION
    Returns an ID value from hr_pump_batch_line_user_keys alone.
  NOTES
    Utility function to get _ID functions.
*/
function user_key_to_id( p_user_key_value in varchar2 )
return number is
   l_id number;
begin
   select unique_key_id
   into   l_id
   from   hr_pump_batch_line_user_keys
   where  user_key_value = p_user_key_value;
   return(l_id);
end user_key_to_id;

/*---------------------------------------------------------------------------*/
/*----------------------- Get ID function globals ---------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*------------------ local functions and procedures -------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*----------------------------- get id functions ----------------------------*/
/*---------------------------------------------------------------------------*/

/* returns a position definition id  */
function get_position_definition_id
(
   p_position_name     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number is
   l_position_definition_id number;
begin
   return(l_position_definition_id);
exception
when others then
   hr_data_pump.fail('get_position_definition_id', sqlerrm, p_position_name,
                     p_business_group_id, p_effective_date);
   raise;
end get_position_definition_id;
/*--------------------- get_collective_agreement_id ------------------------*/
function get_collective_agreement_id
(p_business_group_id in number
,p_cagr_name         in varchar2
,p_effective_date    in date
) return number is
  l_collective_agreement_id number;
begin
  select pc.collective_agreement_id
  into   l_collective_agreement_id
  from   per_collective_agreements pc
  where  pc.business_group_id = p_business_group_id
  and    pc.name = p_cagr_name
  and    p_effective_date between
         nvl(start_date,START_OF_TIME) and nvl(end_date,END_OF_TIME);
  return l_collective_agreement_id;
exception
  when others then
    hr_data_pump.fail('get_collective_agreement_id', sqlerrm,
                      p_business_group_id, p_cagr_name, p_effective_date);
    raise;
end get_collective_agreement_id;

/*------------------------------ get_contract_id ---------------------------*/
function get_contract_id
(p_contract_user_key in varchar2
) return number is
  l_contract_id number;
begin
   l_contract_id := user_key_to_id( p_contract_user_key );
   return(l_contract_id);
exception
  when others then
    hr_data_pump.fail('get_contract_id', sqlerrm, p_contract_user_key);
    raise;
end get_contract_id;

/*---------------------------- get_establishment_id ---------------------------*/
function get_establishment_id
(p_establishment_name in varchar2
,p_location           in varchar2
) return number is
  l_establishment_id number;
begin
  select pe.establishment_id
  into   l_establishment_id
  from   per_establishments pe
  where  pe.location = p_location
  and    pe.name = p_establishment_name;
  return l_establishment_id;
exception
  when others then
    hr_data_pump.fail('get_establishment_id', sqlerrm,
                       p_establishment_name, p_location);
    raise;
end get_establishment_id;

/*------------------------- get_cagr_id_flex_num ------------------------------*/
function get_cagr_id_flex_num
(p_cagr_id_flex_num_user_key varchar2
) return number is
   l_cagr_id_flex_num number;
begin
   l_cagr_id_flex_num := user_key_to_id( p_cagr_id_flex_num_user_key );
   return(l_cagr_id_flex_num);
exception
when others then
   hr_data_pump.fail('get_cagr_id_flex_num', sqlerrm, p_cagr_id_flex_num_user_key);
   raise;
end get_cagr_id_flex_num;

/* get element_entry_id - requires user key */
function get_element_entry_id
(
   p_element_entry_user_key in varchar2
) return number is
   l_element_entry_id number;
begin
   l_element_entry_id := user_key_to_id( p_element_entry_user_key );
   return(l_element_entry_id);
exception
when others then
   hr_data_pump.fail('get_element_entry_id', sqlerrm, p_element_entry_user_key);
   raise;
end get_element_entry_id;

/* get original element_entry_id - requires user key */
function get_original_entry_id
(
   p_original_entry_user_key in varchar2
) return number is
   l_original_entry_id number;
begin
   l_original_entry_id := get_element_entry_id( p_original_entry_user_key );
   return(l_original_entry_id);
exception
when others then
   hr_data_pump.fail('get_original_entry_id', sqlerrm,
                     p_original_entry_user_key);
   raise;
end get_original_entry_id;

/* get target element_entry_id - requires user key */
function get_target_entry_id
(
   p_target_entry_user_key in varchar2
) return number is
   l_target_entry_id number;
begin
   l_target_entry_id := get_element_entry_id( p_target_entry_user_key );
   return(l_target_entry_id);
exception
when others then
   hr_data_pump.fail('get_target_entry_id', sqlerrm, p_target_entry_user_key);
   raise;
end get_target_entry_id;

/* get_element_link_id - requires user key */
function get_element_link_id
(
   p_element_link_user_key in varchar2
) return number is
   l_element_link_id number;
begin
   l_element_link_id := user_key_to_id( p_element_link_user_key );
   return(l_element_link_id);
exception
when others then
   hr_data_pump.fail('get_element_link_id', sqlerrm, p_element_link_user_key);
   raise;
end get_element_link_id;

/* get_cost_allocation_key_flex_id - requires user key */
function get_cost_allocation_keyflex_id
(
   p_cost_alloc_keyflex_user_key in varchar2
) return number is
   l_cost_allocation_keyflex_id number;
begin
   l_cost_allocation_keyflex_id :=
   user_key_to_id( p_cost_alloc_keyflex_user_key );
   return(l_cost_allocation_keyflex_id);
exception
when others then
   hr_data_pump.fail('get_cost_allocation_keyflex_id', sqlerrm,
                     p_cost_alloc_keyflex_user_key);
   raise;
end get_cost_allocation_keyflex_id;

/* get_comment_id - requires user key */
function get_comment_id( p_comment_user_key in varchar2 )
return number is
   l_comment_id number;
begin
   l_comment_id := user_key_to_id( p_comment_user_key );
   return(l_comment_id);
exception
when others then
   hr_data_pump.fail('get_comment_id', sqlerrm, p_comment_user_key);
   raise;
end get_comment_id;

/* get_assignment_action_id - requires user key */
function get_assignment_action_id( p_assignment_action_user_key in varchar2 )
return number is
   l_assignment_action_id number;
begin
   l_assignment_action_id := user_key_to_id( p_assignment_action_user_key );
   return(l_assignment_action_id);
exception
when others then
   hr_data_pump.fail('get_assignment_action_id', sqlerrm,
                     p_assignment_action_user_key);
   raise;
end get_assignment_action_id;

/* get updating assignment_action_id - requires user key */
function get_updating_action_id( p_updating_action_user_key in varchar2 )
return number is
   l_updating_action_id number;
begin
   l_updating_action_id :=
   get_assignment_action_id( p_updating_action_user_key );
   return(l_updating_action_id);
exception
when others then
   hr_data_pump.fail('get_updating_action_id', sqlerrm,
                     p_updating_action_user_key);
   raise;
end get_updating_action_id;

/* get_input_value_id */
function get_input_value_id
(
   p_input_value_name  in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id number;
begin
   select piv.input_value_id
   into   l_input_value_id
   from   pay_input_values_f_tl pivtl,
          pay_input_values_f piv,
          pay_element_types_f pet,
          pay_element_types_f_tl pettl,
          per_business_groups pbg
   where  pbg.business_group_id = p_business_group_id
   and    pettl.element_name = p_element_name
   and    pettl.language = p_language_code
   and    pet.element_type_id = pettl.element_type_id
   and    p_effective_date between
          pet.effective_start_date and pet.effective_end_date
   and
   (
      (pet.business_group_id is null and pet.legislation_code is null) or
      (pet.business_group_id is null
       and pet.legislation_code = pbg.legislation_code) or
      (pet.legislation_code is null
       and pet.business_group_id = p_business_group_id)
   )
   and    piv.element_type_id = pet.element_type_id
   and    p_effective_date between
          piv.effective_start_date and piv.effective_end_date
   and pivtl.input_value_id = piv.input_value_id
   and pivtl.name = p_input_value_name
   and pivtl.LANGUAGE = p_language_code;
   return(l_input_value_id);
exception
when others then
   hr_data_pump.fail('get_input_value_id', sqlerrm, p_input_value_name,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id;

/* get_input_value_id1 */
function get_input_value_id1
(
   p_input_value_name1 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id1 number;
begin
   l_input_value_id1 :=
   get_input_value_id( p_input_value_name1, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id1);
exception
when others then
   hr_data_pump.fail('get_input_value_id1', sqlerrm, p_input_value_name1,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id1;

/* get_input_value_id2 */
function get_input_value_id2
(
   p_input_value_name2 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id2 number;
begin
   l_input_value_id2 :=
   get_input_value_id( p_input_value_name2, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id2);
exception
when others then
   hr_data_pump.fail('get_input_value_id2', sqlerrm, p_input_value_name2,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id2;

/* get_input_value_id3 */
function get_input_value_id3
(
   p_input_value_name3 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id3 number;
begin
   l_input_value_id3 :=
   get_input_value_id( p_input_value_name3, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id3);
exception
when others then
   hr_data_pump.fail('get_input_value_id3', sqlerrm, p_input_value_name3,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id3;

/* get_input_value_id4 */
function get_input_value_id4
(
   p_input_value_name4 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id4 number;
begin
   l_input_value_id4 :=
   get_input_value_id( p_input_value_name4, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id4);
exception
when others then
   hr_data_pump.fail('get_input_value_id4', sqlerrm, p_input_value_name4,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id4;

/* get_input_value_id5 */
function get_input_value_id5
(
   p_input_value_name5 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id5 number;
begin
   l_input_value_id5 :=
   get_input_value_id( p_input_value_name5, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id5);
exception
when others then
   hr_data_pump.fail('get_input_value_id5', sqlerrm, p_input_value_name5,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id5;

/* get_input_value_id6 */
function get_input_value_id6
(
   p_input_value_name6 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id6 number;
begin
   l_input_value_id6 :=
   get_input_value_id( p_input_value_name6, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id6);
exception
when others then
   hr_data_pump.fail('get_input_value_id6', sqlerrm, p_input_value_name6,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id6;

/* get_input_value_id7 */
function get_input_value_id7
(
   p_input_value_name7 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id7 number;
begin
   l_input_value_id7 :=
   get_input_value_id( p_input_value_name7, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id7);
exception
when others then
   hr_data_pump.fail('get_input_value_id7', sqlerrm, p_input_value_name7,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id7;

/* get_input_value_id8 */
function get_input_value_id8
(
   p_input_value_name8 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id8 number;
begin
   l_input_value_id8 :=
   get_input_value_id( p_input_value_name8, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id8);
exception
when others then
   hr_data_pump.fail('get_input_value_id8', sqlerrm, p_input_value_name8,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id8;

/* get_input_value_id9 */
function get_input_value_id9
(
   p_input_value_name9 in varchar2,
   p_element_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id9 number;
begin
   l_input_value_id9 :=
   get_input_value_id( p_input_value_name9, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id9);
exception
when others then
   hr_data_pump.fail('get_input_value_id9', sqlerrm, p_input_value_name9,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id9;

/* get_input_value_id10 */
function get_input_value_id10
(
   p_input_value_name10 in varchar2,
   p_element_name       in varchar2,
   p_business_group_id  in number,
   p_effective_date     in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id10 number;
begin
   l_input_value_id10 :=
   get_input_value_id( p_input_value_name10, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id10);
exception
when others then
   hr_data_pump.fail('get_input_value_id10', sqlerrm, p_input_value_name10,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id10;

/* get_input_value_id11 */
function get_input_value_id11
(
   p_input_value_name11 in varchar2,
   p_element_name       in varchar2,
   p_business_group_id  in number,
   p_effective_date     in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id11 number;
begin
   l_input_value_id11 :=
   get_input_value_id( p_input_value_name11, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id11);
exception
when others then
   hr_data_pump.fail('get_input_value_id11', sqlerrm, p_input_value_name11,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id11;

/* get_input_value_id12 */
function get_input_value_id12
(
   p_input_value_name12 in varchar2,
   p_element_name       in varchar2,
   p_business_group_id  in number,
   p_effective_date     in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id12 number;
begin
   l_input_value_id12 :=
   get_input_value_id( p_input_value_name12, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id12);
exception
when others then
   hr_data_pump.fail('get_input_value_id12', sqlerrm, p_input_value_name12,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id12;

/* get_input_value_id13 */
function get_input_value_id13
(
   p_input_value_name13 in varchar2,
   p_element_name       in varchar2,
   p_business_group_id  in number,
   p_effective_date     in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id13 number;
begin
   l_input_value_id13 :=
   get_input_value_id( p_input_value_name13, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id13);
exception
when others then
   hr_data_pump.fail('get_input_value_id13', sqlerrm, p_input_value_name13,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id13;

/* get_input_value_id14 */
function get_input_value_id14
(
   p_input_value_name14 in varchar2,
   p_element_name       in varchar2,
   p_business_group_id  in number,
   p_effective_date     in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id14 number;
begin
   l_input_value_id14 :=
   get_input_value_id( p_input_value_name14, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id14);
exception
when others then
   hr_data_pump.fail('get_input_value_id14', sqlerrm, p_input_value_name14,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id14;

/* get_input_value_id15 */
function get_input_value_id15
(
   p_input_value_name15 in varchar2,
   p_element_name       in varchar2,
   p_business_group_id  in number,
   p_effective_date     in date,
   p_language_code     in varchar2
) return number is
   l_input_value_id15 number;
begin
   l_input_value_id15 :=
   get_input_value_id( p_input_value_name15, p_element_name,
                       p_business_group_id, p_effective_date,
                       p_language_code );
   return(l_input_value_id15);
exception
when others then
   hr_data_pump.fail('get_input_value_id15', sqlerrm, p_input_value_name15,
                     p_element_name, p_business_group_id, p_effective_date,
                     p_language_code);
   raise;
end get_input_value_id15;

/* get_rate_id */
function get_rate_id
(  p_rate_name         in varchar2,
   p_business_group_id in number
) return number is
   l_rate_id number;
begin
   select rate_id
   into   l_rate_id
   from   pay_rates
   where  name = p_rate_name
   and    business_group_id + 0 = p_business_group_id;
   return(l_rate_id);
exception
when others then
   hr_data_pump.fail('get_rate_id', sqlerrm, p_rate_name, p_business_group_id);
   raise;
end get_rate_id;

/* get_emp_fed_tax_rule_id - requires user key */
function get_emp_fed_tax_rule_id
(
   p_emp_fed_tax_rule_user_key in varchar2
) return number is
   l_emp_fed_tax_rule_id number;
begin
   l_emp_fed_tax_rule_id := user_key_to_id( p_emp_fed_tax_rule_user_key );
   return(l_emp_fed_tax_rule_id);
exception
when others then
   hr_data_pump.fail('get_emp_fed_tax_rule_id', sqlerrm, p_emp_fed_tax_rule_user_key);
   raise;
end get_emp_fed_tax_rule_id;

/* get_emp_state_tax_rule_id - requires user key */
function get_emp_state_tax_rule_id
(
   p_emp_state_tax_rule_user_key in varchar2
) return number is
   l_emp_state_tax_rule_id number;
begin
   l_emp_state_tax_rule_id := user_key_to_id( p_emp_state_tax_rule_user_key );
   return(l_emp_state_tax_rule_id);
exception
when others then
   hr_data_pump.fail('get_emp_state_tax_rule_id', sqlerrm, p_emp_state_tax_rule_user_key);
   raise;
end get_emp_state_tax_rule_id;

/* get_emp_county_tax_rule_id - requires user key */
function get_emp_county_tax_rule_id
(
   p_emp_county_tax_rule_user_key in varchar2
) return number is
   l_emp_county_tax_rule_id number;
begin
   l_emp_county_tax_rule_id := user_key_to_id( p_emp_county_tax_rule_user_key );
   return(l_emp_county_tax_rule_id);
exception
when others then
   hr_data_pump.fail('get_emp_county_tax_rule_id', sqlerrm, p_emp_county_tax_rule_user_key);
   raise;
end get_emp_county_tax_rule_id;

/* get_emp_city_tax_rule_id - requires user key */
function get_emp_city_tax_rule_id
(
   p_emp_city_tax_rule_user_key in varchar2
) return number is
   l_emp_city_tax_rule_id number;
begin
   l_emp_city_tax_rule_id := user_key_to_id( p_emp_city_tax_rule_user_key );
   return(l_emp_city_tax_rule_id);
exception
when others then
   hr_data_pump.fail('get_emp_city_tax_rule_id', sqlerrm, p_emp_city_tax_rule_user_key);
   raise;
end get_emp_city_tax_rule_id;

/* get_ler_internal */
function get_ler_internal
(p_business_group_id in number
,p_effective_date    in date
,p_ler_name          in varchar2
,p_caller            in varchar2
) return number is
   l_ler_id number;
begin
   l_ler_id :=
   get_ler_id(p_business_group_id, p_ler_name, p_effective_date);
   return(l_ler_id);
exception
when others then
   hr_data_pump.fail(p_caller, sqlerrm, p_business_group_id,
                     p_effective_date, p_ler_name);
   raise;
end get_ler_internal;

/* get_start_life_reason_id */
function get_start_life_reason_id
(p_business_group_id in number
,p_effective_date    in date
,p_start_life_reason in varchar2
) return number is
  l_start_life_reason_id number;
begin
  l_start_life_reason_id :=
  get_ler_internal
  (p_business_group_id, p_effective_date, p_start_life_reason,
  'get_start_life_reason_id');
return(l_start_life_reason_id);
end get_start_life_reason_id;

/* get_end_life_reason_id */
function get_end_life_reason_id
(p_business_group_id in number
,p_effective_date    in date
,p_end_life_reason   in varchar2
) return number is
  l_end_life_reason_id number;
begin
  l_end_life_reason_id :=
  get_ler_internal
  (p_business_group_id, p_effective_date, p_end_life_reason,
 'get_end_life_reason_id');
return(l_end_life_reason_id);
end get_end_life_reason_id;

/* get_benefit_group_id */
function get_benefit_group_id
(p_business_group_id  in number
,p_benefit_group      in varchar2
) return number is
   l_benefit_group_id number;
begin
   select bbg.benfts_grp_id
   into   l_benefit_group_id
   from   ben_benfts_grp bbg
   where  bbg.name = p_benefit_group
   and    bbg.business_group_id + 0 = p_business_group_id;
   return(l_benefit_group_id);
exception
when others then
   hr_data_pump.fail('get_benefit_group_id', sqlerrm, p_business_group_id,
                     p_benefit_group);
   raise;
end get_benefit_group_id;

/****** start OAB additions ******/

/** start of USER_KEY additions */

/* returns a ptnl_ler_for_per_id from supplied user_key */
function get_ptnl_ler_for_per_id
( p_ptnl_ler_for_per_user_key    in varchar2
) return number is
  l_ptnl_ler_for_per_id number;
begin
  if p_ptnl_ler_for_per_user_key is null then
    return null;
  end if;
  l_ptnl_ler_for_per_id := user_key_to_id( p_ptnl_ler_for_per_user_key );
  return(l_ptnl_ler_for_per_id);
exception
  when others then
    hr_data_pump.fail('get_ptnl_ler_for_per_id', sqlerrm, p_ptnl_ler_for_per_user_key);
    raise;
end get_ptnl_ler_for_per_id;
-------------
function get_ws_mgr_id
( p_ws_mgr_user_key    in varchar2
) return number is
  l_ws_mgr_id number;
begin
  if p_ws_mgr_user_key is null then
    return null;
  end if;
  l_ws_mgr_id := user_key_to_id( p_ws_mgr_user_key );
  return(l_ws_mgr_id);
exception
  when others then
    hr_data_pump.fail('GET_WS_MGR_ID', sqlerrm, p_ws_mgr_user_key);
    raise;
end get_ws_mgr_id;
--
function get_group_pl_id
( p_group_pl_user_key    in varchar2
) return number is
l_group_pl_id number;
begin
  if p_group_pl_user_key is null then
    return null;
  end if;
  l_group_pl_id := user_key_to_id( p_group_pl_user_key );
  return(l_group_pl_id);
exception
  when others then
    hr_data_pump.fail('get_group_pl_id', sqlerrm, p_group_pl_user_key);
    raise;
end get_group_pl_id;
--
function get_mgr_ovrid_person_id
( p_mgr_ovrid_person_user_key    in varchar2
) return number is
  l_mgr_ovrid_person_id number;
begin
  if p_mgr_ovrid_person_user_key is null then
    return null;
  end if;
  l_mgr_ovrid_person_id := user_key_to_id( p_mgr_ovrid_person_user_key );
  return(l_mgr_ovrid_person_id);
exception
  when others then
    hr_data_pump.fail('get_mgr_ovrid_person_id', sqlerrm, p_mgr_ovrid_person_user_key);
    raise;
end get_mgr_ovrid_person_id;
------------

/* returns a csd_by_ptnl_ler_for_per_id from supplied user_key */
function get_csd_by_ptnl_ler_for_per_id
( p_csd_by_ppl_user_key    in varchar2  -- note abbreviation
) return number is
  l_csd_by_ptnl_ler_for_per_id number;
begin
  if p_csd_by_ppl_user_key is null then
     return null;
  end if;
  l_csd_by_ptnl_ler_for_per_id := user_key_to_id( p_csd_by_ppl_user_key );
  return(l_csd_by_ptnl_ler_for_per_id);
exception
  when others then
    hr_data_pump.fail('get_csd_by_ptnl_ler_for_per_id', sqlerrm, p_csd_by_ppl_user_key);
    raise;
end get_csd_by_ptnl_ler_for_per_id;

/* returns a ptnl_ler_for_per object_version_number */
function get_ptnl_ler_for_per_ovn
( p_ptnl_ler_for_per_user_key    in varchar2
) return number is
  l_ovn number;
begin
   select ppl.object_version_number
   into   l_ovn
   from   ben_ptnl_ler_for_per  ppl,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_ptnl_ler_for_per_user_key
   and    ppl.ptnl_ler_for_per_id  = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_ptnl_ler_for_per_ovn', sqlerrm, p_ptnl_ler_for_per_user_key);
    raise;
end get_ptnl_ler_for_per_ovn;

/* returns a per_in_ler_id from supplied user_key */
function get_per_in_ler_id
( p_per_in_ler_user_key          in varchar2
) return number is
  l_per_in_ler_id number;
begin
  if p_per_in_ler_user_key is null then
     return null;
  end if;
  l_per_in_ler_id := user_key_to_id( p_per_in_ler_user_key );
  return(l_per_in_ler_id);
exception
  when others then
    hr_data_pump.fail('get_per_in_ler_id', sqlerrm, p_per_in_ler_user_key);
    raise;
end get_per_in_ler_id;

/* returns a per_in_ler_id from supplied user_key */
function get_trgr_table_pk_id
( p_trgr_table_pk_user_key          in varchar2
) return number is
  l_trgr_table_pk_id number;
begin
 /* if p_per_in_ler_user_key is null then
     return null;
  end if;
  l_trgr_table_pk_id := user_key_to_id( p_trgr_table_pk_user_key );
  return(l_trgr_table_pk_id); */
  -- return a null value for now
  return null;
exception
  when others then
    hr_data_pump.fail('get_trgr_table_pk_id', sqlerrm, p_trgr_table_pk_user_key);
    raise;
end get_trgr_table_pk_id;

/* returns a bckt_per_in_ler_id from supplied user_key */
function get_bckt_per_in_ler_id
( p_bckt_per_in_ler_user_key          in varchar2
) return number is
  l_bckt_per_in_ler_id number;
begin
  if p_bckt_per_in_ler_user_key is null then
    return null;
  end if;
  l_bckt_per_in_ler_id := user_key_to_id( p_bckt_per_in_ler_user_key );
  return(l_bckt_per_in_ler_id);
exception
  when others then
    hr_data_pump.fail('get_bckt_per_in_ler_id', sqlerrm, p_bckt_per_in_ler_user_key);
    raise;
end get_bckt_per_in_ler_id;

/* returns a ended_per_in_ler_id from supplied user_key */
function get_ended_per_in_ler_id
( p_ended_per_in_ler_user_key          in varchar2
) return number is
  l_ended_per_in_ler_id number;
begin
  if p_ended_per_in_ler_user_key is null then
     return null;
  end if;
  l_ended_per_in_ler_id := user_key_to_id( p_ended_per_in_ler_user_key );
  return(l_ended_per_in_ler_id);
exception
  when others then
    hr_data_pump.fail('get_ended_per_in_ler_id', sqlerrm, p_ended_per_in_ler_user_key);
    raise;
end get_ended_per_in_ler_id;

/* returns a per_in_ler object_version_number */
function get_per_in_ler_ovn
( p_per_in_ler_user_key          in varchar2
) return number is
  l_ovn number;
begin
   select pil.object_version_number
   into   l_ovn
   from   ben_per_in_ler  pil,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_per_in_ler_user_key
   and    pil.per_in_ler_id        = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_per_in_ler_ovn', sqlerrm, p_per_in_ler_user_key);
    raise;
end get_per_in_ler_ovn;

/* returns a prtt_enrt_rslt_id from supplied user_key */
function get_prtt_enrt_rslt_id
( p_prtt_enrt_rslt_user_key      in varchar2
) return number is
  l_prtt_enrt_rslt_id number;
begin
  if p_prtt_enrt_rslt_user_key is null then
     return null;
  end if;
  l_prtt_enrt_rslt_id := user_key_to_id( p_prtt_enrt_rslt_user_key );
  return(l_prtt_enrt_rslt_id);
exception
  when others then
    hr_data_pump.fail('get_prtt_enrt_rslt_id', sqlerrm, p_prtt_enrt_rslt_user_key);
    raise;
end get_prtt_enrt_rslt_id;

/* returns a rplcs_sspndd_rslt_id from supplied user_key */
function get_rplcs_sspndd_rslt_id
( p_rplcs_sspndd_rslt_user_key      in varchar2
) return number is
  l_rplcs_sspndd_rslt_id number;
begin
  if p_rplcs_sspndd_rslt_user_key is null then
     return null;
  end if;
  l_rplcs_sspndd_rslt_id := user_key_to_id( p_rplcs_sspndd_rslt_user_key );
  return(l_rplcs_sspndd_rslt_id);
exception
  when others then
    hr_data_pump.fail('get_rplcs_sspndd_rslt_id', sqlerrm, p_rplcs_sspndd_rslt_user_key);
    raise;
end get_rplcs_sspndd_rslt_id;

/* returns a prtt_enrt_rslt object_version_number */
function get_prtt_enrt_rslt_ovn
( p_prtt_enrt_rslt_user_key      in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select pen.object_version_number
   into   l_ovn
   from   ben_prtt_enrt_rslt_f  pen,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_prtt_enrt_rslt_user_key
   and    pen.prtt_enrt_rslt_id    = key.unique_key_id
   and    p_effective_date between
          pen.effective_start_date and pen.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_prtt_enrt_rslt_ovn', sqlerrm, p_prtt_enrt_rslt_user_key);
    raise;
end get_prtt_enrt_rslt_ovn;

/* returns a prtt_rt_val_id from supplied user_key */
function get_prtt_rt_val_id
( p_prtt_rt_val_user_key         in varchar2
) return number is
  l_prtt_rt_val_id number;
begin
  if p_prtt_rt_val_user_key is null then
     return null;
  end if;
  l_prtt_rt_val_id := user_key_to_id( p_prtt_rt_val_user_key );
  return(l_prtt_rt_val_id);
exception
  when others then
    hr_data_pump.fail('get_prtt_rt_val_id', sqlerrm, p_prtt_rt_val_user_key);
    raise;
end get_prtt_rt_val_id;

/* returns a prtt_rt_val object_version_number */
function get_prtt_rt_val_ovn
( p_prtt_rt_val_user_key         in varchar2
) return number is
  l_ovn number;
begin
   select prv.object_version_number
   into   l_ovn
   from   ben_prtt_rt_val  prv,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_prtt_rt_val_user_key
   and    prv.prtt_rt_val_id       = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_prtt_rt_val_ovn', sqlerrm, p_prtt_rt_val_user_key);
    raise;
end get_prtt_rt_val_ovn;

/* returns a cbr_quald_bnf_id from supplied user_key */
function get_cbr_quald_bnf_id
( p_cbr_quald_bnf_user_key       in varchar2
) return number is
  l_cbr_quald_bnf_id number;
begin
  if p_cbr_quald_bnf_user_key is null then
     return null;
  end if;
  l_cbr_quald_bnf_id := user_key_to_id( p_cbr_quald_bnf_user_key );
  return(l_cbr_quald_bnf_id);
exception
  when others then
    hr_data_pump.fail('get_cbr_quald_bnf_id', sqlerrm, p_cbr_quald_bnf_user_key);
    raise;
end get_cbr_quald_bnf_id;

/* returns a cbr_quald_bnf object_version_number */
function get_cbr_quald_bnf_ovn
( p_cbr_quald_bnf_user_key       in varchar2
) return number is
  l_ovn number;
begin
   select cqb.object_version_number
   into   l_ovn
   from   ben_cbr_quald_bnf  cqb,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_cbr_quald_bnf_user_key
   and    cqb.cbr_quald_bnf_id     = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_cbr_quald_bnf_ovn', sqlerrm, p_cbr_quald_bnf_user_key);
    raise;
end get_cbr_quald_bnf_ovn;

/* returns a cbr_per_in_ler_id from supplied user_key */
function get_cbr_per_in_ler_id
( p_cbr_per_in_ler_user_key      in varchar2
) return number is
  l_cbr_per_in_ler_id number;
begin
  if p_cbr_per_in_ler_user_key is null then
     return null;
  end if;
  l_cbr_per_in_ler_id := user_key_to_id( p_cbr_per_in_ler_user_key );
  return(l_cbr_per_in_ler_id);
exception
  when others then
    hr_data_pump.fail('get_cbr_per_in_ler_id', sqlerrm, p_cbr_per_in_ler_user_key);
    raise;
end get_cbr_per_in_ler_id;

/* returns a cbr_per_in_ler object_version_number */
function get_cbr_per_in_ler_ovn
( p_cbr_per_in_ler_user_key      in varchar2
) return number is
  l_ovn number;
begin
   select crp.object_version_number
   into   l_ovn
   from   ben_cbr_per_in_ler  crp,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_cbr_per_in_ler_user_key
   and    crp.cbr_per_in_ler_id    = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_cbr_per_in_ler_ovn', sqlerrm, p_cbr_per_in_ler_user_key);
    raise;
end get_cbr_per_in_ler_ovn;

/* returns a elig_cvrd_dpnt_id from supplied user_key */
function get_elig_cvrd_dpnt_id
( p_elig_cvrd_dpnt_user_key      in varchar2
) return number is
  l_elig_cvrd_dpnt_id number;
begin
  if p_elig_cvrd_dpnt_user_key is null then
     return null;
  end if;
  l_elig_cvrd_dpnt_id := user_key_to_id( p_elig_cvrd_dpnt_user_key );
  return(l_elig_cvrd_dpnt_id);
exception
  when others then
    hr_data_pump.fail('get_elig_cvrd_dpnt_id', sqlerrm, p_elig_cvrd_dpnt_user_key);
    raise;
end get_elig_cvrd_dpnt_id;

/* returns a elig_cvrd_dpnt object_version_number */
function get_elig_cvrd_dpnt_ovn
( p_elig_cvrd_dpnt_user_key      in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select pdp.object_version_number
   into   l_ovn
   from   ben_elig_cvrd_dpnt_f  pdp,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_elig_cvrd_dpnt_user_key
   and    pdp.elig_cvrd_dpnt_id    = key.unique_key_id
   and    p_effective_date between
          pdp.effective_start_date and pdp.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_elig_cvrd_dpnt_ovn', sqlerrm, p_effective_date, p_elig_cvrd_dpnt_user_key);
    raise;
end get_elig_cvrd_dpnt_ovn;

/* returns a prtt_prem_id from supplied user_key */
function get_prtt_prem_id
( p_prtt_prem_user_key           in varchar2
) return number is
  l_prtt_prem_id number;
begin
  if p_prtt_prem_user_key is null then
     return null;
  end if;
  l_prtt_prem_id := user_key_to_id( p_prtt_prem_user_key );
  return(l_prtt_prem_id);
exception
  when others then
    hr_data_pump.fail('get_prtt_prem_id', sqlerrm, p_prtt_prem_user_key);
    raise;
end get_prtt_prem_id;

/* returns a prtt_prem object_version_number */
function get_prtt_prem_ovn
( p_prtt_prem_user_key           in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select ppe.object_version_number
   into   l_ovn
   from   ben_prtt_prem_f  ppe,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_prtt_prem_user_key
   and    ppe.prtt_prem_id         = key.unique_key_id
   and    p_effective_date between
          ppe.effective_start_date and ppe.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_prtt_prem_ovn', sqlerrm, p_effective_date, p_prtt_prem_user_key);
    raise;
end get_prtt_prem_ovn;

/* returns a elig_dpnt_id from supplied user_key */
function get_elig_dpnt_id
( p_elig_dpnt_user_key           in varchar2
) return number is
  l_elig_dpnt_id number;
begin
  if p_elig_dpnt_user_key is null then
     return null;
  end if;
  l_elig_dpnt_id := user_key_to_id( p_elig_dpnt_user_key );
  return(l_elig_dpnt_id);
exception
  when others then
    hr_data_pump.fail('get_elig_dpnt_id', sqlerrm, p_elig_dpnt_user_key);
    raise;
end get_elig_dpnt_id;

/* returns a elig_dpnt object_version_number */
function get_elig_dpnt_ovn
( p_elig_dpnt_user_key           in varchar2
) return number is
  l_ovn number;
begin
   select egd.object_version_number
   into   l_ovn
   from   ben_elig_dpnt  egd,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_elig_dpnt_user_key
   and    egd.elig_dpnt_id         = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_elig_dpnt_ovn', sqlerrm, p_elig_dpnt_user_key);
    raise;
end get_elig_dpnt_ovn;

/* returns a elig_per_id from supplied user_key */
function get_elig_per_id
( p_elig_per_user_key            in varchar2
) return number is
  l_elig_per_id number;
begin
  if p_elig_per_user_key is null then
     return null;
  end if;
  l_elig_per_id := user_key_to_id( p_elig_per_user_key );
  return(l_elig_per_id);
exception
  when others then
    hr_data_pump.fail('get_elig_per_id', sqlerrm, p_elig_per_user_key);
    raise;
end get_elig_per_id;

/* returns a elig_per object_version_number */
function get_elig_per_ovn
( p_elig_per_user_key            in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select pep.object_version_number
   into   l_ovn
   from   ben_elig_per_f  pep,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_elig_per_user_key
   and    pep.elig_per_id          = key.unique_key_id
   and    p_effective_date between
          pep.effective_start_date and pep.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_elig_per_ovn', sqlerrm, p_effective_date, p_elig_per_user_key);
    raise;
end get_elig_per_ovn;

/* returns a elig_per_opt_id from supplied user_key */
function get_elig_per_opt_id
( p_elig_per_opt_user_key        in varchar2
) return number is
  l_elig_per_opt_id number;
begin
  if p_elig_per_opt_user_key is null then
     return null;
  end if;
  l_elig_per_opt_id := user_key_to_id( p_elig_per_opt_user_key );
  return(l_elig_per_opt_id);
exception
  when others then
    hr_data_pump.fail('get_elig_per_opt_id', sqlerrm, p_elig_per_opt_user_key);
    raise;
end get_elig_per_opt_id;

/* returns a elig_per_opt object_version_number */
function get_elig_per_opt_ovn
( p_elig_per_opt_user_key        in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select epo.object_version_number
   into   l_ovn
   from   ben_elig_per_opt_f  epo,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_elig_per_opt_user_key
   and    epo.elig_per_opt_id      = key.unique_key_id
   and    p_effective_date between
          epo.effective_start_date and epo.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_elig_per_opt_ovn', sqlerrm, p_effective_date, p_elig_per_opt_user_key);
    raise;
end get_elig_per_opt_ovn;

/* returns a pl_bnf_id from supplied user_key */
function get_pl_bnf_id
( p_pl_bnf_user_key              in varchar2
) return number is
  l_pl_bnf_id number;
begin
  if p_pl_bnf_user_key is null then
     return null;
  end if;
  l_pl_bnf_id := user_key_to_id( p_pl_bnf_user_key );
  return(l_pl_bnf_id);
exception
  when others then
    hr_data_pump.fail('get_pl_bnf_id', sqlerrm, p_pl_bnf_user_key);
    raise;
end get_pl_bnf_id;

/* returns a pl_bnf object_version_number */
function get_pl_bnf_ovn
( p_pl_bnf_user_key              in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select pbn.object_version_number
   into   l_ovn
   from   ben_pl_bnf_f  pbn,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_pl_bnf_user_key
   and    pbn.pl_bnf_id            = key.unique_key_id
   and    p_effective_date between
          pbn.effective_start_date and pbn.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_pl_bnf_ovn', sqlerrm, p_effective_date, p_pl_bnf_user_key);
    raise;
end get_pl_bnf_ovn;

/* returns a oipl_id from supplied user_key */
function get_oipl_id
( p_oipl_user_key                in varchar2
) return number is
  l_oipl_id number;
begin
  if p_oipl_user_key is null then
     return null;
  end if;
  l_oipl_id := user_key_to_id( p_oipl_user_key );
  return(l_oipl_id);
exception
  when others then
    hr_data_pump.fail('get_oipl_id', sqlerrm, p_oipl_user_key);
    raise;
end get_oipl_id;

/* returns a oipl object_version_number */
function get_oipl_ovn
( p_oipl_user_key                in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select cop.object_version_number
   into   l_ovn
   from   ben_oipl_f  cop,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_oipl_user_key
   and    cop.oipl_id              = key.unique_key_id
   and    p_effective_date between
          cop.effective_start_date and cop.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_oipl_ovn', sqlerrm, p_effective_date, p_oipl_user_key);
    raise;
end get_oipl_ovn;

/* returns a plip_id from supplied user_key */
function get_plip_id
( p_plip_user_key                in varchar2
) return number is
  l_plip_id number;
begin
  if p_plip_user_key is null then
     return null;
  end if;
  l_plip_id := user_key_to_id( p_plip_user_key );
  return(l_plip_id);
exception
  when others then
    hr_data_pump.fail('get_plip_id', sqlerrm, p_plip_user_key);
    raise;
end get_plip_id;

/* returns a plip object_version_number */
function get_plip_ovn
( p_plip_user_key                in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select cpp.object_version_number
   into   l_ovn
   from   ben_plip_f  cpp,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_plip_user_key
   and    cpp.plip_id              = key.unique_key_id
   and    p_effective_date between
          cpp.effective_start_date and cpp.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_plip_ovn', sqlerrm, p_effective_date, p_plip_user_key);
    raise;
end get_plip_ovn;

/* returns a ptip_id from supplied user_key */
function get_ptip_id
( p_ptip_user_key                in varchar2
) return number is
  l_ptip_id number;
begin
  if p_ptip_user_key is null then
     return null;
  end if;
  l_ptip_id := user_key_to_id( p_ptip_user_key );
  return(l_ptip_id);
exception
  when others then
    hr_data_pump.fail('get_ptip_id', sqlerrm, p_ptip_user_key);
    raise;
end get_ptip_id;

/* returns a ptip object_version_number */
function get_ptip_ovn
( p_ptip_user_key                in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select ctp.object_version_number
   into   l_ovn
   from   ben_ptip_f  ctp,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_ptip_user_key
   and    ctp.ptip_id              = key.unique_key_id
   and    p_effective_date between
          ctp.effective_start_date and ctp.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_ptip_ovn', sqlerrm, p_effective_date, p_ptip_user_key);
    raise;
end get_ptip_ovn;

/* returns a enrt_rt_id from supplied user_key */
function get_enrt_rt_id
( p_enrt_rt_user_key             in varchar2
) return number is
  l_enrt_rt_id number;
begin
  if p_enrt_rt_user_key is null then
     return null;
  end if;
  l_enrt_rt_id := user_key_to_id( p_enrt_rt_user_key );
  return(l_enrt_rt_id);
exception
  when others then
    hr_data_pump.fail('get_enrt_rt_id', sqlerrm, p_enrt_rt_user_key);
    raise;
end get_enrt_rt_id;

/* returns a enrt_rt object_version_number */
function get_enrt_rt_ovn
( p_enrt_rt_user_key             in varchar2
) return number is
  l_ovn number;
begin
   select ecr.object_version_number
   into   l_ovn
   from   ben_enrt_rt  ecr,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_enrt_rt_user_key
   and    ecr.enrt_rt_id           = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_enrt_rt_ovn', sqlerrm, p_enrt_rt_user_key);
    raise;
end get_enrt_rt_ovn;

/* returns a enrt_perd_id from supplied user_key */
function get_enrt_perd_id
( p_enrt_perd_user_key           in varchar2
) return number is
  l_enrt_perd_id number;
begin
  if p_enrt_perd_user_key is null then
    return null;
  end if;
  l_enrt_perd_id := user_key_to_id( p_enrt_perd_user_key );
  return(l_enrt_perd_id);
exception
  when others then
    hr_data_pump.fail('get_enrt_perd_id', sqlerrm, p_enrt_perd_user_key);
    raise;
end get_enrt_perd_id;

/* returns a enrt_perd object_version_number */
function get_enrt_perd_ovn
( p_enrt_perd_user_key           in varchar2
) return number is
  l_ovn number;
begin
   select enp.object_version_number
   into   l_ovn
   from   ben_enrt_perd  enp,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_enrt_perd_user_key
   and    enp.enrt_perd_id         = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_enrt_perd_ovn', sqlerrm, p_enrt_perd_user_key);
    raise;
end get_enrt_perd_ovn;

/* returns a prtt_reimbmt_rqst_id from supplied user_key */
function get_prtt_reimbmt_rqst_id
( p_prtt_reimbmt_rqst_user_key   in varchar2
) return number is
  l_prtt_reimbmt_rqst_id number;
begin
  if p_prtt_reimbmt_rqst_user_key is null then
     return null;
  end if;
  l_prtt_reimbmt_rqst_id := user_key_to_id( p_prtt_reimbmt_rqst_user_key );
  return(l_prtt_reimbmt_rqst_id);
exception
  when others then
    hr_data_pump.fail('get_prtt_reimbmt_rqst_id', sqlerrm, p_prtt_reimbmt_rqst_user_key);
    raise;
end get_prtt_reimbmt_rqst_id;

/* returns a prtt_reimbmt_rqst object_version_number */
function get_prtt_reimbmt_rqst_ovn
( p_prtt_reimbmt_rqst_user_key   in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
   select prc.object_version_number
   into   l_ovn
   from   ben_prtt_reimbmt_rqst_f  prc,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_prtt_reimbmt_rqst_user_key
   and    prc.prtt_reimbmt_rqst_id = key.unique_key_id
   and    p_effective_date between
          prc.effective_start_date and prc.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_prtt_reimbmt_rqst_ovn', sqlerrm, p_prtt_reimbmt_rqst_user_key);
    raise;
end get_prtt_reimbmt_rqst_ovn;

/* returns a elig_per_elctbl_chc_id from supplied user_key */
function get_elig_per_elctbl_chc_id
( p_elig_per_elctbl_chc_user_key in varchar2
) return number is
  l_elig_per_elctbl_chc_id number;
begin
  if p_elig_per_elctbl_chc_user_key is null then
     return null;
  end if;
  l_elig_per_elctbl_chc_id := user_key_to_id( p_elig_per_elctbl_chc_user_key );
  return(l_elig_per_elctbl_chc_id);
exception
  when others then
    hr_data_pump.fail('get_elig_per_elctbl_chc_id', sqlerrm, p_elig_per_elctbl_chc_user_key);
    raise;
end get_elig_per_elctbl_chc_id;

/* returns a elig_per_elctbl_chc object_version_number */
function get_elig_per_elctbl_chc_ovn
( p_elig_per_elctbl_chc_user_key in varchar2
) return number is
  l_ovn number;
begin
   select epe.object_version_number
   into   l_ovn
   from   ben_elig_per_elctbl_chc  epe,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_elig_per_elctbl_chc_user_key
   and    epe.elig_per_elctbl_chc_id  = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_elig_per_elctbl_chc_ovn', sqlerrm, p_elig_per_elctbl_chc_user_key);
    raise;
end get_elig_per_elctbl_chc_ovn;

/** end of USER_KEY additions */

/** start of NAME additions for BEN tables */
-- Note: a similar routine named get_benefit_group_id predates this. Left it for upward compat.
/* returns a benfts_grp_id */
function get_benfts_grp_id
( p_business_group_id in number,
  p_benefits_group    in varchar2
) return number is
  l_benefit_group_id number;
begin
  select bng.benfts_grp_id
  into   l_benefit_group_id
  from   ben_benfts_grp bng
  where  bng.name                  = p_benefits_group
  and    bng.business_group_id + 0 = p_business_group_id;
  return(l_benefit_group_id);
exception
when others then
  hr_data_pump.fail('get_benfts_grp_id', sqlerrm, p_business_group_id, p_benefits_group);
  raise;
end get_benfts_grp_id;

/* returns a benefits group object version number */
function get_benfts_grp_ovn
( p_business_group_id in number,
  p_benefits_group    in varchar2
) return number is
  l_ovn number;
begin
  select bng.object_version_number
  into   l_ovn
  from   ben_benfts_grp bng
  where  bng.name                  = p_benefits_group
  and    bng.business_group_id + 0 = p_business_group_id;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_benfts_grp_ovn', sqlerrm, p_business_group_id, p_benefits_group);
  raise;
end get_benfts_grp_ovn;

/* returns a pl_typ_id */
function get_pl_typ_id
( p_business_group_id in number,
  p_plan_type         in varchar2,
  p_effective_date    in date
) return number is
  l_plan_type_id number;
begin
  select ptp.pl_typ_id
  into   l_plan_type_id
  from   ben_pl_typ_f ptp
  where  ptp.name                  = p_plan_type
  and    ptp.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         ptp.effective_start_date and ptp.effective_end_date;
  return(l_plan_type_id);
exception
when others then
  hr_data_pump.fail('get_pl_typ_id', sqlerrm, p_business_group_id, p_plan_type, p_effective_date);
  raise;
end get_pl_typ_id;

/* returns a plan type object version number */
function get_pl_typ_ovn
( p_business_group_id in number,
  p_plan_type          in varchar2,
  p_effective_date     in date
) return number is
  l_ovn number;
begin
  select ptp.object_version_number
  into   l_ovn
  from   ben_pl_typ_f ptp
  where  ptp.name                  = p_plan_type
  and    ptp.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         ptp.effective_start_date and ptp.effective_end_date;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_pl_typ_ovn', sqlerrm, p_business_group_id, p_plan_type, p_effective_date);
  raise;
end get_pl_typ_ovn;

-- Note: an overloaded routine predates this. Left it for upward compat.
/* returns a ler_id */
function get_ler_id
( p_business_group_id in number,
  p_life_event_reason in varchar2,
  p_effective_date    in date
) return number is
  l_ler_id number;
begin
  select ler.ler_id
  into   l_ler_id
  from   ben_ler_f ler
  where  ler.name                  = p_life_event_reason
  and    ler.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         ler.effective_start_date and ler.effective_end_date;
  return(l_ler_id);
exception
when others then
  hr_data_pump.fail('get_ler_id', sqlerrm, p_business_group_id, p_life_event_reason, p_effective_date);
  raise;
end get_ler_id;

/* returns a life event reason object version number */
function get_ler_ovn
( p_business_group_id in number,
  p_life_event_reason in varchar2,
  p_effective_date    in date
) return number is
   l_ovn number;
begin
  select ler.object_version_number
  into   l_ovn
  from   ben_ler_f ler
  where  ler.name                  = p_life_event_reason
  and    ler.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         ler.effective_start_date and ler.effective_end_date;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_ler_ovn', sqlerrm, p_business_group_id, p_life_event_reason, p_effective_date);
  raise;
end get_ler_ovn;

/* returns an acty_base_rt_id */
function get_acty_base_rt_id
( p_business_group_id in number,
  p_acty_base_rate    in varchar2,
  p_effective_date    in date
) return number is
  l_acty_base_rt_id number;
begin
  select abr.acty_base_rt_id
  into   l_acty_base_rt_id
  from   ben_acty_base_rt_f abr
  where  abr.name                  = p_acty_base_rate
  and    abr.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  return(l_acty_base_rt_id);
exception
when others then
  hr_data_pump.fail('get_acty_base_rt_id', sqlerrm, p_business_group_id, p_acty_base_rate, p_effective_date);
  raise;
end get_acty_base_rt_id;

/* returns an acty base rate object version number */
function get_acty_base_rt_ovn
( p_business_group_id in number,
  p_acty_base_rate    in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
  select abr.object_version_number
  into   l_ovn
  from   ben_acty_base_rt_f abr
  where  abr.name                  = p_acty_base_rate
  and    abr.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_acty_base_rt_ovn', sqlerrm, p_business_group_id, p_acty_base_rate, p_effective_date);
  raise;
end get_acty_base_rt_ovn;

/* returns an actl_prem_id */
function get_actl_prem_id
( p_business_group_id in number,
  p_actual_premium    in varchar2,
  p_effective_date    in date
) return number is
  l_actl_prem_id number;
begin
  select apr.actl_prem_id
  into   l_actl_prem_id
  from   ben_actl_prem_f apr
  where  apr.name                  = p_actual_premium
  and    apr.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         apr.effective_start_date and apr.effective_end_date;
  return(l_actl_prem_id);
exception
when others then
  hr_data_pump.fail('get_actl_prem_id', sqlerrm, p_business_group_id, p_actual_premium, p_effective_date);
  raise;
end get_actl_prem_id;

/* returns an actual premium object version number */
function get_actl_prem_ovn
( p_business_group_id in number,
  p_actual_premium    in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
  select apr.object_version_number
  into   l_ovn
  from   ben_actl_prem_f apr
  where  apr.name                  = p_actual_premium
  and    apr.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         apr.effective_start_date and apr.effective_end_date;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_actl_prem_ovn', sqlerrm, p_business_group_id, p_actual_premium, p_effective_date);
  raise;
end get_actl_prem_ovn;

/* returns a comp_lvl_fctr_id */
function get_comp_lvl_fctr_id
( p_business_group_id in number,
  p_comp_level_factor in varchar2
) return number is
  l_comp_lvl_fctr_id number;
begin
  select clf.comp_lvl_fctr_id
  into   l_comp_lvl_fctr_id
  from   ben_comp_lvl_fctr clf
  where  clf.name                  = p_comp_level_factor
  and    clf.business_group_id + 0 = p_business_group_id;
  return(l_comp_lvl_fctr_id);
exception
when others then
  hr_data_pump.fail('get_comp_lvl_fctr_id', sqlerrm, p_business_group_id, p_comp_level_factor);
  raise;
end get_comp_lvl_fctr_id;

/* returns a comp level factor object version number */
function get_comp_lvl_fctr_ovn
( p_business_group_id in number,
  p_comp_level_factor in varchar2
) return number is
  l_ovn number;
begin
  select clf.object_version_number
  into   l_ovn
  from   ben_comp_lvl_fctr clf
  where  clf.name                  = p_comp_level_factor
  and    clf.business_group_id + 0 = p_business_group_id;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_comp_lvl_fctr_ovn', sqlerrm, p_business_group_id, p_comp_level_factor);
  raise;
end get_comp_lvl_fctr_ovn;

/* returns a cvg_amt_calc_mthd_id */
function get_cvg_amt_calc_mthd_id
( p_business_group_id in number,
  p_cvg_amt_calc      in varchar2,
  p_effective_date    in date
) return number is
  l_cvg_amt_calc_mthd_id number;
begin
  select ccm.cvg_amt_calc_mthd_id
  into   l_cvg_amt_calc_mthd_id
  from   ben_cvg_amt_calc_mthd_f ccm
  where  ccm.name                  = p_cvg_amt_calc
  and    ccm.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         ccm.effective_start_date and ccm.effective_end_date;
  return(l_cvg_amt_calc_mthd_id);
exception
when others then
  hr_data_pump.fail('get_cvg_amt_calc_mthd_id', sqlerrm, p_business_group_id, p_cvg_amt_calc, p_effective_date);
  raise;
end get_cvg_amt_calc_mthd_id;

/* returns a cvg amt calc object version number */
function get_cvg_amt_calc_mthd_ovn
( p_business_group_id in number,
  p_cvg_amt_calc      in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
  select ccm.object_version_number
  into   l_ovn
  from   ben_cvg_amt_calc_mthd_f ccm
  where  ccm.name                  = p_cvg_amt_calc
  and    ccm.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         ccm.effective_start_date and ccm.effective_end_date;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_cvg_amt_calc_mthd_ovn', sqlerrm, p_business_group_id, p_cvg_amt_calc, p_effective_date);
  raise;
end get_cvg_amt_calc_mthd_ovn;

/* returns an opt_id */
function get_opt_id
( p_business_group_id in number,
  p_option_definition in varchar2,
  p_effective_date    in date
) return number is
  l_opt_id number;
begin
  select opt.opt_id
  into   l_opt_id
  from   ben_opt_f opt
  where  opt.name                  = p_option_definition
  and    opt.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         opt.effective_start_date and opt.effective_end_date;
  return(l_opt_id);
exception
when others then
  hr_data_pump.fail('get_opt_id', sqlerrm, p_business_group_id, p_option_definition, p_effective_date);
  raise;
end get_opt_id;

/* returns an option definition object version number */
function get_opt_ovn
( p_business_group_id in number,
  p_option_definition in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
  select opt.object_version_number
  into   l_ovn
  from   ben_opt_f opt
  where  opt.name                  = p_option_definition
  and    opt.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         opt.effective_start_date and opt.effective_end_date;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_opt_ovn', sqlerrm, p_business_group_id, p_option_definition, p_effective_date);
  raise;
end get_opt_ovn;

/* returns a pl_id */
function get_pl_id
( p_business_group_id in number,
  p_plan              in varchar2,
  p_effective_date    in date
) return number is
  l_pl_id number;
begin
  select pln.pl_id
  into   l_pl_id
  from   ben_pl_f pln
  where  pln.name                  = p_plan
  and    pln.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         pln.effective_start_date and pln.effective_end_date;
  return(l_pl_id);
exception
when others then
  hr_data_pump.fail('get_pl_id', sqlerrm, p_business_group_id, p_plan, p_effective_date);
  raise;
end get_pl_id;

/* returns a plan object version number */
function get_pl_ovn
( p_business_group_id in number,
  p_plan              in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
  select pln.object_version_number
  into   l_ovn
  from   ben_pl_f pln
  where  pln.name                  = p_plan
  and    pln.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         pln.effective_start_date and pln.effective_end_date;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_pl_ovn', sqlerrm, p_business_group_id, p_plan, p_effective_date);
  raise;
end get_pl_ovn;

/* returns a pgm_id */
function get_pgm_id
( p_business_group_id in number,
  p_program           in varchar2,
  p_effective_date    in date
) return number is
  l_pgm_id number;
begin
  select pgm.pgm_id
  into   l_pgm_id
  from   ben_pgm_f pgm
  where  pgm.name                  = p_program
  and    pgm.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;
  return(l_pgm_id);
exception
when others then
  hr_data_pump.fail('get_pgm_id', sqlerrm, p_business_group_id, p_program, p_effective_date);
  raise;
end get_pgm_id;

/* returns a program object version number */
function get_pgm_ovn
( p_business_group_id in number,
  p_program           in varchar2,
  p_effective_date    in date
) return number is
  l_ovn number;
begin
  select pgm.object_version_number
  into   l_ovn
  from   ben_pgm_f pgm
  where  pgm.name                  = p_program
  and    pgm.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;
  return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_pgm_ovn', sqlerrm, p_business_group_id, p_program, p_effective_date);
  raise;
end get_pgm_ovn;

/** start of NAME lookups for PER/PAY/HR tables **/

/* returns an element_type_id */
function get_element_type_id
( p_business_group_id in number,
--p_legislation_code in varchar2,
  p_element_name    in varchar2,
  p_effective_date    in date
) return number is
  l_element_type_id number;
begin
  select pet.element_type_id
  into   l_element_type_id
  from   pay_element_types_f pet
  where  pet.element_name        = p_element_name
  and    business_group_id + 0   = p_business_group_id
  and    p_effective_date between
         pet.effective_start_date and pet.effective_end_date;
  return(l_element_type_id);
exception
when others then
  hr_data_pump.fail('get_element_type_id', sqlerrm, p_business_group_id, p_element_name);
  raise;
end get_element_type_id;

/** end of NAME additions **/

/* returns currency_code from fnd_currencies_vl */
function get_currency_code
( p_name_or_code    in varchar2,
  p_effective_date  in date
) return varchar2 is
  l_code fnd_currencies_vl.currency_code%type;
begin
--hr_data_pump.message('**bp** in hr_pump_get.get_cur_code: '|| p_name_or_code);
  --
  begin
    if p_name_or_code is null or p_name_or_code = hr_api.g_varchar2
    then
      --
      -- Defaulted values will be returned unchanged.
      --
      l_code := p_name_or_code;
    else
      --
      -- Check name
      --
      select currency_code
      into   l_code
      from   fnd_currencies_vl
      where  name          = p_name_or_code
      and    enabled_flag  = 'Y'
      and    p_effective_date between
             nvl(start_date_active, START_OF_TIME) and nvl(end_date_active, END_OF_TIME);
    end if;
    --
--hr_data_pump.message('**bp** out hr_pump_get.get_cur_code: '||l_code);
    return(l_code);
  exception
    when no_data_found then
      --
      -- If the name could not be matched, check if the code was used.
      --
      select currency_code
      into   l_code
      from   fnd_currencies    -- user underlying table for faster code lookup
      where  currency_code = p_name_or_code
      and    enabled_flag  = 'Y'
      and    p_effective_date between
             nvl(start_date_active, START_OF_TIME) and nvl(end_date_active, END_OF_TIME);
      --
--hr_data_pump.message('**bp** out hr_pump_get.get_cur_code: '||l_code);
      return(l_code);
    when others then
      raise;
  end;
  --
exception
--
when no_data_found then
  hr_data_pump.fail('get_currency_code', sqlerrm, p_name_or_code);
  raise value_error;
when others then
  hr_data_pump.fail('get_currency_code', sqlerrm, p_name_or_code);
  raise;
end get_currency_code;

/* start HR/PER additional get_xyz routines for BEN */

/* returns a uom code */
function get_uom_code
( p_uom            in varchar2,
  p_effective_date in date
) return varchar2 is
begin
  return(get_currency_code( p_uom, p_effective_date ));
exception
  when others then
    hr_data_pump.fail('get_uom_code', sqlerrm, p_uom);
    raise;
end get_uom_code;

/* returns a std_prem_uom code */
function get_std_prem_uom_code
( p_std_prem_uom            in varchar2,
  p_effective_date in date
) return varchar2 is
begin
  return(get_currency_code( p_std_prem_uom, p_effective_date ));
exception
  when others then
    hr_data_pump.fail('get_std_prem_uom_code', sqlerrm, p_std_prem_uom);
    raise;
end get_std_prem_uom_code;

/* returns a comp_ref_uom code */
function get_comp_ref_uom_code
( p_comp_ref_uom            in varchar2,
  p_effective_date in date
) return varchar2 is
begin
  return(get_currency_code( p_comp_ref_uom, p_effective_date ));
exception
  when others then
    hr_data_pump.fail('get_comp_ref_uom_code', sqlerrm, p_comp_ref_uom);
    raise;
end get_comp_ref_uom_code;

/* returns a rt_comp_ref_uom code */
function get_rt_comp_ref_uom_code
( p_rt_comp_ref_uom            in varchar2,
  p_effective_date in date
) return varchar2 is
begin
  return(get_currency_code( p_rt_comp_ref_uom, p_effective_date ));
exception
  when others then
    hr_data_pump.fail('get_rt_comp_ref_uom_code', sqlerrm, p_rt_comp_ref_uom);
    raise;
end get_rt_comp_ref_uom_code;

/* returns a amt_dsgd_uom code */
function get_amt_dsgd_uom_code
( p_amt_dsgd_uom            in varchar2,
  p_effective_date in date
) return varchar2 is
begin
  return(get_currency_code( p_amt_dsgd_uom, p_effective_date ));
exception
  when others then
    hr_data_pump.fail('get_amt_dsgd_uom_code', sqlerrm, p_amt_dsgd_uom);
    raise;
end get_amt_dsgd_uom_code;

/* get_quald_bnf_person_id - requires user key */
function get_quald_bnf_person_id
(
   p_quald_bnf_person_user_key in varchar2
) return number is
   l_person_id number;
begin
   if p_quald_bnf_person_user_key is null then
     return null;
   end if;
   l_person_id := user_key_to_id( p_quald_bnf_person_user_key );
   return(l_person_id);
exception
when others then
   hr_data_pump.fail('get_quald_bnf_person_id', sqlerrm, p_quald_bnf_person_user_key);
   raise;
end get_quald_bnf_person_id;

/* get_cvrd_emp_person_id - requires user key */
function get_cvrd_emp_person_id
(
   p_cvrd_emp_person_user_key in varchar2
) return number is
   l_person_id number;
begin
   if p_cvrd_emp_person_user_key is null then
      return null;
   end if;
   l_person_id := user_key_to_id( p_cvrd_emp_person_user_key );
   return(l_person_id);
exception
when others then
   hr_data_pump.fail('get_cvrd_emp_person_id', sqlerrm, p_cvrd_emp_person_user_key);
   raise;
end get_cvrd_emp_person_id;

/* get_dpnt_person_id - requires user key */
function get_dpnt_person_id
(
   p_dpnt_person_user_key in varchar2
) return number is
   l_person_id number;
begin
   if p_dpnt_person_user_key is null then
     return null;
   end if;
   l_person_id := user_key_to_id( p_dpnt_person_user_key );
   return(l_person_id);
exception
when others then
   hr_data_pump.fail('get_dpnt_person_id', sqlerrm, p_dpnt_person_user_key);
   raise;
end get_dpnt_person_id;

/* get_bnf_person_id - requires user key */
function get_bnf_person_id
(
   p_bnf_person_user_key in varchar2
) return number is
   l_person_id number;
begin
   if p_bnf_person_user_key is null then
      return null;
   end if;
   l_person_id := user_key_to_id( p_bnf_person_user_key );
   return(l_person_id);
exception
when others then
   hr_data_pump.fail('get_bnf_person_id', sqlerrm, p_bnf_person_user_key);
   raise;
end get_bnf_person_id;

/* get_ttee_person_id - requires user key */
function get_ttee_person_id
(
   p_ttee_person_user_key in varchar2
) return number is
   l_person_id number;
begin
   if p_ttee_person_user_key is null then
     return null;
   end if;
   l_person_id := user_key_to_id( p_ttee_person_user_key );
   return(l_person_id);
exception
when others then
   hr_data_pump.fail('get_ttee_person_id', sqlerrm, p_ttee_person_user_key);
   raise;
end get_ttee_person_id;

/****** end OAB additions ******/

/* get_person_id - requires user key */
function get_person_id
(
   p_person_user_key in varchar2
) return number is
   l_person_id number;
begin
   l_person_id := user_key_to_id( p_person_user_key );
   return(l_person_id);
exception
when others then
   hr_data_pump.fail('get_person_id', sqlerrm, p_person_user_key);
   raise;
end get_person_id;

/* return person_id for contact person. */
function get_contact_person_id
(
   p_contact_person_user_key in varchar2
) return number is
   l_contact_person_id number;
begin
   l_contact_person_id := get_person_id(p_contact_person_user_key);
   return(l_contact_person_id);
exception
when others then
   hr_data_pump.fail('get_contact_person_id', sqlerrm,
                     p_contact_person_user_key);
   raise;
end get_contact_person_id;

/* return assignment_id - requires user key */
function get_assignment_id
(
   p_assignment_user_key in varchar2
) return number is
   l_assignment_id number;
begin
   l_assignment_id := user_key_to_id( p_assignment_user_key );
   return(l_assignment_id);
exception
when others then
   hr_data_pump.fail('get_assignment_id', sqlerrm, p_assignment_user_key);
   raise;
end get_assignment_id;

/* return address_id - requires user key */
function get_address_id
(
   p_address_user_key in varchar2
) return number is
   l_address_id number;
begin
   l_address_id := user_key_to_id( p_address_user_key );
   return(l_address_id);
exception
when others then
   hr_data_pump.fail('get_address_id', sqlerrm, p_address_user_key);
   raise;
end get_address_id;

/* return supervisor person_id - requires user key */
function get_supervisor_id
(
   p_supervisor_user_key in varchar2
) return number is
   l_supervisor_id number;
begin
   l_supervisor_id := get_person_id( p_supervisor_user_key );
   return(l_supervisor_id);
exception
when others then
   hr_data_pump.fail('get_supervisor_id', sqlerrm, p_supervisor_user_key);
   raise;
end get_supervisor_id;

/* return recruiter person_id - requires user key */
function get_recruiter_id
(
   p_recruiter_user_key in varchar2
) return number is
   l_recruiter_id number;
begin
   l_recruiter_id := get_person_id( p_recruiter_user_key );
   return(l_recruiter_id);
exception
when others then
   hr_data_pump.fail('get_recruiter_id', sqlerrm, p_recruiter_user_key);
   raise;
end get_recruiter_id;

/* return person_referred_by_id - requires user key */
function get_person_referred_by_id
(
   p_person_referred_by_user_key in varchar2
) return number is
   l_person_referred_by_id number;
begin
   l_person_referred_by_id := get_person_id( p_person_referred_by_user_key );
   return(l_person_referred_by_id);
exception
when others then
   hr_data_pump.fail('get_person_referred_by_id', sqlerrm,
                     p_person_referred_by_user_key);
   raise;
end get_person_referred_by_id;

/* return person_id for timecard approver. */
function get_timecard_approver_id
(
   p_timecard_approver_user_key in varchar2
) return number is
   l_timecard_approver_id number;
begin
   l_timecard_approver_id := get_person_id(p_timecard_approver_user_key);
   return(l_timecard_approver_id);
exception
when others then
   hr_data_pump.fail('get_timecard_approver_id', sqlerrm,
                     p_timecard_approver_user_key);
   raise;
end get_timecard_approver_id;

/* returns contact_relationship_id */
function get_contact_relationship_id
(
   p_contact_user_key   in varchar2,
   p_contactee_user_key in varchar2
) return number is
   l_contact_relationship_id number;
begin
   select pcr.contact_relationship_id
   into   l_contact_relationship_id
   from   per_contact_relationships    pcr,
          hr_pump_batch_line_user_keys contact_key,
          hr_pump_batch_line_user_keys contactee_key
   where  contact_key.user_key_value   = p_contact_user_key
   and    pcr.contact_person_id        = contact_key.unique_key_id
   and    contactee_key.user_key_value = p_contactee_user_key
   and    pcr.person_id                = contactee_key.unique_key_id;
   return(l_contact_relationship_id);
exception
when others then
   hr_data_pump.fail('get_contact_relationship_id', sqlerrm,
                     p_contact_user_key, p_contactee_user_key );
   raise;
end get_contact_relationship_id;

/* return person_type_id */
function get_person_type_id
(
   p_user_person_type  in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number is
   l_person_type_id number;
begin
   select typ.person_type_id
   into   l_person_type_id
   from   per_person_types_tl typtl,
    per_person_types typ
   where  typtl.user_person_type      = p_user_person_type
   and    typ.business_group_id + 0   = p_business_group_id
   and    typ.person_type_id = typtl.person_type_id
   and    typtl.LANGUAGE = p_language_code;
   return(l_person_type_id);
exception
when others then
   hr_data_pump.fail('get_person_type_id', sqlerrm, p_user_person_type,
                     p_business_group_id, p_language_code);
   raise;
end get_person_type_id;

/* returns a vendor_id */
function get_vendor_id
(
   p_vendor_name in varchar2
) return number is
   l_vendor_id number;
begin
   select pov.vendor_id
   into   l_vendor_id
   from   po_vendors pov
   where  pov.vendor_name = p_vendor_name;
   return(l_vendor_id);
exception
when others then
   hr_data_pump.fail('get_vendor_id', sqlerrm, p_vendor_name);
   raise;
end get_vendor_id;

/* returns an assignment_status_type_id */
function get_assignment_status_type_id
(
   p_user_status       in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number is
   l_assignment_status_type_id number;
begin
   -- Need to check for amended row in per_ass_status_type_amends first.
   begin
      select typ.assignment_status_type_id
      into l_assignment_status_type_id
      from   per_ass_status_type_amends_tl typtl,
             per_ass_status_type_amends typ
      where  typtl.user_status = p_user_status
      and    typ.business_group_id + 0 = p_business_group_id
      and    typ.ass_status_type_amend_id = typtl.ass_status_type_amend_id
      and    typtl.LANGUAGE = p_language_code;
      return(l_assignment_status_type_id);
   exception
      when no_data_found then
         null;
      when others then
         raise;
   end;

   -- Can look in per_assignment_status_types now.
   select typ.assignment_status_type_id
   into   l_assignment_status_type_id
   from   per_assignment_status_types_tl typtl,
          per_assignment_status_types typ
   where  typtl.user_status = p_user_status
   and    typ.assignment_status_type_id = typtl.assignment_status_type_id
   and    typtl.LANGUAGE = p_language_code
   and
   (
     (typ.business_group_id is null and typ.legislation_code is null)
     or
     (typ.business_group_id is not null
      and typ.business_group_id + 0 = p_business_group_id)
     or
     (typ.business_group_id is null
      and typ.legislation_code is not null
      and typ.legislation_code =
          (select legislation_code from per_business_groups
           where  business_group_id = p_business_group_id))
   );
   return(l_assignment_status_type_id);
exception
when others then
   hr_data_pump.fail('get_assignment_status_type_id', sqlerrm, p_user_status,
                     p_business_group_id, p_language_code);
   raise;
end get_assignment_status_type_id;

/* returns an organization_id */
function get_organization_id
(
   p_organization_name in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
  ,p_language_code     in varchar2
) return number is
   l_organization_id number;
begin
   select org.organization_id
   into   l_organization_id
   from   hr_all_organization_units org
   ,      hr_all_organization_units_tl orgtl
   where  orgtl.name = p_organization_name
   and    orgtl.language = p_language_code
   and    org.organization_id = orgtl.organization_id
   and    org.business_group_id + 0 = p_business_group_id;
   return(l_organization_id);
exception
when others then
   hr_data_pump.fail('get_organization_id', sqlerrm, p_organization_name,
                     p_business_group_id, p_effective_date, p_language_code);
   raise;
end get_organization_id;

/* returns a establishment_org_id */
function get_establishment_org_id
(
   p_establishment_org_name in varchar2,
   p_business_group_id        in number,
   p_effective_date           in date
,  p_language_code            in varchar2
) return number is
   l_establishment_org_id number;
begin
   l_establishment_org_id :=
   get_organization_id( p_establishment_org_name, p_business_group_id,
                        p_effective_date, p_language_code );
   return(l_establishment_org_id);
exception
when others then
   hr_data_pump.fail('get_establishment_org_id', sqlerrm,
                     p_establishment_org_name, p_business_group_id,
                     p_effective_date, p_language_code);
   raise;
end get_establishment_org_id;

/* returns a source_organization_id */
function get_source_organization_id
(
   p_source_organization_name in varchar2,
   p_business_group_id        in number,
   p_effective_date           in date
,  p_language_code            in varchar2
) return number is
   l_source_organization_id number;
begin
   l_source_organization_id :=
   get_organization_id( p_source_organization_name, p_business_group_id,
                        p_effective_date, p_language_code );
   return(l_source_organization_id);
exception
when others then
   hr_data_pump.fail('get_source_organization_id', sqlerrm,
                     p_source_organization_name, p_business_group_id,
                     p_effective_date, p_language_code);
   raise;
end get_source_organization_id;

/* returns a grade_id */
function get_grade_id
(
   p_grade_name        in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number is
   l_grade_id number;
begin
   -- Note that the grade name can be null on the
   -- per_grades table, but I think grades are created
   -- with a name - otherwise identifying them would be
   -- rather difficult...
   select gra.grade_id
   into   l_grade_id
   from   per_grades_vl gra
   where  gra.name                  = p_grade_name
   and    gra.business_group_id + 0 = p_business_group_id;
   return(l_grade_id);
exception
when others then
   hr_data_pump.fail('get_grade_id', sqlerrm, p_grade_name, p_business_group_id,                      p_effective_date);
   raise;
end get_grade_id;

/* returns a grade_id */
function get_entry_grade_id
(
   p_entry_grade_name        in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number is
   l_entry_grade_id number;
begin
   l_entry_grade_id :=
   get_grade_id
   (p_grade_name        => p_entry_grade_name
   ,p_business_group_id => p_business_group_id
   ,p_effective_date    => p_effective_date
   );
   return(l_entry_grade_id);
exception
when others then
  raise;
end get_entry_grade_id;

/* return availability_status_id */
function get_availability_status_id
(p_shared_type_name  in    varchar2
,p_system_type_cd    in    varchar2
,p_business_group_id in    number
,p_language_code     in    varchar2
) return number is
cursor csr_lookup is
select pst.shared_type_id
from   per_shared_types pst
,      per_shared_types_tl psttl
where  psttl.shared_type_name = p_shared_type_name
and    psttl.language = p_language_code
and    pst.shared_type_id = psttl.shared_type_id
and    pst.lookup_type = 'POSITION_AVAILABILITY_STATUS'
and    pst.system_type_cd = p_system_type_cd
and    nvl(pst.business_group_id, p_business_group_id) = p_business_group_id;
--
v_shared_type_id    number(15) := null;
begin
  if p_shared_type_name is not null then
    open csr_lookup;
    fetch csr_lookup into v_shared_type_id;
    close csr_lookup;
   end if;
   return v_shared_type_id;
exception
  when others then
    hr_data_pump.fail('get_availability_status_id', sqlerrm,
                     p_shared_type_name, p_system_type_cd,
                     p_business_group_id, p_language_code);
    raise;
end get_availability_status_id;

/* returns a position_id */
function get_position_id
(
   p_position_name     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number is
   l_position_id number;
begin
   select pos.position_id
   into   l_position_id
   from   hr_all_positions_f pos
   where  pos.name                  = p_position_name
   and    pos.business_group_id + 0 = p_business_group_id
   and    p_effective_date between
          pos.effective_start_date and pos.effective_end_date;
   return(l_position_id);
exception
when others then
   hr_data_pump.fail('get_position_id', sqlerrm, p_position_name,
                     p_business_group_id, p_effective_date);
   raise;
end get_position_id;

/* returns a successor_position_id */
function get_successor_position_id
(
   p_successor_position_name in varchar2,
   p_business_group_id       in number,
   p_effective_date          in date
) return number is
   l_pos_id number;
begin
   -- Just call the get_position_id function.
   l_pos_id := get_position_id(p_successor_position_name,
                               p_business_group_id,
                               p_effective_date);
   return(l_pos_id);
exception
when others then
   hr_data_pump.fail('get_successor_position_id', sqlerrm,
                     p_successor_position_name, p_business_group_id,
                     p_effective_date);
   raise;
end get_successor_position_id;

/* returns a relief_position_id */
function get_relief_position_id
(
   p_relief_position_name in varchar2,
   p_business_group_id    in number,
   p_effective_date       in date
) return number is
   l_pos_id number;
begin
   -- Just call the get_position_id function.
   l_pos_id := get_position_id(p_relief_position_name,
                               p_business_group_id,
                               p_effective_date);
   return(l_pos_id);
exception
when others then
   hr_data_pump.fail('get_relief_position_id', sqlerrm,
                     p_relief_position_name, p_business_group_id,
                     p_effective_date);
   raise;
end get_relief_position_id;

/* returns a prior_position_id */
function get_prior_position_id
(
   p_prior_position_name in varchar2,
   p_business_group_id       in number,
   p_effective_date          in date
) return number is
   l_pos_id number;
begin
   -- Just call the get_position_id function.
   l_pos_id := get_position_id(p_prior_position_name,
                               p_business_group_id,
                               p_effective_date);
   return(l_pos_id);
exception
when others then
   hr_data_pump.fail('get_prior_position_id', sqlerrm,
                     p_prior_position_name, p_business_group_id,
                     p_effective_date);
   raise;
end get_prior_position_id;

/* returns a supervisor_position_id */
function get_supervisor_position_id
(
   p_supervisor_position_name in varchar2,
   p_business_group_id       in number,
   p_effective_date          in date
) return number is
   l_pos_id number;
begin
   -- Just call the get_position_id function.
   l_pos_id := get_position_id(p_supervisor_position_name,
                               p_business_group_id,
                               p_effective_date);
   return(l_pos_id);
exception
when others then
   hr_data_pump.fail('get_supervisor_position_id', sqlerrm,
                     p_supervisor_position_name, p_business_group_id,
                     p_effective_date);
   raise;
end get_supervisor_position_id;

/* returns a job_id */
function get_job_id
(
   p_job_name          in varchar2,
   p_effective_date    in date,
   p_business_group_id in number
) return number is
   l_job_id number;
begin
   select job.job_id
   into   l_job_id
   from   per_jobs_vl job
   where  job.name                  = p_job_name
   and    job.business_group_id + 0 = p_business_group_id;
   return(l_job_id);
exception
when others then
   hr_data_pump.fail('get_job_id', sqlerrm,
                     p_job_name, p_effective_date, p_business_group_id);
   raise;
end get_job_id;

/* returns a payroll_id */
function get_payroll_id
(
   p_payroll_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number is
   l_payroll_id number;
begin
   select pay.payroll_id
   into   l_payroll_id
   from   pay_payrolls_f pay
   where  pay.payroll_name          = p_payroll_name
   and    pay.business_group_id + 0 = p_business_group_id
   and    p_effective_date between
          pay.effective_start_date and pay.effective_end_date;
   return(l_payroll_id);
exception
when others then
   hr_data_pump.fail('get_payroll_id', sqlerrm, p_payroll_name,
                     p_business_group_id, p_effective_date);
   raise;
end get_payroll_id;

/* returns a pay_freq_payroll_id */
function get_pay_freq_payroll_id
(
   p_pay_freq_payroll_name in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number is
begin
   return
   get_payroll_id
   (p_payroll_name      => p_pay_freq_payroll_name
   ,p_business_group_id => p_business_group_id
   ,p_effective_date    => p_effective_date
   );
exception
when others then
   raise;
end get_pay_freq_payroll_id;

/* Returns a location_id for the update_location APIs. */
function get_location_id_update
(
   p_existing_location_code in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number is
l_location_id number;
begin
   l_location_id :=
   get_location_id(p_existing_location_code, p_business_group_id,
                   p_language_code);
   return(l_location_id);
exception
when others then
   hr_data_pump.fail('get_location_id_update', sqlerrm,
                     p_existing_location_code,
                     p_business_group_id, p_language_code);
   raise;
end get_location_id_update;

/* returns a location_id */
function get_location_id
(
   p_location_code     in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number is
   l_location_id number;
begin
   select loc.location_id
   into   l_location_id
   from   hr_locations_all loc,
          hr_locations_all_tl lot
   where  lot.location_code = p_location_code
   and    lot.language      = p_language_code
   and    lot.location_id   = loc.location_id
   and    (loc.business_group_id is null or
           loc.business_group_id + 0 = p_business_group_id);
   return(l_location_id);
exception
when others then
   hr_data_pump.fail('get_location_id', sqlerrm, p_location_code,
                     p_business_group_id, p_language_code);
   raise;
end get_location_id;

/* returns receiver id */
function get_designated_receiver_id
 (
  p_designated_receiver_name Varchar2,
  p_business_group_id Number,
  p_effective_date   Date
 ) return number Is
   l_designated_receiver_id Number;
begin
  Select person_id
    Into l_designated_receiver_id
    From per_all_people_f
   Where employee_number Is Not Null
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date and effective_end_date
     and full_name = p_designated_receiver_name;
  return l_designated_receiver_id;
Exception
When Others Then
   hr_data_pump.fail('get_designated_receiver_id',sqlerrm,p_designated_receiver_name,
                     p_business_group_id);
   raise;
end get_designated_receiver_id;

function get_ship_to_location_id
(
   p_ship_to_location_code     in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number is
   l_location_id number;
begin
   select loc.location_id
   into   l_location_id
   from   hr_locations_all loc,
          hr_locations_all_tl lot
   where  lot.location_code = p_ship_to_location_code
   and    lot.language      = p_language_code
   and    lot.location_id   = loc.location_id
   and    (loc.business_group_id is null or
           loc.business_group_id + 0 = p_business_group_id);
   return(l_location_id);
exception
when others then
   hr_data_pump.fail('get_ship_to_location_id', sqlerrm, p_ship_to_location_code,
                     p_business_group_id, p_language_code);
   raise;
end get_ship_to_location_id;

/* returns a pay_basis_id */
function get_pay_basis_id
(
   p_pay_basis_name    in varchar2,
   p_business_group_id in number
) return number is
   l_pay_basis_id number;
begin
   select ppb.pay_basis_id
   into   l_pay_basis_id
   from   per_pay_bases ppb
   where  ppb.name                  = p_pay_basis_name
   and    ppb.business_group_id + 0 = p_business_group_id;
   return(l_pay_basis_id);
exception
when others then
   hr_data_pump.fail('get_pay_basis_id', sqlerrm, p_pay_basis_name,
                     p_business_group_id);
   raise;
end get_pay_basis_id;

/* returns a recruitment_activity_id */
function get_recruitment_activity_id
(
   p_recruitment_activity_name in varchar2,
   p_business_group_id         in number,
   p_effective_date            in date
) return number is
   l_raid number;
begin
   select pra.recruitment_activity_id
   into   l_raid
   from   per_recruitment_activities pra
   where  pra.name                  = p_recruitment_activity_name
   and    pra.business_group_id + 0 = p_business_group_id
   and    p_effective_date between
          pra.date_start and nvl(pra.date_end, END_OF_TIME);
   return(l_raid);
exception
when others then
   hr_data_pump.fail('get_recruitment_activity_id', sqlerrm,
                     p_recruitment_activity_name, p_business_group_id,
                     p_effective_date);
   raise;
end get_recruitment_activity_id;

/* returns a vacancy_id */
function get_vacancy_id
(
   p_vacancy_user_key in varchar2
) return number is
   l_vacancy_id number;
begin
   l_vacancy_id := user_key_to_id( p_vacancy_user_key );
   return(l_vacancy_id);
exception
when others then
   hr_data_pump.fail('get_vacancy_id', sqlerrm, p_vacancy_user_key );
   raise;
end get_vacancy_id;

/* returns an org_payment_method_id */
function get_org_payment_method_id
(
   p_org_payment_method_user_key in varchar2
) return number is
   l_opmid number;
begin
   l_opmid := user_key_to_id( p_org_payment_method_user_key );
   return(l_opmid);
exception
when others then
   hr_data_pump.fail('get_org_payment_method_id', sqlerrm,
                     p_org_payment_method_user_key );
   raise;
end get_org_payment_method_id;

/* returns a payee organization_id */
function get_payee_org_id
(
   p_payee_organization_name in varchar2,
   p_business_group_id       in number,
   p_effective_date          in date
,  p_language_code           in varchar2
) return number is
   l_organization_id number;
begin
   l_organization_id :=
   get_organization_id( p_payee_organization_name, p_business_group_id,
                        p_effective_date, p_language_code );
   return(l_organization_id);
exception
when others then
   hr_data_pump.fail('get_payee_org_id', sqlerrm, p_payee_organization_name,
                     p_business_group_id, p_effective_date, p_language_code);
   raise;
end get_payee_org_id;

/* return payee person_id - requires user key */
function get_payee_person_id
(
   p_payee_person_user_key in varchar2
) return number is
   l_person_id number;
begin
   l_person_id := get_person_id( p_payee_person_user_key );
   return(l_person_id);
exception
when others then
   hr_data_pump.fail('get_payee_person_id', sqlerrm, p_payee_person_user_key);
   raise;
end get_payee_person_id;

/* return payee_id for an organization or person payee. */
function get_payee_id
(
   p_data_pump_always_call in varchar2,
   p_payee_type            in varchar2,
   p_business_group_id     in number,
   p_payee_org             in varchar2 default null,
   p_payee_person_user_key in varchar2 default null,
   p_effective_date        in date
,  p_language_code         in varchar2
) return number is
   l_payee_id number;
begin
   --
   -- Check for a payee person.
   --
   if p_payee_type = 'P' and p_payee_person_user_key is not null then
      l_payee_id := get_payee_person_id( p_payee_person_user_key );
      return(l_payee_id);
   --
   -- Check for a payee organization.
   --
   elsif p_payee_type = 'O' and p_payee_org is not null then
      l_payee_id :=
      get_payee_org_id( p_payee_org, p_business_group_id, p_effective_date,
                        p_language_code );
      return(l_payee_id);
   --
   -- Everything is NULL so return NULL.
   --
   elsif p_payee_type is null and p_payee_person_user_key is null and
         p_payee_org is null then
      return null;
   --
   -- Everything is HR_API-defaulted, so return HR_API default value.
   -- User Keys are set to NULL, if defaulted, on UPDATE.
   --
   elsif p_payee_type = HR_API_G_VARCHAR2 and
         (p_payee_person_user_key is null or p_payee_person_user_key =
         HR_API_G_VARCHAR2) and p_payee_org = HR_API_G_VARCHAR2 then
      return HR_API_G_NUMBER;
   --
   -- User has supplied an erroneous combination of arguments.
   --
   else
      raise value_error;
   end if;
exception
when others then
   hr_data_pump.fail('get_payee_id', sqlerrm, p_payee_type, p_payee_org,
                     p_payee_person_user_key, p_effective_date, p_language_code);
   raise;
end get_payee_id;

/* returns a personal_payment_method_id */
function get_personal_payment_method_id
(
   p_personal_pay_method_user_key in varchar2
) return number is
   l_ppmid number;
begin
   l_ppmid := user_key_to_id( p_personal_pay_method_user_key );
   return(l_ppmid);
exception
when others then
   hr_data_pump.fail('get_personal_payment_method_id', sqlerrm,
                     p_personal_pay_method_user_key);
   raise;
end get_personal_payment_method_id;

/* returns a set_of_books_id */
function get_set_of_books_id
(
   p_set_of_books_name varchar2
) return number is
   l_id number;
begin
   select sob.set_of_books_id
   into   l_id
   from   gl_sets_of_books sob
   where  sob.name = p_set_of_books_name;
   return(l_id);
exception
when others then
   hr_data_pump.fail('get_set_of_books_id', sqlerrm, p_set_of_books_name);
   raise;
end get_set_of_books_id;

/* returns a tax_unit_id */
function get_tax_unit_id
(
   p_tax_unit_name in varchar2,
   p_effective_date in date
) return varchar2 is
   l_tax_unit_id number;
begin
   select tax.tax_unit_id
   into   l_tax_unit_id
   from   hr_tax_units_v tax
   where  tax.name = p_tax_unit_name;
   return(l_tax_unit_id);
exception
when others then
   hr_data_pump.fail('get_tax_unit_id', sqlerrm, p_tax_unit_name,
                     p_effective_date);
   raise;
end get_tax_unit_id;

/* returns a user_column_id for tax schedule */
function get_work_schedule
(
   p_work_schedule     in varchar2,
   p_organization_name in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
  ,p_language_code     in varchar2
) return number is
   l_id number;
begin
   select puc.user_column_id
   into   l_id
   from   pay_user_columns            puc,
          hr_organization_information hoi,
          hr_all_organization_units    org
   ,      hr_all_organization_units_tl orgtl
   where  orgtl.name                  = p_organization_name
   and    orgtl.language              = p_language_code
   and    org.organization_id         = orgtl.organization_id
   and    org.business_group_id + 0   = p_business_group_id
   and    puc.user_column_name        = p_work_schedule
   and    hoi.org_information_context = 'Work Schedule'
   and    hoi.organization_id         = org.organization_id
   and    (puc.user_table_id = hoi.org_information1 or
           hoi.org_information1 is null);
   return(l_id);
exception
when others then
   hr_data_pump.fail('get_work_schedule', sqlerrm, p_work_schedule,
                     p_organization_name, p_business_group_id,
                     p_effective_date, p_language_code);
   raise;
end get_work_schedule;

/* returns an establishment_id */
function get_eeo_1_establishment_id
(
   p_eeo_1_establishment in varchar2,
   p_business_group_id   in number,
   p_effective_date      in date
) return number is
   l_id number;
begin
   select est.establishment_id
   into   l_id
   from   HR_ESTABLISHMENTS_V est
   where  est.name                  = p_eeo_1_establishment
   and    est.business_group_id + 0 = p_business_group_id;
   return(l_id);
exception
when others then
   hr_data_pump.fail('get_eeo_1_establishment_id', sqlerrm,
                     p_eeo_1_establishment, p_business_group_id,
                     p_effective_date);
   raise;
end get_eeo_1_establishment_id;

/* get_program_application_id - standard who column */
function get_program_application_id return number is
begin
   return(null);
end get_program_application_id;

/* get_program_id - standard who column */
function get_program_id return number is
begin
   return(null);
end get_program_id;

/* get_request_id - standard who column */
function get_request_id return number is
begin
   return(null);
end get_request_id;

/* get_creator_id - standard who column */
function get_creator_id return number is
begin
   return(null);
end get_creator_id;

/* get_id_flex_num - requires user key */
function get_id_flex_num( p_id_flex_num_user_key in varchar2 )
return number is
   l_id_flex_num number;
begin
   l_id_flex_num := user_key_to_id( p_id_flex_num_user_key );
   return(l_id_flex_num);
exception
when others then
   hr_data_pump.fail('get_id_flex_num', sqlerrm, p_id_flex_num_user_key);
   raise;
end get_id_flex_num;

/* get_gr_grade_rule_id */
function get_gr_grade_rule_id
(
   p_grade_name        in varchar2,
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number is
   l_grade_rule_id number;
begin
   select pgr.grade_rule_id
   into   l_grade_rule_id
   from   pay_grade_rules_f pgr,
          per_grades_vl pg,
          pay_rates  pr
   where  pg.name = p_grade_name
   and    pg.business_group_id + 0 = p_business_group_id
   and    pr.name = p_rate_name
   and    pr.business_group_id + 0 = p_business_group_id
   and    pgr.rate_id = pr.rate_id
   and    pgr.grade_or_spinal_point_id = pg.grade_id
   and    pgr.rate_type = 'G'
   and    pgr.business_group_id + 0 = p_business_group_id
   and    p_effective_date between pgr.effective_start_date and
          pgr.effective_end_date;
   return(l_grade_rule_id);
exception
when others then
   hr_data_pump.fail('get_gr_grade_rule_id', sqlerrm, p_grade_name,
                      p_rate_name, p_business_group_id, p_effective_date);
   raise;
end get_gr_grade_rule_id;

/* get_pp_grade_rule_id */
function get_pp_grade_rule_id
(
   p_progression_point in varchar2,
   p_pay_scale         in varchar2,
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number is
   l_grade_rule_id number;
begin
   select pgr.grade_rule_id
   into   l_grade_rule_id
   from   per_parent_spines pps,
          per_spinal_points psp,
          pay_grade_rules_f pgr,
          pay_rates  pr
   where  pps.name = p_pay_scale
   and    pps.business_group_id + 0 = p_business_group_id
   and    psp.spinal_point = p_progression_point
   and    psp.business_group_id + 0 = p_business_group_id
   and    psp.parent_spine_id = pps.parent_spine_id
   and    pr.name = p_rate_name
   and    pr.business_group_id + 0 = p_business_group_id
   and    pgr.rate_id = pr.rate_id
   and    pgr.grade_or_spinal_point_id = psp.spinal_point_id
   and    pgr.rate_type = 'SP'
   and    pgr.business_group_id + 0 = p_business_group_id
   and    p_effective_date between pgr.effective_start_date and
          pgr.effective_end_date;
   return( l_grade_rule_id );
exception
when others then
   hr_data_pump.fail('get_pp_grade_rule_id', sqlerrm, p_progression_point,
                      p_pay_scale, p_rate_name, p_business_group_id,
                      p_effective_date);
   raise;
end get_pp_grade_rule_id;

/* get_ar_grade_rule_id */
function get_ar_grade_rule_id
(
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number is
   l_grade_rule_id number;
begin
   select pgr.grade_rule_id
   into   l_grade_rule_id
   from   pay_grade_rules_f pgr,
          pay_rates  pr
   where  pr.name = p_rate_name
   and    pr.business_group_id + 0 = p_business_group_id
   and    pgr.rate_id = pr.rate_id
   and    pgr.rate_type = 'A'
   and    pgr.business_group_id + 0 = p_business_group_id
   and    p_effective_date between pgr.effective_start_date and
          pgr.effective_end_date;
   return(l_grade_rule_id);
exception
when others then
   hr_data_pump.fail('get_ar_grade_rule_id', sqlerrm,
                      p_rate_name, p_business_group_id, p_effective_date);
   raise;
end get_ar_grade_rule_id;

function get_organization_structure_id
(
   p_name in varchar2,
   p_business_group_id in number
)
return number is
   l_organization_structure_id number;
begin
    select pos.organization_structure_id
    into l_organization_structure_id
    from per_organization_structures pos
    where pos.name = p_name
    and pos.business_group_id + 0 = p_business_group_id;
   return (l_organization_structure_id);
exception
when others then
   hr_data_pump.fail('get_organization_structure_id', sqlerrm, p_name, p_business_group_id);
   raise;
end get_organization_structure_id;

function get_org_str_ver_id
(
p_business_group_id in number,
p_organization_structure_id in number,
p_date_from in date,
p_version_number in number
)
return number is
   l_org_str_ver_id number;
begin
   select osv.org_structure_version_id
   into l_org_str_ver_id
   from per_org_structure_versions osv
   where osv.organization_structure_id = p_organization_structure_id
   and osv.date_from = p_date_from
   and osv.version_number = p_version_number
   and osv.business_group_id + 0 = p_business_group_id;
   return (l_org_str_ver_id);
exception
when others then
   hr_data_pump.fail('get_org_str_ver_id', sqlerrm, p_business_group_id, p_organization_structure_id, p_date_from, p_version_number);
   raise;
end get_org_str_ver_id;

/* get_spinal_point_id */
function get_spinal_point_id
(
   p_progression_point in varchar2,
   p_pay_scale         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number is
   l_spinal_point_id number;
begin
   select psp.spinal_point_id
   into   l_spinal_point_id
   from   per_parent_spines pps,
          per_spinal_points psp
   where  pps.name = p_pay_scale
   and    pps.business_group_id + 0 = p_business_group_id
   and    psp.spinal_point = p_progression_point
   and    psp.business_group_id + 0 = p_business_group_id
   and    psp.parent_spine_id = pps.parent_spine_id;
   return( l_spinal_point_id );
exception
when others then
   hr_data_pump.fail('get_spinal_point_id', sqlerrm, p_progression_point,
                      p_pay_scale, p_business_group_id, p_effective_date);
   raise;
end get_spinal_point_id;

/* get_at_period_of_service_id */
function get_at_period_of_service_id
(
   p_person_user_key   in varchar2,
   p_business_group_id in number
)
return number is
   l_period_of_service_id number;
begin
   select pps.period_of_service_id
   into   l_period_of_service_id
   from   per_periods_of_service pps,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_person_user_key
   and    pps.person_id = key.unique_key_id
   and    pps.business_group_id = p_business_group_id
   and    pps.actual_termination_date is null;
   return(l_period_of_service_id);
exception
when others then
   hr_data_pump.fail('get_at_period_of_service_id', sqlerrm,
                      p_person_user_key, p_business_group_id);
   raise;
end get_at_period_of_service_id;

/* get_fp_period_of_service_id */
function get_fp_period_of_service_id
(
   p_person_user_key   in varchar2,
   p_business_group_id in number
)
return number is
   l_period_of_service_id number;
begin
   select pps.period_of_service_id
   into   l_period_of_service_id
   from   per_periods_of_service pps,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_person_user_key
   and    pps.person_id = key.unique_key_id
   and    pps.business_group_id = p_business_group_id
   and    pps.actual_termination_date is not null
   and    pps.final_process_date is null;
   return(l_period_of_service_id);
exception
when others then
   hr_data_pump.fail('get_fp_period_of_service_id', sqlerrm, p_person_user_key,
                      p_business_group_id);
   raise;
end get_fp_period_of_service_id;

/* Added for 11i,Rvydyana,02-DEC-1999 */
/* get_ut_period_of_service_id */
function get_ut_period_of_service_id
(
   p_person_user_key   in varchar2,
   p_effective_date    in date,
   p_business_group_id in number
)
return number is
   l_eot constant date := to_date('4712/12/31', 'YYYY/MM/DD');
   l_period_of_service_id number;
begin

   select pps.period_of_service_id
   into   l_period_of_service_id
   from   per_periods_of_service pps,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_person_user_key
   and    pps.person_id = key.unique_key_id
   and    pps.business_group_id = p_business_group_id
   and    p_effective_date between pps.date_start and NVL(pps.actual_termination_date,l_eot);
   return(l_period_of_service_id);
exception
when others then
   hr_data_pump.fail('get_ut_period_of_service_id', sqlerrm, p_person_user_key,
                      p_effective_date,p_business_group_id);
   raise;
end get_ut_period_of_service_id;

/* get_special_ceiling_step_id */
function get_special_ceiling_step_id
(
   p_special_ceilin_step_user_key varchar2
)
return number is
   l_special_ceiling_step_id number;
begin
   l_special_ceiling_step_id :=
   user_key_to_id( p_special_ceilin_step_user_key );
   return(l_special_ceiling_step_id);
exception
when others then
   hr_data_pump.fail('get_special_ceiling_step_id', sqlerrm,
                     p_special_ceilin_step_user_key );
   raise;
end get_special_ceiling_step_id;

/* get_default_code_comb_id */
function get_default_code_comb_id
(
   p_default_code_comb_user_key varchar2
)
return number is
   l_default_code_comb_id number;
begin
   l_default_code_comb_id := user_key_to_id( p_default_code_comb_user_key );
   return(l_default_code_comb_id);
exception
when others then
   hr_data_pump.fail('get_default_code_comb_id', sqlerrm,
                     p_default_code_comb_user_key );
   raise;
end get_default_code_comb_id;

/* Added for 11i - Rvydyana - 06-DEC-1999 */
/* get_phone_id - requires user key */
function get_phone_id
(
   p_phone_user_key in varchar2
) return number is
   l_phone_id number;
begin
   l_phone_id := user_key_to_id( p_phone_user_key );
   return(l_phone_id);
exception
when others then
   hr_data_pump.fail('get_phone_id', sqlerrm, p_phone_user_key);
   raise;
end get_phone_id;

/*-------------------------- get_grade_ladder_pgm_id -----------------------*/
function get_grade_ladder_pgm_id
( p_grade_ladder_name  in varchar2
 ,p_business_group_id  in number
 ,p_effective_date     in date
) return number is
  l_grade_ladder_pgm_id number;
begin
  select pgm.pgm_id
  into   l_grade_ladder_pgm_id
  from   ben_pgm_f pgm
  where  pgm.name = p_grade_ladder_name
  and    pgm.pgm_typ_cd = 'GSP'
  and    pgm.business_group_id + 0 = p_business_group_id
  and    p_effective_date
         between pgm.effective_start_date and pgm.effective_end_date;
  return(l_grade_ladder_pgm_id);
exception
  when others then
    hr_data_pump.fail('get_grade_ladder_pgm_id', sqlerrm,
                       p_grade_ladder_name);
    raise;
end get_grade_ladder_pgm_id;
/*---------------------- get_supervisor_assignment_id -----------------------*/
function get_supervisor_assignment_id
/* return supervisor assignment_id - requires user key */
(
   p_svr_assignment_user_key in varchar2
) return number is
   l_supervisor_assignment_id number;
begin
   l_supervisor_assignment_id := get_assignment_id(p_svr_assignment_user_key );
   return(l_supervisor_assignment_id);
exception
when others then
   hr_data_pump.fail('get_supervisor_assignment_id', sqlerrm,
                      p_svr_assignment_user_key);
   raise;
end get_supervisor_assignment_id;

/*--------------------- get_parent_spine_id ----------------------------------*/
function get_parent_spine_id
(
   p_parent_spine      in varchar2
  ,p_business_group_id in number
)
return number is
   l_parent_spine_id number;
begin
   select parent_spine_id
   into   l_parent_spine_id
   from   per_parent_spines
   where  name = p_parent_spine
   and    business_group_id = p_business_group_id;
   return(l_parent_spine_id);
exception
when others then
   hr_data_pump.fail('get_parent_spine_id', sqlerrm, p_parent_spine,
                      p_business_group_id);
   raise;
end get_parent_spine_id;
/*--------------------- get_ceiling_step_id ----------------------------------*/
function get_ceiling_step_id
(
   p_ceiling_point     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number is
   l_ceiling_step_id number;
begin
   select sps.step_id
   into   l_ceiling_step_id
   from   per_spinal_points psp
         ,per_spinal_point_steps_f sps
   where  psp.spinal_point = p_ceiling_point
   and    psp.spinal_point_id = sps.spinal_point_id
   and    sps.business_group_id = p_business_group_id
   and    p_effective_date between
          sps.effective_start_date and sps.effective_end_date;
   return(l_ceiling_step_id);
exception
when others then
   hr_data_pump.fail('get_ceiling_step_id', sqlerrm, p_ceiling_point,
                      p_business_group_id, p_effective_date);
   raise;
end get_ceiling_step_id;

/*---------------------------------------------------------------------------*/
/*------------------- get object version number functions -------------------*/
/*---------------------------------------------------------------------------*/

/*-------------------- get_collective_agreement_ovn ------------------------*/
function get_collective_agreement_ovn
(p_business_group_id in number
,p_cagr_name         in varchar2
,p_effective_date    in date
) return number is
  l_object_version_number number;
begin
  select pc.object_version_number
  into   l_object_version_number
  from   per_collective_agreements pc
  where  pc.business_group_id = p_business_group_id
  and    pc.name = p_cagr_name
  and    p_effective_date between
         nvl(start_date,START_OF_TIME) and nvl(end_date,END_OF_TIME);
  return l_object_version_number;
exception
  when others then
    hr_data_pump.fail('get_collective_agreement_ovn', sqlerrm,
                      p_business_group_id, p_cagr_name, p_effective_date);
    raise;
end get_collective_agreement_ovn;

/*----------------------------- get_contract_ovn ---------------------------*/
function get_contract_ovn
(p_contract_user_key in varchar2
,p_effective_date    in date
) return number is
  l_object_version_number number;
begin
   select pc.object_version_number
   into   l_object_version_number
   from   per_contracts_f              pc,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_contract_user_key
   and    pc.contract_id      = key.unique_key_id
   and    p_effective_date between
          pc.effective_start_date and pc.effective_end_date;
   return(l_object_version_number);
exception
  when others then
    hr_data_pump.fail('get_contract_ovn', sqlerrm, p_contract_user_key);
    raise;
end get_contract_ovn;

/*--------------------------- get_establishment_ovn ---------------------------*/
function get_establishment_ovn
(p_establishment_name in varchar2
,p_location           in varchar2
) return number is
  l_object_version_number number;
begin
  select pe.object_version_number
  into   l_object_version_number
  from   per_establishments pe
  where  pe.location = p_location
  and    pe.name = p_establishment_name;
  return l_object_version_number;
exception
  when others then
    hr_data_pump.fail('get_establishment_ovn', sqlerrm,
                       p_establishment_name, p_location);
    raise;
end get_establishment_ovn;

/* returns a federal tax rule object version number */
function get_us_emp_fed_tax_rule_ovn
(
   p_emp_fed_tax_rule_user_key in varchar2,
   p_effective_date  in date
) return number is
   l_ovn number;
begin
   select rules.object_version_number
   into   l_ovn
   from   pay_us_emp_fed_tax_rules_f   rules,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value           = p_emp_fed_tax_rule_user_key
   and    rules.emp_fed_tax_rule_id    = key.unique_key_id
   and    p_effective_date between
          rules.effective_start_date and rules.effective_end_date;
   return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_us_emp_fed_tax_rule_ovn', sqlerrm,
                    p_emp_fed_tax_rule_user_key, p_effective_date);
  raise;
end get_us_emp_fed_tax_rule_ovn;

/* returns a state tax rule object version number */
function get_us_emp_state_tax_rule_ovn
(
   p_emp_state_tax_rule_user_key in varchar2,
   p_effective_date  in date
) return number is
   l_ovn number;
begin
   select rules.object_version_number
   into   l_ovn
   from   pay_us_emp_state_tax_rules_f   rules,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value           = p_emp_state_tax_rule_user_key
   and    rules.emp_state_tax_rule_id    = key.unique_key_id
   and    p_effective_date between
          rules.effective_start_date and rules.effective_end_date;
   return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_us_emp_state_tax_rule_ovn', sqlerrm,
                    p_emp_state_tax_rule_user_key, p_effective_date);
  raise;
end get_us_emp_state_tax_rule_ovn;

/* returns a county tax rule object version number */
function get_us_emp_county_tax_rule_ovn
(
   p_emp_county_tax_rule_user_key in varchar2,
   p_effective_date  in date
) return number is
   l_ovn number;
begin
   select rules.object_version_number
   into   l_ovn
   from   pay_us_emp_county_tax_rules_f   rules,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value           = p_emp_county_tax_rule_user_key
   and    rules.emp_county_tax_rule_id    = key.unique_key_id
   and    p_effective_date between
          rules.effective_start_date and rules.effective_end_date;
   return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_us_emp_county_tax_rule_ovn', sqlerrm,
                    p_emp_county_tax_rule_user_key, p_effective_date);
  raise;
end get_us_emp_county_tax_rule_ovn;

/* returns a city tax rule object version number */
function get_us_emp_city_tax_rule_ovn
(
   p_emp_city_tax_rule_user_key in varchar2,
   p_effective_date  in date
) return number is
   l_ovn number;
begin
   select rules.object_version_number
   into   l_ovn
   from   pay_us_emp_city_tax_rules_f   rules,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value           = p_emp_city_tax_rule_user_key
   and    rules.emp_city_tax_rule_id    = key.unique_key_id
   and    p_effective_date between
          rules.effective_start_date and rules.effective_end_date;
   return(l_ovn);
exception
when others then
  hr_data_pump.fail('get_us_emp_city_tax_rule_ovn', sqlerrm,
                    p_emp_city_tax_rule_user_key, p_effective_date);
  raise;
end get_us_emp_city_tax_rule_ovn;

/* returns a person object version number */
function get_per_ovn
(
   p_person_user_key in varchar2,
   p_effective_date  in date
) return number is
   l_ovn number;
begin
   select per.object_version_number
   into   l_ovn
   from   per_people_f                 per,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_person_user_key
   and    per.person_id      = key.unique_key_id
   and    p_effective_date between
          per.effective_start_date and per.effective_end_date;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_per_ovn', sqlerrm, p_person_user_key,
                     p_effective_date);
   raise;
end get_per_ovn;

/* returns an assignment object version number */
function get_asg_ovn
(
   p_assignment_user_key in varchar2,
   p_effective_date      in date
) return number is
   l_ovn number;
begin
   select asg.object_version_number
   into   l_ovn
   from   per_assignments_f            asg,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_assignment_user_key
   and    asg.assignment_id  = key.unique_key_id
   and    p_effective_date between
          asg.effective_start_date and asg.effective_end_date;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_asg_ovn', sqlerrm, p_assignment_user_key,
                     p_effective_date);
   raise;
end get_asg_ovn;

/* returns an address object version number */
function get_adr_ovn
(
   p_address_user_key in varchar2,
   p_effective_date   in date
) return number is
   l_ovn number;
begin
   select adr.object_version_number
   into   l_ovn
   from   per_addresses                adr,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_address_user_key
   and    adr.address_id     = key.unique_key_id;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_adr_ovn', sqlerrm, p_address_user_key,
                     p_effective_date);
   raise;
end get_adr_ovn;

/* returns a location object version number */
function get_loc_ovn
(
   p_location_code in varchar2
) return number is
   l_ovn number;
begin
  --
  -- Changed to use hr_locations_all for WWBUG 1833930.
  --
   select loc.object_version_number
   into   l_ovn
   from   hr_locations_all loc
   where  loc.location_code = p_location_code;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_loc_ovn', sqlerrm, p_location_code);
   raise;
end get_loc_ovn;

/* returns a job object version number */
function get_org_str_ovn
(
   p_name          in varchar2,
   p_business_group_id in number
) return number is
   l_ovn number;
begin
   select ors.object_version_number
   into   l_ovn
   from   per_organization_structures ors
   where  ors.name                  = p_name
   and    ors.business_group_id + 0 = p_business_group_id;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_org_str_ovn', sqlerrm, p_name, p_business_group_id);
   raise;
end get_org_str_ovn;

/* returns a organization structure version object version number */
function get_org_str_ver_ovn
(
   p_business_group_id in number,
   p_organization_structure_id in number,
   p_date_from in date,
   p_version_number in number
) return number is
   l_ovn number;
begin
   select osv.object_version_number
   into l_ovn
   from per_org_structure_versions osv
   where osv.organization_structure_id = p_organization_structure_id
   and osv.date_from = p_date_from
   and osv.version_number = p_version_number
   and osv.business_group_id + 0 = p_business_group_id;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_org_str_ver_ovn', sqlerrm, p_business_group_id, p_organization_structure_id, p_date_from, p_version_number);
   raise;
 end get_org_str_ver_ovn;

/* returns an organization object version number */
function get_org_ovn
(
   p_business_group_id in number,
   p_organization_name in varchar2,
   p_language_code in varchar2
) return number is
   l_ovn number;
begin
   select org.object_version_number
   into   l_ovn
   from   hr_all_organization_units org
   ,      hr_all_organization_units_tl orgtl
   where  orgtl.name = p_organization_name
   and    orgtl.language = p_language_code
   and    org.organization_id = orgtl.organization_id
   and    org.business_group_id + 0 = p_business_group_id;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_org_ovn', sqlerrm, p_business_group_id, p_organization_name, p_language_code);
   raise;
end get_org_ovn;

/* returns a job object version number */
function get_job_ovn
(
   p_job_name          in varchar2,
   p_effective_date    in date,
   p_business_group_id in number
) return number is
   l_ovn number;
begin
   select job.object_version_number
   into   l_ovn
   from   per_jobs_vl job
   where  job.name                  = p_job_name
   and    job.business_group_id + 0 = p_business_group_id;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_job_ovn', sqlerrm, p_job_name, p_effective_date,
                     p_business_group_id);
   raise;
end get_job_ovn;

/* returns a position object version number */
function get_pos_ovn
(
   p_position_name     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number is
   l_ovn number;
begin
   select pos.object_version_number
   into   l_ovn
   from   hr_all_positions_f pos
   where  pos.name                  = p_position_name
   and    pos.business_group_id + 0 = p_business_group_id
   and    p_effective_date between
          pos.effective_start_date and pos.effective_end_date;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_pos_ovn', sqlerrm, p_position_name,
                     p_business_group_id, p_effective_date);
   raise;
end get_pos_ovn;

/* returns a personal_payment_method object version number */
function get_ppm_ovn
(
   p_personal_pay_method_user_key in varchar2,
   p_effective_date               in date
) return number is
   l_ovn number;
begin
   select ppm.object_version_number
   into   l_ovn
   from   pay_personal_payment_methods_f ppm
   ,      hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_personal_pay_method_user_key
   and    ppm.personal_payment_method_id = key.unique_key_id
   and    p_effective_date between
          ppm.effective_start_date and ppm.effective_end_date;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_ppm_ovn', sqlerrm,
                     p_personal_pay_method_user_key, p_effective_date);
   raise;
end get_ppm_ovn;

/* get_element_entry_ovn - requires user key */
function get_element_entry_ovn
(
   p_element_entry_user_key in varchar2,
   p_effective_date         in date
) return number is
   l_element_entry_ovn number;
begin
   select pee.object_version_number
   into   l_element_entry_ovn
   from   pay_element_entries_f pee,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value   = p_element_entry_user_key
   and    pee.element_entry_id = key.unique_key_id
   and    p_effective_date between
          pee.effective_start_date and pee.effective_end_date;
   return(l_element_entry_ovn);
exception
when others then
   hr_data_pump.fail('get_element_entry_ovn', sqlerrm, p_element_entry_user_key,                     p_effective_date);
   raise;
end get_element_entry_ovn;

/* get_gr_grade_rule_ovn */
function get_gr_grade_rule_ovn
(
   p_grade_name        in varchar2,
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number is
   l_object_version_number number;
begin
   select pgr.object_version_number
   into   l_object_version_number
   from   pay_grade_rules_f pgr,
          per_grades_vl pg,
          pay_rates  pr
   where  pg.name = p_grade_name
   and    pg.business_group_id + 0 = p_business_group_id
   and    pr.name = p_rate_name
   and    pr.business_group_id + 0 = p_business_group_id
   and    pgr.rate_id = pr.rate_id
   and    pgr.grade_or_spinal_point_id = pg.grade_id
   and    pgr.rate_type = 'G'
   and    pgr.business_group_id + 0 = p_business_group_id
   and    p_effective_date between pgr.effective_start_date and
          pgr.effective_end_date;
   return(l_object_version_number);
exception
when others then
   hr_data_pump.fail('get_gr_grade_rule_ovn', sqlerrm, p_grade_name,
                      p_rate_name, p_business_group_id, p_effective_date);
   raise;
end get_gr_grade_rule_ovn;

/* get_pp_grade_rule_ovn */
function get_pp_grade_rule_ovn
(
   p_progression_point in varchar2,
   p_pay_scale         in varchar2,
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number is
   l_object_version_number number;
begin
   select pgr.object_version_number
   into   l_object_version_number
   from   per_parent_spines pps,
          per_spinal_points psp,
          pay_grade_rules_f pgr,
          pay_rates pr
   where  pps.name = p_pay_scale
   and    pps.business_group_id + 0 = p_business_group_id
   and    psp.spinal_point = p_progression_point
   and    psp.business_group_id + 0 = p_business_group_id
   and    psp.parent_spine_id = pps.parent_spine_id
   and    pr.name = p_rate_name
   and    pr.business_group_id + 0 = p_business_group_id
   and    pgr.rate_id = pr.rate_id
   and    pgr.grade_or_spinal_point_id = psp.spinal_point_id
   and    pgr.rate_type = 'SP'
   and    pgr.business_group_id + 0 = p_business_group_id
   and    p_effective_date between pgr.effective_start_date and
          pgr.effective_end_date;
   return(l_object_version_number);
exception
when others then
   hr_data_pump.fail('get_pp_grade_rule_id', sqlerrm, p_progression_point,
                      p_pay_scale, p_rate_name, p_business_group_id,
                      p_effective_date);
   raise;
end get_pp_grade_rule_ovn;

/* get_at_period_of_service_ovn */
function get_at_period_of_service_ovn
(
   p_person_user_key   in varchar2,
   p_business_group_id in number
)
return number is
   l_object_version_number number;
begin
   select pps.object_version_number
   into   l_object_version_number
   from   per_periods_of_service pps,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_person_user_key
   and    pps.person_id = key.unique_key_id
   and    pps.business_group_id = p_business_group_id
   and    pps.actual_termination_date is null;
   return(l_object_version_number);
exception
when others then
   hr_data_pump.fail('get_at_period_of_service_ovn', sqlerrm, p_person_user_key,
                      p_business_group_id);
   raise;
end get_at_period_of_service_ovn;

/* get_fp_period_of_service_ovn */
function get_fp_period_of_service_ovn
(
   p_person_user_key   in varchar2,
   p_business_group_id in number
)
return number is
   l_object_version_number number;
begin
   select pps.object_version_number
   into   l_object_version_number
   from   per_periods_of_service pps,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_person_user_key
   and    pps.person_id = key.unique_key_id
   and    pps.business_group_id = p_business_group_id
   and    pps.actual_termination_date is not null
   and    pps.final_process_date is null;
   return(l_object_version_number);
exception
when others then
   hr_data_pump.fail('get_fp_period_of_service_ovn', sqlerrm, p_person_user_key,
                      p_business_group_id);
   raise;
end get_fp_period_of_service_ovn;

/* Added for 11i,Rvydyana,02-DEC-1999 */
/* get_ut_period_of_service_ovn */
function get_ut_period_of_service_ovn
(
   p_person_user_key   in varchar2,
   p_effective_date    in date,
   p_business_group_id in number
)
return number is
   l_eot constant date := to_date('4712/12/31', 'YYYY/MM/DD');
   l_object_version_number number;
begin

   select pps.object_version_number
   into   l_object_version_number
   from   per_periods_of_service pps,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_person_user_key
   and    pps.person_id = key.unique_key_id
   and    pps.business_group_id = p_business_group_id
   and    p_effective_date between pps.date_start and NVL(pps.actual_termination_date,l_eot);
   return(l_object_version_number);
exception
when others then
   hr_data_pump.fail('get_ut_period_of_service_id', sqlerrm, p_person_user_key,
                      p_effective_date,p_business_group_id);
   raise;
end get_ut_period_of_service_ovn;

/* get entry_step_id - requires user key */
function get_entry_step_id
(
   p_entry_step_user_key in varchar2
) return number is
   l_entry_step_id number;
begin
   l_entry_step_id := user_key_to_id( p_entry_step_user_key );
   return(l_entry_step_id);
exception
when others then
   hr_data_pump.fail('get_entry_step_id', sqlerrm, p_entry_step_user_key);
   raise;
end get_entry_step_id;

/* get entry_grade_rule_id - requires user key */
function get_entry_grade_rule_id
(
   p_entry_grade_rule_user_key in varchar2
) return number is
   l_entry_grade_rule_id number;
begin
   l_entry_grade_rule_id := user_key_to_id( p_entry_grade_rule_user_key );
   return(l_entry_grade_rule_id);
exception
when others then
   hr_data_pump.fail('get_entry_grade_rule_id', sqlerrm, p_entry_grade_rule_user_key);
   raise;
end get_entry_grade_rule_id;

/* Added for 11i - Rvydyana - 06-DEC-1999 */
/* returns a phone object version number */
function get_phn_ovn
(
   p_phone_user_key in varchar2
) return number is
   l_ovn number;
begin
   select phn.object_version_number
   into   l_ovn
   from   per_phones                 phn,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_phone_user_key
   and    phn.phone_id      = key.unique_key_id;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_phn_ovn', sqlerrm, p_phone_user_key);
   raise;
end get_phn_ovn;
--
/* --------------------------------------------------- */
/* ----------------- get_jgr_ovn---------------------- */
/* --------------------------------------------------- */
function get_jgr_ovn
(
 p_job_group_user_key in varchar2
  ) return number is
l_ovn number;
 begin
    select jgr.object_version_number
    into   l_ovn
    from   per_job_groups jgr,
     hr_pump_batch_line_user_keys key
    where  key.user_key_value = p_job_group_user_key
    and    jgr.job_group_id      = key.unique_key_id;
   return(l_ovn);
   exception
   when others then
   hr_data_pump.fail('get_jgr_ovn', sqlerrm, p_job_group_user_key);
   raise;
end get_jgr_ovn;

/* --------------------------------------------------- */
/* ----------------- get_rol_ovn---------------------- */
/* --------------------------------------------------- */
function get_rol_ovn
(
 p_role_user_key in varchar2
  ) return number is
l_ovn number;
 begin
    select rol.object_version_number
    into   l_ovn
    from   per_roles rol,
     hr_pump_batch_line_user_keys key
    where  key.user_key_value = p_role_user_key
    and    rol.role_id      = key.unique_key_id;
   return(l_ovn);
   exception
   when others then
   hr_data_pump.fail('get_rol_ovn', sqlerrm, p_role_user_key);
   raise;
end get_rol_ovn;
/*-------------- returns a pay scale object version number --------------------*/
function get_pay_scale_ovn
(
   p_pay_scale          in varchar2,
   p_business_group_id  in number
) return number is
   l_ovn number;
begin
   select object_version_number
   into   l_ovn
   from   per_parent_spines
   where  name                  = p_pay_scale
   and    business_group_id + 0 = p_business_group_id;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_pay_scale_ovn', sqlerrm, p_pay_scale,
                     p_business_group_id);
   raise;
end get_pay_scale_ovn;
/*-------------- returns a preogresion point object version number ------------*/
function get_progression_point_ovn
(
   p_point              in varchar2,
   p_business_group_id  in number
) return number is
   l_ovn number;
begin
   select object_version_number
   into   l_ovn
   from   per_spinal_points
   where  spinal_point          = p_point
   and    business_group_id + 0 = p_business_group_id;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_progression_point_ovn', sqlerrm, p_point,
                     p_business_group_id);
   raise;
end get_progression_point_ovn;
/*-------------- returns a grade scale object version number ------------*/
function get_grade_scale_ovn
(
   p_grade              in varchar2,
   p_pay_scale          in varchar2,
   p_effective_date     in date,
   p_business_group_id  in number
) return number is
   l_ovn number;
begin
   select pgs.object_version_number
   into   l_ovn
   from   per_grade_spines_f pgs
         ,per_grades pg
         ,per_parent_spines pps
   where  pg.name = p_grade
   and    pg.grade_id = pgs.grade_id
   and    pps.name = p_pay_scale
   and    pps.parent_spine_id = pgs.parent_spine_id
   and    pgs.business_group_id = p_business_group_id
   and    p_effective_date between
          pgs.effective_start_date and pgs.effective_end_date;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_grade_scale_ovn', sqlerrm, p_grade,
                     p_pay_scale, p_effective_date ,p_business_group_id);
   raise;
end get_grade_scale_ovn;
/*-------------- returns a grade step object version number ------------*/
function get_grade_step_ovn
(
   p_point              in varchar2,
   p_sequence           in number,
   p_effective_date     in date,
   p_business_group_id  in number
) return number is
   l_ovn number;
begin
   select sps.object_version_number
   into   l_ovn
   from   per_spinal_point_steps_f sps
         ,per_spinal_points psp
         ,per_grade_spines_f pgs
   where  psp.spinal_point = p_point
   and    psp.spinal_point_id = sps.spinal_point_id
   and    sps.sequence = p_sequence
   and    sps.step_id =  pgs.ceiling_step_id
   and    pgs.grade_spine_id = sps.grade_spine_id
   and    sps.business_group_id = p_business_group_id
   and    p_effective_date between
          sps.effective_start_date and sps.effective_end_date;
   return(l_ovn);
exception
when others then
   hr_data_pump.fail('get_grade_step_ovn', sqlerrm, p_point,
                     p_sequence,p_effective_date, p_business_group_id);
   raise;
end get_grade_step_ovn;
/*---------------------------------------------------------------------------*/
/*----------------------- other special get functions -----------------------*/
/*---------------------------------------------------------------------------*/

/* returns a language code */
function get_correspondence_language
(
   p_correspondence_language varchar2
) return varchar2 is
   l_code fnd_languages.language_code%type;
begin
   select l.language_code
   into   l_code
   from   fnd_languages l
   where  l.nls_language = p_correspondence_language;
   return(l_code);
exception
-- If the nls_language could not be matched, assume that the user was
-- entering the code directly.
when no_data_found then
   return(p_correspondence_language);
when others then
   hr_data_pump.fail('get_correspondence_language', sqlerrm,
                     p_correspondence_language);
   raise;
end get_correspondence_language;

/* get_country */
function get_country( p_country in varchar2 ) return varchar2 is
   l_territory_code varchar2(2);
begin
   select territory_code
   into   l_territory_code
   from   fnd_territories_vl
   where  territory_short_name = p_country;
   return(l_territory_code);
exception
-- If the short_name could not be matched, assume that the user was
-- entering the code directly.
when no_data_found then
   return(p_country);
when others then
   hr_data_pump.fail('get_country', sqlerrm, p_country );
   raise;
end get_country;

/* get change reason lookup code, dependent on assignment */
function get_change_reason
(
   p_change_reason       in varchar2,
   p_assignment_user_key in varchar2,
   p_effective_date      in date,
   p_language_code       in varchar2
) return varchar2 is
   l_code varchar2(30);
begin
   select flv.lookup_code
   into   l_code
   from   fnd_lookup_values            flv,
          per_assignments_f            asg,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_assignment_user_key
   and    asg.assignment_id  = key.unique_key_id
   and    p_effective_date between
          asg.effective_start_date and asg.effective_end_date
   and    flv.lookup_type    = decode(asg.assignment_type,
                                      'E', 'EMP_ASSIGN_REASON',
                                      'A', 'APL_ASSIGN_REASON')
   and    flv.meaning        = p_change_reason
   and    flv.language            = p_language_code
   and    flv.view_application_id = 3
   and    flv.security_group_id   =
          fnd_global.lookup_security_group
          (flv.lookup_type
          ,flv.view_application_id
          )
   and    p_effective_date between
          nvl(flv.start_date_active, START_OF_TIME) and
          nvl(flv.end_date_active, END_OF_TIME);
   return(l_code);
exception
-- Assume that the user entered the code directly when no data found.
when no_data_found then
   return(p_change_reason);
when others then
   hr_data_pump.fail('get_change_reason', sqlerrm, p_change_reason,
                     p_assignment_user_key, p_effective_date);
   raise;
end get_change_reason;

/* get_job_group_id - requires user key */
function get_job_group_id
(
   p_job_group_user_key in varchar2
) return number is
   l_job_group_id number;
begin
   l_job_group_id := user_key_to_id( p_job_group_user_key );
   return(l_job_group_id);
exception
when others then
   hr_data_pump.fail('get_job_group_id', sqlerrm, p_job_group_user_key);
   raise;
end get_job_group_id;

/* get_benchmark_job_id - requires user key */
function get_benchmark_job_id
(
   p_benchmark_job_user_key in varchar2
) return number is
   l_benchmark_job_id number;
begin
   l_benchmark_job_id := user_key_to_id( p_benchmark_job_user_key );
   return(l_benchmark_job_id);
exception
when others then
   hr_data_pump.fail('get_benchmark_job_id', sqlerrm, p_benchmark_job_user_key);
   raise;
end get_benchmark_job_id;

/* get_role_id - requires user key */
function get_role_id
(
   p_role_user_key in varchar2
) return number is
   l_role_id number;
begin
   l_role_id := user_key_to_id( p_role_user_key );
   return(l_role_id);
exception
when others then
   hr_data_pump.fail('get_role_id', sqlerrm, p_role_user_key);
   raise;
end get_role_id;

/* get_loc_id - requires user key */
function get_loc_id
(
   p_location_user_key in varchar2
) return number is
   l_location_id number;
begin
   l_location_id := user_key_to_id( p_location_user_key );
   return(l_location_id);
exception
when others then
   hr_data_pump.fail('get_loc_id', sqlerrm, p_location_user_key);
   raise;
end get_loc_id;

/* get_org_structure_id - requires user key */
function get_org_structure_id
(
   p_org_structure_user_key in varchar2
) return number is
   l_organization_structure_id number;
begin
   l_organization_structure_id := user_key_to_id( p_org_structure_user_key );
   return(l_organization_structure_id);
exception
when others then
   hr_data_pump.fail('get_org_structure_id', sqlerrm, p_org_structure_user_key);
   raise;
end get_org_structure_id;

/* get_org_str_version_id - requires user key */
function get_org_str_version_id
(
   p_org_str_version_user_key in varchar2
) return number is
   l_org_structure_version_id number;
begin
   l_org_structure_version_id := user_key_to_id( p_org_str_version_user_key );
   return(l_org_structure_version_id);
exception
when others then
   hr_data_pump.fail('get_org_str_version_id', sqlerrm, p_org_str_version_user_key);
   raise;
end get_org_str_version_id;

/* get_org_id - requires user key */
function get_org_id
(
   p_org_user_key in varchar2
) return number is
   l_org_id number;
begin
   l_org_id := user_key_to_id( p_org_user_key );
   return(l_org_id);
exception
when others then
   hr_data_pump.fail('get_org_id', sqlerrm, p_org_user_key);
   raise;
end get_org_id;

/* get_grade_rule_id - requires user key */
function get_grade_rule_id
(
   p_grade_rule_user_key in varchar2
) return number is
   l_grade_rule_id number;
begin
   l_grade_rule_id := user_key_to_id( p_grade_rule_user_key );
   return(l_grade_rule_id);
exception
when others then
   hr_data_pump.fail('get_grade_rule_id', sqlerrm, p_grade_rule_user_key);
   raise;
end get_grade_rule_id;

/* returns lookup_code */
function gl
(
   p_meaning_or_code in varchar2,
   p_lookup_type     in varchar2,
   p_effective_date  in date     default null,
   p_language_code   in varchar2 default null
) return varchar2 is
   l_code hr_lookups.lookup_code%type;
   l_effective_date date;
   l_language_code  varchar2(2000);
begin
   --
   -- Is lookup checking disabled ?
   --
   if hr_data_pump.g_disable_lookup_checks then
     return p_meaning_or_code;
   end if;
   --
   -- Set language code (handling possible defaults).
   --
   if p_language_code = hr_api.g_varchar2 then
     --
     -- nvl() in the query will take care of defaulting.
     --
     l_language_code := null;
   else
     l_language_code := p_language_code;
   end if;
   --
   -- Set the effective date (handling possible defaults).
   --
   if p_effective_date is null or p_effective_date = hr_api.g_date then
     l_effective_date := hr_api.g_sys;
   else
     l_effective_date := p_effective_date;
   end if;
   if p_meaning_or_code is null or p_meaning_or_code = hr_api.g_varchar2
   then
     --
     -- Defaulted values will be returned unchanged.
     --
     l_code := p_meaning_or_code;
   else
     --
     -- Check against meaning using the new R11.5 lookup tables.
     --
     select flv.lookup_code
     into   l_code
     from   fnd_lookup_values flv
     where  flv.meaning       = p_meaning_or_code
     and    flv.lookup_type   = p_lookup_type
     and    flv.language      = nvl(l_language_code, userenv('LANG'))
     and    flv.view_application_id = 3
     and    flv.security_group_id   =
     fnd_global.lookup_security_group
     (flv.lookup_type
     ,flv.view_application_id
     )
     and    l_effective_date between
            nvl(flv.start_date_active, START_OF_TIME) and
            nvl(flv.end_date_active, END_OF_TIME);
   end if;
   --
   return(l_code);
exception
  when no_data_found then
    --
    -- If the meaning could not be matched, assume that the user
    -- entered the code directly. This part of the code used to
    -- check against HR_LOOKUPS, but HR_LOOKUPS requires the
    -- legislation context to be set in HR_SESSION_DATA now.
    -- Such an additional check is unnecessary because the API
    -- should be able to pick up bad code values.
    --
    return(p_meaning_or_code);
  when others then
    hr_data_pump.fail
    ('get_lookup_code', sqlerrm, p_meaning_or_code,
    p_lookup_type, p_effective_date, p_language_code);
    raise;
end gl;

function get_lookup_code
(
   p_meaning_or_code in varchar2,
   p_lookup_type     in varchar2,
   p_effective_date  in date     default null,
   p_language_code   in varchar2 default null
) return varchar2 is
begin
  return gl( p_meaning_or_code, p_lookup_type, p_effective_date,
             p_language_code );
end get_lookup_code;
/* return people_group_id */
function get_people_group_id
(
   p_people_group_user_name in varchar2,
   p_effective_date    in date
) return number is
   l_people_group_id number;
begin
   --
   select people_group_id
   into   l_people_group_id
   from   pay_people_groups
   where  GROUP_NAME = p_people_group_user_name
     and  p_effective_date
          between nvl(start_date_active,START_OF_TIME)
          and     nvl(end_date_active,END_OF_TIME);
   --
   return(l_people_group_id);
exception
when others then
   hr_data_pump.fail('get_people_group_id', sqlerrm,
                     p_people_group_user_name,
                     p_effective_date);
   raise;
end get_people_group_id;

/* return absence_attendance_type_id */
function get_absence_attendance_type_id
(
   p_aat_user_name     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number is
   l_absence_attendance_type_id number;
begin
   --
   select aat.absence_attendance_type_id
   into   l_absence_attendance_type_id
   from per_abs_attendance_types_vl aat
   where aat.name = p_aat_user_name
     and aat.business_group_id = p_business_group_id
     and p_effective_date between
         nvl(DATE_EFFECTIVE, START_OF_TIME) AND
         nvl(DATE_END, END_OF_TIME);
   --
   return(l_absence_attendance_type_id);
exception
when others then
   hr_data_pump.fail('get_absence_attendance_type_id', sqlerrm,
                     p_aat_user_name,
                     p_business_group_id,
                     p_effective_date);
   raise;
end get_absence_attendance_type_id;
/* return soft_coding_keyflex_id */
function get_soft_coding_keyflex_id
(
   p_con_seg_user_name     in varchar2,
   p_effective_date    in date
) return number is
   l_soft_coding_keyflex_id number;
begin
   --
   select soft_coding_keyflex_id
   into   l_soft_coding_keyflex_id
   from hr_soft_coding_keyflex
   where concatenated_segments = p_con_seg_user_name
     and p_effective_date between
         nvl(START_DATE_ACTIVE, START_OF_TIME) AND
         nvl(END_DATE_ACTIVE, END_OF_TIME);
   --
   return(l_soft_coding_keyflex_id);
exception
when others then
   hr_data_pump.fail('get_soft_coding_keyflex_id', sqlerrm,
                     p_con_seg_user_name,
                     p_effective_date);
   raise;
end get_soft_coding_keyflex_id;

/* return pk_id */
function get_pk_id
(
   p_pk_name           in varchar2
) return number is
   l_pk_id number := null;
begin
   --
   -- This column should not be populated by datapump.
   --
   return(l_pk_id);
exception
when others then
   hr_data_pump.fail('get_pk_id', sqlerrm,
                     p_pk_name
                     );
   raise;
end get_pk_id;

/* Bug 3275173 -- get object versionn number*/
function get_fed_tax_rule_ovn
(
  p_emp_fed_tax_rule_user_key in varchar2,
  p_effective_date            in date
) return number is
  l_ovn number;
begin
  select object_version_number
    into l_ovn
    from pay_us_emp_fed_tax_rules_f puek,
         hr_pump_batch_line_user_keys uk
   where uk.user_key_value = p_emp_fed_tax_rule_user_key
     and p_effective_date between puek.effective_start_date and puek.effective_end_date
     and puek.emp_fed_tax_rule_id  = uk.unique_key_id;
   --

   return l_ovn;
exception
when others then
   hr_data_pump.fail('get_fed_tax_rule_ovn', sqlerrm,
                     p_emp_fed_tax_rule_user_key,
                     p_effective_date);
   raise;
end get_fed_tax_rule_ovn;

--
-- Bug 3783381 -- get object versionn number for state, county and city
--

function get_state_tax_rule_ovn
(
  p_emp_state_tax_rule_user_key in varchar2,
  p_effective_date            in date
) return number is
  l_ovn number;
begin
  select object_version_number
    into l_ovn
    from pay_us_emp_state_tax_rules_f puek,
         hr_pump_batch_line_user_keys uk
   where uk.user_key_value = p_emp_state_tax_rule_user_key
     and p_effective_date between puek.effective_start_date and puek.effective_end_date
     and puek.emp_state_tax_rule_id  = uk.unique_key_id;
   --

   return l_ovn;
exception
when others then
   hr_data_pump.fail('get_state_tax_rule_ovn', sqlerrm,
                     p_emp_state_tax_rule_user_key,
                     p_effective_date);
   raise;
end get_state_tax_rule_ovn;

---
function get_county_tax_rule_ovn
(
  p_emp_county_tax_rule_user_key in varchar2,
  p_effective_date            in date
) return number is
  l_ovn number;
begin
  select object_version_number
    into l_ovn
    from pay_us_emp_county_tax_rules_f puek,
         hr_pump_batch_line_user_keys uk
   where uk.user_key_value = p_emp_county_tax_rule_user_key
     and p_effective_date between puek.effective_start_date and puek.effective_end_date
     and puek.emp_county_tax_rule_id  = uk.unique_key_id;
   --

   return l_ovn;
exception
when others then
   hr_data_pump.fail('get_county_tax_rule_ovn', sqlerrm,
                     p_emp_county_tax_rule_user_key,
                     p_effective_date);
   raise;
end get_county_tax_rule_ovn;

---

function get_city_tax_rule_ovn
(
  p_emp_city_tax_rule_user_key in varchar2,
  p_effective_date            in date
) return number is
  l_ovn number;
begin
  select object_version_number
    into l_ovn
    from pay_us_emp_city_tax_rules_f puek,
         hr_pump_batch_line_user_keys uk
   where uk.user_key_value = p_emp_city_tax_rule_user_key
     and p_effective_date between puek.effective_start_date and puek.effective_end_date
     and puek.emp_city_tax_rule_id  = uk.unique_key_id;
   --

   return l_ovn;
exception
when others then
   hr_data_pump.fail('get_city_tax_rule_ovn', sqlerrm,
                     p_emp_city_tax_rule_user_key,
                     p_effective_date);
   raise;
end get_city_tax_rule_ovn;

--
--

--
-- -------------------------------------------------------------------------
-- ------------< get_parent_comp_element_id >-------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_parent_comp_element_id
RETURN BINARY_INTEGER
IS
BEGIN
  return (null);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_parent_comp_element_id'
		    , sqlerrm
		    );
   RAISE;
END get_parent_comp_element_id;
-- -------------------------------------------------------------------------
-- --------------------< get_competence_id >--------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_competence_id
  (p_data_pump_always_call IN varchar2
  ,p_competence_name    IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
 l_competence_id  NUMBER DEFAULT null;
BEGIN

   IF p_competence_name is NULL then

     return null;

   ELSIF p_competence_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF p_business_group_id is null THEN

       SELECT competence_id
       INTO   l_competence_id
       FROM   per_competences_vl
       WHERE  name = p_competence_name
       AND    business_group_id is null;

     ELSE

       SELECT competence_id
       INTO   l_competence_id
       FROM   per_competences_vl
       WHERE  name = p_competence_name
       AND    business_group_id = p_business_group_id;

     END IF;

   END IF;

   RETURN(l_competence_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_competence_id'
		    , sqlerrm
		    , p_competence_name
		    , p_business_group_id);
   RAISE;
END get_competence_id;
-- -------------------------------------------------------------------------
-- --------------------< get_cpn_ovn >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the ovn of a competence
--
FUNCTION get_cpn_ovn
  (p_data_pump_always_call IN varchar2
  ,p_competence_name    IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER
IS
 l_cpn_ovn  NUMBER DEFAULT null;
BEGIN

   IF p_competence_name is NULL then

     return null;

   ELSIF p_competence_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     IF p_business_group_id is null THEN

       SELECT object_version_number
       INTO   l_cpn_ovn
       FROM   per_competences_vl
       WHERE  name = p_competence_name
       AND    business_group_id is null;

     ELSE

       SELECT object_version_number
       INTO   l_cpn_ovn
       FROM   per_competences_vl
       WHERE  name = p_competence_name
       AND    business_group_id = p_business_group_id;

     END IF;

   END IF;

   RETURN(l_cpn_ovn);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_cpn_ovn'
		    , sqlerrm
		    , p_competence_name
		    , p_business_group_id);
   RAISE;
END get_cpn_ovn;
-- -------------------------------------------------------------------------
-- -----------------< get_qualification_type_id >---------------------------
-- -------------------------------------------------------------------------
FUNCTION get_qualification_type_id
  (p_data_pump_always_call      IN varchar2
  ,p_qualification_type_name    IN VARCHAR2
  )
RETURN BINARY_INTEGER
IS
 l_qualification_type_id  NUMBER DEFAULT null;
BEGIN

   IF p_qualification_type_name is NULL then

     return null;

   ELSIF p_qualification_type_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

       SELECT qualification_type_id
       INTO   l_qualification_type_id
       FROM   per_qualification_types_vl
       WHERE  name = p_qualification_type_name;

   END IF;

   RETURN(l_qualification_type_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_qualification_type_id'
		    , sqlerrm
		    , p_qualification_type_name);
   RAISE;
END get_qualification_type_id;
--
-- -------------------------------------------------------------------------
-- ---------------------< get_outcome_id >--------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_outcome_id
  (p_data_pump_always_call      IN varchar2
  ,p_outcome_name               IN VARCHAR2
  )
RETURN BINARY_INTEGER
IS
 l_outcome_id  NUMBER DEFAULT null;
BEGIN

   IF p_outcome_name is NULL then

     return null;

   ELSIF p_outcome_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

       SELECT outcome_id
       INTO   l_outcome_id
       FROM   per_competence_outcomes_vl
       WHERE  name = p_outcome_name;

   END IF;

   RETURN(l_outcome_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_outcome_id'
		    , sqlerrm
		    , p_outcome_name
                    );
   RAISE;
END get_outcome_id;
-- -------------------------------------------------------------------------
-- --------------------< get_cpo_ovn >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the ovn of a competence outcome
--
FUNCTION get_cpo_ovn
  (p_data_pump_always_call    IN varchar2
  ,p_outcome_name             IN VARCHAR2
  )
RETURN BINARY_INTEGER
IS
 l_cpo_ovn  NUMBER DEFAULT null;
BEGIN

   IF p_outcome_name is NULL then

     return null;

   ELSIF p_outcome_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

       SELECT object_version_number
       INTO   l_cpo_ovn
       FROM   per_competence_outcomes_vl
       WHERE  name = p_outcome_name;

   END IF;

   RETURN(l_cpo_ovn);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_cpo_ovn'
		    , sqlerrm
		    , p_outcome_name
                    );
   RAISE;
END get_cpo_ovn;
-- -------------------------------------------------------------------------
-- --------------------< get_eqt_ovn >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the ovn of a qualification type
--
FUNCTION get_eqt_ovn
  (p_data_pump_always_call    IN varchar2
  ,p_qualification_type_name  IN VARCHAR2
  )
RETURN BINARY_INTEGER
IS
 l_eqt_ovn  NUMBER DEFAULT null;
BEGIN

   IF p_qualification_type_name is NULL then

     return null;

   ELSIF p_qualification_type_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

       SELECT object_version_number
       INTO   l_eqt_ovn
       FROM   per_qualification_types_vl
       WHERE  name = p_qualification_type_name;

   END IF;

   RETURN(l_eqt_ovn);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_eqt_ovn'
		    , sqlerrm
		    , p_qualification_type_name
                    );
   RAISE;
END get_eqt_ovn;
-- -------------------------------------------------------------------------
-- --------------------< get_ceo_ovn >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the ovn of a comp element outcomes
--
FUNCTION get_ceo_ovn
  (p_data_pump_always_call    IN varchar2
  ,p_element_outcome_name     IN VARCHAR2
  )
RETURN BINARY_INTEGER
IS
 l_ceo_ovn  NUMBER DEFAULT null;
BEGIN

   IF p_element_outcome_name is NULL then

     return null;

   ELSIF p_element_outcome_name  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

       SELECT object_version_number
       INTO   l_ceo_ovn
       FROM   per_comp_element_outcomes_vl
       WHERE  name = p_element_outcome_name;

   END IF;

   RETURN(l_ceo_ovn);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_ceo_ovn'
		    , sqlerrm
		    , p_element_outcome_name
                    );
   RAISE;
END get_ceo_ovn;
-- -------------------------------------------------------------------------
-- ------------------< get_competence_element_id >------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the ovn of a comp element outcomes
--
FUNCTION get_competence_element_id
(p_data_pump_always_call in varchar2
,p_competence_name       in varchar2
,p_person_user_key       in varchar2
,p_business_group_id     in number
)
return binary_integer
IS
  l_competence_element_id number default null;
  l_person_id             number default null;
BEGIN

    l_person_id := user_key_to_id(p_person_user_key);

    SELECT competence_element_id
    INTO   l_competence_element_id
    FROM  per_competence_elements CEL
         ,per_competences         CPN
    WHERE
          CEL.type = 'PERSONAL'
    and   CPN.name = p_competence_name
    and   CEL.competence_id = CPN.competence_id
    and   CEL.business_group_id = p_business_group_id
    and   CEL.person_id = l_person_id;

  RETURN(l_competence_element_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_competence_element_id'
		    , sqlerrm
		    , p_competence_name
                    , p_person_user_key
                    , p_business_group_id
                    );
   RAISE;
END get_competence_element_id;
--
--
FUNCTION get_cost_flex_stru_num
  (p_data_pump_always_call IN varchar2
  ,p_cost_flex_stru_code   IN VARCHAR2
  )
RETURN BINARY_INTEGER is
  l_cost_code number;
begin

   IF p_cost_flex_stru_code is NULL then

     return null;

   ELSIF p_cost_flex_stru_code  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

      select id_flex_num into l_cost_code
      from fnd_id_flex_structures
      where id_flex_structure_code = p_cost_flex_stru_code
      and   id_flex_code ='COST';
   END IF;

   RETURN(l_cost_code);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_cost_flex_stru_num'
		    , sqlerrm
 		    , p_cost_flex_stru_code
                    );
   RAISE;
END get_cost_flex_stru_num;
--
FUNCTION get_grade_flex_stru_num
  (p_data_pump_always_call      IN varchar2
  ,p_grade_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER is
  l_grade_code number;
begin

   IF p_grade_flex_stru_code is NULL then

     return null;

   ELSIF p_grade_flex_stru_code  = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE
      select id_flex_num into l_grade_code
      from fnd_id_flex_structures
      where id_flex_structure_code = p_grade_flex_stru_code
      and   id_flex_code ='GRD';

   END IF;

   RETURN(l_grade_code);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_grade_flex_stru_num'
		    , sqlerrm
 		    , p_grade_flex_stru_code
                    );
   RAISE;
END get_grade_flex_stru_num;
--
FUNCTION get_job_flex_stru_num
  (p_data_pump_always_call      IN varchar2
  ,p_job_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER is
  l_job_code number;
begin

   IF p_job_flex_stru_code is NULL then

     return null;

   ELSIF p_job_flex_stru_code = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

      select id_flex_num into l_job_code
      from fnd_id_flex_structures
      where id_flex_structure_code = p_job_flex_stru_code
      and   id_flex_code ='JOB';
   END IF;

   RETURN(l_job_code);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_job_flex_stru_num'
		    , sqlerrm
 		    , p_job_flex_stru_code
                    );
   RAISE;
END get_job_flex_stru_num;
--
FUNCTION get_position_flex_stru_num
  (p_data_pump_always_call      IN varchar2
  ,p_position_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER is
  l_position_code number;
begin

   IF p_position_flex_stru_code is NULL then

     return null;

   ELSIF p_position_flex_stru_code = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

      select id_flex_num into l_position_code
      from fnd_id_flex_structures
      where id_flex_structure_code = p_position_flex_stru_code
      and   id_flex_code ='POS';
   END IF;

   RETURN(l_position_code);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_position_flex_stru_num'
		    , sqlerrm
 		    , p_position_flex_stru_code
                    );
   RAISE;
END get_position_flex_stru_num;
--
FUNCTION get_group_flex_stru_num
  (p_data_pump_always_call      IN varchar2
  ,p_group_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER is
  l_group_code number;
begin

   IF p_group_flex_stru_code is NULL then

     return null;

   ELSIF p_group_flex_stru_code = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

      select id_flex_num into l_group_code
      from fnd_id_flex_structures
      where id_flex_structure_code = p_group_flex_stru_code
      and   id_flex_code ='GRP';
   END IF;

   RETURN(l_group_code);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_group_flex_stru_num'
		    , sqlerrm
 		    , p_group_flex_stru_code
                    );
   RAISE;
END get_group_flex_stru_num;
--
FUNCTION get_competence_flex_stru_num
  (p_data_pump_always_call      IN varchar2
  ,p_competence_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER is
  l_competence_code number;
begin

   IF p_competence_flex_stru_code is NULL then

     return null;

   ELSIF p_competence_flex_stru_code = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

      select id_flex_num into l_competence_code
      from fnd_id_flex_structures
      where id_flex_structure_code = p_competence_flex_stru_code
      and   id_flex_code ='CMP';
   END IF;

   RETURN(l_competence_code);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_competence_flex_stru_num'
		    , sqlerrm
 		    , p_competence_flex_stru_code
                    );
   RAISE;
END get_competence_flex_stru_num;
--
--
FUNCTION get_sec_group_id
  (p_data_pump_always_call      IN varchar2
  ,p_security_group_name  IN VARCHAR2
  )
RETURN BINARY_INTEGER is
  l_get_sec_group_id number;
begin

   IF p_security_group_name is NULL then

     return null;

   ELSIF p_security_group_name = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

      select security_group_id into l_get_sec_group_id
      from fnd_security_groups_tl
      where upper(security_group_name) = upper(p_security_group_name)
      and   language = userenv('LANG');

   END IF;

   RETURN(l_get_sec_group_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_sec_group_id'
		    , sqlerrm
 		    , p_security_group_name
                    );
   RAISE;
END get_sec_group_id;
--
FUNCTION get_security_profile_id
  (p_data_pump_always_call IN VARCHAR2
  ,p_security_profile_name IN VARCHAR2
  ,p_business_group_id     IN NUMBER
  )
RETURN BINARY_INTEGER is
  l_sec_profile_id number;
begin

   IF p_security_profile_name is NULL then

     return null;

   ELSIF p_security_profile_name = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

      select security_profile_id into l_sec_profile_id
      from per_security_profiles
      where upper(security_profile_name) = upper(p_security_profile_name)
      and   business_group_id            = p_business_group_id;

   END IF;

   RETURN(l_sec_profile_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_security_profile_id'
		    , sqlerrm
 		    , p_security_profile_name
                    , p_business_group_id
                    );
   RAISE;
END get_security_profile_id;
--
--
FUNCTION get_parent_organization_id
  ( p_parent_organization_name in varchar2,
    p_business_group_id in number,
    p_effective_date    in date,
    p_language_code     in varchar2
  ) RETURN BINARY_INTEGER is
   l_organization_id number;
BEGIN
   IF p_parent_organization_name is NULL then

     return null;

   ELSIF p_parent_organization_name = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE

     select org.organization_id
     into   l_organization_id
     from   hr_all_organization_units org
     ,      hr_all_organization_units_tl orgtl
     where  orgtl.name = p_parent_organization_name
     and    orgtl.language = p_language_code
     and    org.organization_id = orgtl.organization_id
     and   (org.business_group_id = p_business_group_id
            or p_business_group_id is null);   --Bug 3823374
   END IF;
   return(l_organization_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_parent_organization_id', sqlerrm, p_parent_organization_name,
                     p_business_group_id, p_effective_date, p_language_code);
   raise;
end get_parent_organization_id;
--
--
FUNCTION get_child_organization_id
  (  p_child_organization_name in varchar2,
     p_business_group_id in number,
     p_effective_date    in date,
     p_language_code     in varchar2
  ) RETURN BINARY_INTEGER is
   l_organization_id number;
BEGIN
   IF p_child_organization_name is NULL then

     return null;

   ELSIF p_child_organization_name = hr_api_g_varchar2 then

     return hr_api_g_number;

   ELSE
     select org.organization_id
     into   l_organization_id
     from   hr_all_organization_units org
     ,      hr_all_organization_units_tl orgtl
     where  orgtl.name = p_child_organization_name
     and    orgtl.language = p_language_code
     and    org.organization_id = orgtl.organization_id
     and   (org.business_group_id = p_business_group_id
            or p_business_group_id is null);    --Bug fix 3823374
   END IF;
   --
   return(l_organization_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_child_organization_id', sqlerrm, p_child_organization_name,
                     p_business_group_id, p_effective_date, p_language_code);
   raise;
end get_child_organization_id;
--
--
function get_person_extra_info_id
(
   p_person_extra_info_user_key in varchar2
) return number is
   l_person_extra_info_id number;
begin
   l_person_extra_info_id := user_key_to_id( p_person_extra_info_user_key );
   return(l_person_extra_info_id);
exception
when others then
   hr_data_pump.fail('get_person_extra_info_id', sqlerrm, p_person_extra_info_user_key);
   raise;
end get_person_extra_info_id;
--
--
function get_person_extra_info_ovn
( p_person_extra_info_user_key    in varchar2
) return number is
  l_ovn number;
begin
   select pei.object_version_number
   into   l_ovn
   from   per_people_extra_info  pei,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value       = p_person_extra_info_user_key
   and    pei.person_extra_info_id  = key.unique_key_id;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail('get_person_extra_info_ovn', sqlerrm, p_person_extra_info_user_key);
    raise;
end get_person_extra_info_ovn;

--
--
/* GET_EMP_FED_TAX_INF_ID - requires user key */
function GET_EMP_FED_TAX_INF_ID
(
   P_EMP_FED_TAX_INF_USER_KEY in varchar2
) return number is
   l_emp_fed_tax_inf_id number;
begin
   l_emp_fed_tax_inf_id := user_key_to_id( P_EMP_FED_TAX_INF_USER_KEY );
   return(l_emp_fed_tax_inf_id);
exception
when others then
   hr_data_pump.fail('GET_EMP_FED_TAX_INF_ID', sqlerrm, P_EMP_FED_TAX_INF_USER_KEY);
   raise;
end GET_EMP_FED_TAX_INF_ID;


--
/* returns a Canada Employee federal tax Inf object version number */
function GET_CA_EMP_FEDTAX_INF_OVN
(
   P_EMP_FED_TAX_INF_USER_KEY in varchar2,
   p_effective_date  in date
) return number is
   l_ovn number;
begin
   select rules.object_version_number
   into   l_ovn
   from   PAY_CA_EMP_FED_TAX_INFO_F   rules,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value           = P_EMP_FED_TAX_INF_USER_KEY
   and    rules.EMP_FED_TAX_INF_ID    = key.unique_key_id
   and    p_effective_date between
          rules.effective_start_date and rules.effective_end_date;
   return(l_ovn);
exception
when others then
  hr_data_pump.fail('GET_CA_EMP_FEDTAX_INF_OVN', sqlerrm,
                    P_EMP_FED_TAX_INF_USER_KEY, p_effective_date);
  raise;
end GET_CA_EMP_FEDTAX_INF_OVN;

--
--
/* GET_EMP_PROVINCE_TAX_INF_ID - requires user key */
function GET_EMP_PROVINCE_TAX_INF_ID
(
   P_EMP_PROV_TAX_INF_USER_KEY in varchar2
) return number is
   l_emp_prov_tax_inf_id number;
begin
   l_emp_prov_tax_inf_id := user_key_to_id( P_EMP_PROV_TAX_INF_USER_KEY );
   return(l_emp_prov_tax_inf_id);
exception
when others then
   hr_data_pump.fail('GET_EMP_PROVINCE_TAX_INF_ID', sqlerrm, P_EMP_PROV_TAX_INF_USER_KEY);
   raise;
end GET_EMP_PROVINCE_TAX_INF_ID;


--
/* returns a Canada Employee federal tax Inf object version number */
function GET_CA_EMP_PRVTAX_INF_OVN
(
   P_EMP_PROV_TAX_INF_USER_KEY in varchar2,
   p_effective_date  in date
) return number is
   l_ovn number;
begin
   select rules.object_version_number
   into   l_ovn
   from   PAY_CA_EMP_PROV_TAX_INFO_F   rules,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value           = P_EMP_PROV_TAX_INF_USER_KEY
   and    rules.EMP_PROVINCE_TAX_INF_ID    = key.unique_key_id
   and    p_effective_date between
          rules.effective_start_date and rules.effective_end_date;
   return(l_ovn);
exception
when others then
  hr_data_pump.fail('GET_CA_EMP_PRVTAX_INF_OVN', sqlerrm,
                    P_EMP_PROV_TAX_INF_USER_KEY, p_effective_date);
  raise;
end GET_CA_EMP_PRVTAX_INF_OVN;


--
/*
 *  Get ID initialisation section.
 */
begin
   -- Initialise the debugging information structure.
   null;

end hr_pump_get;

/
