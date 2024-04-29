--------------------------------------------------------
--  DDL for Package Body CSL_MTL_ITEM_LOCATIONS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_ITEM_LOCATIONS_ACC_PKG" AS
/* $Header: cslmlacb.pls 115.1 2003/10/24 23:35:06 yliao noship $ */

/*
  This package will be called from CSL_CSP_INV_LOC_ASS_ACC_PKG.
  Pre_Insert_Child(..).
  When assigning a sub-inventory to a resource, we check the
  mtl_item_locations records associated with this sub-inventory,
  and insert them into the CSL_MTL_ITEM_LOCATIONS_ACC table.
  Same check applies for deletion of system items.

  We also need functions to be called for upgrade of exsting users
  without new subinventory assignments.
*/

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_MTL_ITEM_LOCATIONS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_ITEM_LOCATIONS');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_ITEM_LOCATIONS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'INVENTORY_LOCATION_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_debug_level           NUMBER; -- debug level

/*
  Private procedure that re-pushes replicated item locations
  that were updated since the last time the concurrent program ran.
*/
PROCEDURE UPDATE_ACC_REC_MARKDIRTY( p_last_run_date   IN DATE )
IS
 CURSOR c_changed( b_last_date       DATE ) IS
  SELECT acc.ACCESS_ID, acc.RESOURCE_ID
  FROM CSL_MTL_ITEM_LOCATIONS_ACC acc
  ,    MTL_ITEM_LOCATIONS b
  ,    ASG_USER   au
  WHERE b.INVENTORY_LOCATION_ID = acc.INVENTORY_LOCATION_ID
  AND   b.ORGANIZATION_ID = acc.ORGANIZATION_ID
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
  Private procedure that re-pushes replicated item locations
  that were inserted since the last time the concurrent program ran.
*/
PROCEDURE INSERT_ACC_REC_MARKDIRTY( p_last_run_date   IN DATE )
IS
 CURSOR c_inserted( b_last_date       DATE ) IS
    SELECT CSL_ACC_SEQUENCE.NEXTVAL, SEC.RESOURCE_ID, LOC.INVENTORY_LOCATION_ID, LOC.ORGANIZATION_ID, SEC.COUNTER
    FROM JTM_MTL_SEC_INV_ACC SEC, MTL_ITEM_LOCATIONS LOC
    WHERE SEC.SECONDARY_INVENTORY_NAME = LOC.SUBINVENTORY_CODE
        AND SEC.ORGANIZATION_ID = LOC.ORGANIZATION_ID
        AND LOC.CREATION_DATE  >= NVL(b_last_date, LOC.CREATION_DATE)
        AND (SEC.RESOURCE_ID, LOC.INVENTORY_LOCATION_ID, LOC.ORGANIZATION_ID)
        NOT IN
        ( SELECT RESOURCE_ID, INVENTORY_LOCATION_ID, ORGANIZATION_ID
          FROM CSL_MTL_ITEM_LOCATIONS_ACC
        );

 l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
 l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
 TYPE location_Tab  IS TABLE OF MTL_ITEM_LOCATIONS.INVENTORY_LOCATION_ID%TYPE INDEX BY BINARY_INTEGER;
 TYPE org_Tab   IS TABLE OF MTL_ITEM_LOCATIONS.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
 TYPE counter_Tab   IS TABLE OF JTM_MTL_SEC_INV_ACC.COUNTER%TYPE INDEX BY BINARY_INTEGER;
 locations          location_Tab;
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
  UPDATE CSL_MTL_ITEM_LOCATIONS_ACC
  SET COUNTER = COUNTER + 1
  ,   LAST_UPDATE_DATE = SYSDATE
  ,   LAST_UPDATED_BY = 1
  WHERE ( RESOURCE_ID, INVENTORY_LOCATION_ID, ORGANIZATION_ID ) IN
  ( SELECT SEC.RESOURCE_ID, LOC.INVENTORY_LOCATION_ID, LOC.ORGANIZATION_ID
    FROM JTM_MTL_SEC_INV_ACC SEC, MTL_ITEM_LOCATIONS LOC
    WHERE SEC.SECONDARY_INVENTORY_NAME = LOC.SUBINVENTORY_CODE
        AND LOC.CREATION_DATE  >= NVL(p_last_run_date, LOC.CREATION_DATE)
  );

 /*Fetch all changed item locations that are in the acc table*/
 OPEN c_inserted( p_last_run_date );
 FETCH c_inserted BULK COLLECT
 INTO l_tab_access_id, l_tab_resource_id, locations, organizations, counters;
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
     INSERT INTO CSL_MTL_ITEM_LOCATIONS_ACC(
                ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY
                , COUNTER, RESOURCE_ID, INVENTORY_LOCATION_ID, ORGANIZATION_ID ) VALUES (
		l_tab_access_id(i), sysdate, 1, sysdate, 1, counters(i), l_tab_resource_id(i), locations(i), organizations(i));

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
  This function will be called from
  CSL_CSP_INV_LOC_ASS_ACC_PKG.Pre_Insert_Child(...)
  It gets all the records associated with sub-inventories.
