--------------------------------------------------------
--  DDL for Package Body HXC_TIMEKEEPER_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMEKEEPER_WF_PKG" AS
/* $Header: hxctimekeeperwf.pkb 120.4 2007/01/10 21:14:38 arundell noship $ */

g_debug boolean := hr_utility.debug_enabled;

-------------------------------------------------------------------
-- Function to get the next Item Key for the Process
-------------------------------------------------------------------
FUNCTION GET_ITEM_KEY RETURN NUMBER IS
l_item_key number;
BEGIN

  select hxc_approval_item_key_s.nextval
  Into l_item_key
  from dual;

  RETURN l_item_key;
END GET_ITEM_KEY;

-------------------------------------------------------------------
-- Function to get the supervisor
-------------------------------------------------------------------
FUNCTION GET_SUPERVISOR(
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

----------------------------------------------------------------------------
-- Timekeeper Audit Workflow Notification
----------------------------------------------------------------------------
Function begin_audit_process
	  (p_timecard_id   in hxc_time_building_blocks.time_building_block_id%type
	  ,p_timecard_ovn  in hxc_time_building_blocks.object_version_number%type
	  ,p_resource_id   in hxc_time_building_blocks.resource_id%type
	  ,p_timekeeper_id in hxc_time_building_blocks.resource_id%type
	  ,p_tk_audit_enabled in VARCHAR2
	  ,p_tk_notify_to  in VARCHAR2
	  ,p_tk_notify_type in VARCHAR2
	  ,p_property_table               hxc_timecard_prop_table_type
           ) return VARCHAR2 IS

l_item_key     NUMBER := NULL;
l_cla_terg_id	NUMBER :=Null;

BEGIN

l_cla_terg_id := to_number(hxc_timecard_properties.find_property_value
                                (p_property_table
                                ,'TsPerAuditRequirementsAuditRequirements'
                                ,null
                                ,null
				,sysdate
				,sysdate
                                ));

if(l_cla_terg_id is not null and
   p_tk_notify_to <>'NONE'   and
   p_tk_audit_enabled ='Y' ) then

l_item_key := HXC_TIMEKEEPER_WF_PKG.GET_ITEM_KEY;

HXC_TIMEKEEPER_WF_PKG.START_TK_WF_PROCESS
( p_item_type	   => 'HXCTKWF'
 ,p_item_key	   =>  l_item_key
 ,p_process_name   => 'HXC_TK_AUDIT_PROCESS'
 ,p_tc_bb_id       =>  p_timecard_id
 ,p_tc_ovn	   =>  p_timecard_ovn
 ,p_tc_resource_id =>  p_resource_id
 ,p_timekeeper_id  =>  p_timekeeper_id
 ,p_tk_nofity_type =>  p_tk_notify_type
 ,p_tk_nofity_to   =>  p_tk_notify_to
);

end if;

return to_char(l_item_key);

END begin_audit_process;

-------------------------------------------------------------------
-- Function to handle timeout case
-------------------------------------------------------------------
procedure capture_timeout_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2) IS

cursor c_transaction_id
(p_tbb_id  in number,
 p_tbb_ovn in number) is
 select transaction_id
 from  hxc_transaction_details
 where time_building_block_id = p_tbb_id
 and   object_version_number  = p_tbb_ovn;

 l_tx_id		NUMBER := NULL;
 l_tc_resource_id     number;
 l_period_start_date  date;
 l_period_end_date    date;

 l_timeouts NUMBER ;

 l_tbb_id    hxc_time_building_blocks.time_building_block_id%type;
 l_tbb_ovn   hxc_time_building_blocks.time_building_block_id%type;
 l_error_id NUMBER;
 l_ovn NUMBER;
 l_approver_type VARCHAR2(30);
 l_message_name   VARCHAR2(250);

begin

   IF p_funcmode = 'TIMEOUT' then

	l_timeouts := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'TIMEOUT_COUNT');

	if l_timeouts  > 0 then

         wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                             itemkey  => p_itemkey,
                             aname    => 'DEFAULT_TIMEOUT',
                             avalue   => 0);


	  l_approver_type := wf_engine.GetItemAttrText(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APR_NOTIFY_TO');

	  l_tbb_id := wf_engine.GetItemAttrNumber(
		                        itemtype  => p_itemtype,
                                        itemkey   => p_itemkey,
                                        aname     => 'TC_BLD_BLK_ID');

	  l_tbb_ovn := wf_engine.GetItemAttrNumber(
                                        itemtype  => p_itemtype,
                                        itemkey   => p_itemkey,
                                        aname     => 'TC_BLD_BLK_OVN');


	   IF    l_approver_type ='WORKER'  THEN
		 l_message_name := 'HXC_WF_TK_WORKER_NO_RESPOND';
	   ELSIF l_approver_type ='SUPERVISOR' THEN
		 l_message_name := 'HXC_WF_TK_SUPER_NO_RESPOND';
	   END IF;

	OPEN   c_transaction_id(l_tbb_id,l_tbb_ovn);
	FETCH  c_transaction_id INTO l_tx_id;
	CLOSE  c_transaction_id;

	IF (l_tx_id is null) THEN
            l_tx_id := -1;
	END IF;

	  hxc_err_ins.ins
	  (p_transaction_detail_id         => l_tx_id
	  ,p_time_building_block_id        => l_tbb_id
	  ,p_time_building_block_ovn       => l_tbb_ovn
          ,p_time_attribute_id             => NULL
          ,p_time_attribute_ovn            => NULL
          ,p_message_name                  => l_message_name
          ,p_message_level                 => 'BUSINESS_MESSAGE'
          ,p_message_field                 => NULL
          ,p_message_tokens                => NULL
          ,p_application_short_name        => 'HXC'
	  ,p_error_id                      => l_error_id
	  ,p_object_version_number	   => l_ovn
          ,p_date_from			   => sysdate
	  ,p_date_to			   => hr_general.end_of_time
	  );

	end if;

       l_timeouts :=l_timeouts +1;

	wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'TIMEOUT_COUNT',
			      avalue   => l_timeouts );

    end if;
