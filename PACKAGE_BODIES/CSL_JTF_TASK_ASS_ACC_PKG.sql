--------------------------------------------------------
--  DDL for Package Body CSL_JTF_TASK_ASS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_JTF_TASK_ASS_ACC_PKG" AS
/* $Header: csltaacb.pls 120.0 2005/05/24 18:02:19 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_JTF_TASK_ASS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_JTF_TASK_ASSIGNMENTS');
g_table_name            CONSTANT VARCHAR2(30) := 'JTF_TASK_ASSIGNMENTS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TASK_ASSIGNMENT_ID';
g_old_resource_id       NUMBER; -- variable containing old resource_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level

/*** Function that checks if assignment record should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_task_assignment_id IN NUMBER
  , p_flow_type          IN NUMBER --DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  )
RETURN BOOLEAN
IS
  -- Fix for Bug# 3466610. Added filter to get only those records whose
  -- Resource Type is Employee Resource.
  CURSOR c_task_assignment (b_task_assignment_id NUMBER) IS
   SELECT *
   FROM JTF_TASK_ASSIGNMENTS -- don't use synonym as that one filters on OWNER records
   WHERE task_assignment_id = b_task_assignment_id
   AND resource_type_code = 'RS_EMPLOYEE';

  r_task_assignment c_task_assignment%ROWTYPE;

  CURSOR c_assignment_status (b_assignment_status_id NUMBER) IS
   SELECT null
   FROM   JTF_TASK_STATUSES_B
   WHERE  TASK_STATUS_ID = b_assignment_status_id
   AND (
     NVL(ASSIGNED_FLAG,  'N') = 'Y'
     OR     NVL(CANCELLED_FLAG, 'N') = 'Y'
     OR     NVL(COMPLETED_FLAG, 'N') = 'Y'
     OR     NVL(CLOSED_FLAG,    'N') = 'Y'
   );
  r_assignment_status c_assignment_status%ROWTYPE;

  CURSOR c_personal_task( b_task_assignment_id NUMBER ) IS
   SELECT tk.TASK_ID
   FROM JTF_TASK_ASSIGNMENTS ta
   ,    JTF_TASKS_B tk
   WHERE   tk.TASK_ID = ta.TASK_ID
   AND   tk.SOURCE_OBJECT_TYPE_CODE = 'TASK'
   AND   ta.TASK_ASSIGNMENT_ID = b_task_assignment_id;

  r_personal_task c_personal_task%ROWTYPE;


BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_task_assignment( p_task_assignment_id );
  FETCH c_task_assignment INTO r_task_assignment;
  IF c_task_assignment%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_task_assignment_id
      , g_table_name
      , 'Replicate_Record error: Could not find task_assignment_id ' || p_task_assignment_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    CLOSE c_task_assignment;
    RETURN FALSE;
  END IF;
  CLOSE c_task_assignment;

  /*** is this an ASSIGNEE task assignment? ***/
  IF NVL(r_task_assignment.assignee_role,'') <> 'ASSIGNEE' THEN
    /*** No -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_task_assignment_id
      , g_table_name
      , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
        'ASSIGNEE_ROLE <> ''ASSIGNEE'''
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    RETURN FALSE;
  END IF;

  IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
    /*** is resource a mobile user? ***/
    IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( r_task_assignment.resource_id ) THEN
      /*** No -> exit ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_assignment_id
        , g_table_name
        , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
          'Resource_id ' || r_task_assignment.resource_id || ' is not a mobile user.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      RETURN FALSE;
    END IF;
  END IF;

  OPEN c_personal_task( p_task_assignment_id);
  FETCH c_personal_task INTO r_personal_task;
  IF c_personal_task%NOTFOUND THEN
    /*** not a personal task created by this user so check assignment status ***/
    OPEN c_assignment_status( r_task_assignment.assignment_status_id );
    FETCH c_assignment_status INTO r_assignment_status;
    IF c_assignment_status%NOTFOUND THEN
      /*** status should not be replicated -> exit ***/
      CLOSE c_assignment_status;
      CLOSE c_personal_task;
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_assignment_id
        , g_table_name
        , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
          'Assignment status should have either ASSIGNED_FLAG, CANCELLED_FLAG, '||
	  'COMPLETED_FLAG or CLOSED_FLAG set to ''Y''.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      RETURN FALSE;
    END IF;--c_assignment_status%NOTFOUND
    CLOSE c_assignment_status;
  END IF; --c_personal_task%NOTFOUND
  CLOSE c_personal_task;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;

