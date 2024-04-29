--------------------------------------------------------
--  DDL for Package Body HXC_FIND_NOTIFY_APRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_FIND_NOTIFY_APRS_PKG" as
/* $Header: hxcafnawf.pkb 120.18.12010000.4 2009/07/07 05:55:24 amakrish ship $ */

g_pkg constant varchar2(30) := 'hxc_find_notify_aprs_pkg.';
g_trace VARCHAR2(2000);

g_debug boolean := hr_utility.debug_enabled;

--
-- useful information from time card building block
--
cursor csr_tc_info(b_tc_bbid number, b_tc_bbovn number) is
SELECT tcbb.resource_id,
       tcbb.start_time,
       tcbb.stop_time
FROM   HXC_TIME_BUILDING_BLOCKS tcbb
WHERE  tcbb.time_building_block_id = b_tc_bbid
and    tcbb.object_version_number = b_tc_bbovn;

--
-- useful information from application period building block
--
cursor csr_ap_info(b_ap_bbid number, b_ap_bbovn number) is
SELECT apbb.resource_id,
       apbb.start_time,
       apbb.stop_time,
       ta.attribute1 recipient_app
FROM   HXC_TIME_ATTRIBUTES       ta,
       HXC_TIME_ATTRIBUTE_USAGES tau,
       HXC_TIME_BUILDING_BLOCKS  apbb
WHERE  apbb.time_building_block_id = b_ap_bbid
and    apbb.object_version_number = b_ap_bbovn
and    tau.time_building_block_id =
                                  apbb.time_building_block_id
and    tau.time_building_block_ovn =
                                   apbb.object_version_number
and    ta.time_attribute_id =
                            tau.time_attribute_id;

--
-- find approval component associated with earliest day building block
--
cursor csr_apr_comp(b_ap_bbid number, b_ap_bbovn number,
                    b_time_recipient_id number) is
SELECT apc.approval_mechanism,
       apc.approval_mechanism_id,
       apc.wf_item_type,
       apc.wf_name
FROM   HXC_APPROVAL_COMPS       apc,
       HXC_APPROVAL_STYLES      aps,
       HXC_TIME_BUILDING_BLOCKS htb_time,
       hxc_time_building_blocks htb_appln
WHERE  htb_appln.TIME_BUILDING_BLOCK_ID =  b_ap_bbid  AND
       htb_appln.object_version_number  =  b_ap_bbovn
AND
       htb_time.resource_id  = htb_appln.resource_id  AND
       htb_time.start_time  <= htb_appln.stop_time    AND
       htb_time.stop_time   >= htb_appln.start_time   AND
       htb_time.scope        = 'TIMECARD'             AND
       htb_time.date_to      = hr_general.end_of_time
AND
       aps.approval_style_id = htb_time.approval_style_id
AND
       apc.approval_style_id = aps.approval_style_id  AND
       apc.time_recipient_id = b_time_recipient_id;

--
-- global context information
--
type info_t is record
(
    -- Time Card info
    tc csr_tc_info%rowtype,

    -- Application Period info
    ap csr_ap_info%rowtype,

    -- Approval Componets info
    ac csr_apr_comp%rowtype
);

g_info info_t;



--
-- raise an assert if 'expression' is false
--
procedure assert(
    p_expression in boolean,
    p_message    in varchar2)
is
begin
    if not p_expression then
	hr_utility.set_message(801, 'FFPLU01_ASSERTION_FAILED');
	hr_utility.set_message_token('LOCATION', p_message);
	hr_utility.raise_error;
    end if;
end assert;



-- Format the value according to the provided
-- precision and rounding rule.
--
FUNCTION apply_round_rule(p_rounding_rule     in varchar2,
			  p_decimal_precision in varchar2,
			  p_value             in number)
		  return number
	IS
	l_value      number;
	l_precision  number;

	BEGIN

	l_precision := to_number(p_decimal_precision);

	l_value := p_value;
	 if (p_rounding_rule = 'ROUND_DOWN')
	then
	  l_value := trunc(l_value,l_precision);
	elsif (p_rounding_rule = 'ROUND_TO_NEAREST')
	then
	  l_value := round(l_value,l_precision);
	elsif (p_rounding_rule = 'ROUND_UP')
	then
	  if( l_value > trunc(l_value,l_precision))
	  then
	    l_value := trunc(l_value,l_precision) + power(0.1,l_precision);
	  end if;
        else
	  l_value := round(l_value,l_precision);
	end if;

	return l_value;
end apply_round_rule;


--
-- from person id and effective date find username,
-- name must exist for duration of time card
--

-- Bug 3562755,3855544
function get_name(
    p_person_id      in number,
    p_effective_date in DATE)
return varchar2
is
cursor csr_name(b_person_id NUMBER, b_effective_date DATE) is
select p.full_name from per_people_f p
where p.person_id=b_person_id
and b_effective_date between p.effective_start_date and p.effective_end_date;

cursor csr_closest_name1
                 (b_person_id in number,b_effective_date date) is
            select full_name
              from per_all_people_f
             where person_id = b_person_id
             and  (effective_end_date=(select max(effective_end_date) from per_all_people_f
                where person_id=b_person_id and(effective_end_date<= b_effective_date)));


cursor csr_closest_name2(b_person_id in number,b_effective_date date) is
	select full_name
		from per_all_people_f
	        where person_id = b_person_id
	        and  (effective_start_date=(select min(effective_start_date) from per_all_people_f
				         where person_id=b_person_id and
					(effective_start_date>= b_effective_date)));


    l_temp_name per_all_people_f.full_name%type;
    l_name wf_users.name%type;
    l_display_name wf_users.display_name%type;

begin

	wf_directory.getusername( p_orig_system => 'PER',
	   		          p_orig_system_id => p_person_id,
			          p_name           => l_name,
			          p_display_name   => l_display_name);

if l_display_name is null then

        open csr_name(p_person_id, trunc(p_effective_date));
        fetch csr_name into l_temp_name;
        if csr_name%notfound then
          open csr_closest_name1(p_person_id,trunc(p_effective_date));
          fetch csr_closest_name1 into l_temp_name;
             if csr_closest_name1%notfound then
             open csr_closest_name2(p_person_id,trunc(p_effective_date));
             fetch csr_closest_name2 into l_temp_name;
             close csr_closest_name2;
             end if;
           close csr_closest_name1;
         end if;
    l_display_name:=l_temp_name;
    close csr_name;
    end if;
        return l_display_name;

end get_name;

--
-- from person id and effective date find supervisor
--
function get_supervisor(
    p_person_id      in number,
    p_effective_date in date)
return number
is

    cursor csr_get_supervisor(b_person_id number, b_effective_date date) is
      select asg.supervisor_id
        from per_all_assignments_f asg
       where asg.person_id = b_person_id
         and TRUNC(b_effective_date) between TRUNC(asg.effective_Start_date) and TRUNC(asg.effective_end_date)
         and asg.primary_flag = 'Y'
         and asg.assignment_type in ('E','C');

    l_supervisor_id  per_all_assignments_f.person_id%type;
begin
    open csr_get_supervisor(p_person_id, trunc(p_effective_date));
    fetch csr_get_supervisor into l_supervisor_id;
    close csr_get_supervisor;

    return l_supervisor_id;
end get_supervisor;


--
-- from person id find self service login name
--,
function get_login(
    p_person_id in number,
    p_user_id In NUMBER DEFAULT NULL)
return varchar2
is
l_name wf_local_roles.name%type;
l_display_name wf_local_roles.display_name%type;

-- Bug 3855544

cursor c_get_user(p_usr_id NUMBER) is
select user_name from fnd_user
where user_id=p_usr_id;

begin
   -- Bug 3390666
   -- Fetch the role from wf table instead of fnd_user table.
   wf_directory.GetUserName(p_orig_system    => 'PER',
                            p_orig_system_id => p_person_id,
                            p_name           => l_name,
                            p_display_name   => l_display_name);
    --
    -- if no data found, person does not have a self service login name,
    -- client must handle this and send notification appropriately
    --

if l_name is NULL and p_user_id is not NULL then
open c_get_user(p_user_id);
fetch c_get_user into l_name;
close c_get_user;
end if;


    return l_name;
end get_login;

--
-- +------------------------------------------------------------------------+
-- |                          get_description                               |
-- +------------------------------------------------------------------------+
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to set the description text on a timecard
-- notification, e.g. 3 total hours (0 premium hours, 0 non worked hours).
-- The tokens are only set if the message contains
-- the token, thus permitting the customers to turn off bits of the
-- description they don't want.  This was added for ER 5748501.
--
-- Prerequisites:
--   None.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   Called from hr_supervisor_approval *and* person_approval
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
  function get_description
    (p_application_period_id in hxc_app_period_summary.application_period_id%type)
    return varchar2 is

    l_description fnd_new_messages.message_text%type;
  begin

    fnd_message.set_name('HXC','HXC_APPR_WF_DESCRIPTION');
    l_description := fnd_message.get();
    -- After getting the message, must reset it

    fnd_message.set_name('HXC','HXC_APPR_WF_DESCRIPTION');
    if(instr(l_description,'TOTAL_HOURS')>0) then
      fnd_message.set_token('TOTAL_HOURS',category_timecard_hrs(p_application_period_id,''));
    end if;

    if(instr(l_description,'PREMIUM_HOURS')>0) then
      fnd_message.set_token('PREMIUM_HOURS',category_timecard_hrs(p_application_period_id,'Total2'));
    end if;

    if(instr(l_description,'NON_WORKED_HOURS')>0) then
      fnd_message.set_token('NON_WORKED_HOURS',category_timecard_hrs(p_application_period_id,'Total3'));
    end if;

    return fnd_message.get();

  end get_description;

  function get_description_tc
    (p_timecard_id  in hxc_timecard_summary.timecard_id%type,
     p_timecard_ovn in hxc_timecard_summary.timecard_ovn%type)
   return varchar2 is

    l_description fnd_new_messages.message_text%type;

  begin

    fnd_message.set_name('HXC','HXC_APPR_WF_DESCRIPTION');
    l_description := fnd_message.get();
    -- After getting the message, must reset it

    fnd_message.set_name('HXC','HXC_APPR_WF_DESCRIPTION');
    if(instr(l_description,'TOTAL_HOURS')>0) then
      fnd_message.set_token
        ('TOTAL_HOURS',
         hxc_time_category_utils_pkg.category_timecard_hrs_ind(p_timecard_id,p_timecard_ovn,'')
         );
    end if;

    if(instr(l_description,'PREMIUM_HOURS')>0) then
      fnd_message.set_token
        ('PREMIUM_HOURS',
         hxc_time_category_utils_pkg.category_timecard_hrs_ind(p_timecard_id, p_timecard_ovn,'Total2')
         );
    end if;

    if(instr(l_description,'NON_WORKED_HOURS')>0) then
      fnd_message.set_token
        ('NON_WORKED_HOURS',
         hxc_time_category_utils_pkg.category_timecard_hrs_ind(p_timecard_id, p_timecard_ovn,'Total3')
         );
    end if;

    return fnd_message.get();
  end get_description_tc;

  function get_description_date
    (p_start_date  in date,
     p_end_date    in date,
     p_resource_id in number)
   return varchar2 is

    l_description fnd_new_messages.message_text%type;

  begin

    fnd_message.set_name('HXC','HXC_APPR_WF_DESCRIPTION');
    l_description := fnd_message.get();
    -- After getting the message, must reset it

    fnd_message.set_name('HXC','HXC_APPR_WF_DESCRIPTION');
    if(instr(l_description,'TOTAL_HOURS')>0) then
      fnd_message.set_token('TOTAL_HOURS',category_timecard_hrs(p_start_date,p_end_date,p_resource_id,''));
    end if;

    if(instr(l_description,'PREMIUM_HOURS')>0) then
      fnd_message.set_token('PREMIUM_HOURS',category_timecard_hrs(p_start_date,p_end_date,p_resource_id,'Total2'));
    end if;

    if(instr(l_description,'NON_WORKED_HOURS')>0) then
      fnd_message.set_token('NON_WORKED_HOURS',category_timecard_hrs(p_start_date,p_end_date,p_resource_id,'Total3'));
    end if;

    return fnd_message.get();
  end get_description_date;

--this procedure is called to cancel the other outstanding
--notifications for the same application period.
procedure cancel_notifications(
  p_app_bb_id IN NUMBER,
  p_archived  IN VARCHAR DEFAULT NULL)

