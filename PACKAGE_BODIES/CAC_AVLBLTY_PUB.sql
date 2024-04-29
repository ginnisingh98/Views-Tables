--------------------------------------------------------
--  DDL for Package Body CAC_AVLBLTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_AVLBLTY_PUB" AS
/* $Header: caccabb.pls 120.5 2008/01/09 12:52:05 lokumar ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CAC_AVLBLTY_PUB';

/*******************************************************************************
** Public APIs
*******************************************************************************/

PROCEDURE GET_SCHEDULE
/*******************************************************************************
**  getSchedule
**
**  Roughly translates to JTF_CALENDAR_PUB_24HR.Get_Resource_Shifts API.
**  It will return a list of periods for which the given Object is considered
**  to be available. The algorithme used is as follows:
**
**     24*7*365              (full availability if no constraints are defined)
**     Schedule              (if a schedule was defined we'll use it)
**     Holidays              (if Holidays are defined in HR we'll honor them)
**     Exceptions  -         (Resource level Exceptions will be honored)
**    --------------
**     Schedule
**
*******************************************************************************/
( p_api_version          IN     NUMBER               -- API version you coded against
, p_init_msg_list        IN     VARCHAR2             -- Create a new error stack?
, p_Object_Type          IN     VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID            IN     NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date_Time      IN     DATE                 -- start date and time of period of interest
, p_End_Date_Time        IN     DATE                 -- end date and time of period of interest
, p_Schedule_Category    IN     VARCHAR2             -- Schedule Category of the schedule instance we'll look at
, p_Include_Exception    IN     VARCHAR2             -- 'T' or 'F' depending on whether the exceptions be included or not
, p_Busy_Tentative       IN     VARCHAR2             -- How to treat periods with FREEBUSYTYPE = BUSY TENTATIVE?
                                                     -- FREE: BUSY TENTATIVE means FREE
                                                     -- BUSY: BUSY TENTATIVE means BUSY
                                                     -- NULL: leave the interpretation to caller
, x_Schedule             OUT NOCOPY CAC_AVLBLTY_TIME_VARRAY
                                                     --  return schedule
, x_return_status        OUT NOCOPY VARCHAR2         -- 'S': API completed without errors
                                                     -- 'E': API completed with recoverable errors; explanation on errorstack
                                                     -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count            OUT NOCOPY NUMBER           -- Number of messages on the errorstack
, x_msg_data             OUT NOCOPY VARCHAR2         -- contains message if x_msg_count = 1
) IS

  l_api_name           CONSTANT VARCHAR2(30)    := 'GET_SCHEDULE';
  l_api_name_full      CONSTANT VARCHAR2(61)    := g_pkg_name || '.' || l_api_name;
  l_api_version        CONSTANT NUMBER          := 1.0;
  l_summary            CAC_AVLBLTY_SUMMARY_VARRAY;

BEGIN

  -- Check version number
  IF NOT fnd_api.compatible_api_call
                ( l_api_version
                , p_api_version
                , l_api_name
                , g_pkg_name
                )
  THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list
  IF fnd_api.to_boolean( p_init_msg_list )
  THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

  CAC_AVLBLTY_PVT.GET_SCHEDULE_DATA
  (
    p_Object_Type       => p_Object_Type,
    p_Object_ID         => p_Object_ID,
    p_Start_Date_Time   => p_Start_Date_Time,
    p_End_Date_Time     => p_End_Date_Time,
    p_Schdl_Cat         => p_Schedule_Category,
    p_Include_Exception => p_Include_Exception,
    p_Busy_Tentative    => p_Busy_Tentative,
    p_return_type       => 'D',
    x_Schedule          => x_Schedule,
    x_Schedule_Summary  => l_summary
  );

  EXCEPTION

    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN OTHERS
    THEN
      --
      -- Set status
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      --
      -- Push message onto CRM stack
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , l_api_name
                             , SQLERRM
                             );
      --
      -- Count the messages on the CRM stack
      --
      x_msg_count     := FND_MSG_PUB.COUNT_MSG;

END GET_SCHEDULE;


