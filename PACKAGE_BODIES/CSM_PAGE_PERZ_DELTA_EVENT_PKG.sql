--------------------------------------------------------
--  DDL for Package Body CSM_PAGE_PERZ_DELTA_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PAGE_PERZ_DELTA_EVENT_PKG" AS
/* $Header: csmeppdb.pls 120.5.12010000.2 2008/10/22 12:43:20 trajasek ship $ */

/*** Globals ***/
g_page_perz_delta_acc_tab_name          CONSTANT VARCHAR2(30) := 'CSM_PAGE_PERZ_DELTA_ACC';
g_page_perz_delta_table_name            CONSTANT VARCHAR2(30) := 'CSM_PAGE_PERZ_DELTA';
g_page_perz_delta_seq_name              CONSTANT VARCHAR2(30) := 'CSM_PAGE_PERZ_DELTA_ACC_S' ;
g_page_perz_delta_pubi_name             CONSTANT VARCHAR2(30) := 'CSM_PAGE_PERZ_DELTA';

g_page_perz_delta_pkg_name              CONSTANT VARCHAR2(30) := 'CSM_PAGE_PERZ_DELTA_EVENT_PKG';
g_page_perz_delta_api_name              CONSTANT VARCHAR2(30) := 'REFRESH_PAGE_PERZ_DELTA';



