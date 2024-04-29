--------------------------------------------------------
--  DDL for Package Body CSM_MTL_MATERIAL_TXN_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_MATERIAL_TXN_ACC_PKG" AS
/* $Header: csmmtacb.pls 120.5.12010000.4 2010/03/11 04:08:23 trajasek ship $ */

/*** Globals ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_MTL_MATERIAL_TXN_ACC';
g_publication_item_name CONSTANT CSM_ACC_PKG.t_publication_item_list :=
 CSM_ACC_PKG.t_publication_item_list('CSM_MTL_MATERIAL_TXNS');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_MATERIAL_TRANSACTIONS';
g_tasks_seq_name        CONSTANT VARCHAR2(30) := 'CSM_MTL_MATERIAL_TXN_ACC_S';
g_pk1_name              CONSTANT VARCHAR2(30) := 'TRANSACTION_ID';

PROCEDURE Insert_MTL_Mat_Transaction(
                                      p_user_id         NUMBER,
                                      p_transaction_id  NUMBER
                                    )
IS

BEGIN
  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     =>  'Entering Insert_MTL_Mat_Transaction Procedure to process TRAN ID : ' || p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

      /*** Call common package to insert record into ACC table ***/
      CSM_ACC_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_seq_name               => g_tasks_seq_name
       ,p_user_id                => p_user_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => p_transaction_id
      );

      /*** Also insert Lot numebers and serial numbers into their respective acc tables ***/
      CSM_MTL_TXN_LOT_NUM_ACC_PKG.Insert_MTL_trans_lot_num(
                                      p_user_id         => p_user_id,
                                      p_transaction_id  => p_transaction_id
                                      );
      CSM_MTL_UNIT_TXN_ACC_PKG.Insert_MTL_Unit_Trans(
                                      p_user_id         => p_user_id,
                                      p_transaction_id  => p_transaction_id
                                      );
  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => ' Leaving Insert_MTL_Mat_Transaction procedure for TRAN ID :' || p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

END Insert_MTL_Mat_Transaction;


PROCEDURE Update_MTL_Mat_Transaction(
                                      p_user_id         NUMBER,
                                      p_transaction_id  NUMBER
                                    )
IS
  l_acc_id    NUMBER;
BEGIN

  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => ' Entering Update_CSP_Sec_Inventory procedure to process TRAN ID :'|| p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

      /*** Call common package to insert record into ACC table ***/
      l_acc_id := CSM_ACC_PKG.Get_Acc_Id
                 ( P_ACC_TABLE_NAME => g_acc_table_name
                  ,P_PK1_NAME       => g_pk1_name
                  ,P_PK1_NUM_VALUE  => p_transaction_id
                  ,p_user_id        => p_user_id);

      IF l_acc_id = -1 THEN
      /*** Record is not yet in ACC tables. Insert has to be done ***/
      CSM_ACC_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_seq_name               => g_tasks_seq_name
       ,p_user_id                => p_user_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => p_transaction_id
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

      /*** Also Update Lot numebers and serial numbers into their respective acc tables ***/
      CSM_MTL_TXN_LOT_NUM_ACC_PKG.Update_MTL_trans_lot_num(
                                      p_user_id         => p_user_id,
                                      p_transaction_id  => p_transaction_id
                                      );
      CSM_MTL_UNIT_TXN_ACC_PKG.Update_MTL_Unit_Trans(
                                      p_user_id         => p_user_id,
                                      p_transaction_id  => p_transaction_id
                                      );
  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     => ' Leaving Update_MTL_Mat_Transaction Procedure for TRAN ID :' || p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

END Update_MTL_Mat_Transaction;


PROCEDURE Delete_MTL_Mat_Transaction(
                                      p_user_id         NUMBER,
                                      p_transaction_id  NUMBER
                                    )
