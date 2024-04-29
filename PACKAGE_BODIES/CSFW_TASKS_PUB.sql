--------------------------------------------------------
--  DDL for Package Body CSFW_TASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_TASKS_PUB" AS
/*$Header: csfwtaskb.pls 120.20.12010000.4 2010/05/29 06:30:12 shadas ship $*/

-- Bug # 4570867
-- Added this function to check a task type is of DISPATCH rule or not
FUNCTION has_field_service_rule (p_task_type_id NUMBER)
 RETURN BOOLEAN IS
 CURSOR c_task_type IS
   SELECT task_type_id
     FROM jtf_task_types_b
    WHERE rule = 'DISPATCH'
      AND NVL (schedule_flag, 'N') = 'Y'
      AND task_type_id = p_task_type_id;
BEGIN
 FOR v_task_type IN c_task_type LOOP
   RETURN TRUE;
 END LOOP;
 RETURN FALSE;
END has_field_service_rule;

PROCEDURE GET_FOLLOW_UP_TASK_DETAILS
  ( p_task_id        IN  NUMBER
  , x_error_id       OUT NOCOPY NUMBER
  , x_error          OUT NOCOPY VARCHAR2
  , x_task_name      OUT NOCOPY varchar2
  , x_status_id      OUT NOCOPY number
  , x_priority_id    OUT NOCOPY number
  , x_customer_name  OUT NOCOPY varchar2
  , x_request_number OUT NOCOPY varchar2
  , x_planned_effort_uom OUT NOCOPY varchar2
  )
IS
l_task_table_type       jtf_tasks_pub.task_table_type;
l_total_retrieved       number;
l_total_returned        number;
l_return_status         varchar2(1);
l_msg_count             number;
l_msg_data              varchar2(2000);
l_object_version_number number;

l_task_rec              jtf_tasks_pub.task_rec;
l_sort_data             jtf_tasks_pub.sort_rec ;
l_sort_table            jtf_tasks_pub.sort_data ;


CURSOR c_version (v_task_id NUMBER)
IS
select object_version_number from jtf_tasks_b where task_id = v_task_id;


BEGIN

x_error_id := 0; --Assume success

--select the object version number
open c_version(p_task_id);
fetch c_version into l_object_version_number;
close c_version;
--select object_version_number into l_object_version_number from jtf_tasks_b where task_id = p_task_id;


l_sort_data.field_name  := 'TASK_NUMBER'; -- this is redundant as we are passing the primary key
l_sort_table (1)        := l_sort_data;

jtf_tasks_pub.query_task
    (
    p_api_version               => 1.0,
    p_task_id                   => p_task_id,
    p_sort_data                 => l_sort_table,
    p_start_pointer             => 1,
    p_rec_wanted                => 1,
    p_show_all                  => 'Y',
    x_task_table                => l_task_table_type ,
    x_total_retrieved           => l_total_retrieved,
    x_total_returned            => l_total_returned,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data,
    x_object_version_number     => l_object_version_number
    );


   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		/* API-call was successfull */
		x_error_id := 0;
		x_error := FND_API.G_RET_STS_SUCCESS;

		-- get the record from table
		l_task_rec := l_task_table_type(1);

		-- Now that we have the Table
		x_task_name      := nvl(l_task_rec.task_name, '');
		x_status_id      := nvl(l_task_rec.task_status_id, 0);
		x_priority_id    := nvl(l_task_rec.task_priority_id, 0);
		x_customer_name  := nvl(l_task_rec.customer_name, '');
		x_request_number := nvl(l_task_rec.obect_name, '');
		x_planned_effort_uom := l_task_rec.planned_effort_uom;
   ELSE
      x_error_id := 1;
      x_error := 'Unexpected Error while Calling the API' ;
   END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    x_error_id := -1;
    x_error := SQLERRM;

END GET_FOLLOW_UP_TASK_DETAILS;

PROCEDURE CREATE_FOLLOW_UP_TASK
  ( p_task_id            IN  NUMBER
  , p_task_name          IN  VARCHAR2
  , p_status_id          IN  NUMBER
  , p_priority_id        IN  NUMBER
  , p_Planned_Start_date IN  DATE
  , p_Planned_End_date   IN  DATE
  , p_planned_effort     IN  NUMBER
  , p_planned_effort_uom IN VARCHAR2
  , p_notes              IN VARCHAR2
  , x_error_id           OUT NOCOPY NUMBER
  , x_error              OUT NOCOPY VARCHAR2
  , x_follow_up_task_id  OUT NOCOPY NUMBER
  , p_note_type          IN  VARCHAR2
  , p_note_status        IN VARCHAR2
 , p_attribute_1	IN VARCHAR2
 , p_attribute_2	IN VARCHAR2
 , p_attribute_3	IN VARCHAR2
 , p_attribute_4	IN VARCHAR2
 , p_attribute_5	IN VARCHAR2
 , p_attribute_6	IN VARCHAR2
 , p_attribute_7	IN VARCHAR2
 , p_attribute_8	IN VARCHAR2
 , p_attribute_9	IN VARCHAR2
 , p_attribute_10	IN VARCHAR2
 , p_attribute_11	IN VARCHAR2
 , p_attribute_12	IN VARCHAR2
 , p_attribute_13	IN VARCHAR2
 , p_attribute_14	IN VARCHAR2
 , p_attribute_15	IN VARCHAR2
 , p_context		IN VARCHAR2
  ) IS

l_task_id number;
l_task_table_type              jtf_tasks_pub.task_table_type;
l_num_rec                      number;
l_total_retrieved              number;
l_total_returned               number;
l_return_status                varchar2(1);
l_msg_count                    number;
l_msg_data                     varchar2(2000);
l_object_version_number        number;
l_data                         varchar2(255);
l_task_rec                     jtf_tasks_pub.task_rec;
l_sort_data                    jtf_tasks_pub.sort_rec ;
l_sort_table                   jtf_tasks_pub.sort_data ;
l_planned_start_date           date;
l_planned_end_date             date;
L_PLANNED_EFFORT               number;
L_PLANNED_EFFORT_UOM           varchar2(10);
l_msg_index_out                number;
l_task_notes_rec               jtf_tasks_pub.task_notes_rec;
l_task_notes_tbl               jtf_tasks_pub.task_notes_tbl;
l_organization_id              NUMBER;
l_note_type                    varchar2(30);
l_note_status                  varchar2(1);
l_acc_hrs_exist_current        varchar2(1);
l_acc_hrs_exist_new            varchar2(1);
l_access_hrs_id                number;
l_tmp_task_owner               number;             -- bug # 4724278
l_tmp_task_owner_type          varchar2(30);       -- bug # 4724278

CURSOR c_resource_id (v_user_id NUMBER)
IS
 select resource_id
  from jtf_rs_resource_extns
  where user_id = v_user_id;

CURSOR c_resource_type (v_resource_id NUMBER)
IS
select decode(category, 'EMPLOYEE', 'RS_EMPLOYEE',
      'PARTNER', 'RS_PARTNER',
      'SUPPLIER_CONTACT', 'RS_SUPPLIER_CONTACT',
      'OTHER', 'RS_OTHER',
      'PARTY', 'RS_PARTY',
      'TBH', 'RS_TBH',
      'VENUE', 'RS_VENUE', category)
  from JTF_RS_RESOURCE_EXTNS
 where resource_id = v_resource_id ;

cursor c_check_valid_resource (v_resource_id number, v_resource_type varchar2)
is
  select count(*) from jtf_task_resources_vl
  where resource_id = v_resource_id and resource_type = v_resource_type;

l_check_valid_resource number;

CURSOR FIND_SKILL (V_TASK_ID NUMBER) IS
SELECT
SKILL_TYPE_ID
, SKILL_ID
, SKILL_LEVEL_ID , DISABLED_FLAG
FROM CSF_REQUIRED_SKILLS_B
WHERE HAS_SKILL_TYPE = 'TASK'
  AND HAS_SKILL_ID = V_TASK_ID;

R_FIND_SKILL FIND_SKILL%ROWTYPE;

CURSOR C_CST_ACCESS_HRS_EXISTS(v_task_id number) is select 'Y' from csf_access_hours_vl where task_id=v_task_id;
CURSOR C_CST_ACCESS_HRS(v_task_id number) IS select * from CSF_ACCESS_HOURS_VL where task_id = v_task_id;

R_CST_HRS C_CST_ACCESS_HRS%ROWTYPE;

CURSOR c_task_location (v_task_id NUMBER)
IS
Select address_id,
       location_id
  from jtf_tasks_b
 where task_id = v_task_id ;

r_task_location c_task_location%ROWTYPE;

begin
l_task_id                   := p_task_id;
l_object_version_number     := 1;
l_sort_data.field_name      := 'TASK_NUMBER';
l_sort_table (1)            := l_sort_data;

l_planned_start_date        := p_Planned_Start_date;
l_planned_end_date          := p_Planned_End_date;
L_PLANNED_EFFORT            := p_planned_effort;
L_PLANNED_EFFORT_UOM        := p_planned_effort_uom;



