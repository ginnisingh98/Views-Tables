--------------------------------------------------------
--  DDL for Package Body JTF_TASK_ASSIGNMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_ASSIGNMENTS_PUB" AS
/* $Header: jtfptkab.pls 120.1 2005/07/02 00:58:27 appldev ship $ */
   PROCEDURE create_task_assignment (
      p_api_version		     IN       NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER DEFAULT NULL,
      p_task_id 		     IN       NUMBER DEFAULT NULL,
      p_task_number		     IN       VARCHAR2 DEFAULT NULL,
      p_task_name		     IN       VARCHAR2 DEFAULT NULL,
      p_resource_type_code	     IN       VARCHAR2,
      p_resource_id		     IN       NUMBER,
      p_resource_name		     IN       NUMBER DEFAULT NULL,
      p_actual_effort		     IN       NUMBER DEFAULT NULL,
      p_actual_effort_uom	     IN       VARCHAR2 DEFAULT NULL,
      p_schedule_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_alarm_type_code 	     IN       VARCHAR2 DEFAULT NULL,
      p_alarm_contact		     IN       VARCHAR2 DEFAULT NULL,
      p_sched_travel_distance	     IN       NUMBER DEFAULT NULL,
      p_sched_travel_duration	     IN       NUMBER DEFAULT NULL,
      p_sched_travel_duration_uom    IN       VARCHAR2 DEFAULT NULL,
      p_actual_travel_distance	     IN       NUMBER DEFAULT NULL,
      p_actual_travel_duration	     IN       NUMBER DEFAULT NULL,
      p_actual_travel_duration_uom   IN       VARCHAR2 DEFAULT NULL,
      p_actual_start_date	     IN       DATE DEFAULT NULL,
      p_actual_end_date 	     IN       DATE DEFAULT NULL,
      p_palm_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_wince_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_laptop_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device1_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device2_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device3_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_resource_territory_id	     IN       NUMBER DEFAULT NULL,
      p_assignment_status_id	     IN       NUMBER,
      p_shift_construct_id	     IN       NUMBER DEFAULT NULL,
      x_return_status		     OUT NOCOPY      VARCHAR2,
      x_msg_count		     OUT NOCOPY      NUMBER,
      x_msg_data		     OUT NOCOPY      VARCHAR2,
      x_task_assignment_id	     OUT NOCOPY      NUMBER,
      p_attribute1		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute2		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute3		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute4		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute5		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute6		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute7		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute8		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute9		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute10		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute11		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute12		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute13		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute14		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute15		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute_category	     IN       VARCHAR2 DEFAULT NULL,
      p_show_on_calendar	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
      p_category_id		     IN       NUMBER DEFAULT NULL,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2,
      p_object_capacity_id           IN       NUMBER,
      p_free_busy_type               IN       VARCHAR2
   )
   IS
      l_api_version	CONSTANT NUMBER
	       := 1.0;
      l_api_name	CONSTANT VARCHAR(30)
	       := 'CREATE_TASK_ASSIGNMENT';
      l_task_assignment_id	 jtf_task_all_assignments.task_assignment_id%TYPE;
      l_task_id 		 jtf_tasks_b.task_id%TYPE
	       := p_task_id;
      l_task_number		 jtf_tasks_b.task_number%TYPE
	       := p_task_number;
      l_resource_type_code	 jtf_task_all_assignments.resource_type_code%TYPE
	       := p_resource_type_code;
      l_resource_id		 NUMBER
	       := p_resource_id;
      l_act_eff 		 jtf_task_all_assignments.actual_effort%TYPE
	       := p_actual_effort;
      l_act_eff_uom		 jtf_task_all_assignments.actual_effort_uom%TYPE
	       := p_actual_effort_uom;
      l_schedule_flag		 jtf_task_all_assignments.schedule_flag%TYPE
	       := p_schedule_flag;
      l_alarm_type_code 	 jtf_task_all_assignments.alarm_type_code%TYPE
	       := p_alarm_type_code;
      l_alarm_contact		 jtf_task_all_assignments.alarm_contact%TYPE
	       := p_alarm_contact;
      l_sched_travel_distance	 jtf_task_all_assignments.sched_travel_distance%TYPE
	       := p_sched_travel_distance;
      l_sched_travel_duration	 jtf_task_all_assignments.sched_travel_duration%TYPE
	       := p_sched_travel_duration;
      l_sched_travel_dur_uom	 jtf_task_all_assignments.sched_travel_duration_uom%TYPE
	       := p_sched_travel_duration_uom;
      l_actual_travel_distance	 jtf_task_all_assignments.actual_travel_distance%TYPE
	       := p_actual_travel_distance;
      l_actual_travel_duration	 jtf_task_all_assignments.actual_travel_duration%TYPE
	       := p_actual_travel_duration;
      l_actual_travel_dur_uom	 jtf_task_all_assignments.actual_travel_duration_uom%TYPE
	       := p_actual_travel_duration_uom;
      l_actual_start_date	 jtf_task_all_assignments.actual_start_date%TYPE
	       := p_actual_start_date;
      l_actual_end_date 	 jtf_task_all_assignments.actual_end_date%TYPE
	       := p_actual_end_date;
      l_palm_flag		 jtf_task_all_assignments.palm_flag%TYPE
	       := p_palm_flag;
      l_wince_flag		 jtf_task_all_assignments.wince_flag%TYPE
	       := p_wince_flag;
      l_laptop_flag		 jtf_task_all_assignments.laptop_flag%TYPE
	       := p_laptop_flag;
      l_device1_flag		 jtf_task_all_assignments.device1_flag%TYPE
	       := p_device1_flag;
      l_device2_flag		 jtf_task_all_assignments.device2_flag%TYPE
	       := p_device2_flag;
      l_device3_flag		 jtf_task_all_assignments.device3_flag%TYPE
	       := p_device3_flag;
      l_msg_data		 VARCHAR2(2000);
      l_msg_count		 NUMBER;
      x 			 CHAR;
      l_rowid			 ROWID;
      l_resource_territory_id	 jtf_task_all_assignments.resource_territory_id%TYPE
	       := p_resource_territory_id;
      l_assignment_status_id	 jtf_task_all_assignments.assignment_status_id%TYPE
	       := p_assignment_status_id;
      l_shift_construct_id	 jtf_task_all_assignments.shift_construct_id%TYPE
	       := p_shift_construct_id;
      l_show_on_calendar	 jtf_task_all_assignments.show_on_calendar%TYPE
	       := p_show_on_calendar;
      l_category_id		 jtf_task_all_assignments.category_id%TYPE
	       := p_category_id;
      l_enable_workflow 	 VARCHAR2(1)	:= p_enable_workflow;
      l_abort_workflow		 VARCHAR2(1)	:= p_abort_workflow;

   BEGIN
      SAVEPOINT create_task_assignment_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
		l_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	     )
      THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	 fnd_msg_pub.initialize;
      END IF;

      -------------
      ------------- Call the Internal Hook
      -------------
      -------------
