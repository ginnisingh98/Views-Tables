--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMPLATES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkms.pls 120.1 2005/07/02 01:45:56 appldev ship $ */
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
   );

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
   );

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
   );

   -- Overloading for Simplex.
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
        p_task_confirmation_status IN	   VARCHAR2
   );

   PROCEDURE delete_task (
      p_api_version     IN       NUMBER,
      p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number IN NUMBER,
      p_task_id         IN       NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );
END;   -- CREATE OR REPLACE PACKAGE spec

 

/
