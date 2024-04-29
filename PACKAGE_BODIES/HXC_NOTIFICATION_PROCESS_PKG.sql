--------------------------------------------------------
--  DDL for Package Body HXC_NOTIFICATION_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_NOTIFICATION_PROCESS_PKG" as
/* $Header: hxcnotifprocess.pkb 120.8.12010000.6 2010/05/05 11:05:06 amakrish ship $ */
  g_pkg constant varchar2(30) := 'hxc_notification_process_pkg.';
  g_debug		  BOOLEAN     :=hr_utility.debug_enabled;

--This process activity procedure simply determines whether the previous approval was performed by the supervisor
--the approver.We look it up off the application period id and check the approval mechanism on the corresponding
--approval component id.

PROCEDURE approved_by
     (p_itemtype in     varchar2,
      p_itemkey  in     varchar2,
      p_actid    in     number,
      p_funcmode in     varchar2,
      p_result   in out nocopy varchar2) is

CURSOR c_get_app_mechanism(p_app_bb_id IN NUMBER,p_app_bb_ovn IN NUMBER)
IS
select approval_mechanism
from hxc_approval_comps hac, hxc_app_period_summary haps
where haps.application_period_id = p_app_bb_id
and haps.application_period_ovn = p_app_bb_ovn
and haps.approval_comp_id = hac.approval_comp_id;

l_app_bb_id          hxc_app_period_summary.application_period_id%type;
l_app_bb_ovn         hxc_app_period_summary.application_period_ovn%type;
l_app_mechanism      varchar2(30);
l_label              varchar2(50);
l_approval_style_id  number;
l_preparer_timeout   number;
l_proc constant      varchar2(61) := g_pkg ||'approved_by';

BEGIN
g_debug:=hr_utility.debug_enabled;
   if g_debug then
       	hr_utility.set_location(l_proc, 10);
   end if;

   l_app_bb_id:= wf_engine.GetItemAttrNumber(itemtype  => p_itemtype,
                                 	     itemkey   => p_itemkey,
                                 	     aname     => 'APP_BB_ID');
   l_app_bb_ovn:= wf_engine.GetItemAttrNumber(itemtype  => p_itemtype,
                               		      itemkey   => p_itemkey,
                              		      aname     => 'APP_BB_OVN');
   open c_get_app_mechanism(l_app_bb_id,l_app_bb_ovn);
   fetch c_get_app_mechanism into l_app_mechanism;

--Bug 5361995.
--We should not show the button 'Send to next approver' in the preparer notification when the current
--approver is the final approver
   l_label := wf_engine.GetActivityLabel ( actid => p_actid);

if l_label = 'APPROVAL_NOTIFICATION:APPROVED_BY_APR_INACTION' then

HXC_FIND_NOTIFY_APRS_PKG.is_final_apr(
     p_itemtype ,
     p_itemkey  ,
     p_actid    ,
     p_funcmode ,
     p_result   );

 l_approval_style_id:= wf_engine.GetItemAttrNumber(itemtype  => p_itemtype,
                                                   itemkey   => p_itemkey,
                                                   aname     => 'APPROVAL_STYLE_ID');

 l_preparer_timeout := hxc_notification_helper.preparer_timeout_value(l_approval_style_id);

 wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'APPROVAL_TIMEOUT',
                             avalue   => l_preparer_timeout);

end if;

   if l_app_mechanism = 'HR_SUPERVISOR' then

       if g_debug then
       	    hr_utility.set_location(l_proc, 20);
       end if;
       hxc_approval_wf_helper.set_notif_attribute_values
             (p_itemtype,
              p_itemkey,
              hxc_app_comp_notifications_api.c_action_transfer,
              hxc_app_comp_notifications_api.c_recipient_preparer
      );

       --Bug 5361995.
       if p_result = 'COMPLETE:Y' and l_label = 'APPROVAL_NOTIFICATION:APPROVED_BY_APR_INACTION' then
            p_result := 'COMPLETE:PERSON';
       else
            p_result := 'COMPLETE:SUPERVISOR';
       end if;

    else
       if g_debug then
          hr_utility.set_location(l_proc, 30);
       end if;
       p_result := 'COMPLETE:PERSON';
    end if;

    close c_get_app_mechanism;