/*** Private procedure that replicates given assignment related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_task_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
IS
   --Bug 3724142
   CURSOR c_debrief_header ( b_task_assignment_id NUMBER)
   IS  SELECT debrief_header_id FROM csf_debrief_headers
      WHERE task_assignment_id = b_task_assignment_id;

   l_debrief_header_id NUMBER;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Inserting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
   ,P_ACC_TABLE_NAME         => g_acc_table_name
   ,P_PK1_NAME               => g_pk1_name
   ,P_PK1_NUM_VALUE          => p_task_assignment_id
   ,P_RESOURCE_ID            => p_resource_id
  );

  /* insert debrief */
  CSL_CSF_DEBRIEF_LINE_ACC_PKG.Pre_Insert_Children
  ( p_task_assignment_id
   ,p_resource_id
  );

  --Bug 3724142
  OPEN c_debrief_header (p_task_assignment_id);
  FETCH c_debrief_header INTO l_debrief_header_id;
  CLOSE c_debrief_header;

  /* insert attachment - signature record */
  --Bug 3724142 - changed p_task_assignment_id to l_debrief_header_id
  CSL_LOBS_ACC_PKG.insert_acc_record
  ( l_debrief_header_id
   ,p_resource_id
  );


  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_ACC_Record;

/*** Private procedure that re-sends given assignment to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_task_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_acc_id             IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Updating ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10) || 'access_id = ' || p_acc_id
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
    ( p_task_assignment_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes assignment for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_task_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*  Delete Attachments - Signature */
  CSL_LOBS_ACC_PKG.delete_acc_record
  ( p_task_assignment_id
   ,p_resource_id
  );


  /* delete debrief header, lines */
  CSL_CSF_DEBRIEF_LINE_ACC_PKG.Post_Delete_Children
  ( p_task_assignment_id,
    p_resource_id
  );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Delete task assignment ACC record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_task_assignment_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/*** function that returns parent TASK_ID for given TASK_ASSIGNMENT_ID ***/
FUNCTION GetParentId( p_task_assignment_id NUMBER)
RETURN NUMBER
IS
  CURSOR c_task_assignment( b_task_assignment_id NUMBER )
  IS
   SELECT task_id
   FROM   jtf_task_assignments -- don't use synonym as that one filters on OWNER records
   WHERE  task_assignment_id = b_task_assignment_id;
  r_task_assignment c_task_assignment%ROWTYPE;
