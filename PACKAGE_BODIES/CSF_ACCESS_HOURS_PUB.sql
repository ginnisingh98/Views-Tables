--------------------------------------------------------
--  DDL for Package Body CSF_ACCESS_HOURS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_ACCESS_HOURS_PUB" as
/* $Header: CSFPACHB.pls 120.2.12010000.4 2010/04/28 10:34:59 ramchint ship $ */
-- Start of Comments
-- Package name     : CSF_ACCESS_HOURS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_ACCESS_HOUR_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'CSFPACHB.pls';
 -- ---------------------------------
  -- private global package variables
  -- ---------------------------------
  g_user_id  number;
  g_login_id number;
  -----------------------------------
  --private api's
  -----------------------------------
PROCEDURE LOCK_ACCESS_HOURS
  (       p_access_hour_id  number,
          p_API_VERSION NUMBER,
          p_init_msg_list varchar2 default null,
          p_object_version_number number,
          x_return_status            OUT NOCOPY            VARCHAR2,
          x_msg_data                 OUT NOCOPY            VARCHAR2,
          x_msg_count                OUT NOCOPY            NUMBER);

PROCEDURE CHECK_PARAMETERS(
	  p_CALLING_ROUTINE VARCHAR2 ,
	  p_TASK_ID NUMBER,
          p_ACCESS_HOUR_REQD VARCHAR2 default null,
          p_AFTER_HOURS_FLAG VARCHAR2 default null,
          p_MONDAY_FIRST_START DATE default TO_DATE(NULL),
          p_MONDAY_FIRST_END DATE default TO_DATE(NULL),
          p_TUESDAY_FIRST_START DATE default TO_DATE(NULL),
          p_TUESDAY_FIRST_END DATE default TO_DATE(NULL) ,
          p_WEDNESDAY_FIRST_START DATE default TO_DATE(NULL),
          p_WEDNESDAY_FIRST_END DATE default TO_DATE(NULL),
          p_THURSDAY_FIRST_START DATE default TO_DATE(NULL),
          p_THURSDAY_FIRST_END DATE default TO_DATE(NULL),
          p_FRIDAY_FIRST_START DATE default TO_DATE(NULL),
          p_FRIDAY_FIRST_END DATE default TO_DATE(NULL),
          p_SATURDAY_FIRST_START DATE default TO_DATE(NULL),
          p_SATURDAY_FIRST_END DATE default TO_DATE(NULL),
          p_SUNDAY_FIRST_START DATE default TO_DATE(NULL),
          p_SUNDAY_FIRST_END DATE default TO_DATE(NULL),
          p_MONDAY_SECOND_START DATE default TO_DATE(NULL) ,
          p_MONDAY_SECOND_END DATE default  TO_DATE(NULL),
          p_TUESDAY_SECOND_START DATE default TO_DATE(NULL),
          p_TUESDAY_SECOND_END DATE default TO_DATE(NULL) ,
          p_WEDNESDAY_SECOND_START DATE default TO_DATE(NULL),
          p_WEDNESDAY_SECOND_END DATE default TO_DATE(NULL),
          p_THURSDAY_SECOND_START DATE default TO_DATE(NULL),
          p_THURSDAY_SECOND_END DATE default TO_DATE(NULL),
          p_FRIDAY_SECOND_START DATE default TO_DATE(NULL),
          p_FRIDAY_SECOND_END DATE default TO_DATE(NULL),
          p_SATURDAY_SECOND_START DATE default TO_DATE(NULL),
          p_SATURDAY_SECOND_END DATE default TO_DATE(NULL),
          p_SUNDAY_SECOND_START DATE default TO_DATE(NULL),
          p_SUNDAY_SECOND_END DATE default TO_DATE(NULL),
          p_DESCRIPTION VARCHAR2 DEFAULT null,
          x_return_status            OUT NOCOPY            VARCHAR2,
	  x_msg_data                 OUT NOCOPY            VARCHAR2,
	  x_msg_count                OUT NOCOPY            NUMBER


);


PROCEDURE LOCK_ACCESS_HOURS
  ( p_access_hour_id in number,
          p_API_VERSION NUMBER,
          p_init_msg_list varchar2 default NULL,
  --     p_commit in     varchar2 default fnd_api.g_false,
   p_object_version_number in number,
    x_return_status            OUT NOCOPY            VARCHAR2,
    x_msg_data                 OUT NOCOPY            VARCHAR2,
    x_msg_count                OUT NOCOPY            NUMBER)


  IS

   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full constant varchar2(50) := 'CSF_ACCESS_HOURS_PUB.LOCK_ACCESS_HOURS';
   l_sta           varchar2(1);
l_cnt           number;
l_msg           varchar2(2000);
l_api_version CONSTANT Number := 1.0 ;


  BEGIN

SAVEPOINT lock_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_success;

IF NOT fnd_api.compatible_api_call (
l_api_version,
p_api_version,
l_api_name_full,
g_pkg_name
)
then
raise fnd_Api.g_exc_unexpected_error;
end if;

IF fnd_api.to_boolean( nvl(p_init_msg_list,fnd_api.g_false)) then
fnd_msg_pub.initialize;
end if;



If  p_ACCESS_HOUR_ID is NULL then
fnd_message.set_name ('CSF','CSF_ACCESS_INVALID_PARAMETER');--message required
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

   CSF_ACCESS_HOURS_PVT.LOCK_ACCESS_HOURS(

p_API_VERSION => 1.0,
p_INIT_MSG_LIST => 'F',
p_ACCESS_HOUR_ID =>p_ACCESS_HOUR_ID,
p_object_version_number=>p_OBJECT_VERSION_NUMBER,
x_return_status            => l_sta,
x_msg_count                => l_cnt,
x_msg_data                 => l_msg
);

If l_return_status = fnd_api.g_ret_sts_error then
raise fnd_api.g_exc_error;
end if;

If l_return_status = fnd_api.g_ret_sts_unexp_error then
raise fnd_Api.g_exc_unexpected_error;
end if;

fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION

WHEN  fnd_api.g_exc_error then
ROLLBACK TO lock_access_hours_pub;
x_return_status :=fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  fnd_api.g_exc_unexpected_error then
ROLLBACK TO lock_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  OTHERS then
ROLLBACK TO  lock_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);




  END LOCK_ACCESS_HOURS;

function get_task_status_flag (p_task_id number)  return varchar2
is
cursor c_task_status(p_task_id number) is
select
ASSIGNED_FLAG,
WORKING_FLAG ,
APPROVED_FLAG ,
COMPLETED_FLAG,
CANCELLED_FLAG,
REJECTED_FLAG,
ACCEPTED_FLAG,
ON_HOLD_FLAG ,
SCHEDULABLE_FLAG,
CLOSED_FLAG,
DELETE_ALLOWED_FLAG,
TASK_STATUS_FLAG ,
ASSIGNMENT_STATUS_FLAG,
SCHEDULED_START_DATE,
SCHEDULED_END_DATE,
START_DATE_TYPE,
END_DATE_TYPE,
ACTUAL_START_DATE,
ACTUAL_END_DATE
from
jtf_task_statuses_vl jtsv,jtf_tasks_b jtb
where
jtb.task_id=p_task_id
and
jtsv.task_status_id=jtb.task_status_id ;

l_ASSIGNED_FLAG			 varchar2(1);
l_WORKING_FLAG			 varchar2(1);
l_APPROVED_FLAG  		 varchar2(1);
l_CANCELLED_FLAG  		 varchar2(1);
l_COMPLETED_FLAG   		 varchar2(1);
l_REJECTED_FLAG      		 varchar2(1);
l_ACCEPTED_FLAG    		 varchar2(1);
l_ON_HOLD_FLAG    		 varchar2(1);
l_SCHEDULABLE_FLAG   		 varchar2(1);
l_CLOSED_FLAG                    varchar2(1);
l_DELETE_ALLOWED_FLAG  		 varchar2(1);
l_TASK_STATUS_FLAG  	  	 varchar2(1);
l_ASSIGNMENT_STATUS_FLAG   	 varchar2(1);
l_scheduled_start_date 	         date;
l_scheduled_end_date             date;
l_actual_start_date	         date;
l_actual_end_date                date;
l_start_date_type                varchar2(80);
l_end_date_type                  varchar2(80);

begin
open c_task_status(p_task_id);
fetch c_task_status into l_ASSIGNED_FLAG,l_WORKING_FLAG ,l_APPROVED_FLAG ,l_COMPLETED_FLAG,
l_CANCELLED_FLAG,l_REJECTED_FLAG,l_ACCEPTED_FLAG,l_ON_HOLD_FLAG ,l_SCHEDULABLE_FLAG,l_CLOSED_FLAG,
l_DELETE_ALLOWED_FLAG,l_TASK_STATUS_FLAG ,l_ASSIGNMENT_STATUS_FLAG ,l_scheduled_start_date,l_scheduled_end_date,l_start_date_type, l_end_date_type,l_actual_start_date,l_actual_end_date;
close c_task_status;

