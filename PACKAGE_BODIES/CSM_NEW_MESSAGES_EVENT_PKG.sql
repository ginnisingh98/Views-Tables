--------------------------------------------------------
--  DDL for Package Body CSM_NEW_MESSAGES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_NEW_MESSAGES_EVENT_PKG" AS
/* $Header: csmenmgb.pls 120.13.12010000.2 2008/10/22 12:43:56 trajasek ship $ */
/*** Globals ***/
g_new_msg_acc_tab_name          CONSTANT VARCHAR2(30) := 'CSM_NEW_MESSAGES_ACC';
g_new_msg_tl_tab_name           CONSTANT VARCHAR2(30) := 'CSM_NEW_MESSAGES_TL';
g_new_msg_perz_tab_name         CONSTANT VARCHAR2(30) := 'CSM_NEW_MESSAGES_PERZ';
g_new_msg_table_name            CONSTANT VARCHAR2(30) := 'CSM_NEW_MESSAGES';
g_new_msg_pubi_name             CONSTANT VARCHAR2(30) := 'CSM_NEW_MESSAGES';

g_new_msg_pkg_name CONSTANT VARCHAR2(30) := 'CSM_NEW_MESSAGES_EVENT_PKG';
g_new_msg_api_name CONSTANT VARCHAR2(30) := 'REFRESH_ACC';

--Bug 5409433
PROCEDURE HANDLE_DELETE(p_status OUT NOCOPY VARCHAR2 ,p_message OUT NOCOPY VARCHAR2)
IS

CURSOR c_delete IS
--EARLIER PERZed ,NOW NO_PERZ  : part 1 of 3
  SELECT CNMA.MESSAGE_ID,
	     CNMA.USER_ID
  FROM   CSM_NEW_MESSAGES_ACC CNMA
  WHERE  CNMA.LEVEL_ID=10001
          AND   CNMA.LEVEL_VALUE=0
		  AND  NOT EXISTS (SELECT 1
		              FROM CSM_NEW_MESSAGES_PERZ CNMP
                      WHERE CNMP.MESSAGE_ID = CNMA.MESSAGE_ID
                      AND   CNMP.LANGUAGE=CNMA.LANGUAGE
                      AND   CNMP.LEVEL_ID=10001  )
UNION ALL
--EARLIER PERZed ,NOW NO_PERZ : part 2 of 3
  SELECT CNMA.MESSAGE_ID,
	     CNMA.USER_ID
  FROM   CSM_NEW_MESSAGES_ACC CNMA
  WHERE  CNMA.LEVEL_ID=10003
 		 AND NOT EXISTS (SELECT 1
		             FROM CSM_NEW_MESSAGES_PERZ CNMP,ASG_USER AU
                     WHERE CNMP.MESSAGE_ID = CNMA.MESSAGE_ID
                     AND   CNMP.LANGUAGE=CNMA.LANGUAGE
					 AND   CNMP.LEVEL_ID=10003
   		             AND   CNMA.USER_ID=AU.USER_ID
					 AND   AU.RESPONSIBILITY_ID=CNMP.LEVEL_VALUE)
  UNION ALL
--EARLIER PERZed ,NOW NO_PERZ : part 3 of 3
  SELECT CNMA.MESSAGE_ID,
	     CNMA.USER_ID
  FROM   CSM_NEW_MESSAGES_ACC CNMA
  WHERE CNMA.LEVEL_ID=10004
 		 AND
         NOT EXISTS (SELECT 1
		             FROM CSM_NEW_MESSAGES_PERZ CNMP
                     WHERE CNMP.MESSAGE_ID = CNMA.MESSAGE_ID
                     AND   CNMP.LANGUAGE=CNMA.LANGUAGE
					 AND   CNMP.LEVEL_ID=10004
					 AND   CNMA.USER_ID=CNMP.LEVEL_VALUE)
  UNION ALL
