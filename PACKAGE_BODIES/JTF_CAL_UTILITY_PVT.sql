--------------------------------------------------------
--  DDL for Package Body JTF_CAL_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_UTILITY_PVT" AS
/* $Header: jtfvcub.pls 120.1 2005/07/02 01:39:10 appldev ship $ */

  FUNCTION GetUserName
  /*****************************************************************************
  ** This function will pick up the user name of the given Resource ID
  *****************************************************************************/
  (p_resource_id   IN NUMBER
  )RETURN VARCHAR2
  IS

    CURSOR c_GetInfo
    ( b_resource_id IN NUMBER
    )IS SELECT jrb.user_name
        FROM jtf_rs_resource_extns jrb
        WHERE jrb.resource_id = b_resource_id;

    l_UserName VARCHAR2(360);

  BEGIN
    IF (c_GetInfo%ISOPEN)
    THEN
      CLOSE c_GetInfo;
    END IF;

    OPEN c_GetInfo(p_resource_id);
    FETCH c_GetInfo INTO l_UserName;

    IF (c_GetInfo%FOUND)
    THEN
      IF (c_GetInfo%ISOPEN)
      THEN
        CLOSE c_GetInfo;
      END IF;
      RETURN l_UserName;
    ELSE
      IF (c_GetInfo%ISOPEN)
      THEN
        CLOSE c_GetInfo;
      END IF;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_GetInfo%ISOPEN)
      THEN
        CLOSE c_GetInfo;
      END IF;
      RETURN NULL;
  END GetUserName;

  FUNCTION GetResourceName
  /****************************************************************
  ** This function will pick up the name of the given Resource Id.
  ****************************************************************/
  (p_resource_id   IN NUMBER
  ,p_resource_type IN VARCHAR2
  )RETURN VARCHAR2
  IS
    CURSOR c_GetGroupInfo(b_resource_id IN NUMBER)
    IS SELECT jrt.group_name resource_name
       FROM jtf_rs_groups_tl   jrt
       WHERE jrt.group_id = b_resource_id
       AND   jrt.language = userenv('LANG');

    CURSOR c_GetInduvidualInfo(b_resource_id IN NUMBER)
    IS SELECT jrt.resource_name
       FROM jtf_rs_resource_extns_tl   jrt
       WHERE jrt.resource_id = b_resource_id
       AND   jrt.language = userenv('LANG');

    l_ResourceInfo VARCHAR2(360);

  BEGIN
    IF (p_resource_type = 'RS_EMPLOYEE')
    THEN
      IF (c_GetInduvidualInfo%ISOPEN)
      THEN
        CLOSE c_GetInduvidualInfo;
      END IF;

      OPEN c_GetInduvidualInfo(p_resource_id
                              );
      FETCH c_GetInduvidualInfo INTO l_ResourceInfo;
      IF (c_GetInduvidualInfo%FOUND)
      THEN
        IF (c_GetInduvidualInfo%ISOPEN)
        THEN
          CLOSE c_GetInduvidualInfo;
        END IF;
        RETURN l_ResourceInfo;
      ELSE
        IF (c_GetInduvidualInfo%ISOPEN)
        THEN
          CLOSE c_GetInduvidualInfo;
        END IF;
        RETURN NULL;
      END IF;
    ELSIF (p_resource_type = 'RS_GROUP')
    THEN
      IF (c_GetGroupInfo%ISOPEN)
      THEN
        CLOSE c_GetGroupInfo;
      END IF;

      OPEN c_GetGroupInfo(p_resource_id
                         );
      FETCH c_GetGroupInfo INTO l_ResourceInfo;
      IF (c_GetGroupInfo%FOUND)
      THEN
        IF (c_GetGroupInfo%ISOPEN)
        THEN
          CLOSE c_GetGroupInfo;
        END IF;
        RETURN l_ResourceInfo;
      ELSE
        IF (c_GetGroupInfo%ISOPEN)
        THEN
          CLOSE c_GetGroupInfo;
        END IF;
        RETURN NULL;
      END IF;
    ELSE
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_GetGroupInfo%ISOPEN)
      THEN
        CLOSE c_GetGroupInfo;
      END IF;
      IF (c_GetInduvidualInfo%ISOPEN)
      THEN
        CLOSE c_GetInduvidualInfo;
      END IF;
      RETURN NULL;
  END GetResourceName;

  PROCEDURE GetResourceInfo
  /***************************************************************
  ** This Procedure will return the ResourceID and ResourceType
  ** for the current FND_USER
  ***************************************************************/
  ( p_UserID       IN     NUMBER
  , x_ResourceID      OUT NOCOPY	NUMBER
  , x_ResourceType    OUT NOCOPY	VARCHAR2
  )IS
   CURSOR c_ResourceInfo
   ( b_UserID   NUMBER
   )IS SELECT jrb.resource_id     ResourceID
       ,      'RS_'||jrb.category ResourceType
       FROM jtf_rs_resource_extns    jrb
       WHERE jrb.user_id = b_UserID;

   r_ResourceInfo c_ResourceInfo%ROWTYPE;

   BEGIN
     IF (c_ResourceInfo%ISOPEN)
     THEN
       CLOSE c_ResourceInfo;
     END IF;
     OPEN c_ResourceInfo(p_UserID);
     FETCH c_ResourceInfo INTO r_ResourceInfo;
     IF (c_ResourceInfo%FOUND)
     THEN
       CLOSE c_ResourceInfo;
       x_ResourceID   := r_ResourceInfo.ResourceID;
       x_ResourceType := r_ResourceInfo.ResourceType;
     ELSE
       CLOSE c_ResourceInfo;
       x_ResourceID   := NULL;
       x_ResourceType := NULL;
     END IF;
   END GetResourceInfo;

  PROCEDURE GetResourceInfo
  /***************************************************************
  ** This Procedure will return the ResourceID and ResourceName
  ** for the current FND_USER
  ***************************************************************/
  ( x_ResourceID OUT NOCOPY	VARCHAR2
  , x_ResourceName OUT NOCOPY	VARCHAR2
  )IS
   CURSOR c_ResourceInfo
   IS SELECT jrb.resource_id   ResourceID
      ,      jrt.resource_name ResourceName
      FROM jtf_rs_resource_extns    jrb
      ,    jtf_rs_resource_extns_tl jrt
      WHERE jrb.resource_id = jrt.resource_id
      AND   jrt.language = userenv('LANG')
      AND   jrb.user_id = to_number(fnd_profile.value('USER_ID'));

   r_ResourceInfo c_ResourceInfo%ROWTYPE;

   BEGIN
     IF (c_ResourceInfo%ISOPEN)
     THEN
       CLOSE c_ResourceInfo;
     END IF;
     OPEN c_ResourceInfo;
     FETCH c_ResourceInfo INTO r_ResourceInfo;
     IF (c_ResourceInfo%FOUND)
     THEN
       CLOSE c_ResourceInfo;
       x_ResourceID   := r_ResourceInfo.ResourceID;
       x_ResourceName := r_ResourceInfo.ResourceName;
     ELSE
       CLOSE c_ResourceInfo;
       x_ResourceID   := -1;
       x_ResourceName := NULL;
     END IF;
   END GetResourceInfo;


  PROCEDURE GetResourceInfo
  /***************************************************************
  ** This Procedure will return the ResourceID and ResourceName
  ** for the passed user id
  ***************************************************************/
  ( p_userid       IN     NUMBER
   , x_ResourceID      OUT NOCOPY	NUMBER
   , x_ResourceType    OUT NOCOPY	VARCHAR2
   , x_ResourceName    OUT NOCOPY	VARCHAR2
  )IS
   CURSOR c_ResourceInfo
   ( b_UserID   NUMBER
   ) IS SELECT jrb.resource_id   ResourceID
      ,      'RS_'||jrb.category ResourceType
      ,      jrt.resource_name ResourceName
      FROM jtf_rs_resource_extns    jrb
      ,    jtf_rs_resource_extns_tl jrt
      WHERE jrb.resource_id = jrt.resource_id
      AND   jrt.language = userenv('LANG')
      AND   jrb.user_id = b_UserID;

   r_ResourceInfo c_ResourceInfo%ROWTYPE;

   BEGIN
     IF (c_ResourceInfo%ISOPEN)
     THEN
       CLOSE c_ResourceInfo;
     END IF;
     OPEN c_ResourceInfo(p_userid);
     FETCH c_ResourceInfo INTO r_ResourceInfo;
     IF (c_ResourceInfo%FOUND)
     THEN
       CLOSE c_ResourceInfo;
       x_ResourceID   := r_ResourceInfo.ResourceID;
       x_ResourceType   := r_ResourceInfo.ResourceType;
       x_ResourceName := r_ResourceInfo.ResourceName;
     ELSE
       CLOSE c_ResourceInfo;
       x_ResourceID   := -1;
       x_ResourceType := NULL;
       x_ResourceName := NULL;
     END IF;
   END GetResourceInfo;

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


  FUNCTION GetItemType
  /*****************************************************************************
  ** This function will return the calendar item type based on whether
  ** its begin and end date/time are defined. The type will determine
  ** where on the calendar the item is shown 1=Calendar 2=task 3=memo
  *****************************************************************************/
  ( p_SourceCode      IN VARCHAR2
  , p_PeriodStartDate IN DATE
  , p_PeriodEndDate   IN DATE
  , p_StartDate       IN DATE
  , p_EndDate         IN DATE
  )RETURN NUMBER
  IS
  BEGIN
     RETURN GetItemType
            (
               p_SourceCode,
               p_PeriodStartDate,
               p_PeriodEndDate,
               p_StartDate,
               p_EndDate,
               fnd_profile.value('JTF_CAL_SPAN_DAYS')
            );
