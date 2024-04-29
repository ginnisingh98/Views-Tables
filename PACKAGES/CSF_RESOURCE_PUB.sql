--------------------------------------------------------
--  DDL for Package CSF_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_RESOURCE_PUB" AUTHID CURRENT_USER AS
  /* $Header: CSFPRESS.pls 120.3.12010000.8 2010/04/05 07:23:27 rkamasam ship $ */

  /**
   * PLSQL Record Type to contain information about a Single Territory Qualifier.
   *
   * Information stored are Qualifier Usage ID, Enabled (or not), Label,
   * Value, Associated Value (in case of Qualifier having a second value)
   * and Display Value (where ID's are converted into Names).
   */
 TYPE resource_qualifier_rec_type IS RECORD(
    qual_usg_id        NUMBER          -- territories qualifier usage ID
  , use_flag           VARCHAR2(1)     -- checked/unchecked by user
  , label              VARCHAR2(60)    -- qualifier description for the UI
  , value              VARCHAR2(360)   -- qualifier value
  , associated_value   VARCHAR2(360)   -- value for qualifiers that occur in pairs
                                       --  (inventory item id and organization id).
  , display_value      VARCHAR2(360)   -- may be filled with a converted value
                                       -- (ID to name) when scheduling is being traced
  );

  /**
   * PLSQL Table Type to contain information about many Territory Qualifiers
   * where each element is of type RESOURCE_QUALIFIER_REC_TYPE.
   */
  TYPE resource_qualifier_tbl_type IS TABLE OF resource_qualifier_rec_type
    INDEX BY BINARY_INTEGER;

  /**
   * PLSQL Record Type to contain information about a Resource's Shift Definitions.
   *
   * Information stored are Shift Construct ID, Availability Type (not used), Shift Start
   * and End Time.
   */
  TYPE shift_rec_type IS RECORD(
    shift_construct_id  NUMBER
  , start_datetime      DATE
  , end_datetime        DATE
  , availability_type   VARCHAR2(40)
  );

  /**
   * PLSQL Table Type to contain information about many Shift Definitions
   * where each element is of type SHIFT_REC_TYPE.
   */
  TYPE shift_tbl_type IS TABLE OF shift_rec_type
    INDEX BY BINARY_INTEGER;

  /**
   * PLSQL Record Type to contain information about a Resource
   *
   */
  TYPE resource_rec_type IS RECORD(
    resource_id       NUMBER
  , resource_type     jtf_objects_b.object_code%TYPE
  , resource_name     jtf_rs_resource_extns_tl.resource_name%TYPE
  , resource_number   jtf_rs_resource_extns.resource_number%TYPE
  );

  /**
   * PLSQL Table Type to contain information about many Resources
   * where each element is of type RESOURCE_REC_TYPE.
   */
  TYPE resource_tbl_type IS TABLE OF resource_rec_type;

  /**
   * Returns the Resource Type Code corresponding to a Resource Category.
   * <br>
   * In sync with the code done in JTF_RS_ALL_RESOURCES_VL
   *
   * @param   p_category    Resource Category
   * @returns Resource Type Code (VARCHAR2).
   */
  FUNCTION rs_category_type (p_category VARCHAR2)
    RETURN VARCHAR2;

  /**
   * Returns the ID of the Resource tied to the given User (FND User).
   * <br>
   * If no User is passed in, then it will take the User who has logged in
   * (FND_GLOBAL.USER_ID).
   *
   * @param   p_user_id   Identifier to the User desired (Optional)
   * @returns Resource ID (NUMBER)
   */
  FUNCTION resource_id (p_user_id NUMBER DEFAULT NULL)
    RETURN NUMBER;

  /**
   * Returns the Resource Type of the Resource tied to the given user. (FND User)
   * <br>
   * If no User is passed in, then it will take the User who has logged in
   * (FND_GLOBAL.USER_ID).
   *
   * @param   p_user_id   Identifier to the User desired (Optional)
   * @returns Resource Type (VARCHAR2)
   */
  FUNCTION resource_type (p_user_id NUMBER DEFAULT NULL)
    RETURN VARCHAR2;

  /**
   * Returns the Resource Name given the Resource ID and Type.
   *
   * @param   p_res_id    Resource ID
   * @param   p_res_type  Resource Type Code
   * @returns Resource Name (VARCHAR2)
   */
  FUNCTION get_resource_name (p_res_id NUMBER, p_res_type VARCHAR2)
    RETURN VARCHAR2;

  /**
   * Returns the Resource Type Name corresponding to the Resource Type Code
   *
   * @param   p_res_type   Resource Type Code
   * @returns Resource Type Name (VARCHAR2)
   */
  FUNCTION get_resource_type_name (p_res_type VARCHAR2)
    RETURN VARCHAR2;

  /**
   * Returns the Address of the Party created for the Resource as of the
   * date passed.
   *
   * @param   p_res_id    Resource ID
   * @param   p_res_type  Resource Type Code
   * @param   p_date      Active Party Site for the given date
   *
   * @returns Party Address of the Resource
   */
  FUNCTION get_resource_party_address (
    p_res_id    NUMBER
  , p_res_type  VARCHAR2
  , p_date      DATE
  , p_res_shift_add VARCHAR2 DEFAULT NULL
  )
    RETURN csf_resource_address_pvt.address_rec_type;

  /**
   * Returns the Complete Resource Information given the Resource ID and Type.
   * The returned record includes Resource Number and Resource Name.
   *
   * @param   p_res_id    Resource ID
   * @param   p_res_type  Resource Type Code
   * @returns Resource Information filled in RESOURCE_REC_TYPE
   */
  FUNCTION get_resource_info(p_res_id NUMBER, p_res_type VARCHAR2)
    RETURN resource_rec_type;

  /**
   * Converts the given Time from Resource Timezone to Server Timezone
   * or vice versa.
   * <br>
   * By default, the given date is assumed to be in Resource Timezone and the
   * date returned is Server Timezone. Set p_server_to_resource parameter as
   * 'T' (FND_API.G_TRUE) to make it return the other way round.
   * <br>
   * Note that the API doesnt support RS_TEAM or RS_GROUP resources.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  p_resource_id             Resource ID
   * @param  p_resource_type           Resource Type
   * @param  p_datetime                Date to be converted
   * @param  p_server_to_resource      Server to Resource Timezone
   */
  PROCEDURE convert_timezone (
    p_api_version          IN              NUMBER
  , p_init_msg_list        IN              VARCHAR2 DEFAULT NULL
  , x_return_status        OUT NOCOPY      VARCHAR2
  , x_msg_count            OUT NOCOPY      NUMBER
  , x_msg_data             OUT NOCOPY      VARCHAR2
  , p_resource_id          IN              NUMBER
  , p_resource_type        IN              VARCHAR2
  , x_datetime             IN OUT NOCOPY   DATE
  , p_server_to_resource   IN              VARCHAR2 DEFAULT NULL
  );

  /**
   * Returns the Qualifier Table having the list of valid Qualifiers
   * based on the Task Information of the given Task ID.
   */
  FUNCTION get_res_qualifier_table(p_task_id NUMBER)
    RETURN resource_qualifier_tbl_type;

  /**
   * Converts the given Qualifier Table to Assignment Manager API Record
   * type.
   * Assembles the selected Qualifiers for this Task from the Qualifier
   * Table in to a Record Type understandable by JTF Assignment Manager.
   * <br>
   * Uses a Hard Coded Mapping between JTF_SEEDED_QUAL_USGS_V.QUAL_USG_ID
   * and the fields in JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE.
   * <br>
   * The Task and SR Number must be set by the caller and wont be set by
   * this API. Moreover Qualifiers of type -1211, -1212 and -1218 have
   * been disabled and therefore wont be set by this API.
   *
   * @param p_table   Qualifier Table having the list of Task Qualifiers
   */
  FUNCTION get_qualified_task_rec(p_table resource_qualifier_tbl_type)
    RETURN jtf_assign_pub.jtf_srv_task_rec_type;

  /**
   * Gets the Qualified Resources for a Task by calling JTF Assignment Manager
   * and also making use of the Required Skills of the Task if Required to reduce
   * the Resource List.
   *
   * <br>
   *
   * The reason for CSF to maintain its own Assignment Manager rather than
   * completely relying on JTF Assignment Manager has two fold reasons.
   * <br>
   * <b>TQ is secondary for JTF Assignment Manager API.</b>
   *    Suppose in Schedule Advise Window, all the Flags are checked... then
   *    JTF Assignment Manager will give preference to Contracts and IB only.
   *    Only when both of returns ZERO resources, then JTF will consider TQ.
   *    But DC expects an intersection of the three results.
   *    Moreover if both Contracts and IB are checked, then JTF will use
   *    the profile "JTFAM: Resource Search Order (JTF_AM_PREF_RES_ORDER)" to
   *    find out which one to return ultimately. If the value CONTRACTS, then
   *      CONTRACTS - Only Contracts is returned. If None, IB is returned.
   *      IB        - Only IB is returned. If None, Contracts is returned.
   *      BOTH      - Intersection of Contracts and IB Resources are returned.
   * <br>
   * <b>JTF doesnt have the concept of Skills. </b>
   *    Resources and Skills is completely a Field Service Functionality. A
   *    Resource can be attached to a Skill with a particular Skill Level.
   *    So can a Task be tied to a Skill with a particular Skill Level. If
   *    Skill based Flag is checked, then the Resource needs to have the same
   *    Skill Set with a Comparable Skill Level as required by the Task.
   *    Comparable Skill Level !!! - What is that ?
   *    The profile "CSF: Skill Level Match (CSF_SKILL_LEVEL_MATCH)" is used
   *    to decide whether the Resource has the Required Skill Level as required
   *    by the Task.
   *      EQUAL TO OR SMALLER THAN - Resource should have a Skill Level equal to
   *                                 or lesser than that of the Task.
   *      EQUAL TO                 - Resource should have a Skill Level equal to
   *                                 that of the Task.
   *      EQUAL TO OR GREATER THAN - Resource should have a Skill Level equal to
   *                                 or greater than that of the Task.
   *    Note that the Task needs to have Skills. Otherwise the Flag wont be used
   *    at all for getting the Qualified Resources.
   *
   * <br>
   *
   * Thus CSF Assignment Manager API will call JTF Assignment Manager separately
   * for Contracts / IB and then for Territory. Do an intersection of the Resources
   * obtained thru the two calls and pruned by Skill Sets. Note that it gets
   * Contracts / IB Resources from JTF in one call and so the user should make use
   * the profile JTF_AM_PREF_RES_ORDER to get intersected results.
   *
   * <br>
   * <b>Still to Implement</b>
   *    CSF Assignment Manager still doesnt pass the parameter P_FILTER_EXCLUDED_RESOURCE
   *    so that JTF Assignment Manager doesnt return Excluded Resources.
   *    CSF Assignment Manager still doesnt pass the parameter P_BUSINESS_PROCESS_ID
   *    so that JTF Assignment Manager returns only those Resources who belong to
   *    Field Service Business Process when Preferred Resources are entered in Contracts.
   *
   * @param   p_api_version             API Version (1.0)
   * @param   p_init_msg_list           Initialize Message List
   * @param   x_return_status           Return Status of the Procedure.
   * @param   x_msg_count               Number of Messages in the Stack.
   * @param   x_msg_data                Stack of Error Messages.
   * @param   p_task_id                 Task Identifier
   * @param   p_incident_id             Service Request ID
   * @param   p_task_rec                Qualified Task Record (Can be Empty)
   * @param   p_scheduling_mode         Scheduling Mode used. (A, I, W, X)
   * @param   p_start                   Start Date of the Plan Window
   * @param   p_end                     End Date of the Plan Window
   * @param   p_duration                Duration of the Task (Used by JTF to find out Available Resources)
   * @param   p_duration_uom            UOM of the above Duration
   * @param   p_contracts_flag          Get Contracts Preferred Resources ('Y'/'N')
   * @param   p_ib_flag                 Get IB Preferred Resources ('Y'/'N')
   * @param   p_territory_flag          Get Winning Territory Resources ('Y'/'N')
   * @param   p_skill_flag              Get Skilled Resources ('Y'/'N')
   * @param   p_calendar_flag           Get only Available Resources. Passed to JTF ('Y'/'N')
   * @param   p_sort_flag               Sort the Resources based on their distance from Task ('Y'/'N')
   * @param   p_suggested_res_id_tbl    Suggested Resource ID Table
   * @param   p_suggested_res_type_tbl  Suggested Resource Type Table
   * @param   x_res_tbl                 Qualified Resource suitable for Scheduling
   */
  PROCEDURE get_resources_to_schedule(
    p_api_version            IN              NUMBER
  , p_init_msg_list          IN              VARCHAR2 DEFAULT NULL
  , x_return_status          OUT NOCOPY      VARCHAR2
  , x_msg_count              OUT NOCOPY      NUMBER
  , x_msg_data               OUT NOCOPY      VARCHAR2
  , p_task_id                IN              NUMBER
  , p_incident_id            IN              NUMBER
  , p_res_qualifier_tbl      IN              resource_qualifier_tbl_type
  , p_scheduling_mode        IN              VARCHAR2
  , p_start                  IN              DATE
  , p_end                    IN              DATE
  , p_duration               IN              NUMBER                 DEFAULT NULL
  , p_duration_uom           IN              VARCHAR2               DEFAULT NULL
  , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
  , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
  , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
  , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
  , p_calendar_flag          IN              VARCHAR2               DEFAULT NULL
  , p_sort_flag              IN              VARCHAR2               DEFAULT NULL
  , p_suggested_res_id_tbl   IN              jtf_number_table       DEFAULT NULL
  , p_suggested_res_type_tbl IN              jtf_varchar2_table_100 DEFAULT NULL
  , x_res_tbl                OUT NOCOPY      jtf_assign_pub.assignresources_tbl_type
  );

  /**
   * Gets the Qualified Resources for a Task in a format understood by Request Model.
   * <br>
   * In turn calls the GET_RESOURCES_TO_SCHEDULE which gets the Resources in JTF
   * Assignment Manager Format.
   */
  PROCEDURE get_resources_to_schedule(
    p_api_version            IN              NUMBER
  , p_init_msg_list          IN              VARCHAR2 DEFAULT NULL
  , x_return_status          OUT NOCOPY      VARCHAR2
  , x_msg_count              OUT NOCOPY      NUMBER
  , x_msg_data               OUT NOCOPY      VARCHAR2
  , p_task_id                IN              NUMBER
  , p_incident_id            IN              NUMBER
  , p_res_qualifier_tbl      IN              resource_qualifier_tbl_type
  , p_scheduling_mode        IN              VARCHAR2
  , p_start                  IN              DATE
  , p_end                    IN              DATE
  , p_duration               IN              NUMBER                 DEFAULT NULL
  , p_duration_uom           IN              VARCHAR2               DEFAULT NULL
  , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
  , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
  , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
  , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
  , p_calendar_flag          IN              VARCHAR2               DEFAULT NULL
  , p_sort_flag              IN              VARCHAR2               DEFAULT NULL
  , p_suggested_res_id_tbl   IN              jtf_number_table       DEFAULT NULL
  , p_suggested_res_type_tbl IN              jtf_varchar2_table_100 DEFAULT NULL
  , x_res_tbl                IN OUT NOCOPY   csf_requests_pvt.resource_tbl_type
  );

  /**
   * Gets the Qualified Resources for a Task by calling JTF Assignment Manager
   * and also making use of the Required Skills of the Task if Required to reduce
   * the Resource List.
   *
   * This is nothing but a very simplified version on top of the existing
   * GET_QUALIFIED_RESOURCES. The output is in a different format
   * though. It returns Territory ID, Resource Source, Resource
   * Name also.
   * <br>
   *
   * @param   p_api_version             API Version (1.0)
   * @param   p_init_msg_list           Initialize Message List
   * @param   x_return_status           Return Status of the Procedure.
   * @param   x_msg_count               Number of Messages in the Stack.
   * @param   x_msg_data                Stack of Error Messages.
   * @param   p_task_id                 Task Identifier
   * @param   p_incident_id             Service Request ID
   * @param   p_contracts_flag          Get Contracts Preferred Resources ('Y'/'N')
   * @param   p_ib_flag                 Get IB Preferred Resources ('Y'/'N')
   * @param   p_territory_flag          Get Winning Territory Resources ('Y'/'N')
   * @param   p_skill_flag              Get Skilled Resources ('Y'/'N')
   * @param   p_calendar_flag           Get only Available Resources. Passed to JTF ('Y'/'N')
   * @param   x_res_tbl                 Qualified Resource suitable for Scheduling
   */
  PROCEDURE get_resources_to_schedule(
    p_api_version            IN              NUMBER
  , p_init_msg_list          IN              VARCHAR2 DEFAULT NULL
  , x_return_status          OUT NOCOPY      VARCHAR2
  , x_msg_count              OUT NOCOPY      NUMBER
  , x_msg_data               OUT NOCOPY      VARCHAR2
  , p_task_id                IN              NUMBER
  , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
  , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
  , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
  , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
  , x_res_tbl                OUT NOCOPY      csf_resource_tbl
  );

  /**
   * Gets the Qualified Resources for a Task by calling JTF Assignment Manager
   * and also making use of the Required Skills of the Task if Required to reduce
   * the Resource List.
   *
   * This is nothing but a very simplified version on top of the existing
   * GET_QUALIFIED_RESOURCES. The output is in a different format
   * though. It returns Territory ID, Resource Source, Resource
   * Name also.
   * <br>
   *
   * @param   p_task_id                 Task Identifier
   * @param   p_incident_id             Service Request ID
   * @param   p_contracts_flag          Get Contracts Preferred Resources ('Y'/'N')
   * @param   p_ib_flag                 Get IB Preferred Resources ('Y'/'N')
   * @param   p_territory_flag          Get Winning Territory Resources ('Y'/'N')
   * @param   p_skill_flag              Get Skilled Resources ('Y'/'N')
   */
  FUNCTION get_resources_to_schedule(
      p_task_id                IN              NUMBER
    , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
    , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
    , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
    , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
    ) RETURN csf_resource_tbl;

  FUNCTION get_resources_to_schedule_pvt(
      p_task_id                IN              NUMBER
    , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
    , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
    , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
    , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
    ) RETURN csf_resource_tbl;

  /**
   * Gets the Shift Definitions of the given Resource between the two given Dates.
   *
   * CSF has its own "Get Resource Shifts" API in addition to JTF providing it is
   * because CSF is still calling JTF Calendar API rather than JTF Calendar 24 API.
   * Going forward, we should be calling JTF_CALENDAR24_PUB rather than
   * JTF_CALENDAR_PUB.
   * Because of this the following Shift Definition is returned as two Shifts.
   * <br>
   * Shift Construct #101: Start = 1-JAN-2005 18:00:00 to 2-JAN-2005 07:00:00
   *    is returned as
   *       Shift Record #1
   *           Shift Construct = 101
   *           Shift Date      = 1-JAN-2005
   *           Start Time      = 18:00
   *           End Time        = 23:59
   *
   *       Shift Record #2
   *           Shift Construct = 101
   *           Shift Date      = 2-JAN-2005
   *           Start Time      = 00:00
   *           End Time        = 07:00
   * <br>
   * Note that Shift Record#1 and Shift Record#2 are adjacent in the returned
   * Shifts Table. Morever both has the same Shift Construct ID and the difference
   * between End Time of the first record and the start time of the second is
   * One Minute (1/1440 days).
   *
   * This feature is being used by this API to merge those shifts in a single
   * record structure.
   *
   * Note this API requires JTF_CALENDAR_PUB to be of version 115.86 as the issue
   * with respect to Sorting of Shifts has been fixed in that version.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_resource_id           Resource Identifier for whom Shifts are required.
   * @param   p_resource_type         Resource Type of the above Resource.
   * @param   p_start_date            Start of the Window between which Shifts are required.
   * @param   p_end_date              End of the Window between which Shifts are required.
   * @param   x_shifts                Shift Definitions
   */
  PROCEDURE get_resource_shifts(
    p_api_version           IN              NUMBER
  , p_init_msg_list         IN              VARCHAR2 DEFAULT NULL
  , x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , p_resource_id           IN              NUMBER
  , p_resource_type         IN              VARCHAR2
  , p_start_date            IN              DATE
  , p_end_date              IN              DATE
  , p_shift_type            IN              VARCHAR2 DEFAULT NULL
  , x_shifts                OUT NOCOPY      shift_tbl_type
  );

  PROCEDURE get_location(
      x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , x_msg_data                  OUT NOCOPY VARCHAR2
    , p_resource_id                IN        NUMBER
    , p_resource_type              IN        VARCHAR2
    , p_date                       IN        DATE      DEFAULT SYSDATE
    , x_creation_date             OUT NOCOPY DATE
    , x_feed_time                 OUT NOCOPY DATE
    , x_status_code               OUT NOCOPY VARCHAR2
    , x_latitude                  OUT NOCOPY NUMBER
    , x_longitude                 OUT NOCOPY NUMBER
    , x_speed                     OUT NOCOPY NUMBER
    , x_direction                 OUT NOCOPY VARCHAR2
    , x_parked_time               OUT NOCOPY NUMBER
    , x_address                   OUT NOCOPY VARCHAR2
    , x_device_tag                OUT NOCOPY VARCHAR2
    , x_status_code_meaning       OUT NOCOPY VARCHAR2
    );

  PROCEDURE get_location(
      x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , x_msg_data                  OUT NOCOPY VARCHAR2
    , p_resource_id                IN        NUMBER
    , p_resource_type              IN        VARCHAR2
    , p_date                       IN        DATE      DEFAULT SYSDATE
    , x_latitude                  OUT NOCOPY NUMBER
    , x_longitude                 OUT NOCOPY NUMBER
    , x_address                   OUT NOCOPY VARCHAR2
    , x_status_meaning            OUT NOCOPY VARCHAR2
    , x_device_tag                OUT NOCOPY VARCHAR2
    );

  FUNCTION get_location (
      p_resource_id                IN        NUMBER
    , p_resource_type              IN        VARCHAR2
    , p_date                       IN        DATE      DEFAULT SYSDATE
    )
    RETURN MDSYS.SDO_POINT_TYPE;

  FUNCTION get_location_attributes(
      p_resource_id                IN        NUMBER
    , p_resource_type              IN        VARCHAR2
    , p_date                       IN        DATE      DEFAULT SYSDATE
    )
    RETURN VARCHAR2;

  /**
  * Returns the Distance between two locations on the globe in KMs.
  *
  * @param   p_lon1           Longitude of a from-Location.
  * @param   p_lat1           Latitude of a from-Location.
  * @param   p_lon2           Longitude of a to-Location.
  * @param   p_lat2           Latitude of a to-Location.
  */
  FUNCTION geo_distance(p_lon1 NUMBER, p_lat1 NUMBER, p_lon2 NUMBER, p_lat2 NUMBER)
    RETURN NUMBER;

  FUNCTION get_third_party_role(
    p_resource_id        IN              NUMBER
  , p_resource_type      IN              VARCHAR2
  ) RETURN VARCHAR2;

END csf_resource_pub;


/
