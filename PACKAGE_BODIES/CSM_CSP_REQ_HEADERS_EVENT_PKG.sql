--------------------------------------------------------
--  DDL for Package Body CSM_CSP_REQ_HEADERS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CSP_REQ_HEADERS_EVENT_PKG" 
/* $Header: csmerhb.pls 120.1 2005/07/25 00:19:46 trajasek noship $*/
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

g_table_name1            CONSTANT VARCHAR2(30) := 'CSP_REQUIREMENT_HEADERS';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_REQ_HEADERS_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_REQ_HEADERS_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_REQ_HEADERS');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'REQUIREMENT_HEADER_ID';

PROCEDURE CSP_REQ_HEADERS_MDIRTY_I(p_requirement_header_id IN NUMBER,
                                   p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSP_REQ_HEADERS_MDIRTY_I for requirement_header_id: ' || p_requirement_header_id,
                                   'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_requirement_header_id
      ,P_USER_ID                => p_user_id
     );

   CSM_UTIL_PKG.LOG('Leaving CSP_REQ_HEADERS_MDIRTY_I for requirement_header_id: ' || p_requirement_header_id,
                                   'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CSP_REQ_HEADERS_MDIRTY_I for requirement_header_id:'
                       || to_char(p_requirement_header_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CSP_REQ_HEADERS_MDIRTY_I;

PROCEDURE CSP_REQ_HEADERS_MDIRTY_D(p_requirement_header_id IN NUMBER,
                                   p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSP_REQ_HEADERS_MDIRTY_D for requirement_header_id: ' || p_requirement_header_id,
                                   'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_requirement_header_id
      ,P_USER_ID                => p_user_id
     );

   CSM_UTIL_PKG.LOG('Leaving CSP_REQ_HEADERS_MDIRTY_D for requirement_header_id: ' || p_requirement_header_id,
                                   'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CSP_REQ_HEADERS_MDIRTY_D for requirement_header_id:'
                       || to_char(p_requirement_header_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CSP_REQ_HEADERS_MDIRTY_D;

PROCEDURE CSP_REQ_HEADERS_MDIRTY_U(p_requirement_header_id IN NUMBER,
                                   p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_access_id  NUMBER;

BEGIN
   CSM_UTIL_PKG.LOG('Entering CSP_REQ_HEADERS_MDIRTY_U for requirement_header_id: ' || p_requirement_header_id,
                                   'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_U',FND_LOG.LEVEL_PROCEDURE);

   l_access_id := CSM_ACC_PKG.Get_Acc_Id
                            ( P_ACC_TABLE_NAME         => g_acc_table_name1
                             ,P_PK1_NAME               => g_pk1_name1
                             ,P_PK1_NUM_VALUE          => p_requirement_header_id
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

   CSM_UTIL_PKG.LOG('Leaving CSP_REQ_HEADERS_MDIRTY_U for requirement_header_id: ' || p_requirement_header_id,
                                   'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_U',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  CSP_REQ_HEADERS_MDIRTY_U for requirement_header_id:'
                       || to_char(p_requirement_header_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CSP_REQ_HEADERS_EVENT_PKG.CSP_REQ_HEADERS_MDIRTY_U',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END CSP_REQ_HEADERS_MDIRTY_U;

END CSM_CSP_REQ_HEADERS_EVENT_PKG;

/
