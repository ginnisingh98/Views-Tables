--------------------------------------------------------
--  DDL for Package Body CSM_HZ_LOCATIONS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_HZ_LOCATIONS_EVENT_PKG" AS
/* $Header: csmehzlb.pls 120.1 2005/12/08 16:02 trajasek noship $ */

/*** Globals ***/
g_debug_level 					 NUMBER;
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_HZ_LOCATIONS_ACC';
g_seq_name          	CONSTANT VARCHAR2(30) := 'CSM_HZ_LOCATIONS_ACC_S';
g_table_name            CONSTANT VARCHAR2(30) := 'HZ_LOCATIONS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'LOCATION_ID';
g_publication_item_name CONSTANT CSM_ACC_PKG.t_publication_item_list :=
 CSM_ACC_PKG.t_publication_item_list('CSM_HZ_LOCATIONS');



PROCEDURE INSERT_LOCATION( p_location_id IN NUMBER, p_user_id IN NUMBER)
IS
--variable declarations
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);

BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Entering Insert_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Inserting ACC record for user_id = '||p_user_id || 'for location id' ||p_location_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name,
      P_ACC_TABLE_NAME         => g_acc_table_name,
      P_SEQ_NAME               => g_seq_name,
      P_USER_ID                => p_user_id,
      P_PK1_NAME               => g_pk1_name,
      P_PK1_NUM_VALUE          => p_location_id);

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Leaving Insert_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     RAISE;
     CSM_UTIL_PKG.LOG('Exception in CSM_HZ_LOCATIONS_EVENT_PKG.INSERT_LOCATION: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_HZ_LOCATIONS_EVENT_PKG.INSERT_LOCATION',FND_LOG.LEVEL_EXCEPTION);

END INSERT_LOCATION;


PROCEDURE DELETE_LOCATION( p_location_id IN NUMBER, p_user_id IN NUMBER)
IS
--variable declarations
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);

BEGIN
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Deleting ACC record for user_id = '||p_user_id || 'for location id' ||p_location_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

 CSM_ACC_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     ,P_ACC_TABLE_NAME         => g_acc_table_name
     ,P_PK1_NAME               => g_pk1_name
     ,P_PK1_NUM_VALUE          => p_location_id
     ,P_USER_ID                => p_user_id
    );


  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Leaving Delete_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     RAISE;
     CSM_UTIL_PKG.LOG('Exception in CSM_HZ_LOCATIONS_EVENT_PKG.DELETE_LOCATION: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_HZ_LOCATIONS_EVENT_PKG.DELETE_LOCATION',FND_LOG.LEVEL_EXCEPTION);

END DELETE_LOCATION;

END CSM_HZ_LOCATIONS_EVENT_PKG;


/
