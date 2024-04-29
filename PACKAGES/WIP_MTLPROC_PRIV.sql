--------------------------------------------------------
--  DDL for Package WIP_MTLPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MTLPROC_PRIV" AUTHID CURRENT_USER as
 /* $Header: wipmtlps.pls 120.1.12000000.1 2007/01/18 22:18:21 appldev ship $ */
  --------------------------------------------------------------------------------------------------
  --This package is the wip material processor (component issues, neg issues, returns, neg returns).
  --It will perform all wip logic and optionally do the inventory transaction.
  --------------------------------------------------------------------------------------------------

  -------------------------------------------------------------------------------------------------
  --processTemp(). This version processes a single MMTT record.
  --
  --parameters:
  --  + p_initMsgList  initialize the message list?
  --    --fnd_api.g_true   to initialize the message list
  --    --fnd_api.g_false  to preserve the existing messages
  --  + p_endDebug: Clean up the log file?
  --    --fnd_api.g_true   unless you plan to call wip_logger.cleanUp() later.
  --    --fnd_api.g_false  if you wish to close the log file.
  --  + p_txnTmpID: The identifier for the MMTT row to process.
  --  + x_returnStatus: return status of the procedure
  --    --fnd_api.g_ret_sts_success      on successful processing.
  --    --fnd_api.g_ret_sts_unexp_error  if an unexpected error occurred.
  -------------------------------------------------------------------------------------------------
  procedure processTemp(p_initMsgList IN VARCHAR2,
                        p_endDebug IN VARCHAR2,
                        p_txnTmpID IN NUMBER,
                        x_returnStatus OUT NOCOPY VARCHAR2);

 /***************************************************************************
  *
  * This procedure will be called from WIP OA Transaction page to do component
  * issue, component return, negative component issue, and negative component
  * return transactions for Discrete jobs. User needs to insert record into
  * MTL_TRANSACTIONS_INTERFACE before calling this routine.
  *
  * PARAMETER:
  *
  * p_mtl_header_id        transaction_header_id in MTL_TRANSACTIONS_INTERFACE
  * x_return_status        There are 2 possible values
  *                        *fnd_api.g_ret_sts_success*
  *                        means the every record was succesfully processed
  *                        *fnd_api.g_ret_sts_error*
  *                        means some records error out
  *
  ***************************************************************************/
  PROCEDURE processOATxn(p_mtl_header_id  IN        NUMBER,
                         x_returnStatus  OUT NOCOPY VARCHAR2);

end wip_mtlProc_priv;

 

/
