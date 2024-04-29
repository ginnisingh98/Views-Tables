--------------------------------------------------------
--  DDL for Package CAC_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_VIEW_PVT" AUTHID CURRENT_USER AS
/* $Header: cacvps.pls 120.3 2006/02/22 08:35:58 sankgupt noship $ */
/*#
 * This package is used for calendar view.
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Calendar View
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY CAC_APPOINTMENT
 */

/*******************************************************************************
** Record type that holds all the information needed to display a Calendar list
*******************************************************************************/
TYPE CalLstRec IS RECORD
( ResourceID         NUMBER       -- JTF_RESOURCE resource ID of the logged on user
, ResourceType       VARCHAR2(30) -- JTF_RESOURCE resource type of the logged on user (save in the cookie)
, CalendarName       VARCHAR2(360)-- Calendar display name
, AccessLevel        VARCHAR2(80) -- Access level for the calendar
);

/*******************************************************************************
** PL/SQL table TYPE definition for the results of the GetCalendarList procedure
*******************************************************************************/
TYPE CalLstTblType IS TABLE OF CalLstRec INDEX BY BINARY_INTEGER;

TYPE QueryIn IS RECORD
/*******************************************************************************
** Record type that holds all the input iformation needed for the
** Calendar daily/weekly/monthly view
*******************************************************************************/
( UserID             NUMBER        -- FND_USER.USER_ID of the logged on user
, LoggedOnRSID       NUMBER        -- JTF_RESOURCE resource ID of the logged on user
, LoggedOnRSType     VARCHAR2(30)  -- JTF_RESOURCE resource type of the logged on user
, QueryRSID          NUMBER        -- JTF_RESOURCE resource ID of the queried user
, QueryRSType        VARCHAR2(30)  -- JTF_RESOURCE resource Type of the queried user
, EmpLocTimezoneID   NUMBER        -- The timezone id of employee location
, StartDate          DATE          -- User StartDate of days to query: NULL means user's today/this week/this month
, EndDate           DATE           -- User EndDate of days to query: NULL means user's today/this week/this month
, QueryMode          NUMBER        -- 1=daily, 2=weekly, 3=monthly
, ShowApts           CHAR(1)       -- 'Y'/'N' whether to show apts
, ShowTasks          CHAR(1)       -- 'Y'/'N' whether to show tasks
, ShowEvents         CHAR(1)       -- 'Y'/'N' whether to show events
, ShowOpenInvite     CHAR(1)       -- 'Y'/'N' whether to show open invitations
, ShowDeclined       CHAR(1)       -- 'Y'/'N' whether to show declined apts
, ShowBookings       CHAR(1)       -- 'Y'/'N' whether to show Bookings
, ShowHRCalendarEvents CHAR(1)     -- 'Y'/'N' whether to show HR Calendar Events
, ShowSchedules      CHAR(1)       -- 'Y'/'N' whether to show Show Schedules
, AptFirstDetail     CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, AptSecondDetail    CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, AptThirdDetail     CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, InvFirstDetail     CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, InvSecondDetail    CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, InvThirdDetail     CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, DeclFirstDetail    CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, DeclSecondDetail   CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, DeclThirdDetail    CHAR(2)       -- 1 = Attendees, 2 = Location, 3 = Related Items
, ShowBusyTask       CHAR(1)
, ShowFreeTask       CHAR(1)
, ShowTentativeTask  CHAR(1)
, TaskFirstDetail    CHAR(2)
, TaskSecondDetail   CHAR(2)
, TaskThirdDetail    CHAR(2)
, UseCalendarSecurity CHAR(1)      -- 'Y'/'N' whether to use security or not
, ViewTimezoneID     NUMBER        -- The timezone id passed to convert the start times into
);

