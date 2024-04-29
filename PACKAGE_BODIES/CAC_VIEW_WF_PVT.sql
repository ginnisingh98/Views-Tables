--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_WF_PVT" AS
/* $Header: cacvcwsb.pls 120.4 2006/02/17 05:43:36 sankgupt noship $ */

g_pkg_name     CONSTANT     VARCHAR2(30) := 'CAC_VIEW_WF_PVT';

PROCEDURE wf_role
( p_resource_id     IN     NUMBER
, p_resource_type   IN     VARCHAR2
, x_role         OUT    NOCOPY	VARCHAR2
, x_name         OUT    NOCOPY	VARCHAR2
, x_emp_number      OUT    NOCOPY    NUMBER
)
IS

  l_employee_number    NUMBER;
  l_name               varchar2(320);
  l_email_address      hz_contact_points.EMAIL_ADDRESS%type;

  CURSOR c_resource
  ( b_resourceID    NUMBER
  )IS SELECT source_id  EmployeeNumber
      FROM   JTF_RS_RESOURCE_EXTNS
      WHERE resource_id   = b_ResourceID
      ;

 CURSOR c_contact_detail (b_resource_id NUMBER ) IS
 select pers.PARTY_name , hc.email_ADDRESS
   from hz_parties pers,
        hz_relationships hr,
        hz_contact_points hc
  where hc.owner_table_id = b_resource_id
    and hr.party_id = hc.owner_table_id
    and hr.subject_id = pers.party_id
    and hr.subject_type = 'PERSON'
    and hc.primary_flag = 'Y'
    and hc.contact_point_type = 'EMAIL'
    AND hc.status ='A'
    and hc.owner_table_name = 'HZ_PARTIES';

BEGIN
  ---------------------------------------------------------------------
  -- Get the employee number
  ---------------------------------------------------------------------
  IF (c_Resource%ISOPEN)
  THEN
    CLOSE c_Resource;
  END IF;

  OPEN c_Resource( p_resource_id
                 );
  FETCH c_Resource INTO l_employee_number;
  IF (c_Resource%NOTFOUND)
  THEN
  /*  x_role := NULL;
    x_name := NULL;*/
    --get employee number so adhoc user can be associated with the resource
    x_emp_number := NULL;
     BEGIN
	    --HZ_PARTIES should be populated in the workflow directory
		  WF_DIRECTORY.GetRoleName( p_orig_system     => 'HZ_PARTY'
                            , p_orig_system_id  => p_resource_id
                            , p_name            => x_role
                            , p_display_name    => x_name
                            );
     EXCEPTION
	      WHEN OTHERS THEN
	       -- if we know name and email_address only we can create an adhoc user
          IF (c_contact_detail%ISOPEN)
          THEN
             CLOSE c_contact_detail;
          END IF;

	   OPEN c_contact_detail ( p_resource_id ) ;
	  FETCH c_contact_detail INTO l_name , l_email_address ;
	  CLOSE c_contact_detail ;

	     WF_DIRECTORY.CreateAdHocRole (role_name => l_name
				          ,role_display_name => l_email_address
				         , email_address => l_email_address
				          );
    END;
  ELSE
    -------------------------------------------------------------------------
    -- Call Workflow API to get the role
    -- If there is more than one role for this employee, the API will
    -- return the first one fetched.  If no Workflow role exists for
    -- the employee, out variable will be NULL
    -------------------------------------------------------------------------
    WF_DIRECTORY.GetRoleName( p_orig_system     => 'PER'
                            , p_orig_system_id  => l_employee_number
                            , p_name            => x_role
                            , p_display_name    => x_name
                            );
    x_emp_number := l_employee_number;
  END IF;

  IF (c_Resource%ISOPEN)
  THEN
    CLOSE c_Resource;
  END IF;
  END wf_role;

FUNCTION get_type_name (p_task_type_id IN NUMBER)
      RETURN VARCHAR2
   AS
      l_type_name   VARCHAR2(30);
   BEGIN
      IF p_task_type_id IS NULL
      THEN
     RETURN NULL;
      ELSE
     SELECT name
       INTO l_type_name
       FROM jtf_task_types_tl
      WHERE task_type_id = p_task_type_id
      AND   language = USERENV('LANG');
      END IF;

      RETURN l_type_name;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN NULL;
      WHEN OTHERS
      THEN
     RETURN NULL;
   END;

  FUNCTION get_priority_name (p_task_priority_id IN NUMBER)
      RETURN VARCHAR2
   AS
      l_priority_name   VARCHAR2(30);
   BEGIN
      IF p_task_priority_id IS NULL
      THEN
     RETURN NULL;
      ELSE
     SELECT name
       INTO l_priority_name
       FROM jtf_task_priorities_tl
      WHERE task_priority_id = p_task_priority_id
      AND   language = USERENV('LANG');
      END IF;

      RETURN l_priority_name;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN NULL;
      WHEN OTHERS
      THEN
     RETURN NULL;
   END;
   FUNCTION get_duration (p_minutes IN NUMBER)
      RETURN VARCHAR2
   AS
      l_duration   VARCHAR2(30);
   BEGIN
      IF p_minutes IS NULL
      THEN
     RETURN NULL;
      ELSE
     SELECT lk.meaning
       INTO l_duration
       FROM fnd_lookups lk
      WHERE lk.lookup_type = 'JTF_CALND_DURATION'
       AND lk.lookup_code = p_minutes;
      END IF;

      RETURN l_duration;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN NULL;
      WHEN OTHERS
      THEN
     RETURN NULL;
   END;

FUNCTION GetTimezone
/*******************************************************************************
** Start of comments
**  FUNCTION    : GetTimezon
**  Description : This function will return the name of the timezone when given an ID
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_DayCode   	   IN 		  VARCHAR2
**
** End of comments
******************************************************************************/
(p_timezone_id IN NUMBER
)RETURN VARCHAR2
IS
  CURSOR c_timezone
  (b_timezone_id IN NUMBER
  )IS SELECT htv.name
      FROM hz_timezones_vl htv
      WHERE htv.timezone_id = b_timezone_id;

  l_name VARCHAR2(80):= 'Unknown timezone_id';

BEGIN
  IF (c_timezone%ISOPEN)
  THEN
    CLOSE c_timezone;
  END IF;

  OPEN c_timezone(p_timezone_id);

  FETCH c_timezone INTO l_name;

  CLOSE c_timezone;

  RETURN l_name;

END GetTimezone;


PROCEDURE StartSubscription
/*******************************************************************************
** Start of comments
**  Procedure   : StartSubscription
**  Description : Given the
**  Parameters  :
**      name                direction  type     required?
**      ----                ---------  ----     ---------
**      p_api_version       IN         NUMBER   required
**      p_init_msg_list     IN         VARCHAR2 optional
**      p_commit            IN         VARCHAR2 optional
**      x_return_status        OUT     VARCHAR2 optional
**      x_msg_count            OUT     NUMBER   required
**      x_msg_data             OUT     VARCHAR2 required
**      p_REQUESTOR         IN         NUMBER   required
**      p_GROUP_ID          IN         NUMBER   optional
**  Notes :
**    1)
**
** End of comments
*******************************************************************************/
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2
, p_commit             IN     VARCHAR2
, x_return_status      OUT    NOCOPY	VARCHAR2
, x_msg_count          OUT    NOCOPY	NUMBER
, x_msg_data           OUT    NOCOPY	VARCHAR2
, p_CALENDAR_REQUESTOR IN     NUMBER   -- Resource ID of the Subscriber
, p_GROUP_ID           IN     NUMBER   -- Resource ID of Group Calendar
, p_GROUP_NAME         IN     VARCHAR2 -- Name of the Group Calendar
, p_GROUP_DESCRIPTION  IN     VARCHAR2 -- Description of the Group Calendar
)
IS
   CURSOR c_Admins
   /****************************************************************************
   ** Pick up all the Admins for the given group ID
   ****************************************************************************/
   (b_group_id NUMBER)
   IS SELECT DISTINCT to_number(fgs.grantee_key) ResourceID
      FROM  fnd_grants                 fgs
      ,     fnd_menus                  fmu
      ,     fnd_objects                fos
      WHERE fgs.object_id          = fos.object_id   -- grants joint to object
      AND   fgs.menu_id            = fmu.menu_id     -- grants joint to menus
      AND   fos.obj_name           = 'JTF_TASK_RESOURCE'
      AND   fmu.menu_name          = 'JTF_CAL_ADMIN_ACCESS'
      AND   fgs.instance_pk1_value = to_char(b_group_id)
      AND   fgs.instance_pk2_value = ('RS_GROUP')
      AND   fgs.start_date        <  SYSDATE
      AND   (  fgs.end_date >= SYSDATE
            OR fgs.end_date IS NULL
            )
      ;


  l_api_name        CONSTANT VARCHAR2(30)   := 'StartSubscription';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;

  l_item_type                 VARCHAR2(8) := 'CACVWSWF';
  l_item_key                  VARCHAR2(30);

  l_requestor_role          VARCHAR2(30);
  l_requestor_name          VARCHAR2(80);
  l_requestor_emp_number       NUMBER;

  l_admin_role              VARCHAR2(30);
  l_cal_admin_role          VARCHAR2(30);
  l_admin_name              VARCHAR2(80);
  l_adhoc_role              VARCHAR2(2000);
  l_admin_emp_number         NUMBER;
  no_user      EXCEPTION;
  PRAGMA EXCEPTION_INIT (no_user, -20002);


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

  /***************************************************************************
   ** we need an itemkey
   ***************************************************************************/

  SELECT to_char(cac_vws_itemkey_s.NEXTVAL) INTO l_item_key
    FROM DUAL;

  /*****************************************************************************
  ** Look up the Calendar Administrator from the Profile (this should be an
  ** existing WF_ROLE)
  *****************************************************************************/
  l_cal_admin_role := FND_PROFILE.Value(name => 'JTF_CALENDAR_ADMINISTRATOR');

  l_adhoc_role := fnd_message.get_string('JTF', 'JTF_CAL_WF_GROUP_ADMIN')
    || ' ' || l_item_key;

   /***************************************************************************
    ** Initialize the workflow
    ***************************************************************************/
    wf_engine.CreateProcess( itemtype => l_item_type
                           , itemkey  => l_item_key
                           , process  => 'REQUEST_SUBSCRIBTION'
                           );

    /***************************************************************************
    ** Init Group info
    ***************************************************************************/
    wf_engine.SetItemAttrNumber( itemtype => l_item_type
                               , itemkey  => l_item_key
                               , aname    => 'GROUP_ID'
                               , avalue   => p_GROUP_ID
                               );

    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'CALENDAR_ADMIN'
                             , avalue   => l_cal_admin_role
                             );

    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'GROUP_NAME'
                             , avalue   => p_GROUP_NAME
                             );


    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'GROUP_DESCRIPTION'
                             , avalue   => p_GROUP_DESCRIPTION
                             );

    /***************************************************************************
    ** Init requestor info
    ***************************************************************************/
    WF_Role( p_CALENDAR_REQUESTOR
           , 'RS_EMPLOYEE'       -- Not used, for future enhancements
           , l_requestor_role
           , l_requestor_name
           , l_requestor_emp_number
           );

    wf_engine.SetItemAttrNumber( itemtype => l_item_type
                               , itemkey  => l_item_key
                               , aname    => 'CALENDAR_REQUESTOR'
                               , avalue   => p_CALENDAR_REQUESTOR
                               );

    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'CALENDAR_REQUESTOR_NAME'
                             , avalue   => l_requestor_name
                             );

    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'CALENDAR_REQUESTOR_ROLE'
                             , avalue   => l_requestor_role
                             );
  /*****************************************************************************
  ** Create adHoc role (ER 2198911)
  *****************************************************************************/
   wf_directory.CreateAdHocRole
    ( role_name => l_adhoc_role,
      role_display_name => l_adhoc_role
    );
  /*****************************************************************************
  ** Find all the admins and start a notification WF for all of them.
  *****************************************************************************/
  FOR r_Admin IN c_Admins(p_Group_ID)
  LOOP <<ADMINS>>



    /***************************************************************************
    ** Init admin info
    ***************************************************************************/
    wf_Role( r_Admin.ResourceID
           , 'RS_EMPLOYEE'
           , l_admin_role
           , l_admin_name
           , l_admin_emp_number
           );

    wf_engine.SetItemAttrNumber( itemtype => l_item_type
                               , itemkey  => l_item_key
                               , aname    => 'GROUP_CALENDAR_ADMIN'
                               , avalue   => r_Admin.ResourceID
                               );
   --comment CreateUserRole because it's not available in all versions of workflow
   --BEGIN
    wf_directory.addUsersToAdHocRole (role_name  => l_adhoc_role,
                                      role_users => l_admin_role);
   /*EXCEPTION
   --in older versions of WF, user has to be adHoc user (in wf_local_users)
   --to be part of adHoc role; to skip the validation, call
   --CreateUserRole with validateUserRole = FALSE
    WHEN no_user THEN
     wf_directory.CreateUserRole( user_name => l_admin_Role,
                   role_name => l_adhoc_role,
                   user_orig_system => 'PER',
                   user_orig_system_id => l_admin_emp_number,
                   role_orig_system => 'WF_LOCAL_ROLES',
                   role_orig_system_id => 0,
                   validateUserRole => FALSE);
    END;*/
  END LOOP ADMINS;
  wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'GROUP_CALENDAR_ADMIN_ROLE'
                             , avalue   => l_adhoc_role
                             );

  wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'GROUP_CALENDAR_ADMIN_NAME'
                             , avalue   => l_adhoc_role
                             );

  /***************************************************************************
    ** Start the workflow
    ***************************************************************************/
    wf_engine.StartProcess( itemtype => l_item_type
                          , itemkey  => l_item_key
                          );


    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/
    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;


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
                             , p_data  => x_msg_data);
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
END StartSubscription;