/*
     IF (p_StartDate IS NULL)
     THEN
       ************************************************************************
       ** Blank start date items are no views candidate
       ************************************************************************
       RETURN 2;
     END IF;

     IF    (p_SourceCode = 'APPOINTMENT')
     THEN
       ************************************************************************
       ** It's an appointment apply appointment rules
       ************************************************************************
       IF ((p_EndDate - p_StartDate) = 0)
       THEN
         **********************************************************************
         ** Untimed Appointments are always displayed as memo
         **********************************************************************
         RETURN 3;
       ELSIF (p_StartDate < p_PeriodStartDate)
       THEN
         **********************************************************************
         ** It started before the period we want to display: memo
         **********************************************************************
         RETURN 3;
       ELSIF (p_EndDate > p_PeriodEndDate)
       THEN
         **********************************************************************
         ** It ended after the period we want to display: memo
         **********************************************************************
         RETURN 3;
       ELSE
         **********************************************************************
         ** It's completely within the period we want to display: Calendar
         **********************************************************************
         RETURN 1;
       END IF;
     ELSIF (p_SourceCode = 'CALENDARITEM')
     THEN
       ************************************************************************
       ** It's a calendar item apply calendar item rules
       ************************************************************************
       IF (p_EndDate IS NULL)
       THEN
         **********************************************************************
         ** Untimed calendar items are always displayed as memo
         **********************************************************************
         RETURN 3;
       ELSIF (TRUNC(p_StartDate) <> TRUNC (p_EndDate))
       THEN
         **********************************************************************
         ** It spans accross multiple days : memo
         **********************************************************************
         RETURN 3;
       ELSE
         **********************************************************************
         ** It's completely within the period we want to display: Calendar
         **********************************************************************
         RETURN 1;
       END IF;
     ELSE
       ************************************************************************
       ** It's a Task apply rules for tasks
       ************************************************************************
       IF (p_EndDate IS NULL)
       THEN
         **********************************************************************
         ** Untimed calendar items are always displayed as memo
         **********************************************************************
         RETURN 3;
       ELSIF (TRUNC(p_StartDate) = TRUNC (p_EndDate))
       THEN
         **********************************************************************
         ** It's completely within the period, so it should be shown on the
         ** calendar and the task list
         **********************************************************************
         RETURN 4;
       ELSE
         **********************************************************************
         ** It spans accross multiple days : memo
         **********************************************************************
         RETURN 3;
       END IF;
     END IF;
 */
  END GetItemType;

  FUNCTION GetItemStatus( p_task_status_id IN NUMBER)RETURN VARCHAR2
  IS
    CURSOR c_Status(b_task_status_id IN NUMBER)
    IS SELECT jtl.Name
       FROM jtf_task_statuses_tl jtl
       WHERE jtl.task_status_id = b_task_status_id
       AND   jtl.language = userenv('LANG');

    r_Status c_Status%ROWTYPE;

  BEGIN
    IF (c_status%ISOPEN)
    THEN
      CLOSE c_status;
    END IF;
    OPEN c_Status(p_task_status_id);
    FETCH c_Status INTO r_Status;
    IF (c_Status%FOUND)
    THEN
      IF (c_status%ISOPEN)
      THEN
        CLOSE c_status;
      END IF;
      RETURN r_Status.Name;
    ELSE
      IF (c_status%ISOPEN)
      THEN
        CLOSE c_status;
      END IF;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_status%ISOPEN)
      THEN
        CLOSE c_status;
      END IF;
      RETURN NULL;

  END GetItemStatus;

  FUNCTION GetItemURL( p_task_id          IN NUMBER
                     , p_task_source_code IN VARCHAR2
                     )RETURN VARCHAR2
  IS
  /**
    CURSOR c_URL(b_task_source_code IN VARCHAR2)
    IS SELECT  SUBSTR(fff.web_html_call,1,
               DECODE(INSTR(fff.web_html_call,'?'),0,LENGTH(fff.web_html_call),
               INSTR(fff.web_html_call,'?')-1)) agent
       FROM fnd_form_functions fff, jtf_objects_b jtb
       WHERE jtb.object_code = b_task_source_code
       AND   fff.fUNCTION_ID = jtb.web_function_id;
  **/
    CURSOR c_URL(b_task_source_code IN VARCHAR2)
    IS SELECT  jtb.URL agent
       FROM jtf_objects_b jtb
       WHERE jtb.object_code = b_task_source_code;

    r_URL c_URL%ROWTYPE;

  BEGIN
	IF (p_task_source_code='APPOINTMENT')
	THEN
		RETURN 'jtfCalApptMain.jsp';
	ELSE
		RETURN 'jtfTaskMain.jsp';
	END IF;

