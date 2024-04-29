--------------------------------------------------------
--  DDL for Package Body WIP_MOVPROC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MOVPROC_GRP" AS
/* $Header: wipmvgpb.pls 120.1 2006/04/27 16:58:19 kboonyap noship $*/
PROCEDURE backflush(p_wipEntityID     IN        NUMBER,
                    p_orgID           IN        NUMBER,
                    p_primaryQty      IN        NUMBER,
                    p_txnDate         IN        DATE,
                    p_txnHdrID        IN        NUMBER,
                    p_txnType         IN        NUMBER,
                    p_fmOp            IN        NUMBER,
                    p_fmStep          IN        NUMBER,
                    p_toOp            IN        NUMBER,
                    p_toStep          IN        NUMBER,
                    p_movTxnID        IN        NUMBER,
                    p_cplTxnID        IN        NUMBER:= NULL,
                    x_lotSerRequired OUT NOCOPY NUMBER,
                    x_compInfo       OUT NOCOPY system.wip_lot_serial_obj_t,
                    x_returnStatus   OUT NOCOPY VARCHAR2) IS

BEGIN
  wip_bflproc_priv.backflush(
    p_wipEntityID        => p_wipEntityID,
    p_orgID              => p_orgID,
    p_primaryQty         => p_primaryQty,
    p_txnDate            => p_txnDate,
    p_txnHdrID           => p_txnHdrID,
    p_txnType            => p_txnType,
    p_entityType         => WIP_CONSTANTS.LOTBASED,
    p_fmOp               => p_fmOp,
    p_fmStep             => p_fmStep,
    p_toOp               => p_toOp,
    p_toStep             => p_toStep,
    p_movTxnID           => p_movTxnID,
    p_cplTxnID           => p_cplTxnID,
    x_compInfo           => x_compInfo,
    x_lotSerRequired     => x_lotSerRequired,
    x_returnStatus       => x_returnStatus);

END backflush;

PROCEDURE backflushIntoMMTT(p_wipEntityID   IN        NUMBER,
                            p_orgID         IN        NUMBER,
                            p_primaryQty    IN        NUMBER,
                            p_txnDate       IN        DATE,
                            p_txnHdrID      IN        NUMBER,
                            p_txnType       IN        NUMBER,
                            p_fmOp          IN        NUMBER,
                            p_fmStep        IN        NUMBER,
                            p_toOp          IN        NUMBER,
                            p_toStep        IN        NUMBER,
                            p_movTxnID      IN        NUMBER,
                            p_cplTxnID      IN        NUMBER:= NULL,
                            p_mtlTxnMode    IN        NUMBER,
                            p_reasonID      IN        NUMBER:= NULL,
                            p_reference     IN        VARCHAR2:= NULL,
                            x_bfRequired   OUT NOCOPY NUMBER,
                            x_returnStatus OUT NOCOPY VARCHAR2) IS

l_lotSerRequired NUMBER; -- throw away value
BEGIN
  wip_bflProc_priv.backflush(
    p_wipEntityID    => p_wipEntityID,
    p_orgID          => p_orgID,
    p_primaryQty     => p_primaryQty,
    p_txnDate        => p_txnDate,
    p_txnHdrID       => p_txnHdrID,
    -- Fixed bug 5056289. Populate batch_id with move_id instead of header_id.
    p_batchID        => p_movTxnID,
    p_txnType        => p_txnType,
    p_entityType     => WIP_CONSTANTS.LOTBASED,
    p_tblName        => WIP_CONSTANTS.MMTT_TBL,
    p_fmOp           => p_fmOp,
    p_fmStep         => p_fmStep,
    p_toOp           => p_toOp,
    p_toStep         => p_toStep,
    p_movTxnID       => p_movTxnID,
    p_cplTxnID       => p_cplTxnID,
    p_mtlTxnMode     => p_mtlTxnMode,
    p_reasonID       => p_reasonID,
    p_reference      => p_reference,
    x_lotSerRequired => l_lotSerRequired,
    x_bfRequired     => x_bfRequired,
    x_returnStatus   => x_returnStatus);
END backflushIntoMMTT;

