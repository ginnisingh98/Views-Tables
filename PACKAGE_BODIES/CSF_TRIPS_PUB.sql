--------------------------------------------------------
--  DDL for Package Body CSF_TRIPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_TRIPS_PUB" AS
  /* $Header: CSFPTRPB.pls 120.19.12010000.31 2010/04/08 11:54:09 ramchint ship $ */

 g_pkg_name           CONSTANT VARCHAR2(30) := 'CSF_TRIPS_PUB';
  g_debug                       VARCHAR2(1);
  g_debug_level                 NUMBER;
  g_level_cp_output    CONSTANT NUMBER       := fnd_log.level_unexpected + 1;

  g_hours_in_day       CONSTANT NUMBER       := 24;
  g_mins_in_day        CONSTANT NUMBER       := 24 * 60;
  g_secs_in_day        CONSTANT NUMBER       := 24 * 60 * 60;

  g_dep_task_type_id   CONSTANT NUMBER       := 20;
  g_arr_task_type_id   CONSTANT NUMBER       := 21;
  g_dep_task_name               VARCHAR2(30);
  g_arr_task_name               VARCHAR2(30);

  g_tz_enabled                  VARCHAR2(1);
  g_server_tz_code              fnd_timezones_b.timezone_code%TYPE;
  g_client_tz_code              fnd_timezones_b.timezone_code%TYPE;
  g_datetime_fmt_mask           fnd_profile_option_values.profile_option_value%TYPE;
  g_duration_uom                mtl_uom_conversions.uom_code%TYPE;
  g_overtime                    NUMBER;

  g_assigned_status_id          NUMBER;
  g_planned_status_id           NUMBER;
  g_blocked_planned_status_id   NUMBER;
  g_blocked_assigned_status_id  NUMBER;
  g_closed_status_id            NUMBER;
  g_res_add_prof                VARCHAR2(200);
  G_SHIFT_TYPE                  VARCHAR2(200);
  TYPE message_rec_type IS RECORD(
    message_name    fnd_new_messages.message_name%TYPE
  , message_type    VARCHAR2(1)
  , resource_id     NUMBER
  , resource_type   jtf_objects_b.object_code%TYPE
  , start_datetime  DATE
  , end_datetime    DATE
  , trip_id         NUMBER
  , error_reason    fnd_new_messages.message_text%TYPE
  );

  TYPE message_tbl_type IS TABLE OF message_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE number_tbl_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  g_error_message      CONSTANT VARCHAR2(1) := 'E';
  g_warning_message    CONSTANT VARCHAR2(1) := 'W';
  g_success_message    CONSTANT VARCHAR2(1) := 'S';

  g_messages           message_tbl_type;
  g_suppress_res_info  BOOLEAN;


  FUNCTION check_dst(p_resource_id IN number ,p_start_server IN date,p_end_server IN date)
  RETURN VARCHAR2;
  Function Get_Res_Timezone_Id ( P_Resource_Id IN Number ) RETURN Number;
  Function ServerDT_To_ResourceDt ( P_Server_DtTime IN date, P_Server_TZ_Id IN Number , p_Resource_TZ_id IN Number ) RETURN date;

  PROCEDURE check_dangling_tasks(p_resource_tbl IN csf_resource_pub.resource_tbl_type
                              , p_start                 IN           DATE
                              , p_end                   IN           DATE
                              , x_return_status         OUT  NOCOPY  VARCHAR2
                              , x_msg_data              OUT  NOCOPY  VARCHAR2
                              , x_msg_count             OUT  NOCOPY  NUMBER);

  PROCEDURE check_duplicate_tasks(p_resource_tbl IN csf_resource_pub.resource_tbl_type
                              , p_start                 IN           DATE
                              , p_end                   IN           DATE
                              , x_return_status         OUT  NOCOPY  VARCHAR2
                              , x_msg_data              OUT  NOCOPY  VARCHAR2
                              , x_msg_count             OUT  NOCOPY  NUMBER);
  /******************************************************************************************
  *                                                                                         *
  *                          Private Utility Functions and Procedures                       *
  *                                                                                         *
  *******************************************************************************************/

  PROCEDURE debug(p_message VARCHAR2, p_module VARCHAR2, p_level NUMBER) IS
  BEGIN
    IF p_level = g_level_cp_output AND fnd_file.output > 0 THEN
      fnd_file.put_line(fnd_file.output, p_message);
    END IF;

    IF g_debug = 'Y' AND p_level >= g_debug_level THEN
      IF fnd_file.log > 0 THEN
        IF p_message = ' ' THEN
          fnd_file.put_line(fnd_file.log, '');
        ELSE
          fnd_file.put_line(fnd_file.log, rpad(p_module, 20) || ': ' || p_message);
        END IF;
      END IF;
      IF ( p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      THEN
        fnd_log.string(p_level, 'csf.plsql.CSF_TRIPS_PUB.' || p_module, p_message);
      END IF;
    END IF;
    --dbms_output.put_line(rpad(p_module, 20) || ': ' || p_message);
  END debug;

  FUNCTION format_date(p_date IN DATE, p_convert_to_client_tz VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS
    l_date DATE;
  BEGIN
    l_date := p_date;
    IF p_convert_to_client_tz IS NULL OR p_convert_to_client_tz = fnd_api.g_true THEN
      -- AOL doesnt initialize FND_DATE package properly. Refer bugs 3183418 and 3115188.
      -- Because of this, dates werent printed with TZ Conversion. Bypassing FND_DATE.
      IF g_tz_enabled = 'Y' THEN
        l_date := fnd_timezones_pvt.adjust_datetime(
                    date_time => p_date
                  , from_tz   => g_server_tz_code
                  , to_tz     => g_client_tz_code
                  );
      END IF;
    END IF;
    RETURN to_char(l_date, g_datetime_fmt_mask);
  END format_date;

  FUNCTION get_resource_info(p_resource_id NUMBER, p_resource_type VARCHAR2)
    RETURN VARCHAR2 IS
    l_resource_info csf_resource_pub.resource_rec_type;
  BEGIN
    l_resource_info := csf_resource_pub.get_resource_info(p_resource_id, p_resource_type);

    RETURN    l_resource_info.resource_name
           || ' ('
           || csf_resource_pub.get_resource_type_name(l_resource_info.resource_type)
           || ', '
           || l_resource_info.resource_number
           || ')';
  END get_resource_info;

  FUNCTION time_overlaps(p_trip trip_rec_type, p_shift csf_resource_pub.shift_rec_type)
    RETURN BOOLEAN IS
	l_api_name     CONSTANT VARCHAR2(30) := 'CHECK_TIME_OVERLAPS';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
  BEGIN
	IF l_debug THEN
		debug( ' Inside procedure CHECK TIME OVERLAP', l_api_name, fnd_log.level_statement);
		debug( ' Overtime value # '||g_overtime, l_api_name, fnd_log.level_statement);
		debug( '  Checking for overlap in trip start#' || format_date(p_trip.start_date_time)  ||
			   ' is <= shift endtime + overtime #'|| format_date(p_shift.end_datetime + g_overtime)  ||
			   ' and overlap in trip end # '||format_date(p_trip.end_date_time + g_overtime)||
			   ' is >= starttime + overtime # '||format_date(p_shift.start_datetime), l_api_name, fnd_log.level_statement);
		debug( ' Outside procedure CHECK TIME OVERLAP', l_api_name, fnd_log.level_statement);
	END IF;
    RETURN     p_trip.start_date_time <= (p_shift.end_datetime + g_overtime)
           AND (p_trip.end_date_time + g_overtime) >= p_shift.start_datetime;
  END time_overlaps;

  FUNCTION time_overlaps(p_trip trip_rec_type, p_start DATE, p_end DATE)
    RETURN BOOLEAN IS
  BEGIN
    RETURN     p_trip.start_date_time < p_end
           AND (p_trip.end_date_time + g_overtime) > p_start;
  END time_overlaps;

  PROCEDURE add_message(
    p_trip      trip_rec_type
  , p_reason    VARCHAR2       DEFAULT NULL
  , p_msg_name  VARCHAR2       DEFAULT NULL
  , p_msg_type  VARCHAR2       DEFAULT NULL
  ) IS
    i    PLS_INTEGER;
  BEGIN
    i := g_messages.COUNT + 1;
    g_messages(i).message_name   := p_msg_name;
    g_messages(i).message_type   := NVL(p_msg_type, g_success_message);
    g_messages(i).error_reason   := p_reason;
    g_messages(i).resource_id    := p_trip.resource_id;
    g_messages(i).resource_type  := p_trip.resource_type;
    g_messages(i).start_datetime := p_trip.start_date_time;
    g_messages(i).end_datetime   := p_trip.end_date_time;
    g_messages(i).trip_id        := p_trip.trip_id;
  END add_message;

  PROCEDURE add_message(
    p_res_id    NUMBER
  , p_res_type  VARCHAR2
  , p_start     DATE
  , p_end       DATE
  , p_reason    VARCHAR2       DEFAULT NULL
  , p_msg_name  VARCHAR2       DEFAULT NULL
  , p_msg_type  VARCHAR2       DEFAULT NULL
  ) IS
    i    PLS_INTEGER;
  BEGIN
    i := g_messages.COUNT + 1;
    g_messages(i).resource_id    := p_res_id;
    g_messages(i).resource_type  := p_res_type;
    g_messages(i).start_datetime := p_start;
    g_messages(i).end_datetime   := p_end;
    g_messages(i).message_name   := p_msg_name;
    g_messages(i).message_type   := NVL(p_msg_type, g_success_message);
    g_messages(i).error_reason   := p_reason;
  END add_message;

  PROCEDURE process_messages(
    p_init_msg_list    IN         VARCHAR2
  , x_return_status   OUT NOCOPY  VARCHAR2
  , p_action           IN         VARCHAR2
  , p_trip_id          IN         NUMBER
  , p_start_date       IN         DATE
  , p_end_date         IN         DATE
  , p_resource_tbl     IN         csf_resource_pub.resource_tbl_type
  ) IS
    l_debug   CONSTANT BOOLEAN := g_debug = 'Y';
    l_success          NUMBER;
    l_failed           NUMBER;
    l_action_name      fnd_flex_values_tl.flex_value_meaning%TYPE;
    l_res_name         jtf_rs_resource_extns_tl.resource_name%TYPE;

    CURSOR c_action_name IS
      SELECT v.flex_value_meaning meaning
        FROM fnd_flex_value_sets s, fnd_flex_values_vl v
       WHERE s.flex_value_set_name = 'CSF_GTR_ACTIONS'
         AND s.flex_value_set_id = v.flex_value_set_id
         AND v.flex_value = p_action;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    -- First Clear the Message Stack if the API is given the permission to clear stack.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    l_success := 0;
    l_failed  := 0;

    FOR i IN 1..g_messages.COUNT LOOP
      IF g_messages(i).message_type IN (g_error_message, g_warning_message) THEN
        fnd_message.set_name('CSF', NVL(g_messages(i).message_name, 'CSF_PROCESS_TRIP_FAILED'));

        IF g_messages(i).resource_id IS NOT NULL THEN
          IF g_suppress_res_info = TRUE THEN
            fnd_message.set_token('RESOURCE', '');
          ELSE
            fnd_message.set_token('RESOURCE', get_resource_info(g_messages(i).resource_id, g_messages(i).resource_type));
          END IF;
        END IF;

        IF g_messages(i).start_datetime IS NOT NULL THEN
          fnd_message.set_token('START_TIME', format_date(g_messages(i).start_datetime));
        END IF;

        IF g_messages(i).end_datetime IS NOT NULL THEN
          fnd_message.set_token('END_TIME', format_date(g_messages(i).end_datetime));
        END IF;

        IF g_messages(i).error_reason IS NOT NULL THEN
          fnd_message.set_token('REASON', g_messages(i).error_reason);
        END IF;

        fnd_msg_pub.ADD;

        IF g_messages(i).message_type = g_error_message THEN
          l_failed := l_failed + 1;
        ELSE
          l_success := l_success + 1;
        END IF;
      ELSE
        IF l_debug THEN
          debug(    'Trip#' || g_messages(i).trip_id
                 || ' for resource ' || get_resource_info(g_messages(i).resource_id, g_messages(i).resource_type)
                 || ' between ' || format_date(g_messages(i).start_datetime)
                 || ' and ' || format_date(g_messages(i).end_datetime)
                 || ' processed successfully'
               , 'PROCESS_ACTION'
               , fnd_log.level_event
               );
        END IF;
        l_success := l_success + 1;
      END IF;
    END LOOP;

    IF l_failed > 0 THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    -- There is only trip involved... and therefore no need to status message.
    IF p_trip_id IS NOT NULL THEN
      RETURN;
    END IF;

    OPEN c_action_name;
    FETCH c_action_name INTO l_action_name;
    CLOSE c_action_name;

    IF p_resource_tbl.COUNT = 1 THEN
      l_res_name := csf_resource_pub.get_resource_name(p_resource_tbl(1).resource_id, p_resource_tbl(1).resource_type);
    ELSE
      l_res_name := '';
    END IF;

    IF l_failed > 0 THEN
      fnd_message.set_name('CSF', 'CSF_TRIPS_ACTION_WARN');
      fnd_message.set_token('FAILED', l_failed);
    ELSE
      fnd_message.set_name('CSF', 'CSF_TRIPS_ACTION_SUCC');
    END IF;

    fnd_message.set_token('SUCCESS',    l_success);
    fnd_message.set_token('ACTION',     l_action_name);
    fnd_message.set_token('RESOURCE',   l_res_name);
    fnd_message.set_token('START_DATE', p_start_date);
    fnd_message.set_token('END_DATE',   p_end_date);
    fnd_msg_pub.ADD;
  END process_messages;

  PROCEDURE init_package IS
  BEGIN
    g_duration_uom       := fnd_profile.value('CSF_UOM_MINUTES');
    g_overtime           := NVL(CSR_SCHEDULER_PUB.GET_SCH_PARAMETER_VALUE('spMaxOvertime'), 0) / g_mins_in_day;


    g_debug              := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
    g_debug_level        := NVL(fnd_profile.value_specific('AFLOG_LEVEL'), fnd_log.level_event);
    g_datetime_fmt_mask  := NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'), 'DD-MON-YYYY') || ' HH24:MI';
    g_tz_enabled         := fnd_timezones.timezones_enabled;
    g_server_tz_code     := fnd_timezones.get_server_timezone_code;
    g_client_tz_code     := fnd_timezones.get_client_timezone_code;

    g_planned_status_id          := fnd_profile.value('CSF_DEFAULT_TASK_PLANNED_STATUS');
    g_assigned_status_id         := fnd_profile.value('CSF_DEFAULT_TASK_ASSIGNED_STATUS');
    g_blocked_planned_status_id  := fnd_profile.value('CSF_DEFAULT_TASK_BLOCKED_PLAN_STATUS');
    g_blocked_assigned_status_id := fnd_profile.value('CSF_DEFAULT_TASK_BLOCKEDASS_STATUS');
    g_closed_status_id           := fnd_profile.value('CSF_DFLT_AUTO_CLOSE_TASK_STATUS');

    SELECT name INTO g_dep_task_name
      FROM jtf_task_types_vl WHERE task_type_id = g_dep_task_type_id;

    SELECT name INTO g_arr_task_name
      FROM jtf_task_types_vl WHERE task_type_id = g_arr_task_type_id;

    --EXECUTE IMMEDIATE 'alter session set timed_statistics=true';
    --EXECUTE IMMEDIATE 'alter session set statistics_level=all';
    --EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 12''';
  EXCEPTION
    WHEN OTHERS THEN
      debug('Unable to initialize the Package - SQLCODE = ' || SQLCODE || ' : SQLERRM = ' || SQLERRM, 'INIT', fnd_log.level_unexpected);
  END;

  FUNCTION trip_has_active_tasks(p_trip_id NUMBER)
    RETURN BOOLEAN IS
    CURSOR c_active_tasks_exist IS
      SELECT 1
        FROM cac_sr_object_capacity oc
       WHERE object_capacity_id = p_trip_id
         AND EXISTS (SELECT 1
                       FROM jtf_task_assignments ta
                          , jtf_task_statuses_b ts
                          , jtf_tasks_b t
                      WHERE ta.object_capacity_id = oc.object_capacity_id
                        AND ts.task_status_id     = ta.assignment_status_id
                        AND NVL(ts.closed_flag, 'N')     = 'N'
                        AND NVL(ts.completed_flag, 'N')  = 'N'
                        AND NVL(ts.cancelled_flag, 'N')  = 'N'
                        AND NVL(ts.rejected_flag, 'N')   = 'N'
                        AND t.task_id                    = ta.task_id
                        AND NVL(t.deleted_flag, 'N')     = 'N'
                        AND t.task_type_id NOT IN (20, 21));
    l_result NUMBER;
  BEGIN
    OPEN c_active_tasks_exist;
    FETCH c_active_tasks_exist INTO l_result;
    CLOSE c_active_tasks_exist;

    RETURN l_result IS NOT NULL;
  END trip_has_active_tasks;

  -- Returns all the Trips which overlaps with the Passed Timings for the Resource
  FUNCTION find_trips(
    p_resource_tbl     IN    csf_resource_pub.resource_tbl_type
  , p_start_date_time  IN    DATE
  , p_end_date_time    IN    DATE
  , p_overtime_flag    IN    VARCHAR2 DEFAULT NULL
  ) RETURN trip_tbl_type IS

    l_trips_count     NUMBER;
    l_trips           trip_tbl_type;
    l_overtime        NUMBER;
    i                 PLS_INTEGER;

    CURSOR c_trips (p_resource_id NUMBER, p_resource_type VARCHAR2) IS
      SELECT *
        FROM cac_sr_object_capacity
       WHERE object_id   = p_resource_id
         AND object_type = p_resource_type
         AND p_start_date_time <= (end_date_time + l_overtime)
         AND p_end_date_time >= start_date_time
       ORDER BY start_date_time, object_capacity_id;

  BEGIN
    l_overtime := 0;
    IF p_overtime_flag IS NULL OR p_overtime_flag = fnd_api.g_true THEN
      l_overtime := g_overtime;
    END IF;

    l_trips_count := 0;

    i := p_resource_tbl.FIRST;
    -- Find Trips for each resource and add it to the output table.
    WHILE i IS NOT NULL LOOP
      -- Loop through all the Trips found for the criteria specified.
      FOR v_trip IN c_trips(p_resource_tbl(i).resource_id, p_resource_tbl(i).resource_type) LOOP
        l_trips_count := l_trips_count + 1;

        l_trips(l_trips_count).trip_id                := v_trip.object_capacity_id;
        l_trips(l_trips_count).object_version_number  := v_trip.object_version_number;
        l_trips(l_trips_count).resource_type          := v_trip.object_type;
        l_trips(l_trips_count).resource_id            := v_trip.object_id;
        l_trips(l_trips_count).start_date_time        := v_trip.start_date_time;
        l_trips(l_trips_count).end_date_time          := v_trip.end_date_time;
        l_trips(l_trips_count).available_hours        := v_trip.available_hours;
        l_trips(l_trips_count).available_hours_before := v_trip.available_hours_before;
        l_trips(l_trips_count).available_hours_after  := v_trip.available_hours_after;
        l_trips(l_trips_count).schedule_detail_id     := v_trip.schedule_detail_id;
        l_trips(l_trips_count).status                 := v_trip.status;
        l_trips(l_trips_count).availability_type      := v_trip.availability_type;
      END LOOP;

      i := p_resource_tbl.NEXT(i);
    END LOOP;

    RETURN l_trips;
  END find_trips;

  FUNCTION get_trip(p_trip_id IN NUMBER) RETURN trip_rec_type AS
    l_trip trip_rec_type;
    CURSOR c_trip IS
      SELECT *
        FROM cac_sr_object_capacity
       WHERE object_capacity_id = p_trip_id;
  BEGIN
    FOR v_trip IN c_trip LOOP
      l_trip.trip_id                := v_trip.object_capacity_id;
      l_trip.object_version_number  := v_trip.object_version_number;
      l_trip.resource_type          := v_trip.object_type;
      l_trip.resource_id            := v_trip.object_id;
      l_trip.start_date_time        := v_trip.start_date_time;
      l_trip.end_date_time          := v_trip.end_date_time;
      l_trip.available_hours        := v_trip.available_hours;
      l_trip.available_hours_before := v_trip.available_hours_before;
      l_trip.available_hours_after  := v_trip.available_hours_after;
      l_trip.schedule_detail_id     := v_trip.schedule_detail_id;
      l_trip.status                 := v_trip.status;
      l_trip.availability_type := v_trip.availability_type;
    END LOOP;

    RETURN l_trip;
  END get_trip;

  PROCEDURE create_shift_tasks(
    p_api_version          IN          NUMBER
  , p_init_msg_list        IN          VARCHAR2 DEFAULT NULL
  , p_commit               IN          VARCHAR2 DEFAULT NULL
  , x_return_status       OUT  NOCOPY  VARCHAR2
  , x_msg_data            OUT  NOCOPY  VARCHAR2
  , x_msg_count           OUT  NOCOPY  NUMBER
  , p_resource_id          IN          NUMBER
  , p_resource_type        IN          VARCHAR2
  , p_start_date_time      IN          DATE
  , p_end_date_time        IN          DATE
  , p_create_dep_task      IN          BOOLEAN
  , p_create_arr_task      IN          BOOLEAN
  , p_res_shift_add        IN          VARCHAR2 default null
  , x_dep_task_id         OUT NOCOPY   NUMBER
  , x_arr_task_id         OUT NOCOPY   NUMBER
  ) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_SHIFT_TASKS';
    l_debug           CONSTANT BOOLEAN  := g_debug = 'Y';
    l_address         csf_resource_address_pvt.address_rec_type;
    l_task_assign_tbl jtf_tasks_pub.task_assign_tbl;

    CURSOR c_obj_capacity_det
    IS
     select object_id,object_type,start_date_time,end_date_time
     from cac_sr_object_capacity
     where object_id = p_resource_id
       and object_type = p_resource_type
       and start_date_time = p_start_date_time
       and end_date_time = p_end_date_time;

    l_row_obj_cap c_obj_capacity_det%rowtype;
  BEGIN

    IF p_create_dep_task = FALSE AND p_create_arr_task = FALSE THEN
      RETURN;
    END IF;

    -- Get the Resource's Address for this Date
    l_address := csf_resource_pub.get_resource_party_address(
                         p_res_id   => p_resource_id
                       , p_res_type => p_resource_type
                       , p_date     => p_start_date_time
                       ,  p_res_shift_add => g_res_add_prof
                       );

    IF l_debug THEN
      debug('    Got the Party Site ID ' || l_address.party_site_id || ' for the resource on ' || p_start_date_time, l_api_name, fnd_log.level_statement);
    END IF;

    IF l_address.party_site_id IS NULL THEN
      IF l_debug THEN
        x_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
        debug('    CSF_RESOURCE_ADDRESS_PVT failed to give Party Site ID' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_RESOURCE_NO_ACTIVE_PARTY');
      fnd_message.set_token('RESOURCE', get_resource_info(p_resource_id, p_resource_type));
      fnd_message.set_token('DATE', format_date(p_start_date_time));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Departure and Arrival Task Resource Assignment
    l_task_assign_tbl(1).resource_id          := p_resource_id;
    l_task_assign_tbl(1).resource_type_code   := p_resource_type;
    l_task_assign_tbl(1).assignment_status_id := g_assigned_status_id;



    -- Create the Departure Task
    IF p_create_dep_task THEN

     open c_obj_capacity_det;
     fetch c_obj_capacity_det into l_row_obj_cap;
     close c_obj_capacity_det;

     IF l_row_obj_cap.start_date_time is null
     THEN

      jtf_tasks_pub.create_task(
        p_api_version                => 1.0
      , p_task_name                  => g_dep_task_name
      , p_task_type_id               => g_dep_task_type_id
      , p_task_status_id             => g_assigned_status_id
      , p_owner_id                   => p_resource_id
      , p_owner_type_code            => p_resource_type
      , p_address_id                 => l_address.party_site_id
      , p_customer_id                => l_address.party_id
      , p_planned_start_date         => p_start_date_time
      , p_planned_end_date           => p_start_date_time
      , p_scheduled_start_date       => p_start_date_time
      , p_scheduled_end_date         => p_start_date_time
      , p_duration                   => 0
      , p_duration_uom               => g_duration_uom
      , p_bound_mode_code            => 'BTS'
      , p_soft_bound_flag            => 'Y'
      , p_task_assign_tbl            => l_task_assign_tbl
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_id                    => x_dep_task_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('CSF', 'CSF_TASK_CREATE_FAIL');
        fnd_message.set_token('TASK_NAME', g_dep_task_name);
        fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
        fnd_msg_pub.ADD;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_debug THEN
        debug('    Created Departure Task - Task ID = ' || x_dep_task_id, l_api_name, fnd_log.level_statement);
      END IF;
      END IF; -- end if for l_row_obj_cap
    END IF;

    -- Create the Arrival Task
    IF p_create_arr_task THEN

    open c_obj_capacity_det;
     fetch c_obj_capacity_det into l_row_obj_cap;
     close c_obj_capacity_det;

     IF l_row_obj_cap.end_date_time is  null
     THEN

      jtf_tasks_pub.create_task(
        p_api_version                => 1.0
      , p_task_name                  => g_arr_task_name
      , p_task_type_id               => g_arr_task_type_id
      , p_task_status_id             => g_assigned_status_id
      , p_owner_id                   => p_resource_id
      , p_owner_type_code            => p_resource_type
      , p_address_id                 => l_address.party_site_id
      , p_customer_id                => l_address.party_id
      , p_planned_start_date         => p_end_date_time
      , p_planned_end_date           => p_end_date_time
      , p_scheduled_start_date       => p_end_date_time
      , p_scheduled_end_date         => p_end_date_time
      , p_duration                   => 0
      , p_duration_uom               => g_duration_uom
      , p_bound_mode_code            => 'BTS'
      , p_soft_bound_flag            => 'Y'
      , p_task_assign_tbl            => l_task_assign_tbl
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_id                    => x_arr_task_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('CSF', 'CSF_TASK_CREATE_FAIL');
        fnd_message.set_token('TASK_NAME', g_arr_task_name);
        fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
        fnd_msg_pub.ADD;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_debug THEN
        debug('    Created Arrival Task - Task ID = ' || x_arr_task_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;-- end if for l_row_obj_cap
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      if SQLCODE =1 then
        x_return_status := fnd_api.g_ret_sts_error;
      else
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      end if;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END create_shift_tasks;

  FUNCTION get_new_task_status(p_action VARCHAR2, p_current_status NUMBER)
    RETURN NUMBER IS
  BEGIN
    IF p_action = g_action_block_trip THEN
      IF p_current_status = g_planned_status_id THEN
        RETURN g_blocked_planned_status_id;
      ELSIF p_current_status = g_assigned_status_id THEN
        RETURN g_blocked_assigned_status_id;
      ELSE
        RETURN NULL;
      END IF;
    ELSIF p_action = g_action_unblock_trip THEN
      IF p_current_status = g_blocked_planned_status_id THEN
        RETURN g_planned_status_id;
      ELSIF p_current_status = g_blocked_assigned_status_id THEN
        RETURN g_assigned_status_id;
      ELSE
        RETURN NULL;
      END IF;
    ELSIF p_action = g_action_close_trip THEN
      RETURN g_closed_status_id;
    ELSE
      RETURN NULL;
    END IF;
  END get_new_task_status;

  PROCEDURE new_trip(
    x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_resource_id           IN          NUMBER
  , p_resource_type         IN          VARCHAR2
  , p_start_date_time       IN          DATE
  , p_end_date_time         IN          DATE
  , p_status                IN          NUMBER    DEFAULT NULL
  , p_schedule_detail_id    IN          NUMBER    DEFAULT NULL
  , p_find_tasks            IN          VARCHAR2  DEFAULT NULL
  , p_dep_task_id           IN          NUMBER    DEFAULT NULL
  , p_arr_task_id           IN          NUMBER    DEFAULT NULL
  , x_trip                 OUT  NOCOPY  trip_rec_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'NEW_TRIP';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    CURSOR c_linkable_tasks IS
      SELECT ta.task_assignment_id
           , ta.object_version_number
           , ta.task_id
           , ta.booking_start_date
           , ta.booking_end_date
           , csf_util_pvt.convert_to_minutes(
               ta.sched_travel_duration
             , ta.sched_travel_duration_uom
             ) travel_time
        FROM jtf_task_assignments ta
           , jtf_task_statuses_b ts
           , jtf_tasks_b t
       WHERE ta.resource_id               = p_resource_id
         AND ta.resource_type_code        = p_resource_type
         AND ta.assignee_role             = 'ASSIGNEE'
         AND ts.task_status_id            = ta.assignment_status_id
         AND NVL(ts.closed_flag, 'N')     = 'N'
         AND NVL(ts.completed_flag, 'N')  = 'N'
         AND NVL(ts.cancelled_flag, 'N')  = 'N'
         AND t.task_id = ta.task_id
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND ta.booking_start_date <= (p_end_date_time + g_overtime)
         AND ta.booking_end_date   >= p_start_date_time;

    l_available_hours       NUMBER;
    l_time_occupied         NUMBER;
    l_dep_task_id           NUMBER;
    l_arr_task_id           NUMBER;
    i                       PLS_INTEGER;
    l_object_capacity_tbl   cac_sr_object_capacity_pub.object_capacity_tbl_type;
    l_object_tasks_tbl      cac_sr_object_capacity_pub.object_tasks_tbl_type;
  BEGIN
    SAVEPOINT csf_new_trip;

    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('  Creating Trip between ' || format_date(p_start_date_time) || ' and ' || format_date(p_end_date_time), l_api_name, fnd_log.level_statement);
    END IF;

    -- Trip Available Hours
    l_available_hours := (p_end_date_time - p_start_date_time) * g_hours_in_day;

    -- Check#3 - The Trip Duration should be lesser than 24 Hours.
   IF l_available_hours > g_hours_in_day THEN
     IF check_dst(p_resource_id,p_start_date_time,p_end_date_time) = 'FALSE'
     THEN
      IF l_debug THEN
        debug('  The specified Trip Length is greater than one day', l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_TRIP_LENGTH_MORE_THAN_DAY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
     END IF;

    END IF;


    -- Create new Shift Tasks for the Trip to be created.
    IF p_dep_task_id IS NULL OR p_arr_task_id IS NULL THEN
      create_shift_tasks(
        p_api_version         => 1.0
      , p_init_msg_list       => fnd_api.g_false
      , p_commit              => fnd_api.g_false
      , x_return_status       => x_return_status
      , x_msg_data            => x_msg_data
      , x_msg_count           => x_msg_count
      , p_resource_id         => p_resource_id
      , p_resource_type       => p_resource_type
      , p_start_date_time     => p_start_date_time
      , p_end_date_time       => p_end_date_time
      , p_create_dep_task     => p_dep_task_id IS NULL
      , p_create_arr_task     => p_arr_task_id IS NULL
      , x_dep_task_id         => l_dep_task_id
      , x_arr_task_id         => l_arr_task_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          debug('    Unable to Create Shift Tasks: Error = ' || x_msg_data, l_api_name, fnd_log.level_error);
        END IF;
        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
      IF l_debug THEN
        debug('    Created new Shift Tasks - Dep#' || l_dep_task_id || ' : Arr#' || l_arr_task_id, l_api_name, fnd_log.level_statement);
      END IF;
      l_dep_task_id := NVL(p_dep_task_id, l_dep_task_id);
      l_arr_task_id := NVL(p_arr_task_id, l_arr_task_id);
    ELSE
      -- Use the existing ones.
      l_dep_task_id := p_dep_task_id;
      l_arr_task_id := p_arr_task_id;
      IF l_debug THEN
        debug('    Using existing Shift Tasks - Dep#' || l_dep_task_id || ' : Arr#' || l_arr_task_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;
    IF l_dep_task_id  IS NOT NULL AND l_arr_task_id IS NOT NULL
	THEN
			IF p_find_tasks IS NULL OR p_find_tasks = fnd_api.g_true THEN
			  i := 1;
			  FOR v_task IN c_linkable_tasks LOOP
				l_time_occupied   := v_task.booking_end_date - v_task.booking_start_date; -- Scheduled Task Duration
				l_time_occupied   := l_time_occupied + NVL(v_task.travel_time, 0) / g_mins_in_day; -- Scheduled Travel Duration
				l_available_hours := l_available_hours - l_time_occupied * g_hours_in_day;

				IF l_debug THEN
				  debug('    Linking TaskID #' || v_task.task_id || ' : Time Used = ' || l_time_occupied * g_hours_in_day, l_api_name, fnd_log.level_statement);
				END IF;

				l_object_tasks_tbl(i).task_assignment_id      := v_task.task_assignment_id;
				l_object_tasks_tbl(i).task_assignment_ovn     := v_task.object_version_number;
				l_object_tasks_tbl(i).object_capacity_tbl_idx := 1;
				i := i + 1;
			  END LOOP;
			ELSE

			  l_object_tasks_tbl(1).task_assignment_id      := l_dep_task_id;
			  l_object_tasks_tbl(1).object_capacity_tbl_idx := 1;
			  l_object_tasks_tbl(2).task_assignment_id      := l_arr_task_id;
			  l_object_tasks_tbl(2).object_capacity_tbl_idx := 1;
			END IF;

			-- Create the Object Capacity Record
			l_object_capacity_tbl(1).object_type        := p_resource_type;
			l_object_capacity_tbl(1).object_id          := p_resource_id;
			l_object_capacity_tbl(1).start_date_time    := p_start_date_time;
			l_object_capacity_tbl(1).end_date_time      := p_end_date_time;
			l_object_capacity_tbl(1).available_hours    := l_available_hours;
			l_object_capacity_tbl(1).status             := p_status;
			l_object_capacity_tbl(1).schedule_detail_id := p_schedule_detail_id;
		    l_object_capacity_tbl(1).availability_type   := g_shift_type;

			IF l_debug THEN
			  debug('    Trip Available Hours = ' || l_available_hours, l_api_name, fnd_log.level_statement);
			END IF;
			IF l_debug THEN
			   debug('  No departure Arrival for dates ' || format_date(p_start_date_time) || ' and ' || format_date(p_end_date_time), l_api_name, fnd_log.level_statement);
			   debug('  No departure Arrival for Resource ' || p_resource_id || ' and Resource Type' ||p_resource_type , l_api_name, fnd_log.level_statement);
			END IF;

			-- Create the Trip by calling Object Capacity Table Handlers
			cac_sr_object_capacity_pub.insert_object_capacity(
			  p_api_version          =>  1.0
			, p_init_msg_list        =>  fnd_api.g_false
			, x_return_status        =>  x_return_status
			, x_msg_count            =>  x_msg_count
			, x_msg_data             =>  x_msg_data
			, p_object_capacity      =>  l_object_capacity_tbl
			, p_update_tasks         =>  fnd_api.g_true
			, p_object_tasks         =>  l_object_tasks_tbl
			);

			IF x_return_status <> fnd_api.g_ret_sts_success THEN
			  IF l_debug THEN
				x_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
				debug('  Unable to Create the Object Capacity: Error = ' || x_msg_data, l_api_name, fnd_log.level_error);
			  END IF;
			  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
				RAISE fnd_api.g_exc_unexpected_error;
			  END IF;
			  RAISE fnd_api.g_exc_error;
			END IF;

			x_trip.trip_id               := l_object_capacity_tbl(1).object_capacity_id;
			x_trip.object_version_number := 1;
			x_trip.resource_id           := p_resource_id;
			x_trip.resource_type         := p_resource_type;
			x_trip.start_date_time       := p_start_date_time;
			x_trip.end_date_time         := p_end_date_time;
			x_trip.available_hours       := l_available_hours;
			x_trip.status                := p_status;
			x_trip.schedule_detail_id    := p_schedule_detail_id;

			IF l_debug THEN
			  debug('  Created Trip - TripID#' || x_trip.trip_id, l_api_name, fnd_log.level_statement);
			END IF;
	ELSE
	    IF l_debug THEN
			debug('  No departure Arrival for dates ' || format_date(p_start_date_time) || ' and ' || format_date(p_end_date_time), l_api_name, fnd_log.level_statement);
			debug('  No departure Arrival for Resource ' || p_resource_id || ' and Resource Type' ||p_resource_type , l_api_name, fnd_log.level_statement);
		END IF;

	END IF; --END IF FOR l_dep_task_id is null

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_new_trip;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
     debug('Unepected error occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      ROLLBACK TO csf_new_trip;
      if SQLCODE =1 then
        x_return_status := fnd_api.g_ret_sts_error;
      else
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      end if;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
      ROLLBACK TO csf_new_trip;
  END new_trip;

  PROCEDURE change_trip(
    x_return_status           OUT  NOCOPY  VARCHAR2
  , x_msg_data                OUT  NOCOPY  VARCHAR2
  , x_msg_count               OUT  NOCOPY  NUMBER
  , p_trip                     IN          trip_rec_type
  , p_object_version_number    IN          NUMBER
  , p_available_hours          IN          NUMBER          DEFAULT NULL
  , p_upd_available_hours      IN          NUMBER          DEFAULT NULL
  , p_available_hours_before   IN          NUMBER          DEFAULT NULL
  , p_available_hours_after    IN          NUMBER          DEFAULT NULL
  , p_status                   IN          NUMBER          DEFAULT NULL
  , p_availability_type        IN          VARCHAR2        DEFAULT NULL
  , p_update_tasks             IN          VARCHAR2        DEFAULT NULL
  , p_task_action              IN          VARCHAR2        DEFAULT NULL
   , p_start_date               IN          DATE            DEFAULT NULL
  , p_end_date                 IN          DATE            DEFAULT NULL
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'CHANGE_TRIP';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_new_task_status        NUMBER;
    l_shift_length           NUMBER;
    l_available_hours        NUMBER;
    l_available_hours_before NUMBER;
    l_available_hours_after  NUMBER;

    CURSOR c_tasks (p_task_type VARCHAR2) IS
      SELECT ta.task_assignment_id
           , ta.object_version_number ta_object_version_number
           , ta.assignment_status_id
           , t.task_id
           , t.task_number
           , t.object_version_number task_ovn
           , t.task_status_id
        FROM cac_sr_object_capacity cac
           , jtf_task_assignments ta
           , jtf_tasks_b t
           , jtf_task_statuses_b ts
       WHERE cac.object_capacity_id = p_trip.trip_id
         AND ta.resource_id         = cac.object_id
         AND ta.resource_type_code  = cac.object_type
         AND ( (ta.object_capacity_id IS NOT NULL AND ta.object_capacity_id = cac.object_capacity_id)
              OR (ta.booking_start_date  <= (cac.end_date_time + g_overtime) AND ta.booking_end_date >= cac.start_date_time) )
         AND t.task_id              = ta.task_id
         AND ts.task_status_id      = ta.assignment_status_id
         AND NVL(ts.closed_flag, 'N')    = 'N'
         AND NVL(ts.completed_flag, 'N') = 'N'
         AND NVL(ts.cancelled_flag, 'N') = 'N'
         AND NVL(ts.working_flag, 'N')   = 'N'
         AND NVL(t.deleted_flag, 'N')    = 'N'
         AND ta.actual_start_date IS NULL
         AND (t.source_object_type_code = 'SR' OR t.task_type_id IN (20, 21))
         AND (p_task_type = 'ALL' OR t.task_type_id IN (20, 21));

    l_task_type        VARCHAR2(10);
    l_validation_level NUMBER;

  BEGIN
    SAVEPOINT csf_change_trip;

    x_return_status := fnd_api.g_ret_sts_success;

    l_shift_length           := (p_trip.end_date_time - p_trip.start_date_time) * g_hours_in_day;
    l_available_hours        := p_trip.available_hours;
    l_available_hours_before := p_trip.available_hours_before;
    l_available_hours_after  := p_trip.available_hours_after;

    IF p_available_hours IS NOT NULL THEN
      l_available_hours := p_available_hours;
    ELSIF p_upd_available_hours IS NOT NULL THEN
      l_available_hours := p_trip.available_hours + p_upd_available_hours;
    END IF;

    -- If Available Hours (either as value or as inc/dec) is passed, and Avl Before/After
    -- is not passed, they should be nulled out.
    IF p_available_hours IS NOT NULL OR p_upd_available_hours IS NOT NULL THEN
      l_available_hours_before := NVL(p_available_hours_before, fnd_api.g_miss_num);
      l_available_hours_after  := NVL(p_available_hours_after, fnd_api.g_miss_num);
    ELSE
      l_available_hours_before := p_available_hours_before;
      l_available_hours_after  := p_available_hours_after;
    END IF;

   /* IF    l_available_hours > l_shift_length
       OR (l_available_hours_before <> fnd_api.g_miss_num AND l_available_hours_before > l_shift_length)
       OR (l_available_hours_after <> fnd_api.g_miss_num AND l_available_hours_after > l_shift_length)
    THEN
      -- Trip Availability is more than the Shift Length
      IF l_debug THEN
        debug('  Trip Availability is more than Shift Length', l_api_name, fnd_log.level_error);
      END IF;

      fnd_message.set_name('CSF', 'CSF_TRIP_WRONG_AVAILABILITY');
      fnd_message.set_token('AVAILABLE', l_available_hours);
      fnd_message.set_token('AVLBEFORE', l_available_hours_before);
      fnd_message.set_token('AVLAFTER', l_available_hours_after);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;*/

    IF l_available_hours = l_shift_length
      AND (    ( l_available_hours_before IS NOT NULL AND l_available_hours_before <> fnd_api.g_miss_num )
            OR ( l_available_hours_after IS NOT NULL AND l_available_hours_after <> fnd_api.g_miss_num )
      )
    THEN
      -- Trip Availability is equal to the Shift Length and Before and Afters are not NULL
      IF l_debug THEN
        debug('  Available Hours Before and After must be NULL when Availability is Trip Length', l_api_name, fnd_log.level_error);
      END IF;

      fnd_message.set_name('CSF', 'CSF_TRIP_WRONG_AVL_BEFOREAFTER');
      fnd_message.set_token('AVLBEFORE', l_available_hours_before);
      fnd_message.set_token('AVLAFTER', l_available_hours_after);
      fnd_message.set_token('AVAILABLE', l_available_hours);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    cac_sr_object_capacity_pub.update_object_capacity(
      p_api_version             => 1.0
    , x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_object_capacity_id      => p_trip.trip_id
    , p_object_version_number   => p_object_version_number
    , p_available_hours         => l_available_hours
    , p_available_hours_before  => l_available_hours_before
    , p_available_hours_after   => l_available_hours_after
    , p_availability_type       =>  p_availability_type
    , p_status                  => p_status
    , p_start_date_time   => p_start_date
    , p_end_date_time   => p_end_date
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        debug('  Unable to Update the Object Capacity', l_api_name, fnd_log.level_error);
      END IF;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- If Tasks need not be updated.... nothing more to be done. Exit
    IF p_update_tasks = fnd_api.g_false THEN
      RETURN;
    END IF;

    -- If New Trip Status equals Old Trip Status.... nothing more to be done. Exit
    IF NVL(p_status, p_trip.status) = p_trip.status THEN
      RETURN;
    END IF;

    IF p_task_action = g_action_close_trip THEN
      l_validation_level := fnd_api.g_valid_level_none;
      l_task_type := 'SHIFTS';
    ELSE
      l_validation_level := fnd_api.g_valid_level_full;
      l_task_type := 'ALL';
    END IF;

    FOR v_task IN c_tasks(l_task_type) LOOP
      l_new_task_status := get_new_task_status(p_task_action, v_task.assignment_status_id);
      IF l_new_task_status IS NOT NULL THEN
        IF l_debug THEN
          debug('    Updating the Task - TaskID# ' || v_task.task_id, l_api_name, fnd_log.level_statement);
        END IF;
        csf_task_assignments_pub.update_assignment_status(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_validation_level           => l_validation_level
        , p_commit                     => fnd_api.g_false
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_task_assignment_id         => v_task.task_assignment_id
        , p_object_version_number      => v_task.ta_object_version_number
        , p_assignment_status_id       => l_new_task_status
        , x_task_object_version_number => v_task.task_ovn
        , x_task_status_id             => v_task.task_status_id
        );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          -- Somehow direct population of the Token using fnd_msg_pub is not working
          -- Therefore populating it in x_msg_data and using it to populate the Token REASON.
          x_msg_data := fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false);
          IF l_debug THEN
            debug('  Unable to update the Assignment: Error = ' || x_msg_data, l_api_name, fnd_log.level_error);
          END IF;
          fnd_message.set_name('CSF', 'CSF_ASSIGNMENT_UPDATE_FAIL');
          fnd_message.set_token('TASK', v_task.task_number);
          fnd_message.set_token('REASON', x_msg_data);
          fnd_msg_pub.ADD;
          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_change_trip;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_change_trip;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
      ROLLBACK TO csf_change_trip;
  END change_trip;

  PROCEDURE remove_trip(
    x_return_status         OUT  NOCOPY  VARCHAR2
  , x_msg_data              OUT  NOCOPY  VARCHAR2
  , x_msg_count             OUT  NOCOPY  NUMBER
  , p_trip                   IN          trip_rec_type
  , p_object_version_number  IN          NUMBER
  , p_check_active_tasks     IN          VARCHAR2       DEFAULT NULL
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'REMOVE_TRIP';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    -- No need to check Task Assignment Status as Task itself will reflect it for Shift Tasks.
    CURSOR c_shift_tasks IS
     SELECT t.task_id
          , t.object_version_number
          , t.task_name
          , t.task_number
       FROM jtf_task_assignments ta
          , jtf_tasks_vl t
      WHERE ta.object_capacity_id        = p_trip.trip_id
        AND t.task_id                    = ta.task_id
        AND NVL(t.deleted_flag, 'N')     = 'N'
        AND t.task_type_id IN (g_dep_task_type_id, g_arr_task_type_id);

  BEGIN
    SAVEPOINT csf_remove_trip;

    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug(    '  Deleting the Trip #' || p_trip.trip_id
             || ' between ' || format_date(p_trip.start_date_time)
             || ' and ' || format_date(p_trip.end_date_time)
           , l_api_name, fnd_log.level_procedure
           );
    END IF;

    -- Check whether the Trip is blocked
    IF p_trip.status = g_trip_unavailable THEN
      IF l_debug THEN
        debug('    The Trip is unavailable and so cant be deleted', l_api_name, fnd_log.level_error);
      END IF;

      fnd_message.set_name('CSF', 'CSF_TRIP_IS_BLOCKED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Check whether there are active Task Assignments in the Trip
    IF NVL(p_check_active_tasks, fnd_api.g_true) = fnd_api.g_true THEN
      IF trip_has_active_tasks(p_trip.trip_id) THEN
        -- There are Active Task Assignments for the Trip.
        IF l_debug THEN
          debug('    Trip has active Tasks and so cant be deleted', l_api_name, fnd_log.level_error);
        END IF;

        fnd_message.set_name('CSF', 'CSF_TRIP_HAS_ACTIVE_TASKS');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Delete the Shift Tasks
    FOR v_shift_task IN c_shift_tasks LOOP
      IF l_debug THEN
        debug('    Deleting the Shift Task #' || v_shift_task.task_id ||' object version number ' || v_shift_task.object_version_number  , l_api_name, fnd_log.level_statement);
      END IF;
      jtf_tasks_pub.delete_task(
        p_api_version            => 1.0
      , x_return_status          => x_return_status
      , x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      , p_task_id                => v_shift_task.task_id
      , p_object_version_number  => v_shift_task.object_version_number
      );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          debug('      Unable to Delete the Shift Task id - ' || v_shift_task.task_id , l_api_name, fnd_log.level_error);
        END IF;

        fnd_message.set_name('CSF', 'CSF_TASK_DELETE_FAIL');
        fnd_message.set_token('TASK', v_shift_task.task_number);
        fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
        fnd_msg_pub.ADD;
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
    END LOOP;

    -- Delete the Object Capacity
    cac_sr_object_capacity_pub.delete_object_capacity(
      p_api_version           => 1.0
    , x_return_status         => x_return_status
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    , p_object_capacity_id    => p_trip.trip_id
    , p_object_version_number => p_object_version_number
    , p_update_tasks          => fnd_api.g_false
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        debug('    Unable to Delete the Object Capacity', l_api_name, fnd_log.level_error);
      END IF;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_debug THEN
      debug('    Deleted the Trip', l_api_name, fnd_log.level_statement);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_remove_trip;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_remove_trip;
	  IF l_debug THEN
		debug('Unable to Delete the Object Capacity: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
	  END IF;
      if SQLCODE =1 then
        x_return_status := fnd_api.g_ret_sts_error;
      else
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      end if;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
      ROLLBACK TO csf_remove_trip;
  END remove_trip;

  PROCEDURE correct_trip(
    x_return_status         OUT  NOCOPY  VARCHAR2
  , x_msg_data              OUT  NOCOPY  VARCHAR2
  , x_msg_count             OUT  NOCOPY  NUMBER
  , p_trip                   IN          trip_rec_type
  , p_object_version_number  IN          NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'CORRECT_TRIP';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
    l_available_hours    NUMBER;
    l_total_task_time    NUMBER;
    l_total_travel_time  NUMBER;

    l_dep_task_exists    BOOLEAN;
    l_arr_task_exists    BOOLEAN;
    l_dep_task_id        NUMBER;
    l_arr_task_id        NUMBER;

    CURSOR c_tasks IS
      SELECT ta.task_id
           , t.task_number
           , ta.task_assignment_id
           , ta.object_version_number
           , ta.object_capacity_id wrong_trip_id
           , oc.object_capacity_id correct_trip_id
        FROM cac_sr_object_capacity oc
           , jtf_task_assignments ta
           , jtf_tasks_b t
           , jtf_task_statuses_b ts
       WHERE oc.object_capacity_id = p_trip.trip_id
         AND ta.resource_id        = oc.object_id
         AND ta.resource_type_code = oc.object_type
         AND ta.assignee_role      = 'ASSIGNEE'
         AND t.task_id             = ta.task_id
         AND t.task_type_id NOT IN (20, 21)
         AND ts.task_status_id     = ta.assignment_status_id
         AND NVL(ts.closed_flag, 'N')    = 'N'
         AND NVL(ts.completed_flag, 'N') = 'N'
         AND NVL(ts.cancelled_flag, 'N') = 'N'
         AND NVL(ta.object_capacity_id, -1) <> oc.object_capacity_id
         AND ta.booking_start_date < (oc.end_date_time + g_overtime)
         AND ta.booking_end_date > oc.start_date_time
      UNION ALL
      SELECT ta.task_id
           , t.task_number
           , ta.task_assignment_id
           , ta.object_version_number
           , p_trip.trip_id wrong_trip_id
           , oc.object_capacity_id correct_trip_id
        FROM cac_sr_object_capacity oc
           , jtf_task_assignments ta
           , jtf_tasks_b t
           , jtf_task_statuses_b ts
       WHERE ta.object_capacity_id = p_trip.trip_id
         AND oc.object_id          = ta.resource_id
         AND oc.object_type        = ta.resource_type_code
         AND oc.object_capacity_id <> ta.object_capacity_id
         AND t.task_id             = ta.task_id
         AND t.task_type_id NOT IN (20, 21)
         AND ts.task_status_id     = ta.assignment_status_id
         AND NVL(ts.closed_flag, 'N')    = 'N'
         AND NVL(ts.completed_flag, 'N') = 'N'
         AND NVL(ts.cancelled_flag, 'N') = 'N'
         AND ta.booking_start_date < (oc.end_date_time + g_overtime)
         AND ta.booking_end_date > oc.start_date_time
      UNION ALL
      SELECT ta.task_id
           , t.task_number
           , ta.task_assignment_id
           , ta.object_version_number
           , to_number(NULL) wrong_trip_id
           , p_trip.trip_id correct_trip_id
        FROM jtf_task_assignments ta
           , jtf_tasks_b t
       WHERE ta.task_id IN (l_dep_task_id, l_arr_task_id)
         AND t.task_id = ta.task_id;

    CURSOR c_used_time IS
      SELECT SUM (ta.booking_end_date - ta.booking_start_date) used_time
           , SUM (NVL(csf_util_pvt.convert_to_minutes(
                    ta.sched_travel_duration
                  , ta.sched_travel_duration_uom
                  ), 0)) travel_time
        FROM jtf_task_assignments ta
           , jtf_task_statuses_b ts
       WHERE ta.object_capacity_id        = p_trip.trip_id
         AND ts.task_status_id            = ta.assignment_status_id
         AND NVL(ts.closed_flag, 'N')     = 'N'
         AND NVL(ts.completed_flag, 'N')  = 'N'
         AND NVL(ts.cancelled_flag, 'N')  = 'N';

    CURSOR c_shift_tasks IS
      SELECT t.task_id
           , t.task_type_id
           , t.object_version_number
           , t.task_name
           , t.task_number
           , LAG(t.task_id) OVER (PARTITION BY t.task_type_id
                                  ORDER BY t.scheduled_start_date) duplicate
        FROM jtf_task_assignments ta
           , jtf_tasks_vl t
       WHERE ta.object_capacity_id = p_trip.trip_id
         AND t.task_id = ta.task_id
         AND NVL(t.deleted_flag, 'N') = 'N'
         AND t.task_type_id IN (20, 21);
  BEGIN
    SAVEPOINT csf_correct_trip;

    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('  Checking Shift Tasks', l_api_name, fnd_log.level_statement);
    END IF;

    -- Clean up the Shift Tasks for the Trip.
    l_dep_task_exists := FALSE;
    l_arr_task_exists := FALSE;
    FOR v_shift_task IN c_shift_tasks LOOP
      IF v_shift_task.duplicate IS NOT NULL THEN
        IF l_debug THEN
          debug('    Deleting the Duplicate Shift Task #' || v_shift_task.task_id, l_api_name, fnd_log.level_statement);
        END IF;
        -- Departure Task already exists... Delete this Duplicate.
        jtf_tasks_pub.delete_task(
          p_api_version            => 1.0
        , x_return_status          => x_return_status
        , x_msg_count              => x_msg_count
        , x_msg_data               => x_msg_data
        , p_task_id                => v_shift_task.task_id
        , p_object_version_number  => v_shift_task.object_version_number
        );
      END IF;
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          debug('    Unable to Delete the Task', l_api_name, fnd_log.level_error);
        END IF;

        fnd_message.set_name('CSF', 'CSF_TASK_DELETE_FAIL');
        fnd_message.set_token('TASK', v_shift_task.task_number);
        fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
        fnd_msg_pub.ADD;
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF v_shift_task.task_type_id = 20 THEN
        l_dep_task_exists := TRUE;
      ELSE
        l_arr_task_exists := TRUE;
      END IF;
    END LOOP;

    IF NOT(l_dep_task_exists) OR NOT(l_arr_task_exists) THEN
      IF l_debug THEN
        debug('    Either Departure or Arrival Task is absent. Creating them', l_api_name, fnd_log.level_statement);
      END IF;

      create_shift_tasks(
        p_api_version         => 1.0
      , x_return_status       => x_return_status
      , x_msg_data            => x_msg_data
      , x_msg_count           => x_msg_count
      , p_resource_id         => p_trip.resource_id
      , p_resource_type       => p_trip.resource_type
      , p_start_date_time     => p_trip.start_date_time
      , p_end_date_time       => p_trip.end_date_time
      , p_create_dep_task     => NOT(l_dep_task_exists)
      , p_create_arr_task     => NOT(l_arr_task_exists)
      , x_dep_task_id         => l_dep_task_id
      , x_arr_task_id         => l_arr_task_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          debug('    Creation of Shift Tasks failed', l_api_name, fnd_log.level_error);
        END IF;
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    FOR v_task IN c_tasks LOOP
      IF l_debug THEN
        debug('  TaskID#' || v_task.task_id || ' is part of Trip#' || v_task.wrong_trip_id || '. But should be in Trip#' || v_task.correct_trip_id || '. Fixing the Task', l_api_name, fnd_log.level_statement);
      END IF;

      jtf_task_assignments_pub.update_task_assignment(
        p_api_version           => 1.0
      , x_return_status         => x_return_status
      , x_msg_data              => x_msg_data
      , x_msg_count             => x_msg_count
      , p_task_assignment_id    => v_task.task_assignment_id
      , p_object_version_number => v_task.object_version_number
      , p_object_capacity_id    => v_task.correct_trip_id
      , p_enable_workflow       => fnd_api.g_miss_char
      , p_abort_workflow        => fnd_api.g_miss_char
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('CSF', 'CSF_ASSIGNMENT_UPDATE_FAIL');
        fnd_message.set_token('TASK', v_task.task_number);
        fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
        fnd_msg_pub.ADD;
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
    END LOOP;

    -- Update the Availability of the Trip.
    OPEN c_used_time;
    FETCH c_used_time INTO l_total_task_time, l_total_travel_time;
    CLOSE c_used_time;

    l_available_hours :=   (p_trip.end_date_time - p_trip.start_date_time)
                         -  l_total_task_time
                         - l_total_travel_time / g_mins_in_day;

    cac_sr_object_capacity_pub.update_object_capacity(
      p_api_version             => 1.0
    , x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_object_capacity_id      => p_trip.trip_id
    , p_object_version_number   => p_object_version_number
    , p_available_hours         => l_available_hours * g_hours_in_day
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_correct_trip;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_correct_trip;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
      ROLLBACK TO csf_correct_trip;
  END correct_trip;


  /******************************************************************************************
  *                                                                                         *
  *                Private Functions and Procedures dealing with Multiple Trips             *
  *                                                                                         *
  *******************************************************************************************/
  /**
   * Creates Trips for the passed Resource between the Start and End Dates
   * based on the Shift Definitions existing for the resource between the dates.
   * <br>
   * Validations done in addition to the ones in CREATE_TRIP
   * 1. If any one trip exists without any Dep/Arr, then the API errors out asking
   *    to use FIX TRIPS to fix the Trips in the range first.
   * 2. If there exists no Shift Definitions for the Resource between the given
   *    dates, the API errors out with No Shift Defn message.
   * 3. If there exists atleast one Shift Task not tied to any Trip between the
   *    the dates, the API errors out asking to use UPGRADE_TRIPS to upgrade
   *    from Shift Model to Trips Model.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commits the Database
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_resource_id             Resource ID
   * @param  p_resource_type           Resource Type
   * @param  p_start_date              Start Date
   * @param  p_end_date                End Date
   *
   * @see create_trip                  Create Trip API
   **/

  PROCEDURE delete_trips(
    x_return_status          OUT  NOCOPY  VARCHAR2
  , x_msg_data               OUT  NOCOPY  VARCHAR2
  , x_msg_count              OUT  NOCOPY  NUMBER
  , p_trips                  IN           trip_tbl_type
  )IS
    l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_TRIPS';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('Deleting the given Trips', l_api_name, fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_trips.COUNT LOOP
       IF p_trips(i).availability_type = g_shift_type OR g_shift_type is null
       THEN
            remove_trip(
              x_return_status         => x_return_status
            , x_msg_data              => x_msg_data
            , x_msg_count             => x_msg_count
            , p_trip                  => p_trips(i)
            , p_object_version_number => p_trips(i).object_version_number
            );

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
              add_message(
                p_trip     => p_trips(i)
              , p_reason   => fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
              , p_msg_name => 'CSF_TRIP_DELETE_FAIL_OTHER'
              , p_msg_type => g_error_message
              );
              IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            ELSE
              add_message(p_trips(i));
            END IF;
       END IF;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END delete_trips;

  PROCEDURE fix_trips(
    x_return_status          OUT  NOCOPY  VARCHAR2
  , x_msg_data               OUT  NOCOPY  VARCHAR2
  , x_msg_count              OUT  NOCOPY  NUMBER
  , p_trips                   IN          trip_tbl_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_TRIPS';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('Fixing the given Trips', l_api_name, fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_trips.COUNT LOOP
      correct_trip(
        x_return_status         => x_return_status
      , x_msg_data              => x_msg_data
      , x_msg_count             => x_msg_count
      , p_trip                  => p_trips(i)
      , p_object_version_number => p_trips(i).object_version_number
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        add_message(
          p_trip     => p_trips(i)
        , p_reason   => fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
        , p_msg_name => 'CSF_TRIP_FIX_FAIL_OTHER'
        , p_msg_type => g_error_message
        );
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        add_message(p_trips(i));
      END IF;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END fix_trips;

  PROCEDURE create_trips(
    x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_resource_tbl          IN          csf_resource_pub.resource_tbl_type
  , p_start_date            IN          DATE
  , p_end_date              IN          DATE
  , P_SHIFT_TYPE            IN        VARCHAR2 DEFAULT NULL
  , p_delete_trips          IN          BOOLEAN    DEFAULT FALSE
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_TRIPS';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_check_failed       VARCHAR2(1);
    l_res_id             NUMBER;
    l_res_type           jtf_objects_b.object_code%TYPE;
    l_start              DATE;
    l_end                DATE;

    l_shifts             csf_resource_pub.shift_tbl_type;
    l_shift_idx          PLS_INTEGER;

    l_trip_idx           PLS_INTEGER;
    l_new_trip           trip_rec_type;
    l_old_trips          trip_tbl_type;
    l_new_trips          trip_tbl_type;

    l_trip_length        NUMBER;
    l_prev_trip_id       NUMBER;
    l_temp_trip_tbl      number_tbl_type;
    l_del_trip_tbl       jtf_number_table;
    l_old_new_trip_map   number_tbl_type;

    l_msg_name           fnd_new_messages.message_name%TYPE;
    l_reason             fnd_new_messages.message_text%TYPE;

	l_shift_old_start    DATE;
    l_shift_old_end    DATE;

    -- Query to check for the existence of Stray Shift Tasks
    CURSOR c_shift_tasks_exist (p_res_id NUMBER, p_res_type VARCHAR2, p_start DATE, p_end DATE) IS
      SELECT 'Y'
        FROM jtf_tasks_b t
           , jtf_task_assignments ta
       WHERE t.owner_id = p_res_id
         AND t.owner_type_code = p_res_type
         AND t.planned_start_date BETWEEN p_start AND p_end
         AND t.task_type_id IN (20, 21)
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND ta.task_id = t.task_id
         AND ta.assignee_role = 'ASSIGNEE'
         AND ta.object_capacity_id IS NULL
         AND ROWNUM = 1;

    -- Cursor to retrive tasks still linked to old trip
    CURSOR c_unlinked_tasks IS
      SELECT /*+ cardinality (oc 1) */
             ta.task_assignment_id
           , ta.object_version_number
           , ta.object_capacity_id
           , ta.task_id
           , ta.booking_start_date
           , ta.booking_end_date
           , csf_util_pvt.convert_to_minutes(
               ta.sched_travel_duration
             , ta.sched_travel_duration_uom
             ) travel_time
        FROM TABLE ( CAST(l_del_trip_tbl AS jtf_number_table) ) oc
           , jtf_task_assignments ta
           , jtf_task_statuses_b ts
           , jtf_tasks_b t
       WHERE ta.object_capacity_id = oc.COLUMN_VALUE
         AND ts.task_status_id = ta.assignment_status_id
         AND NVL(ts.closed_flag, 'N')     = 'N'
         AND NVL(ts.completed_flag, 'N')  = 'N'
         AND NVL(ts.cancelled_flag, 'N')  = 'N'
         AND NVL(ts.rejected_flag, 'N')   = 'N'
         AND t.task_id = ta.task_id
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND t.task_type_id NOT IN (20, 21)
       ORDER BY ta.object_capacity_id;


    CURSOR c_linkable_tasks(l_trip number) IS
     SELECT tb.task_id
     FROM   jtf_task_assignments jta,
            jtf_tasks_b tb,
            jtf_task_statuses_b jts
     WHERE  jta.object_capacity_id=l_trip
       AND  jta.task_id=tb.task_id
       AND  jts.task_status_id = tb.task_status_id
       AND  NVL(jts.closed_flag, 'N')     = 'N'
       AND  NVL(jts.completed_flag, 'N')  = 'N'
       AND  NVL(jts.cancelled_flag, 'N')  = 'N'
       AND  NVL(jts.rejected_flag, 'N')   = 'N'
       AND  NVL(tb.deleted_flag, 'N') <> 'Y'
       AND  tb.task_type_id not in (20,21);

    CURSOR c_trip_info(p_trip_id NUMBER) IS
      SELECT oc.object_version_number
           , oc.available_hours
        FROM cac_sr_object_capacity oc
       WHERE oc.object_capacity_id = p_trip_id;

    l_trip_info c_trip_info%ROWTYPE;
    l_links     c_linkable_tasks%ROWTYPE;


  BEGIN
    SAVEPOINT csf_create_trips;

    x_return_status := fnd_api.g_ret_sts_success;

    l_res_id   := p_resource_tbl(1).resource_id;
    l_res_type := p_resource_tbl(1).resource_type;

    IF l_debug THEN
      IF p_delete_trips THEN
        debug('Replacing Trips for Resource#' || l_res_id || ' between ' || p_start_date || ' and ' || p_end_date, l_api_name, fnd_log.level_procedure);
      ELSE
        debug('Creating Trips for Resource#' || l_res_id || ' between ' || p_start_date || ' and ' || p_end_date, l_api_name, fnd_log.level_procedure);
      END IF;
    END IF;

    -- Get the Resource's Shifts
    csf_resource_pub.get_resource_shifts(
      p_api_version       => 1.0
    , x_return_status     => x_return_status
    , x_msg_count         => x_msg_count
    , x_msg_data          => x_msg_data
    , p_resource_id       => l_res_id
    , p_resource_type     => l_res_type
    , p_start_date        => p_start_date
    , p_end_date          => p_end_date
    , p_shift_type        => p_shift_type
    , x_shifts            => l_shifts
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        debug('  No Shifts were found for the resource between the timeframe', l_api_name, fnd_log.level_error);
      END IF;
      add_message(
        p_res_id   => l_res_id
      , p_res_type => l_res_type
      , p_start    => p_start_date
      , p_end      => p_end_date
      , p_reason   => fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
      , p_msg_name => 'CSF_RETRIEVE_SHIFTS_FAIL'
      , p_msg_type => g_error_message
      );
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;
    if l_shifts.count >0 then
    -- Check whether Shift Tasks are already there between the given Time Frame.
    l_start := l_shifts(l_shifts.FIRST).start_datetime;
    l_end   := l_shifts(l_shifts.LAST).end_datetime;

   debug('Shift Start time : '|| to_char(l_start,'dd/mm/yyyy hh24:mi') || 'Shift End time : '|| to_char(l_end,'dd/mm/yyyy hh24:mi'), l_api_name, fnd_log.level_procedure);
    OPEN c_shift_tasks_exist(l_res_id, l_res_type, l_start, l_end);
    FETCH c_shift_tasks_exist INTO l_check_failed;
    IF c_shift_tasks_exist%NOTFOUND THEN
      l_check_failed := 'N';
    END IF;
    CLOSE c_shift_tasks_exist;

    IF l_check_failed = 'Y' THEN
      -- Shift Tasks exists. Should use "Upgrade to Trips" API rather than "Create Trip".
      IF l_debug THEN
        debug('  Shift tasks are present between the timeframe', l_api_name, fnd_log.level_error);
      END IF;
      add_message(
        p_res_id   => l_res_id
      , p_res_type => l_res_type
      , p_start    => p_start_date
      , p_end      => p_end_date
      , p_msg_name => 'CSF_USE_UPGRADE_TRIPS'
      , p_msg_type => g_error_message
      );
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Get all the trips in the required interval
    l_start     := LEAST(p_start_date, l_shifts(l_shifts.FIRST).start_datetime);
    l_end       := GREATEST(p_end_date, l_shifts(l_shifts.LAST).end_datetime);
	l_shift_old_start := l_start;
	l_shift_old_end  :=l_end;
    l_old_trips := find_trips(p_resource_tbl, l_start, l_end);

    IF l_debug THEN
      debug('  Current Trips existing: Count = ' || l_old_trips.COUNT, l_api_name, fnd_log.level_statement);
      FOR i IN 1..l_old_trips.COUNT LOOP
        debug( '    Trip ID = ' || l_old_trips(i).trip_id
                || ' Start Time = ' || format_date(l_old_trips(i).start_date_time)
                || ' End Time = ' || format_date(l_old_trips(i).end_date_time)
              , l_api_name, fnd_log.level_statement);
      END LOOP;
    END IF;

    l_del_trip_tbl := jtf_number_table();

    -- Loop through each Shift to create a new Trip
    l_shift_idx := l_shifts.FIRST;
    WHILE l_shift_idx IS NOT NULL LOOP
      IF l_debug THEN
        debug(     '  Trying to create trip for shift between '
                || format_date(l_shifts(l_shift_idx).start_datetime) || ' and '
                || format_date(l_shifts(l_shift_idx).end_datetime)
             , l_api_name, fnd_log.level_statement
             );
      END IF;
      BEGIN
        SAVEPOINT csf_process_shift;
           l_old_trips := find_trips(p_resource_tbl, l_shift_old_start, l_shift_old_end);
        x_return_status := fnd_api.g_ret_sts_success;

        l_start    := l_shifts(l_shift_idx).start_datetime;
        l_end      := l_shifts(l_shift_idx).end_datetime;
        g_shift_type := l_shifts(l_shift_idx).availability_type;
        l_msg_name := NULL;
        IF l_debug THEN
        debug(     '  Trying to create trip for shift between '
                || format_date(l_start) || ' and '
                || format_date(l_end) || ' and shift type :'
                || g_shift_type
             , l_api_name, fnd_log.level_statement
             );
      END IF;
        -- Loop through each trip and check for overlap with any of the current trips
        l_trip_idx := l_old_trips.FIRST;
        WHILE l_trip_idx IS NOT NULL LOOP
          IF l_debug THEN
            debug('  Checking for overlap with old trip ' || l_old_trips(l_trip_idx).trip_id ||
                   ' Object version number :'|| l_old_trips(l_trip_idx).object_version_number    , l_api_name, fnd_log.level_statement);
          END IF;



                    IF time_overlaps(l_old_trips(l_trip_idx), l_shifts(l_shift_idx)) THEN
                      -- If Trips can be deleted, then we can avoid the error "Duplicate Trip"
                      -- by deleting the overlapping trip and only when it falls within the range.
                      IF    NOT p_delete_trips
                         OR NOT time_overlaps(l_old_trips(l_trip_idx), p_start_date, p_end_date)
                      THEN
                        IF l_debug THEN
                            debug('  Error : CSF_TRIP_CREATE_FAIL_DUP '    , l_api_name, fnd_log.level_error);
                      END IF;
                        l_msg_name := 'CSF_TRIP_CREATE_FAIL_DUP';
                        RAISE fnd_api.g_exc_error;
                      END IF;
                      IF l_debug THEN
                            debug('  Time Overlaps so calling remove trip '    , l_api_name, fnd_log.level_statement);
                      END IF;
                      remove_trip(
                        x_return_status         => x_return_status
                      , x_msg_data              => x_msg_data
                      , x_msg_count             => x_msg_count
                      , p_trip                  => l_old_trips(l_trip_idx)
                      , p_object_version_number => l_old_trips(l_trip_idx).object_version_number
                      , p_check_active_tasks    => fnd_api.g_false
                      );

                      IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        IF l_debug THEN
                            debug('   remove_trip Error : CSF_TRIP_DELETE_FAIL_OTHER '    , l_api_name, fnd_log.level_error);
                        END IF;
                        l_msg_name := 'CSF_TRIP_DELETE_FAIL_OTHER';
                        RAISE fnd_api.g_exc_error;
                      END IF;

                      -- Since Trip is not present in DB... it should be removed from memory too.
                      l_temp_trip_tbl(l_temp_trip_tbl.COUNT+1) := l_old_trips(l_trip_idx).trip_id;

                    ELSIF l_old_trips(l_trip_idx).start_date_time > (l_end + g_overtime) THEN
                      -- Since Trips and Shifts are ordered by time, there is no point in searching forward
                      EXIT;
                    END IF;


            l_trip_idx := l_old_trips.NEXT(l_trip_idx);

        END LOOP;

        -- Loop through each trip and check for overlap with any of the new trips
        l_trip_idx := l_new_trips.LAST;
        WHILE l_trip_idx IS NOT NULL LOOP
          IF l_debug THEN
            debug('  Checking for overlap with new trip ' || l_new_trips(l_trip_idx).trip_id
                 , l_api_name, fnd_log.level_statement);
          END IF;
          IF time_overlaps(l_new_trips(l_trip_idx), l_shifts(l_shift_idx)) THEN
            l_msg_name := 'CSF_TRIP_CREATE_FAIL_DUP';
            RAISE fnd_api.g_exc_error;
          ELSIF (l_new_trips(l_trip_idx).end_date_time + g_overtime) < l_start THEN
            -- Since Trips and Shifts are ordered by time, there is no point in searching forward
            EXIT;
          END IF;
          l_trip_idx := l_new_trips.PRIOR(l_trip_idx);
        END LOOP;

        new_trip(
          x_return_status        => x_return_status
        , x_msg_data             => x_msg_data
        , x_msg_count            => x_msg_count
        , p_resource_id          => l_res_id
        , p_resource_type        => l_res_type
        , p_start_date_time      => l_start
        , p_end_date_time        => l_end
        , p_find_tasks           => fnd_api.g_true
        , x_trip                 => l_new_trip
        );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          l_msg_name := 'CSF_TRIP_CREATE_FAIL_OTHER';
          RAISE fnd_api.g_exc_error;
        END IF;

        -- Since the Old Trips are removed from Database and there is no error
        -- encountered we can remove the Old Trips from Memory also
        FOR i in 1..l_temp_trip_tbl.COUNT LOOP
          l_trip_idx := l_old_trips.FIRST;
          WHILE l_trip_idx IS NOT NULL LOOP
            IF l_temp_trip_tbl(i) = l_old_trips(l_trip_idx).trip_id THEN
              l_old_trips.DELETE(l_trip_idx);
            END IF;
            l_trip_idx := l_old_trips.NEXT(l_trip_idx);
          END LOOP;

          l_del_trip_tbl.extend(1);
          l_del_trip_tbl(l_del_trip_tbl.LAST)    := l_temp_trip_tbl(i);
          l_old_new_trip_map(l_temp_trip_tbl(i)) := l_new_trips.COUNT + 1;
        END LOOP;

        l_temp_trip_tbl.DELETE;
        l_new_trips(l_new_trips.COUNT + 1)  := l_new_trip;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO csf_process_shift;
          l_new_trip.trip_id := -1;
          l_new_trips(l_new_trips.COUNT + 1) := l_new_trip;
          IF l_msg_name = 'CSF_TRIP_DELETE_FAIL_OTHER'  THEN
            l_start := l_old_trips(l_trip_idx).start_date_time;
            l_end   := l_old_trips(l_trip_idx).end_date_time;
          END IF;
          IF l_msg_name <> 'CSF_TRIP_CREATE_FAIL_DUP' THEN
            l_reason := fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false);
          ELSE
            l_reason := NULL;
          END IF;

          IF l_debug THEN
            IF l_msg_name = 'CSF_TRIP_CREATE_FAIL_DUP' THEN
              IF NOT p_delete_trips THEN
                debug(     '    Since delete trips not allowed.. we have overlap with existing trip'
                     , l_api_name, fnd_log.level_error
                     );
              ELSE
                debug(     '    Delete trips allowed.. but we have conflict with new trip'
                     , l_api_name, fnd_log.level_error
                     );
              END IF;
            ELSIF l_msg_name = 'CSF_TRIP_CREATE_FAIL_OTHER' THEN
                debug(     '    Error occurred while creating the trip between '
                        || format_date(l_start) || ' and ' || format_date(l_end)
                        || ' : Error = ' || l_reason
                     , l_api_name, fnd_log.level_error
                     );
            ELSIF l_msg_name = 'CSF_TRIP_DELETE_FAIL_OTHER' THEN
                debug(     '    Error occurred while deleting the trip between '
                        || format_date(l_start) || ' and ' || format_date(l_end)
                        || ' : Error = ' || l_reason
                     , l_api_name, fnd_log.level_error
                     );
            END IF;
          END IF;

          add_message(
            p_res_id   => l_res_id
          , p_res_type => l_res_type
          , p_start    => l_start
          , p_end      => l_end
          , p_reason   => l_reason
          , p_msg_name => l_msg_name
          , p_msg_type => g_error_message
          );
          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END;

      l_shift_idx := l_shifts.NEXT(l_shift_idx);
    END LOOP;

    IF p_delete_trips THEN
      -- Link all the Unlinked Task Assignments to the corresponding shifts
      IF l_debug THEN
        debug('  Linking unlinked Task Assignments if any of old trips to new trips', l_api_name, fnd_log.level_statement);
      END IF;

      l_trip_length  := 0;
      FOR v_task IN c_unlinked_tasks LOOP
        l_trip_idx := l_old_new_trip_map(v_task.object_capacity_id);

        -- Moment we have processed all Tasks linked to old trip.. update Prev Trip's Capacity.
        IF l_prev_trip_id <> l_new_trips(l_trip_idx).trip_id THEN
          IF l_debug THEN
            debug(    '    Decreasing Trip#' || l_prev_trip_id
                   || ' Capacity to be lesser by ' || l_trip_length*g_hours_in_day
                 , l_api_name, fnd_log.level_statement
                 );
          END IF;

          OPEN c_trip_info(l_prev_trip_id);
          FETCH c_trip_info INTO l_trip_info;
          CLOSE c_trip_info;

          l_trip_info.available_hours :=   l_trip_info.available_hours
                                         - l_trip_length * g_hours_in_day;
          -- Update the new Trip Capacity of the new trip created (Always OVN is 1)
          cac_sr_object_capacity_pub.update_object_capacity(
            p_api_version             => 1.0
          , x_return_status           => x_return_status
          , x_msg_count               => x_msg_count
          , x_msg_data                => x_msg_data
          , p_object_capacity_id      => l_prev_trip_id
          , p_object_version_number   => l_trip_info.object_version_number
          , p_available_hours         => l_trip_info.available_hours
          );

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_debug THEN
              debug(    '    Error updating Trip. ' || fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false), l_api_name, fnd_log.level_error);
            END IF;
          END IF;

          l_trip_length  := 0;
        END IF;

        IF l_debug THEN
          debug(    '    Linking Task ' || v_task.task_id
                 || ' : Old Trip = ' || v_task.object_capacity_id
                 || ' : New Trip = ' || l_new_trips(l_trip_idx).trip_id
               , l_api_name, fnd_log.level_statement
               );
        END IF;

        l_trip_length :=   l_trip_length
                         + v_task.booking_end_date - v_task.booking_start_date
                         + NVL(v_task.travel_time, 0) / g_mins_in_day;

        jtf_task_assignments_pub.update_task_assignment(
          p_api_version           => 1.0
        , x_return_status         => x_return_status
        , x_msg_data              => x_msg_data
        , x_msg_count             => x_msg_count
        , p_task_assignment_id    => v_task.task_assignment_id
        , p_object_version_number => v_task.object_version_number
        , p_object_capacity_id    => l_new_trips(l_trip_idx).trip_id
        , p_enable_workflow       => fnd_api.g_miss_char
        , p_abort_workflow        => fnd_api.g_miss_char
        );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_debug THEN
            debug(    '    Error updating Task Assignment', l_api_name, fnd_log.level_error);
          END IF;
          add_message(
            p_res_id   => l_res_id
          , p_res_type => l_res_type
          , p_start    => p_start_date
          , p_end      => p_end_date
          , p_reason   => fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
          , p_msg_name => 'CSF_TRIP_REPLACE_FAIL_RELINK'
          , p_msg_type => g_error_message
          );
          RAISE fnd_api.g_exc_error;
        END IF;

        -- Moment we encounter a Task linked to old trip.. we have a conflict.
        IF l_prev_trip_id IS NULL OR l_prev_trip_id <> l_new_trips(l_trip_idx).trip_id THEN
          -- Notify the user that the new trip has conflicts. Note its not an error.
          add_message(
            p_res_id   => l_res_id
          , p_res_type => l_res_type
          , p_start    => l_shifts(l_trip_idx).start_datetime
          , p_end      => l_shifts(l_trip_idx).end_datetime
          , p_msg_name => 'CSF_TRIP_CREATED_CONFLICTS'
          , p_msg_type => g_warning_message
          );
        END IF;

        l_prev_trip_id := l_new_trips(l_trip_idx).trip_id;
      END LOOP;

      -- Delete the remaining trips not replaced during Create Operation
      -- commented becoz existing trips should not be deleted while replacing
     /* l_trip_idx := l_old_trips.FIRST;
      WHILE l_trip_idx IS NOT NULL LOOP
        -- Delete only those trips falling within the given dates.
        IF time_overlaps(l_old_trips(l_trip_idx), p_start_date, p_end_date) THEN

          IF l_debug THEN
            debug(     '    Deleting the non-overlapping Trip ' || l_old_trips(l_trip_idx).trip_id
                    || ' between ' || format_date(l_old_trips(l_trip_idx).start_date_Time)
                    || ' and ' || format_date(l_old_trips(l_trip_idx).end_date_Time)
                 , l_api_name, fnd_log.level_statement
                 );
          END IF;

          IF trip_has_active_tasks(l_old_trips(l_trip_idx).trip_id) THEN
            IF l_debug THEN
              debug(    '    Cant delete trip' || l_old_trips(l_trip_idx).trip_id
                     || ' between ' || format_date(l_old_trips(l_trip_idx).start_date_Time)
                     || ' and ' || format_date(l_old_trips(l_trip_idx).end_date_Time)
                     || ' as there active tasks present'
                   , l_api_name, fnd_log.level_error
                   );
            END IF;
            add_message(l_old_trips(l_trip_idx), NULL, 'CSF_TRIP_REPLACE_FAIL_ACTIVE', g_error_message);
          ELSE
            remove_trip(
              x_return_status         => x_return_status
            , x_msg_data              => x_msg_data
            , x_msg_count             => x_msg_count
            , p_trip                  => l_old_trips(l_trip_idx)
            , p_object_version_number => l_old_trips(l_trip_idx).object_version_number
            , p_check_active_tasks    => fnd_api.g_true
            );
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
              add_message(
                p_trip     => l_old_trips(l_trip_idx)
              , p_reason   => fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
              , p_msg_name => 'CSF_TRIP_DELETE_FAIL_OTHER'
              , p_msg_type => g_error_message
              );
              IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END IF;
          END IF;
        END IF;
        l_trip_idx := l_old_trips.NEXT(l_trip_idx);
      END LOOP;*/
    END IF;

    -- Now populate the Message Table so that the caller will
    -- get correct picture of Success vs Failure. Note that the failures
    -- are already accounted for in the above logic. Only Success needs to be
    -- stored. In case of REPLACE Action, we are bothered about how many trips
    -- created successfully and not how many deleted successfully.
    FOR i IN 1..l_new_trips.COUNT LOOP
      IF l_new_trips(i).trip_id <> -1 THEN
        add_message(l_res_id, l_res_type, l_shifts(i).start_datetime, l_shifts(i).end_datetime);
      END IF;
    END LOOP;
    end if;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_create_trips;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_create_trips;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
      ROLLBACK TO csf_create_trips;
  END create_trips;

  /**
   * Upgrades the current data based on Shift Tasks Model to Trips Model.
   * Upgrades all the Trips which exists in the system demarcated by Shift Tasks to the
   * actual Trips Model by creating new records in Trips Table for the Resource
   * identified by P_RESOURCE_ID by querying for all the Departure and Arrival Shift Tasks
   * between the Start and End Dates and creating Trips for those Shift Tasks.
   * <br>
   * The major difference between CREATE_TRIPS and UPGRADE_TO_TRIPS is that the former
   * creates the Trips based on the current Shift Definitions. The Later creates Trips
   * based on the current Shift Tasks position.
   * <br>
   * For each trip to be created, it inturn calls CREATE_TRIP and so all
   * the validation that are done for CREATE_TRIP is applicable here also.
   * Since this API already has Shift Tasks and is creating Trips for those Shift Tasks
   * it fills the parameters P_DEP_TASK_ID and P_ARR_TASK_ID of CREATE_TRIP API.
   * <br>
   * If there are no fatal errors encountered, x_msg_data will contain the number
   * of Trips upgraded successfully and the number of Trips failed to be upgraded
   * because of possible overlap with existing trips. Note that this message is
   * not put in the Message Stack. So API users should not rely on the value of
   * x_msg_data to determine whether the API failed or not. Rather they should
   * rely only on standard way of checking x_return_status.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commits the Database
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_resource_id             Resource ID
   * @param  p_resource_type           Resource Type
   * @param  p_start_date              Start Date
   * @param  p_end_date                End Date
   *
   * @see create_trip                  Create Trip API
   * @see create_trips                 Create Trips API
   **/
  PROCEDURE upgrade_to_trips(
    x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_resource_tbl          IN          csf_resource_pub.resource_tbl_type
  , p_start_date            IN          DATE
  , p_end_date              IN          DATE
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'UPGRADE_TO_TRIPS';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_dep_task_tbl       jtf_number_table;
    l_arr_task_tbl       jtf_number_table;
    l_start_time_tbl     jtf_date_table;
    l_end_time_tbl       jtf_date_table;
    l_new_trip           trip_rec_type;

    CURSOR c_shift_tasks IS
      SELECT d.task_id            dep_task_id
           , a.task_id            arr_task_id
           , d.planned_start_date start_time
           , a.planned_end_date   end_time
        FROM jtf_tasks_b d
           , jtf_task_assignments dta
           , jtf_tasks_b a
           , jtf_task_assignments ata
       WHERE d.owner_id = p_resource_tbl(1).resource_id
         AND d.owner_type_code = p_resource_tbl(1).resource_type
         AND d.planned_start_date BETWEEN p_start_date AND p_end_date
         AND d.task_type_id = 20
         AND NVL(d.deleted_flag, 'N') = 'N'
         AND dta.task_id = d.task_id
         AND dta.assignee_role = 'ASSIGNEE'
         AND dta.object_capacity_id IS NULL
         AND a.owner_id = d.owner_id
         AND a.owner_type_code = d.owner_type_code
         AND a.planned_end_date BETWEEN d.planned_start_date AND (d.planned_start_date + 1)
         AND a.task_type_id = 21
         AND NVL(a.deleted_flag, 'N') = 'N'
         AND ata.task_id = a.task_id
         AND ata.assignee_role = 'ASSIGNEE'
         AND ata.object_capacity_id IS NULL
         AND dta.shift_construct_id = ata.shift_construct_id
       ORDER BY d.planned_start_date;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('Upgrading to Trips for Resource#' || p_resource_tbl(1).resource_id || ' between ' || p_start_date || ' and ' || p_end_date, l_api_name, fnd_log.level_procedure);
    END IF;

    -- Bulk Collecting all information about Shift Tasks.
    OPEN c_shift_tasks;
    FETCH c_shift_tasks BULK COLLECT INTO l_dep_task_tbl, l_arr_task_tbl, l_start_time_tbl, l_end_time_tbl;
    CLOSE c_shift_tasks;

    FOR i IN 1..l_dep_task_tbl.COUNT LOOP
      IF l_debug THEN
        debug('  Found Shift Tasks - Dep #' || l_dep_task_tbl(i) || ' : Arr # ' || l_arr_task_tbl(i), l_api_name, fnd_log.level_procedure);
      END IF;
      -- Create a Trip between the Shift Tasks.
      new_trip(
        x_return_status        => x_return_status
      , x_msg_data             => x_msg_data
      , x_msg_count            => x_msg_count
      , p_resource_id          => p_resource_tbl(1).resource_id
      , p_resource_type        => p_resource_tbl(1).resource_type
      , p_start_date_time      => l_start_time_tbl(i)
      , p_end_date_time        => l_end_time_tbl(i)
      , p_dep_task_id          => l_dep_task_tbl(i)
      , p_arr_task_id          => l_arr_task_tbl(i)
      , x_trip                 => l_new_trip
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        add_message(
          p_res_id   => p_resource_tbl(1).resource_id
        , p_res_type => p_resource_tbl(1).resource_type
        , p_start    => l_start_time_tbl(i)
        , p_end      => l_end_time_tbl(i)
        , p_reason   => fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
        , p_msg_name => 'CSF_TRIP_CREATE_FAIL_OTHER'
        , p_msg_type => g_error_message
        );
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        add_message(
          p_res_id   => p_resource_tbl(1).resource_id
        , p_res_type => p_resource_tbl(1).resource_type
        , p_start    => l_start_time_tbl(i)
        , p_end      => l_end_time_tbl(i)
        );
      END IF;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END upgrade_to_trips;

  PROCEDURE update_trip_status(
    x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_trip_action           IN          VARCHAR2
  , p_trips                 IN          trip_tbl_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_TRIP_STATUS';
    l_debug        CONSTANT BOOLEAN  := g_debug = 'Y';

    l_new_trip_status    NUMBER;
    l_trip_action        VARCHAR2(30);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('Updating the status of the given trips', l_api_name, fnd_log.level_procedure);
    END IF;

    IF p_trip_action IN (g_action_block_trip, g_action_close_trip) THEN
      l_new_trip_status := g_trip_unavailable;
    ELSIF p_trip_action = g_action_unblock_trip THEN
      l_new_trip_status := g_trip_available;
    END IF;

    FOR i IN 1..p_trips.COUNT LOOP
      IF l_debug THEN
        debug('Updating Trip# ' || p_trips(i).trip_id, l_api_name, fnd_log.level_statement);
      END IF;

      IF l_new_trip_status = p_trips(i).status THEN
        IF l_debug THEN
          debug('  Trip is already in correct status ' || p_trips(i).status, l_api_name, fnd_log.level_statement);
        END IF;
        GOTO NEXT_TRIP;
      END IF;

      IF p_trip_action = g_action_close_trip AND (p_trips(i).end_date_time + g_overtime) > SYSDATE THEN
        IF l_debug THEN
          debug('  Trip is present or future dated. Cant close', l_api_name, fnd_log.level_error);
        END IF;
        add_message(
          p_trip     => p_trips(i)
        , p_msg_name => 'CSF_TRIP_CLOSE_FAIL_ACTIVE'
        , p_msg_type => g_error_message
        );
        GOTO NEXT_TRIP;
      END IF;

      IF p_trip_action = g_action_block_trip AND (p_trips(i).end_date_time + g_overtime) < SYSDATE THEN
        IF l_debug THEN
          debug('  Trip is past dated. Close it rather than blocking', l_api_name, fnd_log.level_statement);
        END IF;
        l_trip_action := g_action_close_trip;
      ELSE
        l_trip_action := p_trip_action;
      END IF;

      change_trip(
        x_return_status         => x_return_status
      , x_msg_data              => x_msg_data
      , x_msg_count             => x_msg_count
      , p_trip                  => p_trips(i)
      , p_object_version_number => p_trips(i).object_version_number
      , p_status                => l_new_trip_status
      , p_update_tasks          => fnd_api.g_true
      , p_task_action           => l_trip_action
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        add_message(
          p_trip     => p_trips(i)
        , p_reason   => fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
        , p_msg_name => 'CSF_TRIP_UPDATE_FAIL_OTHER'
        , p_msg_type => g_error_message
        );
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        add_message(p_trips(i));
      END IF;

      <<NEXT_TRIP>>
      NULL;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END update_trip_status;

  /******************************************************************************************
  *                                                                                         *
  *                Public Functions and Procedures dealing with a Single Trip               *
  *                                                                                         *
  *******************************************************************************************/
  /**
   * Refer to the Package Spec for documentation of this procedure
   */
  PROCEDURE create_trip(
    p_api_version           IN          NUMBER
  , p_init_msg_list         IN          VARCHAR2
  , p_commit                IN          VARCHAR2
  , x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_resource_id           IN          NUMBER
  , p_resource_type         IN          VARCHAR2
  , p_start_date_time       IN          DATE
  , p_end_date_time         IN          DATE
  , p_schedule_detail_id    IN          NUMBER
  , p_status                IN          NUMBER
  , p_find_tasks            IN          VARCHAR2
  , x_trip_id              OUT  NOCOPY  NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_TRIP';
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_trips                 trip_tbl_type;
    l_resource              csf_resource_pub.resource_tbl_type;
    l_new_trip              trip_rec_type;

    l_shift_tasks_exist     VARCHAR2(1);

    -- Query for the existence of any Shift Task in the Trip Inteval for the Resource.
    CURSOR c_st_exist IS
      SELECT 'Y'
        FROM jtf_tasks_b t
       WHERE t.owner_id        = p_resource_id
         AND t.owner_type_code = p_resource_type
         AND t.scheduled_start_date BETWEEN p_start_date_time AND p_end_date_time
         AND t.task_type_id IN (20, 21)
         AND NVL(t.deleted_flag, 'N') = 'N'
         AND ROWNUM = 1;
  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF p_init_msg_list = fnd_api.g_true THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('Creating a Trip for Resource#' || p_resource_id || ' between '
            || to_char(p_start_date_time, 'DD-MON-YYYY HH24:MI:SS') || ' and '
            || to_char(p_end_date_time, 'DD-MON-YYYY HH24:MI:SS'), l_api_name, fnd_log.level_procedure);
    END IF;

    l_resource := csf_resource_pub.resource_tbl_type();
    l_resource.extend();
    l_resource(1).resource_id   := p_resource_id;
    l_resource(1).resource_type := p_resource_type;
    l_trips := find_trips(l_resource, p_start_date_time, p_end_date_time);

    -- Check#1 - No Trips should be found for the given criteria
    IF l_trips.COUNT > 0 THEN
      IF l_debug THEN
        debug('  Trips already exists for the Resource in the specified interval', l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_TRIP_CREATE_FAIL_DUP');
      fnd_message.set_token('RESOURCE', get_resource_info(p_resource_id, p_resource_type));
      fnd_message.set_token('START_TIME', format_date(p_start_date_time));
      fnd_message.set_token('END_TIME', format_date(p_end_date_time));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Check#2 - No Shift Tasks in the Interval where the Trip is going to be created.
    IF l_debug THEN
      debug('  Searching for existence of any Shift Tasks in that interval', l_api_name, fnd_log.level_statement);
    END IF;

    OPEN c_st_exist;
    FETCH c_st_exist INTO l_shift_tasks_exist;
    IF c_st_exist%NOTFOUND THEN
      l_shift_tasks_exist := 'N';
    END IF;
    CLOSE c_st_exist;

    IF l_shift_tasks_exist = 'Y' THEN
      IF l_debug THEN
        debug('  Shift Tasks exist for the Resource in the specified interval', l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_TRIP_CREATE_FAIL_ST_EXIST');
      fnd_message.set_token('RESOURCE', get_resource_info(p_resource_id, p_resource_type));
      fnd_message.set_token('START_TIME', format_date(p_start_date_time));
      fnd_message.set_token('END_TIME', format_date(p_end_date_time));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- All validations passed. Create the Trip.
    new_trip(
      x_return_status        => x_return_status
    , x_msg_data             => x_msg_data
    , x_msg_count            => x_msg_count
    , p_resource_id          => p_resource_id
    , p_resource_type        => p_resource_type
    , p_start_date_time      => p_start_date_time
    , p_end_date_time        => p_end_date_time
    , p_status               => p_status
    , p_schedule_detail_id   => p_schedule_detail_id
    , p_find_tasks           => p_find_tasks
    , x_trip                 => l_new_trip
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('CSF', 'CSF_TRIP_CREATE_FAIL_OTHER');
      fnd_message.set_token('RESOURCE', get_resource_info(p_resource_id, p_resource_type));
      fnd_message.set_token('START_TIME', format_date(p_start_date_time));
      fnd_message.set_token('END_TIME', format_date(p_end_date_time));
      fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
      fnd_msg_pub.ADD;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_trip_id := l_new_trip.trip_id;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END create_trip;

  /**
   * Refer to the Package Spec for documentation of this procedure
   */
  PROCEDURE update_trip(
    p_api_version              IN          NUMBER
  , p_init_msg_list            IN          VARCHAR2
  , p_commit                   IN          VARCHAR2
  , x_return_status           OUT  NOCOPY  VARCHAR2
  , x_msg_data                OUT  NOCOPY  VARCHAR2
  , x_msg_count               OUT  NOCOPY  NUMBER
  , p_trip_id                  IN          NUMBER
  , p_object_version_number    IN          NUMBER
  , p_available_hours          IN          NUMBER
  , p_upd_available_hours      IN          NUMBER
  , p_available_hours_before   IN          NUMBER
  , p_available_hours_after    IN          NUMBER
  , p_status                   IN          NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_TRIP';
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_trip                   trip_rec_type;
  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_trip_id IS NULL OR p_trip_id = fnd_api.g_miss_num THEN
      -- Invalid Trip ID passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_TRIP_ID');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_object_version_number IS NULL OR p_object_version_number = fnd_api.g_miss_num THEN
      -- Invalid Object Version Number passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_OBJECT_VERSION_NUMBER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_available_hours IS NOT NULL AND p_upd_available_hours IS NOT NULL THEN
      -- Error out as both cant be passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_UPD_AVAILABLE_HOURS');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_trip := get_trip(p_trip_id);
    IF l_trip.trip_id IS NULL THEN
      fnd_message.set_name('CSF', 'CSF_INVALID_TRIP_ID');
      fnd_message.set_token('TRIP_ID', p_trip_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    change_trip(
      x_return_status          => x_return_status
    , x_msg_data               => x_msg_data
    , x_msg_count              => x_msg_count
    , p_trip                   => l_trip
    , p_object_version_number  => p_object_version_number
    , p_available_hours        => p_available_hours
    , p_upd_available_hours    => p_upd_available_hours
    , p_available_hours_before => p_available_hours_before
    , p_available_hours_after  => p_available_hours_after
    , p_status                 => p_status
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('CSF', 'CSF_TRIP_UPDATE_FAIL_OTHER');
      fnd_message.set_token('RESOURCE', get_resource_info(l_trip.resource_id, l_trip.resource_type));
      fnd_message.set_token('START_TIME', format_date(l_trip.start_date_time));
      fnd_message.set_token('END_TIME', format_date(l_trip.end_date_time));
      fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
      fnd_msg_pub.ADD;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END;

  /**
   * Refer to the Package Spec for documentation of this procedure
   */
  PROCEDURE delete_trip (
    p_api_version            IN          NUMBER
  , p_init_msg_list          IN          VARCHAR2
  , p_commit                 IN          VARCHAR2
  , x_return_status         OUT  NOCOPY  VARCHAR2
  , x_msg_data              OUT  NOCOPY  VARCHAR2
  , x_msg_count             OUT  NOCOPY  NUMBER
  , p_trip_id                IN          NUMBER
  , p_object_version_number  IN          NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_TRIP';
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
    l_trip                 trip_rec_type;
  BEGIN
    SAVEPOINT delete_trip;

    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('Deleting the Trip #' || p_trip_id, l_api_name, fnd_log.level_procedure);
    END IF;

    IF p_trip_id IS NULL OR p_trip_id = fnd_api.g_miss_num THEN
      -- Invalid Trip ID passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_TRIP_ID');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_object_version_number IS NULL OR p_object_version_number = fnd_api.g_miss_num THEN
      -- Invalid Object Version Number passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_OBJECT_VERSION_NUMBER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_trip := get_trip(p_trip_id);
    -- No Trips found for the given Trip ID
    IF l_trip.trip_id IS NULL THEN
      fnd_message.set_name('CSF', 'CSF_INVALID_TRIP_ID');
      fnd_message.set_token('TRIP_ID', p_trip_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    remove_trip(
      x_return_status         => x_return_status
    , x_msg_data              => x_msg_data
    , x_msg_count             => x_msg_count
    , p_trip                  => l_trip
    , p_object_version_number => p_object_version_number
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        debug(    '  Unable to delete the Trip: Error = '
               || fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
             , l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_TRIP_DELETE_FAIL_OTHER');
      fnd_message.set_token('RESOURCE', get_resource_info(l_trip.resource_id, l_trip.resource_type));
      fnd_message.set_token('START_TIME', format_date(l_trip.start_date_time));
      fnd_message.set_token('END_TIME', format_date(l_trip.end_date_time));
      fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
      fnd_msg_pub.ADD;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO delete_trip;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_trip;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      ROLLBACK TO delete_trip;
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END delete_trip;

  /**
   * Refer to the Package Spec for documentation of this procedure
   */
  PROCEDURE fix_trip(
    p_api_version            IN          NUMBER
  , p_init_msg_list          IN          VARCHAR2
  , p_commit                 IN          VARCHAR2
  , x_return_status         OUT  NOCOPY  VARCHAR2
  , x_msg_data              OUT  NOCOPY  VARCHAR2
  , x_msg_count             OUT  NOCOPY  NUMBER
  , p_trip_id                IN          NUMBER
  , p_object_version_number  IN          NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'FIX_TRIPS';
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_trip               trip_rec_type;
  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('Fixing the Trip #' || p_trip_id, l_api_name, fnd_log.level_procedure);
    END IF;

    IF p_trip_id IS NULL OR p_trip_id = fnd_api.g_miss_num THEN
      -- Invalid Trip ID passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_TRIP_ID');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_object_version_number IS NULL OR p_object_version_number = fnd_api.g_miss_num THEN
      -- Invalid Object Version Number passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_OBJECT_VERSION_NUMBER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_trip := get_trip(p_trip_id);
    IF l_trip.trip_id IS NULL THEN
      fnd_message.set_name('CSF', 'CSF_INVALID_TRIP_ID');
      fnd_message.set_token('TRIP_ID', p_trip_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    correct_trip(
      x_return_status         => x_return_status
    , x_msg_data              => x_msg_data
    , x_msg_count             => x_msg_count
    , p_trip                  => l_trip
    , p_object_version_number => p_object_version_number
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        debug('  Unable to fix the Trip', l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_TRIP_FIX_FAIL_OTHER');
      fnd_message.set_token('RESOURCE', get_resource_info(l_trip.resource_id, l_trip.resource_type));
      fnd_message.set_token('START_TIME', format_date(l_trip.start_date_time));
      fnd_message.set_token('END_TIME', format_date(l_trip.end_date_time));
      fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
      fnd_msg_pub.ADD;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END fix_trip;

  /******************************************************************************************
  *                                                                                         *
  *                   Public Functions and Procedures dealing generally on Trips            *
  *                                                                                         *
  *******************************************************************************************/

  /**
   * Refer to the Package Spec for documentation of this procedure
   */
  PROCEDURE find_trip(
    p_api_version      IN          NUMBER
  , p_init_msg_list    IN          VARCHAR2
  , x_return_status   OUT  NOCOPY  VARCHAR2
  , x_msg_data        OUT  NOCOPY  VARCHAR2
  , x_msg_count       OUT  NOCOPY  NUMBER
  , p_resource_id      IN          NUMBER
  , p_resource_type    IN          VARCHAR2
  , p_start_date_time  IN          DATE
  , p_end_date_time    IN          DATE
  , p_overtime_flag    IN          VARCHAR2
  , x_trip            OUT  NOCOPY  trip_rec_type
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'FIND_TRIP';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_debug       CONSTANT BOOLEAN      := g_debug = 'Y';
    l_resource_tbl         csf_resource_pub.resource_tbl_type;
    l_trips                trip_tbl_type;
  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    l_resource_tbl := csf_resource_pub.resource_tbl_type();
    l_resource_tbl.extend();
    l_resource_tbl(1).resource_id   := p_resource_id;
    l_resource_tbl(1).resource_type := p_resource_type;

    l_trips := find_trips(l_resource_tbl, p_start_date_time, p_end_date_time, p_overtime_flag);

    IF l_trips.COUNT = 0 OR l_trips.COUNT > 1 THEN
      IF l_trips.COUNT = 0 THEN
        fnd_message.set_name('CSF', 'CSF_NO_TRIPS_FOUND');
      ELSE
        fnd_message.set_name('CSF', 'CSF_MULTIPLE_TRIPS_FOUND');
      END IF;
      fnd_message.set_token('RESOURCE', get_resource_info(p_resource_id, p_resource_type));
      fnd_message.set_token('START_TIME', format_date(p_start_date_time));
      fnd_message.set_token('END_TIME', format_date(p_end_date_time));
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_trip := l_trips(l_trips.FIRST);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END find_trip;

  /**
   * Refer to the Package Spec for documentation of this procedure
   */
  PROCEDURE find_trip(
    p_api_version      IN          NUMBER
  , p_init_msg_list    IN          VARCHAR2
  , x_return_status   OUT  NOCOPY  VARCHAR2
  , x_msg_data        OUT  NOCOPY  VARCHAR2
  , x_msg_count       OUT  NOCOPY  NUMBER
  , p_resource_id      IN          NUMBER
  , p_resource_type    IN          VARCHAR2
  , p_start_date_time  IN          DATE
  , p_end_date_time    IN          DATE
  , p_overtime_flag    IN          VARCHAR2
  , x_trip_id         OUT  NOCOPY  NUMBER
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'FIND_TRIP';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_debug       CONSTANT BOOLEAN      := g_debug = 'Y';
    l_trip        trip_rec_type;
  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    find_trip(
      p_api_version     => p_api_version
    , p_init_msg_list   => p_init_msg_list
    , x_return_status   => x_return_status
    , x_msg_data        => x_msg_data
    , x_msg_count       => x_msg_count
    , p_resource_id     => p_resource_id
    , p_resource_type   => p_resource_type
    , p_start_date_time => p_start_date_time
    , p_end_date_time   => p_end_date_time
    , p_overtime_flag   => p_overtime_flag
    , x_trip            => l_trip
    );

    IF x_return_status = fnd_api.g_ret_sts_success THEN
      x_trip_id := l_trip.trip_id;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END find_trip;

  /**
   * Refer to the Package Spec for documentation of this procedure
   */
  PROCEDURE find_trips(
    p_api_version      IN          NUMBER
  , p_init_msg_list    IN          VARCHAR2
  , x_return_status   OUT  NOCOPY  VARCHAR2
  , x_msg_data        OUT  NOCOPY  VARCHAR2
  , x_msg_count       OUT  NOCOPY  NUMBER
  , p_resource_tbl     IN          csf_resource_pub.resource_tbl_type
  , p_start_date_time  IN          DATE
  , p_end_date_time    IN          DATE
  , p_overtime_flag    IN          VARCHAR2
  , x_trips           OUT  NOCOPY  trip_tbl_type
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'FIND_TRIP';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_debug       CONSTANT BOOLEAN      := g_debug = 'Y';
  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    x_trips := find_trips(p_resource_tbl, p_start_date_time, p_end_date_time, p_overtime_flag);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END find_trips;

  /**
   * Refer to the Package Spec for documentation of this procedure
   */
  PROCEDURE process_action(
    p_api_version             IN          NUMBER
  , p_init_msg_list           IN          VARCHAR2
  , p_commit                  IN          VARCHAR2
  , x_return_status          OUT  NOCOPY  VARCHAR2
  , x_msg_data               OUT  NOCOPY  VARCHAR2
  , x_msg_count              OUT  NOCOPY  NUMBER
  , p_action                  IN          VARCHAR2
  , p_trip_id                 IN          NUMBER
  , p_resource_tbl            IN          csf_resource_pub.resource_tbl_type
  , p_shift_type              IN         VARCHAR2
  , p_start_date              IN          DATE
  , p_end_date                IN          DATE
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'PROCESS_ACTION';
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_trips              trip_tbl_type;
    l_trip               trip_rec_type;
    l_param_name         VARCHAR2(30);
    l_shift_type         VARCHAR2(30);



  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;
    l_shift_type := p_shift_type;
    IF l_debug THEN
      debug('Generating Resource Trips for a Resource', l_api_name, fnd_log.level_procedure);
      debug('  Action     = ' || p_action, l_api_name, fnd_log.level_statement);
      IF p_trip_id IS NOT NULL THEN
        debug('  Trip ID    = ' || p_trip_id, l_api_name, fnd_log.level_statement);
      END IF;

      IF p_start_date IS NOT NULL THEN
        debug('  Time Frame = ' || p_start_date || ' to ' || p_end_date, l_api_name, fnd_log.level_statement);
      END IF;

      IF p_resource_tbl IS NOT NULL AND p_resource_tbl.COUNT = 1 THEN
        debug('  Resource   = ' || p_resource_tbl(p_resource_tbl.FIRST).resource_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;

    -- Checking whether all required parameters are passed.
    IF p_action IN (g_action_block_trip, g_action_unblock_trip) THEN
      IF p_trip_id IS NULL AND (p_resource_tbl IS NULL OR p_start_date IS NULL OR p_end_date IS NULL) THEN
        IF (p_resource_tbl IS NOT NULL OR p_start_date IS NOT NULL OR p_end_date IS NOT NULL) THEN
          IF p_resource_tbl IS NULL THEN
            l_param_name := 'P_RESOURCE_TBL';
          ELSIF p_start_date IS NULL THEN
            l_param_name := 'P_START_DATE';
          ELSE
            l_param_name := 'P_END_DATE';
          END IF;
        ELSE
          l_param_name := 'P_TRIP_ID';
        END IF;
      END IF;
    ELSIF p_resource_tbl IS NULL THEN
      l_param_name := 'P_RESOURCE_TBL';
    ELSIF p_start_date IS NULL THEN
      l_param_name := 'P_START_DATE';
    ELSIF p_end_date IS NULL THEN
      l_param_name := 'P_END_DATE';
    END IF;

    IF l_param_name IS NOT NULL THEN
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', l_param_name);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Getting the Trips only for actions like DELETE, FIX, BLOCK, UNBLOCK.
    IF p_action NOT IN (g_action_create_trip, g_action_upgrade_trip, g_action_replace_trip) THEN
      IF p_trip_id IS NOT NULL THEN
        l_trips(1) := get_trip(p_trip_id);
      ELSE
        l_trips := find_trips(p_resource_tbl, p_start_date, p_end_date);
      END IF;

      IF l_trips.COUNT = 0 THEN
        IF p_trip_id IS NOT NULL THEN
          fnd_message.set_name('CSF', 'CSF_INVALID_TRIP_ID');
          fnd_message.set_token('TRIP_ID', p_trip_id);
        ELSE
          fnd_message.set_name('CSF', 'CSF_NO_TRIPS_FOUND');
          IF p_resource_tbl.COUNT = 1 THEN
            fnd_message.set_token('RESOURCE', get_resource_info(
                                                                  p_resource_tbl(1).resource_id
                                                                , p_resource_tbl(1).resource_type
                                                                ));
          END IF;
          fnd_message.set_token('START_TIME', format_date(p_start_date));
          fnd_message.set_token('END_TIME', format_date(p_end_date));
          fnd_msg_pub.add;
          IF p_action = g_action_delete_trip
          THEN
          check_dangling_tasks(p_resource_tbl     =>    p_resource_tbl
                                  , p_start            =>    p_start_date
                                  , p_end              =>    p_end_date
                                  , x_return_status    =>    x_return_status
                                  , x_msg_data         =>    x_msg_data
                                  , x_msg_count        =>  	 x_msg_count);
          END IF;
        END IF;
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    g_messages.DELETE;
    IF p_action IN (g_action_create_trip, g_action_replace_trip) THEN


      create_trips(
        x_return_status    => x_return_status
      , x_msg_data         => x_msg_data
      , x_msg_count        => x_msg_count
      , p_resource_tbl     => p_resource_tbl
      , p_start_date       => p_start_date
      , p_end_date         => p_end_date
      , P_SHIFT_TYPE       => l_shift_type
      , p_delete_trips     => (p_action = g_action_replace_trip)
      );
    ELSIF p_action = g_action_upgrade_trip THEN
      upgrade_to_trips(
        x_return_status    => x_return_status
      , x_msg_data         => x_msg_data
      , x_msg_count        => x_msg_count
      , p_resource_tbl     => p_resource_tbl
      , p_start_date       => p_start_date
      , p_end_date         => p_end_date
      );
    ELSIF p_action = g_action_delete_trip THEN
      delete_trips(
        x_return_status    => x_return_status
      , x_msg_data         => x_msg_data
      , x_msg_count        => x_msg_count
      , p_trips            => l_trips
      );
    ELSIF p_action = g_action_fix_trip THEN
      fix_trips(
        x_return_status    => x_return_status
      , x_msg_data         => x_msg_data
      , x_msg_count        => x_msg_count
      , p_trips            => l_trips
      );
    ELSIF p_action IN (g_action_block_trip, g_action_unblock_trip, g_action_close_trip) THEN
      update_trip_status(
        x_return_status    => x_return_status
      , x_msg_data         => x_msg_data
      , x_msg_count        => x_msg_count
      , p_trip_action      => p_action
      , p_trips            => l_trips
      );
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    check_dangling_tasks(p_resource_tbl     =>    p_resource_tbl
                              , p_start            =>    p_start_date
                              , p_end              =>    p_end_date
                              , x_return_status    =>    x_return_status
                              , x_msg_data         =>    x_msg_data
                              , x_msg_count        =>  	 x_msg_count);
    check_duplicate_tasks(p_resource_tbl     =>    p_resource_tbl
                              , p_start            =>    p_start_date
                              , p_end              =>    p_end_date
                              , x_return_status    =>    x_return_status
                              , x_msg_data         =>    x_msg_data
                              , x_msg_count        =>  	 x_msg_count);
    process_messages(
      p_init_msg_list   => p_init_msg_list
    , x_return_status   => x_return_status
    , p_action          => p_action
    , p_trip_id         => p_trip_id
    , p_start_date      => p_start_date
    , p_end_date        => p_end_date
    , p_resource_tbl    => p_resource_tbl
    );

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

    fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END process_action;

  /******************************************************************************************
  *                                                                                         *
  *         Functions and Procedures dealing with Generate Trips Concurrent Program         *
  *                                                                                         *
  *******************************************************************************************/

  PROCEDURE generate_trips(
    errbuf           OUT    NOCOPY    VARCHAR2
  , retcode          OUT    NOCOPY    VARCHAR2
  , p_action          IN              VARCHAR2
  , p_start_date      IN              VARCHAR2
  , p_num_days        IN              NUMBER
  , p_resource_type   IN              VARCHAR2
  , p_resource_id     IN              NUMBER
  , p_shift_type      IN              VARCHAR2 DEFAULT NULL
  , p_res_shift_add   IN              VARCHAR2 DEFAULT NULL
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'GENERATE_TRIPS';

    l_msg_data               VARCHAR2(2000);
    l_msg_count              NUMBER;
    l_return_status          VARCHAR2(1);
    l_start_date             DATE;
    l_end_date               DATE;
    l_num_days               NUMBER;
    l_resources_failed       NUMBER;
    l_resources_success      NUMBER;
    l_resource               csf_resource_pub.resource_tbl_type;
    l_resource_info          VARCHAR2(500);
    l_resource_id_tbl        jtf_number_table;
    l_resource_type_tbl      jtf_varchar2_table_100;
    l_shift_type             VARCHAR2(100);
    l_shift_parameter        varchar2(100);
    l_conv_end_date          DATE;

	l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    CURSOR C_RESOURCES IS
      SELECT RESOURCE_ID,
 	         RESOURCE_TYPE
	  FROM(
	       SELECT RESOURCE_ID,
		          RESOURCE_TYPE
		   FROM   CSF_SELECTED_RESOURCES_V
	       MINUS
		   SELECT DISTINCT
		          A.RESOURCE_ID,
				  A.RESOURCE_TYPE
		   FROM   CSF_SELECTED_RESOURCES_V A,
         	      JTF_RS_DEFRESROLES_VL B,
				  JTF_RS_ALL_RESOURCES_VL C,
				  JTF_RS_ROLES_B D
		   WHERE B.ROLE_RESOURCE_ID=A.RESOURCE_ID
		   AND   C.RESOURCE_ID = B.ROLE_RESOURCE_ID
		   AND   C.RESOURCE_TYPE =A.RESOURCE_TYPE
		   AND   D.ROLE_ID     = B.ROLE_ID
		   AND   B.ROLE_TYPE_CODE ='CSF_THIRD_PARTY'
		   AND     NVL( B.DELETE_FLAG, 'N') = 'N'
		   AND   (SYSDATE >= TRUNC (B.RES_RL_START_DATE) OR B.RES_RL_START_DATE IS NULL)
           AND   (SYSDATE <= TRUNC (B.RES_RL_END_DATE) + 1 OR B.RES_RL_END_DATE IS NULL)
		   AND     ROLE_CODE IN ( 'CSF_THIRD_PARTY_SERVICE_PROVID', 'CSF_THIRD_PARTY_ADMINISTRATOR')
		)
       ORDER BY RESOURCE_TYPE, RESOURCE_ID;


  BEGIN
    /******************* Concurrent Program Start Message *******************/

    fnd_message.set_name('CSF', 'CSF_GTR_CP_STARTED');
    debug(fnd_message.get, 'GENERATE_TRIPS', g_level_cp_output);

    init_package;
    g_suppress_res_info := TRUE;

    g_res_add_prof :=p_res_shift_add;
    g_shift_type := p_shift_type;
    l_shift_parameter := p_shift_type;




    /************* Concurrent Program Input Parameters Validation *************/

    -- Get the Start Date (with Timezone Conversions) from the passed Start Date
    IF p_start_date IS NOT NULL THEN
      l_start_date := fnd_date.canonical_to_date(p_start_date);

      IF l_start_date < SYSDATE AND p_action IN (g_action_create_trip, g_action_replace_trip) THEN
        l_start_date := NULL;
      END IF;
    END IF;

    IF l_start_date IS NULL THEN
      -- Get the System Date in Client Timezone
      l_start_date := csf_timezones_pvt.date_to_client_tz_date(SYSDATE);
      -- Convert the time to System Timezone
      l_start_date := csf_timezones_pvt.date_to_server_tz_date(TRUNC(l_start_date));
    END IF;

    IF p_num_days IS NULL OR p_num_days <= 0 THEN
      l_num_days := CSR_SCHEDULER_PUB.GET_SCH_PARAMETER_VALUE('spPlanScope');
      IF l_num_days IS NULL OR l_num_days <=0 THEN
        l_num_days := 7;
      END IF;
    ELSE
      l_num_days := p_num_days;
    END IF;

    IF p_action = g_action_close_trip THEN
      l_end_date   := l_start_date;
      l_start_date := l_end_date - l_num_days + 1;
    ELSE
      l_end_date   := l_start_date + l_num_days - 1;
    END IF;
   if p_shift_type = 'REGULAR AND STANDBY'
   then
     g_shift_type := null;
     l_shift_parameter := null;
  end if;

    -- End Date will be 00:00 hours of the Start Date. So making it 23:59.
    l_end_date := l_end_date + (g_secs_in_day - 1) / g_secs_in_day;

   -- added this for the bug 8410630
    /* l_conv_end_date:=  fnd_timezones_pvt.adjust_datetime(
                    date_time => l_end_date
                  , from_tz   => g_client_tz_code
                  , to_tz     => g_server_tz_code
                  );

    -- added if condition for the bug 8410630
    IF l_conv_end_date > l_end_date
    then
      l_end_date := l_conv_end_date;
    end if;*/

    -- Concurrent Program Parameters
    IF p_resource_id IS NOT NULL AND p_resource_type IS NOT NULL THEN
      fnd_message.set_name('CSF', 'CSF_GTR_CP_PARAMS_RESOURCE');
      fnd_message.set_token('RESOURCE', get_resource_info(p_resource_id, p_resource_type));

      l_resource_info := fnd_message.get;
      l_resource_id_tbl    := jtf_number_table();
      l_resource_id_tbl.extend(1);
      l_resource_id_tbl(1) := p_resource_id;

      l_resource_type_tbl := jtf_varchar2_table_100();
      l_resource_type_tbl.extend(1);
      l_resource_type_tbl(1) := p_resource_type;
    ELSE
      l_resource_info := '';

      OPEN c_resources;
      FETCH c_resources BULK COLLECT INTO l_resource_id_tbl, l_resource_type_tbl;
      CLOSE c_resources;
    END IF;

    fnd_message.set_name('CSF', 'CSF_GTR_CP_PARAMS');
    fnd_message.set_token('ACTION', p_action);
    fnd_message.set_token('START_DATE', l_start_date);
    fnd_message.set_token('END_DATE', l_end_date);
    fnd_message.set_token('RESOURCE_INFO', l_resource_info);
    debug(fnd_message.get, 'GENERATE_TRIPS', g_level_cp_output);

    /********************* Concurrent Program Execution *********************/
    l_resources_failed   := 0;
    l_resources_success  := 0;
    IF l_resource_id_tbl IS NOT NULL THEN
      l_resource := csf_resource_pub.resource_tbl_type();
      l_resource.extend(1);

      FOR i IN 1..l_resource_id_tbl.COUNT LOOP
        l_resource(1).resource_id   := l_resource_id_tbl(i);
        l_resource(1).resource_type := l_resource_type_tbl(i);

        l_resource_info := get_resource_info(l_resource(1).resource_id, l_resource(1).resource_type);
        fnd_message.set_name('CSF', 'CSF_RESOURCE_PROCESSED');
        fnd_message.set_token('RESOURCE', l_resource_info);
        debug(fnd_message.get, 'GEN_RESOURCE_TRIPS', g_level_cp_output);
        IF l_debug THEN
          debug('*****Starting generating Trips for Resource ID  #' || l_resource(1).resource_id||
		  ' Resource Type  #'|| l_resource(1).resource_type, l_api_name, fnd_log.level_statement);
        END IF;
        process_action(
          p_api_version       => 1.0
        , p_init_msg_list     => fnd_api.g_true
        , p_commit            => fnd_api.g_true
        , x_return_status     => l_return_status
        , x_msg_data          => l_msg_data
        , x_msg_count         => l_msg_count
        , p_action            => p_action
        , p_resource_tbl      => l_resource
        , p_shift_type        => l_shift_parameter
        , p_start_date        => l_start_date
        , p_end_date          => l_end_date
        );

        -- Print all the messages encountered
        FOR i IN 1..l_msg_count LOOP
          debug('  ' || fnd_msg_pub.get(i, fnd_api.g_false), l_api_name, g_level_cp_output);
        END LOOP;
        debug(' ', l_api_name, g_level_cp_output);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          l_resources_failed := l_resources_failed + 1;
          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          l_resources_success := l_resources_success + 1;
        END IF;
      END LOOP;
    END IF;

    /**************** Concurrent Program Completion Message ****************/

    debug(' ', '', g_level_cp_output);

    IF l_resources_failed > 0 THEN
      retcode := 1;
      fnd_message.set_name('CSF', 'CSF_CP_DONE_WARNING');
    ELSE
      retcode := 0;
      fnd_message.set_name('CSF', 'CSF_CP_DONE_SUCCESS');
    END IF;

    errbuf := fnd_message.get;
    debug(errbuf, l_api_name, g_level_cp_output);

    debug(' ', '', g_level_cp_output);
    fnd_message.set_name('CSF', 'CSF_RESOURCES_DONE_SUCCESS');
    fnd_message.set_token('NUMBER', l_resources_success);
    debug(fnd_message.get, l_api_name, g_level_cp_output);

    fnd_message.set_name('CSF', 'CSF_RESOURCES_DONE_FAILED');
    fnd_message.set_token('NUMBER', l_resources_failed);
    debug(fnd_message.get, l_api_name, g_level_cp_output);

    fnd_message.set_name('CSF', 'CSF_RESOURCES_DONE_TOTAL');
    fnd_message.set_token('NUMBER', l_resources_success + l_resources_failed);
    debug(fnd_message.get, l_api_name, g_level_cp_output);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM IS NOT NULL THEN

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
          debug(fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false), l_api_name, g_level_cp_output);
        END IF;
      END IF;

      retcode := 2;
      fnd_message.set_name('CSF', 'CSF_CP_DONE_ERROR');
      errbuf := fnd_message.get;
      debug(errbuf, l_api_name, g_level_cp_output);
  END generate_trips;


  PROCEDURE optimize_across_trips(
    p_api_version             IN          NUMBER
  , p_init_msg_list           IN          VARCHAR2
  , p_commit                  IN          VARCHAR2
  , x_return_status          OUT  NOCOPY  VARCHAR2
  , x_msg_data               OUT  NOCOPY  VARCHAR2
  , x_msg_count              OUT  NOCOPY  NUMBER
  , x_conc_request_id        OUT  NOCOPY  NUMBER
  , p_resource_tbl            IN          csf_requests_pvt.resource_tbl_type
  , p_start_date              IN          DATE
  , p_end_date                IN          DATE
  ) IS
    l_api_name     CONSTANT VARCHAR2(30)   := 'OPTIMIZE_ACROSS_TRIPS';
    l_api_version  CONSTANT NUMBER         := 1.0;
    l_debug        CONSTANT BOOLEAN        := g_debug = 'Y';

    l_sched_request_id      NUMBER         DEFAULT NULL;
    l_conc_request_id       NUMBER         DEFAULT NULL;
    l_oat_string            VARCHAR2(100)  DEFAULT NULL;
    --
    l_resources_tbl         csf_requests_pvt.resource_tbl_type;
  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('CSF_TRIPS_PUB.Optimize Across Trips', l_api_name, fnd_log.level_procedure);
      debug('  No of resources in list = ' || p_resource_tbl.COUNT, l_api_name, fnd_log.level_statement);
      debug('  Time Frame = ' || p_start_date || ' to ' || p_end_date, l_api_name, fnd_log.level_statement);
    END IF;

    l_resources_tbl := p_resource_tbl;
    FOR i IN 1..l_resources_tbl.COUNT LOOP
      l_resources_tbl(i).planwin_start := p_start_date;
      l_resources_tbl(i).planwin_end   := p_end_date;
    END LOOP;

    -- create a scheduler request
    csf_requests_pvt.create_scheduler_request (
        p_api_version      => 1.0
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      , p_name             => 'OptimizeAcrossTrips'
      , p_object_id        => -1
      , p_resource_tbl     => l_resources_tbl
      , x_request_id       => l_sched_request_id
    );

    -- Standard check of the return status for the API call
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    fnd_message.set_name('CSR','OPTIMIZE_ACROSS_TRIPS');
    l_oat_string := fnd_message.get;

    -- submit the concurrent request 'Optimize Across Trips'
    x_conc_request_id := fnd_request.submit_request (
        application => 'CSR'
      , program     => 'OPTIMIZE_ACROSS_TRIPS'
      , sub_request => FALSE
      , argument1   => l_sched_request_id
    );

    IF x_conc_request_id = 0 THEN
      -- FND_REQUEST.SUBMIT_REQUEST should have populated the Message Stack.
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- needed to submit the request properly
    COMMIT;

    fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      ROLLBACK;
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END optimize_across_trips;

PROCEDURE create_trip1(
    p_api_version           IN          NUMBER
  , p_init_msg_list         IN          VARCHAR2
  , p_commit                IN          VARCHAR2
  , x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_resource_id           IN          NUMBER
  , p_resource_type         IN          VARCHAR2
  , p_start_date_time       IN          DATE
  , p_end_date_time         IN          DATE
  , p_schedule_detail_id    IN          NUMBER
  , p_status                IN          NUMBER
  , p_find_tasks            IN          VARCHAR2
  , p_arr_party_site       IN          NUMBER
  , p_arr_party            IN          NUMBER
  , p_dep_party_site       IN          NUMBER
  , p_dep_party            IN          NUMBER
  , p_shift_type           IN          VARCHAR2
  , x_trip_id              OUT  NOCOPY  NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_TRIP';
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_trips                 trip_tbl_type;
    l_resource              csf_resource_pub.resource_tbl_type;
    l_new_trip              trip_rec_type;

    l_shift_tasks_exist     VARCHAR2(1);
    l_trip_exist            VARCHAR2(1);
    l_overtime              NUMBER;

    -- Query for the existence of any Shift Task in the Trip Inteval for the Resource.
    CURSOR c_st_exist IS
      SELECT 'Y'
        FROM jtf_tasks_b t
       WHERE t.owner_id        = p_resource_id
         AND t.owner_type_code = p_resource_type
         AND t.scheduled_start_date BETWEEN p_start_date_time AND p_end_date_time
         AND t.task_type_id IN (20, 21)
         AND NVL(t.deleted_flag, 'N') = 'N'
         AND ROWNUM = 1;

     CURSOR c_trip_exist
     is
        SELECT 'Y'
        FROM  cac_sr_object_capacity
        WHERE p_start_date_time <= (end_date_time + g_overtime)
          AND p_end_date_time >= start_date_time
          AND object_id=p_resource_id;

  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF p_init_msg_list = fnd_api.g_true THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;



    OPEN c_st_exist;
    FETCH c_st_exist INTO l_shift_tasks_exist;
    IF c_st_exist%NOTFOUND THEN
      l_shift_tasks_exist := 'N';
    END IF;
    CLOSE c_st_exist;

    OPEN c_trip_exist;
    FETCH c_trip_exist INTO l_trip_exist;
    IF c_trip_exist%NOTFOUND THEN
      l_trip_exist := 'N';
    END IF;
    CLOSE c_trip_exist;

    IF (l_shift_tasks_exist = 'Y' or l_trip_exist = 'Y') THEN
      IF l_debug THEN
        debug('  Shift Tasks exist for the Resource in the specified interval', l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_TRIP_CREATE_FAIL_ST_EXIST');
      fnd_message.set_token('RESOURCE', get_resource_info(p_resource_id, p_resource_type));
      fnd_message.set_token('START_TIME', format_date(p_start_date_time));
      fnd_message.set_token('END_TIME', format_date(p_end_date_time));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- All validations passed. Create the Trip.
    new_trip1(
      x_return_status        => x_return_status
    , x_msg_data             => x_msg_data
    , x_msg_count            => x_msg_count
    , p_resource_id          => p_resource_id
    , p_resource_type        => p_resource_type
    , p_start_date_time      => p_start_date_time
    , p_end_date_time        => p_end_date_time
    , p_status               => p_status
    , p_schedule_detail_id   => p_schedule_detail_id
    , p_find_tasks           => p_find_tasks
	, p_arr_party_site       => p_arr_party_site
    , p_arr_party            => p_arr_party
    , p_dep_party_site       => p_dep_party_site
    , p_dep_party            => p_dep_party
    , p_shift_type           => p_shift_type
    , x_trip                 => l_new_trip
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('CSF', 'CSF_TRIP_CREATE_FAIL_OTHER');
      fnd_message.set_token('RESOURCE', get_resource_info(p_resource_id, p_resource_type));
      fnd_message.set_token('START_TIME', format_date(p_start_date_time));
      fnd_message.set_token('END_TIME', format_date(p_end_date_time));
      fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
      fnd_msg_pub.ADD;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_trip_id := l_new_trip.trip_id;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END create_trip1;


  PROCEDURE new_trip1(
    x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_resource_id           IN          NUMBER
  , p_resource_type         IN          VARCHAR2
  , p_start_date_time       IN          DATE
  , p_end_date_time         IN          DATE
  , p_status                IN          NUMBER    DEFAULT NULL
  , p_schedule_detail_id    IN          NUMBER    DEFAULT NULL
  , p_find_tasks            IN          VARCHAR2  DEFAULT NULL
  , p_dep_task_id           IN          NUMBER    DEFAULT NULL
  , p_arr_task_id           IN          NUMBER    DEFAULT NULL
  , p_arr_party_site       IN          NUMBER
  , p_arr_party            IN          NUMBER
  , p_dep_party_site       IN          NUMBER
  , p_dep_party            IN          NUMBER
  , p_shift_type           IN          VARCHAR2
  , x_trip                 OUT  NOCOPY  trip_rec_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'NEW_TRIP';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_available_hours       NUMBER;
    l_time_occupied         NUMBER;
    l_dep_task_id           NUMBER;
    l_arr_task_id           NUMBER;
    i                       PLS_INTEGER;
    l_object_capacity_tbl   cac_sr_object_capacity_pub.object_capacity_tbl_type;
    l_object_tasks_tbl      cac_sr_object_capacity_pub.object_tasks_tbl_type;

    CURSOR c_linkable_tasks IS
      SELECT ta.task_assignment_id
           , ta.object_version_number
           , ta.task_id
           , ta.booking_start_date
           , ta.booking_end_date
           , csf_util_pvt.convert_to_minutes(
               ta.sched_travel_duration
             , ta.sched_travel_duration_uom
             ) travel_time
        FROM jtf_task_assignments ta
           , jtf_task_statuses_b ts
           , jtf_tasks_b t
       WHERE ta.resource_id               = p_resource_id
         AND ta.resource_type_code        = p_resource_type
         AND ta.assignee_role             = 'ASSIGNEE'
         AND ts.task_status_id            = ta.assignment_status_id
         AND NVL(ts.closed_flag, 'N')     = 'N'
         AND NVL(ts.completed_flag, 'N')  = 'N'
         AND NVL(ts.cancelled_flag, 'N')  = 'N'
         AND t.task_id = ta.task_id
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND ta.booking_start_date <= (p_end_date_time + g_overtime)
         AND ta.booking_end_date   >= p_start_date_time
         AND (t.task_type_id NOT IN (20, 21) OR t.task_id IN (l_dep_task_id, l_arr_task_id));

    CURSOR c_shift_tasks_info IS
      SELECT ta.task_assignment_id, ta.object_version_number, ta.task_id
        FROM jtf_task_assignments ta
       WHERE ta.task_id IN (l_dep_task_id, l_arr_task_id);

  BEGIN
    SAVEPOINT csf_new_trip;

    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('  Creating Trip between ' || format_date(p_start_date_time) || ' and ' || format_date(p_end_date_time), l_api_name, fnd_log.level_statement);
    END IF;

    -- Trip Available Hours
    l_available_hours := (p_end_date_time - p_start_date_time) * g_hours_in_day;

    -- Check#3 - The Trip Duration should be lesser than 24 Hours.
   IF l_available_hours > g_hours_in_day THEN
     IF check_dst(p_resource_id,p_start_date_time,p_end_date_time) = 'FALSE'
     THEN
      IF l_debug THEN
        debug('  The specified Trip Length is greater than one day', l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_TRIP_LENGTH_MORE_THAN_DAY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
     END IF;

    END IF;


    -- Create new Shift Tasks for the Trip to be created.
    IF p_dep_task_id IS NULL OR p_arr_task_id IS NULL THEN
      create_shift_tasks1(
        p_api_version         => 1.0
      , p_init_msg_list       => fnd_api.g_false
      , p_commit              => fnd_api.g_false
      , x_return_status       => x_return_status
      , x_msg_data            => x_msg_data
      , x_msg_count           => x_msg_count
      , p_resource_id         => p_resource_id
      , p_resource_type       => p_resource_type
      , p_start_date_time     => p_start_date_time
      , p_end_date_time       => p_end_date_time
      , p_create_dep_task     => p_dep_task_id IS NULL
      , p_create_arr_task     => p_arr_task_id IS NULL
      , p_arr_party_site       => p_arr_party_site
      , p_arr_party            => p_arr_party
      , p_dep_party_site       => p_dep_party_site
      , p_dep_party            => p_dep_party
      , x_dep_task_id         => l_dep_task_id
      , x_arr_task_id         => l_arr_task_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          debug('    Unable to Create Shift Tasks: Error = ' || x_msg_data, l_api_name, fnd_log.level_error);
        END IF;
        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
      IF l_debug THEN
        debug('    Created new Shift Tasks - Dep#' || l_dep_task_id || ' : Arr#' || l_arr_task_id, l_api_name, fnd_log.level_statement);
      END IF;
      l_dep_task_id := NVL(p_dep_task_id, l_dep_task_id);
      l_arr_task_id := NVL(p_arr_task_id, l_arr_task_id);
    ELSE
      -- Use the existing ones.
      l_dep_task_id := p_dep_task_id;
      l_arr_task_id := p_arr_task_id;
      IF l_debug THEN
        debug('    Using existing Shift Tasks - Dep#' || l_dep_task_id || ' : Arr#' || l_arr_task_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;

    i := 0;
    IF p_find_tasks IS NULL OR p_find_tasks = fnd_api.g_true THEN
      FOR v_task IN c_linkable_tasks LOOP
        l_time_occupied   := v_task.booking_end_date - v_task.booking_start_date; -- Scheduled Task Duration
        l_time_occupied   := l_time_occupied + NVL(v_task.travel_time, 0) / g_mins_in_day; -- Scheduled Travel Duration
        l_available_hours := l_available_hours - l_time_occupied * g_hours_in_day;

        IF l_debug THEN
          debug('    Linking TaskID #' || v_task.task_id || ' : Time Used = ' || l_time_occupied * g_hours_in_day, l_api_name, fnd_log.level_statement);
        END IF;

        i := i + 1;
        l_object_tasks_tbl(i).task_assignment_id      := v_task.task_assignment_id;
        l_object_tasks_tbl(i).task_assignment_ovn     := v_task.object_version_number;
        l_object_tasks_tbl(i).object_capacity_tbl_idx := 1;
      END LOOP;
    ELSE
      FOR v_task IN c_shift_tasks_info LOOP
        IF l_debug THEN
          debug('    Linking Shift TaskID #' || v_task.task_id, l_api_name, fnd_log.level_statement);
        END IF;

        i := i + 1;
        l_object_tasks_tbl(i).task_assignment_id      := v_task.task_assignment_id;
        l_object_tasks_tbl(i).task_assignment_ovn     := v_task.object_version_number;
        l_object_tasks_tbl(i).object_capacity_tbl_idx := 1;
      END LOOP;
    END IF;

    -- Create the Object Capacity Record
    l_object_capacity_tbl(1).object_type        := p_resource_type;
    l_object_capacity_tbl(1).object_id          := p_resource_id;
    l_object_capacity_tbl(1).start_date_time    := p_start_date_time;
    l_object_capacity_tbl(1).end_date_time      := p_end_date_time;
    l_object_capacity_tbl(1).available_hours    := l_available_hours;
    l_object_capacity_tbl(1).status             := p_status;
    l_object_capacity_tbl(1).availability_type         := p_shift_type;
    l_object_capacity_tbl(1).schedule_detail_id := p_schedule_detail_id;

    IF l_debug THEN
      debug('    Trip Available Hours = ' || l_available_hours, l_api_name, fnd_log.level_statement);
    END IF;

    -- Create the Trip by calling Object Capacity Table Handlers
    cac_sr_object_capacity_pub.insert_object_capacity(
      p_api_version          =>  1.0
    , p_init_msg_list        =>  fnd_api.g_false
    , x_return_status        =>  x_return_status
    , x_msg_count            =>  x_msg_count
    , x_msg_data             =>  x_msg_data
    , p_object_capacity      =>  l_object_capacity_tbl
    , p_update_tasks         =>  fnd_api.g_true
    , p_object_tasks         =>  l_object_tasks_tbl
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        x_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
        debug('  Unable to Create the Object Capacity: Error = ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_trip.trip_id               := l_object_capacity_tbl(1).object_capacity_id;
    x_trip.object_version_number := 1;
    x_trip.resource_id           := p_resource_id;
    x_trip.resource_type         := p_resource_type;
    x_trip.start_date_time       := p_start_date_time;
    x_trip.end_date_time         := p_end_date_time;
    x_trip.available_hours       := l_available_hours;
    x_trip.status                := p_status;
    x_trip.schedule_detail_id    := p_schedule_detail_id;

    IF l_debug THEN
      debug('  Created Trip - TripID#' || x_trip.trip_id, l_api_name, fnd_log.level_statement);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_new_trip;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_new_trip;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
      ROLLBACK TO csf_new_trip;
  END new_trip1;



    PROCEDURE create_shift_tasks1(
    p_api_version          IN          NUMBER
  , p_init_msg_list        IN          VARCHAR2 DEFAULT NULL
  , p_commit               IN          VARCHAR2 DEFAULT NULL
  , x_return_status       OUT  NOCOPY  VARCHAR2
  , x_msg_data            OUT  NOCOPY  VARCHAR2
  , x_msg_count           OUT  NOCOPY  NUMBER
  , p_resource_id          IN          NUMBER
  , p_resource_type        IN          VARCHAR2
  , p_start_date_time      IN          DATE
  , p_end_date_time        IN          DATE
  , p_create_dep_task      IN          BOOLEAN
  , p_create_arr_task      IN          BOOLEAN
  , p_arr_party_site       IN          NUMBER
  , p_arr_party            IN          NUMBER
  , p_dep_party_site       IN          NUMBER
  , p_dep_party            IN          NUMBER
  , x_dep_task_id         OUT NOCOPY   NUMBER
  , x_arr_task_id         OUT NOCOPY   NUMBER
  ) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_SHIFT_TASKS';
    l_debug           CONSTANT BOOLEAN  := g_debug = 'Y';
    l_address         csf_resource_address_pvt.address_rec_type;
    l_task_assign_tbl jtf_tasks_pub.task_assign_tbl;
  BEGIN

    IF p_create_dep_task = FALSE AND p_create_arr_task = FALSE THEN
      RETURN;
    END IF;


    -- Departure and Arrival Task Resource Assignment
    l_task_assign_tbl(1).resource_id          := p_resource_id;
    l_task_assign_tbl(1).resource_type_code   := p_resource_type;
    l_task_assign_tbl(1).assignment_status_id := g_assigned_status_id;

    -- Create the Departure Task
    IF p_create_dep_task THEN
      jtf_tasks_pub.create_task(
        p_api_version                => 1.0
      , p_task_name                  => g_dep_task_name
      , p_task_type_id               => g_dep_task_type_id
      , p_task_status_id             => g_assigned_status_id
      , p_owner_id                   => p_resource_id
      , p_owner_type_code            => p_resource_type
      , p_address_id                 => p_dep_party_site
      , p_customer_id                => p_dep_party
      , p_planned_start_date         => p_start_date_time
      , p_planned_end_date           => p_start_date_time
      , p_scheduled_start_date       => p_start_date_time
      , p_scheduled_end_date         => p_start_date_time
      , p_duration                   => 0
      , p_duration_uom               => g_duration_uom
      , p_bound_mode_code            => 'BTS'
      , p_soft_bound_flag            => 'Y'
      , p_task_assign_tbl            => l_task_assign_tbl
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_id                    => x_dep_task_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('CSF', 'CSF_TASK_CREATE_FAIL');
        fnd_message.set_token('TASK_NAME', g_dep_task_name);
        fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
        fnd_msg_pub.ADD;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_debug THEN
        debug('    Created Departure Task - Task ID = ' || x_dep_task_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;

    -- Create the Arrival Task
    IF p_create_arr_task THEN
      jtf_tasks_pub.create_task(
        p_api_version                => 1.0
      , p_task_name                  => g_arr_task_name
      , p_task_type_id               => g_arr_task_type_id
      , p_task_status_id             => g_assigned_status_id
      , p_owner_id                   => p_resource_id
      , p_owner_type_code            => p_resource_type
      , p_address_id                 => p_arr_party_site
      , p_customer_id                => p_arr_party
      , p_planned_start_date         => p_end_date_time
      , p_planned_end_date           => p_end_date_time
      , p_scheduled_start_date       => p_end_date_time
      , p_scheduled_end_date         => p_end_date_time
      , p_duration                   => 0
      , p_duration_uom               => g_duration_uom
      , p_bound_mode_code            => 'BTS'
      , p_soft_bound_flag            => 'Y'
      , p_task_assign_tbl            => l_task_assign_tbl
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_id                    => x_arr_task_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('CSF', 'CSF_TASK_CREATE_FAIL');
        fnd_message.set_token('TASK_NAME', g_arr_task_name);
        fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
        fnd_msg_pub.ADD;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
      IF l_debug THEN
        debug('    Created Arrival Task - Task ID = ' || x_arr_task_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END create_shift_tasks1;

  PROCEDURE update_dc_trip(
    p_api_version              IN          NUMBER
  , p_init_msg_list            IN          VARCHAR2
  , p_commit                   IN          VARCHAR2
  , x_return_status           OUT  NOCOPY  VARCHAR2
  , x_msg_data                OUT  NOCOPY  VARCHAR2
  , x_msg_count               OUT  NOCOPY  NUMBER
  , p_trip_id                  IN          NUMBER
  , p_object_version_number    IN          NUMBER
  , p_available_hours          IN          NUMBER
  , p_upd_available_hours      IN          NUMBER
  , p_available_hours_before   IN          NUMBER
  , p_available_hours_after    IN          NUMBER
  , p_status                   IN          NUMBER
  , p_availability_type        in varchar2 default null
  , p_start_date_time           in date
  , p_end_date_time           in date
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_TRIP';
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_trip                   trip_rec_type;
    l_overtime              NUMBER;




     CURSOR c_trip_exist(p_resource_id number)
     is
        SELECT 'Y'
        FROM  cac_sr_object_capacity
        WHERE p_start_date_time <= (end_date_time + g_overtime)
          AND p_end_date_time >= start_date_time
          AND object_id=p_resource_id
          AND OBJECT_CAPACITY_ID NOT IN (p_trip_id);

    l_shift_tasks_exist     VARCHAR2(1);
    l_trip_exist            VARCHAR2(1);

  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_trip_id IS NULL OR p_trip_id = fnd_api.g_miss_num THEN
      -- Invalid Trip ID passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_TRIP_ID');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_object_version_number IS NULL OR p_object_version_number = fnd_api.g_miss_num THEN
      -- Invalid Object Version Number passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_OBJECT_VERSION_NUMBER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_available_hours IS NOT NULL AND p_upd_available_hours IS NOT NULL THEN
      -- Error out as both cant be passed.
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_UPD_AVAILABLE_HOURS');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;



    l_trip := get_trip(p_trip_id);
    IF l_trip.trip_id IS NULL THEN
      fnd_message.set_name('CSF', 'CSF_INVALID_TRIP_ID');
      fnd_message.set_token('TRIP_ID', p_trip_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;



    OPEN c_trip_exist(l_trip.resource_id);
    FETCH c_trip_exist INTO l_trip_exist;
    IF c_trip_exist%NOTFOUND THEN
      l_trip_exist := 'N';
    END IF;
    CLOSE c_trip_exist;

    IF (l_trip_exist = 'Y') THEN
      IF l_debug THEN
        debug('  Shift Tasks exist for the Resource in the specified interval', l_api_name, fnd_log.level_error);
      END IF;
      fnd_message.set_name('CSF', 'CSF_TRIP_CREATE_FAIL_ST_EXIST');
      fnd_message.set_token('RESOURCE', get_resource_info(l_trip.resource_id,l_trip.resource_type));
      fnd_message.set_token('START_TIME', format_date(p_start_date_time));
      fnd_message.set_token('END_TIME', format_date(p_end_date_time));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    change_trip(
      x_return_status          => x_return_status
    , x_msg_data               => x_msg_data
    , x_msg_count              => x_msg_count
    , p_trip                   => l_trip
    , p_object_version_number  => p_object_version_number
    , p_available_hours        => p_available_hours
    , p_upd_available_hours    => p_upd_available_hours
    , p_available_hours_before => p_available_hours_before
    , p_available_hours_after  => p_available_hours_after
    , p_status                 => p_status
    , p_availability_type => p_availability_type
    , p_start_date => p_start_date_time
    , p_end_date => p_end_date_time
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('CSF', 'CSF_TRIP_UPDATE_FAIL_OTHER');
      fnd_message.set_token('RESOURCE', get_resource_info(l_trip.resource_id, l_trip.resource_type));
      fnd_message.set_token('START_TIME', format_date(l_trip.start_date_time));
      fnd_message.set_token('END_TIME', format_date(l_trip.end_date_time));
      fnd_message.set_token('REASON', fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false));
      fnd_msg_pub.ADD;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      debug('Fatal Exception occurred: Code = ' || SQLCODE || ' Error = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END;

  PROCEDURE update_shift_tasks(
    p_api_version          IN          NUMBER
  , p_init_msg_list        IN          VARCHAR2 DEFAULT NULL
  , p_commit               IN          VARCHAR2 DEFAULT NULL
  , p_object_version_number in out nocopy number
  , p_task_id              IN          NUMBER
  , p_Task_type_id         IN          NUMBER
  , x_return_status       OUT  NOCOPY  VARCHAR2
  , x_msg_data            OUT  NOCOPY  VARCHAR2
  , x_msg_count           OUT  NOCOPY  NUMBER
  , p_resource_id          IN          NUMBER
  , p_resource_type        IN          VARCHAR2
  , p_start_date_time      IN          DATE
  , p_end_date_time        IN          DATE
  , p_arr_party_site       IN          NUMBER
  , p_arr_party            IN          NUMBER
  , p_dep_party_site       IN          NUMBER
  , p_dep_party            IN          NUMBER
  , p_update_dep_task      IN          BOOLEAN  default null
  , p_update_arr_task      IN          BOOLEAN  default null
  ) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_SHIFT_TASKS';
    l_debug           CONSTANT BOOLEAN  := g_debug = 'Y';
    l_address         csf_resource_address_pvt.address_rec_type;
    l_task_assign_tbl jtf_tasks_pub.task_assign_tbl;
  BEGIN

    IF p_update_dep_task = FALSE AND p_update_arr_task = FALSE THEN
      RETURN;
    END IF;


    -- Departure and Arrival Task Resource Assignment
    l_task_assign_tbl(1).resource_id          := p_resource_id;
    l_task_assign_tbl(1).resource_type_code   := p_resource_type;
    l_task_assign_tbl(1).assignment_status_id := g_assigned_status_id;

    -- Create the Departure Task
    IF p_update_dep_task THEN
      jtf_tasks_pub.update_task(
        p_api_version                => 1.0
      , p_task_id                    => p_task_id
      , p_object_version_number      => p_object_version_number
      , p_task_type_id               => p_task_type_id
      , p_task_status_id             => g_assigned_status_id
      , p_owner_id                   => p_resource_id
      , p_owner_type_code            => p_resource_type
      , p_address_id                 => p_dep_party_site
      , p_customer_id                => p_dep_party
      , p_planned_start_date         => p_start_date_time
      , p_planned_end_date           => p_start_date_time
      , p_scheduled_start_date       => p_start_date_time
      , p_scheduled_end_date         => p_start_date_time
      , p_duration                   => 0
      , p_duration_uom               => g_duration_uom
      , p_bound_mode_code            => 'BTS'
      , p_soft_bound_flag            => 'Y'
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN


        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;


    END IF;

    -- Create the Arrival Task
    IF p_update_arr_task THEN
      jtf_tasks_pub.update_task(
        p_api_version                => 1.0
      , p_task_id                    => p_task_id
      , p_object_version_number      => p_object_version_number
      , p_task_type_id               => p_task_type_id
      , p_task_status_id             => g_assigned_status_id
      , p_owner_id                   => p_resource_id
      , p_owner_type_code            => p_resource_type
      , p_address_id                 => p_arr_party_site
      , p_customer_id                => p_arr_party
      , p_planned_start_date         => p_end_date_time
      , p_planned_end_date           => p_end_date_time
      , p_scheduled_start_date       => p_end_date_time
      , p_scheduled_end_date         => p_end_date_time
      , p_duration                   => 0
      , p_duration_uom               => g_duration_uom
      , p_bound_mode_code            => 'BTS'
      , p_soft_bound_flag            => 'Y'
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
           );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN


        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;
     IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END update_shift_tasks;

  PROCEDURE create_dc_trip( p_api_version           IN          NUMBER
                          , p_init_msg_list         IN          VARCHAR2
                          , p_commit                IN          VARCHAR2
                          , x_return_status        OUT  NOCOPY  VARCHAR2
                          , x_msg_data             OUT  NOCOPY  VARCHAR2
                          , x_msg_count            OUT  NOCOPY  NUMBER
                          , p_resource_tbl          IN          csf_resource_pub.resource_tbl_type
                          , p_start_date            IN          DATE
                          , p_end_date              IN          DATE
                          , p_delete_trips          IN          BOOLEAN    DEFAULT FALSE)
 IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_DC_TRIPS';
  l_api_version  CONSTANT NUMBER       := 1.0;
 BEGIN
    SAVEPOINT csf_dc_trip;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    create_trips(
                  x_return_status  => x_return_status
                , x_msg_data       => x_msg_data
                , x_msg_count      => x_msg_count
                , p_resource_tbl   => p_resource_tbl
                , p_start_date     => p_start_date
                , p_end_date       => p_end_date
                , p_delete_trips   => null
                );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_dc_trip;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_dc_trip;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      ROLLBACK TO csf_dc_trip;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END create_dc_trip;


FUNCTION check_dst(p_resource_id IN number ,p_start_server IN date,p_end_server IN date)
  RETURN VARCHAR2
  IS
   l_api_name		   CONSTANT VARCHAR2(30) := 'check_dst';
   l_API_VERSION       Number := 1.0 ;
   p_API_VERSION       Number := 1.0 ;
   l_INIT_MSG_LIST     varchar2(1) := 'F';
   p_INIT_MSG_LIST     varchar2(1) := 'F';
   l_res_Timezone_id   number;

   l_start_res date;
   l_end_res date;
   l_server_diff number;
   l_res_diff    number;
   l_main_diff   number;
   l_tz_enabled    VARCHAR2(10):=fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS');
   l_server_tz_id   Number :=   to_number (fnd_profile.value_specific('SERVER_TIMEZONE_ID'));

   X_RETURN_STATUS     Varchar2(10);
   x_msg_count         number;
   x_msg_data          Varchar2(2000);
  BEGIN


     -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
        	    	    	     	    	    p_api_version ,
   	       	    	 		    l_api_name ,
		    	    	       	    G_PKG_NAME )
    THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Get the dates in Server Timezone
   -- Calculate diff ,if greater than 24 convert back to Resoruce timezone.
   -- check the diff in Resource timezone
   -- if >24 error out else Convert back to Server timezone again and
   -- check if >24 .If yes its DST change so allow the change otherwise
   -- error out

   l_server_diff := trunc  ((p_end_server - p_start_server ) * g_hours_in_day,2);
   IF l_server_diff > 24
   THEN
      If fnd_profile.value_specific('ENABLE_TIMEZONE_CONVERSIONS') = 'Y'
      Then
    	   l_res_Timezone_id := Get_Res_Timezone_Id (p_resource_id);
    	   l_start_res := ServerDT_To_ResourceDt(p_start_server,l_server_tz_id,l_res_Timezone_id);
         l_end_res := ServerDT_To_ResourceDt(p_end_server,l_server_tz_id,l_res_Timezone_id);

         l_res_diff := trunc((l_end_res - l_start_res ) * g_hours_in_day,2);
         l_main_diff := (l_server_diff - l_res_diff);
         if l_res_diff < 24 and l_main_diff = 1
         then
           return 'TRUE';
         else
           return 'FALSE';
         end if;
     else
         return 'FALSE';
     end if;
   END IF;
  EXCEPTION
   when others then

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);
    RETURN 'FALSE';
  END;


  Function ServerDT_To_ResourceDt ( P_Server_DtTime IN date, P_Server_TZ_Id IN Number , p_Resource_TZ_id IN Number ) RETURN date IS

 x_Server_time	   Date := P_Server_DtTime;

 l_api_name		   CONSTANT VARCHAR2(30) := 'ServerDT_To_ResourceDt';
 l_API_VERSION       Number := 1.0 ;
 p_API_VERSION       Number := 1.0 ;
 l_INIT_MSG_LIST     varchar2(1) := 'F';
 p_INIT_MSG_LIST     varchar2(1) := 'F';
 X_msg_count	   Number;
 X_msg_data		   Varchar2(2000);
 X_RETURN_STATUS     Varchar2(10);

BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
        	    	    	     	    	    p_api_version ,
   	       	    	 		    l_api_name ,
		    	    	       	    G_PKG_NAME )
    THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   HZ_TIMEZONE_PUB.Get_Time( l_API_VERSION
                           , l_INIT_MSG_LIST
                           , P_Server_TZ_Id
                           , p_Resource_TZ_id
                           , P_Server_DtTime
                           , x_Server_time
                           , X_RETURN_STATUS
                           , X_msg_count
                           , X_msg_data);

Return x_Server_time;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);

  WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);

END ServerDT_To_ResourceDT;

Function Get_Res_Timezone_Id ( P_Resource_Id IN Number ) RETURN Number IS

 Cursor C_Res_TimeZone Is
 Select TIME_ZONE
   From JTF_RS_RESOURCE_EXTNS
  Where RESOURCE_ID = p_resource_id
    And trunc(sysdate) between trunc(nvl(START_DATE_ACTIVE,sysdate))
                           and trunc(nvl(END_DATE_ACTIVE,sysdate));

 l_Res_Timezone_id   Number;

Begin

    Open C_Res_TimeZone ;
   Fetch C_Res_TimeZone into l_Res_TimeZone_id;
   Close C_Res_TimeZone ;

l_Res_TimeZone_id := nvl(l_Res_TimeZone_id,fnd_profile.value_specific('SERVER_TIMEZONE_ID'));

Return (l_Res_TimeZone_id);

End Get_Res_Timezone_Id;

PROCEDURE check_dangling_tasks(p_resource_tbl IN csf_resource_pub.resource_tbl_type
                              , p_start                 IN           DATE
                              , p_end                   IN           DATE
                              , x_return_status         OUT  NOCOPY  VARCHAR2
                              , x_msg_data              OUT  NOCOPY  VARCHAR2
                              , x_msg_count             OUT  NOCOPY  NUMBER)
IS

CURSOR c_dangling_tasks(p_res_id number,p_res_type varchar2)
IS
   SELECT t.task_id,t.object_version_number,scheduled_start_date,scheduled_end_date
        FROM jtf_tasks_b t
           , jtf_task_assignments ta
       WHERE t.owner_id = p_res_id
         AND t.owner_type_code = p_res_type
         AND t.planned_start_date BETWEEN p_start AND p_end
         AND t.task_type_id IN (20, 21)
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND ta.task_id = t.task_id
         AND ta.assignee_role = 'ASSIGNEE'
         AND ta.object_capacity_id IS NULL
         UNION
    SELECT t.task_id,t.object_version_number,scheduled_start_date,scheduled_end_date
         FROM jtf_tasks_b t
         WHERE  t.owner_id = p_res_id
         AND t.owner_type_code = p_res_type
         AND t.task_type_id IN (20, 21)
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND( t.planned_start_date BETWEEN p_start AND p_end )
         AND TASK_ID NOT IN (SELECT ta.TASK_ID FROM JTF_TASK_ASSIGNMENTS ta WHERE  ta.task_id=t.task_id and RESOURCE_ID = p_res_id
         AND RESOURCE_TYPE_CODE = p_res_type);

CURSOR c_alone_trip_tasks(p_res_id number,p_res_type varchar2)
IS
SELECT task_number,
  scheduled_start_date,
  scheduled_end_date,
  owner_id,
  owner_type_code
FROM JTF_TASKS_B
WHERE TASK_ID IN
  (SELECT TASK_ID
  FROM JTF_TASK_ASSIGNMENTS
  WHERE OBJECT_CAPACITY_ID IN
    (SELECT co.object_capacity_id
    FROM cac_sr_object_capacity co,
      jtf_tasks_b jtb,
      jtf_task_assignments jta,
      jtf_task_statuses_b jts,
      jtf_Task_statuses_b jtsa
    WHERE jtb.task_id                 =jta.task_id
    AND jta.assignment_status_id      =jts.task_status_id
    AND NVL(jts.cancelled_flag,'N')  <> 'Y'
    AND jtb.task_status_id            =jtsa.task_status_id
    AND NVL(jtsa.cancelled_flag,'N') <> 'Y'
    AND NVL(jtb.deleted_flag,'N')    <> 'Y'
    AND co.object_capacity_id         =jta.object_capacity_id
    AND resource_id                   =object_id
    AND resource_type_code            =object_type
    AND jtb.task_type_id             IN (20,21)
	AND resource_id                   =p_res_id
	AND resource_type_code            =p_res_type
	AND( co.start_date_time BETWEEN p_start AND p_end )
    GROUP BY co.object_capacity_id
    HAVING COUNT(jta.task_id) =1
    )
  );
    l_tasks c_dangling_tasks%rowtype;
    l_api_name     CONSTANT VARCHAR2(30) := 'CHECK_DANGLING_TASKS';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

BEGIN

IF l_debug THEN
  debug('    Inside Dangling Procedure # ', l_api_name, fnd_log.level_statement);
  debug('  Checking Dangling Trip between ' || format_date(p_start) || ' and ' || format_date(p_end), l_api_name, fnd_log.level_statement);

END IF;
FOR i in p_resource_tbl.first .. p_resource_tbl.last
LOOP
   FOR l_tasks IN c_dangling_tasks(p_resource_tbl(i).resource_id,p_resource_tbl(i).resource_type)
   LOOP

       IF l_debug THEN
          debug('    Deleting the Dangling Shift Task #' || l_tasks.task_id, l_api_name, fnd_log.level_statement);
        END IF;
        -- Departure Task already exists... Delete this Duplicate.
        jtf_tasks_pub.delete_task(
          p_api_version            => 1.0
        , x_return_status          => x_return_status
        , x_msg_count              => x_msg_count
        , x_msg_data               => x_msg_data
        , p_task_id                => l_tasks.task_id
        , p_object_version_number  => l_tasks.object_version_number
        );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          debug('    Unable to Delete the dangling shift Task', l_api_name, fnd_log.level_error);
        END IF;

        add_message(  p_resource_tbl(i).resource_id
                    , p_resource_tbl(i).resource_type
                    , l_tasks.scheduled_start_date
                    , l_tasks.scheduled_end_date
                    , fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
                    , 'CSF_TASK_DELETE_FAIL'
                    , g_error_message  );

       END IF;
      END LOOP;
	  FOR l_alone_trip_task in c_alone_trip_tasks(p_resource_tbl(i).resource_id,p_resource_tbl(i).resource_type)
	  LOOP
		IF l_debug THEN
		  debug('  Details of Trip which have only one Departure/Arrival Task for given below period # ', l_api_name, fnd_log.level_statement);
		  debug('  From Date    # ' || format_date(p_start) || ' TO Date   # ' || format_date(p_end), l_api_name, fnd_log.level_statement);
		  debug('  Task Number # ' ||l_alone_trip_task.task_number||' Scheduled Start Date #'||format_date(l_alone_trip_task.scheduled_start_date) ||
		  ' Scheduled End Date #'||format_date(l_alone_trip_task.scheduled_end_date) ||' Owner Id #'||l_alone_trip_task.owner_id||
		  ' Owner Type #'||l_alone_trip_task.owner_type_code, l_api_name, fnd_log.level_statement);
		END IF;
	  END LOOP;
END LOOP;


IF l_debug THEN
  debug('    OutSide Dangling Procedure # ', l_api_name, fnd_log.level_statement);
END IF;

END check_dangling_tasks;

PROCEDURE check_duplicate_tasks(p_resource_tbl IN csf_resource_pub.resource_tbl_type
                              , p_start                 IN           DATE
                              , p_end                   IN           DATE
                              , x_return_status         OUT  NOCOPY  VARCHAR2
                              , x_msg_data              OUT  NOCOPY  VARCHAR2
                              , x_msg_count             OUT  NOCOPY  NUMBER)
IS

CURSOR c_duplicate_tasks(p_res_id number,p_res_type varchar2)
IS
   SELECT    task_id
           , task_type_id
           , object_version_number
           , task_name
           , task_number FROM (
       SELECT t.task_id
           , t.task_type_id
           , t.object_version_number
           , t.task_name
           , t.task_number
           , LAG(t.task_id) OVER (PARTITION BY t.task_type_id,resource_id,resource_type_code,scheduled_start_date
                                  ORDER BY t.scheduled_start_date) duplicate
        FROM jtf_task_assignments ta
           , jtf_tasks_vl t
       WHERE t.task_id = ta.task_id
         AND  NVL(t.deleted_flag, 'N') = 'N'
         AND t.task_type_id IN (20, 21)
		 AND resource_id =p_res_id
		 AND resource_type_code=p_res_type
		 AND scheduled_start_date <= p_end + 1
		 AND scheduled_end_date >= p_start - 1
		) WHERE duplicate IS NOT NULL;

    l_tasks c_duplicate_tasks%rowtype;
    l_api_name     CONSTANT VARCHAR2(30) := 'CHECK_DUPLICATE_TASKS';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

BEGIN

IF l_debug THEN
  debug('    Inside Duplicate Procedure # ', l_api_name, fnd_log.level_statement);
END IF;
FOR i in p_resource_tbl.first .. p_resource_tbl.last
LOOP

  FOR l_tasks IN c_duplicate_tasks(p_resource_tbl(i).resource_id,p_resource_tbl(i).resource_type)
  LOOP
       IF l_debug THEN
          debug('    Deleting the Duplicate Shift Task #' || l_tasks.task_id, l_api_name, fnd_log.level_statement);
        END IF;
        -- Departure Task already exists... Delete this Duplicate.
        jtf_tasks_pub.delete_task(
          p_api_version            => 1.0
        , x_return_status          => x_return_status
        , x_msg_count              => x_msg_count
        , x_msg_data               => x_msg_data
        , p_task_id                => l_tasks.task_id
        , p_object_version_number  => l_tasks.object_version_number
        );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          debug('    Unable to Delete the Duplicate shift Task', l_api_name, fnd_log.level_error);
        END IF;

        add_message(  p_resource_tbl(i).resource_id
                    , p_resource_tbl(i).resource_type
                    , null
                    , null
                    , fnd_msg_pub.get(fnd_msg_pub.g_last, fnd_api.g_false)
                    , 'CSF_TASK_DELETE_FAIL'
                    , g_error_message  );


      END IF;
    END LOOP;
END LOOP;
IF l_debug THEN
  debug('    OutSide Duplicate Procedure # ', l_api_name, fnd_log.level_statement);
END IF;

END check_duplicate_tasks;


BEGIN
  -- Package Initialization
  init_package;
END csf_trips_pub;


/
