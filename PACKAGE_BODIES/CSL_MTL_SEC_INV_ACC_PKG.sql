--------------------------------------------------------
--  DDL for Package Body CSL_MTL_SEC_INV_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_SEC_INV_ACC_PKG" AS
/* $Header: cslmiacb.pls 115.7 2002/08/21 08:27:15 rrademak ship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_MTL_SEC_INV_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
 JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_SEC_INVENTORIES');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_SEC_INVENTORIES';
g_pk1_name              CONSTANT VARCHAR2(30) := 'SECONDARY_INVENTORY_NAME';
g_pk2_name              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_debug_level           NUMBER; -- debug level

PROCEDURE Insert_MTL_Sec_Inventory(
                                    p_resource_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER
		    )
IS
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_MTL_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Inserting ACC record :' || p_organization_id || ' for resource id '
                         || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Call common package to insert record into ACC table ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( p_publication_item_names => g_publication_item_name
   ,p_acc_table_name         => g_acc_table_name
   ,p_resource_id            => p_resource_id
   ,p_pk1_name               => g_pk1_name
   ,p_pk1_char_value         => p_subinventory_code
   ,p_pk2_name               => g_pk2_name
   ,p_pk2_num_value          => p_organization_id
  );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Insert_MTL_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END Insert_MTL_Sec_Inventory;


PROCEDURE Update_MTL_Sec_Inventory(
                                    p_resource_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER
		    )
IS
  l_acc_id   NUMBER;
BEGIN

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Update_MTL_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Update ACC record :' ||
                         p_organization_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Call common package to insert record into ACC table ***/
  l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
             ( P_ACC_TABLE_NAME => g_acc_table_name
              ,p_pk1_name       => g_pk1_name
              ,p_pk1_char_value => p_subinventory_code
              ,p_pk2_name       => g_pk2_name
              ,p_pk2_num_value  => p_organization_id
              ,P_RESOURCE_ID    => p_resource_id);


  IF l_acc_id = -1 THEN
  /*** Record is not yet in ACC tables. Insert has to be done ***/
    JTM_HOOK_UTIL_PKG.Insert_Acc
                     ( p_publication_item_names => g_publication_item_name
                     ,p_acc_table_name          => g_acc_table_name
                     ,p_pk1_name                => g_pk1_name
                     ,p_pk1_char_value          => p_subinventory_code
                     ,p_pk2_name                => g_pk2_name
                     ,p_pk2_num_value           => p_organization_id
                     ,p_resource_id             => p_resource_id
                     );
  ELSE
  /*** Record is already in ACC. Only an update is required for re-sending ***/
    JTM_HOOK_UTIL_PKG.Update_Acc
                     ( p_publication_item_names => g_publication_item_name
                     ,p_acc_table_name         => g_acc_table_name
                     ,p_resource_id            => p_resource_id
                     ,p_access_id               => l_acc_id
                     );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Update_MTL_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Update_MTL_Sec_Inventory;


PROCEDURE Delete_MTL_Sec_Inventory(
                                    p_resource_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER
		    )
IS
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Delete_MTL_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Inserting ACC record :' || p_organization_id || ' for resource id '
                         || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Call common package to insert record into ACC table ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
  ( p_publication_item_names => g_publication_item_name
   ,p_acc_table_name         => g_acc_table_name
   ,p_resource_id            => p_resource_id
   ,p_pk1_name               => g_pk1_name
   ,p_pk1_char_value         => p_subinventory_code
   ,p_pk2_name               => g_pk2_name
   ,p_pk2_num_value          => p_organization_id
  );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Delete_MTL_Sec_Inventory'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END Delete_MTL_Sec_Inventory;

END CSL_MTL_SEC_INV_ACC_PKG;

/
