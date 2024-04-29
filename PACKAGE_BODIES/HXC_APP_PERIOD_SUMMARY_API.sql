--------------------------------------------------------
--  DDL for Package Body HXC_APP_PERIOD_SUMMARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APP_PERIOD_SUMMARY_API" as
/* $Header: hxcapsumapi.pkb 120.2.12010000.1 2008/07/28 11:04:41 appldev ship $ */
Procedure delete_app_period
            (p_application_period_id in hxc_app_period_summary.application_period_id%type
            ) is

Begin

--
-- 1. Remove all the links between the app_period and the timecards
--
hxc_tc_ap_links_pkg.remove_app_period_links
  (p_application_period_id => p_application_period_id);
--
-- 2. Remove all detail links between details and application
--    periods
--
hxc_ap_detail_links_pkg.delete_ap_detail_links
  (p_application_period_id => p_application_period_id);

--
-- 3. Remove the application period summary row itself
--
hxc_app_period_summary_pkg.delete_summary_row
  (p_app_period_id => p_application_period_id);

End delete_app_period;

procedure app_period_clean_up
            (p_application_period_id in hxc_app_period_summary.application_period_id%type
            ,p_mode in varchar2
            ) is

cursor app_period_info
         (p_id in hxc_app_period_summary.application_period_id%type) is
  select tbb.resource_id
        ,tbb.start_time
        ,tbb.stop_time
        ,ta.attribute1 time_recipient_id
    from hxc_time_building_blocks tbb, hxc_time_Attributes ta, hxc_time_attribute_usages tau
   where tbb.time_building_block_id = p_id
     and tbb.date_to = hr_general.end_of_time
     and tau.time_building_block_id = tbb.time_building_block_id
     and tau.time_building_block_ovn = tbb.object_version_number
     and tau.time_attribute_id = ta.time_attribute_id
     and ta.attribute_category = 'APPROVAL';

cursor app_periods_to_remove
         (p_resource_id in hxc_app_period_summary.resource_id%type
         ,p_start_time  in hxc_app_period_summary.start_time%type
         ,p_stop_time   in hxc_app_period_summary.stop_time%type
         ,p_time_recipient_id in hxc_app_period_summary.time_recipient_id%type) is
  select application_period_id
    from hxc_app_period_summary
   where resource_id = p_resource_id
     and start_time <= p_stop_time
     and stop_time >= p_start_time
     and time_recipient_id = p_time_recipient_id;

l_resource_id       hxc_app_period_summary.resource_id%type;
l_start_time        hxc_app_period_summary.start_time%type;
l_stop_time         hxc_app_period_summary.stop_time%type;
l_time_recipient_id hxc_app_period_summary.time_recipient_id%type;

Begin

if(p_mode = hxc_timecard_summary_pkg.c_normal_mode) then
  open app_period_info(p_application_period_id);
  fetch app_period_info into l_resource_id, l_start_time, l_stop_time,l_time_recipient_id;
  if (app_period_info%FOUND) then
    for app_rec in app_periods_to_remove(l_resource_id,l_start_time,l_stop_time,l_time_recipient_id) loop
      delete_app_period(app_rec.application_period_id);
    end loop;
  else
  -- we can do nothing but delete the current app period
    delete_app_period(p_application_period_id);
  end if;
  close app_period_info;
else
    delete_app_period(p_application_period_id);
end if;

End app_period_clean_up;

procedure app_period_create
            (p_application_period_id  in hxc_app_period_summary.application_period_id%type
            ,p_mode                   in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
            ) is

Begin
--
-- 1. Clean up current application period data
--
  app_period_clean_up(p_application_period_id,p_mode);
--
-- 2. Create the application period summary row
--
  hxc_app_period_summary_pkg.insert_summary_row
    (p_app_period_id => p_application_period_id
    ,p_approval_item_type    => NULL
    ,p_approval_process_name => NULL
    ,p_approval_item_key     => NULL
    );
--
-- 3. Create the link between the application periods
--    and the timecards
--
  hxc_tc_ap_links_pkg.create_app_period_links
    (p_application_period_id => p_application_period_id);
