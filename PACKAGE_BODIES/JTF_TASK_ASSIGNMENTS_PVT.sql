--------------------------------------------------------
--  DDL for Package Body JTF_TASK_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_ASSIGNMENTS_PVT" AS
/* $Header: jtfvtkab.pls 120.3.12000000.2 2007/07/19 08:45:38 lokumar ship $ */

   g_free_busy_type CONSTANT jtf_task_all_assignments.free_busy_type%TYPE	:= 'FREE';

   -- Internal procedures used for implicit booking
   -- It populates booking date by using task calendar date
   --
   -- !!! NOTE: any change in this procedure must be in sync with !!!
   -- !!!       migration script cacbkgmg.sql                     !!!
   --
   PROCEDURE populate_owner_booking_dates
   (
      p_calendar_start_date     IN	DATE,
      p_calendar_end_date       IN	DATE,
      p_actual_travel_duration  IN  NUMBER,
      p_actual_travel_duration_uom   IN VARCHAR2,
      p_planned_effort          IN  NUMBER,
      p_planned_effort_uom      IN   VARCHAR2,
      x_booking_start_date      OUT NOCOPY DATE,
      x_booking_end_date        OUT NOCOPY DATE
   )
   IS
   BEGIN
       x_booking_start_date := NULL;
       x_booking_end_date   := NULL;

       IF (p_calendar_start_date IS NULL) OR
          (p_calendar_start_date > p_calendar_end_date) OR
          (p_calendar_end_date IS NULL AND NVL(p_planned_effort, -1) < 0)
       THEN
          RETURN;
       END IF;

       x_booking_start_date := jtf_task_utl_ext.adjust_date
       (
          p_calendar_start_date,
          p_actual_travel_duration * (-1),
          p_actual_travel_duration_uom
       );


       IF (p_calendar_start_date <= p_calendar_end_date)
       THEN
           x_booking_end_date := p_calendar_end_date;
       ELSE
           x_booking_end_date := jtf_task_utl_ext.adjust_date
           (
              p_calendar_start_date,
              p_planned_effort,
              p_planned_effort_uom
           );
       END IF;
   END populate_owner_booking_dates;

   -- Internal procedures used for implicit booking
   -- It populates booking date by using actual assignment date or
   -- task calendar date
   --
   -- !!! NOTE: any change in this procedure must be in sync with !!!
   -- !!!       migration script cacbkgmg.sql                     !!!
   --
   PROCEDURE populate_booking_dates
   (
      p_calendar_start_date     IN	DATE,
      p_calendar_end_date       IN	DATE,
      p_actual_start_date       IN	DATE,
      p_actual_end_date         IN	DATE,
      p_actual_travel_duration  IN  NUMBER,
      p_actual_travel_duration_uom   IN VARCHAR2,
      p_planned_effort          IN  NUMBER,
      p_planned_effort_uom      IN  VARCHAR2,
      p_actual_effort           IN  NUMBER,
      p_actual_effort_uom       IN  VARCHAR2,
      x_booking_start_date      OUT NOCOPY DATE,
      x_booking_end_date        OUT NOCOPY DATE
    )
    IS
    BEGIN
        x_booking_start_date := NULL;
        x_booking_end_date   := NULL;

        IF (p_actual_start_date IS NULL) OR
           (p_actual_start_date > p_actual_end_date) OR
           (p_actual_end_date IS NULL AND
            NVL(p_actual_effort, NVL(p_planned_effort, -1)) < 0)

        THEN
            -- Populate the booking dates as for owner .
            populate_owner_booking_dates
            (
              p_calendar_start_date     => p_calendar_start_date,
              p_calendar_end_date       => p_calendar_end_date,
              p_actual_travel_duration  => p_actual_travel_duration,
              p_actual_travel_duration_uom => p_actual_travel_duration_uom,
              p_planned_effort          => p_planned_effort,
              p_planned_effort_uom      => p_planned_effort_uom,
              x_booking_start_date      => x_booking_start_date,
              x_booking_end_date        => x_booking_end_date
            );
            RETURN;
        END IF;

        x_booking_start_date := jtf_task_utl_ext.adjust_date
        (
          p_actual_start_date,
          p_actual_travel_duration * (-1),
          p_actual_travel_duration_uom
        );


        IF  p_actual_start_date <= p_actual_end_date
        THEN
            x_booking_end_date   := p_actual_end_date;
        ELSIF p_actual_effort >= 0
        THEN
           x_booking_end_date := jtf_task_utl_ext.adjust_date
           (
              p_actual_start_date,
              p_actual_effort,
              p_actual_effort_uom
           );
        ELSE
           x_booking_end_date := jtf_task_utl_ext.adjust_date
           (
              p_actual_start_date,
              p_planned_effort,
              p_planned_effort_uom
           );
        END IF;
    END populate_booking_dates;

    -- This procedure updates the free-busy type for an assignee
    -- Should be call only for tasks for a new assignemnt and
    -- whenever the assignemnt status is changed
    --
    -- !!! NOTE: any change in this procedure must be in sync with !!!
    -- !!!       migration script cacbkgmg.sql                     !!!
    --
    PROCEDURE update_free_busy_type
    (
      p_assignment_status_id     IN NUMBER,
      x_free_busy_type           IN OUT NOCOPY VARCHAR2
    )
    IS
    BEGIN
       select decode(cancelled_flag, 'Y', 'FREE',
              decode(rejected_flag,  'Y', 'FREE',
              decode(working_flag,   'Y', 'BUSY',
              decode(accepted_flag,  'Y', 'BUSY',
              decode(assigned_flag,  'Y', 'BUSY', x_free_busy_type )))))
         into x_free_busy_type
         from jtf_task_statuses_b
        where task_status_id = p_assignment_status_id;
    END update_free_busy_type;

   PROCEDURE create_task_assignment (
      p_api_version		     IN       NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER DEFAULT NULL,
      p_task_id 		     IN       NUMBER DEFAULT NULL,
      p_resource_type_code	     IN       VARCHAR2,
      p_resource_id		     IN       NUMBER,
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
      p_assignee_role		     IN       VARCHAR2 DEFAULT 'ASSIGNEE',
      p_show_on_calendar	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
      p_category_id		     IN       NUMBER DEFAULT NULL,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2,
      p_add_option		     IN       VARCHAR2,
      p_free_busy_type		     IN       VARCHAR2,
      p_object_capacity_id           IN       NUMBER
   )
   IS
      l_api_version	CONSTANT NUMBER
	       := 1.0;
      l_api_name	CONSTANT VARCHAR(30)
	       := 'CREATE_TASK_ASSIGNMENTS';
      l_return_status		 VARCHAR2(1)
	       := fnd_api.g_ret_sts_success;
      l_task_assignment_id	 jtf_task_all_assignments.task_assignment_id%TYPE;
      l_task_id 		 jtf_tasks_b.task_id%TYPE
	       := p_task_id;
      l_resource_type_code	 jtf_task_all_assignments.resource_type_code%TYPE
	       := p_resource_type_code;
      l_resource_id		 NUMBER
	       := p_resource_id;
      l_act_eff 		 NUMBER
	       := p_actual_effort;
      l_act_eff_uom		 VARCHAR2(3)
	       := p_actual_effort_uom;
      l_schedule_flag		 VARCHAR2(1)
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
      l_assignee_role		 jtf_task_all_assignments.assignee_role%TYPE
	       := p_assignee_role;
      l_show_on_calendar	 jtf_task_all_assignments.show_on_calendar%TYPE
	       := p_show_on_calendar;
      l_category_id		 jtf_task_all_assignments.category_id%TYPE
	       := p_category_id;
      l_enable_workflow 	 VARCHAR2(1)	:= p_enable_workflow;
      l_abort_workflow		 VARCHAR2(1)	:= p_abort_workflow;

      -- Simplex Changes ..
      l_booking_start_date jtf_task_all_assignments.booking_start_date%TYPE;
      l_booking_end_date 	 jtf_task_all_assignments.booking_end_date%TYPE;
	    l_free_busy_type   	 jtf_task_all_assignments.free_busy_type%TYPE
	                         := p_free_busy_type;

      CURSOR ra_cur1 (l_rowid IN ROWID)
      IS
	 SELECT 1
	   FROM jtf_task_all_assignments
	  WHERE ROWID = l_rowid;

      ------------------------------------------
      -- For XP
      ------------------------------------------
      CURSOR c_task (b_task_id NUMBER)IS
      SELECT source_object_type_code
	   , recurrence_rule_id
	   , calendar_start_date
       , calendar_end_date
       , planned_effort
       , planned_effort_uom
       , entity
       , open_flag
	FROM jtf_tasks_b
       WHERE task_id = b_task_id;

      rec_task	c_task%ROWTYPE;

      l_add_assignee_rec  jtf_task_repeat_assignment_pvt.add_assignee_rec;

       -- Business Event System Enhancement # 2391065
      l_assignment_rec	  jtf_task_assignments_pvt.task_assignments_rec ;
      x_event_return_status varchar2(100);
      ------------------------------------------
   BEGIN
      SAVEPOINT create_task_assign_pvt;
      x_return_status := fnd_api.g_ret_sts_success;

      ------------------------------------------
      -- For XP
      ------------------------------------------
      OPEN c_task (l_task_id);
      FETCH c_task INTO rec_task;
      IF c_task%NOTFOUND
      THEN
	 CLOSE c_task;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TASK_ID');
	 fnd_message.set_token ('P_TASK_ID', l_task_id);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE c_task;

      IF rec_task.source_object_type_code = 'APPOINTMENT' AND
	 rec_task.recurrence_rule_id IS NOT NULL
      THEN
	 IF p_add_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE OR
	    p_add_option = JTF_TASK_REPEAT_APPT_PVT.G_ALL OR
	    p_add_option = JTF_TASK_REPEAT_APPT_PVT.G_ONE
	 THEN
	     l_add_assignee_rec.recurrence_rule_id   := rec_task.recurrence_rule_id;
	     l_add_assignee_rec.task_id 	     := l_task_id;
	     l_add_assignee_rec.calendar_start_date  := rec_task.calendar_start_date;
	     l_add_assignee_rec.resource_type_code   := p_resource_type_code;
	     l_add_assignee_rec.resource_id	     := p_resource_id;
	     l_add_assignee_rec.free_busy_type       := p_free_busy_type;
	     l_add_assignee_rec.assignment_status_id := p_assignment_status_id;
	     l_add_assignee_rec.add_option	     := p_add_option;
	     l_add_assignee_rec.enable_workflow      := p_enable_workflow;
	     l_add_assignee_rec.abort_workflow	     := p_abort_workflow;

	     jtf_task_repeat_assignment_pvt.add_assignee(
		p_api_version	     => 1.0,
		p_init_msg_list      => fnd_api.g_false,
		p_commit	     => fnd_api.g_false,
		p_add_assignee_rec   => l_add_assignee_rec,
		x_return_status      => x_return_status,
		x_msg_count	     => x_msg_count,
		x_msg_data	     => x_msg_data,
		x_task_assignment_id => x_task_assignment_id
	     );

	     RETURN;
	  ELSIF p_add_option IS NOT NULL AND
		p_add_option <> JTF_TASK_REPEAT_APPT_PVT.G_SKIP
	  THEN
	     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_FLAG');
	     fnd_message.set_token ('P_FLAG_NAME', 'The parameter p_add_option ');
	     fnd_msg_pub.add;

	     x_return_status := fnd_api.g_ret_sts_unexp_error;
	     RAISE fnd_api.g_exc_unexpected_error;
	  END IF;
      END IF;
      ------------------------------------------

      IF p_task_assignment_id IS NOT NULL
      THEN
	 IF p_task_assignment_id > jtf_task_utl_ext.get_last_number('JTF_TASK_ASSIGNMENTS_S') and -- Enh# 2734020
	    p_task_assignment_id < 1e+12
	 THEN
	    fnd_message.set_name ('JTF', 'JTF_TASK_OUT_OF_RANGE');
	    fnd_msg_pub.add;
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 ELSE
	    l_task_assignment_id := p_task_assignment_id;
	 END IF;
      ELSE
	 SELECT jtf_task_assignments_s.nextval
	   INTO l_task_assignment_id
	   FROM dual;
      END IF;

     -- Validate the value in L_RESOURCE_TYPE_CODE
      IF    l_resource_type_code = 'RS_TEAM'
	 OR l_resource_type_code = 'RS_GROUP'
      THEN
	 l_category_id := NULL;
      END IF;

      -- Validate the value in ASSIGNEE_ROLE
    IF NOT jtf_task_utl.validate_lookup(
       'JTF_TASK_ASSIGNEE_ROLES',
       NVL (l_assignee_role, 'ASSIGNEE'),
       'assignment assignee role ( JTF_TK_ASSOGNEE_ROLE )')
    THEN
	      x_return_status := fnd_api.g_ret_sts_unexp_error;
	      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    -- Implicit booking for tasks
    populate_booking_dates
    (
       p_calendar_start_date    =>  rec_task.calendar_start_date,
       p_calendar_end_date      =>  rec_task.calendar_end_date,
       p_actual_start_date      =>  l_actual_start_date,
       p_actual_end_date        =>  l_actual_end_date,
       p_actual_travel_duration =>  l_actual_travel_duration,
       p_actual_travel_duration_uom  =>  l_actual_travel_dur_uom,
       p_planned_effort         =>  rec_task.planned_effort,
       p_planned_effort_uom     =>  rec_task.planned_effort_uom,
       p_actual_effort          =>  l_act_eff,
       p_actual_effort_uom      =>  l_act_eff_uom,
       x_booking_start_date     =>  l_booking_start_date,
       x_booking_end_date       =>  l_booking_end_date
    );


    IF l_free_busy_type IS NULL
    THEN
       l_free_busy_type := g_free_busy_type;
       IF rec_task.entity = 'TASK' AND
          l_booking_start_date IS NOT NULL AND
          l_booking_end_date IS NOT NULL
       THEN
           IF p_assignee_role = 'OWNER' AND p_show_on_calendar = 'Y'
           THEN
                 l_free_busy_type := 'BUSY';
           ELSIF p_assignee_role = 'ASSIGNEE'
           THEN
               update_free_busy_type
               (
                p_assignment_status_id => l_assignment_status_id,
                x_free_busy_type       => l_free_busy_type
               );
           END IF;
       END IF;
    END IF;

      jtf_task_assignments_pkg.insert_row (
	 x_rowid => l_rowid,
	 x_task_assignment_id => l_task_assignment_id,
	 x_sched_travel_duration_uom => l_sched_travel_dur_uom,
	 x_actual_travel_distance => l_actual_travel_distance,
	 x_actual_travel_duration => l_actual_travel_duration,
	 x_actual_travel_duration_uom => l_actual_travel_dur_uom,
	 x_actual_start_date => l_actual_start_date,
	 x_actual_end_date => l_actual_end_date,
	 x_palm_flag => l_palm_flag,
	 x_wince_flag => l_wince_flag,
	 x_laptop_flag => l_laptop_flag,
	 x_device1_flag => l_device1_flag,
	 x_device2_flag => l_device2_flag,
	 x_device3_flag => l_device3_flag,
	 x_attribute1 => p_attribute1,
	 x_attribute2 => p_attribute2,
	 x_attribute3 => p_attribute3,
	 x_attribute4 => p_attribute4,
	 x_attribute5 => p_attribute5,
	 x_attribute6 => p_attribute6,
	 x_attribute7 => p_attribute7,
	 x_attribute8 => p_attribute8,
	 x_attribute9 => p_attribute9,
	 x_attribute10 => p_attribute10,
	 x_attribute11 => p_attribute11,
	 x_attribute12 => p_attribute12,
	 x_attribute13 => p_attribute13,
	 x_attribute14 => p_attribute14,
	 x_attribute15 => p_attribute15,
	 x_attribute_category => p_attribute_category,
	 x_task_id => l_task_id,
	 x_resource_id => l_resource_id,
	 x_actual_effort => l_act_eff,
	 x_actual_effort_uom => l_act_eff_uom,
	 x_schedule_flag => l_schedule_flag,
	 x_alarm_type_code => l_alarm_type_code,
	 x_alarm_contact => l_alarm_contact,
	 x_sched_travel_distance => l_sched_travel_distance,
	 x_sched_travel_duration => l_sched_travel_duration,
	 x_resource_type_code => l_resource_type_code,
	 x_creation_date => SYSDATE,
	 x_created_by => jtf_task_utl.created_by,
	 x_last_update_date => SYSDATE,
	 x_last_updated_by => jtf_task_utl.updated_by,
	 x_last_update_login => jtf_task_utl.login_id,
	 x_resource_territory_id => l_resource_territory_id,
	 x_assignment_status_id => l_assignment_status_id,
	 x_shift_construct_id => l_shift_construct_id,
	 x_assignee_role => l_assignee_role,
	 x_show_on_calendar => l_show_on_calendar,
	 x_category_id => l_category_id,
	 x_free_busy_type => NVL(l_free_busy_type, g_free_busy_type),
         x_booking_start_date => l_booking_start_date,
         x_booking_end_date => l_booking_end_date,
         x_object_capacity_id => p_object_capacity_id
      );

      OPEN ra_cur1 (l_rowid);
      FETCH ra_cur1 INTO x;

      IF ra_cur1%NOTFOUND
      THEN
	 CLOSE ra_cur1; -- Fix a missing CLOSE on 4/18/2002
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_TK_ASS');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      ELSE
	 x_task_assignment_id := l_task_assignment_id;
      END IF;
      CLOSE ra_cur1; -- Fix a missing CLOSE on 4/18/2002

      ---
      --- decide the launch of workflow
      ---

      -- Business Event System Enhancement # 2391065 and 2797666
      IF (rec_task.entity = 'TASK')
      THEN
      l_assignment_rec.task_assignment_id     := l_task_assignment_id;
      l_assignment_rec.task_id		      := l_task_id;
      l_assignment_rec.resource_type_code     := l_resource_type_code;
      l_assignment_rec.resource_id	      := l_resource_id;
      l_assignment_rec.assignment_status_id   := l_assignment_status_id;
      l_assignment_rec.actual_start_date      := l_actual_start_date;
      l_assignment_rec.actual_end_date	      := l_actual_end_date;
      l_assignment_rec.assignee_role          := l_assignee_role;
      l_assignment_rec.show_on_calendar	      := l_show_on_calendar;
      l_assignment_rec.category_id	      := l_category_id;
      l_assignment_rec.enable_workflow	      := p_enable_workflow;
      l_assignment_rec.abort_workflow	      := l_abort_workflow;

      jtf_task_wf_events_pvt.publish_create_assignment(l_assignment_rec, x_event_return_status);

      IF (x_event_return_status = 'WARNING')
      THEN
	   fnd_message.set_name ('JTF', 'JTF_TASK_ASS_EVENT_WARNING');
	   fnd_message.set_token ('P_ASSIGNMENT_ID', l_task_assignment_id);
	   fnd_msg_pub.add;
		ELSIF(x_event_return_status = 'ERROR')
		THEN
		   fnd_message.set_name ('JTF', 'JTF_TASK_ASS_EVENT_ERROR');
	   fnd_message.set_token ('P_ASSIGNMENT_ID', l_task_assignment_id);
	   fnd_msg_pub.add;
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   RAISE fnd_api.g_exc_unexpected_error;
		END IF ;

       END IF;

  -- ------------------------------------------------------------------------
  -- Create reference to resource, fix for enh #1845501
  -- ------------------------------------------------------------------------
     IF  (rec_task.source_object_type_code <> 'APPOINTMENT')  THEN
     --Do not create automatic references for party assignment created for an APPOINTMENT
     --Check bug 3968128
      jtf_task_utl.create_party_reference (
	 p_reference_from   => 'ASSIGNMENT',
	 p_task_id	=> l_task_id,
	 p_party_type_code	=> l_resource_type_code,
	 p_party_id	=> l_resource_id,
	 x_msg_count	    => x_msg_count,
	 x_msg_data	=> x_msg_data,
	 x_return_status    => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    END IF; -- for the if statement for (rec_task.source_object_type_code <> 'APPOINTMENT')

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	 ROLLBACK TO create_task_assign_pvt;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN OTHERS
      THEN
	 ROLLBACK TO create_task_assign_pvt;
	 fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
	 fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
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
      p_resource_type_code	     IN       VARCHAR2,
      p_resource_id		     IN       NUMBER,
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
      p_assignee_role		     IN       VARCHAR2 DEFAULT 'ASSIGNEE',
      p_show_on_calendar	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
      p_category_id		     IN       NUMBER DEFAULT NULL,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2,
      p_add_option		     IN       VARCHAR2,
      p_free_busy_type		     IN       VARCHAR2
   )
   IS
   BEGIN

      create_task_assignment (
      p_api_version		     =>       p_api_version,
      p_init_msg_list		     =>       p_init_msg_list,
      p_commit			     =>       p_commit,
      p_task_assignment_id	     =>       p_task_assignment_id,
      p_task_id 		     =>       p_task_id,
      p_resource_type_code	     =>       p_resource_type_code,
      p_resource_id		     =>       p_resource_id,
      p_actual_effort		     =>       p_actual_effort,
      p_actual_effort_uom	     =>       p_actual_effort_uom,
      p_schedule_flag		     =>       p_schedule_flag,
      p_alarm_type_code 	     =>       p_alarm_type_code,
      p_alarm_contact		     =>       p_alarm_contact,
      p_sched_travel_distance	     =>       p_sched_travel_distance,
      p_sched_travel_duration	     =>       p_sched_travel_duration,
      p_sched_travel_duration_uom    =>       p_sched_travel_duration_uom,
      p_actual_travel_distance	     =>       p_actual_travel_distance,
      p_actual_travel_duration	     =>       p_actual_travel_duration,
      p_actual_travel_duration_uom   =>       p_actual_travel_duration_uom,
      p_actual_start_date	     =>       p_actual_start_date,
      p_actual_end_date 	     =>       p_actual_end_date,
      p_palm_flag		     =>       p_palm_flag,
      p_wince_flag		     =>       p_wince_flag,
      p_laptop_flag		     =>       p_laptop_flag,
      p_device1_flag		     =>       p_device1_flag,
      p_device2_flag		     =>       p_device2_flag,
      p_device3_flag		     =>       p_device3_flag,
      p_resource_territory_id	     =>       p_resource_territory_id,
      p_assignment_status_id	     =>       p_assignment_status_id,
      p_shift_construct_id	     =>       p_shift_construct_id,
      x_return_status		     =>       x_return_status,
      x_msg_count		     =>       x_msg_count,
      x_msg_data		     =>       x_msg_data,
      x_task_assignment_id	     =>       x_task_assignment_id,
      p_attribute1		     =>       p_attribute1,
      p_attribute2		     =>       p_attribute2,
      p_attribute3		     =>       p_attribute3,
      p_attribute4		     =>       p_attribute4,
      p_attribute5		     =>       p_attribute5,
      p_attribute6		     =>       p_attribute6,
      p_attribute7		     =>       p_attribute7,
      p_attribute8		     =>       p_attribute8,
      p_attribute9		     =>       p_attribute9,
      p_attribute10		     =>       p_attribute10,
      p_attribute11		     =>       p_attribute11,
      p_attribute12		     =>       p_attribute12,
      p_attribute13		     =>       p_attribute13,
      p_attribute14		     =>       p_attribute14,
      p_attribute15		     =>       p_attribute15,
      p_attribute_category	     =>       p_attribute_category,
      p_assignee_role		     =>       p_assignee_role,
      p_show_on_calendar	     =>       p_show_on_calendar,
      p_category_id		     =>       p_category_id,
      p_enable_workflow 	     =>       p_enable_workflow,
      p_abort_workflow		     =>       p_abort_workflow,
      p_add_option		     =>       p_add_option,
      p_free_busy_type		     =>       p_free_busy_type,
      p_object_capacity_id           =>       NULL
   );
   END;

    PROCEDURE create_task_assignment (
      p_api_version		     IN       NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER DEFAULT NULL,
      p_task_id 		     IN       NUMBER DEFAULT NULL,
      p_resource_type_code	     IN       VARCHAR2,
      p_resource_id		     IN       NUMBER,
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
      p_assignee_role		     IN       VARCHAR2 DEFAULT 'ASSIGNEE',
      p_show_on_calendar	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
      p_category_id		     IN       NUMBER DEFAULT NULL,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2,
      p_add_option		     IN       VARCHAR2
    )
   IS
   BEGIN
      jtf_task_assignments_pvt.create_task_assignment (
      p_api_version		     => p_api_version,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_task_id 		     => p_task_id,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
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
      p_assignee_role		     => p_assignee_role,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => p_enable_workflow,
      p_abort_workflow		     => p_abort_workflow,
      p_add_option		     => p_add_option,
      p_free_busy_type		     => NULL
      );
   END;


   PROCEDURE create_task_assignment (
      p_api_version		     IN       NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER DEFAULT NULL,
      p_task_id 		     IN       NUMBER DEFAULT NULL,
      p_resource_type_code	     IN       VARCHAR2,
      p_resource_id		     IN       NUMBER,
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
      p_assignee_role		     IN       VARCHAR2 DEFAULT 'ASSIGNEE',
      p_show_on_calendar	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_yes_char,
      p_category_id		     IN       NUMBER DEFAULT NULL,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2
    )
   IS
   BEGIN
      jtf_task_assignments_pvt.create_task_assignment (
      p_api_version		     => p_api_version,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_task_id 		     => p_task_id,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
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
      p_assignee_role		     => p_assignee_role,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => p_enable_workflow,
      p_abort_workflow		     => p_abort_workflow,
      p_add_option		     => JTF_TASK_REPEAT_APPT_PVT.G_ONE,
      p_free_busy_type		     => NULL
      );
   END;

   PROCEDURE create_task_assignment (
      p_api_version		     IN       NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER DEFAULT NULL,
      p_task_id 		     IN       NUMBER DEFAULT NULL,
      p_resource_type_code	     IN       VARCHAR2,
      p_resource_id		     IN       NUMBER,
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
      p_assignee_role		     IN       VARCHAR2 DEFAULT 'ASSIGNEE',
      p_show_on_calendar	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_yes_char,
      p_category_id		     IN       NUMBER DEFAULT NULL
   )
   IS
   BEGIN
      jtf_task_assignments_pvt.create_task_assignment (
      p_api_version		     => p_api_version,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_task_id 		     => p_task_id,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
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
      p_assignee_role		     => p_assignee_role,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
      p_abort_workflow		     => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
	  p_add_option		         => JTF_TASK_REPEAT_APPT_PVT.G_ONE,
      p_free_busy_type		     => NULL
      );
   END;

