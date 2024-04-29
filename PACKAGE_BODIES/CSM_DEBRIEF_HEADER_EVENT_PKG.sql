--------------------------------------------------------
--  DDL for Package Body CSM_DEBRIEF_HEADER_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_DEBRIEF_HEADER_EVENT_PKG" AS
/* $Header: csmedbhb.pls 120.1 2005/07/24 23:45:04 trajasek noship $*/

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

g_debrief_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_DEBRIEF_HEADERS_ACC';
g_debrief_table_name            CONSTANT VARCHAR2(30) := 'CSF_DEBRIEF_HEADERS';
g_debrief_seq_name              CONSTANT VARCHAR2(30) := 'CSM_DEBRIEF_HEADERS_ACC_S';
g_debrief_pk1_name              CONSTANT VARCHAR2(30) := 'DEBRIEF_HEADER_ID';
g_debrief_pubi_name             CSM_ACC_PKG.t_publication_item_list;

PROCEDURE DEBRIEF_HEADER_INS_INIT(p_debrief_header_id IN NUMBER, p_h_user_id IN NUMBER,
                                  p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_user_id NUMBER;

CURSOR l_csm_debrfHdInsInit_csr (p_debrief_header_id csf_debrief_headers.debrief_header_id%TYPE)
IS
SELECT dhdr.task_assignment_id, jtrs.user_id, jta.resource_id
FROM   csf_debrief_headers dhdr,
	   jtf_task_assignments jta,
	   jtf_rs_resource_extns jtrs
WHERE dhdr.debrief_header_id = p_debrief_header_id
AND  jta.task_assignment_id = dhdr.task_assignment_id
AND  jtrs.resource_id (+)= jta.resource_id
;

l_csm_debrfHdInsInit_rec l_csm_debrfHdInsInit_csr%ROWTYPE;
l_csm_debrfHdInsInit_null l_csm_debrfHdInsInit_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_HEADER_INS_INIT for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_HEADER_INS_INIT',FND_LOG.LEVEL_PROCEDURE);

   l_csm_debrfHdInsInit_rec := l_csm_debrfHdInsInit_null;

   OPEN l_csm_debrfHdInsInit_csr(p_debrief_header_id);
   FETCH l_csm_debrfHdInsInit_csr INTO l_csm_debrfHdInsInit_rec;
   IF l_csm_debrfHdInsInit_csr%NOTFOUND THEN
      CLOSE l_csm_debrfHdInsInit_csr;
      RETURN;
   END IF;
   CLOSE l_csm_debrfHdInsInit_csr;

   IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
       IF ( NOT (CSM_UTIL_PKG.is_palm_resource(l_csm_debrfHdInsInit_rec.resource_id))) THEN
         CSM_UTIL_PKG.LOG('Not a mobile resource for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
         RETURN;
       END IF;
       l_user_id := l_csm_debrfHdInsInit_rec.user_id;

       -- get debrief header notes
       csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'SD',
                                              p_sourceobjectid=>p_debrief_header_id,
                                              p_userid=>l_user_id,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);
   ELSE
       l_user_id := p_h_user_id;
   END IF;

   -- insert debrief headers into acc table
   DEBRIEF_HEADER_MDIRTY_I(p_debrief_header_id=>p_debrief_header_id,
                           p_user_id=>l_user_id);

   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_HEADER_INS_INIT for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_HEADER_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_HEADER_INS_INIT for debrief_header_id:'
                       || to_char(p_debrief_header_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_HEADER_INS_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_HEADER_INS_INIT;

PROCEDURE DEBRIEF_HEADER_MDIRTY_I(p_debrief_header_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_HEADER_MDIRTY_I for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);

  CSM_ACC_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEBRIEF_HEADERS')
   ,P_ACC_TABLE_NAME         => g_debrief_acc_table_name
   ,P_SEQ_NAME               => g_debrief_seq_name
   ,P_PK1_NAME               => g_debrief_pk1_name
   ,P_PK1_NUM_VALUE          => p_debrief_header_id
   ,P_USER_ID                => p_user_id
  );

   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_HEADER_MDIRTY_I for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_HEADER_MDIRTY_I for debrief_header_id:'
                       || to_char(p_debrief_header_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_HEADER_MDIRTY_I;

PROCEDURE DEBRIEF_HEADER_DEL_INIT(p_debrief_header_id IN NUMBER, p_user_id IN NUMBER,
                                  p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_user_id NUMBER;

CURSOR l_csm_debrfHdDel_csr (p_debrief_header_id csf_debrief_headers.debrief_header_id%TYPE,
                             p_user_id NUMBER)
IS
SELECT dhdr.task_assignment_id, acc.user_id
FROM   csf_debrief_headers dhdr,
       csm_debrief_headers_acc acc
WHERE dhdr.debrief_header_id = p_debrief_header_id
AND  acc.debrief_header_id = dhdr.debrief_header_id
AND  acc.user_id = p_user_id;

l_csm_debrfHdDel_rec l_csm_debrfHdDel_csr%ROWTYPE;
l_csm_debrfHdDel_null l_csm_debrfHdDel_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_HEADER_DEL_INIT for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_HEADER_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);

   l_csm_debrfHdDel_rec := l_csm_debrfHdDel_null;

   OPEN l_csm_debrfHdDel_csr(p_debrief_header_id, p_user_id);
   FETCH l_csm_debrfHdDel_csr INTO l_csm_debrfHdDel_rec;
   IF l_csm_debrfHdDel_csr%NOTFOUND THEN
      CLOSE l_csm_debrfHdDel_csr;
      RETURN;
   END IF;
   CLOSE l_csm_debrfHdDel_csr;

   IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
      -- no need to check if its a mobile resource

      -- delete debrief header notes
       csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'SD',
                                                  p_sourceobjectid=>p_debrief_header_id,
                                                  p_userid=>p_user_id,
                                                  p_error_msg=>l_error_msg,
                                                  x_return_status=>l_return_status);
   END IF;

   -- delete debrief headers from acc table
   DEBRIEF_HEADER_MDIRTY_D(p_debrief_header_id=>p_debrief_header_id,
                           p_user_id=>l_user_id);

   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_HEADER_DEL_INIT for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_HEADER_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_HEADER_DEL_INIT for debrief_header_id:'
                       || to_char(p_debrief_header_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_HEADER_DEL_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_HEADER_DEL_INIT;

PROCEDURE DEBRIEF_HEADER_MDIRTY_D(p_debrief_header_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_user_id NUMBER;

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_HEADER_MDIRTY_D for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Delete_Acc
   ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEBRIEF_HEADERS')
    ,P_ACC_TABLE_NAME         => g_debrief_acc_table_name
    ,P_PK1_NAME               => g_debrief_pk1_name
    ,P_PK1_NUM_VALUE          => p_debrief_header_id
    ,P_USER_ID                => p_user_id
   );

   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_HEADER_MDIRTY_D for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_HEADER_MDIRTY_D for debrief_header_id:'
                       || to_char(p_debrief_header_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_HEADER_MDIRTY_D;

PROCEDURE DEBRIEF_HEADER_MDIRTY_U(p_debrief_header_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_access_id  NUMBER;

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_HEADER_MDIRTY_U for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_U',FND_LOG.LEVEL_PROCEDURE);

   l_access_id := CSM_ACC_PKG.Get_Acc_Id
                            ( P_ACC_TABLE_NAME         => g_debrief_acc_table_name
                             ,P_PK1_NAME               => g_debrief_pk1_name
                             ,P_PK1_NUM_VALUE          => p_debrief_header_id
                             ,P_USER_ID                => p_user_id
                             );

    IF l_access_id <> -1 THEN
      CSM_ACC_PKG.Update_Acc
      ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEBRIEF_HEADERS')
       ,P_ACC_TABLE_NAME         => g_debrief_acc_table_name
       ,P_USER_ID                => p_user_id
       ,p_ACCESS_ID              => l_access_id
      );
    END IF;

   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_HEADER_MDIRTY_U for debrief_header_id: ' || p_debrief_header_id,
                                   'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_U',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_HEADER_MDIRTY_U for debrief_header_id:'
                       || to_char(p_debrief_header_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_HEADER_EVENT_PKG.DEBRIEF_HEADER_MDIRTY_U',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_HEADER_MDIRTY_U;

END CSM_DEBRIEF_HEADER_EVENT_PKG;

/