--
-- 4. Links between details and application
--    periods made at another time.
--
  hxc_ap_detail_links_pkg.create_ap_detail_links
    (p_application_period_id => p_application_period_id);
--
-- 5. Reevaluate the timecard status
--    Not required on migration - status are
--    found as the migrated rows are created.
  if(p_mode = hxc_timecard_summary_pkg.c_normal_mode) then
    hxc_timecard_summary_api.reevaluate_timecard_statuses
      (p_application_period_id => p_application_period_id);
  end if;

--
-- End create application period
--
End app_period_create;

procedure app_period_create
            (p_application_period_id  in hxc_app_period_summary.application_period_id%type
            ,p_application_period_ovn in hxc_app_period_summary.application_period_ovn%type
            ,p_approval_status        in hxc_app_period_summary.approval_status%type
            ,p_time_recipient_id      in hxc_app_period_summary.time_recipient_id%type
            ,p_time_category_id       in hxc_app_period_summary.time_category_id%type
            ,p_start_time             in hxc_app_period_summary.start_time%type
            ,p_stop_time              in hxc_app_period_summary.stop_time%type
            ,p_resource_id            in hxc_app_period_summary.resource_id%type
            ,p_recipient_sequence     in hxc_app_period_summary.recipient_sequence%type
            ,p_category_sequence      in hxc_app_period_summary.category_sequence%type
            ,p_creation_date          in hxc_app_period_summary.creation_date%type
            ,p_notification_status    in hxc_app_period_summary.notification_status%type
            ,p_approver_id            in hxc_app_period_summary.approver_id%type
            ,p_approval_comp_id       in hxc_app_period_summary.approval_comp_id%type
            ,p_approval_item_key      in hxc_app_period_summary.approval_item_key%type default null
            ) is

cursor c_get_data_set_id(p_application_period_id number, p_application_period_ovn number) is
select data_set_id from hxc_time_building_blocks
where scope = 'APPLICATION_PERIOD'
  and time_building_block_id = p_application_period_id
  and object_version_number = p_application_period_ovn;

l_data_set_id hxc_time_building_blocks.data_set_id%TYPE;

Begin
--
-- 1. Clean up current application period data
--
  delete_app_period(p_application_period_id);
--
-- 2. Create the application period summary row
--
open c_get_data_set_id(p_application_period_id, p_application_period_ovn);
fetch c_get_data_set_id into l_data_set_id;
close c_get_data_set_id;

  hxc_app_period_summary_pkg.insert_summary_row
    (p_application_period_id => p_application_period_id
    ,p_application_period_ovn=> p_application_period_ovn
    ,p_approval_status	     => p_approval_status
    ,p_time_recipient_id     => p_time_recipient_id
    ,p_time_category_id	     => p_time_category_id
    ,p_start_time	     => p_start_time
    ,p_stop_time	     => p_stop_time
    ,p_resource_id	     => p_resource_id
    ,p_recipient_sequence    => p_recipient_sequence
    ,p_category_sequence     => p_category_sequence
    ,p_creation_date         => p_creation_date
    ,p_notification_status   => p_notification_status
    ,p_approver_id           => p_approver_id
    ,p_approval_comp_id      => p_approval_comp_id
    ,p_approval_item_type    => NULL
    ,p_approval_process_name => NULL
    ,p_approval_item_key     => p_approval_item_key
    ,p_data_set_id => l_data_set_id
    );
--
-- 3. Create the link between the application periods
--    and the timecards
--
  hxc_tc_ap_links_pkg.create_app_period_links
    (p_application_period_id => p_application_period_id);
--
-- 4. Links between details and application
--    periods made at another time.
--
--
-- 5. Reevaluate the timecard status
--
  hxc_timecard_summary_api.reevaluate_timecard_statuses
    (p_application_period_id => p_application_period_id);

--
-- End create application period
--
End app_period_create;

Procedure app_period_delete
            (p_application_period_id in hxc_app_period_summary.application_period_id%type) is

Begin

