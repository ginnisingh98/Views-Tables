--------------------------------------------------------
--  DDL for Package Body CSL_MTL_MAT_TRANS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_MAT_TRANS_ACC_PKG" AS
/* $Header: cslmtacb.pls 120.0 2005/05/24 18:31:07 appldev noship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_MTL_MAT_TRANS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
 JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_MAT_TRANSACTIONS');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_MATERIAL_TRANSACTIONS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TRANSACTION_ID';
g_old_resource_id       NUMBER; -- variable containing old resource_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level

PROCEDURE Insert_MTL_Mat_Transaction(
                                      p_resource_id         NUMBER,
                                      p_subinventory_code  VARCHAR2,
                                      p_organization_id     NUMBER
	                     )
IS

CURSOR c_mtl_mat_transactions (b_subinventory_code VARCHAR2, b_organization_id NUMBER) IS
       SELECT TRANSACTION_ID, INVENTORY_ITEM_ID
       FROM   MTL_MATERIAL_TRANSACTIONS
       WHERE  SUBINVENTORY_CODE = p_SUBINVENTORY_CODE
       AND    ORGANIZATION_ID   = b_organization_id
       AND    TRANSACTION_ACTION_ID = 2 --Subinventory transfer
       AND    SOURCE_CODE = 'CSP';
r_mtl_mat_transactions c_mtl_mat_transactions%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_MTL_Mat_Transaction'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_mtl_mat_transactions( p_subinventory_code, p_organization_id);
  FETCH c_mtl_mat_transactions INTO r_mtl_mat_transactions;
  IF c_mtl_mat_transactions%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Insert_MTL_Mat_Transaction => no transactions for sub inventory :' ||
                         p_subinventory_code ||', organization '||p_organization_id||
                         ' for resource id ' || p_resource_id|| ' found'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_mtl_mat_transactions;
--    RETURN FALSE;
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
    WHILE c_mtl_mat_transactions%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      JTM_HOOK_UTIL_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_resource_id            => p_resource_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_mtl_mat_transactions.TRANSACTION_ID
      );

      /*** Also insert Lot numebers and serial numbers into their respective acc tables ***/
      CSL_MTL_TRANS_LOT_NUM_ACC_PKG.Insert_MTL_trans_lot_num(
                                      p_resource_id         => p_resource_id,
                                      p_transaction_id      => r_mtl_mat_transactions.TRANSACTION_ID,
                                      p_inventory_item_id   => r_mtl_mat_transactions.inventory_item_id,
                                      p_organization_id     => p_organization_id
                                      );
      CSL_MTL_UNIT_TRANS_ACC_PKG.Insert_MTL_Unit_Trans(
                                      p_resource_id         => p_resource_id,
                                      p_transaction_id      => r_mtl_mat_transactions.TRANSACTION_ID,
                                      p_inventory_item_id   => r_mtl_mat_transactions.inventory_item_id,
                                      p_organization_id     => p_organization_id,
		        p_subinventory_code   => p_subinventory_code
                                      );

      FETCH c_mtl_mat_transactions INTO r_mtl_mat_transactions;
    END LOOP;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Insert_MTL_Mat_Transaction'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END Insert_MTL_Mat_Transaction;


PROCEDURE Update_MTL_Mat_Transaction(
                                      p_resource_id         NUMBER,
                                      p_subinventory_code  VARCHAR2,
                                      p_organization_id     NUMBER
		      )
IS

