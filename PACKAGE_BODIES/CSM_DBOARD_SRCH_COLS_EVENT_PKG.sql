--------------------------------------------------------
--  DDL for Package Body CSM_DBOARD_SRCH_COLS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_DBOARD_SRCH_COLS_EVENT_PKG" AS
/* $Header: csmedscb.pls 120.2 2008/02/07 10:46:16 anaraman ship $ */

/*** Globals ***/
g_dboard_sch_cols_acc_tab_name          CONSTANT VARCHAR2(30) := 'CSM_DASHBOARD_SEARCH_COLS_ACC';
g_dboard_sch_cols_table_name            CONSTANT VARCHAR2(30) := 'CSM_DASHBOARD_SEARCH_COLS';
g_dboard_sch_cols_seq_name              CONSTANT VARCHAR2(30) := 'CSM_DASHBOARD_SRCH_COLS_ACC_S' ;
g_dboard_sch_cols_pubi_name             CONSTANT VARCHAR2(30) := 'CSM_DASHBOARD_SEARCH_COLS';

g_dboard_sch_cols_pkg_name              CONSTANT VARCHAR2(30) := 'CSM_DBOARD_SRCH_COLS_EVENT_PKG';
g_dboard_sch_cols_api_name              CONSTANT VARCHAR2(30) := 'REFRESH_ACC';

g_access_list                           asg_download.access_list;

PROCEDURE GET_ACCESS_LIST(p_access_id IN CSM_DASHBOARD_SEARCH_COLS_ACC.ACCESS_ID%TYPE ,
                          p_count IN NUMBER)
IS
BEGIN
 g_access_list.DELETE;
 FOR I IN 1..p_count
 LOOP
  g_access_list(I):=p_access_id;
 END LOOP;

END get_access_list;


PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,p_message OUT NOCOPY VARCHAR2 ) IS


 /*** get the last run date of the concurent program ***/
CURSOR  c_LastRundate IS
  SELECT NVL(LAST_RUN_DATE, to_date('1','J')) LAST_RUN_DATE
  FROM   JTM_CON_REQUEST_DATA
  WHERE  package_name =  g_dboard_sch_cols_pkg_name
  AND    procedure_name = g_dboard_sch_cols_api_name;

CURSOR c_delete IS
 SELECT ACC.ACCESS_ID,
        ACC.COLUMN_NAME
 FROM   CSM_DASHBOARD_SEARCH_COLS_ACC ACC
 WHERE  NOT EXISTS (SELECT 1 FROM  CSM_DASHBOARD_SEARCH_COLS B
                    WHERE  B.COLUMN_NAME=ACC.COLUMN_NAME);

CURSOR c_update(b_lastrundate DATE) IS
 SELECT  ACC.ACCESS_ID,
         ACC.COLUMN_NAME
 FROM    CSM_DASHBOARD_SEARCH_COLS_ACC ACC
 WHERE   EXISTS (SELECT 1 FROM  CSM_DASHBOARD_SEARCH_COLS B
                 WHERE  B.COLUMN_NAME=ACC.COLUMN_NAME
				 AND    B.LAST_UPDATE_DATE > b_lastrundate);


CURSOR c_insert IS
 SELECT 1 ACCESS_ID,
        B.COLUMN_NAME
 FROM   CSM_DASHBOARD_SEARCH_COLS B
 WHERE  NOT EXISTS (SELECT 1 FROM  CSM_DASHBOARD_SEARCH_COLS_ACC ACC
                    WHERE  ACC.COLUMN_NAME=B.COLUMN_NAME);

CURSOR c_get_access_id IS
 SELECT CSM_DASHBOARD_SRCH_COLS_ACC_S.NEXTVAL
 FROM   DUAL;

CURSOR c_get_user_list IS
 SELECT au.USER_ID
 FROM   ASG_USER au
 WHERE  au.user_id=au.owner_id;


