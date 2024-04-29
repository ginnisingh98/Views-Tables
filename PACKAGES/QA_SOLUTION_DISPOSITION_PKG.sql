--------------------------------------------------------
--  DDL for Package QA_SOLUTION_DISPOSITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SOLUTION_DISPOSITION_PKG" AUTHID CURRENT_USER as
/* $Header: qasodiss.pls 120.0.12010000.4 2010/04/26 17:22:38 ntungare ship $ */


  PROCEDURE REWORK_NEW_NONSTANDARD_JOB(
		   p_item                 IN VARCHAR2,
                   p_job_class            IN VARCHAR2,
                   p_job_name             IN VARCHAR2,
                   p_job_start            IN VARCHAR2,
                   p_job_end              IN VARCHAR2,
                   p_bill_reference       IN VARCHAR2,
                   p_bom_revision         IN VARCHAR2,
                   p_routing_reference    IN VARCHAR2,
                   p_routing_revision     IN VARCHAR2,
                   p_quantity             IN NUMBER,
                   p_job_mrp_net_quantity IN NUMBER,
                   p_project_number       IN VARCHAR2,
                   p_task_number          IN VARCHAR2,
                   p_collection_id        IN NUMBER,
                   p_occurrence           IN NUMBER,
                   p_organization_code    IN VARCHAR2,
                   p_plan_name            IN VARCHAR2,
                   p_launch_action        IN VARCHAR2,
                   p_action_fired         IN VARCHAR2);


  FUNCTION REWORK_NEW_NONSTANDARD_JOB_INT(
		     p_item_id              NUMBER,
                     p_group_id             NUMBER,
                     p_jclass               VARCHAR2,
                     p_job_name             VARCHAR2,
                     p_job_start            DATE,
                     p_job_end              DATE,
                     p_bill_id              NUMBER,
                     p_bill_revision        VARCHAR2,
                     p_routing_id           NUMBER,
                     p_routing_revision     VARCHAR2,
                     p_quantity             NUMBER,
                     p_job_mrp_net_quantity NUMBER,
                     p_project_number       VARCHAR2,
                     p_task_number          VARCHAR2,
                     p_organization_id      NUMBER)
  RETURN NUMBER;



  PROCEDURE WIP_SCRAP_WIP_MOVE(
		     p_item               IN VARCHAR2,
                     p_job_name           IN VARCHAR2,
		     p_scrap_alias        IN VARCHAR2,
                     p_from_op_seq        IN NUMBER,
                     p_from_intra_step    IN VARCHAR2,
                     p_to_op_seq          IN NUMBER,
                     p_to_intra_step      IN VARCHAR2,
                     p_from_op_code       IN VARCHAR2,
                     p_to_op_code         IN VARCHAR2,
                     p_reason_code        IN VARCHAR2,
                     p_uom                IN VARCHAR2,
                     p_quantity           IN NUMBER,
                     p_txn_date           IN VARCHAR2,
                     p_collection_id      IN NUMBER,
                     p_occurrence         IN NUMBER,
                     p_organization_code  IN VARCHAR2,
                     p_plan_name          IN VARCHAR2,
                     p_launch_action      IN VARCHAR2,
                     p_action_fired       IN VARCHAR2);


  FUNCTION WIP_SCRAP_WIP_MOVE_INT(
		       p_item_id           NUMBER,
                       p_txn_id            NUMBER,
                       p_job_name          VARCHAR2,
                       p_dist_account_id   NUMBER,
                       p_from_op_seq       NUMBER,
                       p_from_intra_step   NUMBER,
                       p_to_op_seq         NUMBER,
                       p_to_intra_step     NUMBER,
                       p_fm_op_code        VARCHAR2 DEFAULT NULL,
                       p_to_op_code        VARCHAR2 DEFAULT NULL,
                       p_reason_id         NUMBER DEFAULT NULL,
                       p_uom               VARCHAR2,
                       p_quantity          NUMBER,
                       p_txn_date          DATE,
                       p_organization_code VARCHAR2,
                       p_collection_id     VARCHAR2)
  RETURN NUMBER;



  PROCEDURE INV_SCRAP_ACCOUNT_ALIAS(
				  p_item               IN VARCHAR2,
                                  p_revision           IN VARCHAR2,
                                  p_subinventory       IN VARCHAR2,
                                  p_locator            IN VARCHAR2,
                                  p_lot_number         IN VARCHAR2,
                                  p_serial_number      IN VARCHAR2,
                                  p_transaction_uom    IN VARCHAR2,
                                  p_transaction_qty    IN NUMBER,
                                  p_transaction_date   IN VARCHAR2,
                                  p_inv_acc_alias      IN VARCHAR2,
                                  p_collection_id      IN NUMBER,
                                  p_occurrence         IN NUMBER,
                                  p_organization_code  IN VARCHAR2,
                                  p_plan_name          IN VARCHAR2,
                                  p_launch_action      IN VARCHAR2,
                                  p_action_fired       IN VARCHAR2);



  FUNCTION INV_SCRAP_ACCOUNT_ALIAS_INT(
		       p_item_id          NUMBER,
                       p_revision         VARCHAR2,
                       p_subinventory     VARCHAR2,
                       p_locator_id       NUMBER,
                       p_lot_number       VARCHAR2,
                       p_serial_number    VARCHAR2,
                       p_transaction_uom  VARCHAR2,
                       p_transaction_qty  NUMBER,
                       p_transaction_date DATE,
                       p_disposition_id   NUMBER,
                       p_collection_id    NUMBER,
                       p_occurrence       NUMBER,
                       p_organization_id  NUMBER)
  RETURN NUMBER;

  --
  -- bug 9652549 CLM changes
  --
  PROCEDURE PO_RETURN_TO_VENDOR(
			    p_item               IN VARCHAR2,
                            p_revision           IN VARCHAR2,
                            p_subinventory       IN VARCHAR2,
                            p_locator            IN VARCHAR2,
                            p_lot_number         IN VARCHAR2,
                            p_serial_number      IN VARCHAR2,
                            p_uom_code           IN VARCHAR2,
                            p_quantity           IN NUMBER,
                            p_po_number          IN VARCHAR2,
                            p_po_line_number     IN VARCHAR2,
                            p_po_shipment_number IN NUMBER,
                            p_po_receipt_number  IN NUMBER,
                            p_transaction_date   IN VARCHAR2,
                            p_collection_id      IN NUMBER,
                            p_occurrence         IN NUMBER,
                            p_plan_name          IN VARCHAR2,
                            p_organization_code  IN VARCHAR2,
                            p_launch_action      IN VARCHAR2,
                            p_action_fired       IN VARCHAR2);


  --
  -- bug 9652549 CLM changes
  --
  FUNCTION PO_RETURN_TO_VENDOR_INT(
		   p_item_id                  IN NUMBER,
                   p_revision                 IN VARCHAR2,
                   p_subinventory             IN VARCHAR2,
                   p_locator_id               IN NUMBER	,
                   p_lot_number               IN VARCHAR2,
                   p_serial_number            IN VARCHAR2,
                   p_uom_code                 IN VARCHAR2,
                   p_quantity                 IN NUMBER,
                   p_po_number                IN VARCHAR2,
                   p_po_line_number           IN VARCHAR2,
                   p_po_shipment_number       IN NUMBER,
                   p_po_receipt_number        IN NUMBER,
                   p_transaction_date         IN DATE,
                   p_collection_id            IN NUMBER,
                   p_occurrence               IN NUMBER,
                   p_plan_id                  IN NUMBER,
                   p_organization_id          IN NUMBER,
                   p_interface_transaction_id IN NUMBER)
  RETURN NUMBER;


  PROCEDURE INV_CREATE_MOVE_ORDER (
                            p_item               IN VARCHAR2,
                            p_revision           IN VARCHAR2,
                            p_from_subinventory  IN VARCHAR2,
                            p_from_locator       IN VARCHAR2,
                            p_lot_number         IN VARCHAR2,
                            p_serial_number      IN VARCHAR2,
                            p_uom_code           IN VARCHAR2,
                            p_quantity           IN NUMBER,
                            p_to_subinventory    IN VARCHAR2,
                            p_to_locator         IN VARCHAR2,
                            p_date_required      IN VARCHAR2,
                            p_project_number     IN VARCHAR2,
                            p_task_number        IN VARCHAR2,
                            p_collection_id      IN NUMBER,
                            p_occurrence         IN NUMBER,
                            p_plan_name          IN VARCHAR2,
                            p_organization_code  IN VARCHAR2,
                            p_launch_action      IN VARCHAR2,
                            p_action_fired       IN VARCHAR2 );


  FUNCTION INV_CREATE_MOVE_ORDER_INT (
                            p_item_id            IN NUMBER,
                            p_revision           IN VARCHAR2,
                            p_from_subinventory  IN VARCHAR2,
                            p_from_locator_id    IN NUMBER,
                            p_lot_number         IN VARCHAR2,
                            p_serial_number      IN VARCHAR2,
                            p_uom_code           IN VARCHAR2,
                            p_quantity           IN NUMBER,
                            p_to_subinventory    IN VARCHAR2,
                            p_to_locator_id      IN NUMBER,
                            p_date_required      IN DATE,
                            p_project_id         IN NUMBER,
                            p_task_id            IN NUMBER,
                            p_organization_id    IN NUMBER,
                            x_request_number     OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;


  PROCEDURE WIP_COMP_RETURN(
                            p_job_name           IN VARCHAR2,
                            p_item               IN VARCHAR2,
                            p_revision           IN VARCHAR2,
                            p_subinventory       IN VARCHAR2,
                            p_locator            IN VARCHAR2,
                            p_lot_number         IN VARCHAR2,
                            p_serial_number      IN VARCHAR2,
                            p_transaction_uom    IN VARCHAR2,
                            p_transaction_qty    IN NUMBER,
                            p_transaction_date   IN VARCHAR2,
                            p_op_seq_num         IN NUMBER,
                            p_reason_code        IN VARCHAR2,
                            p_collection_id      IN NUMBER,
                            p_occurrence         IN NUMBER,
                            p_organization_code  IN VARCHAR2,
                            p_plan_name          IN VARCHAR2,
                            p_launch_action      IN VARCHAR2,
                            p_action_fired       IN VARCHAR2);



  PROCEDURE WIP_COMP_ISSUE (
                             p_job_name           IN VARCHAR2,
                             p_item               IN VARCHAR2,
                             p_revision           IN VARCHAR2,
                             p_subinventory       IN VARCHAR2,
                             p_locator            IN VARCHAR2,
                             p_lot_number         IN VARCHAR2,
                             p_serial_number      IN VARCHAR2,
                             p_transaction_uom    IN VARCHAR2,
                             p_transaction_qty    IN NUMBER,
                             p_transaction_date   IN VARCHAR2,
                             p_op_seq_num         IN NUMBER,
                             p_reason_code        IN VARCHAR2,
                             p_collection_id      IN NUMBER,
                             p_occurrence         IN NUMBER,
                             p_organization_code  IN VARCHAR2,
                             p_plan_name          IN VARCHAR2,
                             p_launch_action      IN VARCHAR2,
                             p_action_fired       IN VARCHAR2);


  FUNCTION WIP_MATERIAL_TXN_INT(
                                p_job_name          VARCHAR2,
                                p_item_id           NUMBER,
                                p_revision          VARCHAR2,
                                p_subinventory      VARCHAR2,
                                p_locator_id        NUMBER,
                                p_lot_number        VARCHAR2,
                                p_serial_number     VARCHAR2,
                                p_transaction_uom   VARCHAR2,
                                p_transaction_qty   NUMBER,
                                p_transaction_date  DATE,
                                p_op_seq_num        NUMBER,
                                p_reason_id         NUMBER,
                                p_source_code       VARCHAR2,
                                p_txn_type_id       NUMBER,
                                p_txn_action_id     NUMBER,
                                p_collection_id     NUMBER,
                                p_occurrence        NUMBER,
                                p_organization_id   NUMBER)
  RETURN NUMBER;

  PROCEDURE WIP_MOVE_TXN(
      		     p_item               IN VARCHAR2,
                     p_job_name           IN VARCHAR2,
                     p_from_op_seq        IN NUMBER,
                     p_from_intra_step    IN VARCHAR2,
                     p_to_op_seq          IN NUMBER,
                     p_to_intra_step      IN VARCHAR2,
                     p_fm_op_code         IN VARCHAR2,
                     p_to_op_code         IN VARCHAR2,
                     p_reason_name        IN VARCHAR2,
                     p_uom                IN VARCHAR2,
                     p_quantity           IN NUMBER,
                     p_txn_date           IN VARCHAR2,
                     p_collection_id      IN NUMBER,
                     p_occurrence         IN NUMBER,
                     p_organization_code  IN VARCHAR2,
                     p_plan_name          IN VARCHAR2,
                     p_launch_action      IN VARCHAR2,
                     p_action_fired       IN VARCHAR2);


  PROCEDURE REWORK_ADD_OPERATION(
                     p_job_name           IN VARCHAR2,
                     p_op_seq_num         IN NUMBER,
                     p_operation_code     IN VARCHAR2,
                     p_department_code    IN VARCHAR2,
                     p_res_seq_num        IN NUMBER,
                     p_resource_code      IN VARCHAR2,
                     p_assigned_units     IN NUMBER,
                     p_usage_rate         IN NUMBER,
                     p_start_date         IN VARCHAR2,
                     p_end_date           IN VARCHAR2,
                     p_collection_id      IN NUMBER,
                     p_occurrence         IN NUMBER,
                     p_organization_code  IN VARCHAR2,
                     p_plan_name          IN VARCHAR2,
                     p_launch_action      IN VARCHAR2,
                     p_action_fired       IN VARCHAR2);

  FUNCTION REWORK_OP_ADD_OP_INT(
                     p_group_id         NUMBER,
                     p_job_name         VARCHAR2,
                     p_wip_entity_id    NUMBER,
                     p_op_seq_num       NUMBER,
                     p_operation_id     NUMBER,
                     p_department_id    NUMBER,
                     p_start_date       DATE,
                     p_end_date         DATE,
                     p_organization_id  NUMBER,
                     p_status_type      NUMBER)
  RETURN NUMBER;

  FUNCTION REWORK_OP_ADD_RES_INT(
                     p_group_id         NUMBER,
                     p_job_name         VARCHAR2,
                     p_wip_entity_id    NUMBER,
                     p_op_seq_num       NUMBER,
                     p_operation_id     NUMBER,
                     p_department_id    NUMBER,
                     p_res_seq_num      NUMBER,
                     p_resource_id      NUMBER,
                     p_assigned_units   NUMBER,
                     p_usage_rate       NUMBER,
                     p_organization_id  NUMBER,
                     p_op_type          NUMBER,
                     p_status_type      NUMBER)
  RETURN NUMBER;



  PROCEDURE UPDATE_STATUS(p_plan_id       IN NUMBER,
                          p_collection_id IN NUMBER,
                          p_occurrence    IN NUMBER);


  PROCEDURE WRITE_BACK(p_plan_id                        IN NUMBER,
                       p_collection_id                  IN NUMBER,
                       p_occurrence                     IN NUMBER,
                       p_status                         IN VARCHAR2,
                       p_mti_transaction_header_id      IN NUMBER DEFAULT NULL,
                       p_mti_transaction_interface_id   IN NUMBER DEFAULT NULL,
                       p_mmt_transaction_id             IN NUMBER DEFAULT NULL,
                       p_wmti_group_id                  IN NUMBER DEFAULT NULL,
                       p_wmt_transaction_id             IN NUMBER DEFAULT NULL,
                       p_rti_interface_transaction_id   IN NUMBER DEFAULT NULL,
                       p_job_id				IN NUMBER DEFAULT NULL,
                       p_wjsi_group_id                  IN NUMBER DEFAULT NULL,
                       p_request_id                     IN NUMBER DEFAULT NULL,
                       p_message                        IN VARCHAR2 DEFAULT NULL,
                       p_move_order_number              IN VARCHAR2 DEFAULT NULL,
                       p_eco_name                       IN VARCHAR2 DEFAULT NULL);



END QA_SOLUTION_DISPOSITION_PKG;


/