IS
-- Bug 3345143.
-- Modified the cursor to fetch item_key associated to the Open notification.
-- Bug 3549092.
--   Changed the get item key cursor so that the item keys
-- are only obtained from the item attribute values table.
-- We then **require** the Begin..End around the abort process
-- because this can obtain completed workflows.  In this case
-- the abort process call will fail, but nothing is wrong.
--

  CURSOR c_get_old_style_item_key(
    p_app_bb_id IN NUMBER
  )
  IS
    select wiav.item_key
      from wf_item_attribute_values wiav
     where wiav.item_type = 'HXCEMP'
       and wiav.name = 'APP_BB_ID'
       and wiav.NUMBER_VALUE = p_app_bb_id;

  CURSOR c_get_item_key(
    p_app_bb_id IN NUMBER )
  IS
      select approval_item_key
      from hxc_app_period_summary
      where application_period_id = p_app_bb_id;

  l_item_key varchar2(240);
  l_old_style_flag BOOLEAN;

BEGIN
  -- Bug 3345143
  --cancel all the notifications associated with current
  --application period and abort the current process.

g_debug := hr_utility.debug_enabled;


if g_debug then
  hr_utility.trace('cancelling notifications for ' || p_app_bb_id);
end if;
--  OPEN c_duplicate_notifications(p_app_bb_id);
--  LOOP
--    FETCH c_duplicate_notifications into l_notification_id;
--    EXIT WHEN c_duplicate_notifications%NOTFOUND;
--    wf_notification.cancel(l_notification_id,
--         'canceled because a new notification is sent');
--    if g_debug then
--	hr_utility.trace('cancelled ' || l_notification_id);
--    end if;
--  END LOOP;
--  CLOSE c_duplicate_notifications;

 l_old_style_flag :=FALSE;

   open c_get_item_key(p_app_bb_id);
   Loop
      fetch c_get_item_key into l_item_key;
      Exit when c_get_item_key%NOTFOUND;
      Begin

        IF l_item_key IS NULL  THEN

   	   l_old_style_flag :=TRUE;

	    OPEN c_get_old_style_item_key(p_app_bb_id);
	    Loop  fetch c_get_old_style_item_key into l_item_key;
            Exit when c_get_old_style_item_key%NOTFOUND;
	    BEGIN
	     --Updating the WF_NOTIFICATION_ATTRIBUTES, incase of archival.
	     IF (p_archived = 'Yes') THEN
	 	     hxc_archive_restore_utils.upd_wf_notif_attributes(p_item_type => 'HXCEMP',p_item_key => l_item_key);
	     END IF;
	     wf_engine.AbortProcess(itemkey => l_item_key,
				itemtype => 'HXCEMP');
	    EXCEPTION
	        When others then
  	        null;
            END;
           End Loop;
	   CLOSE c_get_old_style_item_key;
	 ELSE
	     --Updating the WF_NOTIFICATION_ATTRIBUTES, incase of archival.
	     IF (p_archived = 'Yes') THEN
	 	     hxc_archive_restore_utils.upd_wf_notif_attributes(p_item_type => 'HXCEMP',p_item_key => l_item_key);
	     END IF;
	     wf_engine.AbortProcess(itemkey => l_item_key,
				itemtype => 'HXCEMP');
	 END IF;

      Exception
	 When others then
	    -- Was probably a complete workflow.  Ignore.
	    null;
      End;

    EXIT when l_old_style_flag;

   End Loop;
   close c_get_item_key;

END cancel_notifications;

procedure cancel_previous_notifications
  (p_app_bb_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
  ,p_app_bb_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  ) is

  cursor c_appl_periods
          (p_app_bb_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_app_bb_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
          ) IS
   select distinct apps.time_building_block_id
     from hxc_time_building_blocks apps
         ,hxc_time_building_blocks refapps
    where refapps.resource_id = apps.resource_id
      and refapps.scope = apps.scope
      and refapps.date_to = hr_general.end_of_time
      and refapps.start_time <= apps.stop_time
      and refapps.stop_time >= apps.start_time
      and ((refapps.time_building_block_id <> apps.time_building_block_id)
         OR
           ((refapps.object_version_number <> apps.object_version_number)
           AND
            (refapps.time_building_block_id = apps.time_building_block_id))
          )
      and refapps.time_building_block_id = p_app_bb_id
      and refapps.object_version_number = p_app_bb_ovn;

BEGIN

  FOR ap_rec in c_appl_periods(p_app_bb_id,p_app_bb_ovn) LOOP


    cancel_notifications(ap_rec.time_building_block_id);


  END LOOP;

END cancel_previous_notifications;

procedure cancel_previous_notifications(
  p_itemtype  IN varchar2
 ,p_itemkey   in varchar2
)
IS
  l_resource_id NUMBER;
  l_tc_start    DATE;
  l_tc_stop     DATE;
  l_app_bb_id   hxc_time_building_blocks.time_building_block_id%TYPE;

  CURSOR c_appl_periods(
    p_tc_start_time IN hxc_time_building_blocks.start_time%TYPE
   ,p_tc_stop_time  IN hxc_time_building_blocks.stop_time%TYPE
   ,p_resource_id   IN hxc_time_building_blocks.resource_id%TYPE
  )
  IS
    SELECT time_building_block_id
      FROM hxc_time_building_blocks
     WHERE scope = 'APPLICATION_PERIOD'
       AND resource_id = p_resource_id
       AND date_to = hr_general.end_of_time
       AND TRUNC(start_time) <= TRUNC(p_tc_stop_time)
       AND TRUNC(stop_time) >= TRUNC(p_tc_start_time);


BEGIN
  --cancel all the notifications for all the other application periods
  --associated with the submitted timecard

  l_resource_id := wf_engine.GetItemAttrNumber(
                     itemtype => p_itemtype,
                     itemkey  => p_itemkey,
                     aname    => 'RESOURCE_ID');

  l_tc_start := wf_engine.GetItemAttrDate(
                     itemtype => p_itemtype,
                     itemkey  => p_itemkey,
                     aname    => 'TC_START');

  l_tc_stop := wf_engine.GetItemAttrDate(
                     itemtype => p_itemtype,
                     itemkey  => p_itemkey,
                     aname    => 'TC_STOP');

  OPEN  c_appl_periods(
    p_tc_start_time => l_tc_start
   ,p_tc_stop_time  => l_tc_stop
   ,p_resource_id   => l_resource_id
  );

  LOOP
    FETCH c_appl_periods into l_app_bb_id;
    EXIT WHEN c_appl_periods%NOTFOUND;

    cancel_notifications(l_app_bb_id);
  END LOOP;

  CLOSE c_appl_periods;

END cancel_previous_notifications;




PROCEDURE cancel_previous_notifications(
  p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
)
IS

--bug 4946511.

  CURSOR c_app_periods(
    p_timecard_id hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
  SELECT aps.application_period_id
    FROM hxc_tc_ap_links tcl, hxc_app_period_summary aps
   WHERE tcl.timecard_id = p_timecard_id
     AND tcl.application_period_id = aps.application_period_id
     AND aps.notification_status = 'NOTIFIED';

  l_app_id hxc_time_building_blocks.time_building_block_id%TYPE;

BEGIN
g_debug:=hr_utility.debug_enabled;
  OPEN c_app_periods(p_timecard_id);

  LOOP
    FETCH c_app_periods INTO l_app_id;

    EXIT WHEN c_app_periods%NOTFOUND;

if g_debug then
    hr_utility.trace('in cancelling notifications: found app id=' || l_app_id);
end if;
    cancel_notifications(l_app_id);
  END LOOP;

END cancel_previous_notifications;


--
-- nothing workflow specific here
--
procedure get_context_info(
    p_ap_bb_id  in number,
    p_ap_bb_ovn in number,
    p_tc_bb_id  in number default null,
    p_tc_bb_ovn in number default null)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'get_context_info';
begin
    --
    -- initalise global information structure
    --
    g_info.tc.resource_id := null;
    g_info.tc.start_time := null;
    g_info.tc.stop_time := null;

    g_info.ap.resource_id := null;
    g_info.ap.start_time := null;
    g_info.ap.stop_time := null;
    g_info.ap.recipient_app := null;

    g_info.ac.approval_mechanism := null;
    g_info.ac.approval_mechanism_id := null;
    g_info.ac.wf_item_type := null;
    g_info.ac.wf_name := null;

    --
    -- get time card information if calling in notification mode
    --
    if p_tc_bb_id is not null then
        open csr_tc_info(p_tc_bb_id, p_tc_bb_ovn);
        fetch csr_tc_info into g_info.tc;

        if csr_tc_info%notfound then
            close csr_tc_info;
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '10');
            hr_utility.raise_error;
        end if;

        close csr_tc_info;
    end if;

    --
    -- get application period information
    --
    open csr_ap_info(p_ap_bb_id, p_ap_bb_ovn);
    fetch csr_ap_info into g_info.ap;

    if csr_ap_info%notfound then
        close csr_ap_info;
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '20');
        hr_utility.raise_error;
    end if;

    close csr_ap_info;

    --
    -- get approval component for recipient application,
    -- if no component exists then no approval required
    --
    open csr_apr_comp(p_ap_bb_id, p_ap_bb_ovn, g_info.ap.recipient_app);
    fetch csr_apr_comp into g_info.ac;
    close csr_apr_comp;

    --
    -- dump out pertinent information
    --
    --sb_msgs_pkg.trace('g_info.tc.resource_id          >' || g_info.tc.resource_id || '<');
    --sb_msgs_pkg.trace('g_info.tc.start_time           >' || g_info.tc.start_time || '<');
    --sb_msgs_pkg.trace('g_info.tc.stop_time            >' || g_info.tc.stop_time || '<');

    --sb_msgs_pkg.trace('g_info.ap.resource_id          >' || g_info.ap.resource_id || '<');
    --sb_msgs_pkg.trace('g_info.ap.start_time           >' || g_info.ap.start_time || '<');
    --sb_msgs_pkg.trace('g_info.ap.stop_time            >' || g_info.ap.stop_time || '<');
    --sb_msgs_pkg.trace('g_info.ap.recipient_app        >' || g_info.ap.recipient_app || '<');

    --sb_msgs_pkg.trace('g_info.ac.approval_mechanism   >' || g_info.ac.approval_mechanism || '<');
    --sb_msgs_pkg.trace('g_info.ac.approval_mechanism_id>' || g_info.ac.approval_mechanism_id || '<');
    --sb_msgs_pkg.trace('g_info.ac.wf_item_type         >' || g_info.ac.wf_item_type || '<');
    --sb_msgs_pkg.trace('g_info.ac.wf_name              >' || g_info.ac.wf_name || '<');
end get_context_info;