--Procedure to Update the Task Assignment
   PROCEDURE update_task_assignment (
      p_api_version		     IN       NUMBER,
      p_object_version_number	     IN       OUT NOCOPY   NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_resource_type_code	     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_resource_id		     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_actual_effort		     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_actual_effort_uom	     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_schedule_flag		     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_alarm_type_code 	     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_alarm_contact		     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_sched_travel_distance	     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_sched_travel_duration	     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_sched_travel_duration_uom    IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_actual_travel_distance	     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_actual_travel_duration	     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_actual_travel_duration_uom   IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_actual_start_date	     IN       DATE DEFAULT fnd_api.g_miss_date,
      p_actual_end_date 	     IN       DATE DEFAULT fnd_api.g_miss_date,
      p_palm_flag		     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_wince_flag		     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_laptop_flag		     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_device1_flag		     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_device2_flag		     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_device3_flag		     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_resource_territory_id	     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_assignment_status_id	     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_shift_construct_id	     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      x_return_status		     OUT      NOCOPY      VARCHAR2,
      x_msg_count		     OUT      NOCOPY      NUMBER,
      x_msg_data		     OUT      NOCOPY      VARCHAR2,
      p_attribute1		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_assignee_role		     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_show_on_calendar	     IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_category_id		     IN       NUMBER DEFAULT jtf_task_utl.g_miss_number,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2,
      p_free_busy_type		     IN       VARCHAR2
   )
   IS
   BEGIN
      jtf_task_assignments_pvt.update_task_assignment (
      p_api_version		     => p_api_version,
      p_object_version_number	     => p_object_version_number,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
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
      p_assignee_role		     => p_assignee_role,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => p_enable_workflow,
      p_abort_workflow		     => p_abort_workflow,
      p_free_busy_type		     => p_free_busy_type,
      p_object_capacity_id           => fnd_api.g_miss_num
      );
   END;

