--------------------------------------------------------
--  DDL for Package Body CSL_CSP_REQ_HEADERS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CSP_REQ_HEADERS_ACC_PKG" AS
/* $Header: cslrhacb.pls 120.0 2005/05/25 11:06:42 appldev noship $ */

/*** Globals ***/
-- CSP_REQUIREMENT_HEADERS
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CSP_REQ_HEADERS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSP_REQUIREMENT_HEADERS');
g_pk1_name              CONSTANT VARCHAR2(30) := 'REQUIREMENT_HEADER_ID';

g_table_name            CONSTANT VARCHAR2(30) := 'CSP_REQUIREMENT_HEADERS';
g_debug_level           NUMBER; -- debug level

/*** Function that checks if requirement record(s) should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_req_header_id NUMBER
  )
RETURN BOOLEAN
IS
/*  CURSOR c_req_task_ass( b_req_header_id NUMBER ) IS
   SELECT jta.resource_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    crh.requirement_header_id = b_req_header_id;*/

  CURSOR c_req_resource( b_req_header_id NUMBER ) IS
    SELECT RH.RESOURCE_ID
    FROM CSP_REQUIREMENT_HEADERS RH
    WHERE  RH.REQUIREMENT_HEADER_ID = b_req_header_id;

  l_resource_id NUMBER;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_req_resource( p_req_header_id );
  FETCH c_req_resource INTO l_resource_id;
  IF c_req_resource%NOTFOUND THEN
    --OPEN c_req_task_ass( p_req_header_id );
    --FETCH c_req_task_ass INTO l_resource_id;
    --IF c_req_task_ass%NOTFOUND THEN
      l_resource_id := -1;
    --END IF;
    --CLOSE c_req_task_ass;
  END IF;
  CLOSE c_req_resource;

  IF l_resource_id < 0 THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_header_id
      , g_table_name
      , 'Replicate_Record error: Could not find resource for requirement '|| p_req_header_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
    RETURN FALSE;
  END IF;

  /*** is resource a mobile user? ***/
  IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( l_resource_id ) THEN
    /*** No -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_header_id
      , g_table_name
      , 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
        'Resource_id ' || l_resource_id || ' is not a mobile user.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    RETURN FALSE;
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;

/*** Private procedure that replicates given requierment related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_req_header_id        IN NUMBER
  )
IS
  /*CURSOR c_req_task_ass( b_req_header_id NUMBER ) IS
   SELECT jta.resource_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    crh.requirement_header_id = b_req_header_id;*/

  CURSOR c_req_resource( b_req_header_id NUMBER ) IS
    SELECT RH.RESOURCE_ID
    FROM CSP_REQUIREMENT_HEADERS RH
    WHERE  RH.REQUIREMENT_HEADER_ID = b_req_header_id;

  l_resource_id NUMBER;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Inserting ACC record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_req_resource( p_req_header_id );
  FETCH c_req_resource INTO l_resource_id;
  IF c_req_resource%NOTFOUND THEN
--    OPEN c_req_task_ass( p_req_header_id );
--    FETCH c_req_task_ass INTO l_resource_id;
--    IF c_req_task_ass%NOTFOUND THEN
      l_resource_id := -1;
--    END IF;
--    CLOSE c_req_task_ass;
  END IF;
  CLOSE c_req_resource;

  IF l_resource_id < 0 THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_header_id
      , g_table_name
      , 'Insert ACC Record error: Could not find a resource for requirement ' || p_req_header_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
  ELSE
    JTM_HOOK_UTIL_PKG.Insert_Acc
    (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     , P_ACC_TABLE_NAME         => g_acc_table_name
     , P_PK1_NAME               => g_pk1_name
     , P_PK1_NUM_VALUE          => p_req_header_id
     , P_RESOURCE_ID            => l_resource_id
    );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_ACC_Record;

/*** Private procedure that re-sends given requirement to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_req_header_id        IN NUMBER
  )
IS
/*  CURSOR c_req_task_ass( b_req_header_id NUMBER ) IS
   SELECT jta.resource_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    crh.requirement_header_id = b_req_header_id;*/

  CURSOR c_req_resource( b_req_header_id NUMBER ) IS
    SELECT RH.RESOURCE_ID
    FROM CSP_REQUIREMENT_HEADERS RH
    WHERE  RH.REQUIREMENT_HEADER_ID = b_req_header_id;

  l_resource_id NUMBER;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Updating ACC record(s)'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  OPEN c_req_resource( p_req_header_id );
  FETCH c_req_resource INTO l_resource_id;
  IF c_req_resource%NOTFOUND THEN
--    OPEN c_req_task_ass( p_req_header_id );
--    FETCH c_req_task_ass INTO l_resource_id;
--    IF c_req_task_ass%NOTFOUND THEN
      l_resource_id := -1;
