--------------------------------------------------------
--  DDL for Package Body WMA_MOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_MOVE" AS
/* $Header: wmapmovb.pls 120.3 2007/09/17 21:26:29 kboonyap ship $ */

/**
 * This procedure is the entry point into the Move Processing code
 * Parameters:
 *   parameters  The MoveParam containing values from the mobile move form.
 *   status      Indicates success (0), failure (-1).
 *   errMessage  The error or warning message, if any.
 */
PROCEDURE process(parameters IN OUT NOCOPY MoveParam,
                  status        OUT NOCOPY NUMBER,
                  errMessage    OUT NOCOPY VARCHAR2) IS
  error VARCHAR2(241);                        -- error message
  moveRecord MoveTxnRec;                      -- move record for insertion
  l_returnStatus VARCHAR2(1);
  l_opSeq NUMBER;
  l_step NUMBER;
  l_mtlMode NUMBER;
  cmpParams wma_completion.CmpParams;
  l_params wip_logger.param_tbl_t;
  l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
BEGIN
  if (l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName := 'not printing params';
    l_params(1).paramValue := ' ';
    wip_logger.entryPoint(p_procName => 'wma_move.process',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  end if;

  status := 0;
  IF(parameters.txnType = WIP_CONSTANTS.COMP_TXN) THEN
    -- tell move processor not to process backflush components.
    -- The last processor should be the one who call Inventory TM.
    -- In this case it is Completion Processor.
    l_mtlMode := WIP_CONSTANTS.BACKGROUND;
  ELSE
    -- If Move or EZ Return, move processor should be the one who call
    -- inventory TM because it is the last processor.
    l_mtlMode := WIP_CONSTANTS.ONLINE;
  END IF;

  IF(parameters.txnMode = WIP_CONSTANTS.ONLINE AND
     parameters.txnType = WIP_CONSTANTS.RET_TXN) THEN
    -- create completionParams structure from moveParams
    cmpParams.environment := parameters.environment;
    cmpParams.transactionType := parameters.mtlTxnTypeID;
    cmpParams.transactionHeaderID := parameters.mtl_header_id;
    cmpParams.transactionIntID := parameters.mtlTxnIntID;
    cmpParams.cmpTransactionID := parameters.cmpTxnID;
    cmpParams.movTransactionID := parameters.txnID;
    cmpParams.wipEntityID := parameters.wipEntityID;
    cmpParams.wipEntityName := parameters.wipEntityName;
    cmpParams.itemID := parameters.itemID;
    cmpParams.itemName := parameters.itemName;
    cmpParams.transactionQty := parameters.transactionQty;
    cmpParams.transactionUOM := parameters.transactionUOM;
    cmpParams.subinv := parameters.subinv;
    cmpParams.locatorID := parameters.locatorID;
    cmpParams.locatorName := parameters.locatorName;
    cmpParams.kanbanCardID := parameters.kanbanID;
    cmpParams.qualityID := parameters.qualityID;
    cmpParams.projectID := parameters.projectID;
    cmpParams.taskID := parameters.taskID;
    cmpParams.isFromSerializedPage := parameters.isFromSerializedPage;
    -- call completion processor to process assy cpl
    wma_completion.process(parameters  => cmpParams,
                           processInv  => fnd_api.g_true,
                           status      => status,
                           errMessage  => errMessage);
    IF(status <> 0) THEN
      if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.process',
                               p_procReturnStatus => status,
                               p_msg => errMessage,
                               x_returnStatus => l_returnStatus);
      end if;
      return;
    END IF;
  END IF; -- Easy Return

  /********************* Start doing move ************************/
  -- first derive all necessary fields for insertion
  IF(derive(moveRecord => moveRecord,
            parameters => parameters,
            errMessage => error) = FALSE) THEN
    -- process error
    status := -1;
    errMessage := error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.process',
                           p_procReturnStatus => status,
                           p_msg => errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
    return;
  END IF;

  -- now, ready to insert into the interface table
  IF(put(moveRecord => moveRecord,
         errMessage => error) = FALSE ) THEN
    -- process error
    status := -1;
    errMessage := error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.process',
                           p_procReturnStatus => status,
                           p_msg => errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
    return;
  END IF;

  -- Only call the API's below for serial txns
  IF(parameters.isFromSerializedPage = WIP_CONSTANTS.YES) THEN
    -- serial txns, so need to insert record into WIP_SERIAL_MOVE_INTERFACE too
    IF(insertSerial(groupID       => moveRecord.row.group_id,
                    transactionID => moveRecord.row.transaction_id,
                    serialNumber  => parameters.serial,
                    errMessage    => error) = FALSE) THEN
      -- process error
      status := -1;
      errMessage := error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_move.process',
                             p_procReturnStatus => status,
                             p_msg => errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
      return;
    END IF;
  END IF; -- from serialized page

  -- If mobile transaction mode is online, call PL/SQL move_processor to
  -- process record in WMTI. Otherwise stop here, and let the move manager
  -- to pick the record
  IF(parameters.txnMode = WIP_CONSTANTS.ONLINE) THEN


    --move op pull txns to mmtt. This is already be done (and they would already be
    --processed) if the txn is an easy return.
    --note that for an easy cpl record, the assy l/s info is already written, but the
    --assy record in MTI does not exist. Thus the 'orphaned' l/s info in MSNI/MTLI will
    --remain there even after the validateInterfaceTxns() call until the assy record is
    --inserted and processed in the wma_completion.process() call further below
    IF(parameters.txnType <> WIP_CONSTANTS.RET_TXN) THEN
      wip_mtlTempProc_priv.validateInterfaceTxns(p_txnHdrID => parameters.mtl_header_id,
                                                 p_initMsgList => fnd_api.g_true,
                                                 x_returnStatus => l_returnStatus);
      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        /* Bug 5727205 : Commented out commit. No need to commit if validation fails.
        commit;     */
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    wip_movProc_priv.processIntf
                    (p_group_id      => parameters.txnID,
                     p_child_txn_id  => parameters.childTxnID,
                     p_mtl_header_id => parameters.mtl_header_id,
                     p_proc_phase    => WIP_CONSTANTS.MOVE_PROC,
                     p_time_out      => 0,
                     p_move_mode     => WIP_CONSTANTS.ONLINE,
                     p_bf_mode       => WIP_CONSTANTS.ONLINE,
                     p_mtl_mode      => l_mtlMode,
                     p_endDebug      => FND_API.G_TRUE,
                     p_initMsgList   => FND_API.G_TRUE,
                     p_insertAssy    => FND_API.G_FALSE,
                     p_do_backflush  => FND_API.G_FALSE,
                     x_returnStatus  => l_returnStatus);

    IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  ELSE -- Background transaction
    NULL;
  END IF;

  /********************* End doing move ************************/

  IF(parameters.txnMode = WIP_CONSTANTS.ONLINE AND
     parameters.txnType = WIP_CONSTANTS.COMP_TXN) THEN
    -- create completionParams structure from moveParams
    cmpParams.environment := parameters.environment;
    cmpParams.transactionType := parameters.mtlTxnTypeID;
    cmpParams.transactionHeaderID := parameters.mtl_header_id;
    cmpParams.transactionIntID := parameters.mtlTxnIntID;
    cmpParams.cmpTransactionID := parameters.cmpTxnID;
    cmpParams.movTransactionID := parameters.txnID;
    cmpParams.wipEntityID := parameters.wipEntityID;
    cmpParams.wipEntityName := parameters.wipEntityName;
    cmpParams.itemID := parameters.itemID;
    cmpParams.itemName := parameters.itemName;
    cmpParams.transactionQty := parameters.transactionQty;
    cmpParams.transactionUOM := parameters.transactionUOM;
    cmpParams.subinv := parameters.subinv;
    cmpParams.locatorID := parameters.locatorID;
    cmpParams.locatorName := parameters.locatorName;
    cmpParams.kanbanCardID := parameters.kanbanID;
    cmpParams.qualityID := parameters.qualityID;
    cmpParams.projectID := parameters.projectID;
    cmpParams.taskID := parameters.taskID;
    cmpParams.isFromSerializedPage := parameters.isFromSerializedPage;
    -- call completion processor to derive and insert assembly record
    -- into MMTT. And also call Inventory TM to process all records in MMTT.
    wma_completion.process(parameters  => cmpParams,
                           processInv  => fnd_api.g_true,
                           status      => status,
                           errMessage  => errMessage);
    IF(status <> 0) THEN
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_move.process',
                             p_procReturnStatus => status,
                             p_msg => errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
      return;
    END IF;
  END IF; -- Easy Complete

  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wma_move.process',
                         p_procReturnStatus => status,
                         p_msg => 'success',
                         x_returnStatus => l_returnStatus);
  end if;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    status := -1;
    wip_utilities.get_message_stack(p_msg => errMessage);
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.process',
                           p_procReturnStatus => status,
                           p_msg => errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
  WHEN others THEN
    status := -1;
    fnd_message.set_name ('WIP', 'GENERIC_ERROR');
    fnd_message.set_token ('FUNCTION', 'wma_move.process');
    fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
    errMessage := fnd_message.get;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.process',
                           p_procReturnStatus => status,
                           p_msg => errMessage,
                           x_returnStatus => l_returnStatus);
    end if;