/**COMMENTED
    IF (c_URL%ISOPEN)
    THEN
      CLOSE c_URL;
    END IF;
    OPEN c_URL(p_task_source_code);
    FETCH c_URL INTO r_URL;
    IF (c_URL%FOUND)
    THEN
      IF (c_URL%ISOPEN)
      THEN
        CLOSE c_URL;
      END IF;
      RETURN r_URL.agent;
    ELSE
      IF (c_URL%ISOPEN)
      THEN
        CLOSE c_URL;
      END IF;
      RETURN NULL;
    END IF;
**/
  EXCEPTION
   WHEN OTHERS
   THEN
      IF (c_URL%ISOPEN)
      THEN
        CLOSE c_URL;
      END IF;
      RETURN NULL;

  END GetItemURL;

  FUNCTION GetCategoryName
  (p_category_id NUMBER)RETURN VARCHAR2
  IS
    CURSOR c_category
    (b_category_id NUMBER)
    IS SELECT perz_data_desc name
       FROM jtf_perz_data
       WHERE perz_data_id = b_category_id;

    r_Category c_Category%ROWTYPE;

  BEGIN
    IF (c_category%ISOPEN)
    THEN
      CLOSE c_category;
    END IF;

    OPEN c_category(p_category_id);

    FETCH c_category INTO r_category;
    IF (c_category%FOUND)
    THEN
      IF (c_category%ISOPEN)
      THEN
        CLOSE c_category;
      END IF;
      RETURN r_category.name;
    ELSE
      IF (c_category%ISOPEN)
      THEN
        CLOSE c_category;
      END IF;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_category%ISOPEN)
      THEN
        CLOSE c_category;
      END IF;
      RETURN NULL;
  END GetCategoryName;

  FUNCTION GetTaskPriority
  (p_task_priority_id NUMBER)RETURN VARCHAR2
  IS
    CURSOR c_Priority
    (b_task_priority_id NUMBER)
    IS SELECT name
       FROM jtf_task_priorities_tl
       WHERE task_priority_id = b_task_priority_id
       AND   language = userenv('LANG');

    r_Priority c_Priority%ROWTYPE;

  BEGIN
    IF (c_Priority%ISOPEN)
    THEN
      CLOSE c_Priority;
    END IF;

    OPEN c_Priority(p_task_priority_id);

    FETCH c_priority INTO r_priority;
    IF (c_priority%FOUND)
    THEN
      IF (c_Priority%ISOPEN)
      THEN
        CLOSE c_Priority;
      END IF;
      RETURN r_priority.name;
    ELSE
      IF (c_Priority%ISOPEN)
      THEN
        CLOSE c_Priority;
      END IF;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_Priority%ISOPEN)
      THEN
        CLOSE c_Priority;
      END IF;
      RETURN NULL;
  END GetTaskPriority;

  FUNCTION TaskHasNotes
  (p_task_id  IN NUMBER)RETURN VARCHAR2
  IS

    CURSOR c_notes(b_task_id IN NUMBER)
    IS SELECT jtf_note_id
       FROM jtf_notes_b
       WHERE source_object_code = 'TASK'
       AND   source_object_id = b_task_id
       AND   ROWNUM = 1;

   l_note_id NUMBER;

  BEGIN
    IF (c_notes%ISOPEN)
    THEN
      CLOSE c_Notes;
    END IF;

    OPEN c_notes(p_task_id);

    FETCH c_notes INTO l_note_id;
    IF (c_notes%FOUND)
    THEN
      IF (c_notes%ISOPEN)
      THEN
        CLOSE c_notes;
      END IF;
      RETURN 'Y';
    ELSE
      IF (c_notes%ISOPEN)
      THEN
        CLOSE c_notes;
      END IF;
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_notes%ISOPEN)
      THEN
        CLOSE c_notes;
      END IF;
      RETURN 'N';
  END TaskHasNotes;

  FUNCTION GetGroupColor
  (p_ResourceID   NUMBER   -- Resource ID of calendar user
  ,p_ResourceType VARCHAR2 -- Resource Type of Calendar User
  ,p_GroupID      NUMBER   -- Group ID of Group Calendar
  )RETURN VARCHAR2
  IS CURSOR c_Group
     (b_ResourceID   NUMBER   -- Resource ID of calendar user
     ,b_ResourceType VARCHAR2 -- Resource Type of Calendar User
     ,b_GroupID      NUMBER   -- Group ID of Group Calendar
     )IS SELECT  jpa.attribute_value color
         FROM   jtf_perz_profile      jpp
         ,      jtf_perz_data         jpd
         ,      jtf_perz_data_attrib  jpa
         WHERE  jpp.profile_name   =  to_char(b_ResourceID)||':JTF_CAL'
         AND    jpp.profile_id     =  jpd.profile_id
         AND    jpa.perz_data_id   =  jpd.perz_data_id
         AND    jpa.attribute_name =  to_char(b_GroupID)||':COLOR';

   l_color VARCHAR2(300);

  BEGIN

    IF (c_Group%ISOPEN)
    THEN
      CLOSE c_Group;
    END IF;

    OPEN c_Group(p_ResourceID
                ,p_ResourceType
                ,p_GroupID
                );

    FETCH c_Group INTO l_Color;
    IF (c_Group%FOUND)
    THEN
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN l_Color;
    ELSE
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN NULL;
  END GetGroupColor;

  FUNCTION GetGroupColorName(p_ResourceID   NUMBER   -- Resource ID of calendar user
                            ,p_ResourceType VARCHAR2 -- Resource Type of Calendar User
                            ,p_GroupID      NUMBER   -- Group ID of Group Calendar
                            )RETURN VARCHAR2
  IS CURSOR c_Group
     (b_ResourceID   NUMBER   -- Resource ID of calendar user
     ,b_ResourceType VARCHAR2 -- Resource Type of Calendar User
     ,b_GroupID      NUMBER   -- Group ID of Group Calendar
     )IS SELECT  flu.meaning color
         FROM   jtf_perz_profile      jpp
         ,      jtf_perz_data         jpd
         ,      jtf_perz_data_attrib  jpa
         ,      fnd_lookups           flu
         WHERE  jpp.profile_name   =  to_char(b_ResourceID)||':JTF_CAL'
         AND    jpp.profile_id     =  jpd.profile_id
         AND    jpa.perz_data_id   =  jpd.perz_data_id
         AND    jpa.attribute_name =  to_char(b_GroupID)||':COLOR'
         AND    flu.lookup_type    =  'JTF_CALND_GROUP_COLOR'
         AND    flu.lookup_code    =  jpa.attribute_value;

   l_color VARCHAR2(300);

  BEGIN

    IF (c_Group%ISOPEN)
    THEN
      CLOSE c_Group;
    END IF;

    OPEN c_Group(p_ResourceID
                ,p_ResourceType
                ,p_GroupID
                );

    FETCH c_Group INTO l_Color;
    IF (c_Group%FOUND)
    THEN
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN l_Color;
    ELSE
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN NULL;
  END GetGroupColorName;

  FUNCTION GetGroupPrefix(p_ResourceID   NUMBER   -- Resource ID of calendar user
                         ,p_ResourceType VARCHAR2 -- Resource Type of Calendar User
                         ,p_GroupID      NUMBER   -- Group ID of Group Calendar
                         )RETURN VARCHAR2

  IS CURSOR c_Group
     (b_ResourceID   NUMBER   -- Resource ID of calendar user
     ,b_ResourceType VARCHAR2 -- Resource Type of Calendar User
     ,b_GroupID      NUMBER   -- Group ID of Group Calendar
     )IS SELECT  jpa.attribute_value color
         FROM   jtf_perz_profile      jpp
         ,      jtf_perz_data         jpd
         ,      jtf_perz_data_attrib  jpa
         WHERE  jpp.profile_name   =  to_char(b_ResourceID)||':JTF_CAL'
         AND    jpp.profile_id     =  jpd.profile_id
         AND    jpa.perz_data_id   =  jpd.perz_data_id
         AND    jpa.attribute_name =  to_char(b_GroupID)||':PREFIX';

   l_prefix VARCHAR2(300);

  BEGIN

    IF (c_Group%ISOPEN)
    THEN
      CLOSE c_Group;
    END IF;

    OPEN c_Group(p_ResourceID
                ,p_ResourceType
                ,p_GroupID
                );

    FETCH c_Group INTO l_prefix;
    IF (c_Group%FOUND)
    THEN
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN l_prefix;
    ELSE
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_Group%ISOPEN)
      THEN
        CLOSE c_Group;
      END IF;
      RETURN NULL;
