--------------------------------------------------------
--  DDL for Package Body CSL_MTL_UNIT_TRANS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_UNIT_TRANS_ACC_PKG" AS
/* $Header: cslutacb.pls 120.0 2005/05/24 18:15:19 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_MTL_UNIT_TRANS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
 JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_UNIT_TRANSACTIONS');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_UNIT_TRANSACTIONS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TRANSACTION_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'SERIAL_NUMBER';
g_old_resource_id       NUMBER; -- variable containing old resource_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level

PROCEDURE Insert_MTL_Unit_Trans(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER,
		        p_subinventory_code   VARCHAR2
	                )
IS

CURSOR c_mtl_unit_trans(b_transaction_id      NUMBER
                       ,b_inventory_item_id   NUMBER
                       ,b_organization_id     NUMBER
                       ,b_subinventory_code   VARCHAR2)
       IS
           SELECT TRANSACTION_ID, SERIAL_NUMBER
           FROM MTL_UNIT_TRANSACTIONS
           WHERE TRANSACTION_ID = b_transaction_id
           AND INVENTORY_ITEM_ID = b_inventory_item_id
           AND ORGANIZATION_ID = b_organization_id
           AND SUBINVENTORY_CODE = b_subinventory_code;

r_mtl_unit_trans c_mtl_unit_trans%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_transaction_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_MTL_Unit_Trans'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_mtl_unit_trans( p_transaction_id, p_inventory_item_id, p_organization_id, p_subinventory_code);
  FETCH c_mtl_unit_trans INTO r_mtl_unit_trans;
  IF c_mtl_unit_trans%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_transaction_id
      , v_object_name => g_table_name
      , v_message     => 'Insert_MTL_Unit_Trans could not find records for transaction :' || p_transaction_id ||
                         ' , ' || p_inventory_item_id || p_organization_id ||
                         ' , ' || p_subinventory_code || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_mtl_unit_trans;
--    RETURN FALSE;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_transaction_id
        , v_object_name => g_table_name
        , v_message     => 'Inserting ACC record :' || p_transaction_id ||
                           ' , ' || p_inventory_item_id || p_organization_id ||
                           ' , ' || p_subinventory_code || ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_mtl_unit_trans%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      JTM_HOOK_UTIL_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_resource_id            => p_resource_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_mtl_unit_trans.TRANSACTION_ID
       ,p_pk2_name               => g_pk2_name
       ,p_pk2_char_value         => r_mtl_unit_trans.SERIAL_NUMBER
      );
      FETCH c_mtl_unit_trans INTO r_mtl_unit_trans;
    END LOOP;
  END IF;

END Insert_MTL_Unit_Trans;


PROCEDURE Update_MTL_Unit_Trans(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER,
		        p_subinventory_code   VARCHAR2
		      )
IS

BEGIN

/*** Not necassery because it will be an insert or delete updates will not be done from the csp_inv_loc_ass package ***/
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

END Update_MTL_Unit_Trans;


PROCEDURE Delete_MTL_Unit_Trans(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER,
		        p_subinventory_code   VARCHAR2
	                     )
IS

CURSOR c_mtl_unit_trans(b_transaction_id      NUMBER
                       ,b_inventory_item_id   NUMBER
                       ,b_organization_id     NUMBER
                       ,b_subinventory_code   VARCHAR2)
       IS
           SELECT TRANSACTION_ID, SERIAL_NUMBER
           FROM MTL_UNIT_TRANSACTIONS
           WHERE TRANSACTION_ID = b_transaction_id
           AND INVENTORY_ITEM_ID = b_inventory_item_id
           AND ORGANIZATION_ID = b_organization_id
           AND SUBINVENTORY_CODE = b_subinventory_code;

r_mtl_unit_trans c_mtl_unit_trans%ROWTYPE;

BEGIN

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Delete_MTL_trans_lot_num'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_mtl_unit_trans( p_transaction_id, p_inventory_item_id, p_organization_id, p_subinventory_code);
  FETCH c_mtl_unit_trans INTO r_mtl_unit_trans;
  IF c_mtl_unit_trans%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
      , v_object_name => g_table_name
      , v_message     => 'Delete_MTL_trans_lot_num could not find transaction records for transaction :' || p_transaction_id ||
                         ' , ' || p_inventory_item_id || p_organization_id ||
                         ' , ' || p_subinventory_code || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_mtl_unit_trans;
--    RETURN FALSE;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_organization_id
        , v_object_name => g_table_name
        , v_message     => 'Deleting ACC record :' || p_transaction_id ||
                           ' , ' || p_inventory_item_id || p_organization_id ||
                           ' , ' || p_subinventory_code || ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_mtl_unit_trans%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      JTM_HOOK_UTIL_PKG.Delete_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_resource_id            => p_resource_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_mtl_unit_trans.TRANSACTION_ID
       ,p_pk2_name               => g_pk2_name
       ,p_pk2_char_value         => r_mtl_unit_trans.SERIAL_NUMBER
      );
      FETCH c_mtl_unit_trans INTO r_mtl_unit_trans;
    END LOOP;
  END IF;

END Delete_MTL_Unit_Trans;

/*Delete all records for non-existing user ( e.g user was deleted )*/
PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 )
IS
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering DELETE_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;

  DELETE JTM_MTL_UNIT_TRANS_ACC
  WHERE  RESOURCE_ID = p_resource_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving DELETE_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    );
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => 1
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in DELETE_ALL_ACC_RECORDS hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_MTL_UNIT_TRANS_ACC_PKG','PROCESS_ACC',sqlerrm);
END DELETE_ALL_ACC_RECORDS;


END CSL_MTL_UNIT_TRANS_ACC_PKG;

/