-- Lets Query The Task
jtf_tasks_pub.query_task
    (
    p_api_version               => 1.0,
    p_task_id                   => l_task_id,
    p_sort_data                 => l_sort_table,
    p_start_pointer             => 1,
    p_rec_wanted                => 1,
    p_show_all                  => 'Y',
    x_task_table                => l_task_table_type ,
    x_total_retrieved           => l_total_retrieved,
    x_total_returned            => l_total_returned,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data,
    x_object_version_number     => l_object_version_number
    );

	IF l_return_status = FND_API.G_RET_STS_SUCCESS
          THEN
		/* API-call was successfull */
		x_error_id := 0;
		x_error := FND_API.G_RET_STS_SUCCESS;
		l_task_rec := l_task_table_type(1);

--notes
if p_notes <> '$$#@'
then
    if p_note_type is null then
       l_note_type := 'KB_FACT';
    else
       l_note_type := p_note_type;
    end if;

    if p_note_status is null then
       l_note_status := 'I';
    else
       l_note_status := p_note_status;
    end if;



	FND_PROFILE.GET ( 'CS_INV_VALIDATION_ORG' , l_organization_id);
	l_task_notes_rec.org_id		 := l_organization_id;
	l_task_notes_rec.notes		 := p_notes;
	l_task_notes_rec.note_status	 := l_note_status;
	l_task_notes_rec.entered_by	 := FND_GLOBAL.user_id;
	l_task_notes_rec.entered_date	 := sysdate;
	l_task_notes_rec.note_type       := l_note_type;
	l_task_notes_tbl (1)             := l_task_notes_rec;

else
	l_task_notes_tbl := jtf_tasks_pub.g_miss_task_notes_tbl;
end if;

   -- bug # 4724278
   -- Use Task Manager profile for Task Owner details
   -- l_tmp_task_owner := -1;
   FND_PROFILE.GET('JTF_TASK_DEFAULT_OWNER', l_tmp_task_owner);
   FND_PROFILE.GET('JTF_TASK_DEFAULT_OWNER_TYPE', l_tmp_task_owner_type);

   open c_check_valid_resource (l_tmp_task_owner, l_tmp_task_owner_type);
   fetch c_check_valid_resource into l_check_valid_resource;
   close c_check_valid_resource;

   IF l_tmp_task_owner IS NULL
      or l_tmp_task_owner_type is null
      or l_check_valid_resource is null
      or l_check_valid_resource <> 1 THEN

      -- resource id
      open c_resource_id (FND_GLOBAL.USER_ID);
      fetch c_resource_id into l_tmp_task_owner;
      close c_resource_id;

      -- resource type
      open c_resource_type (l_tmp_task_owner);
      fetch c_resource_type into l_tmp_task_owner_type;
      close c_resource_type;
   END IF;

   -- Address/location
   open c_task_location (l_task_id);
   fetch c_task_location into r_task_location;
   close c_task_location;


			-- bug # 4570867
			-- use csf_task_pub instead of jtf_task_pub
			csf_tasks_pub.create_task (
				p_api_version             => 1.0,
				p_commit                  => fnd_api.g_true,
				p_task_name               => p_task_name ,
				p_task_type_name          => l_task_rec.task_type,
				p_task_type_id            => l_task_rec.task_type_id,
				p_description             => null,
				p_task_status_id          => p_status_id,
				p_task_priority_id        => p_priority_id,
				p_owner_type_code         => l_tmp_task_owner_type,   -- bug # 4724278
				p_owner_id                => l_tmp_task_owner,        -- bug # 4724278
				-- p_owner_territory_id      => l_task_rec.owner_territory_id,
				p_customer_number         => l_task_rec.customer_number,
				p_customer_id             => l_task_rec.customer_id,
				p_cust_account_number     => l_task_rec.cust_account_number,
				p_cust_account_id         => l_task_rec.cust_account_id,
				p_address_id              => r_task_location.address_id,
				p_location_id             => r_task_location.location_id,
				p_planned_start_date      => l_planned_Start_Date,
				p_planned_end_date        => l_planned_End_Date,
				p_source_object_type_code => l_task_rec.object_type_code,
				p_source_object_id        => l_task_rec.object_id,
				p_source_object_name      => l_task_rec.obect_name,
				p_planned_effort          => L_PLANNED_EFFORT,
				p_planned_effort_uom      => L_PLANNED_EFFORT_UOM,
				p_percentage_complete     => l_task_rec.percentage_complete,
				p_reason_code             => l_task_rec.reason_code,
				p_private_flag            => l_task_rec.private_flag,
				p_publish_flag            => l_task_rec.publish_flag,
				p_multi_booked_flag       => l_task_rec.multi_booked_flag,
				p_milestone_flag          => l_task_rec.milestone_flag,
				p_holiday_flag            => l_task_rec.holiday_flag,
				p_workflow_process_id     => l_task_rec.workflow_process_id,
				p_notification_flag       => l_task_rec.notification_flag,
				p_notification_period     => l_task_rec.notification_period,
				p_notification_period_uom => l_task_rec.notification_period_uom,
				p_alarm_start             => l_task_rec.alarm_start,
				p_alarm_start_uom         => l_task_rec.alarm_start_uom,
				p_alarm_on                => l_task_rec.alarm_on,
				p_alarm_count             => l_task_rec.alarm_count,
				p_alarm_interval          => l_task_rec.alarm_interval,
				p_alarm_interval_uom      => l_task_rec.alarm_interval_uom,
				p_escalation_level        => l_task_rec.escalation_level,
				p_task_notes_tbl          => l_task_notes_tbl ,
				x_return_status           => l_return_status,
				x_msg_count               => l_msg_count,
				x_msg_data                => l_msg_data,
				x_task_id                 => x_follow_up_task_id,
				p_attribute1              => p_attribute_1,
				p_attribute2              => p_attribute_2,
				p_attribute3              => p_attribute_3,
				p_attribute4              => p_attribute_4,
				p_attribute5              => p_attribute_5,
				p_attribute6              => p_attribute_6,
				p_attribute7              => p_attribute_7,
				p_attribute8              => p_attribute_8,
				p_attribute9              => p_attribute_9,
				p_attribute10             => p_attribute_10,
				p_attribute11             => p_attribute_11,
				p_attribute12             => p_attribute_12,
				p_attribute13             => p_attribute_13,
				p_attribute14             => p_attribute_14,
				p_attribute15             => p_attribute_15,
				p_attribute_category      => p_context,
				p_date_selected           => l_task_rec.date_selected
			    );

			IF l_return_status = FND_API.G_RET_STS_SUCCESS
			THEN
				/* API-call was successfull */
				x_error_id := 0;
				x_error := FND_API.G_RET_STS_SUCCESS;

				--ADding up skills (Bug 3290577)

           FOR R_FIND_SKILL IN FIND_SKILL (l_task_id)
               LOOP
                   CSF_REQUIRED_SKILLS_PKG.CREATE_ROW
                   ( P_API_VERSION      => 1.0
                   , P_INIT_MSG_LIST    => FND_API.G_FALSE
                   , P_COMMIT           => fnd_api.g_true
                   , P_VALIDATION_LEVEL => 100
                   , X_RETURN_STATUS    => l_return_status
                   , X_MSG_COUNT        => L_MSG_COUNT
                   , X_MSG_DATA         => L_MSG_DATA
                   , P_TASK_ID          => x_follow_up_task_id
                   , P_SKILL_TYPE_ID    => R_FIND_SKILL.SKILL_TYPE_ID
                   , P_SKILL_ID         => R_FIND_SKILL.SKILL_ID
                   , P_SKILL_LEVEL_ID   => R_FIND_SKILL.SKILL_LEVEL_ID);


                   -- ERROR PROCESSING IF THERE ARE ANY ERRORS WHILE CALLING THE API

                   IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           x_error_id := 0;
                           x_error := FND_API.G_RET_STS_SUCCESS;
                           /*
                           lets update the row with the disable flag
                           This is a temporary fix as there is no API from CSF_SKILL
                           to update the row or set the DISABLE_FLAG while creating
                           To be removed once that is in. A bug is filed (# 3292940)
                           */
                           IF (R_FIND_SKILL.DISABLED_FLAG = 'Y') THEN
                            UPDATE CSF_REQUIRED_SKILLS_B
                               SET DISABLED_FLAG = 'Y'
                             WHERE SKILL_ID = R_FIND_SKILL.SKILL_ID
                               AND HAS_SKILL_ID = x_follow_up_task_id
                               AND SKILL_TYPE_ID = R_FIND_SKILL.SKILL_TYPE_ID
                               AND SKILL_LEVEL_ID = R_FIND_SKILL.SKILL_LEVEL_ID;

                           END IF;
                           commit work;
                   ELSE
                           FOR l_counter IN 1 .. l_msg_count
                           LOOP
                                 fnd_msg_pub.get
                                   ( p_msg_index     => l_counter
                                   , p_encoded       => FND_API.G_FALSE
                                   , p_data          => l_data
                                   , p_msg_index_out => l_msg_index_out
                                   );
                                 --dbms_output.put_line( 'Message: '||l_data );
                           END LOOP ;
                           x_error_id := 22;
                           x_error := l_data;
                   END IF;
               END LOOP;

               -- copy customer access hours
               -- check if current task has access hours.
               open C_CST_ACCESS_HRS_EXISTS(l_task_id);
               fetch C_CST_ACCESS_HRS_EXISTS into l_acc_hrs_exist_current;
	       if C_CST_ACCESS_HRS_EXISTS%notfound then
                   l_acc_hrs_exist_current := 'N';
               end if;
	       close C_CST_ACCESS_HRS_EXISTS;

               -- check if new follow-up task has access hours.
               open C_CST_ACCESS_HRS_EXISTS(x_follow_up_task_id);
               fetch C_CST_ACCESS_HRS_EXISTS into l_acc_hrs_exist_new;
	       if C_CST_ACCESS_HRS_EXISTS%notfound then
                   l_acc_hrs_exist_new := 'N';
               end if;
	       close C_CST_ACCESS_HRS_EXISTS;

               if l_acc_hrs_exist_current='Y' and l_acc_hrs_exist_new='N' then
                  -- copy access hours
                  FOR R_CST_HRS in C_CST_ACCESS_HRS(l_task_id)
                  LOOP
                     CSF_ACCESS_HOURS_PUB.CREATE_ACCESS_HOURS(
                        x_ACCESS_HOUR_ID => l_access_hrs_id,
                        p_API_VERSION => 1.0,
                        p_init_msg_list => 'F',
                        p_TASK_ID    => x_follow_up_task_id,
                        p_ACCESS_HOUR_REQD => R_CST_HRS.ACCESSHOUR_REQUIRED,
                        p_AFTER_HOURS_FLAG => R_CST_HRS.AFTER_HOURS_FLAG,
                        p_MONDAY_FIRST_START => R_CST_HRS.MONDAY_FIRST_START,
                        p_MONDAY_FIRST_END => R_CST_HRS.MONDAY_FIRST_END,
                        p_MONDAY_SECOND_START => R_CST_HRS.MONDAY_SECOND_START,
                        p_MONDAY_SECOND_END => R_CST_HRS.MONDAY_SECOND_END,
                        p_TUESDAY_FIRST_START => R_CST_HRS.TUESDAY_FIRST_START,
                        p_TUESDAY_FIRST_END => R_CST_HRS.TUESDAY_FIRST_END,
                        p_TUESDAY_SECOND_START => R_CST_HRS.TUESDAY_SECOND_START,
                        p_TUESDAY_SECOND_END => R_CST_HRS.TUESDAY_SECOND_END,
                        p_WEDNESDAY_FIRST_START => R_CST_HRS.WEDNESDAY_FIRST_START,
                        p_WEDNESDAY_FIRST_END => R_CST_HRS.WEDNESDAY_FIRST_END,
                        p_WEDNESDAY_SECOND_START => R_CST_HRS.WEDNESDAY_SECOND_START,
                        p_WEDNESDAY_SECOND_END => R_CST_HRS.WEDNESDAY_SECOND_END,
                        p_THURSDAY_FIRST_START => R_CST_HRS.THURSDAY_FIRST_START,
                        p_THURSDAY_FIRST_END => R_CST_HRS.THURSDAY_FIRST_END,
                        p_THURSDAY_SECOND_START => R_CST_HRS.THURSDAY_SECOND_START,
                        p_THURSDAY_SECOND_END => R_CST_HRS.THURSDAY_SECOND_END,
                        p_FRIDAY_FIRST_START => R_CST_HRS.FRIDAY_FIRST_START,
                        p_FRIDAY_FIRST_END => R_CST_HRS.FRIDAY_FIRST_END,
                        p_FRIDAY_SECOND_START => R_CST_HRS.FRIDAY_SECOND_START,
                        p_FRIDAY_SECOND_END => R_CST_HRS.FRIDAY_SECOND_END,
                        p_SATURDAY_FIRST_START => R_CST_HRS.SATURDAY_FIRST_START,
                        p_SATURDAY_FIRST_END => R_CST_HRS.SATURDAY_FIRST_END,
                        p_SATURDAY_SECOND_START => R_CST_HRS.SATURDAY_SECOND_START,
                        p_SATURDAY_SECOND_END => R_CST_HRS.SATURDAY_SECOND_END,
                        p_SUNDAY_FIRST_START => R_CST_HRS.SUNDAY_FIRST_START,
                        p_SUNDAY_FIRST_END => R_CST_HRS.SUNDAY_FIRST_END,
                        p_SUNDAY_SECOND_START => R_CST_HRS.SUNDAY_SECOND_START,
                        p_SUNDAY_SECOND_END => R_CST_HRS.SUNDAY_SECOND_END,
                        p_DESCRIPTION => R_CST_HRS.DESCRIPTION,
                        px_object_version_number => l_object_version_number,
                        p_CREATED_BY  => FND_GLOBAL.user_id,
                        p_CREATION_DATE => sysdate,
                        p_LAST_UPDATED_BY    =>  FND_GLOBAL.user_id,
                        p_LAST_UPDATE_DATE    => sysdate,
                        p_LAST_UPDATE_LOGIN    => FND_GLOBAL.user_id,
                        x_return_status => l_return_status,
                        x_msg_data => l_msg_data,
                        x_msg_count => l_msg_count
                        );

                        IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           x_error_id := 0;
                           x_error := FND_API.G_RET_STS_SUCCESS;
                        ELSE
                           FOR l_counter IN 1 .. l_msg_count
                           LOOP
                                 fnd_msg_pub.get
                                   ( p_msg_index     => l_counter
                                   , p_encoded       => FND_API.G_FALSE
                                   , p_data          => l_data
                                   , p_msg_index_out => l_msg_index_out
                                   );
                           END LOOP ;
                           x_error_id := 22;
                           x_error := l_data;
                        END IF;

                  END LOOP;
               end if;

			ELSE
				FOR l_counter IN 1 .. l_msg_count
				LOOP
				      fnd_msg_pub.get
					( p_msg_index     => l_counter
					, p_encoded       => FND_API.G_FALSE
					, p_data          => l_data
					, p_msg_index_out => l_msg_index_out
					);
				      --dbms_output.put_line( 'Message: '||l_data );
				END LOOP ;
				x_error_id := 2;
				x_error := l_data;
				x_follow_up_task_id := 0; -- no tasks
			END IF;

	ELSE
            FOR l_counter IN 1 .. l_msg_count
            LOOP
                      fnd_msg_pub.get
                        ( p_msg_index     => l_counter
                        , p_encoded       => FND_API.G_FALSE
                        , p_data          => l_data
                        , p_msg_index_out => l_msg_index_out
                        );
                      --dbms_output.put_line( 'Message: '||l_data );
            END LOOP ;
            x_error_id := 3;
            x_error := l_data;
	    x_follow_up_task_id := 0; -- no tasks
	END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    x_error_id := -1;
    x_error := p_notes||' ' ||SQLERRM;

