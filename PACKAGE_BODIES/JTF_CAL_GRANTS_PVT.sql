--------------------------------------------------------
--  DDL for Package Body JTF_CAL_GRANTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_GRANTS_PVT" AS
/* $Header: jtfvcgtb.pls 120.2 2006/07/28 10:36:02 sankgupt ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_CAL_GRANTS';

FUNCTION get_username
( resourceId        IN      VARCHAR2
) RETURN VARCHAR2
IS
    l_username        fnd_user.user_name%TYPE;
    CURSOR C_USERNAME IS
    select user_name from jtf_rs_resource_extns
    where resource_id = TO_NUMBER(resourceId);
BEGIN
    OPEN C_USERNAME;
    FETCH C_USERNAME INTO l_username;
    IF (C_USERNAME %NOTFOUND) THEN
        CLOSE C_USERNAME;
        --RAISE NO_DATA_FOUND;
        RETURN -1;
    END IF;
    CLOSE C_USERNAME;
    RETURN l_username;
END get_username;

FUNCTION get_instance_set_id
( instance_set_name        IN      VARCHAR2
) RETURN NUMBER
IS
    l_instance_set_id        NUMBER;
    CURSOR C_INSTANCE_SET_ID IS
    select instance_set_id from fnd_object_instance_sets
    where instance_set_name = jtf_task_security_pvt.RESOURCE_TASKS_SET;
BEGIN
    OPEN C_INSTANCE_SET_ID;
    FETCH C_INSTANCE_SET_ID INTO l_instance_set_id;
    IF (C_INSTANCE_SET_ID %NOTFOUND) THEN
        CLOSE C_INSTANCE_SET_ID;
        --RAISE NO_DATA_FOUND;
        RETURN -1;
    END IF;
    CLOSE C_INSTANCE_SET_ID;
    RETURN l_instance_set_id;
END get_instance_set_id;

PROCEDURE doRevoke
( api_version       IN      NUMBER
, grant_guid        IN      RAW
)
IS
  l_success             VARCHAR2(1);
  l_error               NUMBER;
BEGIN
    fnd_grants_pkg.revoke_grant
    (   p_api_version   => api_version
       ,p_grant_guid    => grant_guid
       ,x_success       => l_success
       ,x_errorcode     => l_error
    );
    /** Add error check  **/
    IF (l_success <> 'T') THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END doRevoke;

PROCEDURE doCalGrant
( api_version       IN      NUMBER
 ,menu_name         IN      VARCHAR2
 ,p_GranterID       IN      VARCHAR2
 ,grantee_key       IN      VARCHAR2
)
IS
    l_grant_guid    RAW(16);
    l_success       VARCHAR2(1);
    l_error         NUMBER;
BEGIN
    fnd_grants_pkg.grant_function( p_api_version        => api_version
                                 , p_menu_name          => menu_name
                                 , p_instance_type      => CALENDAR_INSTANCE_TYPE
                                 , p_object_name        => CALENDAR_OBJECT
                                 , p_instance_pk1_value => p_GranterID
                                 , p_instance_pk2_value => CALENDAR_RESOURCE_TYPE
                                 , p_grantee_type       => GRANTEE_TYPE
                                 , p_grantee_key        => grantee_key
                                 , p_start_date         => SYSDATE
                                 , p_end_date           => NULL
                                 , p_program_name       => PROGRAM_NAME
                                 , p_program_tag        => PROGRAM_TAG
                                 , x_grant_guid         => l_grant_guid
                                 , x_success            => l_success
                                 , x_errorcode          => l_error
                                 );
    /** Add error check  **/
    IF (l_success <> 'T') THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END doCalGrant;

PROCEDURE doTasksGrant
( api_version           IN      NUMBER
 ,menu_name             IN      VARCHAR2
 ,l_instance_set_id     IN      NUMBER
 ,p_GranterID           IN      VARCHAR2
 ,grantee_key           IN      VARCHAR2
)
IS
    l_grant_guid    RAW(16);
    l_success       VARCHAR2(1);
    l_error         NUMBER;
