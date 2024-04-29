--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_APPROVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_APPROVAL" as
/* $Header: hxctimeapprove.pkb 120.8.12010000.5 2009/10/05 12:09:47 amakrish ship $ */

  g_package varchar2(30) := 'hxc_timecard_approval.';
  g_debug boolean := hr_utility.debug_enabled;

  TYPE application_period_table IS TABLE OF hxc_app_period_summary.APPLICATION_PERIOD_ID%TYPE;
  TYPE tc_ap_links IS RECORD
    (TIMECARD_ID			hxc_tc_ap_links.TIMECARD_ID%TYPE,
     APPLICATION_PERIOD_ID		hxc_tc_ap_links.APPLICATION_PERIOD_ID%TYPE
     );
  TYPE tc_ap_links_table IS TABLE OF tc_ap_links INDEX BY BINARY_INTEGER;

  TYPE time_recipient_table IS TABLE OF HXC_TIME_RECIPIENTS.TIME_RECIPIENT_ID%TYPE INDEX BY BINARY_INTEGER;

  TYPE application_period_id_arr IS TABLE OF hxc_tc_ap_links.APPLICATION_PERIOD_ID%TYPE INDEX BY BINARY_INTEGER;

  TYPE time_building_block_id_arr IS TABLE OF hxc_ap_detail_links.TIME_BUILDING_BLOCK_ID%TYPE INDEX BY BINARY_INTEGER;

  TYPE time_building_block_ovn_arr IS TABLE OF hxc_ap_detail_links.TIME_BUILDING_BLOCK_OVN%TYPE INDEX BY BINARY_INTEGER;

  TYPE ap_detail_links_rec IS RECORD
    (APPLICATION_PERIOD_ID		application_period_id_arr,
     TIME_BUILDING_BLOCK_ID	time_building_block_id_arr,
     TIME_BUILDING_BLOCK_OVN	time_building_block_ovn_arr
     );

  TYPE timecard_info IS RECORD
    (TIME_BUILDING_BLOCK_ID	HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE,
     OBJECT_VERSION_NUMBER	HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE,
     TYPE			HXC_TIME_BUILDING_BLOCKS.TYPE%TYPE,
     START_TIME		HXC_TIME_BUILDING_BLOCKS.START_TIME%TYPE,
     STOP_TIME		HXC_TIME_BUILDING_BLOCKS.STOP_TIME%TYPE,
     RESOURCE_ID		HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE,
     RESOURCE_TYPE		HXC_TIME_BUILDING_BLOCKS.RESOURCE_TYPE%TYPE,
     APPROVAL_STYLE_ID	HXC_TIME_BUILDING_BLOCKS.APPROVAL_STYLE_ID%TYPE,
     APPLICATION_SET_ID	HXC_TIME_BUILDING_BLOCKS.APPLICATION_SET_ID%TYPE,
     CREATION_DATE		HXC_TIME_BUILDING_BLOCKS.CREATION_DATE%TYPE
     );

  g_light_approval_style_id number	:= -99;

  Function get_item_key return number is
    l_item_key number;
  Begin
      select hxc_approval_item_key_s.nextval
        into l_item_key
        from dual;

    return l_item_key;

  End get_item_key;

  Function is_timecard_resubmitted
    (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type,
     p_timecard_ovn in hxc_time_building_blocks.object_version_number%type,
     p_resource_id in hxc_time_building_blocks.resource_id%type,
     p_start_time  in hxc_time_building_blocks.start_time%type,
     p_stop_time   in hxc_time_building_blocks.stop_time%type
     ) return varchar2 is

    cursor csr_resubmitted
      (p_timecard_id IN HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE,
       p_max_ovn     IN HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
       ) is
      select 'YES'
        from hxc_time_building_blocks
       where time_building_block_id = p_timecard_id
         and object_version_number <= p_max_ovn
         and approval_status = 'SUBMITTED';

    cursor csr_further_check
      (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type,
       p_resource_id in hxc_time_building_blocks.resource_id%type,
       p_start_time in hxc_time_building_blocks.start_time%type,
       p_stop_time in hxc_time_building_blocks.stop_time%type
       ) is
      select 'YES'
        from hxc_time_building_blocks
       where time_building_block_id <> p_timecard_id
         and approval_status = 'SUBMITTED'
         and start_time <= p_stop_time
         and stop_time >= p_start_time
         and resource_id = p_resource_id
         and scope = 'TIMECARD';

    l_resubmitted varchar2(3) := 'NO';

  Begin

    open csr_resubmitted(p_timecard_id, p_timecard_ovn);
    fetch csr_resubmitted into l_resubmitted;
    if(csr_resubmitted%NOTFOUND) then
      close csr_resubmitted;
      open csr_further_check(p_timecard_id, p_resource_id, p_start_time, p_stop_time);
      fetch csr_further_check into l_resubmitted;
      if (csr_further_check%NOTFOUND) then
        l_resubmitted := 'NO';
      end if;
      close csr_further_check;
    else
      close csr_resubmitted;
    end if;

    return l_resubmitted;

  Exception
    When others then
      return l_resubmitted;

  End is_timecard_resubmitted;

  Procedure get_timecard_information
    (p_blocks       in            hxc_block_table_type,
     p_timecard_id     out nocopy hxc_time_building_blocks.time_building_block_id%type,
     p_timecard_ovn    out nocopy hxc_time_building_blocks.object_version_number%type,
     p_new_blocks      out nocopy varchar2,
     p_timecard_info   out nocopy timecard_info
     ) is
    l_timecard_index number;
  Begin
    l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);
    p_timecard_id  := p_blocks(l_timecard_index).time_building_block_id;
    p_timecard_ovn := p_blocks(l_timecard_index).object_version_number;
    p_new_blocks   := hxc_timecard_block_utils.any_new_blocks(p_blocks);
    p_timecard_info.time_building_block_id	:= p_blocks(l_timecard_index).time_building_block_id;
    p_timecard_info.object_version_number	:= p_blocks(l_timecard_index).object_version_number;
    p_timecard_info.type			:= p_blocks(l_timecard_index).type;
    p_timecard_info.start_time		:= to_date(p_blocks(l_timecard_index).start_time,'rrrr/mm/dd hh24:mi:ss');
    p_timecard_info.stop_time		:= to_date(p_blocks(l_timecard_index).stop_time,'rrrr/mm/dd hh24:mi:ss');
    p_timecard_info.resource_id		:= p_blocks(l_timecard_index).resource_id;
    p_timecard_info.resource_type		:= p_blocks(l_timecard_index).resource_type;
    p_timecard_info.approval_style_id	:= p_blocks(l_timecard_index).approval_style_id;
    p_timecard_info.application_set_id	:= p_blocks(l_timecard_index).application_set_id;
  End get_timecard_information;


  Procedure light_approve_timecards
    (p_tc_bb_id       IN            number,
     p_tc_ovn         IN            number,
     p_tc_resubmitted IN            varchar2,
     p_blocks  	      IN	    hxc_block_table_type,
     p_timecard_info  IN	    timecard_info,
     p_messages	      IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
     )is

    Cursor c_get_tc_ap_links
    is
      select timecard_id,
             application_period_id
        from hxc_tc_ap_links
       where timecard_id = p_tc_bb_id;

    Cursor c_creation_date
      (l_app_id hxc_time_building_blocks.time_building_block_id%TYPE,
       l_app_ovn hxc_time_building_blocks.object_version_number%TYPE
       ) is
      select creation_date
        from hxc_time_building_blocks
       where time_building_block_id = l_app_id
         and object_version_number = l_app_ovn;

    cursor c_app_period
      (p_resource_id hxc_time_building_blocks.resource_id%TYPE,
       p_start_time  hxc_time_building_blocks.start_time%TYPE,
       p_stop_time   hxc_time_building_blocks.stop_time%TYPE,
       p_time_recipient_id hxc_time_recipients.time_recipient_id%TYPE
       ) is
      select application_period_id
        from hxc_app_period_summary
       where resource_id = p_resource_id
         and trunc(start_time) = trunc(p_start_time)
         and trunc(stop_time) = trunc(p_stop_time)
         and time_recipient_id  = p_time_recipient_id
         and recipient_sequence IS NULL
         and time_category_id IS NULL
         and category_sequence IS NULL
         and approval_comp_id IS NULL;

    cursor c_get_apps_from_app_set
      (p_app_set number) is
      select htr.time_recipient_id
        from hxc_application_sets_v has,
             hxc_application_set_comps_v hasc,
             hxc_time_recipients htr
       where has.application_set_id = p_app_set
         and hasc.application_set_id = has.application_set_id
         and hasc.time_recipient_id = htr.time_recipient_id;

    l_application_set_id  	HXC_APPLICATION_SETS_V.APPLICATION_SET_ID%TYPE;
    l_appl_recipients 		time_recipient_table;
    l_time_building_block_id	HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE ;
    l_object_version_number	HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE ;
    l_resource_id  		HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE ;
    l_resource_type 		HXC_TIME_BUILDING_BLOCKS.RESOURCE_TYPE%TYPE ;
    l_timecard_type 		HXC_TIME_BUILDING_BLOCKS.TYPE%TYPE ;
    l_timecard_start_time 	HXC_TIME_BUILDING_BLOCKS.START_TIME%TYPE ;
    l_timecard_stop_time  	HXC_TIME_BUILDING_BLOCKS.STOP_TIME%TYPE ;
    l_period_start_date		HXC_TIME_BUILDING_BLOCKS.START_TIME%TYPE ;
    l_period_end_date		HXC_TIME_BUILDING_BLOCKS.STOP_TIME%TYPE ;
    l_tc_ap_links_table		tc_ap_links_table;
    l_index 			number ;
    l_assignment_periods        hxc_timecard_utilities.periods;
    l_app_period_info 		application_period_table;
    l_creation_date 		hxc_time_building_blocks.creation_date%TYPE := NULL;
    l_dup_index			number;
    l_detail_array		ap_detail_links_rec;
    l_index_1			number;
    l_index_2			number;
    l_timecard_blocks  		hxc_timecard.block_list;
    l_day_blocks       		hxc_timecard.block_list;
    l_detail_blocks    		hxc_timecard.block_list;
    l_proc                      varchar2(70);

  Begin
    if g_debug then
      l_proc := g_package||'light_approve_timecards';
      hr_utility.set_location('Processing '||l_proc, 10);
    end if;

    l_timecard_type	:=	p_timecard_info.TYPE;
    l_timecard_start_time	:=	p_timecard_info.START_TIME;
    l_timecard_stop_time	:=	p_timecard_info.STOP_TIME;
    l_resource_id		:=	p_timecard_info.RESOURCE_ID;
    l_resource_type	:=	p_timecard_info.RESOURCE_TYPE;
    l_application_set_id	:=	p_timecard_info.APPLICATION_SET_ID;


