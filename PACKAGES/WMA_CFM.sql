--------------------------------------------------------
--  DDL for Package WMA_CFM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_CFM" AUTHID CURRENT_USER AS
/* $Header: wmapcfms.pls 115.9 2003/09/08 22:01:13 rlohani ship $ */

  /**
   * This structure is for the parameters passed from the form.
   */
  TYPE CfmParam IS RECORD (
    environment             wma_common.environment,
    scheduleNumber          VARCHAR2(30),
    scheduledFlag           NUMBER,
    assemblyID              NUMBER,
    lineID                  NUMBER,
    wipEntityID             NUMBER,
    transactionType         NUMBER,
    transactionHeaderID     NUMBER,
    transactionInterfaceID  NUMBER,
    transactionQty          NUMBER,
    transactionUOM          VARCHAR2(3),
    transactionDate         DATE,
    subinventoryCode        VARCHAR2(10),
    locatorID               NUMBER,
    reasonID                NUMBER,
    qualityID               NUMBER,
    lineOp                  NUMBER,
    kanbanID                NUMBER,
    projectID               NUMBER,
    taskID                  NUMBER,
    demandSourceHeaderID    NUMBER,
    demandSourceLine        VARCHAR2(30),
    demandSourceDelivery    VARCHAR2(30)
  );

  TYPE LpnCfmParam IS RECORD (
    environment             wma_common.environment,
    scheduleNumber          VARCHAR2(30),
    scheduledFlag           NUMBER,
    assemblyID              NUMBER,
    lineID                  NUMBER,
    headerID                NUMBER,
    transactionType         NUMBER,
    transactionQty          NUMBER,
    transactionUOM          VARCHAR2(3),
    transactionDate         DATE,
    subinventoryCode        VARCHAR2(10),
    locatorID               NUMBER,
    reasonID                NUMBER,
    qualityID               NUMBER,
    lineOp                  NUMBER,
    kanbanID                NUMBER,
    lpnID                   NUMBER,
    completionTxnID         NUMBER,
    wipEntityID             NUMBER,
    demandSourceHeaderID    NUMBER,
    demandSourceLine        VARCHAR2(30),
    demandSourceDelivery    VARCHAR2(30)
  );

  /**
   * This structrue is for the record that should be inserted into
   * mtl_transactions_interface table.
   */
  TYPE CfmRecord IS RECORD (row mtl_transactions_interface%ROWTYPE);
  TYPE LpnCfmRecord IS RECORD (row wip_lpn_completions%ROWTYPE);

  PROCEDURE process(param      IN     CfmParam,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2);

  PROCEDURE process(lpnParam   IN     LpnCfmParam,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2);

  Function derive(param CfmParam,
                  cfmRec OUT NOCOPY CfmRecord,
                  errMsg OUT NOCOPY VARCHAR2) return boolean;

  Function derive(lpnParam LpnCfmParam,
                  lpnCfmRec OUT NOCOPY LpnCfmRecord,
                  errMsg OUT NOCOPY VARCHAR2) return boolean;

  Function put(cfmRec CfmRecord, errMsg OUT NOCOPY VARCHAR2) return boolean;

  Function put(lpnCfmRec LpnCfmRecord, errMsg OUT NOCOPY VARCHAR2) return boolean;

END wma_cfm;

 

/
