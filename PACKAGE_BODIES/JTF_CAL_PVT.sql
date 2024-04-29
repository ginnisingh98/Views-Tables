--------------------------------------------------------
--  DDL for Package Body JTF_CAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_PVT" AS
/* $Header: jtfvhcb.pls 120.6 2006/05/30 13:19:14 sbarat ship $ */

PROCEDURE GetCalendarList
/*******************************************************************************
** Given a ResourceID, this procedure will return a list of Calendars that the
** Calendar user has access to
*******************************************************************************/
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_validation_level       IN     NUMBER
, x_return_status          OUT    NOCOPY	VARCHAR2
, x_msg_count              OUT    NOCOPY	NUMBER
, x_msg_data               OUT    NOCOPY	VARCHAR2
, p_resourceID             IN OUT NOCOPY	NUMBER
, p_resourceType           IN OUT NOCOPY	VARCHAR2
, p_userID                 IN     NUMBER
, x_calendarList           OUT    NOCOPY	CalLstTblType
)
IS
  l_index         BINARY_INTEGER:=1;
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
     AND   jrt.resource_id        = to_number(fgs.instance_pk1_value)  -- Modified by SBARAT on 30/05/2006 for bug# 5213367
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
, p_Color                IN  VARCHAR2
, p_prefix               IN  VARCHAR2
, p_pers_cal             IN  VARCHAR2
, x_index                IN OUT NOCOPY	BINARY_INTEGER
, x_DisplayItems         IN OUT NOCOPY	Jtf_Cal_Pvt.QueryOutTab
, x_Preferences          IN OUT NOCOPY	Jtf_Cal_Pvt.Preference
) IS

  l_TempStartDate       DATE;
  l_TempEndDate         DATE;
  l_TempItemDisplayType  NUMBER;
  l_ItemDisplayType      NUMBER;

  --Added by jawang on 11/18/2002 to fix the NOCOPY issue
  l_StartDate 		DATE;
  l_EndDate 		DATE;

  CURSOR c_Tasks
  /*****************************************************************************
  ** This cursor will only return Tasks/Appointments that need to be displayed
  ** in the page or is needed to derive that information
  *****************************************************************************/
  ( b_ResourceID   IN NUMBER
  , b_ResourceType IN VARCHAR2
  , b_StartDate    IN DATE  -- start of query period
  , b_EndDate      IN DATE  -- end of query period
  )IS SELECT /*+ INDEX(jtsb JTF_TASK_STATUSES_B_U1) */
             jtb.task_id                      TaskId
      ,      jtb.source_object_type_code      SourceObjectTypeCode
      ,      jtb.source_object_id             SourceId
      ,      jtb.customer_id                  CustomerId
      ,      jtt.task_name                    ItemName
      ,      jtb.calendar_start_date          StartDate
      ,      jtb.calendar_end_date            EndDate
      ,      jtb.timezone_id                  TimezoneID
      ,      jtb.duration                     Duration    -- always in minutes
      ,      jtb.private_flag                 PrivateFlag -- needed to determin access level
      ,      DECODE(jta.assignment_status_id ,18, DECODE(jtb.source_object_type_code ,'APPOINTMENT',1,0),0)
                             InviteIndicator
      ,      DECODE(jtb.recurrence_rule_id
                   ,NULL,0
                   ,1
                   )          RepeatIndicator
      ,      DECODE(jtb.source_object_type_code ,'APPOINTMENT', x_preferences.ApptColor, x_preferences.TaskColor)
                             ItemColor
      ,      DECODE(jtb.source_object_type_code ,'APPOINTMENT', x_preferences.ApptPrefix, x_preferences.TaskPrefix)
                             ItemPrefix
      ,      Jtf_Cal_Utility_Pvt.GetItemURL               -- can't join URL is dynamic..
             ( jtb.source_object_id
             , jtb.source_object_type_code)   URL
      ,      jta.assignee_role                AssigneeRole
      ,      jtb.task_priority_id             PriorityID    -- Needed for todos
      ,      jta.category_id                  CategoryID    -- Needed for todos
      ,      jtb.object_version_number        AssignmentOVN -- Needed to update todos
      ,      jta.object_version_number        TaskOVN       -- Needed to update todos
      FROM jtf_task_all_assignments   jta
      ,    jtf_tasks_b            jtb
      ,    jtf_tasks_tl           jtt
      ,    jtf_task_statuses_b    jtsb
      WHERE jta.resource_id          = b_ResourceID        -- 101272224
      AND   jta.resource_type_code   = b_ResourceType      -- 'RS_EMPLOYEE'
      AND   jta.task_id              = jtb.task_id         -- join to tasks_b
      AND   jtb.task_status_id       = jtsb.task_status_id -- join to to task_status_b
      AND   jtb.task_id              = jtt.task_id         -- join to tasks_tl
      AND   jtt.LANGUAGE             = USERENV('LANG')     -- join to tasks_tl
      AND   jta.show_on_calendar     = 'Y'
      AND   jta.assignment_status_id <> 4 -- using status rejected for declined
      AND   NVL(jtsb.closed_flag,'N')<> 'Y'
      AND   (   jtb.calendar_start_date <= b_EndDate
            OR  jtb.calendar_start_date IS NULL
            )
      AND   (   jtb.calendar_end_date   >=  b_StartDate
            OR  jtb.calendar_end_date IS NULL
            )
      AND jtb.entity <> 'BOOKING'
      AND jtb.source_object_type_code <> 'EXTERNAL APPOINTMENT'
      ;
      --Added by MPADHIAR for Bug#5037648
      TYPE tbl_PersonalTask IS TABLE OF c_Tasks%ROWTYPE INDEX BY BINARY_INTEGER;
      l_tab_PersonalTask   tbl_PersonalTask;
      l_index BINARY_INTEGER;
      --Added by MPADHIAR for Bug#5037648 --Ends here