/*Cancel all the previous notifications for this Timecard. The rationale
* is, this Timecard is going to be Light approved, which means there should
* be no open notifications for this Timecard. If the Timecard had previously
* been associated with some other Approval style, then the notifications
* generated, if any should be CANCELLED. */


    if g_debug then
      hr_utility.set_location('Processing '||l_proc, 20);
    end if;

    hxc_find_notify_aprs_pkg.cancel_previous_notifications
      (p_timecard_id => p_tc_bb_id);

/*Remove existing records from hxc_tc_ap_links
* Most probably there wont be any records as they would have
* been deleted in the hxc_timecard package      */

    hxc_tc_ap_links_pkg.remove_timecard_links
      (p_timecard_id => p_tc_bb_id );

    open c_get_apps_from_app_set(l_application_set_id );
    fetch c_get_apps_from_app_set BULK COLLECT INTO l_appl_recipients;

    if l_appl_recipients.count > 0 then
/* Loop through all the recipient applications */
      for l_index IN l_appl_recipients.first .. l_appl_recipients.last LOOP
        if g_debug then
          hr_utility.set_location('Processing '||l_proc, 30);
        end if;
        l_period_start_date	:= l_timecard_start_time;
        l_period_end_date	:= l_timecard_stop_time;
/* Get any existing Application period for the same resource_id, recipient_id, start and stop time */
        open c_app_period
          (l_resource_id,
           l_period_start_date,
           l_period_end_date,
           l_appl_recipients(l_index)
           );

        fetch c_app_period bulk collect into l_app_period_info;
        close c_app_period;

        if l_app_period_info.count > 0 then
          if g_debug then
            hr_utility.set_location('Processing '||l_proc, 40);
          end if;

          for l_dup_index IN  l_app_period_info.first .. l_app_period_info.last loop
            if g_debug then
              hr_utility.set_location('Processing '||l_proc, 50);
            end if;
 /* Remove the existing record from hxc_ap_detail_links table */
            hxc_ap_detail_links_pkg.delete_ap_detail_links(p_application_period_id => l_app_period_info(l_dup_index));
