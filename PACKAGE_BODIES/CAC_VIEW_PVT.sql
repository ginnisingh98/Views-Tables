--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_PVT" AS
/* $Header: cacvpb.pls 120.15 2006/09/19 12:08:41 sankgupt noship $ */

TYPE MENUS_TBL IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

FUNCTION get_locations(p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_locations IS
        SELECT resource_id
          FROM jtf_task_all_assignments jta
         WHERE jta.resource_type_code = 'PN_LOCATION'
           AND jta.task_id = p_task_id;

        CURSOR c_standalone_location IS
        SELECT location
          FROM cac_view_collab_details_vl cdv
           WHERE cdv.task_id = p_task_id;


        l_locations VARCHAR2(4000);
        l_location VARCHAR2(2000);
    BEGIN
        FOR rec_std IN c_standalone_location
        LOOP
          l_locations := rec_std.location;
        END LOOP;
        FOR rec IN c_locations
        LOOP
            IF(rec.resource_id IS NOT NULL) THEN
              l_location := JTF_TASK_UTL.get_owner('PN_LOCATION', rec.resource_id);
            END IF;
            IF(l_location IS NOT NULL) THEN
              IF l_locations IS NULL THEN
                l_locations := l_location;
              ELSE
                l_locations := l_locations || ', '|| l_location;
              END IF;
          END IF;
        END LOOP;

        RETURN l_locations;
    END;

PROCEDURE GetCalendarList
/*******************************************************************************
** Given a ResourceID, this procedure will return a list of Calendars that the
** Calendar user has access to
*******************************************************************************/
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_validation_level       IN     NUMBER
, x_return_status          OUT    NOCOPY    VARCHAR2
, x_msg_count              OUT    NOCOPY    NUMBER
, x_msg_data               OUT    NOCOPY    VARCHAR2
, p_resourceID             IN OUT NOCOPY    NUMBER
, p_resourceType           IN OUT NOCOPY    VARCHAR2
, p_userID                 IN     NUMBER
, x_calendarList           OUT    NOCOPY    CalLstTblType
)
IS
  l_index         BINARY_INTEGER;
  l_ResourceName  VARCHAR2(360);
  l_GranteeKey    VARCHAR2(240);
  /*****************************************************************************
  ** NOTE: Since we consider the views provided by AOL performance hazards we
  **       will pick up the data we need directly from their tables
  *****************************************************************************/

  CURSOR c_PersonalCalendars(b_Grantee_Key IN VARCHAR2)
  /*****************************************************************************
  ** This cursor will pick up all Resource Ids of persons the Calendar User has
  ** access to and the level of access that was granted.
  ****************************************************************/
  IS SELECT DISTINCT fmu.menu_name         Privilege
     ,      fgs.instance_pk1_value         ResourceID
     ,      jrt.resource_name              ResourceName
     FROM  fnd_grants                 fgs
     ,     fnd_menus                  fmu
     ,     fnd_objects                fos
     ,     jtf_rs_resource_extns_tl   jrt
     WHERE fgs.object_id          = fos.object_id   -- grants joint to object
     AND   fgs.menu_id            = fmu.menu_id     -- grants joint to menus
     AND   fos.obj_name           = 'JTF_TASK_RESOURCE'
     AND   fgs.grantee_key        = b_Grantee_Key
     AND   fgs.grantee_type       = 'USER'
     AND   fgs.start_date        <  SYSDATE
     AND   (   fgs.end_date          >= SYSDATE
           OR  fgs.end_date IS NULL
           )
     AND   fgs.instance_pk2_value = ('RS_EMPLOYEE')
     --AND   to_char(jrt.resource_id)        = fgs.instance_pk1_value  -- Commented by SBARAT on 23/02/2006 for bug# 5045559
     AND   jrt.resource_id        = to_number(fgs.instance_pk1_value)  -- Added by SBARAT on 23/02/2006 for bug# 5045559
     AND   jrt.LANGUAGE           = USERENV('LANG');

  CURSOR c_GroupCalendars(b_GranteeKey IN VARCHAR2)
  /*****************************************************************************
  ** This cursor will pick up all Resource Group Ids of persons the Calendar
  ** User has the CALENDAR_ADMIN role.
  *****************************************************************************/
  IS SELECT DISTINCT DECODE(fmu.menu_name,'JTF_CAL_ADMIN_ACCESS','JTF_CAL_FULL_ACCESS',FMU.MENU_NAME) Privilege
     ,      fgs.instance_pk1_value   ResourceID
     ,      jrt.group_name           ResourceName
     FROM  fnd_grants                 fgs
     ,     fnd_menus                  fmu
     ,     fnd_objects                fos
     ,     jtf_rs_groups_tl           jrt
     WHERE fgs.object_id          = fos.object_id   -- grants joint to object
     AND   fgs.menu_id            = fmu.menu_id     -- grants joint to menus
     AND   fmu.MENU_NAME in ('JTF_CAL_ADMIN_ACCESS','JTF_CAL_FULL_ACCESS')
     AND   fos.obj_name           = 'JTF_TASK_RESOURCE'
     AND   fgs.grantee_key        = b_GranteeKey --'1000001366'
     AND   fgs.grantee_type       = 'USER'
     AND   fgs.start_date        <  SYSDATE
     AND   (  fgs.end_date       >= SYSDATE
           OR fgs.end_date IS NULL
           )
     AND   fgs.instance_pk2_value = ('RS_GROUP')
     AND   jrt.group_id           = TO_NUMBER(fgs.instance_pk1_value)
     AND   jrt.LANGUAGE           = USERENV('LANG');

BEGIN
  IF fnd_api.to_boolean (NVL(p_init_msg_list,fnd_api.g_false))
  THEN
    fnd_msg_pub.initialize;
  END IF;

  l_index := 1;
  /*****************************************************************************
  ** Get basic Resource Information for current FND_USER
  *****************************************************************************/
  IF ((p_ResourceID IS NULL) OR (p_ResourceType IS NULL))
  THEN
    Jtf_Cal_Utility_Pvt.GetResourceInfo( p_UserID       => p_userID
                                        , x_ResourceID   => p_ResourceID
                                        , x_ResourceType => p_ResourceType
                                        , x_ResourceName => l_ResourceName
                                        );
  ELSE
    l_ResourceName := Jtf_Cal_Utility_Pvt.GetResourceName( p_ResourceID
                                                          , p_ResourceType
                                                          );
  END IF;

  /*****************************************************************************
  ** Determine the GranteeKey
  *****************************************************************************/
  l_GranteeKey := TO_CHAR(p_ResourceID);

  /*****************************************************************************
  ** There is no record in the GRANTS table for CALENDAR ACCESS to your own
  ** personal calendar in order to simplify the logic on the client side we will
  ** add a record to the list
  *****************************************************************************/
  x_calendarList(l_index).ResourceID   := p_resourceID;
  x_calendarList(l_index).ResourceType := 'RS_EMPLOYEE';
  x_calendarList(l_index).CalendarName := l_ResourceName;
  x_calendarList(l_index).AccessLevel  := 'JTF_CAL_ADMIN_ACCESS';
  l_index := l_index + 1;

  /*****************************************************************************
  ** Get all the Personal Calendars the Calender User has access to.
  *****************************************************************************/
  FOR r_PersonalCalendar IN c_PersonalCalendars(l_GranteeKey)
  LOOP <<PERSONAL_CALENDARS>>
    x_calendarList(l_index).ResourceID   := r_PersonalCalendar.ResourceID;
    x_calendarList(l_index).ResourceType := 'RS_EMPLOYEE';
    x_calendarList(l_index).CalendarName := r_PersonalCalendar.ResourceName;
    x_calendarList(l_index).AccessLevel  := r_PersonalCalendar.Privilege;
    l_index := l_index + 1;
  END LOOP PERSONAL_CALENDARS;

  /*****************************************************************************
  ** Get all the Group Calendars the Calender User has access to.
  *****************************************************************************/
  FOR r_GroupCalendar IN c_GroupCalendars(l_GranteeKey)
  LOOP <<GROUP_CALENDARS>>
    x_calendarList(l_index).ResourceID   := r_GroupCalendar.ResourceID;
    x_calendarList(l_index).ResourceType := 'RS_GROUP';
    x_calendarList(l_index).CalendarName := r_GroupCalendar.ResourceName;
    x_calendarList(l_index).AccessLevel  := r_GroupCalendar.Privilege;
    l_index := l_index + 1;
  END LOOP GROUP_CALENDARS;

END GetCalendarList;

FUNCTION GET_ACCESS_LEVEL
( p_entity                 IN VARCHAR2
, p_object_code            IN VARCHAR2
, p_loggedon_resource_id   IN NUMBER
, p_loggedon_resource_type IN VARCHAR2
, p_query_resource_id      IN NUMBER
, p_query_resource_type    IN VARCHAR2
, p_private_flag           IN VARCHAR2
, p_access_list            IN MENUS_TBL
) RETURN NUMBER
IS
  l_ret_value NUMBER;
BEGIN
  l_ret_value := 3;
  IF (p_entity = 'BOOKING')
  THEN
    IF ((p_loggedon_resource_id = p_query_resource_id) AND
      (p_loggedon_resource_type = p_query_resource_type))
    THEN
      l_ret_value := 1;
    ELSE
      IF (p_access_list.COUNT > 0)
      THEN
        FOR i IN p_access_list.FIRST..p_access_list.LAST
        LOOP
          IF (p_access_list(i) = 'CAC_BKG_READ_ONLY_ACCESS')
          THEN
            l_ret_value := 1;
            EXIT;
          END IF;
        END LOOP;
      END IF;
    END IF;
  ELSIF (p_entity = 'TASK')
  THEN
    IF ((p_loggedon_resource_id = p_query_resource_id) AND
      (p_loggedon_resource_type = p_query_resource_type))
    THEN
      l_ret_value := 2;
    ELSIF (p_private_flag = 'Y')
    THEN
      l_ret_value := 0;
    ELSE
      IF (p_access_list.COUNT > 0)
      THEN
        FOR i IN p_access_list.FIRST..p_access_list.LAST
        LOOP
          IF (p_access_list(i) = 'JTF_TASK_FULL_ACCESS')
          THEN
            l_ret_value := 2;
            EXIT;
          ELSIF (p_access_list(i) = 'JTF_TASK_READ_ONLY')
          THEN
            l_ret_value := 1;
            -- continue checking
          END IF;
        END LOOP;
      END IF;
    END IF;
  ELSIF (p_entity = 'APPOINTMENT')
  THEN
    IF ((p_loggedon_resource_id = p_query_resource_id) AND
      (p_loggedon_resource_type = p_query_resource_type))
    THEN
      IF (p_object_code = 'EXTERNAL APPOINTMENT')
      THEN
        l_ret_value := 1;
      ELSE
        l_ret_value := 2;
      END IF;
    ELSIF (p_private_flag = 'Y')
    THEN
      l_ret_value := 0;
    ELSE
      IF (p_access_list.COUNT > 0)
      THEN
        FOR i IN p_access_list.FIRST..p_access_list.LAST
        LOOP
          IF (p_access_list(i) = 'JTF_CAL_FULL_ACCESS')
          THEN
            IF (p_object_code = 'EXTERNAL APPOINTMENT')
            THEN
              l_ret_value := 1;
            ELSE
              l_ret_value := 2;
            END IF;
            EXIT;
          ELSIF (p_access_list(i) = 'JTF_CAL_READ_ACCESS')
          THEN
            l_ret_value := 1;
            -- continue checking
          END IF;
        END LOOP;
      END IF;
    END IF;
  END IF;
  RETURN l_ret_value;
END GET_ACCESS_LEVEL;