PROCEDURE REFRESH_PAGE_PERZ_DELTA(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
 /*** get the last run date of the concurent program ***/
CURSOR  c_LastRundate IS
  SELECT NVL(LAST_RUN_DATE, to_date('1','J')) LAST_RUN_DATE
  FROM   JTM_CON_REQUEST_DATA
  WHERE  package_name =  g_page_perz_delta_pkg_name
  AND    procedure_name = g_page_perz_delta_api_name;

 --DELETE--
CURSOR c_delete IS
  SELECT ACC.ACCESS_ID,
         ACC.PAGE_PERZ_ID,
         ACC.LEVEL_ID,
         ACC.LEVEL_VALUE,
         ACC.DELTA_FILE_NAME,
         ACC.DELTA_FILE_TYPE,
         ACC.DELTA_SERVER_VERSION,
         ACC.DELTA_CLIENT_VERSION,
         ACC.FILE_DATA,
         ACC.USER_ID
  FROM  CSM_PAGE_PERZ_DELTA_ACC ACC,
        ASG_USER AU
  WHERE ACC.USER_ID=AU.USER_ID
  AND   AU.USER_ID =AU.OWNER_ID
  AND   EXISTS(SELECT 1
               FROM  CSM_PAGE_PERZ_DELTA CPPD
               WHERE CPPD.PAGE_PERZ_ID=ACC.PAGE_PERZ_ID
               AND   CPPD.LEVEL_ID<>10001
               AND  (
                     (ACC.LEVEL_ID = 10001
                      AND ACC.LEVEL_VALUE = 0
                      AND CPPD.LEVEL_ID=10003
                      AND CPPD.LEVEL_VALUE = AU.RESPONSIBILITY_ID) --Site to Resp
                  OR (ACC.LEVEL_ID = 10001
                      AND ACC.LEVEL_VALUE = 0
                      AND CPPD.LEVEL_ID=10004
                      AND CPPD.LEVEL_VALUE = AU.USER_ID) -- Site to User
            	  OR (ACC.LEVEL_ID = 10003
                      AND ACC.LEVEL_VALUE = AU.RESPONSIBILITY_ID
             	      AND CPPD.LEVEL_ID=10004
                      AND CPPD.LEVEL_VALUE = AU.USER_ID)--Resp to User
	               )
              )
  UNION ALL
  SELECT ACC.ACCESS_ID,
         ACC.PAGE_PERZ_ID,
         ACC.LEVEL_ID,
         ACC.LEVEL_VALUE,
         ACC.DELTA_FILE_NAME,
         ACC.DELTA_FILE_TYPE,
         ACC.DELTA_SERVER_VERSION,
         ACC.DELTA_CLIENT_VERSION,
         ACC.FILE_DATA,
         ACC.USER_ID
  FROM  CSM_PAGE_PERZ_DELTA_ACC ACC
  WHERE NOT EXISTS (SELECT 1 FROM CSM_PAGE_PERZ CPP
                    WHERE CPP.PAGE_PERZ_ID= ACC.PAGE_PERZ_ID)
        OR
        NOT EXISTS (SELECT 1 FROM CSM_PAGE_PERZ_DELTA CPPD
                    WHERE CPPD.PAGE_PERZ_ID= ACC.PAGE_PERZ_ID
         		    AND   CPPD.LEVEL_ID    = ACC.LEVEL_ID
	         	    AND   CPPD.LEVEL_VALUE = ACC.LEVEL_VALUE);


 --UPDATE--
CURSOR 	c_update(b_lastrundate DATE) IS
  SELECT ACC.ACCESS_ID,
         ACC.PAGE_PERZ_ID,
         ACC.LEVEL_ID,
         ACC.LEVEL_VALUE,
         CPPD.DELTA_FILE_NAME,
         CPPD.DELTA_FILE_TYPE,
         CPPD.DELTA_SERVER_VERSION,
         CPPD.DELTA_CLIENT_VERSION,
         CPPD.FILE_DATA,
         ACC.USER_ID
  FROM  CSM_PAGE_PERZ_DELTA_ACC ACC,
        CSM_PAGE_PERZ_DELTA CPPD
  WHERE CPPD.PAGE_PERZ_ID= ACC.PAGE_PERZ_ID
  AND   CPPD.LEVEL_ID    = ACC.LEVEL_ID
  AND   CPPD.LEVEL_VALUE = ACC.LEVEL_VALUE
  AND   CPPD.LAST_UPDATE_DATE > b_lastrundate ;


 --INSERT--
CURSOR  c_insert IS
  SELECT 1 ACCESS_ID,
         CPPD.PAGE_PERZ_ID,
         CPPD.LEVEL_ID,
         CPPD.LEVEL_VALUE,
         CPPD.DELTA_FILE_NAME,
         CPPD.DELTA_FILE_TYPE,
         CPPD.DELTA_SERVER_VERSION,
         CPPD.DELTA_CLIENT_VERSION,
         CPPD.FILE_DATA,
         AU.USER_ID
  FROM CSM_PAGE_PERZ CPP,
       CSM_PAGE_PERZ_DELTA CPPD,
       ASG_USER AU
  WHERE CPP.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
  AND   AU.USER_ID =AU.OWNER_ID
  AND ( (CPPD.LEVEL_VALUE = AU.USER_ID
         AND CPPD.LEVEL_ID = 10004)
      OR
        (CPPD.LEVEL_VALUE = AU.RESPONSIBILITY_ID
         AND CPPD.LEVEL_ID = 10003
 	     AND NOT EXISTS (SELECT 1
		                 FROM CSM_PAGE_PERZ_DELTA CPPD1
	                     WHERE CPPD1.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
	                     AND   CPPD1.LEVEL_ID = 10004
	                     AND   CPPD1.LEVEL_VALUE= AU.USER_ID ))
      OR
       (CPPD.LEVEL_VALUE=0
        AND  CPPD.LEVEL_ID = 10001
 	    AND NOT EXISTS (SELECT 1
		                FROM CSM_PAGE_PERZ_DELTA CPPD1
	                    WHERE CPPD1.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
	                    AND   CPPD1.LEVEL_ID = 10003
	                    AND   CPPD1.LEVEL_VALUE= AU.RESPONSIBILITY_ID )
 	    AND NOT EXISTS (SELECT 1
	                    FROM CSM_PAGE_PERZ_DELTA CPPD1
	                    WHERE CPPD1.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
	                    AND   CPPD1.LEVEL_ID = 10004
	                    AND   CPPD1.LEVEL_VALUE= AU.USER_ID ))
      )
  AND NOT EXISTS (SELECT 1
                  FROM CSM_PAGE_PERZ_DELTA_ACC ACC
                  WHERE ACC.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
		          AND   ACC.LEVEL_ID = CPPD.LEVEL_ID
                  AND   ACC.LEVEL_VALUE = CPPD.LEVEL_VALUE
                  AND   ACC.USER_ID = AU.USER_ID);

CURSOR C_GET_ACCESS_ID IS
 SELECT CSM_PAGE_PERZ_DELTA_ACC_S.NEXTVAL
 FROM DUAL;

TYPE con_rec_type IS RECORD
  (
   ACCESS_ID CSM_PAGE_PERZ_DELTA_ACC.ACCESS_ID%TYPE,
   PAGE_PERZ_ID CSM_PAGE_PERZ_DELTA.PAGE_PERZ_ID%TYPE,
   LEVEL_ID CSM_PAGE_PERZ_DELTA.LEVEL_ID%TYPE,
   LEVEL_VALUE CSM_PAGE_PERZ_DELTA.LEVEL_VALUE%TYPE,
   DELTA_FILE_NAME CSM_PAGE_PERZ_DELTA.DELTA_FILE_NAME%TYPE,
   DELTA_FILE_TYPE CSM_PAGE_PERZ_DELTA.DELTA_FILE_TYPE%TYPE,
   DELTA_SERVER_VERSION CSM_PAGE_PERZ_DELTA.DELTA_SERVER_VERSION%TYPE,
   DELTA_CLIENT_VERSION CSM_PAGE_PERZ_DELTA.DELTA_CLIENT_VERSION%TYPE,
   FILE_DATA CSM_PAGE_PERZ_DELTA.FILE_DATA%TYPE,
   USER_ID ASG_USER.USER_ID%TYPE
  );

TYPE l_tab_type IS TABLE OF con_rec_type
INDEX BY BINARY_INTEGER;

l_tab         l_tab_type;
l_lastrundate c_LastRundate%ROWTYPE;
l_sqlerrno    VARCHAR2(20);
l_sqlerrmsg   VARCHAR2(4000);
l_access_id   NUMBER;
l_dummy       BOOLEAN;

BEGIN

  CSM_UTIL_PKG.LOG('Entering REFRESH_PAGE_PERZ_DELTA: ',
                             'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);

  OPEN c_lastrundate;
  FETCH c_lastrundate INTO l_lastrundate;
  CLOSE c_lastrundate;

  CSM_UTIL_PKG.LOG('Got LASTRUNDATE ',
                             'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);
  --delete--
  OPEN  c_delete;
  FETCH  c_delete BULK COLLECT INTO l_tab;
  CLOSE  c_delete;

  CSM_UTIL_PKG.LOG('Entering DELETE to remove ' || l_tab.count||' records',
                             'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
   l_dummy := asg_download.mark_dirty(g_page_perz_delta_pubi_name,l_tab(I).ACCESS_ID ,  l_tab(I).USER_ID, 'D', sysdate );

   DELETE FROM CSM_PAGE_PERZ_DELTA_ACC WHERE ACCESS_ID=l_tab(I).ACCESS_ID;
  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('DELETION successful',
                             'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);

  l_tab.DELETE;


  --update--
  OPEN c_update(l_lastrundate.LAST_RUN_DATE);
  FETCH c_update BULK COLLECT INTO l_tab;
  CLOSE c_update;

  CSM_UTIL_PKG.LOG('Entering UPDATE to update ' || l_tab.count||' records',
                             'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
   l_dummy := asg_download.mark_dirty(g_page_perz_delta_pubi_name,l_tab(I).ACCESS_ID,l_tab(I).USER_ID, 'U', sysdate );

    UPDATE CSM_PAGE_PERZ_DELTA_ACC
	SET
         DELTA_FILE_NAME=l_tab(I).DELTA_FILE_NAME,
         DELTA_FILE_TYPE=l_tab(I).DELTA_FILE_TYPE,
         DELTA_SERVER_VERSION=l_tab(I).DELTA_SERVER_VERSION,
         DELTA_CLIENT_VERSION=l_tab(I).DELTA_CLIENT_VERSION,
         FILE_DATA=l_tab(I).FILE_DATA,
         LAST_UPDATE_DATE=SYSDATE,
         LAST_UPDATED_BY=1,
         LAST_UPDATE_LOGIN=1
   	WHERE  ACCESS_ID=l_tab(I).ACCESS_ID;
  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('UPDATE Successful ',
                             'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);
  l_tab.DELETE;

  --insert--
  OPEN c_insert;
  FETCH c_insert BULK COLLECT INTO l_tab;
  CLOSE c_insert;

  CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_tab.count||' records',
                            'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
     OPEN  C_GET_ACCESS_ID;
     FETCH C_GET_ACCESS_ID INTO l_access_id;
     CLOSE C_GET_ACCESS_ID;

     INSERT INTO CSM_PAGE_PERZ_DELTA_ACC
     ( ACCESS_ID,
       PAGE_PERZ_ID,
       LEVEL_ID,
       LEVEL_VALUE,
       DELTA_FILE_NAME,
       DELTA_FILE_TYPE,
       DELTA_SERVER_VERSION,
       DELTA_CLIENT_VERSION,
       FILE_DATA,
       USER_ID,
       COUNTER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN
	 )
     VALUES
	 ( l_access_id,
           l_tab(I).PAGE_PERZ_ID,
           l_tab(I).LEVEL_ID,
           l_tab(I).LEVEL_VALUE,
           l_tab(I).DELTA_FILE_NAME,
           l_tab(I).DELTA_FILE_TYPE,
           l_tab(I).DELTA_SERVER_VERSION,
           l_tab(I).DELTA_CLIENT_VERSION,
           l_tab(I).FILE_DATA,
           l_tab(I).USER_ID,
 	   1,
 	   1,
 	   SYSDATE,
 	   1,
 	   SYSDATE,
 	   1
     );

   l_dummy := asg_download.mark_dirty(g_page_perz_delta_pubi_name,l_access_id , l_tab(I).USER_ID, 'I', sysdate );

  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('INSERTION Successful ',
                             'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);

  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = SYSDATE
  WHERE  package_name =  g_page_perz_delta_pkg_name
  AND    procedure_name = g_page_perz_delta_api_name;

  COMMIT;

  p_status  := 'FINE';
  p_message := 'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA executed successfully';

  CSM_UTIL_PKG.LOG('Leaving REFRESH_PAGE_PERZ_DELTA: ',
                              'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     l_sqlerrno  := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_PAGE_PERZ_DELTA ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);

END REFRESH_PAGE_PERZ_DELTA;

--7239431
PROCEDURE REFRESH_USER(p_user_id NUMBER)
IS

 --INSERT--
CURSOR  c_insert(b_user_id NUMBER) IS
  SELECT 1 ACCESS_ID,
         CPPD.PAGE_PERZ_ID,
         CPPD.LEVEL_ID,
         CPPD.LEVEL_VALUE,
         CPPD.DELTA_FILE_NAME,
         CPPD.DELTA_FILE_TYPE,
         CPPD.DELTA_SERVER_VERSION,
         CPPD.DELTA_CLIENT_VERSION,
         CPPD.FILE_DATA,
         AU.USER_ID
  FROM CSM_PAGE_PERZ CPP,
       CSM_PAGE_PERZ_DELTA CPPD,
       ASG_USER AU
  WHERE AU.USER_ID=b_user_id
  AND   AU.USER_ID =AU.OWNER_ID
  AND CPP.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
  AND ( (CPPD.LEVEL_VALUE = AU.USER_ID
         AND CPPD.LEVEL_ID = 10004)
      OR
        (CPPD.LEVEL_VALUE = AU.RESPONSIBILITY_ID
         AND CPPD.LEVEL_ID = 10003
 	     AND NOT EXISTS (SELECT 1
		                 FROM CSM_PAGE_PERZ_DELTA CPPD1
	                     WHERE CPPD1.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
	                     AND   CPPD1.LEVEL_ID = 10004
	                     AND   CPPD1.LEVEL_VALUE= AU.USER_ID ))
      OR
       (CPPD.LEVEL_VALUE=0
        AND  CPPD.LEVEL_ID = 10001
 	    AND NOT EXISTS (SELECT 1
		                FROM CSM_PAGE_PERZ_DELTA CPPD1
	                    WHERE CPPD1.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
	                    AND   CPPD1.LEVEL_ID = 10003
	                    AND   CPPD1.LEVEL_VALUE= AU.RESPONSIBILITY_ID )
 	    AND NOT EXISTS (SELECT 1
	                    FROM CSM_PAGE_PERZ_DELTA CPPD1
	                    WHERE CPPD1.PAGE_PERZ_ID = CPPD.PAGE_PERZ_ID
	                    AND   CPPD1.LEVEL_ID = 10004
	                    AND   CPPD1.LEVEL_VALUE= AU.USER_ID ))
      );

CURSOR C_GET_ACCESS_ID IS
 SELECT CSM_PAGE_PERZ_DELTA_ACC_S.NEXTVAL
 FROM DUAL;

TYPE con_rec_type IS RECORD
  (
   ACCESS_ID CSM_PAGE_PERZ_DELTA_ACC.ACCESS_ID%TYPE,
   PAGE_PERZ_ID CSM_PAGE_PERZ_DELTA.PAGE_PERZ_ID%TYPE,
   LEVEL_ID CSM_PAGE_PERZ_DELTA.LEVEL_ID%TYPE,
   LEVEL_VALUE CSM_PAGE_PERZ_DELTA.LEVEL_VALUE%TYPE,
   DELTA_FILE_NAME CSM_PAGE_PERZ_DELTA.DELTA_FILE_NAME%TYPE,
   DELTA_FILE_TYPE CSM_PAGE_PERZ_DELTA.DELTA_FILE_TYPE%TYPE,
   DELTA_SERVER_VERSION CSM_PAGE_PERZ_DELTA.DELTA_SERVER_VERSION%TYPE,
   DELTA_CLIENT_VERSION CSM_PAGE_PERZ_DELTA.DELTA_CLIENT_VERSION%TYPE,
   FILE_DATA CSM_PAGE_PERZ_DELTA.FILE_DATA%TYPE,
   USER_ID ASG_USER.USER_ID%TYPE
  );

TYPE l_tab_type IS TABLE OF con_rec_type
INDEX BY BINARY_INTEGER;

l_tab         l_tab_type;
l_access_id   NUMBER;
l_dummy       BOOLEAN;

BEGIN

  CSM_UTIL_PKG.LOG('Entering api REFRESH_USER with user id- '||p_user_id,
                            'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

  DELETE FROM CSM_PAGE_PERZ_DELTA_ACC WHERE USER_ID=p_user_id;

  --insert--
  OPEN c_insert(p_user_id);
  FETCH c_insert BULK COLLECT INTO l_tab;
  CLOSE c_insert;

  CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_tab.count||' records for user',
                            'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

 FOR I IN 1..l_tab.COUNT
  LOOP
     OPEN  C_GET_ACCESS_ID;
     FETCH C_GET_ACCESS_ID INTO l_access_id;
     CLOSE C_GET_ACCESS_ID;

     INSERT INTO CSM_PAGE_PERZ_DELTA_ACC
     ( ACCESS_ID,
       PAGE_PERZ_ID,
       LEVEL_ID,
       LEVEL_VALUE,
       DELTA_FILE_NAME,
       DELTA_FILE_TYPE,
       DELTA_SERVER_VERSION,
       DELTA_CLIENT_VERSION,
       FILE_DATA,
       USER_ID,
       COUNTER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN
	 )
     VALUES
	 ( l_access_id,
       l_tab(I).PAGE_PERZ_ID,
       l_tab(I).LEVEL_ID,
       l_tab(I).LEVEL_VALUE,
       l_tab(I).DELTA_FILE_NAME,
       l_tab(I).DELTA_FILE_TYPE,
       l_tab(I).DELTA_SERVER_VERSION,
       l_tab(I).DELTA_CLIENT_VERSION,
       l_tab(I).FILE_DATA,
       l_tab(I).USER_ID,
 	   1,
 	   1,
 	   SYSDATE,
 	   1,
 	   SYSDATE,
 	   1
     );

   l_dummy := asg_download.mark_dirty(g_page_perz_delta_pubi_name,l_access_id , l_tab(I).USER_ID, 'I', sysdate );

  END LOOP;

  CSM_UTIL_PKG.LOG('INSERTION Successful ',
                             'CSM_PAGE_PERZ_DELTA_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

END REFRESH_USER;

END CSM_PAGE_PERZ_DELTA_EVENT_PKG;

/