/* Remove the record from hxc_app_period_summary table */
            hxc_app_period_summary_pkg.delete_summary_row(p_app_period_id => l_app_period_info(l_dup_index) );
          End loop;
        end if;
      end loop;

    else
      if g_debug then
        hr_utility.set_location('Processing '||l_proc, 60);
      end if;
      fnd_message.set_name('HXC', 'HXC_APR_NO_APPL_SET_PREF');
      fnd_message.raise_error;
    end if;

/* For each of the recipient Application present in the Application set of the person*/
/* We get the detail blocks of the Timecard from p_blocks */

    hxc_timecard_block_utils.sort_blocks
      (p_blocks          => p_blocks,
       p_timecard_blocks => l_timecard_blocks,
       p_day_blocks      => l_day_blocks,
       p_detail_blocks   => l_detail_blocks
       );


    l_index_1 := l_detail_blocks.first;
    l_index_2  := 1;
    loop
      EXIT WHEN NOT l_detail_blocks.exists(l_index_1);
      if g_debug then
        hr_utility.set_location('Processing '||l_proc, 70);
      end if;
      l_detail_array.TIME_BUILDING_BLOCK_ID(l_index_2) := p_blocks(l_detail_blocks(l_index_1)).time_building_block_id  ;
      l_detail_array.TIME_BUILDING_BLOCK_OVN(l_index_2) := p_blocks(l_detail_blocks(l_index_1)).object_version_number ;
      l_index_2 := l_index_2 + 1;
      l_index_1 := l_detail_blocks.next(l_index_1);
    end loop;
    if g_debug then
      hr_utility.set_location('Processing '||l_proc, 80);
    end if;

    for l_index IN l_appl_recipients.first .. l_appl_recipients.last LOOP
     /* Call to create an Application period  in hxc_time_building blocks table */
      l_time_building_block_id := null;
      l_object_version_number  := null;

      if g_debug then
        hr_utility.set_location('Processing '||l_proc, 90);
      end if;

      hxc_building_block_api.create_building_block
        (p_effective_date            => trunc(SYSDATE),
         p_type                      => l_timecard_type,
         p_measure                   => null,
         p_unit_of_measure           => null,
         p_start_time                => l_timecard_start_time,
         p_stop_time                 => l_timecard_stop_time,
         p_parent_building_block_id  => null,
         p_parent_building_block_ovn => null,
         p_scope                     => 'APPLICATION_PERIOD',
         p_approval_style_id         => null,
         p_approval_status           => 'APPROVED',
         p_resource_id               => l_resource_id,
         p_resource_type             => l_resource_type,
         p_comment_text              => 'LIGHT_APPROVAL',
         p_application_set_id        => null,
         p_translation_display_key   => null,
         p_time_building_block_id    => l_time_building_block_id,
         p_object_version_number     => l_object_version_number
         );


