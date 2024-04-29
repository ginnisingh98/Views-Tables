--------------------------------------------------------
--  DDL for Package Body HXC_WF_ERROR_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_WF_ERROR_HELPER" 	HXC_WF_ERROR_HELPER as
/* $Header: hxcwferrhelper.pkb 120.3.12010000.2 2008/08/05 12:09:27 ubhat ship $ */

g_pkg constant varchar2(30) := 'hxc_wf_error_helper.';
g_debug		  BOOLEAN     :=hr_utility.debug_enabled;

procedure prepare_error(
	 			itemtype     IN varchar2,
                                itemkey      IN varchar2,
                                actid        IN number,
                                funcmode     IN varchar2,
                                result       IN OUT NOCOPY varchar2)
is

l_app_bb_id                      number;
l_app_bb_ovn                     number;
l_timecard_id                    number;
l_timecard_ovn                   number;
l_effective_end_date             date;
l_effective_start_date           date;
l_worker_role                    wf_local_roles.name%type;
l_error_admin_role               wf_local_roles.name%type;
l_total_hours                    number;
l_premium_hours                  number;
l_non_worked_hours               number;
l_description                    varchar2(1000);
l_title                          varchar2(1000);
l_fyi_subject                    varchar2(5000);
l_item_type_desc                 varchar2(1000);
l_worker_full_name               varchar2(1000);
l_error_body                     varchar2(32000);
l_tc_start_date                  date;
l_tc_stop_date                   date;
l_resource_id                    number;
l_itemkey                        wf_items.item_key%type;
l_error                          varchar2(3000);
l_recipient_login                fnd_user.user_name%type;
l_recipient_id                   number;
l_proc constant        varchar2(61) := g_pkg ||'prepare_error';

CURSOR c_tc_info(
          p_tc_bbid hxc_time_building_blocks.time_building_block_id%TYPE
        )
        IS
SELECT tcsum.resource_id,
       tcsum.start_time,
       tcsum.stop_time
  FROM hxc_timecard_summary tcsum
 WHERE  tcsum.timecard_id = p_tc_bbid;

 CURSOR c_tc_info_tbb(
           p_tc_bbid hxc_time_building_blocks.time_building_block_id%TYPE
         )
        IS
 select htb.resource_id, htb.start_time,htb.stop_time
 from hxc_time_building_blocks htb
 where htb.time_building_block_id  =p_tc_bbid
 and htb.scope = 'TIMECARD'
 and htb.object_version_number = (select max(object_version_number)
                                  from hxc_time_building_blocks htb1
                                  where htb.time_building_block_id =htb1.time_building_block_id);


CURSOR c_get_error(p_itemkey wf_items.item_key%type)
is
select error_message
from WF_ITEM_ACTIVITY_STATUSES
where item_type = 'HXCEMP'
and item_key = p_itemkey
and activity_status = 'ERROR';


CURSOR c_get_parent_itemkey(itemkey in wf_items.item_key%type)
is
select parent_item_key
from wf_items
where item_key = itemkey;

BEGIN

g_debug:=hr_utility.debug_enabled;
   if g_debug then
       	hr_utility.set_location(l_proc, 10);
   end if;

--The itemkey passed to this procedure is not the itemkey assoicated with application period id. This is entirely --a different item key(error item key). The parent to this error item key is the item key in App bb id.

open c_get_parent_itemkey(itemkey);
fetch c_get_parent_itemkey into l_itemkey;
close c_get_parent_itemkey;

l_app_bb_id:= wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                              		  itemkey   => l_itemkey,
                              		  aname     => 'APP_BB_ID');

l_app_bb_ovn:= wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                              		   itemkey   => l_itemkey,
                              		   aname     => 'APP_BB_OVN');

l_timecard_id := wf_engine.GetItemAttrNumber
					  (itemtype => itemtype,
					   itemkey  => l_itemkey,
					   aname    => 'TC_BLD_BLK_ID');
l_timecard_ovn := wf_engine.GetItemAttrNumber
					(itemtype => itemtype,
					 itemkey  => l_itemkey,
					 aname    => 'TC_BLD_BLK_OVN');


l_effective_end_date := wf_engine.GetItemAttrDate(
					    itemtype => itemtype,
					    itemkey  => l_itemkey,
					    aname    => 'APP_END_DATE');

l_effective_start_date := wf_engine.GetItemAttrDate(
	                                    itemtype => itemtype,
	                                    itemkey  => l_itemkey,
	                                    aname    => 'APP_START_DATE');
--Instead of fetching these from item attributes, fetch it from sumary table since in the case of
--submission-worker these attributes will not be set.

open c_tc_info(l_timecard_id);
fetch c_tc_info into l_resource_id, l_tc_start_date, l_tc_stop_date;

if c_tc_info%notfound then

     open c_tc_info_tbb(l_timecard_id);
     fetch c_tc_info_tbb into l_resource_id, l_tc_start_date, l_tc_stop_date;
     close c_tc_info_tbb;

end if;

