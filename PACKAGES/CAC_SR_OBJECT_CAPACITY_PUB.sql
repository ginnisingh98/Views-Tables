--------------------------------------------------------
--  DDL for Package CAC_SR_OBJECT_CAPACITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SR_OBJECT_CAPACITY_PUB" AUTHID CURRENT_USER AS
/* $Header: cacsrocps.pls 120.1.12010000.5 2009/06/01 08:41:21 anangupt ship $ */

--Default AVAILABILITY_TYPE
DEFAULT_AVAILABILITY_TYPE CONSTANT VARCHAR2(30) := 'REGULAR';

/*******************************************************************************
** Datatypes used in APIs
*******************************************************************************/
  TYPE OBJECT_CAPACITY_REC_TYPE IS
  RECORD( OBJECT_CAPACITY_ID     NUMBER       -- primary key

        , OBJECT_VERSION_NUMBER  NUMBER       -- The version number of the row
                                              -- after any updates. Initially it
                                              -- is set to 1 and incremented
                                              -- whenever any change in the data
                                              -- happens. This should be used to
                                              -- check if another user updated
                                              -- the same row.

        , OBJECT_TYPE            VARCHAR2(30) -- JTF OBJECTS type of the Object.
                                              -- It should considered same as
                                              -- Resource Type

        , OBJECT_ID              NUMBER       -- JTF OBJECTS select ID of the
                                              -- Object Instance. It should be
                                              -- considered same as Resource Id

        , START_DATE_TIME        DATE         -- Start date and time of the
                                              -- Object Capacity record

        , END_DATE_TIME          DATE         -- End date and time of the
                                              -- Object Capacity record

        , AVAILABLE_HOURS        NUMBER       -- The available hours in this
                                              -- record. Initially, this will
                                              -- be (END_DATE_TIME -
                                              -- START_DATE_TIME). As the tasks
                                              -- are scheduled, it will decrease.

        , AVAILABLE_HOURS_BEFORE NUMBER       -- The hours that can be made
                                              -- available before the first task
                                              -- in this record. It will be NULL
                                              -- if there are no tasks
                                              -- associated with this record.
                                              -- The calculation of this field
                                              -- will be driven by the business
                                              -- rules of individual product.

        , AVAILABLE_HOURS_AFTER  NUMBER       -- The hours that can be made
                                              -- available after the last task
                                              -- in this record. It will be NULL
                                              -- if there are no tasks
                                              -- associated with this record.
                                              -- The calculation of this field
                                              -- will be driven by the business
                                              -- rules of individual product.

        , SCHEDULE_DETAIL_ID     NUMBER       -- The schedule detail row that
                                              -- was used to create this record
                                              -- It is a foreign key to the
                                              -- table CAC_SR_SCHDL_DETAILS.
                                              -- If this record was created
                                              -- using old JTF Shifts model
                                              -- then this field will be set
                                              -- to the value
                                              -- (0 - SHIFT_CONSTRUCT_ID).
                                              -- It will be set to NULL if the
                                              -- record as created manually
                                              -- without any corresponding shift

        , STATUS                 NUMBER       -- It will indicate if the record
                                              -- can be used for scheduling or
                                              -- not. Initially it will be set
                                              -- 1 (Available) and different
                                              -- application can set different
                                              -- values based on their need.

       , AVAILABILITY_TYPE      VARCHAR2(240)  -- This field indicates if the record
																							-- has regular shift or stand by
																							-- shift.Possible values are
																							-- "REGULAR" or "STANDBY"
																							-- Default value for AVAILABILITY_TYPE
																							-- is "REGULAR"

       , SOURCE_TYPE            VARCHAR2(30)  -- This filed indicates from where
                                              -- this trip is created.Possible values
                                              -- are "GEN" for shifts created using
                                              -- concurrent program and "MAN" for
                                              -- shifts created manually
        );

  TYPE OBJECT_CAPACITY_TBL_TYPE IS
  TABLE of OBJECT_CAPACITY_REC_TYPE INDEX BY BINARY_INTEGER;

  TYPE OBJECT_TASKS_REC_TYPE IS
  RECORD( OBJECT_CAPACITY_TBL_IDX     NUMBER    -- The pl/sql table index of the
                                                -- object capacity record where
                                                -- this tasks lies
        , TASK_ASSIGNMENT_ID          NUMBER    -- The primary key of the task
                                                -- assignment table record
        , TASK_ASSIGNMENT_OVN         NUMBER    -- The object version no.of the
                                                -- task assignment table record
        , ASSIGNMENT_STATUS_ID        NUMBER    -- The status id in the task
                                                -- assignment table record
        , FREE_BUSY_TYPE              VARCHAR2(30) -- If this task is making this
                                                    -- resource Free or Busy
        , TASK_ID                     NUMBER    -- The primary key of the task
                                                -- table record
        , TASK_OVN                    NUMBER    -- The object version no. of the
                                                -- task table record
        , TASK_TYPE_ID                NUMBER    -- The task type
        , TASK_STATUS_ID              NUMBER    -- The task status
        , SCHEDULED_START_DATE        DATE      -- The schedule start date of
                                                -- the task table record
        , SCHEDULED_END_DATE          DATE      -- The schedule end date of
                                                -- the task table record
        , PLANNED_START_DATE          DATE      -- The planned start date of
                                                -- the task table record
        , PLANNED_END_DATE            DATE      -- The planned end date of
                                                -- the task table record
        , CUSTOMER_ID                 NUMBER    -- The party id of the customer
        , ADDRESS_ID                  NUMBER    -- Id of the party address
    );

  TYPE OBJECT_TASKS_TBL_TYPE IS
  TABLE of OBJECT_TASKS_REC_TYPE INDEX BY BINARY_INTEGER;

