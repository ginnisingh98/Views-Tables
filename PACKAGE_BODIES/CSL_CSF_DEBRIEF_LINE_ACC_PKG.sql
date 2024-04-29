--------------------------------------------------------
--  DDL for Package Body CSL_CSF_DEBRIEF_LINE_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CSF_DEBRIEF_LINE_ACC_PKG" AS
/* $Header: csldbacb.pls 120.0 2005/05/25 11:04:53 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CSF_DEBRIEF_LINES_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
   JTM_HOOK_UTIL_PKG.t_publication_item_list('CSF_DEBRIEF_LINES');
g_table_name            CONSTANT VARCHAR2(30) := 'CSF_DEBRIEF_LINES';
g_pk1_name              CONSTANT VARCHAR2(30) := 'DEBRIEF_LINE_ID';
g_pre_replicate         BOOLEAN;

g_debug_level           NUMBER;  -- debug level

/*** cache variables used by pre/post update ***/
CURSOR c_update_cache_rec( b_debrief_line_id NUMBER)
IS
 SELECT inventory_item_id
 , NVL( NVL(issuing_inventory_org_id, receiving_inventory_org_id)
        , FND_PROFILE.VALUE('CS_INV_VALIDATION_ORG')) AS organization_id
 FROM   csf_debrief_lines
 WHERE  debrief_line_id = b_debrief_line_id;
g_pre_update_rec c_update_cache_rec%ROWTYPE;

/*** Public Function that returns the debrief header id ***/
FUNCTION Get_Debrief_Header_Id
  ( p_debrief_line_id NUMBER
  )
RETURN NUMBER
IS
  CURSOR c_debrief_line (b_debrief_line_id NUMBER) IS
   SELECT debrief_header_id
   FROM CSF_DEBRIEF_LINES
   WHERE debrief_line_id = b_debrief_line_id;
  r_debrief_line c_debrief_line%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Entering Get_Debrief_Header_Id'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_debrief_line( p_debrief_line_id );
  FETCH c_debrief_line INTO r_debrief_line;
  IF c_debrief_line%NOTFOUND THEN
    /*** could not find debrief_line record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_line_id
      , g_table_name
      , 'Get_Debrief_Header_Id error: Could not find debrief_line_id ' ||
        p_debrief_line_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_debrief_line;
    RETURN -1;
  END IF;
  CLOSE c_debrief_line;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Get_Debrief_Header_Id returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** return the debrief header id ***/
  return r_debrief_line.debrief_header_id;
END Get_Debrief_Header_Id;