exception
  when others then

    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
       if g_debug then
           	hr_utility.set_location(l_proc, 999);
       end if;

    wf_core.context('HXCNOTIFPROCESS', 'hxc_notification_process_pkg.approved_by',
    p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
    raise;
  p_result := '';
  return;
END approved_by;

--This procedure  initializes the loop item attribute value for use with the resending of notifications. It sets
--the loop variable in a safe fashion, ensuring that if by accident an existing workflow comes into this
--procedure it won't fail
PROCEDURE loop_initialization
                     (p_item_type in wf_items.item_type%type,
                      p_item_key in wf_item_activity_statuses.item_key%type,
                      p_resend_number in number) is

BEGIN

      if(hxc_approval_wf_helper.item_attribute_value_exists(p_item_type,p_item_key,'NOTIFICATION_RESEND_COUNTER')) then

            wf_engine.SetItemAttrNumber(itemtype => p_item_type,
                                  itemkey  => p_item_key,
                                  aname    => 'NOTIFICATION_RESEND_COUNTER',
                                  avalue   => p_resend_number);

      else

            wf_engine.AddItemAttr(itemtype => p_item_type,
                                  itemkey  => p_item_key,
                                  aname    => 'NOTIFICATION_RESEND_COUNTER',
                                  number_value   => p_resend_number);

      end if;

END  loop_initialization;


PROCEDURE timeouts_enabled
     (p_itemtype in     varchar2,
      p_itemkey  in     varchar2,
      p_actid    in     number,
      p_funcmode in     varchar2,
      p_result   in out nocopy varchar2) is

CURSOR c_timeout_enabled(p_app_bb_id in number)
IS
select hacn.notification_number_retries
from hxc_app_period_summary haps
     ,hxc_approval_comps hac
     ,hxc_app_comp_notif_usages hacnu
     ,hxc_app_comp_notifications hacn
where haps.application_period_id = p_app_bb_id
 and  haps.approval_comp_id = hac.approval_comp_id
 and  hacnu.approval_comp_id = hac.approval_comp_id
 and  hacnu.approval_comp_ovn = hac.object_version_number
 and  hacnu.comp_notification_id = hacn.comp_notification_id
 and  hacnu.comp_notification_ovn=hacn.object_version_number
 and  hacnu.enabled_flag = 'Y'
 and  hacn.notification_action_code = 'REQUEST-APPROVAL-RESEND';

cursor c_app_comp_pm(p_bb_id number,p_bb_ovn number)
is
select hac.approval_comp_id
from hxc_approval_comps hac,
     hxc_approval_styles has,
    hxc_time_building_blocks htb
where htb.time_building_block_id =p_bb_id
and htb.object_version_number = p_bb_ovn
and htb.approval_style_id = has.approval_style_id
and has.approval_style_id = hac.APPROVAL_STYLE_ID
and hac.approval_mechanism = 'PROJECT_MANAGER'
and hac.parent_comp_id is null
and hac.parent_comp_ovn is null;

CURSOR c_timeout_enabled_pm(p_app_comp_id in number)
IS
select hacn.notification_number_retries
from  hxc_approval_comps hac
     ,hxc_app_comp_notif_usages hacnu
     ,hxc_app_comp_notifications hacn
where hac.approval_comp_id = p_app_comp_id
 and  hacnu.approval_comp_id = hac.approval_comp_id
 and  hacnu.approval_comp_ovn = hac.object_version_number
 and  hacnu.comp_notification_id = hacn.comp_notification_id
 and  hacnu.comp_notification_ovn=hacn.object_version_number
 and  hacnu.enabled_flag = 'Y'
 and  hacn.notification_action_code = 'REQUEST-APPROVAL-RESEND';



l_resend_number               number := 0;
l_approval_style_id           number;
l_app_bb_id                   number;
l_approver_timeout            number;
l_role_name                   varchar2(50);
l_role_display                varchar2(50);
l_user_name                   varchar2(50);
l_user_display                varchar2(50);
l_total_hours                 number;
l_approval_comp_id            number;
p_tc_bbid                     number;
p_tc_bbovn                    number;
l_preparer_role               wf_local_roles.name%type;
l_proc constant        varchar2(61) := g_pkg ||'timeouts_enabled';

BEGIN
g_debug:=hr_utility.debug_enabled;

   if g_debug then
       	hr_utility.set_location(l_proc, 10);
   end if;


  --find application period id item attribute value

   l_app_bb_id:= wf_engine.GetItemAttrNumber(itemtype  => p_itemtype,
                                 	     itemkey   => p_itemkey,
                                 	     aname     => 'APP_BB_ID');

-- We need to set the total hours and Description in this procedure because we are over writing these values in
-- prepare notification process while sending superviosr notification.
wf_engine.SetItemAttrText
  (itemtype => p_itemtype,
   itemkey  => p_itemkey,
   aname    => 'DESCRIPTION',
   avalue   => hxc_find_notify_aprs_pkg.get_description(l_app_bb_id));

l_total_hours:= HXC_FIND_NOTIFY_APRS_PKG.category_timecard_hrs(l_app_bb_id,'');
wf_engine.SetItemAttrNumber(
			      itemtype => p_itemtype,
			      itemkey  => p_itemkey,
			      aname    => 'TOTAL_TC_HOURS',
			      avalue   => l_total_hours);

p_tc_bbid:= wf_engine.GetItemAttrNumber
					  (itemtype => p_itemtype,
					   itemkey  => p_itemkey,
					   aname    => 'TC_BLD_BLK_ID');
p_tc_bbovn:= wf_engine.GetItemAttrNumber
					  (itemtype => p_itemtype,
					   itemkey  => p_itemkey,
					   aname    => 'TC_BLD_BLK_OVN');

open c_app_comp_pm(p_tc_bbid,p_tc_bbovn);
fetch c_app_comp_pm into l_approval_comp_id;

if c_app_comp_pm%found then

	open c_timeout_enabled_pm(l_approval_comp_id);
	fetch c_timeout_enabled_pm into l_resend_number;
	close c_timeout_enabled_pm;

else
	close c_app_comp_pm;
	open c_timeout_enabled(l_app_bb_id);
	fetch c_timeout_enabled into l_resend_number;
	close c_timeout_enabled;
end if;

   if l_resend_number > 0 then
       -- set Approval timeout
       if g_debug then
           hr_utility.set_location(l_proc, 20);
       end if;

       	--Bug 5359397.
       	--TC_FROM_ROLE needs ro reset to preparer role since we are overwriting this attribute with approver role
       	--in reset_for_next_timeout.
       	l_preparer_role := hxc_approval_wf_helper.find_role_for_recipient('PREPARER',p_tc_bbid,p_tc_bbovn);
       	wf_engine.SetItemAttrText(itemtype => p_itemtype,
       				  itemkey  => p_itemkey,
       			          aname    => 'TC_FROM_ROLE',
				  avalue   => l_preparer_role);

       loop_initialization(p_itemtype ,p_itemkey ,l_resend_number-1);

       l_approval_style_id:= wf_engine.GetItemAttrNumber(itemtype  => p_itemtype,
       						 itemkey   => p_itemkey,
						 aname     => 'APPROVAL_STYLE_ID');

       l_approver_timeout := hxc_notification_helper.approver_timeout_value(l_approval_style_id);

       wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'APPROVAL_TIMEOUT',
                                   avalue   => l_approver_timeout);
	wf_engine.SetItemAttrText(
	                            itemtype => p_itemtype,
	                            itemkey  => p_itemkey,
	                            aname    => hxc_approval_wf_helper.c_recipient_code_attribute,
				    avalue   => hxc_app_comp_notifications_api.c_recipient_approver);


       p_result := 'COMPLETE:Y';
    else
          if g_debug then
              	hr_utility.set_location(l_proc, 30);
          end if;
       p_result := 'COMPLETE:N';
    end if;