BEGIN
    fnd_grants_pkg.grant_function( p_api_version        => api_version
                                 , p_menu_name          => menu_name
                                 , p_instance_type      => TASK_INSTANCE_TYPE
                                 , p_instance_set_id    => l_instance_set_id
                                 , p_object_name        => jtf_task_security_pvt.TASK_OBJECT
                                 , p_grantee_type       => GRANTEE_TYPE
                                 , p_grantee_key        => grantee_key
                                 , p_start_date         => SYSDATE
                                 , p_end_date           => NULL
                                 , p_program_name       => PROGRAM_NAME
                                 , p_program_tag        => PROGRAM_TAG
                                 , x_grant_guid         => l_grant_guid
                                 , x_success            => l_success
                                 , x_errorcode          => l_error
                                 , p_parameter1         => p_GranterID
                                 );
    /** Add error check  **/
    IF (l_success <> 'T') THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
END doTasksGrant;

PROCEDURE UpdateGrants
/*******************************************************************************
** Given:
** - the Granter
** - a list of Read Only Grantees
** - a list of Full Access Grantees
** This API will make sure that the proper grants are create/deleted
*******************************************************************************/
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                 IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level       IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_GranterID              IN     VARCHAR2
, p_ReadAccess             IN     VARCHAR2
, p_FullAccess             IN     VARCHAR2
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'UpdateGrants';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;
  l_grant_guid               RAW(16);
  l_success                  VARCHAR2(1);
  l_error                    NUMBER;

  l_instance_set_id          NUMBER;

  l_CalAccessTbl             GranteeTbl;
  l_TaskAccessTbl            GranteeTbl;

  l_index1                   NUMBER;
  l_index2                   NUMBER;
  i                          BINARY_INTEGER;
  j                          BINARY_INTEGER;

  revoke_cal_found           BOOLEAN:=true;
  revoke_tasks_found         BOOLEAN:=true;

  /** Define a cursor C_CAL to fetch Calendar Read and Full Access for the given p_GranterID  **/
  CURSOR C_CAL IS
  SELECT fgs.grant_guid, fgs.grantee_key, fmu.menu_name
  FROM FND_GRANTS fgs, FND_MENUS fmu, FND_OBJECTS fos
  WHERE fgs.object_id = fos.object_id
  AND   fos.obj_name = CALENDAR_OBJECT
  AND   fgs.menu_id = fmu.menu_id
  AND   fmu.menu_name IN (CALENDAR_READ_PRIVILEGE
                         ,CALENDAR_FULL_PRIVILEGE
                         ) -- Calendar Read and Full Access
  AND   instance_pk1_value = p_GranterID
  AND   instance_pk2_value = CALENDAR_RESOURCE_TYPE
  AND   instance_type = CALENDAR_INSTANCE_TYPE
  AND   grantee_type = GRANTEE_TYPE
  AND   program_name = PROGRAM_NAME
  AND   program_tag = 'ACCESS LEVEL';

  /** Define a cursor C_CAL to fetch Tasks Read and Full Access for the given p_GranterID  **/
  CURSOR C_TASKS IS
  SELECT fgs.grant_guid, fgs.grantee_key, fmu.menu_name
  FROM FND_GRANTS fgs, FND_MENUS fmu, FND_OBJECTS fos
  WHERE fgs.object_id = fos.object_id
  AND   fos.obj_name =  jtf_task_security_pvt.TASK_OBJECT
  AND   fgs.menu_id = fmu.menu_id
  AND   fmu.menu_name IN (jtf_task_security_pvt.READ_PRIVILEGE
                         ,jtf_task_security_pvt.FULL_PRIVILEGE
                         ) -- Task Read and Full Access
  AND   instance_type = TASK_INSTANCE_TYPE
  AND   instance_set_id = l_instance_set_id
  AND   parameter1 = p_GranterID
  AND   grantee_type = GRANTEE_TYPE
  AND   program_name = PROGRAM_NAME
  AND   program_tag = 'ACCESS LEVEL';

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
  ** Submit JSP will return a comma delimited string, need to break it up
  ** Merge p_ReadAccess and p_FullAccess into one table of records
  ** l_CalAccessTbl for Calendar, l_TaskAccessTbl for Tasks
  *****************************************************************************/
  i        := 1;
  l_index1 := 1;
  l_index2 := 1;

  WHILE length(p_ReadAccess) <> 0
  LOOP <<READ_ACCESS>>
    l_index2 := instr(p_ReadAccess
                     ,','
                     ,l_index1
                     ,1
                     );
    IF (l_index2 = 0)
    THEN
      l_index2 := length(p_ReadAccess)+1;
    END IF;

    l_CalAccessTbl(i).GranteeKey := substr( p_ReadAccess
                                    , l_index1
                                    ,(l_index2-l_index1)
                                    );
    l_CalAccessTbl(i).AccessLevel := CALENDAR_READ_PRIVILEGE;

    /** Get the username for a given resource id  **/
    l_TaskAccessTbl(i).GranteeKey := get_username(l_CalAccessTbl(i).GranteeKey);
    IF (l_TaskAccessTbl(i).GranteeKey = '-1') THEN
    	fnd_message.set_name('JTF', 'JTF_CAL_USERNAME_NOT_FOUND');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_TaskAccessTbl(i).AccessLevel := jtf_task_security_pvt.READ_PRIVILEGE;

    i       := i + 1;
    l_index1 := l_index2 + 1;
    IF (l_index2 > length(p_ReadAccess))
    THEN
      EXIT;
    END IF;
  END LOOP READ_ACCESS;

  j        := 1;
  l_index1 := 1;
  l_index2 := 1;
  WHILE length(p_FullAccess) <> 0
  LOOP <<FULL_ACCESS>>
    l_index2 := instr(p_FullAccess
                     ,','
                     ,l_index1
                     ,1
                     );
    IF (l_index2 = 0)
    THEN
      l_index2 := length(p_FullAccess)+1;
    END IF;

    l_CalAccessTbl(i).GranteeKey := substr( p_FullAccess
                                    , l_index1
                                    ,(l_index2-l_index1)
                                    );
    l_CalAccessTbl(i).AccessLevel := CALENDAR_FULL_PRIVILEGE;
    /** Get the username for a given resource id  **/
    l_TaskAccessTbl(i).GranteeKey := get_username(l_CalAccessTbl(i).GranteeKey);
    IF (l_TaskAccessTbl(i).GranteeKey = '-1') THEN
    	fnd_message.set_name('JTF', 'JTF_CAL_USERNAME_NOT_FOUND');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_TaskAccessTbl(i).AccessLevel := jtf_task_security_pvt.FULL_PRIVILEGE;

    i        := i + 1;
    j        := j + 1;
    l_index1 := l_index2 + 1;
    IF (l_index2 > length(p_FullAccess))
    THEN
      EXIT;
    END IF;
  END LOOP FULL_ACCESS;

  /** Get the instance_set_id for instance_name RESOURCE_TASKS_SET **/
  /** It is required in fnd_grants function   **/
  l_instance_set_id := get_instance_set_id(jtf_task_security_pvt.RESOURCE_TASKS_SET);
  IF ( l_instance_set_id = -1) THEN
  	fnd_message.set_name('JTF', 'JTF_CAL_INST_SET_ID_NOT_FOUND');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /** Grant and Revoke Calendar Read and Full Access  **/
  FOR r_cal IN C_CAL LOOP
    revoke_cal_found := true;
    FOR j IN 1 .. NVL(l_CalAccessTbl.LAST,0)
    LOOP <<ADD_CAL_ACCESS>>
        IF ((r_cal.grantee_key = l_CalAccessTbl(j).GranteeKey) AND (r_cal.menu_name = l_CalAccessTbl(j).AccessLevel)) THEN
            /** The resource is already in the database **/
            /** And the acccess level is the same for the resource **/
            l_CalAccessTbl(j).GrantType:=0;
            revoke_cal_found := false;
            EXIT;
        END IF;
    END LOOP ADD_CAL_ACCESS;

    /** The resource is not in the new list, revoke Calendar Read or Full Access **/
    IF (revoke_cal_found) THEN
        doRevoke(l_api_version, r_cal.grant_guid);
    END IF;
  END LOOP;


  /** Loop the l_CalAccessTbl table to grant Read or Full Access  **/
  FOR k IN 1 .. NVL(l_CalAccessTbl.LAST,0)
  LOOP <<ADD_CAL_ACCESS>>
    IF ((l_CalAccessTbl(k).GrantType = 1) AND (l_CalAccessTbl(k).AccessLevel=CALENDAR_READ_PRIVILEGE)) THEN
        /** Grant Calendar READ Access **/
        doCalGrant(l_api_version, CALENDAR_READ_PRIVILEGE, p_GranterID, l_CalAccessTbl(k).GranteeKey);
   ELSIF ((l_CalAccessTbl(k).GrantType = 1) AND (l_CalAccessTbl(k).AccessLevel=CALENDAR_FULL_PRIVILEGE)) THEN
        /** Grant Calendar Full Access  **/
        doCalGrant(l_api_version, CALENDAR_FULL_PRIVILEGE, p_GranterID,l_CalAccessTbl(k).GranteeKey);
    END IF;
  END LOOP ADD_CAL_ACCESS;

  /** Grant and Revoke Task Read Access  **/
  FOR r_tasks IN C_TASKS LOOP
    revoke_tasks_found := true;
    FOR m IN 1 .. NVL(l_TaskAccessTbl.LAST,0)
    LOOP <<ADD_TASKS_ACCESS>>
        IF ((r_tasks.grantee_key = l_TaskAccessTbl(m).GranteeKey) AND (r_tasks.menu_name = l_TaskAccessTbl(m).AccessLevel)) THEN
            /** The resource is already in the database **/
            /** The acccess level is the same for the resource **/
            l_TaskAccessTbl(m).GrantType:=0;
            revoke_tasks_found := false;
            EXIT;
        END IF;
    END LOOP ADD_TASKS_ACCESS;

    /** The resource is not in the new list, revoke Task Read or Full Access **/
    IF (revoke_tasks_found) THEN
        doRevoke(l_api_version, r_tasks.grant_guid);
    END IF;
  END LOOP;


  FOR n IN 1 .. NVL(l_TaskAccessTbl.LAST,0)
  LOOP <<ADD_TASKS_ACCESS>>
    IF ((l_TaskAccessTbl(n).GrantType = 1) AND (l_TaskAccessTbl(n).AccessLevel= jtf_task_security_pvt.READ_PRIVILEGE) ) THEN
        /** Grant Tasks Read Access **/
        doTasksGrant(l_api_version,jtf_task_security_pvt.READ_PRIVILEGE,l_instance_set_id, p_GranterID,l_TaskAccessTbl(n).GranteeKey);
    ELSIF ((l_TaskAccessTbl(n).GrantType = 1) AND (l_TaskAccessTbl(n).AccessLevel=jtf_task_security_pvt.FULL_PRIVILEGE) ) THEN
         /** Grant Tasks Full Access **/
         doTasksGrant(l_api_version,jtf_task_security_pvt.FULL_PRIVILEGE,l_instance_set_id, p_GranterID,l_TaskAccessTbl(n).GranteeKey);
    END IF;
  END LOOP ADD_TASKS_ACCESS;

  /*****************************************************************************
  ** Standard check of p_commit
  *****************************************************************************/
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