END CREATE_FOLLOW_UP_TASK;


PROCEDURE CREATE_NEW_TASK
  ( p_task_name          IN  VARCHAR2
  , p_task_type_id       IN  NUMBER
  , p_status_id          IN  NUMBER
  , p_priority_id        IN  NUMBER
  , p_assign_to_me       IN  VARCHAR2
  , p_Planned_Start_date IN  DATE
  , p_planned_effort     IN  NUMBER
  , p_planned_effort_uom IN VARCHAR2
  , p_notes              IN VARCHAR2
  , p_source_object_id   IN NUMBER
  , x_error_id           OUT NOCOPY NUMBER
  , x_error              OUT NOCOPY VARCHAR2
  , x_new_task_id        OUT NOCOPY NUMBER
  , p_note_type          IN  VARCHAR2
  , p_note_status        IN VARCHAR2
  , p_Planned_End_date   IN  DATE
  , p_attribute_1	IN VARCHAR2
  , p_attribute_2	IN VARCHAR2
  , p_attribute_3	IN VARCHAR2
  , p_attribute_4	IN VARCHAR2
  , p_attribute_5	IN VARCHAR2
  , p_attribute_6	IN VARCHAR2
  , p_attribute_7	IN VARCHAR2
  , p_attribute_8	IN VARCHAR2
  , p_attribute_9	IN VARCHAR2
  , p_attribute_10	IN VARCHAR2
  , p_attribute_11	IN VARCHAR2
  , p_attribute_12	IN VARCHAR2
  , p_attribute_13	IN VARCHAR2
  , p_attribute_14	IN VARCHAR2
  , p_attribute_15	IN VARCHAR2
  , p_context		IN VARCHAR2
) IS

l_task_type_name varchar2(30);
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);

l_data varchar2(255);
l_task_notes_rec               jtf_tasks_pub.task_notes_rec;
l_task_notes_tbl               jtf_tasks_pub.task_notes_tbl;
l_msg_index_out number;
l_location_id number;
l_address_id number;

l_resource_id number;
l_resource_type varchar2(30);
l_assign_by_id number;
l_scheduled_start_date DATE;
l_scheduled_end_date DATE;
l_incident_number VARCHAR2(64);
l_organization_id NUMBER;
l_note_type                    varchar2(30);
l_note_status                  varchar2(1);
-- bug # 5182676
l_customer_id  number;

cursor c_customer_id (v_incident_id number)
is
   select customer_id from cs_incidents_all where incident_id = v_incident_id;

CURSOR c_task_type (v_task_type_id NUMBER)
IS
Select name
  from jtf_task_types_vl
 where TASK_TYPE_ID = v_task_type_id;

CURSOR c_resource_id (v_user_id NUMBER)
IS
 select resource_id
  from jtf_rs_resource_extns
  where user_id = v_user_id;

