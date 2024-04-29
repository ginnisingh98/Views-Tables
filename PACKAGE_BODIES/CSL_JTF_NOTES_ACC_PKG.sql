--------------------------------------------------------
--  DDL for Package Body CSL_JTF_NOTES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_JTF_NOTES_ACC_PKG" AS
/* $Header: cslntacb.pls 120.0 2005/05/24 17:15:41 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_JTF_NOTES_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
   JTM_HOOK_UTIL_PKG.t_publication_item_list('JTF_NOTES_VL');
g_table_name            CONSTANT VARCHAR2(30) := 'JTF_NOTES_B';
g_pk_name               CONSTANT VARCHAR2(30) := 'JTF_NOTE_ID';

g_debug_level           NUMBER;  -- debug level

/*** Function that checks if note should be replicated. Returns TRUE if it should ***/
FUNCTION Replicate_Record
  ( p_jtf_note_id NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_jtf_note (b_jtf_note_id NUMBER) IS
   SELECT *
   FROM JTF_NOTES_B
   WHERE jtf_note_id = b_jtf_note_id;
  r_jtf_note c_jtf_note%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_jtf_note( p_jtf_note_id );
  FETCH c_jtf_note INTO r_jtf_note;
  IF c_jtf_note%NOTFOUND THEN
    /*** could not find jtf_note record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_jtf_note_id
      , g_table_name
      , 'Replicate_Record error: Could not find jtf_note_id ' || p_jtf_note_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_jtf_note;
    RETURN FALSE;
  END IF;
  CLOSE c_jtf_note;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Replicate_Record returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** Record matched criteria -> return true ***/
  RETURN TRUE;
END Replicate_Record;


/*** Public Function that returns the entered by id ***/
FUNCTION Get_User_Id( p_jtf_note_id NUMBER)
RETURN NUMBER
IS
  CURSOR c_jtf_note (b_jtf_note_id NUMBER) IS
   SELECT entered_by
   FROM JTF_NOTES_B
   WHERE jtf_note_id = b_jtf_note_id;
  r_jtf_note c_jtf_note%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Entering Get_User_Id'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_jtf_note( p_jtf_note_id );
  FETCH c_jtf_note INTO r_jtf_note;
  IF c_jtf_note%NOTFOUND THEN
    /*** could not find jtf_note record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_jtf_note_id
      , g_table_name
      , 'Get_User_Id error: Could not find jtf_note_id ' || p_jtf_note_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_jtf_note;
    RETURN -1;
  END IF;
  CLOSE c_jtf_note;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Get_User_Id returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** return the entered by id ***/
  return r_jtf_note.entered_by;
END Get_User_Id;


/*** Public Function that returns the resource extn id ***/
FUNCTION Get_Resource_Extn_Id( p_user_id NUMBER)
RETURN NUMBER
IS
  CURSOR c_jtf_rs_resource_extns (b_user_id NUMBER) IS
   SELECT resource_id
   FROM JTF_RS_RESOURCE_EXTNS
   WHERE user_id = b_user_id;
  r_jtf_rs_resource_extns c_jtf_rs_resource_extns%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Entering Get_Resource_Extn_Id'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_jtf_rs_resource_extns( p_user_id );
  FETCH c_jtf_rs_resource_extns INTO r_jtf_rs_resource_extns;
  IF c_jtf_rs_resource_extns%NOTFOUND THEN
    /*** could not find jtf_rs_resource_extns record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_user_id
      , g_table_name
      , 'Get_Resource_Extn_Id error: Could not find p_user_id ' || p_user_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_jtf_rs_resource_extns;
    RETURN -1;
  END IF;
  CLOSE c_jtf_rs_resource_extns;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_user_id
    , g_table_name
    , 'Get_Resource_Extn_Id returned TRUE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /** return the entered by id ***/
  return r_jtf_rs_resource_extns.resource_id;
END Get_Resource_Extn_Id;

/*** Private procedure that replicates given jtf_note related data for resource ***/
PROCEDURE Insert_ACC_Record
  ( p_jtf_note_id     IN NUMBER
   ,p_resource_id     IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Entering Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Inserting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Insert jtf_note ACC record ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk_name
    ,P_PK1_NUM_VALUE          => p_jtf_note_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Leaving Insert_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_ACC_Record;

/*** Private procedure that re-sends given jtf_note to mobile ***/
PROCEDURE Update_ACC_Record
  ( p_jtf_note_id            IN NUMBER
   ,p_resource_id                IN NUMBER
   ,p_acc_id                     IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Entering Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Updating ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10) || 'access_id = ' || p_acc_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Update jtf_note ACC record ***/
  JTM_HOOK_UTIL_PKG.Update_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_RESOURCE_ID            => p_resource_id
    ,P_ACCESS_ID              => p_acc_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Leaving Update_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_ACC_Record;

/*** Private procedure that deletes jtf_note for resource from acc table ***/
PROCEDURE Delete_ACC_Record
  ( p_jtf_note_id     IN NUMBER
   ,p_resource_id         IN NUMBER
  )
IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Entering Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Deleting ACC record for resource_id = ' || p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** Delete jtf_note ACC record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_PK1_NAME               => g_pk_name
    ,P_PK1_NUM_VALUE          => p_jtf_note_id
    ,P_RESOURCE_ID            => p_resource_id
   );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Leaving Delete_ACC_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_ACC_Record;

/***
  Public function that gets called when a jtf_note needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/
FUNCTION Pre_Insert_Child
  ( p_jtf_note_id     IN NUMBER
   ,p_resource_id     IN NUMBER
  )
RETURN BOOLEAN
IS
  l_acc_id              NUMBER;
  l_user_id             NUMBER;
  l_resource_extn_id    NUMBER;
  l_success             BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Entering Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;


  /*** no -> does record match criteria? ***/
  IF Replicate_Record( p_jtf_note_id ) THEN
    /*** yes -> insert jtf_note acc record ***/
    Insert_ACC_Record
    ( p_jtf_note_id
     ,p_resource_id
    );

    /*** Get the user id ***/
    l_user_id := Get_User_Id( p_jtf_note_id );

    /*** Insert the user ***/
    CSL_FND_USER_ACC_PKG.Insert_User
    ( l_user_id
     ,p_resource_id
    );

    /*** Get the resource id ***/
    l_resource_extn_id := Get_Resource_Extn_Id( l_user_id );

    /*** Insert the resource ext ***/
    /*** Only if resource id is not -1 ***/
    IF l_resource_extn_id > -1 THEN
      CSL_JTF_RESOURCE_EXTNS_ACC_PKG.Insert_Resource_Extns
      ( l_resource_extn_id
       ,p_resource_id
      );
    END IF;

    l_success := TRUE;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Leaving Pre_Insert_Child procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_success;
END Pre_Insert_Child;

/***
  Public function that gets called when jtf_notes needs to be inserted into ACC table.
  Returns TRUE when records already were or have been inserted into ACC table.
***/
FUNCTION Pre_Insert_Children
  ( p_source_obj_id    IN NUMBER
   ,p_source_obj_code  IN VARCHAR2
   ,p_resource_id      IN NUMBER
  )
RETURN BOOLEAN
IS
  CURSOR c_jtf_note (b_source_obj_id   NUMBER,
                     b_source_obj_code VARCHAR2) IS
   SELECT *
   FROM JTF_NOTES_B
   WHERE source_object_id = b_source_obj_id
   AND   source_object_code = b_source_obj_code;
  r_jtf_note c_jtf_note%ROWTYPE;

  l_dummy  BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_source_obj_id
    , g_table_name
    , 'Entering Pre_Insert_Children procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_jtf_note IN c_jtf_note( p_source_obj_id, p_source_obj_code ) LOOP

    /*** Insert record if applicable ***/
    l_dummy := Pre_Insert_Child
      (  r_jtf_note.jtf_note_id
        ,p_resource_id
      );

    IF l_dummy = FALSE THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
        jtm_message_log_pkg.Log_Msg
        ( p_source_obj_id
        , g_table_name
        , 'Pre_Insert_Children:  note was not insertable.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
      END IF;
    END IF;
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_source_obj_id
    , g_table_name
    , 'Leaving Pre_Insert_Children procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN TRUE;
END Pre_Insert_Children;

/***
  Public procedure that gets called when a jtf_note needs to be deleted from the ACC table.
***/
PROCEDURE Post_Delete_Child
  ( p_jtf_note_id     IN NUMBER
   ,p_resource_id     IN NUMBER
  )
IS
  l_acc_id            NUMBER;
  l_user_id           NUMBER;
  l_resource_extn_id  NUMBER;
  l_success           BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Entering Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** no -> delete jtf_note record from ACC ***/
  Delete_ACC_Record
  ( p_jtf_note_id
   ,p_resource_id);

  /*** Get the user id ***/
  l_user_id := Get_User_Id( p_jtf_note_id );

  /*** Delete the user ***/
  CSL_FND_USER_ACC_PKG.Delete_User
  ( l_user_id
   ,p_resource_id
  );

  /*** Get resource id ***/
  l_resource_extn_id := Get_Resource_Extn_Id( l_user_id );

  /*** Delete the resource ext ***/
  /*** Only if resource id is not -1 ***/
  IF l_resource_extn_id > -1 THEN
    CSL_JTF_RESOURCE_EXTNS_ACC_PKG.Delete_Resource_Extns
    ( l_resource_extn_id
     ,p_resource_id
    );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Leaving Post_Delete_Child'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Post_Delete_Child;

/***
  Public procedure that gets called when jtf_notes need to be deleted from the ACC table.
***/
PROCEDURE Post_Delete_Children
  ( p_source_obj_id    IN NUMBER
   ,p_source_obj_code  IN VARCHAR2
   ,p_resource_id      IN NUMBER
  )
IS
  CURSOR c_jtf_note (b_source_obj_id   NUMBER,
                     b_source_obj_code VARCHAR2) IS
   SELECT *
   FROM JTF_NOTES_B
   WHERE source_object_id = b_source_obj_id
   AND   source_object_code = b_source_obj_code;
  r_jtf_note c_jtf_note%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_source_obj_id
    , g_table_name
    , 'Entering Post_Delete_Children procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_jtf_note IN c_jtf_note( p_source_obj_id, p_source_obj_code ) LOOP

    /*** Insert record if applicable ***/
    Post_Delete_Child
    (  r_jtf_note.jtf_note_id
      ,p_resource_id
    );
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_source_obj_id
    , g_table_name
    , 'Leaving Post_Delete_Children procedure'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END Post_Delete_Children;

/* Called before jtf_note Insert */
PROCEDURE PRE_INSERT_NOTES
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_INSERT_NOTES;

/* Called after jtf_note Insert */
PROCEDURE POST_INSERT_NOTES ( p_api_version      IN  NUMBER
                            , p_init_msg_list    IN  VARCHAR2
                            , p_commit           IN  VARCHAR2
                            , p_validation_level IN  NUMBER
                            , x_msg_count        OUT NOCOPY NUMBER
                            , x_msg_data         OUT NOCOPY VARCHAR2
                            , x_return_status    OUT NOCOPY VARCHAR2
                            , p_jtf_note_id      IN  NUMBER )
IS
  l_resource_id      NUMBER;  /* Get from API */
  l_replicate        BOOLEAN;

  CURSOR c_object( b_note_id NUMBER ) IS
   SELECT SOURCE_OBJECT_ID
   ,      SOURCE_OBJECT_CODE
   FROM   JTF_NOTES_B
   WHERE  JTF_NOTE_ID = b_note_id;
  r_object c_object%ROWTYPE;

  CURSOR c_sr( b_id NUMBER ) IS
   SELECT resource_id
   FROM csl_cs_incidents_all_acc
   WHERE incident_id = b_id;

  CURSOR c_task( b_id NUMBER ) IS
   SELECT resource_id
   FROM csl_jtf_tasks_acc
   WHERE task_id = b_id;

  CURSOR c_party( b_id NUMBER ) IS
   SELECT resource_id
   FROM csl_hz_parties_acc
   WHERE party_id = b_id;

  CURSOR c_cp( b_id NUMBER ) IS
   SELECT resource_id
   FROM csl_csi_item_instances_acc
   WHERE instance_id = b_id;

  -- ER 3168529
  CURSOR c_contracts ( b_id NUMBER ) IS
   SELECT resource_id
   FROM CSL_SR_CONTRACT_HEADERS_ACC a,
   CSL_SR_CONTRACT_HEADERS b
   WHERE a.incident_id = b.incident_id
   AND b.contract_service_id = b_id;

  -- ER 3746779
  CURSOR c_debrief( b_id NUMBER ) IS
   SELECT resource_id
   FROM JTM_CSF_DEBRIEF_HEADERS_ACC
   WHERE debrief_header_id = b_id;


BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Entering POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*Get the object type and id of this note*/
  OPEN c_object( p_jtf_note_id );
  FETCH c_object INTO r_object;
  IF c_object%NOTFOUND THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_jtf_note_id
      , g_table_name
      , 'Objects for note '||p_jtf_note_id||' not found'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  ELSE
    l_replicate := FALSE;
    /*Check if whe have the "parent" object of this note*/
    IF r_object.SOURCE_OBJECT_CODE = 'SR' THEN
      /*SR note, so check incident acc table*/
      FOR r_sr IN c_sr( r_object.SOURCE_OBJECT_ID ) LOOP
        l_replicate := Pre_Insert_Child( p_jtf_note_id, r_sr.resource_id );
      END LOOP;
    ELSIF r_object.SOURCE_OBJECT_CODE = 'TASK' THEN
      /*TASK note, so check tasks acc table*/
       FOR r_task IN c_task( r_object.SOURCE_OBJECT_ID ) LOOP
         l_replicate := Pre_Insert_Child( p_jtf_note_id, r_task.resource_id );
       END LOOP;
    ELSIF r_object.SOURCE_OBJECT_CODE = 'PARTY' THEN
      /*PARTY note, so check hz_party acc table*/
      FOR r_party IN c_party( r_object.SOURCE_OBJECT_ID ) LOOP
        l_replicate := Pre_Insert_Child( p_jtf_note_id, r_party.resource_id );
      END LOOP;
    ELSIF r_object.SOURCE_OBJECT_CODE = 'CP' THEN
      /*CP note, so check customer product ( item instance ) acc table*/
      FOR r_cp IN c_cp( r_object.SOURCE_OBJECT_ID ) LOOP
        l_replicate := Pre_Insert_Child( p_jtf_note_id, r_cp.resource_id );
      END LOOP;
    -- ER 3168529 Contract Notes
    ELSIF r_object.SOURCE_OBJECT_CODE = 'OKS_COV_NOTE' THEN
      /* Contract note, so check contract service id */
      FOR r_contracts IN c_contracts( r_object.SOURCE_OBJECT_ID ) LOOP
        l_replicate := Pre_Insert_Child( p_jtf_note_id, r_contracts.resource_id );
      END LOOP;
    -- ER 3746779 Debrief Notes
    ELSIF r_object.SOURCE_OBJECT_CODE = 'SD' THEN
      /* Debrief note, so check debrief header id */
      FOR r_debrief IN c_debrief( r_object.SOURCE_OBJECT_ID ) LOOP
        l_replicate := Pre_Insert_Child( p_jtf_note_id, r_debrief.resource_id );
      END LOOP;
    ELSE
      /*Note is of not supported type*/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
         ( p_jtf_note_id
         , g_table_name
         , 'Source_Object_Code '||r_object.SOURCE_OBJECT_CODE||' is not supported'
         , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF; --g_debug_level
    END IF; -- CODE = SR

    /*** Insert record if applicable ***/
    IF l_replicate = FALSE THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
         jtm_message_log_pkg.Log_Msg
           ( p_jtf_note_id
           , g_table_name
           , 'Note '||p_jtf_note_id||' did not match the criteria to be replicated'||fnd_global.local_chr(10)||
	     'Object id = '||r_object.SOURCE_OBJECT_ID||fnd_global.local_chr(10)||
	     'Object_code = '||r_object.SOURCE_OBJECT_CODE
           , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF; -- g_debug_level
    END IF;  -- l_replicate = FALSE
  END IF; --c_object%NOTFOUND
  CLOSE c_object;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Leaving POST_INSERT hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( p_jtf_note_id
    , g_table_name
    , 'Caught exception in POST_INSERT hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_NOTES_ACC_PKG','POST_INSERT_JTF_NOTES',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_INSERT_NOTES;

/* Called before jtf_note Update */
PROCEDURE PRE_UPDATE_NOTES
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_UPDATE_NOTES;

/* Called after jtf_note Update */
PROCEDURE POST_UPDATE_NOTES ( p_api_version      IN  NUMBER
                            , p_init_msg_list    IN  VARCHAR2
                            , p_commit           IN  VARCHAR2
                            , p_validation_level IN  NUMBER
                            , x_msg_count        OUT NOCOPY NUMBER
                            , x_msg_data         OUT NOCOPY VARCHAR2
                            , x_return_status    OUT NOCOPY VARCHAR2
                            , p_jtf_note_id      IN  NUMBER )
IS

  l_jtf_note_id        NUMBER;
  l_user_id            NUMBER;
  l_resource_extn_id   NUMBER;
  l_replicate          BOOLEAN;

  l_tab_resource_id     dbms_sql.Number_Table;
  l_tab_access_id       dbms_sql.Number_Table;
BEGIN
  l_jtf_note_id :=  p_jtf_note_id;

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_jtf_note_id
    , g_table_name
    , 'Entering POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Check if jtf_note after update matches criteria ***/
  l_replicate := Replicate_Record( l_jtf_note_id );

  /*** replicate record after update? ***/
  IF NOT l_replicate THEN
    /*** yes -> re-send updated jtf_note record to all resources ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( l_jtf_note_id
      , g_table_name
      , 'Note was not replicateable after update.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

  ELSE
    /*** yes -> re-send updated note record to all resources ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( l_jtf_note_id
      , g_table_name
      , 'Note being re-sent to mobile users.'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    /*** get list of resources to whom the record was replicated ***/
    JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
    ( P_ACC_TABLE_NAME  => g_acc_table_name
     ,P_PK1_NAME        => g_pk_name
     ,P_PK1_NUM_VALUE   => l_jtf_note_id
     ,L_TAB_RESOURCE_ID => l_tab_resource_id
     ,L_TAB_ACCESS_ID   => l_tab_access_id
    );

    /*** re-send rec to all resources ***/
    IF l_tab_resource_id.COUNT > 0 THEN

      /*** Get the entered by id ***/
      l_user_id := Get_User_Id( l_jtf_note_id );

      /*** Get the resource id ***/
      l_resource_extn_id := Get_Resource_Extn_Id( l_user_id );

      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP

        /*** is resource a mobile user? ***/
        IF NOT JTM_HOOK_UTIL_PKG.isMobileFSresource( l_tab_resource_id(i) ) THEN
           /*** No -> exit ***/
           IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
             jtm_message_log_pkg.Log_Msg
             ( l_tab_resource_id(i)
             , g_table_name
             , 'POST_UPDATE_DEBRIEF_LINE' || fnd_global.local_chr(10) ||
               'Resource_id ' || l_tab_resource_id(i) || ' is not a mobile user.'
             , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
           END IF;
        ELSE

           Update_ACC_Record
           ( l_jtf_note_id
            ,l_tab_resource_id(i)
            ,l_tab_access_id(i)
           );

        END IF;
      END LOOP;
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_jtf_note_id
    , g_table_name
    , 'Leaving POST_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( l_jtf_note_id
    , g_table_name
    , 'Caught exception in POST_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_JTF_NOTES_ACC_PKG','POST_UPDATE_JTF_NOTES',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_UPDATE_NOTES;

/* Called before jtf_note Delete */
PROCEDURE PRE_DELETE_NOTES
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRE_DELETE_NOTES;

/* Called after jtf_note Delete */
PROCEDURE POST_DELETE_NOTES
  ( x_return_status OUT NOCOPY varchar2
  )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_DELETE_NOTES;

END CSL_JTF_NOTES_ACC_PKG;

/
