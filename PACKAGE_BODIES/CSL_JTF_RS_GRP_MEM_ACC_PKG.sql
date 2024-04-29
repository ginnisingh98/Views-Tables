--------------------------------------------------------
--  DDL for Package Body CSL_JTF_RS_GRP_MEM_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_JTF_RS_GRP_MEM_ACC_PKG" AS
/* $Header: csljgacb.pls 120.0 2005/05/24 17:18:20 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_JTF_RS_GROUP_MEMBERS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('JTF_RS_GROUP_MEMBERS');
g_table_name            CONSTANT VARCHAR2(30) := 'JTF_RS_GROUP_MEMBERS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'GROUP_MEMBER_ID';
g_debug_level NUMBER;


/*** Function that checks if group member should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_group_member_id NUMBER
  )
RETURN BOOLEAN
IS
  /** Get the group Id for a given group member Id ***/
  CURSOR c_GetGroupId( b_group_member_id NUMBER )
  IS
    SELECT group_id, resource_id
    FROM  jtf_rs_group_members
    WHERE DELETE_FLAG = 'N'
    AND   group_member_id = b_group_member_id;

  r_GetGroupId  c_GetGroupId%ROWTYPE;

  /** Get all resource ids that reside in a retrieved group id ***/
  CURSOR c_GetResourceId( b_group_id NUMBER )
  IS
    SELECT resource_id
    FROM   jtf_rs_group_members
    WHERE  group_id = b_group_id
    AND    delete_flag = 'N';

  r_GetResourceId  c_GetResourceId%ROWTYPE;

  /*** Initialise the following parameters ***/
  l_group_found boolean := FALSE;
  l_resource_is_mobile boolean := FALSE;
  l_replicate boolean := FALSE;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
      ( p_group_member_id
      , g_table_name
      , 'Entering Replicate_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
  END IF;

  /*** First retrieve the group id for de given group member id ***/
  OPEN  c_GetGroupId ( p_group_member_id );
  FETCH c_GetGroupId INTO r_GetGroupId;
  IF c_GetGroupId%FOUND
  THEN
    l_group_found:=TRUE;
  ELSE
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    THEN
      jtm_message_log_pkg.Log_Msg
        ( p_group_member_id
        , g_table_name
        , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
          'Group member record was deleted'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        );
    END IF;
  END IF;
  CLOSE c_GetGroupId;

  /*** Second retrieve all resource ids for de retrieved group id ***/
  IF l_group_found
  THEN
    FOR r_GetResourceId  IN c_GetResourceId( r_GetGroupId.group_id )
    LOOP
      /*** Then check if the resource from a retrieved group is a mobile resource ***/
      IF JTM_HOOK_UTIL_PKG.isMobileFSresource( r_GetResourceId.resource_id )
      THEN
        l_resource_is_mobile := TRUE;
      END IF;
    END LOOP;
  END IF;

  IF l_resource_is_mobile
  THEN
    l_replicate := TRUE;
  ELSE
    jtm_message_log_pkg.Log_Msg
      ( p_group_member_id
      , g_table_name
      , 'No mobile resources were found for this group id: ' || r_GetGroupId.group_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      );
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN l_replicate;
END Replicate_Record;

/*** Private procedure that inserts given group member related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_group_member_id IN NUMBER
    ,p_resource_id    IN NUMBER
  )
IS
  /*** cursor to retrieve group member details ***/
  CURSOR c_group_member( b_group_member_id NUMBER ) IS
    SELECT rgm.resource_id
    ,      rxt.user_id
    FROM  jtf_rs_group_members  rgm
    ,     jtf_rs_resource_extns rxt
    WHERE rgm.resource_id = rxt.resource_id
    AND   rgm.group_member_id = b_group_member_id;
  r_group_member c_group_member%ROWTYPE;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
      ( p_group_member_id
      , g_table_name
      , 'Entering Insert_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
  THEN
    jtm_message_log_pkg.LOG_MSG
      ( p_group_member_id
      , g_table_name
      , 'Inserting ACC record for resource id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Insert the related resource id in Acc table **/
  JTM_HOOK_UTIL_PKG.Insert_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    , P_ACC_TABLE_NAME          => g_acc_table_name
    , P_PK1_NAME                => g_pk1_name
    , P_PK1_NUM_VALUE           => p_group_member_id
    , P_RESOURCE_ID             => p_resource_id
    );

  /*** retrieve group member resource_id and user_id ***/
  OPEN  c_group_member ( p_group_member_id );
  FETCH c_group_member INTO r_group_member;
  IF c_group_member%FOUND
  THEN
    /** Delete the resource extns ACC record **/
    CSL_JTF_RESOURCE_EXTNS_ACC_PKG.Insert_Resource_Extns
     ( r_group_member.resource_id
     , p_resource_id
      );

    /*** Delete the fnd_user record ***/
    CSL_FND_USER_ACC_PKG.Insert_User
      ( r_group_member.user_id
      , p_resource_id
      );
  END IF;
  CLOSE c_group_member;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
      ( p_group_member_id
      , g_table_name
      , 'Leaving Insert_ACC_Record'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     );
  END IF;
END Insert_ACC_Record;

/*** Private procedure that deletes group member from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_group_member_id  IN NUMBER
   ,p_resource_id      IN NUMBER
  )
IS
  /*** cursor to retrieve group member details ***/
  CURSOR c_group_member( b_group_member_id NUMBER ) IS
    SELECT rgm.resource_id
    ,      rxt.user_id
    FROM  jtf_rs_group_members  rgm
    ,     jtf_rs_resource_extns rxt
    WHERE rgm.resource_id = rxt.resource_id
    AND   rgm.group_member_id = b_group_member_id;
  r_group_member c_group_member%ROWTYPE;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( p_group_member_id
      , g_table_name
      ,'Entering Delete_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     );
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( p_group_member_id
      , g_table_name
      , 'Deleting ACC record for p_resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
  END IF;

  /*** Delete group member ACC record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    , P_ACC_TABLE_NAME         => g_acc_table_name
    , P_PK1_NAME               => g_pk1_name
    , P_PK1_NUM_VALUE          => p_group_member_id
    , P_RESOURCE_ID            => p_resource_id
    );

  /*** retrieve group member resource_id and user_id ***/
  OPEN  c_group_member ( p_group_member_id );
  FETCH c_group_member INTO r_group_member;
  IF c_group_member%FOUND
  THEN
    /** Delete the resource extns ACC record **/
    CSL_JTF_RESOURCE_EXTNS_ACC_PKG.Delete_Resource_Extns
     ( r_group_member.resource_id
     , p_resource_id
      );

    /*** Delete the fnd_user record ***/
    CSL_FND_USER_ACC_PKG.Delete_User
      ( r_group_member.user_id
      , p_resource_id
      );
  END IF;
  CLOSE c_group_member;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( p_group_member_id
      , g_table_name
      , 'Leaving Delete_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      );
  END IF;
END Delete_ACC_Record;

/*** Called after Group member Insert ***/
PROCEDURE  POST_INSERT_RS_GROUP_MEMBER
  (P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  )
IS
  CURSOR c_group_resources ( b_group_id NUMBER ) IS
   SELECT group_member_id, resource_id
   FROM   jtf_rs_group_members
   WHERE  group_id = b_group_id
   AND    delete_flag = 'N';
  r_group_resources c_group_resources%ROWTYPE;

  l_is_mobile_resource BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
     ( p_group_member_id
     , g_table_name
     , 'Entering POST_INSERT_RS_GROUP_MEMBER hook'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** check if record needs to be replicated ***/
  IF Replicate_Record( p_group_member_id ) THEN
    /*** yes -> replicate record to mobile resources within group ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    THEN
      jtm_message_log_pkg.Log_Msg
       ( p_group_member_id
       , g_table_name
       , 'Record needs to be replicated'
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** check if new member record is mobile resource ***/
    IF JTM_HOOK_UTIL_PKG.isMobileFSresource( p_resource_id ) THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      THEN
        jtm_message_log_pkg.Log_Msg
         ( p_group_member_id
         , g_table_name
         , 'New group member is mobile resource'
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      l_is_mobile_resource := TRUE;
    ELSE

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      THEN
        jtm_message_log_pkg.Log_Msg
         ( p_group_member_id
         , g_table_name
         , 'New group member is not a mobile resource'
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      l_is_mobile_resource := FALSE;
    END IF;

    /***
       Loop through all group members.
       Replicate new record to all mobile resources in resource group.
       If new group member is a mobile resource, then also replicate all
       existing group member records to the mobile resource.
    ***/
    FOR r_group_resources IN c_group_resources( p_group_id )
    LOOP
      /*** is group member a mobile resource? ***/
      IF JTM_HOOK_UTIL_PKG.isMobileFSresource( r_group_resources.resource_id )
      THEN
        /*** yes -> replicate new record to mobile resource ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        THEN
          jtm_message_log_pkg.Log_Msg
           ( p_group_member_id
           , g_table_name
           , 'Replicating new member record to mobile resource_id = ' || r_group_resources.resource_id
           , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        Insert_ACC_Record
        ( p_group_member_id
         ,r_group_resources.resource_id
        );
      END IF;

      /*** is new group member record mobile resource? ***/
      IF l_is_mobile_resource THEN
        /***
           yes -> is current record the new record?
           We only replicate existing record to the new resource;
           the new record will be replicated to the new resource
           by the previous Insert_ACC_Record call (we don't need it twice).
        ***/
        IF r_group_resources.group_member_id <> p_group_member_id THEN
          /*** no -> replicate existing member to new mobile group member ***/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
          THEN
            jtm_message_log_pkg.Log_Msg
             ( p_group_member_id
             , g_table_name
             , 'Replicating existing member record to new mobile resource group member. ' ||
               fnd_global.local_chr(10) || 'group_member_id = ' || r_group_resources.group_member_id
             , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
          END IF;

          Insert_ACC_Record
          ( r_group_resources.group_member_id
           ,p_resource_id
          );
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
     ( p_group_member_id
     , g_table_name
     , 'Leaving POST_INSERT_RS_GROUP_MEMBER hook'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( p_group_member_id
      , g_table_name
      , 'Caught exception in POST_INSERT Procedure:' || fnd_global.local_chr(10) || sqlerrm
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

END POST_INSERT_RS_GROUP_MEMBER;

/* Called after Group member delete */
PROCEDURE PRE_DELETE_RS_GROUP_MEMBER
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  )
IS
  CURSOR c_group_resources ( b_group_id NUMBER ) IS
   SELECT group_member_id, resource_id
   FROM   jtf_rs_group_members
   WHERE  group_id = b_group_id
   AND    delete_flag = 'N';
  r_group_resources c_group_resources%ROWTYPE;

  CURSOR c_group_member ( b_group_id NUMBER, b_resource_id NUMBER ) IS
   SELECT group_member_id
   FROM   jtf_rs_group_members
   WHERE  group_id = b_group_id
   AND    resource_id = b_resource_id
   AND    delete_flag = 'N';
  l_group_member_id jtf_rs_group_members.group_member_id%TYPE;

  l_is_mobile_resource BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
     ( null
     , g_table_name
     , 'Entering PRE_DELETE_RS_GROUP_MEMBER hook'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** retrieve group_member_id for deleted member ***/
  OPEN c_group_member( p_group_id, p_resource_id );
  FETCH c_group_member INTO l_group_member_id;
  IF c_group_member%NOTFOUND THEN
    /*** could not find group member -> log error and exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
    THEN
      jtm_message_log_pkg.Log_Msg
       ( null
       , g_table_name
       , 'Could not find group member for group_id = ' || p_group_id || ', resource_id = ' || p_resource_id
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
    CLOSE c_group_member;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  CLOSE c_group_member;

  /*** is deleted group member a mobile resource? ***/
  IF JTM_HOOK_UTIL_PKG.isMobileFSresource( p_resource_id ) THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    THEN
      jtm_message_log_pkg.Log_Msg
       ( l_group_member_id
       , g_table_name
       , 'Deleted group member is mobile resource'
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    l_is_mobile_resource := TRUE;
  ELSE
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    THEN
      jtm_message_log_pkg.Log_Msg
       ( l_group_member_id
       , g_table_name
       , 'Deleted group member is not a mobile resource'
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    l_is_mobile_resource := FALSE;
  END IF;

  /*** loop through group resources ***/
  FOR r_group_resources IN c_group_resources ( p_group_id ) LOOP

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    THEN
      jtm_message_log_pkg.Log_Msg
       ( l_group_member_id
       , g_table_name
       , 'Processing group_member_id = ' || r_group_resources.group_member_id
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** is group member a mobile resource? ***/
    IF JTM_HOOK_UTIL_PKG.isMobileFSresource( r_group_resources.resource_id )
    THEN
      /*** yes -> delete deleted member for mobile user ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      THEN
        jtm_message_log_pkg.Log_Msg
         ( l_group_member_id
         , g_table_name
         , 'Deleting deleted member record for mobile resource_id = ' || r_group_resources.resource_id
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      Delete_ACC_Record
      ( l_group_member_id
       ,r_group_resources.resource_id
      );
    END IF;

    /*** Is deleted group member a mobile resource? ***/
    IF l_is_mobile_resource THEN
      /*** Yes -> has this record already been deleted above? ***/
      IF l_group_member_id <> r_group_resources.group_member_id THEN
        /*** No -> delete existing group member for deleted mobile resource ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        THEN
          jtm_message_log_pkg.Log_Msg
           ( l_group_member_id
           , g_table_name
           , 'Deleting existing member record for deleted mobile group member'
           , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        Delete_ACC_Record
        ( r_group_resources.group_member_id
         ,p_resource_id
        );
      END IF;
    END IF;
  END LOOP;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
  THEN
    jtm_message_log_pkg.Log_Msg
     ( l_group_member_id
     , g_table_name
     , 'Deleted group_member_id = ' || l_group_member_id
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  THEN
    jtm_message_log_pkg.Log_Msg
     ( l_group_member_id
     , g_table_name
     , 'Leaving PRE_DELETE_RS_GROUP_MEMBER hook'
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( l_group_member_id
      , g_table_name
      , 'Caught exception in PRE_DELETE Procedure:' || fnd_global.local_chr(10) || sqlerrm
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

END PRE_DELETE_RS_GROUP_MEMBER;

/* Remove all ACC records of a mobile user */
PROCEDURE Delete_All_ACC_Records
  ( p_resource_id in NUMBER
  , x_return_status OUT NOCOPY varchar2
  )
IS

  CURSOR c_grp_mem_acc( b_resource_id NUMBER)
  IS
   SELECT acc.group_member_id
   FROM  jtm_jtf_rs_group_members_acc acc
   WHERE acc.resource_id = b_resource_id;
  r_grp_mem_acc c_grp_mem_acc%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( null
    , g_table_name
    , 'Entering Delete_All_ACC_Records'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** check if resource is fs laptop resource ***/
  IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( p_resource_id ) THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Resource is not a mobile field service/laptop resource'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
--    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    FOR r_grp_mem_acc IN c_grp_mem_acc( p_resource_id )
    LOOP
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( r_grp_mem_acc.group_member_id
        , g_table_name
        , 'Calling Delete_ACC_Record'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      Delete_ACC_Record
      ( r_grp_mem_acc.group_member_id
       ,p_resource_id
      );
    END LOOP;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_table_name
      , v_message     => 'Leaving Delete_All_ACC_Records'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Caught exception in Delete_All_ACC_Records:' || fnd_global.local_chr(10) || sqlerrm
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_RS_GRP_MEM_ACC_PKG','Delete_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Delete_All_ACC_Records;

/* Full synch for a mobile user */
PROCEDURE Insert_All_ACC_Records
  ( p_resource_id IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  )
IS
  CURSOR c_jtf_rs_group_members (b_resource_id NUMBER) IS
   SELECT group_member_id
   FROM JTF_RS_GROUP_MEMBERS
   WHERE delete_flag = 'N'
   AND group_id IN (
     SELECT group_id
     FROM   jtf_rs_group_members
     WHERE  delete_flag = 'N'
     AND    RESOURCE_ID = b_resource_id);
  r_jtf_rs_group_members c_jtf_rs_group_members%ROWTYPE;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( null
    , g_table_name
    , 'Entering Insert_All_ACC_Records'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** check if resource is fs laptop resource ***/
  IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( p_resource_id ) THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Resource is not a mobile field service/laptop resource'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
--    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    /*** Yes -> insert all replicateable records ***/
    FOR r_jtf_rs_group_members IN c_jtf_rs_group_members( p_resource_id )
    LOOP
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( r_jtf_rs_group_members.group_member_id
        , g_table_name
        , 'Calling Insert_ACC_Record'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      Insert_ACC_Record
      ( r_jtf_rs_group_members.group_member_id
      , p_resource_id
      );
    END LOOP;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_resource_id
      , v_object_name => g_table_name
      , v_message     => 'Leaving Insert_All_ACC_Records procedure for user: ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Caught exception in Delete_All_ACC_Records:' || fnd_global.local_chr(10) || sqlerrm
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_RS_GRP_MEM_ACC_PKG','Insert_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Insert_All_ACC_Records;

END CSL_JTF_RS_GRP_MEM_ACC_PKG;

/
