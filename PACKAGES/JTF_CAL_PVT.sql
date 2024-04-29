--------------------------------------------------------
--  DDL for Package JTF_CAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvhcs.pls 120.2 2005/12/20 05:07:08 sankgupt ship $ */

/*******************************************************************************
** Record type that holds all the information needed to display a Calendar list
*******************************************************************************/
TYPE CalLstRec IS RECORD
( ResourceID	     NUMBER       -- JTF_RESOURCE resource ID of the logged on user
, ResourceType       VARCHAR2(30) -- JTF_RESOURCE resource type of the logged on user (save in the cookie)
, CalendarName       VARCHAR2(360)-- Calendar display name
, AccessLevel        VARCHAR2(80) -- Access level for the calendar
);

/*******************************************************************************
** PL/SQL table TYPE definition for the results of the GetCalendarList procedure
*******************************************************************************/
TYPE CalLstTblType IS TABLE OF CalLstRec INDEX BY BINARY_INTEGER;

/*******************************************************************************
** Record type that holds Start time and End Time for a day
*******************************************************************************/
TYPE WeekTimePrefRec IS RECORD
( DayStart         NUMBER := null     -- Start Hours of day 0-24
, DayEnd           NUMBER := null     -- End Hours of day 0-24
);

/*******************************************************************************
** PL/SQL table that holds Start time and End Time of week days
*******************************************************************************/
TYPE WeekTimePrefTblType IS TABLE OF WeekTimePrefRec INDEX BY BINARY_INTEGER;

/*******************************************************************************
** Record type that holds all the Calendar Preferences
*******************************************************************************/
TYPE Preference IS RECORD
( LoggedOnRSID	       NUMBER        -- JTF_RESOURCE resource ID of the logged on user (save in the cookie)
, LoggedOnRSType       VARCHAR2(30)  -- JTF_RESOURCE resource type of the logged on user (save in the cookie)
, LoggedOnRSName       VARCHAR2(360) -- JTF_RESOURCE resource name of the logged on user
, SendEmail            VARCHAR2(3)   -- 'YES' or 'NO' -- Talk to Sarvi change it to 1/0
, TimeFormat           VARCHAR2(30)  -- fnd_lookup.code
, DateFormat           VARCHAR2(30)  -- fnd_lookup.code
, TimeZone             NUMBER        -- HZ_TIMEZONES.TIMEZONE_ID
, WeekStart            NUMBER        -- fnd_lookup.code
, WeekEnd              NUMBER        -- fnd_lookup.code
, ApptIncrement        NUMBER        -- fnd_lookup.code in minutes
, MinStartTime         DATE          -- MIN(selected(StartDates), Preference(StartDate))
, MaxEndTime           DATE          -- MAX(selected(StartDates), Preference(StartDate))
, CurrentTime          DATE          -- SYSDATE + GMT OFFSET
, DisplayItems         VARCHAR2(3)   -- 'YES' or 'NO'
, ApptColor            VARCHAR2(7)   -- #003333 etc.
, ApptPrefix           VARCHAR2(50)  -- free input field
, TaskColor            VARCHAR2(7)
, TaskPrefix           VARCHAR2(50)
, ItemColor            VARCHAR2(7)
, ItemPrefix           VARCHAR2(50)
, TaskCustomerSource   VARCHAR2(3)
);


TYPE QueryIn IS RECORD
/*******************************************************************************
** Record type that holds all the input iformation needed for the
** Calendar daily/weekly/monthly view
*******************************************************************************/
( UserID             NUMBER        -- FND_USER.USER_ID of the logged on user
, LoggedOnRSID	     NUMBER        -- JTF_RESOURCE resource ID of the logged on user
, LoggedOnRSType     VARCHAR2(30)  -- JTF_RESOURCE resource type of the logged on user
, QueryRSID          NUMBER        -- JTF_RESOURCE resource ID of the queried user
, QueryRSType        VARCHAR2(30)  -- JTF_RESOURCE resource Type of the queried user
, StartDate          DATE          -- User StartDate of days to query: NULL means user's today/this week/this month
, QueryMode          NUMBER        -- 1=daily, 2=weekly, 3=monthly
);

TYPE QueryOut IS RECORD
/*******************************************************************************
** Record type that holds all the output iformation needed for the Calendar
** daily/weekly/monthly view
*******************************************************************************/
( ItemDisplayType          NUMBER         -- 1=Calendar 2=task 3=memo 4=Calendar and task
, ItemSourceID             NUMBER         -- TASK_ID for task and appt
, ItemSourceCode           VARCHAR2(30)   -- For backward comptblty with Tasks Bins
, SourceObjectTypeCode     VARCHAR(60)    -- source_object_type_code
, SourceId                 NUMBER         -- source_id
, CustomerId               NUMBER         -- party_id
, ItemName                 VARCHAR2(130)  -- Display name of the item (prefix will be concatenated)
, AccessLevel              NUMBER         -- 0='anonymous block', 1='full access', 2='read access'
, Color                    VARCHAR2(8)    -- Color for the hyperlink
, InviteIndicator          NUMBER         -- 1 for invite 0 for the rest
, RepeatIndicator          NUMBER         -- 1 for repeating appointments 0 for the rest
, StartDate                DATE           -- Start date for the item
, EndDate                  DATE           -- End date for the item
, URL                      VARCHAR2(2000) -- jsp filename
, URLParamList             VARCHAR(2000)
, PriorityID               NUMBER         -- Priority ID only populated if shown on todo
, PriorityName             VARCHAR2(30)   -- Priority Name only populated if shown on todo
, CategoryID               NUMBER         -- Category ID only populated if shown on todo
, CategoryDesc             VARCHAR2(240)  -- Category Desc only populated if shown on todo
, NoteFlag                 VARCHAR2(1)    -- Note indicator only populated if shown on todo
, TaskOVN                  NUMBER         -- Object Version Number of task only populated if shown on todo
, AssignmentOVN            NUMBER         -- Object Version Number of assignment only populated if shown on todo
, GroupRSID                NUMBER         -- Resource ID of the group who owns the task
);

/*******************************************************************************
** PL/SQL table TYPE definition for the results of the GetView procedure
*******************************************************************************/
TYPE QueryOutTab IS TABLE OF QueryOut INDEX BY BINARY_INTEGER;

PROCEDURE GetCalendarList
/*******************************************************************************
** Given a ResourceID, this procedure will return a list of Calendars that the
** Calendar user has access to
*******************************************************************************/
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level       IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_resourceID             IN OUT NOCOPY   NUMBER
, p_resourceType           IN OUT NOCOPY   VARCHAR2
, p_userID                 IN     NUMBER
, x_calendarList           OUT    NOCOPY   CalLstTblType
);

PROCEDURE GetView
/*******************************************************************************
** This procedure will return all task information needed to display the daily
** Calendar page
*******************************************************************************/
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level       IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_input                  IN     JTF_CAL_PVT.QueryIn
, x_DisplayItems           OUT    NOCOPY   JTF_CAL_PVT.QueryOutTab
, x_Preferences            OUT    NOCOPY   JTF_CAL_PVT.Preference
);

END JTF_CAL_PVT;

 

/
