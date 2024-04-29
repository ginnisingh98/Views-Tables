--------------------------------------------------------
--  DDL for Package Body JTF_TASK_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_TEMPLATES_PVT" AS
/* $Header: jtfvtkmb.pls 120.1 2005/07/02 01:45:52 appldev ship $ */
   g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_TASK_TEMPLATES_PVT';

   PROCEDURE create_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id                   IN       NUMBER DEFAULT NULL,
      p_task_name                 IN       VARCHAR2,
      p_task_group_id             IN       NUMBER,
      p_task_type_id              IN       NUMBER DEFAULT NULL,
      p_description               IN       VARCHAR2 DEFAULT NULL,
      p_task_status_id            IN       NUMBER DEFAULT NULL,
      p_task_priority_id          IN       NUMBER DEFAULT NULL,
      p_duration                  IN       NUMBER DEFAULT NULL,
      p_duration_uom              IN       VARCHAR2 DEFAULT NULL,
      p_planned_effort            IN       NUMBER DEFAULT NULL,
      p_planned_effort_uom        IN       VARCHAR2 DEFAULT NULL,
      p_private_flag              IN       VARCHAR2 DEFAULT NULL,
      p_publish_flag              IN       VARCHAR2 DEFAULT NULL,
      p_restrict_closure_flag     IN       VARCHAR2 DEFAULT NULL,
      p_multi_booked_flag         IN       VARCHAR2 DEFAULT NULL,
      p_milestone_flag            IN       VARCHAR2 DEFAULT NULL,
      p_holiday_flag              IN       VARCHAR2 DEFAULT NULL,
      p_billable_flag             IN       VARCHAR2 DEFAULT NULL,
      p_notification_flag         IN       VARCHAR2 DEFAULT NULL,
      p_notification_period       IN       NUMBER DEFAULT NULL,
      p_notification_period_uom   IN       VARCHAR2 DEFAULT NULL,
      p_alarm_start               IN       NUMBER DEFAULT NULL,
      p_alarm_start_uom           IN       VARCHAR2 DEFAULT NULL,
      p_alarm_on                  IN       VARCHAR2 DEFAULT NULL,
      p_alarm_count               IN       NUMBER DEFAULT NULL,
      p_alarm_interval            IN       NUMBER DEFAULT NULL,
      p_alarm_interval_uom        IN       VARCHAR2 DEFAULT NULL,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      x_task_id                   OUT NOCOPY      NUMBER,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null
   )
   IS
      l_api_version   CONSTANT NUMBER                              := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'CREATE_TASK_TEMPLATES';


   BEGIN
      SAVEPOINT create_task_pvt1;
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

      jtf_task_templates_pvt.create_task
      (
      p_api_version          => p_api_version,
      p_init_msg_list        => p_init_msg_list,
      p_commit               => p_commit,
      p_task_id              => p_task_id,
      p_task_name            => p_task_name,
      p_task_group_id        => p_task_group_id,
      p_task_type_id         => p_task_type_id,
      p_description          => p_description,
      p_task_status_id       => p_task_status_id,
      p_task_priority_id	 => p_task_priority_id,
      p_duration	    => p_duration,
	  p_duration_uom 	=> p_duration_uom,
      p_planned_effort	=> p_planned_effort,
	  p_planned_effort_uom	    => p_planned_effort_uom,
      p_private_flag 	=> p_private_flag,
	  p_publish_flag 	=> p_publish_flag,
      p_restrict_closure_flag    => p_restrict_closure_flag,
	  p_multi_booked_flag	    => p_multi_booked_flag,
      p_milestone_flag	=> p_milestone_flag,
	  p_holiday_flag 	=> p_holiday_flag,
	  p_billable_flag	=> p_billable_flag,
      p_notification_flag	    => p_notification_flag,
	  p_notification_period	    => p_notification_period,
	  p_notification_period_uom  => p_notification_period_uom,
      p_alarm_start		=> p_alarm_start,
	  p_alarm_start_uom	=> p_alarm_start_uom,
	  p_alarm_on	    => p_alarm_on,
	  p_alarm_count		=> p_alarm_count,
      p_alarm_interval	=> p_alarm_interval,
	  p_alarm_interval_uom	    => p_alarm_interval_uom,
      x_return_status	=> x_return_status,
	  x_msg_count		=> x_msg_count,
	  x_msg_data	    => x_msg_data,
	  x_task_id	        => x_task_id,
      p_attribute1		=> p_attribute1,
	  p_attribute2		=> p_attribute2,
	  p_attribute3		=> p_attribute3,
	  p_attribute4		=> p_attribute4,
	  p_attribute5		=> p_attribute5,
	  p_attribute6		=> p_attribute6,
	  p_attribute7		=> p_attribute7,
	  p_attribute8		=> p_attribute8,
	  p_attribute9		=> p_attribute9,
	  p_attribute10		=> p_attribute10,
	  p_attribute11		=> p_attribute11,
	  p_attribute12		=> p_attribute12,
	  p_attribute13		=> p_attribute13,
	  p_attribute14		=> p_attribute14,
	  p_attribute15		=> p_attribute15,
      p_attribute_category	=> p_attribute_category,
      p_task_confirmation_status => 'N'

   );

     IF NOT (x_return_status = fnd_api.g_ret_sts_success)
     THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
     END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
      COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_task_pvt1;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_task_pvt1;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;
   -- Overloading for Simplex.
   PROCEDURE create_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id                   IN       NUMBER DEFAULT NULL,
      p_task_name                 IN       VARCHAR2,
      p_task_group_id             IN       NUMBER,
      p_task_type_id              IN       NUMBER DEFAULT NULL,
      p_description               IN       VARCHAR2 DEFAULT NULL,
      p_task_status_id            IN       NUMBER DEFAULT NULL,
      p_task_priority_id          IN       NUMBER DEFAULT NULL,
      p_duration                  IN       NUMBER DEFAULT NULL,
      p_duration_uom              IN       VARCHAR2 DEFAULT NULL,
      p_planned_effort            IN       NUMBER DEFAULT NULL,
      p_planned_effort_uom        IN       VARCHAR2 DEFAULT NULL,
      p_private_flag              IN       VARCHAR2 DEFAULT NULL,
      p_publish_flag              IN       VARCHAR2 DEFAULT NULL,
      p_restrict_closure_flag     IN       VARCHAR2 DEFAULT NULL,
      p_multi_booked_flag         IN       VARCHAR2 DEFAULT NULL,
      p_milestone_flag            IN       VARCHAR2 DEFAULT NULL,
      p_holiday_flag              IN       VARCHAR2 DEFAULT NULL,
      p_billable_flag             IN       VARCHAR2 DEFAULT NULL,
      p_notification_flag         IN       VARCHAR2 DEFAULT NULL,
      p_notification_period       IN       NUMBER DEFAULT NULL,
      p_notification_period_uom   IN       VARCHAR2 DEFAULT NULL,
      p_alarm_start               IN       NUMBER DEFAULT NULL,
      p_alarm_start_uom           IN       VARCHAR2 DEFAULT NULL,
      p_alarm_on                  IN       VARCHAR2 DEFAULT NULL,
      p_alarm_count               IN       NUMBER DEFAULT NULL,
      p_alarm_interval            IN       NUMBER DEFAULT NULL,
      p_alarm_interval_uom        IN       VARCHAR2 DEFAULT NULL,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      x_task_id                   OUT NOCOPY      NUMBER,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null ,
        p_task_confirmation_status IN	   VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER                              := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'CREATE_TASK_TEMPLATES';
      l_rowid                  ROWID;
      l_task_id                jtf_tasks_b.task_id%TYPE
               := p_task_id;
      l_task_number            jtf_tasks_b.task_number%TYPE;
      l_task_type_id           jtf_tasks_b.task_type_id%TYPE
               := p_task_type_id;
      l_task_status_id         jtf_tasks_b.task_status_id%TYPE
               := p_task_status_id;
      l_task_priority_id       jtf_tasks_b.task_priority_id%TYPE
               := p_task_priority_id;
      l_duration               jtf_tasks_b.duration%TYPE
               := p_duration;
      l_duration_uom           jtf_tasks_b.duration_uom%TYPE
               := p_duration_uom;
      l_planned_effort         jtf_tasks_b.planned_effort%TYPE
               := p_planned_effort;
      l_planned_effort_uom     jtf_tasks_b.planned_effort_uom%TYPE
               := p_planned_effort_uom;
      l_task_confirmation_status jtf_tasks_b.task_confirmation_status%TYPE
               := p_task_confirmation_status;

      CURSOR c_jtf_tasks (l_rowid IN ROWID)
      IS
         SELECT 1
           FROM jtf_task_templates_b
          WHERE ROWID = l_rowid;

      x                        CHAR;
   BEGIN

      null;

      SAVEPOINT create_task_pvt;
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

      IF l_task_id IS NOT NULL
      THEN
         IF l_task_id < 1e+12
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_TEMP_OUT_OF_RANGE');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         SELECT jtf_task_template_number_s.nextval
           INTO l_task_number
           FROM dual;
      ELSE
         SELECT jtf_task_templates_s.nextval
           INTO l_task_id
           FROM dual;
         SELECT jtf_task_template_number_s.nextval
           INTO l_task_number
           FROM dual;
      END IF;

      BEGIN
         SELECT 1
           INTO x
           FROM jtf_task_temp_groups_vl
          WHERE task_template_group_id = p_task_group_id
            AND NVL (end_date_active, SYSDATE) >= SYSDATE
            AND NVL (start_date_active, SYSDATE) <= SYSDATE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP_GRP_ID');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         WHEN TOO_MANY_ROWS
         THEN
            NULL;
      END;

      jtf_task_templates_pkg.insert_row (
         x_rowid => l_rowid,
         x_task_template_id => l_task_id,
         x_task_group_id => p_task_group_id,
         x_duration => l_duration,
         x_duration_uom => l_duration_uom,
         x_planned_effort => l_planned_effort,
         x_planned_effort_uom => l_planned_effort_uom,
         x_private_flag => p_private_flag,
         x_publish_flag => p_publish_flag,
         x_restrict_closure_flag => p_restrict_closure_flag,
         x_multi_booked_flag => p_multi_booked_flag,
         x_milestone_flag => p_milestone_flag,
         x_holiday_flag => p_holiday_flag,
         x_billable_flag => p_billable_flag,
         x_notification_flag => p_notification_flag,
         x_notification_period => p_notification_period,
         x_notification_period_uom => p_notification_period_uom,
         x_recurrence_rule_id => NULL,
         x_alarm_start => p_alarm_start,
         x_alarm_start_uom => p_alarm_start_uom,
         x_alarm_on => p_alarm_on,
         x_alarm_count => p_alarm_count,
         x_alarm_interval => p_alarm_interval,
         x_alarm_interval_uom => p_alarm_interval_uom,
         x_deleted_flag => jtf_task_utl.g_no,
            x_attribute1 => p_attribute1 ,
            x_attribute2 => p_attribute2 ,
            x_attribute3 => p_attribute3 ,
            x_attribute4 => p_attribute4 ,
            x_attribute5 => p_attribute5 ,
            x_attribute6 => p_attribute6 ,
            x_attribute7 => p_attribute7 ,
            x_attribute8 => p_attribute8 ,
            x_attribute9 => p_attribute9 ,
            x_attribute10 => p_attribute10 ,
            x_attribute11 => p_attribute11 ,
            x_attribute12 => p_attribute12 ,
            x_attribute13 => p_attribute13 ,
            x_attribute14 => p_attribute14 ,
            x_attribute15 => p_attribute15,
            x_attribute_category => p_attribute_category ,
         x_task_number => l_task_number,
         x_task_type_id => l_task_type_id,
         x_task_status_id => l_task_status_id,
         x_task_priority_id => l_task_priority_id,
         x_task_name => p_task_name,
         x_description => p_description,
         x_task_confirmation_status => l_task_confirmation_status,
         x_creation_date => SYSDATE,
         x_created_by => jtf_task_utl.created_by,
         x_last_update_date => SYSDATE,
         x_last_updated_by => jtf_task_utl.updated_by,
         x_last_update_login => jtf_task_utl.login_id

      );
      OPEN c_jtf_tasks (l_rowid);
      FETCH c_jtf_tasks INTO x;

      IF c_jtf_tasks%NOTFOUND
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_ERROR_CREATION_TEMP');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      ELSE
         x_task_id := l_task_id;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_task_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_task_pvt;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

    PROCEDURE update_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number     IN OUT NOCOPY   NUMBER,
      p_task_id                   IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_name                 IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_description               IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_type_id              IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_status_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_priority_id          IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_duration                  IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_duration_uom              IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_planned_effort            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_planned_effort_uom        IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_private_flag              IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_publish_flag              IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_restrict_closure_flag     IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_multi_booked_flag         IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_milestone_flag            IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_holiday_flag              IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_billable_flag             IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_notification_flag         IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_notification_period       IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_notification_period_uom   IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_alarm_start               IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_alarm_start_uom           IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_alarm_on                  IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_alarm_count               IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_alarm_fired_count         IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_alarm_interval            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_alarm_interval_uom        IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
        p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   )
   IS
     l_api_version	 CONSTANT NUMBER := 1.0;
      l_api_name	 CONSTANT VARCHAR2(30) := 'UPDATE_TASK';
   BEGIN
      SAVEPOINT update_task_pvt1;
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

      jtf_task_templates_pvt.update_task (
	    p_api_version		=> p_api_version,
	    p_init_msg_list		=>  p_init_msg_list,
	    p_commit			=>  p_commit,
	    p_object_version_number	=> p_object_version_number,
	    p_task_id			=> p_task_id,
	    p_task_name 		=> p_task_name,
        p_description		=> p_description,
	    p_task_type_id		=> p_task_type_id,
        p_task_status_id		=> p_task_status_id,
	    p_task_priority_id		=> p_task_priority_id,
        p_duration			=> p_duration,
	    p_duration_uom		=> p_duration_uom,
	    p_planned_effort		=> p_planned_effort,
	    p_planned_effort_uom	=> p_planned_effort_uom,
        p_private_flag		=> p_private_flag,
	    p_publish_flag		=> p_publish_flag,
	    p_restrict_closure_flag	=> p_restrict_closure_flag,
        p_multi_booked_flag 	=> p_multi_booked_flag,
	    p_milestone_flag		=> p_milestone_flag,
	    p_holiday_flag		=> p_holiday_flag,
	    p_billable_flag		=> p_billable_flag,
	    p_notification_flag 	=> p_notification_flag,
	    p_notification_period	=> p_notification_period,
	    p_notification_period_uom	=> p_notification_period_uom,
	    p_alarm_start		=> p_alarm_start,
	    p_alarm_start_uom		=> p_alarm_start_uom,
	    p_alarm_on			=> p_alarm_on,
	    p_alarm_count		=> p_alarm_count,
        p_alarm_fired_count 	=> p_alarm_fired_count,
	    p_alarm_interval		=> p_alarm_interval,
	    p_alarm_interval_uom	=> p_alarm_interval_uom,
        x_return_status		=> x_return_status,
	    x_msg_count 		=> x_msg_count,
	    x_msg_data			=> x_msg_data,
	    p_attribute1		=> p_attribute1,
	    p_attribute2		=> p_attribute2,
	    p_attribute3		=> p_attribute3,
	    p_attribute4		=> p_attribute4,
	    p_attribute5		=> p_attribute5,
	    p_attribute6		=> p_attribute6,
	    p_attribute7		=> p_attribute7,
	    p_attribute8		=> p_attribute8,
	    p_attribute9		=> p_attribute9,
	    p_attribute10		=> p_attribute10,
	    p_attribute11		=> p_attribute11,
	    p_attribute12		=> p_attribute12,
	    p_attribute13		=> p_attribute13,
	    p_attribute14		=> p_attribute14,
	    p_attribute15		=> p_attribute15,
	    p_attribute_category	=> p_attribute_category,
        p_task_confirmation_status => 'N'
      );

     IF NOT (x_return_status = fnd_api.g_ret_sts_success)
     THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF fnd_api.to_boolean (p_commit)
     THEN
     COMMIT WORK;
     END IF;

     fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_task_pvt1;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_task_pvt1;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE update_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number     IN OUT NOCOPY   NUMBER,
      p_task_id                   IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_name                 IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_description               IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_type_id              IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_status_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_priority_id          IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_duration                  IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_duration_uom              IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_planned_effort            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_planned_effort_uom        IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_private_flag              IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_publish_flag              IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_restrict_closure_flag     IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_multi_booked_flag         IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_milestone_flag            IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_holiday_flag              IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_billable_flag             IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_notification_flag         IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_notification_period       IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_notification_period_uom   IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_alarm_start               IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_alarm_start_uom           IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_alarm_on                  IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_alarm_count               IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_alarm_fired_count         IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_alarm_interval            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_alarm_interval_uom        IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
        p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_task_confirmation_status IN      VARCHAR2
   )
   IS
      l_task_id                   jtf_task_templates_b.task_template_id%TYPE;
      l_task_group_id             jtf_task_templates_b.task_group_id%TYPE;
      l_task_number               jtf_task_templates_b.task_number%TYPE;
      l_task_type_id              jtf_task_templates_b.task_type_id%TYPE;
      l_task_status_id            jtf_task_templates_b.task_status_id%TYPE;
      l_task_priority_id          jtf_task_templates_b.task_priority_id%TYPE;
      l_duration                  jtf_task_templates_b.duration%TYPE;
      l_duration_uom              jtf_task_templates_b.duration_uom%TYPE;
      l_planned_effort            jtf_task_templates_b.planned_effort%TYPE;
      l_planned_effort_uom        jtf_task_templates_b.planned_effort_uom%TYPE;
      l_private_flag              jtf_task_templates_b.private_flag%TYPE;
      l_publish_flag              jtf_task_templates_b.publish_flag%TYPE;
      l_restrict_closure_flag     jtf_task_templates_b.restrict_closure_flag%TYPE;
      l_multi_booked_flag         jtf_task_templates_b.multi_booked_flag%TYPE;
      l_milestone_flag            jtf_task_templates_b.milestone_flag%TYPE;
      l_holiday_flag              jtf_task_templates_b.holiday_flag%TYPE;
      l_billable_flag             jtf_task_templates_b.billable_flag%TYPE;
      l_notification_flag         jtf_task_templates_b.notification_flag%TYPE;
      l_notification_period       jtf_task_templates_b.notification_period%TYPE;
      l_notification_period_uom   jtf_task_templates_b.notification_period_uom%TYPE;
      l_alarm_start               jtf_task_templates_b.alarm_start%TYPE;
      l_alarm_start_uom           jtf_task_templates_b.alarm_start_uom%TYPE;
      l_alarm_on                  jtf_task_templates_b.alarm_on%TYPE;
      l_alarm_count               jtf_task_templates_b.alarm_count%TYPE;
      l_alarm_interval            jtf_task_templates_b.alarm_interval%TYPE;
      l_alarm_interval_uom        jtf_task_templates_b.alarm_interval_uom%TYPE;
      l_task_name                 jtf_task_templates_tl.task_name%TYPE;
      l_description               jtf_task_templates_tl.description%TYPE;
      l_task_confirmation_status  jtf_task_templates_b.task_confirmation_status%TYPE;

      CURSOR c_task
      IS
         SELECT task_number,
                recurrence_rule_id,
                task_group_id,
                DECODE (
                   p_task_name,
                   fnd_api.g_miss_char, task_name,
                   p_task_name
                ) task_name,
                DECODE (
                   p_task_type_id,
                   fnd_api.g_miss_num, task_type_id,
                   p_task_type_id
                ) task_type_id,
                DECODE (
                   p_description,
                   fnd_api.g_miss_char, description,
                   p_description
                ) description,
                DECODE (
                   p_task_status_id,
                   fnd_api.g_miss_num, task_status_id,
                   p_task_status_id
                ) task_status_id,
                DECODE (
                   p_task_priority_id,
                   fnd_api.g_miss_num, task_priority_id,
                   p_task_priority_id
                ) task_priority_id,
                DECODE (
                   p_duration,
                   fnd_api.g_miss_num,
                   duration,
                   p_duration
                ) duration,
                DECODE (
                   p_duration_uom,
                   fnd_api.g_miss_char,
                   duration_uom,
                   p_duration_uom
                ) duration_uom,
                DECODE (
                   p_planned_effort,
                   fnd_api.g_miss_num,
                   planned_effort,
                   p_planned_effort
                ) planned_effort,
                DECODE (
                   p_planned_effort_uom,
                   fnd_api.g_miss_char,
                   planned_effort_uom,
                   p_planned_effort_uom
                ) planned_effort_uom,
                DECODE (
                   p_private_flag,
                   fnd_api.g_miss_char,
                   private_flag,
                   p_private_flag
                ) private_flag,
                DECODE (
                   p_publish_flag,
                   fnd_api.g_miss_char,
                   publish_flag,
                   p_publish_flag
                ) publish_flag,
                DECODE (
                   p_restrict_closure_flag,
                   fnd_api.g_miss_char,
                   restrict_closure_flag,
                   p_restrict_closure_flag
                ) restrict_closure_flag,
                DECODE (
                   p_multi_booked_flag,
                   fnd_api.g_miss_char,
                   multi_booked_flag,
                   p_multi_booked_flag
                ) multi_booked_flag,
                DECODE (
                   p_milestone_flag,
                   fnd_api.g_miss_char,
                   milestone_flag,
                   p_milestone_flag
                ) milestone_flag,
                DECODE (
                   p_holiday_flag,
                   fnd_api.g_miss_char,
                   holiday_flag,
                   p_holiday_flag
                ) holiday_flag,
                DECODE (
                   p_billable_flag,
                   fnd_api.g_miss_char,
                   billable_flag,
                   p_billable_flag
                ) billable_flag,
                DECODE (
                   p_notification_flag,
                   fnd_api.g_miss_char,
                   notification_flag,
                   p_notification_flag
                ) notification_flag,
                DECODE (
                   p_notification_period,
                   fnd_api.g_miss_num,
                   notification_period,
                   p_notification_period
                ) notification_period,
                DECODE (
                   p_notification_period_uom,
                   fnd_api.g_miss_char,
                   notification_period_uom,
                   p_notification_period_uom
                ) notification_period_uom,
                DECODE (
                   p_alarm_start,
                   fnd_api.g_miss_num,
                   alarm_start,
                   p_alarm_start
                ) alarm_start,
                DECODE (
                   p_alarm_start_uom,
                   fnd_api.g_miss_char,
                   alarm_start_uom,
                   p_alarm_start_uom
                ) alarm_start_uom,
                DECODE (
                   p_alarm_on,
                   fnd_api.g_miss_char,
                   alarm_on,
                   p_alarm_on
                ) alarm_on,
                DECODE (
                   p_alarm_count,
                   fnd_api.g_miss_num,
                   alarm_count,
                   p_alarm_count
                ) alarm_count,
                DECODE (
                   p_alarm_interval,
                   fnd_api.g_miss_num,
                   alarm_interval,
                   p_alarm_interval
                ) alarm_interval,
                DECODE (
                   p_alarm_interval_uom,
                   fnd_api.g_miss_char,
                   alarm_interval_uom,
                   p_alarm_interval_uom
                ) alarm_interval_uom,