BEGIN

  IF (c_Tasks%ISOPEN)
  THEN
    CLOSE c_Tasks; -- Make sure the cursor is closed
  END IF;
   --Added by MPADHIAR for Bug#5037648
  OPEN c_Tasks( p_QueryRSID
                               , p_QueryRSType
                               , p_QueryStartDate - 1 -- allow for max timezone correction
                               , p_QueryEndDate   + 1 -- allow for max timezone correction
                               );
  LOOP <<ALL_PERSONAL_TASKS>>
	  FETCH c_Tasks BULK COLLECT INTO l_tab_PersonalTask LIMIT 500;
	  FOR l_index IN 1 .. l_tab_PersonalTask.COUNT LOOP <<PERSONAL_TASKS>>
	  --Added by MPADHIAR for Bug#5037648 --Ends here
          /***************************************************************************
          ** We will have to adjust the Start/End Date for the users timezone
          ***************************************************************************/
           --Here onwards r_PersonalTask is replaced with l_tab_PersonalTask(l_index)
	  --for Bug#5037648 by MPADHIAR
          l_TempItemDisplayType := Jtf_Cal_Utility_Pvt.GetItemType
                                 ( p_SourceCode      => l_tab_PersonalTask(l_index).SourceObjectTypeCode
                                 , p_PeriodStartDate => p_QueryStartDate
                                 , p_PeriodEndDate   => p_QueryEndDate
                                 , p_StartDate       => l_tab_PersonalTask(l_index).StartDate
                                 , p_EndDate         => l_tab_PersonalTask(l_index).EndDate
                                 , p_CalSpanDaysProfile => p_CalSpanDaysProfile
                                 );

          --Added by jawang on 11/18/2002 to fix the NOCOPY issue
          l_StartDate  := l_tab_PersonalTask(l_index).StartDate;
          l_EndDate  := l_tab_PersonalTask(l_index).EndDate;

          IF  l_TempItemDisplayType <> 3 THEN

            Jtf_Cal_Utility_Pvt.AdjustForTimezone
                             ( p_source_tz_id    =>  l_tab_PersonalTask(l_index).TimezoneID--213--
                             , p_dest_tz_id      =>  x_Preferences.Timezone
                             , p_source_day_time =>  l_StartDate
                             , x_dest_day_time   =>  l_tab_PersonalTask(l_index).Startdate
                             );

            Jtf_Cal_Utility_Pvt.AdjustForTimezone
                             ( p_source_tz_id    =>  l_tab_PersonalTask(l_index).TimezoneID--213--
                             , p_dest_tz_id      =>  x_Preferences.Timezone
                             -- Modified by jawang on 11/21/02 to fix NOCOPY issue
                             , p_source_day_time =>  l_EndDate
                             , x_dest_day_time   =>  l_tab_PersonalTask(l_index).Enddate
                             );
          END IF;


              IF ((p_QueryMode = 4) -- All tasks
             OR ((p_QueryMode <> 4)
                AND (l_TempItemDisplayType <> 2))) -- Filter tasks item type 2
              THEN

          --MultiDay span case
              l_TempStartDate   := l_tab_PersonalTask(l_index).StartDate;
              l_TempEndDate     := l_tab_PersonalTask(l_index).EndDate;
          l_ItemDisplayType := l_TempItemDisplayType;
              IF (l_TempItemDisplayType = 5)
              THEN
                 l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
                 l_ItemDisplayType := 1;
              END IF;


              WHILE (((l_TempEndDate <= l_tab_PersonalTask(l_index).EndDate) AND
                        (l_TempStartDate <= l_tab_PersonalTask(l_index).EndDate)) OR
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
                              x_DisplayItems(x_index).ItemSourceID    := l_tab_PersonalTask(l_index).TaskId;
                  --Rada, enh # 2658165
                  IF NVL(x_preferences.TaskCustomerSource, 'NO') = 'YES' THEN
                    IF ( l_tab_PersonalTask(l_index).SourceObjectTypeCode <> 'APPOINTMENT'
                      AND  l_tab_PersonalTask(l_index).SourceObjectTypeCode <> 'TASK' ) THEN
                      x_DisplayItems(x_index).SourceID    := l_tab_PersonalTask(l_index).SourceId;
                                  x_DisplayItems(x_index).SourceObjectTypeCode  := l_tab_PersonalTask(l_index).SourceObjectTypeCode;
                    END IF;

                    x_DisplayItems(x_index).CustomerId := l_tab_PersonalTask(l_index).CustomerId;
                  END IF;
                  -- Rada, enh # 2127725, do not apply color and prefix on group cal items and invitations
                  IF p_pers_cal = 'Y' OR l_tab_PersonalTask(l_index).InviteIndicator = 1 OR l_tab_PersonalTask(l_index).ItemPrefix = ' ' THEN
                       x_DisplayItems(x_index).ItemName	:= p_prefix||l_tab_PersonalTask(l_index).ItemName;
                  ELSE
                       x_DisplayItems(x_index).ItemName   := l_tab_PersonalTask(l_index).ItemPrefix || l_tab_PersonalTask(l_index).ItemName;
                  END IF;
                              x_DisplayItems(x_index).AccessLevel := Jtf_Cal_Utility_Pvt.GetAccessLevel
                                                                                                                 (   l_tab_PersonalTask(l_index).PrivateFlag
                                                                                                                         , l_tab_PersonalTask(l_index).AssigneeRole
                                                                                                                         , p_LoggedOnRSID
                                                                                                                         , p_LoggedOnRSType
                                                                                                                         , p_QueryRSID
                                                                                                                         , p_QueryRSType
                                                                 , l_tab_PersonalTask(l_index).SourceObjectTypeCode
                                                                                                                 );
                              x_DisplayItems(x_index).InviteIndicator := l_tab_PersonalTask(l_index).InviteIndicator;
                              x_DisplayItems(x_index).RepeatIndicator := l_tab_PersonalTask(l_index).RepeatIndicator;
                              x_DisplayItems(x_index).StartDate       := l_TempStartDate;
                              x_DisplayItems(x_index).EndDate         := l_TempEndDate;
                              x_DisplayItems(x_index).URL             := l_tab_PersonalTask(l_index).URL;

                  -- Rada, enh # 2127725, do not apply color and prefix on group cal items and invitations
                  IF p_pers_cal = 'Y' THEN
                    x_DisplayItems(x_index).Color := p_Color;
                  ELSE
                    x_DisplayItems(x_index).Color   := l_tab_PersonalTask(l_index).ItemColor;
                  END IF;
                              x_DisplayItems(x_index).GroupRSID := p_GroupRSID;

                              /***********************************************************************
                              ** These are populated conditionally, making sure they are NULL
                              ***********************************************************************/
                              x_DisplayItems(x_index).PriorityID      := NULL;
                              x_DisplayItems(x_index).PriorityName    := NULL;
                              x_DisplayItems(x_index).CategoryID      := NULL;
                              x_DisplayItems(x_index).CategoryDesc    := NULL;
                              x_DisplayItems(x_index).NoteFlag        := NULL;
                              x_DisplayItems(x_index).TaskOVN         := NULL;
                              x_DisplayItems(x_index).AssignmentOVN   := NULL;

                              /*******************************************************************
                              ** This is a task that should show in the todo list, therefore we
                              ** need some extra information
                              *******************************************************************/
                              IF ((l_ItemDisplayType = 2) -- Display as Tasks only
                                      AND (p_QueryMode = 4)) -- Combi view
                              THEN
                                      x_DisplayItems(x_index).PriorityID      := l_tab_PersonalTask(l_index).PriorityID;
                                      x_DisplayItems(x_index).PriorityName    := Jtf_Cal_Utility_Pvt.GetTaskPriority
                                                                                                                        ( l_tab_PersonalTask(l_index).PriorityID
                                                                                                                        );
                                      x_DisplayItems(x_index).CategoryID      := l_tab_PersonalTask(l_index).CategoryID;
                                      x_DisplayItems(x_index).CategoryDesc    := Jtf_Cal_Utility_Pvt.GetCategoryName
                                                                                                                         ( l_tab_PersonalTask(l_index).CategoryID
                                                                                                                         );
                                      x_DisplayItems(x_index).NoteFlag        := Jtf_Cal_Utility_Pvt.TaskHasNotes
                                                                                                                         ( l_tab_PersonalTask(l_index).TaskId
                                                                                                                         );
                                      x_DisplayItems(x_index).TaskOVN         := l_tab_PersonalTask(l_index).TaskOVN;
                                      x_DisplayItems(x_index).AssignmentOVN   := l_tab_PersonalTask(l_index).AssignmentOVN;
                              END IF;

                              /***********************************************************************
                              ** We may have to adjust the display range in the preferences if the
                              ** tasks/appointments to be displayed fall outside the range.
                              *******************************************************************/
                              IF (l_ItemDisplayType IN (1,4))
                              THEN
                                Jtf_Cal_Utility_Pvt.AdjustMinMaxTime( p_StartDate   => l_TempStartDate
                                                                                                        , p_EndDate     => l_TempEndDate
                                                                                                        , p_increment   => x_Preferences.ApptIncrement
                                                                                                        , x_min_time    => x_Preferences.MinStartTime
                                                                                                        , x_max_time    => x_Preferences.MaxEndTime
                                                                                                        );
                              END IF;
                      END IF;
                      -- Increment the dates.
                      IF (l_TempItemDisplayType = 5)
                      THEN
                         l_TempStartDate := TRUNC(l_TempStartDate) + 1;
                         l_TempEndDate := TRUNC(l_TempStartDate) + 1 - 1/(24*60*60);
                         IF (l_TempEndDate > l_tab_PersonalTask(l_index).EndDate)
                         THEN
                                l_TempEndDate := l_tab_PersonalTask(l_index).EndDate;
                         END IF;
                         IF (l_TempStartDate >= l_tab_PersonalTask(l_index).EndDate)
                         THEN
                                EXIT;
                         END IF;
                      ELSE
                         EXIT;
                      END IF;
              END LOOP;
          END IF; --Filter tasks 2

        END LOOP PERSONAL_TASKS;
--Added by MPADHIAR for Bug#5037648
        EXIT WHEN C_Tasks%NOTFOUND;
  END LOOP ALL_PERSONAL_TASKS;
  CLOSE c_Tasks;
--Added by MPADHIAR for Bug#5037648 -- Ends here

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
, p_CalSpanDaysProfile   IN  VARCHAR2
, p_GroupRSID            IN  VARCHAR2
, p_Color                IN  VARCHAR2
, p_prefix               IN  VARCHAR2
, x_index                IN OUT NOCOPY	BINARY_INTEGER
, x_DisplayItems         IN OUT NOCOPY	Jtf_Cal_Pvt.QueryOutTab
, x_Preferences          IN OUT NOCOPY	Jtf_Cal_Pvt.Preference
) IS