IS
BEGIN

  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     =>' Entering Delete_MTL_Mat_Transaction Procedure for TRAN ID :'|| p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

      /*** Call common package to insert record into ACC table ***/
      CSM_ACC_PKG.Delete_Acc
      ( p_publication_item_names => g_publication_item_name
       ,p_acc_table_name         => g_acc_table_name
       ,p_user_id                => p_user_id
       ,p_pk1_name               => g_pk1_name
       ,p_pk1_num_value          => p_transaction_id
      );

      /*** Also insert Lot numebers and serial numbers into their respective acc tables ***/
      CSM_MTL_TXN_LOT_NUM_ACC_PKG.Delete_MTL_trans_lot_num(
                                      p_user_id         => p_user_id,
                                      p_transaction_id  => p_transaction_id
                                      );
      CSM_MTL_UNIT_TXN_ACC_PKG.Delete_MTL_Unit_Trans(
                                      p_user_id         => p_user_id,
                                      p_transaction_id  => p_transaction_id
                                      );
  CSM_UTIL_PKG.LOG
  ( module => g_table_name
  , message     =>' Leaving Delete_MTL_Mat_Transaction Procedure for TRAN ID :'|| p_transaction_id
  , log_level    => FND_LOG.LEVEL_STATEMENT);

END Delete_MTL_Mat_Transaction;


/*Delete all records for non-existing user ( e.g user was deleted )*/
PROCEDURE DELETE_ALL_ACC_RECORDS( p_user_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 )
IS
BEGIN
  CSM_UTIL_PKG.LOG
    ( module => g_table_name
    , message     => 'Entering DELETE_ALL_ACC_RECORDS'
    , log_level    => FND_LOG.LEVEL_STATEMENT);

  DELETE CSM_MTL_MATERIAL_TXN_ACC
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
  fnd_msg_pub.Add_Exc_Msg('CSM_MTL_MATERIAL_TXN_ACC_PKG','PROCESS_ACC',sqlerrm);
END DELETE_ALL_ACC_RECORDS;


