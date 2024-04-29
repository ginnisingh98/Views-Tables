--------------------------------------------------------
--  DDL for Package WIP_MTLTEMPPROC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MTLTEMPPROC_GRP" AUTHID CURRENT_USER as
 /* $Header: wiptmpps.pls 115.7 2003/09/19 02:47:01 kmreddy ship $ */


  type comp_rec_t is record(txnTmpID NUMBER,
                             mtlTxnID NUMBER,
                             wipEntityId NUMBER,
                             repLineID NUMBER,
                             orgID NUMBER,
                             itemID NUMBER,
                             opSeqNum NUMBER,
                             primaryQty NUMBER,
                             txnQty NUMBER,
                             negReqFlag NUMBER,
                             wipSupplyType NUMBER,
                             wipEntityType NUMBER,
                             supplySub VARCHAR2(10),
                             supplyLocID NUMBER,
                             txnDate DATE,
                             txnHdrID NUMBER,
                             movTxnID NUMBER,
                             cplTxnID NUMBER,
                             qaCollectionID NUMBER,
                             deptID NUMBER,
                             txnActionID NUMBER,
                             serialControlCode NUMBER,
                             lotControlCode NUMBER,
                             eamItemType NUMBER,
                             rebuildItemID NUMBER,
                             rebuildJobName VARCHAR2(240),
                             rebuildActivityID NUMBER,
                             rebuildSerialNumber VARCHAR2(30));

  --Procedure to process WIP transactions out of MMTT. Currently a limited number of transaction
  --types are supported:
  -- + component issues
  -- + component returns
  -- + component negative issues
  -- + component negative returns
  -- + Scraps (no WIP processing involved)
  -- + Cost Updates (no WIP processing involved)
  -- Arguments:
  -- + p_initMsgList: Pass fnd_api.g_true to initialize the message list.
  --                  Pass fnd_api.g_false to leave the message list intact.
  -- + p_processInv: Pass fnd_api.g_true to invoke the TM
  --                 Pass fnd_api.g_false to only perform WIP processing
  -- + p_txnHdrID: the transaction_header_id value of the MMTT records to be processed.
  -- + p_mtlTxnBusinessFlowCode: This will be passed to the inv TM for component transactions.
  --                             It is generally used for label printing purposes. If null, then
  --                             label printing does not occur.
  -- + x_returnStatus: fnd_api.g_ret_sts_success if all rows were processed successfully.
  --                   fnd_api.g_ret_sts_error OR fnd_api.g_ret_sts_unexp_error if some rows failed.
  -- + x_errorMsg: A concatenation of all the error messages for any rows that failed. It is limited
  --               to 2000 characters in length. Each row's error_code and error_explanation columns
  --               should be updated for that row's specific error.
  procedure processTemp(p_initMsgList IN VARCHAR2,
                        p_processInv IN VARCHAR2, --whether or not to call inventory TM
                        p_txnHdrID IN NUMBER,
                        p_mtlTxnBusinessFlowCode IN NUMBER := null,
                        x_returnStatus OUT NOCOPY VARCHAR2,
                        x_errorMsg OUT NOCOPY VARCHAR2);

  procedure processWIP(p_txnTmpID IN NUMBER,
                       x_returnStatus OUT NOCOPY VARCHAR2,
                       x_errorMsg OUT NOCOPY VARCHAR2);

  function isTxnIDRequired(p_txnTmpID IN NUMBER) return boolean;

end wip_mtlTempProc_grp;

 

/
