--------------------------------------------------------
--  DDL for Package Body CSL_MTL_TRANS_LOT_NUM_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_TRANS_LOT_NUM_ACC_PKG" AS
/* $Header: cslltacb.pls 115.11 2002/11/08 14:02:28 asiegers ship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_MTL_TRANS_LOT_NUM_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
 JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_TRANS_LOT_NUMBERS');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_TRANSACTIONS_LOT_NUMBERS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TRANSACTION_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'LOT_NUMBER';
g_old_resource_id       NUMBER; -- variable containing old resource_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level

PROCEDURE Insert_MTL_trans_lot_num(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER
	                     )
IS

CURSOR c_transaction_lot_number(
                                  b_transaction_id NUMBER,
                                  b_inventory_item_id NUMBER,
                                  b_organization_id NUMBER
		  ) IS
       SELECT TRANSACTION_ID, LOT_NUMBER
       FROM MTL_TRANSACTION_LOT_NUMBERS
       WHERE TRANSACTION_ID = b_transaction_id
       AND INVENTORY_ITEM_ID = b_inventory_item_id
       AND ORGANIZATION_ID = b_organization_id;

r_transaction_lot_number c_transaction_lot_number%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_MTL_trans_lot_num'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_transaction_lot_number( p_transaction_id, p_inventory_item_id, p_organization_id);
  FETCH c_transaction_lot_number INTO r_transaction_lot_number;
  IF c_transaction_lot_number%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
      , v_object_name => g_table_name
      , v_message     => 'Insert_MTL_trans_lot_num could not find lot number transactions for transaction :' || p_transaction_id ||
                         ' , ' || p_inventory_item_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_transaction_lot_number;
--    RETURN FALSE;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
        , v_object_name => g_table_name
        , v_message     => 'Inserting ACC record :' || p_transaction_id || ' , ' || p_inventory_item_id ||
                           ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_transaction_lot_number%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      JTM_HOOK_UTIL_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_resource_id            => p_resource_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_transaction_lot_number.TRANSACTION_ID
       ,p_pk2_name               => g_pk2_name
       ,p_pk2_char_value         => r_transaction_lot_number.LOT_NUMBER
      );
      FETCH c_transaction_lot_number INTO r_transaction_lot_number;
    END LOOP;
  END IF;

END Insert_MTL_trans_lot_num;


PROCEDURE Update_MTL_trans_lot_num(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER
		      )
IS
CURSOR c_transaction_lot_number(
                                  b_transaction_id NUMBER,
                                  b_inventory_item_id NUMBER,
                                  b_organization_id NUMBER
		  ) IS
       SELECT TRANSACTION_ID, LOT_NUMBER
       FROM MTL_TRANSACTION_LOT_NUMBERS
       WHERE TRANSACTION_ID = b_transaction_id
       AND INVENTORY_ITEM_ID = b_inventory_item_id
       AND ORGANIZATION_ID = b_organization_id;

  r_transaction_lot_number c_transaction_lot_number%ROWTYPE;

  l_acc_id NUMBER;

BEGIN

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Update_MTL_trans_lot_num'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_transaction_lot_number( p_transaction_id, p_inventory_item_id, p_organization_id);
  FETCH c_transaction_lot_number INTO r_transaction_lot_number;
  IF c_transaction_lot_number%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
      , v_object_name => g_table_name
      , v_message     => 'Update_MTL_trans_lot_num could not find lot number transactions for transaction :' || p_transaction_id ||
                         ' , ' || p_inventory_item_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_transaction_lot_number;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
        , v_object_name => g_table_name
        , v_message     => 'Update ACC record :' || p_transaction_id || ' , ' || p_inventory_item_id ||
                           ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_transaction_lot_number%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      l_acc_id := JTM_HOOK_UTIL_PKG.Get_Acc_Id
                 ( P_ACC_TABLE_NAME => g_acc_table_name
                  ,p_pk1_name       => g_pk1_name
                  ,p_pk1_num_value  => r_transaction_lot_number.TRANSACTION_ID
                  ,p_pk2_name       => g_pk2_name
                  ,p_pk2_char_value => r_transaction_lot_number.LOT_NUMBER
                  ,P_RESOURCE_ID    => p_resource_id);


      IF l_acc_id = -1 THEN
      /*** Record is not yet in ACC tables. Insert has to be done ***/
        JTM_HOOK_UTIL_PKG.Insert_Acc
                         ( p_publication_item_names => g_publication_item_name
                         ,p_acc_table_name          => g_acc_table_name
                         ,p_pk1_name                => g_pk1_name
                         ,p_pk1_num_value           => r_transaction_lot_number.TRANSACTION_ID
                         ,p_pk2_name                => g_pk2_name
                         ,p_pk2_char_value          => r_transaction_lot_number.LOT_NUMBER
                         ,p_resource_id             => p_resource_id
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


      FETCH c_transaction_lot_number INTO r_transaction_lot_number;
    END LOOP;
    /*** Succesfull looped through recordset ***/

  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Update_MTL_trans_lot_num'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;


END Update_MTL_trans_lot_num;


PROCEDURE Delete_MTL_trans_lot_num(
                                      p_resource_id         NUMBER,
                                      p_transaction_id      NUMBER,
                                      p_inventory_item_id   NUMBER,
                                      p_organization_id     NUMBER
	                     )
IS

CURSOR c_transaction_lot_number(
                                  b_transaction_id NUMBER,
                                  b_inventory_item_id NUMBER,
                                  b_organization_id NUMBER
		  ) IS
       SELECT TRANSACTION_ID, LOT_NUMBER
       FROM MTL_TRANSACTION_LOT_NUMBERS
       WHERE TRANSACTION_ID = b_transaction_id
       AND INVENTORY_ITEM_ID = b_inventory_item_id
       AND ORGANIZATION_ID = b_organization_id;

r_transaction_lot_number c_transaction_lot_number%ROWTYPE;

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
  OPEN c_transaction_lot_number( p_transaction_id, p_inventory_item_id, p_organization_id);
  FETCH c_transaction_lot_number INTO r_transaction_lot_number;
  IF c_transaction_lot_number%NOTFOUND THEN
    /*** could not find assignment record -> exit ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_transaction_id || ' , ' || p_inventory_item_id
      , v_object_name => g_table_name
      , v_message     => 'Delete_MTL_trans_lot_num could not find lot number transactions for transaction :' || p_transaction_id ||
                         ' , ' || p_inventory_item_id || ' for resource id ' || p_resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    CLOSE c_transaction_lot_number;
--    RETURN FALSE;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_organization_id
        , v_object_name => g_table_name
        , v_message     => 'Deleting ACC record :' || p_transaction_id || ' , ' || p_inventory_item_id ||
                           ' for resource id ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    /*** Loop over all available records and put them in the acc table ***/
    WHILE c_transaction_lot_number%FOUND LOOP
      /*** Call common package to insert record into ACC table ***/
      JTM_HOOK_UTIL_PKG.Delete_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_resource_id            => p_resource_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => r_transaction_lot_number.TRANSACTION_ID
       ,p_pk2_name               => g_pk2_name
       ,p_pk2_char_value         => r_transaction_lot_number.LOT_NUMBER
      );
      FETCH c_transaction_lot_number INTO r_transaction_lot_number;
    END LOOP;
  END IF;

END Delete_MTL_trans_lot_num;

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

  DELETE JTM_MTL_TRANS_LOT_NUM_ACC
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
  fnd_msg_pub.Add_Exc_Msg('CSL_MTL_TRANS_LOT_NUM_ACC_PKG','PROCESS_ACC',sqlerrm);
END DELETE_ALL_ACC_RECORDS;

END CSL_MTL_TRANS_LOT_NUM_ACC_PKG;

/