TYPE l_conc_rec IS RECORD
 (
 ACCESS_ID CSM_DASHBOARD_SEARCH_COLS_ACC.ACCESS_ID%TYPE,
 COLUMN_NAME CSM_DASHBOARD_SEARCH_COLS.COLUMN_NAME%TYPE
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
                             'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  OPEN c_lastrundate;
  FETCH c_lastrundate INTO l_lastrundate;
  CLOSE c_lastrundate;

  CSM_UTIL_PKG.LOG('Got LASTRUNDATE ',
                             'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  OPEN  c_get_user_list;
  FETCH c_get_user_list BULK COLLECT INTO l_user_list;
  CLOSE c_get_user_list;

  CSM_UTIL_PKG.LOG('Got USER list : ',
                              'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  --delete--
  OPEN  c_delete;
  FETCH c_delete BULK COLLECT INTO l_tab;
  CLOSE c_delete;

  CSM_UTIL_PKG.LOG('Entering DELETE to remove ' || l_tab.count||' records',
                             'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
     GET_ACCESS_LIST(l_tab(I).ACCESS_ID,l_user_list.COUNT);
     l_dummy := asg_download.mark_dirty(g_dboard_sch_cols_pubi_name,g_access_list,l_user_list, 'D', sysdate );

     DELETE FROM CSM_DASHBOARD_SEARCH_COLS_ACC WHERE ACCESS_ID=l_tab(I).ACCESS_ID;
  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('DELETION successful',
                             'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  l_tab.DELETE;


  --update--
  OPEN  c_update(l_lastrundate.Last_run_date);
  FETCH c_update BULK COLLECT INTO l_tab;
  CLOSE c_update;

  CSM_UTIL_PKG.LOG('Entering UPDATE to update ' || l_tab.count||' records',
                             'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
     GET_ACCESS_LIST(l_tab(I).ACCESS_ID,l_user_list.COUNT);
     l_dummy := asg_download.mark_dirty(g_dboard_sch_cols_pubi_name,g_access_list,l_user_list, 'U', sysdate );

    UPDATE CSM_DASHBOARD_SEARCH_COLS_ACC
     	SET
         LAST_UPDATE_DATE=SYSDATE,
         LAST_UPDATED_BY=1,
         LAST_UPDATE_LOGIN=1
     	WHERE  ACCESS_ID=l_tab(I).ACCESS_ID;
  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('UPDATE Successful ',
                             'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);
  l_tab.DELETE;

  --insert--
  OPEN c_insert;
  FETCH c_insert BULK COLLECT INTO l_tab;
  CLOSE c_insert;

  CSM_UTIL_PKG.LOG('Entering INSERT to add ' || l_tab.count||' records',
                            'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
     OPEN  C_GET_ACCESS_ID;
     FETCH C_GET_ACCESS_ID INTO l_access_id;
     CLOSE C_GET_ACCESS_ID;

     INSERT INTO CSM_DASHBOARD_SEARCH_COLS_ACC
     ( ACCESS_ID,
       COLUMN_NAME,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN
     )
     VALUES
     ( l_access_id,
       l_tab(I).COLUMN_NAME,
       1,
       SYSDATE,
       1,
       SYSDATE,
       1
     );

    GET_ACCESS_LIST(l_access_id,l_user_list.COUNT);

    l_dummy:= ASG_DOWNLOAD.mark_dirty(g_dboard_sch_cols_pubi_name,g_access_list,l_user_list,'I',SYSDATE);

  END LOOP;

  COMMIT;

  CSM_UTIL_PKG.LOG('INSERTION Successful ',
                             'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = SYSDATE
  WHERE  package_name =  g_dboard_sch_cols_pkg_name
  AND    procedure_name = g_dboard_sch_cols_api_name;

  COMMIT;

  p_status  := 'FINE';
  p_message := 'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC executed successfully';

  CSM_UTIL_PKG.LOG('Leaving REFRESH_ACC: ',
                              'CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     l_sqlerrno  := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_DBOARD_SRCH_COLS_EVENT_PKG.REFRESH_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);

END REFRESH_ACC;



END CSM_DBOARD_SRCH_COLS_EVENT_PKG;

/
