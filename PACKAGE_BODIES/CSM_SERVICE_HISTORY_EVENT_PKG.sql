--------------------------------------------------------
--  DDL for Package Body CSM_SERVICE_HISTORY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SERVICE_HISTORY_EVENT_PKG" AS
/* $Header: csmsrhb.pls 120.6 2008/02/08 12:29:18 trajasek ship $ */

/*** Globals ***/
g_debug_level                     NUMBER;
g_object_name                     CONSTANT VARCHAR2(30) := 'CSM_SERVICE_HISTORY_EVENT_PKG' ;
g_table_name                      CONSTANT VARCHAR2(30) := 'CSM_SERVICE_HISTORY';
g_publication_item_name           CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                                     CSM_ACC_PKG.t_publication_item_list('CSM_SERVICE_HISTORY');
g_acc_table_name                  CONSTANT VARCHAR2(30) := 'CSM_SERVICE_HISTORY_ACC';
g_pk1_name                        CONSTANT VARCHAR2(30) := 'INCIDENT_ID';
g_pk2_name                        CONSTANT VARCHAR2(30) := 'HISTORY_INCIDENT_ID';
g_pk3_name                        CONSTANT VARCHAR2(30) := 'INSTANCE_ID';
g_seq_name                        CONSTANT VARCHAR2(30) := 'CSM_SERVICE_HISTORY_ACC_S' ;

g_incidents_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_INCIDENTS_ALL_ACC';
g_incidents_table_name            CONSTANT VARCHAR2(30) := 'CS_INCIDENTS_ALL';
g_incidents_seq_name              CONSTANT VARCHAR2(30) := 'CSM_INCIDENTS_ALL_ACC_S' ;
g_incidents_pk1_name              CONSTANT VARCHAR2(30) := 'INCIDENT_ID';
g_incidents_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                                     CSM_ACC_PKG.t_publication_item_list('CSM_INCIDENTS_ALL');

PROCEDURE DELETE_HISTORY_SR_RECORD( p_incident_id NUMBER
                                  , p_history_id  NUMBER
                                  , p_user_id NUMBER )
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

 CURSOR c_closed_assignments( b_incident_id NUMBER ) IS
   SELECT TASK_ASSIGNMENT_ID
   FROM JTF_TASKS_B              tk
   ,    JTF_TASK_ASSIGNMENTS ta
   ,    JTF_TASK_TYPES_B       tt
   ,    JTF_TASK_STATUSES_B    tkst
   ,    JTF_TASK_STATUSES_B    tast
   WHERE  tk.SOURCE_OBJECT_ID = b_incident_id
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
   AND nvl(tast.REJECTED_FLAG,'N')  <> 'Y' ;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_HISTORY_EVENT_PKG.DELETE_HISTORY_SR_RECORD',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.DELETE_HISTORY_SR_RECOR',FND_LOG.LEVEL_PROCEDURE);

  --Calculate ta + debrief
  FOR r_closed_assignement IN c_closed_assignments( b_incident_id => p_history_id ) LOOP

           csm_task_assignment_event_pkg.task_assignment_hist_del_init
                   (p_task_assignment_id=>r_closed_assignement.task_assignment_id,
                    p_parent_incident_id=>p_incident_id,
                    p_user_id=>p_user_id,
                    p_error_msg=>l_error_msg,
                    x_return_status=>l_return_status);

  END LOOP;
    CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_HISTORY_EVENT_PKG.DELETE_HISTORY_SR_RECORD',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.DELETE_HISTORY_SR_RECOR',FND_LOG.LEVEL_EXCEPTION);


EXCEPTION WHEN OTHERS THEN
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg ||'- Exception in  DELETE_HISTORY_SR_RECORD for incident_id:' || p_incident_id
                    || ' and user_id: ' || p_user_id  || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERVICE_HISTORY_EVENT_PKG.DELETE_HISTORY_SR_RECORD',FND_LOG.LEVEL_EXCEPTION);
    RAISE;
END DELETE_HISTORY_SR_RECORD;

PROCEDURE CREATE_HISTORY_SR_RECORD( p_incident_id IN NUMBER
                                  , p_history_id  IN NUMBER
                                  , p_user_id IN NUMBER
				  , p_closed_date IN DATE )