--EARLIER NO_PERZ,NOW PERZed
  SELECT CNMA.MESSAGE_ID,
	     CNMA.USER_ID
  FROM   CSM_NEW_MESSAGES_ACC CNMA
  WHERE CNMA.LEVEL_ID=0
  AND   EXISTS (SELECT 1
                 FROM CSM_NEW_MESSAGES_PERZ CNMP,ASG_USER AU
                 WHERE CNMP.MESSAGE_ID = CNMA.MESSAGE_ID
                 AND CNMA.USER_ID = AU.USER_ID
				 AND   (
                         (CNMP.LEVEL_ID=10001
                          AND CNMP.LEVEL_VALUE=0)
					   OR
					     (CNMP.LEVEL_ID=10003
  					      AND CNMP.LEVEL_VALUE=AU.RESPONSIBILITY_ID
					      /*AND CNMA.USER_ID=AU.USER_ID*/)
					   OR
                         (CNMP.LEVEL_ID=10004
					      /*AND CNMP.LEVEL_VALUE=CNMA.USER_ID*/
                          AND  CNMP.LEVEL_VALUE=AU.USER_ID))
			    )
  UNION ALL
--EARLIER PERZed ,BUT Now Inserted FINER LEVEL_ID  : part 1 of 2
  SELECT CNMA.MESSAGE_ID,
	     CNMA.USER_ID
  FROM  CSM_NEW_MESSAGES_ACC CNMA
  WHERE CNMA.LEVEL_ID = 10001
  AND CNMA.LEVEL_VALUE = 0
  AND  EXISTS (SELECT 1
               FROM  CSM_NEW_MESSAGES_PERZ CNMP,
                     ASG_USER AU
               WHERE CNMP.MESSAGE_ID=CNMA.MESSAGE_ID
               AND   CNMP.LANGUAGE = CNMA.LANGUAGE
               AND   CNMA.USER_ID = AU.USER_ID
               AND  (
                     (CNMP.LEVEL_ID=10003
                      AND CNMP.LEVEL_VALUE = AU.RESPONSIBILITY_ID) --Site to Resp
                  OR (CNMP.LEVEL_ID=10004
 			          AND CNMP.LEVEL_VALUE = AU.USER_ID) -- Site to User
                     ))
UNION ALL
--EARLIER PERZed ,BUT Now Inserted FINER LEVEL_ID  : part2 of 2
  SELECT CNMA.MESSAGE_ID,
	     CNMA.USER_ID
  FROM  CSM_NEW_MESSAGES_ACC CNMA
  WHERE CNMA.LEVEL_ID = 10003
  AND  EXISTS (SELECT 1
               FROM  CSM_NEW_MESSAGES_PERZ CNMP,
                     ASG_USER AU
               WHERE CNMP.MESSAGE_ID=CNMA.MESSAGE_ID
               AND   CNMP.LANGUAGE = CNMA.LANGUAGE
               AND   CNMA.USER_ID = AU.USER_ID
                      AND CNMA.LEVEL_VALUE = AU.RESPONSIBILITY_ID
           	          AND CNMP.LEVEL_ID=10004
                      AND CNMP.LEVEL_VALUE = AU.USER_ID) ; --Resp to User


CURSOR c_delete_fragment IS
    --EARLIER PERZed/NO_PERZed BUT NOW REMOVED FROM BASE_TABLE
   SELECT /*+index (cnma csm_new_messages_acc_u2) */
         CNMA.MESSAGE_ID,
         CNMA.USER_ID
   FROM   CSM_NEW_MESSAGES_ACC CNMA
   WHERE  CNMA.message_id is not null
   AND    NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES CNM
                     WHERE CNM.MESSAGE_ID=CNMA.MESSAGE_ID) ;


