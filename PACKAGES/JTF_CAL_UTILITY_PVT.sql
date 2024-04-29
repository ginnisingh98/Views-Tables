--------------------------------------------------------
--  DDL for Package JTF_CAL_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvcus.pls 120.1 2005/07/02 01:39:14 appldev ship $ */
/*#
 * Private APIs for the HTML Calendar module.
 * This API facilitates getting user preferences like category, priority, color & timezone
 * @rep:scope private
 * @rep:product CAC
 * @rep:displayname JTF Calendar Utility Private API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_APPOINTMENT
 */

/*#
 * This function will pick up the name of the given Resource Id.
 * @param p_resource_id Input resource Id
 * @param p_resource_type Input resource type
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Resource Name
 */
  FUNCTION GetResourceName(p_resource_id   IN NUMBER
                          ,p_resource_type IN VARCHAR2
                          ) RETURN VARCHAR2;

/*#
 * This function will pick up the user name of the given Resource ID
 * @param p_resource_id Input resource Id
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get User Name
 */
  FUNCTION GetUserName(p_resource_id   IN NUMBER
                      ) RETURN VARCHAR2;

  PROCEDURE GetResourceInfo( x_ResourceID OUT NOCOPY	VARCHAR2
                           , x_ResourceName OUT NOCOPY	VARCHAR2
                           );

  PROCEDURE GetResourceInfo( p_userid       IN     NUMBER
                           , x_ResourceID   OUT    NOCOPY	NUMBER
                           , x_ResourceType OUT    NOCOPY	VARCHAR2
                           );

/*#
 * This Procedure will return the ResourceID and ResourceName for the passed user id
 * @param p_userid Input resource Id
 * @param x_ResourceID Output resource Id
 * @param x_ResourceType Output resource Type
 * @param x_ResourceName Output resource name
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Resource Info
 */
  PROCEDURE GetResourceInfo( p_userid       IN     NUMBER
                           , x_ResourceID   OUT    NOCOPY	NUMBER
                           , x_ResourceType OUT    NOCOPY	VARCHAR2
                           , x_ResourceName OUT    NOCOPY	VARCHAR2
                           );

  FUNCTION GetItemType( p_SourceCode      IN VARCHAR2
                      , p_PeriodStartDate IN DATE
                      , p_PeriodEndDate   IN DATE
                      , p_StartDate       IN DATE
                      , p_EndDate         IN DATE
                      )RETURN NUMBER;

/*#
 * This function will return the calendar item type based on whether
 * its begin and end date/time are defined. The type will determine
 * where on the calendar the item is shown 1=Calendar 2=task 3=memo 5=split
 * @param p_SourceCode  Input source Code
 * @param p_PeriodStartDate Input period start date
 * @param p_PeriodEndDate Input period end date
 * @param p_StartDate Input start date
 * @param p_EndDate Input end date
 * @param p_CalSpanDaysProfile Input Calendar Span Days Profile
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Item Type
 */
  FUNCTION GetItemType( p_SourceCode      IN VARCHAR2
                      , p_PeriodStartDate IN DATE
                      , p_PeriodEndDate   IN DATE
                      , p_StartDate       IN DATE
                      , p_EndDate         IN DATE
                      , p_CalSpanDaysProfile IN VARCHAR2
                      )RETURN NUMBER;

/*#
 * This function will return the calendar item type status
 * @param p_task_status_id  Input Item Type status
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Item Status
 */
  FUNCTION GetItemStatus( p_task_status_id IN NUMBER)RETURN VARCHAR2;

/*#
 * This function will return calendar item url string
 * @param p_task_id  Input task id
 * @param p_task_source_code  Input task source code
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Item URL
 */
  FUNCTION GetItemURL( p_task_id          IN NUMBER
                     , p_task_source_code IN VARCHAR2
                     )RETURN VARCHAR2;

/*#
 * This function will return calendar category name
 * @param p_category_id  a category id
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Item URL
 */
  FUNCTION GetCategoryName(p_category_id NUMBER)RETURN VARCHAR2;

/*#
 * This function will return Task Priority
 * @param p_task_priority_id  Input task priority id
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Task Priority
 */
  FUNCTION GetTaskPriority(p_task_priority_id NUMBER)RETURN VARCHAR2;

  FUNCTION TaskHasNotes(p_task_id  IN NUMBER)RETURN VARCHAR2;

/*#
 * This function will return group color code
 * @param p_ResourceID Input Resource ID of calendar user
 * @param p_ResourceType Input Resource Type of Calendar User
 * @param p_GroupID Input Group ID of Group Calendar
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Group Color
 */
  FUNCTION GetGroupColor(p_ResourceID   NUMBER   -- Resource ID of calendar user
                        ,p_ResourceType VARCHAR2 -- Resource Type of Calendar User
                        ,p_GroupID      NUMBER   -- Group ID of Group Calendar
                        )RETURN VARCHAR2;

/*#
 * This function will return group color name
 * @param p_ResourceID Input Resource ID of calendar user
 * @param p_ResourceType Input Resource Type of Calendar User
 * @param p_GroupID Input Group ID of Group Calendar
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Group Color Name
 */
  FUNCTION GetGroupColorName(p_ResourceID   NUMBER   -- Resource ID of calendar user
                            ,p_ResourceType VARCHAR2 -- Resource Type of Calendar User
                            ,p_GroupID      NUMBER   -- Group ID of Group Calendar
                            )RETURN VARCHAR2;