PROCEDURE GET_SCHEDULE_SUMMARY
/*******************************************************************************
**  GET_SCHEDULE_SUMMARY
**
**  This API will return summary of schedule on day by day basis
**  The algorithme used is as follows:
**
**     24*7*365              (full availability if no constraints are defined)
**     Schedule              (if a schedule was defined we'll use it)
**     Holidays              (if Holidays are defined in HR we'll honor them)
**     Exceptions  -         (Resource level Exceptions will be honored)
**    --------------
**     Schedule
**
*******************************************************************************/
( p_api_version          IN     NUMBER               -- API version you coded against
, p_init_msg_list        IN     VARCHAR2             -- Create a new error stack?
, p_Object_Type          IN     VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID            IN     NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date           IN     DATE                 -- start date of period of interest
, p_End_Date             IN     DATE                 -- end date of period of interest
, p_Schedule_Category    IN     VARCHAR2             -- Schedule Category of the schedule instance we'll look at
, p_Include_Exception    IN     VARCHAR2             -- 'T' or 'F' depending on whether the exceptions be included or not
, p_Busy_Tentative       IN     VARCHAR2             -- How to treat periods with FREEBUSYTYPE = BUSY TENTATIVE?
                                                     -- FREE: BUSY TENTATIVE means FREE
                                                     -- BUSY: BUSY TENTATIVE means BUSY
                                                     -- NULL: leave the interpretation to caller
, x_Schedule_Summary     OUT NOCOPY CAC_AVLBLTY_SUMMARY_VARRAY
                                                     --  return schedule summary
, x_return_status        OUT NOCOPY VARCHAR2         -- 'S': API completed without errors
                                                     -- 'E': API completed with recoverable errors; explanation on errorstack
                                                     -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count            OUT NOCOPY NUMBER           -- Number of messages on the errorstack
, x_msg_data             OUT NOCOPY VARCHAR2         -- contains message if x_msg_count = 1
) IS

  l_api_name           CONSTANT VARCHAR2(30)    := 'GET_SCHEDULE_SUMMARY';
  l_api_name_full      CONSTANT VARCHAR2(61)    := g_pkg_name || '.' || l_api_name;
  l_api_version        CONSTANT NUMBER          := 1.0;
  l_Schedule           CAC_AVLBLTY_TIME_VARRAY;

BEGIN

  -- Check version number
  IF NOT fnd_api.compatible_api_call
                ( l_api_version
                , p_api_version
                , l_api_name
                , g_pkg_name
                )
  THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list
  IF fnd_api.to_boolean( p_init_msg_list )
  THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

  CAC_AVLBLTY_PVT.GET_SCHEDULE_DATA
  (
    p_Object_Type       => p_Object_Type,
    p_Object_ID         => p_Object_ID,
    p_Start_Date_Time   => p_Start_Date,
    p_End_Date_Time     => p_End_Date,
    p_Schdl_Cat         => p_Schedule_Category,
    p_Include_Exception => p_Include_Exception,
    p_Busy_Tentative    => p_Busy_Tentative,
    p_return_type       => 'S',
    x_Schedule          => l_Schedule,
    x_Schedule_Summary  => x_Schedule_Summary
  );

  EXCEPTION

    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN OTHERS
    THEN
      --
      -- Set status
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      --
      -- Push message onto CRM stack
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , l_api_name
                             , SQLERRM
                             );
      --
      -- Count the messages on the CRM stack
      --
      x_msg_count     := FND_MSG_PUB.COUNT_MSG;

END GET_SCHEDULE_SUMMARY;


