--------------------------------------------------------
--  DDL for Package Body JTF_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASKS_PKG" AS
/* $Header: jtftktab.pls 120.2.12010000.6 2010/04/01 05:50:26 anangupt ship $ */
   PROCEDURE insert_row (
      x_rowid                     IN OUT NOCOPY   VARCHAR2,
      x_task_id                   IN       NUMBER,
      x_attribute4                IN       VARCHAR2,
      x_attribute5                IN       VARCHAR2,
      x_attribute6                IN       VARCHAR2,
      x_attribute7                IN       VARCHAR2,
      x_attribute8                IN       VARCHAR2,
      x_attribute9                IN       VARCHAR2,
      x_attribute10               IN       VARCHAR2,
      x_attribute11               IN       VARCHAR2,
      x_attribute12               IN       VARCHAR2,
      x_attribute13               IN       VARCHAR2,
      x_attribute14               IN       VARCHAR2,
      x_attribute15               IN       VARCHAR2,
      x_attribute_category        IN       VARCHAR2,
      x_task_number               IN       VARCHAR2,
      x_task_type_id              IN       NUMBER,
      x_task_status_id            IN       NUMBER,
      x_task_priority_id          IN       NUMBER,
      x_owner_id                  IN       NUMBER,
      x_owner_type_code           IN       VARCHAR2,
      x_assigned_by_id            IN       NUMBER,
      x_cust_account_id           IN       NUMBER,
      x_customer_id               IN       NUMBER,
      x_address_id                IN       NUMBER,
      x_planned_start_date        IN       DATE,
      x_palm_flag                 IN       VARCHAR2,
      x_wince_flag                IN       VARCHAR2,
      x_laptop_flag               IN       VARCHAR2,
      x_device1_flag              IN       VARCHAR2,
      x_device2_flag              IN       VARCHAR2,
      x_device3_flag              IN       VARCHAR2,
      x_costs                     IN       NUMBER,
      x_currency_code             IN       VARCHAR2,
      x_attribute1                IN       VARCHAR2,
      x_attribute2                IN       VARCHAR2,
      x_attribute3                IN       VARCHAR2,
      x_notification_period       IN       NUMBER,
      x_notification_period_uom   IN       VARCHAR2,
      x_parent_task_id            IN       NUMBER,
      x_recurrence_rule_id        IN       NUMBER,
      x_alarm_start               IN       NUMBER,
      x_alarm_start_uom           IN       VARCHAR2,
      x_alarm_on                  IN       VARCHAR2,
      x_alarm_count               IN       NUMBER,
      x_alarm_fired_count         IN       NUMBER,
      x_alarm_interval            IN       NUMBER,
      x_alarm_interval_uom        IN       VARCHAR2,
      x_deleted_flag              IN       VARCHAR2,
      x_actual_start_date         IN       DATE,
      x_actual_end_date           IN       DATE,
      x_source_object_type_code   IN       VARCHAR2,
      x_timezone_id               IN       NUMBER,
      x_source_object_id          IN       NUMBER,
      x_source_object_name        IN       VARCHAR2,
      x_duration                  IN       NUMBER,
      x_duration_uom              IN       VARCHAR2,
      x_planned_effort            IN       NUMBER,
      x_planned_effort_uom        IN       VARCHAR2,
      x_actual_effort             IN       NUMBER,
      x_actual_effort_uom         IN       VARCHAR2,
      x_percentage_complete       IN       NUMBER,
      x_reason_code               IN       VARCHAR2,
      x_private_flag              IN       VARCHAR2,
      x_publish_flag              IN       VARCHAR2,
      x_restrict_closure_flag     IN       VARCHAR2,
      x_multi_booked_flag         IN       VARCHAR2,
      x_milestone_flag            IN       VARCHAR2,
      x_holiday_flag              IN       VARCHAR2,
      x_billable_flag             IN       VARCHAR2,
      x_bound_mode_code           IN       VARCHAR2,
      x_soft_bound_flag           IN       VARCHAR2,
      x_workflow_process_id       IN       NUMBER,
      x_notification_flag         IN       VARCHAR2,
      x_planned_end_date          IN       DATE,
      x_scheduled_start_date      IN       DATE,
      x_scheduled_end_date        IN       DATE,
      x_task_name                 IN       VARCHAR2,
      x_description               IN       VARCHAR2,
      x_creation_date             IN       DATE,
      x_created_by                IN       NUMBER,
      x_last_update_date          IN       DATE,
      x_last_updated_by           IN       NUMBER,
      x_last_update_login         IN       NUMBER,
      x_owner_territory_id        IN       NUMBER,
      x_escalation_level          IN       VARCHAR2,
      x_calendar_start_date       IN       DATE ,
      x_calendar_end_date         IN       DATE ,
      x_date_selected             IN       VARCHAR2 ,
      x_template_id               IN       NUMBER ,
      x_template_group_id         IN       NUMBER ,
      x_open_flag                 IN       VARCHAR2,
      x_entity                    IN       VARCHAR2,
      x_task_confirmation_status  IN       VARCHAR2,
      x_task_confirmation_counter IN       NUMBER,
      x_task_split_flag           IN       VARCHAR2,
      x_child_position            IN       VARCHAR2,
      x_child_sequence_num        IN       NUMBER,
      x_location_id               IN       NUMBER
   )
   IS
      CURSOR c
      IS
         SELECT ROWID
           FROM jtf_tasks_b
          WHERE task_id = x_task_id;

      x_return_status varchar2(1);
      x_msg_data        VARCHAR2(2000);
      x_msg_count       NUMBER;

      l_task_audit_id 		NUMBER;
      l_enable_audit    varchar2(5);

      l_source_object_type_code    jtf_tasks_b.source_object_type_code%type ;
      l_source_object_id    jtf_tasks_b.source_object_id%type ;
      l_source_object_name    jtf_tasks_b.source_object_name%type ;

   BEGIN
    l_enable_audit := Upper(nvl(fnd_profile.Value('JTF_TASK_ENABLE_AUDIT'),'Y'));
    IF(l_enable_audit = 'Y') THEN
	    jtf_task_audits_pvt.create_task_audits (
	      p_api_version => 1,
	      p_init_msg_list => fnd_api.g_false,
	      p_commit => fnd_api.g_false,
	      p_object_version_number => 1,
	      p_task_id => x_task_id,
	      p_new_billable_flag => x_billable_flag,
	      p_new_device1_flag => x_device1_flag,
	      p_new_device2_flag => x_device2_flag,
	      p_new_device3_flag => x_device3_flag,
	      p_new_holiday_flag => x_holiday_flag,
	      p_new_laptop_flag => x_laptop_flag,
	      p_new_milestone_flag => x_milestone_flag,
	      p_new_multi_booked_flag => x_multi_booked_flag,
	      p_new_not_flag => x_notification_flag,
	      p_new_palm_flag => x_palm_flag,
	      p_new_private_flag => x_private_flag,
	      p_new_publish_flag => x_publish_flag,
	      p_new_restrict_closure_flag => x_restrict_closure_flag,
	      p_new_wince_flag => x_wince_flag,
	      p_new_soft_bound_flag => x_soft_bound_flag,
	      p_new_actual_effort => x_actual_effort,
	      p_new_actual_effort_uom => x_actual_effort_uom,
	      p_new_actual_end_date => x_actual_end_date,
	      p_new_actual_start_date => x_actual_start_date,
	      p_new_address_id => x_address_id,
	      p_new_assigned_by_id => x_assigned_by_id,
	      p_new_bound_mode_code => x_bound_mode_code,
	      p_new_costs => x_costs,
	      p_new_currency_code => x_currency_code,
	      p_new_customer_id => x_customer_id,
	      p_new_cust_account_id => x_cust_account_id,
	      p_new_duration => x_duration,
	      p_new_duration_uom => x_duration_uom,
	      p_new_not_period => x_notification_period,
	      p_new_not_period_uom => x_notification_period_uom,
	      p_new_owner_id => x_owner_id,
	      p_new_owner_type_code => x_owner_type_code,
	      p_new_parent_task_id => x_parent_task_id,
	      p_new_per_complete => x_percentage_complete,
	      p_new_planned_effort => x_planned_effort,
	      p_new_planned_effort_uom => x_planned_effort_uom,
	      p_new_planned_end_date => x_planned_end_date,
	      p_new_planned_start_date => x_planned_start_date,
	      p_new_reason_code => x_reason_code,
	      p_new_recurrence_rule_id => x_recurrence_rule_id,
	      p_new_sched_end_date => x_scheduled_end_date,
	      p_new_sched_start_date => x_scheduled_start_date,
	      p_new_src_obj_id => x_source_object_id,
	      p_new_src_obj_name => x_source_object_name,
	      p_new_src_obj_type_code => x_source_object_type_code,
	      p_new_task_priority_id => x_task_priority_id,
	      p_new_task_status_id => x_task_status_id,
	      p_new_task_type_id => x_task_type_id,
	      p_new_timezone_id => x_timezone_id,
	      p_new_workflow_process_id => x_workflow_process_id,
	      p_not_chan_flag => NULL,
	      p_new_description => x_description,
	      p_new_task_name => x_task_name,
	      p_new_escalation_level => x_escalation_level,
	      p_new_owner_territory_id => x_owner_territory_id,
	      p_new_date_selected => x_date_selected,
	      p_new_location_id => x_location_id,
	   -- p_new_task_conf_status => l_Task_Upd_Rec.task_confirmation_status,
	   -- p_new_task_conf_counter => l_Task_Upd_Rec.task_confirmation_counter,
	   -- p_new_task_split_flag	=> l_Task_Upd_Rec.task_split_flag,
	      x_return_status => x_return_status,
	      x_msg_count => x_msg_count,
	      x_msg_data => x_msg_data,
	      x_task_audit_id => l_task_audit_id
	    );
    END IF;

      INSERT INTO jtf_tasks_b (
                     attribute4,
                     attribute5,
                     attribute6,
                     attribute7,
                     attribute8,
                     attribute9,
                     attribute10,
                     attribute11,
                     attribute12,
                     attribute13,
                     attribute14,
                     attribute15,
                     attribute_category,
                     task_id,
                     task_number,
                     task_type_id,
                     task_status_id,
                     task_priority_id,
                     owner_id,
                     owner_type_code,
                     assigned_by_id,
                     cust_account_id,
                     customer_id,
                     address_id,
                     planned_start_date,
                     palm_flag,
                     wince_flag,
                     laptop_flag,
                     device1_flag,
                     device2_flag,
                     device3_flag,
                     costs,
                     currency_code,
                     attribute1,
                     attribute2,
                     attribute3,
                     notification_period,
                     notification_period_uom,
                     parent_task_id,
                     recurrence_rule_id,
                     alarm_start,
                     alarm_start_uom,
                     alarm_on,
                     alarm_count,
                     alarm_fired_count,
                     alarm_interval,
                     alarm_interval_uom,
                     deleted_flag,
                     actual_start_date,
                     actual_end_date,
                     source_object_type_code,
                     timezone_id,
                     source_object_id,
                     source_object_name,
                     duration,
                     duration_uom,
                     planned_effort,
                     planned_effort_uom,
                     actual_effort,
                     actual_effort_uom,
                     percentage_complete,
                     reason_code,
                     private_flag,
                     publish_flag,
                     restrict_closure_flag,
                     multi_booked_flag,
                     milestone_flag,
                     holiday_flag,
                     billable_flag,
                     bound_mode_code,
                     soft_bound_flag,
                     workflow_process_id,
                     notification_flag,
                     planned_end_date,
                     scheduled_start_date,
                     scheduled_end_date,
                     creation_date,
                     created_by,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     object_version_number,
                     owner_territory_id,
                     escalation_level,
                     calendar_start_date,
                     calendar_end_date,
                     date_selected,
                     template_id,
                     template_group_id,
                     object_changed_date,
                     open_flag,
                     entity,
                     task_confirmation_status,
                     task_confirmation_counter,
                     task_split_flag,
                     child_position,
                     child_sequence_num,
			   location_id
                  )
           VALUES (
              x_attribute4,
              x_attribute5,
              x_attribute6,
              x_attribute7,
              x_attribute8,
              x_attribute9,
              x_attribute10,
              x_attribute11,
              x_attribute12,
              x_attribute13,
              x_attribute14,
              x_attribute15,
              x_attribute_category,
              x_task_id,
              x_task_number,
              x_task_type_id,
              x_task_status_id,
              x_task_priority_id,
              x_owner_id,
              x_owner_type_code,
              x_assigned_by_id,
              x_cust_account_id,
              x_customer_id,
              x_address_id,
              x_planned_start_date,
              x_palm_flag,
              x_wince_flag,
              x_laptop_flag,
              x_device1_flag,
              x_device2_flag,
              x_device3_flag,
              x_costs,
              x_currency_code,
              x_attribute1,
              x_attribute2,
              x_attribute3,
              x_notification_period,
              x_notification_period_uom,
              x_parent_task_id,
              x_recurrence_rule_id,
              x_alarm_start,
              x_alarm_start_uom,
              x_alarm_on,
              x_alarm_count,
              x_alarm_fired_count,
              x_alarm_interval,
              x_alarm_interval_uom,
              x_deleted_flag,
              x_actual_start_date,
              x_actual_end_date,
              x_source_object_type_code,
              x_timezone_id,
              x_source_object_id,
              x_source_object_name,
              x_duration,
              x_duration_uom,
              x_planned_effort,
              x_planned_effort_uom,
              x_actual_effort,
              x_actual_effort_uom,
              x_percentage_complete,
              x_reason_code,
              x_private_flag,
              x_publish_flag,
              x_restrict_closure_flag,
              x_multi_booked_flag,
              x_milestone_flag,
              x_holiday_flag,
              x_billable_flag,
              x_bound_mode_code,
              x_soft_bound_flag,
              x_workflow_process_id,
              x_notification_flag,
              x_planned_end_date,
              x_scheduled_start_date,
              x_scheduled_end_date,
              x_creation_date,
              x_created_by,
              x_last_update_date,
              x_last_updated_by,
              x_last_update_login,
              1,
              x_owner_territory_id,
              x_escalation_level,
              x_calendar_start_date,
              x_calendar_end_date,
              x_date_selected,
              x_template_id,
              x_template_group_id,
              SYSDATE,
              x_open_flag,
              x_entity,
              x_task_confirmation_status,
              x_task_confirmation_counter,
              x_task_split_flag,
              x_child_position,
              x_child_sequence_num,
		  x_location_id
           );




      OPEN c;
      FETCH c INTO x_rowid;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;

      INSERT INTO jtf_tasks_tl
                  (task_name,
                   description,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   task_id,
                   language,
                   source_lang
                  )
         SELECT x_task_name,
                x_description,
                x_created_by,
                x_creation_date,
                x_last_updated_by,
                x_last_update_date,
                x_last_update_login,
                x_task_id,
                l.language_code,
                USERENV ('LANG')
           FROM fnd_languages l
          WHERE l.installed_flag IN ('I', 'B')
            AND NOT EXISTS (SELECT NULL
                              FROM jtf_tasks_tl t
                             WHERE t.task_id = x_task_id
                               AND t.language = l.language_code);
      OPEN c;
      FETCH c INTO x_rowid;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;
	END insert_row;

   PROCEDURE lock_row (x_task_id IN NUMBER, x_object_version_number IN NUMBER)
   IS
      CURSOR c
      IS
         SELECT object_version_number
           FROM jtf_tasks_vl
          WHERE task_id = x_task_id
            FOR UPDATE OF task_id NOWAIT;

      recinfo   c%ROWTYPE;

      CURSOR c1
      IS
         SELECT task_name, description, DECODE (language, USERENV ('LANG'), 'Y', 'N') baselang
           FROM jtf_tasks_tl
          WHERE task_id = x_task_id
            AND USERENV ('LANG') IN (language, source_lang)
            FOR UPDATE OF task_id NOWAIT;

      e_resource_busy                exception;
      pragma exception_init(e_resource_busy, -54);

   BEGIN
      OPEN c;
      FETCH c INTO recinfo;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;
         fnd_message.set_name ('JTF', 'JTF_API_RECORD_NOT_FOUND');
         app_exception.raise_exception;
      END IF;

      CLOSE c;

      IF (recinfo.object_version_number = x_object_version_number)
      THEN
         NULL;
      ELSE
         fnd_message.set_name ('JTF', 'JTF_API_RECORD_NOT_FOUND');
         fnd_msg_pub.add;
         app_exception.raise_exception;
      END IF;

      FOR tlinfo IN c1
      LOOP
         IF (tlinfo.baselang = 'Y')
         THEN
            NULL;
         END IF;
      END LOOP;

      RETURN;

   exception
      when e_resource_busy then
         fnd_message.set_name('FND', 'FND_LOCK_RECORD_ERROR');
         fnd_msg_pub.add;
         app_exception.raise_exception;

   END lock_row;

