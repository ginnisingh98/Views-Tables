--------------------------------------------------------
--  DDL for Package Body CSL_MTL_SEC_LOCATORS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_SEC_LOCATORS_ACC_PKG" AS
/* $Header: cslslacb.pls 120.1 2005/06/01 23:39:40 appldev  $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_MTL_SECONDARY_LOCATORS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_SECONDARY_LOCATORS');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_SECONDARY_LOCATORS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'INVENTORY_ITEM_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'SECONDARY_LOCATOR';
g_pk3_name              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_debug_level           NUMBER; -- debug level

/*
  Private procedure that re-pushes replicated secondary locators
  that were updated since the last time the concurrent program ran.
  This is called from the CON_REQUEST_SECONDARY_LOCATORS procedure.
*/
PROCEDURE UPDATE_ACC_REC_MARKDIRTY( p_last_run_date   IN DATE )
IS
 CURSOR c_changed( b_last_date       DATE ) IS
  SELECT acc.ACCESS_ID, acc.RESOURCE_ID
  FROM CSL_MTL_SECONDARY_LOCATORS_ACC acc
  ,    MTL_SECONDARY_LOCATORS b
  ,    ASG_USER au
  WHERE b.SECONDARY_LOCATOR = acc.SECONDARY_LOCATOR
  AND   b.ORGANIZATION_ID = acc.ORGANIZATION_ID
  AND   b.INVENTORY_ITEM_ID = acc.INVENTORY_ITEM_ID
  AND   au.RESOURCE_ID = acc.RESOURCE_ID
  AND   b.LAST_UPDATE_DATE  >= b_last_date;

 l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
 l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
 l_dummy BOOLEAN;

BEGIN
 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering UPDATE_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

 /*Fetch all changed item locations that are in the acc table*/
 OPEN c_changed( p_last_run_date );
 FETCH c_changed BULK COLLECT INTO l_tab_access_id, l_tab_resource_id;
 /*Call oracle lite*/
 IF l_tab_access_id.COUNT > 0 THEN
  /*** 1 or more acc rows retrieved -> push to resource ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
      , g_table_name
      , 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s)'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
   END IF;
   /*** push to oLite using asg_download ***/
   l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
         , P_ACCESSLIST   => l_tab_access_id
         , P_RESOURCELIST => l_tab_resource_id
         , P_DML_TYPE     => 'U'
         , P_TIMESTAMP    => SYSDATE
         );
 END IF;
 CLOSE c_changed;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving UPDATE_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'UPDATE_ACC_REC_MARKDIRTY'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END UPDATE_ACC_REC_MARKDIRTY;