--Procedure to Update the Task Assignment
   PROCEDURE update_task_assignment (
      p_api_version		     IN       NUMBER,
      p_object_version_number	     IN OUT NOCOPY   NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_resource_type_code	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_id		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
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
      p_assignee_role		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_show_on_calendar	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_category_id		     IN       NUMBER
	    DEFAULT jtf_task_utl.g_miss_number,
      p_enable_workflow 	     IN       VARCHAR2,
      p_abort_workflow		     IN       VARCHAR2,
      p_free_busy_type		     IN       VARCHAR2,
      p_object_capacity_id           IN       NUMBER
   )
   IS
      l_api_version	CONSTANT NUMBER
	       := 1.0;
      l_api_name	CONSTANT VARCHAR(30)
	       := 'Update_Task_Assignment';
      l_return_status		 VARCHAR2(1)
	       := fnd_api.g_ret_sts_success;
      l_task_assignment_id	 jtf_task_all_assignments.task_assignment_id%TYPE
	       := p_task_assignment_id;
      l_task_id 		 jtf_task_all_assignments.task_id%TYPE;
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
      l_assignment_status_id	 jtf_task_all_assignments.assignment_status_id%TYPE
	       := p_assignment_status_id;
      l_resource_territory_id	 jtf_task_all_assignments.resource_territory_id%TYPE
	       := p_resource_territory_id;
      l_shift_construct_id	 jtf_task_all_assignments.shift_construct_id%TYPE
	       := p_shift_construct_id;
      l_assignee_role		 jtf_task_all_assignments.assignee_role%TYPE
	       := p_assignee_role;
      l_show_on_calendar	 jtf_task_all_assignments.show_on_calendar%TYPE
	       := p_show_on_calendar;
      l_category_id		 jtf_task_all_assignments.category_id%TYPE
	       := p_category_id;
      l_assignee_role_db	 jtf_task_all_assignments.assignee_role%TYPE;
      l_session 		 VARCHAR2(10) := 'UPDATE';
      l_enable_workflow 	 VARCHAR2(1)  := p_enable_workflow;
      l_abort_workflow		 VARCHAR2(1)  := p_abort_workflow;
      l_free_busy_type		 jtf_task_all_assignments.free_busy_type%TYPE
	       := p_free_busy_type;
      l_object_capacity_id	 jtf_task_all_assignments.object_capacity_id%TYPE
	       := p_object_capacity_id;
      l_booking_start_date	 jtf_task_all_assignments.booking_start_date%TYPE;
      l_booking_end_date 	 jtf_task_all_assignments.booking_end_date%TYPE;

      -- Added for bug# 5514013 on 11/09/2006
      l_old_assignment_status_id   jtf_task_all_assignments.assignment_status_id%TYPE;

      CURSOR task_ass_u
      IS
	 SELECT task_id,
		assignment_status_id   old_assignment_status_id,
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
		   p_assignee_role,
		   fnd_api.g_miss_char, assignee_role,
		   p_assignee_role
		) assignee_role,
		DECODE (
		   p_show_on_calendar,
		   fnd_api.g_miss_char, show_on_calendar,
		   p_show_on_calendar
		) show_on_calendar,
		DECODE (
		   p_category_id,
		   jtf_task_utl.g_miss_number, category_id,
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
		) attribute_category,
		DECODE (
		   p_free_busy_type,
		   jtf_task_utl.g_miss_char, free_busy_type,
		   p_free_busy_type
		) free_busy_type,
		DECODE (
		   p_object_capacity_id,
		   fnd_api.g_miss_num, object_capacity_id,
		   p_object_capacity_id
		) object_capacity_id
	   FROM jtf_task_all_assignments
	  WHERE task_assignment_id = l_task_assignment_id;

      x 			 CHAR;
      task_ass			 task_ass_u%ROWTYPE;

