--------------------------------------------------------
--  DDL for Package Body CSM_NOTES_TYPE_MAP_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_NOTES_TYPE_MAP_EVENT_PKG" AS
/* $Header: csmenmpb.pls 120.1 2008/02/07 08:18:32 anaraman ship $ */

/*** Globals ***/
g_notes_type_map_acc_tab_name          CONSTANT VARCHAR2(30) := 'CSM_NOTES_TYPE_MAPPING_ACC';
g_notes_type_map_seq_name              CONSTANT VARCHAR2(30) := 'CSM_NOTES_TYPE_MAPPING_ACC_S' ;
g_notes_type_map_pubi_name             CONSTANT VARCHAR2(30) := 'CSM_NOTES_TYPE_MAPPING';

g_notes_type_map_pkg_name              CONSTANT VARCHAR2(30) := 'CSM_NOTES_TYPE_MAP_EVENT_PKG';
g_notes_type_map_api_name              CONSTANT VARCHAR2(30) := 'REFRESH_ACC';



PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
 /*** get the last run date of the concurent program ***/
CURSOR  c_LastRundate IS
  SELECT NVL(LAST_RUN_DATE, to_date('1','J')) LAST_RUN_DATE
  FROM   JTM_CON_REQUEST_DATA
  WHERE  package_name =  g_notes_type_map_pkg_name
  AND    procedure_name = g_notes_type_map_api_name;

 --DELETE--
CURSOR c_delete IS
 SELECT ACC.ACCESS_ID
 FROM  CSM_NOTES_TYPE_MAPPING_ACC ACC
 WHERE NOT EXISTS (SELECT 1
                   FROM JTF_OBJECT_MAPPINGS B
                   WHERE B.MAPPING_ID = ACC.MAPPING_ID
				   AND   NVL(B.END_DATE,SYSDATE)>= SYSDATE);

 --UPDATE--
CURSOR 	c_update(b_lastrundate DATE) IS
 SELECT ACC.ACCESS_ID
 FROM   CSM_NOTES_TYPE_MAPPING_ACC ACC
 WHERE  EXISTS (SELECT 1
                FROM JTF_OBJECT_MAPPINGS B
                WHERE B.MAPPING_ID = ACC.MAPPING_ID
                AND   B.LAST_UPDATE_DATE > b_lastrundate );


 --INSERT--
CURSOR  c_insert IS
 SELECT MAPPING_ID
 FROM   JTF_OBJECT_MAPPINGS B
 WHERE  NVL(B.END_DATE,SYSDATE)>= SYSDATE
 AND    B.OBJECT_CODE = 'JTF_NOTE_TYPE'
 AND    NOT EXISTS (SELECT 1
                    FROM  CSM_NOTES_TYPE_MAPPING_ACC ACC
                    WHERE ACC.MAPPING_ID = B.MAPPING_ID);


CURSOR c_user_id IS
 SELECT USER_ID
 FROM   ASG_USER AU ,
        ASG_USER_PUB_RESPS AUPR
 WHERE  AU.USER_NAME  = AUPR.USER_NAME
 AND    AU.USER_ID    = AU.OWNER_ID
 AND    AUPR.PUB_NAME ='SERVICEP';

TYPE tab_type IS TABLE OF NUMBER;

l_user_List   asg_download.user_list;
l_access_list asg_download.access_list;
l_id_tab      TAB_TYPE;
l_lastrundate c_LastRundate%ROWTYPE;
l_sqlerrno    VARCHAR2(20);
l_sqlerrmsg   VARCHAR2(4000);
l_access_id   NUMBER;
l_dummy       BOOLEAN;

BEGIN

  CSM_UTIL_PKG.LOG('Entering REFRESH_ACC: ',
                             'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  OPEN  c_lastrundate;
  FETCH c_lastrundate INTO l_lastrundate;
  CLOSE c_lastrundate;

  CSM_UTIL_PKG.LOG('Got LASTRUNDATE ',
                             'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  OPEN  c_user_id;
  FETCH c_user_id BULK COLLECT INTO l_user_list;
  CLOSE c_user_id;

  --delete--
  OPEN   c_delete;
  FETCH  c_delete BULK COLLECT INTO l_access_list;
  CLOSE  c_delete;


  CSM_UTIL_PKG.LOG('Entering DELETE to remove ' || l_access_list.count||' records',
                             'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  IF l_access_list.COUNT > 0 THEN
   l_dummy := asg_download.mark_dirty(g_notes_type_map_pubi_name,l_access_list, l_user_list, 'D', sysdate,TRUE );
  END IF;

  FORALL I IN 1..l_access_list.COUNT
  DELETE FROM CSM_NOTES_TYPE_MAPPING_ACC WHERE ACCESS_ID=l_access_list(I);



  CSM_UTIL_PKG.LOG('DELETION successful',
                             'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  l_access_list.DELETE;

  --update--
  OPEN  c_update(l_lastrundate.LAST_RUN_DATE);
  FETCH c_update BULK COLLECT INTO l_access_list;
  CLOSE c_update;

  CSM_UTIL_PKG.LOG('Entering UPDATE to update ' || l_access_list.count||' records',
                             'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  IF l_access_list.COUNT >0 THEN
   l_dummy := asg_download.mark_dirty(g_notes_type_map_pubi_name,l_access_list, l_user_list, 'U', sysdate,TRUE );
  END IF;


  CSM_UTIL_PKG.LOG('UPDATE Successful ',
                             'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  l_access_list.DELETE;


  --insert--
  OPEN c_insert;
  FETCH c_insert BULK COLLECT INTO l_id_tab;
  CLOSE c_insert;

  CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_id_tab.count||' records',
                            'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  FORALL I IN 1..l_id_tab.COUNT
     INSERT INTO CSM_NOTES_TYPE_MAPPING_ACC
     ( ACCESS_ID,
       MAPPING_ID,
       COUNTER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN
	 )
     VALUES
	 ( CSM_NOTES_TYPE_MAPPING_ACC_S.NEXTVAL,
       l_id_tab(I),
 	   1,
 	   1,
 	   SYSDATE,
 	   1,
 	   SYSDATE,
 	   1
     ) RETURNING ACCESS_ID BULK COLLECT INTO l_access_list;


   IF l_access_list.COUNT >0 THEN
    l_dummy := asg_download.mark_dirty(g_notes_type_map_pubi_name,l_access_list, l_user_list, 'I', sysdate,TRUE );
   END IF;


  CSM_UTIL_PKG.LOG('INSERTION Successful ',
                             'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = SYSDATE
  WHERE  package_name =  g_notes_type_map_pkg_name
  AND    procedure_name = g_notes_type_map_api_name;

  COMMIT;

  p_status  := 'FINE';
  p_message := 'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC executed successfully';

  CSM_UTIL_PKG.LOG('Leaving REFRESH_ACC: ',
                              'CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     l_sqlerrno  := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_NOTES_TYPE_MAP_EVENT_PKG.REFRESH_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);

END REFRESH_ACC;

END CSM_NOTES_TYPE_MAP_EVENT_PKG;

/
