--------------------------------------------------------
--  DDL for Package CSR_SCHEDULER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSR_SCHEDULER_PVT" AUTHID CURRENT_USER AS
/* $Header: CSRVSCHS.pls 120.10.12010000.4 2010/03/18 13:14:32 rkamasam ship $ */

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
  );

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
    RETURN DATE;

  /**
   * Returns the Time Zone Difference between the given Timezone
   * and the Server Timezone in Half Hour Units
   *
   * @param  p_timezone_id   Timezone Identifier
   * @return Difference in Half Hour Units
   */
  FUNCTION get_server_timezone_offset(p_timezone_id IN NUMBER)
    RETURN NUMBER;


  /**
   * Gets the Timezone corresponding to the given Address.
   *
   * If no timezone is found for the Address or the Address is invalid,
   * then the API returns Server Timezone as defined by GET_SERVER_TIMEZONE.
   *
   * @return Timezone corresponding to the given Address.
   */
  FUNCTION get_timezone(p_address_id IN NUMBER)
    RETURN NUMBER;

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
  FUNCTION get_server_timezone
    RETURN NUMBER;

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
   * @param   p_spares_likelihood     	      Spares Likelihood to be used for this request
   * @param   p_route_based_flag      	      Flag to enable route based scheduling for this request
   * @param   p_disabled_access_hours_flag    Activate access hours if any assigned for the task.
   * @param   x_request_id                    Request id of created request

   * The API  first finds the set of qualified resoucres for the given task
   * based on the qualifers given.
   * It then creates appropriate serach request based on the request name
   */
  PROCEDURE create_search_request(
    p_api_version                IN          NUMBER
  , p_init_msg_list              IN          VARCHAR2
  , p_commit                     IN          VARCHAR2
  , x_return_status              OUT  NOCOPY VARCHAR2
  , x_msg_count                  OUT  NOCOPY NUMBER
  , x_msg_data                   OUT  NOCOPY VARCHAR2
  , p_request_name               IN          VARCHAR2
  , p_task_id                    IN          NUMBER
  , p_contracts_flag             IN          VARCHAR2
  , p_ib_flag                    IN          VARCHAR2
  , p_territory_flag             IN          VARCHAR2
  , p_skill_flag                 IN          VARCHAR2
  , p_resource_id_tbl            IN          jtf_number_table
  , p_resource_type_tbl          IN          jtf_varchar2_table_100
  , p_spares_mandatory           IN          VARCHAR2
  , p_spares_source              IN          VARCHAR2
  , p_consider_standby_shifts    IN          VARCHAR2
  , p_route_based_flag           IN          VARCHAR2
  , p_disabled_access_hours_flag IN          VARCHAR2
  , x_request_id                 OUT  NOCOPY NUMBER
  );

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
    p_api_version               IN   NUMBER
  , p_init_msg_list             IN   VARCHAR2
  , p_commit                    IN   VARCHAR2
  , x_return_status             OUT  NOCOPY VARCHAR2
  , x_msg_count                 OUT  NOCOPY NUMBER
  , x_msg_data                  OUT  NOCOPY VARCHAR2
  , p_plan_option_id            IN   NUMBER
  , p_target_status_id          IN   NUMBER
  , p_set_plan_task_confirmed   IN   VARCHAR2
  , x_request_id                OUT  NOCOPY NUMBER
  );

  /**
   * Fills the Qualified Resources for all the Tasks associated with the
   * given Request.
   * <br>
   * Note that Auto-Schedule Request submitted from Dispatch Center will
   * create a SearchAndScheduleAuto Request containing only the Task
   * Information and not the Resource Information to improve the performance.
   * Scheduler will call this API to fill the tasks with Qualified Resources
   * before proceeding with Scheduling Operation.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_request_id            Request ID whose Tasks should be processed.
   */
  PROCEDURE fill_request_resources(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2 DEFAULT NULL
  , p_commit             IN              VARCHAR2 DEFAULT NULL
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_request_id         IN              NUMBER
  );

  /**
   * Search Plan Options for the given list of To-Be-Planned Tasks and
   * automatically Schedule the Best Option for each task.
   * <br>
   * This is generally used by Semi-Interative Scheduling wherein the End User
   * selects a list of Tasks to be processed in Task List of Dispatch Center.
   * Ultimately the API requires the List of Tasks to be processed.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   p_commit                Commit the Work.
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_task_tbl              List of Tasks to be processed
   * @param   x_sched_request_id      Scheduler Request ID (CSF_R_SCHED_REQUEST)
   * @param   x_conc_request_id       Concurrent Request ID (FND_CONCURRENT_REQUESTS)
   */
  PROCEDURE search_and_schedule_auto(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2 DEFAULT NULL
  , p_commit             IN              VARCHAR2 DEFAULT NULL
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_task_tbl           IN              csf_requests_pvt.object_tbl_type
  , x_sched_request_id   OUT NOCOPY      NUMBER
  , x_conc_request_id    OUT NOCOPY      NUMBER
  );

  /**
   * Creates a Scheduler Request for the given Query so that Autonomous Scheduler
   * can process the Tasks as stored in the created request.
   *
   * Retrives the list of valid Tasks to be processed using the given Query ID
   * and creates a parent Scheduler Request (A) with name "SearchAndScheduleAuto" and
   * creates a Scheduler Request "SearchAndSchedule" for each Task in the above Task
   * Table with Parent Request ID as (A). Morever the table CSF_R_RESOURCE_RESULTS
   * will be populated by the valid Resource Candidates suitable to perform the
   * Task as determined by CSR_SCHEDULER_PVT.GET_ASSIGN_TASK_RESOURCES.
   * <br>
   * Note that the returned Scheduler Request ID is of the parent SearchAndScheduleAuto
   * Request (A) and not that the individual child requests SearchAndSchedule.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   p_commit                Commit the Work.
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_task_tbl              List of Tasks to be processed
   * @param   x_sched_request_id      Scheduler Request ID (CSF_R_SCHED_REQUEST)
   */
  PROCEDURE create_auto_request(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2 DEFAULT NULL
  , p_commit             IN              VARCHAR2 DEFAULT NULL
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_query_id           IN              NUMBER
  , x_sched_request_id   OUT NOCOPY      NUMBER
  );

  /**
   * For a given Task Assignment, this API checks whether there exists Material
   * Transactions (Reservations or Orders) created against it.
   *
   * @param   p_task_assignment_id   Task Assignment Id to be checked for
   *
   * Returns Y in case there exists Transactions. N otherwise.
   */
  FUNCTION check_material_for_task(p_task_assignment_id IN NUMBER)
    RETURN VARCHAR2;

  /**
   * Creates a Scheduler Request for the given Territory so that
   * Autonomous Scheduler can optimize across all the trips
   * belonging to the resources attached to the territory.
   *
   * In case the caller wants to restrict the optimization to only
   * one Territory, then the parameter P_TERR_ID can be populated
   * with the relevant Territory Id. If not, the caller can send
   * the value as NULL so that all the Dispatcher Selected
   * Territories will be used.
   * <br>
   * All the Trips within the given timeframe (P_START_DATE
   * and P_END_DATE) belonging to the Resources attached to the
   * Territories will be processed.
   * <br>
   * A Parent Request OptimizeTrips will be created and a single
   * Child Request OptimizeTrip will be created with all the
   * Resource Information.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   p_commit                Commit the Work.
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_terr_id               Territory Id in case only a
   *                                  particular Territory needs
   *                                  to be processed.
   * @param   p_start_date            Start Date of the timeframe
   * @param   p_end_date              End Date of the timeframe
   * @param   x_sched_request_id      Scheduler Request ID (CSF_R_SCHED_REQUEST)
   */
  PROCEDURE create_optimize_trips_request(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2  DEFAULT NULL
  , p_commit             IN              VARCHAR2  DEFAULT NULL
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_terr_id            IN              NUMBER    DEFAULT NULL
  , p_start_date         IN              DATE
  , p_end_date           IN              DATE
  , x_sched_request_id   OUT NOCOPY      NUMBER
  );

  /**
   * Gets the Qualified Resources for all the Tasks as given in the input task list.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_task_id_tbl           Table of Task Identifiers
   * @param   p_start_date_tbl        Table of Start Date of Activity for the Tasks
   * @param   p_end_date_tbl          Table of End Date of Activity for the Tasks
   * @param   x_resources_tbl         Table of Resources for each
   *                                  task. Each entry is a table
   *                                  by itself.
   */
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
  );

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
  );

  FUNCTION get_third_party_res_role(
    p_resource_id        IN              NUMBER
  , p_resource_type      IN              VARCHAR2
  ) RETURN VARCHAR2;


END csr_scheduler_pvt;

/
