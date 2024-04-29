--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_APPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_APPT_PVT" AS
/* $Header: cacvwsab.pls 120.1 2005/08/18 05:43:31 amigupta noship $ */

FUNCTION is_valid_alarm(p_alarm_start IN NUMBER)
  RETURN BOOLEAN
  IS
  BEGIN
    IF p_alarm_start <> 0 AND p_alarm_start <> 5 AND p_alarm_start <> 10
      AND p_alarm_start <> 15  AND p_alarm_start <> 30
      AND p_alarm_start <> 60 AND p_alarm_start <> 120 AND p_alarm_start <> 1440
      AND p_alarm_start <> 2880 AND p_alarm_start <> 4320 AND p_alarm_start <> 10080
     THEN
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END;

PROCEDURE get_alarm_start (p_task_id IN NUMBER,
                            x_alarm_start OUT NOCOPY NUMBER,
                            x_planned_start_date OUT NOCOPY DATE)
  IS
    CURSOR c_alarm IS
   select alarm_start, planned_start_date
     from jtf_tasks_b t
   where t.task_id = p_task_id;

   l_alarm c_alarm%ROWTYPE;
   BEGIN
     OPEN c_alarm;
     FETCH c_alarm INTO l_alarm;
     IF c_alarm%NOTFOUND THEN
       CLOSE c_alarm;
       fnd_message.set_name ('JTF', 'JTF_INVALID_TASK_ID');
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_unexpected_error;
     ELSE
      CLOSE c_alarm;
      x_alarm_start := l_alarm.alarm_start;
      x_planned_start_date := l_alarm.planned_start_date;

    END IF;
  END;

 PROCEDURE create_external_appointment (
        p_task_name               IN       VARCHAR2,
        p_task_type_id            IN       NUMBER,
        p_description             IN       VARCHAR2,
        p_task_priority_id        IN       NUMBER,
        p_owner_type_code         IN       VARCHAR2,
        p_owner_id                IN       NUMBER,
        p_planned_start_date      IN       DATE,
        p_planned_end_date        IN       DATE,
        p_timezone_id             IN       NUMBER,
        p_private_flag            IN       VARCHAR2,
        p_alarm_start             IN       NUMBER,
        p_alarm_on                IN       VARCHAR2,
        p_category_id             IN       NUMBER,
	p_free_busy_type          IN       VARCHAR2,
	p_source_object_type_code IN       VARCHAR2,
        x_return_status           OUT NOCOPY     VARCHAR2,
        x_task_id                 OUT NOCOPY     NUMBER
   )IS
    l_msg_count   NUMBER;
    l_msg_data   VARCHAR2(2000);
   BEGIN

   fnd_msg_pub.initialize;
   jtf_tasks_pvt.create_task(
       p_api_version             => 1.0,
       p_task_name               => p_task_name,
       p_task_type_id            => p_task_type_id,
       p_task_status_id          => 3, -- Accepted
       p_description             => p_description,
       p_task_priority_id        => p_task_priority_id ,
       p_owner_type_code         => p_owner_type_code,
       p_owner_id                => p_owner_id,
       p_planned_start_date      => p_planned_start_date ,
       p_planned_end_date        => p_planned_end_date,
       p_timezone_id             => p_timezone_id,
       p_source_object_type_code => p_source_object_type_code,
       p_private_flag            => p_private_flag,
       p_workflow_process_id     => 0,
       p_alarm_start             => p_alarm_start,
       p_alarm_on                => p_alarm_on,
       p_alarm_interval_uom      => 'min',
       x_return_status           => x_return_status,
       x_msg_count               => l_msg_count,
       x_msg_data                => l_msg_data,
       x_task_id                 => x_task_id,
       p_date_selected           => 'P',
       p_category_id             => p_category_id,
       p_show_on_calendar        => 'Y',
       p_owner_status_id         => 3,--Accepted
       p_enable_workflow         => 'N',
       p_abort_workflow          => 'N',
       p_entity                  => 'APPOINTMENT',
       p_free_busy_type          => p_free_busy_type
        ) ;

    IF x_return_status = fnd_api.g_ret_sts_success AND p_alarm_start > 0
       AND is_valid_alarm(p_alarm_start) THEN
           jtf_cal_wf_pvt.startreminders(
            p_api_version   => 1.0,
            p_commit        => 'T',
            x_return_status => x_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data,
            p_invitor       => p_owner_id,
            p_taskid        => x_task_id,
            p_reminddate    => p_planned_start_date - p_alarm_start/1440
          );
     END IF;
 END;