/*
  Private procedure that re-pushes replicated secondary locators
  that were inserted since the last time the concurrent program ran.
  This is called from the CON_REQUEST_SECONDARY_LOCATORS procedure.
*/
PROCEDURE INSERT_ACC_REC_MARKDIRTY( p_last_run_date   IN DATE )
IS
  CURSOR c_inserted( b_last_date       DATE )
  IS SELECT CSL_ACC_SEQUENCE.NEXTVAL, I.RESOURCE_ID, S.INVENTORY_ITEM_ID, S.SECONDARY_LOCATOR, S.ORGANIZATION_ID, I.COUNTER
     FROM MTL_SECONDARY_LOCATORS S, CSL_MTL_ITEM_LOCATIONS_ACC A,
          JTM_MTL_SYSTEM_ITEMS_ACC I, ASG_USER U
     WHERE S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
       AND S.ORGANIZATION_ID = I.ORGANIZATION_ID
       AND S.SECONDARY_LOCATOR = A.INVENTORY_LOCATION_ID
       AND S.ORGANIZATION_ID = A.ORGANIZATION_ID
       AND A.RESOURCE_ID = I.RESOURCE_ID
       AND A.RESOURCE_ID = U.RESOURCE_ID
       AND ( S.CREATION_DATE  >= NVL(b_last_date, S.CREATION_DATE)
         OR A.CREATION_DATE >= NVL(b_last_date, A.CREATION_DATE) -- cover sec_loc records to be added as new MTL_ITEM_LOCATIONS added
         OR I.CREATION_DATE >= NVL(b_last_date, I.CREATION_DATE) -- cover sec_loc records to be added as new MTL_SYSTEM_ITEMS added
       )
       AND (I.RESOURCE_ID, S.INVENTORY_ITEM_ID, S.SECONDARY_LOCATOR, S.ORGANIZATION_ID)
       NOT IN
        ( SELECT RESOURCE_ID, INVENTORY_ITEM_ID, SECONDARY_LOCATOR, ORGANIZATION_ID
          FROM CSL_MTL_SECONDARY_LOCATORS_ACC
        );

  l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
  l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
  TYPE item_Tab  IS TABLE OF MTL_SECONDARY_LOCATORS.INVENTORY_ITEM_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE location_Tab  IS TABLE OF MTL_SECONDARY_LOCATORS.SECONDARY_LOCATOR%TYPE INDEX BY BINARY_INTEGER;
  TYPE org_Tab   IS TABLE OF MTL_SECONDARY_LOCATORS.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE counter_Tab   IS TABLE OF CSL_MTL_SECONDARY_LOCATORS_ACC.COUNTER%TYPE INDEX BY BINARY_INTEGER;
  locations          location_Tab;
  items        item_Tab;
  organizations  org_Tab;
  counters       counter_Tab;

  l_dummy BOOLEAN;
  -- CSL.CSL_ACC_SEQUENCE
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering INSERT_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;

  /*Increment count if the record already exists */
  UPDATE CSL_MTL_SECONDARY_LOCATORS_ACC
  SET COUNTER = COUNTER + 1
  ,   LAST_UPDATE_DATE = SYSDATE
  ,   LAST_UPDATED_BY = 1
  WHERE ( RESOURCE_ID, INVENTORY_ITEM_ID, SECONDARY_LOCATOR, ORGANIZATION_ID ) IN
  (  SELECT I.RESOURCE_ID, S.INVENTORY_ITEM_ID, S.SECONDARY_LOCATOR, S.ORGANIZATION_ID
     FROM MTL_SECONDARY_LOCATORS S, CSL_MTL_ITEM_LOCATIONS_ACC A,
          JTM_MTL_SYSTEM_ITEMS_ACC I, ASG_USER U
     WHERE S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
       AND S.ORGANIZATION_ID = I.ORGANIZATION_ID
       AND S.SECONDARY_LOCATOR = A.INVENTORY_LOCATION_ID
       AND S.ORGANIZATION_ID = A.ORGANIZATION_ID
       AND A.RESOURCE_ID = I.RESOURCE_ID
       AND A.RESOURCE_ID = U.RESOURCE_ID
       AND ( S.CREATION_DATE  >= NVL(p_last_run_date, S.CREATION_DATE)
         OR A.CREATION_DATE >= NVL(p_last_run_date, A.CREATION_DATE) -- cover sec_loc records to be added as new MTL_ITEM_LOCATIONS added
         OR I.CREATION_DATE >= NVL(p_last_run_date, I.CREATION_DATE) -- cover sec_loc records to be added as new MTL_SYSTEM_ITEMS added
       )
  );

 /*Fetch all changed item locations that are in the acc table*/
 OPEN c_inserted( p_last_run_date );
 FETCH c_inserted BULK COLLECT
 INTO l_tab_access_id, l_tab_resource_id, items, locations, organizations, counters;
 /*Call oracle lite*/
 IF l_tab_access_id.COUNT > 0 THEN
  /*** 1 or more acc rows retrieved -> push to resource ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
      , g_table_name
      , 'Pushing ' || l_tab_access_id.COUNT || ' inserted record(s)'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
   END IF;

   FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
     INSERT INTO CSL_MTL_SECONDARY_LOCATORS_ACC(
                ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY
                , COUNTER, RESOURCE_ID, INVENTORY_ITEM_ID, SECONDARY_LOCATOR, ORGANIZATION_ID ) VALUES (
		l_tab_access_id(i), sysdate, 1, sysdate, 1, counters(i), l_tab_resource_id(i), items(i), locations(i), organizations(i));

    /*** push to oLite using asg_download ***/
   l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
         , P_ACCESSLIST   => l_tab_access_id
         , P_RESOURCELIST => l_tab_resource_id
         , P_DML_TYPE     => 'I'
         , P_TIMESTAMP    => SYSDATE
         );
 END IF;
 CLOSE c_inserted;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving INSERT_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'INSERT_ACC_REC_MARKDIRTY'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END INSERT_ACC_REC_MARKDIRTY;

