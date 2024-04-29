--------------------------------------------------------
--  DDL for Package GMP_RESOURCE_DTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_RESOURCE_DTL_PUB" AUTHID CURRENT_USER AS
/* $Header: GMPRSDTS.pls 120.7.12010000.2 2010/02/24 13:28:59 vpedarla ship $ */
/*#
 * This is the public interface for OPM Plant Resources API
 * These API can be used  for creation, updation or deletion of Plant
 * Resources in OPM
 * @rep:scope public
 * @rep:product GMP
 * @rep:displayname GMP_RESOURCE_DTL_PUB
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMP_PLANT_RESOURCE
*/

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMP_RESOURCE_DTL_PUB';
  v_update_flag  varchar2(1) := 'N';

  /* Define record and table type */
  TYPE update_table_rec_type IS RECORD
  (
   p_col_to_update	VARCHAR2(30)
  ,p_value		VARCHAR2(30)
  );

  TYPE update_tbl_type IS TABLE OF update_table_rec_type
       INDEX BY BINARY_INTEGER;

  TYPE resource_instances_rec IS RECORD
  (
     RESOURCE_ID                     NUMBER,
     INSTANCE_ID                     NUMBER,
     INSTANCE_NUMBER                 NUMBER,
     VENDOR_ID                       NUMBER,
     MODEL_NUMBER                    VARCHAR2(30),
     SERIAL_NUMBER                   VARCHAR2(30),
     TRACKING_NUMBER                 VARCHAR2(30),
     EFF_START_DATE                  DATE,
     EFF_END_DATE                    DATE,
     LAST_MAINTENANCE_DATE           DATE,
     MAINTENANCE_INTERVAL            NUMBER,
     INACTIVE_IND                    NUMBER,
     CALIBRATION_FREQUENCY           NUMBER,
     CALIBRATION_PERIOD              VARCHAR2(4),
     CALIBRATION_ITEM_ID             NUMBER,
     LAST_CALIBRATION_DATE           DATE,
     NEXT_CALIBRATION_DATE           DATE,
     LAST_CERTIFICATION_DATE         DATE,
     CERTIFIED_BY                    VARCHAR2(32),
     CREATION_DATE                   DATE,
     CREATED_BY                      NUMBER,
     LAST_UPDATE_DATE                DATE,
     LAST_UPDATED_BY                 NUMBER,
     LAST_UPDATE_LOGIN               NUMBER
  ) ;

  TYPE resource_instances_tbl IS TABLE OF resource_instances_rec
       INDEX BY BINARY_INTEGER;

/*#
 *  API for INSERT_RESOURCE_DTL
 *  This API to craete a new plant resource i.e. to insert a row in the plant
 *  resource table - cr_rsrc_dtl
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list BOOLEAN
 *  @param p_commit   This is the commmit flag BOOLEAN.
 *  @param p_resources This is the information about the resource to be created
 *  in the prescribed format - row type of cr_rsrc_dtl table.
 *  @param p_rsrc_instances This is the information about the instances of the
 *  resource being created
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname INSERT_RESOURCE_DTL
*/
 PROCEDURE insert_resource_dtl
  ( p_api_version            IN   NUMBER                :=  1
  , p_init_msg_list          IN   BOOLEAN               :=  TRUE
  , p_commit                 IN   BOOLEAN               :=  FALSE
  , p_resources              IN   cr_rsrc_dtl%ROWTYPE
  , p_rsrc_instances         IN   resource_instances_tbl
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          IN OUT  NOCOPY VARCHAR2
  ) ;