CURSOR c_get_access(b_msg_id NUMBER, b_user_id NUMBER) IS
  SELECT /*+index (cnma csm_new_messages_acc_u2) */
         CNMA.ACCESS_ID
  FROM   CSM_NEW_MESSAGES_ACC CNMA
  WHERE  CNMA.MESSAGE_ID = b_msg_id
  AND    CNMA.USER_ID    = b_user_id;

TYPE con_rec_type IS RECORD
  (
   MESSAGE_ID CSM_NEW_MESSAGES.MESSAGE_ID%TYPE,
   USER_ID ASG_USER.USER_ID%TYPE
  );

TYPE l_tab_type IS TABLE OF con_rec_type
INDEX BY BINARY_INTEGER;

l_tab              l_tab_type;
l_access_id        NUMBER;
l_dummy            BOOLEAN;

l_sqlerrno         VARCHAR2(20);
l_sqlerrmsg        VARCHAR2(4000);
BEGIN

OPEN c_delete;
FETCH c_delete BULK COLLECT INTO l_tab;
CLOSE c_delete;


  CSM_UTIL_PKG.LOG('Entering DELETE to remove ' || l_tab.count||' records',
                             'CSM_NEW_MESSAGES_EVENT_PKG.HANDLE_DELETE',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
    OPEN c_get_access(l_tab(I).MESSAGE_ID,l_tab(I).USER_ID);
    FETCH c_get_access INTO l_access_id;
    CLOSE c_get_access;

    l_dummy := asg_download.mark_dirty(g_new_msg_pubi_name,l_ACCESS_ID ,  l_tab(I).USER_ID, 'D', sysdate );

    DELETE FROM CSM_NEW_MESSAGES_ACC WHERE ACCESS_ID=l_ACCESS_ID;
  END LOOP;

  COMMIT;

l_tab.DELETE;

 OPEN c_delete_fragment;
 FETCH c_delete_fragment BULK COLLECT INTO l_tab;
 CLOSE c_delete_fragment;


  CSM_UTIL_PKG.LOG('Entering DELETE FRAGMENT to remove ' || l_tab.count||' records',
                             'CSM_NEW_MESSAGES_EVENT_PKG.HANDLE_DELETE',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
    OPEN c_get_access(l_tab(I).MESSAGE_ID,l_tab(I).USER_ID);
    FETCH c_get_access INTO l_access_id;
    CLOSE c_get_access;

    l_dummy := asg_download.mark_dirty(g_new_msg_pubi_name,l_ACCESS_ID ,  l_tab(I).USER_ID, 'D', sysdate );

    DELETE FROM CSM_NEW_MESSAGES_ACC WHERE ACCESS_ID=l_ACCESS_ID;
  END LOOP;

  CSM_UTIL_PKG.LOG('DELETION successful',
                             'CSM_NEW_MESSAGES_EVENT_PKG.HANDLE_DELETE',FND_LOG.LEVEL_PROCEDURE);
p_status :='SUCCESS';
p_message :='DELETION in CSM_NEW_MESSAGES_EVENT_PKG.HANDLE_DELETE successful';

EXCEPTION
 WHEN OTHERS THEN
     l_sqlerrno  := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_NEW_MESSAGES_EVENT_PKG.HANDLE_DELETE: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     RAISE;
     csm_util_pkg.log('CSM_NEW_MESSAGES_EVENT_PKG.HANDLE_DELETE ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END HANDLE_DELETE;

PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2) IS

PRAGMA AUTONOMOUS_TRANSACTION;
 /*** get the last run date of the concurent program ***/
CURSOR  c_LastRundate IS
  SELECT NVL(LAST_RUN_DATE, to_date('1','J')) LAST_RUN_DATE
  FROM   JTM_CON_REQUEST_DATA
  WHERE  package_name =  g_new_msg_pkg_name
  AND    procedure_name = g_new_msg_api_name;

 --UPDATE--
CURSOR  c_update(b_lastrundate DATE)  IS
  SELECT CNMA.MESSAGE_ID,
         CNMA.LEVEL_ID,
         CNMA.LEVEL_VALUE,
         CNMA.LANGUAGE,
         CNMP.MESSAGE_TEXT,
         CNMP.DESCRIPTION,
	     CNMA.USER_ID,
	     CNMA.ACCESS_ID
  FROM   CSM_NEW_MESSAGES_ACC CNMA,
         CSM_NEW_MESSAGES_PERZ CNMP
  WHERE  CNMA.MESSAGE_ID=CNMP.MESSAGE_ID
  AND    (CNMP.LEVEL_ID   = CNMA.LEVEL_ID
           AND CNMP.LEVEL_VALUE= CNMA.LEVEL_VALUE
           AND CNMP.LANGUAGE   = CNMA.LANGUAGE
           AND CNMP.LAST_UPDATE_DATE>b_lastrundate )
UNION ALL
  SELECT CNMA.MESSAGE_ID,
         CNMA.LEVEL_ID,
         CNMA.LEVEL_VALUE,
         CNMA.LANGUAGE,
         CNMT.MESSAGE_TEXT,
         CNMT.DESCRIPTION,
	     CNMA.USER_ID,
	     CNMA.ACCESS_ID
  FROM   CSM_NEW_MESSAGES_ACC CNMA,
         CSM_NEW_MESSAGES_TL CNMT
  WHERE  CNMT.MESSAGE_ID = CNMA.MESSAGE_ID
  AND    CNMT.LANGUAGE   = CNMA.LANGUAGE
  AND    CNMT.LAST_UPDATE_DATE>b_lastrundate
  AND    CNMA.LEVEL_ID=0    --PREVIOUSLY  AND NOW ALSO NOT PERSONALIZED
  AND    NOT EXISTS (SELECT 1 FROM  CSM_NEW_MESSAGES_PERZ CNMP,ASG_USER AU
                             WHERE  CNMA.MESSAGE_ID=CNMP.MESSAGE_ID
                             AND    AU.USER_ID=AU.OWNER_ID
							 AND   ( CNMP.LEVEL_ID=10001
							       OR ---IF SITE-LEVEL PERZ IS THERE THEN DON'T UPDATE ANY REC WITH TL-TABLE
							       (CNMP.LEVEL_ID=10003
							        AND CNMA.USER_ID=AU.USER_ID
								    AND AU.RESPONSIBILITY_ID=CNMP.LEVEL_VALUE)
								   OR ---IF RESP-LEVEL PERZ IS THERE THEN DON'T UPDATE THAT USER RECS WITH TL-TABLE
								    (CNMP.LEVEL_ID=10004
							         AND CNMA.USER_ID=CNMP.LEVEL_VALUE) )) ;



 --INSERT--
CURSOR  c_insert IS
--PERZ EXISTS
  SELECT CNM.MESSAGE_ID,
         CNMP.LEVEL_ID,
         CNMP.LEVEL_VALUE,
         CNMP.LANGUAGE,
         CNMP.MESSAGE_TEXT,
         CNMP.DESCRIPTION,
	     AU.USER_ID,
	     1 ACCESS_ID
  FROM  CSM_NEW_MESSAGES CNM,
        CSM_NEW_MESSAGES_PERZ CNMP,
        ASG_USER AU
  WHERE CNM.MESSAGE_ID=CNMP.MESSAGE_ID
  AND   CNMP.LANGUAGE =AU.LANGUAGE
  AND    AU.USER_ID=AU.OWNER_ID
  AND ( (CNMP.LEVEL_VALUE = AU.USER_ID
       AND CNMP.LEVEL_ID = 10004)
      OR
	   (CNMP.LEVEL_VALUE = AU.RESPONSIBILITY_ID
       AND CNMP.LEVEL_ID = 10003
 	   AND NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES_PERZ CNMP1
		                  WHERE AU.USER_ID = CNMP1.LEVEL_VALUE AND CNMP1.LEVEL_ID = 10004))
      OR
       (CNMP.LEVEL_VALUE=0
        AND  CNMP.LEVEL_ID = 10001
        AND  NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES_PERZ CNMP1
	                      WHERE CNMP.MESSAGE_ID=CNMP1.MESSAGE_ID
						  AND   CNMP.LANGUAGE=CNMP1.LANGUAGE
						  AND   AU.RESPONSIBILITY_ID = CNMP1.LEVEL_VALUE
						  AND   CNMP1.LEVEL_ID = 10003)
	    AND  NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES_PERZ CNMP1
	                      WHERE CNMP.MESSAGE_ID=CNMP1.MESSAGE_ID
						  AND   CNMP.LANGUAGE=CNMP1.LANGUAGE
						  AND   AU.USER_ID = CNMP1.LEVEL_VALUE
						  AND   CNMP1.LEVEL_ID = 10004)
	   )
      )
  AND NOT EXISTS (SELECT 1
                  FROM  CSM_NEW_MESSAGES_ACC ACC
                  WHERE ACC.MESSAGE_ID = CNMP.MESSAGE_ID
                  AND   ACC.USER_ID = AU.USER_ID)