--
-- for application period building block find type of approval required
--
procedure find_apr_style(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is

    CURSOR c_approval_comp(
      p_ap_bb_id HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
     ,p_ap_bb_ovn HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
    )
    IS
    SELECT apc.approval_mechanism,
           apc.approval_mechanism_id,
           apc.wf_item_type,
           apc.wf_name
      FROM hxc_app_period_summary apsum
          ,hxc_approval_comps apc
     WHERE apsum.application_period_id = p_ap_bb_id
       AND apsum.application_period_ovn = p_ap_bb_ovn
       AND apsum.approval_comp_id = apc.approval_comp_id;


cursor c_approval_comp_alt
        (p_application_period_id in hxc_app_period_summary.application_period_id%type
        ,p_application_period_ovn in hxc_app_period_summary.application_period_ovn%type) is
    SELECT apc.approval_mechanism,
           apc.approval_mechanism_id,
           apc.wf_item_type,
           apc.wf_name
      FROM hxc_app_period_summary apsum
          ,hxc_approval_comps apc
          ,hxc_tc_ap_links tcl
          ,hxc_time_building_blocks tbb
     WHERE apsum.application_period_id = p_application_period_id
       AND apsum.application_period_ovn = p_application_period_ovn
       and apsum.application_period_id = tcl.application_period_id
       and tcl.timecard_id = tbb.time_building_block_id
       and tbb.scope = 'TIMECARD'
       and tbb.date_to = hr_general.end_of_time
       and tbb.approval_style_id = apc.approval_style_id
       and apsum.time_recipient_id = apc.time_recipient_id;

    CURSOR c_tc_info(
      p_tc_bbid hxc_time_building_blocks.time_building_block_id%TYPE
    )
    IS
    SELECT tcsum.resource_id,
           tcsum.start_time,
           tcsum.stop_time
      FROM hxc_timecard_summary tcsum
     WHERE  tcsum.timecard_id = p_tc_bbid;


    l_proc constant varchar2(61) := g_pkg || '.' || 'find_apr_style';
    l_tc_bb_id    hxc_time_building_blocks.time_building_block_id%type;
    l_tc_bb_ovn   hxc_time_building_blocks.time_building_block_id%type;
    l_ap_bb_id    hxc_time_building_blocks.time_building_block_id%type;
    l_ap_bb_ovn   hxc_time_building_blocks.time_building_block_id%type;
    l_login       fnd_user.user_name%type;
    l_resource_id hxc_time_building_blocks.resource_id%TYPE;
    l_tc_start_time hxc_time_building_blocks.start_time%TYPE;
    l_tc_stop_time hxc_time_building_blocks.stop_time%TYPE;
    l_approval_mechanism hxc_approval_comps.approval_mechanism%TYPE;
    l_approval_mechanism_id hxc_approval_comps.approval_mechanism_id%TYPE;
    l_wf_item_type hxc_approval_comps.wf_item_type%TYPE;
    l_wf_name  hxc_approval_comps.wf_name%TYPE;
begin
    g_debug:=hr_utility.debug_enabled;
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');
    g_trace := '10';

    if p_funcmode = 'RUN' then
        l_tc_bb_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_BLD_BLK_ID');

        l_tc_bb_ovn := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_BLD_BLK_OVN');

        l_ap_bb_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_BB_ID');

        l_ap_bb_ovn := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_BB_OVN');

        g_trace := '20';

        if l_tc_bb_id is null or l_tc_bb_ovn is null or
           l_ap_bb_id is null or l_ap_bb_ovn is null then
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '10');
            hr_utility.raise_error;
        end if;

        g_trace := '30';


        --fetch timecard detail
        open c_tc_info(l_tc_bb_id);
        fetch c_tc_info into l_resource_id, l_tc_start_time, l_tc_stop_time;

        if c_tc_info%notfound then

            close c_tc_info;
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '12');
            hr_utility.raise_error;
        end if;

        close c_tc_info;


        g_trace := '40';

        --fetch approval detail
	if g_debug then
		hr_utility.trace('app id=' || l_ap_bb_id);
		hr_utility.trace('app ovn=' || l_ap_bb_ovn);
	end if;
        OPEN c_approval_comp(l_ap_bb_id, l_ap_bb_ovn);
        FETCH c_approval_comp INTO l_approval_mechanism
                                  ,l_approval_mechanism_id
                                  ,l_wf_item_type
                                  ,l_wf_name;


        IF c_approval_comp%NOTFOUND
        THEN
          g_trace := '50';

          CLOSE c_approval_comp;

          --
          -- This should never happen, but if it does
          -- try getting the approval component info
          -- using the other cursor
          --

          open c_approval_comp_alt(l_ap_bb_id, l_ap_bb_ovn);
          FETCH c_approval_comp_alt INTO l_approval_mechanism
                                  ,l_approval_mechanism_id
                                  ,l_wf_item_type
                                  ,l_wf_name;

          if(c_approval_comp_alt%notfound) then
            close c_approval_comp_alt;
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '18');
            hr_utility.raise_error;
          else
            close c_approval_comp_alt;
          end if;

        else
          CLOSE c_approval_comp;
        END IF;
	if g_debug then
		hr_utility.trace('mechanism=' || l_approval_mechanism);
		hr_utility.trace('mechanism_id=' || l_approval_mechanism_id);
		hr_utility.trace('item_type=' || l_wf_item_type);
		hr_utility.trace('wf_name=' || l_wf_name);
	end if;
        g_trace := '60';

        -- set tokens used by all notifications
        --
        wf_engine.SetItemAttrText(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_OWNER',
                                  avalue   => get_name(l_resource_id,l_tc_start_time)
                                 );

        g_trace := '70';
        --
        -- set attribute to specify timecard owner's self service login
        --
        l_login := get_login(p_person_id => l_resource_id);

        g_trace := '80';

        --
        -- if null returned, timecard owner does not have a self
        -- service login name, where does notification get sent?
        --
        if l_login is null then
          g_trace := '90';

              -- 5027063: Try creating an adhoc user
          begin

             l_login := hxc_approval_helper.createAdHocUser
                (p_resource_id => l_resource_id,
                 p_effective_date => l_tc_start_time
                 );

          exception
             when others then
                hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PROCEDURE', l_proc);
                hr_utility.set_message_token('STEP', '20');
                hr_utility.raise_error;
          end;

        end if;

        g_trace := '100';

        --set role attribute
        wf_engine.SetItemAttrText(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_FROM_ROLE',
                                  avalue   => l_login);

        g_trace := '110';

        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_OWNER_SS_LOGIN',
                                  avalue   => l_login);

        g_trace := '120';

        wf_engine.SetItemAttrDate(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_START',
                                  avalue   => l_tc_start_time);
        g_trace := '130';

        wf_engine.SetItemAttrDate(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_STOP',
                                  avalue   => l_tc_stop_time);

        g_trace := '140';

        if l_approval_mechanism = 'AUTO_APPROVE'
        then

          g_trace := '150';
          p_result := 'COMPLETE:AUTO_APPROVE';

        elsif l_approval_mechanism = 'PERSON'
        then
          g_trace := '160';
          --
          -- set parameters required by next activity
          --
          wf_engine.SetItemAttrNumber(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'APR_PERSON_ID',
                                  avalue   => l_approval_mechanism_id);

          g_trace := '170';
          p_result := 'COMPLETE:PERSON';

        elsif l_approval_mechanism = 'HR_SUPERVISOR'
        then
          g_trace := '180';
          wf_engine.SetItemAttrNumber(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'APR_PERSON_ID',
                                  avalue   => l_resource_id);

          g_trace := '190';
          p_result := 'COMPLETE:HR_SUPERVISOR';

-- GPaytonM fix version 115.6

        elsif l_approval_mechanism = 'FORMULA_MECHANISM'
        then
           g_trace := '200';
           wf_engine.SetItemAttrNumber(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'FORMULA_ID',
                                  avalue   => l_approval_mechanism_id);

           g_trace := '210';
           p_result := 'COMPLETE:FORMULA';

        elsif l_approval_mechanism = 'WORKFLOW'
        then

          g_trace := '220';
          wf_engine.SetItemAttrText(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'WF_ITEM_TYPE',
                                  avalue   => l_wf_item_type);

          wf_engine.SetItemAttrText(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'WF_PROCESS_NAME',
                                  avalue   => l_wf_name);

          g_trace := '230';
          p_result := 'COMPLETE:WORKFLOW';

        elsif l_approval_mechanism = 'PROJECT_MANAGER'
        then
          g_trace := '240';
          p_result := 'COMPLETE:PROJECT_MANAGER';

        else
          g_trace := '250';
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP', '30');
          hr_utility.raise_error;
        end if;

    end if;

    g_trace := '260';
    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    g_trace := '270';
    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    g_trace := '300';
exception
    when others then

        --
        -- record this function call in the error system in case of an exception
        --
        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode,
                        l_proc || '|' || g_trace);
        raise;
end find_apr_style;


PROCEDURE set_real_approver(
  p_itemtype in     varchar2
 ,p_itemkey  in     varchar2
)
IS
  l_employee_id fnd_user.employee_id%TYPE;
  l_real_approver VARCHAR2(500);


BEGIN
   -- Bug 3490263
   l_employee_id :=  hxc_approval_wf_pkg.find_mysterious_approver(p_itemtype,p_itemkey);


  IF l_employee_id <> -1
  THEN
    l_real_approver := get_name(l_employee_id,sysdate);
  END IF;


  wf_engine.SetItemAttrText(
    itemtype => p_itemtype,
    itemkey  => p_itemkey,
    aname    => 'APR_NAME',
    avalue   => l_real_approver
  );

--Bug 5375656
   wf_engine.SetItemAttrText(
      itemtype => p_itemtype,
      itemkey  => p_itemkey,
      aname    => 'TC_APPROVER_FROM_ROLE',
      avalue   => l_real_approver
  );
END set_real_approver;





-- this work flow activity implies that the approver has 'approved'
-- the notification, ie. not a timeout
--
procedure capture_approved_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'capture_approved_status';
    l_approvers_visited number;
begin
    g_debug:=hr_utility.debug_enabled;
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');
    if g_debug then
	    hr_utility.trace('capture approved status');
    end if;
    if p_funcmode = 'RUN' then

        set_real_approver(
          p_itemtype => p_itemtype
         ,p_itemkey  => p_itemkey
        );
        --
        -- set variables for approval hierarchy
        --
        l_approvers_visited := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APPROVERS_VISITED');
	if g_debug then
	        hr_utility.trace('l_approvers_visited=' || l_approvers_visited);
	end if;
        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APPROVED_AT_LEVEL',
                                avalue   => l_approvers_visited);

        --
        -- set up attribute required for next activity
        --
        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => 'APPROVED');

        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    --OIT Enhancement
    --FYI Notification to PREPARER on timecard APPROVAL
   hxc_approval_wf_helper.set_notif_attribute_values
      (p_itemtype,
       p_itemkey,
       hxc_app_comp_notifications_api.c_action_approved,
       hxc_app_comp_notifications_api.c_recipient_preparer
      );
    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end capture_approved_status;

procedure capture_timeout_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'capture_timeout_status';
begin
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');

    if p_funcmode = 'RUN' then
        --
        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => 'APPROVED');

        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'APR_REJ_REASON',
                             avalue   => 'TIMED_OUT');

        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end capture_timeout_status;

--
-- reject comment after notification has been responded to
--
procedure capture_rejected_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'capture_rejection_status';
begin
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');

    if p_funcmode = 'RUN' then
       set_real_approver(
         p_itemtype => p_itemtype
        ,p_itemkey  => p_itemkey
       );
        --
        -- set up attribute required for next activity
        --
        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => 'REJECTED');

        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    --OIT Enhancement
    --FYI Notification to PREPARER on timecard REJECTION
    hxc_approval_wf_helper.set_notif_attribute_values
          (p_itemtype,
           p_itemkey,
           hxc_app_comp_notifications_api.c_action_rejected,
           hxc_app_comp_notifications_api.c_recipient_preparer
       );

    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end capture_rejected_status;

FUNCTION GetProjectManager(
  p_project_id IN NUMBER
)
RETURN NUMBER
IS
BEGIN
  RETURN 10250;
END GetProjectManager;

--
-- Project Manager Mechanism
--

