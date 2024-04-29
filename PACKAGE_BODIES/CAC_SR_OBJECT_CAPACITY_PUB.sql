--------------------------------------------------------
--  DDL for Package Body CAC_SR_OBJECT_CAPACITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SR_OBJECT_CAPACITY_PUB" AS
/* $Header: cacsrocpb.pls 120.1.12010000.4 2009/06/01 08:45:42 anangupt ship $ */

  -- package identification
  g_pkg_name constant varchar2(30) := 'CAC_SR_OBJECT_CAPACITY_PUB';
  g_default_capacity_status constant number := 1;

/*******************************************************************************
** Private APIs
*******************************************************************************/

FUNCTION get_new_object_capacity_id
/*******************************************************************************
**  get_new_object_capacity_id
**
**  This API returns the next value of the sequence cac_sr_object_capacity_s
**
*******************************************************************************/
RETURN NUMBER IS

  CURSOR get_object_capacity_id IS
  SELECT cac_sr_object_capacity_s.nextval
  FROM dual;

  l_return   NUMBER;

BEGIN

  OPEN get_object_capacity_id;
  FETCH get_object_capacity_id
    INTO l_return;
  CLOSE get_object_capacity_id;

  RETURN l_return;

END get_new_object_capacity_id;

FUNCTION validate_object_capacity
/*******************************************************************************
**  validate_object_capacity
**
**  This API checks if all the attributes of the object capacity record have
**  been entered correctly. If any validation fails then it adds a message
**  in the error stack and return false.
**
*******************************************************************************/
(
  p_object_capacity_rec  IN OBJECT_CAPACITY_REC_TYPE
) RETURN BOOLEAN IS

BEGIN
  IF ((p_object_capacity_rec.OBJECT_TYPE IS NULL) OR
       (p_object_capacity_rec.OBJECT_ID IS NULL) OR
     (p_object_capacity_rec.START_DATE_TIME IS NULL) OR
     (p_object_capacity_rec.END_DATE_TIME IS NULL) OR
     (p_object_capacity_rec.AVAILABLE_HOURS IS NULL))
  THEN
    fnd_message.set_name('JTF', 'JTF_CAL_REQUIRED_PARAMETERS');
    fnd_message.set_token('P_PARAMETER','OBJECT_TYPE, OBJECT_ID, START_DATE_TIME, END_DATE_TIME, and AVAILABLE_HOURS');
    fnd_msg_pub.add;
    RETURN FALSE;
  END IF;

  RETURN TRUE;

END validate_object_capacity;

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
) IS

      CURSOR c_tasks
      ( b_resource_type varchar2
      , b_resource_id   number
      , b_date_min      date
      , b_date_max      date
      )
      is
      select   jta.task_assignment_id
      ,        jta.object_version_number asn_ovn
      ,        jta.assignment_status_id
      ,        jta.free_busy_type
      ,        jtb.task_id
      ,        jtb.object_version_number task_ovn
      ,        jtb.task_status_id
      ,        jtb.task_type_id
      ,        jtb.scheduled_start_date
      ,        jtb.scheduled_end_date
      ,        jtb.planned_start_date
      ,        jtb.planned_end_date
      ,        jtb.address_id
      ,        jtb.customer_id
      from     jtf_task_statuses_b jtsb
      ,        jtf_task_assignments jta
      ,        jtf_tasks_b jtb
      where    nvl(jtsb.closed_flag, 'N') = 'N'
      and      nvl(jtsb.completed_flag, 'N') = 'N'
      and      nvl(jtsb.cancelled_flag, 'N') = 'N'
      and      jtsb.task_status_id = jta.assignment_status_id
      and      jta.resource_type_code = b_resource_type
      and      jta.resource_id = b_resource_id
      and      jta.task_id = jtb.task_id
      and      nvl(jtb.deleted_flag, 'N') = 'N'
      and      nvl(jtb.open_flag, 'Y') = 'Y'
      and      jtb.scheduled_start_date BETWEEN b_date_min AND b_date_max
      and      jtb.scheduled_end_date BETWEEN b_date_min AND b_date_max
      order by jtb.scheduled_start_date;

    l_api_name    constant varchar2(30) := 'GENERATE_OBJECT_CAPACITY';
    l_api_version constant number       := 1.0;
    l_return_status       varchar2(1);
    l_msg_count           number;
    l_msg_data            varchar2(2000);
    l_shift               JTF_CALENDAR_PUB_24HR.SHIFT_TBL_TYPE;
    l_idx                 number;
    l_tbl_count           number;
    l_Populate_ID         boolean;
    l_Fetch_Tasks         boolean;