/*if l_actual_start_date is not null or l_actual_end_date is not null
    or l_working_flag ='Y' or l_rejected_flag='Y' or l_completed_flag='Y' or l_closed_flag='Y'
then
  return 'W';
elsif l_scheduled_start_date is NULL and l_scheduled_end_date is NULL and  (l_SCHEDULABLE_FLAG ='Y' OR l_ON_HOLD_FLAG='Y')
then
  return 'S'; -- for tasks not yet scheduled
elsif (l_SCHEDULABLE_FLAG ='Y'or l_ASSIGNED_FLAG = 'Y') and  l_scheduled_start_date is not NULL and l_scheduled_end_date is not NULL then
  return 'A'; --for Planned /Assigned task
end if;*/

if (l_CANCELLED_flag='Y' or l_closed_flag='Y') then
  return 'W'; --for closed/completed task
else
 return 'S';
end if;
return 'X';

end get_task_status_flag;

 PROCEDURE CHECK_PARAMETERS(
	  p_CALLING_ROUTINE VARCHAR2,
	  p_TASK_ID NUMBER,
          p_ACCESS_HOUR_REQD VARCHAR2 ,
          p_AFTER_HOURS_FLAG VARCHAR2,
          p_MONDAY_FIRST_START DATE ,
          p_MONDAY_FIRST_END DATE ,
          p_TUESDAY_FIRST_START DATE ,
          p_TUESDAY_FIRST_END DATE  ,
          p_WEDNESDAY_FIRST_START DATE ,
          p_WEDNESDAY_FIRST_END DATE ,
          p_THURSDAY_FIRST_START DATE ,
          p_THURSDAY_FIRST_END DATE ,
          p_FRIDAY_FIRST_START DATE ,
          p_FRIDAY_FIRST_END DATE ,
          p_SATURDAY_FIRST_START DATE ,
          p_SATURDAY_FIRST_END DATE ,
          p_SUNDAY_FIRST_START DATE ,
          p_SUNDAY_FIRST_END DATE,
          p_MONDAY_SECOND_START DATE  ,
          p_MONDAY_SECOND_END DATE ,
          p_TUESDAY_SECOND_START DATE ,
          p_TUESDAY_SECOND_END DATE  ,
          p_WEDNESDAY_SECOND_START DATE,
          p_WEDNESDAY_SECOND_END DATE ,
          p_THURSDAY_SECOND_START DATE,
          p_THURSDAY_SECOND_END DATE ,
          p_FRIDAY_SECOND_START DATE,
          p_FRIDAY_SECOND_END DATE,
          p_SATURDAY_SECOND_START DATE,
          p_SATURDAY_SECOND_END DATE ,
          p_SUNDAY_SECOND_START DATE,
          p_SUNDAY_SECOND_END DATE ,
          p_DESCRIPTION VARCHAR2,
          x_return_status            OUT NOCOPY            VARCHAR2,
	  x_msg_data                 OUT NOCOPY            VARCHAR2,
	  x_msg_count                OUT NOCOPY            NUMBER


)

          IS
l_task_status varchar2(1);

cursor c_existing_values(p_task_id number) is
select
ACCESSHOUR_REQUIRED,
AFTER_HOURS_FLAG,
MONDAY_FIRST_START,
MONDAY_FIRST_END,
MONDAY_SECOND_START,
MONDAY_SECOND_END,
TUESDAY_FIRST_START,
TUESDAY_FIRST_END,
TUESDAY_SECOND_START,
TUESDAY_SECOND_END,
WEDNESDAY_FIRST_START,
WEDNESDAY_FIRST_END,
WEDNESDAY_SECOND_START,
WEDNESDAY_SECOND_END,
THURSDAY_FIRST_START,
THURSDAY_FIRST_END,
THURSDAY_SECOND_START,
THURSDAY_SECOND_END,
FRIDAY_FIRST_START,
FRIDAY_FIRST_END,
FRIDAY_SECOND_START,
FRIDAY_SECOND_END,
SATURDAY_FIRST_START,
SATURDAY_FIRST_END,
SATURDAY_SECOND_START,
SATURDAY_SECOND_END,
SUNDAY_FIRST_START,
SUNDAY_FIRST_END,
SUNDAY_SECOND_START,
SUNDAY_SECOND_END,
DESCRIPTION
from csf_access_hours_vl
where task_id=p_task_id;

l_accesshour_required varchar2(1);
l_after_hours_flag    varchar2(1);
l_MONDAY_FIRST_START    date;
l_MONDAY_FIRST_END  date;
l_MONDAY_SECOND_START  date;
l_MONDAY_SECOND_END  date;
l_TUESDAY_FIRST_START  date;
l_TUESDAY_FIRST_END   date;
l_TUESDAY_SECOND_START  date;
l_TUESDAY_SECOND_END   date;
l_WEDNESDAY_FIRST_START  date;
l_WEDNESDAY_FIRST_END  date;
l_WEDNESDAY_SECOND_START   date;
l_WEDNESDAY_SECOND_END  date;
l_THURSDAY_FIRST_START  date;
l_THURSDAY_FIRST_END  date;
l_THURSDAY_SECOND_START  date;
l_THURSDAY_SECOND_END  date;
l_FRIDAY_FIRST_START  date;
l_FRIDAY_FIRST_END   date;
l_FRIDAY_SECOND_START  date;
l_FRIDAY_SECOND_END   date;
l_SATURDAY_FIRST_START  date;
l_SATURDAY_FIRST_END   date;
l_SATURDAY_SECOND_START   date;
l_SATURDAY_SECOND_END   date;
l_SUNDAY_FIRST_START  date;
l_SUNDAY_FIRST_END date;
l_SUNDAY_SECOND_START date;
l_SUNDAY_SECOND_END date;
l_DESCRIPTION varchar2(240);

BEGIN


l_task_status := get_task_status_flag (p_TASK_ID);
-- Insertion of a new record is allowed only when the status of the task is IN PLANNING or ON HOLD or PLANNED
-- For PLANNED status task only description field can be entered when inserting a record for a task

IF l_task_status ='W' or l_task_status='X' or (l_task_status='A' and p_calling_routine='DELETE_ROW') then
fnd_message.set_name('CSF','CSF_ACCESS_INVALID_STATUS');-- require message
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

IF l_task_status ='A' and p_CALLING_ROUTINE='INSERT_ROW' then
IF          p_MONDAY_FIRST_START is not NULL
OR          p_MONDAY_FIRST_END is not NULL
OR          p_TUESDAY_FIRST_START is not NULL
OR          p_TUESDAY_FIRST_END is not NULL
OR          p_WEDNESDAY_FIRST_START is not NULL
OR          p_WEDNESDAY_FIRST_END is not NULL
OR          p_THURSDAY_FIRST_START is not NULL
OR          p_THURSDAY_FIRST_END is not NULL
OR          p_FRIDAY_FIRST_START  is not NULL
OR          p_FRIDAY_FIRST_END  is not NULL
OR          p_SATURDAY_FIRST_START  is not NULL
OR          p_SATURDAY_FIRST_END  is not NULL
OR          p_SUNDAY_FIRST_START is not NULL
OR          p_SUNDAY_FIRST_END is not NULL
OR          p_MONDAY_SECOND_START is not NULL
OR          p_MONDAY_SECOND_END is not NULL
OR          p_TUESDAY_SECOND_START is not NULL
OR          p_TUESDAY_SECOND_END  is not NULL
OR          p_WEDNESDAY_SECOND_START is not NULL
OR          p_WEDNESDAY_SECOND_END is not NULL
OR          p_THURSDAY_SECOND_START is not NULL
OR          p_THURSDAY_SECOND_END is not NULL
OR          p_FRIDAY_SECOND_START is not NULL
OR          p_FRIDAY_SECOND_END is not NULL
OR          p_SATURDAY_SECOND_START is not NULL
OR          p_SATURDAY_SECOND_END is not NULL
OR          p_SUNDAY_SECOND_START is not NULL
OR          p_SUNDAY_SECOND_END is not NULL
OR          p_DESCRIPTION is  null
OR          nvl(p_ACCESS_HOUR_REQD,'N')='Y'
OR          nvl(p_AFTER_HOURS_FLAG,'N') ='Y'
then
fnd_message.set_name('CSF','CSF_ACCESS_INVALID_INSERT');---require message
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;
end if;