END GetGroupPrefix;

PROCEDURE GetPreferences
( p_ResourceID   IN     NUMBER
, p_ResourceType IN     VARCHAR2
, x_Preferences         OUT NOCOPY	JTF_CAL_PVT.Preference
, x_WeekTimePrefTbl     OUT NOCOPY	JTF_CAL_PVT.WeekTimePrefTblType
, x_CalSpanDaysProfile  OUT NOCOPY	VARCHAR2
)
IS
BEGIN
  GetPreferences
  (
     p_ResourceID,
     p_ResourceType,
     x_Preferences,
     x_WeekTimePrefTbl
  );

  x_CalSpanDaysProfile := fnd_profile.value('JTF_CAL_SPAN_DAYS');

END GetPreferences;

PROCEDURE GetPreferences
  ( p_LoggedOnRSID   IN     NUMBER
  , p_LoggedOnRSType IN     VARCHAR2
  , p_QueryRSID      IN     NUMBER
  , p_QueryRSType    IN     VARCHAR2
  , x_Preferences         OUT NOCOPY	JTF_CAL_PVT.Preference
  , x_WeekTimePrefTbl     OUT NOCOPY	JTF_CAL_PVT.WeekTimePrefTblType
  , x_CalSpanDaysProfile  OUT NOCOPY	VARCHAR2
  ) AS
