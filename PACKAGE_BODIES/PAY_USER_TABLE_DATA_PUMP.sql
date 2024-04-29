--------------------------------------------------------
--  DDL for Package Body PAY_USER_TABLE_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_TABLE_DATA_PUMP" AS
/* $Header: pyputdpm.pkb 115.0 2003/10/29 20:51 scchakra noship $ */
--
------------------------------ get_user_table_id ------------------------------
--
-- This is a private function and returns the user table id.
--
function get_user_table_id
  (p_user_table_user_key in varchar2)
  return number is

l_user_table_id number;
begin
   l_user_table_id := pay_element_data_pump.user_key_to_id
                      (p_user_table_user_key);
   return(l_user_table_id);
exception
when others then
   hr_data_pump.fail('get_user_table_id', sqlerrm, p_user_table_user_key);
   raise;
end get_user_table_id;
--
---------------------------- get_user_table_ovn ------------------------------
--
-- Returns the object version number of the user table and requires a
-- user key.
--
Function get_user_table_ovn
  (p_user_table_user_key  in varchar2)
  return number is
--
  l_user_table_ovn number;
  l_user_table_id number;
--
begin
  l_user_table_id := get_user_table_id
                        (p_user_table_user_key
			);
  select object_version_number
    into l_user_table_ovn
    from pay_user_tables
   where user_table_id = l_user_table_id;
  --
  return(l_user_table_ovn);
exception
when others then
   hr_data_pump.fail('get_user_table_ovn',
                     sqlerrm,
		     p_user_table_user_key
                    );
   raise;
End get_user_table_ovn;
--
---------------------------- get_user_column_ovn ------------------------------
--
-- Returns the object version number of the user column and requires a
-- user key.
--
Function get_user_column_ovn
  (p_user_column_user_key  in varchar2
  )
  return number is
--
  l_user_column_ovn number;
  l_user_column_id number;
--
begin
  l_user_column_id := get_user_column_id
                        (p_user_column_user_key
			);
  select object_version_number
    into l_user_column_ovn
    from pay_user_columns
   where user_column_id = l_user_column_id;
  --
  return(l_user_column_ovn);
exception
when others then
   hr_data_pump.fail('get_user_column_ovn',
                     sqlerrm,
		     p_user_column_user_key
                    );
   raise;
End get_user_column_ovn;
--
--------------------------- get_user_column_id --------------------------------
--
-- Returns a user_column_id and requires a user_key.
--
function get_user_column_id
  (p_user_column_user_key in varchar2)
  return number is

l_user_column_id number;
begin
   l_user_column_id := pay_element_data_pump.user_key_to_id
                      (p_user_column_user_key);
   return(l_user_column_id);
exception
when others then
   hr_data_pump.fail('get_user_column_id', sqlerrm, p_user_column_user_key);
   raise;
end get_user_column_id;
--
----------------------------- get_formula_id ----------------------------------
--
-- Returns a formula_id.
--
function get_formula_id
   (p_formula_name      in varchar2,
    p_business_group_id in  number
   ) return number IS

l_formula_id number ;

Begin

 select distinct formula_id
   into l_formula_id
   from ff_formulas_f f1,
        ff_formula_types f2
  where f1.formula_type_id = f2.formula_type_id
    and f2.formula_type_name = 'User Table Validation'
    and (business_group_id + 0 = p_business_group_id
        or (business_group_id is null
            and legislation_code =
                hr_api.return_legislation_code(p_business_group_id))
        or (business_group_id is null
	    and legislation_code is null)
	)
    and  upper(formula_name) = upper(p_formula_Name);

 return(l_formula_id);

Exception
  When OTHERS Then
     hr_data_pump.fail('get_formula_id',
                        sqlerrm,
			p_formula_name,
              	        p_business_group_id);
       RAISE;
