--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_WF_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_WF_HELPER" as
/* $Header: hxcaprwfhelper.pkb 120.12.12010000.4 2010/01/20 12:34:30 amakrish ship $ */
g_pkg constant varchar2(30) := 'hxc_approval_wf_helper.';
g_debug boolean :=hr_utility.debug_enabled;

-- This will determine the error admin role
FUNCTION find_admin_role(
     p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
    return hxc_approval_styles.admin_role%type
    is

l_admin_role hxc_approval_styles.admin_role%type;
l_proc constant        varchar2(61) := g_pkg ||'find_admin_role';

CURSOR c_admin_role(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
	    ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
is
SELECT
has.admin_role
FROM
hxc_time_building_blocks htbb,
hxc_approval_styles has
WHERE
htbb.time_building_block_id = p_timecard_id      and
htbb.object_version_number = p_timecard_ovn      and
htbb.approval_style_id = has.approval_style_id;


CURSOR c_get_admin
is
select text
from wf_resources
where name = 'WF_ADMIN_ROLE';

BEGIN

if g_debug then
hr_utility.set_location(l_proc, 10);
end if;

open c_admin_role(p_timecard_id,p_timecard_ovn);
fetch c_admin_role into l_admin_role;

if l_admin_role is null then
	--if OTL Admin Role is not found i.e. if user doen't select any OTL Workflow adminstrator in the form
	--then we shall return Workflow Administrator.
	    if g_debug then
		hr_utility.set_location(l_proc, 20);
	    end if;

	open c_get_admin;
	fetch c_get_admin into l_admin_role;
	close c_get_admin;

END if;

close c_admin_role;

if g_debug then
hr_utility.set_location(l_proc, 30);
end if;

return l_admin_role;

END find_admin_role;
--------------------------------------------------------------------------------------

-- This will determine the error admin role

FUNCTION find_error_admin_role(
     p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
    return hxc_approval_styles.error_admin_role%type
    is

l_error_admin_role     hxc_approval_styles.error_admin_role%type;
l_proc constant        varchar2(61) := g_pkg ||'find_error_admin_role';

CURSOR c_error_admin_role(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
		  ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
is
SELECT
has.error_admin_role
FROM
hxc_time_building_blocks htbb,
hxc_approval_styles has
WHERE
htbb.time_building_block_id = p_timecard_id  and
htbb.object_version_number = p_timecard_ovn  and
htbb.approval_style_id = has.approval_style_id;

CURSOR c_get_admin
is
select text
from wf_resources
where name = 'WF_ADMIN_ROLE';

BEGIN

if g_debug then
hr_utility.set_location(l_proc, 10);
end if;

open c_error_admin_role(p_timecard_id,p_timecard_ovn);
fetch c_error_admin_role into l_error_admin_role;

if l_error_admin_role is null then
	--if OTL Error Admin Role is not found i.e. if user doen't select any OTL Error Workflow adminstrator in
                          --the form then we shall return Workflow Administrator.

	 if g_debug then
		hr_utility.set_location(l_proc, 20);
	 end if;
	 open c_get_admin;
	 fetch c_get_admin into l_error_admin_role;
	 close c_get_admin;
END if;

close c_error_admin_role;

if g_debug then
hr_utility.set_location(l_proc, 30);
end if;
return l_error_admin_role;

END find_error_admin_role;
----------------------------------------------------------------------------------------------
FUNCTION  find_preparer_role(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
                        ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
return wf_local_roles.name%type
is

l_user_id               number;
l_person_id             number;
l_name                  wf_local_roles.name%type;
l_display_name          wf_local_roles.display_name%type;
l_proc constant        varchar2(61) := g_pkg ||'find_preparer_role';

CURSOR c_get_user_id(p_user_id IN number)
is
select employee_id
from fnd_user
where user_id = p_user_id;

--Bug 5370557
--Since for a blank timecard there are no detail blocks hence we need to fetch the preparer role from
--the most recent block, it can be TIMECARD,DAY or DETAIL.
CURSOR c_latest_detail_block(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
                  ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
is
select distinct last_updated_by
from hxc_time_building_blocks
where last_update_date =  (select  max(last_update_date)
			   from   HXC_TIME_BUILDING_BLOCKS
			   where  date_to=hr_general.END_of_time
			   connect by prior  time_building_block_id=parent_building_block_id
			   start with  time_building_block_id=p_timecard_id)
and date_to=hr_general.END_of_time
connect by prior  time_building_block_id=parent_building_block_id
start with  time_building_block_id=p_timecard_id;

BEGIN
g_debug:=hr_utility.debug_enabled;
    if g_debug then
 	hr_utility.set_location(l_proc, 10);
    end if;
--The most recent detail building block should be found for the timecard, and the user id on the WHO column for
--that detail used to subsequently pass to the workflow directory service, getrolename, PROCEDURE to obtain the
--appropriate role
open c_latest_detail_block(p_timecard_id,p_timecard_ovn);
fetch c_latest_detail_block into l_user_id;
close c_latest_detail_block;

--Get role form FND system
wf_directory.getrolename( p_orig_system => 'FND_USR',
   	   		  p_orig_system_id => l_user_id,
   		          p_name           => l_name,
    			  p_display_name   => l_display_name);

if l_name is NULL and l_user_id is not NULL then

--If the role name can not be found from the user id, original system is FND, then we should look up the person
--id associated with the user id from the FND_USER record, and try finding the role using the PER orginal system.
    if g_debug then
     	hr_utility.set_location(l_proc, 20);
    end if;

    open c_get_user_id(l_user_id);
    fetch c_get_user_id into l_person_id;
    close c_get_user_id;
    wf_directory.getrolename( p_orig_system => 'PER',
       	   		  p_orig_system_id => l_person_id,
       		          p_name           => l_name,
    			  p_display_name   => l_display_name);
end if;

    if g_debug then
 	hr_utility.set_location(l_proc, 30);
    end if;
return l_name;

END find_preparer_role;

-------------------------------------------------------------------------------------------------
FUNCTION  find_full_name_from_role(p_role_name in wf_local_roles.name%type,
				p_effective_date in date)
return varchar2
is

l_system_id                  wf_local_roles.orig_system_id%type;
l_original_system            wf_local_roles.orig_system%type;
l_full_name                  per_all_people_f.full_name%type;
l_display_name               wf_local_roles.display_name%type;
l_proc constant        varchar2(61) := g_pkg ||'find_full_name_from_role';

CURSOR c_get_original_system(p_role_name in wf_local_roles.name%type)
is
select orig_system,orig_system_id,display_name
from wf_local_roles
where name= p_role_name;

CURSOR c_get_name_ppf(p_system_id in wf_local_roles.orig_system_id%type,
			p_effective_date in date)
is
select full_name
from per_all_people_f
where person_id = p_system_id
and p_effective_date between effective_start_date and effective_end_date;


BEGIN

g_debug:=hr_utility.debug_enabled;
    if g_debug then
 	hr_utility.set_location(l_proc, 10);
    end if;
--Find what is the Original system i.e. PER/FND
open c_get_original_system(p_role_name);
fetch c_get_original_system into l_original_system,l_system_id,l_display_name;
close c_get_original_system;

if(l_original_system = 'PER') then

    if g_debug then
 	hr_utility.set_location(l_proc, 20);
    end if;
--If the original system is PER then we can do a direct query against PER_ALL_PEOPLE_F to fetch the full name.
open c_get_name_ppf(l_system_id, p_effective_date);
fetch c_get_name_ppf into l_full_name;
close c_get_name_ppf;
END if;

if(l_original_system = 'FND_USR') then

    if g_debug then
 	hr_utility.set_location(l_proc, 30);
    end if;

l_full_name := l_display_name;
END if;

return l_full_name;

END find_full_name_from_role;

--------------------------------------------------------------------------------------------------------
FUNCTION  find_supervisor_role(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
                        ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
return  wf_local_roles.name%type
is

l_supervisor_id              per_all_assignments_f.supervisor_id%type;
l_name                       wf_local_roles.name%type;
l_display_name               wf_local_roles.display_name%type;
l_proc constant varchar2(61) := g_pkg ||'find_supervisor_role';

CURSOR c_get_supervisor(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
                      ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
is
      select supervisor_id
      from per_all_assignments_f
      where person_id = (select resource_id
	 	         from hxc_time_building_blocks
		         where time_building_block_id=p_timecard_id
		     	 and object_version_number =p_timecard_ovn)
       and assignment_type in ('E','C')
       and primary_flag = 'Y'
       and sysdate between effective_start_date and effective_END_Date;

BEGIN
    if g_debug then
 	hr_utility.set_location(l_proc, 10);
    end if;
--This FUNCTION uses the HXC_TIME_BUILDING_BLOCKS table and PER_ALL_ASSIGNMENTS_F to find the supervisor
--corresponding to the primary employee or contingent worker assignment, and then subsequently use that
--supervisor id to find the appropriate role from the workflow directory service using the PER original system.

open c_get_supervisor(p_timecard_id,p_timecard_ovn);
fetch c_get_supervisor into l_supervisor_id;
close c_get_supervisor;

wf_directory.getrolename( p_orig_system => 'PER',
   	   		  p_orig_system_id => l_supervisor_id,
   		          p_name           => l_name,
    			  p_display_name   => l_display_name);

return l_name;

END find_supervisor_role;
-----------------------------------------------------------------------------------------------------
FUNCTION  find_worker_role(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
                        ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
return wf_local_roles.name%type
is

l_worker_id                hxc_time_building_blocks.resource_id%TYPE;
l_name                     wf_local_roles.name%type;
l_display_name             wf_local_roles.display_name%type;
l_proc constant varchar2(61) := g_pkg ||'find_worker_role';


CURSOR c_get_worker_id(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
                     ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
is
select resource_id
from hxc_time_building_blocks
where time_building_block_id=p_timecard_id
and object_version_number =p_timecard_ovn;


BEGIN
    if g_debug then
 	hr_utility.set_location(l_proc, 10);
    end if;
--This is a private FUNCTION, which is passed the timecard id and object version number. This uses
--HXC_TIME_BUILDING_BLOCKS to locate the resource id associated with the timecard, and from there uses the
--workflow directory service getrolename call to obtain the role associated with the user, using the PER original system.

open c_get_worker_id(p_timecard_id,p_timecard_ovn);
fetch c_get_worker_id into l_worker_id;
close c_get_worker_id;

wf_directory.getrolename( p_orig_system => 'PER',
   	   		  p_orig_system_id => l_worker_id,
   		          p_name           => l_name,
    			  p_display_name   => l_display_name);

    if g_debug then
 	hr_utility.set_location(l_proc, 20);
    end if;

return l_name;

END find_worker_role;

-----------------------------------------------------------------------------------------------------
FUNCTION find_role_for_recipient
              (p_recipient_code in wf_item_attribute_values.text_value%type,
               p_timecard_id    in number,
               p_timecard_ovn   in number)
               Return wf_local_roles.name%type

is
l_role wf_local_roles.name%type;
l_proc constant varchar2(61) := g_pkg ||'find_role_for_recipient';

BEGIN
g_debug:=hr_utility.debug_enabled;
    if g_debug then
 	hr_utility.set_location(l_proc, 10);
    end if;
--This FUNCTION is essentially a switch on the recipient code, to call one of the private specific FUNCTIONs for
--that role, i.e. if recipient code is supervisor then fetch c_the role by calling find_supervisor_role etc.

if(p_recipient_code = hxc_app_comp_notifications_api.c_recipient_admin) then

    if g_debug then
 	hr_utility.set_location(l_proc, 20);
    end if;

    l_role := find_admin_role(p_timecard_id,p_timecard_ovn);

elsif ( p_recipient_code = hxc_app_comp_notifications_api.c_recipient_error_admin) then

    if g_debug then
 	hr_utility.set_location(l_proc, 30);
    end if;

    l_role :=find_error_admin_role(p_timecard_id,p_timecard_ovn);

elsif (p_recipient_code = hxc_app_comp_notifications_api.c_recipient_preparer) then

    if g_debug then
 	hr_utility.set_location(l_proc, 40);
    end if;

    l_role :=find_preparer_role(p_timecard_id,p_timecard_ovn);

elsif(p_recipient_code = hxc_app_comp_notifications_api.c_recipient_supervisor) then

    if g_debug then
 	hr_utility.set_location(l_proc, 50);
    end if;

    l_role :=find_supervisor_role(p_timecard_id,p_timecard_ovn);
elsif (p_recipient_code = hxc_app_comp_notifications_api.c_recipient_worker) then

    if g_debug then
 	hr_utility.set_location(l_proc, 60);
    end if;
    l_role :=find_worker_role(p_timecard_id,p_timecard_ovn);
END if;

return l_role;

END find_role_for_recipient;

-----------------------------------------------------------------------------------------------------

--This helper FUNCTION returns true if the approver resource (person) id passed is the same as the supervisor id
--on the passed worker resource id this FUNCTION returns true, otherwise it returns false

FUNCTION is_approver_supervisor
              (p_approver_resource_id in number,
               p_resource_id in number)
           Return Boolean is
    l_supervisor_id per_all_assignments_f.supervisor_id%type;
    l_proc constant varchar2(61) := g_pkg ||'is_approver_supervisor';

    Cursor get_supervisor(p_resource_id number)
    Is
    select supervisor_id
    from per_all_assignments_f
    where person_id = p_resource_id
    and assignment_type in ('E','C')
    and primary_flag = 'Y'
    and sysdate between effective_start_date and effective_END_Date;

  BEGIN
    g_debug:=hr_utility.debug_enabled;

    open get_supervisor(p_resource_id);
    fetch get_supervisor into l_supervisor_id;
    close get_supervisor;

    if(l_supervisor_id = p_approver_resource_id) then
	    if g_debug then
	 	hr_utility.set_location(l_proc, 10);
            end if;
      	return true;
    else
	    if g_debug then
	 	hr_utility.set_location(l_proc, 20);
            end if;
      	return false;
    END if;

   END is_approver_supervisor;
-----------------------------------------------------------------------------------------------------------

PROCEDURE get_notif_attribute_values
              (p_item_type            in            wf_items.item_type%type,
               p_item_key             in            wf_item_activity_statuses.item_key%type,
               p_app_bb_id            in            number,
               p_notif_action_code       out nocopy varchar2,
               p_notif_recipient_code    out nocopy varchar2,
               p_approval_comp_id        out nocopy number,
               p_can_notify              out nocopy boolean)
        is

l_approval_comp_id number;
p_tc_bbid          number;
p_tc_bbovn         number;
l_proc constant varchar2(61) := g_pkg ||'get_notif_attribute_values';


CURSOR c_get_app_comp_id(p_app_bb_id hxc_time_building_blocks.time_building_block_id%TYPE)
is
select approval_comp_id
from hxc_app_period_summary
where application_period_id = p_app_bb_id;

CURSOR c_get_any_comp_id(p_app_bb_id hxc_time_building_blocks.time_building_block_id%TYPE)
is
select happs.approval_comp_id
from hxc_tc_ap_links htal, hxc_app_period_summary happs
where htal.timecard_id =  p_app_bb_id
and happs.application_period_id = htal.application_period_id
and rownum <2;

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



BEGIN
  g_debug:=hr_utility.debug_enabled;
    if g_debug then
 	hr_utility.set_location(l_proc, 10);
    end if;

--The values for the recipient action code and recipient code are obtained via the safe method.

p_notif_action_code := wf_engine.getitemattrtext
 			(itemtype => p_item_type ,
 	  		 itemkey  => p_item_key  ,
   			 aname    => hxc_approval_wf_helper.c_action_code_attribute,
   			 ignore_notfound => true);

p_notif_recipient_code := wf_engine.getitemattrtext
 			(itemtype => p_item_type,
 	  		 itemkey  => p_item_key  ,
   			 aname    => hxc_approval_wf_helper.c_recipient_code_attribute,
   			 ignore_notfound => true);

--The approval component id is derived from a CURSOR c_based on the passed application building block id.

if p_notif_action_code = 'SUBMISSION' and p_notif_recipient_code = 'WORKER' then

--In the case of the 'WORKER' recipient code, and the 'SUBMISSION' action code, the value passed in the
--application building block id parameter will actually correspond to a timecard id. In this case, the
--application period will have been created, but the item attribute value has yet to be created. We use a
--different CURSOR in this case to find any approval component associated with the application periods which
--have been created as part of this submission.

        if g_debug then
       	     hr_utility.set_location(l_proc, 20);
        end if;
	open c_get_any_comp_id(p_app_bb_id);
	fetch c_get_any_comp_id into l_approval_comp_id;
	close c_get_any_comp_id;
else

        if g_debug then
             hr_utility.set_location(l_proc, 30);
        end if;
	open c_get_app_comp_id(p_app_bb_id);
	fetch c_get_app_comp_id into l_approval_comp_id;
	close c_get_app_comp_id;

END if;

p_tc_bbid:= wf_engine.GetItemAttrNumber
					  (itemtype => p_item_type,
					   itemkey  => p_item_key,
					   aname    => 'TC_BLD_BLK_ID');
p_tc_bbovn:= wf_engine.GetItemAttrNumber
					  (itemtype => p_item_type,
					   itemkey  => p_item_key,
					   aname    => 'TC_BLD_BLK_OVN');


p_approval_comp_id :=l_approval_comp_id;

open c_app_comp_pm(p_tc_bbid,p_tc_bbovn);
fetch c_app_comp_pm into p_approval_comp_id;
close c_app_comp_pm;

--The return boolean, p_can_notify, is set to true by default, and is set to false if any of the action code,
--recipient code or approval component id return parameters are null.

--For the existing workflow action and recipient code will be null and this condition fails and no notification.

if(p_notif_action_code is null OR p_notif_recipient_code is null OR p_approval_comp_id is null)
then
    if g_debug then
      	hr_utility.set_location(l_proc, 40);
    end if;

	p_can_notify :=false;
else
    if g_debug then
 	hr_utility.set_location(l_proc, 50);
    end if;

	p_can_notify :=true;
END if;


END get_notif_attribute_values;

---------------------------------------------------------------------------------------------------------------
--This FUNCTION simply checks that the item attribute value name passed exists for the supplied item type and item key
FUNCTION item_attribute_value_exists
              (p_item_type in wf_items.item_type%type,
               p_item_key  in wf_item_activity_statuses.item_key%type,
               p_name      in wf_item_attribute_values.name%type)
               return boolean is

    l_dummy varchar2(1);

  BEGIN

    select 'Y'
      into l_dummy
      from wf_item_attribute_values
     where item_type = p_item_type
       and item_key = p_item_key
       and name = p_name;

    return true;

  Exception
     When others then
       return false;

  END item_attribute_value_exists;
----------------------------------------------------------------------------------------------------------------
--This is a simple FUNCTION, which given the recipient and action codes works out whether to send a notification
--with the timecard details, or just a text-based FYI notification. Currently all notifications include the
--timecard details, with the exception of the 'Notification to timecard preparer that the timecard is
--approved' - with action codes APPROVED and recipient code PREPARER, these do not contain the details.
FUNCTION  notification_with_details
		(p_notif_action_code      in  varchar2,
                 p_notif_recipient_code   in  varchar2)
 return boolean is

 BEGIN

 if(p_notif_action_code = hxc_app_comp_notifications_api.c_action_approved
 AND p_notif_recipient_code = hxc_app_comp_notifications_api.c_recipient_preparer)
 then
 	return false;
 else
 	return true;
 END if;

 END notification_with_details;
 ---------------------------------------------------------------------------------------------------------------
 PROCEDURE set_notif_attribute_values
               (p_item_type            in wf_items.item_type%type,
                p_item_key             in wf_item_activity_statuses.item_key%type,
                p_notif_action_code    in wf_item_attribute_values.text_value%type,
                p_notif_recipient_code in wf_item_attribute_values.text_value%type)

 is

 BEGIN
g_debug:=hr_utility.debug_enabled;

 --run check PROCEDURE to validate the passed parameters

 hxc_han_bus.chk_notification_action_code(p_notif_action_code);

 hxc_han_bus.chk_notification_recip_code(p_notif_recipient_code);

 --Add via safe method..
 --I.e. for each of the two codes, it checks to see if they exist first, and if so, simply set the right value,
--if not, create them dynamically setting the value at the time. Again this helps ensure that any existing
--process does not fail.

 if(item_attribute_value_exists(p_item_type,p_item_key,c_action_code_attribute)) then

       wf_engine.setitemattrtext
         (itemtype => p_item_type,
          itemkey  => p_item_key,
          aname    => c_action_code_attribute,
          avalue   => p_notif_action_code
         );

    else

       wf_engine.additemattr
         (itemtype     => p_item_type,
          itemkey      => p_item_key,
          aname        =>c_action_code_attribute,
          text_value   => p_notif_action_code
         );

   END if;

   if(item_attribute_value_exists(p_item_type,p_item_key,c_recipient_code_attribute)) then

         wf_engine.setitemattrtext
           (itemtype => p_item_type,
            itemkey  => p_item_key,
            aname    => c_recipient_code_attribute,
            avalue   => p_notif_recipient_code
           );

      else

         wf_engine.additemattr
           (itemtype     => p_item_type,
            itemkey      => p_item_key,
            aname        => c_recipient_code_attribute,
            text_value   => p_notif_recipient_code
           );

   END if;

END  set_notif_attribute_values;

FUNCTION send_notification
             (p_approval_comp_id in number,
              p_action_code      in wf_item_attribute_values.text_value%type,
              p_recipient_code   in wf_item_attribute_values.text_value%type,
              p_timecard_id      in hxc_time_building_blocks.time_building_block_id%type,
              p_timecard_ovn     in hxc_time_building_blocks.object_version_number%type,
              p_app_period_id    in hxc_time_building_blocks.time_building_block_id%type,
              p_app_period_ovn   in hxc_time_building_blocks.object_version_number%type)

Return boolean is


l_result                       boolean;
l_dummy                        varchar2(1) := 'N';
l_app_bb_id                    hxc_time_building_blocks.time_building_block_id%type;
l_timecard_fyi                 varchar2(1000);
l_item_key                     wf_items.item_key%type;
l_tc_url                       varchar2(1000);
l_block_index 		       PLS_INTEGER := 1;
l_tk_audit_item_key            hxc_timecard_summary.tk_audit_item_key%type;
l_resource_id                  hxc_time_building_blocks.resource_id%type;
l_recipient_action_code        wf_item_attribute_values.text_value%type;
l_action_code                  wf_item_attribute_values.text_value%type;
l_notification_id              wf_notifications.notification_id%type;
l_recipient_role               wf_local_roles.name%type;
l_app_mech                     varchar2(30);
l_app_start_date               date;
l_app_end_date                 date;
l_tc_start_date                date;
l_tc_end_date                  date;
l_proc constant varchar2(61) := g_pkg ||'send_notification';


CURSOR c_is_notification_exists(p_approval_comp_id in number,
              p_action_code      in wf_item_attribute_values.text_value%type,
              p_retrieval_code   in wf_item_attribute_values.text_value%type)
is
select 'Y'
from hxc_app_comp_notifications hacn,
     hxc_app_comp_notif_usages hacnu
where hacnu.comp_notification_id = hacn.comp_notification_id
      and hacnu.comp_notification_ovn = hacn.object_version_number
      and hacnu.approval_comp_id = p_approval_comp_id
      and hacn.notification_action_code = p_action_code
      and hacn.notification_recipient_code = p_recipient_code
      and hacnu.enabled_flag = 'Y';



CURSOR c_get_detail_blocks(p_application_period_id in hxc_time_building_blocks.time_building_block_id%type)
is
  select adl.time_building_block_id,
            adl.time_building_block_ovn
    from hxc_ap_detail_links adl
   where adl.application_period_id = p_application_period_id;


CURSOR c_get_notifications(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
			,p_recipient_role in wf_local_roles.name%type)
is
select wias.item_key,
          wn.notification_id,
          wna3.text_value bb_id
   from wf_notifications wn,
           wf_notification_attributes wna1,
           wf_notification_attributes wna2,
           wf_notification_attributes wna3,
           wf_item_activity_statuses wias
 where wn.message_name = 'HXC_GENERIC_NOTIF_MESSAGE'
     and wn.message_type = 'HXCEMP'
     and (wn.recipient_role = p_recipient_role OR wn.original_recipient = p_recipient_role)
     and wna1.notification_id = wn.notification_id
     and wna2.notification_id = wn.notification_id
     and wna3.notification_id = wn.notification_id
     and wna1.name = 'FYI_ACTION_CODE'
     and wna1.text_value  = p_action_code
     and wna2.name = 'FYI_RECIPIENT_CODE'
     and wna2.text_value = p_recipient_code
     and wna3.name = 'APP_BB_ID'
     and wn.notification_id = wias.notification_id
     and wias.item_type = 'HXCEMP'
     and wias.item_key in (
                     select ts.approval_item_key item_key
                       from hxc_timecard_summary ts
                     where ts.timecard_id = p_timecard_id
                     union
                     select aps.approval_item_key item_key
                       from hxc_tc_ap_links tcl,
                               hxc_app_period_summary aps
                    where tcl.timecard_id = p_timecard_id
                       and tcl.application_period_id = aps.application_period_id

                   );

CURSOR c_chk_auto_approve(p_app_bb_id in number)
is

select d.approval_mechanism
from hxc_ap_detail_links a,
hxc_latest_details b,
hxc_app_period_summary c,
hxc_approval_comps d
where a.time_building_block_id in (select time_building_block_id
				from hxc_ap_detail_links
				where application_period_id =p_app_period_id)
and a.application_period_id <>p_app_period_id
and b.time_building_block_id = a.time_building_block_id
and b.object_version_number = a.time_building_block_ovn
and c.application_period_id = a.application_period_id
and c.approval_comp_id = d.approval_comp_id
and d.approval_mechanism <>'AUTO_APPROVE';

CURSOR c_get_app_dates(p_app_bb_id in number)
is
select start_time,stop_time
from hxc_app_period_summary
where application_period_id = p_app_bb_id;

CURSOR c_get_tc_dates(p_timecard_id in number)
is
select start_time,stop_time
from hxc_timecard_summary
where timecard_id = p_timecard_id;


type rec_type is record(p_id hxc_time_building_blocks.time_building_block_id%TYPE,
p_ovn hxc_time_building_blocks.time_building_block_id%TYPE);


TYPE tab_type IS TABLE OF rec_type INDEX BY BINARY_INTEGER;

l_tab_type_a		tab_type;
l_tab_type_b		tab_type;



BEGIN
     if g_debug then
  	hr_utility.set_location(l_proc, 10);
     end if;

open c_is_notification_exists(p_approval_comp_id,p_action_code,p_recipient_code);
fetch c_is_notification_exists into l_dummy;
close c_is_notification_exists;

--This PROCEDURE looks up whether for this approval component id there exists an enabled usage for the passed
--action and recipient codes. If one does not exist, it returns false.
--If the timecard preparer chooses to send the approval notification to the next approver, we will not be having
--any row in the notification for this TRANSFER-PREPARER case since there is no check box on the form for this
--notification, hence we need to bypass the check for the notification check.

--Notify supervisor if the notification is sent to next approver
if p_action_code = 'TRANSFER' and p_recipient_code = 'PREPARER' then
   l_dummy := 'Y';
end if;

if l_dummy <> 'Y' then
	return false;
else
	--If the notification does exist, then we need to check if this notification has already been sent for
	--the set of details which would sent in this notification.

             if g_debug then
	  	hr_utility.set_location(l_proc, 20);
	     end if;

	l_recipient_role :=find_role_for_recipient(p_recipient_code,p_timecard_id,p_timecard_ovn);


	--Now get all the notifications that are sent for this timecard

	open c_get_notifications(p_timecard_id,l_recipient_role);
	fetch c_get_notifications into l_item_key,l_notification_id,l_app_bb_id;
	if(c_get_notifications%found) then

	        if g_debug then
	              hr_utility.set_location(l_proc, 30);
	        end if;

		open c_get_app_dates(p_app_period_id);
		fetch c_get_app_dates into l_app_start_date,l_app_end_date;
		close c_get_app_dates;

		open c_get_tc_dates(p_timecard_id);
		fetch c_get_tc_dates into l_tc_start_date,l_tc_end_date;
		close c_get_tc_dates;
		--For the 'Notify supervisor on approval request' notification, since we are sending only once
		--return false if we found out that notification has been sent.
		if p_action_code = hxc_app_comp_notifications_api.c_action_request_approval
		and p_recipient_code=hxc_app_comp_notifications_api.c_recipient_supervisor
		and trunc(l_tc_end_date - l_tc_start_date) <= (l_app_end_date - l_app_start_date) then

		        if g_debug then
			      hr_utility.set_location(l_proc, 40);
			end if;

			return false;

		else

                       if g_debug then
		       	     hr_utility.set_location(l_proc, 50);
		       end if;

		        --fetch c_detail blocks for current app_bb_id;
			open c_get_detail_blocks(p_app_period_id);
			fetch c_get_detail_blocks bulk collect INTO l_tab_type_a; --l_tab_type.p_id,l_tab_type.p_ovn ;
			close c_get_detail_blocks;

			--fetch c_detail blocks for the app_bb_id found in the CURSOR c_get_notifications

			open c_get_detail_blocks(l_app_bb_id);
			fetch c_get_detail_blocks bulk collect INTO l_tab_type_b;
			close c_get_detail_blocks;
			--Now compare the detail blocks attached with the app_bb_ids. If there exists same
			--detail blocks for these two application periods then that means notification has
			--aldready been sent with the detail and we should not resend the notification with same details.
			if(l_tab_type_a.COUNT = l_tab_type_b.COUNT) then

				loop
					exit when l_block_index > l_tab_type_a.COUNT;

					if((l_tab_type_a(l_block_index).p_id
					     = l_tab_type_b(l_block_index).p_id)
					     AND
					    (l_tab_type_a(l_block_index).p_ovn
					     = l_tab_type_b(l_block_index).p_ovn)) then

					     l_result := false;

					else
					     l_result := true;
					     exit;
					END if;

				l_block_index := l_block_index + 1;
				END LOOP;


			else
			     if g_debug then
			  	hr_utility.set_location(l_proc, 60);
			     end if;

				l_result := true;
		        END if;-- if(l_tab_type_a.COUNT = l_tab_type_b.COUNT)
                END IF;--if p_action_code = 'SUBMISSION' and p_recipient_code='SUPERVISOR' then
	else

	     if g_debug then
	  	hr_utility.set_location(l_proc, 70);
	     end if;

	l_result := true;

	END if;--if(get_notifications%found)

	close c_get_notifications;

END if;--if(is_notification_exists%notfound)


--check for notify worker on timecard submission for TK

if(p_action_code = hxc_app_comp_notifications_api.c_action_submission
and p_recipient_code=hxc_app_comp_notifications_api.c_recipient_worker and l_result = true) then

     if g_debug then
  	hr_utility.set_location(l_proc, 80);
     end if;

select tk_audit_item_key
into l_tk_audit_item_key
from hxc_timecard_summary
where timecard_id= p_timecard_id;

	if(l_tk_audit_item_key is not null) then
	hr_utility.trace('TK itemkey '||l_tk_audit_item_key);
		l_result := false;
	END if;

END if;
--check for notify worker on auto approval

if(p_action_code = hxc_app_comp_notifications_api.c_action_auto_approve and
p_recipient_code=hxc_app_comp_notifications_api.c_recipient_worker and l_result = true) then

     if g_debug then
  	hr_utility.set_location(l_proc, 90);
     end if;

open c_chk_auto_approve(p_app_period_id);
fetch c_chk_auto_approve into l_app_mech;

	if(c_chk_auto_approve%found) then
	--we cannot send auto-approve notification to worker as the same detail block is attached to another
	--application period which does not have auto-approval mechanism.

	l_result := false;
	end if;

close  c_chk_auto_approve;
end if;

-- If it passes all the tests above then return true.

return l_result;

END send_notification;
------------------------------------------------------------------------------------------------------------
PROCEDURE prepare_notification(
	 			itemtype     IN varchar2,
                                itemkey      IN varchar2,
                                actid        IN number,
                                funcmode     IN varchar2,
                                result       IN OUT NOCOPY varchar2)
is

l_app_bb_id                   hxc_time_building_blocks.time_building_block_id%TYPE;
l_app_bb_ovn                  hxc_time_building_blocks.time_building_block_id%TYPE;
l_action_code                 varchar2(30);
l_recipient_code              varchar2(30);
l_approval_comp_id            number;
l_can_notify                  boolean;
l_timecard_id                 hxc_time_building_blocks.time_building_block_id%TYPE;
l_timecard_ovn	              hxc_time_building_blocks.time_building_block_id%TYPE;
l_tc_from_role                wf_local_roles.name%type;
l_tc_to_role                  wf_local_roles.name%type;
l_title                       varchar2(4000);
l_total_hours                 number ;
l_premium_hours               number ;
l_non_worked_hours            number ;
l_worker_role                 wf_local_roles.name%type;
l_worker_full_name            per_all_people_f.full_name%type;
l_preparer_role               wf_local_roles.name%type;
l_preparer_full_name          per_all_people_f.full_name%type;
l_fyi_subject                 varchar2(4000);
l_description                 varchar2(4000);
l_tc_url                      varchar2(1000);
l_resource_id                 hxc_time_building_blocks.resource_id%type;
l_effective_END_date          date;
l_effective_start_date        date;
l_tc_stop_date                date;
l_tc_start_date               date;
l_apr_rej_reason              varchar2(2000);
l_fyi_no_detail_body          varchar2(4000);
l_recipient_login             fnd_user.user_name%type;
l_recipient_id                number;
l_supervisor_role             wf_local_roles.name%type;
l_tc_id                       number;
l_tc_ovn                      number;
l_apr_person_id               number;
l_apr_name                    per_all_people_f.full_name%type;
l_supervisor_name             per_all_people_f.full_name%type;
l_supervisor_id               number;
l_exclude_hours		      varchar2(1) := 'N';
l_proc               constant varchar2(61) :=g_pkg||'Prepare Notifications';

 CURSOR c_tc_info(
          p_tc_bbid hxc_time_building_blocks.time_building_block_id%TYPE
        )
        IS
        SELECT tcsum.resource_id,
               tcsum.start_time,
               tcsum.stop_time
          FROM hxc_timecard_summary tcsum
         WHERE  tcsum.timecard_id = p_tc_bbid;

CURSOR get_timecards (p_app_bb_id in hxc_timecard_summary.timecard_id%type)

is

select hts.timecard_id,hts.timecard_ovn
from  hxc_tc_ap_links tcl, hxc_timecard_summary hts
where tcl.application_period_id = p_app_bb_id
and tcl.timecard_id = hts.timecard_id;


BEGIN

g_debug:=hr_utility.debug_enabled;

     if g_debug then
  	hr_utility.set_location(l_proc, 10);
     end if;

l_app_bb_id:= wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                              		  itemkey   => itemkey,
                              		  aname     => 'APP_BB_ID');

l_app_bb_ovn:= wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                              		   itemkey   => itemkey,
                              		   aname     => 'APP_BB_OVN');

l_timecard_id := wf_engine.GetItemAttrNumber
					  (itemtype => itemtype,
					   itemkey  => itemkey,
					   aname    => 'TC_BLD_BLK_ID');
l_timecard_ovn := wf_engine.GetItemAttrNumber
					  (itemtype => itemtype,
					   itemkey  => itemkey,
					   aname    => 'TC_BLD_BLK_OVN');

--Instead of fetching these from item attributes, fetch it from sumary table since in the case of
--submission-worker these attributes will not be set.

open c_tc_info(l_timecard_id);
fetch c_tc_info into l_resource_id, l_tc_start_date, l_tc_stop_date;

if c_tc_info%notfound then

	close c_tc_info;
	hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
	hr_utility.set_message_token('PROCEDURE', l_proc);
	hr_utility.set_message_token('STEP', '10');
	hr_utility.raise_error;
END if;

close c_tc_info;

l_effective_end_date := wf_engine.GetItemAttrDate(
					    itemtype => itemtype,
					    itemkey  => itemkey,
					    aname    => 'APP_END_DATE');

l_effective_start_date := wf_engine.GetItemAttrDate(
	                                    itemtype => itemtype,
	                                    itemkey  => itemkey,
	                                    aname    => 'APP_START_DATE');

l_worker_role :=find_role_for_recipient(hxc_app_comp_notifications_api.c_recipient_worker,l_timecard_id,l_timecard_ovn);


--There is a possibility that worker may not be having SS login, in that case worker role will be null.
--But we need to have worker full name for various notification purposes, hence we need to check worker role
--for null, if it is null we need to fetch from the per tables.
if l_worker_role is null then
	l_worker_full_name :=hxc_find_notify_aprs_pkg.get_name(l_resource_id,l_tc_stop_date);
else
	l_worker_full_name := find_full_name_from_role(l_worker_role,l_tc_start_date);
end if;

l_preparer_role := find_role_for_recipient(hxc_app_comp_notifications_api.c_recipient_preparer,l_timecard_id,l_timecard_ovn);

l_preparer_full_name := find_full_name_from_role(l_preparer_role,l_tc_start_date);

     if g_debug then
  	hr_utility.set_location(l_proc, 20);
     end if;

get_notif_attribute_values
      (itemtype,
       itemkey,
       nvl(l_app_bb_id,l_timecard_id), --l_app_bb_id will be null in the case SUBMISSION-WORKER, in that case we
       l_action_code,                 -- we need to pass timecard id not app id.
       l_recipient_code,
       l_approval_comp_id,
       l_can_notify);

     if g_debug then
  	hr_utility.set_location(l_proc, 30);
     end if;

if(l_can_notify) then
     if g_debug then
  	hr_utility.set_location(l_proc, 40);
     end if;
        if(send_notification(l_approval_comp_id,l_action_code,l_recipient_code,l_timecard_id,l_timecard_ovn,l_app_bb_id,l_app_bb_ovn)) then
            if g_debug then
    	       hr_utility.set_location(l_proc, 50);
     	    end if;
           if(notification_with_details(l_action_code,l_recipient_code)) then
                   if g_debug then
	        	hr_utility.set_location(l_proc, 60);
                    end if;

		if(l_action_code=hxc_app_comp_notifications_api.c_action_auto_approve
		and l_recipient_code=hxc_app_comp_notifications_api.c_recipient_worker) then
		             if g_debug then
			  	hr_utility.set_location(l_proc, 70);
                             end if;

				-- set FROM ROLE to Worker Role
				l_tc_from_role :=find_role_for_recipient(hxc_app_comp_notifications_api.c_recipient_worker,l_timecard_id,l_timecard_ovn);
				wf_engine.SetItemAttrText(itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TC_FROM_ROLE',
							  avalue   => l_tc_from_role);
				--set TITLE
				fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
				fnd_message.set_token('START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('END_DATE',to_char(l_effective_END_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

				l_title := fnd_message.get();

				wf_engine.SetItemAttrText(
							  itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TITLE',
							  avalue   => l_title);

				--set DESCRIPTION
				wf_engine.SetItemAttrText
                                  (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DESCRIPTION',
                                   avalue   => hxc_find_notify_aprs_pkg.get_description(l_app_bb_id));
				--set FYI_SUBJECT
				fnd_message.set_name('HXC','HXC_APPR_AUTO_WORKER');
				fnd_message.set_token('START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('END_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('RESOURCE_FULL_NAME',l_worker_full_name);

				l_fyi_subject :=fnd_message.get();

				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => 'FYI_SUBJECT',
							   avalue   => l_fyi_subject);

			        --set FYI_RECIPIENT_LOGIN

				if l_worker_role is null then

				    begin
				    l_worker_role := hxc_approval_helper.createAdHocUser
						 (p_resource_id => l_resource_id,
						  p_effective_date => l_tc_start_date
						 );
				    exception
				       when others then
				     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
				     hr_utility.set_message_token('PROCEDURE', l_proc);
				     hr_utility.set_message_token('STEP', '20');
				     hr_utility.raise_error;
				    end;

				end if;
				wf_engine.SetItemAttrText(
							      itemtype => itemtype,
							      itemkey  => itemkey,
							      aname    => 'FYI_RECIPIENT_LOGIN',
							      avalue   =>l_worker_role);
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_REASSIGN',
							   avalue   => 'Y');
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_MOREINFO',
							   avalue   => 'Y');


			elsif(l_action_code=hxc_app_comp_notifications_api.c_action_rejected and l_recipient_code=hxc_app_comp_notifications_api.c_recipient_preparer) then
                                    if g_debug then
			         	hr_utility.set_location(l_proc, 80);
				    end if;
				--set TC_FROM_ROLE
				l_tc_from_role :=wf_engine.GetItemAttrText(
							  itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'APR_NAME');
				wf_engine.SetItemAttrText(itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TC_FROM_ROLE',
							  avalue   => l_tc_from_role);
				--set TITLE
				fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
				fnd_message.set_token('START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('END_DATE',to_char(l_effective_END_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

				l_title := fnd_message.get();

				wf_engine.SetItemAttrText(
							  itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TITLE',
							  avalue   => l_title);
				--set DESCRIPTION
				wf_engine.SetItemAttrText
                                  (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DESCRIPTION',
                                   avalue   => hxc_find_notify_aprs_pkg.get_description(l_app_bb_id));

				--set FYI_SUBJECT
				fnd_message.set_name('HXC','HXC_APPR_REJ_PREPARER');
				fnd_message.set_token('APPROVER_FULL_NAME',l_tc_from_role);
				fnd_message.set_token('APPLICATION_PERIOD_START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('APPLICATION_PERIOD_STOP_DATE',to_char(l_effective_END_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('RESOURCE_FULL_NAME',l_worker_full_name);

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
							      aname    => 'FYI_RECIPIENT_LOGIN',
							      avalue   => l_preparer_role);

				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_REASSIGN',
							   avalue   => 'Y');
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_MOREINFO',
							   avalue   => 'N');

			elsif(l_action_code=hxc_app_comp_notifications_api.c_action_submission and l_recipient_code=hxc_app_comp_notifications_api.c_recipient_worker) then
			           if g_debug then
			        	hr_utility.set_location(l_proc, 90);
                                   end if;
			       -- We need to attach timecard Id to Application Id..it looks crazy...
			       --but we need to do this as the TIMECARD attribute is using APP_BB_ID
			       --in the URL.
			       wf_engine.SetItemAttrNumber(itemtype  => itemtype,
							   itemkey   => itemkey,
							   aname     => 'APP_BB_ID',
							   avalue    => l_timecard_id);
			       wf_engine.SetItemAttrText(
							itemtype => itemtype,
							itemkey  => itemkey,
							aname    => 'FORMATTED_APP_START_DATE',
							avalue   => to_char(l_tc_start_date,'YYYY/MM/DD'));
				--set TC_FROM_ROLE
				wf_engine.SetItemAttrText(itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TC_FROM_ROLE',
							  avalue   => l_preparer_role);

				--set TITLE
				fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
				fnd_message.set_token('START_DATE',to_char(l_tc_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('END_DATE',to_char(l_tc_stop_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

				l_title := fnd_message.get();

				wf_engine.SetItemAttrText(
							  itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TITLE',
							  avalue   => l_title);
				--set DESCRIPTION
				wf_engine.SetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'DESCRIPTION',
                                                          avalue   => hxc_find_notify_aprs_pkg.get_description_tc(l_timecard_id,l_timecard_ovn));

				-- for bug 8888588
				l_exclude_hours := hxc_notification_process_pkg.evaluate_abs_pref
				                            (l_resource_id,
				                             TRUNC(l_tc_start_date)
				                             );

				IF l_exclude_hours = 'N' THEN
		                	-- Added for bug 6369091
		                	--set TOTAL_HOURS
		                	l_total_hours := hxc_time_category_utils_pkg.category_timecard_hrs_ind(l_timecard_id,l_timecard_ovn,'');
					--set FYI_SUBJECT
					fnd_message.set_name('HXC','HXC_APPR_SUB_WORKER');
					fnd_message.set_token('TOTAL_HOURS',l_total_hours);
				ELSE
					--set FYI_SUBJECT for Absences enabled resource
					fnd_message.set_name('HXC','HXC_APPR_SUB_WORKER_ABS');

				END IF;

				fnd_message.set_token('START_DATE',to_char(l_tc_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('END_DATE',to_char(l_tc_stop_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('RESOURCE_FULL_NAME',l_worker_full_name);
				fnd_message.set_token('PREPARER_FULL_NAME',l_preparer_full_name);

				l_fyi_subject :=fnd_message.get();

				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => 'FYI_SUBJECT',
							   avalue   => l_fyi_subject);

				--set FYI_RECIPIENT_LOGIN
				--Worker role is null that means worker does not have SS login, raise
				--an error.
				if l_worker_role is null then

				    begin
				    l_worker_role := hxc_approval_helper.createAdHocUser
                                                 (p_resource_id => l_resource_id,
                                                  p_effective_date => l_tc_start_date
                                                 );
                                    exception
                                       when others then
				     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
				     hr_utility.set_message_token('PROCEDURE', l_proc);
				     hr_utility.set_message_token('STEP', '30');
				     hr_utility.raise_error;
				    end;

				end if;
				wf_engine.SetItemAttrText(
							      itemtype => itemtype,
							      itemkey  => itemkey,
							      aname    => 'FYI_RECIPIENT_LOGIN',
							      avalue   => l_worker_role);
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_REASSIGN',
							   avalue   => 'Y');
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_MOREINFO',
							   avalue   => 'N');
				wf_engine.SetItemAttrText(
							      itemtype => itemtype,
							      itemkey  => itemkey,
							      aname    => 'RESOURCE_ID',
							      avalue   => l_resource_id);

			elsif(l_action_code=hxc_app_comp_notifications_api.c_action_request_approval and l_recipient_code=hxc_app_comp_notifications_api.c_recipient_supervisor) then
                        	     if g_debug then
				  	hr_utility.set_location(l_proc, 100);
                                     end if;
                                l_supervisor_role :=find_role_for_recipient('SUPERVISOR',l_timecard_id,l_timecard_ovn);

                        	if l_supervisor_role is null then
				     result := 'COMPLETE:NO_NOTIFICATION';
				     return;
            			end if;

				--set TC_FROM_ROLE
				wf_engine.SetItemAttrText(itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TC_FROM_ROLE',
							  avalue   => l_worker_role);
				--set TITLE
				hr_utility.trace('set TITLE');
				fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
				fnd_message.set_token('START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('END_DATE',to_char(l_effective_END_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

				l_title := fnd_message.get();

				wf_engine.SetItemAttrText(
							  itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TITLE',
							  avalue   => l_title);
				--set DESCRIPTION
				wf_engine.SetItemAttrText
                                  (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DESCRIPTION',
                                   avalue   => hxc_find_notify_aprs_pkg.get_description_date(l_effective_start_date,l_effective_end_date,l_resource_id));

				--set FYI_SUBJECT
				l_tc_to_role :=wf_engine.GetItemAttrText(
									  itemtype => itemtype,
									  itemkey  => itemkey,
									  aname    => 'TC_APPROVER_FROM_ROLE');

				fnd_message.set_name('HXC','HXC_APPR_SUB_SUPERVISOR');
				fnd_message.set_token('APPLICATION_PERIOD_START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('APPLICATION_PERIOD_END_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('RESOURCE_FULL_NAME',l_worker_full_name);

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
							      aname    => 'FYI_RECIPIENT_LOGIN',
							      avalue   =>l_supervisor_role );
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_REASSIGN',
							   avalue   => 'Y');
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_MOREINFO',
							   avalue   => 'N');

			  elsif(l_action_code=hxc_app_comp_notifications_api.c_action_transfer and l_recipient_code=hxc_app_comp_notifications_api.c_recipient_preparer) then

				     if g_debug then
					hr_utility.set_location(l_proc, 110);
				     end if;

				wf_engine.SetItemAttrText(itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TC_FROM_ROLE',
							  avalue   => l_preparer_role);
				--set TITLE
				fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
				fnd_message.set_token('START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('END_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

				l_title := fnd_message.get();

				wf_engine.SetItemAttrText(
							  itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TITLE',
							  avalue   => l_title);
				--set DESCRIPTION
				wf_engine.SetItemAttrText
                                  (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DESCRIPTION',
                                   avalue   => hxc_find_notify_aprs_pkg.get_description(l_app_bb_id));

				--set FYI_SUBJECT
				l_apr_person_id :=wf_engine.GetItemAttrText(
							  itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'APR_PERSON_ID');
				l_supervisor_id :=hxc_find_notify_aprs_pkg.get_supervisor(l_apr_person_id,SYSDATE);
				l_supervisor_name :=hxc_find_notify_aprs_pkg.get_name(
				l_supervisor_id,SYSDATE);
			        fnd_message.set_name('HXC','HXC_APPR_TRAN_APPROVER');
				fnd_message.set_token('APPROVER_FULL_NAME',l_preparer_full_name);
				fnd_message.set_token('APPLICATION_PERIOD_START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('APPLICATION_PERIOD_STOP_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('SUPERVISOR_FULL_NAME',l_supervisor_name);

				l_fyi_subject :=fnd_message.get();

				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => 'FYI_SUBJECT',
							   avalue   => l_fyi_subject);
				--set FYI_RECIPIENT_LOGIN
				l_tc_from_role :=hxc_find_notify_aprs_pkg.get_login(p_person_id => l_apr_person_id);

				wf_engine.SetItemAttrText(
							      itemtype => itemtype,
							      itemkey  => itemkey,
							      aname    => 'FYI_RECIPIENT_LOGIN',
							      avalue   => l_tc_from_role);

				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_REASSIGN',
							   avalue   => 'Y');
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_MOREINFO',
							   avalue   => 'N');


		          END if;

		          result := 'COMPLETE:INCLUDE_TIMECARD_DETAILS';

		    else
		           if(l_action_code=hxc_app_comp_notifications_api.c_action_approved and l_recipient_code=hxc_app_comp_notifications_api.c_recipient_preparer) then

			       if g_debug then
				 hr_utility.set_location(l_proc, 120);
			       end if;
				--set TC_FROM_ROLE
				l_tc_from_role :=wf_engine.GetItemAttrText(
							  itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'APR_NAME');
				wf_engine.SetItemAttrText(itemtype => itemtype,
							  itemkey  => itemkey,
							  aname    => 'TC_FROM_ROLE',
							  avalue   => l_tc_from_role);

				--set FYI_SUBJECT
				fnd_message.set_name('HXC','HXC_APPR_APPR_PREPARER');
				fnd_message.set_token('APPROVER_FULL_NAME',l_tc_from_role);
				fnd_message.set_token('TIMECARD_START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('TIMECARD_STOP_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
				fnd_message.set_token('RESOURCE_FULL_NAME',l_worker_full_name);

				l_fyi_subject :=fnd_message.get();

				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => 'FYI_SUBJECT',
							   avalue   => l_fyi_subject);

				-- set  FYI_NO_DETAIL_BODY
				fnd_message.set_name('HXC','HXC_APPR_NO_DETAILS_BODY');
				fnd_message.set_token('PREPARER_FULL_NAME',l_preparer_full_name);



				l_apr_rej_reason :=wf_engine.GetItemAttrText(itemtype => itemtype,
									     itemkey  => itemkey,
									     aname    => 'APR_REJ_REASON');

				fnd_message.set_token('APR_REJ_REASON',l_apr_rej_reason);

				l_fyi_no_detail_body :=fnd_message.get();

				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => 'FYI_NO_DETAIL_BODY',
							   avalue   => l_fyi_no_detail_body);


				wf_engine.SetItemAttrText(
							      itemtype => itemtype,
							      itemkey  => itemkey,
							      aname    => 'FYI_RECIPIENT_LOGIN',
							      avalue   => l_preparer_role);
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_REASSIGN',
							   avalue   => 'Y');
				wf_engine.SetItemAttrText(
							   itemtype => itemtype,
							   itemkey  => itemkey,
							   aname    => '#HIDE_MOREINFO',
							   avalue   => 'N');

			end if;

	   result := 'COMPLETE:TEXT_ONLY';

        END if; -- END Notification with details or not
     else
    	     if g_debug then
	  	hr_utility.set_location(l_proc, 130);
             end if;
    	result := 'COMPLETE:NO_NOTIFICATION';
     END if; -- END SEND Notification

   else
           if g_debug then
        	hr_utility.set_location(l_proc, 140);
           end if;
      result := 'COMPLETE:NO_NOTIFICATION';
   END if;--END can notify or not

    return;

    -- error handler
    hr_utility.trace('Leaving preparing notifications');
exception
  when others then

    -- The line below records this FUNCTION call in the error system
    -- in the case of an exception.
    --

     if g_debug then
     	hr_utility.set_location(l_proc, 999);
     end if;
    wf_core.context('HCAPPRWFHELPER', 'hxc_approval_wf_helper.prepare_notification',
    itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;

END prepare_notification;
----------------------------------------------------------------------------------------------------------------
procedure cleanup(itemtype     IN varchar2,
                  itemkey      IN varchar2,
                  actid        IN number,
                  funcmode     IN varchar2,
                  result       IN OUT NOCOPY varchar2)
is

l_timecard_id  number;
l_app_bb_id    number;
l_app_bb_ovn   number;
l_result       varchar2(50);
l_proc constant        varchar2(61) := g_pkg ||'cleanup';

/*CURSOR c_get_app_periods(p_timecard_id in number)
is
select aps.application_period_id
from hxc_tc_ap_links tcl,
       hxc_app_period_summary aps
where  tcl.timecard_id = p_timecard_id
and tcl.application_period_id = aps.application_period_id ;*/

CURSOR  get_result
is
select text_value
from wf_item_attribute_values
where item_type = itemtype
and item_key = itemkey
and name = 'RESULT';

begin

--Bug 5374013
--We should not 'cleanup' the process in the case of RESTART.
open get_result;
fetch get_result into l_result;
close get_result;

if l_result <> 'RESTART' then

	 l_app_bb_id:= wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => 'APP_BB_ID');
	 l_app_bb_ovn:= wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => 'APP_BB_OVN');

	update hxc_app_period_summary
	    set approval_status = 'SUBMITTED'
	where application_period_id = l_app_bb_id
	and application_period_ovn = l_app_bb_ovn;
end if;

result := 'COMPLETE';

exception
  when others then

    -- The line below records this FUNCTION call in the error system
    -- in the case of an exception.
    --

     if g_debug then
     	hr_utility.set_location(l_proc, 999);
     end if;
    wf_core.context('HCAPPRWFHELPER', 'hxc_approval_wf_helper.cleanup',
    itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;

End cleanup;
----------------------------------------------------------------------------------------------------------------
END HXC_APPROVAL_WF_HELPER;


/