PROCEDURE GetBookings
( p_LoggedOnRSID            IN  NUMBER
, p_LoggedOnRSType          IN  VARCHAR2
, p_QueryRSID               IN  NUMBER
, p_QueryRSType             IN  VARCHAR2
, p_QueryStartDate          IN  DATE
, p_QueryEndDate            IN  DATE
, p_QueryMode               IN  VARCHAR2
, p_TimezoneId              IN  NUMBER
, p_CalSpanDaysProfile      IN  VARCHAR2
, p_GroupRSID               IN  VARCHAR2
, p_ShowBookings            IN  CHAR
, p_QueryUserAccess         IN  MENUS_TBL
, x_index                   IN OUT NOCOPY    BINARY_INTEGER
, x_DisplayItems            IN OUT NOCOPY    CAC_VIEW_PVT.QueryOutTab
)
IS
  l_TempStartDate       DATE;
  l_TempEndDate         DATE;
  l_TempItemDisplayType  NUMBER;
  l_ItemDisplayType      NUMBER;

  l_StartDate         DATE;
  l_EndDate         DATE;
  l_NewStartDate         DATE;
  l_NewEndDate         DATE;

  l_objects_input    jtf_objects_pub.PG_INPUT_REC;

 CURSOR c_Bookings
  /*****************************************************************************
  ** This cursor will only return Bookings that need to be displayed
  ** in the page or is needed to derive that information
  *****************************************************************************/
  ( b_ResourceID   IN NUMBER
  , b_ResourceType IN VARCHAR2
  , b_StartDate    IN DATE  -- start of query period
  , b_EndDate      IN DATE  -- end of query period
  )IS
       SELECT task_view.TASK_ID           TaskId,
       booking.ASSIGNEE_ROLE ,
       booking_status.NAME AS             BOOKING_STATUS_NAME,
       task_type.NAME AS                  TYPE_NAME,
       task_priority.NAME AS              PRIORITY_NAME,
       task_view.TASK_NAME                ItemName ,
       task_view.calendar_start_date AS      StartDate,
       task_view.calendar_end_date AS        EndDate,
       task_view.SOURCE_OBJECT_TYPE_CODE  SourceObjectTypeCode,
       task_view.SOURCE_OBJECT_ID         SourceId,
       booking.assignment_status_id       AssignmentStatus,
       freebusy.meaning                   FREE_BUSY_STATUS,
       booking.assignee_role              AssigneeRole,
       task_view.alarm_on                 RemindIndicator,
       DECODE(task_view.recurrence_rule_id
                   ,NULL,0
                   ,1
                   ) RepeatIndicator,
       task_view.TIMEZONE_ID               TimezoneID,
       task_view.OWNER_ID,
       task_view.OWNER_TYPE_CODE,
       owner.SOURCE_NAME AS                OWNER,
       task_view.PRIVATE_FLAG              PrivateFlag ,
       task_view.DESCRIPTION,
       jtf_object.name AS SOURCE_NAME,
       jtf_task_utl.get_owner(task_view.SOURCE_OBJECT_TYPE_CODE, task_view.SOURCE_OBJECT_ID) AS SOURCE_INSTANCE
   FROM
     jtf_tasks_vl task_view,
     jtf_task_statuses_vl booking_status,
     jtf_task_types_tl task_type,
     jtf_task_priorities_tl task_priority,
     jtf_rs_resource_extns owner,
     jtf_task_all_assignments booking,
     fnd_lookups freebusy,
     jtf_objects_tl jtf_object
     WHERE
        booking.resource_id = b_ResourceId --10125
        AND booking.resource_type_code = b_ResourceType --'RS_EMPLOYEE'
        AND booking.task_id = task_view.task_id
        --AND task_view.entity = 'BOOKING'  -- all bookings
        AND (NVL(task_view.deleted_flag,'N') = 'N')             -- not deleted
AND (task_view.calendar_start_date <= b_EndDate --sysdate + 5*360     --start date
    OR task_view.calendar_start_date is null)
       AND (task_view.calendar_end_date   >=  b_StartDate--sysdate - 5*360    --end date
        OR task_view.calendar_end_date is null)
        AND task_view.task_type_id = task_type.task_type_id            -- type
        AND task_type.language = userenv('LANG')
    AND booking.assignment_status_id = booking_status.task_status_id  -- booking status
        AND NVL(booking_status.cancelled_flag, 'N') <>'Y'                             -- not cancelled
    AND NVL(booking_status.rejected_flag, 'N') <> 'Y'                             --not rejected
        AND task_view.task_priority_id = task_priority.task_priority_id       --priority
        AND task_priority.language = userenv('LANG')
        AND task_view.owner_id = owner.resource_id  --owner
        AND task_view.owner_type_code = 'RS_' || owner.category
    AND freebusy.lookup_type = 'CAC_VIEW_FREE_BUSY'
    AND  booking.free_busy_type =  freebusy.lookup_code
    AND task_view.source_object_type_code = jtf_object.object_code
    AND task_view.source_object_type_code = 'EXTERNAL APPOINTMENT'
        AND jtf_object.language = userenv('LANG') ;

BEGIN
 IF (p_ShowBookings ='Y') THEN
  IF (c_Bookings%ISOPEN)
  THEN
    CLOSE c_Bookings; -- Make sure the cursor is closed
  END IF;
  FOR r_Bookings IN c_Bookings( p_QueryRSID
                               , p_QueryRSType
                               , p_QueryStartDate - 1 -- allow for max timezone correction
                               , p_QueryEndDate   + 1 -- allow for max timezone correction
                               )
  LOOP <<BOOKINGS>>
    /***************************************************************************
    ** We will have to adjust the Start/End Date for the users timezone
    ***************************************************************************/
    l_StartDate  := r_Bookings.StartDate;
    l_EndDate    := r_Bookings.EndDate;

     if p_TimezoneId is not null
     then
     CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  to_number(r_Bookings.TimezoneID)
    , p_dest_tz_id      =>  p_TimezoneId
    , p_source_day_time =>  l_StartDate
    , x_dest_day_time   =>  l_NewStartDate
    );

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  to_number(r_Bookings.TimezoneID)
    , p_dest_tz_id      =>  p_TimezoneId
    , p_source_day_time =>  l_EndDate
    , x_dest_day_time   =>  l_NewEndDate
    );

    else

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  r_Bookings.TimezoneID
    , p_dest_tz_id      =>  to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'))
    , p_source_day_time =>  l_StartDate
    , x_dest_day_time   =>  l_NewStartDate
    );

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  r_Bookings.TimezoneID
    , p_dest_tz_id      =>  to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'))
    , p_source_day_time =>  l_EndDate
    , x_dest_day_time   =>  l_NewEndDate
    );

    end if;

     l_TempItemDisplayType := GetItemType
                           ( p_SourceCode      => r_Bookings.SourceObjectTypeCode
                           , p_PeriodStartDate => p_QueryStartDate
                           , p_PeriodEndDate   => p_QueryEndDate
                           , p_StartDate       => l_NewStartDate
                           , p_EndDate         => l_NewEndDate
                           , p_CalSpanDaysProfile => p_CalSpanDaysProfile
                           );

    IF  l_TempItemDisplayType <> 3 THEN
             r_Bookings.Startdate := l_NewStartDate;
             r_Bookings.Enddate := l_NewEndDate;
    END IF;

      IF ((p_QueryMode = 4) -- All tasks
       OR ((p_QueryMode <> 4)
          AND (l_TempItemDisplayType <> 2))) -- Filter tasks item type 2
    THEN

    --MultiDay span case
    l_TempStartDate   := r_Bookings.StartDate;
    l_TempEndDate     := r_Bookings.EndDate;
        l_ItemDisplayType := l_TempItemDisplayType;
    IF (l_TempItemDisplayType = 5)
    THEN
       l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
       l_ItemDisplayType := 1;


    END IF;

    WHILE (((l_TempEndDate <= r_Bookings.EndDate) AND
          (l_TempStartDate <= r_Bookings.EndDate)) OR
          (l_TempStartDate IS NULL) OR (l_TempEndDate IS NULL))
    LOOP
        /***************************************************************************
        ** Now that the StartDate and EndDate are corrected we need to check
        ** whether we want to display them
        ***************************************************************************/
       IF  (     (  l_TempStartDate <= p_QueryEndDate
                  OR l_TempStartDate IS NULL
                  )
            AND   (  l_TempEndDate  >=  p_QueryStartDate
                  OR l_TempEndDate IS NULL
                  )
            )
        THEN
            /*************************************************************************
            ** Store the task information in a PL/SQL table.
            *************************************************************************/
            x_index := x_index + 1;
            /***********************************************************************
            ** These items should be displayed on the Calendar or Memo, Todolist
            ** items are filtered unless query mode is combi
            ***********************************************************************/
            x_DisplayItems(x_index).ItemDisplayType := l_ItemDisplayType;
            x_DisplayItems(x_index).ItemSourceID    := r_Bookings.TaskId;
            x_DisplayItems(x_index).Location    :=  get_locations(r_Bookings.TaskId);
            x_DisplayItems(x_index).Attendees    :=  cac_view_acc_daily_view_pvt.get_attendees(r_Bookings.TaskId);
            x_DisplayItems(x_index).ItemSourceCode  :=  'BOOKING';
            x_DisplayItems(x_index).SourceObjectTypeCode  :=  r_Bookings.SourceObjectTypeCode;
            x_DisplayItems(x_index).ItemName := r_Bookings.ItemName;
            x_DisplayItems(x_index).AccessLevel := GET_ACCESS_LEVEL
                                                   ( 'BOOKING'
                                                   , r_Bookings.SourceObjectTypeCode
                                                   , p_LoggedOnRSID
                                                   , p_LoggedOnRSType
                                                   , p_QueryRSID
                                                   , p_QueryRSType
                                                   , r_Bookings.PrivateFlag
                                                   , p_QueryUserAccess
                                                   );

            x_DisplayItems(x_index).AssignmentStatus := r_Bookings.AssignmentStatus;
            --Find related items (references). Use "source" column to store the value
            x_DisplayItems(x_index).Source :=  r_Bookings.SOURCE_NAME || '-' || r_Bookings.SOURCE_INSTANCE;
            x_DisplayItems(x_index).TaskType :=  r_Bookings.TYPE_NAME;
            x_DisplayItems(x_index).Priority := r_Bookings.PRIORITY_NAME;
            x_DisplayItems(x_index).Status := r_Bookings.FREE_BUSY_STATUS;
            IF(r_Bookings.AssigneeRole <> 'OWNER') THEN
              x_DisplayItems(x_index).InviteIndicator := 1;
            ELSE
              x_DisplayItems(x_index).InviteIndicator := 0;
            END IF;
            IF(r_Bookings.RemindIndicator = 'Y' AND r_Bookings.AssigneeRole = 'OWNER') THEN
              x_DisplayItems(x_index).RemindIndicator := 1;
            ELSE
              x_DisplayItems(x_index).RemindIndicator := 0;
            END IF;
            x_DisplayItems(x_index).RepeatIndicator := r_Bookings.RepeatIndicator;
            x_DisplayItems(x_index).StartDate       := l_TempStartDate;
            x_DisplayItems(x_index).EndDate         := l_TempEndDate;
            x_DisplayItems(x_index).GroupRSID       := p_GroupRSID;

            -- Get Drilldown information
            l_objects_input.ENTITY           := 'BOOKING';
            l_objects_input.OBJECT_CODE      := r_Bookings.SourceObjectTypeCode;
            l_objects_input.SOURCE_OBJECT_ID := r_Bookings.SourceId;
            l_objects_input.TASK_ID := r_Bookings.TaskId;
            jtf_objects_pub.GET_DRILLDOWN_PAGE
            ( P_INPUT_REC      => l_objects_input
            , X_PG_FUNCTION    => x_DisplayItems(x_index).URL
            , X_PG_PARAMETERS  => x_DisplayItems(x_index).URLParamList
            );
        END IF;
        -- Increment the dates.
        IF (l_TempItemDisplayType = 5)
        THEN
           l_TempStartDate := TRUNC(l_TempStartDate) + 1;
           l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
           IF (l_TempEndDate > r_Bookings.EndDate)
           THEN
              l_TempEndDate := r_Bookings.EndDate;
           END IF;
           IF (l_TempStartDate >= r_Bookings.EndDate)
           THEN
              EXIT;
           END IF;
        ELSE
           EXIT;
        END IF;
    END LOOP;

    END IF; --Filter tasks 2

  END LOOP BOOKINGS;
END IF; -- end of IF (p_ShowBookings)

END GetBookings;