*/
PROCEDURE Insert_Item_Locs_By_Subinv
  ( p_subinventory_code      IN VARCHAR2
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  )
IS
  CURSOR c_item_loc_by_subinv ( b_organization_id   NUMBER,
                                b_subinventory_code VARCHAR2 )
    IS
    SELECT INVENTORY_LOCATION_ID
    FROM MTL_ITEM_LOCATIONS
    WHERE ORGANIZATION_ID = b_organization_id
      AND SUBINVENTORY_CODE = b_subinventory_code
      AND (DISABLE_DATE > sysdate OR DISABLE_DATE IS NULL)
      ;
  r_item_loc_by_subinv c_item_loc_by_subinv%ROWTYPE;
BEGIN
  FOR r_item_loc_by_subinv IN c_item_loc_by_subinv (p_organization_id, p_subinventory_code)
  LOOP
    Insert_Item_Location(
        r_item_loc_by_subinv.inventory_location_id,
        p_organization_id,
        p_resource_id);
  END LOOP;
END Insert_Item_Locs_By_Subinv;

/*
  This function will be called from
  CSL_CSP_INV_LOC_ASS_ACC_PKG.Post_Delete_Child(...)
  It deletes all the records associated with sub-inventories.
*/
PROCEDURE Delete_Item_Locs_By_Subinv
  ( p_subinventory_code      IN VARCHAR2
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  )
IS
  CURSOR c_item_loc_by_subinv ( b_organization_id   NUMBER,
                                b_subinventory_code VARCHAR2,
                                b_resource_id       NUMBER )
    IS
    SELECT B.INVENTORY_LOCATION_ID
    FROM MTL_ITEM_LOCATIONS B, CSL_MTL_ITEM_LOCATIONS_ACC A
    WHERE B.ORGANIZATION_ID = b_organization_id
      AND B.SUBINVENTORY_CODE = b_subinventory_code
      AND A.RESOURCE_ID = b_resource_id
      AND B.ORGANIZATION_ID = A.ORGANIZATION_ID
      AND B.INVENTORY_LOCATION_ID = A.INVENTORY_LOCATION_ID
      ;
  r_item_loc_by_subinv c_item_loc_by_subinv%ROWTYPE;
BEGIN
  FOR r_item_loc_by_subinv IN c_item_loc_by_subinv (p_organization_id, p_subinventory_code, p_resource_id)
  LOOP
    Delete_Item_Location(
        r_item_loc_by_subinv.inventory_location_id,
        p_organization_id,
        p_resource_id);
  END LOOP;
END Delete_Item_Locs_By_Subinv;

/*
  This function will be called from
  CSL_MTL_SEC_LOCATORS_ACC_PKG.Insert_Secondary_Locators(...)
  and Insert_Item_Locs_By_Subinv.
  It gets all records for MTL_SEC_LOCATORS records.
*/
PROCEDURE Insert_Item_Location
  ( p_inventory_location_id  IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  )
IS
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_location_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_Item_Location'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Inserting ACC record :' || p_inventory_location_id || ' for resource id '
                         || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Call common package to insert record into ACC table ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( p_publication_item_names => g_publication_item_name
   ,p_acc_table_name         => g_acc_table_name
   ,p_resource_id            => p_resource_id
   ,p_pk1_name               => g_pk1_name
   ,p_pk1_char_value         => p_inventory_location_id
   ,p_pk2_name               => g_pk2_name
   ,p_pk2_num_value          => p_organization_id
  );

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_location_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Insert_Item_Location'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Insert_Item_Location;

PROCEDURE Update_Item_Location
  ( p_inventory_location_id  IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  )
IS
  l_access_id NUMBER := NULL;
  CURSOR c_item_location_acc (
  b_inventory_location_id  NUMBER
  , b_organization_id      NUMBER
  , b_resource_id          NUMBER )
  IS
    SELECT ACCESS_ID
    FROM CSL_MTL_ITEM_LOCATIONS_ACC
    WHERE INVENTORY_LOCATION_ID = b_inventory_location_id
      AND ORGANIZATION_ID = b_organization_id
      AND RESOURCE_ID = b_resource_id;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_location_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Update_Item_Location'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Deleting ACC record :' || p_inventory_location_id || ' for resource id '
                         || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_item_location_acc(
            p_inventory_location_id,
            p_organization_id,
            p_resource_id);
  FETCH c_item_location_acc INTO l_access_id;
  CLOSE c_item_location_acc;

  IF l_access_id IS NOT NULL THEN
  /*** Call common package to delete record from ACC table ***/
    JTM_HOOK_UTIL_PKG.Update_Acc
    ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_resource_id            => p_resource_id
       ,p_access_id              => l_access_id
    );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_location_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Update_Item_Location'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_Item_Location;

