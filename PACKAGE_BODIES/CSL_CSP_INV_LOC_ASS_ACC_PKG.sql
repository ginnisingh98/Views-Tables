--------------------------------------------------------
--  DDL for Package Body CSL_CSP_INV_LOC_ASS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CSP_INV_LOC_ASS_ACC_PKG" AS
/* $Header: cslilacb.pls 120.0 2005/05/24 17:50:07 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CSP_INV_LOC_ASS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSP_INV_LOC_ASSIGNMENTS');
g_table_name            CONSTANT VARCHAR2(30) := 'CSP_INV_LOC_ASSIGNMENTS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'CSP_INV_LOC_ASSIGNMENT_ID';
g_old_resource_id       NUMBER; -- variable containing old resource_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level

/*** Function that checks if assignment record should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_csp_inv_loc_assignment_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_csp_inv_loc_assignment (b_csp_inv_loc_assignment_id NUMBER) IS
   SELECT *
   FROM CSP_INV_LOC_ASSIGNMENTS
   WHERE CSP_INV_LOC_ASSIGNMENT_ID = b_csp_inv_loc_assignment_id;
  r_csp_inv_loc_assignment c_csp_inv_loc_assignment%ROWTYPE;

  l_return_value BOOLEAN := FALSE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Replicate_Record'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_csp_inv_loc_assignment( p_csp_inv_loc_assignment_id );
  FETCH c_csp_inv_loc_assignment INTO r_csp_inv_loc_assignment;
  IF c_csp_inv_loc_assignment%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_csp_inv_loc_assignment_id
      , v_object_name => g_table_name
      , v_message     => 'Replicate_Record error: Could not find '
                         || g_pk1_name || ' ' || p_csp_inv_loc_assignment_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    CLOSE c_csp_inv_loc_assignment;
    RETURN l_return_value;
  END IF;
  CLOSE c_csp_inv_loc_assignment;

  /*** is this an RS_EMPLOYEE assignment? ***/
  IF NVL(r_csp_inv_loc_assignment.resource_type,'') <> 'RS_EMPLOYEE' THEN
    /*** No -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_csp_inv_loc_assignment_id
      , v_object_name => g_table_name
      , v_message     => 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
                         'RESOURCE_TYPE <> ''RS_EMPLOYEE'''
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    RETURN l_return_value;
  END IF;

  /*** is resource a mobile user? ***/
  IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( r_csp_inv_loc_assignment.resource_id ) THEN
    /*** No -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_csp_inv_loc_assignment_id
      , v_object_name => g_table_name
      , v_message     => 'Replicate_Record returned FALSE' || fnd_global.local_chr(10) ||
                         'Resource_id ' || r_csp_inv_loc_assignment.resource_id || ' is not a mobile user.'
	          || fnd_global.local_chr(10) || 'For location assignment : ' || p_csp_inv_loc_assignment_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    RETURN l_return_value;
  END IF;

  /*** Record is found OK return status ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Replicate_Record returned TRUE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  l_return_value := TRUE;

  RETURN l_return_value;
END Replicate_Record;

/*** Private procedure that replicates given assignment related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_csp_inv_loc_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
IS
  l_success       BOOLEAN;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_ACC_Record'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Inserting ACC record for resource_id = ' || p_resource_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Call common package to insert record into ACC table ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( p_publication_item_names => g_publication_item_name
   ,p_acc_table_name         => g_acc_table_name
   ,p_pk1_name               => g_pk1_name
   ,p_pk1_num_value          => p_csp_inv_loc_assignment_id
   ,p_resource_id            => p_resource_id
  );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Insert_ACC_Record'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

END Insert_ACC_Record;

/*** Private procedure that re-sends given location assignment to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_csp_inv_loc_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_acc_id             IN NUMBER
  )
IS

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Update_ACC_Record'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Updating ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10) ||
                       'access_id = ' || p_acc_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Update Inventor Location Assignment ACC record ***/
  JTM_HOOK_UTIL_PKG.Update_Acc
   ( p_publication_item_names => g_publication_item_name
    ,p_acc_table_name         => g_acc_table_name
    ,p_resource_id            => p_resource_id
    ,p_access_id              => p_acc_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Update_ACC_Record'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes assignment for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_csp_inv_loc_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
  )