PROCEDURE GetApptsAndTasks
( p_LoggedOnRSID            IN  NUMBER
, p_LoggedOnRSType          IN  VARCHAR2
, p_QueryRSID            IN  NUMBER
, p_QueryRSType          IN  VARCHAR2
, p_QueryStartDate       IN  DATE
, p_QueryEndDate         IN  DATE
, p_QueryMode            IN  VARCHAR2
, p_CalSpanDaysProfile   IN  VARCHAR2
, p_GroupRSID            IN  VARCHAR2
, p_ShowApts             IN  CHAR
, p_ShowTasks            IN  CHAR
, p_ShowOpenInvite       IN  CHAR
, p_ShowDeclined         IN  CHAR
, p_AptFirstDetail       IN  CHAR
, p_AptSecondDetail      IN  CHAR
, p_AptThirdDetail       IN  CHAR
, p_ShowBusyTask         IN  CHAR
, p_ShowFreeTask         IN  CHAR
, p_ShowTentativeTask    IN  CHAR
, p_TaskFirstDetail      IN  CHAR
, p_TaskSecondDetail     IN  CHAR
, p_TaskThirdDetail      IN  CHAR
, p_TimezoneId     IN  NUMBER
, p_pers_cal             IN  VARCHAR2
, p_QueryUserAccess         IN  MENUS_TBL
, x_index                IN OUT NOCOPY    BINARY_INTEGER
, x_DisplayItems         IN OUT NOCOPY    CAC_VIEW_PVT.QueryOutTab
) IS

  l_TempStartDate       DATE;
  l_TempEndDate         DATE;
  l_TempItemDisplayType  NUMBER;
  l_ItemDisplayType      NUMBER;

  l_StartDate         DATE;
  l_EndDate         DATE;
  l_NewStartDate         DATE;
  l_NewEndDate         DATE;

  l_objects_input    jtf_objects_pub.PG_INPUT_REC;

  CURSOR c_Appointments
  /*****************************************************************************
  ** This cursor will only return Tasks/Appointments that need to be displayed
  ** in the page or is needed to derive that information
  *****************************************************************************/
  ( b_ResourceID   IN NUMBER
  , b_ResourceType IN VARCHAR2
  , b_StartDate    IN DATE  -- start of query period
  , b_EndDate      IN DATE  -- end of query period
  )IS SELECT jtb.task_id                      TaskId
      ,      jtb.source_object_type_code      SourceObjectTypeCode
      ,      jtb.source_object_id             SourceId
      ,      jtb.customer_id                  CustomerId
      ,      jtt.task_name                    ItemName
      ,      jtb.calendar_start_date          StartDate
      ,      jtb.calendar_end_date            EndDate
      ,      jtb.timezone_id                  TimezoneID
      ,      jtb.duration                     Duration    -- always in minutes
      ,      jtb.private_flag                 PrivateFlag -- needed to determin access level
      ,      jta.assignment_status_id         AssignmentStatus
      ,      jtb.alarm_on                     RemindIndicator
      ,      DECODE(jtb.recurrence_rule_id
                   ,NULL,0
                   ,1
                   )          RepeatIndicator
      ,      jta.assignee_role                AssigneeRole
      ,      jta.free_busy_type               free_busy_type
      FROM jtf_task_all_assignments   jta
      ,    jtf_tasks_b            jtb
      ,    jtf_tasks_tl           jtt
      ,    jtf_task_statuses_b    jtsb
      WHERE jta.resource_id          = b_ResourceID        -- 101272224
      AND   jta.resource_type_code   = b_ResourceType      -- 'RS_EMPLOYEE'
      AND   jta.task_id              = jtb.task_id         -- join to tasks_b
      AND   jtb.task_status_id       = jtsb.task_status_id -- join to task_status_b
      AND   jtb.task_id              = jtt.task_id         -- join to tasks_tl
      AND   jtt.LANGUAGE             = USERENV('LANG')     -- join to tasks_tl
      AND   jta.show_on_calendar     = 'Y'
      AND  (p_ShowDeclined = 'Y' AND (jta.assignment_status_id IN (3,4,18))
         OR (p_ShowDeclined = 'N' AND jta.assignment_status_id IN (3,18)))
      AND  (p_ShowOpenInvite = 'Y' AND (jta.assignment_status_id IN (3,4,18))
         OR (p_ShowOpenInvite = 'N' AND jta.assignment_status_id IN (3,4)))
      AND   NVL(jtb.deleted_flag,'N')<> 'Y'
      AND   (   jtb.calendar_start_date <= b_EndDate
            OR  jtb.calendar_start_date IS NULL
            )
      AND   (   jtb.calendar_end_date   >=  b_StartDate
            OR  jtb.calendar_end_date IS NULL
            )
      AND jtb.entity = 'APPOINTMENT'
      AND jtb.source_object_type_code <> 'EXTERNAL APPOINTMENT'
      ;
--
  /*CURSOR c_Tasks
  /*****************************************************************************
  ** This cursor will only return Tasks/Appointments that need to be displayed
  ** in the page or is needed to derive that information
  *****************************************************************************/
  /*( b_ResourceID   IN NUMBER
  , b_ResourceType IN VARCHAR2
  , b_StartDate    IN DATE  -- start of query period
  , b_EndDate      IN DATE  -- end of query period
  )IS SELECT jtb.task_id                      TaskId
      ,      jtb.source_object_type_code      SourceObjectTypeCode
      ,      jtb.source_object_id             SourceId
      ,      jtb.customer_id                  CustomerId
      ,      jtt.task_name                    ItemName
      ,      jtb.calendar_start_date          StartDate
      ,      jtb.calendar_end_date            EndDate
      ,      jtb.timezone_id                  TimezoneID
      ,      jtb.duration                     Duration    -- always in minutes
      ,      jtb.private_flag                 PrivateFlag -- needed to determin access level
      ,      DECODE(jtb.recurrence_rule_id
                   ,NULL,0
                   ,1
                   )          RepeatIndicator
      ,      jta.assignee_role                AssigneeRole
      FROM jtf_task_all_assignments   jta
      ,    jtf_tasks_b            jtb
      ,    jtf_tasks_tl           jtt
      ,    jtf_task_statuses_b    jtsb
      WHERE jta.resource_id          = b_ResourceID        -- 101272224
      AND   jta.resource_type_code   = b_ResourceType      -- 'RS_EMPLOYEE'
      AND   jta.task_id              = jtb.task_id         -- join to tasks_b
      AND   jtb.task_status_id       = jtsb.task_status_id -- join to task_status_b
      AND   jtb.task_id              = jtt.task_id         -- join to tasks_tl
      AND   jtt.LANGUAGE             = USERENV('LANG')     -- join to tasks_tl
      AND   jta.show_on_calendar     = 'Y'
      AND   jta.assignment_status_id <> 4 -- using status rejected for declined
      AND   NVL(jtsb.closed_flag,'N')<> 'Y'
      AND   NVL(jtb.deleted_flag,'N')<> 'Y'
      AND   (   jtb.calendar_start_date <= b_EndDate
            OR  jtb.calendar_start_date IS NULL
            )
      AND   (   jtb.calendar_end_date   >=  b_StartDate
            OR  jtb.calendar_end_date IS NULL
            )
      AND jtb.source_object_type_code <> 'APPOINTMENT'
      ;*/

  CURSOR c_Tasks
  (
    b_ResourceId   IN NUMBER
  , b_ResourceType IN VARCHAR2
  , b_StartDate    IN DATE  -- start of query period
  , b_EndDate      IN DATE  -- end of query period
  )
  IS
  SELECT /*+ first_rows */ task_view.TASK_ID,
       assignment.TASK_ASSIGNMENT_ID,
       assignment.ASSIGNEE_ROLE,
       task_status.NAME AS STATUS_NAME,
       assign_status.NAME AS ASSIGN_STATUS_NAME,
       task_type.NAME AS TYPE_NAME,
       task_priority.NAME AS PRIORITY_NAME,
       task_view.TASK_NAME,
       --task_view.CALENDAR_START_DATE,
       --task_view.CALENDAR_END_DATE,
       assignment.BOOKING_START_DATE CALENDAR_START_DATE,
       assignment.BOOKING_END_DATE CALENDAR_END_DATE,
       task_view.SOURCE_OBJECT_TYPE_CODE,
       task_view.SOURCE_OBJECT_ID,
       task_view.CUSTOMER_ID,
       task_view.TASK_CONFIRMATION_STATUS,
       DECODE(task_view.recurrence_rule_id
                   ,NULL,0
                   ,1
                   )          RepeatIndicator,
       task_view.TIMEZONE_ID,
       task_view.OWNER_ID,
       task_view.OWNER_TYPE_CODE,
       owner.SOURCE_NAME AS OWNER,
       party.PARTY_NAME AS CUSTOMER_NAME,
       location.CITY,
       task_view.PRIVATE_FLAG,
       task_view.DESCRIPTION,
       jtf_object.name AS SOURCE_NAME,
       jtf_task_utl.get_owner(task_view.SOURCE_OBJECT_TYPE_CODE, task_view.SOURCE_OBJECT_ID) AS SOURCE_INSTANCE,
       assignment.free_busy_type free_busy_type
   FROM
     jtf_tasks_vl task_view,
     jtf_task_statuses_tl task_status,
     jtf_task_statuses_vl assign_status,
     jtf_task_types_tl task_type,
     jtf_task_priorities_tl task_priority,
     hz_parties party,
     hz_party_sites site,
     hz_locations location,
     jtf_rs_resource_extns owner,
     jtf_task_all_assignments assignment,
     jtf_objects_tl jtf_object
  WHERE
        assignment.resource_id = b_ResourceId --13475
        AND assignment.resource_type_code = b_ResourceType --'RS_EMPLOYEE'
        AND assignment.task_id = task_view.task_id
    AND task_view.entity = 'TASK'
        AND task_view.task_type_id <> 22                        -- not escalations
        AND (NVL(task_view.deleted_flag,'N') = 'N')             -- not deleted
        AND (NVL(assignment.show_on_calendar,'Y') = 'Y')        -- for backward compatibility
        AND assignment.booking_start_date <= b_EndDate --sysdate + 5*360     --start date
        AND assignment.booking_end_date   >=  b_StartDate --sysdate - 5*360    --end date
        AND task_view.task_type_id = task_type.task_type_id            -- type
        AND task_type.language = userenv('LANG')
        AND task_view.task_status_id = task_status.task_status_id        -- task status
        AND task_status.language = userenv('LANG')
        AND assignment.assignment_status_id = assign_status.task_status_id  -- assignment status
        AND NVL(assign_status.cancelled_flag, 'N') <>'Y'                             -- not cancelled
    AND task_view.task_priority_id = task_priority.task_priority_id       --priority
        AND task_priority.language = userenv('LANG')
        AND task_view.customer_id = party.party_id(+)              --customer
        AND task_view.address_id = site.party_site_id(+)           --task location
        AND site.location_id = location.location_id(+)
        AND task_view.source_object_type_code = jtf_object.object_code    --source
        AND jtf_object.language = userenv('LANG')
        AND task_view.owner_id = owner.resource_id  --owner
        AND task_view.owner_type_code = 'RS_' || owner.category
    AND assignment.ASSIGNEE_ROLE= decode (1, (select count(task_assignment_id)
                           from jtf_task_all_assignments
                           where task_id=task_view.task_id
                           and resource_id = b_ResourceId
                           and resource_type_code=b_ResourceType),
                           assignment.ASSIGNEE_ROLE,'ASSIGNEE')
       AND assignment.free_busy_type <> 'FREE' ;

--