BEGIN
  GetPreferences
  (
     p_LoggedOnRSID,
     p_LoggedOnRSType,
     x_Preferences,
     x_WeekTimePrefTbl
  );

  --Update preference structure with query res info
  x_Preferences.LoggedOnRSID	     := p_QueryRSID;
  x_Preferences.LoggedOnRSType       := p_QueryRSType;
  x_Preferences.LoggedOnRSName  := GetResourceName( p_QueryRSID
                                                      , p_QueryRSType
                                                      );
  x_CalSpanDaysProfile := fnd_profile.value('JTF_CAL_SPAN_DAYS');

END GetPreferences;

PROCEDURE GetPreferences
( p_ResourceID   IN     NUMBER
, p_ResourceType IN     VARCHAR2
, x_Preferences         OUT NOCOPY	JTF_CAL_PVT.Preference
, x_WeekTimePrefTbl     OUT NOCOPY	JTF_CAL_PVT.WeekTimePrefTblType
)
IS
  CURSOR c_Preference
  (b_ResourceID  IN     NUMBER
  )IS SELECT jpa.attribute_name   AttributeName
      ,      jpa.attribute_value  AttributeValue
      FROM jtf_perz_profile         jpp
      ,    jtf_perz_data            jpd
      ,    jtf_perz_data_attrib     jpa
      WHERE jpp.profile_name   = to_char(b_ResourceID)||':JTF_CAL'
      AND   jpp.profile_id     = jpd.profile_id
      AND   jpd.perz_data_id   = jpa.perz_data_id
      AND   jpa.attribute_name IN ( 'APPT_INCR'
                                  , 'ISSUE_INVITATION'
                                  , 'DISPLAY_ITEMS'
                                  , 'CLOCK_FORMAT'
                                  , 'APPT_PREFIX'
                                  , 'APPT_COLOR'
                                  , 'TASK_PREFIX'
                                  , 'TASK_COLOR'
                                  , 'ITEM_PREFIX'
                                  , 'ITEM_COLOR'
                                  , 'WEEK_BEGIN'
                                  , 'WEEK_END'
                                  , 'SUNDAY_START'
                                  , 'SUNDAY_END'
                                  , 'MONDAY_START'
                                  , 'MONDAY_END'
                                  , 'TUESDAY_START'
                                  , 'TUESDAY_END'
                                  , 'WEDNESDAY_START'
                                  , 'WEDNESDAY_END'
                                  , 'THURSDAY_START'
                                  , 'THURSDAY_END'
                                  , 'FRIDAY_START'
                                  , 'FRIDAY_END'
                                  , 'SATURDAY_START'
                                  , 'SATURDAY_END'
                                  , 'TASK_CUST_SRC' );

    r_Preference c_Preference%ROWTYPE;
    l_dummyNumber  NUMBER:=0;