exception
  when others then

    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
       if g_debug then
           	hr_utility.set_location(l_proc, 999);
       end if;

    wf_core.context('HXCNOTIFPROCESS', 'hxc_notification_process_pkg.timeouts_enabled',
    p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
    raise;
  p_result := '';
  return;

END timeouts_enabled;

PROCEDURE reset_for_next_timeout(p_itemtype in     varchar2,
      p_itemkey  in     varchar2,
      p_actid    in     number,
      p_funcmode in     varchar2,
      p_result   in out nocopy varchar2) is

l_current_recipient           varchar2(30);
l_preparer_timeout            number;
l_admin_timeout               number;
l_approval_style_id           number;
l_tc_from_role                wf_local_roles.name%type;
l_worker_role                 wf_local_roles.name%type;
l_worker_full_name            per_all_people_f.full_name%type;
l_preparer_role               wf_local_roles.name%type;
l_preparer_full_name          per_all_people_f.full_name%type;
l_admin_role                  wf_local_roles.name%type;
l_admin_full_name             per_all_people_f.full_name%type;
l_apr_name		      per_all_people_f.full_name%type;
l_timecard_id                 hxc_time_building_blocks.time_building_block_id%TYPE;
l_timecard_ovn	              hxc_time_building_blocks.time_building_block_id%TYPE;
l_tc_stop_date                date;
l_tc_start_date               date;
l_effective_start_date        date;
l_effective_end_date          date;
l_fyi_subject                 varchar2(1000);
l_recipient_login             fnd_user.user_name%type;
l_recipient_id                number;
l_resend_counter              number;
l_proc constant        varchar2(61) := g_pkg ||'reset_for_next_timeout';
BEGIN

g_debug:=hr_utility.debug_enabled;

   if g_debug then
       	hr_utility.set_location(l_proc, 10);
   end if;

l_timecard_id := wf_engine.GetItemAttrNumber
				    (itemtype => p_itemtype,
				    itemkey  => p_itemkey,
				    aname    => 'TC_BLD_BLK_ID');
l_timecard_ovn := wf_engine.GetItemAttrNumber
				    (itemtype => p_itemtype,
				     itemkey  => p_itemkey,
				     aname    => 'TC_BLD_BLK_OVN');
l_tc_stop_date := wf_engine.GetItemAttrDate(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_STOP');

l_tc_start_date := wf_engine.GetItemAttrDate(
	                            itemtype => p_itemtype,
	                            itemkey  => p_itemkey,
	                            aname    => 'TC_START');

l_effective_end_date := wf_engine.GetItemAttrDate(
					    itemtype => p_itemtype,
					    itemkey  => p_itemkey,
					    aname    => 'APP_END_DATE');

l_effective_start_date := wf_engine.GetItemAttrDate(
	                                    itemtype => p_itemtype,
	                                    itemkey  => p_itemkey,
	                                    aname    => 'APP_START_DATE');

l_current_recipient := wf_engine.getItemAttrText(
	                            itemtype => p_itemtype,
	                            itemkey  => p_itemkey,
	                            aname    => hxc_approval_wf_helper.c_recipient_code_attribute,
				    ignore_notfound => true);

l_approval_style_id:= wf_engine.GetItemAttrNumber(itemtype  => p_itemtype,
					          itemkey   => p_itemkey,
					          aname     => 'APPROVAL_STYLE_ID');

l_worker_role :=hxc_approval_wf_helper.find_role_for_recipient('WORKER',l_timecard_id,l_timecard_ovn);

l_worker_full_name := hxc_approval_wf_helper.find_full_name_from_role(l_worker_role,l_tc_start_date);

l_preparer_role := hxc_approval_wf_helper.find_role_for_recipient('PREPARER',l_timecard_id,l_timecard_ovn);

l_preparer_full_name := hxc_approval_wf_helper.find_full_name_from_role(l_preparer_role,l_tc_start_date);

l_admin_role :=hxc_approval_wf_helper.find_role_for_recipient('ADMIN',l_timecard_id,l_timecard_ovn);

l_admin_full_name := hxc_approval_wf_helper.find_full_name_from_role(l_admin_role,l_tc_start_date);


if  l_current_recipient = hxc_app_comp_notifications_api.c_recipient_approver then

         if g_debug then
	       	hr_utility.set_location(l_proc, 20);
         end if;

	--set the attibutes for the PREPARER

	l_preparer_timeout := hxc_notification_helper.preparer_timeout_value(l_approval_style_id);

        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
	 			    itemkey  => p_itemkey,
				    aname    => 'APPROVAL_TIMEOUT',
			            avalue   => l_preparer_timeout);
	--loop variable seeting is not required as it is already set in the timeout_enabled


	l_tc_from_role :=wf_engine.GetItemAttrText(

					  itemtype => p_itemtype,
					  itemkey  => p_itemkey,
					  aname    => 'TC_APPROVER_FROM_ROLE');
	wf_engine.SetItemAttrText(itemtype => p_itemtype,
			          itemkey  => p_itemkey,
			          aname    => 'TC_FROM_ROLE',
				  avalue   => l_tc_from_role);


	fnd_message.set_name('HXC','HXC_APPR_TO_PREPARER');
	fnd_message.set_token('TIMECARD_START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
	fnd_message.set_token('TIMECARD_STOP_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
	fnd_message.set_token('WORKER_FULL_NAME',l_worker_full_name);
	fnd_message.set_token('APPROVER_FULL_NAME',hxc_approval_wf_helper.find_full_name_from_role(l_tc_from_role,l_tc_start_date));

	l_fyi_subject :=fnd_message.get();

	wf_engine.SetItemAttrText(
				   itemtype => p_itemtype,
				   itemkey  => p_itemkey,
				   aname    => 'FYI_SUBJECT',
			           avalue   => l_fyi_subject);

	wf_engine.SetItemAttrText(
	                      itemtype => p_itemtype,
	                      itemkey  => p_itemkey,
	                      aname    => 'PREPARER_ROLE',
	                      avalue   => l_preparer_role );




	wf_engine.SetItemAttrText(
	                            itemtype => p_itemtype,
	                            itemkey  => p_itemkey,
	                            aname    => hxc_approval_wf_helper.c_recipient_code_attribute,
				    avalue   => hxc_app_comp_notifications_api.c_recipient_preparer);


elsif l_current_recipient = hxc_app_comp_notifications_api.c_recipient_preparer then
	--set the attibutes for the ADMIN

	if g_debug then
	   hr_utility.set_location(l_proc, 30);
	end if;

	l_admin_timeout := hxc_notification_helper.admin_timeout_value(l_approval_style_id);
	l_resend_counter := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
	                                                itemkey  => p_itemkey,
	                                                aname    => 'NOTIFICATION_RESEND_COUNTER');
     if l_resend_counter = 0 then
      wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
				    itemkey  => p_itemkey,
				    aname    => 'APPROVAL_TIMEOUT',
				    avalue   => 0);

     else
	wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
				    itemkey  => p_itemkey,
				    aname    => 'APPROVAL_TIMEOUT',
				    avalue   => l_admin_timeout);

	loop_initialization(p_itemtype ,p_itemkey ,l_resend_counter-1);
     end if;

	--loop variable seeting is not required as it is already set in the timeout_enabled
	l_apr_name := wf_engine.GetItemAttrText(itemtype => p_itemtype,
	                                        itemkey  => p_itemkey,
                                                aname    => 'TC_APPROVER_FROM_ROLE');

	fnd_message.set_name('HXC','HXC_APPR_TO_ADMIN');
	fnd_message.set_token('TIMECARD_START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
	fnd_message.set_token('TIMECARD_STOP_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
	fnd_message.set_token('WORKER_FULL_NAME',l_worker_full_name);
	fnd_message.set_token('APPROVER_FULL_NAME',hxc_approval_wf_helper.find_full_name_from_role(l_apr_name,l_tc_start_date));

	l_fyi_subject :=fnd_message.get();



	wf_engine.SetItemAttrText(
				   itemtype => p_itemtype,
				   itemkey  => p_itemkey,
				   aname    => 'FYI_SUBJECT',
			           avalue   => l_fyi_subject);

	wf_engine.SetItemAttrText(itemtype => p_itemtype,
				  itemkey  => p_itemkey,
				  aname    => 'TC_FROM_ROLE',
				  avalue   => l_preparer_role);

	wf_engine.SetItemAttrText(
		                      itemtype => p_itemtype,
		                      itemkey  => p_itemkey,
		                      aname    => 'ADMIN_ROLE',
		                      avalue   => l_admin_role );

	wf_engine.SetItemAttrText(
	                            itemtype => p_itemtype,
	                            itemkey  => p_itemkey,
	                            aname    => hxc_approval_wf_helper.c_recipient_code_attribute,
				    avalue   => hxc_app_comp_notifications_api.c_recipient_admin);

elsif l_current_recipient = hxc_app_comp_notifications_api.c_recipient_admin then

	--In this case all the attributes were already set in the l_current_recipient = 'PREPARER' section.

	   if g_debug then
	       	hr_utility.set_location(l_proc, 40);
	   end if;

	wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
	 			    itemkey  => p_itemkey,
				    aname    => 'APPROVAL_TIMEOUT',
			            avalue   => 0);

end if;

p_result := 'COMPLETE';

exception
  when others then

    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
    if g_debug then
          hr_utility.set_location(l_proc, 999);
    end if;
    wf_core.context('HXCNOTIFPROCESS', 'hxc_notification_process_pkg.reset_for_next_timeout',
    p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
    raise;
  p_result := '';
  return;

end reset_for_next_timeout;

PROCEDURE restart_workflow(p_itemtype in     varchar2,
      p_item_key  in     varchar2,
      p_actid    in     number,
      p_funcmode in     varchar2,
      p_result   in out nocopy varchar2) is

CURSOR c_csr_get_tc_info(
    p_bld_blk_id number,
    p_ovn        number
  )
  IS
   select tc.resource_id, tc.start_time, tc.stop_time,tc.last_updated_by
     from hxc_time_building_blocks tc
    where tc.time_building_block_id = p_bld_blk_id
      and tc.object_version_number = p_ovn;

  CURSOR c_csr_get_appl_periods(
    p_app_bb_id in number
   ,p_app_bb_ovn in number
  )
  IS
   select aps.start_time,                 -- period_start_date
          aps.stop_time,                  -- period_end_date
          aps.time_recipient_id,
          aps.recipient_sequence,
          aps.time_category_id,
          aps.category_sequence
     from hxc_app_period_summary aps
    where  aps.application_period_id = p_app_bb_id
    and aps.application_period_ovn = p_app_bb_ovn;

CURSOR c_is_error_process(p_itemtype in varchar2, p_item_key in varchar2)
is
select parent_item_key
from wf_items
where item_type = p_itemtype
and item_key = p_item_key
and root_activity = 'OTL_ERROR_PROCESS';

cursor c_get_attributes(p_timecard_bb_id in number,p_timecard_ovn in number )
is
  select ta.attribute3,
         ta.attribute4,
         ta.attribute5,
         ta.attribute6
     from hxc_time_attributes ta,
          hxc_time_attribute_usages tau,
          hxc_time_building_blocks tbb
    where tbb.time_building_block_id = p_timecard_bb_id
      and tbb.object_version_number  = p_timecard_ovn
      and tbb.time_building_block_id = tau.time_building_block_id
      and tbb.object_version_number  = tau.time_building_block_ovn
      and ta.time_attribute_id  = tau.time_attribute_id
      and ta.attribute_category = 'SECURITY';
l_timecard_id                   number;
l_timecard_ovn			number;
l_tc_resubmitted		varchar2(10);
l_bb_new			varchar2(10);
l_app_bb_id			number;
l_app_bb_ovn			number;
l_tc_resource_id		number;
l_tc_start_time			date;
l_tc_stop_time			date;
l_last_updated_by		number;
l_process_name 			varchar2(30);
l_period_start_date		date;
l_period_end_date		date;
l_time_recipient		varchar2(150);
l_recipient_sequence		number;
l_time_category_id		hxc_time_categories.time_category_id%TYPE;
l_category_sequence		hxc_approval_comps.approval_order%TYPE;
l_approval_style_id		number;
l_tc_url			varchar2(1000);
l_item_key                      wf_items.item_key%type;
itemkey                         wf_items.item_key%type;
l_user_id       		number;
l_resp_id       		number;
l_resp_appl_id   		number;
l_sec_grp_id     		number;
l_proc constant        varchar2(61) := g_pkg ||'restart_workflow';

begin

g_debug:=hr_utility.debug_enabled;

l_process_name := 'HXC_APPLY_NOTIFY';


 if g_debug then
	hr_utility.set_location(l_proc, 10);
 end if;

--This restart_workflow is called from two places
--1.) When Adminstrator chooses to restart the workflow.
--2.) When Error Adminstrator chosses to restart the workflow.
--In the second case the itemkey passed to this procedure is not the itemkey assoicated with application period id.
--This is a entirely a different item key(error item key). The parent to this error item key is the item key in App bb id.
--So in the second case fetch the parent item key.

