--------------------------------------------------------
--  DDL for Package Body CSF_TASK_ASSIGNMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_TASK_ASSIGNMENTS_PUB" AS
/* $Header: CSFPTASB.pls 120.20.12010000.15 2009/12/04 13:06:33 ramchint ship $ */

 g_pkg_name CONSTANT VARCHAR2(30) := 'CSF_TASK_ASSIGNMENTS_PUB';
 g_debug_level       NUMBER       := NVL(fnd_profile.value_specific('AFLOG_LEVEL'), fnd_log.level_event);


  /**
   * The Trip Information should be corrected so that it reflects
   * the correct availability.
   * Case#1
   *   New Assignment is created and is linked with a Trip.
   *   Decrease the trip availability.
   * Case#2
   *   Assignment is updated and is linked with a different Trip.
   *   Decrease the new trip availability and increase the old
   *   trip availability.
   * Case#3
   *   Assignment is cancelled. Increase the old trip
   *   availability.
   * Case#4
   *   Assignment is updated. Same trip is used. Increase /
   *   Decrease the availability by the difference.
   */

 FUNCTION cross_task_val(p_task_assignment_id NUMBER,p_assignment_status NUMBER,p_task out NOCOPY NUMBER)
 RETURN VARCHAR2;

 PROCEDURE debug(p_message VARCHAR2, p_module VARCHAR2, p_level NUMBER) IS
 BEGIN
    IF p_level >= g_debug_level
    THEN
      IF ( p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      THEN
        fnd_log.string(p_level, 'csf.plsql.CSF_TASK_ASSIGNMENTS_PUB.' || p_module, p_message);
      END IF;
    END IF;
  END;


  PROCEDURE update_trip_info(
    x_return_status                OUT    NOCOPY VARCHAR2
  , x_msg_count                    OUT    NOCOPY NUMBER
  , x_msg_data                     OUT    NOCOPY VARCHAR2
  , p_task_assignment_id           IN            NUMBER
  , p_task_id                      IN            NUMBER
  , p_resource_id                  IN            NUMBER
  , p_resource_type_code           IN            VARCHAR2
  , p_actual_start_date            IN            DATE      DEFAULT NULL
  , p_actual_end_date              IN            DATE      DEFAULT NULL
  , p_actual_effort                IN            NUMBER    DEFAULT NULL
  , p_actual_effort_uom            IN            VARCHAR2  DEFAULT NULL
  , p_actual_travel_duration       IN            NUMBER    DEFAULT NULL
  , p_actual_travel_duration_uom   IN            VARCHAR2  DEFAULT NULL
  , p_sched_travel_duration        IN            NUMBER    DEFAULT NULL
  , p_sched_travel_duration_uom    IN            VARCHAR2  DEFAULT NULL
  , p_old_trip_id                  IN            NUMBER    DEFAULT NULL
  , p_old_trip_ovn                 IN            NUMBER    DEFAULT NULL
  , x_trip_id                      OUT    NOCOPY NUMBER
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'UPDATE_TRIP_INFO';

    l_trip                      csf_trips_pub.trip_rec_type;

    l_new_start_date            DATE;
    l_new_end_date              DATE;
    l_old_start_date            DATE;
    l_old_end_date              DATE;

    CURSOR c_task_info IS
      SELECT t.scheduled_start_date
           , t.scheduled_end_date
           , csf_util_pvt.convert_to_minutes(planned_effort, planned_effort_uom) planned_effort
           , ta.actual_start_date
           , ta.actual_end_date
           , ta.resource_id
           , ta.resource_type_code
           , csf_util_pvt.convert_to_minutes(ta.actual_effort, ta.actual_effort_uom) actual_effort
           , csf_util_pvt.convert_to_minutes(ta.sched_travel_duration, ta.sched_travel_duration_uom) sched_travel_duration
           , csf_util_pvt.convert_to_minutes(ta.actual_travel_duration, ta.actual_travel_duration_uom) actual_travel_duration
           , cac.object_capacity_id old_trip_id
           , cac.object_version_number old_trip_ovn
        FROM jtf_tasks_b t
           , jtf_task_assignments ta
           , jtf_task_statuses_b ts
           , cac_sr_object_capacity cac
       WHERE t.task_id                    = p_task_id
         AND ta.task_id (+)               = t.task_id
         AND ts.task_status_id (+)        = ta.assignment_status_id
         AND cac.object_capacity_id (+)   = ta.object_capacity_id
         AND NVL(ts.closed_flag, 'N')     = 'N'
         AND NVL(ts.completed_flag, 'N')  = 'N'
         AND NVL(ts.cancelled_flag, 'N')  = 'N'
         AND (p_task_assignment_id IS NULL OR ta.task_assignment_id = p_task_assignment_id);

    l_task_info         c_task_info%ROWTYPE;
    l_travel_time       NUMBER;
    l_old_booked_time   NUMBER;
    l_new_booked_time   NUMBER;

  BEGIN

    -- If Actuals are passed, then Trip has to be Queried based on the passed Actuals
    IF NVL(p_actual_start_date, fnd_api.g_miss_date) <>  fnd_api.g_miss_date THEN
      l_new_start_date := p_actual_start_date;
      l_new_end_date   := p_actual_end_date;

      IF NVL(l_new_end_date, fnd_api.g_miss_date) = fnd_api.g_miss_date
        AND NVL(p_actual_effort, fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN
        l_new_end_date :=   l_new_start_date
                          + csf_util_pvt.convert_to_minutes(
                              p_actual_effort
                            , p_actual_effort_uom) / (60 * 24);
      END IF;
    END IF;

    OPEN c_task_info;
    FETCH c_task_info INTO l_task_info;
    CLOSE c_task_info;

    -- If Actuals are not passed, then Trip has to be Queried based on the Task's Data (Actuals / Scheduled)
    IF l_new_start_date IS NULL OR l_new_end_date IS NULL THEN
      IF l_task_info.actual_start_date IS NOT NULL THEN
        l_new_start_date := l_task_info.actual_start_date;
        l_new_end_date   := l_task_info.actual_end_date;

        IF l_new_end_date IS NULL THEN
          l_new_end_date := l_new_start_date + NVL(l_task_info.actual_effort, l_task_info.planned_effort) / (60*24);
        END IF;
      ELSE
        l_new_start_date := l_task_info.scheduled_start_date;
        l_new_end_date   := l_task_info.scheduled_end_date;

        IF l_new_end_date IS NULL AND l_task_info.planned_effort IS NOT NULL THEN
          l_new_end_date := l_new_start_date + l_task_info.planned_effort / (60*24);
        END IF;
      END IF;
    END IF;

    -- If the Caller wants to treat the given Old Trip Id as the Old Trip Id, then change it in our DataStructure.
    IF NVL(p_old_trip_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
      AND NVL(p_old_trip_ovn, fnd_api.g_miss_num) <> fnd_api.g_miss_num
    THEN
      l_task_info.old_trip_id  := p_old_trip_id;
      l_task_info.old_trip_ovn := p_old_trip_id;
    END IF;

    -- If the Caller wants to treat the given Old Trip Id as the Old Trip Id, then change it in our DataStructure.
    IF NVL(p_resource_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
    THEN
      l_task_info.resource_id        := p_resource_id;
      l_task_info.resource_type_code := p_resource_type_code;
    END IF;

    csf_trips_pub.find_trip(
      p_api_version         => 1
    , p_init_msg_list       => fnd_api.g_false
    , x_return_status       => x_return_status
    , x_msg_data            => x_msg_data
    , x_msg_count           => x_msg_count
    , p_resource_id         => l_task_info.resource_id
    , p_resource_type       => l_task_info.resource_type_code
    , p_start_date_time     => l_new_start_date
    , p_end_date_time       => l_new_end_date
    , p_overtime_flag       => fnd_api.g_true
    , x_trip                => l_trip
    );

    -- Error would be returned only if there are no trips or multiple trips
    -- found. We should continue in those cases.
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_new_start_date IS NULL THEN
      -- Start Date is NULL. That means there is no timings. Clear the Trip Id
      l_trip.trip_id := NULL;
    END IF;

    --
    -- Determine whether we have to update the availability of the Old Trip
    --
    l_old_booked_time := 0;
    IF l_task_info.old_trip_id IS NOT NULL THEN
      IF l_task_info.actual_start_date IS NOT NULL THEN
        l_old_start_date := l_task_info.actual_start_date;
        l_old_end_date   := l_task_info.actual_end_date;

        IF l_old_end_date IS NULL THEN
          l_old_end_date := l_old_start_date + NVL(l_task_info.actual_effort, l_task_info.planned_effort) / (60*24);
        END IF;
      END IF;

      IF l_old_start_date IS NULL OR l_old_end_date IS NULL THEN
        l_old_start_date := l_task_info.scheduled_start_date;
        l_old_end_date   := l_task_info.scheduled_end_date;

        IF l_old_end_date IS NULL AND l_task_info.planned_effort IS NOT NULL THEN
          l_old_end_date := l_old_start_date + l_task_info.planned_effort / (60*24);
        END IF;
      END IF;

      IF l_task_info.actual_travel_duration IS NOT NULL
        OR l_task_info.sched_travel_duration IS NOT NULL THEN
        l_old_start_date :=   l_old_start_date
                        - NVL(l_task_info.actual_travel_duration, l_task_info.sched_travel_duration)
                           / (60 * 24);
      END IF;

      l_old_booked_time := (l_old_end_date - l_old_start_date) * 24;

      IF l_task_info.old_trip_id <> NVL(l_trip.trip_id, -999) THEN
        csf_trips_pub.update_trip(
          p_api_version            => 1
        , p_init_msg_list          => fnd_api.g_false
        , x_return_status          => x_return_status
        , x_msg_data               => x_msg_data
        , x_msg_count              => x_msg_count
        , p_trip_id                => l_task_info.old_trip_id
        , p_object_version_number  => l_task_info.old_trip_ovn
        , p_upd_available_hours    => l_old_booked_time
		, p_available_hours_before => fnd_api.g_miss_num
		, p_available_hours_after  => fnd_api.g_miss_num
        );

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_old_booked_time := 0; -- Clear it so that it doesnt affect the new trip
      END IF;
    END IF;

    --
    -- Determine whether we have to update the availability of the New Trip
    --
    IF NVL(l_trip.trip_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      l_travel_time := 0;
      IF NVL(p_actual_travel_duration, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        l_travel_time := csf_util_pvt.convert_to_minutes(p_actual_travel_duration, p_actual_travel_duration_uom);
      ELSIF NVL(p_sched_travel_duration, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        l_travel_time := csf_util_pvt.convert_to_minutes(p_sched_travel_duration, p_sched_travel_duration);
      ELSIF NVL(l_task_info.actual_travel_duration, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        l_travel_time := l_task_info.actual_travel_duration;
      ELSIF NVL(l_task_info.sched_travel_duration, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        l_travel_time := l_task_info.sched_travel_duration;
      END IF;

      l_new_booked_time :=   (l_new_end_date - l_new_start_date) * 24 -- Scheduled Dates
                           + l_travel_time / 60                       -- Travel Time (in mins)
                           - l_old_booked_time;                       -- Old Booked Time

      IF ROUND(l_new_booked_time, 5) <> 0 THEN
        csf_trips_pub.update_trip(
          p_api_version           => 1
        , p_init_msg_list         => fnd_api.g_false
        , x_return_status         => x_return_status
        , x_msg_data              => x_msg_data
        , x_msg_count             => x_msg_count
        , p_trip_id               => l_trip.trip_id
        , p_object_version_number => l_trip.object_version_number
        , p_upd_available_hours   => - l_new_booked_time
		, p_available_hours_before => fnd_api.g_miss_num
		, p_available_hours_after  => fnd_api.g_miss_num
        );
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

    END IF;

    x_trip_id := l_trip.trip_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_trip_id := NULL;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_trip_id := NULL;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_trip_id := NULL;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END update_trip_info;

  /**
   * Propagate the Assignment Status Change to its dependent Objects like
   * Task, Parent Task and Child Tasks, Spares, etc.
   */
  PROCEDURE propagate_status_change(
    x_return_status                OUT    NOCOPY   VARCHAR2
  , x_msg_count                    OUT    NOCOPY   NUMBER
  , x_msg_data                     OUT    NOCOPY   VARCHAR2
  , p_task_assignment_id           IN              NUMBER
  , p_object_version_number        IN OUT NOCOPY   NUMBER
  , p_new_assignment_status_id     IN              NUMBER
  , p_update_task                  IN              VARCHAR2
  , p_new_sts_cancelled_flag       IN              VARCHAR2
  , x_task_object_version_number   OUT    NOCOPY   NUMBER
  , x_task_status_id               OUT    NOCOPY   NUMBER
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'PROPAGATE_STATUS_CHANGE';

    -- Cursor to fetch Information about the Assignment, Task and Trip
    CURSOR c_task_info IS
      SELECT t.task_id
           , t.object_version_number
           , t.task_status_id
           , t.scheduled_start_date
           , t.scheduled_end_date
           , t.task_split_flag
           , t.parent_task_id
           , (SELECT pt.object_version_number FROM jtf_tasks_b pt WHERE pt.task_id = t.parent_task_id) parent_task_ovn
           , t.source_object_type_code
           , ta.resource_id
           , ta.resource_type_code
           , cac.object_capacity_id trip_id
           , cac.object_version_number trip_ovn
           , NVL(
                 ( SELECT 'Y'
                     FROM jtf_task_assignments ta2, jtf_task_statuses_b ts2
                    WHERE ta2.task_id = t.task_id
                      AND ta2.task_assignment_id <> ta.task_assignment_id
                      AND ts2.task_status_id = ta2.assignment_status_id
                      AND NVL(ts2.cancelled_flag, 'N') <> 'Y'
                      AND NVL(ts2.rejected_flag, 'N') <> 'Y'
                      AND ta2.assignee_role = 'ASSIGNEE'
                      AND ta2.assignment_status_id <> ta.assignment_status_id
                      AND ROWNUM = 1
                 )
                 , 'N'
             ) other_ta_exists
        FROM jtf_tasks_b t
           , jtf_task_assignments ta
           , cac_sr_object_capacity cac
       WHERE ta.task_assignment_id = p_task_assignment_id
         AND t.task_id = ta.task_id
         AND cac.object_capacity_id (+) = ta.object_capacity_id;

    cursor c_tasks is
      select jta.assignment_status_id,jtb.validation_start_date,jtb.validation_end_date,jta.task_id,JTA.OBJECT_CAPACITY_ID
      from jtf_Task_assignments jta , jtf_task_statuses_b jtb
      where jta.assignment_status_id= jtb.task_status_id
      and jta.task_assignment_id=p_task_assignment_id
      and  jtb.enforce_validation_flag = 'Y'
      and nvl(jtb.validation_start_date,sysdate) <= sysdate
      and nvl(jtb.validation_end_date,sysdate) >= sysdate;

    l_task_info              c_task_info%ROWTYPE;
    l_scheduled_start        DATE;
    l_scheduled_end          DATE;
     L_TRIP                       NUMBER;
    val                         VARCHAR2(100):= 'TRUE';
    l_trip_id                    NUMBER;
    L_TASK                       NUMBER;
    L_TRIP_START                 DATE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_task_info;
    FETCH c_task_info INTO l_task_info;
    CLOSE c_task_info;

    -- If there is only one active task assignment (ignoring Closed, Completed, Cancelled
    -- or Rejected Assignments), then the new Status should be propagated to Task also
    -- for both of them to be in Sync.
    x_task_object_version_number := l_task_info.object_version_number;
    x_task_status_id             := l_task_info.task_status_id;
    IF p_update_task IS NULL OR p_update_task = fnd_api.g_true THEN
      IF l_task_info.other_ta_exists = 'N' AND l_task_info.task_status_id <> p_new_assignment_status_id THEN
        x_task_status_id   := p_new_assignment_status_id;

        -- The Task is going to be cancelled... Clear the Scheduled Dates
        IF p_new_sts_cancelled_flag = 'Y' AND l_task_info.source_object_type_code = 'SR' THEN
          l_scheduled_start := NULL;
          l_scheduled_end   := NULL;
        ELSE
          l_scheduled_start  := csf_util_pvt.get_miss_date;
          l_scheduled_end    := csf_util_pvt.get_miss_date;
        END IF;
        -- cross task validation


        -- No other open Task Assignments. Update the Task also.
        jtf_tasks_pub.update_task(
          p_api_version               => 1.0
        , x_return_status             => x_return_status
        , x_msg_count                 => x_msg_count
        , x_msg_data                  => x_msg_data
        , p_task_id                   => l_task_info.task_id
        , p_task_status_id            => x_task_status_id
        , p_object_version_number     => x_task_object_version_number
        , p_scheduled_start_date      => l_scheduled_start
        , p_scheduled_end_date        => l_scheduled_end
        , p_enable_workflow           => fnd_api.g_miss_char
        , p_abort_workflow            => fnd_api.g_miss_char
        );

        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      -- update the Parent Task so that it is having the correct Scheduled Dates.
      IF l_task_info.task_split_flag = 'D' THEN
        -- Sync up the Parent and all the other Siblings
        csf_tasks_pub.update_task_longer_than_shift(
          p_api_version            => 1.0
        , p_init_msg_list          => fnd_api.g_false
        , p_commit                 => fnd_api.g_false
        , x_return_status          => x_return_status
        , x_msg_count              => x_msg_count
        , x_msg_data               => x_msg_data
        , p_task_id                => l_task_info.parent_task_id
        , p_object_version_number  => l_task_info.parent_task_ovn
        , p_action                 => csf_tasks_pub.g_action_normal_to_parent
        );
        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
    END IF;

    -- If the new Assignment Status has Cancelled Flag, Delete the Spares
    -- Reservations created against the Task Assignment. Increase the Trip
    -- Availability.
    IF p_new_sts_cancelled_flag = 'Y' THEN
      csp_sch_int_pvt.clean_material_transaction(
        p_api_version_number     => 1.0
      , p_task_assignment_id     => p_task_assignment_id
      , x_return_status          => x_return_status
      , x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Assignment was previously linked to a trip. Increase its Availability
      IF l_task_info.trip_id IS NOT NULL THEN
        update_trip_info(
          x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_task_assignment_id         => p_task_assignment_id
        , p_task_id                    => l_task_info.task_id
        , p_resource_id                => l_task_info.resource_id
        , p_resource_type_code         => l_task_info.resource_type_code
        , p_old_trip_id                => l_task_info.trip_id
        , p_old_trip_ovn               => l_task_info.trip_ovn
        , x_trip_id                    => l_task_info.trip_id
        );

        -- Error out only when we have unexpected error.
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
    END IF;
  END propagate_status_change;

  /**
   * Creates a New Task Assignment for the given Task with the given attributes.
   *
   * If there exists any Cancelled Task Assignment for the Task with the given
   * Resource Information, then that Task Assignment is reused rather than creating a
   * new Task Assignment afresh.
   * <br>
   * If the Trip ID corresponding to the Task Assignment is passed as FND_API.G_MISS_NUM
   * then the user doesnt want to link the Assignment to any Trip. So the Trip ID will
   * be saved as NULL corresponding to the Task Assignment.
   * If Trip ID is passed as NULL or not passed at all, then the API will try to find a
   * Trip corresponding to the Assignment. Since we are dependent on Trips Model, any
   * Assignment created for a Field Service Task should be linked to a Trip (based on
   * Actual Date / Scheduled Dates). If there exists no Trip or there exists multiple trips,
   * then the API will error out. If Assignment shouldnt be linked to any Trip, then
   * Trip ID should be passed as FND_API.G_MISS_NUM.
   * <br>
   * Except for Task ID, Resouce ID, Resource Type Code all other parameters are optional.
   */
  PROCEDURE create_task_assignment(
    p_api_version                  IN           NUMBER
  , p_init_msg_list                IN           VARCHAR2
  , p_commit                       IN           VARCHAR2
  , p_validation_level             IN           NUMBER
  , x_return_status                OUT NOCOPY   VARCHAR2
  , x_msg_count                    OUT NOCOPY   NUMBER
  , x_msg_data                     OUT NOCOPY   VARCHAR2
  , p_task_assignment_id           IN           NUMBER
  , p_task_id                      IN           NUMBER
  , p_task_name                    IN           VARCHAR2
  , p_task_number                  IN           VARCHAR2
  , p_resource_type_code           IN           VARCHAR2
  , p_resource_id                  IN           NUMBER
  , p_resource_name                IN           VARCHAR2
  , p_actual_effort                IN           NUMBER
  , p_actual_effort_uom            IN           VARCHAR2
  , p_schedule_flag                IN           VARCHAR2
  , p_alarm_type_code              IN           VARCHAR2
  , p_alarm_contact                IN           VARCHAR2
  , p_sched_travel_distance        IN           NUMBER
  , p_sched_travel_duration        IN           NUMBER
  , p_sched_travel_duration_uom    IN           VARCHAR2
  , p_actual_travel_distance       IN           NUMBER
  , p_actual_travel_duration       IN           NUMBER
  , p_actual_travel_duration_uom   IN           VARCHAR2
  , p_actual_start_date            IN           DATE
  , p_actual_end_date              IN           DATE
  , p_palm_flag                    IN           VARCHAR2
  , p_wince_flag                   IN           VARCHAR2
  , p_laptop_flag                  IN           VARCHAR2
  , p_device1_flag                 IN           VARCHAR2
  , p_device2_flag                 IN           VARCHAR2
  , p_device3_flag                 IN           VARCHAR2
  , p_resource_territory_id        IN           NUMBER
  , p_assignment_status_id         IN           NUMBER
  , p_shift_construct_id           IN           NUMBER
  , p_object_capacity_id           IN           NUMBER
  , p_update_task                  IN           VARCHAR2
  , x_task_assignment_id           OUT NOCOPY   NUMBER
  , x_ta_object_version_number     OUT NOCOPY   NUMBER
  , x_task_object_version_number   OUT NOCOPY   NUMBER
  , x_task_status_id               OUT NOCOPY   NUMBER
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'CREATE_TASK_ASSIGNMENT';
    l_api_version    CONSTANT NUMBER       := 1.0;

    CURSOR c_cancelled_assignments IS
      SELECT ta.task_assignment_id
           , ta.object_version_number
        FROM jtf_task_assignments ta, jtf_task_statuses_b ts
       WHERE ta.task_id = p_task_id
         AND ta.resource_id = p_resource_id
         AND ta.resource_type_code = p_resource_type_code
         AND ta.assignment_status_id = ts.task_status_id
         AND ta.actual_start_date IS NULL
         AND ta.actual_end_date IS NULL
         AND ts.cancelled_flag = 'Y';

    CURSOR c_assignment_info IS
      SELECT object_version_number
        FROM jtf_task_assignments
       WHERE task_assignment_id = x_task_assignment_id;

    l_cancelled_assignments     c_cancelled_assignments%ROWTYPE;
    l_trans_valid               VARCHAR2(1);
    l_valid_statuses            VARCHAR2(2000);
    l_trip_id                   NUMBER;
    l_start_date                DATE;
    l_end_date                  DATE;
  BEGIN
    SAVEPOINT csf_create_task_assignment_pub;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    l_trip_id := p_object_capacity_id;

    IF (p_validation_level IS NULL OR p_validation_level = fnd_api.g_valid_level_full) THEN
      -- Validate Field Service status flow
      csf_tasks_pub.validate_status_change(NULL, p_assignment_status_id);

      -- Validate Trip ID passed. Trip ID has to a valid Trip given the Dates
      -- and Resource Critieria.
      -- If FND_API.G_MISS_NUM, then the caller wants to make Trip ID as NULL in the DB.
      IF l_trip_id = fnd_api.g_miss_num THEN
        l_trip_id := NULL;
      ELSE
        update_trip_info(
          x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_task_assignment_id         => p_task_assignment_id
        , p_task_id                    => p_task_id
        , p_resource_type_code         => p_resource_type_code
        , p_resource_id                => p_resource_id
        , p_actual_start_date          => p_actual_start_date
        , p_actual_end_date            => p_actual_end_date
        , p_actual_effort              => p_actual_effort
        , p_actual_effort_uom          => p_actual_effort_uom
        , p_actual_travel_duration     => p_actual_travel_duration
        , p_actual_travel_duration_uom => p_actual_travel_duration_uom
        , p_sched_travel_duration      => p_sched_travel_duration
        , p_sched_travel_duration_uom  => p_sched_travel_duration_uom
        , x_trip_id                    => l_trip_id
        );
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
    END IF;

    -- Reuse a Cancelled Task Assignment of the Task rather than creating anew.
    OPEN c_cancelled_assignments;
    FETCH c_cancelled_assignments INTO l_cancelled_assignments;
    CLOSE c_cancelled_assignments;

    IF l_cancelled_assignments.task_assignment_id IS NOT NULL THEN
      x_ta_object_version_number  := l_cancelled_assignments.object_version_number;
      x_task_assignment_id        := l_cancelled_assignments.task_assignment_id;
      update_task_assignment(
        p_api_version                    => p_api_version
      , p_init_msg_list                  => p_init_msg_list
      , p_commit                         => fnd_api.g_false
      , p_validation_level               => fnd_api.g_valid_level_none
      , x_return_status                  => x_return_status
      , x_msg_count                      => x_msg_count
      , x_msg_data                       => x_msg_data
      , p_task_assignment_id             => x_task_assignment_id
      , p_object_version_number          => x_ta_object_version_number
      , p_task_id                        => p_task_id
      , p_resource_type_code             => p_resource_type_code
      , p_resource_id                    => p_resource_id
      , p_resource_territory_id          => p_resource_territory_id
      , p_assignment_status_id           => p_assignment_status_id
      , p_actual_start_date              => p_actual_start_date
      , p_actual_end_date                => p_actual_end_date
      , p_sched_travel_distance          => p_sched_travel_distance
      , p_sched_travel_duration          => p_sched_travel_duration
      , p_sched_travel_duration_uom      => p_sched_travel_duration_uom
      , p_shift_construct_id             => p_shift_construct_id
      , p_object_capacity_id             => l_trip_id
      , p_update_task                    => p_update_task
      , x_task_object_version_number     => x_task_object_version_number
      , x_task_status_id                 => x_task_status_id
      );
    ELSE
      jtf_task_assignments_pub.create_task_assignment(
        p_api_version                    => 1.0
      , x_return_status                  => x_return_status
      , x_msg_count                      => x_msg_count
      , x_msg_data                       => x_msg_data
      , p_task_assignment_id             => p_task_assignment_id
      , p_task_id                        => p_task_id
      , p_task_name                      => p_task_name
      , p_task_number                    => p_task_number
      , p_resource_type_code             => p_resource_type_code
      , p_resource_id                    => p_resource_id
      , p_assignment_status_id           => p_assignment_status_id
      , p_object_capacity_id             => l_trip_id
      , p_actual_effort                  => p_actual_effort
      , p_actual_effort_uom              => p_actual_effort_uom
      , p_schedule_flag                  => p_schedule_flag
      , p_alarm_type_code                => p_alarm_type_code
      , p_alarm_contact                  => p_alarm_contact
      , p_sched_travel_distance          => p_sched_travel_distance
      , p_sched_travel_duration          => p_sched_travel_duration
      , p_sched_travel_duration_uom      => p_sched_travel_duration_uom
      , p_actual_travel_distance         => p_actual_travel_distance
      , p_actual_travel_duration         => p_actual_travel_duration
      , p_actual_travel_duration_uom     => p_actual_travel_duration_uom
      , p_actual_start_date              => p_actual_start_date
      , p_actual_end_date                => p_actual_end_date
      , p_palm_flag                      => p_palm_flag
      , p_wince_flag                     => p_wince_flag
      , p_laptop_flag                    => p_laptop_flag
      , p_device1_flag                   => p_device1_flag
      , p_device2_flag                   => p_device2_flag
      , p_device3_flag                   => p_device3_flag
      , p_resource_territory_id          => p_resource_territory_id
      , p_shift_construct_id             => p_shift_construct_id
      , p_enable_workflow                => fnd_api.g_miss_char
      , p_abort_workflow                 => fnd_api.g_miss_char
      , x_task_assignment_id             => x_task_assignment_id
      );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_assignment_info;
      FETCH c_assignment_info INTO x_ta_object_version_number;
      CLOSE c_assignment_info;

      -- Update the Assignment Status and thereby Synchronizing with Task
      propagate_status_change(
        x_return_status                  => x_return_status
      , x_msg_count                      => x_msg_count
      , x_msg_data                       => x_msg_data
      , p_task_assignment_id             => x_task_assignment_id
      , p_object_version_number          => x_ta_object_version_number
      , p_new_assignment_status_id       => p_assignment_status_id
      , p_update_task                    => p_update_task
      , p_new_sts_cancelled_flag         => 'N'
      , x_task_object_version_number     => x_task_object_version_number
      , x_task_status_id                 => x_task_status_id
      );
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_create_task_assignment_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_create_task_assignment_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_create_task_assignment_pub;
  END create_task_assignment;

  /**
   * Update an existing Task Assignment with new Task Attributes
   *
   * Given the Task Assignment ID and Task Object Version Number, it calls
   * JTF Task Assignment API to update the Task Assignment with the new Attributes.
   * It is actually a two step process
   *    1. Updating the Task Assignment with the new Task Attributes except Status
   *    2. Updating the Task Assignment with the new Task Status (if not FND_API.G_MISS_NUM)
   *       by calling UPDATE_ASSIGNMENT_STATUS.
   * <br>
   * Because of the two step process, the returned Task Assignment Object
   * Version Number might be incremented by 2 when user might have expected an
   * increment of only 1.
   * <br>
   * Except Task Assignment ID and Object Version Number parameters, all are optional.
   */
  PROCEDURE update_task_assignment(
    p_api_version                  IN              NUMBER
  , p_init_msg_list                IN              VARCHAR2
  , p_commit                       IN              VARCHAR2
  , p_validation_level             IN              NUMBER
  , x_return_status                OUT    NOCOPY   VARCHAR2
  , x_msg_count                    OUT    NOCOPY   NUMBER
  , x_msg_data                     OUT    NOCOPY   VARCHAR2
  , p_task_assignment_id           IN              NUMBER
  , p_object_version_number        IN OUT NOCOPY   NUMBER
  , p_task_id                      IN              NUMBER
  , p_resource_type_code           IN              VARCHAR2
  , p_resource_id                  IN              NUMBER
  , p_resource_territory_id        IN              NUMBER
  , p_assignment_status_id         IN              NUMBER
  , p_actual_start_date            IN              DATE
  , p_actual_end_date              IN              DATE
  , p_sched_travel_distance        IN              NUMBER
  , p_sched_travel_duration        IN              NUMBER
  , p_sched_travel_duration_uom    IN              VARCHAR2
  , p_shift_construct_id           IN              NUMBER
  , p_object_capacity_id           IN              NUMBER
  , p_update_task                  IN              VARCHAR2
  , p_task_number                  IN              VARCHAR2
  , p_task_name                    IN              VARCHAR2
  , p_resource_name                IN              VARCHAR2
  , p_actual_effort                IN              NUMBER
  , p_actual_effort_uom            IN              VARCHAR2
  , p_actual_travel_distance       IN              NUMBER
  , p_actual_travel_duration       IN              NUMBER
  , p_actual_travel_duration_uom   IN              VARCHAR2
  , p_attribute1                   IN              VARCHAR2
  , p_attribute2                   IN              VARCHAR2
  , p_attribute3                   IN              VARCHAR2
  , p_attribute4                   IN              VARCHAR2
  , p_attribute5                   IN              VARCHAR2
  , p_attribute6                   IN              VARCHAR2
  , p_attribute7                   IN              VARCHAR2
  , p_attribute8                   IN              VARCHAR2
  , p_attribute9                   IN              VARCHAR2
  , p_attribute10                  IN              VARCHAR2
  , p_attribute11                  IN              VARCHAR2
  , p_attribute12                  IN              VARCHAR2
  , p_attribute13                  IN              VARCHAR2
  , p_attribute14                  IN              VARCHAR2
  , p_attribute15                  IN              VARCHAR2
  , p_attribute_category           IN              VARCHAR2
  , p_show_on_calendar             IN              VARCHAR2
  , p_category_id                  IN              NUMBER
  , p_schedule_flag                IN              VARCHAR2
  , p_alarm_type_code              IN              VARCHAR2
  , p_alarm_contact                IN              VARCHAR2
  , p_palm_flag                    IN              VARCHAR2
  , p_wince_flag                   IN              VARCHAR2
  , p_laptop_flag                  IN              VARCHAR2
  , p_device1_flag                 IN              VARCHAR2
  , p_device2_flag                 IN              VARCHAR2
  , p_device3_flag                 IN              VARCHAR2
  , p_enable_workflow              IN              VARCHAR2
  , p_abort_workflow               IN              VARCHAR2
  , x_task_object_version_number   OUT    NOCOPY   NUMBER
  , x_task_status_id               OUT    NOCOPY   NUMBER
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TASK_ASSIGNMENT';
    l_api_version   CONSTANT NUMBER       := 1.0;

    -- cursor to fetch the Cancelled Flag corresponding to the new Task Status.
    CURSOR c_task_status_info IS
      SELECT NVL (ts.cancelled_flag, 'N') cancelled_flag
        FROM jtf_task_statuses_b ts
       WHERE ts.task_status_id = p_assignment_status_id;

    -- cursor to fetch Information about the Task Assignment.
    CURSOR c_task_assignment_info IS
      SELECT ta.assignment_status_id, ta.task_id
        FROM jtf_task_assignments ta
       WHERE task_assignment_id = p_task_assignment_id;

     cursor c_tasks is
       select jta.assignment_status_id,jta.task_id,JTA.OBJECT_CAPACITY_ID,object_version_number
      from jtf_Task_assignments jta
      where jta.task_assignment_id=p_task_assignment_id;

    CURSOR c_cross_task(p_sched_start_date date, p_sched_end_date date)
    IS
     select jtB.TASK_status_id,jtb.validation_start_date,jtb.validation_end_date
      from  jtf_task_statuses_b jtb
      where  jtb.enforce_validation_flag = 'Y'
      and nvl(jtb.validation_start_date,nvl(trunc(p_sched_start_date),sysdate)) <= nvl(trunc(p_sched_start_date),sysdate)
      and nvl(jtb.validation_end_date,nvl(trunc(p_sched_end_date),sysdate)) >= nvl(trunc(p_sched_end_date),sysdate);

     CURSOR TRIP_SD(L_TRIP_ID NUMBER)
      IS
       SELECT START_dATE_TIME
       FROM CAC_SR_OBJECT_CAPACITY
       WHERE OBJECT_CAPACITY_ID = L_TRIP_ID;
    cursor c_Task_number(l_task number)
    is
     select task_number
     from jtf_tasks_b
     where task_id=l_task;

    cursor c_task_status(l_task number)
    is
    select name
    from jtf_task_statuses_tl jl,jtf_tasks_b jb
    where jl.task_status_id=jb.task_status_id
      and jb.task_id = l_task
    and language=userenv('lang');

    cursor c_scheduled_dates(p_task_id number)
    IS
    select scheduled_start_date, scheduled_end_date
    from jtf_tasks_b
    where task_id =p_task_id
    and nvl(deleted_flag,'N')<>'Y';

    scheduled_dates c_scheduled_dates%rowtype;


    l_task_id                   NUMBER;
    l_old_assignment_status_id  NUMBER;
    l_new_sts_cancelled_flag    VARCHAR2(1);
    l_trip_id                   NUMBER;
    l_distance                  NUMBER;
    l_duration                  NUMBER;
    l_duration_uom              VARCHAR2(3);
    l_trip                       NUMBER;
    val                         VARCHAR2(100):= 'TRUE';
    --l_trip_id                    NUMBER;
    L_TASK                       NUMBER;
    L_TRIP_START                 DATE;
    l_sts                       NUMBER;
    l_task_name                  VARCHAR2(200);
    l_task_number                VARCHAR2(200);
    l_modified_ver_no            NUMBER;



  BEGIN
    SAVEPOINT csf_update_task_assignment_pub;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Fetch the Task Assignment Information
    OPEN c_task_assignment_info;
    FETCH c_task_assignment_info INTO l_old_assignment_status_id, l_task_id;
    CLOSE c_task_assignment_info;

    -- We require Task Id for computations. If the caller doesnt pass Task Id
    -- lets retrieve it from JTF_TASK_ASSIGNMENTS. If the caller has indeeed
    -- passed it, then use that value.
    IF p_task_id <> fnd_api.g_miss_num AND p_task_id IS NOT NULL THEN
      l_task_id := p_task_id;
    END IF;

    l_trip_id := p_object_capacity_id;

    -- If Assignment is cancelled, then we have to clear the Scheduled Travel
    -- Duration, Distance and Trip ID.
    l_distance               := p_sched_travel_distance;
    l_duration               := p_sched_travel_duration;
    l_duration_uom           := p_sched_travel_duration_uom;
    l_new_sts_cancelled_flag := 'N';
    IF p_assignment_status_id <> fnd_api.g_miss_num THEN
      OPEN c_task_status_info;
      FETCH c_task_status_info INTO l_new_sts_cancelled_flag;
      CLOSE c_task_status_info;

      IF l_new_sts_cancelled_flag = 'Y' THEN
        l_distance     := NULL;
        l_duration     := NULL;
        l_duration_uom := NULL;
        l_trip_id      := NULL;
      END IF;
    END IF;

   open c_scheduled_dates(l_task_id);
   fetch c_scheduled_dates into scheduled_dates;
   close c_scheduled_dates;


    -- cross task validation
   FOR i IN c_cross_task(scheduled_dates.scheduled_start_date,scheduled_dates.scheduled_end_date)
   LOOP

     open c_tasks;
     fetch c_tasks into l_sts,l_task,l_trip,l_modified_ver_no;
     close c_tasks;
     IF i.task_status_id = p_assignment_status_id
     THEN
        val := cross_task_val(p_task_assignment_id,p_assignment_status_id,l_task);
       IF  val ='FALSE'
       THEN

         OPEN TRIP_SD(L_TRIP);
         FETCH TRIP_SD INTO L_TRIP_START;
         CLOSE TRIP_SD;
         open c_task_number(l_task);
         fetch c_task_number into l_task_number;
         close c_task_number;
         open c_task_status(l_task);
         fetch c_task_status into l_task_name;
         close c_task_status;
          fnd_message.set_name('CSF','CSF_CROSSTASK_VALIDATION');
          fnd_message.set_token('TASK_NUMBER',l_task_number);
          fnd_message.set_token('TASK_ASSIGNMENT_STATUS',l_task_name);
          --fnd_message.set_token('TRIP_START_DATE',TO_CHAR(L_TRIP_START,'DD/MM/YYYY HH24:MI:SS'));
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
       END IF;
   END IF;
   END LOOP;


    IF (p_validation_level IS NULL OR p_validation_level = fnd_api.g_valid_level_full) THEN

      -- Validate Field Service status flow
      IF p_assignment_status_id <> fnd_api.g_miss_num
        AND NVL(l_old_assignment_status_id, -1) <> NVL(p_assignment_status_id, -1)
      THEN
        csf_tasks_pub.validate_status_change(l_old_assignment_status_id, p_assignment_status_id);
      END IF;



      -- If Trip ID is passed as FND_API.G_MISS_NUM.. and Actuals are passed, we need to link
      -- the Task Assignment to the correct Trip.
      IF l_trip_id IS NOT NULL AND l_new_sts_cancelled_flag = 'N' THEN

        update_trip_info(
          x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_task_id                    => l_task_id
        , p_task_assignment_id         => p_task_assignment_id
        , p_resource_type_code         => p_resource_type_code
        , p_resource_id                => p_resource_id
        , p_actual_start_date          => p_actual_start_date
        , p_actual_end_date            => p_actual_end_date
        , p_actual_effort              => p_actual_effort
        , p_actual_effort_uom          => p_actual_effort_uom
        , p_actual_travel_duration     => p_actual_travel_duration
        , p_actual_travel_duration_uom => p_actual_travel_duration_uom
        , p_sched_travel_duration      => p_sched_travel_duration
        , p_sched_travel_duration_uom  => p_sched_travel_duration_uom
        , x_trip_id                    => l_trip_id
        );
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status =  fnd_api.g_ret_sts_success
        THEN
               open c_tasks;
               fetch c_tasks into l_sts,l_task,l_trip,l_modified_ver_no;
               close c_tasks;


        END IF;
      END IF;
    END IF;
    IF  l_modified_ver_no IS NULL
    THEN
        l_modified_ver_no :=p_object_version_number;
    END IF;
    jtf_task_assignments_pub.update_task_assignment(
      p_api_version                  => 1.0
    , x_return_status                => x_return_status
    , x_msg_count                    => x_msg_count
    , x_msg_data                     => x_msg_data
    , p_task_assignment_id           => p_task_assignment_id
    , p_object_version_number        => l_modified_ver_no
    , p_task_id                      => l_task_id
    , p_resource_type_code           => p_resource_type_code
    , p_resource_id                  => p_resource_id
    , p_resource_territory_id        => p_resource_territory_id
    , p_assignment_status_id         => p_assignment_status_id
    , p_actual_start_date            => p_actual_start_date
    , p_actual_end_date              => p_actual_end_date
    , p_sched_travel_distance        => l_distance
    , p_sched_travel_duration        => l_duration
    , p_sched_travel_duration_uom    => l_duration_uom
    , p_shift_construct_id           => p_shift_construct_id
    , p_object_capacity_id           => l_trip_id
    , p_task_number                  => p_task_number
    , p_task_name                    => p_task_name
    , p_resource_name                => p_resource_name
    , p_actual_effort                => p_actual_effort
    , p_actual_effort_uom            => p_actual_effort_uom
    , p_actual_travel_distance       => p_actual_travel_distance
    , p_actual_travel_duration       => p_actual_travel_duration
    , p_actual_travel_duration_uom   => p_actual_travel_duration_uom
    , p_attribute1                   => p_attribute1
    , p_attribute2                   => p_attribute2
    , p_attribute3                   => p_attribute3
    , p_attribute4                   => p_attribute4
    , p_attribute5                   => p_attribute5
    , p_attribute6                   => p_attribute6
    , p_attribute7                   => p_attribute7
    , p_attribute8                   => p_attribute8
    , p_attribute9                   => p_attribute9
    , p_attribute10                  => p_attribute10
    , p_attribute11                  => p_attribute11
    , p_attribute12                  => p_attribute12
    , p_attribute13                  => p_attribute13
    , p_attribute14                  => p_attribute14
    , p_attribute15                  => p_attribute15
    , p_attribute_category           => p_attribute_category
    , p_show_on_calendar             => p_show_on_calendar
    , p_category_id                  => p_category_id
    , p_schedule_flag                => p_schedule_flag
    , p_alarm_type_code              => p_alarm_type_code
    , p_alarm_contact                => p_alarm_contact
    , p_palm_flag                    => p_palm_flag
    , p_wince_flag                   => p_wince_flag
    , p_laptop_flag                  => p_laptop_flag
    , p_device1_flag                 => p_device1_flag
    , p_device2_flag                 => p_device2_flag
    , p_device3_flag                 => p_device3_flag
    , p_enable_workflow              => p_enable_workflow
    , p_abort_workflow               => p_abort_workflow
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- If Assignment Status is updated, then propagate the status to other objects
    IF p_assignment_status_id <> fnd_api.g_miss_num THEN
      propagate_status_change(
        x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_task_assignment_id         => p_task_assignment_id
      , p_object_version_number      => p_object_version_number
      , p_new_assignment_status_id   => p_assignment_status_id
      , p_update_task                => p_update_task
      , p_new_sts_cancelled_flag     => l_new_sts_cancelled_flag
      , x_task_object_version_number => x_task_object_version_number
      , x_task_status_id             => x_task_status_id
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_update_task_assignment_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_update_task_assignment_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_update_task_assignment_pub;
  END update_task_assignment;

  /**
   * Update the Status of the Task Assignment with the given Status and propagate to the
   * Task also if required.
   * <br>
   * Task Assignment is updated with the new Status if the Transition from the current
   * status to the new status is allowed as determined by
   * CSF_TASKS_PUB.VALIDATE_STATE_TRANSITION. Transition validation is done only
   * when Validation Level is passed as FULL.
   * <br>
   * In addition to updating the Task Assignment Status, the following operations are also
   * done
   *   1. If the Task corresponding to the given Task Assignment has no other
   *      Open / Active Task Assignments other than the given one, then the Assignment
   *      Status is propagated to the Task also. If there exists any other Active
   *      Assignment, then the Task is not updated.
   *      The parameters P_TASK_OBJECT_VERSION_NUMBER and X_TASK_STATUS_ID reflect
   *      the Object Version Number and Task Status ID of the Task in Database
   *      irrespective of the fact whether the update has taken place or not. <br>
   *
   *   2. If the Assignment goes to Cancelled (as per the new status), then if any
   *      Spares Order is linked to the Assignment, they are cleaned up by calling
   *      CLEAN_MATERIAL_TRANSACTION of Spares. <br>
   *
   *   3. If the Assignment goes to Assigned (as per the new status), and the
   *      old status is not Assigned, then Orders are created and linked to the
   *      Task Assignment. <br>
   *
   *   4. If the Assignnment goes to Working (as per the new status), then it means
   *      that the Resource is working on the Task and so his location should be updated
   *      to reflect the location of the Task. This is required by Map Functionality.
   *      THIS IS WRONG AND SHOULD BE REMOVED. MAP SHOULD BE USING HZ_LOCATIONS TABLE. <br>
   *
   * @param  p_api_version                  API Version (1.0)
   * @param  p_init_msg_list                Initialize Message List
   * @param  p_commit                       Commit the Work
   * @param  p_validation_level             Validate the given Parameters
   * @param  x_return_status                Return Status of the Procedure.
   * @param  x_msg_count                    Number of Messages in the Stack.
   * @param  x_msg_data                     Stack of Error Messages.
   * @param  p_task_assignment_id           Task Assignment ID of the Assignment to be updated
   * @param  p_assignment_status_id         New Task Status ID for the Task Assignment.
   * @param  p_show_on_calendar             <Dont Know>
   * @param  p_object_version_number        Current Task Version and also container for new one.
   * @param  x_task_object_version_number   Task Object Version Number (either old or new)
   * @param  x_task_status_id               Task Status ID (either old or new)
   */
  PROCEDURE update_assignment_status(
    p_api_version                  IN              NUMBER
  , p_init_msg_list                IN              VARCHAR2
  , p_commit                       IN              VARCHAR2
  , p_validation_level             IN              NUMBER
  , x_return_status                OUT    NOCOPY   VARCHAR2
  , x_msg_count                    OUT    NOCOPY   NUMBER
  , x_msg_data                     OUT    NOCOPY   VARCHAR2
  , p_task_assignment_id           IN              NUMBER
  , p_object_version_number        IN OUT NOCOPY   NUMBER
  , p_assignment_status_id         IN              NUMBER
  , p_update_task                  IN              VARCHAR2
  , p_show_on_calendar             IN              VARCHAR2
  , x_task_object_version_number   OUT    NOCOPY   NUMBER
  , x_task_status_id               OUT    NOCOPY   NUMBER
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_ASSIGNMENT_STATUS';
    l_api_version   CONSTANT NUMBER       := 1.0;

    -- cursor to fetch Information about the Task Assignment.
    CURSOR c_task_assignment_info IS
      SELECT ta.assignment_status_id,ta.task_id
        FROM jtf_task_assignments ta
       WHERE task_assignment_id = p_task_assignment_id;

    -- Fetch the Cancelled Flag corresponding to the new Task Status.
    CURSOR c_task_status_info IS
      SELECT NVL (ts.cancelled_flag, 'N') cancelled_flag
        FROM jtf_task_statuses_b ts
       WHERE ts.task_status_id = p_assignment_status_id;

       cursor c_tasks is
       select jta.assignment_status_id,jta.task_id,JTA.OBJECT_CAPACITY_ID
      from jtf_Task_assignments jta
      where jta.task_assignment_id=p_task_assignment_id;

      CURSOR c_cross_task(p_sched_start_date date, p_sched_end_date date)
      IS
      select jtB.TASK_status_id,jtb.validation_start_date,jtb.validation_end_date
      from  jtf_task_statuses_b jtb
      where  jtb.enforce_validation_flag = 'Y'
      and nvl(jtb.validation_start_date,nvl(trunc(p_sched_start_date),sysdate)) <= nvl(trunc(p_sched_start_date),sysdate)
      and nvl(jtb.validation_end_date,nvl(trunc(p_sched_end_date),sysdate)) >= nvl(trunc(p_sched_end_date),sysdate);



      CURSOR c_scheduled_dates(p_task_id number)
      IS
      SELECT scheduled_start_date, scheduled_end_date
      FROM jtf_tasks_b
      WHERE task_id =p_task_id
      AND nvl(deleted_flag,'N')<>'Y';

      scheduled_dates c_scheduled_dates%rowtype;

     CURSOR TRIP_SD(L_TRIP_ID NUMBER)
      IS
       SELECT START_dATE_TIME
       FROM CAC_SR_OBJECT_CAPACITY
       WHERE OBJECT_CAPACITY_ID = L_TRIP_ID;

    cursor c_Task_number(l_task number)
    is
     select task_number
     from jtf_tasks_b
     where task_id=l_task;
     Cursor c_task_status(l_task number)
     IS
     select name
      from jtf_task_statuses_tl jl,jtf_tasks_b jb
      where jl.task_status_id=jb.task_status_id
        and jb.task_id = l_task
      and language=userenv('lang');




    l_old_assignment_status_id   NUMBER;
    l_new_sts_cancelled_flag     VARCHAR2(1);
    l_distance                   NUMBER;
    l_duration                   NUMBER;
    l_duration_uom               VARCHAR2(3);
    l_trip_id                    NUMBER;
     val                         VARCHAR2(100):= 'TRUE';
    --l_trip_id                    NUMBER;
    L_TASK                       NUMBER;
    L_TRIP_START                 DATE;
    l_sts                       NUMBER;
    l_task_name                  VARCHAR2(200);
    l_task_number                VARCHAR2(200);
    l_trip                       NUMBER;
    l_task_id                    NUMBER;





  BEGIN
    SAVEPOINT csf_update_assign_status_pub;


    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Check whether there is anything update in Assignment Status.
    IF p_assignment_status_id = fnd_api.g_miss_num THEN
      RETURN;
    END IF;

    OPEN c_task_assignment_info;
    FETCH c_task_assignment_info INTO l_old_assignment_status_id,l_task_id;
    CLOSE c_task_assignment_info;

    IF l_old_assignment_status_id = p_assignment_status_id THEN
      RETURN;
    END IF;

    IF (p_validation_level IS NULL OR p_validation_level = fnd_api.g_valid_level_full) THEN
      -- Validate Field Service status flow
      csf_tasks_pub.validate_status_change(l_old_assignment_status_id, p_assignment_status_id);
    END IF;

    OPEN c_task_status_info;
    FETCH c_task_status_info INTO l_new_sts_cancelled_flag;
    CLOSE c_task_status_info;

    IF l_new_sts_cancelled_flag = 'Y' THEN
      l_distance     := NULL;
      l_duration     := NULL;
      l_duration_uom := NULL;
      l_trip_id      := NULL;
    ELSE
      l_distance     := csf_util_pvt.get_miss_num;
      l_duration     := csf_util_pvt.get_miss_num;
      l_duration_uom := csf_util_pvt.get_miss_char;
      l_trip_id      := csf_util_pvt.get_miss_num;
    END IF;

    open  c_scheduled_dates(l_task_id);
    fetch c_scheduled_dates into scheduled_dates;
    close c_scheduled_dates;

    -- cross task validation
    FOR i IN c_cross_task(scheduled_dates.scheduled_start_date,scheduled_dates.scheduled_end_date)
    LOOP
     open c_tasks;
     fetch c_tasks into l_sts,l_task,l_trip;
     close c_tasks;
     IF i.task_status_id = p_assignment_status_id
     THEN
       val := cross_task_val(p_task_assignment_id,p_assignment_status_id,l_task);
     IF  val ='FALSE'
     THEN

         OPEN TRIP_SD(L_TRIP);
         FETCH TRIP_SD INTO L_TRIP_START;
         CLOSE TRIP_SD;
         open c_task_number(l_task);
         fetch c_task_number into l_task_number;
         close c_task_number;
         open c_task_status(l_task);
         fetch c_task_status into l_task_name;
         close c_task_status;
        fnd_message.set_name('CSF','CSF_CROSSTASK_VALIDATION');
        fnd_message.set_token('TASK_NUMBER',l_task_number);
        fnd_message.set_token('TASK_ASSIGNMENT_STATUS',l_task_name);
        --fnd_message.set_token('TRIP_START_DATE',TO_CHAR(L_TRIP_START,'DD/MM/YYYY HH24:MI:SS'));
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
     END IF;
    END IF;
   END LOOP;
    -- Update the Task Assignment.


    -- Update the Task Assignment.
    jtf_task_assignments_pub.update_task_assignment(
      p_api_version               => 1.0
    , x_return_status             => x_return_status
    , x_msg_count                 => x_msg_count
    , x_msg_data                  => x_msg_data
    , p_object_version_number     => p_object_version_number
    , p_task_assignment_id        => p_task_assignment_id
    , p_assignment_status_id      => p_assignment_status_id
    , p_sched_travel_distance     => l_distance
    , p_sched_travel_duration     => l_duration
    , p_sched_travel_duration_uom => l_duration_uom
    , p_object_capacity_id        => l_trip_id
    , p_show_on_calendar          => p_show_on_calendar
    , p_category_id               => NULL
    , p_enable_workflow           => fnd_api.g_false
    , p_abort_workflow            => fnd_api.g_false
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Propagate the changes to Task, Parent Task, Child Tasks, Spares, etc.
    propagate_status_change(
      x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_task_assignment_id         => p_task_assignment_id
    , p_object_version_number      => p_object_version_number
    , p_new_assignment_status_id   => p_assignment_status_id
    , p_update_task                => p_update_task
    , p_new_sts_cancelled_flag     => l_new_sts_cancelled_flag
    , x_task_object_version_number => x_task_object_version_number
    , x_task_status_id             => x_task_status_id
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_update_assign_status_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_update_assign_status_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_update_assign_status_pub;
  END update_assignment_status;

 FUNCTION cross_task_val(p_task_assignment_id NUMBER,p_assignment_status NUMBER,p_task out NOCOPY NUMBER)
 RETURN VARCHAR2
 IS
   CURSOR c_trip_info(p_task_assignment_id number)
   IS
     SELECT jtb.task_id     ,
            jtb.customer_id       ,
            jtb.address_id        ,
            cac.object_capacity_id,
            cac.start_date_time   ,
            cac.end_date_time
       FROM jtf_tasks_b jtb   ,
            jtf_task_assignments jta,
            cac_sr_object_capacity cac
      WHERE jta.task_assignment_id = p_task_assignment_id
        AND jta.task_id                = jtb.task_id
        AND cac.object_capacity_id (+) = jta.object_capacity_id;

   CURSOR c_task_info(p_trip number,p_task number)
   IS
      SELECT b.task_id     ,
            a.task_assignment_id,
            a.assignment_status_id
       FROM jtf_task_assignments a ,
            jtf_tasks_b b
      WHERE object_capacity_id = p_trip
        AND a.task_id              =b.task_id
        AND b.task_id NOT         IN (p_task)
        AND b.task_type_id NOT    IN (20,21);

   CURSOR c_site_info(p_task number)
   IS
    SELECT task_id,customer_id,address_id
    from jtf_tasks_b
    where task_id = p_task;

   CURSOR c_working
   IS
    select task_status_id from jtf_task_statuses_b
    where assigned_flag = 'Y'
    and working_flag = 'Y'
    and seeded_flag = 'Y'
    and nvl(approved_flag,'N') = 'N'
    and task_status_flag = 'Y'
    and assignment_status_flag = 'Y';

  CURSOR c_travel
  IS
    select task_status_id from jtf_task_statuses_b
    where travel_flag = 'Y'
    and seeded_flag= 'Y';

   CURSOR c_task_geometry(p_task_id number) IS
      SELECT l.geometry
        FROM jtf_tasks_b t, hz_locations l
       WHERE t.task_id = p_task_id
         AND l.location_id = csf_tasks_pub.get_task_location_id(t.task_id, t.address_id, t.location_id);


   c_trip_rec                        c_trip_info%rowtype;
   l_task_id                         number;
   l_customer_id                     number;
   l_address_id                      number;
   l_work                            number;
   l_travel                          number;
   l_geometry                        MDSYS.SDO_GEOMETRY;
   t_geometry                        MDSYS.SDO_GEOMETRY;
   l_longitude                       NUMBER;
   l_latitude						             NUMBER;
   t_longitude                       NUMBER;
   t_latitude						             NUMBER;
   l_geocode                         VARCHAR2(1)              := 'N';
   l_msg_count                       NUMBER;
   l_msg_data                        VARCHAR2(2000);
   l_return_status                   VARCHAR2(1);
   l_valid_geo                       VARCHAR2(5);
   l_api_name        CONSTANT VARCHAR2(30) := 'cross_task_val';



   a number := 0;

   l_debug boolean := TRUE;
  BEGIN
    IF l_debug
    THEN
       debug('Input Parameters: p_task_assignment_id:'||p_task_assignment_id||',p_assignment_status: '||p_assignment_status, l_api_name, fnd_log.level_statement);
    END IF;
    open c_trip_info(p_task_assignment_id);
    fetch c_trip_info into c_trip_rec;
    close c_trip_info;

    IF l_debug
    THEN
     debug('Task Id :'||c_trip_rec.task_id, l_api_name, fnd_log.level_statement);
    END IF;
    -- Fetch the Geocode information of the task whose status is going to be changed
    OPEN c_task_geometry(c_trip_rec.task_id);
    FETCH c_task_geometry INTO l_geometry;
    CLOSE c_task_geometry;

    IF l_geometry IS NULL THEN
      IF l_debug
      THEN
        debug('l_geometry is null', l_api_name, fnd_log.level_statement);
      END IF;
      l_longitude := NULL;
      l_latitude  := NULL;
    ELSE
      csf_locus_pub.verify_locus(
                  p_api_version       => 1.0
                , x_msg_count         => l_msg_count
                , x_msg_data          => l_msg_data
                , x_return_status     => l_return_status
                , p_locus             => l_geometry
                , x_result            => l_valid_geo
                );

                IF l_valid_geo = 'FALSE' THEN
                  l_longitude := NULL;
                  l_latitude  := NULL;
                  IF l_debug
                  THEN
                    debug('l_geometry is FALSE', l_api_name, fnd_log.level_statement);
                  END IF;
                ELSE
                  l_longitude := l_geometry.sdo_ordinates(1);
                  l_latitude  := l_geometry.sdo_ordinates(2);
                  IF l_debug
                  THEN
                    debug('Longitude : '||l_longitude, l_api_name, fnd_log.level_statement);
                    debug('Latitude : '||l_latitude, l_api_name, fnd_log.level_statement);
                  END IF;
                END IF;
    END IF;
    IF l_debug
    THEN
          debug('Object Capacity ID : '||c_trip_rec.object_capacity_id, l_api_name, fnd_log.level_statement);
    END IF;
    FOR i in c_task_info(c_trip_rec.object_capacity_id,c_trip_rec.task_id)
    LOOP
        IF l_debug
        THEN
          debug('TaskId  in the trip : '||i.task_id, l_api_name, fnd_log.level_statement);
        END IF;
        open c_site_info(i.task_id);
        fetch c_site_info into l_task_id,l_customer_id,l_address_id;
        close c_site_info;

        IF l_debug
        THEN
          debug('TaskId : '||i.task_id||', Customer id :'||l_customer_id||', Address Id: '||l_address_id, l_api_name, fnd_log.level_statement);
        END IF;

        --Get Geo code of the task in the trip
  	    OPEN c_task_geometry(i.task_id);
        FETCH c_task_geometry INTO t_geometry;
        CLOSE c_task_geometry;

    		IF t_geometry IS NULL THEN
    		  t_longitude := NULL;
    		  t_latitude  := NULL;
    		   IF l_debug
           THEN
             debug('t_geometry is NULL', l_api_name, fnd_log.level_statement);
           END IF;
    		ELSE
    			csf_locus_pub.verify_locus(
    			  p_api_version       => 1.0
    			, x_msg_count         => l_msg_count
    			, x_msg_data          => l_msg_data
    			, x_return_status     => l_return_status
    			, p_locus             => t_geometry
    			, x_result            => l_valid_geo
    			);


    			IF l_valid_geo = 'FALSE' THEN
    			  t_longitude := NULL;
    			  t_latitude  := NULL;
    			 IF l_debug
           THEN
             debug('l_valid_geo is false', l_api_name, fnd_log.level_statement);
           END IF;
    			ELSE
    			  t_longitude := t_geometry.sdo_ordinates(1);
            t_latitude  := t_geometry.sdo_ordinates(2);
            IF l_debug
            THEN
                    debug('Longitude of tasks in the trip: '||t_longitude, l_api_name, fnd_log.level_statement);
                    debug('Latitude of tasks in the trip : '||t_latitude, l_api_name, fnd_log.level_statement);
            END IF;
    			END IF;
        END IF;

        OPEN c_working;
        FETCH c_working into l_work;
        CLOSE c_working;

        IF l_debug
        THEN
            debug('Working status ID: '||l_work, l_api_name, fnd_log.level_statement);
        END IF;

        OPEN c_travel;
        FETCH c_travel into l_travel;
        CLOSE c_travel;

        IF l_debug
        THEN
            debug('Traveling status ID: '||l_travel, l_api_name, fnd_log.level_statement);
        END IF;
        IF p_assignment_status = l_work
        THEN
          IF l_debug
          THEN
            debug('assignment_status of the task: '||i.assignment_status_id, l_api_name, fnd_log.level_statement);
          END IF;
          IF i.assignment_status_id in (l_travel,l_work)
          THEN
            IF l_debug
            THEN
               debug('Already there is task with status Working or Traveling so return false ', l_api_name, fnd_log.level_statement);
               debug('Out parameter p_task:'||i.task_id, l_api_name, fnd_log.level_statement);
            END IF;
            p_task := i.task_id;
            RETURN 'FALSE';
          END IF;
        ELSIF p_assignment_status = l_travel
        THEN
          IF l_debug
          THEN
            debug('assignment_status of the task: '||i.assignment_status_id, l_api_name, fnd_log.level_statement);
          END IF;
          IF i.assignment_status_id = l_work
          THEN
            IF l_debug
            THEN
               debug('Already there is task with status Working or Traveling so return false ', l_api_name, fnd_log.level_statement);
               debug('Out parameter p_task:'||i.task_id, l_api_name, fnd_log.level_statement);
            END IF;
            p_task := i.task_id;
            RETURN 'FALSE';
          END IF;
        END IF;

        IF i.assignment_status_id = p_assignment_status
        THEN
          IF l_debug
          THEN
             debug('Customer ID:'||c_trip_rec.customer_id||', Address ID: '||c_trip_rec.address_id, l_api_name, fnd_log.level_statement);
          END IF;

          IF c_trip_rec.customer_id = l_customer_id and c_trip_rec.address_id = l_address_id
          THEN
            IF l_debug
            THEN
               debug('Already there is task with status Working or Traveling so return false', l_api_name, fnd_log.level_statement);
            END IF;
            RETURN 'TRUE';
          ELSE
          		 l_geocode := 'Y';
          END IF;

          IF l_geocode = 'Y'
      		THEN
        		 IF l_longitude = t_longitude and l_latitude = t_latitude
        		 THEN
        		   IF l_debug
               THEN
                  debug('G-code of the tasks are equal', l_api_name, fnd_log.level_statement);
               END IF;
        		   RETURN 'TRUE';
        		 ELSE
               IF l_debug
               THEN
                  debug('G-code of the tasks are not equal', l_api_name, fnd_log.level_statement);
                  debug('Out parameter p_task:'||i.task_id, l_api_name, fnd_log.level_statement);
               END IF;
               p_task := i.task_id;
               RETURN 'FALSE';
             END IF;
          END IF;
        END IF;
    END LOOP;
   IF c_task_info%isopen
   THEN
    close c_task_info;
   end IF;
  RETURN 'TRUE';
 EXCEPTION
 WHEN others THEN
  IF l_debug
  THEN
      debug('Exception encountered: '||substr(sqlerrm,1,200), l_api_name, fnd_log.level_statement);
  END IF;
 IF c_task_info%isopen
 THEN
    close c_task_info;
 END IF;
 debug('Out parameter p_task:'||p_task, l_api_name, fnd_log.level_statement);
 RETURN 'FALSE';

 END;


 PROCEDURE cross_task_validation (x_return_status out nocopy varchar2)
IS
l_task_assignment_id       NUMBER;
l_assignment_status         NUMBER;
l_task                     NUMBER;
l_task_update              VARCHAR2(10);
l_task_id                  NUMBER;
l_task_number              NUMBER;
l_task_name               VARCHAR2(200);
l_api_name   constant varchar2(30) := 'CROSS_TASK_VALIDATION';
CURSOR c_cross_task(p_sched_start_date date, p_sched_end_date date)
IS
      select jtB.TASK_status_id,jtb.validation_start_date,jtb.validation_end_date
      from  jtf_task_statuses_b jtb
      where  jtb.enforce_validation_flag = 'Y'
      and nvl(jtb.validation_start_date,nvl(trunc(p_sched_start_date),sysdate)) <= nvl(trunc(p_sched_start_date),sysdate)
      and nvl(jtb.validation_end_date,nvl(trunc(p_sched_end_date),sysdate)) >= nvl(trunc(p_sched_end_date),sysdate);


   cursor c_scheduled_dates(p_task_id number)
    IS
    select scheduled_start_date, scheduled_end_date
    from jtf_tasks_b
    where task_id =p_task_id
    and nvl(deleted_flag,'N')<>'Y';

    cursor c_Task_number(l_task number)
    is
     select task_number
     from jtf_tasks_b
     where task_id=l_task;

    cursor c_task_status(l_task number)
    is
    select name
    from jtf_task_statuses_tl jl,jtf_tasks_b jb
    where jl.task_status_id=jb.task_status_id
      and jb.task_id = l_task
    and language=userenv('lang');

    scheduled_dates c_scheduled_dates%rowtype;

BEGIN

   l_task_id            := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_id;
   l_task_assignment_id := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.task_assignment_id;
   l_assignment_status  := JTF_TASK_ASSIGNMENTS_PUB.p_task_assignments_user_hooks.assignment_status_id;

   open c_scheduled_dates(l_task_id);
   fetch c_scheduled_dates into scheduled_dates;
   close c_scheduled_dates;

   FOR i IN c_cross_task(scheduled_dates.scheduled_start_date,scheduled_dates.scheduled_end_date)
   LOOP

     IF i.task_status_id = l_assignment_status
     THEN
             l_task_update := cross_task_val(l_task_assignment_id,l_assignment_status,l_task);
             IF l_task_update = 'FALSE'
             THEN
                 open c_task_number(l_task);
                 fetch c_task_number into l_task_number;
                 close c_task_number;
                 open c_task_status(l_task);
                 fetch c_task_status into l_task_name;
                 close c_task_status;
                  fnd_message.set_name('CSF','CSF_CROSSTASK_VALIDATION');
                  fnd_message.set_token('TASK_NUMBER',l_task_number);
                  fnd_message.set_token('TASK_ASSIGNMENT_STATUS',l_task_name);
                  --fnd_message.set_token('TRIP_START_DATE',TO_CHAR(L_TRIP_START,'DD/MM/YYYY HH24:MI:SS'));
                  fnd_msg_pub.add;
                  raise fnd_api.g_exc_error;
             END IF;
      END IF;
    END LOOP;
  x_return_status  := fnd_api.g_ret_sts_success;
EXCEPTION
   WHEN others THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
       THEN
         fnd_msg_pub.add_exc_msg ( g_pkg_name, l_api_name );
       END IF;

END;

END csf_task_assignments_pub;



/
