--------------------------------------------------------
--  DDL for Package Body JTF_TASK_TEMPLATES_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_TEMPLATES_UTL" AS
/* $Header: jtfptutb.pls 120.8.12000000.2 2007/06/29 09:40:42 tduggara ship $ */

   PROCEDURE validate_task_template_group (
      p_task_template_group_id IN NUMBER
   )
   IS
      -- Bug 3374694: modified cursor query for truncating time portion of dates.
      CURSOR c_task_template_group_id
      IS
      SELECT task_template_group_id
	FROM jtf_task_temp_groups_b
       WHERE task_template_group_id = p_task_template_group_id
	 AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	 AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);

      x_task_template_group_id	 NUMBER;
   BEGIN
      IF p_task_template_group_id IS NOT NULL
      THEN
	 OPEN c_task_template_group_id;
	 FETCH c_task_template_group_id INTO x_task_template_group_id;
	 IF c_task_template_group_id%NOTFOUND
	 THEN
	    CLOSE c_task_template_group_id;
	    fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP_GRP');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
	 CLOSE c_task_template_group_id;
      ELSE
	  fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP_GRP');
	  fnd_msg_pub.add;
	  RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END;  -- Procedure End

   PROCEDURE validate_create_template (
      p_task_template_info IN jtf_task_inst_templates_pub.task_template_info,
      p_source_object_type_code IN jtf_objects_b.object_code%TYPE,
      p_task_template_group_info IN jtf_task_inst_templates_pub.task_template_group_info,
      x_task_id OUT NOCOPY NUMBER,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR c_task_template (
	 p_task_template_group_id IN NUMBER,
	 task_template_record IN jtf_task_inst_templates_pub.task_template_info
      )
      IS
	 SELECT task_template_id,
		task_number,
		DECODE (
		   task_template_record.task_name,
		   NULL, task_name,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.task_name
		) task_name,
		DECODE (
		   task_template_record.description,
		   NULL, description,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.description
		) description,
		DECODE (
		   task_template_record.task_type_id,
		   NULL, task_type_id,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.task_type_id
		) task_type_id,
		DECODE (
		   task_template_record.task_status_id,
		   NULL, task_status_id,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.task_status_id
		) task_status_id,
		DECODE (
		   task_template_record.task_priority_id,
		   NULL, task_priority_id,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.task_priority_id
		) task_priority_id,
		DECODE (
		   task_template_record.duration,
		   NULL, duration,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.duration
		) duration,
		DECODE (
		   task_template_record.duration_uom,
		   NULL, duration_uom,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.duration_uom
		) duration_uom,
		DECODE (
		   task_template_record.planned_effort,
		   NULL, planned_effort,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.planned_effort
		) planned_effort,
		DECODE (
		   task_template_record.planned_effort_uom,
		   NULL, planned_effort_uom,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.planned_effort_uom
		) planned_effort_uom,
		DECODE (
		   task_template_record.private_flag,
		   NULL, private_flag,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.private_flag
		) private_flag,
		publish_flag,
		DECODE (
		   task_template_record.restrict_closure_flag,
		   NULL, restrict_closure_flag,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.restrict_closure_flag
		) restrict_closure_flag,
		multi_booked_flag,
		milestone_flag,
		holiday_flag,
		billable_flag,
		notification_flag,
		notification_period,
		notification_period_uom,
		recurrence_rule_id,
		alarm_start,
		alarm_start_uom,
		alarm_on,
		alarm_count,
		alarm_interval,
		alarm_interval_uom,
		task_template_record.palm_flag palm_flag,
		task_template_record.wince_flag wince_flag,
		task_template_record.laptop_flag laptop_flag,
		task_template_record.device1_flag device1_flag,
		task_template_record.device2_flag device2_flag,
		task_template_record.device3_flag device3_flag,
		task_template_record.timezone_id timezone_id,
		DECODE (
		   task_template_record.attribute1,
		   NULL, attribute1,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute1
		) attribute1,
		DECODE (
		   task_template_record.attribute2,
		   NULL, attribute2,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute2
		) attribute2,
		DECODE (
		   task_template_record.attribute3,
		   NULL, attribute3,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute3
		) attribute3,
		DECODE (
		   task_template_record.attribute4,
		   NULL, attribute4,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute4
		) attribute4,
		DECODE (
		   task_template_record.attribute5,
		   NULL, attribute5,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute5
		) attribute5,
		DECODE (
		   task_template_record.attribute6,
		   NULL, attribute6,
		   task_template_record.attribute6
		) attribute6,
		DECODE (
		   task_template_record.attribute7,
		   NULL, attribute7,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute7
		) attribute7,
		DECODE (
		   task_template_record.attribute8,
		   NULL, attribute8,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute8
		) attribute8,
		DECODE (
		   task_template_record.attribute9,
		   NULL, attribute9,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute9
		) attribute9,
		DECODE (
		   task_template_record.attribute10,
		   NULL, attribute10,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute10
		) attribute10,
		DECODE (
		   task_template_record.attribute11,
		   NULL, attribute11,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute11
		) attribute11,
		DECODE (
		   task_template_record.attribute12,
		   NULL, attribute12,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute12
		) attribute12,
		DECODE (
		   task_template_record.attribute13,
		   NULL, attribute13,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute13
		) attribute13,
		DECODE (
		   task_template_record.attribute14,
		   NULL, attribute14,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute14
		) attribute14,
		DECODE (
		   task_template_record.attribute15,
		   NULL, attribute15,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute15
		) attribute15,
		DECODE (
		   task_template_record.attribute_category,
		   NULL, attribute_category,
		   FND_API.G_MISS_CHAR, NULL,
		   task_template_record.attribute_category
		) attribute_category,
        DECODE (
		   task_template_record.task_confirmation_status,
		   NULL,task_confirmation_status,
		   jtf_task_utl.G_MISS_CHAR, NULL,
		   task_template_record.task_confirmation_status
		) task_confirmation_status
	   FROM jtf_task_templates_vl
	  WHERE task_group_id = p_task_template_group_id
	    AND task_template_id = task_template_record.task_template_id;

       l_task_template_rec   c_task_template%ROWTYPE;

       -- Added by SBARAT on 06/01/2005 for bug# 4898434
       Cursor C_Object_Version_Num(p_task_id  NUMBER) Is
             Select object_version_number From JTF_TASKS_VL
                    Where task_id=p_task_id;

        l_object_version_number   NUMBER;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      OPEN c_task_template (p_task_template_group_info.task_template_group_id, p_task_template_info);
      FETCH c_task_template INTO l_task_template_rec;

      IF c_task_template%NOTFOUND
      THEN
	 CLOSE c_task_template;
	 fnd_message.set_name ('JTF', 'JTF_TASK_NO_TEMP_FOUND');
	 fnd_message.set_token ('task_template_id', p_task_template_info.task_template_id);
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_tasks_pub.create_task (
	 p_api_version => 1.0,
	 p_init_msg_list => fnd_api.g_false,
	 p_commit => fnd_api.g_false,
	 p_task_name => l_task_template_rec.task_name,
	 p_task_type_id => l_task_template_rec.task_type_id,
	 p_description => l_task_template_rec.description,
	 p_task_status_id => l_task_template_rec.task_status_id,
	 p_task_priority_id => l_task_template_rec.task_priority_id,
	 p_owner_type_code => p_task_template_info.owner_type_code,
	 p_owner_id => p_task_template_info.owner_id,
       p_owner_territory_id => p_task_template_group_info.owner_territory_id,     -- Added by SBARAT on 28/10/2005 for bug# 4597321
	 p_duration => l_task_template_rec.duration,
	 p_duration_uom => l_task_template_rec.duration_uom,
	 p_planned_effort => l_task_template_rec.planned_effort,
	 p_planned_effort_uom => l_task_template_rec.planned_effort_uom,
	 p_private_flag => l_task_template_rec.private_flag,
	 p_publish_flag => l_task_template_rec.publish_flag,
	 p_restrict_closure_flag => l_task_template_rec.restrict_closure_flag,
	 p_multi_booked_flag => l_task_template_rec.multi_booked_flag,
	 p_milestone_flag => l_task_template_rec.milestone_flag,
	 p_holiday_flag => l_task_template_rec.holiday_flag,
	 p_billable_flag => l_task_template_rec.billable_flag,
	 p_notification_flag => l_task_template_rec.notification_flag,
	 p_notification_period => l_task_template_rec.notification_period,
	 p_notification_period_uom => l_task_template_rec.notification_period_uom,
	 p_source_object_type_code => p_source_object_type_code,
	 p_source_object_id => p_task_template_group_info.source_object_id,
	 p_source_object_name => p_task_template_group_info.source_object_name,
	 p_alarm_start => l_task_template_rec.alarm_start,
	 p_alarm_start_uom => l_task_template_rec.alarm_start_uom,
	 p_alarm_on => l_task_template_rec.alarm_on,
	 p_alarm_count => l_task_template_rec.alarm_count,
	 p_alarm_interval => l_task_template_rec.alarm_interval,
	 p_alarm_interval_uom => l_task_template_rec.alarm_interval_uom,
	 x_return_status => x_return_status,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data,
	 x_task_id => x_task_id,
	 p_cust_account_id => p_task_template_group_info.cust_account_id,
	 p_customer_id => p_task_template_group_info.customer_id,
	 p_address_id => p_task_template_group_info.address_id,
	 p_planned_start_date => p_task_template_info.planned_start_date,
	 p_planned_end_date => p_task_template_info.planned_end_date,
	 p_scheduled_start_date => p_task_template_info.scheduled_start_date,
	 p_scheduled_end_date => p_task_template_info.scheduled_end_date,
	 p_actual_start_date => p_task_template_info.actual_start_date,
	 p_actual_end_date => p_task_template_info.actual_end_date,
	 p_palm_flag => l_task_template_rec.palm_flag,
	 p_wince_flag => l_task_template_rec.wince_flag,
	 p_laptop_flag => l_task_template_rec.laptop_flag,
	 p_device1_flag => l_task_template_rec.device1_flag,
	 p_device2_flag => l_task_template_rec.device2_flag,
	 p_device3_flag => l_task_template_rec.device3_flag,
	 p_timezone_id => l_task_template_rec.timezone_id,
	 p_attribute1 => l_task_template_rec.attribute1,
	 p_attribute2 => l_task_template_rec.attribute2,
	 p_attribute3 => l_task_template_rec.attribute3,
	 p_attribute4 => l_task_template_rec.attribute4,
	 p_attribute5 => l_task_template_rec.attribute5,
	 p_attribute6 => l_task_template_rec.attribute6,
	 p_attribute7 => l_task_template_rec.attribute7,
	 p_attribute8 => l_task_template_rec.attribute8,
	 p_attribute9 => l_task_template_rec.attribute9,
	 p_attribute10 => l_task_template_rec.attribute10,
	 p_attribute11 => l_task_template_rec.attribute11,
	 p_attribute12 => l_task_template_rec.attribute12,
	 p_attribute13 => l_task_template_rec.attribute13,
	 p_attribute14 => l_task_template_rec.attribute14,
	 p_attribute15 => l_task_template_rec.attribute15,
	 p_attribute_category => l_task_template_rec.attribute_category,
	 p_date_selected => p_task_template_info.p_date_selected,
	 p_show_on_calendar => p_task_template_info.show_on_calendar,
	 p_template_id => l_task_template_rec.task_template_id,
	 p_template_group_id => p_task_template_group_info.task_template_group_id,
	 p_enable_workflow	=> fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
	 p_abort_workflow	      => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
       p_task_split_flag      => NULL,
       p_reference_flag       => NULL,
       p_child_position       => NULL,
       p_child_sequence_num   => NULL,
       p_location_id          => p_task_template_group_info.location_id
      );
      CLOSE c_task_template;

      /******* Start of modification by SBARAT on 06/01/2005 for bug# 4898434 *******/

      Open C_Object_Version_Num(x_task_id);
      Fetch C_Object_Version_Num Into l_object_version_number;
      Close C_Object_Version_Num;

      IF l_object_version_number IS NULL
      THEN
          l_object_version_number := 1 ;
      END IF;

      /******* End of modification by SBARAT on 06/01/2005 for bug# 4898434 *******/

   -- Commented out the call of reset_confirmation_status. Instead, we are now calling
   -- set_counter_status to set the confirmation_status. Changes done due to bug# 4352360
   /* jtf_task_confirmation_pub.reset_confirmation_status
    (
       p_api_version => 1.0,
	   p_init_msg_list => fnd_api.g_false,
	   p_commit => fnd_api.g_false,
       p_object_version_number => l_object_version_number,
       p_task_id	     => x_task_id,
       x_return_status => x_return_status,
	   x_msg_count => x_msg_count,
	   x_msg_data => x_msg_data
    ); */

      jtf_task_confirmation_pub.set_counter_status(
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_object_version_number => l_object_version_number,
         p_task_id => x_task_id,
         p_task_confirmation_status => l_task_template_rec.task_confirmation_status,
         p_task_confirmation_counter => 0);

   END;

    PROCEDURE create_template_group_tasks (
      p_source_object_type_code IN jtf_objects_b.object_code%TYPE,
      p_task_template_group_info IN jtf_task_inst_templates_pub.task_template_group_info,
      x_task_details_tbl OUT NOCOPY jtf_task_inst_templates_pub.task_details_tbl,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR c_task_template
      IS
	 SELECT task_template_id,
		task_number,
		task_name,
		description,
		task_type_id,
		task_status_id,
		task_priority_id,
		duration,
		duration_uom,
		planned_effort,
		planned_effort_uom,
		private_flag,
		publish_flag,
		restrict_closure_flag,
		multi_booked_flag,
		milestone_flag,
		holiday_flag,
		billable_flag,
		notification_flag,
		notification_period,
		notification_period_uom,
		recurrence_rule_id,
		alarm_start,
		alarm_start_uom,
		alarm_on,
		alarm_count,
		alarm_interval,
		alarm_interval_uom,
		p_task_template_group_info.owner_type_code,
		p_task_template_group_info.owner_id,
            p_task_template_group_info.owner_territory_id,    -- Added by SBARAT on 28/10/2005 for bug# 4597321
		p_task_template_group_info.source_object_id,
		p_task_template_group_info.source_object_name,
		p_task_template_group_info.cust_account_id,
		p_task_template_group_info.customer_id,
		p_task_template_group_info.address_id,
		p_task_template_group_info.assigned_by_id,
		p_task_template_group_info.actual_start_date,
		p_task_template_group_info.actual_end_date,
		p_task_template_group_info.planned_start_date,
		p_task_template_group_info.planned_end_date,
		p_task_template_group_info.scheduled_start_date,
		p_task_template_group_info.scheduled_end_date,
		p_task_template_group_info.palm_flag palm_flag,
		p_task_template_group_info.wince_flag wince_flag,
		p_task_template_group_info.laptop_flag laptop_flag,
		p_task_template_group_info.device1_flag device1_flag,
		p_task_template_group_info.device2_flag device2_flag,
		p_task_template_group_info.device3_flag device3_flag,
		p_task_template_group_info.parent_task_id,  -- Added by SBARAT on 11/07/2005 for bug# 4376274
		p_task_template_group_info.timezone_id timezone_id,
		p_task_template_group_info.percentage_complete,
		p_task_template_group_info.actual_effort,
		p_task_template_group_info.actual_effort_uom,
		p_task_template_group_info.reason_code,
		p_task_template_group_info.bound_mode_code,
		p_task_template_group_info.soft_bound_flag,
		p_task_template_group_info.workflow_process_id,
		p_task_template_group_info.costs,
		p_task_template_group_info.currency_code,
		p_task_template_group_info.date_selected,
		p_task_template_group_info.show_on_calendar,
		DECODE (
		   p_task_template_group_info.attribute1,
		   NULL, attribute1,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute1
		) attribute1,
		DECODE (
		   p_task_template_group_info.attribute2,
		   NULL, attribute2,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute2
		) attribute2,
		DECODE (
		   p_task_template_group_info.attribute3,
		   NULL, attribute3,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute3
		) attribute3,
		DECODE (
		   p_task_template_group_info.attribute4,
		   NULL, attribute4,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute4
		) attribute4,
		DECODE (
		   p_task_template_group_info.attribute5,
		   NULL, attribute5,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute5
		) attribute5,
		DECODE (
		   p_task_template_group_info.attribute6,
		   NULL, attribute6,
		   p_task_template_group_info.attribute6
		) attribute6,
		DECODE (
		   p_task_template_group_info.attribute7,
		   NULL, attribute7,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute7
		) attribute7,
		DECODE (
		   p_task_template_group_info.attribute8,
		   NULL, attribute8,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute8
		) attribute8,
		DECODE (
		   p_task_template_group_info.attribute9,
		   NULL, attribute9,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute9
		) attribute9,
		DECODE (
		   p_task_template_group_info.attribute10,
		   NULL, attribute10,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute10
		) attribute10,
		DECODE (
		   p_task_template_group_info.attribute11,
		   NULL, attribute11,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute11
		) attribute11,
		DECODE (
		   p_task_template_group_info.attribute12,
		   NULL, attribute12,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute12
		) attribute12,
		DECODE (
		   p_task_template_group_info.attribute13,
		   NULL, attribute13,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute13
		) attribute13,
		DECODE (
		   p_task_template_group_info.attribute14,
		   NULL, attribute14,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute14
		) attribute14,
		DECODE (
		   p_task_template_group_info.attribute15,
		   NULL, attribute15,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute15
		) attribute15,
		DECODE (
		   p_task_template_group_info.attribute_category,
		   NULL, attribute_category,
		   FND_API.G_MISS_CHAR, NULL,
		   p_task_template_group_info.attribute_category
		) attribute_category,
                decode (
                  task_confirmation_status,
                  null, 'N',
                  task_confirmation_status
                ) task_confirmation_status
	  FROM jtf_task_templates_vl
	     WHERE task_group_id = p_task_template_group_info.task_template_group_id
             AND   nvl(deleted_flag,'N') <> 'Y'
             ORDER BY task_template_id;

      task_template_rec   c_task_template%ROWTYPE;
      l_task_id  NUMBER;

       -- Added by SBARAT on 06/01/2005 for bug# 4898434
       Cursor C_Object_Version_Num(p_task_id  NUMBER) Is
             Select object_version_number From JTF_TASKS_VL
                    Where task_id=p_task_id;

      l_object_version_number NUMBER;
      i NUMBER := 1 ;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      FOR task_template_rec IN c_task_template
      LOOP
      jtf_tasks_pub.create_task (
	 p_api_version => 1.0,
	 p_init_msg_list => fnd_api.g_false,
	 p_commit => fnd_api.g_false,
	 p_task_name => task_template_rec.task_name,
	 p_task_type_id => task_template_rec.task_type_id,
	 p_description => task_template_rec.description,
	 p_task_status_id => task_template_rec.task_status_id,
	 p_task_priority_id => task_template_rec.task_priority_id,
	 p_owner_type_code => task_template_rec.owner_type_code,
	 p_owner_id => task_template_rec.owner_id,
       p_owner_territory_id => task_template_rec.owner_territory_id,  -- Added by SBARAT on 28/10/2005 for bug# 4597321
	 p_duration => task_template_rec.duration,
	 p_duration_uom => task_template_rec.duration_uom,
	 p_planned_effort => task_template_rec.planned_effort,
	 p_planned_effort_uom => task_template_rec.planned_effort_uom,
	 p_private_flag => task_template_rec.private_flag,
	 p_publish_flag => task_template_rec.publish_flag,
	 p_restrict_closure_flag => task_template_rec.restrict_closure_flag,
	 p_multi_booked_flag => task_template_rec.multi_booked_flag,
	 p_milestone_flag => task_template_rec.milestone_flag,
	 p_holiday_flag => task_template_rec.holiday_flag,
	 p_billable_flag => task_template_rec.billable_flag,
	 p_notification_flag => task_template_rec.notification_flag,
	 p_notification_period => task_template_rec.notification_period,
	 p_notification_period_uom => task_template_rec.notification_period_uom,
	 p_source_object_type_code => p_source_object_type_code,
	 p_source_object_id => task_template_rec.source_object_id,
	 p_source_object_name => task_template_rec.source_object_name,
	 p_alarm_start => task_template_rec.alarm_start,
	 p_alarm_start_uom => task_template_rec.alarm_start_uom,
	 p_alarm_on => task_template_rec.alarm_on,
	 p_alarm_count => task_template_rec.alarm_count,
	 p_alarm_interval => task_template_rec.alarm_interval,
	 p_alarm_interval_uom => task_template_rec.alarm_interval_uom,
	 x_return_status => x_return_status,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data,
	 x_task_id => l_task_id,
	 p_cust_account_id => task_template_rec.cust_account_id,
	 p_customer_id => task_template_rec.customer_id,
	 p_address_id => task_template_rec.address_id,
	 p_planned_start_date => task_template_rec.planned_start_date,
	 p_planned_end_date => task_template_rec.planned_end_date,
	 p_scheduled_start_date => task_template_rec.scheduled_start_date,
	 p_scheduled_end_date => task_template_rec.scheduled_end_date,
	 p_actual_start_date => task_template_rec.actual_start_date,
	 p_actual_end_date => task_template_rec.actual_end_date,
	 p_parent_task_id=> task_template_rec.parent_task_id,  -- Added by SBARAT on 11/07/2005 for bug# 4376274
	 p_palm_flag => task_template_rec.palm_flag,
	 p_wince_flag => task_template_rec.wince_flag,
	 p_laptop_flag => task_template_rec.laptop_flag,
	 p_device1_flag => task_template_rec.device1_flag,
	 p_device2_flag => task_template_rec.device2_flag,
	 p_device3_flag => task_template_rec.device3_flag,
	 p_timezone_id => task_template_rec.timezone_id,
	 p_attribute1 => task_template_rec.attribute1,
	 p_attribute2 => task_template_rec.attribute2,
	 p_attribute3 => task_template_rec.attribute3,
	 p_attribute4 => task_template_rec.attribute4,
	 p_attribute5 => task_template_rec.attribute5,
	 p_attribute6 => task_template_rec.attribute6,
	 p_attribute7 => task_template_rec.attribute7,
	 p_attribute8 => task_template_rec.attribute8,
	 p_attribute9 => task_template_rec.attribute9,
	 p_attribute10 => task_template_rec.attribute10,
	 p_attribute11 => task_template_rec.attribute11,
	 p_attribute12 => task_template_rec.attribute12,
	 p_attribute13 => task_template_rec.attribute13,
	 p_attribute14 => task_template_rec.attribute14,
	 p_attribute15 => task_template_rec.attribute15,
	 p_attribute_category => task_template_rec.attribute_category,
	 p_date_selected => task_template_rec.date_selected,
	 p_show_on_calendar => task_template_rec.show_on_calendar,
	 p_template_id => task_template_rec.task_template_id,
	 p_template_group_id =>  p_task_template_group_info.task_template_group_id,
	 p_enable_workflow	=> fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
	 p_abort_workflow	      => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
       p_task_split_flag      => NULL,
       p_reference_flag       => NULL,
       p_child_position       => NULL,
       p_child_sequence_num   => NULL,
       p_location_id          => p_task_template_group_info.location_id
      );

      /******* Start of modification by SBARAT on 06/01/2005 for bug# 4898434 *******/

      l_object_version_number := NULL;

      Open C_Object_Version_Num(l_task_id);
      Fetch C_Object_Version_Num Into l_object_version_number;
      Close C_Object_Version_Num;

      IF l_object_version_number IS NULL
      THEN
          l_object_version_number := 1 ;
      END IF;

      /******* End of modification by SBARAT on 06/01/2005 for bug# 4898434 *******/

      jtf_task_confirmation_pub.set_counter_status(
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_object_version_number => l_object_version_number,
         p_task_id => l_task_id,
         p_task_confirmation_status => task_template_rec.task_confirmation_status,
         p_task_confirmation_counter => 0);

      x_task_details_tbl (i).task_id := l_task_id;
      x_task_details_tbl (i).task_template_id :=  task_template_rec.task_template_id;
      i := i + 1;
      END LOOP;
    END;

   PROCEDURE validate_create_task_resource (
      p_task_template_id IN NUMBER,
      p_task_id IN NUMBER,
      x_resource_req_id OUT NOCOPY jtf_task_rsc_reqs.resource_req_id%TYPE,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   )
   IS
      --- Resource for a template
      CURSOR c_task_resource (
	 p_task_template_id IN NUMBER
      )
      IS
      SELECT resource_type_code,
	     required_units,
	     task_type_id,
	     task_id,
	     enabled_flag,
	     attribute1,
	     attribute2,
	     attribute3,
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
	     attribute_category
	FROM jtf_task_rsc_reqs
       WHERE task_id = p_task_template_id;

      l_task_resource_rec   c_task_resource%ROWTYPE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

--    Bug 3342422 : there might be more than one resource in
--                  template task needs to be created.
--                  Comment out the following lines, add a for
--                  loop instead of.
--
--      OPEN c_task_resource (p_task_template_id);
--      FETCH c_task_resource INTO l_task_resource_rec;

--      IF c_task_resource%FOUND
--      THEN

--    Add for loop for fixing bug 3342422

      FOR l_task_resource_rec in c_task_resource(p_task_template_id)
      LOOP
        jtf_task_resources_pvt.create_task_rsrc_req (
	    p_api_version => 1.0,
	    p_init_msg_list => fnd_api.g_false,
	    p_commit => fnd_api.g_false,
	    p_task_id => p_task_id,
	    p_task_number => NULL,
	    p_task_type_id => l_task_resource_rec.task_type_id,
	    p_task_template_id => l_task_resource_rec.task_id,
	    p_resource_type_code => l_task_resource_rec.resource_type_code,
	    p_required_units => l_task_resource_rec.required_units,
	    p_enabled_flag => l_task_resource_rec.enabled_flag,
	    x_return_status => x_return_status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data,
	    x_resource_req_id => x_resource_req_id,
	    p_attribute1 => l_task_resource_rec.attribute1,
	    p_attribute2 => l_task_resource_rec.attribute2,
	    p_attribute3 => l_task_resource_rec.attribute3,
	    p_attribute4 => l_task_resource_rec.attribute4,
	    p_attribute5 => l_task_resource_rec.attribute5,
	    p_attribute6 => l_task_resource_rec.attribute6,
	    p_attribute7 => l_task_resource_rec.attribute7,
	    p_attribute8 => l_task_resource_rec.attribute8,
	    p_attribute9 => l_task_resource_rec.attribute9,
	    p_attribute10 => l_task_resource_rec.attribute10,
	    p_attribute11 => l_task_resource_rec.attribute11,
	    p_attribute12 => l_task_resource_rec.attribute12,
	    p_attribute13 => l_task_resource_rec.attribute13,
	    p_attribute14 => l_task_resource_rec.attribute14,
	    p_attribute15 => l_task_resource_rec.attribute15,
	    p_attribute_category => l_task_resource_rec.attribute_category
	 );

--      END IF;
--      CLOSE c_task_resource;

      END LOOP;
   END;

   PROCEDURE validate_create_recur (
      p_recurrence_rule_id IN NUMBER,
      p_task_id IN NUMBER,
      x_reccurence_generated OUT NOCOPY NUMBER,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR c_task_recurs (
	 p_recurrence_rule_id IN NUMBER
      )
      IS
	 SELECT occurs_which,
		day_of_week,
		date_of_month,
		occurs_month,
		occurs_uom,
		occurs_every,
		occurs_number,
		start_date_active,
		end_date_active
	   FROM jtf_task_recur_rules
	  WHERE recurrence_rule_id = p_recurrence_rule_id;

      l_task_recur_rec	     c_task_recurs%ROWTYPE;
      l_task_rec	     jtf_task_recurrences_pub.task_details_rec;
      l_recurrence_rule_id   NUMBER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      IF p_recurrence_rule_id IS NOT NULL
      THEN
	 OPEN c_task_recurs (p_recurrence_rule_id);
	 FETCH c_task_recurs INTO l_task_recur_rec;

	 IF c_task_recurs%NOTFOUND
	 THEN
	    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
	    fnd_message.set_token ('P_TASK_RECURRENCE_RULE_ID', p_recurrence_rule_id);
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 jtf_task_recurrences_pub.create_task_recurrence (
	    p_api_version => 1.0,
	    p_init_msg_list => fnd_api.g_false,
	    p_commit => fnd_api.g_false,
	    p_task_id => p_task_id,
	    p_occurs_which => l_task_recur_rec.occurs_which,
	    p_template_flag => jtf_task_utl.g_no,
	    p_day_of_week => l_task_recur_rec.day_of_week,
	    p_date_of_month => l_task_recur_rec.date_of_month,
	    p_occurs_month => l_task_recur_rec.occurs_month,
	    p_occurs_uom => l_task_recur_rec.occurs_uom,
	    p_occurs_every => l_task_recur_rec.occurs_every,
	    p_occurs_number => l_task_recur_rec.occurs_number,
	    p_start_date_active => l_task_recur_rec.start_date_active,
	    p_end_date_active => l_task_recur_rec.end_date_active,
	    x_return_status => x_return_status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data,
	    x_recurrence_rule_id => l_recurrence_rule_id,
	    x_task_rec => l_task_rec,
	    x_reccurences_generated => x_reccurence_generated
	 );
	 CLOSE c_task_recurs;
      ELSE
	 fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
	 fnd_message.set_token ('P_TASK_RECURRENCE_RULE_ID', p_recurrence_rule_id);
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END;

   PROCEDURE create_task_phones (
      p_task_contact_points_tbl IN jtf_task_inst_templates_pub.task_contact_points_tbl,
      p_task_template_id IN NUMBER,
      p_task_contact_id IN NUMBER,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   )
   IS
       l_task_phone_id NUMBER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      FOR i IN 1 .. p_task_contact_points_tbl.COUNT
      LOOP
	 IF (	p_task_contact_points_tbl (i).task_template_id = p_task_template_id
	    AND x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	    jtf_task_phones_pub.create_task_phones (
	       p_api_version => 1.0,
	       p_init_msg_list => fnd_api.g_false,
	       p_commit => fnd_api.g_false,
	       p_task_contact_id => p_task_contact_id,
	       p_phone_id => p_task_contact_points_tbl (i).phone_id,
	       p_primary_flag => p_task_contact_points_tbl (i).primary_key,
	       p_owner_table_name => 'JTF_TASKS_B',
	       x_return_status => x_return_status,
	       x_msg_count => x_msg_count,
	       x_msg_data => x_msg_data,
	       x_task_phone_id => l_task_phone_id
	    );
	 END IF;
      END LOOP;
   END;
END;

/