END process;

/**
  * This procedure is a wrapper on top of wip_bflProc_priv.processRequirements
  * and wip_autoLotProc_priv.deriveLots. This procedure should be called to
  * check whether we need to gather more lot/serial info from the user or not
  */
PROCEDURE backflush(p_jobID         IN NUMBER,
                    p_orgID         IN        NUMBER,
                    p_childMoveID   IN        NUMBER,
                    p_moveID        IN        NUMBER,
                    p_ocQty         IN        NUMBER,
                    p_moveQty       IN        NUMBER,
                    p_txnDate       IN        DATE,
                    p_txnHdrID      IN        NUMBER,
                    p_fm_op         IN        NUMBER,
                    p_fm_step       IN        NUMBER,
                    p_to_op         IN        NUMBER,
                    p_to_step       IN        NUMBER,
                    p_cmpTxnID      IN        NUMBER,
                    p_txnType       IN        NUMBER,
                    p_objectID      IN        NUMBER,
                    x_lotEntryType OUT NOCOPY NUMBER,
                    x_compInfo     OUT NOCOPY system.wip_lot_serial_obj_t,
                    x_returnStatus OUT NOCOPY VARCHAR2,
                    x_errMessage   OUT NOCOPY VARCHAR2) IS

l_first_bf_op NUMBER := -1;
l_last_bf_op NUMBER := -1;
l_maxOpSeqNum NUMBER;
l_bf_qty NUMBER;
l_first_op NUMBER;
i NUMBER;
l_returnStatus VARCHAR(1);
l_compTbl system.wip_component_tbl_t;
l_params  wip_logger.param_tbl_t;
l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);