BEGIN
 IF (p_ShowApts ='Y') THEN
  IF (c_Appointments%ISOPEN)
  THEN
    CLOSE c_Appointments; -- Make sure the cursor is closed
  END IF;
  FOR r_PersonalApt IN c_Appointments( p_QueryRSID
                               , p_QueryRSType
                               , p_QueryStartDate - 1 -- allow for max timezone correction
                               , p_QueryEndDate   + 1 -- allow for max timezone correction
                               )
  LOOP <<PERSONAL_APTS>>
    /***************************************************************************
    ** We will have to adjust the Start/End Date for the users timezone
    ***************************************************************************/
    l_StartDate  := r_PersonalApt.StartDate;
    l_EndDate  := r_PersonalApt.EndDate;

    if p_TimezoneId is not null
    then
    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  to_number(r_PersonalApt.TimezoneID)
    , p_dest_tz_id      =>  p_TimezoneId
    , p_source_day_time =>  l_StartDate
    , x_dest_day_time   =>  l_NewStartDate
    );

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  to_number(r_PersonalApt.TimezoneID)
    , p_dest_tz_id      =>  p_TimezoneId
    , p_source_day_time =>  l_EndDate
    , x_dest_day_time   =>  l_NewEndDate
    );

    else
    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  r_PersonalApt.TimezoneID
    , p_dest_tz_id      =>  to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'))
    , p_source_day_time =>  l_StartDate
    , x_dest_day_time   =>  l_NewStartDate
    );

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  r_PersonalApt.TimezoneID
    , p_dest_tz_id      =>  to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'))
    , p_source_day_time =>  l_EndDate
    , x_dest_day_time   =>  l_NewEndDate
    );

    end if;

     l_TempItemDisplayType := GetItemType
                           ( p_SourceCode      => r_PersonalApt.SourceObjectTypeCode
                           , p_PeriodStartDate => p_QueryStartDate
                           , p_PeriodEndDate   => p_QueryEndDate
                           , p_StartDate       => l_NewStartDate
                           , p_EndDate         => l_NewEndDate
                           , p_CalSpanDaysProfile => p_CalSpanDaysProfile
                           );




    IF  l_TempItemDisplayType <> 3 THEN
             r_PersonalApt.Startdate := l_NewStartDate;
             r_PersonalApt.Enddate := l_NewEndDate;
    END IF;



    IF ((p_QueryMode = 4) -- All tasks
       OR ((p_QueryMode <> 4)
          AND (l_TempItemDisplayType <> 2))) -- Filter tasks item type 2
    THEN

    --MultiDay span case
    l_TempStartDate   := r_PersonalApt.StartDate;
    l_TempEndDate     := r_PersonalApt.EndDate;
    l_ItemDisplayType := l_TempItemDisplayType;
    IF (l_TempItemDisplayType = 5)
    THEN
       l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
       l_ItemDisplayType := 1;


    END IF;

    WHILE (((l_TempEndDate <= r_PersonalApt.EndDate) AND
          (l_TempStartDate <= r_PersonalApt.EndDate)) OR
          (l_TempStartDate IS NULL) OR (l_TempEndDate IS NULL))
    LOOP
        /***************************************************************************
        ** Now that the StartDate and EndDate are corrected we need to check
        ** whether we want to display them
        ***************************************************************************/
       IF  (     (  l_TempStartDate <= p_QueryEndDate
                  OR l_TempStartDate IS NULL
                  )
            AND   (  l_TempEndDate  >=  p_QueryStartDate
                  OR l_TempEndDate IS NULL
                  )
            )
        THEN
            /*************************************************************************
            ** Store the task information in a PL/SQL table.
            *************************************************************************/
            x_index := x_index + 1;
            /***********************************************************************
            ** These items should be displayed on the Calendar or Memo, Todolist
            ** items are filtered unless query mode is combi
            ***********************************************************************/
            x_DisplayItems(x_index).ItemDisplayType := l_ItemDisplayType;
            x_DisplayItems(x_index).ItemSourceID    := r_PersonalApt.TaskId;
            x_DisplayItems(x_index).Location    :=  get_locations(r_PersonalApt.TaskId);
            x_DisplayItems(x_index).Attendees    :=  cac_view_acc_daily_view_pvt.get_attendees(r_PersonalApt.TaskId);
            x_DisplayItems(x_index).ItemSourceCode  :=  'APPOINTMENT';
            x_DisplayItems(x_index).SourceObjectTypeCode  :=  r_PersonalApt.SourceObjectTypeCode;
            x_DisplayItems(x_index).ItemName := r_PersonalApt.ItemName;
            x_DisplayItems(x_index).AccessLevel := GET_ACCESS_LEVEL
                                                   ( 'APPOINTMENT'
                                                   , r_PersonalApt.SourceObjectTypeCode
                                                   , p_LoggedOnRSID
                                                   , p_LoggedOnRSType
                                                   , p_QueryRSID
                                                   , p_QueryRSType
                                                   , r_PersonalApt.PrivateFlag
                                                   , p_QueryUserAccess
                                                   );

            x_DisplayItems(x_index).AssignmentStatus := r_PersonalApt.AssignmentStatus;
            --Find related items (references). Use "source" column to store the value
            x_DisplayItems(x_index).Source :=  cac_view_acc_daily_view_pvt.get_related_items(r_PersonalApt.TaskId);
            IF(r_PersonalApt.AssigneeRole <> 'OWNER') THEN
              x_DisplayItems(x_index).InviteIndicator := 1;
            ELSE
              x_DisplayItems(x_index).InviteIndicator := 0;
            END IF;
            IF(r_PersonalApt.RemindIndicator = 'Y' AND r_PersonalApt.AssigneeRole = 'OWNER') THEN
              x_DisplayItems(x_index).RemindIndicator := 1;
            ELSE
              x_DisplayItems(x_index).RemindIndicator := 0;
            END IF;
            x_DisplayItems(x_index).RepeatIndicator := r_PersonalApt.RepeatIndicator;
            x_DisplayItems(x_index).StartDate       := l_TempStartDate;
            x_DisplayItems(x_index).EndDate         := l_TempEndDate;
            x_DisplayItems(x_index).GroupRSID := p_GroupRSID;
            x_DisplayItems(x_index).FreeBusyType := r_PersonalApt.free_busy_type;

            -- Get Drilldown information
            l_objects_input.ENTITY           := 'APPOINTMENT';
            l_objects_input.OBJECT_CODE      := r_PersonalApt.SourceObjectTypeCode;
            l_objects_input.SOURCE_OBJECT_ID := r_PersonalApt.SourceId;
            l_objects_input.TASK_ID          := r_PersonalApt.TaskId;
            jtf_objects_pub.GET_DRILLDOWN_PAGE
            ( P_INPUT_REC      => l_objects_input
            , X_PG_FUNCTION    => x_DisplayItems(x_index).URL
            , X_PG_PARAMETERS  => x_DisplayItems(x_index).URLParamList
            );
        END IF;
        -- Increment the dates.
        IF (l_TempItemDisplayType = 5)
        THEN
           l_TempStartDate := TRUNC(l_TempStartDate) + 1;
           l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
           IF (l_TempEndDate > r_PersonalApt.EndDate)
           THEN
              l_TempEndDate := r_PersonalApt.EndDate;
           END IF;
           IF (l_TempStartDate >= r_PersonalApt.EndDate)
           THEN
              EXIT;
           END IF;
        ELSE
           EXIT;
        END IF;
    END LOOP;

    END IF; --Filter tasks 2

  END LOOP PERSONAL_APTS;
END IF; -- end of IF (p_ShowApts)
--
IF (p_ShowTasks ='Y') THEN
  IF (c_Tasks%ISOPEN)
  THEN
    CLOSE c_Tasks; -- Make sure the cursor is closed
  END IF;
  FOR r_PersonalTask IN c_Tasks( p_QueryRSID
                               , p_QueryRSType
                               , p_QueryStartDate - 1 -- allow for max timezone correction
                               , p_QueryEndDate   + 1 -- allow for max timezone correction
                               )
  LOOP <<PERSONAL_TASKS>>
    /***************************************************************************
    ** We will have to adjust the Start/End Date for the users timezone
    ***************************************************************************/
    l_StartDate  := r_PersonalTask.CALENDAR_START_DATE;
    l_EndDate  := r_PersonalTask.CALENDAR_END_DATE;

     if p_TimezoneId is not null
    then
    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  to_number(r_PersonalTask.TIMEZONE_ID)
    , p_dest_tz_id      =>  p_TimezoneId
    , p_source_day_time =>  l_StartDate
    , x_dest_day_time   =>  l_NewStartDate
    );

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  to_number(r_PersonalTask.TIMEZONE_ID)
    , p_dest_tz_id      =>  p_TimezoneId
    , p_source_day_time =>  l_EndDate
    , x_dest_day_time   =>  l_NewEndDate
    );

    else
    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  r_PersonalTask.TIMEZONE_ID
    , p_dest_tz_id      =>  to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'))
    , p_source_day_time =>  l_StartDate
    , x_dest_day_time   =>  l_NewStartDate
    );

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  r_PersonalTask.TIMEZONE_ID
    , p_dest_tz_id      =>  to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'))
    , p_source_day_time =>  l_EndDate
    , x_dest_day_time   =>  l_NewEndDate
    );

    end if;


    l_TempItemDisplayType := GetItemType
                           ( p_SourceCode      => r_PersonalTask.SOURCE_OBJECT_TYPE_CODE
                           , p_PeriodStartDate => p_QueryStartDate
                           , p_PeriodEndDate   => p_QueryEndDate
                           , p_StartDate       => l_NewStartDate
                           , p_EndDate         => l_NewEndDate
                           , p_CalSpanDaysProfile => p_CalSpanDaysProfile
                           );


    IF  l_TempItemDisplayType <> 3 THEN
             r_PersonalTask.CALENDAR_START_DATE := l_NewStartDate;
             r_PersonalTask.CALENDAR_END_DATE := l_NewEndDate;
    END IF;



    IF ((p_QueryMode = 4) -- All tasks
       OR ((p_QueryMode <> 4)
          AND (l_TempItemDisplayType <> 2))) -- Filter tasks item type 2
    THEN

    --MultiDay span case
    l_TempStartDate   := r_PersonalTask.CALENDAR_START_DATE;
    l_TempEndDate     := r_PersonalTask.CALENDAR_END_DATE;
    l_ItemDisplayType := l_TempItemDisplayType;
    IF (l_TempItemDisplayType = 5)
    THEN
       l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
       IF (r_PersonalTask.SOURCE_OBJECT_TYPE_CODE ='APPOINTMENT')  THEN
         l_ItemDisplayType := 1;
       ELSE
         l_ItemDisplayType := 3; -- show such tasks as all day
       END IF;

    END IF;


    WHILE (((l_TempEndDate <= r_PersonalTask.CALENDAR_END_DATE) AND
          (l_TempStartDate <= r_PersonalTask.CALENDAR_END_DATE)) OR
          (l_TempStartDate IS NULL) OR (l_TempEndDate IS NULL))
    LOOP
        /***************************************************************************
        ** Now that the StartDate and EndDate are corrected we need to check
        ** whether we want to display them
        ***************************************************************************/
        IF  (     (  l_TempStartDate <= p_QueryEndDate
                  OR l_TempStartDate IS NULL
                  )
            AND   (  l_TempEndDate  >=  p_QueryStartDate
                  OR l_TempEndDate IS NULL
                  )
            )
        THEN
            /*************************************************************************
            ** Store the task information in a PL/SQL table.
            *************************************************************************/
            x_index := x_index + 1;
            /***********************************************************************
            ** These items should be displayed on the Calendar;
            ** items are filtered unless query mode is combi
            ***********************************************************************/
            x_DisplayItems(x_index).ItemDisplayType := l_ItemDisplayType;
            x_DisplayItems(x_index).ItemSourceID    := r_PersonalTask.TASK_ID;
            x_DisplayItems(x_index).ItemSourceCode  :=  'TASK';
            x_DisplayItems(x_index).SourceObjectTypeCode  :=  r_PersonalTask.SOURCE_OBJECT_TYPE_CODE;
            x_DisplayItems(x_index).ItemName := r_PersonalTask.TASK_NAME;
            x_DisplayItems(x_index).AccessLevel := GET_ACCESS_LEVEL
                                                   ( 'TASK'
                                                   , r_PersonalTask.SOURCE_OBJECT_TYPE_CODE
                                                   , p_LoggedOnRSID
                                                   , p_LoggedOnRSType
                                                   , p_QueryRSID
                                                   , p_QueryRSType
                                                   , r_PersonalTask.Private_Flag
                                                   , p_QueryUserAccess
                                                   );
            x_DisplayItems(x_index).RepeatIndicator := r_PersonalTask.RepeatIndicator;
            x_DisplayItems(x_index).RemindIndicator := 0;
            x_DisplayItems(x_index).InviteIndicator := 0;
            x_DisplayItems(x_index).StartDate       := l_TempStartDate;
            x_DisplayItems(x_index).EndDate         := l_TempEndDate;
            x_DisplayItems(x_index).GroupRSID := p_GroupRSID;
            x_DisplayItems(x_index).FreeBusyType := r_PersonalTask.free_busy_type;
            -- The following fields are optional, check whether they match
            -- First, Second or Third Detail task preferences
            IF (p_TaskFirstDetail = '1' OR p_TaskSecondDetail = '1'
              OR p_TaskThirdDetail = '1') THEN
              x_DisplayItems(x_index).Attendees       :=  cac_view_acc_daily_view_pvt.get_attendees(r_PersonalTask.TASK_ID);
            END IF;
            IF (p_TaskFirstDetail = '2' OR p_TaskSecondDetail = '2'
              OR p_TaskThirdDetail = '2') THEN
              x_DisplayItems(x_index).source := r_PersonalTask.SOURCE_NAME || '-' ||
                 r_PersonalTask.SOURCE_INSTANCE;
            END IF;
            IF (p_TaskFirstDetail = '3' OR p_TaskSecondDetail = '3'
              OR p_TaskThirdDetail = '3') THEN
              x_DisplayItems(x_index).customer := r_PersonalTask.CUSTOMER_NAME;
            END IF;
            IF (p_TaskFirstDetail = '4' OR p_TaskSecondDetail = '4'
              OR p_TaskThirdDetail = '4') THEN
              x_DisplayItems(x_index).CustomerConfirmation := r_PersonalTask.TASK_CONFIRMATION_STATUS;
              NULL;
            END IF;
            IF (p_TaskFirstDetail = '5' OR p_TaskSecondDetail = '5'
              OR p_TaskThirdDetail = '5') THEN
              x_DisplayItems(x_index).Status := r_PersonalTask.STATUS_NAME;
            END IF;
            IF (p_TaskFirstDetail = '6' OR p_TaskSecondDetail = '6'
              OR p_TaskThirdDetail = '6') THEN
              x_DisplayItems(x_index).AssigneeStatus := r_PersonalTask.ASSIGN_STATUS_NAME;
            END IF;
            IF (p_TaskFirstDetail = '7' OR p_TaskSecondDetail = '7'
              OR p_TaskThirdDetail = '7') THEN
              x_DisplayItems(x_index).Priority := r_PersonalTask.PRIORITY_NAME;
            END IF;
            IF (p_TaskFirstDetail = '8' OR p_TaskSecondDetail = '8'
              OR p_TaskThirdDetail = '8') THEN
            x_DisplayItems(x_index).TaskType := r_PersonalTask.TYPE_NAME;
            END IF;
            IF (p_TaskFirstDetail = '9' OR p_TaskSecondDetail = '9'
              OR p_TaskThirdDetail = '9') THEN
              x_DisplayItems(x_index).Description := r_PersonalTask.DESCRIPTION;
            END IF;
            IF (p_TaskFirstDetail = '10' OR p_TaskSecondDetail = '10'
              OR p_TaskThirdDetail = '10') THEN
              x_DisplayItems(x_index).Owner := r_PersonalTask.OWNER;
            END IF;
            IF (p_TaskFirstDetail = '11' OR p_TaskSecondDetail = '11'
              OR p_TaskThirdDetail = '11') THEN
              x_DisplayItems(x_index).Location := r_PersonalTask.CITY;
            END IF;

            -- Get Drilldown information
            l_objects_input.ENTITY             := 'TASK';
            l_objects_input.OBJECT_CODE        := r_PersonalTask.SOURCE_OBJECT_TYPE_CODE;
            l_objects_input.SOURCE_OBJECT_ID   := r_PersonalTask.SOURCE_OBJECT_ID;
            l_objects_input.TASK_ASSIGNMENT_ID := r_PersonalTask.TASK_ASSIGNMENT_ID;
            l_objects_input.TASK_ID            := r_PersonalTask.TASK_ID;
	     --Bug 5228719 Initialize JTF Objects cache
	    jtf_objects_pub.INITIALIZE_CACHE;
            jtf_objects_pub.GET_DRILLDOWN_PAGE
            ( P_INPUT_REC      => l_objects_input
            , X_PG_FUNCTION    => x_DisplayItems(x_index).URL
            , X_PG_PARAMETERS  => x_DisplayItems(x_index).URLParamList
            );
        END IF;
       -- Increment the dates.
        IF (l_TempItemDisplayType = 5)
        THEN
           l_TempStartDate := TRUNC(l_TempStartDate) + 1;
           l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
           IF (l_TempEndDate > r_PersonalTask.CALENDAR_END_DATE)
           THEN
              l_TempEndDate := r_PersonalTask.CALENDAR_END_DATE;
           END IF;
           IF (l_TempStartDate >= r_PersonalTask.CALENDAR_END_DATE)
           THEN
              EXIT;
           END IF;
        ELSE
           EXIT;
        END IF;
    END LOOP;
    END IF; --Filter tasks 2

  END LOOP PERSONAL_TASKS;