/*
  This procedure will trigger the insert of the corresponding MTL_SECONDARY_LOCATORS record as well.
  This will be called from CSL_MTL_SYSTEM_ITEMS_ACC_PKG insertion procedures except in the CON_REQUEST_SYSTEM_ITEMS calls.
 */
PROCEDURE Insert_Secondary_Locators
  ( p_inventory_item_id      IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  )
IS
  CURSOR c_sec_locator ( b_inventory_item_id NUMBER, b_org_id NUMBER, b_resource_id NUMBER)
  IS SELECT S.SECONDARY_LOCATOR
     FROM MTL_SECONDARY_LOCATORS S, CSL_MTL_ITEM_LOCATIONS_ACC A
     WHERE S.INVENTORY_ITEM_ID = b_inventory_item_id
       AND S.ORGANIZATION_ID = b_org_id
       AND S.SECONDARY_LOCATOR = A.INVENTORY_LOCATION_ID
       AND S.ORGANIZATION_ID = A.ORGANIZATION_ID
       AND A.RESOURCE_ID = b_resource_id;
  r_sec_locator c_sec_locator%ROWTYPE;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_item_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_Secondary_Locators'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_sec_locator IN c_sec_locator(p_inventory_item_id, p_organization_id, p_resource_id)
  LOOP
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Inserting ACC record :' || p_inventory_item_id || ' for resource id '
                         || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /* comment this out, assuming that CSL_MTL_ITEM_LOCATIONS_ACC records already exist
    CSL_MTL_ITEM_LOCATIONS_ACC_PKG.Insert_Item_Location
    ( p_inventory_location_id => r_sec_locator.SECONDARY_LOCATOR
     ,p_organization_id       => p_organization_id
     ,p_resource_id           => p_resource_id
    );
    */

    /*** Call common package to insert record into ACC table ***/
    JTM_HOOK_UTIL_PKG.Insert_Acc
    ( p_publication_item_names => g_publication_item_name
     ,p_acc_table_name         => g_acc_table_name
     ,p_resource_id            => p_resource_id
     ,p_pk1_name               => g_pk1_name
     ,p_pk1_char_value         => p_inventory_item_id
     ,p_pk2_name               => g_pk2_name
     ,p_pk2_num_value          => r_sec_locator.SECONDARY_LOCATOR
     ,p_pk3_name               => g_pk3_name
     ,p_pk3_num_value          => p_organization_id
    );
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_item_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Insert_Secondary_Locators'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_Secondary_Locators;

PROCEDURE Update_Secondary_Locators
  ( p_inventory_item_id      IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  ) IS
BEGIN
  NULL;
END Update_Secondary_Locators;

/*
  This procedure will trigger the delete of the corresponding MTL_SECONDARY_LOCATORS record as well.
  This will be called from CSL_MTL_SYSTEM_ITEMS_ACC_PKG deletion procedures except in the CON_REQUEST_SYSTEM_ITEMS calls.
 */
