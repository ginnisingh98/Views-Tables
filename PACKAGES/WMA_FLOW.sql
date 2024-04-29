--------------------------------------------------------
--  DDL for Package WMA_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_FLOW" AUTHID CURRENT_USER AS
/* $Header: wmapflws.pls 120.1 2007/10/12 18:27:21 vjambhek ship $ */

  /**
   * This structure is for the parameters passed from the form.
   */
  TYPE FlowParam IS RECORD (
    environment             wma_common.environment,
    scheduleNumber          VARCHAR2(30),
    scheduledFlag           NUMBER,
    assemblyID              NUMBER,
    lineID                  NUMBER,
    wipEntityID             NUMBER,
    transactionType         NUMBER,
    transactionHeaderID     NUMBER,
    transactionIntID        NUMBER,
    completionTxnID         NUMBER,
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
    lpnID                   NUMBER,
    demandSourceHeaderID    NUMBER,
    demandSourceLine        VARCHAR2(30),
    demandSourceDelivery    VARCHAR2(30),
    headerId                NUMBER    /*Fix for bug #6216695, which is an FP of 6082623 :
                                        Add header id to populate MTLT and MSNT*/
  );


  /**
   * This structrue is for the record that should be inserted into
   * mtl_material_transactions_temp table.
   */
  TYPE FlowRecord IS RECORD(
    transaction_interface_id NUMBER,
    completion_transaction_id NUMBER,
    transaction_header_id NUMBER,
    process_flag NUMBER,
    source_code VARCHAR2(30),
    last_updated_by NUMBER,
    last_update_date DATE,
    creation_date DATE,
    created_by NUMBER,
    transaction_mode NUMBER,
    inventory_item_id NUMBER,
    organization_id NUMBER,
    wip_entity_type NUMBER,
    subinventory_code VARCHAR2(30),
    locator_id NUMBER,
    revision VARCHAR2(3),
    bom_revision VARCHAR2(3),
    bom_revision_date DATE,
    routing_revision VARCHAR2(3),
    routing_revision_date DATE,
    transaction_uom VARCHAR2(3),
    transaction_quantity NUMBER,
    primary_quantity NUMBER,
    acct_period_id NUMBER,
    distribution_account_id NUMBER,
    reason_id NUMBER,
    qa_collection_id NUMBER,
    transaction_source_id NUMBER,
    transaction_source_type_id NUMBER,
    transaction_type_id NUMBER,
    transaction_action_id NUMBER,
    transaction_date DATE,
    flow_schedule VARCHAR2(1),
    wipEntityType NUMBER,
    scheduled_flag NUMBER,
    schedule_number VARCHAR2(30),
    repetitive_line_id NUMBER,
    operation_seq_num NUMBER,
    accounting_class VARCHAR2(10),
    kanban_card_id NUMBER,
    source_project_id NUMBER,
    source_task_id NUMBER,
    lpn_id NUMBER,
    demand_source_header_id NUMBER,
    demand_source_line VARCHAR2(30),
    demand_source_delivery VARCHAR2(30),
    source_line_id NUMBER,
    source_header_id NUMBER,
    header_id   NUMBER /*Fix for bug #6216695, which is an FP of 6082623 :
                         Add header id to populate MTLT and MSNT*/
 );



  PROCEDURE insertParentRecord(param      IN     FlowParam,
                               status     OUT NOCOPY NUMBER,
                               errMessage OUT NOCOPY VARCHAR2);

  PROCEDURE insertParentRecordIntoMMTT(param      IN     FlowParam,
                                       status     OUT NOCOPY NUMBER,
                                       errMessage OUT NOCOPY VARCHAR2);

  Function derive(param FlowParam,
                  flowRec OUT NOCOPY FlowRecord,
                  errMsg OUT NOCOPY VARCHAR2) return boolean;

  Function put(flowRec FlowRecord, errMsg OUT NOCOPY VARCHAR2) return boolean;


  procedure explodeBOMAndDerive(p_assyID          in  number,
                                p_orgID           in  number,
                                p_qty             in  number,
                                p_wipEntityID     in  number,
                                p_txnDate         in  date,
                                p_projectID       in  number,
                                p_taskID          in  number,
                                p_toOpSeqNum      in  number,
                                x_lotEntryType    out nocopy number,
                                x_compInfo        out nocopy system.wip_lot_serial_obj_t,
                                x_returnStatus    out nocopy varchar2,
                                x_errMessage      out nocopy varchar2);

END wma_flow;

/
