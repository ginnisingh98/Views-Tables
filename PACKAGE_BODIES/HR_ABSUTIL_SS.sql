--------------------------------------------------------
--  DDL for Package Body HR_ABSUTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ABSUTIL_SS" AS
/* $Header: hrabsutlss.pkb 120.7.12010000.4 2010/03/31 09:51:25 ckondapi ship $ */

-- Package Variables
--
-- Package Variables
--
g_package  constant varchar2(14) := 'HR_ABSUTIL_SS.';
g_debug boolean ;


function getStartDate(p_transaction_id in number,
                            p_absence_attendance_id in number) return date

IS
c_proc  constant varchar2(30) := 'getStartDate';
lv_startDate hr_api_transaction_steps.Information1%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

    if(p_transaction_id is not null) then
      begin
      select nvl(Information1,Information3)
      into lv_startDate
      from hr_api_transaction_steps
      where transaction_id=p_transaction_id;

      exception
      when others then
        null;
        lv_startDate:=null;
      end;
    end if;
    if(lv_startDate is not null) then
      return fnd_date.canonical_to_date(lv_startDate);
    else
      return null;
    end if;
  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
--    raise;
   return null;
end getStartDate;

function getEndDate(p_transaction_id in number,
                            p_absence_attendance_id in number) return date

IS
c_proc  constant varchar2(30) := 'getEndDate';
lv_EndDate hr_api_transaction_steps.Information1%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
    if(p_transaction_id is not null) then
      begin
      select nvl(Information2,Information4)
      into lv_EndDate
      from hr_api_transaction_steps
      where transaction_id=p_transaction_id;

      exception
      when others then
        null;
        lv_EndDate:=null;
      end;
    end if;
     if(lv_EndDate is not null) then
       return fnd_date.canonical_to_date(lv_EndDate);
     else
       return null;
     end if;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
   -- raise;
   return null;
end getEndDate;

function getAbsenceType(p_transaction_id in number,
                            p_absence_attendance_id in number) return varchar2

IS
c_proc  constant varchar2(30) := 'getAbsenceType';
lv_AbsenceTypeId PER_ABSENCE_ATTENDANCE_TYPES.absence_attendance_type_id%type;
lv_AbsenceType   PER_ABSENCE_ATTENDANCE_TYPES.name%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
--  hr_general.decode_lookup('ABSENCE_CATEGORY',hats.Information4)
    if(p_transaction_id is not null) then
      begin
      select Information5
      into lv_AbsenceTypeId
      from hr_api_transaction_steps
      where transaction_id=p_transaction_id;

      exception
      when others then
        null;
        lv_AbsenceTypeId:=null;
      end;
     if(lv_AbsenceTypeId is not null) then
       begin
        select name
        into lv_AbsenceType
        from PER_ABS_ATTENDANCE_TYPES_TL
        where ABSENCE_ATTENDANCE_TYPE_ID=lv_AbsenceTypeId
            and language = userenv('LANG');
       exception
      when others then
          lv_AbsenceType:=null;
       end;
     end if;
    end if;

    return lv_AbsenceType;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getAbsenceType;



function getAbsenceCategory(p_transaction_id in number,
                            p_absence_attendance_id in number) return varchar2

IS
c_proc  constant varchar2(30) := 'getAbsenceCategory';
lv_AbsenceCategory hr_api_transaction_steps.Information6%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

  /*and paat.absence_attendance_type_id =FND_NUMBER.canonical_to_number(nvl(hats.Information3,'0'))
      and fcl.lookup_type(+) = 'ABSENCE_CATEGORY'
      and paat.absence_category = fcl.lookup_code(+)
      and ((hr_api.return_legislation_code(paat.business_group_id) = 'GB'
         and paat.absence_category not in
('M','GB_PAT_ADO','GB_PAT_BIRTH','GB_ADO'))
         or
        (hr_api.return_legislation_code(paat.business_group_id) <> 'GB'
         and paat.absence_category not in
('GB_PAT_ADO','GB_PAT_BIRTH','GB_ADO')))*/

    if(p_transaction_id is not null) then
      begin
        select Information6
        into lv_AbsenceCategory
        from hr_api_transaction_steps
        where transaction_id=p_transaction_id;
      exception
      when others then
        lv_AbsenceCategory:=null;
      end;
    end if;
 return lv_AbsenceCategory;
  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getAbsenceCategory;

function getAbsenceHoursDuration(p_transaction_id in number,
                            p_absence_attendance_id in number) return number

