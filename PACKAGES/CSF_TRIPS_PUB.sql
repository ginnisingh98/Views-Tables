--------------------------------------------------------
--  DDL for Package CSF_TRIPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_TRIPS_PUB" AUTHID CURRENT_USER AS
  /* $Header: CSFPTRPS.pls 120.3.12010000.4 2009/04/23 12:59:24 ramchint ship $ */

  -- Maps to a Trip Record in CAC_SR_OBJECT_CAPACITY Table.
  TYPE trip_rec_type IS RECORD (
    trip_id                 NUMBER
  , object_version_number   NUMBER
  , resource_type           VARCHAR2(30)
  , resource_id             NUMBER
  , start_date_time         DATE
  , end_date_time           DATE
  , available_hours         NUMBER
  , available_hours_before  NUMBER
  , available_hours_after   NUMBER
  , schedule_detail_id      NUMBER
  , status                  NUMBER
  , availability_type      varchar2(30)
  );

  -- A Table of Trips.
  TYPE trip_tbl_type IS TABLE OF trip_rec_type
    INDEX BY BINARY_INTEGER;

  g_action_create_trip  CONSTANT VARCHAR2(10) := 'ADD';
  g_action_delete_trip  CONSTANT VARCHAR2(10) := 'DELETE';
  g_action_replace_trip CONSTANT VARCHAR2(10) := 'REPLACE';
  g_action_fix_trip     CONSTANT VARCHAR2(10) := 'FIX';
  g_action_upgrade_trip CONSTANT VARCHAR2(10) := 'UPGRADE';
  g_action_close_trip   CONSTANT VARCHAR2(10) := 'CLOSE';
  g_action_block_trip   CONSTANT VARCHAR2(10) := 'BLOCK';
  g_action_unblock_trip CONSTANT VARCHAR2(10) := 'UNBLOCK';

  g_trip_unavailable    CONSTANT NUMBER := 0;
  g_trip_available      CONSTANT NUMBER := 1;

  /**
   * Searches for a Trip existing for the passed selection criteria.
   * Searches CAC_SR_OBJECT_CAPACITY for the Trips that exists for the Resource
   * identified by P_RESOURCE_ID before the passed two dates.
   * <br>
   * Fills the message stack with the message identified by CSF_NO_TRIPS_FOUND or
   * CSF_MULTIPLE_TRIPS_FOUND upon encountering Zero Trips or Many Trips
   * respectively.
   * <br>
   * Differs from the overloaded version of FIND_TRIP in the sense that this API
   * returns the entire Trip Structure.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_resource_id             Resource ID
   * @param  p_resource_type           Resource Type
   * @param  p_start_date_time         Start Date Time
   * @param  p_end_date_time           End Date Time
   * @param  p_overtime_flag           Flag to consider Overtime (Optional.. Defaults to FND_API.G_TRUE)
   * @param  x_trip                    Fetched Trips
   *
   * @see find_trips                   Find many Trips API
   **/
  PROCEDURE find_trip(
    p_api_version      IN          NUMBER
  , p_init_msg_list    IN          VARCHAR2 DEFAULT NULL
  , x_return_status   OUT  NOCOPY  VARCHAR2
  , x_msg_data        OUT  NOCOPY  VARCHAR2
  , x_msg_count       OUT  NOCOPY  NUMBER
  , p_resource_id      IN          NUMBER
  , p_resource_type    IN          VARCHAR2
  , p_start_date_time  IN          DATE
  , p_end_date_time    IN          DATE
  , p_overtime_flag    IN          VARCHAR2 DEFAULT NULL
  , x_trip            OUT  NOCOPY  trip_rec_type
  );

  /**
   * Searches for a Trip existing for the passed selection criteria.
   * Searches CAC_SR_OBJECT_CAPACITY for the Trips that exists for the Resource
   * identified by P_RESOURCE_ID before the passed two dates.
   * <br>
   * Fills the message stack with the message identified by CSF_NO_TRIPS_FOUND or
   * CSF_MULTIPLE_TRIPS_FOUND upon encountering Zero Trips or Many Trips
   * respectively.
   * <br>
   * Differs from the overloaded version of FIND_TRIP in the sense that this API
   * returns only the Trip ID.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_resource_id             Resource ID
   * @param  p_resource_type           Resource Type
   * @param  p_start_date_time         Start Date Time
   * @param  p_end_date_time           End Date Time
   * @param  p_overtime_flag           Flag to consider Overtime (Optional.. Defaults to FND_API.G_TRUE)
   * @param  x_trip_id                 Fetched Trip ID
   *
   * @see find_trips                   Find many Trips API
   **/
  PROCEDURE find_trip(
    p_api_version      IN          NUMBER
  , p_init_msg_list    IN          VARCHAR2 DEFAULT NULL
  , x_return_status   OUT  NOCOPY  VARCHAR2
  , x_msg_data        OUT  NOCOPY  VARCHAR2
  , x_msg_count       OUT  NOCOPY  NUMBER
  , p_resource_id      IN          NUMBER
  , p_resource_type    IN          VARCHAR2
  , p_start_date_time  IN          DATE
  , p_end_date_time    IN          DATE
  , p_overtime_flag    IN          VARCHAR2 DEFAULT NULL
  , x_trip_id         OUT  NOCOPY  NUMBER
  );

  /**
   * Searches for all the Trips existing for the passed selection criteria.
   * Searches CAC_SR_OBJECT_CAPACITY for the Trips that exists between the
   * passed two dates for each resource in the passed Resource List.
   * <br>
   * Doesnt throw any error message.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_resource_tbl            Table of Resources containing Resource ID and Type.
   * @param  p_start_date_time         Start Date Time
   * @param  p_end_date_time           End Date Time
   * @param  p_overtime_flag           Flag to consider Overtime (Optional..Defaults to FND_API.G_TRUE)
   * @param  x_trips                   Fetched Trips
   *
   * @see find_trip                    Find a Single Trip API
   **/
  PROCEDURE find_trips(
    p_api_version        IN          NUMBER
  , p_init_msg_list      IN          VARCHAR2 DEFAULT NULL
  , x_return_status     OUT  NOCOPY  VARCHAR2
  , x_msg_data          OUT  NOCOPY  VARCHAR2
  , x_msg_count         OUT  NOCOPY  NUMBER
  , p_resource_tbl       IN          csf_resource_pub.resource_tbl_type
  , p_start_date_time    IN          DATE
  , p_end_date_time      IN          DATE
  , p_overtime_flag      IN          VARCHAR2 DEFAULT NULL
  , x_trips             OUT  NOCOPY  trip_tbl_type
  );

  /**
   * Creates a Trip for the passed Resource constrained by the two times.
   * Creates a new Trip for the Resource identified by P_RESOURCE_ID constrained
   * by the two times Start and End Time.
   * <br>
   * This API checks for the existence of any trip which overlaps with the
   * specified boundary conditions for the Resource. Upon that error, the message
   * CSF_TRIP_ALREADY_EXISTS is pushed into the message stack.
   * Moreover it doesnt allow for a trip to be created if there exists some Shift
   * Tasks in the new Trip interval. Upon that error, the message
   * CSF_SHIFT_TASKS_EXIST is pushed into the message stack.
   * <br>
   * In addition to the above check, it is also mandatory that the total duration
   * between the two times should be less than or equal to 1 day.
   * <br>
   * 1. Moreover, the API automatically creates Shift Tasks 'Departure' and
   * 'Arrival' at the two end points of the Trip if needed. <br>
   * 2. The Availability of the Trip is set to the Total Duration between
   * identified by P_RESOURCE_ID before the passed two dates.<br>
   * 3. All the Task Assignments which fall within the Trip or overlap with
   * any one of boundary times will be tied to the Trip automatically.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commits the Database
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_resource_id             Resource ID
   * @param  p_resource_type           Resource Type
   * @param  p_start_date_time         Start Date Time
   * @param  p_end_date_time           End Date Time
   * @param  p_schedule_detail_id      (Not Used) Maps to CAC_SR_SCHEDULE_DETAILS
   * @param  p_status                  Initial Status of the Trip (Unblocked).
   * @param  p_find_tasks              Flag to indicate whether Tasks has to be linked
   * @param  x_trip_id                 Trip ID of the new Trip created.
   *
   * @see create_trips                 Create Multiple Trips API
   **/
  PROCEDURE create_trip(
    p_api_version           IN          NUMBER
  , p_init_msg_list         IN          VARCHAR2 DEFAULT NULL
  , p_commit                IN          VARCHAR2 DEFAULT NULL
  , x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_resource_id           IN          NUMBER
  , p_resource_type         IN          VARCHAR2
  , p_start_date_time       IN          DATE
  , p_end_date_time         IN          DATE
  , p_schedule_detail_id    IN          NUMBER   DEFAULT NULL
  , p_status                IN          NUMBER   DEFAULT NULL
  , p_find_tasks            IN          VARCHAR2 DEFAULT NULL
  , x_trip_id              OUT  NOCOPY  NUMBER
  );

  /**
   * Deletes the Trip given the Trip ID.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commits the Database
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_trip_id                 Trip ID
   * @param  p_object_version_number   Trip Object Version Number
   *
   * @see update_trip                  Update Trip API
   * @see delete_trips                 Delete Multiple Trips API
   **/
  PROCEDURE delete_trip(
    p_api_version             IN          NUMBER
  , p_init_msg_list           IN          VARCHAR2 DEFAULT NULL
  , p_commit                  IN          VARCHAR2 DEFAULT NULL
  , x_return_status          OUT  NOCOPY  VARCHAR2
  , x_msg_data               OUT  NOCOPY  VARCHAR2
  , x_msg_count              OUT  NOCOPY  NUMBER
  , p_trip_id                 IN          NUMBER
  , p_object_version_number   IN          NUMBER   DEFAULT NULL
  );

  /**
   * Updates the Availability of the Trip given the Trip ID.
   * Updates the Available, Available Before,  Available After Hours of the Trip
   * in the underlying database given the Trip ID.
   * <br>
   * The API first validates the passed Available Values. Both Available Hours and
   * Update Available Hours cant be passed. Only one of them can be passed. If they
   * make the Availability equal to Shift Length, then the value of Available Hours
   * Before and After are ignored and they are updated as NULL. <br>
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commits the Database
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_trip_id                 Trip ID
   * @param  p_object_version_number   Trip Object Version Number
   * @param  p_available_hours         Available Hours in the Trip
   * @param  p_upd_available_hours     Update Available Hours with value.
   * @param  p_available_hours_before  Available Hours in the start of Trip.
   * @param  p_available_hours_after   Available Hours at the end of Trip.
   * @param  p_status                  (Not Used) New Status of the Trip.
   *
   * @see delete_trip                  Delete Trip API
   **/
  PROCEDURE update_trip(
    p_api_version              IN          NUMBER
  , p_init_msg_list            IN          VARCHAR2      DEFAULT NULL
  , p_commit                   IN          VARCHAR2      DEFAULT NULL
  , x_return_status           OUT  NOCOPY  VARCHAR2
  , x_msg_data                OUT  NOCOPY  VARCHAR2
  , x_msg_count               OUT  NOCOPY  NUMBER
  , p_trip_id                  IN          NUMBER
  , p_object_version_number    IN          NUMBER        DEFAULT NULL
  , p_available_hours          IN          NUMBER        DEFAULT NULL
  , p_upd_available_hours      IN          NUMBER        DEFAULT NULL
  , p_available_hours_before   IN          NUMBER        DEFAULT NULL
  , p_available_hours_after    IN          NUMBER        DEFAULT NULL
  , p_status                   IN          NUMBER        DEFAULT NULL
  );

  /**
   * Fixes the passed Trip by pulling in all the valid Tasks into the Trip and
   * removing Tasks which doesnt fall / linking tasks which fall within
   * the Trip Boundary.
   * <br>
   * The API
   *   1. Task Assignments
   *      Finds all the Task Assignments which doesnt fall within the
   *      Trip Start Time and (Trip End Time + Overtime) and can be linked
   *      to another trip. If so, it removes the task from the Trip.
   *      Then it goes and checks whether there are any valid candidatees
   *      that can be made as part of the Trip.
   *   2. Shift Tasks
   *      Deletes any Duplicate Shift Task if present. If any of the Shift Task
   *      is not there... it creates one.
   *   3. Availability
   *      Computes the correct availability of the Trip and updates it.
   * <br>
   * During the process of find valid eligible Task Assignments, it doesnt care if the
   * Task Assignment is already part of another Trip (ie) Trip ID is already stamped in
   * the Task Assignment. This is because, it is mandatory for two trips not to overlap
   * anytime.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commits the Database
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_trip_id                 Trip ID
   *
   **/
  PROCEDURE fix_trip(
    p_api_version            IN          NUMBER
  , p_init_msg_list          IN          VARCHAR2 DEFAULT NULL
  , p_commit                 IN          VARCHAR2 DEFAULT NULL
  , x_return_status         OUT  NOCOPY  VARCHAR2
  , x_msg_data              OUT  NOCOPY  VARCHAR2
  , x_msg_count             OUT  NOCOPY  NUMBER
  , p_trip_id                IN          NUMBER
  , p_object_version_number  IN          NUMBER   DEFAULT NULL
  );

  /**
   * Processes the passed action on all the Trips falling between
   * the two dates passed for the given Resource.
   * Processes actions for a given Trip or for all Trips identified
   * by the passed Resource List and the two dates.
   * <br>
   * Either P_TRIP_ID has to be passed or the list of Resources along
   * with Start Date and End Date has to tbe passed for the API to
   * do something.
   * <br>
   * Action to be performed by the API on the Trips is identified
   * by P_TRIP_ACTION which takes values as given in the following table
   *
   *  --------------------------------------------------------------
   *  |    Operation      |    Identifier            |  Value      |
   *  --------------------------------------------------------------
   *  |  Create Trips     |  g_action_create_trip    |  ADD        |
   *  |  Delete Trips     |  g_action_delete_trip    |  DELETE     |
   *  |  Fix Trips        |  g_action_fix_trip       |  FIX        |
   *  |  Block Trips      |  g_action_block_trip     |  BLOCK      |
   *  |  Unblock Trips    |  g_action_unblock_trip   |  UNBLOCK    |
   *  |  Upgrade Trips    |  g_action_upgrade_trip   |  UPGRADE    |
   *  |  Replace Trips    |  g_action_replace_trip   |  REPLACE    |
   *  --------------------------------------------------------------
   *
   * <br>
   * In case of Block Trip and Unblock Trip, the tasks forming part of
   * the Trip will also be affected by the action. The eligible Tasks
   * are those which doesnt have Actuals entered or which are not
   * interrupted. The status of the task will move from Planned to
   * Blocked Planned and Assigned to Blocked Assigned or vice versa depending
   * on the action of the Trip.
   * <br>
   * The actions ADD (Create Trips) and REPLACE (Replace Trips) accept only
   * one resource currently in the table of resources passed.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List  (Optional)
   * @param  p_commit                  Commits the Database  (Optional)
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_action                  Action to be performed on the Trip.
   * @param  p_trip_id                 Trip to be processed. (Optional)
   * @param  p_resource_tbl            Table of Resources. (Optional)
   * @param  p_start_date              Start Date. (Optional)
   * @param  p_end_date                End Date. (Optional)
   **/
  PROCEDURE process_action(
    p_api_version             IN          NUMBER
  , p_init_msg_list           IN          VARCHAR2                           DEFAULT NULL
  , p_commit                  IN          VARCHAR2                           DEFAULT NULL
  , x_return_status          OUT  NOCOPY  VARCHAR2
  , x_msg_data               OUT  NOCOPY  VARCHAR2
  , x_msg_count              OUT  NOCOPY  NUMBER
  , p_action                  IN          VARCHAR2
  , p_trip_id                 IN          NUMBER                             DEFAULT NULL
  , p_resource_tbl            IN          csf_resource_pub.resource_tbl_type DEFAULT NULL
  , p_shift_type              IN         VARCHAR2                            DEFAULT NULL
  , p_start_date              IN          DATE                               DEFAULT NULL
  , p_end_date                IN          DATE                               DEFAULT NULL
  );

  /**
   * "Generate Trips Concurrent Program" - Generates the Trip Records for
   * the Resources under the current User or for the passed Resource.
   * <br>
   * This is the Generate Trips concurrent program and the API generates
   * the Trips records for the passed Resource or for all Resources under
   * all the Territories of the current User for the timespan given by
   * the Start and End Dates.
   * This Concurrent Program can be run in follwing Modes.
   * 1. Add     - Creates new Trips Records. <br>
   * 2. Delete  - Deletes existing Trip Records. <br>
   * 3. Replace - Deletes existing Trip Records and creates new ones. <br>
   * 4. Fix     - Fixes existing Trip Records to be proper. <br>
   * 5. Upgrade - Upgrades the current Shift Task Model to Trips Model.
   * <br>
   * Default Values: <br>
   * a. Default Action is ADD (Given in the Concurrent Program Definition). <br>
   * b. Default Start Date is SYSDATE. <br>
   * c. Default End Date is (Start Date + Plan Scope). <br>
   * d. Default Resource is NULL - All Resources under the User. <br>
   * <br>
   *
   * @param  errbuf                    Standard Concurrent Program Output Parameter
   * @param  retcode                   Standard Concurrent Program Output Parameter
   * @param  p_action                  Action to be accomplished by the CP.
   * @param  p_start_date              Start Date for the Action.
   * @param  p_num_days                Number of Days.
   * @param  p_resource_type           Resource Type for whom GTR has to be run
   * @param  p_resource_id             Resource ID for whom GTR has to be run
   **/
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
  );

  PROCEDURE optimize_across_trips(
    p_api_version             IN          NUMBER
  , p_init_msg_list           IN          VARCHAR2                           DEFAULT NULL
  , p_commit                  IN          VARCHAR2                           DEFAULT NULL
  , x_return_status          OUT  NOCOPY  VARCHAR2
  , x_msg_data               OUT  NOCOPY  VARCHAR2
  , x_msg_count              OUT  NOCOPY  NUMBER
  , x_conc_request_id        OUT  NOCOPY  NUMBER
  , p_resource_tbl            IN          csf_requests_pvt.resource_tbl_type DEFAULT NULL
  , p_start_date              IN          DATE                               DEFAULT NULL
  , p_end_date                IN          DATE                               DEFAULT NULL
  );

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
  );

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
  );
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
  );

   PROCEDURE create_trips(
    x_return_status        OUT  NOCOPY  VARCHAR2
  , x_msg_data             OUT  NOCOPY  VARCHAR2
  , x_msg_count            OUT  NOCOPY  NUMBER
  , p_resource_tbl          IN          csf_resource_pub.resource_tbl_type
  , p_start_date            IN          DATE
  , p_end_date              IN          DATE
  , p_shift_type            IN          VARCHAR2   DEFAULT NULL
  , p_delete_trips          IN          BOOLEAN    DEFAULT FALSE
  );

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
  );
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
  );

  PROCEDURE create_dc_trip( p_api_version           IN          NUMBER
                          , p_init_msg_list         IN          VARCHAR2
                          , p_commit                IN          VARCHAR2
                          , x_return_status        OUT  NOCOPY  VARCHAR2
                          , x_msg_data             OUT  NOCOPY  VARCHAR2
                          , x_msg_count            OUT  NOCOPY  NUMBER
                          , p_resource_tbl          IN          csf_resource_pub.resource_tbl_type
                          , p_start_date            IN          DATE
                          , p_end_date              IN          DATE
                          , p_delete_trips          IN          BOOLEAN    DEFAULT FALSE);

END csf_trips_pub;




/