CURSOR c_Items
  /*****************************************************************************
  ** This Cursor will fetch all Calendar Items related to a Resource
  *****************************************************************************/
  ( b_ResourceID   IN NUMBER
  , b_ResourceType IN VARCHAR2
  , b_StartDate    IN DATE
  , b_EndDate      IN DATE
  )IS SELECT DISTINCT jtb.source_id          ItemSourceID
      --,      jtb.source_code        ItemSourceCode
      , jtf_cal_items_pvt.GetName(jtb.SOURCE_CODE, jtb.SOURCE_ID) ItemName
      ,      jtb.source_code        SourceCode
      ,      jtb.source_id          SourceID
      ,      jtb.start_date         StartDate
      ,      jtb.end_date           EndDate
      ,      jtb.timezone_id        TimezoneID
      ,      jtb.url                URL
      ,      jtf_cal_items_pvt.GetUrlParams(jtb.SOURCE_CODE, jtb.SOURCE_ID) URLParams
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
      --,      jtb.source_code        ItemSourceCode
      , jtf_cal_items_pvt.GetName(jtb.SOURCE_CODE, jtb.SOURCE_ID) ItemName
      ,      jtb.source_code        SourceCode
      ,      jtb.source_id          SourceID
      ,      jtb.start_date         StartDate
      ,      jtb.end_date           EndDate
      ,      jtb.timezone_id        TimezoneID
      ,      jtb.url                URL
      ,      jtf_cal_items_pvt.GetUrlParams(jtb.SOURCE_CODE, jtb.SOURCE_ID) URLParams
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
  --Added by jawang on 11/21/2002 to fix the NOCOPY issue
  l_StartDate            DATE;
  l_EndDate              DATE;
  l_item_name            VARCHAR2(2000);

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

    Jtf_Cal_Utility_Pvt.AdjustForTimezone
                       ( p_source_tz_id    =>  r_PersonalItem .TimezoneID
                       , p_dest_tz_id      =>  x_Preferences.Timezone
                       , p_source_day_time =>  l_StartDate
                       , x_dest_day_time   =>  r_PersonalItem .Startdate
                       );

    Jtf_Cal_Utility_Pvt.AdjustForTimezone
                       ( p_source_tz_id    =>  r_PersonalItem .TimezoneID
                       , p_dest_tz_id      =>  x_Preferences.Timezone
                       , p_source_day_time =>  l_EndDate
                       , x_dest_day_time   =>  r_PersonalItem .Enddate
                       );

    l_TempItemDisplayType := Jtf_Cal_Utility_Pvt.GetItemType
                           ( p_SourceCode      => 'CALENDARITEM'
                           , p_PeriodStartDate => p_QueryStartDate
                           , p_PeriodEndDate   => p_QueryEndDate
                           , p_StartDate       => r_PersonalItem.StartDate
                           , p_EndDate         => r_PersonalItem.EndDate
                           , p_CalSpanDaysProfile => p_CalSpanDaysProfile
                           );


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
          -- Trim names longer than 80 (77 + ...)
          l_item_name :=  p_prefix || r_PersonalItem.ItemName;
          IF (length( l_item_name) > 77) THEN
                 l_item_name := SUBSTR(l_item_name, 1, 77) || '...';
          END IF;
		  x_DisplayItems(x_index).ItemName	        := l_item_name;
		  x_DisplayItems(x_index).AccessLevel       := 1;
		  x_DisplayItems(x_index).InviteIndicator   := 0;
		  x_DisplayItems(x_index).RepeatIndicator   := 0;
		  x_DisplayItems(x_index).StartDate         := l_TempStartDate;
		  x_DisplayItems(x_index).EndDate           := l_TempEndDate;
		  x_DisplayItems(x_index).URL               := r_PersonalItem.URL;
          x_DisplayItems(x_index).URLParamList        := r_PersonalItem.URLParams;
		  x_DisplayItems(x_index).Color	            := p_Color;
		  x_DisplayItems(x_index).GroupRSID         := p_GroupRSID;

		  /*******************************************************************
		  ** These are populated conditionally, making sure they are NULL
		  *******************************************************************/
		  x_DisplayItems(x_index).PriorityID      := NULL;
		  x_DisplayItems(x_index).PriorityName    := NULL;
		  x_DisplayItems(x_index).CategoryID      := NULL;
		  x_DisplayItems(x_index).CategoryDesc    := NULL;
		  x_DisplayItems(x_index).NoteFlag        := NULL;
		  x_DisplayItems(x_index).TaskOVN         := NULL;
		  x_DisplayItems(x_index).AssignmentOVN   := NULL;

		  /*************************************************************************
		  ** We may have to adjust the display range in the preferences if the items
		  ** to be displayed fall outside the range.
		  *********************************************************************/
		  IF (l_ItemDisplayType = 1)
		  THEN
			Jtf_Cal_Utility_Pvt.AdjustMinMaxTime( p_StartDate   => l_TempStartDate
												, p_EndDate     => l_TempEndDate
												, p_increment   => x_Preferences.ApptIncrement
												, x_min_time    => x_Preferences.MinStartTime
												, x_max_time    => x_Preferences.MaxEndTime
												);
		  END IF;
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