BEGIN

    -- check version compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    -- initialize message stack if required
    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;
    -- initialize return status
    x_return_status := fnd_api.g_ret_sts_success;

    -- call current shift api to get resource shifts
    JTF_CALENDAR_PUB_24HR.GET_RESOURCE_SHIFTS
      ( p_api_version   => 1.0
      , p_resource_id   => p_object_id
      , p_resource_type => p_object_type
      , p_start_date    => p_start_date
      , p_end_date      => p_end_date
      , x_return_status => l_return_status
      , x_msg_count     => l_msg_count
      , x_msg_data      => l_msg_data
      , x_shift         => l_shift
      );
    IF l_return_status <> fnd_api.g_ret_sts_success
    THEN
      IF l_return_status = fnd_api.g_ret_sts_error
      THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_tbl_count := 0;
    l_Populate_ID := fnd_api.to_boolean(p_Populate_ID);
    l_idx := l_shift.FIRST;

    WHILE (l_idx IS NOT NULL)
    LOOP
      l_tbl_count := l_tbl_count + 1;
      IF l_Populate_ID
      THEN
           x_object_capacity(l_tbl_count).OBJECT_CAPACITY_ID := get_new_object_capacity_id;
      ELSE
         x_object_capacity(l_tbl_count).OBJECT_CAPACITY_ID := NULL;
      END IF;
      x_object_capacity(l_tbl_count).OBJECT_TYPE := p_object_type;
      x_object_capacity(l_tbl_count).OBJECT_ID := p_object_id;
      x_object_capacity(l_tbl_count).START_DATE_TIME := l_shift(l_idx).START_TIME;
      x_object_capacity(l_tbl_count).END_DATE_TIME := l_shift(l_idx).END_TIME;
      x_object_capacity(l_tbl_count).AVAILABLE_HOURS := (l_shift(l_idx).END_TIME -
                                                     l_shift(l_idx).START_TIME) * 24.0;
      x_object_capacity(l_tbl_count).AVAILABLE_HOURS_BEFORE := NULL;
      x_object_capacity(l_tbl_count).AVAILABLE_HOURS_AFTER := NULL;
      x_object_capacity(l_tbl_count).SCHEDULE_DETAIL_ID := 0 - l_shift(l_idx).shift_construct_id;
      x_object_capacity(l_tbl_count).STATUS := g_default_capacity_status;
      x_object_capacity(l_tbl_count).AVAILABILITY_TYPE := l_shift(l_idx).AVAILABILITY_TYPE;

      l_idx := l_shift.NEXT(l_idx);
    END LOOP;

    -- Fetch tasks now
    l_tbl_count := 0;
    l_idx := x_object_capacity.FIRST;
    IF fnd_api.to_boolean(p_Fetch_Tasks)
    THEN
      -- to take care of any boundry condition fetch tasks with -+ 1 days of the start and end
      FOR ref_tasks IN c_tasks(p_object_type,p_object_id,p_start_date-1,p_end_date+1)
      LOOP
        -- First step is to find if this task lies in any object capacity record
        -- Note that the l_idx is not reset in the for loop. The reason being
        -- since both the capacity table and ref_tasks are sorted the new task
        -- fetched will always be either in the current capacity record or in
        -- the ones which are after that
        WHILE l_idx IS NOT NULL
        LOOP
          -- Either the task which ends in this capacity record or which starts
          -- here are considered to be the ones connected to this shift.
          IF ((ref_tasks.scheduled_start_date BETWEEN x_object_capacity(l_idx).START_DATE_TIME
               AND x_object_capacity(l_idx).END_DATE_TIME) OR (ref_tasks.scheduled_end_date
             BETWEEN x_object_capacity(l_idx).START_DATE_TIME AND x_object_capacity(l_idx).END_DATE_TIME))
          THEN
            -- This is the right one
            l_tbl_count := l_tbl_count + 1;
            -- Create a new entry in the object tasks table
            x_Object_Tasks(l_tbl_count).OBJECT_CAPACITY_TBL_IDX := l_idx;
            x_Object_Tasks(l_tbl_count).TASK_ASSIGNMENT_ID := ref_tasks.task_assignment_id;
            x_Object_Tasks(l_tbl_count).TASK_ASSIGNMENT_OVN := ref_tasks.asn_ovn;
            x_Object_Tasks(l_tbl_count).ASSIGNMENT_STATUS_ID := ref_tasks.assignment_status_id;
            x_Object_Tasks(l_tbl_count).FREE_BUSY_TYPE := ref_tasks.FREE_BUSY_TYPE;
            x_Object_Tasks(l_tbl_count).TASK_ID := ref_tasks.task_id;
            x_Object_Tasks(l_tbl_count).TASK_OVN := ref_tasks.task_ovn;
            x_Object_Tasks(l_tbl_count).TASK_TYPE_ID := ref_tasks.task_type_id;
            x_Object_Tasks(l_tbl_count).TASK_STATUS_ID := ref_tasks.task_status_id;
            x_Object_Tasks(l_tbl_count).SCHEDULED_START_DATE := ref_tasks.scheduled_start_date;
            x_Object_Tasks(l_tbl_count).SCHEDULED_END_DATE := ref_tasks.scheduled_end_date;
            x_Object_Tasks(l_tbl_count).PLANNED_START_DATE := ref_tasks.planned_start_date;
            x_Object_Tasks(l_tbl_count).PLANNED_END_DATE := ref_tasks.planned_end_date;
            x_Object_Tasks(l_tbl_count).CUSTOMER_ID := ref_tasks.customer_id;
            x_Object_Tasks(l_tbl_count).ADDRESS_ID := ref_tasks.address_id;
            -- Task record updated, so exit the object capacity loop
            EXIT;
          ELSE
            -- now check if this task is before the current object capacity record
            -- if it is then there is no need to loop through the object capacity
            -- records since the next one would be even after the current one.
            -- which means that the fetched task doesn't qualify in any object
            -- capacity record and so should be ignored.
            IF (ref_tasks.scheduled_end_date < x_object_capacity(l_idx).START_DATE_TIME)
            THEN
              EXIT; -- exit the loop
            END IF;
            -- if the task is after the current object capacity record then continue
            -- with the loop as this task can be in the next one.
          END IF;
          -- go to the next one
          l_idx := x_object_capacity.NEXT(l_idx);
        END LOOP;
        -- if we have already reached the end of object capacity table then there
        -- is no need to continue fetching tasks, so exit
        IF l_idx IS NULL
        THEN
          EXIT; -- exit the tasks loop
        END IF;
      END LOOP;
    END IF;

   fnd_msg_pub.count_and_get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                             );
  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg( g_pkg_name
                               , l_api_name
                               );
      END IF;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