/*p_task_assignments_user_hooks.task_id    := p_task_id ;
p_task_assignments_user_hooks.task_number     := p_task_number ;
p_task_assignments_user_hooks.resource_type_code   := p_resource_type_code ;
p_task_assignments_user_hooks.resource_id     := p_resource_id ;
p_task_assignments_user_hooks.actual_effort   := p_actual_effort ;
p_task_assignments_user_hooks.actual_effort_uom    := p_actual_effort_uom ;
p_task_assignments_user_hooks.schedule_flag   := p_schedule_flag ;
p_task_assignments_user_hooks.alarm_type_code	   := p_alarm_type_code ;
p_task_assignments_user_hooks.alarm_contact   := p_alarm_contact ;
p_task_assignments_user_hooks.sched_travel_distance	:= p_sched_travel_distance ;
p_task_assignments_user_hooks.sched_travel_duration	:= p_sched_travel_duration ;
p_task_assignments_user_hooks.sched_travel_duration_uom      := p_sched_travel_duration_uom ;
p_task_assignments_user_hooks.actual_travel_distance	:= p_actual_travel_distance ;
p_task_assignments_user_hooks.actual_travel_duration	:= p_actual_travel_duration ;
p_task_assignments_user_hooks.actual_travel_duration_uom     := p_actual_travel_duration_uom ;
p_task_assignments_user_hooks.actual_start_date    := p_actual_start_date ;
p_task_assignments_user_hooks.actual_end_date	   := p_actual_end_date ;
p_task_assignments_user_hooks.palm_flag  := p_palm_flag ;
p_task_assignments_user_hooks.wince_flag      := p_wince_flag ;
p_task_assignments_user_hooks.laptop_flag     := p_laptop_flag ;
p_task_assignments_user_hooks.device1_flag    := p_device1_flag ;
p_task_assignments_user_hooks.device2_flag    := p_device2_flag ;
p_task_assignments_user_hooks.device3_flag    := p_device3_flag ;
p_task_assignments_user_hooks.resource_territory_id	:= p_resource_territory_id ;
p_task_assignments_user_hooks.assignment_status_id	:= p_assignment_status_id ;
p_task_assignments_user_hooks.shift_construct_id   := p_shift_construct_id ;


jtf_task_assignments_iuhk.create_task_assignment_pre(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
      -------------
      -------------
      -------------
      -------------


      -------
      -------  Validate the task
      -------
      jtf_task_utl.validate_task (
	 x_return_status => x_return_status,
	 p_task_id => l_task_id,
	 p_task_number => l_task_number,
	 x_task_id => l_task_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_task_id IS NULL
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -----
      ----- Validate the assigned resource.
      -----
      jtf_task_utl.validate_task_owner (
	 p_owner_type_code => p_resource_type_code,
	 p_owner_id => p_resource_id,
	 x_return_status => x_return_status,
	 x_owner_id => l_resource_id,
	 x_owner_type_code => l_resource_type_code
      );

      IF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_RES_TYP_COD');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_resource_type_code IS NULL
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_RES_TYP_COD');
	 fnd_message.set_token ('RESOURCE_TYPE_CODE', p_resource_type_code);
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_resource_id IS NULL
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name ('JTF', 'JTF_TASK_NULL_RES_ID');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -----
      ----- Validate Assignment Status Id
      -----
      jtf_task_utl.validate_task_status (
	 p_task_status_id => l_assignment_status_id,
	 p_task_status_name => NULL,
	 p_validation_type => 'ASSIGNMENT',
	 x_return_status => x_return_status,
	 x_task_status_id => l_assignment_status_id
      );

      IF l_assignment_status_id IS NULL
      THEN
	 fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK_STATUS');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate actual effort
      -------
      jtf_task_utl.validate_effort (
	 p_tag => jtf_task_utl.get_translated_lookup (
		     'JTF_TASK_TRANSLATED_MESSAGES',
		     'ACTUAL_EFFORT'
		  ),
	 p_tag_uom => jtf_task_utl.get_translated_lookup (
			 'JTF_TASK_TRANSLATED_MESSAGES',
			 'ACTUAL_EFFORT_UOM'
		      ),
	 x_return_status => x_return_status,
	 p_effort => l_act_eff,
	 p_effort_uom => l_act_eff_uom
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate	Sched. Travel Duration
      -------
      jtf_task_utl.validate_effort (
	 p_tag => jtf_task_utl.get_translated_lookup (
		     'JTF_TASK_TRANSLATED_MESSAGES',
		     'SCHEDULED_TRAVEL_DURATION'
		  ),
	 p_tag_uom => jtf_task_utl.get_translated_lookup (
			 'JTF_TASK_TRANSLATED_MESSAGES',
			 'SCHEDULED_TRAVEL_DURATION'
		      ),
	 x_return_status => x_return_status,
	 p_effort => l_sched_travel_duration,
	 p_effort_uom => l_sched_travel_dur_uom
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate	Actual Travel Duration
      -------
      jtf_task_utl.validate_effort (
	 p_tag => jtf_task_utl.get_translated_lookup (
		     'JTF_TASK_TRANSLATED_MESSAGES',
		     'ACTUAL_TRAVEL_DURATION'
		  ),
	 p_tag_uom => jtf_task_utl.get_translated_lookup (
			 'JTF_TASK_TRANSLATED_MESSAGES',
			 'ACTUAL_TRAVEL_DURATION'
		      ),
	 x_return_status => x_return_status,
	 p_effort => l_actual_travel_duration,
	 p_effort_uom => l_actual_travel_dur_uom
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate	Actual Travel Distance
      -------
      jtf_task_utl.validate_distance (
	 p_distance_units => p_actual_travel_distance,
	 p_distance_tag => jtf_task_utl.get_translated_lookup (
			      'JTF_TASK_TRANSLATED_MESSAGES',
			      'ACTUAL_TRAVEL_DISTANCE'
			   ),
	 x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate	Schedule Travel Distance
      -------
      jtf_task_utl.validate_distance (
	 p_distance_units => p_sched_travel_distance,
	 p_distance_tag => jtf_task_utl.get_translated_lookup (
			      'JTF_TASK_TRANSLATED_MESSAGES',
			      'SCHEDULED_TRAVEL_DISTANCE'
			   ),
	 x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate Schedule Flag
      -------
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'SCHEDULED_FLAG'
			),
	 p_flag_value => l_schedule_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate Alarm Type Code and Alarm Contact FND_LOOKUPS
      -------
/*	IF l_alarm_type_code IS NOT NULL
      THEN
	 jtf_task_assignments_pvt.validate_alarm_type_code (
	    p_alarm_type_code => l_alarm_type_code,
	    x_return_status => x_return_status
	 );

	 IF (x_return_status = fnd_api.g_ret_sts_unexp_error)
	 THEN
	    fnd_message.set_name ('JTF', 'JTF_TASK_INV_ALA_TYPE');
	    fnd_message.set_token ('ALARM_TYPE_CODE', p_alarm_type_code);
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      ELSIF	l_alarm_type_code IS NULL
	    AND l_alarm_contact IS NOT NULL
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_ALA_CON');
	 fnd_message.set_token ('ALARM_CONTACT', p_alarm_contact);
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
      -------
      ------- Validate the flags.
      -------
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'PALM_FLAG'
			),
	 p_flag_value => l_palm_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'WINCE_FLAG'
			),
	 p_flag_value => l_wince_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'LAPTOP_FLAG'
			),
	 p_flag_value => l_laptop_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'DEVICE1_FLAG'
			),
	 p_flag_value => l_device1_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'DEVICE2_FLAG'
			),
	 p_flag_value => l_device2_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'DEVICE3_FLAG'
			),
	 p_flag_value => l_device3_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Validate the code in ON_SHOW_CALENDAR
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'PRIMARY_FLAG'
			),
	 p_flag_value => l_show_on_calendar
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Validate the value in category_id
      IF jtf_task_utl.g_validate_category = TRUE
      THEN
	 jtf_task_utl.validate_category (
	    p_category_id => l_category_id,
	    x_return_status => x_return_status
	 );

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END IF;

      -----
      ----- Validate the Shift construct id.
      -----
      IF l_shift_construct_id IS NOT NULL
      THEN
	 IF NOT jtf_task_utl.validate_shift_construct (l_shift_construct_id)
	 THEN
	    fnd_message.set_name ('JTF', 'JTF_TASK_CONSTRUCT_ID');
	    --fnd_message.set_token ('SHIFT_CONSTRUCT_ID', p_shift_construct_id);
	    fnd_message.set_token ('P_SHIFT_CONSTRUCT_ID', jtf_task_utl.get_translated_lookup(
							  'JTF_TASK_TRANSLATED_MESSAGES',
							  'SHIFT_CONSTRUCT_ID')
				   );
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END IF;

      ----
      ---- Validate dates
      ----
      ----
      jtf_task_utl.validate_dates (
	 p_date_tag => jtf_task_utl.get_translated_lookup (
			  'JTF_TASK_TRANSLATED_MESSAGES',
			  'ACTUAL'
		       ),
	 p_start_date => l_actual_start_date,
	 p_end_date => l_actual_end_date,
	 x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ------
      ------ Call the private api.
      ------
      jtf_task_assignments_pvt.create_task_assignment (
	 p_api_version => l_api_version,
	 p_init_msg_list => fnd_api.g_false,
	 p_commit => fnd_api.g_false,
	 p_task_assignment_id => p_task_assignment_id,
	 p_task_id => l_task_id,
	 p_resource_type_code => l_resource_type_code,
	 p_resource_id => l_resource_id,
	 p_actual_effort => l_act_eff,
	 p_actual_effort_uom => l_act_eff_uom,
	 p_schedule_flag => l_schedule_flag,
	 p_alarm_type_code => l_alarm_type_code,
	 p_alarm_contact => l_alarm_contact,
	 p_sched_travel_distance => l_sched_travel_distance,
	 p_sched_travel_duration => l_sched_travel_duration,
	 p_sched_travel_duration_uom => l_sched_travel_dur_uom,
	 p_actual_travel_distance => l_actual_travel_distance,
	 p_actual_travel_duration => l_actual_travel_duration,
	 p_actual_travel_duration_uom => l_actual_travel_dur_uom,
	 p_actual_start_date => l_actual_start_date,
	 p_actual_end_date => l_actual_end_date,
	 p_palm_flag => l_palm_flag,
	 p_wince_flag => l_wince_flag,
	 p_laptop_flag => l_laptop_flag,
	 p_device1_flag => l_device1_flag,
	 p_device2_flag => l_device2_flag,
	 p_device3_flag => l_device3_flag,
	 p_resource_territory_id => l_resource_territory_id,
	 p_assignment_status_id => l_assignment_status_id,
	 p_shift_construct_id => l_shift_construct_id,
	 x_return_status => x_return_status,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data,
	 x_task_assignment_id => x_task_assignment_id,
	 p_attribute1 => p_attribute1,
	 p_attribute2 => p_attribute2,
	 p_attribute3 => p_attribute3,
	 p_attribute4 => p_attribute4,
	 p_attribute5 => p_attribute5,
	 p_attribute6 => p_attribute6,
	 p_attribute7 => p_attribute7,
	 p_attribute8 => p_attribute8,
	 p_attribute9 => p_attribute9,
	 p_attribute10 => p_attribute10,
	 p_attribute11 => p_attribute11,
	 p_attribute12 => p_attribute12,
	 p_attribute13 => p_attribute13,
	 p_attribute14 => p_attribute14,
	 p_attribute15 => p_attribute15,
	 p_attribute_category => p_attribute_category,
	 p_show_on_calendar => l_show_on_calendar,
	 p_category_id => l_category_id,
	 p_enable_workflow => l_enable_workflow,
	 p_abort_workflow => l_abort_workflow,
         p_add_option     => NULL,
         p_free_busy_type => p_free_busy_type,
         p_object_capacity_id => p_object_capacity_id
	 );

      IF (x_return_status = fnd_api.g_ret_sts_error)
      THEN
	 RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      p_task_assignments_user_hooks.task_assignment_id :=
	 x_task_assignment_id;

/*--jtf_task_assignments_iuhk.create_task_assignment_post(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
      IF fnd_api.to_boolean (p_commit)
      THEN
	 COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
	 ROLLBACK TO create_task_assignment_pub;
	 x_return_status := fnd_api.g_ret_sts_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	 ROLLBACK TO create_task_assignment_pub;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN OTHERS
      THEN
	 ROLLBACK TO create_task_assignment_pub;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 /* if fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
	  then
	      fnd_msg_pub.add_exc_msg(g_pkg_name,l_api_name) ;
	  end if ;*/
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
   END;



      PROCEDURE create_task_assignment (
         p_api_version		     IN       NUMBER,
         p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
         p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
         p_task_assignment_id	     IN       NUMBER DEFAULT NULL,
         p_task_id 		     IN       NUMBER DEFAULT NULL,
         p_task_number		     IN       VARCHAR2 DEFAULT NULL,
         p_task_name		     IN       VARCHAR2 DEFAULT NULL,
         p_resource_type_code	     IN       VARCHAR2,
         p_resource_id		     IN       NUMBER,
         p_resource_name		     IN       NUMBER DEFAULT NULL,
         p_actual_effort		     IN       NUMBER DEFAULT NULL,
         p_actual_effort_uom	     IN       VARCHAR2 DEFAULT NULL,
         p_schedule_flag		     IN       VARCHAR2 DEFAULT NULL,
         p_alarm_type_code 	     IN       VARCHAR2 DEFAULT NULL,
         p_alarm_contact		     IN       VARCHAR2 DEFAULT NULL,
         p_sched_travel_distance	     IN       NUMBER DEFAULT NULL,
         p_sched_travel_duration	     IN       NUMBER DEFAULT NULL,
         p_sched_travel_duration_uom    IN       VARCHAR2 DEFAULT NULL,
         p_actual_travel_distance	     IN       NUMBER DEFAULT NULL,
         p_actual_travel_duration	     IN       NUMBER DEFAULT NULL,
         p_actual_travel_duration_uom   IN       VARCHAR2 DEFAULT NULL,
         p_actual_start_date	     IN       DATE DEFAULT NULL,
         p_actual_end_date 	     IN       DATE DEFAULT NULL,
         p_palm_flag		     IN       VARCHAR2 DEFAULT NULL,
         p_wince_flag		     IN       VARCHAR2 DEFAULT NULL,
         p_laptop_flag		     IN       VARCHAR2 DEFAULT NULL,
         p_device1_flag		     IN       VARCHAR2 DEFAULT NULL,
         p_device2_flag		     IN       VARCHAR2 DEFAULT NULL,
         p_device3_flag		     IN       VARCHAR2 DEFAULT NULL,
         p_resource_territory_id	     IN       NUMBER DEFAULT NULL,
         p_assignment_status_id	     IN       NUMBER,
         p_shift_construct_id	     IN       NUMBER DEFAULT NULL,
         x_return_status		     OUT NOCOPY      VARCHAR2,
         x_msg_count		     OUT NOCOPY      NUMBER,
         x_msg_data		     OUT NOCOPY      VARCHAR2,
         x_task_assignment_id	     OUT NOCOPY      NUMBER,
         p_attribute1		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute2		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute3		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute4		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute5		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute6		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute7		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute8		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute9		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute10		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute11		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute12		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute13		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute14		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute15		     IN       VARCHAR2 DEFAULT NULL,
         p_attribute_category	     IN       VARCHAR2 DEFAULT NULL,
         p_show_on_calendar	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
         p_category_id		     IN       NUMBER DEFAULT NULL,
         p_enable_workflow 	     IN       VARCHAR2,
         p_abort_workflow		     IN       VARCHAR2,
         p_object_capacity_id           IN       NUMBER
   )
  IS
    BEGIN
       jtf_task_assignments_pub.create_task_assignment (
       p_api_version		     => p_api_version,
       p_init_msg_list		     => p_init_msg_list,
       p_commit			     => p_commit,
       p_task_assignment_id	     => p_task_assignment_id,
       p_task_id 		     => p_task_id,
       p_task_number		     => p_task_number,
       p_task_name		     => p_task_name,
       p_resource_type_code	     => p_resource_type_code,
       p_resource_id		     => p_resource_id,
       p_resource_name		     => p_resource_name,
       p_actual_effort		     => p_actual_effort,
       p_actual_effort_uom	     => p_actual_effort_uom,
       p_schedule_flag		     => p_schedule_flag,
       p_alarm_type_code 	     => p_alarm_type_code,
       p_alarm_contact		     => p_alarm_contact,
       p_sched_travel_distance	     => p_sched_travel_distance,
       p_sched_travel_duration	     => p_sched_travel_duration,
       p_sched_travel_duration_uom    => p_sched_travel_duration_uom,
       p_actual_travel_distance	     => p_actual_travel_distance,
       p_actual_travel_duration	     => p_actual_travel_duration,
       p_actual_travel_duration_uom   => p_actual_travel_duration_uom,
       p_actual_start_date	     => p_actual_start_date,
       p_actual_end_date 	     => p_actual_end_date,
       p_palm_flag		     => p_palm_flag,
       p_wince_flag		     => p_wince_flag,
       p_laptop_flag		     => p_laptop_flag,
       p_device1_flag		     => p_device1_flag,
       p_device2_flag		     => p_device2_flag,
       p_device3_flag		     => p_device3_flag,
       p_resource_territory_id	     => p_resource_territory_id,
       p_assignment_status_id	     => p_assignment_status_id,
       p_shift_construct_id	     => p_shift_construct_id,
       x_return_status		     => x_return_status,
       x_msg_count		     => x_msg_count,
       x_msg_data		     => x_msg_data,
       x_task_assignment_id	     => x_task_assignment_id,
       p_attribute1		     => p_attribute1,
       p_attribute2		     => p_attribute2,
       p_attribute3		     => p_attribute3,
       p_attribute4		     => p_attribute4,
       p_attribute5		     => p_attribute5,
       p_attribute6		     => p_attribute6,
       p_attribute7		     => p_attribute7,
       p_attribute8		     => p_attribute8,
       p_attribute9		     => p_attribute9,
       p_attribute10		     => p_attribute10,
       p_attribute11		     => p_attribute11,
       p_attribute12		     => p_attribute12,
       p_attribute13		     => p_attribute13,
       p_attribute14		     => p_attribute14,
       p_attribute15		     => p_attribute15,
       p_attribute_category	     => p_attribute_category,
       p_show_on_calendar	     => p_show_on_calendar,
       p_category_id		     => p_category_id,
       p_enable_workflow 	     => p_enable_workflow,
       p_abort_workflow		     => p_abort_workflow,
       p_object_capacity_id          => p_object_capacity_id ,
       p_free_busy_type              => null
       );
   END;




 --overloading create procedure
   PROCEDURE create_task_assignment (
      p_api_version		     IN       NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER DEFAULT NULL,
      p_task_id 		     IN       NUMBER DEFAULT NULL,
      p_task_number		     IN       VARCHAR2 DEFAULT NULL,
      p_task_name		     IN       VARCHAR2 DEFAULT NULL,
      p_resource_type_code	     IN       VARCHAR2,
      p_resource_id		     IN       NUMBER,
      p_resource_name		     IN       NUMBER DEFAULT NULL,
      p_actual_effort		     IN       NUMBER DEFAULT NULL,
      p_actual_effort_uom	     IN       VARCHAR2 DEFAULT NULL,
      p_schedule_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_alarm_type_code 	     IN       VARCHAR2 DEFAULT NULL,
      p_alarm_contact		     IN       VARCHAR2 DEFAULT NULL,
      p_sched_travel_distance	     IN       NUMBER DEFAULT NULL,
      p_sched_travel_duration	     IN       NUMBER DEFAULT NULL,
      p_sched_travel_duration_uom    IN       VARCHAR2 DEFAULT NULL,
      p_actual_travel_distance	     IN       NUMBER DEFAULT NULL,
      p_actual_travel_duration	     IN       NUMBER DEFAULT NULL,
      p_actual_travel_duration_uom   IN       VARCHAR2 DEFAULT NULL,
      p_actual_start_date	     IN       DATE DEFAULT NULL,
      p_actual_end_date 	     IN       DATE DEFAULT NULL,
      p_palm_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_wince_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_laptop_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device1_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device2_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device3_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_resource_territory_id	     IN       NUMBER DEFAULT NULL,
      p_assignment_status_id	     IN       NUMBER,
      p_shift_construct_id	     IN       NUMBER DEFAULT NULL,
      x_return_status		     OUT NOCOPY      VARCHAR2,
      x_msg_count		     OUT NOCOPY      NUMBER,
      x_msg_data		     OUT NOCOPY      VARCHAR2,
      x_task_assignment_id	     OUT NOCOPY      NUMBER,
      p_attribute1		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute2		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute3		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute4		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute5		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute6		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute7		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute8		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute9		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute10		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute11		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute12		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute13		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute14		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute15		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute_category	     IN       VARCHAR2 DEFAULT NULL,
      p_show_on_calendar	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
      p_category_id		     IN       NUMBER DEFAULT NULL,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2
   )
   IS
   BEGIN
      jtf_task_assignments_pub.create_task_assignment (
      p_api_version		     => p_api_version,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_task_id 		     => p_task_id,
      p_task_number		     => p_task_number,
      p_task_name		     => p_task_name,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
      p_resource_name		     => p_resource_name,
      p_actual_effort		     => p_actual_effort,
      p_actual_effort_uom	     => p_actual_effort_uom,
      p_schedule_flag		     => p_schedule_flag,
      p_alarm_type_code 	     => p_alarm_type_code,
      p_alarm_contact		     => p_alarm_contact,
      p_sched_travel_distance	     => p_sched_travel_distance,
      p_sched_travel_duration	     => p_sched_travel_duration,
      p_sched_travel_duration_uom    => p_sched_travel_duration_uom,
      p_actual_travel_distance	     => p_actual_travel_distance,
      p_actual_travel_duration	     => p_actual_travel_duration,
      p_actual_travel_duration_uom   => p_actual_travel_duration_uom,
      p_actual_start_date	     => p_actual_start_date,
      p_actual_end_date 	     => p_actual_end_date,
      p_palm_flag		     => p_palm_flag,
      p_wince_flag		     => p_wince_flag,
      p_laptop_flag		     => p_laptop_flag,
      p_device1_flag		     => p_device1_flag,
      p_device2_flag		     => p_device2_flag,
      p_device3_flag		     => p_device3_flag,
      p_resource_territory_id	     => p_resource_territory_id,
      p_assignment_status_id	     => p_assignment_status_id,
      p_shift_construct_id	     => p_shift_construct_id,
      x_return_status		     => x_return_status,
      x_msg_count		     => x_msg_count,
      x_msg_data		     => x_msg_data,
      x_task_assignment_id	     => x_task_assignment_id,
      p_attribute1		     => p_attribute1,
      p_attribute2		     => p_attribute2,
      p_attribute3		     => p_attribute3,
      p_attribute4		     => p_attribute4,
      p_attribute5		     => p_attribute5,
      p_attribute6		     => p_attribute6,
      p_attribute7		     => p_attribute7,
      p_attribute8		     => p_attribute8,
      p_attribute9		     => p_attribute9,
      p_attribute10		     => p_attribute10,
      p_attribute11		     => p_attribute11,
      p_attribute12		     => p_attribute12,
      p_attribute13		     => p_attribute13,
      p_attribute14		     => p_attribute14,
      p_attribute15		     => p_attribute15,
      p_attribute_category	     => p_attribute_category,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => p_enable_workflow,
      p_abort_workflow		     => p_abort_workflow,
      p_object_capacity_id           => NULL
      );
   END;

 --overloading create procedure
   PROCEDURE create_task_assignment (
      p_api_version		     IN       NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER DEFAULT NULL,
      p_task_id 		     IN       NUMBER DEFAULT NULL,
      p_task_number		     IN       VARCHAR2 DEFAULT NULL,
      p_task_name		     IN       VARCHAR2 DEFAULT NULL,
      p_resource_type_code	     IN       VARCHAR2,
      p_resource_id		     IN       NUMBER,
      p_resource_name		     IN       NUMBER DEFAULT NULL,
      p_actual_effort		     IN       NUMBER DEFAULT NULL,
      p_actual_effort_uom	     IN       VARCHAR2 DEFAULT NULL,
      p_schedule_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_alarm_type_code 	     IN       VARCHAR2 DEFAULT NULL,
      p_alarm_contact		     IN       VARCHAR2 DEFAULT NULL,
      p_sched_travel_distance	     IN       NUMBER DEFAULT NULL,
      p_sched_travel_duration	     IN       NUMBER DEFAULT NULL,
      p_sched_travel_duration_uom    IN       VARCHAR2 DEFAULT NULL,
      p_actual_travel_distance	     IN       NUMBER DEFAULT NULL,
      p_actual_travel_duration	     IN       NUMBER DEFAULT NULL,
      p_actual_travel_duration_uom   IN       VARCHAR2 DEFAULT NULL,
      p_actual_start_date	     IN       DATE DEFAULT NULL,
      p_actual_end_date 	     IN       DATE DEFAULT NULL,
      p_palm_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_wince_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_laptop_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device1_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device2_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_device3_flag		     IN       VARCHAR2 DEFAULT NULL,
      p_resource_territory_id	     IN       NUMBER DEFAULT NULL,
      p_assignment_status_id	     IN       NUMBER,
      p_shift_construct_id	     IN       NUMBER DEFAULT NULL,
      x_return_status		     OUT NOCOPY      VARCHAR2,
      x_msg_count		     OUT NOCOPY      NUMBER,
      x_msg_data		     OUT NOCOPY      VARCHAR2,
      x_task_assignment_id	     OUT NOCOPY      NUMBER,
      p_attribute1		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute2		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute3		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute4		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute5		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute6		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute7		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute8		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute9		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute10		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute11		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute12		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute13		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute14		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute15		     IN       VARCHAR2 DEFAULT NULL,
      p_attribute_category	     IN       VARCHAR2 DEFAULT NULL,
      p_show_on_calendar	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
      p_category_id		     IN       NUMBER DEFAULT NULL
   )
   IS
   BEGIN
      jtf_task_assignments_pub.create_task_assignment (
      p_api_version		     => p_api_version,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_task_id 		     => p_task_id,
      p_task_number		     => p_task_number,
      p_task_name		     => p_task_name,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
      p_resource_name		     => p_resource_name,
      p_actual_effort		     => p_actual_effort,
      p_actual_effort_uom	     => p_actual_effort_uom,
      p_schedule_flag		     => p_schedule_flag,
      p_alarm_type_code 	     => p_alarm_type_code,
      p_alarm_contact		     => p_alarm_contact,
      p_sched_travel_distance	     => p_sched_travel_distance,
      p_sched_travel_duration	     => p_sched_travel_duration,
      p_sched_travel_duration_uom    => p_sched_travel_duration_uom,
      p_actual_travel_distance	     => p_actual_travel_distance,
      p_actual_travel_duration	     => p_actual_travel_duration,
      p_actual_travel_duration_uom   => p_actual_travel_duration_uom,
      p_actual_start_date	     => p_actual_start_date,
      p_actual_end_date 	     => p_actual_end_date,
      p_palm_flag		     => p_palm_flag,
      p_wince_flag		     => p_wince_flag,
      p_laptop_flag		     => p_laptop_flag,
      p_device1_flag		     => p_device1_flag,
      p_device2_flag		     => p_device2_flag,
      p_device3_flag		     => p_device3_flag,
      p_resource_territory_id	     => p_resource_territory_id,
      p_assignment_status_id	     => p_assignment_status_id,
      p_shift_construct_id	     => p_shift_construct_id,
      x_return_status		     => x_return_status,
      x_msg_count		     => x_msg_count,
      x_msg_data		     => x_msg_data,
      x_task_assignment_id	     => x_task_assignment_id,
      p_attribute1		     => p_attribute1,
      p_attribute2		     => p_attribute2,
      p_attribute3		     => p_attribute3,
      p_attribute4		     => p_attribute4,
      p_attribute5		     => p_attribute5,
      p_attribute6		     => p_attribute6,
      p_attribute7		     => p_attribute7,
      p_attribute8		     => p_attribute8,
      p_attribute9		     => p_attribute9,
      p_attribute10		     => p_attribute10,
      p_attribute11		     => p_attribute11,
      p_attribute12		     => p_attribute12,
      p_attribute13		     => p_attribute13,
      p_attribute14		     => p_attribute14,
      p_attribute15		     => p_attribute15,
      p_attribute_category	     => p_attribute_category,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
      p_abort_workflow		     => fnd_profile.value('JTF_TASK_ABORT_PREV_WF')
      );
   END;


   PROCEDURE lock_task_assignment (
      p_api_version		IN	 NUMBER,
      p_init_msg_list		IN	 VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			IN	 VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	IN	 NUMBER,
      p_object_version_number	IN	 NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_data		OUT NOCOPY	VARCHAR2,
      x_msg_count		OUT NOCOPY	NUMBER
   )
   IS
      l_api_version   CONSTANT NUMBER	    := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'LOCK_TASK_ASSIGNMENT';
      resource_locked	       EXCEPTION;
      PRAGMA EXCEPTION_INIT (resource_locked, -54);
   BEGIN
      SAVEPOINT lock_task_assignment_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
		l_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	     )
      THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	 fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      jtf_task_assignments_pkg.lock_row (
	 x_task_assignment_id => p_task_assignment_id,
	 x_object_version_number => p_object_version_number
      );
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN resource_locked
      THEN
	 ROLLBACK TO lock_task_assignment_pub;
	 fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
	 fnd_message.set_token ('P_LOCKED_RESOURCE', 'Assignments');
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	 ROLLBACK TO lock_task_assignment_pub;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN OTHERS
      THEN
	 ROLLBACK TO lock_task_assignment_pub;
	 fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
	 fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
   END;

   PROCEDURE update_task_assignment (
      p_api_version		     IN       NUMBER,
      p_object_version_number	     IN OUT NOCOPY   NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER,
      p_task_id 		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_task_number		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_task_name		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_type_code	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_id		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_resource_name		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_effort		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_effort_uom	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_schedule_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_alarm_type_code 	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_alarm_contact		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_sched_travel_distance	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_sched_travel_duration	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_sched_travel_duration_uom    IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_travel_distance	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_travel_duration	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_travel_duration_uom   IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_start_date	     IN       DATE DEFAULT fnd_api.g_miss_date,
      p_actual_end_date 	     IN       DATE DEFAULT fnd_api.g_miss_date,
      p_palm_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_wince_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_laptop_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device1_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device2_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device3_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_territory_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_assignment_status_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_shift_construct_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      x_return_status		     OUT NOCOPY      VARCHAR2,
      x_msg_count		     OUT NOCOPY      NUMBER,
      x_msg_data		     OUT NOCOPY      VARCHAR2,
      p_attribute1		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_show_on_calendar	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_category_id		     IN       NUMBER
	    DEFAULT jtf_task_utl.g_miss_number,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2,
      p_object_capacity_id           IN       NUMBER
   )
   IS
