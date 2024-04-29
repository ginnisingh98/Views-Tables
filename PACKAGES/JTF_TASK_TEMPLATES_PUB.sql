--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMPLATES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkms.pls 120.1 2005/07/02 00:59:35 appldev ship $ */
   TYPE task_details_rec IS RECORD (
      task_id                       NUMBER,
      task_number                   NUMBER,
      task_name                     VARCHAR2(30)
   );

   TYPE task_depends_rec IS RECORD (
      dependent_on_task_id          NUMBER := NULL,
      dependent_on_task_number      NUMBER := NULL,
      dependency_type_code          VARCHAR2(30),
      adjustment_time               NUMBER := NULL,
      adjustment_time_uom           VARCHAR2(3) := NULL,
      validated_flag                VARCHAR2(1) := NULL
   );

   TYPE task_depends_tbl IS TABLE OF task_depends_rec
      INDEX BY BINARY_INTEGER;

   g_miss_task_depends_tbl    task_depends_tbl;

   TYPE task_rsrc_req_rec IS RECORD (
      resource_subtype_id           NUMBER,
      required_units                NUMBER,
      enabled_flag                  VARCHAR2(1) := NULL
   );

   TYPE task_rsrc_req_tbl IS TABLE OF task_rsrc_req_rec
      INDEX BY BINARY_INTEGER;

   g_miss_task_rsrc_req_tbl   task_rsrc_req_tbl;

   TYPE task_recur_rec IS RECORD (
      occurs_which                  NUMBER := NULL,
      day_of_week                   NUMBER := NULL,
      date_of_month                 NUMBER := NULL,
      occurs_month                  NUMBER := NULL,
      occurs_uom                    VARCHAR2(3),
      occurs_every                  NUMBER := NULL,
      occurs_number                 NUMBER := NULL,
      start_date_active             DATE := NULL,
      end_date_active               DATE := NULL
   );

   g_miss_task_recur_rec      task_recur_rec;

   type task_template_rec is record
   (
 ALARM_ON                                 VARCHAR2(1) ,
 ALARM_COUNT                              NUMBER,
 ALARM_INTERVAL                           NUMBER,
 ALARM_INTERVAL_UOM                       VARCHAR2(3) ,
 DELETED_FLAG                             VARCHAR2(1) ,
 ATTRIBUTE1                               VARCHAR2(150) ,
 ATTRIBUTE2                               VARCHAR2(150) ,
 ATTRIBUTE3                               VARCHAR2(150) ,
 ATTRIBUTE4                               VARCHAR2(150) ,
 ATTRIBUTE5                               VARCHAR2(150) ,
 ATTRIBUTE6                               VARCHAR2(150) ,
 ATTRIBUTE7                               VARCHAR2(150) ,
 ATTRIBUTE8                               VARCHAR2(150) ,
 ATTRIBUTE9                               VARCHAR2(150) ,
 ATTRIBUTE10                              VARCHAR2(150) ,
 ATTRIBUTE11                              VARCHAR2(150) ,
 ATTRIBUTE12                              VARCHAR2(150) ,
 ATTRIBUTE13                              VARCHAR2(150) ,
 ATTRIBUTE14                              VARCHAR2(150) ,
 ATTRIBUTE15                              VARCHAR2(150) ,
 ATTRIBUTE_CATEGORY                       VARCHAR2(30) ,
 HOLIDAY_FLAG                             VARCHAR2(1) ,
 BILLABLE_FLAG                            VARCHAR2(1) ,
 RECURRENCE_RULE_ID                       NUMBER,
 NOTIFICATION_FLAG                        VARCHAR2(1) ,
 NOTIFICATION_PERIOD                      NUMBER,
 NOTIFICATION_PERIOD_UOM                  VARCHAR2(3) ,
 ALARM_START                              NUMBER,
 ALARM_START_UOM                          VARCHAR2(3) ,
 PRIVATE_FLAG                             VARCHAR2(1) ,
 PUBLISH_FLAG                             VARCHAR2(1) ,
 RESTRICT_CLOSURE_FLAG                    VARCHAR2(1) ,
 MULTI_BOOKED_FLAG                        VARCHAR2(240) ,
 MILESTONE_FLAG                           VARCHAR2(1) ,
 TASK_GROUP_ID                      NUMBER,
 TASK_NUMBER                        VARCHAR2(30) ,
 TASK_TYPE_ID                       NUMBER,
 TASK_STATUS_ID                     NUMBER,
 TASK_PRIORITY_ID                         NUMBER,
 DURATION                                 NUMBER,
 DURATION_UOM                             VARCHAR2(3) ,
 PLANNED_EFFORT                           NUMBER,
 PLANNED_EFFORT_UOM                       VARCHAR2(3) ,
 TASK_TEMPLATE_ID                   NUMBER,
 TASK_NAME                          VARCHAR2(80) ,
 DESCRIPTION                              VARCHAR2(4000) ,
 OBJECT_VERSION_NUMBER              NUMBER,
 TASK_CONFIRMATION_STATUS       	VARCHAR2(1)
  );

   p_task_template_rec      task_template_rec ;

   PROCEDURE create_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id                   IN       NUMBER DEFAULT NULL,
      p_task_group_id             IN       NUMBER DEFAULT NULL,
      p_task_group_name           IN       VARCHAR2 DEFAULT NULL,
      p_task_name                 IN       VARCHAR2,
      p_task_type_name            IN       VARCHAR2 DEFAULT NULL,
      p_task_type_id              IN       NUMBER DEFAULT NULL,
      p_description               IN       VARCHAR2 DEFAULT NULL,
      p_task_status_name          IN       VARCHAR2 DEFAULT NULL,
      p_task_status_id            IN       NUMBER DEFAULT NULL,
      p_task_priority_name        IN       VARCHAR2 DEFAULT NULL,
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
      p_task_depends_tbl          IN       task_depends_tbl
            DEFAULT g_miss_task_depends_tbl,
      p_task_rsrc_req_tbl         IN       task_rsrc_req_tbl
            DEFAULT g_miss_task_rsrc_req_tbl,
      p_task_recur_rec            IN       task_recur_rec
            DEFAULT g_miss_task_recur_rec,
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
   -- Overloaded method for Simplex.
   PROCEDURE create_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id                   IN       NUMBER DEFAULT NULL,
      p_task_group_id             IN       NUMBER DEFAULT NULL,
      p_task_group_name           IN       VARCHAR2 DEFAULT NULL,
      p_task_name                 IN       VARCHAR2,
      p_task_type_name            IN       VARCHAR2 DEFAULT NULL,
      p_task_type_id              IN       NUMBER DEFAULT NULL,
      p_description               IN       VARCHAR2 DEFAULT NULL,
      p_task_status_name          IN       VARCHAR2 DEFAULT NULL,
      p_task_status_id            IN       NUMBER DEFAULT NULL,
      p_task_priority_name        IN       VARCHAR2 DEFAULT NULL,
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
      p_task_depends_tbl          IN       task_depends_tbl
            DEFAULT g_miss_task_depends_tbl,
      p_task_rsrc_req_tbl         IN       task_rsrc_req_tbl
            DEFAULT g_miss_task_rsrc_req_tbl,
      p_task_recur_rec            IN       task_recur_rec
            DEFAULT g_miss_task_recur_rec,
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
        p_task_confirmation_status IN      VARCHAR2
   );

   PROCEDURE lock_task (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id           IN       NUMBER,
      p_object_version_number IN   NUMBER,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER
   ) ;




   PROCEDURE update_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number     IN     OUT NOCOPY NUMBER ,
      p_task_id                   IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_number               IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_group_id             IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_name                 IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_type_name            IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_type_id              IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_description               IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_status_name          IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_status_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_priority_name        IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
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

   -- Overloaded for Simplex.
   PROCEDURE update_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number     IN     OUT NOCOPY NUMBER ,
      p_task_id                   IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_number               IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_group_id             IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_name                 IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_type_name            IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_type_id              IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_description               IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_status_name          IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
      p_task_status_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_task_priority_name        IN       VARCHAR2
            DEFAULT fnd_api.g_miss_char,
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
   );

   PROCEDURE delete_task (
      p_api_version     IN       NUMBER,
      p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN      NUMBER ,
      p_task_id         IN       NUMBER DEFAULT NULL,
      p_task_number     IN       VARCHAR2 DEFAULT NULL,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );
END;

 

/
