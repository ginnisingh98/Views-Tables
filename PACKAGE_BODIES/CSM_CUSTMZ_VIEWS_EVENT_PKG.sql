--------------------------------------------------------
--  DDL for Package Body CSM_CUSTMZ_VIEWS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CUSTMZ_VIEWS_EVENT_PKG" AS
/* $Header: csmeczvb.pls 120.8.12010000.2 2008/10/22 12:44:36 trajasek ship $ */

/*** Globals ***/
g_cust_view_acc_tab_name          CONSTANT VARCHAR2(30) := 'CSM_CUSTOMIZATION_VIEWS_ACC';
g_cust_view_table_name            CONSTANT VARCHAR2(30) := 'CSM_CUSTOMIZATION_VIEWS';
g_cust_view_seq_name              CONSTANT VARCHAR2(30) := 'CSM_CUSTOMIZATION_VIEWS_ACC_S' ;
g_cust_view_pk1_name              CONSTANT VARCHAR2(30) := 'CUST_VIEW_ID';
g_cust_view_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                                                      CSM_ACC_PKG.t_publication_item_list('CSM_CUSTOMIZATION_VIEWS');

g_cust_view_pkg_name CONSTANT VARCHAR2(30) := 'CSM_CUSTMZ_VIEWS_EVENT_PKG';
g_cust_view_api_name CONSTANT VARCHAR2(30) := 'REFRESH_ACC';


PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
--CURSOR declarations

--cursor to get last run date from jtm_con_request_data
CURSOR  c_LastRundate IS
  SELECT NVL(LAST_RUN_DATE, to_date('1','J')) LAST_RUN_DATE
  FROM   JTM_CON_REQUEST_DATA
  WHERE  package_name   =  g_cust_view_pkg_name
  AND    procedure_name = g_cust_view_api_name;

--Cursor for delete
CURSOR 	c_delete IS
--Delete the records that have been removed from the base table
SELECT 	 ACC.USER_ID,
         ACC.CUST_VIEW_ID,
         ACC.ACCESS_ID
FROM 	 CSM_CUSTOMIZATION_VIEWS_ACC ACC
WHERE NOT EXISTS (SELECT 1
                  FROM 	CSM_CUSTOMIZATION_VIEWS B
                  WHERE  B.CUST_VIEW_ID = ACC.CUST_VIEW_ID)
UNION ALL
--Delete the records that have been personalized at a "higher" level
SELECT 	 ACC.USER_ID,
         ACC.CUST_VIEW_ID,
         ACC.ACCESS_ID
FROM 	 CSM_CUSTOMIZATION_VIEWS_ACC ACC,
         CSM_CUSTOMIZATION_VIEWS BACC  --to get cust_view_key,level_id,level_value for that cust_view_id
WHERE   BACC.CUST_VIEW_ID=ACC.CUST_VIEW_ID
AND     EXISTS(SELECT 1
               FROM  CSM_CUSTOMIZATION_VIEWS B,
                     ASG_USER AU
               WHERE B.PAGE_NAME=BACC.PAGE_NAME
               AND   B.REGION_NAME=BACC.REGION_NAME
               AND   B.CUST_VIEW_KEY=BACC.CUST_VIEW_KEY
               AND   ACC.USER_ID = AU.USER_ID
               AND   AU.USER_ID  = AU.OWNER_ID
               AND  (
                     (BACC.LEVEL_ID = 10001
                      AND BACC.LEVEL_VALUE = 0
                      AND B.LEVEL_ID=10003
                      AND B.LEVEL_VALUE = AU.RESPONSIBILITY_ID) --Site to Resp
                  OR (BACC.LEVEL_ID = 10001
                      AND BACC.LEVEL_VALUE = 0
                      AND B.LEVEL_ID=10004
                      AND B.LEVEL_VALUE = AU.USER_ID) -- Site to User
           	  OR (BACC.LEVEL_ID = 10003
                      AND BACC.LEVEL_VALUE = AU.RESPONSIBILITY_ID
           	      AND B.LEVEL_ID=10004
                      AND B.LEVEL_VALUE = AU.USER_ID)--Resp to User
	             )
              ) ;


--Cursor for update
CURSOR 	c_update(b_lastrundate DATE) IS
SELECT 	ACC.USER_ID,
        ACC.CUST_VIEW_ID,
        ACC.ACCESS_ID
FROM 	CSM_CUSTOMIZATION_VIEWS_ACC ACC
WHERE  EXISTS
       (SELECT 1 FROM CSM_CUSTOMIZATION_VIEWS B
        WHERE  B.CUST_VIEW_ID = ACC.CUST_VIEW_ID
        AND    B.LAST_UPDATE_DATE > b_lastrundate );