--BES Changes
    -- original version to call the new version which has task_audit_id

   PROCEDURE update_row (
      x_task_id                   IN   NUMBER,
      x_object_version_number     IN   NUMBER,
      x_attribute4                IN   VARCHAR2,
      x_attribute5                IN   VARCHAR2,
      x_attribute6                IN   VARCHAR2,
      x_attribute7                IN   VARCHAR2,
      x_attribute8                IN   VARCHAR2,
      x_attribute9                IN   VARCHAR2,
      x_attribute10               IN   VARCHAR2,
      x_attribute11               IN   VARCHAR2,
      x_attribute12               IN   VARCHAR2,
      x_attribute13               IN   VARCHAR2,
      x_attribute14               IN   VARCHAR2,
      x_attribute15               IN   VARCHAR2,
      x_attribute_category        IN   VARCHAR2,
      x_task_number               IN   VARCHAR2,
      x_task_type_id              IN   NUMBER,
      x_task_status_id            IN   NUMBER,
      x_task_priority_id          IN   NUMBER,
      x_owner_id                  IN   NUMBER,
      x_owner_type_code           IN   VARCHAR2,
      x_assigned_by_id            IN   NUMBER,
      x_cust_account_id           IN   NUMBER,
      x_customer_id               IN   NUMBER,
      x_address_id                IN   NUMBER,
      x_planned_start_date        IN   DATE,
      x_palm_flag                 IN   VARCHAR2,
      x_wince_flag                IN   VARCHAR2,
      x_laptop_flag               IN   VARCHAR2,
      x_device1_flag              IN   VARCHAR2,
      x_device2_flag              IN   VARCHAR2,
      x_device3_flag              IN   VARCHAR2,
      x_costs                     IN   NUMBER,
      x_currency_code             IN   VARCHAR2,
      x_attribute1                IN   VARCHAR2,
      x_attribute2                IN   VARCHAR2,
      x_attribute3                IN   VARCHAR2,
      x_notification_period       IN   NUMBER,
      x_notification_period_uom   IN   VARCHAR2,
      x_parent_task_id            IN   NUMBER,
      x_recurrence_rule_id        IN   NUMBER,
      x_alarm_start               IN   NUMBER,
      x_alarm_start_uom           IN   VARCHAR2,
      x_alarm_on                  IN   VARCHAR2,
      x_alarm_count               IN   NUMBER,
      x_alarm_fired_count         IN   NUMBER,
      x_alarm_interval            IN   NUMBER,
      x_alarm_interval_uom        IN   VARCHAR2,
      x_deleted_flag              IN   VARCHAR2,
      x_actual_start_date         IN   DATE,
      x_actual_end_date           IN   DATE,
      x_source_object_type_code   IN   VARCHAR2,
      x_timezone_id               IN   NUMBER,
      x_source_object_id          IN   NUMBER,
      x_source_object_name        IN   VARCHAR2,
      x_duration                  IN   NUMBER,
      x_duration_uom              IN   VARCHAR2,
      x_planned_effort            IN   NUMBER,
      x_planned_effort_uom        IN   VARCHAR2,
      x_actual_effort             IN   NUMBER,
      x_actual_effort_uom         IN   VARCHAR2,
      x_percentage_complete       IN   NUMBER,
      x_reason_code               IN   VARCHAR2,
      x_private_flag              IN   VARCHAR2,
      x_publish_flag              IN   VARCHAR2,
      x_restrict_closure_flag     IN   VARCHAR2,
      x_multi_booked_flag         IN   VARCHAR2,
      x_milestone_flag            IN   VARCHAR2,
      x_holiday_flag              IN   VARCHAR2,
      x_billable_flag             IN   VARCHAR2,
      x_bound_mode_code           IN   VARCHAR2,
      x_soft_bound_flag           IN   VARCHAR2,
      x_workflow_process_id       IN   NUMBER,
      x_notification_flag         IN   VARCHAR2,
      x_planned_end_date          IN   DATE,
      x_scheduled_start_date      IN   DATE,
      x_scheduled_end_date        IN   DATE,
      x_task_name                 IN   VARCHAR2,
      x_description               IN   VARCHAR2,
      x_last_update_date          IN   DATE,
      x_last_updated_by           IN   NUMBER,
      x_last_update_login         IN   NUMBER,
      x_owner_territory_id        IN   NUMBER,
      x_escalation_level          IN   VARCHAR2,
      x_calendar_start_date       IN   DATE ,
      x_calendar_end_date         IN   DATE ,
      x_date_selected             IN   VARCHAR2 ,
      x_open_flag                 IN   VARCHAR2,
      x_task_confirmation_status  IN	 VARCHAR2,
      x_task_confirmation_counter IN  NUMBER,
      x_task_split_flag           IN VARCHAR2,
      x_child_position            IN VARCHAR2,
      x_child_sequence_num        IN NUMBER,
	x_location_id		    IN NUMBER
   )
   IS
      x_return_status   VARCHAR2(1);
      x_msg_data        VARCHAR2(2000);
      x_msg_count       NUMBER;

      l_task_audit_id   number ;

      my_message           VARCHAR2(2000);
      l_count                  NUMBER;
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);