TYPE QueryOut IS RECORD
/*******************************************************************************
** Record type that holds all the output iformation needed for the Calendar
** daily/weekly/monthly view
*******************************************************************************/
( ItemDisplayType          NUMBER         -- 1=Calendar 2=task 3=memo 4=Calendar and task, 6= HR Calendar Events, 7=Schedules
, ItemSourceID             NUMBER         -- TASK_ID for task and appt
, ItemSourceCode           VARCHAR2(30)   -- For backward comptblty with Tasks Bins
, Source                   VARCHAR2(2000) -- source
, Customer                 VARCHAR2(2000) -- customer
, ItemName                 VARCHAR2(80)   -- Display name of the item (prefix will be concatenated)
, AccessLevel              NUMBER         -- 0='anonymous block', 1='full access', 2='read access'
, AssignmentStatus         NUMBER         -- 1 for invite 0 for the rest
, InviteIndicator          NUMBER         -- 1 for invitations 0 for the rest
, RepeatIndicator          NUMBER         -- 1 for repeating appointments 0 for the rest
, RemindIndicator          NUMBER         -- 1 for reminders 0 for the rest
, StartDate                DATE           -- Start date for the item
, SourceObjectTypeCode     VARCHAR2(60)   -- source_object_type_code
, EndDate                  DATE           -- End date for the item
, URL                      VARCHAR2(2000) -- filename
, URLParamList             VARCHAR(2000)
, Attendees                VARCHAR2(2000)
, Location                 VARCHAR2(4000)
, CustomerConfirmation     CHAR(1)
, Status                   VARCHAR2(30)
, AssigneeStatus           VARCHAR2(30)
, Priority                 VARCHAR2(30)
, TaskType                 VARCHAR2(30)
, Owner                    VARCHAR2(360)
, Description              VARCHAR2(4000)
, GroupRSID                NUMBER         -- Resource ID of the group who owns the task
, FreeBusyType             VARCHAR2(30)
, DisplayColor             VARCHAR2(30)
);

/*******************************************************************************
** PL/SQL table TYPE definition for the results of the GetView procedure
*******************************************************************************/
TYPE QueryOutTab IS TABLE OF QueryOut INDEX BY BINARY_INTEGER;

/**
 * Given a ResourceID, this procedure will return a list of Calendars that the Calendar user has access to
 * @param p_api_version API version number
 * @param p_init_msg_list a flag to indicate if message list is initialized
 * @param p_validation_level validation level (not used)
 * @param x_return_status return status
 * @param x_msg_count the number of message
 * @param x_msg_data message data
 * @param p_resourceID resource id
 * @param p_resourceType resource type code
 * @param p_userID user id
 * @param x_calendarList a list of calendars
 * @rep:displayname Get Calendar List
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE GetCalendarList
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT NULL
, p_validation_level       IN     NUMBER   DEFAULT NULL
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_resourceID             IN OUT NOCOPY   NUMBER
, p_resourceType           IN OUT NOCOPY   VARCHAR2
, p_userID                 IN     NUMBER
, x_calendarList           OUT    NOCOPY   CalLstTblType
);

/**
 * This procedure will return all task information needed to display the daily Calendar page
 * @param p_api_version API version number
 * @param p_init_msg_list a flag to indicate if message list is initialized
 * @param p_validation_level validation level (not used)
 * @param x_return_status return status
 * @param x_msg_count the number of message
 * @param x_msg_data message data
 * @param p_input query criteria
 * @param x_DisplayItems a list of calendar items queried
 * @rep:displayname Get View
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE GetView
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT NULL
, p_validation_level       IN     NUMBER   DEFAULT NULL
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_input                  IN     CAC_VIEW_PVT.QueryIn
, x_DisplayItems           OUT    NOCOPY   CAC_VIEW_PVT.QueryOutTab
);

/**
 * This function will return the location associated with the given calendar
 * @param p_task_id task id
 * @rep:displayname Get Locations
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_locations(p_task_id IN NUMBER)
    RETURN VARCHAR2;

/**
 * This function will return the calendar item type based on whether
 * its begin and end date/time are defined. The type will determine
 * where the calendar the item is shown: 1=Calendar 2=task 3=memo 5=split
 * @param p_SourceCode source code
 * @param p_PeriodStartDate period start date (not used)
 * @param p_PeriodEndDate period end date (not used)
 * @param p_StartDate calendar start date
 * @param p_EndDate calendar end date
 * @param p_CalSpanDaysProfile a flag to indicate if it spans across multiple days
 * @return The item type number
 * @rep:displayname Get Item Type
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION GetItemType
  ( p_SourceCode      IN VARCHAR2
  , p_PeriodStartDate IN DATE
  , p_PeriodEndDate   IN DATE
  , p_StartDate       IN DATE
  , p_EndDate         IN DATE
  , p_CalSpanDaysProfile IN VARCHAR2
  )RETURN NUMBER;

/**
 * This function will return the contact name for the given party id and party type
 * @param p_party_type_code Party Type
 * @param p_party_id Party Id
 * @rep:displayname Get Contact
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_Contact(p_party_type_code in varchar2,p_party_id IN NUMBER)
RETURN VARCHAR2;

END; -- Package spec

 

/