BEGIN
  OPEN c_task_assignment( p_task_assignment_id );
  FETCH c_task_assignment INTO r_task_assignment;
  IF c_task_assignment%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      CLOSE c_task_assignment;
      jtm_message_log_pkg.Log_Msg
      ( p_task_assignment_id
      , g_table_name
      , 'Post_Delete_Child error: Could not find task_assignment_id ' || p_task_assignment_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
--      RAISE_APPLICATION_ERROR(-20000, 'Post_Delete_Child error: Could not find task_assignment_id ' || p_task_assignment_id);
      RETURN -1;
    END IF;
  END IF;
  CLOSE c_task_assignment;
  /*** found assignment -> return task_id ***/
  RETURN r_task_assignment.task_id;
END GetParentId;

/***
  Public function that gets called when an assignment needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/
FUNCTION Pre_Insert_Child
  ( p_task_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_flow_type          IN NUMBER --DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  )
RETURN BOOLEAN
IS
  l_success BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Entering Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_success := FALSE;
  /*** no -> does record match criteria? ***/
  IF Replicate_Record( p_task_assignment_id, p_flow_type ) THEN

    IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
      /*** yes -> is insert task acc record successful? ***/
      IF CSL_JTF_TASKS_ACC_PKG.Pre_Insert_Child( GetParentId( p_task_assignment_id), p_resource_id) THEN
        /*** yes -> insert assignment acc record ***/
        Insert_ACC_Record
        ( p_task_assignment_id
         ,p_resource_id
        );
        l_success := TRUE;
      END IF;
    ELSE
      Insert_ACC_Record
      ( p_task_assignment_id
       ,p_resource_id
      );
      l_success := TRUE;
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Leaving Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_success;
END Pre_Insert_Child;

/***
  Public procedure that gets called when an assignment needs to be deleted from ACC table.
***/
PROCEDURE Post_Delete_Child
  ( p_task_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_flow_type          IN NUMBER --DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  )
IS
  l_acc_id NUMBER;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Entering Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** does record exist in ACC table? ***/
  l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
                 ( P_ACC_TABLE_NAME => g_acc_table_name
                  ,P_PK1_NAME       => g_pk1_name
                  ,P_PK1_NUM_VALUE  => p_task_assignment_id
                  ,P_RESOURCE_ID    => p_resource_id);

  IF l_acc_id > -1 THEN
    /*** yes -> delete assignment record from ACC ***/
    Delete_ACC_Record
    ( p_task_assignment_id
     ,p_resource_id);

    /*** call delete task ***/
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_task_assignment_id
      , g_table_name
      , 'Calling CSL_JTF_TASKS_ACC_PKG.Post_Delete_Child'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    /*If history flow is SR -> task -> assignment, so no need to call tasks again*/
    IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
      CSL_JTF_TASKS_ACC_PKG.Post_Delete_Child( GetParentId( p_task_assignment_id), p_resource_id );
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Leaving Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Post_Delete_Child;


/* Called during user creation */
PROCEDURE INSERT_ALL_ACC_RECORDS( p_resource_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2 ) IS
 CURSOR c_task_assignment( b_resource_id NUMBER ) IS
  SELECT TASK_ASSIGNMENT_ID
  FROM   JTF_TASK_ASSIGNMENTS
  WHERE  ASSIGNEE_ROLE = 'ASSIGNEE'
  AND    RESOURCE_ID = b_resource_id;
 l_return_status BOOLEAN;
BEGIN
FOR r_task_assignment IN c_task_assignment( p_resource_id ) LOOP
 l_return_status := Pre_Insert_Child
  ( r_task_assignment.task_assignment_id
   ,p_resource_id);
 END LOOP;
 x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS THEN
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END INSERT_ALL_ACC_RECORDS;

/* Called during deletion of a user */
PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2 ) IS
 CURSOR c_task_assignment( b_resource_id NUMBER ) IS
  SELECT TASK_ASSIGNMENT_ID
  FROM   JTF_TASK_ASSIGNMENTS
  WHERE  ASSIGNEE_ROLE = 'ASSIGNEE'
  AND    RESOURCE_ID = b_resource_id;
BEGIN
FOR r_task_assignment IN c_task_assignment( p_resource_id ) LOOP
 Post_Delete_Child
  ( r_task_assignment.task_assignment_id
   ,p_resource_id);
 END LOOP;
 x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS THEN
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END DELETE_ALL_ACC_RECORDS;


/*** Called before assignment Insert ***/
PROCEDURE PRE_INSERT_TASK_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_TASK_ASSIGNMENT;