END IF; -- end of IF (p_ShowTasks)

--

END GetApptsAndTasks;

PROCEDURE GetItems
/*******************************************************************************
** This procedure will return Marketing Calendar Items
*******************************************************************************/
( p_LoggedOnRSID            IN  NUMBER
, p_LoggedOnRSType          IN  VARCHAR2
, p_QueryRSID            IN  NUMBER
, p_QueryRSType          IN  VARCHAR2
, p_QueryStartDate       IN  DATE
, p_QueryEndDate         IN  DATE
, p_QueryMode            IN  VARCHAR2
, p_TimezoneId           IN  NUMBER
, p_CalSpanDaysProfile   IN  VARCHAR2
, p_GroupRSID            IN  VARCHAR2
, x_index                IN OUT NOCOPY    BINARY_INTEGER
, x_DisplayItems         IN OUT NOCOPY    CAC_VIEW_PVT.QueryOutTab
) IS

CURSOR c_Items
  /*****************************************************************************
  ** This Cursor will fetch all Calendar Items related to a Resource
  *****************************************************************************/
  ( b_ResourceID   IN NUMBER
  , b_ResourceType IN VARCHAR2
  , b_StartDate    IN DATE
  , b_EndDate      IN DATE
  )IS SELECT DISTINCT jtb.source_id ItemSourceID
      ,      jtb.cal_item_id        CalItemId
      ,      jtb.source_code        SourceCode
      ,      jtb.source_id          SourceID
      ,      jtb.start_date         StartDate
      ,      jtb.end_date           EndDate
      ,      jtb.timezone_id        TimezoneID
      FROM  jtf_cal_items_b   jtb
      WHERE(   jtb.start_date <= b_EndDate
            )
      AND   (   jtb.end_date   >=  b_StartDate
            )
      AND jtb.resource_type = 'RS_GROUP'
      AND jtb.resource_id IN --select groups that user is member of
      (SELECT mem.group_id
      FROM
         jtf_rs_group_members mem,
         jtf_rs_group_usages  rgu
      WHERE mem.resource_id = b_ResourceID
        AND nvl(mem.delete_flag, 'N') <> 'Y'
        AND   rgu.group_id = mem.group_id
        AND   rgu.usage =  'CALENDAR_ITEMS')
    UNION -- individual items
     SELECT jtb.source_id          ItemSourceID
      ,      jtb.cal_item_id        CalItemId
      ,      jtb.source_code        SourceCode
      ,      jtb.source_id          SourceID
      ,      jtb.start_date         StartDate
      ,      jtb.end_date           EndDate
      ,      jtb.timezone_id        TimezoneID
      FROM  jtf_cal_items_b   jtb
       WHERE jtb.resource_id   = b_ResourceID
       AND   jtb.resource_type = 'RS_EMPLOYEE'
       AND  (   jtb.start_date <= b_EndDate
            )
       AND  (   jtb.end_date   >=  b_StartDate
            )
      ;
  l_TempStartDate       DATE;
  l_TempEndDate         DATE;
  l_TempItemDisplayType  NUMBER;
  l_ItemDisplayType      NUMBER;
  l_StartDate            DATE;
  l_EndDate              DATE;
  l_NewStartDate            DATE;
  l_NewEndDate              DATE;
  l_item_name            VARCHAR2(2000);

  l_objects_input    jtf_objects_pub.PG_INPUT_REC;

BEGIN
  /*****************************************************************************
  ** Now we need to get all the Calendar Items for this Employee Resource.
  *****************************************************************************/
  IF (c_Items%ISOPEN)
  THEN
    CLOSE c_Items; -- Make sure the cursor is closed
  END IF;
  FOR r_PersonalItem IN c_Items( p_QueryRSID
                               , p_QueryRSType
                               , p_QueryStartDate - 1 -- allow for max timezone adjustment
                               , p_QueryEndDate   + 1 -- allow for max timezone adjustment
                               )


  LOOP <<PERSONAL_ITEMS>>
    /***************************************************************************
    ** We will have to adjust the Start/End Date for the users timezone
    ***************************************************************************/
    --Added by jawang on 11/21/2002 to fix the NOCOPY issue
    l_StartDate := r_PersonalItem .Startdate;
    l_EndDate := r_PersonalItem .Enddate;

    if p_TimezoneId is not null
    then
    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  TO_NUMBER(r_PersonalItem .TimezoneID)
    , p_dest_tz_id      =>  p_TimezoneId
    , p_source_day_time =>  l_StartDate
    , x_dest_day_time   =>  l_NewStartDate
    );

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  TO_NUMBER(r_PersonalItem .TimezoneID)
    , p_dest_tz_id      =>  p_TimezoneId
    , p_source_day_time =>  l_EndDate
    , x_dest_day_time   =>  l_NewEndDate
    );
    else
    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  r_PersonalItem .TimezoneID
    , p_dest_tz_id      =>  TO_NUMBER(NVL(Fnd_Profile.Value('CLIENT_TIMEZONE_ID'),'4'))
    , p_source_day_time =>  l_StartDate
    , x_dest_day_time   =>  l_NewStartDate
    );

    CAC_VIEW_UTIL_PVT.AdjustForTimezone
    ( p_source_tz_id    =>  r_PersonalItem .TimezoneID
    , p_dest_tz_id      =>  TO_NUMBER(NVL(Fnd_Profile.Value('CLIENT_TIMEZONE_ID'),'4'))
    , p_source_day_time =>  l_EndDate
    , x_dest_day_time   =>  l_NewEndDate
    );

    end if;

    l_TempItemDisplayType := GetItemType
                           ( p_SourceCode      => 'CALENDARITEM'
                           , p_PeriodStartDate => p_QueryStartDate
                           , p_PeriodEndDate   => p_QueryEndDate
                           , p_StartDate       => l_NewStartDate
                           , p_EndDate         => l_NewEndDate
                           , p_CalSpanDaysProfile => p_CalSpanDaysProfile
                           );

     IF  l_TempItemDisplayType <> 3 THEN
             r_PersonalItem.Startdate := l_NewStartDate;
             r_PersonalItem.Enddate := l_NewEndDate;
     END IF;

    IF ((p_QueryMode = 4)
       OR ((p_QueryMode <> 4)
          AND (l_TempItemDisplayType <> 2)))
    THEN

--MultiDay span case
    l_TempStartDate   := r_PersonalItem.StartDate;
    l_TempEndDate     := r_PersonalItem.EndDate;
    l_ItemDisplayType := l_TempItemDisplayType;
    IF (l_TempItemDisplayType = 5)
    THEN
       l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
       l_ItemDisplayType := 1;
    END IF;

    WHILE (((l_TempEndDate <= r_PersonalItem.EndDate) AND
          (l_TempStartDate <= r_PersonalItem.EndDate)) OR
          (l_TempStartDate IS NULL) OR (l_TempEndDate IS NULL))
    LOOP
       /***************************************************************************
        ** Now that the StartDate and EndDate are corrected we need to check whether
        ** we want to display them
        ***************************************************************************/
        IF  (     NVL(l_TempStartDate,TRUNC(SYSDATE)) <= p_QueryEndDate
            AND   NVL(l_TempEndDate,TRUNC(SYSDATE))   >=  p_QueryStartDate
            )
        THEN
          x_index := x_index + 1;

          x_DisplayItems(x_index).ItemDisplayType   := l_ItemDisplayType;
          x_DisplayItems(x_index).ItemSourceID      := r_PersonalItem.ItemSourceID;
          IF(r_PersonalItem.SourceCode IS NOT NULL
            AND r_PersonalItem.SourceId IS NOT NULL )THEN
            x_DisplayItems(x_index).ItemName            := JTF_TASK_UTL.get_owner(r_PersonalItem.SourceCode, r_PersonalItem.SourceId);
          END IF;
          x_DisplayItems(x_index).AccessLevel       := 1;
          x_DisplayItems(x_index).StartDate         := l_TempStartDate;
          x_DisplayItems(x_index).EndDate           := l_TempEndDate;
          x_DisplayItems(x_index).ItemSourceCode    := 'CALENDARITEM';
          x_DisplayItems(x_index).GroupRSID         := p_GroupRSID;
          x_DisplayItems(x_index).AssignmentStatus  := 0;
          x_DisplayItems(x_index).InviteIndicator   := 0;
          x_DisplayItems(x_index).RepeatIndicator   := 0;
          x_DisplayItems(x_index).RemindIndicator   := 0;

          -- Get Drilldown information
          l_objects_input.ENTITY             := 'CALENDARITEM';
          l_objects_input.OBJECT_CODE        := r_PersonalItem.SourceCode;
          l_objects_input.SOURCE_OBJECT_ID   := r_PersonalItem.SourceId;
          l_objects_input.CAL_ITEM_ID        := r_PersonalItem.CalItemId;
          jtf_objects_pub.GET_DRILLDOWN_PAGE
          ( P_INPUT_REC      => l_objects_input
          , X_PG_FUNCTION    => x_DisplayItems(x_index).URL
          , X_PG_PARAMETERS  => x_DisplayItems(x_index).URLParamList
          );
        END IF;
        -- Increment the dates.
        IF (l_TempItemDisplayType = 5)
        THEN
           l_TempStartDate := TRUNC(l_TempStartDate) + 1;
           l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
           IF (l_TempEndDate > r_PersonalItem.EndDate)
           THEN
              l_TempEndDate := r_PersonalItem.EndDate;
           END IF;
           IF (l_TempStartDate >= r_PersonalItem.EndDate)
           THEN
              EXIT;
           END IF;
        ELSE
           EXIT;
         END IF;
     END LOOP;
 END IF;
 END LOOP PERSONAL_ITEMS;
END GetItems;

PROCEDURE GET_CAL_EVENTS
( p_object_type IN     VARCHAR2
, p_object_id   IN     NUMBER
, p_start_date  IN     DATE
, p_end_date    IN     DATE
, x_items       IN OUT NOCOPY   CAC_VIEW_PVT.QueryOutTab
)
IS
   l_hrcal    CAC_HR_CAL_EVENTS_PVT.HR_CAL_EVENT_TBL_TYPE;
   l_index    NUMBER;
   l_objects_input    jtf_objects_pub.PG_INPUT_REC;

