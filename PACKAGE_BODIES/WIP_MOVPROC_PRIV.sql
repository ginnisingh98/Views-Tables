--------------------------------------------------------
--  DDL for Package Body WIP_MOVPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MOVPROC_PRIV" AS
/* $Header: wipmovpb.pls 120.52.12010000.10 2010/04/15 07:18:49 spattem ship $*/

TYPE move_profile_rec_t IS RECORD(
          child_txn_id   NUMBER,
          cmp_txn_id     NUMBER,
          org_id         NUMBER,
          wip_id         NUMBER,
          entity_type    NUMBER,
          fmOp           NUMBER,
          fmStep         NUMBER,
          toOp           NUMBER,
          toStep         NUMBER,
          scrapTxn       NUMBER,      -- Scrap txn?
          easyComplete   NUMBER,      -- Completion txn?
          easyReturn     NUMBER,      -- Return txn?
          jobTxn         NUMBER,      -- Any move txns on a job?
          scheTxn        NUMBER,      -- Any move txns on a schedule?
          rsrcItem       NUMBER,      -- Existence of auto resource per item?
          rsrcLot        NUMBER,      -- Existence of auto resource per lot?
          poReqItem      NUMBER,      -- Existence of po requisition per item?
          poReqLot       NUMBER);     -- Existence of po requisition per lot?

TYPE group_rec_t IS RECORD(
          group_id       NUMBER,
          assy_header_id NUMBER,        -- Assembly header ID
          mtl_header_id  NUMBER,        -- Material header ID (component)
          move_mode      NUMBER,        -- Move processing mode
          bf_mode        NUMBER,        -- Backflush processing mode
          mtl_mode       NUMBER,        -- Material processing mode
          txn_date       DATE,          -- Transactions date
          process_phase  NUMBER,
          process_status NUMBER,
          time_out       NUMBER,        -- Processing time out in seconds
          intf_tbl_name  VARCHAR2(240), -- Interface table name
          user_id        NUMBER,
          login_id       NUMBER,
          request_id     NUMBER,
          application_id NUMBER,
          program_id     NUMBER,
          move_profile   move_profile_rec_t,
          seq_move       NUMBER);       -- Sequencing move or not

-- this record used to store all necessary info need to change in
-- wip_operations for repetitive schedule allocation
TYPE update_rsa_rec_t IS RECORD(scheID      NUMBER,
                                scheQty     NUMBER,
                                loginID     NUMBER,
                                reqID       NUMBER,
                                appID       NUMBER,
                                progID      NUMBER,
                                createdBy   NUMBER,
                                updatedBy   NUMBER,
                                orgID       NUMBER,
                                wipID       NUMBER,
                                fmOp        NUMBER,
                                fmStep      NUMBER,
                                toOp        NUMBER,
                                toStep      NUMBER);
TYPE update_rsa_tbl_t IS TABLE OF update_rsa_rec_t INDEX BY binary_integer;
TVE_NO_MOVE_ALLOC CONSTANT NUMBER := -5; -- Cannot execute move allocation
TVE_OVERCOMPLETION_MISMATCH CONSTANT NUMBER := -6; -- Cannot execute move alloc

-- transaction_source_type_id used to insert into MMTT
TPS_INV_JOB_OR_SCHED CONSTANT NUMBER := 5;

/*****************************************************************************
 * This procedure will be used to backflush assembly pull component for
 * EZ Completion an EZ Return transaction.
 ****************************************************************************/
PROCEDURE backflush_assy_pull(p_gib          IN OUT NOCOPY group_rec_t,
                              p_move_txn_id  IN            NUMBER,
                              p_entity_type  IN            NUMBER) IS

CURSOR c_repAssembly IS
  SELECT mmt.completion_transaction_id cpl_txn_id,
         mmt.transaction_action_id txn_action_id,
         mmt.transaction_source_id txn_src_id,
         mmt.repetitive_line_id rep_line_id,
         mmt.organization_id org_id,
         mmt.transaction_date txn_date,
         ABS(mmt.primary_quantity) primary_qty,
         mmt.reason_id reason_id,
         mmt.transaction_reference reference,
         /* Fixed bug 4628893 */
         mmt.move_transaction_id move_txn_id,
         wmti.transaction_type txn_type
    FROM mtl_material_transactions mmt,
         wip_move_txn_interface wmti
   /* Bug 4891549 - Modified where clause to improve performance. */
   WHERE mmt.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
     AND mmt.transaction_source_id = wmti.wip_entity_id
     AND mmt.organization_id = wmti.organization_id
   /* End fix for bug 4891549 */
     AND mmt.move_transaction_id = wmti.transaction_id
     AND wmti.transaction_id = p_move_txn_id /* Fixed bug 4916939 */
     AND wmti.group_id = p_gib.group_id
     AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
     AND wmti.transaction_date = mmt.transaction_date   /*Bug 5581147 - Added to improve selectivity*/
     AND mmt.transaction_action_id IN (WIP_CONSTANTS.RETASSY_ACTION,
                                       WIP_CONSTANTS.CPLASSY_ACTION);

CURSOR c_discAssembly IS
  SELECT mmt.completion_transaction_id cpl_txn_id,
         mmt.transaction_action_id txn_action_id,
         mmt.transaction_source_id txn_src_id,
         mmt.organization_id org_id,
         mmt.transaction_date txn_date,
         ABS(mmt.primary_quantity) primary_qty,
         wmti.entity_type entity_type,
         mmt.reason_id reason_id,
         mmt.transaction_reference reference,
         /* Fixed bug 4628893 */
         mmt.move_transaction_id move_txn_id,
         wmti.transaction_type txn_type
    FROM mtl_material_transactions mmt,
         wip_move_txn_interface wmti
    /* Bug 4891549 - Modified where clause to improve performance. */
   WHERE mmt.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
     AND mmt.transaction_source_id = wmti.wip_entity_id
     AND mmt.organization_id = wmti.organization_id
   /* End fix for bug 4891549 */
     AND mmt.move_transaction_id = wmti.transaction_id
     AND wmti.transaction_id = p_move_txn_id /* Fixed bug 4916939 */
     AND wmti.group_id = p_gib.group_id
     AND wmti.transaction_date = mmt.transaction_date   /*Bug 5581147 - Added to improve selectivity*/
     AND wmti.entity_type = WIP_CONSTANTS.DISCRETE
     AND mmt.transaction_action_id IN (WIP_CONSTANTS.RETASSY_ACTION,
                                       WIP_CONSTANTS.CPLASSY_ACTION);

CURSOR c_OSFMAssembly IS
  SELECT mmt.completion_transaction_id cpl_txn_id,
         mmt.transaction_action_id txn_action_id,
         mmt.transaction_source_id txn_src_id,
         mmt.organization_id org_id,
         mmt.transaction_date txn_date,
         ABS(mmt.primary_quantity) primary_qty,
         wmti.entity_type entity_type,
         mmt.reason_id reason_id,
         mmt.transaction_reference reference,
         /* Fixed bug 4628893 */
         mmt.move_transaction_id move_txn_id,
         wmti.transaction_type txn_type,
         /* Fixed bug 5014211 */
         wmti.fm_operation_seq_num fm_op,
         wmti.fm_intraoperation_step_type fm_step,
         wmti.to_operation_seq_num to_op,
         wmti.to_intraoperation_step_type to_step
         /* End fix of bug 5014211 */
    FROM mtl_material_transactions mmt,
         wip_move_txn_interface wmti
    /* Bug 4891549 - Modified where clause to improve performance. */
   WHERE mmt.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
     AND mmt.transaction_source_id = wmti.wip_entity_id
     AND mmt.organization_id = wmti.organization_id
   /* End fix for bug 4891549 */
     AND mmt.move_transaction_id = wmti.transaction_id
     AND wmti.transaction_id = p_move_txn_id /* Fixed bug 4916939 */
     AND wmti.group_id = p_gib.group_id
     AND wmti.transaction_date = mmt.transaction_date   /*Bug 5581147 - Added to improve selectivity*/
     AND wmti.entity_type = WIP_CONSTANTS.LOTBASED
     AND mmt.transaction_action_id IN (WIP_CONSTANTS.RETASSY_ACTION,
                                       WIP_CONSTANTS.CPLASSY_ACTION);

l_repAssembly      c_repAssembly%ROWTYPE;
l_discAssembly     c_discAssembly%ROWTYPE;
l_OSFMAssembly     c_OSFMAssembly%ROWTYPE;
l_params           wip_logger.param_tbl_t;
l_returnStatus     VARCHAR2(1);
l_errMsg           VARCHAR(240);
l_msg              VARCHAR(240);
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;
l_bf_required      NUMBER; -- throw away value
l_ls_required      NUMBER;
-- New variable to pass to OSFM new backflush API.
l_error_msg        VARCHAR2(1000);
l_error_count      NUMBER;
BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName  := 'p_group_id';
    l_params(1).paramValue :=  p_gib.group_id;
    l_params(2).paramName  := 'p_mtl_header_id';
    l_params(2).paramValue :=  p_gib.mtl_header_id;
    l_params(3).paramName  := 'p_mtl_mode';
    l_params(3).paramValue :=  p_gib.mtl_mode;
    /* Fixed bug 4916939 */
    l_params(4).paramName  := 'p_move_txn_id';
    l_params(4).paramValue :=  p_move_txn_id;
    l_params(5).paramName  := 'p_entity_type';
    l_params(5).paramValue :=  p_entity_type;

    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.backflush_assy_pull',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;
  IF(p_entity_type = WIP_CONSTANTS.REPETITIVE) THEN
    FOR l_repAssembly IN c_repAssembly LOOP
      wip_bflProc_priv.backflush(
        p_wipEntityID     => l_repAssembly.txn_src_id,
        p_orgID           => l_repAssembly.org_id,
        p_primaryQty      => l_repAssembly.primary_qty,
        p_txnDate         => l_repAssembly.txn_date,
        p_txnHdrID        => p_gib.mtl_header_id,
        -- Fixed bug 5056289. Pass move_id as a batch_id because we want
        -- inventory to fail only components related to a specific move record.
        p_batchID         => p_move_txn_id,
        p_txnType         => l_repAssembly.txn_type,
        p_entityType      => WIP_CONSTANTS.REPETITIVE,
        p_tblName         => WIP_CONSTANTS.MTI_TBL,
        p_lineID          => l_repAssembly.rep_line_id,
        p_cplTxnID        => l_repAssembly.cpl_txn_id,
        -- Fixed bug 5014211. Stamp move_transaction_id for assembly
        -- pull components so that we will have a link if component
        -- records fail inventory validation.
        p_movTxnID        => l_repAssembly.move_txn_id,
        -- End fix of 5014211.
        p_fmMoveProcessor => WIP_CONSTANTS.YES,
        p_mtlTxnMode      => p_gib.mtl_mode,
        p_reasonID        => l_repAssembly.reason_id,
        p_reference       => l_repAssembly.reference,
        -- Set lock_flag to 1 to prevent inventory worker pick up the record.
        -- Need this change because we will commit after each TM call.
        p_lockFlag        => WIP_CONSTANTS.YES,
        x_lotSerRequired  => l_ls_required,
        x_bfRequired      => l_bf_required,
        x_returnStatus    => l_returnStatus);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        raise fnd_api.g_exc_unexpected_error;
      ELSE
        IF(l_ls_required = WIP_CONSTANTS.YES) THEN
          -- If we need to gather more lot/serial, error out because
          -- we cannot gather lot/serial for background transaction.
          fnd_message.set_name('WIP', 'WIP_NO_LOT_SER_COMP_BKGND');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- check return status
    END LOOP; -- repetitive schedule
  ELSIF(p_entity_type = WIP_CONSTANTS.DISCRETE) THEN
    FOR l_discAssembly IN c_discAssembly LOOP
      wip_bflProc_priv.backflush(
        p_wipEntityID     => l_discAssembly.txn_src_id,
        p_orgID           => l_discAssembly.org_id,
        p_primaryQty      => l_discAssembly.primary_qty,
        p_txnDate         => l_discAssembly.txn_date,
        p_txnHdrID        => p_gib.mtl_header_id,
        -- Fixed bug 5056289. Pass move_id as a batch_id because we want
        -- inventory to fail only components related to a specific move record.
        p_batchID         => p_move_txn_id,
        p_txnType         => l_discAssembly.txn_type,
        p_entityType      => l_discAssembly.entity_type,
        p_tblName         => WIP_CONSTANTS.MTI_TBL,
        p_cplTxnID        => l_discAssembly.cpl_txn_id,
        -- Fixed bug 5014211. Stamp move_transaction_id for assembly
        -- pull components so that we will have a link if component
        -- records fail inventory validation.
        p_movTxnID        => l_discAssembly.move_txn_id,
        -- End fix of 5014211.
        p_fmMoveProcessor => WIP_CONSTANTS.YES,
        p_mtlTxnMode      => p_gib.mtl_mode,
        p_reasonID        => l_discAssembly.reason_id,
        p_reference       => l_discAssembly.reference,
        -- Set lock_flag to 1 to prevent inventory worker pick up the record.
        -- Need this change because we will commit after each TM call.
        p_lockFlag        => WIP_CONSTANTS.YES,
        x_lotSerRequired  => l_ls_required,
        x_bfRequired      => l_bf_required,
        x_returnStatus    => l_returnStatus);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        raise fnd_api.g_exc_unexpected_error;
      ELSE
        IF(l_ls_required = WIP_CONSTANTS.YES) THEN
          -- If we need to gather more lot/serial, error out because
          -- we cannot gather lot/serial for background transaction.
          fnd_message.set_name('WIP', 'WIP_NO_LOT_SER_COMP_BKGND');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- check return status
    END LOOP; -- Discrete
  ELSIF(p_entity_type = WIP_CONSTANTS.LOTBASED) THEN
    FOR l_OSFMAssembly IN c_OSFMAssembly LOOP
      wsm_serial_support_grp.backflush_comp(
        p_wipEntityID     => l_OSFMAssembly.txn_src_id,
        p_orgID           => l_OSFMAssembly.org_id,
        p_primaryQty      => l_OSFMAssembly.primary_qty,
        p_txnDate         => l_OSFMAssembly.txn_date,
        p_txnHdrID        => p_gib.mtl_header_id,
        p_txnType         => l_OSFMAssembly.txn_type,
        -- Fixed bug 5014211. Stamp move_transaction_id for assembly
        -- pull components so that we will have a link if component
        -- records fail inventory validation.
        p_fmOp            => l_OSFMAssembly.fm_op,
        p_fmStep          => l_OSFMAssembly.fm_step,
        p_toOp            => l_OSFMAssembly.to_op,
        p_toStep          => l_OSFMAssembly.to_step,
        p_movTxnID        => l_OSFMAssembly.move_txn_id,
        -- End fix of 5014211.
        p_cplTxnID        => l_OSFMAssembly.cpl_txn_id,
        p_mtlTxnMode      => p_gib.mtl_mode,
        p_reasonID        => l_OSFMAssembly.reason_id,
        p_reference       => l_OSFMAssembly.reference,
        p_init_msg_list   => fnd_api.g_true,
        x_lotSerRequired  => l_ls_required,
        x_returnStatus    => l_returnStatus,
        x_error_msg       => l_error_msg,      -- throw away value
        x_error_count     => l_error_count);   -- throw away value

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        raise fnd_api.g_exc_unexpected_error;
      ELSE
        IF(l_ls_required = WIP_CONSTANTS.YES) THEN
          -- If we need to gather more lot/serial, error out because
          -- we cannot gather lot/serial for background transaction.
          fnd_message.set_name('WIP', 'WIP_NO_LOT_SER_COMP_BKGND');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- check return status
    END LOOP; -- OSFM
  END IF; -- entity_type check
  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.backflush_assy_pull',
                         p_procReturnStatus => 'S',
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;
END backflush_assy_pull;


/*****************************************************************************
 * This procedure will delete record from MTI and MTLI if the components fail
 * inventory validation. It will also update a corresponding move record to
 * error status.
 ****************************************************************************/
PROCEDURE component_cleanup(p_mtl_header_id IN NUMBER,
                            p_group_id      IN NUMBER) IS

l_params        wip_logger.param_tbl_t;
l_returnStatus  VARCHAR(1);
l_msg           VARCHAR(240);
l_logLevel      NUMBER := fnd_log.g_current_runtime_level;
BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_mtl_header_id';
    l_params(1).paramValue  :=  p_mtl_header_id;
    l_params(2).paramName   := 'p_group_id';
    l_params(2).paramValue  :=  p_group_id;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.component_cleanup',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;
  -- Update status of move record to error if components fail inventory
  -- validation.
  UPDATE wip_move_txn_interface wmti
     SET wmti.process_status = WIP_CONSTANTS.ERROR
   WHERE wmti.group_id = p_group_id
     AND EXISTS
         (SELECT 1
            FROM mtl_transactions_interface mti
           WHERE mti.transaction_header_id = p_mtl_header_id
             AND mti.move_transaction_id = wmti.transaction_id
             AND mti.error_explanation IS NOT NULL);

  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'WIP_MOVE_TXN_INTERFACE');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  -- Delete error records from MTLI
  DELETE FROM mtl_transaction_lots_interface mtli
   WHERE mtli.transaction_interface_id IN
        (SELECT mti.transaction_interface_id
           FROM mtl_transactions_interface mti
          WHERE mti.transaction_header_id = p_mtl_header_id);

  IF (l_logLevel <= wip_constants.full_logging) THEN
    l_msg := SQL%ROWCOUNT ||
             ' rows deleted from mtl_transaction_lots_interface';
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  -- Delete error records from MTI
  DELETE FROM mtl_transactions_interface
   WHERE transaction_header_id = p_mtl_header_id;

  IF (l_logLevel <= wip_constants.full_logging) THEN
    l_msg := SQL%ROWCOUNT ||
             ' rows deleted from mtl_transactions_interface';
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  l_returnStatus := fnd_api.g_ret_sts_success;
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.component_cleanup',
                         p_procReturnStatus => l_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

END component_cleanup;


/*****************************************************************************
 * This is an autonomous procedure that will move an error message from MTI to
 * WMTI.
 ****************************************************************************/
PROCEDURE write_mtl_error(p_move_id                NUMBER,
                          p_error_msg              VARCHAR2,
                          p_last_update_date       DATE,
                          p_last_updated_by        NUMBER,
                          p_creation_date          DATE,
                          p_created_by             NUMBER,
                          p_last_update_login      NUMBER,
                          p_request_id             NUMBER,
                          p_program_application_id NUMBER,
                          p_program_id             NUMBER,
                          p_program_update_date    DATE) IS

 PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  INSERT INTO wip_txn_interface_errors
   (transaction_id,
    error_column,
    error_message,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date
   )
   VALUES(p_move_id,                  -- transaction_id
          NULL,                       -- error_column
          p_error_msg,                -- error_message
          p_last_update_date,
          p_last_updated_by,
          p_creation_date,
          p_created_by,
          p_last_update_login,
          p_request_id,
          p_program_application_id,
          p_program_id,
          p_program_update_date);

  COMMIT;
END write_mtl_error;

/*****************************************************************************
 * This procedure will be used to record error messages from
 * MTL_TRANSACTIONS_INTERFACE into WIP_TXN_INTERFACE_ERRORS
 ****************************************************************************/
PROCEDURE write_mtl_errors(p_mtl_header_id IN NUMBER) IS

CURSOR c_mtl_errors IS
  SELECT mti.move_transaction_id,
         substrb(msik.concatenated_segments || ':' ||
                  mti.error_explanation,1,240) error_msg,  -- error_message
         mti.last_update_date,
         mti.last_updated_by,
         mti.creation_date,
         mti.created_by,
         mti.last_update_login,
         mti.request_id,
         mti.program_application_id,
         mti.program_id,
         mti.program_update_date
    FROM mtl_transactions_interface mti,
         mtl_system_items_kfv msik
   WHERE mti.transaction_header_id = p_mtl_header_id
     AND mti.inventory_item_id = msik.inventory_item_id
     AND mti.organization_id = msik.organization_id
     AND mti.error_explanation IS NOT NULL;

l_mtl_errors    c_mtl_errors%ROWTYPE;
l_params        wip_logger.param_tbl_t;
l_returnStatus  VARCHAR(1);
l_errMsg        VARCHAR2(240);
l_logLevel      NUMBER := fnd_log.g_current_runtime_level;
l_count         NUMBER;
BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_mtl_header_id';
    l_params(1).paramValue  :=  p_mtl_header_id;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.write_mtl_errors',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;
  l_count := 0;
  FOR l_mtl_errors IN c_mtl_errors LOOP
    l_count := l_count + 1;
    write_mtl_error(
      p_move_id                => l_mtl_errors.move_transaction_id,
      p_error_msg              => l_mtl_errors.error_msg,
      p_last_update_date       => l_mtl_errors.last_update_date,
      p_last_updated_by        => l_mtl_errors.last_updated_by,
      p_creation_date          => l_mtl_errors.creation_date,
      p_created_by             => l_mtl_errors.created_by,
      p_last_update_login      => l_mtl_errors.last_update_login,
      p_request_id             => l_mtl_errors.request_id,
      p_program_application_id => l_mtl_errors.program_application_id,
      p_program_id             => l_mtl_errors.program_id,
      p_program_update_date    => l_mtl_errors.program_update_date);
  END LOOP;
  -- Clear inventory message from the stack because inventory always put
  -- quantity tree error into message stack, but did not error out the
  -- transactions. This will mislead both customer and developer if transaction
  -- fail inventory validation code.
  fnd_msg_pub.initialize;

  IF (l_logLevel <= wip_constants.full_logging) THEN
    wip_logger.log(p_msg          => l_count || ' records inserted',
                   x_returnStatus => l_returnStatus);
  END IF;

  l_returnStatus := fnd_api.g_ret_sts_success;
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.write_mtl_errors',
                         p_procReturnStatus => l_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;
  EXCEPTION
    WHEN others THEN
      l_returnStatus := fnd_api.g_ret_sts_unexp_error;
      l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.write_mtl_errors',
                           p_procReturnStatus => l_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END write_mtl_errors;

/*****************************************************************************
 * This procedure is equivalent to witpslw_lock_wipops in wiltps.ppc
 * This procedure is used to lock a record in WIP_OPERATIONS
 ****************************************************************************/
PROCEDURE lock_wipops(p_gib           IN        group_rec_t,
                      x_returnStatus OUT NOCOPY VARCHAR2) IS

CURSOR c_wipops(p_group_id  NUMBER,
                p_txn_date  DATE) IS
  SELECT wop.wip_entity_id,
         wop.operation_seq_num,
         wop.organization_id,
         wop.repetitive_schedule_id
    FROM wip_operations wop,
         wip_repetitive_schedules wrs,
         wip_move_txn_interface wmti
   WHERE wop.organization_id = wmti.organization_id
     AND wop.wip_entity_id = wmti.wip_entity_id
     AND wmti.group_id = p_group_id
     AND TRUNC(wmti.transaction_date) = TRUNC(p_txn_date)
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND ((wop.operation_seq_num BETWEEN
         wmti.fm_operation_seq_num AND wmti.to_operation_seq_num)
         OR (wop.operation_seq_num BETWEEN
         wmti.to_operation_seq_num AND wmti.fm_operation_seq_num))
     AND wop.organization_id = wrs.organization_id (+)
     AND wop.repetitive_schedule_id = wrs.repetitive_schedule_id(+)
     AND NVL(wrs.status_type,-999) IN (-999, WIP_CONSTANTS.RELEASED,
                                       WIP_CONSTANTS.COMP_CHRG)
     AND (( wmti.line_id = wrs.line_id
           AND wmti.line_id IS NOT NULL
           AND wop.repetitive_schedule_id IS NOT NULL)
           OR (wmti.line_id IS NULL))
     FOR UPDATE OF wop.quantity_completed NOWAIT;

l_wipops       c_wipops%ROWTYPE;
l_returnStatus VARCHAR(1);
l_errMsg       VARCHAR2(240);
l_params       wip_logger.param_tbl_t;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName  := 'p_group_id';
    l_params(1).paramValue :=  p_gib.group_id;
    l_params(2).paramName  := 'p_txn_date';
    l_params(2).paramValue :=  p_gib.txn_date;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.lock_wipops',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  OPEN c_wipops(p_group_id  => p_gib.group_id,
                p_txn_date  => p_gib.txn_date);

  IF(c_wipops%ISOPEN) THEN
    CLOSE c_wipops;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.lock_wipops',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN wip_constants.records_locked THEN
    IF(c_wipops%ISOPEN) THEN
      CLOSE c_wipops;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'Unable to lock the record in wip_operations';

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.lock_wipops',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('INV','INV_WIP_WORK_ORDER_LOCKED');
    fnd_msg_pub.add;

  WHEN others THEN
    IF(c_wipops%ISOPEN) THEN
      CLOSE c_wipops;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.lock_wipops',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END lock_wipops;

/*****************************************************************************
 * This procedure is equivalent to witpssa_sched_alloc in wiltps.ppc
 * This procedure is used to allocate quantity to multiple reptitive schedule
 * it work for both regular and over move transaction
 ****************************************************************************/
PROCEDURE schedule_alloc(p_org_id        IN        NUMBER,
                         p_wip_id        IN        NUMBER,
                         p_line_id       IN        NUMBER,
                         p_quantity      IN        NUMBER,
                         p_fm_op         IN        NUMBER,
                         p_fm_step       IN        NUMBER,
                         p_to_op         IN        NUMBER,
                         p_to_step       IN        NUMBER,
                         p_oc_txn_type   IN        NUMBER,
                         p_txnType       IN        NUMBER,
                         p_fm_form       IN        NUMBER,
                         p_comp_alloc    IN        NUMBER,
                         p_txn_date      IN        DATE, /* bug 5373061 */
                         x_proc_status  OUT NOCOPY NUMBER,
                         x_sche_count   OUT NOCOPY NUMBER,
                         x_rsa          OUT NOCOPY rsa_tbl_t,
                         x_returnStatus OUT NOCOPY VARCHAR2) IS

/* Fix for bug 5373061: Added date_released condition to allocate back-dated
transactions correctly */
CURSOR c_rsa(p_forward NUMBER) IS
  SELECT wrs.repetitive_schedule_id scheID,
         (wo2.quantity_waiting_to_move - NVL(SUM(wmat.primary_quantity),0))
            toMoveQty,
         (wrs.quantity_completed + NVL(SUM(wmat.primary_quantity),0))
            completedQty,
         wo1.operation_seq_num op_seq,
         wo1.quantity_in_queue queue_qty,
         wo1.quantity_running run_qty,
         wo1.quantity_waiting_to_move tomove_qty,
         wo1.quantity_rejected reject_qty,
         wo1.quantity_scrapped scrap_qty
    FROM wip_operations wo1,
         wip_operations wo2,
         wip_repetitive_schedules wrs,
         wip_mtl_allocations_temp wmat
   WHERE wrs.repetitive_schedule_id = wmat.repetitive_schedule_id(+)
     AND wrs.organization_id = wmat.organization_id(+)
     AND wrs.organization_id = wo1.organization_id
     AND wrs.wip_entity_id = wo1.wip_entity_id
     AND wrs.repetitive_schedule_id = wo1.repetitive_schedule_id
     AND wo1.operation_seq_num = p_fm_op
     AND wrs.organization_id = wo2.organization_id
     AND wrs.wip_entity_id = wo2.wip_entity_id
     AND wrs.repetitive_schedule_id = wo2.repetitive_schedule_id
     AND wo2.operation_seq_num = p_to_op
     AND wrs.organization_id = p_org_id
     AND wrs.wip_entity_id = p_wip_id
     AND wrs.line_id = p_line_id
     AND wrs.status_type in (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG)
     AND wrs.date_released < p_txn_date
GROUP BY wrs.repetitive_schedule_id,
         wo2.quantity_waiting_to_move,
         wrs.quantity_completed,
         wo1.operation_seq_num,
         wo1.quantity_in_queue,
         wo1.quantity_running,
         wo1.quantity_waiting_to_move,
         wo1.quantity_rejected,
         wo1.quantity_scrapped,
         wo1.first_unit_start_date,
         wrs.first_unit_start_date
ORDER BY DECODE(p_forward,
           WIP_CONSTANTS.YES,NVL(wo1.first_unit_start_date,
                                 wrs.first_unit_start_date), -- no routing
           NULL) ASC,
         DECODE(p_forward,
           WIP_CONSTANTS.NO, NVL(wo1.first_unit_start_date,
                                 wrs.first_unit_start_date), -- no routing
           NULL) DESC;

l_rsa          c_rsa%ROWTYPE;
l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_errMsg       VARCHAR2(240);
l_forward      NUMBER;
l_cur_qty      NUMBER;
l_scheID       NUMBER;
l_quantity     NUMBER := p_quantity;
l_recordFound  NUMBER := 0;
l_need_more    BOOLEAN := TRUE;
l_dummy        NUMBER := 0;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_org_id';
    l_params(1).paramValue  :=  p_org_id;
    l_params(2).paramName   := 'p_wip_id';
    l_params(2).paramValue  :=  p_wip_id;
    l_params(3).paramName   := 'p_line_id';
    l_params(3).paramValue  :=  p_line_id;
    l_params(4).paramName   := 'p_quantity';
    l_params(4).paramValue  :=  p_quantity;
    l_params(5).paramName   := 'p_fm_op';
    l_params(5).paramValue  :=  p_fm_op;
    l_params(6).paramName   := 'p_fm_step';
    l_params(6).paramValue  :=  p_fm_step;
    l_params(7).paramName   := 'p_to_op';
    l_params(7).paramValue  :=  p_to_op;
    l_params(8).paramName   := 'p_to_step';
    l_params(8).paramValue  :=  p_to_step;
    l_params(9).paramName   := 'p_oc_txn_type';
    l_params(9).paramValue  :=  p_oc_txn_type;
    l_params(10).paramName  := 'p_txnType';
    l_params(10).paramValue :=  p_txnType;
    l_params(11).paramName  := 'p_fm_form';
    l_params(11).paramValue :=  p_fm_form;
    l_params(12).paramName  := 'p_comp_alloc';
    l_params(12).paramValue :=  p_comp_alloc;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.schedule_alloc',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- initialize x_sche_count
  x_sche_count := 0;

  IF(p_fm_op < p_to_op) OR
    (p_fm_op = p_to_op AND p_fm_step <= p_to_step) THEN
    l_forward := WIP_CONSTANTS.YES;
  ELSE
    l_forward := WIP_CONSTANTS.NO;
  END IF;

  OPEN c_rsa(l_forward);
  WHILE l_need_more LOOP
    FETCH c_rsa INTO l_rsa;

    IF(c_rsa%NOTFOUND) THEN
      GOTO no_data;
    ELSE
      l_recordFound := l_recordFound + 1;
      l_scheID      := l_rsa.scheID;

      IF(p_txnType = WIP_CONSTANTS.RET_TXN AND
         p_fm_form = WIP_CONSTANTS.YES) THEN
        l_cur_qty := l_rsa.completedQty;
      ELSE
        IF (p_fm_step = WIP_CONSTANTS.QUEUE) THEN
          l_cur_qty := NVL(l_rsa.queue_qty, 0);
        ELSIF (p_fm_step = WIP_CONSTANTS.RUN) THEN
          l_cur_qty := NVL(l_rsa.run_qty, 0);
        ELSIF (p_fm_step = WIP_CONSTANTS.TOMOVE) THEN
          l_cur_qty := NVL(l_rsa.tomove_qty, 0);
        ELSIF (p_fm_step = WIP_CONSTANTS.REJECT) THEN
          l_cur_qty := NVL(l_rsa.reject_qty, 0);
        ELSIF (p_fm_step = WIP_CONSTANTS.SCRAP) THEN
          l_cur_qty := NVL(l_rsa.scrap_qty, 0);
        END IF;

        IF (p_comp_alloc = WIP_CONSTANTS.YES) THEN
          -- completion allocation from Tomove of the last op. This logic
          -- will be used in completion part of EZ Completion transactions
          l_cur_qty := l_cur_qty + l_rsa.toMoveQty;
        END IF;
      END IF; -- Return transactions from form

      IF (p_oc_txn_type = WIP_CONSTANTS.child_txn) THEN
        NULL;  -- just allocate everything to the last schedule
      ELSE
        IF (l_cur_qty > 0) THEN
          l_quantity := l_quantity - l_cur_qty;
          IF (l_quantity <= 0) THEN
            l_cur_qty := l_cur_qty + l_quantity;
            l_need_more := FALSE;
          END IF;
          -- increase schedule count by 1 IF found record
          x_sche_count := x_sche_count + 1;
          x_rsa(x_sche_count).scheID := l_scheID;
          x_rsa(x_sche_count).scheQty := l_cur_qty;
        END IF; -- l_cur_qty > 0
      END IF; -- child txn
    END IF; -- c_rsa%NOTFOUND
  END LOOP; -- while

  IF(p_oc_txn_type = WIP_CONSTANTS.parent_txn) THEN
    -- IF parent and came here, it means that the whole quantity was
    -- fulfilled without needing overcompletion. In that case it must be
    -- an error
    x_proc_status := TVE_OVERCOMPLETION_MISMATCH;
    l_errMsg := 'Overcompletion mismatch';
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  -- for parent transaction, it always come here because the available
  -- qty is not enough. Child transaction also come here
<<no_data>>

  IF (l_recordFound = 0) THEN -- no schedule found
    l_errMsg := 'No repetitive schedule found';
    raise fnd_api.g_exc_unexpected_error;
  ELSIF((p_oc_txn_type =  WIP_CONSTANTS.parent_txn OR
        (p_txnType = WIP_CONSTANTS.RET_TXN AND
         p_fm_form = WIP_CONSTANTS.YES)) AND
         l_quantity > 0) THEN
    -- parent may have some allocation already made or none
    IF (x_sche_count = 0) THEN -- no allocation made yet
      x_sche_count := 1;
      x_rsa(x_sche_count).scheID  := l_scheID;
      x_rsa(x_sche_count).scheQty := l_quantity;
    ELSE
      IF (x_rsa(x_sche_count).scheID = l_scheID) THEN
        -- there is an allocation made to the last schedule already
        x_rsa(x_sche_count).scheQty :=  x_rsa(x_sche_count).scheQty +
                                        l_quantity;
      ELSE
        -- all allocation were made to schedules other than the last schedule
        x_sche_count := x_sche_count + 1;
        x_rsa(x_sche_count).scheID  := l_scheID;
        x_rsa(x_sche_count).scheQty := l_quantity;
      END IF;
    END IF; -- x_sche_count = 0
  ELSIF(p_oc_txn_type = WIP_CONSTANTS.child_txn) THEN
    -- no allocation should be there yet
    x_sche_count := 1;
    x_rsa(x_sche_count).scheID  := l_scheID;
    x_rsa(x_sche_count).scheQty := l_quantity;

  ELSE -- IF normal txn
    IF(p_fm_form = WIP_CONSTANTS.YES) THEN
      -- skip this validation if call from from because there may be
      -- a case that completed quantity is negative for repetitive
      NULL;
    ELSE
      IF(l_quantity > 0) THEN
        -- user insert incorrect value for normal transaction txn qty must
        -- be less than or equal to available qty
        x_proc_status := TVE_NO_MOVE_ALLOC;
        l_errMsg := 'Not enough qty to move';
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
  END IF; -- no schedule found

  IF(c_rsa%ISOPEN) THEN
    CLOSE c_rsa;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_success;
  x_proc_status  := WIP_CONSTANTS.RUNNING;
  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.schedule_alloc',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF(c_rsa%ISOPEN) THEN
      CLOSE c_rsa;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.schedule_alloc',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

    /* Fix for bug 5373061: Passed missing token */
    fnd_message.set_name('WIP','WIP_INT_ERROR_NO_SCHED');
    fnd_message.set_token('ROUTINE', 'wip_movProc_priv.schedule_alloc');
    fnd_msg_pub.add;

  WHEN others THEN
    IF(c_rsa%ISOPEN) THEN
      CLOSE c_rsa;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    x_proc_status  := WIP_CONSTANTS.ERROR;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.schedule_alloc',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END schedule_alloc;

/*****************************************************************************
 * This procedure is equivalent to witoc_insert_alloc_child in wiltps.ppc
 * This procedure is used to insert child record into WIP_MOVE_TXN_INTERFACE
 * and WIP_MOVE_TXN_ALLOCATIONS
 ****************************************************************************/
PROCEDURE insert_alloc_child(p_org_id        IN        NUMBER,
                             p_scheID        IN        NUMBER,
                             p_oc_pri_qty    IN        NUMBER,
                             p_parent_txn_id IN        NUMBER,
                             p_gib       IN OUT NOCOPY group_rec_t,
                             x_oc_fm_op     OUT NOCOPY NUMBER,
                             x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params           wip_logger.param_tbl_t;
l_returnStatus     VARCHAR(1);
l_errMsg           VARCHAR2(240);
l_msgData          VARCHAR2(240);
l_first_op_code    VARCHAR2(4);
l_first_dept_code  VARCHAR2(10);
l_first_dept_id    NUMBER := 0;
l_first_op_seq_num NUMBER := 0;
l_oc_txn_id        NUMBER := 0;
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_org_id';
    l_params(1).paramValue  :=  p_org_id;
    l_params(2).paramName   := 'p_scheID';
    l_params(2).paramValue  :=  p_scheID;
    l_params(3).paramName   := 'p_oc_pri_qty';
    l_params(3).paramValue  :=  p_oc_pri_qty;
    l_params(4).paramName   := 'p_parent_txn_id';
    l_params(4).paramValue  :=  p_parent_txn_id;
    l_params(5).paramName   := 'child_txn_id';
    l_params(5).paramValue  :=  p_gib.move_profile.child_txn_id;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.insert_alloc_child',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- call PL/SQL api to insert to WMTI
  WIP_OVERCOMPLETION.insert_child_move_txn
      (p_primary_quantity             => p_oc_pri_qty,
       p_parent_txn_id                => p_parent_txn_id,
       -- pass move_profile equal to background so that it will always insert
       -- parent group_id to child group_id
       p_move_profile                 => WIP_CONSTANTS.BACKGROUND,
       p_sched_id                     => p_scheID,
       p_user_id                      => p_gib.user_id,
       p_login_id                     => p_gib.login_id,
       p_req_id                       => p_gib.request_id,
       p_appl_id                      => p_gib.application_id,
       p_prog_id                      => p_gib.program_id,
       p_child_txn_id                 => p_gib.move_profile.child_txn_id,
       p_oc_txn_id                    => l_oc_txn_id,
       p_first_operation_seq_num      => l_first_op_seq_num,
       p_first_operation_code         => l_first_op_code,
       p_first_department_id          => l_first_dept_id,
       p_first_department_code        => l_first_dept_code,
       p_err_mesg                     => l_msgData);

  IF(p_gib.move_profile.child_txn_id IS NULL) THEN
    l_errMsg := 'WIP_OVERCOMPLETION.insert_child_move_txn failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  IF(l_first_op_seq_num IS NOT NULL) THEN
    x_oc_fm_op := l_first_op_seq_num;
  ELSE
    l_errMsg := 'wip_operations_INFO.first_operation failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  IF(p_scheID > 0) THEN
    -- this is a repetitvie schedule, hence must insert allocation records
    -- to wip_move_txn_allocations as well
    INSERT INTO wip_move_txn_allocations
      (transaction_id,
       repetitive_schedule_id,
       organization_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       transaction_quantity,
       primary_quantity)
       (SELECT p_gib.move_profile.child_txn_id,
               repetitive_schedule_id,
               organization_id,
               SYSDATE,               /* last_update_date, */
               last_updated_by,
               SYSDATE,               /* creation_date */
               created_by,
               last_update_login,
               request_id,
               program_application_id,
               program_id,
               SYSDATE,               /* program_update_date */
               p_oc_pri_qty,
               p_oc_pri_qty
          FROM wip_move_txn_allocations wmta
         WHERE wmta.transaction_id = p_parent_txn_id
           AND wmta.organization_id = p_org_id
           AND wmta.repetitive_schedule_id =
       (SELECT MAX(wmta1.repetitive_schedule_id)
          FROM wip_move_txn_allocations wmta1
         WHERE wmta1.transaction_id = wmta.transaction_id
           AND wmta1.organization_id = wmta.organization_id));
  END IF; -- p_scheID > 0
  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_alloc_child',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN

    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_alloc_child',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msgData);
    fnd_msg_pub.add;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_alloc_child',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END insert_alloc_child;

/*****************************************************************************
 * This procedure is equivalent to wip_update_wo_rs  in wiltps.ppc
 * This procedure is used to update WIP_OPERATIONS table for repetitive sche
 ****************************************************************************/
PROCEDURE update_wo_rs(p_scheCount     IN        NUMBER,
                       p_rsa_rec       IN        update_rsa_tbl_t,
                       p_txn_date      IN        DATE,
                       x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params           wip_logger.param_tbl_t;
l_returnStatus     VARCHAR(1);
l_errMsg           VARCHAR2(240);
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;
l_forward_move     NUMBER;
BEGIN
  FOR i IN  1..p_scheCount LOOP
    -- write parameter value to log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName    := 'p_scheID';
      l_params(1).paramValue   :=  p_rsa_rec(i).scheID;
      l_params(2).paramName    := 'p_scheQty';
      l_params(2).paramValue   :=  p_rsa_rec(i).scheQty;
      l_params(3).paramName    := 'p_scheCount';
      l_params(3).paramValue   :=  p_scheCount;
      l_params(4).paramName    := 'p_wip_id';
      l_params(4).paramValue   :=  p_rsa_rec(i).wipID;
      l_params(5).paramName    := 'p_org_id';
      l_params(5).paramValue   :=  p_rsa_rec(i).orgID;
      l_params(6).paramName    := 'p_fm_op';
      l_params(6).paramValue   :=  p_rsa_rec(i).fmOp;
      l_params(7).paramName    := 'p_fm_step';
      l_params(7).paramValue   :=  p_rsa_rec(i).fmStep;
      l_params(8).paramName    := 'p_to_op';
      l_params(8).paramValue   :=  p_rsa_rec(i).toOp;
      l_params(9).paramName    := 'p_to_step';
      l_params(9).paramValue   :=  p_rsa_rec(i).toStep;
      l_params(10).paramName   := 'p_txn_date';
      l_params(10).paramValue  :=  p_txn_date;
      wip_logger.entryPoint(p_procName => 'wip_movProc_priv.update_wo_rs',
                            p_params => l_params,
                            x_returnStatus => l_returnStatus);
    END IF;

  END LOOP;

  FOR i IN  1..p_scheCount LOOP

    UPDATE wip_operations wop
      SET (date_last_moved,
           last_updated_by,
           last_update_date,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           quantity_in_queue,
           quantity_running,
           quantity_waiting_to_move,
           quantity_rejected,
           quantity_scrapped) =

           (SELECT DECODE(wop.operation_seq_num, p_rsa_rec(i).fmOp,
                   p_txn_date,wop.date_last_moved),
                   p_rsa_rec(i).updatedBy,
                   SYSDATE,
                   DECODE(p_rsa_rec(i).loginID, -1, NULL,p_rsa_rec(i).loginID),
                   DECODE(p_rsa_rec(i).reqID, -1, NULL, p_rsa_rec(i).reqID),
                   DECODE(p_rsa_rec(i).appID, -1, NULL, p_rsa_rec(i).appID),
                   DECODE(p_rsa_rec(i).progID, -1, NULL, p_rsa_rec(i).progID),
                   DECODE(p_rsa_rec(i).reqID, -1, NULL, SYSDATE),
                   wop.quantity_in_queue + SUM(
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).fmOp,
                       -1 * DECODE(p_rsa_rec(i).fmStep,
                              1, ROUND(p_rsa_rec(i).scheQty,
                                       WIP_CONSTANTS.INV_MAX_PRECISION),0),0) +
                     DECODE(wop.operation_seq_num,  p_rsa_rec(i).toOp,
                       DECODE(p_rsa_rec(i).toStep,
                         1, ROUND(p_rsa_rec(i).scheQty,
                                  WIP_CONSTANTS.INV_MAX_PRECISION), 0), 0)),
                   wop.quantity_running + SUM(
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).fmOp,
                       -1 * DECODE(p_rsa_rec(i).fmStep,
                              2, ROUND(p_rsa_rec(i).scheQty,
                                       WIP_CONSTANTS.INV_MAX_PRECISION),0),0) +
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).toOp,
                       DECODE(p_rsa_rec(i).toStep,
                         2, ROUND(p_rsa_rec(i).scheQty,
                                  WIP_CONSTANTS.INV_MAX_PRECISION), 0), 0)),
                   wop.quantity_waiting_to_move + SUM(
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).fmOp,
                       -1 * DECODE(p_rsa_rec(i).fmStep,
                              3, ROUND(p_rsa_rec(i).scheQty,
                                       WIP_CONSTANTS.INV_MAX_PRECISION),0),0) +
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).toOp,
                       DECODE(p_rsa_rec(i).toStep,
                         3, ROUND(p_rsa_rec(i).scheQty,
                                  WIP_CONSTANTS.INV_MAX_PRECISION), 0), 0)),
                   wop.quantity_rejected + SUM(
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).fmOp,
                       -1*DECODE(p_rsa_rec(i).fmStep,
                            4, ROUND(p_rsa_rec(i).scheQty,
                                     WIP_CONSTANTS.INV_MAX_PRECISION), 0), 0) +
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).toOp,
                       DECODE(p_rsa_rec(i).toStep,
                         4, ROUND(p_rsa_rec(i).scheQty,
                                  WIP_CONSTANTS.INV_MAX_PRECISION), 0), 0)),
                   wop.quantity_scrapped + SUM(
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).fmOp,
                       -1*DECODE(p_rsa_rec(i).fmStep,
                            5, ROUND(p_rsa_rec(i).scheQty,
                                     WIP_CONSTANTS.INV_MAX_PRECISION), 0), 0) +
                     DECODE(wop.operation_seq_num, p_rsa_rec(i).toOp,
                       DECODE(p_rsa_rec(i).toStep,
                         5, ROUND(p_rsa_rec(i).scheQty,
                                  WIP_CONSTANTS.INV_MAX_PRECISION), 0), 0))
              FROM wip_operations wop1
             WHERE wop1.rowid = wop.rowid
               AND wop1.organization_id = p_rsa_rec(i).orgID
               AND wop1.wip_entity_id = p_rsa_rec(i).wipID
               AND wop1.repetitive_schedule_id = p_rsa_rec(i).scheID
               AND (wop1.operation_seq_num = p_rsa_rec(i).fmOp
                OR wop1.operation_seq_num = p_rsa_rec(i).toOp))
     WHERE wop.rowid IN
           (SELECT wop2.rowid
              FROM wip_operations wop2
             WHERE wop2.organization_id = p_rsa_rec(i).orgID
               AND wop2.wip_entity_id = p_rsa_rec(i).wipID
               AND wop2.repetitive_schedule_id = p_rsa_rec(i).scheID
               AND (wop2.operation_seq_num = p_rsa_rec(i).fmOp
                    OR wop2.operation_seq_num = p_rsa_rec(i).toOp));

 /* Enhancement 2864382*/
  IF(p_rsa_rec(i).fmStep = WIP_CONSTANTS.SCRAP AND p_rsa_rec(i).toStep = WIP_CONSTANTS.SCRAP) THEN
      l_forward_move := WIP_CONSTANTS.NO;
      IF(p_rsa_rec(i).fmOp < p_rsa_rec(i).toOp) THEN
        l_forward_move := WIP_CONSTANTS.YES;
      END IF;

      UPDATE WIP_OPERATIONS wop
         SET wop.cumulative_scrap_quantity = wop.cumulative_scrap_quantity +
                                             DECODE(l_forward_move,
                                                    WIP_CONSTANTS.YES,p_rsa_rec(i).scheQty,
                                                    WIP_CONSTANTS.NO,-1 * p_rsa_rec(i).scheQty,
                                                    0)
      WHERE wop.rowid in
            (SELECT wop1.rowid
               FROM WIP_OPERATIONS wop1
              WHERE wop1.organization_id  = p_rsa_rec(i).orgID
                AND wop1.wip_entity_id    = p_rsa_rec(i).wipID
                AND wop1.repetitive_schedule_id = p_rsa_rec(i).scheID
                AND wop1.operation_seq_num > LEAST(p_rsa_rec(i).fmOp,p_rsa_rec(i).toOp)
                AND wop1.operation_seq_num <= GREATEST(p_rsa_rec(i).fmOp,p_rsa_rec(i).toOp));
   ELSIF(p_rsa_rec(i).fmStep=WIP_CONSTANTS.SCRAP OR p_rsa_rec(i).toStep=WIP_CONSTANTS.SCRAP) THEN
     UPDATE WIP_OPERATIONS wop
        SET wop.cumulative_scrap_quantity = wop.cumulative_scrap_quantity +
                                            DECODE(p_rsa_rec(i).toStep,
                                                   WIP_CONSTANTS.SCRAP,p_rsa_rec(i).scheQty,
                                                   0)  +
                                            DECODE(p_rsa_rec(i).fmStep,
                                                   WIP_CONSTANTS.SCRAP,-1*p_rsa_rec(i).scheQty,
                                                   0)
     WHERE wop.rowid in
           (SELECT wop1.rowid
              FROM WIP_OPERATIONS wop1
             WHERE wop1.organization_id        = p_rsa_rec(i).orgID
               AND wop1.wip_entity_id          = p_rsa_rec(i).wipID
               AND wop1.repetitive_schedule_id = p_rsa_rec(i).scheID
               AND wop1.operation_seq_num      > DECODE(p_rsa_rec(i).fmStep,
                                                        WIP_CONSTANTS.SCRAP,p_rsa_rec(i).fmOp,
                                                        p_rsa_rec(i).toOp));
    END IF;


  END LOOP; -- END for loop

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.update_wo_rs',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.update_wo_rs',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END update_wo_rs;


/*****************************************************************************
 * This procedure is equivalent to witoc_update_wo  in wiltps5.ppc
 * This procedure is used to update qty in the queue step of the from
 * operatio for child move txns.
 ****************************************************************************/
PROCEDURE  update_wipops(p_txn_id        IN        NUMBER,
                         p_gib           IN        group_rec_t,
                         x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR2(1);
l_errMsg       VARCHAR2(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter values to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_txn_id';
    l_params(1).paramValue  :=  p_txn_id;
    l_params(2).paramName   := 'p_group_id';
    l_params(2).paramValue  :=  p_gib.group_id;
    l_params(3).paramName   := 'p_txn_date';
    l_params(3).paramValue  :=  p_gib.txn_date;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.update_wipops',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  UPDATE wip_operations wop
     SET (quantity_in_queue,
          last_updated_by,
          last_update_date,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date
         ) =
         (SELECT wop.quantity_in_queue + wmti1.primary_quantity,
                 p_gib.user_id,
                 SYSDATE,
                 DECODE(p_gib.login_id, -1, NULL, p_gib.login_id),
                 DECODE(p_gib.request_id, -1, NULL, p_gib.request_id),
                 DECODE(p_gib.application_id, -1, NULL, p_gib.application_id),
                 DECODE(p_gib.program_id, -1, NULL, p_gib.program_id),
                 DECODE(p_gib.request_id, -1, NULL, SYSDATE)
            FROM wip_operations wop1,
                 wip_move_txn_interface wmti1,
                 wip_move_txn_allocations wma1
           WHERE wop1.rowid = wop.rowid
           -- The WO rows to be updated are identIFied by the rowids.
           -- For each such row, go back and sum the quantities from WMTI
             AND wmti1.group_id = p_gib.group_id
             AND TRUNC(wmti1.transaction_date) = TRUNC(p_gib.txn_date)
             AND wmti1.transaction_id = p_txn_id
             AND wop1.wip_entity_id = wmti1.wip_entity_id
             AND wop1.organization_id = wmti1.organization_id
             AND wop1.operation_seq_num = wmti1.fm_operation_seq_num
             AND wmti1.organization_id = wma1.organization_id (+)
             AND wmti1.transaction_id = wma1.transaction_id (+)
             AND NVL(wma1.repetitive_schedule_id,0) =
                 NVL(wop1.repetitive_schedule_id,0))
         -- the select below must return just 1 row. When Online, group_id
         -- is the same as transaction_id. When in BG, THEN the transaction_id
         -- must be passed.
   WHERE wop.rowid =
         (SELECT wop2.rowid
            FROM wip_operations wop2,
                 wip_move_txn_interface wmti2,
                 wip_move_txn_allocations wma2
           WHERE wmti2.group_id = p_gib.group_id
             AND TRUNC(wmti2.transaction_date) = TRUNC(p_gib.txn_date)
             AND wmti2.transaction_id = p_txn_id
                 -- Picked a Move txn
             AND wop2.wip_entity_id = wmti2.wip_entity_id
             AND wop2.organization_id = wmti2.organization_id
             AND wop2.operation_seq_num = wmti2.fm_operation_seq_num
             AND wmti2.organization_id = wma2.organization_id (+)
             AND wmti2.transaction_id = wma2.transaction_id (+)
             AND NVL(wma2.repetitive_schedule_id,0) =
                 NVL(wop2.repetitive_schedule_id,0));
   -- Picked the row corresponding to the txn. 1 each for such txns
   -- Rowids can be duplicate because there might be 2 wmti records with
   -- the same fm_op

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.update_wipops',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                        x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.update_wipops',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END update_wipops;

/*****************************************************************************
 * This procedure is equivalent to witpsma_move_alloc in wiltps.ppc
 * This procedure is used to allocate repetitive schedule.
 * Need to check the negative quantities and make sure schedule is still
 * Released.
 ****************************************************************************/
PROCEDURE rep_move_alloc(p_gib       IN OUT NOCOPY group_rec_t,
                         x_returnStatus OUT NOCOPY VARCHAR2) IS

CURSOR c_rs_txn(p_timeout  NUMBER,
                p_group_id NUMBER,
                p_txn_date DATE) IS

  SELECT created_by,
         last_updated_by last_upd_by,
         transaction_id txn_id,
         organization_id org_id,
         wip_entity_id wip_id,
         line_id,
         transaction_uom txn_uom,
         transaction_quantity txn_qty,
         primary_quantity primary_qty,
         fm_operation_seq_num fm_op,
         fm_intraoperation_step_type fm_step,
         to_operation_seq_num to_op,
         to_intraoperation_step_type to_step,
         DECODE(SIGN(86400*(SYSDATE - creation_date) - p_timeout),
           1,1,0,0,-1,0) past_timeout,
         NVL(overcompletion_primary_qty,0) oc_pri_qty,
         DECODE(NVL(overcompletion_primary_qty,-1),
           -1,DECODE(NVL(overcompletion_transaction_id,-1),
                -1,WIP_CONSTANTS.normal_txn,
                 WIP_CONSTANTS.child_txn),
           WIP_CONSTANTS.parent_txn) oc_txn_type,
         transaction_type txn_type,
         transaction_date txn_date
    FROM wip_move_txn_interface
   WHERE group_id = p_group_id
     AND TRUNC(transaction_date) = TRUNC(p_txn_date)
     AND process_phase = WIP_CONSTANTS.MOVE_PROC
     AND process_status = WIP_CONSTANTS.RUNNING
     AND entity_type = WIP_CONSTANTS.REPETITIVE
ORDER BY transaction_date, organization_id, wip_entity_id, line_id,
         fm_operation_seq_num, to_operation_seq_num,
         fm_intraoperation_step_type, to_intraoperation_step_type,
         creation_date;

l_rs_txn         c_rs_txn%ROWTYPE;
l_params         wip_logger.param_tbl_t;
l_rsa            rsa_tbl_t;
l_update_rsa     update_rsa_tbl_t;
l_returnStatus   VARCHAR(1);
l_errMsg         VARCHAR2(240);
l_msg            VARCHAR(2000);
l_sche_count     NUMBER;
l_oc_fm_op       NUMBER;
l_rec_count      NUMBER :=0;
l_proc_status    NUMBER;
l_logLevel       NUMBER := fnd_log.g_current_runtime_level;
l_msg_data       VARCHAR2(2000);
l_propagate_job_change_to_po NUMBER;
BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_timeout';
    l_params(2).paramValue  :=  p_gib.time_out;
    l_params(3).paramName   := 'p_txn_date';
    l_params(3).paramValue  :=  p_gib.txn_date;
    l_params(4).paramName   := 'p_login_id';
    l_params(4).paramValue  :=  p_gib.login_id;
    l_params(5).paramName   := 'p_request_id';
    l_params(5).paramValue  :=  p_gib.request_id;
    l_params(6).paramName   := 'p_application_id';
    l_params(6).paramValue  :=  p_gib.application_id;
    l_params(7).paramName   := 'p_program_id';
    l_params(7).paramValue  :=  p_gib.program_id;
    l_params(8).paramName   := 'p_move_mode';
    l_params(8).paramValue  :=  p_gib.move_mode;
    l_params(9).paramName   := 'p_backflush_mode';
    l_params(9).paramValue  :=  p_gib.bf_mode;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.rep_move_alloc',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  OPEN c_rs_txn(p_timeout  => p_gib.time_out,
                p_group_id => p_gib.group_id,
                p_txn_date => p_gib.txn_date);
  LOOP
  BEGIN
    FETCH c_rs_txn INTO l_rs_txn;

    IF(c_rs_txn%NOTFOUND) THEN
      GOTO END_loop;
    ELSE
      l_rec_count := l_rec_count + 1;
      -- call schedule to allocate qty to schedule
      schedule_alloc(p_org_id         => l_rs_txn.org_id,
                     p_wip_id         => l_rs_txn.wip_id,
                     p_line_id        => l_rs_txn.line_id ,
                     p_quantity       => l_rs_txn.primary_qty,
                     p_fm_op          => l_rs_txn.fm_op,
                     p_fm_step        => l_rs_txn.fm_step,
                     p_to_op          => l_rs_txn.to_op,
                     p_to_step        => l_rs_txn.to_step,
                     p_oc_txn_type    => l_rs_txn.oc_txn_type,
                     p_txnType        => l_rs_txn.txn_type,
                     p_fm_form        => WIP_CONSTANTS.NO,
                     p_comp_alloc     => WIP_CONSTANTS.NO,
                     p_txn_date       => l_rs_txn.txn_date, /* Bug 5373061 */
                     x_proc_status    => l_proc_status,
                     x_sche_count     => l_sche_count,
                     x_rsa            => l_rsa,
                     x_returnStatus   => x_returnStatus);
      IF (l_logLevel <= wip_constants.full_logging) THEN
        wip_logger.log(p_msg          => 'l_proc_status = ' || l_proc_status,
                       x_returnStatus => l_returnStatus);
        wip_logger.log(p_msg          => 'l_sche_count = ' || l_sche_count,
                       x_returnStatus => l_returnStatus);
      END IF;

      IF(l_proc_status = WIP_CONSTANTS.RUNNING) THEN

        FOR i IN 1..l_sche_count LOOP
          INSERT INTO wip_move_txn_allocations
                 (transaction_id,
                  repetitive_schedule_id,
                  organization_id,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date,
                  transaction_quantity,
                  primary_quantity)
           VALUES(l_rs_txn.txn_id,
                  l_rsa(i).scheID,
                  l_rs_txn.org_id,
                  SYSDATE,
                  l_rs_txn.last_upd_by,
                  SYSDATE,
                  l_rs_txn.created_by,     -- Fix for bug 5195072
                  DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
                  DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                  DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                  DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                  DECODE(p_gib.request_id,-1,NULL,SYSDATE),
                  l_rs_txn.txn_qty * l_rsa(i).scheQty /
                    l_rs_txn.primary_qty, -- transaction_quantity
                  ROUND(l_rsa(i).scheQty,
                        WIP_CONSTANTS.INV_MAX_PRECISION)); -- primary_quantity
        END LOOP; --END for loop

        IF(l_rs_txn.oc_txn_type = WIP_CONSTANTS.child_txn) THEN

          -- update qty in the queue step of the from operation
          -- for child move txns.
          update_wipops(p_txn_id         => l_rs_txn.txn_id,
                        p_gib            => p_gib,
                        x_returnStatus   => x_returnStatus);

          IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
            l_errMsg := 'wip_movProc_priv.update_wipops failed';
            raise fnd_api.g_exc_unexpected_error;
          END IF;

        END IF; -- child txns

        IF(l_rs_txn.oc_txn_type = WIP_CONSTANTS.parent_txn) THEN
          -- all procedure in this loop is pretty much for child record
          -- IF it is over completion/move txn, insert child record to WMTI
          insert_alloc_child(p_org_id         => l_rs_txn.org_id,
                             p_scheID         => l_rsa(1).scheID,
                             p_oc_pri_qty     => l_rs_txn.oc_pri_qty,
                             p_parent_txn_id  => l_rs_txn.txn_id,
                             p_gib            => p_gib,
                             x_oc_fm_op       => l_oc_fm_op,
                             x_returnStatus   => x_returnStatus);

          IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN

            IF (l_rs_txn.past_timeout = 0) THEN -- not time out yet
              UPDATE wip_move_txn_interface
                 SET process_status = WIP_CONSTANTS.PENDING,
                     group_id       = NULL,
                     transaction_id = NULL
               WHERE transaction_id = l_rs_txn.txn_id
                 AND group_id = p_gib.group_id;
            END IF; -- time out check

            l_errMsg := 'wip_movProc_priv.insert_alloc_child failed';
            raise fnd_api.g_exc_unexpected_error;

          ELSE -- insert child success
            -- insert assemblies in the queue of the first operation after
            -- the child record is inserted
            update_wipops(p_txn_id         => p_gib.move_profile.child_txn_id,
                          p_gib            => p_gib,
                          x_returnStatus   => x_returnStatus);

            IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_movProc_priv.update_wipops failed';
              raise fnd_api.g_exc_unexpected_error;
            END IF;

            -- prepare data before calling update_wo_rs
            l_update_rsa(1).scheID    := l_rsa(l_sche_count).scheID;
            l_update_rsa(1).scheQty   := l_rs_txn.oc_pri_qty;
            l_update_rsa(1).loginID   := p_gib.login_id;
            l_update_rsa(1).reqID     := p_gib.request_id;
            l_update_rsa(1).appID     := p_gib.application_id;
            l_update_rsa(1).progID    := p_gib.program_id;
            l_update_rsa(1).createdBy := l_rs_txn.created_by;
            l_update_rsa(1).updatedBy := l_rs_txn.last_upd_by;
            l_update_rsa(1).orgID     := l_rs_txn.org_id;
            l_update_rsa(1).wipID     := l_rs_txn.wip_id;
            l_update_rsa(1).fmOp      := l_oc_fm_op;
            l_update_rsa(1).toOp      := l_rs_txn.fm_op;
            l_update_rsa(1).fmStep    := WIP_CONSTANTS.QUEUE;
            l_update_rsa(1).toStep    := l_rs_txn.fm_step;

            update_wo_rs(p_scheCount    => 1,
                         p_rsa_rec      => l_update_rsa,
                         p_txn_date     => l_rs_txn.txn_date,
                         x_returnStatus => x_returnStatus);

            IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_movProc_priv.update_wo_rs failed';
              raise fnd_api.g_exc_unexpected_error;
            END IF;
          END IF; -- insert_alloc_child check

          IF(l_rs_txn.oc_pri_qty <> 0 AND
             po_code_release_grp.Current_Release >=
             po_code_release_grp.PRC_11i_Family_Pack_J) THEN

            SELECT propagate_job_change_to_po
              INTO l_propagate_job_change_to_po
              FROM wip_parameters
             WHERE organization_id = l_rs_txn.org_id;

            IF(l_propagate_job_change_to_po = WIP_CONSTANTS.YES) THEN
              wip_osp.updatePOReqQuantity(
                p_job_id        => l_rs_txn.wip_id,
                p_repetitive_id => l_rsa(1).scheID,
                p_org_id        => l_rs_txn.org_id,
                p_changed_qty   => l_rs_txn.oc_pri_qty,
               /* Fix for Bug#4746495. PO linked to current Operation should
                * not be updated. Only future PO should be updated.
                */
                p_fm_op         => l_rs_txn.fm_op,
                x_return_status => x_returnStatus);

              IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
                l_errMsg := 'wip_osp.updatePOReqQuantity failed';
                raise fnd_api.g_exc_unexpected_error;
              END IF; -- l_return_status
            END IF; -- l_propagate_job_change_to_po = WIP_CONSTANTS.YES
          END IF; -- l_rs_txn.oc_pri_qty <> 0 and customer have PO FPJ
        END IF; --  IF parent_txn

        -- prepare data before calling update_wo_rs
        FOR i IN 1..l_sche_count LOOP
          l_update_rsa(i).scheID    := l_rsa(i).scheID;
          l_update_rsa(i).scheQty   := l_rsa(i).scheQty;
          l_update_rsa(i).loginID   := p_gib.login_id;
          l_update_rsa(i).reqID     := p_gib.request_id;
          l_update_rsa(i).appID     := p_gib.application_id;
          l_update_rsa(i).progID    := p_gib.program_id;
          l_update_rsa(i).createdBy := l_rs_txn.created_by;
          l_update_rsa(i).updatedBy := l_rs_txn.last_upd_by;
          l_update_rsa(i).orgID     := l_rs_txn.org_id;
          l_update_rsa(i).wipID     := l_rs_txn.wip_id;
          l_update_rsa(i).fmOp      := l_rs_txn.fm_op;
          l_update_rsa(i).toOp      := l_rs_txn.to_op;
          l_update_rsa(i).fmStep    := l_rs_txn.fm_step;
          l_update_rsa(i).toStep    := l_rs_txn.to_step ;
        END LOOP;
        -- update wip_operations
        update_wo_rs(p_scheCount    => l_sche_count,
                     p_rsa_rec      => l_update_rsa,
                     p_txn_date     => l_rs_txn.txn_date,
                     x_returnStatus => x_returnStatus);

        IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_movProc_priv.update_wo_rs failed';
          raise fnd_api.g_exc_unexpected_error;
        END IF;

      ELSIF(l_proc_status = TVE_OVERCOMPLETION_MISMATCH OR
            l_proc_status = TVE_NO_MOVE_ALLOC) THEN

        IF(p_gib.move_mode = WIP_CONSTANTS.BACKGROUND) THEN
          IF (l_rs_txn.past_timeout = 0) THEN -- not time out yet
            UPDATE wip_move_txn_interface
               SET process_status = WIP_CONSTANTS.PENDING,
                   group_id       = NULL,
                   transaction_id = NULL
             WHERE transaction_id = l_rs_txn.txn_id
               AND group_id = p_gib.group_id;
          END IF; -- time out check
        END IF; -- BACKGROUND check

        IF(l_proc_status = TVE_OVERCOMPLETION_MISMATCH) THEN
          fnd_message.set_name('WIP', 'WIP_OVERCOMPLETION_MISMATCH');
          fnd_msg_pub.add;
          l_errMsg := 'parent txn is not really overcompletion txn';
          raise fnd_api.g_exc_unexpected_error;
        ELSE
          fnd_message.set_name('WIP', 'WIP_LESS_OR_EQUAL');
          fnd_message.set_token('ENTITY1', 'transaction quantity');
          fnd_message.set_token('ENTITY2', 'quantity available to move');
          fnd_msg_pub.add;
          l_errMsg := 'available qty is not enough to fullfill move txn';
          raise fnd_api.g_exc_unexpected_error;
        END IF;

      ELSIF(l_proc_status = WIP_CONSTANTS.ERROR) THEN

        -- update move_interface table
        UPDATE wip_move_txn_interface
           SET process_status = WIP_CONSTANTS.ERROR
         WHERE transaction_id = l_rs_txn.txn_id
           AND group_id = p_gib.group_id;

        l_errMsg := 'wip_movProc_priv.schedule_alloc failed';
        raise fnd_api.g_exc_unexpected_error;

      END IF; -- process_status

    END IF; -- c_rs_txn%NOTFOUND
    -- Fixed bug 4324706. Reset p_gib.move_profile.child_txn_id to null
    -- to prevent child move record got inserted with the same transaction_id.
    p_gib.move_profile.child_txn_id := null;
    -- Fixed bug 4406536. We should error out only problematic record and
    -- continue to process next record.
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF(p_gib.move_mode = WIP_CONSTANTS.BACKGROUND) THEN
        IF (l_rs_txn.past_timeout = 0) THEN -- not time out yet
          UPDATE wip_move_txn_interface
             SET process_status = WIP_CONSTANTS.PENDING,
                 group_id       = NULL,
                 transaction_id = NULL
           WHERE transaction_id = l_rs_txn.txn_id
             AND group_id = p_gib.group_id;
        ELSE -- already time out
          UPDATE wip_move_txn_interface
             SET process_status = WIP_CONSTANTS.ERROR
           WHERE transaction_id = l_rs_txn.txn_id
             AND group_id = p_gib.group_id;

          -- Get error from message stack
          wip_utilities.get_message_stack(p_msg =>l_msg);
          IF(l_msg IS NULL) THEN
            -- initialize message to something because we cannot insert
            -- null into WIP_TXN_INTERFACE_ERRORS
            fnd_message.set_name('WIP', 'WIP_SOME_RECORDS_ERROR');
            l_msg := fnd_message.get;
          END IF;

          INSERT INTO WIP_TXN_INTERFACE_ERRORS
                  (transaction_id,
                   error_column,
                   error_message,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date)
                SELECT  wmti.transaction_id,
                        'TRANSACTION_QUANTITY', -- error_column
                        substrb(l_msg,1,240),   -- error_message
                        SYSDATE,                -- last_update_date
                        wmti.last_updated_by,   -- last_update_by
                        SYSDATE,                -- creation_date
                        wmti.created_by,        -- created_by
                        p_gib.login_id,
                        p_gib.request_id,
                        p_gib.application_id,
                        p_gib.program_id,
                        SYSDATE                 -- program_update_date
                   FROM wip_move_txn_interface wmti
                  WHERE wmti.transaction_id = l_rs_txn.txn_id
                    AND wmti.group_id = p_gib.group_id;
        END IF; -- time out check
      ELSE--Online processing
      --Bug 5210073: Raise an exception to rollback the changes in online mode.
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- background check
  END;
  END LOOP;

<<END_loop>>
  IF (l_rec_count = 0) THEN -- no record found
    l_errMsg := 'No reptitive move record found';
    raise fnd_api.g_exc_unexpected_error;

  ELSE
    IF(c_rs_txn%ISOPEN) THEN
      CLOSE c_rs_txn;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_success;

    -- write to the log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.rep_move_alloc',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure complete',
                           x_returnStatus => l_returnStatus);
    END IF;

  END IF;

EXCEPTION

  WHEN fnd_api.g_exc_unexpected_error THEN
    IF(c_rs_txn%ISOPEN) THEN
      CLOSE c_rs_txn;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.rep_move_alloc',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
  WHEN others THEN
    IF(c_rs_txn%ISOPEN) THEN
      CLOSE c_rs_txn;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.rep_move_alloc',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END rep_move_alloc;

/*****************************************************************************
 * This procedure is equivalent to wip_update_wo_dj in wiltps.ppc
 * This procedure is used to update WIP_OPERATIONS table for discrete and
 * lotbased jobs.
 ****************************************************************************/
PROCEDURE update_wo_dj(p_fm_op         IN        NUMBER,
                       p_fm_step       IN        NUMBER,
                       p_to_op         IN        NUMBER,
                       p_to_step       IN        NUMBER,
                       p_qty           IN        NUMBER,
                       p_org_id        IN        NUMBER,
                       p_wip_id        IN        NUMBER,
                       p_txn_date      IN        DATE,
                       p_gib           IN        group_rec_t,
                       x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_errMsg       VARCHAR2(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
l_forward_move NUMBER;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_txn_date';
    l_params(1).paramValue  :=  p_txn_date;
    l_params(2).paramName   := 'p_fm_op';
    l_params(2).paramValue  :=  p_fm_op;
    l_params(3).paramName   := 'p_fm_step';
    l_params(3).paramValue  :=  p_fm_step;
    l_params(4).paramName   := 'p_to_op';
    l_params(4).paramValue  :=  p_to_op;
    l_params(5).paramName   := 'p_to_step';
    l_params(5).paramValue  :=  p_to_step;
    l_params(6).paramName   := 'p_qty';
    l_params(6).paramValue  :=  p_qty;
    l_params(7).paramName   := 'p_org_id';
    l_params(7).paramValue  :=  p_org_id;
    l_params(8).paramName   := 'p_wip_id';
    l_params(8).paramValue  :=  p_wip_id;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.update_wo_dj',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  UPDATE wip_operations wop
     SET (date_last_moved,
          last_updated_by,
          last_update_date,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          quantity_in_queue,
          quantity_running,
          quantity_waiting_to_move,
          quantity_rejected,
          quantity_scrapped) =

          (SELECT DECODE(wop.operation_seq_num,
                  p_fm_op,p_txn_date, wop.date_last_moved),
                  p_gib.user_id,
                  SYSDATE,
                  DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
                  DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                  DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                  DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                  DECODE(p_gib.request_id,-1,NULL,SYSDATE),
                  wop.quantity_in_queue + SUM(
                    DECODE(wop.operation_seq_num,
                      p_fm_op, -1 * DECODE(p_fm_step,
                                      1,ROUND(p_qty,
                                              WIP_CONSTANTS.INV_MAX_PRECISION),
                                      0),
                      0) +
                    DECODE(wop.operation_seq_num,
                      p_to_op,DECODE(p_to_step,
                                1,ROUND(p_qty,WIP_CONSTANTS.INV_MAX_PRECISION),
                                0),
                      0)),
                  wop.quantity_running + SUM(
                    DECODE(wop.operation_seq_num,
                      p_fm_op, -1 * DECODE(p_fm_step,
                                      2,ROUND(p_qty,
                                              WIP_CONSTANTS.INV_MAX_PRECISION),
                                      0),
                      0) +
                    DECODE(wop.operation_seq_num,
                      p_to_op,DECODE(p_to_step,
                                2,ROUND(p_qty,WIP_CONSTANTS.INV_MAX_PRECISION),
                                0),
                      0)),
                  wop.quantity_waiting_to_move + SUM(
                    DECODE(wop.operation_seq_num,
                      p_fm_op, -1 * DECODE(p_fm_step,
                                      3,ROUND(p_qty,
                                              WIP_CONSTANTS.INV_MAX_PRECISION),
                                      0),
                      0) +
                    DECODE(wop.operation_seq_num,
                      p_to_op,DECODE(p_to_step,
                                3,ROUND(p_qty,WIP_CONSTANTS.INV_MAX_PRECISION),
                                0),
                      0)),
                  wop.quantity_rejected + SUM(
                    DECODE(wop.operation_seq_num,
                      p_fm_op,-1 * DECODE(p_fm_step,
                                     4,ROUND(p_qty,
                                             WIP_CONSTANTS.INV_MAX_PRECISION),
                                     0),
                      0) +
                    DECODE(wop.operation_seq_num,
                      p_to_op,DECODE(p_to_step,
                                4,ROUND(p_qty,WIP_CONSTANTS.INV_MAX_PRECISION),
                                0),
                      0)),
                  wop.quantity_scrapped + SUM(
                    DECODE(wop.operation_seq_num,
                      p_fm_op,-1 * DECODE(p_fm_step,
                                     5,ROUND(p_qty,
                                             WIP_CONSTANTS.INV_MAX_PRECISION),
                                     0),
                      0) +
                    DECODE(wop.operation_seq_num,
                      p_to_op,DECODE(p_to_step,
                                5,ROUND(p_qty,WIP_CONSTANTS.INV_MAX_PRECISION),
                                0),
                      0))
             FROM wip_operations wop1
            WHERE wop1.rowid = wop.rowid
              AND wop1.organization_id = p_org_id
              AND wop1.wip_entity_id = p_wip_id
              AND (wop1.operation_seq_num = p_fm_op
                   OR wop1.operation_seq_num = p_to_op))
   WHERE wop.rowid IN
         (SELECT wop2.rowid
            FROM wip_operations wop2
           WHERE wop2.organization_id = p_org_id
             AND wop2.wip_entity_id = p_wip_id
             AND (wop2.operation_seq_num = p_fm_op
                  OR wop2.operation_seq_num = p_to_op));

 /*Enh#2864382.Update wip_operations.cumulative_scrap_quantity after each
   scrap or return from scrap txn*/
   IF(p_fm_step = WIP_CONSTANTS.SCRAP AND p_to_step = WIP_CONSTANTS.SCRAP) THEN
     l_forward_move  := WIP_CONSTANTS.NO;
     IF(p_fm_op<p_to_op) THEN
       l_forward_move := WIP_CONSTANTS.YES;
     END IF;

     UPDATE WIP_OPERATIONS  wo
       SET  wo.cumulative_scrap_quantity = wo.cumulative_scrap_quantity +
                                           DECODE(l_forward_move,
                                                  WIP_CONSTANTS.YES, -1*p_qty,
                                                  WIP_CONSTANTS.NO, p_qty,
                                                  0)
     WHERE  wo.rowid in
            ( SELECT wo1.rowid
                FROM WIP_OPERATIONS wo1
               WHERE wo1.organization_id = p_org_id
                 AND wo1.wip_entity_id = p_wip_id
                 AND wo1.operation_seq_num > LEAST(p_fm_op,p_to_op)
                 AND wo1.operation_seq_num <= GREATEST(p_fm_op,p_to_op));
  ELSIF(p_fm_step=WIP_CONSTANTS.SCRAP OR p_to_step=WIP_CONSTANTS.SCRAP)THEN
    UPDATE WIP_OPERATIONS wo
       SET wo.cumulative_scrap_quantity = wo.cumulative_scrap_quantity +
                                          DECODE(p_to_step,
                                                 WIP_CONSTANTS.SCRAP,p_qty,
                                                 0)   +
                                          DECODE(p_fm_step,
                                                 WIP_CONSTANTS.SCRAP,-1*p_qty,
                                                 0)
    WHERE wo.rowid in
          (SELECT wo1.rowid
             FROM WIP_OPERATIONS wo1
            WHERE wo1.organization_id = p_org_id
              AND wo1.wip_entity_id   = p_wip_id
              AND wo1.operation_seq_num > DECODE(p_fm_step,
                                                 WIP_CONSTANTS.SCRAP,p_fm_op,
                                                 p_to_op));
  END IF;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.update_wo_dj',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.update_wo_dj',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END update_wo_dj;

/*****************************************************************************
 * This procedure is equivalent to witpssq_step_qtys_dj in wiltps.ppc
 * This procedure is used to check whether the quantity is enough to move or
 * not. IF it is enough, update WIP_OPERATIONS.
 ****************************************************************************/
PROCEDURE check_qty_dj(p_gib       IN OUT NOCOPY group_rec_t,
                       x_returnStatus OUT NOCOPY VARCHAR2) IS

CURSOR c_dj_txn(p_timeout  NUMBER,
                p_group_id NUMBER,
                p_txn_date DATE) IS

  SELECT wmti.transaction_id txn_id,
         wmti.organization_id org_id,
         wmti.wip_entity_id wip_id,
         wmti.primary_quantity qty,
         wmti.fm_operation_seq_num fm_op,
         wmti.fm_intraoperation_step_type fm_step,
         wmti.to_operation_seq_num to_op,
         wmti.to_intraoperation_step_type to_step,
         DECODE(SIGN(86400*(SYSDATE - wmti.creation_date) - p_timeout),
           1,1,0) past_timeout,
         NVL(wmti.overcompletion_primary_qty,0) oc_pri_qty,
         DECODE(NVL(wmti.overcompletion_primary_qty,-1),
           -1,DECODE(NVL(wmti.overcompletion_transaction_id,-1),
           -1,WIP_CONSTANTS.normal_txn, WIP_CONSTANTS.child_txn)
           ,WIP_CONSTANTS.parent_txn) oc_txn_type,
         -- new columns added for serial location check
         wmti.transaction_type txn_type,
         wmti.primary_item_id item_id,
         NVL(wdj.serialization_start_op, 0) sn_start_op,
         wmti.transaction_date txn_date
    FROM wip_move_txn_interface wmti,
         wip_discrete_jobs wdj
   WHERE wmti.wip_entity_id = wdj.wip_entity_id
     AND wmti.group_id = p_group_id
     AND TRUNC(wmti.transaction_date) = TRUNC(p_txn_date)
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     /* Now checks for lotbased entity type also */
     AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
         OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)
ORDER BY wmti.transaction_date,
         wmti.organization_id,
         wmti.wip_entity_id,
         wmti.processing_order,
         wmti.fm_operation_seq_num,
         wmti.to_operation_seq_num,
         wmti.fm_intraoperation_step_type,
         wmti.to_intraoperation_step_type,
         wmti.creation_date;

CURSOR c_ser_loc(p_start_op NUMBER,
                 p_move_id  NUMBER) IS

  SELECT msn.serial_number serial,
         NVL(msn.operation_seq_num, p_start_op) sn_op,
         NVL(msn.intraoperation_step_type, WIP_CONSTANTS.QUEUE) sn_step
    FROM mtl_serial_numbers msn,
         wip_serial_move_interface wsmi,
         wip_move_txn_interface wmti
   WHERE msn.inventory_item_id = wmti.primary_item_id
     AND msn.current_organization_id = wmti.organization_id
     -- msn.wip_entity_id will be null after complete to inventory. Need this
     -- check to support return transaction.
     AND (msn.wip_entity_id is null OR
          msn.wip_entity_id = wmti.wip_entity_id)
     AND msn.serial_number = wsmi.assembly_serial_number
     AND wmti.transaction_id = wsmi.transaction_id
     AND wmti.transaction_id = p_move_id
     AND wmti.group_id = p_gib.group_id;

l_dj_txn         c_dj_txn%ROWTYPE;
l_ser_loc        c_ser_loc%ROWTYPE;
l_params         wip_logger.param_tbl_t;
l_returnStatus   VARCHAR(1);
l_errMsg         VARCHAR2(240);
l_msg            VARCHAR(2000);
l_rec_count      NUMBER :=0;
l_queue_qty      NUMBER;
l_run_qty        NUMBER;
l_tomove_qty     NUMBER;
l_reject_qty     NUMBER;
l_scrap_qty      NUMBER;
l_oc_fm_op       NUMBER;
-- Fixed bug 4406536. We should initialized l_notenough at the beginning of
-- for loop, not the declaration part.
-- l_notenough      BOOLEAN := FALSE;
l_notenough      BOOLEAN;
l_logLevel       NUMBER := fnd_log.g_current_runtime_level;
-- new variables added for serial location check
l_opSeq          NUMBER;
l_step           NUMBER;
l_msg_data       VARCHAR2(2000);
l_propagate_job_change_to_po NUMBER;
BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_timeout';
    l_params(2).paramValue  :=  p_gib.time_out;
    l_params(3).paramName   := 'p_txn_date';
    l_params(3).paramValue  :=  p_gib.txn_date;
    l_params(4).paramName   := 'p_move_mode';
    l_params(4).paramValue  :=  p_gib.move_mode;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.check_qty_dj',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  OPEN c_dj_txn(p_timeout  => p_gib.time_out,
                p_group_id => p_gib.group_id,
                p_txn_date => p_gib.txn_date);
  LOOP
  BEGIN
    FETCH c_dj_txn INTO l_dj_txn;
    IF(c_dj_txn%NOTFOUND) THEN
      GOTO end_loop;
    ELSE
      l_rec_count := l_rec_count + 1;
      -- Fixed bug 4406536. We should initialized l_notenough at the beginning
      -- of for loop, not the declaration part.
      l_notenough := FALSE;
      -- validate serial location if serialized job, and serialized move
      IF(l_dj_txn.sn_start_op <> 0 AND
         l_dj_txn.fm_op >= l_dj_txn.sn_start_op AND
         l_dj_txn.to_op >= l_dj_txn.sn_start_op) THEN
        -- Only check serial locationtion if transaction_type is either
        -- Move or Move and Complete. We already check that serial has valid
        -- status to do Return and Move in Move Validation code, so no need to
        -- check serial location because both MSN.OPERATION_SEQ_NUM and
        -- MSN.INTRAOPERATION_STEP_TYPE will be null, anyway.
        FOR l_ser_loc IN c_ser_loc(p_start_op => l_dj_txn.sn_start_op,
                                   p_move_id  => l_dj_txn.txn_id) LOOP

          -- get MSN.OPERATION_SEQ_NUM and MSN.INTRAOPERATION_STEP_TYPE

          IF(l_dj_txn.txn_type IN (WIP_CONSTANTS.COMP_TXN,
                                   WIP_CONSTANTS.MOVE_TXN) AND
             (l_ser_loc.sn_op <> l_dj_txn.fm_op OR
              l_ser_loc.sn_step <> l_dj_txn.fm_step)) THEN
            fnd_message.set_name('WIP', 'WIP_SERIAL_LOCATION_MISSMATCH');
            fnd_msg_pub.add;
            l_errMsg := 'current serial location missmatch';
            raise fnd_api.g_exc_unexpected_error;
          ELSE -- serial location is valid to move
            -- If user move back to Queue of serialization start op, we clear
            -- operation_seq_num and intraoperation_step_type in MSNT
            IF (l_dj_txn.to_op   = l_dj_txn.sn_start_op AND
                l_dj_txn.to_step = WIP_CONSTANTS.QUEUE) THEN
              l_opSeq := null;
              l_step  := null;
            ELSE
              l_opSeq := l_dj_txn.to_op;
              l_step  := l_dj_txn.to_step;
            END IF;
            -- update current serial location to WMTI.TO_OPERATION_SEQ_NUM and
            -- WMTI.INTRAOPERATION_STEP_TYPE
            wip_utilities.update_serial(
              p_serial_number            => l_ser_loc.serial,
              p_inventory_item_id        => l_dj_txn.item_id,
              p_organization_id          => l_dj_txn.org_id,
              p_wip_entity_id            => l_dj_txn.wip_id,
              p_line_mark_id             => null,
              p_operation_seq_num        => l_opSeq,
              p_intraoperation_step_type => l_step,
              x_return_status            => l_returnStatus);

            IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_utilities.update_serial failed';
              raise fnd_api.g_exc_unexpected_error;
            END IF;
          END IF; -- IF(l_dj_txn.txn_type
        END LOOP; -- l_ser_loc IN c_ser_loc
      END IF; -- serialized move

      SELECT wop.quantity_in_queue,
             wop.quantity_running,
             wop.quantity_waiting_to_move,
             wop.quantity_rejected,
             wop.quantity_scrapped
        INTO l_queue_qty,
             l_run_qty,
             l_tomove_qty,
             l_reject_qty,
             l_scrap_qty
        FROM wip_operations wop
       WHERE wop.organization_id = l_dj_txn.org_id
         AND wop.wip_entity_id = l_dj_txn.wip_id
         AND wop.operation_seq_num = l_dj_txn.fm_op;

      IF(l_dj_txn.oc_txn_type = WIP_CONSTANTS.child_txn) THEN
         -- update qty in queue step for child txn
        update_wipops(p_txn_id         => l_dj_txn.txn_id,
                      p_gib            => p_gib,
                      x_returnStatus   => x_returnStatus);

        IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_movProc_priv.update_wipops failed';
          raise fnd_api.g_exc_unexpected_error;
        END IF; -- check return status

      ELSE   -- IF it is parent or normal txn, validate qty

        IF(l_dj_txn.fm_step = WIP_CONSTANTS.QUEUE) THEN
          IF(l_dj_txn.qty > l_queue_qty + l_dj_txn.oc_pri_qty + 0.00001) THEN
            l_notenough := TRUE;
          END IF;
        ELSIF(l_dj_txn.fm_step = WIP_CONSTANTS.RUN) THEN
          IF(l_dj_txn.qty > l_run_qty + l_dj_txn.oc_pri_qty + 0.00001) THEN
            l_notenough := TRUE;
          END IF;
        ELSIF(l_dj_txn.fm_step = WIP_CONSTANTS.TOMOVE) THEN
          IF(l_dj_txn.qty > l_tomove_qty + l_dj_txn.oc_pri_qty + 0.00001) THEN
            l_notenough := TRUE;
          END IF;
        ELSIF(l_dj_txn.fm_step = WIP_CONSTANTS.REJECT) THEN
          IF(l_dj_txn.qty > l_reject_qty + l_dj_txn.oc_pri_qty + 0.00001) THEN
            l_notenough := TRUE;
          END IF;
        ELSIF(l_dj_txn.fm_step = WIP_CONSTANTS.SCRAP) THEN
          IF(l_dj_txn.qty > l_scrap_qty + l_dj_txn.oc_pri_qty + 0.00001) THEN
            l_notenough := TRUE;
          END IF;
        END IF; -- fm_step check
      END IF; -- child txn check

      IF(l_notenough) THEN
        IF(p_gib.move_mode = WIP_CONSTANTS.BACKGROUND) THEN
          IF (l_dj_txn.past_timeout = 0) THEN -- not time out yet
            UPDATE wip_move_txn_interface
               SET process_status = WIP_CONSTANTS.PENDING,
                   group_id       = NULL,
                   transaction_id = NULL
             WHERE transaction_id = l_dj_txn.txn_id
               AND group_id = p_gib.group_id;
          END IF; -- time out check
        END IF; -- BACKGROUND check
        fnd_message.set_name('WIP', 'WIP_LESS_OR_EQUAL');
        fnd_message.set_token('ENTITY1', 'transaction quantity');
        fnd_message.set_token('ENTITY2', 'quantity available to move');
        fnd_msg_pub.add;
        l_errMsg := 'available qty is not enough to fullfill move txn';
        raise fnd_api.g_exc_unexpected_error;
      ELSE -- enough qty to move
        IF(l_dj_txn.oc_txn_type = WIP_CONSTANTS.parent_txn) THEN

          -- all procedure in this loop is pretty much for child record
          -- IF it is over completion/move txn, insert child record to WMTI
          insert_alloc_child(p_org_id         => l_dj_txn.org_id,
                             p_scheID         => -1,
                             p_oc_pri_qty     => l_dj_txn.oc_pri_qty,
                             p_parent_txn_id  => l_dj_txn.txn_id,
                             p_gib            => p_gib,
                             x_oc_fm_op       => l_oc_fm_op,
                             x_returnStatus   => x_returnStatus);

          IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
            IF (l_dj_txn.past_timeout = 0) THEN -- not time out yet
              UPDATE wip_move_txn_interface
                 SET process_status = WIP_CONSTANTS.PENDING,
                     group_id       = NULL,
                     transaction_id = NULL
               WHERE transaction_id = l_dj_txn.txn_id
                 AND group_id = p_gib.group_id;
            END IF; -- time out check

            l_errMsg := 'wip_movProc_priv.insert_alloc_child failed';
            raise fnd_api.g_exc_unexpected_error;

          ELSE -- insert child success
            -- insert assemblies in the queue of the first operation after
            -- the child record is inserted
            update_wipops(p_txn_id         => p_gib.move_profile.child_txn_id,
                          p_gib            => p_gib,
                          x_returnStatus   => x_returnStatus);

            IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_movProc_priv.update_wipops failed';
              raise fnd_api.g_exc_unexpected_error;
            END IF;

            -- update wip_operations for child move txns
            update_wo_dj(p_gib             => p_gib,
                         p_fm_op           => l_oc_fm_op,
                         p_fm_step         => WIP_CONSTANTS.QUEUE,
                         p_to_op           => l_dj_txn.fm_op,
                         p_to_step         => l_dj_txn.fm_step,
                         p_qty             => l_dj_txn.oc_pri_qty,
                         p_org_id          => l_dj_txn.org_id,
                         p_wip_id          => l_dj_txn.wip_id,
                         p_txn_date        => l_dj_txn.txn_date,
                         x_returnStatus    => x_returnStatus);

            IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_movProc_priv.update_wo_dj failed';
              raise fnd_api.g_exc_unexpected_error;
            END IF;
          END IF; -- insert_alloc_child check

          -- Increase PO/requisition quantity if overmove
          IF(l_dj_txn.oc_pri_qty <> 0 AND
             po_code_release_grp.Current_Release >=
             po_code_release_grp.PRC_11i_Family_Pack_J) THEN

            SELECT propagate_job_change_to_po
              INTO l_propagate_job_change_to_po
              FROM wip_parameters
             WHERE organization_id = l_dj_txn.org_id;

            IF(l_propagate_job_change_to_po = WIP_CONSTANTS.YES) THEN
              wip_osp.updatePOReqQuantity(
                p_job_id        => l_dj_txn.wip_id,
                p_org_id        => l_dj_txn.org_id,
                p_changed_qty   => l_dj_txn.oc_pri_qty,
               /* Fix for Bug#4746495. PO linked to current Operation should
                * not be updated. Only future PO should be updated.
                */
                p_fm_op         => l_dj_txn.fm_op,
                x_return_status => x_returnStatus);

              IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
                l_errMsg := 'wip_osp.updatePOReqQuantity failed';
                raise fnd_api.g_exc_unexpected_error;
              END IF; -- x_returnStatus
            END IF; -- l_propagate_job_change_to_po = WIP_CONSTANTS.YES
          END IF; -- l_dj_txn.oc_pri_qty <> 0 and customer have PO FPJ
        END IF; --  IF parent_txn

        -- update wip_operations for parent and normal move txns
        update_wo_dj(p_gib             => p_gib,
                     p_fm_op           => l_dj_txn.fm_op,
                     p_fm_step         => l_dj_txn.fm_step,
                     p_to_op           => l_dj_txn.to_op,
                     p_to_step         => l_dj_txn.to_step,
                     p_qty             => l_dj_txn.qty,
                     p_org_id          => l_dj_txn.org_id,
                     p_wip_id          => l_dj_txn.wip_id,
                     p_txn_date        => l_dj_txn.txn_date,
                     x_returnStatus    => x_returnStatus);

        IF (x_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_movProc_priv.update_wo_dj failed';
          raise fnd_api.g_exc_unexpected_error;
        END IF;

      END IF; -- check enough qty

    END IF; --c_dj_txn%NOTFOUND
    -- Fixed bug 4324706. Reset p_gib.move_profile.child_txn_id to null
    -- to prevent child move record got inserted with the same transaction_id.
    p_gib.move_profile.child_txn_id := null;
    -- Fixed bug 4406536. We should error out only problematic record and
    -- continue to process next record.
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF(p_gib.move_mode = WIP_CONSTANTS.BACKGROUND) THEN
        IF (l_dj_txn.past_timeout = 0) THEN -- not time out yet
          UPDATE wip_move_txn_interface
             SET process_status = WIP_CONSTANTS.PENDING,
                 group_id       = NULL,
                 transaction_id = NULL
           WHERE transaction_id = l_dj_txn.txn_id
             AND group_id = p_gib.group_id;
        ELSE -- already time out
          UPDATE wip_move_txn_interface
             SET process_status = WIP_CONSTANTS.ERROR
           WHERE transaction_id = l_dj_txn.txn_id
             AND group_id = p_gib.group_id;
          -- Get error from message stack
          wip_utilities.get_message_stack(p_msg =>l_msg);
          IF(l_msg IS NULL) THEN
            -- initialize message to something because we cannot insert
            -- null into WIP_TXN_INTERFACE_ERRORS
            fnd_message.set_name('WIP', 'WIP_SOME_RECORDS_ERROR');
            l_msg := fnd_message.get;
          END IF;

          INSERT INTO WIP_TXN_INTERFACE_ERRORS
                  (transaction_id,
                   error_column,
                   error_message,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date)
                SELECT  wmti.transaction_id,
                        'TRANSACTION_QUANTITY', -- error_column
                        substrb(l_msg,1,240),   -- error_message
                        SYSDATE,                -- last_update_date
                        wmti.last_updated_by,   -- last_update_by
                        SYSDATE,                -- creation_date
                        wmti.created_by,        -- created_by
                        p_gib.login_id,
                        p_gib.request_id,
                        p_gib.application_id,
                        p_gib.program_id,
                        SYSDATE                 -- program_update_date
                   FROM wip_move_txn_interface wmti
                  WHERE wmti.transaction_id = l_dj_txn.txn_id
                    AND wmti.group_id = p_gib.group_id;
        END IF; -- time out check
      ELSE--Online processing
      --Bug 5210073: Raise an exception to rollback the changes in online mode.
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- background check
  END;
  END LOOP; -- c_dj_txn

<<end_loop>>
  IF(c_dj_txn%ISOPEN) THEN
    CLOSE c_dj_txn;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.check_qty_dj',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION

  WHEN fnd_api.g_exc_unexpected_error THEN
    IF(c_dj_txn%ISOPEN) THEN
      CLOSE c_dj_txn;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.check_qty_dj',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    IF(c_dj_txn%ISOPEN) THEN
      CLOSE c_dj_txn;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.check_qty_dj',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END check_qty_dj;

/*****************************************************************************
 * This procedure is equivalent to witvemp_move_profile in wiltve.ppc
 * This procedure is used to get move profile
 ****************************************************************************/
PROCEDURE get_move_profile(p_gib       IN OUT NOCOPY group_rec_t,
                           x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_errMsg       VARCHAR2(240);
l_mv_item  NUMBER;
l_mv_lot   NUMBER;
l_po_item  NUMBER;
l_po_lot   NUMBER;
l_completion   NUMBER;
l_return       NUMBER;
l_move         move_profile_rec_t;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- initialize l_move
  l_move := p_gib.move_profile;

  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    l_params(3).paramName   := 'p_move_mode';
    l_params(3).paramValue  :=  p_gib.move_mode;
    l_params(4).paramName   := 'org_id';
    l_params(4).paramValue  :=  l_move.org_id;
    l_params(5).paramName   := 'wip_id';
    l_params(5).paramValue  :=  l_move.wip_id;
    l_params(6).paramName   := 'fmOp';
    l_params(6).paramValue  :=  l_move.fmOp;
    l_params(7).paramName   := 'fmStep';
    l_params(7).paramValue  :=  l_move.fmStep;
    l_params(8).paramName   := 'toOp';
    l_params(8).paramValue  :=  l_move.toOp;
    l_params(9).paramName   := 'toStep';
    l_params(9).paramValue  :=  l_move.toStep;
    l_params(10).paramName  := 'scrapTxn';
    l_params(10).paramValue :=  l_move.scrapTxn;
    l_params(11).paramName  := 'easyComplete';
    l_params(11).paramValue :=  l_move.easyComplete;
    l_params(12).paramName  := 'easyReturn';
    l_params(12).paramValue :=  l_move.easyReturn;
    l_params(13).paramName  := 'jobTxn';
    l_params(13).paramValue :=  l_move.jobTxn;
    l_params(14).paramName  := 'scheTxn';
    l_params(14).paramValue :=  l_move.scheTxn;
    l_params(15).paramName  := 'rsrcItem';
    l_params(15).paramValue :=  l_move.rsrcItem;
    l_params(16).paramName  := 'rsrcLot';
    l_params(16).paramValue :=  l_move.rsrcLot;
    l_params(17).paramName  := 'poReqItem';
    l_params(17).paramValue :=  l_move.poReqItem;
    l_params(18).paramName  := 'poRegLot';
    l_params(18).paramValue :=  l_move.poReqLot;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.get_move_profile',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  IF(p_gib.move_mode = WIP_CONSTANTS.ONLINE) THEN

    /* Fix for FP bug 5246228 base bug 5227706:
     *  Modified following query to consider autocharge
     *  resources in previous operation for overcompletion cases */
    SELECT SUM(DECODE(basis_type,1,DECODE(autocharge_type,1,1,0),0)),
           SUM(DECODE(basis_type,2,DECODE(autocharge_type,1,1,0),0)),
           SUM(DECODE(to_intraoperation_step_type,1,DECODE(basis_type,1,
             DECODE(autocharge_type,3,1,4,1,0),0))),
           SUM(DECODE(to_intraoperation_step_type,1,DECODE(basis_type,2,
             DECODE(autocharge_type,3,1,4,1,0),0)))
      INTO l_mv_item,
           l_mv_lot,
           l_po_item,
           l_po_lot
      FROM wip_move_txn_interface wmti,
           wip_operation_resources wor
     WHERE wmti.transaction_id = p_gib.group_id
       AND wmti.group_id = p_gib.group_id
       AND wor.organization_id = l_move.org_id
       AND wor.wip_entity_id = l_move.wip_id
       AND ((wmti.overcompletion_primary_qty IS NULL
             AND (wor.operation_seq_num BETWEEN l_move.fmOp AND l_move.toOp
                 OR
                 wor.operation_seq_num BETWEEN l_move.toOp AND l_move.fmOp))
            OR wor.operation_seq_num <= l_move.toOp);
            /* Fix for Bug#5552530, which is an FP of Bug#5509016.
               Changed < to <= in above condition */

  ELSE   -- move_mode is background

    SELECT SUM(DECODE(transaction_type, WIP_CONSTANTS.COMP_TXN, 1, 0)),
           SUM(DECODE(transaction_type, WIP_CONSTANTS.RET_TXN, 1, 0))
      INTO l_completion,
           l_return
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = p_gib.group_id
       AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
       AND wmti.process_status = WIP_CONSTANTS.RUNNING;

    -- set completion and return flag
    IF(l_completion > 0) THEN
      l_move.easyComplete := WIP_CONSTANTS.YES;
    ELSE
      l_move.easyComplete := WIP_CONSTANTS.NO;
    END IF;

    IF(l_return > 0) THEN
      l_move.easyReturn := WIP_CONSTANTS.YES;
    ELSE
      l_move.easyReturn := WIP_CONSTANTS.NO;
    END IF;
    /* Fix for bug 3902908: Added hints as per suggestion of appsperf team. */
    /* Fix for FP bug 5246228 base bug 5227706: Modified following query to consider autocharge
       resources in previous operation for overcompletion cases */
    SELECT /*+ leading(wti) use_nl(wti wor) index(wor WIP_OPERATION_RESOURCES_U1) */
           SUM(DECODE(basis_type,1,DECODE(autocharge_type,1,1,0),0)),
           SUM(DECODE(basis_type,2,DECODE(autocharge_type,1,1,0),0)),
           SUM(DECODE(to_intraoperation_step_type,1,DECODE(basis_type,1,
             DECODE(autocharge_type,3,1,4,1,0),0))),
           SUM(DECODE(to_intraoperation_step_type,1,DECODE(basis_type,2,
             DECODE(autocharge_type,3,1,4,1,0),0)))
      INTO l_mv_item,
           l_mv_lot,
           l_po_item,
           l_po_lot
      FROM wip_move_txn_interface wmti,
           wip_operation_resources wor
     WHERE wmti.group_id = p_gib.group_id
       AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
       AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
       AND wmti.process_status = WIP_CONSTANTS.RUNNING
       AND wor.organization_id = wmti.organization_id
       AND wor.wip_entity_id = wmti.wip_entity_id
       AND ((wmti.overcompletion_primary_qty IS NULL
             AND (wor.operation_seq_num BETWEEN wmti.fm_operation_seq_num
                    AND wmti.to_operation_seq_num
                  OR
                  wor.operation_seq_num BETWEEN wmti.to_operation_seq_num
                    AND wmti.fm_operation_seq_num))
            OR wor.operation_seq_num <= wmti.to_operation_seq_num);
            /* Fix for Bug#5552530, which is an FP of Bug#5509016.
               Changed < to <= in above condition */

  END IF; -- move_mode is online

  -- set the rest of move_profile flag
  IF(l_mv_item > 0) THEN -- auto resource per item
    l_move.rsrcItem :=  WIP_CONSTANTS.YES;
  ELSE
    l_move.rsrcItem :=  WIP_CONSTANTS.NO;
  END IF;

  IF(l_mv_lot > 0) THEN -- auto resource per lot
    l_move.rsrcLot :=  WIP_CONSTANTS.YES;
  ELSE
    l_move.rsrcLot :=  WIP_CONSTANTS.NO;
  END IF;

  IF(l_po_item > 0) THEN  -- po requisition per item
    l_move.poReqItem :=  WIP_CONSTANTS.YES;
  ELSE
    l_move.poReqItem :=  WIP_CONSTANTS.NO;
  END IF;

  IF(l_po_lot > 0) THEN  -- po requisition per lot
    l_move.poReqLot :=  WIP_CONSTANTS.YES;
  ELSE
    l_move.poReqLot :=  WIP_CONSTANTS.NO;
  END IF;

  -- return move profile back
  p_gib.move_profile := l_move;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.get_move_profile',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.get_move_profile',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END get_move_profile;

/*****************************************************************************
 * This procedure is equivalent to witpsth_txn_history in wiltps5.ppc
 * This procedure is used to insert history move records into
 * WIP_MOVE_TRANSACTIONS.
 ****************************************************************************/
PROCEDURE insert_txn_history(p_gib           IN        group_rec_t,
                             x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_msg          VARCHAR(240);
l_errMsg       VARCHAR2(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.insert_txn_history',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- insert history serial move record into WIP_SERIAL_MOVE_TRANSACTIONS
  INSERT INTO wip_serial_move_transactions
         (transaction_id,
          assembly_serial_number,
          creation_date,
          created_by,
          created_by_name,
          last_update_date,
          last_updated_by,
          last_updated_by_name,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          -- Add this column for OSFM serial support project.
          gen_object_id
          )
          SELECT wsmi.transaction_id,
                 wsmi.assembly_serial_number,
                 wsmi.creation_date,
                 wsmi.created_by,
                 wsmi.created_by_name,
                 wsmi.last_update_date,
                 wsmi.last_updated_by,
                 wsmi.last_updated_by_name,
                 wsmi.last_update_login,
                 wsmi.request_id,
                 wsmi.program_application_id,
                 wsmi.program_id,
                 wsmi.program_update_date,
                 -- Add this column for OSFM serial support project.
                 wsmi.gen_object_id
            FROM wip_serial_move_interface wsmi,
                 wip_move_txn_interface wmti
           WHERE wsmi.transaction_id = wmti.transaction_id
             AND wmti.group_id = p_gib.group_id
             AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
             AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
             AND wmti.process_status = WIP_CONSTANTS.RUNNING;

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'WIP_SERIAL_MOVE_TRANSACTIONS');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  -- insert history move record into WIP_MOVE_TRANSACTIONS
  -- Discrete/OSFM
  INSERT INTO wip_move_transactions
         (transaction_id,
          last_updated_by,
          last_update_date,
          last_update_login,
          created_by,
          creation_date,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          group_id,
          source_code,
          source_line_id,
          organization_id,
          wip_entity_id,
          primary_item_id,
          line_id,
          transaction_date,
          acct_period_id,
          fm_operation_seq_num,
          fm_operation_code,
          fm_department_id,
          fm_intraoperation_step_type,
          to_operation_seq_num,
          to_operation_code,
          to_department_id,
          to_intraoperation_step_type,
          transaction_quantity,
          transaction_uom,
          primary_quantity,
          primary_uom,
          reason_id,
          reference,
          scrap_account_id,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          qa_collection_id,
          overcompletion_transaction_qty,
          overcompletion_primary_qty,
          overcompletion_transaction_id,
          job_quantity_snapshot,
          batch_id,
          employee_id,
          completed_instructions
          )
          SELECT wmti.transaction_id,
                 wmti.last_updated_by,  -- last_updated_by --Fix for bug 5195072
                 SYSDATE,       -- last_update_date
                 DECODE(p_gib.login_id,
                   -1,NULL,p_gib.login_id), -- last_update_login
                 wmti.created_by,    -- created_by  --Fix for bug 5195072
                 SYSDATE,       -- creation_date
                 DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                 DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                 DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                 DECODE(p_gib.request_id,
                   -1,NULL,SYSDATE), -- program_update_date
                 p_gib.group_id,
                 wmti.source_code,
                 wmti.source_line_id,
                 wmti.organization_id,
                 wmti.wip_entity_id,
                 wmti.primary_item_id,
                 wmti.line_id,
                 wmti.transaction_date,
                 wmti.acct_period_id,
                 wmti.fm_operation_seq_num,
                 wmti.fm_operation_code,
                 wmti.fm_department_id,
                 wmti.fm_intraoperation_step_type,
                 wmti.to_operation_seq_num,
                 wmti.to_operation_code,
                 wmti.to_department_id,
                 wmti.to_intraoperation_step_type,
                 wmti.transaction_quantity,
                 wmti.transaction_uom,
                 wmti.primary_quantity,
                 wmti.primary_uom,
                 wmti.reason_id,
                 wmti.reference,
                 wmti.scrap_account_id,
                 wmti.attribute_category,
                 wmti.attribute1,
                 wmti.attribute2,
                 wmti.attribute3,
                 wmti.attribute4,
                 wmti.attribute5,
                 wmti.attribute6,
                 wmti.attribute7,
                 wmti.attribute8,
                 wmti.attribute9,
                 wmti.attribute10,
                 wmti.attribute11,
                 wmti.attribute12,
                 wmti.attribute13,
                 wmti.attribute14,
                 wmti.attribute15,
                 wmti.qa_collection_id,
                 wmti.overcompletion_transaction_qty,
                 wmti.overcompletion_primary_qty,
                 wmti.overcompletion_transaction_id,
                 wdj.start_quantity,
                 wmti.batch_id,
                 wmti.employee_id,
                 wmti.completed_instructions
            FROM wip_move_txn_interface wmti,
                 wip_discrete_jobs wdj
           WHERE wmti.group_id = p_gib.group_id
             AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
             AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
             AND wmti.process_status = WIP_CONSTANTS.RUNNING
             AND wmti.entity_type IN (WIP_CONSTANTS.DISCRETE,
                                      WIP_CONSTANTS.LOTBASED)
             AND wdj.wip_entity_id = wmti.wip_entity_id
             AND wdj.organization_id = wmti.organization_id;

   -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'WIP_MOVE_TRANSACTIONS');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  -- Repetitive Schedule
  INSERT INTO wip_move_transactions
         (transaction_id,
          last_updated_by,
          last_update_date,
          last_update_login,
          created_by,
          creation_date,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          group_id,
          source_code,
          source_line_id,
          organization_id,
          wip_entity_id,
          primary_item_id,
          line_id,
          transaction_date,
          acct_period_id,
          fm_operation_seq_num,
          fm_operation_code,
          fm_department_id,
          fm_intraoperation_step_type,
          to_operation_seq_num,
          to_operation_code,
          to_department_id,
          to_intraoperation_step_type,
          transaction_quantity,
          transaction_uom,
          primary_quantity,
          primary_uom,
          reason_id,
          reference,
          scrap_account_id,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          qa_collection_id,
          overcompletion_transaction_qty,
          overcompletion_primary_qty,
          overcompletion_transaction_id
          )
          SELECT wmti.transaction_id,
                 wmti.last_updated_by,  -- last_updated_by --Fix for bug 5195072
                 SYSDATE,       -- last_update_date
                 DECODE(p_gib.login_id,
                   -1,NULL,p_gib.login_id), -- last_update_login
                 wmti.created_by,    -- created_by --Fix for bug 5195072
                 SYSDATE,       -- creation_date
                 DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                 DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                 DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                 DECODE(p_gib.request_id,
                   -1,NULL,SYSDATE), -- program_update_date
                 p_gib.group_id,
                 wmti.source_code,
                 wmti.source_line_id,
                 wmti.organization_id,
                 wmti.wip_entity_id,
                 wmti.primary_item_id,
                 wmti.line_id,
                 wmti.transaction_date,
                 wmti.acct_period_id,
                 wmti.fm_operation_seq_num,
                 wmti.fm_operation_code,
                 wmti.fm_department_id,
                 wmti.fm_intraoperation_step_type,
                 wmti.to_operation_seq_num,
                 wmti.to_operation_code,
                 wmti.to_department_id,
                 wmti.to_intraoperation_step_type,
                 wmti.transaction_quantity,
                 wmti.transaction_uom,
                 wmti.primary_quantity,
                 wmti.primary_uom,
                 wmti.reason_id,
                 wmti.reference,
                 wmti.scrap_account_id,
                 wmti.attribute_category,
                 wmti.attribute1,
                 wmti.attribute2,
                 wmti.attribute3,
                 wmti.attribute4,
                 wmti.attribute5,
                 wmti.attribute6,
                 wmti.attribute7,
                 wmti.attribute8,
                 wmti.attribute9,
                 wmti.attribute10,
                 wmti.attribute11,
                 wmti.attribute12,
                 wmti.attribute13,
                 wmti.attribute14,
                 wmti.attribute15,
                 wmti.qa_collection_id,
                 wmti.overcompletion_transaction_qty,
                 wmti.overcompletion_primary_qty,
                 wmti.overcompletion_transaction_id
            FROM wip_move_txn_interface wmti
           WHERE wmti.group_id = p_gib.group_id
             AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
             AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
             AND wmti.process_status = WIP_CONSTANTS.RUNNING
             AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE;

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'WIP_MOVE_TRANSACTIONS');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_txn_history',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_txn_history',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END insert_txn_history;

/*****************************************************************************
 * This procedure is equivalent to witoc_delete_child in wiltps5.ppc
 * This procedure is used to delete child record from WIP_MOVE_TXN_INTERFACE
 * table where the child rows have fm_op and to_op to be the first operation
 * and the step types to be Queue
 ****************************************************************************/
PROCEDURE delete_child_txn(p_gib           IN        group_rec_t,
                           x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_errMsg       VARCHAR2(240);
l_outcome      NUMBER := -1;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.delete_child_txn',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- delete child records from WIP
  DELETE FROM wip_move_txn_interface wmti
         WHERE wmti.group_id = p_gib.group_id
           AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
           AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
           AND wmti.process_status = WIP_CONSTANTS.RUNNING
           AND wmti.overcompletion_transaction_id IS NOT NULL
           AND wmti.overcompletion_primary_qty IS NULL
           AND wmti.fm_operation_seq_num = wmti.to_operation_seq_num
           AND wmti.fm_intraoperation_step_type =
               wmti.to_intraoperation_step_type
           AND wmti.fm_intraoperation_step_type = WIP_CONSTANTS.QUEUE;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.delete_child_txn',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.delete_child_txn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END delete_child_txn;

/*****************************************************************************
 * This procedure is equivalent to witpsar_auto_resources in wiltps2.ppc
 * This procedure is used to insert auto-resources associated with move txn
 * This procedure insert the record into WIP_COST_TXN_INTERFACE and
 * WIP_TXN_ALLOCATIONS IF needed
 ****************************************************************************/
PROCEDURE insert_auto_resource(p_gib           IN        group_rec_t,
                               x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_msg          VARCHAR(240);
l_errMsg       VARCHAR2(240);
l_move         move_profile_rec_t;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  l_move := p_gib.move_profile;

  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    l_params(3).paramName   := 'org_id';
    l_params(3).paramValue  :=  l_move.org_id;
    l_params(4).paramName   := 'wip_id';
    l_params(4).paramValue  :=  l_move.wip_id;
    l_params(5).paramName   := 'fmOp';
    l_params(5).paramValue  :=  l_move.fmOp;
    l_params(6).paramName   := 'fmStep';
    l_params(6).paramValue  :=  l_move.fmStep;
    l_params(7).paramName   := 'toOp';
    l_params(7).paramValue  :=  l_move.toOp;
    l_params(8).paramName   := 'toStep';
    l_params(8).paramValue  :=  l_move.toStep;
    l_params(9).paramName   := 'scrapTxn';
    l_params(9).paramValue  :=  l_move.scrapTxn;
    l_params(10).paramName  := 'easyComplete';
    l_params(10).paramValue :=  l_move.easyComplete;
    l_params(11).paramName  := 'easyReturn';
    l_params(11).paramValue :=  l_move.easyReturn;
    l_params(12).paramName  := 'jobTxn';
    l_params(12).paramValue :=  l_move.jobTxn;
    l_params(13).paramName  := 'scheTxn';
    l_params(13).paramValue :=  l_move.scheTxn;
    l_params(14).paramName  := 'rsrcItem';
    l_params(14).paramValue :=  l_move.rsrcItem;
    l_params(15).paramName  := 'rsrcLot';
    l_params(15).paramValue :=  l_move.rsrcLot;
    l_params(16).paramName  := 'poReqItem';
    l_params(16).paramValue :=  l_move.poReqItem;
    l_params(17).paramName  := 'poRegLot';
    l_params(17).paramValue :=  l_move.poReqLot;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.insert_auto_resource',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- Per item basis type for discrete jobs
  IF(l_move.jobTxn = WIP_CONSTANTS.YES AND
     l_move.rsrcItem = WIP_CONSTANTS.YES) THEN
    /* Fix for bug 4036149: Added leading hint to drive from the table
     wip_move_txn_interface to improve performance */
    INSERT INTO wip_cost_txn_interface
      (transaction_id,
       last_update_date,
       last_updated_by,
       last_updated_by_name,
       creation_date,
       created_by,
       created_by_name,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       group_id,
       source_code,
       source_line_id,
       process_phase,
       process_status,
       transaction_type,
       organization_id,
       organization_code,
       wip_entity_id,
       entity_type,
       primary_item_id,
       line_id,
       line_code,
       transaction_date,
       acct_period_id,
       operation_seq_num,
       department_id,
       department_code,
       employee_id,
       resource_seq_num,
       resource_id,
       resource_code,
       phantom_flag,
       usage_rate_or_amount,
       basis_type,
       autocharge_type,
       standard_rate_flag,
       transaction_quantity,
       transaction_uom,
       primary_quantity,
       primary_uom,
       actual_resource_rate,
       activity_id,
       activity_name,
       reason_id,
       reason_name,
       reference,
       move_transaction_id,
       po_header_id,
       po_line_id,
       repetitive_schedule_id,
       project_id,
       task_id
       )
       SELECT /*+ leading(wmti) */
              NULL,                     -- transaction_id
              SYSDATE,                  -- last_update_date
              wmti.last_updated_by,      -- last_updated_by --Fix for bug 5195072
              wmti.last_updated_by_name, -- last_updated_by_name --fix for bug 5195072
              SYSDATE,                  -- creation_date
              wmti.created_by,           -- created_by --Fix for bug 5195072
              wmti.created_by_name,      -- created_by_name --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE),  -- program_update_date
              p_gib.group_id,
              wmti.source_code,
              wmti.source_line_id,
              WIP_CONSTANTS.RES_PROC,   -- process_phase
              WIP_CONSTANTS.PENDING,    -- process_status
              WIP_CONSTANTS.RES_TXN,    -- transaction_type
              wmti.organization_id,
              wmti.organization_code,
              wmti.wip_entity_id,
              wmti.entity_type,
              wmti.primary_item_id,
              wmti.line_id,
              wmti.line_code,
              wmti.transaction_date,
              wmti.acct_period_id,
              wop.operation_seq_num,
              NVL(wor.department_id, wop.department_id),
              bd.department_code,
              NULL,                      -- employee_id
              wor.resource_seq_num,
              wor.resource_id,
              br.resource_code,
              wor.phantom_flag,
              wor.usage_rate_or_amount,
              wor.basis_type,
              wor.autocharge_type,
              wor.standard_rate_flag,
              wor.usage_rate_or_amount * NVL(wmti.primary_quantity *
                DECODE(
                  SIGN(wmti.to_operation_seq_num - wmti.fm_operation_seq_num),
                  0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),
                    0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                   -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                    1,-1),
                  1, 1,
                 -1,-1),
                0),                      -- transaction_quantity
              wor.uom_code,              -- transaction_uom
              wor.usage_rate_or_amount * NVL(wmti.primary_quantity *
                DECODE(
                  SIGN(wmti.to_operation_seq_num - wmti.fm_operation_seq_num),
                  0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),
                    0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                   -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                    1,-1),
                  1, 1,
                 -1,-1),
                0),                      -- primary_quantity
              wor.uom_code,              -- primary_uom
              NULL,                      -- actual_resource_rate
              wor.activity_id,
              ca.activity,               -- activity_name
              wmti.reason_id,
              wmti.reason_name,
              wmti.reference,
              wmti.transaction_id,        -- move_transaction_id
              NULL,                      -- po_header_id
              NULL,                      -- po_line_id
              NULL,                      -- repetitive_schedule_id
              wdj.project_id,
              wdj.task_id
         FROM bom_departments bd,
              bom_resources br,
              cst_activities ca,
              wip_operation_resources wor,
              wip_discrete_jobs wdj,
              wip_operations wop,
              wip_move_txn_interface wmti
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
               OR wmti.entity_type = WIP_CONSTANTS.LOTBASED) /* WSM */
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wop.organization_id = wor.organization_id
          AND wop.wip_entity_id = wor.wip_entity_id
          AND wop.operation_seq_num = wor.operation_seq_num
          /* added for OSFM jump enhancement 2541431 */
          AND NVL(wop.skip_flag, WIP_CONSTANTS.NO) <> WIP_CONSTANTS.YES
          AND wor.autocharge_type = WIP_CONSTANTS.WIP_MOVE
          AND wor.basis_type = WIP_CONSTANTS.PER_ITEM
          AND wop.organization_id = bd.organization_id
          AND NVL(wor.department_id, wop.department_id) = bd.department_id
          AND wor.organization_id = br.organization_id
          AND wor.resource_id = br.resource_id
          AND wor.usage_rate_or_amount <> 0
          AND wor.activity_id = ca.activity_id (+)
          AND wdj.wip_entity_id = wmti.wip_entity_id
          AND wdj.organization_id = wmti.organization_id
          AND (
              (wop.operation_seq_num >= wmti.fm_operation_seq_num
               + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                             WIP_CONSTANTS.RUN), 1,1,0)
              AND wop.operation_seq_num < wmti.to_operation_seq_num
                + DECODE(SIGN(wmti.to_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                   OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.fm_operation_seq_num
                   OR (wop.operation_seq_num = wmti.to_operation_seq_num
                       AND wmti.to_intraoperation_step_type >
                           WIP_CONSTANTS.RUN)))
            OR
              (wop.operation_seq_num < wmti.fm_operation_seq_num
               + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                             WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num >= wmti.to_operation_seq_num
               + DECODE(SIGN(wmti.to_intraoperation_step_type -
                             WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                  OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR wop.operation_seq_num = wmti.to_operation_seq_num
                  OR (wop.operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type >
                          WIP_CONSTANTS.RUN)))
    );

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF; -- Per item basis type for discrete jobs

  -- Per item basis type for repetitive schedule
  IF(l_move.scheTxn = WIP_CONSTANTS.YES AND
     l_move.rsrcItem = WIP_CONSTANTS.YES) THEN

    INSERT INTO wip_cost_txn_interface
      (transaction_id,
       last_update_date,
       last_updated_by,
       last_updated_by_name,
       creation_date,
       created_by,
       created_by_name,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       group_id,
       source_code,
       source_line_id,
       process_phase,
       process_status,
       transaction_type,
       organization_id,
       organization_code,
       wip_entity_id,
       entity_type,
       primary_item_id,
       line_id,
       line_code,
       transaction_date,
       acct_period_id,
       operation_seq_num,
       department_id,
       department_code,
       employee_id,
       resource_seq_num,
       resource_id,
       resource_code,
       phantom_flag,
       usage_rate_or_amount,
       basis_type,
       autocharge_type,
       standard_rate_flag,
       transaction_quantity,
       transaction_uom,
       primary_quantity,
       primary_uom,
       actual_resource_rate,
       activity_id,
       activity_name,
       reason_id,
       reason_name,
       reference,
       move_transaction_id,
       po_header_id,
       po_line_id,
       repetitive_schedule_id
       )
       SELECT NULL,                          -- transaction_id
              SYSDATE,                       -- last_update_date
              MAX(wmti.last_updated_by),      -- last_updated_by --Fix for bug 5195072
              MAX(wmti.last_updated_by_name), -- last_updated_by_name --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              MAX(wmti.created_by),           -- created_by -- Fix for bug 5195072
              MAX(wmti.created_by_name),      -- created_by_name --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              p_gib.group_id,
              MAX(wmti.source_code),
              MAX(wmti.source_line_id),
              WIP_CONSTANTS.RES_PROC,        -- process_phase
              WIP_CONSTANTS.PENDING,         -- process_status
              WIP_CONSTANTS.RES_TXN,         -- transaction_type
              wmti.organization_id,
              MAX(wmti.organization_code),
              wmti.wip_entity_id,
              MAX(wmti.entity_type),
              MAX(wmti.primary_item_id),
              wmti.line_id,
              MAX(wmti.line_code),
              MAX(wmti.transaction_date),
              MAX(wmti.acct_period_id),
              wop.operation_seq_num,
              NVL(MAX(wor.department_id), MAX(wop.department_id)),
              MAX(bd.department_code),
              NULL,                           -- employee_id
              wor.resource_seq_num,
              wor.resource_id,
              MAX(br.resource_code),
              MAX(wor.phantom_flag),
              wor.usage_rate_or_amount,
              MAX(wor.basis_type),
              MAX(wor.autocharge_type),
              wor.standard_rate_flag,
              SUM(wor.usage_rate_or_amount * NVL(wma.primary_quantity *
                DECODE(
                  SIGN(wmti.to_operation_seq_num-wmti.fm_operation_seq_num),
                  0, DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),
                    0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                   -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                    1,-1),
                  1, 1,
                 -1,-1)
                ,0)),                       -- transaction_quantity
              MAX(wor.uom_code),            -- transaction_uom
              SUM(wor.usage_rate_or_amount * NVL(wma.primary_quantity *
                DECODE(
                  SIGN(wmti.to_operation_seq_num-wmti.fm_operation_seq_num),
                  0, DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),
                    0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                   -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                    1,-1),
                  1, 1,
                 -1,-1)
                ,0)),                        -- primary_quantity
              MAX(wor.uom_code),             -- primary_uom
              NULL,                          -- acutual_resource_rate
              wor.activity_id,
              MAX(ca.activity),              -- activity_name
              MAX(wmti.reason_id),
              MAX(wmti.reason_name),
              MAX(wmti.reference),
              MAX(wmti.transaction_id),       -- move_transaction_id
              NULL,                          -- po_header_id
              NULL,                          -- po_line_id
              NULL                           -- repetitive_schedule_id
         FROM bom_departments bd,
              bom_resources br,
              cst_activities ca,
              wip_operation_resources wor,
              wip_move_txn_allocations wma,
              wip_operations wop,
              wip_move_txn_interface wmti
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wop.wip_entity_id = wor.wip_entity_id
          AND wop.operation_seq_num = wor.operation_seq_num
          AND wop.organization_id = wor.organization_id
          AND wop.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wor.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wmti.organization_id = wma.organization_id
          AND wmti.transaction_id = wma.transaction_id
          AND wor.autocharge_type = WIP_CONSTANTS.WIP_MOVE
          AND wor.basis_type = WIP_CONSTANTS.PER_ITEM
          AND wop.organization_id = bd.organization_id
          AND NVL(wor.department_id, wop.department_id) = bd.department_id
          AND wor.organization_id = br.organization_id
          AND wor.resource_id = br.resource_id
          AND wor.usage_rate_or_amount <> 0
          AND wor.activity_id = ca.activity_id (+)
          AND (
              (wop.operation_seq_num >= wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num < wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                   OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.fm_operation_seq_num
                   OR (wop.operation_seq_num = wmti.to_operation_seq_num
                       AND wmti.to_intraoperation_step_type >
                           WIP_CONSTANTS.RUN)))
            OR
              (wop.operation_seq_num < wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num >= wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                  OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR wop.operation_seq_num = wmti.to_operation_seq_num
                  OR (wop.operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type >
                          WIP_CONSTANTS.RUN))))
     GROUP BY wmti.organization_id,
              wmti.wip_entity_id,
              wmti.line_id,
              wop.operation_seq_num,
              wor.resource_seq_num,
              wor.resource_id,
              wor.activity_id,
              wor.standard_rate_flag,
              wor.usage_rate_or_amount,
              wmti.transaction_id;

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF;  -- Per item basis type for repetitive schedule

   /*------------------------------------------------------------+
   |  Per order basis type for discrete jobs
      department_id cannot be changed so we can take the MAX,
      also columns such as usage_rate_or_amount are not part of
      the transaction they are looked up in wip_operation_resources
   +------------------------------------------------------------*/
  IF(l_move.jobTxn = WIP_CONSTANTS.YES AND
     l_move.rsrcLot = WIP_CONSTANTS.YES) THEN

    INSERT INTO wip_cost_txn_interface
      (transaction_id,
       last_update_date,
       last_updated_by,
       last_updated_by_name,
       creation_date,
       created_by,
       created_by_name,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       group_id,
       source_code,
       source_line_id,
       process_phase,
       process_status,
       transaction_type,
       organization_id,
       organization_code,
       wip_entity_id,
       entity_type,
       primary_item_id,
       line_id,
       line_code,
       transaction_date,
       acct_period_id,
       operation_seq_num,
       department_id,
       department_code,
       employee_id,
       resource_seq_num,
       resource_id,
       resource_code,
       phantom_flag,
       usage_rate_or_amount,
       basis_type,
       autocharge_type,
       standard_rate_flag,
       transaction_quantity,
       transaction_uom,
       primary_quantity,
       primary_uom,
       actual_resource_rate,
       activity_id,
       activity_name,
       reason_id,
       reason_name,
       reference,
       move_transaction_id,
       po_header_id,
       po_line_id,
       repetitive_schedule_id,
       project_id,
       task_id
       )
       SELECT NULL,                          -- transaction_id
              SYSDATE,                       -- last_update_date
              MAX(wmti.last_updated_by),      -- last_updated_by --Fix for bug 5195072
              MAX(wmti.last_updated_by_name), -- last_updated_by_name --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              MAX(wmti.created_by),           -- created_by --Fix for bug 5195072
              MAX(wmti.created_by_name),      -- created_by_name --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              p_gib.group_id,
              MAX(wmti.source_code),          -- source_code
              -- Fixed bug 2465148
              MAX(wmti.source_line_id),       -- source_line_id
              WIP_CONSTANTS.RES_PROC,        -- process_phase
              WIP_CONSTANTS.PENDING,         -- process_status
              WIP_CONSTANTS.RES_TXN,         -- transaction_type
              wop.organization_id,
              MAX(wmti.organization_code),
              wop.wip_entity_id,
              MAX(entity_type),
              MAX(wmti.primary_item_id),
              MAX(wmti.line_id),
              MAX(wmti.line_code),
              MAX(wmti.transaction_date),
              MAX(wmti.acct_period_id),
              wop.operation_seq_num,
              NVL(MAX(wor.department_id), MAX(wop.department_id)),
              MAX(bd.department_code),
              NULL,                          -- employee_id
              wor.resource_seq_num,
              MAX(wor.resource_id),
              MAX(br.resource_code),
              MAX(wor.phantom_flag),
              MAX(wor.usage_rate_or_amount),
              MAX(wor.basis_type),
              MAX(wor.autocharge_type),
              MAX(wor.standard_rate_flag),
              MAX(wor.usage_rate_or_amount) * -- transaction_quantity
                DECODE(SIGN(MAX(wop.quantity_completed) +
                                NVL(SUM(wmti.primary_quantity *
                  DECODE(SIGN(wmti.to_operation_seq_num -
                              wmti.fm_operation_seq_num),
                  0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),
                    0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                    WIP_CONSTANTS.RUN),1,1,-1),
                    -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                    WIP_CONSTANTS.RUN),1,1,-1),
                    1,-1),
                  1, 1,
                 -1,-1)
                 ),0)),   -- NVL
                0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
                1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
               -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0)),
              MAX(wor.uom_code),              -- transaction_uom
              MAX(wor.usage_rate_or_amount) * -- primary_quantity
                DECODE(SIGN(MAX(wop.quantity_completed) +
                                NVL(SUM(wmti.primary_quantity *
                  DECODE(SIGN(wmti.to_operation_seq_num -
                              wmti.fm_operation_seq_num),
                  0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),
                    0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                    WIP_CONSTANTS.RUN),1,1,-1),
                    -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                    WIP_CONSTANTS.RUN),1,1,-1),
                    1,-1),
                  1, 1,
                 -1,-1)
                 ),0)),   -- NVL
                0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
                1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
               -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0)),
              MAX(wor.uom_code),               -- primary_uom
              NULL,                            -- actual_resource_rate
              MAX(wor.activity_id),
              MAX(ca.activity),                -- activity_name
              NULL,                            -- reason_id
              NULL,                            -- reason_name
              -- Fixed bug 2506653
              MAX(wmti.reference),              -- reference
              MAX(wmti.transaction_id),         -- move_transaction_id
              NULL,                            -- po_header_id
              NULL,                            -- po_line_id
              NULL,                            -- repetitive_schedule_id
              MAX(wdj.project_id),
              MAX(wdj.task_id)
         FROM bom_departments bd,
              bom_resources br,
              cst_activities ca,
              wip_operation_resources wor,
              wip_discrete_jobs wdj,
              wip_operations wop,
              wip_move_txn_interface wmti
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
               OR wmti.entity_type = WIP_CONSTANTS.LOTBASED) /* WSM */
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wop.wip_entity_id = wor.wip_entity_id
          AND wop.operation_seq_num = wor.operation_seq_num
          /* added for OSFM jump enhancement 2541431 */
          AND NVL(wop.skip_flag, WIP_CONSTANTS.NO) <> WIP_CONSTANTS.YES
          AND wop.organization_id = wor.organization_id
          AND wor.autocharge_type = WIP_CONSTANTS.WIP_MOVE
          AND wor.basis_type = WIP_CONSTANTS.PER_LOT
          AND wop.organization_id = bd.organization_id
          AND NVL(wor.department_id, wop.department_id) = bd.department_id
          AND wor.organization_id = br.organization_id
          AND wor.resource_id = br.resource_id
          AND wor.usage_rate_or_amount <> 0
          AND wor.activity_id = ca.activity_id (+)
          AND wdj.wip_entity_id = wmti.wip_entity_id
          AND wdj.organization_id = wmti.organization_id
          AND (
              (wop.operation_seq_num >= wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num < wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                   OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.fm_operation_seq_num
                   OR (wop.operation_seq_num = wmti.to_operation_seq_num
                       AND wmti.to_intraoperation_step_type >
                           WIP_CONSTANTS.RUN)))
            OR
              (wop.operation_seq_num < wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num >= wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                  OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR wop.operation_seq_num = wmti.to_operation_seq_num
                  OR (wop.operation_seq_num = wmti.fm_operation_seq_num
                     AND wmti.fm_intraoperation_step_type >
                         WIP_CONSTANTS.RUN))))
     GROUP BY wop.organization_id,
              wop.wip_entity_id,
              wop.operation_seq_num,
              wor.resource_seq_num
       HAVING 0 <>
              DECODE(SIGN(MAX(wop.quantity_completed) +
                              NVL(SUM(wmti.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
                ),0)),    -- NVL
              0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
              1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
             -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0));

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF; -- Per order basis type for discrete jobs

  -- Per order basis type for repetitive
  IF(l_move.scheTxn = WIP_CONSTANTS.YES AND
     l_move.rsrcLot = WIP_CONSTANTS.YES) THEN

    INSERT INTO wip_cost_txn_interface
      (transaction_id,
       last_update_date,
       last_updated_by,
       last_updated_by_name,
       creation_date,
       created_by,
       created_by_name,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       group_id,
       source_code,
       source_line_id,
       process_phase,
       process_status,
       transaction_type,
       organization_id,
       organization_code,
       wip_entity_id,
       entity_type,
       primary_item_id,
       line_id,
       line_code,
       transaction_date,
       acct_period_id,
       operation_seq_num,
       department_id,
       department_code,
       employee_id,
       resource_seq_num,
       resource_id,
       resource_code,
       phantom_flag,
       usage_rate_or_amount,
       basis_type,
       autocharge_type,
       standard_rate_flag,
       transaction_quantity,
       transaction_uom,
       primary_quantity,
       primary_uom,
       actual_resource_rate,
       activity_id,
       activity_name,
       reason_id,
       reason_name,
       reference,
       move_transaction_id,
       po_header_id,
       po_line_id,
       repetitive_schedule_id
       )
       SELECT NULL,                          -- transaction_id
              SYSDATE,                       -- last_update_date
              MAX(wmti.last_updated_by),      -- last_updated_by --Fix for bug 5195072
              MAX(wmti.last_updated_by_name), -- last_updated_by_name --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              MAX(wmti.created_by),           -- created_by --Fix for bug 5195072
              MAX(wmti.created_by_name),      -- created_by_name --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              p_gib.group_id,
              MAX(wmti.source_code),          -- source_code
              -- Fixed bug 2465148
              MAX(wmti.source_line_id),       -- source_line_id
              WIP_CONSTANTS.RES_PROC,        -- process_phase
              WIP_CONSTANTS.PENDING,         -- process_status
              WIP_CONSTANTS.RES_TXN,         -- transaction_type
              wop.organization_id,
              MAX(wmti.organization_code),
              wop.wip_entity_id,
              MAX(entity_type),
              MAX(wmti.primary_item_id),
              wmti.line_id,
              MAX(wmti.line_code),
              MAX(wmti.transaction_date),
              MAX(wmti.acct_period_id),
              wop.operation_seq_num,
              NVL(MAX(wor.department_id), MAX(wop.department_id)),
              MAX(bd.department_code),
              NULL,                           -- employee_id
              wor.resource_seq_num,
              wor.resource_id,
              MAX(br.resource_code),
              MAX(wor.phantom_flag),
              wor.usage_rate_or_amount,
              MAX(wor.basis_type),
              MAX(wor.autocharge_type),
              wor.standard_rate_flag,
              1,                              -- transaction_quantity
              MAX(wor.uom_code),              -- transaction_uom
              1,                              -- primary_quantity
              MAX(wor.uom_code),              -- primary_uom
              NULL,                           -- actual_resource_rate
              wor.activity_id,
              MAX(ca.activity),               -- activity_name
              NULL,                           -- reason_id
              NULL,                           -- reason_name
              -- Fixed bug 2506653
              MAX(wmti.reference),             -- reference
              MAX(wmti.transaction_id),        -- move_transaction_id
              NULL,                           -- po_header_id
              NULL,                           -- po_line_id
              wma.repetitive_schedule_id
         FROM bom_departments bd,
              bom_resources br,
              cst_activities ca,
              wip_operation_resources wor,
              wip_move_txn_allocations wma,
              wip_operations wop,
              wip_move_txn_interface wmti
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wop.wip_entity_id = wor.wip_entity_id
          AND wop.operation_seq_num = wor.operation_seq_num
          AND wop.organization_id = wor.organization_id
          AND wop.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wor.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wmti.organization_id = wma.organization_id
          AND wmti.transaction_id = wma.transaction_id
          AND wor.autocharge_type = WIP_CONSTANTS.WIP_MOVE
          AND wor.basis_type = WIP_CONSTANTS.PER_LOT
          AND wop.organization_id = bd.organization_id
          AND NVL(wor.department_id, wop.department_id) = bd.department_id
          AND wor.organization_id = br.organization_id
          AND wor.resource_id = br.resource_id
          AND wor.usage_rate_or_amount <> 0
          AND wor.activity_id = ca.activity_id (+)
          AND (
              (wop.operation_seq_num >= wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num < wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                   OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.fm_operation_seq_num
                   OR (wop.operation_seq_num = wmti.to_operation_seq_num
                       AND wmti.to_intraoperation_step_type >
                           WIP_CONSTANTS.RUN)))
            OR
              (wop.operation_seq_num < wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num >= wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                  OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR wop.operation_seq_num = wmti.to_operation_seq_num
                  OR (wop.operation_seq_num = wmti.fm_operation_seq_num
                     AND wmti.fm_intraoperation_step_type >
                         WIP_CONSTANTS.RUN))))
     GROUP BY wop.organization_id,
              wop.wip_entity_id,
              wmti.line_id,
              wma.repetitive_schedule_id,
              wop.operation_seq_num,
              wor.resource_seq_num,
              wor.resource_id,
              wor.activity_id,
              wor.standard_rate_flag,
              wor.usage_rate_or_amount
       HAVING 0 <>
              DECODE(SIGN(MAX(wop.quantity_completed) + NVL(SUM(
                  wma.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                   0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),1,1,-1),
                  -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),1,1,-1),
                   1,-1),
                1, 1,
               -1,-1)
                ),0)),      -- NVL
              0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
              1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
             -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0));

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF; --  Per order basis type for repetitive

  -- IF resource per item or resource per lot, set transaction_id
  IF(l_move.rsrcItem = WIP_CONSTANTS.YES OR
     l_move.rsrcLot  = WIP_CONSTANTS.YES) THEN

   /*------------------------------------------------------------+
   |  Generate transaction_id for WIP_TXN_ALLOCATIONS     |
   +------------------------------------------------------------*/
   UPDATE wip_cost_txn_interface
      SET transaction_id = wip_transactions_s.nextval
    WHERE group_id = p_gib.group_id
      AND TRUNC(transaction_date) = TRUNC(p_gib.txn_date)
      AND transaction_type = WIP_CONSTANTS.RES_TXN;

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF;  -- Either resource per item or resource per lot

  -- Per order basis type for repetitive
  IF(l_move.scheTxn = WIP_CONSTANTS.YES AND
     l_move.rsrcLot = WIP_CONSTANTS.YES) THEN

   /*------------------------------------------------------------+
   |  Insert into cost allocations for repetitive schedules     |
   |  per lot
   +------------------------------------------------------------*/

  /*------------------------------------------------------------+
   |  Columns to insert into WIP_TXN_ALLOCATIONS                |
   |                                                            |
   |  transaction_id,                                           |
   |  repetitive_schedule_id, organization_id,                  |
   |  last_update_date, last_updated_by, creation_date,         |
   |  created_by, last_update_login, request_id,                |
   |  program_application_id, program_id, program_update_date,  |
   |  transaction_quantity,                                     |
   |  primary_quantity,                                         |
   |                                                            |
   +------------------------------------------------------------*/
    INSERT INTO wip_txn_allocations
     (transaction_id,
      repetitive_schedule_id,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      transaction_quantity,
      primary_quantity
      )
      SELECT wci.transaction_id,
             wma.repetitive_schedule_id,
             MAX(wmti.organization_id),
             SYSDATE,                      -- last_update_date
             MAX(wmti.last_updated_by),     -- last_updated_by --Fix for bug 5195072
             SYSDATE,                      -- creation_date
             MAX(wmti.created_by),          -- created_by --Fix for bug 5195072
             DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
             DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
             DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
             DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
             DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
             MAX(wor.usage_rate_or_amount) *       -- transaction_quantity
               DECODE(SIGN(MAX(wop.quantity_completed) +
                               NVL(SUM(wma.primary_quantity *
                 DECODE(SIGN(wmti.to_operation_seq_num -
                             wmti.fm_operation_seq_num),
                 0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                               WIP_CONSTANTS.RUN),
                   0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),1,1,-1),
                  -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),1,1,-1),
                   1,-1),
                 1, 1,
                -1,-1)
                ),0)),   -- NVL
               0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
               1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
              -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0)),
             MAX(wor.usage_rate_or_amount) *     -- primary_quantity
               DECODE(SIGN(MAX(wop.quantity_completed) +
                               NVL(SUM(wma.primary_quantity *
                 DECODE(SIGN(wmti.to_operation_seq_num -
                             wmti.fm_operation_seq_num),
                 0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                               WIP_CONSTANTS.RUN),
                   0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),1,1,-1),
                  -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),1,1,-1),
                   1,-1),
                 1, 1,
                -1,-1)
                ),0)),   -- NVL
               0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
               1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
              -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0))

        FROM wip_operation_resources wor,
             wip_operations wop,
             wip_move_txn_allocations wma,
             wip_cost_txn_interface wci,
             wip_move_txn_interface wmti
       WHERE wmti.group_id = p_gib.group_id
         AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
         AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
         AND wmti.process_status = WIP_CONSTANTS.RUNNING
         AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
         AND wmti.group_id = wci.group_id
         AND wci.organization_id = wmti.organization_id
         AND wci.wip_entity_id = wmti.wip_entity_id
         AND wci.operation_seq_num = wop.operation_seq_num
         AND wci.basis_type = WIP_CONSTANTS.PER_LOT
         AND wci.transaction_type = WIP_CONSTANTS.RES_TXN
         AND wop.repetitive_schedule_id = wor.repetitive_schedule_id
         AND wci.organization_id = wor.organization_id
         AND wci.wip_entity_id = wor.wip_entity_id
         AND wci.operation_seq_num = wor.operation_seq_num
         AND wci.resource_seq_num = wor.resource_seq_num
         AND wci.resource_id = wor.resource_id
         AND wci.standard_rate_flag = wor.standard_rate_flag
         AND wci.usage_rate_or_amount = wor.usage_rate_or_amount
         AND NVL(wci.activity_id, -1) = NVL(wor.activity_id, -1)
         AND wor.autocharge_type = WIP_CONSTANTS.WIP_MOVE
         AND wor.basis_type = WIP_CONSTANTS.PER_LOT
         AND wop.organization_id = wmti.organization_id
         AND wop.wip_entity_id = wmti.wip_entity_id
         AND wop.repetitive_schedule_id = wma.repetitive_schedule_id
         AND wmti.organization_id = wma.organization_id
         AND wmti.transaction_id = wma.transaction_id
         AND wci.repetitive_schedule_id = wma.repetitive_schedule_id
    GROUP BY wci.transaction_id,
             wma.repetitive_schedule_id;

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_TXN_ALLOCATIONS');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF; -- Per order basis type for repetitive

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_auto_resource',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.insert_auto_resource',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END insert_auto_resource;

/*****************************************************************************
 * This procedure is equivalent to wipiara in wiltca.ppc
 * This procedure is used to allocate per-item auto-resouce according to the
 * material allocation in the coresponding move transactions.
 * This procedure insert the record into WIP_TXN_ALLOCATIONS
 * This procedure must be called only after move allocation is successfully
 * completed
 ****************************************************************************/
PROCEDURE insert_txn_alloc(p_gib           IN        group_rec_t,
                           x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_msg          VARCHAR(240);
l_errMsg       VARCHAR2(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.insert_txn_alloc',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  /*---------------------------------------------------------------------+
    For each pENDing automatic per-item resource transaction in the group,
    the allocator uses the transaction associated material allocation in
    WIP_MOVE_TXN_ALLOCATION to insert one or more allocation records into
    WIP_TXN_ALLOCATIONS.
   +--------------------------------------------------------------------*/
  INSERT INTO wip_txn_allocations
    (transaction_id,
     repetitive_schedule_id,
     organization_id,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login,
     request_id,
     program_application_id,
     program_id,
     program_update_date,
     transaction_quantity,
     primary_quantity
    )
    SELECT wcti.transaction_id,
           wmta.repetitive_schedule_id,
           wcti.organization_id,
           SYSDATE,                       -- last_update_date
           wcti.last_updated_by,
           SYSDATE,                       -- creation_date
           wcti.created_by,
           wcti.last_update_login,
           wcti.request_id,
           wcti.program_application_id,
           wcti.program_id,
           SYSDATE,                       -- program_update_date
           wmta.transaction_quantity * wor.usage_rate_or_amount
             * DECODE(SIGN(wmti.to_operation_seq_num -
                           wmti.fm_operation_seq_num),
               0, DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  1, -1, DECODE(SIGN(wmti.to_intraoperation_step_type -
                                     WIP_CONSTANTS.RUN),1, 1, -1)),
               1, 1,
              -1,-1),                      -- transaction_quantity
                       wmta.primary_quantity * wor.usage_rate_or_amount
             * DECODE(SIGN(wmti.to_operation_seq_num -
                           wmti.fm_operation_seq_num),
               0, DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  1, -1, DECODE(SIGN(wmti.to_intraoperation_step_type -
                                     WIP_CONSTANTS.RUN),1, 1, -1)),
               1, 1,
              -1,-1)                       -- primary_quantity
      FROM wip_operation_resources wor,
           wip_move_txn_allocations wmta,
           wip_move_txn_interface wmti,
           wip_cost_txn_interface wcti
     WHERE wcti.group_id = p_gib.group_id
       AND wcti.process_phase = WIP_CONSTANTS.RES_PROC
       AND wcti.process_status = WIP_CONSTANTS.PENDING
       AND wcti.transaction_type = WIP_CONSTANTS.RES_TXN
       AND wcti.move_transaction_id IS NOT NULL /* Automatic resource */
       AND wcti.entity_type = WIP_CONSTANTS.REPETITIVE
       AND wcti.basis_type = WIP_CONSTANTS.PER_ITEM
       AND wcti.group_id = wmti.group_id  /* Bug 938039, 979553*/
       AND wcti.move_transaction_id = wmti.transaction_id
       AND wcti.move_transaction_id = wmta.transaction_id
       AND wcti.organization_id = wmta.organization_id
       AND wor.organization_id = wcti.organization_id
       AND wor.wip_entity_id = wcti.wip_entity_id
       AND wor.repetitive_schedule_id = wmta.repetitive_schedule_id
       AND wor.operation_seq_num = wcti.operation_seq_num
       AND wor.resource_seq_num = wcti.resource_seq_num
       AND wor.resource_id = wcti.resource_id
       AND NVL(wor.activity_id, -1) = NVL(wcti.activity_id, -1)
       AND wor.standard_rate_flag = wcti.standard_rate_flag
       AND wor.usage_rate_or_amount = wcti.usage_rate_or_amount;

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'WIP_TXN_ALLOCATIONS');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_txn_alloc',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.insert_txn_alloc',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END insert_txn_alloc;

/*****************************************************************************
 * This procedure is equivalent to witpsdo_dept_overheads in wiltps3.ppc
 * This procedure is used to insert department overhead info into
 * WIP_COST_TXN_INTERFACE and WIP_TXN_ALLOCATIONS IF needed
 ****************************************************************************/
PROCEDURE insert_dept_overhead(p_gib           IN        group_rec_t,
                               x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_msg          VARCHAR(240);
l_errMsg       VARCHAR2(240);
l_move         move_profile_rec_t;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  l_move  := p_gib.move_profile;

  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    l_params(3).paramName   := 'org_id';
    l_params(3).paramValue  :=  l_move.org_id;
    l_params(4).paramName   := 'wip_id';
    l_params(4).paramValue  :=  l_move.wip_id;
    l_params(5).paramName   := 'fmOp';
    l_params(5).paramValue  :=  l_move.fmOp;
    l_params(6).paramName   := 'fmStep';
    l_params(6).paramValue  :=  l_move.fmStep;
    l_params(7).paramName   := 'toOp';
    l_params(7).paramValue  :=  l_move.toOp;
    l_params(8).paramName   := 'toStep';
    l_params(8).paramValue  :=  l_move.toStep;
    l_params(9).paramName   := 'scrapTxn';
    l_params(9).paramValue  :=  l_move.scrapTxn;
    l_params(10).paramName  := 'easyComplete';
    l_params(10).paramValue :=  l_move.easyComplete;
    l_params(11).paramName  := 'easyReturn';
    l_params(11).paramValue :=  l_move.easyReturn;
    l_params(12).paramName  := 'jobTxn';
    l_params(12).paramValue :=  l_move.jobTxn;
    l_params(13).paramName  := 'scheTxn';
    l_params(13).paramValue :=  l_move.scheTxn;
    l_params(14).paramName  := 'rsrcItem';
    l_params(14).paramValue :=  l_move.rsrcItem;
    l_params(15).paramName  := 'rsrcLot';
    l_params(15).paramValue :=  l_move.rsrcLot;
    l_params(16).paramName  := 'poReqItem';
    l_params(16).paramValue :=  l_move.poReqItem;
    l_params(17).paramName  := 'poRegLot';
    l_params(17).paramValue :=  l_move.poReqLot;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.insert_dept_overhead',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

   -- Per item basis type for discrete jobs
  IF(l_move.jobTxn = WIP_CONSTANTS.YES) THEN

    INSERT INTO wip_cost_txn_interface
      (transaction_id,
       last_update_date,
       last_updated_by,
       last_updated_by_name,
       creation_date,
       created_by,
       created_by_name,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       group_id,
       source_code,
       source_line_id,
       process_phase,
       process_status,
       transaction_type,
       organization_id,
       organization_code,
       wip_entity_id,
       entity_type,
       primary_item_id,
       line_id,
       line_code,
       transaction_date,
       acct_period_id,
       operation_seq_num,
       department_id,
       department_code,
       employee_id,
       resource_seq_num,
       resource_id,
       resource_code,
       phantom_flag,
       usage_rate_or_amount,
       basis_type,
       autocharge_type,
       standard_rate_flag,
       transaction_quantity,
       transaction_uom,
       primary_quantity,
       primary_uom,
       actual_resource_rate,
       activity_id,
       activity_name,
       reason_id,
       reason_name,
       reference,
       move_transaction_id,
       po_header_id,
       po_line_id,
       repetitive_schedule_id,
       project_id,
       task_id
       )
       SELECT NULL,                          -- transaction_id
              SYSDATE,                       -- last_update_date
              MAX(wmti.last_updated_by),     -- last_updated_by --Fix for bug 5195072
              MAX(wmti.last_updated_by_name),-- last_updated_by_name --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              MAX(wmti.created_by),          -- created_by --Fix for bug 5195072
              MAX(wmti.created_by_name),     -- created_by_name --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              p_gib.group_id,
              MAX(wmti.source_code),
              MAX(wmti.source_line_id),
              WIP_CONSTANTS.RES_PROC,        -- process_phase
              WIP_CONSTANTS.PENDING,         -- process_status
              WIP_CONSTANTS.OVHD_TXN,        -- transaction_type
              MAX(wmti.organization_id),
              MAX(wmti.organization_code),
              MAX(wmti.wip_entity_id),
              MAX(wmti.entity_type),
              MAX(wmti.primary_item_id),
              MAX(wmti.line_id),
              MAX(wmti.line_code),
              MAX(wmti.transaction_date),
              MAX(wmti.acct_period_id),
              wop.operation_seq_num,
              NVL(wor.department_id, wop.department_id),
              MAX(bd.department_code),
              NULL,                          -- employee_id
              NULL,                          -- resource_seq_num
              NULL,                          -- resource_id
              NULL,                          -- resource_code
              MAX(wor.phantom_flag),
              NULL,                          -- usage_rate_or_amount
              WIP_CONSTANTS.PER_ITEM,        -- basis_type
              WIP_CONSTANTS.WIP_MOVE,        -- autocharge_type
              NULL,                          -- standard_rate_flag
              MAX(NVL(DECODE(wor.phantom_flag, 1, wro.quantity_per_assembly, 1)
               * wmti.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
               ,0)),                         -- transaction_quantity
              MAX(wmti.primary_uom),         -- transaction_uom
              MAX(NVL(DECODE(wor.phantom_flag, 1, wro.quantity_per_assembly, 1)
               * wmti.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
               ,0)),                         -- primary_quantity
              MAX(wmti.primary_uom),         -- primary_uom
              NULL,                          -- actual_resource_rate
              NULL,                          -- activity_id
              NULL,                          -- activity_name
              MAX(wmti.reason_id),
              MAX(wmti.reason_name),
              MAX(wmti.reference),
              MAX(wmti.transaction_id),      -- move_transaction_id
              NULL,                          -- po_header_id
              NULL,                          -- po_line_id
              NULL,                          -- repetitive_schedule_id
              MAX(wdj.project_id),
              MAX(wdj.task_id)
         FROM bom_departments bd,
              wip_operations wop,
              wip_operation_resources wor,
              wip_discrete_jobs wdj,
              wip_move_txn_interface wmti,
              wip_requirement_operations WRO
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wdj.wip_entity_id = wmti.wip_entity_id
          AND wdj.organization_id = wmti.organization_id
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
              OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)/* WSM */
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wop.organization_id = bd.organization_id
          AND NVL(wor.department_id, wop.department_id) = bd.department_id
          AND wop.organization_id = wor.organization_id(+)
          AND wop.wip_entity_id = wor.wip_entity_id(+)
          AND wop.operation_seq_num = wor.operation_seq_num(+)
          /* added for OSFM jump enhancement 2541431 */
          AND NVL(wop.skip_flag, WIP_CONSTANTS.NO) <> WIP_CONSTANTS.YES
          AND wor.wip_entity_id = wro.wip_entity_id (+)
          AND wor.organization_id = wro.organization_id (+)
          /* Fixed bug 3881663. Op seq in wro is a negative number,
           * but op seq in wor is a positive number.*/
          AND -wor.operation_seq_num = wro.operation_seq_num (+)
          AND wor.phantom_item_id = wro.inventory_item_id (+)
          /*bug 3930251 -> insert into WCTI only if there are records in CDO)*/
          AND EXISTS
             ( SELECT 1 FROM cst_department_overheads cdo
                WHERE cdo.organization_id = bd.organization_id
                  AND cdo.department_id = bd.department_id
             )
          AND (
              (wop.operation_seq_num >= wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num < wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND(wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                  OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                     AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                     AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.fm_operation_seq_num
                   OR (wop.operation_seq_num = wmti.to_operation_seq_num
                       AND wmti.to_intraoperation_step_type >
                           WIP_CONSTANTS.RUN)))
            OR
              (wop.operation_seq_num < wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num >= wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                  OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.to_operation_seq_num
                   OR (wop.operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type >
                          WIP_CONSTANTS.RUN))))
     GROUP BY wop.wip_entity_id,
              wop.operation_seq_num,
              wor.department_id,/*Fixed bug 2834503*/
              wop.department_id,
              wor.phantom_item_id,
              wor.phantom_op_seq_num,
              wmti.transaction_id; /* 2821017 */

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF;  --Per item basis type for discrete jobs

  -- Per item basis type for repetitive schedule
  IF(l_move.scheTxn = WIP_CONSTANTS.YES) THEN

    INSERT INTO wip_cost_txn_interface
      (transaction_id,
       last_update_date,
       last_updated_by,
       last_updated_by_name,
       creation_date,
       created_by,
       created_by_name,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       group_id,
       source_code,
       source_line_id,
       process_phase,
       process_status,
       transaction_type,
       organization_id,
       organization_code,
       wip_entity_id,
       entity_type,
       primary_item_id,
       line_id,
       line_code,
       transaction_date,
       acct_period_id,
       operation_seq_num,
       department_id,
       department_code,
       employee_id,
       resource_seq_num,
       resource_id,
       resource_code,
       phantom_flag,
       usage_rate_or_amount,
       basis_type,
       autocharge_type,
       standard_rate_flag,
       transaction_quantity,
       transaction_uom,
       primary_quantity,
       primary_uom,
       actual_resource_rate,
       activity_id,
       activity_name,
       reason_id,
       reason_name,
       reference,
       move_transaction_id,
       po_header_id,
       po_line_id,
       repetitive_schedule_id
       )
       SELECT NULL,                          -- transaction_id
              SYSDATE,                       -- last_update_date
              MAX(wmti.last_updated_by),      -- last_updated_by --Fix for bug 5195072
              MAX(wmti.last_updated_by_name), -- last_updated_by_name --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              MAX(wmti.created_by),           -- created_by --Fix for bug 5195072
              MAX(wmti.created_by_name),      -- created_by_name --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              p_gib.group_id,
              MAX(wmti.source_code),
              MAX(wmti.source_line_id),
              WIP_CONSTANTS.RES_PROC,        -- process_phase
              WIP_CONSTANTS.PENDING,         -- process_status
              WIP_CONSTANTS.OVHD_TXN,        -- transaction_type
              wmti.organization_id,
              MAX(wmti.organization_code),
              wmti.wip_entity_id,
              MAX(wmti.entity_type),
              MAX(wmti.primary_item_id),
              wmti.line_id,
              MAX(wmti.line_code),
              MAX(wmti.transaction_date),
              MAX(wmti.acct_period_id),
              wor.operation_seq_num,
              NVL(wor.department_id, wop.department_id),
              MAX(bd.department_code),
              NULL,                          -- employee_id
              NULL,                          -- resource_seq_num
              NULL,                          -- resource_id
              NULL,                          -- resource_code
              max(wor.phantom_flag),
              NULL,                          -- usage_rate_or_amount
              WIP_CONSTANTS.PER_ITEM,        -- basis_type
              WIP_CONSTANTS.WIP_MOVE,        -- autocharge_type
              NULL,                          -- standard_rate_flag
              SUM(NVL(wma.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
               ,0)),                         -- transaction_quantity
              MAX(wmti.primary_uom),          -- transaction_uom
              SUM(NVL(wma.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
               ,0)),                         -- primary_quantity
              MAX(wmti.primary_uom),          -- primary_uom
              NULL,                          -- actual_resource_rate
              NULL,                          -- activity_id
              NULL,                          -- activity_name
              MAX(wmti.reason_id),
              MAX(wmti.reason_name),
              MAX(wmti.reference),
              MAX(wmti.transaction_id),       -- move_transaction_id
              NULL,                          -- po_header_id
              NULL,                          -- po_line_id
              NULL                           -- repetitive_schedule_id
         FROM bom_departments bd,
              wip_move_txn_allocations wma,
              wip_operations wop,
              wip_move_txn_interface wmti,
              wip_operation_resources wor
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wmti.organization_id = wma.organization_id
          AND wmti.transaction_id = wma.transaction_id
          AND wop.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wop.organization_id = bd.organization_id
          AND NVL(wor.department_id, wop.department_id) = bd.department_id
          AND wor.organization_id = wop.organization_id
          AND wor.wip_entity_id = wop.wip_entity_id
          AND wor.operation_seq_num = wop.operation_seq_num
          AND wor.repetitive_schedule_id = wop.repetitive_schedule_id
          AND (
              (wop.operation_seq_num >= wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num < wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                   OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.fm_operation_seq_num
                   OR (wop.operation_seq_num = wmti.to_operation_seq_num
                       AND wmti.to_intraoperation_step_type >
                           WIP_CONSTANTS.RUN)))
            OR
              (wop.operation_seq_num < wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num >= wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                  OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.to_operation_seq_num
                   OR (wop.operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type >
                          WIP_CONSTANTS.RUN))))
     GROUP BY wmti.organization_id,
              wmti.wip_entity_id,
              wmti.line_id,
              wor.operation_seq_num,
              wmti.transaction_id,
              wor.department_id, /*fixed bug 2834503*/
              wop.department_id,
              wor.phantom_item_id,
              wor.phantom_op_seq_num;

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF;  -- Per item basis type for repetitive schedule

  /*-----------------------------------------------------------------------+
   |  Per order basis type for discrete jobs
   +-----------------------------------------------------------------------*/
  /* Grouping wmti.source_line_id, wmti.source_code, wmti.primary_uom
   | wmti.reason_id, wmti.reference may not make sense since they are
   | tied to the transaction_id.  NULL them out [24-JUL-92, John, Djuki.
   | We have more than one record per op_seq because of quantity_completed
   +----------------------------------------------------------------------*/
  IF(l_move.jobTxn = WIP_CONSTANTS.YES) THEN

    INSERT INTO wip_cost_txn_interface
      (transaction_id,
       last_update_date,
       last_updated_by,
       last_updated_by_name,
       creation_date,
       created_by,
       created_by_name,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       group_id,
       source_code,
       source_line_id,
       process_phase,
       process_status,
       transaction_type,
       organization_id,
       organization_code,
       wip_entity_id,
       entity_type,
       primary_item_id,
       line_id,
       line_code,
       transaction_date,
       acct_period_id,
       operation_seq_num,
       department_id,
       department_code,
       employee_id,
       resource_seq_num,
       resource_id,
       resource_code,
       phantom_flag,
       usage_rate_or_amount,
       basis_type,
       autocharge_type,
       standard_rate_flag,
       transaction_quantity,
       transaction_uom,
       primary_quantity,
       primary_uom,
       actual_resource_rate,
       activity_id,
       activity_name,
       reason_id,
       reason_name,
       reference,
       move_transaction_id,
       po_header_id,
       po_line_id,
       repetitive_schedule_id,
       project_id,
       task_id
       )
       SELECT NULL,                          -- transaction_id
              SYSDATE,                       -- last_update_date
              MAX(wmti.last_updated_by),      -- last_updated_by --Fix for bug 5195072
              MAX(wmti.last_updated_by_name), -- last_updated_by_name --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              MAX(wmti.created_by),           -- created_by --Fix for bug 5195072
              MAX(wmti.created_by_name),      -- created_by_name --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              p_gib.group_id,
              MAX(wmti.source_code),          -- source_code
              MAX(wmti.source_line_id),       -- source_line_id
              WIP_CONSTANTS.RES_PROC,        -- process_phase
              WIP_CONSTANTS.PENDING,         -- process_status
              WIP_CONSTANTS.OVHD_TXN,        -- transaction_type
              wmti.organization_id,
              MAX(wmti.organization_code),
              wmti.wip_entity_id,
              MAX(entity_type),
              MAX(wmti.primary_item_id),
              MAX(wmti.line_id),
              MAX(wmti.line_code),
              MAX(wmti.transaction_date),
              MAX(wmti.acct_period_id),
              wop.operation_seq_num,
              NVL(wor.department_id, wop.department_id) ,
              MAX(bd.department_code),
              NULL,                           -- employee_id
              NULL,                           -- resource_seq_num
              NULL,                           -- resource_id
              NULL,                           -- resource_code
              MAX(wor.phantom_flag),
              NULL,                           -- usage_rate_or_amount
              WIP_CONSTANTS.PER_LOT,          -- basis_type
              WIP_CONSTANTS.WIP_MOVE,         -- autocharge_type
              NULL,                           -- standard_rate_flag
                DECODE(SIGN(MAX(wop.quantity_completed) +
              /* Fixed bug 3740010 change from "NVL(SUM(wmti.primary_quantity"
               * to "NVL(MAX(wmti.primary_quantity" because there may be
               * multiple resources per operation.
               */
                  NVL(MAX(wmti.primary_quantity *
                  DECODE(SIGN(wmti.to_operation_seq_num -
                              wmti.fm_operation_seq_num),
                  0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),
                    0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                   -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                    1,-1),
                  1, 1,
                 -1,-1)
                 ),0)),                       -- transaction_quantity
                0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
                1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
               -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0)),
              MAX(wmti.primary_uom),           -- transaction_uom
                 DECODE(SIGN(MAX(wop.quantity_completed) +
              /* Fixed bug 3740010 change from "NVL(SUM(wmti.primary_quantity"
               * to "NVL(MAX(wmti.primary_quantity" because there may be
               * multiple resources per operation.
               */
                  NVL(MAX(wmti.primary_quantity *
                  DECODE(SIGN(wmti.to_operation_seq_num -
                              wmti.fm_operation_seq_num),
                  0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),
                    0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                   -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                  WIP_CONSTANTS.RUN),1,1,-1),
                    1,-1),
                  1, 1,
                 -1,-1)
                 ),0)),                        -- primary_quantity
                0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
                1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
               -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0)),
              MAX(wmti.primary_uom),            -- primary_uom
              NULL,                            -- actual_resource_rate
              NULL,                            -- activity_id
              NULL,                            -- activity_name
              NULL,                            -- reason_id
              NULL,                            -- reason_name
              NULL,                            -- reference
              MAX(wmti.transaction_id),         -- move_transaction_id
              NULL,                            -- po_header_id
              NULL,                            -- po_line_id
              NULL,                            -- repetitive_schedule_id
              MAX(wdj.project_id),
              MAX(wdj.task_id)
         FROM bom_departments bd,
              wip_operations wop,
              wip_operation_resources wor,
              wip_discrete_jobs wdj,
              wip_move_txn_interface wmti
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
               OR wmti.entity_type = WIP_CONSTANTS.LOTBASED) /* WSM */
          AND wdj.wip_entity_id = wmti.wip_entity_id
          AND wdj.organization_id = wmti.organization_id
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wop.organization_id = bd.organization_id
          AND NVL(wor.department_id, wop.department_id) = bd.department_id
          AND wop.organization_id = wor.organization_id(+)
          AND wop.wip_entity_id = wor.wip_entity_id(+)
          AND wop.operation_seq_num = wor.operation_seq_num(+)
          /* added for OSFM jump enhancement 2541431 */
          AND NVL(wop.skip_flag, WIP_CONSTANTS.NO) <> WIP_CONSTANTS.YES
          /*bug 3930251 -> insert into WCTI only if there are records in CDO)*/
          AND EXISTS
             ( SELECT 1 FROM cst_department_overheads cdo
                WHERE cdo.organization_id = bd.organization_id
                  AND cdo.department_id = bd.department_id
             )
          AND (
              (wop.operation_seq_num >= wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num < wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                   OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.fm_operation_seq_num
                   OR (wop.operation_seq_num = wmti.to_operation_seq_num
                       AND wmti.to_intraoperation_step_type >
                           WIP_CONSTANTS.RUN)))
            OR
              (wop.operation_seq_num < wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num >= wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                   OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR wop.operation_seq_num = wmti.to_operation_seq_num
                  OR (wop.operation_seq_num = wmti.fm_operation_seq_num
                     AND wmti.fm_intraoperation_step_type >
                         WIP_CONSTANTS.RUN))))
     GROUP BY wmti.organization_id,
              wmti.wip_entity_id,
              wop.operation_seq_num,
              wor.phantom_item_id, --Bug 5213164:Added to take care of multiple phantoms
              wor.phantom_op_seq_num, --Bug 5213164
              wor.department_id, /*fixed bug 2834503*/
              wop.department_id
       HAVING 0 <>
              DECODE(SIGN(MAX(wop.quantity_completed) +
              /* Fixed bug 3740010 change from "NVL(SUM(wmti.primary_quantity"
               * to "NVL(MAX(wmti.primary_quantity" because there may be
               * multiple resources per operation.
               */
                              NVL(MAX(wmti.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
                ),0)),     -- NVL
              0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
              1, DECODE(sign(MAX(wop.quantity_completed)),1,0,1),
             -1, DECODE(sign(MAX(wop.quantity_completed)),1,-1,0));

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF; -- Per order basis type for discrete jobs

  -- Per order basis type for repetitive
  IF(l_move.scheTxn = WIP_CONSTANTS.YES) THEN

    INSERT INTO wip_cost_txn_interface
      (transaction_id,
       last_update_date,
       last_updated_by,
       last_updated_by_name,
       creation_date,
       created_by,
       created_by_name,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       group_id,
       source_code,
       source_line_id,
       process_phase,
       process_status,
       transaction_type,
       organization_id,
       organization_code,
       wip_entity_id,
       entity_type,
       primary_item_id,
       line_id,
       line_code,
       transaction_date,
       acct_period_id,
       operation_seq_num,
       department_id,
       department_code,
       employee_id,
       resource_seq_num,
       resource_id,
       resource_code,
       phantom_flag,
       usage_rate_or_amount,
       basis_type,
       autocharge_type,
       standard_rate_flag,
       transaction_quantity,
       transaction_uom,
       primary_quantity,
       primary_uom,
       actual_resource_rate,
       activity_id,
       activity_name,
       reason_id,
       reason_name,
       reference,
       move_transaction_id,
       po_header_id,
       po_line_id,
       repetitive_schedule_id
       )
       SELECT NULL,                          -- transaction_id
              SYSDATE,                       -- last_update_date
              MAX(wmti.last_updated_by),      -- last_updated_by --Fix for bug 5195072
              MAX(wmti.last_updated_by_name), -- last_updated_by_name --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              MAX(wmti.created_by),           -- created_by --Fix for bug 5195072
              MAX(wmti.created_by_name),      -- created_by_name --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              p_gib.group_id,
              MAX(wmti.source_code),          -- source_code
              -- Fixed bug 2465148
              MAX(wmti.source_line_id),       -- source_line_id
              WIP_CONSTANTS.RES_PROC,        -- process_phase
              WIP_CONSTANTS.PENDING,         -- process_status
              WIP_CONSTANTS.OVHD_TXN,        -- transaction_type
              wmti.organization_id,
              MAX(wmti.organization_code),
              wmti.wip_entity_id,
              MAX(entity_type),
              MAX(wmti.primary_item_id),
              wmti.line_id,
              MAX(wmti.line_code),
              MAX(wmti.transaction_date),
              MAX(wmti.acct_period_id),
              wor.operation_seq_num,
              NVL(wor.department_id, wop.department_id),
              MAX(bd.department_code),
              NULL,                          -- employee_id
              NULL,                          -- resource_seq_num
              NULL,                          -- resource_id
              NULL,                          -- resource_code
              MAX(wor.phantom_flag),
              NULL,                          -- usage_rate_or_amount
              WIP_CONSTANTS.PER_LOT,         -- basis_type
              WIP_CONSTANTS.WIP_MOVE,        -- autocharge_type
              NULL,                          -- standard_rate_flag
              1,                             -- transaction_quantity
              MAX(wmti.primary_uom),          -- transaction_uom
              1,                             -- primary_quantity
              MAX(wmti.primary_uom),          -- primary_uom
              NULL,                          -- actual_resource_rate
              NULL,                          -- activity_id
              NULL,                          -- activity_name
              NULL,                          -- reason_id
              NULL,                          -- reason_name
              -- Fixed bug 2506653
              MAX(wmti.reference),            -- reference
              MAX(wmti.transaction_id),       -- move_transaction_id
              NULL,                          -- po_header_id
              NULL,                          -- po_line_id
              wma.repetitive_schedule_id
         FROM bom_departments bd,
              wip_move_txn_allocations wma,
              wip_operations wop,
              wip_move_txn_interface wmti,
              wip_operation_resources wor
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wop.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wmti.organization_id = wma.organization_id
          AND wmti.transaction_id = wma.transaction_id
          AND wop.organization_id = bd.organization_id
          AND NVL(wor.department_id, wop.department_id) = bd.department_id
          AND wor.organization_id = wop.organization_id
          AND wor.wip_entity_id = wop.wip_entity_id
          AND wor.operation_seq_num = wop.operation_seq_num
          AND wor.repetitive_schedule_id = wop.repetitive_schedule_id
          AND (
              (wop.operation_seq_num >= wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num < wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                   OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                   OR wop.operation_seq_num = wmti.fm_operation_seq_num
                   OR (wop.operation_seq_num = wmti.to_operation_seq_num
                       AND wmti.to_intraoperation_step_type >
                           WIP_CONSTANTS.RUN)))
            OR
              (wop.operation_seq_num < wmti.fm_operation_seq_num
              + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND wop.operation_seq_num >= wmti.to_operation_seq_num
              + DECODE(SIGN(wmti.to_intraoperation_step_type -
                            WIP_CONSTANTS.RUN),1,1,0)
              AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                   OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
              AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR wop.operation_seq_num = wmti.to_operation_seq_num
                  OR (wop.operation_seq_num = wmti.fm_operation_seq_num
                     AND wmti.fm_intraoperation_step_type >
                         WIP_CONSTANTS.RUN))))
     GROUP BY wmti.organization_id,
              wmti.wip_entity_id,
              wmti.line_id,
              wma.repetitive_schedule_id,
              wor.operation_seq_num,
              wor.department_id, /*fixed bug 2834503*/
              wop.department_id,
              wor.phantom_item_id,
              wor.phantom_op_seq_num
       HAVING 0 <>
              DECODE(SIGN(MAX(wop.quantity_completed) +
                              NVL(SUM(wma.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
               ),0)),
              0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
              1, DECODE(sign(MAX(wop.quantity_completed)),1,0,1),
             -1, DECODE(sign(MAX(wop.quantity_completed)),1,-1,0));

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF;   -- Per order basis type for repetitive


  /*------------------------------------------------------------+
   |  Generate transaction_id for WIP_TXN_ALLOCATIONS     |
   +------------------------------------------------------------*/
  UPDATE wip_cost_txn_interface
     SET transaction_id = wip_transactions_s.nextval
   WHERE group_id = p_gib.group_id
     AND TRUNC(transaction_date) = TRUNC(p_gib.txn_date)
     AND transaction_type = WIP_CONSTANTS.OVHD_TXN;

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
  END IF;

  -- For repetitive
  IF(l_move.scheTxn = WIP_CONSTANTS.YES) THEN

   /*------------------------------------------------------------+
    |  Insert into cost allocations for repetitive schedules     |
    |  per lot
    +------------------------------------------------------------*/

   /*------------------------------------------------------------+
    |  Columns to insert into WIP_TXN_ALLOCATIONS                |
    |                                                            |
    |  transaction_id,                                           |
    |  repetitive_schedule_id, organization_id,                  |
    |  last_update_date, last_updated_by, creation_date,         |
    |  created_by, last_update_login, request_id,                |
    |  program_application_id, program_id, program_update_date,  |
    |  transaction_quantity,                                     |
    |  primary_quantity,                                         |
    |                                                            |
    +------------------------------------------------------------*/
    INSERT INTO wip_txn_allocations
      (transaction_id,
       repetitive_schedule_id,
       organization_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       transaction_quantity,
       primary_quantity
       )
       SELECT wci.transaction_id,
              wma.repetitive_schedule_id,
              MAX(wmti.organization_id),
              SYSDATE,                         -- last_update_date
              MAX(wmti.last_updated_by),        -- last_updated_by --Fix for bug 5195072
              SYSDATE,                         -- creation_date
              MAX(wmti.created_by),             -- created_by --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              DECODE(SIGN(MAX(wop.quantity_completed) +
                              NVL(SUM(wma.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
                ),0)),                   -- transaction_quantity
              0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
              1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
             -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0)),
               DECODE(SIGN(MAX(wop.quantity_completed) +
                              NVL(SUM(wma.primary_quantity *
                DECODE(SIGN(wmti.to_operation_seq_num -
                            wmti.fm_operation_seq_num),
                0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                              WIP_CONSTANTS.RUN),
                  0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                 -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,-1),
                  1,-1),
                1, 1,
               -1,-1)
                ),0)),                   -- primary_quantity
              0, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0),
              1, DECODE(SIGN(MAX(wop.quantity_completed)),1,0,1),
             -1, DECODE(SIGN(MAX(wop.quantity_completed)),1,-1,0))
         FROM wip_move_txn_allocations wma,
              wip_operations wop,
              wip_cost_txn_interface wci,
              wip_move_txn_interface wmti
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND wmti.group_id = wci.group_id
          AND wci.organization_id = wmti.organization_id
          AND wci.wip_entity_id = wmti.wip_entity_id
          AND wci.operation_seq_num = wop.operation_seq_num
          AND wci.basis_type = WIP_CONSTANTS.PER_LOT
          AND wci.transaction_type = WIP_CONSTANTS.OVHD_TXN
          AND wop.organization_id = wmti.organization_id
          AND wop.wip_entity_id = wmti.wip_entity_id
          AND wop.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wmti.organization_id = wma.organization_id
          AND wmti.transaction_id = wma.transaction_id
          AND wci.repetitive_schedule_id = wma.repetitive_schedule_id
     GROUP BY wci.transaction_id,
              wma.repetitive_schedule_id;

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'WIP_TXN_ALLOCATIONS');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF;   -- For repetitive

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_dept_overhead',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.insert_dept_overhead',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END insert_dept_overhead;

/*****************************************************************************
 * This procedure is equivalent to witpsrt_release_cost_txns in wiltps3.ppc
 * This procedure is used to set group_id in wip_cost_txn_interface to be NULL
 * so that Costing Manager will pick up the records.
 ****************************************************************************/
PROCEDURE release_cost_txn(p_gib           IN        group_rec_t,
                           x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_msg          VARCHAR(240);
l_errMsg       VARCHAR2(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.release_cost_txn',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  UPDATE wip_cost_txn_interface
     SET group_id = NULL
   WHERE group_id = p_gib.group_id
     AND TRUNC(transaction_date) = TRUNC(p_gib.txn_date);

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'WIP_COST_TXN_INTERFACE');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.release_cost_txn',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.release_cost_txn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END release_cost_txn;

/*****************************************************************************
 * This procedure is equivalent to witpspr_po_req in wiltps4.ppc
 * This procedure is used to insert purchase order requisition into
 * PO_REQUISITIONS_INTERFACE_ALL
 * NOTES:
 *  IF the purchase item lead time falls outside of BOM_CALENDAR_DATES
 *  THEN no PO req will be created
 ****************************************************************************/
PROCEDURE insert_po_req(p_gib           IN        group_rec_t,
                        x_returnStatus OUT NOCOPY VARCHAR2) IS

CURSOR c_additional_reqs(p_group_id NUMBER) IS
  SELECT distinct wmti.wip_entity_id wip_id,
         wmti.repetitive_schedule_id rep_sched_id,
         wmti.organization_id org_id,
         wo.operation_seq_num op_seq_num,
         wmti.overcompletion_primary_qty oc_qty
    FROM wip_move_txn_interface wmti,
         wip_operations wo,
         wip_operation_resources wor,
         wip_discrete_jobs wdj
   WHERE wmti.group_id = p_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.overcompletion_transaction_qty IS NOT NULL
     AND wdj.wip_entity_id = wmti.wip_entity_id
     AND wdj.organization_id = wmti.organization_id
     AND wdj.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE
     AND wo.wip_entity_id = wmti.wip_entity_id
     AND wo.organization_id = wmti.organization_id
     AND wo.operation_seq_num > wmti.fm_operation_seq_num
     AND wo.count_point_type <> WIP_CONSTANTS.NO_MANUAL
     AND wor.wip_entity_id = wo.wip_entity_id
     AND wor.organization_id = wo.organization_id
     AND wor.operation_seq_num = wo.operation_seq_num
     AND wor.autocharge_type in (WIP_CONSTANTS.PO_RECEIPT,
                                 WIP_CONSTANTS.PO_MOVE)
     AND wor.basis_type = WIP_CONSTANTS.PER_ITEM

   UNION

  SELECT distinct wmti.wip_entity_id wip_id,
               wmti.repetitive_schedule_id rep_sched_id,
         wmti.organization_id org_id,
         wo.operation_seq_num op_seq_num,
         wmti.overcompletion_primary_qty oc_qty
    FROM wip_move_txn_interface wmti,
         wip_operations wo,
         wip_operation_resources wor,
         wip_repetitive_schedules wrs
   WHERE wmti.group_id = p_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.overcompletion_transaction_qty IS NOT NULL
     AND wrs.wip_entity_id = wmti.wip_entity_id
     AND wrs.repetitive_schedule_id = wmti.repetitive_schedule_id
     AND wrs.organization_id = wmti.organization_id
     AND wrs.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE
     AND wo.wip_entity_id = wmti.wip_entity_id
     AND wo.repetitive_schedule_id = wmti.repetitive_schedule_id
     AND wo.organization_id = wmti.organization_id
     AND wo.operation_seq_num > wmti.fm_operation_seq_num
     AND wo.count_point_type <> WIP_CONSTANTS.NO_MANUAL
     AND wor.wip_entity_id = wo.wip_entity_id
     AND wor.organization_id = wo.organization_id
     AND wor.repetitive_schedule_id = wmti.repetitive_schedule_id
     AND wor.operation_seq_num = wo.operation_seq_num
     AND wor.autocharge_type in (WIP_CONSTANTS.PO_RECEIPT,
                                 WIP_CONSTANTS.PO_MOVE)
     AND wor.basis_type = WIP_CONSTANTS.PER_ITEM ;


l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_msg          VARCHAR(240);
l_errMsg       VARCHAR2(240);
l_additional_reqs c_additional_reqs%ROWTYPE;
l_move         move_profile_rec_t;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  l_move := p_gib.move_profile;

  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    l_params(3).paramName   := 'org_id';
    l_params(3).paramValue  :=  l_move.org_id;
    l_params(4).paramName   := 'wip_id';
    l_params(4).paramValue  :=  l_move.wip_id;
    l_params(5).paramName   := 'fmOp';
    l_params(5).paramValue  :=  l_move.fmOp;
    l_params(6).paramName   := 'fmStep';
    l_params(6).paramValue  :=  l_move.fmStep;
    l_params(7).paramName   := 'toOp';
    l_params(7).paramValue  :=  l_move.toOp;
    l_params(8).paramName   := 'toStep';
    l_params(8).paramValue  :=  l_move.toStep;
    l_params(9).paramName   := 'scrapTxn';
    l_params(9).paramValue  :=  l_move.scrapTxn;
    l_params(10).paramName  := 'easyComplete';
    l_params(10).paramValue :=  l_move.easyComplete;
    l_params(11).paramName  := 'easyReturn';
    l_params(11).paramValue :=  l_move.easyReturn;
    l_params(12).paramName  := 'jobTxn';
    l_params(12).paramValue :=  l_move.jobTxn;
    l_params(13).paramName  := 'scheTxn';
    l_params(13).paramValue :=  l_move.scheTxn;
    l_params(14).paramName  := 'rsrcItem';
    l_params(14).paramValue :=  l_move.rsrcItem;
    l_params(15).paramName  := 'rsrcLot';
    l_params(15).paramValue :=  l_move.rsrcLot;
    l_params(16).paramName  := 'poReqItem';
    l_params(16).paramValue :=  l_move.poReqItem;
    l_params(17).paramName  := 'poRegLot';
    l_params(17).paramValue :=  l_move.poReqLot;

    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.insert_po_req',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  /*------------------------------------------------------------+
   |  Insert into PO_REQUISITIONS_INTERFACE_ALL table for per item for jobs
   +------------------------------------------------------------*/
  IF(l_move.jobTxn    = WIP_CONSTANTS.YES AND
     l_move.poReqItem = WIP_CONSTANTS.YES) THEN

    -- Fixed bug 5144659. Insert into po_requisitions_interface_all instead of
    -- po_requisitions_interface as part of MOAC change.
    INSERT INTO po_requisitions_interface_all
      (last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       org_id,  /* Operating unit org */
       preparer_id,
       interface_source_code,
       authorization_status,
       source_type_code,
       destination_organization_id,
       destination_type_code,
       item_id,
       item_revision,
       uom_code,
       quantity,
       line_type_id,
       charge_account_id,
       deliver_to_location_id,
       deliver_to_requestor_id,
       wip_entity_id,
       wip_line_id,
       wip_operation_seq_num,
       wip_resource_seq_num,
       bom_resource_id,
       wip_repetitive_schedule_id,
       need_by_date,
       autosource_flag,
       group_code,
       suggested_buyer_id,
       project_id,
       task_id,
       project_accounting_context
       )
       SELECT /*bugfix 5345712 : performance fix. removed hint */
              SYSDATE,                   -- last_update_date
              wmti.last_updated_by,      -- last_updated_by --Fix for bug 5195072
              SYSDATE,                   -- creation_date
              wmti.created_by,           -- created_by --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              to_number(hoi.org_information3),        -- ou_org_id
              fu.employee_id,            -- preparer_id
              'WIP',                     -- interface_source_code
              'APPROVED',                -- authorization_status
              'VENDOR',                  -- source_type_code
              wor.organization_id,       -- destination_organization_id
              'SHOP FLOOR',              -- destination_type_code
              br.purchase_item_id,       -- item_id
              DECODE(msi.revision_qty_control_code, -- item_revision
               1, NULL,
               2, DECODE(br.purchase_item_id,
                        wdj.primary_item_id, wdj.bom_revision,
                        BOM_revisions.GET_ITEM_REVISION_FN
                               ('EXCLUDE_OPEN_HOLD',        -- eco_status
                                'ALL',                      -- examine_type
                                 br.ORGANIZATION_ID,        -- org_id
                                 br.purchase_item_id,       -- item_id
                                 wdj.scheduled_start_date   -- rev_date
                                      ))), /* Fixed Bug# 1623063 */
              msi.primary_uom_code,       -- uom_code
              DECODE(msi.outside_operation_uom_type, -- quantity
               'RESOURCE',ROUND(wor.usage_rate_or_amount*wmti.primary_quantity,
                                WIP_CONSTANTS.INV_MAX_PRECISION),
               'ASSEMBLY',wmti.primary_quantity),
              3,                          -- line_type_id
              wdj.outside_processing_account, -- charge_account_id
              bd.location_id,             -- deliver_to_location_id
              fu.employee_id,             -- deliver_to_requestor_id
              wor.wip_entity_id,
              wmti.line_id,
              wor.operation_seq_num,
              wor.resource_seq_num,
              wor.resource_id,
              wor.repetitive_schedule_id,
              /* Bug 4398047 commented following portion of the sql
              DECODE(wmti.entity_type, --  Fix for 2374334
                WIP_CONSTANTS.LOTBASED, bcd1.calendar_date, */
                (bcd3.calendar_date +
                 (DECODE(wo1.next_operation_seq_num,
                    NULL, wo1.last_unit_completion_date,
                    wo2.first_unit_start_date) -
                  TRUNC(DECODE(wo1.next_operation_seq_num,
                          NULL, wo1.last_unit_completion_date,
                          wo2.first_unit_start_date)))),  -- need_by_date  /* Bug 4398047 removed one matching bracket for decode */
             'Y',                         -- autosource_flag
              NULL,                       -- group_code
              msi.buyer_id,               -- suggested_buyer_id
              wdj.project_id,
              wdj.task_id,
              DECODE(wdj.project_id,NULL,NULL,'Y')-- project_accounting_context
        FROM      /* bugfix 5129403: modified the order in the from clause */
              wip_move_txn_interface wmti,
              wip_operation_resources wor,
              bom_resources br,
              mtl_system_items msi,
              mtl_parameters mp,
           -- bom_calendar_dates bcd2,  Bug 4398047 join to bcd2 not required
              bom_calendar_dates bcd4,
           -- bom_calendar_dates bcd1,  Bug 4398047 join to bcd1 not required
              bom_calendar_dates bcd3,
              fnd_user fu,
              bom_departments bd,
              hr_organization_information hoi,
              wip_discrete_jobs wdj,
              wip_operations wo1,
              wip_operations wo2
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
               OR wmti.entity_type = WIP_CONSTANTS.LOTBASED) /* WSM */
          AND (wmti.overcompletion_transaction_id IS NULL
               OR ( wmti.overcompletion_transaction_id IS NOT NULL
                    AND wmti.overcompletion_transaction_qty IS NOT NULL))
--Bugfix 6679124: Join to wor using wdj rather than wmti to get better execution plan.
--          AND wmti.organization_id = wor.organization_id
--          AND wmti.wip_entity_id = wor.wip_entity_id
	    AND wdj.organization_id = wor.organization_id     --6679124
            AND wdj.wip_entity_id = wor.wip_entity_id         -- 6679124
          AND wmti.to_operation_seq_num = wor.operation_seq_num
          AND wmti.fm_operation_seq_num < wmti.to_operation_seq_num
          AND wmti.to_intraoperation_step_type = WIP_CONSTANTS.QUEUE
          AND wo1.organization_id = wmti.organization_id
          AND wo1.wip_entity_id = wmti.wip_entity_id
          AND wo1.operation_seq_num = wmti.to_operation_seq_num
          AND wo2.organization_id = wo1.organization_id
          AND wo2.wip_entity_id = wo1.wip_entity_id
      -- Fixed bug 2259661
      --    AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT
      --          AND wo2.operation_seq_num = wmti.to_operation_seq_num)
      --      OR (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE
          AND ((wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                        WIP_CONSTANTS.PO_MOVE))
                AND ((wo1.next_operation_seq_num IS NOT NULL
                      AND wo1.next_operation_seq_num = wo2.operation_seq_num)
                  OR (wo1.next_operation_seq_num IS NULL
                      AND wo2.operation_seq_num = wmti.to_operation_seq_num)))
          AND wdj.organization_id = wmti.organization_id
          AND wdj.wip_entity_id = wmti.wip_entity_id
          AND (wdj.po_creation_time = WIP_CONSTANTS.AT_OPERATION
            OR (wo1.count_point_type = WIP_CONSTANTS.NO_MANUAL
                      AND wdj.po_creation_time <> WIP_CONSTANTS.MANUAL_CREATION))
          AND wor.basis_type = WIP_CONSTANTS.PER_ITEM
          AND wor.organization_id = br.organization_id
          AND wor.resource_id = br.resource_id
          AND br.organization_id = msi.organization_id
          AND br.purchase_item_id = msi.inventory_item_id
          AND wmti.created_by = fu.user_id
          AND wmti.organization_id = bd.organization_id
          /*  Fix for bug 3609023: Corrected condition to ensure we insert
              correct deliver_to_location_id for PO_RECEIPT */
          AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT AND
                wo1.department_id = bd.department_id)
                OR
               (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE AND
                wo2.department_id = bd.department_id))
          AND mp.organization_id = wmti.organization_id
          AND hoi.organization_id = wmti.organization_id
          AND hoi.org_information_context = 'Accounting Information'
          /*Bug 4398047 commenting out following portion of the sql
          AND bcd2.calendar_code = mp.calendar_code -- Fix for Bug#2374334
          AND bcd2.exception_set_id = mp.calendar_exception_set_id
          AND bcd2.calendar_date = trunc(SYSDATE)
          AND bcd1.calendar_code = mp.calendar_code
          AND bcd1.exception_set_id = mp.calendar_exception_set_id
          AND bcd1.seq_num = (bcd2.next_seq_num +
                CEIL(NVL(msi.preprocessing_lead_time,0) +
                     NVL(msi.fixed_lead_time,0) +
                    (NVL(msi.variable_lead_time,0) *
                       DECODE(msi.outside_operation_uom_type,
                        'RESOURCE',
                         wor.usage_rate_or_amount * wmti.primary_quantity,
                        'ASSEMBLY',
                         wmti.primary_quantity
                         )
                     ) +
                     NVL(msi.postprocessing_lead_time,0))) Bug 4398047 end of commented portion of sql */
          -- consider post processing lead time before inserting need-by-date
          AND bcd4.calendar_code = mp.calendar_code
          AND bcd4.exception_set_id = mp.calendar_exception_set_id
          AND bcd4.calendar_date =
              TRUNC(DECODE(wo1.next_operation_seq_num,
                      NULL, wo1.last_unit_completion_date,
                      wo2.first_unit_start_date))
          AND bcd3.calendar_code = mp.calendar_code
          AND bcd3.exception_set_id = mp.calendar_exception_set_id
          AND bcd3.seq_num = (bcd4.next_seq_num -
                              CEIL(NVL(msi.postprocessing_lead_time,0)));
    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'PO_REQUISITIONS_INTERFACE_ALL');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF; -- po requisition per item for jobs

  /*------------------------------------------------------------+
   |Insert into po_req interface table for per item for schedule
   +------------------------------------------------------------*/
  IF(l_move.scheTxn    = WIP_CONSTANTS.YES AND
     l_move.poReqItem = WIP_CONSTANTS.YES) THEN
    -- Fixed bug 5144659. Insert into po_requisitions_interface_all instead of
    -- po_requisitions_interface as part of MOAC change.
    INSERT INTO po_requisitions_interface_all
      (last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       org_id,  /* Operating unit org */
       preparer_id,
       interface_source_code,
       authorization_status,
       source_type_code,
       destination_organization_id,
       destination_type_code,
       item_id,
       item_revision,
       uom_code,
       quantity,
       line_type_id,
       charge_account_id,
       deliver_to_location_id,
       deliver_to_requestor_id,
       wip_entity_id,
       wip_line_id,
       wip_operation_seq_num,
       wip_resource_seq_num,
       bom_resource_id,
       wip_repetitive_schedule_id,
       need_by_date,
       autosource_flag,
       group_code,
       suggested_buyer_id
       )
       SELECT SYSDATE,                       -- last_update_date
              wmti.last_updated_by,           -- last_updated_by --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              wmti.created_by,                -- created_by --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              to_number(hoi.org_information3),        -- ou_org_id
              fu.employee_id,                -- preparer_id
              'WIP',                         -- interface_source_code
              'APPROVED',                    -- authorization_status
              'VENDOR',                      -- source_type_code
              wor.organization_id,           -- destination_organization_id
              'SHOP FLOOR',                  -- destination_type_code
              br.purchase_item_id,           -- item_id
              DECODE(msi.revision_qty_control_code, -- item_revision
               1, NULL,
               2, DECODE(br.purchase_item_id,
                  we.primary_item_id, wrs.bom_revision,
                        BOM_revisions.GET_ITEM_REVISION_FN
                               ('EXCLUDE_OPEN_HOLD',         -- eco_status
                                'ALL',                       -- examine_type
                                 br.ORGANIZATION_ID,         -- org_id
                                 br.purchase_item_id,        -- item_id
                                 wrs.first_unit_start_date   -- rev_date
                                      ))), /* Fixed Bug# 1623063 */
              msi.primary_uom_code,          -- uom_code
              DECODE(msi.outside_operation_uom_type, -- quantity
               'RESOURCE',ROUND(wor.usage_rate_or_amount *wma.primary_quantity,
                                WIP_CONSTANTS.INV_MAX_PRECISION),
               'ASSEMBLY',wma.primary_quantity),
              3,                             -- line_type_id
              wrs.outside_processing_account,-- charge_account_id
              bd.location_id,                -- deliver_to_location_id
              fu.employee_id,                -- deliver_to_requestor_id
              wor.wip_entity_id,
              wmti.line_id,
              wor.operation_seq_num,
              wor.resource_seq_num,
              wor.resource_id,
              wor.repetitive_schedule_id,
     /* consider post processing lead time before inserting need-by-date */
              (bcd1.calendar_date +
               (DECODE(wo1.next_operation_seq_num,
                  NULL, wo1.last_unit_completion_date,
                  wo2.first_unit_start_date) -
                TRUNC(DECODE(wo1.next_operation_seq_num,
                      NULL, wo1.last_unit_completion_date,
                      wo2.first_unit_start_date)))),  -- need_by_date
              'Y',                           -- autosource_flag
              NULL,                          -- group_code
              msi.buyer_id                   -- suggested_buyer_id
         FROM bom_resources br,
              bom_departments bd,
              bom_calendar_dates bcd1,
              bom_calendar_dates bcd2,
              fnd_user fu,
              mtl_system_items msi,
              mtl_parameters mp,
              hr_organization_information hoi,
              wip_entities we,
              wip_repetitive_schedules wrs,
              wip_operation_resources wor,
              wip_operations wo1,
              wip_operations wo2,
              wip_move_txn_allocations wma,
              wip_move_txn_interface wmti
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND (wmti.overcompletion_transaction_id IS NULL
               OR ( wmti.overcompletion_transaction_id IS NOT NULL
                    AND wmti.overcompletion_transaction_qty IS NOT NULL))
          AND wmti.organization_id = wor.organization_id
          AND wmti.wip_entity_id = wor.wip_entity_id
          AND wmti.to_operation_seq_num = wor.operation_seq_num
          AND wor.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wmti.organization_id = wma.organization_id
          AND wmti.transaction_id = wma.transaction_id
          AND wmti.fm_operation_seq_num < wmti.to_operation_seq_num
          AND wmti.to_intraoperation_step_type = WIP_CONSTANTS.QUEUE
          AND wrs.organization_id = wor.organization_id
          AND wrs.repetitive_schedule_id = wor.repetitive_schedule_id
          AND (wrs.po_creation_time = WIP_CONSTANTS.AT_OPERATION
               OR (wo1.count_point_type = WIP_CONSTANTS.NO_MANUAL
                   AND wrs.po_creation_time <> WIP_CONSTANTS.MANUAL_CREATION))
          AND wo1.organization_id = wmti.organization_id
          AND wo1.wip_entity_id = wmti.wip_entity_id
          AND wo1.operation_seq_num = wmti.to_operation_seq_num
          AND wo1.repetitive_schedule_id = wor.repetitive_schedule_id
          AND wo2.organization_id = wo1.organization_id
          AND wo2.wip_entity_id = wo1.wip_entity_id
          AND wo2.repetitive_schedule_id = wo1.repetitive_schedule_id
       -- Fixed bug 2259661
       --   AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT
       --         AND wo2.operation_seq_num = wmti.to_operation_seq_num)
       --     OR (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE
          AND ((wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                        WIP_CONSTANTS.PO_MOVE))
                AND ((wo1.next_operation_seq_num IS NOT NULL
                      AND wo1.next_operation_seq_num = wo2.operation_seq_num)
                   OR (wo1.next_operation_seq_num IS NULL
                       AND wo2.operation_seq_num = wmti.to_operation_seq_num)))
          AND wor.basis_type = WIP_CONSTANTS.PER_ITEM
          AND wor.organization_id = br.organization_id
          AND wor.resource_id = br.resource_id
          AND br.organization_id = msi.organization_id
          AND br.purchase_item_id = msi.inventory_item_id
          AND wmti.created_by = fu.user_id
          AND wmti.organization_id = bd.organization_id
          /*  Fix for bug 3609023: Corrected condition to ensure we insert
              correct deliver_to_location_id for PO_RECEIPT */
          AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT AND
                wo1.department_id = bd.department_id)
                OR
               (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE AND
                wo2.department_id = bd.department_id))
          AND mp.organization_id = wmti.organization_id
          AND hoi.organization_id = wmti.organization_id
          AND hoi.org_information_context = 'Accounting Information'
          AND we.wip_entity_id = wrs.wip_entity_id
          AND we.organization_id = wrs.organization_id
          -- consider post processing lead time before inserting need-by-date
          AND bcd2.calendar_code = mp.calendar_code
          AND bcd2.exception_set_id = mp.calendar_exception_set_id
          AND bcd2.calendar_date =
              TRUNC(DECODE(wo1.next_operation_seq_num,
                      NULL, wo1.last_unit_completion_date,
                      wo2.first_unit_start_date))
          AND bcd1.calendar_code = mp.calendar_code
          AND bcd1.exception_set_id = mp.calendar_exception_set_id
          AND bcd1.seq_num = (bcd2.next_seq_num -
                              CEIL(NVL(msi.postprocessing_lead_time,0)));

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'PO_REQUISITIONS_INTERFACE_ALL');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF;  -- po requisition per item for schedule

  /*------------------------------------------------------------+
   |  Insert into po_req interface table for per lot for job
   +------------------------------------------------------------*/
  IF(l_move.jobTxn    = WIP_CONSTANTS.YES AND
     l_move.poReqLot = WIP_CONSTANTS.YES) THEN
    -- Fixed bug 5144659. Insert into po_requisitions_interface_all instead of
    -- po_requisitions_interface as part of MOAC change.
    INSERT INTO po_requisitions_interface_all
      (last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       org_id,  /* Operating unit org */
       preparer_id,
       interface_source_code,
       authorization_status,
       source_type_code,
       destination_organization_id,
       destination_type_code,
       item_id,
       item_revision,
       uom_code,
       quantity,
       line_type_id,
       charge_account_id,
       deliver_to_location_id,
       deliver_to_requestor_id,
       wip_entity_id,
       wip_line_id,
       wip_operation_seq_num,
       wip_resource_seq_num,
       bom_resource_id,
       wip_repetitive_schedule_id,
       need_by_date,
       autosource_flag,
       group_code,
       suggested_buyer_id,
       project_id,
       task_id,
       project_accounting_context
       )
       SELECT /* bugfix 5250067 performance fix. removed hint */
              SYSDATE,                       -- last_update_date
              MAX(wmti.last_updated_by),      -- last_updated_by --Fix for bug 5195072
              SYSDATE,                       -- creation_date
              MAX(wmti.created_by),           -- created_by --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              MAX(to_number(hoi.org_information3)),     -- ou_org_id
              MAX(fu.employee_id),           -- preparer_id
              'WIP',                         -- interface_source_code
              'APPROVED',                    -- authorization_status
              'VENDOR',                      -- source_type_code
              wor.organization_id,           -- destination_organization_id
              'SHOP FLOOR',                  -- destination_type_code
              MAX(br.purchase_item_id),      -- item_id
              DECODE(max(msi.revision_qty_control_code), -- item_revision
               1, NULL,
               2, DECODE(MAX(br.purchase_item_id),
                        MAX(wdj.primary_item_id), MAX(wdj.bom_revision),
                        MAX(BOM_revisions.GET_ITEM_REVISION_FN
                                   ('EXCLUDE_OPEN_HOLD',        -- eco_status
                                    'ALL',                      -- examine_type
                                     br.ORGANIZATION_ID,        -- org_id
                                     br.purchase_item_id,       -- item_id
                                     wdj.scheduled_start_date   -- rev_date
                                               )))), /* Fixed Bug# 1623063 */
              MAX(msi.primary_uom_code),     -- uom_code
              DECODE(MAX(msi.outside_operation_uom_type), -- quantity
               'RESOURCE',MAX(ROUND(wor.usage_rate_or_amount,
                                    WIP_CONSTANTS.INV_MAX_PRECISION)),
               'ASSEMBLY', 1),
              3,                             -- line_type_id
              MAX(wdj.outside_processing_account), -- charge_account_id
              MAX(bd.location_id),           -- deliver_to_location_id
              MAX(fu.employee_id),           -- deliver_to_requestor_id
              wor.wip_entity_id,
              MAX(wmti.line_id),
              wor.operation_seq_num,
              wor.resource_seq_num,
              MAX(wor.resource_id),
              wor.repetitive_schedule_id,
              /* Bug 4398047 commenting out this portion of the sql
              DECODE(MAX(wmti.entity_type), -- Fix for 2374334
                WIP_CONSTANTS.LOTBASED, MAX(bcd1.calendar_date),*/
                (MAX(bcd3.calendar_date) +
                (DECODE(MAX(wo1.next_operation_seq_num),
                   NULL, MAX(wo1.last_unit_completion_date),
                   MAX(wo2.first_unit_start_date)) -
                 TRUNC(DECODE(MAX(wo1.next_operation_seq_num),
                         NULL, MAX(wo1.last_unit_completion_date),
                         MAX(wo2.first_unit_start_date))))), -- need_by_date /* Bug 4398047 removed one matching bracket */
              'Y',                           -- autosource_flag
              NULL,                          -- group_code
              MAX(msi.buyer_id),             -- suggested_buyer_id
              wdj.project_id,
              wdj.task_id,
              DECODE(wdj.project_id,NULL,NULL,'Y')-- project_accounting_context
        FROM        /* bugfix 5129403: modified the order in the from clause */
              wip_move_txn_interface wmti,
              wip_operation_resources wor,
              bom_resources br,
              mtl_system_items msi,
              mtl_parameters mp,
           -- bom_calendar_dates bcd2,  Bug 4398047 join no longer required
              bom_calendar_dates bcd4,
           -- bom_calendar_dates bcd1,  Bug 4398047 join no longer required
              bom_calendar_dates bcd3,
              fnd_user fu,
              bom_departments bd,
              hr_organization_information hoi,
              wip_discrete_jobs wdj,
              wip_operations wo1,
              wip_operations wo2
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
               OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)/* WSM */
          AND (wmti.overcompletion_transaction_id IS NULL
               OR ( wmti.overcompletion_transaction_id IS NOT NULL
                    AND wmti.overcompletion_transaction_qty IS NOT NULL))
       --    Bugfix 6679124: Join to wor using wdj rather than wmti to get better execution plan
       --   AND wmti.organization_id = wor.organization_id
       --   AND wmti.wip_entity_id = wor.wip_entity_id
	    AND wdj.organization_id = wor.organization_id       --6679124
            AND wdj.wip_entity_id = wor.wip_entity_id           -- 6679124
          AND wmti.to_operation_seq_num = wor.operation_seq_num
          AND wmti.fm_operation_seq_num < wmti.to_operation_seq_num
          AND wmti.to_intraoperation_step_type = WIP_CONSTANTS.QUEUE
          AND wo1.organization_id = wmti.organization_id
          AND wo1.wip_entity_id = wmti.wip_entity_id
          AND wo1.operation_seq_num = wmti.to_operation_seq_num
          AND wo2.organization_id = wo1.organization_id
          AND wo2.wip_entity_id = wo1.wip_entity_id
       -- Fixed bug 2259661
       --   AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT
       --         AND wo2.operation_seq_num = wmti.to_operation_seq_num)
       --     OR (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE
          AND ((wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                        WIP_CONSTANTS.PO_MOVE))
                AND ((wo1.next_operation_seq_num IS NOT NULL
                      AND wo1.next_operation_seq_num = wo2.operation_seq_num)
                   OR (wo1.next_operation_seq_num IS NULL
                       AND wo2.operation_seq_num = wmti.to_operation_seq_num)))
          AND wdj.organization_id = wmti.organization_id
          AND wdj.wip_entity_id = wmti.wip_entity_id
          AND (wdj.po_creation_time = WIP_CONSTANTS.AT_OPERATION
               OR (wo1.count_point_type = WIP_CONSTANTS.NO_MANUAL
                   AND wdj.po_creation_time <> WIP_CONSTANTS.MANUAL_CREATION))
          AND wor.basis_type = WIP_CONSTANTS.PER_LOT
          AND wor.organization_id = br.organization_id
          AND wor.resource_id = br.resource_id
          AND br.organization_id = msi.organization_id
          AND br.purchase_item_id = msi.inventory_item_id
          AND wmti.created_by = fu.user_id
          AND wmti.organization_id = bd.organization_id
          /*  Fix for bug 3609023: Corrected condition to ensure we insert
              correct deliver_to_location_id for PO_RECEIPT */
          AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT AND
                wo1.department_id = bd.department_id)
                OR
               (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE AND
                wo2.department_id = bd.department_id))
          AND mp.organization_id = wmti.organization_id
          AND hoi.organization_id = wmti.organization_id
          AND hoi.org_information_context = 'Accounting Information'
          /* Bug 4398047 removing the following portion of the sql
          AND bcd2.calendar_code = mp.calendar_code -- Fix for Bug#2374334
          AND bcd2.exception_set_id = mp.calendar_exception_set_id
          AND bcd2.calendar_date = trunc(SYSDATE)
          AND bcd1.calendar_code = mp.calendar_code
          AND bcd1.exception_set_id = mp.calendar_exception_set_id
          AND bcd1.seq_num = (bcd2.next_seq_num +
                CEIL(NVL(msi.preprocessing_lead_time,0) + NVL(msi.fixed_lead_time,0) +
                (NVL(msi.variable_lead_time,0) *
                  DECODE(msi.outside_operation_uom_type,
                        'RESOURCE',
                         wor.usage_rate_or_amount,
                        'ASSEMBLY',
                         1
                        )
                  )
                     +
                 NVL(msi.postprocessing_lead_time,0)))  Bug 4398047 end of commenting */
          -- consider post processing lead time before inserting need-by-date
          AND bcd4.calendar_code = mp.calendar_code
          AND bcd4.exception_set_id = mp.calendar_exception_set_id
          AND bcd4.calendar_date =
              TRUNC(DECODE(wo1.next_operation_seq_num,
                      NULL, wo1.last_unit_completion_date,
                      wo2.first_unit_start_date))
          AND bcd3.calendar_code = mp.calendar_code
          AND bcd3.exception_set_id = mp.calendar_exception_set_id
          AND bcd3.seq_num = (bcd4.next_seq_num -
                              CEIL(NVL(msi.postprocessing_lead_time,0)))
     GROUP BY wor.organization_id,
              wor.wip_entity_id,
              wor.repetitive_schedule_id,
              wor.operation_seq_num,
              wor.resource_seq_num,
              wdj.project_id,
              wdj.task_id
       HAVING 1 =
              DECODE(SIGN(MAX(wo1.quantity_in_queue) -
                              SUM(wmti.primary_quantity)),
              0, DECODE(SIGN(MAX(wo1.quantity_running +
                                 wo1.quantity_waiting_to_move +
                                 wo1.quantity_rejected +
                                 wo1.quantity_scrapped)),
                 0, DECODE(SIGN(MAX(wo1.quantity_completed)),0,1,0),
                 1, 0),
              1, 0);

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'PO_REQUISITIONS_INTERFACE_ALL');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

  END IF;  -- po requisition per lot for job

  /*------------------------------------------------------------+
   | Insert into po_req interface table for per lot for schedule
   +------------------------------------------------------------*/
  IF(l_move.scheTxn  = WIP_CONSTANTS.YES AND
     l_move.poReqLot = WIP_CONSTANTS.YES) THEN
    -- Fixed bug 5144659. Insert into po_requisitions_interface_all instead of
    -- po_requisitions_interface as part of MOAC change.
    INSERT INTO po_requisitions_interface_all
      (last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       org_id,  /* Operating unit org */
       preparer_id,
       interface_source_code,
       authorization_status,
       source_type_code,
       destination_organization_id,
       destination_type_code,
       item_id,
       item_revision,
       uom_code,
       quantity,
       line_type_id,
       charge_account_id,
       deliver_to_location_id,
       deliver_to_requestor_id,
       wip_entity_id,
       wip_line_id,
       wip_operation_seq_num,
       wip_resource_seq_num,
       bom_resource_id,
       wip_repetitive_schedule_id,
       need_by_date,
       autosource_flag,
       group_code,
       suggested_buyer_id
       )
       SELECT SYSDATE,                         -- last_update_date
              MAX(wmti.last_updated_by),        -- last_updated_by --Fix for bug 5195072
              SYSDATE,                         -- creation_date
              MAX(wmti.created_by),             -- created_by --Fix for bug 5195072
              DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
              DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
              DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
              DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
              DECODE(p_gib.request_id,-1,NULL,SYSDATE), -- program_update_date
              MAX(to_number(hoi.org_information3)),     -- ou_org_id
              MAX(fu.employee_id),             -- preparer_id
              'WIP',                           -- interface_source_code
              'APPROVED',                      -- authorization_status
              'VENDOR',                        -- source_type_code
              wor.organization_id,             -- destination_organization_id
              'SHOP FLOOR',                    -- destination_type_code
              MAX(br.purchase_item_id),        -- item_id
              DECODE(MAX(msi.revision_qty_control_code),  -- item_revision
               1, NULL,
               2, DECODE(MAX(br.purchase_item_id),
                        MAX(we.primary_item_id), MAX(wrs.bom_revision),
                        MAX(BOM_revisions.GET_ITEM_REVISION_FN
                                   ('EXCLUDE_OPEN_HOLD',       -- eco_status
                                    'ALL',                     -- examine_type
                                     br.ORGANIZATION_ID,       -- org_id
                                     br.purchase_item_id,      -- item_id
                                     wrs.first_unit_start_date -- rev_date
                                                )))), /* Fixed Bug# 1623063 */
              MAX(msi.primary_uom_code),       -- uom_code
              DECODE(MAX(msi.outside_operation_uom_type), -- quantity
               'RESOURCE',MAX(ROUND(wor.usage_rate_or_amount,
                                    WIP_CONSTANTS.INV_MAX_PRECISION)),
               'ASSEMBLY', 1),
              3,                                -- line_type_id
              MAX(wrs.outside_processing_account), -- charge_account_id
              MAX(bd.location_id),              -- deliver_to_location_id
              MAX(fu.employee_id),              -- deliver_to_requestor_id
              wor.wip_entity_id,
              MAX(wmti.line_id),
              wor.operation_seq_num,
              wor.resource_seq_num,
              MAX(wor.resource_id),
              wor.repetitive_schedule_id,
              (MAX(bcd1.calendar_date) +
                (DECODE(MAX(wo1.next_operation_seq_num),
                   NULL, MAX(wo1.last_unit_completion_date),
                   MAX(wo2.first_unit_start_date)) -
                 TRUNC(DECODE(MAX(wo1.next_operation_seq_num),
                      NULL, MAX(wo1.last_unit_completion_date),
                      MAX(wo2.first_unit_start_date))))), -- need_by_date
              'Y',                              -- autosource_flag
              NULL,                             -- group_code
              MAX(msi.buyer_id)                 -- suggested_buyer_id
         FROM bom_departments bd,
              bom_resources br,
              bom_calendar_dates bcd1,
              bom_calendar_dates bcd2,
              fnd_user fu,
              mtl_item_revisions mir,
              mtl_system_items msi,
              mtl_parameters mp,
              hr_organization_information hoi,
              wip_operation_resources wor,
              wip_repetitive_schedules wrs,
              wip_entities we,
              wip_operations wo1,
              wip_operations wo2,
              wip_move_txn_allocations wma,
              wip_move_txn_interface wmti
        WHERE wmti.group_id = p_gib.group_id
          AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
          AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
          AND wmti.process_status = WIP_CONSTANTS.RUNNING
          AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
          AND (wmti.overcompletion_transaction_id IS NULL
               OR ( wmti.overcompletion_transaction_id IS NOT NULL
                    AND wmti.overcompletion_transaction_qty IS NOT NULL))
          AND wmti.organization_id = wor.organization_id
          AND wmti.wip_entity_id = wor.wip_entity_id
          AND wmti.to_operation_seq_num = wor.operation_seq_num
          AND wor.repetitive_schedule_id = wma.repetitive_schedule_id
          AND wmti.organization_id = wma.organization_id
          AND wmti.transaction_id = wma.transaction_id
          AND wmti.fm_operation_seq_num < wmti.to_operation_seq_num
          AND wmti.to_intraoperation_step_type = WIP_CONSTANTS.QUEUE
          AND wrs.organization_id = wor.organization_id
          AND wrs.repetitive_schedule_id = wor.repetitive_schedule_id
          AND (wrs.po_creation_time = WIP_CONSTANTS.AT_OPERATION
               OR (wo1.count_point_type = WIP_CONSTANTS.NO_MANUAL
                   AND wrs.po_creation_time <> WIP_CONSTANTS.MANUAL_CREATION))
          AND wo1.organization_id = wmti.organization_id
          AND wo1.wip_entity_id = wmti.wip_entity_id
          AND wo1.repetitive_schedule_id = wor.repetitive_schedule_id
          AND wo1.operation_seq_num = wmti.to_operation_seq_num
          AND wo2.organization_id = wo1.organization_id
          AND wo2.wip_entity_id = wo1.wip_entity_id
          AND wo2.repetitive_schedule_id = wo1.repetitive_schedule_id
       -- Fixed bug 2259661
       --   AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT
       --         AND wo2.operation_seq_num = wmti.to_operation_seq_num)
       --     OR (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE
          AND ((wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                        WIP_CONSTANTS.PO_MOVE))
                AND ((wo1.next_operation_seq_num IS NOT NULL
                      AND wo1.next_operation_seq_num = wo2.operation_seq_num)
                   OR (wo1.next_operation_seq_num IS NULL
                       AND wo2.operation_seq_num = wmti.to_operation_seq_num)))
          AND wor.basis_type = WIP_CONSTANTS.PER_LOT
          AND wor.organization_id = br.organization_id
          AND wor.resource_id = br.resource_id
          AND br.organization_id = msi.organization_id
          AND br.purchase_item_id = msi.inventory_item_id
          AND wmti.created_by = fu.user_id
          AND wmti.organization_id = bd.organization_id
          /*  Fix for bug 3609023: Corrected condition to ensure we insert
              correct deliver_to_location_id for PO_RECEIPT */
          AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT AND
                wo1.department_id = bd.department_id)
                OR
               (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE AND
                wo2.department_id = bd.department_id))
          AND mp.organization_id = wmti.organization_id
          AND hoi.organization_id = wmti.organization_id
          AND hoi.org_information_context = 'Accounting Information'
          AND we.wip_entity_id = wrs.wip_entity_id
          AND we.organization_id = wrs.organization_id
          AND mir.inventory_item_id = msi.inventory_item_id
          AND mir.organization_id = msi.organization_id
          AND mir.revision =
              (SELECT MAX(revision)
                 FROM mtl_item_revisions mir1,
                      eng_revised_items eri
                WHERE mir1.inventory_item_id = mir.inventory_item_id
                  AND mir1.organization_id = mir.organization_id
                  AND mir1.effectivity_date <= wmti.transaction_date
                  AND mir1.revised_item_sequence_id =
                      eri.revised_item_sequence_id(+)
                  AND nvl(eri.status_type,0) not in (1,2)
              )
          -- consider post processing lead time before inserting need-by-date
          AND bcd2.calendar_code = mp.calendar_code
          AND bcd2.exception_set_id = mp.calendar_exception_set_id
          AND bcd2.calendar_date =
              TRUNC(DECODE (wo1.next_operation_seq_num,
                      NULL, wo1.last_unit_completion_date,
                      wo2.first_unit_start_date))
          AND bcd1.calendar_code = mp.calendar_code
          AND bcd1.exception_set_id = mp.calendar_exception_set_id
          AND bcd1.seq_num = (bcd2.next_seq_num -
                              CEIL(NVL(msi.postprocessing_lead_time,0)))
     GROUP BY wor.organization_id,
              wor.wip_entity_id,
              wor.repetitive_schedule_id,
              wor.operation_seq_num,
              wor.resource_seq_num
       HAVING 1 =
              DECODE(SIGN(MAX(wo1.quantity_in_queue) -
                              SUM(wma.primary_quantity)),
              0, DECODE(SIGN(MAX(wo1.quantity_running +
                                 wo1.quantity_waiting_to_move +
                                 wo1.quantity_rejected +
                                 wo1.quantity_scrapped)),
                 0, DECODE(SIGN(MAX(wo1.quantity_completed)),0,1,0),
                 1, 0),
              1, 0);

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'PO_REQUISITIONS_INTERFACE_ALL');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;
  END IF;  -- po requisition per lot for schedule

  IF(po_code_release_grp.Current_Release <
     po_code_release_grp.PRC_11i_Family_Pack_J) THEN
    -- Only cut new requisition if customer do not have PO patchset J,
    -- otherwise, try to update PO/requisition instead
    OPEN c_additional_reqs(p_group_id => p_gib.group_id);
    /* for overcompletions - create new reqs for subsequent operations IF
       an overmove has occurred */
    LOOP
      FETCH c_additional_reqs INTO l_additional_reqs;
      EXIT WHEN c_additional_reqs%NOTFOUND;
      -- call PL/SQL API to create additional_req
      wip_osp.create_additional_req
        (p_wip_entity_id          => l_additional_reqs.wip_id,
         p_organization_id        => l_additional_reqs.org_id,
         p_repetitive_schedule_id => l_additional_reqs.rep_sched_id,
         p_added_quantity         => l_additional_reqs.oc_qty,
         p_op_seq                 => l_additional_reqs.op_seq_num);
    END LOOP;
    IF(c_additional_reqs%ISOPEN) THEN
      CLOSE c_additional_reqs;
    END IF;
  END IF; -- check PO patchset
  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.insert_po_req',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    IF(c_additional_reqs%ISOPEN) THEN
      CLOSE c_additional_reqs;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.insert_po_req',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END insert_po_req;

/*****************************************************************************
 * This procedure is equivalent to wip_startwf in wiltps4.ppc
 * This procedure is used to start workflow for OSP stuff
 ****************************************************************************/
PROCEDURE start_workflow(p_gib           IN        group_rec_t,
                         x_returnStatus OUT NOCOPY VARCHAR2) IS

CURSOR c_wmti_txn(p_group_id  NUMBER,
                  p_txn_date  DATE) IS
  SELECT wmti.transaction_id txn_id,
         wmti.wip_entity_id  wip_id,
         wmti.repetitive_schedule_id sched_id,
         wmti.organization_id org_id,
         wmti.primary_quantity pri_qty,
         muom.unit_of_measure pri_uom,
         wmti.to_operation_seq_num op_seq_num,
         wor.autocharge_type autocharge_type
    FROM bom_resources br,
         mtl_units_of_measure muom,
         wip_operation_resources wor,
         wip_operations wo,
         wip_move_txn_interface wmti
   WHERE wmti.group_id = p_group_id
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND TRUNC(wmti.transaction_date)= TRUNC(p_txn_date)
     AND (wmti.fm_operation_seq_num < wmti.to_operation_seq_num
         OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
             AND wmti.fm_intraoperation_step_type <
                 wmti.to_intraoperation_step_type))
     AND wmti.to_intraoperation_step_type = WIP_CONSTANTS.QUEUE
     AND muom.uom_code = wmti.primary_uom
     AND wo.wip_entity_id = wmti.wip_entity_id
     AND wo.organization_id = wmti.organization_id
     AND NVL(wo.repetitive_schedule_id, -1) =
         NVL(wmti.repetitive_schedule_id, -1)
     AND wo.operation_seq_num = wmti.to_operation_seq_num
     AND NOT EXISTS
         (SELECT 'EXISTS'
            FROM po_distributions_all pd,
                 po_line_locations_all ps
           WHERE pd.wip_entity_id = wo.wip_entity_id
             AND NVL(pd.wip_repetitive_schedule_id, -1) =
                 NVL(wo.repetitive_schedule_id, -1)
             AND pd.wip_operation_seq_num = wo.previous_operation_seq_num
             AND ps.line_location_id = pd.line_location_id
             AND ps.ship_to_location_id IN
                (SELECT location_id
                   FROM po_location_associations_all
                  WHERE vENDor_id IS NOT NULL
                    AND vENDor_site_id IS NOT NULL))
     AND wor.wip_entity_id = wo.wip_entity_id
     AND wor.organization_id = wo.organization_id
     AND NVL(wor.repetitive_schedule_id, -1) =
         NVL(wo.repetitive_schedule_id, -1)
     AND wor.operation_seq_num = wo.operation_seq_num
     AND wor.autocharge_type in(WIP_CONSTANTS.PO_MOVE, --Fix for 2393550
                                WIP_CONSTANTS.PO_RECEIPT)
     AND br.resource_id = wor.resource_id
     AND br.organization_id = wor.organization_id
     AND br.purchase_item_id IS NOT NULL;

l_params            wip_logger.param_tbl_t;
l_returnStatus      VARCHAR(1);
l_errMsg            VARCHAR2(240);
l_wmti_txn          c_wmti_txn%ROWTYPE;
l_itemkey           VARCHAR2(80) := NULL;
l_logLevel          NUMBER := fnd_log.g_current_runtime_level;
l_success           NUMBER := 0;
l_org_id number;
l_ou_id number;
l_org_acct_ctxt VARCHAR2(30):= 'Accounting Information';
 l_req_import VARCHAR2(20); --8919025(Fp 8850950)

-- new parameter used to determine whether we have to launch "Req Import"
-- concurrent program or not
l_osp_exist         NUMBER := WIP_CONSTANTS.NO;
l_launch_req_import NUMBER := WIP_CONSTANTS.YES;
BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.start_workflow',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;
  OPEN c_wmti_txn(p_group_id  => p_gib.group_id,
                  p_txn_date  => p_gib.txn_date);
  LOOP
    FETCH c_wmti_txn INTO l_wmti_txn;
    EXIT WHEN c_wmti_txn%NOTFOUND;

    l_osp_exist := WIP_CONSTANTS.YES;
    l_org_id := l_wmti_txn.org_id;

    IF(l_wmti_txn.autocharge_type = WIP_CONSTANTS.PO_MOVE) THEN
      -- Launch workflow only for PO_MOVE
      -- call PL/SQL API to start workflow

      -- Fixed bug 5333089. Need to set org context before launching workflow
      -- because Req Import need this information.
      -- get the OU, set context for MOAC. Need to set it for each PO Move
      -- record found.
      select to_number(ORG_INFORMATION3) into l_ou_id
        from HR_ORGANIZATION_INFORMATION
       where ORGANIZATION_ID = l_org_id
         and ORG_INFORMATION_CONTEXT = l_org_acct_ctxt;
      FND_REQUEST.SET_ORG_ID (l_ou_id);

      wip_osp_shp_i_wf.StartWFProcess
        (p_itemtype         => 'WIPISHPW',
         p_itemkey          => l_itemkey,
         p_workflow_process => 'INTERMEDIATE_SHIP',
         p_wip_entity_id    => l_wmti_txn.wip_id,
         p_rep_sched_id     => l_wmti_txn.sched_id,
         p_organization_id  => l_wmti_txn.org_id,
         p_primary_qty      => l_wmti_txn.pri_qty,
         p_primary_uom      => l_wmti_txn.pri_uom,
         p_op_seq_num       => l_wmti_txn.op_seq_num);

      IF l_itemkey IS NOT NULL THEN
        UPDATE wip_move_transactions
           SET wf_itemtype = 'WIPISHPW',
               wf_itemkey  = l_itemkey
         WHERE transaction_id = l_wmti_txn.txn_id;
      END IF;
      -- No need to lauch "Req Import" again if we already laucned the workflow
      -- because "Req Import" is part of the workflow itself.
      l_launch_req_import := WIP_CONSTANTS.NO;
      -- Fix for Bug#4369684. Need to reassign to null for multiple OSP Move.
      l_itemkey := NULL;
    END IF; -- PO_MOVE
  END LOOP;

  -- If OSP item exists, and there is no workflow launch yet, we have to launch
  -- "Req Import" concurrent program
  IF(l_osp_exist = WIP_CONSTANTS.YES AND
     l_launch_req_import = WIP_CONSTANTS.YES) THEN

    -- get the OU, set context for MOAC
    select to_number(ORG_INFORMATION3) into l_ou_id
      from HR_ORGANIZATION_INFORMATION
     where ORGANIZATION_ID = l_org_id
       and ORG_INFORMATION_CONTEXT = l_org_acct_ctxt;
    FND_REQUEST.SET_ORG_ID (l_ou_id);

    /*Fix for bug 8919025(Fp 8850950)*/
    BEGIN
      select reqimport_group_by_code
      into l_req_import
      from po_system_parameters_all
      where org_id = l_ou_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
 	       raise fnd_api.g_exc_unexpected_error;
    END;

    l_success := fnd_request.submit_request(
        'PO', 'REQIMPORT', NULL, NULL, FALSE,'WIP', NULL, l_req_import, --fix bug 8919025(Fp 8850950)
        NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        ) ;
    -- We can just ignore the return status
  END IF; -- all OSP are PO_RECEIPT

  IF(c_wmti_txn%ISOPEN) THEN
    CLOSE c_wmti_txn;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_success;
  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.start_workflow',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION

  WHEN others THEN
    IF(c_wmti_txn%ISOPEN) THEN
      CLOSE c_wmti_txn;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.start_workflow',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END start_workflow;

/*****************************************************************************
 * This procedure is equivalent to witpsuc_op_units_complete in wiltps5.ppc
 * This procedure is used to update operation unit complete in
 * WIP_OPERATIONS
 ****************************************************************************/
PROCEDURE update_complete_qty(p_gib           IN        group_rec_t,
                              p_txn_id        IN        NUMBER := NULL,
                              x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_msg          VARCHAR(240);
l_errMsg       VARCHAR2(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    l_params(3).paramName   := 'p_txn_id';
    l_params(3).paramValue  :=  p_txn_id;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.update_complete_qty',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  /*------------------------------------------------------------+
   |  Update quantity_completed
   +------------------------------------------------------------*/
   UPDATE wip_operations wop
     SET (quantity_completed,
          last_updated_by,
          last_update_date,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date
         ) =
         (SELECT decode(wop.repetitive_schedule_id,null, /* Bugfix 6333820 FP for 5987013: decode between 4081320 fix (for discrete) and original code (for repetitive) to allow negative quantity_completed for repetitive and rail at 0 for discrete */
                greatest(0, wop.quantity_completed + -- added greatest function to fix FP bug 4081320
                   NVL(SUM(NVL(wma1.primary_quantity, wmti.primary_quantity) *
                   DECODE(SIGN(wmti.to_operation_seq_num -
                               wmti.fm_operation_seq_num),
                   0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),
                     0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                   WIP_CONSTANTS.RUN),1,1,-1),
                    -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                   WIP_CONSTANTS.RUN),1,1,-1),
                     1,-1),
                   1, 1,
                  -1,-1)
                   ),0)), /* for discrete */
		wop.quantity_completed + -- added greatest function to fix FP bug 4081320
                   NVL(SUM(NVL(wma1.primary_quantity, wmti.primary_quantity) *
                   DECODE(SIGN(wmti.to_operation_seq_num -
                               wmti.fm_operation_seq_num),
                   0,DECODE(SIGN(wmti.fm_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),
                     0,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                   WIP_CONSTANTS.RUN),1,1,-1),
                    -1,DECODE(SIGN(wmti.to_intraoperation_step_type -
                                   WIP_CONSTANTS.RUN),1,1,-1),
                     1,-1),
                   1, 1,
                  -1,-1)
                   ),0) /* for repetitive */
                   ),    -- quantity_completed
                 MAX(wmti.last_updated_by),
                 SYSDATE,              -- last_update_date
                 DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
                 DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                 DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                 DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                 DECODE(p_gib.request_id,-1,NULL,SYSDATE)-- program_update_date
            FROM wip_operations wop1,
                 wip_move_txn_allocations wma1,
                 wip_move_txn_interface wmti
           WHERE wop1.rowid = wop.rowid
             AND wmti.group_id = p_gib.group_id
             AND (p_txn_id IS NULL OR wmti.transaction_id = p_txn_id)
             AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
             AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
             AND wmti.process_status = WIP_CONSTANTS.RUNNING
             AND wop1.organization_id = wmti.organization_id
             AND wop1.wip_entity_id = wmti.wip_entity_id
             AND wmti.organization_id = wma1.organization_id (+)
             AND wmti.transaction_id = wma1.transaction_id (+)
             AND NVL(wma1.repetitive_schedule_id,0) =
                 NVL(wop1.repetitive_schedule_id,0)
             AND ((wop1.operation_seq_num >= wmti.fm_operation_seq_num
                 + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                               WIP_CONSTANTS.RUN),1,1,0)
               AND wop1.operation_seq_num < wmti.to_operation_seq_num
                   + DECODE(SIGN(wmti.to_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),1,1,0)
               AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                  OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                      AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
               AND (wop1.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR wop1.operation_seq_num = wmti.fm_operation_seq_num
                  OR (wop1.operation_seq_num = wmti.to_operation_seq_num
                     AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN)))
               OR
                  (wop1.operation_seq_num < wmti.fm_operation_seq_num
                 + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                               WIP_CONSTANTS.RUN),1,1,0)
               AND wop1.operation_seq_num >= wmti.to_operation_seq_num
                   + DECODE(SIGN(wmti.to_intraoperation_step_type -
                                 WIP_CONSTANTS.RUN),1,1,0)
               AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                  OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                      AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                      AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
               AND (wop1.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR (wop1.operation_seq_num = wmti.to_operation_seq_num)
                  /*Fix bug 9538314(fp of 9344254) ,revert the fix of bug 1834450 as it caused regression*/
--/*fix bug 1834450*/   AND wop1.count_point_type < WIP_CONSTANTS.NO_MANUAL )
                  OR (wop1.operation_seq_num = wmti.fm_operation_seq_num
                     AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN)))
                 ))
    WHERE wop.rowid IN
         (SELECT wop2.rowid
            FROM wip_operations wop2,
                 wip_move_txn_allocations wma2,
                 wip_move_txn_interface wmti
           WHERE wop2.organization_id = wmti.organization_id
             AND wmti.group_id = p_gib.group_id
             AND (p_txn_id IS NULL OR wmti.transaction_id = p_txn_id)
             AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
             AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
             AND wmti.process_status = WIP_CONSTANTS.RUNNING
             AND wop2.organization_id = wmti.organization_id
             AND wop2.wip_entity_id = wmti.wip_entity_id
             AND wmti.organization_id = wma2.organization_id (+)
             AND wmti.transaction_id = wma2.transaction_id (+)
             AND NVL(wma2.repetitive_schedule_id,0) =
                 NVL(wop2.repetitive_schedule_id,0)
             AND ((wop2.operation_seq_num >= wmti.fm_operation_seq_num
                 + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                               WIP_CONSTANTS.RUN),1,1,0)
               AND wop2.operation_seq_num < wmti.to_operation_seq_num
                  + DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,0)
               AND (wmti.to_operation_seq_num > wmti.fm_operation_seq_num
                  OR (wmti.to_operation_seq_num = wmti.fm_operation_seq_num
                     AND wmti.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                     AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
               AND (wop2.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR wop2.operation_seq_num = wmti.fm_operation_seq_num
                  OR (wop2.operation_seq_num = wmti.to_operation_seq_num
                     AND wmti.to_intraoperation_step_type > WIP_CONSTANTS.RUN)))
             OR
                  (wop2.operation_seq_num < wmti.fm_operation_seq_num
                 + DECODE(SIGN(wmti.fm_intraoperation_step_type -
                               WIP_CONSTANTS.RUN),1,1,0)
               AND wop2.operation_seq_num >= wmti.to_operation_seq_num
                  + DECODE(SIGN(wmti.to_intraoperation_step_type -
                                WIP_CONSTANTS.RUN),1,1,0)
               AND (wmti.fm_operation_seq_num > wmti.to_operation_seq_num
                  OR (wmti.fm_operation_seq_num = wmti.to_operation_seq_num
                     AND wmti.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                     AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
               AND (wop2.count_point_type < WIP_CONSTANTS.NO_MANUAL
                  OR (wop2.operation_seq_num = wmti.to_operation_seq_num)
                  /*Fix bug 9538314(fp of 9344254) ,revert the fix of bug 1834450 as it caused regression*/
--/*fix bug 1834450*/  AND wop2.count_point_type < WIP_CONSTANTS.NO_MANUAL)
                  OR (wop2.operation_seq_num = wmti.fm_operation_seq_num
                     AND wmti.fm_intraoperation_step_type > WIP_CONSTANTS.RUN)))
                 ));

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'WIP_OPERATIONS');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.update_complete_qty',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.update_complete_qty',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END update_complete_qty;

/*****************************************************************************
 * This procedure is equivalent to wit_op_snapshot in wiltps5.ppc
 * This procedure is used to call Costing snapshot CSTACOSN.op_snapshot
 ****************************************************************************/
PROCEDURE op_snapshot(p_mtl_temp_id   IN        NUMBER,
                      x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params           wip_logger.param_tbl_t;
l_returnStatus     VARCHAR(1);
l_returnValue      NUMBER;
l_msgCount         NUMBER;
l_errCode          VARCHAR(240);
l_errMsg           VARCHAR(240);
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_mtl_temp_id';
    l_params(1).paramValue  :=  p_mtl_temp_id;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.op_snapshot',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  l_returnValue := CSTACOSN.op_snapshot
                           (i_txn_temp_id  => p_mtl_temp_id,
                            err_num        => l_msgCount,
                            err_code       => l_errCode,
                            err_msg        => l_errMsg);
  IF(l_returnValue <> 1) THEN
     l_errMsg := 'CSTACOSN.op_snapshot failed';
     raise fnd_api.g_exc_unexpected_error;
  END IF;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.op_snapshot',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.op_snapshot',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

    fnd_message.set_name('CST', l_errCode);
    fnd_msg_pub.add;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.op_snapshot',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END op_snapshot;

/*****************************************************************************
 * This procedure is equivalent to wit_snapshot_online in wiltps5.ppc
 * This procedure is used to call Costing snapshot
 ****************************************************************************/
PROCEDURE snapshot_online(p_mtl_header_id  IN        NUMBER,
                          p_org_id         IN        NUMBER,
                          p_txn_type       IN        NUMBER,
                          p_txn_type_id    IN        NUMBER,
                          p_txn_action_id  IN        NUMBER,
                          x_returnStatus  OUT NOCOPY VARCHAR2) IS

CURSOR c_mmtt IS
  SELECT transaction_temp_id mtl_temp_id
    FROM mtl_material_transactions_temp
   WHERE transaction_header_id = p_mtl_header_id
     AND transaction_action_id = p_txn_action_id
     AND transaction_type_id = p_txn_type_id
     AND transaction_source_type_id = TPS_INV_JOB_OR_SCHED
     AND (wip_entity_type = WIP_CONSTANTS.DISCRETE
          OR wip_entity_type = WIP_CONSTANTS.LOTBASED)  /*WSM */
   ORDER BY transaction_date, transaction_source_id; /*Bug 7314913: Added order by clause*/

l_params               wip_logger.param_tbl_t;
l_returnStatus         VARCHAR(1);
l_errMsg               VARCHAR(240);
l_pri_cost_method      NUMBER;
l_mandatory_scrap_flag NUMBER;
l_mmtt                 c_mmtt%ROWTYPE;
l_logLevel             NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_mtl_header_id';
    l_params(1).paramValue  :=  p_mtl_header_id;
    l_params(2).paramName   := 'p_org_id';
    l_params(2).paramValue  :=  p_org_id;
    l_params(3).paramName   := 'p_txn_type';
    l_params(3).paramValue  :=  p_txn_type;
    l_params(4).paramName   := 'p_txn_type_id';
    l_params(4).paramValue  :=  p_txn_type_id;
    l_params(5).paramName   := 'p_txn_action_id';
    l_params(5).paramValue  :=  p_txn_action_id;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.snapshot_online',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- get primary cost method
  SELECT mp.primary_cost_method
    INTO l_pri_cost_method
    FROM mtl_parameters mp
   WHERE mp.organization_id = p_org_id;

  -- get mandatoty scrap flag
  SELECT wp.mandatory_scrap_flag
    INTO l_mandatory_scrap_flag
    FROM wip_parameters wp
   WHERE wp.organization_id = p_org_id;

  IF((l_pri_cost_method = WIP_CONSTANTS.COST_AVG  OR
      l_pri_cost_method = WIP_CONSTANTS.COST_FIFO OR
      l_pri_cost_method = WIP_CONSTANTS.COST_LIFO)
     AND
     (p_txn_type = WIP_CONSTANTS.COMP_TXN OR
      p_txn_type = WIP_CONSTANTS.RET_TXN  OR
      p_txn_type = WIP_CONSTANTS.MOVE_TXN)) THEN

      -- Fix bug 2369642
      --(p_txn_type = WIP_CONSTANTS.MOVE_TXN AND
      -- l_mandatory_scrap_flag = WIP_CONSTANTS.YES))) THEN

    UPDATE mtl_material_transactions_temp
       SET transaction_temp_id = mtl_material_transactions_s.nextval
     WHERE transaction_header_id = p_mtl_header_id
       AND transaction_temp_id IS NULL
       AND transaction_action_id = p_txn_action_id
       AND transaction_type_id = p_txn_type_id
       AND transaction_source_type_id = TPS_INV_JOB_OR_SCHED
       AND (wip_entity_type = WIP_CONSTANTS.DISCRETE
            OR wip_entity_type = WIP_CONSTANTS.LOTBASED);  /*WSM*/

    FOR l_mmtt IN c_mmtt LOOP
      op_snapshot(p_mtl_temp_id   => l_mmtt.mtl_temp_id,
                  x_returnStatus  => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_movProc_priv.op_snapshot failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status
    END LOOP; -- END for loop
  END IF;

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.snapshot_online',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.snapshot_online',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.snapshot_online',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END snapshot_online;

/*****************************************************************************
 * This procedure is equivalent to wit_snapshot_background in wiltps5.ppc
 * This procedure is used to call Costing snapshot
 ****************************************************************************/
PROCEDURE snapshot_background(p_group_id      IN        NUMBER,
                              p_txn_id        IN        NUMBER := NULL,
                              p_txn_date      IN        DATE,
                              x_returnStatus OUT NOCOPY VARCHAR2) IS

 /* Fixed Bug# 1480410 -
    Added source_code field in following cursor.
    --
    This is applicable for only Average Costing case
    --

    The original condition was treating records inserted from the receiving
    transactions for osp item as records inserted from the open interface
    process and thus validating against cst_comp_snap_temp table and erroring
    out as there is no record. This fix would treat records inserted into
    wip_move_txn_interface by receiving transaction as created from the WIP
    and thus will create a record in the cst_comp_snap_temp.
*/

CURSOR c_txns IS
   SELECT wmti.transaction_id txn_id,
          mmtt.transaction_temp_id mtl_temp_id,
          DECODE(NVL(wmti.source_line_id,-1),
           -1, 2,
            1) load_from_interface,
          DECODE(NVL(wmti.source_code,'WIP'),
           'WIP', -1,
           'RCV', -1,
            1) source_code,
          MMTT.PRIMARY_QUANTITY primary_quantity
     FROM wip_move_txn_interface wmti,
          mtl_material_transactions_temp mmtt,
          mtl_parameters mp
    WHERE wmti.group_id = p_group_id
      AND (p_txn_id IS NULL OR wmti.transaction_id = p_txn_id)
      AND TRUNC(wmti.transaction_date) = TRUNC(p_txn_date)
      AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
      AND wmti.process_status = WIP_CONSTANTS.RUNNING
      AND mmtt.move_transaction_id = wmti.transaction_id
      /* Improve performance */
      AND mmtt.organization_id = wmti.organization_id
      AND mmtt.transaction_source_id = wmti.wip_entity_id
      AND mmtt.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
      /* End Improve performance */
      AND mmtt.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                   WIP_CONSTANTS.LOTBASED)  /*WSM */
      -- Fixed bug2515712 (do not insert component related record)
      AND mmtt.transaction_action_id IN (WIP_CONSTANTS.SCRASSY_ACTION,
                                         WIP_CONSTANTS.RETASSY_ACTION,
                                         WIP_CONSTANTS.CPLASSY_ACTION)
      AND mp.organization_id = wmti.organization_id
      AND mp.primary_cost_method IN (WIP_CONSTANTS.COST_AVG,
                                     WIP_CONSTANTS.COST_FIFO,
                                     WIP_CONSTANTS.COST_LIFO)
      AND (((wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
             OR wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
             AND wmti.scrap_account_id IS NOT NULL)
             -- Fix bug 2369642
             -- AND wp.mandatory_scrap_flag = WIP_CONSTANTS.YES)
           OR
            (wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                      WIP_CONSTANTS.RET_TXN)));

l_params          wip_logger.param_tbl_t;
l_returnStatus    VARCHAR(1);
l_errMsg          VARCHAR(240);
l_errCode         VARCHAR(240);
l_txns            c_txns%ROWTYPE;
l_num_snapshot    NUMBER;
l_returnValue     NUMBER;
l_interface_table NUMBER;
l_msgCount        NUMBER;
l_logLevel        NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_txn_date;
    l_params(3).paramName   := 'p_txn_id';
    l_params(3).paramValue  :=  p_txn_id;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.snapshot_background',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- check for snapshot transactions through the interface
  SELECT COUNT(*)
    INTO l_num_snapshot
    FROM wip_move_txn_interface wmti,
         mtl_parameters mp
        -- wip_parameters wp
   WHERE wmti.group_id = p_group_id
     AND wmti.process_phase  = WIP_CONSTANTS.MOVE_PROC
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.organization_id = mp.organization_id
     AND mp.primary_cost_method IN (WIP_CONSTANTS.COST_AVG,
                                    WIP_CONSTANTS.COST_FIFO,
                                    WIP_CONSTANTS.COST_LIFO)
     --AND wp.organization_id = wmti.organization_id
     AND (((wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
            OR wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
            AND wmti.scrap_account_id IS NOT NULL)
          --  AND wp.mandatory_scrap_flag = WIP_CONSTANTS.YES)
          OR
           (wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                     WIP_CONSTANTS.RET_TXN)));

  IF(l_num_snapshot = 0) THEN
    GOTO END_txn;
  END IF;

  UPDATE mtl_material_transactions_temp mmtt1
     SET mmtt1.transaction_temp_id = mtl_material_transactions_s.nextval
   WHERE mmtt1.rowid IN
        (SELECT mmtt1.rowid
           FROM wip_move_txn_interface wmti,
              --  wip_parameters wp,
                mtl_parameters mp,
                mtl_material_transactions_temp mmtt2
          WHERE wmti.group_id = p_group_id
            AND TRUNC(wmti.transaction_date) = TRUNC(p_txn_date)
            AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
            AND wmti.process_status = WIP_CONSTANTS.RUNNING
            AND mmtt2.organization_id = wmti.organization_id
            AND mmtt2.transaction_source_id = wmti.wip_entity_id
            AND mmtt2.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
           -- AND wp.organization_id = wmti.organization_id
            AND mp.organization_id = wmti.organization_id
            AND mp.primary_cost_method IN (WIP_CONSTANTS.COST_AVG,
                                           WIP_CONSTANTS.COST_FIFO,
                                           WIP_CONSTANTS.COST_LIFO)
            AND (((wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
                   OR wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
                  AND wmti.scrap_account_id IS NOT NULL)
                 --  AND wp.mandatory_scrap_flag = WIP_CONSTANTS.YES)
                 OR
                  (wmti.transaction_type IN (WIP_CONSTANTS.COMP_TXN,
                                            WIP_CONSTANTS.RET_TXN))))
     AND mmtt1.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
     AND mmtt1.transaction_temp_id IS NULL;

  l_interface_table := 2; -- MOVE_TXN_INTERFACE

  FOR l_txns IN c_txns LOOP
    IF(l_txns.load_from_interface = 1 AND
       l_txns.source_code = 1) THEN
      l_returnValue :=  CSTPACMS.validate_move_snap_to_temp
                              (l_txn_interface_id  => l_txns.txn_id,
                               l_txn_temp_id       => l_txns.mtl_temp_id,
                               l_interface_table   => l_interface_table,
                               l_primary_quantity  => l_txns.primary_quantity,
                               err_num             => l_msgCount,
                               err_code            => l_errCode,
                               err_msg             => l_errMsg);

      IF(l_returnValue <> 1) THEN
        fnd_message.set_name('CST', l_errCode);
        fnd_msg_pub.add;
        l_errMsg := 'CSTACOSN.validate_move_snap_to_temp failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status
    ELSE
      op_snapshot(p_mtl_temp_id   => l_txns.mtl_temp_id,
                  x_returnStatus  => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_movProc_priv.op_snapshot failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status
    END IF; -- check load from interface and source code
  END LOOP;

<<END_txn>>
  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.snapshot_background',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName =>'wip_movProc_priv.snapshot_background',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.snapshot_background',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END snapshot_background;

/*****************************************************************************
 * This procedure will be used to update quantity_completed, and take snapshot
 * of wip_operations if applicable(LIFO, FIFO, and average costing)
 ****************************************************************************/
PROCEDURE update_wo_and_snapshot(p_gib           IN        group_rec_t,
                                 x_returnStatus OUT NOCOPY VARCHAR2) IS
 CURSOR c_move_rec IS
   SELECT wmti.transaction_id txn_id
     FROM wip_move_txn_interface wmti
    WHERE wmti.group_id = p_gib.group_id
      AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
      AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
      AND wmti.process_status = WIP_CONSTANTS.RUNNING
 ORDER BY wmti.transaction_date;

l_move_rec     c_move_rec%ROWTYPE;
l_returnStatus VARCHAR(1);
l_errMsg       VARCHAR(240);
l_params       wip_logger.param_tbl_t;
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
BEGIN
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_gib.group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_gib.txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    l_params(3).paramName   := 'p_gib.seq_move';
    l_params(3).paramValue  :=  p_gib.seq_move;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.update_wo_and_snapshot',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  IF(p_gib.seq_move = WIP_CONSTANTS.YES) THEN
    -- update quantity_completed and take snapshot one record at a time
    FOR l_move_rec IN c_move_rec LOOP
      update_complete_qty(p_gib          => p_gib,
                          p_txn_id       => l_move_rec.txn_id,
                          x_returnStatus => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_movProc_priv.update_complete_qty failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status

      snapshot_background(p_group_id      => p_gib.group_id,
                          p_txn_id        => l_move_rec.txn_id,
                          p_txn_date      => p_gib.txn_date,
                          x_returnStatus  => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_movProc_priv.snapshot_background failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status
    END LOOP;
  ELSE
    -- update quantity_completed and take snapshot for the whole group
    update_complete_qty(p_gib          => p_gib,
                        x_returnStatus => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_movProc_priv.update_complete_qty failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF; -- check return status

    snapshot_background(p_group_id      => p_gib.group_id,
                        p_txn_date      => p_gib.txn_date,
                        x_returnStatus  => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_movProc_priv.snapshot_background failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF; -- check return status
  END IF;

  x_returnStatus := fnd_api.g_ret_sts_success;
  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName =>'wip_movProc_priv.update_wo_and_snapshot',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName =>'wip_movProc_priv.update_wo_and_snapshot',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.update_wo_and_snapshot',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END update_wo_and_snapshot;

/*****************************************************************************
 * This procedure is equivalent to witpsst_scrap_txns in wiltps5.ppc
 * This procedure is used to update scrap quantity in WIP_DISCRETE_JOBS for
 * discrete and OSFM jobs, and WIP_REPETITIVE_SCHEDULES for repetitive
 * schedules.
 * This procedure also insert into MTL_MATERIAL_TRANSACTIONS_TEMP for costing
 * purpose IF the user provide scrap account.
 ****************************************************************************/
PROCEDURE scrap_txns(p_gib       IN OUT NOCOPY group_rec_t,
                     x_returnStatus OUT NOCOPY VARCHAR2) IS

CURSOR c_mtl_alloc IS
  SELECT wmti.transaction_id txn_id,
         wmti.organization_id org_id,
         mmtt.material_allocation_temp_id alloc_id
    FROM wip_move_txn_interface wmti,
         mtl_material_transactions_temp mmtt
   WHERE wmti.transaction_id = mmtt.move_transaction_id
     /* Improve performance */
     AND mmtt.organization_id = wmti.organization_id
     AND mmtt.transaction_source_id = wmti.wip_entity_id
     AND mmtt.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
     /* End Improve performance */
     AND wmti.group_id = p_gib.group_id
     AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
     AND wmti.scrap_account_id IS NOT NULL
     AND (wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP OR
          wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP);

CURSOR c_update_po IS
  SELECT wmti.wip_entity_id job_id,
         DECODE(wmti.entity_type,
                WIP_CONSTANTS.REPETITIVE, wmta.repetitive_schedule_id,
                NULL) rep_id,
         wmti.organization_id org_id,
         DECODE (wmti.fm_intraoperation_step_type,
           WIP_CONSTANTS.SCRAP,DECODE(wmti.entity_type,
                                WIP_CONSTANTS.REPETITIVE,wmta.primary_quantity,
                                wmti.primary_quantity),
           -1 * DECODE(wmti.entity_type,
                  WIP_CONSTANTS.REPETITIVE, wmta.primary_quantity,
                  wmti.primary_quantity)) changed_qty,
         GREATEST(wmti.fm_operation_seq_num, wmti.to_operation_seq_num) fm_op
    FROM wip_move_txn_interface wmti,
         wip_move_txn_allocations wmta,
         wip_parameters mp
   WHERE wmti.transaction_id = wmta.transaction_id (+)
     AND wmti.organization_id = wmta.organization_id (+)
     AND wmti.group_id = p_gib.group_id
     AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
     AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
     AND wmti.process_status = WIP_CONSTANTS.RUNNING
     AND (wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP OR
          wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
     AND NOT(wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP AND
             wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
     AND mp.organization_id = wmti.organization_id
     AND mp.propagate_job_change_to_po = WIP_CONSTANTS.YES;


l_params           wip_logger.param_tbl_t;
l_mtl_alloc        c_mtl_alloc%ROWTYPE;
l_returnStatus     VARCHAR(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_errMsg           VARCHAR(240);
l_msg              VARCHAR(2000);
l_scrap_flag       NUMBER := -1;
l_step             NUMBER;
l_transaction_mode NUMBER;
l_move             move_profile_rec_t;
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;
l_update_po        c_update_po%ROWTYPE;
l_osp_op_seq_num   NUMBER;      --fix bug 6607192
l_update_po_qty    NUMBER;
BEGIN
  l_move := p_gib.move_profile;

  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    l_params(3).paramName   := 'org_id';
    l_params(3).paramValue  :=  l_move.org_id;
    l_params(4).paramName   := 'wip_id';
    l_params(4).paramValue  :=  l_move.wip_id;
    l_params(5).paramName   := 'fmOp';
    l_params(5).paramValue  :=  l_move.fmOp;
    l_params(6).paramName   := 'fmStep';
    l_params(6).paramValue  :=  l_move.fmStep;
    l_params(7).paramName   := 'toOp';
    l_params(7).paramValue  :=  l_move.toOp;
    l_params(8).paramName   := 'toStep';
    l_params(8).paramValue  :=  l_move.toStep;
    l_params(9).paramName   := 'scrapTxn';
    l_params(9).paramValue  :=  l_move.scrapTxn;
    l_params(10).paramName  := 'easyComplete';
    l_params(10).paramValue :=  l_move.easyComplete;
    l_params(11).paramName  := 'easyReturn';
    l_params(11).paramValue :=  l_move.easyReturn;
    l_params(12).paramName  := 'jobTxn';
    l_params(12).paramValue :=  l_move.jobTxn;
    l_params(13).paramName  := 'scheTxn';
    l_params(13).paramValue :=  l_move.scheTxn;
    l_params(14).paramName  := 'rsrcItem';
    l_params(14).paramValue :=  l_move.rsrcItem;
    l_params(15).paramName  := 'rsrcLot';
    l_params(15).paramValue :=  l_move.rsrcLot;
    l_params(16).paramName  := 'poReqItem';
    l_params(16).paramValue :=  l_move.poReqItem;
    l_params(17).paramName  := 'poRegLot';
    l_params(17).paramValue :=  l_move.poReqLot;
    l_params(18).paramName  := 'p_mtl_header_id';
    l_params(18).paramValue :=  p_gib.mtl_header_id;
    l_params(19).paramName  := 'p_move_mode';
    l_params(19).paramValue :=  p_gib.move_mode;
    l_params(20).paramName  := 'p_mtl_mode';
    l_params(20).paramValue :=  p_gib.mtl_mode;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.scrap_txns',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- Any scrap transaction?
  IF(l_move.scrapTxn <> WIP_CONSTANTS.YES AND
     l_move.scrapTxn <> WIP_CONSTANTS.NO) THEN -- Indeterminate

    SELECT COUNT(1)
      INTO l_scrap_flag
      FROM wip_move_txn_interface
     WHERE group_id = p_gib.group_id
       AND TRUNC(transaction_date) = TRUNC(p_gib.txn_date)
       AND process_phase = WIP_CONSTANTS.MOVE_PROC
       AND process_status = WIP_CONSTANTS.RUNNING
       AND (fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
            OR to_intraoperation_step_type = WIP_CONSTANTS.SCRAP);

    IF (l_scrap_flag > 0) THEN
      l_move.scrapTxn := WIP_CONSTANTS.YES;
    ELSE
      l_move.scrapTxn := WIP_CONSTANTS.NO;
    END IF;

  END IF; -- scrap txn indeterminate

  -- Scrap transaction
  IF(l_move.scrapTxn = WIP_CONSTANTS.YES) THEN
    /*------------------------------------------------------------+
     |  Update scrap quantity for discrete jobs
     +------------------------------------------------------------*/
    IF(l_move.jobTxn = WIP_CONSTANTS.YES) THEN

/** 3050846 **/
       wip_so_reservations.scrap_txn_relieve_rsv ( p_group_id      =>   p_gib.group_id,
                                                 x_return_status =>   l_returnstatus,
                                                 x_msg_count     =>   l_msg_count,
                                                 x_msg_data      =>   l_msg_data
                                                 );
       IF (l_returnstatus <> fnd_api.g_ret_sts_success) THEN
         IF (l_returnstatus = fnd_api.g_ret_sts_error) THEN
             fnd_msg_pub.count_and_get(
                   p_encoded => fnd_api.g_false,
                   p_count   => l_msg_count,
                   p_data    => l_errmsg);
            RAISE fnd_api.g_exc_error;
         ELSE
             fnd_msg_pub.count_and_get(
                   p_encoded => fnd_api.g_false,
                   p_count   => l_msg_count,
                   p_data    => l_errmsg);

            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
       END IF;



/** 3050846 **/

      UPDATE wip_discrete_jobs wdj
         SET (quantity_scrapped,
              last_updated_by,
              last_update_date,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date
             ) =
             (SELECT wdj.quantity_scrapped         -- quantity_scrapped
                     + SUM(DECODE(wmti.to_intraoperation_step_type,
                                  WIP_CONSTANTS.SCRAP, wmti.primary_quantity,0)
                     - DECODE(wmti.fm_intraoperation_step_type,
                              WIP_CONSTANTS.SCRAP,wmti.primary_quantity,0)),
                     MAX(wmti.last_updated_by),
                     SYSDATE,                      -- last_update_date
                     DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
                     DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                     DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                     DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                     DECODE(p_gib.request_id,
                      -1,NULL,SYSDATE)-- program_update_date
                FROM wip_discrete_jobs wdj1, wip_move_txn_interface wmti
               WHERE wdj1.rowid = wdj.rowid
                 AND wmti.group_id = p_gib.group_id
                 AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
                 AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
                 AND wmti.process_status = WIP_CONSTANTS.RUNNING
                 AND wmti.organization_id = wdj1.organization_id
                 AND wmti.wip_entity_id = wdj1.wip_entity_id
                 AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
                      OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)/*WSM */
                 AND (wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
                      OR wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
             )
        WHERE wdj.rowid IN
             (SELECT wdj2.rowid
                FROM wip_discrete_jobs wdj2,
                     wip_move_txn_interface wmti
               WHERE wmti.group_id = p_gib.group_id
                 AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
                 AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
                 AND wmti.process_status = WIP_CONSTANTS.RUNNING
                 AND wmti.organization_id = wdj2.organization_id
                 AND wmti.wip_entity_id = wdj2.wip_entity_id
                 AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
                      OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)/* WSM*/
                 AND (wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
                      OR wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
             );
      /* Now we will also update the column status_type to "Complete" IF
      these scrap completions will finish off the remaining quantity to be
      completed, or update it to "Released" IF moving these assemblies back
      from Scrap will re-release a completed job.  We will also update the
      date_completed IF necessary.  See wiltct.ppc for a similar change.
      rkaiser, 7/15/98  */

      UPDATE wip_discrete_jobs wdj
         SET (status_type,
              date_completed
             ) =
            (SELECT WIP_CONSTANTS.COMP_CHRG,   -- status_type
                    SYSDATE                    -- date_completed
               FROM DUAL)
       WHERE wdj.rowid IN
            (SELECT wdj2.rowid
               FROM wip_discrete_jobs wdj2,
                    wip_move_txn_interface wmti
              WHERE wmti.group_id = p_gib.group_id
                AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
                AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
                AND wmti.process_status = WIP_CONSTANTS.RUNNING
                AND wmti.organization_id = wdj2.organization_id
                AND wmti.wip_entity_id = wdj2.wip_entity_id
                AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
                     OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)/*WSM */
                AND (wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
                     OR wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
                AND (wdj2.start_quantity - wdj2.quantity_completed -
                     wdj2.quantity_scrapped) <= 0);

      UPDATE wip_discrete_jobs wdj
         SET status_type = WIP_CONSTANTS.RELEASED,
/*bug 3933240 -> nullify date_completed while changing the status of job to
  released */
             date_completed = null
       WHERE wdj.rowid IN
             (SELECT wdj2.rowid
                FROM wip_discrete_jobs wdj2,
                     wip_move_txn_interface wmti
               WHERE wmti.group_id = p_gib.group_id
                 AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
                 AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
                 AND wmti.process_status = WIP_CONSTANTS.RUNNING
                 AND wmti.organization_id = wdj2.organization_id
                 AND wmti.wip_entity_id = wdj2.wip_entity_id
                 AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
                      OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)/* WSM*/
                 AND (wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
                      OR wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
                 AND (wdj2.start_quantity - wdj2.quantity_completed -
                      wdj2.quantity_scrapped) > 0);

      -- IF debug message level = 2, write statement below to log file
      IF (l_logLevel <= wip_constants.full_logging) THEN
        fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
        fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
        fnd_message.set_token('ENTITY2', 'WIP_DISCRETE_JOBS');
        l_msg := fnd_message.get;
        wip_logger.log(p_msg          => l_msg,
                       x_returnStatus => l_returnStatus);
      END IF;
    END IF; -- END job transactions

   /*------------------------------------------------------------+
    |  Update scrap quantity for repetitive schedule
    +------------------------------------------------------------*/
    IF(l_move.scheTxn = WIP_CONSTANTS.YES) THEN
      /*------------------------------------------------------------------+
       | For repetitive schedules, we do not set the date_closed, since this
       | is only done manually, via the form.  It is not set automatically for
       | regular completions, so we will not set it here.  rkaiser
       +------------------------------------------------------------------*/
      UPDATE wip_repetitive_schedules wrs
         SET (status_type) =
             (SELECT DECODE(SIGN(
                       (wrs.daily_production_rate * wrs.processing_work_days -
                        wrs.quantity_completed) -
                        SUM(NVL(wo.quantity_scrapped, 0))),
                     1, WIP_CONSTANTS.RELEASED,
                     WIP_CONSTANTS.COMP_CHRG)
                FROM wip_operations wo
               WHERE wo.organization_id = wrs.organization_id
                 AND wo.repetitive_schedule_id = wrs.repetitive_schedule_id)
       WHERE wrs.status_type IN (WIP_CONSTANTS.RELEASED,
                                 WIP_CONSTANTS.COMP_CHRG)
         AND wrs.rowid IN
            (SELECT wrs2.rowid
               FROM wip_repetitive_schedules wrs2,
                    wip_move_txn_interface wmti
              WHERE wmti.group_id = p_gib.group_id
                AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
                AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
                AND wmti.process_status = WIP_CONSTANTS.RUNNING
                AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
                AND wrs2.wip_entity_id = wmti.wip_entity_id
                AND wrs2.organization_id = wmti.organization_id
                AND wrs2.line_id = wmti.line_id
                AND (wmti.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
                    OR wmti.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP));

      -- IF debug message level = 2, write statement below to log file
      IF (l_logLevel <= wip_constants.full_logging) THEN
        fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
        fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
        fnd_message.set_token('ENTITY2', 'WIP_REPETITIVE_SCHEDULES');
        l_msg := fnd_message.get;
        wip_logger.log(p_msg          => l_msg,
                       x_returnStatus => l_returnStatus);
      END IF;
    END IF; -- END repetitive schedule transactions

    /* Generate a mtl txn header id IF one has not already been generated */
    IF(p_gib.mtl_header_id IS NULL OR
       p_gib.mtl_header_id = -1) THEN
      SELECT mtl_material_transactions_s.nextval
        INTO p_gib.mtl_header_id
        FROM DUAL;
    END IF;

    -- initialize transaction mode
    IF(p_gib.move_mode = WIP_CONSTANTS.ONLINE AND
       p_gib.mtl_mode  = WIP_CONSTANTS.ONLINE) THEN
      l_transaction_mode := WIP_CONSTANTS.ONLINE;
    ELSE
      l_transaction_mode := WIP_CONSTANTS.BACKGROUND;
    END IF;

    FOR l_step IN WIP_CONSTANTS.QUEUE..WIP_CONSTANTS.RUN LOOP

      -- Discrete and Lotbased jobs
      IF(l_move.jobTxn = WIP_CONSTANTS.YES) THEN
        INSERT INTO mtl_material_transactions_temp
          (last_updated_by,
           last_update_date,
           last_update_login,
           created_by,
           creation_date,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           transaction_header_id,
           transaction_temp_id,
           source_code,
           source_line_id,
           transaction_mode,
           inventory_item_id,
           revision,
           organization_id,
           transaction_quantity,
           transaction_uom,
           primary_quantity,
           transaction_source_type_id,
           transaction_source_id,
           transaction_action_id,
           transaction_type_id,
           transaction_date,
           acct_period_id,
           distribution_account_id,
           transaction_cost,
           transaction_reference,
           reason_id,
           wip_entity_type,
           schedule_id,
           repetitive_line_id,
           operation_seq_num,
           move_transaction_id,
           process_flag,
           lock_flag,
           posting_flag,
           source_project_id,
           source_task_id,
           transaction_batch_id,
           qa_collection_id,        /*Added for Bug 	7136450 (FP of 7126588 )*/
           transaction_batch_seq
           )
           SELECT wmti.last_updated_by,       -- last_updated_by --Fix for bug 5195072
                  SYSDATE,                    -- last_update_date
                  DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
                  wmti.created_by,        -- created_by --Fix for bug 5195072
                  SYSDATE,                    -- creation_date
                  DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                  DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                  DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                  DECODE(p_gib.request_id,
                   -1,NULL,SYSDATE), -- program_update_date
                  p_gib.mtl_header_id,        -- transaction_header_id
                  mtl_material_transactions_s.nextval,  -- transaction_temp_id
                  wmti.source_code,
                  wmti.source_line_id,
                  l_transaction_mode,         -- transaction_mode
                  wmti.primary_item_id,        -- inventory_item_id
                  -- Fixed bug 2387630
                  DECODE(msi.revision_qty_control_code,
                    WIP_CONSTANTS.REV, NVL(wdj.bom_revision,
                      bom_revisions.get_item_revision_fn
                        ('EXCLUDE_OPEN_HOLD',        -- eco_status
                         'ALL',                      -- examine_type
                          wmti.organization_id,       -- org_id
                          wmti.primary_item_id,       -- item_id
                          wmti.transaction_date       -- rev_date
                        )),
                    NULL),                    -- revision
                  wmti.organization_id,
                  DECODE(l_step,              -- transaction_quantity
                    WIP_CONSTANTS.QUEUE, -1 * wmti.transaction_quantity,
                    wmti.transaction_quantity),
                  wmti.transaction_uom,        -- transaction_uom
                  DECODE(l_step,              -- primary_quantity
                    WIP_CONSTANTS.QUEUE, -1 * wmti.primary_quantity,
                    wmti.primary_quantity),
                  TPS_INV_JOB_OR_SCHED,       -- transaction_source_type_id
                  wmti.wip_entity_id,          -- transaction_source_id
                  WIP_CONSTANTS.SCRASSY_ACTION, -- transaction_action_id
                  WIP_CONSTANTS.SCRASSY_TYPE,   -- transaction_type_id
                  wmti.transaction_date,
                  wmti.acct_period_id,
                  wmti.scrap_account_id,       -- distribution_account_id
                  NULL,                       -- transaction_cost
                  wmti.reference,
                  wmti.reason_id,
                  wmti.entity_type,            -- wip_entity_type
                  NULL,                       -- schedule_id
                  wmti.line_id,                -- repetitive_line_id
                  DECODE(l_step,              -- operation_seq_num
                    WIP_CONSTANTS.QUEUE, wmti.fm_operation_seq_num,
                    wmti.to_operation_seq_num),
                  wmti.transaction_id,         -- move_transaction_id
                  'Y',                        -- process_flag
                  'N',                        -- lock_flag
                  'Y',                        -- posting_flag
                  wdj.project_id,
                  wdj.task_id,
                  p_gib.mtl_header_id,         -- transaction_batch_id
                  wmti.qa_collection_id,        /*Added for Bug 7136450 (FP of 7126588 )*/
                  WIP_CONSTANTS.ASSY_BATCH_SEQ -- transaction_batch_seq
             FROM wip_move_txn_interface wmti,
                  mtl_system_items msi,
                  wip_discrete_jobs wdj
            WHERE wmti.group_id = p_gib.group_id
              AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
              AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
              AND wmti.process_status = WIP_CONSTANTS.RUNNING
              AND wmti.scrap_account_id IS NOT NULL
              AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
                   OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)/*WSM*/
              AND wdj.wip_entity_id = wmti.wip_entity_id
              AND wdj.organization_id = wmti.organization_id
              AND DECODE(l_step,
                    WIP_CONSTANTS.QUEUE, wmti.fm_intraoperation_step_type,
                    wmti.to_intraoperation_step_type) = WIP_CONSTANTS.SCRAP
              AND msi.organization_id = wmti.organization_id
              AND msi.inventory_item_id = wmti.primary_item_id;

        -- IF debug message level = 2, write statement below to log file
        IF (l_logLevel <= wip_constants.full_logging) THEN
          fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
          fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
          fnd_message.set_token('ENTITY2', 'MTL_MATERIAL_TRANSACTIONS_TEMP');
          l_msg := fnd_message.get;
          wip_logger.log(p_msg          => l_msg,
                         x_returnStatus => l_returnStatus);
        END IF;

      END IF; -- discrete jobs

      -- Repetitive schedules
      IF(l_move.scheTxn = WIP_CONSTANTS.YES) THEN

        INSERT INTO mtl_material_transactions_temp
          (material_allocation_temp_id,
           last_updated_by,
           last_update_date,
           last_update_login,
           created_by,
           creation_date,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           transaction_header_id,
           transaction_temp_id,
           source_code,
           source_line_id,
           transaction_mode,
           inventory_item_id,
           revision,
           organization_id,
           transaction_quantity,
           transaction_uom,
           primary_quantity,
           transaction_source_type_id,
           transaction_source_id,
           transaction_action_id,
           transaction_type_id,
           transaction_date,
           acct_period_id,
           distribution_account_id,
           transaction_cost,
           transaction_reference,
           reason_id,
           wip_entity_type,
           schedule_id,
           repetitive_line_id,
           operation_seq_num,
           move_transaction_id,
           process_flag,
           lock_flag,
           posting_flag,
           transaction_batch_id,
           transaction_batch_seq
           )
           SELECT mtl_material_transactions_s.nextval, -- material_alloc_id
                  wmti.last_updated_by,       -- last_updated_by --Fix for bug 5195072
                  SYSDATE,                   -- last_update_date
                  DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
                  wmti.created_by,            -- created_by --Fix for bug 5195072
                  SYSDATE,                   -- creation_date
                  DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                  DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                  DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                  DECODE(p_gib.request_id,
                    -1,NULL,SYSDATE), -- program_update_date
                  p_gib.mtl_header_id,       -- transaction_header_id
                  mtl_material_transactions_s.nextval, -- transaction_temp_id
                  wmti.source_code,
                  wmti.source_line_id,
                  l_transaction_mode,        -- transaction_mode
                  wmti.primary_item_id,       -- inventory_item_id
                  -- Fixed bug 2387630
                  DECODE(msi.revision_qty_control_code, -- revision
                    WIP_CONSTANTS.REV, NVL(wrs.bom_revision,
                      bom_revisions.get_item_revision_fn
                        ('EXCLUDE_OPEN_HOLD',        -- eco_status
                         'ALL',                      -- examine_type
                          wmti.organization_id,       -- org_id
                          wmti.primary_item_id,       -- item_id
                          wmti.transaction_date       -- rev_date
                        )),
                    NULL),
                  wmti.organization_id,
                  DECODE(l_step,             -- transaction_quantity
                    WIP_CONSTANTS.QUEUE, -1 * wmti.transaction_quantity,
                    wmti.transaction_quantity),
                  wmti.transaction_uom,
                  DECODE(l_step,             -- primary_quantity
                    WIP_CONSTANTS.QUEUE, -1 * wmti.primary_quantity,
                    wmti.primary_quantity),
                  TPS_INV_JOB_OR_SCHED,      -- transaction_source_type_id
                  wmti.wip_entity_id,         -- transaction_source_id
                  WIP_CONSTANTS.SCRASSY_ACTION, -- transaction_action_id
                  WIP_CONSTANTS.SCRASSY_TYPE,   -- transaction_type_id
                  wmti.transaction_date,
                  wmti.acct_period_id,
                  wmti.scrap_account_id,      -- distribution_account_id
                  NULL,                      -- transaction_cost
                  wmti.reference,
                  wmti.reason_id,
                  wmti.entity_type,           -- wip_entity_type
                  NULL,                      -- schedule_id
                  wmti.line_id,               -- repetitive_line_id
                  DECODE(l_step,             -- operation_seq_num
                    WIP_CONSTANTS.QUEUE, wmti.fm_operation_seq_num,
                    wmti.to_operation_seq_num),
                  wmti.transaction_id,        -- move_transaction_id
                  'Y',                       -- process_flag
                  'N',                       -- lock_flag
                  'Y',                       -- posting_flag
                  p_gib.mtl_header_id,         -- transaction_batch_id
                  WIP_CONSTANTS.ASSY_BATCH_SEQ -- transaction_batch_seq
             FROM wip_move_txn_interface wmti,
                  mtl_system_items msi,
                  wip_repetitive_schedules wrs
            WHERE wmti.group_id = p_gib.group_id
              AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
              AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
              AND wmti.process_status = WIP_CONSTANTS.RUNNING
              AND wmti.scrap_account_id IS NOT NULL
              AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
              AND wrs.wip_entity_id = wmti.wip_entity_id
              AND wrs.organization_id = wmti.organization_id
              AND wrs.line_id = wmti.line_id
              AND wrs.repetitive_schedule_id = wmti.repetitive_schedule_id
              AND DECODE(l_step,
                    WIP_CONSTANTS.QUEUE, wmti.fm_intraoperation_step_type,
                    wmti.to_intraoperation_step_type) = WIP_CONSTANTS.SCRAP
              AND msi.organization_id = wmti.organization_id
              AND msi.inventory_item_id = wmti.primary_item_id;

         -- IF debug message level = 2, write statement below to log file
         IF (l_logLevel <= wip_constants.full_logging) THEN
           fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
           fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
           fnd_message.set_token('ENTITY2', 'MTL_MATERIAL_TRANSACTIONS_TEMP');
           l_msg := fnd_message.get;
           wip_logger.log(p_msg          => l_msg,
                          x_returnStatus => l_returnStatus);
         END IF;
      END IF; -- Repetitive schedules
    END LOOP; -- FOR l_step

    IF(l_move.jobTxn = WIP_CONSTANTS.YES) THEN
      /* Call snapshot for Discrete jobs and only in Avg costing Org. */
            IF(p_gib.move_mode = WIP_CONSTANTS.ONLINE) THEN
        snapshot_online(p_mtl_header_id => p_gib.mtl_header_id,
                        p_org_id        => l_move.org_id,
                        p_txn_type      => WIP_CONSTANTS.MOVE_TXN,
                        p_txn_type_id   => WIP_CONSTANTS.SCRASSY_TYPE,
                        p_txn_action_id => WIP_CONSTANTS.SCRASSY_ACTION,
                        x_returnStatus  => x_returnStatus);

        IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_movProc_priv.snapshot_online failed';
          raise fnd_api.g_exc_unexpected_error;
        END IF; -- check return status
      END IF; -- move mode check
    END IF; -- IF job txns
  END IF; -- scrap transactions

  -- Update PO quantity for scrap transactions
  IF (po_code_release_grp.Current_Release >=
      po_code_release_grp.PRC_11i_Family_Pack_J) THEN
    FOR l_update_po IN c_update_po LOOP

    /* fix bug 6607192(FP 6348222):  Cancel the attached PO with the job when Scrap Txn
       is happening for all the job qty */
                 SELECT (scheduled_quantity - quantity_scrapped - cumulative_scrap_quantity)
 	                into  l_update_po_qty
 	                FROM  wip_operations
 	                WHERE wip_entity_id = l_update_po.job_id
 	                AND   nvl(repetitive_schedule_id,0) = nvl(l_update_po.rep_id,0)
 	                AND   operation_seq_num = l_update_po.fm_op
 	                AND   organization_id = l_update_po.org_id;

                 SELECT NVL(Min(operation_seq_num),0)
 	                into   l_osp_op_seq_num
 	                FROM   wip_operation_resources
 	                WHERE  wip_entity_id = l_update_po.job_id
 	                AND    organization_id = l_update_po.org_id
 	                AND    autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT, WIP_CONSTANTS.PO_MOVE);

                 IF(l_update_po_qty = 0 AND l_update_po.fm_op < l_osp_op_seq_num) then
                    wip_osp.cancelPOReq(
 	                    p_job_id          => l_update_po.job_id,
 	                    p_org_id          => l_update_po.org_id,
 	                    x_return_status => x_returnStatus);
 	                  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
 	                   l_errMsg := 'wip_osp.cancelPOReq failed';
 	                   raise fnd_api.g_exc_unexpected_error;
 	                 END IF;
 	         ELSE
    /* end of fix 6607192 */

      wip_osp.updatePOReqQuantity(
        p_job_id        => l_update_po.job_id,
        p_repetitive_id => l_update_po.rep_id,
        p_org_id        => l_update_po.org_id,
        p_changed_qty   => l_update_po.changed_qty,
        p_fm_op         => l_update_po.fm_op,
        /* Fix for Bug#4734309 */
        p_is_scrap_txn  => WIP_CONSTANTS.YES,
        x_return_status => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_osp.updatePOReqQuantity failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    END LOOP;
  END IF; -- have PO patchset J onward


  -- assign l_move back to move profile
  p_gib.move_profile := l_move;
  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.scrap_txns',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName =>'wip_movProc_priv.scrap_txns',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.scrap_txns',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END scrap_txns;

/*****************************************************************************
 * This procedure is equivalent to witpscp_completion in wiltps5.ppc
 * This procedure is used to do easy completion and easy return
 * This procedure insert into MTL_MATERIAL_TRANSACTIONS_TEMP and
 * MTL_TRANSACTION_LOTS_TEMP
 ****************************************************************************/
PROCEDURE ez_completion(p_gib       IN OUT NOCOPY group_rec_t,
                        p_txn_type     IN         NUMBER,
                        x_returnStatus OUT NOCOPY VARCHAR2) IS

CURSOR c_repAssembly(p_header_id NUMBER) IS
  SELECT completion_transaction_id cpl_txn_id,
         transaction_action_id txn_action_id,
         transaction_source_id txn_src_id,
         repetitive_line_id rep_line_id,
         organization_id org_id,
         transaction_date txn_date,
         ABS(primary_quantity) primary_qty,
         reason_id reason_id,
         transaction_reference reference
    FROM mtl_material_transactions_temp
   WHERE transaction_header_id = p_header_id
     AND wip_entity_type = WIP_CONSTANTS.REPETITIVE
     AND transaction_action_id IN (WIP_CONSTANTS.RETASSY_ACTION,
                                   WIP_CONSTANTS.CPLASSY_ACTION);

l_repAssembly      c_repAssembly%ROWTYPE;
l_params           wip_logger.param_tbl_t;
l_returnStatus     VARCHAR(1);
l_errMsg           VARCHAR(240);
l_msg              VARCHAR(240);
l_step             NUMBER;
l_transaction_mode NUMBER;
l_txn_action_id    NUMBER;
l_txn_type_id      NUMBER;
l_txn_direction    NUMBER;
l_mti_lot_rec      NUMBER; -- number of record under lot control
l_mti_ser_rec      NUMBER; -- number of record under serial control
l_move             move_profile_rec_t;
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;
l_bf_required      NUMBER; -- throw away value
l_ls_required      NUMBER;
l_addMsgToStack    VARCHAR2(1);
BEGIN
  l_move := p_gib.move_profile;

  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    l_params(3).paramName   := 'org_id';
    l_params(3).paramValue  :=  l_move.org_id;
    l_params(4).paramName   := 'wip_id';
    l_params(4).paramValue  :=  l_move.wip_id;
    l_params(5).paramName   := 'fmOp';
    l_params(5).paramValue  :=  l_move.fmOp;
    l_params(6).paramName   := 'fmStep';
    l_params(6).paramValue  :=  l_move.fmStep;
    l_params(7).paramName   := 'toOp';
    l_params(7).paramValue  :=  l_move.toOp;
    l_params(8).paramName   := 'toStep';
    l_params(8).paramValue  :=  l_move.toStep;
    l_params(9).paramName   := 'scrapTxn';
    l_params(9).paramValue  :=  l_move.scrapTxn;
    l_params(10).paramName  := 'easyComplete';
    l_params(10).paramValue :=  l_move.easyComplete;
    l_params(11).paramName  := 'easyReturn';
    l_params(11).paramValue :=  l_move.easyReturn;
    l_params(12).paramName  := 'jobTxn';
    l_params(12).paramValue :=  l_move.jobTxn;
    l_params(13).paramName  := 'scheTxn';
    l_params(13).paramValue :=  l_move.scheTxn;
    l_params(14).paramName  := 'rsrcItem';
    l_params(14).paramValue :=  l_move.rsrcItem;
    l_params(15).paramName  := 'rsrcLot';
    l_params(15).paramValue :=  l_move.rsrcLot;
    l_params(16).paramName  := 'poReqItem';
    l_params(16).paramValue :=  l_move.poReqItem;
    l_params(17).paramName  := 'poRegLot';
    l_params(17).paramValue :=  l_move.poReqLot;
    l_params(18).paramName  := 'p_mtl_header_id';
    l_params(18).paramValue :=  p_gib.mtl_header_id;
    l_params(19).paramName  := 'p_move_mode';
    l_params(19).paramValue :=  p_gib.move_mode;
    l_params(20).paramName  := 'p_mtl_mode';
    l_params(20).paramValue :=  p_gib.mtl_mode;
    l_params(21).paramName  := 'p_txn_type';
    l_params(21).paramValue :=  p_txn_type;
    l_params(22).paramName  := 'p_assy_header_id';
    l_params(22).paramValue :=  p_gib.assy_header_id;

    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.ez_completion',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  /* Generate a mtl txn header id IF one has not already been generated */
  IF(p_gib.mtl_header_id IS NULL OR
     p_gib.mtl_header_id = -1) THEN
    SELECT mtl_material_transactions_s.nextval
      INTO p_gib.mtl_header_id
      FROM DUAL;
  END IF;

  IF(p_gib.assy_header_id IS NULL OR
     p_gib.assy_header_id = -1) THEN
    -- Generate new header ID for assembly records because we want inventory
    -- to process assembly records, but not component records.
    SELECT mtl_material_transactions_s.nextval
      INTO p_gib.assy_header_id
      FROM DUAL;
  END IF;

  /* set transaction type */
  IF (p_txn_type = WIP_CONSTANTS.RET_TXN) THEN
    l_txn_action_id := WIP_CONSTANTS.RETASSY_ACTION;
    l_txn_type_id   := WIP_CONSTANTS.RETASSY_TYPE;
    l_txn_direction := -1;
  ELSE
    l_txn_action_id := WIP_CONSTANTS.CPLASSY_ACTION;
    l_txn_type_id   := WIP_CONSTANTS.CPLASSY_TYPE;
    l_txn_direction := 1;
  END IF;

  -- initialize transaction mode
  IF(p_gib.move_mode = WIP_CONSTANTS.ONLINE AND
    p_gib.mtl_mode  = WIP_CONSTANTS.ONLINE) THEN
    l_transaction_mode := WIP_CONSTANTS.ONLINE;
  ELSE
    l_transaction_mode := WIP_CONSTANTS.BACKGROUND;
  END IF;

  /*------------------------------------------------------------+
   |  Insert completion transaction record                      |
   +------------------------------------------------------------*/
  IF(l_move.jobTxn = WIP_CONSTANTS.YES) THEN
    INSERT INTO mtl_transactions_interface
       (completion_transaction_id,
transaction_interface_id,
last_updated_by,
        last_update_date,
        last_update_login,
        created_by,
        creation_date,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        transaction_header_id,
        source_code,
--        completion_transaction_id,
        move_transaction_id,
        inventory_item_id,
        subinventory_code,
        locator_id,
        transaction_quantity,
        transaction_uom,
        primary_quantity,
        transaction_date,
        organization_id,
        acct_period_id,
        transaction_action_id,
        transaction_source_id,
        transaction_source_type_id,
        transaction_type_id,
        wip_entity_type,
        repetitive_line_id,
        transaction_reference,
        operation_seq_num,
        reason_id,
        revision,
        kanban_card_id,
        source_project_id,
        source_task_id,
        transaction_mode,
        process_flag,
--        lock_flag,
--        posting_flag,
--        item_lot_control_code,
--        item_serial_control_code,
--        project_id,
--        task_id,
        source_header_id,
        source_line_id,
        transaction_batch_id,
        transaction_batch_seq,
--        transaction_interface_id,
        -- populate this value for EZ completion/return because material
        -- processor need this value to enable quality
        qa_collection_id
        )/*7314913: Inserting into MTI based on order of transaction_date*/
	/*Sequence and order by cannot exist in the same level of select, thus re-writing the select statement as sub-query*/
select NVL(p_gib.move_profile.cmp_txn_id,mtl_material_transactions_s.nextval), mtl_material_transactions_s.nextval, t.*
        from
	(SELECT wmti.last_updated_by last_updated_by,             -- last_update_by --Fix for bug 5195072
               SYSDATE last_update_date,                     -- last_update_date
               DECODE(p_gib.login_id, -1, NULL, p_gib.login_id) login_id,
               wmti.created_by created_by, --Fix for bug 5195072
               SYSDATE creation_date,
               DECODE(p_gib.request_id, -1, NULL, p_gib.request_id) request_id,
               DECODE(p_gib.application_id, -1, NULL, p_gib.application_id) application_id,
               DECODE(p_gib.program_id, -1, NULL, p_gib.program_id) program_id,
               DECODE(p_gib.request_id, -1, NULL, SYSDATE) program_update_date,
               p_gib.assy_header_id transaction_header_id,
               'WIP Completion' source_code,
--               NVL(p_gib.move_profile.cmp_txn_id,-- completion_transaction_id
--                   mtl_material_transactions_s.nextval),
               wmti.transaction_id move_transaction_id,
               wmti.primary_item_id inventory_item_id,
               wdj.completion_subinventory subinventory_code,
               wdj.completion_locator_id locator_id,
               l_txn_direction * wmti.transaction_quantity transaction_qty,
               wmti.transaction_uom transaction_uom,
               l_txn_direction * wmti.primary_quantity primary_quantity,
               wmti.transaction_date transaction_date,
               wmti.organization_id organization_id,
               wmti.acct_period_id acct_period_id,
               l_txn_action_id transaction_action_id,
               wmti.wip_entity_id transaction_source_id,
               TPS_INV_JOB_OR_SCHED transaction_source_type_id,
               l_txn_type_id transaction_type_id,
               wmti.entity_type wip_entity_type,
               wmti.line_id repetitive_line_id,
               wmti.reference transaction_reference,
               wop.operation_seq_num operation_seq_num,
               wmti.reason_id reason_id,
                 -- Fixed bug 2387630
               DECODE(msi.revision_qty_control_code, -- revision
                 WIP_CONSTANTS.REV, NVL(wdj.bom_revision,
                  bom_revisions.get_item_revision_fn
                    ('EXCLUDE_OPEN_HOLD',        -- eco_status
                     'ALL',                      -- examine_type
                      wmti.organization_id,       -- org_id
                      wmti.primary_item_id,       -- item_id
                      wmti.transaction_date       -- rev_date
                     )),
                 NULL) revision_qty_control_code,
               DECODE(l_txn_direction,      -- kanban_card_id
                -1,NULL,wdj.kanban_card_id) kanban_card_id,
               wdj.project_id source_project_id,
               wdj.task_id source_task_id,
               l_transaction_mode transaction_mode,
               WIP_CONSTANTS.MTI_INVENTORY process_flag, -- process_flag for WIP
--               'N',                         -- lock_flag
--               'Y',                         -- posting_flag
--               msi.lot_control_code,        -- item_lot_control_code
--               msi.serial_number_control_code,-- item_serial_control_code
--               mil.project_id,              -- project_id
--               mil.task_id,                 -- task_id
               wmti.wip_entity_id source_header_id,
               wop.operation_seq_num source_line_id,
               p_gib.assy_header_id transaction_batch_id,
               WIP_CONSTANTS.ASSY_BATCH_SEQ transaction_batch_seq,
--               mtl_material_transactions_s.nextval, -- transaction_interface_id
               -- populate this value for EZ completion/return because
               -- material processor need this value to enable quality
               wmti.qa_collection_id qa_collection_id
          FROM wip_move_txn_interface wmti,
               mtl_item_locations mil,
               wip_operations wop,
               mtl_system_items msi,
               wip_discrete_jobs wdj
         WHERE wmti.group_id = p_gib.group_id
           AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
           AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
           AND wmti.process_status = WIP_CONSTANTS.RUNNING
           AND wmti.transaction_type = p_txn_type
           AND (wmti.entity_type = WIP_CONSTANTS.DISCRETE
                OR wmti.entity_type = WIP_CONSTANTS.LOTBASED)/*WSM*/
           AND wdj.wip_entity_id = wmti.wip_entity_id
           AND wdj.organization_id = wmti.organization_id
           AND wop.organization_id = wmti.organization_id
           AND wop.wip_entity_id = wmti.wip_entity_id
           AND NVL(wop.repetitive_schedule_id,-1) =
               NVL(wmti.repetitive_schedule_id,-1)
           AND wop.next_operation_seq_num IS NULL
           AND msi.organization_id = wmti.organization_id
           AND msi.inventory_item_id = wmti.primary_item_id
           AND wdj.completion_locator_id = mil.inventory_location_id (+)
           AND wdj.organization_id = mil.organization_id (+)
	order by wmti.transaction_date, wmti.wip_entity_id) t
;

  END IF; -- discrete jobs

  IF(l_move.scheTxn = WIP_CONSTANTS.YES) THEN

    INSERT INTO mtl_transactions_interface
       (completion_transaction_id,
	transaction_interface_id,
	last_updated_by,
        last_update_date,
        last_update_login,
        created_by,
        creation_date,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        transaction_header_id,
        source_code,
        --completion_transaction_id,
        move_transaction_id,
        inventory_item_id,
        subinventory_code,
        locator_id,
        transaction_quantity,
        transaction_uom,
        primary_quantity,
        transaction_date,
        organization_id,
        acct_period_id,
        transaction_action_id,
        transaction_source_id,
        transaction_source_type_id,
        transaction_type_id,
        wip_entity_type,
        repetitive_line_id,
        transaction_reference,
        operation_seq_num,
        reason_id,
        revision,
        transaction_mode,
        process_flag,
--        lock_flag,
--        posting_flag,
--        item_lot_control_code,
--        item_serial_control_code,
        source_header_id,
        source_line_id,
        transaction_batch_id,
        transaction_batch_seq,
--        transaction_interface_id,
        -- populate this value for EZ completion/return because material
        -- processor need this value to enable quality
        qa_collection_id
        )/*7314913: Inserting into MTI based on order of transaction_date*/
	/*Sequence and order by cannot exist in the same level of select, thus re-writing the select statement as sub-query*/
	select NVL(p_gib.move_profile.cmp_txn_id,mtl_material_transactions_s.nextval), mtl_material_transactions_s.nextval, t.*
        from
	(SELECT wmti.last_updated_by last_update_by, --Fix for bug 5195072
               SYSDATE last_update_date,
               DECODE(p_gib.login_id, -1, NULL, p_gib.login_id) login_id,
               wmti.created_by created_by, --Fix for bug 5195072
               SYSDATE  creation_date,
               DECODE(p_gib.request_id, -1, NULL, p_gib.request_id) request_id,
               DECODE(p_gib.application_id, -1, NULL, p_gib.application_id) application_id,
               DECODE(p_gib.program_id, -1, NULL, p_gib.program_id) program_id,
               DECODE(p_gib.request_id, -1, NULL, SYSDATE) program_update_date,
               p_gib.assy_header_id transaction_header_id,
               'WIP Completion' source_code,
--               NVL(p_gib.move_profile.cmp_txn_id, -- completion_transaction_id
--                   mtl_material_transactions_s.nextval),
               wmti.transaction_id move_transaction_id,
               wmti.primary_item_id inventory_item_id,
               wri.completion_subinventory subinventory_code,
               wri.completion_locator_id locator_id,
               l_txn_direction * wmti.transaction_quantity transaction_qty,
               wmti.transaction_uom transaction_uom,
               l_txn_direction * wmti.primary_quantity primary_quantity,
               wmti.transaction_date transaction_date,
               wmti.organization_id organization_id,
               wmti.acct_period_id acct_period_id,
               l_txn_action_id transaction_action_id,
               wmti.wip_entity_id transaction_source_id,
               TPS_INV_JOB_OR_SCHED  trsnsaction_source_type_id,
               l_txn_type_id transaction_type_id,
               wmti.entity_type entity_type,
               wmti.line_id repetitive_line_id,
               wmti.reference transaction_reference,
               wop.operation_seq_num operation_seq_num,
               wmti.reason_id reason_id,
               -- Fixed bug 2387630
               DECODE(msi.revision_qty_control_code, -- revision
                 WIP_CONSTANTS.REV, NVL(wrs.bom_revision,
                   bom_revisions.get_item_revision_fn
                    ('EXCLUDE_OPEN_HOLD',        -- eco_status
                     'ALL',                      -- examine_type
                      wmti.organization_id,       -- org_id
                      wmti.primary_item_id,       -- item_id
                      wmti.transaction_date       -- rev_date
                     )),
                 NULL) revision_qty_control_code,
               l_transaction_mode transaction_mode,
               WIP_CONSTANTS.MTI_INVENTORY process_flag, -- process_flag for WIP
--               'N',                        -- lock_flag
--               'Y',                        -- posting_flag
--               msi.lot_control_code,       -- item_lot_control_code
--               msi.serial_number_control_code, -- item_serial_control_code
               wmti.wip_entity_id source_header_id,
               wop.operation_seq_num source_line_id,
               p_gib.assy_header_id transaction_batch_id,
               WIP_CONSTANTS.ASSY_BATCH_SEQ transaction_batch_seq,
--               mtl_material_transactions_s.nextval, -- transaction_interface_id
               -- populate this value for EZ completion/return because
               -- material processor need this value to enable quality
               wmti.qa_collection_id qa_collection_id
          FROM wip_move_txn_interface wmti,
               wip_operations wop,
               mtl_system_items msi,
               wip_repetitive_schedules wrs,
               wip_repetitive_items wri
         WHERE wmti.group_id = p_gib.group_id
           AND TRUNC(wmti.transaction_date) = TRUNC(p_gib.txn_date)
           AND wmti.process_phase = WIP_CONSTANTS.MOVE_PROC
           AND wmti.process_status = WIP_CONSTANTS.RUNNING
           AND wmti.transaction_type = p_txn_type
           AND wmti.entity_type = WIP_CONSTANTS.REPETITIVE
           AND wrs.wip_entity_id = wmti.wip_entity_id
           AND wrs.organization_id = wmti.organization_id
           AND wrs.line_id = wmti.line_id
           AND wrs.repetitive_schedule_id = wmti.repetitive_schedule_id
           AND wri.organization_id = wmti.organization_id
           AND wri.wip_entity_id = wmti.wip_entity_id
           AND wri.line_id = wmti.line_id
           AND wop.organization_id = wmti.organization_id
           AND wop.wip_entity_id = wmti.wip_entity_id
           AND NVL(wop.repetitive_schedule_id,-1) =
               NVL(wmti.repetitive_schedule_id,-1)
           AND wop.next_operation_seq_num IS NULL
           AND msi.organization_id = wmti.organization_id
           AND msi.inventory_item_id = wmti.primary_item_id
	order by wmti.transaction_date, wmti.wip_entity_id) t;
  END IF; -- Repetitive schedules

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'MTL_TRANSACTIONS_INTERFACE');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  /* Only allow lot control for discrete/OSFM jobs */
  IF(l_move.jobTxn = WIP_CONSTANTS.YES) THEN

    SELECT COUNT(*)
      INTO l_mti_lot_rec
      FROM mtl_transactions_interface mti,
           mtl_system_items msi
     WHERE mti.organization_id = msi.organization_id
       AND mti.inventory_item_id = msi.inventory_item_id
       AND mti.transaction_header_id = p_gib.assy_header_id
       AND mti.transaction_action_id = l_txn_action_id
       AND mti.transaction_type_id   = l_txn_type_id
       AND mti.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
       AND mti.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                   WIP_CONSTANTS.LOTBASED) /*WSM*/
       AND msi.lot_control_code = WIP_CONSTANTS.LOT;

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      l_msg := 'No. of records in mti updated for lot controlled ' ||
               'assemblies : ' || l_mti_lot_rec;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;

    /* IF records under lot control THEN continue */
    IF(l_mti_lot_rec > 0) THEN
      /* Insert lot records into lot interface table */
      /*----------------------------------------------------------------------
       |The NOT EXISTS statement in the where clause is added for fixing
       | bug 1813824. Duplicate records could be inserted in the following
       | senario. The first around, the first record get inserted into mtt
       | and THEN temp id is update for that record, so one record get
       | inserted into mtlt. The second round, the second record get inserted
       | into mtt and temp id is THEN updated accordingly. But when doing the
       | insertion, since the where clause is not selective enough, the record
       | that is inserted into mtlt for the first record is inserted again.
       | Since there is no other way to indicate that the corresponding record
       | in mtlt is already inserted for record in mtt and the fact that
       | we only insert one row into mtlt here for one row in mtt, we could
       | add a NOT EXISTS statment to prevent duplicate record being inserted
       +---------------------------------------------------------------------*/
      INSERT INTO mtl_transaction_lots_interface
        (transaction_interface_id,
         lot_number,
         primary_quantity,
         transaction_quantity,
         lot_expiration_date,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         serial_transaction_temp_id
         )
         SELECT mti.transaction_interface_id,
                wdj.lot_number,
                mti.primary_quantity,
                mti.transaction_quantity,
                NULL,                     -- lot_expiration_date
                mti.creation_date,
                mti.created_by,
                mti.last_update_date,
                mti.last_updated_by,
                mti.last_update_login,
                DECODE(msi.serial_number_control_code,
                  WIP_CONSTANTS.FULL_SN, mtl_material_transactions_s.nextval,
                  WIP_CONSTANTS.DYN_RCV_SN,mtl_material_transactions_s.nextval,
                  NULL)
           FROM mtl_transactions_interface mti,
                mtl_system_items msi,
                wip_discrete_jobs wdj
          WHERE mti.organization_id = msi.organization_id
            AND mti.inventory_item_id = msi.inventory_item_id
            AND mti.transaction_header_id = p_gib.assy_header_id
            AND mti.transaction_action_id = l_txn_action_id
            AND mti.transaction_type_id   = l_txn_type_id
            AND mti.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
            AND mti.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                        WIP_CONSTANTS.LOTBASED)/*WSM */
            AND msi.lot_control_code = WIP_CONSTANTS.LOT
            AND mti.organization_id = wdj.organization_id
            AND mti.transaction_source_id = wdj.wip_entity_id
            AND NOT EXISTS
               (SELECT 1
                  FROM mtl_transaction_lots_interface mtli
                 WHERE mtli.transaction_interface_id =
                       mti.transaction_interface_id);

      -- IF debug message level = 2, write statement below to log file
      IF (l_logLevel <= wip_constants.full_logging) THEN
        fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
        fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
        fnd_message.set_token('ENTITY2', 'MTL_TRANSACTION_LOTS_INTERFACE');
        l_msg := fnd_message.get;
        wip_logger.log(p_msg          => l_msg,
                       x_returnStatus => l_returnStatus);
      END IF;

      /* Update lot records with an expiration date */
      /* Use expiration date in MTL_LOT_NUMBERS. */
      /* IF no expiration date THEN calculate based on SHELF_LIFE_DAYS */

      UPDATE mtl_transaction_lots_interface mtli
         SET lot_expiration_date =
             (SELECT MIN(mln.expiration_date)
                FROM mtl_transactions_interface mti,
                     mtl_system_items msi,
                     mtl_lot_numbers  mln
               WHERE mti.organization_id = msi.organization_id
                 AND mti.inventory_item_id = msi.inventory_item_id
                 AND mti.transaction_header_id = p_gib.assy_header_id
                 AND mti.transaction_action_id = l_txn_action_id
                 AND mti.transaction_type_id   = l_txn_type_id
                 AND mti.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
                 AND mti.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                             WIP_CONSTANTS.LOTBASED)/*WSM */
                 AND msi.lot_control_code = WIP_CONSTANTS.LOT
                 AND mln.lot_number = mtli.lot_number
                 AND mln.inventory_item_id = mti.inventory_item_id
                 AND mln.organization_id = mti.organization_id)
       WHERE mtli.transaction_interface_id IN
             (SELECT mti.transaction_interface_id
                FROM mtl_transactions_interface mti,
                     mtl_system_items msi
               WHERE mti.organization_id = msi.organization_id
                 AND mti.inventory_item_id = msi.inventory_item_id
                 AND mti.transaction_header_id = p_gib.assy_header_id
                 AND mti.transaction_action_id = l_txn_action_id
                 AND mti.transaction_type_id   = l_txn_type_id
                 AND mti.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
                 /* AND mti.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                             WIP_CONSTANTS.LOTBASED) WSM */
                 AND msi.lot_control_code = WIP_CONSTANTS.LOT
                 -- Bug 8847539. Update lot_expiration_date for osfm jobs if on hand of existing lot is not zero.
                 -- For Lots with zero onhand it will be recalculated based on shelf life in next sql.
                 AND ( mti.wip_entity_type = WIP_CONSTANTS.DISCRETE or
                       (mti.wip_entity_type = WIP_CONSTANTS.LOTBASED and
                        0 <> (select nvl(sum(primary_transaction_quantity),0)
                              FROM mtl_onhand_quantities_detail moqd
                              WHERE moqd.inventory_item_id = mti.inventory_item_id
                              AND moqd.organization_id = mti.organization_id
                              AND moqd.lot_number = mtli.lot_number
                             )
                       )
                     ));

      -- IF debug message level = 2, write statement below to log file
      IF (l_logLevel <= wip_constants.full_logging) THEN
        fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
        fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
        fnd_message.set_token('ENTITY2', 'MTL_TRANSACTION_LOTS_INTERFACE');
        l_msg := fnd_message.get;
        wip_logger.log(p_msg          => l_msg,
                       x_returnStatus => l_returnStatus);
      END IF;

      /* IF Exp date null in MTL_LOT_NUMBERS should I leave it null */
      /* Or should I just decode based on exp date null in the temp table? */
      /* Removed group by and modIFied select and where conditions to avoid
         oracle error 1427.  See bugs 866408 and 938422. */
      UPDATE mtl_transaction_lots_interface mtli
         SET lot_expiration_date =
             (SELECT mti.transaction_date + NVL(msi.shelf_life_days,0)
                FROM mtl_transactions_interface mti,
                     mtl_system_items msi
               WHERE mti.transaction_header_id = p_gib.assy_header_id
                 AND mti.transaction_action_id = l_txn_action_id
                 AND mti.transaction_type_id   = l_txn_type_id
                 AND mti.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
                 AND mti.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                             WIP_CONSTANTS.LOTBASED) /*WSM */
                 AND msi.lot_control_code = WIP_CONSTANTS.LOT
                 AND msi.organization_id = mti.organization_id
                 AND msi.inventory_item_id = mti.inventory_item_id
                 AND msi.shelf_life_code = WIP_CONSTANTS.SHELF_LIFE
                 AND mtli.transaction_interface_id =
                     mti.transaction_interface_id)
       WHERE mtli.lot_expiration_date IS NULL
         AND mtli.transaction_interface_id IN
             (SELECT mti.transaction_interface_id
                FROM mtl_transactions_interface mti,
                     mtl_system_items msi
               WHERE mti.organization_id = msi.organization_id
                 AND mti.inventory_item_id = msi.inventory_item_id
                 AND mti.transaction_header_id = p_gib.assy_header_id
                 AND mti.transaction_action_id = l_txn_action_id
                 AND mti.transaction_type_id   = l_txn_type_id
                 AND mti.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
                 AND mti.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                             WIP_CONSTANTS.LOTBASED)/* WSM */
                 AND msi.lot_control_code = WIP_CONSTANTS.LOT);

      -- IF debug message level = 2, write statement below to log file
      IF (l_logLevel <= wip_constants.full_logging) THEN
        fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
        fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
        fnd_message.set_token('ENTITY2', 'MTL_TRANSACTION_LOTS_INTERFACE');
        l_msg := fnd_message.get;
        wip_logger.log(p_msg          => l_msg,
                       x_returnStatus => l_returnStatus);
      END IF;

    END IF; -- (l_mti_lot_rec > 0)
  END IF; -- Discrete and Lotbased jobs

  SELECT COUNT(*)
    INTO l_mti_ser_rec
    FROM mtl_transactions_interface mti,
         mtl_system_items msi
   WHERE mti.organization_id = msi.organization_id
     AND mti.inventory_item_id = msi.inventory_item_id
     AND mti.transaction_header_id = p_gib.assy_header_id
     AND mti.transaction_action_id = l_txn_action_id
     AND mti.transaction_type_id   = l_txn_type_id
     AND mti.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
     AND mti.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                 WIP_CONSTANTS.LOTBASED) /*WSM*/
     AND msi.serial_number_control_code IN (WIP_CONSTANTS.FULL_SN,
                                            WIP_CONSTANTS.DYN_RCV_SN);

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    l_msg := 'No. of records in mti updated for serial controlled ' ||
             'assemblies : ' || l_mti_ser_rec;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;

  /* IF records under serial control THEN continue */
  IF(l_mti_ser_rec > 0) THEN
    /* Insert serial records into serial interface table */

    INSERT INTO mtl_serial_numbers_interface
        (transaction_interface_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         fm_serial_number,
         to_serial_number
         )
         SELECT DECODE(msi.lot_control_code,
                  WIP_CONSTANTS.LOT, mtli.serial_transaction_temp_id,
                  mti.transaction_interface_id),
                mti.creation_date,
                mti.created_by,
                mti.last_update_date,
                mti.last_updated_by,
                mti.last_update_login,
                wsmi.assembly_serial_number,
                wsmi.assembly_serial_number
           FROM mtl_transactions_interface mti,
                mtl_system_items msi,
                mtl_transaction_lots_interface mtli,
                wip_serial_move_interface wsmi
          WHERE mti.organization_id = msi.organization_id
            AND mti.inventory_item_id = msi.inventory_item_id
            AND mti.transaction_header_id = p_gib.assy_header_id
            AND mti.transaction_action_id = l_txn_action_id
            AND mti.transaction_type_id   = l_txn_type_id
            AND mti.transaction_source_type_id = TPS_INV_JOB_OR_SCHED
            AND mti.wip_entity_type IN (WIP_CONSTANTS.DISCRETE,
                                        WIP_CONSTANTS.LOTBASED)/*WSM */
            AND msi.serial_number_control_code IN (WIP_CONSTANTS.FULL_SN,
                                                   WIP_CONSTANTS.DYN_RCV_SN)
            AND mti.transaction_interface_id = mtli.transaction_interface_id(+)
            AND mti.move_transaction_id = wsmi.transaction_id;

    -- IF debug message level = 2, write statement below to log file
    IF (l_logLevel <= wip_constants.full_logging) THEN
      fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
      fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
      fnd_message.set_token('ENTITY2', 'MTL_SERIAL_NUMBERS_INTERFACE');
      l_msg := fnd_message.get;
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_returnStatus);
    END IF;
  END IF; -- Discrete or OSFM jobs

  IF(p_gib.move_mode = WIP_CONSTANTS.ONLINE) THEN
    l_addMsgToStack := fnd_api.g_true;
  ELSE
    -- Message stack is only useful for online transaction. For background,
    -- we never used message stack.
    l_addMsgToStack := fnd_api.g_false;
  END IF;
  -- Move all assembly records from mti to mmtt
  wip_mtlTempProc_priv.validateInterfaceTxns(
    p_txnHdrID      => p_gib.assy_header_id,
    p_addMsgToStack => l_addMsgToStack,
    p_rollbackOnErr => fnd_api.g_false,
    x_returnStatus  => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        --FP bug 5752485 (base bug 4128207) Added the IF condition below since write_mtl_errors
        --is not applicable for ONLINE completions. Otherwise the fnd_msg_pub stack is initialized
        --inside write_mtl_errors which suppresses messages to be shown to the user in the UI
        IF (l_transaction_mode <> WIP_CONSTANTS.ONLINE) THEN
                -- write mtl error message into WIP_TXN_INTERFACE_ERRORS
                write_mtl_errors(p_mtl_header_id => p_gib.assy_header_id);
        END IF;
        l_errMsg := 'wip_mtlTempProc_priv.validateInterfaceTxns failed' ||
                ' (assembly records)' ;
        raise fnd_api.g_exc_unexpected_error;
  END IF;

  FOR l_repAssembly IN c_repAssembly(p_header_id => p_gib.assy_header_id) LOOP
    -- Preallocate if repetitive schedule. This API will allocate primary
    -- quantity to appropriate schedules.
    wip_cplProc_priv.preAllocateSchedules(
      p_txnHdrID     => p_gib.assy_header_id,
      p_cplTxnID     => l_repAssembly.cpl_txn_id,
      p_txnActionID  => l_repAssembly.txn_action_id,
      p_wipEntityID  => l_repAssembly.txn_src_id,
      p_repLineID    => l_repAssembly.rep_line_id,
      p_tblName      => WIP_CONSTANTS.MMTT_TBL,
      p_endDebug     => fnd_api.g_false,
      x_returnStatus => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_cplProc_priv.preAllocateSchedules failed' ;
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END LOOP;

  IF(p_gib.move_mode = WIP_CONSTANTS.ONLINE) THEN
    snapshot_online(p_mtl_header_id => p_gib.assy_header_id,
                    p_org_id        => l_move.org_id,
                    p_txn_type      => p_txn_type,
                    p_txn_type_id   => l_txn_type_id,
                    p_txn_action_id => l_txn_action_id,
                    x_returnStatus  => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_movProc_priv.snapshot_online failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF; -- check return status
  ELSE -- move is background
    IF(p_txn_type = WIP_CONSTANTS.RET_TXN) THEN
      snapshot_background(p_group_id      => p_gib.group_id,
                          p_txn_date      => p_gib.txn_date,
                          x_returnStatus  => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_movProc_priv.snapshot_background failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status
    END IF; -- return transaction
  END IF; -- move mode check

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.ez_completion',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName =>'wip_movProc_priv.ez_completion',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.ez_completion',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END ez_completion;

/*****************************************************************************
 * This procedure is equivalent to witoc_update_wro in wiltps5.ppc
 * This update statement in this procedure is equivalent to the one in
 * WIP_OVERCOMPLETION.update_wip_req_operations. This procedure is used to
 * update WIP_REQUIREMENT_OPERATIONS table
 ****************************************************************************/
PROCEDURE update_wro(p_gib           IN        group_rec_t,
                     x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params           wip_logger.param_tbl_t;
l_returnStatus     VARCHAR(1);
l_errMsg           VARCHAR2(240);
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_txn_date';
    l_params(2).paramValue  :=  p_gib.txn_date;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.update_wro',
                        p_params => l_params,
                        x_returnStatus => l_returnStatus);
  END IF;

  UPDATE wip_requirement_operations wro
     SET (wro.required_quantity,
          last_updated_by,
          last_update_date,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date) =
         (SELECT MIN(required_quantity) + (NVL(SUM(
                   NVL(wma1.primary_quantity, wmti1.primary_quantity)),0)
          --Bug 5476966:Division by yield is added.
                   * MIN(quantity_per_assembly)/min(nvl(component_yield_factor,
                                               1))),
                 p_gib.user_id,
                 SYSDATE,
                 DECODE(p_gib.login_id,-1,NULL,p_gib.login_id),
                 DECODE(p_gib.request_id,-1,NULL,p_gib.request_id),
                 DECODE(p_gib.application_id,-1,NULL,p_gib.application_id),
                 DECODE(p_gib.program_id,-1,NULL,p_gib.program_id),
                 DECODE(p_gib.request_id,-1,NULL,SYSDATE)
            FROM wip_requirement_operations wro1,
                 wip_move_txn_interface wmti1,
                 wip_move_txn_allocations wma1
           WHERE wro1.rowid = wro.rowid
           -- The WO rows to be updated are identIFied by the rowids.
           -- For each such row, go back and sum the quantities from WMTI
             AND wmti1.group_id = p_gib.group_id
             AND wmti1.process_phase = WIP_CONSTANTS.MOVE_PROC
             AND wmti1.process_status = WIP_CONSTANTS.RUNNING
             AND TRUNC(wmti1.transaction_date) = TRUNC(p_gib.txn_date)
             AND wmti1.overcompletion_transaction_id IS NOT NULL
             AND wmti1.overcompletion_primary_qty IS NULL
             AND wro1.wip_entity_id = wmti1.wip_entity_id
             AND wro1.organization_id = wmti1.organization_id
             AND wmti1.organization_id = wma1.organization_id (+)
             AND wmti1.transaction_id = wma1.transaction_id (+)
             AND NVL(wma1.repetitive_schedule_id,0)
                 = NVL(wro1.repetitive_schedule_id,0)
               )
         WHERE wro.rowid in
               (SELECT wro2.rowid
                  FROM wip_requirement_operations wro2,
                       wip_move_txn_interface wmti2,
                       wip_move_txn_allocations wma2
                 WHERE wmti2.group_id = p_gib.group_id
                   AND wmti2.process_phase = WIP_CONSTANTS.MOVE_PROC
                   AND wmti2.process_status = WIP_CONSTANTS.RUNNING
                   AND TRUNC(wmti2.transaction_date) = TRUNC(p_gib.txn_date)
                   AND wmti2.overcompletion_transaction_id IS NOT NULL
                   AND wmti2.overcompletion_primary_qty IS NULL
                   -- Picked a Move txn
                   AND wro2.wip_entity_id = wmti2.wip_entity_id
                   AND wro2.organization_id = wmti2.organization_id
                   AND wmti2.organization_id = wma2.organization_id (+)
                   AND wmti2.transaction_id = wma2.transaction_id (+)
                   AND NVL(wma2.repetitive_schedule_id,0)
                       = NVL(wro2.repetitive_schedule_id,0))
                   AND nvl(wro.basis_type,1) <> WIP_CONSTANTS.LOT_BASED_MTL; /* LBM Project */

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.update_wro',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.update_wro',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END update_wro;

/*****************************************************************************
 * This procedure is equivalent to wiltps in wiltps5.ppc
 * This is the main api to do move transactions
 ****************************************************************************/

PROCEDURE move_txns(p_gib       IN OUT NOCOPY group_rec_t,
                    x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params           wip_logger.param_tbl_t;
l_returnStatus     VARCHAR(1);
l_errMsg           VARCHAR(240);
l_move             move_profile_rec_t;
l_po               BOOLEAN;
l_poStatus         VARCHAR(1);
l_poIndustry       VARCHAR(1);
l_poSchema         VARCHAR(10);
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  l_move := p_gib.move_profile;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_gib.group_id;
    l_params(2).paramName   := 'p_mtl_header_id';
    l_params(2).paramValue  :=  p_gib.mtl_header_id;
    l_params(3).paramName   := 'p_move_mode';
    l_params(3).paramValue  :=  p_gib.move_mode;
    l_params(4).paramName   := 'p_bf_mode';
    l_params(4).paramValue  :=  p_gib.bf_mode;
    l_params(5).paramName   := 'p_mtl_mode';
    l_params(5).paramValue  :=  p_gib.mtl_mode;
    l_params(6).paramName   := 'p_txn_date';
    l_params(6).paramValue  :=  p_gib.txn_date;
    l_params(7).paramName   := 'p_process_phase';
    l_params(7).paramValue  :=  p_gib.process_phase;
    l_params(8).paramName   := 'p_process_status';
    l_params(8).paramValue  :=  p_gib.process_status;
    l_params(9).paramName   := 'p_time_out';
    l_params(9).paramValue  :=  p_gib.time_out;
    l_params(10).paramName  := 'p_intf_tbl_name';
    l_params(10).paramValue :=  p_gib.intf_tbl_name;
    l_params(11).paramName  := 'p_user_id';
    l_params(11).paramValue :=  p_gib.user_id;
    l_params(12).paramName  := 'p_login_id';
    l_params(12).paramValue :=  p_gib.login_id;
    l_params(13).paramName  := 'p_request_id';
    l_params(13).paramValue :=  p_gib.request_id;
    l_params(14).paramName  := 'p_application_id';
    l_params(14).paramValue :=  p_gib.application_id;
    l_params(15).paramName  := 'p_program_id';
    l_params(15).paramValue :=  p_gib.program_id;
    l_params(16).paramName  := 'p_org_id';
    l_params(16).paramValue :=  l_move.org_id;
    l_params(17).paramName  := 'p_wip_id';
    l_params(17).paramValue :=  l_move.wip_id;
    l_params(18).paramName  := 'p_entity_type';
    l_params(18).paramValue :=  l_move.entity_type;
    l_params(19).paramName  := 'p_fmOp';
    l_params(19).paramValue :=  l_move.fmOp;
    l_params(20).paramName  := 'p_fmStep';
    l_params(20).paramValue :=  l_move.fmStep;
    l_params(21).paramName  := 'p_toOp';
    l_params(21).paramValue :=  l_move.toOp;
    l_params(22).paramName  := 'p_toStep';
    l_params(22).paramValue :=  l_move.toStep;
    l_params(23).paramName  := 'p_scrapTxn';
    l_params(23).paramValue :=  l_move.scrapTxn;
    l_params(24).paramName  := 'p_easyComplete';
    l_params(24).paramValue :=  l_move.easyComplete;
    l_params(25).paramName  := 'p_easyReturn';
    l_params(25).paramValue :=  l_move.easyReturn;
    l_params(26).paramName  := 'p_jobTxn';
    l_params(26).paramValue :=  l_move.jobTxn;
    l_params(27).paramName  := 'p_scheTxn';
    l_params(27).paramValue :=  l_move.scheTxn;
    l_params(28).paramName  := 'p_rsrcItem';
    l_params(28).paramValue :=  l_move.rsrcItem;
    l_params(29).paramName  := 'p_rsrcLot';
    l_params(29).paramValue :=  l_move.rsrcLot;
    l_params(30).paramName  := 'p_poReqItem';
    l_params(30).paramValue :=  l_move.poReqItem;
    l_params(31).paramName  := 'p_poReqLot';
    l_params(31).paramValue :=  l_move.poReqLot;
    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.move_txns',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  -- Lock record in WIP_OPERATIONS table
  lock_wipops(p_gib          => p_gib,
              x_returnStatus => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
     l_errMsg := 'wip_movProc_priv.lock_wipops failed';
     raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  -- Call repetitive allocatioin for repetitive schedule
  IF(l_move.scheTxn = WIP_CONSTANTS.YES) THEN
    rep_move_alloc(p_gib          => p_gib,
                   x_returnStatus => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_movProc_priv.rep_move_alloc failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF; -- check return status
  END IF; -- check repetitive schedules

  -- Check for the step unit quantities for discrete and OSFM jobs
  IF(l_move.jobTxn = WIP_CONSTANTS.YES) THEN
    check_qty_dj(p_gib          => p_gib,
                 x_returnStatus => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_movProc_priv.check_qty_dj failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF; -- check return status
  END IF; -- check discrete and OSFM jobs

  -- Lock record in WIP_OPERATIONS table
  -- Update the WRO quantities for the Overcompletion
  update_wro(p_gib          => p_gib,
             x_returnStatus => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_errMsg := 'wip_movProc_priv.update_wro failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  -- Record move transactions history in WIP_MOVE_TRANSACTIONS
  insert_txn_history(p_gib          => p_gib,
                     x_returnStatus => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_errMsg := 'wip_movProc_priv.insert_txn_history failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  -- Delete child record (overmove/overcompletion/overreturn)
  delete_child_txn(p_gib          => p_gib,
                   x_returnStatus => x_returnStatus);

  -- Delete child record (overmove/overcompletion/overreturn)
  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_errMsg := 'wip_movProc_priv.delete_child_txn failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  -- Delete child record (overmove/overcompletion/overreturn)
  -- Insert auto-resources associated with move
  -- (insert into WIP_COST_TXN_INTERFACE)
  insert_auto_resource(p_gib          => p_gib,
                       x_returnStatus => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_errMsg := 'wip_movProc_priv.insert_auto_resource failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  -- Only call the cost allocation IF schedule transactions and auto resource
  -- per item exist (insert into WIP_TXN_ALLOCATIONS)
  IF(l_move.scheTxn = WIP_CONSTANTS.YES AND
     l_move.rsrcItem = WIP_CONSTANTS.YES) THEN

    insert_txn_alloc(p_gib          => p_gib,
                     x_returnStatus => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_movProc_priv.insert_txn_alloc failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF; -- check return status
  END IF; -- repetitive schedule and resource per item exist

  -- Insert department overhead into WIP_COST_TXN_INTERFACE
  insert_dept_overhead(p_gib          => p_gib,
                       x_returnStatus => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_errMsg := 'wip_movProc_priv.insert_dept_overhead failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  -- Release costing transactions
  release_cost_txn(p_gib          => p_gib,
                   x_returnStatus => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_errMsg := 'wip_movProc_priv.release_cost_txn failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  -- IF PO installed and PO, insert PO info into PO_REQUISITIONS_INTERFACE_ALL
  l_po := fnd_installation.get_app_info
                          (application_short_name => 'PO',
                           status                 => l_poStatus,
                           industry               => l_poIndustry,
                           oracle_schema          => l_poSchema);

  IF(l_po = FALSE) THEN -- there is an error calling fnd_installion package
    l_errMsg := 'fnd_installation.get_app_info failed';
    raise fnd_api.g_exc_unexpected_error;
  ELSE  -- no error
    IF(l_poStatus = 'I') THEN -- IF PO installed, insert PO info
      insert_po_req(p_gib          => p_gib,
                    x_returnStatus => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_movProc_priv.insert_po_req failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status
    END IF;
  END IF;

  IF(p_gib.move_mode = WIP_CONSTANTS.ONLINE) THEN
    -- Only update quantity_completed if online. For background, we will update
    -- quantity completed in update_wo_and_snapshot
    update_complete_qty(p_gib          => p_gib,
                        x_returnStatus => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_movProc_priv.update_complete_qty failed';
      raise fnd_api.g_exc_unexpected_error;
    END IF; -- check return status
  END IF;

  -- Update scrap quantity in WIP_DISCRETE_JOBS and insert into MMTT IF
  -- scrap account provided
  scrap_txns(p_gib          => p_gib,
             x_returnStatus => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_errMsg := 'wip_movProc_priv.scrap_txns failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  -- Start workflow for OSP stuff
  start_workflow(p_gib          => p_gib,
                 x_returnStatus => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_errMsg := 'wip_movProc_priv.start_workflow failed';
    raise fnd_api.g_exc_unexpected_error;
  END IF; -- check return status

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.move_txns',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName =>'wip_movProc_priv.move_txns',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.move_txns',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    fnd_msg_pub.add;
END move_txns;

/*****************************************************************************
 * This procedure is equivalent to SF_MOVE in wiutps.ppc + EASY_COMPLETE in
 * wiutez.ppc for ON-LINE transactions. It is also equivalent to wiltws in
 * wiltws.ppc for BACKGROUND transactions.
 *
 * This is the main api to do move, scrap, easy complete, and easy return.
 ****************************************************************************/

PROCEDURE processIntf(p_group_id             IN        NUMBER,
                      p_proc_phase           IN        NUMBER,
                      p_time_out             IN        NUMBER,
                      p_move_mode            IN        NUMBER,
                      p_bf_mode              IN        NUMBER,
                      p_mtl_mode             IN        NUMBER,
                      p_ENDDebug             IN        VARCHAR2,
                      p_initMsgList          IN        VARCHAR2,
                      p_insertAssy           IN        VARCHAR2,
                      p_do_backflush         IN        VARCHAR2,
                      p_child_txn_id         IN        NUMBER := NULL,
                      p_assy_header_id       IN        NUMBER := NULL,
                      p_mtl_header_id        IN        NUMBER := NULL,
                      p_cmp_txn_id           IN        NUMBER := NULL,
                      p_seq_move             IN        NUMBER := NULL,
                      -- Fixed bug 4361566.
                      p_allow_partial_commit IN  NUMBER := NULL,
                      x_returnStatus         OUT NOCOPY VARCHAR2) IS

CURSOR c_backflush(p_txn_date DATE) IS
   SELECT  wmti.wip_entity_id wip_id,
           wmti.organization_id org_id,
           wmti.transaction_date txn_date,
           wmti.primary_quantity primary_qty,
           wmti.transaction_type txn_type,
           wmti.entity_type ent_type,
           wmti.line_id line_id,
           wmti.fm_operation_seq_num fm_op,
           wmti.to_operation_seq_num to_op,
           wmti.fm_intraoperation_step_type fm_step,
           wmti.to_intraoperation_step_type to_step,
           wmti.transaction_id txn_id,
           wmti.reason_id reason_id,
           wmti.reference reference
      FROM wip_move_txn_interface wmti
     WHERE wmti.group_id = p_group_id
       AND TRUNC(wmti.transaction_date)= TRUNC(p_txn_date)
       AND wmti.process_phase = WIP_CONSTANTS.BF_SETUP
       AND wmti.process_status = WIP_CONSTANTS.RUNNING;

CURSOR c_move_online IS
  SELECT NVL(last_updated_by, -1) user_id,
         NVL(last_update_login, -1) login_id,
         NVL(request_id, -1) req_id,
         NVL(program_application_id, -1) appl_id,
         NVL(program_id, -1) prog_id,
         transaction_type txn_type,
         organization_id org_id,
         wip_entity_id wip_id,
         entity_type,
         transaction_date txn_date,
         process_status proc_status,
         fm_operation_seq_num fm_op,
         fm_intraoperation_step_type fm_step,
         to_operation_seq_num to_op,
         to_intraoperation_step_type to_step
    FROM wip_move_txn_interface
   WHERE group_id = p_group_id
/* Comment out the check below because UI may need to use validation logic */
--     AND process_phase = WIP_CONSTANTS.MOVE_PROC
     AND process_status = WIP_CONSTANTS.RUNNING;

CURSOR c_qa_id(p_txn_date DATE) IS
 SELECT qa_collection_id
   FROM wip_move_txn_interface
  WHERE group_id = p_group_id
    AND process_phase = WIP_CONSTANTS.MOVE_PROC
    AND process_status = WIP_CONSTANTS.RUNNING
    AND TRUNC(transaction_date)= TRUNC(p_txn_date)
 -- Only enable QA for move, scrap and reject. For EZ completion/return,
 -- material processor will call it.
    AND transaction_type = WIP_CONSTANTS.MOVE_TXN
    AND qa_collection_id IS NOT NULL;

CURSOR c_txn_date IS
  SELECT DISTINCT TRUNC(transaction_date)
    FROM wip_move_txn_interface
   WHERE group_id = p_group_id
     AND process_status = WIP_CONSTANTS.RUNNING
   order by 1; /*Bug 7314913: Added order by clause*/

l_gib              group_rec_t;
l_move_online      c_move_online%ROWTYPE;
l_backflush        c_backflush%ROWTYPE;
l_params           wip_logger.param_tbl_t;
l_returnStatus     VARCHAR(1);
l_errMsg           VARCHAR(2000);
l_msg              VARCHAR(240);
l_bf_mode          NUMBER;
l_mtl_mode         NUMBER;
l_job              NUMBER;
l_sche             NUMBER;
l_qa_collection_id NUMBER;
l_err_record       NUMBER := 0;
l_txn_tmp_id       NUMBER;
l_msgCount         NUMBER;
l_MMTT_record      NUMBER;
l_returnCode       NUMBER;
l_first_bf_op      NUMBER := -1;
l_last_bf_op       NUMBER := -1;
l_bf_qty           NUMBER;
l_forward          NUMBER;
l_mov_txn_id       NUMBER;
l_logLevel         NUMBER := fnd_log.g_current_runtime_level;
l_bf_required      NUMBER; -- throw away value
l_ls_required      NUMBER;
-- New variable to pass to OSFM new backflush API.
l_error_msg        VARCHAR2(1000);
l_error_count      NUMBER;
-- Fixed bug 4361566
l_return_hdr_id    NUMBER := -1;
BEGIN

  IF(fnd_api.to_boolean(p_initMsgList)) THEN
    fnd_msg_pub.initialize;
  END IF;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id;
    l_params(2).paramName   := 'p_child_txn_id';
    l_params(2).paramValue  :=  p_child_txn_id;
    l_params(3).paramName   := 'p_mtl_header_id';
    l_params(3).paramValue  :=  p_mtl_header_id;
    l_params(4).paramName   := 'p_proc_phase';
    l_params(4).paramValue  :=  p_proc_phase;
    l_params(5).paramName   := 'p_time_out';
    l_params(5).paramValue  :=  p_time_out;
    l_params(6).paramName   := 'p_move_mode';
    l_params(6).paramValue  :=  p_move_mode;
    l_params(7).paramName   := 'p_bf_mode';
    l_params(7).paramValue  :=  p_bf_mode;
    l_params(8).paramName   := 'p_mtl_mode';
    l_params(8).paramValue  :=  p_mtl_mode;
    l_params(9).paramName   := 'p_insertAssy';
    l_params(9).paramValue  :=  p_insertAssy;
    l_params(10).paramName  := 'p_do_backflush';
    l_params(10).paramValue :=  p_do_backflush;
    l_params(11).paramName  := 'p_cmp_txn_id';
    l_params(11).paramValue :=  p_cmp_txn_id;
    l_params(11).paramName  := 'p_seq_move';
    l_params(11).paramValue :=  p_seq_move;
    l_params(12).paramName  := 'p_assy_header_id';
    l_params(12).paramValue :=  p_assy_header_id;
    l_params(13).paramName  := 'p_allow_partial_commit';
    l_params(13).paramValue :=  p_allow_partial_commit;

    wip_logger.entryPoint(p_procName =>'wip_movProc_priv.processIntf',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  IF(p_move_mode = WIP_CONSTANTS.ONLINE) THEN

    -- this cursor suppose to return only one record because transaction_id
    -- is primary_key
    FOR l_move_online IN  c_move_online LOOP

      -- initialize value for l_move
      l_gib.move_profile.child_txn_id  := p_child_txn_id;
      l_gib.move_profile.cmp_txn_id    := p_cmp_txn_id;
      l_gib.move_profile.org_id        := l_move_online.org_id;
      l_gib.move_profile.wip_id        := l_move_online.wip_id;
      l_gib.move_profile.entity_type   := l_move_online.entity_type;
      l_gib.move_profile.fmOp          := l_move_online.fm_op;
      l_gib.move_profile.fmStep        := l_move_online.fm_step;
      l_gib.move_profile.toOp          := l_move_online.to_op;
      l_gib.move_profile.toStep        := l_move_online.to_step;

      IF(l_move_online.txn_type = WIP_CONSTANTS.COMP_TXN) THEN
        l_gib.move_profile.easyComplete  := WIP_CONSTANTS.YES;
      ELSE
        l_gib.move_profile.easyComplete  := WIP_CONSTANTS.NO;
      END IF;

      IF(l_move_online.txn_type = WIP_CONSTANTS.RET_TXN) THEN
        l_gib.move_profile.easyReturn  := WIP_CONSTANTS.YES;
      ELSE
        l_gib.move_profile.easyReturn  := WIP_CONSTANTS.NO;
      END IF;

      IF(l_move_online.entity_type = WIP_CONSTANTS.DISCRETE OR
         l_move_online.entity_type = WIP_CONSTANTS.LOTBASED) THEN
        l_gib.move_profile.jobTxn := WIP_CONSTANTS.YES;
      ELSE
        l_gib.move_profile.jobTxn := WIP_CONSTANTS.NO;
      END IF;

      IF(l_move_online.entity_type = WIP_CONSTANTS.REPETITIVE) THEN
        l_gib.move_profile.scheTxn := WIP_CONSTANTS.YES;
      ELSE
        l_gib.move_profile.scheTxn := WIP_CONSTANTS.NO;
      END IF;
      -- the others 4 parameters will be initialized in get_move_profile()
      -- rsrcItem, rsrcLot, poReqItem, poReqLot

      -- initialize value for l_gib
      l_gib.group_id       := p_group_id;
      l_gib.assy_header_id := p_assy_header_id;
      l_gib.mtl_header_id  := p_mtl_header_id;
      l_gib.move_mode      := WIP_CONSTANTS.ONLINE;
      l_gib.bf_mode        := p_bf_mode; -- l_bf_mode;
      l_gib.mtl_mode       := p_mtl_mode; -- l_mtl_mode;
      l_gib.process_phase  := WIP_CONSTANTS.MOVE_PROC;
      l_gib.process_status := WIP_CONSTANTS.RUNNING;
      l_gib.time_out       := p_time_out;
      l_gib.intf_tbl_name  := 'WIP_MOVE_TXN_INTERFACE';
      l_gib.user_id        := l_move_online.user_id;
      l_gib.login_id       := l_move_online.login_id;
      l_gib.request_id     := l_move_online.req_id;
      l_gib.application_id := l_move_online.appl_id;
      l_gib.program_id     := l_move_online.prog_id;
      l_gib.seq_move       := WIP_CONSTANTS.NO;
    END LOOP; -- c_move_online
  ELSE -- move mode is background
    l_gib.group_id       := p_group_id;
    l_gib.assy_header_id := p_assy_header_id;
    l_gib.mtl_header_id  := p_mtl_header_id;
    l_gib.move_mode      := WIP_CONSTANTS.BACKGROUND;
    l_gib.bf_mode        := p_bf_mode; -- l_bf_mode;
    l_gib.mtl_mode       := p_mtl_mode; -- l_mtl_mode;
    l_gib.process_phase  := p_proc_phase;
    l_gib.process_status := WIP_CONSTANTS.RUNNING;
    l_gib.time_out       := p_time_out;
    l_gib.intf_tbl_name  := 'WIP_MOVE_TXN_INTERFACE';
    l_gib.user_id        := fnd_global.user_id;
    l_gib.login_id       := fnd_global.conc_login_id;
    l_gib.request_id     := fnd_global.conc_request_id;
    l_gib.application_id := fnd_global.prog_appl_id;
    l_gib.program_id     := fnd_global.conc_program_id;
    l_gib.seq_move       := NVL(p_seq_move, WIP_CONSTANTS.NO);
  END IF; -- move is online

  IF(p_proc_phase = WIP_CONSTANTS.MOVE_VAL) THEN
    /*----------------+
     | Move Validation |
     +-----------------*/
    -- derive and validate all necessary info
    wip_move_validator.validate(p_group_id    => p_group_id,
                                p_initMsgList => fnd_api.g_true);

    -- There is no return status from this routine. IF some record error out,
    -- just neglect it and continue validating other records. The error record
    -- will have process_status in WIP_MOVE_TXN_INTERFACE equal to (3) or
    -- WIP_CONSTANTS.ERROR, and those error records will not be picked up by
    -- move_txns. The error message also show up in WIP_TXN_INTERFACE_ERRORS
  END IF; -- Move Validation

  OPEN c_txn_date;
  LOOP
  BEGIN
    FETCH c_txn_date INTO l_gib.txn_date;
    EXIT WHEN c_txn_date%NOTFOUND;
    SAVEPOINT s_move_proc;
    IF(p_proc_phase = WIP_CONSTANTS.MOVE_VAL OR
       p_proc_phase = WIP_CONSTANTS.MOVE_PROC) THEN

      IF(p_move_mode = WIP_CONSTANTS.BACKGROUND) THEN

        SELECT SUM(DECODE(entity_type,
                     WIP_CONSTANTS.DISCRETE, 1,
                     WIP_CONSTANTS.LOTBASED, 1,
                   0)),
               SUM(DECODE(entity_type,WIP_CONSTANTS.REPETITIVE,1,0))
          INTO l_job,
               l_sche
          FROM wip_move_txn_interface wmti
         WHERE wmti.group_id = l_gib.group_id
           AND TRUNC(transaction_date)= TRUNC(l_gib.txn_date)
           AND process_phase = WIP_CONSTANTS.MOVE_PROC
           AND process_status = WIP_CONSTANTS.RUNNING;

        IF(l_job > 0 AND l_sche > 0) THEN
          l_gib.move_profile.jobTxn  := WIP_CONSTANTS.YES;
          l_gib.move_profile.scheTxn := WIP_CONSTANTS.YES;
        ELSIF(l_job > 0) THEN
          l_gib.move_profile.entity_type  := WIP_CONSTANTS.DISCRETE;
          l_gib.move_profile.jobTxn  := WIP_CONSTANTS.YES;
          l_gib.move_profile.scheTxn := WIP_CONSTANTS.NO;
        ELSIF(l_sche > 0) THEN
          l_gib.move_profile.entity_type  := WIP_CONSTANTS.REPETITIVE;
          l_gib.move_profile.jobTxn  := WIP_CONSTANTS.NO;
          l_gib.move_profile.scheTxn := WIP_CONSTANTS.YES;
        END IF; -- move profile check
        -- the others 6 parameters will be initialized in get_move_profile()
        -- rsrcItem, rsrcLot, poReqItem, poReqLot, easyComplete, easyReturn
      END IF; -- Background transactions

      /* get profile of this group of transactions */
      get_move_profile(p_gib          => l_gib,
                       x_returnStatus => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_movProc_priv.get_move_profile failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status

      -- check IF easy return txns
      IF(l_gib.move_profile.easyReturn = WIP_CONSTANTS.YES) THEN
        IF(p_insertAssy = fnd_api.g_true) THEN
          ez_completion(p_gib          => l_gib,
                        p_txn_type     => WIP_CONSTANTS.RET_TXN,
                        x_returnStatus => x_returnStatus);

          IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
            l_errMsg := 'wip_movProc_priv.ez_completion (return) failed';
            raise fnd_api.g_exc_unexpected_error;
          END IF; -- check return status
        ELSE /* Bug fix 5026797 (base 4901865) - Assembly completion/return transaction through Discrete Workstation are
                processed with p_insertAssy = fnd_api.g_false. Added the following call to snapshot
                for assembly return transaction.*/
          snapshot_online(p_mtl_header_id => l_gib.assy_header_id,
                          p_org_id        => l_gib.move_profile.org_id,
                          p_txn_type      => WIP_CONSTANTS.RET_TXN,
                          p_txn_type_id   => WIP_CONSTANTS.RETASSY_TYPE,
                          p_txn_action_id => WIP_CONSTANTS.RETASSY_ACTION,
                          x_returnStatus  => x_returnStatus);

           IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_movProc_priv.snapshot_online (return) failed';
              raise fnd_api.g_exc_unexpected_error;
           END IF; -- check return status
        END IF; -- p_insertAssy = fnd_api.g_true
        /* End of bug fix 5026797 */

        IF(l_gib.assy_header_id IS NOT NULL AND
           l_gib.assy_header_id <> -1) THEN
          -- Process assembly return record
          wip_mtlTempProc_priv.processTemp
           (p_initMsgList   => fnd_api.g_true,
            p_txnHdrID      => l_gib.assy_header_id,
            p_txnMode       => WIP_CONSTANTS.ONLINE,
            x_returnStatus  => x_returnStatus,
            x_errorMsg      => l_errMsg);

          IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE', l_errMsg);
            fnd_msg_pub.add;
            l_errMsg := 'wip_mtlTempProc_priv.processTemp failed' ;
            raise fnd_api.g_exc_unexpected_error;
          END IF;
          l_return_hdr_id := l_gib.assy_header_id;
          -- reset l_gib.assy_header_id to null
          l_gib.assy_header_id := null;
        END IF; -- check l_gib.assy_header_id
      END IF; -- easy return txn

      -- initialize scrap txns to be indeterminate
      l_gib.move_profile.scrapTxn := -1;

      -- call main move processor
      move_txns(p_gib          => l_gib,
                x_returnStatus => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_movProc_priv.move_txns failed';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- check return status

      -- check IF easy completion txns
      IF(l_gib.move_profile.easyComplete = WIP_CONSTANTS.YES) THEN
        IF( p_insertAssy = fnd_api.g_true) THEN
          ez_completion(p_gib          => l_gib,
                        p_txn_type     => WIP_CONSTANTS.COMP_TXN,
                        x_returnStatus => x_returnStatus);

          IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
            l_errMsg := 'wip_movProc_priv.ez_completion (complete) failed';
            raise fnd_api.g_exc_unexpected_error;
          END IF; -- check return status
        ELSE /*  Bug fix 5026797 (base 4901865) - Assembly completion/return transaction through Discrete Workstation are
                processed with p_insertAssy = fnd_api.g_false. Added the following call to snapshot for assembly completion transaction.*/
            snapshot_online(p_mtl_header_id => l_gib.assy_header_id,
                            p_org_id        => l_gib.move_profile.org_id,
                            p_txn_type      => WIP_CONSTANTS.COMP_TXN,
                            p_txn_type_id   => WIP_CONSTANTS.CPLASSY_TYPE,
                            p_txn_action_id => WIP_CONSTANTS.CPLASSY_ACTION,
                            x_returnStatus  => x_returnStatus);

           IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_movProc_priv.snapshot_online(complete) failed';
              raise fnd_api.g_exc_unexpected_error;
           END IF; -- check return status
        END IF; -- p_insertAssy = fnd_api.g_true
        /* End of bug fix 5026797 */
      END IF; -- easy complete txn

      -- update completed quantity and take snapshot before calling inventory
      -- to process aseembly completion record
      IF(l_gib.move_mode = WIP_CONSTANTS.BACKGROUND) THEN
        update_wo_and_snapshot(p_gib          => l_gib,
                               x_returnStatus => x_returnStatus);
        IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_movProc_priv.update_wo_and_snapshot';
          raise fnd_api.g_exc_unexpected_error;
        END IF; -- check return status
      END IF;

      /* call qualtiy to enable results */
      OPEN c_qa_id(p_txn_date => l_gib.txn_date);
      LOOP
        FETCH c_qa_id INTO l_qa_collection_id;
        EXIT WHEN c_qa_id%NOTFOUND;

        QA_RESULT_GRP.ENABLE(
                      p_api_version => 1.0,
                      p_init_msg_list => fnd_api.g_true,
                      p_commit => fnd_api.g_false,
                      p_validation_level => 0,
                      p_collection_id => l_qa_collection_id,
                      p_return_status => x_returnStatus,
                      p_msg_count => l_msgCount,
                      p_msg_data => l_errMsg);

        IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE', l_errMsg);
          fnd_msg_pub.add;
          l_errMsg   := 'QA Failed. Collection ID:' || l_qa_collection_id;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP; -- c_qa_id FETCH

      CLOSE c_qa_id; /* Bug 4204892 - Close the cursor c_qa_id to avoid ORA-6511. */

      IF (l_logLevel <= wip_constants.full_logging) THEN
        wip_logger.log(p_msg          => 'QA enable success',
                       x_returnStatus => l_returnStatus);
      END IF;

      UPDATE wip_move_txn_interface
         SET process_phase = WIP_CONSTANTS.BF_SETUP
       WHERE group_id = p_group_id
         AND process_phase = WIP_CONSTANTS.MOVE_PROC
         AND process_status = WIP_CONSTANTS.RUNNING
         AND TRUNC(transaction_date) = TRUNC(l_gib.txn_date);

      -- IF debug message level = 2, write statement below to log file
      IF (l_logLevel <= wip_constants.full_logging) THEN
        fnd_message.set_name('WIP', 'WIP_UPDATED_ROWS');
        fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
        fnd_message.set_token('ENTITY2', 'WIP_MOVE_TXN_INTERFACE');
        l_msg := fnd_message.get;
        wip_logger.log(p_msg          => l_msg,
                       x_returnStatus => l_returnStatus);
      END IF;

      IF(p_allow_partial_commit = WIP_CONSTANTS.YES) THEN
        IF(l_gib.assy_header_id IS NOT NULL AND
           l_gib.assy_header_id <> -1) THEN
          -- Update lock_flag to 'Y' to prevent inventory worker pick up these
          -- records. After we commit, assembly completion record will be in
          -- MMTT. There is a slim chance that inventory worker may pick up
          -- these records after we commit, and before we call processTemp.
          UPDATE mtl_material_transactions_temp
             SET lock_flag ='Y'
           WHERE transaction_header_id = l_gib.assy_header_id;
        END IF;
        -- Fixed bug 4361566. Commit to prevent dead lock from calling
        -- inventory TM mulitple times in the same commit cycle.
        COMMIT;
        IF(l_return_hdr_id IS NOT NULL AND l_return_hdr_id <> -1) THEN
          -- Release user lock on assembly return records per inventory
          -- request.
          inv_table_lock_pvt.release_locks(p_header_id => l_return_hdr_id);
        END IF;
        -- Set savepoint again because commit will clear savepoint.
        SAVEPOINT s_move_proc;
      END IF;

      -- Calling inventory to process assembly completion records.
      IF(l_gib.assy_header_id IS NOT NULL AND
         l_gib.assy_header_id <> -1) THEN
        -- Process assembly completion record
        wip_mtlTempProc_priv.processTemp
         (p_initMsgList   => fnd_api.g_true,
          p_txnHdrID      => l_gib.assy_header_id,
          p_txnMode       => WIP_CONSTANTS.ONLINE,
          x_returnStatus  => x_returnStatus,
          x_errorMsg      => l_errMsg);

        IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE', l_errMsg);
          fnd_msg_pub.add;
          l_errMsg := 'wip_mtlTempProc_priv.processTemp failed' ;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- check l_gib.assy_header_id

      IF(p_allow_partial_commit = WIP_CONSTANTS.YES) THEN
        -- Fixed bug 4361566. Commit to prevent dead lock from calling
        -- inventory TM mulitple times in the same commit cycle.
        COMMIT;
        IF(l_gib.assy_header_id IS NOT NULL AND
           l_gib.assy_header_id <> -1) THEN
          -- Release user lock on assembly completion records per inventory
          -- request.
          inv_table_lock_pvt.release_locks(p_header_id => l_gib.assy_header_id);
        END IF;
        -- Set savepoint again because commit will clear savepoint.
        SAVEPOINT s_move_proc;
      END IF;

    END IF; -- Move Processing

    /* Backflush processing */
    IF(p_proc_phase = WIP_CONSTANTS.MOVE_VAL OR
       p_proc_phase = WIP_CONSTANTS.MOVE_PROC OR
       p_proc_phase = WIP_CONSTANTS.BF_SETUP) THEN

      IF(l_gib.bf_mode = WIP_CONSTANTS.ONLINE) THEN
        IF(p_do_backflush = fnd_api.g_true) THEN
          IF(l_gib.mtl_header_id IS NULL OR
             l_gib.mtl_header_id = -1) THEN
            SELECT mtl_material_transactions_s.nextval
              INTO l_gib.mtl_header_id
              FROM DUAL;
          END IF;

          -- backflush operation pull, and assembly pull for scrap.
          OPEN c_backflush(p_txn_date => l_gib.txn_date);
          LOOP
            FETCH c_backflush INTO l_backflush;
            EXIT WHEN c_backflush%NOTFOUND;
            BEGIN
              SAVEPOINT s_backflush_proc;
              /* Changes for bug 4916939 */
              -- Backflush assembly pull component for EZ Completion and
              -- EZ Return
              backflush_assy_pull(p_gib         => l_gib,
                                  p_move_txn_id => l_backflush.txn_id,
                                  p_entity_type => l_backflush.ent_type);
              /* End changes for bug 4916939 */
              -- Call OSFM new backflush API for OSFM job.
              IF(l_backflush.ent_type = WIP_CONSTANTS.LOTBASED) THEN
                wsm_serial_support_grp.backflush_comp(
                  p_wipEntityID     => l_backflush.wip_id,
                  p_orgID           => l_backflush.org_id,
                  p_primaryQty      => l_backflush.primary_qty,
                  p_txnDate         => l_backflush.txn_date,
                  p_txnHdrID        => l_gib.mtl_header_id,
                  p_txnType         => l_backflush.txn_type,
                  p_fmOp            => l_backflush.fm_op,
                  p_fmStep          => l_backflush.fm_step,
                  p_toOp            => l_backflush.to_op,
                  p_toStep          => l_backflush.to_step,
                  p_movTxnID        => l_backflush.txn_id,
                  p_mtlTxnMode      => l_gib.mtl_mode,
                  p_reasonID        => l_backflush.reason_id,
                  p_reference       => l_backflush.reference,
                  p_init_msg_list   => fnd_api.g_true,
                  x_lotSerRequired  => l_ls_required,
                  x_returnStatus    => l_returnStatus,
                  x_error_msg       => l_error_msg,      -- throw away value
                  x_error_count     => l_error_count);   -- throw away value

                IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
                  l_errMsg := 'wsm_serial_support_grp.backflush_comp failed' ;
                  raise fnd_api.g_exc_unexpected_error;
                ELSE
                  IF(l_ls_required = WIP_CONSTANTS.YES) THEN
                    -- If we need to gather more lot/serial, error out because
                    -- we cannot gather lot/serial for background transaction.
                    fnd_message.set_name('WIP', 'WIP_NO_LOT_SER_COMP_BKGND');
                    fnd_msg_pub.add;
                    raise fnd_api.g_exc_unexpected_error;
                  END IF;
                END IF; -- check return status
              ELSE -- discrete job or repetitive schedule
                wip_bflProc_priv.backflush(
                  p_wipEntityID     => l_backflush.wip_id,
                  p_orgID           => l_backflush.org_id,
                  p_primaryQty      => l_backflush.primary_qty,
                  p_txnDate         => l_backflush.txn_date,
                  p_txnHdrID        => l_gib.mtl_header_id,
        -- Fixed bug 5056289. Pass move_id as a batch_id because we want
        -- inventory to fail only components related to a specific move record.
                  p_batchID         => l_backflush.txn_id,
                  p_txnType         => l_backflush.txn_type,
                  p_entityType      => l_backflush.ent_type,
                  p_tblName         => WIP_CONSTANTS.MTI_TBL,
                  p_lineID          => l_backflush.line_id,
                  p_fmOp            => l_backflush.fm_op,
                  p_fmStep          => l_backflush.fm_step,
                  p_toOp            => l_backflush.to_op,
                  p_toStep          => l_backflush.to_step,
                  p_movTxnID        => l_backflush.txn_id,
                  p_fmMoveProcessor => WIP_CONSTANTS.YES,
                  p_mtlTxnMode      => l_gib.mtl_mode,
                  p_reasonID        => l_backflush.reason_id,
                  p_reference       => l_backflush.reference,
                  x_lotSerRequired  => l_ls_required,
                  x_bfRequired      => l_bf_required,
                  x_returnStatus    => l_returnStatus);

                IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
                  l_errMsg := 'wip_bflProc_priv.backflush failed' ;
                  raise fnd_api.g_exc_unexpected_error;
                ELSE
                  IF(l_ls_required = WIP_CONSTANTS.YES) THEN
                   -- If we need to gather more lot/serial, error out because
                    -- we cannot gather lot/serial for background transaction.
                    fnd_message.set_name('WIP', 'WIP_NO_LOT_SER_COMP_BKGND');
                    fnd_msg_pub.add;
                    raise fnd_api.g_exc_unexpected_error;
                  END IF;
                END IF; -- check return status
              END IF; -- check entity type
            EXCEPTION
              WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO SAVEPOINT s_backflush_proc;
                wip_utilities.get_message_stack(p_msg =>l_errMsg);
                IF(l_errMsg IS NULL) THEN
                  -- initialize message to something because we cannot
                  -- insert null into WIP_TXN_INTERFACE_ERRORS
                  fnd_message.set_name('WIP', 'WIP_SOME_RECORDS_ERROR');
                  l_errMsg := fnd_message.get;
                END IF;
                IF(p_move_mode = WIP_CONSTANTS.BACKGROUND) THEN
                  /* Update process status to error */
                  UPDATE wip_move_txn_interface
                     SET process_status = WIP_CONSTANTS.ERROR
                   WHERE group_id = p_group_id
                     AND process_status = WIP_CONSTANTS.RUNNING
                     AND transaction_id = l_backflush.txn_id;

                  /* insert error messages */
                  INSERT INTO wip_txn_interface_errors
                   (transaction_id,
                    error_column,
                    error_message,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date
                   )
                  SELECT wmti.transaction_id,
                         NULL,                       -- error_column
                         substrb(l_errMsg,1,240),    -- error_message
                         SYSDATE,                    -- last_update_date
                         l_gib.user_id,              -- last_update_by
                         SYSDATE,                    -- creation_date
                         l_gib.user_id,              -- created_by
                         l_gib.login_id,
                         l_gib.request_id,
                         l_gib.application_id,
                         l_gib.program_id,
                         SYSDATE                     -- program_update_date
                    FROM wip_move_txn_interface wmti
                   WHERE wmti.group_id = p_group_id
                     AND transaction_id = l_backflush.txn_id;

                ELSE -- move mode is online, write to log file
                  IF(x_returnStatus = fnd_api.g_ret_sts_error) THEN
                    -- let the user know that more lot/serial info required
                    x_returnStatus := fnd_api.g_ret_sts_error;
                  END IF;
                  IF (l_logLevel <= wip_constants.trace_logging) THEN
                    l_errMsg := 'move_txn_id: ' || l_backflush.txn_id ||
                                ' failed because ' || l_errMsg;
                    wip_logger.log(p_msg          => l_errMsg,
                                   x_returnStatus => l_returnStatus);
                  END IF;
                END IF;
            END;
          /* End of Changes for bug 4628893 */
          END LOOP; -- c_backflush

          CLOSE c_backflush; /* Bug 4204892 - Close the cursor c_backflush to avoid ORA-6511. */

          -- Move assembly pull and operation pull records from mti to mmtt
          -- pass fnd_api.g_false to p_addMsgToStack because we never used
          -- message stack for background transaction. Moreover, this will
          -- improve performance if there are lots of errors.
          wip_mtlTempProc_priv.validateInterfaceTxns(
            p_txnHdrID      => l_gib.mtl_header_id,
            p_addMsgToStack => fnd_api.g_false,
            p_rollbackOnErr => fnd_api.g_false,
            x_returnStatus  => x_returnStatus);

          IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
            -- write error into WIP_TXN_INTERFACE_ERRORS
            write_mtl_errors(p_mtl_header_id => l_gib.mtl_header_id);
            IF (l_logLevel <= wip_constants.full_logging) THEN
              l_errMsg := 'wip_mtlTempProc_priv.validateInterfaceTxns failed'||
                          ' (component records)' ;
              wip_logger.log(p_msg          => l_errMsg,
                             x_returnStatus => l_returnStatus);
            END IF;
            -- Fixed bug 5056289. We will not raise exception because we still
            -- want to process the components that pass validation.
            -- raise fnd_api.g_exc_unexpected_error;

            -- Call component_cleanup to set the status of corresponding move
            -- records to error and delete error records from MTI and MTLI.
            component_cleanup(p_mtl_header_id => l_gib.mtl_header_id,
                              p_group_id      => p_group_id);

          END IF;
        END IF; -- p_do_backflush
      /*---------------------+
       | Inventory processing |
       +---------------------*/
        SELECT count(*)
            INTO l_MMTT_record
            FROM mtl_material_transactions_temp
           WHERE transaction_header_id = l_gib.mtl_header_id;

        IF(l_MMTT_record > 0 AND
           l_gib.mtl_mode <> WIP_CONSTANTS.NO_PROCESSING) THEN
          -- Call material processor to process backflush components, and
          -- scrap assembly.
          wip_mtlTempProc_priv.processTemp
           (p_initMsgList   => fnd_api.g_true,
            p_txnHdrID      => l_gib.mtl_header_id,
            p_txnMode       => l_gib.mtl_mode,
            x_returnStatus  => x_returnStatus,
            x_errorMsg      => l_errMsg);

          IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE', l_errMsg);
            fnd_msg_pub.add;
            l_errMsg := 'wip_mtlTempProc_priv.processTemp failed' ;
            raise fnd_api.g_exc_unexpected_error;
          END IF;
        END IF; -- there is the records in MMTT with this header_id
      ELSE -- backflush is background
        UPDATE wip_move_txn_interface
           SET group_id = NULL,
               process_phase = WIP_CONSTANTS.BF_SETUP,
               process_status = WIP_CONSTANTS.PENDING
         WHERE group_id = p_group_id
           AND process_status = WIP_CONSTANTS.RUNNING;
      END IF; -- backflush is online
    END IF; -- Backflush Setup

    IF(p_allow_partial_commit = WIP_CONSTANTS.YES) THEN
      -- Fixed bug 4361566. Commit to prevent dead lock from calling
      -- inventory TM mulitple times in the same commit cycle.
      COMMIT;
      IF(l_MMTT_record > 0 AND
         l_gib.mtl_mode <> WIP_CONSTANTS.NO_PROCESSING) THEN
        -- Release user lock on backflush records per inventory request.
        inv_table_lock_pvt.release_locks(p_header_id => l_gib.mtl_header_id);
      END IF;
      -- Set savepoint again because commit will clear savepoint.
      SAVEPOINT s_move_proc;
    END IF;

    -- initialize transaction_header_id for each group on each day
    l_gib.mtl_header_id := -1;

  EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error THEN

      IF(p_move_mode = WIP_CONSTANTS.BACKGROUND) THEN

        ROLLBACK TO SAVEPOINT s_move_proc;
        /*Fix for bug 8473023(FP 8358813)*/
        /*Update the lock_flag in MMTT to be 'N' if failed in Move Processing Phase*/
        clean_up(p_assy_header_id => l_gib.assy_header_id);

        /* Update process status to error */
        UPDATE wip_move_txn_interface
           SET process_status = WIP_CONSTANTS.ERROR
         WHERE group_id = p_group_id
           AND process_status = WIP_CONSTANTS.RUNNING
           AND TRUNC(transaction_date)= TRUNC(l_gib.txn_date);

        wip_utilities.get_message_stack(p_msg =>l_errMsg);
        IF(l_errMsg IS NULL) THEN
          -- initialize message to something because we cannot insert null
          -- into WIP_TXN_INTERFACE_ERRORS
          fnd_message.set_name('WIP', 'WIP_SOME_RECORDS_ERROR');
          l_errMsg := fnd_message.get;
        END IF;

        /* insert error messages */
        INSERT INTO wip_txn_interface_errors
          (transaction_id,
           error_column,
           error_message,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date
          )
          SELECT wmti.transaction_id,
                 NULL,                       -- error_column
                 substrb(l_errMsg,1,240),    -- error_message
                 SYSDATE,                    -- last_update_date
                 l_gib.user_id,              -- last_update_by
                 SYSDATE,                    -- creation_date
                 l_gib.user_id,              -- created_by
                 l_gib.login_id,
                 l_gib.request_id,
                 l_gib.application_id,
                 l_gib.program_id,
                 SYSDATE                     -- program_update_date
            FROM wip_move_txn_interface wmti
           WHERE wmti.group_id = p_group_id
             AND TRUNC(wmti.transaction_date) = TRUNC(l_gib.txn_date)
             AND NOT EXISTS (SELECT 1
                               FROM wip_txn_interface_errors wtie
                              WHERE wtie.transaction_id = wmti.transaction_id);

      ELSE -- move mode is online, write to log file
        IF(x_returnStatus = fnd_api.g_ret_sts_error) THEN
          -- let the user know that more lot/serial info required
          x_returnStatus := fnd_api.g_ret_sts_error;
        ELSE
           ROLLBACK TO SAVEPOINT s_move_proc;
           x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        END IF;
        IF (l_logLevel <= wip_constants.trace_logging) THEN
          wip_logger.exitPoint(p_procName =>'wip_movProc_priv.processIntf',
                               p_procReturnStatus => x_returnStatus,
                               p_msg => l_errMsg,
                               x_returnStatus => l_returnStatus);
        END IF;
        -- close log file
        IF (p_ENDDebug = fnd_api.g_true) THEN
          wip_logger.cleanUp(x_returnStatus => l_returnStatus);
        END IF;
        GOTO END_program;
      END IF; -- move mode is background

    WHEN others THEN
      ROLLBACK TO SAVEPOINT s_move_proc;
      IF(p_move_mode = WIP_CONSTANTS.BACKGROUND) THEN

         /* Update process status to error */
        UPDATE wip_move_txn_interface
           SET process_status = WIP_CONSTANTS.ERROR
         WHERE group_id = p_group_id
           AND process_status = WIP_CONSTANTS.RUNNING
           AND TRUNC(transaction_date)= TRUNC(l_gib.txn_date);

        l_errMsg := 'unexpected error: ' || SQLERRM;

        /* insert error messages */
        INSERT INTO wip_txn_interface_errors
          (transaction_id,
           error_column,
           error_message,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date
          )
          SELECT wmti.transaction_id,
                 NULL,                       -- error_column
                 substrb(l_errMsg,1,240),    -- error_message
                 SYSDATE,                    -- last_update_date
                 l_gib.user_id,              -- last_update_by
                 SYSDATE,                    -- creation_date
                 l_gib.user_id,              -- created_by
                 l_gib.login_id,
                 l_gib.request_id,
                 l_gib.application_id,
                 l_gib.program_id,
                 SYSDATE                     -- program_update_date
            FROM wip_move_txn_interface wmti
           WHERE wmti.group_id = p_group_id
             AND TRUNC(wmti.transaction_date) = TRUNC(l_gib.txn_date)
             AND NOT EXISTS (SELECT 1
                               FROM wip_txn_interface_errors wtie
                              WHERE wtie.transaction_id = wmti.transaction_id);
      ELSE -- move mode is online
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        IF (l_logLevel <= wip_constants.trace_logging) THEN
          wip_logger.exitPoint(p_procName=>'wip_movProc_priv.processIntf',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexpected error: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
        END IF;
        -- close log file
        IF (p_ENDDebug = fnd_api.g_true) THEN
          wip_logger.cleanUp(x_returnStatus => l_returnStatus);
        END IF;
        GOTO END_program;
      END IF; -- move mode is background
  END;

  END LOOP; -- c_txn_date FETCH
  /*---------------------------------------------------------------------+
   | Set group_mark_id to wip_entity_id for Return and Move transactions |
   +---------------------------------------------------------------------*/
  UPDATE mtl_serial_numbers msn1
     SET msn1.group_mark_id = msn1.wip_entity_id
   WHERE msn1.gen_object_id =
         (SELECT msn2.gen_object_id
            FROM wip_move_txn_interface wmti,
                 wip_serial_move_interface wsmi,
                 mtl_serial_numbers msn2
           WHERE wmti.transaction_id = wsmi.transaction_id
             AND wsmi.assembly_serial_number = msn2.serial_number
             AND wmti.primary_item_id = msn2.inventory_item_id
             AND wmti.organization_id = msn2.current_organization_id
             AND wmti.wip_entity_id = msn2.wip_entity_id
             AND msn2.group_mark_id IS NULL
             AND wmti.group_id = p_group_id
             AND wmti.process_phase = WIP_CONSTANTS.BF_SETUP
             AND wmti.process_status = WIP_CONSTANTS.RUNNING
             AND wmti.transaction_type = WIP_CONSTANTS.RET_TXN);

  /*--------------------------------------+
   | Delete serial move interface records |
   +--------------------------------------*/
  DELETE FROM wip_serial_move_interface
  WHERE transaction_id IN
       (SELECT transaction_id
          FROM wip_move_txn_interface
         WHERE group_id = p_group_id
           AND process_phase = WIP_CONSTANTS.BF_SETUP
           AND process_status = WIP_CONSTANTS.RUNNING);

  /*-------------------------------+
   | Delete move interface records |
   +-------------------------------*/
  DELETE FROM wip_move_txn_interface
  WHERE group_id = p_group_id
    AND process_phase = WIP_CONSTANTS.BF_SETUP
    AND process_status = WIP_CONSTANTS.RUNNING;

  /*--------------------------------+
   |  check for failed transactions |
   +--------------------------------*/
  SELECT COUNT(1)
    INTO l_err_record
    FROM WIP_MOVE_TXN_INTERFACE
   WHERE GROUP_ID = p_group_id
     AND process_status in (WIP_CONSTANTS.ERROR, WIP_CONSTANTS.RUNNING);

  IF(l_err_record > 0) THEN
    /*===========================================================*/
    /*  transactions in current group left in interface table -  */
    /*  worker exit with warning signal                          */
    /*===========================================================*/
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    -- Fixed bug 5355443. We should not always put WIP_SOME_RECORDS_ERROR in
    -- the message stack because this API will be called for both online and
    -- background transaction. However, WIP_SOME_RECORDS_ERROR is only
    -- applicable for background transaction.
    --fnd_message.set_name('WIP', 'WIP_SOME_RECORDS_ERROR');
    --fnd_msg_pub.add;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.processIntf',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'some records error out',
                           x_returnStatus => l_returnStatus);
    END IF;
    -- close log file
    IF (p_ENDDebug = fnd_api.g_true) THEN
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;
    /*Bug 5727221 (FP of 5580093): Mobile WIP Transaction seems to be leaving
      transaction in WMTI in some exception case. However there is no error
      message propagated back to UI. As a result transaction goes through fine
      with no UI error but record remains in WMTI. x_returnStatus is changed
      to sucess by cleanup procedure after closing file . Hence repopulate
      x_returnStatus to error  again  */
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
  ELSE
    x_returnStatus := fnd_api.g_ret_sts_success;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.processIntf',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'no record in this group error out',
                           x_returnStatus => l_returnStatus);
    END IF;
    -- close log file
    IF (p_ENDDebug = fnd_api.g_true) THEN
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;
  END IF;

<<END_program>>
  IF(c_backflush%ISOPEN) THEN
    CLOSE c_backflush;
  END IF;
  IF (c_qa_id%ISOPEN) THEN
    CLOSE c_qa_id;
  END IF;
  IF (c_txn_date%ISOPEN) THEN
    CLOSE c_txn_date;
  END IF;
END processIntf;

PROCEDURE move_worker(errbuf       OUT NOCOPY VARCHAR2,
                      retcode      OUT NOCOPY NUMBER,
                      p_group_id   IN         NUMBER,
                      p_proc_phase IN         NUMBER,
                      p_time_out   IN         NUMBER,
                      p_seq_move   IN         NUMBER) IS

l_returnStatus VARCHAR2(1);
BEGIN
  retcode := 0; -- success
  /* Set process phase to 'Running' */
  UPDATE wip_move_txn_interface
     SET process_status = WIP_CONSTANTS.RUNNING,
         last_update_date = SYSDATE,
         last_update_login = fnd_global.conc_login_id,
         request_id = fnd_global.conc_request_id,
         program_application_id = fnd_global.prog_appl_id,
         program_id = fnd_global.conc_program_id,
         program_update_date = SYSDATE
   WHERE group_id = p_group_id;

   -- Fixed bug 4361566. Set global variable to let inventory know that they
   -- should not delete lock record from their temp table. These lock records
   -- will be deleted when wip call inv_table_lock_pvt.release_locks.
   WIP_CONSTANTS.WIP_MOVE_WORKER := 'Y';

   wip_movProc_priv.processIntf
    (p_group_id             => p_group_id,
     p_proc_phase           => p_proc_phase,
     p_time_out             => p_time_out,
     p_move_mode            => WIP_CONSTANTS.BACKGROUND,
     p_bf_mode              => WIP_CONSTANTS.ONLINE,
     p_mtl_mode             => WIP_CONSTANTS.ONLINE,
     p_endDebug             => FND_API.G_TRUE,
     p_initMsgList          => FND_API.G_TRUE,
     p_insertAssy           => FND_API.G_TRUE,
     p_do_backflush         => FND_API.G_TRUE,
     p_seq_move             => p_seq_move,
     p_allow_partial_commit => WIP_CONSTANTS.YES, -- Fixed bug 4361566.
     x_returnStatus         => l_returnStatus);

   -- Fixed bug 4361566. Reset global variable WIP_MOVE_WORKER to its original
   -- value.
   WIP_CONSTANTS.WIP_MOVE_WORKER := 'N';

   IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
     retcode := 2; -- error
     -- Fixed bug 5355443. Since WIP_SOME_RECORDS_ERROR message is only
     -- applicable to background transaction, we should set error message here
     -- instead of wip_movProc_priv.processIntf().
     --wip_utilities.get_message_stack(p_msg =>errbuf);
     fnd_message.set_name('WIP', 'WIP_SOME_RECORDS_ERROR');
     errbuf := fnd_message.get;
   END IF;
   COMMIT; -- To prevent Move Worker concurrent program rollback.
EXCEPTION
  WHEN others THEN
    retcode := 2; -- error
    errbuf := SQLERRM;
END move_worker;

PROCEDURE repetitive_scrap(p_tmp_id       IN         NUMBER,
                           x_returnStatus OUT NOCOPY VARCHAR2) IS

l_params       wip_logger.param_tbl_t;
l_returnStatus VARCHAR2(1);
l_msg          VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
BEGIN
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_tmp_id';
    l_params(1).paramValue  :=  p_tmp_id;
    wip_logger.entryPoint(p_procName => 'wip_movProc_priv.repetitive_scrap',
                          p_params   => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;
  -- insert into mtl_material_txn_allocations for repetitive schedule
  INSERT INTO mtl_material_txn_allocations
     (transaction_id,
      repetitive_schedule_id,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      primary_quantity,
      transaction_quantity,
      transaction_date
     )
     SELECT mmtt.material_allocation_temp_id,  -- transaction_id
            wmta.repetitive_schedule_id,
            wmta.organization_id,
            SYSDATE,                           -- last_update_date
            wmta.last_updated_by,
            SYSDATE,                           -- creation_date
            wmta.created_by,
            wmta.last_update_login,
            wmta.request_id,
            wmta.program_application_id,
            wmta.program_id,
            wmta.program_update_date,
            wmta.primary_quantity *
              sign(mmtt.primary_quantity),     -- primary_quantity
            wmta.transaction_quantity *
              sign(mmtt.transaction_quantity), -- transaction_quantity
            wmti.transaction_date
       FROM wip_move_txn_allocations wmta,
            wip_move_txn_interface wmti,
            mtl_material_transactions_temp mmtt
      WHERE wmti.transaction_id = wmta.transaction_id
        AND wmti.organization_id = wmta.organization_id
        AND wmti.transaction_id = mmtt.move_transaction_id
        AND mmtt.transaction_temp_id = p_tmp_id
        AND mmtt.transaction_action_id = WIP_CONSTANTS.SCRASSY_ACTION;

  -- IF debug message level = 2, write statement below to log file
  IF (l_logLevel <= wip_constants.full_logging) THEN
    fnd_message.set_name('WIP', 'WIP_INSERTED_ROWS');
    fnd_message.set_token('ENTITY1', SQL%ROWCOUNT);
    fnd_message.set_token('ENTITY2', 'MTL_MATERIAL_TXN_ALLOCATIONS');
    l_msg := fnd_message.get;
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_returnStatus);
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_success;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_movProc_priv.repetitive_scrap',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_returnStatus);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msg);
    fnd_msg_pub.add;
END repetitive_scrap;

/*****************************************************************************
 * This procedure will be used by WIP OA Transaction page to insert record
 * into WIP_MOVE_TXN_INTERFACE.
 ****************************************************************************/
PROCEDURE insert_record(p_transaction_id                 IN NUMBER,
                        p_last_update_date               IN DATE,
                        p_last_updated_by                IN NUMBER,
                        p_last_updated_by_name           IN VARCHAR2,
                        p_creation_date                  IN DATE,
                        p_created_by                     IN NUMBER,
                        p_created_by_name                IN VARCHAR2,
                        p_last_update_login              IN NUMBER,
                        p_request_id                     IN NUMBER,
                        p_program_application_id         IN NUMBER,
                        p_program_id                     IN NUMBER,
                        p_program_update_date            IN DATE,
                        p_group_id                       IN NUMBER,
                        p_source_code                    IN VARCHAR2,
                        p_source_line_id                 IN NUMBER,
                        p_process_phase                  IN NUMBER,
                        p_process_status                 IN NUMBER,
                        p_transaction_type               IN NUMBER,
                        p_organization_id                IN NUMBER,
                        p_organization_code              IN VARCHAR2,
                        p_wip_entity_id                  IN NUMBER,
                        p_wip_entity_name                IN VARCHAR2,
                        p_entity_type                    IN NUMBER,
                        p_primary_item_id                IN NUMBER,
                        p_line_id                        IN NUMBER,
                        p_line_code                      IN VARCHAR2,
                        p_repetitive_schedule_id         IN NUMBER,
                        p_transaction_date               IN DATE,
                        p_acct_period_id                 IN NUMBER,
                        p_fm_operation_seq_num           IN NUMBER,
                        p_fm_operation_code              IN VARCHAR2,
                        p_fm_department_id               IN NUMBER,
                        p_fm_department_code             IN VARCHAR2,
                        p_fm_intraoperation_step_type    IN NUMBER,
                        p_to_operation_seq_num           IN NUMBER,
                        p_to_operation_code              IN VARCHAR2,
                        p_to_department_id               IN NUMBER,
                        p_to_department_code             IN VARCHAR2,
                        p_to_intraoperation_step_type    IN NUMBER,
                        p_transaction_quantity           IN NUMBER,
                        p_transaction_uom                IN VARCHAR2,
                        p_primary_quantity               IN NUMBER,
                        p_primary_uom                    IN VARCHAR2,
                        p_scrap_account_id               IN NUMBER,
                        p_reason_id                      IN NUMBER,
                        p_reason_name                    IN VARCHAR2,
                        p_reference                      IN VARCHAR2,
                        p_attribute_category             IN VARCHAR2,
                        p_attribute1                     IN VARCHAR2,
                        p_attribute2                     IN VARCHAR2,
                        p_attribute3                     IN VARCHAR2,
                        p_attribute4                     IN VARCHAR2,
                        p_attribute5                     IN VARCHAR2,
                        p_attribute6                     IN VARCHAR2,
                        p_attribute7                     IN VARCHAR2,
                        p_attribute8                     IN VARCHAR2,
                        p_attribute9                     IN VARCHAR2,
                        p_attribute10                    IN VARCHAR2,
                        p_attribute11                    IN VARCHAR2,
                        p_attribute12                    IN VARCHAR2,
                        p_attribute13                    IN VARCHAR2,
                        p_attribute14                    IN VARCHAR2,
                        p_attribute15                    IN VARCHAR2,
                        p_qa_collection_id               IN NUMBER,
                        p_kanban_card_id                 IN NUMBER,
                        p_oc_transaction_qty             IN NUMBER,
                        p_oc_primary_qty                 IN NUMBER,
                        p_oc_transaction_id              IN NUMBER,
                        p_xml_document_id                IN VARCHAR2,
                        p_processing_order               IN NUMBER,
                        p_batch_id                       IN NUMBER,
                        p_employee_id                    IN NUMBER,
                        p_completed_instructions         IN NUMBER) IS
BEGIN
  INSERT INTO wip_move_txn_interface
    (transaction_id,
     last_update_date,
     last_updated_by,
     last_updated_by_name,
     creation_date,
     created_by,
     created_by_name,
     last_update_login,
     request_id,
     program_application_id,
     program_id,
     program_update_date,
     group_id,
     source_code,
     source_line_id,
     process_phase,
     process_status,
     transaction_type,
     organization_id,
     organization_code,
     wip_entity_id,
     wip_entity_name,
     entity_type,
     primary_item_id,
     line_id,
     line_code,
     repetitive_schedule_id,
     transaction_date,
     acct_period_id,
     fm_operation_seq_num,
     fm_operation_code,
     fm_department_id,
     fm_department_code,
     fm_intraoperation_step_type,
     to_operation_seq_num,
     to_operation_code,
     to_department_id,
     to_department_code,
     to_intraoperation_step_type,
     transaction_quantity,
     transaction_uom,
     primary_quantity,
     primary_uom,
     scrap_account_id,
     reason_id,
     reason_name,
     reference,
     attribute_category,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     qa_collection_id,
     kanban_card_id,
     overcompletion_transaction_qty,
     overcompletion_primary_qty,
     overcompletion_transaction_id,
     xml_document_id,
     processing_order,
     batch_id,
     employee_id,
     completed_instructions)
   VALUES
    (p_transaction_id,
     p_last_update_date,
     p_last_updated_by,
     p_last_updated_by_name,
     p_creation_date,
     p_created_by,
     p_created_by_name,
     p_last_update_login,
     p_request_id,
     p_program_application_id,
     p_program_id,
     p_program_update_date,
     p_group_id,
     p_source_code,
     p_source_line_id,
     p_process_phase,
     p_process_status,
     p_transaction_type,
     p_organization_id,
     p_organization_code,
     p_wip_entity_id,
     p_wip_entity_name,
     p_entity_type,
     p_primary_item_id,
     p_line_id,
     p_line_code,
     p_repetitive_schedule_id,
     p_transaction_date,
     p_acct_period_id,
     p_fm_operation_seq_num,
     p_fm_operation_code,
     p_fm_department_id,
     p_fm_department_code,
     p_fm_intraoperation_step_type,
     p_to_operation_seq_num,
     p_to_operation_code,
     p_to_department_id,
     p_to_department_code,
     p_to_intraoperation_step_type,
     p_transaction_quantity,
     p_transaction_uom,
     p_primary_quantity,
     p_primary_uom,
     p_scrap_account_id,
     p_reason_id,
     p_reason_name,
     p_reference,
     p_attribute_category,
     p_attribute1,
     p_attribute2,
     p_attribute3,
     p_attribute4,
     p_attribute5,
     p_attribute6,
     p_attribute7,
     p_attribute8,
     p_attribute9,
     p_attribute10,
     p_attribute11,
     p_attribute12,
     p_attribute13,
     p_attribute14,
     p_attribute15,
     p_qa_collection_id,
     p_kanban_card_id,
     p_oc_transaction_qty,
     p_oc_primary_qty,
     p_oc_transaction_id,
     p_xml_document_id,
     p_processing_order,
     p_batch_id,
     p_employee_id,
     p_completed_instructions);

END insert_record;

PROCEDURE processOATxn(p_group_id       IN        NUMBER,
                       p_child_txn_id   IN        NUMBER,
                       p_mtl_header_id  IN        NUMBER,
                       p_do_backflush   IN        VARCHAR2,
                       p_assySerial     IN        VARCHAR2:= NULL,
		       p_print_label    IN        NUMBER default null, /* VJ Label Printing */
                       x_returnStatus  OUT NOCOPY VARCHAR2) IS

CURSOR c_errors IS
  SELECT wtie.error_column,
         wtie.error_message
    FROM wip_txn_interface_errors wtie,
         wip_move_txn_interface wmti
   WHERE wtie.transaction_id = wmti.transaction_id
     AND wmti.group_id = p_group_id;

CURSOR c_move_records IS
  SELECT wmt.wip_entity_id wip_id,
         wmt.fm_operation_seq_num fm_op,
         wmt.to_operation_seq_num to_op
    FROM wip_move_transactions wmt
   WHERE wmt.transaction_id = p_group_id;

l_log_level     NUMBER := fnd_log.g_current_runtime_level;
l_error_msg     VARCHAR2(1000);
l_process_phase VARCHAR2(3);
l_return_status VARCHAR(1);
l_errors        c_errors%ROWTYPE;
l_move_records  c_move_records%ROWTYPE;
l_params        wip_logger.param_tbl_t;
l_msg_count     NUMBER; /* VJ Label Printing */
l_msg_stack     VARCHAR2(2000); /* VJ Label Printing */

BEGIN

  /* Fix for bug 5518780. Initialize msg stack here instead of exception handler
     so that messages from INV are not deleted */
  fnd_msg_pub.initialize;

  l_process_phase := '1';
  IF (l_log_level <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id;
    l_params(2).paramName   := 'p_child_txn_id';
    l_params(2).paramValue  :=  p_child_txn_id;
    l_params(3).paramName   := 'p_mtl_header_id';
    l_params(3).paramValue  :=  p_mtl_header_id;
    l_params(4).paramName   := 'p_do_backflush';
    l_params(4).paramValue  :=  p_do_backflush;
    l_params(5).paramName   := 'p_assySerial';
    l_params(5).paramValue  :=  p_assySerial;
    l_params(6).paramName   := 'p_print_label'; /* VJ Label Printing */
    l_params(6).paramValue  :=  p_print_label;  /* VJ Label Printing */

    wip_logger.entryPoint(p_procName     => 'wip_movProc_priv.processOATxn',
                          p_params       => l_params,
                          x_returnStatus => l_return_status);
  END IF;
  l_process_phase := '2';
  SAVEPOINT s_oa_txn_proc;

  IF(p_assySerial IS NOT NULL) THEN
    -- serial txns, so need to insert record into WIP_SERIAL_MOVE_INTERFACE too
    IF(wma_move.insertSerial(groupID       => p_group_id,
                             transactionID => p_group_id,
                             serialNumber  => p_assySerial,
                             errMessage    => l_error_msg) = FALSE) THEN
      -- insert statement error out
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF; -- from serialized page
  l_process_phase := '2.5';
  -- Validate and move records from MTI to MMTT. This will move both assembly
  -- and component records because we use the same header Id.
  wip_mtlTempProc_priv.validateInterfaceTxns(
    p_txnHdrID      => p_mtl_header_id,
    p_addMsgToStack => fnd_api.g_true, -- So that we can display to user
    p_rollbackOnErr => fnd_api.g_false,
    x_returnStatus  => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    raise fnd_api.g_exc_unexpected_error;
  END IF;
  l_process_phase := '3';

  -- Perform some validations that have not done in the UI
  wip_move_validator.validateOATxn(p_group_id => p_group_id);
  l_process_phase := '4';

  -- Process move and material records.
  wip_movProc_priv.processIntf
   (p_group_id       => p_group_id,
    p_child_txn_id   => p_child_txn_id,
    p_mtl_header_id  => p_mtl_header_id,
    p_assy_header_id => p_mtl_header_id,
    p_proc_phase     => WIP_CONSTANTS.MOVE_PROC,
    p_time_out       => 0,
    p_move_mode      => WIP_CONSTANTS.ONLINE,
    p_bf_mode        => WIP_CONSTANTS.ONLINE,
    p_mtl_mode       => WIP_CONSTANTS.ONLINE,
    p_endDebug       => FND_API.G_FALSE,
    p_initMsgList    => FND_API.G_TRUE,
    p_insertAssy     => FND_API.G_FALSE,
    p_do_backflush   => p_do_backflush,
    x_returnStatus   => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    l_process_phase := '5';
    raise fnd_api.g_exc_unexpected_error;
  ELSE
    l_process_phase := '6';
    -- If move success, call time entry API to clock off operator if there
    -- is no quantity left at the operation.
    FOR l_move_records IN c_move_records LOOP
      wip_ws_time_entry.process_time_records_move(
        p_wip_entity_id => l_move_records.wip_id,
        p_from_op       => l_move_records.fm_op,
        p_to_op         => l_move_records.to_op);
    END LOOP;
    l_process_phase := '7';
  END IF;

  /* Start: VJ Label Printing */
  IF (p_print_label = 1) THEN
    wip_utilities.print_move_txn_label(p_txn_id  => p_group_id,
				       x_status  => l_return_status,
				       x_msg_count => l_msg_count,
				       x_msg  => l_error_msg);
    -- do not error out if label printing, only put warning message in log
    IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
      wip_utilities.get_message_stack(p_msg => l_msg_stack);
      IF (l_log_level <= wip_constants.full_logging) THEN
        wip_logger.log(p_msg => 'An error has occurred with label printing.\n' ||
                                'The following error has occurred during ' ||
                                'printing: ' || l_msg_stack || '\n' ||
                                'Please check the Inventory log file for more ' ||
                                'information.',
                       x_returnStatus =>l_return_status);
      END IF;
    END IF;
  END IF;
  l_process_phase := '8';
  /* End: VJ Label Printing */

  x_returnStatus := fnd_api.g_ret_sts_success;

  -- write to the log file
  IF (l_log_level <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_priv.processOATxn',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_return_status);
  END IF;
  -- close log file
  wip_logger.cleanUp(x_returnStatus => l_return_status);
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    -- Fixed bug 5518780. We should not clear message from the stack.
    -- If it fails inventory validation, no error will be recorded in WTIE.
    -- Instead, error message will be put in message stack.
    -- fnd_msg_pub.initialize;
    FOR l_errors IN c_errors LOOP
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errors.error_message);
      fnd_msg_pub.add;
    END LOOP;
    ROLLBACK TO SAVEPOINT s_oa_txn_proc;
    x_returnStatus := fnd_api.g_ret_sts_error;
    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.processOATxn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'wip_movProc_priv.processOATxn failed : '
                                     || l_process_phase,
                           x_returnStatus => l_return_status);
    END IF;
    -- close log file
    wip_logger.cleanUp(x_returnStatus => l_return_status);
  WHEN others THEN
    ROLLBACK TO SAVEPOINT s_oa_txn_proc;
    x_returnStatus := fnd_api.g_ret_sts_error;
    l_error_msg := ' unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_error_msg);
    fnd_msg_pub.add;

    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_priv.processOATxn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_error_msg || ' : ' || l_process_phase,
                           x_returnStatus => l_return_status);
    END IF;
    -- close log file
    wip_logger.cleanUp(x_returnStatus => l_return_status);
END processOATxn;

/*****************************************************************************
 * This procedure update the lock_flag value to 'N' in MMTT if the move
 * transaction failed during Move Processing Phase so that no records will
 * will stuck in MMTT. Added this procedure for fix of bug 8473023(FP 8358813)
 ****************************************************************************/
 PROCEDURE clean_up(p_assy_header_id  IN     NUMBER) IS

 BEGIN
 	  UPDATE mtl_material_transactions_temp
 	  SET lock_flag ='N'
 	  WHERE transaction_header_id = p_assy_header_id;

 END clean_up;

END wip_movProc_priv;

/