CURSOR c_resource_type (v_resource_id NUMBER)
IS
select decode(category, 'EMPLOYEE', 'RS_EMPLOYEE',
      'PARTNER', 'RS_PARTNER',
      'SUPPLIER_CONTACT', 'RS_SUPPLIER_CONTACT',
      'OTHER', 'RS_OTHER',
      'PARTY', 'RS_PARTY',
      'TBH', 'RS_TBH',
      'VENUE', 'RS_VENUE', category)
  from JTF_RS_RESOURCE_EXTNS
 where resource_id = v_resource_id ;

cursor c_check_valid_resource (v_resource_id number, v_resource_type varchar2)
is
  select count(*) from jtf_task_resources_vl
  where resource_id = v_resource_id and resource_type = v_resource_type;

l_check_valid_resource number;

CURSOR c_incident_number (v_incident_id NUMBER)
IS
Select incident_number,
       incident_location_type,
       incident_location_id
  from cs_incidents_all
 where incident_id = v_incident_id ;

 r_incident_record c_incident_number%ROWTYPE;

BEGIN

-- get the task type name
open c_task_type(p_task_type_id);
fetch c_task_type into l_task_type_name;
close c_task_type;


--notes
if p_notes <> '$$#@'
then
    if p_note_type is null then
       l_note_type := 'KB_FACT';
    else
       l_note_type := p_note_type;
    end if;

    if p_note_status is null then
       l_note_status := 'I';
    else
       l_note_status := p_note_status;
    end if;

	FND_PROFILE.GET ( 'CS_INV_VALIDATION_ORG' , l_organization_id);
	l_task_notes_rec.org_id		 := l_organization_id;
	l_task_notes_rec.notes		 := p_notes;
	l_task_notes_rec.note_status	 := l_note_status;
	l_task_notes_rec.entered_by	 := FND_GLOBAL.user_id;
	l_task_notes_rec.entered_date	 := sysdate;
	l_task_notes_rec.note_type       := l_note_type;
	l_task_notes_tbl (1)             := l_task_notes_rec;
else
	l_task_notes_tbl := jtf_tasks_pub.g_miss_task_notes_tbl;
end if;

-- bug # 4724278
-- Use Task Manager profile for Task Owner details
l_resource_id := -1;
FND_PROFILE.GET('JTF_TASK_DEFAULT_OWNER', l_resource_id);
FND_PROFILE.GET('JTF_TASK_DEFAULT_OWNER_TYPE', l_resource_type);

open c_check_valid_resource (l_resource_id, l_resource_type);
fetch c_check_valid_resource into l_check_valid_resource;
close c_check_valid_resource;

IF l_resource_id IS NULL
   or l_resource_type is NULL
   or l_check_valid_resource is NULL
   or l_check_valid_resource <> 1 THEN

   -- resource id
   open c_resource_id (FND_GLOBAL.USER_ID);
   fetch c_resource_id into l_resource_id;
   close c_resource_id;

   -- resource type
   open c_resource_type (l_resource_id);
   fetch c_resource_type into l_resource_type;
   close c_resource_type;
END IF;

-- SR number
open c_incident_number (p_source_object_id);
fetch c_incident_number into r_incident_record;
close c_incident_number;
l_incident_number := r_incident_record.incident_number;

IF (r_incident_record.incident_location_type = 'HZ_LOCATION')THEN
    l_location_id := r_incident_record.incident_location_id;
    l_address_id  := null;
ELSE
    l_location_id := null;
    l_address_id  := r_incident_record.incident_location_id;
END IF;


-- bug # 5182676
l_customer_id := null;
open c_customer_id (p_source_object_id);
fetch c_customer_id into l_customer_id;
close c_customer_id;


-- Lets call the API
-- bug # 4570867
-- use csf_task_pub instead of jtf_task_pub
-- for DISPATCH type task

IF has_field_service_rule (p_task_type_id) THEN

   csf_tasks_pub.create_task (
   	p_api_version             => 1.0,
   	p_commit                  => fnd_api.g_true,
   	p_task_name               => p_task_name,
   	p_task_type_name          => l_task_type_name,
   	p_task_type_id            => p_task_type_id,
   	p_task_status_id          => p_status_id,
   	p_task_priority_id        => p_priority_id,
   	p_owner_type_code         => l_resource_type,
   	p_owner_id                => l_resource_id,
   	p_assigned_by_id          => l_assign_by_id,
   	p_planned_start_date      => p_Planned_Start_date,
   	p_planned_end_date        => p_Planned_End_date,
   	p_scheduled_start_date    => l_scheduled_start_date,
   	p_scheduled_end_date      => l_scheduled_end_date,
   	p_source_object_type_code => 'SR',
   	p_source_object_id        => p_source_object_id,
   	p_customer_id             => l_customer_id,     -- bug # 5182676
    p_address_id              => l_address_id,
    p_location_id             => l_location_id,
   	p_source_object_name      => l_incident_number,
   	p_planned_effort          => p_planned_effort,
   	p_planned_effort_uom      => p_planned_effort_uom,
   	p_task_notes_tbl          => l_task_notes_tbl,
   	x_return_status           => l_return_status,
   	x_msg_count               => l_msg_count,
   	x_msg_data                => l_msg_data,
   	x_task_id                 => x_new_task_id,
   	p_attribute1              => p_attribute_1,
   	p_attribute2              => p_attribute_2,
   	p_attribute3              => p_attribute_3,
   	p_attribute4              => p_attribute_4,
   	p_attribute5              => p_attribute_5,
   	p_attribute6              => p_attribute_6,
   	p_attribute7              => p_attribute_7,
   	p_attribute8              => p_attribute_8,
   	p_attribute9              => p_attribute_9,
   	p_attribute10             => p_attribute_10,
   	p_attribute11             => p_attribute_11,
   	p_attribute12             => p_attribute_12,
   	p_attribute13             => p_attribute_13,
   	p_attribute14             => p_attribute_14,
   	p_attribute15             => p_attribute_15,
   	p_attribute_category      => p_context
       );
ELSE
   -- call JTF for non DISPATCH type task
   jtf_tasks_pub.create_task (
        p_api_version             => 1.0,
        p_commit                  => fnd_api.g_true,
        p_task_name               => p_task_name,
        p_task_type_name          => l_task_type_name,
        p_task_type_id            => p_task_type_id,
        p_description             => '',
        p_task_status_name        => null,
        p_task_status_id          => p_status_id,
        p_task_priority_name      => null,
        p_task_priority_id        => p_priority_id,
        p_owner_type_name         => Null,
        p_owner_type_code         => l_resource_type,
        p_owner_id                => l_resource_id,
        p_owner_territory_id      => null,
        p_assigned_by_name        => NULL,
        p_assigned_by_id          => l_assign_by_id,
        p_customer_number         => null,
        p_customer_id             => l_customer_id,   -- bug # 5182676
        p_cust_account_number     => null,
        p_cust_account_id         => null,
        p_address_id              => l_address_id,
        p_location_id             => l_location_id,
        p_planned_start_date      => p_Planned_Start_date,
        p_planned_end_date        => p_Planned_End_date,
        p_scheduled_start_date    => l_scheduled_start_date,
        p_scheduled_end_date      => l_scheduled_end_date,
        p_actual_start_date       => NULL,
        p_actual_end_date         => NULL,
        p_timezone_id             => NULL,
        p_timezone_name           => NULL,
        p_source_object_type_code => 'SR',
        p_source_object_id        => p_source_object_id,
        p_source_object_name      => l_incident_number,
        p_duration                => null,
        p_duration_uom            => null,
        p_planned_effort          => p_planned_effort,
        p_planned_effort_uom      => p_planned_effort_uom,
        p_actual_effort           => NULL,
        p_actual_effort_uom       => NULL,
        p_percentage_complete     => null,
        p_reason_code             => null,
        p_private_flag            => null,
        p_publish_flag            => null,
        p_restrict_closure_flag   => NULL,
        p_multi_booked_flag       => NULL,
        p_milestone_flag          => NULL,
        p_holiday_flag            => NULL,
        p_billable_flag           => NULL,
        p_bound_mode_code         => null,
        p_soft_bound_flag         => null,
        p_workflow_process_id     => NULL,
        p_notification_flag       => NULL,
        p_notification_period     => NULL,
        p_notification_period_uom => NULL,
        p_parent_task_number      => null,
        p_parent_task_id          => NULL,
        p_alarm_start             => NULL,
        p_alarm_start_uom         => NULL,
        p_alarm_on                => NULL,
        p_alarm_count             => NULL,
        p_alarm_interval          => NULL,
        p_alarm_interval_uom      => NULL,
        p_palm_flag               => NULL,
        p_wince_flag              => NULL,
        p_laptop_flag             => NULL,
        p_device1_flag            => NULL,
        p_device2_flag            => NULL,
        p_device3_flag            => NULL,
        p_costs                   => NULL,
        p_currency_code           => NULL,
        p_escalation_level        => NULL,
        p_task_notes_tbl          => l_task_notes_tbl,
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data,
        x_task_id                 => x_new_task_id,
        p_attribute1              => p_attribute_1,
        p_attribute2              => p_attribute_2,
        p_attribute3              => p_attribute_3,
        p_attribute4              => p_attribute_4,
        p_attribute5              => p_attribute_5,
        p_attribute6              => p_attribute_6,
        p_attribute7              => p_attribute_7,
        p_attribute8              => p_attribute_8,
        p_attribute9              => p_attribute_9,
        p_attribute10             => p_attribute_10,
        p_attribute11             => p_attribute_11,
        p_attribute12             => p_attribute_12,
        p_attribute13             => p_attribute_13,
        p_attribute14             => p_attribute_14,
        p_attribute15             => p_attribute_15,
        p_attribute_category      => p_context,
        p_date_selected           => NULL,
        p_category_id             => null,
        p_show_on_calendar        => null,
        p_owner_status_id         => null,
        p_template_id             => null,
        p_template_group_id       => null
    );