END generate_object_capacity;

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
                                              --  table of object capacity records which should be inserte
, p_Update_Tasks     IN  VARCHAR2 DEFAULT 'F' -- Update task assignments too?
, p_Object_Tasks     IN  OBJECT_TASKS_TBL_TYPE
                                              --  table of object task records to be updated
, x_return_status    OUT NOCOPY VARCHAR2      -- 'S': API completed without errors
                                              -- 'E': API completed with recoverable errors; explanation on errorstack
                                              -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count        OUT NOCOPY NUMBER        -- Number of messages on the errorstack
, x_msg_data         OUT NOCOPY VARCHAR2      -- contains message if x_msg_count = 1
) IS

    l_api_name    constant varchar2(30) := 'INSERT_OBJECT_CAPACITY';
    l_api_version constant number       := 1.0;
    l_idx                 number;
    l_return_status       varchar2(1);
    l_msg_count           number;
    l_msg_data            varchar2(2000);
    l_current_date        date;
    l_user                number;
    l_login               number;
    l_rowid               VARCHAR2(255);
    l_ovn                 number;

BEGIN

    -- check version compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    -- initialize message stack if required
    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;
    -- initialize return status
    x_return_status := fnd_api.g_ret_sts_success;

    l_current_date := SYSDATE;
    l_user := FND_GLOBAL.USER_ID;
    l_login := FND_GLOBAL.LOGIN_ID;

    l_idx := p_Object_Capacity.FIRST;

    WHILE l_idx IS NOT NULL
    LOOP
      -- validate if the record is correct
      IF NOT validate_object_capacity(p_Object_Capacity(l_idx))
      THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- populate the primary key if needed
      IF p_Object_Capacity(l_idx).OBJECT_CAPACITY_ID IS NULL
      THEN
        p_Object_Capacity(l_idx).OBJECT_CAPACITY_ID := get_new_object_capacity_id;
      END IF;
      IF p_Object_Capacity(l_idx).STATUS IS NULL
      THEN
        p_Object_Capacity(l_idx).STATUS := g_default_capacity_status;
      END IF;
      p_Object_Capacity(l_idx).OBJECT_VERSION_NUMBER := 1;

      --veirfy if shift type is populated otherwise default it
      IF( p_Object_Capacity(l_idx).availability_type IS NULL OR
        p_Object_Capacity(l_idx).availability_type = '') THEN
        p_Object_Capacity(l_idx).availability_type:=DEFAULT_AVAILABILITY_TYPE;
      END IF;

      -- call the table handler to insert data
      CAC_SR_OBJECT_CAPACITY_PKG.INSERT_ROW
      (
           X_ROWID                  => l_rowid,
           X_OBJECT_CAPACITY_ID     => p_Object_Capacity(l_idx).OBJECT_CAPACITY_ID,
           X_OBJECT_VERSION_NUMBER  => p_Object_Capacity(l_idx).OBJECT_VERSION_NUMBER,
           X_OBJECT_TYPE            => p_Object_Capacity(l_idx).OBJECT_TYPE,
           X_OBJECT_ID              => p_Object_Capacity(l_idx).OBJECT_ID,
           X_START_DATE_TIME        => p_Object_Capacity(l_idx).START_DATE_TIME,
           X_END_DATE_TIME          => p_Object_Capacity(l_idx).END_DATE_TIME,
           X_AVAILABLE_HOURS        => p_Object_Capacity(l_idx).AVAILABLE_HOURS,
           X_AVAILABLE_HOURS_BEFORE => p_Object_Capacity(l_idx).AVAILABLE_HOURS_BEFORE,
           X_AVAILABLE_HOURS_AFTER  => p_Object_Capacity(l_idx).AVAILABLE_HOURS_AFTER,
           X_SCHEDULE_DETAIL_ID     => p_Object_Capacity(l_idx).SCHEDULE_DETAIL_ID,
           X_STATUS                 => p_Object_Capacity(l_idx).STATUS,
           X_CREATION_DATE          => l_current_date,
           X_CREATED_BY             => l_user,
           X_LAST_UPDATE_DATE       => l_current_date,
           X_LAST_UPDATED_BY        => l_user,
           X_LAST_UPDATE_LOGIN      => l_login,
           X_AVAILABILITY_TYPE      => p_Object_Capacity(l_idx).AVAILABILITY_TYPE,
           X_SOURCE_TYPE            => p_Object_Capacity(l_idx).SOURCE_TYPE
      );
      l_idx := p_Object_Capacity.NEXT(l_idx);
    END LOOP;

    -- check if task assignments need to be updated
    IF fnd_api.to_boolean(p_Update_Tasks)
    THEN
      l_idx := p_Object_Tasks.FIRST;
      WHILE l_idx IS NOT NULL
      LOOP
        -- find out if there is an object capacity id for this task assignment
        IF ((p_Object_Tasks(l_idx).OBJECT_CAPACITY_TBL_IDX IS NOT NULL)
           AND p_Object_Capacity.EXISTS(p_Object_Tasks(l_idx).OBJECT_CAPACITY_TBL_IDX))
        THEN
          -- Call assignments api to update object capacity id
          l_ovn := p_Object_Tasks(l_idx).TASK_ASSIGNMENT_OVN;
          JTF_TASK_ASSIGNMENTS_PUB.UPDATE_TASK_ASSIGNMENT
          (
            p_api_version           => 1.0,
            p_commit                => fnd_api.G_FALSE,
            p_object_version_number => l_ovn,
            p_task_assignment_id    => p_Object_Tasks(l_idx).TASK_ASSIGNMENT_ID,
            p_enable_workflow       => NULL,
            p_abort_workflow        => NULL,
            p_object_capacity_id    => p_Object_Capacity(p_Object_Tasks(l_idx).OBJECT_CAPACITY_TBL_IDX).OBJECT_CAPACITY_ID,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data
            );
          IF l_return_status <> fnd_api.g_ret_sts_success
          THEN
              IF l_return_status = fnd_api.g_ret_sts_error
              THEN
              RAISE fnd_api.g_exc_error;
              ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
        END IF;
        l_idx := p_Object_Tasks.NEXT(l_idx);
      END LOOP;
    END IF;

    fnd_msg_pub.count_and_get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                             );
  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg( g_pkg_name
                               , l_api_name
                               );
      END IF;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

