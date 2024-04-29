--------------------------------------------------------
--  DDL for Package Body HXC_TC_AP_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TC_AP_LINKS_PKG" as
/* $Header: hxctalsum.pkb 115.1 2004/06/08 17:50:51 arundell noship $ */


procedure insert_summary_row(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
                            ,p_application_period_id in hxc_time_building_blocks.time_building_block_id%type) is

begin

insert into hxc_tc_ap_links
(timecard_id
,application_period_id
)
values
(p_timecard_id
,p_application_period_id
);

end insert_summary_row;

procedure delete_summary_row(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
                            ,p_application_period_id in hxc_time_building_blocks.time_building_block_id%type) is


begin

delete from hxc_tc_ap_links
 where timecard_id = p_timecard_id
   and application_period_id = p_application_period_id;

end delete_summary_row;

procedure remove_timecard_links
           (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is

begin

delete from hxc_tc_ap_links where timecard_id = p_timecard_id;

end remove_timecard_links;

procedure create_timecard_links
            (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is

cursor c_timecard_info(p_id in hxc_time_building_blocks.time_building_block_id%type) is
  select resource_id
        ,start_time
        ,stop_time
    from hxc_timecard_summary
   where timecard_id = p_id;

cursor c_app_periods(p_resource_id in hxc_time_building_blocks.resource_id%type
                    ,p_start_time  in hxc_time_building_blocks.start_time%type
                    ,p_stop_time   in hxc_time_building_blocks.stop_time%type
                    ) is
  select application_period_id
    from hxc_app_period_summary
   where resource_id = p_resource_id
     and start_time <= p_stop_time
     and stop_time >= p_start_time;

l_resource_id hxc_timecard_summary.resource_id%type;
l_start_time  hxc_timecard_summary.start_time%type;
l_stop_time   hxc_timecard_summary.stop_time%type;

begin

--
-- 1. Remove existing links
--

remove_timecard_links(p_timecard_id);

--
-- 2. Find timecard information
--

open c_timecard_info(p_timecard_id);
fetch c_timecard_info into l_resource_id, l_start_time, l_stop_time;
if(c_timecard_info%notfound) then
  close c_timecard_info;
  fnd_message.set_name('HXC','HXC_NO_TC_SUMMARY');
  fnd_message.raise_error;
end if;
close c_timecard_info;

--
-- 3. Find corresponding application period info, and create link
--

for app_rec in c_app_periods(l_resource_id,l_start_time,l_stop_time) loop

  insert_summary_row(p_timecard_id,app_rec.application_period_id);

end loop;

end create_timecard_links;

procedure remove_app_period_links
            (p_application_period_id in hxc_tc_ap_links.application_period_id%type) is

Begin

delete from hxc_tc_ap_links
 where application_period_id = p_application_period_id;

End remove_app_period_links;


procedure create_app_period_links
            (p_application_period_id in hxc_tc_ap_links.application_period_id%type) is

cursor c_app_period_info(p_id in hxc_time_building_blocks.time_building_block_id%type) is
  select resource_id
        ,start_time
        ,stop_time
    from hxc_app_period_summary
   where application_period_id = p_id;

cursor c_timecards(p_resource_id in hxc_time_building_blocks.resource_id%type
                  ,p_start_time  in hxc_time_building_blocks.start_time%type
                  ,p_stop_time   in hxc_time_building_blocks.stop_time%type
                  ) is
  select timecard_id
    from hxc_timecard_summary
   where resource_id = p_resource_id
     and start_time <= p_stop_time
     and stop_time >= p_start_time;

l_resource_id hxc_timecard_summary.resource_id%type;
l_start_time  hxc_timecard_summary.start_time%type;
l_stop_time   hxc_timecard_summary.stop_time%type;

begin
--
-- 1. Remove the existing application period links
--
remove_app_period_links
      (p_application_period_id => p_application_period_id);
--
-- 2. Find application period information
--
open c_app_period_info(p_application_period_id);
fetch c_app_period_info into l_resource_id, l_start_time, l_stop_time;
if(c_app_period_info%found) then

  --
  -- 3. Find corresponding application period info, and create link
  --

  for tc_rec in c_timecards(l_resource_id,l_start_time,l_stop_time) loop

    insert_summary_row(tc_rec.timecard_id,p_application_period_id);

  end loop;

end if;
close c_app_period_info;

end create_app_period_links;

end hxc_tc_ap_links_pkg;

/
