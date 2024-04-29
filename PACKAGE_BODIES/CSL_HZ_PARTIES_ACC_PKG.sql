--------------------------------------------------------
--  DDL for Package Body CSL_HZ_PARTIES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_HZ_PARTIES_ACC_PKG" AS
/* $Header: cslpaacb.pls 120.1 2005/08/31 02:56:49 utekumal noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_HZ_PARTIES_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_PARTIES');
g_table_name            CONSTANT VARCHAR2(30) := 'HZ_PARTIES';
g_pk1_name              CONSTANT VARCHAR2(30) := 'PARTY_ID';
g_debug_level NUMBER;

/**
 *
 */
FUNCTION Replicate_Record( p_party_id IN NUMBER)
RETURN BOOLEAN
IS
 CURSOR c_party( b_party_id NUMBER ) IS
  SELECT party_id        -- Fix for Sql Performance
  FROM HZ_PARTIES
  WHERE PARTY_ID = b_party_id;
 r_party c_party%ROWTYPE;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Entering Replicate_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_party( p_party_id );
  FETCH c_party INTO r_party;
  IF c_party%FOUND THEN
    CLOSE c_party;
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_party_id
      , g_table_name
      , 'Replicate_record returned TRUE'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    RETURN TRUE;
  END IF;
  CLOSE c_party;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Replicate_record returned FALSE'||fnd_global.local_chr(10)||
      'Could not find party with party_id: '||p_party_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  RETURN FALSE;
END Replicate_Record;

/**
 *
 */
PROCEDURE INSERT_ACC_RECORD( p_party_id    IN NUMBER
                           , p_resource_id IN NUMBER )
IS
BEGIN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Entering Insert_Acc_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Inserting ACC record for resource_id = '||p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  JTM_HOOK_UTIL_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     , P_ACC_TABLE_NAME         => g_acc_table_name
     , P_PK1_NAME               => g_pk1_name
     , P_PK1_NUM_VALUE          => p_party_id
     , P_RESOURCE_ID            => p_resource_id
     );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Leaving Insert_Acc_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END INSERT_ACC_RECORD;

/**
 *
 */
PROCEDURE UPDATE_ACC_RECORD( p_access_id IN NUMBER
                           , p_party_id IN NUMBER
                           , p_resource_id IN NUMBER )
IS
BEGIN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Entering Update_Acc_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( p_party_id
     , g_table_name
     , 'Updating ACC record for resource_id = ' || p_resource_id || fnd_global.local_chr(10)
        || 'access_id = ' ||p_access_id
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  JTM_HOOK_UTIL_PKG.Update_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     , P_ACC_TABLE_NAME         => g_acc_table_name
     , P_RESOURCE_ID            => p_resource_id
     , P_ACCESS_ID              => p_access_id
     );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Leaving Update_Acc_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END UPDATE_ACC_RECORD;

/**
 *
 */
PROCEDURE DELETE_ACC_RECORD( p_party_id IN NUMBER
                           , p_resource_id IN NUMBER )
IS
BEGIN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Entering Delete_Acc_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( p_party_id
     , g_table_name
     , 'Deleting party '|| p_party_id ||' for resource_id = ' || p_resource_id
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  JTM_HOOK_UTIL_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     ,P_ACC_TABLE_NAME         => g_acc_table_name
     ,P_PK1_NAME               => g_pk1_name
     ,P_PK1_NUM_VALUE          => p_party_id
     ,P_RESOURCE_ID            => p_resource_id
    );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Leaving Delete_Acc_Record'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END DELETE_ACC_RECORD;

/**
 *
 */
PROCEDURE INSERT_PARTY( p_party_id    IN NUMBER
                      , p_resource_id IN NUMBER
		      , p_flow_type   IN NUMBER )--DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL)
IS
 l_return BOOLEAN;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Entering Insert_Party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_return := Replicate_Record( p_party_id );
  IF l_return = TRUE THEN

    INSERT_ACC_RECORD( p_party_id, p_resource_id );

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_party_id
      , g_table_name
      , 'Get the notes for this party'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    /*Only replicate notes for non history sr*/
    IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
      l_return := CSL_JTF_NOTES_ACC_PKG.PRE_INSERT_CHILDREN
                                      ( P_SOURCE_OBJ_ID   => p_party_id
  				      , P_SOURCE_OBJ_CODE => 'PARTY'
  				      , P_RESOURCE_ID     => p_resource_id );
    END IF;--p_flow_type
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Leaving Insert_Party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END INSERT_PARTY;

/**
 *
 */
PROCEDURE UPDATE_PARTY( p_party_id IN NUMBER )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Entering Update_Party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
     ( P_ACC_TABLE_NAME  => g_acc_table_name
     , P_PK1_NAME        => g_pk1_name
     , P_PK1_NUM_VALUE   => p_party_id
     , L_TAB_RESOURCE_ID => l_tab_resource_id
     , L_TAB_ACCESS_ID   => l_tab_access_id
     );

    /*** re-send rec to all resources ***/
    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
        UPDATE_ACC_RECORD( p_access_id   => l_tab_access_id(i)
	                 , p_party_id    => p_party_id
			 , p_resource_id => l_tab_resource_id(i));
       END LOOP;
    END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Leaving Update_Party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END UPDATE_PARTY;

/**
 *
 */
PROCEDURE DELETE_PARTY( p_party_id    IN NUMBER
                      , p_resource_id IN NUMBER
		      , p_flow_type   IN NUMBER )--DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL)