delete_app_period(p_application_period_id);

End app_period_delete;


--below for Garry's retrieval
FUNCTION valid_status(
  p_status       IN hxc_time_building_blocks.approval_status%TYPE
 ,p_block_status IN hxc_time_building_blocks.approval_status%TYPE
)
RETURN BOOLEAN
IS
BEGIN
  IF p_status = 'APPROVED'
  THEN
    IF p_block_status = 'APPROVED'
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF p_status = 'SUBMITTED' OR p_status = 'WORKING'
  THEN
    IF p_block_status = 'APPROVED'
      OR p_block_status = 'SUBMITTED'
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  END IF;
END valid_status;

PROCEDURE add_old_period(
  p_valid_periods IN OUT NOCOPY valid_period_tab
 ,p_start_date    IN DATE
 ,p_stop_date     IN DATE
)
IS
  l_index NUMBER;
BEGIN
  l_index := NVL(p_valid_periods.last, 0);

  IF l_index <> 0
    AND TRUNC(p_start_date) - TRUNC(p_valid_periods(l_index).stop_time) = 1
  THEN
    p_valid_periods(l_index).stop_time := p_stop_date;

    RETURN;
  END IF;

  l_index := l_index + 1;
  p_valid_periods(l_index).start_time := p_start_date;
  p_valid_periods(l_index).stop_time := p_stop_date;

END add_old_period;
--
-- This version of add period is used by the new
-- version of get_valid_periods, not including
-- the work done by Soma.
--
PROCEDURE add_period(
  p_valid_periods IN OUT NOCOPY valid_period_tab
 ,p_start_time    IN DATE
 ,p_stop_time     IN DATE
)
IS
  l_index NUMBER;
BEGIN
  l_index := to_number(to_char(p_start_time,'YYYYMMDD'));
  p_valid_periods(l_index).start_time := trunc(p_start_time);
  p_valid_periods(l_index).stop_time := trunc(p_stop_time);

END add_period;
--
-- Added for the 115.7 get_valid_periods rewrite
--
Function mergePeriods
           (p_valid_periods in out nocopy valid_period_tab,
	    p_invalid_periods in out nocopy valid_period_tab) return valid_period_tab is
   l_merged_periods valid_period_tab;
   l_index number;
   l_merged_index number;
   l_last_index number;
Begin
   l_index := p_invalid_periods.first;
   Loop
      Exit when not p_invalid_periods.exists(l_index);
      if(p_valid_periods.exists(l_index)) then
	 p_valid_periods.delete(l_index);
      end if;
      l_index := p_invalid_periods.next(l_index);
   End Loop;
   l_index := p_valid_periods.first;
   l_merged_index := 0;
   Loop
      Exit when not p_valid_periods.exists(l_index);
      if(l_merged_periods.count > 0) then
	 l_last_index := l_merged_periods.last;
	 if(p_valid_periods(l_index).start_time > l_merged_periods(l_last_index).stop_time) then
	    if((p_valid_periods(l_index).start_time - l_merged_periods(l_last_index).stop_time) = 1) then
	       l_merged_periods(l_last_index).stop_time := p_valid_periods(l_index).stop_time;
	    else
	       l_merged_index := l_last_index +1;
	       l_merged_periods(l_merged_index).start_time:= p_valid_periods(l_index).start_time;
	       l_merged_periods(l_merged_index).stop_time:= p_valid_periods(l_index).stop_time;
	    end if;
	 end if;
      else
	 l_merged_index := 1;
	 l_merged_periods(l_merged_index).start_time:= p_valid_periods(l_index).start_time;
	 l_merged_periods(l_merged_index).stop_time:= p_valid_periods(l_index).stop_time;
      end if;
      l_index := p_valid_periods.next(l_index);
   End Loop;
   return l_merged_periods;
End mergePeriods;