IS
c_proc  constant varchar2(30) := 'getAbsenceHoursDuration';
lv_AbsenceHoursDuration hr_api_transaction_steps.Information7%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
    if(p_transaction_id is not null) then
      begin
        select Information7
        into lv_AbsenceHoursDuration
        from hr_api_transaction_steps
        where transaction_id=p_transaction_id;
      exception
      when others then
        lv_AbsenceHoursDuration:=null;
      end;
    end if;
 -- Fix for bug 7712861
 return fnd_number.canonical_to_number(nvl(lv_AbsenceHoursDuration,0));

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getAbsenceHoursDuration;


function getAbsenceDaysDuration(p_transaction_id in number,
                            p_absence_attendance_id in number) return number

IS
c_proc  constant varchar2(30) := 'getAbsenceDaysDuration';
lv_AbsenceDaysDuration hr_api_transaction_steps.Information8%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
     if(p_transaction_id is not null) then
      begin
        select Information8
        into lv_AbsenceDaysDuration
        from hr_api_transaction_steps
        where transaction_id=p_transaction_id;
      exception
      when others then
        lv_AbsenceDaysDuration:=null;
      end;
    end if;
 return lv_AbsenceDaysDuration;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getAbsenceDaysDuration;



function getApprovalStatus(p_transaction_id in number,
                           p_absence_attendance_id in number) return varchar2

IS
c_proc  constant varchar2(30) := 'getApprovalStatus';
lv_approvalStatus fnd_lookup_values.meaning%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
 /*decode(hat.status,'RI',hr_general.decode_lookup('PQH_SS_TRANSACTION_STATUS','C'),
              'RO',hr_general.decode_lookup('PQH_SS_TRANSACTION_STATUS','C'),
                   hrl.meaning)*/
    if(p_transaction_id is not null) then
      begin
        select    hr_general.decode_lookup('PQH_SS_TRANSACTION_STATUS',
           decode(status,'RI','C',
                      'RIS','S',
                      'RO','Y',
                      'ROS','Y',
                      'YS','Y',
                      status))
        into lv_approvalStatus
        from hr_api_transactions
        where transaction_id=p_transaction_id;
      exception
      when others then
        lv_approvalStatus:=null;
      end;
    end if;
 return lv_approvalStatus;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getApprovalStatus;


function getApprovalStatusCode(p_transaction_id in number,
                           p_absence_attendance_id in number) return varchar2

IS
c_proc  constant varchar2(30) := 'getApprovalStatusCode';
lv_approvalStatusCode varchar2(30);
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
 /*decode(hat.status,'RI',hr_general.decode_lookup('PQH_SS_TRANSACTION_STATUS','C'),
              'RO',hr_general.decode_lookup('PQH_SS_TRANSACTION_STATUS','C'),
                   hrl.meaning)*/
    if(p_transaction_id is not null) then
      begin
        select  decode(status,'RI','C',
                      'RIS','S',
                      'RO','Y',
                      'ROS','Y',
                      'YS','Y',
                      status)
        into lv_approvalStatusCode
        from hr_api_transactions
        where transaction_id=p_transaction_id;

      exception
      when others then
        lv_approvalStatusCode:=null;
      end;
    end if;
 return lv_approvalStatusCode;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getApprovalStatusCode;


function getAbsenceStatus(p_transaction_id in number,
                          p_absence_attendance_id in number) return varchar2

IS
c_proc  constant varchar2(30) := 'getAbsenceStatus';
lv_AbsenceStatus hr_api_transaction_steps.Information9%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
    if(p_transaction_id is not null) then
      begin
        select (SELECT meaning
                 from fnd_lookup_values
                 where lookup_type ='ABSENCE_STATUS'
                 and   fnd_lookup_values.lookup_code=Information9
                 and language = userenv('LANG')
                )
        into lv_AbsenceStatus
        from hr_api_transaction_steps
        where transaction_id=p_transaction_id;
      exception
      when others then
        lv_AbsenceStatus:=null;
      end;
    end if;
 return lv_AbsenceStatus;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getAbsenceStatus;

function isUpdateAllowed(p_transaction_id in number,
                         p_absence_attendance_id in number,
                         p_transaction_status in varchar2) return varchar2