--BES enh 2391065
      l_Task_Upd_Rec       JTF_TASKS_PKG.Task_Upd_Rec;


   BEGIN


      l_Task_Upd_Rec.TASK_ID	:= x_task_id;
      l_Task_Upd_Rec.OBJECT_VERSION_NUMBER	:= x_object_version_number;
      l_Task_Upd_Rec.ATTRIBUTE4		:= x_attribute4;
      l_Task_Upd_Rec.ATTRIBUTE5		:= x_attribute5;
      l_Task_Upd_Rec.ATTRIBUTE6		:= x_attribute6;
      l_Task_Upd_Rec.ATTRIBUTE7		:= x_attribute7;
      l_Task_Upd_Rec.ATTRIBUTE8		:= x_attribute8;
      l_Task_Upd_Rec.ATTRIBUTE9		:= x_attribute9;
      l_Task_Upd_Rec.ATTRIBUTE10	:= x_attribute10;
      l_Task_Upd_Rec.ATTRIBUTE11	:= x_attribute11;
      l_Task_Upd_Rec.ATTRIBUTE12	:= x_attribute12;
      l_Task_Upd_Rec.ATTRIBUTE13	:= x_attribute13;
      l_Task_Upd_Rec.ATTRIBUTE14	:= x_attribute14;
      l_Task_Upd_Rec.ATTRIBUTE15	:= x_attribute15;
      l_Task_Upd_Rec.ATTRIBUTE_CATEGORY	:= x_attribute_category;
      l_Task_Upd_Rec.TASK_NUMBER	:= x_task_number;
      l_Task_Upd_Rec.TASK_TYPE_ID	:= x_task_type_id;
      l_Task_Upd_Rec.TASK_STATUS_ID	:= x_task_status_id;
      l_Task_Upd_Rec.TASK_PRIORITY_ID	:= x_task_priority_id;
      l_Task_Upd_Rec.OWNER_ID		:= x_owner_id;
      l_Task_Upd_Rec.OWNER_TYPE_CODE	:= x_owner_type_code;
      l_Task_Upd_Rec.ASSIGNED_BY_ID	:= x_assigned_by_id;
      l_Task_Upd_Rec.CUST_ACCOUNT_ID	:= x_cust_account_id;
      l_Task_Upd_Rec.CUSTOMER_ID	:= x_customer_id;
      l_Task_Upd_Rec.ADDRESS_ID	:= x_address_id;
      l_Task_Upd_Rec.PLANNED_START_DATE	:= x_planned_start_date;
      l_Task_Upd_Rec.PALM_FLAG	:= x_palm_flag;
      l_Task_Upd_Rec.WINCE_FLAG	:= x_wince_flag;
      l_Task_Upd_Rec.LAPTOP_FLAG	:= x_laptop_flag;
      l_Task_Upd_Rec.DEVICE1_FLAG	:= x_device1_flag;
      l_Task_Upd_Rec.DEVICE2_FLAG	:= x_device2_flag;
      l_Task_Upd_Rec.DEVICE3_FLAG	:= x_device3_flag;
      l_Task_Upd_Rec.COSTS		:= x_costs;
      l_Task_Upd_Rec.CURRENCY_CODE	:= x_currency_code;
      l_Task_Upd_Rec.ATTRIBUTE1		:= x_attribute1;
      l_Task_Upd_Rec.ATTRIBUTE2		:= x_attribute2;
      l_Task_Upd_Rec.ATTRIBUTE3		:= x_attribute3;
      l_Task_Upd_Rec.NOTIFICATION_PERIOD	:= x_notification_period;
      l_Task_Upd_Rec.NOTIFICATION_PERIOD_UOM	:= x_notification_period_uom;
      l_Task_Upd_Rec.PARENT_TASK_ID	:= x_parent_task_id;
      l_Task_Upd_Rec.RECURRENCE_RULE_ID	:= x_recurrence_rule_id;
      l_Task_Upd_Rec.ALARM_START	:= x_alarm_start;
      l_Task_Upd_Rec.ALARM_START_UOM	:= x_alarm_start_uom;
      l_Task_Upd_Rec.ALARM_ON		:= x_alarm_on;
      l_Task_Upd_Rec.ALARM_COUNT	:= x_alarm_count;
      l_Task_Upd_Rec.ALARM_FIRED_COUNT	:= x_alarm_fired_count;
      l_Task_Upd_Rec.ALARM_INTERVAL	:= x_alarm_interval;
      l_Task_Upd_Rec.ALARM_INTERVAL_UOM	:= x_alarm_interval_uom;
      l_Task_Upd_Rec.DELETED_FLAG	:= x_deleted_flag;
      l_Task_Upd_Rec.ACTUAL_START_DATE	:= x_actual_start_date;
      l_Task_Upd_Rec.ACTUAL_END_DATE	:= x_actual_end_date;
      l_Task_Upd_Rec.SOURCE_OBJECT_TYPE_CODE	:= x_source_object_type_code;
      l_Task_Upd_Rec.TIMEZONE_ID	:= x_timezone_id;
      l_Task_Upd_Rec.SOURCE_OBJECT_ID	:= x_source_object_id;
      l_Task_Upd_Rec.SOURCE_OBJECT_NAME	:= x_source_object_name;
      l_Task_Upd_Rec.DURATION		:= x_duration;
      l_Task_Upd_Rec.DURATION_UOM	:= x_duration_uom;
      l_Task_Upd_Rec.PLANNED_EFFORT	:= x_planned_effort;
      l_Task_Upd_Rec.PLANNED_EFFORT_UOM	:= x_planned_effort_uom;
      l_Task_Upd_Rec.ACTUAL_EFFORT	:= x_actual_effort;
      l_Task_Upd_Rec.ACTUAL_EFFORT_UOM	:= x_actual_effort_uom;
      l_Task_Upd_Rec.PERCENTAGE_COMPLETE	:= x_percentage_complete;
      l_Task_Upd_Rec.REASON_CODE	:= x_reason_code;
      l_Task_Upd_Rec.PRIVATE_FLAG	:= x_private_flag;
      l_Task_Upd_Rec.PUBLISH_FLAG	:= x_publish_flag;
      l_Task_Upd_Rec.RESTRICT_CLOSURE_FLAG	:= x_restrict_closure_flag;
      l_Task_Upd_Rec.MULTI_BOOKED_FLAG	:= x_multi_booked_flag;
      l_Task_Upd_Rec.MILESTONE_FLAG	:= x_milestone_flag;
      l_Task_Upd_Rec.HOLIDAY_FLAG	:= x_holiday_flag;
      l_Task_Upd_Rec.BILLABLE_FLAG	:= x_billable_flag;
      l_Task_Upd_Rec.BOUND_MODE_CODE	:= x_bound_mode_code;
      l_Task_Upd_Rec.SOFT_BOUND_FLAG	:= x_soft_bound_flag;
      l_Task_Upd_Rec.WORKFLOW_PROCESS_ID	:= x_workflow_process_id;
      l_Task_Upd_Rec.NOTIFICATION_FLAG	:= x_notification_flag;
      l_Task_Upd_Rec.PLANNED_END_DATE	:= x_planned_end_date;
      l_Task_Upd_Rec.SCHEDULED_START_DATE	:= x_scheduled_start_date;
      l_Task_Upd_Rec.SCHEDULED_END_DATE	:= x_scheduled_end_date;
      l_Task_Upd_Rec.TASK_NAME		:= x_task_name;
      l_Task_Upd_Rec.DESCRIPTION	:= x_description;
      l_Task_Upd_Rec.LAST_UPDATE_DATE	:= x_last_update_date;
      l_Task_Upd_Rec.LAST_UPDATED_BY	:= x_last_updated_by;
      l_Task_Upd_Rec.LAST_UPDATE_LOGIN	:= x_last_update_login;
      l_Task_Upd_Rec.OWNER_TERRITORY_ID	:= x_owner_territory_id;
      l_Task_Upd_Rec.ESCALATION_LEVEL	:= x_escalation_level;
      l_Task_Upd_Rec.calendar_start_date	:= x_calendar_start_date;
      l_Task_Upd_Rec.calendar_end_date	:= x_calendar_end_date;
      l_Task_Upd_Rec.date_selected	:= x_date_selected;
      l_Task_Upd_Rec.open_flag		:= x_open_flag;
      l_Task_Upd_Rec.task_audit_id     := FND_API.G_MISS_NUM;
      l_Task_Upd_Rec.task_confirmation_status := x_task_confirmation_status;
      l_Task_Upd_Rec.task_confirmation_counter := x_task_confirmation_counter;
      l_Task_Upd_Rec.task_split_flag  := x_task_split_flag;
      l_Task_Upd_Rec.child_position   := x_child_position;
      l_Task_Upd_Rec.child_sequence_num := x_child_sequence_num;
	l_Task_Upd_Rec.location_id := x_location_id;

    -- call new version

	update_row ( p_Task_Upd_Rec => l_Task_Upd_Rec,
                     p_task_audit_id => l_task_audit_id);


   END update_row;


    -- new version which has task_audit_id

   PROCEDURE update_row (
	p_Task_Upd_Rec	IN 	JTF_TASKS_PKG.Task_Upd_Rec,
	p_Task_Audit_Id	OUT NOCOPY 	JTF_TASK_AUDITS_B.TASK_AUDIT_ID%TYPE
   )
   IS
      x_return_status   VARCHAR2(1);
      x_msg_data        VARCHAR2(2000);
      x_msg_count       NUMBER;

      l_source_object_type_code    jtf_tasks_b.source_object_type_code%type ;
      l_source_object_id    jtf_tasks_b.source_object_id%type ;
      l_source_object_name    jtf_tasks_b.source_object_name%type ;

      l_task_audit_id   number :=-1;
      my_message           VARCHAR2(2000);
      l_count                  NUMBER;
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_enable_audit         varchar2(5);

      l_Task_Upd_Rec       JTF_TASKS_PKG.Task_Upd_Rec := p_Task_Upd_Rec;

   BEGIN
    l_enable_audit := Upper(nvl(fnd_profile.Value('JTF_TASK_ENABLE_AUDIT'),'Y'));
    IF(l_enable_audit = 'Y') THEN
      jtf_task_audits_pvt.create_task_audits (
         p_api_version => 1,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_object_version_number => l_Task_Upd_Rec.object_version_number,
         p_task_id => l_Task_Upd_Rec.task_id,
         p_new_billable_flag => l_Task_Upd_Rec.billable_flag,
         p_new_device1_flag => l_Task_Upd_Rec.device1_flag,
         p_new_device2_flag => l_Task_Upd_Rec.device2_flag,
         p_new_device3_flag => l_Task_Upd_Rec.device3_flag,
         p_new_holiday_flag => l_Task_Upd_Rec.holiday_flag,
         p_new_laptop_flag => l_Task_Upd_Rec.laptop_flag,
         p_new_milestone_flag => l_Task_Upd_Rec.milestone_flag,
         p_new_multi_booked_flag => l_Task_Upd_Rec.multi_booked_flag,
         p_new_not_flag => l_Task_Upd_Rec.notification_flag,
         p_new_palm_flag => l_Task_Upd_Rec.palm_flag,
         p_new_private_flag => l_Task_Upd_Rec.private_flag,
         p_new_publish_flag => l_Task_Upd_Rec.publish_flag,
         p_new_restrict_closure_flag => l_Task_Upd_Rec.restrict_closure_flag,
         p_new_wince_flag => l_Task_Upd_Rec.wince_flag,
         p_new_soft_bound_flag => l_Task_Upd_Rec.soft_bound_flag,
         p_new_actual_effort => l_Task_Upd_Rec.actual_effort,
         p_new_actual_effort_uom => l_Task_Upd_Rec.actual_effort_uom,
         p_new_actual_end_date => l_Task_Upd_Rec.actual_end_date,
         p_new_actual_start_date => l_Task_Upd_Rec.actual_start_date,
         p_new_address_id => l_Task_Upd_Rec.address_id,
         p_new_assigned_by_id => l_Task_Upd_Rec.assigned_by_id,
         p_new_bound_mode_code => l_Task_Upd_Rec.bound_mode_code,
         p_new_costs => l_Task_Upd_Rec.costs,
         p_new_currency_code => l_Task_Upd_Rec.currency_code,
         p_new_customer_id => l_Task_Upd_Rec.customer_id,
         p_new_cust_account_id => l_Task_Upd_Rec.cust_account_id,
         p_new_duration => l_Task_Upd_Rec.duration,
         p_new_duration_uom => l_Task_Upd_Rec.duration_uom,
         p_new_not_period => l_Task_Upd_Rec.notification_period,
         p_new_not_period_uom => l_Task_Upd_Rec.notification_period_uom,
         p_new_owner_id => l_Task_Upd_Rec.owner_id,
         p_new_owner_type_code => l_Task_Upd_Rec.owner_type_code,
         p_new_parent_task_id => l_Task_Upd_Rec.parent_task_id,
         p_new_per_complete => l_Task_Upd_Rec.percentage_complete,
         p_new_planned_effort => l_Task_Upd_Rec.planned_effort,
         p_new_planned_effort_uom => l_Task_Upd_Rec.planned_effort_uom,
         p_new_planned_end_date => l_Task_Upd_Rec.planned_end_date,
         p_new_planned_start_date => l_Task_Upd_Rec.planned_start_date,
         p_new_reason_code => l_Task_Upd_Rec.reason_code,
         p_new_recurrence_rule_id => l_Task_Upd_Rec.recurrence_rule_id,
         p_new_sched_end_date => l_Task_Upd_Rec.scheduled_end_date,
         p_new_sched_start_date => l_Task_Upd_Rec.scheduled_start_date,
         p_new_src_obj_id => l_Task_Upd_Rec.source_object_id,
         p_new_src_obj_name => l_Task_Upd_Rec.source_object_name,
         p_new_src_obj_type_code => l_Task_Upd_Rec.source_object_type_code,
         p_new_task_priority_id => l_Task_Upd_Rec.task_priority_id,
         p_new_task_status_id => l_Task_Upd_Rec.task_status_id,
         p_new_task_type_id => l_Task_Upd_Rec.task_type_id,
         p_new_timezone_id => l_Task_Upd_Rec.timezone_id,
         p_new_workflow_process_id => l_Task_Upd_Rec.workflow_process_id,
         p_not_chan_flag => NULL,
         p_new_description => l_Task_Upd_Rec.description,
         p_new_task_name => l_Task_Upd_Rec.task_name,
         p_new_escalation_level => l_Task_Upd_Rec.escalation_level,
         p_new_owner_territory_id => l_Task_Upd_Rec.owner_territory_id,
         p_new_date_selected => l_Task_Upd_Rec.date_selected,
         p_new_location_id => l_Task_Upd_Rec.location_id,
        -- p_new_task_conf_status => l_Task_Upd_Rec.task_confirmation_status,
        -- p_new_task_conf_counter => l_Task_Upd_Rec.task_confirmation_counter,
        -- p_new_task_split_flag	=> l_Task_Upd_Rec.task_split_flag,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_task_audit_id => l_task_audit_id
      );
    END IF;
      p_task_audit_id	:= l_task_audit_id;

      UPDATE jtf_tasks_b
         SET attribute4 = l_Task_Upd_Rec.attribute4,
             object_version_number = l_Task_Upd_Rec.object_version_number,
             attribute5 = l_Task_Upd_Rec.attribute5,
             attribute6 = l_Task_Upd_Rec.attribute6,
             attribute7 = l_Task_Upd_Rec.attribute7,
             attribute8 = l_Task_Upd_Rec.attribute8,
             attribute9 = l_Task_Upd_Rec.attribute9,
             attribute10 = l_Task_Upd_Rec.attribute10,
             attribute11 = l_Task_Upd_Rec.attribute11,
             attribute12 = l_Task_Upd_Rec.attribute12,
             attribute13 = l_Task_Upd_Rec.attribute13,
             attribute14 = l_Task_Upd_Rec.attribute14,
             attribute15 = l_Task_Upd_Rec.attribute15,
             attribute_category = l_Task_Upd_Rec.attribute_category,
             task_number = l_Task_Upd_Rec.task_number,
             task_type_id = l_Task_Upd_Rec.task_type_id,
             task_status_id = l_Task_Upd_Rec.task_status_id,
             task_priority_id = l_Task_Upd_Rec.task_priority_id,
             owner_id = l_Task_Upd_Rec.owner_id,
             owner_type_code = l_Task_Upd_Rec.owner_type_code,
             assigned_by_id = l_Task_Upd_Rec.assigned_by_id,
             cust_account_id = l_Task_Upd_Rec.cust_account_id,
             customer_id = l_Task_Upd_Rec.customer_id,
             address_id = l_Task_Upd_Rec.address_id,
             planned_start_date = l_Task_Upd_Rec.planned_start_date,
             palm_flag = l_Task_Upd_Rec.palm_flag,
             wince_flag = l_Task_Upd_Rec.wince_flag,
             laptop_flag = l_Task_Upd_Rec.laptop_flag,
             device1_flag = l_Task_Upd_Rec.device1_flag,
             device2_flag = l_Task_Upd_Rec.device2_flag,
             device3_flag = l_Task_Upd_Rec.device3_flag,
             costs = l_Task_Upd_Rec.costs,
             currency_code = l_Task_Upd_Rec.currency_code,
             attribute1 = l_Task_Upd_Rec.attribute1,
             attribute2 = l_Task_Upd_Rec.attribute2,
             attribute3 = l_Task_Upd_Rec.attribute3,
             notification_period = l_Task_Upd_Rec.notification_period,
             notification_period_uom = l_Task_Upd_Rec.notification_period_uom,
             parent_task_id = l_Task_Upd_Rec.parent_task_id,
             recurrence_rule_id = l_Task_Upd_Rec.recurrence_rule_id,
             alarm_start = l_Task_Upd_Rec.alarm_start,
             alarm_start_uom = l_Task_Upd_Rec.alarm_start_uom,
             alarm_on = l_Task_Upd_Rec.alarm_on,
             alarm_count = l_Task_Upd_Rec.alarm_count,
             alarm_fired_count = l_Task_Upd_Rec.alarm_fired_count,
             alarm_interval = l_Task_Upd_Rec.alarm_interval,
             alarm_interval_uom = l_Task_Upd_Rec.alarm_interval_uom,
             deleted_flag = l_Task_Upd_Rec.deleted_flag,
             actual_start_date = l_Task_Upd_Rec.actual_start_date,
             actual_end_date = l_Task_Upd_Rec.actual_end_date,
             source_object_type_code = l_Task_Upd_Rec.source_object_type_code,
             timezone_id = l_Task_Upd_Rec.timezone_id,
             source_object_id = l_Task_Upd_Rec.source_object_id,
             source_object_name = l_Task_Upd_Rec.source_object_name,
             duration = l_Task_Upd_Rec.duration,
             duration_uom = l_Task_Upd_Rec.duration_uom,
             planned_effort = l_Task_Upd_Rec.planned_effort,
             planned_effort_uom = l_Task_Upd_Rec.planned_effort_uom,
             actual_effort = l_Task_Upd_Rec.actual_effort,
             actual_effort_uom = l_Task_Upd_Rec.actual_effort_uom,
             percentage_complete = l_Task_Upd_Rec.percentage_complete,
             reason_code = l_Task_Upd_Rec.reason_code,
             private_flag = l_Task_Upd_Rec.private_flag,
             publish_flag = l_Task_Upd_Rec.publish_flag,
             restrict_closure_flag = l_Task_Upd_Rec.restrict_closure_flag,
             multi_booked_flag = l_Task_Upd_Rec.multi_booked_flag,
             milestone_flag = l_Task_Upd_Rec.milestone_flag,
             holiday_flag = l_Task_Upd_Rec.holiday_flag,
             billable_flag = l_Task_Upd_Rec.billable_flag,
             bound_mode_code = l_Task_Upd_Rec.bound_mode_code,
             soft_bound_flag = l_Task_Upd_Rec.soft_bound_flag,
             workflow_process_id = l_Task_Upd_Rec.workflow_process_id,
             notification_flag = l_Task_Upd_Rec.notification_flag,
             planned_end_date = l_Task_Upd_Rec.planned_end_date,
             scheduled_start_date = l_Task_Upd_Rec.scheduled_start_date,
             scheduled_end_date = l_Task_Upd_Rec.scheduled_end_date,
             last_update_date = l_Task_Upd_Rec.last_update_date,
             last_updated_by = l_Task_Upd_Rec.last_updated_by,
             last_update_login = l_Task_Upd_Rec.last_update_login,
             owner_territory_id = l_Task_Upd_Rec.owner_territory_id,
             escalation_level = l_Task_Upd_Rec.escalation_level,
             calendar_start_date = decode(calendar_start_date, jtf_task_utl.g_miss_date, calendar_start_date, l_Task_Upd_Rec.calendar_start_date),
             calendar_end_date = decode(calendar_end_date, jtf_task_utl.g_miss_date, calendar_end_date, l_Task_Upd_Rec.calendar_end_date),
             date_selected = decode(date_selected, jtf_task_utl.g_miss_char, date_selected, l_Task_Upd_Rec.date_selected),
             object_changed_date = SYSDATE,
             open_flag = l_Task_Upd_Rec.open_flag,
             task_confirmation_status  =  l_Task_Upd_Rec.task_confirmation_status,
             task_confirmation_counter = l_Task_Upd_Rec.task_confirmation_counter,
             task_split_flag	       = l_Task_Upd_Rec.task_split_flag,
             child_position            = l_Task_Upd_Rec.child_position,
             child_sequence_num        = l_Task_Upd_Rec.child_sequence_num,
		--task_audit_id = p_task_audit_id
             location_id = l_Task_Upd_Rec.location_id
       WHERE task_id = l_Task_Upd_Rec.task_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE jtf_tasks_tl
         SET task_name = l_Task_Upd_Rec.task_name,
             description = l_Task_Upd_Rec.description,
             last_update_date = l_Task_Upd_Rec.last_update_date,
             last_updated_by = l_Task_Upd_Rec.last_updated_by,
             last_update_login = l_Task_Upd_Rec.last_update_login,
             source_lang = USERENV ('LANG')
       WHERE task_id = l_Task_Upd_Rec.task_id
         AND USERENV ('LANG') IN (language, source_lang);

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

   END update_row;

