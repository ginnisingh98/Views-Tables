--------------------------------------------------------
--  DDL for Package Body CSM_MTL_UNIT_TXN_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_UNIT_TXN_ACC_PKG" AS
/* $Header: csmutacb.pls 120.0.12010000.2 2008/10/20 10:43:51 trajasek ship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_MTL_UNIT_TXN_ACC';
g_publication_item_name CONSTANT CSM_ACC_PKG.t_publication_item_list :=
 CSM_ACC_PKG.t_publication_item_list('CSM_MTL_UNIT_TXNS');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_UNIT_TRANSACTIONS';
g_tasks_seq_name        CONSTANT VARCHAR2(30) := 'CSM_MTL_UNIT_TXN_ACC_S';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TRANSACTION_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'SERIAL_NUMBER';
g_old_user_id           NUMBER; -- variable containing old user_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level
TYPE TRANS_idTab     IS TABLE OF MTL_UNIT_TRANSACTIONS.TRANSACTION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE SERIAL_idTab       IS TABLE OF MTL_UNIT_TRANSACTIONS.SERIAL_NUMBER%TYPE INDEX BY BINARY_INTEGER;
l_transaction_id_lst    TRANS_idTab;
l_serial_lst            SERIAL_idTab;

PROCEDURE Insert_MTL_Unit_Trans(   p_user_id         NUMBER,
                                   p_transaction_id      NUMBER
                              )
IS
CURSOR c_mtl_unit_trans(b_transaction_id      NUMBER)
IS
   SELECT TRANSACTION_ID, SERIAL_NUMBER
   FROM MTL_UNIT_TRANSACTIONS
   WHERE TRANSACTION_ID = b_transaction_id;

BEGIN
  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => p_transaction_id || 'Entering Insert_MTL_Unit_Trans Procedure'
  , log_level    => FND_LOG.LEVEL_STATEMENT);

  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;
  IF l_serial_lst.COUNT >0 THEN
     l_serial_lst.DELETE;
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN  c_mtl_unit_trans( p_transaction_id);
  FETCH c_mtl_unit_trans BULK COLLECT INTO l_transaction_id_lst,l_serial_lst;
  CLOSE c_mtl_unit_trans;

  IF l_transaction_id_lst.COUNT > 0 THEN
    /*** Loop over all available records and put them in the acc table ***/
    FOR i in 1..l_transaction_id_lst.COUNT LOOP
      /*** Call common package to insert record into ACC table ***/
      CSM_ACC_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_seq_name               => g_tasks_seq_name
       ,p_user_id                => p_user_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => l_transaction_id_lst(i)
       ,p_pk2_name               => g_pk2_name
       ,p_pk2_char_value         => l_serial_lst(i)
      );
    END LOOP;
  END IF;
  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;
  IF l_serial_lst.COUNT >0 THEN
     l_serial_lst.DELETE;
  END IF;
  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => 'Leaving Insert_MTL_Unit_Trans Procedure after processing tran id:' || p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

END Insert_MTL_Unit_Trans;


PROCEDURE Update_MTL_Unit_Trans( p_user_id         NUMBER,
                                 p_transaction_id      NUMBER
                              )
IS
BEGIN
/*** Not necassery because it will be an insert or delete updates will not be done from the csp_inv_loc_ass package ***/
  /*** get debug level ***/
  RETURN;
END Update_MTL_Unit_Trans;


PROCEDURE Delete_MTL_Unit_Trans( p_user_id         NUMBER,
                                 p_transaction_id      NUMBER
	                       )
IS
CURSOR c_mtl_unit_trans(b_transaction_id NUMBER, b_user_id NUMBER)
IS
   SELECT TRANSACTION_ID, SERIAL_NUMBER
   FROM   CSM_MTL_UNIT_TXN_ACC
   WHERE  TRANSACTION_ID = b_transaction_id
   AND    USER_ID        = b_user_id;

BEGIN

  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => ' Entering Delete_MTL_trans_lot_num for Tran id : ' || p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;
  IF l_serial_lst.COUNT >0 THEN
     l_serial_lst.DELETE;
  END IF;
  /*** Retreive record assigned by Hook ***/
  OPEN c_mtl_unit_trans( p_transaction_id , p_user_id);
  FETCH c_mtl_unit_trans BULK COLLECT INTO l_transaction_id_lst , l_serial_lst;
  CLOSE c_mtl_unit_trans;

  IF l_transaction_id_lst.COUNT > 0 THEN
    /*** Loop over all available records and put them in the acc table ***/
    FOR i in 1..l_transaction_id_lst.COUNT LOOP
      /*** Call common package to insert record into ACC table ***/
      CSM_ACC_PKG.Delete_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_user_id                => p_user_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => l_transaction_id_lst(i)
       ,p_pk2_name               => g_pk2_name
       ,p_pk2_char_value         => l_serial_lst(i)
      );
    END LOOP;
  END IF;

  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;
  IF l_serial_lst.COUNT >0 THEN
     l_serial_lst.DELETE;
  END IF;
  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => ' Leaving Delete_MTL_trans_lot_num for Tran id : ' || p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

END Delete_MTL_Unit_Trans;

/*Delete all records for non-existing user ( e.g user was deleted )*/
PROCEDURE DELETE_ALL_ACC_RECORDS( p_user_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 )
IS
BEGIN
  CSM_UTIL_PKG.LOG
    ( module => g_table_name
    , message     => 'Entering DELETE_ALL_ACC_RECORDS'
    , log_level    => FND_LOG.LEVEL_STATEMENT);


  DELETE CSM_MTL_UNIT_TXN_ACC
  WHERE  user_id = p_user_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CSM_UTIL_PKG.LOG
    ( module => g_table_name
    , message     => 'Leaving DELETE_ALL_ACC_RECORDS'
    , log_level    => FND_LOG.LEVEL_STATEMENT);

EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => 'Caught exception in DELETE_ALL_ACC_RECORDS hook:' || fnd_global.local_chr(10) || sqlerrm
  , log_level    => FND_LOG.LEVEL_ERROR);
  fnd_msg_pub.Add_Exc_Msg('CSM_MTL_UNIT_TXN_ACC_PKG','PROCESS_ACC',sqlerrm);
END DELETE_ALL_ACC_RECORDS;


END CSM_MTL_UNIT_TXN_ACC_PKG;

/