-- in case of UPDATE_ROW function
-- for tasks with status PLANNED,no changes to time slots are allowed
-- description can be changed
-- access hour and after hour flags can be changed from Y to N only
IF p_CALLING_ROUTINE='UPDATE_ROW' then
/*open c_existing_values(p_TASK_ID);
fetch c_existing_values into l_ACCESSHOUR_REQUIRED,
l_AFTER_HOURS_FLAG,
l_MONDAY_FIRST_START,
l_MONDAY_FIRST_END,
l_MONDAY_SECOND_START,
l_MONDAY_SECOND_END,
l_TUESDAY_FIRST_START,
l_TUESDAY_FIRST_END,
l_TUESDAY_SECOND_START,
l_TUESDAY_SECOND_END,
l_WEDNESDAY_FIRST_START,
l_WEDNESDAY_FIRST_END,
l_WEDNESDAY_SECOND_START,
l_WEDNESDAY_SECOND_END,
l_THURSDAY_FIRST_START,
l_THURSDAY_FIRST_END,
l_THURSDAY_SECOND_START,
l_THURSDAY_SECOND_END,
l_FRIDAY_FIRST_START,
l_FRIDAY_FIRST_END,
l_FRIDAY_SECOND_START,
l_FRIDAY_SECOND_END,
l_SATURDAY_FIRST_START,
l_SATURDAY_FIRST_END,
l_SATURDAY_SECOND_START,
l_SATURDAY_SECOND_END,
l_SUNDAY_FIRST_START,
l_SUNDAY_FIRST_END,
l_SUNDAY_SECOND_START,
l_SUNDAY_SECOND_END,
l_DESCRIPTION;
close c_existing_values;*/
null;


end if;

IF p_CALLING_ROUTINE='INSERT_ROW' or p_CALLING_ROUTINE='UPDATE_ROW' then

-- both flags should not be set to Y together

if nvl(p_ACCESS_HOUR_REQD,'N') ='Y' and nvl(p_AFTER_HOURS_FLAG,'N') ='Y' then
fnd_message.set_name('CSF','CSF_ACCESS_BOTH_FLAGS_INV');-- require message
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;



--When start time is entered ,end time should also be entered

IF (p_MONDAY_FIRST_START is not null and p_MONDAY_FIRST_END is null)
OR (p_MONDAY_SECOND_START is not null and  p_MONDAY_SECOND_END is null)
OR (p_TUESDAY_FIRST_START is not null and p_TUESDAY_FIRST_END is null)
OR (p_TUESDAY_SECOND_START is not null and  p_TUESDAY_SECOND_END is null)
OR (p_WEDNESDAY_FIRST_START is not null and p_WEDNESDAY_FIRST_END is null)
OR (p_WEDNESDAY_SECOND_START is not null and  p_WEDNESDAY_SECOND_END is null)
OR (p_THURSDAY_FIRST_START is not null and p_THURSDAY_FIRST_END is null)
OR (p_THURSDAY_SECOND_START is not null and  p_THURSDAY_SECOND_END is null)
OR (p_FRIDAY_FIRST_START is not null and p_FRIDAY_FIRST_END is null)
OR (p_FRIDAY_SECOND_START is not null and  p_FRIDAY_SECOND_END is null)
OR (p_SATURDAY_FIRST_START is not null and p_SATURDAY_FIRST_END is null)
OR (p_SATURDAY_SECOND_START is not null and  p_SATURDAY_SECOND_END is null)
OR (p_SUNDAY_FIRST_START is not null and p_SUNDAY_FIRST_END is null)
OR (p_SUNDAY_SECOND_START is not null and  p_SUNDAY_SECOND_END is null)

then
fnd_message.set_name('CSF','CSF_INV_START_END_NOT_NULL');
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

-- when access_hours flag is set atleast one slot should be entered

if nvl(p_ACCESS_HOUR_REQD,'N') ='Y'
and p_MONDAY_FIRST_START is null
and p_TUESDAY_FIRST_START is null
and p_WEDNESDAY_FIRST_START is null
and p_THURSDAY_FIRST_START is null
and p_FRIDAY_FIRST_START is null
and p_SATURDAY_FIRST_START is null
and p_SUNDAY_FIRST_START is null
then
fnd_message.set_name('CSF','CSF_ENTER_ATLEAST_ONE_SLOT');-- require message here
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

-- start to be enetered first and then the end

IF (p_MONDAY_FIRST_START is null and p_MONDAY_FIRST_END is NOT null)
OR (p_MONDAY_SECOND_START is  null and  p_MONDAY_SECOND_END is not null)
OR (p_TUESDAY_FIRST_START is  null and p_TUESDAY_FIRST_END is not null)
OR (p_TUESDAY_SECOND_START is  null and  p_TUESDAY_SECOND_END is not null)
OR (p_WEDNESDAY_FIRST_START is null and p_WEDNESDAY_FIRST_END is not  null)
OR (p_WEDNESDAY_SECOND_START is  null and p_WEDNESDAY_SECOND_END is not null)
OR (p_THURSDAY_FIRST_START is null and p_THURSDAY_FIRST_END is  not null)
OR (p_THURSDAY_SECOND_START is null and p_THURSDAY_SECOND_END is not null)
OR (p_FRIDAY_FIRST_START is  null and p_FRIDAY_FIRST_END is not  null)
OR (p_FRIDAY_SECOND_START is null and  p_FRIDAY_SECOND_END is not null)
OR (p_SATURDAY_FIRST_START is  null and p_SATURDAY_FIRST_END is not null)
OR (p_SATURDAY_SECOND_START is null and  p_SATURDAY_SECOND_END is not null)
OR (p_SUNDAY_FIRST_START is null and p_SUNDAY_FIRST_END is not null)
OR (p_SUNDAY_SECOND_START is  null and  p_SUNDAY_SECOND_END is not null)

then
fnd_message.set_name('CSF','CSF_ACCESS_START_FIRST');-- need new messgae for this
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;
-- second slots for a day to be entered only after end times are entered

IF( (p_MONDAY_FIRST_START is null and p_MONDAY_FIRST_END is null)
and (p_MONDAY_SECOND_START is not null or  p_MONDAY_SECOND_END is not null) )
OR( (p_TUESDAY_FIRST_START is  null and p_TUESDAY_FIRST_END is null)
and (p_TUESDAY_SECOND_START is not null or  p_TUESDAY_SECOND_END is not null))
OR( (p_WEDNESDAY_FIRST_START is null and p_WEDNESDAY_FIRST_END is null)
and (p_WEDNESDAY_SECOND_START is not null or p_WEDNESDAY_SECOND_END is not null))
OR( (p_THURSDAY_FIRST_START is null and p_THURSDAY_FIRST_END is null)
and (p_THURSDAY_SECOND_START is not null or p_THURSDAY_SECOND_END is not null))
OR( (p_FRIDAY_FIRST_START is  null and p_FRIDAY_FIRST_END is null)
and (p_FRIDAY_SECOND_START is not null or  p_FRIDAY_SECOND_END is not null))
OR( (p_SATURDAY_FIRST_START is  null and p_SATURDAY_FIRST_END is null)
and (p_SATURDAY_SECOND_START is not null or  p_SATURDAY_SECOND_END is not null))
OR( (p_SUNDAY_FIRST_START is null and p_SUNDAY_FIRST_END is null)
and (p_SUNDAY_SECOND_START is not null and  p_SUNDAY_SECOND_END is not null))

then
fnd_message.set_name('CSF','CSF_SECOND_SLOT_FIRST_SLOT');-- need new messgae for this
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

--- start time should be less than the end time for each slot

IF (p_MONDAY_FIRST_START > p_MONDAY_FIRST_END )
OR (p_MONDAY_SECOND_START >p_MONDAY_SECOND_END )
OR (p_TUESDAY_FIRST_START > p_TUESDAY_FIRST_END)
OR (p_TUESDAY_SECOND_START >p_TUESDAY_SECOND_END)
OR (p_WEDNESDAY_FIRST_START > p_WEDNESDAY_FIRST_END )
OR (p_WEDNESDAY_SECOND_START >p_WEDNESDAY_SECOND_END )
OR (p_THURSDAY_FIRST_START >p_THURSDAY_FIRST_END)
OR (p_THURSDAY_SECOND_START >p_THURSDAY_SECOND_END)
OR (p_FRIDAY_FIRST_START >p_FRIDAY_FIRST_END)
OR (p_FRIDAY_SECOND_START > p_FRIDAY_SECOND_END)
OR (p_SATURDAY_FIRST_START > p_SATURDAY_FIRST_END )
OR (p_SATURDAY_SECOND_START > p_SATURDAY_SECOND_END)
OR (p_SUNDAY_FIRST_START >p_SUNDAY_FIRST_END )
OR (p_SUNDAY_SECOND_START >p_SUNDAY_SECOND_END)

then
fnd_message.set_name('CSF','CSF_INV_START_END');
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

-- start time of the second slot should be greater than the end time of the first slot for a day
IF (p_MONDAY_FIRST_END > p_MONDAY_SECOND_START )
OR (p_TUESDAY_FIRST_END > p_TUESDAY_SECOND_START)
OR (p_WEDNESDAY_FIRST_END >p_WEDNESDAY_SECOND_START )
OR (p_THURSDAY_FIRST_END >p_THURSDAY_SECOND_START)
OR (p_FRIDAY_FIRST_END > p_FRIDAY_SECOND_START)
OR (p_SATURDAY_FIRST_END > p_SATURDAY_SECOND_START)
OR (p_SUNDAY_FIRST_END >p_SUNDAY_SECOND_START)

