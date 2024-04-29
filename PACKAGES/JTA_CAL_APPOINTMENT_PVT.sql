--------------------------------------------------------
--  DDL for Package JTA_CAL_APPOINTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_CAL_APPOINTMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: jtavcas.pls 120.1 2005/07/02 02:24:32 appldev ship $ */


PROCEDURE create_appointment (
        p_task_name               IN       VARCHAR2,
        p_task_type_id            IN       NUMBER,
        p_description             IN       VARCHAR2 DEFAULT NULL,
        p_task_priority_id        IN       NUMBER DEFAULT NULL,
        p_owner_type_code         IN       VARCHAR2 DEFAULT NULL,
        p_owner_id                IN       NUMBER DEFAULT NULL,
        p_planned_start_date      IN       DATE,
        p_planned_end_date        IN       DATE DEFAULT NULL,
        p_timezone_id             IN       NUMBER,
        p_private_flag            IN       VARCHAR2 DEFAULT NULL,
        p_alarm_start             IN       NUMBER DEFAULT NULL,
        p_alarm_on                IN       VARCHAR2 DEFAULT NULL,
        p_category_id             IN       NUMBER DEFAULT NULL,
        x_return_status           OUT NOCOPY     VARCHAR2,
        x_task_id                 OUT NOCOPY     NUMBER
   );


PROCEDURE create_appointment (
        p_task_name               IN       VARCHAR2,
        p_task_type_id            IN       NUMBER,
        p_description             IN       VARCHAR2 DEFAULT NULL,
        p_task_priority_id        IN       NUMBER DEFAULT NULL,
        p_owner_type_code         IN       VARCHAR2 DEFAULT NULL,
        p_owner_id                IN       NUMBER DEFAULT NULL,
        p_planned_start_date      IN       DATE,
        p_planned_end_date        IN       DATE DEFAULT NULL,
        p_timezone_id             IN       NUMBER,
        p_private_flag            IN       VARCHAR2 DEFAULT NULL,
        p_alarm_start             IN       NUMBER DEFAULT NULL,
        p_alarm_on                IN       VARCHAR2 DEFAULT NULL,
        p_category_id             IN       NUMBER DEFAULT NULL,
	p_free_busy_type          IN       VARCHAR2,
        x_return_status           OUT NOCOPY     VARCHAR2,
        x_task_id                 OUT NOCOPY     NUMBER
   );

   PROCEDURE update_appointment (
        p_object_version_number   IN       OUT  NOCOPY NUMBER ,
        p_task_id                 IN       NUMBER,
        p_task_name               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_type_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_description             IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_priority_id        IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_planned_start_date      IN       DATE DEFAULT fnd_api.g_miss_date,
        p_planned_end_date        IN       DATE DEFAULT fnd_api.g_miss_date,
        p_timezone_id             IN       NUMBER   DEFAULT fnd_api.g_miss_num,
        p_private_flag            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_alarm_start             IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_alarm_on                IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_category_id             IN       NUMBER DEFAULT jtf_task_utl.g_miss_number,
	p_change_mode             IN       VARCHAR2,
        x_return_status           OUT NOCOPY    VARCHAR2
  );

PROCEDURE update_appointment (
        p_object_version_number   IN       OUT  NOCOPY NUMBER ,
        p_task_id                 IN       NUMBER,
        p_task_name               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_type_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_description             IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_priority_id        IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_planned_start_date      IN       DATE DEFAULT fnd_api.g_miss_date,
        p_planned_end_date        IN       DATE DEFAULT fnd_api.g_miss_date,
        p_timezone_id             IN       NUMBER   DEFAULT fnd_api.g_miss_num,
        p_private_flag            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_alarm_start             IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_alarm_on                IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_category_id             IN       NUMBER DEFAULT jtf_task_utl.g_miss_number,
        p_free_busy_type          IN       VARCHAR2,
        p_change_mode             IN       VARCHAR2,
        x_return_status           OUT NOCOPY    VARCHAR2

   );
PROCEDURE delete_appointment (
      p_object_version_number       IN       NUMBER,
      p_task_id                     IN       NUMBER,
      p_delete_future_recurrences   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status               OUT NOCOPY     VARCHAR2
   );

END;

 

/