open c_is_error_process(p_itemtype,p_item_key);
fetch c_is_error_process into itemkey; -- When Error adminstartor restarts

if c_is_error_process%notfound then
	itemkey := p_item_key; --When Adminstrator restarts
end if;

close c_is_error_process;


l_timecard_id := wf_engine.GetItemAttrNumber
					  (itemtype => p_itemtype,
					   itemkey  => itemkey,
					   aname    => 'TC_BLD_BLK_ID');
l_timecard_ovn := wf_engine.GetItemAttrNumber
                                (itemtype => p_itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'TC_BLD_BLK_OVN');
l_tc_resubmitted := wf_engine.GetItemAttrText
                             (itemtype => p_itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_RESUBMITTED');
l_bb_new := wf_engine.GetItemAttrText
                             (itemtype => p_itemtype,
                              itemkey  => itemkey,
                              aname    => 'BB_NEW');

l_app_bb_id:= wf_engine.GetItemAttrNumber(itemtype  => p_itemtype,
                              		  itemkey   => itemkey,
                              		  aname     => 'APP_BB_ID');

l_app_bb_ovn:= wf_engine.GetItemAttrNumber(itemtype  => p_itemtype,
                              		   itemkey   => itemkey,
                              		   aname     => 'APP_BB_OVN');
open c_csr_get_tc_info(l_timecard_id,
                     l_timecard_ovn);
fetch c_csr_get_tc_info into l_tc_resource_id,
                           l_tc_start_time,
                           l_tc_stop_time,
  		           l_last_updated_by;
close  c_csr_get_tc_info;

open c_get_attributes(l_timecard_id,l_timecard_ovn);
fetch c_get_attributes into l_user_id,l_resp_id,l_resp_appl_id,l_sec_grp_id;
close c_get_attributes;

if l_user_id <> fnd_global.user_id OR l_resp_id <>fnd_global.resp_id
   OR l_resp_appl_id <> fnd_global.resp_appl_id OR l_sec_grp_id <>fnd_global.security_group_id then
 fnd_global.APPS_INITIALIZE(l_user_id,l_resp_id,l_resp_appl_id,l_sec_grp_id);
end if;

		SELECT hxc_approval_item_key_s.nextval
                INTO l_item_key
                FROM dual;


		update hxc_app_period_summary
		set notification_status = 'NOTIFIED',
                      approval_item_type = p_itemtype,
                      approval_process_name = l_process_name,
                      approval_item_key = l_item_key
                where application_period_id = l_app_bb_id
                  and application_period_ovn = l_app_bb_ovn;

             if g_debug then
		hr_utility.trace('l_item_key is : ' || l_item_key);
             end if;

             wf_engine.CreateProcess(itemtype => p_itemtype,
                                     itemkey  => l_item_key,
                                     process  => l_process_name);
             wf_engine.setitemowner(p_itemtype,
                                    p_item_key,
                                    HXC_FIND_NOTIFY_APRS_PKG.get_login(p_person_id=>l_tc_resource_id,
                                                                       p_user_id => l_last_updated_by)
                                    );

             open c_csr_get_appl_periods(l_app_bb_id,l_app_bb_ovn);

	     fetch c_csr_get_appl_periods into l_period_start_date,
	     				     l_period_end_date,
	     				     l_time_recipient,
	                                     l_recipient_sequence,
	                                     l_time_category_id,
                                             l_category_sequence;

	      close c_csr_get_appl_periods;
             if g_debug then
		hr_utility.set_location(l_proc, 20);
             end if;

             wf_engine.SetItemAttrDate(itemtype => p_itemtype,
                                       itemkey  => l_item_key,
                                       aname    => 'APP_START_DATE',
                                       avalue   => l_period_start_date);

             wf_engine.SetItemAttrText(itemtype      => p_itemtype,
                                       itemkey       => l_item_key,
                                       aname         => 'FORMATTED_APP_START_DATE',
                                       avalue        => to_char(l_period_start_date,'YYYY/MM/DD'));
             if g_debug then
                hr_utility.set_location(l_proc, 30);
                hr_utility.trace('APP_START_DATE is : ' ||
                                 to_char(l_period_start_date, 'DD-MM-YYYY'));
             end if;

             wf_engine.SetItemAttrDate(itemtype => p_itemtype,
                                       itemkey  => l_item_key,
                                       aname    => 'APP_END_DATE',
                                       avalue   => l_period_end_date);

             if g_debug then
                hr_utility.set_location(l_proc, 40);
                hr_utility.trace('APP_END_DATE is : ' ||
                                 to_char(l_period_end_date, 'DD-MM-YYYY'));
             end if;

            wf_engine.SetItemAttrNumber(itemtype  => p_itemtype,
                                         itemkey   => l_item_key,
                                         aname     => 'APP_BB_ID',
                                         avalue    => l_app_bb_id);

             if g_debug then
                hr_utility.set_location(l_proc, 50);
                hr_utility.trace('APP_BB_ID is : ' || to_char(l_app_bb_id));
             end if;

             wf_engine.SetItemAttrNumber(itemtype  => p_itemtype,
                                         itemkey   => l_item_key,
                                         aname     => 'APP_BB_OVN',
                                         avalue    => l_app_bb_ovn);


             if g_debug then
                hr_utility.set_location(l_proc, 60);
                hr_utility.trace('APP_BB_OVN is : ' ||
                                 to_char(l_app_bb_ovn));
             end if;

             wf_engine.SetItemAttrNumber(itemtype  => p_itemtype,
                                         itemkey   => l_item_key,
                                         aname     => 'RESOURCE_ID',
                                         avalue    => l_tc_resource_id);

             if g_debug then
                hr_utility.set_location(l_proc, 70);
                hr_utility.trace('RESOURCE_ID is : ' || to_char(l_tc_resource_id));
             end if;

             wf_engine.SetItemAttrText(itemtype  => p_itemtype,
                                       itemkey   => l_item_key,
                                       aname     => 'TIME_RECIPIENT_ID',
                                       avalue    => l_time_recipient);

             if g_debug then
                hr_utility.set_location(l_proc, 80);
                hr_utility.trace('TIME_RECIPIENT_ID is : ' || l_time_recipient);
             end if;

             wf_engine.SetItemAttrText(itemtype   => p_itemtype,
                                       itemkey    => l_item_key,
                                       aname      => 'TC_RESUBMITTED',
                                       avalue     => l_tc_resubmitted);

             if g_debug then
                hr_utility.set_location(l_proc, 90);
                hr_utility.trace('TC_RESUBMITTED is : ' || l_tc_resubmitted);
             end if;

             wf_engine.SetItemAttrText(itemtype   => p_itemtype,
                                       itemkey    => l_item_key,
                                       aname      => 'BB_NEW',
                                       avalue     => l_bb_new);

             if g_debug then
                hr_utility.set_location(l_proc, 100);
                hr_utility.trace('BB_NEW is : ' || l_bb_new);
             end if;

             wf_engine.SetItemAttrNumber(itemtype    => p_itemtype,
                                         itemkey     => l_item_key,
                                         aname       => 'TC_BLD_BLK_ID',
                                         avalue      => l_timecard_id);

             if g_debug then
		hr_utility.set_location(l_proc, 110);
	        hr_utility.trace('TC_BLD_BLK_ID is : ' || to_char(l_timecard_id));
             end if;

             wf_engine.SetItemAttrNumber(itemtype    => p_itemtype,
                                         itemkey     => l_item_key,
                                         aname       => 'TC_BLD_BLK_OVN',
                                         avalue      => l_timecard_ovn);

             if g_debug then
		hr_utility.set_location(l_proc, 120);
	        hr_utility.trace('TC_BLD_BLK_OVN is : ' || to_char(l_timecard_ovn));
             end if;
             l_approval_style_id := hxc_approval_wf_pkg.get_approval_style_id(l_tc_start_time,
	     	                                          l_tc_stop_time,
                                                          l_tc_resource_id);

             wf_engine.SetItemAttrNumber(itemtype    => p_itemtype,
                                         itemkey     => l_item_key,
                                         aname       => 'APPROVAL_STYLE_ID',
                                         avalue      => l_approval_style_id);

	     l_tc_url :='JSP:OA_HTML/OA.jsp?akRegionCode=HXCAPRVPAGE\&akRegionApplicationId=' ||
	                     '809\&retainAM=Y\&Action=Details\&AprvTimecardId=' || l_app_bb_id ||
	                     '\&AprvTimecardOvn=' || l_app_bb_ovn ||
	                     '\&AprvStartTime=' || to_char(l_period_start_date,'YYYY/MM/DD')||
	                     '\&AprvStopTime=' || to_char(l_period_end_date,'YYYY/MM/DD') ||
	                     '\&AprvResourceId=' || to_char(l_tc_resource_id) ||
	                     '\&OAFunc=HXC_TIME_ENTER'||
                             '\&NtfId=-&#NID-';

             wf_engine.SetItemAttrText(itemtype      => p_itemtype,
                                       itemkey       => l_item_key,
                                       aname         => 'HXC_TIMECARD_URL',
                                       avalue        => l_tc_url);

             --
             -- For bug 4291206, copy the previous approvers
             -- in the new process
             -- 115.92 Change.
             --
             hxc_approval_wf_util.copy_previous_approvers
                (p_item_type   => p_itemtype,
                 p_current_key => itemkey,
                 p_copyto_key  => l_item_key);

             -- Update attribute4 with NOTIFIED and attribute2 with the Item Key.


               update hxc_app_period_summary
                  set notification_status = 'NOTIFIED'
                where application_period_id = l_app_bb_id
                  and application_period_ovn = l_app_bb_ovn;


             wf_engine.StartProcess(itemtype => p_itemtype,itemkey  => l_item_key);

p_result := 'COMPLETE';

exception
  when others then

    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
    wf_core.context('HXCNOTIFPROCESS', 'hxc_notification_process_pkg.restart_workflow',
    p_itemtype, l_item_key, to_char(p_actid), p_funcmode);
    raise;
  p_result := '';
  return;
end restart_workflow;


Procedure is_transfer(p_itemtype in     varchar2,
                                 p_itemkey  in     varchar2,
                                 p_actid    in     number,
                                 p_funcmode in     varchar2,
                                 p_result   in out nocopy varchar2) is

cursor c_get_notification(p_itemtype varchar2,p_itemkey varchar2)
is
select wn.original_recipient
  from wf_item_activity_statuses wias,
          wf_process_activities wpa,
          wf_notifications wn
 where wias.item_type = p_itemtype
   and wias.item_key = p_itemkey
   and wias.process_activity = wpa.instance_id
   and wpa.activity_name IN('TC_APR_NOTIFICATION', 'TC_APR_NOTIFICATION_ABS')
   and wias.notification_id = wn.notification_id;

l_notification_id number;
l_original_recipient varchar2(50);
l_approver varchar2(50);

BEGIN

open c_get_notification(p_itemtype,p_itemkey);
fetch c_get_notification into l_original_recipient; --This will fetch the notification id that is in action currently
close c_get_notification;

--Get the present owner of the notification
l_approver := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'APR_SS_LOGIN' );
--Compare the present owner with the original_recipient, if these not same, then it is a transfer action
--Delegate case:
--l_approver = Approver1
--l_original_recipient = Approver1
--Transfer case:
--l_approver = Approver1
--l_original_recipient = Approver2