then
fnd_message.set_name('CSF','CSF_INV_SLOTS');
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

/*-- both flags should not be set to Y together

if nvl(p_ACCESS_HOUR_REQD,'N') ='Y' and nvl(p_AFTER_HOURS_FLAG,'N') ='Y' then
fnd_message.set_name('CSF','CSF_INV_SLOTS');-- require message
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

-- when access_hours flag is set atleast one slot should be entered

if nvl(p_ACCESS_HOUR_REQD,'N') ='Y'
and p_MONDAY_FIRST_START is null
and p_TUESDAY_FIRST_START is null
and p_WEDNESDAY_FIRST_START is null
and p_THURSDAY_FIRST_START is null
and p_FRIDAY_FIRST_START is null
and p_SATURDAY_FIRST_START is null
and p_SUNDAY_FIRST_START is null
then
fnd_message.set_name('CSF','CSF_INV_START_END_NOT_NULL');-- require message here
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;*/

end if;

EXCEPTION
WHEN  fnd_api.g_exc_error then
x_return_status := fnd_api.g_ret_sts_error;
--fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN fnd_api.g_exc_unexpected_error then
x_return_status :=fnd_api.g_ret_sts_unexp_error;
--fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN others then
x_return_status :=fnd_api.g_ret_sts_unexp_error;
--fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);


END CHECK_PARAMETERS;

PROCEDURE CREATE_ACCESS_HOURS(
          x_ACCESS_HOUR_ID OUT NOCOPY NUMBER,
          p_API_VERSION NUMBER,
          p_init_msg_list varchar2 ,
          p_TASK_ID    NUMBER,
          p_ACCESS_HOUR_REQD VARCHAR2,
          p_AFTER_HOURS_FLAG VARCHAR2 ,
          p_MONDAY_FIRST_START DATE ,
          p_MONDAY_FIRST_END DATE ,
          p_MONDAY_SECOND_START DATE  ,
          p_MONDAY_SECOND_END DATE ,
          p_TUESDAY_FIRST_START DATE ,
          p_TUESDAY_FIRST_END DATE  ,
          p_TUESDAY_SECOND_START DATE,
          p_TUESDAY_SECOND_END DATE  ,
          p_WEDNESDAY_FIRST_START DATE ,
          p_WEDNESDAY_FIRST_END DATE ,
          p_WEDNESDAY_SECOND_START DATE ,
          p_WEDNESDAY_SECOND_END DATE ,
          p_THURSDAY_FIRST_START DATE ,
          p_THURSDAY_FIRST_END DATE ,
          p_THURSDAY_SECOND_START DATE ,
          p_THURSDAY_SECOND_END DATE ,
          p_FRIDAY_FIRST_START DATE,
          p_FRIDAY_FIRST_END DATE ,
          p_FRIDAY_SECOND_START DATE ,
          p_FRIDAY_SECOND_END DATE,
          p_SATURDAY_FIRST_START DATE ,
          p_SATURDAY_FIRST_END DATE ,
          p_SATURDAY_SECOND_START DATE ,
          p_SATURDAY_SECOND_END DATE ,
          p_SUNDAY_FIRST_START DATE ,
          p_SUNDAY_FIRST_END DATE,
          p_SUNDAY_SECOND_START DATE ,
          p_SUNDAY_SECOND_END DATE,
          p_DESCRIPTION VARCHAR2,
          px_object_version_number in out nocopy number,
          p_CREATED_BY    NUMBER ,
          p_CREATION_DATE    DATE ,
          p_LAST_UPDATED_BY    NUMBER ,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER ,
  --        p_commit in     varchar2 default fnd_api.g_false,
          x_return_status            OUT NOCOPY            VARCHAR2,
	  x_msg_data                 OUT NOCOPY            VARCHAR2,
	  x_msg_count                OUT NOCOPY            NUMBER


)

          IS

   l_api_version CONSTANT Number := 1.0 ;
   l_api_name_full CONSTANT varchar2(50) := 'CSF_ACCESS_HOURS_PUB.CREATE_ACCESS_HOURS';
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
l_sta           varchar2(1);
l_cnt           number;
l_msg           varchar2(2000);
l_temp          varchar2(1);

CURSOR C_EXISTS(p_task_id number) is select 'Y' from csf_access_hours_vl where task_id=p_task_id;

 BEGIN
SAVEPOINT create_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_success;

IF NOT fnd_api.compatible_api_call (
l_api_version,
p_api_version,
l_api_name_full,
g_pkg_name
)
then
raise fnd_Api.g_exc_unexpected_error;
end if;

IF fnd_api.to_boolean( nvl(p_init_msg_list,fnd_Api.g_false)) then
fnd_msg_pub.initialize;
end if;

If p_task_id is NULL then
fnd_message.set_name ('CSF','CSF_ACCESS_INVALID_PARAMETER');--message required
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

open c_exists(p_task_id);
fetch c_exists into l_temp;
 if c_exists%notfound then
    close c_exists;
 else
   close c_exists;
   fnd_message.set_name('CSF','CSF_ACCESS_ROW_EXISTS');
   fnd_msg_pub.add;
   raise fnd_api.g_exc_error;
 end if;

check_parameters
(
p_CALLING_ROUTINE => 'INSERT_ROW',
p_TASK_ID => p_TASK_ID,
p_ACCESS_HOUR_REQD=>nvl(p_ACCESS_HOUR_REQD,'N'),
p_AFTER_HOURS_FLAG =>nvl(p_AFTER_HOURS_FLAG,'N'),
p_MONDAY_FIRST_START =>p_MONDAY_FIRST_START,
p_MONDAY_FIRST_END  =>p_MONDAY_FIRST_END,
p_TUESDAY_FIRST_START  =>p_TUESDAY_FIRST_START,
p_TUESDAY_FIRST_END   =>p_TUESDAY_FIRST_END,
p_WEDNESDAY_FIRST_START =>p_WEDNESDAY_FIRST_START,
p_WEDNESDAY_FIRST_END  =>p_WEDNESDAY_FIRST_END ,
p_THURSDAY_FIRST_START  =>p_THURSDAY_FIRST_START ,
p_THURSDAY_FIRST_END  =>p_THURSDAY_FIRST_END,
p_FRIDAY_FIRST_START  =>p_FRIDAY_FIRST_START,
p_FRIDAY_FIRST_END  =>p_FRIDAY_FIRST_END ,
p_SATURDAY_FIRST_START =>p_SATURDAY_FIRST_START,
p_SATURDAY_FIRST_END  => p_SATURDAY_FIRST_END ,
p_SUNDAY_FIRST_START =>p_SUNDAY_FIRST_START ,
p_SUNDAY_FIRST_END  =>p_SUNDAY_FIRST_END   ,
p_MONDAY_SECOND_START => p_MONDAY_SECOND_START,
p_MONDAY_SECOND_END  =>p_MONDAY_SECOND_END  ,
p_TUESDAY_SECOND_START  =>p_TUESDAY_SECOND_START ,
p_TUESDAY_SECOND_END   =>p_TUESDAY_SECOND_END,
p_WEDNESDAY_SECOND_START =>p_WEDNESDAY_SECOND_START,
p_WEDNESDAY_SECOND_END  => p_WEDNESDAY_SECOND_END ,
p_THURSDAY_SECOND_START  =>p_THURSDAY_SECOND_START ,
p_THURSDAY_SECOND_END  => p_THURSDAY_SECOND_END ,
p_FRIDAY_SECOND_START  => p_FRIDAY_SECOND_START,
p_FRIDAY_SECOND_END  => p_FRIDAY_SECOND_END ,
p_SATURDAY_SECOND_START =>p_SATURDAY_SECOND_START ,
p_SATURDAY_SECOND_END  =>p_SATURDAY_SECOND_END  ,
p_SUNDAY_SECOND_START =>p_SUNDAY_SECOND_START ,
p_SUNDAY_SECOND_END  =>p_SUNDAY_SECOND_END  ,
p_DESCRIPTION => p_DESCRIPTION,
x_return_status            => l_return_status,
x_msg_count                => l_msg_count,
x_msg_data                 => l_msg_data

);

If l_return_status = fnd_api.g_ret_sts_error then
raise fnd_api.g_exc_error;
end if;

If l_return_status = fnd_api.g_ret_sts_unexp_error then
raise fnd_Api.g_exc_unexpected_error;
end if;