IS
l_dummy BOOLEAN;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

 CURSOR c_closed_assignments( b_hist_incident_id NUMBER, b_incident_id IN number,
                              b_user_id IN number) IS
   SELECT TASK_ASSIGNMENT_ID
   FROM JTF_TASKS_B              tk
   ,    JTF_TASK_ASSIGNMENTS ta
   ,    JTF_TASK_TYPES_B       tt
   ,    JTF_TASK_STATUSES_B    tkst
   ,    JTF_TASK_STATUSES_B    tast
   WHERE  tk.SOURCE_OBJECT_ID = b_hist_incident_id
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
   AND NOT EXISTS
   (SELECT 1
    FROM csm_service_history_acc acc
    WHERE acc.user_id = b_user_id
    AND acc.incident_id = b_incident_id
    AND acc.history_incident_id = b_hist_incident_id
    );

 l_itemtype varchar2(30);
 l_itemkey varchar2(1000);
 l_seq_val number;
BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_HISTORY_EVENT_PKG.CREATE_HISTORY_SR_RECORD',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CREATE_HISTORY_SR_RECOR',FND_LOG.LEVEL_PROCEDURE);

  --use the CSMTYPE3 itemtype
  l_itemtype := 'CSMTYPE3';

   --Call for each task assignment
   FOR r_closed_assignement IN c_closed_assignments( b_hist_incident_id => p_history_id, b_incident_id => p_incident_id,
                                                    b_user_id => p_user_id) LOOP

             csm_task_assignment_event_pkg.task_assignment_hist_init
                   (p_task_assignment_id=>r_closed_assignement.task_assignment_id,
                    p_parent_incident_id=>p_incident_id,
                    p_user_id=>p_user_id,
                    p_error_msg=>l_error_msg,
                    x_return_status=>l_return_status);

   END LOOP;
    CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_HISTORY_EVENT_PKG.CREATE_HISTORY_SR_RECORD',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CREATE_HISTORY_SR_RECOR',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    l_error_msg := l_error_msg ||'- Exception in  CREATE_HISTORY_SR_RECORD for incident_id:' || p_incident_id
                    || ' and user_id: ' || p_user_id  || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERVICE_HISTORY_EVENT_PKG.CREATE_HISTORY_SR_RECORD',FND_LOG.LEVEL_EXCEPTION);
    RAISE;
END CREATE_HISTORY_SR_RECORD;

/*Procedure calculates the x number of history service request for the given sr */
PROCEDURE CALCULATE_HISTORY( l_incident_id in number,
	    	                 l_user_id in number)
IS
CURSOR c_sr_type( b_incident_id NUMBER )
IS
SELECT CUSTOMER_PRODUCT_ID
,      INSTALL_SITE_ID
,      CUSTOMER_ID
,      INCIDENT_LOCATION_ID
FROM CS_INCIDENTS_ALL_B
WHERE INCIDENT_ID = b_incident_id;

r_sr_type c_sr_type%ROWTYPE;

CURSOR c_task_time( b_incident_id NUMBER
                  , b_user_id NUMBER )
IS
SELECT MAX(tk.SCHEDULED_END_DATE ) AS "TASK_TIME"
FROM JTF_TASKS_B tk
,    JTF_TASK_ASSIGNMENTS ta
,    JTF_RS_RESOURCE_EXTNS rs
WHERE tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
AND   tk.SOURCE_OBJECT_ID = b_incident_id
AND   tk.TASK_ID = ta.TASK_ID
AND   ta.ASSIGNEE_ROLE = 'ASSIGNEE'
AND   ta.RESOURCE_ID = rs.resource_id
AND   rs.user_id = b_user_id ;

r_task_time c_task_time%ROWTYPE;

CURSOR c_get_cp_history( b_max_date            DATE,
                         b_customer_product_id NUMBER )
IS
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
--AND inc.install_site_id IS NOT NULL
AND ists.CLOSE_FLAG = 'Y'
AND tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
AND tk.TASK_ID = ta.TASK_ID
AND ta.ASSIGNEE_ROLE = 'ASSIGNEE'
AND tk.TASK_STATUS_ID = tkst.TASK_STATUS_ID
AND (tkst.CLOSED_FLAG = 'Y' OR tkst.COMPLETED_FLAG = 'Y')
AND NVL(tkst.CANCELLED_FLAG,'N') <> 'Y'
AND NVL(tkst.REJECTED_FLAG,'N')  <> 'Y'
AND tk.TASK_TYPE_ID = tt.TASK_TYPE_ID
AND tt.RULE = 'DISPATCH'
AND ta.ASSIGNMENT_STATUS_ID = tast.TASK_STATUS_ID
AND (tast.CLOSED_FLAG = 'Y' OR tast.COMPLETED_FLAG = 'Y')
AND NVL(tast.CANCELLED_FLAG,'N') <> 'Y'
AND NVL(tast.REJECTED_FLAG,'N')  <> 'Y'
AND inc.CUSTOMER_PRODUCT_ID = b_customer_product_id
ORDER BY inc.CLOSE_DATE DESC;