if l_approver <> l_original_recipient then
--This condition ensures that we are resetting the attribute only in the case of transfer
--If it is a transfer action set the item attribute APR_SS_LOGIN with the new owner i.e. original_recipient.
 wf_engine.SetItemAttrText(itemtype => p_itemtype,
                           itemkey  => p_itemkey,
                           aname   => 'APR_SS_LOGIN',
                           avalue  => l_original_recipient);
 wf_engine.SetItemAttrText(itemtype => p_itemtype,
                           itemkey  => p_itemkey,
                           aname   => 'TC_APPROVER_FROM_ROLE',
                           avalue  => l_original_recipient);
 wf_engine.SetItemAttrText(itemtype => p_itemtype,
                           itemkey  => p_itemkey,
                           aname   => 'TC_FROM_ROLE',
                           avalue  => l_approver);
end if;

p_result := 'COMPLETE';

END is_transfer;


-- Absences start
-- Bug 8888588 - For notification subject when Absences is set

PROCEDURE  exclude_total_hours(p_itemtype in     varchar2,
                          p_itemkey  in     varchar2,
                          p_actid    in     number,
                          p_funcmode in     varchar2,
                          p_result   in out nocopy varchar2) is

l_resource_id 	          per_all_people_f.person_id%type;
l_tc_start_date           date;
l_exclude_hours	          varchar2(1);
l_proc                    varchar2(50) := 'exclude_total_hours';

