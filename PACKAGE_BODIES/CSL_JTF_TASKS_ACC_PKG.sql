--------------------------------------------------------
--  DDL for Package Body CSL_JTF_TASKS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_JTF_TASKS_ACC_PKG" AS
/* $Header: csltkacb.pls 120.0 2005/05/24 17:32:14 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_JTF_TASKS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_JTF_TASKS_VL');
g_table_name            CONSTANT VARCHAR2(30) := 'JTF_TASKS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TASK_ID';

g_debug_level           NUMBER;  -- debug level
g_replicate_pre_update  BOOLEAN; -- true when task was replicated before the update

g_cached_task_address_id   NUMBER;

/*** Function that checks if task record should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_task_id     NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_task (b_task_id NUMBER) IS
   SELECT *
   FROM JTF_TASKS_B
   WHERE task_id = b_task_id;
  r_task c_task%ROWTYPE;

  CURSOR c_task_status (b_task_status_id NUMBER) IS
   SELECT null
   FROM   JTF_TASK_STATUSES_B
   WHERE  TASK_STATUS_ID = b_task_status_id
   AND (
     NVL(ASSIGNED_FLAG,  'N') = 'Y'
     OR     NVL(CANCELLED_FLAG, 'N') = 'Y'
     OR     NVL(COMPLETED_FLAG, 'N') = 'Y'
     OR     NVL(CLOSED_FLAG,    'N') = 'Y'
   );
  r_task_status c_task_status%ROWTYPE;

  CURSOR c_task_type ( b_task_type_id NUMBER ) IS
   SELECT null
   FROM   jtf_task_types_b
   WHERE  task_type_id = b_task_type_id
   AND    rule = 'DISPATCH';
  r_task_type c_task_type%ROWTYPE;

  CURSOR c_private_task_type( b_task_type_id NUMBER ) IS
    SELECT null
    FROM   jtf_task_types_b
    WHERE  task_type_id = b_task_type_id
    AND    private_flag = 'Y';
  r_private_task_type c_private_task_type%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_task( p_task_id );
  FETCH c_task INTO r_task;
  IF c_task%NOTFOUND THEN
    /*** could not find task record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_task_id
      , g_table_name
      , 'Replicate_Record error: Could not find task_id ' || p_task_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_task;
    RETURN FALSE;
  END IF;
  CLOSE c_task;

  /*** is this a SR or personal (trip) task? ***/
  IF r_task.source_object_type_code NOT IN ('TASK', 'SR') THEN
    /*** no -> don't replicate ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_task_id
      , g_table_name
      , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
        'SOURCE_OBJECT_TYPE CODE NOT IN (''SR'',''TASK'')'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    RETURN FALSE;
  END IF;

  /*** check if scheduled start and end dates are not null ***/
  IF r_task.scheduled_start_date IS NULL OR
   r_task.scheduled_end_date IS NULL THEN
    /*** no -> don't replicate ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_task_id
      , g_table_name
      , 'Replicate_Record returned FALSE ' || fnd_global.local_chr(10) ||
        'SCHEDULED_START_DATE and SCHEDULED_END_DATE should both be NOT NULL.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    RETURN FALSE;
  END IF;


  /*** is this a SR task? ***/
  IF r_task.source_object_type_code = 'SR' THEN
    /*** yes -> check if task type rule = DISPATCH ***/
    OPEN c_task_type ( r_task.task_type_id );
    FETCH c_task_type INTO r_task_type;
    IF c_task_type%NOTFOUND THEN
      /*** no -> don't replicate ***/
      CLOSE c_task_type;
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_id
        , g_table_name
        , 'Replicate_Record returned FALSE ' || fnd_global.local_chr(10) ||
          'Task''s task type RULE <> ''DISPATCH''.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      RETURN FALSE;
    END IF;
    CLOSE c_task_type;

    /*** check task status ***/
    OPEN c_task_status ( r_task.task_status_id );
    FETCH c_task_status INTO r_task_status;
    IF c_task_status%NOTFOUND THEN
      /*** no -> don't replicate ***/
      CLOSE c_task_status;
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_id
        , g_table_name
        , 'Replicate_Record returned FALSE ' || fnd_global.local_chr(10) ||
          'Task status for SR tasks should have either ASSIGNED_FLAG, CANCELLED_FLAG, '||
	  'COMPLETED_FLAG or CLOSED_FLAG set to ''Y''.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      RETURN FALSE;
    END IF;
    CLOSE c_task_status;
  END IF;

  /*Is task personal task ?*/
  IF r_task.source_object_type_code = 'TASK' THEN
    /*** yes -> check if task type rule = DISPATCH ***/
    OPEN c_private_task_type ( r_task.task_type_id );
    FETCH c_private_task_type INTO r_private_task_type;
    IF c_private_task_type%NOTFOUND THEN
      /*** no -> don't replicate ***/
      CLOSE c_private_task_type;
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_id
        , g_table_name
        , 'Replicate_Record returned FALSE ' || fnd_global.local_chr(10) ||
          'Task''s task type private flag <> ''Y''.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      RETURN FALSE;
    END IF;
    CLOSE c_private_task_type;
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;