PROCEDURE ProcessInvitation
/*******************************************************************************
** Start of comments
**  Procedure   : ProcessInvitation
**  Description : Given the
**  Parameters  :
**      name                direction  type     required?
**      ----                ---------  ----     ---------
**      p_api_version       IN         NUMBER   required
**      p_init_msg_list     IN         VARCHAR2 optional
**      p_commit            IN         VARCHAR2 optional
**      x_return_status        OUT     VARCHAR2 optional
**      x_msg_count            OUT     NUMBER   required
**      x_msg_data             OUT     VARCHAR2 required
**      p_task_assignment_id   IN      NUMBER   required
**      p_resource_type        IN      VARCHAR2 required
**      p_resource_id          IN      NUMBER   required
**      p_assignment_status_id IN      NUMBER   required
**  Notes :
**    1) Created for ER 2219647
**
** End of comments
*******************************************************************************/
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2
, p_commit             IN     VARCHAR2
, x_return_status      OUT    NOCOPY	VARCHAR2
, x_msg_count          OUT    NOCOPY	NUMBER
, x_msg_data           OUT    NOCOPY	VARCHAR2
, p_task_assignment_id IN     NUMBER
, p_resource_type      IN     VARCHAR2
, p_resource_id        IN     NUMBER
, p_assignment_status_id IN NUMBER
)
IS
   CURSOR c_invitor
   /****************************************************************************
   ** Pick up appointment owner
   ****************************************************************************/
   (p_task_assignment_id NUMBER)
   IS
    SELECT task_id, owner_id, task_name, description, timezone_id, task_type_id,
     task_priority_id, calendar_start_date  startDate,
    (calendar_end_date - calendar_start_date)*24*60 duration
      FROM jtf_tasks_vl
     WHERE task_id IN
        (SELECT task_id
          FROM jtf_task_all_assignments
         WHERE task_id IN (SELECT  task_id
                            FROM jtf_task_all_assignments
                          WHERE task_assignment_id = p_task_assignment_id)
          AND assignee_role = 'OWNER')
      ;


  l_api_name        CONSTANT VARCHAR2(30)   := 'ProcessInvitation';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;

  l_item_type                 VARCHAR2(8) := 'CACVWSWF';
  l_item_key                  VARCHAR2(30);
  l_cal_admin_role            VARCHAR2(30);
  l_invitor                   c_invitor%ROWTYPE;
  l_task_type_name            VARCHAR2(30);
  l_task_priority_name        VARCHAR2(30);
  l_timezone                  VARCHAR2(80);


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

  /***************************************************************************
   ** we need an itemkey
   ***************************************************************************/

  SELECT to_char(cac_vws_itemkey_s.NEXTVAL) INTO l_item_key
    FROM DUAL;

  IF (p_assignment_status_id <> 3 AND p_assignment_status_id <>4) THEN
    fnd_message.set_name ('JTF', 'JTF_CAL_INVALID_ASSIGNMENT');
    fnd_message.set_token ('ASSIGNMENT_STATUS_ID', p_assignment_status_id);
    fnd_msg_pub.add;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  OPEN c_invitor (p_task_assignment_id);
  FETCH c_invitor INTO l_invitor;
  IF c_invitor%NOTFOUND  THEN
    CLOSE c_invitor;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  CLOSE c_invitor;


  /*****************************************************************************
  ** Look up the Calendar Administrator from the Profile (this should be an
  ** existing WF_ROLE)
  *****************************************************************************/
  l_cal_admin_role := FND_PROFILE.Value(name => 'JTF_CALENDAR_ADMINISTRATOR');
  l_task_type_name := get_type_name(l_invitor.task_type_id);
  l_task_priority_name := get_type_name(l_invitor.task_priority_id);
  l_timezone := GetTimezone(p_timezone_id => l_invitor.timezone_id);

   /***************************************************************************
    ** Initialize the workflow
    ***************************************************************************/
    wf_engine.CreateProcess( itemtype => l_item_type
                           , itemkey  => l_item_key
                           , process  => 'PROCESS_INVITATION'
                           );
    wf_engine.SetItemAttrNumber
                         ( itemtype => l_item_type
                         , itemkey  => l_item_key
                         , aname    => 'TASK_ID'
                         , avalue   => l_invitor.task_id
                         );

    wf_engine.SetItemAttrNumber
                         ( itemtype => l_item_type
                         , itemkey  => l_item_key
                         , aname    => 'ASSIGNMENT_STATUS_ID'
                         , avalue   => p_assignment_status_id
                         );
     wf_engine.SetItemAttrText
                         ( itemtype => l_item_type
                         , itemkey  => l_item_key
                         , aname    => 'TASK_DESCRIPTION'
                         , avalue   => l_invitor.description
                         );
     wf_engine.SetItemAttrText
                         ( itemtype => l_item_type
                         , itemkey  => l_item_key
                         , aname    => 'TASK_NAME'
                         , avalue   => l_invitor.task_name
                         );

     wf_engine.SetItemAttrDate
                         ( itemtype => l_item_type
                         , itemkey  => l_item_key
                         , aname    => 'START_DATE'
                         , avalue   => l_invitor.startDate
                         );
     wf_engine.SetItemAttrText
                         ( itemtype => l_item_type
                         , itemkey  => l_item_key
                         , aname    => 'DURATION'
                         , avalue   => get_duration(l_invitor.duration)
                         );
    wf_engine.SetItemAttrNumber( itemtype => l_item_type
                               , itemkey  => l_item_key
                               , aname    => 'INVITEE'
                               , avalue   => p_resource_id
                               );

    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'CALENDAR_ADMIN'
                             , avalue   => l_cal_admin_role
                             );

    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  => l_item_key
                             , aname    => 'INVITOR'
                             , avalue   => l_invitor.owner_id
                             );
    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  =>  l_item_key
                             , aname    =>  'TIMEZONE'
                             , avalue   =>  l_timezone
                             );
    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  =>  l_item_key
                             , aname    =>  'TYPE'
                             , avalue   =>  l_task_type_name
                             );
    wf_engine.SetItemAttrText( itemtype => l_item_type
                             , itemkey  =>  l_item_key
                             , aname    =>  'PRIORITY'
                             , avalue   =>  l_task_priority_name
                             );
  /***************************************************************************
    ** Start the workflow
    ***************************************************************************/
    wf_engine.StartProcess( itemtype => l_item_type
                          , itemkey  => l_item_key
                          );
    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/
    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;


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
                             , p_data  => x_msg_data);
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
END ProcessInvitation;


PROCEDURE ProcessSubscription
/*******************************************************************************
** Start of comments
**  Procedure   : ProcessSubscription
**  Description :
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     VARCHAR2 required
**
**  Notes :
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout  OUT    NOCOPY	VARCHAR2
)
IS
   l_RequestorID        NUMBER;
   l_RequestorWFRole    VARCHAR2(30);
   l_RequestorWFName    VARCHAR2(80);

   l_GroupID            NUMBER;
   l_GroupName          VARCHAR2(60);
   l_GroupNumber        VARCHAR2(30);
   l_GroupDescription   VARCHAR2(240);
   l_Response           VARCHAR2(80);

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_grant_guid         RAW(16);
   l_return             BOOLEAN;

BEGIN
  /*****************************************************************************
  ** Initialize API return status to success
  *****************************************************************************/
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  /*****************************************************************************
  ** Get the WF attribute values
  *****************************************************************************/
  l_RequestorID := wf_engine.GetItemAttrNumber
                            ( itemtype => itemtype
                            , itemkey  => itemkey
                            , aname    => 'CALENDAR_REQUESTOR'
                            );

  l_GroupID := wf_engine.GetItemAttrNumber
                        ( itemtype => itemtype
                        , itemkey  => itemkey
                        , aname    => 'GROUP_ID'
                        );

  l_GroupName := wf_engine.GetItemAttrText
                          ( itemtype => itemtype
                          , itemkey  => itemkey
                          , aname    => 'GROUP_NAME'
                          );

  l_GroupDescription := wf_engine.GetItemAttrText
                                 ( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'GROUP_DESCRIPTION'
                                 );

  l_Response := wf_engine.GetItemAttrText
                         ( itemtype => itemtype
                         , itemkey  => itemkey
                         , aname    => 'ACCESS_LEVEL');

  /** Check whether the requestor already has an access level to the group
   ** Added by Jane **/

  l_return := JTF_CAL_GRANTS_PVT.has_access_level(p_resourceid => to_char(l_RequestorID)
                                                 ,p_groupid    => to_char(l_GroupID));

  IF (l_return = true) THEN resultout := 'COMPLETE:NO_ERROR';
  ELSE
  BEGIN

  /*****************************************************************************
  ** Grant privs to the requestor
  *****************************************************************************/
  fnd_grants_pkg.grant_function( p_api_version        => 1.0
                               , p_menu_name          => l_Response
                               , p_instance_type      => 'INSTANCE'
                               , p_object_name        => 'JTF_TASK_RESOURCE'
                               , p_instance_pk1_value => to_char(l_GroupID)
                               , p_instance_pk2_value => 'RS_GROUP'
                               , p_grantee_type       => 'USER'
                               , p_grantee_key        => to_char(l_RequestorID)
                               , p_start_date         => SYSDATE
                               , p_end_date           => NULL
                               , p_program_name       => 'CALENDAR'
                               , p_program_tag        => 'ACCESS LEVEL'
                               , x_grant_guid         => l_grant_guid
                               , x_success            => l_return_status
                               , x_errorcode          => l_msg_data
                               );

  /*****************************************************************************
   ** If the Access Level is ADMIN, grant the requstor READ Access as well
  *****************************************************************************/
  IF (l_Response = 'CAC_VWS_ADMIN_ACCESS')
  THEN
    fnd_grants_pkg.grant_function( p_api_version      => 1.0
                               , p_menu_name          => 'CAC_VWS_READ_ACCESS'
                               , p_instance_type      => 'INSTANCE'
                               , p_object_name        => 'JTF_TASK_RESOURCE'
                               , p_instance_pk1_value => to_char(l_GroupID)
                               , p_instance_pk2_value => 'RS_GROUP'
                               , p_grantee_type       => 'USER'
                               , p_grantee_key        => to_char(l_RequestorID)
                               , p_start_date         => SYSDATE
                               , p_end_date           => NULL
                               , p_program_name       => 'CALENDAR'
                               , p_program_tag        => 'ACCESS LEVEL'
                               , x_grant_guid         => l_grant_guid
                               , x_success            => l_return_status
                               , x_errorcode          => l_msg_data
                               );

  END IF;

  IF (l_return_status <> FND_API.G_TRUE)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  resultout := 'COMPLETE:NO_ERROR';

