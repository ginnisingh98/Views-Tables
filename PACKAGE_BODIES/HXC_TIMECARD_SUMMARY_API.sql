--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_SUMMARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_SUMMARY_API" as
/* $Header: hxctcsumapi.pkb 120.0.12010000.3 2008/08/05 12:06:35 ubhat ship $ */
Procedure delete_timecard
            (p_blocks      in hxc_block_table_type
            ,p_timecard_id in number
            ,p_mode        in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
            ) is

l_index number;
l_previous_status       hxc_timecard_summary.approval_status%type;

l_item_key hxc_timecard_summary.approval_item_key%type;
l_dummy varchar2(1);

cursor c_previously_submitted(
			      p_timecard_id in hxc_timecard_summary.timecard_id%type) is
  select ts.approval_status
    from hxc_timecard_summary ts
   where timecard_id = p_timecard_id
     and exists(
		select 1
		  from hxc_tc_ap_links tcl,
		       hxc_app_period_summary aps
		 where aps.application_period_id = tcl.application_period_id
		   and tcl.timecard_id = ts.timecard_id
		   and aps.approval_status = hxc_timecard.c_submitted_status
		);


cursor c_get_item_key(p_timecard_id in number)
is
select approval_item_key
from hxc_timecard_summary
where timecard_id = p_timecard_id;

cursor c_is_wf_deferred(p_item_key in hxc_timecard_summary.approval_item_key%type)
is
select 'Y'
from wf_item_activity_statuses wias
where item_type = 'HXCEMP'
and item_key = l_item_key
and activity_status = 'DEFERRED';

Begin

--
-- 0. Close all nofications associated with this timecard, only
-- if we're not migrating.
-- if we are not migrating, and the timecard is submitted,
-- indicating that there might still be an open notification
-- that requires cancellation.

--
if(p_mode = hxc_timecard_summary_pkg.c_normal_mode) then
  open c_previously_submitted(p_timecard_id);
  fetch c_previously_submitted into l_previous_status;
  if (c_previously_submitted%found)  then
/*
   --Cancel notifications for TK Audit

	hxc_timekeeper_wf_pkg.cancel_previous_notifications
	( p_tk_audit_item_type => l_previous_tk_item_type
	 ,p_tk_audit_item_key =>  l_previous_tk_item_key
	);
*/
   --Cancel notifications for Approval

        hxc_find_notify_aprs_pkg.cancel_previous_notifications
	    (p_timecard_id => p_timecard_id);

  end if;
  close c_previously_submitted;
end if;

-- 1. Remove all the links between the timecard and the application
--    periods

hxc_tc_ap_links_pkg.remove_timecard_links
  (p_timecard_id => p_timecard_id);


open c_get_item_key(p_timecard_id);
fetch c_get_item_key into l_item_key;
close c_get_item_key;

If l_item_key is not null then
	open c_is_wf_deferred(l_item_key);
	fetch c_is_wf_deferred into l_dummy;
	close c_is_wf_deferred;

	If l_dummy = 'Y' then
	 wf_engine.AbortProcess(itemkey => l_item_key,
    				itemtype => 'HXCEMP');
        end if;
end if;


-- 2. Delete the existing timecard information in the summary
--

hxc_timecard_summary_pkg.delete_summary_row
  (p_timecard_id => p_timecard_id);

End delete_timecard;

Procedure delete_timecard
            (p_timecard_id in hxc_timecard_summary.timecard_id%type
            ,p_mode        in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
            ) is

l_index number;

l_dummy varchar(1);

l_item_key hxc_timecard_summary.approval_item_key%type;
l_dummy_ik varchar2(1);

cursor c_previously_submitted(
			      p_timecard_id in hxc_timecard_summary.timecard_id%type) is
  select '1'
    from hxc_timecard_summary
   where timecard_id = p_timecard_id;


cursor c_get_item_key(p_timecard_id in number)
is
select approval_item_key
from hxc_timecard_summary
where timecard_id = p_timecard_id;