PROCEDURE Delete_Secondary_Locators
  ( p_inventory_item_id      IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  ) IS
  CURSOR c_sec_locator (b_inventory_item_id NUMBER, b_org_id NUMBER, b_resource_id NUMBER)
  IS SELECT SECONDARY_LOCATOR, ACCESS_ID
     FROM CSL_MTL_SECONDARY_LOCATORS_ACC
     WHERE INVENTORY_ITEM_ID = b_inventory_item_id
       AND ORGANIZATION_ID = b_org_id
       AND RESOURCE_ID = b_resource_id;
  r_sec_locator c_sec_locator%ROWTYPE;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_item_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Delete_Secondary_Locators'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_sec_locator IN c_sec_locator(p_inventory_item_id, p_organization_id, p_resource_id)
  LOOP
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Deleting ACC record :' || p_inventory_item_id || ' for resource id '
                         || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*
    CSL_MTL_ITEM_LOCATIONS_ACC_PKG.Delete_Item_Location
    ( p_inventory_location_id => r_sec_locator.SECONDARY_LOCATOR
     ,p_organization_id       => p_organization_id
     ,p_resource_id           => p_resource_id
    );
    */
    /*** Call common package to insert record into ACC table ***/
    JTM_HOOK_UTIL_PKG.Delete_Acc
    ( p_publication_item_names => g_publication_item_name
     ,p_acc_table_name         => g_acc_table_name
     ,p_resource_id            => p_resource_id
     ,p_pk1_name               => g_pk1_name
     ,p_pk1_char_value         => p_inventory_item_id
     ,p_pk2_name               => g_pk2_name
     ,p_pk2_num_value          => r_sec_locator.SECONDARY_LOCATOR
     ,p_pk3_name               => g_pk2_name
     ,p_pk3_num_value          => p_organization_id
    );
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_item_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Delete_Secondary_Locators'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_Secondary_Locators;

/*
  This procedure is used to populate the MTL_SECONDARY_LOCATORS records upon patching
  (upgrading with JTM_MTL_SYSTEM_ITEMS_ACC already filled).
  It's also called from CSL_MTL_SYSTEM_ITEMS_ACC_PKG.INSERT_ALL_ACC_RECORDS
 */
PROCEDURE POPULATE_SEC_LOCATORS_ACC IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR c_inserted
  IS SELECT CSL_ACC_SEQUENCE.NEXTVAL, I.RESOURCE_ID, S.INVENTORY_ITEM_ID, S.SECONDARY_LOCATOR, S.ORGANIZATION_ID, I.COUNTER
     FROM MTL_SECONDARY_LOCATORS S, CSL_MTL_ITEM_LOCATIONS_ACC A,
          JTM_MTL_SYSTEM_ITEMS_ACC I, ASG_USER U
     WHERE S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
       AND S.ORGANIZATION_ID = I.ORGANIZATION_ID
       AND S.SECONDARY_LOCATOR = A.INVENTORY_LOCATION_ID
       AND S.ORGANIZATION_ID = A.ORGANIZATION_ID
       AND A.RESOURCE_ID = I.RESOURCE_ID
       AND A.RESOURCE_ID = U.RESOURCE_ID;
  l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
  l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
  TYPE inventory_item_Tab  IS TABLE OF MTL_SECONDARY_LOCATORS.INVENTORY_ITEM_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE location_Tab  IS TABLE OF MTL_SECONDARY_LOCATORS.SECONDARY_LOCATOR%TYPE INDEX BY BINARY_INTEGER;
  TYPE org_Tab   IS TABLE OF MTL_SECONDARY_LOCATORS.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE counter_Tab   IS TABLE OF JTM_MTL_SYSTEM_ITEMS_ACC.COUNTER%TYPE INDEX BY BINARY_INTEGER;
  items          inventory_item_Tab;
  locations      location_Tab;
  organizations  org_Tab;
  counters       counter_Tab;

  l_dummy BOOLEAN;

