--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_FEED_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_FEED_DATA_PUMP" AS
/* $Header: pypbfdpm.pkb 115.0 2003/03/27 13:03:52 scchakra noship $ */
--
---------------------------- get_balance_feed_id ------------------------------
--
-- Returns a balance_feed_id and requires a user_key.
--
function get_balance_feed_id
(
   p_balance_feed_user_key in varchar2
) return number is
   l_balance_feed_id number;
begin
   l_balance_feed_id := pay_element_data_pump.user_key_to_id
                          (p_balance_feed_user_key);
   return(l_balance_feed_id);
exception
when others then
   hr_data_pump.fail('get_balance_feed_id', sqlerrm, p_balance_feed_user_key);
   raise;
end get_balance_feed_id;
--
---------------------------- get_balance_type_id ------------------------------
--
-- Returns a balance_type_id.
--
Function get_balance_type_id
  (p_balance_name          in varchar2
  ,p_business_group_id     in number
  ,p_language_code         in varchar2
  )
  return number is
  --
  l_balance_type_id number;
  --
Begin
  --
  select bt.balance_type_id
    into l_balance_type_id
    from pay_balance_types bt, pay_balance_types_tl bttl
   where bt.balance_type_id = bttl.balance_type_id
     and bttl.language = p_language_code
     and bttl.balance_name = p_balance_name
     and (nvl(bt.business_group_id,-1) = p_business_group_id
         or nvl(bt.legislation_code,' ') =
              hr_api.return_legislation_code(p_business_group_id)
         or bt.business_group_id is null
         and bt.legislation_code is null);
  --
  return(l_balance_type_id);
  --
Exception
  --
  when others then
    hr_data_pump.fail('get_balance_type_id'
                     ,sqlerrm
                     ,p_balance_name
                     ,p_business_group_id);
    raise;
    --
End get_balance_type_id;
--
---------------------------- get_balance_feed_ovn -----------------------------
--
-- Returns the object version number of the balance feed and requires a user
-- user key.
--
Function get_balance_feed_ovn
  (p_balance_feed_user_key in varchar2
  ,p_effective_date        in date
  )
  return number is
  --
  l_balance_feed_ovn number;
  --
Begin
   select pbf.object_version_number
     into l_balance_feed_ovn
     from pay_balance_feeds_f pbf,
          hr_pump_batch_line_user_keys key
    where key.user_key_value  = p_balance_feed_user_key
      and pbf.balance_feed_id = key.unique_key_id
      and p_effective_date between pbf.effective_start_date
      and pbf.effective_end_date;

   return(l_balance_feed_ovn);
exception
when others then
   hr_data_pump.fail('get_balance_feed_ovn', sqlerrm, p_balance_feed_user_key,
                     p_effective_date);
   raise;
end get_balance_feed_ovn;
--
END pay_balance_feed_data_pump;

/