procedure find_project_manager(
  p_itemtype in     varchar2,
  p_itemkey  in     varchar2,
  p_actid    in     number,
  p_funcmode in     varchar2,
  p_result   in out nocopy varchar2
)
is

  CURSOR c_project_id(
    p_ap_bb_id hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
  SELECT hta.attribute1
    FROM hxc_ap_detail_links apdet
        ,hxc_time_building_blocks htbb
        ,hxc_time_attribute_usages htau
        ,hxc_time_attributes hta
   WHERE apdet.application_period_id = p_ap_bb_id
     AND apdet.time_building_block_id = htbb.time_building_block_id
     AND htbb.date_to = hr_general.end_of_time
     AND htbb.time_building_block_id = htau.time_building_block_id
     AND htbb.object_version_number = htau.time_building_block_ovn
     AND htau.time_attribute_id = hta.time_attribute_id
     AND hta.attribute_category = 'PROJECTS';

  cursor c_project_id_deleted_detail
           (p_app_bb_id in hxc_time_building_blocks.time_building_block_id%type) is
  select to_number(ta.attribute1)
  from hxc_time_building_blocks details,
       hxc_time_building_blocks days,
       hxc_time_attribute_usages tau,
       hxc_app_period_summary aps,
       hxc_time_Attributes ta
 where aps.application_period_id = p_app_bb_id
   and aps.start_time <= days.stop_time
   and aps.stop_time >= days.start_time
   and aps.resource_id = days.resource_Id
   and details.parent_building_block_Id = days.time_building_block_id
   and details.parent_building_block_ovn = days.object_version_number
   and details.date_to <> hr_general.end_of_time
   and details.object_version_number =
       (select max(details2.object_version_number)
          from hxc_time_building_blocks details2
	 where details.time_building_block_id = details2.time_building_block_id)
   and details.time_building_block_id = tau.time_building_block_id
   and details.object_version_number = tau.time_building_block_ovn
   and tau.time_Attribute_Id = ta.time_attribute_id
   and ta.attribute_category = 'PROJECTS'
   and not exists
      (select 1
	 from hxc_ap_detail_links adl
	where adl.application_period_id = aps.application_period_id
	  and adl.time_building_block_id = details.time_building_block_id
	  and adl.time_building_block_ovn = details.object_version_number
	      );

  l_project_id VARCHAR2(150);
  l_project_procedure VARCHAR2(150) := 'get_project_manager';
  l_dyn_sql   VARCHAR2(2000);
  l_ap_bb_id   NUMBER;
  l_project_manager NUMBER := NULL;

  l_proc VARCHAR2(100);
  l_is_blank varchar2(1);
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	  l_proc := g_pkg || 'find_project_manager';
	  hr_utility.trace('in ' || l_proc);
  end if;
  l_ap_bb_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_BB_ID');

  l_is_blank := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'IS_DIFF_TC',
                                          ignore_notfound => true);


  --
  -- First: Attempt to find the project id from a live time detail.
  --
  open c_project_id(l_ap_bb_id);
  fetch c_project_id into l_project_id;
  if c_project_id%notfound then
     close c_project_id;
     --
     -- Bug fix: 4177451: 115.65.  In the case of a deleted line,
     -- check to see if the project id can be determined from an
     -- end dated detail.
     --
     open c_project_id_deleted_detail(l_ap_bb_id);
     fetch c_project_id_deleted_detail into l_project_id;
     close c_project_id_deleted_detail;
  else
     close c_project_id;
  end if;

  if l_is_blank = 'Y' then
       l_project_id := null;
  end if;

  if(l_project_id is not null) then

    --find project manager id

    l_dyn_sql := 'BEGIN '|| fnd_global.newline
              || ':1 := Pa_Otc_Api.GetProjectManager'  ||fnd_global.newline
              ||'(p_project_id => :2);'   ||fnd_global.newline
              ||'END;';

    EXECUTE IMMEDIATE l_dyn_sql
            using OUT l_project_manager, IN l_project_id;


    IF l_project_manager IS NULL
    THEN
      g_trace :=' project manager is null';

      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', '10');
      hr_utility.raise_error;

    END IF;

    wf_engine.SetItemAttrNumber(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'APR_PERSON_ID',
                                  avalue   => l_project_manager);

    p_result := 'COMPLETE';
  ELSE
     --
     -- Bug fix: 4291206: 115.66.  If the user has updated instead of
     -- deleting the line, such that the new project manager is different
     -- we need to notify the previous project manager to ensure we can complete
     -- the ELA approval.  We can look up the previous approver, because we
     -- stored it when we were generating the application period.
     --
     l_project_manager := hxc_approval_wf_util.get_previous_approver
                            (p_itemtype,p_itemkey,l_ap_bb_id);
     if(l_project_manager is not null) then
        wf_engine.SetItemAttrNumber
           (itemtype => p_itemtype,
            itemkey  => p_itemkey,
            aname    => 'APR_PERSON_ID',
            avalue   => l_project_manager);
        p_result := 'COMPLETE';
     else
	if g_debug then
	        hr_utility.trace('project id and previous approver are null');
        end if;
	g_trace :='no project id or approver';
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '20');
        hr_utility.raise_error;
     end if;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- The line below records this function call in the error system
     -- in the case of an exception.
     --
     if g_debug then
	     hr_utility.set_location(l_proc, 999);
     --
	     hr_utility.trace('IN EXCEPTION IN find_project_manager');
     --
     end if;
     wf_core.context('HCAPPRWF', l_proc,
                     p_itemtype, p_itemkey, to_char(p_actid), p_funcmode, g_trace);
     raise;
     p_result := '';
     return;
END find_project_manager;



-- auto approval mechanism
--
procedure auto_approval(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'auto_approval';
    l_ap_bbid           hxc_time_building_blocks.time_building_block_id%type;
    l_ap_bbovn          hxc_time_building_blocks.time_building_block_id%type;
begin
    --sb_msgs_pkg.begin_call(l_proc);

    if p_funcmode = 'RUN' then
        --
        -- set up attribute required for next activity
        --
        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => 'APPROVED');

        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'APR_REJ_REASON',
                             avalue   => 'AUTO_APPROVE');

        --OIT Enhancement
        --FYI Notification to WORKER on timecard AUTO APPROVAL
	HXC_APPROVAL_WF_HELPER.set_notif_attribute_values
          (p_itemtype,
           p_itemkey,
           hxc_app_comp_notifications_api.c_action_auto_approve,
           hxc_app_comp_notifications_api.c_recipient_worker
          );

        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end auto_approval;


FUNCTION category_timecard_hrs (
		p_app_per_id	NUMBER
  	    ,   p_time_category_name VARCHAR2 )
RETURN NUMBER
IS

CURSOR csr_get_timecard(p_app_per_id NUMBER) IS
SELECT adl.TIME_BUILDING_BLOCK_ID bb_id,
       adl.TIME_BUILDING_BLOCK_OVN ovn
FROM	hxc_time_building_blocks tbb
,	hxc_ap_detail_links adl
WHERE adl.APPLICATION_PERIOD_ID = p_app_per_id
AND
	tbb.time_building_block_id = adl.time_building_block_id AND
	tbb.object_version_number  = adl.time_building_block_ovn AND
        tbb.date_to                = hr_general.end_of_time;

CURSOR csr_get_person_id(p_app_per_id NUMBER) IS
SELECT resource_id
FROM	hxc_time_building_blocks tbb
WHERE tbb.time_building_block_id = p_app_per_id;

/* Bug fix for 5526281 */
CURSOR get_timecard_start_date(p_app_per_id NUMBER) IS
SELECT tbb.start_time ,tbb.stop_time
FROM   hxc_tc_ap_links htl,
       hxc_time_building_blocks tbb
WHERE  htl.application_period_id = p_app_per_id
AND    tbb.time_building_block_id = htl.timecard_id;

cursor emp_hire_info(p_resource_id hxc_time_building_blocks.resource_id%TYPE) IS
select date_start from per_periods_of_service where person_id=p_resource_id order by date_start desc;
/* end of bug fix for 5526281 */

l_tc_rec csr_get_timecard%ROWTYPE;
l_timecard_hrs NUMBER := 0;
l_detail_hrs   NUMBER := 0;
l_time_category_id hxc_time_categories.time_category_id%TYPE;
l_resource_id hxc_time_building_blocks.resource_id%TYPE;
l_precision       VARCHAR2(4);
l_rounding_rule   VARCHAR2(20);
l_tc_start_date   date;

/* Bug fix for 5526281 */
l_tc_end_date           date;
l_pref_eval_date	date;
l_emp_hire_date		date;
/* end of bug fix for 5526281 */

BEGIN

OPEN  csr_get_person_id ( p_app_per_id );
FETCH csr_get_person_id into l_resource_id;
CLOSE csr_get_person_id;

/* Bug fix for 5526281 */
OPEN  get_timecard_start_date ( p_app_per_id );
FETCH get_timecard_start_date into l_tc_start_date,l_tc_end_date;
CLOSE get_timecard_start_date;

OPEN  emp_hire_info (l_resource_id);
FETCH emp_hire_info into l_emp_hire_date;
CLOSE emp_hire_info;

if trunc(l_emp_hire_date) >= trunc(l_tc_start_date) and trunc(l_emp_hire_date) <= trunc(l_tc_end_date) then
	l_pref_eval_date := trunc(l_emp_hire_date);
else
	l_pref_eval_date := trunc(l_tc_start_date);
end if;

l_precision := hxc_preference_evaluation.resource_preferences
                                                (l_resource_id,
                                                 'TC_W_TCRD_UOM',
                                                 3,
                                                 l_pref_eval_date
                                                );

l_rounding_rule := hxc_preference_evaluation.resource_preferences
                                                (l_resource_id,
                                                 'TC_W_TCRD_UOM',
                                                 4,
                                                 l_pref_eval_date
                                                );

/* end of bug fix for 5526281 */

if l_precision is null
then
l_precision := '2';
end if;

if l_rounding_rule is null
then
l_rounding_rule := 'ROUND_TO_NEAREST';
end if;

l_time_category_id := HXC_TIME_CATEGORY_UTILS_PKG.get_time_category_id ( p_time_category_name => p_time_category_name );

OPEN  csr_get_timecard ( p_app_per_id );
FETCH csr_get_timecard into l_tc_rec;

	WHILE csr_get_timecard%FOUND
	LOOP
			-- call category_detail_hrs
		l_detail_hrs := HXC_TIME_CATEGORY_UTILS_PKG.category_detail_hrs (
				p_tbb_id      => l_tc_rec.bb_id
			,	p_tbb_ovn     => l_tc_rec.ovn
			,       p_time_category_id => l_time_category_id );

		l_timecard_hrs := l_timecard_hrs + apply_round_rule(l_rounding_rule,
		                                                    l_precision,
								    l_detail_hrs);

		FETCH csr_get_timecard INTO l_tc_rec;
	END LOOP;

CLOSE csr_get_timecard;
RETURN l_timecard_hrs;

END category_timecard_hrs;

FUNCTION category_timecard_hrs (
		p_start_date	date,
		p_end_date   date,
		p_resource_id number,
  	       p_time_category_name VARCHAR2 )
RETURN NUMBER
IS

CURSOR csr_get_details
IS
select details.time_building_block_id bb_id, details.object_version_number ovn
from hxc_time_building_blocks timecard,
     hxc_time_building_blocks details,
     hxc_time_building_blocks days
where timecard.time_building_block_id = days.parent_building_block_id
  and timecard.object_version_number = days.parent_building_block_ovn
  and days.time_building_block_id = details.parent_building_block_id
  and days.object_version_number = details.parent_building_block_ovn
  and details.date_to = hr_general.end_of_time
  and days.start_time <=p_end_date
  and days.stop_time >= p_start_date
  and days.resource_id = p_resource_id
  and details.scope = 'DETAIL'
  and timecard.scope = 'TIMECARD';

l_tc_rec csr_get_details%ROWTYPE;
l_timecard_hrs NUMBER := 0;
l_detail_hrs   NUMBER := 0;
l_time_category_id hxc_time_categories.time_category_id%TYPE;
l_precision     VARCHAR2(4);
l_rounding_rule VARCHAR2(20);

BEGIN
l_precision := hxc_preference_evaluation.resource_preferences
                                                (p_resource_id,
                                                 'TC_W_TCRD_UOM',
                                                 3,
                                                 p_start_date
                                                );

l_rounding_rule := hxc_preference_evaluation.resource_preferences
                                                (p_resource_id,
                                                 'TC_W_TCRD_UOM',
                                                 4,
                                                 p_start_date
                                                );

if l_precision is null
then
l_precision := '2';
end if;

if l_rounding_rule is null
then
l_rounding_rule := 'ROUND_TO_NEAREST';
end if;

l_time_category_id := HXC_TIME_CATEGORY_UTILS_PKG.get_time_category_id ( p_time_category_name => p_time_category_name );

OPEN  csr_get_details;
FETCH csr_get_details into l_tc_rec;

WHILE csr_get_details%FOUND
LOOP
		-- call category_detail_hrs
	l_detail_hrs := HXC_TIME_CATEGORY_UTILS_PKG.category_detail_hrs (
	    		p_tbb_id      => l_tc_rec.bb_id
		,	p_tbb_ovn     => l_tc_rec.ovn
		,       p_time_category_id => l_time_category_id );

	l_timecard_hrs := l_timecard_hrs + apply_round_rule(l_rounding_rule,
	                                                    l_precision,
							    l_detail_hrs);

	FETCH csr_get_details INTO l_tc_rec;
END LOOP;

CLOSE csr_get_details;
RETURN l_timecard_hrs;