END IF;

IF l_return_status = FND_API.G_RET_STS_SUCCESS
THEN
	/* API-call was successfull */
	x_error_id := 0;
	x_error := FND_API.G_RET_STS_SUCCESS;
ELSE
	FOR l_counter IN 1 .. l_msg_count
	LOOP
	      fnd_msg_pub.get
		( p_msg_index     => l_counter
		, p_encoded       => FND_API.G_FALSE
		, p_data          => l_data
		, p_msg_index_out => l_msg_index_out
		);
	      --dbms_output.put_line( 'Message: '||l_data );
	END LOOP ;
	x_error_id := 2;
	x_error := l_data;
	x_new_task_id := 0; -- no tasks
END IF;


EXCEPTION
  WHEN OTHERS
  THEN
    x_error_id := -1;
    x_error := SQLERRM;


END CREATE_NEW_TASK;


PROCEDURE CREATE_NEW_SR
( p_old_incident_id    IN  NUMBER
, p_incident_type_id   IN  NUMBER
, p_status_id          IN  NUMBER
, p_severity_id        IN  NUMBER
, p_summary            IN  VARCHAR2
, p_instance_id        IN  NUMBER
, p_inv_item_id        IN  NUMBER
, p_serial_number      IN  VARCHAR2
, p_notes              IN  VARCHAR2
, x_new_incident_id    OUT NOCOPY NUMBER
, x_incident_number    OUT NOCOPY VARCHAR2
, x_error_id           OUT NOCOPY NUMBER
, x_error              OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, p_contact_id         IN  NUMBER
, p_external_reference IN  VARCHAR2
, p_prob_code	       IN  VARCHAR2		-- Addition for inserting problem code
, p_cust_po_number	IN varchar2		-- Bug 5059169
, p_attribute_1		IN VARCHAR2		-- Addition for insert DFF data with create SR
, p_attribute_2		IN VARCHAR2
, p_attribute_3		IN VARCHAR2
, p_attribute_4		IN VARCHAR2
, p_attribute_5		IN VARCHAR2
, p_attribute_6		IN VARCHAR2
, p_attribute_7		IN VARCHAR2
, p_attribute_8		IN VARCHAR2
, p_attribute_9		IN VARCHAR2
, p_attribute_10	IN VARCHAR2
, p_attribute_11	IN VARCHAR2
, p_attribute_12	IN VARCHAR2
, p_attribute_13	IN VARCHAR2
, p_attribute_14	IN VARCHAR2
, p_attribute_15	IN VARCHAR2
, p_context		IN VARCHAR2
)IS


l_api_name                CONSTANT VARCHAR2(30) := 'Create_new_SR';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_access_flag             VARCHAR2(1);
l_sqlcode 		  Number;
l_sqlerrm 		  Varchar2(2000);
l_service_request_rec 	cs_servicerequest_pub.service_request_rec_type;
l_notes_table 		cs_servicerequest_pub.notes_table;
l_notes_rec             cs_servicerequest_pub.notes_rec;
l_contacts_table 	cs_servicerequest_pub.contacts_table;
l_msg_index_out 	number;
l_task_id		NUMBER;
l_index 		NUMBER := 0;
l_primary_contact 	VARCHAR2(1);
l_organization_id       NUMBER;
x_interaction_id	Number;
x_workflow_process_id 	Number;
x_individual_owner	Number;
x_group_owner		Number;
x_individual_type	Varchar2(200);
x_object_version_number Number;
x_reciprocal_link_id    Number;
x_link_id	     	Number;
x_pm_conf_reqd		Varchar2(1);
X_Msg_Data                VARCHAR2(2000);
l_data                  VARCHAR2(255);
X_MSG_INDEX_OUT         NUMBER;

l_caller_type        VARCHAR2(100);
l_party_id           NUMBER;
l_install_site_id    NUMBER;
l_party_acc_id       NUMBER;
l_external_ref       VARCHAR2(30);
l_system_id          NUMBER;
l_bill_to_site_id    NUMBER;
l_ship_to_site_id    NUMBER;
l_bill_to_party_id   NUMBER;
l_ship_to_party_id   NUMBER;

/* File Handling
    debug_handler utl_file.file_type;
    debug_handler1 utl_file.file_type;
    l_utl_dir varchar2(1000) := '/sqlcom/outbound/SRVDEVR9';
*/

l_party_type VARCHAR2(30);
l_next_val number;
l_context VARCHAR2(30);

CURSOR c_incident_record( v_incident_id number)
  IS

Select caller_type,
	customer_id       ,
	install_site_id   ,
	account_id        ,
	external_reference,
	system_id         ,
	bill_to_site_id   ,
	ship_to_site_id   ,
	bill_to_party_id  ,
	ship_to_party_id  ,
    incident_location_type,
    incident_location_id,
    -- bug # 5182686
    customer_email_id,
    customer_phone_id,
    category_set_id,
    category_id
  from cs_incidents_all
  where incident_id = v_incident_id;

  r_incident_record c_incident_record%ROWTYPE;

  -- bug # 5182686
  cursor c_hz_contact_points (v_party_id number, v_contact_type varchar2) is
  select contact_point_id
  from
  HZ_PARTY_CONTACT_POINTS_V
  where
  party_id = v_party_id
  and contact_point_type =  v_contact_type
  and primary_flag = 'Y';

  l_customer_phone_id number;
  l_customer_email_id number;

  -- bug # 5182686 for item category
  cursor c_item_category (v_inv_item_id number, v_cat_set_id number, v_org_id number ) is
  select
  category_id
  from
  MTL_ITEM_CATEGORIES
  where
  INVENTORY_ITEM_ID = v_inv_item_id
  and organization_id = v_org_id
  and category_set_id = v_cat_set_id;

  l_category_set_id number;
  l_category_id number;

CURSOR c_party_type( v_contact_id number) IS
SELECT party_type FROM hz_parties WHERE party_id = v_contact_id;

CURSOR c_contact_points_next IS
SELECT CS_HZ_SR_CONTACT_POINTS_S.NEXTVAL  FROM DUAL;

cursor c_from_ib_instance(v_instance_id number) is
SELECT
LOCATION_ID,
LOCATION_TYPE_CODE,
OWNER_PARTY_ID,
OWNER_PARTY_ACCOUNT_ID,
SYSTEM_ID,
EXTERNAL_REFERENCE
from csi_item_instances
where instance_id = v_instance_id;

r_from_ib_instance c_from_ib_instance%ROWTYPE;



cursor c_bill_to_ship_to (v_instance_id number, v_type varchar2) is
SELECT
c.party_id party_id,
nvl(a.party_site_id , 0) party_site_id
from hz_party_sites a, hz_party_site_uses b ,csi_i_parties c
 where a.party_id(+) = c.party_id
 and   c.RELATIONSHIP_TYPE_CODE = v_type
 and   c.instance_id = v_instance_id
 and   b.party_site_id(+) = a.party_site_id
 and   b.site_use_type(+) = v_type
 and   b.status(+) = 'A'
 and   trunc(SYSDATE) BETWEEN TRUNC(NVL(b.begin_date,SYSDATE)) and
				TRUNC(NVL(b.end_date,SYSDATE));

r_bill_to_ship_to  c_bill_to_ship_to%ROWTYPE;



cursor c_install_site(v_party_id number, v_location_id number ) is
select party_site_id
from   hz_party_sites
where  party_id = v_party_id
  and  location_id = v_location_id;