PROCEDURE GetView
/*******************************************************************************
** This procedure will return all task information needed to
** display the daily Calendar page
*******************************************************************************/
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_validation_level       IN     NUMBER
, x_return_status          OUT    NOCOPY	VARCHAR2
, x_msg_count              OUT    NOCOPY	NUMBER
, x_msg_data               OUT    NOCOPY	VARCHAR2
, p_input                  IN     Jtf_Cal_Pvt.QueryIn
, x_DisplayItems           OUT    NOCOPY	Jtf_Cal_Pvt.QueryOutTab
, x_Preferences            OUT    NOCOPY	Jtf_Cal_Pvt.Preference
)IS
  l_LoggedOnRSID         NUMBER;       -- ResourceID of the logged on user
  l_LoggedOnRSType       VARCHAR2(30); -- ResourceType of the logged on user
  l_QueryRSID            NUMBER;       -- ResourceID of the logged on user
  l_QueryRSType          VARCHAR2(30); -- ResourceType of the logged on user
  l_QueryRSName          VARCHAR2(360);-- Resource Name of the logged on user
  l_LoggedOnToday        DATE;         -- Today of logged on user
  l_QueryDate            DATE;         -- Query Date of logged on user
  l_QueryStartDate       DATE;         -- Start of the query period
  l_QueryEndDate         DATE;         -- End of the query period

  l_WeekTimePrefTbl      WeekTimePrefTblType;
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
  l_index                BINARY_INTEGER:=-1;
  CURSOR c_Groups
  /*****************************************************************************
  ** This Cursor will fetch all Groups Calendars the Calendar User is
  ** subscribed to
  *****************************************************************************/
  ( b_ResourceID  IN NUMBER
  )IS SELECT DISTINCT TO_NUMBER(fgs.instance_pk1_value) GroupID
      ,           Jtf_Cal_Utility_Pvt.GetGroupColor
                                     ( b_ResourceID
                                     , 'RS_EMPLOYEE'
                                     , TO_NUMBER(fgs.instance_pk1_value)
                                     )                  Color
      ,           Jtf_Cal_Utility_Pvt.GetGroupPrefix
                                     ( b_ResourceID
                                     , 'RS_EMPLOYEE'
                                     , TO_NUMBER(fgs.instance_pk1_value)
                                     )                  Prefix
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
  /*****************************************************************************
  ** Make sure I have all the Resource Information needed for the logged
  ** on user
  *****************************************************************************/
  IF (  (p_input.LoggedOnRSID IS NULL)
     OR (p_input.LoggedOnRSType IS NULL)
     )
  THEN
    /***************************************************************************
    ** If I didn't get it, try to look it up with the UserID
    ***************************************************************************/
    IF(p_input.UserID IS NULL)
    THEN
      NULL; --error no user information provided, this is not supposed to happen...
    ELSE
      Jtf_Cal_Utility_Pvt.GetResourceInfo( p_UserID       => p_input.UserID
                                         , x_ResourceID   => l_LoggedOnRSID
                                         , x_ResourceType => l_LoggedOnRSType
                                         );
    END IF;

  ELSE
    /***************************************************************************
    ** If I did get it
    ***************************************************************************/
    l_LoggedOnRSID    := p_input.LoggedOnRSID;
    l_LoggedOnRSType  := p_input.LoggedOnRSType;
  END IF;

  /*****************************************************************************
  ** Determine the resource id/type for which the data should be fetched
  *****************************************************************************/
  IF ((p_input.QueryRSID IS NULL) OR (p_input.QueryRSType IS NULL))
  THEN
    l_QueryRSID := l_LoggedOnRSID;
    l_QueryRSType := l_LoggedOnRSType;
  ELSE
    l_QueryRSID := p_input.QueryRSID;
    l_QueryRSType := p_input.QueryRSType;
  END IF;

  /*****************************************************************************
  ** Need to get all the preferences for the current resource
  *****************************************************************************/
  Jtf_Cal_Utility_Pvt.GetPreferences( p_LoggedOnRSID   => l_LoggedOnRSID
                                    , p_LoggedOnRSType => l_LoggedOnRSType
                                    , p_QueryRSID => l_QueryRSID
                                    , p_QueryRSType => l_QueryRSType
                                    , x_Preferences  => x_Preferences
                                    , x_WeekTimePrefTbl => l_WeekTimePrefTbl
                                    , x_CalSpanDaysProfile => l_CalSpanDaysProfile
                                    );

  /***************************************************************************
  ** What is today for the logged on user
  ***************************************************************************/
  Hz_Timezone_Pub.Get_Time( p_api_version     => 1.0
                            , p_init_msg_list   => Fnd_Api.G_FALSE
                            , p_source_tz_id    => TO_NUMBER(NVL(Fnd_Profile.Value('SERVER_TIMEZONE_ID'),'4'))
                            , p_dest_tz_id      => x_Preferences.Timezone
                            , p_source_day_time => SYSDATE -- database sysdate
                            , x_dest_day_time   => l_LoggedOnToday
                            , x_return_status   => l_return_status
                            , x_msg_count       => l_msg_count
                            , x_msg_data        => l_msg_data
                            );

  /*****************************************************************************
  ** Set the Current Time for the Resource
  *****************************************************************************/
  x_Preferences.CurrentTime := l_LoggedOnToday;

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
    ** Weekly is not easy.. Get the start and end of the week for the logged
    ** on user
    ***************************************************************************/
    l_WeekStartDay := x_Preferences.WeekStart;
    l_WeekEndDay   := x_Preferences.WeekEnd;

    /***************************************************************************
    ** Calculate the number of days to be queried
    ***************************************************************************/
    IF (l_WeekEndDay >= l_WeekStartDay)
    THEN
      l_QueryDays := l_WeekEndDay - l_WeekStartDay + 1;
    ELSE
      l_QueryDays := 7 - (l_WeekStartDay - l_WeekEndDay) + 1;
    END IF;

    /***************************************************************************
    ** Now we need to get the 'day' for Query Date
    ***************************************************************************/
    -- get the day number of the LoggedOnToday
    l_DayNumber := MOD((TRUNC(l_QueryDate) - l_SundayDate),7);

    IF (l_DayNumber>=0)
    THEN
       l_DayNumber := 1 + l_DayNumber;
    ELSE
       l_DayNumber := 1 - l_DayNumber;
    END IF;
    -- If for some reason l_DayNumber is not in 1-7 range then reset it.
    IF ((l_DayNumber<1) OR (l_DayNumber>7))
    THEN
       l_DayNumber := l_WeekStartDay;
    END IF;

    /***************************************************************************
    ** Calculate the offset to the begining of the week
    ***************************************************************************/
    IF (
        (  (l_WeekEndDay < l_WeekStartDay) AND
           (l_DayNumber < l_WeekStartDay) AND (l_DayNumber > l_WeekEndDay)
        ) OR
        (  (l_WeekEndDay > l_WeekStartDay) AND
          (
           (l_DayNumber > l_WeekStartDay) AND (l_DayNumber > l_WeekEndDay)
           OR (l_DayNumber < l_WeekStartDay) AND (l_DayNumber < l_WeekEndDay)
          )
        )
       )
    THEN
      /*************************************************************************
      ** The p_Input.StartDate lies outside the work week of the user
      *************************************************************************/
      IF (l_DayNumber > l_WeekStartDay)
      THEN
        /***********************************************************************
        ** Get the next work week
        ***********************************************************************/
        l_offset := 7 - (l_DayNumber - l_WeekStartDay);
      ELSE
        /***********************************************************************
        ** Get the next work week
        ***********************************************************************/
        l_offset := l_WeekStartDay - l_DayNumber;
      END IF;
    ELSE
      /*************************************************************************
      ** The p_Input.StartDate lies within the work week of the user
      *************************************************************************/
      IF (l_WeekStartDay <= l_DayNumber)
      THEN
        /***********************************************************************
        ** Go back to the beginning of the work week
        ***********************************************************************/
        l_offset := -1*(l_DayNumber - l_WeekStartDay);
      ELSE
        /***********************************************************************
        ** Go back to the beginning of the work week
        ***********************************************************************/
        l_offset := -1*(7 - (l_WeekStartDay - l_DayNumber));
      END IF;
    END IF;

   /***************************************************************************
    ** now we can calculate the actual dates..
    ***************************************************************************/
    l_QueryStartDate := TRUNC(l_QueryDate) + l_offset;               -- start of workweek 00:00:00
    l_QueryEndDate   := (l_QueryStartDate + l_QueryDays) - (1/24/60/60); -- end of workweek 23:59:59

  ELSIF (p_Input.QueryMode = 3)
  THEN
    /***************************************************************************
    ** Monthly is easy too
    ***************************************************************************/

    -- Modified by jawang on 09/26/2002 to show previous and next month's appoints and tasks for a given month as well
    l_QueryStartDate := TRUNC(l_QueryDate,'MON'); -- start of month 00:00:00
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
    l_QueryDays      := 0;

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
  FOR I IN l_DayNumber .. l_DayNumber+l_QueryDays-1
  LOOP
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
  END LOOP;
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
  x_Preferences.MinStartTime := TO_DATE(TO_CHAR(l_QueryStartDate,'DD-MON-YYYY')||
                                ' '||TO_CHAR(l_MinDayTime),'DD-MON-YYYY hh24');
  x_Preferences.MaxEndTime   := TO_DATE(TO_CHAR(l_QueryEndDate,'DD-MON-YYYY')||
                                ' '||TO_CHAR(l_MaxDayTime),'DD-MON-YYYY hh24');

 /*****************************************************************************
  ** If it's a personal calendar we need to super impose the tasks/appointments
  ** of groups we subscribed to
  *****************************************************************************/
  IF (l_QueryRSType = 'RS_EMPLOYEE')
  THEN
    FOR r_Groups IN c_Groups(l_QueryRSID)
    LOOP <<GROUPS>>

      /*************************************************************************
      ** The GROUPS loop will get the GROUP_Ids of all Calendar groups
      ** that I am currently a member of
      *************************************************************************/
	  GetApptsAndTasks (
     l_LoggedOnRSID,
     l_LoggedOnRSType,
     r_Groups.GroupID,
     'RS_GROUP',
     l_QueryStartDate,
     l_QueryEndDate,
     p_input.QueryMode,
     l_CalSpanDaysProfile,
     r_Groups.GroupID,
     r_Groups.color,
     r_Groups.Prefix,
     'Y',  -- we are in "personal" calendar
     l_index,
     x_DisplayItems,
     x_Preferences
     );
    END LOOP GROUPS;
  END IF;

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
    NULL,
    '',
    'N',
    l_index,
    x_DisplayItems,
    x_Preferences
    );
    IF NVL(x_preferences.DisplayItems, 'NO') = 'YES' THEN
     GetItems (
     l_LoggedOnRSID,
     l_LoggedOnRSType,
     l_QueryRSID,
     l_QueryRSType,
     l_QueryStartDate,
     l_QueryEndDate,
     p_input.QueryMode,
     'N',
     NULL,
     x_preferences.ItemColor, --Color
     x_preferences.ItemPrefix, --Prefix
    l_index,
    x_DisplayItems,
    x_Preferences
    );
    END IF;

  /*****************************************************************************
  ** Almost done, just have to sort the table
  *****************************************************************************/
  Jtf_Cal_Utility_Pvt.SortTable(x_DisplayItems);

END GetView;

END Jtf_Cal_Pvt;

/