End get_formula_id;
--
----------------------------- get_user_row_id ---------------------------------
--
-- Returns a user_row_id and requires a user_key.
--
function get_user_row_id
  (p_user_row_user_key in varchar2)
  return number is

l_user_row_id number;
begin
   l_user_row_id := pay_element_data_pump.user_key_to_id
                      (p_user_row_user_key);
   return(l_user_row_id);
exception
when others then
   hr_data_pump.fail('get_user_row_id', sqlerrm, p_user_row_user_key);
   raise;
end get_user_row_id;
--
----------------------------- get_user_row_ovn --------------------------------
--
-- Returns the object version number of the user row and requires a
-- user key.
--
Function get_user_row_ovn
  (p_user_row_user_key  in varchar2
  ,p_effective_date     in date
  )
  return number is
--
  l_user_row_ovn number;
  l_user_row_id number;
--
begin
  l_user_row_id := get_user_row_id
                     (p_user_row_user_key
                     );
  select object_version_number
    into l_user_row_ovn
    from pay_user_rows_f
   where user_row_id = l_user_row_id
     and p_effective_date between effective_start_date
     and effective_end_date;
  --
  return(l_user_row_ovn);
exception
when others then
   hr_data_pump.fail('get_user_row_ovn',
                     sqlerrm,
		     p_user_row_user_key
                    );
   raise;
End get_user_row_ovn;
--
------------------------- get_user_column_instance_id -------------------------
--
-- Returns a user_column_instance_id.
--
function get_user_column_instance_id
  (p_user_column_user_key in varchar2
  ,p_business_group_id in number
  ,p_user_row_user_key in varchar2
  ,p_effective_date    in date
  )
  return number is

l_user_column_id          number;
l_user_row_id             number;
l_user_column_instance_id number;

begin
  l_user_column_id := get_user_column_id
                        (p_user_column_user_key
			);
  l_user_row_id := get_user_row_id(p_user_row_user_key);

  select user_column_instance_id
    into l_user_column_instance_id
    from pay_user_column_instances_f
   where user_row_id = l_user_row_id
     and user_column_id = l_user_column_id
     and p_effective_date between effective_start_date
     and effective_end_date
     and (business_group_id + 0 = p_business_group_id
         or (business_group_id is null
            and legislation_code =
                hr_api.return_legislation_code(p_business_group_id))
         or (business_group_id is null
	    and legislation_code is null)
	 );
return(l_user_column_instance_id);
exception
when others then
   hr_data_pump.fail('get_user_column_instance_id'
                     ,sqlerrm
                     ,p_user_column_user_key
		     ,p_business_group_id
		     ,p_user_row_user_key
		     ,p_effective_date
		     );
   raise;
end get_user_column_instance_id;
--
------------------------ get_user_column_instance_ovn -------------------------
--
-- Returns the object version number of the user column instance and requires a
-- user key.
--
function get_user_column_instance_ovn
  (p_user_column_user_key  in varchar2
  ,p_business_group_id in number
  ,p_user_row_user_key in varchar2
  ,p_effective_date    in date
  )
  return number is
--
  l_user_column_instance_ovn number;
  l_user_column_instance_id number;
--
begin
  l_user_column_instance_id := get_user_column_instance_id
				 (p_user_column_user_key
				 ,p_business_group_id
				 ,p_user_row_user_key
				 ,p_effective_date);

  select object_version_number
    into l_user_column_instance_ovn
    from pay_user_column_instances_f
   where user_column_instance_id = l_user_column_instance_id
     and p_effective_date between effective_start_date
     and effective_end_date;
  --
  return(l_user_column_instance_ovn);
exception
when others then
   hr_data_pump.fail('get_user_column_instance_ovn'
                     ,sqlerrm
                     ,p_user_column_user_key
		     ,p_business_group_id
		     ,p_user_row_user_key
		     ,p_effective_date
		    );
   raise;
End get_user_column_instance_ovn;
--
END pay_user_table_data_pump;

/