PROCEDURE IS_AVAILABLE
/*****************************************************************************
**  Method IS_AVAILABLE
**
**  Roughly translates to JTF_CALENDAR_PUB_24HR. Is_Res_Available API.
**  It will return:
**   - 'T' if the resource is available for the given period
**   - 'F' if the resource is unavailable for the given period
**
*******************************************************************************/
( p_api_version          IN     NUMBER               -- API version you coded against
, p_init_msg_list        IN     VARCHAR2             -- Create a new error stack?
, p_Object_Type          IN     VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID            IN     NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date_Time      IN     DATE                 -- start date and time of period of interest
, p_End_Date_Time        IN     DATE                 -- end date and time of period of interest
, p_Schedule_Category    IN     VARCHAR2             -- Schedule Category of the schedule instance we'll look at
, p_Busy_Tentative       IN     VARCHAR2             -- How to treat periods with FREEBUSYTYPE = BUSY TENTATIVE?
                                                     -- FREE: BUSY TENTATIVE means FREE
                                                     -- BUSY: BUSY TENTATIVE means BUSY
                                                     -- NULL: leave the interpretation to caller
, p_task_assignment_id   IN     NUMBER  DEFAULT NULL -- specifies the task assignment id to be ignored while checking availability
                                                     -- Added by lokumar for bug#6345516
, x_Available            OUT NOCOPY VARCHAR2         -- 'T' or 'F'
, x_return_status        OUT NOCOPY VARCHAR2         -- 'S': API completed without errors
                                                     -- 'E': API completed with recoverable errors; explanation on errorstack
                                                     -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count            OUT NOCOPY NUMBER           -- Number of messages on the errorstack
, x_msg_data             OUT NOCOPY VARCHAR2         -- contains message if x_msg_count = 1
) IS

  CURSOR c_tasks
  (
    b_ObjectType     VARCHAR2,
    b_ObjectID       NUMBER,
    b_StartDate      DATE,
    b_EndDate        DATE,
    b_BusyTentative  VARCHAR2,
    b_ToTimeZone     NUMBER
  ) IS
  SELECT GREATEST( CAC_AVLBLTY_PVT.ADJUST_FOR_TIMEZONE( jtb.timezone_id
                                                      , b_ToTimeZone
                                                      , jtb.calendar_start_date
                                                      )
                 , b_StartDate
                 ) StartDateTime
  ,      LEAST( CAC_AVLBLTY_PVT.ADJUST_FOR_TIMEZONE( jtb.timezone_id
                                                   , b_ToTimeZone
                                                   , jtb.calendar_end_date
                                                   )
              , b_EndDate
              ) EndDateTime
  ,      DECODE( jta.free_busy_type, 'FREE','FREE'
                                   , 'BUSY','BUSY'
                                   , 'TENTATIVE',NVL(b_BusyTentative,'TENTATIVE')
               ) FBType
  ,      jtb.task_type_id CategoryID
  ,      jtb.entity CategoryType
  ,      jta.task_assignment_id
  FROM jtf_task_all_assignments  jta
  ,    jtf_tasks_b               jtb
  ,    ( SELECT /*+ INDEX(jts JTF_TASK_STATUSES_B_U1) */ jts.task_status_id
         FROM   jtf_task_statuses_b jts
         WHERE  jts.assignment_status_flag    = 'Y'
         AND    NVL(jts.closed_flag,'N')      = 'N'
         AND    NVL(jts.completed_flag,'N')   = 'N'
         AND    NVL(jts.rejected_flag,'N')    = 'N'
         AND    NVL(jts.on_hold_flag,'N')     = 'N'
         AND    NVL(jts.cancelled_flag,'N')   = 'N'
       ) jto
  WHERE jta.resource_type_code   = b_ObjectType
  AND   jta.resource_id          = b_ObjectID
  AND   jta.assignment_status_id = jto.task_status_id
  AND   jta.task_id              = jtb.task_id
  AND   jtb.open_flag            = 'Y'
  AND   jtb.calendar_end_date   >= b_StartDate
  AND   jtb.calendar_start_date <= b_EndDate
  AND   jtb.entity IN ('BOOKING','TASK','APPOINTMENT');

  l_api_name           CONSTANT VARCHAR2(30)    := 'IS_AVAILABLE';
  l_api_name_full      CONSTANT VARCHAR2(61)    := g_pkg_name || '.' || l_api_name;
  l_api_version        CONSTANT NUMBER          := 1.0;

BEGIN

  -- Check version number
  IF NOT fnd_api.compatible_api_call
                ( l_api_version
                , p_api_version
                , l_api_name
                , g_pkg_name
                )
  THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list
  IF fnd_api.to_boolean( p_init_msg_list )
  THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

  x_Available     := 'T';

  FOR ref_tasks IN c_tasks(p_Object_Type,
                           p_Object_Id,
                           p_Start_Date_Time-1,
                           p_End_Date_Time+1,
                           p_Busy_Tentative,
                           TO_NUMBER(FND_PROFILE.Value('SERVER_TIMEZONE_ID')))
  LOOP
    -- If condition modified by lokumar for bug#5752188
    IF ((p_task_assignment_id is null OR p_task_assignment_id<>ref_tasks.task_assignment_id) AND (ref_tasks.FBType = 'BUSY') AND (NOT (
      ((p_Start_Date_Time < ref_tasks.StartDateTime) AND
       (p_End_Date_Time   <= ref_tasks.StartDateTime)) OR
      ((p_Start_Date_Time >= ref_tasks.EndDateTime) AND
       (p_End_Date_Time   > ref_tasks.EndDateTime)))))
    THEN
      x_Available := 'F';
      EXIT;
    END IF;
  END LOOP;

  EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

    WHEN OTHERS
    THEN
      --
      -- Set status
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      --
      -- Push message onto CRM stack
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , l_api_name
                             , SQLERRM
                             );
      --
      -- Count the messages on the CRM stack
      --
      x_msg_count     := FND_MSG_PUB.COUNT_MSG;

END IS_AVAILABLE;


END CAC_AVLBLTY_PUB;

/