--Declare the variables

--
      l_api_version	CONSTANT NUMBER
	       := 1.0;
      l_api_name	CONSTANT VARCHAR(30)
	       := 'Update_Task_Assignment';
      l_return_status		 VARCHAR2(1)
	       := fnd_api.g_ret_sts_success;
      l_task_assignment_id	 jtf_task_all_assignments.task_assignment_id%TYPE
	       := p_task_assignment_id;
      l_resource_type_code	 jtf_task_all_assignments.resource_type_code%TYPE
	       := p_resource_type_code;
      l_resource_id		 jtf_task_all_assignments.resource_id%TYPE
	       := p_resource_id;
      l_act_eff 		 jtf_task_all_assignments.actual_effort%TYPE
	       := p_actual_effort;
      l_act_eff_uom		 jtf_task_all_assignments.actual_effort_uom%TYPE
	       := p_actual_effort_uom;
      l_schedule_flag		 jtf_task_all_assignments.schedule_flag%TYPE
	       := p_schedule_flag;
      l_alarm_type_code 	 jtf_task_all_assignments.alarm_type_code%TYPE
	       := p_alarm_type_code;
      l_alarm_contact		 jtf_task_all_assignments.alarm_contact%TYPE
	       := p_alarm_contact;
      l_sched_travel_distance	 jtf_task_all_assignments.sched_travel_distance%TYPE
	       := p_sched_travel_distance;
      l_sched_travel_duration	 jtf_task_all_assignments.sched_travel_duration%TYPE
	       := p_sched_travel_duration;
      l_sched_travel_dur_uom	 jtf_task_all_assignments.sched_travel_duration_uom%TYPE
	       := p_sched_travel_duration_uom;
      l_actual_travel_distance	 jtf_task_all_assignments.actual_travel_distance%TYPE
	       := p_actual_travel_distance;
      l_actual_travel_duration	 jtf_task_all_assignments.actual_travel_duration%TYPE
	       := p_actual_travel_duration;
      l_actual_travel_dur_uom	 jtf_task_all_assignments.actual_travel_duration_uom%TYPE
	       := p_actual_travel_duration_uom;
      l_actual_start_date	 jtf_task_all_assignments.actual_start_date%TYPE
	       := p_actual_start_date;
      l_actual_end_date 	 jtf_task_all_assignments.actual_end_date%TYPE
	       := p_actual_end_date;
      l_palm_flag		 jtf_task_all_assignments.palm_flag%TYPE
	       := p_palm_flag;
      l_wince_flag		 jtf_task_all_assignments.wince_flag%TYPE
	       := p_wince_flag;
      l_laptop_flag		 jtf_task_all_assignments.laptop_flag%TYPE
	       := p_laptop_flag;
      l_device1_flag		 jtf_task_all_assignments.device1_flag%TYPE
	       := p_device1_flag;
      l_device2_flag		 jtf_task_all_assignments.device2_flag%TYPE
	       := p_device2_flag;
      l_device3_flag		 jtf_task_all_assignments.device3_flag%TYPE
	       := p_device3_flag;
      l_msg_data		 VARCHAR2(2000);
      l_msg_count		 NUMBER;
      x 			 CHAR;
      l_rowid			 ROWID;
      l_resource_territory_id	 jtf_task_all_assignments.resource_territory_id%TYPE
	       := p_resource_territory_id;
      l_assignment_status_id	 jtf_task_all_assignments.assignment_status_id%TYPE
	       := p_assignment_status_id;
      l_shift_construct_id	 jtf_task_all_assignments.shift_construct_id%TYPE
	       := p_shift_construct_id;
      l_show_on_calendar	 jtf_task_all_assignments.show_on_calendar%TYPE
	       := p_show_on_calendar;
      l_category_id		 jtf_task_all_assignments.category_id%TYPE
	       := p_category_id;
      l_type   varchar2(15)	:='ASSIGNMENT';
      l_enable_workflow 	 VARCHAR2(1)	:= p_enable_workflow;
      l_abort_workflow		 VARCHAR2(1)	:= p_abort_workflow;

      CURSOR task_ass_u (l_task_asignment_id IN NUMBER)
      IS
	 SELECT task_id,
		DECODE (
		   p_resource_id,
		   fnd_api.g_miss_num, resource_id,
		   p_resource_id
		) resource_id,
		DECODE (
		   p_resource_type_code,
		   fnd_api.g_miss_char, resource_type_code,
		   p_resource_type_code
		) resource_type_code,
		DECODE (
		   p_assignment_status_id,
		   fnd_api.g_miss_num, assignment_status_id,
		   p_assignment_status_id
		) assignment_status_id,
		DECODE (
		   p_actual_effort,
		   fnd_api.g_miss_num, actual_effort,
		   p_actual_effort
		) actual_effort,
		DECODE (
		   p_actual_effort_uom,
		   fnd_api.g_miss_char, actual_effort_uom,
		   p_actual_effort_uom
		) actual_effort_uom,
		DECODE (
		   p_alarm_type_code,
		   fnd_api.g_miss_char, alarm_type_code,
		   p_alarm_type_code
		) alarm_type_code,
		DECODE (
		   p_alarm_contact,
		   fnd_api.g_miss_char, alarm_contact,
		   p_alarm_contact
		) alarm_contact,
		DECODE (
		   p_sched_travel_distance,
		   fnd_api.g_miss_num, sched_travel_distance,
		   p_sched_travel_distance
		) sched_travel_distance,
		DECODE (
		   p_sched_travel_duration,
		   fnd_api.g_miss_num, sched_travel_duration,
		   p_sched_travel_duration
		) sched_travel_duration,
		DECODE (
		   p_sched_travel_duration_uom,
		   fnd_api.g_miss_char, sched_travel_duration_uom,
		   p_sched_travel_duration_uom
		) sched_travel_dur_uom,
		DECODE (
		   p_actual_travel_distance,
		   fnd_api.g_miss_num, actual_travel_distance,
		   p_actual_travel_distance
		) actual_travel_distance,
		DECODE (
		   p_actual_travel_duration,
		   fnd_api.g_miss_num, actual_travel_duration,
		   p_actual_travel_duration
		) actual_travel_duration,
		DECODE (
		   p_resource_territory_id,
		   fnd_api.g_miss_num, resource_territory_id,
		   p_resource_territory_id
		) resource_territory_id,
		DECODE (
		   p_shift_construct_id,
		   fnd_api.g_miss_num, shift_construct_id,
		   p_shift_construct_id
		) shift_construct_id,
		DECODE (
		   p_actual_travel_duration_uom,
		   fnd_api.g_miss_char, actual_travel_duration_uom,
		   p_actual_travel_duration_uom
		) actual_travel_dur_uom,
		DECODE (
		   p_schedule_flag,
		   fnd_api.g_miss_char, schedule_flag,
		   p_schedule_flag
		) schedule_flag,
		DECODE (
		   p_actual_start_date,
		   fnd_api.g_miss_date, actual_start_date,
		   p_actual_start_date
		) actual_start_date,
		DECODE (
		   p_actual_end_date,
		   fnd_api.g_miss_date, actual_end_date,
		   p_actual_end_date
		) actual_end_date,
		DECODE (
		   p_palm_flag,
		   fnd_api.g_miss_char, palm_flag,
		   p_palm_flag
		) palm_flag,
		DECODE (
		   p_wince_flag,
		   fnd_api.g_miss_char, wince_flag,
		   p_wince_flag
		) wince_flag,
		DECODE (
		   p_laptop_flag,
		   fnd_api.g_miss_char, laptop_flag,
		   p_laptop_flag
		) laptop_flag,
		DECODE (
		   p_device1_flag,
		   fnd_api.g_miss_char, device1_flag,
		   p_device1_flag
		) device1_flag,
		DECODE (
		   p_device2_flag,
		   fnd_api.g_miss_char, device2_flag,
		   p_device2_flag
		) device2_flag,
		DECODE (
		   p_device3_flag,
		   fnd_api.g_miss_char, device3_flag,
		   p_device3_flag
		) device3_flag,
		DECODE (
		   p_show_on_calendar,
		   fnd_api.g_miss_char, show_on_calendar,
		   p_show_on_calendar
		) show_on_calendar,
		DECODE (
		   p_category_id,
		   fnd_api.g_miss_num, category_id,
		   p_category_id
		) category_id,
		DECODE (
		   p_attribute1,
		   fnd_api.g_miss_char, attribute1,
		   p_attribute1
		) attribute1,
		DECODE (
		   p_attribute2,
		   fnd_api.g_miss_char, attribute2,
		   p_attribute2
		) attribute2,
		DECODE (
		   p_attribute3,
		   fnd_api.g_miss_char, attribute3,
		   p_attribute3
		) attribute3,
		DECODE (
		   p_attribute4,
		   fnd_api.g_miss_char, attribute4,
		   p_attribute4
		) attribute4,
		DECODE (
		   p_attribute5,
		   fnd_api.g_miss_char, attribute5,
		   p_attribute5
		) attribute5,
		DECODE (
		   p_attribute6,
		   fnd_api.g_miss_char, attribute6,
		   p_attribute6
		) attribute6,
		DECODE (
		   p_attribute7,
		   fnd_api.g_miss_char, attribute7,
		   p_attribute7
		) attribute7,
		DECODE (
		   p_attribute8,
		   fnd_api.g_miss_char, attribute8,
		   p_attribute8
		) attribute8,
		DECODE (
		   p_attribute9,
		   fnd_api.g_miss_char, attribute9,
		   p_attribute9
		) attribute9,
		DECODE (
		   p_attribute10,
		   fnd_api.g_miss_char, attribute10,
		   p_attribute10
		) attribute10,
		DECODE (
		   p_attribute11,
		   fnd_api.g_miss_char, attribute11,
		   p_attribute11
		) attribute11,
		DECODE (
		   p_attribute12,
		   fnd_api.g_miss_char, attribute12,
		   p_attribute12
		) attribute12,
		DECODE (
		   p_attribute13,
		   fnd_api.g_miss_char, attribute13,
		   p_attribute13
		) attribute13,
		DECODE (
		   p_attribute14,
		   fnd_api.g_miss_char, attribute14,
		   p_attribute14
		) attribute14,
		DECODE (
		   p_attribute15,
		   fnd_api.g_miss_char, attribute15,
		   p_attribute15
		) attribute15,
		DECODE (
		   p_attribute_category,
		   fnd_api.g_miss_char, attribute_category,
		   p_attribute_category
		) attribute_category
	   FROM jtf_task_all_assignments
	  WHERE task_assignment_id = l_task_assignment_id;

      task_ass_rec		 task_ass_u%ROWTYPE;
   BEGIN
      SAVEPOINT update_task_assignment_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
		l_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	     )
      THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	 fnd_msg_pub.initialize;
      END IF;