end capture_timeout_status;
-------------------------------------------------------------------
-- Function to get the login
-------------------------------------------------------------------
FUNCTION set_login(
    p_person_id      in number,
    p_tc_bb_id       in number,
    p_tc_bb_ovn      in number)
return varchar2
is

     cursor c_updated_by
         (p_tc_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
         ,p_tc_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
         ) is
  select u.user_name
    from fnd_user u, hxc_time_building_blocks tbb
   where tbb.time_building_block_id = p_tc_id
     and tbb.object_version_number = p_tc_ovn
     and tbb.last_updated_by = u.user_id;

    l_proc constant      varchar2(61) :='hxc_timekeeper_wf_pkg.set_login';
    l_login              fnd_user.user_name%type;
begin

	l_login := hxc_find_notify_aprs_pkg.get_login(p_person_id => p_person_id);

       --
        -- if null returned, timecard owner does not have a self
        -- service login name, where does notification get sent?
        --
        if l_login is null then
	      open c_updated_by(p_tc_bb_id,p_tc_bb_ovn);
              fetch c_updated_by into l_login;

              if (c_updated_by%NOTFOUND) then
                close c_updated_by;
                hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PROCEDURE', l_proc);
                hr_utility.set_message_token('STEP', '20');
                hr_utility.raise_error;
              end if;
              close c_updated_by;
        end if;

    return l_login;
end set_login;

------------------------------------------------------------------
-- Cancel Prvious Notifications
------------------------------------------------------------------
PROCEDURE cancel_previous_notifications
( p_tk_audit_item_type in     varchar2
 ,p_tk_audit_item_key in     varchar2
) IS

CURSOR c_audit_keys is
SELECT ITEM_KEY,ITEM_TYPE
from wf_items
where parent_item_key =p_tk_audit_item_key
and parent_item_type = p_tk_audit_item_type;


-- Changed the query in the cursor for the bug 4696149.
/*
CURSOR c_notification_id(p_item_key varchar2,p_item_type varchar2) is
   select Notification_id
    from WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA
    where WIAS.ITEM_TYPE = p_item_type
    and WIAS.ITEM_KEY = p_item_key
    and WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
    and WPA.ACTIVITY_NAME = 'FYI_NOTIFICATION'
    and WPA.PROCESS_NAME = nvl('HXC_TK_AUDIT', WPA.PROCESS_NAME);
*/

CURSOR c_notification_id(p_item_key varchar2,p_item_type varchar2) is
   select  wn.notification_id nid
   from  WF_NOTIFICATIONS WN, WF_ITEM_ACTIVITY_STATUSES WIAS
   where WN.GROUP_ID = WIAS.NOTIFICATION_ID
    and  WIAS.ITEM_TYPE = p_item_type
     and WIAS.ITEM_KEY = p_item_key;

l_item_key  wf_items.item_key%type;
l_item_type wf_items.item_type%type;
l_ntfid     Number;

BEGIN

FOR audit_keys in c_audit_keys LOOP

l_item_key := audit_keys.item_key;
l_item_type := audit_keys.item_type;

  BEGIN
	BEGIN
	-- As of now abort process will cancel all notifications which are
	-- in Notified state
	-- This  will start calcelling the notifications when the bug 3468491 get's fixed
	-- We need not call cancel notifications after this bug is fixed.

	wf_engine.abortprocess
		(itemkey => audit_keys.item_key
		 ,itemtype => audit_keys.item_typE);

	EXCEPTION
	When others then

	-- to cancel FYI notifications we use the workaround to get the notification id and
	--cancel the notification

	l_ntfid :=Null;
        Open c_notification_id(l_item_key,l_item_type);
        fetch c_notification_id into l_ntfid;
        close c_notification_id;

	if l_ntfid is not Null then
            wf_notification.cancel(l_ntfid);
        end if;
	END;

   EXCEPTION
	When others then
	Null;
   END;
END LOOP;

END cancel_previous_notifications;

-------------------------------------------------------------------
-- Prodedure to set timecard Hours
-------------------------------------------------------------------
PROCEDURE set_timecard_hours(
    p_itemtype		in varchar2,
    p_itemkey		in varchar2,
    p_tc_bb_id		in number,
    p_tc_bb_ovn		in number) is

    l_total_hours        number;

