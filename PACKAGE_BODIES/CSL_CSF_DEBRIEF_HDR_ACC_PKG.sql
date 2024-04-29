--------------------------------------------------------
--  DDL for Package Body CSL_CSF_DEBRIEF_HDR_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CSF_DEBRIEF_HDR_ACC_PKG" AS
/* $Header: csldhacb.pls 115.8 2003/08/28 10:15:24 vekrishn ship $ */

  /*** Globals ***/
  g_acc_table_name        CONSTANT VARCHAR2(30)
                               := 'JTM_CSF_DEBRIEF_HEADERS_ACC';
  g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
   JTM_HOOK_UTIL_PKG.t_publication_item_list('CSF_DEBRIEF_HEADERS');
  g_table_name            CONSTANT VARCHAR2(30) := 'CSF_DEBRIEF_HEADERS';
  g_pk1_name              CONSTANT VARCHAR2(30) := 'DEBRIEF_HEADER_ID';

  g_debug_level           NUMBER;  -- debug level


  /*** Function that retrieves resource_id for a given debrief_line_id.
   ***/

  FUNCTION Get_Resource_Id( p_debrief_header_id NUMBER )
  RETURN NUMBER
  IS
    CURSOR c_resource ( b_debrief_header_id NUMBER)
    IS
     SELECT resource_id
     FROM   jtf_task_assignments jta
     ,      csf_debrief_headers  dbh
     WHERE  jta.task_assignment_id = dbh.task_assignment_id
     AND    dbh.debrief_header_id  = b_debrief_header_id;
     r_resource c_resource%ROWTYPE;
  BEGIN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Entering Get_Resource_Id function'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    OPEN c_resource( p_debrief_header_id );
    FETCH c_resource INTO r_resource;
    CLOSE c_resource;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Leaving Get_Resource_Id function'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    RETURN r_resource.resource_id;
  END Get_Resource_Id;


  /*** Function that checks if debrief line should be replicated. Returns
       TRUE if it should ***/

  FUNCTION Replicate_Record
  ( p_debrief_header_id NUMBER
  )
  RETURN BOOLEAN
  IS
    CURSOR c_debrief_header (b_debrief_header_id NUMBER) IS
     SELECT *
     FROM CSF_DEBRIEF_HEADERS
     WHERE debrief_header_id = b_debrief_header_id;
    r_debrief_header c_debrief_header%ROWTYPE;

  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Entering Replicate_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    OPEN c_debrief_header( p_debrief_header_id );
    FETCH c_debrief_header INTO r_debrief_header;
    IF c_debrief_header%NOTFOUND THEN
      /*** could not find debrief_header record -> exit ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
        jtm_message_log_pkg.Log_Msg
        ( p_debrief_header_id
        , g_table_name
        , 'Replicate_Record error: Could not find debrief_header_id ' ||
          p_debrief_header_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CLOSE c_debrief_header;
      RETURN FALSE;
    END IF;
    CLOSE c_debrief_header;

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Replicate_Record returned TRUE'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /** Record matched criteria -> return true ***/
    RETURN TRUE;
  END Replicate_Record;


  /*** Private procedure that replicates given debrief header related data
       for resource ***/
  PROCEDURE Insert_ACC_Record
    ( p_debrief_header_id   IN NUMBER
     ,p_resource_id         IN NUMBER
    )
  IS
  BEGIN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Entering Insert_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Inserting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** Insert debrief header ACC record ***/
    JTM_HOOK_UTIL_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      ,P_ACC_TABLE_NAME         => g_acc_table_name
      ,P_PK1_NAME               => g_pk1_name
      ,P_PK1_NUM_VALUE          => p_debrief_header_id
      ,P_RESOURCE_ID            => p_resource_id
     );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Leaving Insert_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END Insert_ACC_Record;


  /*** Private procedure that re-sends given debrief header to mobile ***/
  PROCEDURE Update_ACC_Record
    ( p_debrief_header_id          IN NUMBER
     ,p_resource_id                IN NUMBER
     ,p_acc_id                     IN NUMBER
    )
  IS
  BEGIN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Entering Update_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Updating ACC record for resource_id = ' || p_resource_id
        || fnd_global.local_chr(10) || 'access_id = ' || p_acc_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** Update debrief header ACC record ***/
    JTM_HOOK_UTIL_PKG.Update_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      ,P_ACC_TABLE_NAME         => g_acc_table_name
      ,P_RESOURCE_ID            => p_resource_id
      ,P_ACCESS_ID              => p_acc_id
     );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Leaving Update_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END Update_ACC_Record;


  /*** Private procedure that deletes debrief line for resource from acc
       table ***/

  PROCEDURE Delete_ACC_Record
    ( p_debrief_header_id   IN NUMBER
     ,p_resource_id         IN NUMBER
    )
  IS
  BEGIN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Entering Delete_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Deleting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** Delete debrief header ACC record ***/
    JTM_HOOK_UTIL_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      ,P_ACC_TABLE_NAME         => g_acc_table_name
      ,P_PK1_NAME               => g_pk1_name
      ,P_PK1_NUM_VALUE          => p_debrief_header_id
      ,P_RESOURCE_ID            => p_resource_id
     );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Leaving Delete_ACC_Record'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END Delete_ACC_Record;


  /*** Public function that gets called when a debrief header needs to be
       inserted into ACC table.  ***/

  PROCEDURE Insert_Debrief_Header
    ( p_debrief_header_id   IN NUMBER
     ,p_resource_id         IN NUMBER
    )
  IS
    l_acc_id           NUMBER;
    l_success          BOOLEAN;
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Entering Insert_Debrief_Header procedure'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** does record match criteria? ***/
    IF Replicate_Record( p_debrief_header_id ) THEN
      /*** yes -> insert debrief header acc record ***/
      Insert_ACC_Record
      ( p_debrief_header_id
       ,p_resource_id
      );

    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Leaving Insert_Debrief_Header procedure'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  END Insert_Debrief_Header;


  /*** Public function that gets called when a debrief header needs to
       be updated into ACC table.  ***/

  PROCEDURE Update_Debrief_Header
    ( p_debrief_header_id   IN NUMBER
     ,p_resource_id         IN NUMBER
    )
  IS
    l_acc_id           NUMBER;
    l_success          BOOLEAN;
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Entering Update_Debrief_Header procedure'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id(
                     P_ACC_TABLE_NAME => g_acc_table_name
                    ,P_PK1_NAME       => g_pk1_name
                    ,P_PK1_NUM_VALUE  => p_debrief_header_id
                    ,P_RESOURCE_ID    => p_resource_id);

    /*** is record already in ACC table? ***/
    l_success := FALSE;
    IF l_acc_id = -1 THEN
      /*** yes -> return TRUE ***/
      l_success := TRUE;
    ELSE
      /*** no -> does record match criteria? ***/
      IF Replicate_Record( p_debrief_header_id ) THEN
        /*** yes -> update debrief header acc record ***/
        Update_ACC_Record
        ( p_debrief_header_id
         ,p_resource_id
         ,l_acc_id
        );

      END IF;
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Leaving Update_Debrief_Header procedure'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

  END Update_Debrief_Header;


  /*** Public procedure that gets called when a debrief header needs to
       be deleted from ACC table.  ***/

  PROCEDURE Delete_Debrief_Header
    ( p_debrief_header_id   IN NUMBER
     ,p_resource_id         IN NUMBER
    )
  IS
    l_acc_id           NUMBER;
    l_success          BOOLEAN;
  BEGIN
    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Entering Delete_Debrief_Header'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id(
                     P_ACC_TABLE_NAME => g_acc_table_name
                    ,P_PK1_NAME       => g_pk1_name
                    ,P_PK1_NUM_VALUE  => p_debrief_header_id
                    ,P_RESOURCE_ID    => p_resource_id);


    /*** is record already in ACC table? ***/
    IF l_acc_id <> -1 THEN
      /*** yes -> delete debrief header acc record ***/
      Delete_ACC_Record
      ( p_debrief_header_id
       ,p_resource_id
      );

    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( p_debrief_header_id
      , g_table_name
      , 'Leaving Delete_Debrief_Header'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END Delete_Debrief_Header;


  /** User Hooks Callout Procedure */

  /* Called before debrief_header Insert */
  PROCEDURE PRE_INSERT_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  )
  IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END PRE_INSERT_DEBRIEF_HEADER;


  /* Called after debrief_header Insert */
  PROCEDURE POST_INSERT_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  )
  IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END POST_INSERT_DEBRIEF_HEADER;


  /* Called before debrief_header Update */
  PROCEDURE PRE_UPDATE_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  )
  IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END PRE_UPDATE_DEBRIEF_HEADER;


  /* Called after debrief_header Update */
  PROCEDURE POST_UPDATE_DEBRIEF_HEADER (
     x_return_status out NOCOPY varchar2
    ) IS

    l_enabled_flag      VARCHAR2(30);
    l_debrief_header_id csf_debrief_headers.debrief_header_id%TYPE;
    l_resource_id       NUMBER;
    l_replicate         BOOLEAN;

  BEGIN

    l_enabled_flag := JTM_PROFILE_UTL_PKG.GET_ENABLE_FLAG_AT_RESP
                       ( P_APP_SHORT_NAME => 'CSL' );

    IF l_enabled_flag <> 'Y' THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    /*** get debug level ***/
    g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

    /*** get debrief_header record details from public API ***/
    l_debrief_header_id :=
             CSF_DEBRIEF_Headers_PKG.user_hooks_rec.debrief_header_id;
    l_resource_id := Get_Resource_Id( l_debrief_header_id );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( l_debrief_header_id
      , g_table_name
      , 'Entering POST_UPDATE hook'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Check if debrief_line after update matches criteria ***/
    IF JTM_HOOK_UTIL_PKG.isMobileFSresource( l_resource_id ) THEN
      Update_Debrief_Header(l_debrief_header_id, l_resource_id);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END POST_UPDATE_DEBRIEF_HEADER;


  /* Called before debrief_header delete */
  PROCEDURE PRE_DELETE_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  )
  IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END PRE_DELETE_DEBRIEF_HEADER;



END CSL_CSF_DEBRIEF_HDR_ACC_PKG;

/
