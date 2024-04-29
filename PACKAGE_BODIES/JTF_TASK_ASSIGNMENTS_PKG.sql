--------------------------------------------------------
--  DDL for Package Body JTF_TASK_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_ASSIGNMENTS_PKG" as
/* $Header: jtftkasb.pls 120.3.12010000.4 2010/04/20 09:09:32 anangupt ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TASK_ASSIGNMENT_ID in NUMBER,
  X_SCHED_TRAVEL_DURATION_UOM in VARCHAR2,
  X_ACTUAL_TRAVEL_DISTANCE in NUMBER,
  X_ACTUAL_TRAVEL_DURATION in NUMBER,
  X_ACTUAL_TRAVEL_DURATION_UOM in VARCHAR2,
  X_ACTUAL_START_DATE in DATE,
  X_ACTUAL_END_DATE in DATE,
  X_PALM_FLAG in VARCHAR2,
  X_WINCE_FLAG in VARCHAR2,
  X_LAPTOP_FLAG in VARCHAR2,
  X_DEVICE1_FLAG in VARCHAR2,
  X_DEVICE2_FLAG in VARCHAR2,
  X_DEVICE3_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_TASK_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_ACTUAL_EFFORT in NUMBER,
  X_ACTUAL_EFFORT_UOM in VARCHAR2,
  X_SCHEDULE_FLAG in VARCHAR2,
  X_ALARM_TYPE_CODE in VARCHAR2,
  X_ALARM_CONTACT in VARCHAR2,
  X_SCHED_TRAVEL_DISTANCE in NUMBER,
  X_SCHED_TRAVEL_DURATION in NUMBER,
  X_RESOURCE_TYPE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_RESOURCE_TERRITORY_ID in NUMBER,
  X_ASSIGNMENT_STATUS_ID in NUMBER,
  X_SHIFT_CONSTRUCT_ID in NUMBER,
  X_ASSIGNEE_ROLE in VARCHAR2,
  X_SHOW_ON_CALENDAR in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_FREE_BUSY_TYPE in VARCHAR2,
  X_BOOKING_START_DATE in DATE,
  X_BOOKING_END_DATE in DATE,
  X_OBJECT_CAPACITY_ID in NUMBER
) is
  cursor C is select ROWID from jtf_task_all_assignments
    where TASK_ASSIGNMENT_ID = X_TASK_ASSIGNMENT_ID ;

   x_return_status varchar2(1) ;
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_enable_audit          varchar2(5);
   l_assignee_role            jtf_task_all_assignments.assignee_role%TYPE
               := x_assignee_role;
begin
if l_assignee_role is null then
   l_assignee_role := 'ASSIGNEE';
end if;

-- Added by SBARAT on 27/01/2006 for bug# 4661006
jtf_task_assignments_pub.p_task_assignments_user_hooks:=NULL;

jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id:=x_task_assignment_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id:=x_task_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_type_code:=x_resource_type_code ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id:=x_resource_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_effort:=x_actual_effort ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_effort_uom:=x_actual_effort_uom ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.schedule_flag:=x_schedule_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.alarm_type_code:=x_alarm_type_code;
jtf_task_assignments_pub.p_task_assignments_user_hooks.alarm_contact:=x_alarm_contact ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.sched_travel_distance:=x_sched_travel_distance ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.sched_travel_duration:=x_sched_travel_duration ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.sched_travel_duration_uom:=x_sched_travel_duration_uom ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_travel_distance:=x_actual_travel_distance ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_travel_duration:=x_actual_travel_duration ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_travel_duration_uom:=x_actual_travel_duration_uom ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_start_date:=x_actual_start_date ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_end_date:=x_actual_end_date;
jtf_task_assignments_pub.p_task_assignments_user_hooks.palm_flag:=x_palm_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.wince_flag:=x_wince_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.laptop_flag:=x_laptop_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.device1_flag:=x_device1_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.device2_flag:=x_device2_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.device3_flag:=x_device3_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_territory_id:=x_resource_territory_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.assignment_status_id:=x_assignment_status_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.shift_construct_id:=x_shift_construct_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role:=l_assignee_role ;

-- Added by SBARAT on 22/02/2006 for bug# 4650129
jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_start_date:=x_booking_start_date;
jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_end_date:=x_booking_end_date;

jtf_task_assignments_iuhk.create_task_assignment_pre(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
l_enable_audit := Upper(nvl(fnd_profile.Value('JTF_TASK_ENABLE_AUDIT'),'Y'));
IF(l_enable_audit = 'Y') THEN
  jtf_task_assignment_audit_pkg.create_task_assignment_audit(
    p_api_version                 => 1,
    p_init_msg_list               => fnd_api.g_false,
    p_commit                      => fnd_api.g_false,
    p_object_version_number       => 1,
    p_task_id                     => x_task_id,
    p_task_assignment_id          => x_task_assignment_id,
    p_new_resource_type_code      => x_resource_type_code,
    p_new_resource_id             => x_resource_id,
    p_new_assignment_status       => x_assignment_status_id,
    p_new_actual_effort           => x_actual_effort,
    p_new_actual_effort_uom       => x_actual_effort_uom,
    p_new_res_territory_id        => x_resource_territory_id,
    p_new_assignee_role           => l_assignee_role,
    p_new_schedule_flag           => x_schedule_flag,
    p_new_alarm_type              => x_alarm_type_code,
    p_new_alarm_contact           => x_alarm_contact,
    p_new_update_status_flag      => null,
    p_new_show_on_cal_flag        => X_SHOW_ON_CALENDAR,
    p_new_category_id             => x_category_id,
    p_new_free_busy_type          => x_free_busy_type,
    p_new_booking_start_date      => x_booking_start_date,
    p_new_booking_end_date        => x_booking_end_date,
    p_new_actual_travel_distance  => x_actual_travel_distance,
    p_new_actual_travel_duration  => x_actual_travel_duration,
    p_new_actual_travel_DUR_UOM   => x_actual_travel_duration_uom,
    p_new_sched_travel_distance   => x_sched_travel_distance,
    p_new_sched_travel_duration   => x_sched_travel_duration,
    p_new_sched_travel_DUR_UOM    => x_sched_travel_duration_uom,
    p_new_actual_start_date       => x_actual_start_date,
    p_new_actual_end_date         => x_actual_end_date,
    x_return_status               => x_return_status,
    x_msg_count                   => l_msg_count,
    x_msg_data                    => l_msg_data
  );
END IF;


  insert into jtf_task_all_assignments (
    SCHED_TRAVEL_DURATION_UOM,
    ACTUAL_TRAVEL_DISTANCE,
    ACTUAL_TRAVEL_DURATION,
    ACTUAL_TRAVEL_DURATION_UOM,
    ACTUAL_START_DATE,
    ACTUAL_END_DATE,
    PALM_FLAG,
    WINCE_FLAG,
    LAPTOP_FLAG,
    DEVICE1_FLAG,
    DEVICE2_FLAG,
    DEVICE3_FLAG,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    TASK_ASSIGNMENT_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TASK_ID,
    RESOURCE_TYPE_CODE,
    RESOURCE_ID,
    ACTUAL_EFFORT,
    ACTUAL_EFFORT_UOM,
    SCHEDULE_FLAG,
    ALARM_TYPE_CODE,
    ALARM_CONTACT,
    SCHED_TRAVEL_DISTANCE,
    SCHED_TRAVEL_DURATION,
    OBJECT_VERSION_NUMBER,
    RESOURCE_TERRITORY_ID,
    ASSIGNMENT_STATUS_ID,
    SHIFT_CONSTRUCT_ID,
    ASSIGNEE_ROLE,
    SHOW_ON_CALENDAR,
    CATEGORY_ID,
    FREE_BUSY_TYPE,
    BOOKING_START_DATE,
    BOOKING_END_DATE,
    OBJECT_CAPACITY_ID
 ) values(
    X_SCHED_TRAVEL_DURATION_UOM,
    X_ACTUAL_TRAVEL_DISTANCE,
    X_ACTUAL_TRAVEL_DURATION,
    X_ACTUAL_TRAVEL_DURATION_UOM,
    X_ACTUAL_START_DATE,
    X_ACTUAL_END_DATE,
    X_PALM_FLAG,
    X_WINCE_FLAG,
    X_LAPTOP_FLAG,
    X_DEVICE1_FLAG,
    X_DEVICE2_FLAG,
    X_DEVICE3_FLAG,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_TASK_ASSIGNMENT_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_TASK_ID,
    X_RESOURCE_TYPE_CODE,
    X_RESOURCE_ID,
    X_ACTUAL_EFFORT,
    X_ACTUAL_EFFORT_UOM,
    X_SCHEDULE_FLAG,
    X_ALARM_TYPE_CODE,
    X_ALARM_CONTACT,
    X_SCHED_TRAVEL_DISTANCE,
    X_SCHED_TRAVEL_DURATION,
    1 ,
    X_RESOURCE_TERRITORY_ID,
    X_ASSIGNMENT_STATUS_ID,
    X_SHIFT_CONSTRUCT_ID,
    L_ASSIGNEE_ROLE,
    X_SHOW_ON_CALENDAR,
    X_CATEGORY_ID,
    X_FREE_BUSY_TYPE,
    X_BOOKING_START_DATE,
    X_BOOKING_END_DATE,
    X_OBJECT_CAPACITY_ID
    );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

jtf_task_assignments_iuhk.create_task_assignment_post(x_return_status );

  IF NOT (x_return_status = fnd_api.g_ret_sts_success)
  THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;


end INSERT_ROW;

procedure LOCK_ROW (
  X_TASK_ASSIGNMENT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c1 is select
        OBJECT_VERSION_NUMBER
    from jtf_task_all_assignments
    where TASK_ASSIGNMENT_ID = X_TASK_ASSIGNMENT_ID
    for update of TASK_ASSIGNMENT_ID nowait;
    tlinfo c1%rowtype ;

begin
	open c1;
	fetch c1 into tlinfo;
	if (c1%notfound) then
		close c1;
		fnd_message.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
		fnd_msg_pub.add;
		app_exception.raise_exception;
	 end if;
	 close c1;

  if (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
    fnd_msg_pub.add;
    app_exception.raise_exception;
  end if;


end LOCK_ROW;

procedure UPDATE_ROW (
  X_TASK_ASSIGNMENT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SCHED_TRAVEL_DURATION_UOM in VARCHAR2,
  X_ACTUAL_TRAVEL_DISTANCE in NUMBER,
  X_ACTUAL_TRAVEL_DURATION in NUMBER,
  X_ACTUAL_TRAVEL_DURATION_UOM in VARCHAR2,
  X_ACTUAL_START_DATE in DATE,
  X_ACTUAL_END_DATE in DATE,
  X_PALM_FLAG in VARCHAR2,
  X_WINCE_FLAG in VARCHAR2,
  X_LAPTOP_FLAG in VARCHAR2,
  X_DEVICE1_FLAG in VARCHAR2,
  X_DEVICE2_FLAG in VARCHAR2,
  X_DEVICE3_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_TASK_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_ACTUAL_EFFORT in NUMBER,
  X_ACTUAL_EFFORT_UOM in VARCHAR2,
  X_SCHEDULE_FLAG in VARCHAR2,
  X_ALARM_TYPE_CODE in VARCHAR2,
  X_ALARM_CONTACT in VARCHAR2,
  X_SCHED_TRAVEL_DISTANCE in NUMBER,
  X_SCHED_TRAVEL_DURATION in NUMBER,
  X_RESOURCE_TYPE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_RESOURCE_TERRITORY_ID in NUMBER,
  X_ASSIGNMENT_STATUS_ID in NUMBER,
  X_SHIFT_CONSTRUCT_ID in NUMBER,
  X_ASSIGNEE_ROLE in VARCHAR2,
  X_SHOW_ON_CALENDAR in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_FREE_BUSY_TYPE in VARCHAR2,
  X_BOOKING_START_DATE in DATE,
  X_BOOKING_END_DATE in DATE,
  X_OBJECT_CAPACITY_ID in NUMBER
  ) is
x_return_status         varchar2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_enable_audit          varchar2(5);
l_assignee_role            jtf_task_all_assignments.assignee_role%TYPE
               := x_assignee_role;
begin
if l_assignee_role is null or l_assignee_role = fnd_api.g_miss_char then
   l_assignee_role := 'ASSIGNEE';
end if;

-- Added by SBARAT on 27/01/2006 for bug# 4661006
jtf_task_assignments_pub.p_task_assignments_user_hooks:=NULL;

jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id:=x_task_assignment_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id:=x_task_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_type_code:=x_resource_type_code ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id:=x_resource_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_effort:=x_actual_effort ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_effort_uom:=x_actual_effort_uom ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.schedule_flag:=x_schedule_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.alarm_type_code:=x_alarm_type_code;
jtf_task_assignments_pub.p_task_assignments_user_hooks.alarm_contact:=x_alarm_contact ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.sched_travel_distance:=x_sched_travel_distance ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.sched_travel_duration:=x_sched_travel_duration ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.sched_travel_duration_uom:=x_sched_travel_duration_uom ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_travel_distance:=x_actual_travel_distance ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_travel_duration:=x_actual_travel_duration ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_travel_duration_uom:=x_actual_travel_duration_uom ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_start_date:=x_actual_start_date ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.actual_end_date:=x_actual_end_date;
jtf_task_assignments_pub.p_task_assignments_user_hooks.palm_flag:=x_palm_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.wince_flag:=x_wince_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.laptop_flag:=x_laptop_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.device1_flag:=x_device1_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.device2_flag:=x_device2_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.device3_flag:=x_device3_flag ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_territory_id:=x_resource_territory_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.assignment_status_id:=x_assignment_status_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.shift_construct_id:=x_shift_construct_id ;
jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role:=l_assignee_role ;

-- Added by SBARAT on 22/02/2006 for bug# 4650129
jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_start_date:=x_booking_start_date;
jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_end_date:=x_booking_end_date;

jtf_task_assignments_iuhk.update_task_assignment_pre(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

l_enable_audit := Upper(nvl(fnd_profile.Value('JTF_TASK_ENABLE_AUDIT'),'Y'));
IF(l_enable_audit = 'Y') THEN
  jtf_task_assignment_audit_pkg.create_task_assignment_audit(
    p_api_version                 => 1,
    p_init_msg_list              => fnd_api.g_false,
    p_commit                      => fnd_api.g_false,
    p_object_version_number       => 1,
    p_task_id                     => x_task_id,
    p_task_assignment_id          => x_task_assignment_id,
    p_new_resource_type_code      => x_resource_type_code,
    p_new_resource_id             => x_resource_id,
    p_new_assignment_status       => x_assignment_status_id,
    p_new_actual_effort           => x_actual_effort,
    p_new_actual_effort_uom       => x_actual_effort_uom,
    p_new_res_territory_id        => x_resource_territory_id,
    p_new_assignee_role           => l_assignee_role,
    p_new_schedule_flag           => x_schedule_flag,
    p_new_alarm_type              => x_alarm_type_code,
    p_new_alarm_contact           => x_alarm_contact,
    p_new_update_status_flag      => null,
    p_new_show_on_cal_flag        => X_SHOW_ON_CALENDAR,
    p_new_category_id             => x_category_id,
    p_new_free_busy_type          => x_free_busy_type,
    p_new_booking_start_date      => x_booking_start_date,
    p_new_booking_end_date        => x_booking_end_date,
    p_new_actual_travel_distance  => x_actual_travel_distance,
    p_new_actual_travel_duration  => x_actual_travel_duration,
    p_new_actual_travel_DUR_UOM   => x_actual_travel_duration_uom,
    p_new_sched_travel_distance   => x_sched_travel_distance,
    p_new_sched_travel_duration   => x_sched_travel_duration,
    p_new_sched_travel_DUR_UOM    => x_sched_travel_duration_uom,
    p_new_actual_start_date       => x_actual_start_date,
    p_new_actual_end_date         => x_actual_end_date,
    x_return_status               => x_return_status,
    x_msg_count                   => l_msg_count,
    x_msg_data                    => l_msg_data
  );
END IF;


  update jtf_task_all_assignments set
    SCHED_TRAVEL_DURATION_UOM = X_SCHED_TRAVEL_DURATION_UOM,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ACTUAL_TRAVEL_DISTANCE = X_ACTUAL_TRAVEL_DISTANCE,
    ACTUAL_TRAVEL_DURATION = X_ACTUAL_TRAVEL_DURATION,
    ACTUAL_TRAVEL_DURATION_UOM = X_ACTUAL_TRAVEL_DURATION_UOM,
    ACTUAL_START_DATE = X_ACTUAL_START_DATE,
    ACTUAL_END_DATE = X_ACTUAL_END_DATE,
    PALM_FLAG = X_PALM_FLAG,
    WINCE_FLAG = X_WINCE_FLAG,
    LAPTOP_FLAG = X_LAPTOP_FLAG,
    DEVICE1_FLAG = X_DEVICE1_FLAG,
    DEVICE2_FLAG = X_DEVICE2_FLAG,
    DEVICE3_FLAG = X_DEVICE3_FLAG,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    TASK_ID = X_TASK_ID,
    RESOURCE_ID = X_RESOURCE_ID,
    ACTUAL_EFFORT = X_ACTUAL_EFFORT,
    ACTUAL_EFFORT_UOM = X_ACTUAL_EFFORT_UOM,
    SCHEDULE_FLAG = X_SCHEDULE_FLAG,
    ALARM_TYPE_CODE = X_ALARM_TYPE_CODE,
    ALARM_CONTACT = X_ALARM_CONTACT,
    SCHED_TRAVEL_DISTANCE = X_SCHED_TRAVEL_DISTANCE,
    SCHED_TRAVEL_DURATION = X_SCHED_TRAVEL_DURATION,
    RESOURCE_TYPE_CODE = X_RESOURCE_TYPE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    RESOURCE_TERRITORY_ID = X_RESOURCE_TERRITORY_ID,
    ASSIGNMENT_STATUS_ID = X_ASSIGNMENT_STATUS_ID,
    SHIFT_CONSTRUCT_ID  = X_SHIFT_CONSTRUCT_ID,
    ASSIGNEE_ROLE = L_ASSIGNEE_ROLE,
    SHOW_ON_CALENDAR = decode(X_SHOW_ON_CALENDAR,fnd_api.g_miss_char,SHOW_ON_CALENDAR,X_SHOW_ON_CALENDAR),
    CATEGORY_ID = decode(X_CATEGORY_ID ,fnd_api.g_miss_num,category_id,x_category_id ),
    FREE_BUSY_TYPE = X_FREE_BUSY_TYPE,
    BOOKING_START_DATE = X_BOOKING_START_DATE,
    BOOKING_END_DATE  = X_BOOKING_END_DATE,
    OBJECT_CAPACITY_ID = X_OBJECT_CAPACITY_ID
  where TASK_ASSIGNMENT_ID = X_TASK_ASSIGNMENT_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

jtf_task_assignments_iuhk.update_task_assignment_post(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


end UPDATE_ROW;

procedure DELETE_ROW (
  X_TASK_ASSIGNMENT_ID in NUMBER
) is
x_return_status         varchar2(1);
l_enable_audit          varchar2(5);
begin

-- Added by SBARAT on 27/01/2006 for bug# 4661006
jtf_task_assignments_pub.p_task_assignments_user_hooks:=NULL;

  jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id:=x_task_assignment_id ;
  jtf_task_assignments_iuhk.delete_task_assignment_pre(x_return_status );
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
  delete from jtf_task_all_assignments
  where TASK_ASSIGNMENT_ID = X_TASK_ASSIGNMENT_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  l_enable_audit := Upper(nvl(fnd_profile.Value('JTF_TASK_ENABLE_AUDIT'),'Y'));
  IF(l_enable_audit = 'Y') THEN
    jtf_task_assignment_audit_pkg.DELETE_ROW(
      X_ASSIGNMENT_ID =>x_task_assignment_id
    );
  END IF;

  jtf_task_assignments_iuhk.delete_task_assignment_post(x_return_status );
    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

end DELETE_ROW;
end ;

/