BEGIN



      l_resource_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                   itemkey  => p_itemkey,
                                                   aname   => 'RESOURCE_ID' );

      l_tc_start_date := wf_engine.GetItemAttrDate(itemtype => p_itemtype,
	                                           itemkey  => p_itemkey,
	                                           aname    => 'TC_START');

      l_exclude_hours := evaluate_abs_pref(l_resource_id,
      			                  trunc(l_tc_start_date)
      			                  );

      IF not(hxc_approval_wf_pkg.item_attribute_exists(p_itemtype, p_itemkey, 'IS_ABS_ENABLED')) THEN

             wf_engine.additemattr
      	            (itemtype     => p_itemtype,
      	             itemkey      => p_itemkey,
      	             aname        => 'IS_ABS_ENABLED',
       	             text_value   => 'N');

      END IF;


      if l_exclude_hours = 'Y' then
	wf_engine.SetItemAttrText(
		   itemtype => p_itemtype,
		   itemkey  => p_itemkey,
		   aname    => 'IS_ABS_ENABLED',
		   avalue   => 'Y');

	p_result := 'COMPLETE:Y';

      else
	wf_engine.SetItemAttrText(
		   itemtype => p_itemtype,
		   itemkey  => p_itemkey,
		   aname    => 'IS_ABS_ENABLED',
		   avalue   => 'N');

	p_result := 'COMPLETE:N';
      end if;