PROCEDURE Refresh_Mat_Txn_Acc(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR l_last_run_date_csr IS
  SELECT NVL(last_run_date, TO_DATE('1','J'))
  FROM jtm_con_request_data
  WHERE package_name = 'CSM_MTL_MATERIAL_TXN_ACC_PKG'
  AND procedure_name = 'REFRESH_MAT_TXN_ACC';

--Delete if either from or to subinv is not assigned to the mobile user any longer
--OR if the transaction is older than CSM: Purge Interval Setting profile value
CURSOR l_mat_delete_csr (c_history_profile NUMBER)
IS
    SELECT ACC.user_id
    ,      ACC.TRANSACTION_ID
    FROM  CSM_MTL_MATERIAL_TXN_ACC ACC,
          MTL_MATERIAL_TRANSACTIONS B
    WHERE B.TRANSACTION_ID = ACC.TRANSACTION_ID
    AND   B.TRANSACTION_ACTION_ID = 2 --Subinventory transfer
    And   (
          B.transaction_date < (sysdate - c_history_profile)
          OR
         NOT EXISTS
         (SELECT 1
          FROM csm_inv_loc_ass_acc cilaa,
               csp_inv_loc_assignments cila
          WHERE cilaa.csp_inv_loc_assignment_id = cila.csp_inv_loc_assignment_id
          AND cilaa.user_id = ACC.user_id
          AND cila.subinventory_code = B.subinventory_code
          AND cila.organization_id = B.organization_id
         UNION ALL
          SELECT 1
          FROM csm_inv_loc_ass_acc cilaa,
               csp_inv_loc_assignments cila
          WHERE cilaa.csp_inv_loc_assignment_id = cila.csp_inv_loc_assignment_id
          AND cilaa.user_id = ACC.user_id
          AND cila.subinventory_code = B.transfer_subinventory
          AND cila.organization_id = B.transfer_organization_id)
    );

-- get the updates to mat trfr
CURSOR l_mat_update_csr (b_last_run_date IN DATE) IS
    SELECT ACC.user_id
    ,      ACC.TRANSACTION_ID
    FROM  CSM_MTL_MATERIAL_TXN_ACC ACC,
          MTL_MATERIAL_TRANSACTIONS B
    WHERE B.TRANSACTION_ID = ACC.TRANSACTION_ID
    AND B.last_update_date > b_last_run_date;

--Insert if either from OR to subinv are assigned to the mobile user
CURSOR l_mat_insert_csr (c_history_profile NUMBER)
IS
    SELECT cilaa.user_id
    ,      B.TRANSACTION_ID
    FROM  MTL_MATERIAL_TRANSACTIONS B,
          csm_inv_loc_ass_acc cilaa,
          csp_inv_loc_assignments cila_from
    WHERE cilaa.csp_inv_loc_assignment_id = cila_from.csp_inv_loc_assignment_id
      AND TRANSACTION_ACTION_ID = 2 --Subinventory transfer
      AND cila_from.subinventory_code = B.subinventory_code
      AND cila_from.organization_id = B.organization_id
      AND NVL(cila_from.locator_id,0) = NVL(B.locator_id,0)
      AND NOT EXISTS (SELECT 1 FROM CSM_MTL_MATERIAL_TXN_ACC ACC
                      WHERE   B.TRANSACTION_ID = ACC.TRANSACTION_ID
                      And     Acc.User_Id      = Cilaa.User_Id)
      AND B.transaction_date > (sysdate - c_history_profile)
    UNION ALL
    SELECT cilaa.user_id
    ,      B.TRANSACTION_ID
    FROM  MTL_MATERIAL_TRANSACTIONS B,
          csm_inv_loc_ass_acc cilaa,
          csp_inv_loc_assignments cila_to
    WHERE cilaa.csp_inv_loc_assignment_id = cila_to.csp_inv_loc_assignment_id
      AND TRANSACTION_ACTION_ID = 2 --Subinventory transfer
      AND cila_to.subinventory_code = B.transfer_subinventory
      AND cila_to.organization_id = B.transfer_organization_id
      And Nvl(Cila_To.Locator_Id,0) = Nvl(B.Transfer_Locator_Id,0)
      AND B.transaction_date > (sysdate - c_history_profile)
      AND NOT EXISTS (SELECT 1 FROM CSM_MTL_MATERIAL_TXN_ACC ACC
                      WHERE B.TRANSACTION_ID = ACC.TRANSACTION_ID
                      AND     ACC.USER_ID    = cilaa.USER_ID);

l_last_run_date jtm_con_request_data.last_run_date%TYPE;

TYPE tran_idTab  IS TABLE OF MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE INDEX BY BINARY_INTEGER;

l_user_id_lst ASG_DOWNLOAD.USER_LIST;
l_tran_id_lst tran_idTab;

l_current_date DATE;
l_sqlerrno VARCHAR2(20);
L_Sqlerrmsg Varchar2(2000);
l_profile_value NUMBER;
l_dummy boolean;

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc ',
                         g_table_name,FND_LOG.LEVEL_PROCEDURE);

  L_Current_Date := Sysdate;
  --This profile is supported only at site level.
  --So it is not required to be called for each user
  l_profile_value := NVL(CSM_PROFILE_PKG.get_task_history_days(NULL),0);
  -- get the last run date
  OPEN l_last_run_date_csr;
  FETCH l_last_run_date_csr INTO l_last_run_date;
  CLOSE l_last_run_date_csr;

  IF l_user_id_lst.COUNT > 0 THEN
    l_user_id_lst.DELETE;
  END IF;
  IF l_tran_id_lst.COUNT > 0 THEN
    l_tran_id_lst.DELETE;
  END IF;

     CSM_UTIL_PKG.LOG('Processing Material Trasaction Delete',
  'CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc',FND_LOG.LEVEL_STATEMENT);