cursor c_is_wf_deferred(p_item_key in hxc_timecard_summary.approval_item_key%type)
is
select 'Y'
from wf_item_activity_statuses wias
where item_type = 'HXCEMP'
and item_key = l_item_key
and activity_status = 'DEFERRED';


Begin
--
-- 0. Close all nofications associated with this timecard, only
-- if we're not migrating.
--
if(p_mode = hxc_timecard_summary_pkg.c_normal_mode) then


  open c_previously_submitted(p_timecard_id);
  fetch c_previously_submitted into l_dummy;
  if (c_previously_submitted%found)  then
/*
   --Cancel notifications for TK Audit

	hxc_timekeeper_wf_pkg.cancel_previous_notifications
	( p_tk_audit_item_type => l_previous_tk_item_type
	 ,p_tk_audit_item_key =>  l_previous_tk_item_key
	);
*/
   --Cancel notifications for Approval

	  hxc_find_notify_aprs_pkg.cancel_previous_notifications
	    (p_timecard_id => p_timecard_id);
  end if;
  close c_previously_submitted;

end if;


-- 1. Remove all the links between the timecard and the application
--    periods

hxc_tc_ap_links_pkg.remove_timecard_links
  (p_timecard_id => p_timecard_id);

open c_get_item_key(p_timecard_id);
fetch c_get_item_key into l_item_key;
close c_get_item_key;

If l_item_key is not null then
	open c_is_wf_deferred(l_item_key);
	fetch c_is_wf_deferred into l_dummy_ik;
	close c_is_wf_deferred;

	If l_dummy_ik = 'Y' then
	 wf_engine.AbortProcess(itemkey => l_item_key,
    				itemtype => 'HXCEMP');
        end if;
end if;

-- 2. Delete the existing timecard information in the summary

hxc_timecard_summary_pkg.delete_summary_row
  (p_timecard_id => p_timecard_id);

End delete_timecard;


Function timecard_present
           (p_timecard_id in hxc_timecard_summary.timecard_id%type) return boolean is

l_dummy hxc_timecard_summary.timecard_id%type;

begin

select timecard_id
  into l_dummy
  from hxc_timecard_summary
 where timecard_id = p_timecard_id;

return true;

exception
  when others then
    return false;
end timecard_present;

Procedure cleanup_timecards
            (p_blocks in hxc_block_table_type) is

l_index number;

Begin

l_index := p_blocks.first;

Loop
  Exit when not p_blocks.exists(l_index);

  if(p_blocks(l_index).scope = hxc_timecard.c_timecard_scope) then
    if(timecard_present(p_blocks(l_index).time_building_block_id)) then
      delete_timecard(p_blocks,p_blocks(l_index).time_building_block_id);
    end if;
  end if;

  l_index := p_blocks.next(l_index);
End Loop;

End cleanup_timecards;

procedure timecard_deposit
            (p_blocks in hxc_block_table_type
            ,p_mode   in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
   	    ,p_approval_item_type    in varchar2
	    ,p_approval_process_name in varchar2
	    ,p_approval_item_key     in varchar2
   	    ,p_tk_audit_item_type    in varchar2
	    ,p_tk_audit_process_name in varchar2
	    ,p_tk_audit_item_key     in varchar2
	    ) IS

l_timecard_index number;

Begin
--
-- 1. Find the timecard index of the blocks
--
l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);
--
-- 2. Clean up if this is an existing timecard
--
   cleanup_timecards(p_blocks);
--
-- 3. Create timecard summary info
--
hxc_timecard_summary_pkg.insert_summary_row
  (p_timecard_id => p_blocks(l_timecard_index).time_building_block_id
  ,p_mode        => p_mode
  ,p_approval_item_type    => p_approval_item_type
  ,p_approval_process_name => p_approval_process_name
  ,p_approval_item_key     => p_approval_item_key
  ,p_tk_audit_item_type    => p_tk_audit_item_type
  ,p_tk_audit_process_name => p_tk_audit_process_name
  ,p_tk_audit_item_key     => p_tk_audit_item_key
  );
