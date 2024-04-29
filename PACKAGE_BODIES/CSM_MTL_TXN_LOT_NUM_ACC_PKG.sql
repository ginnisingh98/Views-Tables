--------------------------------------------------------
--  DDL for Package Body CSM_MTL_TXN_LOT_NUM_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_TXN_LOT_NUM_ACC_PKG" AS
/* $Header: csmltacb.pls 120.0.12010000.2 2008/10/20 10:40:59 trajasek ship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_MTL_TXN_LOT_NUM_ACC';
g_publication_item_name CONSTANT CSM_ACC_PKG.t_publication_item_list :=
 CSM_ACC_PKG.t_publication_item_list('CSM_MTL_TXNS_LOT_NUM');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_TRANSACTIONS_LOT_NUMBERS';
g_tasks_seq_name        CONSTANT VARCHAR2(30) := 'CSM_MTL_TXN_LOT_NUM_ACC_S';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TRANSACTION_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'LOT_NUMBER';
g_old_user_id           NUMBER; -- variable containing old user_id; populated in Pre_Update hook
g_debug_level           NUMBER; -- debug level
TYPE TRANS_idTab     IS TABLE OF MTL_TRANSACTION_LOT_NUMBERS.TRANSACTION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE LOT_idTab       IS TABLE OF MTL_TRANSACTION_LOT_NUMBERS.LOT_NUMBER%TYPE INDEX BY BINARY_INTEGER;
l_transaction_id_lst    TRANS_idTab;
l_lot_number_lst        LOT_idTab;

PROCEDURE Insert_MTL_trans_lot_num
    (   p_user_id         NUMBER,
        p_transaction_id      NUMBER  )
IS

CURSOR c_transaction_lot_number( b_transaction_id NUMBER )
IS
   SELECT TRANSACTION_ID, LOT_NUMBER
   FROM   MTL_TRANSACTION_LOT_NUMBERS
   WHERE  TRANSACTION_ID = b_transaction_id;

BEGIN
    CSM_UTIL_PKG.LOG
    ( module => g_table_name
    , message     => 'Entering Insert_MTL_trans_lot_num Procedure for TRAN ID :' || p_transaction_id
    , log_level    => FND_LOG.LEVEL_STATEMENT);

  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;

  IF l_lot_number_lst.COUNT >0 THEN
     l_lot_number_lst.DELETE;
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN  c_transaction_lot_number( p_transaction_id);
  FETCH c_transaction_lot_number BULK COLLECT INTO l_transaction_id_lst,l_lot_number_lst;
  CLOSE c_transaction_lot_number;

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
       ,p_pk2_char_value         => l_lot_number_lst(i)
      );
      END LOOP;
  END IF;

  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;
  IF l_lot_number_lst.COUNT >0 THEN
     l_lot_number_lst.DELETE;
  END IF;
      CSM_UTIL_PKG.LOG
    ( module => g_table_name
    , message     => 'Leaving Insert_MTL_trans_lot_num Procedure for TRAN ID :' || p_transaction_id
    , log_level    => FND_LOG.LEVEL_STATEMENT);
END Insert_MTL_trans_lot_num;


PROCEDURE Update_MTL_trans_lot_num( p_user_id         NUMBER,
                                    p_transaction_id      NUMBER)
IS
CURSOR c_transaction_lot_number(b_transaction_id NUMBER)
IS
 SELECT TRANSACTION_ID, LOT_NUMBER
 FROM MTL_TRANSACTION_LOT_NUMBERS
 WHERE TRANSACTION_ID = b_transaction_id;

l_acc_id NUMBER;

BEGIN

  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => ' Entering Update_MTL_trans_lot_num Procedure  forTRAN ID :' || p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

  IF l_transaction_id_lst.COUNT >0 THEN
   l_transaction_id_lst.DELETE;
  END IF;
  IF l_lot_number_lst.COUNT >0 THEN
   l_lot_number_lst.DELETE;
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN c_transaction_lot_number( p_transaction_id);
  FETCH c_transaction_lot_number BULK COLLECT INTO l_transaction_id_lst,l_lot_number_lst ;
  CLOSE c_transaction_lot_number;

    /*** Loop over all available records and put them in the acc table ***/
      /*** Call common package to insert record into ACC table ***/
    FOR i in 1..l_transaction_id_lst.COUNT LOOP
      l_acc_id := CSM_ACC_PKG.Get_Acc_Id
                 ( P_ACC_TABLE_NAME => g_acc_table_name
                  ,p_pk1_name       => g_pk1_name
                  ,p_pk1_num_value  => l_transaction_id_lst(i)
                  ,p_pk2_name       => g_pk2_name
                  ,p_pk2_char_value => l_lot_number_lst(i)
                  ,p_user_id    => p_user_id);

      IF l_acc_id = -1 THEN
      /*** Record is not yet in ACC tables. Insert has to be done ***/
        CSM_ACC_PKG.Insert_Acc
                         ( p_publication_item_names => g_publication_item_name
                         ,p_acc_table_name          => g_acc_table_name
                         ,p_seq_name               => g_tasks_seq_name
                         ,p_pk1_name                => g_pk1_name
                         ,p_pk1_num_value           => l_transaction_id_lst(i)
                         ,p_pk2_name                => g_pk2_name
                         ,p_pk2_char_value          => l_lot_number_lst(i)
                         ,p_user_id             => p_user_id
                         );
      ELSE
      /*** Record is already in ACC. Only an update is required for re-sending ***/
        CSM_ACC_PKG.Update_Acc
                         ( p_publication_item_names => g_publication_item_name
                         ,p_acc_table_name          => g_acc_table_name
                         ,p_user_id                 => p_user_id
	                 ,p_access_id               => l_acc_id
                         );
      END IF;
    END LOOP;
    /*** Succesfull looped through recordset ***/
  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;
  IF l_lot_number_lst.COUNT >0 THEN
     l_lot_number_lst.DELETE;
  END IF;

  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => ' Leaving Update_MTL_trans_lot_num Procedure for TRAN ID :' || p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