decode( p_attribute1 , fnd_api.g_miss_char , attribute1 , p_attribute1 )  attribute1  ,
decode( p_attribute2 , fnd_api.g_miss_char , attribute2 , p_attribute2 )  attribute2  ,
decode( p_attribute3 , fnd_api.g_miss_char , attribute3 , p_attribute3 )  attribute3  ,
decode( p_attribute4 , fnd_api.g_miss_char , attribute4 , p_attribute4 )  attribute4  ,
decode( p_attribute5 , fnd_api.g_miss_char , attribute5 , p_attribute5 )  attribute5  ,
decode( p_attribute6 , fnd_api.g_miss_char , attribute6 , p_attribute6 )  attribute6  ,
decode( p_attribute7 , fnd_api.g_miss_char , attribute7 , p_attribute7 )  attribute7  ,
decode( p_attribute8 , fnd_api.g_miss_char , attribute8 , p_attribute8 )  attribute8  ,
decode( p_attribute9 , fnd_api.g_miss_char , attribute9 , p_attribute9 )  attribute9  ,
decode( p_attribute10 , fnd_api.g_miss_char , attribute10 , p_attribute10 )  attribute10  ,
decode( p_attribute11 , fnd_api.g_miss_char , attribute11 , p_attribute11 )  attribute11  ,
decode( p_attribute12 , fnd_api.g_miss_char , attribute12 , p_attribute12 )  attribute12  ,
decode( p_attribute13 , fnd_api.g_miss_char , attribute13 , p_attribute13 )  attribute13  ,
decode( p_attribute14 , fnd_api.g_miss_char , attribute14 , p_attribute14 )  attribute14  ,
decode( p_attribute15 , fnd_api.g_miss_char , attribute15 , p_attribute15 )  attribute15 ,
decode( p_attribute_category,fnd_api.g_miss_char,attribute_category,p_attribute_category) attribute_category,
decode( p_task_confirmation_status,jtf_task_utl.g_miss_char,task_confirmation_status,p_task_confirmation_status)
      task_confirmation_status
           FROM jtf_task_templates_vl
          WHERE task_template_id =
                   p_task_id;

      tasks                       c_task%ROWTYPE;
   BEGIN
      OPEN c_task;
      FETCH c_task INTO tasks;

      IF c_task%NOTFOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP');
         fnd_message.set_token ('JTF_TASK_INVALID_TEMP', p_task_id);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_task_id := p_task_id;
      l_task_name := tasks.task_name;
      l_task_number := tasks.task_number;
      l_task_type_id := tasks.task_type_id;
      l_description := tasks.description;
      l_task_status_id := tasks.task_status_id;
      l_task_priority_id := tasks.task_priority_id;
      l_duration := tasks.duration;
      l_duration_uom := tasks.duration_uom;
      l_private_flag := tasks.private_flag;
      l_publish_flag := tasks.publish_flag;
      l_planned_effort := tasks.planned_effort;
      l_planned_effort_uom := tasks.planned_effort_uom;
      l_restrict_closure_flag := tasks.restrict_closure_flag;
      l_multi_booked_flag := tasks.multi_booked_flag;
      l_milestone_flag := tasks.milestone_flag;
      l_holiday_flag := tasks.holiday_flag;
      l_billable_flag := tasks.billable_flag;
      l_notification_flag := tasks.notification_flag;
      l_notification_period := tasks.notification_period;
      l_notification_period_uom := tasks.notification_period_uom;
      l_alarm_start := tasks.alarm_start;
      l_alarm_start_uom := tasks.alarm_start_uom;
      l_alarm_on := tasks.alarm_on;
      l_alarm_count := tasks.alarm_count;
      l_alarm_interval := tasks.alarm_interval;
      l_alarm_interval_uom := tasks.alarm_interval_uom;
      l_task_confirmation_status := tasks.task_confirmation_status;

      jtf_task_templates_pub.lock_task
      ( P_API_VERSION                 =>	1.0 ,
       P_INIT_MSG_LIST                =>	fnd_api.g_false ,
       P_COMMIT                       =>	fnd_api.g_false ,
       P_TASK_ID                      =>	l_task_id ,
       P_OBJECT_VERSION_NUMBER        =>	p_object_version_number,
       X_RETURN_STATUS                =>	x_return_status ,
       X_MSG_DATA                     =>	x_msg_data ,
       X_MSG_COUNT                    =>	x_msg_count ) ;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_templates_pkg.update_row (
         x_task_template_id => l_task_id,
         x_object_version_number => p_object_version_number + 1,
            x_attribute1 => tasks.attribute1 ,
            x_attribute2 => tasks.attribute2 ,
            x_attribute3 => tasks.attribute3 ,
            x_attribute4 => tasks.attribute4 ,
            x_attribute5 => tasks.attribute5 ,
            x_attribute6 => tasks.attribute6 ,
            x_attribute7 => tasks.attribute7 ,
            x_attribute8 => tasks.attribute8 ,
            x_attribute9 => tasks.attribute9 ,
            x_attribute10 => tasks.attribute10 ,
            x_attribute11 => tasks.attribute11 ,
            x_attribute12 => tasks.attribute12 ,
            x_attribute13 => tasks.attribute13 ,
            x_attribute14 => tasks.attribute14 ,
            x_attribute15 => tasks.attribute15 ,
            x_attribute_category => tasks.attribute_category ,
         x_task_number => l_task_number,
         x_task_group_id => tasks.task_group_id,
         x_task_type_id => l_task_type_id,
         x_task_status_id => l_task_status_id,
         x_task_priority_id => l_task_priority_id,
         x_duration => l_duration,
         x_duration_uom => l_duration_uom,
         x_planned_effort => l_planned_effort,
         x_planned_effort_uom => l_planned_effort_uom,
         x_private_flag => l_private_flag,
         x_publish_flag => l_publish_flag,
         x_restrict_closure_flag => l_restrict_closure_flag,
         x_multi_booked_flag => l_multi_booked_flag,
         x_milestone_flag => l_milestone_flag,
         x_holiday_flag => l_holiday_flag,
         x_billable_flag => l_billable_flag,
         x_notification_flag => l_notification_flag,
         x_notification_period => l_notification_period,
         x_notification_period_uom => l_notification_period_uom,
         x_recurrence_rule_id => tasks.recurrence_rule_id,
         x_alarm_start => l_alarm_start,
         x_alarm_start_uom => l_alarm_start_uom,
         x_alarm_on => l_alarm_on,
         x_alarm_count => l_alarm_count,
         x_alarm_interval => l_alarm_interval,
         x_alarm_interval_uom => l_alarm_interval_uom,
         x_deleted_flag => 'N',
         x_task_name => l_task_name,
         x_description => l_description,
         x_task_confirmation_status => l_task_confirmation_status,
         x_last_update_date => SYSDATE,
         x_last_updated_by => jtf_task_utl.updated_by,
         x_last_update_login => jtf_task_utl.login_id
      );

      p_object_version_number := p_object_version_number + 1;

   END;

   PROCEDURE delete_task (
      p_api_version     IN       NUMBER,
      p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number IN NUMBER,
      p_task_id         IN       NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      l_task_id   jtf_task_templates_b.task_template_id%TYPE := p_task_id;

      CURSOR c_dependencies
      IS
         SELECT dependency_id, object_version_number
           FROM jtf_task_depends
          WHERE (  task_id = l_task_id
                OR dependent_on_task_id = l_task_id)
            AND (template_flag = jtf_task_utl.g_yes);
   BEGIN
      SAVEPOINT delete_task_pvt;
      x_return_status := fnd_api.g_ret_sts_success;

            ---------------------------
      ---- delete dependencies
            ---------------------------
      FOR a IN c_dependencies
      LOOP
         jtf_task_dependency_pub.delete_task_dependency (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => a.object_version_number,
            p_dependency_id => a.dependency_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
         );

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END LOOP;

      jtf_task_templates_pub.lock_task
      ( P_API_VERSION                 =>	1.0 ,
       P_INIT_MSG_LIST                =>	fnd_api.g_false ,
       P_COMMIT                       =>	fnd_api.g_false ,
       P_TASK_ID                      =>	l_task_id ,
       P_OBJECT_VERSION_NUMBER        =>	p_object_version_number,
       X_RETURN_STATUS                =>	x_return_status ,
       X_MSG_DATA                     =>	x_msg_data ,
       X_MSG_COUNT                    =>	x_msg_count ) ;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      UPDATE jtf_task_templates_b
         SET deleted_flag = 'Y'
       WHERE task_template_id = l_task_id;

      IF SQL%NOTFOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_ERROR_DELETING_TEMP');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_task_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_task_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;
END;   -- CREATE OR REPLACE PACKAGE spec

/