END category_timecard_hrs;
--
-- person approval mechanism
--
procedure person_approval(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is

  cursor c_item_attribute_values(p_item_key in varchar2) is
  select name,text_value
    from wf_item_attribute_values
   where item_type = 'HXCEMP'
     and item_key = p_item_key;

    l_proc constant varchar2(61) := g_pkg || '.' || 'person_approval';
    l_effective_end_date    date;
    l_effective_start_date    date;
    l_apr_person_id     per_all_assignments_f.person_id%type;
    l_login             fnd_user.user_name%type;
    --
    -- Bug 4153585
    -- Increased size for translation
    l_title             varchar2(4000);
    l_total_hours       number;
    l_otl_appr_id        varchar2(50);
    l_appl_period_bb_id  number;
    l_resource_id        number;
    l_is_blank varchar2(1);
    l_supervisor_id number;
begin
    if p_funcmode = 'RUN' then
        --
        -- all datetrack data should be valid for duration of application period
        --
        l_effective_end_date := wf_engine.GetItemAttrDate(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_END_DATE');

        l_effective_start_date := wf_engine.GetItemAttrDate(
	                                    itemtype => p_itemtype,
	                                    itemkey  => p_itemkey,
	                                    aname    => 'APP_START_DATE');

        l_apr_person_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APR_PERSON_ID');

        l_appl_period_bb_id := wf_engine.GetItemAttrNumber(
                                     itemtype  => p_itemtype,
                                     itemkey   => p_itemkey,
                                     aname     => 'APP_BB_ID');
	l_is_blank := wf_engine.GetItemAttrText(itemtype => p_itemtype,
						itemkey  => p_itemkey  ,
						aname    => 'IS_DIFF_TC',
						ignore_notfound => true);
	--Added as part of OIT enhancement
	l_resource_id := wf_engine.GetItemAttrNumber(
				     itemtype  => p_itemtype,
				     itemkey   => p_itemkey,
				     aname     => 'RESOURCE_ID');

        -- Check if the approver is terminated (Bug#3160848)
	if validate_person (l_apr_person_id,SYSDATE)
        then
		IF l_is_blank = 'Y' THEN

		l_apr_person_id := get_supervisor(l_resource_id, sysdate);

		wf_engine.SetItemAttrNumber(
		                            itemtype => p_itemtype,
		                            itemkey  => p_itemkey,
					    aname    => 'APR_PERSON_ID',
					    avalue   => l_apr_person_id);
		ELSE
        	-- Check if the approver is terminated (Bug#3160848)

        	   hr_utility.set_message(809, 'HXC_APPR_WF_TERMINATED_APPR');-- If approver is terminated then raise an error
        	   hr_utility.raise_error;
        	end if;
	END IF;

        --
        -- set attribute to specify approver's self service login
        --
        l_login := get_login(p_person_id => l_apr_person_id);

        --
        -- if null returned, approver does not have a self service login name,
        -- where does notification get sent?
        --
        if l_login is null then
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '10');
            hr_utility.raise_error;
        end if;

        --sb_msgs_pkg.trace('approver login>' || l_login || '<');

        wf_engine.SetItemAttrText(
                              itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APR_SS_LOGIN',
                              avalue   => l_login);

        --
        -- set information for notification
        --


        wf_engine.SetItemAttrText(
                              itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APR_NAME',
                              avalue   => get_name(l_apr_person_id,l_effective_end_date)
			     );
        wf_engine.SetItemAttrText(
                              itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'TC_APPROVER_FROM_ROLE',
                              avalue   => l_login);

        fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
        fnd_message.set_token('START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
        fnd_message.set_token('END_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

        l_title := fnd_message.get();

	wf_engine.SetItemAttrText(
	                              itemtype => p_itemtype,
	                              itemkey  => p_itemkey,
	                              aname    => 'TITLE',
	                              avalue   => l_title);

        l_otl_appr_id := l_appl_period_bb_id||'#'||p_itemkey;

        wf_engine.SetItemAttrText(
	                              itemtype => p_itemtype,
	                              itemkey  => p_itemkey,
	                              aname    => 'OTL_APPR_ID',
	                              avalue   => l_otl_appr_id);

        wf_engine.SetItemAttrText(
		                      itemtype => p_itemtype,
		                      itemkey  => p_itemkey,
		                      aname    => 'DESCRIPTION',
		                      avalue   => get_description(l_appl_period_bb_id));

        wf_engine.SetItemAttrNumber(
		                      itemtype => p_itemtype,
		                      itemkey  => p_itemkey,
		                      aname    => 'TOTAL_TC_HOURS',
		                      avalue   => l_total_hours);
        --OIT Enhancement
        --FYI Notification to SUPERVISOR on timecard SUBMISSION if he is not the direct approver.
	if(HXC_APPROVAL_WF_HELPER.is_approver_supervisor(l_apr_person_id,l_resource_id)) then
		   HXC_APPROVAL_WF_HELPER.set_notif_attribute_values
		     (p_itemtype,
		      p_itemkey,
		      null,
		      null
		     );
	else
	           HXC_APPROVAL_WF_HELPER.set_notif_attribute_values
	             (p_itemtype,
	              p_itemkey,
	              hxc_app_comp_notifications_api.c_action_request_approval,
	              hxc_app_comp_notifications_api.c_recipient_supervisor
	             );
        end if;

        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

/*
   Bug 3449786

   Added commit.  At this point we're about to send a notification
   which could take several days for a response, therefore to
   save rollback segments, we issue a commit here, knowing that
   the workflow data is set appropriately.

*/

   commit;

exception
    when others then
        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end person_approval;

--Function to check if a given approver is terminated (Bug#3160848)
--Changed for 115.60; used per_all_people_f instead of per_people_f
FUNCTION validate_person(
    p_person_id      in number,
    p_effective_date in date)
RETURN BOOLEAN
is

    cursor csr_validate_person(b_person_id number, b_effective_date date) is
    SELECT 1
    FROM per_all_people_f per,
           per_person_types ppt,
           per_person_type_usages_f pptu
    WHERE per.person_id = b_person_id
      AND TRUNC(b_effective_date) between  TRUNC(per.effective_Start_date) and TRUNC(per.effective_end_date)
      AND TRUNC(b_effective_date) between TRUNC(pptu.effective_Start_date) and TRUNC(pptu.effective_end_date)
      AND pptu.person_id = per.person_id
      AND pptu.person_type_id = ppt.person_type_id
      AND ppt.system_person_type in ('EMP','CWK');

     temp   number;

    begin

    open csr_validate_person(p_person_id, trunc(p_effective_date));
    fetch csr_validate_person into temp;

  IF csr_validate_person%NOTFOUND
  THEN
     close csr_validate_person;
     RETURN TRUE;
  END IF;

  CLOSE csr_validate_person;
  RETURN FALSE;

end validate_person;

--
--
--
procedure inc_approvers_visited(
    p_itemtype in varchar2,
    p_itemkey  in varchar2)
is
    l_approvers_visited number;
begin
    l_approvers_visited := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APPROVERS_VISITED');

    l_approvers_visited := l_approvers_visited + 1;

    wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVERS_VISITED',
                              avalue   => l_approvers_visited);
end inc_approvers_visited;



PROCEDURE process_extension_func2(
  p_tc_id          IN hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_tc_ovn         IN hxc_time_building_blocks.object_version_number%TYPE
 ,p_time_recipient IN hxc_time_recipients.time_recipient_id%TYPE
 ,p_ext_func2      IN hxc_time_recipients.extension_function2%TYPE
 ,p_previous_approver IN NUMBER
 ,p_next_approver     OUT NOCOPY NUMBER
)
IS

  l_previous_approver_id  number := p_previous_approver;
  l_approver_person_id    number := NULL;
  l_message               varchar2(2000);
  l_func_sql              varchar2(2000);
  l_message_index         number;
  l_message_table         hxc_self_service_time_deposit.message_table;
BEGIN
  --
  -- Sets up global variables for timecard records.
  --
  hxc_self_service_time_deposit.get_timecard_tables(
        p_timecard_id             => p_tc_id
       ,p_timecard_ovn            => p_tc_ovn
       ,p_timecard_blocks         => hxc_approval_wf_pkg.g_time_building_blocks
       ,p_timecard_app_attributes => hxc_approval_wf_pkg.g_time_app_attributes
       ,p_time_recipient_id       => p_time_recipient);



  l_func_sql := 'BEGIN '||fnd_global.newline
   ||p_ext_func2 ||fnd_global.newline
   ||'(p_previous_approver_id => :1'     ||fnd_global.newline
   ||',x_approver_person_id   => :2'     ||fnd_global.newline
   ||',x_messages             => :3);'   ||fnd_global.newline
   ||'END;';

  EXECUTE IMMEDIATE l_func_sql
            using IN OUT l_previous_approver_id,
                  IN OUT l_approver_person_id,
                  IN OUT l_message;

  if g_debug then
	  hr_utility.trace('After client extension');
	  --
	  hr_utility.trace('Previous APPR ID is : ' || to_char(l_previous_approver_id));
	  hr_utility.trace('APPR ID is : ' || to_char(l_approver_person_id));
	  hr_utility.trace('Message is : ' || l_message);
  end if;
  IF l_message IS NOT NULL
  THEN
    l_message_table := hxc_deposit_wrapper_utilities.string_to_messages
                              (p_message_string => l_message);

    IF l_message_table.count > 0
    THEN
          l_message_index := l_message_table.first;

          FND_MESSAGE.SET_NAME
           (l_message_table(l_message_index).application_short_name
           ,l_message_table(l_message_index).message_name
           );

          FND_MESSAGE.RAISE_ERROR;
    END IF;

  END IF;

  p_next_approver := l_approver_person_id;


EXCEPTION
  WHEN OTHERS THEN
    raise;

END process_extension_func2;



--
-- supervisor approval mechanism
--
procedure hr_supervisor_approval(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
--
cursor csr_get_extension(p_time_recipient number) is
   select htr.extension_function2
     from hxc_time_recipients htr
    where htr.time_recipient_id = p_time_recipient;



cursor c_details_of_timecard( l_tc_bb_id  hxc_time_building_blocks.time_building_block_id%type )
is
 select 'Y'
    from hxc_tc_ap_links tcl,
             hxc_ap_detail_links adl
  where tcl.timecard_id = l_tc_bb_id
       and tcl.application_period_id =  adl.application_period_id
       and rownum < 2;

cursor c_find_app_per_id( l_ap_bb_id    in hxc_time_building_blocks.time_building_block_id%type)
is
SELECT 'Y'
  FROM hxc_app_period_summary
 WHERE time_category_id = 0
   AND APPLICATION_PERIOD_ID = l_ap_bb_id
   AND approval_comp_id = (SELECT approval_comp_id
                             FROM hxc_approval_comps
                            WHERE approval_style_id =
                                     (SELECT approval_style_id
                                        FROM hxc_approval_styles
                                       WHERE NAME = 'SEEDED_APPL_PA_MGR')
                              AND time_category_id = 0);


cursor  get_result
is
 select text_value
 from wf_item_attribute_values
 where item_type = p_itemtype
 and item_key = p_itemkey
 and name = 'RESULT';

 cursor c_appr_comp(p_app_bb_id number,p_app_bb_ovn number)
 is
 select approval_comp_id
 from hxc_app_period_summary
 where application_period_id = p_app_bb_id
 and application_period_ovn = p_app_bb_ovn;


--
l_proc constant        varchar2(61) := g_pkg || '.' || 'hr_supervisor_approval';
l_effective_start_date  date;
l_effective_end_date    date;
--l_effective_date        date;
--l_approval_timeout      number;
l_approvers_visited     number;
l_default_timeout       number;
--
-- person who requires approval
--
l_person_id             per_all_assignments_f.person_id%type;
--
l_supervisor_id         per_all_assignments_f.supervisor_id%type;
l_next_supervisor_id    per_all_assignments_f.supervisor_id%type;
l_login                 fnd_user.user_name%type;
l_ap_bbid               hxc_time_building_blocks.time_building_block_id%type;
l_ap_bbovn              hxc_time_building_blocks.time_building_block_id%type;



 l_ap_bb_id    hxc_time_building_blocks.time_building_block_id%type;
 l_validate_flag varchar2(15);
 l_tc_has_details_flag varchar2(15);

--
l_time_recipient        varchar2(150);
l_ext_func2             varchar2(2000);
l_auto_approval_flag    varchar2(1);
l_approver_person_id    number := NULL;
l_previous_approver_id  number := NULL;
l_message               varchar2(2000);
l_func_sql              varchar2(2000);
l_tc_bld_blk_id         number;
l_tc_ovn                number;
--
-- Bug 4153585
-- Increased size for translation
l_title                 varchar2(4000);
l_description           fnd_new_messages.message_text%type;
l_otl_appr_id           varchar2(50);
l_appl_period_bb_id     number;
l_total_hours           number;
l_result                varchar2(20);
l_approval_component_id number;
l_app_ovn               number;

--
begin

g_debug:=hr_utility.debug_enabled;

IF p_funcmode <> 'CANCEL' THEN

  g_trace := 'Begin hr_supervisor_approval';
  if g_debug then
	  hr_utility.trace('Begin hr_supervisor_approval');
  end if;

  l_tc_bld_blk_id := wf_engine.GetItemAttrNumber
                             (itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'TC_BLD_BLK_ID');

  g_trace := 'Timecard BB ID is : ' || to_char(l_tc_bld_blk_id);

  if g_debug then
	hr_utility.trace('Timecard BB ID is : ' || to_char(l_tc_bld_blk_id));
  end if;
  l_tc_ovn := wf_engine.GetItemAttrNumber
                             (itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'TC_BLD_BLK_OVN');

  l_approvers_visited := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APPROVERS_VISITED');

  l_time_recipient := wf_engine.GetItemAttrText(
                                        itemtype => p_itemtype,
                                        itemkey  => p_itemkey  ,
                                        aname    => 'TIME_RECIPIENT_ID');

  l_person_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APR_PERSON_ID');

  l_appl_period_bb_id := wf_engine.GetItemAttrNumber(
                                        itemtype  => p_itemtype,
                                        itemkey   => p_itemkey,
                                        aname     => 'APP_BB_ID');
  l_app_ovn  :=wf_engine.GetItemAttrNumber(
                                        itemtype  => p_itemtype,
                                        itemkey   => p_itemkey,
                                        aname     => 'APP_BB_OVN');
--OIT Change.
--When the preparer  chooses to resend the notification, we end up with sending the notification to
--supervisor's supervisor since we are setting the 'APR_PERSON_ID' to supervisor id when we initially traversed
--the HR_Supervisor_approval.During the resend we get the person id from APR_PERSON_ID (which is supervisor id)
--and gets the supervisor of this resource id which is supervisor's supervisor.

  open get_result;
  fetch get_result into l_result;
  close get_result;

  if l_result = 'RESEND' then

  	wf_engine.SetItemAttrNumber(
	                            itemtype => p_itemtype,
	                            itemkey  => p_itemkey,
                                    aname    => 'APPROVERS_VISITED',
                                    avalue   => l_approvers_visited-1);
  end if;
--added to support OIT desuport

open c_appr_comp(l_appl_period_bb_id,l_app_ovn);
fetch c_appr_comp into l_approval_component_id;
close c_appr_comp;

if(hxc_notification_helper.run_extensions(l_approval_component_id)) then
  open csr_get_extension(to_number(l_time_recipient));
  fetch csr_get_extension into l_ext_func2;
  close csr_get_extension;

  g_trace := 'Before client extension=' || l_ext_func2;
  if g_debug then
	  hr_utility.trace('Before client extension=' || l_ext_func2);
  end if;
	-- Bug 4177487. For an empty Timecard (Timecard that does not have DETAIL level records),
	-- we need not call the PA extension function.
	open c_details_of_timecard( l_tc_bld_blk_id );
	fetch c_details_of_timecard into l_tc_has_details_flag;
	close c_details_of_timecard;
else
   l_ext_func2 := null;
   l_tc_has_details_flag := 'N';
end if;    -- Run extensions


  IF l_ext_func2 IS NOT NULL and l_tc_has_details_flag = 'Y'
  THEN
    g_trace := 'extension not null';
  if g_debug then
	hr_utility.trace('extension not null');
  end if;
    IF hxc_approval_wf_pkg.code_chk(l_ext_func2)
    THEN
      g_trace := 'extension code exists';
      if g_debug then
	      hr_utility.trace('extension code exists');
      end if;
      wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APR_KEY_LEVEL',
                                avalue   => '100');

      wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'APPROVAL_TIMEOUT',
                                  avalue   => 0);

      IF l_approvers_visited = 0
      THEN
        l_previous_approver_id := null;
      ELSE
        l_previous_approver_id := l_person_id;
      END IF;

      g_trace := 'before processing extension l_previous_approver_id='
              || to_char(l_person_id);
      if g_debug then
	      hr_utility.trace('before processing extension l_previous_approver_id='
                      || to_char(l_person_id));
      end if;

      --Bug 5386274
      --We need to get the result attribute, if it is RESEND then set the supervisor id to person id which we set
      --to supervisor id when we traversed this procedure initially.
      if l_result = 'RESEND' then
      	      l_supervisor_id :=l_person_id;
      else
	      process_extension_func2(
		p_tc_id             => l_tc_bld_blk_id
	       ,p_tc_ovn            => l_tc_ovn
	       ,p_time_recipient    => to_number(l_time_recipient)
	       ,p_ext_func2         => l_ext_func2
	       ,p_previous_approver => l_previous_approver_id
	       ,p_next_approver     => l_supervisor_id
	      );
      end if;

      g_trace := 'after processing extension l_supervisor_id='
              || to_char(l_supervisor_id);
      if g_debug then
	      hr_utility.trace('after processing extension l_supervisor_id='
                      || to_char(l_supervisor_id));
      end if;
      IF l_supervisor_id IS NOT NULL
      THEN
        g_trace := 'testing if this is the final approver';
      if g_debug then
		hr_utility.trace('testing if this is the final approver');
      end if;
        process_extension_func2(
          p_tc_id             => l_tc_bld_blk_id
         ,p_tc_ovn            => l_tc_ovn
         ,p_time_recipient    => to_number(l_time_recipient)
         ,p_ext_func2         => l_ext_func2
         ,p_previous_approver => l_supervisor_id
         ,p_next_approver     => l_next_supervisor_id
        );

        g_trace := 'end calling extension';
	if g_debug then
		hr_utility.trace('end calling extension');
	end if;
        IF l_next_supervisor_id = -99
        THEN
          wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'FINAL_APR',
                              avalue   => 'YES');

          g_trace := 'FINAL_APR is : YES';
	  if g_debug then
		hr_utility.trace('FINAL_APR is : YES');
	  end if;
        END IF;

        g_trace := 'end testing final approver';
	if g_debug then
	        hr_utility.trace('end testing final approver');
	end if;
      END IF;

    ELSE
      g_trace := 'extension function=' || l_ext_func2 || 'not exist in db';
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', '10');
      hr_utility.raise_error;

    END IF;
  ELSE -- if no client extension, find supervisor from assignments
    wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'FINAL_APR',
                              avalue   => 'NO_EXTENSION');


    --Bug 2777538 sonarasi 20-FEB-2003
    g_trace := 'no extension function checking assignment';
    if g_debug then
	hr_utility.trace('no extension function checking assignment');
    end if;

	-- Bug 4202019. These variables need to be set outside this IF block.
/*
    l_effective_end_date := wf_engine.GetItemAttrDate(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_END_DATE');

    l_effective_start_date := wf_engine.GetItemAttrDate(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_START_DATE');
*/

    --l_effective_date := l_effective_end_date;

     --OIT Change
     --We need to get the result attribute, if it is RESEND then set the supervisor id to person id which we set
     --to supervisor id when we traversed this procedure initially.

     if l_result = 'RESEND' then
    	l_supervisor_id := l_person_id;
     else
        l_supervisor_id:= get_supervisor(l_person_id, SYSDATE);
     end if;

  END IF;


  -- no supervisor found, does not make sense here
  -- eg. approval key level = 1
  --     expect martin to be found as supervisor
  --
  --     approval key level = 2
  --     expect martin, clive to be found as supervisors,
  --
  if l_supervisor_id is null and l_approvers_visited = 0 then
    g_trace := '200';
    if g_debug then
	    hr_utility.trace('200');
    end if;

    hr_utility.set_message(809, 'HXC_APPR_WF_NO_HR_SUP');
    hr_utility.raise_error;
  end if;

  g_trace := 'supervisor is not null';
  if g_debug then
	  hr_utility.trace('supervisor is not null');
  end if;
  -- set up timeout properties for first approver in hierarchy

  IF l_ext_func2 IS NULL
  THEN
    g_trace := 'setting timeout';
    if g_debug then
	hr_utility.trace('setting timeout');
    end if;
    if l_approvers_visited = 0 then

      -- if supervisors exist after first approver then notification
      -- for first approver is allowed to timeout

      if get_supervisor(l_supervisor_id, SYSDATE) is not null
      then
        g_trace :='allow timeout';
	if g_debug then
		hr_utility.trace('allow timeout');
	end if;
        l_default_timeout := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'DEFAULT_TIMEOUT');


        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APPROVAL_TIMEOUT',
                                    avalue   => l_default_timeout);

        g_trace := 'timeout=' || to_char(l_default_timeout);
	if g_debug then
	        hr_utility.trace('timeout=' || to_char(l_default_timeout));
	end if;
      -- if no more supervisors exist after first approver then
      -- notification sent to next approver NOT allowed to timeout
      else
        g_trace :='NOT allow timeout';
	if g_debug then
	        hr_utility.trace('NOT allow timeout');
	end if;
        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APPROVAL_TIMEOUT',
                                    avalue   => 0);
      end if;
    end if;
  END IF;




  g_trace := 'find supervisor self service login';
  if g_debug then
	  hr_utility.trace('find supervisor self service login');
  end if;
   -- find supervisor  self service login
      l_login := get_login(p_person_id =>l_supervisor_id);

  if l_login is null then
     g_trace := 'RAISE: no self service login for supervisor';
     if g_debug then
	     hr_utility.trace('RAISE: no self service login for supervisor');
     end if;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE', l_proc);
     hr_utility.set_message_token('STEP', '30');
     hr_utility.raise_error;
  end if;

  g_trace := 'supervisor ss login=' || l_login;
  if g_debug then
	hr_utility.trace('supervisor ss login=' || l_login);
  end if;

    -- supervisor found and notification to be sent,
    -- keep track of approvers visted to date

    g_trace := 'increase approvers visited';
    if g_debug then
  	  hr_utility.trace('increase approvers visited');
    end if;
  inc_approvers_visited(p_itemtype, p_itemkey);

  wf_engine.SetItemAttrText(
    itemtype => p_itemtype,
    itemkey  => p_itemkey,
    aname    => 'APR_SS_LOGIN',
    avalue   => l_login
  );

  g_trace := 'setting apr_name';
  if g_debug then
	hr_utility.trace('setting apr_name');
  end if;
  -- set information for notification
  wf_engine.SetItemAttrText(
    itemtype => p_itemtype,
    itemkey  => p_itemkey,
    aname    => 'APR_NAME',
    avalue   => get_name(l_supervisor_id,sysdate)
    );

  g_trace := 'setting from_role';
  if g_debug then
	  hr_utility.trace('setting from_role');
  end if;
  wf_engine.SetItemAttrText(
    itemtype => p_itemtype,
    itemkey  => p_itemkey,
    aname    => 'TC_APPROVER_FROM_ROLE',
    avalue   => l_login
  );

  g_trace := '300';
  if g_debug then
	hr_utility.trace('Notification Sent to : '||to_char(l_supervisor_id));
  end if;
  --
  -- set supervisor's person id, ready for next iteration

  wf_engine.SetItemAttrNumber(
                              itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APR_PERSON_ID',
                              avalue   => l_supervisor_id);

	-- Bug 4202019. These variables are set just before they are being used in the TITLE of Worklist notification.

    l_effective_end_date := wf_engine.GetItemAttrDate(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_END_DATE');

    l_effective_start_date := wf_engine.GetItemAttrDate(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_START_DATE');


    fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
    fnd_message.set_token('START_DATE',to_char(l_effective_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
    fnd_message.set_token('END_DATE',to_char(l_effective_end_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

    l_title := fnd_message.get();

    wf_engine.SetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'TITLE',
                                avalue   => l_title);

    l_otl_appr_id := l_appl_period_bb_id||'#'||p_itemkey;

    wf_engine.SetItemAttrText(
  	                      itemtype => p_itemtype,
  	                      itemkey  => p_itemkey,
  	                      aname    => 'OTL_APPR_ID',
  	                      avalue   => l_otl_appr_id);

    l_description := get_description(l_appl_period_bb_id);

    open c_find_app_per_id( l_appl_period_bb_id );
    fetch c_find_app_per_id into l_validate_flag;
    close c_find_app_per_id;

    if l_validate_flag = 'Y' then
      fnd_message.set_name('HXC','HXC_APPR_WF_DESC_NO_PA_MANAGER');
      l_description := l_description || fnd_message.get();
    end if;

    wf_engine.SetItemAttrText
      (itemtype => p_itemtype,
       itemkey  => p_itemkey,
       aname    => 'DESCRIPTION',
       avalue   => l_description);

    wf_engine.SetItemAttrNumber(
		                      itemtype => p_itemtype,
		                      itemkey  => p_itemkey,
		                      aname    => 'TOTAL_TC_HOURS',
		                      avalue   => l_total_hours);



  g_trace := '500';
  if g_debug then
	  hr_utility.trace('500');
  end if;
  p_result := 'COMPLETE:Y';

end if;
  if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE:Y';
  end if;

  if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE:Y';
  end if;



/*
   Bug 3449786

   Added commit.  At this point we're about to send a notification
   which could take several days for a response, therefore to
   save rollback segments, we issue a commit here, knowing that
   the workflow data is set appropriately.

*/

   commit;

exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode,
                        l_proc || '|' || g_trace);
        raise;
end hr_supervisor_approval;
--
-- approval comment arrives after notification has been responded to,
-- this work flow activity implies that the approver has 'approved'
-- the notification, ie. not a timeout
--
procedure capture_apr_comment(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'capture_apr_comment';
    l_approvers_visited number;
begin
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');

    if p_funcmode = 'RUN' then
        --
        -- set variables for approval hierarchy
        --
/*jxtan should move this to other procedure
        l_approvers_visited := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APPROVERS_VISITED');

        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APPROVED_AT_LEVEL',
                                avalue   => l_approvers_visited);

*/
        --
        -- set up attribute required for next activity
        --
        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => 'APPROVED');

        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end capture_apr_comment;



--
-- reject comment after notification has been responded to
--
procedure capture_reject_comment(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'capture_reject_comment';
begin
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');

    if p_funcmode = 'RUN' then
        --
        -- set up attribute required for next activity
        --
        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => 'REJECTED');
        --

        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end capture_reject_comment;



--
-- controls looping logic
--
procedure is_final_apr(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'is_final_apr';
    l_final_apr         varchar2(50);
    l_effective_date    date;
    l_approval_timeout  number;
    l_default_timeout   number;
    l_apr_person_id     per_all_assignments_f.person_id%type;
    l_apr_key_level     number;
    l_approved_at_level number;
    l_approvers_visited number;
begin
    g_debug:=hr_utility.debug_enabled;
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');
    if g_debug then
	hr_utility.trace('is final approver');
    end if;
    if p_funcmode = 'RUN' then

        l_final_apr := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'FINAL_APR');


        IF l_final_apr = 'YES' THEN
           if g_debug then
		hr_utility.trace('Final!');
	   end if;
           p_result := 'COMPLETE:Y';
           return;
        ELSIF l_final_apr = 'NO' THEN
	   if g_debug then
		hr_utility.trace('extension not final');
           end if;
	   p_result := 'COMPLETE:N';
           return;
        END IF;

        l_apr_person_id := wf_engine.GetItemAttrNumber(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APR_PERSON_ID');

        IF get_supervisor(l_apr_person_id, SYSDATE) IS NULL
        THEN
          p_result := 'COMPLETE:Y';
          return;
        END IF;

	if g_debug then
	        hr_utility.trace('NOT final');
	end if;

        l_effective_date := wf_engine.GetItemAttrDate(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APP_END_DATE');

        l_approval_timeout := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APPROVAL_TIMEOUT');

        l_default_timeout := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'DEFAULT_TIMEOUT');


        --sb_msgs_pkg.trace('current apr per id>' || l_apr_person_id || '<');

        l_apr_key_level := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APR_KEY_LEVEL');

        l_approved_at_level := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APPROVED_AT_LEVEL');

        l_approvers_visited := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APPROVERS_VISITED');

        --
        -- next iteration takes us below key approver,
        -- next approver allowed to timeout
        --
        if l_approvers_visited + 1 < l_apr_key_level then
            --sb_msgs_pkg.trace('10 - if');

            if g_debug then
		hr_utility.trace('not final 1');
	    end if;

            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APPROVAL_TIMEOUT',
                                    avalue   => l_default_timeout);
            p_result := 'COMPLETE:N';
        --
        -- next iteration takes us to key approver,
        -- determine timeout properties for next approver
        --
        elsif l_approvers_visited + 1 = l_apr_key_level then
            --sb_msgs_pkg.trace('20 - else if');

            --
            -- if supervisor exists for next approver,
            -- next approver allowed to timeout
            --
            if get_supervisor(l_apr_person_id,
                                            SYSDATE) is not null then
                --sb_msgs_pkg.trace('22 - if');

                wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname    => 'APPROVAL_TIMEOUT',
                                        avalue   => l_default_timeout);
            --
            -- if supervisor does not exist for next approver,
            -- next approver NOT allowed to timeout
            else
                --sb_msgs_pkg.trace('24 - else');

                wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname    => 'APPROVAL_TIMEOUT',
                                        avalue   => 0);
            end if;

            if g_debug then
		hr_utility.trace('not final 2');
	    end if;

            p_result := 'COMPLETE:N';
        --
        -- next iteration takes us above key approver,
        -- if key approver has approved then no need for further notification,
        -- if key approver has not approved (ie. timeout) then iterate,
        -- next approver not allowed to timeout (notification must wait here)
        --
        elsif l_approvers_visited + 1 > l_apr_key_level then
            --sb_msgs_pkg.trace('30 - else if');

            if l_approved_at_level >= l_apr_key_level then
                --sb_msgs_pkg.trace('32 - if');
		if g_debug then
	                hr_utility.trace('Yes final 1');
		end if;
                p_result := 'COMPLETE:Y';
            else
                --sb_msgs_pkg.trace('34 - else');

                if g_debug then
			hr_utility.trace('not final 3');
		end if;

                wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname    => 'APPROVAL_TIMEOUT',
                                        avalue   => 0);
                p_result := 'COMPLETE:N';
            end if;
        end if;

        --
        -- timeout to be used by next notification
        --
        l_approval_timeout := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APPROVAL_TIMEOUT');
        --sb_msgs_pkg.trace('l_apr_timeout(A)>' || l_approval_timeout || '<');
    end if;

    if p_funcmode = 'CANCEL' then
	if g_debug then
		hr_utility.trace('cancelled');
	end if;

        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then

        if g_debug then
		hr_utility.trace('completed');
	end if;

        p_result := 'COMPLETE';
    end if;

    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end is_final_apr;


-- Added new procedure to check if Timecard owner is active in fnd_user as on Sysdate
-- for bug 8594271
procedure check_user_exists(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
   l_proc 		varchar2(100);
   l_tc_user_name 	fnd_user.user_name%TYPE;
   l_count 		NUMBER;

begin

	if g_debug then
		l_proc := g_pkg || '.' || 'check_user_exists';
		hr_utility.set_location(l_proc, 10);
	end if;

	if p_funcmode = 'RUN' then

	        l_tc_user_name := wf_engine.GetItemAttrText(
                                itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'TC_OWNER_SS_LOGIN');

                select count(*) into l_count
                from fnd_user
                where user_name = l_tc_user_name
                and TRUNC(sysdate) between TRUNC(start_date) and NVL(TRUNC(end_date), TRUNC(sysdate));

                if l_count = 0 then
                 	p_result := 'COMPLETE:N';
                else
                 	p_result := 'COMPLETE:Y';
                end if;

	end if;

    	if p_funcmode = 'CANCEL' then
		if g_debug then
			hr_utility.trace('cancelled');
		end if;

    	    p_result := 'COMPLETE';
    	end if;

    	if p_funcmode = 'TIMEOUT' then

    	    if g_debug then
			hr_utility.trace('completed');
		end if;

    	    p_result := 'COMPLETE';
    	end if;


end check_user_exists;


--
-- formula decides approval style to use
--
procedure formula_selects_mechanism(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc varchar2(61);

    l_inputs           ff_exec.inputs_t;
    l_outputs          ff_exec.outputs_t;

    l_effective_date    date;
    l_formula_id        hxc_approval_comps.approval_mechanism_id%type;

    -- formula return values
    l_approval_mechanism    hxc_approval_comps.approval_mechanism%type;
    l_approval_mechanism_id hxc_approval_comps.approval_mechanism_id%type;
    l_wf_item_type          hxc_approval_comps.wf_item_type%type;
    l_wf_process_name       hxc_approval_comps.wf_name%type;
    l_person_id             per_all_assignments_f.person_id%type;
    l_formula_status        varchar2(10);
    l_formula_message       varchar2(2000);
begin
   --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');

	if g_debug then
		l_proc := g_pkg || '.' || 'formula_selects_mechanism';
		hr_utility.set_location(l_proc, 10);
	end if;

      l_person_id := wf_engine.GetItemAttrNumber(
                                             itemtype => p_itemtype,
                                             itemkey  => p_itemkey,
                                             aname    => 'RESOURCE_ID');
    if p_funcmode = 'RUN' then
        l_effective_date := wf_engine.GetItemAttrDate(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APP_END_DATE');

        l_formula_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'FORMULA_ID');

	if g_debug then
		hr_utility.set_location(l_proc, 20);
	end if;

        --
        -- initialise formula
        --
        --sb_msgs_pkg.trace('STEP 10 - before init_formula()');
-- gaz - remove
        ff_utils.set_debug(127);
        ff_exec.init_formula(l_formula_id, l_effective_date, l_inputs,l_outputs);

        --
        -- set up the inputs and contexts to formula
        -- nb. no contexts are used
        --

	if g_debug then
		hr_utility.set_location(l_proc, 30);
	end if;

        hr_utility.trace('Input count is:'||l_inputs.count);

        -- Added IF END IF condition for bug 8646570
        -- do not assign values to the formula inputs when none of the inputs are used within the formula

        if (l_inputs.count > 0) then
         for i in l_inputs.first..l_inputs.last loop

          hr_utility.trace('Input name:'||l_inputs(i).name);

          if l_inputs(i).name = 'TIMECARD_BB_ID' then

            if g_debug then
              hr_utility.set_location(l_proc, 40);
            end if;
            l_inputs(i).value := wf_engine.GetItemAttrNumber(
                                                             itemtype => p_itemtype,
                                                             itemkey  => p_itemkey,
                                                             aname    => 'TC_BLD_BLK_ID');

          elsif l_inputs(i).name = 'TIMECARD_BB_OVN' then
            if g_debug then
              hr_utility.set_location(l_proc, 50);
            end if;
            l_inputs(i).value := wf_engine.GetItemAttrNumber(
                                                             itemtype => p_itemtype,
                                                             itemkey  => p_itemkey,
                                                             aname    => 'TC_BLD_BLK_OVN');

          elsif l_inputs(i).name = 'APPLICATION_PERIOD_BB_ID' then
            if g_debug then
              hr_utility.set_location(l_proc, 60);
            end if;
            l_inputs(i).value := wf_engine.GetItemAttrNumber(
                                                             itemtype => p_itemtype,
                                                             itemkey  => p_itemkey,
                                                             aname    => 'APP_BB_ID');

          elsif l_inputs(i).name = 'APPLICATION_PERIOD_BB_OVN' then
            if g_debug then
              hr_utility.set_location(l_proc, 70);
            end if;
            l_inputs(i).value := wf_engine.GetItemAttrNumber(
                                                             itemtype => p_itemtype,
                                                             itemkey  => p_itemkey,
                                                             aname    => 'APP_BB_OVN');

          elsif l_inputs(i).name = 'TIME_RECIPIENT_ID' then
            if g_debug then
              hr_utility.set_location(l_proc, 80);
            end if;
            l_inputs(i).value := wf_engine.GetItemAttrNumber(
                                                             itemtype => p_itemtype,
                                                             itemkey  => p_itemkey,
                                                             aname    => 'TIME_RECIPIENT_ID');
            l_inputs(i).value := 5;

          elsif l_inputs(i).name = 'RESOURCE_ID' then
            if g_debug then
              hr_utility.set_location(l_proc, 90);
            end if;
            l_inputs(i).value := wf_engine.GetItemAttrNumber(
                                                             itemtype => p_itemtype,
                                                             itemkey  => p_itemkey,
                                                             aname    => 'RESOURCE_ID');

          elsif l_inputs(i).name = 'RESOURCE_TYPE' then
            if g_debug then
              hr_utility.set_location(l_proc, 100);
            end if;
            l_inputs(i).value := 'abc';

          else
            --
            -- context not recognised
            --
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '20');
            hr_utility.raise_error;
          end if;
         end loop;
	end if;  -- Bug 8646570

	if g_debug then
          hr_utility.set_location(l_proc, 110);
	end if;
        --sb_msgs_pkg.trace('STEP 30 - before run_formula()');
        ff_exec.run_formula(l_inputs, l_outputs);

	if g_debug then
		hr_utility.set_location(l_proc, 120);
        end if;

	--
        -- obtain return values,
        -- there should be at least three outputs
        --
        assert(l_outputs.count >= 3, l_proc || ':STEP 40');

        for i in l_outputs.first..l_outputs.last loop

	if g_debug then
		hr_utility.set_location(l_proc, 130);
	end if;

            if l_outputs(i).name = 'APPROVAL_MECHANISM' then
                l_approval_mechanism := l_outputs(i).value;

            elsif l_outputs(i).name = 'APPROVAL_MECHANISM_ID' then
                l_approval_mechanism_id := l_outputs(i).value;

            elsif l_outputs(i).name = 'WF_ITEM_TYPE' then
                l_wf_item_type := l_outputs(i).value;

            elsif l_outputs(i).name = 'WF_PROCESS_NAME' then
                l_wf_process_name := l_outputs(i).value;

            elsif l_outputs(i).name = 'FORMULA_STATUS' then
                l_formula_status := l_outputs(i).value;

            elsif l_outputs(i).name = 'FORMULA_MESSAGE' then
                l_formula_message := l_outputs(i).value;

            else
                hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PROCEDURE', l_proc);
                hr_utility.set_message_token('STEP', '50');
                hr_utility.raise_error;
            end if;
        end loop;

        --
        -- check whether formual has raised an error and act appropriately
        --
	if g_debug then
		hr_utility.set_location(l_proc, 140);
	end if;

        if l_formula_status = 'E' then
            --
            -- formula has failed, raise an error
            --
	if g_debug then
		hr_utility.set_location(l_proc, 150);
	end if;

            if l_formula_message is null then
                --
                -- user not defined an error message, raise OTC default message
                -- stub - need our own error message
                --
                fnd_message.set_name('PAY', 'HR_6648_ELE_ENTRY_FORMULA_ERR');
                hr_utility.raise_error;
            else
                --
                -- user has defined message, raise it
                --
                fnd_message.set_name('PAY', 'HR_ELE_ENTRY_FORMULA_HINT');
                fnd_message.set_token('FORMULA_TEXT', l_formula_message, false);
                hr_utility.raise_error;
            end if;

        elsif l_formula_status = 'W' then

	if g_debug then
		hr_utility.set_location(l_proc, 160);
        end if;
	    --
            -- formula has failed, but only warning necessary
            --
            if l_formula_message is null then
                --
                -- user has not defined an error message
                --
                fnd_message.set_name('PAY', 'HR_6648_ELE_ENTRY_FORMULA_ERR');
                hr_utility.set_warning;
            else
                --
                -- user has defined message, raise it
                --
                fnd_message.set_name('PAY', 'HR_ELE_ENTRY_FORMULA_HINT');
                fnd_message.set_token('FORMULA_TEXT', l_formula_message, false);
                hr_utility.set_warning;
            end if;
        end if;

        --
        -- set up context for approval mechanism
        --
        -- auto approval no further context is required
        --
	if g_debug then
		hr_utility.set_location(l_proc, 170);
	end if;

        if l_approval_mechanism = 'AUTO_APPROVE' then
            --sb_msgs_pkg.trace('formula selects auto approve approval');
            null;

        --
        -- person approval, set approving person id context
        --
        elsif l_approval_mechanism = 'PERSON' then
            --sb_msgs_pkg.trace('formula selects person approval');
	if g_debug then
		hr_utility.set_location(l_proc, 180);
	end if;

            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APR_PERSON_ID',
                                avalue   => l_approval_mechanism_id);

	if g_debug then
		hr_utility.set_location(l_proc, 190);
        end if;

	--
        -- HR supervisor approval, approving person id can derived from
        -- resource id on application period,
        -- Find Approval Style activity has already been called, this should
        -- ensure that global context information has been set
        --
        elsif l_approval_mechanism = 'HR_SUPERVISOR' then
            --sb_msgs_pkg.trace('formula selects hr supervisor approval');

            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'APR_PERSON_ID',
                                avalue   => l_person_id);

        --
        -- workflow approval, set workflow item type and workflow process name
        --
        elsif l_approval_mechanism = 'WORKFLOW' then
            --sb_msgs_pkg.trace('formula selects workflow approval');

            wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'WF_ITEM_TYPE',
                                avalue   => l_wf_item_type);

            wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'WF_PROCESS_NAME',
                                avalue   => l_wf_process_name);

        elsif l_approval_mechanism = 'PROJECT_MANAGER'
        then
          NULL;
        else
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '60');
            hr_utility.raise_error;
        end if;

        --
        -- set result code for transition to next activity
        --
        p_result := l_approval_mechanism;
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end formula_selects_mechanism;