EXCEPTION
  WHEN OTHERS
  THEN
    /*****************************************************************************
    ** Something went wrong return 'ERROR' and set the ERROR_MESSAGE
    *****************************************************************************/
    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'ERROR_MESSAGE'
                             , avalue   => 'CAC_VIEW_WF_PVT.ProcessSubscription(): ' || to_char(SQLCODE)||':'||SQLERRM
                             );

    resultout := 'COMPLETE:ERROR';
END; -- Added by Jane on 04/30/02
END IF;

END ProcessSubscription;


PROCEDURE StartRequest
/*******************************************************************************
** Start of comments
**  Procedure   : StartRequest
**  Description : Given the
**  Parameters  :
**      name                direction  type     required?
**      ----                ---------  ----     ---------
**      p_api_version       IN         NUMBER   required
**      p_init_msg_list     IN         VARCHAR2 optional
**      p_commit            IN         VARCHAR2 optional
**      x_return_status        OUT     VARCHAR2 optional
**      x_msg_count            OUT     NUMBER   required
**      x_msg_data             OUT     VARCHAR2 required
**      p_REQUESTOR         IN         NUMBER   required
**      p_GROUP_ID          IN         NUMBER   optional
**      p_GROUP_NAME        IN         VARCHAR2 required
**      p_GROUP_DESCRIPTION IN         VARCHAR2 required
**      p_PUBLIC_FLAG       IN         VARCHAR2 required
**  Notes :
**    1)
**
** End of comments
*******************************************************************************/
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2
, p_commit             IN     VARCHAR2
, x_return_status      OUT    NOCOPY	VARCHAR2
, x_msg_count          OUT    NOCOPY	NUMBER
, x_msg_data           OUT    NOCOPY	VARCHAR2
, p_CALENDAR_REQUESTOR IN     NUMBER   -- Resource ID of the Requestor
, p_GROUP_ID           IN     NUMBER   -- Resource ID of Group if known
, p_GROUP_NAME         IN     VARCHAR2 -- (Suggested) Name of the Group Calendar
, p_GROUP_DESCRIPTION  IN     VARCHAR2 -- (Suggested) Description of the Group Calendar
, p_PUBLIC             IN     VARCHAR2 -- Public Calendar flag
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'StartRequestCalendarWF';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;

  l_ItemType                 VARCHAR2(8)    := 'CACVWSWF';

  l_AdminWFRole              VARCHAR2(30);

  l_RequestorWFRole          VARCHAR2(30);
  l_RequestorWFName          VARCHAR2(80);
  l_RequestorEmpNumber       NUMBER;

  l_ItemKey                  VARCHAR2(100);

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
  ** Look up the Calendar Administrator from the Profile (this should be an
  ** existing WF_ROLE)
  *****************************************************************************/
  l_AdminWFRole := FND_PROFILE.Value(name => 'JTF_CALENDAR_ADMINISTRATOR');

  /*****************************************************************************
  ** Look up the WF Role and Name of the requestor
  *****************************************************************************/
  WF_Role( p_CALENDAR_REQUESTOR
         , 'RS_EMPLOYEE'       -- Not used, for future enhancements
         , l_RequestorWFRole
         , l_RequestorWFName
         , l_RequestorEmpNumber
         );

  /*****************************************************************************
  ** Get a WF itemkey
  *****************************************************************************/
  SELECT to_char(cac_vws_itemkey_s.NEXTVAL) INTO l_ItemKey
  FROM DUAL;

  /***************************************************************************
  ** Initialize the workflow
  ***************************************************************************/
  wf_engine.CreateProcess( itemtype => l_ItemType
                         , itemkey  => l_ItemKey
                         , process  => 'REQUEST_CALENDAR'
                         );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_ItemKey
                           , aname    => 'CALENDAR_ADMIN'
                           , avalue   => l_AdminWFRole
                           );

  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_ItemKey
                             , aname    => 'CALENDAR_REQUESTOR'
                             , avalue   => p_CALENDAR_REQUESTOR
                             );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_ItemKey
                           , aname    => 'CALENDAR_REQUESTOR_ROLE'
                           , avalue   => l_RequestorWFRole
                           );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_ItemKey
                           , aname    => 'CALENDAR_REQUESTOR_NAME'
                           , avalue   => l_RequestorWFName
                           );

  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_ItemKey
                             , aname    => 'GROUP_ID'
                             , avalue   => p_GROUP_ID
                             );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_ItemKey
                           , aname    => 'GROUP_NAME'
                           , avalue   => p_GROUP_NAME
                           );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_ItemKey
                           , aname    => 'GROUP_DESCRIPTION'
                           , avalue   => p_GROUP_DESCRIPTION
                           );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_ItemKey
                           , aname    => 'PUBLIC'
                           , avalue   => p_PUBLIC
                           );

  /***************************************************************************
  ** Start the workflow
  ***************************************************************************/
  wf_engine.StartProcess( itemtype => l_itemtype
                        , itemkey  => l_ItemKey
                        );

  /***************************************************************************
  ** Standard check of p_commit (WF won't start until commited..)
  ***************************************************************************/
  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

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

END StartRequest;

PROCEDURE ProcessRequest
/*******************************************************************************
** Start of comments
**  Procedure   : ProcessRequest
**  Description :
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     VARCHAR2 required
**
**  Notes :
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout  OUT    NOCOPY	VARCHAR2
)
IS
  CURSOR c_GroupExists
  /*****************************************************************************
  ** If a group already exists with this Name and Description then we just need
  ** to create a 'GROUP/PUBLIC CALENDAR' usage for it
  *****************************************************************************/
  ( b_GroupName        VARCHAR2
  , b_GroupDescription VARCHAR2
  )IS SELECT jrb.group_id
      FROM jtf_rs_groups_b  jrb
      ,    jtf_rs_groups_tl jrt
      WHERE jrb.group_id = jrt.group_id
      AND   (  (jrb.end_date_active > SYSDATE)
            OR (jrb.end_date_active IS NULL)
            )
      AND   jrt.group_name = b_GroupName
    --  AND   jrt.group_desc = b_GroupDescription
      AND   jrt.language = userenv('LANG');

  CURSOR c_GroupUsageExists
  /*****************************************************************************
  ** If the group usage already exists we just create the grant
  *****************************************************************************/
  ( b_GroupID NUMBER
  , b_Usage   VARCHAR2
  )IS SELECT group_usage_id
      FROM   jtf_rs_group_usages  jru
      WHERE  jru.group_id = b_GroupID
      AND    jru.usage    = b_Usage;

   l_AdminWFRole        VARCHAR2(30);

   l_RequestorID        NUMBER;
   l_RequestorWFRole    VARCHAR2(30);
   l_RequestorWFName    VARCHAR2(80);

   l_GroupID            NUMBER;
   l_GroupName          VARCHAR2(60);
   l_GroupNumber        VARCHAR2(30);
   l_GroupDescription   VARCHAR2(240);
   l_PublicFlag         VARCHAR2(1);
   l_GroupUsageID       NUMBER;
   l_Usage              VARCHAR2(240);

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_msg_index_out      NUMBER;
   l_grant_guid         RAW(16);

   l_debug              varchar2(4000);


BEGIN
  /*****************************************************************************
  ** Initialize message list
  *****************************************************************************/
  FND_MSG_PUB.Initialize;

  /*****************************************************************************
  ** Initialize API return status to success
  *****************************************************************************/
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  /*****************************************************************************
  ** Get the WF attribute values
  *****************************************************************************/
  l_RequestorID := wf_engine.GetItemAttrNumber
                            ( itemtype => itemtype
                            , itemkey  => itemkey
                            , aname    => 'CALENDAR_REQUESTOR'
                            );

  l_GroupID := wf_engine.GetItemAttrNumber
                        ( itemtype => itemtype
                        , itemkey  => itemkey
                        , aname    => 'GROUP_ID'
                        );

  l_GroupName := wf_engine.GetItemAttrText
                          ( itemtype => itemtype
                          , itemkey  => itemkey
                          , aname    => 'GROUP_NAME'
                          );

  l_GroupDescription := wf_engine.GetItemAttrText
                                 ( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'GROUP_DESCRIPTION'
                                 );

  l_PublicFlag := wf_engine.GetItemAttrText
                           ( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'PUBLIC'
                           );

  IF (l_GroupID IS NULL)
  THEN
    /***************************************************************************
    ** No Group ID is set, let's see if the name/description already exists
    ***************************************************************************/
    IF (c_GroupExists%ISOPEN)
    THEN
      CLOSE c_GroupExists;
    END IF;

    OPEN c_GroupExists( l_GroupName
                      , l_GroupDescription
                      );

    FETCH c_GroupExists INTO l_GroupID;
    IF (c_GroupExists%NOTFOUND)
    THEN
      /*************************************************************************
      ** No Group exists with this name/description, assume it's a new one.
      *************************************************************************/
      JTF_RS_GROUPS_PUB.Create_Resource_Group
      ( P_API_VERSION       => 1.0
      , P_INIT_MSG_LIST     => FND_API.G_TRUE
      , P_COMMIT            => FND_API.G_FALSE -- Can't commit in WF!
      , P_GROUP_NAME        => l_GroupName
      , P_GROUP_DESC        => l_GroupDescription
      , P_START_DATE_ACTIVE => SYSDATE
      , X_RETURN_STATUS     => l_return_status
      , X_MSG_COUNT         => l_msg_count
      , X_MSG_DATA          => l_msg_data
      , X_GROUP_ID          => l_GroupID
    --, X_GROUP_NUMBER      => l_GroupName
    -- Modified by jawang on 12/31/2002 to fix the NOCOPY issue
      , X_GROUP_NUMBER      => l_GroupNumber
      );

      /*************************************************************************
      ** Standard call to get message count and if count is 1, get message info
      *************************************************************************/
      FND_MSG_PUB.Count_And_Get( p_count => l_msg_count
                               , p_data  => l_msg_data
                               );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF (c_GroupExists%ISOPEN)
    THEN
      CLOSE c_GroupExists;
    END IF;
  END IF;


  /*****************************************************************************
  ** Now that we made sure the group exists, we need to create the proper usage
  *****************************************************************************/
  IF (l_PublicFlag = 'Y')
  THEN
    l_Usage := 'PUBLIC_CALENDAR';
  ELSE
    l_Usage := 'GROUP_CALENDAR';
  END IF;

  IF (c_GroupUsageExists%ISOPEN)
  THEN
    CLOSE c_GroupUsageExists;
  END IF;

  OPEN c_GroupUsageExists( l_GroupID
                         , l_Usage
                         );

  FETCH c_GroupUsageExists INTO l_GroupUsageID;
  IF (c_GroupUsageExists%NOTFOUND)
  THEN
    /***************************************************************************
    ** Create the usage
    ***************************************************************************/
    JTF_RS_GROUP_USAGES_PUB.Create_Group_Usage
    ( P_API_VERSION    => 1.0
    , P_INIT_MSG_LIST  => FND_API.G_FALSE
    , P_COMMIT         => FND_API.G_FALSE
    , P_GROUP_ID       => l_GroupID
    , P_GROUP_NUMBER   => NULL
    , P_USAGE          => l_usage
    , X_RETURN_STATUS  => l_return_status
    , X_MSG_COUNT      => l_msg_count
    , X_MSG_DATA       => l_msg_data
    , X_GROUP_USAGE_ID => l_GroupUsageID
    );

    /***************************************************************************
    ** Standard call to get message count and if count is 1, get message info
    ***************************************************************************/
    FND_MSG_PUB.Count_And_Get( p_count => l_msg_count
                             , p_data  => l_msg_data
                             );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  --END IF;

  /*IF (c_GroupUsageExists%ISOPEN)
  THEN
    CLOSE c_GroupUsageExists;
  END IF;
  */

  l_return_status := FND_API.G_TRUE;

  /*****************************************************************************
  ** Grant Administrator privs to the requestor
  *****************************************************************************/
  fnd_grants_pkg.grant_function( p_api_version        => 1.0
                               , p_menu_name          => 'CAC_VWS_ADMIN_ACCESS'
                               , p_instance_type      => 'INSTANCE'
                               , p_object_name        => 'JTF_TASK_RESOURCE'
                               , p_instance_pk1_value => to_char(nvl(l_GroupID,1))
                               , p_instance_pk2_value => 'RS_GROUP'
                               , p_grantee_type       => 'USER'
                               , p_grantee_key        => to_char(nvl(l_RequestorID,1))
                               , p_start_date         => SYSDATE
                               , p_end_date           => NULL
                               , p_program_name       => 'CALENDAR'
                               , p_program_tag        => 'ACCESS LEVEL'
                               , x_grant_guid         => l_grant_guid
                               , x_success            => l_return_status
                               , x_errorcode          => l_msg_data
                               );

  /*****************************************************************************
    ** Grant Readonly privs to the requestor as well
    ** Added by Jane on 04/30/02
    *****************************************************************************/
    fnd_grants_pkg.grant_function( p_api_version        => 1.0
                                 , p_menu_name          => 'CAC_VWS_READ_ACCESS'
                                 , p_instance_type      => 'INSTANCE'
                                 , p_object_name        => 'JTF_TASK_RESOURCE'
                                 , p_instance_pk1_value => to_char(nvl(l_GroupID,1))
                                 , p_instance_pk2_value => 'RS_GROUP'
                                 , p_grantee_type       => 'USER'
                                 , p_grantee_key        => to_char(nvl(l_RequestorID,1))
                                 , p_start_date         => SYSDATE
                                 , p_end_date           => NULL
                                 , p_program_name       => 'CALENDAR'
                                 , p_program_tag        => 'ACCESS LEVEL'
                                 , x_grant_guid         => l_grant_guid
                                 , x_success            => l_return_status
                                 , x_errorcode          => l_msg_data
                               );

  	IF (l_return_status <> FND_API.G_TRUE)
  	THEN
    		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

   END IF; -- End of c_GroupUsageExists%NOTFOUND

   IF (c_GroupUsageExists%ISOPEN)
   THEN
   	CLOSE c_GroupUsageExists;
   END IF;

  /*****************************************************************************
  ** All went well return 'NO_ERROR'
  *****************************************************************************/
  resultout := 'COMPLETE:NO_ERROR';