BEGIN
  if (l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName    := 'p_jobID';
    l_params(1).paramValue   :=  p_jobID;
    l_params(2).paramName    := 'p_orgID';
    l_params(2).paramValue   :=  p_orgID;
    l_params(3).paramName    := 'p_childMoveID';
    l_params(3).paramValue   :=  p_childMoveID;
    l_params(4).paramName    := 'p_moveID';
    l_params(4).paramValue   :=  p_moveID;
    l_params(5).paramName    := 'p_ocQty';
    l_params(5).paramValue   :=  p_ocQty;
    l_params(6).paramName    := 'p_moveQty';
    l_params(6).paramValue   :=  p_moveQty;
    l_params(7).paramName    := 'p_txnDate';
    l_params(7).paramValue   :=  p_txnDate;
    l_params(8).paramName    := 'p_txnHdrID';
    l_params(8).paramValue   :=  p_txnHdrID;
    l_params(9).paramName    := 'p_fm_op';
    l_params(9).paramValue   :=  p_fm_op;
    l_params(10).paramName   := 'p_fm_step';
    l_params(10).paramValue  :=  p_fm_step;
    l_params(11).paramName   := 'p_to_op';
    l_params(11).paramValue  :=  p_to_op;
    l_params(12).paramName   := 'p_to_step';
    l_params(12).paramValue  :=  p_to_step;
    l_params(13).paramName   := 'p_moveQty';
    l_params(13).paramValue  :=  p_moveQty;
    -- write parameter value to log file
    wip_logger.entryPoint(p_procName =>'wma_move.backflush',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  end if;

  SELECT backflush_lot_entry_type
    INTO x_lotEntryType
    FROM wip_parameters
   WHERE organization_id = p_orgID;

  l_compTbl := system.wip_component_tbl_t();

  IF(p_txnType = WIP_CONSTANTS.COMP_TXN OR
     p_txnType = WIP_CONSTANTS.RET_TXN) THEN -- Easy Complete/Return
    -- get the last operation to pass to backflush processor
    SELECT NVL(MAX(operation_seq_num), 1)
      INTO l_maxOpSeqNum
      FROM wip_operations
     WHERE wip_entity_id = p_jobID;

    IF(p_txnType = WIP_CONSTANTS.COMP_TXN) THEN
      l_bf_qty := p_moveQty;
    ELSIF(p_txnType = WIP_CONSTANTS.RET_TXN) THEN
      l_bf_qty := -1 * p_moveQty;
    END IF;
    -- call backflush processor to insert Assembly Pull components
    wip_bflProc_priv.processRequirements
                    (p_wipEntityID   => p_jobID,
                     p_wipEntityType => WIP_CONSTANTS.DISCRETE,
                     p_repSchedID    => null,
                     p_repLineID     => null,
                     p_cplTxnID      => p_cmpTxnID,
                     p_movTxnID      => null,
                     p_orgID         => p_orgID,
                     p_assyQty       => l_bf_qty,
                     p_txnDate       => p_txnDate,
                     p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
                     p_txnHdrID      => p_txnHdrID,
                     p_firstOp       => -1, -- for regular completion
                     p_lastOP        => l_maxOpSeqNum,
                     p_firstMoveOp   => null,
                     p_lastMoveOp    => null,
                     p_srcCode       => null,
                     p_mergeMode     => fnd_api.g_false,
                     p_initMsgList   => fnd_api.g_true,
                     p_endDebug      => fnd_api.g_false,
                     p_mtlTxnMode    => wip_constants.online,
                     x_compTbl       => l_compTbl,
                     x_returnStatus  => x_returnStatus);

    IF(x_returnStatus <>  fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;-- Easy Complete/Return

  -- Call bf_require to derive first_bf_op, last_bf_op, and bf_qty before
  -- call wip_bflProc_priv.processRequirements for Operation Pull components

  bf_require(p_jobID        => p_jobID,
             p_fm_op        => p_fm_op,
             p_fm_step      => p_fm_step,
             p_to_op        => p_to_op,
             p_to_step      => p_to_step,
             p_moveQty      => p_moveQty,
             x_first_bf_op  => l_first_bf_op,
             x_last_bf_op   => l_last_bf_op,
             x_bf_qty       => l_bf_qty,
             x_returnStatus => x_returnStatus,
             x_errMessage   => x_errMessage);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', x_errMessage);
    fnd_msg_pub.add;
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  IF(l_first_bf_op <> -1) THEN

    -- Call backflush processor to get operation pull components into l_compTbl
    wip_bflProc_priv.processRequirements
                    (p_wipEntityID   => p_jobID,
                     p_wipEntityType => WIP_CONSTANTS.DISCRETE,
                     p_repSchedID    => null,
                     p_repLineID     => null,
                     p_cplTxnID      => null,
                     p_movTxnID      => p_moveID,
                     p_orgID         => p_orgID,
                     p_assyQty       => l_bf_qty,
                     p_txnDate       => p_txnDate,
                     p_wipSupplyType => WIP_CONSTANTS.OP_PULL,
                     p_txnHdrID      => p_txnHdrID,
                     p_firstOp       => l_first_bf_op,
                     p_lastOP        => l_last_bf_op,
                     p_firstMoveOp   => p_fm_op, -- use to check autocharge
                     p_lastMoveOp    => p_to_op, -- use to check autocharge
                     p_srcCode       => null,
                     p_mergeMode     => fnd_api.g_false,
                     p_initMsgList   => fnd_api.g_true,
                     p_endDebug      => fnd_api.g_false,
                     p_mtlTxnMode    => wip_constants.online,
                     x_compTbl       => l_compTbl,
                     x_returnStatus  => x_returnStatus);

    IF(x_returnStatus <>  fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF; -- l_first_bf_op <> -1

  -- Call assy_pull_bf to derive first_bf_op, last_bf_op, and bf_qty before
  -- call wip_bflProc_priv.processRequirements for Assembly Pull components
  -- This is only for Scrap Transactions

  -- set l_first_bf_op and l_last_bf_op back to -1
  l_first_bf_op := -1;
  l_last_bf_op  := -1;

  assy_pull_bf(p_jobID        => p_jobID,
               p_fm_op        => p_fm_op,
               p_fm_step      => p_fm_step,
               p_to_op        => p_to_op,
               p_to_step      => p_to_step,
               p_moveQty      => p_moveQty,
               x_first_bf_op  => l_first_bf_op,
               x_last_bf_op   => l_last_bf_op,
               x_bf_qty       => l_bf_qty,
               x_returnStatus => x_returnStatus,
               x_errMessage   => x_errMessage);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', x_errMessage);
    fnd_msg_pub.add;
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  IF(l_first_bf_op <> -1) THEN

    -- Call backflush processor to get assembly pull components into l_compTbl
    -- for scrap transactions
    wip_bflProc_priv.processRequirements
                    (p_wipEntityID   => p_jobID,
                     p_wipEntityType => WIP_CONSTANTS.DISCRETE,
                     p_repSchedID    => null,
                     p_repLineID     => null,
                     p_cplTxnID      => null,
                     p_movTxnID      => p_moveID,
                     p_orgID         => p_orgID,
                     p_assyQty       => l_bf_qty,
                     p_txnDate       => p_txnDate,
                     p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
                     p_txnHdrID      => p_txnHdrID,
                     p_firstOp       => l_first_bf_op,
                     p_lastOP        => l_last_bf_op,
                     p_firstMoveOp   => p_fm_op, -- use to check autocharge
                     p_lastMoveOp    => p_to_op, -- use to check autocharge
                     p_srcCode       => null,
                     p_mergeMode     => fnd_api.g_false,
                     p_initMsgList   => fnd_api.g_true,
                     p_endDebug      => fnd_api.g_false,
                     p_mtlTxnMode    => wip_constants.online,
                     x_compTbl       => l_compTbl,
                     x_returnStatus  => x_returnStatus);

    IF(x_returnStatus <>  fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF; -- l_first_bf_op <> -1

  IF(p_childMoveID <> -1) THEN

    -- Over move transaction, so need to check backflush components for
    -- child record too.
    l_first_bf_op := -1;
    l_last_bf_op  := -1;
    l_bf_qty      := 0;
    SELECT MIN(operation_seq_num)
      INTO l_first_op
      FROM wip_operations
     WHERE wip_entity_id = p_jobID;

    bf_require(p_jobID        => p_jobID,
               p_fm_op        => l_first_op,
               p_fm_step      => WIP_CONSTANTS.QUEUE,
               p_to_op        => p_fm_op,
               p_to_step      => p_fm_step,
               p_moveQty      => p_ocQty,
               x_first_bf_op  => l_first_bf_op,
               x_last_bf_op   => l_last_bf_op,
               x_bf_qty       => l_bf_qty,
               x_returnStatus => x_returnStatus,
               x_errMessage   => x_errMessage);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', x_errMessage);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    IF(l_first_bf_op <> -1) THEN

      /* Call backflush processor to get component into l_compTbl*/
      wip_bflProc_priv.processRequirements
                      (p_wipEntityID   => p_jobID,
                       p_wipEntityType => WIP_CONSTANTS.DISCRETE,
                       p_repSchedID    => null,
                       p_repLineID     => null,
                       p_cplTxnID      => null,
                       p_movTxnID      => p_childMoveID,
                       p_orgID         => p_orgID,
                       p_assyQty       => l_bf_qty,
                       p_txnDate       => p_txnDate,
                       p_wipSupplyType => WIP_CONSTANTS.OP_PULL,
                       p_txnHdrID      => p_txnHdrID,
                       p_firstOp       => l_first_bf_op,
                       p_lastOP        => l_last_bf_op,
                       p_firstMoveOp   => p_fm_op, -- use to check autocharge
                       p_lastMoveOp    => p_to_op, -- use to check autocharge
                       p_srcCode       => null,
                       p_mergeMode     => fnd_api.g_false,
                       p_initMsgList   => fnd_api.g_true,
                       p_endDebug      => fnd_api.g_false,
                       p_mtlTxnMode    => wip_constants.online,
                       x_compTbl       => l_compTbl,
                       x_returnStatus  => x_returnStatus);

      IF(x_returnStatus <>  fnd_api.g_ret_sts_success) THEN
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- end l_first_bf_op <> -1

    -- Call assy_pull_bf to derive first_bf_op, last_bf_op, and bf_qty before
    -- call wip_bflProc_priv.processRequirements for Assembly Pull components
    -- This is only for Scrap Transactions

    -- set l_first_bf_op and l_last_bf_op back to -1
    l_first_bf_op := -1;
    l_last_bf_op  := -1;

    assy_pull_bf(p_jobID        => p_jobID,
                 p_fm_op        => l_first_op,
                 p_fm_step      => WIP_CONSTANTS.QUEUE,
                 p_to_op        => p_fm_op,
                 p_to_step      => p_fm_step,
                 p_moveQty      => p_ocQty,
                 x_first_bf_op  => l_first_bf_op,
                 x_last_bf_op   => l_last_bf_op,
                 x_bf_qty       => l_bf_qty,
                 x_returnStatus => x_returnStatus,
                 x_errMessage   => x_errMessage);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', x_errMessage);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    IF(l_first_bf_op <> -1) THEN

      -- Call backflush processor to get assembly pull components into
      -- l_compTbl for scrap transactions
      wip_bflProc_priv.processRequirements
                      (p_wipEntityID   => p_jobID,
                       p_wipEntityType => WIP_CONSTANTS.DISCRETE,
                       p_repSchedID    => null,
                       p_repLineID     => null,
                       p_cplTxnID      => null,
                       p_movTxnID      => p_childMoveID,
                       p_orgID         => p_orgID,
                       p_assyQty       => l_bf_qty,
                       p_txnDate       => p_txnDate,
                       p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
                       p_txnHdrID      => p_txnHdrID,
                       p_firstOp       => l_first_bf_op,
                       p_lastOP        => l_last_bf_op,
                       p_firstMoveOp   => p_fm_op, -- use to check autocharge
                       p_lastMoveOp    => p_to_op, -- use to check autocharge
                       p_srcCode       => null,
                       p_mergeMode     => fnd_api.g_false,
                       p_initMsgList   => fnd_api.g_true,
                       p_endDebug      => fnd_api.g_false,
                       p_mtlTxnMode    => wip_constants.online,
                       x_compTbl       => l_compTbl,
                       x_returnStatus  => x_returnStatus);

      IF(x_returnStatus <>  fnd_api.g_ret_sts_success) THEN
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- l_first_bf_op <> -1

  END IF; -- end over move transaction
  if (l_logLevel <= wip_constants.full_logging) then
    wip_logger.log(p_msg          => 'before system.wip_lot_serial_obj_t',
                   x_returnStatus => l_returnStatus);
  end if;
  x_compInfo := system.wip_lot_serial_obj_t(null, null, null, l_compTbl,
                                            null, null);
  if (l_logLevel <= wip_constants.full_logging) then
    wip_logger.log(p_msg          => 'after system.wip_lot_serial_obj_t',
                   x_returnStatus => l_returnStatus);
  end if;
  x_compInfo.initialize;
  if (l_logLevel <= wip_constants.full_logging) then
    wip_logger.log(p_msg          => 'after x_compInfo.initialize',
                   x_returnStatus => l_returnStatus);
  end if;
  -- derive lot if the component under lot control, if return status
  -- is 'E' mean cannot derive lot, so the user need to provide more
  -- info if move_mode is online. For background, error out if cannot
  -- derive lot.
  wip_autoLotProc_priv.deriveLots(
    x_compLots      => x_compInfo,
    p_orgID         => p_orgID,
    p_wipEntityID   => p_jobID,
    p_initMsgList   => fnd_api.g_true,
    p_endDebug      => fnd_api.g_false,
    p_destroyTrees  => fnd_api.g_true,
    p_treeMode      => inv_quantity_tree_pvt.g_reservation_mode,
    p_treeSrcName   => null,
    x_returnStatus  => x_returnStatus);

  if (l_logLevel <= wip_constants.full_logging) then
    wip_logger.log(p_msg          => 'after wip_autoLotProc_priv.deriveLots',
                   x_returnStatus => l_returnStatus);
  end if;
  IF(x_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  -- derive serial for serialized transaction. We can just check p_objectID.
  -- If p_objectID is -1, don't need to call deriveSerial. Otherwise call
  -- the API below.
  IF(p_objectID <> -1) THEN
    wip_autoSerialProc_priv.deriveSerial(x_compLots      => x_compInfo,
                                         p_orgID         => p_orgID,
                                         p_objectID      => p_objectID,
                                         p_initMsgList   => fnd_api.g_true,
                                         x_returnStatus  => x_returnStatus);

    IF(x_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_success;
  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wma_move.backflush',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  end if;
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    x_errMessage := fnd_msg_pub.get(p_encoded => 'F');
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.backflush',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    x_errMessage := 'unexpected error: ' || SQLERRM;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.backflush',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
END backflush;

/**
 * This function derives and validates the values necessary for executing
 * the move transaction. Given the form parameters, it populates
 * moveRecord preparing it to be inserted into the interface table.
 * This is the most important procedure for move background transaction
 * Parameters:
 *   moveRecord record to be populated. The minimum number of fields to
 *              execute the move transaction successfully are populated
 *   parameters move mobile form parameters
 *   errMessage populated if an error occurrs
 * Return:
 *   boolean    flag indicating the successful derivation of necessary values
 */
Function derive(moveRecord IN OUT NOCOPY MoveTxnRec,
                parameters     IN        MoveParam,
                errMessage IN OUT NOCOPY VARCHAR2)
return boolean IS
  job wma_common.Job;
  item wma_common.Item;
  periodID number;
  fmOpCode varchar2(5);
  fmDeptID number;
  fmDeptCode varchar2(11);
  fmPrevOpSeq number;
  fmNextOpSeq number;
  fmOpExists boolean;
  toOpCode varchar2(5);
  toDeptID number;
  toDeptCode varchar2(11);
  toPrevOpSeq number;
  toNextOpSeq number;
  toOpExists boolean;
  openPastPeriod boolean := false;
  txnMode NUMBER;
  l_returnStatus VARCHAR(1);
  l_revision VARCHAR2(3);
  l_logLevel NUMBER := fnd_log.g_current_runtime_level;
BEGIN

  -- derive info about the job
  job := wma_derive.getJob(parameters.wipEntityID);

  if (job.wipEntityID is null) then
      fnd_message.set_name ('WIP', 'WIP_JOB_DOES_NOT_EXIST');
      fnd_message.set_token('INTERFACE', 'wma_move.derive', TRUE);
      errMessage := fnd_message.get;
      return false;
  end if;

  if(parameters.txnMode = WIP_CONSTANTS.BACKGROUND AND
     (parameters.txnType = WIP_CONSTANTS.RET_TXN OR
      parameters.txnType = WIP_CONSTANTS.COMP_TXN)) then
    -- Only check revision for background transaction because we skip
    -- validation code if mobile insert record into WMTI. For online txns
    -- wma_completion.derive will validate the revision before insert into MMTT

    -- get the item info
    item := wma_derive.getItem(parameters.itemID,
                               parameters.environment.orgID,
                               parameters.locatorID);
    if (item.invItemID is null) then
      fnd_message.set_name ('WIP', 'WIP_ITEM_DOES_NOT_EXIST');
      errMessage := fnd_message.get;
      return false;
    end if;

    -- get the item revision
    if (item.revQtyControlCode = WIP_CONSTANTS.REVISION_CONTROLLED) then
      if(NOT wma_completion.getRevision(
                            wipEntityID => parameters.wipEntityID,
                            orgID       => parameters.environment.orgID,
                            itemID      => parameters.itemID,
                            revision    => l_revision)) then
        errMessage := substr(fnd_message.get,1,241);
        return false;
      end if; -- getRevision
    end if; -- revQtyControlCode = WIP_CONSTANTS.REVISION_CONTROLLED
  end if; -- Background transaction

  -- derive the accounting period stuff by calling inv routine
  invttmtx.tdatechk(
    org_id           => parameters.environment.orgID,
    transaction_date => sysdate,
    period_id        => periodID,
    open_past_period => openPastPeriod);

   if (periodID = -1 or periodID = 0) then
      fnd_message.set_name(
        application => 'INV',
        name        => 'INV_NO_OPEN_PERIOD');
      errMessage := fnd_message.get;
      return false;
    end if;

  -- derive the operation related information based on sequence number (From)
  wip_operations_info.derive_info(
    p_org_id => parameters.environment.orgID,
    p_wip_entity_id => parameters.wipEntityID,
    p_first_schedule_id => null,
    p_operation_seq_num => parameters.fmOpSeqNum,
    p_operation_code => fmOpCode,
    p_department_id => fmDeptID,
    p_department_code => fmDeptCode,
    p_prev_op_seq_num => fmPrevOpSeq,
    p_next_op_seq_num => fmNextOpSeq,
    p_operation_exists => fmOpExists);

  -- derive the operation related information based on sequence number (To)
  wip_operations_info.derive_info(
    p_org_id => parameters.environment.orgID,
    p_wip_entity_id => parameters.wipEntityID,
    p_first_schedule_id => null,
    p_operation_seq_num => parameters.toOpSeqNum,
    p_operation_code => toOpCode,
    p_department_id => toDeptID,
    p_department_code => toDeptCode,
    p_prev_op_seq_num => toPrevOpSeq,
    p_next_op_seq_num => toNextOpSeq,
    p_operation_exists => toOpExists);

  -- now derive the rest of the mandatory fields in the MoveTxnRec
  IF(parameters.txnID = NULL) THEN
    IF (l_logLevel <= wip_constants.full_logging) THEN
      wip_logger.log(p_msg          => 'before wma_derive.getNextVal',
                     x_returnStatus => l_returnStatus);
    END IF;
    moveRecord.row.transaction_id := wma_derive.getNextVal
                                     ('wip_transactions_s');
    IF (l_logLevel <= wip_constants.full_logging) THEN
      wip_logger.log(p_msg          => 'after wma_derive.getNextVal',
                     x_returnStatus => l_returnStatus);
    END IF;
  ELSE
    moveRecord.row.transaction_id := parameters.txnID;
  END IF;

  IF(parameters.txnMode = WIP_CONSTANTS.ONLINE) THEN
    moveRecord.row.process_status := WIP_CONSTANTS.RUNNING;
    moveRecord.row.group_id := moveRecord.row.transaction_id;
  ELSE -- background
    moveRecord.row.process_status := WIP_CONSTANTS.PENDING;
    moveRecord.row.group_id := NULL;
  END IF;
  moveRecord.row.last_update_date := sysdate;
  moveRecord.row.last_updated_by := parameters.environment.userID;
  moveRecord.row.last_updated_by_name := parameters.environment.userName;
  moveRecord.row.creation_date := sysdate;
  moveRecord.row.created_by := parameters.environment.userID;
  moveRecord.row.created_by_name := parameters.environment.userName;
  moveRecord.row.process_phase := WIP_CONSTANTS.MOVE_PROC;

  moveRecord.row.transaction_type := parameters.txnType;
  moveRecord.row.organization_id := parameters.environment.orgID;
  moveRecord.row.organization_code := parameters.environment.orgCode;
  moveRecord.row.wip_entity_id := parameters.wipEntityID;
  moveRecord.row.wip_entity_name := parameters.wipEntityName;
  moveRecord.row.entity_type := WIP_CONSTANTS.DISCRETE;  --only support discrete now
  moveRecord.row.primary_item_id := parameters.itemID;
  moveRecord.row.line_id := job.lineID;
  moveRecord.row.line_code := job.lineCode;
  moveRecord.row.transaction_date := sysdate;
  moveRecord.row.acct_period_id := periodID;
  moveRecord.row.fm_operation_seq_num := parameters.fmOpSeqNum;
  moveRecord.row.fm_operation_code := fmOpCode;
  moveRecord.row.fm_department_id := fmDeptID;
  moveRecord.row.fm_department_code := fmDeptCode;
  moveRecord.row.fm_intraoperation_step_type := parameters.fmStepType;
  moveRecord.row.to_operation_seq_num := parameters.toOpSeqNum;
  moveRecord.row.to_operation_code := toOpCode;
  moveRecord.row.to_department_id := toDeptID;
  moveRecord.row.to_department_code := toDeptCode;
  moveRecord.row.to_intraoperation_step_type := parameters.toStepType;
  moveRecord.row.transaction_quantity := parameters.transactionQty;
  moveRecord.row.transaction_uom := parameters.transactionUOM;
  moveRecord.row.primary_quantity := parameters.transactionQty;
  moveRecord.row.primary_uom := parameters.transactionUOM;
  moveRecord.row.scrap_account_id := parameters.scrapAcctID;
  moveRecord.row.reason_id := parameters.reasonID;
  moveRecord.row.qa_collection_id := parameters.qualityID;
  moveRecord.row.overcompletion_transaction_qty := parameters.overcompleteQty;
  moveRecord.row.overcompletion_primary_qty := parameters.overcompleteQty;
  -- insert different source_code for serialized transactions
  IF(parameters.isFromSerializedPage = WIP_CONSTANTS.YES) THEN
    moveRecord.row.source_code := WMA_COMMON.SERIALIZATION_SOURCE_CODE;
  ELSE
    moveRecord.row.source_code := WMA_COMMON.SOURCE_CODE;
  END IF;
  -- successful, return
  return true;

EXCEPTION
  when others then
    fnd_message.set_name ('WIP', 'GENERIC_ERROR');
    fnd_message.set_token ('FUNCTION', 'wma_move.derive');
    fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
    errMessage := fnd_message.get;
    return false;
END derive;

 /**
  * This function is only use for scrap transaction. It takes fm_op, fm_step,
  * to_op, to_step and check which operation that we need to issue/return
  * assembly pull components to/from inventory. If the transaction is not
  * scrap txn, this routine will not set anything.
  * This function will return the first_operation, last_operation,
  *  and backflush quantity that the user can pass to
  * wip_bflProc_priv.processRequirements. The caller should check the
  * original value of x_first_bf_op and compare with the one
  * that this procedure return. If it is the same value, it mean no backflush
  * require because this routine will only set the value when backflush is
  * require.
  *
  * NOTE:
  * This routine only concern abot Assembly Pull components for scrap txns.
  * For Operation Pull component, please use bf_require procedure instead.
  */

PROCEDURE assy_pull_bf(p_jobID         IN        NUMBER,
                       p_fm_op         IN        NUMBER,
                       p_fm_step       IN        NUMBER,
                       p_to_op         IN        NUMBER,
                       p_to_step       IN        NUMBER,
                       p_moveQty       IN        NUMBER,
                       x_first_bf_op  OUT NOCOPY NUMBER,
                       x_last_bf_op   OUT NOCOPY NUMBER,
                       x_bf_qty       OUT NOCOPY NUMBER,
                       x_returnStatus OUT NOCOPY VARCHAR2,
                       x_errMessage   OUT NOCOPY VARCHAR2) IS

CURSOR c_last_bf_op IS

  SELECT p_moveQty *
           DECODE(
             SIGN(p_to_step - WIP_CONSTANTS.SCRAP),
             0, DECODE(SIGN(p_fm_step - WIP_CONSTANTS.SCRAP),
                  0, DECODE(SIGN(p_to_op - p_fm_op),
                       1,1,
                      -1,-1),
                 -1, 1),
            -1, DECODE(SIGN(p_fm_step - WIP_CONSTANTS.SCRAP),
                  0, -1)) txn_qty,
         MAX(wop.operation_seq_num) last_op
    FROM wip_operations wop
   WHERE wop.wip_entity_id = p_jobID
     AND ((wop.operation_seq_num = p_fm_op AND
           p_fm_step = WIP_CONSTANTS.SCRAP)
          OR
          (wop.operation_seq_num = p_to_op AND
           p_to_step = WIP_CONSTANTS.SCRAP)
         );

CURSOR c_first_bf_op IS

  SELECT MIN(wop.operation_seq_num) first_op
    FROM wip_operations wop
   WHERE wop.wip_entity_id = p_jobID
     AND wop.operation_seq_num >
         DECODE(SIGN(p_fm_step - WIP_CONSTANTS.SCRAP),
           0, DECODE(SIGN(p_to_step - WIP_CONSTANTS.SCRAP),
                0, DECODE(SIGN(p_to_op - p_fm_op),
                     1, p_fm_op,
                     p_to_op),
                0),
           0);

l_last_bf_op c_last_bf_op%ROWTYPE;
l_params  wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_first_op NUMBER;
l_logLevel NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  if (l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName   := 'p_jobID';
    l_params(1).paramValue  :=  p_jobID;
    l_params(2).paramName   := 'p_fm_op';
    l_params(2).paramValue  :=  p_fm_op;
    l_params(3).paramName   := 'p_fm_step';
    l_params(3).paramValue  :=  p_fm_step;
    l_params(4).paramName   := 'p_to_op';
    l_params(4).paramValue  :=  p_to_op;
    l_params(5).paramName   := 'p_to_step';
    l_params(5).paramValue  :=  p_to_step;
    l_params(6).paramName   := 'p_moveQty';
    l_params(6).paramValue  :=  p_moveQty;
    -- write parameter value to log file
    wip_logger.entryPoint(p_procName =>'wma_move.assy_pull_bf',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  end if;

  OPEN c_last_bf_op;
  LOOP
    FETCH c_last_bf_op INTO l_last_bf_op;
    EXIT WHEN  c_last_bf_op%NOTFOUND;
    IF(l_last_bf_op.last_op IS NOT NULL) THEN
      -- get the first backflush operation
      OPEN c_first_bf_op;
      LOOP
        FETCH c_first_bf_op INTO l_first_op;
        EXIT WHEN c_first_bf_op%NOTFOUND;
      END LOOP;

      -- return operation pull backflush info to the caller
      x_first_bf_op := l_first_op;
      x_last_bf_op  := l_last_bf_op.last_op;
      x_bf_qty      := l_last_bf_op.txn_qty;
    END IF;
  END LOOP;

  -- if cannot find last_bf_op mean, no backflush required for this move txn
  -- we don't need to set anything

  x_returnStatus := fnd_api.g_ret_sts_success;
  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wma_move.assy_pull_bf',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  end if;

  IF(c_last_bf_op%ISOPEN) THEN
    CLOSE c_last_bf_op;
  END IF;
  IF(c_first_bf_op%ISOPEN) THEN
    CLOSE c_first_bf_op;
  END IF;

EXCEPTION
  WHEN others THEN
    IF(c_last_bf_op%ISOPEN) THEN
      CLOSE c_last_bf_op;
    END IF;
    IF(c_first_bf_op%ISOPEN) THEN
      CLOSE c_first_bf_op;
    END IF;
    x_errMessage := 'unexpected error: ' || SQLERRM;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.assy_pull_bf',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;

END assy_pull_bf;

 /**
  * This function take fm_op, fm_step, to_op, to_step and check whether do we
  * need to call backflush or not. If backflush required, this function will
  * return the first_operation, last_operation, and backflush quantity that
  * the user can pass to wip_bflProc_priv.processRequirements. The caller
  * should check the original value of x_first_bf_op and compare with the one
  * that this procedure return. If it is the same value, it mean no backflush
  * require because this routine will only set the value when backflush is
  * require. If the x_bf_qty is positive, it is component issue transaction.
  * Otherwise, it is component return transaction.
  *
  * NOTE:
  * This routine support for both regulare move and scrap transaction. However,
  * this routine only concern abot Operation Pull components. For scrap txns
  * we need to backflush Assembly Pull components too. Please read assy_pull_bf
  * procedure for more info
  */

PROCEDURE bf_require(p_jobID         IN        NUMBER,
                     p_fm_op         IN        NUMBER,
                     p_fm_step       IN        NUMBER,
                     p_to_op         IN        NUMBER,
                     p_to_step       IN        NUMBER,
                     p_moveQty       IN        NUMBER,
                     x_first_bf_op  OUT NOCOPY NUMBER,
                     x_last_bf_op   OUT NOCOPY NUMBER,
                     x_bf_qty       OUT NOCOPY NUMBER,
                     x_returnStatus OUT NOCOPY VARCHAR2,
                     x_errMessage   OUT NOCOPY VARCHAR2) IS

CURSOR c_last_bf_op IS

    SELECT p_moveQty *
               DECODE(
                 SIGN(p_to_op - p_fm_op),
                 0, DECODE(SIGN(p_to_step - p_fm_step),
                    1, 1,
                    -1),
                 1, 1,
                -1,-1) txn_qty,
           MAX(wop.operation_seq_num) last_op
      FROM wip_operations wop
     WHERE wop.wip_entity_id = p_jobID
       AND DECODE(SIGN(DECODE(SIGN(p_to_op - p_fm_op),
                    -1, p_fm_step,
                     1, p_to_step,
                     0, DECODE(SIGN(p_to_step - p_fm_step),
                          1, p_to_step,
                          p_fm_step))
                        - WIP_CONSTANTS.RUN),
             1, DECODE(SIGN(p_to_op - p_fm_op), -1, p_fm_op, p_to_op)
                + 0.0000001,
             DECODE(SIGN(p_to_op - p_fm_op), -1, p_fm_op, p_to_op))
           >  wop.operation_seq_num
       AND wop.operation_seq_num >= DECODE(SIGN(p_to_op - p_fm_op),
                                     -1, p_to_op,
                                      p_fm_op)
       AND (wop.backflush_flag = WIP_CONSTANTS.YES
            OR
           (wop.operation_seq_num = p_fm_op AND
            p_fm_step = WIP_CONSTANTS.SCRAP)
            OR
           (wop.operation_seq_num = p_to_op AND
            p_to_step = WIP_CONSTANTS.SCRAP));

CURSOR c_first_bf_op IS

   SELECT MIN(wop.operation_seq_num) first_op
     FROM wip_operations wop
    WHERE wop.wip_entity_id = p_jobID
      AND wop.operation_seq_num >
              (SELECT NVL(MAX(wop1.operation_seq_num), 0)
                 FROM wip_operations wop1
                WHERE wop1.wip_entity_id = p_jobID
                  AND DECODE(SIGN(DECODE(SIGN(p_to_op - p_fm_op),
                              -1, p_to_step,
                               1, p_fm_step,
                               0, DECODE(SIGN(p_to_step - p_fm_step),
                                    1, p_fm_step,
                                    p_to_step))
                      - WIP_CONSTANTS.RUN),
                        1, DECODE(SIGN(p_to_op - p_fm_op), -1,p_to_op, p_fm_op)
                             + 0.0000001,
                        DECODE(SIGN(p_to_op - p_fm_op), -1, p_to_op,p_fm_op))
                      > wop1.operation_seq_num
                  AND (wop1.backflush_flag = WIP_CONSTANTS.YES
                       OR
                      (p_to_op > p_fm_op AND
                       wop1.operation_seq_num = p_fm_op AND
                       p_fm_step = WIP_CONSTANTS.SCRAP)
                       OR
                      (p_to_op < p_fm_op AND
                       wop1.operation_seq_num = p_to_op AND
                       p_to_step = WIP_CONSTANTS.SCRAP)));

CURSOR c_scrap_comp IS

   SELECT MIN(wop.operation_seq_num) first_op,
          p_to_op last_op,
          p_moveQty txn_qty
     FROM wip_operations wop
    WHERE wop.wip_entity_id = p_jobID
      AND wop.operation_seq_num >
              (SELECT NVL(MAX(wop1.operation_seq_num),0)
                 FROM wip_operations wop1
                WHERE wop1.wip_entity_id = p_jobID
                  AND p_fm_op > p_to_op
                  AND p_to_step = WIP_CONSTANTS.SCRAP
                  AND p_to_op  >= wop1.operation_seq_num
                  AND (wop1.backflush_flag = WIP_CONSTANTS.YES));

l_last_bf_op c_last_bf_op%ROWTYPE;
l_scrap_comp c_scrap_comp%ROWTYPE;
l_params  wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_first_op NUMBER;
l_logLevel NUMBER := fnd_log.g_current_runtime_level;

BEGIN
  l_params(1).paramName   := 'p_jobID';
  l_params(1).paramValue  :=  p_jobID;
  l_params(2).paramName   := 'p_fm_op';
  l_params(2).paramValue  :=  p_fm_op;
  l_params(3).paramName   := 'p_fm_step';
  l_params(3).paramValue  :=  p_fm_step;
  l_params(4).paramName   := 'p_to_op';
  l_params(4).paramValue  :=  p_to_op;
  l_params(5).paramName   := 'p_to_step';
  l_params(5).paramValue  :=  p_to_step;
  l_params(6).paramName   := 'p_moveQty';
  l_params(6).paramValue  :=  p_moveQty;

  -- write parameter value to log file
  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.entryPoint(p_procName =>'wma_move.bf_require',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  end if;

  OPEN c_last_bf_op;
  LOOP
    FETCH c_last_bf_op INTO l_last_bf_op;
    EXIT WHEN  c_last_bf_op%NOTFOUND;

    -- get the first backflush operation
    OPEN c_first_bf_op;
    LOOP
      FETCH c_first_bf_op INTO l_first_op;
      EXIT WHEN c_first_bf_op%NOTFOUND;
    END LOOP;

    IF(l_last_bf_op.last_op >= l_first_op) THEN
      -- return operation pull backflush info to the caller
      x_first_bf_op := l_first_op;
      x_last_bf_op  := l_last_bf_op.last_op;
      x_bf_qty      := l_last_bf_op.txn_qty;
    ELSE
      -- only do this for backward move to scrap transactions. We need to issue
      -- all operation pull component upto scrap operations.
      IF(p_to_op <> p_fm_op AND p_to_step = WIP_CONSTANTS.SCRAP) THEN
        OPEN c_scrap_comp;
        LOOP
          FETCH c_scrap_comp INTO l_scrap_comp;
          EXIT WHEN c_scrap_comp%NOTFOUND;
          IF(l_scrap_comp.last_op >= l_scrap_comp.first_op) THEN
            -- return operation pull backflush info to the caller
            x_first_bf_op := l_scrap_comp.first_op;
            x_last_bf_op  := l_scrap_comp.last_op;
            x_bf_qty      := l_scrap_comp.txn_qty;
          END IF;
        END LOOP;
      END IF; -- to_op <> fm_op
    END IF; -- l_last_bf_op.last_op >= first_op
  END LOOP;

  -- if cannot find last_bf_op mean, no backflush required for this move txn
  -- we don't need to set anything

  x_returnStatus := fnd_api.g_ret_sts_success;
  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wma_move.bf_require',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
  end if;

  IF(c_last_bf_op%ISOPEN) THEN
    CLOSE c_last_bf_op;
  END IF;
  IF(c_first_bf_op%ISOPEN) THEN
    CLOSE c_first_bf_op;
  END IF;
  IF(c_scrap_comp%ISOPEN) THEN
    CLOSE c_scrap_comp;
  END IF;

EXCEPTION
  WHEN others THEN
    IF(c_last_bf_op%ISOPEN) THEN
      CLOSE c_last_bf_op;
    END IF;
    IF(c_first_bf_op%ISOPEN) THEN
      CLOSE c_first_bf_op;
    END IF;
    IF(c_scrap_comp%ISOPEN) THEN
      CLOSE c_scrap_comp;
    END IF;
    x_errMessage := 'unexpected error: ' || SQLERRM;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.bf_require',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
END bf_require;

/**
 * This procedure validates the quantity entered by the user.  The transaction
 * quantity should be validated against the from operation sequence, from
 * intraoperation step type.  In the case of overcompletion, the tolerence
 * level is checked.
 * Check shop floor status between fromOp and toOp, also need to validate
 * OSP related information
 */
PROCEDURE validate(p_userID        IN        NUMBER,
                   p_orgID         IN        NUMBER,
                   p_jobID         IN        NUMBER,
                   p_fmOp          IN        NUMBER,
                   p_fmStep        IN        NUMBER,
                   p_toOp          IN        NUMBER,
                   p_toStep        IN        NUMBER,
                   p_overcomplQty  IN        NUMBER,
                   x_returnStatus OUT NOCOPY VARCHAR2,
                   x_errMessage   OUT NOCOPY VARCHAR2) IS

  result NUMBER;
  message varchar2(80);
  l_returnStatus VARCHAR(1);
  l_params wip_logger.param_tbl_t;
  l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  -- Fixed bug 5252677
  l_noMoveCount NUMBER;
BEGIN
  if (l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName := 'not printing params';
    l_params(1).paramValue := ' ';
    wip_logger.entryPoint(p_procName => 'wma_move.validate',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  end if;

  -- check overcompletion tolerence if overcompletion
  IF (p_overcomplQty <> 0) THEN
    wip_overcompletion.check_tolerance(
      p_organization_id => p_orgID,
      p_wip_entity_id => p_jobID,
      p_primary_quantity => p_overcomplQty,
      p_result => result);

    IF (result = WIP_CONSTANTS.NO) THEN
      -- exceed tolerance, set error message
      fnd_message.set_name ('WIP', 'WIP_OC_TOLERANCE_FAIL');
      x_errMessage := fnd_message.get;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_move.validate',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => x_errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
      return;
    END IF;
  END IF;

  -- Fixed bug 5252677. Check no move shopfloor status at from step.
  SELECT count(*)
    INTO l_noMoveCount
    FROM wip_shop_floor_status_codes wsc,
         wip_shop_floor_statuses ws
   WHERE wsc.organization_id = p_orgID
     AND ws.organization_id = wsc.organization_id
     AND ws.wip_entity_id = p_jobID
     AND ws.operation_seq_num = p_fmOp
     AND ws.intraoperation_step_type = p_fmStep
     AND ws.shop_floor_status_code = wsc.shop_floor_status_code
     AND wsc.status_move_flag = WIP_CONSTANTS.NO
     AND NVL(wsc.disable_date, SYSDATE + 1) > SYSDATE;

  IF(l_noMoveCount <> 0)THEN
    -- From step has no move shopfloor status
    fnd_message.set_name ('WIP', 'WIP_STATUS_NO_TXN1');
    x_errMessage := fnd_message.get;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.validate',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
    return;
  END IF; -- l_noMoveCount <> 0
  -- End fix for bug 5252677.

  -- check and make sure no shop floor statuses between the from and to
  IF (wip_sf_status.count_no_move_statuses(
        p_org_id   => p_orgID,
        p_wip_id   => p_jobID,
        p_line_id  => null,
        p_sched_id => null,
        p_fm_op    => p_fmOp,
        p_fm_step  => p_fmStep,
        p_to_op    => p_toOp,
        p_to_step  => p_toStep) > 0) THEN
    -- There is no-move shop floor status in between
    fnd_message.set_name ('WIP', 'WIP_NO_MOVE_SF_STATUS_BETWEEN');
    x_errMessage := fnd_message.get;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.validate',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
    return;
  END IF;-- Check no move shopfloor statuses between the from and to

  IF(p_fmOp < p_toOp AND
     p_toStep = WIP_CONSTANTS.QUEUE) THEN
    -- check osp related validation
    IF (wip_osp.checkOSP(p_orgID       => p_orgID,
                         p_wipEntityID => p_jobID,
                         p_entityType  => 1, -- Discrete
                         p_fmOpSeqNum  => p_fmOp,
                         p_toOpSeqNum  => p_toOp,
                         p_toStep      => p_toStep,
                         p_userID      => p_userID,
                         x_msg         => message,
                         x_error       => x_errMessage) = false) THEN
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_move.validate',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => x_errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
      return;
    END IF;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_success;
  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wma_move.validate',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'success',
                         x_returnStatus => l_returnStatus);
  end if;
EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    x_errMessage := 'unexpected error: ' || SQLERRM;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_move.validate',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;

END validate;

/**
 * This function inserts into the MOVE_TXN_INTERFACE table with values
 * derived and minimally validated by prior validate call with data stored
 * in the moveRecord passed in parameter.
 * Parameters:
 *   moveRecord  The MoveTxnRec representing the row to be inserted.
 * Return:
 *   boolean     A flag indicating whether update successful or not.
 */
Function put(moveRecord     IN        MoveTxnRec,
             errMessage IN OUT NOCOPY VARCHAR2)
return boolean IS
BEGIN
  insert into wip_move_txn_interface
         (group_id,
          source_code,
          transaction_id,
          last_update_date,
          last_updated_by,
          last_updated_by_name,
          creation_date, created_by,
          created_by_name,
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
          qa_collection_id,
          overcompletion_transaction_qty,
          overcompletion_primary_qty
         )
  values (moveRecord.row.group_id,
          moveRecord.row.source_code,
          moveRecord.row.transaction_id,
          moveRecord.row.last_update_date,
          moveRecord.row.last_updated_by,
          moveRecord.row.last_updated_by_name,
          moveRecord.row.creation_date,
          moveRecord.row.created_by,
          moveRecord.row.created_by_name,
          moveRecord.row.process_phase,
          moveRecord.row.process_status,
          moveRecord.row.transaction_type,
          moveRecord.row.organization_id,
          moveRecord.row.organization_code,
          moveRecord.row.wip_entity_id,
          moveRecord.row.wip_entity_name,
          moveRecord.row.entity_type,
          moveRecord.row.primary_item_id,
          moveRecord.row.line_id,
          moveRecord.row.line_code,
          moveRecord.row.transaction_date,
          moveRecord.row.acct_period_id,
          moveRecord.row.fm_operation_seq_num,
          moveRecord.row.fm_operation_code,
          moveRecord.row.fm_department_id,
          moveRecord.row.fm_department_code,
          moveRecord.row.fm_intraoperation_step_type,
          moveRecord.row.to_operation_seq_num,
          moveRecord.row.to_operation_code,
          moveRecord.row.to_department_id,
          moveRecord.row.to_department_code,
          moveRecord.row.to_intraoperation_step_type,
          moveRecord.row.transaction_quantity,
          moveRecord.row.transaction_uom,
          moveRecord.row.primary_quantity,
          moveRecord.row.primary_uom,
          moveRecord.row.scrap_account_id,
          moveRecord.row.reason_id,
          moveRecord.row.qa_collection_id,
          moveRecord.row.overcompletion_transaction_qty,
          moveRecord.row.overcompletion_primary_qty
         );
  return true;

EXCEPTION
  when others then
    fnd_message.set_name ('WIP', 'GENERIC_ERROR');
    fnd_message.set_token ('FUNCTION', 'wma_move.put');
    fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
    errMessage := fnd_message.get;
    return false;
END put;

/**
 * This function inserts into the WIP_SERIAL_MOVE_INTERFACE table with values
 * selected from wip_move_txn_interface table
 *
 * Parameters:
 *   transactionID The transaction_id in wip_move_txn_interface table
 *   serialNumber  The serial number
 * Return:
 *   boolean     A flag indicating whether update successful or not.
 */
Function insertSerial(groupID        IN        NUMBER,
                      transactionID  IN        NUMBER,
                      serialNumber   IN        VARCHAR2,
                      errMessage IN OUT NOCOPY VARCHAR2)
return boolean IS
BEGIN
  insert into wip_serial_move_interface
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
          program_update_date
         )
          select transaction_id,
                 serialNumber,
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
                 program_update_date
            FROM wip_move_txn_interface wmti
           WHERE transaction_id = transactionID
             AND group_id = groupID;
  return true;

EXCEPTION
  when others then
    fnd_message.set_name ('WIP', 'GENERIC_ERROR');
    fnd_message.set_token ('FUNCTION', 'wma_move.insertSerial');
    fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
    errMessage := fnd_message.get;
    return false;
END insertSerial;
END wma_move;

/
