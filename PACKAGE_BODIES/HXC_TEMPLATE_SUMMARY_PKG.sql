--------------------------------------------------------
--  DDL for Package Body HXC_TEMPLATE_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TEMPLATE_SUMMARY_PKG" AS
/* $Header: hxctempsumpkg.pkb 120.1 2005/12/12 08:34:13 gkrishna noship $ */

PROCEDURE INSERT_SUMMARY_ROW(p_template_id in hxc_time_building_blocks.time_building_block_id%type,
			     p_template_ovn in hxc_time_building_blocks.OBJECT_VERSION_NUMBER%type,
			     p_template_name in hxc_template_summary.TEMPLATE_NAME%type,
			     p_description in hxc_template_summary.DESCRIPTION%type,
			     p_template_type in hxc_template_summary.TEMPLATE_TYPE%type,
			     p_layout_id in hxc_template_summary.LAYOUT_ID%type,
			     p_recurring_period_id in hxc_template_summary.RECURRING_PERIOD_ID%type,
			     p_business_group_id in hxc_template_summary.BUSINESS_GROUP_ID%type,
			     p_resource_id in hxc_template_summary.RESOURCE_ID%type
			     ) is

cursor c_template_info(p_template_id in hxc_time_building_blocks.time_building_block_id%type,p_template_ovn in hxc_time_building_blocks.object_version_number%type) is
 select  RESOURCE_ID,
	 start_time,
	 stop_time
    from hxc_time_building_blocks htb
   where time_building_block_id = p_template_id
     and date_to = hr_general.end_of_time
     and object_version_number = p_template_ovn
     and scope = 'TIMECARD_TEMPLATE';

l_updatedby_id hxc_time_building_blocks.resource_id%type;
l_recorded_hours  hxc_template_summary.recorded_hours%type :=0;
l_details      hxc_timecard_summary_pkg.details;
l_created_by   hxc_time_building_blocks.resource_id%type;
l_start_time   hxc_time_building_blocks.start_time%type;
l_stop_time   hxc_time_building_blocks.stop_time%type;
Begin

open c_template_info(p_template_id,p_template_ovn);
fetch c_template_info
 into l_created_by,l_start_time,l_stop_time;

if(p_resource_id is not null) then
     l_updatedby_id := p_resource_id;  -- Normal Template Deposition.
else
     l_updatedby_id := l_created_by;   -- Template Summary Migration.
end if;


if(c_template_info%found) then

  --
  -- 2. Recorded Hours
  --
     hxc_timecard_summary_pkg.get_recorded_hours(p_template_id,p_template_ovn,l_recorded_hours,l_details);
  --
  --
  -- Insert Summary Row
  --

insert into hxc_template_summary
			(TEMPLATE_ID,
			 TEMPLATE_OVN,
			 TEMPLATE_NAME,
			 DESCRIPTION,
			 TEMPLATE_TYPE,
			 RECORDED_HOURS,
			 LAYOUT_ID,
			 RESOURCE_ID,
			 LAST_UPDATED_BY_RESOURCE_ID,
			 RECURRING_PERIOD_ID,
			 BUSINESS_GROUP_ID,
			 START_TIME,
			 STOP_TIME)
  values
  (p_template_id
  ,p_template_ovn
  ,p_template_name
  ,p_description
  ,p_template_type
  ,l_recorded_hours
  ,p_layout_id
  ,l_created_by
  ,l_updatedby_id
  ,to_number(p_recurring_period_id)
  ,to_number(p_business_group_id)
  ,l_start_time
  ,l_stop_time);

else

  FND_MESSAGE.set_name('HXC','HXC_NO_TEMPLATE_ID');
  FND_MESSAGE.set_token('TEMPLATE__ID',to_char(p_template_id));
  FND_MESSAGE.raise_error;

end if;

END INSERT_SUMMARY_ROW;

PROCEDURE UPDATE_SUMMARY_ROW(p_template_id in hxc_time_building_blocks.time_building_block_id%type) is

Begin

null;

END UPDATE_SUMMARY_ROW;

PROCEDURE DELETE_SUMMARY_ROW(p_template_id in hxc_time_building_blocks.time_building_block_id%type) is

Begin

delete from hxc_template_summary where template_id = p_template_id;

Exception
  When others then
    FND_MESSAGE.set_name('HXC','HXC_NO_TEMPLATE_ID');
    FND_MESSAGE.raise_error;

END DELETE_SUMMARY_ROW;
END HXC_TEMPLATE_SUMMARY_PKG;

/