/*#
 * This function will return group Prefix
 * @param p_ResourceID Input Resource ID of calendar user
 * @param p_ResourceType Input Resource Type of Calendar User
 * @param p_GroupID Input Group ID of Group Calendar
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Group Prefix
 */
  FUNCTION GetGroupPrefix(p_ResourceID   NUMBER   -- Resource ID of calendar user
                         ,p_ResourceType VARCHAR2 -- Resource Type of Calendar User
                         ,p_GroupID      NUMBER   -- Group ID of Group Calendar
                         )RETURN VARCHAR2;

  PROCEDURE GetPreferences
  ( p_ResourceID   IN     NUMBER
  , p_ResourceType IN     VARCHAR2
  , x_Preferences  OUT    NOCOPY	JTF_CAL_PVT.Preference
  , x_WeekTimePrefTbl     OUT 	NOCOPY	JTF_CAL_PVT.WeekTimePrefTblType
  , x_CalSpanDaysProfile  OUT   NOCOPY	VARCHAR2
  );

/*#
 * This Procedure will get the calendar preference detail
 * @param p_LoggedOnRSID Input Logged on Resource ID
 * @param p_LoggedOnRSType Input Logged on Resource Type
 * @param p_QueryRSID Input Query Resource ID
 * @param p_QueryRSType Input Query Resource Type
 * @param x_Preferences output preference date through record object type JTF_CAL_PVT.Preference
 * @param x_WeekTimePrefTbl output preference date through record object type JTF_CAL_PVT.WeekTimePrefTblType
 * @param x_CalSpanDaysProfile Output Calendar Span days Profile value
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Preferences
 */
  PROCEDURE GetPreferences
  ( p_LoggedOnRSID   IN     NUMBER
  , p_LoggedOnRSType IN     VARCHAR2
  , p_QueryRSID      IN     NUMBER
  , p_QueryRSType    IN     VARCHAR2
  , x_Preferences    OUT    NOCOPY	JTF_CAL_PVT.Preference
  , x_WeekTimePrefTbl       OUT NOCOPY	JTF_CAL_PVT.WeekTimePrefTblType
  , x_CalSpanDaysProfile    OUT NOCOPY	VARCHAR2
  );

  PROCEDURE GetPreferences
  ( p_ResourceID   IN     NUMBER
  , p_ResourceType IN     VARCHAR2
  , x_Preferences         OUT NOCOPY	JTF_CAL_PVT.Preference
  , x_WeekTimePrefTbl     OUT NOCOPY	JTF_CAL_PVT.WeekTimePrefTblType
  );

/*#
 * Function will return the access level for a task/appointment, if the private
 * flag is set the task/appoint is only visible for the owner of the task.
 * - 0 no access: show as anonymous block
 * - 1 owner access (i.e. page level security applies)
 * - 2 read only (i.e. page level gets over ruled)
 * @param p_PrivateFlag Input Private flag
 * @param p_QueryRSRole Input Query Resource Role
 * @param p_LoggedOnRSID Input Logged on Resource ID
 * @param p_LoggedOnRSType Input Logged on Resource Type
 * @param p_QueryRSID Input Query Resource ID
 * @param p_QueryRSType Input Query Resource Type
 * @param p_SourceType Input Source type
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Access Level
 */
  FUNCTION GetAccessLevel
  ( p_PrivateFlag     VARCHAR2
  , p_QueryRSRole     VARCHAR2
  , p_LoggedOnRSID    NUMBER
  , p_LoggedOnRSType  VARCHAR2
  , p_QueryRSID       NUMBER
  , p_QueryRSType     VARCHAR2
  , p_SourceType      VARCHAR2
  )RETURN NUMBER;

/*#
 * If there are appointments/tasks scheduled during the period we are displaying
 * that fall outside the range set in the user preferences the range will be
 * adjusted.
 * @param p_StartDate start date
 * @param p_EndDate end date
 * @param p_increment an incremental
 * @param x_min_time min time
 * @param x_max_time max time
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname AdjustMinMaxTime
 */
  PROCEDURE AdjustMinMaxTime
  ( p_StartDate   IN      DATE
  , p_EndDate     IN      DATE
  , p_increment   IN      NUMBER
  , x_min_time    IN OUT  NOCOPY	DATE
  , x_max_time    IN OUT  NOCOPY	DATE
  );

/*#
 * We need to sort the output table to make life easier on the
 * java end.. This is a simple bi-directional bubble sort, which
 * should do the trick.
 * @param p_CalendarItems calendar items
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname SortTable
 */
  PROCEDURE SortTable
  (p_CalendarItems IN OUT NOCOPY	JTF_CAL_PVT.QueryOutTab
  );

  PROCEDURE AdjustForTimezone
  ( p_source_tz_id     IN     NUMBER
  , p_dest_tz_id       IN     NUMBER
  , p_source_day_time  IN     DATE
  , x_dest_day_time    OUT    NOCOPY	DATE
  );

/*#
 * This function will pick up the user ID of the given Resource ID
 * @param p_resource_id resource id
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname GetUserID
 */
  FUNCTION GetUserID
  (p_resource_id   IN NUMBER
  )RETURN NUMBER;

  FUNCTION isValidTimezone (p_timezone_id IN NUMBER)
  RETURN BOOLEAN;

  FUNCTION isValidObjectCode (p_object_code IN VARCHAR2)
  RETURN BOOLEAN;



END JTF_CAL_UTILITY_PVT;

 

/
