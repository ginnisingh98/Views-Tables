--------------------------------------------------------
--  DDL for Package WIP_CPLPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CPLPROC_PRIV" AUTHID CURRENT_USER as
/* $Header: wipcplps.pls 120.3 2007/09/17 19:52:10 vjambhek ship $ */

  ---------------
  --public types
  ---------------
  type completion_rec_t is record(wipEntityType  NUMBER,
                                  wipEntityID    NUMBER,
                                  orgID          NUMBER,
                                  repLineID      NUMBER,
                                  itemID         NUMBER,
                                  txnActionID    NUMBER,
                                  priQty         NUMBER,
                                  txnQty         NUMBER,
                                  txnDate        DATE,
                                  cplTxnID       NUMBER,
                                  movTxnID       NUMBER,
                                  kanbanCardID   NUMBER,
                                  qaCollectionID NUMBER,
                                  lastOpSeq      NUMBER,
                                  revision       VARCHAR2(3),
                                  mtlAlcTmpID    NUMBER,
                                  txnHdrID       NUMBER,
                                  txnStatus      NUMBER,
                                  overCplPriQty  NUMBER,
                                  overCplTxnID   NUMBER,
                                  lastUpdBy      NUMBER,
                                  createdBy      NUMBER,
                                  lpnID          NUMBER,
                                  txnMode        NUMBER);
  ---------------------------------------------------------------------------------------------
  -- Processes a single completion transaction in MMTT
  --
  --parameters:
  -- + p_txnTmpID: mmtt identifier of the completion txn
  -- + p_initMsgList: initialize the message stack?
  -- + p_endDebug: Clean up the log file? Pass fnd_api.g_true unless you plan to call
  --               wip_logger.cleanUp() later.
  -- + x_returnStatus: fnd_api.g_ret_sts_success     on successful processing.
  --                   fnd_api.g_exc_error           if l/s information is for the components
  --                                                 is missing
  --                   fnd_api.g_ret_sts_unexp_error if an unexpected error occurred or one or
  --                                                 more records failed processing.
  ---------------------------------------------------------------------------------------------
  procedure processTemp(p_txnTmpID     IN         NUMBER,
                        p_initMsgList  IN         VARCHAR2,
                        p_endDebug     IN         VARCHAR2,
                        x_returnStatus OUT NOCOPY VARCHAR2);

  procedure preAllocateSchedules(p_txnHdrID     IN         NUMBER,
                                 p_cplTxnID     IN         NUMBER,
                                 p_txnActionID  IN         NUMBER,
                                 p_wipEntityID  IN         NUMBER,
                                 p_repLineID    IN         NUMBER,
                                 p_tblName      IN         VARCHAR2,
                                 p_endDebug     IN         VARCHAR2,
                                 x_returnStatus OUT NOCOPY VARCHAR2);

  procedure processOverCpl(p_cplRec       IN OUT NOCOPY completion_rec_t,
                           x_returnStatus    OUT NOCOPY VARCHAR2);

 /***************************************************************************
  *
  * This procedure will be called from WIP OA Transaction page to do completion
  * and return transactions for Discrete jobs. User needs to insert record into
  * MTL_TRANSACTIONS_INTERFACE before calling this routine.
  *
  * PARAMETER:
  *
  * p_org_id               organization_id in MTL_TRANSACTIONS_INTERFACE
  * p_interface_id         transaction_interface_id in
  *                        MTL_TRANSACTIONS_INTERFACE
  * p_mtl_header_id        transaction_header_id in MTL_TRANSACTIONS_INTERFACE
  * p_oc_primary_qty       overcompletion_primary_qty in
  * p_assySerial           Assembly serial number. This parameter will be used
  *                        to differentiate between regular and serialized
  *                        transactions.
  * p_print_label          Print Label flag. This parameter will be used to pass
  *                        the value of the Administrator preference 'Standard
  *                        Operations for Move Labels' for the current transaction.
  * x_return_status        There are 2 possible values
  *                        *fnd_api.g_ret_sts_success*
  *                        means the every record was succesfully processed
  *                        *fnd_api.g_ret_sts_error*
  *                        means some records error out
  *
  * NOTE:
  * The user don't need to insert child record for online over completion.
  * This API will take care everything. The user also don't need
  * to call QA API for online transaction either.
  ***************************************************************************/
  PROCEDURE processOATxn(p_org_id         IN        NUMBER,
                         p_interface_id   IN        NUMBER,
                         p_mtl_header_id  IN        NUMBER,
                         p_oc_primary_qty IN        NUMBER,
                         p_assySerial     IN        VARCHAR2:= NULL,
			 p_print_label    IN        NUMBER default null,/*VJ Label Printing*/
                         x_returnStatus  OUT NOCOPY VARCHAR2);
end wip_cplProc_priv;

/
