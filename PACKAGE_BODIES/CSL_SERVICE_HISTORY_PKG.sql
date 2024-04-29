--------------------------------------------------------
--  DDL for Package Body CSL_SERVICE_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_SERVICE_HISTORY_PKG" AS
/* $Header: cslsrhib.pls 115.7 2004/05/10 06:42:37 utekumal ship $ */

/*** Globals ***/
g_debug_level NUMBER;
g_table_name            CONSTANT VARCHAR2(30) := 'CSL_SERVICE_HISTORY_PKG';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_SERVICE_HISTORY');
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_SERVICE_HISTORY';
g_pk1_name              CONSTANT VARCHAR2(30) := 'INCIDENT_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'HISTORY_INCIDENT_ID';


PROCEDURE INSERT_MAPPING_RECORD( p_incident_id NUMBER
                               , p_history_id  NUMBER
                               , p_resource_id NUMBER )
IS
BEGIN
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Entering INSERT_MAPPING_RECORD for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;

 JTM_HOOK_UTIL_PKG.Insert_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_RESOURCE_ID            => p_resource_id
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_incident_id
    ,P_PK2_NAME               => g_pk2_name
    ,P_PK2_NUM_VALUE          => p_history_id
   );

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Leaving INSERT_MAPPING_RECORD for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;
EXCEPTION WHEN OTHERS THEN
 jtm_message_log_pkg.Log_Msg( null
  , g_table_name
  , 'Exception in CSL_SERVICE_HISTORY_PKG.INSERT_MAPPING_RECORD for incident '||p_incident_id||
    ' and resource '||p_resource_id || ':' || fnd_global.local_chr(10) || sqlerrm
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
  , 'csl_service_history_pkg');
 RAISE;
END INSERT_MAPPING_RECORD;

PROCEDURE DELETE_MAPPING_RECORD( p_incident_id NUMBER
                               , p_history_id  NUMBER
                               , p_resource_id NUMBER )
IS
BEGIN
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Entering DELETE_MAPPING_RECORD for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;

 JTM_HOOK_UTIL_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_RESOURCE_ID            => p_resource_id
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_incident_id
    ,P_PK2_NAME               => g_pk2_name
    ,P_PK2_NUM_VALUE          => p_history_id
   );

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Leaving DELETE_MAPPING_RECORD for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;
EXCEPTION WHEN OTHERS THEN
 jtm_message_log_pkg.Log_Msg( null
  , g_table_name
  , 'Exception in CSL_SERVICE_HISTORY_PKG.DELETE_MAPPING_RECORD for incident '||p_incident_id||
    ' and resource '||p_resource_id||':'|| fnd_global.local_chr(10) || sqlerrm
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
  , 'csl_service_history_pkg');
 RAISE;
END DELETE_MAPPING_RECORD;

/*** Function to retreive the amount of history records***/
FUNCTION GET_HISTORY_COUNT( p_resource_id IN NUMBER )
RETURN NUMBER
IS
 l_max_count NUMBER;
 l_profile_value NUMBER;
 CURSOR c_responsibilities( b_resource_id NUMBER ) IS
  SELECT fur.USER_ID
  ,      fur.RESPONSIBILITY_ID
  ,      fur.RESPONSIBILITY_APPLICATION_ID
  FROM   FND_USER_RESP_GROUPS fur
  ,      ASG_USER             au
  WHERE  au.RESOURCE_ID = b_resource_id
  AND    au.USER_ID = fur.USER_ID
  AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(fur.start_date,sysdate))
                            AND TRUNC(NVL(fur.end_date,sysdate));

BEGIN
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Entering GET_HISTORY_COUNT for resource '||p_resource_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;
 /*If multiple values can be gotton from the profile the maximum value will be returned
   Leading is the profile order of user ->resp -> appl -> site so it basicly only counts
   for responsibility for the highest value
   */
 l_max_count := 0;
 FOR r_resp IN c_responsibilities( p_resource_id ) LOOP
   l_profile_value := TO_NUMBER(
                       FND_PROFILE.VALUE_SPECIFIC(NAME              => 'JTM_HISTORY_COUNT',
                                                  USER_ID           => r_resp.USER_ID ,
                                                  RESPONSIBILITY_ID => r_resp.RESPONSIBILITY_ID ,
                                                  APPLICATION_ID    => r_resp.RESPONSIBILITY_APPLICATION_ID ));
   IF l_profile_value > l_max_count THEN
    l_max_count := l_profile_value;
   END IF;
 END LOOP;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Leaving GET_HISTORY_COUNT for for resource '||p_resource_id||
    ' with value '||l_max_count
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;
 RETURN l_max_count;