--Processing Deletes
  OPEN l_mat_delete_csr(l_profile_value);
  LOOP
  FETCH l_mat_delete_csr BULK COLLECT INTO l_user_id_lst, l_tran_id_lst LIMIT 500;
  EXIT WHEN l_user_id_lst.COUNT = 0;

     FOR i IN l_user_id_lst.FIRST..l_user_id_lst.LAST LOOP
        Delete_MTL_Mat_Transaction (l_user_id_lst(i), l_tran_id_lst(i));
     END LOOP;
    COMMIT;
    IF l_user_id_lst.COUNT > 0 THEN
      l_user_id_lst.DELETE;
    END IF;
    IF l_tran_id_lst.COUNT > 0 THEN
      l_tran_id_lst.DELETE;
    END IF;

  END LOOP;
  CLOSE l_mat_delete_csr;

  --Processing updates
    IF l_user_id_lst.COUNT > 0 THEN
      l_user_id_lst.DELETE;
    END IF;
    IF l_tran_id_lst.COUNT > 0 THEN
      l_tran_id_lst.DELETE;
    END IF;

  CSM_UTIL_PKG.LOG('Processing Material Trasaction Update',
  'CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc',FND_LOG.LEVEL_STATEMENT);
  OPEN l_mat_update_csr (l_last_run_date);
  LOOP
  FETCH l_mat_update_csr BULK COLLECT INTO l_user_id_lst , l_tran_id_lst LIMIT 500;
  EXIT WHEN l_user_id_lst.COUNT = 0;

      FOR i IN l_user_id_lst.FIRST..l_user_id_lst.LAST LOOP
        Update_MTL_Mat_Transaction (l_user_id_lst(i), l_tran_id_lst(i));
      END LOOP;
    COMMIT;
    IF l_user_id_lst.COUNT > 0 THEN
      l_user_id_lst.DELETE;
    END IF;
    IF l_tran_id_lst.COUNT > 0 THEN
      l_tran_id_lst.DELETE;
    END IF;

  END LOOP;
  CLOSE l_mat_update_csr;


--Process Inserts
    IF l_user_id_lst.COUNT > 0 THEN
      l_user_id_lst.DELETE;
    END IF;
    IF l_tran_id_lst.COUNT > 0 THEN
      l_tran_id_lst.DELETE;
    END IF;

  CSM_UTIL_PKG.LOG('Processing Material Trasaction Insert',
  'CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc',FND_LOG.LEVEL_STATEMENT);

  OPEN l_mat_insert_csr(l_profile_value);
  LOOP
  FETCH l_mat_insert_csr BULK COLLECT INTO l_user_id_lst, l_tran_id_lst LIMIT 500;
  EXIT WHEN l_user_id_lst.COUNT = 0;

      FOR i IN l_user_id_lst.FIRST..l_user_id_lst.LAST LOOP
        Insert_MTL_Mat_Transaction (l_user_id_lst(i), l_tran_id_lst(i));
      END LOOP;
    COMMIT;
    IF l_user_id_lst.COUNT > 0 THEN
      l_user_id_lst.DELETE;
    END IF;
    IF l_tran_id_lst.COUNT > 0 THEN
      l_tran_id_lst.DELETE;
    END IF;

  END LOOP;
  CLOSE l_mat_insert_csr;
  COMMIT;