/*Function to get the parent*/
FUNCTION  GetParentId( p_task_id IN Number )
RETURN NUMBER
IS
 CURSOR c_parent( b_task_id NUMBER ) IS
   SELECT source_object_id
   FROM   jtf_tasks_b
   WHERE  source_object_type_code = 'SR'
   AND    task_id = b_task_id;
  r_parent c_parent%ROWTYPE;
BEGIN
  OPEN c_parent( p_task_id );
  FETCH c_parent INTO r_parent;
  IF c_parent%NOTFOUND THEN
    CLOSE c_parent;
    RETURN -1;
  END IF;
  CLOSE c_parent;
  RETURN r_parent.source_object_id;
END GetParentId;

/*** Private procedure that replicates given task related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_task_id     IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER ) --DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
IS
  l_return BOOLEAN;

  CURSOR c_task( b_task_id NUMBER ) IS
    SELECT *
    FROM JTF_TASKS_B
    WHERE TASK_ID = b_task_id;

  r_task c_task%ROWTYPE;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Inserting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Insert task ACC record ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_task_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  /*Insert the non critical dependant record*/
 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Inserting non-critical dependant records'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*Do not replicate notes for history tasks*/
  IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
   --NOTES
   l_return := CSL_JTF_NOTES_ACC_PKG.PRE_INSERT_CHILDREN
                                     ( P_SOURCE_OBJ_ID   => p_task_id
 				     , P_SOURCE_OBJ_CODE => 'TASK'
				     , P_RESOURCE_ID     => p_resource_id );
  END IF;

  OPEN c_task( b_task_id => p_task_id );
  FETCH c_task INTO r_task;
  IF c_task%FOUND THEN
    --PARTY_SITE
    --fix for bug 2472668: check if address_id is null
    IF r_task.address_id IS NOT NULL THEN
      CSL_HZ_PARTY_SITES_ACC_PKG.INSERT_PARTY_SITE( p_party_site_id => r_task.address_id
                                                  , p_resource_id => p_resource_id );
    END IF;


    --Bug 3724142
    --ATTACHMENTS
   CSL_LOBS_ACC_PKG.DOWNLOAD_TASK_ATTACHMENTS(p_task_id);

  END IF;
  CLOSE c_task;


  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_ACC_Record;