IS
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Entering Delete_Party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  DELETE_ACC_RECORD( p_party_id, p_resource_id );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Delete the notes for this party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*History records did not have notes so leave notes untouched*/
  IF p_flow_type <> CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY THEN
    CSL_JTF_NOTES_ACC_PKG.POST_DELETE_CHILDREN( P_SOURCE_OBJ_ID   => p_party_id
                                              , P_SOURCE_OBJ_CODE => 'PARTY'
  					      , P_RESOURCE_ID     => p_resource_id );
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , g_table_name
    , 'Leaving Delete_Party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END DELETE_PARTY;

/**
 *
 */
PROCEDURE CHANGE_PARTY( p_old_party_id IN NUMBER
                      , p_new_party_id IN NUMBER
		      , p_resource_id IN NUMBER )
IS
 l_return BOOLEAN;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_party_id
    , g_table_name
    , 'Entering Change_Party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_party_id
    , g_table_name
    , 'Change party from '||p_old_party_id||' to '||p_new_party_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;


  /*Party is changed so delete the old one ( basicly we lower the counter )*/
  DELETE_ACC_RECORD( p_old_party_id, p_resource_id );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_party_id
    , g_table_name
    , 'Delete the notes for the old party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  /*Delete the matching notes*/
  CSL_JTF_NOTES_ACC_PKG.POST_DELETE_CHILDREN( P_SOURCE_OBJ_ID   => p_old_party_id
                                            , P_SOURCE_OBJ_CODE => 'PARTY'
					    , P_RESOURCE_ID     => p_resource_id );

  l_return := Replicate_Record( p_new_party_id );
  IF l_return = TRUE THEN
    /*Insert the new party*/
    INSERT_ACC_RECORD( p_new_party_id, p_resource_id );
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_new_party_id
      , g_table_name
      , 'Insert the notes for the new party'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    /*Insert the notes*/
    l_return := CSL_JTF_NOTES_ACC_PKG.PRE_INSERT_CHILDREN
                                    ( P_SOURCE_OBJ_ID   => p_new_party_id
  				    , P_SOURCE_OBJ_CODE => 'PARTY'
  				    , P_RESOURCE_ID     => p_resource_id );
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_party_id
    , g_table_name
    , 'Leaving Change_Party'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END CHANGE_PARTY;

/**
 *
 */
PROCEDURE PRE_INSERT_PARTY ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

/**
 *
 */
PROCEDURE POST_INSERT_PARTY ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

/**
 *
 */
PROCEDURE PRE_UPDATE_PARTY ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

/**
 *
 */
PROCEDURE POST_UPDATE_PARTY ( x_return_status OUT NOCOPY varchar2)
IS
 l_party_id NUMBER;
 l_tab_resource_id    dbms_sql.Number_Table;
 l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  /*TODO get the party id from the hook api*/
  l_party_id := 0;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_party_id
    , g_table_name
    , 'Entering POST_UPDATE_PARTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
      ( l_party_id
      , g_table_name
      , 'Check if a resource has this party'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*Is record valid ?*/
  IF Replicate_record( l_party_id ) THEN
    /*Check if the party is asigned to a resource*/
    JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
       ( P_ACC_TABLE_NAME  => g_acc_table_name
       , P_PK1_NAME        => g_pk1_name
       , P_PK1_NUM_VALUE   => l_party_id
       , L_TAB_RESOURCE_ID => l_tab_resource_id
       , L_TAB_ACCESS_ID   => l_tab_access_id
       );

    /*** re-send rec to all resources ***/
    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
        UPDATE_ACC_RECORD( p_access_id   => l_tab_access_id(i)
  	                 , p_party_id    => l_party_id
  			 , p_resource_id => l_tab_resource_id(i));
      END LOOP;
    END IF;
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_party_id
    , g_table_name
    , 'Leaving POST_UPDATE_PARTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

/**
 *
 */
PROCEDURE PRE_DELETE_PARTY ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

/**
 *
 */
PROCEDURE POST_DELETE_PARTY ( x_return_status OUT NOCOPY varchar2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

FUNCTION UPDATE_PARTY_WFSUB( p_subscription_guid   in     raw
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
 l_party_id NUMBER;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;


  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_party_id
    , g_table_name
    , 'Entering UPDATE_PARTY_WFSUB'
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
        ( l_party_id
        , g_table_name
        , 'Get parameter for hz parameter P_ORGANIZATION_REC.PARTY_REC.PARTY_ID'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  --Bug 4496299
  /*
  l_party_id := hz_param_pkg.ValueOfNumParameter  (p_key  => l_key,
                           p_parameter_name => 'P_ORGANIZATION_REC.PARTY_REC.PARTY_ID');
  */

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
      ( l_party_id
      , g_table_name
      , 'Retrieved parameter for hz parameter P_ORGANIZATION_REC.PARTY_REC.PARTY_ID ' || l_party_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*Is record valid ? assume so*/
--  IF Replicate_record( l_party_id ) THEN
  UPDATE_PARTY(l_party_id);
--  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_party_id
    , g_table_name
    , 'Leaving UPDATE_PARTY_WFSUB'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN 'SUCCESS';

EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('CSL_HZ_PARTIES_ACC_PKG', 'UPDATE_PARTY_WFSUB', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
END UPDATE_PARTY_WFSUB;
END CSL_HZ_PARTIES_ACC_PKG;

/
