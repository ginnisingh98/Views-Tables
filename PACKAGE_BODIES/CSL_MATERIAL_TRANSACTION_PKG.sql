--------------------------------------------------------
--  DDL for Package Body CSL_MATERIAL_TRANSACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MATERIAL_TRANSACTION_PKG" AS
/* $Header: cslvmmtb.pls 115.17 2002/11/08 14:00:33 asiegers ship $ */

error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_MATERIAL_TRANSACTION_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'MTL_MAT_TRANSACTIONS';
g_debug_level           NUMBER; -- debug level

CURSOR c_material_transaction( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSL_MTL_MAT_TRANSACTIONS_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

CURSOR c_lot_number( b_user_name VARCHAR2, b_tranid NUMBER, b_transaction_id NUMBER) is
  SELECT *
  FROM  CSL_MTL_TRANS_LOT_NUM_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name
  AND   transaction_id = b_transaction_id;

CURSOR c_unit_transaction( b_user_name VARCHAR2, b_tranid NUMBER, b_transaction_id NUMBER) is
  SELECT *
  FROM  CSL_MTL_UNIT_TRANS_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name
  AND   transaction_id = b_transaction_id;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_material_transaction%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
IS

  l_lot_number           c_lot_number%ROWTYPE;
  l_serial_number        c_unit_transaction%ROWTYPE;
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(240);
  l_mat_txn_transfer_id  NUMBER;
  l_transaction_id       NUMBER := NULL;

  /*** Object needed for pushing data with new pk to client ***/
  CURSOR c_transactions( b_transaction_set_id NUMBER ) IS
    SELECT TRANSACTION_ID
    ,      INVENTORY_ITEM_ID
    ,      ORGANIZATION_ID
    ,      SUBINVENTORY_CODE
    FROM MTL_MATERIAL_TRANSACTIONS
    WHERE TRANSACTION_SET_ID = b_transaction_set_id;

  CURSOR c_resource( b_client_name VARCHAR2 ) IS
    SELECT RESOURCE_ID
    FROM   ASG_USER
    WHERE  USER_NAME = b_client_name;
  r_resource c_resource%ROWTYPE;

  l_pub_item_name_mat CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
                               JTM_HOOK_UTIL_PKG.t_publication_item_list('MTL_MAT_TRANSACTIONS');
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Initialization
  l_transaction_id := p_record.transaction_id;

  OPEN c_lot_number( p_record.clid$$cs, p_record.tranid$$, p_record.transaction_id );
  FETCH c_lot_number INTO l_lot_number;
  IF c_lot_number%NOTFOUND THEN
    l_lot_number := NULL;
  END IF;
  CLOSE c_lot_number;

  OPEN c_unit_transaction( p_record.clid$$cs, p_record.tranid$$, p_record.transaction_id );
  FETCH c_unit_transaction INTO l_serial_number;
  IF c_unit_transaction%NOTFOUND THEN
    l_serial_number := NULL;
  END IF;
  CLOSE c_unit_transaction;

  -- In the application the qty is inverted during insert to reflect the
  -- same behaviour as when the record comes from apps. This inversion
  -- should be undone in the wrapper hence transaction_quantity * -1
  -- ( GG 05-FEB-2002 )
  csp_transactions_pub.transact_material
  ( p_api_version              => 1.0
  , p_init_msg_list            => FND_API.G_TRUE
  , p_commit                   => FND_API.G_FALSE
  , px_transaction_id          => l_transaction_id
  , px_transaction_header_id   => l_mat_txn_transfer_id
  , p_inventory_item_id        => p_record.inventory_item_id
  , p_organization_id          => p_record.organization_id
  , p_subinventory_code        => p_record.subinventory_code
  , p_locator_id               => p_record.locator_id
  , p_lot_number               => l_lot_number.lot_number
  , p_revision                 => p_record.revision
  , p_serial_number            => l_serial_number.serial_number
  , p_quantity                 => -(p_record.transaction_quantity)
  , p_uom                      => p_record.transaction_uom
  , p_source_id                => NULL
  , p_source_line_id           => NULL
  , p_transaction_type_id      => p_record.transaction_type_id
  , p_account_id               => NULL
  , p_transfer_to_subinventory => p_record.transfer_subinventory
  , p_transfer_to_locator      => p_record.transfer_locator_id
  , p_transfer_to_organization => p_record.transfer_organization_id
  , p_transaction_source_id    => NULL
  , p_trx_source_line_id       => NULL
  , p_reason_id                => p_record.reason_id
  , p_transaction_reference    => p_record.transaction_reference
  , x_return_status            => x_return_status
  , x_msg_count                => l_msg_count
  , x_msg_data                 => l_msg_data
  );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  ELSE
    /*** Record was succesfull applied now push records with new PK to client ***/
    /*** Use the transaction_set_id (px_transaction_header_id) because the
         transaction_id is not returned by the INV API ***/
    FOR r_transaction IN c_transactions( l_mat_txn_transfer_id ) LOOP
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Found new transaction_id ' || r_transaction.transaction_id||
	  ', Pushing these to the client'
       , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      /*** Get the resource ***/
      OPEN c_resource( p_record.CLID$$CS );
      FETCH c_resource INTO r_resource;
      IF c_resource%FOUND THEN

        /*** Pushing record ***/
        JTM_HOOK_UTIL_PKG.Insert_Acc
        ( p_publication_item_names => l_pub_item_name_mat
         ,p_acc_table_name         => 'JTM_MTL_MAT_TRANS_ACC'
         ,p_resource_id            => r_resource.resource_id
         ,p_pk1_name               => 'TRANSACTION_ID'
         ,p_pk1_num_value          => r_transaction.TRANSACTION_ID
        );
        /*** Check if the record was serialized or lot controlled ***/
	CSL_MTL_TRANS_LOT_NUM_ACC_PKG.Insert_MTL_trans_lot_num(
                                      p_resource_id         => r_resource.resource_id,
                                      p_transaction_id      => r_transaction.TRANSACTION_ID,
                                      p_inventory_item_id   => r_transaction.inventory_item_id,
                                      p_organization_id     => r_transaction.organization_id
                                      );
        CSL_MTL_UNIT_TRANS_ACC_PKG.Insert_MTL_Unit_Trans(
                                      p_resource_id         => r_resource.resource_id,
                                      p_transaction_id      => r_transaction.TRANSACTION_ID,
                                      p_inventory_item_id   => r_transaction.inventory_item_id,
                                      p_organization_id     => r_transaction.organization_id,
	 	                      p_subinventory_code   => r_transaction.subinventory_code
                                      );
      END IF;
      CLOSE c_resource;

    END LOOP;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_INSERT:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an updated record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_material_transaction%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- There is no update possible so returning SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_UPDATE:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_material_transaction%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
      , v_object_name => g_object_name
      , v_message     => 'Processing TRANSACTION_ID = ' || p_record.TRANSACTION_ID || fnd_global.local_chr(10) ||
       'DMLTYPE = ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSIF p_record.dmltype$$='U' THEN
    -- Process update
    APPLY_UPDATE
      (
       p_record,
       p_error_msg,
       x_return_status
     );
  ELSIF p_record.dmltype$$='D' THEN
    -- Process delete; not supported for this entity
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
        , v_object_name => g_object_name
        , v_message     => 'Delete is not supported for this entity'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
      , v_object_name => g_object_name
      , v_message     => 'Invalid DML type: ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_RECORD:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.TRANSACTION_ID -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication item MTL_MAT_TRANSACTIONS
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** loop through MTL_MAT_TRANSACTIONS records in inqueue ***/
  FOR r_material_transaction IN c_material_transaction( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_material_transaction
      , l_error_msg
      , l_process_status
      );

    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> reject record because of changed pk ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_material_transaction.transaction_id
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, rejecting record because pk is changed'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.REJECT_RECORD
        (
          p_user_name,
          p_tranid,
          r_material_transaction.seqno$$,
          r_material_transaction.transaction_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );

      IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
        /*** Reject successfull now rejecting matching serial/lotnumber records ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_material_transaction.transaction_id
          , v_object_name => g_object_name
          , v_message     => 'Record rejected, now rejecting available matching lot-/serialnumber records'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        FOR r_lot_number IN c_lot_number( p_user_name,
	                                  p_tranid,
	                                  r_material_transaction.transaction_id  ) LOOP
          CSL_SERVICEL_WRAPPER_PKG.REJECT_RECORD
          (
            p_user_name,
            r_lot_number.tranid$$,
            r_lot_number.seqno$$,
            r_lot_number.tranid$$,
            g_object_name,
            'MTL_TRANS_LOT_NUMBERS',
            l_error_msg,
            l_process_status
          );
        END LOOP;

        FOR r_unit_transaction IN c_unit_transaction( p_user_name,
	                                              p_tranid,
						      r_material_transaction.transaction_id ) LOOP
          CSL_SERVICEL_WRAPPER_PKG.REJECT_RECORD
            (
              p_user_name,
              r_unit_transaction.tranid$$,
              r_unit_transaction.seqno$$,
              r_unit_transaction.tranid$$,
              g_object_name,
              'MTL_UNIT_TRANSACTIONS',
              l_error_msg,
              l_process_status
            );
	END LOOP;
      END IF;

    /*** was record processed successfully? ***/
    /*IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN*/
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_material_transaction.TRANSACTION_ID
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_material_transaction.seqno$$,
          r_material_transaction.TRANSACTION_ID,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );

      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_material_transaction.TRANSACTION_ID
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;

      FOR r_lot_number IN c_lot_number( p_user_name, p_tranid, r_material_transaction.transaction_id  ) LOOP
        /* Delete matching contact record(s) */
        CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
          (
            p_user_name,
            p_tranid,
            r_lot_number.seqno$$,
            r_lot_number.tranid$$,
            g_object_name,
            'MTL_TRANS_LOT_NUMBERS',
            l_error_msg,
            l_process_status
          );
          /*** was delete successful? ***/
          IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
              jtm_message_log_pkg.Log_Msg
               ( v_object_id   => r_lot_number.tranid$$
               , v_object_name => g_object_name || 'MTL_TRANS_LOT_NUMBERS'
               , v_message     => 'Deleting from inqueue failed, Defer and reject record'
               , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
            END IF;
            CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
             (
               p_user_name
             , p_tranid
             , r_lot_number.seqno$$
             , r_lot_number.tranid$$
             , g_object_name
             , 'MTL_TRANS_LOT_NUMBERS'
             , l_error_msg
             , l_process_status
            );
         END IF;
      END LOOP;

      FOR r_unit_transaction IN c_unit_transaction( p_user_name,
                                                    p_tranid,
						    r_material_transaction.transaction_id  ) LOOP
        /* Delete matching contact record(s) */
        CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
          (
            p_user_name,
            p_tranid,
            r_unit_transaction.seqno$$,
            r_unit_transaction.tranid$$,
            g_object_name,
            'MTL_UNIT_TRANSACTIONS',
            l_error_msg,
            l_process_status
          );
          /*** was delete successful? ***/
          IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
              jtm_message_log_pkg.Log_Msg
               ( v_object_id   => r_unit_transaction.tranid$$
               , v_object_name => g_object_name || 'MTL_UNIT_TRANSACTIONS'
               , v_message     => 'Deleting from inqueue failed, Defer and reject record'
               , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
            END IF;
            CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
             (
               p_user_name
             , p_tranid
             , r_unit_transaction.seqno$$
             , r_unit_transaction.tranid$$
             , g_object_name
             , 'MTL_UNIT_TRANSACTIONS'
             , l_error_msg
             , l_process_status
            );
         END IF;
      END LOOP;

    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_material_transaction.TRANSACTION_ID
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_material_transaction.seqno$$
       , r_material_transaction.TRANSACTION_ID
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_material_transaction.TRANSACTION_ID
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;

      FOR r_lot_number IN c_lot_number( p_user_name, p_tranid, r_material_transaction.transaction_id  ) LOOP
        /* Defering matching contact record(s) */
        CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
         (
            p_user_name
          , p_tranid
          , r_lot_number.seqno$$
          , r_lot_number.tranid$$
          , g_object_name
          , 'MTL_TRANS_LOT_NUMBERS'
          , l_error_msg
          , l_process_status
         );
      END LOOP;

      FOR r_unit_transaction IN c_unit_transaction( p_user_name,
                                                    p_tranid,
						    r_material_transaction.transaction_id  ) LOOP
        /* Defering matching contact record(s) */
        CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
         (
            p_user_name
          , p_tranid
          , r_unit_transaction.seqno$$
          , r_unit_transaction.tranid$$
          , g_object_name
          , 'MTL_UNIT_TRANSACTIONS'
          , l_error_msg
          , l_process_status
         );
      END LOOP;
    END IF;
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_CLIENT_CHANGES:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSL_MATERIAL_TRANSACTION_PKG;

/
