--------------------------------------------------------
--  DDL for Package WMA_MATERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_MATERIAL" AUTHID CURRENT_USER AS
/* $Header: wmapmtls.pls 120.0 2005/05/25 07:50:36 appldev noship $ */

  /**
   * This structure is for the parameters passed from the form.
   *
   * HISTORY:
   * 30-DEC-2004  spondalu  Bug 4093569: eAM-WMS Integration enhancements:
   *                        Included new member wipEntityType to MtlParam.
   */
  TYPE MtlParam IS RECORD (
    environment             wma_common.environment,
    transactionType         NUMBER,
    transactionHeaderID     NUMBER,
    transactionIntID        NUMBER,
    jobID                   NUMBER,
    itemID                  NUMBER,
    transactionQty          NUMBER,
    transactionUOM          VARCHAR2(3),
    opSeqNum                NUMBER,
    deptID                  NUMBER,
    subinventoryCode        VARCHAR2(10),
    locatorID               NUMBER,
    qualityID               NUMBER,
    projectID               NUMBER,
    taskID                  NUMBER,
    revision                VARCHAR2(3),
    isFromSerializedPage    NUMBER,
    wipEntityType           NUMBER
  );

  /**
   * This structrue is for the record that should be inserted into
   * MTI.
   *
   * HISTORY:
   * 30-DEC-2004  spondalu  Bug 4093569: eAM-WMS Integration enhancements:
   *                        Included new element rebuild_item_id in mtlRecord.
   */
  TYPE MtlRecord IS RECORD(transaction_header_id NUMBER,
                           transaction_interface_id NUMBER,
                           transaction_mode NUMBER,
                           inventory_item_id NUMBER,
                           subinventory_code VARCHAR2(10),
                           locator_id NUMBER,
                           transaction_date DATE,
                           organization_id NUMBER,
                           acct_period_id NUMBER,
                           last_update_date DATE,
                           last_updated_by NUMBER,
                           creation_date DATE,
                           created_by NUMBER,
                           transaction_source_id NUMBER,
                           transaction_source_type_id NUMBER,
                           source_code VARCHAR2(30),
                           source_line_id NUMBER,
                           source_header_id NUMBER,
                           transaction_quantity NUMBER,
                           primary_quantity NUMBER,
                           transaction_uom VARCHAR2(3),
                           negative_req_flag NUMBER,
                           transaction_action_id NUMBER,
                           transaction_type_id NUMBER,
                           wip_entity_type NUMBER,
                           operation_seq_num NUMBER,
                           department_id NUMBER,
                           revision VARCHAR2(3),
                           project_id NUMBER,
                           task_id NUMBER,
                           source_project_id NUMBER,
                           source_task_id NUMBER,
                           qa_collection_id NUMBER,
                           process_flag NUMBER,
                           final_completion_flag VARCHAR2(1),
                           rebuild_item_id NUMBER);

  /**
   * This procedure is the entry point into the Material Transaction
   * processing code.
   */
  PROCEDURE process(param      IN  MtlParam,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2);

  Function derive(param MtlParam,
                  mtlRec OUT NOCOPY MtlRecord,
                  errMsg OUT NOCOPY VARCHAR2) return boolean;

  Function put(mtlRec MtlRecord, errMsg OUT NOCOPY VARCHAR2) return boolean;

  procedure validateIssueProject(p_orgID       in  number,
                                 p_wipEntityID in  number,
                                 p_locatorID   in  number,
                                 p_allowCrossIssue in number,
                                 x_projectID   out nocopy number,
                                 x_taskID      out nocopy number,
                                 x_projectNum  out nocopy varchar2,
                                 x_taskNum     out nocopy varchar2,
                                 x_returnStatus out nocopy varchar2,
                                 x_returnMsg   out nocopy varchar2);

END wma_material;

 

/
