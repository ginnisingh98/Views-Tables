--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_TYPES_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_TYPES_DATA_PUMP" AS
/* $Header: pybltdpm.pkb 120.0 2005/05/29 03:20:59 appldev noship $ */

------------------------------ user_key_to_id ---------------------------------
--
-- Returns an ID value from hr_pump_batch_line_user_keys alone.
-- Utility function to get _ID functions.
--
Function user_key_to_id(p_user_key_value in varchar2)
  return number is
   l_id number;
Begin
   select unique_key_id
   into   l_id
   from   hr_pump_batch_line_user_keys
   where  user_key_value = p_user_key_value;
   return(l_id);
End user_key_to_id;
--

----------------------------- get_balance_category_id -----------------------------
--
-- Returns the balance_category id
--
Function get_balance_category_id
  (p_effective_date  	          in date
  ,p_business_group_id            in number
  ,p_category_name                in varchar2
  ) return number is
--
 l_balance_category_id    pay_balance_types.balance_category_id%type;
--
Begin
  select balance_category_id
    into l_balance_category_id
     from pay_balance_categories_f
    where category_name = p_category_name
    and nvl(business_group_id, nvl(p_business_group_id,-1))
                         = nvl(p_business_group_id,-1)
    and nvl(legislation_code, nvl(hr_api.return_legislation_code(p_business_group_id),' '))
                        = nvl(hr_api.return_legislation_code(p_business_group_id),' ')
    and p_effective_date between effective_start_date
                                     and effective_end_date;

  --
  return (l_balance_category_id);
Exception
when others then
   hr_data_pump.fail('get_balance_category_id', sqlerrm, p_category_name,
                     p_business_group_id,p_effective_date);
   raise;
End get_balance_category_id;
--
------------------------------get_base_balance_type_id------------------------------------
--
--  Return the formula id.
--

Function get_base_balance_type_id( p_base_balance_Name      in varchar2,
  	  	                   p_business_group_id in  number
                                 ) return number is

l_balance_type_id number ;

Begin

  select balance_type_id
    into l_balance_type_id
   from pay_balance_types
  where base_balance_type_id is null
    and balance_name = p_base_balance_name
    and nvl(business_group_id, nvl(p_business_group_id,-1))
                         = nvl(p_business_group_id,-1)
    and nvl(legislation_code, nvl(hr_api.return_legislation_code(p_business_group_id),' '))
                        = nvl(hr_api.return_legislation_code(p_business_group_id),' ');

 RETURN(l_balance_type_id);

Exception
  When OTHERS Then
     hr_data_pump.fail('get_base_balance_type_id', sqlerrm, p_base_balance_Name,
              	        p_business_group_id);
       RAISE;
End get_base_balance_type_id;
--
-----------------------------get_input_value_id-----------------------------

Function get_input_value_id (p_element_name      in varchar2,
                             p_input_name   in varchar2,
                             p_business_group_id in number,
                             p_effective_date    in date,
                             p_language_code     in varchar2
                            ) return number is

  l_input_value_id   number;

Begin

  l_input_value_id  := hr_pump_get.get_input_value_id
                                        (p_input_name,
                                         p_element_name ,
                                         p_business_group_id ,
                                         p_effective_date ,
                                         p_language_code );

  return(l_input_value_id);

Exception
    When OTHERS Then
    hr_data_pump.fail('get_input_value_id', sqlerrm,
                       p_element_name,p_input_name,
                       p_business_group_id , p_effective_date,
                       p_language_code
                      );
    RAISE;
End get_input_value_id;
--
--
------------------------- get_balance_type_ovn -------------------------
--
-- Returns the object version number of the balance type and requires a
-- user key.
--
Function get_balance_type_ovn
  (p_balance_type_user_key        in varchar2
  )
  return number is
--
  l_blt_ovn number;
--
Begin
  select blt.object_version_number
    into l_blt_ovn
    from pay_balance_types blt,
         hr_pump_batch_line_user_keys key
   where key.user_key_value  = p_balance_type_user_key
     and blt.balance_type_id = key.unique_key_id;
  --
  return(l_blt_ovn);
exception
when others then
   hr_data_pump.fail('get_balance_type_ovn'
                     ,sqlerrm
		     ,p_balance_type_user_key
                    );
   raise;
End get_balance_type_ovn;
--
-------------------------- get_balance_type_id -------------------------
--
-- Returns a balance_types_id and requires a user_key.
--
function get_balance_type_id
(
   p_balance_type_user_key in varchar2
) return number is
   l_balance_type_id number;
begin
   l_balance_type_id := user_key_to_id(p_balance_type_user_key);
   return(l_balance_type_id);
exception
when others then
   hr_data_pump.fail('get_balance_type_id', sqlerrm, p_balance_type_user_key);
   raise;
end get_balance_type_id;
--
END pay_balance_types_data_pump ;

/