EXCEPTION WHEN OTHERS THEN
 jtm_message_log_pkg.Log_Msg( null
  , g_table_name
  , 'Exception in CSL_SERVICE_HISTORY_PKG.GET_HISTORY_COUNT for resource '||p_resource_id||':'
    || fnd_global.local_chr(10) || sqlerrm
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
  , 'csl_service_history_pkg');
 RETURN 0;
END GET_HISTORY_COUNT;

PROCEDURE DELETE_HISTORY_SR_RECORD( p_incident_id NUMBER
                                  , p_history_id  NUMBER
                                  , p_resource_id NUMBER )
IS
 CURSOR c_closed_tasks( b_incident_id NUMBER )IS
   SELECT tk.TASK_ID
   FROM JTF_TASKS_B tk
   ,    JTF_TASK_STATUSES_B ts
   WHERE tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
   AND   tk.SOURCE_OBJECT_ID = b_incident_id
   AND   tk.TASK_STATUS_ID = ts.TASK_STATUS_ID
   AND   (ts.CLOSED_FLAG    = 'Y'
    OR    ts.COMPLETED_FLAG = 'Y' )
   AND   NVL(ts.CANCELLED_FLAG,'N') <> 'Y'
   AND   NVL(ts.REJECTED_FLAG, 'N') <> 'Y';

 CURSOR c_closed_assignments( b_task_id NUMBER ) IS
   SELECT TASK_ASSIGNMENT_ID
   ,      RESOURCE_ID
   FROM   JTF_TASK_ASSIGNMENTS ta
   ,      JTF_TASK_STATUSES_B ts
   WHERE  ta.TASK_ID = b_task_id
   AND    ta.ASSIGNEE_ROLE = 'ASSIGNEE'
   AND    ts.TASK_STATUS_ID = ta.ASSIGNMENT_STATUS_ID
   AND    (ts.CLOSED_FLAG   = 'Y'
    OR    ts.COMPLETED_FLAG = 'Y' )
   AND    NVL(ts.CANCELLED_FLAG,'N') <> 'Y'
   AND    NVL(ts.REJECTED_FLAG, 'N') <> 'Y';
BEGIN
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Entering DELETE_HISTORY_SR_RECORD for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;

 CSL_CS_INCIDENTS_ALL_ACC_PKG.Post_Delete_Child( p_incident_id => p_history_id
                                               , p_resource_id => p_resource_id
                                               , p_flow_type   => CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY);

   --Calculate tasks
   FOR r_closed_task IN c_closed_tasks( b_incident_id => p_history_id ) LOOP
     CSL_JTF_TASKS_ACC_PKG.Post_Delete_Child( p_task_id     => r_closed_task.task_id
                                            , p_resource_id => p_resource_id
			                    , p_flow_type   => CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY);

     --Calculate ta + debrief
     FOR r_closed_assignement IN c_closed_assignments( b_task_id => r_closed_task.task_id ) LOOP
       CSL_JTF_TASK_ASS_ACC_PKG.Post_Delete_Child(
                                p_task_assignment_id => r_closed_assignement.task_assignment_id,
 	  	                p_resource_id        => p_resource_id,
              			p_flow_type          => CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY);

       --Delete resource of ta
       CSL_JTF_RESOURCE_EXTNS_ACC_PKG.Delete_Resource_Extns(
                        p_resource_extn_id => r_closed_assignement.resource_id,
  		        p_resource_id      => p_resource_id );
     END LOOP;
   END LOOP;
   DELETE_MAPPING_RECORD( p_incident_id, p_history_id, p_resource_id );
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Leaving DELETE_HISTORY_SR_RECORD for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;
EXCEPTION WHEN OTHERS THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Exception in CSL_SERVICE_HISTORY_PKG.DELETE_HISTORY_SR_RECORD for incident '||p_incident_id||
     ' and resource '||p_resource_id||':'|| fnd_global.local_chr(10) || sqlerrm
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
   , 'csl_service_history_pkg');
   RAISE;
