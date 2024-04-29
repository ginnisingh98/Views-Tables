--------------------------------------------------------
--  DDL for Package Body WIP_MOVPROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MOVPROC_PUB" AS
/* $Header: wipmvpbb.pls 120.0 2005/05/24 18:03:19 appldev noship $*/

/*************************************************************************
 * This  procedure should be called if caller want to process one record
 * at a time.
 *************************************************************************/
PROCEDURE processInterface(p_txn_id       IN         NUMBER,
                           p_do_backflush IN         VARCHAR2 := NULL,
                           p_commit       IN         VARCHAR2,
                           x_returnStatus OUT NOCOPY VARCHAR2,
                           x_errorMsg     OUT NOCOPY VARCHAR2) IS

CURSOR c_errors(p_transaction_id NUMBER) IS
  SELECT error_column,
         error_message
    FROM wip_txn_interface_errors
   WHERE transaction_id = p_transaction_id;

l_returnStatus VARCHAR2(1);
l_do_backflush VARCHAR2(1);
l_params wip_logger.param_tbl_t;
l_groupID NUMBER;
l_logLevel NUMBER := fnd_log.g_current_runtime_level;
l_errors c_errors%ROWTYPE;
BEGIN

  IF(l_logLevel <= WIP_CONSTANTS.TRACE_LOGGING) THEN
    l_params(1).paramName := 'p_txn_id';
    l_params(1).paramValue := p_txn_id;
    wip_logger.entryPoint(p_procName     => 'wip_movProc_pub.processInterface',
                          p_params       => l_params,
                          x_returnStatus => l_returnStatus);

  END IF;

  SELECT group_id
    INTO l_groupID
    FROM wip_move_txn_interface
   WHERE transaction_id = p_txn_id
     AND process_phase = WIP_CONSTANTS.MOVE_VAL
     AND process_status = WIP_CONSTANTS.RUNNING
     AND group_id IS NOT NULL;

  IF (p_do_backflush = fnd_api.g_false) THEN
    l_do_backflush := fnd_api.g_false;
  ELSE
    l_do_backflush := fnd_api.g_true;
  END IF;

  wip_movProc_priv.processIntf(p_group_id      => l_groupID,
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
                               p_do_backflush  => l_do_backflush,
                               x_returnStatus  => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    raise fnd_api.g_exc_error;
  END IF;

  IF(fnd_api.to_boolean(p_commit)) THEN
    COMMIT;
  END IF;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_pub.processInterface',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
    wip_logger.cleanUp(x_returnStatus => l_returnStatus);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    FOR l_errors IN c_errors(p_transaction_id => p_txn_id) LOOP
      x_errorMsg := x_errorMsg || l_errors.error_column ||':' ||
                   l_errors.error_message || '; ';
    END LOOP;
    x_errorMsg := substr(x_errorMsg, 1, 1000);

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_pub.processInterface',
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
      wip_logger.exitPoint(p_procName => 'wip_movProc_pub.processInterface',
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
      wip_logger.exitPoint(p_procName => 'wip_movProc_pub.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'no data found: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    x_errorMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_pub.processInterface',
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
PROCEDURE processInterface(p_group_id     IN         NUMBER,
                           p_do_backflush IN         VARCHAR2 := NULL,
                           p_commit       IN         VARCHAR2,
                           x_returnStatus OUT NOCOPY VARCHAR2) IS
l_returnStatus VARCHAR2(1);
l_do_backflush VARCHAR2(1);
l_params wip_logger.param_tbl_t;
l_groupID NUMBER;
l_logLevel NUMBER := fnd_log.g_current_runtime_level;
BEGIN

  IF(l_logLevel <= WIP_CONSTANTS.TRACE_LOGGING) THEN
    l_params(1).paramName := 'p_group_id';
    l_params(1).paramValue := p_group_id;
    wip_logger.entryPoint(p_procName     => 'wip_movProc_pub.processInterface',
                          p_params       => l_params,
                          x_returnStatus => l_returnStatus);

  END IF;

  IF (p_do_backflush = fnd_api.g_false) THEN
    l_do_backflush := fnd_api.g_false;
  ELSE
    l_do_backflush := fnd_api.g_true;
  END IF;

  wip_movProc_priv.processIntf(p_group_id      => p_group_id,
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
                               p_do_backflush  => l_do_backflush,
                               x_returnStatus  => x_returnStatus);

  IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
    raise fnd_api.g_exc_error;
  END IF;

  IF(fnd_api.to_boolean(p_commit)) THEN
    COMMIT;
  END IF;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_movProc_pub.processInterface',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'no record in this group error out',
                         x_returnStatus => l_returnStatus);
    wip_logger.cleanUp(x_returnStatus => l_returnStatus);
  END IF;
EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_pub.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'some records in this group error out',
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;

  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_movProc_pub.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexpected error: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
      wip_logger.cleanUp(x_returnStatus => l_returnStatus);
    END IF;
END processInterface;

END wip_movProc_pub;

/