EXCEPTION
  WHEN OTHERS
  THEN
    IF (c_GroupExists%ISOPEN)
    THEN
      CLOSE c_GroupExists;
    END IF;
    IF (c_GroupUsageExists%ISOPEN)
    THEN
      CLOSE c_GroupUsageExists;
    END IF;

    /*****************************************************************************
    ** Something went wrong return 'ERROR' and set the ERROR_MESSAGE
    *****************************************************************************/
    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'ERROR_MESSAGE'
                             , avalue   => 'CAC_VIEW_WF_PVT.ProcessRequest(): ' || to_char(SQLCODE)||':'||SQLERRM
                             );

    resultout := 'COMPLETE:ERROR';

END ProcessRequest;


PROCEDURE StartInvite
/*******************************************************************************
** Start of comments
**  Procedure   : StartInvite
**  Description : Given the task ID of the appointment (p_TaskID) and the
**                Resource ID of the invitor (p_INVITOR) this procedure will
**                send notifications to all the attendees of the appointment.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_INVITOR          IN         NUMBER   required
**      p_TaskID           IN         NUMBER   required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_INVITOR       IN     NUMBER   -- Resource ID of Invitor
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'StartInviteWF';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;
  l_ItemType                 VARCHAR2(8) := 'CACVWSWF';
  l_AdminWFRole              VARCHAR2(30);
  l_task_type_name           VARCHAR2(30);
  l_task_priority_name       VARCHAR2(30);
  l_timezone                 VARCHAR2(80);

  CURSOR c_Task
  /*****************************************************************************
  ** Cursor to pick up all the invitees for the appointment. Also picks up
  ** a itemkey from the sequence, this is needed to start the workflow
  *****************************************************************************/
  (b_TaskID NUMBER
  )IS SELECT to_char(cac_vws_itemkey_s.NEXTVAL) ItemKey
      ,      jta.task_assignment_id             TASK_ASSIGNMENT_ID
      ,      jta.resource_id                    INVITEE
      ,      jta.resource_type_code             INVITEE_CODE
      ,      jtl.task_name                      TASK_NAME
      ,      jtl.description                    TASK_DESCRIPTION
      ,      jtb.calendar_start_date            START_DATE
      ,      jtb.task_type_id                   TYPE_ID
      ,      jtb.task_priority_id               PRIORITY_ID
      ,      (jtb.calendar_end_date - jtb.calendar_start_date)*24*60 DURATION
      ,      jtb.timezone_id                    TIMEZONE_ID
      FROM   jtf_tasks_b          jtb
      ,      jtf_tasks_tl         jtl
      ,      jtf_task_all_assignments jta
      WHERE  jtb.task_id          = jtl.task_id
      AND    jtl.language         = userenv('LANG')
      AND    jta.task_id          = jtb.task_id
      AND    jta.assignee_role    = 'ASSIGNEE' -- don't sent one to the owner??
      AND    jta.show_on_calendar = 'Y'        -- so Vanessa doesn't get it..
      AND    jtb.task_id          = b_TaskID;

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
  ** Look up the Calendar Administrator from the Profile (this should be an
  ** existing WF_ROLE)
  *****************************************************************************/
  l_AdminWFRole := FND_PROFILE.Value(name => 'JTF_CALENDAR_ADMINISTRATOR');

  /*****************************************************************************
  ** Get Appointment details for every invitee and start a notification WF for
  ** all of them.
  *****************************************************************************/
  FOR r_Task IN c_Task(p_TaskID)
  LOOP <<ASSIGNEES>>
    /***************************************************************************
    ** Initialize the workflow
    ***************************************************************************/
    l_task_type_name := get_type_name(r_Task.TYPE_ID);
    l_task_priority_name := get_type_name(r_Task.PRIORITY_ID);
    l_timezone := GetTimezone(p_timezone_id => r_Task.TIMEZONE_ID);
    wf_engine.CreateProcess( itemtype => l_ItemType
                           , itemkey  => r_Task.ItemKey
                           , process  => 'SEND_INVITATION'
                           );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'CALENDAR_ADMIN'
                             , avalue   => l_AdminWFRole
                             );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE'
                               , avalue   => r_Task.INVITEE
                               );
---Enh # 3443999, amigupta, Setting new attribute value INVITEE_CODE for handling Resource_type_Code also

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE_CODE'
                               , avalue   => r_Task.INVITEE_CODE
                               );

 wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ASSIGNMENT_ID'
                               , avalue   => r_Task.TASK_ASSIGNMENT_ID
                               );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITOR'
                               , avalue   => p_INVITOR
                               );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ID'
                               , avalue   => p_TaskID
                               );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_NAME'
                             , avalue   => r_Task.TASK_NAME
                             );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_DESCRIPTION'
                             , avalue   => r_Task.TASK_DESCRIPTION
                             );

    wf_engine.SetItemAttrDate( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'START_DATE'
                             , avalue   => r_Task.START_DATE
                             );

   wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TYPE'
                             , avalue   => l_task_type_name
                             );
     wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'PRIORITY'
                             , avalue   => l_task_priority_name
                             );
     wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  =>   r_Task.ItemKey
                             , aname    =>  'DURATION'
                             , avalue   =>  get_duration(r_Task.DURATION)
                             );
    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  =>   r_Task.ItemKey
                             , aname    =>  'TIMEZONE'
                             , avalue   =>  l_timezone
                             );

    /***************************************************************************
    ** Start the workflow
    ***************************************************************************/
    wf_engine.StartProcess( itemtype => l_itemtype
                          , itemkey  => r_Task.ItemKey
                          );


    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/
    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;


  END LOOP ASSIGNEES;

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

END StartInvite;

PROCEDURE StartInviteResource
/*******************************************************************************
** Start of comments
**  Procedure   : StartInviteResource
**  Description : Given the task ID of the appointment (p_TaskID) and the
**                Resource ID of the invitee (p_INVITEE) this procedure will
**                send notification to the paticular attendee of the appointment.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_INVITEE          IN         NUMBER   required
**      p_INVITOR          IN         NUMBER   required
**      p_TaskID           IN         NUMBER   required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_INVITEE       IN     NUMBER   -- Resource ID of Invitee
, p_INVITEE_TYPE  IN     VARCHAR2 --Resource Type of the INVITEE
, p_INVITOR       IN     NUMBER   -- Resource ID of Invitor
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'StartInviteWF';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;
  l_ItemType                 VARCHAR2(8) := 'CACVWSWF';
  l_AdminWFRole              VARCHAR2(30);
  l_task_type_name           VARCHAR2(30);
  l_task_priority_name       VARCHAR2(30);
  l_timezone                 VARCHAR2(80);

  CURSOR c_Task
  /*****************************************************************************
  ** Cursor to pick up all the invitees for the appointment. Also picks up
  ** a itemkey from the sequence, this is needed to start the workflow
  *****************************************************************************/
  (b_TaskID NUMBER, b_INVITEE  NUMBER, b_INVITEE_TYPE  VARCHAR2
  )IS SELECT to_char(cac_vws_itemkey_s.NEXTVAL) ItemKey
      ,      jta.task_assignment_id             TASK_ASSIGNMENT_ID
      ,      jta.resource_id                    INVITEE
      ,      jta.resource_type_code             INVITEE_CODE
      ,      jtl.task_name                      TASK_NAME
      ,      jtl.description                    TASK_DESCRIPTION
      ,      jtb.calendar_start_date            START_DATE
      ,      jtb.task_type_id                   TYPE_ID
      ,      jtb.task_priority_id               PRIORITY_ID
      ,      (jtb.calendar_end_date - jtb.calendar_start_date)*24*60 DURATION
      ,      jtb.timezone_id                    TIMEZONE_ID
      FROM   jtf_tasks_b          jtb
      ,      jtf_tasks_tl         jtl
      ,      jtf_task_all_assignments jta
      WHERE  jtb.task_id          = jtl.task_id
      AND    jtl.language         = userenv('LANG')
      AND    jta.task_id          = jtb.task_id
      AND    jta.assignee_role    = 'ASSIGNEE' -- don't sent one to the owner??
      AND    jta.show_on_calendar = 'Y'        -- so Vanessa doesn't get it..
      AND    jtb.task_id          = b_TaskID
      AND    jta.resource_id      =  b_INVITEE
      AND    jta.resource_type_code  =   b_INVITEE_TYPE  ;

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
  ** Look up the Calendar Administrator from the Profile (this should be an
  ** existing WF_ROLE)
  *****************************************************************************/
  l_AdminWFRole := FND_PROFILE.Value(name => 'JTF_CALENDAR_ADMINISTRATOR');

  /*****************************************************************************
  ** Get Appointment details for every invitee and start a notification WF for
  ** all of them.
  *****************************************************************************/
  FOR r_Task IN c_Task(p_TaskID, p_INVITEE, p_INVITEE_TYPE)
  LOOP <<ASSIGNEES>>
    /***************************************************************************
    ** Initialize the workflow
    ***************************************************************************/
    l_task_type_name := get_type_name(r_Task.TYPE_ID);
    l_task_priority_name := get_type_name(r_Task.PRIORITY_ID);
    l_timezone := GetTimezone(p_timezone_id => r_Task.TIMEZONE_ID);
    wf_engine.CreateProcess( itemtype => l_ItemType
                           , itemkey  => r_Task.ItemKey
                           , process  => 'SEND_INVITATION'
                           );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'CALENDAR_ADMIN'
                             , avalue   => l_AdminWFRole
                             );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE'
                               , avalue   => r_Task.INVITEE
                               );
