--------------------------------------------------------
--  DDL for Package Body JTF_TASK_ASSIGNMENT_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_ASSIGNMENT_AUDIT_PKG" AS
  /*$Header: jtftkaub.pls 120.0.12010000.5 2010/03/31 12:02:19 anangupt noship $*/

  /**
   * Procedure to accept call for creation of audit record for change in
   * task assignment. This procedure validates if the update IS actual
   * update or a dummy update by comparing values passed with the values
   * stored for the given assignment.This procedure inturn calls
   * INSERT_ROW() procedure to create row in database.
   */

  PROCEDURE create_task_assignment_audit (
    p_api_version                 IN       NUMBER,
    p_init_msg_list               IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_version_number       IN       NUMBER,
    p_task_id                     IN       NUMBER,
    p_task_assignment_id          IN       NUMBER,
    p_new_resource_type_code      IN       VARCHAR2 DEFAULT NULL,
    p_new_resource_id             IN       NUMBER DEFAULT NULL,
    p_new_assignment_status       IN       NUMBER DEFAULT NULL,
    p_new_actual_effort           IN       NUMBER DEFAULT NULL,
    p_new_actual_effort_uom       IN       VARCHAR2 DEFAULT NULL,
    p_new_res_territory_id        IN       NUMBER DEFAULT NULL,
    p_new_assignee_role           IN       VARCHAR2 DEFAULT NULL,
    p_new_schedule_flag           IN       VARCHAR2 DEFAULT NULL,
    p_new_alarm_type              IN       VARCHAR2 DEFAULT NULL,
    p_new_alarm_contact           IN       VARCHAR2 DEFAULT NULL,
    p_new_update_status_flag      IN       VARCHAR2 DEFAULT NULL,
    p_new_show_on_cal_flag        IN       VARCHAR2 DEFAULT NULL,
    p_new_category_id             IN       NUMBER DEFAULT NULL,
    p_new_free_busy_type          IN       VARCHAR2 DEFAULT NULL,
    p_new_booking_start_date      IN       DATE DEFAULT NULL,
    p_new_booking_end_date        IN       DATE DEFAULT NULL,
    p_new_actual_travel_distance  IN       NUMBER DEFAULT NULL,
    p_new_actual_travel_duration  IN       NUMBER DEFAULT NULL,
    p_new_actual_travel_dur_uom   IN       VARCHAR2 DEFAULT NULL,
    p_new_sched_travel_distance   IN       NUMBER DEFAULT NULL,
    p_new_sched_travel_duration   IN       NUMBER DEFAULT NULL,
    p_new_sched_travel_dur_uom    IN       VARCHAR2 DEFAULT NULL,
    p_new_actual_start_date       IN       DATE DEFAULT NULL,
    p_new_actual_end_date         IN       DATE DEFAULT NULL,
    x_return_status               OUT NOCOPY     VARCHAR2,
    x_msg_count                   OUT NOCOPY     NUMBER,
    x_msg_data                    OUT NOCOPY     VARCHAR2
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)    := 'JTF_TASK_ASSIGNMENT_AUDIT_PKG';
    l_api_version        CONSTANT NUMBER          := 1.0;
    l_init_msg_list               VARCHAR2(10)    := fnd_api.g_false;
    l_commit                      VARCHAR2(10)    := fnd_api.g_false;
    l_old_resource_type_code      VARCHAR2(30);
    l_old_resource_id             NUMBER;
    l_old_assignment_status       NUMBER;
    l_old_actual_effort           NUMBER;
    l_old_actual_effort_uom       VARCHAR2(3);
    l_old_res_territory_id        NUMBER;
    l_old_assignee_role           VARCHAR2(30);
    l_old_schedule_flag           VARCHAR2(1);
    l_old_alarm_type              VARCHAR2(30);
    l_old_alarm_contact           VARCHAR2(200);
    l_old_update_status_flag      VARCHAR2(1);
    l_old_show_on_cal_flag        VARCHAR2(1);
    l_old_category_id             NUMBER;
    l_old_free_busy_type          VARCHAR2(100);
    l_old_booking_start_date      DATE;
    l_old_booking_end_date        DATE;
    l_old_actual_travel_distance  NUMBER;
    l_old_actual_travel_duration  NUMBER;
    l_old_actual_travel_dur_uom   VARCHAR2(3);
    l_old_sched_travel_distance   NUMBER;
    l_old_sched_travel_duration   NUMBER;
    l_old_sched_travel_dur_uom    VARCHAR2(3);
    l_old_actual_start_date       DATE;
    l_old_actual_end_date         DATE;
    l_resource_type_code_changed     VARCHAR2(1) :='N';
    l_resource_id_changed 	     VARCHAR2(1) :='N';
    l_assignment_status_changed      VARCHAR2(1) :='N';
    l_actual_effort_changed 	     VARCHAR2(1) :='N';
    l_actual_effort_uom_changed      VARCHAR2(1) :='N';
    l_res_territory_id_changed 	     VARCHAR2(1) :='N';
    l_assignee_role_changed 	     VARCHAR2(1) :='N';
    l_schedule_flag_changed 	     VARCHAR2(1) :='N';
    l_alarm_type_changed 	     VARCHAR2(1) :='N';
    l_alarm_contact_changed 	     VARCHAR2(1) :='N';
    l_update_status_flag_changed     VARCHAR2(1) :='N';
    l_show_on_cal_flag_changed 	     VARCHAR2(1) :='N';
    l_category_id_changed 	     VARCHAR2(1) :='N';
    l_free_busy_type_changed 	     VARCHAR2(1) :='N';
    l_booking_start_date_changed     VARCHAR2(1) :='N';
    l_booking_end_date_changed 	     VARCHAR2(1) :='N';
    l_actual_travel_dist_changed     VARCHAR2(1) :='N';
    l_actual_travel_dur_changed      VARCHAR2(1) :='N';
    l_actual_travel_uom_changed      VARCHAR2(1) :='N';
    l_sched_travel_dist_changed      VARCHAR2(1) :='N';
    l_sched_travel_dur_changed       VARCHAR2(1) :='N';
    l_sched_travel_uom_changed       VARCHAR2(1) :='N';
    l_actual_start_date_changed      VARCHAR2(1) :='N';
    l_actual_end_date_changed 	     VARCHAR2(1) :='N';
    x                             NUMBER ;
    l_asg_create                  NUMBER;

    CURSOR cur_asg_audit (p_task_assignment_id IN NUMBER)
    IS
       SELECT task_id
            , resource_type_code
            , resource_id
            , assignment_status_id
            , actual_effort
            , actual_effort_uom
            , resource_territory_id
            , assignee_role
            , schedule_flag
            , alarm_type_code
            , alarm_contact
            , update_status_flag
            , show_on_calendar
            , category_id
            , free_busy_type
            , booking_start_date
            , booking_end_date
            , actual_travel_distance
            , actual_travel_duration
            , actual_travel_duration_uom
            , sched_travel_distance
            , sched_travel_duration
            , sched_travel_duration_uom
            , actual_start_date
            , actual_end_date
            , trim(object_version_number) as object_version_number
         FROM jtf_task_all_assignments
        WHERE task_assignment_id = p_task_assignment_id;

    CURSOR c1 (l_asg_audit_id IN NUMBER)
    IS
      SELECT 1
        FROM jtf_task_assignments_audit_b
       WHERE Assignment_audit_id = l_asg_audit_id;

    audit_rec      cur_asg_audit%ROWTYPE;
    l_new_category_id NUMBER := p_new_category_id ;
    l_curr            NUMBER;
  BEGIN
    SAVEPOINT create_asg_audit_pvt;

    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean (p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    OPEN cur_asg_audit (p_task_assignment_id);

    FETCH cur_asg_audit INTO audit_rec;
    IF(cur_asg_audit%notfound) then
      l_old_resource_type_code              := NULL;
      l_old_resource_id                     := NULL;
      l_old_assignment_status               := NULL;
      l_old_actual_effort                   := NULL;
      l_old_actual_effort_uom               := NULL;
      l_old_res_territory_id                := NULL;
      l_old_assignee_role                   := NULL;
      l_old_schedule_flag                   := NULL;
      l_old_alarm_type                      := NULL;
      l_old_alarm_contact                   := NULL;
      l_old_update_status_flag              := NULL;
      l_old_show_on_cal_flag                := NULL;
      l_old_category_id                     := NULL;
      l_old_free_busy_type                  := NULL;
      l_old_booking_start_date              := NULL;
      l_old_booking_end_date                := NULL;
      l_old_actual_travel_distance          := NULL;
      l_old_actual_travel_duration          := NULL;
      l_old_actual_travel_dur_uom           := NULL;
      l_old_sched_travel_distance           := NULL;
      l_old_sched_travel_duration           := NULL;
      l_old_sched_travel_dur_uom            := NULL;
      l_old_actual_start_date               := NULL;
      l_old_actual_end_date                 := NULL;
      l_asg_create                          := 0;
    ELSE
      l_old_resource_type_code              := audit_rec.resource_type_code;
      l_old_resource_id                     := audit_rec.resource_id;
      l_old_assignment_status               := audit_rec.assignment_status_id;
      l_old_actual_effort                   := audit_rec.actual_effort;
      l_old_actual_effort_uom               := audit_rec.actual_effort_uom;
      l_old_res_territory_id                := audit_rec.resource_territory_id;
      l_old_assignee_role                   := audit_rec.assignee_role;
      l_old_schedule_flag                   := audit_rec.schedule_flag;
      l_old_alarm_type                      := audit_rec.alarm_type_code;
      l_old_alarm_contact                   := audit_rec.alarm_contact;
      l_old_update_status_flag              := audit_rec.update_status_flag;
      l_old_show_on_cal_flag                := audit_rec.show_on_calendar;
      l_old_category_id                     := audit_rec.category_id;
      l_old_free_busy_type                  := audit_rec.free_busy_type;
      l_old_booking_start_date              := audit_rec.booking_start_date;
      l_old_booking_end_date                := audit_rec.booking_end_date;
      l_old_actual_travel_distance          := audit_rec.actual_travel_distance;
      l_old_actual_travel_duration          := audit_rec.actual_travel_duration;
      l_old_actual_travel_dur_uom           := audit_rec.actual_travel_duration_UOM;
      l_old_sched_travel_distance           := audit_rec.sched_travel_distance;
      l_old_sched_travel_duration           := audit_rec.sched_travel_duration;
      l_old_sched_travel_dur_uom            := audit_rec.sched_travel_duration_UOM;
      l_old_actual_start_date               := audit_rec.actual_start_date;
      l_old_actual_end_date                 := audit_rec.actual_end_date;
      l_asg_create                          := 1;
    END IF;
    CLOSE cur_asg_audit;

    IF (p_new_category_id = fnd_api.g_miss_num)
    THEN
      l_new_category_id:=NULL;
    END IF;

    IF ( (p_new_resource_type_code IS NULL AND l_old_resource_type_code IS NOT NULL)
          OR (p_new_resource_type_code IS NOT NULL AND l_old_resource_type_code IS NULL)
          OR (p_new_resource_type_code IS NOT NULL AND l_old_resource_type_code IS NOT NULL
              AND p_new_resource_type_code <> l_old_resource_type_code))
    THEN
      l_resource_type_code_changed:='Y';
    END IF;

    IF ( (p_new_resource_id IS NULL AND l_old_resource_id IS NOT NULL)
          OR (p_new_resource_id IS NOT NULL AND l_old_resource_id IS NULL)
          OR (p_new_resource_id IS NOT NULL AND l_old_resource_id IS NOT NULL
              AND p_new_resource_id <> l_old_resource_id))
    THEN
      l_resource_id_changed:='Y';
    END IF;

    IF ( (p_new_assignment_status IS NULL AND l_old_assignment_status IS NOT NULL)
          OR (p_new_assignment_status IS NOT NULL AND l_old_assignment_status IS NULL)
          OR (p_new_assignment_status IS NOT NULL AND l_old_assignment_status IS NOT NULL
              AND p_new_assignment_status <> l_old_assignment_status))
    THEN
      l_assignment_status_changed:='Y';
    END IF;

    IF ( (p_new_actual_effort IS NULL AND l_old_actual_effort IS NOT NULL)
          OR (p_new_actual_effort IS NOT NULL AND l_old_actual_effort IS NULL)
          OR (p_new_actual_effort IS NOT NULL AND l_old_actual_effort IS NOT NULL
              AND p_new_actual_effort <> l_old_actual_effort))
    THEN
      l_actual_effort_changed:='Y';
    END IF;

    IF ( (p_new_actual_effort_uom IS NULL AND l_old_actual_effort_uom IS NOT NULL)
          OR (p_new_actual_effort_uom IS NOT NULL AND l_old_actual_effort_uom IS NULL)
          OR (p_new_actual_effort_uom IS NOT NULL AND l_old_actual_effort_uom IS NOT NULL
              AND p_new_actual_effort_uom <> l_old_actual_effort_uom))
    THEN
      l_actual_effort_uom_changed:='Y';
    END IF;

    IF ( (p_new_res_territory_id IS NULL AND l_old_res_territory_id IS NOT NULL)
          OR (p_new_res_territory_id IS NOT NULL AND l_old_res_territory_id IS NULL)
          OR (p_new_res_territory_id IS NOT NULL AND l_old_res_territory_id IS NOT NULL
              AND p_new_res_territory_id <> l_old_res_territory_id))
    THEN
      l_res_territory_id_changed:='Y';
    END IF;

    IF ( (p_new_assignee_role IS NULL AND l_old_assignee_role IS NOT NULL)
          OR (p_new_assignee_role IS NOT NULL AND l_old_assignee_role IS NULL)
          OR (p_new_assignee_role IS NOT NULL AND l_old_assignee_role IS NOT NULL
              AND p_new_assignee_role <> l_old_assignee_role))
    THEN
      l_assignee_role_changed:='Y';
    END IF;

    IF ( (p_new_schedule_flag IS NULL AND l_old_schedule_flag IS NOT NULL)
          OR (p_new_schedule_flag IS NOT NULL AND l_old_schedule_flag IS NULL)
          OR (p_new_schedule_flag IS NOT NULL AND l_old_schedule_flag IS NOT NULL
              AND p_new_schedule_flag <> l_old_schedule_flag))
    THEN
      l_schedule_flag_changed:='Y';
    END IF;

    IF ( (p_new_alarm_type IS NULL AND l_old_alarm_type IS NOT NULL)
          OR (p_new_alarm_type IS NOT NULL AND l_old_alarm_type IS NULL)
          OR (p_new_alarm_type IS NOT NULL AND l_old_alarm_type IS NOT NULL
              AND p_new_alarm_type <> l_old_alarm_type))
    THEN
      l_alarm_type_changed:='Y';
    END IF;

    IF ( (p_new_alarm_contact IS NULL AND l_old_alarm_contact IS NOT NULL)
          OR (p_new_alarm_contact IS NOT NULL AND l_old_alarm_contact IS NULL)
          OR (p_new_alarm_contact IS NOT NULL AND l_old_alarm_contact IS NOT NULL
              AND p_new_alarm_contact <> l_old_alarm_contact))
    THEN
      l_alarm_contact_changed:='Y';
    END IF;

    IF ( (p_new_update_status_flag IS NULL AND l_old_update_status_flag IS NOT NULL)
          OR (p_new_update_status_flag IS NOT NULL AND l_old_update_status_flag IS NULL)
          OR (p_new_update_status_flag IS NOT NULL AND l_old_update_status_flag IS NOT NULL
              AND p_new_update_status_flag <> l_old_update_status_flag) )
    THEN
      l_update_status_flag_changed:='Y';
    END IF;

    IF ( (p_new_show_on_cal_flag IS NULL AND l_old_show_on_cal_flag IS NOT NULL)
          OR (p_new_show_on_cal_flag IS NOT NULL AND l_old_show_on_cal_flag IS NULL)
          OR (p_new_show_on_cal_flag IS NOT NULL AND l_old_show_on_cal_flag IS NOT NULL
              AND p_new_show_on_cal_flag <> l_old_show_on_cal_flag) )
    THEN
      l_show_on_cal_flag_changed:='Y';
    END IF;

    IF ( (l_new_category_id IS NULL AND l_old_category_id IS NOT NULL)
          OR (l_new_category_id IS NOT NULL AND l_old_category_id IS NULL)
          OR (l_new_category_id IS NOT NULL AND l_old_category_id IS NOT NULL
              AND l_new_category_id <> l_old_category_id) )
    THEN
      l_category_id_changed:='Y';
    END IF;

    IF ( (p_new_free_busy_type IS NULL AND l_old_free_busy_type IS NOT NULL)
          OR (p_new_free_busy_type IS NOT NULL AND l_old_free_busy_type IS NULL)
          OR (p_new_free_busy_type IS NOT NULL AND l_old_free_busy_type IS NOT NULL
              AND p_new_free_busy_type <> l_old_free_busy_type) )
    THEN
      l_free_busy_type_changed:='Y';
    END IF;

    IF ( (p_new_booking_start_date IS NULL AND l_old_booking_start_date IS NOT NULL)
          OR (p_new_booking_start_date IS NOT NULL AND l_old_booking_start_date IS NULL)
          OR (p_new_booking_start_date IS NOT NULL AND l_old_booking_start_date IS NOT NULL
              AND p_new_booking_start_date <> l_old_booking_start_date) )
    THEN
      l_booking_start_date_changed:='Y';
    END IF;

    IF ( (p_new_booking_end_date IS NULL AND l_old_booking_end_date IS NOT NULL)
          OR (p_new_booking_end_date IS NOT NULL AND l_old_booking_end_date IS NULL)
          OR (p_new_booking_end_date IS NOT NULL AND l_old_booking_end_date IS NOT NULL
              AND p_new_booking_end_date <> l_old_booking_end_date) )
    THEN
      l_booking_end_date_changed:='Y';
    END IF;

    IF ( (p_new_actual_travel_distance IS NULL AND l_old_actual_travel_distance IS NOT NULL)
          OR (p_new_actual_travel_distance IS NOT NULL AND l_old_actual_travel_distance IS NULL)
          OR (p_new_actual_travel_distance IS NOT NULL AND l_old_actual_travel_distance IS NOT NULL
              AND p_new_actual_travel_distance <> l_old_actual_travel_distance))
    THEN
      l_actual_travel_dist_changed:='Y';
    END IF;

    IF ( (p_new_actual_travel_duration IS NULL AND l_old_actual_travel_duration IS NOT NULL)
          OR (p_new_actual_travel_duration IS NOT NULL AND l_old_actual_travel_duration IS NULL)
          OR (p_new_actual_travel_duration IS NOT NULL AND l_old_actual_travel_duration IS NOT NULL
              AND p_new_actual_travel_duration <> l_old_actual_travel_duration) )
    THEN
      l_actual_travel_dur_changed:='Y';
    END IF;

    IF ( (p_new_actual_travel_dur_uom IS NULL AND l_old_actual_travel_dur_uom IS NOT NULL)
          OR (p_new_actual_travel_dur_uom IS NOT NULL AND l_old_actual_travel_dur_uom IS NULL)
          OR (p_new_actual_travel_dur_uom IS NOT NULL AND l_old_actual_travel_dur_uom IS NOT NULL
              AND p_new_actual_travel_dur_uom <> l_old_actual_travel_dur_uom) )
    THEN
      l_actual_travel_uom_changed:='Y';
    END IF;

    IF ( (p_new_sched_travel_distance IS NULL AND l_old_sched_travel_distance IS NOT NULL)
          OR (p_new_sched_travel_distance IS NOT NULL AND l_old_sched_travel_distance IS NULL)
          OR (p_new_sched_travel_distance IS NOT NULL AND l_old_sched_travel_distance IS NOT NULL
              AND p_new_sched_travel_distance <> l_old_sched_travel_distance) )
    THEN
      l_sched_travel_dist_changed:='Y';
    END IF;

    IF ( (p_new_sched_travel_duration IS NULL AND l_old_sched_travel_duration IS NOT NULL)
          OR (p_new_sched_travel_duration IS NOT NULL AND l_old_sched_travel_duration IS NULL)
          OR (p_new_sched_travel_duration IS NOT NULL AND l_old_sched_travel_duration IS NOT NULL
              AND p_new_sched_travel_duration <> l_old_sched_travel_duration) )
    THEN
      l_sched_travel_dur_changed:='Y';
    END IF;

    IF ( (p_new_sched_travel_dur_uom IS NULL AND l_old_sched_travel_DUR_UOM IS NOT NULL)
          OR (p_new_sched_travel_dur_uom IS NOT NULL AND l_old_sched_travel_DUR_UOM IS NULL)
          OR (p_new_sched_travel_dur_uom IS NOT NULL AND l_old_sched_travel_DUR_UOM IS NOT NULL
              AND p_new_sched_travel_dur_uom <> l_old_sched_travel_DUR_UOM) )
    THEN
      l_sched_travel_uom_changed:='Y';
    END IF;

    IF ( (p_new_actual_start_date IS NULL AND l_old_actual_start_date IS NOT NULL)
          OR (p_new_actual_start_date IS NOT NULL AND l_old_actual_start_date IS NULL)
          OR (p_new_actual_start_date IS NOT NULL AND l_old_actual_start_date IS NOT NULL
              AND p_new_actual_start_date <> l_old_actual_start_date) )
    THEN
      l_actual_start_date_changed:='Y';
    END IF;

    IF ( (p_new_actual_end_date IS NULL AND l_old_actual_end_date IS NOT NULL)
          OR (p_new_actual_end_date IS NOT NULL AND l_old_actual_end_date IS NULL)
          OR (p_new_actual_end_date IS NOT NULL AND l_old_actual_end_date IS NOT NULL
              AND p_new_actual_end_date <> l_old_actual_end_date) )
    THEN
      l_actual_end_date_changed:='Y';
    END IF;

    IF(l_asg_create='0' OR l_resource_type_code_changed='Y' OR
      l_resource_id_changed='Y' OR
      l_assignment_status_changed='Y' OR
      l_actual_effort_changed='Y' OR
      l_actual_effort_uom_changed='Y' OR
      l_res_territory_id_changed='Y' OR
      l_assignee_role_changed='Y' OR
      l_schedule_flag_changed='Y' OR
      l_alarm_type_changed='Y' OR
      l_alarm_contact_changed='Y' OR
      l_update_status_flag_changed='Y' OR
      l_show_on_cal_flag_changed='Y' OR
      l_category_id_changed='Y' OR
      l_free_busy_type_changed='Y' OR
      l_booking_start_date_changed='Y' OR
      l_booking_end_date_changed='Y' OR
      l_actual_travel_dist_changed='Y' OR
      l_actual_travel_dur_changed='Y' OR
      l_actual_travel_uom_changed='Y' OR
      l_sched_travel_dist_changed='Y' OR
      l_sched_travel_dur_changed='Y' OR
      l_sched_travel_uom_changed='Y' OR
      l_actual_start_date_changed='Y' OR
      l_actual_end_date_changed='Y' )
    THEN

      SELECT jtf_task_assignments_audit_s.NEXTVAL INTO l_curr FROM dual;
      INSERT_ROW(
        X_ASSIGNMENT_AUDIT_ID          =>   l_curr,
        X_ASSIGNMENT_ID                =>   p_task_assignment_id,
        X_TASK_ID                      =>   p_task_id,
        X_CREATION_DATE                =>   SYSDATE,
        X_CREATED_BY                   =>   jtf_task_utl.created_by,
        X_LAST_UPDATE_DATE             =>   SYSDATE,
        X_LAST_UPDATED_BY              =>   jtf_task_utl.updated_by,
        X_LAST_UPDATE_LOGIN            =>   jtf_task_utl.login_id,
        X_OLD_RESOURCE_TYPE_CODE       =>   l_old_resource_type_code,
        X_NEW_RESOURCE_TYPE_CODE       =>   p_new_resource_type_code,
        X_OLD_RESOURCE_ID              =>   l_old_resource_id,
        X_NEW_RESOURCE_ID              =>   p_new_resource_id,
        X_OLD_ASSIGNMENT_STATUS_ID     =>   l_old_assignment_status,
        X_NEW_ASSIGNMENT_STATUS_ID     =>   p_new_assignment_status,
        X_OLD_ACTUAL_EFFORT            =>   l_old_actual_effort,
        X_NEW_ACTUAL_EFFORT            =>   p_new_actual_effort,
        X_OLD_ACTUAL_EFFORT_UOM        =>   l_old_actual_effort_uom,
        X_NEW_ACTUAL_EFFORT_UOM        =>   p_new_actual_effort_uom,
        X_OLD_RES_TERRITORY_ID         =>   l_old_res_territory_id,
        X_NEW_RES_TERRITORY_ID         =>   p_new_res_territory_id,
        X_OLD_ASSIGNEE_ROLE            =>   l_old_assignee_role,
        X_NEW_ASSIGNEE_ROLE            =>   p_new_assignee_role,
        X_OLD_ALARM_TYPE               =>   l_old_alarm_type,
        X_NEW_ALARM_TYPE               =>   p_new_alarm_type,
        X_OLD_ALARM_CONTACT            =>   l_old_alarm_contact,
        X_NEW_ALARM_CONTACT            =>   p_new_alarm_contact,
        X_OLD_CATEGORY_ID              =>   l_old_category_id,
        X_NEW_CATEGORY_ID              =>   l_new_category_id,
        X_OLD_BOOKING_START_DATE       =>   l_old_booking_start_date,
        X_NEW_BOOKING_START_DATE       =>   p_new_booking_start_date,
        X_OLD_BOOKING_END_DATE         =>   l_old_booking_end_date,
        X_NEW_BOOKING_END_DATE         =>   p_new_booking_end_date,
        X_OLD_ACTUAL_TRAVEL_DISTANCE   =>   l_old_actual_travel_distance,
        X_NEW_ACTUAL_TRAVEL_DISTANCE   =>   p_new_actual_travel_distance,
        X_OLD_ACTUAL_TRAVEL_DURATION   =>   l_old_actual_travel_duration,
        X_NEW_ACTUAL_TRAVEL_DURATION   =>   p_new_actual_travel_duration,
        X_OLD_ACTUAL_TRAVEL_DUR_UOM    =>   l_old_actual_travel_dur_uom,
        X_NEW_ACTUAL_TRAVEL_DUR_UOM    =>   p_new_actual_travel_dur_uom,
        X_OLD_SCHED_TRAVEL_DISTANCE    =>   l_old_sched_travel_distance,
        X_NEW_SCHED_TRAVEL_DISTANCE    =>   p_new_sched_travel_distance,
        X_OLD_SCHED_TRAVEL_DURATION    =>   l_old_sched_travel_duration,
        X_NEW_SCHED_TRAVEL_DURATION    =>   p_new_sched_travel_duration,
        X_OLD_SCHED_TRAVEL_DUR_UOM     =>   l_old_sched_travel_dur_uom,
        X_NEW_SCHED_TRAVEL_DUR_UOM     =>   p_new_sched_travel_dur_uom,
        X_OLD_ACTUAL_START_DATE        =>   l_old_actual_start_date,
        X_NEW_ACTUAL_START_DATE        =>   p_new_actual_start_date,
        X_OLD_ACTUAL_END_DATE          =>   l_old_actual_end_date,
        X_NEW_ACTUAL_END_DATE          =>   p_new_actual_end_date,
        X_FREE_BUSY_TYPE_CHANGED       =>   l_free_busy_type_changed,
        X_UPDATE_STATUS_FLAG_CHANGED   =>   l_update_status_flag_changed,
        X_SHOW_ON_CALENDAR_CHANGED     =>   l_show_on_cal_flag_changed,
        X_SCHEDULED_FLAG_CHANGED       =>   l_schedule_flag_changed
        );

    END IF;
    SELECT jtf_task_assignments_audit_s.CURRVAL INTO l_curr FROM dual;
    OPEN c1 (l_curr);
    FETCH c1 INTO x;

    IF c1%NOTFOUND
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
        NULL;
    END IF;


    IF fnd_api.to_boolean (p_commit)
    THEN
        COMMIT WORK;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_task_assignment_audit;



  PROCEDURE INSERT_ROW (
    X_ASSIGNMENT_AUDIT_ID IN NUMBER,
    X_ASSIGNMENT_ID IN NUMBER,
    X_TASK_ID IN NUMBER,
    X_CREATION_DATE in DATE,
    X_CREATED_BY in NUMBER,
    X_LAST_UPDATE_DATE in DATE,
    X_LAST_UPDATED_BY in NUMBER,
    X_LAST_UPDATE_LOGIN in NUMBER,
    X_OLD_RESOURCE_TYPE_CODE IN VARCHAR2,
    X_NEW_RESOURCE_TYPE_CODE IN VARCHAR2,
    X_OLD_RESOURCE_ID IN NUMBER,
    X_NEW_RESOURCE_ID IN NUMBER,
    X_OLD_ASSIGNMENT_STATUS_ID IN NUMBER,
    X_NEW_ASSIGNMENT_STATUS_ID IN NUMBER,
    X_OLD_ACTUAL_EFFORT IN NUMBER,
    X_NEW_ACTUAL_EFFORT IN NUMBER,
    X_OLD_ACTUAL_EFFORT_UOM IN VARCHAR2,
    X_NEW_ACTUAL_EFFORT_UOM IN VARCHAR2,
    X_OLD_RES_TERRITORY_ID IN NUMBER,
    X_NEW_RES_TERRITORY_ID IN NUMBER,
    X_OLD_ASSIGNEE_ROLE IN VARCHAR2,
    X_NEW_ASSIGNEE_ROLE IN VARCHAR2,
    X_OLD_ALARM_TYPE IN VARCHAR2,
    X_NEW_ALARM_TYPE IN VARCHAR2,
    X_OLD_ALARM_CONTACT IN VARCHAR2,
    X_NEW_ALARM_CONTACT IN VARCHAR2,
    X_OLD_CATEGORY_ID IN NUMBER,
    X_NEW_CATEGORY_ID IN NUMBER,
    X_OLD_BOOKING_START_DATE IN DATE,
    X_NEW_BOOKING_START_DATE IN DATE,
    X_OLD_BOOKING_END_DATE IN DATE,
    X_NEW_BOOKING_END_DATE IN DATE,
    X_OLD_ACTUAL_TRAVEL_DISTANCE IN NUMBER,
    X_NEW_ACTUAL_TRAVEL_DISTANCE IN NUMBER,
    X_OLD_ACTUAL_TRAVEL_DURATION IN NUMBER,
    X_NEW_ACTUAL_TRAVEL_DURATION IN NUMBER,
    X_OLD_ACTUAL_TRAVEL_DUR_UOM IN VARCHAR2,
    X_NEW_ACTUAL_TRAVEL_DUR_UOM IN VARCHAR2,
    X_OLD_SCHED_TRAVEL_DISTANCE IN NUMBER,
    X_NEW_SCHED_TRAVEL_DISTANCE IN NUMBER,
    X_OLD_SCHED_TRAVEL_DURATION IN NUMBER,
    X_NEW_SCHED_TRAVEL_DURATION IN NUMBER,
    X_OLD_SCHED_TRAVEL_DUR_UOM IN VARCHAR2,
    X_NEW_SCHED_TRAVEL_DUR_UOM IN VARCHAR2,
    X_OLD_ACTUAL_START_DATE IN DATE,
    X_NEW_ACTUAL_START_DATE IN DATE,
    X_OLD_ACTUAL_END_DATE IN DATE,
    X_NEW_ACTUAL_END_DATE IN DATE,
    X_FREE_BUSY_TYPE_CHANGED IN VARCHAR2,
    X_UPDATE_STATUS_FLAG_CHANGED IN VARCHAR2,
    X_SHOW_ON_CALENDAR_CHANGED IN VARCHAR2,
    X_SCHEDULED_FLAG_CHANGED IN VARCHAR2
    ) IS
      l_rowid ROWID;
      l_enable_audit    varchar2(5);

      cursor C IS select ROWID from JTF_TASK_ASSIGNMENTS_AUDIT_B
        where ASSIGNMENT_AUDIT_ID = X_ASSIGNMENT_AUDIT_ID;
  BEGIN
    l_enable_audit := Upper(nvl(fnd_profile.Value('JTF_TASK_ENABLE_AUDIT'),'Y'));
    IF(l_enable_audit = 'N') THEN
      RETURN;
    END IF;

    INSERT INTO JTF_TASK_ASSIGNMENTS_AUDIT_B (
      ASSIGNMENT_AUDIT_ID  ,
      ASSIGNMENT_ID  ,
      OBJECT_VERSION_NUMBER,
      TASK_ID  ,
      CREATION_DATE  ,
      CREATED_BY  ,
      LAST_UPDATE_DATE  ,
      LAST_UPDATED_BY  ,
      LAST_UPDATE_LOGIN  ,
      OLD_RESOURCE_TYPE_CODE  ,
      NEW_RESOURCE_TYPE_CODE  ,
      OLD_RESOURCE_ID  ,
      NEW_RESOURCE_ID  ,
      OLD_ASSIGNMENT_STATUS_ID  ,
      NEW_ASSIGNMENT_STATUS_ID  ,
      OLD_ACTUAL_EFFORT  ,
      NEW_ACTUAL_EFFORT  ,
      OLD_ACTUAL_EFFORT_UOM  ,
      NEW_ACTUAL_EFFORT_UOM  ,
      OLD_RES_TERRITORY_ID  ,
      NEW_RES_TERRITORY_ID  ,
      OLD_ASSIGNEE_ROLE  ,
      NEW_ASSIGNEE_ROLE  ,
      OLD_ALARM_TYPE  ,
      NEW_ALARM_TYPE  ,
      OLD_ALARM_CONTACT  ,
      NEW_ALARM_CONTACT  ,
      OLD_CATEGORY_ID  ,
      NEW_CATEGORY_ID  ,
      OLD_BOOKING_START_DATE  ,
      NEW_BOOKING_START_DATE  ,
      OLD_BOOKING_END_DATE  ,
      NEW_BOOKING_END_DATE  ,
      OLD_ACTUAL_TRAVEL_DISTANCE  ,
      NEW_ACTUAL_TRAVEL_DISTANCE  ,
      OLD_ACTUAL_TRAVEL_DURATION  ,
      NEW_ACTUAL_TRAVEL_DURATION  ,
      OLD_ACTUAL_TRAVEL_DURATION_UOM  ,
      NEW_ACTUAL_TRAVEL_DURATION_UOM  ,
      OLD_SCHED_TRAVEL_DISTANCE  ,
      NEW_SCHED_TRAVEL_DISTANCE  ,
      OLD_SCHED_TRAVEL_DURATION  ,
      NEW_SCHED_TRAVEL_DURATION  ,
      OLD_SCHED_TRAVEL_DURATION_UOM  ,
      NEW_SCHED_TRAVEL_DURATION_UOM  ,
      OLD_ACTUAL_START_DATE,
      NEW_ACTUAL_START_DATE,
      OLD_ACTUAL_END_DATE,
      NEW_ACTUAL_END_DATE,
      FREE_BUSY_TYPE_CHANGED  ,
      UPDATE_STATUS_FLAG_CHANGED  ,
      SHOW_ON_CALENDAR_CHANGED  ,
      SCHEDULE_FLAG_CHANGED ) VALUES (
      X_ASSIGNMENT_AUDIT_ID  ,
      X_ASSIGNMENT_ID  ,
      1.0,
      X_TASK_ID  ,
      X_CREATION_DATE  ,
      X_CREATED_BY  ,
      X_LAST_UPDATE_DATE  ,
      X_LAST_UPDATED_BY  ,
      X_LAST_UPDATE_LOGIN  ,
      X_OLD_RESOURCE_TYPE_CODE  ,
      X_NEW_RESOURCE_TYPE_CODE  ,
      X_OLD_RESOURCE_ID  ,
      X_NEW_RESOURCE_ID  ,
      X_OLD_ASSIGNMENT_STATUS_ID  ,
      X_NEW_ASSIGNMENT_STATUS_ID  ,
      X_OLD_ACTUAL_EFFORT  ,
      X_NEW_ACTUAL_EFFORT  ,
      X_OLD_ACTUAL_EFFORT_UOM  ,
      X_NEW_ACTUAL_EFFORT_UOM  ,
      X_OLD_RES_TERRITORY_ID  ,
      X_NEW_RES_TERRITORY_ID  ,
      X_OLD_ASSIGNEE_ROLE  ,
      X_NEW_ASSIGNEE_ROLE  ,
      X_OLD_ALARM_TYPE  ,
      X_NEW_ALARM_TYPE  ,
      X_OLD_ALARM_CONTACT  ,
      X_NEW_ALARM_CONTACT  ,
      X_OLD_CATEGORY_ID  ,
      X_NEW_CATEGORY_ID  ,
      X_OLD_BOOKING_START_DATE  ,
      X_NEW_BOOKING_START_DATE  ,
      X_OLD_BOOKING_END_DATE  ,
      X_NEW_BOOKING_END_DATE  ,
      X_OLD_ACTUAL_TRAVEL_DISTANCE  ,
      X_NEW_ACTUAL_TRAVEL_DISTANCE  ,
      X_OLD_ACTUAL_TRAVEL_DURATION  ,
      X_NEW_ACTUAL_TRAVEL_DURATION  ,
      X_OLD_ACTUAL_TRAVEL_DUR_UOM  ,
      X_NEW_ACTUAL_TRAVEL_DUR_UOM  ,
      X_OLD_SCHED_TRAVEL_DISTANCE  ,
      X_NEW_SCHED_TRAVEL_DISTANCE  ,
      X_OLD_SCHED_TRAVEL_DURATION  ,
      X_NEW_SCHED_TRAVEL_DURATION  ,
      X_OLD_SCHED_TRAVEL_DUR_UOM  ,
      X_NEW_SCHED_TRAVEL_DUR_UOM  ,
      X_OLD_ACTUAL_START_DATE,
      X_NEW_ACTUAL_START_DATE,
      X_OLD_ACTUAL_END_DATE,
      X_NEW_ACTUAL_END_DATE,
      X_FREE_BUSY_TYPE_CHANGED  ,
      X_UPDATE_STATUS_FLAG_CHANGED  ,
      X_SHOW_ON_CALENDAR_CHANGED  ,
      X_SCHEDULED_FLAG_CHANGED );


    OPEN c;
    FETCH c into l_rowid;
    IF (c%notfound) THEN
      close c;
      raise no_data_found;
    END IF;
    CLOSE c;
  END INSERT_ROW;

  PROCEDURE DELETE_ROW(X_ASSIGNMENT_ID IN NUMBER)
  IS
    CURSOR C IS select ROWID from JTF_TASK_ALL_ASSIGNMENTS
      where task_ASSIGNMENT_ID = X_ASSIGNMENT_ID;

    l_rowid ROWID;
    l_enable_audit    varchar2(5);
  BEGIN
    l_enable_audit := Upper(nvl(fnd_profile.Value('JTF_TASK_ENABLE_AUDIT'),'Y'));
    IF(l_enable_audit = 'N') THEN
      RETURN;
    END IF;
    OPEN c;
    FETCH c into l_rowid;
    IF(c%notfound) THEN
      DELETE FROM jtf_task_assignments_audit_b WHERE assignment_id = x_assignment_id;
    ELSE
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE c;
  END DELETE_ROW;


END jtf_task_assignment_audit_pkg;

/