END UpdateGrants;

PROCEDURE RevokeGrants
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                 IN     VARCHAR2 DEFAULT fnd_api.g_false
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_resourceId             IN     VARCHAR2
, p_groupId                IN     VARCHAR2
)
IS
   l_api_name        CONSTANT VARCHAR2(30)   := 'RevokeGrants';
   l_api_version     CONSTANT NUMBER         := 1.0;
   l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_grant_guid         RAW(16);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_grant_guid := get_grant_guid(p_resourceId  => p_resourceId,
                                  p_groupId     => p_groupId);
   IF (l_grant_guid IS NOT NULL) THEN
   fnd_grants_pkg.revoke_grant
   (
     p_api_version   => l_api_version,
     p_grant_guid    => l_grant_guid,
     x_success       => l_return_status,
     x_errorcode     => x_msg_data
   );

   IF (l_return_status <> FND_API.G_TRUE)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
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

END RevokeGrants;

PROCEDURE InvokeGrants
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                 IN     VARCHAR2 DEFAULT fnd_api.g_false
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_resourceId             IN     VARCHAR2
, p_groupId                IN     VARCHAR2
, p_accesslevel            IN     VARCHAR2
)
IS
   l_api_name        CONSTANT VARCHAR2(30)   := 'InvokeGrants';
   l_api_version     CONSTANT NUMBER         := 1.0;
   l_api_name_full   CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_grant_guid         RAW(16);
   l_read_access     CONSTANT VARCHAR2(30)   := 'JTF_CAL_READ_ACCESS';
   l_full_access     CONSTANT VARCHAR2(30)   := 'JTF_CAL_FULL_ACCESS';
   l_return             BOOLEAN;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return := has_access_level( p_resourceId  => p_resourceId
                               , p_groupId     => p_groupId
                               );

  /** Check whether the requstor already has an access level -- Full or Readonly
   ** If yes, do not grant Readonly Access to the requestor.
   ** If not, grant Readonly Access to the requestor first                   */

  IF (l_return = false)
  THEN
     fnd_grants_pkg.grant_function( p_api_version     => 1.0
                               , p_menu_name          => l_read_access
                               , p_instance_type      => 'INSTANCE'
                               , p_object_name        => 'JTF_TASK_RESOURCE'
                               , p_instance_pk1_value => nvl(p_groupId,1)
                               , p_instance_pk2_value => 'RS_GROUP'
                               , p_grantee_type       => 'USER'
                               , p_grantee_key          => p_resourceId
                               , p_start_date         => SYSDATE
                               , p_end_date           => NULL
                               , p_program_name       => 'CALENDAR'
                               , p_program_tag        => 'ACCESS LEVEL'
                               , x_grant_guid         => l_grant_guid
                               , x_success            => l_return_status
                               , x_errorcode          => l_msg_data
                               );
  END IF;