CSF_ACCESS_HOURS_PVT.CREATE_ACCESS_HOURS
(
p_API_VERSION => 1.0,
p_INIT_MSG_LIST => 'F',
x_ACCESS_HOUR_ID =>x_ACCESS_HOUR_ID,
p_TASK_ID=>p_TASK_ID,
p_ACCESS_HOUR_REQD=>nvl(p_ACCESS_HOUR_REQD,'N'),
p_AFTER_HOURS_FLAG =>nvl(p_AFTER_HOURS_FLAG,'N'),
p_MONDAY_FIRST_START =>p_MONDAY_FIRST_START,
p_MONDAY_FIRST_END  =>p_MONDAY_FIRST_END,
p_TUESDAY_FIRST_START  =>p_TUESDAY_FIRST_START,
p_TUESDAY_FIRST_END   =>p_TUESDAY_FIRST_END,
p_WEDNESDAY_FIRST_START =>p_WEDNESDAY_FIRST_START,
p_WEDNESDAY_FIRST_END  =>p_WEDNESDAY_FIRST_END ,
p_THURSDAY_FIRST_START  =>p_THURSDAY_FIRST_START ,
p_THURSDAY_FIRST_END  =>p_THURSDAY_FIRST_END,
p_FRIDAY_FIRST_START  =>p_FRIDAY_FIRST_START,
p_FRIDAY_FIRST_END  =>p_FRIDAY_FIRST_END ,
p_SATURDAY_FIRST_START =>p_SATURDAY_FIRST_START,
p_SATURDAY_FIRST_END  => p_SATURDAY_FIRST_END ,
p_SUNDAY_FIRST_START =>p_SUNDAY_FIRST_START ,
p_SUNDAY_FIRST_END  =>p_SUNDAY_FIRST_END   ,
p_MONDAY_SECOND_START => p_MONDAY_SECOND_START,
p_MONDAY_SECOND_END  =>p_MONDAY_SECOND_END  ,
p_TUESDAY_SECOND_START  =>p_TUESDAY_SECOND_START ,
p_TUESDAY_SECOND_END   =>p_TUESDAY_SECOND_END,
p_WEDNESDAY_SECOND_START =>p_WEDNESDAY_SECOND_START,
p_WEDNESDAY_SECOND_END  => p_WEDNESDAY_SECOND_END ,
p_THURSDAY_SECOND_START  =>p_THURSDAY_SECOND_START ,
p_THURSDAY_SECOND_END  => p_THURSDAY_SECOND_END ,
p_FRIDAY_SECOND_START  => p_FRIDAY_SECOND_START,
p_FRIDAY_SECOND_END  => p_FRIDAY_SECOND_END ,
p_SATURDAY_SECOND_START =>p_SATURDAY_SECOND_START ,
p_SATURDAY_SECOND_END  =>p_SATURDAY_SECOND_END  ,
p_SUNDAY_SECOND_START =>p_SUNDAY_SECOND_START ,
p_SUNDAY_SECOND_END  =>p_SUNDAY_SECOND_END  ,
p_DESCRIPTION => p_DESCRIPTION,
px_object_version_number => px_object_version_number,
p_commit =>fnd_api.g_true,--p_commit
x_return_status            => l_return_status,
x_msg_count                => l_msg_count,
x_msg_data                 => l_msg_data

);


If l_return_status = fnd_api.g_ret_sts_error then
raise fnd_api.g_exc_error;
end if;

If l_return_status = fnd_api.g_ret_sts_unexp_error then
raise fnd_Api.g_exc_unexpected_error;
end if;

fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION
WHEN  fnd_api.g_exc_error then
ROLLBACK TO create_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  fnd_api.g_exc_unexpected_error then
ROLLBACK TO create_access_hours_pub;
x_return_status :=fnd_api.g_ret_sts_unexp_error ;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  OTHERS then
ROLLBACK TO create_task_assignment_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);


End  CREATE_ACCESS_HOURS;

PROCEDURE UPDATE_ACCESS_HOURS(
          p_ACCESS_HOUR_ID   IN  NUMBER,
          p_TASK_ID    NUMBER,
          p_API_VERSION NUMBER,
          p_init_msg_list varchar2 ,
          p_commit        varchar2 ,
          p_ACCESS_HOUR_REQD VARCHAR2 ,
          p_AFTER_HOURS_FLAG VARCHAR2 ,
          p_MONDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_MONDAY_FIRST_END DATE, --default TO_DATE(NULL),
          p_MONDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_MONDAY_SECOND_END DATE, --default TO_DATE(NULL),
          p_TUESDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_TUESDAY_FIRST_END DATE, --default  TO_DATE(NULL) ,
          p_TUESDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_TUESDAY_SECOND_END DATE, --default TO_DATE(NULL) ,
          p_WEDNESDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_WEDNESDAY_FIRST_END DATE, -- default TO_DATE(NULL),
          p_WEDNESDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_WEDNESDAY_SECOND_END DATE,-- default TO_DATE(NULL),
          p_THURSDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_THURSDAY_FIRST_END DATE, --default TO_DATE(NULL),
          p_THURSDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_THURSDAY_SECOND_END DATE, --default TO_DATE(NULL),
          p_FRIDAY_FIRST_START DATE,-- default TO_DATE(NULL),
          p_FRIDAY_FIRST_END DATE,-- default TO_DATE(NULL),
          p_FRIDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_FRIDAY_SECOND_END DATE,-- default TO_DATE(NULL),
          p_SATURDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_SATURDAY_FIRST_END DATE, --default TO_DATE(NULL),
          p_SATURDAY_SECOND_START DATE,-- default TO_DATE(NULL),
          p_SATURDAY_SECOND_END DATE, --default TO_DATE(NULL),
          p_SUNDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_SUNDAY_FIRST_END DATE, -- default TO_DATE(NULL),
          p_SUNDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_SUNDAY_SECOND_END DATE, --default TO_DATE(NULL),
          p_DESCRIPTION VARCHAR2 DEFAULT null,
          px_object_version_number in out nocopy number,
          p_CREATED_BY    NUMBER default null,
          p_CREATION_DATE    DATE default null,
          p_LAST_UPDATED_BY    NUMBER default null,
          p_LAST_UPDATE_DATE    DATE default null,
          p_LAST_UPDATE_LOGIN    NUMBER default null,
          x_return_status            OUT NOCOPY            VARCHAR2,
	  x_msg_data                 OUT NOCOPY            VARCHAR2,
	  x_msg_count                OUT NOCOPY            NUMBER

          )

 IS
          l_api_name_full constant varchar2(50) := 'CSF_ACCESS_HOURS_PUB.UPDATE_ACCESS_HOURS';
          l_api_version CONSTANT Number := 1.0 ;
          l_return_status    varchar2(100);
          l_msg_count        NUMBER;
          l_msg_data         varchar2(1000);
l_sta           varchar2(1);
l_cnt           number;
l_msg           varchar2(2000);




cursor c_existing_values(p_task_id number) is
select
ACCESSHOUR_REQUIRED,
AFTER_HOURS_FLAG,
MONDAY_FIRST_START,
MONDAY_FIRST_END,
MONDAY_SECOND_START,
MONDAY_SECOND_END,
TUESDAY_FIRST_START,
TUESDAY_FIRST_END,
TUESDAY_SECOND_START,
TUESDAY_SECOND_END,
WEDNESDAY_FIRST_START,
WEDNESDAY_FIRST_END,
WEDNESDAY_SECOND_START,
WEDNESDAY_SECOND_END,
THURSDAY_FIRST_START,
THURSDAY_FIRST_END,
THURSDAY_SECOND_START,
THURSDAY_SECOND_END,
FRIDAY_FIRST_START,
FRIDAY_FIRST_END,
FRIDAY_SECOND_START,
FRIDAY_SECOND_END,
SATURDAY_FIRST_START,
SATURDAY_FIRST_END,
SATURDAY_SECOND_START,
SATURDAY_SECOND_END,
SUNDAY_FIRST_START,
SUNDAY_FIRST_END,
SUNDAY_SECOND_START,
SUNDAY_SECOND_END,
DESCRIPTION,
object_version_number
from csf_access_hours_vl
where task_id=p_task_id;

l_ACCESS_HOUR_REQD VARCHAR2(1);

l_after_hours_flag    varchar2(1);
l_MONDAY_FIRST_START    date;
l_MONDAY_FIRST_END  date;
l_MONDAY_SECOND_START  date;
l_MONDAY_SECOND_END  date;
l_TUESDAY_FIRST_START  date;
l_TUESDAY_FIRST_END   date;
l_TUESDAY_SECOND_START  date;
l_TUESDAY_SECOND_END   date;
l_WEDNESDAY_FIRST_START  date;
l_WEDNESDAY_FIRST_END  date;
l_WEDNESDAY_SECOND_START   date;
l_WEDNESDAY_SECOND_END  date;
l_THURSDAY_FIRST_START  date;
l_THURSDAY_FIRST_END  date;
l_THURSDAY_SECOND_START  date;
l_THURSDAY_SECOND_END  date;
l_FRIDAY_FIRST_START  date;
l_FRIDAY_FIRST_END   date;
l_FRIDAY_SECOND_START  date;
l_FRIDAY_SECOND_END   date;
l_SATURDAY_FIRST_START  date;
l_SATURDAY_FIRST_END   date;
l_SATURDAY_SECOND_START   date;
l_SATURDAY_SECOND_END   date;
l_SUNDAY_FIRST_START  date;
l_SUNDAY_FIRST_END date;
l_SUNDAY_SECOND_START date;
l_SUNDAY_SECOND_END date;
l_DESCRIPTION varchar2(240);
--l_object_version_number number;

