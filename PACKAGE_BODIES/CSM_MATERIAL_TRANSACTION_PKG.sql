--------------------------------------------------------
--  DDL for Package Body CSM_MATERIAL_TRANSACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MATERIAL_TRANSACTION_PKG" AS
/* $Header: csmvmmtb.pls 120.0 2006/02/16 04:23:47 utekumal noship $ */

error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_MATERIAL_TRANSACTION_PKG';
g_mat_pub_name CONSTANT VARCHAR2(30) := 'CSM_MTL_MATERIAL_TXNS';
g_lot_pub_name CONSTANT VARCHAR2(30) := 'CSM_MTL_TXNS_LOT_NUM';
g_unit_pub_name CONSTANT VARCHAR2(30) := 'CSM_MTL_UNIT_TXNS';

CURSOR c_material_transaction( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSM_MTL_MATERIAL_TXNS_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

CURSOR c_lot_number( b_user_name VARCHAR2, b_tranid NUMBER, b_transaction_id NUMBER) is
  SELECT *
  FROM  CSM_MTL_TXNS_LOT_NUM_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name
  AND   transaction_id = b_transaction_id;

CURSOR c_unit_transaction( b_user_name VARCHAR2, b_tranid NUMBER, b_transaction_id NUMBER) is
  SELECT *
  FROM  CSM_MTL_UNIT_TXNS_INQ
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
    CSM_UTIL_PKG.LOG
    ( module => g_object_name
    , message     => p_record.TRANSACTION_ID || ' Entering ' || g_object_name || '.APPLY_INSERT'
    , log_level    => FND_LOG.LEVEL_STATEMENT);

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
    CSM_UTIL_PKG.LOG
    ( module => g_object_name
    , message     => 'transaction_id ' || l_transaction_id || ' errored out with msg: ' || l_msg_data
    , log_level    => FND_LOG.LEVEL_PROCEDURE);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => p_record.TRANSACTION_ID || ' Leaving ' || g_object_name || '.APPLY_INSERT'
  , log_level    => FND_LOG.LEVEL_STATEMENT);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => p_record.TRANSACTION_ID || ' Exception occurred in APPLY_INSERT:' || fnd_global.local_chr(10) || sqlerrm
  , log_level    => FND_LOG.LEVEL_ERROR);

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

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
  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => p_record.TRANSACTION_ID || ' Entering ' || g_object_name || '.APPLY_UPDATE'
  , log_level    => FND_LOG.LEVEL_STATEMENT);

  -- There is no update possible so returning SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => p_record.TRANSACTION_ID || ' Leaving ' || g_object_name || '.APPLY_UPDATE'
  , log_level    => FND_LOG.LEVEL_STATEMENT);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => p_record.TRANSACTION_ID || ' Exception occurred in APPLY_UPDATE:' || fnd_global.local_chr(10) || sqlerrm
  , log_level    => FND_LOG.LEVEL_ERROR);

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

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

  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => 'Entering ' || g_object_name || '.APPLY_RECORD and processing TRANSACTION_ID = ' || p_record.TRANSACTION_ID || fnd_global.local_chr(10) ||
     'DMLTYPE = ' || p_record.dmltype$$
  , log_level    => FND_LOG.LEVEL_STATEMENT);

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSE
    -- Updates/Deletes are not supported for this entity
    CSM_UTIL_PKG.LOG
      ( module => g_object_name
      , message     => p_record.TRANSACTION_ID || ' Updates and Deletes is not supported for this entity'
      , log_level    => FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => p_record.TRANSACTION_ID || ' Leaving ' || g_object_name || '.APPLY_RECORD'
  , log_level    => FND_LOG.LEVEL_STATEMENT);

EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => p_record.TRANSACTION_ID || ' Exception occurred in APPLY_RECORD:' || fnd_global.local_chr(10) || sqlerrm
  , log_level    => FND_LOG.LEVEL_ERROR);

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSM_UTIL_PKG when publication item MTL_MAT_TRANSACTIONS
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
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => ' Entering ' || g_object_name || '.Apply_Client_Changes for user: ' ||
     p_user_name || ' and tran id: ' || p_tranid
  , log_level    => FND_LOG.LEVEL_STATEMENT);

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
      CSM_UTIL_PKG.LOG
      ( module => g_object_name
      , message     => r_material_transaction.TRANSACTION_ID || ' Record successfully processed, rejecting record because pk is changed'
      , log_level    => FND_LOG.LEVEL_PROCEDURE);

      CSM_UTIL_PKG.REJECT_RECORD
        (
          p_user_name,
          p_tranid,
          r_material_transaction.seqno$$,
          r_material_transaction.transaction_id,
          g_object_name,
          g_mat_pub_name,
          l_error_msg,
          l_process_status
        );

      IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
        /*** Reject successfull now rejecting matching serial/lotnumber records ***/
        CSM_UTIL_PKG.LOG
        ( module => g_object_name
        , message     => r_material_transaction.TRANSACTION_ID || ' Record rejected, now rejecting available matching lot-/serialnumber records'
        , log_level    => FND_LOG.LEVEL_PROCEDURE);

        FOR r_lot_number IN c_lot_number( p_user_name,
	                                  p_tranid,
	                                  r_material_transaction.transaction_id  ) LOOP
          CSM_UTIL_PKG.REJECT_RECORD
          (
            p_user_name,
            r_lot_number.tranid$$,
            r_lot_number.seqno$$,
            r_lot_number.TRANSACTION_ID,
            g_object_name,
            g_lot_pub_name,
            l_error_msg,
            l_process_status
          );
        END LOOP;

        FOR r_unit_transaction IN c_unit_transaction( p_user_name,
	                                              p_tranid,
						      r_material_transaction.transaction_id ) LOOP
          CSM_UTIL_PKG.REJECT_RECORD
            (
              p_user_name,
              r_unit_transaction.tranid$$,
              r_unit_transaction.seqno$$,
              r_unit_transaction.TRANSACTION_ID,
              g_object_name,
              g_unit_pub_name,
              l_error_msg,
              l_process_status
            );
	END LOOP;
      END IF;

    /*** was record processed successfully? ***/
    /*IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN*/
      /*** Yes -> delete record from inqueue ***/
      CSM_UTIL_PKG.LOG
      ( module => g_object_name
      , message     => r_material_transaction.TRANSACTION_ID || ' Record successfully processed, deleting from inqueue'
      , log_level    => FND_LOG.LEVEL_PROCEDURE);

      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_material_transaction.seqno$$,
          r_material_transaction.TRANSACTION_ID,
          g_object_name,
          g_mat_pub_name,
          l_error_msg,
          l_process_status
        );

      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( module => g_object_name
        , message     => r_material_transaction.TRANSACTION_ID || ' Deleting from inqueue failed, rolling back to savepoint'
        , log_level    => FND_LOG.LEVEL_PROCEDURE);

        ROLLBACK TO save_rec;
      END IF;

      FOR r_lot_number IN c_lot_number( p_user_name, p_tranid, r_material_transaction.transaction_id  ) LOOP
        /* Delete matching contact record(s) */
        CSM_UTIL_PKG.DELETE_RECORD
          (
            p_user_name,
            p_tranid,
            r_lot_number.seqno$$,
            r_lot_number.TRANSACTION_ID,
            g_object_name,
            g_lot_pub_name,
            l_error_msg,
            l_process_status
          );
          /*** was delete successful? ***/
          IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
            CSM_UTIL_PKG.LOG
             ( module => g_object_name
             , message     => r_lot_number.tranid$$ || ' Deleting from inqueue failed, Defer and reject record'
             , log_level    => FND_LOG.LEVEL_PROCEDURE);

	    CSM_UTIL_PKG.DEFER_RECORD
             (
               p_user_name
             , p_tranid
             , r_lot_number.seqno$$
             , r_lot_number.TRANSACTION_ID
             , g_object_name
             , g_lot_pub_name
             , l_error_msg
             , l_process_status
	     , r_lot_number.dmltype$$
            );
         END IF;
      END LOOP;

      FOR r_unit_transaction IN c_unit_transaction( p_user_name,
                                                    p_tranid,
						    r_material_transaction.transaction_id  ) LOOP
        /* Delete matching contact record(s) */
        CSM_UTIL_PKG.DELETE_RECORD
          (
            p_user_name,
            p_tranid,
            r_unit_transaction.seqno$$,
            r_unit_transaction.TRANSACTION_ID,
            g_object_name,
            g_unit_pub_name,
            l_error_msg,
            l_process_status
          );
          /*** was delete successful? ***/
          IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
            CSM_UTIL_PKG.LOG
             ( module => g_object_name || 'MTL_UNIT_TRANSACTIONS'
             , message     => r_unit_transaction.TRANSACTION_ID || ' Deleting from inqueue failed, Defer and reject record'
             , log_level    => FND_LOG.LEVEL_PROCEDURE);

            CSM_UTIL_PKG.DEFER_RECORD
             (
               p_user_name
             , p_tranid
             , r_unit_transaction.seqno$$
             , r_unit_transaction.TRANSACTION_ID
             , g_object_name
             , g_unit_pub_name
             , l_error_msg
             , l_process_status
	     , r_unit_transaction.dmltype$$
            );
         END IF;
      END LOOP;

    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      CSM_UTIL_PKG.LOG
      ( module => g_object_name
      , message     => r_material_transaction.TRANSACTION_ID || ' Record not processed successfully, deferring and rejecting record'
      , log_level    => FND_LOG.LEVEL_PROCEDURE);

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_material_transaction.seqno$$
       , r_material_transaction.TRANSACTION_ID
       , g_object_name
       , g_mat_pub_name
       , l_error_msg
       , l_process_status
       , r_material_transaction.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( module => g_object_name
        , message     => r_material_transaction.TRANSACTION_ID || ' Defer record failed, rolling back to savepoint'
        , log_level    => FND_LOG.LEVEL_PROCEDURE);

        ROLLBACK TO save_rec;
      END IF;

      FOR r_lot_number IN c_lot_number( p_user_name, p_tranid, r_material_transaction.transaction_id  ) LOOP
        /* Defering matching contact record(s) */
        CSM_UTIL_PKG.DEFER_RECORD
         (
            p_user_name
          , p_tranid
          , r_lot_number.seqno$$
          , r_lot_number.TRANSACTION_ID
          , g_object_name
          , g_lot_pub_name
          , l_error_msg
          , l_process_status
          , r_lot_number.dmltype$$
         );
      END LOOP;

      FOR r_unit_transaction IN c_unit_transaction( p_user_name,
                                                    p_tranid,
						    r_material_transaction.transaction_id  ) LOOP
        /* Defering matching contact record(s) */
        CSM_UTIL_PKG.DEFER_RECORD
         (
            p_user_name
          , p_tranid
          , r_unit_transaction.seqno$$
          , r_unit_transaction.TRANSACTION_ID
          , g_object_name
          , g_unit_pub_name
          , l_error_msg
          , l_process_status
          , r_unit_transaction.dmltype$$
         );
      END LOOP;
    END IF;
  END LOOP;

  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => 'Leaving ' || g_object_name || '.Apply_Client_Changes'
  , log_level    => FND_LOG.LEVEL_STATEMENT);

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( module => g_object_name
  , message     => 'Exception occurred in APPLY_CLIENT_CHANGES:' || fnd_global.local_chr(10) || sqlerrm
  , log_level    => FND_LOG.LEVEL_ERROR);

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSM_MATERIAL_TRANSACTION_PKG;

/
