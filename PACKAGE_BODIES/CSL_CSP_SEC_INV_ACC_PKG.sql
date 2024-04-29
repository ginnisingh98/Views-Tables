--------------------------------------------------------
--  DDL for Package Body CSL_CSP_SEC_INV_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CSP_SEC_INV_ACC_PKG" AS
/* $Header: cslciacb.pls 120.0 2005/05/24 17:43:20 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_CSP_SEC_INV_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
 JTM_HOOK_UTIL_PKG.t_publication_item_list('CSP_SEC_INVENTORIES');
g_table_name            CONSTANT VARCHAR2(30) := 'CSP_SEC_INVENTORIES';
g_pk1_name              CONSTANT VARCHAR2(30) := 'SECONDARY_INVENTORY_ID';
g_old_resource_id       NUMBER; -- variable containing old resource_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level

FUNCTION Insert_CSP_Sec_Inventory
         (
           p_resource_id        IN  NUMBER,
           p_subinventory_code  IN  VARCHAR2,
           p_organization_id    IN  NUMBER
         )
RETURN BOOLEAN
IS

CURSOR c_csp_sec_inventories( b_subinventory_code VARCHAR2
                            , b_organization_id NUMBER
                            ) IS
       SELECT csi.secondary_inventory_id
       FROM csp_sec_inventories         csi
       WHERE (csi.SECONDARY_INVENTORY_NAME = b_subinventory_code
       AND csi.ORGANIZATION_ID = b_organization_id)
       OR ( CONDITION_TYPE = 'B'
       -- Bug 3724123
       AND csi.ORGANIZATION_ID = JTM_HOOK_UTIL_PKG.Get_Profile_Value('CS_INV_VALIDATION_ORG',0));

  r_csp_sec_inventories c_csp_sec_inventories%ROWTYPE;

  l_return_value BOOLEAN := FALSE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_CSP_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_csp_sec_inventories( p_subinventory_code, p_organization_id);
  FETCH c_csp_sec_inventories INTO r_csp_sec_inventories;
  IF c_csp_sec_inventories%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Insert_CSP_Sec_Inventory could not find :' || p_subinventory_code ||
                         ' , ' || p_organization_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);

      RETURN l_return_value;
    END IF;

    CLOSE c_csp_sec_inventories;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
        , v_object_name => g_table_name
        , v_message     => 'Inserting ACC record :' || p_subinventory_code || ' , ' || p_organization_id ||
                           ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_csp_sec_inventories%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      JTM_HOOK_UTIL_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_csp_sec_inventories.SECONDARY_INVENTORY_ID
       ,p_resource_id            => p_resource_id
      );
      CSL_MTL_SEC_INV_ACC_PKG.Insert_MTL_Sec_Inventory(p_resource_id, p_subinventory_code, p_organization_id);
      CSL_MTL_ITEM_LOCATIONS_ACC_PKG.Insert_Item_Locs_By_Subinv
      ( p_subinventory_code  => p_subinventory_code
      , p_organization_id    => p_organization_id
      , p_resource_id        => p_resource_id
      );

      FETCH c_csp_sec_inventories INTO r_csp_sec_inventories;
    END LOOP;
    l_return_value := TRUE;
  END IF;

  RETURN l_return_value;

END Insert_CSP_Sec_Inventory;

PROCEDURE Update_CSP_Sec_Inventory
         (
           p_resource_id        IN  NUMBER,
           p_subinventory_code  IN  VARCHAR2,
           p_organization_id    IN  NUMBER
         )
IS
CURSOR c_csp_sec_inventories( b_subinventory_code VARCHAR2
                            , b_organization_id NUMBER
                            ) IS
       SELECT csi.secondary_inventory_id
       FROM csp_sec_inventories         csi
       WHERE (csi.SECONDARY_INVENTORY_NAME = b_subinventory_code
       AND csi.ORGANIZATION_ID = b_organization_id)
       OR ( CONDITION_TYPE = 'B'
       -- Bug 3724123
       AND csi.ORGANIZATION_ID = JTM_HOOK_UTIL_PKG.Get_Profile_Value('CS_INV_VALIDATION_ORG',0));

  r_csp_sec_inventories c_csp_sec_inventories%ROWTYPE;

  l_acc_id   NUMBER;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Update_CSP_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_csp_sec_inventories( p_subinventory_code, p_organization_id);
  FETCH c_csp_sec_inventories INTO r_csp_sec_inventories;
  IF c_csp_sec_inventories%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Update_CSP_Sec_Inventory could not find :' || p_subinventory_code || ' , '
                         || p_organization_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    CLOSE c_csp_sec_inventories;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
        , v_object_name => g_table_name
        , v_message     => 'Update ACC record :' || p_subinventory_code || ' , ' || p_organization_id
                           || ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_csp_sec_inventories%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
                 ( P_ACC_TABLE_NAME => g_acc_table_name
                  ,P_PK1_NAME       => g_pk1_name
                  ,P_PK1_NUM_VALUE  => r_csp_sec_inventories.SECONDARY_INVENTORY_ID
                  ,P_RESOURCE_ID    => p_resource_id);


      IF l_acc_id = -1 THEN
      /*** Record is not yet in ACC tables. Insert has to be done ***/
        JTM_HOOK_UTIL_PKG.Insert_Acc
                         ( p_publication_item_names => g_publication_item_name
                         ,p_acc_table_name         => g_acc_table_name
                         ,p_pk1_name               => g_pk1_name
                         ,p_pk1_num_value          => r_csp_sec_inventories.SECONDARY_INVENTORY_ID
                         ,p_resource_id            => p_resource_id
                         );

        CSL_MTL_SEC_INV_ACC_PKG.Insert_MTL_Sec_Inventory(p_resource_id, p_subinventory_code, p_organization_id);
        CSL_MTL_ITEM_LOCATIONS_ACC_PKG.Insert_Item_Locs_By_Subinv
        ( p_subinventory_code  => p_subinventory_code
        , p_organization_id    => p_organization_id
        , p_resource_id        => p_resource_id
        );

      ELSE
      /*** Record is already in ACC. Only an update is required for re-sending ***/
        JTM_HOOK_UTIL_PKG.Update_Acc
                         ( p_publication_item_names => g_publication_item_name
                         ,p_acc_table_name          => g_acc_table_name
                         ,p_resource_id             => p_resource_id
	          ,p_access_id               => l_acc_id
                         );

        CSL_MTL_SEC_INV_ACC_PKG.Update_MTL_Sec_Inventory(p_resource_id, p_subinventory_code, p_organization_id);
      END IF;


      FETCH c_csp_sec_inventories INTO r_csp_sec_inventories;
    END LOOP;
    /*** Succesfull looped through recordset ***/

  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Update_CSP_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;