PROCEDURE update_external_appointment (
        p_object_version_number   IN   OUT NOCOPY NUMBER ,
        p_task_id                 IN       NUMBER,
        p_task_name               IN       VARCHAR2,
        p_task_type_id            IN       NUMBER,
        p_description             IN       VARCHAR2,
        p_task_priority_id        IN       NUMBER,
        p_planned_start_date      IN       DATE,
        p_planned_end_date        IN       DATE,
        p_timezone_id             IN       NUMBER,
        p_private_flag            IN       VARCHAR2,
        p_alarm_start             IN       NUMBER,
        p_alarm_on                IN       VARCHAR2,
        p_category_id             IN       NUMBER,
        p_free_busy_type          IN       VARCHAR2,
        p_change_mode             IN       VARCHAR2,
        x_return_status           OUT  NOCOPY VARCHAR2

   )
   IS
    l_msg_count   NUMBER;
    l_msg_data   VARCHAR2(2000);
    l_alarm_start NUMBER;
    l_planned_start_date DATE;
    l_remind_date DATE;
   BEGIN
   fnd_msg_pub.initialize;
   get_alarm_start(p_task_id, l_alarm_start, l_planned_start_date);
   jtf_tasks_pvt.update_task(
       p_api_version                   => 1.0,
       p_object_version_number         => p_object_version_number,
       p_task_id                       => p_task_id,
       p_task_name                     => p_task_name,
       p_task_type_id                  => p_task_type_id,
       p_description                   => p_description,
       p_task_priority_id              => p_task_priority_id,
       p_planned_start_date            => p_planned_start_date,
       p_planned_end_date              => p_planned_end_date,
       p_timezone_id                   => p_timezone_id,
       p_private_flag                  => p_private_flag,
       p_alarm_start                   => p_alarm_start,
       p_alarm_on                      => p_alarm_on,
       p_source_object_type_code       => 'EXTERNAL APPOINTMENT',
       x_return_status                 => x_return_status,
       x_msg_count                     => l_msg_count,
       x_msg_data                      => l_msg_data,
       p_category_id                   => p_category_id ,
       p_enable_workflow               => 'N',
       p_abort_workflow                => 'N',
       p_change_mode                   => p_change_mode,
       p_free_busy_type                => p_free_busy_type
       );
   IF x_return_status = fnd_api.g_ret_sts_success THEN
     IF (l_alarm_start > 0 and (p_alarm_start = 0  OR p_alarm_start IS NULL)) OR
       (NOT is_valid_alarm(p_alarm_start)) THEN
     --kill the old workflow
      jtf_cal_wf_pvt.updatereminders(
            p_api_version   => 1.0,
            p_commit        => 'T',
            x_return_status => x_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data,
            p_taskid        => p_task_id,
            p_reminddate    => NULL
          );
      -- update workflow if start date or remindme option changed
      ELSIF p_alarm_start > 0 AND is_valid_alarm(p_alarm_start) AND
          (p_alarm_start <> l_alarm_start
           OR p_planned_start_date <> l_planned_start_date) THEN
            jtf_cal_wf_pvt.updatereminders(
            p_api_version   => 1.0,
            p_commit        => 'T',
            x_return_status => x_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data,
            p_taskid        => p_task_id,
            p_reminddate    => p_planned_start_date - p_alarm_start/1440
          );
     END IF;
    END IF;
  END;

  PROCEDURE delete_external_appointment (
      p_object_version_number       IN       NUMBER,
      p_task_id                     IN       NUMBER,
      p_delete_future_recurrences   IN       VARCHAR2,
      x_return_status               OUT  NOCOPY  VARCHAR2
   )
   IS
   l_msg_count   NUMBER;
   l_msg_data   VARCHAR2(2000);
   BEGIN
     fnd_msg_pub.initialize;
     jtf_tasks_pvt.delete_task (
      p_api_version               => 1.0,
      p_object_version_number     => p_object_version_number,
      p_task_id                   => p_task_id,
      p_delete_future_recurrences =>  p_delete_future_recurrences,
      x_return_status             => x_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data,
      p_enable_workflow           => 'N',
      p_abort_workflow            => 'N'
   );
  END;

END; -- End of package

/