EXCEPTION
  when others then

    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
       if g_debug then
           	hr_utility.set_location(l_proc, 999);
       end if;

    wf_core.context('HXCNOTIFPROCESS', 'hxc_notification_process_pkg.exclude_total_hours',
    p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
    raise;
  p_result := '';
  return;

END exclude_total_hours;


FUNCTION evaluate_abs_pref(p_resource_id IN  NUMBER,
			   p_eval_date   IN DATE)
  return varchar2  is

  l_pref_table              hxc_preference_evaluation.t_pref_table;
  l_abs_integ_enabled	  varchar2(5);
  l_exclude_hours	  varchar2(1) := 'N';

BEGIN

IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
-- Absence Integration Profile is ON
      hxc_preference_evaluation.resource_preferences
                                    (p_resource_id          => p_resource_id,
                                     p_pref_code_list       => 'TS_ABS_PREFERENCES',
                                     p_pref_table           => l_pref_table,
                                     p_evaluation_date      => trunc(p_eval_date)
                                    );

      IF (l_pref_table.COUNT = 1)
      THEN
         l_abs_integ_enabled := nvl(l_pref_table (l_pref_table.FIRST).attribute1, 'N');

         if l_abs_integ_enabled = 'Y' then
            l_exclude_hours := nvl(l_pref_table (l_pref_table.FIRST).attribute8, 'N');
         else
            l_exclude_hours := 'N';
         end if;

      END IF;

ELSE
-- Absence Integration Profile is OFF
      l_exclude_hours := 'N';
END IF;

return l_exclude_hours;

END evaluate_abs_pref;

END hxc_notification_process_pkg;

/