END DELETE_HISTORY_SR_RECORD;

PROCEDURE CREATE_HISTORY_SR_RECORD( p_incident_id IN NUMBER
                                  , p_history_id  IN NUMBER
                                  , p_resource_id IN NUMBER
				  , p_closed_date IN DATE )
IS
 l_dummy BOOLEAN;

 CURSOR c_closed_tasks( b_incident_id NUMBER )IS
   SELECT tk.TASK_ID
   FROM JTF_TASKS_B tk
   ,    JTF_TASK_STATUSES_B ts
   WHERE tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
   AND   tk.SOURCE_OBJECT_ID = b_incident_id
   AND   tk.TASK_STATUS_ID = ts.TASK_STATUS_ID
   AND   (ts.CLOSED_FLAG = 'Y'
    OR    ts.COMPLETED_FLAG = 'Y' )
   AND   NVL(ts.CANCELLED_FLAG,'N') <> 'Y'
   AND   NVL(ts.REJECTED_FLAG,'N')  <> 'Y';

 CURSOR c_closed_assignments( b_task_id NUMBER ) IS
   SELECT TASK_ASSIGNMENT_ID
   ,      RESOURCE_ID
   FROM   JTF_TASK_ASSIGNMENTS ta
   ,      JTF_TASK_STATUSES_B ts
   WHERE  ta.TASK_ID = b_task_id
   AND    ta.ASSIGNEE_ROLE = 'ASSIGNEE'
   AND    ts.TASK_STATUS_ID = ta.ASSIGNMENT_STATUS_ID
   AND    (ts.CLOSED_FLAG = 'Y'
    OR    ts.COMPLETED_FLAG = 'Y' )
   AND    NVL(ts.CANCELLED_FLAG,'N') <> 'Y'
   AND    NVL(ts.REJECTED_FLAG,'N')  <> 'Y';

BEGIN
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Entering CREATE_HISTORY_SR_RECORD for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
    ( null
    , g_table_name
    , 'Inserting history record '||p_history_id||' for incident '||
       p_incident_id||' and resource '||p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    , 'csl_service_history_pkg');
  END IF;

 INSERT_MAPPING_RECORD( p_incident_id, p_history_id, p_resource_id );
 --Insert SR
 l_dummy := CSL_CS_INCIDENTS_ALL_ACC_PKG.Pre_Insert_Child(
                                                p_incident_id => p_history_id
                                              , p_resource_id => p_resource_id
                                              , p_flow_type   => CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY);
 --Calculate tasks
 FOR r_closed_task IN c_closed_tasks( b_incident_id => p_history_id ) LOOP
   l_dummy := CSL_JTF_TASKS_ACC_PKG.Pre_Insert_Child( p_task_id     => r_closed_task.task_id
                                            , p_resource_id => p_resource_id
	 				    , p_flow_type   => CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY);

   --Calculate ta + debrief
   FOR r_closed_assignement IN c_closed_assignments( b_task_id => r_closed_task.task_id ) LOOP
     l_dummy := CSL_JTF_TASK_ASS_ACC_PKG.Pre_Insert_Child(
                        p_task_assignment_id => r_closed_assignement.task_assignment_id,
	  	        p_resource_id        => p_resource_id,
			p_flow_type          => CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY);

     --Insert resource of ta
     CSL_JTF_RESOURCE_EXTNS_ACC_PKG.Insert_Resource_Extns(
                        p_resource_extn_id => r_closed_assignement.resource_id,
    		        p_resource_id       => p_resource_id );

   END LOOP;
 END LOOP;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Leaving CREATE_HISTORY_SR_RECORD for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;
EXCEPTION WHEN OTHERS THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Exception in CSL_SERVICE_HISTORY_PKG.CREATE_HISTORY_SR_RECORD for incident '||p_incident_id||
     ' and resource '||p_resource_id||':'|| fnd_global.local_chr(10) || sqlerrm
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
   , 'csl_service_history_pkg');
   RAISE;
END CREATE_HISTORY_SR_RECORD;