--
-- launch user defined workflow process
--
procedure launch_wf_process(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'launch_wf_process';
    l_item_key          number;
    l_ap_bbid           hxc_time_building_blocks.time_building_block_id%type;
    l_ap_bbovn          hxc_time_building_blocks.time_building_block_id%type;
    l_wf_item_type      hxc_approval_comps.wf_item_type%type;
    l_wf_process_name   hxc_approval_comps.wf_name%type;
    l_apr_person_id     per_all_assignments_f.person_id%type;
    l_resource_id     per_all_assignments_f.person_id%type;
begin
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');

    l_ap_bbid := wf_engine.GetItemAttrNumber(
                                        itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname    => 'APP_BB_ID');

    l_ap_bbovn := wf_engine.GetItemAttrNumber(
                                        itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname    => 'APP_BB_OVN');

    l_wf_item_type := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                                itemkey  => p_itemkey,
                                                aname    => 'WF_ITEM_TYPE');

    l_wf_process_name := wf_engine.GetItemAttrText(
                                                itemtype => p_itemtype,
                                                itemkey  => p_itemkey,
                                                aname    => 'WF_PROCESS_NAME');

    --
    -- get key for item instance
    --
    SELECT hxc_approval_wf_s.nextval
    INTO   l_item_key
    FROM   DUAL;

    --sb_msgs_pkg.trace('l_item_key>' || l_item_key || '<');

    wf_engine.createProcess(l_wf_item_type, l_item_key, l_wf_process_name);


    --
    -- set attributes required by child workflow,
    -- set parent item type and key in child workflow process
    --
    wf_engine.SetItemAttrText(itemtype => l_wf_item_type,
                                itemkey  => l_item_key,
                                aname    => 'PARENT_ITEM_TYPE',
                                avalue   => p_itemtype);

    wf_engine.SetItemAttrText(itemtype => l_wf_item_type,
                                itemkey  => l_item_key,
                                aname    => 'PARENT_ITEM_KEY',
                                avalue   => p_itemkey);
    --
    wf_engine.SetItemParent
                (itemtype         => l_wf_item_type,
                 itemkey          => l_item_key,
                 parent_itemtype  => p_itemtype,
                 parent_itemkey   => p_itemkey,
                 parent_context   => NULL);
    --
    -- launch customer's workflow process
    --
    wf_engine.startProcess(l_wf_item_type, l_item_key);

    l_apr_person_id := wf_engine.GetItemAttrNumber(
                                                    itemtype => p_itemtype,
                                                    itemkey  => p_itemkey,
                                                   aname    => 'APR_PERSON_ID');
    l_resource_id := wf_engine.GetItemAttrNumber(
    	                                         itemtype => p_itemtype,
                                                 itemkey  => p_itemkey,
               	                                 aname    => 'RESOURCE_ID');
    --OIT Enhancement
    --FYI Notification to SUPERVISOR on timecard SUBMISSION if he is not direct approver
    if(hxc_approval_wf_helper.is_approver_supervisor(l_apr_person_id,l_resource_id)) then
               hxc_approval_wf_helper.set_notif_attribute_values
                 (p_itemtype,
                  p_itemkey,
                  null,
                  null
                 );
    else
               hxc_approval_wf_helper.set_notif_attribute_values
                 (p_itemtype,
                  p_itemkey,
                  hxc_app_comp_notifications_api.c_action_request_approval,
                  hxc_app_comp_notifications_api.c_recipient_supervisor
                 );
    end if;

    --
    -- next activity waits for child processes to complete
    --
    p_result := 'COMPLETE';

    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end launch_wf_process;