END insert_object_capacity;

PROCEDURE update_object_capacity
/*******************************************************************************
**  update_object_capacity New version
**
**  This API calls table handler to update data into cac_sr_object_capacity.
**  Only the available hours fields and status can be updated.
**  This version include updation of shift type also.
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
) IS

    CURSOR C_ObjCap
    (
     b_object_capacity_id NUMBER
    ) IS SELECT
     OBJECT_VERSION_NUMBER,
     OBJECT_TYPE,
     OBJECT_ID,
     START_DATE_TIME,
     END_DATE_TIME,
     AVAILABLE_HOURS,
     AVAILABLE_HOURS_BEFORE,
     AVAILABLE_HOURS_AFTER,
     SCHEDULE_DETAIL_ID,
     STATUS,
     AVAILABILITY_TYPE,
     SOURCE_TYPE
    FROM CAC_SR_OBJECT_CAPACITY
    WHERE OBJECT_CAPACITY_ID = b_object_capacity_id
    FOR UPDATE OF OBJECT_CAPACITY_ID NOWAIT;

    l_api_name    constant varchar2(30) := 'UPDATE_OBJECT_CAPACITY';
    l_api_version constant number       := 1.0;
    l_current_date        date;
    l_user                number;
    l_login               number;
    l_Object_Capacity     OBJECT_CAPACITY_REC_TYPE;

BEGIN

    -- check version compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    -- initialize message stack if required
    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;
    -- initialize return status
    x_return_status := fnd_api.g_ret_sts_success;

    l_Object_Capacity.OBJECT_CAPACITY_ID := p_object_capacity_id;

    OPEN C_ObjCap(l_Object_Capacity.OBJECT_CAPACITY_ID);
    FETCH C_ObjCap
      INTO l_Object_Capacity.OBJECT_VERSION_NUMBER,
           l_Object_Capacity.OBJECT_TYPE,
           l_Object_Capacity.OBJECT_ID,
           l_Object_Capacity.START_DATE_TIME,
           l_Object_Capacity.END_DATE_TIME,
           l_Object_Capacity.AVAILABLE_HOURS,
           l_Object_Capacity.AVAILABLE_HOURS_BEFORE,
           l_Object_Capacity.AVAILABLE_HOURS_AFTER,
           l_Object_Capacity.SCHEDULE_DETAIL_ID,
           l_Object_Capacity.STATUS,
           l_Object_Capacity.AVAILABILITY_TYPE,
           l_Object_Capacity.SOURCE_TYPE;
    IF C_ObjCap%NOTFOUND
    THEN
      CLOSE C_ObjCap;
      fnd_message.set_name('FND', 'FND_RECORD_DELETED_ERROR');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE C_ObjCap;

    -- check if record updated by another user
    IF (NVL(p_object_version_number, -1) <>
       l_Object_Capacity.OBJECT_VERSION_NUMBER)
    THEN
      fnd_message.set_name('FND', 'FND_RECORD_CHANGED_ERROR');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Copy the changed values

    -- Available hours is mandatory field, so update only if a new valid
    -- value is passed.
    IF ((p_available_hours IS NULL) OR (p_available_hours = FND_API.G_MISS_NUM))
    THEN
      NULL;
    ELSE
      l_Object_Capacity.AVAILABLE_HOURS := p_available_hours;
    END IF;

    -- Available hours before can be set to NULL or a new value
    IF (p_available_hours_before IS NULL)
    THEN
      NULL;
    ELSIF (p_available_hours_before = FND_API.G_MISS_NUM)
    THEN
      l_Object_Capacity.AVAILABLE_HOURS_BEFORE := NULL;
    ELSE
      l_Object_Capacity.AVAILABLE_HOURS_BEFORE := p_available_hours_before;
    END IF;

    -- Available hours after can be set to NULL or a new value
    IF (p_available_hours_after IS NULL)
    THEN
      NULL;
    ELSIF (p_available_hours_after = FND_API.G_MISS_NUM)
    THEN
      l_Object_Capacity.AVAILABLE_HOURS_AFTER := NULL;
    ELSE
      l_Object_Capacity.AVAILABLE_HOURS_AFTER := p_available_hours_after;
    END IF;

    -- Status is mandatory field, so update only if a new valid value is passed.
    IF ((p_status IS NULL) OR (p_status = FND_API.G_MISS_NUM))
    THEN
      NULL;
    ELSE
      l_Object_Capacity.STATUS := p_status;
    END IF;

    -- Shift type is mandatory field, so update only if a new valid value is passed.
    IF ((p_availability_type IS NULL) OR (p_availability_type = ''))
    THEN
      NULL;
    ELSE
      l_Object_Capacity.AVAILABILITY_TYPE := p_availability_type;
    END IF;

     -- start date time is mandatory field, so update only if a new valid value is passed.
    IF ((p_start_date_time IS NULL) OR (p_start_date_time = FND_API.G_MISS_DATE))
    THEN
      NULL;
    ELSE
      l_Object_Capacity.START_DATE_TIME := p_start_date_time;
    END IF;

    -- end date time is mandatory field, so update only if a new valid value is passed.
    IF ((p_end_date_time IS NULL) OR (p_end_date_time = FND_API.G_MISS_DATE))
    THEN
      NULL;
    ELSE
      l_Object_Capacity.END_DATE_TIME := p_end_date_time;
    END IF;

    -- for source type field update only if a new valid value is passed.
    IF ((p_source_type IS NULL) OR (p_source_type = FND_API.G_MISS_CHAR))
    THEN
      NULL;
    ELSE
      l_Object_Capacity.SOURCE_TYPE := p_source_type;
    END IF;

    -- Now increment the object version number by one
    l_Object_Capacity.OBJECT_VERSION_NUMBER := l_Object_Capacity.OBJECT_VERSION_NUMBER + 1;

    l_current_date := SYSDATE;
    l_user := FND_GLOBAL.USER_ID;
    l_login := FND_GLOBAL.LOGIN_ID;

    -- call the table handler to update data
    CAC_SR_OBJECT_CAPACITY_PKG.UPDATE_ROW
    (
      X_OBJECT_CAPACITY_ID     => l_Object_Capacity.OBJECT_CAPACITY_ID,
      X_OBJECT_VERSION_NUMBER  => l_Object_Capacity.OBJECT_VERSION_NUMBER,
      X_OBJECT_TYPE            => l_Object_Capacity.OBJECT_TYPE,
      X_OBJECT_ID              => l_Object_Capacity.OBJECT_ID,
      X_START_DATE_TIME        => l_Object_Capacity.START_DATE_TIME,
      X_END_DATE_TIME          => l_Object_Capacity.END_DATE_TIME,
      X_AVAILABLE_HOURS        => l_Object_Capacity.AVAILABLE_HOURS,
      X_AVAILABLE_HOURS_BEFORE => l_Object_Capacity.AVAILABLE_HOURS_BEFORE,
      X_AVAILABLE_HOURS_AFTER  => l_Object_Capacity.AVAILABLE_HOURS_AFTER,
      X_SCHEDULE_DETAIL_ID     => l_Object_Capacity.SCHEDULE_DETAIL_ID,
      X_STATUS                 => l_Object_Capacity.STATUS,
      X_AVAILABILITY_TYPE      => l_Object_Capacity.AVAILABILITY_TYPE,
      X_SOURCE_TYPE            => l_Object_Capacity.SOURCE_TYPE,
      X_CREATION_DATE          => l_current_date,
      X_CREATED_BY             => l_user,
      X_LAST_UPDATE_DATE       => l_current_date,
      X_LAST_UPDATED_BY        => l_user,
      X_LAST_UPDATE_LOGIN      => l_login
    );

    fnd_msg_pub.count_and_get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                             );
  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg( g_pkg_name
                               , l_api_name
                               );
      END IF;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

END update_object_capacity;

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
) IS

    CURSOR C_ObjCap
    (
     b_object_capacity_id NUMBER
    ) IS SELECT
     OBJECT_VERSION_NUMBER
    FROM CAC_SR_OBJECT_CAPACITY
    WHERE OBJECT_CAPACITY_ID = b_object_capacity_id
    FOR UPDATE OF OBJECT_CAPACITY_ID NOWAIT;

      CURSOR c_tasks
      (
        b_object_capacity_id number
      )
      is
      select   jta.task_assignment_id
      ,        jta.object_version_number
      from     jtf_task_statuses_b jtsb
      ,        jtf_task_assignments jta
      ,        jtf_tasks_b jtb
      where    jtsb.task_status_id = jta.assignment_status_id
      and      jta.object_capacity_id = b_object_capacity_id
      and      jta.task_id = jtb.task_id
      and      nvl(jtb.deleted_flag, 'N') = 'N'
      order by jtb.scheduled_start_date;

    l_api_name    constant varchar2(30) := 'DELETE_OBJECT_CAPACITY';
    l_api_version constant number       := 1.0;
    l_return_status       varchar2(1);
    l_msg_count           number;
    l_msg_data            varchar2(2000);
    l_object_version_number      number;

BEGIN

    -- check version compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    -- initialize message stack if required
    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;
    -- initialize return status
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN C_ObjCap(p_object_capacity_id);
    FETCH C_ObjCap
      INTO l_object_version_number;
    IF C_ObjCap%NOTFOUND
    THEN
      CLOSE C_ObjCap;
      fnd_message.set_name('FND', 'FND_RECORD_DELETED_ERROR');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE C_ObjCap;

    -- check if record updated by another user
    IF (NVL(p_object_version_number, -1) <> l_object_version_number)
    THEN
      fnd_message.set_name('FND', 'FND_RECORD_CHANGED_ERROR');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- check if task assignments need to be updated
    IF fnd_api.to_boolean(p_Update_Tasks)
    THEN
      -- First get all the open task assignments and remove the object capacity
      FOR ref_tasks IN c_tasks(p_object_capacity_id)
      LOOP
        -- Call assignments api to update object capacity id
          JTF_TASK_ASSIGNMENTS_PUB.UPDATE_TASK_ASSIGNMENT
          (
         p_api_version              => 1.0,
         p_commit                   => fnd_api.G_FALSE,
         p_object_version_number    => ref_tasks.OBJECT_VERSION_NUMBER,
         p_task_assignment_id       => ref_tasks.TASK_ASSIGNMENT_ID,
         p_enable_workflow          => NULL,
         p_abort_workflow           => NULL,
         p_object_capacity_id       => NULL,
         x_return_status            => l_return_status,
         x_msg_count                => l_msg_count,
         x_msg_data                 => l_msg_data
              );
           IF l_return_status <> fnd_api.g_ret_sts_success
           THEN
             IF l_return_status = fnd_api.g_ret_sts_error
             THEN
             RAISE fnd_api.g_exc_error;
             ELSE
             RAISE fnd_api.g_exc_unexpected_error;
           END IF;
         END IF;
       END LOOP;
    END IF;

    -- call the table handler to delete data
    CAC_SR_OBJECT_CAPACITY_PKG.DELETE_ROW
    (
      X_OBJECT_CAPACITY_ID => p_object_capacity_id
    );

    fnd_msg_pub.count_and_get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                             );
  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg( g_pkg_name
                               , l_api_name
                               );
      END IF;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

END delete_object_capacity;

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
) IS

    l_api_name    constant varchar2(30) := 'BUILD_OBJECT_CAPACITY';
    l_api_version constant number       := 1.0;

BEGIN

    -- check version compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    -- initialize message stack if required
    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;
    -- initialize return status
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.count_and_get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                             );
  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg( g_pkg_name
                               , l_api_name
                               );
      END IF;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

END build_object_capacity;


END CAC_SR_OBJECT_CAPACITY_PUB;

/
