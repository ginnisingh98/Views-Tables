--------------------------------------------------------
--  DDL for Package WMA_MOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_MOVE" AUTHID CURRENT_USER AS
/* $Header: wmapmovs.pls 120.1 2007/09/17 21:21:11 kboonyap ship $ */

  /**
   * This is the set of parameters that will be passed from the Mobile Apps
   * Move form to the process procedure for processing the transaction.
   * The list contains all displayed fields as well as hidden fields
   * (derived from the LOV).  All fields will be initialized to
   * FND_API initialization values.  For boolean values, they will be
   * initailized to false. The lengths for the strings are derived from
   * those defined in WIP_CONSTANTS package.
   */
  TYPE MoveParam IS RECORD
  (
    environment          wma_common.environment,
    txnMode              NUMBER,
    txnID                NUMBER,
    childTxnID           NUMBER,
    mtl_header_id        NUMBER,
    wipEntityID          NUMBER,
    wipEntityName        VARCHAR2(241),
    itemID               NUMBER,
    itemName             VARCHAR2(241),
    fmOpSeqNum           NUMBER,
    fmStepType           NUMBER,
    toOpSeqNum           NUMBER,
    toStepType           NUMBER,
    overcompleteQty      NUMBER,
    availableQty         NUMBER,
    transactionQty       NUMBER,
    transactionUOM       VARCHAR2(4),
    minTransferQty       NUMBER,
    qualityID            NUMBER,
    reasonID             NUMBER,
    projectID            NUMBER,
    taskID               NUMBER,
    -- new param added for scrap account and easy complete/return project
    scrapAcctID          NUMBER,
    txnType              NUMBER,
    mtlTxnTypeID         NUMBER,
    mtlTxnIntID          NUMBER,
    cmpTxnID             NUMBER,
    kanbanID             NUMBER,
    locatorID            NUMBER,
    locatorName          VARCHAR2(241),
    subinv               VARCHAR2(11),
    -- new param added for serial txns project
    serial               VARCHAR2(30),
    serialOp             NUMBER,
    isFromSerializedPage NUMBER
  );

  /**
   * This is the record type for the record to be inserted into
   * WIP_MOVE_TXN_INTERFACE table.
   */
  TYPE MoveTxnRec IS RECORD (row wip_move_txn_interface%ROWTYPE);

  PROCEDURE process(parameters IN OUT NOCOPY MoveParam,
                    status        OUT NOCOPY NUMBER,
                    errMessage    OUT NOCOPY VARCHAR2);

  /**
   * This procedure is a wrapper on top of wip_bflProc_priv.processRequirements
   * and wip_autoLotProc_priv.deriveLots. This procedure should be called to
   * check whether we need to gather more lot/serial info from the user or not
   *
   * parameters
   * p_childMoveID     pass -1 for regular txns, and pass value generated from
   *                   wip_transactions_s for overmove/overcomplete
   * p_ocQty           pass 0 for regular txns, and pass value for overmove
   * p_cmpTxnID        pass value generated from mtl_material_transactions_s
   *                   for EZ Complete/Return and processing mode is
   *                   online. Otherwise pass -1.
   * p_objectID        pass -1 for non-serialized txns, and pass gen_object_id
   *                   for serialized txns.
   */
   PROCEDURE backflush(p_jobID         IN        NUMBER,
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
                       x_errMessage   OUT NOCOPY VARCHAR2);

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
                       x_errMessage   OUT NOCOPY VARCHAR2);

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
                         x_errMessage   OUT NOCOPY VARCHAR2);

  /**
   * This procedure validates the overcompletion tolerance, shop floor status
   * , and do OSP validation
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
                     x_errMessage   OUT NOCOPY VARCHAR2);

  /**
   * This function derives and validates the values necessary for executing the
   * move transaction. Given the form parameters, it populates moveRecord
   * preparing it to be inserted into the interface table.
   */
  FUNCTION derive(moveRecord IN OUT NOCOPY MoveTxnRec,
                  parameters     IN        MoveParam,
                  errMessage IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  /**
   * Inserts a populated MoveTxnRec into WIP_MOVE_TXN_INTERFACE
   */
  FUNCTION put(moveRecord     IN        MoveTxnRec,
               errMessage IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;
  /**
   * This function inserts into the WIP_SERIAL_MOVE_INTERFACE table with values
   * selected from wip_move_txn_interface table
   *
   * Parameters:
   *   groupID       The group_id in wip_move_txn_interface table
   *   transactionID The transaction_id in wip_move_txn_interface table
   *   serialNumber  The serial number
   * Return:
   *   boolean     A flag indicating whether update successful or not.
   */
  FUNCTION insertSerial(groupID        IN        NUMBER,
                        transactionID  IN        NUMBER,
                        serialNumber   IN        VARCHAR2,
                        errMessage IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

END wma_move;

/