UNION ALL
--PERZ DOESN'T EXIST
SELECT 	CNM.MESSAGE_ID,
        0 LEVEL_ID,
        0 LEVEL_VALUE,
        CNMT.LANGUAGE,
        CNMT.MESSAGE_TEXT,
        CNMT.DESCRIPTION,
	    AU.USER_ID,
	    1 ACCESS_ID
FROM   CSM_NEW_MESSAGES CNM,
       CSM_NEW_MESSAGES_TL CNMT,
	   ASG_USER AU
WHERE  CNM.MESSAGE_ID = CNMT.MESSAGE_ID
AND    AU.USER_ID=AU.OWNER_ID
AND    CNMT.LANGUAGE  = AU.LANGUAGE
AND    NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES_PERZ CNMP
                   WHERE CNMP.MESSAGE_ID=CNM.MESSAGE_ID
				   AND(
				       CNMP.LEVEL_ID=10001
                      OR
	  			       (CNMP.LEVEL_ID=10003
  						AND   CNMP.LEVEL_VALUE=AU.RESPONSIBILITY_ID)
 					  OR
					   (CNMP.LEVEL_ID=10004
					    AND   CNMP.LEVEL_VALUE=AU.USER_ID)))
AND   NOT EXISTS (SELECT 1
                  FROM  CSM_NEW_MESSAGES_ACC ACC
                  WHERE ACC.MESSAGE_ID = CNMT.MESSAGE_ID
                  AND   ACC.USER_ID = AU.USER_ID);

