--------------------------------------------------------
--  DDL for Package Body AMS_TCOP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TCOP_UTIL_PKG" AS
/* $Header: amsvtcub.pls 120.0 2005/05/31 22:19:38 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_UTIL_PKG
-- Purpose
--
-- This package contains all the traffic cop related utilities
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
-- Start of Comments
-- Name
-- Is_Fatigue_Rule_Applicable
--
-- Purpose
-- This function verifies if Fatigue Rule is applicable for
-- this schedule or not
-- Return Value
-- It returns 'Y' if Fatigue Rule is applicable for this schedule
-- It returns 'N' if Fatigue Rule is no applicable for this schedule
--
function Is_Fatigue_Rule_Applicable (
  p_schedule_id number
)
return varchar2
is

cursor c_get_fatigue_flag(p_schedule_id number)
is
select list_header.apply_traffic_cop,
       list_header.list_header_id
from ams_list_headers_all list_header
,ams_act_lists act_list
where act_list.LIST_ACT_TYPE = 'TARGET'
and act_list.LIST_USED_BY = 'CSCH'
and act_list.LIST_USED_BY_ID = p_schedule_id
and act_list.LIST_HEADER_ID = list_header.LIST_HEADER_ID;

cursor c_get_rule(p_schedule_id number)
is
select rule_id
from ams_tcop_fr_rules_setup rule,
     ams_campaign_schedules_b schedule
where rule.ENABLED_FLAG = 'Y'
and (rule.CHANNEL_ID is null
     or (rule.CHANNEL_ID = schedule.ACTIVITY_ID) )
and rule.RULE_TYPE in ('GLOBAL' , 'CHANNEL_BASED')
and schedule.SCHEDULE_ID = p_schedule_id;

cursor c_get_null_party_map(p_list_header_id number)
is
select list1.list_entry_id
from ams_list_entries list1
where list1.list_header_id = p_list_header_id
and exists
(
   select list2.list_entry_id
   from ams_list_entries list2
   where list1.list_entry_id=list2.list_entry_id
   and list2.list_header_id = p_list_header_id
   and list2.party_id is null
);

cursor c_get_non_tca_map(p_list_header_id number)
is
select list1.list_entry_id
from ams_list_entries list1
where list1.list_header_id=p_list_header_id
and not exists
(
   select list2.party_id
   from ams_list_entries list2
        ,hz_parties hz
   where list2.party_id=hz.party_id
   and list2.list_header_id = p_list_header_id
   and list2.list_entry_id=list1.list_entry_id
);


l_fatigue_flag varchar2(1);
l_rule_id number;
l_list_header_id number;
l_list_entry_id number;

begin

   -- Check if the Apply Traffic Cop flag is set at Target Group List Header
   -- level;
   open c_get_fatigue_flag (p_schedule_id);
   fetch c_get_fatigue_flag into l_fatigue_flag,l_list_header_id;
   close c_get_fatigue_flag;

   if (l_fatigue_flag = 'Y') then

      -- Check if there are any Fatigue Rules relevant for this Schedule
      -- If not,Fatigue Rule will not be applied

      open c_get_rule (p_schedule_id);
      fetch c_get_rule into l_rule_id;
      close c_get_rule;

      if (l_rule_id is not null) then

         -- Check whether party_id column in AMS_LIST_ENTRIES is null
         -- if party_id column is null then Fatigue Rule will not be applied
         open c_get_null_party_map(l_list_header_id);
         fetch c_get_null_party_map
         into  l_list_entry_id;
         close c_get_null_party_map;

         if (l_list_entry_id is not null) then
            return 'N';
         else
            -- Check whether party_id mapped in AMS_LIST_ENTRIES
            -- refer to HZ_PARTIES.PARTY_ID
            -- if party_id columns is mapped to anything other than TCA Party Id
            -- then fatigue rule will not be applicable.
            open c_get_non_tca_map(l_list_header_id);
            fetch c_get_non_tca_map
            into  l_list_entry_id;
            close c_get_non_tca_map;

            if (l_list_entry_id is not null) then
               return 'N';
            else
               return 'Y';
            end if;

         end if;

      else
	      return 'N';
      end if;
   else
      return 'N';
   end if;

end Is_Fatigue_Rule_Applicable;

END AMS_TCOP_UTIL_PKG;

/