BEGIN
        wf_engine.SetItemAttrText
          (itemtype => p_itemtype,
           itemkey  => p_itemkey,
           aname    => 'DESCRIPTION',
           avalue   => hxc_find_notify_aprs_pkg.get_description_tc(p_tc_bb_id,p_tc_bb_ovn)
           );

	l_total_hours := HXC_TIME_CATEGORY_UTILS_PKG.category_timecard_hrs (
				 p_tbb_id       => p_tc_bb_id
				, p_tbb_ovn     => p_tc_bb_ovn
				, P_TIME_CATEGORY_NAME => '' );

        wf_engine.SetItemAttrNumber(
		                      itemtype => p_itemtype,
		                      itemkey  => p_itemkey,
		                      aname    => 'TOTAL_TC_HOURS',
		                      avalue   => round(l_total_hours,3));


end set_timecard_hours;


-------------------------------------------------------------------
-- Function to get the name for the approver
-------------------------------------------------------------------
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

-------------------------------------------------------------------
-- Function to set the attributes and start the child process based
-- on the nofitication to
-------------------------------------------------------------------
PROCEDURE start_child_process
              (p_tc_item_type      IN        VARCHAR2
              ,p_tc_item_key       IN        VARCHAR2
              ,p_tc_process_name   IN        VARCHAR2
              ,p_tc_bb_id          IN        NUMBER
              ,p_tc_bb_ovn         IN        NUMBER
	      ,p_tc_start_time     IN        DATE
	      ,p_tc_stop_time      IN        DATE
	      ,p_tc_resource_id    IN	     NUMBER
	      ,p_tc_timekeeper_id  IN        NUMBER
	      ,p_tc_tk_nofity_type IN	     VARCHAR2
	      ,p_tc_tk_nofity_to   IN	     VARCHAR2
              )is

    l_child_item_key     wf_items.item_key%type;

BEGIN
	l_child_item_key := hxc_timekeeper_wf_pkg.get_item_key;

         wf_engine.CreateProcess(itemtype => p_tc_item_type,
                                itemkey  => l_child_item_key,
                                process  => p_tc_process_name);

          wf_engine.setitemowner(p_tc_item_type,
                               l_child_item_key,
                               HXC_FIND_NOTIFY_APRS_PKG.get_login(p_tc_timekeeper_id));


	  wf_engine.SetItemAttrNumber
	   (itemtype	=> p_tc_item_type
	   ,itemkey  	=> l_child_item_key
	   ,aname 	=> 'TC_BLD_BLK_ID'
	   ,avalue	=> p_tc_bb_id
	   );

	  wf_engine.SetItemAttrNumber
	   (itemtype    => p_tc_item_type
	   ,itemkey     => l_child_item_key
	   ,aname       => 'TC_BLD_BLK_OVN'
	   ,avalue      => p_tc_bb_ovn
	   );

	  wf_engine.SetItemAttrNumber
	   (itemtype    => p_tc_item_type
	   ,itemkey     => l_child_item_key
	   ,aname       => 'RESOURCE_ID'
	   ,avalue      => p_tc_resource_id
	   );

	  wf_engine.SetItemAttrDate
	   (itemtype    => p_tc_item_type
	   ,itemkey     => l_child_item_key
	   ,aname       => 'TC_START'
	   ,avalue      => p_tc_start_time
	   );

          wf_engine.SetItemAttrText
	   (itemtype    => p_tc_item_type
	   ,itemkey     => l_child_item_key
	   ,aname       => 'FORMATTED_TC_START'
	   ,avalue      => to_char(p_tc_start_time,'YYYY/MM/DD')
	   );

	  wf_engine.SetItemAttrDate
	   (itemtype    => p_tc_item_type
	   ,itemkey     => l_child_item_key
	   ,aname       => 'TC_STOP'
	   ,avalue      => p_tc_stop_time
	   );

	  wf_engine.SetItemAttrText
	   (itemtype    => p_tc_item_type
	   ,itemkey     => l_child_item_key
	   ,aname       => 'FORMATTED_TC_STOP'
	   ,avalue      => to_char(p_tc_stop_time,'YYYY/MM/DD')
	   );

	  wf_engine.SetItemAttrNumber
	   (itemtype    => p_tc_item_type
	   ,itemkey     => l_child_item_key
	   ,aname       => 'TIMEKEEPER_ID'
	   ,avalue      => p_tc_timekeeper_id
	   );

	 wf_engine.SetItemAttrText
	  (itemtype => p_tc_item_type,
	   itemkey  => l_child_item_key,
	   aname    => 'APR_NOTIFY_TYPE',
	   avalue   => p_tc_tk_nofity_type
	   );

	 wf_engine.SetItemAttrText
	  (itemtype => p_tc_item_type,
	   itemkey  => l_child_item_key,
	   aname    => 'APR_NOTIFY_TO',
	   avalue   => p_tc_tk_nofity_to
	   );

         wf_engine.SetItemParent
                (itemtype         => p_tc_item_type,
                 itemkey          => l_child_item_key,
                 parent_itemtype  => p_tc_item_type,
                 parent_itemkey   => p_tc_item_key,
                 parent_context   => NULL);

          wf_engine.StartProcess(itemtype => p_tc_item_type,
                               itemkey  => l_child_item_key);