PROCEDURE DELETE_HISTORY( p_incident_id IN NUMBER
                        , p_resource_id IN NUMBER )
IS
 CURSOR c_history ( b_incident_id NUMBER, b_resource_id NUMBER ) IS
   SELECT HISTORY_INCIDENT_ID
   FROM   CSL_SERVICE_HISTORY
   WHERE  INCIDENT_ID = b_incident_id
   AND    RESOURCE_ID = b_resource_id;


BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Entering DELETE_HISTORY for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;

 FOR r_history IN c_history( p_incident_id, p_resource_id ) LOOP
 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
   jtm_message_log_pkg.Log_Msg
    ( null
    , g_table_name
    , 'Calling delete history record for incident id '||p_incident_id||
      ' and history id '||r_history.HISTORY_INCIDENT_ID||' and resource id '||p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    , 'csl_service_history_pkg');
   END IF;
   DELETE_HISTORY_SR_RECORD( p_incident_id, r_history.HISTORY_INCIDENT_ID, p_resource_id );
 END LOOP;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Leaving DELETE_HISTORY for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;
EXCEPTION WHEN OTHERS THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Exception in CSL_SERVICE_HISTORY_PKG.DELETE_HISTORY for incident '||p_incident_id||
     ' and resource '||p_resource_id||':'|| fnd_global.local_chr(10) || sqlerrm
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
   , 'csl_service_history_pkg');
END DELETE_HISTORY;

/*Procedure calculates the x number of history service request for the given sr */
PROCEDURE CALCULATE_HISTORY( p_incident_id IN NUMBER
                           , p_resource_id IN NUMBER )