--Cursor for insert
CURSOR 	c_insert IS
 SELECT  AU.USER_ID,
         B.CUST_VIEW_ID,
         1 ACCESS_ID
 FROM  CSM_CUSTOMIZATION_VIEWS B,
       ASG_USER AU
 WHERE AU.USER_ID  = AU.OWNER_ID
 AND   (
        (B.LEVEL_ID=10004 AND B.LEVEL_VALUE = AU.USER_ID)
        OR
	--If perz at resp level, verify that no User level perz exists
        (B.LEVEL_ID=10003 AND B.LEVEL_VALUE = AU.RESPONSIBILITY_ID
         AND NOT EXISTS( SELECT 1
	                 FROM CSM_CUSTOMIZATION_VIEWS B1
	  	 	 WHERE B.PAGE_NAME = B1.PAGE_NAME
			 AND   B.REGION_NAME = B1.REGION_NAME
			 AND   B.CUST_VIEW_KEY = B1.CUST_VIEW_KEY
   	                 AND   B1.LEVEL_ID = 10004
	                 AND   B1.LEVEL_VALUE = AU.USER_ID)
                       )
        OR
	--If perz at site level, verify that no resp and User level perz exists
        (B.LEVEL_ID=10001 AND B.LEVEL_VALUE=0
         AND NOT EXISTS( SELECT 1
	                 FROM CSM_CUSTOMIZATION_VIEWS B1
                         WHERE B.PAGE_NAME=B1.PAGE_NAME
                         AND   B.REGION_NAME=B1.REGION_NAME
                         AND   B.CUST_VIEW_KEY=B1.CUST_VIEW_KEY
                         AND   B1.LEVEL_ID=10004
                         AND   B1.LEVEL_VALUE=AU.USER_ID
                       )
         AND NOT EXISTS( SELECT 1
                         FROM CSM_CUSTOMIZATION_VIEWS B1
                         WHERE B.PAGE_NAME=B1.PAGE_NAME
                         AND   B.REGION_NAME=B1.REGION_NAME
                         AND   B.CUST_VIEW_KEY=B1.CUST_VIEW_KEY
                         AND   B1.LEVEL_ID=10003
                         AND   B1.LEVEL_VALUE=AU.RESPONSIBILITY_ID)
		       )
       )
 AND   NOT EXISTS (SELECT 1
                   FROM   CSM_CUSTOMIZATION_VIEWS_ACC ACC
                   WHERE  B.CUST_VIEW_ID = ACC.CUST_VIEW_ID
                   AND    AU.USER_ID = ACC.USER_ID );


TYPE con_rec_type IS RECORD
  (
   USER_ID      ASG_USER.USER_ID%TYPE,
   CUST_VIEW_ID NUMBER,
   ACCESS_ID    NUMBER
  );

TYPE l_tab_type IS TABLE OF con_rec_type
INDEX BY BINARY_INTEGER;