---Enh # 3443999, amigupta, Setting new attribute value INVITEE_CODE for handling Resource_type_Code also

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE_CODE'
                               , avalue   => r_Task.INVITEE_CODE
                               );

 wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ASSIGNMENT_ID'
                               , avalue   => r_Task.TASK_ASSIGNMENT_ID
                               );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITOR'
                               , avalue   => p_INVITOR
                               );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ID'
                               , avalue   => p_TaskID
                               );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_NAME'
                             , avalue   => r_Task.TASK_NAME
                             );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_DESCRIPTION'
                             , avalue   => r_Task.TASK_DESCRIPTION
                             );

    wf_engine.SetItemAttrDate( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'START_DATE'
                             , avalue   => r_Task.START_DATE
                             );

   wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TYPE'
                             , avalue   => l_task_type_name
                             );
     wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'PRIORITY'
                             , avalue   => l_task_priority_name
                             );
     wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  =>   r_Task.ItemKey
                             , aname    =>  'DURATION'
                             , avalue   =>  get_duration(r_Task.DURATION)
                             );
    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  =>   r_Task.ItemKey
                             , aname    =>  'TIMEZONE'
                             , avalue   =>  l_timezone
                             );

    /***************************************************************************
    ** Start the workflow
    ***************************************************************************/
    wf_engine.StartProcess( itemtype => l_itemtype
                          , itemkey  => r_Task.ItemKey
                          );


    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/
    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;


  END LOOP ASSIGNEES;

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

END StartInviteResource;

PROCEDURE UpdateInvitation
/*******************************************************************************
** Start of comments
**  Procedure   : UpdateInvitation
**  Description : Given the task ID of the appointment (p_TaskID) and the
**                Resource ID of the invitee (p_INVITEE) this procedure will
**                respond to the notifications from the attendees of the appointment.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     VARCHAR2 required
** End of comments
*******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout     OUT NOCOPY VARCHAR2
)
IS

 l_object_version_number	NUMBER :=1 ;
 l_InviteeResourceID		NUMBER;
 l_TaskID			NUMBER;
 l_task_assignment_id		NUMBER;
 l_assignment_status_id         NUMBER;
 l_resource_type		varchar2(30);
 l_return_status		VARCHAR2(1);
 l_result			varchar2(30);
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(1000);

 BEGIN

  IF (funcmode = 'RUN')
  THEN
    /***************************************************************************
    ** 'RUN' function from WF
    ***************************************************************************/

    /***************************************************************************
    ** Pick up the resource ID of the INVITEE
    ***************************************************************************/
   l_result := wf_engine.getItemAttrText
                                    ( itemtype => itemtype
                                    , itemkey  => itemkey
                                    , aname    => 'RESULT'
                                    );

   l_InviteeResourceID := wf_engine.GetItemAttrNumber
                                    ( itemtype => itemtype
                                    , itemkey  => itemkey
                                    , aname    => 'INVITEE'
                                    );

    l_TaskID := wf_engine.GetItemAttrNumber
                                    ( itemtype => itemtype
                                    , itemkey  => itemkey
                                    , aname    => 'TASK_ID'
                                    );

   l_resource_type := wf_engine.getItemAttrText( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'INVITEE_CODE'
                               );

   l_task_assignment_id := wf_engine.GetItemAttrNumber
                                    ( itemtype => itemtype
                                    , itemkey  => itemkey
                                    , aname    => 'TASK_ASSIGNMENT_ID'
                                    );


 IF (l_result = 'ACCEPT' OR l_result = 'ACCEPT_ALL')
  THEN
    l_assignment_status_id :=3;
  ELSIF (l_result = 'DECLINE' OR l_result = 'DECLINE_ALL')
  THEN
    l_assignment_status_id := 4;
  END IF;

  fnd_msg_pub.initialize;

  JTF_TASK_ASSIGNMENTS_PVT.update_task_assignment
  (
            p_api_version                  =>       1.0,
            p_object_version_number        =>       l_object_version_number,
            p_init_msg_list                =>       'T', --?
            p_task_assignment_id           =>       l_task_assignment_id,
            p_resource_type_code           =>       l_resource_type,
            p_resource_id                  =>       l_InviteeResourceID,
            p_schedule_flag                =>       fnd_api.g_miss_char, --Y Or N??
            p_actual_start_date            =>       null, --?
            p_actual_end_date              =>       null, --?
            p_assignment_status_id         =>       l_assignment_status_id,
            p_show_on_calendar             =>       'Y',
            p_enable_workflow              =>       'N',
            p_abort_workflow               =>       'N',
            x_return_status                =>       l_return_status,
            x_msg_count                    =>       l_msg_count,
            x_msg_data                     =>       l_msg_data
         ) ;


   IF l_return_status = fnd_api.g_ret_sts_success
   THEN

      cac_view_wf_pvt.processinvitation(p_api_version => 1.0
            ,p_init_msg_list => 'T'
            ,p_commit        => 'F'
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_task_assignment_id => l_task_assignment_id
            ,p_resource_type     => l_resource_type
            ,p_resource_id => l_InviteeResourceID
            ,p_assignment_status_id => l_assignment_status_id);

   END IF;

 END IF;

END UpdateInvitation;

PROCEDURE DetermineWFRole
/*******************************************************************************
** Start of comments
**  Procedure   : DetermineWFRole
**  Description : Work out the WF role for the given resource.
**                Used to implement the 'Determine WF Role' function in the
**                'CACVWSWF.Send Invitation' workflow.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     VARCHAR2 required
**
**  Notes :
**    1) Expects WF item attributes 'RESOURCE_ID' and 'RESOURCE_TYPE' to be
**       available to this procedure.
**    2) This procedure should only be used within Workflow
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout  OUT    NOCOPY	VARCHAR2
)
IS
  l_InvitorResourceID   NUMBER;
  l_InvitorWFRole       VARCHAR2(30);
  l_InvitorWFName       VARCHAR2(80);
  l_InvitorEmpNumber    NUMBER;

  l_InviteeResourceID   NUMBER;
  l_InviteeWFRole       VARCHAR2(30);
  l_InviteeWFName       VARCHAR2(80);

  l_InviteeCode         VARCHAR2(30);

  CURSOR c_EmployeeInfo
  /*****************************************************************************
  ** Get the employee number of the Resource
  *****************************************************************************/
  ( b_ResourceID    NUMBER
  )IS SELECT source_id  EmployeeNumber
      FROM   JTF_RS_RESOURCE_EXTNS
      WHERE resource_id   = b_ResourceID;

BEGIN

  IF (funcmode = 'RUN')
  THEN
    /***************************************************************************
    ** 'RUN' function from WF
    ***************************************************************************/

    /***************************************************************************
    ** Pick up the resource ID of the INVITOR
    ***************************************************************************/
    l_InvitorResourceID := wf_engine.GetItemAttrNumber
                                    ( itemtype => itemtype
                                    , itemkey  => itemkey
                                    , aname    => 'INVITOR'
                                    );

    /***************************************************************************
    ** Pick up the resource ID of the INVITEE
    ***************************************************************************/
    l_InviteeResourceID := wf_engine.GetItemAttrNumber
                                    ( itemtype => itemtype
                                    , itemkey  => itemkey
                                    , aname    => 'INVITEE'
                                    );

---Enh # 3443999,amigupta Getting attribute value for INVITEE_CODE and passing to WF_ROLE

  /***************************************************************************
    ** Pick up the resource Type Code of the INVITEE
    ***************************************************************************/
    l_InviteeCode := wf_engine.GetItemAttrText
                                    ( itemtype => itemtype
                                    , itemkey  => itemkey
                                    , aname    => 'INVITEE_CODE'
                                    );

    /***************************************************************************
    ** Determine the WF Role and WF Name for the Invitor
    ***************************************************************************/

    WF_Role( l_InvitorResourceID
           , l_InviteeCode      -- Not used, for future enhancements
           , l_InvitorWFRole
           , l_InvitorWFName
           , l_InvitorEmpNumber
           );

    /***************************************************************************
    ** If the invitor doesn't exist in the WF directory we can't send a
    ** notification to invitor
    ***************************************************************************/
    IF ((l_InvitorWFRole IS NULL) OR
        (l_InvitorWFName IS NULL)
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      /*************************************************************************
      ** Found INVITOR, set WF Attributes
      *************************************************************************/
      WF_ENGINE.SetItemAttrText( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'WF_INVITOR_ROLE'
                               , avalue   => l_InvitorWFRole
                               );

      WF_ENGINE.SetItemAttrText( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'WF_INVITOR_NAME'
                               , avalue   => l_InvitorWFName
                               );

      /*************************************************************************
      ** Determine the WF Role and WF Name for the Invitee
      *************************************************************************/
      WF_Role( l_InviteeResourceID
             , l_InviteeCode       -- Not used, for future enhancements
             , l_InviteeWFRole
             , l_InviteeWFName
             , l_InvitorEmpNumber
             );

      IF ((l_InviteeWFRole IS NULL) OR
          (l_InviteeWFName IS NULL)
         )
      THEN
        /***********************************************************************
        ** If the invitee doesn't exist in the WF directory we send a warning
        ** notification to the invitor
        ***********************************************************************/
        resultout := 'COMPLETE:WARNING';
      ELSE
        /***********************************************************************
        ** Found INVITEE, set WF Attributes
        ***********************************************************************/
        WF_ENGINE.SetItemAttrText( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'WF_INVITEE_ROLE'
                                 , avalue   => l_InviteeWFRole
                                 );

        WF_ENGINE.SetItemAttrText( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'WF_INVITEE_NAME'
                                 , avalue   => l_InviteeWFName
                                 );
        resultout := 'COMPLETE:NO_ERROR';
      END IF;

    END IF;

  ELSIF (funcmode = 'CANCEL')
  THEN
    /***************************************************************************
    ** 'CANCEL' function from WF
    ***************************************************************************/
    resultout := 'COMPLETE:NO_ERROR';
  ELSIF (funcmode = 'TIMEOUT')
  THEN
    /***************************************************************************
    ** 'TIMEOUT' function from WF
    ***************************************************************************/
    resultout := 'COMPLETE:NO_ERROR';
  ELSE
    /***************************************************************************
    ** Unknown function from WF - raise error
    ***************************************************************************/
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    /*****************************************************************************
    ** Something went wrong return 'ERROR' and set the ERROR_MESSAGE
    *****************************************************************************/
    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'ERROR_MESSAGE'
                             , avalue   => 'CAC_VIEW_WF_PVT.DetermineWFRole(): ' || to_char(SQLCODE)||':'||SQLERRM
                             );

    resultout := 'COMPLETE:ERROR';


END DetermineWFRole;


PROCEDURE StartReminders
/*******************************************************************************
** Start of comments
**  Procedure   : StartReminder
**  Description : Given the task ID of the appointment (p_TaskID) and the
**                Resource ID of the invitor (p_INVITOR) this procedure will
**                start WF that will initiate the sending of reminders when the
**                time has come..
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_INVITOR          IN         NUMBER   required
**      p_TaskID           IN         NUMBER   required
**  Notes :
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_INVITOR       IN     NUMBER   -- Resource ID of Invitor
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
, p_RemindDate    IN     DATE     -- Date/Time the reminder needs to be send
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'StartReminders';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;

  l_ItemType                 VARCHAR2(8) := 'JTFTKRDR';
  l_ItemKey                  VARCHAR2(100);
  l_AdminWFRole              VARCHAR2(30);

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
  ** Look up the Calendar Administrator from the Profile (this should be an
  ** existing WF_ROLE)
  *****************************************************************************/
  l_AdminWFRole := FND_PROFILE.Value(name => 'JTF_CALENDAR_ADMINISTRATOR');

  /***************************************************************************
  ** we need an itemkey
  ***************************************************************************/
  SELECT to_char(cac_vws_itemkey_s.NEXTVAL) INTO l_ItemKey
  FROM DUAL;
  /***************************************************************************
  ** Initialize the workflow
  ***************************************************************************/
  wf_engine.CreateProcess( itemtype => l_ItemType
                         , itemkey  => l_ItemKey
                         , process  => 'DELAYSTARTREMINDER'
                         );

  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_ItemKey
                             , aname    => 'TASK_ID'
                             , avalue   => p_TaskID
                             );

  wf_engine.SetItemAttrDate( itemtype => l_itemtype
                           , itemkey  => l_ItemKey
                           , aname    => 'REMIND_DATE'
                           , avalue   => p_RemindDate
                           );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                           , itemkey  => l_ItemKey
                           , aname    => 'CALENDAR_ADMIN'
                           , avalue   => l_AdminWFRole
                           );

  wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                             , itemkey  => l_ItemKey
                             , aname    => 'INVITOR'
                             , avalue   => p_INVITOR
                             );

  /***************************************************************************
  ** Start the workflow
  ***************************************************************************/
  wf_engine.StartProcess( itemtype => l_itemtype
                        , itemkey  => l_ItemKey
                        );

  /***************************************************************************
  ** Save the workflow itemtype and item key so we can update the reminder WF
  ** if the start date or remind me settings change
  ***************************************************************************/

  UPDATE jtf_task_all_assignments
  SET reminder_wf_item_type = l_itemtype
  ,   reminder_wf_item_key  = l_ItemKey
  WHERE task_id  = p_TaskID;

  /***************************************************************************
  ** Standard check of p_commit (WF won't start until commited)
  ***************************************************************************/
  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

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

