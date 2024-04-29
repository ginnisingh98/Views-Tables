--------------------------------------------------------
--  DDL for Package Body CSM_AD_SRCH_REGION_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_AD_SRCH_REGION_EVENT_PKG" AS
/* $Header: csmeasrb.pls 120.5 2008/02/22 08:51:32 trajasek noship $ */
/*** Globals ***/
g_ad_sch_region_acc_tab_name          CONSTANT VARCHAR2(30) := 'CSM_AD_SEARCH_REGION_ACC';
g_ad_sch_region_table_name            CONSTANT VARCHAR2(30) := 'CSM_AD_SEARCH_REGION_VIEW';
g_ad_sch_region_seq_name              CONSTANT VARCHAR2(30) := 'CSM_AD_SEARCH_REGION_ACC_S' ;
g_ad_sch_region_pubi_name             CONSTANT VARCHAR2(30) := 'CSM_AD_SEARCH_REGION';

g_ad_sch_region_pkg_name              CONSTANT VARCHAR2(30) := 'CSM_AD_SRCH_REGION_EVENT_PKG';
g_ad_sch_region_api_name              CONSTANT VARCHAR2(30) := 'REFRESH_ACC';

g_access_list                         asg_download.access_list;

PROCEDURE GET_ACCESS_LIST(p_access_id IN CSM_AD_SEARCH_REGION_ACC.ACCESS_ID%TYPE ,
                          p_count IN NUMBER)
IS
BEGIN
  IF g_access_list.COUNT >0 THEN
    g_access_list.DELETE;
  END IF;
  FOR I IN 1..p_count
  LOOP
     g_access_list(I):=p_access_id;
  END LOOP;

END get_access_list;


PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,p_message OUT NOCOPY VARCHAR2 ) IS
PRAGMA AUTONOMOUS_TRANSACTION;

 /*** get the last run date of the concurent program ***/
CURSOR  c_LastRundate IS
   SELECT NVL(LAST_RUN_DATE, to_date('1','J')) LAST_RUN_DATE
   FROM   JTM_CON_REQUEST_DATA
   WHERE  package_name =  g_ad_sch_region_pkg_name
   AND    procedure_name = g_ad_sch_region_api_name;

CURSOR c_delete IS
  SELECT ACC.ACCESS_ID,
         ACC.ID
  FROM   CSM_AD_SEARCH_REGION_ACC ACC
  WHERE  NOT EXISTS (SELECT 1 FROM  CSM_AD_SEARCH_REGION_VIEW B
                     WHERE  B.ID=ACC.ID
                     AND EXISTS  (SELECT 1 FROM  CSM_AD_SEARCH_TITLE_VIEW C
                     WHERE C.ID= B.SEARCH_TYPE_ID));

CURSOR c_update(b_lastrundate DATE) IS
   SELECT  ACC.ACCESS_ID,
           ACC.ID
   FROM    CSM_AD_SEARCH_REGION_ACC ACC
   WHERE   EXISTS (SELECT 1 FROM CSM_AD_SEARCH_REGION_VIEW B
                   WHERE  B.ID=ACC.ID
                   AND    B.LAST_UPDATE_DATE > b_lastrundate);


CURSOR c_insert IS
   SELECT 1 ACCESS_ID,
          B.ID
   FROM   CSM_AD_SEARCH_REGION_VIEW B
   WHERE  NOT EXISTS (SELECT 1 FROM  CSM_AD_SEARCH_REGION_ACC ACC
                      WHERE  ACC.ID=B.ID
                      OR  NOT EXISTS(SELECT 1 FROM  CSM_AD_SEARCH_TITLE_VIEW C
                      WHERE C.ID= B.SEARCH_TYPE_ID));

CURSOR c_get_access_id IS
 SELECT CSM_AD_SEARCH_REGION_ACC_S.NEXTVAL
 FROM   DUAL;

CURSOR c_get_user_list IS
   SELECT USER_ID
   FROM   ASG_USER
   WHERE  USER_ID =OWNER_ID
   AND    ENABLED='Y';


TYPE l_conc_rec IS RECORD
 (
 ACCESS_ID   CSM_AD_SEARCH_REGION_ACC.ACCESS_ID%TYPE,
 ID          CSM_AD_SEARCH_REGION_VIEW.ID%TYPE
 );

TYPE l_tab_type IS  TABLE OF l_conc_rec
INDEX BY BINARY_INTEGER;

TYPE l_user_list_type IS TABLE OF ASG_USER.USER_ID%TYPE
INDEX BY BINARY_INTEGER;

l_tab          l_tab_type;
l_lastrundate  c_LastRundate%ROWTYPE;
l_dummy        BOOLEAN;
l_access_id    NUMBER;
l_user_list    asg_download.user_list;
l_sqlerrno     VARCHAR2(20);
l_sqlerrmsg    VARCHAR2(4000);