/* Get the creation date of the Timecard to populate in the hxc_app_period_summary table */
      open c_creation_date(l_time_building_block_id , l_object_version_number );
      fetch c_creation_date into l_creation_date;
      close c_creation_date;
      if g_debug then
        hr_utility.set_location('Processing '||l_proc, 100);
      end if;

   /* Call to create the Application period  in hxc_app_period_summary table */
      hxc_app_period_summary_pkg.insert_summary_row
        (p_application_period_id => l_time_building_block_id,
         p_application_period_ovn=> l_object_version_number,
         p_approval_status       => 'APPROVED',
         p_time_recipient_id     => l_appl_recipients(l_index),
         p_time_category_id      => NULL,
         p_start_time	       => l_timecard_start_time,
         p_stop_time	       => l_timecard_stop_time,
         p_resource_id	       => l_resource_id,
         p_recipient_sequence    => null,
         p_category_sequence     => null,
         p_creation_date         => l_creation_date,
         p_notification_status   => 'FINISHED',
         p_approver_id           => null,
         p_approval_comp_id      => null,
         p_approval_item_type    => NULL,
         p_approval_process_name => NULL,
         p_approval_item_key     => NULL,
         p_data_set_id 	       => null	----- Passing data set id as null explicitly.,
         );


   /* Call to create the Timecard - Application period  link in hxc_yc_ap_links table */
      hxc_tc_ap_links_pkg.insert_summary_row
        (p_timecard_id           => p_tc_bb_id,
         p_application_period_id => l_time_building_block_id
         );

   /* Call to get all the detail records of the Timecard and populate the nested array l_detail_array */
      --Fix the bug 4506258. Added the if condition to take care of empty PL/SQL table when empty TC is submitted
      if(l_detail_array.time_building_block_id.count>0) then
        For l_index_app IN l_detail_array.TIME_BUILDING_BLOCK_ID.first .. l_detail_array.TIME_BUILDING_BLOCK_ID.last LOOP
          l_detail_array.application_period_id(l_index_app) :=   l_time_building_block_id ;
        End loop;
      end if;
      if g_debug then
        hr_utility.set_location('Processing '||l_proc, 110);
      end if;
   /* Bulk insert the nested array into the hxc_ap_detail_links table */
      --Fix the bug 4506258. Added the if condition to take care of empty PL/SQL table when empty TC is submitted
      if(l_detail_array.application_period_id.count>0) then
        forall l_dup_index in l_detail_array.application_period_id.first .. l_detail_array.application_period_id.last
          insert into hxc_ap_detail_links
          values ( l_detail_array.APPLICATION_PERIOD_ID(l_dup_index),
                   l_detail_array.TIME_BUILDING_BLOCK_ID(l_dup_index),
                   l_detail_array.TIME_BUILDING_BLOCK_OVN(l_dup_index)
                   );
      end if;
    end loop;
    if g_debug then
      hr_utility.set_location('Processing '||l_proc, 120);
    end if;

      update hxc_timecard_summary
         set approval_status = hxc_timecard.c_approved_status
       where timecard_id = p_tc_bb_id;

    if g_debug then
      hr_utility.set_location('Processing '||l_proc, 130);
    end if;

  -- OTL-Absences Integration (Bug 8779478)
    IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
       IF g_debug THEN
        	hr_utility.trace('Initiated Online Retrieval from HXC_TIMECARD_APPROVAL.LIGHT_APPROVE_TIMECARDS');
       END IF;

       HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES(l_resource_id,
       					   l_timecard_start_time,
       					   l_timecard_stop_time,
       					   hxc_timecard.c_approved_status,
       					   p_messages);

    END IF;

  end light_approve_timecards;

  Function active_assignment_over_period
    (p_timecard_info timecard_info,
     p_timecard_props hxc_timecard_prop_table_type)
    return Boolean is

    l_return     boolean := true;
    l_types_done boolean := false;
    l_pind       binary_integer;

  Begin
    l_pind := p_timecard_props.last;
    Loop
      Exit when ((not p_timecard_props.exists(l_pind))
                 or
                 (not l_return)
                 or
                 (l_types_done)
                 );
      if(p_timecard_props(l_pind).property_name = 'ResourceAssignmentStatusType') then
        if(p_timecard_props(l_pind).date_from <= p_timecard_info.stop_time) then
          if(p_timecard_props(l_pind).date_to >= p_timecard_info.start_time) then
            if(p_timecard_props(l_pind).property_value not in ('ACTIVE_ASSIGN','ACTIVE_CWK',
            						       'SUSP_ASSIGN','TERM_ASSIGN',  -- Bug 8271321
            						       'SUSP_CWK_ASG')) then
              l_return := false;
            end if;
          end if;
        end if;
      else
        l_types_done := true;
      end if;
      l_pind := l_pind - 1;
    End Loop;

    return l_return;
  end active_assignment_over_period;
  -- 115.12
  -- Added timecard properties and messages in case of
  -- non active assignment
  Function begin_approval
    (p_blocks         in            hxc_block_table_type,
     p_item_type      in            wf_items.item_type%type,
     p_process_name   in            wf_process_activities.process_name%type,
     p_resubmitted    in            varchar2,
     p_timecard_props in            hxc_timecard_prop_table_type,
     p_messages       in out nocopy hxc_message_table_type
     ) return VARCHAR2 is

    l_item_key            number;
    l_timecard_id         hxc_time_building_blocks.time_building_block_id%type;
    l_timecard_ovn        hxc_time_building_blocks.object_version_number%type;
    l_new_building_blocks varchar2(3) := 'NO';
    l_proc                varchar2(70);
    l_dummy		  varchar2(1);
    l_active_asg          boolean := true;

    Cursor c_get_appr_style is
      Select APPROVAL_STYLE_ID
        from hxc_approval_styles
       where NAME = 'Approval on Submit' ;

    l_timecard_info		timecard_info;

  Begin

    g_debug := hr_utility.debug_enabled;

    if g_debug then
      l_proc := g_package||'begin_approval';
      hr_utility.set_location('Processing '||l_proc, 10);
    end if;

    get_timecard_information
      (p_blocks       => p_blocks,
       p_timecard_id  => l_timecard_id,
       p_timecard_ovn => l_timecard_ovn,
       p_new_blocks   => l_new_building_blocks,
       p_timecard_info => l_timecard_info
       );

    if g_debug then
      hr_utility.set_location('Processing '||l_proc, 20);
    end if;

    IF g_light_approval_style_id = -99 then
      if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
      end if;

      open c_get_appr_style;
      fetch c_get_appr_style into g_light_approval_style_id;
      close c_get_appr_style ;

    end if;
    -- 115.12 Call active assignment over period, if false
    -- we must use approve on submit approval style
    l_active_asg := active_assignment_over_period(l_timecard_info,p_timecard_props);

    If ((l_timecard_info.approval_style_id <> g_light_approval_style_id)
       AND
        (l_active_asg)) then

      if g_debug then
	hr_utility.set_location('Processing '||l_proc, 40);
      end if;

      l_item_key := get_item_key;
      hxc_approval_wf_pkg.start_approval_wf_process
        (p_item_type      => p_item_type,
         p_item_key       => to_char(l_item_key),
         p_process_name   => p_process_name,
         p_tc_bb_id       => l_timecard_id,
         p_tc_ovn         => l_timecard_ovn,
         p_tc_resubmitted => p_resubmitted,
         p_bb_new         => l_new_building_blocks
         );

    else
      if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
      end if;
      light_approve_timecards
        (p_tc_bb_id       => l_timecard_id,
         p_tc_ovn         => l_timecard_ovn,
         p_tc_resubmitted => p_resubmitted,
         p_blocks         => p_blocks,
         p_timecard_info  => l_timecard_info,
         p_messages	  => p_messages
         );
    end if;
    -- If the timekeeper has entered time for a suspended or
    -- other non-active assignment, we should inform them
    -- that the timecard has been auto-approved.
    if(not l_active_asg) then
      -- Add informational Message
      hxc_timecard_message_helper.addErrorToCollection
        (p_messages,
         'HXC_366547_INACTIVE_ASG_APPR',
         hxc_timecard.c_business_message,
         null,
         null,
         hxc_timecard.c_hxc,
         l_timecard_id,
         l_timecard_ovn,
         null,
         null
         );
    end if;

    if g_debug then
      hr_utility.set_location('Processing '||l_proc, 60);
    end if;

    return to_char(l_item_key);

  End begin_approval;

end hxc_timecard_approval;

/