END StartReminders;


PROCEDURE SendReminders
/*******************************************************************************
** Start of comments
**  Procedure   : SendReminders
**  Description :
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     VARCHAR2 required
**
**  Notes :
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout  OUT    NOCOPY	VARCHAR2
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'StartReminderWF';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;

  l_ItemType                 VARCHAR2(8) := 'JTFTKRDR';
  l_AdminWFRole              VARCHAR2(30);
  l_StartDateCorrected       DATE;
  l_EndDateCorrected         DATE;
  l_user_id                  NUMBER;
  l_DestTimezoneID           NUMBER;
  l_SourceTimezoneID         NUMBER;

  CURSOR c_Task
  /*****************************************************************************
  ** Cursor to pick up all the invitees for the appointment. Also picks up
  ** a itemkey from the sequence, this is needed to start the workflow
  *****************************************************************************/
  (b_TaskID NUMBER
  )IS SELECT jta.task_assignment_id             TaskAssignmentID
      ,      to_char(cac_vws_itemkey_s.NEXTVAL) ItemKey
      ,      jta.resource_id                    INVITEE
      ,      jta.resource_type_code             INVITEE_CODE
      ,      jtl.task_name                      TASK_NAME
      ,      jtl.description                    TASK_DESCRIPTION
      ,      jtb.calendar_start_date            START_DATE
      ,      jtb.calendar_end_date              END_DATE
      ,      NVL( jtb.timezone_id
                ,(NVL( FND_PROFILE.Value('SERVER_TIMEZONE_ID')
                     , 4)
                     )
                )                               SourceTimezoneID
      FROM   jtf_tasks_b          jtb
      ,      jtf_tasks_tl         jtl
      ,      jtf_task_all_assignments jta
      WHERE  jtb.task_id          = jtl.task_id
      AND    jtl.language         = userenv('LANG')
      AND    jta.task_id          = jtb.task_id
      AND    jta.show_on_calendar = 'Y'
      AND    jta.assignment_status_id <> 4
      AND    jtb.task_id          = b_TaskID;

   l_TaskID   NUMBER;
   l_INVITOR  NUMBER;

BEGIN
  /*****************************************************************************
  ** Retrieve the globals that where set
  *****************************************************************************/
  l_AdminWFRole :=  wf_engine.GetItemAttrNumber( itemtype => itemtype
                                               , itemkey  => itemkey
                                               , aname    => 'CALENDAR_ADMIN'
                                               );

  l_TaskID := wf_engine.GetItemAttrNumber( itemtype => itemtype
                                         , itemkey  => itemkey
                                         , aname    => 'TASK_ID'
                                         );

  l_INVITOR:= wf_engine.GetItemAttrNumber( itemtype => itemtype
                                         , itemkey  => itemKey
                                         , aname    => 'INVITOR'
                                         );

  /*****************************************************************************
  ** Get Appointment details for every invitee and start a notification WF for
  ** all of them.
  *****************************************************************************/
  FOR r_Task IN c_Task(l_TaskID)
  LOOP <<ASSIGNEES>>
    /***************************************************************************
    ** Initialize the workflow
    ***************************************************************************/
    wf_engine.CreateProcess( itemtype => l_ItemType
                           , itemkey  => r_Task.ItemKey
                           , process  => 'JTF_TASK_REMINDER'
                           );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'CALENDAR_ADMIN'
                             , avalue   => l_AdminWFRole
                             );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE'
                               , avalue   => r_Task.INVITEE
                               );
---Bug # 4089393, amigupta, Setting new attribute value INVITEE_CODE

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE_CODE'
                               , avalue   => r_Task.INVITEE_CODE
                               );


    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITOR'
                               , avalue   => l_INVITOR
                               );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ID'
                               , avalue   => l_TaskID
                               );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_NAME'
                             , avalue   => r_Task.TASK_NAME
                             );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_DESCRIPTION'
                             , avalue   => r_Task.TASK_DESCRIPTION
                             );

    --
    -- Start and end date/time will have to be adjusted for the recipients timezone
    --

    --
    -- I need to get the user_id for the INVITEE
    --
    l_user_id        := JTF_CAL_UTILITY_PVT.GetUserID(r_Task.INVITEE);
    l_DestTimezoneID := NVL(FND_PROFILE.Value_Specific( name    => 'CLIENT_TIMEZONE_ID'
                                                      , user_id => l_user_id
                                                      )
                           ,4 -- If not set on any level, default to PST
                           );

    --
    -- Adjust startdate from Task/Server timezone to recipient client timezone
    --
    JTF_CAL_UTILITY_PVT.AdjustForTimezone
    ( p_source_tz_id    =>   r_Task.SourceTimezoneID
    , p_dest_tz_id      =>   l_DestTimezoneID
    , p_source_day_time =>   r_Task.START_DATE
    , x_dest_day_time   =>   l_StartDateCorrected
    );

    --
    -- Adjust enddate from Task/Server timezone to recipient client timezone
    --
    JTF_CAL_UTILITY_PVT.AdjustForTimezone
    ( p_source_tz_id    =>   r_Task.SourceTimezoneID
    , p_dest_tz_id      =>   l_DestTimezoneID
    , p_source_day_time =>   r_Task.END_DATE
    , x_dest_day_time   =>   l_EndDateCorrected
    );


    wf_engine.SetItemAttrDate( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'START_DATE'
                             , avalue   => l_StartDateCorrected
                             );

    wf_engine.SetItemAttrDate( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'END_DATE'
                             , avalue   => l_EndDateCorrected
                             );

    /***************************************************************************
    ** Start the workflow
    ***************************************************************************/
    wf_engine.StartProcess( itemtype => l_itemtype
                          , itemkey  => r_Task.ItemKey
                          );

  END LOOP ASSIGNEES;

  /*****************************************************************************
  ** All went well return 'NO_ERROR'
  *****************************************************************************/
  resultout := 'COMPLETE:NO_ERROR';

EXCEPTION
  WHEN OTHERS
  THEN
    IF (c_Task%ISOPEN)
    THEN
      CLOSE c_Task;
    END IF;
    /*****************************************************************************
    ** Something went wrong return 'ERROR' and set the ERROR_MESSAGE
    *****************************************************************************/
    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'ERROR_MESSAGE'
                             , avalue   => 'CAC_VIEW_WF_PVT.SendReminders(): ' || to_char(SQLCODE)||':'||SQLERRM
                             );

    resultout := 'COMPLETE:ERROR';

END SendReminders;





PROCEDURE UpdateReminders
/*******************************************************************************
** Start of comments
**  Procedure   : UpdateReminders
**  Description : Given the task ID and a new reminder date this procedure will
**                update all the reminders for the appointment, should only be
**                called if the reminder me or start date has changed
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_TaskID           IN         NUMBER   required
**      p_RemindDate       IN         DATE     required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
, p_RemindDate    IN     DATE     -- NEW Date/Time the reminder needs to be send
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'UpdateReminderWF';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;

  l_ItemType                 VARCHAR2(8) := 'JTFTKRDR';
  l_AdminWFRole              VARCHAR2(30);

  CURSOR c_Task
  /*****************************************************************************
  ** Cursor to pick up all the invitees for the appointment. Also picks up
  ** a itemkey from the sequence, this is needed to start the workflow
  *****************************************************************************/
  (b_TaskID NUMBER
  )IS SELECT jta.task_assignment_id             TaskassignmentID
      ,      jta.reminder_wf_item_type          ReminderWFItemType
      ,      jta.reminder_wf_item_key           ReminderWFItemKey
      ,      jta.resource_id                    INVITEE
      ,      jtb.owner_id                       INVITOR
      ,      jtl.task_name                      TASK_NAME
      ,      jtl.description                    TASK_DESCRIPTION
      ,      jtb.calendar_start_date            START_DATE
      ,      jtb.calendar_end_date              END_DATE
      FROM   jtf_tasks_b          jtb
      ,      jtf_tasks_tl         jtl
      ,      jtf_task_all_assignments jta
      WHERE  jtb.task_id          = jtl.task_id
      AND    jtl.language         = userenv('LANG')
      AND    jta.task_id          = jtb.task_id
      AND    jta.show_on_calendar = 'Y'
      AND    jta.assignee_role    = 'OWNER'
      AND    jtb.task_id          = b_TaskID;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_status             VARCHAR2(8);
   l_result             VARCHAR2(30);



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
  ** Get Appointment details for every invitee and start a notification WF for
  ** all of them.
  *****************************************************************************/
  FOR r_Task IN c_Task(p_TaskID)
  LOOP <<ASSIGNEES>>
    /***************************************************************************
    ** Initialize the workflow
    ***************************************************************************/
    IF (   (r_Task.ReminderWFItemType IS NOT NULL)
       AND (r_Task.ReminderWFItemKey  IS NOT NULL)
       )
    THEN
      -- Check if the process is stil active
      WF_ITEM_ACTIVITY_STATUS.Root_Status( itemtype => r_Task.ReminderWFItemType
                                         , itemkey  => r_Task.ReminderWFItemKey
                                         , status   => l_status
                                         , result   => l_result
                                         );
      IF (l_status = 'ACTIVE')
      THEN
        -- abort the existing process
        wf_engine.AbortProcess( itemtype => r_Task.ReminderWFItemType
                              , itemkey  => r_Task.ReminderWFItemKey
                              , process  => 'DELAYSTARTREMINDER'
                              , result   => 'COMPLETE'
                              );
      END IF;
    END IF;
    --Check if this is an update to Do Not Remind me
    IF p_RemindDate IS NOT NULL THEN
     StartReminders( p_api_version   => 1.0
                  , p_init_msg_list => fnd_api.g_false
                  , p_commit        => fnd_api.g_true
                  , x_return_status => l_return_status
                  , x_msg_count     => l_msg_count
                  , x_msg_data      => l_msg_data
                  , p_INVITOR       => r_Task.INVITOR
                  , p_TaskID        => p_TaskID
                  , p_RemindDate    => p_RemindDate
                  );
    END IF;

    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/
    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;

    /***************************************************************************
    ** Save the workflow itemtype and item key so we can update the reminder WF
    ** if the start date or remind me settings change
    ***************************************************************************/

    UPDATE jtf_task_all_assignments
    SET reminder_wf_item_type = r_Task.ReminderWFItemType
    ,   reminder_wf_item_key  = r_Task.ReminderWFItemKey
    WHERE task_id  = p_TaskID;

  END LOOP ASSIGNEES;

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

END UpdateReminders;

/*
amigupta, Enh # 3880081 STARTS HERE
*/