/*** Private procedure that re-sends given task to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_task_id            IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_acc_id             IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Updating ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10) ||
      'access_id = ' || p_acc_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  JTM_HOOK_UTIL_PKG.Update_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_RESOURCE_ID            => p_resource_id
    ,P_ACCESS_ID              => p_acc_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes task for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_task_id     IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER
  )
IS
  CURSOR c_task( b_task_id NUMBER ) IS
    SELECT *
    FROM JTF_TASKS_B
    WHERE TASK_ID = b_task_id;

  r_task c_task%ROWTYPE;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Delete task ACC record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_task_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Deleting Non-critical dependant records'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*Notes are not replicated for history so we do not need to delete them*/
  IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
    --NOTES
    CSL_JTF_NOTES_ACC_PKG.POST_DELETE_CHILDREN( P_SOURCE_OBJ_ID   => p_task_id
                                              , P_SOURCE_OBJ_CODE => 'TASK'
  					      , P_RESOURCE_ID     => p_resource_id );
  END IF;
  --PARTY_SITE
  OPEN c_task( b_task_id => p_task_id );
  FETCH c_task INTO r_task;
  IF c_task%FOUND THEN
    --fix for bug 2472668: check if address_id is null
    IF r_task.address_id IS NOT NULL THEN
      CSL_HZ_PARTY_SITES_ACC_PKG.DELETE_PARTY_SITE( p_party_site_id => r_task.ADDRESS_ID
                                                  , p_resource_id   => p_resource_id );
    END IF;

    --Bug 3724142
    --ATTACHMENTS
    /*CSL_LOBS_ACC_PKG.DELETE_ATTACHMENTS ( p_entity_name => 'JTF_TASKS_B',
                              p_primary_key => p_task_id,
                              p_resource_id => p_resource_id);*/

  END IF;
  CLOSE c_task;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/***
  Public function that gets called when a task needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/
FUNCTION Pre_Insert_Child
  ( p_task_id     IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER ) --DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
RETURN BOOLEAN
IS
  l_acc_id  NUMBER;
  l_success BOOLEAN;
  l_incident_id NUMBER;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Entering Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_success := FALSE;

  /*** is this a history record? ***/
  IF p_flow_type = CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
    /*** yes -> replicate without further checking ***/
    l_success := TRUE;
  ELSE
    /*** SR task? ***/
    IF Replicate_Record( p_task_id ) THEN
      /*** yes -> is this an SR task? ***/
      l_incident_id := GetParentId( p_task_id);
      IF l_incident_id = -1 THEN
        /*** no -> replicate personal task ***/
        l_success := TRUE;
      ELSE
        /*** yes -> insert parent SR ***/
        IF CSL_CS_INCIDENTS_ALL_ACC_PKG.Pre_Insert_Child( l_incident_id, p_resource_id, p_flow_type) THEN
          /*** yes -> replicate task ***/
          l_success := TRUE;
        END IF;
      END IF;
    END IF;
  END IF;

  IF l_success THEN
    /*** successful -> insert task acc record ***/
    Insert_ACC_Record
    ( p_task_id
    , p_resource_id
    , p_flow_type
    );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Leaving Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_success;
END Pre_Insert_Child;

/***
  Public procedure that gets called when a task needs to be deleted from ACC table.
***/
PROCEDURE Post_Delete_Child
  ( p_task_id     IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER )--DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
IS
  l_incident_id NUMBER;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Entering Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** delete task record from ACC ***/
  Delete_ACC_Record
  ( p_task_id
  , p_resource_id
  , p_flow_type);

  /*** call delete service request ***/
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Calling CSL_CS_INCIDENTS_ALL_ACC_PKG.Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*Do not delete sr when history, flow is sr -> task -> assignment */
  IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
    /* delete the dependant SR */
    l_incident_id := GetParentId( p_task_id);
    IF l_incident_id <> -1 THEN
      CSL_CS_INCIDENTS_ALL_ACC_PKG.Post_Delete_Child( l_incident_id, p_resource_id );
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_id
    , g_table_name
    , 'Leaving Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Post_Delete_Child;


/* Called before task Insert */
PROCEDURE PRE_INSERT_TASK
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_TASK;

/* Called after task Insert */
PROCEDURE POST_INSERT_TASK
  ( x_return_status OUT NOCOPY varchar2
  )
IS
 l_task_id NUMBER;
 CURSOR c_task( b_task_id NUMBER ) IS
  SELECT tk.SOURCE_OBJECT_TYPE_CODE
  ,      au.RESOURCE_ID
  FROM JTF_TASKS_B tk
  ,    ASG_USER au
  WHERE tk.TASK_ID = b_task_id
  AND   tk.CREATED_BY = au.USER_ID;
 r_task c_task%ROWTYPE;
 l_enabled_flag VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Entering POST_INSERT_TASK hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;
  OPEN c_task( l_task_id );
  FETCH c_task INTO r_task;
  IF c_task%FOUND THEN
   IF r_task.SOURCE_OBJECT_TYPE_CODE = 'SR' AND
      JTM_HOOK_UTIL_PKG.isMobileFSresource(r_task.RESOURCE_ID) = TRUE THEN
     Insert_ACC_Record
      ( l_task_id
      , r_task.RESOURCE_ID
      , CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
      );
   END IF;--Type = SR
  END IF;--c_task%FOUND
  CLOSE c_task;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Leaving POST_INSERT_TASK hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Caught exception in POST_INSERT_TASK hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_TASKS_ACC_PKG','POST_INSERT_TASK',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_TASK;