END START_CHILD_PROCESS;

-------------------------------------------------------------------
-- Staring point from Tk form
-------------------------------------------------------------------
PROCEDURE start_tk_wf_process
              (p_item_type      IN            varchar2
              ,p_item_key       IN            varchar2
              ,p_process_name   IN            varchar2
              ,p_tc_bb_id       IN            number
              ,p_tc_ovn         IN            number
	      ,p_tc_resource_id IN	      NUMBER
	      ,p_timekeeper_id  IN            NUMBER
	      ,p_tk_nofity_type IN	      VARCHAR2
	      ,p_tk_nofity_to   IN	      VARCHAR2
              )is
BEGIN

  wf_engine.createProcess
   (itemtype => p_item_type
   ,itemkey  => p_item_key
   ,process  => p_process_name
   );

  wf_engine.SetItemAttrNumber
   (itemtype	=> p_item_type
   ,itemkey  	=> p_item_key
   ,aname 	=> 'TC_BLD_BLK_ID'
   ,avalue	=> p_tc_bb_id
   );

  wf_engine.SetItemAttrNumber
   (itemtype    => p_item_type
   ,itemkey     => p_item_key
   ,aname       => 'TC_BLD_BLK_OVN'
   ,avalue      => p_tc_ovn
   );

  wf_engine.SetItemAttrNumber
   (itemtype    => p_item_type
   ,itemkey     => p_item_key
   ,aname       => 'RESOURCE_ID'
   ,avalue      => p_tc_resource_id
   );

  wf_engine.SetItemAttrNumber
   (itemtype    => p_item_type
   ,itemkey     => p_item_key
   ,aname       => 'TIMEKEEPER_ID'
   ,avalue      => p_timekeeper_id
   );

 wf_engine.SetItemAttrText
  (itemtype => p_item_type,
   itemkey  => p_item_key,
   aname    => 'TK_NOTIFY_TYPE',
   avalue   => p_tk_nofity_type
   );

 wf_engine.SetItemAttrText
  (itemtype => p_item_type,
   itemkey  => p_item_key,
   aname    => 'TK_NOTIFY_TO',
   avalue   => p_tk_nofity_to
   );

  wf_engine.setitemowner
   (itemtype    => p_item_type
   ,itemkey     => p_item_key
    ,owner      => HXC_FIND_NOTIFY_APRS_PKG.get_login(p_tc_resource_id));

  wf_engine.StartProcess
   (itemtype => p_item_type
   ,itemkey  => p_item_key
   );

  wf_engine.threshold := 50;

END start_tk_wf_process;