--      CURSOR ass_res_orig (b_task_assignment_id IN NUMBER)
--      IS
--	 SELECT resource_id, resource_type_code, free_busy_type,assignment_status_id, object_capacity_id
--	   FROM jtf_task_all_assignments
--	  WHERE task_assignment_id = b_task_assignment_id;

      l_orig_res_id           jtf_task_all_assignments.resource_id%type;
      l_orig_res_type_code    jtf_task_all_assignments.resource_type_code%type;
      l_orig_object_capacity_id   jtf_task_all_assignments.object_capacity_id%type;

       -- Business Event System Enhancement # 2391065
      l_assignment_rec_old	  jtf_task_assignments_pvt.task_assignments_rec ;
	  l_assignment_rec_new	  jtf_task_assignments_pvt.task_assignments_rec ;
      ass_orig		      jtf_task_utl.c_ass_orig%ROWTYPE;
      x_event_return_status   varchar2(100);

      CURSOR c_task (b_task_id NUMBER) IS
      SELECT source_object_type_code
	   , recurrence_rule_id
	   , calendar_start_date
       , calendar_end_date
       , planned_effort
       , planned_effort_uom
       , open_flag
       , entity
	   FROM jtf_tasks_b
       WHERE task_id = b_task_id;

      l_source_object_type_code   jtf_tasks_b.source_object_type_code%TYPE;
      l_recurrence_rule_id	  NUMBER;
      l_calendar_start_date	  DATE;
      l_calendar_end_date     DATE;
      l_planned_effort        NUMBER;
      l_planned_effort_uom    jtf_tasks_b.planned_effort_uom%TYPE;
      l_entity               jtf_tasks_b.entity%TYPE;
      l_open_flag            jtf_tasks_b.open_flag%TYPE;
      l_response_invitation_rec  jtf_task_repeat_assignment_pvt.response_invitation_rec;
   BEGIN
      SAVEPOINT update_task_assign_pvt;
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN task_ass_u;
      FETCH task_ass_u INTO task_ass;

      IF task_ass_u%NOTFOUND
      THEN
	 CLOSE task_ass_u;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INS_TK_ASS');
	 fnd_message.set_token ('TASK_ASSIGNMENT', p_task_assignment_id);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE task_ass_u;

      -- Business Event System Enhancement # 2391065
	  OPEN jtf_task_utl.c_ass_orig(p_task_assignment_id);
      FETCH jtf_task_utl.c_ass_orig INTO ass_orig;

      IF jtf_task_utl.c_ass_orig%NOTFOUND
      THEN
	 CLOSE jtf_task_utl.c_ass_orig;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INS_TK_ASS');
	 fnd_message.set_token ('TASK_ASSIGNMENT', p_task_assignment_id);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE jtf_task_utl.c_ass_orig;

      l_task_assignment_id := p_task_assignment_id;
      l_task_id := task_ass.task_id;
      l_resource_id := task_ass.resource_id;
      l_resource_type_code := task_ass.resource_type_code;
      l_old_assignment_status_id := task_ass.old_assignment_status_id; -- Added for bug#5514013 on 11/09/2006
      l_assignment_status_id := task_ass.assignment_status_id;
      l_act_eff := task_ass.actual_effort;
      l_act_eff_uom := task_ass.actual_effort_uom;
      l_alarm_type_code := task_ass.alarm_type_code;
      l_alarm_contact := task_ass.alarm_contact;
      l_sched_travel_distance := task_ass.sched_travel_distance;
      l_sched_travel_duration := task_ass.sched_travel_duration;
      l_sched_travel_dur_uom := task_ass.sched_travel_dur_uom;
      -- Bug 3467524
      -- l_actual_travel_distance := task_ass.actual_travel_duration;
      l_actual_travel_distance := task_ass.actual_travel_distance;
      l_actual_travel_duration := task_ass.actual_travel_duration;
      l_actual_travel_dur_uom := task_ass.actual_travel_dur_uom;
      l_actual_start_date := task_ass.actual_start_date;
      l_actual_end_date := task_ass.actual_end_date;
      l_palm_flag := task_ass.palm_flag;
      l_wince_flag := task_ass.wince_flag;
      l_laptop_flag := task_ass.laptop_flag;
      l_device1_flag := task_ass.device1_flag;
      l_device2_flag := task_ass.device2_flag;
      l_device3_flag := task_ass.device3_flag;
      l_resource_territory_id := task_ass.resource_territory_id;
      l_shift_construct_id := task_ass.shift_construct_id;
      l_assignee_role	:= task_ass.assignee_role;
      l_show_on_calendar   := task_ass.show_on_calendar;
      l_category_id	   := task_ass.category_id;
      --add schedule_flag
      l_schedule_flag := task_ass.schedule_flag;
      l_free_busy_type := task_ass.free_busy_type;
      l_object_capacity_id := task_ass.object_capacity_id;

      --------------------------------------------------
      -- For XP Sync: Story# 140
      --------------------------------------------------
      OPEN c_task (l_task_id);
      FETCH c_task
       INTO l_source_object_type_code
	  , l_recurrence_rule_id
	  , l_calendar_start_date
      , l_calendar_end_date
      , l_planned_effort
      , l_planned_effort_uom
      , l_open_flag
      , l_entity;
      IF c_task%NOTFOUND
      THEN
	 CLOSE c_task;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TASK_ID');
	 fnd_message.set_token ('P_TASK_ID', l_task_id);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE c_task;

      IF l_recurrence_rule_id IS NOT NULL AND
	 l_source_object_type_code = 'APPOINTMENT' AND
	 task_ass.old_assignment_status_id  in ( 18 , 3 ) -- Invited
      THEN
	 IF g_response_flag = jtf_task_utl.g_no_char
	 THEN
	     l_response_invitation_rec.task_assignment_id   := p_task_assignment_id;
	     l_response_invitation_rec.assignment_status_id := l_assignment_status_id;
	     l_response_invitation_rec.task_id		    := l_task_id;
	     l_response_invitation_rec.recurrence_rule_id   := l_recurrence_rule_id;

	     jtf_task_repeat_assignment_pvt.response_invitation(
		p_api_version		  => 1.0,
		p_init_msg_list 	  => fnd_api.g_false,
		p_commit		  => fnd_api.g_false,
		p_object_version_number   => p_object_version_number,
		p_response_invitation_rec => l_response_invitation_rec,
		x_return_status 	  => x_return_status,
		x_msg_count		  => x_msg_count,
		x_msg_data		  => x_msg_data
	     );

	     g_response_flag := jtf_task_utl.g_no_char;

	     ----------------------------------------------------------------
	     -- response_invitation() will call this procedure again
	     --    to update the assignment status with accepted or rejected.
	     -- So this procedure must return right after the call because
	     --    the remaining process has already been processed
	     --    by response_invitation().
	     ----------------------------------------------------------------
	     RETURN;
	  END IF;
      END IF;
      ------------------------------------------------------------------------

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
      END IF;


      -- Validate the user_id
	 jtf_task_utl.check_security_privilege(
		    p_task_id => l_task_id,
		    p_session => l_session,
		    x_return_status => x_return_status
		    );

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

      --Bug 2467222  for assignee category update
      IF (p_category_id <> jtf_task_utl.g_miss_number) OR (p_category_id IS NULL)
      THEN
      UPDATE jtf_task_all_assignments
	 SET category_id = p_category_id
       WHERE task_id = l_task_id
	 AND resource_id = (SELECT resource_id
			    FROM jtf_rs_resource_extns
			    WHERE user_id = fnd_global.user_id)
	 AND resource_type_code not in ('RS_GROUP','RS_TEAM');
      END IF;

      -- Validate the value in L_RESOURCE_TYPE_CODE
      IF    l_resource_type_code = 'RS_TEAM'
	 OR l_resource_type_code = 'RS_GROUP'
      THEN
	 l_category_id := NULL;
      END IF;

      -- bug# 1947303
      IF l_assignee_role IS NULL
      THEN
	 l_assignee_role := 'ASSIGNEE';
      END IF;

     -- Validate the value in ASSIGNEE_ROLE
      IF NOT jtf_task_utl.validate_lookup (
		'JTF_TASK_ASSIGNEE_ROLES',
		l_assignee_role,
		'assignment assignee role ( JTF_TK_ASSOGNEE_ROLE )'
	     )
      THEN
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Update the values based on ASSIGNEE_ROLE
      select assignee_role
      into l_assignee_role_db
      from jtf_task_all_assignments
      where task_assignment_id = l_task_assignment_id;
      IF l_assignee_role_db = 'OWNER'
      THEN
	 UPDATE jtf_tasks_b
	    SET owner_id = l_resource_id,
		owner_type_code = l_resource_type_code
	  WHERE task_id = l_task_id;
      END IF;

	 l_assignee_role := l_assignee_role_db;

      -- ------------------------------------------------------------------------
      -- Get the original resource_id so we can update the reference details if
      -- necessary
      -- ------------------------------------------------------------------------

