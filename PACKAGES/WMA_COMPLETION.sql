--------------------------------------------------------
--  DDL for Package WMA_COMPLETION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_COMPLETION" AUTHID CURRENT_USER AS
/* $Header: wmapcmps.pls 120.2.12010000.1 2008/07/24 05:28:06 appldev ship $ */

  /**
   * Contains the set of parameters that will be passed from the Mobile Apps
   * Completion and Return forms to the process procedure for processing the
   * transaction. The list contains all displayed fields as well as hidden
   * fields (derived from LOVs on the form). It also contains the transaction
   * IDs that are used to associate the transaction''s parent record in
   * MTL_MATERIAL_TRANSACTIONS_TEMP to its child records in other tables (an
   * example is the lot and serial information for the item.)
   * All fields are initialized to FND_API initialization values. Boolean
   * values are initailized to false. Strings lengths are derived from
   * those defined in WIP_CONSTANTS package.
   * HISTORY:
   * 02-MAR-2006  spondalu  ER 4163405: Added two new parameters to CmpParams
   *                        and CmpTxnRec.
   *
   */
  TYPE CmpParams IS RECORD
  (
    environment           wma_common.environment,
    transactionType       NUMBER,
    transactionHeaderID   NUMBER,
    transactionIntID      NUMBER,
    cmpTransactionID      NUMBER,
    movTransactionID      NUMBER,
    wipEntityID           NUMBER,
    wipEntityName         VARCHAR2(241),
    itemID                NUMBER,
    itemName              VARCHAR2(241),
    overcomplete          BOOLEAN,
    transactionQty        NUMBER,
    transactionUOM        VARCHAR2(4),
    subinv                VARCHAR2(11),
    locatorID             NUMBER,
    locatorName           VARCHAR2(241),
    kanbanCardID          NUMBER,
    qualityID             NUMBER,
    projectID             NUMBER,
    taskID                NUMBER,
    lpnID                 NUMBER,
    isFromSerializedPage  NUMBER,
    demandSourceHeaderID  NUMBER, /* ER 4163405 */
    demandSourceLineID    NUMBER
  );

  TYPE LpnCmpParams IS RECORD
  (
    environment           wma_common.environment,
    transactionTypeID     NUMBER,
    headerID              NUMBER,
    wipEntityID           NUMBER,
    wipEntityName         VARCHAR2(241),
    itemID                NUMBER,
    itemName              VARCHAR2(241),
    overcomplete          BOOLEAN,
    transactionQty        NUMBER,
    transactionUOM        VARCHAR2(4),
    subinv                VARCHAR2(11),
    locatorID             NUMBER,
    locatorName           VARCHAR2(241),
    kanbanCardID          NUMBER,
    qualityID             NUMBER,
    lpnID                 NUMBER,
    completionTxnID       NUMBER
  );

  /**
   * This is the record type for the record to be populated and inserted into
   * the MTL_MATERIAL_TRANSACTIONS_TEMP table.
   */
  TYPE CmpTxnRec IS RECORD(transaction_interface_id NUMBER,
                           transaction_header_id NUMBER,
                           item_lot_control_code NUMBER,
                           operation_seq_num NUMBER,
                           revision VARCHAR2(3),
                           transaction_type_id NUMBER,
                           transaction_action_id NUMBER,
                           primary_quantity NUMBER,
                           transaction_quantity NUMBER,
                           overcompletion_transaction_id NUMBER,
                           overcompletion_transaction_qty NUMBER,
                           overcompletion_primary_qty NUMBER,
                           transaction_source_id NUMBER,
                           transaction_source_type_id NUMBER,
                           completion_transaction_id NUMBER,
                           move_transaction_id NUMBER,
                           transaction_mode NUMBER,
                           created_by NUMBER,
                           creation_date DATE,
                           last_updated_by NUMBER,
                           last_update_date DATE,
                           source_code VARCHAR2(30),
                           source_line_id NUMBER,
                           source_header_id NUMBER,
                           inventory_item_id NUMBER,
                           subinventory_code VARCHAR2(10),
                           locator_id NUMBER,
                           transaction_uom VARCHAR2(3),
                           transaction_date DATE,
                           organization_id NUMBER,
                           acct_period_id NUMBER,
                           wip_entity_type NUMBER,
                           process_flag NUMBER,
                           final_completion_flag VARCHAR2(1),
                           project_id NUMBER,
                           task_id NUMBER,
                           source_project_id NUMBER,
                           source_task_id NUMBER,
                           qa_collection_id NUMBER,
                           kanban_card_id NUMBER,
                           lpn_id NUMBER,
                           demand_source_header_id NUMBER, /* ER 4163405 */
                           demand_source_line_id NUMBER);


  TYPE LpnCmpTxnRec IS RECORD (row wip_lpn_completions%ROWTYPE);

  /**
   * This procedure is the entry point into the Completion and Return
   * Processing code for background processing.
   */
  PROCEDURE process(parameters IN CmpParams,
                    processInv IN  VARCHAR2,
                    txnMode    IN NUMBER := NULL, --override wip parammeter setting
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2);

  PROCEDURE process(parameters IN     LpnCmpParams,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2,
                    cmpl_txnTmpId OUT NOCOPY NUMBER); -- Added for Bug 6013398.
  /**
   * This function derives and validates the values necessary for executing a
   * completion or return transaction. Given the form parameters, it populates
   * cmpRecord preparing it to be inserted into the interface table.
   */
  FUNCTION derive(cmpRecord  IN OUT NOCOPY CmpTxnRec,
                  overCplRec IN OUT NOCOPY wip_cplProc_priv.completion_rec_t,
                  parameters IN            CmpParams,
                  txnMode    IN            NUMBER,
                  errMessage IN OUT NOCOPY VARCHAR2) return boolean;

  FUNCTION derive(LpnCmpRecord IN OUT NOCOPY LpnCmpTxnRec,
                  parameters IN LpnCmpParams,
                  errMessage IN OUT NOCOPY VARCHAR2) return boolean;

  /**
   * Inserts a populated CmpTxnRec into MTL_MATERIAL_TRANSACTIONS_TEMP
   */
  FUNCTION put(cmpRecord IN CmpTxnRec,
               errMessage IN OUT NOCOPY VARCHAR2) return boolean;

  /**
   * Inserts a populated CmpTxnRec into wip_lpn_completions
   */
  FUNCTION put(lpnCmpRecord IN LpnCmpTxnRec,
               errMessage IN OUT NOCOPY VARCHAR2) return boolean;

  /**
   * checks the transaction quantity entered by the user.
   * In the case of completion, the quantity should not exceed the quantity
   * available to complete for the job. If overcompleting, however, the
   * transaction quantity should be greater than the available quantity
   * and should not exceed the overcompletion tolerance.
   * In the case of return, the quantity should not exceed the completed
   * quantity.
   * If the structures passed to this procedure are not available, use the
   * overloaded version.
   */
  FUNCTION checkQuantity (parameters IN CmpParams,
                          job IN wma_common.Job,
                          errMessage IN OUT NOCOPY VARCHAR2) return boolean;


  /**
   * checks the transaction quantity entered by the user.
   * In the case of completion, the quantity should not exceed the quantity
   * available to complete for the job. If overcompleting, however, the
   * transaction quantity should be greater than the available quantity,
   * and should not exceed the overcompletion tolerance.
   * In the case of return, the quantity should not exceed the completed
   * quantity.
   */
  FUNCTION checkQuantity (orgID IN NUMBER,
                          wipEntityID IN NUMBER,
                          overcomplete IN BOOLEAN,
                          transactionType IN NUMBER,
                          transactionQty IN NUMBER,
                          availableQty IN NUMBER,
                          completedQty IN NUMBER,
                          errMessage IN OUT NOCOPY VARCHAR2) return boolean;

  /**
   * Check whether exceeds overcompletion tolerance or not.
   */
  procedure checkOverCpl(p_orgID        in number,
                         p_wipEntityID  in number,
                         p_overCplQty   in number,
                         x_returnStatus out nocopy varchar2,
                         x_errMessage   out nocopy varchar2);


  /**
   * given a Job, getLastOpSeq() gets the last operation sequence
   * associated with the job if the job has a routing. If the job
   * does not have a routing, -1 is returned.
   */
  FUNCTION getLastOpSeq (job IN wma_common.Job) return number;


  /**
   * given a wipEntityID and an orgID, getLastOpSeq() gets the last
   * operation sequence associated with the job if the job has a
   * routing. If the job does not have a routing, -1 is returned.
   */
  FUNCTION getLastOpSeq (wipEntityID IN NUMBER,
                         orgID IN NUMBER) return number;


  /**
   * given a job, getAvilableQty() returns the quantity in the
   * To Move step of the final operation if the job has a routing.
   * If the job, does not have a routing, getAvailableQty() computes
   * the available quantity to complete from the job quantities.
   */
  FUNCTION getAvailableQty (job IN wma_common.Job) return number;

  /**
   * Collects backflush components for the job into the x_compInfo object
   */
  procedure backflush(p_jobID IN NUMBER,
                      p_orgID IN NUMBER,
                      p_cplQty IN NUMBER,
                      p_overCplQty IN NUMBER,
                      p_cplTxnID IN NUMBER,
                      p_movTxnID IN NUMBER,
                      p_txnDate IN DATE,
                      p_txnHdrID IN NUMBER,
                      p_txnMode in number := null,
                      p_objectID in number,
                      x_lotEntryType OUT NOCOPY NUMBER,
                      x_compInfo OUT NOCOPY system.wip_lot_serial_obj_t,
                      x_returnStatus OUT NOCOPY VARCHAR2,
                      x_errMessage OUT NOCOPY VARCHAR2);

  /**
   * given a wipEntityID, orgID and itemID, getRevision() will validate
   * whether bom_revision exists as an item_revision or not. If not
   * return false. Otherwise return true. If bom_revision is null, derive
   * it based on the transaction_date specified. In mobile it is sysdate.
   * Parameters:
   *   wipEntityID  the wip_entity_id of the job
   *   orgID        the organization job belongs to.
   *   itemID       the assembly item ID
   *   revision     bom_revision if bom_revision exists as an item_revision
   *                if bom_revision is null, derive it based on txn_date
   * Returns:
   *   true if bom_revision exist as an item_revision. Otherwise return false
   */
  FUNCTION getRevision (wipEntityID IN NUMBER,
                        orgID       IN NUMBER,
                        itemID      IN NUMBER,
                        revision   OUT NOCOPY VARCHAR2) return boolean;

END wma_completion;

/