l_task_status varchar2(1);
l_temp          varchar2(1);

CURSOR C_EXISTS(p_task_id number) is select 'Y' from csf_access_hours_vl where task_id=p_task_id;

 BEGIN
SAVEPOINT update_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_success;

IF NOT fnd_api.compatible_api_call (
l_api_version,
p_api_version,
l_api_name_full,
g_pkg_name
)
then
raise fnd_Api.g_exc_unexpected_error;
end if;

IF fnd_api.to_boolean(nvl(p_init_msg_list,fnd_Api.g_false)) then
fnd_msg_pub.initialize;
end if;


If p_task_id is NULL or p_ACCESS_HOUR_ID is NULL then
fnd_message.set_name ('CSF','CSF_ACCESS_INVALID_PARAMETER');--message required
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

open c_exists(p_task_id);
fetch c_exists into l_temp;
 if c_exists%notfound then
   close c_exists;
   fnd_message.set_name('CSF','CSF_ACCESS_NO_ROW_EXISTS');
   fnd_msg_pub.add;
   raise fnd_api.g_exc_error;
 else
   close c_exists;
 end if;

open c_existing_values(p_TASK_ID);
fetch c_existing_values into l_ACCESS_HOUR_REQD,
l_AFTER_HOURS_FLAG,
l_MONDAY_FIRST_START,
l_MONDAY_FIRST_END,
l_MONDAY_SECOND_START,
l_MONDAY_SECOND_END,
l_TUESDAY_FIRST_START,
l_TUESDAY_FIRST_END,
l_TUESDAY_SECOND_START,
l_TUESDAY_SECOND_END,
l_WEDNESDAY_FIRST_START,
l_WEDNESDAY_FIRST_END,
l_WEDNESDAY_SECOND_START,
l_WEDNESDAY_SECOND_END,
l_THURSDAY_FIRST_START,
l_THURSDAY_FIRST_END,
l_THURSDAY_SECOND_START,
l_THURSDAY_SECOND_END,
l_FRIDAY_FIRST_START,
l_FRIDAY_FIRST_END,
l_FRIDAY_SECOND_START,
l_FRIDAY_SECOND_END,
l_SATURDAY_FIRST_START,
l_SATURDAY_FIRST_END,
l_SATURDAY_SECOND_START,
l_SATURDAY_SECOND_END,
l_SUNDAY_FIRST_START,
l_SUNDAY_FIRST_END,
l_SUNDAY_SECOND_START,
l_SUNDAY_SECOND_END,
l_DESCRIPTION,
px_object_version_number;
close c_existing_values;
l_task_status:=get_task_status_flag(p_task_id);

IF l_task_status='A' then

IF ((l_ACCESS_HOUR_REQD ='N' and  p_ACCESS_HOUR_REQD ='Y')
OR  (l_AFTER_HOURS_FLAG ='N' and p_AFTER_HOURS_FLAG='Y'))
then
fnd_message.set_name ('CSF','CSF_INV_FLAG_CHANGE');--message required
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

IF p_MONDAY_FIRST_START is not null
OR p_MONDAY_FIRST_END is not null
OR p_TUESDAY_FIRST_START is not null
OR p_TUESDAY_FIRST_END is not null
OR p_WEDNESDAY_FIRST_START is not null
OR p_WEDNESDAY_FIRST_END is not null
OR p_THURSDAY_FIRST_START is not null
OR p_THURSDAY_FIRST_END is not null
OR p_FRIDAY_FIRST_START is not null
OR p_FRIDAY_FIRST_END is not null
OR p_SATURDAY_FIRST_START is not null
OR p_SATURDAY_FIRST_END is not null
OR p_SUNDAY_FIRST_START is not null
OR p_SUNDAY_FIRST_END is not null
OR p_MONDAY_SECOND_START is not null
OR p_MONDAY_SECOND_END is not null
OR p_TUESDAY_SECOND_START is not null
OR p_TUESDAY_SECOND_END is not null
OR p_WEDNESDAY_SECOND_START is not null
OR p_WEDNESDAY_SECOND_END is not null
OR p_THURSDAY_SECOND_START is not null
OR p_THURSDAY_SECOND_END is not null
OR p_FRIDAY_SECOND_START is not null
OR p_FRIDAY_SECOND_END is not null
OR p_SATURDAY_SECOND_START is not null
OR p_SATURDAY_SECOND_END is not null
OR p_SUNDAY_SECOND_START is not null
OR p_SUNDAY_SECOND_END is not null then

fnd_message.set_name ('CSF','CSF_INV_DATE_CHANGE');--message required
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;
 end if;

--- now copy all existing values and the new values to the local variable b4 calling the update_row procedure of csf_access_hours_pvt
IF p_ACCESS_HOUR_REQD is NOT  NULL then
l_ACCESS_HOUR_REQD :=p_ACCESS_HOUR_REQD;
END IF;

IF  p_AFTER_HOURS_FLAG is NOT NULL then
l_AFTER_HOURS_FLAG := p_AFTER_HOURS_FLAG;
END IF;

--IF p_MONDAY_FIRST_START is NOT NULL and
IF l_task_status <> 'A' then
l_MONDAY_FIRST_START := p_MONDAY_FIRST_START;
END IF;

--IF p_MONDAY_FIRST_END is NOT NULL and
IF l_task_status <> 'A' then
l_MONDAY_FIRST_END := p_MONDAY_FIRST_END;
END IF;

--IF p_MONDAY_SECOND_START is NOT NULL and
IF l_task_status <> 'A'  then
l_MONDAY_SECOND_START := p_MONDAY_SECOND_START;
END IF;

--IF p_MONDAY_SECOND_END is NOT NULL and
IF l_task_status<> 'A' then
l_MONDAY_SECOND_END := p_MONDAY_SECOND_END;
END IF;

--IF p_TUESDAY_FIRST_START is NOT NULL and
IF l_task_status<>'A' then
l_TUESDAY_FIRST_START := p_TUESDAY_FIRST_START;
END IF;

--IF p_TUESDAY_FIRST_END is NOT NULL and
IF l_task_status<>'A'  then
l_TUESDAY_FIRST_END := p_TUESDAY_FIRST_END;
END IF;

--IF p_TUESDAY_SECOND_START is NOT NULL and
IF l_task_status<>'A'  then
l_TUESDAY_SECOND_START := p_TUESDAY_SECOND_START;
END IF;

--IF p_TUESDAY_SECOND_END is NOT NULL and
IF l_task_status<>'A'  then
l_TUESDAY_SECOND_END := p_TUESDAY_SECOND_END;
END IF;

--IF p_WEDNESDAY_FIRST_START is NOT NULL and
IF l_task_status<>'A' then
l_WEDNESDAY_FIRST_START := p_WEDNESDAY_FIRST_START;
END IF;

--IF p_WEDNESDAY_FIRST_END is NOT NULL and
IF  l_task_status<>'A' then
l_WEDNESDAY_FIRST_END := p_WEDNESDAY_FIRST_END;
END IF;

--IF p_WEDNESDAY_SECOND_START is NOT NULL and
IF  l_task_status<>'A' then
l_WEDNESDAY_SECOND_START := p_WEDNESDAY_SECOND_START;
END IF;

--IF p_WEDNESDAY_SECOND_END is NOT NULL and
IF l_task_status<>'A' then
l_WEDNESDAY_SECOND_END := p_WEDNESDAY_SECOND_END;
END IF;

--IF p_THURSDAY_FIRST_START is NOT NULL and
IF l_task_status<>'A' then
l_THURSDAY_FIRST_START := p_THURSDAY_FIRST_START;
END IF;

--IF p_THURSDAY_FIRST_END is NOT NULL and
IF l_task_status<>'A' then
l_THURSDAY_FIRST_END := p_THURSDAY_FIRST_END;
END IF;

--IF p_THURSDAY_SECOND_START is NOT NULL and
IF l_task_status<>'A' then
l_THURSDAY_SECOND_START := p_THURSDAY_SECOND_START;
END IF;

--IF p_THURSDAY_SECOND_END is NOT NULL and
IF  l_task_status<>'A' then
l_THURSDAY_SECOND_END := p_THURSDAY_SECOND_END;
END IF;

--IF p_FRIDAY_FIRST_START is NOT NULL and
IF l_task_status<>'A' then
l_FRIDAY_FIRST_START := p_FRIDAY_FIRST_START;
END IF;

--IF p_FRIDAY_FIRST_END is NOT NULL and
 IF l_task_status<>'A' then
l_FRIDAY_FIRST_END := p_FRIDAY_FIRST_END;
END IF;

