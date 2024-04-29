--------------------------------------------------------
--  DDL for Package Body CSM_CSP_REQ_LINES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CSP_REQ_LINES_EVENT_PKG" 
/* $Header: csmerlb.pls 120.1.12010000.5 2009/08/06 12:25:36 saradhak ship $*/
AS
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

g_table_name1            CONSTANT VARCHAR2(30) := 'CSP_REQUIREMENT_LINES';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_REQ_LINES_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_REQ_LINES_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_REQ_LINES');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'REQUIREMENT_LINE_ID';

PROCEDURE CSP_REQ_LINES_MDIRTY_I(p_requirement_line_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSP_REQ_LINES_MDIRTY_I for requirement_line_id: ' || p_requirement_line_id,
                                   'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_requirement_line_id
      ,P_USER_ID                => p_user_id
     );

   CSM_UTIL_PKG.LOG('Leaving CSP_REQ_LINES_MDIRTY_I for requirement_line_id: ' || p_requirement_line_id,
                                   'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CSP_REQ_LINES_MDIRTY_I for requirement_line_id:'
                       || to_char(p_requirement_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CSP_REQ_LINES_MDIRTY_I;

PROCEDURE CSP_REQ_LINES_MDIRTY_D(p_requirement_line_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSP_REQ_LINES_MDIRTY_D for requirement_line_id: ' || p_requirement_line_id,
                                   'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_requirement_line_id
      ,P_USER_ID                => p_user_id
     );

   CSM_UTIL_PKG.LOG('Leaving CSP_REQ_LINES_MDIRTY_D for requirement_line_id: ' || p_requirement_line_id,
                                   'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CSP_REQ_LINES_MDIRTY_D for requirement_line_id:'
                       || to_char(p_requirement_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CSP_REQ_LINES_MDIRTY_D;

PROCEDURE CSP_REQ_LINES_MDIRTY_U(p_requirement_line_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_access_id  NUMBER;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSP_REQ_LINES_MDIRTY_U for requirement_line_id: ' || p_requirement_line_id,
                                   'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_U',FND_LOG.LEVEL_PROCEDURE);

   l_access_id := CSM_ACC_PKG.Get_Acc_Id
                            ( P_ACC_TABLE_NAME         => g_acc_table_name1
                             ,P_PK1_NAME               => g_pk1_name1
                             ,P_PK1_NUM_VALUE          => p_requirement_line_id
                             ,P_USER_ID                => p_user_id
                             );

    IF l_access_id <> -1 THEN
       CSM_ACC_PKG.Update_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
           ,P_ACC_TABLE_NAME         => g_acc_table_name1
           ,P_ACCESS_ID              => l_access_id
           ,P_USER_ID                => p_user_id
          );
     END IF;

   CSM_UTIL_PKG.LOG('Leaving CSP_REQ_LINES_MDIRTY_U for requirement_line_id: ' || p_requirement_line_id,
                                   'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_U',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CSP_REQ_LINES_MDIRTY_U for requirement_line_id:'
                       || to_char(p_requirement_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CSP_REQ_LINES_EVENT_PKG.CSP_REQ_LINES_MDIRTY_U',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CSP_REQ_LINES_MDIRTY_U;


PROCEDURE CONC_ORDER_UPDATE(p_status OUT NOCOPY VARCHAR2,
                            p_message OUT NOCOPY VARCHAR2)
IS


  /*** get the last run date of the concurent program ***/
  CURSOR  c_LastRundate
  IS
    SELECT NVL(LAST_RUN_DATE, to_date('1','J')) LAST_RUN_DATE
    FROM   JTM_CON_REQUEST_DATA
    WHERE  package_name =  'CSM_CSP_REQ_LINES_EVENT_PKG'
    AND    procedure_name = 'CONC_ORDER_UPDATE';

    r_LastRundate c_LastRundate%ROWTYPE;

  CURSOR c_order_info (b_last_run_date DATE)
  IS
  SELECT acc.user_id
       , acc.access_id
  FROM   csm_req_lines_acc acc
       , CSP_REQ_LINE_DETAILS crld
       , OE_ORDER_LINES_ALL ol
  WHERE  acc.requirement_line_id = crld.requirement_line_id
  AND    crld.source_id          = ol.line_id
  AND    ol.LAST_UPDATE_DATE    >= b_last_run_date  ;


   l_tab_access_id ASG_DOWNLOAD.ACCESS_LIST;
   l_tab_user_id ASG_DOWNLOAD.USER_LIST;
   g_debug_level        NUMBER;
   l_dummy              BOOLEAN;
   l_current_run_date   DATE;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 1
    , g_table_name1
    , 'Entering CONC_ORDER_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_current_run_date := sysdate;

  /*** First retrieve last run date of the conccurent program ***/
  OPEN  c_LastRundate;
  FETCH c_LastRundate  INTO r_LastRundate;
  CLOSE c_LastRundate;

  l_tab_access_id.DELETE;
  l_tab_user_id.DELETE;


  OPEN c_order_info(r_LastRundate.LAST_RUN_DATE);
  FETCH c_order_info BULK COLLECT INTO l_tab_user_id, l_tab_access_id;
  CLOSE c_order_info;

  IF l_tab_access_id.COUNT > 0 THEN
    /*** 1 or more acc rows retrieved -> push to resource ***/
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( l_tab_access_id(1)
      , g_table_name1
      , 'Updating Order Lines'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
    LOOP
       -- mark dirty the record
       l_dummy := asg_download.mark_dirty(
            p_pub_item         => g_publication_item_name1(1)
          , p_accessid         => l_tab_access_id(i)
          , p_userid           => l_tab_user_id(i)
          , p_dml              => 'U'
          , p_timestamp        => l_current_run_date
          );

      --Notify User of update on Order placed
	   IF(NOT CSM_UTIL_PKG.is_new_mmu_user(CSM_UTIL_PKG.get_user_name(l_tab_user_id(i)))) THEN
          CSM_WF_PKG.RAISE_START_AUTO_SYNC_EVENT('CSM_REQ_LINES',to_char(l_tab_access_id(i)),'UPDATE');
	   END IF;
    END LOOP;
  END IF;--IF l_tab_access_id.COUNT > 0


  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = l_current_run_date
  WHERE package_name =  'CSM_CSP_REQ_LINES_EVENT_PKG'
  AND   procedure_name = 'CONC_ORDER_UPDATE';

  COMMIT;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 1
    , g_table_name1
    , 'Leaving CONC_ORDER_UPDATE hook'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  p_status := 'FINE';
  p_message :=  'CSM_CSP_REQ_LINES_EVENT_PKG.CONC_ORDER_UPDATE Executed successfully';

  RETURN;
EXCEPTION WHEN OTHERS THEN
  p_status := 'ERROR';
  p_message := 'Error in CSM_CSP_REQ_LINES_EVENT_PKG.CONC_ORDER_UPDATE: ' || substr(SQLERRM, 1, 2000);
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( 1
    , g_table_name1
    , 'Caught exception in CONC_ORDER_UPDATE hook:' || fnd_global.local_chr(10) || sqlerrm
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSM_CSP_REQ_LINES_EVENT_PKG','CONC_ORDER_UPDATE',sqlerrm);
END CONC_ORDER_UPDATE;

END CSM_CSP_REQ_LINES_EVENT_PKG;

/