BEGIN

   CSM_UTIL_PKG.LOG('Entering REFRESH_ACC: ',
                              'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

   OPEN c_lastrundate;
   FETCH c_lastrundate INTO l_lastrundate;
   CLOSE c_lastrundate;

   CSM_UTIL_PKG.LOG('Got LASTRUNDATE ',
                              'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

   OPEN  c_get_user_list;
   FETCH c_get_user_list BULK COLLECT INTO l_user_list;
   CLOSE c_get_user_list;

   CSM_UTIL_PKG.LOG('Got USER list : ',
                               'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

   --delete--
   OPEN  c_delete;
   FETCH c_delete BULK COLLECT INTO l_tab;
   CLOSE c_delete;

   CSM_UTIL_PKG.LOG('Entering DELETE to remove ' || l_tab.count||' records',
                              'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

   FOR I IN 1..l_tab.COUNT
   LOOP
      IF l_user_list.COUNT > 0 THEN --Do Mark dirty only if there are valid users
        GET_ACCESS_LIST(l_tab(I).ACCESS_ID,l_user_list.COUNT);
        l_dummy := asg_download.mark_dirty(g_ad_sch_region_pubi_name ,g_access_list,l_user_list, 'D', sysdate );
      END IF;
      DELETE FROM CSM_AD_SEARCH_REGION_ACC WHERE ACCESS_ID=l_tab(I).ACCESS_ID;
   END LOOP;

   COMMIT;

   CSM_UTIL_PKG.LOG('DELETION successful',
                              'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

   IF l_tab.COUNT > 0 THEN
    l_tab.DELETE;
   END IF;

   --update--
   OPEN  c_update(l_lastrundate.Last_run_date);
   FETCH c_update BULK COLLECT INTO l_tab;
   CLOSE c_update;

   CSM_UTIL_PKG.LOG('Entering UPDATE to update ' || l_tab.count||' records',
                              'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

   FOR I IN 1..l_tab.COUNT
   LOOP
      IF l_user_list.COUNT > 0 THEN --Do Mark dirty only if there are valid users
        GET_ACCESS_LIST(l_tab(I).ACCESS_ID,l_user_list.COUNT);
        l_dummy := asg_download.mark_dirty(g_ad_sch_region_pubi_name ,g_access_list,l_user_list, 'U', sysdate );
      END IF;
     UPDATE CSM_AD_SEARCH_REGION_ACC
      SET
          LAST_UPDATE_DATE=SYSDATE,
          LAST_UPDATED_BY=1,
          LAST_UPDATE_LOGIN=1
      WHERE  ACCESS_ID=l_tab(I).ACCESS_ID;
   END LOOP;

   COMMIT;

   CSM_UTIL_PKG.LOG('UPDATE Successful ',
                              'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);
   IF l_tab.COUNT > 0 THEN
    l_tab.DELETE;
   END IF;

   --insert--
   OPEN c_insert;
   FETCH c_insert BULK COLLECT INTO l_tab;
   CLOSE c_insert;

   CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_tab.count||' records',
                             'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

   FOR I IN 1..l_tab.COUNT
   LOOP
      OPEN  C_GET_ACCESS_ID;
      FETCH C_GET_ACCESS_ID INTO l_access_id;
      CLOSE C_GET_ACCESS_ID;

      INSERT INTO CSM_AD_SEARCH_REGION_ACC
      ( ACCESS_ID,
        ID,
        USER_ID,
        COUNTER,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
      )
      VALUES
      ( l_access_id,
        l_tab(I).ID,
        1,
        1,
        SYSDATE,
        1,
        SYSDATE,
        1,
        1
      );

      IF l_user_list.COUNT > 0 THEN --Do Mark dirty only if there are valid users
        GET_ACCESS_LIST(l_access_id,l_user_list.COUNT);
        l_dummy:= ASG_DOWNLOAD.mark_dirty(g_ad_sch_region_pubi_name ,g_access_list,l_user_list,'I',SYSDATE);
      END IF;
   END LOOP;

   COMMIT;

   IF l_tab.COUNT > 0 THEN
    l_tab.DELETE;
   END IF;

   CSM_UTIL_PKG.LOG('INSERTION Successful ',
                              'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

   UPDATE JTM_CON_REQUEST_DATA
   SET LAST_RUN_DATE = SYSDATE
   WHERE  package_name =  g_ad_sch_region_pkg_name
   AND    procedure_name = g_ad_sch_region_api_name;

   COMMIT;

   p_status  := 'FINE';
   p_message := 'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC executed successfully';

   CSM_UTIL_PKG.LOG('Leaving REFRESH_ACC: ',
                               'CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
   WHEN OTHERS THEN
      l_sqlerrno  := TO_CHAR(SQLCODE);
      l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
      p_status := 'ERROR';
      p_message := 'Error in CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg;
      ROLLBACK;
      csm_util_pkg.log('CSM_AD_SEARCH_REGION_EVENT_PKG.REFRESH_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);

END REFRESH_ACC;

END CSM_AD_SRCH_REGION_EVENT_PKG;


/