--
-- test out workflow result
--
procedure test_wf_result(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc constant varchar2(61) := g_pkg || '.' || 'test_wf_result';
    l_datetime constant date := SYSDATE;
    l_ap_bbid           hxc_time_building_blocks.time_building_block_id%type;
    l_ap_bbovn          hxc_time_building_blocks.time_building_block_id%type;
    l_apr_rej_reason    varchar2(2000);
    l_wf_apr_result varchar2(80);
begin
    --sb_msgs_pkg.begin_call(l_proc);
    --sb_msgs_pkg.trace('p_funcmode>' || p_funcmode || '<');

    if p_funcmode = 'RUN' then
        l_wf_apr_result := wf_engine.GetItemAttrText(
                      itemtype => p_itemtype,
                      itemkey  => p_itemkey,
                      aname    => 'WF_APPROVAL_RESULT');
        --sb_msgs_pkg.trace('WF_APPROVAL_RESULT>' || l_wf_apr_result || '<');

        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => l_wf_apr_result);


        if l_wf_apr_result = 'APPROVED' then
            --OIT Enhancement
            --FYI Notification to PREPARER on timecard APPROVAL
            hxc_approval_wf_helper.set_notif_attribute_values
             (p_itemtype,
              p_itemkey,
              hxc_app_comp_notifications_api.c_action_approved,
              hxc_app_comp_notifications_api.c_recipient_preparer
             );
            p_result := 'COMPLETE:APPROVED';

        elsif l_wf_apr_result = 'REJECTED' then
            --OIT Enhancement
            --FYI Notification to PREPARER on timecard REJECTION
            hxc_approval_wf_helper.set_notif_attribute_values
             (p_itemtype,
              p_itemkey,
              hxc_app_comp_notifications_api.c_action_rejected,
              hxc_app_comp_notifications_api.c_recipient_preparer
             );
            p_result := 'COMPLETE:REJECTED';

        else
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '10');
            hr_utility.raise_error;
        end if;
    end if;

    if p_funcmode = 'CANCEL' then
        p_result := 'COMPLETE';
    end if;

    if p_funcmode = 'TIMEOUT' then
        p_result := 'COMPLETE';
    end if;

    --sb_msgs_pkg.trace('p_result>' || p_result || '<');
    --sb_msgs_pkg.end_call(l_proc);
