--------------------------------------------------------
--  DDL for Package Body JTF_CAL_AVLBLTY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_AVLBLTY_PVT" AS
/* $Header: jtfvavb.pls 115.16 2003/10/28 00:37:24 cjang ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_CAL_AVLBLTY_PVT';

PROCEDURE Availability
( p_api_version         IN     NUMBER
, p_init_msg_list       IN     VARCHAR2
, x_return_status       OUT    NOCOPY	VARCHAR2
, x_msg_count           OUT    NOCOPY	NUMBER
, x_msg_data            OUT    NOCOPY	VARCHAR2
, p_RSList              IN     RSTab
, p_StartDateTime       IN     DATE     -- Start DateTime of the period to check
, p_EndDateTime         IN     DATE     -- End DateTime of the period to check
, p_SlotSize            IN     NUMBER   -- The slot size in minutes
, x_NumberOfSlots       OUT    NOCOPY	NUMBER
, x_AvailbltyList       OUT    NOCOPY	AvlblTb  -- list of resources and their availability
, x_TotalAvailbltyList  OUT    NOCOPY	AvlblTb  -- Total availability
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'Availability';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;
  l_RSSectionStart           NUMBER;
  l_RSSectionEnd             NUMBER;
  l_FirstSlot                NUMBER;
  l_LastSlot                 NUMBER;
  i                          BINARY_INTEGER;
  l_StartDate                DATE;
  l_EndDate                  DATE;

  x_WeekTimePrefTbl          JTF_CAL_PVT.WeekTimePrefTblType;
  x_Preferences              JTF_CAL_PVT.Preference;
  l_ItemDisplayType          NUMBER;

  CURSOR c_Tasks
  /******************************************************************
  ** This Cursor will fetch all Tasks related to an Employee
  ** Resource for the given period
  ******************************************************************/
  ( b_ResourceID   IN NUMBER
  , b_ResourceType IN VARCHAR2
  , b_StartDate    IN DATE
  , b_EndDate      IN DATE
  )IS SELECT jtb.source_object_id             ItemSourceID
      ,      jtb.source_object_type_code      ItemSourceCode
      ,      jtb.calendar_start_date          StartDate
      ,      jtb.calendar_end_date            EndDate
      ,      jtb.timezone_id                  TimezoneID
      FROM jtf_task_all_assignments      jta
      ,    jtf_tasks_b               jtb
      ,    jtf_task_statuses_b       jtsb
      WHERE jta.resource_id          = b_ResourceID        -- 101272224
      AND   jta.resource_type_code   = b_ResourceType      -- 'RS_EMPLOYEE'
      AND   jta.task_id              = jtb.task_id         -- join to tasks_b
      AND   jtb.task_status_id       = jtsb.task_status_id -- join to to task_status_b
      AND   jta.show_on_calendar     = 'Y'
      AND   jta.assignment_status_id <> 4 -- using status rejected for declined
      AND   NVL(jtsb.closed_flag,'N')<> 'Y'
      AND   (   jtb.calendar_start_date <= b_EndDate
            OR  jtb.calendar_start_date IS NULL
            )
      AND   (   jtb.calendar_end_date   >=  b_StartDate
            OR  jtb.calendar_end_date IS NULL
            );

  FUNCTION NumberOfSlots
  /*****************************************************************************
  ** Given a Start, End date and Slot size in minutes this function will
  ** return the number of slots needed for the period.
  *****************************************************************************/
  ( p_StartDate IN DATE
  , p_EndDate   IN DATE
  , p_Slotsize  IN NUMBER
  )RETURN NUMBER
  IS
  BEGIN
    /***************************************************************************
    ** determine the period in minutes, rounded to the smallest number greater
    ** than the result.
    ***************************************************************************/
    RETURN CEIL(((p_EndDate - p_StartDate)*24*60)/p_SlotSize);
  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END NumberOfSlots;

  PROCEDURE InitializeList
  /*****************************************************************************
  ** Given a List of type AvlblTb this function will initialize a range of
  ** records in the table with the given values for:
  ** - ResourceID
  ** - ResourcType
  ** - InitialValue (0 for available, 1 for unavailable)
  ** The slot sequence will be generated
  *****************************************************************************/
  ( p_List          IN OUT NOCOPY	AvlblTb
  , p_StartRecord   IN     NUMBER
  , p_EndRecord     IN     NUMBER
  , p_ResourceID    IN     NUMBER
  , p_ResourceType  IN     VARCHAR2
  , p_ResourceName  IN     VARCHAR2
  , p_InitValue     IN     NUMBER
  )
  IS
    m              BINARY_INTEGER;
    n              NUMBER := 1;
    l_ResourceName VARCHAR2(360);
  BEGIN
    IF (   ( p_ResourceName IS NULL )
       AND ( p_ResourceID   IS NOT NULL )
       AND ( p_ResourceType IS NOT NULL )
       )
    THEN