END Update_MTL_trans_lot_num;


PROCEDURE Delete_MTL_trans_lot_num(   p_user_id         NUMBER,
                                      p_transaction_id  NUMBER )
IS
CURSOR c_transaction_lot_number( b_transaction_id NUMBER, b_user_id NUMBER)
IS
   SELECT TRANSACTION_ID, LOT_NUMBER
   FROM   CSM_MTL_TXN_LOT_NUM_ACC
   WHERE  TRANSACTION_ID = b_transaction_id
   AND    USER_ID        = b_user_id;

r_transaction_lot_number c_transaction_lot_number%ROWTYPE;

BEGIN

    CSM_UTIL_PKG.LOG
    ( module => g_table_name
    , message     => ' Entering Delete_MTL_trans_lot_num Procedure for TRAN ID :' || p_transaction_id
    , log_level    => FND_LOG.LEVEL_STATEMENT);

  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;
  IF l_lot_number_lst.COUNT >0 THEN
     l_lot_number_lst.DELETE;
  END IF;

  /*** Retreive record assigned by Hook ***/
  OPEN  c_transaction_lot_number( p_transaction_id, p_user_id);
  FETCH c_transaction_lot_number BULK COLLECT INTO l_transaction_id_lst,l_lot_number_lst;
  CLOSE c_transaction_lot_number;
    /*** could not find assignment record -> exit ***/
    IF l_transaction_id_lst.COUNT > 0 THEN
      /*** Loop over all available records and put them in the acc table ***/
      FOR i in 1..l_transaction_id_lst.COUNT LOOP
      /*** Call common package to insert record into ACC table ***/
        CSM_ACC_PKG.Delete_Acc
        ( p_publication_item_names => g_publication_item_name
        ,p_acc_table_name         => g_acc_table_name
        ,p_user_id            => p_user_id
        ,p_pk1_name               => g_pk1_name
        ,p_pk1_num_value          => l_transaction_id_lst(i)
        ,p_pk2_name               => g_pk2_name
        ,p_pk2_char_value         => l_lot_number_lst(i)
        );
      END LOOP;
    END IF;

  IF l_transaction_id_lst.COUNT >0 THEN
     l_transaction_id_lst.DELETE;
  END IF;
  IF l_lot_number_lst.COUNT >0 THEN
     l_lot_number_lst.DELETE;
  END IF;
    CSM_UTIL_PKG.LOG
    ( module => g_table_name
    , message     => ' Leaving Delete_MTL_trans_lot_num Procedure for TRAN ID :' || p_transaction_id
    , log_level    => FND_LOG.LEVEL_STATEMENT);

END Delete_MTL_trans_lot_num;

/*Delete all records for non-existing user ( e.g user was deleted )*/
PROCEDURE DELETE_ALL_ACC_RECORDS( p_user_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 )
IS
BEGIN
  CSM_UTIL_PKG.LOG
    ( module => g_table_name
    , message     => 'Entering DELETE_ALL_ACC_RECORDS'
    , log_level    => FND_LOG.LEVEL_STATEMENT);

  DELETE CSM_MTL_TXN_LOT_NUM_ACC
  WHERE  USER_ID = p_user_id;

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
  fnd_msg_pub.Add_Exc_Msg('CSM_MTL_TXN_LOT_NUM_ACC_PKG','PROCESS_ACC',sqlerrm);
END DELETE_ALL_ACC_RECORDS;

END CSM_MTL_TXN_LOT_NUM_ACC_PKG;

/