BEGIN
   l_index := x_items.count;

   CAC_HR_CAL_EVENTS_PVT.GET_HR_CAL_EVENTS
   (p_object_type   => p_object_type,
    p_object_id     => p_object_id,
    p_start_date    => p_start_date,
    p_end_date      => p_end_date,
    p_event_type    => NULL,
    p_event_id      => NULL,
    x_hr_cal_events => l_hrcal
   );

   IF l_hrcal.count > 0 THEN
      FOR i IN l_hrcal.first..l_hrcal.last
      LOOP
        x_items(l_index).ItemDisplayType := 6;
        x_items(l_index).ItemSourceCode  := 'HR_CAL_EVENT';
        x_items(l_index).ItemSourceID    := l_hrcal(i).cal_event_id;
        x_items(l_index).StartDate       := l_hrcal(i).start_date_time;
        x_items(l_index).EndDate         := l_hrcal(i).end_date_time;
        x_items(l_index).ItemName        := l_hrcal(i).event_name;
        x_items(l_index).AssignmentStatus:= 0;
        x_items(l_index).InviteIndicator := 0;
        x_items(l_index).RepeatIndicator := 0;
        x_items(l_index).RemindIndicator := 0;
        x_items(l_index).SourceObjectTypeCode := 'HR_CAL_EVENT';
         -- Get Drilldown information
        l_objects_input.ENTITY             := 'HR_CAL_EVENT';
        l_objects_input.OBJECT_CODE        := 'HR_CAL_EVENT';
        l_objects_input.HR_CAL_EVENT_ID    := l_hrcal(i).cal_event_id;
        jtf_objects_pub.GET_DRILLDOWN_PAGE
        ( P_INPUT_REC      => l_objects_input
        , X_PG_FUNCTION    => x_items(l_index).URL
        , X_PG_PARAMETERS  => x_items(l_index).URLParamList
        );
        l_index := l_index + 1;
      END LOOP;
   END IF;

END GET_CAL_EVENTS;

PROCEDURE GET_SCHEDULES
( p_object_type IN     VARCHAR2
, p_object_id   IN     NUMBER
, p_start_date  IN     DATE
, p_end_date    IN     DATE
, p_timezone_id IN     NUMBER
, p_view_timezone IN   NUMBER
, x_items       IN OUT NOCOPY   CAC_VIEW_PVT.QueryOutTab
)
IS
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

   l_schedule_summary    CAC_AVLBLTY_SUMMARY_VARRAY;
   l_schedule_details    CAC_AVLBLTY_DETAIL_VARRAY;
   l_schedule_daytime    CAC_AVLBLTY_DAY_TIME_VARRAY;

   l_new_start_date DATE;
   l_new_end_date   DATE;
   l_skip BOOLEAN;

   l_index NUMBER;
   l_objects_input    jtf_objects_pub.PG_INPUT_REC;

BEGIN
   l_index := x_items.count;

   CAC_AVLBLTY_PUB.GET_SCHEDULE_SUMMARY
   ( p_api_version          => 1.0
   , p_init_msg_list        => fnd_api.g_false
   , p_object_type          => p_object_type
   , p_object_id            => p_object_id
   , p_start_date           => p_start_date - 1
   , p_end_date             => p_end_date + 1
   , p_schedule_category    => NULL
   , p_include_exception    => 'T'
   , p_busy_tentative       => NULL
   , x_schedule_summary     => l_schedule_summary
   , x_return_status        => l_return_status
   , x_msg_count            => l_msg_count
   , x_msg_data             => l_msg_data
   );

   IF l_return_status = 'S' AND
      l_schedule_summary.count > 0
   THEN
      FOR i IN l_schedule_summary.first..l_schedule_summary.last
      LOOP
         l_schedule_details := l_schedule_summary(i).summary_lines;
         IF l_schedule_details.count > 0
         THEN
            FOR j IN l_schedule_details.first..l_schedule_details.last
            LOOP
               l_schedule_daytime := l_schedule_details(j).day_times;
               IF l_schedule_daytime.count > 0
               THEN
                  FOR k IN l_schedule_daytime.first..l_schedule_daytime.last
                  LOOP
                     l_skip := FALSE;


                     IF p_timezone_id IS NOT NULL
                     THEN

                        CAC_VIEW_UTIL_PVT.AdjustForTimezone
                        ( p_source_tz_id    => p_timezone_id
                        , p_dest_tz_id      => to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'))
                        , p_source_day_time => l_schedule_daytime(k).start_date_time
                        , x_dest_day_time   => l_new_start_date
                        );

                        CAC_VIEW_UTIL_PVT.AdjustForTimezone
                        ( p_source_tz_id    => p_timezone_id
                        , p_dest_tz_id      => to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'))
                        , p_source_day_time => l_schedule_daytime(k).end_date_time
                        , x_dest_day_time   => l_new_end_date
                        );

                     ELSIF p_view_timezone is not null
                     then
                        CAC_VIEW_UTIL_PVT.AdjustForTimezone
                        ( p_source_tz_id    => to_number(NVL(FND_PROFILE.Value('SERVER_TIMEZONE_ID'),'4'))
                        , p_dest_tz_id      => p_view_timezone
                        , p_source_day_time => l_schedule_daytime(k).start_date_time
                        , x_dest_day_time   => l_new_start_date
                        );

                        CAC_VIEW_UTIL_PVT.AdjustForTimezone
                        ( p_source_tz_id    => to_number(NVL(FND_PROFILE.Value('SERVER_TIMEZONE_ID'),'4'))
                        , p_dest_tz_id      => p_view_timezone
                        , p_source_day_time => l_schedule_daytime(k).end_date_time
                        , x_dest_day_time   => l_new_end_date
                        );

                    ELSE
                        l_new_start_date := l_schedule_daytime(k).start_date_time;
                        l_new_end_date := l_schedule_daytime(k).end_date_time;
                     END IF;
                     IF ((l_new_start_date <= p_start_date) AND
                         (l_new_end_date > p_start_date))
                     THEN
                       l_new_start_date := p_start_date;
                       IF (l_new_end_date > p_end_date)
                       THEN
                         l_new_end_date := p_end_date;
                       END IF;
                     ELSIF ((l_new_start_date > p_start_date) AND
                         (l_new_start_date < p_end_date))
                     THEN
                       IF (l_new_end_date > p_end_date)
                       THEN
                         l_new_end_date := p_end_date;
                       END IF;
                     ELSE
                        l_skip := TRUE;
                     END IF;

		     --Bug 4586452 Change the endtime if it ends at midnight
		     if ((to_char(l_new_end_date,'HH24:MI'))='00:00')
                     then
                     l_new_end_date:= l_new_end_date - (1/(24*60));
                     end if;

                     IF ((NOT l_skip) AND (l_new_end_date > l_new_start_date))
                     THEN
                        x_items(l_index).ItemDisplayType := 7;
                        x_items(l_index).ItemName        := l_schedule_details(j).period_category_name ||': '||
                                                            to_char(l_new_start_date,'HH24:MI')||' - '||
                                                            to_char(l_new_end_date,'HH24:MI');
                        x_items(l_index).FreeBusyType    := l_schedule_details(j).free_busy_type;
                        x_items(l_index).DisplayColor    := l_schedule_details(j).display_color;
                        x_items(l_index).ItemSourceCode  := 'SCHEDULE';
                        x_items(l_index).ItemSourceID    := 0;
                        x_items(l_index).AssignmentStatus:= 0;
                        x_items(l_index).InviteIndicator := 0;
                        x_items(l_index).RepeatIndicator := 0;
                        x_items(l_index).RemindIndicator := 0;
                        x_items(l_index).SourceObjectTypeCode := 'SCHEDULE';
                        x_items(l_index).StartDate := l_new_start_date;
                        x_items(l_index).EndDate   := l_new_end_date;
                        -- Get Drilldown information
                        l_objects_input.ENTITY             := 'SCHEDULE';
                        l_objects_input.OBJECT_CODE        := 'SCHEDULE';
                        l_objects_input.SCHEDULE_ID        := NULL; --TBD
                        jtf_objects_pub.GET_DRILLDOWN_PAGE
                        ( P_INPUT_REC      => l_objects_input
                        , X_PG_FUNCTION    => x_items(l_index).URL
                        , X_PG_PARAMETERS  => x_items(l_index).URLParamList
                        );
                        l_index := l_index + 1;
                     END IF;
                  END LOOP;
               END IF; -- end if l_schedule_daytime.count > 0
            END LOOP;
         END IF; -- end if l_schedule_details.count > 0
      END LOOP;
   END IF; -- end if l_schedule_summary.count > 0

END GET_SCHEDULES;

PROCEDURE SortTable
  /******************************************************************
  ** We need to sort the output table to make life easier on the
  ** java end.. This is a simple bi-directional bubble sort, which
  ** should do the trick.
  ******************************************************************/
  (p_CalendarItems IN OUT NOCOPY    CAC_VIEW_PVT.QueryOutTab
  )
  IS
    l_LastRecord BINARY_INTEGER;

    PROCEDURE Swap
    /******************************************************************
    ** Swap the records
    ******************************************************************/
    (p_index IN NUMBER
    )
    IS
      l_record   CAC_VIEW_PVT.QueryOut;
    BEGIN
      l_record                     := p_CalendarItems(p_index);
      p_CalendarItems(p_index)     := p_CalendarItems(p_index - 1);
      p_CalendarItems(p_index - 1) := l_record;
    END Swap;

  BEGIN
    l_LastRecord := p_CalendarItems.LAST;
    IF (l_LastRecord is null)
    THEN
      RETURN;
    ELSE
      FOR l_high IN 1 .. l_LastRecord
      LOOP <<HIGH>>
        IF (p_CalendarItems(l_high).ItemDisplayType NOT IN (6,7) AND
            p_CalendarItems(l_high - 1).ItemDisplayType NOT IN (6,7) AND
            p_CalendarItems(l_high).StartDate < p_CalendarItems(l_high - 1).StartDate) OR
           (p_CalendarItems(l_high).ItemDisplayType IN (6,7) AND
            p_CalendarItems(l_high - 1).ItemDisplayType NOT IN (6,7) AND
            trunc(p_CalendarItems(l_high).StartDate) <= trunc(p_CalendarItems(l_high - 1).StartDate)) OR
           (p_CalendarItems(l_high).ItemDisplayType IN (6,7) AND
            p_CalendarItems(l_high - 1).ItemDisplayType IN (6,7) AND
            p_CalendarItems(l_high).StartDate < p_CalendarItems(l_high - 1).StartDate)
        THEN
          Swap(l_high);
          FOR l_low IN REVERSE 1 .. (l_high - 1)
          LOOP <<LOW>>
            IF (p_CalendarItems(l_low).ItemDisplayType NOT IN (6,7) AND
                p_CalendarItems(l_low - 1).ItemDisplayType NOT IN (6,7) AND
                p_CalendarItems(l_low).StartDate < p_CalendarItems(l_low - 1).StartDate) OR
               (p_CalendarItems(l_low).ItemDisplayType IN (6,7) AND
                p_CalendarItems(l_low - 1).ItemDisplayType NOT IN (6,7) AND
                trunc(p_CalendarItems(l_low).StartDate) <= trunc(p_CalendarItems(l_low - 1).StartDate)) OR
               (p_CalendarItems(l_low).ItemDisplayType IN (6,7) AND
                p_CalendarItems(l_low - 1).ItemDisplayType IN (6,7) AND
                p_CalendarItems(l_low).StartDate < p_CalendarItems(l_low - 1).StartDate)
            THEN
              Swap(l_low);
            ELSE
              EXIT;
            END IF;
          END LOOP LOW;
        END IF;
      END LOOP HIGH;
    END IF;
  EXCEPTION
    WHEN COLLECTION_IS_NULL
    THEN RETURN;

    WHEN OTHERS
    THEN RAISE;
  END SortTable;

PROCEDURE GET_PERSON_PRIMARY_ASSIGNMENT
( p_emp_resource_id      IN  NUMBER
, x_per_assignment_id    OUT NOCOPY NUMBER
, x_per_assignment_type  OUT NOCOPY VARCHAR2
)
IS
  CURSOR c IS
  SELECT a.assignment_id
    FROM per_assignments_f a
       , jtf_rs_resource_extns r
   WHERE r.resource_id = p_emp_resource_id
     AND a.person_id = r.source_id
     AND a.primary_flag = 'Y'
     AND trunc(SYSDATE) BETWEEN NVL(a.effective_start_date, trunc(SYSDATE))
                            AND NVL(a.effective_end_date, trunc(SYSDATE+1));
BEGIN

  OPEN c;
  FETCH c INTO x_per_assignment_id;
  CLOSE c;

  x_per_assignment_type := 'PERSON_ASSIGNMENT';

END GET_PERSON_PRIMARY_ASSIGNMENT;

PROCEDURE GET_EMPLOYEE_RESOURCE
( p_per_assignment_id  IN  NUMBER
, x_emp_resource_id    OUT NOCOPY NUMBER
, x_emp_resource_type  OUT NOCOPY VARCHAR2
)
IS
  CURSOR c IS
  SELECT r.resource_id
    FROM per_assignments_f a
       , jtf_rs_resource_extns r
   WHERE a.assignment_id = p_per_assignment_id
     AND r.source_id = a.person_id
     AND r.category = 'EMPLOYEE';