/*#
 *  API for CHECK_DATA
 *  This API to validate the resource data before updating or creating a plant
 *  resource.
 *  @param p_organization_id This is the  Inventory Organization to which the Resource is Associated
 *  @param p_resources This is the Resource that need to be inserted into the
 *  table.
 *  @param p_resource_id This is the resource id of the resource that will be passed
 *  @param p_group_resource Resource Group - Resource can be grouped by this
 *  type
 *  @param p_assigned_qty    How many of the resources are in the plant
 *  @param p_daily_avl_use   Number of hours the resource is available in the
 *  plant each day
 *  @param p_usage_um       Unit of measure for measuring resource usage
 *  @param p_nominal_cost    Cost of the Resource in the Plant
 *  @param p_inactive_ind    Inactive indicator. 0=Active, 1=Inactive
 *  @param p_ideal_capacity    Ideal Capacity of the Resource
 *  @param p_min_capacity    Minimum Capacity of the Resource
 *  @param p_max_capacity    Maximum Capacity of the Resource
 *  @param p_capacity_uom    Resource Capacity Uom
 *  @param p_capacity_constraint  Resource Capacity Constraint
 *  @param p_capacity_tolerance  Capacity Tolerance
 *  @param p_schedule_ind  Schedule Indicator This Column is used to define
 *  whether a resource is should be Scheduled or Not, the Values are 1=
 *  Scheduling , 2= Schedule to Instance, 0= Do Not Schedule
 *  @param p_utilization    Indicates the resource Utilization
 *  @param p_efficiency     Indicates the resource Efficiency
 *  @param p_calendar_code  Indicates the calendar code
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname CHECK_DATA
*/
 PROCEDURE  check_data
  (
    p_organization_id      IN   NUMBER, /* B4724360 - INVCONV */
    p_resources            IN   VARCHAR2,
    p_resource_id          IN   NUMBER, /* B4724360 - INVCONV */
    p_group_resource       IN   VARCHAR2,
    p_assigned_qty         IN   integer,
    p_daily_avl_use        IN   NUMBER,
    p_usage_um             IN   VARCHAR2,
    p_nominal_cost         IN   NUMBER,
    p_inactive_ind         IN   NUMBER,
    p_ideal_capacity       IN   NUMBER,
    p_min_capacity         IN   NUMBER,
    p_max_capacity         IN   NUMBER,
    p_capacity_uom         IN   VARCHAR2,
    p_capacity_constraint  IN   NUMBER,
    p_capacity_tolerance   IN   NUMBER,
    p_schedule_ind         IN   NUMBER,
    p_utilization          IN   NUMBER,
    p_efficiency           IN   NUMBER,
    p_calendar_code        IN   VARCHAR2, /* B4724360 - INVCONV */
    p_batchable_flag       IN   NUMBER,
    p_batch_window         IN   NUMBER,
    x_message_count        OUT  NOCOPY NUMBER,
    x_message_list         OUT  NOCOPY VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2
 );