close c_tc_info;

l_worker_role :=HXC_APPROVAL_WF_HELPER.find_role_for_recipient(hxc_app_comp_notifications_api.c_recipient_worker,l_timecard_id,l_timecard_ovn);

if l_worker_role is null then
	l_worker_full_name :=hxc_find_notify_aprs_pkg.get_name(l_resource_id,l_tc_stop_date);
else
	l_worker_full_name := hxc_approval_wf_helper.find_full_name_from_role(l_worker_role,l_tc_start_date);
end if;

l_error_admin_role := hxc_approval_wf_helper.find_role_for_recipient(hxc_app_comp_notifications_api.c_recipient_error_admin,l_timecard_id,l_timecard_ovn);

   if g_debug then
       	hr_utility.set_location(l_proc, 20);
   end if;
wf_engine.SetItemAttrText(itemtype => itemtype,
			  itemkey  => itemkey,
			  aname    => 'TC_FROM_ROLE',
			  avalue   => l_worker_role);
--set TITLE
fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');

--l_effective_start_date and l_effective_end_date will be null when error happens in create_app_period_info, --since in this procedure the itemkey will be the itelkey ascoaited with the timecard,hence we need to pass --timecard start and stop times.

if(l_effective_start_date is null and l_effective_end_date is null) then
  fnd_message.set_token('START_DATE',to_char(l_tc_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
  fnd_message.set_token('END_DATE',to_char(l_tc_stop_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
else
  fnd_message.set_token('START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
  fnd_message.set_token('END_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
end if;

l_title := fnd_message.get();

wf_engine.SetItemAttrText(
			  itemtype => itemtype,
			  itemkey  => itemkey,
			  aname    => 'TITLE',
			  avalue   => l_title);
--set DESCRIPTION

--l_app_bb_id will be null when error happens in create_app_period_info, since in this procedure the itemkey will --be the itelkey ascoaited with the timecard,hence when l_app_bb_id is null total hours should be calculated --based on timecard id
if l_app_bb_id is null then
  wf_engine.SetItemAttrText
    (itemtype => itemtype,
     itemkey  => itemkey,
     aname    => 'DESCRIPTION',
     avalue   => hxc_find_notify_aprs_pkg.get_description_tc(l_timecard_id,l_timecard_ovn)
     );
else
  wf_engine.SetItemAttrText
    (itemtype => itemtype,
     itemkey  => itemkey,
     aname    => 'DESCRIPTION',
     avalue   => hxc_find_notify_aprs_pkg.get_description(l_app_bb_id)
     );
end if;

--set ERROR_BODY
select display_name
into l_item_type_desc
from wf_item_types_vl
where name = 'HXCEMP';

open c_get_error(l_itemkey);
fetch c_get_error into l_error;
close c_get_error;

--set FYI_SUBJECT
fnd_message.set_name('HXC','HXC_APPR_ERROR_SUBJECT');

--l_effective_start_date and l_effective_end_date will be null when error happens in create_app_period_info, --since in this procedure the itemkey will be the itelkey ascoaited with the timecard,hence we need to pass --timecard start and stop times.
if(l_effective_start_date is null and l_effective_end_date is null) then
   fnd_message.set_token('APPLICATION_PERIOD_START_DATE',to_char(l_tc_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
   fnd_message.set_token('APPLICATION_PERIOD_END_DATE',to_char(l_tc_stop_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
else
  fnd_message.set_token('APPLICATION_PERIOD_START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
  fnd_message.set_token('APPLICATION_PERIOD_END_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
end if;

fnd_message.set_token('RESOURCE_FULL_NAME',l_worker_full_name);
fnd_message.set_token('ERROR',l_error);
l_fyi_subject :=fnd_message.get();

wf_engine.SetItemAttrText(
			   itemtype => itemtype,
			   itemkey  => itemkey,
			   aname    => 'FYI_SUBJECT',
			   avalue   => l_fyi_subject);

--set FYI_RECIPIENT_LOGIN
wf_engine.SetItemAttrText(
			      itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'ERROR_ROLE',
			      avalue   =>l_error_admin_role);

fnd_message.set_name('HXC','HXC_APPR_ERROR_BODY');
fnd_message.set_token('ITEM_TYPE_DESC',l_item_type_desc);
fnd_message.set_token('ITEM_TYPE',itemtype);
fnd_message.set_token('ITEM_KEY',l_itemkey);
fnd_message.set_token('ERROR_INFORMATION',l_error);
l_error_body := fnd_message.get();

wf_engine.SetItemAttrText(
			      itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'ERROR_BODY',
			      avalue   =>l_error_body);

   if g_debug then
       	hr_utility.set_location(l_proc, 30);
   end if;


result := 'COMPLETE';
exception
  when others then

    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
       if g_debug then
           	hr_utility.set_location(l_proc, 999);
       end if;

    wf_core.context('HXCERRORHELPER', 'HXC_WF_ERROR_HELPER.prepare_error',
    itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
End prepare_error;

END ;

/