BEGIN

  OPEN c;
  FETCH c INTO x_emp_resource_id;
  CLOSE c;

  x_emp_resource_type := 'RS_EMPLOYEE';

END GET_EMPLOYEE_RESOURCE;

PROCEDURE GET_RESOURCES
( p_input                      IN  CAC_VIEW_PVT.QueryIn
, x_query_emp_resource_id      OUT NOCOPY NUMBER
, x_query_emp_resource_type    OUT NOCOPY VARCHAR2
, x_query_per_assignment_id    OUT NOCOPY NUMBER
, x_query_per_assignment_type  OUT NOCOPY VARCHAR2
, x_query_user_access          OUT NOCOPY MENUS_TBL
, x_loggedon_emp_resource_id   OUT NOCOPY NUMBER
, x_loggedon_emp_resource_type OUT NOCOPY VARCHAR2
)
IS
  CURSOR C_GET_MENUS
  (
    b_resource_id   NUMBER,
    b_resource_type VARCHAR2
  ) IS
  SELECT fmu.menu_name
  FROM  fnd_grants             fgs
  ,     fnd_menus              fmu
  ,     fnd_objects            fos
  WHERE fgs.object_id          = fos.object_id
  AND   fgs.menu_id            = fmu.menu_id
  AND   fos.obj_name           = 'CAC_CAL_RESOURCES'
  AND   fgs.grantee_key        = FND_GLOBAL.USER_NAME
  AND   fgs.grantee_type       = 'USER'
  AND   fgs.start_date        <  SYSDATE
  AND   (   fgs.end_date      >= SYSDATE
        OR  fgs.end_date IS NULL
        )
  and   fgs.instance_type      = 'INSTANCE'
  AND   fgs.instance_pk1_value = TO_CHAR(b_resource_id)
  AND   fgs.instance_pk2_value = b_resource_type;

  l_user_id NUMBER;
  i         BINARY_INTEGER;
BEGIN
  IF p_input.QueryRSID IS NOT NULL
  THEN
     IF p_input.QueryRSType = 'RS_EMPLOYEE' THEN

       x_query_emp_resource_id := p_input.QueryRSID;
       x_query_emp_resource_type := p_input.QueryRSType;

       -- Get a primary person assignment id for the employee
       GET_PERSON_PRIMARY_ASSIGNMENT
       ( p_emp_resource_id      => p_input.QueryRSID
       , x_per_assignment_id    => x_query_per_assignment_id
       , x_per_assignment_type  => x_query_per_assignment_type
       );

     ELSIF p_input.QueryRSType = 'PERSON_ASSIGNMENT' THEN

       x_query_per_assignment_id := p_input.QueryRSID;
       x_query_per_assignment_type := p_input.QueryRSType;

       -- Get an employee resource info for the person assignment id
       GET_EMPLOYEE_RESOURCE
       ( p_per_assignment_id  => p_input.QueryRSID
       , x_emp_resource_id    => x_query_emp_resource_id
       , x_emp_resource_type  => x_query_emp_resource_type
       );

     END IF;
  ELSE
     IF p_input.UserID IS NOT NULL THEN
       l_user_id := p_input.UserID;
     ELSE
       l_user_id := fnd_global.user_id;
     END IF;

     -- Get an employee resource info for the given user id
     Jtf_Cal_Utility_Pvt.GetResourceInfo
     ( p_UserID       => l_user_id
     , x_ResourceID   => x_query_emp_resource_id
     , x_ResourceType => x_query_emp_resource_type
     );

     -- Get a primary person assignment id for the employee
     GET_PERSON_PRIMARY_ASSIGNMENT
     ( p_emp_resource_id      => x_query_emp_resource_id
     , x_per_assignment_id    => x_query_per_assignment_id
     , x_per_assignment_type  => x_query_per_assignment_type
     );
  END IF;

  -- Get an employee resource info for the loggon user
  Jtf_Cal_Utility_Pvt.GetResourceInfo
  ( p_UserID       => fnd_global.user_id
  , x_ResourceID   => x_loggedon_emp_resource_id
  , x_ResourceType => x_loggedon_emp_resource_type
  );

  -- Check access
  IF ((x_loggedon_emp_resource_id = x_query_emp_resource_id) AND
    (x_loggedon_emp_resource_type = x_query_emp_resource_type))
  THEN
    i := 1;
    x_query_user_access(i) := 'JTF_CAL_FULL_ACCESS';
    i := i+1;
    x_query_user_access(i) := 'JTF_TASK_FULL_ACCESS';
    i := i+1;
    x_query_user_access(i) := 'CAC_BKG_READ_ONLY_ACCESS';
  ELSIF (p_input.UseCalendarSecurity = 'Y')
  THEN
    i := 1;
    FOR ref_menus IN C_GET_MENUS(x_query_emp_resource_id,x_query_emp_resource_type)
    LOOP
      x_query_user_access(i) := ref_menus.menu_name;
      i := i+1;
    END LOOP;
  ELSE
    i := 1;
    x_query_user_access(i) := 'JTF_CAL_READ_ACCESS';
    i := i+1;
    x_query_user_access(i) := 'JTF_TASK_READ_ONLY';
    i := i+1;
    x_query_user_access(i) := 'CAC_BKG_READ_ONLY_ACCESS';
  END IF;
END GET_RESOURCES;

PROCEDURE GetView
/*******************************************************************************
** This procedure will return all task information needed to
** display the daily Calendar page
*******************************************************************************/
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_validation_level       IN     NUMBER
, x_return_status          OUT    NOCOPY    VARCHAR2
, x_msg_count              OUT    NOCOPY    NUMBER
, x_msg_data               OUT    NOCOPY    VARCHAR2
, p_input                  IN     CAC_VIEW_PVT.QueryIn
, x_DisplayItems           OUT    NOCOPY    CAC_VIEW_PVT.QueryOutTab
)IS
  l_LoggedOnRSID         NUMBER;       -- ResourceID of the logged on user
  l_LoggedOnRSType       VARCHAR2(30); -- ResourceType of the logged on user
  l_QueryRSID            NUMBER;       -- ResourceID of the logged on user
  l_QueryRSType          VARCHAR2(30); -- ResourceType of the logged on user
  l_QueryRSName          VARCHAR2(360);-- Resource Name of the logged on user
  l_query_per_rs_id      NUMBER;       -- Person Primary Assignment ID
  l_query_per_rs_type    VARCHAR2(30); -- PERSON_ASSIGNMENT
  l_query_user_name      VARCHAR2(100);--
  l_query_user_access    MENUS_TBL ;   --
  l_LoggedOnToday        DATE;         -- Today of logged on user
  l_QueryDate            DATE;         -- Query Date of logged on user
  l_QueryStartDate       DATE;         -- Start of the query period
  l_QueryEndDate         DATE;         -- End of the query period

  --l_WeekTimePrefTbl      WeekTimePrefTblType;
  l_CalSpanDaysProfile   VARCHAR2(10);
  l_MinDayTime           NUMBER;
  l_MaxDayTime           NUMBER;
  l_WeekStartDay         NUMBER;
  l_WeekEndDay           NUMBER;
  l_QueryDays            NUMBER;
  l_DayNumber            NUMBER;
  l_offset               NUMBER;
  l_SundayDate           DATE;
  l_SaturdayDate         DATE;

  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_index                BINARY_INTEGER;
  CURSOR c_Groups
  /*****************************************************************************
  ** This Cursor will fetch all Groups Calendars the Calendar User is
  ** subscribed to
  *****************************************************************************/
  ( b_ResourceID  IN NUMBER
  )IS SELECT DISTINCT TO_NUMBER(fgs.instance_pk1_value) GroupID
      /*,           Jtf_Cal_Utility_Pvt.GetGroupColor
                                     ( b_ResourceID
                                     , 'RS_EMPLOYEE'
                                     , TO_NUMBER(fgs.instance_pk1_value)
                                     )                  Color
      ,           Jtf_Cal_Utility_Pvt.GetGroupPrefix
                                     ( b_ResourceID
                                     , 'RS_EMPLOYEE'
                                     , TO_NUMBER(fgs.instance_pk1_value)
                                     )                  Prefix*/
      FROM  fnd_grants               fgs
      ,     fnd_objects              fos
      ,     jtf_rs_group_usages      rgu
      WHERE fgs.object_id          = fos.object_id   -- grants joint to object
      AND   fos.obj_name           = 'JTF_TASK_RESOURCE'
      AND   fgs.grantee_key        = TO_CHAR(b_ResourceID)
      AND   fgs.start_date        <  SYSDATE
      AND   (   (fgs.end_date     >= SYSDATE)
            OR  (fgs.end_date     IS NULL)
            )
      AND   fgs.instance_pk2_value = 'RS_GROUP'
      AND   rgu.GROUP_ID = TO_NUMBER(fgs.instance_pk1_value)
       AND   rgu.USAGE = 'GROUP_CALENDAR';

