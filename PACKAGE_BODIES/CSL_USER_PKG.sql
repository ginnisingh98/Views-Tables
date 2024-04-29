--------------------------------------------------------
--  DDL for Package Body CSL_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_USER_PKG" AS
/* $Header: cslmupb.pls 120.0 2005/05/25 11:04:49 appldev noship $ */

/*** Globals ***/
g_debug_level NUMBER;
g_table_name  VARCHAR2(30) := 'CSL_USER_PKG';

/* Put all create_user procedures here */
PROCEDURE CREATE_USER( p_resource_id IN NUMBER
                     , x_return_status OUT NOCOPY VARCHAR2 ) IS
CURSOR c_user( b_resource_id NUMBER ) IS
 SELECT USER_ID
 FROM JTF_RS_RESOURCE_EXTNS
 WHERE RESOURCE_ID = b_resource_id;
r_user NUMBER;
BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Entering CREATE_USER'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
 END IF;

 /* First delete all ancient records*/
 DELETE_USER( p_resource_id, x_return_status );

 /* Because we delete also resource and user we need to recreate those records*/
 OPEN c_user(P_RESOURCE_ID );
 FETCH c_user INTO r_user;
 IF c_user%FOUND THEN
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => JTM_HOOK_UTIL_PKG.t_publication_item_list('FND_USER')
   ,P_ACC_TABLE_NAME         => 'JTM_FND_USER_ACC'
   ,P_PK1_NAME               => 'USER_ID'
   ,P_PK1_NUM_VALUE          => r_user
   ,P_RESOURCE_ID            => P_RESOURCE_ID
   );
 END IF;
 CLOSE c_user;

  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => JTM_HOOK_UTIL_PKG.t_publication_item_list('JTF_RS_RESOURCE_EXTNS')
   ,P_ACC_TABLE_NAME         => 'JTM_JTF_RS_RESOURCE_EXTNS_ACC'
   ,P_PK1_NAME               => 'RESOURCE_PK'
   ,P_PK1_NUM_VALUE          => P_RESOURCE_ID
   ,P_RESOURCE_ID            => P_RESOURCE_ID
   );

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_JTF_TASK_ASS_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_JTF_TASK_ASS_ACC_PKG.INSERT_ALL_ACC_RECORDS( p_resource_id, x_return_status  );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 /*** insert SRs created by mobile resource ***/
 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_CS_INCIDENTS_ALL_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_CS_INCIDENTS_ALL_ACC_PKG.INSERT_ALL_ACC_RECORDS
  ( p_resource_id
  , x_return_status );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 /*** insert tasks created by mobile resource ***/
 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_JTF_TASKS_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_JTF_TASKS_ACC_PKG.INSERT_ALL_ACC_RECORDS
  ( p_resource_id
  , x_return_status );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_CSP_INV_LOC_ASS_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_CSP_INV_LOC_ASS_ACC_PKG.INSERT_ALL_ACC_RECORDS( p_resource_id, x_return_status  );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_CSP_LOCATIONS_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_CSP_LOCATIONS_ACC_PKG.INSERT_ALL_ACC_RECORDS( p_resource_id, x_return_status  );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_CSP_REQ_HEADERS_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_CSP_REQ_HEADERS_ACC_PKG.INSERT_ALL_ACC_RECORDS( p_resource_id, x_return_status  );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_CSP_REQ_LINES_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_CSP_REQ_LINES_ACC_PKG.INSERT_ALL_ACC_RECORDS( p_resource_id, x_return_status  );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_WF_NOTIFICATION_AT_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_WF_NOTIFICATION_AT_ACC_PKG.INSERT_ALL_ACC_RECORDS( p_resource_id, x_return_status  );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_JTF_RS_GRP_MEM_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_JTF_RS_GRP_MEM_ACC_PKG.INSERT_ALL_ACC_RECORDS( p_resource_id, x_return_status  );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_MTL_SYSTEM_ITEMS_ACC_PKG.INSERT_ALL_ACC_RECORDS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_MTL_SYSTEM_ITEMS_ACC_PKG.INSERT_ALL_ACC_RECORDS( p_resource_id, x_return_status );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
 END IF;

 /*Call Concurrent programs ( always after hook packages because of dependencies )*/

 /*** fix for bug 2457810 (deadlock issue), now doing commit before running autonomous inserts ***/
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_MTL_ONHAND_QTY_ACC_PKG.REFRESH_ONHAND_QTY'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_MTL_ONHAND_QTY_ACC_PKG.REFRESH_ONHAND_QTY;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_JTF_TASK_REFS_ACC_PKG.CON_REQUEST_TASK_REFERENCES'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_JTF_TASK_REFS_ACC_PKG.CON_REQUEST_TASK_REFERENCES;

 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Calling CSL_MTL_SERIAL_NUMBERS_ACC_PKG.INSERT_SERIAL_NUMBERS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
 END IF;
 CSL_MTL_SERIAL_NUMBERS_ACC_PKG.INSERT_SERIAL_NUMBERS(p_resource_id);

 COMMIT;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Leaving CREATE_USER'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
 END IF;

 x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
  /*** api call failed -> rolback and log error ***/
  ROLLBACK ;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Exception occurred in CREATE_USER when calling API'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_USER_PKG','CREATE_USER','API error');
  x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN OTHERS THEN
  /*** uncaught exception -> rollback and log sql error ***/
  ROLLBACK;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Caught exception in CREATE_USER:' || fnd_global.local_chr(10) || sqlerrm
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg('CSL_USER_PKG','CREATE_USER',sqlerrm);
  x_return_status := FND_API.G_RET_STS_ERROR;
