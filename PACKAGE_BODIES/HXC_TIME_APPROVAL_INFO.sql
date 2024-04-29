--------------------------------------------------------
--  DDL for Package Body HXC_TIME_APPROVAL_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_APPROVAL_INFO" AS
/* $Header: hxctcapinfo.pkb 115.2 2004/07/05 02:36:47 dragarwa noship $ */

g_timecard_info timecard_info;
g_application_info application_info_table;

procedure clearCache is
begin

   g_timecard_info.timecard_id := null;
   g_timecard_info.approval_status := null;
   g_timecard_info.submission_date := null;
   g_timecard_info.audit_data_exists := null;
   g_timecard_info.recorded_hours := null;
   g_application_info.delete;

end clearCache;

procedure createApplicationCache
   (p_timecard_id in hxc_timecard_summary.timecard_id%type) is

cursor c_ap_cache_info
   (p_tc_id in hxc_tc_ap_links.timecard_id%type) is
  select aps.application_period_id,
         aps.approval_status,
	 aps.creation_date,
	 aps.notification_status,
	 aps.approver_id,
	 aps.time_recipient_id
    from hxc_tc_ap_links tcl,
	 hxc_app_period_summary aps
   where tcl.timecard_id = p_tc_id
     and tcl.application_period_id = aps.application_period_id;

l_dummy_name varchar2(360);

begin

   for app_rec in c_ap_cache_info(p_timecard_id) loop
      g_application_info(app_rec.application_period_id).time_recipient_id :=
	 app_rec.time_recipient_id;
      g_application_info(app_rec.application_period_id).approval_status :=
	 app_rec.approval_status;
      g_application_info(app_rec.application_period_id).creation_date :=
	 app_rec.creation_date;
      g_application_info(app_rec.application_period_id).notification_status :=
	 app_rec.notification_status;
      wf_directory.getusername
	 (p_orig_system => 'PER',
	  p_orig_system_id => app_rec.approver_id,
	  p_name => l_dummy_name,
	  p_display_name => g_application_info(app_rec.application_period_id).approver
	  );
   end loop;

end createApplicationCache;

function findApprovalDate
   (p_timecard_id in hxc_timecard_summary.timecard_id%type)
   return hxc_timecard_summary.submission_date%type is

   cursor c_approval_date
      (p_timecard_id in hxc_timecard_summary.timecard_id%type) is
   select max(aps.creation_date)
     from hxc_tc_ap_links tcl, hxc_app_period_summary aps
    where tcl.timecard_id = p_timecard_id
      and aps.approval_status = 'APPROVED'
      and aps.application_period_id = tcl.application_period_id;

 l_approval_date date;

begin
   open c_approval_date(p_timecard_id);
   fetch c_approval_date into l_approval_date;
   if(c_approval_date%notfound) then
      l_approval_date := null;
   end if;
   close c_approval_date;

   return l_approval_date;
end findApprovalDate;

procedure createTimecardCache
   (p_timecard_id in hxc_timecard_summary.timecard_id%type) is

cursor c_tc_cache_info
      (p_tc_id in hxc_timecard_summary.timecard_id%type) is
  select ts.timecard_id,
         ts.approval_status,
	 ts.recorded_hours,
	 ts.has_reasons,
	 ts.submission_date
    from hxc_timecard_summary ts
   where ts.timecard_id = p_tc_id;

begin

   open c_tc_cache_info(p_timecard_id);
   fetch c_tc_cache_info into
             g_timecard_info.timecard_id,
             g_timecard_info.approval_status,
             g_timecard_info.recorded_hours,
             g_timecard_info.audit_data_exists,
             g_timecard_info.submission_date;
   close c_tc_cache_info;
   if(g_timecard_info.approval_status = 'APPROVED') then
      g_timecard_info.approval_date :=
	 findApprovalDate(p_timecard_id);
   else
      g_timecard_info.approval_date := null;
   end if;
end createTimecardCache;