BEGIN
	FND_PROFILE.GET ( 'CS_INV_VALIDATION_ORG' , l_organization_id);
		cs_servicerequest_pub.initialize_rec(l_service_request_rec);
	--keep on Selecting

	IF (p_old_incident_id <> 0) THEN
		OPEN c_incident_record(p_old_incident_id);
		FETCH c_incident_record INTO r_incident_record;
		CLOSE c_incident_record;

		l_caller_type      := r_incident_record.caller_type;
		l_party_id         := r_incident_record.customer_id;
		l_install_site_id  := r_incident_record.install_site_id;
		l_party_acc_id     := r_incident_record.account_id;
		l_external_ref     := r_incident_record.external_reference;
		l_system_id        := r_incident_record.system_id;
		l_bill_to_site_id  := r_incident_record.bill_to_site_id;
		l_ship_to_site_id  := r_incident_record.ship_to_site_id;
		l_bill_to_party_id := r_incident_record.bill_to_party_id;
		l_ship_to_party_id := r_incident_record.ship_to_party_id;
		l_service_request_rec.incident_location_type := r_incident_record.incident_location_type;
		l_service_request_rec.incident_location_id := r_incident_record.incident_location_id;

       -- bug # 5182686
       l_service_request_rec.customer_phone_id := r_incident_record.customer_phone_id;
       l_service_request_rec.customer_email_id := r_incident_record.customer_email_id;
       l_service_request_rec.category_set_id := r_incident_record.category_set_id;
       l_service_request_rec.category_id := r_incident_record.category_id;

	ELSE
		-- Some how we need to get the parameters
		-- we can find some from the instance id. If we do not have the instance id then we
		-- will have the incident id
		OPEN c_from_ib_instance(p_instance_id);
		FETCH c_from_ib_instance INTO r_from_ib_instance;
		CLOSE c_from_ib_instance;

		l_caller_type      := 'ORGANIZATION';
		l_party_id         := r_from_ib_instance.OWNER_PARTY_ID;
		l_party_acc_id     := r_from_ib_instance.OWNER_PARTY_ACCOUNT_ID;
		l_external_ref     := r_from_ib_instance.EXTERNAL_REFERENCE;
		l_system_id        := r_from_ib_instance.SYSTEM_ID;

		/*
		Chenged for FS Asstets Flow
		IF (r_from_ib_instance.INSTALL_LOCATION_TYPE_CODE = 'HZ_PARTY_SITES') THEN
			l_install_site_id  := r_from_ib_instance.INSTALL_LOCATION_ID;
		ELSIF (r_from_ib_instance.INSTALL_LOCATION_TYPE_CODE = 'HZ_LOCATIONS') THEN
			open c_install_site(l_party_id, r_from_ib_instance.INSTALL_LOCATION_ID);
			fetch c_install_site into l_install_site_id;
			close c_install_site;LOCATION_ID,
LOCATION_TYPE_CODE,


		ELSE
			l_install_site_id := null;
		END IF;*/

		IF (r_from_ib_instance.LOCATION_TYPE_CODE = 'HZ_PARTY_SITES') THEN
		    l_install_site_id  := r_from_ib_instance.LOCATION_ID;
		    l_service_request_rec.incident_location_type := 'HZ_PARTY_SITE';
		    l_service_request_rec.incident_location_id := r_from_ib_instance.LOCATION_ID;
		ELSIF (r_from_ib_instance.LOCATION_TYPE_CODE = 'HZ_LOCATIONS') THEN
		    open c_install_site(l_party_id, r_from_ib_instance.LOCATION_ID);
		    fetch c_install_site into l_install_site_id;
		    close c_install_site;
		    l_service_request_rec.incident_location_type := 'HZ_LOCATION';
		    l_service_request_rec.incident_location_id := r_from_ib_instance.LOCATION_ID;

		ELSE
		    l_install_site_id := null;
		END IF;


		--lets validate the partyid and install locationid
		-- and if it fails then we will not pass the install site id
		IF (validate_install_site(l_install_site_id, l_party_id)<=0)then
		    l_install_site_id := null;
		END IF;


		OPEN c_bill_to_ship_to(p_instance_id, 'SHIP_TO');
		FETCH c_bill_to_ship_to INTO r_bill_to_ship_to;
		CLOSE c_bill_to_ship_to;
		l_ship_to_site_id  := r_bill_to_ship_to.party_site_id;
		l_ship_to_party_id := l_party_id;--r_bill_to_ship_to.PARTY_ID;

		OPEN c_bill_to_ship_to(p_instance_id, 'BILL_TO');
		FETCH c_bill_to_ship_to INTO r_bill_to_ship_to;
		CLOSE c_bill_to_ship_to;
		l_bill_to_site_id  := r_bill_to_ship_to.party_site_id;
		l_bill_to_party_id := l_party_id;--r_bill_to_ship_to.PARTY_ID;

		--Check for 0
		IF (l_bill_to_site_id = 0 ) THEN
			l_bill_to_site_id := NULL;
		END IF;

		IF (l_ship_to_site_id = 0 ) THEN
			l_ship_to_site_id := NULL;
		END IF;

	END IF;

		l_service_request_rec.type_id                  := p_incident_type_id;
		l_service_request_rec.status_id                := p_status_id;
		l_service_request_rec.severity_id              := p_severity_id;
		l_service_request_rec.summary                  := p_summary;
		l_service_request_rec.caller_type              := l_caller_type;
		l_service_request_rec.customer_id              := l_party_id;

       -- bug # 5182686
       open c_hz_contact_points (l_party_id, 'PHONE');
       fetch c_hz_contact_points into l_customer_phone_id;
       close c_hz_contact_points;

       if l_customer_phone_id is not null then
         l_service_request_rec.customer_phone_id := l_customer_phone_id;
       end if;

       open c_hz_contact_points (l_party_id, 'EMAIL');
       fetch c_hz_contact_points into l_customer_email_id;
       close c_hz_contact_points;

       if l_customer_email_id is not null then
         l_service_request_rec.customer_email_id := l_customer_email_id;
       end if;

		IF  (p_instance_id <> 0) THEN
			l_service_request_rec.customer_product_id      := p_instance_id;
		END IF;

		IF  (p_inv_item_id <> 0) THEN
			l_service_request_rec.inventory_item_id        := p_inv_item_id;
         -- bug # 5182686
         FND_PROFILE.GET ( 'CS_SR_DEFAULT_CATEGORY_SET' , l_category_set_id);
         open c_item_category (p_inv_item_id, l_category_set_id, l_organization_id);
         fetch c_item_category into l_category_id;
         close c_item_category;
         if l_category_id is not null then
           l_service_request_rec.category_id := l_category_id;
           l_service_request_rec.category_set_id := l_category_set_id;
         end if;
		END IF ;

		l_service_request_rec.inventory_org_id         := l_organization_id;

		IF  (p_serial_number <> '$$#@') THEN
			l_service_request_rec.current_serial_number    := p_serial_number;
		END IF;

		IF  (p_external_reference <> '$$#@') THEN
			l_service_request_rec.external_reference    := p_external_reference;
		ELSE
			l_service_request_rec.external_reference       := l_external_ref;
		END IF;



      -- bug # 5525903 Populate incident_date
      l_service_request_rec.request_date             := sysdate;
      l_service_request_rec.incident_occurred_date   := sysdate;

		l_service_request_rec.exp_resolution_date      := sysdate+2;
		l_service_request_rec.install_site_use_id      := l_install_site_id;
		l_service_request_rec.account_id               := l_party_acc_id;
		l_service_request_rec.sr_creation_channel      := 'MOBILE'; -- Bug 3939638: Changing from `AUTOMATIC`
		l_service_request_rec.system_id                := l_system_id;

		l_service_request_rec.creation_program_code    := 'FS-WIRELESS'; -- Bug 3939638: Changing from 'PMCON'
		l_service_request_rec.last_update_program_code := 'FS-WIRELESS'; -- Bug 3939638: Changing from 'PMCON'
		l_service_request_rec.program_id               := fnd_global.conc_program_id;
		l_service_request_rec.program_application_id   := fnd_global.prog_appl_id;
		l_service_request_rec.conc_request_id          := fnd_global.conc_request_id;
		l_service_request_rec.program_login_id         := fnd_global.conc_login_id;

		--l_service_request_rec.bill_to_site_id                := l_bill_to_site_id;
		l_service_request_rec.ship_to_site_id                := l_ship_to_site_id;
		--l_service_request_rec.bill_to_party_id                := l_bill_to_party_id;
		l_service_request_rec.ship_to_party_id               := l_ship_to_party_id;

		l_service_request_rec.owner_id                 := NULL;
		l_service_request_rec.time_zone_id             := NULL;
		l_service_request_rec.verify_cp_flag           := 'Y';
		l_service_request_rec.problem_code	       := p_prob_code;
		l_service_request_rec.cust_po_number		:= p_cust_po_number; -- Bug 5059169

		-- Addition for insert DFF data with create SR
		l_service_request_rec.request_attribute_1	:= p_attribute_1 ;
		l_service_request_rec.request_attribute_2	:= p_attribute_2 ;
		l_service_request_rec.request_attribute_3	:= p_attribute_3 ;
		l_service_request_rec.request_attribute_4	:= p_attribute_4 ;
		l_service_request_rec.request_attribute_5	:= p_attribute_5 ;
		l_service_request_rec.request_attribute_6	:= p_attribute_6 ;
		l_service_request_rec.request_attribute_7	:= p_attribute_7 ;
		l_service_request_rec.request_attribute_8	:= p_attribute_8 ;
		l_service_request_rec.request_attribute_9	:= p_attribute_9 ;
		l_service_request_rec.request_attribute_10	:= p_attribute_10 ;
		l_service_request_rec.request_attribute_11	:= p_attribute_11 ;
		l_service_request_rec.request_attribute_12	:= p_attribute_12 ;
		l_service_request_rec.request_attribute_13	:= p_attribute_13 ;
		l_service_request_rec.request_attribute_14	:= p_attribute_14 ;
		l_service_request_rec.request_attribute_15	:= p_attribute_15 ;
		l_service_request_rec.request_context		:= p_context ;


		--notes
		if p_notes <> '$$#@'
		then
			l_notes_rec.note	    := p_notes;
			l_notes_rec.note_type       := 'KB_FACT';
			l_notes_table (1)           := l_notes_rec;
		else
			l_notes_rec.note	    := FND_API.G_MISS_CHAR;
			l_notes_rec.note_type       := FND_API.G_MISS_CHAR;
			l_notes_table (1)           := l_notes_rec;
		end if;

		--Contacts
		IF  (p_contact_id <> 0) THEN
			open c_party_type(p_contact_id);
			fetch c_party_type into l_party_type;
			close c_party_type;

			open c_contact_points_next;
			fetch c_contact_points_next into l_next_val;
			close c_contact_points_next;

			l_contacts_table(1).SR_CONTACT_POINT_ID := l_next_val ;
			l_contacts_table(1).PRIMARY_FLAG        := 'Y';
			l_contacts_table(1).PARTY_ID            := p_contact_id;
			l_contacts_table(1).CONTACT_TYPE        := l_party_type;
		END IF;

		--CALLING API
		cs_servicerequest_pub.Create_ServiceRequest
			( p_api_version          => 3.0,
			  p_init_msg_list        => FND_API.G_FALSE,
			  p_commit	         => FND_API.G_TRUE, -- COMMIT
			  x_return_status	 => x_return_status,
			  x_msg_count		 => x_msg_count,
			  x_msg_data		 => x_msg_data,
			  p_resp_appl_id         => FND_GLOBAL.RESP_APPL_ID,
			  p_resp_id	         => FND_GLOBAL.RESP_ID,
			  p_user_id		 => fnd_global.user_id,
			  p_login_id		 => fnd_global.conc_login_id,
			  p_org_id		 => null,
			  p_request_id           => null,
			  p_request_number	 => null,
			  p_service_request_rec  => l_service_request_rec,
			  p_notes     		 => l_notes_table,
			  p_contacts  		 => l_contacts_table,-- for time being it is null
			  p_auto_assign	 	 => 'Y',
			  x_request_id		 => x_new_incident_id,
			  x_request_number	 => x_incident_number,
			  x_interaction_id       => x_interaction_id,
			  x_workflow_process_id  => x_workflow_process_id,
			  x_individual_owner     => x_individual_owner,
			  x_group_owner		 => x_group_owner,
			  x_individual_type	 => x_individual_type );