PROCEDURE backflushIntoMTI(p_wipEntityID     IN        NUMBER,
                           p_orgID           IN        NUMBER,
                           p_primaryQty      IN        NUMBER,
                           p_txnDate         IN        DATE,
                           p_txnHdrID        IN        NUMBER,
                           p_txnType         IN        NUMBER,
                           p_fmOp            IN        NUMBER,
                           p_fmStep          IN        NUMBER,
                           p_toOp            IN        NUMBER,
                           p_toStep          IN        NUMBER,
                           p_movTxnID        IN        NUMBER,
                           p_cplTxnID        IN        NUMBER:= NULL,
                           p_mtlTxnMode      IN        NUMBER,
                           p_reasonID        IN        NUMBER:= NULL,
                           p_reference       IN        VARCHAR2:= NULL,
                           x_lotSerRequired OUT NOCOPY NUMBER,
                           x_returnStatus   OUT NOCOPY VARCHAR2) IS

l_bfRequired NUMBER; -- throw away value
BEGIN
  wip_bflProc_priv.backflush(
    p_wipEntityID    => p_wipEntityID,
    p_orgID          => p_orgID,
    p_primaryQty     => p_primaryQty,
    p_txnDate        => p_txnDate,
    p_txnHdrID       => p_txnHdrID,
    -- Fixed bug 5056289. Populate batch_id with move_id instead of header_id.
    p_batchID        => p_movTxnID,
    p_txnType        => p_txnType,
    p_entityType     => WIP_CONSTANTS.LOTBASED,
    p_tblName        => WIP_CONSTANTS.MTI_TBL,
    p_fmOp           => p_fmOp,
    p_fmStep         => p_fmStep,
    p_toOp           => p_toOp,
    p_toStep         => p_toStep,
    p_movTxnID       => p_movTxnID,
    p_cplTxnID       => p_cplTxnID,
    p_mtlTxnMode     => p_mtlTxnMode,
    p_reasonID       => p_reasonID,
    p_reference      => p_reference,
    x_lotSerRequired => x_lotSerRequired,
    x_bfRequired     => l_bfRequired,
    x_returnStatus   => x_returnStatus);
END backflushIntoMTI;

/*************************************************************************
 * This  procedure should be called if caller want to process one record
 * at a time.
 *************************************************************************/
PROCEDURE processInterface(p_movTxnID      IN         NUMBER,
                           p_procPhase     IN         NUMBER,
                           p_txnHdrID      IN         NUMBER,
                           p_mtlMode       IN         NUMBER,
                           p_cplTxnID      IN         NUMBER := NULL,
                           p_commit        IN         VARCHAR2 := NULL,
                           x_returnStatus  OUT NOCOPY VARCHAR2,
                           x_errorMsg      OUT NOCOPY VARCHAR2) IS

CURSOR c_errors(p_transaction_id NUMBER) IS
  SELECT error_column,
         error_message
    FROM wip_txn_interface_errors
   WHERE transaction_id = p_transaction_id;