IS
 CURSOR c_sr_type( b_incident_id NUMBER ) IS
   -- 11.5.10 Service uptake - 3430663. Get incident_location_id
   SELECT CUSTOMER_PRODUCT_ID
   ,      INCIDENT_LOCATION_ID
   ,      CUSTOMER_ID
   FROM CS_INCIDENTS_ALL_B
   WHERE INCIDENT_ID = b_incident_id;
 r_sr_type c_sr_type%ROWTYPE;

 CURSOR c_task_time( b_incident_id NUMBER
                   , b_resource_id NUMBER ) IS
  SELECT MAX(tk.SCHEDULED_END_DATE ) AS "TASK_TIME"
  FROM JTF_TASKS_B tk
  ,    JTF_TASK_ASSIGNMENTS ta
  WHERE tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
  AND   tk.SOURCE_OBJECT_ID = b_incident_id
  AND   tk.TASK_ID = ta.TASK_ID
  AND   ta.ASSIGNEE_ROLE = 'ASSIGNEE'
  AND   ta.RESOURCE_ID = b_resource_id;
 r_task_time c_task_time%ROWTYPE;

 CURSOR c_get_cp_history( b_max_date            DATE,
                          b_customer_product_id NUMBER ) IS
   SELECT DISTINCT inc.INCIDENT_ID
   ,               inc.CLOSE_DATE
   FROM CS_INCIDENTS_ALL_B       inc
   ,    JTF_TASKS_B              tk
   ,    JTF_TASK_ASSIGNMENTS ta
   ,    CS_INCIDENT_STATUSES_B   ists
   ,    JTF_TASK_TYPES_B       tt
   ,    JTF_TASK_STATUSES_B    tkst
   ,    JTF_TASK_STATUSES_B    tast
   WHERE inc.CLOSE_DATE <= b_max_date
   AND inc.INCIDENT_ID = tk.SOURCE_OBJECT_ID
   AND inc.INCIDENT_STATUS_ID = ists.INCIDENT_STATUS_ID
   AND ists.CLOSE_FLAG = 'Y'
   AND tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
   AND tk.TASK_ID = ta.TASK_ID
   AND ta.ASSIGNEE_ROLE = 'ASSIGNEE'
   AND tk.TASK_STATUS_ID = tkst.TASK_STATUS_ID
   AND (tkst.CLOSED_FLAG = 'Y'
    OR tkst.COMPLETED_FLAG = 'Y')
   AND nvl(tkst.CANCELLED_FLAG,'N') <> 'Y'
   AND nvl(tkst.REJECTED_FLAG,'N')  <> 'Y'
   AND tk.TASK_TYPE_ID = tt.TASK_TYPE_ID
   AND tt.RULE = 'DISPATCH'
   AND ta.ASSIGNMENT_STATUS_ID = tast.TASK_STATUS_ID
   AND (tast.CLOSED_FLAG = 'Y'
    OR tast.COMPLETED_FLAG = 'Y')
   AND nvl(tast.CANCELLED_FLAG,'N') <> 'Y'
   AND nvl(tast.REJECTED_FLAG,'N')  <> 'Y'
   AND inc.CUSTOMER_PRODUCT_ID = b_customer_product_id
   ORDER BY inc.CLOSE_DATE DESC;

 -- 11510 Changes 3430663. Using incident_location_id instead of install_site_id
 CURSOR c_get_non_cp_history( b_max_date            DATE,
                              b_customer_id         NUMBER,
		              b_incident_location_id NUMBER ) IS
   SELECT DISTINCT inc.INCIDENT_ID
   ,               inc.CLOSE_DATE
   FROM CS_INCIDENTS_ALL_B       inc
   ,    JTF_TASKS_B              tk
   ,    JTF_TASK_ASSIGNMENTS ta
   ,    CS_INCIDENT_STATUSES_B   ists
   ,    JTF_TASK_TYPES_B       tt
   ,    JTF_TASK_STATUSES_B    tkst
   ,    JTF_TASK_STATUSES_B    tast
   WHERE inc.CLOSE_DATE <= b_max_date
   AND inc.INCIDENT_ID = tk.SOURCE_OBJECT_ID
   AND inc.INCIDENT_STATUS_ID = ists.INCIDENT_STATUS_ID
   AND ists.CLOSE_FLAG = 'Y'
   AND tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
   AND tk.TASK_ID = ta.TASK_ID
   AND ta.ASSIGNEE_ROLE = 'ASSIGNEE'
   AND tk.TASK_STATUS_ID = tkst.TASK_STATUS_ID
   AND (tkst.CLOSED_FLAG = 'Y'
    OR tkst.COMPLETED_FLAG = 'Y')
   AND tk.TASK_TYPE_ID = tt.TASK_TYPE_ID
   AND tt.RULE = 'DISPATCH'
   AND ta.ASSIGNMENT_STATUS_ID = tast.TASK_STATUS_ID
   AND (tast.CLOSED_FLAG = 'Y'
    OR tast.COMPLETED_FLAG = 'Y')
   AND inc.CUSTOMER_ID = b_customer_id
   AND inc.INCIDENT_LOCATION_ID = b_incident_location_id
   ORDER BY inc.CLOSE_DATE DESC;

 l_history_count NUMBER;

 CURSOR c_history( b_incident_id NUMBER, b_resource_id NUMBER ) IS
   SELECT HISTORY_INCIDENT_ID
   FROM   CSL_SERVICE_HISTORY
   WHERE  INCIDENT_ID = b_incident_id
   AND    RESOURCE_ID = b_resource_id;

 TYPE history_table_type IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

 l_history_table history_table_type;
 l_cntr NUMBER;

 l_not_exists  BOOLEAN;

BEGIN
 /*** get debug level ***/
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Entering CALCULATE_HISTORY for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;

 /*Get history count from profile*/
 l_history_count := GET_HISTORY_COUNT( p_resource_id);