CURSOR c_get_non_cp_history( b_max_date            DATE,
                             b_customer_id         NUMBER,
                             b_INCIDENT_LOCATION_ID NUMBER )
IS
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
--AND inc.install_site_id IS NOT NULL
AND ists.CLOSE_FLAG = 'Y'
AND tk.SOURCE_OBJECT_TYPE_CODE = 'SR'
AND tk.TASK_ID = ta.TASK_ID
AND ta.ASSIGNEE_ROLE = 'ASSIGNEE'
AND tk.TASK_STATUS_ID = tkst.TASK_STATUS_ID
AND (tkst.CLOSED_FLAG = 'Y' OR tkst.COMPLETED_FLAG = 'Y')
AND NVL(tkst.CANCELLED_FLAG,'N') <> 'Y'
AND NVL(tkst.REJECTED_FLAG,'N')  <> 'Y'
AND tk.TASK_TYPE_ID = tt.TASK_TYPE_ID
AND tt.RULE = 'DISPATCH'
AND ta.ASSIGNMENT_STATUS_ID = tast.TASK_STATUS_ID
AND (tast.CLOSED_FLAG = 'Y' OR tast.COMPLETED_FLAG = 'Y')
AND NVL(tkst.CANCELLED_FLAG,'N') <> 'Y'
AND NVL(tkst.REJECTED_FLAG,'N')  <> 'Y'
AND inc.CUSTOMER_ID = b_customer_id
AND inc.INCIDENT_LOCATION_ID = b_INCIDENT_LOCATION_ID
ORDER BY inc.CLOSE_DATE DESC;

l_history_count NUMBER;

CURSOR c_history( b_incident_id NUMBER, b_user_id NUMBER )
IS
SELECT HISTORY_INCIDENT_ID
FROM   CSM_SERVICE_HISTORY_ACC
WHERE  INCIDENT_ID = b_incident_id
AND    USER_ID = b_user_id;

TYPE history_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_history_table history_table_type;
l_cntr NUMBER;
l_not_exists  BOOLEAN;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_PROCEDURE);

 /*Get history count from profile*/
  l_history_count := csm_profile_pkg.get_history_count(l_user_id);