--      l_ResourceName := JTF_CAL_UTILITY_PVT.GetUserName
--                        (p_resource_id   => p_ResourceID
--                        );
      l_ResourceName := JTF_CAL_UTILITY_PVT.GetResourceName
                        (p_resource_id   => p_ResourceID
                        ,p_resource_type => p_ResourceType
                        );
    ELSE
      l_ResourceName := p_ResourceName;
    END IF;

    FOR m IN p_StartRecord..p_EndRecord
    LOOP
      p_List(m).ResourceID   := p_ResourceID;
      p_List(m).ResourceType := p_ResourceType;
      p_List(m).ResourceName := l_ResourceName;
      p_List(m).SlotSequence := n;
      p_List(m).SlotAvailable:= p_InitValue;
      n := n + 1;
    END LOOP;

  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END InitializeList;

  PROCEDURE Slots
  /*****************************************************************************
  ** - This procedure will determine the slots that are unavailable for a given
  **   period. The period is defined by the Task start date and Task end date.
  ** - If the tasks starts before the StartDate the
  ** - The Number Of Slots is the last slot that will be displayed, therefore
  **   any tasks that span beyond that will return that max number
  *****************************************************************************/
  ( p_StartDate      IN     DATE     -- start of period
  , p_SlotSize       IN     NUMBER   -- Size of the slots used
  , p_NumberOfSlots  IN     NUMBER   -- Max Number of slots
  , p_TaskStartDate  IN     DATE     -- Start time for this task
  , p_TaskEndDate    IN     DATE     -- End time for this task
  , p_FirstSlot      OUT    NOCOPY	 NUMBER   -- output: first slot for task
  , p_LastSlot       OUT    NOCOPY	NUMBER   -- output: last slot for task
  )
  IS
    l_FirstSlot   NUMBER;
    l_LastSlot    NUMBER;

  BEGIN

    l_FirstSlot := TRUNC(round((((p_TaskStartDate - p_StartDate) * 24 * 60)/p_SlotSize),6)) + 1;
    -- - round(,6) because the division doesn't return integers
    -- - add 1 so the slots start with 1 not 0
    l_LastSlot := CEIL((((p_TaskEndDate -(1/24/60/60)) - p_StartDate)* 24 * 60)/p_SlotSize);
    -- - minus 1 second so '1 till 2 meetings' don't take up an extra slot for ending on the
    --   beginning of the next edge

    IF (l_FirstSlot < 1)
    THEN
      -- If it starts before the period we are interested in return 1
      p_FirstSlot := 1;
    ELSE
      p_FirstSlot := l_FirstSlot;
    END IF;

    IF (l_LastSlot > p_NumberOfSlots)
    THEN
     -- If it ends beyond the period we are interested in return NumberOfSlots
      p_LastSlot := p_NumberOfSlots;
    ELSE
      p_LastSlot := l_LastSlot;
    END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Slots;

  PROCEDURE UpdateList
  ( p_List          IN OUT  NOCOPY	AvlblTb  -- List Name
  , p_StartRecord   IN      NUMBER   -- For this RS List section starts with record #
  , p_FirstSlot     IN      NUMBER   -- First Slot to set to unavailable
  , p_LastSlot      IN      NUMBER   -- Last Slot to set to unavailable
  )
  IS
    p BINARY_INTEGER;
  BEGIN
    FOR p IN p_FirstSlot..p_LastSlot
    LOOP <<UNAVAILBLE>>
      p_list(p_StartRecord + (p-1) ).SlotAvailable := 0;
    END LOOP UNAVAILABLE;

  EXCEPTION
    WHEN OTHERS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END UpdateList;