BEGIN
  IF fnd_api.to_boolean (NVL(p_init_msg_list,fnd_api.g_false))
  THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize JTF Objects cache
  jtf_objects_pub.INITIALIZE_CACHE;

  /*****************************************************************************
  ** Make sure I have all the Resource Information needed for the logged
  ** on user
  *****************************************************************************/

  l_index := -1;
  --IF (  (p_input.LoggedOnRSID IS NULL)
  --   OR (p_input.LoggedOnRSType IS NULL)
  --   )
  --THEN
    /***************************************************************************
    ** If I didn't get it, try to look it up with the UserID
    ***************************************************************************/
  --  IF(p_input.UserID IS NULL)
  --  THEN
  --    NULL; --error no user information provided, this is not supposed to happen...
  --  ELSE
  --    Jtf_Cal_Utility_Pvt.GetResourceInfo( p_UserID       => p_input.UserID
  --                                       , x_ResourceID   => l_LoggedOnRSID
  --                                       , x_ResourceType => l_LoggedOnRSType
  --                                       );
  --  END IF;

  --ELSE
    /***************************************************************************
    ** If I did get it
    ***************************************************************************/
  --  l_LoggedOnRSID    := p_input.LoggedOnRSID;
  --  l_LoggedOnRSType  := p_input.LoggedOnRSType;
  --END IF;

  /*****************************************************************************
  ** Determine the resource id/type for which the data should be fetched
  *****************************************************************************/
  --IF ((p_input.QueryRSID IS NULL) OR (p_input.QueryRSType IS NULL))
  --THEN
  --  l_QueryRSID := l_LoggedOnRSID;
  --  l_QueryRSType := l_LoggedOnRSType;
  --ELSE
  --  l_QueryRSID := p_input.QueryRSID;
  --  l_QueryRSType := p_input.QueryRSType;
  --END IF;

  GET_RESOURCES
  ( p_input                      => p_input
  , x_query_emp_resource_id      => l_QueryRSID
  , x_query_emp_resource_type    => l_QueryRSType
  , x_query_per_assignment_id    => l_query_per_rs_id
  , x_query_per_assignment_type  => l_query_per_rs_type
  , x_query_user_access          => l_query_user_access
  , x_loggedon_emp_resource_id   => l_LoggedOnRSID
  , x_loggedon_emp_resource_type => l_LoggedOnRSType
  );

 -- need to fetch SpanDaysProfile profile independently
 l_CalSpanDaysProfile := fnd_profile.value('JTF_CAL_SPAN_DAYS');
  /***************************************************************************
  ** What is today for the logged on user
  ***************************************************************************/
  if p_input.ViewTimezoneID is not null
  then
    Hz_Timezone_Pub.Get_Time( p_api_version     => 1.0
                            , p_init_msg_list   => Fnd_Api.G_FALSE
                            , p_source_tz_id    => TO_NUMBER(NVL(Fnd_Profile.Value('SERVER_TIMEZONE_ID'),'4'))
                            , p_dest_tz_id      => p_input.ViewTimezoneID
                            , p_source_day_time => SYSDATE -- database sysdate
                            , x_dest_day_time   => l_LoggedOnToday
                            , x_return_status   => l_return_status
                            , x_msg_count       => l_msg_count
                            , x_msg_data        => l_msg_data
                            );
 else
    Hz_Timezone_Pub.Get_Time( p_api_version     => 1.0
                            , p_init_msg_list   => Fnd_Api.G_FALSE
                            , p_source_tz_id    => TO_NUMBER(NVL(Fnd_Profile.Value('SERVER_TIMEZONE_ID'),'4'))
                            , p_dest_tz_id      => TO_NUMBER(NVL(Fnd_Profile.Value('CLIENT_TIMEZONE_ID'),'4'))
                            , p_source_day_time => SYSDATE -- database sysdate
                            , x_dest_day_time   => l_LoggedOnToday
                            , x_return_status   => l_return_status
                            , x_msg_count       => l_msg_count
                            , x_msg_data        => l_msg_data
                            );
  end if;

  /*****************************************************************************
  ** Set the Current Time for the Resource
  *****************************************************************************/
  -- Rada, 09/25/2003 remove all x_preferences
  --x_Preferences.CurrentTime := l_LoggedOnToday;

  /****************************************************************************
  ** If p_input.StartDate IS NULL I have to figure out what the current day
  ****************************************************************************/
  IF (p_Input.StartDate IS NULL)
  THEN
    l_QueryDate := l_LoggedOnToday;
  ELSE
    l_QueryDate := p_Input.StartDate;
  END IF;

  -- get the name for sunday from a known date
  l_SundayDate := TO_DATE('1995/01/01','yyyy/mm/dd');
  l_SaturdayDate := l_SundayDate - 1;

  /*****************************************************************************
  ** Depending on the QueryMode we have to determine the QueryStartDate and the
  ** QueryEndDate
  ** - 1 = Daily view
  ** - 2 = Weekly view
  ** - 3 = Monthly view
  ** - 4 = Combi view (daily + todo list)
  *****************************************************************************/
  IF (p_Input.QueryMode IN (1,4))
  THEN
    /***************************************************************************
    ** Daily is easy..
    ***************************************************************************/
    l_QueryStartDate := TRUNC(l_QueryDate);                      -- today 00:00:00
    l_QueryEndDate   := (TRUNC(l_QueryDate) + 1) - (1/24/60/60); -- today 23:59:59
    l_QueryDays      := 1;
  ELSIF (p_Input.QueryMode = 2)
  THEN
    /***************************************************************************
    ** Weekly View
    ***************************************************************************/
    l_QueryStartDate := p_input.StartDate;
    l_QueryEndDate := p_input.EndDate;

  ELSIF (p_Input.QueryMode = 3)
  THEN
    --REMOVE THE LOGIC FOR MONTHLY VIEW END DATE. USE ENDDATE INPUT PARAMETER INSTEAD.
    l_QueryStartDate := p_input.StartDate;
    l_QueryEndDate := p_input.EndDate;
    IF l_QueryEndDate IS NULL THEN
      l_QueryEndDate := sysdate + 31;
      l_QueryDays := 0;
    END IF;
    /***************************************************************************
    ** Monthly is easy too
    ***************************************************************************/

    -- Modified by jawang on 09/26/2002 to show previous and next month's appoints and tasks for a given month as well
    /*l_QueryStartDate := TRUNC(l_QueryDate,'MON'); -- start of month 00:00:00
    l_DayNumber := MOD((TRUNC(l_QueryStartDate) - l_SundayDate),7);

    IF (l_DayNumber>0)
    THEN
        l_QueryStartDate := l_QueryStartDate - l_DayNumber;
    ELSIF (l_DayNumber<0) THEN
        l_QueryStartDate := l_QueryStartDate - (7 + l_DayNumber);
    END IF;

    l_QueryEndDate   := TRUNC(LAST_DAY(l_QueryDate));-- end of month 00:00:00
    l_DayNumber := MOD((TRUNC(l_QueryEndDate) - l_SaturdayDate),7);

    IF (l_DayNumber>0)
    THEN
        l_QueryEndDate := l_QueryEndDate + (7-l_DayNumber);
    ELSIF (l_DayNumber<0) THEN
        l_QueryEndDate := l_QueryEndDate - l_DayNumber;
    END IF;
    l_QueryEndDate := l_QueryEndDate + (1 - (1/24/60/60));
    l_QueryDays      := 0;*/

  END IF;

  /*****************************************************************************
  ** Adjust the preferences to reflect the period
  *****************************************************************************/
  l_DayNumber := MOD((TRUNC(l_QueryStartDate) - l_SundayDate),7);
  IF (l_DayNumber>=0)
  THEN
     l_DayNumber := 1 + l_DayNumber;
  ELSE
     l_DayNumber := 1 - l_DayNumber;
  END IF;
  l_MinDayTime := 50;
  l_MaxDayTime := -1;
  /*FOR I IN l_DayNumber .. l_DayNumber+l_QueryDays-1
  LOOP
     NULL;
    IF (l_WeekTimePrefTbl.EXISTS(I))
    THEN
      IF (l_WeekTimePrefTbl(I).DayStart BETWEEN 0 AND 23)
      THEN
        IF (l_MinDayTime>l_WeekTimePrefTbl(I).DayStart)
        THEN
          l_MinDayTime := l_WeekTimePrefTbl(I).DayStart;
        END IF;
      END IF;
      IF (l_WeekTimePrefTbl(I).DayEnd BETWEEN 0 AND 23)
      THEN
        IF (l_MaxDayTime<l_WeekTimePrefTbl(I).DayEnd)
        THEN
          l_MaxDayTime := l_WeekTimePrefTbl(I).DayEnd;
        END IF;
      END IF;
    END IF;
  END LOOP;*/
  IF (l_MinDayTime=50)
  THEN
    l_MinDayTime := 9;
  END IF;
  IF (l_MaxDayTime<0)
  THEN
    l_MaxDayTime := 18;
  END IF;
  IF (l_MaxDayTime<l_MinDayTime)
  THEN
    l_MinDayTime := 9;
    l_MaxDayTime := 18;
  END IF;
  /*x_Preferences.MinStartTime := TO_DATE(TO_CHAR(l_QueryStartDate,'DD-MON-YYYY')||
                                ' '||TO_CHAR(l_MinDayTime),'DD-MON-YYYY hh24');
  x_Preferences.MaxEndTime   := TO_DATE(TO_CHAR(l_QueryEndDate,'DD-MON-YYYY')||
                                ' '||TO_CHAR(l_MaxDayTime),'DD-MON-YYYY hh24');*/

-- Bug # 4189292, amigupta, code commented for bringing Group Appointments

 /*****************************************************************************
  ** If it's a personal calendar we need to super impose the tasks/appointments
  ** of groups we subscribed to
  *****************************************************************************/

  --RDESPOTO, 04/09/2004

 /* IF (l_QueryRSType = 'RS_EMPLOYEE')
  THEN
    FOR r_Groups IN c_Groups(l_QueryRSID)
    LOOP <<GROUPS>>

      /*************************************************************************
      ** The GROUPS loop will get the GROUP_Ids of all Calendar groups
      ** that I am currently a member of
      *************************************************************************/
/*      GetApptsAndTasks (
     l_LoggedOnRSID,
     l_LoggedOnRSType,
     r_Groups.GroupID,
     'RS_GROUP',
     l_QueryStartDate,
     l_QueryEndDate,
     p_input.QueryMode,
     l_CalSpanDaysProfile,
     r_Groups.GroupID,
     p_input.ShowApts,
     p_input.ShowTasks,
     p_input.ShowOpenInvite,
     p_Input.ShowDeclined,
     p_Input.AptFirstDetail,
     p_Input.AptSecondDetail,
     p_Input.AptThirdDetail,
     p_Input.ShowBusyTask,
     p_Input.ShowFreeTask,
     p_Input.ShowTentativeTask,
     p_Input.TaskFirstDetail,
     p_Input.TaskSecondDetail,
     p_Input.TaskThirdDetail,
     'Y',  -- we are in "personal" calendar
     l_index,
     x_DisplayItems
     --x_Preferences
     );
    END LOOP GROUPS;
  END IF;
*/

  /*****************************************************************************
  ** No matter what the resource type get the TASKS for the query user
  *****************************************************************************/

    GetApptsAndTasks (
    l_LoggedOnRSID,
    l_LoggedOnRSType,
    l_QueryRSID,
    l_QueryRSType,
    l_QueryStartDate,
    l_QueryEndDate,
    p_input.QueryMode,
    l_CalSpanDaysProfile,
    NULL,
     p_input.ShowApts,
     p_input.ShowTasks,
     p_input.ShowOpenInvite,
     p_Input.ShowDeclined,
     p_Input.AptFirstDetail,
     p_Input.AptSecondDetail,
     p_Input.AptThirdDetail,
     p_Input.ShowBusyTask,
     p_Input.ShowFreeTask,
     p_Input.ShowTentativeTask,
     p_Input.TaskFirstDetail,
     p_Input.TaskSecondDetail,
     p_Input.TaskThirdDetail,
     p_Input.ViewTimezoneID,
    'N',
    l_query_user_access,
    l_index,
    x_DisplayItems
    );
    IF (p_input.ShowEvents) = 'Y' THEN
     GetItems (
     l_LoggedOnRSID,
     l_LoggedOnRSType,
     l_QueryRSID,
     l_QueryRSType,
     l_QueryStartDate,
     l_QueryEndDate,
     p_input.QueryMode,
     p_Input.ViewTimezoneID,
     'N',
     NULL,
    l_index,
    x_DisplayItems
    );
   END IF;
/* ER# 3740057, amigupta, Call to getBookings procedure in order to fetch Bookings */
   GetBookings(
    l_LoggedOnRSID,
    l_LoggedOnRSType,
    l_QueryRSID,
    l_QueryRSType,
    l_QueryStartDate,
    l_QueryEndDate,
    p_input.QueryMode,
    p_Input.ViewTimezoneID,
    l_CalSpanDaysProfile,
    NULL,
     p_input.ShowBookings, -- p_input.ShowBookings
    l_query_user_access,
    l_index,
    x_DisplayItems
    );

  IF p_input.ShowSchedules = 'Y' THEN
     GET_SCHEDULES
     (p_object_type => l_query_per_rs_type
     ,p_object_id   => l_query_per_rs_id
     ,p_start_date  => l_QueryStartDate
     ,p_end_date    => l_QueryEndDate
     ,p_timezone_id => p_input.EmpLocTimezoneId
     ,p_view_timezone => p_input.ViewTimezoneID
     ,x_items       => x_DisplayItems);
  END IF;

  IF p_input.ShowHRCalendarEvents = 'Y' THEN
     GET_CAL_EVENTS
     (p_object_type => l_query_per_rs_type
     ,p_object_id   => l_query_per_rs_id
     ,p_start_date  => l_QueryStartDate
     ,p_end_date    => l_QueryEndDate
     ,x_items       => x_DisplayItems);
  END IF;

  /*****************************************************************************
  ** Almost done, just have to sort the table
  *****************************************************************************/
  SortTable(x_DisplayItems);

END GetView;

FUNCTION GetItemType
  /*****************************************************************************
  ** This function will return the calendar item type based on whether
  ** its begin and end date/time are defined. The type will determine
  ** where on the calendar the item is shown 1=Calendar 2=task 3=memo 5=split
  *****************************************************************************/
  ( p_SourceCode      IN VARCHAR2
  , p_PeriodStartDate IN DATE
  , p_PeriodEndDate   IN DATE
  , p_StartDate       IN DATE
  , p_EndDate         IN DATE
  , p_CalSpanDaysProfile IN VARCHAR2
  )RETURN NUMBER
  IS
  BEGIN

     IF (p_StartDate IS NULL)
     THEN
       /************************************************************************
       ** Blank start date items are no views candidate
       ************************************************************************/
       RETURN 2;
     END IF;
     IF (p_EndDate IS NULL)
     THEN
         /**********************************************************************
         ** Untimed calendar items are always displayed as memo
         **********************************************************************/
         RETURN 3;
     ELSIF (TRUNC(p_StartDate) = TRUNC (p_EndDate))
     THEN
         /**********************************************************************
         ** It's completely within the period, so it should be shown on the
         ** calendar and the task list based on source
         **********************************************************************/
         /*All day appointment end date is in "23 hour 59 mins" format" to fix bug 3465725*/
         IF ((p_EndDate - p_StartDate) = 0 OR (p_EndDate - p_StartDate)*24*60 = 1439)
         THEN
            /** Bug 2863891, don't show tasks on top of the page **/
            IF (p_SourceCode <> 'APPOINTMENT') THEN
             RETURN 1;
            ELSE
             RETURN 3;
            END IF;
         ELSE
            RETURN 1;
         END IF;
     ELSE
         /**********************************************************************
         ** It spans accross multiple days : split accross all days
         **********************************************************************/
         IF (p_CalSpanDaysProfile = 'Y')
         THEN
            RETURN 5;
         ELSE
            RETURN 3;
         END IF;
     END IF;
 --RDESPOTO, 04/05/2003, return 'All Day' as default item type
  RETURN 3;
  END GetItemType;

FUNCTION get_Contact(p_party_type_code in varchar2,p_party_id IN NUMBER)
    RETURN VARCHAR2
    IS
    person_party_name varchar2(25);
    BEGIN
    Select  per.party_name into person_party_name
    From   hz_parties per,  hz_relationships hr
Where  hr.subject_table_name = 'HZ_PARTIES'
and hr.object_table_name  = 'HZ_PARTIES'
and hr.directional_flag = 'F'
and hr.subject_id = per.party_id
and per.party_type = 'PERSON'
and hr.party_id = p_party_id;
        RETURN person_party_name ;
    EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
    END get_Contact;

END CAC_VIEW_PVT;


/
