--------------------------------------------------------
--  DDL for Package Body CSL_HZ_LOCATIONS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_HZ_LOCATIONS_ACC_PKG" AS
/* $Header: cslhlacb.pls 120.1 2005/08/31 02:58:17 utekumal noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_HZ_LOCATIONS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_LOCATIONS');
g_table_name            CONSTANT VARCHAR2(30) := 'HZ_LOCATIONS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'LOCATION_ID';
g_debug_level NUMBER;

PROCEDURE INSERT_LOCATION( p_location_id IN NUMBER
                         , p_resource_id IN NUMBER )
IS
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
    , 'Inserting ACC record for resource_id = '||p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  JTM_HOOK_UTIL_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     , P_ACC_TABLE_NAME         => g_acc_table_name
     , P_PK1_NAME               => g_pk1_name
     , P_PK1_NUM_VALUE          => p_location_id
     , P_RESOURCE_ID            => p_resource_id
     );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Leaving Insert_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END INSERT_LOCATION;

PROCEDURE UPDATE_LOCATION( p_location_id IN NUMBER )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Entering Update_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
     ( P_ACC_TABLE_NAME  => g_acc_table_name
     , P_PK1_NAME        => g_pk1_name
     , P_PK1_NUM_VALUE   => p_location_id
     , L_TAB_RESOURCE_ID => l_tab_resource_id
     , L_TAB_ACCESS_ID   => l_tab_access_id
     );

    /*** re-send rec to all resources ***/
    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP

       IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( p_location_id
          , g_table_name
          , 'Updating ACC record for resource_id = ' || l_tab_resource_id(i) || fnd_global.local_chr(10) ||
	    'access_id = ' || l_tab_access_id(i)
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        JTM_HOOK_UTIL_PKG.Update_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
           ,P_ACC_TABLE_NAME         => g_acc_table_name
           ,P_RESOURCE_ID            => l_tab_resource_id(i)
           ,P_ACCESS_ID              => l_tab_access_id(i)
          );
       END LOOP;
    END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Leaving Udate_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END UPDATE_LOCATION;

PROCEDURE DELETE_LOCATION( p_location_id IN NUMBER
                         , p_resource_id IN NUMBER )
IS
BEGIN
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Entering Delete_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

 JTM_HOOK_UTIL_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     ,P_ACC_TABLE_NAME         => g_acc_table_name
     ,P_PK1_NAME               => g_pk1_name
     ,P_PK1_NUM_VALUE          => p_location_id
     ,P_RESOURCE_ID            => p_resource_id
    );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_location_id
    , g_table_name
    , 'Leaving Delete_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END DELETE_LOCATION;

PROCEDURE CHANGE_LOCATION( p_old_location_id IN NUMBER
                         , p_new_location_id IN NUMBER
		         , p_resource_id IN NUMBER )
IS
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_location_id
    , g_table_name
    , 'Entering Change_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_location_id
    , g_table_name
    , 'Change location from '||p_old_location_id||' to '||p_new_location_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*Party site is changed so delete the old one ( basicly we lower the counter )*/
  JTM_HOOK_UTIL_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     ,P_ACC_TABLE_NAME         => g_acc_table_name
     ,P_PK1_NAME               => g_pk1_name
     ,P_PK1_NUM_VALUE          => p_old_location_id
     ,P_RESOURCE_ID            => p_resource_id
    );

  /*Insert the new party site*/
  JTM_HOOK_UTIL_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     , P_ACC_TABLE_NAME         => g_acc_table_name
     , P_PK1_NAME               => g_pk1_name
     , P_PK1_NUM_VALUE          => p_new_location_id
     , P_RESOURCE_ID            => p_resource_id
     );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_location_id
    , g_table_name
    , 'Leaving Change_Location'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END CHANGE_LOCATION;

FUNCTION UPDATE_LOCATION_WFSUB( p_subscription_guid   in     raw
               , p_event               in out NOCOPY wf_event_t)
return varchar2
IS
 l_key                    varchar2(240) := p_event.GetEventKey();
 l_org_id                 NUMBER;
 l_user_id 	            NUMBER;
 l_resp_id 	            NUMBER;
 l_resp_appl_id           NUMBER;
 l_security_group_id      NUMBER;
 l_count	            NUMBER;
 l_location_id NUMBER;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;


  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_location_id
    , g_table_name
    , 'Entering UPDATE_LOCATION_WFSUB'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_org_id := p_event.GetValueForParameter('ORG_ID');
  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_group_id := p_event.GetValueForParameter('SECURITY_GROUP_ID');

  fnd_global.apps_initialize (l_user_id, l_resp_id, l_resp_appl_id, l_security_group_id);

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( l_location_id
        , g_table_name
        , 'Get parameter for hz parameter P_LOCATION_REC.LOCATION_ID'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  --Bug 4496299
  /*
  l_location_id := hz_param_pkg.ValueOfNumParameter  (p_key  => l_key,
                           p_parameter_name => 'P_LOCATION_REC.LOCATION_ID');
  */

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
      ( l_location_id
      , g_table_name
      , 'Retrieved parameter for hz parameter P_LOCATION_REC.LOCATION_ID ' || l_location_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*Is record valid ? assume so*/
--  IF Replicate_record( l_location_id ) THEN
  UPDATE_LOCATION(l_location_id);
--  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_location_id
    , g_table_name
    , 'Leaving UPDATE_LOCATION_WFSUB'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN 'SUCCESS';

EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('CSL_HZ_LOCATIONS_ACC_PKG', 'UPDATE_LOCATION_WFSUB', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
END UPDATE_LOCATION_WFSUB;

END CSL_HZ_LOCATIONS_ACC_PKG;

/