IS
c_proc  constant varchar2(30) := 'isUpdateAllowed';
lv_UpdateAllowed varchar2(30);
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
 /*
 decode (hat.status,'W', 'HrUpdateEnabled',
                           'S','HrUpdateEnabled',
                           'RI','HrUpdateEnabled',
                'HrUpdateDisabled')
*/
   -- need to revisit with the common code for handling update
   -- based on the current transaction owner

    -- for now this will only allow for transaction owner to update

     if(p_transaction_id is not null) then
    if(hr_transaction_swi.istxnowner(p_transaction_id,fnd_global.employee_id)
       and p_transaction_status in ('W','S','RI','RIS')) then
      lv_UpdateAllowed := 'HrUpdateEnabled';
    else
      lv_UpdateAllowed := 'HrUpdateDisabled';
    end if;
  end if;

  return lv_UpdateAllowed;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end isUpdateAllowed;

function isConfirmAllowed(p_transaction_id in number,
                            p_absence_attendance_id in number) return varchar2

IS
c_proc  constant varchar2(30) := 'isConfirmAllowed';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

   return  'HrConfirmDisabled';

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end isConfirmAllowed;


function isCancelAllowed(p_transaction_id in number,
                         p_absence_attendance_id in number,
                         p_transaction_status in varchar2) return varchar2

IS
c_proc  constant varchar2(30) := 'isCancelAllowed';
lv_CancelAllowed varchar2(30);
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
  /*decode(hat.status,'W','HrCancelEnabled',
                          'S','HrCancelEnabled',
                          'RI','HrCancelEnabled',
               'HrCancelDisabled')*/
  if(p_transaction_id is not null) then
    if(hr_transaction_swi.istxnowner(p_transaction_id,fnd_global.employee_id)
       and p_transaction_status in ('W','S','RI','RIS')) then
      lv_CancelAllowed := 'HrCancelEnabled';
    else
      lv_CancelAllowed := 'HrCancelDisabled';
    end if;
  end if;

  return lv_CancelAllowed;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end isCancelAllowed;

function hasSupportingDocuments(p_transaction_id in number,
                                p_absence_attendance_id in number) return varchar2

IS
c_proc  constant varchar2(30) := 'hasSupportingDocuments';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
lv_entity_name constant varchar2(50) := 'PER_ABSENCE_ATTENDANCES';
lv_pkey1 fnd_attached_documents.pk1_value%type;
l_exists VARCHAR2(1);

begin
   g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

   if(p_transaction_id is not null) then
     lv_pkey1 :=p_absence_attendance_id||'_'||p_transaction_id;
   else
     lv_pkey1 :=p_absence_attendance_id;
   end if;

   begin
     SELECT 'Y'
     INTO l_exists
     from fnd_attached_documents
     where entity_name=lv_entity_name
     and pk1_value=lv_pkey1
     AND ROWNUM = 1;
   exception
   when no_data_found then
      l_exists := 'N';
   end;

    IF (l_exists<>'Y') THEN
     return('N');
    ELSE
     return('Y');
    END IF;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end hasSupportingDocuments;


procedure getAbsenceNotificationDetails(p_transaction_id in number
                                       ,p_notification_subject out nocopy varchar2)


IS
c_proc  constant varchar2(30) := 'getAbsenceNotificationDetails';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
lv_status hr_api_transactions.status%type;
ln_notification_id wf_notifications.notification_id%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

   begin
     select status,item_type,item_key
     into lv_status,lv_item_type,lv_item_key
     from hr_api_transactions
     where transaction_id=p_transaction_id;
    exception
    when others then
       null;
   end;

   if(lv_status in ('S','RIS'))then
       begin
            select item_type, item_key
            into lv_item_type,lv_item_key
            from wf_items
            where user_key=p_transaction_id
            and rownum<2;
         exception
         when no_data_found then
           null;
         end;

    end if;



      -- get the ntf id
      begin
         select notification_id
         into ln_notification_id
         FROM   WF_ITEM_ACTIVITY_STATUSES IAS
         WHERE  ias.item_type          = lv_item_type
         and    ias.item_key           = lv_item_key
         and    ias.activity_status    = 'NOTIFIED'
         and    ias.notification_id is not null
         and rownum<=1;
      exception
      when others then
        null;
      end;

      if(ln_notification_id is not null) then
         p_notification_subject:= wf_notification.getsubject(ln_notification_id);
      end if;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getAbsenceNotificationDetails;

function getAbsDurDays(
  p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2)
return number
is
c_proc              constant varchar2(30) := 'getAbsDurDays';
p_absence_days               number;
p_absence_hours              number;
p_use_formula                   number;
p_min_max_failure             varchar2(1);
p_warning_or_error           varchar2(1);
p_page_error_msg             fnd_new_messages.message_text%TYPE;


begin

g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