--IF p_FRIDAY_SECOND_START is NOT NULL and
IF l_task_status<>'A' then
l_FRIDAY_SECOND_START := p_FRIDAY_SECOND_START;
END IF;

--IF p_FRIDAY_SECOND_END is NOT NULL and
IF l_task_status<>'A' then
l_FRIDAY_SECOND_END := p_FRIDAY_SECOND_END;
END IF;

--IF p_SATURDAY_FIRST_START is NOT NULL and
IF l_task_status<>'A' then
l_SATURDAY_FIRST_START := p_SATURDAY_FIRST_START;
END IF;

--IF p_SATURDAY_FIRST_END is NOT NULL and
IF l_task_status<>'A' then
l_SATURDAY_FIRST_END := p_SATURDAY_FIRST_END;
END IF;

--IF p_SATURDAY_SECOND_START is NOT NULL and
IF  l_task_status<>'A' then
l_SATURDAY_SECOND_START := p_SATURDAY_SECOND_START;
END IF;

--IF p_SATURDAY_SECOND_END is NOT NULL and
IF  l_task_status<>'A' then
l_SATURDAY_SECOND_END := p_SATURDAY_SECOND_END;
END IF;

--IF p_SUNDAY_FIRST_START is NOT NULL and
IF  l_task_status<>'A'   then
l_SUNDAY_FIRST_START := p_SUNDAY_FIRST_START;
END IF;

--IF p_SUNDAY_FIRST_END is NOT NULL  and
IF l_task_status<>'A' then
l_SUNDAY_FIRST_END := p_SUNDAY_FIRST_END;
END IF;

--IF p_SUNDAY_SECOND_START is NOT NULL and
IF l_task_status<>'A'  then
l_SUNDAY_SECOND_START := p_SUNDAY_SECOND_START;
END IF;

--IF p_SUNDAY_SECOND_END is NOT NULL  and
IF l_task_status<>'A' then
l_SUNDAY_SECOND_END := p_SUNDAY_SECOND_END;
END IF;

IF p_description is NOT NULL then
l_description := p_description;
END IF;

   check_parameters
(
p_CALLING_ROUTINE => 'UPDATE_ROW',
p_TASK_ID => p_TASK_ID,
p_ACCESS_HOUR_REQD=>l_ACCESS_HOUR_REQD,
p_AFTER_HOURS_FLAG =>l_AFTER_HOURS_FLAG,
p_MONDAY_FIRST_START =>l_MONDAY_FIRST_START,
p_MONDAY_FIRST_END  =>l_MONDAY_FIRST_END,
p_TUESDAY_FIRST_START  =>l_TUESDAY_FIRST_START,
p_TUESDAY_FIRST_END   =>l_TUESDAY_FIRST_END,
p_WEDNESDAY_FIRST_START =>l_WEDNESDAY_FIRST_START,
p_WEDNESDAY_FIRST_END  =>l_WEDNESDAY_FIRST_END ,
p_THURSDAY_FIRST_START  =>l_THURSDAY_FIRST_START ,
p_THURSDAY_FIRST_END  =>l_THURSDAY_FIRST_END,
p_FRIDAY_FIRST_START  =>l_FRIDAY_FIRST_START,
p_FRIDAY_FIRST_END  =>l_FRIDAY_FIRST_END ,
p_SATURDAY_FIRST_START =>l_SATURDAY_FIRST_START,
p_SATURDAY_FIRST_END  => l_SATURDAY_FIRST_END ,
p_SUNDAY_FIRST_START =>l_SUNDAY_FIRST_START ,
p_SUNDAY_FIRST_END  =>l_SUNDAY_FIRST_END   ,
p_MONDAY_SECOND_START => l_MONDAY_SECOND_START,
p_MONDAY_SECOND_END  =>l_MONDAY_SECOND_END  ,
p_TUESDAY_SECOND_START  =>l_TUESDAY_SECOND_START ,
p_TUESDAY_SECOND_END   =>l_TUESDAY_SECOND_END,
p_WEDNESDAY_SECOND_START =>l_WEDNESDAY_SECOND_START,
p_WEDNESDAY_SECOND_END  => l_WEDNESDAY_SECOND_END ,
p_THURSDAY_SECOND_START  =>l_THURSDAY_SECOND_START ,
p_THURSDAY_SECOND_END  => l_THURSDAY_SECOND_END ,
p_FRIDAY_SECOND_START  => l_FRIDAY_SECOND_START,
p_FRIDAY_SECOND_END  => l_FRIDAY_SECOND_END ,
p_SATURDAY_SECOND_START =>l_SATURDAY_SECOND_START ,
p_SATURDAY_SECOND_END  =>l_SATURDAY_SECOND_END  ,
p_SUNDAY_SECOND_START =>l_SUNDAY_SECOND_START ,
p_SUNDAY_SECOND_END  =>l_SUNDAY_SECOND_END  ,
p_DESCRIPTION => l_DESCRIPTION,
x_return_status            => l_return_status,
x_msg_count                => l_msg_count,
x_msg_data                 => l_msg_data

);

If l_return_status = fnd_api.g_ret_sts_error then
raise fnd_api.g_exc_error;
end if;

If l_return_status = fnd_api.g_ret_sts_unexp_error then
raise fnd_Api.g_exc_unexpected_error;
end if;


CSF_ACCESS_HOURS_PVT.UPDATE_ACCESS_HOURS(
p_API_VERSION => 1.0,
p_INIT_MSG_LIST => 'F',
p_ACCESS_HOUR_ID =>p_ACCESS_HOUR_ID,
p_TASK_ID=>p_TASK_ID,
p_ACCESS_HOUR_REQD=>l_ACCESS_HOUR_REQD,
p_AFTER_HOURS_FLAG =>l_AFTER_HOURS_FLAG,
p_MONDAY_FIRST_START =>l_MONDAY_FIRST_START,
p_MONDAY_FIRST_END  =>l_MONDAY_FIRST_END,
p_TUESDAY_FIRST_START  =>l_TUESDAY_FIRST_START,
p_TUESDAY_FIRST_END   =>l_TUESDAY_FIRST_END,
p_WEDNESDAY_FIRST_START =>l_WEDNESDAY_FIRST_START,
p_WEDNESDAY_FIRST_END  =>l_WEDNESDAY_FIRST_END ,
p_THURSDAY_FIRST_START  =>l_THURSDAY_FIRST_START ,
p_THURSDAY_FIRST_END  =>l_THURSDAY_FIRST_END,
p_FRIDAY_FIRST_START  =>l_FRIDAY_FIRST_START,
p_FRIDAY_FIRST_END  =>l_FRIDAY_FIRST_END ,
p_SATURDAY_FIRST_START =>l_SATURDAY_FIRST_START,
p_SATURDAY_FIRST_END  => l_SATURDAY_FIRST_END ,
p_SUNDAY_FIRST_START =>l_SUNDAY_FIRST_START ,
p_SUNDAY_FIRST_END  =>l_SUNDAY_FIRST_END   ,
p_MONDAY_SECOND_START => l_MONDAY_SECOND_START,
p_MONDAY_SECOND_END  =>l_MONDAY_SECOND_END  ,
p_TUESDAY_SECOND_START  =>l_TUESDAY_SECOND_START ,
p_TUESDAY_SECOND_END   =>l_TUESDAY_SECOND_END,
p_WEDNESDAY_SECOND_START =>l_WEDNESDAY_SECOND_START,
p_WEDNESDAY_SECOND_END  => l_WEDNESDAY_SECOND_END ,
p_THURSDAY_SECOND_START  =>l_THURSDAY_SECOND_START ,
p_THURSDAY_SECOND_END  => l_THURSDAY_SECOND_END ,
p_FRIDAY_SECOND_START  => l_FRIDAY_SECOND_START,
p_FRIDAY_SECOND_END  => l_FRIDAY_SECOND_END ,
p_SATURDAY_SECOND_START =>l_SATURDAY_SECOND_START ,
p_SATURDAY_SECOND_END  =>l_SATURDAY_SECOND_END  ,
p_SUNDAY_SECOND_START =>l_SUNDAY_SECOND_START ,
p_SUNDAY_SECOND_END  =>l_SUNDAY_SECOND_END  ,
p_DESCRIPTION => l_DESCRIPTION,
px_object_version_number => px_object_version_number,
p_commit                 => nvl(p_commit,fnd_Api.g_false),
x_return_status            => l_return_status,
x_msg_count                => l_msg_count,
x_msg_data                 => l_msg_data

    );

If l_return_status = fnd_api.g_ret_sts_error then
raise fnd_api.g_exc_error;
end if;

If l_return_status = fnd_api.g_ret_sts_unexp_error then
raise fnd_api.g_exc_unexpected_error;
end if;

 fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);


EXCEPTION
WHEN  fnd_api.g_exc_error then
ROLLBACK TO update_access_hours_pub;
x_return_status :=  fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  fnd_api.g_exc_unexpected_error then
ROLLBACK TO  update_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  OTHERS then
ROLLBACK TO  update_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);


