--------------------------------------------------------
--  DDL for Package Body CSR_SCHEDULER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSR_SCHEDULER_PVT" AS
/* $Header: CSRVSCHB.pls 120.19.12010000.19 2010/04/23 12:02:20 rkamasam ship $ */

  g_pkg_name            CONSTANT VARCHAR2(30) := 'CSR_SCHEDULER_PVT';
  g_csr_appl_id         CONSTANT NUMBER       := 698;
  g_conc_program_name   CONSTANT VARCHAR2(30) := 'SEARCH_AND_SCHEDULE_AUTO';

  g_auto_contract_flag  CONSTANT VARCHAR2(1)  := csr_scheduler_pub.get_sch_parameter_value('spPickContractResources');
  g_auto_ib_flag        CONSTANT VARCHAR2(1)  := csr_scheduler_pub.get_sch_parameter_value('spPickIbResources');
  g_auto_skills_flag    CONSTANT VARCHAR2(1)  := csr_scheduler_pub.get_sch_parameter_value('spPickSkilledResources');
  g_auto_terr_flag      CONSTANT VARCHAR2(1)  := csr_scheduler_pub.get_sch_parameter_value('spPickTerritoryResources');
  g_spares_source       CONSTANT VARCHAR2(30) := csr_scheduler_pub.get_sch_parameter_value('spSparesSource');
  g_spares_mandatory    CONSTANT VARCHAR2(1)  := csr_scheduler_pub.get_sch_parameter_value('spSparesMandatory');
  g_standby_shifts      CONSTANT VARCHAR2(30) := csr_scheduler_pub.get_sch_parameter_value('spConsiderStandbyShifts');

  TYPE ref_cursor_type IS REF CURSOR;


  FUNCTION valid_argument(p_arg_value VARCHAR2, p_arg_name VARCHAR2, p_api_name VARCHAR2)
    RETURN BOOLEAN IS
  BEGIN
    IF p_arg_value IS NULL THEN
      fnd_message.set_name('CSR', 'CSR_MANDATORY_FIELD_MISSING');
      fnd_message.set_token('FIELD', p_arg_name);
      fnd_message.set_token('TASK', p_api_name);
      fnd_msg_pub.ADD;
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END valid_argument;


  /**
   * Gets the Geocode of a Task.
   *
   * The API returns the Geocoded Geometry of the Task if the given Task has an address.
   * If the Task is not yet Geocoded, then tries to resolve the Address of the Task by
   * calling Location Finder.
   *
   * The Geocode is returned by stamping the values in the respective output parameters
   * rather than as MDSYS.SDO_GEOMETRY itself because JDBC doesnt support PLSQL Record
   * Types as of now.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   p_commit                Commits the Work
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_task_id               Task ID
   * @param   x_locus_segment_id      Segment ID of the Road in the Address's Geocode
   * @param   x_locus_side            Side of the Road in the Address's Geocode
   * @param   x_locus_spot            Offset in the Road in the Address's Geocode
   * @param   x_locus_lat             Longitude of the Location in the Address's Geocode
   * @param   x_locus_lon             Latitude of the Location in the Address's Geocode
   * @param   x_should_call_lf        Should LF be called on the Address or not
   * @param   x_location_id           Location ID of the Address.
   * @param   x_srid                  Coordinate system id.
   * @param   x_country_code          Country Code of the Address
   */
  PROCEDURE get_geometry(
    p_api_version            IN              NUMBER
  , p_init_msg_list          IN              VARCHAR2
  , p_commit                 IN              VARCHAR2
  , x_return_status          OUT NOCOPY      VARCHAR2
  , x_msg_count              OUT NOCOPY      NUMBER
  , x_msg_data               OUT NOCOPY      VARCHAR2
  , p_task_id                IN              NUMBER
  , x_locus_segment_id       OUT NOCOPY      NUMBER
  , x_locus_side             OUT NOCOPY      NUMBER
  , x_locus_spot             OUT NOCOPY      NUMBER
  , x_locus_lat              OUT NOCOPY      NUMBER
  , x_locus_lon              OUT NOCOPY      NUMBER
  , x_should_call_lf         OUT NOCOPY      VARCHAR2
  , x_location_id            OUT NOCOPY      NUMBER
  , x_srid                   OUT NOCOPY      NUMBER
  , x_country_code           OUT NOCOPY      VARCHAR2
  ) IS
    l_api_name      CONSTANT VARCHAR2(30)       := 'GET_GEOMETRY';
    l_api_version   CONSTANT NUMBER             := 1.0;

    CURSOR c_address_info IS
      SELECT l.location_id
           , l.geometry
           , l.house_number
           , l.address1
           , l.address2
           , l.address3
           , l.address4
           , l.city
           , l.state
           , l.postal_code
           , fnd.territory_short_name country
           , l.country country_code
           , l.geometry_status_code
        FROM jtf_tasks_b t
           , hz_locations l
           , fnd_territories_vl fnd
       WHERE t.task_id = p_task_id
         AND l.location_id = csf_tasks_pub.get_task_location_id(t.task_id, t.address_id, t.location_id)
         AND fnd.territory_code = l.country;

    l_address_info   c_address_info%ROWTYPE;
    l_locus_valid    VARCHAR2(6);
    l_geo_status_code hz_locations.geometry_status_code%TYPE;
  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_address_info;
    FETCH c_address_info INTO l_address_info;
    CLOSE c_address_info;

    -- The Task has no Address Information.
    IF l_address_info.location_id IS NULL THEN
      -- Need to throw with proper error message
      RAISE fnd_api.g_exc_error;
    END IF;

    l_geo_status_code := NVL(l_address_info.geometry_status_code, 'ERROR');

    IF l_address_info.geometry IS NULL
       OR l_geo_status_code NOT IN ('GOOD', 'NOEXACTMATCH', 'MULTIMATCH')
    THEN
      l_locus_valid := 'FALSE';
    ELSE
      csf_locus_pub.verify_locus(
        p_api_version                => 1
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_return_status              => x_return_status
      , p_locus                      => l_address_info.geometry
      , x_result                     => l_locus_valid
      );
    END IF;

    -- Geocode of the Task is invalid. Try to Geocode the Task
    IF l_locus_valid = 'FALSE' THEN
      csf_resource_address_pvt.resolve_address(
        p_api_version       => 1
      , p_init_msg_list     => fnd_api.g_false
      , x_return_status     => x_return_status
      , x_msg_count         => x_msg_count
      , x_msg_data          => x_msg_data
      , p_location_id       => l_address_info.location_id
      , p_building_num      => l_address_info.house_number
      , p_address1          => l_address_info.address1
      , p_address2          => l_address_info.address2
      , p_address3          => l_address_info.address3
      , p_address4          => l_address_info.address4
      , p_state             => l_address_info.state
      , p_city              => l_address_info.city
      , p_postalcode        => l_address_info.postal_code
      , p_country           => l_address_info.country
      , p_country_code      => l_address_info.country_code
      , x_geometry          => l_address_info.geometry
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_success AND l_address_info.geometry IS NOT NULL THEN
      x_locus_segment_id := csf_locus_pub.get_locus_segmentid(l_address_info.geometry);
      x_locus_side       := csf_locus_pub.get_locus_side(l_address_info.geometry);
      x_locus_spot       := csf_locus_pub.get_locus_spot(l_address_info.geometry);
      x_locus_lat        := csf_locus_pub.get_locus_lat(l_address_info.geometry);
      x_locus_lon        := csf_locus_pub.get_locus_lon(l_address_info.geometry);
      x_should_call_lf   := csf_locus_pub.should_call_lf(l_address_info.geometry);
      x_location_id      := l_address_info.location_id;
      x_srid             := csf_locus_pub.get_locus_srid(l_address_info.geometry);
      x_country_code     := l_address_info.country_code;

      IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_geometry;

  /**
   * Gets the Server Timezone configured in the E-Business Suite
   *
   * Gets the value of the profile SERVER_TIMEZONE_ID. Apparently SERVER_TIMEZONE_ID
   * has been replaced by the profile SERVER_TIMEZONE. So if the former profile
   * doesnt return any value, the API will try to return value of SERVER_TIMEZONE_ID.
   *
   * If either of the profiles doesnt return any value, then it returns the first
   * profile satisfying the condition of being in GMT-8 Offset and also having
   * Day Light Savings as Yes from HZ_TIMEZONES.
   *
   * @return Server Timezone ID (or Zero upon any exception).
   */
  FUNCTION get_server_timezone RETURN NUMBER IS
    l_timezone_id      NUMBER;
  BEGIN
    fnd_profile.get('SERVER_TIMEZONE', l_timezone_id);
    IF l_timezone_id IS NULL THEN
      fnd_profile.get('SERVER_TIMEZONE_ID', l_timezone_id);
    END IF;

    IF l_timezone_id IS NULL THEN
      SELECT MIN(timezone_id)
        INTO l_timezone_id
        FROM hz_timezones
       WHERE gmt_deviation_hours = -8
         AND daylight_savings_time_flag = 'Y';
    END IF;

    RETURN l_timezone_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  /**
   * Returns the Time Zone Difference between the given Timezone
   * and the Server Timezone in Half Hour Units
   *
   * @param  p_timezone_id   Timezone Identifier
   * @return Difference in Half Hour Units
   */
  FUNCTION get_server_timezone_offset(p_timezone_id IN NUMBER)
    RETURN NUMBER IS
    l_offset_days  NUMBER;
    l_server_date  DATE;
  BEGIN
    l_server_date        := hz_timezone_pub.convert_datetime(
                              p_source_tz_id        => p_timezone_id
                            , p_dest_tz_id          => get_server_timezone
                            , p_source_day_time     => SYSDATE
                            );
    l_offset_days := l_server_date - SYSDATE;
    RETURN TRUNC(l_offset_days * 48);  -- Output in half hours.
  END get_server_timezone_offset;


  /**
   * Gets the Timezone corresponding to the given Address.
   *
   */
  FUNCTION get_timezone(p_address_id IN NUMBER) RETURN NUMBER IS
    CURSOR c_timezone IS
      SELECT loc.timezone_id
        FROM hz_party_sites par
           , hz_locations loc
       WHERE par.party_site_id = p_address_id
         AND par.location_id = loc.location_id;

    l_timezone        c_timezone%ROWTYPE;
    l_profile_value   VARCHAR2(50);
  BEGIN
    IF p_address_id IS NULL THEN
      RETURN get_server_timezone;
    ELSE
      OPEN c_timezone;
      FETCH c_timezone INTO l_timezone;
      IF c_timezone%NOTFOUND THEN
        CLOSE c_timezone;
        RETURN get_server_timezone;
      END IF;
      CLOSE c_timezone;
    END IF;
    RETURN l_timezone.timezone_id;
  END get_timezone;

  /**
   * Converts the given Time from the given Timezone to Server Timezone.
   *
   * Calls GET_SERVER_TIMEZONE to get the Server Timezone Identifier.
   * Note that only the Time Component of the given Time is taken and not the
   * Date Component. The returned date has SYSDATE as the Date Component.
   *
   * Generally used by WTP to create the Window Slots properly converted from Task
   * Timezone to Server Timezone.
   *
   * @param   p_time          Time to be converted to Server Timezone
   * @param   p_timezone_id   Source Timezone Identifier
   * @return  Time converted to Server Timezone.
   */
  FUNCTION convert_timezone(p_time IN DATE, p_timezone_id IN NUMBER)
    RETURN DATE IS
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_server_timezone_id   NUMBER;
    l_src_datetime         DATE;
    l_dest_datetime        DATE;
  BEGIN
    l_src_datetime := TO_DATE(TO_CHAR( TRUNC(SYSDATE), 'DD-MM-YYYY') || TO_CHAR(p_time, 'HH24:MI')
                                   , 'DD-MM-YYYY HH24:MI'
                                   );

    hz_timezone_pub.get_time(p_api_version         => 1
                           , p_init_msg_list       => fnd_api.g_false
                           , x_return_status       => l_return_status
                           , x_msg_count           => l_msg_count
                           , x_msg_data            => l_msg_data
                           , p_source_tz_id        => p_timezone_id
                           , p_dest_tz_id          => get_server_timezone
                           , p_source_day_time     => l_src_datetime
                           , x_dest_day_time       => l_dest_datetime
                            );
    l_dest_datetime := TO_DATE( TO_CHAR(TRUNC(SYSDATE), 'DD-MM-YYYY') || TO_CHAR(l_dest_datetime, 'HH24:MI')
                              , 'DD-MM-YYYY HH24:MI'
                              );
    RETURN l_dest_datetime;
  END convert_timezone;

  /**
   * This API Creates a scheduler search request

   * @param   p_api_version           	     API Version (1.0)
   * @param   p_init_msg_list         	     Initialize Message List
   * @param   p_commit                	     Commits the Work. This is set as true to allow Scheduler to see the new request created.
   * @param   x_return_status         	     Return Status of the Procedure.
   * @param   x_msg_count             	     Number of Messages in the Stack.
   * @param   x_msg_data              	     Stack of Error Messages.
   * @param   p_task_id               	     The task id for which the search request is being created.
   * @param   The following set of parameters represents the qualifiers of resoucres for the task.
                1) p_contracts_flag
                2) p_ib_flag
                3) p_territory_flag
                4) p_skill_flag
   * @param   p_resource_tbl          	     The set of resource to be considered for scheduling irrespective of their qualification.
   * @param   p_request_name          	     Type of request to be created
	          One of the following request types are created
                    1) SearchAssistedOptions
                    2) SearchIntelligentOptions
                    3) SearchWTPOptions
   * @param   p_spares_mandatory       	      Is Spares Mandatory
   * @param   p_spares_source          	      Spares Source to be used for this request
   * @param   p_consider_standby_shifts       Should Standby Shifts be considered (ALWAYS, NEVER, DAY_WISE, REG_THEN_STANDBY)
   * @param   p_route_based_flag      	      Flag to enable route based scheduling for this request
   * @param   p_disabled_access_hours_flag    Activate access hours if any assigned for the task.
   * @param   x_request_id                    Request id of created request

   * The API  first finds the set of qualified resoucres for the given task
   * based on the qualifers given.
   * It then creates appropriate serach request based on the request name
   */
  PROCEDURE create_search_request(
    p_api_version                IN           NUMBER
  , p_init_msg_list              IN           VARCHAR2
  , p_commit                     IN           VARCHAR2
  , x_return_status              OUT  NOCOPY  VARCHAR2
  , x_msg_count                  OUT  NOCOPY  NUMBER
  , x_msg_data                   OUT  NOCOPY  VARCHAR2
  , p_request_name               IN           VARCHAR2
  , p_task_id                    IN           NUMBER
  , p_contracts_flag             IN           VARCHAR2
  , p_ib_flag                    IN           VARCHAR2
  , p_territory_flag             IN           VARCHAR2
  , p_skill_flag                 IN           VARCHAR2
  , p_resource_id_tbl            IN           jtf_number_table
  , p_resource_type_tbl          IN           jtf_varchar2_table_100
  , p_spares_mandatory           IN           VARCHAR2
  , p_spares_source              IN           VARCHAR2
  , p_consider_standby_shifts    IN           VARCHAR2
  , p_route_based_flag           IN           VARCHAR2
  , p_disabled_access_hours_flag IN           VARCHAR2
  , x_request_id                 OUT  NOCOPY  NUMBER
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_SEARCH_REQUEST';

    l_res_qualifiers   csf_resource_pub.resource_qualifier_tbl_type;
    l_res_tbl          csf_requests_pvt.resource_tbl_type;
    j                  PLS_INTEGER;
    k                  PLS_INTEGER;

    CURSOR c_task_info IS
      SELECT planned_start_date, planned_end_date, source_object_id
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;

    l_task_info           c_task_info%ROWTYPE;

  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Find the qualified resoucres for the task based on the given resoucer qualifiers

    OPEN c_task_info;
    FETCH c_task_info INTO l_task_info;
    IF c_task_info%NOTFOUND THEN
      CLOSE c_task_info;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_task_info;

    -- Validate the Planned Window (same logic as that done in DC)
    csf_tasks_pub.validate_planned_dates(l_task_info.planned_start_date, l_task_info.planned_end_date);

    csf_resource_pub.get_resources_to_schedule(
      p_api_version             => 1
    , p_init_msg_list           => fnd_api.g_false
    , x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_scheduling_mode         => 'X'       -- Auto Assign mode
    , p_task_id                 => p_task_id
    , p_incident_id             => l_task_info.source_object_id
    , p_start                   => l_task_info.planned_start_date
    , p_end                     => l_task_info.planned_end_date
    , p_contracts_flag          => p_contracts_flag
    , p_ib_flag                 => p_ib_flag
    , p_territory_flag          => p_territory_flag
    , p_skill_flag              => p_skill_flag
    , p_res_qualifier_tbl       => l_res_qualifiers
    , p_suggested_res_id_tbl    => p_resource_id_tbl
    , p_suggested_res_type_tbl  => p_resource_type_tbl
    , x_res_tbl                 => l_res_tbl
    );

    -- Unless it is an Unexpected Error... continue even with
    -- "No Resources Found" error. Java will do the proper error handling.
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Create Scheduler Search Request based on the given information.
    csf_requests_pvt.create_scheduler_request(
      p_api_version                 => 1
    , p_init_msg_list               => fnd_api.g_false
    , p_commit                      => fnd_api.g_false
    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data
    , p_name                        => p_request_name
    , p_object_id                   => p_task_id
    , p_resource_tbl                => l_res_tbl
    , p_route_based_flag            => p_route_based_flag
    , p_disabled_access_hours_flag  => p_disabled_access_hours_flag
    , p_spares_mandatory            => p_spares_mandatory
    , p_spares_source               => p_spares_source
    , p_standby_param               => p_consider_standby_shifts
    , x_request_id                  => x_request_id
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_search_request;

  /**
   * This API creates a request of type 'ScheduleOption'

   * @param   p_api_version           	 API Version (1.0)
   * @param   p_init_msg_list         	 Initialize Message List
   * @param   p_commit                	 Commits the Work. This is set as true to allow Scheduler to see the new request created.
   * @param   x_return_status         	 Return Status of the Procedure.
   * @param   x_msg_count             	 Number of Messages in the Stack.
   * @param   x_msg_data              	 Stack of Error Messages.
   * @param   p_plan_option_id           The id of the plan option to be scheduled
   * @param   p_target_status_id     	 The status to which the task has to be changed after scheduling
   * @param   p_set_plan_task_confirmed  Flag to indicate that customer confirmation has to be considered for the task.
   * @param   x_request_id               Request id of created request

   * This API creates a scheduler request of type 'ScheduleOption'
   * that is used to schedule the given plan option
   */
  PROCEDURE create_schedule_option_request(
    p_api_version               IN  NUMBER
  , p_init_msg_list             IN  VARCHAR2
  , p_commit                    IN  VARCHAR2
  , x_return_status             OUT  NOCOPY VARCHAR2
  , x_msg_count                 OUT  NOCOPY NUMBER
  , x_msg_data                  OUT  NOCOPY VARCHAR2
  , p_plan_option_id            IN  NUMBER
  , p_target_status_id          IN  NUMBER
  , p_set_plan_task_confirmed   IN VARCHAR2
  , x_request_id                OUT  NOCOPY NUMBER
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_SCHEDULE_OPTION_REQUEST';
  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    csf_requests_pvt.create_scheduler_request(
      p_api_version                    => 1
    , x_return_status                  => x_return_status
    , x_msg_count                      => x_msg_count
    , x_msg_data                       => x_msg_data
    , p_name                           => 'ScheduleOption'
    , p_object_id                      => p_plan_option_id
    , p_status_id                      => p_target_status_id
    , p_set_plan_task_confirmed        => p_set_plan_task_confirmed
    , x_request_id                     => x_request_id
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_schedule_option_request;

  PROCEDURE create_auto_request(
    x_return_status   OUT NOCOPY VARCHAR2
  , x_msg_count       OUT NOCOPY NUMBER
  , x_msg_data        OUT NOCOPY VARCHAR2
  , p_task_tbl        IN         csf_requests_pvt.object_tbl_type
  , p_find_resources  IN         VARCHAR2 DEFAULT fnd_api.g_true
  , x_request_id      OUT NOCOPY NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_AUTO_REQUEST';

    i                    PLS_INTEGER;
    l_child_request_id   NUMBER;
    l_res_tbl            csf_requests_pvt.resource_tbl_type;
    l_res_qualifiers     csf_resource_pub.resource_qualifier_tbl_type;

    CURSOR c_task_info (p_task_id NUMBER) IS
      SELECT t.task_id, t.planned_start_date, t.planned_end_date, t.source_object_id
        FROM jtf_tasks_b t
       WHERE t.task_id = p_task_id;

    l_task_info      c_task_info%ROWTYPE;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;


    IF p_task_tbl IS NULL OR p_task_tbl.COUNT <= 0 THEN
      x_request_id := -1;
      RETURN;
    END IF;


    -- Create the SearchAndScheduleAuto Request which will serve as
    -- the Parent Request for the subsequents requests created for each Task.
    csf_requests_pvt.create_scheduler_request(
      p_api_version                    => 1
    , p_init_msg_list                  => fnd_api.g_true
    , p_commit                         => fnd_api.g_false
    , x_return_status                  => x_return_status
    , x_msg_count                      => x_msg_count
    , x_msg_data                       => x_msg_data
    , p_name                           => 'SearchAndScheduleAuto'
    , p_object_id                      => -1
    , x_request_id                     => x_request_id
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;


    -- For each task, create a SearchAndSchedule Request with Parent
    -- Request being the Request created above.
    i := p_task_tbl.FIRST;
    WHILE i IS NOT NULL LOOP
      IF p_find_resources = fnd_api.g_true THEN

        OPEN c_task_info(p_task_tbl(i));
        FETCH c_task_info INTO l_task_info;
        CLOSE c_task_info;

        -- Validate the Planned Window (same logic as that done in DC)
        csf_tasks_pub.validate_planned_dates(l_task_info.planned_start_date, l_task_info.planned_end_date);

        -- Get the Resources for this Task.
        csf_resource_pub.get_resources_to_schedule(
          p_api_version             => 1
        , p_init_msg_list           => fnd_api.g_false
        , x_return_status           => x_return_status
        , x_msg_count               => x_msg_count
        , x_msg_data                => x_msg_data
        , p_scheduling_mode         => 'X'       -- Auto Assign mode
        , p_task_id                 => p_task_tbl(i)
        , p_incident_id             => l_task_info.source_object_id
        , p_start                   => l_task_info.planned_start_date
        , p_end                     => l_task_info.planned_end_date
        , p_contracts_flag          => g_auto_contract_flag
        , p_ib_flag                 => g_auto_ib_flag
        , p_territory_flag          => g_auto_terr_flag
        , p_skill_flag              => g_auto_skills_flag
        , p_res_qualifier_tbl       => l_res_qualifiers
        , x_res_tbl                 => l_res_tbl
        );

        -- Unless it is an Unexpected Error... continue even with
        -- "No Resources Found" error. Java will do the proper error handling.
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      csf_requests_pvt.create_scheduler_request(
        p_api_version                    => 1
      , p_init_msg_list                  => fnd_api.g_false
      , p_commit                         => fnd_api.g_false
      , x_return_status                  => x_return_status
      , x_msg_count                      => x_msg_count
      , x_msg_data                       => x_msg_data
      , p_name                           => 'SearchAndSchedule'
      , p_object_id                      => p_task_tbl(i)
      , p_resource_tbl                   => l_res_tbl
      , p_parent_id                      => x_request_id
      , p_spares_mandatory               => g_spares_mandatory
      , p_spares_source                  => g_spares_source
      , p_standby_param                  => g_standby_shifts
      , x_request_id                     => l_child_request_id
      );

      i := p_task_tbl.NEXT(i);

    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_auto_request;

  PROCEDURE fill_request_resources(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2
  , p_commit             IN              VARCHAR2
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_request_id         IN              NUMBER
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'FILL_REQUEST_RESOURCES';

    l_res_qualifiers  csf_resource_pub.resource_qualifier_tbl_type;
    l_res_tbl         csf_requests_pvt.resource_tbl_type;
    iIndex            PLS_INTEGER;
    l_role            VARCHAR2(30);

    CURSOR c_request_task_list IS
      SELECT rt.request_task_id
           , t.task_id
           , t.source_object_id
           , t.planned_start_date
           , t.planned_end_date
        FROM (  SELECT sched_request_id
                  FROM csf_r_sched_requests
                 WHERE parent_request_id = p_request_id
                UNION ALL
                SELECT sched_request_id
                  FROM csf_r_sched_requests
                 WHERE sched_request_id = p_request_id
                   AND NOT EXISTS (SELECT 1
                                     FROM csf_r_sched_requests
                                    WHERE parent_request_id = p_request_id)
             ) r
           , csf_r_request_tasks rt
           , jtf_tasks_b t
       WHERE rt.sched_request_id = r.sched_request_id
         AND NOT EXISTS ( SELECT 1
                            FROM csf_r_resource_results rr
                           WHERE rr.request_task_id = rt.request_task_id
                         )
         AND t.task_id = rt.task_id;

  BEGIN
    SAVEPOINT fill_request_resources;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    FOR l_task_rec IN c_request_task_list LOOP

      -- Get the Qualified Resources for this Task.
      -- Validate the Planned Window (same logic as that done in DC)
      csf_tasks_pub.validate_planned_dates(l_task_rec.planned_start_date, l_task_rec.planned_end_date);

      -- Get the Resources for this Task.
      csf_resource_pub.get_resources_to_schedule(
        p_api_version             => 1
      , p_init_msg_list           => fnd_api.g_false
      , x_return_status           => x_return_status
      , x_msg_count               => x_msg_count
      , x_msg_data                => x_msg_data
      , p_scheduling_mode         => 'X'       -- Auto Assign mode
      , p_task_id                 => l_task_rec.task_id
      , p_incident_id             => l_task_rec.source_object_id
      , p_start                   => l_task_rec.planned_start_date
      , p_end                     => l_task_rec.planned_end_date
      , p_contracts_flag          => g_auto_contract_flag
      , p_ib_flag                 => g_auto_ib_flag
      , p_territory_flag          => g_auto_terr_flag
      , p_skill_flag              => g_auto_skills_flag
      , p_res_qualifier_tbl       => l_res_qualifiers
      , x_res_tbl                 => l_res_tbl
      );

      -- Unless it is an Unexpected Error... continue even with
      -- "No Resources Found" error. Java will do the proper error handling.
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- Filter out the Resources with Third Party Service provider Role.

      /* iIndex := l_res_tbl.FIRST;

      WHILE iIndex IS NOT NULL
      LOOP
        l_role := csr_scheduler_pvt.get_third_party_res_role( l_res_tbl(iIndex).resource_id
                                                            , l_res_tbl(iIndex).resource_type
                                                            );
        IF l_role = 'CSF_THIRD_PARTY_SERVICE_PROVID'
        THEN
          l_res_tbl.DELETE(iIndex) ;
        END IF;
        iIndex := l_res_tbl.NEXT(iIndex);
      END LOOP;  */



      csf_requests_pvt.create_resource_results(
        p_api_version      => 1
      , p_init_msg_list    => fnd_api.g_false
      , p_commit           => fnd_api.g_false
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      , p_request_task_id  => l_task_rec.request_task_id
      , p_resource_tbl     => l_res_tbl
      );
    END LOOP;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO fill_request_resources;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO fill_request_resources;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO fill_request_resources;
  END fill_request_resources;

  PROCEDURE search_and_schedule_auto(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2
  , p_commit             IN              VARCHAR2
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_task_tbl           IN              csf_requests_pvt.object_tbl_type
  , x_sched_request_id   OUT NOCOPY      NUMBER
  , x_conc_request_id    OUT NOCOPY      NUMBER
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'SEARCH_AND_SCHEDULE_AUTO';
  BEGIN
    SAVEPOINT search_and_schedule_auto_pub;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT p_task_tbl.LAST > 0 THEN
      IF NOT valid_argument(NULL, 'task_tbl', l_api_name) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Create the SearchAndScheduleAuto Request.
    create_auto_request(
      x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
    , p_task_tbl       => p_task_tbl
    , p_find_resources => fnd_api.g_false
    , x_request_id     => x_sched_request_id
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Submit the Scheduler concurrent program
    x_conc_request_id := fnd_request.submit_request(
                           application     => 'CSR'
                         , program         => g_conc_program_name
                         , description     => fnd_message.get_string('CSF', 'CSF_R_SEMI_INTERACTIVE_DESC')
                         , sub_request     => FALSE
                         , argument1       => TO_CHAR(x_sched_request_id)
                         );

    IF x_conc_request_id = 0 THEN
      -- FND_REQUEST.SUBMIT_REQUEST should have populated the Message Stack.
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO search_and_schedule_auto_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO search_and_schedule_auto_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO search_and_schedule_auto_pub;
  END search_and_schedule_auto;

  PROCEDURE create_auto_request(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2
  , p_commit             IN              VARCHAR2
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_query_id           IN              NUMBER
  , x_sched_request_id   OUT NOCOPY      NUMBER
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_AUTO_REQUEST';

    l_where      csf_dc_queries_b.where_clause%TYPE;
    l_stmt       VARCHAR2(4000);
    c_task_list  ref_cursor_type;
    l_task_tbl   csf_requests_pvt.object_tbl_type;
  BEGIN
    SAVEPOINT create_auto_request_pub;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF NOT valid_argument(p_query_id, 'query_id', l_api_name) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Get the WHERE CLAUSE for the Given Query ID.

    l_where := csf_util_pvt.get_query_where(p_query_id);

    IF l_where IS NULL THEN
      RAISE no_data_found;
    END IF;

    -- Create the Task List Query using the WHERE CLAUSE
    l_stmt := 'SELECT task_id FROM csf_ct_tasks WHERE ' || l_where || ' ORDER BY scheduled_start_date NULLS FIRST, planned_end_date, creation_date';

    l_task_tbl := csf_requests_pvt.object_tbl_type();

    -- Fetch the Task List
    OPEN c_task_list FOR l_stmt;
    FETCH c_task_list BULK COLLECT INTO l_task_tbl;
    CLOSE c_task_list;

    -- Create the SearchAndScheduleAuto Request
    create_auto_request(
      x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
    , p_task_tbl       => l_task_tbl
    , x_request_id     => x_sched_request_id
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_auto_request_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_auto_request_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO create_auto_request_pub;
  END create_auto_request;

  PROCEDURE create_optimize_trips_request(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2
  , p_commit             IN              VARCHAR2
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_terr_id            IN              NUMBER
  , p_start_date         IN              DATE
  , p_end_date           IN              DATE
  , x_sched_request_id   OUT NOCOPY      NUMBER
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_OPTIMIZE_TRIPS_REQUEST';

    CURSOR c_resources IS
      SELECT resource_id, resource_type, terr_id FROM
      (SELECT /*+ cardinality(t, 1) */ DISTINCT trs.resource_id, trs.resource_type, trs.terr_id
               , RANK () OVER (PARTITION BY trs.resource_id, trs.resource_type ORDER BY NVL
                                                           (tra.absolute_rank,
                                                            0
                                                           ) DESC NULLS LAST)
                                                                 AS comp_rank
        FROM jtf_terr_rsc_all trs, jtf_terr_all tra
           , TABLE( CAST ( csf_util_pvt.get_selected_terr_table AS jtf_number_table ) ) t
       WHERE trs.terr_id = t.column_value
         AND (p_terr_id IS NULL OR trs.terr_id = p_terr_id))
          WHERE comp_rank = 1;

    l_res_id_tbl   jtf_number_table;
    l_res_type_tbl jtf_varchar2_table_100;
    l_res_terrid_tbl  jtf_number_table;
    l_resource_tbl csf_requests_pvt.resource_tbl_type;
  BEGIN
    SAVEPOINT create_opt_request_pub;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    OPEN c_resources;
    FETCH c_resources BULK COLLECT INTO l_res_id_tbl, l_res_type_tbl, l_res_terrid_tbl;
    CLOSE c_resources;

    l_resource_tbl := csf_requests_pvt.resource_tbl_type();
    FOR i IN  1..l_res_id_tbl.COUNT LOOP
      l_resource_tbl.EXTEND;
      l_resource_tbl(i).resource_id              := l_res_id_tbl(i);
      l_resource_tbl(i).resource_type            := l_res_type_tbl(i);
      l_resource_tbl(i).planwin_start            := p_start_date;
      l_resource_tbl(i).planwin_end              := p_end_date;
      l_resource_tbl(i).planwin_end              := p_end_date;
      l_resource_tbl(i).preferred_resources_flag := 'N';
      l_resource_tbl(i).TERRITORY_ID             := l_res_terrid_tbl(i);
    END LOOP;

    csf_requests_pvt.create_scheduler_request(
      p_api_version      => 1.0
    , x_return_status    => x_return_status
    , x_msg_count        => x_msg_count
    , x_msg_data         => x_msg_data
    , p_name             => 'OptimizeAcrossTrips'
    , p_object_id        => -1
    , p_resource_tbl     => l_resource_tbl
    , x_request_id       => x_sched_request_id
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_opt_request_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_opt_request_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO create_opt_request_pub;
  END create_optimize_trips_request;

  PROCEDURE get_qualified_resources(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_task_id_tbl        IN              jtf_number_table
  , p_start_date_tbl     IN              jtf_date_table
  , p_end_date_tbl       IN              jtf_date_table
  , x_task_resources_tbl OUT NOCOPY      csf_task_resources_tbl_type
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'GET_QUALIFIED_RESOURCES';
    l_role         VARCHAR2(30) := NULL;

    CURSOR c_task_info IS
      SELECT source_object_id
        FROM jtf_tasks_b t
           , TABLE( CAST ( p_task_id_tbl AS jtf_number_table ) ) tt
       WHERE t.task_id = tt.COLUMN_VALUE;

    l_res_qualifiers  csf_resource_pub.resource_qualifier_tbl_type;
    l_res_tbl        jtf_assign_pub.assignresources_tbl_type;
    l_res_idx        PLS_INTEGER;
    l_task_res_tbl   csf_resource_tbl;
    l_sr_id_tbl      jtf_number_table;
    l_res_preferred  VARCHAR2(1);
    l_start_date     DATE;
    l_end_date       DATE;

  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    l_task_res_tbl := csf_resource_tbl();
    x_task_resources_tbl := csf_task_resources_tbl_type();

    OPEN c_task_info;
    FETCH c_task_info BULK COLLECT INTO l_sr_id_tbl;
    CLOSE c_task_info;

    FOR i IN 1..p_task_id_tbl.COUNT LOOP
      l_start_date := p_start_date_tbl(i);
      l_end_date   := p_end_date_tbl(i);

      -- Get the Qualified Resources for this Task.
      -- Validate the Planned Window (same logic as that done in DC)
      csf_tasks_pub.validate_planned_dates(l_start_date, l_end_date);

      -- Get the Resources for this Task.
      csf_resource_pub.get_resources_to_schedule(
        p_api_version             => 1.0
      , p_init_msg_list           => fnd_api.g_false
      , x_return_status           => x_return_status
      , x_msg_count               => x_msg_count
      , x_msg_data                => x_msg_data
      , p_scheduling_mode         => 'O'       -- Optimizer mode
      , p_task_id                 => p_task_id_tbl(i)
      , p_incident_id             => l_sr_id_tbl(i)
      , p_start                   => l_start_date
      , p_end                     => l_end_date
      , p_contracts_flag          => g_auto_contract_flag
      , p_ib_flag                 => g_auto_ib_flag
      , p_territory_flag          => g_auto_terr_flag
      , p_skill_flag              => g_auto_skills_flag
      , p_res_qualifier_tbl       => l_res_qualifiers
      , x_res_tbl                 => l_res_tbl
      );

      l_task_res_tbl.DELETE;
      l_res_idx := l_res_tbl.FIRST;
      WHILE l_res_idx IS NOT NULL LOOP
        l_res_preferred := 'N';
        IF l_res_tbl(l_res_idx).preference_type IN ('I', 'C') THEN
          l_res_preferred := 'Y';
        END IF;

        l_role := csr_scheduler_pvt.get_third_party_res_role( l_res_tbl(l_res_idx).resource_id
                                                            , l_res_tbl(l_res_idx).resource_type
                                                            );

        l_task_res_tbl.EXTEND;
        l_task_res_tbl(l_task_res_tbl.COUNT) :=
              csf_resource(
                l_res_preferred
              , NULL
              , NULL
              , l_res_tbl(l_res_idx).resource_id
              , l_res_tbl(l_res_idx).resource_type
              , NULL
              , l_res_tbl(l_res_idx).start_date
              , l_res_tbl(l_res_idx).end_date
              , l_role
              );

        l_res_idx := l_res_tbl.NEXT(l_res_idx);
      END LOOP;

      x_task_resources_tbl.EXTEND();
      x_task_resources_tbl(i) := l_task_res_tbl;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_qualified_resources;

  FUNCTION check_material_for_task(p_task_assignment_id IN NUMBER)
    RETURN VARCHAR2 IS

    l_has_material_transactions varchar2(1);

    l_order_id  NUMBER;
    l_status varchar2(30);

    CURSOR c_get_reservations is
      SELECT 'Y'
        FROM csp_req_line_details crld
           , csp_requirement_lines crl
           , csp_requirement_headers crh
       WHERE crh.task_assignment_id = p_task_assignment_id
         AND crl.requirement_header_id = crh.requirement_header_id
         AND crld.requirement_line_id = crl.requirement_line_id
         AND crld.source_type = 'RES' ;

    CURSOR c_get_orders is
      SELECT 'Y'
        FROM csp_req_line_details crld
           , csp_requirement_lines crl
           , csp_requirement_headers crh
           , oe_order_lines_all oel
           , oe_order_headers_all oeh
       WHERE crh.task_assignment_id = p_task_assignment_id
         AND crl.requirement_header_id = crh.requirement_header_id
         AND crld.requirement_line_id = crl.requirement_line_id
         AND crld.source_type = 'IO'
         AND oel.line_id = crld.source_id
         AND oeh.header_id =  oel.header_id
         AND oeh.flow_status_code <>'CANCELLED'
       ORDER BY oeh.header_id;


  BEGIN

    l_has_material_transactions := 'N';

    OPEN c_get_reservations ;
    FETCH c_get_reservations INTO l_has_material_transactions;
    CLOSE c_get_reservations;

    IF l_has_material_transactions <> 'Y' THEN
      OPEN c_get_orders;
      FETCH c_get_orders INTO l_has_material_transactions;
      CLOSE c_get_orders;
    END IF;

    RETURN  l_has_material_transactions;

  END check_material_for_task;

  /**
   * Lock the Trips and the Tasks of the given Resources. It will
   * try three times before throwing an exception that LOCK COULD
   * NOT BE OBTAINED.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_resource_tbl          Resources whose Trips and Tasks
   *                                  and Tasks needs to be locked.
   */
  PROCEDURE lock_trips_and_tasks(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_resource_tbl       IN              csf_resource_tbl
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'LOCK_TRIPS_AND_TASKS';

    CURSOR c_trips_and_tasks IS
      SELECT t.task_id
           , ta.task_assignment_id
           , ah.access_hour_id
           , oc.object_capacity_id
        FROM jtf_tasks_b t
           , jtf_task_assignments ta
           , jtf_task_statuses_b ts
           , csf_access_hours_b ah
           , cac_sr_object_capacity oc
           , TABLE ( CAST ( p_resource_tbl AS CSF_RESOURCE_TBL ) ) r
       WHERE t.task_id = ta.task_id
         AND ta.assignment_status_id = ts.task_status_id
         AND t.task_id = ah.task_id(+)
         AND ta.resource_id = oc.object_id
         AND ta.resource_type_code = oc.object_type
         AND (
                 (     ta.object_capacity_id IS NOT NULL
                   AND ta.object_capacity_id = oc.object_capacity_id
                 )
              OR (
                       ta.object_capacity_id IS NULL
                   AND ta.booking_start_date < oc.end_date_time
                   AND ta.booking_end_date > oc.start_date_time
                 )
             )
         AND t.scheduled_end_date >= t.scheduled_start_date
         AND (t.deleted_flag = 'N' OR t.deleted_flag IS NULL)
         AND (
                 NVL(ta.actual_start_date, ta.actual_end_date) IS NOT NULL
              OR ((ts.cancelled_flag = 'N' OR ts.cancelled_flag IS NULL))
             )
         AND oc.object_id = r.resource_id
         AND oc.object_type = r.resource_type
         AND oc.start_date_time <= r.planwin_end
         AND oc.end_date_time >= r.planwin_start
         FOR UPDATE OF t.task_id, ta.task_assignment_id, ah.access_hour_id, oc.object_capacity_id NOWAIT;

    l_objects_locked BOOLEAN;
  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    l_objects_locked := FALSE;

    FOR i IN 1..3 LOOP
      BEGIN
        OPEN c_trips_and_tasks;
        CLOSE c_trips_and_tasks;

        l_objects_locked := TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          IF c_trips_and_tasks%ISOPEN THEN
            CLOSE c_trips_and_tasks;
          END IF;
      END;

      EXIT WHEN l_objects_locked;
      dbms_lock.sleep( i * 2 );
    END LOOP;

    IF NOT l_objects_locked THEN
      fnd_message.set_name ('CSR', 'CSR_LOCKING_RES_TRIPS_FAILED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END lock_trips_and_tasks;

  FUNCTION get_third_party_res_role(
     p_resource_id        IN              NUMBER
   , p_resource_type      IN              VARCHAR2
   ) RETURN VARCHAR2 IS

  -- Returns NULL for Internal or Wrong Setup
  -- Returns TPT or TPA or TPS role name

  CURSOR c_roles IS
  SELECT jrb.role_code
       , jrr.role_resource_type
   FROM  jtf_rs_role_relations jrr
       , jtf_rs_roles_b jrb
   WHERE jrr.role_id = jrb.role_id
     AND jrr.role_resource_id = p_resource_id
     AND jrb.role_type_code = 'CSF_THIRD_PARTY'
     AND jrr.role_resource_type = p_resource_type
     AND ( jrr.start_date_active IS NULL or trunc(jrr.start_date_active) <= sysdate )
     AND ( jrr.end_date_active IS NULL or trunc(jrr.end_date_active) >= sysdate )
     AND NVL( jrr.delete_flag, 'N') = 'N'
  ORDER BY 1;

    l_role VARCHAR2(30) := NULL;
    l_type VARCHAR2(30) := NULL;

  BEGIN
    IF ( p_resource_id IS NOT NULL and p_resource_type IS NOT NULL ) THEN
      OPEN c_roles;
      LOOP
        FETCH c_roles INTO l_role, l_type;
        EXIT WHEN c_roles%NOTFOUND;
        -- A Group Resource with TPS is eligible for third party scheduling
        -- Any other type of resource with TPS is considered as Internal Resource
        IF l_role = 'CSF_THIRD_PARTY_SERVICE_PROVID' AND l_type = 'RS_GROUP'
        THEN
          RETURN l_role;
        END IF;
        IF l_role = 'CSF_THIRD_PARTY_TECHNICIAN'
        THEN
           RETURN l_role;
        END IF;
      END LOOP;
      RETURN l_role;
    END IF;
    RETURN NULL;
  END get_third_party_res_role;

END csr_scheduler_pvt;

/