/*TODO: FETCH ALL EXISTING HISTORY RECORDS FOR THIS INCIDENT IN A PLSQL TABLE*/
/*      WHEN CALCULATING NEEDED RECORDS SHOULD BE COMPARED TO THIS TABLE*/
/*      IF IT MATCHES RECORD DOES NOT NEED TO BE INSERTED AND THE PLSQL RECORD SHOULD BE DELETED*/
/*      AT THE END PUSH A DELETE FOR THE REMAINING RECORDS AS THEY ARE NO LONGER NEEDED*/
 OPEN c_history( p_incident_id, p_resource_id );
 FETCH c_history BULK COLLECT INTO l_history_table;
 CLOSE c_history;

 OPEN c_sr_type( b_incident_id => p_incident_id );
 FETCH c_sr_type INTO r_sr_type;
 IF c_sr_type%FOUND THEN
  OPEN c_task_time( b_incident_id => p_incident_id, b_resource_id => p_resource_id );
  FETCH c_task_time INTO r_task_time;
  CLOSE c_task_time;
  /*Check for sr type ( on CP or not )*/
  IF r_sr_type.CUSTOMER_PRODUCT_ID IS NOT NULL THEN
    /*Only history for CP product*/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Service request is based on a customer product'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , 'csl_service_history_pkg');
    END IF;

    FOR r_get_cp_history IN c_get_cp_history( b_max_date => nvl( r_task_time.TASK_TIME, SYSDATE ),
                                              b_customer_product_id => r_sr_type.CUSTOMER_PRODUCT_ID )
    LOOP
      IF l_history_table.COUNT > 0 THEN
        l_not_exists := TRUE;
        /*Check if record exists*/
	FOR i IN l_history_table.FIRST .. l_history_table.LAST LOOP
	  IF l_history_table.EXISTS(i) THEN
	    IF l_history_table(i) = r_get_cp_history.incident_id THEN
	      /*Record does exist do not insert but remove reference from list*/
	      l_history_table.DELETE(i);
	      l_not_exists := FALSE;
	    END IF;
	  END IF;
	END LOOP;
	IF l_not_exists THEN
          /*Record does not yet exists so insert*/
          CREATE_HISTORY_SR_RECORD( p_incident_id => p_incident_id
                                  , p_history_id  => r_get_cp_history.incident_id
                                  , p_resource_id => p_resource_id
                                  , p_closed_date => r_get_cp_history.close_date );
	END IF;
      ELSE
        /*Record does not yet exists so insert*/
        CREATE_HISTORY_SR_RECORD( p_incident_id => p_incident_id
                                , p_history_id  => r_get_cp_history.incident_id
                                , p_resource_id => p_resource_id
  			        , p_closed_date => r_get_cp_history.close_date );
      END IF;

      l_history_count := l_history_count - 1;
      EXIT WHEN l_history_count = 0;
    END LOOP;

    /*Push delete to history records that are no longer history record*/
    IF l_history_table.COUNT > 0 THEN
      FOR i IN l_history_table.FIRST .. l_history_table.LAST LOOP
        IF l_history_table.EXISTS(i) THEN
          DELETE_HISTORY_SR_RECORD( p_incident_id, l_history_table(i), p_resource_id );
        END IF;
      END LOOP;
    END IF;
  ELSE
    /*SR history for cust/install site*/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( null
      , g_table_name
      , 'Service request is not based on a customer product, retrieving history for' ||
        fnd_global.local_chr(10) || 'task time = ' || to_char(r_task_time.TASK_TIME, 'DD-MON-YYYY HH24:MI') ||
        fnd_global.local_chr(10) || 'customer_id = ' || r_sr_type.CUSTOMER_ID ||
        fnd_global.local_chr(10) || 'incident_location_id = ' || r_sr_type.incident_location_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , 'csl_service_history_pkg');
    END IF;

    FOR r_get_non_cp_history IN c_get_non_cp_history( b_max_date => nvl( r_task_time.TASK_TIME, SYSDATE ),
                                                      b_customer_id => r_sr_type.CUSTOMER_ID,
		                                      b_incident_location_id => r_sr_type.incident_location_id )
    LOOP

     IF l_history_table.COUNT > 0 THEN
        l_not_exists := TRUE;
        /*Check if record exists*/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( null
          , g_table_name
          , 'Checking if incident_id ' || r_get_non_cp_history.incident_id ||' needs to be replicated'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
          , 'csl_service_history_pkg');
        END IF;

	FOR i IN l_history_table.FIRST .. l_history_table.LAST LOOP
	  IF l_history_table.EXISTS(i) THEN
	    IF l_history_table(i) = r_get_non_cp_history.incident_id THEN
	      /*Record does exist do not insert but remove reference from list*/
              IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
                jtm_message_log_pkg.Log_Msg
                ( null
                , g_table_name
                , 'Already replicated, deleting from PL/SQL table'
                , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
                , 'csl_service_history_pkg');
              END IF;
	      l_history_table.DELETE(i);
              l_not_exists := FALSE;
	    END IF;
	  END IF;
	END LOOP;
	IF l_not_exists THEN
          /*Record does not yet exists so insert*/
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
             jtm_message_log_pkg.Log_Msg
             ( null
             , g_table_name
             , 'Record not replicated yet; push it to client(s)'
             , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
             , 'csl_service_history_pkg');
          END IF;
          CREATE_HISTORY_SR_RECORD( p_incident_id => p_incident_id
                                  , p_history_id  => r_get_non_cp_history.incident_id
                                  , p_resource_id => p_resource_id
                                  , p_closed_date => r_get_non_cp_history.close_date );
        END IF;
      ELSE
      CREATE_HISTORY_SR_RECORD( p_incident_id => p_incident_id
                              , p_history_id  => r_get_non_cp_history.incident_id
                              , p_resource_id => p_resource_id
			      , p_closed_date => r_get_non_cp_history.close_date );
      END IF;
      l_history_count := l_history_count - 1;
      EXIT WHEN l_history_count = 0;
    END LOOP;

    /*Push delete to history records that are no longer history record*/
    IF l_history_table.COUNT > 0 THEN
      FOR i IN l_history_table.FIRST .. l_history_table.LAST LOOP
        IF l_history_table.EXISTS(i) THEN
          DELETE_HISTORY_SR_RECORD( p_incident_id, l_history_table(i), p_resource_id );
        END IF;
      END LOOP;
    END IF;
  END IF;
 ELSE
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( null
    , g_table_name
    , 'Could not find data for incident id '||p_incident_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    , 'csl_service_history_pkg');
  END IF;
 END IF;
 CLOSE c_sr_type;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Leaving CALCULATE_HISTORY for incident '||p_incident_id
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;