-- open the file
/*
debug_handler := UTL_FILE.FOPEN(l_utl_dir, 'prats1.log','a');

if UTL_FILE.is_open(debug_handler)  then
	UTL_FILE.PUT_LINE(debug_handler,'**************** STARTING AGAIN **********' );
    UTL_FILE.PUT_LINE(debug_handler,'Just called API' );
	UTL_FILE.PUT_LINE(debug_handler,'Return Status ' ||x_return_status );
	UTL_FILE.PUT_LINE(debug_handler,'x_error '|| x_error );
	UTL_FILE.PUT_LINE(debug_handler,'x_msg_data ' || x_msg_data);
	UTL_FILE.PUT_LINE(debug_handler,'x_msg_count ' || x_msg_count);
--	UTL_FILE.PUT_LINE(debug_handler,'**************** FINISHED RUN **********' );
--	UTL_FILE.FCLOSE(debug_handler);
end if;
*/
		IF x_return_status = FND_API.G_RET_STS_SUCCESS
		THEN
			/* API-call was successfull */
			x_error_id := 0;
			x_error    := NULL ;
		ELSE
			x_error_id := 2;
				FOR l_counter IN 1 .. x_msg_count
				LOOP
				      fnd_msg_pub.get
					( p_msg_index     => l_counter
					, p_encoded       => FND_API.G_FALSE
					, p_data          => l_data
					, p_msg_index_out => l_msg_index_out
					);
/*
if UTL_FILE.is_open(debug_handler)  then
	UTL_FILE.PUT_LINE(debug_handler,'------------- Came Here status <> S --------------' );
	UTL_FILE.PUT_LINE(debug_handler,' l_counter ' || l_counter);
	UTL_FILE.PUT_LINE(debug_handler,' l_data ' || l_data);
--	UTL_FILE.PUT_LINE(debug_handler,'**************** FINISHED RUN **********' );
--	UTL_FILE.FCLOSE(debug_handler);
end if;
*/            x_msg_data := l_data;
				END LOOP ;
			x_error := x_msg_data;
			x_new_incident_id := 0; -- no tasks
		END IF;
/*
if UTL_FILE.is_open(debug_handler)  then
	UTL_FILE.PUT_LINE(debug_handler,'------------- Trying to finish stuffs --------------' );
	UTL_FILE.PUT_LINE(debug_handler,' x_msg_data ' || x_msg_data);
	UTL_FILE.PUT_LINE(debug_handler,'**************** FINISHED RUN **********' );
	UTL_FILE.FCLOSE(debug_handler);
end if;
*/
-- debug
 x_error :='Error is ' || x_error|| ' - '||l_bill_to_site_id||' - '|| l_bill_to_party_id ||' - '|| l_ship_to_site_id ||' - '|| l_ship_to_party_id;


EXCEPTION
  WHEN OTHERS
  THEN
    x_error_id := -1;
    x_error := SQLERRM;


END CREATE_NEW_SR ;

FUNCTION GET_END_DATE (p_start_date date, p_uom_code varchar2, p_effort number)
RETURN date IS

conversion_rate_in_day number;

cursor c_conversion (l_uom_code varchar2) is
      SELECT CONVERSION_RATE/24
        FROM MTL_UOM_CONVERSIONS
       WHERE UOM_CLASS = 'Time'
         AND UOM_CODE  = l_uom_code
	 AND INVENTORY_ITEM_ID = 0;


BEGIN

open c_conversion(p_uom_code);
fetch c_conversion into conversion_rate_in_day;
close c_conversion;

return (p_start_date+(p_effort * conversion_rate_in_day) );


END GET_END_DATE;


FUNCTION validate_install_site
(
	p_install_site_id IN NUMBER ,
	p_customer_id	IN NUMBER
) RETURN NUMBER IS
l_count number;

BEGIN
l_count := 0;
SELECT count(*)
INTO l_count
        FROM   Hz_Party_Sites s
        WHERE s.party_site_id = p_install_site_id
        AND   s.status = 'A'
		-- Belongs to SR Customer
        AND ( s.party_id = p_customer_id
		-- or one of its relationships
              OR s.party_id IN (
                 SELECT r.party_id
                 FROM   Hz_Relationships r
                 WHERE r.object_id     = p_customer_id
                 AND   r.status = 'A'
                 AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(r.START_DATE, SYSDATE)) AND TRUNC(NVL(r.END_DATE, SYSDATE)) )
		-- or one of its Related parties
              OR s.party_id IN (
                 SELECT sub.party_id
                 FROM   Hz_Parties  p,
                        Hz_Parties sub,
                        Hz_Parties obj,
                        Hz_Relationships r
                 WHERE obj.party_id  = p_customer_id
                 AND   sub.status = 'A'
                 AND   sub.party_type IN ('PERSON','ORGANIZATION')
                 AND   p.party_id = r.party_id
                 AND   r.object_id = obj.party_id
                 AND   r.subject_id = sub.party_id ));

return l_count;

 EXCEPTION
   when no_data_found then
      return 0;
   when others then
      return 0;

END validate_install_site;


-- Wrapper on update_task for updating task fled field

PROCEDURE UPDATE_TASK_FLEX
  (
  p_task_id		IN  NUMBER
  , p_attribute_1	IN VARCHAR2
  , p_attribute_2	IN VARCHAR2
  , p_attribute_3	IN VARCHAR2
  , p_attribute_4	IN VARCHAR2
  , p_attribute_5	IN VARCHAR2
  , p_attribute_6	IN VARCHAR2
  , p_attribute_7	IN VARCHAR2
  , p_attribute_8	IN VARCHAR2
  , p_attribute_9	IN VARCHAR2
  , p_attribute_10	IN VARCHAR2
  , p_attribute_11	IN VARCHAR2
  , p_attribute_12	IN VARCHAR2
  , p_attribute_13	IN VARCHAR2
  , p_attribute_14	IN VARCHAR2
  , p_attribute_15	IN VARCHAR2
  , p_context		IN VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count		OUT NOCOPY NUMBER
  , x_error             OUT NOCOPY VARCHAR2
) IS

l_msg_count number;
l_msg_data varchar2(2000);

l_data varchar2(255);
l_msg_index_out number;
l_object_version_number number;


CURSOR c_prez_data(v_task_id number)
IS
select object_version_number from jtf_tasks_b where task_id = v_task_id;


BEGIN

open c_prez_data(p_task_id);
fetch c_prez_data into l_object_version_number;
close c_prez_data ;

-- Lets call the API
-- bug # 4570867
-- call csf_task_pub instead of jtf_task_pub

csf_tasks_pub.update_task (
      p_api_version		      => 1.0,
      p_init_msg_list		   => FND_API.G_FALSE,
      p_commit			         => FND_API.G_TRUE,
      p_object_version_number => l_object_version_number,
      p_task_id 		         => p_task_id,
      x_return_status		   => x_return_status,
      x_msg_count		         => x_msg_count,
      x_msg_data		         => l_msg_data,
      p_attribute1		      => p_attribute_1,
      p_attribute2		      => p_attribute_2,
      p_attribute3		      => p_attribute_3,
      p_attribute4		      => p_attribute_4,
      p_attribute5		      => p_attribute_5,
      p_attribute6		      => p_attribute_6,
      p_attribute7		      => p_attribute_7,
      p_attribute8		      => p_attribute_8,
      p_attribute9		      => p_attribute_9,
      p_attribute10		      => p_attribute_10,
      p_attribute11		      => p_attribute_11,
      p_attribute12		      => p_attribute_12,
      p_attribute13		      => p_attribute_13,
      p_attribute14		      => p_attribute_14,
      p_attribute15		      => p_attribute_15,
      p_attribute_category	   => p_context
     );