l_returnStatus VARCHAR2(1);
l_params wip_logger.param_tbl_t;
l_groupID NUMBER;
l_move_mode NUMBER;
l_logLevel NUMBER := fnd_log.g_current_runtime_level;
l_errors c_errors%ROWTYPE;
BEGIN

  IF(l_logLevel <= WIP_CONSTANTS.TRACE_LOGGING) THEN
    l_params(1).paramName := 'p_movTxnID';
    l_params(1).paramValue := p_movTxnID;
    l_params(2).paramName := 'p_procPhase';
    l_params(2).paramValue := p_procPhase;
    l_params(3).paramName := 'p_txnHdrID';
    l_params(3).paramValue := p_txnHdrID;
    l_params(4).paramName := 'p_mtlMode';
    l_params(4).paramValue := p_mtlMode;
    l_params(5).paramName := 'p_cplTxnID';
    l_params(5).paramValue := p_cplTxnID;
    l_params(6).paramName := 'p_commit';
    l_params(6).paramValue := p_commit;

    wip_logger.entryPoint(p_procName     => 'wip_movProc_grp.processInterface',
                          p_params       => l_params,
                          x_returnStatus => l_returnStatus);

  END IF;

  SELECT group_id
    INTO l_groupID
    FROM wip_move_txn_interface
   WHERE transaction_id = p_movTxnID
     AND process_phase = p_procPhase
     AND process_status = WIP_CONSTANTS.RUNNING
     AND group_id IS NOT NULL;

  IF(p_procPhase = WIP_CONSTANTS.MOVE_VAL) THEN
    l_move_mode := WIP_CONSTANTS.BACKGROUND;
  ELSE
    l_move_mode := WIP_CONSTANTS.ONLINE;
  END IF;

  wip_movProc_priv.processIntf(p_group_id      => l_groupID,
                               p_child_txn_id  => -1,
                               p_mtl_header_id => p_txnHdrID,
                               p_proc_phase    => p_procPhase,
                               p_time_out      => 0,
                               p_move_mode     => l_move_mode,
                               p_bf_mode       => WIP_CONSTANTS.ONLINE,
                               p_mtl_mode      => p_mtlMode,
                               p_endDebug      => fnd_api.g_false,
                               p_initMsgList   => fnd_api.g_true,
                               p_insertAssy    => fnd_api.g_true,
                               p_do_backflush  => fnd_api.g_false,
                               p_cmp_txn_id    => p_cplTxnID,
                               x_returnStatus  => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    raise fnd_api.g_exc_error;
  END IF;

  IF(fnd_api.to_boolean(p_commit)) THEN
    COMMIT;
  END IF;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_grp.processInterface',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
    wip_logger.cleanUp(x_returnStatus => l_returnStatus);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF(l_move_mode = WIP_CONSTANTS.BACKGROUND) THEN
      FOR l_errors IN c_errors(p_transaction_id => p_movTxnID) LOOP
        x_errorMsg := x_errorMsg || l_errors.error_column ||':' ||
                      l_errors.error_message || '; ';
      END LOOP;
      x_errorMsg := substr(x_errorMsg, 1, 1000);
    ELSE
      -- get error message from message stack
      inv_mobile_helper_functions.get_stacked_messages(x_errorMsg);
    END IF;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_grp.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'wip_movProc_priv.processIntf failed',
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;

  WHEN TOO_MANY_ROWS THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WIP', 'WIP_NOT_VALID');
    fnd_message.set_token('ENTITY', 'TRANSACTION_ID');
    x_errorMsg := substr(fnd_message.get, 1, 1000);

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_grp.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'to many rows: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;

  WHEN NO_DATA_FOUND THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WIP', 'WIP_NOT_VALID');
    fnd_message.set_token('ENTITY',
      'TRANSACTION_ID/GROUP_ID/PROCESS_PHASE/PROCESS_STATUS');
    x_errorMsg := substr(fnd_message.get, 1, 1000);

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_grp.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'no data found: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    x_errorMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_grp.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errorMsg,
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;

END processInterface;

/*************************************************************************
 * This  procedure should be called if caller want to do batch processing
 * for multiple records in WMTI.
 *************************************************************************/
PROCEDURE processInterface(p_groupID       IN         NUMBER,
                           p_commit        IN         VARCHAR2 := NULL,
                           x_returnStatus  OUT NOCOPY VARCHAR2) IS
l_returnStatus VARCHAR2(1);
l_params wip_logger.param_tbl_t;
l_groupID NUMBER;
l_logLevel NUMBER := fnd_log.g_current_runtime_level;
BEGIN

  IF(l_logLevel <= WIP_CONSTANTS.TRACE_LOGGING) THEN
    l_params(1).paramName := 'p_groupID';
    l_params(1).paramValue := p_groupID;
    l_params(2).paramName := 'p_commit';
    l_params(2).paramValue := p_commit;
    wip_logger.entryPoint(p_procName     => 'wip_movProc_grp.processInterface',
                          p_params       => l_params,
                          x_returnStatus => l_returnStatus);

  END IF;

  wip_movProc_priv.processIntf(p_group_id      => p_groupID,
                               p_child_txn_id  => -1,
                               p_mtl_header_id => -1,
                               p_proc_phase    => WIP_CONSTANTS.MOVE_VAL,
                               p_time_out      => 0,
                               p_move_mode     => WIP_CONSTANTS.BACKGROUND,
                               p_bf_mode       => WIP_CONSTANTS.ONLINE,
                               p_mtl_mode      => WIP_CONSTANTS.ONLINE,
                               p_endDebug      => fnd_api.g_false,
                               p_initMsgList   => fnd_api.g_true,
                               p_insertAssy    => fnd_api.g_true,
                               p_do_backflush  => fnd_api.g_true,
                               x_returnStatus  => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    raise fnd_api.g_exc_error;
  END IF;

  IF(fnd_api.to_boolean(p_commit)) THEN
    COMMIT;
  END IF;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_grp.processInterface',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'no record in this group error out',
                         x_returnStatus => l_returnStatus);
    wip_logger.cleanUp(x_returnStatus => l_returnStatus);
  END IF;
EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_grp.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'some records in this group error out',
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_grp.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexpected error: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;
END processInterface;

END wip_movProc_grp;

/