END CREATE_USER;

/* Put all delete_user procedures here */
/* TODO add jtf_RS_resource_EXTNS and JTF_group_members and fnd_user*/
PROCEDURE DELETE_USER( p_resource_id IN NUMBER
                     , x_return_status OUT NOCOPY VARCHAR2 ) IS
BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Entering DELETE_USER'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
   , 'csl_user_pkg');
 END IF;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_CONTR_BUSS_PROCESSES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_CONTR_BUSS_PROCESSES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_CONTR_BUSS_TXN_TYPES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_CONTR_BUSS_TXN_TYPES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_CSI_ITEM_INSTANCES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_CSI_ITEM_INSTANCES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_CS_INCIDENTS_ALL_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_CS_INCIDENTS_ALL_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_CS_HZ_SR_CONTACT_PTS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_CS_HZ_SR_CONTACT_PTS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_HZ_CONTACT_POINTS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_HZ_CONTACT_POINTS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_HZ_CUST_ACCT_SITES_ALL_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_HZ_CUST_ACCT_SITES_ALL_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_HZ_CUST_SITE_USES_ALL_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_HZ_CUST_SITE_USES_ALL_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_HZ_LOCATIONS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_HZ_LOCATIONS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;


 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_HZ_PARTIES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_HZ_PARTIES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_HZ_PARTY_SITES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_HZ_PARTY_SITES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_HZ_RELATIONSHIPS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_HZ_RELATIONSHIPS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_JTF_TASKS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_JTF_TASKS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_JTF_TASK_ASS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_JTF_TASK_ASS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_MTL_ONHAND_QTY_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_MTL_ONHAND_QTY_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_SR_CONTRACT_HEADERS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_SR_CONTRACT_HEADERS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CSF_DEBRIEF_HEADERS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CSF_DEBRIEF_HEADERS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CSF_DEBRIEF_LINES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CSF_DEBRIEF_LINES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CSP_INV_LOC_ASS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CSP_INV_LOC_ASS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CSP_REQ_HEADERS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CSP_REQ_HEADERS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CSP_REQ_LINES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CSP_REQ_LINES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CSP_RS_CUST_RELATIONS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CSP_RS_CUST_RELATIONS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CSP_SEC_INV_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CSP_SEC_INV_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;


 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CS_COUNTERS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CS_COUNTERS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CS_COUNTER_GROUPS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CS_COUNTER_GROUPS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CS_COUNTER_PROPS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CS_COUNTER_PROPS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CS_COUNTER_PROP_VALS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CS_COUNTER_PROP_VALS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_CS_COUNTER_VALUES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_CS_COUNTER_VALUES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_JTF_NOTES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_JTF_NOTES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_JTF_TASK_REFERENCES_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_JTF_TASK_REFERENCES_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_MTL_SEC_INV_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_MTL_SEC_INV_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_MTL_SERIAL_NUMBERS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_MTL_SERIAL_NUMBERS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_MTL_SYSTEM_ITEMS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_MTL_SYSTEM_ITEMS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_RESOURCE_INVENTORY_ORG for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_RESOURCE_INVENTORY_ORG
 WHERE RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_MTL_TRANS_LOT_NUM_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_MTL_TRANS_LOT_NUM_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_MTL_UNIT_TRANS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_MTL_UNIT_TRANS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_OE_ORDER_HEADERS_ALL_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_OE_ORDER_HEADERS_ALL_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_OE_ORDER_LINES_ALL_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_OE_ORDER_LINES_ALL_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_PER_ALL_PEOPLE_F_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_PER_ALL_PEOPLE_F_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_PO_LOC_ASS_ALL_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_PO_LOC_ASS_ALL_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_WF_NOTIFICATIONS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_WF_NOTIFICATIONS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_WF_NOTIFICATION_AT_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_WF_NOTIFICATION_AT_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_FND_USER_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_FND_USER_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_JTF_RS_RESOURCE_EXTNS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_JTF_RS_RESOURCE_EXTNS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from JTM_JTF_RS_GROUP_MEMBERS_ACC for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE JTM_JTF_RS_GROUP_MEMBERS_ACC
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Delete from CSL_SERVICE_HISTORY for resource '||p_resource_id
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
   , 'csl_user_pkg');
 END IF;
 DELETE CSL_SERVICE_HISTORY
 WHERE  RESOURCE_ID = p_resource_id;
 COMMIT;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Leaving DELETE_USER'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
   , 'csl_user_pkg');
 END IF;

 x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
  /*** api call failed -> rolback and log error ***/
  ROLLBACK;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Exception occurred in DELETE_USER when calling API'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_user_pkg');
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_USER_PKG','DELETE_USER','API error');
  x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN OTHERS THEN
  /*** uncaught exception -> rollback and log sql error ***/
  ROLLBACK;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Caught exception in DELETE_USER:' || fnd_global.local_chr(10) || sqlerrm
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_user_pkg');
  END IF;

  fnd_msg_pub.Add_Exc_Msg('CSL_USER_PKG','DELETE_USER',sqlerrm);
  x_return_status := FND_API.G_RET_STS_ERROR;
END DELETE_USER;

END CSL_USER_PKG;

/