PROCEDURE UpdateAttendee
/*******************************************************************************
** Start of comments
**  Procedure   : UpdateReminders
**  Description : Given the task ID and a new reminder date this procedure will
**                update all the reminders for the appointment, should only be
**                called if the reminder me or start date has changed
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_TaskID           IN         NUMBER   required
**      p_RemindDate       IN         DATE     required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_INVITEE       IN     NUMBER   -- Resource ID of Invitee
, p_INVITEE_TYPE  IN     VARCHAR2 --Resource Type of the INVITEE
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'UpdateAttendeeWF';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;

  l_ItemType                 VARCHAR2(8) := 'CACVWSWF';
  l_task_type_name           VARCHAR2(30);
  l_task_priority_name       VARCHAR2(30);
  l_timezone                 VARCHAR2(80);

  l_AdminWFRole       VARCHAR2(30);
  l_AdminWFName       VARCHAR2(30);
  l_AdminEmpNumber    NUMBER;

CURSOR c_invitor
   /****************************************************************************
   ** Pick up appointment owner
   ****************************************************************************/
   (p_task_id NUMBER)
   IS
  SELECT tsk_vl.task_id, owner_id,owner_type_code
      FROM jtf_tasks_vl tsk_vl,
      jtf_task_all_assignments tsk_asg
     WHERE tsk_vl.task_id = p_task_id
	 and tsk_vl.task_id = tsk_asg.task_id
          AND assignee_role = 'OWNER' ;

  CURSOR c_Task
  /*****************************************************************************
  ** Cursor to pick up all the invitees for the appointment. Also picks up
  ** a itemkey from the sequence, this is needed to start the workflow
  *****************************************************************************/
   (b_TaskID NUMBER, b_INVITEE  NUMBER, b_INVITEE_TYPE  VARCHAR2
  )IS SELECT to_char(cac_vws_itemkey_s.NEXTVAL) ItemKey
      ,      jta.task_assignment_id             TASK_ASSIGNMENT_ID
      ,      jta.resource_id                    INVITEE
      ,      jta.resource_type_code             INVITEE_CODE
      ,      jtl.task_name                      TASK_NAME
      ,      jtl.description                    TASK_DESCRIPTION
      ,      jtb.calendar_start_date            START_DATE
      ,      jtb.task_type_id                   TYPE_ID
      ,      jtb.task_priority_id               PRIORITY_ID
      ,      (jtb.calendar_end_date - jtb.calendar_start_date)*24*60 DURATION
      ,      jtb.timezone_id                    TIMEZONE_ID
      FROM   jtf_tasks_b          jtb
      ,      jtf_tasks_tl         jtl
      ,      jtf_task_all_assignments jta
      WHERE  jtb.task_id          = jtl.task_id
      AND    jtl.language         = userenv('LANG')
      AND    jta.task_id          = jtb.task_id
      AND    jta.show_on_calendar = 'Y'
      AND    jta.assignee_role    = 'ASSIGNEE'
       AND    jtb.task_id          = b_TaskID
      AND    jta.resource_id      =  b_INVITEE
      AND    jta.resource_type_code  =   b_INVITEE_TYPE  ;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_status             VARCHAR2(8);
   l_result             VARCHAR2(30);
   l_invitor                  c_invitor%ROWTYPE;



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
  ** Get Appointment details for every invitee and start a notification WF for
  ** all of them.
  *****************************************************************************/
 OPEN c_invitor (p_TaskID);
  FETCH c_invitor INTO l_invitor;
  IF c_invitor%NOTFOUND  THEN
    CLOSE c_invitor;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  CLOSE c_invitor;

  FOR r_Task IN c_Task(p_TaskID, p_INVITEE, p_INVITEE_TYPE)
  LOOP <<ASSIGNEES>>

  WF_Role( l_invitor.owner_id
           , l_invitor.owner_type_code
           , l_AdminWFRole
           , l_AdminWFName
           , l_AdminEmpNumber
           );


  l_task_type_name := get_type_name(r_Task.TYPE_ID);
  l_task_priority_name := get_type_name(r_Task.PRIORITY_ID);
  l_timezone  := GetTimezone(p_timezone_id => r_Task.timezone_id);

   wf_engine.CreateProcess( itemtype => l_ItemType
                           , itemkey  => r_Task.ItemKey
                           , process  => 'UPDATE_INVITATION'
                           );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'CALENDAR_ADMIN'
                             , avalue   => l_AdminWFRole
                             );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'INVITOR'
                             , avalue   => l_invitor.owner_id
                             );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE'
                               , avalue   => r_Task.INVITEE
                               );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE_CODE'
                               , avalue   => r_Task.INVITEE_CODE
                               );

 wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ASSIGNMENT_ID'
                               , avalue   => r_Task.TASK_ASSIGNMENT_ID
                               );

      wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ID'
                               , avalue   => p_TaskID
                               );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_NAME'
                             , avalue   => r_Task.TASK_NAME
                             );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_DESCRIPTION'
                             , avalue   => r_Task.TASK_DESCRIPTION
                             );

    wf_engine.SetItemAttrDate( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'START_DATE'
                             , avalue   => r_Task.START_DATE
                             );

   wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TYPE'
                             , avalue   => l_task_type_name
                             );
     wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'PRIORITY'
                             , avalue   => l_task_priority_name
                             );
     wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  =>   r_Task.ItemKey
                             , aname    =>  'DURATION'
                             , avalue   =>  get_duration(r_Task.DURATION)
                             );
    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  =>   r_Task.ItemKey
                             , aname    =>  'TIMEZONE'
                             , avalue   =>  l_timezone
                             );

    /***************************************************************************
    ** Start the workflow
    ***************************************************************************/

    wf_engine.StartProcess( itemtype => l_itemtype
                          , itemkey  => r_Task.ItemKey
                          );


    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/


    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;
    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/
    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;

  END LOOP ASSIGNEES;

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

END UpdateAttendee;

/*
amigupta, Enh 3880081 ENDS HERE
*/

FUNCTION GetDayNumber
/*******************************************************************************
** Start of comments
**  FUNCTION    : GetDayNumber
**  Description : This function will return a translated enumeration of the day
**				  in the month i.e. 1 will return 1st, 2 will return 2nd etc
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_DayNumber   	   IN 		  NUMBER
**
** End of comments
******************************************************************************/
( p_DayNumber	  IN    NUMBER
)RETURN VARCHAR2
IS
  CURSOR c_Day
  ( b_DayNumber VARCHAR2
  ) IS SELECT meaning
  	   FROM WF_LOOKUPS
  	   WHERE lookup_type = 'JTF_DAY_NUMBERS'
  	   AND   lookup_code = b_DayNumber;

  l_DayNumber VARCHAR2(80);

BEGIN
   OPEN c_Day(to_char(p_DayNumber));
   FETCH c_Day INTO l_DayNumber;
   CLOSE c_Day;
   RETURN l_DayNumber;
END GetDayNumber;


FUNCTION GetDayName
/*******************************************************************************
** Start of comments
**  FUNCTION    : GetWeekdays
**  Description : This function will return a translated string that sums up the
**				  days of the week for an appointment
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_DayCode   	   IN 		  VARCHAR2
**
** End of comments
******************************************************************************/
( p_DayCode	  IN    VARCHAR2
)RETURN VARCHAR2
IS
  CURSOR c_Day
  ( b_DayCode VARCHAR2
  ) IS SELECT meaning
  	   FROM WF_LOOKUPS
  	   WHERE lookup_type = 'JTF_DAY_NAMES'
  	   AND   lookup_code = b_DayCode;

  l_DayName VARCHAR2(80);

BEGIN
   OPEN c_Day(p_DayCode);
   FETCH c_Day INTO l_DayName;
   CLOSE c_Day;
   RETURN l_DayName;
END GetDayName;


FUNCTION GetDays
/*******************************************************************************
** Start of comments
**  FUNCTION    : GetWeekdays
**  Description : This function will return a translated string that sums up the
**				  days of the week for an appointment
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_DayCode   	   IN 		  VARCHAR2
**
** End of comments
******************************************************************************/
( p_Sunday	  IN    VARCHAR2
, p_Monday	  IN    VARCHAR2
, p_Tuesday	  IN    VARCHAR2
, p_Wednesday IN    VARCHAR2
, p_Thursday  IN    VARCHAR2
, p_Friday	  IN    VARCHAR2
, p_Saturday  IN    VARCHAR2
)RETURN VARCHAR2
IS
  l_days VARCHAR2(2000):= NULL;

BEGIN
  IF (p_Sunday = 'Y')
  THEN
    l_days := l_days||GetDayName('SUN');
  END IF;

  IF (p_Monday = 'Y')
  THEN
    IF (l_days IS NOT NULL)
	THEN
	  l_days := l_days||',';
	END IF;
    l_days := l_days||GetDayName('MON');
  END IF;

  IF (p_Tuesday = 'Y')
  THEN
    IF (l_days IS NOT NULL)
	THEN
	  l_days := l_days||',';
	END IF;
    l_days := l_days||GetDayName('TUE');
  END IF;

  IF (p_Wednesday = 'Y')
  THEN
    IF (l_days IS NOT NULL)
	THEN
	  l_days := l_days||',';
	END IF;
    l_days := l_days||GetDayName('WED');
  END IF;


  IF (p_Thursday = 'Y')
  THEN
    IF (l_days IS NOT NULL)
	THEN
	  l_days := l_days||',';
	END IF;
    l_days := l_days||GetDayName('THU');
  END IF;


  IF (p_Friday = 'Y')
  THEN
    IF (l_days IS NOT NULL)
	THEN
	  l_days := l_days||',';
	END IF;
    l_days := l_days||GetDayName('FRI');
  END IF;


  IF (p_Saturday = 'Y')
  THEN
    IF (l_days IS NOT NULL)
	THEN
	  l_days := l_days||',';
	END IF;
    l_days := l_days||GetDayName('SAT');
  END IF;

  RETURN l_days;
END GetDays;

/*
sankgupt, Bug # 5011863 STARTS HERE
*/