END  UPDATE_ACCESS_HOURS;

PROCEDURE DELETE_ACCESS_HOURS(
    p_TASK_ID    NUMBER,
    p_ACCESS_HOUR_ID  NUMBER,
    p_API_VERSION NUMBER,
    p_init_msg_list varchar2 default null,
  --  p_commit in     varchar2 default fnd_api.g_false,
    x_return_status            OUT NOCOPY            VARCHAR2,
    x_msg_data                 OUT NOCOPY            VARCHAR2,
    x_msg_count                OUT NOCOPY            NUMBER)
 IS
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full constant varchar2(50) := 'CSF_ACCESS_HOURS_PUB.DELETE_ACCESS_HOURS';
     l_api_version CONSTANT Number := 1.0 ;
l_sta           varchar2(1);
l_cnt           number;
l_msg           varchar2(2000);
l_task_status varchar2(1);
l_temp          varchar2(1);

CURSOR C_EXISTS(p_task_id number) is select 'Y' from csf_access_hours_vl where task_id=p_task_id;

 BEGIN
SAVEPOINT delete_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_success;

IF NOT fnd_api.compatible_api_call (
l_api_version,
p_api_version,
l_api_name_full,
g_pkg_name
)
then
raise fnd_Api.g_exc_unexpected_error;
end if;

IF fnd_api.to_boolean( nvl(p_init_msg_list,fnd_Api.g_false)) then
fnd_msg_pub.initialize;
end if;

If p_task_id is NULL or p_ACCESS_HOUR_ID is NULL then
fnd_message.set_name ('CSF','CSF_ACCESS_INVALID_PARAMETER');--message required
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;

open c_exists(p_task_id);
fetch c_exists into l_temp;
 if c_exists%notfound then
   close c_exists;
   fnd_message.set_name('CSF','CSF_ACCESS_NO_ROW_EXISTS');
   fnd_msg_pub.add;
   raise fnd_api.g_exc_error;
 else
   close c_exists;
 end if;


check_parameters(
p_CALLING_ROUTINE => 'DELETE_ROW',
p_TASK_ID => p_TASK_ID,
x_return_status            => l_return_status,
x_msg_count                => l_msg_count,
x_msg_data                 => l_msg_data

);

If l_return_status = fnd_api.g_ret_sts_error then
raise fnd_api.g_exc_error;
end if;

If l_return_status = fnd_api.g_ret_sts_unexp_error then
raise fnd_Api.g_exc_unexpected_error;
end if;


CSF_ACCESS_HOURS_PVT.DELETE_ACCESS_HOURS(
p_API_VERSION => 1.0,
p_INIT_MSG_LIST => 'F',
p_ACCESS_HOUR_ID =>p_ACCESS_HOUR_ID,
p_commit =>fnd_api.g_true, --p_commit,--fnd_api.g_true,
x_return_status            => l_return_status,
x_msg_count                => l_msg_count,
x_msg_data                 => l_msg_data
);

 /*  If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
     end if;  */

  /* DELETE FROM CSF_ACCESS_HOURS_B
    WHERE ACCESS_HOUR_ID=p_ACCESS_HOUR_ID;*/

/*   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
       end if;*/

If l_return_status = fnd_api.g_ret_sts_error then
raise fnd_api.g_exc_error;
end if;

If l_return_status = fnd_api.g_ret_sts_unexp_error then
raise fnd_Api.g_exc_unexpected_error;
end if;

fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

 EXCEPTION
WHEN  fnd_api.g_exc_error then
ROLLBACK TO delete_access_hours_pub;
x_return_status :=  fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  fnd_api.g_exc_unexpected_error then
ROLLBACK TO  delete_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  OTHERS then
ROLLBACK TO  delete_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

 END DELETE_ACCESS_HOURS;

PROCEDURE update_access_hours(
    p_api_version           number
  , p_init_msg_list         varchar2
  , p_commit                varchar2
  , p_task_id               number
  , p_access_hour_reqd      varchar2
  , x_object_version_number in out nocopy number
  , x_return_status         out nocopy varchar2
  , x_msg_data              out nocopy varchar2
  , x_msg_count             out nocopy number
  )
IS
          l_api_name_full constant varchar2(50) := 'CSF_ACCESS_HOURS_PUB.UPDATE_ACCESS_HOURS-2';
          l_api_version CONSTANT Number := 1.0 ;
          l_return_status    varchar2(100);
          l_msg_count        NUMBER;
          l_msg_data         varchar2(2000);

cursor c_existing_values(p_task_id number) is
select
ACCESS_HOUR_ID,
ACCESSHOUR_REQUIRED,
AFTER_HOURS_FLAG,
DESCRIPTION,
object_version_number
from csf_access_hours_vl
where task_id=p_task_id;

l_rec c_existing_values%rowtype;
l_object_version_number number;
l_task_status varchar2(1);




BEGIN

SAVEPOINT update_access_hours_pub2;
x_return_status := fnd_api.g_ret_sts_success;

IF NOT fnd_api.compatible_api_call (
l_api_version,
p_api_version,
l_api_name_full,
g_pkg_name
)
then
raise fnd_Api.g_exc_unexpected_error;
end if;
IF fnd_api.to_boolean(nvl(p_init_msg_list,fnd_api.g_false)) then
fnd_msg_pub.initialize;
end if;


If p_task_id is NULL then
fnd_message.set_name ('CSF','CSF_ACCESS_INVALID_PARAMETER');--message required
fnd_msg_pub.add;
raise fnd_api.g_exc_error;
end if;



open c_existing_values(p_TASK_ID);
fetch c_existing_values into l_rec;
 if c_existing_values%notfound then
   close c_existing_values;
   fnd_message.set_name('CSF','CSF_ACCESS_NO_ROW_EXISTS');
   fnd_msg_pub.add;
   raise fnd_api.g_exc_error;
 end if;
close c_existing_values;

l_object_version_number := l_rec.object_version_number;

UPDATE_ACCESS_HOURS(
          p_ACCESS_HOUR_ID => l_rec.access_hour_id,
          p_TASK_ID  =>P_TASK_ID,
          p_API_VERSION =>l_api_version,
          p_init_msg_list =>nvl(p_init_msg_list,fnd_api.g_false),
          p_commit => nvl(p_commit,fnd_api.g_false),
          p_ACCESS_HOUR_REQD=>p_Access_hour_reqd ,
          p_AFTER_HOURS_FLAG=> l_rec.after_hours_flag,
          p_MONDAY_FIRST_START =>NULL,
          p_MONDAY_FIRST_END =>NULL,
          p_MONDAY_SECOND_START =>NULL,
          p_MONDAY_SECOND_END =>NULL,
          p_TUESDAY_FIRST_START =>NULL,
          p_TUESDAY_FIRST_END => NULL,
          p_TUESDAY_SECOND_START =>NULL,
          p_TUESDAY_SECOND_END => NULL,
          p_WEDNESDAY_FIRST_START => NULL,
          p_WEDNESDAY_FIRST_END =>NULL,
          p_WEDNESDAY_SECOND_START => NULL,
          p_WEDNESDAY_SECOND_END =>NULL,
          p_THURSDAY_FIRST_START =>NULL,
          p_THURSDAY_FIRST_END =>NULL,
          p_THURSDAY_SECOND_START =>NULL,
          p_THURSDAY_SECOND_END =>NULL,
          p_FRIDAY_FIRST_START =>NULL,
          p_FRIDAY_FIRST_END => NULL,
          p_FRIDAY_SECOND_START =>NULL,
          p_FRIDAY_SECOND_END =>NULL,
          p_SATURDAY_FIRST_START =>NULL,
          p_SATURDAY_FIRST_END =>NULL,
          p_SATURDAY_SECOND_START => NULL,
          p_SATURDAY_SECOND_END =>NULL,
          p_SUNDAY_FIRST_START =>NULL,
          p_SUNDAY_FIRST_END => NULL,
          p_SUNDAY_SECOND_START =>NULL,
          p_SUNDAY_SECOND_END =>NULL,
          p_DESCRIPTION=> l_rec.description,
          px_object_version_number=>l_object_version_number,
          x_return_status=>x_return_status,
	  x_msg_data => x_msg_data,
	  x_msg_count=> x_msg_count
   );
   x_object_version_number := l_object_version_number;

EXCEPTION
WHEN  fnd_api.g_exc_error then
ROLLBACK TO update_access_hours_pub2;
x_return_status :=  fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  fnd_api.g_exc_unexpected_error then
ROLLBACK TO  update_access_hours_pub2;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  OTHERS then
ROLLBACK TO  update_access_hours_pub2;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);


END UPDATE_ACCESS_HOURS;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  NULL;
END ADD_LANGUAGE;

--BEGIN
-- ADD SESSION INFO
 --g_user_id  := fnd_global.user_id;
 --g_login_id := fnd_global.login_id;

END CSF_ACCESS_HOURS_PUB;

/