--	OPEN ass_res_orig (l_task_assignment_id);
--	FETCH ass_res_orig INTO l_orig_res_id, l_orig_res_type_code, l_orig_free_busy_type, l_orig_assig_status_id, l_object_capacity_id;

--        IF (p_object_capacity_id <> fnd_api.g_miss_num and p_object_capacity_id is not null)
--        then
--          l_object_capacity_id := p_object_capacity_id;
--        end if;

--	IF ass_res_orig%NOTFOUND
--	THEN
--	   CLOSE ass_res_orig; -- Fix a missing CLOSE on 4/18/2002
--	   RAISE fnd_api.g_exc_unexpected_error;
--	END IF;
--	CLOSE ass_res_orig; -- Fix a missing CLOSE on 4/18/2002

      -- Booking Changes for Simplex ..
          populate_booking_dates
          (
           p_calendar_start_date    =>  l_calendar_start_date,
           p_calendar_end_date      =>  l_calendar_end_date,
           p_actual_start_date      =>  l_actual_start_date,
           p_actual_end_date        =>  l_actual_end_date,
           p_actual_travel_duration =>  l_actual_travel_duration,
           p_actual_travel_duration_uom  =>  l_actual_travel_dur_uom,
           p_planned_effort         =>  l_planned_effort,
           p_planned_effort_uom     =>  l_planned_effort_uom,
           p_actual_effort          =>  l_act_eff,
           p_actual_effort_uom      =>  l_act_eff_uom,
           x_booking_start_date     =>  l_booking_start_date,
           x_booking_end_date       =>  l_booking_end_date
          );

     IF l_entity = 'TASK' AND
        p_free_busy_type = jtf_task_utl.g_miss_char AND -- no explicit value
        nvl(p_assignment_status_id, 0) <> fnd_api.g_miss_num AND
        nvl(l_old_assignment_status_id, 0) <> nvl(l_assignment_status_id, 0)         -- Modified for bug# 5514013 on 11/09/2006
     THEN
         update_free_busy_type(
            p_assignment_status_id => l_assignment_status_id,
            x_free_busy_type       => l_free_busy_type
         );
     END IF;

      p_object_version_number := p_object_version_number + 1;
      jtf_task_assignments_pkg.update_row (
	 x_task_assignment_id => l_task_assignment_id,
	 x_object_version_number => p_object_version_number,
	 x_sched_travel_duration_uom => l_sched_travel_dur_uom,
	 x_actual_travel_distance => l_actual_travel_distance,
	 x_actual_travel_duration => l_actual_travel_duration,
	 x_actual_travel_duration_uom => l_actual_travel_dur_uom,
	 x_actual_start_date => l_actual_start_date,
	 x_actual_end_date => l_actual_end_date,
	 x_palm_flag => l_palm_flag,
	 x_wince_flag => l_wince_flag,
	 x_laptop_flag => l_laptop_flag,
	 x_device1_flag => l_device1_flag,
	 x_device2_flag => l_device2_flag,
	 x_device3_flag => l_device3_flag,
	 x_attribute1 => task_ass.attribute1,
	 x_attribute2 => task_ass.attribute2,
	 x_attribute3 => task_ass.attribute3,
	 x_attribute4 => task_ass.attribute4,
	 x_attribute5 => task_ass.attribute5,
	 x_attribute6 => task_ass.attribute6,
	 x_attribute7 => task_ass.attribute7,
	 x_attribute8 => task_ass.attribute8,
	 x_attribute9 => task_ass.attribute9,
	 x_attribute10 => task_ass.attribute10,
	 x_attribute11 => task_ass.attribute11,
	 x_attribute12 => task_ass.attribute12,
	 x_attribute13 => task_ass.attribute13,
	 x_attribute14 => task_ass.attribute14,
	 x_attribute15 => task_ass.attribute15,
	 x_attribute_category => task_ass.attribute_category,
	 x_task_id => l_task_id,
	 x_resource_id => l_resource_id,
	 x_actual_effort => l_act_eff,
	 x_actual_effort_uom => l_act_eff_uom,
	 x_schedule_flag => l_schedule_flag,
	 x_alarm_type_code => l_alarm_type_code,
	 x_alarm_contact => l_alarm_contact,
	 x_sched_travel_distance => l_sched_travel_distance,
	 x_sched_travel_duration => l_sched_travel_duration,
	 x_resource_type_code => l_resource_type_code,
	 x_last_update_date => SYSDATE,
	 x_last_updated_by => jtf_task_utl.updated_by,
	 x_last_update_login => jtf_task_utl.login_id,
	 x_resource_territory_id => l_resource_territory_id,
	 x_assignment_status_id => l_assignment_status_id,
	 x_shift_construct_id => l_shift_construct_id,
	 x_assignee_role => l_assignee_role,
	 x_show_on_calendar => l_show_on_calendar,
       --x_category_id => l_category_id
	 x_free_busy_type => NVL(l_free_busy_type, g_free_busy_type),
   x_booking_start_date => l_booking_start_date,
	 x_booking_end_date => l_booking_end_date,
   x_object_capacity_id => l_object_capacity_id
      );

      IF task_ass_u%ISOPEN
      THEN
	 CLOSE task_ass_u;
      END IF;

  -- ------------------------------------------------------------------------
  -- Update reference to resource if changed, fix enh #1845501
  -- ------------------------------------------------------------------------
      if (nvl(l_resource_id, 0) <> fnd_api.g_miss_num and
	  nvl(l_resource_id, 0) <> nvl(l_orig_res_id, 0))
	 or (nvl(l_resource_type_code, fnd_api.g_miss_char) <> nvl(l_orig_res_type_code, fnd_api.g_miss_char)) then
      -- delete the old one
	 jtf_task_utl.delete_party_reference(
	    p_reference_from	=> 'ASSIGNMENT',
	    p_task_id	    => l_task_id,
	    p_party_type_code	=> l_orig_res_type_code,
	    p_party_id	    => l_orig_res_id,
	    x_msg_count     => x_msg_count,
	    x_msg_data	    => x_msg_data,
	    x_return_status	=> x_return_status);

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
	 -- create a new one
	 jtf_task_utl.create_party_reference(
	    p_reference_from	=> 'ASSIGNMENT',
	    p_task_id	    => l_task_id,
	    p_party_type_code	=> l_resource_type_code,
	    p_party_id	    => l_resource_id,
	    x_msg_count     => x_msg_count,
	    x_msg_data	    => x_msg_data,
	    x_return_status	=> x_return_status);

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      end if;

      ---
      --- decide to lunch workflow
      ---
       -- Business Event System Enhancement # 2391065 and 2797666
      IF (l_entity = 'TASK')
      THEN
	  l_assignment_rec_old.task_assignment_id     := l_task_assignment_id;
	  l_assignment_rec_old.task_id		      := l_task_id;
      l_assignment_rec_old.resource_type_code	  := ass_orig.resource_type_code;
      l_assignment_rec_old.resource_id		  := ass_orig.resource_id;
      l_assignment_rec_old.assignment_status_id   := ass_orig.assignment_status_id;
      l_assignment_rec_old.actual_start_date	  := ass_orig.actual_start_date;
      l_assignment_rec_old.actual_end_date	  := ass_orig.actual_end_date;
	  l_assignment_rec_old.assignee_role	      := ass_orig.assignee_role;
	  l_assignment_rec_old.show_on_calendar       := ass_orig.show_on_calendar;
      l_assignment_rec_old.category_id		  := ass_orig.category_id;
	  l_assignment_rec_old.object_version_number  := ass_orig.object_version_number;
      l_assignment_rec_old.enable_workflow	   := p_enable_workflow;
      l_assignment_rec_old.abort_workflow	   := l_abort_workflow;

	  l_assignment_rec_new.task_assignment_id     := l_task_assignment_id;
	  l_assignment_rec_new.task_id	   := l_task_id;
      l_assignment_rec_new.resource_type_code	  := l_resource_type_code;
      l_assignment_rec_new.resource_id		  := l_resource_id;
      l_assignment_rec_new.assignment_status_id   := l_assignment_status_id;
      l_assignment_rec_new.actual_start_date	  := l_actual_start_date;
      l_assignment_rec_new.actual_end_date	  := l_actual_end_date;
	  l_assignment_rec_new.assignee_role	      := l_assignee_role;
	  l_assignment_rec_new.show_on_calendar       := l_show_on_calendar;
      l_assignment_rec_new.category_id		  := l_category_id;
	  l_assignment_rec_new.object_version_number  := p_object_version_number;
	  l_assignment_rec_new.enable_workflow	       := p_enable_workflow;
      l_assignment_rec_new.abort_workflow	   := l_abort_workflow;

     jtf_task_wf_events_pvt.publish_update_assignment(l_assignment_rec_new,l_assignment_rec_old,x_event_return_status);

		IF (x_event_return_status = 'WARNING')
		THEN
		   fnd_message.set_name ('JTF', 'JTF_TASK_ASS_EVENT_WARNING');
	   fnd_message.set_token ('P_ASSIGNMENT_ID', l_task_assignment_id);
	   fnd_msg_pub.add;
		ELSIF(x_event_return_status = 'ERROR')
		THEN
		   fnd_message.set_name ('JTF', 'JTF_TASK_ASS_EVENT_ERROR');
	   fnd_message.set_token ('P_ASSIGNMENT_ID', l_task_assignment_id);
	   fnd_msg_pub.add;
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   RAISE fnd_api.g_exc_unexpected_error;
		END IF ;

     END IF;

