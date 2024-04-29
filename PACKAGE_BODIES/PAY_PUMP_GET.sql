--------------------------------------------------------
--  DDL for Package Body PAY_PUMP_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PUMP_GET" as
/* $Header: paydpget.pkb 115.0 2003/02/14 15:07:29 arashid noship $ */
--------------------------- user_key_to_id ----------------------------------
/*
  NAME
    user_key_to_id
  DESCRIPTION
    Returns an ID value from hr_pump_batch_line_user_keys alone.
  NOTES
    Utility function to get _ID functions.
*/
function user_key_to_id
(p_where          in varchar2
,p_user_key_value in varchar2
) return number is
l_id number;
begin
   select unique_key_id
   into   l_id
   from   hr_pump_batch_line_user_keys
   where  user_key_value = p_user_key_value;
   return(l_id);
exception
  when others then
    hr_data_pump.fail(p_where, sqlerrm, p_user_key_value);
    raise;
end user_key_to_id;
--------------------------- get_run_type_id ---------------------------------
function get_run_type_id
(p_run_type_user_key in varchar2
) return number is
begin
  return
  user_key_to_id
  (p_where          => 'PAY_PUMP_GET.GET_RUN_TYPE_ID'
  ,p_user_key_value => p_run_type_user_key
  );
end get_run_type_id;
--------------------------- get_run_type_ovn --------------------------------
function get_run_type_ovn
(p_run_type_user_key in varchar2
,p_effective_date    in date
) return number is
l_ovn number;
begin
   select rt.object_version_number
   into   l_ovn
   from   pay_run_types_f rt
   ,      hr_pump_batch_line_user_keys key
   where  key.user_key_value = p_run_type_user_key
   and    rt.run_type_id = key.unique_key_id
   and    p_effective_date between
          rt.effective_start_date and rt.effective_end_date;
   return(l_ovn);
exception
  when others then
    hr_data_pump.fail
    ('PAY_PUMP_GET.GET_RUN_TYPE_OVN', sqlerrm, p_run_type_user_key,
     p_effective_date);
    raise;
end get_run_type_ovn;
end pay_pump_get;

/