/*****************************************************************************
** Grant Administrator privs to the requestor
*****************************************************************************/
fnd_grants_pkg.grant_function( p_api_version          => 1.0
                               , p_menu_name          => p_accesslevel
                               , p_instance_type      => 'INSTANCE'
                               , p_object_name        => 'JTF_TASK_RESOURCE'
                               , p_instance_pk1_value => nvl(p_groupId,1)
                               , p_instance_pk2_value => 'RS_GROUP'
                               , p_grantee_type       => 'USER'
                               , p_grantee_key        => p_resourceId
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

END InvokeGrants;


FUNCTION get_grant_guid
(   p_resourceId             IN     VARCHAR2
,   p_groupId                IN     VARCHAR2
) RETURN RAW
IS
    l_grant_guid               RAW(16);

    /*cursor C is
      SELECT grant_guid FROM FND_GRANTS
      WHERE grantee_key = p_resourceId
      AND instance_pk1_value = p_groupId
      AND instance_pk2_value = 'RS_GROUP'
      AND program_name = 'CALENDAR'; */

    cursor C is
      SELECT fgs.grant_guid
      FROM FND_GRANTS fgs, FND_MENUS fmu
      WHERE grantee_key = p_resourceId
      AND instance_pk1_value = p_groupId
      AND instance_pk2_value = 'RS_GROUP'
      AND program_name = 'CALENDAR'
      AND fgs.menu_id = fmu.menu_id
      AND fmu.menu_name = 'JTF_CAL_ADMIN_ACCESS';

BEGIN
      open C;
      fetch C into l_grant_guid;
      if (C%NOTFOUND) then
        close C;
        raise NO_DATA_FOUND;
        return NULL;
      end if;
      close C;
      return l_grant_guid;
END get_grant_guid;

FUNCTION has_access_level
( p_resourceId          IN     VARCHAR2
, p_groupId             IN     VARCHAR2
) RETURN BOOLEAN
IS
  l_count NUMBER;
  l_return BOOLEAN;
  cursor c_Count is
    SELECT 1 FROM FND_GRANTS
    WHERE grantee_key = p_resourceId
    AND instance_pk1_value = p_groupId
    AND instance_pk2_value = 'RS_GROUP'
    AND program_name = 'CALENDAR';

BEGIN
      l_return := false;

      IF (c_Count%ISOPEN)
      THEN CLOSE c_Count;
      END IF;

      open c_Count;
      fetch c_Count into l_count;
      IF(c_Count%NOTFOUND) then
        return false;
      END IF;

      IF (l_count >= 1) THEN
        l_return := true;
      END IF;

      IF (c_Count%ISOPEN)
      THEN CLOSE c_Count;
      END IF;

      RETURN l_return;
END has_access_level;

END JTF_CAL_GRANTS_PVT;

/