/*#
 *  API for INSERT_DETAIL_ROWS
 *  This API inserts a row in Plant Resource table (cr_rsrc_dtl)
 *  @param p_organization_id This is the Inventory Organization to which the Resource is Associated
 *  @param p_resources This is the Resource that needs to be inserted into the
 *  table.
 *  @param p_group_resource Resource Group - Resource can be grouped by this
 *  type
 *  @param p_assigned_qty    How many of the resources are in the plant
 *  @param p_daily_avail_use   Number of hours the resource is available in the
 *  plant each day
 *  @param p_usage_um       Unit of measure for measuring resource usage
 *  @param p_nominal_cost    Cost of the Resource in the Plant
 *  @param p_inactive_ind    Inactive indicator. 0=Active, 1=Inactive
 *  @param p_creation_date   Row Who columns
 *  @param p_created_by      Row Who columns
 *  @param p_last_update_date      Row Who columns
 *  @param p_last_updated_by       Row Who columns
 *  @param p_last_update_login       Row Who columns
 *  @param p_trans_cnt       Not currently used
 *  @param p_delete_mark     Standard: 0=Active record (default); 1=Marked for
 *  (logical) deletion
 *  @param p_text_code   ID which joins any rows of text in this table to the
 *  Text Table for this Module
 *  @param p_ideal_capacity    Ideal Capacity of the Resource
 *  @param p_min_capacity    Minimum Capacity of the Resource
 *  @param p_max_capacity    Maximum Capacity of the Resource
 *  @param p_capacity_uom    Resource Capacity Uom
 *  @param p_resource_id   Unique Identifier of the Resource Surrogate Key
 *  @param p_capacity_constraint  Resource Capacity Constraint
 *  @param p_capacity_tolerance  Capacity Tolerance
 *  @param p_schedule_ind  Schedule Indicator This Column is used to define
 *  whether a resource is should be Scheduled or Not, the Values are 1=
 *  Scheduling , 2= Schedule to Instance, 0= Do Not Schedule
 *  @param p_utilization    Indicates the resource Utilization
 *  @param p_efficiency     Indicates the resource Efficiency
 *  @param p_calendar_code  Indicates the calendar code
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname INSERT_DETAIL_ROWS
*/
--Bug#6413873 Need to pass planning_exception_set
PROCEDURE  insert_detail_rows
  (
     p_organization_id        IN  NUMBER, /* B4724360 - INVCONV */
     p_resources              IN  varchar2,
     p_group_resource         IN  VARCHAR2,
     p_assigned_qty           IN  NUMBER,
     p_daily_avail_use        IN  NUMBER,
     p_usage_um               IN  VARCHAR2,
     p_nominal_cost           IN  NUMBER,
     p_inactive_ind           IN  NUMBER,
     p_creation_date          IN  DATE,
     p_created_by             IN  NUMBER,
     p_last_update_date       IN  DATE,
     p_last_updated_by        IN  NUMBER,
     p_last_update_login      IN  NUMBER,
     p_trans_cnt              IN  NUMBER,
     p_delete_mark            IN  NUMBER,
     p_text_code              IN  NUMBER,
     p_ideal_capacity         IN  NUMBER,
     p_min_capacity           IN  NUMBER,
     p_max_capacity           IN  NUMBER,
     p_capacity_uom           IN  VARCHAR2,
     p_resource_id            IN  NUMBER,
     p_capacity_constraint    IN  NUMBER,
     p_capacity_tolerance     IN  NUMBER,
     p_schedule_ind           IN  NUMBER,
     p_utilization            IN  NUMBER,
     p_efficiency             IN  NUMBER,
     p_planning_exception_set IN  VARCHAR2,    /*Bug#6413873 KBANDDYO*/
     p_calendar_code          IN  VARCHAR2, /* B4724360 - INVCONV */
     p_sds_window             IN  NUMBER ,  /* B7637373 - VPEDARLA */
     p_batchable_flag         IN  NUMBER,
     p_batch_window           IN  NUMBER
  );

/*#
 *  API for UPDATE_RESOURCE_DTL
 *  This API updates a Plant Resource ie. a row in table cr_rsrc_dtl.
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list BOOLEAN
 *  @param p_commit   This is the commmit flag BOOLEAN.
 *  @param p_resources This is the resource information that needs to be updated
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname UPDATE_RESOURCE_DTL
*/

PROCEDURE update_resource_dtl
  ( p_api_version            IN   NUMBER               :=  1
  , p_init_msg_list          IN   BOOLEAN              :=  TRUE
  , p_commit                 IN   BOOLEAN              :=  FALSE
  , p_resources              IN   cr_rsrc_dtl%ROWTYPE
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          OUT  NOCOPY VARCHAR2
  ) ;