IS

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Delete_ACC_Record'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Deleting ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10) ||
                       'Location assignment = ' || p_csp_inv_loc_assignment_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Delete Inventor Location Assignment ACC record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
   ( p_publication_item_names => g_publication_item_name
    ,p_acc_table_name         => g_acc_table_name
    ,p_pk1_name               => g_pk1_name
    ,p_pk1_num_value          => p_csp_inv_loc_assignment_id
    ,p_resource_id            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Delete_ACC_Record'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/***
  Public function that gets called when a Inventory Location Assignment needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/
FUNCTION Pre_Insert_Child
  ( p_csp_inv_loc_assignment_id     IN NUMBER
   ,p_resource_id                   IN NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_retreive_org_name(b_loc_assignment_id NUMBER) IS
         SELECT organization_id, subinventory_code
         FROM CSP_INV_LOC_ASSIGNMENTS
         WHERE csp_inv_loc_assignment_id = b_loc_assignment_id;

  r_retreive_org_name c_retreive_org_name%ROWTYPE;

  l_success BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Pre_Insert_Child procedure'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_success := FALSE;
  /*** no -> does record match criteria? ***/
  IF Replicate_Record( p_csp_inv_loc_assignment_id ) THEN

    OPEN c_retreive_org_name( p_csp_inv_loc_assignment_id );
    FETCH c_retreive_org_name INTO r_retreive_org_name;
    IF NOT c_retreive_org_name%NOTFOUND THEN

      IF CSL_CSP_SEC_INV_ACC_PKG.Insert_CSP_Sec_Inventory(
                                 p_resource_id
		  ,r_retreive_org_name.subinventory_code
		  ,r_retreive_org_name.organization_id) THEN

        Insert_ACC_Record
          ( p_csp_inv_loc_assignment_id
          , p_resource_id
          );

        CSL_MTL_MAT_TRANS_ACC_PKG.Insert_MTL_Mat_Transaction(
                                      p_resource_id,
                                      r_retreive_org_name.subinventory_code,
                                      r_retreive_org_name.organization_id
	                     );

        l_success := TRUE;
      END IF;

    END IF;
    CLOSE c_retreive_org_name;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_csp_inv_loc_assignment_id
    , g_table_name
    , 'Leaving Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_success;
END Pre_Insert_Child;

/***
  Public procedure that gets called when a Inventory Location Assignment needs to be deleted from ACC table.
***/
PROCEDURE Post_Delete_Child
  ( p_csp_inv_loc_assignment_id IN NUMBER
   ,p_resource_id IN NUMBER
  )
IS

  CURSOR c_retreive_org_name(b_loc_assignment_id NUMBER) IS
         SELECT organization_id, subinventory_code
         FROM CSP_INV_LOC_ASSIGNMENTS
         WHERE csp_inv_loc_assignment_id = b_loc_assignment_id;

  r_retreive_org_name c_retreive_org_name%ROWTYPE;

  l_return_value BOOLEAN;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_csp_inv_loc_assignment_id
    , g_table_name
    , 'Entering Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

    /*** no -> delete task record from ACC ***/
  Delete_ACC_Record(
                   p_csp_inv_loc_assignment_id
                  ,p_resource_id);

  OPEN c_retreive_org_name( p_csp_inv_loc_assignment_id);
  FETCH c_retreive_org_name INTO r_retreive_org_name;
  IF c_retreive_org_name%FOUND THEN

    l_return_value := CSL_CSP_SEC_INV_ACC_PKG.Delete_CSP_Sec_Inventory(
                                     p_resource_id
                                    ,r_retreive_org_name.subinventory_code
                                    ,r_retreive_org_name.organization_id);

/*    CSL_MTL_MAT_TRANS_ACC_PKG.Delete_MTL_Mat_Transaction(
                                     p_resource_id,
                                     r_retreive_org_name.subinventory_code,
                                     r_retreive_org_name.organization_id); */

  END IF;
  CLOSE c_retreive_org_name;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_csp_inv_loc_assignment_id
    , g_table_name
    , 'Leaving Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Post_Delete_Child;

/*** Called before assignment Insert ***/
PROCEDURE PRE_INSERT_INV_LOC_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_INV_LOC_ASSIGNMENT;

/*** Called after assignment Insert ***/
PROCEDURE POST_INSERT_INV_LOC_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_resource_id        NUMBER;
  l_csp_inv_loc_assignment_id NUMBER;
  l_dummy              BOOLEAN;
  CURSOR c_resource( b_csp_inv_loc_assignment_id NUMBER ) IS
   SELECT resource_id
   FROM   csp_inv_loc_assignments
   WHERE  csp_inv_loc_assignment_id = b_csp_inv_loc_assignment_id;
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
    ( v_object_id   => l_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Entering POST_INSERT hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** get assignment record details from public API ***/
  l_csp_inv_loc_assignment_id := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID;

  OPEN c_resource( l_csp_inv_loc_assignment_id );
  FETCH c_resource INTO l_resource_id;
  IF c_resource%FOUND THEN
    /*** Insert record if applicable ***/
    l_dummy := Pre_Insert_Child
      (  l_csp_inv_loc_assignment_id
        ,l_resource_id
      );
  ELSE
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => l_csp_inv_loc_assignment_id
      , v_object_name => g_table_name
      , v_message     => 'Cannot find resource for inv loc assignment '||l_csp_inv_loc_assignment_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  END IF;
  CLOSE c_resource;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving POST_INSERT hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  RETURN;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment_id
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in POST_INSERT hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_INV_LOC_ASS_ACC_PKG','POST_INSERT_INV_LOC_ASSIGNMENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_INV_LOC_ASSIGNMENT;

/* Called before assignment Update */
PROCEDURE PRE_UPDATE_INV_LOC_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  CURSOR c_csp_inv_loc_assignment( b_csp_inv_loc_ass_id NUMBER ) IS
   SELECT resource_id
   FROM   csp_inv_loc_assignments -- don't use synonym as that one filters on OWNER records
   WHERE  csp_inv_loc_assignment_id = b_csp_inv_loc_ass_id;

  r_csp_inv_loc_assignment c_csp_inv_loc_assignment%ROWTYPE;
  l_csp_inv_loc_assignment NUMBER;
  l_enabled_flag VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
  END IF;
  /*** get assignment record details from public API ***/
  l_csp_inv_loc_assignment := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Entering PRE_UPDATE hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** retrieve old resource_id for task assignment ***/
  OPEN c_csp_inv_loc_assignment(l_csp_inv_loc_assignment);
  FETCH c_csp_inv_loc_assignment INTO r_csp_inv_loc_assignment;
  g_old_resource_id := r_csp_inv_loc_assignment.resource_id;
  CLOSE c_csp_inv_loc_assignment;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Leaving PRE_UPDATE hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in PRE_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_INV_LOC_ASS_ACC_PKG','PRE_UPDATE_INV_LOC_ASSIGNMENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_INV_LOC_ASSIGNMENT;

/* Called after assignment Update */
PROCEDURE POST_UPDATE_INV_LOC_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  CURSOR c_retreive_org_name(b_loc_assignment_id NUMBER) IS
         SELECT organization_id, subinventory_code
         FROM CSP_INV_LOC_ASSIGNMENTS
         WHERE csp_inv_loc_assignment_id = b_loc_assignment_id;

  r_retreive_org_name c_retreive_org_name%ROWTYPE;

  l_resource_id             NUMBER;
  l_csp_inv_loc_assignment  NUMBER;
  l_replicate               BOOLEAN;
  l_dummy                   BOOLEAN;
  l_acc_id                  NUMBER;

  CURSOR c_csp_inv_loc_assignment( b_csp_inv_loc_ass_id NUMBER ) IS
   SELECT resource_id
   FROM   csp_inv_loc_assignments -- don't use synonym as that one filters on OWNER records
   WHERE  csp_inv_loc_assignment_id = b_csp_inv_loc_ass_id;

  r_csp_inv_loc_assignment c_csp_inv_loc_assignment%ROWTYPE;

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
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Entering POST_UPDATE hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** get assignment record details from public API ***/
  l_csp_inv_loc_assignment := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID;

  /*** retrieve 'new' resource_id for task assignment ***/
  OPEN c_csp_inv_loc_assignment(l_csp_inv_loc_assignment);
  FETCH c_csp_inv_loc_assignment INTO r_csp_inv_loc_assignment;
  l_resource_id := r_csp_inv_loc_assignment.resource_id;
  CLOSE c_csp_inv_loc_assignment;


  /*** did resource_id get changed? ***/
  IF (g_old_resource_id <> l_resource_id) THEN
    /*** yes -> do cascading delete for old resource_id ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( l_csp_inv_loc_assignment
      , g_table_name
      , 'Invntory Location Assignment resource_id changed from ' || g_old_resource_id ||
        ' to ' || l_resource_id || '.' || fnd_global.local_chr(10) ||
        'Deleting old assignment ACC record (if exists).'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** DELETE SEQUENCE !!!!!! ***/

  ELSE
    /*** resource_id is same as before the update -> check if it already exists on mobile ***/
    l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
                   ( P_ACC_TABLE_NAME => g_acc_table_name
                    ,P_PK1_NAME       => g_pk1_name
                    ,P_PK1_NUM_VALUE  => l_csp_inv_loc_assignment
                    ,P_RESOURCE_ID    => l_resource_id);
  END IF;

  /*** check if updated record needs to be replicated ***/
  l_replicate := Replicate_Record( l_csp_inv_loc_assignment );
  IF l_replicate THEN
    /*** Check if it is going to be Update or Insert! ***/
    IF l_acc_id = -1 THEN
    /*** Insert ! ***/
      l_dummy := Pre_Insert_Child
        (  l_csp_inv_loc_assignment
          ,l_resource_id
        );
    ELSE
    /*** Update ! ***/
      OPEN c_retreive_org_name( l_csp_inv_loc_assignment );
      FETCH c_retreive_org_name INTO r_retreive_org_name;
      IF NOT c_retreive_org_name%NOTFOUND THEN
        CSL_CSP_SEC_INV_ACC_PKG.Update_CSP_Sec_Inventory(
                                   l_resource_id ,
                                   r_retreive_org_name.subinventory_code ,
                                   r_retreive_org_name.organization_id);

        Update_ACC_Record
          ( l_csp_inv_loc_assignment
           , l_resource_id
           , l_acc_id
           );

      END IF;
      CLOSE c_retreive_org_name;
    END IF;
  ELSE

/***  ??????????????????????????????????? ***/
  /*** record should not be replicated ***/
    IF l_acc_id > -1 THEN
      /*** record exists on mobile but should not be replicated anymore -> delete from mobile ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( l_csp_inv_loc_assignment
        , g_table_name
        , 'Inventory Location Assignment was replicated before update, but should not be replicated anymore.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      Post_Delete_Child
      ( l_csp_inv_loc_assignment
       ,l_resource_id);
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Leaving POST_UPDATE hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_INV_LOC_ASS_ACC_PKG','POST_UPDATE_INV_LOC_ASSIGNMENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_INV_LOC_ASSIGNMENT;

/* Called before assignment Delete */
PROCEDURE PRE_DELETE_INV_LOC_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
  l_resource_id        NUMBER;
  l_csp_inv_loc_assignment NUMBER;
  l_enabled_flag VARCHAR2(30);
BEGIN
  l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP( P_APP_SHORT_NAME => 'CSL' );
  IF l_enabled_flag <> 'Y' THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
  END IF;
  /*** get assignment record details from public API ***/
  l_csp_inv_loc_assignment := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID;
  l_resource_id            := CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.RESOURCE_ID;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Entering PRE_DELETE hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** yes -> delete assignment related data from the ACC tables ***/
  Post_Delete_Child
  ( l_csp_inv_loc_assignment
   ,l_resource_id);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Leaving PRE_DELETE hook'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => l_csp_inv_loc_assignment
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in PRE_DELETE hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_INV_LOC_ASS_ACC_PKG','PRE_DELETE_INV_LOC_ASSIGNMENT',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_INV_LOC_ASSIGNMENT;

/* Called after assignment Delete */
PROCEDURE POST_DELETE_INV_LOC_ASSIGNMENT
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_INV_LOC_ASSIGNMENT;

/* Remove all ACC records of a mobile user */
PROCEDURE Delete_All_ACC_Records
  ( p_resource_id in NUMBER
  , x_return_status OUT NOCOPY varchar2
  )
IS

  CURSOR c_csp_inv_loc_assignment (b_resource_id NUMBER) IS
   SELECT *
   FROM jtm_csp_inv_loc_ass_acc
   WHERE RESOURCE_ID = b_resource_id;
  r_csp_inv_loc_assignment c_csp_inv_loc_assignment%ROWTYPE;

--  l_return_value VARCHAR2(2000) := FND_API.G_RET_STS_ERROR;
  l_return_value VARCHAR2(2000) := FND_API.G_RET_STS_SUCCESS;
  l_dummy BOOLEAN;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.GET_DEBUG_LEVEL;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Delete_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Delete all Inventory Location Assignemts acc records for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  OPEN c_csp_inv_loc_assignment( p_resource_id );
  FETCH c_csp_inv_loc_assignment INTO r_csp_inv_loc_assignment;
  IF c_csp_inv_loc_assignment%NOTFOUND THEN
   IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_resource_id
    , v_object_name => g_table_name
    , v_message     => 'There are no rows returned for user : ' || p_resource_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
   END IF;
  ELSE
    WHILE c_csp_inv_loc_assignment%FOUND LOOP
      Post_Delete_Child
          ( r_csp_inv_loc_assignment.csp_inv_loc_assignment_id
          , p_resource_id
          );
      FETCH c_csp_inv_loc_assignment INTO r_csp_inv_loc_assignment;
    END LOOP;
  END IF;
  CLOSE c_csp_inv_loc_assignment;

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
  ( p_resource_id IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  )
IS

  CURSOR c_csp_inv_loc_assignment (b_resource_id NUMBER) IS
   SELECT *
   FROM CSP_INV_LOC_ASSIGNMENTS
   WHERE RESOURCE_ID = b_resource_id
   AND RESOURCE_TYPE = 'RS_EMPLOYEE' ;

  r_csp_inv_loc_assignment c_csp_inv_loc_assignment%ROWTYPE;

--  l_return_value VARCHAR2(2000) := FND_API.G_RET_STS_ERROR;
  l_return_value VARCHAR2(2000) := FND_API.G_RET_STS_SUCCESS;
  l_dummy BOOLEAN;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.GET_DEBUG_LEVEL;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering Insert_All_ACC_Records procedure for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Insert all Inventory Location Assignments acc records for user: ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Insert all of the ACC Records of Requirement Lines ***/

  IF JTM_HOOK_UTIL_PKG.isMobileFSresource( p_resource_id ) THEN
    /*** Retreive record assigned by Hook ***/
    OPEN c_csp_inv_loc_assignment( p_resource_id );
    FETCH c_csp_inv_loc_assignment INTO r_csp_inv_loc_assignment;
    IF c_csp_inv_loc_assignment%NOTFOUND THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_resource_id
        , v_object_name => g_table_name
        , v_message     => 'There are no rows returned for user : ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    ELSE
      WHILE c_csp_inv_loc_assignment%FOUND LOOP
        l_dummy := Pre_Insert_Child
             ( r_csp_inv_loc_assignment.csp_inv_loc_assignment_id
             , p_resource_id
             );
        FETCH c_csp_inv_loc_assignment INTO r_csp_inv_loc_assignment;
      END LOOP;
    END IF;
    CLOSE c_csp_inv_loc_assignment;
    l_return_value := FND_API.G_RET_STS_SUCCESS;
  ELSE
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
       ( v_object_id   => p_resource_id
       , v_object_name => g_table_name
       , v_message     => 'User with resource id : ' || p_resource_id || ' is not a Mobile User.'
       , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  END IF;

  x_return_status := l_return_value;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_HEADERS_ACC_PKG','Insert_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END Insert_All_ACC_Records;

END CSL_CSP_INV_LOC_ASS_ACC_PKG;

/