--
-- 4. Create the link information if the
-- mode is migration
--
if(p_mode = hxc_timecard_summary_pkg.c_migration_mode) then
  hxc_tc_ap_links_pkg.create_timecard_links
   (p_timecard_id => p_blocks(l_timecard_index).time_building_block_id);
end if;
End timecard_deposit;

Procedure timecard_deposit
            (p_timecard_id in hxc_timecard_summary.timecard_id%type
            ,p_mode   in varchar2 default hxc_timecard_summary_pkg.c_normal_mode
	    ,p_approval_item_type    in varchar2
	    ,p_approval_process_name in varchar2
	    ,p_approval_item_key     in varchar2
   	    ,p_tk_audit_item_type    in varchar2
	    ,p_tk_audit_process_name in varchar2
	    ,p_tk_audit_item_key     in varchar2
	    ) is

Begin
--
-- 1. Clean up if this is an existing timecard
-- NOTE: This version is called on migration, and we
-- absolutely don't want to call cleanup_timecards
-- on migration.

  delete_timecard(p_timecard_id, p_mode);
--
-- 3. Create timecard summary info
--
hxc_timecard_summary_pkg.insert_summary_row
  (p_timecard_id           => p_timecard_id
  ,p_mode                  => p_mode
  ,p_approval_item_type    => p_approval_item_type
  ,p_approval_process_name => p_approval_process_name
  ,p_approval_item_key     => p_approval_item_key
  ,p_tk_audit_item_type    => p_tk_audit_item_type
  ,p_tk_audit_process_name => p_tk_audit_process_name
  ,p_tk_audit_item_key     => p_tk_audit_item_key
  );

End timecard_deposit;

Procedure timecard_delete
            (p_blocks in hxc_block_table_type) is

l_timecard_index number;

Begin

l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

delete_timecard(p_blocks,l_timecard_index, hxc_timecard_summary_pkg.c_normal_mode);

End timecard_delete;

Procedure timecard_delete
            (p_timecard_id in hxc_timecard_summary.timecard_id%type) is

Begin

delete_timecard(p_timecard_id, hxc_timecard_summary_pkg.c_normal_mode);

End timecard_delete;

procedure reject_timecards
            (p_application_period_id in hxc_app_period_summary.application_period_id%type) is
--
-- In this case we have a rejection.
-- We should ensure all non-rejected timecards
-- that overlap with this application periods
-- are changed to rejected.
--

cursor c_timecards
         (p_ap_id in hxc_tc_ap_links.application_period_id%type) is
  select ts.timecard_id
    from hxc_tc_ap_links lnk, hxc_timecard_summary ts
   where application_period_id = p_ap_id
     and ts.timecard_id = lnk.timecard_id
     and ts.approval_status <> hxc_timecard.c_rejected_status;

Begin

for tc_rec in c_timecards(p_application_period_id) loop
  hxc_timecard_summary_pkg.reject_timecard(tc_rec.timecard_id);
end loop;

End reject_timecards;

Procedure submit_timecards
            (p_application_period_id in hxc_app_period_summary.application_period_id%type) is

cursor c_timecards_to_check
         (p_id in hxc_app_period_summary.application_period_id%type) is
  select tc1.timecard_id ,tc1.approval_status
    from hxc_timecard_summary tc1, hxc_tc_ap_links lnk1
   where lnk1.application_period_id = p_id
     and lnk1.timecard_id = tc1.timecard_id
     and tc1.approval_status <> hxc_timecard.c_submitted_status;

cursor c_any_reject_app_periods
         (p_id in hxc_tc_ap_links.timecard_id%type) is
  select asm.approval_status
    from hxc_tc_ap_links lnk1, hxc_app_period_summary asm
   where lnk1.timecard_id = p_id
     and lnk1.application_period_id = asm.application_period_id
     and asm.approval_status = hxc_timecard.c_rejected_status;

l_approval_status hxc_app_period_summary.approval_status%type;

Begin