/*#
 *  API for UPDATE_DETAIL_ROWS
 *  This API updates a row in  Plant Resource table (cr_rsrc_dtl)
 *  @param p_organization_id This is the Inventory Organization to which the Resource is Associated
 *  @param p_resources This is the Resource that is to be updated .
 *  @param p_group_resource Resource Group - Resource can be grouped by this
 *  type
 *  @param p_assigned_qty    How many of the resources are in the plant
 *  @param p_daily_avail_use   Number of hours the resource is available in the
 *  plant each day
 *  @param p_usage_um       Unit of measure in which daily_avail_use is
 *  expressed
 *  @param p_nominal_cost    Cost of the Resource in the Plant
 *  @param p_inactive_ind    Inactive indicator. 0=Active, 1=Inactive
 *  @param p_creation_date   Row Who columns
 *  @param p_created_by      Row Who columns
 *  @param p_last_update_date      Row Who columns
 *  @param p_last_updated_by       Row Who columns
 *  @param p_last_update_login       Row Who columns
 *  @param p_trans_cnt       Not currently used
 *  @param p_delete_mark     Standard: 0=Active record (default); 1=Marked for
 *  (logical) deletion
 *  @param p_text_code   ID which joins any rows of text in this table to the
 *  Text Table for this Module
 *  @param p_ideal_capacity    Ideal Capacity of the Resource
 *  @param p_min_capacity    Minimum Capacity of the Resource
 *  @param p_max_capacity    Maximum Capacity of the Resource
 *  @param p_capacity_uom    Resource Capacity Uom
 *  @param p_resource_id   Unique Identifier of the Resource Surrogate Key
 *  @param p_capacity_constraint  Resource Capacity Constraint
 *  @param p_capacity_tolerance  Capacity Tolerance
 *  @param p_schedule_ind  Schedule Indicator This Column is used to define
 *  whether a resource is should be Scheduled or Not, the Values are 1=
 *  Scheduling , 2= Schedule to Instance, 0= Do Not Schedule
 *  @param p_utilization    Indicates the resource Utilization
 *  @param p_efficiency     Indicates the resource Efficiency
 *  @param p_calendar_code  Indicates the calendar code
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname UPDATE_DETAIL_ROWS
*/
--Bug#6413873 Need to pass planning_exception_set
PROCEDURE  update_detail_rows
  (
     p_organization_id        IN  NUMBER, /* B4724360 - INVCONV */
     p_resources              IN  VARCHAR2,
     p_group_resource         IN  VARCHAR2,
     p_assigned_qty           IN  NUMBER,
     p_daily_avail_use        IN  NUMBER,
     p_usage_um               IN  VARCHAR2,
     p_nominal_cost           IN  NUMBER,
     p_inactive_ind           IN  NUMBER,
     p_creation_date          IN  DATE,
     p_created_by             IN  NUMBER,
     p_last_update_date       IN  DATE,
     p_last_updated_by        IN  NUMBER,
     p_last_update_login      IN  NUMBER,
     p_trans_cnt              IN  NUMBER,
     p_delete_mark            IN  NUMBER,
     p_text_code              IN  NUMBER,
     p_ideal_capacity         IN  NUMBER,
     p_min_capacity           IN  NUMBER,
     p_max_capacity           IN  NUMBER,
     p_capacity_uom           IN  VARCHAR2,
     p_resource_id            IN  NUMBER,
     p_capacity_constraint    IN  NUMBER,
     p_capacity_tolerance     IN  NUMBER,
     p_schedule_ind           IN  NUMBER,
     p_utilization            IN  NUMBER,
     p_efficiency             IN  NUMBER,
     p_sds_window             IN  NUMBER,   /* B7637373 - VPEDARLA */
     p_planning_exception_set IN  VARCHAR2,    /*Bug#6413873 KBANDDYO*/
     p_calendar_code          IN  VARCHAR2, /* B4724360 - INVCONV */
     p_batchable_flag         IN  NUMBER,
     p_batch_window           IN  NUMBER ,
     x_return_status          OUT NOCOPY VARCHAR2
  ) ;

/*#
 *  API for DELETE_RESOURCES
 *  This API Deletes a row in  Plant Resource table (cr_rsrc_dtl)
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list BOOLEAN
 *  @param p_commit   This is the commmit flag BOOLEAN.
 *  @param p_organization_id This is the Inventory Organization to which the Resource is Associated
 *  @param p_resources This is the resource information that needs to be Deleted
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname DELETE_RESOURCES
*/
PROCEDURE delete_resources
  ( p_api_version 	IN NUMBER 	:= 1
  , p_init_msg_list 	IN BOOLEAN 	:= TRUE
  , p_commit		IN BOOLEAN 	:= FALSE
  , p_organization_id 	IN cr_rsrc_dtl.organization_id%TYPE
  , p_resources 	IN cr_rsrc_dtl.resources%TYPE
  , x_message_count 	OUT NOCOPY NUMBER
  , x_message_list 	OUT NOCOPY VARCHAR2
  , x_return_status	OUT NOCOPY VARCHAR2
  );

