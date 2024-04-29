--------------------------------------------------------
--  DDL for Package WIP_MTLTEMPPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MTLTEMPPROC_PRIV" AUTHID CURRENT_USER as
 /* $Header: wiptmpvs.pls 120.0.12010000.1 2008/07/24 05:26:46 appldev ship $ */

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
  -- + p_txnHdrID: the transaction_header_id value of the MMTT records to be processed.
  -- + x_returnStatus: fnd_api.g_ret_sts_success if all rows were processed successfully.
  --                   fnd_api.g_ret_sts_error OR fnd_api.g_ret_sts_unexp_error if some rows failed.
  -- + x_errorMsg: A concatenation of all the error messages for any rows that failed. It is limited
  --               to 2000 characters in length. Each row's error_code and error_explanation columns
  --               should be updated for that row's specific error.
  procedure processTemp(p_initMsgList IN VARCHAR2,
                        p_txnHdrID IN NUMBER,
                        p_txnMode IN NUMBER := null,
                        p_destroyQtyTrees IN VARCHAR2 := null,
                        p_endDebug IN VARCHAR2 := null,
                        x_returnStatus OUT NOCOPY VARCHAR2,
                        x_errorMsg OUT NOCOPY VARCHAR2);


  procedure processWIP(p_txnTmpID IN NUMBER,
                       p_processLpn IN VARCHAR2,
                       p_endDebug IN VARCHAR2 := null,
                       x_returnStatus OUT NOCOPY VARCHAR2,
                       x_errorMsg OUT NOCOPY VARCHAR2);


  --does limited validation of MTI records and moves the records to MMTT
  procedure validateInterfaceTxns(p_txnHdrID in NUMBER,
                                  p_initMsgList in VARCHAR2 := null,--default false
                                  p_endDebug in VARCHAR2 := null, --default false
                                  p_numRows IN NUMBER := null,
                                  p_addMsgToStack IN VARCHAR2 := null,--default true
                                  p_rollbackOnErr IN VARCHAR2 := null,--default true
                                  x_returnStatus out nocopy VARCHAR2);

end wip_mtlTempProc_priv;

/