PROCEDURE Delete_Item_Location
  ( p_inventory_location_id  IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  )
IS
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_location_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Delete_Item_Location'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Deleting ACC record :' || p_inventory_location_id || ' for resource id '
                         || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Call common package to delete record from ACC table ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
  ( p_publication_item_names => g_publication_item_name
   ,p_acc_table_name         => g_acc_table_name
   ,p_resource_id            => p_resource_id
   ,p_pk1_name               => g_pk1_name
   ,p_pk1_char_value         => p_inventory_location_id
   ,p_pk2_name               => g_pk2_name
   ,p_pk2_num_value          => p_organization_id
  );

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_inventory_location_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Delete_Item_Location'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_Item_Location;

/*
  Iterate over all the acc records for subinventories for given mobile user.
  populate the CSL_MTL_ITEM_LOCATIONS_ACC records for all mobile users.
*/
PROCEDURE POPULATE_ITEM_LOCATIONS_ACC
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR c_inserted
  IS SELECT CSL_ACC_SEQUENCE.NEXTVAL, A.RESOURCE_ID, L.INVENTORY_LOCATION_ID, L.ORGANIZATION_ID, A.COUNTER
     FROM MTL_ITEM_LOCATIONS L, JTM_MTL_SEC_INV_ACC A
     WHERE L.SUBINVENTORY_CODE = A.SECONDARY_INVENTORY_NAME
       AND L.ORGANIZATION_ID = A.ORGANIZATION_ID;

  l_tab_access_id   ASG_DOWNLOAD.ACCESS_LIST;
  l_tab_resource_id ASG_DOWNLOAD.USER_LIST;
  TYPE location_Tab  IS TABLE OF MTL_SECONDARY_LOCATORS.SECONDARY_LOCATOR%TYPE INDEX BY BINARY_INTEGER;
  TYPE org_Tab   IS TABLE OF MTL_SECONDARY_LOCATORS.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE counter_Tab   IS TABLE OF JTM_MTL_SYSTEM_ITEMS_ACC.COUNTER%TYPE INDEX BY BINARY_INTEGER;
  locations      location_Tab;
  organizations  org_Tab;
  counters       counter_Tab;

  l_dummy BOOLEAN;

BEGIN
  DELETE FROM CSL_MTL_ITEM_LOCATIONS_ACC;

 OPEN c_inserted;
 FETCH c_inserted BULK COLLECT
 INTO l_tab_access_id, l_tab_resource_id, locations, organizations, counters;
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
     INSERT INTO CSL_MTL_ITEM_LOCATIONS_ACC(
                ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY
                , COUNTER, RESOURCE_ID, INVENTORY_LOCATION_ID, ORGANIZATION_ID ) VALUES (
		l_tab_access_id(i), sysdate, 1, sysdate, 1,
                counters(i), l_tab_resource_id(i), locations(i), organizations(i));

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
END POPULATE_ITEM_LOCATIONS_ACC;

PROCEDURE CON_REQUEST_ITEM_LOCATIONS
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  /*** get the last run date of the concurent program ***/
  CURSOR  c_LastRundate
  IS
    select LAST_RUN_DATE
    from   JTM_CON_REQUEST_DATA
    where  package_name =  'CSL_MTL_ITEM_LOCATIONS_ACC_PKG'
    AND    procedure_name = 'CON_REQUEST_MTL_ITEM_LOCATIONS';
  r_LastRundate  c_LastRundate%ROWTYPE;
  l_current_run_date DATE;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( 0
    , g_table_name
    , 'Entering CON_REQUEST_MTL_ITEM_LOCATIONS'
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
  WHERE package_name =  'CSL_MTL_ITEM_LOCATIONS_ACC_PKG'
  AND   procedure_name = 'CON_REQUEST_ITEM_LOCATIONS';

  COMMIT;

 IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
   jtm_message_log_pkg.Log_Msg
   ( 0
   , g_table_name
   , 'Leaving CON_REQUEST_ITEM_LOCATIONS'
   , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
   );
 END IF;

EXCEPTION
 WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
      ( 0
      , g_table_name
      , 'CON_REQUEST_ITEM_LOCATIONS'||fnd_global.local_chr(10)||
        'Error: '||sqlerrm
      , JTM_HOOK_UTIL_PKG.g_debug_level_error);
  END IF;
  ROLLBACK;
END CON_REQUEST_ITEM_LOCATIONS;

END CSL_MTL_ITEM_LOCATIONS_ACC_PKG;

/