-------------------------------------------------------------------
-- TO get the Notification Type from Tk preference and decide
-- to whom the notification should be sent to
-------------------------------------------------------------------
PROCEDURE START_TK_NOTIFICATION (
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
IS


    CURSOR c_tc_info(
      p_tc_bbid hxc_time_building_blocks.time_building_block_id%TYPE
      ,p_tc_ovn  hxc_time_building_blocks.object_version_number%TYPE
    )
    IS
    SELECT tcsum.resource_id,
           tcsum.start_time,
           tcsum.stop_time
      FROM hxc_time_building_blocks tcsum
     WHERE  tcsum.time_building_block_id = p_tc_bbid
     AND    tcsum.object_version_number = p_tc_ovn ;


    l_proc constant      varchar2(61) :='hxc_timekeeper_wf_pkg.find_tk_ntf_style';
    l_tc_bb_id           hxc_time_building_blocks.time_building_block_id%type;
    l_tc_bb_ovn          hxc_time_building_blocks.time_building_block_id%type;
    l_tc_start_time      hxc_time_building_blocks.start_time%TYPE;
    l_tc_stop_time       hxc_time_building_blocks.stop_time%TYPE;
    l_ntf_type	         VARCHAR2(150);
    l_ntf_to	         VARCHAR2(150);
    l_timkeeper_id       hxc_time_building_blocks.resource_id%TYPE;
    l_child_item_key     wf_items.item_key%type;
    l_process_name       varchar2(150);
    l_resource_id	 hxc_time_building_blocks.resource_id%TYPE;

BEGIN

        l_tc_bb_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_BLD_BLK_ID');

        l_tc_bb_ovn := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_BLD_BLK_OVN');

	l_timkeeper_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TIMEKEEPER_ID');

	l_resource_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'RESOURCE_ID');

	l_ntf_to      := wf_engine.GetItemAttrText(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'TK_NOTIFY_TO');

	l_ntf_type     := wf_engine.GetItemAttrText(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'TK_NOTIFY_TYPE');

        open c_tc_info(l_tc_bb_id,l_tc_bb_ovn);
        fetch c_tc_info
	into l_resource_id, l_tc_start_time, l_tc_stop_time;

        if c_tc_info%notfound then
            close c_tc_info;
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP', '12');
            hr_utility.raise_error;
        end if;
        close c_tc_info;

        wf_engine.SetItemAttrDate(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_START',
                                  avalue   => l_tc_start_time);

        wf_engine.SetItemAttrDate(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_STOP',
                                  avalue   => l_tc_stop_time);

	IF l_ntf_to ='NONE' THEN
	     p_result := 'COMPLETE';
	ELSIF l_ntf_to ='WORKER' OR l_ntf_to ='SUPERVISOR' THEN

	   start_child_process
              (p_tc_item_type       => p_itemtype
              ,p_tc_item_key        => p_itemkey
              ,p_tc_process_name    => 'HXC_TK_AUDIT'
              ,p_tc_bb_id           => l_tc_bb_id
              ,p_tc_bb_ovn          => l_tc_bb_ovn
	      ,p_tc_start_time      => l_tc_start_time
	      ,p_tc_stop_time       => l_tc_stop_time
	      ,p_tc_resource_id     => l_resource_id
	      ,p_tc_timekeeper_id   => l_timkeeper_id
	      ,p_tc_tk_nofity_type  => l_ntf_type
	      ,p_tc_tk_nofity_to    => l_ntf_to
	      );
	ELSIF l_ntf_to ='WORKER_SUPERVISOR' THEN

	   start_child_process
              (p_tc_item_type       => p_itemtype
              ,p_tc_item_key        => p_itemkey
              ,p_tc_process_name    => 'HXC_TK_AUDIT'
              ,p_tc_bb_id           => l_tc_bb_id
              ,p_tc_bb_ovn          => l_tc_bb_ovn
	      ,p_tc_start_time      => l_tc_start_time
	      ,p_tc_stop_time       => l_tc_stop_time
	      ,p_tc_resource_id     => l_resource_id
	      ,p_tc_timekeeper_id   => l_timkeeper_id
	      ,p_tc_tk_nofity_type  => l_ntf_type
	      ,p_tc_tk_nofity_to    => 'WORKER'
	      );
	   start_child_process
              (p_tc_item_type       => p_itemtype
              ,p_tc_item_key        => p_itemkey
              ,p_tc_process_name    => 'HXC_TK_AUDIT'
              ,p_tc_bb_id           => l_tc_bb_id
              ,p_tc_bb_ovn          => l_tc_bb_ovn
	      ,p_tc_start_time      => l_tc_start_time
	      ,p_tc_stop_time       => l_tc_stop_time
	      ,p_tc_resource_id     => l_resource_id
	      ,p_tc_timekeeper_id   => l_timkeeper_id
	      ,p_tc_tk_nofity_type  => l_ntf_type
	      ,p_tc_tk_nofity_to    => 'SUPERVISOR'
	      );
	END IF;

  p_result := '';

END START_TK_NOTIFICATION;

-------------------------------------------------------------------
-- Decide the Notification To
-------------------------------------------------------------------