/*TODO: FETCH ALL EXISTING HISTORY RECORDS FOR THIS INCIDENT IN A PLSQL TABLE*/
/*      WHEN CALCULATING NEEDED RECORDS SHOULD BE COMPARED TO THIS TABLE*/
/*      IF IT MATCHES RECORD DOES NOT NEED TO BE INSERTED AND THE PLSQL RECORD SHOULD BE DELETED*/
/*      AT THE END PUSH A DELETE FOR THE REMAINING RECORDS AS THEY ARE NO LONGER NEEDED*/
 OPEN c_history( l_incident_id, l_user_id );
 FETCH c_history BULK COLLECT INTO l_history_table;
 CLOSE c_history;

 OPEN c_sr_type( b_incident_id => l_incident_id );
 FETCH c_sr_type INTO r_sr_type;
 IF c_sr_type%FOUND THEN
  OPEN c_task_time( b_incident_id => l_incident_id, b_user_id => l_user_id );
  FETCH c_task_time INTO r_task_time;
  CLOSE c_task_time;
  /*Check for sr type ( on CP or not )*/
  IF r_sr_type.CUSTOMER_PRODUCT_ID IS NOT NULL THEN
    /*Only history for CP product*/
    CSM_UTIL_PKG.LOG(' Service request is based on a customer product',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_PROCEDURE);

    -- If csm_history_count profile value > 0
    IF l_history_count > 0 THEN

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
              CSM_UTIL_PKG.LOG('Already replicated, deleting from PLSQL table',
                          'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_PROCEDURE);
	          l_history_table.DELETE(i);
	          l_not_exists := FALSE;
	        END IF;
	      END IF;
	    END LOOP; -- end of for looping over l_history table
  	    IF l_not_exists THEN
          /*Record does not yet exists so insert*/
          CSM_UTIL_PKG.LOG('Record not replicated yet; push it to client(s)',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_PROCEDURE);
          CREATE_HISTORY_SR_RECORD( p_incident_id => l_incident_id
                                  , p_history_id  => r_get_cp_history.incident_id
                                  , p_user_id => l_user_id
                                  , p_closed_date => r_get_cp_history.close_date );
	    END IF;
      ELSE -- else when l_history_table count is 0
        /*Record does not yet exists so insert*/
        CREATE_HISTORY_SR_RECORD( p_incident_id => l_incident_id
                                , p_history_id  => r_get_cp_history.incident_id
                                , p_user_id => l_user_id
  			        , p_closed_date => r_get_cp_history.close_date );
      END IF;

      l_history_count := l_history_count - 1;
      EXIT WHEN l_history_count = 0;
    END LOOP;
    END IF ; -- l_history_count > 0
    /*Push delete to history records that are no longer history record*/
    IF l_history_table.COUNT > 0 THEN
      FOR i IN l_history_table.FIRST .. l_history_table.LAST LOOP
        IF l_history_table.EXISTS(i) THEN
          DELETE_HISTORY_SR_RECORD( l_incident_id, l_history_table(i), l_user_id );
        END IF;
      END LOOP;
    END IF;
  ELSE
    /*SR history for cust/install site*/
   CSM_UTIL_PKG.LOG(' Service request is not based on a customer product',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_PROCEDURE);

   -- If csm_history_count profile value > 0
  IF l_history_count > 0 THEN

    FOR r_get_non_cp_history IN c_get_non_cp_history( b_max_date => nvl( r_task_time.TASK_TIME, SYSDATE ),
                                                      b_customer_id => r_sr_type.CUSTOMER_ID,
        		                                      b_INCIDENT_LOCATION_ID => r_sr_type.INCIDENT_LOCATION_ID )

    LOOP

     IF l_history_table.COUNT > 0 THEN
        l_not_exists := TRUE;

        	FOR i IN l_history_table.FIRST .. l_history_table.LAST LOOP
         	  IF l_history_table.EXISTS(i) THEN
        	    IF l_history_table(i) = r_get_non_cp_history.incident_id THEN
	            /*Record does exist do not insert but remove reference from list*/
                 CSM_UTIL_PKG.LOG('Already replicated, deleting from PLSQL table',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_PROCEDURE);
	             l_history_table.DELETE(i);
                 l_not_exists := FALSE;
        	    END IF;
        	  END IF;
        	END LOOP;
    	IF l_not_exists THEN
          /*Record does not yet exists so insert*/
          CSM_UTIL_PKG.LOG('Record not replicated yet; push it to client(s)',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_PROCEDURE);

          CREATE_HISTORY_SR_RECORD( p_incident_id => l_incident_id
                                  , p_history_id  => r_get_non_cp_history.incident_id
                                  , p_user_id => l_user_id
                                  , p_closed_date => r_get_non_cp_history.close_date );
        END IF;
      ELSE
        CREATE_HISTORY_SR_RECORD( p_incident_id => l_incident_id
                              , p_history_id  => r_get_non_cp_history.incident_id
                              , p_user_id => l_user_id
            			      , p_closed_date => r_get_non_cp_history.close_date );
      END IF;
      l_history_count := l_history_count - 1;
      EXIT WHEN l_history_count = 0;
    END LOOP;
    END IF ; -- l_history_count > 0
    /*Push delete to history records that are no longer history record*/
    IF l_history_table.COUNT > 0 THEN
      FOR i IN l_history_table.FIRST .. l_history_table.LAST LOOP
        IF l_history_table.EXISTS(i) THEN
          DELETE_HISTORY_SR_RECORD( l_incident_id, l_history_table(i), l_user_id );
        END IF;
      END LOOP;
    END IF;
  END IF;
 ELSE

  null ;
 END IF;
 CLOSE c_sr_type;
  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_PROCEDURE);


EXCEPTION
    WHEN OTHERS THEN
      l_sqlerrno := to_char(SQLCODE);
      l_sqlerrmsg := substr(SQLERRM, 1,2000);
      l_error_msg := ' Exception in  CALCULATE_HISTORY for incident_id: ' || l_incident_id ||
      ' and for user_id: ' || l_user_id || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
      CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERVICE_HISTORY_EVENT_PKG.CALCULATE_HISTORY',FND_LOG.LEVEL_EXCEPTION);
      RAISE;
END CALCULATE_HISTORY;