BEGIN
  /*****************************************************************************
  ** Initializing with x_Preference with defaults
  *****************************************************************************/
  x_Preferences.LoggedOnRSID	     := p_ResourceID;
  x_Preferences.LoggedOnRSType       := p_ResourceType;
  x_Preferences.SendEmail            := 'YES';
  x_Preferences.DisplayItems         := 'NO';
  x_Preferences.TaskCustomerSource   := 'NO';
  x_Preferences.TimeFormat           := '12';
  x_Preferences.DateFormat           := 'DD-MON-YYYY';
  x_Preferences.TimeZone             := to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),'4'));
  x_Preferences.WeekStart            := 2;
  x_Preferences.WeekEnd              := 6;
  x_Preferences.ApptIncrement        := 30;
  x_Preferences.ApptColor            := '#663300'; --Brown
  x_Preferences.ApptPrefix           := '';
  x_Preferences.TaskColor            := '#663300'; --Brown
  x_Preferences.TaskPrefix           := '';
  x_Preferences.ItemColor            := '#663300'; --Brown
  x_Preferences.ItemPrefix           := '';
  x_Preferences.MinStartTime         := TO_DATE(TO_CHAR(TRUNC(SYSDATE)
                                                       ,'DD-MON-YYYY')||' 09:00'
                                               ,'DD-MON-YYYY HH24:MI');
  x_Preferences.MaxEndTime           := TO_DATE(TO_CHAR(TRUNC(SYSDATE)
                                                       ,'DD-MON-YYYY')||' 18:00'
                                               ,'DD-MON-YYYY HH24:MI');
  IF (c_Preference%ISOPEN)
  THEN
    CLOSE c_Preference;
  END IF;

  FOR r_Preference IN c_Preference(p_ResourceID)
  LOOP
    /***************************************************************************
    ** Preferences found for this user: overwrite the defaults
    ***************************************************************************/
    IF (r_preference.AttributeName = 'APPT_INCR')
    THEN
      x_Preferences.ApptIncrement := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'ISSUE_INVITATION')
    THEN
      x_Preferences.SendEmail := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'DISPLAY_ITEMS')
    THEN
      x_Preferences.DisplayItems := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'TASK_CUST_SRC')
    THEN
      x_Preferences.TaskCustomerSource := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'CLOCK_FORMAT')
    THEN
      x_Preferences.TimeFormat := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'APPT_PREFIX')
    THEN
      x_Preferences.ApptPrefix := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'APPT_COLOR')
    THEN
      x_Preferences.ApptColor := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'TASK_PREFIX')
    THEN
      x_Preferences.TaskPrefix := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'TASK_COLOR')
    THEN
      x_Preferences.TaskColor := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'ITEM_PREFIX')
    THEN
      x_Preferences.ItemPrefix := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'ITEM_COLOR')
    THEN
      x_Preferences.ItemColor := r_preference.AttributeValue;

    ELSIF (r_preference.AttributeName = 'WEEK_BEGIN')
    THEN
      x_Preferences.WeekStart := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'WEEK_END')
    THEN
      x_Preferences.WeekEnd := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'SUNDAY_START')
    THEN
      x_WeekTimePrefTbl(1).DayStart := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'MONDAY_START')
    THEN
      x_WeekTimePrefTbl(2).DayStart := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'TUESDAY_START')
    THEN
      x_WeekTimePrefTbl(3).DayStart := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'WEDNESDAY_START')
    THEN
      x_WeekTimePrefTbl(4).DayStart := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'THURSDAY_START')
    THEN
      x_WeekTimePrefTbl(5).DayStart := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'FRIDAY_START')
    THEN
      x_WeekTimePrefTbl(6).DayStart := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'SATURDAY_START')
    THEN
      x_WeekTimePrefTbl(7).DayStart := TO_NUMBER(r_preference.AttributeValue);

     ELSIF (r_preference.AttributeName = 'SUNDAY_END')
    THEN
      x_WeekTimePrefTbl(1).DayEnd := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'MONDAY_END')
    THEN
      x_WeekTimePrefTbl(2).DayEnd := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'TUESDAY_END')
    THEN
      x_WeekTimePrefTbl(3).DayEnd := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'WEDNESDAY_END')
    THEN
      x_WeekTimePrefTbl(4).DayEnd := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'THURSDAY_END')
    THEN
      x_WeekTimePrefTbl(5).DayEnd := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'FRIDAY_END')
    THEN
      x_WeekTimePrefTbl(6).DayEnd := TO_NUMBER(r_preference.AttributeValue);

    ELSIF (r_preference.AttributeName = 'SATURDAY_END')
    THEN
      x_WeekTimePrefTbl(7).DayEnd := TO_NUMBER(r_preference.AttributeValue);

    END IF;
  END LOOP;

END GetPreferences;

FUNCTION GetAccessLevel
/*******************************************************************************
** Function will return the access level for a task/appointment, if the private
** flag is set the task/appoint is only visible for the owner of the task.
** - 0 no access: show as anonymous block
** - 1 owner access (i.e. page level security applies)
** - 2 read only (i.e. page level gets over ruled)
*******************************************************************************/
( p_PrivateFlag       VARCHAR2
  , p_QueryRSRole     VARCHAR2
  , p_LoggedOnRSID    NUMBER
  , p_LoggedOnRSType  VARCHAR2
  , p_QueryRSID       NUMBER
  , p_QueryRSType     VARCHAR2
  , p_SourceType      VARCHAR2
)RETURN NUMBER
IS
BEGIN
  /*****************************************************************************
  ** Current user is an assignee and should not see the private tasks
  ** Don't do this for Appointment as invitees to private appointment should
  ** be able to see it !@#$
  *****************************************************************************/
  IF (p_QueryRSRole = 'ASSIGNEE')
  THEN
    /***************************************************************************
    ** If Logged on user is not the same as current user then private tasks
    ** shouldn't be visible
    ***************************************************************************/
    IF (((p_QueryRSID <> p_LoggedOnRSID) OR (p_QueryRSType <> p_LoggedOnRSType))
        AND (p_PrivateFlag = 'Y'))
    THEN
      RETURN 0;