/*******************************************************************************
** Public APIs
*******************************************************************************/

PROCEDURE generate_object_capacity
/*******************************************************************************
**  generate_object_capacity
**
**  This API calls JTF_CALENDAR_PUB_24HR.Get_Resource_Shifts API and builds the
**  pl/sql table with object capacity records. It populates object_capacity_id
**  for each record with the sequence cac_sr_object_capacity_s value if the
**  parameter p_PopulateID is 'T'.
**  It will return a list of tasks also if the p_FetchTasks parameter is set to
**  true. This is needed only if you want to fetch all the tasks at one shot as
**  it will be more performant than fetching tasks for each object capacity
**  record one by one.
**
*******************************************************************************/
( p_api_version      IN  NUMBER               -- API version you coded against
, p_init_msg_list    IN  VARCHAR2 DEFAULT 'F' -- Create a new error stack?
, p_Object_Type      IN  VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID        IN  NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date       IN  DATE                 -- start date and time of period of interest
, p_End_Date         IN  DATE                 -- end date and time of period of interest
, p_Populate_ID      IN  VARCHAR2 DEFAULT 'F' -- Populate the object_capacity_id of the record?
                                              -- Should be set to 'T' if the ids are needed for foreign key reference
                                              -- 'F' means the ids will be genrated while inserting these records in the table
, p_Fetch_Tasks      IN  VARCHAR2 DEFAULT 'F' -- Fetch tasks for the time period too?
, x_Object_Capacity  OUT NOCOPY OBJECT_CAPACITY_TBL_TYPE
                                              --  return table of object capacity records
, x_Object_Tasks     OUT NOCOPY OBJECT_TASKS_TBL_TYPE
                                              --  return table of object task records
, x_return_status    OUT NOCOPY VARCHAR2      -- 'S': API completed without errors
                                              -- 'E': API completed with recoverable errors; explanation on errorstack
                                              -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count        OUT NOCOPY NUMBER        -- Number of messages on the errorstack
, x_msg_data         OUT NOCOPY VARCHAR2      -- contains message if x_msg_count = 1
);

PROCEDURE insert_object_capacity
/*******************************************************************************
**  insert_object_capacity
**
**  This API calls table handler to insert data into cac_sr_object_capacity
**  using pl/sql table passed. It populates object_capacity_id for each record
**  if with the sequence cac_sr_object_capacity_s value if it is NULL in the
**  record.
**  It updates the task assignment with the corresponding object_capacity_id
**  if the p_Update_Tasks parameter is set to 'T'.
**
*******************************************************************************/
( p_api_version      IN  NUMBER               -- API version you coded against
, p_init_msg_list    IN  VARCHAR2 DEFAULT 'F' -- Create a new error stack?
, p_Object_Capacity  IN OUT NOCOPY OBJECT_CAPACITY_TBL_TYPE
                                              -- table of object capacity records which should be inserte
, p_Update_Tasks     IN  VARCHAR2 DEFAULT 'F' -- Update task assignments too?
, p_Object_Tasks     IN  OBJECT_TASKS_TBL_TYPE
                                              -- table of object task records to be updated
, x_return_status    OUT NOCOPY VARCHAR2      -- 'S': API completed without errors
                                              -- 'E': API completed with recoverable errors; explanation on errorstack
                                              -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count        OUT NOCOPY NUMBER        -- Number of messages on the errorstack
, x_msg_data         OUT NOCOPY VARCHAR2      -- contains message if x_msg_count = 1
);

