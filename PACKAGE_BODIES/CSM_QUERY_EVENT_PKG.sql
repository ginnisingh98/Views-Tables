--------------------------------------------------------
--  DDL for Package Body CSM_QUERY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_QUERY_EVENT_PKG" AS
/* $Header: csmeqryb.pls 120.5.12010000.4 2009/09/24 06:49:15 trajasek noship $*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
g_pub_item_qry     VARCHAR2(50)  := 'CSM_QUERY';
g_pub_item_qvar    VARCHAR2(50)  := 'CSM_QUERY_VARIABLES';
g_pub_item_qval    VARCHAR2(50)  := 'CSM_QUERY_VARIABLE_VALUES';
g_pub_item_qins    VARCHAR2(50)  := 'CSM_QUERY_INSTANCES';
g_pub_item_qres    VARCHAR2(50)  := 'CSM_QUERY_RESULTS';

PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
TYPE QUERY_LIST IS TABLE OF CSM_QUERY_B.QUERY_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE VARIABLE_LIST IS TABLE OF CSM_QUERY_VARIABLES_B.VARIABLE_ID%TYPE INDEX BY BINARY_INTEGER;

l_run_date 		  DATE;
l_sqlerrno 		  VARCHAR2(20);
l_sqlerrmsg 	  VARCHAR2(2000);
l_mark_dirty	  boolean;
g_pub_item 		  VARCHAR2(30) := 'CSM_QUERY';
l_prog_update_date				  jtm_con_request_data.last_run_date%TYPE;
l_access_list		asg_download.access_list;
l_user_list 		asg_download.user_list;
l_query_id_list QUERY_LIST;
l_variable_id_list VARIABLE_LIST;

-- Cursor Declaration
CURSOR c_query_ins
IS
SELECT 	CSM_QUERY_ACC_S.NEXTVAL,
        au.USER_ID,
        b.QUERY_ID
FROM 	CSM_QUERY_B b,
      ASG_USER    au
WHERE (  (b.LEVEL_ID = 10003 AND   b.LEVEL_VALUE = au.responsibility_id)--Support for Responsiblity
      OR (b.LEVEL_ID = 10004 AND   b.LEVEL_VALUE = au.USER_ID)
      OR (b.LEVEL_ID = 10001 AND   b.LEVEL_VALUE =0)   )
AND   au.USER_ID  = au.OWNER_ID
AND   au.ENABLED= 'Y'
AND   NVL(b.DELETE_FLAG,'N') = 'N'
AND   NOT EXISTS
    	(
        SELECT	1
      	FROM 	  CSM_QUERY_ACC acc
        WHERE 	acc.QUERY_ID = b.QUERY_ID
        AND     acc.USER_ID  = au.USER_ID
    	);

CURSOR c_query_var_ins
IS
SELECT 	CSM_QUERY_VARIABLES_ACC_S.NEXTVAL,
        qacc.USER_ID,
        b.QUERY_ID,
        b.VARIABLE_ID
FROM 	CSM_QUERY_VARIABLES_B b,
      CSM_QUERY_ACC    qacc
WHERE qacc.QUERY_ID = b.QUERY_ID
AND   NOT EXISTS
    	(
        SELECT	1
      	FROM 	  CSM_QUERY_VARIABLES_ACC vacc
        WHERE 	vacc.QUERY_ID = qacc.QUERY_ID
        AND     vacc.USER_ID  = qacc.USER_ID
        AND     b.VARIABLE_ID = vacc.VARIABLE_ID
    	);


--Update Cursor
CURSOR 	c_query_upd(p_lastrundate IN date)
IS
SELECT 	acc.ACCESS_ID,
        acc.USER_ID
FROM 	  CSM_QUERY_ACC		acc,
        CSM_QUERY_B 	b
WHERE 	acc.QUERY_ID 		 = b.QUERY_ID
AND 	  b.LAST_UPDATE_DATE >= p_lastrundate;

CURSOR 	c_query_var_upd(p_lastrundate IN date)
IS
SELECT 	acc.ACCESS_ID,
        acc.USER_ID
FROM 	  CSM_QUERY_VARIABLES_ACC		acc,
        CSM_QUERY_VARIABLES_B 	b
WHERE 	acc.QUERY_ID 		 = b.QUERY_ID
AND     acc.VARIABLE_ID  = b.VARIABLE_ID
AND 	  b.LAST_UPDATE_DATE >= p_lastrundate;


--Delete Cursors
CURSOR 	c_query_del
IS
SELECT 	acc.ACCESS_ID,
        acc.USER_ID
FROM 	  CSM_QUERY_ACC		acc
WHERE	EXISTS
		(SELECT 1
		  FROM	CSM_QUERY_B b
		  WHERE b.QUERY_ID 	=  acc.QUERY_ID
      AND   NVL(b.DELETE_FLAG,'N') ='Y'
		 );
--Delete Query Variables from the ACC
CURSOR 	c_query_variables_del
IS
SELECT 	acc.ACCESS_ID,
        acc.USER_ID
FROM 	  CSM_QUERY_VARIABLES_ACC		acc,
      	CSM_QUERY_B b
WHERE   b.QUERY_ID 	=  acc.QUERY_ID
AND     NVL(b.DELETE_FLAG,'N') ='Y';

--Delete Query Instances from the ACC
CURSOR 	c_query_instances_del
IS
SELECT 	acc.ACCESS_ID,
        acc.USER_ID
FROM 	  CSM_QUERY_INSTANCES_ACC		acc,
      	CSM_QUERY_B b
WHERE   b.QUERY_ID 	=  acc.QUERY_ID
AND    ( NVL(b.DELETE_FLAG,'N') ='Y'
      OR  (   UPPER(b.RETENTION_POLICY) = 'AUTOMATIC'
          AND acc.LAST_UPDATE_DATE      < (SYSDATE-nvl(b.RETENTION_DAYS,1000))
       )) ;

--Delete Query Variable Values from the ACC
CURSOR 	c_query_variables_val_del
IS
SELECT 	acc.ACCESS_ID,
        acc.USER_ID
FROM 	  CSM_QUERY_VARIABLE_VALUES_ACC		acc
WHERE   NOT EXISTS
        (SELECT 1 FROM CSM_QUERY_INSTANCES_ACC iacc
         WHERE iacc.USER_ID     = acc.USER_ID
         AND   iacc.INSTANCE_ID = acc.INSTANCE_ID
         AND   iacc.QUERY_ID    = acc.QUERY_ID);

--Delete Query Results from the ACC
CURSOR 	c_query_results_del
IS
SELECT 	acc.ACCESS_ID,
        acc.USER_ID
FROM 	  CSM_QUERY_RESULTS_ACC		acc
WHERE   NOT EXISTS
        (SELECT 1 FROM CSM_QUERY_INSTANCES_ACC iacc
         WHERE iacc.USER_ID     = acc.USER_ID
         AND   iacc.INSTANCE_ID = acc.INSTANCE_ID
         AND   iacc.QUERY_ID    = acc.QUERY_ID);

CURSOR	l_last_run_date_csr
IS
SELECT 	nvl(last_run_date, (sysdate - 365*50))
FROM 	  jtm_con_request_data
WHERE 	package_name 	= 'CSM_QUERY_EVENT_PKG'
AND 	  procedure_name  = 'REFRESH_ACC';

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_QUERY_EVENT_PKG.REFRESH_ACC ',
                         'CSM_QUERY_EVENT_PKG.REFRESH_ACC', FND_LOG.LEVEL_PROCEDURE);

 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN 	l_last_run_date_csr;
 FETCH  l_last_run_date_csr INTO l_prog_update_date;
 CLOSE  l_last_run_date_csr;

 CSM_UTIL_PKG.LOG('Entering deletes ', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_STATEMENT);

 -- process all DELETES
 -------------------------------------------------------------------------------

 -- process Query Deletion from Acc
 OPEN 	c_query_del;
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;

 FETCH  c_query_del BULK COLLECT INTO l_access_list,l_user_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qry,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.del,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   FORALL i IN 1..l_access_list.count
     DELETE FROM csm_query_acc WHERE access_id = l_access_list(i);

  COMMIT;

 END LOOP;
 CLOSE  c_query_del;
CSM_UTIL_PKG.LOG('Completed Query Delete', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

-- process Query Variables Deletion from ACC table
 OPEN 	c_query_variables_del;
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;

 FETCH  c_query_variables_del BULK COLLECT INTO l_access_list,l_user_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qvar,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.del,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   FORALL i IN 1..l_access_list.count
     DELETE FROM csm_query_variables_acc WHERE access_id = l_access_list(i);

  COMMIT;

 END LOOP;
 CLOSE  c_query_variables_del;
CSM_UTIL_PKG.LOG('Completed Query Variables Delete', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

-- process Query Instances Deletion from ACC table
 OPEN 	c_query_instances_del;
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;

 FETCH  c_query_instances_del BULK COLLECT INTO l_access_list,l_user_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qins,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.del,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   FORALL i IN 1..l_access_list.count
     DELETE FROM CSM_QUERY_INSTANCES_ACC WHERE access_id = l_access_list(i);

  COMMIT;

 END LOOP;
 CLOSE  c_query_instances_del;
CSM_UTIL_PKG.LOG('Completed Query Instances Delete', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

-- process Query Variables values Deletion from ACC table
 OPEN 	c_query_variables_val_del;
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;

 FETCH  c_query_variables_val_del BULK COLLECT INTO l_access_list,l_user_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qval,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.del,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   FORALL i IN 1..l_access_list.count
     DELETE FROM CSM_QUERY_VARIABLE_VALUES_ACC WHERE access_id = l_access_list(i);

  COMMIT;

 END LOOP;
 CLOSE  c_query_variables_val_del;
CSM_UTIL_PKG.LOG('Completed Query Variable Values Delete', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

-- process Query Results Deletion from ACC table
 OPEN 	c_query_results_del;
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;

 FETCH  c_query_results_del BULK COLLECT INTO l_access_list,l_user_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qres,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.del,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   FORALL i IN 1..l_access_list.count
     DELETE FROM CSM_QUERY_RESULTS_ACC WHERE access_id = l_access_list(i);

  COMMIT;

 END LOOP;
 CLOSE  c_query_results_del;
 CSM_UTIL_PKG.LOG('Completed Query Results Delete', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 CSM_UTIL_PKG.LOG('Leaving deletes and entering updates', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);
 -- process all updates
 -------------------------------------------------------------------------------

 --PRocess Query updates
 OPEN 	c_query_upd(l_prog_update_date);
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;

 FETCH  c_query_upd BULK COLLECT INTO l_access_list,l_user_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qry,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.upd,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   COMMIT;

 END LOOP;
 CLOSE  c_query_upd;
CSM_UTIL_PKG.LOG('Completed Query Updates', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 --PRocess Query updates
 OPEN 	c_query_var_upd(l_prog_update_date);
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;

 FETCH  c_query_var_upd BULK COLLECT INTO l_access_list,l_user_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qvar,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.upd,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   COMMIT;

 END LOOP;
 CLOSE  c_query_var_upd;
 CSM_UTIL_PKG.LOG('Completed Query Variable Updates', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);
 CSM_UTIL_PKG.LOG('Leaving updates and entering inserts', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);
 --process all inserts
 -------------------------------------------------------------------------------
 --Process query inserts
 OPEN 	c_query_ins;
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;
 IF l_query_id_list.count >0 THEN
  l_query_id_list.delete;
 END IF;
 FETCH  c_query_ins BULK COLLECT INTO l_access_list,l_user_list,l_query_id_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qry,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.ins,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   FORALL i IN 1..l_access_list.count
     INSERT INTO CSM_QUERY_ACC
	 			(ACCESS_ID,
         USER_ID,
         QUERY_ID,
				 CREATED_BY, CREATION_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATE_LOGIN)
                 VALUES
				 (l_access_list(i),
          l_user_list(i),
				  l_query_id_list(i),
				  fnd_global.user_id,
				  l_run_date,
				  fnd_global.user_id,
				  l_run_date,
				  fnd_global.login_id);

  COMMIT;

  END LOOP;
  CLOSE  c_query_ins;
 CSM_UTIL_PKG.LOG('Completed Query Inserts', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);
--Process query variable inserts
 OPEN 	c_query_var_ins;
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;
 IF l_query_id_list.count >0 THEN
  l_query_id_list.delete;
 END IF;
 IF l_variable_id_list.count >0 THEN
  l_variable_id_list.delete;
 END IF;


 FETCH  c_query_var_ins BULK COLLECT INTO l_access_list,l_user_list,l_query_id_list,l_variable_id_list LIMIT 1000;
 EXIT WHEN l_access_list.count = 0;

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qvar,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.ins,
                                                 p_timestamp   => l_run_date);

   END LOOP;
   FORALL i IN 1..l_access_list.count
     INSERT INTO CSM_QUERY_VARIABLES_ACC
	 			(ACCESS_ID,
         USER_ID,
         QUERY_ID,
         VARIABLE_ID,
				 CREATED_BY,
         CREATION_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATE_LOGIN,
         GEN_PK)
                 VALUES
				 (l_access_list(i),
          l_user_list(i),
				  l_query_id_list(i),
          l_variable_id_list(i),
				  fnd_global.user_id,
				  l_run_date,
				  fnd_global.user_id,
				  l_run_date,
				  fnd_global.login_id,
          l_access_list(i));

  COMMIT;

  END LOOP;
  CLOSE  c_query_var_ins;
  CSM_UTIL_PKG.LOG('Completed Query Variable Inserts', 'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  --Delete Saved Queries that are deleted as part of Parent Query
  DELETE FROM CSM_QUERY_B
  WHERE LEVEL_ID =10004
  AND   SAVED_QUERY ='Y'
  AND   DELETE_FLAG ='Y';

  -- update last_run_date
  UPDATE	jtm_con_request_data
  SET 	last_run_date 	= l_run_date
  WHERE 	package_name 	= 'CSM_QUERY_EVENT_PKG'
  AND 	procedure_name 	= 'REFRESH_ACC';

 COMMIT;

 p_status  := 'FINE';
 p_message :=  'CSM_QUERY_EVENT_PKG.REFRESH_ACC Executed successfully';

 CSM_UTIL_PKG.LOG('Leaving CSM_QUERY_EVENT_PKG.REFRESH_ACC ',
                         'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status 	 := 'ERROR';
     p_message 	 := 'Error in CSM_QUERY_EVENT_PKG.REFRESH_ACC :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_QUERY_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_QUERY_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
END REFRESH_ACC;

PROCEDURE REFRESH_USER(p_user_id NUMBER)
IS
TYPE QUERY_LIST IS TABLE OF CSM_QUERY_B.QUERY_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE VARIABLE_LIST IS TABLE OF CSM_QUERY_VARIABLES_B.VARIABLE_ID%TYPE INDEX BY BINARY_INTEGER;
l_sqlerrno 		  VARCHAR2(20);
l_sqlerrmsg 	  VARCHAR2(2000);
l_mark_dirty	  boolean;
l_access_list		asg_download.access_list;
l_user_list 		asg_download.user_list;
l_query_id_list QUERY_LIST;
l_variable_id_list VARIABLE_LIST;

-- Cursor Declaration
CURSOR c_query_ins (c_user_id NUMBER)
IS
SELECT 	CSM_QUERY_ACC_S.NEXTVAL,
        au.USER_ID,
        b.QUERY_ID
FROM 	CSM_QUERY_B b,
      ASG_USER    au
WHERE (  (b.LEVEL_ID = 10003 AND   b.LEVEL_VALUE = au.responsibility_id)--Support for Responsiblity
      OR (b.LEVEL_ID = 10004 AND   b.LEVEL_VALUE = au.USER_ID)--Saved Query
      OR (b.LEVEL_ID = 10001 AND   b.LEVEL_VALUE =0)   )--Site level
AND   au.USER_ID             = c_user_id
AND   au.USER_ID             = au.OWNER_ID
AND   NVL(b.DELETE_FLAG,'N') = 'N'
AND   NOT EXISTS
    	(
        SELECT	1
      	FROM 	  CSM_QUERY_ACC acc
        WHERE 	acc.QUERY_ID = b.QUERY_ID
        AND     acc.USER_ID  = au.user_ID
    	);

CURSOR c_query_var_ins(c_user_id NUMBER)
IS
SELECT 	CSM_QUERY_VARIABLES_ACC_S.NEXTVAL,
        qacc.USER_ID,
        b.QUERY_ID,
        b.VARIABLE_ID
FROM 	CSM_QUERY_VARIABLES_B b,
      CSM_QUERY_ACC    qacc
WHERE qacc.QUERY_ID = b.QUERY_ID
AND   qacc.USER_ID  = c_user_id
AND   NOT EXISTS
    	(
        SELECT	1
      	FROM 	  CSM_QUERY_VARIABLES_ACC vacc
        WHERE 	vacc.QUERY_ID = qacc.QUERY_ID
        AND     vacc.USER_ID  = qacc.USER_ID
        AND     b.VARIABLE_ID = vacc.VARIABLE_ID
    	);
BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_QUERY_EVENT_PKG.REFRESH_ACC For User id :'|| p_user_id,
                         'CSM_QUERY_EVENT_PKG.REFRESH_ACC', FND_LOG.LEVEL_PROCEDURE);

OPEN 	c_query_ins(p_user_id);
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;
 IF l_query_id_list.count >0 THEN
  l_query_id_list.delete;
 END IF;

 FETCH  c_query_ins BULK COLLECT INTO l_access_list,l_user_list,l_query_id_list LIMIT 100;
 EXIT WHEN l_access_list.count = 0;

   FORALL i IN 1..l_access_list.count
     INSERT INTO CSM_QUERY_ACC
	 			(ACCESS_ID,
         USER_ID,
         QUERY_ID,
				 CREATED_BY, CREATION_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATE_LOGIN)
                 VALUES
				 (l_access_list(i),
          l_user_list(i),
				  l_query_id_list(i),
				  fnd_global.user_id,
				  sysdate,
				  fnd_global.user_id,
				  sysdate,
				  fnd_global.login_id);

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qry,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.ins,
                                                 p_timestamp   => sysdate);

   END LOOP;
  END LOOP;
  CLOSE  c_query_ins;
 CSM_UTIL_PKG.LOG('Completed Query Inserts for User id :'|| p_user_id, 'CSM_QUERY_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);


--Process query variable inserts
 OPEN 	c_query_var_ins(p_user_id);
 LOOP
 IF l_access_list.count >0 THEN
  l_access_list.delete;
 END IF;
 IF l_user_list.count >0 THEN
  l_user_list.delete;
 END IF;
 IF l_query_id_list.count >0 THEN
  l_query_id_list.delete;
 END IF;
 IF l_variable_id_list.count >0 THEN
  l_variable_id_list.delete;
 END IF;


 FETCH  c_query_var_ins BULK COLLECT INTO l_access_list,l_user_list,l_query_id_list,l_variable_id_list LIMIT 100;
 EXIT WHEN l_access_list.count = 0;

   FORALL i IN 1..l_access_list.count
     INSERT INTO CSM_QUERY_VARIABLES_ACC
	 			(ACCESS_ID,
         USER_ID,
         QUERY_ID,
         VARIABLE_ID,
				 CREATED_BY,
         CREATION_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATE_LOGIN,
         GEN_PK)
                 VALUES
				 (l_access_list(i),
          l_user_list(i),
				  l_query_id_list(i),
          l_variable_id_list(i),
				  fnd_global.user_id,
				  sysdate,
				  fnd_global.user_id,
				  sysdate,
				  fnd_global.login_id,
          l_access_list(i));

   FOR i IN 1..l_access_list.count LOOP
        l_mark_dirty := asg_Download.mark_dirty (p_pub_item    => g_pub_item_qvar,
                                                 p_accessid    => l_access_list(i),
                                                 p_userid      => l_user_list(i),
                                                 p_dml         => asg_download.ins,
                                                 p_timestamp   => sysdate);

   END LOOP;

  END LOOP;
  CLOSE  c_query_var_ins;
  CSM_UTIL_PKG.LOG('Completed Query Variable Inserts for User id: '|| p_user_id, 'CSM_QUERY_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     RAISE;
     CSM_UTIL_PKG.LOG('Exception in CSM_QUERY_EVENT_PKG.REFRESH_USER: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_QUERY_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_EXCEPTION);
END REFRESH_USER;

END CSM_QUERY_EVENT_PKG;

/