for tc_check in c_timecards_to_check(p_application_period_id) loop
  if(tc_check.approval_status = hxc_timecard.c_approved_status) then
  --
  -- It doesn't matter about the other approval periods
  -- just set the timecards to submitted.
  --
     hxc_timecard_summary_pkg.submit_timecard(tc_check.timecard_id);
  elsif(tc_check.approval_status = hxc_timecard.c_rejected_status) then
  --
  -- It must be rejected, therefore we should check to see if we
  -- can upgrade to submitted status (since we only look for APPROVED
  -- or REJECTED timecards - SUBMITTED timecards do not have to change)
  --
     open c_any_reject_app_periods(tc_check.timecard_id);
     fetch c_any_reject_app_periods into l_approval_status;
     if (c_any_reject_app_periods%notfound) then
     --
     -- There are no more REJECTED app periods update to
     -- submitted.
        hxc_timecard_summary_pkg.submit_timecard(tc_check.timecard_id);
     end if;
     close c_any_reject_app_periods;
  else
     -- Timecard status should not be changed if it is submitted or
     -- working or error.
     null;
  end if;

end loop;

End submit_timecards;

Procedure approve_timecards
            (p_application_period_id in hxc_app_period_summary.application_period_id%type) is

cursor c_timecards_to_check
         (p_id in hxc_app_period_summary.application_period_id%type) is
  select tc1.timecard_id
    from hxc_timecard_summary tc1, hxc_tc_ap_links lnk1
   where lnk1.application_period_id = p_id
     and lnk1.timecard_id = tc1.timecard_id
     and tc1.approval_status = hxc_timecard.c_submitted_status;

cursor c_any_non_approved_app_periods
         (p_timecard_id in hxc_timecard_summary.timecard_id%type) is
  select asm.approval_status
    from hxc_app_period_summary asm, hxc_tc_ap_links lnk1
   where lnk1.timecard_id = p_timecard_id
     and lnk1.application_period_id = asm.application_period_id
     and asm.approval_status <> hxc_timecard.c_approved_status
  order by 1 asc;

l_dummy_approval hxc_app_period_summary.approval_status%type;

Begin

for tc_check in c_timecards_to_check(p_application_period_id) loop
  --
  -- Check for any non-approved application periods for this
  -- application period to see if we can approve this timecard
  --
  open c_any_non_approved_app_periods(tc_check.timecard_id);
  fetch c_any_non_approved_app_periods into l_dummy_approval;
  if (c_any_non_approved_app_periods%notfound) then
    close c_any_non_approved_app_periods;
    --
    -- We can appprove this timecard!
    --
       hxc_timecard_summary_pkg.approve_timecard(tc_check.timecard_id);
  else
     close c_any_non_approved_app_periods;
     if(l_dummy_approval = hxc_timecard.c_rejected_status) then
       hxc_timecard_summary_pkg.reject_timecard(tc_check.timecard_id);
     end if;
  end if;
end loop;

End approve_timecards;

Procedure reevaluate_timecard_statuses
            (p_application_period_id in hxc_app_period_summary.application_period_id%type) is

cursor c_app_period_info
         (p_ap_id in hxc_app_period_summary.application_period_id%type) is
  select approval_status
    from hxc_app_period_summary
   where application_period_id = p_ap_id;

l_approval_status hxc_app_period_summary.approval_status%type;

Begin

open c_app_period_info(p_application_period_id);
fetch c_app_period_info into l_approval_status;
if (c_app_period_info%found) then

  if(l_approval_status = hxc_timecard.c_rejected_status) then
  --
  -- It's easy, reject all timecards associated with this app period
  --
    reject_timecards(p_application_period_id);
  elsif(l_approval_status = hxc_timecard.c_submitted_status) then
  --
  -- Check for submission status
  --
    submit_timecards(p_application_period_id);
  elsif(l_approval_status = hxc_timecard.c_approved_status) then
  --
  -- See if we can approve some timecards!
  --
     approve_timecards(p_application_period_id);

  end if;

end if;
close c_app_period_info;

End reevaluate_timecard_statuses;

end hxc_timecard_summary_api;

/