/*** Function that checks if debrief line should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_debrief_line_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_debrief_line (b_debrief_line_id NUMBER) IS
   SELECT *
   FROM CSF_DEBRIEF_LINES
   WHERE debrief_line_id = b_debrief_line_id;
  r_debrief_line c_debrief_line%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_debrief_line( p_debrief_line_id );
  FETCH c_debrief_line INTO r_debrief_line;
  IF c_debrief_line%NOTFOUND THEN
    /*** could not find debrief_line record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_line_id
      , g_table_name
      , 'Replicate_Record error: Could not find debrief_line_id ' || p_debrief_line_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_debrief_line;
    RETURN FALSE;
  END IF;
  CLOSE c_debrief_line;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;


/*** Private procedure that replicates given debrief_line related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_debrief_line_id     IN NUMBER
   ,p_resource_id         IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Inserting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Insert debrief_line ACC record ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_debrief_line_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_ACC_Record;

/*** Private procedure that re-sends given debrief_line to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_debrief_line_id            IN NUMBER
   ,p_resource_id                IN NUMBER
   ,p_acc_id                     IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Updating ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10) || 'access_id = ' || p_acc_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Update debrief_line ACC record ***/
  JTM_HOOK_UTIL_PKG.Update_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_RESOURCE_ID            => p_resource_id
    ,P_ACCESS_ID              => p_acc_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes debrief_line for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_debrief_line_id     IN NUMBER
   ,p_resource_id         IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Delete debrief_line ACC record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_debrief_line_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/***
  Public function that gets called when a debrief_line needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/
FUNCTION Pre_Insert_Child
  ( p_debrief_line_id     IN NUMBER
   ,p_resource_id         IN NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_debrief_line( b_debrief_line_id NUMBER)
  IS
   SELECT inventory_item_id
   , NVL( NVL(issuing_inventory_org_id, receiving_inventory_org_id)
          , FND_PROFILE.VALUE('CS_INV_VALIDATION_ORG')) AS organization_id
   FROM   csf_debrief_lines
   WHERE  debrief_line_id = b_debrief_line_id;
  r_debrief_line c_debrief_line%ROWTYPE;

  l_debrief_header_id  NUMBER;
  l_acc_id             NUMBER;
  l_success            BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Entering Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** does record match criteria? ***/
  IF Replicate_Record( p_debrief_line_id ) THEN
    /*** Get the debrief header id ***/
    l_debrief_header_id := Get_Debrief_Header_Id(p_debrief_line_id);

    /*** Insert the debrief header ***/
    CSL_CSF_DEBRIEF_HDR_ACC_PKG.Insert_Debrief_Header
    ( l_debrief_header_id
     ,p_resource_id
    );

    /*** insert the system item used by the debrief line ***/
    OPEN c_debrief_line( p_debrief_line_id );
    FETCH c_debrief_line INTO r_debrief_line;
    IF c_debrief_line%FOUND THEN
      IF r_debrief_line.inventory_item_id IS NOT NULL
       AND r_debrief_line.organization_id IS NOT NULL THEN
        CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Pre_Insert_Child (
         p_inventory_item_id => r_debrief_line.inventory_item_id
        ,p_organization_id   => r_debrief_line.organization_id
        ,p_resource_id       => p_resource_id
       );
      END IF;
    END IF;
    CLOSE c_debrief_line;

    /*** yes -> insert debrief_line acc record ***/
    Insert_ACC_Record
    ( p_debrief_line_id
     ,p_resource_id
    );

    l_success := TRUE;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Leaving Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_success;
END Pre_Insert_Child;

/***
  Public procedure that gets called when debrief lines need to be inserted into ACC table.
***/
PROCEDURE Pre_Insert_Children
  ( p_task_assignment_id  IN NUMBER
   ,p_resource_id         IN NUMBER
  )