PROCEDURE FIND_NTF_TO(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
IS
    l_apr_ntf_to	         VARCHAR2(150);

BEGIN

	l_apr_ntf_to    := wf_engine.GetItemAttrText(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'APR_NOTIFY_TO');

	IF l_apr_ntf_to='WORKER' then
	   p_result := 'COMPLETE:WORKER';
	ELSIF l_apr_ntf_to='SUPERVISOR' then
	   p_result := 'COMPLETE:SUPERVISOR';
	END IF;

END find_ntf_to;

-------------------------------------------------------------------
-- Person  Notification
-------------------------------------------------------------------
PROCEDURE PERSON_NOTIFY(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
IS

    l_resource_id	 hxc_time_building_blocks.resource_id%TYPE;
    l_login              fnd_user.user_name%type;
    l_fyi_login		 fnd_user.user_name%type;
    l_start_date	 DATE;
    l_stop_date		 DATE;
    l_tc_bb_id	         hxc_time_building_blocks.time_building_block_id%type;
    l_tc_bb_ovn          hxc_time_building_blocks.time_building_block_id%type;
    l_ntf_type		 VARCHAR2(150);
    l_proc       varchar2(61);
    l_title		 VARCHAR2(2000);
    l_otl_appr_id	 VARCHAR2(2000);
    l_timekeeper_id	 hxc_time_building_blocks.resource_id%TYPE;
    l_tc_url             varchar2(1000);
BEGIN

	g_debug := hr_utility.debug_enabled;

        l_tc_bb_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_BLD_BLK_ID');

	if g_debug then
		l_proc := 'hxc_timekeeper_wf_pkg.PERSON_NOTIFY';
		hr_utility.trace('l_tc_bb_id='||l_tc_bb_id);
	end if;

        l_tc_bb_ovn := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_BLD_BLK_OVN');

	if g_debug then
		hr_utility.trace('l_tc_bb_ovn='||l_tc_bb_ovn);
	end if;

	l_resource_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'RESOURCE_ID');

	if g_debug then
		hr_utility.trace('l_resource_id='||l_resource_id);
	end if;

	l_start_date  := wf_engine.GetItemAttrDate(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'TC_START');

	if g_debug then
		hr_utility.trace('l_start_date='||to_char(l_start_date));
	end if;

	l_stop_date  := wf_engine.GetItemAttrDate(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'TC_STOP');

	if g_debug then
		hr_utility.trace('l_stop_date='||to_char(l_stop_date));
	end if;

	l_ntf_type  := wf_engine.GetItemAttrText(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'APR_NOTIFY_TYPE');

	if g_debug then
		hr_utility.trace('l_ntf_type='||l_ntf_type);
	end if;

	l_timekeeper_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TIMEKEEPER_ID');

	if g_debug then
		hr_utility.trace('l_timekeeper_id='||l_timekeeper_id);
	end if;

	wf_engine.SetItemAttrNumber(
				  itemtype => p_itemtype,
				  itemkey  => p_itemkey,
				  aname    => 'APR_PERSON_ID',
				  avalue   => l_resource_id);

	if g_debug then
		hr_utility.trace('before login');
	end if;

	l_login := set_login(p_person_id  => l_timekeeper_id
			     ,p_tc_bb_id  => l_tc_bb_id
			     ,p_tc_bb_ovn => l_tc_bb_ovn );

	if g_debug then
		hr_utility.trace('l_login'||l_login);
	end if;

        --set role attribute
        wf_engine.SetItemAttrText(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_FROM_ROLE',
                                  avalue   => l_login);

	l_fyi_login := set_login(p_person_id  => l_resource_id
			     ,p_tc_bb_id  => l_tc_bb_id
			     ,p_tc_bb_ovn => l_tc_bb_ovn );

	if g_debug then
		hr_utility.trace('l_fyi_login='||l_fyi_login);
	end if;

	 wf_engine.SetItemAttrText(
				   itemtype => p_itemtype,
		                   itemkey  => p_itemkey,
		                   aname    => 'TC_OWNER',
		                   avalue   => get_name(l_resource_id,l_start_date)
			         );

	 wf_engine.SetItemAttrText(
				   itemtype => p_itemtype,
		                   itemkey  => p_itemkey,
		                   aname    => 'TC_TIMEKEEPER',
		                   avalue   => get_name(l_timekeeper_id,l_start_date)
			         );

	wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_OWNER_SS_LOGIN',
                                  avalue   => l_fyi_login);

        wf_engine.SetItemAttrText(
                              itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APR_SS_LOGIN',
                              avalue   => l_fyi_login);

	fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
        fnd_message.set_token('START_DATE',to_char(l_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
        fnd_message.set_token('END_DATE',to_char(l_stop_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

        l_title := fnd_message.get();

	if g_debug then
		hr_utility.trace('l_title='||substr(l_title,1,20));
	end if;

	wf_engine.SetItemAttrText(
	                              itemtype => p_itemtype,
	                              itemkey  => p_itemkey,
	                              aname    => 'TITLE',
	                              avalue   => l_title);

        l_otl_appr_id := l_tc_bb_id||'#'||p_itemkey;

	if g_debug then
		hr_utility.trace('l_otl_appr_id='||l_otl_appr_id);
	end if;

        wf_engine.SetItemAttrText(
	                              itemtype => p_itemtype,
	                              itemkey  => p_itemkey,
	                              aname    => 'OTL_APPR_ID',
	                              avalue   => l_otl_appr_id);
	set_timecard_hours(
                p_itemtype => p_itemtype,
                p_itemkey  => p_itemkey,
		p_tc_bb_id  => l_tc_bb_id ,
		p_tc_bb_ovn => l_tc_bb_ovn   );

	p_result :='COMPLETE:'||upper(l_ntf_type);

END PERSON_NOTIFY;

-------------------------------------------------------------------
-- Supervisor  Notification
-------------------------------------------------------------------

PROCEDURE SUPERVISOR_NOTIFY(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
IS

     cursor c_updated_by
         (p_tc_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
         ,p_tc_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
         ) is
  select u.user_name
    from fnd_user u, hxc_time_building_blocks tbb
   where tbb.time_building_block_id = p_tc_id
     and tbb.object_version_number = p_tc_ovn
     and tbb.last_updated_by = u.user_id;

    l_resource_id	 hxc_time_building_blocks.resource_id%TYPE;
    l_login              fnd_user.user_name%type;
    l_start_date	 DATE;
    l_stop_date		 DATE;
    l_supervisor	 hxc_time_building_blocks.resource_id%TYPE;
    l_tc_bb_id           hxc_time_building_blocks.time_building_block_id%type;
    l_tc_bb_ovn          hxc_time_building_blocks.time_building_block_id%type;
    l_ntf_type		 VARCHAR2(150);
    l_proc constant      varchar2(61) :='hxc_timekeeper_wf_pkg.SUPERVISOR_NOTIFY';
    l_title		 VARCHAR2(2000);
    l_otl_appr_id	 VARCHAR2(2000);
    l_timekeeper_id	 hxc_time_building_blocks.resource_id%TYPE;
    l_total_hours        number;
    l_premium_hours      number;
    l_non_worked_hours   number;
    l_description        varchar2(100);


BEGIN

        l_tc_bb_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_BLD_BLK_ID');

        l_tc_bb_ovn := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TC_BLD_BLK_OVN');

	l_resource_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'RESOURCE_ID');

	l_start_date  := wf_engine.GetItemAttrDate(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'TC_START');
	l_stop_date  := wf_engine.GetItemAttrDate(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'TC_STOP');

	l_timekeeper_id := wf_engine.GetItemAttrNumber(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'TIMEKEEPER_ID');

	l_ntf_type  := wf_engine.GetItemAttrText(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'APR_NOTIFY_TYPE');

	l_login := set_login(p_person_id => l_timekeeper_id
			    ,p_tc_bb_id  => l_tc_bb_id
			    ,p_tc_bb_ovn => l_tc_bb_ovn);

	 wf_engine.SetItemAttrText(
				   itemtype => p_itemtype,
		                   itemkey  => p_itemkey,
		                   aname    => 'TC_TIMEKEEPER',
		                   avalue   => get_name(l_timekeeper_id,l_start_date)
			         );

	        --set role attribute
        wf_engine.SetItemAttrText(
                                  itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_FROM_ROLE',
                                  avalue   => l_login);

	l_login := set_login(p_person_id => l_resource_id
			    ,p_tc_bb_id  => l_tc_bb_id
			    ,p_tc_bb_ovn => l_tc_bb_ovn);

        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                  itemkey  => p_itemkey,
                                  aname    => 'TC_OWNER_SS_LOGIN',
                                  avalue   => l_login);

	 wf_engine.SetItemAttrText(
				   itemtype => p_itemtype,
		                   itemkey  => p_itemkey,
		                   aname    => 'TC_OWNER',
		                   avalue   => get_name(l_resource_id,l_start_date)
			         );

	l_supervisor := get_supervisor(l_resource_id,l_start_date);


	wf_engine.SetItemAttrNumber(
				  itemtype => p_itemtype,
				  itemkey  => p_itemkey,
				  aname    => 'APR_PERSON_ID',
				  avalue   => l_supervisor);

	l_login := set_login(p_person_id => l_supervisor
			    ,p_tc_bb_id  => l_tc_bb_id
			    ,p_tc_bb_ovn => l_tc_bb_ovn);

        wf_engine.SetItemAttrText(
                              itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APR_SS_LOGIN',
                              avalue   => l_login);
	fnd_message.set_name('HXC','HXC_APPR_WF_TITLE');
        fnd_message.set_token('START_DATE',to_char(l_start_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
        fnd_message.set_token('END_DATE',to_char(l_stop_date,fnd_profile.value('ICX_DATE_FORMAT_MASK')));

        l_title := fnd_message.get();

	wf_engine.SetItemAttrText(
	                              itemtype => p_itemtype,
	                              itemkey  => p_itemkey,
	                              aname    => 'TITLE',
	                              avalue   => l_title);

        l_otl_appr_id := l_tc_bb_id||'#'||p_itemkey;

        wf_engine.SetItemAttrText(
	                              itemtype => p_itemtype,
	                              itemkey  => p_itemkey,
	                              aname    => 'OTL_APPR_ID',
	                              avalue   => l_otl_appr_id);
	set_timecard_hours(
                p_itemtype => p_itemtype,
                p_itemkey  => p_itemkey,
		p_tc_bb_id  => l_tc_bb_id ,
		p_tc_bb_ovn => l_tc_bb_ovn   );


	p_result :='COMPLETE:'||UPPER(l_ntf_type);

END SUPERVISOR_NOTIFY;

-------------------------------------------------------------------
-- Set the Approval Status
-------------------------------------------------------------------
PROCEDURE capture_approved_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2) IS

l_resource_id NUMBER;
l_name VARCHAR2(250);
l_display_name VARCHAR2(250);


BEGIN

        wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => 'APPROVED');

        p_result := 'COMPLETE';
END capture_approved_status;

-------------------------------------------------------------------
-- Set the Rejected Status
-------------------------------------------------------------------

PROCEDURE capture_rejected_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2) IS

l_resource_id NUMBER;
l_name VARCHAR2(250);
l_display_name VARCHAR2(250);

BEGIN

         wf_engine.SetItemAttrText(itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'APPROVAL_STATUS',
                              avalue   => 'REJECTED');

 p_result := 'COMPLETE';
END capture_rejected_status;

-------------------------------------------------------------------
-- Attach proper messages based on responses to TK
-------------------------------------------------------------------
PROCEDURE update_tk_ntf_result(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2) IS

cursor c_transaction_id
(p_tbb_id  in number,
 p_tbb_ovn in number) is
 select transaction_id
 from  hxc_transaction_details
 where time_building_block_id = p_tbb_id
 and   object_version_number  = p_tbb_ovn;

 l_tx_id		NUMBER := NULL;
 l_tc_resource_id     number;
 l_period_start_date  date;
 l_period_end_date    date;
 l_approval_status    hxc_time_building_blocks.approval_status%type;
 l_approver_comment   hxc_time_building_blocks.comment_text%TYPE;
 l_tbb_id    hxc_time_building_blocks.time_building_block_id%type;
 l_tbb_ovn   hxc_time_building_blocks.time_building_block_id%type;
 l_approver_type  VARCHAR2(250);
 l_message_name   VARCHAR2(250);
 l_error_id NUMBER;
 l_ovn NUMBER;

cursor c_error_id
(p_tbb_id  in number,
 p_tbb_ovn in number) is
 select *
 from  hxc_errors
 where time_building_block_id = p_tbb_id
 and   time_building_block_ovn  = p_tbb_ovn
 and   message_name in ('HXC_WF_TK_WORKER_NO_RESPOND','HXC_WF_TK_SUPER_NO_RESPOND')
 and   (date_to=hr_general.end_of_time OR date_to is NULL);

BEGIN

  g_debug := hr_utility.debug_enabled;

  l_tc_resource_id := wf_engine.GetItemAttrNumber(
                                        itemtype => p_itemtype,
                                        itemkey  => p_itemkey  ,
                                        aname    => 'RESOURCE_ID');

  l_period_start_date := wf_engine.GetItemAttrDate(
                                        itemtype => p_itemtype,
                                        itemkey  => p_itemkey  ,
                                        aname    => 'TC_START');

  l_period_end_date := wf_engine.GetItemAttrDate(
                                        itemtype => p_itemtype,
                                        itemkey  => p_itemkey  ,
                                        aname    => 'TC_STOP');

  l_tbb_id := wf_engine.GetItemAttrNumber(
		                        itemtype  => p_itemtype,
                                        itemkey   => p_itemkey,
                                        aname     => 'TC_BLD_BLK_ID');

  l_tbb_ovn := wf_engine.GetItemAttrNumber(
                                        itemtype  => p_itemtype,
                                        itemkey   => p_itemkey,
                                        aname     => 'TC_BLD_BLK_OVN');

  l_approval_status := wf_engine.GetItemAttrText(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey  ,
                                   aname    => 'APPROVAL_STATUS');

  l_approver_comment := wf_engine.GetItemAttrText(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APR_REJ_REASON');

  l_approver_type := wf_engine.GetItemAttrText(
                                    itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'APR_NOTIFY_TO');


   OPEN   c_transaction_id(l_tbb_id,l_tbb_ovn);
   FETCH  c_transaction_id INTO l_tx_id;
   CLOSE  c_transaction_id;

   IF (l_tx_id is null) THEN
       l_tx_id := -1;
   END IF;

   IF    l_approver_type ='WORKER' AND upper(l_approval_status) = 'APPROVED' THEN
         l_message_name := 'HXC_WF_TK_WORKER_OK';
   ELSIF l_approver_type ='WORKER' AND upper(l_approval_status) = 'REJECTED' THEN
         l_message_name := 'HXC_WF_TK_WORKER_NOT_OK';
   ELSIF l_approver_type ='SUPERVISOR' AND upper(l_approval_status) = 'APPROVED' THEN
         l_message_name := 'HXC_WF_TK_SUPER_OK';
   ELSIF l_approver_type ='SUPERVISOR' AND upper(l_approval_status) = 'REJECTED' THEN
         l_message_name := 'HXC_WF_TK_SUPER_NOT_OK';
   END IF;

-- can cel the error message associated
	For error_rec in c_error_id(l_tbb_id,l_tbb_ovn) LOOP
	 hxc_err_upd.upd
	  (p_error_id                     => error_rec.error_id
	  ,p_object_version_number        => error_rec.object_version_number
	  ,p_date_from                    => error_rec.date_from
	  ,p_date_to                      => sysdate-1
	  );
	END LOOP;

  hxc_err_ins.ins
	  (p_transaction_detail_id         => l_tx_id
	  ,p_time_building_block_id        => l_tbb_id
	  ,p_time_building_block_ovn       => l_tbb_ovn
          ,p_time_attribute_id             => NULL
          ,p_time_attribute_ovn            => NULL
          ,p_message_name                  => l_message_name
          ,p_message_level                 => 'BUSINESS_MESSAGE'
          ,p_message_field                 => NULL
          ,p_message_tokens                => NULL
          ,p_application_short_name        => 'HXC'
	  ,p_error_id                      => l_error_id
	  ,p_object_version_number	   => l_ovn
          ,p_date_from			   => sysdate
	  ,p_date_to			   => hr_general.end_of_time
	  );

  IF upper(l_approval_status) = 'APPROVED' THEN
    p_result := 'COMPLETE:APPROVED';
  ELSIF upper(l_approval_status) = 'REJECTED' THEN
    p_result := 'COMPLETE:REJECTED';
  END IF;

  return;

EXCEPTION
  WHEN OTHERS THEN
    --
    if g_debug then
    	hr_utility.trace(sqlerrm);
    end if;
    IF sqlerrm like '%HXC_TIME_BLD_BLK_NOT_LATEST%' THEN
       RETURN;
    END IF;
    wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.update_appl_period',
                    p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
    raise;
  p_result := '';
  return;
--
--
END UPDATE_TK_NTF_RESULT;

end hxc_timekeeper_wf_pkg;

/