/*** Called after assignment Insert ***/
PROCEDURE POST_INSERT_TASK_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_resource_id        NUMBER;
  l_task_assignment_id NUMBER;
  l_dummy              BOOLEAN;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP(P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  /*** get assignment record details from public API ***/
  l_task_assignment_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;
  l_resource_id        := jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Insert record if applicable ***/
  l_dummy := Pre_Insert_Child
    (  l_task_assignment_id
      ,l_resource_id
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Leaving POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  RETURN;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Caught exception in POST_INSERT hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_TASK_ASS_ACC_PKG','POST_INSERT_TASK_ASSIGNMENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_TASK_ASSIGNMENT;

/* Called before assignment Update */
PROCEDURE PRE_UPDATE_TASK_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  CURSOR c_task_assignment( b_task_assignment_id NUMBER ) IS
   SELECT resource_id
   FROM   jtf_task_assignments -- don't use synonym as that one filters on OWNER records
   WHERE  task_assignment_id = b_task_assignment_id;

  r_task_assignment c_task_assignment%ROWTYPE;
  l_task_assignment_id NUMBER;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP(P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  /*** get assignment record details from public API ***/
  l_task_assignment_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Entering PRE_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** retrieve old resource_id for task assignment ***/
  OPEN c_task_assignment(l_task_assignment_id);
  FETCH c_task_assignment INTO r_task_assignment;
  g_old_resource_id := r_task_assignment.resource_id;
  CLOSE c_task_assignment;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Leaving PRE_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Caught exception in PRE_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_TASK_ASS_ACC_PKG','PRE_UPDATE_TASK_ASSIGNMENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_TASK_ASSIGNMENT;

/* Called after assignment Update */
PROCEDURE POST_UPDATE_TASK_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_resource_id        NUMBER;
  l_task_assignment_id NUMBER;
  l_acc_id             NUMBER;
  l_replicate          BOOLEAN;
  l_dummy              BOOLEAN;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP(P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  /*** get assignment record details from public API ***/
  l_task_assignment_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;
  l_resource_id        := jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Entering POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** did resource_id get changed? ***/
  IF (g_old_resource_id <> l_resource_id) THEN
    /*** yes -> do cascading delete for old resource_id ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( l_task_assignment_id
      , g_table_name
      , 'Task assignment resource_id changed from ' || g_old_resource_id || ' to ' || l_resource_id || '.' || fnd_global.local_chr(10) ||
        'Deleting old assignment ACC record (if exists).'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    Post_Delete_Child
    ( l_task_assignment_id
     ,g_old_resource_id);

    /*** record doesn't exist for new resource_id yet ***/
    l_acc_id := -1;
  ELSE
    /*** resource_id is same as before the update -> check if it already exists on mobile ***/
    l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
                   ( P_ACC_TABLE_NAME => g_acc_table_name
                    ,P_PK1_NAME       => g_pk1_name
                    ,P_PK1_NUM_VALUE  => l_task_assignment_id
                    ,P_RESOURCE_ID    => l_resource_id);
  END IF;

  /*** check if updated record needs to be replicated ***/
  l_replicate := Replicate_Record( l_task_assignment_id );
  IF l_replicate THEN
    /*** record should be replicated ***/
    IF l_acc_id = -1 THEN
      /*** record doesn't exist on mobile but should be replicated -> Insert ***/
      l_dummy := Pre_Insert_Child
        (  l_task_assignment_id
          ,l_resource_id);
    ELSE
      /*** record exists on mobile and should still be replicated -> push changed record to mobile ***/
      Update_ACC_Record
        ( l_task_assignment_id
         ,l_resource_id
         ,l_acc_id);
    END IF;
  ELSE
    /*** record should not be replicated ***/
    IF l_acc_id > -1 THEN
      /*** record exists on mobile but should not be replicated anymore -> delete from mobile ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_task_assignment_id
        , g_table_name
        , 'Task assignment was replicated before update, but should not be replicated anymore.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      Post_Delete_Child
      ( l_task_assignment_id
       ,l_resource_id);
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Leaving POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_TASK_ASS_ACC_PKG','POST_UPDATE_TASK_ASSIGNMENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_TASK_ASSIGNMENT;

/* Called before assignment Delete */
PROCEDURE PRE_DELETE_TASK_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_resource_id        NUMBER;
  l_task_assignment_id NUMBER;
  l_enabled_flag       VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP(P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  /*** get assignment record details from public API ***/
  l_task_assignment_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;
  l_resource_id        := jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Entering PRE_DELETE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** yes -> delete assignment related data from the ACC tables ***/
  Post_Delete_Child
  ( l_task_assignment_id
   ,l_resource_id);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Leaving PRE_DELETE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_task_assignment_id
    , g_table_name
    , 'Caught exception in PRE_DELETE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_TASK_ASS_ACC_PKG','PRE_DELETE_TASK_ASSIGNMENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_TASK_ASSIGNMENT;

/* Called after assignment Delete */
PROCEDURE POST_DELETE_TASK_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_TASK_ASSIGNMENT;


/***Purge logic for Expired/Completed Task Assignments***/
--Bug 3475657
PROCEDURE PURGE_TASK_ASSIGNMENTS(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2)
IS
CURSOR lcur_purge_task_assignments is
SELECT  acc.task_assignment_id, acc.resource_id
FROM    csl_jtf_task_ass_acc acc,
        jtf_task_assignments jta,
        jtf_tasks_b jt,
        jtf_task_statuses_b jts,
        jtf_task_statuses_b jta_jts
WHERE   acc.task_assignment_id = jta.task_assignment_id
AND     jt.task_id = jta.task_id
AND     jts.task_status_id = jt.task_status_id
AND     jta_jts.task_status_id = jta.assignment_status_id
AND     (NVL(jt.scheduled_start_date, SYSDATE) < (SYSDATE - TO_NUMBER(FND_PROFILE.Value('CSL_APPL_HISTORY_IN_DAYS'))))
AND     (NVL(jts.cancelled_flag,'N') = 'Y'
        OR NVL(jts.closed_flag, 'N') = 'Y'
        OR NVL(jts.completed_flag, 'N') = 'Y'
        OR NVL(jts.rejected_flag, 'N') = 'Y'
        OR NVL(jta_jts.cancelled_flag,'N') = 'Y'
        OR NVL(jta_jts.closed_flag,'N') = 'Y'
        OR NVL(jta_jts.completed_flag,'N') = 'Y'
        OR NVL(jta_jts.rejected_flag, 'N') = 'Y')
AND     NOT EXISTS (SELECT 'x' FROM CSL_SERVICE_HISTORY hist
                    WHERE hist.history_incident_id = jt.source_object_id
                    AND jt.source_object_type_code = 'SR'
                    AND hist.resource_id = acc.resource_id);

rcur_purge_task_assignments lcur_purge_task_assignments%ROWTYPE;

BEGIN


     --Delete the Task Assignements which have expired or been been closed.
     FOR rcur_purge_task_assignments in lcur_purge_task_assignments
     LOOP
         Post_Delete_Child(rcur_purge_task_assignments.task_assignment_id, rcur_purge_task_assignments.resource_id);
     END LOOP;

    CSL_JTF_TASKS_ACC_PKG.Purge_Tasks;

    p_status := 'FINE';
    p_message := 'CSL_JTF_TASK_ASS_ACC_PKG.PURGE_TASK_ASSIGNMENTS Completed successfully';

EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Error in CSL_JTF_TASK_ASS_ACC_PKG.PURGE_TASK_ASSIGNMENTS: ' || substr(SQLERRM, 1, 2000);

	jtm_message_log_pkg.Log_Msg
            (rcur_purge_task_assignments.task_assignment_id,
            'CSL_JTF_TASK_ASS_ACC',
            'Exception occured in PURGE_TASK_ASSIGNMENT for id: ' || rcur_purge_task_assignments.task_assignment_id,
            JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

END PURGE_TASK_ASSIGNMENTS;

END CSL_JTF_TASK_ASS_ACC_PKG;

/