function findTimeCategoryId
   (p_time_category_name in hxc_time_categories.time_category_name%type)
   return hxc_time_categories.time_category_id%type is

   cursor c_tc_id
      (p_name in hxc_time_categories.time_category_name%type) is
   select time_category_id
     from hxc_time_categories
    where time_category_name = p_name;

 l_tc_id hxc_time_categories.time_category_id%type;

 begin

    if(p_time_category_name is not null) then
       open c_tc_id(p_time_category_name);
       fetch c_tc_id into l_tc_id;
       if(c_tc_id%notfound) then
	  close c_tc_id;
	  fnd_message.set_name('HXC','HXC_NO_TIME_CATEGORY');
	  fnd_message.set_token('NAME',p_time_category_name);
	  fnd_message.raise_error;
       else
	  close c_tc_id;
       end if;
    else
       l_tc_id := null;
    end if;

    return l_tc_id;

 end findTimeCategoryId;

function findTimeRecipientId
   (p_time_recipient_name in hxc_time_recipients.name%type)
return hxc_time_recipients.time_recipient_id%type is

   cursor c_find_tr_id
      (p_name in hxc_time_recipients.name%type) is
   select time_recipient_id
     from hxc_time_recipients
    where name = p_name;

 l_tr_id hxc_time_recipients.time_recipient_id%type;

begin

   open c_find_tr_id(p_time_recipient_name);
   fetch c_find_tr_id into l_tr_id;
   if(c_find_tr_id%notfound) then
      close c_find_tr_id;
      fnd_message.set_name('HXC','HXC_NO_TIME_RECIPIENT');
      fnd_message.set_token('NAME',p_time_recipient_name);
      fnd_message.raise_error;
   else
      close c_find_tr_id;
   end if;
   return l_tr_id;

end findTimeRecipientId;

function findAppPeriodId
   (p_resource_id in hxc_app_period_summary.resource_id%type,
    p_start_time in hxc_app_period_summary.start_time%type,
    p_stop_time in hxc_app_period_summary.stop_time%type,
    p_application_name in hxc_time_recipients.name%type,
    p_time_category_name in hxc_time_categories.time_category_name%type)
   return hxc_app_period_summary.application_period_id%type is

   cursor c_find_app_period
   (p_resource_id in hxc_app_period_summary.resource_id%type,
    p_start_time in hxc_app_period_summary.start_time%type,
    p_stop_time in hxc_app_period_summary.stop_time%type,
    p_time_recipient_id in hxc_app_period_summary.time_recipient_id%type,
    p_time_category_id in hxc_app_period_summary.time_category_id%type) is
      select application_period_id
	from hxc_app_period_summary
       where resource_id = p_resource_id
	 and trunc(start_time) = trunc(p_start_time)
	 and trunc(stop_time) = trunc(p_stop_time)
	 and time_recipient_id = p_time_recipient_id
	 and nvl(time_category_id,-1) = nvl(p_time_category_id,-1);

   l_time_recipient_id hxc_time_recipients.time_recipient_id%type;
   l_time_category_id hxc_time_categories.time_category_id%type;
   l_application_period_id hxc_app_period_summary.application_period_id%type;

begin

   l_time_recipient_id := findTimeRecipientId(p_application_name);
   l_time_category_id := findTimeCategoryId(p_time_category_name);

   open c_find_app_period
          (p_resource_id,
	   p_start_time,
	   p_stop_time,
	   l_time_recipient_id,
	   l_time_category_id);
   fetch c_find_app_period into l_application_period_id;
   if(c_find_app_period%notfound) then
      close c_find_app_period;
      fnd_message.set_name('HXC','HXC_NO_APP_PERIOD');
      fnd_message.raise_error;
   else
      close c_find_app_period;
   end if;
   return l_application_period_id;

end findAppPeriodId;

function findTimecardId
   (p_application_period_id in hxc_app_period_summary.application_period_id%type)
   return hxc_timecard_summary.timecard_id%type is

   cursor c_find_timecard_id
      (p_app_period_id in hxc_app_period_summary.application_period_id%type) is
   select timecard_id
     from hxc_tc_ap_links
    where application_period_id = p_app_period_id;

 l_timecard_id hxc_timecard_summary.timecard_id%type;

begin

   open c_find_timecard_id(p_application_period_id);
   fetch c_find_timecard_id into l_timecard_id;
   if(c_find_timecard_id%notfound) then
      close c_find_timecard_id;
      fnd_message.set_name('HXC','HXC_NO_TIMECARD_ID');
      fnd_message.raise_error;
   else
      close c_find_timecard_id;
   end if;
   return l_timecard_id;

end findTimecardId;