PROCEDURE update_object_capacity
/*******************************************************************************
**  update_object_capacity New Version
**
**  This API calls table handler to update data into cac_sr_object_capacity.
**  Only the available hours fields and status can be updated.
**
*******************************************************************************/
( p_api_version            IN  NUMBER               -- API version you coded against
, p_init_msg_list          IN  VARCHAR2 DEFAULT 'F' -- Create a new error stack?
, p_object_capacity_id     IN  NUMBER               -- Primary Key ID of the row to be updated
, p_object_version_number  IN  NUMBER               -- Object Version of the row to be updated
                                                    -- If this doesn't match the database value then that means someone else has updated the same row
, p_available_hours        IN  NUMBER DEFAULT NULL  -- The new value of available hours
                                                                -- If it is NULL then no change is done to the existing data
, p_available_hours_before IN  NUMBER DEFAULT NULL  -- The new value of available before hours.
                                                                -- If it is NULL then no change is done to the existing data
                                                    -- If it is FND_API.G_MISS_NUM then the value will be set to NULL in the database
, p_available_hours_after  IN  NUMBER DEFAULT NULL  -- The new value of available before hours.
                                                                -- If it is NULL then no change is done to the existing data
                                                                -- If it is FND_API.G_MISS_NUM then the value will be set to NULL in the database
, p_status                 IN  NUMBER DEFAULT NULL  -- The new value of the status
                                                                -- If it is NULL then no change is done to the existing data
, p_availability_type      IN  VARCHAR2 DEFAULT NULL -- The new value of availability_type
																                    --If it is NULL then no change is done to the existing data
, p_start_date_time        IN DATE DEFAULT NULL     -- New value for start date time
                                                    -- if this value is NULL then no change is done to the existing
                                                    -- value
, p_end_date_time          IN DATE DEFAULT NULL     -- New value for end date time
                                                    -- if this value is NULL then no change is done to the existing
                                                    -- value
, p_source_type            IN VARCHAR2 DEFAULT NULL -- new value for source type of trip
                                                    -- If NULL is passed for this value then no change is done
                                                    -- to exsiting value
, x_return_status          OUT NOCOPY VARCHAR2      -- 'S': API completed without errors
                                                    -- 'E': API completed with recoverable errors; explanation on errorstack
                                                    -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count              OUT NOCOPY NUMBER        -- Number of messages on the errorstack
, x_msg_data               OUT NOCOPY VARCHAR2      -- contains message if x_msg_count = 1
);

PROCEDURE delete_object_capacity
/*******************************************************************************
**  delete_object_capacity
**
**  This API calls table handler to delete data from cac_sr_object_capacity.
**  It will also update the task assignments and remove the object capacity id
**  if the p_update_tasks is true
**
*******************************************************************************/
( p_api_version            IN  NUMBER               -- API version you coded against
, p_init_msg_list          IN  VARCHAR2 DEFAULT 'F' -- Create a new error stack?
, p_object_capacity_id     IN  NUMBER               -- Primary Key ID of the row to be updated
, p_object_version_number  IN  NUMBER               -- Object Version of the row to be updated
                                                    -- If this doesn't match the database value then that means someone else has updated the same row
, p_Update_Tasks           IN  VARCHAR2 DEFAULT 'T' -- Update task assignments too?
, x_return_status          OUT NOCOPY VARCHAR2      -- 'S': API completed without errors
                                                    -- 'E': API completed with recoverable errors; explanation on errorstack
                                                    -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count              OUT NOCOPY NUMBER        -- Number of messages on the errorstack
, x_msg_data               OUT NOCOPY VARCHAR2      -- contains message if x_msg_count = 1
);

PROCEDURE build_object_capacity
/*******************************************************************************
**  build_object_capacity
**
**  This API calls generate_object_capacity to get the object capacity records.
**  It then checks if there are overlapping data in the database for the same
**  period and then calls insert_object_capacity to insert data.
**
*******************************************************************************/
( p_api_version      IN  NUMBER               -- API version you coded against
, p_init_msg_list    IN  VARCHAR2 DEFAULT 'F' -- Create a new error stack?
, p_Object_Type      IN  VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID        IN  NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date_Time  IN  DATE                 -- start date and time of period of interest
, p_End_Date_Time    IN  DATE                 -- end date and time of period of interest
, p_Build_Mode       IN  VARCHAR2             -- operation mode of the build
                                              -- 'ADD' - New object capacity records are generated and inserted
                                              -- 'REPLACE' - Existing object capacity records are deleted and new ones are inserted
                                              -- 'DELETE' - Existing object capacity records are deleted
, p_Update_Tasks     IN  VARCHAR2 DEFAULT 'F' -- Should the existing task assignments be updated with the object capacity ids?
, x_return_status    OUT NOCOPY VARCHAR2      -- 'S': API completed without errors
                                              -- 'E': API completed with recoverable errors; explanation on errorstack
                                              -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count        OUT NOCOPY NUMBER        -- Number of messages on the errorstack
, x_msg_data         OUT NOCOPY VARCHAR2      -- contains message if x_msg_count = 1
);

END CAC_SR_OBJECT_CAPACITY_PUB;

/