/**COMMENTED. ALL PRIVATE TASKS ARE VISIBLE TO ASSIGNEES
    ELSIF ((p_SourceType <> 'APPOINTMENT') AND (p_PrivateFlag = 'Y'))
    THEN
      RETURN 0;
**/
    ELSE
      RETURN 1;
    END IF;

  /*****************************************************************************
  ** Current user is the owner and should see the private task
  *****************************************************************************/
  ELSIF( p_QueryRSRole =  'OWNER')
  THEN
    /***************************************************************************
    ** If Logged on user is not the same as current user then private tasks
    ** shouldn't be visible
    ***************************************************************************/
    IF (((p_QueryRSID <> p_LoggedOnRSID) OR (p_QueryRSType <> p_LoggedOnRSType))
        AND (p_PrivateFlag = 'Y'))
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;

  /*****************************************************************************
  ** Current user is not the owner only be allowed to access this task in
  ** through the read only page
  *****************************************************************************/
  ELSE
    RETURN 2;
  END IF;
END GetAccessLevel;

PROCEDURE AdjustMinMaxTime
/*******************************************************************************
** If there are appointments/tasks scheduled during the period we are displaying
** that fall outside the range set in the user preferences the range will be
** adjusted.
*******************************************************************************/
( p_StartDate   IN      DATE
, p_EndDate     IN      DATE
, p_increment   IN      NUMBER
, x_min_time    IN OUT  NOCOPY	DATE
, x_max_time    IN OUT  NOCOPY	DATE
)
IS
  l_MinDateTimePref DATE;
  l_MaxDateTimePref DATE;
  l_MinDateTimeIn DATE;
  l_MaxDateTimeIn DATE;

  l_NewHrs NUMBER;
  l_OldHrs NUMBER;
  l_EndDate     DATE;
  l_Adjusted    BOOLEAN;
BEGIN


  /*****************************************************************************
  ** Determine the min date/time based on the preferences
  *****************************************************************************/
  --l_MinDateTimePref := x_min_time;

  /*****************************************************************************
  ** Adjust the min value, but it has to be done in the given increments :-(
  *****************************************************************************/
  l_NewHrs := TO_NUMBER(TO_CHAR(p_StartDate,'hh24'));
  l_OldHrs := TO_NUMBER(TO_CHAR(x_min_time,'hh24'));


  --First Adjust the date part, if required.

  IF (trunc(x_min_time) > trunc(p_StartDate))
  THEN
     x_min_time := trunc(p_StartDate) + 1;

  END IF;


  --Now adjust the time part, if required.
  IF (l_OldHrs > l_NewHrs)
  THEN
    x_min_time := trunc(x_min_time) + l_NewHrs/24;
  END IF;
  /*
  WHILE (p_StartDate < l_MinDateTimePref)
  LOOP <<MINTIME>>
    l_MinDateTimePref := l_MinDateTimePref - (p_increment/24/60);
  END LOOP MINTIME;

  x_min_time    := l_MinDateTimePref;
  */
  /*****************************************************************************
  ** Determine the max date/time based on the preferences
  *****************************************************************************/
  --l_MaxDateTimePref := x_max_time;

  /***************************************************************************
  ** Adjust the max value, but it has to be done in the given increments :-(
  ***************************************************************************/
  l_NewHrs := TO_NUMBER(TO_CHAR(p_EndDate,'hh24')) + 1;
  l_OldHrs := TO_NUMBER(TO_CHAR(x_max_time,'hh24'));
  l_Adjusted := false;

  --First Adjust the date part, if required.

  IF (trunc(x_max_time) < trunc(p_EndDate))
  THEN
    x_max_time := TRUNC(p_EndDate) - 1/(60*60*24);
  l_Adjusted := true;
  END IF;



  --Now adjust the time part, if required.
  IF (NOT l_Adjusted)
  THEN
    --First reset the hours, if greater than 23 (should be 0-23)
    IF (l_NewHrs > 23)
    THEN
      l_NewHrs := 23;
    END IF;
    IF (l_OldHrs < l_NewHrs)
    THEN
      l_EndDate := x_max_time;
      x_max_time := trunc(x_max_time) + (l_NewHrs+1)/24;
      --If it goes to the next day then reset it to the previous day at 23:59
      IF (TRUNC(x_max_time) <> TRUNC(l_EndDate))
      THEN
        x_max_time := x_max_time - 1/(60*60*24);
      END IF;
    ELSIF (l_OldHrs = l_NewHrs)
    THEN
      --Compare the minutes part if hours is same
      IF (TO_NUMBER(TO_CHAR(p_EndDate,'mi')) > 0)
      THEN
        l_EndDate := x_max_time;
        x_max_time := trunc(x_max_time) + (l_NewHrs+1)/24;
        --If it goes to the next day then reset it to the previous day at 23:59
        IF (TRUNC(x_max_time) <> TRUNC(l_EndDate))
        THEN
          x_max_time := x_max_time - 1/(60*60*24);
        END IF;
      END IF;
    END IF;
  END IF;

  /*
  WHILE (p_EndDate > l_MaxDateTimePref)
  LOOP <<MAXTIME>>
    l_MaxDateTimePref := l_MaxDateTimePref + (p_increment/24/60);
  END LOOP MAXTIME;

  x_max_time    := l_MaxDateTimePref;
  */