hr_loa_ss.calculate_absence_duration
 (p_absence_attendance_type_id
 ,p_business_group_id
 ,p_effective_date
 ,p_person_id
 ,p_date_start
 ,p_date_end
 ,p_time_start
 ,p_time_end
 ,p_absence_days
 ,p_absence_hours
 ,p_use_formula
 ,p_min_max_failure
 ,p_warning_or_error
 ,p_page_error_msg    );


 return p_absence_days;


exception
 when others then
   raise;

end getAbsDurDays;


function getAbsDurHours(
p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2)
 return number
 is
c_proc              constant varchar2(30) := 'getAbsDurHours';
p_absence_days               number;
p_absence_hours              number;
p_use_formula                   number;
p_min_max_failure             varchar2(1);
p_warning_or_error           varchar2(1);
p_page_error_msg             fnd_new_messages.message_text%TYPE;

Begin
 g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

  hr_loa_ss.calculate_absence_duration
 (p_absence_attendance_type_id
 ,p_business_group_id
 ,p_effective_date
 ,p_person_id
 ,p_date_start
 ,p_date_end
 ,p_time_start
 ,p_time_end
 ,p_absence_days
 ,p_absence_hours
 ,p_use_formula
 ,p_min_max_failure
 ,p_warning_or_error
 ,p_page_error_msg    );


 return p_absence_hours;


exception
 when others then
   raise;

end getAbsDurHours;

function getAbsenceStatusValue(p_transaction_id in Varchar2) return varchar2

IS
c_proc  constant varchar2(30) := 'getAbsenceStatusValue';
lv_AbsenceStatus hr_api_transaction_steps.Information9%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
    if(p_transaction_id is not null) then
      begin
        select (SELECT meaning
                 from fnd_lookup_values
                 where lookup_type ='ABSENCE_STATUS'
                 and   fnd_lookup_values.lookup_code=Information9
                 and language = userenv('LANG')
                )
        into lv_AbsenceStatus
        from hr_api_transaction_steps
        where transaction_id=p_transaction_id;
      exception
      when others then
        lv_AbsenceStatus:=null;
      end;
    end if;
 return lv_AbsenceStatus;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
    raise;
end getAbsenceStatusValue;

procedure delete_transaction
(p_transaction_id in	   number)
is


lv_result varchar2(100);
lr_hr_api_transaction_rec hr_api_transactions%rowtype;
lr_wf_items_rec wf_items%rowtype := null;
l_user_key varchar2(50) := null;

begin

  if(p_transaction_id is not null) then
     begin
       select * into lr_hr_api_transaction_rec
       from hr_api_transactions
       where transaction_id=p_transaction_id;
     exception
     when others then
        raise;
     end;

    if(lr_hr_api_transaction_rec.item_type is not null and
       lr_hr_api_transaction_rec.item_key is not null) then

        hr_sflutil_ss.closesflnotifications(p_transaction_id
                                           ,lr_hr_api_transaction_rec.item_type
                                           ,lr_hr_api_transaction_rec.item_key);

        hr_transaction_ss.rollback_transaction(lr_hr_api_transaction_rec.item_type,
                                               lr_hr_api_transaction_rec.item_key,
                                               null,
                                               wf_engine.eng_run,
                                               lv_result);
        wf_engine.abortprocess(itemtype     => lr_hr_api_transaction_rec.item_type
                               ,itemkey     => lr_hr_api_transaction_rec.item_key
                               ,process     =>null
                               ,result      => wf_engine.eng_force
                               ,verify_lock => true
                               ,cascade     => true);
    else

hr_sflutil_ss.closesflnotifications(p_transaction_id,null,null);
hr_transaction_api.rollback_transaction
                 (p_transaction_id => p_transaction_id);

    end if;
  end if;

exception
when others then
  raise;
end delete_transaction;

procedure remove_absence_transaction(p_absence_attendance_id in number)
is

cursor c_trans_rec(p_absence_attendance_id number) is

select transaction_id from hr_api_transactions hat
where hat.transaction_ref_id = p_absence_attendance_id
and hat.transaction_ref_table = 'PER_ABSENCE_ATTENDANCES'
and hat.status not in ('AC','Y');

trans_record c_trans_rec%ROWTYPE;
begin

 OPEN c_trans_rec(p_absence_attendance_id);
   LOOP
      FETCH c_trans_rec into trans_record;
      EXIT WHEN c_trans_rec%NOTFOUND;

     delete_transaction(trans_record.transaction_id);

   END LOOP;
   CLOSE c_trans_rec;


exception

when others then
raise;

end remove_absence_transaction;

END HR_ABSUTIL_SS;

/
