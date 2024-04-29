--------------------------------------------------------
--  DDL for Package Body CSL_JTF_TASK_REFS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_JTF_TASK_REFS_ACC_PKG" AS
/* $Header: cslteacb.pls 115.6 2002/11/08 14:01:15 asiegers ship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_JTF_TASK_REFERENCES_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('JTF_TASK_REFERENCES');
g_table_name            CONSTANT VARCHAR2(30) := 'JTF_TASK_REFERENCES_B';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TASK_REFERENCE_ID';
g_debug_level           NUMBER; -- debug level


PROCEDURE CON_REQUEST_TASK_REFERENCES
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 CURSOR c_esc(b_task_id NUMBER, b_resource_id NUMBER, b_last_run_date DATE ) IS
  SELECT jtr.task_reference_id
    FROM jtf_tasks_b           jtb,
         jtf_task_references_b jtr,
         jtf_task_statuses_b   jts
   WHERE jtb.task_id = jtr.task_id
     AND jtb.task_type_id   = 22
     AND jtb.task_status_id = jts.task_status_id
     AND NVL(jts.closed_flag,    'N') <> 'Y'
     AND NVL(jts.completed_flag, 'N') <> 'Y'
     AND NVL(jts.cancelled_flag, 'N') <> 'Y'
     AND jtr.reference_code   = 'ESC'
     AND jtr.object_type_code = 'TASK'
     AND jtb.last_update_date >= NVL(b_last_run_date, jtb.LAST_UPDATE_DATE )
     AND jtr.object_id        = b_task_id
     AND jtr.task_reference_id NOT IN(
         SELECT task_reference_id
	 FROM   jtm_jtf_task_references_acc
	 WHERE  resource_id = b_resource_id );
 r_esc c_esc%ROWTYPE;

 CURSOR c_task IS
  SELECT task_id
  ,      resource_id
  from   csl_jtf_tasks_acc;

 CURSOR c_esc_res IS
  SELECT DISTINCT resource_id
  FROM   jtm_jtf_task_references_acc;

  /*** get the last run date of the concurent program ***/
  CURSOR  c_LastRundate
  IS
    select LAST_RUN_DATE
    from   JTM_CON_REQUEST_DATA
    where  package_name =  'CSL_JTF_TASK_REFS_ACC_PKG'
    AND    procedure_name = 'CON_REQUEST_TASK_REFERENCES';
  r_LastRundate  c_LastRundate%ROWTYPE;
  l_last_rundate DATE;
  l_return_status VARCHAR2(2000);
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering CON_REQUEST_TASK_REFERENCES'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  /*** First retrieve last run date of the conccurent program ***/
  OPEN  c_LastRundate;
  FETCH c_LastRundate  INTO r_LastRundate;
  IF c_LastRundate%NOTFOUND THEN
    /*ERROR package is not seeded*/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
       ( 0
        , g_table_name
        , 'CON_REQUEST_TASK_REFERENCES called but not seeded'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
       );
    END IF;
    CLOSE c_LastRundate;
    ROLLBACK;
    RETURN;
  ELSE
   l_last_rundate := r_LastRundate.last_run_date;
  END IF;
  CLOSE c_LastRundate;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
     , g_table_name
     , 'Updating LAST_RUN_DATE from '||r_LastRundate.LAST_RUN_DATE||' to '||sysdate
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
  END IF;

  /*Update the last run date*/
  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = SYSDATE
  WHERE package_name =  'CSL_JTF_TASK_REFS_ACC_PKG'
  AND   procedure_name = 'CON_REQUEST_TASK_REFERENCES';

  FOR r_task IN c_task LOOP
    /*Get all escaleted tasks not yet in the acc table*/
    OPEN c_esc( r_task.task_id, r_task.resource_id, l_last_rundate );
    FETCH c_esc INTO r_esc;
    IF c_esc%FOUND THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( r_esc.task_reference_id
        , g_table_name
        , 'Inserting escalation '||r_esc.task_reference_id||' for resource '||r_task.resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        );
      END IF;

      JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
        ,P_ACC_TABLE_NAME         => g_acc_table_name
        ,P_RESOURCE_ID            => r_task.resource_id
        ,P_PK1_NAME               => g_pk1_name
        ,P_PK1_NUM_VALUE          => r_esc.task_reference_id
       );
     END IF;
     CLOSE c_esc;
  END LOOP;

  /*Delete all escaltions that are closed or no longer assigned to a mobile resource*/
  FOR r_esc_res IN c_esc_res LOOP
    DELETE_ALL_ACC_RECORDS( r_esc_res.resource_id, l_return_status );
  END LOOP;

  COMMIT;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving CON_REQUEST_TASK_REFERENCES'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'CON_REQUEST_TASK_REFERENCES'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  ROLLBACK;
  RETURN;
END CON_REQUEST_TASK_REFERENCES;

PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id   IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 )
IS
 CURSOR c_no_esc ( b_resource_id NUMBER ) IS
  SELECT task_reference_id
  FROM   jtm_jtf_task_references_acc
  WHERE  resource_id = b_resource_id
  AND    task_reference_id NOT IN(
   SELECT jtr.task_reference_id
    FROM jtf_tasks_b           jtb,
         jtf_task_references_b jtr,
         jtf_task_statuses_b   jts
   WHERE jtb.task_id = jtr.task_id
     AND jtb.task_type_id   = 22
     AND jtb.task_status_id = jts.task_status_id
     AND NVL(jts.closed_flag,    'N') <> 'Y'
     AND NVL(jts.completed_flag, 'N') <> 'Y'
     AND NVL(jts.cancelled_flag, 'N') <> 'Y'
     AND jtr.reference_code   = 'ESC'
     AND jtr.object_type_code = 'TASK'
     AND jtr.object_id        IN (
      SELECT task_id
      from   csl_jtf_tasks_acc));
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering DELETE_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  FOR r_no_esc IN c_no_esc( p_resource_id ) LOOP
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( r_no_esc.task_reference_id
      , g_table_name
      , 'Removing escalation '||r_no_esc.task_reference_id||' for resource '||p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      );
    END IF;
    JTM_HOOK_UTIL_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
      ,P_ACC_TABLE_NAME         => g_acc_table_name
      ,P_RESOURCE_ID            => p_resource_id
      ,P_PK1_NAME               => g_pk1_name
      ,P_PK1_NUM_VALUE          => r_no_esc.task_reference_id
     );
  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving DELETE_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;
EXCEPTION
 WHEN OTHERS THEN
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'CON_REQUEST_TASK_REFERENCES'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  ROLLBACK;
  RAISE;
END DELETE_ALL_ACC_RECORDS;

END CSL_JTF_TASK_REFS_ACC_PKG;

/