function findTimecardId
   (p_resource_id in hxc_timecard_summary.resource_id%type,
    p_start_time in hxc_timecard_summary.start_time%type,
    p_stop_time in hxc_timecard_summary.stop_time%type)
   return hxc_timecard_summary.timecard_id%type is

   cursor c_find_timecard_id
   (p_resource_id in hxc_timecard_summary.resource_id%type,
    p_start_time in hxc_timecard_summary.start_time%type,
    p_stop_time in hxc_timecard_summary.stop_time%type) is
   select timecard_id
     from hxc_timecard_summary
    where resource_id = p_resource_id
      and trunc(start_time) = trunc(p_start_time)
      and trunc(stop_time) = trunc(p_stop_time);

 l_timecard_id hxc_timecard_summary.timecard_id%type;

 begin

    open c_find_timecard_id(p_resource_id,p_start_time,p_stop_time);
    fetch c_find_timecard_id into l_timecard_id;
    if(c_find_timecard_id%notfound) then
       close c_find_timecard_id;
       fnd_message.set_name('HXC','HXC_NO_TIMECARD_ID');
       fnd_message.raise_error;
    else
       close c_find_timecard_id;
    end if;
    return l_timecard_id;

end findTimecardId;


function verifyCache
   (p_timecard_id in hxc_timecard_summary.timecard_id%type)
   return boolean is

begin

   if(g_timecard_info.timecard_id = p_timecard_id) then
      return true;
   else
      return false;
   end if;

end verifyCache;

procedure verifyOrCreateCache
   (p_timecard_id in hxc_timecard_summary.timecard_id%type,
    p_application_period_id in hxc_app_period_summary.application_period_id%type) is

   l_timecard_id hxc_timecard_summary.timecard_id%type;

begin

   l_timecard_id := p_timecard_id;

   if((p_timecard_id is null) and (p_application_period_id is not null)) then
      l_timecard_id := findTimecardId(p_application_period_id);
   end if;

   if (NOT verifyCache(p_timecard_id)) then

      clearCache;
      createTimecardCache(p_timecard_id);
      if(p_application_period_id is not null) then
	 createApplicationCache(p_timecard_id);
      end if;

   end if;

end verifyOrCreateCache;

--
-- Public interfaces below
--

function get_timecard_approval_status
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.approval_status%type is

begin
   verifyOrCreateCache(p_timecard_id,null);
   return g_timecard_info.approval_status;
end get_timecard_approval_status;

function get_timecard_approval_status
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.approval_status%type is

begin
   verifyOrCreateCache
      (findTimecardId
       (p_resource_id,
	p_start_time,
	p_stop_time
	),
       null
       );
   return g_timecard_info.approval_status;
end get_timecard_approval_status;

function get_timecard_approval_date
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.submission_date%type is

begin
   verifyOrCreateCache(p_timecard_id,null);
   return g_timecard_info.approval_date;
end get_timecard_approval_date;

function get_timecard_approval_date
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.submission_date%type is

begin
   verifyOrCreateCache
      (findTimecardId
       (p_resource_id,
	p_start_time,
	p_stop_time
	),
       null
       );
   return g_timecard_info.approval_date;
end get_timecard_approval_date;

function get_timecard_recorded_hours
 (p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.recorded_hours%type is

begin
   verifyOrCreateCache(p_timecard_id,null);
   return g_timecard_info.recorded_hours;
end get_timecard_recorded_hours;

function get_timecard_recorded_hours
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.recorded_hours%type is

begin
   verifyOrCreateCache
      (findTimecardId
       (p_resource_id,
	p_start_time,
	p_stop_time
	),
       null
       );
   return g_timecard_info.recorded_hours;
end get_timecard_recorded_hours;

function get_timecard_audit_data_exists
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.has_reasons%type is

begin
   verifyOrCreateCache(p_timecard_id, null);
   return g_timecard_info.audit_data_exists;
end get_timecard_audit_data_exists;

function get_timecard_audit_data_exists
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.has_reasons%type is

begin
   verifyOrCreateCache
      (findTimecardId
       (p_resource_id,
	p_start_time,
	p_stop_time
	),
       null
       );
   return g_timecard_info.audit_data_exists;
end get_timecard_audit_data_exists;

function get_timecard_submission_date
(p_timecard_id in hxc_timecard_summary.timecard_id%type)
return hxc_timecard_summary.submission_date%type is

begin
   verifyOrCreateCache(p_timecard_id,null);
   return g_timecard_info.submission_date;
end get_timecard_submission_date;

function get_timecard_submission_date
(p_resource_id in hxc_timecard_summary.resource_id%type,
 p_start_time in hxc_timecard_summary.start_time%type,
 p_stop_time in hxc_timecard_summary.stop_time%type)
return hxc_timecard_summary.submission_date%type is

begin
   verifyOrCreateCache
      (findTimecardId
       (p_resource_id,
	p_start_time,
	p_stop_time
	),
       null
       );
   return g_timecard_info.submission_date;
end get_timecard_submission_date;

function get_app_approval_status
   (p_application_period_id in hxc_app_period_summary.application_period_id%type)
return hxc_app_period_summary.approval_status%type is

begin
   verifyOrCreateCache(findTimecardId(p_application_period_id),p_application_period_id);
   return g_application_info(p_application_period_id).approval_status;
end get_app_approval_status;

function get_app_approval_status
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type
   )