PROCEDURE DeleteAttendee
/*******************************************************************************
** Start of comments
**  Procedure   : DeleteAttendee
**  Description : Given the task ID and the Invitee id this procedure will send reminders to
**                attendees if the appointment is deleted
**
**  Parameters  :
**      name               direction  type     required
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_TaskID           IN         NUMBER   required
**      p_RemindDate       IN         DATE     required
**      p_INVITEE          IN         NUMBER   required
**      p_INVITEE_TYPE     IN         VARCHAR2 required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_INVITEE       IN     NUMBER   -- Resource ID of Invitee
, p_INVITEE_TYPE  IN     VARCHAR2 --Resource Type of the INVITEE
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'UpdateAttendeeWF';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;

  l_ItemType                 VARCHAR2(8) := 'CACVWSWF';
  l_task_type_name           VARCHAR2(30);
  l_task_priority_name       VARCHAR2(30);
  l_timezone                 VARCHAR2(80);

  l_AdminWFRole       VARCHAR2(30);
  l_AdminWFName       VARCHAR2(30);
  l_AdminEmpNumber    NUMBER;

CURSOR c_invitor
   /****************************************************************************
   ** Pick up appointment owner
   ****************************************************************************/
   (p_task_id NUMBER)
   IS
  SELECT tsk_vl.task_id, owner_id,owner_type_code
      FROM jtf_tasks_vl tsk_vl,
      jtf_task_all_assignments tsk_asg
     WHERE tsk_vl.task_id = p_task_id
	 and tsk_vl.task_id = tsk_asg.task_id
          AND assignee_role = 'OWNER' ;

  CURSOR c_Task
  /*****************************************************************************
  ** Cursor to pick up all the invitees for the appointment. Also picks up
  ** a itemkey from the sequence, this is needed to start the workflow
  *****************************************************************************/
   (b_TaskID NUMBER, b_INVITEE  NUMBER, b_INVITEE_TYPE  VARCHAR2
  )IS SELECT to_char(cac_vws_itemkey_s.NEXTVAL) ItemKey
      ,      jta.task_assignment_id             TASK_ASSIGNMENT_ID
      ,      jta.resource_id                    INVITEE
      ,      jta.resource_type_code             INVITEE_CODE
      ,      jtl.task_name                      TASK_NAME
      ,      jtl.description                    TASK_DESCRIPTION
      ,      jtb.calendar_start_date            START_DATE
      ,      jtb.task_type_id                   TYPE_ID
      ,      jtb.task_priority_id               PRIORITY_ID
      ,      (jtb.calendar_end_date - jtb.calendar_start_date)*24*60 DURATION
      ,      jtb.timezone_id                    TIMEZONE_ID
      FROM   jtf_tasks_b          jtb
      ,      jtf_tasks_tl         jtl
      ,      jtf_task_all_assignments jta
      WHERE  jtb.task_id          = jtl.task_id
      AND    jtl.language         = userenv('LANG')
      AND    jta.task_id          = jtb.task_id
      AND    jta.show_on_calendar = 'Y'
      AND    jta.assignee_role    = 'ASSIGNEE'
       AND    jtb.task_id          = b_TaskID
      AND    jta.resource_id      =  b_INVITEE
      AND    jta.resource_type_code  =   b_INVITEE_TYPE  ;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_status             VARCHAR2(8);
   l_result             VARCHAR2(30);
   l_invitor                  c_invitor%ROWTYPE;



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
  ** Get Appointment details for every invitee and start a notification WF for
  ** all of them.
  *****************************************************************************/
 OPEN c_invitor (p_TaskID);
  FETCH c_invitor INTO l_invitor;
  IF c_invitor%NOTFOUND  THEN
    CLOSE c_invitor;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  CLOSE c_invitor;

  FOR r_Task IN c_Task(p_TaskID, p_INVITEE, p_INVITEE_TYPE)
  LOOP <<ASSIGNEES>>

  WF_Role( l_invitor.owner_id
           , l_invitor.owner_type_code
           , l_AdminWFRole
           , l_AdminWFName
           , l_AdminEmpNumber
           );


  l_task_type_name := get_type_name(r_Task.TYPE_ID);
  l_task_priority_name := get_type_name(r_Task.PRIORITY_ID);
  l_timezone  := GetTimezone(p_timezone_id => r_Task.timezone_id);

   wf_engine.CreateProcess( itemtype => l_ItemType
                           , itemkey  => r_Task.ItemKey
                           , process  => 'DELETE_INVITATION'
                           );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'CALENDAR_ADMIN'
                             , avalue   => l_AdminWFRole
                             );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'INVITOR'
                             , avalue   => l_invitor.owner_id
                             );

    wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE'
                               , avalue   => r_Task.INVITEE
                               );

  wf_engine.SetItemAttrText( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'INVITEE_CODE'
                               , avalue   => r_Task.INVITEE_CODE
                               );

 wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ASSIGNMENT_ID'
                               , avalue   => r_Task.TASK_ASSIGNMENT_ID
                               );

      wf_engine.SetItemAttrNumber( itemtype => l_itemtype
                               , itemkey  => r_Task.ItemKey
                               , aname    => 'TASK_ID'
                               , avalue   => p_TaskID
                               );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_NAME'
                             , avalue   => r_Task.TASK_NAME
                             );

    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TASK_DESCRIPTION'
                             , avalue   => r_Task.TASK_DESCRIPTION
                             );

    wf_engine.SetItemAttrDate( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'START_DATE'
                             , avalue   => r_Task.START_DATE
                             );

   wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'TYPE'
                             , avalue   => l_task_type_name
                             );
     wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  => r_Task.ItemKey
                             , aname    => 'PRIORITY'
                             , avalue   => l_task_priority_name
                             );
     wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  =>   r_Task.ItemKey
                             , aname    =>  'DURATION'
                             , avalue   =>  get_duration(r_Task.DURATION)
                             );
    wf_engine.SetItemAttrText( itemtype => l_itemtype
                             , itemkey  =>   r_Task.ItemKey
                             , aname    =>  'TIMEZONE'
                             , avalue   =>  l_timezone
                             );

    /***************************************************************************
    ** Start the workflow
    ***************************************************************************/

    wf_engine.StartProcess( itemtype => l_itemtype
                          , itemkey  => r_Task.ItemKey
                          );


    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/


    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;
    /***************************************************************************
    ** Standard check of p_commit (WF won't start until commited)
    ***************************************************************************/
    IF FND_API.To_Boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;

  END LOOP ASSIGNEES;

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

END DeleteAttendee;

/*
sankgupt, Bug # 5011863 STARTS HERE
*/

PROCEDURE GetRepeatingRule
/*******************************************************************************
** Start of comments
**  Procedure   : GetRepeatingRule
**  Description : Set the attributes for the repeating rule and determine which
**                notification to send
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     VARCHAR2 required
**
**  Notes :
**    1) Expects WF item attributes 'TASK_ID' to be available to this procedure.
**    2) This procedure should only be used within Workflow
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout  OUT    NOCOPY	VARCHAR2
)
IS
  l_TaskID       NUMBER;
  l_ResultType   VARCHAR2(80);
  l_days		 VARCHAR2(2000);
  l_DayNumber	 VARCHAR2(2000);
  l_which        VARCHAR2(80);
  l_timezone     VARCHAR2(80);

  CURSOR c_rule
  /*****************************************************************************
  ** Get the recurrance rule for the given task
  *****************************************************************************/
  (b_task_id IN NUMBER
  )IS   SELECT jtr.occurs_which
        ,	   jtr.day_of_week
        ,	   jtr.date_of_month
        ,	   jtr.occurs_month
        ,	   jtr.occurs_uom
        ,	   jtr.occurs_every
        ,	   jtr.occurs_number
        ,	   jtr.start_date_active
        ,	   jtr.end_date_active
        ,	   jtr.sunday
        ,	   jtr.monday
        ,	   jtr.tuesday
        ,	   jtr.wednesday
        ,	   jtr.thursday
        ,	   jtr.friday
        ,	   jtr.saturday
        ,      jtb.timezone_id
        ,      (jtb.calendar_end_date - jtb.calendar_start_date)*24*60 duration
        FROM jtf_task_recur_rules jtr
		,	 jtf_tasks_b		  jtb
		WHERE jtb.recurrence_rule_id = jtr.recurrence_rule_id
		AND	  jtb.task_id = b_task_id;

   r_rule c_rule%ROWTYPE;

BEGIN
  IF (funcmode = 'RUN')
  THEN
    /***************************************************************************
    ** 'RUN' function from WF
    ***************************************************************************/

    /***************************************************************************
    ** Pick up the Task ID Attribute
    ***************************************************************************/
    l_TaskID := wf_engine.GetItemAttrNumber
                         ( itemtype => itemtype
                         , itemkey  => itemkey
                         , aname    => 'TASK_ID'
                         );

    /***************************************************************************
    ** Get the Rule if one was set
    ***************************************************************************/
    OPEN c_rule(l_TaskID);
	FETCH c_rule INTO r_rule;
	IF (c_rule%FOUND)
	THEN

      WF_ENGINE.SetItemAttrNumber( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'OCCURS_EVERY'
                                 , avalue   => r_rule.occurs_every
                                 );
      WF_ENGINE.SetItemAttrText( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'DURATION'
                                 , avalue   => get_duration(r_rule.duration)
                                 );
      WF_ENGINE.SetItemAttrDate( itemtype => itemtype
                                 , itemkey  => itemkey
                                 , aname    => 'REPEAT_END_DATE'
                                 , avalue   => r_rule.end_date_active
                                 );

      l_Days := GetDays( p_Sunday    => r_rule.sunday
                       , p_Monday	 => r_rule.monday
                       , p_Tuesday	 => r_rule.tuesday
                       , p_Wednesday => r_rule.wednesday
                       , p_Thursday  => r_rule.thursday
                       , p_Friday	 => r_rule.friday
                       , p_Saturday  => r_rule.saturday
                       );

      l_DayNumber := GetDayNumber(p_DayNumber  => r_rule.date_of_month);
      l_which     := GetDayNumber(p_DayNumber  => r_rule.occurs_which);
      l_timezone  := GetTimezone(p_timezone_id => r_rule.timezone_id);

      WF_ENGINE.SetItemAttrText( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'DAYSOFWEEK'
                               , avalue   => l_days
                               );

      WF_ENGINE.SetItemAttrText( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'DATE_OF_MONTH'
                               , avalue   => l_DayNumber
							   );

      WF_ENGINE.SetItemAttrText( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'OCCURS_WHICH'
                               , avalue   => l_which
                               );

      WF_ENGINE.SetItemAttrText( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'TIMEZONE'
                               , avalue   => l_timezone
                               );


      /*************************************************************************
      ** Determine the function result
      *************************************************************************/
   	  IF r_rule.occurs_uom = 'DAY'
	  THEN
        l_ResultType:= 'REPEAT_DAY';

	  ELSIF r_rule.occurs_uom = 'WEK'
	  THEN
        l_ResultType:= 'REPEAT_WEEK';

	  ELSIF r_rule.occurs_uom = 'MON'
	  THEN
        IF (r_rule.date_of_month IS NOT NULL)
		THEN
          l_ResultType:= 'REPEAT_MON1';
		ELSE
          l_ResultType:= 'REPEAT_MON2';
		END IF;
	  END IF;
	ELSE
      /*************************************************************************
      ** No rule found
      *************************************************************************/
      l_ResultType:= 'SINGLE';
	END IF;

    CLOSE c_rule;

    resultout := 'COMPLETE:'||l_ResultType;

  ELSIF (funcmode = 'CANCEL')
  THEN
    /***************************************************************************
    ** 'CANCEL' function from WF
    ***************************************************************************/
    resultout := 'COMPLETE:SINGLE';
  ELSIF (funcmode = 'TIMEOUT')
  THEN
    /***************************************************************************
    ** 'TIMEOUT' function from WF
    ***************************************************************************/
    resultout := 'COMPLETE:SINGLE';
  ELSE
    /***************************************************************************
    ** Unknown function from WF - raise error
    ***************************************************************************/
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    /*****************************************************************************
    ** Something went wrong return 'ERROR' and set the ERROR_MESSAGE
    *****************************************************************************/
	IF (c_rule%ISOPEN)
	THEN
      CLOSE c_rule;
	END IF;

    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'ERROR_MESSAGE'
                             , avalue   => 'CAC_VIEW_WF_PVT.GetRepeatingRule(): ' || to_char(SQLCODE)||':'||SQLERRM
                             );

    resultout := 'COMPLETE:ERROR';

END GetRepeatingRule;

PROCEDURE GetInvitationStatus
/*******************************************************************************
** Start of comments
**  Procedure   : GetInvitationStatus
**  Description : Set the attributes for the invitation status and determine which
**                notification to send
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     VARCHAR2 required
**
**  Notes :
**    1) Expects WF item attributes 'ASSIGNMENT_STATUS_ID' to be available to this procedure.
**    2) This procedure should only be used within Workflow
**    3) Created for 2219647
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout  OUT    NOCOPY	VARCHAR2
)
IS
  l_result_type   VARCHAR2(80);
  l_assignment_status_id NUMBER;


BEGIN
  IF (funcmode = 'RUN')
  THEN
    /***************************************************************************
    ** 'RUN' function from WF
    ***************************************************************************/

    /***************************************************************************
    ** Pick up the Task ID Attribute
    ***************************************************************************/
    l_assignment_status_id := wf_engine.GetItemAttrNumber
                         ( itemtype => itemtype
                         , itemkey  => itemkey
                         , aname    => 'ASSIGNMENT_STATUS_ID'
                         );


      /*************************************************************************
      ** Determine the function result
      *************************************************************************/
   	  IF l_assignment_status_id = 3
	  THEN
        l_result_type:= 'APPROVED';

	  ELSIF l_assignment_status_id = 4
	  THEN
        l_result_type:= 'REJECTED';
     END IF;
    resultout := 'COMPLETE:'||l_result_type;
  END IF;
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
EXCEPTION
  WHEN OTHERS
  THEN

    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'ERROR_MESSAGE'
                             , avalue   => 'CAC_VIEW_WF_PVT.GetInvitationStatus(): ' || to_char(SQLCODE)||':'||SQLERRM
                             );
    resultout := 'COMPLETE:ERROR';

END GetInvitationStatus;


END CAC_VIEW_WF_PVT;

/