/*	-------------
      ------------- Call the Internal Hook
      -------------
      -------------

p_task_assignments_user_hooks.task_id	 := p_task_id ;
p_task_assignments_user_hooks.task_number     := p_task_number ;
p_task_assignments_user_hooks.resource_type_code   := p_resource_type_code ;
p_task_assignments_user_hooks.resource_id     := p_resource_id ;
p_task_assignments_user_hooks.actual_effort   := p_actual_effort ;
p_task_assignments_user_hooks.actual_effort_uom    := p_actual_effort_uom ;
p_task_assignments_user_hooks.schedule_flag   := p_schedule_flag ;
p_task_assignments_user_hooks.alarm_type_code	   := p_alarm_type_code ;
p_task_assignments_user_hooks.alarm_contact   := p_alarm_contact ;
p_task_assignments_user_hooks.sched_travel_distance	:= p_sched_travel_distance ;
p_task_assignments_user_hooks.sched_travel_duration	:= p_sched_travel_duration ;
p_task_assignments_user_hooks.sched_travel_duration_uom      := p_sched_travel_duration_uom ;
p_task_assignments_user_hooks.actual_travel_distance	:= p_actual_travel_distance ;
p_task_assignments_user_hooks.actual_travel_duration	:= p_actual_travel_duration ;
p_task_assignments_user_hooks.actual_travel_duration_uom     := p_actual_travel_duration_uom ;
p_task_assignments_user_hooks.actual_start_date    := p_actual_start_date ;
p_task_assignments_user_hooks.actual_end_date	   := p_actual_end_date ;
p_task_assignments_user_hooks.palm_flag  := p_palm_flag ;
p_task_assignments_user_hooks.wince_flag      := p_wince_flag ;
p_task_assignments_user_hooks.laptop_flag     := p_laptop_flag ;
p_task_assignments_user_hooks.device1_flag    := p_device1_flag ;
p_task_assignments_user_hooks.device2_flag    := p_device2_flag ;
p_task_assignments_user_hooks.device3_flag    := p_device3_flag ;
p_task_assignments_user_hooks.resource_territory_id	:= p_resource_territory_id ;
p_task_assignments_user_hooks.assignment_status_id	:= p_assignment_status_id ;
p_task_assignments_user_hooks.shift_construct_id   := p_shift_construct_id ;


jtf_task_assignments_iuhk.update_task_assignment_pre(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

*/
      OPEN task_ass_u (l_task_assignment_id);
      FETCH task_ass_u INTO task_ass_rec;

      IF task_ass_u%NOTFOUND
      THEN
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_TK_ASS');
	 fnd_message.set_token ('TASK_ASSIGNMENT_ID', p_task_assignment_id);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -----
      ----- Validate Assignment Status Id
      -----
      l_assignment_status_id := task_ass_rec.assignment_status_id;
      jtf_task_utl.validate_task_status (
	 p_task_status_id => l_assignment_status_id,
	 p_task_status_name => NULL,
	 p_validation_type => 'ASSIGNMENT',
	 x_return_status => x_return_status,
	 x_task_status_id => l_assignment_status_id
      );

      IF l_assignment_status_id IS NULL
      THEN
	 fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK_STATUS');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -----
      ----- Validate the assigned resource.
      -----
      l_resource_type_code := task_ass_rec.resource_type_code;
      l_resource_id := task_ass_rec.resource_id;
      jtf_task_utl.validate_task_owner (
	 p_owner_type_code => l_resource_type_code,
	 p_owner_id => l_resource_id,
	 x_return_status => x_return_status,
	 x_owner_id => l_resource_id,
	 x_owner_type_code => l_resource_type_code
      );

      IF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_RES_TYP_COD');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_resource_type_code IS NULL
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_RES_TYP_COD');
	 fnd_message.set_token ('RESOURCE_TYPE_CODE', p_resource_type_code);
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_resource_id IS NULL
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name ('JTF', 'JTF_TASK_NULL_RES_ID');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate actual effort
      -------
      l_act_eff := task_ass_rec.actual_effort;
      l_act_eff_uom := task_ass_rec.actual_effort_uom;
      jtf_task_utl.validate_effort (
	 p_tag => jtf_task_utl.get_translated_lookup (
		     'JTF_TASK_TRANSLATED_MESSAGES',
		     'ACTUAL_EFFORT'
		  ),
	 p_tag_uom => jtf_task_utl.get_translated_lookup (
			 'JTF_TASK_TRANSLATED_MESSAGES',
			 'ACTUAL_EFFORT_UOM'
		      ),
	 x_return_status => x_return_status,
	 p_effort => l_act_eff,
	 p_effort_uom => l_act_eff_uom
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_shift_construct_id := task_ass_rec.shift_construct_id;

      IF l_shift_construct_id IS NOT NULL
      THEN
	 IF NOT jtf_task_utl.validate_shift_construct (l_shift_construct_id)
	 THEN
	    fnd_message.set_name ('JTF', 'JTF_TASK_CONSTRUCT_ID');
	    --fnd_message.set_token ('SHIFT_CONSTRUCT_ID', p_shift_construct_id);
	    fnd_message.set_token ('P_SHIFT_CONSTRUCT_ID', jtf_task_utl.get_translated_lookup(
							  'JTF_TASK_TRANSLATED_MESSAGES',
							  'SHIFT_CONSTRUCT_ID')
				   );
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END IF;

------
------ Validate Alarm
------
      l_alarm_type_code := task_ass_rec.alarm_type_code;
      l_alarm_contact := task_ass_rec.alarm_contact;
      -------
      ------- Validate	Sched. Travel Duration
      -------
      l_sched_travel_duration := task_ass_rec.sched_travel_duration;
      l_sched_travel_dur_uom := task_ass_rec.sched_travel_dur_uom;
      jtf_task_utl.validate_effort (
	 p_tag => jtf_task_utl.get_translated_lookup (
		     'JTF_TASK_TRANSLATED_MESSAGES',
		     'SCHEDULED_TRAVEL_DURATION'
		  ),
	 p_tag_uom => jtf_task_utl.get_translated_lookup (
			 'JTF_TASK_TRANSLATED_MESSAGES',
			 'SCHEDULED_TRAVEL_DURATION_UOM'
		      ),
	 x_return_status => x_return_status,
	 p_effort => l_sched_travel_duration,
	 p_effort_uom => l_sched_travel_dur_uom
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate	Actual Travel Duration
      -------
      l_actual_travel_duration := task_ass_rec.actual_travel_duration;
      l_actual_travel_dur_uom := task_ass_rec.actual_travel_dur_uom;
      jtf_task_utl.validate_effort (
	 p_tag => jtf_task_utl.get_translated_lookup (
		     'JTF_TASK_TRANSLATED_MESSAGES',
		     'ACTUAL_TRAVEL_DURATION'
		  ),
	 p_tag_uom => jtf_task_utl.get_translated_lookup (
			 'JTF_TASK_TRANSLATED_MESSAGES',
			 'SCHEDULED_TRAVEL_DURATION_UOM'
		      ),
	 x_return_status => x_return_status,
	 p_effort => l_actual_travel_duration,
	 p_effort_uom => l_actual_travel_dur_uom
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate	Actual Travel Distance
      -------
      l_actual_travel_distance := task_ass_rec.actual_travel_distance;
      jtf_task_utl.validate_distance (
	 p_distance_units => p_actual_travel_distance,
	 p_distance_tag => jtf_task_utl.get_translated_lookup (
			      'JTF_TASK_TRANSLATED_MESSAGES',
			      'ACTUAL_TRAVEL_DISTANCE'
			   ),
	 x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -------
      ------- Validate	Schedule Travel Distance
      -------
      l_sched_travel_distance := task_ass_rec.sched_travel_distance;
      jtf_task_utl.validate_distance (
	 p_distance_units => p_sched_travel_distance,
	 p_distance_tag => 'Schedule Travel Distance',
	 x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ------
      ------ Palm flag.
      ------
      l_palm_flag := task_ass_rec.palm_flag;
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'PALM_FLAG'
			),
	 p_flag_value => l_palm_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ------
      ------ Wince flag.
      ------
      l_wince_flag := task_ass_rec.wince_flag;
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'WINCE_FLAG'
			),
	 p_flag_value => l_wince_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ------
      ------ Laptop flag.
      ------
      l_laptop_flag := task_ass_rec.laptop_flag;
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'LAPTOP_FLAG'
			),
	 p_flag_value => l_laptop_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ------
      ------ Device1 flag.
      ------
      l_device1_flag := task_ass_rec.device1_flag;
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'DEVICE1_FLAG'
			),
	 p_flag_value => l_device1_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ------
      ------ Device2 flag.
      ------
      l_device2_flag := task_ass_rec.device1_flag;
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'DEVICE2_FLAG'
			),
	 p_flag_value => l_device2_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ------
      ------ Device3 flag.
      ------
      l_device3_flag := task_ass_rec.device3_flag;
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'DEVICE3_FLAG'
			),
	 p_flag_value => l_device3_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_resource_territory_id := task_ass_rec.resource_territory_id;
      ------
      ------ Schedule flag.
      ------
      l_schedule_flag := task_ass_rec.schedule_flag;
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => 'Schedule Flag',
	 p_flag_value => l_schedule_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ----
      ---- Validate dates
      ----
      ----
      l_actual_start_date := task_ass_rec.actual_start_date;
      l_actual_end_date := task_ass_rec.actual_end_date;
      jtf_task_utl.validate_dates (
	 p_date_tag => jtf_task_utl.get_translated_lookup (
			  'JTF_TASK_TRANSLATED_MESSAGES',
			  'ACTUAL'
		       ),
	 p_start_date => l_actual_start_date,
	 p_end_date => l_actual_end_date,
	 x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Validate the value in SHOW_ON_CALENDAR
      l_show_on_calendar := task_ass_rec.show_on_calendar;
      jtf_task_utl.validate_flag (
	 x_return_status => x_return_status,
	 p_flag_name => jtf_task_utl.get_translated_lookup (
			   'JTF_TASK_TRANSLATED_MESSAGES',
			   'PRIMARY_FLAG'
			),
	 p_flag_value => l_show_on_calendar
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Validate the value in category_id
      l_category_id := task_ass_rec.category_id;
      IF jtf_task_utl.g_validate_category = TRUE
      THEN
	 jtf_task_utl.validate_category (
	    p_category_id => l_category_id,
	    x_return_status => x_return_status
	 );

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END IF;

      -- Validate the code in status id
      jtf_task_utl.validate_status (
	 p_status_id => l_assignment_status_id,
	 p_type     => l_type,
	 x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_assignments_pub.lock_task_assignment (
	 p_api_version => 1.0,
	 p_init_msg_list => fnd_api.g_false,
	 p_commit => fnd_api.g_false,
	 p_task_assignment_id => p_task_assignment_id,
	 p_object_version_number => p_object_version_number,
	 x_return_status => x_return_status,
	 x_msg_data => x_msg_data,
	 x_msg_count => x_msg_count
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      jtf_task_assignments_pvt.update_task_assignment (
	 p_api_version => l_api_version,
	 p_object_version_number => p_object_version_number,
	 p_init_msg_list => fnd_api.g_false,
	 p_commit => fnd_api.g_false,
	 p_task_assignment_id => l_task_assignment_id,
	 p_sched_travel_duration_uom => l_sched_travel_dur_uom,
	 p_actual_travel_distance => l_actual_travel_distance,
	 p_actual_travel_duration => l_actual_travel_duration,
	 p_actual_travel_duration_uom => l_actual_travel_dur_uom,
	 p_actual_start_date => l_actual_start_date,
	 p_actual_end_date => l_actual_end_date,
	 p_palm_flag => l_palm_flag,
	 p_wince_flag => l_wince_flag,
	 p_laptop_flag => l_laptop_flag,
	 p_device1_flag => l_device1_flag,
	 p_device2_flag => l_device2_flag,
	 p_device3_flag => l_device3_flag,
	 p_resource_id => l_resource_id,
	 p_actual_effort => l_act_eff,
	 p_actual_effort_uom => l_act_eff_uom,
	 p_schedule_flag => l_schedule_flag,
	 p_alarm_type_code => l_alarm_type_code,
	 p_alarm_contact => l_alarm_contact,
	 p_sched_travel_distance => l_sched_travel_distance,
	 p_sched_travel_duration => l_sched_travel_duration,
	 p_resource_type_code => l_resource_type_code,
	 p_resource_territory_id => l_resource_territory_id,
	 p_assignment_status_id => l_assignment_status_id,
	 p_shift_construct_id => l_shift_construct_id,
	 x_msg_data => x_msg_data,
	 x_msg_count => x_msg_count,
	 x_return_status => x_return_status,
	 p_attribute1 => task_ass_rec.attribute1,
	 p_attribute2 => task_ass_rec.attribute2,
	 p_attribute3 => task_ass_rec.attribute3,
	 p_attribute4 => task_ass_rec.attribute4,
	 p_attribute5 => task_ass_rec.attribute5,
	 p_attribute6 => task_ass_rec.attribute6,
	 p_attribute7 => task_ass_rec.attribute7,
	 p_attribute8 => task_ass_rec.attribute8,
	 p_attribute9 => task_ass_rec.attribute9,
	 p_attribute10 => task_ass_rec.attribute10,
	 p_attribute11 => task_ass_rec.attribute11,
	 p_attribute12 => task_ass_rec.attribute12,
	 p_attribute13 => task_ass_rec.attribute13,
	 p_attribute14 => task_ass_rec.attribute14,
	 p_attribute15 => task_ass_rec.attribute15,
	 p_attribute_category => task_ass_rec.attribute_category,
	 p_show_on_calendar => l_show_on_calendar,
	 p_category_id => l_category_id,
	 p_enable_workflow => l_enable_workflow,
	 p_abort_workflow  => l_abort_workflow,
         p_free_busy_type  => fnd_api.g_miss_char,
         p_object_capacity_id => p_object_capacity_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      p_task_assignments_user_hooks.task_assignment_id :=
	 p_task_assignment_id;

/*	jtf_task_assignments_iuhk.update_task_assignment_post(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

*/
      IF fnd_api.to_boolean (p_commit)
      THEN
	 COMMIT WORK;
      END IF;

      IF task_ass_u%ISOPEN
      THEN
	 CLOSE task_ass_u;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
	 ROLLBACK TO update_task_assignment_pub;

	 IF task_ass_u%ISOPEN
	 THEN
	    CLOSE task_ass_u;
	 END IF;

	 x_return_status := fnd_api.g_ret_sts_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	 ROLLBACK TO update_task_assignment_pub;

	 IF task_ass_u%ISOPEN
	 THEN
	    CLOSE task_ass_u;
	 END IF;

	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN OTHERS
      THEN
	 ROLLBACK TO update_task_assignment_pub;

	 IF task_ass_u%ISOPEN
	 THEN
	    CLOSE task_ass_u;
	 END IF;

	 x_return_status := fnd_api.g_ret_sts_unexp_error;

	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
	 THEN
	    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
	 END IF;

	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
   END;

 --overloading update procedure
   PROCEDURE update_task_assignment (
      p_api_version		     IN       NUMBER,
      p_object_version_number	     IN OUT NOCOPY   NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER,
      p_task_id 		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_task_number		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_task_name		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_type_code	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_id		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_resource_name		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_effort		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_effort_uom	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_schedule_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_alarm_type_code 	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_alarm_contact		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_sched_travel_distance	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_sched_travel_duration	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_sched_travel_duration_uom    IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_travel_distance	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_travel_duration	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_travel_duration_uom   IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_start_date	     IN       DATE DEFAULT fnd_api.g_miss_date,
      p_actual_end_date 	     IN       DATE DEFAULT fnd_api.g_miss_date,
      p_palm_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_wince_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_laptop_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device1_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device2_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device3_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_territory_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_assignment_status_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_shift_construct_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      x_return_status		     OUT NOCOPY      VARCHAR2,
      x_msg_count		     OUT NOCOPY      NUMBER,
      x_msg_data		     OUT NOCOPY      VARCHAR2,
      p_attribute1		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_show_on_calendar	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_category_id		     IN       NUMBER
	    DEFAULT jtf_task_utl.g_miss_number,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2
   )
   IS
   BEGIN
      jtf_task_assignments_pub.update_task_assignment (
      p_api_version		     => p_api_version,
      p_object_version_number	     => p_object_version_number,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_task_id 		     => p_task_id,
      p_task_number		     => p_task_number,
      p_task_name		     => p_task_name,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
      p_resource_name		     => p_resource_name,
      p_actual_effort		     => p_actual_effort,
      p_actual_effort_uom	     => p_actual_effort_uom,
      p_schedule_flag		     => p_schedule_flag,
      p_alarm_type_code 	     => p_alarm_type_code,
      p_alarm_contact		     => p_alarm_contact,
      p_sched_travel_distance	     => p_sched_travel_distance,
      p_sched_travel_duration	     => p_sched_travel_duration,
      p_sched_travel_duration_uom    => p_sched_travel_duration_uom,
      p_actual_travel_distance	     => p_actual_travel_distance,
      p_actual_travel_duration	     => p_actual_travel_duration,
      p_actual_travel_duration_uom   => p_actual_travel_duration_uom,
      p_actual_start_date	     => p_actual_start_date,
      p_actual_end_date 	     => p_actual_end_date,
      p_palm_flag		     => p_palm_flag,
      p_wince_flag		     => p_wince_flag,
      p_laptop_flag		     => p_laptop_flag,
      p_device1_flag		     => p_device1_flag,
      p_device2_flag		     => p_device2_flag,
      p_device3_flag		     => p_device3_flag,
      p_resource_territory_id	     => p_resource_territory_id,
      p_assignment_status_id	     => p_assignment_status_id,
      p_shift_construct_id	     => p_shift_construct_id,
      x_return_status		     => x_return_status,
      x_msg_count		     => x_msg_count,
      x_msg_data		     => x_msg_data,
      p_attribute1		     => p_attribute1,
      p_attribute2		     => p_attribute2,
      p_attribute3		     => p_attribute3,
      p_attribute4		     => p_attribute4,
      p_attribute5		     => p_attribute5,
      p_attribute6		     => p_attribute6,
      p_attribute7		     => p_attribute7,
      p_attribute8		     => p_attribute8,
      p_attribute9		     => p_attribute9,
      p_attribute10		     => p_attribute10,
      p_attribute11		     => p_attribute11,
      p_attribute12		     => p_attribute12,
      p_attribute13		     => p_attribute13,
      p_attribute14		     => p_attribute14,
      p_attribute15		     => p_attribute15,
      p_attribute_category	     => p_attribute_category,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => p_enable_workflow,
      p_abort_workflow		     => p_abort_workflow,
      p_object_capacity_id           => fnd_api.g_miss_num
      );
  END;

 --overloading update procedure
   PROCEDURE update_task_assignment (
      p_api_version		     IN       NUMBER,
      p_object_version_number	     IN OUT NOCOPY   NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER,
      p_task_id 		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_task_number		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_task_name		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_type_code	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_id		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_resource_name		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_effort		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_effort_uom	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_schedule_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_alarm_type_code 	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_alarm_contact		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_sched_travel_distance	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_sched_travel_duration	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_sched_travel_duration_uom    IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_travel_distance	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_travel_duration	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_actual_travel_duration_uom   IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_actual_start_date	     IN       DATE DEFAULT fnd_api.g_miss_date,
      p_actual_end_date 	     IN       DATE DEFAULT fnd_api.g_miss_date,
      p_palm_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_wince_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_laptop_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device1_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device2_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_device3_flag		     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_territory_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_assignment_status_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_shift_construct_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      x_return_status		     OUT NOCOPY      VARCHAR2,
      x_msg_count		     OUT NOCOPY      NUMBER,
      x_msg_data		     OUT NOCOPY      VARCHAR2,
      p_attribute1		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_show_on_calendar	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_category_id		     IN       NUMBER
	    DEFAULT jtf_task_utl.g_miss_number
   )
   IS
   BEGIN
      jtf_task_assignments_pub.update_task_assignment (
      p_api_version		     => p_api_version,
      p_object_version_number	     => p_object_version_number,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_task_id 		     => p_task_id,
      p_task_number		     => p_task_number,
      p_task_name		     => p_task_name,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
      p_resource_name		     => p_resource_name,
      p_actual_effort		     => p_actual_effort,
      p_actual_effort_uom	     => p_actual_effort_uom,
      p_schedule_flag		     => p_schedule_flag,
      p_alarm_type_code 	     => p_alarm_type_code,
      p_alarm_contact		     => p_alarm_contact,
      p_sched_travel_distance	     => p_sched_travel_distance,
      p_sched_travel_duration	     => p_sched_travel_duration,
      p_sched_travel_duration_uom    => p_sched_travel_duration_uom,
      p_actual_travel_distance	     => p_actual_travel_distance,
      p_actual_travel_duration	     => p_actual_travel_duration,
      p_actual_travel_duration_uom   => p_actual_travel_duration_uom,
      p_actual_start_date	     => p_actual_start_date,
      p_actual_end_date 	     => p_actual_end_date,
      p_palm_flag		     => p_palm_flag,
      p_wince_flag		     => p_wince_flag,
      p_laptop_flag		     => p_laptop_flag,
      p_device1_flag		     => p_device1_flag,
      p_device2_flag		     => p_device2_flag,
      p_device3_flag		     => p_device3_flag,
      p_resource_territory_id	     => p_resource_territory_id,
      p_assignment_status_id	     => p_assignment_status_id,
      p_shift_construct_id	     => p_shift_construct_id,
      x_return_status		     => x_return_status,
      x_msg_count		     => x_msg_count,
      x_msg_data		     => x_msg_data,
      p_attribute1		     => p_attribute1,
      p_attribute2		     => p_attribute2,
      p_attribute3		     => p_attribute3,
      p_attribute4		     => p_attribute4,
      p_attribute5		     => p_attribute5,
      p_attribute6		     => p_attribute6,
      p_attribute7		     => p_attribute7,
      p_attribute8		     => p_attribute8,
      p_attribute9		     => p_attribute9,
      p_attribute10		     => p_attribute10,
      p_attribute11		     => p_attribute11,
      p_attribute12		     => p_attribute12,
      p_attribute13		     => p_attribute13,
      p_attribute14		     => p_attribute14,
      p_attribute15		     => p_attribute15,
      p_attribute_category	     => p_attribute_category,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
      p_abort_workflow		     => fnd_profile.value('JTF_TASK_ABORT_PREV_WF')
      );
  END;

--Procedure to Delete the Task Assignment
   PROCEDURE delete_task_assignment (
      p_api_version		IN	 NUMBER,
      p_object_version_number	IN	 NUMBER,
      p_init_msg_list		IN	 VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			IN	 VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	IN	 NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_count		OUT NOCOPY	NUMBER,
      x_msg_data		OUT NOCOPY	VARCHAR2,
      p_enable_workflow 	IN	 VARCHAR2,
      p_abort_workflow		IN	 VARCHAR2
   )
   IS
--
--
      l_api_version   CONSTANT NUMBER
	       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
	       := 'Delete_Task_Assignment';
      l_return_status	       VARCHAR2(1)
	       := fnd_api.g_ret_sts_success;
      l_msg_data	       VARCHAR2(2000);
      l_msg_count	       NUMBER;
      l_task_assignment_id     jtf_task_all_assignments.task_assignment_id%TYPE
	       := p_task_assignment_id;
      l_enable_workflow 	 VARCHAR2(1)	:= p_enable_workflow;
      l_abort_workflow		 VARCHAR2(1)	:= p_abort_workflow;

      CURSOR ra_d
      IS
	 SELECT 1
	   FROM jtf_task_all_assignments
	  WHERE task_assignment_id = l_task_assignment_id;

      x 		       CHAR;
   BEGIN
      SAVEPOINT delete_task_assignment_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
		l_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	     )
      THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	 fnd_msg_pub.initialize;
      END IF;

      -------------
      ------------- Call the Internal Hook
      -------------
      -------------
/*p_task_assignments_user_hooks.task_assignment_id    := p_task_assignment_id ;
jtf_task_assignments_iuhk.delete_task_assignment_pre(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/	-------------
      -------------
      -------------
      -------------


      ---- if Task Assignment Id is null, then it is an error
      IF (l_task_assignment_id IS NULL)
      THEN
	 fnd_message.set_name ('JTF', 'JTF_TASK_NULL_TK_ASS');
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_assignments_pub.lock_task_assignment (
	 p_api_version => 1.0,
	 p_init_msg_list => fnd_api.g_false,
	 p_commit => fnd_api.g_false,
	 p_task_assignment_id => p_task_assignment_id,
	 p_object_version_number => p_object_version_number,
	 x_return_status => x_return_status,
	 x_msg_data => x_msg_data,
	 x_msg_count => x_msg_count
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ---- if task Assignment is NOT valid, then it is an error
/*	OPEN ra_d;
      FETCH ra_d INTO x;

      IF ra_d%NOTFOUND
      THEN
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_TK_ASS');
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      ELSE
	 jtf_task_assignments_pub.lock_task_assignment (
	    p_api_version => 1.0,
	    p_init_msg_list => fnd_api.g_false,
	    p_commit => fnd_api.g_false,
	    p_task_assignment_id => l_task_assignment_id,
	    p_object_version_number => p_object_version_number,
	    x_return_status => x_return_status,
	    x_msg_data => x_msg_data,
	    x_msg_count => x_msg_count
	 );

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;*/
      jtf_task_assignments_pvt.delete_task_assignment (
	 p_api_version => l_api_version,
	 p_object_version_number => p_object_version_number,
	 p_init_msg_list => fnd_api.g_false,
	 p_commit => fnd_api.g_false,
	 p_task_assignment_id => l_task_assignment_id,
	 x_return_status => x_return_status,
	 x_msg_count => l_msg_count,
	 x_msg_data => l_msg_data,
	 p_enable_workflow => l_enable_workflow,
	 p_abort_workflow => l_abort_workflow
      );

      IF (x_return_status = fnd_api.g_ret_sts_error)
      THEN
	 RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

--	END IF;

/*	IF ra_d%ISOPEN
      THEN
	 CLOSE ra_d;
      END IF;
*/

      -------------
      ------------- Call the Internal Hook
      -------------
      -------------

/*jtf_task_assignments_iuhk.delete_task_assignment_post(x_return_status );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/	-------------
      -------------
      -------------
      -------------
      IF fnd_api.to_boolean (p_commit)
      THEN
	 COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
	 ROLLBACK TO delete_task_assignment_pub;
/*	   IF ra_d%ISOPEN
	 THEN
	    CLOSE ra_d;
	 END IF;
*/
	 x_return_status := fnd_api.g_ret_sts_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	 ROLLBACK TO delete_task_assignment_pub;
/*	   IF ra_d%ISOPEN
	 THEN
	    CLOSE ra_d;
	 END IF;

*/
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN OTHERS
      THEN
	 ROLLBACK TO delete_task_assignment_pub;
/*	   IF ra_d%ISOPEN
	 THEN
	    CLOSE ra_d;
	 END IF;
*/
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
   END;


 --overloading delete procedure
   PROCEDURE delete_task_assignment (
      p_api_version		IN	 NUMBER,
      p_object_version_number	IN	 NUMBER,
      p_init_msg_list		IN	 VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			IN	 VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	IN	 NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_count		OUT NOCOPY	NUMBER,
      x_msg_data		OUT NOCOPY	VARCHAR2
   )
   IS
   BEGIN
      jtf_task_assignments_pub.delete_task_assignment (
      p_api_version		=> p_api_version,
      p_object_version_number	=> p_object_version_number,
      p_init_msg_list		=> p_init_msg_list,
      p_commit			=> p_commit,
      p_task_assignment_id	=> p_task_assignment_id,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_enable_workflow 	=> fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
      p_abort_workflow		=> fnd_profile.value('JTF_TASK_ABORT_PREV_WF')
      );
   END;
END;

/