-- update last_run_date
 UPDATE jtm_con_request_data
 SET last_run_date = l_current_date
 WHERE package_name = 'CSM_MTL_MATERIAL_TXN_ACC_PKG'
 AND procedure_name = 'REFRESH_MAT_TXN_ACC';

 COMMIT;

 p_status := 'FINE';
 p_message :=  'CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc executed successfully';

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc ',
                         'CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN OTHERS THEN
     l_sqlerrno := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.LOG('CSM_MTL_MATERIAL_TXN_ACC_PKG.Refresh_Mat_Txn_Acc ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END Refresh_Mat_Txn_Acc;

--Called when a new user is created
PROCEDURE get_new_user_mat_txn(p_user_id IN NUMBER)
IS

--Insert if either from OR to subinv are assigned to the mobile user
CURSOR l_mat_insert_csr (b_user_id IN NUMBER, b_profile_value NUMBER) IS
    SELECT B.TRANSACTION_ID
    FROM  MTL_MATERIAL_TRANSACTIONS B
    WHERE B.transaction_date > (sysdate - b_profile_value)
    AND   B.TRANSACTION_ACTION_ID = 2 --Subinventory transfer
    AND   EXISTS( SELECT 1
          FROM    csm_inv_loc_ass_acc cilaa1,
                  csp_inv_loc_assignments cila_from
          WHERE cilaa1.csp_inv_loc_assignment_id = cila_from.csp_inv_loc_assignment_id
          AND cila_from.subinventory_code = B.subinventory_code
          AND cila_from.organization_id   = B.organization_id
          AND NVL(cila_from.locator_id,0) = NVL(B.locator_id,0)
          AND cilaa1.user_id              = b_user_id)
    AND NOT EXISTS (SELECT 1 FROM CSM_MTL_MATERIAL_TXN_ACC ACC
                    WHERE B.TRANSACTION_ID = ACC.TRANSACTION_ID
                    AND   ACC.USER_ID      = b_user_id)
    UNION ALL
    SELECT B.TRANSACTION_ID
    FROM  MTL_MATERIAL_TRANSACTIONS B
    WHERE B.transaction_date > (sysdate - b_profile_value)
    AND   B.TRANSACTION_ACTION_ID = 2 --Subinventory transfer
    AND   EXISTS  (SELECT 1
          FROM    csm_inv_loc_ass_acc cilaa2,
                  csp_inv_loc_assignments cila_to
          WHERE cilaa2.csp_inv_loc_assignment_id = cila_to.csp_inv_loc_assignment_id
          AND cila_to.subinventory_code = B.transfer_subinventory
          AND cila_to.organization_id   = B.transfer_organization_id
          AND NVL(cila_to.locator_id,0) = NVL(B.transfer_locator_id,0)
          AND cilaa2.user_id            = b_user_id)
    AND   NOT EXISTS (SELECT 1 FROM CSM_MTL_MATERIAL_TXN_ACC ACC
                    WHERE B.TRANSACTION_ID = ACC.TRANSACTION_ID
                    AND   ACC.USER_ID      = b_user_id);



TYPE Tran_idTab     IS TABLE OF MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE INDEX BY BINARY_INTEGER;

l_tran_id_lst Tran_idTab;

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);
l_profile_value NUMBER;
l_dummy boolean;

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_MTL_MATERIAL_TXN_ACC_PKG.get_new_user_mat_txn ',
                         g_table_name,FND_LOG.LEVEL_PROCEDURE);
  l_profile_value := NVL(CSM_PROFILE_PKG.get_task_history_days(p_user_id),0);

  OPEN l_mat_insert_csr(p_user_id, l_profile_value);
  LOOP
    IF l_tran_id_lst.COUNT > 0 THEN
      l_tran_id_lst.DELETE;
    END IF;
  FETCH l_mat_insert_csr BULK COLLECT INTO l_tran_id_lst LIMIT 1000;
  EXIT WHEN l_tran_id_lst.COUNT = 0;

      FOR i IN l_tran_id_lst.FIRST..l_tran_id_lst.LAST LOOP
        Insert_MTL_Mat_Transaction (p_user_id, l_tran_id_lst(i));
      END LOOP;

  END LOOP;
  CLOSE l_mat_insert_csr;

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_MATERIAL_TXN_ACC_PKG.get_new_user_mat_txn ',
                         'CSM_MTL_MATERIAL_TXN_ACC_PKG.get_new_user_mat_txn',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN OTHERS THEN
     l_sqlerrno := TO_CHAR(SQLCODE);
     l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
     ROLLBACK;
     csm_util_pkg.LOG('CSM_MTL_MATERIAL_TXN_ACC_PKG.get_new_user_mat_txn ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END get_new_user_mat_txn;

END CSM_MTL_MATERIAL_TXN_ACC_PKG;

/