PROCEDURE CONCURRENT_HISTORY(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR c_acc_incidents
IS
SELECT acc.INCIDENT_ID
,      acc.USER_ID
FROM CSM_INCIDENTS_ALL_ACC acc
,    CS_INCIDENTS_ALL_B inc
,    CS_INCIDENT_STATUSES_b cis
,    JTF_TASKS_B tsk
,    JTF_TASK_ASSIGNMENTS ta
,    JTF_RS_RESOURCE_EXTNS rs
WHERE tsk.SOURCE_OBJECT_ID = inc.INCIDENT_ID
AND   tsk.SOURCE_OBJECT_TYPE_CODE = 'SR'
AND   tsk.TASK_ID = ta.TASK_ID
AND   ta.RESOURCE_ID = rs.RESOURCE_ID
AND   rs.USER_ID = acc.USER_ID
AND   inc.INCIDENT_ID = acc.INCIDENT_ID
AND   inc.incident_status_id = cis.incident_status_id
AND   NVL(cis.close_flag,'N') <> 'Y'
AND   tsk.SCHEDULED_END_DATE >= TRUNC(SYSDATE)
AND   NVL(inc.CLOSE_DATE, SYSDATE ) >= SYSDATE;

-- this purges SR history that was not purged by the TA purge
-- ideally this shouldn't happen and this is more of a data fix
CURSOR l_purge_SR_history
IS
SELECT /*+INDEX (hacc CSM_SERVICE_HISTORY_ACC_U1)*/ user_id,
       incident_id,
       history_incident_id
FROM   csm_service_history_acc hacc
WHERE NOT EXISTS
 (SELECT 'X'
  FROM csm_incidents_all_acc acc
  WHERE acc.user_id = hacc.user_id
  AND acc.incident_id = hacc.incident_id);

CURSOR l_upd_last_run_date_csr
IS
SELECT 1
FROM jtm_con_request_data
WHERE product_code = 'CSM'
AND package_name = 'CSM_SERVICE_HISTORY_EVENT_PKG'
AND procedure_name = 'CONCURRENT_HISTORY'
FOR UPDATE OF last_run_date NOWAIT ;

l_last_run_date date ;
l_dummy number ;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_HISTORY_EVENT_PKG.CONCURRENT_HISTORY',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CONCURRENT_HISTORY',FND_LOG.LEVEL_PROCEDURE);

 /*  Assign flow_type to 'HISTORY' */
 -- csm_util_pkg.g_flow_type := 'HISTORY' ;
 l_last_run_date := SYSDATE;

 -- get new history
 FOR r_acc_incident IN c_acc_incidents LOOP
  CALCULATE_HISTORY( l_incident_id => r_acc_incident.INCIDENT_ID
                    , l_user_id => r_acc_incident.USER_ID );
 END LOOP;

 -- purge history that is not purged by TA purge
 FOR r_purge_SR_history IN l_purge_SR_history LOOP
    DELETE_HISTORY_SR_RECORD(p_incident_id=>r_purge_SR_history.incident_id,
                             p_history_id=>r_purge_SR_history.history_incident_id,
                             p_user_id=>r_purge_SR_history.user_id);
 END LOOP;

 -- update last_run_date
 OPEN l_upd_last_run_date_csr;
 FETCH l_upd_last_run_date_csr INTO l_dummy;
 IF l_upd_last_run_date_csr%FOUND THEN
     UPDATE jtm_con_request_data
     SET last_run_date = l_last_run_date
     WHERE CURRENT OF l_upd_last_run_date_csr;
 END IF;
 CLOSE l_upd_last_run_date_csr;

 COMMIT;

 CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_HISTORY_EVENT_PKG.CONCURRENT_HISTORY',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.CONCURRENT_HISTORY',FND_LOG.LEVEL_PROCEDURE);
 p_status := 'SUCCESS';
 p_message :=  'CSM_SERVICE_HISTORY_EVENT_PKG.CONCURRENT_HISTORY Executed successfully';

EXCEPTION
 WHEN OTHERS THEN
      l_sqlerrno := to_char(SQLCODE);
      l_sqlerrmsg := substr(SQLERRM, 1,2000);
      l_error_msg := ' Exception in  CONCURRENT_HISTORY : ' || l_sqlerrno || ':' || l_sqlerrmsg;
      CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERVICE_HISTORY_EVENT_PKG.CONCURRENT_HISTORY',FND_LOG.LEVEL_EXCEPTION);
      p_status := 'ERROR';
      p_message := 'Error in CSM_SERVICE_HISTORY_EVENT_PKG.CONCURRENT_HISTORY: ' || l_error_msg;
      ROLLBACK;
END CONCURRENT_HISTORY;