/* Called before task Update */
PROCEDURE PRE_UPDATE_TASK
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_task_id NUMBER;
  l_enabled_flag       VARCHAR2(30);
  CURSOR c_task_address( b_task_id NUMBER ) IS
   SELECT ADDRESS_ID
   FROM JTF_TASKS_B
   WHERE TASK_ID = b_task_id;
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL');
  IF l_enabled_flag <> 'Y' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
  END IF;
  /*** get task record details from public API ***/
  l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Entering PRE_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Check if task before update matched criteria ***/
  g_replicate_pre_update := Replicate_Record( l_task_id );
  /* Cache the address id ( might change ) */
  OPEN c_task_address( l_task_id );
  FETCH c_task_address INTO g_cached_task_address_id;
  CLOSE c_task_address;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Leaving PRE_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Caught exception in PRE_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_TASKS_ACC_PKG','POST_UPDATE_TASK',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_TASK;

/* Called after task Update */
PROCEDURE POST_UPDATE_TASK
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  CURSOR c_task_assignment( b_task_id NUMBER )
  IS
   SELECT task_assignment_id, resource_id
   FROM   jtf_task_assignments
   WHERE  task_id = b_task_id;
  r_task_assignment c_task_assignment%ROWTYPE;

  CURSOR c_task_address( b_task_id NUMBER ) IS
   SELECT ADDRESS_ID
   FROM JTF_TASKS_B
   WHERE TASK_ID = b_task_id;

  l_address_id NUMBER;
  l_address_changed BOOLEAN := FALSE;
  l_task_id   NUMBER;
  l_replicate BOOLEAN;
  l_dummy     BOOLEAN;

  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL');
  IF l_enabled_flag <> 'Y' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
  END IF;
  /*** get task record details from public API ***/
  l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Entering POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Check if task after update matches criteria ***/
  l_replicate := Replicate_Record( l_task_id );

  /*** replicate record after update? ***/
  IF l_replicate THEN
    /*** yes -> was record already replicated? ***/
    IF g_replicate_pre_update THEN
      /*** yes -> re-send updated task record to all resources ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_task_id
        , g_table_name
        , 'Task was replicateable before and after update. Re-sending task record to mobile users.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      /*** get list of resources to whom the record was replicated ***/
      JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
      ( P_ACC_TABLE_NAME  => g_acc_table_name
       ,P_PK1_NAME        => g_pk1_name
       ,P_PK1_NUM_VALUE   => l_task_id
       ,L_TAB_RESOURCE_ID => l_tab_resource_id
       ,L_TAB_ACCESS_ID   => l_tab_access_id
      );

      /*Check if address is changed if so also chage address in acc table*/
      OPEN c_task_address( l_task_id );
      FETCH c_task_address INTO l_address_id;
      IF c_task_address%FOUND THEN
        IF l_address_id <> g_cached_task_address_id AND l_address_id IS NOT NULL THEN
	 l_address_changed := TRUE;
	END IF;
      END IF;
      CLOSE c_task_address;
      /*** re-send rec to all resources ***/
      IF l_tab_resource_id.COUNT > 0 THEN
        FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
          Update_ACC_Record
          ( l_task_id
           ,l_tab_resource_id(i)
           ,l_tab_access_id(i)
          );
	  IF l_address_changed = TRUE THEN
	    /*Address changed check if there was an address*/
	    IF g_cached_task_address_id IS NOT NULL THEN
              CSL_HZ_PARTY_SITES_ACC_PKG.CHANGE_PARTY_SITE( g_cached_task_address_id
                                                          , l_address_id
   		                                          , l_tab_resource_id(i));
	    ELSE
  	      CSL_HZ_PARTY_SITES_ACC_PKG.INSERT_PARTY_SITE( l_address_id
   		                                          , l_tab_resource_id(i));
	    END IF;--g_cached not null
	  END IF;--addess changed
        END LOOP;
      END IF;
    ELSE
      /***
        record was not replicated before update but should be replicated now ->
        send record related data to all resources
      ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_task_id
        , g_table_name
        , 'Task was not replicated before update, but should be replicated now.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      FOR r_task_assignment IN c_task_assignment( l_task_id ) LOOP

        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( l_task_id
          , g_table_name
          , 'Evaluating task_assignment_id ' ||
	    r_task_assignment.task_assignment_id || fnd_global.local_chr(10) ||
            'for resource_id ' || r_task_assignment.resource_id
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        /*** insert task assignment data ***/
        l_dummy := CSL_JTF_TASK_ASS_ACC_PKG.Pre_Insert_Child
        ( r_task_assignment.task_assignment_id
         ,r_task_assignment.resource_id
         );
      END LOOP;
    END IF;
  ELSE
    /*** record should not be replicated anymore -> was it replicated before? ***/
    IF g_replicate_pre_update THEN
      /*** yes -> delete record related data for all resources ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_task_id
        , g_table_name
        , 'Task was replicated before update, but should no longer be replicated.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      FOR r_task_assignment IN c_task_assignment( l_task_id ) LOOP

        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( l_task_id
          , g_table_name
          , 'Evaluating task_assignment_id ' || r_task_assignment.task_assignment_id ||
	    fnd_global.local_chr(10) ||'for resource_id ' || r_task_assignment.resource_id
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        /*** delete task assignment data ***/
        CSL_JTF_TASK_ASS_ACC_PKG.Post_Delete_Child
          ( r_task_assignment.task_assignment_id
           ,r_task_assignment.resource_id
          );
      END LOOP;
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Leaving POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_id
    , g_table_name
    , 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_TASKS_ACC_PKG','POST_UPDATE_TASK',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_TASK;