CURSOR C_GET_ACCESS_ID IS
 SELECT CSM_NEW_MESSAGES_ACC_S.NEXTVAL
 FROM DUAL;

TYPE con_rec_type IS RECORD
  (
   MESSAGE_ID CSM_NEW_MESSAGES.MESSAGE_ID%TYPE,
   LEVEL_ID CSM_NEW_MESSAGES_PERZ.LEVEL_ID%TYPE,
   LEVEL_VALUE CSM_NEW_MESSAGES_PERZ.LEVEL_VALUE%TYPE,
   LANGUAGE  CSM_NEW_MESSAGES_TL.LANGUAGE%TYPE,
   MESSAGE_TEXT CSM_NEW_MESSAGES_TL.MESSAGE_TEXT%TYPE,
   DESCRIPTION CSM_NEW_MESSAGES_TL.DESCRIPTION%TYPE,
   USER_ID ASG_USER.USER_ID%TYPE,
   ACCESS_ID CSM_NEW_MESSAGES_ACC.ACCESS_ID%TYPE
  );

TYPE l_tab_type IS TABLE OF con_rec_type
INDEX BY BINARY_INTEGER;

l_tab              l_tab_type;
l_lastrundate      c_LastRundate%ROWTYPE;
l_sqlerrno         VARCHAR2(20);
l_sqlerrmsg        VARCHAR2(4000);
l_dummy            BOOLEAN;
l_access_id        NUMBER;
l_max_update_date  DATE;
l_checkupdates     VARCHAR2(1) := 'N';
BEGIN

  CSM_UTIL_PKG.LOG('Entering REFRESH_ACC: ',
                             'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  OPEN c_lastrundate;
  FETCH c_lastrundate INTO l_lastrundate;
  CLOSE c_lastrundate;

  CSM_UTIL_PKG.LOG('Got LASTRUNDATE ',
                             'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

--Bug 5409433
  --DELETE--
   HANDLE_DELETE(p_status,p_message);
   COMMIT;

  --update--
  -- Don't bother to run the update cursor unless the max(last_update_date) is > last_run_date
  -- Will reduce buffer gets. See bug 5184173
  -- An index will be created on last_update_date column to avoid FTS.
  SELECT NVL(MAX(last_update_date), to_date('1', 'J')) INTO l_max_update_date
  FROM CSM_NEW_MESSAGES_PERZ;
  -- Find the next max_last_update_date only if the above query shows a lower last_update_date
  IF(l_max_update_date  <= l_lastrundate.last_run_date) THEN
    SELECT NVL(MAX(last_update_date), to_date('1', 'J')) INTO l_max_update_date
    FROM CSM_NEW_MESSAGES_TL;
    IF(l_max_update_date > l_lastrundate.last_run_date) THEN
       l_checkupdates := 'Y';
    END IF;
  ELSE
    l_checkupdates := 'Y';
  END IF;

  IF(l_checkupdates = 'Y') THEN
     OPEN c_update(l_lastrundate.LAST_RUN_DATE);
     FETCH c_update BULK COLLECT INTO l_tab;
     CLOSE c_update;

     CSM_UTIL_PKG.LOG('Entering UPDATE to update ' || l_tab.count||' records',
                      'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

     FOR I IN 1..l_tab.COUNT LOOP
       l_dummy := asg_download.mark_dirty(g_new_msg_pubi_name,l_tab(I).ACCESS_ID ,
                                          l_tab(I).USER_ID, 'U', sysdate );

       UPDATE CSM_NEW_MESSAGES_ACC
	   SET
         MESSAGE_TEXT=L_TAB(I).MESSAGE_TEXT,
         DESCRIPTION=L_TAB(I).DESCRIPTION,
         LAST_UPDATE_DATE=SYSDATE,
         LAST_UPDATED_BY=1,
         LAST_UPDATE_LOGIN=1
   	   WHERE  ACCESS_ID=l_tab(I).ACCESS_ID;
     END LOOP;

     COMMIT;

     CSM_UTIL_PKG.LOG('UPDATE Successful ',
                      'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);
     l_tab.DELETE;
   END IF;

  --insert--
  OPEN c_insert;
  FETCH c_insert BULK COLLECT INTO l_tab;
  CLOSE c_insert;

  CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_tab.count||' records',
                            'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
     OPEN  C_GET_ACCESS_ID;
     FETCH C_GET_ACCESS_ID INTO l_access_id;
     CLOSE C_GET_ACCESS_ID;

     INSERT INTO CSM_NEW_MESSAGES_ACC
     ( ACCESS_ID,
       MESSAGE_ID,
       LEVEL_ID,
       LEVEL_VALUE,
       LANGUAGE,
       USER_ID,
       MESSAGE_TEXT,
       DESCRIPTION,
       COUNTER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN
	 )
     VALUES
	 ( l_access_id,
 	   l_tab(I).MESSAGE_ID,
 	   l_tab(I).LEVEL_ID,
 	   l_tab(I).LEVEL_VALUE,
 	   l_tab(I).LANGUAGE,
 	   l_tab(I).USER_ID,
 	   l_tab(I).MESSAGE_TEXT,
 	   l_tab(I).DESCRIPTION,
 	   1,
 	   1,
 	   SYSDATE,
 	   1,
 	   SYSDATE,
 	   1
     );

   l_dummy := asg_download.mark_dirty(g_new_msg_pubi_name,l_access_id ,  l_tab(I).USER_ID, 'I', sysdate );

  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('INSERTION Successful ',
                             'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = SYSDATE
  WHERE  package_name =  g_new_msg_pkg_name
  AND    procedure_name = g_new_msg_api_name;

  COMMIT;

  p_status  := 'FINE';
  p_message := 'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC executed successfully';

  CSM_UTIL_PKG.LOG('Leaving REFRESH_ACC: ',
                              'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     l_sqlerrno  := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := p_message||': Error in CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);

END REFRESH_ACC;

--Bug 7239431
PROCEDURE REFRESH_USER(p_user_id NUMBER)
IS

 --INSERT--
CURSOR  c_insert(b_user_id NUMBER) IS
--PERZ EXISTS
  SELECT CNM.MESSAGE_ID,
         CNMP.LEVEL_ID,
         CNMP.LEVEL_VALUE,
         CNMP.LANGUAGE,
         CNMP.MESSAGE_TEXT,
         CNMP.DESCRIPTION,
	     AU.USER_ID,
	     1 ACCESS_ID
  FROM  CSM_NEW_MESSAGES CNM,
        CSM_NEW_MESSAGES_PERZ CNMP,
        ASG_USER AU
  WHERE AU.USER_ID= b_user_id
  AND    AU.USER_ID=AU.OWNER_ID
  AND CNM.MESSAGE_ID=CNMP.MESSAGE_ID
  AND   CNMP.LANGUAGE =AU.LANGUAGE
  AND ( (CNMP.LEVEL_VALUE = AU.USER_ID
       AND CNMP.LEVEL_ID = 10004)
      OR
	   (CNMP.LEVEL_VALUE = AU.RESPONSIBILITY_ID
       AND CNMP.LEVEL_ID = 10003
 	   AND NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES_PERZ CNMP1
		                  WHERE AU.USER_ID = CNMP1.LEVEL_VALUE AND CNMP1.LEVEL_ID = 10004))
      OR
       (CNMP.LEVEL_VALUE=0
        AND  CNMP.LEVEL_ID = 10001
        AND  NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES_PERZ CNMP1
	                      WHERE CNMP.MESSAGE_ID=CNMP1.MESSAGE_ID
						  AND   CNMP.LANGUAGE=CNMP1.LANGUAGE
						  AND   AU.RESPONSIBILITY_ID = CNMP1.LEVEL_VALUE
						  AND   CNMP1.LEVEL_ID = 10003)
	    AND  NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES_PERZ CNMP1
	                      WHERE CNMP.MESSAGE_ID=CNMP1.MESSAGE_ID
						  AND   CNMP.LANGUAGE=CNMP1.LANGUAGE
						  AND   AU.USER_ID = CNMP1.LEVEL_VALUE
						  AND   CNMP1.LEVEL_ID = 10004)
	   )
      )
UNION ALL
--PERZ DOESN'T EXIST
SELECT 	CNM.MESSAGE_ID,
        0 LEVEL_ID,
        0 LEVEL_VALUE,
        CNMT.LANGUAGE,
        CNMT.MESSAGE_TEXT,
        CNMT.DESCRIPTION,
	    AU.USER_ID,
	    1 ACCESS_ID
FROM   CSM_NEW_MESSAGES CNM,
       CSM_NEW_MESSAGES_TL CNMT,
	   ASG_USER AU
WHERE AU.USER_ID= b_user_id
AND    AU.USER_ID=AU.OWNER_ID
AND   CNM.MESSAGE_ID = CNMT.MESSAGE_ID
AND   CNMT.LANGUAGE  = AU.LANGUAGE
AND    NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES_PERZ CNMP
                   WHERE CNMP.MESSAGE_ID=CNM.MESSAGE_ID
				   AND(
				       CNMP.LEVEL_ID=10001
                      OR
	  			       (CNMP.LEVEL_ID=10003
  						AND   CNMP.LEVEL_VALUE=AU.RESPONSIBILITY_ID)
 					  OR
					   (CNMP.LEVEL_ID=10004
					    AND   CNMP.LEVEL_VALUE=AU.USER_ID)));

CURSOR C_GET_ACCESS_ID IS
 SELECT CSM_NEW_MESSAGES_ACC_S.NEXTVAL
 FROM DUAL;

TYPE con_rec_type IS RECORD
  (
   MESSAGE_ID CSM_NEW_MESSAGES.MESSAGE_ID%TYPE,
   LEVEL_ID CSM_NEW_MESSAGES_PERZ.LEVEL_ID%TYPE,
   LEVEL_VALUE CSM_NEW_MESSAGES_PERZ.LEVEL_VALUE%TYPE,
   LANGUAGE  CSM_NEW_MESSAGES_TL.LANGUAGE%TYPE,
   MESSAGE_TEXT CSM_NEW_MESSAGES_TL.MESSAGE_TEXT%TYPE,
   DESCRIPTION CSM_NEW_MESSAGES_TL.DESCRIPTION%TYPE,
   USER_ID ASG_USER.USER_ID%TYPE,
   ACCESS_ID CSM_NEW_MESSAGES_ACC.ACCESS_ID%TYPE
  );

TYPE l_tab_type IS TABLE OF con_rec_type
INDEX BY BINARY_INTEGER;

l_tab              l_tab_type;
l_dummy            BOOLEAN;
l_access_id        NUMBER;

BEGIN

  CSM_UTIL_PKG.LOG('Entering api REFRESH_USER with user id- '||p_user_id,
                            'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

  DELETE FROM CSM_NEW_MESSAGES_ACC WHERE USER_ID=p_user_id;

  --insert--
  OPEN c_insert(p_user_id);
  FETCH c_insert BULK COLLECT INTO l_tab;
  CLOSE c_insert;

  CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_tab.count||' records for user',
                            'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
     OPEN  C_GET_ACCESS_ID;
     FETCH C_GET_ACCESS_ID INTO l_access_id;
     CLOSE C_GET_ACCESS_ID;

     INSERT INTO CSM_NEW_MESSAGES_ACC
     ( ACCESS_ID,
       MESSAGE_ID,
       LEVEL_ID,
       LEVEL_VALUE,
       LANGUAGE,
       USER_ID,
       MESSAGE_TEXT,
       DESCRIPTION,
       COUNTER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN
	 )
     VALUES
	 ( l_access_id,
 	   l_tab(I).MESSAGE_ID,
 	   l_tab(I).LEVEL_ID,
 	   l_tab(I).LEVEL_VALUE,
 	   l_tab(I).LANGUAGE,
 	   l_tab(I).USER_ID,
 	   l_tab(I).MESSAGE_TEXT,
 	   l_tab(I).DESCRIPTION,
 	   1,
 	   1,
 	   SYSDATE,
 	   1,
 	   SYSDATE,
 	   1
     );

   l_dummy := asg_download.mark_dirty(g_new_msg_pubi_name,l_access_id ,  l_tab(I).USER_ID, 'I', sysdate );

  END LOOP;

  CSM_UTIL_PKG.LOG('INSERTION Successful ',
                             'CSM_NEW_MESSAGES_EVENT_PKG.REFRESH_USER',FND_LOG.LEVEL_PROCEDURE);

END REFRESH_USER;

END CSM_NEW_MESSAGES_EVENT_PKG;

/