PROCEDURE SERVICE_HISTORY_ACC_I(p_parent_incident_id IN NUMBER,
                                p_incident_id IN NUMBER,
                                p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SERVICE_HISTORY_ACC_I for incident_id: ' || p_incident_id
                     || ' and parent_incident_id:' || p_parent_incident_id,
                         'CSM_SERVICE_HISTORY_EVENT_PKG.SERVICE_HISTORY_ACC_I',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Insert_Acc
   ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
    ,P_ACC_TABLE_NAME         => g_acc_table_name
    ,P_SEQ_NAME               => g_seq_name
    ,P_PK1_NAME               => g_pk1_name
    ,P_PK1_NUM_VALUE          => p_parent_incident_id
    ,P_PK2_NAME               => g_pk2_name
    ,P_PK2_NUM_VALUE          => p_incident_id
    ,p_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving SERVICE_HISTORY_ACC_I for incident_id: ' || p_incident_id
                     || ' and parent_incident_id:' || p_parent_incident_id,
                         'CSM_SERVICE_HISTORY_EVENT_PKG.SERVICE_HISTORY_ACC_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SERVICE_HISTORY_ACC_I for incident_id: ' || p_incident_id
                     || ' and parent_incident_id:' || p_parent_incident_id || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERVICE_HISTORY_EVENT_PKG.SERVICE_HISTORY_ACC_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SERVICE_HISTORY_ACC_I;

PROCEDURE DELETE_HISTORY(p_task_assignment_id IN NUMBER,
                         p_incident_id IN NUMBER,
                         p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR c_history ( b_incident_id NUMBER, b_task_assignment_id NUMBER, b_user_id NUMBER ) IS
   SELECT HISTORY_INCIDENT_ID
   FROM   CSM_SERVICE_HISTORY_ACC
   WHERE  INCIDENT_ID = b_incident_id
   AND    USER_ID = b_user_id
   AND NOT EXISTS (SELECT 'X'
                   FROM CSM_TASK_ASSIGNMENTS_ACC ACC,
                        JTF_TASK_ASSIGNMENTS ASG,
                        JTF_TASKS_B TASK
                   WHERE ACC.TASK_ASSIGNMENT_ID = ASG.TASK_ASSIGNMENT_ID
                     AND ASG.TASK_ID = TASK.TASK_ID
                     AND TASK.SOURCE_OBJECT_TYPE_CODE = 'SR'
                     AND TASK.SOURCE_OBJECT_ID = b_incident_id
                     AND ACC.USER_ID = b_user_id
                     AND ACC.TASK_ASSIGNMENT_ID <> b_task_assignment_id);

BEGIN
   CSM_UTIL_PKG.LOG('Entering DELETE_HISTORY for incident_id: ' || p_incident_id
                     || ' and task_assignment_id:' || p_task_assignment_id,
                         'CSM_SERVICE_HISTORY_EVENT_PKG.DELETE_HISTORY',FND_LOG.LEVEL_PROCEDURE);

 FOR r_history IN c_history( p_incident_id, p_task_assignment_id, p_user_id ) LOOP
    DELETE_HISTORY_SR_RECORD( p_incident_id, r_history.HISTORY_INCIDENT_ID, p_user_id );
 END LOOP;

   CSM_UTIL_PKG.LOG('Leaving DELETE_HISTORY for incident_id: ' || p_incident_id
                     || ' and task_assignment_id:' || p_task_assignment_id,
                         'CSM_SERVICE_HISTORY_EVENT_PKG.DELETE_HISTORY',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DELETE_HISTORY for incident_id: ' || p_incident_id
                     || ' and task_assignment_id:' || p_task_assignment_id || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERVICE_HISTORY_EVENT_PKG.DELETE_HISTORY',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DELETE_HISTORY;

PROCEDURE SERVICE_HISTORY_ACC_D(p_parent_incident_id IN NUMBER,
                                p_incident_id IN NUMBER,
                                p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SERVICE_HISTORY_ACC_D for incident_id: ' || p_incident_id
                     || ' and parent_incident_id:' || p_parent_incident_id,
                         'CSM_SERVICE_HISTORY_EVENT_PKG.SERVICE_HISTORY_ACC_D',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     ,P_ACC_TABLE_NAME         => g_acc_table_name
     ,P_PK1_NAME               => g_pk1_name
     ,P_PK1_NUM_VALUE          => p_parent_incident_id
     ,P_PK2_NAME               => g_pk2_name
     ,P_PK2_NUM_VALUE          => p_incident_id
     ,p_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving SERVICE_HISTORY_ACC_D for incident_id: ' || p_incident_id
                     || ' and parent_incident_id:' || p_parent_incident_id,
                         'CSM_SERVICE_HISTORY_EVENT_PKG.SERVICE_HISTORY_ACC_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SERVICE_HISTORY_ACC_D for incident_id: ' || p_incident_id
                     || ' and parent_incident_id:' || p_parent_incident_id || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERVICE_HISTORY_EVENT_PKG.SERVICE_HISTORY_ACC_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SERVICE_HISTORY_ACC_D;

PROCEDURE PROCESS_OWNER_HISTORY( p_return_status OUT NOCOPY VARCHAR2,p_error_message OUT NOCOPY VARCHAR2
                               )
IS

TYPE l_instance_id_tbl_type      IS TABLE OF csm_item_instances_acc.instance_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_user_id_tbl_type          IS TABLE OF csm_parties_acc.user_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_party_id_tbl_type         IS TABLE OF csm_parties_acc.party_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_incident_id_tbl_type      IS TABLE OF csm_incidents_all_acc.incident_id%TYPE INDEX BY BINARY_INTEGER;

l_instance_id_tbl                l_instance_id_tbl_type;
l_incident_id_tbl                l_incident_id_tbl_type;
l_user_id_tbl                    l_user_id_tbl_type;
l_parent_incident_id             NUMBER;
l_sr_profile_value               VARCHAR2(1) := NULL;

l_sqlerrno                       VARCHAR2(20);
l_sqlerrmsg                      VARCHAR2(2000);
l_error_msg                      VARCHAR2(3000);
l_return_status                  VARCHAR2(3000);
l_error_message                  VARCHAR2(3000);

/*
This cursor fetches SR history for the parties downloaded
*/
CURSOR l_sr_hist_ins_csr
IS
SELECT ciab.incident_id
     , ciia.user_id
     , ciia.instance_id
FROM   cs_incidents_all_b ciab
     , cs_incident_statuses_b cisb
     , csm_item_instances_acc ciia
     , jtf_tasks_b jtb
WHERE  ciab.customer_product_id      = ciia.instance_id
AND    ciab.incident_status_id       = cisb.incident_status_id
AND    cisb.close_flag               = 'Y'
AND    ciab.incident_id              = jtb.source_object_id
AND    jtb.source_object_type_code   = 'SR'
and    jtb.scheduled_start_date > (sysdate - NVL(fnd_profile.value_specific('CSF_M_HISTORY'),100))
AND    ciia.user_id IN ( SELECT cpa.user_id
                         FROM   csm_party_assignment cpa
                         WHERE  cpa.deleted_flag ='N'
                       )
AND    NOT EXISTS      ( SELECT 1
                         FROM   csm_service_history_acc csha
                         WHERE  csha.user_id = ciia.user_id
                         AND    csha.history_incident_id = ciab.incident_id
                       );


/*
This cursor fetches SR history for the parties downloaded
*/
CURSOR l_sr_hist_del_csr
IS
SELECT csha.history_incident_id
     , csha.user_id
     , csha.instance_id
FROM   csm_service_history_acc csha
WHERE  csha.incident_id=1
AND    NOT EXISTS      ( SELECT 1
                         FROM   csm_item_instances_acc ciia
                         WHERE  ciia.user_id     = csha.user_id
                         AND    ciia.instance_id = csha.instance_id
                       );

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_HISTORY_EVENT_PKG.PROCESS_OWNER_HISTORY',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.PROCESS_OWNER_HISTORY',FND_LOG.LEVEL_PROCEDURE);

  l_parent_incident_id := 1;

  l_sr_profile_value := fnd_profile.value_specific('CSM_SR_HIST_DWLD_PARTY');

  IF l_sr_profile_value = 'Y' THEN


  OPEN l_sr_hist_ins_csr;

    LOOP

      IF l_instance_id_tbl.COUNT > 0 THEN

         l_instance_id_tbl.DELETE;

      END IF;

      IF l_incident_id_tbl.COUNT > 0 THEN

         l_incident_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_sr_hist_ins_csr BULK COLLECT INTO l_incident_id_tbl,l_user_id_tbl,l_instance_id_tbl LIMIT 100;
        EXIT WHEN l_incident_id_tbl.COUNT = 0;

          IF l_incident_id_tbl.COUNT > 0 THEN

            FOR i IN l_incident_id_tbl.FIRST..l_incident_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert into csm_service_history_acc table

                CSM_ACC_PKG.Insert_Acc
                  ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
                   ,P_ACC_TABLE_NAME         => g_acc_table_name
                   ,P_SEQ_NAME               => g_seq_name
                   ,P_PK1_NAME               => g_pk1_name
                   ,P_PK1_NUM_VALUE          => l_parent_incident_id
                   ,P_PK2_NAME               => g_pk2_name
                   ,P_PK2_NUM_VALUE          => l_incident_id_tbl(i)
                   ,P_PK3_NAME               => g_pk3_name
                   ,P_PK3_NUM_VALUE          => l_instance_id_tbl(i)
                   ,p_USER_ID                => l_user_id_tbl(i)
                  );

            END LOOP;

            FOR i IN l_incident_id_tbl.FIRST..l_incident_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert into CSM_INCIDENTS_ALL_ACC table

               CSM_ACC_PKG.Insert_Acc
	        ( P_PUBLICATION_ITEM_NAMES => g_incidents_pubi_name
	         ,P_ACC_TABLE_NAME         => g_incidents_acc_table_name
	         ,P_SEQ_NAME               => g_incidents_seq_name
	         ,P_PK1_NAME               => g_incidents_pk1_name
	         ,P_PK1_NUM_VALUE          => l_incident_id_tbl(i)
	         ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

        -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_sr_hist_ins_csr;

  OPEN l_sr_hist_del_csr;

      LOOP

        IF l_instance_id_tbl.COUNT > 0 THEN

           l_instance_id_tbl.DELETE;

        END IF;

        IF l_incident_id_tbl.COUNT > 0 THEN

           l_incident_id_tbl.DELETE;

        END IF;

        IF l_user_id_tbl.COUNT > 0 THEN

           l_user_id_tbl.DELETE;

        END IF;

          FETCH l_sr_hist_del_csr BULK COLLECT INTO l_incident_id_tbl,l_user_id_tbl,l_instance_id_tbl LIMIT 100;
          EXIT WHEN l_incident_id_tbl.COUNT = 0;

            IF l_incident_id_tbl.COUNT > 0 THEN

              FOR i IN l_incident_id_tbl.FIRST..l_incident_id_tbl.LAST LOOP

                --call the CSM_ACC_PKG to delete from csm_service_history_acc table

                  CSM_ACC_PKG.Delete_Acc
                    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
                     ,P_ACC_TABLE_NAME         => g_acc_table_name
                     ,P_PK1_NAME               => g_pk1_name
                     ,P_PK1_NUM_VALUE          => l_parent_incident_id
                     ,P_PK2_NAME               => g_pk2_name
                     ,P_PK2_NUM_VALUE          => l_incident_id_tbl(i)
                     ,P_PK3_NAME               => g_pk3_name
                     ,P_PK3_NUM_VALUE          => l_instance_id_tbl(i)
                     ,p_USER_ID                => l_user_id_tbl(i)
                    );

              END LOOP;

              FOR i IN l_incident_id_tbl.FIRST..l_incident_id_tbl.LAST LOOP

	        --call the CSM_ACC_PKG to Delete from CSM_INCIDENTS_ALL_ACC table

	          CSM_ACC_PKG.Delete_Acc
	      	    ( P_PUBLICATION_ITEM_NAMES => g_incidents_pubi_name
	      	     ,P_ACC_TABLE_NAME         => g_incidents_acc_table_name
	      	     ,P_PK1_NAME               => g_incidents_pk1_name
	      	     ,P_PK1_NUM_VALUE          => l_incident_id_tbl(i)
	      	     ,P_USER_ID                => l_user_id_tbl(i)
	            );

              END LOOP;

            END IF;

          -- commit after every 100 records

        COMMIT;

      END LOOP;

  CLOSE l_sr_hist_del_csr;

  ELSE

  CSM_UTIL_PKG.LOG('The Profile Option CSM: Allow Service Request History Download for Parties
                         is set to NO',FND_LOG.LEVEL_PROCEDURE);

  END IF;

    p_return_status := 'SUCCESS';
    p_error_message := 'SR HISTORY Records are successfully processed';

    CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_HISTORY_EVENT_PKG.PROCESS_OWNER_HISTORY',
                         'CSM_SERVICE_HISTORY_EVENT_PKG.PROCESS_OWNER_HISTORY',FND_LOG.LEVEL_EXCEPTION);


EXCEPTION WHEN OTHERS THEN
    l_sqlerrno      := to_char(SQLCODE);
    l_sqlerrmsg     := substr(SQLERRM, 1,2000);
    p_return_status := 'ERROR';
    p_error_message := l_sqlerrmsg;
    l_error_msg     :='Exception in  PROCESS_OWNER_HISTORY ' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_SERVICE_HISTORY_EVENT_PKG.PROCESS_OWNER_HISTORY',FND_LOG.LEVEL_EXCEPTION);
    RAISE;
END PROCESS_OWNER_HISTORY;

END;

/