--End BES Changes

   PROCEDURE delete_row (x_task_id IN NUMBER)
   IS

   x_return_status   varchar2(1);

   BEGIN
      null;
   END delete_row;

   PROCEDURE add_language
   IS
   BEGIN

     /* Solving Perf. Bug 3723927*/
     /* The following delete and update statements are commented out */
     /* as a quick workaround to fix the time-consuming table handler issue */
     /*

     /* DELETE
        FROM jtf_tasks_tl t
       WHERE NOT EXISTS (SELECT NULL
                           FROM jtf_tasks_b b
                          WHERE b.task_id = t.task_id);
      UPDATE jtf_tasks_tl t
         SET (task_name, description) = ( SELECT b.task_name, b.description
                                            FROM jtf_tasks_tl b
                                           WHERE b.task_id = t.task_id
                                             AND b.language = t.source_lang)
       WHERE (t.task_id, t.language) IN (SELECT subt.task_id, subt.language
                                           FROM jtf_tasks_tl subb, jtf_tasks_tl subt
                                          WHERE subb.task_id = subt.task_id
                                            AND subb.language = subt.source_lang
                                            AND (  subb.task_name <> subt.task_name
                                                OR subb.description <> subt.description
                                                OR (   subb.description IS NULL
                                                   AND subt.description IS NOT NULL)
                                                OR (   subb.description IS NOT NULL
                                                   AND subt.description IS NULL)));

      INSERT INTO jtf_tasks_tl
                  (task_name,
                   description,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   task_id,
                   language,
                   source_lang
                  )
         SELECT b.task_name,
                b.description,
                b.created_by,
                b.creation_date,
                b.last_updated_by,
                b.last_update_date,
                b.last_update_login,
                b.task_id,
                l.language_code,
                b.source_lang
           FROM jtf_tasks_tl b, fnd_languages l
          WHERE l.installed_flag IN ('I', 'B')
            AND b.language = USERENV ('LANG')
            AND NOT EXISTS (SELECT NULL
                              FROM jtf_tasks_tl t
                             WHERE t.task_id = b.task_id
                               AND t.language = l.language_code);

      *** Additional fix for the same bug is to add parallel hints to insert.
      *** Replaced the original query with one below (mmmarovic on 3/7/05)
      */
        INSERT /*+ append parallel(tl) */ INTO jtf_tasks_tl tl
 	      (task_name, description, created_by, creation_date,
	       last_updated_by, last_update_date, last_update_login,
	       task_id, language, source_lang)
 	   SELECT /*+ parallel(v) parallel(t) use_nl(t) */ v.*
 	     FROM ( SELECT /*+ no_merge ordered parallel(b) */
 	                   b.task_name, b.description, b.created_by, b.creation_date,
			   b.last_updated_by, b.last_update_date, b.last_update_login,
			   b.task_id, l.language_code, b.source_lang
 	              FROM fnd_languages l, jtf_tasks_tl b
 	             WHERE l.installed_flag IN ('I', 'B')
 	               AND b.language = USERENV ('LANG')
 	           ) v, jtf_tasks_tl t
 	    WHERE t.task_id(+) = v.task_id
 	      AND t.language(+) = v.language_code
 	      AND t.task_id IS NULL;

   END add_language;

procedure translate_row(
   x_task_id in number,
   x_task_name   in varchar2,
   x_description   in varchar2,
   x_owner   in varchar2 )
as
begin
  update jtf_tasks_tl set
    task_name = nvl(x_task_name,task_name),
    description = nvl(x_description,description),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATEd_by = decode(x_owner,'SEED',1,0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where task_id = X_task_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end;

END jtf_tasks_pkg;

/