BEGIN
  DELETE FROM CSL_MTL_SECONDARY_LOCATORS_ACC;

 OPEN c_inserted;
 FETCH c_inserted BULK COLLECT
 INTO l_tab_access_id, l_tab_resource_id, items, locations, organizations, counters;
 /*Call oracle lite*/
 IF l_tab_access_id.COUNT > 0 THEN
  /*** 1 or more acc rows retrieved -> push to resource ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
      , g_table_name
      , 'Pushing ' || l_tab_access_id.COUNT || ' inserted record(s)'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
   END IF;

   FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
     INSERT INTO CSL_MTL_SECONDARY_LOCATORS_ACC(
                ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY
                , COUNTER, RESOURCE_ID, INVENTORY_ITEM_ID, SECONDARY_LOCATOR, ORGANIZATION_ID ) VALUES (
		l_tab_access_id(i), sysdate, 1, sysdate, 1,
                counters(i), l_tab_resource_id(i), items(i), locations(i), organizations(i));

    /*** push to oLite using asg_download ***/
   l_dummy := asg_download.markdirty(
           P_PUB_ITEM     => g_publication_item_name(1)
         , P_ACCESSLIST   => l_tab_access_id
         , P_RESOURCELIST => l_tab_resource_id
         , P_DML_TYPE     => 'I'
         , P_TIMESTAMP    => SYSDATE
         );
  END IF;
  CLOSE c_inserted;
  COMMIT;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Leaving INSERT_ACC_REC_MARKDIRTY'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'INSERT_ACC_REC_MARKDIRTY'||fnd_global.local_chr(10)||
      'Error: '||sqlerrm
    , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  RAISE;
END POPULATE_SEC_LOCATORS_ACC;

/*
  Concurrent program run to periodically pick up the changes on
  MTL_SECONDARY_LOCATORS table.
 */
PROCEDURE CON_REQUEST_SECONDARY_LOCATORS
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  /*** get the last run date of the concurent program ***/
  CURSOR  c_LastRundate
  IS
    select LAST_RUN_DATE
    from   JTM_CON_REQUEST_DATA
    where  package_name =  'CSL_MTL_SEC_LOCATORS_ACC_PKG'
    AND    procedure_name = 'CON_REQUEST_SECONDARY_LOCATORS';
  r_LastRundate  c_LastRundate%ROWTYPE;
  l_current_run_date DATE;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering CON_REQUEST_SECONDARY_LOCATORS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  /*** First retrieve last run date of the conccurent program ***/
  OPEN  c_LastRundate;
  FETCH c_LastRundate  INTO r_LastRundate;
  CLOSE c_LastRundate;

  l_current_run_date := SYSDATE;

  /*** Push updated system item records to resources ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Pushing updated records'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    );
  END IF;
  UPDATE_ACC_REC_MARKDIRTY( p_last_run_date => r_LastRundate.last_run_date );
  COMMIT;

  -- INSERT new records if found, for the mobile users' subinventories
  /*** Get the mobile laptop resources and loop over all of them ***/
  INSERT_ACC_REC_MARKDIRTY( p_last_run_date => r_LastRundate.last_run_date );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
     ( 0
     , g_table_name
     , 'Updating LAST_RUN_DATE from '||r_LastRundate.LAST_RUN_DATE||' to '||l_current_run_date
     , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
     );
  END IF;

  /*Update the last run date*/
  UPDATE JTM_CON_REQUEST_DATA
  SET LAST_RUN_DATE = l_current_run_date
  WHERE package_name =  'CSL_MTL_SEC_LOCATORS_ACC_PKG'
  AND   procedure_name = 'CON_REQUEST_SECONDARY_LOCATORS';

  COMMIT;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
   jtm_message_log_pkg.Log_Msg
   ( 0
   , g_table_name
   , 'Leaving CON_REQUEST_SECONDARY_LOCATORS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
   );
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'CON_REQUEST_SECONDARY_LOCATORS'||fnd_global.local_chr(10)||
        'Error: '||sqlerrm
      , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  END IF;
  ROLLBACK;
END CON_REQUEST_SECONDARY_LOCATORS;

END CSL_MTL_SEC_LOCATORS_ACC_PKG; -- Package Body CSL_MTL_SEC_LOCATORS_ACC_PKG

/