exception
    when others then
        --sb_msgs_pkg.trace('sqlcode>' || sqlcode || '<');
        --sb_msgs_pkg.trace('sqlerrm>' || sqlerrm || '<');

        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end test_wf_result;


PROCEDURE set_next_app_period(
  p_itemtype in     varchar2,
  p_itemkey  in     varchar2,
  p_actid    in     number,
  p_funcmode in     varchar2,
  p_result   in out nocopy varchar2
)
IS
  l_next_period_id hxc_time_building_blocks.time_building_block_id%TYPE;
  l_next_period_ovn hxc_time_building_blocks.object_version_number%TYPE;


  l_proc VARCHAR2(150);

BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	  l_proc  := 'set_next_app_period';
	  hr_utility.trace('in set next period');
  end if;
  IF p_funcmode = 'RUN'
  THEN
    l_next_period_id := wf_engine.GetItemAttrNumber(
		                        itemtype  => p_itemtype,
                                        itemkey   => p_itemkey,
                                        aname     => 'NEXT_APP_BB_ID');

    if g_debug then
	hr_utility.set_location(l_proc, 60);
    end if;

    l_next_period_ovn := wf_engine.GetItemAttrNumber(
                                        itemtype  => p_itemtype,
                                        itemkey   => p_itemkey,
                                        aname     => 'NEXT_APP_BB_OVN');

    wf_engine.SetItemAttrNumber(itemtype  => p_itemtype,
                               itemkey   => p_itemkey,
                               aname     => 'APP_BB_ID',
                               avalue    => l_next_period_id);

    wf_engine.SetItemAttrNumber(itemtype  => p_itemtype,
                              itemkey   => p_itemkey,
                              aname     => 'APP_BB_OVN',
                              avalue    => l_next_period_ovn);

    wf_engine.SetItemAttrText(itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'APR_REJ_REASON',
                             avalue   => '');

    wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => '');


    if g_debug then
	    hr_utility.trace('next app id=' ||  l_next_period_id);
	    hr_utility.trace('next app ovn=' || l_next_period_ovn);
    end if;
    p_result := 'COMPLETE';
  END IF;

  IF p_funcmode = 'CANCEL'
  THEN
    p_result := 'COMPLETE';
  END IF;

  IF p_funcmode = 'TIMEOUT'
  THEN
    p_result := 'COMPLETE';
  END IF;

EXCEPTION
  WHEN OTHERS THEN


    wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
                        p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
    raise;
END set_next_app_period;

end hxc_find_notify_aprs_pkg;

/