--    END IF;
--    CLOSE c_req_task_ass;
  END IF;
  CLOSE c_req_resource;

  IF l_resource_id < 0 THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_req_header_id
      , g_table_name
      , 'Update ACC Record error: Could not find resource for requirement '|| p_req_header_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
  ELSE
    JTM_HOOK_UTIL_PKG.Update_Acc
     (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      , P_ACC_TABLE_NAME         => g_acc_table_name
      , P_RESOURCE_ID            => l_resource_id
      , P_ACCESS_ID              => p_req_header_id
     );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes requirement for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_req_header_id IN NUMBER
   ,p_resource_id   IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  -- No delete of the requirement is possible
  JTM_HOOK_UTIL_PKG.Delete_Acc
   (  P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    , P_ACC_TABLE_NAME         => g_acc_table_name
    , P_PK1_NAME               => g_pk1_name
    , P_PK1_NUM_VALUE          => p_req_header_id
    , P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_req_header_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/*** Called before requirement Insert ***/
PROCEDURE PRE_INSERT_REQ_HEADER
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_REQ_HEADER;

/*** Called after requirement Insert ***/
PROCEDURE POST_INSERT_REQ_HEADER( x_return_status OUT NOCOPY varchar2 )
IS
  l_req_header_id  NUMBER;
  l_enabled_flag         VARCHAR2(30);
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
    ( l_req_header_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_req_header_id := CSP_REQUIREMENT_HEADERS_PKG.user_hooks_rec.REQUIREMENT_HEADER_ID;

  /*** Insert record if applicable ***/
  IF Replicate_Record(l_req_header_id) THEN
    Insert_ACC_Record(l_req_header_id);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_req_header_id
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
    ( l_req_header_id
    , g_table_name
    , 'Caught exception in POST_INSERT hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_HEADERS_ACC_PKG','POST_INSERT_REQ_HEADER',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_REQ_HEADER;

/* Called before requirement Update */
PROCEDURE PRE_UPDATE_REQ_HEADER
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_HEADERS_ACC_PKG','PRE_UPDATE_REQ_HEADER',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_REQ_HEADER;

/* Called after requirement Update */
PROCEDURE POST_UPDATE_REQ_HEADER( x_return_status OUT NOCOPY varchar2 )
IS
  l_req_header_id        NUMBER;
  l_enabled_flag         VARCHAR2(30);
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
    ( l_req_header_id
    , g_table_name
    , 'Entering POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_req_header_id := CSP_REQUIREMENT_HEADERS_PKG.user_hooks_rec.REQUIREMENT_HEADER_ID;

  IF Replicate_Record( l_req_header_id ) THEN
    Update_ACC_Record(l_req_header_id);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_req_header_id
    , g_table_name
    , 'Leaving POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_req_header_id
    , g_table_name
    , 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_HEADERS_ACC_PKG','POST_UPDATE_REQ_HEADER',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_REQ_HEADER;

/* Called before req header Delete */
PROCEDURE PRE_DELETE_REQ_HEADER
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_REQ_HEADER;

/* Called after req header Delete */
PROCEDURE POST_DELETE_REQ_HEADER
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_HEADERS_ACC_PKG','POST_DELETE_REQ_HEADER',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_REQ_HEADER;

/* Remove all ACC records of a mobile user */
PROCEDURE Delete_All_ACC_Records
  ( p_resource_id in NUMBER
  , x_return_status OUT NOCOPY varchar2
  )
IS
  CURSOR c_req_header (b_resource_id NUMBER) IS
   SELECT REQUIREMENT_HEADER_ID
   FROM   CSP_REQUIREMENT_HEADERS RH
   WHERE  RH.RESOURCE_ID = b_resource_id;

/* CURSOR c_req_task_ass (b_resource_id NUMBER) IS
  SELECT crh.requirement_header_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    jta.resource_id = b_resource_id; */

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Delete_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*First all resource created requirements*/
  FOR r_req_header IN c_req_header( p_resource_id ) LOOP
    Delete_Acc_Record( r_req_header.requirement_header_id, p_resource_id );
  END LOOP;

  /*Second all task assignment created requirements*/
--  FOR r_req_task_ass IN c_req_task_ass( p_resource_id ) LOOP
--    Delete_Acc_Record( r_req_task_ass.requirement_header_id, p_resource_id );
--  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving Delete_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_HEADERS_ACC_PKG','Delete_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Delete_All_ACC_Records;

/* Full synch for a mobile user */
PROCEDURE Insert_All_ACC_Records
  ( p_resource_id in NUMBER
  , x_return_status OUT NOCOPY varchar2
  )
IS
  CURSOR c_req_header (b_resource_id NUMBER) IS
   SELECT REQUIREMENT_HEADER_ID
   FROM   CSP_REQUIREMENT_HEADERS RH
   WHERE  RH.RESOURCE_ID = b_resource_id;

/* CURSOR c_req_task_ass (b_resource_id NUMBER) IS
  SELECT crh.requirement_header_id
   FROM   jtf.jtf_task_assignments jta
   ,      csp_requirement_headers crh
   WHERE  crh.task_assignment_id = jta.task_assignment_id
   AND    jta.assignee_role = 'ASSIGNEE'
   AND    jta.resource_id = b_resource_id; */

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Insert_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*First all resource based requirements*/
  FOR r_req_header IN c_req_header( p_resource_id ) LOOP
    IF Replicate_Record( r_req_header.requirement_header_id ) THEN
      Insert_Acc_Record( r_req_header.requirement_header_id );
    END IF;
  END LOOP;

  /*Second all task assignmnet based requirements*/
--  FOR r_req_task_ass IN c_req_task_ass( p_resource_id ) LOOP
--    IF Replicate_Record( r_req_task_ass.requirement_header_id ) THEN
--      Insert_Acc_Record( r_req_task_ass.requirement_header_id );
--    END IF;
--  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving Insert_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_HEADERS_ACC_PKG','Insert_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Insert_All_ACC_Records;

END CSL_CSP_REQ_HEADERS_ACC_PKG;

/