EXCEPTION WHEN OTHERS THEN
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Exception in CSL_SERVICE_HISTORY_PKG.CALCULATE_HISTORY for incident '||p_incident_id||
     ' and resource '||p_resource_id||':'|| fnd_global.local_chr(10) || sqlerrm
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
   , 'csl_service_history_pkg');
END CALCULATE_HISTORY;

PROCEDURE CONCURRENT_HISTORY
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 CURSOR c_acc_incidents IS
   SELECT acc.INCIDENT_ID
   ,      acc.RESOURCE_ID
   FROM CSL_CS_INCIDENTS_ALL_ACC acc
   ,    CS_INCIDENTS_ALL_B inc
   ,    JTF_TASKS_B tsk
   ,    JTF_TASK_ASSIGNMENTS ta
   WHERE tsk.SOURCE_OBJECT_ID = inc.INCIDENT_ID
   AND   tsk.SOURCE_OBJECT_TYPE_CODE = 'SR'
   AND   tsk.TASK_ID = ta.TASK_ID
   AND   ta.RESOURCE_ID = acc.RESOURCE_ID
   AND   inc.INCIDENT_ID = acc.INCIDENT_ID
   AND   tsk.SCHEDULED_END_DATE >= TRUNC(SYSDATE)
   AND   NVL(inc.CLOSE_DATE, SYSDATE ) >= SYSDATE;

BEGIN
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Entering CONCURRENT_HISTORY'
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;

 FOR r_acc_incident IN c_acc_incidents LOOP
   CALCULATE_HISTORY( p_incident_id => r_acc_incident.INCIDENT_ID
                    , p_resource_id => r_acc_incident.RESOURCE_ID );
 END LOOP;

  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = SYSDATE
  WHERE PRODUCT_CODE = 'CSL'
  AND   PACKAGE_NAME = 'CSL_SERVICE_HISTORY_PKG'
  AND   PROCEDURE_NAME = 'CONCURRENT_HISTORY';


  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
  jtm_message_log_pkg.Log_Msg
  ( null
  , g_table_name
  , 'Leaving CONCURRENT_HISTORY'
  , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  , 'csl_service_history_pkg');
 END IF;
 COMMIT;
EXCEPTION WHEN OTHERS THEN
 ROLLBACK;
   jtm_message_log_pkg.Log_Msg
   ( null
   , g_table_name
   , 'Exception in CSL_SERVICE_HISTORY_PKG.CONCURRENT_HISTORY'||':'
     || fnd_global.local_chr(10) || sqlerrm
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
   , 'csl_service_history_pkg');
END CONCURRENT_HISTORY;

END CSL_SERVICE_HISTORY_PKG;

/