END Update_CSP_Sec_Inventory;

FUNCTION Delete_CSP_Sec_Inventory
         (
           p_resource_id        IN  NUMBER,
           p_subinventory_code  IN  VARCHAR2,
           p_organization_id    IN  NUMBER
         )
RETURN BOOLEAN
IS

CURSOR c_csp_sec_inventories( b_subinventory_code VARCHAR2
                            , b_organization_id NUMBER
                            ) IS
       SELECT csi.secondary_inventory_id
       FROM csp_sec_inventories         csi
       WHERE (csi.SECONDARY_INVENTORY_NAME = b_subinventory_code
       AND csi.ORGANIZATION_ID = b_organization_id)
       OR ( CONDITION_TYPE = 'B'
       -- Bug 3724123
       AND csi.ORGANIZATION_ID = JTM_HOOK_UTIL_PKG.Get_Profile_Value('CS_INV_VALIDATION_ORG',0));

  r_csp_sec_inventories c_csp_sec_inventories%ROWTYPE;

  l_return_value BOOLEAN := FALSE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Delete_CSP_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_csp_sec_inventories( p_subinventory_code, p_organization_id);
  FETCH c_csp_sec_inventories INTO r_csp_sec_inventories;
  IF c_csp_sec_inventories%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Delete_CSP_Sec_Inventory could not find :' || p_subinventory_code || ' , '
                         || p_organization_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    CLOSE c_csp_sec_inventories;
    RETURN l_return_value;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
        , v_object_name => g_table_name
        , v_message     => 'Deleting ACC record :' || p_subinventory_code || ' , ' || p_organization_id
                           || ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_csp_sec_inventories%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      JTM_HOOK_UTIL_PKG.Delete_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_csp_sec_inventories.SECONDARY_INVENTORY_ID
       ,p_resource_id            => p_resource_id
      );

      CSL_MTL_SEC_INV_ACC_PKG.Delete_MTL_Sec_Inventory(p_resource_id, p_subinventory_code, p_organization_id);
      CSL_MTL_ITEM_LOCATIONS_ACC_PKG.Delete_Item_Locs_By_Subinv
      ( p_subinventory_code  => p_subinventory_code
      , p_organization_id    => p_organization_id
      , p_resource_id        => p_resource_id
      );


      FETCH c_csp_sec_inventories INTO r_csp_sec_inventories;
    END LOOP;
    /*** Succesfull looped through recordset ***/
    l_return_value := TRUE;
  END IF;

  RETURN l_return_value;

END Delete_CSP_Sec_Inventory;

END CSL_CSP_SEC_INV_ACC_PKG;

/
