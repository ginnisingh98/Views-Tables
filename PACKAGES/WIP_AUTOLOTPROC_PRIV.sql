--------------------------------------------------------
--  DDL for Package WIP_AUTOLOTPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_AUTOLOTPROC_PRIV" AUTHID CURRENT_USER as
 /* $Header: wiplotps.pls 120.1 2007/09/17 21:12:42 kboonyap ship $ */

  ------------------------------------------------------------------------------------------------
  --This package will do lot defaulting. The deriveLots() procedure is the heart of the package.
  --It will take an object of items and then derive lots for those items. The deriveLotsFromMMTT
  --and deriveLotsFromMTI procedures are wrappers on top of deriveLots() that select items from
  --MMTT, derive the lots for lot controlled items, and do various serial number checks for
  --serial controlled items. Lots can be derived as follows:
  --
  --Issues: A quantity tree is built to query the amount of onhand lot quantities in the given
  --        backflush location. This procedure uses the lot derivation parameters (FIFO,FEFO) to
  --        pick lots.
  --
  --Negative Issues: Lots can not be derived for this transaction type. This is because neg issues
  --                 are similar to assembly completions: A new item is being created, so none of
  --                 the wip derivation rules are applicable.
  --
  --Returns/Negative Returns: Past transactions are queried to obtain the lots that were used in
  --                          previous issues. These are the lots that are defaulted for these 2
  --                          transaction types.
  ------------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------------------------
  --deriveLots. This procedure will derive lots for all the items in the x_compLots structure.
  --parameters:
  --  + x_compLots: This parameter contains all the items that need lot derivation on input.
  --                On output, derived lots are added to the object appropriately.
  --  + p_orgID: The organization.
  --  + p_wipEntityID: Only needed for returns. Used to query past transactions for this entity. Pass
  --                   null for completion transactions.
  --  + p_initMsgList: Initialize the message list?
  --    --fnd_api.g_true   to initialize the message list
  --    --fnd_api.g_false  to preserve the existing messages
  --  + p_endDebug: Clean up the log file?
  --    --fnd_api.g_true   unless you plan to call wip_logger.cleanUp() later.
  --    --fnd_api.g_false  if you wish to close the log file.
  --  + p_destroyTrees: Destroy the quantity trees after they are used?
  --    --fnd_api.g_true   to destroy trees on procedure exit.
  --    --fnd_api.g_false  to retain trees in memory for later manipulation by caller.
  --  + p_treeMode: which mode to open the tree in. See inv_quantity_tree_pvt package spec.
  --                wip normally uses inv_quantity_tree_pvt.g_reservation_mode.
  --  + p_treeSrcName: Name of the tree. Use if the tree needs to be later identified (Only makes
  --                   sense if p_destroyTrees is false).if p_destroyTrees is true, any value can
  --                   be passed (including null).
  --  + x_returnStatus: return status of the procedure (tri-state)
  --    -- fnd_api.g_ret_sts_success      if all lot information was derived.
  --    -- fnd_api.g_ret_sts_error        if some lot information could not be derived.
  --    -- fnd_api.g_ret_sts_unexp_error  if an unexpected error occurred.
  --------------------------------------------------------------------------------------------------------
  procedure deriveLots(x_compLots  IN OUT NOCOPY system.wip_lot_serial_obj_t,
                       p_orgID         IN NUMBER,
                       p_wipEntityID   IN NUMBER,
                       p_initMsgList   IN VARCHAR2,
                       p_endDebug      IN VARCHAR2,
                       p_destroyTrees  IN VARCHAR2,
                       p_treeMode      IN NUMBER,
                       p_treeSrcName   IN VARCHAR2,
                       x_returnStatus OUT NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------------------------------------
  --deriveLotsFromMMTT. This procedure will derive lots for all the items in MMTT for the given identifier.
  --It will also check if serial information is missing.
  --parameters:
  --  + p_cplTxnID: Query mmtt rows by completion_transaction_id if this parameter is not null.
  --  + p_movTxnID: Query mmtt rows by move_transaction_id if this parameter is not null.
  --  + p_orgID: The organization.
  --  + p_wipEntityID: Only needed for returns. Used to query past transactions for this entity. Pass
  --                   null for completions
  --  + p_initMsgList: Initialize the message list?
  --    --fnd_api.g_true   to initialize the message list
  --    --fnd_api.g_false  to preserve the existing messages
  --  + p_endDebug: Clean up the log file?
  --    --fnd_api.g_true   unless you plan to call wip_logger.cleanUp() later.
  --    --fnd_api.g_false  if you wish to close the log file.
  --  + x_returnStatus: return status of the procedure (tri-state)
  --    --fnd_api.g_ret_sts_success     if all lot information was derived.
  --    --fnd_api.g_ret_sts_error       if some lot information could not be derived or some
  --                                    items are under serial control.
  --    --fnd_api.g_ret_sts_unexp_error if an unexpected error occurred.
  ---------------------------------------------------------------------------------------------------------
/*  procedure deriveLotsFromMMTT(p_cplTxnID IN NUMBER,
                               p_movTxnID IN NUMBER,
                               p_orgID    IN NUMBER,
                               p_wipEntityID IN NUMBER, --populate for returns
                               p_initMsgList IN VARCHAR2,
                               p_endDebug     IN VARCHAR2,
                               x_returnStatus OUT NOCOPY VARCHAR2);
*/
  ---------------------------------------------------------------------------------------------------------
  --deriveLotsFromMTI. This procedure will derive lots for all the items in MTI for the given identifier.
  --It will also check if serial information is missing.
  --parameters:
  --  + p_orgID: The organization.
  --  + p_wipEntityID: Only needed for returns. Used to query past transactions for this entity. Pass
  --                   null for completions.
  --  + p_parentID: Query MTI rows by parent_id.
  --  + p_initMsgList: Initialize the message list?
  --    --fnd_api.g_true   to initialize the message list
  --    --fnd_api.g_false  to preserve the existing messages
  --  + p_endDebug: Clean up the log file?
  --    --fnd_api.g_true   unless you plan to call wip_logger.cleanUp() later.
  --    --fnd_api.g_false  if you wish to close the log file.
  --  + x_returnStatus: return status of the procedure (tri-state)
  --    --fnd_api.g_ret_sts_success     if all lot information was derived.
  --    --fnd_api.g_ret_sts_error       if some lot information could not be derived or some
  --                                    items are under serial control.
  --    --fnd_api.g_ret_sts_unexp_error if an unexpected error occurred.
  ---------------------------------------------------------------------------------------------------------
  procedure deriveLotsFromMTI(p_orgID    IN NUMBER,
                              p_wipEntityID IN NUMBER, --populate for returns
                              p_txnHdrID IN NUMBER,
                              p_cplTxnID IN NUMBER := null,
                              p_movTxnID IN NUMBER := null,
                              p_childMovTxnID IN NUMBER := null,
                              p_initMsgList IN VARCHAR2,
                              p_endDebug     IN VARCHAR2,
                              x_returnStatus OUT NOCOPY VARCHAR2);

/******************************************************************************
 * This procedure will do lots derivation. It will take an object of items
 * and then derive lots for those items based on the genealogy built for
 * assembly. Lots can be derived as follows:
 *
 * Return           : Lot will be derived based on genealogy build from issue
 *                    transaction.
 *
 * Issues           : Lot cannot be derived for this transaction type
 *                    because no genealogy have been built yet.
 *
 * Negative Return/ : Lot cannot be derived for these transaction types
 * Negative Issue     because no genealogy have been built for these txns
 *
 * parameters:
 * x_compLots        This parameter contains all the items that need to be
 *                   unbackflushed. On output, derived lot are added to
 *                   the object appropriately.
 * p_objectID        Object_id of the parent serial(assembly). Used to derive
 *                   all the child lot number
 * p_orgID           Organization ID
 * p_initMsgList     Initialize the message list?
 * x_returnStatus    fnd_api.g_ret_sts_success if success without any errors.
 *                   Otherwise return fnd_api.g_ret_sts_unexp_error.
 *****************************************************************************/
  PROCEDURE deriveLotsFromMOG(
              x_compLots  IN OUT NOCOPY system.wip_lot_serial_obj_t,
              p_orgID         IN        NUMBER,
              p_objectID      IN        NUMBER,
              p_initMsgList   IN        VARCHAR2,
              x_returnStatus OUT NOCOPY VARCHAR2);

end wip_autoLotProc_priv;

/
