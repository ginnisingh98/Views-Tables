--------------------------------------------------------
--  DDL for Package Body CSL_HZ_PARTY_SITES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_HZ_PARTY_SITES_ACC_PKG" AS
/* $Header: cslpsacb.pls 120.0 2005/05/24 18:18:39 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_HZ_PARTY_SITES_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_PARTY_SITES');
g_table_name            CONSTANT VARCHAR2(30) := 'HZ_PARTY_SITES';
g_pk1_name              CONSTANT VARCHAR2(30) := 'PARTY_SITE_ID';
g_debug_level NUMBER;

PROCEDURE INSERT_PARTY_SITE( p_party_site_id IN NUMBER
                           , p_resource_id IN NUMBER )
IS
 CURSOR c_party_site( b_party_site_id NUMBER ) IS
   SELECT *
   FROM HZ_PARTY_SITES
   WHERE party_site_id = b_party_site_id;

 r_party_site c_party_site%ROWTYPE;

BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_site_id
    , g_table_name
    , 'Entering Insert_Party_Site'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_site_id
    , g_table_name
    , 'Inserting ACC record for resource_id = '||p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  JTM_HOOK_UTIL_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     , P_ACC_TABLE_NAME         => g_acc_table_name
     , P_PK1_NAME               => g_pk1_name
     , P_PK1_NUM_VALUE          => p_party_site_id
     , P_RESOURCE_ID            => p_resource_id
     );

  /*Insert the matching location*/
  OPEN c_party_site( b_party_site_id => p_party_site_id );
  FETCH c_party_site INTO r_party_site;
  IF c_party_site%FOUND THEN
    CSL_HZ_LOCATIONS_ACC_PKG.INSERT_LOCATION( p_location_id => r_party_site.location_id
                                            , p_resource_id => p_resource_id );
  END IF;
  CLOSE c_party_site;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_site_id
    , g_table_name
    , 'Leaving Insert_Party_Site'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END INSERT_PARTY_SITE;

PROCEDURE UPDATE_PARTY_SITE( p_party_site_id IN NUMBER )
IS
  l_tab_resource_id    dbms_sql.Number_Table;
  l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_site_id
    , g_table_name
    , 'Entering Update_Party_Site'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
     ( P_ACC_TABLE_NAME  => g_acc_table_name
     , P_PK1_NAME        => g_pk1_name
     , P_PK1_NUM_VALUE   => p_party_site_id
     , L_TAB_RESOURCE_ID => l_tab_resource_id
     , L_TAB_ACCESS_ID   => l_tab_access_id
     );

    /*** re-send rec to all resources ***/
    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP

       IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( p_party_site_id
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
    ( p_party_site_id
    , g_table_name
    , 'Leaving Udate_Party_Site'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END UPDATE_PARTY_SITE;

PROCEDURE DELETE_PARTY_SITE( p_party_site_id IN NUMBER
                           , p_resource_id IN NUMBER )
IS
 CURSOR c_party_site( b_party_site_id NUMBER ) IS
   SELECT *
   FROM HZ_PARTY_SITES
   WHERE party_site_id = b_party_site_id;

 r_party_site c_party_site%ROWTYPE;

BEGIN
 g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_site_id
    , g_table_name
    , 'Entering Delete_Party_Site'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

 JTM_HOOK_UTIL_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
     ,P_ACC_TABLE_NAME         => g_acc_table_name
     ,P_PK1_NAME               => g_pk1_name
     ,P_PK1_NUM_VALUE          => p_party_site_id
     ,P_RESOURCE_ID            => p_resource_id
    );

  /*Delete the matching location*/
  OPEN c_party_site( b_party_site_id => p_party_site_id );
  FETCH c_party_site INTO r_party_site;
  IF c_party_site%FOUND THEN
    CSL_HZ_LOCATIONS_ACC_PKG.DELETE_LOCATION( p_location_id => r_party_site.location_id
                                            , p_resource_id => p_resource_id );
  END IF;
  CLOSE c_party_site;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_site_id
    , g_table_name
    , 'Leaving Delete_Party_Site'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END DELETE_PARTY_SITE;

PROCEDURE CHANGE_PARTY_SITE( p_old_party_site_id IN NUMBER
                           , p_new_party_site_id IN NUMBER
		           , p_resource_id IN NUMBER )
IS
 CURSOR c_party_site( b_party_site_id NUMBER ) IS
   SELECT *
   FROM HZ_PARTY_SITES
   WHERE party_site_id = b_party_site_id;

 r_party_site c_party_site%ROWTYPE;

BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_party_site_id
    , g_table_name
    , 'Entering Change_Party_Site'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_party_site_id
    , g_table_name
    , 'Change party site from '||p_old_party_site_id||' to '||p_new_party_site_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*Party site is changed so delete the old one ( basicly we lower the counter )*/
  IF p_old_party_site_id IS NOT NULL THEN
    JTM_HOOK_UTIL_PKG.Delete_Acc
      ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
       ,P_ACC_TABLE_NAME         => g_acc_table_name
       ,P_PK1_NAME               => g_pk1_name
       ,P_PK1_NUM_VALUE          => p_old_party_site_id
       ,P_RESOURCE_ID            => p_resource_id
      );

    /*Delete the matching location*/
    OPEN c_party_site( b_party_site_id => p_old_party_site_id );
    FETCH c_party_site INTO r_party_site;
    IF c_party_site%FOUND THEN
      CSL_HZ_LOCATIONS_ACC_PKG.DELETE_LOCATION( p_location_id => r_party_site.location_id
                                              , p_resource_id => p_resource_id );
    END IF;
    CLOSE c_party_site;
  END IF;


  /*Insert the new party site*/
  IF p_new_party_site_id IS NOT NULL THEN
    JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name
       , P_ACC_TABLE_NAME         => g_acc_table_name
       , P_PK1_NAME               => g_pk1_name
       , P_PK1_NUM_VALUE          => p_new_party_site_id
       , P_RESOURCE_ID            => p_resource_id
       );
    --Bug 3991346 - Call INSERT_LOCATION instead of DELETE_LOCATION
    /*Insert the matching location*/
    OPEN c_party_site( b_party_site_id => p_new_party_site_id );
    FETCH c_party_site INTO r_party_site;
    IF c_party_site%FOUND THEN
      CSL_HZ_LOCATIONS_ACC_PKG.INSERT_LOCATION( p_location_id => r_party_site.location_id
                                              , p_resource_id => p_resource_id );
    END IF;
    CLOSE c_party_site;
  END IF;


  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_old_party_site_id
    , g_table_name
    , 'Leaving Change_Party_Site'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END CHANGE_PARTY_SITE;

END CSL_HZ_PARTY_SITES_ACC_PKG;

/