--      IF ass_res_orig%ISOPEN
--      THEN
--	 CLOSE ass_res_orig;
--      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
	 COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	 IF task_ass_u%ISOPEN
	 THEN
	    CLOSE task_ass_u;
	 END IF;

	 ROLLBACK TO update_task_assign_pvt;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN OTHERS
      THEN
	 IF task_ass_u%ISOPEN
	 THEN
	    CLOSE task_ass_u;
	 END IF;

	 ROLLBACK TO update_task_assign_pvt;

       -- Added by SBARAT on 23/05/2006 for bug# 5176073
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
      p_task_assignment_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_resource_type_code	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_id		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
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
      p_assignee_role		     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_show_on_calendar	     IN       VARCHAR2
	    DEFAULT jtf_task_utl.g_miss_char,
      p_category_id		     IN       NUMBER
	    DEFAULT jtf_task_utl.g_miss_number
   )
   IS
   BEGIN
      jtf_task_assignments_pvt.update_task_assignment (
      p_api_version		     => p_api_version,
      p_object_version_number	     => p_object_version_number,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
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
      p_assignee_role		     => p_assignee_role,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
      p_abort_workflow		     => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
      p_free_busy_type		     => fnd_api.g_miss_char
      );
   END;

    PROCEDURE update_task_assignment (
      p_api_version		     IN       NUMBER,
      p_object_version_number	     IN OUT NOCOPY   NUMBER,
      p_init_msg_list		     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit			     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_assignment_id	     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
      p_resource_type_code	     IN       VARCHAR2
	    DEFAULT fnd_api.g_miss_char,
      p_resource_id		     IN       NUMBER
	    DEFAULT fnd_api.g_miss_num,
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
      p_assignee_role		     IN       VARCHAR2
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
      jtf_task_assignments_pvt.update_task_assignment (
      p_api_version		     => p_api_version,
      p_object_version_number	     => p_object_version_number,
      p_init_msg_list		     => p_init_msg_list,
      p_commit			     => p_commit,
      p_task_assignment_id	     => p_task_assignment_id,
      p_resource_type_code	     => p_resource_type_code,
      p_resource_id		     => p_resource_id,
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
      p_assignee_role		     => p_assignee_role,
      p_show_on_calendar	     => p_show_on_calendar,
      p_category_id		     => p_category_id,
      p_enable_workflow 	     => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
      p_abort_workflow		     => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
      p_free_busy_type		     => fnd_api.g_miss_char
      );
   END;

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
      p_abort_workflow		IN	 VARCHAR2,
      p_delete_option	      IN       VARCHAR2
   )
   IS
      --Declare the variables
      l_task_assignment_id   jtf_task_all_assignments.task_assignment_id%TYPE
	       := p_task_assignment_id;
      x 		     CHAR;

      CURSOR c_res_ass
      IS
	 SELECT 1
	   FROM jtf_task_all_assignments
	  WHERE task_assignment_id = l_task_assignment_id;

      l_session VARCHAR2(10) := 'DELETE';
      l_task_id jtf_task_all_assignments.task_id%TYPE;
      l_resource_id jtf_task_all_assignments.resource_id%TYPE;
      l_resource_type_code jtf_task_all_assignments.resource_type_code%TYPE;
      l_assignee_role jtf_task_all_assignments.assignee_role%TYPE;

      -- Business Event System Enhancement # 2391065
      l_assignment_status_id jtf_task_all_assignments.assignment_status_id%TYPE;
      CURSOR ass_res_orig (b_task_assignment_id IN NUMBER)
      IS
	 SELECT task_id, resource_id, resource_type_code, assignee_role, assignment_status_id
	   FROM jtf_task_all_assignments
	  WHERE task_assignment_id = b_task_assignment_id;

      l_enable_workflow 	 VARCHAR2(1)  := p_enable_workflow;
      l_abort_workflow		 VARCHAR2(1)  := p_abort_workflow;

      ------------------------------------------
      -- For XP
      ------------------------------------------
      CURSOR c_task (b_task_assignment_id NUMBER)IS
      SELECT jtb.source_object_type_code
	   , jtb.recurrence_rule_id
	   , jtb.calendar_start_date
	   , jtb.task_id
	   , jtaa.resource_id
       , jtb.entity
	FROM jtf_tasks_b jtb
	   , jtf_task_all_assignments jtaa
       WHERE jtaa.task_assignment_id = b_task_assignment_id
	 AND jtb.task_id = jtaa.task_id;

      rec_task	c_task%ROWTYPE;

      l_delete_assignee_rec  jtf_task_repeat_assignment_pvt.delete_assignee_rec;

      -- Business Event System Enhancement # 2391065
	  l_assignment_rec	  jtf_task_assignments_pvt.task_assignments_rec ;
      x_event_return_status  varchar2(100);
      ------------------------------------------
   BEGIN
      SAVEPOINT delete_task_ass_pvt;
      x_return_status := fnd_api.g_ret_sts_success;

      ------------------------------------------
      -- For XP
      ------------------------------------------
      OPEN c_task (p_task_assignment_id);
      FETCH c_task INTO rec_task;
      IF c_task%NOTFOUND
      THEN
	 CLOSE c_task;
	 fnd_message.set_name ('JTF', 'JTF_TASK_INV_TK_ASS');
	 fnd_message.set_token ('P_TASK_ASSIGNMENT_ID', p_task_assignment_id);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE c_task;

      l_task_id := rec_task.task_id;

      IF rec_task.source_object_type_code = 'APPOINTMENT' AND
	 rec_task.recurrence_rule_id IS NOT NULL
      THEN
	 IF p_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_ONE OR
	    p_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE OR
	    p_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_ALL
	 THEN
	     l_delete_assignee_rec.recurrence_rule_id	 := rec_task.recurrence_rule_id;
	     l_delete_assignee_rec.task_id		 := l_task_id;
	     l_delete_assignee_rec.calendar_start_date	 := rec_task.calendar_start_date;
	     l_delete_assignee_rec.resource_id		 := rec_task.resource_id;
	     l_delete_assignee_rec.delete_option	 := p_delete_option;
	     l_delete_assignee_rec.enable_workflow	 := p_enable_workflow;
	     l_delete_assignee_rec.abort_workflow	 := p_abort_workflow;

	     jtf_task_repeat_assignment_pvt.delete_assignee(
		p_api_version	      => 1.0,
		p_init_msg_list       => fnd_api.g_false,
		p_commit	      => fnd_api.g_false,
		p_delete_assignee_rec => l_delete_assignee_rec,
		x_return_status       => x_return_status,
		x_msg_count	      => x_msg_count,
		x_msg_data	      => x_msg_data
	     );

	     RETURN;
	  ELSIF p_delete_option IS NOT NULL AND
		p_delete_option <> JTF_TASK_REPEAT_APPT_PVT.G_SKIP
	  THEN
	     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_FLAG');
	     fnd_message.set_token ('P_FLAG_NAME', 'The parameter p_delete_option ');
	     fnd_msg_pub.add;

	     x_return_status := fnd_api.g_ret_sts_unexp_error;
	     RAISE fnd_api.g_exc_unexpected_error;
	  END IF;
      END IF;
      ------------------------------------------

      ---call the table handler to delete the resource req
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
      END IF;

      -- ------------------------------------------------------------------------
      -- Get the original resource_id so we can delete the reference details
      -- ------------------------------------------------------------------------

       -- Validate the user_id
	OPEN ass_res_orig (p_task_assignment_id);
	FETCH ass_res_orig INTO l_task_id, l_resource_id, l_resource_type_code, l_assignee_role, l_assignment_status_id;


	 IF ass_res_orig%NOTFOUND
	 THEN
	    CLOSE ass_res_orig; -- Fix a missing CLOSE on 4/18/2002
	    fnd_message.set_name ('JTF', 'JTF_TASK_INV_TK_ASS');
	    fnd_message.set_token ('P_TASK_ASSIGNMENT_ID', p_task_assignment_id);
	    fnd_msg_pub.add;
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
	 CLOSE ass_res_orig; -- Fix a missing CLOSE on 4/18/2002

	 jtf_task_utl.check_security_privilege(
		    p_task_id => l_task_id,
		    p_session => l_session,
		    x_return_status => x_return_status
		    );

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	 THEN
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;


      jtf_task_assignments_pkg.delete_row (
	 x_task_assignment_id => l_task_assignment_id
      );
      OPEN c_res_ass;
      FETCH c_res_ass INTO x;

      IF c_res_ass%FOUND
      THEN
	 CLOSE c_res_ass; -- Fix a missing CLOSE on 4/18/2002
	 fnd_message.set_name ('JTF', 'JTF_TASK_DELETING_TK_ASS');
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 RAISE fnd_api.g_exc_unexpected_error;
	 --CLOSE c_res_ass; -- Incorrect position for CLOSE
      ELSE
	 CLOSE c_res_ass;
      END IF;

      IF c_res_ass%ISOPEN
      THEN
	 CLOSE c_res_ass;
      END IF;

  -- ------------------------------------------------------------------------
  -- Delete reference to resource, fix enh #1845501
  -- ------------------------------------------------------------------------
	    jtf_task_utl.delete_party_reference(
	       p_reference_from     => 'ASSIGNMENT',
	       p_task_id	=> l_task_id,
	       p_party_type_code	=> l_resource_type_code,
	       p_party_id	=> l_resource_id,
	       x_msg_count	=> x_msg_count,
	       x_msg_data	=> x_msg_data,
	       x_return_status	    => x_return_status);

	    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	    THEN
	       x_return_status := fnd_api.g_ret_sts_unexp_error;
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

      ---
      --- decide the launch of workflow
      ---

      -- Business Event System Enhancement # 2391065 and 2797666
      IF (rec_task.entity = 'TASK')
      THEN
	  l_assignment_rec.task_assignment_id	      := l_task_assignment_id;
	  l_assignment_rec.task_id		      := l_task_id;
	  l_assignment_rec.resource_type_code	      := l_resource_type_code;
      l_assignment_rec.resource_id		  := l_resource_id;
      l_assignment_rec.assignment_status_id	  := l_assignment_status_id;
      l_assignment_rec.assignee_role		  := l_assignee_role;
	  l_assignment_rec.enable_workflow	      := p_enable_workflow;
      l_assignment_rec.abort_workflow		  := l_abort_workflow;

      jtf_task_wf_events_pvt.publish_delete_assignment(l_assignment_rec, x_event_return_status);

		IF (x_event_return_status = 'WARNING')
		THEN
		   fnd_message.set_name ('JTF', 'JTF_TASK_ASS_EVENT_WARNING');
	   fnd_message.set_token ('P_ASSIGNMENT_ID', l_task_assignment_id);
	   fnd_msg_pub.add;
		ELSIF(x_event_return_status = 'ERROR')
		THEN
		   fnd_message.set_name ('JTF', 'JTF_TASK_ASS_EVENT_ERROR');
	   fnd_message.set_token ('P_ASSIGNMENT_ID', l_task_assignment_id);
	   fnd_msg_pub.add;
		   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   RAISE fnd_api.g_exc_unexpected_error;
		END IF ;

      END IF;

      IF ass_res_orig%ISOPEN
      THEN
	 CLOSE ass_res_orig;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
	 COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	 ROLLBACK TO delete_task_ass_pvt;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
      WHEN OTHERS
      THEN
	 ROLLBACK TO delete_task_ass_pvt;

       -- Added by SBARAT on 23/05/2006 for bug# 5176073
	 fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
	 fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
	 fnd_msg_pub.add;

	 x_return_status := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
   END;

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
   BEGIN
      jtf_task_assignments_pvt.delete_task_assignment (
      p_api_version		=> p_api_version,
      p_object_version_number	=> p_object_version_number,
      p_init_msg_list		=> p_init_msg_list,
      p_commit			=> p_commit,
      p_task_assignment_id	=> p_task_assignment_id,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_enable_workflow 	=> p_enable_workflow,
      p_abort_workflow		=> p_abort_workflow,
      p_delete_option		=> JTF_TASK_REPEAT_APPT_PVT.G_ONE
      );
  END;

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
      jtf_task_assignments_pvt.delete_task_assignment (
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