IF x_return_status = FND_API.G_RET_STS_SUCCESS
THEN
	-- API-call was successfull
	commit;
ELSE
	FOR l_counter IN 1 .. x_msg_count
	LOOP
	      fnd_msg_pub.get
		( p_msg_index     => l_counter
		, p_encoded       => FND_API.G_FALSE
		, p_data          => l_data
		, p_msg_index_out => l_msg_index_out
		);
	      --dbms_output.put_line( 'Message: '||l_data );
	END LOOP ;
	x_error := l_data;
END IF;


EXCEPTION
  WHEN OTHERS
  THEN
    x_error := SQLERRM;


END UPDATE_TASK_FLEX;

   /*
      Bug # 4922104
      Procedure added to update schedule start/end date and Planned Efforts
   */
   PROCEDURE UPDATE_SCH_DATE_TASK
         ( p_task_id                IN NUMBER
         , p_scheduled_start_date   IN DATE
         , p_scheduled_end_date     IN DATE
         , p_planned_effort         IN NUMBER
         , p_planned_effort_uom     IN VARCHAR
         , p_allow_overlap          IN VARCHAR
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_msg_count              OUT NOCOPY NUMBER
         , x_error                  OUT NOCOPY VARCHAR2
         ) IS

      l_object_version_number number;
      l_find_overlap varchar2(10);
      l_validation_level number;
      l_msg_count number;
      l_overlap_msg_index number;
      CURSOR c_prez_data(v_task_id number) IS
         select object_version_number from jtf_tasks_b where task_id = v_task_id;

   BEGIN

      -- Fetch Object Version
      open c_prez_data(p_task_id);
      fetch c_prez_data into l_object_version_number;
      close c_prez_data ;

      l_find_overlap := fnd_api.G_TRUE;
      l_validation_level := fnd_api.G_VALID_LEVEL_FULL;

      if p_allow_overlap = 'Y' then
        l_find_overlap := fnd_api.G_FALSE;
        l_validation_level := fnd_api.G_VALID_LEVEL_NONE;
      end if;

      savepoint before_sch_date;
      -- Call API
      CSF_TASKS_PUB.Update_Task
      ( p_api_version             => 1.0
      , p_init_msg_list           => fnd_api.g_true
      , p_commit                  => fnd_api.g_false
      , p_validation_level        => l_validation_level
      , p_find_overlap            => l_find_overlap
      , p_task_id                 => p_task_id
      , p_object_version_number   => l_object_version_number
      , p_planned_start_date      => fnd_api.g_miss_date
      , p_planned_end_date        => fnd_api.g_miss_date
      , p_scheduled_start_date    => p_scheduled_start_date
      , p_scheduled_end_date      => p_scheduled_end_date
      , p_actual_start_date       => fnd_api.g_miss_date
      , p_actual_end_date         => fnd_api.g_miss_date
      , p_timezone_id             => fnd_api.g_miss_num
      , p_source_object_type_code => fnd_api.g_miss_char
      , p_source_object_id        => fnd_api.g_miss_num
      , p_source_object_name      => fnd_api.g_miss_char
      , p_task_status_id          => fnd_api.g_miss_num
      , p_task_type_id            => fnd_api.g_miss_num
      , p_task_priority_id        => fnd_api.g_miss_num
      , p_owner_type_code         => fnd_api.g_miss_char
      , p_owner_id                => fnd_api.g_miss_num
      , p_owner_territory_id      => fnd_api.g_miss_num
      , p_assigned_by_id          => fnd_api.g_miss_num
      , p_customer_id             => fnd_api.g_miss_num
      , p_cust_account_id         => fnd_api.g_miss_num
      , p_address_id              => fnd_api.g_miss_num
      , p_task_name               => fnd_api.g_miss_char
      , p_description             => fnd_api.g_miss_char
      , p_duration                => fnd_api.g_miss_num
      , p_duration_uom            => fnd_api.g_miss_char
      , p_planned_effort          => p_planned_effort
      , p_planned_effort_uom      => p_planned_effort_uom
      , p_actual_effort           => fnd_api.g_miss_num
      , p_actual_effort_uom       => fnd_api.g_miss_char
      , p_percentage_complete     => fnd_api.g_miss_num
      , p_reason_code             => fnd_api.g_miss_char
      , p_private_flag            => fnd_api.g_miss_char
      , p_publish_flag            => fnd_api.g_miss_char
      , p_restrict_closure_flag   => fnd_api.g_miss_char
      , p_attribute1              => fnd_api.g_miss_char
      , p_attribute2              => fnd_api.g_miss_char
      , p_attribute3              => fnd_api.g_miss_char
      , p_attribute4              => fnd_api.g_miss_char
      , p_attribute5              => fnd_api.g_miss_char
      , p_attribute6              => fnd_api.g_miss_char
      , p_attribute7              => fnd_api.g_miss_char
      , p_attribute8              => fnd_api.g_miss_char
      , p_attribute9              => fnd_api.g_miss_char
      , p_attribute10             => fnd_api.g_miss_char
      , p_attribute11             => fnd_api.g_miss_char
      , p_attribute12             => fnd_api.g_miss_char
      , p_attribute13             => fnd_api.g_miss_char
      , p_attribute14             => fnd_api.g_miss_char
      , p_attribute15             => fnd_api.g_miss_char
      , p_attribute_category      => fnd_api.g_miss_char
      , p_date_selected           => fnd_api.g_miss_char
      , p_category_id             => fnd_api.g_miss_num
      , p_multi_booked_flag       => fnd_api.g_miss_char
      , p_milestone_flag          => fnd_api.g_miss_char
      , p_holiday_flag            => fnd_api.g_miss_char
      , p_billable_flag           => fnd_api.g_miss_char
      , p_bound_mode_code         => fnd_api.g_miss_char
      , p_soft_bound_flag         => fnd_api.g_miss_char
      , p_workflow_process_id     => fnd_api.g_miss_num
      , p_notification_flag       => fnd_api.g_miss_char
      , p_notification_period     => fnd_api.g_miss_num
      , p_notification_period_uom => fnd_api.g_miss_char
      , p_parent_task_id          => fnd_api.g_miss_num
      , p_alarm_start             => fnd_api.g_miss_num
      , p_alarm_start_uom         => fnd_api.g_miss_char
      , p_alarm_on                => fnd_api.g_miss_char
      , p_alarm_count             => fnd_api.g_miss_num
      , p_alarm_fired_count       => fnd_api.g_miss_num
      , p_alarm_interval          => fnd_api.g_miss_num
      , p_alarm_interval_uom      => fnd_api.g_miss_char
      , p_palm_flag               => fnd_api.g_miss_char
      , p_wince_flag              => fnd_api.g_miss_char
      , p_laptop_flag             => fnd_api.g_miss_char
      , p_device1_flag            => fnd_api.g_miss_char
      , p_device2_flag            => fnd_api.g_miss_char
      , p_device3_flag            => fnd_api.g_miss_char
      , p_costs                   => fnd_api.g_miss_num
      , p_currency_code           => fnd_api.g_miss_char
      , p_escalation_level        => fnd_api.g_miss_char
      , x_return_status           => x_return_status
      , x_msg_count               => x_msg_count
      , x_msg_data                => x_error
      );

      -- Bug 8942077. Check only for the overlap message in case of x_return_status = 'S'
      -- Throw exception if x_return_status = 'E'/'U'
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        ROLLBACK TO before_sch_date;
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        ROLLBACK TO before_sch_date;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- No error status, lets check the messages for overlap message.
      IF x_return_status = fnd_api.g_ret_sts_success THEN

        -- Going inside loop to check for messages...
        FOR l_cnt IN 1..x_msg_count
        LOOP
          x_error := fnd_msg_pub.get(p_msg_index => l_cnt, p_encoded => fnd_api.g_true);
          IF INSTR(x_error, 'CSR_TASK_OVERLAP', 1, 1) > 0 THEN -- Check for the overlap message code.
            l_overlap_msg_index := l_cnt; --this is the index of the overlap error message.
          --ELSE
            --fnd_msg_pub.delete_msg(l_cnt);
          END IF;
         END LOOP;

        -- Rollback the transaction if there is an overlap message.
        IF l_overlap_msg_index > 0 THEN
          -- Getting decoded overlap message...
          fnd_msg_pub.get(p_msg_index => l_overlap_msg_index, p_encoded => fnd_api.g_false, p_data => x_error, p_msg_index_out => l_msg_count);
          ROLLBACK TO before_sch_date;
        ELSE
          fnd_msg_pub.initialize;
          x_msg_count := 0;
          x_error := null;
          COMMIT;
        END IF;

      END IF;

      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          x_return_status := fnd_api.g_ret_sts_error;
          --fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_error);
          fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false, p_data => x_error, p_msg_index_out => l_msg_count);
        WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          --fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_error);
          fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false, p_data => x_error, p_msg_index_out => l_msg_count);
        WHEN OTHERS THEN
          x_error := SQLERRM;
   END UPDATE_SCH_DATE_TASK;

END csfw_tasks_pub;


/