/*#
 *  API for CHECK_INSTANCE_DATA
 *  This API checks the Instance data before Insertion
 *  @param p_resource_id   Unique Identifier of the Resource Surrogate Key
 *  @param p_instance_id   Surrogate Key to uniquely identify the Instance
 *  @param p_vendor_id     Surrogate Key to uniquely identify the Vendor
 *  @param p_eff_start_date  The Start Date for the Resource when it becomes
 *  Active
 *  @param p_eff_end_date  The End Date for the Resource till it is Active
 *  @param p_maintenance_interval  The number of Days from the last time
 *  maintenance was done where maintenance should occur again
 *  @param p_inactive_ind    Inactive indicator. 0=Active, 1=Inactive
 *  @param p_calibration_frequency  Resource Calibration Frequency
 *  @param p_calibration_item_id  The Item with which the Calibration is done
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname CHECK_INSTANCE_DATA
*/
PROCEDURE  check_instance_data
  (
     p_resource_id             IN NUMBER
    ,p_instance_id             IN NUMBER
    ,p_vendor_id               IN NUMBER
    ,p_eff_start_date          IN DATE
    ,p_eff_end_date            IN DATE
    ,p_maintenance_interval    IN NUMBER
    ,p_inactive_ind            IN NUMBER
    ,p_calibration_frequency   IN NUMBER
    ,p_calibration_item_id     IN NUMBER
    ,x_message_count           OUT  NOCOPY NUMBER
    ,x_message_list            OUT  NOCOPY VARCHAR2
    ,x_return_status           OUT  NOCOPY VARCHAR2
    ) ;

/*#
 *  API for INSERT_RESOURCE_INSTANCE
 *  This API inserts a row in Plant Resource Instance table
 *  (gmp_resource_instances)
 *  @param p_resource_id   Unique Identifier of the Resource Surrogate Key
 *  @param p_instance_id   Surrogate Key to uniquely identify the Instance
 *  @param p_instance_number   The number identifying the resource uniquely
 *  @param p_vendor_id     Surrogate Key to uniquely identify the Vendor
 *  @param p_model_number the Model number from the manufacturer for the
 *  resource
 *  @param p_serial_number the Combination of numbers, Letters and Symbols the
 *  manufacturer uses to identify the resource
 *  @param p_tracking_number the unique combination of numbers, Letters and
 *  symbols to identify the resource for internal tracking
 *  @param p_eff_start_date  The Start Date for the Resource when it becomes
 *  Active
 *  @param p_eff_end_date  The End Date for the Resource till it is Active
 *  @param p_last_maintenance_date  The Date maintenance last occurred for the
 *  resource
 *  @param p_maintenance_interval The number of Days from the last time
 *  maintenance was done where maintenance should occur again
 *  @param p_inactive_ind    Inactive indicator. 0=Active, 1=Inactive
 *  @param p_calibration_frequency  Resource Calibration Frequency
 *  @param p_calibration_period  Resource Calibration Period
 *  @param p_calibration_item_id  The Item with which the Calibration is done
 *  @param p_last_calibration_date Standard date validation
 *  @param p_next_calibration_date Standard date validation
 *  @param p_last_certification_date  Standard date validation
 *  @param p_certified_by Person Who has done the Calibration Certification
 *  @param p_creation_date   Row Who columns
 *  @param p_created_by      Row Who columns
 *  @param p_last_update_date      Row Who columns
 *  @param p_last_updated_by       Row Who columns
 *  @param p_last_update_login       Row Who columns
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname INSERT_RESOURCE_INSTANCE
*/
PROCEDURE  insert_resource_instance (
     p_resource_id                     IN NUMBER
    ,p_instance_id                     IN NUMBER
    ,p_instance_number                 IN NUMBER
    ,p_vendor_id                       IN NUMBER
    ,p_model_number                    IN VARCHAR2
    ,p_serial_number                   IN VARCHAR2
    ,p_tracking_number                 IN VARCHAR2
    ,p_eff_start_date                  IN DATE
    ,p_eff_end_date                    IN DATE
    ,p_last_maintenance_date           IN DATE
    ,p_maintenance_interval            IN NUMBER
    ,p_inactive_ind                    IN NUMBER
    ,p_calibration_frequency           IN NUMBER
    ,p_calibration_period              IN VARCHAR2
    ,p_calibration_item_id             IN NUMBER
    ,p_last_calibration_date           IN DATE
    ,p_next_calibration_date           IN DATE
    ,p_last_certification_date         IN DATE
    ,p_certified_by                    IN VARCHAR2
    ,p_creation_date                   IN DATE
    ,p_created_by                      IN NUMBER
    ,p_last_update_date                IN DATE
    ,p_last_updated_by                 IN NUMBER
    ,p_last_update_login               IN NUMBER );