return hxc_app_period_summary.approval_status%type is

begin
   return get_app_approval_status(p_resource_id,p_start_time,p_stop_time,p_application_name,null);
end get_app_approval_status;

function get_app_approval_status
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type,
   p_time_category_name in hxc_time_categories.time_category_name%type
   )
return hxc_app_period_summary.approval_status%type is

   l_application_period_id hxc_app_period_summary.application_period_id%type;

begin
   l_application_period_id := findAppPeriodId
                                (p_resource_id,
				 p_start_time,
				 p_stop_time,
				 p_application_name,
				 p_time_category_name);
   verifyOrCreateCache(findTimecardId(l_application_period_id),l_application_period_id);
   return g_application_info(l_application_period_id).approval_status;
end get_app_approval_status;

function get_app_creation_date
  (p_application_period_id in hxc_app_period_summary.application_period_id%type)
return hxc_app_period_summary.creation_date%type is

begin
   verifyOrCreateCache(findTimecardId(p_application_period_id), p_application_period_id);
   return g_application_info(p_application_period_id).creation_date;
end get_app_creation_date;

function get_app_creation_date
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type
   )
return hxc_app_period_summary.creation_date%type is

begin
   return get_app_creation_date
      (p_resource_id,
       p_start_time,
       p_stop_time,
       p_application_name,
       null
       );
end get_app_creation_date;

function get_app_creation_date
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type,
   p_time_category_name in hxc_time_categories.time_category_name%type
   )
return hxc_app_period_summary.creation_date%type is
  l_application_period_id hxc_app_period_summary.application_period_id%type;
begin
   l_application_period_id := findAppPeriodId
                                (p_resource_id,
				 p_start_time,
				 p_stop_time,
				 p_application_name,
				 p_time_category_name);
   verifyOrCreateCache(findTimecardId(l_application_period_id),l_application_period_id);
   return g_application_info(l_application_period_id).creation_date;
end get_app_creation_date;

function get_app_approver
   (p_application_period_id in hxc_app_period_summary.application_period_id%type)
return varchar2 is
begin
   verifyOrCreateCache(findTimecardId(p_application_period_id),p_application_period_id);
   return g_application_info(p_application_period_id).approver;
end get_app_approver;

function get_app_approver
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type
   )
return varchar2 is

begin
   return get_app_approver
      (p_resource_id,
       p_start_time,
       p_stop_time,
       p_application_name,
       null
       );
end get_app_approver;

function get_app_approver
  (p_resource_id in hxc_app_period_summary.resource_id%type,
   p_start_time in hxc_app_period_summary.start_time%type,
   p_stop_time in hxc_app_period_summary.stop_time%type,
   p_application_name in hxc_time_recipients.name%type,
   p_time_category_name in hxc_time_categories.time_category_name%type
   )
return varchar2 is
  l_application_period_id hxc_app_period_summary.application_period_id%type;
begin
   l_application_period_id := findAppPeriodId
                                (p_resource_id,
				 p_start_time,
				 p_stop_time,
				 p_application_name,
				 p_time_category_name);
   verifyOrCreateCache(findTimecardId(l_application_period_id),l_application_period_id);
   return g_application_info(l_application_period_id).approver;
end get_app_approver;

END hxc_time_approval_info;

/