CURSOR c_mtl_mat_transactions (b_subinventory_code VARCHAR2, b_organization_id NUMBER) IS
       SELECT TRANSACTION_ID, INVENTORY_ITEM_ID
       FROM   MTL_MATERIAL_TRANSACTIONS
       WHERE  SUBINVENTORY_CODE = p_SUBINVENTORY_CODE
       AND    ORGANIZATION_ID   = b_organization_id
       AND    TRANSACTION_ACTION_ID = 2 --Subinventory transfer
       AND    SOURCE_CODE = 'CSP';

  r_mtl_mat_transactions c_mtl_mat_transactions%ROWTYPE;

  l_acc_id    NUMBER;

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
  OPEN c_mtl_mat_transactions( p_subinventory_code, p_organization_id);
  FETCH c_mtl_mat_transactions INTO r_mtl_mat_transactions;
  IF c_mtl_mat_transactions%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Update_MTL_Mat_Transaction could not find records for :' || p_subinventory_code || ','
                         || p_organization_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_mtl_mat_transactions;
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
    WHILE c_mtl_mat_transactions%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
                 ( P_ACC_TABLE_NAME => g_acc_table_name
                  ,P_PK1_NAME       => g_pk1_name
                  ,P_PK1_NUM_VALUE  => r_mtl_mat_transactions.TRANSACTION_ID
                  ,P_RESOURCE_ID    => p_resource_id);


      IF l_acc_id = -1 THEN
      /*** Record is not yet in ACC tables. Insert has to be done ***/
      JTM_HOOK_UTIL_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_resource_id            => p_resource_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_mtl_mat_transactions.TRANSACTION_ID
      );
      ELSE
      /*** Record is already in ACC. Only an update is required for re-sending ***/
        JTM_HOOK_UTIL_PKG.Update_Acc
                         ( p_publication_item_names => g_publication_item_name
                         ,p_acc_table_name          => g_acc_table_name
                         ,p_resource_id             => p_resource_id
	          ,p_access_id               => l_acc_id
                         );
      END IF;

      /*** Also Update Lot numebers and serial numbers into their respective acc tables ***/
      CSL_MTL_TRANS_LOT_NUM_ACC_PKG.Update_MTL_trans_lot_num(
                                      p_resource_id         => p_resource_id,
                                      p_transaction_id      => r_mtl_mat_transactions.TRANSACTION_ID,
                                      p_inventory_item_id   => r_mtl_mat_transactions.inventory_item_id,
                                      p_organization_id     => p_organization_id
                                      );
      CSL_MTL_UNIT_TRANS_ACC_PKG.Update_MTL_Unit_Trans(
                                      p_resource_id         => p_resource_id,
                                      p_transaction_id      => r_mtl_mat_transactions.TRANSACTION_ID,
                                      p_inventory_item_id   => r_mtl_mat_transactions.inventory_item_id,
                                      p_organization_id     => p_organization_id,
		        p_subinventory_code   => p_subinventory_code
                                      );
      FETCH c_mtl_mat_transactions INTO r_mtl_mat_transactions;
    END LOOP;
    /*** Succesfull looped through recordset ***/

  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Update_MTL_Mat_Transaction'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;



END Update_MTL_Mat_Transaction;


PROCEDURE Delete_MTL_Mat_Transaction(
                                      p_resource_id         NUMBER,
                                      p_subinventory_code  VARCHAR2,
                                      p_organization_id     NUMBER
		      )
IS

CURSOR c_mtl_mat_transactions (b_subinventory_code VARCHAR2, b_organization_id NUMBER) IS
       SELECT TRANSACTION_ID, INVENTORY_ITEM_ID
       FROM   MTL_MATERIAL_TRANSACTIONS
       WHERE  SUBINVENTORY_CODE = p_SUBINVENTORY_CODE
       AND    ORGANIZATION_ID   = b_organization_id
       AND    TRANSACTION_ACTION_ID = 2 --Subinventory transfer
       AND    SOURCE_CODE = 'CSP';

r_mtl_mat_transactions c_mtl_mat_transactions%ROWTYPE;

BEGIN

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Delete_MTL_Mat_Transaction'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_mtl_mat_transactions( p_subinventory_code, p_organization_id);
  FETCH c_mtl_mat_transactions INTO r_mtl_mat_transactions;
  IF c_mtl_mat_transactions%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_subinventory_code || ' , ' || p_organization_id
      , v_object_name => g_table_name
      , v_message     => 'Delete_MTL_Mat_Transaction could not find records for :' || p_subinventory_code ||
                         ' , ' || p_organization_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_mtl_mat_transactions;
--    RETURN FALSE;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_organization_id
        , v_object_name => g_table_name
        , v_message     => 'Inserting ACC record :' || p_subinventory_code || ' , ' || p_organization_id ||
                           ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_mtl_mat_transactions%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      JTM_HOOK_UTIL_PKG.Delete_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_resource_id            => p_resource_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_mtl_mat_transactions.TRANSACTION_ID
      );

      /*** Also insert Lot numebers and serial numbers into their respective acc tables ***/
      CSL_MTL_TRANS_LOT_NUM_ACC_PKG.Delete_MTL_trans_lot_num(
                                      p_resource_id         => p_resource_id,
                                      p_transaction_id      => r_mtl_mat_transactions.TRANSACTION_ID,
                                      p_inventory_item_id   => r_mtl_mat_transactions.inventory_item_id,
                                      p_organization_id     => p_organization_id
                                      );
      CSL_MTL_UNIT_TRANS_ACC_PKG.Delete_MTL_Unit_Trans(
                                      p_resource_id         => p_resource_id,
                                      p_transaction_id      => r_mtl_mat_transactions.TRANSACTION_ID,
                                      p_inventory_item_id   => r_mtl_mat_transactions.inventory_item_id,
                                      p_organization_id     => p_organization_id,
		                      p_subinventory_code   => p_subinventory_code
                                      );

      FETCH c_mtl_mat_transactions INTO r_mtl_mat_transactions;
    END LOOP;
  END IF;

END Delete_MTL_Mat_Transaction;


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

  DELETE JTM_MTL_MAT_TRANS_ACC
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
  fnd_msg_pub.Add_Exc_Msg('CSL_MTL_MAT_TRANS_ACC_PKG','PROCESS_ACC',sqlerrm);
END DELETE_ALL_ACC_RECORDS;


END CSL_MTL_MAT_TRANS_ACC_PKG;

/