PROCEDURE get_valid_periods(
  p_resource_id       IN hxc_time_building_blocks.resource_id%TYPE
 ,p_time_recipient_id IN hxc_time_recipients.time_recipient_id%TYPE
 ,p_start_date        IN DATE
 ,p_stop_date         IN DATE
 ,p_valid_status      IN VARCHAR2
 ,p_valid_periods    OUT NOCOPY valid_period_tab
) is

  CURSOR c_app_periods(
    p_resource_id        hxc_time_building_blocks.resource_id%TYPE
   ,p_time_recipient_id  hxc_time_recipients.time_recipient_id%TYPE
   ,p_start_date         DATE
   ,p_stop_date          DATE
  )
  IS
    SELECT aps.start_time
          ,aps.stop_time
          ,aps.approval_status
	  ,aps.time_category_id
      FROM hxc_app_period_summary aps
     WHERE aps.resource_id =  p_resource_id
       AND aps.time_recipient_id = p_time_recipient_id
       AND aps.start_time <= p_stop_date
       AND aps.stop_time  >= p_start_date
       and exists
         (select 1
            from hxc_tc_ap_links tal
           where tal.application_period_id = aps.application_period_id
		 )
    ORDER BY start_time;

  CURSOR c_timecard_periods
   (   p_resource_id        hxc_time_building_blocks.resource_id%TYPE
      ,p_start_date         DATE
      ,p_stop_date          DATE
   )
   is
     SELECT tc.start_time
           ,tc.stop_time
       FROM hxc_timecard_summary tc
      WHERE tc.resource_id =  p_resource_id
        AND tc.start_time <= p_stop_date
        AND tc.stop_time  >= p_start_date
        AND tc.approval_status in ('SUBMITTED','APPROVED')
     ORDER BY start_time;

  l_valid BOOLEAN;
  l_start DATE := NULL;
  l_stop  DATE := NULL;
  l_app_period_start DATE;
  l_app_period_stop  DATE;
  l_app_period_status hxc_time_building_blocks.approval_status%TYPE;
  l_index NUMBER := 0;

  l_ela_used boolean;
  l_time_category_id number;
  l_invalid_periods valid_period_tab;

Begin
  if p_valid_status = 'SUBMITTED' then

   -- incoming status is 'SUBMITTED''
   -- we open c_timecard_periods cursor and add every period
   -- to the valid periods

       OPEN c_timecard_periods(
         p_resource_id       => p_resource_id
        ,p_start_date        => p_start_date
        ,p_stop_date         => p_stop_date
       );

       LOOP
           FETCH c_timecard_periods into l_start,l_stop;
           EXIT WHEN c_timecard_periods%NOTFOUND;

            add_old_period(
               p_valid_periods => p_valid_periods
              ,p_start_date    => greatest(p_start_date,l_start)
              ,p_stop_date     => least(p_stop_date, l_stop)
             );

       END LOOP;
       CLOSE c_timecard_periods;
         -- finally after adding all periods, we return
       return;
  end if;

  OPEN c_app_periods(
    p_resource_id       => p_resource_id
   ,p_time_recipient_id => p_time_recipient_id
   ,p_start_date        => p_start_date
   ,p_stop_date         => p_stop_date
  );

  Loop
     FETCH c_app_periods INTO l_app_period_start, l_app_period_stop, l_app_period_status, l_time_category_id;
     EXIT WHEN c_app_periods%NOTFOUND;

     if(l_time_category_id is not null) then
	l_ela_used := true;
     end if;

     l_valid := valid_status(p_valid_status, l_app_period_status);

     if(l_valid) then
	add_period(
		   p_valid_periods => p_valid_periods,
		   p_start_time    => greatest(p_start_date,l_app_period_start),
		   p_stop_time     => least(p_stop_date,l_app_period_stop)
		   ); /* Bug: 5599914 */
     else
	add_period(
		   p_valid_periods => l_invalid_periods,
		   p_start_time    => greatest(p_start_date,l_app_period_start),
		   p_stop_time     => least(p_stop_date,l_app_period_stop)
		   );	/* Bug: 5599914 */
     end if;
  End Loop;

  p_valid_periods :=  mergePeriods(p_valid_periods,l_invalid_periods);

End get_valid_periods;

end hxc_app_period_summary_api;

/