l_tab         l_tab_type;
l_lastrundate c_LastRundate%ROWTYPE;
l_sqlerrno    VARCHAR2(20);
l_sqlerrmsg   VARCHAR2(4000);
l_dummy       BOOLEAN;
l_resource_id NUMBER;
BEGIN
    CSM_UTIL_PKG.LOG('Entering CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc Package ',
                                           'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);

    OPEN c_lastrundate;
    FETCH c_lastrundate INTO l_lastrundate;
    CLOSE c_lastrundate;

    CSM_UTIL_PKG.LOG('Got LASTRUNDATE ','CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);

  --delete--

   OPEN   c_delete;
   FETCH  c_delete BULK COLLECT INTO l_tab;
   CLOSE  c_delete;


  CSM_UTIL_PKG.LOG('Entering DELETE to remove ' || l_tab.count||' records',
                             'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
      CSM_ACC_PKG.DELETE_ACC(
      p_publication_item_names => g_cust_view_pubi_name,
	  p_acc_table_name         => g_cust_view_acc_tab_name ,
	  p_user_id                => l_tab(I).USER_ID,
	  p_pk1_name               => g_cust_view_pk1_name,
	  p_pk1_num_value          => l_tab(I).CUST_VIEW_ID);
  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('DELETION successful',
                             'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);

  l_tab.DELETE;


  --update--
  OPEN  c_update(l_lastrundate.LAST_RUN_DATE);
  FETCH c_update BULK COLLECT INTO l_tab;
  CLOSE c_update;

  CSM_UTIL_PKG.LOG('Entering UPDATE to update ' || l_tab.count||' records',
                             'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
    CSM_ACC_PKG.UPDATE_ACC(
    p_publication_item_names => g_cust_view_pubi_name,
    p_acc_table_name         => g_cust_view_acc_tab_name ,
    p_user_id                => l_tab(I).USER_ID,
    p_access_id              => l_tab(I).ACCESS_ID);
  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('UPDATE Successful ',
                             'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);
  l_tab.DELETE;

  --insert--
  OPEN  c_insert;
  FETCH c_insert BULK COLLECT INTO l_tab;
  CLOSE c_insert;

  CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_tab.count||' records',
                            'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
    CSM_ACC_PKG.INSERT_ACC(
      p_publication_item_names => g_cust_view_pubi_name,
	  p_acc_table_name         => g_cust_view_acc_tab_name ,
	  p_seq_name               => g_cust_view_seq_name,
	  p_user_id                => l_tab(I).USER_ID,
	  p_pk1_name               => g_cust_view_pk1_name,
	  p_pk1_num_value          => l_tab(I).CUST_VIEW_ID);
  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('INSERTION Successful ',
                             'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);


  UPDATE jtm_con_request_data
  SET    last_run_date   = sysdate
  WHERE  package_name =  g_cust_view_pkg_name
  AND    procedure_name = g_cust_view_api_name;



  COMMIT;
  p_status := 'FINE';
  p_message :=  'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc Executed successfully';
  CSM_UTIL_PKG.LOG('Leaving CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc Package ',
                                       'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status 	 := 'ERROR';
     p_message   := 'Error in CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc :' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(p_message, 'CSM_CUSTMZ_VIEWS_EVENT_PKG.Refresh_Acc',FND_LOG.LEVEL_EXCEPTION);
     ROLLBACK;

END Refresh_Acc;


--Bug 7239431
PROCEDURE REFRESH_USER(p_user_id NUMBER)
IS

--Cursor for insert
CURSOR 	c_insert(b_user_id NUMBER) IS
 SELECT  AU.USER_ID,
         B.CUST_VIEW_ID,
         1 ACCESS_ID
 FROM  CSM_CUSTOMIZATION_VIEWS B,
       ASG_USER AU
 WHERE AU.USER_ID  = AU.OWNER_ID
 AND   AU.USER_ID = b_user_id
 AND   (
        (B.LEVEL_ID=10004 AND B.LEVEL_VALUE = AU.USER_ID)
        OR
	--If perz at resp level, verify that no User level perz exists
        (B.LEVEL_ID=10003 AND B.LEVEL_VALUE = AU.RESPONSIBILITY_ID
         AND NOT EXISTS( SELECT 1
	                 FROM CSM_CUSTOMIZATION_VIEWS B1
	  	 	 WHERE B.PAGE_NAME = B1.PAGE_NAME
			 AND   B.REGION_NAME = B1.REGION_NAME
			 AND   B.CUST_VIEW_KEY = B1.CUST_VIEW_KEY
   	                 AND   B1.LEVEL_ID = 10004
	                 AND   B1.LEVEL_VALUE = AU.USER_ID)
                       )
        OR
	--If perz at site level, verify that no resp and User level perz exists
        (B.LEVEL_ID=10001 AND B.LEVEL_VALUE=0
         AND NOT EXISTS( SELECT 1
	                 FROM CSM_CUSTOMIZATION_VIEWS B1
                         WHERE B.PAGE_NAME=B1.PAGE_NAME
                         AND   B.REGION_NAME=B1.REGION_NAME
                         AND   B.CUST_VIEW_KEY=B1.CUST_VIEW_KEY
                         AND   B1.LEVEL_ID=10004
                         AND   B1.LEVEL_VALUE=AU.USER_ID
                       )
         AND NOT EXISTS( SELECT 1
                         FROM CSM_CUSTOMIZATION_VIEWS B1
                         WHERE B.PAGE_NAME=B1.PAGE_NAME
                         AND   B.REGION_NAME=B1.REGION_NAME
                         AND   B.CUST_VIEW_KEY=B1.CUST_VIEW_KEY
                         AND   B1.LEVEL_ID=10003
                         AND   B1.LEVEL_VALUE=AU.RESPONSIBILITY_ID)
		       )
       );


TYPE con_rec_type IS RECORD
  (
   USER_ID      ASG_USER.USER_ID%TYPE,
   CUST_VIEW_ID NUMBER,
   ACCESS_ID    NUMBER
  );

TYPE l_tab_type IS TABLE OF con_rec_type
INDEX BY BINARY_INTEGER;

l_tab         l_tab_type;

BEGIN

  CSM_UTIL_PKG.LOG('Entering api REFRESH_USER with user id- '||p_user_id,
                            'CSM_CUSTMZ_VIEWS_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

  DELETE FROM CSM_CUSTOMIZATION_VIEWS_ACC WHERE USER_ID=p_user_id;

  --insert--
  OPEN c_insert(p_user_id);
  FETCH c_insert BULK COLLECT INTO l_tab;
  CLOSE c_insert;

  CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_tab.count||' records for user',
                            'CSM_CUSTMZ_VIEWS_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
    CSM_ACC_PKG.INSERT_ACC(
      p_publication_item_names => g_cust_view_pubi_name,
	  p_acc_table_name         => g_cust_view_acc_tab_name ,
	  p_seq_name               => g_cust_view_seq_name,
	  p_user_id                => l_tab(I).USER_ID,
	  p_pk1_name               => g_cust_view_pk1_name,
	  p_pk1_num_value          => l_tab(I).CUST_VIEW_ID);
  END LOOP;

  CSM_UTIL_PKG.LOG('INSERTION Successful ',
                             'CSM_CUSTMZ_VIEWS_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

END REFRESH_USER;

END CSM_CUSTMZ_VIEWS_EVENT_PKG;

/