IS
  CURSOR c_debrief_line (b_task_assignment_id NUMBER) IS
   SELECT CDL.debrief_line_id
   FROM CSF_DEBRIEF_HEADERS CDH, CSF_DEBRIEF_LINES CDL
   WHERE CDH.task_assignment_id = b_task_assignment_id
   AND   CDH.debrief_header_id = CDL.debrief_header_id;
  r_debrief_line c_debrief_line%ROWTYPE;

  l_dummy  BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Entering Pre_Insert_Children procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_debrief_line IN c_debrief_line( p_task_assignment_id ) LOOP

    /*** Insert record if applicable ***/
    l_dummy := Pre_Insert_Child
      ( r_debrief_line.debrief_line_id
        ,p_resource_id
      );

    IF l_dummy = FALSE THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
        jtm_message_log_pkg.Log_Msg
        ( p_task_assignment_id
        , g_table_name
        , 'Pre_Insert_Children:  debrief line was not insertable.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
      END IF;
    END IF;
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Leaving Pre_Insert_Children procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END Pre_Insert_Children;

/***
  Public procedure that gets called when a debrief_line needs to be deleted from ACC table.
***/
PROCEDURE Post_Delete_Child
  ( p_debrief_line_id     IN NUMBER
   ,p_resource_id         IN NUMBER
  )
IS
  CURSOR c_debrief_line( b_debrief_line_id NUMBER)
  IS
   SELECT inventory_item_id
   , NVL( NVL(issuing_inventory_org_id, receiving_inventory_org_id)
          , FND_PROFILE.VALUE('CS_INV_VALIDATION_ORG')) AS organization_id
   FROM   csf_debrief_lines
   WHERE  debrief_line_id = b_debrief_line_id;
  r_debrief_line c_debrief_line%ROWTYPE;

  l_debrief_header_id NUMBER;
  l_acc_id            NUMBER;
  l_success           BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Entering Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** no -> delete debrief_line record from ACC ***/
  Delete_ACC_Record
  ( p_debrief_line_id
   ,p_resource_id);

  /*** delete the system item used by the debrief line ***/
  OPEN c_debrief_line( p_debrief_line_id );
  FETCH c_debrief_line INTO r_debrief_line;
  IF c_debrief_line%FOUND THEN
    IF r_debrief_line.inventory_item_id IS NOT NULL
     AND r_debrief_line.organization_id IS NOT NULL THEN
      CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Post_Delete_Child (
       p_inventory_item_id => r_debrief_line.inventory_item_id
      ,p_organization_id   => r_debrief_line.organization_id
      ,p_resource_id       => p_resource_id
     );
    END IF;
  END IF;
  CLOSE c_debrief_line;

  /*** Get the debrief header id ***/
  l_debrief_header_id := Get_Debrief_Header_Id(p_debrief_line_id);

  /*** Delete the debrief header ***/
  CSL_CSF_DEBRIEF_HDR_ACC_PKG.Delete_Debrief_Header
  ( l_debrief_header_id
   ,p_resource_id
  );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Leaving Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Post_Delete_Child;

/***
  Public procedure that gets called when debrief lines need to be deleted into ACC table.
***/
PROCEDURE Post_Delete_Children
  ( p_task_assignment_id  IN NUMBER
   ,p_resource_id         IN NUMBER
  )
IS
  CURSOR c_debrief_line (b_task_assignment_id NUMBER) IS
   SELECT CDL.debrief_line_id
   FROM CSF_DEBRIEF_HEADERS CDH, CSF_DEBRIEF_LINES CDL
   WHERE CDH.task_assignment_id = b_task_assignment_id
   AND   CDH.debrief_header_id = CDL.debrief_header_id;
  r_debrief_line c_debrief_line%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Entering Post_Delete_Children procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_debrief_line IN c_debrief_line( p_task_assignment_id ) LOOP

      /*** Delete record if applicable ***/
      Post_Delete_Child
      (  r_debrief_line.debrief_line_id
        ,p_resource_id
      );
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_task_assignment_id
    , g_table_name
    , 'Leaving Post_Delete_Children procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END Post_Delete_Children;

/***
  Function that retrieves resource_id for a given debrief_line_id.
***/
FUNCTION Get_Resource_Id( p_debrief_line_id NUMBER )
RETURN NUMBER
IS
  CURSOR c_resource ( b_debrief_line_id NUMBER)
  IS
   SELECT resource_id
   FROM   jtf_task_assignments jta
   ,      csf_debrief_headers  dbh
   ,      csf_debrief_lines    dbl
   WHERE  jta.task_assignment_id = dbh.task_assignment_id
   AND    dbh.debrief_header_id  = dbl.debrief_header_id
   AND    dbl.debrief_line_id = b_debrief_line_id;
  r_resource c_resource%ROWTYPE;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Entering Get_Resource_Id function'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_resource( p_debrief_line_id );
  FETCH c_resource INTO r_resource;
  CLOSE c_resource;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_debrief_line_id
    , g_table_name
    , 'Leaving Get_Resource_Id function'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  RETURN r_resource.resource_id;
END Get_Resource_Id;

/* Called before debrief_line Insert */
PROCEDURE PRE_INSERT_DEBRIEF_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_DEBRIEF_LINE;

/* Called after debrief_line Insert */
PROCEDURE POST_INSERT_DEBRIEF_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_debrief_line_id  NUMBER;
  l_resource_id      NUMBER;
  l_dummy            BOOLEAN;
  l_enabled_flag      VARCHAR2(30);
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
    ( l_debrief_line_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** get debrief record details from public API ***/
  l_debrief_line_id := CSF_DEBRIEF_LINES_PKG.user_hooks_rec.debrief_line_id;
  l_resource_id := Get_Resource_Id( l_debrief_line_id );

  /*** is resource a mobile user? ***/
  IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( l_resource_id ) THEN
    /*** No -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( l_debrief_line_id
      , g_table_name
      , 'POST_INSERT_DEBRIEF_LINE' || fnd_global.local_chr(10) ||
        'Resource_id ' || l_resource_id || ' is not a mobile user.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  ELSE

    /*** Insert record if applicable ***/
    l_dummy := Pre_Insert_Child
      (  l_debrief_line_id
        ,l_resource_id
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_debrief_line_id
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
    ( l_debrief_line_id
    , g_table_name
    , 'Caught exception in POST_INSERT hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSF_DEBRIEF_LINE_ACC_PKG','POST_INSERT_DEBRIEF_LINE',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_DEBRIEF_LINE;

/* Called before debrief_line Update */
PROCEDURE PRE_UPDATE_DEBRIEF_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_debrief_line_id   NUMBER;
  l_resource_id       NUMBER;
  l_enabled_flag      VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  /*** default value of pre replication ***/
  g_pre_replicate := FALSE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_debrief_line_id
    , g_table_name
    , 'Entering PRE_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

    /*** get debrief_line record details from public API ***/
  l_debrief_line_id := CSF_DEBRIEF_LINES_PKG.user_hooks_rec.debrief_line_id;
  l_resource_id := Get_Resource_Id( l_debrief_line_id );

  /*** Check if debrief_line before update matches criteria ***/
  IF JTM_HOOK_UTIL_PKG.isMobileFSresource( l_resource_id ) THEN
    g_pre_replicate := Replicate_Record( l_debrief_line_id );
  END IF;

  IF g_pre_replicate THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_debrief_line_id
        , g_table_name
        , 'Debrief line was replicated before update.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** retrieve old system item data from debrief line ***/
    OPEN c_update_cache_rec( l_debrief_line_id );
    FETCH c_update_cache_rec INTO g_pre_update_rec;
    CLOSE c_update_cache_rec;

  ELSIF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( l_debrief_line_id
    , g_table_name
    , 'Debrief line was not replicated before update'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_debrief_line_id
    , g_table_name
    , 'Leaving PRE_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_debrief_line_id
    , g_table_name
    , 'Caught exception in PRE_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSF_DEBRIEF_LINE_ACC_PKG','PRE_UPDATE_DEBRIEF_LINE',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  g_pre_replicate := FALSE;
END PRE_UPDATE_DEBRIEF_LINE;

/* Called after debrief_line Update */
PROCEDURE POST_UPDATE_DEBRIEF_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS

  l_debrief_line_id   NUMBER;
  l_resource_id       NUMBER;
  l_replicate         BOOLEAN;

  l_access_id         NUMBER;
  l_dummy             BOOLEAN;
  l_enabled_flag      VARCHAR2(30);

  l_post_update_rec   c_update_cache_rec%ROWTYPE;
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
    ( l_debrief_line_id
    , g_table_name
    , 'Entering POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** get debrief_line record details from public API ***/
  l_debrief_line_id := CSF_DEBRIEF_LINES_PKG.user_hooks_rec.debrief_line_id;
  l_resource_id := Get_Resource_Id( l_debrief_line_id );

  /*** Check if debrief_line after update matches criteria ***/
  l_replicate := FALSE;
  IF JTM_HOOK_UTIL_PKG.isMobileFSresource( l_resource_id ) THEN
    l_replicate := Replicate_Record( l_debrief_line_id );
  END IF;

  IF l_replicate THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_debrief_line_id
        , g_table_name
        , 'Debrief line should be replicated after update.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  ELSIF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( l_debrief_line_id
    , g_table_name
    , 'Debrief line should not be replicated after update'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Check results from pre update ***/
  IF g_pre_replicate THEN

    /*** replicate record after update? ***/
    IF NOT l_replicate THEN

      /*** No -> Delete the record ***/
      Post_Delete_Child
      ( l_debrief_line_id
      , l_resource_id );

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_debrief_line_id
        , g_table_name
        , 'Debrief line was deleted during post update.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

    ELSE

      /*** yes -> re-send updated debrief record to resource ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_debrief_line_id
        , g_table_name
        , 'Debrief line being re-sent to mobile user.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      l_access_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
      ( p_acc_table_name => g_acc_table_name
       ,p_resource_id    => l_resource_id
       ,P_PK1_NAME        => g_pk1_name
       ,P_PK1_NUM_VALUE   => l_debrief_line_id
      );

      /* Update the debrief line */
      Update_ACC_Record
      ( l_debrief_line_id
       ,l_resource_id
       ,l_access_id
      );

      /* Check if system item changed */
      OPEN c_update_cache_rec( l_debrief_line_id );
      FETCH c_update_cache_rec INTO l_post_update_rec;
      IF (g_pre_update_rec.inventory_item_id <> l_post_update_rec.inventory_item_id
       OR g_pre_update_rec.organization_id <> l_post_update_rec.organization_id) THEN
        -- yes -> remove old item and insert new item
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( l_debrief_line_id
          , g_table_name
          , 'System item changed -> deleting old item and inserting new item.'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Post_Delete_Child (
         p_inventory_item_id => g_pre_update_rec.inventory_item_id
        ,p_organization_id   => g_pre_update_rec.organization_id
        ,p_resource_id       => l_resource_id
        );

        CSL_MTL_SYSTEM_ITEMS_ACC_PKG.Pre_Insert_Child (
         p_inventory_item_id => l_post_update_rec.inventory_item_id
        ,p_organization_id   => l_post_update_rec.organization_id
        ,p_resource_id       => l_resource_id
        );
      END IF; -- system item changed
      CLOSE c_update_cache_rec;
    END IF;

  ELSIF l_replicate THEN
    /*** record was not replicated before update -> replicate now ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( l_debrief_line_id
      , g_table_name
      , 'Debrief line was inserted during post update.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** Insert record if applicable ***/
    l_dummy := Pre_Insert_Child
      (  l_debrief_line_id
        ,l_resource_id
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_debrief_line_id
    , g_table_name
    , 'Leaving POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_debrief_line_id
    , g_table_name
    , 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSF_DEBRIEF_LINE_ACC_PKG','POST_UPDATE_DEBRIEF_LINE',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_DEBRIEF_LINE;

/* Called before debrief_line Delete */
PROCEDURE PRE_DELETE_DEBRIEF_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS

  l_debrief_line_id NUMBER;
  l_resource_id     NUMBER;

BEGIN

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_debrief_line_id
    , v_object_name => g_table_name
    , v_message     => 'Entering PRE_DELETE hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Get debrief line record details from public API and then get the resource id ***/
  l_debrief_line_id := CSF_DEBRIEF_LINES_PKG.user_hooks_rec.debrief_line_id;
  l_resource_id     := Get_Resource_Id( l_debrief_line_id );

  /*** Delete debrief line from ACC table. This also deletes its Debrief Header ***/
  Post_Delete_Child ( l_debrief_line_id
                    , l_resource_id );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_debrief_line_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving PRE_DELETE hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN

  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_debrief_line_id
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in PRE_DELETE hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg('CSL_CSF_DEBRIEF_LINE_ACC_PKG','PRE_DELETE_DEBRIEF_LINE',sqlerrm);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_DEBRIEF_LINE;

/* Called after debrief_line Delete */
PROCEDURE POST_DELETE_DEBRIEF_LINE
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_DEBRIEF_LINE;

END CSL_CSF_DEBRIEF_LINE_ACC_PKG;

/