END AdjustMinMaxTime;

PROCEDURE SortTable
  /******************************************************************
  ** We need to sort the output table to make life easier on the
  ** java end.. This is a simple bi-directional bubble sort, which
  ** should do the trick.
  ******************************************************************/
  (p_CalendarItems IN OUT NOCOPY	JTF_CAL_PVT.QueryOutTab
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
      l_record   JTF_CAL_PVT.QueryOut;
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
        IF p_CalendarItems(l_high).StartDate < p_CalendarItems(l_high - 1).StartDate
        THEN
          Swap(l_high);
          FOR l_low IN REVERSE 1 .. (l_high - 1)
          LOOP <<LOW>>
            IF p_CalendarItems(l_low).StartDate < p_CalendarItems(l_low - 1).StartDate
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

PROCEDURE AdjustForTimezone
( p_source_tz_id     IN     NUMBER
, p_dest_tz_id       IN     NUMBER
, p_source_day_time  IN     DATE
, x_dest_day_time       OUT NOCOPY	DATE
)
IS
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  l_SourceTimezoneID NUMBER;

BEGIN
  IF (p_source_day_time IS NOT NULL)
  THEN
    /****************************************************************************
    ** NULL is the same in every timezone
    ****************************************************************************/
    IF (p_source_tz_id IS NULL)
    THEN
      /**************************************************************************
      ** If the timezone is not defined used the profile value
      **************************************************************************/
      --l_SourceTimezoneID := to_number(FND_PROFILE.Value('JTF_CAL_DEFAULT_TIMEZONE'));
        l_SourceTimezoneID := to_number(FND_PROFILE.Value('SERVER_TIMEZONE_ID'));
      --l_SourceTimezoneID := to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),4));
    ELSE
      l_SourceTimezoneID := p_source_tz_id;
    END IF;
    /***********************************************************************
    ** Only adjust if the timezones are different
    ***********************************************************************/
    IF (l_SourceTimezoneID <> p_dest_tz_id)
    THEN
      /*********************************************************************
      ** Call the API to get the adjusted date (this API is slow..)
      *********************************************************************/
      HZ_TIMEZONE_PUB.Get_Time( p_api_version     => 1.0
                              , p_init_msg_list   => FND_API.G_FALSE
                              , p_source_tz_id    => l_SourceTimezoneID
                              , p_dest_tz_id      => p_dest_tz_id
                              , p_source_day_time => p_source_day_time
                              , x_dest_day_time   => x_dest_day_time
                              , x_return_status   => l_return_status
                              , x_msg_count       => l_msg_count
                              , x_msg_data        => l_msg_data
                              );
    ELSE
      x_dest_day_time := p_source_day_time;
    END IF;
  ELSE
    x_dest_day_time := NULL;
  END IF;
END AdjustForTimezone;

FUNCTION GetUserID
/*****************************************************************************
** This function will pick up the user ID of the given Resource ID
*****************************************************************************/
(p_resource_id   IN NUMBER
)RETURN NUMBER
IS

  CURSOR c_GetInfo
  ( b_resource_id IN NUMBER
  )IS SELECT jrb.user_id
      FROM jtf_rs_resource_extns jrb
      WHERE jrb.resource_id = b_resource_id;

  l_UserID NUMBER;

  BEGIN
    IF (c_GetInfo%ISOPEN)
    THEN
      CLOSE c_GetInfo;
    END IF;

    OPEN c_GetInfo(p_resource_id);
    FETCH c_GetInfo INTO l_UserID;

    IF (c_GetInfo%FOUND)
    THEN
      IF (c_GetInfo%ISOPEN)
      THEN
        CLOSE c_GetInfo;
      END IF;
      RETURN l_UserID;
    ELSE
      IF (c_GetInfo%ISOPEN)
      THEN
        CLOSE c_GetInfo;
      END IF;
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (c_GetInfo%ISOPEN)
      THEN
        CLOSE c_GetInfo;
      END IF;
      RETURN NULL;
  END GetUserID;

  FUNCTION isValidTimezone (p_timezone_id IN NUMBER)
  RETURN BOOLEAN
  IS
  CURSOR c_timezone_id
      IS
  SELECT 1
   FROM hz_timezones
  WHERE timezone_id = p_timezone_id
  AND ROWNUM = 1;
  l_exist NUMBER;

  BEGIN
  OPEN c_timezone_id;
  FETCH c_timezone_id INTO l_exist;
  IF c_timezone_id%NOTFOUND THEN
    CLOSE c_timezone_id;
    RETURN FALSE;
  ELSE
    CLOSE c_timezone_id;
    RETURN TRUE;
  END IF;
 END isValidTimezone;

 FUNCTION isValidObjectCode (p_object_code IN VARCHAR2)
 RETURN BOOLEAN
 IS
 CURSOR c_object_code
      IS
  SELECT 1
   FROM jtf_objects_b
  WHERE object_code = p_object_code
  AND ROWNUM = 1;
  l_exist NUMBER;

  BEGIN
  OPEN c_object_code;
  FETCH c_object_code INTO l_exist;
  IF c_object_code%NOTFOUND THEN
    CLOSE c_object_code;
    RETURN FALSE;
  ELSE
    CLOSE c_object_code;
    RETURN TRUE;
  END IF;

 END;

END JTF_CAL_UTILITY_PVT;

/