/*#
 *  API for UPDATE_INSTANCES
 *  This API updates a Resource Instance Table ie. a row in table
 *  gmp_resource_instances.
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list BOOLEAN
 *  @param p_commit   This is the commmit flag BOOLEAN.
 *  @param p_instances This is the Instances of the Resource that need to be
 *  updated
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname UPDATE_INSTANCES
*/
PROCEDURE update_instances
  ( p_api_version            IN   NUMBER         :=  1
  , p_init_msg_list          IN   BOOLEAN        :=  TRUE
  , p_commit                 IN   BOOLEAN        :=  FALSE
  , p_instances              IN   gmp_resource_instances%ROWTYPE
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          OUT  NOCOPY VARCHAR2
  ) ;

/*#
 *  API for UPDATE_INSTANCE_ROW
 *  This API updates a row in Resource Instance Table ie.  gmp_resource_instances.
 *  @param p_resource_id   Unique Identifier of the Resource Surrogate Key
 *  @param p_instance_id   Surrogate Key to uniquely identify the Instance
 *  @param p_instance_number   The number identifying the resource uniquely
 *  @param p_vendor_id     Surrogate Key to uniquely identify the Vendor
 *  @param p_model_number the Model number from the manufacturer for the
 *  resource
 *  @param p_serial_number the Combination of numbers, Letters and Symbols the
 *  manufacturer uses to identify the resource
 *  @param p_tracking_number the unique combination of numbers, Letters and
 *  symbols to identify the resource for internal tracking
 *  @param p_eff_start_date  The Start Date for the Resource when it becomes
 *  Active
 *  @param p_eff_end_date    The End Date for the Resource till it is Active
 *  @param p_last_maintenance_date  The Date maintenance last occurred for the
 *  resource
 *  @param p_maintenance_interval The number of Days from the last time
 *  maintenance was done where maintenance should occur again
 *  @param p_inactive_ind       Inactive indicator. 0=Active, 1=Inactive
 *  @param p_calibration_frequency  Resource Calibration Frequency
 *  @param p_calibration_period    Resource Calibration Period
 *  @param p_calibration_item_id    The Item with which the Calibration is done
 *  @param p_last_calibration_date    Standard date validation
 *  @param p_next_calibration_date    Standard date validation
 *  @param p_last_certification_date    Standard date validation
 *  @param p_certified_by    Person Who has done the Calibration Certification
 *  @param p_creation_date   Row Who columns
 *  @param p_created_by      Row Who columns
 *  @param p_last_update_date      Row Who columns
 *  @param p_last_updated_by       Row Who columns
 *  @param p_last_update_login       Row Who columns
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname UPDATE_INSTANCE_ROW
*/
PROCEDURE  update_instance_row
  (
     p_resource_id                     IN NUMBER
    ,p_instance_id                     IN NUMBER
    ,p_instance_number                 IN NUMBER
    ,p_vendor_id                       IN NUMBER
    ,p_model_number                    IN VARCHAR2
    ,p_serial_number                   IN VARCHAR2
    ,p_tracking_number                 IN VARCHAR2
    ,p_eff_start_date                  IN DATE
    ,p_eff_end_date                    IN DATE
    ,p_last_maintenance_date           IN DATE
    ,p_maintenance_interval            IN NUMBER
    ,p_inactive_ind                    IN NUMBER
    ,p_calibration_frequency           IN NUMBER
    ,p_calibration_period              IN VARCHAR2
    ,p_calibration_item_id             IN NUMBER
    ,p_last_calibration_date           IN DATE
    ,p_next_calibration_date           IN DATE
    ,p_last_certification_date         IN DATE
    ,p_certified_by                    IN VARCHAR2
    ,p_creation_date                   IN DATE
    ,p_created_by                      IN NUMBER
    ,p_last_update_date                IN DATE
    ,p_last_updated_by                 IN NUMBER
    ,p_last_update_login               IN NUMBER
    ,x_return_status                   OUT  NOCOPY VARCHAR2
  ) ;

END GMP_RESOURCE_DTL_PUB;


/