BEGIN
  /*****************************************************************************
  ** Standard call to check for call compatibility
  *****************************************************************************/
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*****************************************************************************
  ** Initialize message list if p_init_msg_list is set to TRUE
  *****************************************************************************/
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  /*****************************************************************************
  ** Initialize API return status to success
  *****************************************************************************/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*****************************************************************************
  ** Get the Timezone of the first user (this is the Query user)
  *****************************************************************************/
  JTF_CAL_UTILITY_PVT.GetPreferences
  ( p_ResourceID   => p_RSList(p_RSList.FIRST).ResourceID
  , p_ResourceType => p_RSList(p_RSList.FIRST).ResourceType
  , x_Preferences  => x_Preferences
  , x_WeekTimePrefTbl => x_WeekTimePrefTbl
  );

  /*****************************************************************************
  ** Determine the total number of slots for the given period
  *****************************************************************************/
  x_NumberOfSlots := NumberOfSlots( p_StartDateTime  -- start of period
                                  , p_EndDateTime    -- end of period
                                  , p_SlotSize       -- slotsize in minutes
                                  );

  /*****************************************************************************
  ** Initialize the total availability list to: everybody is available
  *****************************************************************************/
  InitializeList( x_TotalAvailbltyList     -- ListName
                , 1                        -- start with record #
                , x_NumberOfSlots          -- end with record #
                , NULL                     -- Resource ID
                , NULL                     -- Rescource Type
                , NULL                     -- Resource Name
                , 1                        -- init to 1
                );

  FOR i IN p_RSList.FIRST..p_RSList.LAST
  LOOP <<RESOURCES>>
    /***************************************************************************
    ** Initialize the availability list section for this resource to:
    ** resource is available
    ***************************************************************************/
    l_RSSectionStart := 1 + ((i-1) * x_NumberOfSlots);
    l_RSSectionEnd   := i * x_NumberOfSlots;

    InitializeList( x_AvailbltyList          -- ListName
                  , l_RSSectionStart         -- start with record #
                  , l_RSSectionEnd           -- end with record #
                  , p_RSList(i).ResourceID   -- Resource ID
                  , p_RSList(i).ResourceType -- Rescource Type
                  , p_RSList(i).ResourceName -- Resource Name
                  , 1                        -- init to 1
                  );

    /***************************************************************************
    ** Find all the Tasks assigned to this resource that are shown on Calendar
    ***************************************************************************/
    FOR r_ResourceTask IN c_Tasks( p_RSList(i).ResourceID
                                 , p_RSList(i).ResourceType
                                 , p_StartDateTime - 1 -- allow for max timezone adjustments
                                 , p_EndDateTime   + 1 -- allow for max timezone adjustments
                                 )
    LOOP <<RESOURCE_TASKS>>

      /*************************************************************************
      ** We will have to adjust the Start/End Date for the users timezone (if
      ** needed)
      *************************************************************************/
      /* Rada, make local copies of start and end date to avoid NOCOPY issue*/
      l_StartDate := r_ResourceTask.Startdate;
      l_EndDate   := r_ResourceTask.Enddate;


      JTF_CAL_UTILITY_PVT.AdjustForTimezone
                          ( p_source_tz_id    =>  r_ResourceTask.TimezoneID
                          , p_dest_tz_id      =>  x_Preferences.Timezone
                          , p_source_day_time =>  l_StartDate
                          , x_dest_day_time   =>  r_ResourceTask.Startdate
                          );

      JTF_CAL_UTILITY_PVT.AdjustForTimezone
                          ( p_source_tz_id    =>  r_ResourceTask.TimezoneID
                          , p_dest_tz_id      =>  x_Preferences.Timezone
                          , p_source_day_time =>  l_EndDate
                          , x_dest_day_time   =>  r_ResourceTask.Enddate
                          );

      /***************************************************************************
      ** Now that the StartDate and EndDate are corrected we need to check whether
      ** it we are still interested in it
      ***************************************************************************/
      IF  (   ( r_ResourceTask.StartDate <= p_EndDateTime )
          AND ( r_ResourceTask.EndDate   >  p_StartDateTime)
          )
      THEN
        /*************************************************************************
        ** Determine the display type, only stuff on the calendar is taken into
        ** account for availability
        *************************************************************************/
        l_ItemDisplayType := JTF_CAL_UTILITY_PVT.GetItemType
                             ( p_SourceCode      => r_ResourceTask.ItemSourceCode
                             , p_PeriodStartDate => p_StartDateTime
                             , p_PeriodEndDate   => p_EndDateTime
                             , p_StartDate       => r_ResourceTask.StartDate
                             , p_EndDate         => r_ResourceTask.EndDate
                             , p_CalSpanDaysProfile => 'Y'
                     );

        IF (l_ItemDisplayType IN (1,5))
        THEN
          /*************************************************************************
          ** This procedure will determine what slot are unavailable because of
          ** the task that is fetched
          *************************************************************************/
          Slots( p_StartDateTime          -- start of period
               , p_SlotSize               -- Size of the slots used
               , x_NumberOfSlots          -- Last slot for period
               , r_ResourceTask.StartDate -- Start time for this task
               , r_ResourceTask.EndDate   -- End time for this task
               , l_FirstSlot              -- output: first slot for task
               , l_LastSlot               -- output: last slot for task
               );

          /*************************************************************************
          ** Update the availabity list section of this resource with the Slot
          ** Data
          *************************************************************************/
          UpdateList( x_AvailbltyList      -- List Name
                    , l_RSSectionStart     -- For this RS List section starts with record #
                    , l_FirstSlot          -- First Slot to set to unavailable
                    , l_LastSlot           -- Last Slot to set to unavailable
                    );

          /*************************************************************************
          ** Update the total availabity list with the Slot Data
          *************************************************************************/
          UpdateList( x_TotalAvailbltyList -- List Name
                    , 1                    -- start with record #
                    , l_FirstSlot          -- First Slot to set to unavailable
                    , l_LastSlot           -- Last Slot to set to unavailable
                    );
        END IF;
       END IF;
    END LOOP RESOURCE_TASKS;
  END LOOP RESOURCES;

  /*****************************************************************************
  ** Standard call to get message count and if count is > 1, get message info
  *****************************************************************************/
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END Availability;
END JTF_CAL_AVLBLTY_PVT;

/