/* Called before task Delete */
PROCEDURE PRE_DELETE_TASK
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_TASK;

/* Called after task Delete */
PROCEDURE POST_DELETE_TASK
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_TASK;

PROCEDURE INSERT_ALL_ACC_RECORDS
  ( p_resource_id   IN  NUMBER
  , x_return_status OUT NOCOPY VARCHAR2 ) IS

 CURSOR c_task( b_resource_id NUMBER ) IS
  SELECT tk.task_id
  FROM JTF_TASKS_B tk
  ,    ASG_USER au
  WHERE tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
  AND   tk.CREATED_BY = au.USER_ID
  AND   au.RESOURCE_ID = b_resource_id;
 r_task c_task%ROWTYPE;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** insert all tasks created by resource ***/
  FOR r_task IN c_task( p_resource_id ) LOOP
     Insert_ACC_Record
      ( r_task.task_id
      , p_resource_id
      , CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
      );
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Caught exception in INSERT_ALL_ACC_RECORDS:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END INSERT_ALL_ACC_RECORDS;

/***Purge logic for Expired/Closed Personal Task***/
--Bug 3475657
PROCEDURE PURGE_TASKS
IS

CURSOR lcur_purge_tasks IS
SELECT  acc.task_id, acc.resource_id
FROM    csl_jtf_tasks_acc acc,
        jtf_tasks_b jt,
        jtf_task_statuses_b jts
WHERE   acc.task_id = jt.task_id
AND     jts.task_status_id = jt.task_status_id
AND     (NVL(jt.scheduled_start_date, SYSDATE) < (SYSDATE - TO_NUMBER(FND_PROFILE.Value('CSL_APPL_HISTORY_IN_DAYS'))))
AND     (NVL(jts.cancelled_flag,'N') = 'Y'
        OR NVL(jts.closed_flag, 'N') = 'Y'
        OR NVL(jts.completed_flag, 'N') = 'Y'
        OR NVL(jts.rejected_flag, 'N') = 'Y')
AND     source_object_type_code = 'TASK';

rcur_purge_tasks lcur_purge_tasks%ROWTYPE;
BEGIN

     --Delete the Tasks which haven been created on the client and have either expired or been closed/completed.
     --FOR rcur_purge_tasks in lcur_purge_tasks(p_resource_id)
     FOR rcur_purge_tasks in lcur_purge_tasks
     LOOP
         Post_Delete_Child(rcur_purge_tasks.task_id, rcur_purge_tasks.resource_id);
     END LOOP;

EXCEPTION

    WHEN OTHERS THEN
        jtm_message_log_pkg.Log_Msg
            (rcur_purge_tasks.task_id,
            'CSL_JTF_TASK_ASS_ACC',
            'Exception occured in PURGE_TASKS for id: ' || rcur_purge_tasks.task_id,
            JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

END;

END CSL_JTF_TASKS_ACC_PKG;

/
