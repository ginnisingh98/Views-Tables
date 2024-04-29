--------------------------------------------------------
--  DDL for Package WMS_PACKING_WORKBENCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PACKING_WORKBENCH_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSPACVS.pls 120.2.12010000.2 2010/04/12 23:50:47 sfulzele ship $ */

/*******************************
Variable Types
********************************/

TYPE kit_rec_type IS RECORD(
    kit_item_id NUMBER
,   top_model_line_id NUMBER
,   exist_flag VARCHAR2(1)
,   identified_flag VARCHAR2(1)
);
TYPE kit_tbl_type IS TABLE OF kit_rec_type INDEX BY BINARY_INTEGER;

TYPE kit_component_rec_type IS RECORD(
    kit_item_id NUMBER
,   component_item_id NUMBER
,   packed_qty NUMBER
,   packed_qty_disp VARCHAR2(20)
);
TYPE kit_component_tbl_type IS TABLE OF kit_component_rec_type INDEX BY BINARY_INTEGER;

TYPE move_order_rec_type is RECORD
(
    move_order_line_id		        NUMBER
,   transaction_quantity	        NUMBER
,   transaction_uom                     VARCHAR2(3)
,   primary_quantity                    NUMBER
,   secondary_transaction_quantity	NUMBER      --INVCONV kkillams
,   secondary_uom_code                  VARCHAR2(3) --INVCONV kkillams
,   grade_code                          VARCHAR2(150) --INVCONV kkillams
);
TYPE move_order_tbl_type IS TABLE OF move_order_rec_type INDEX BY BINARY_INTEGER;
l_null_mol_list move_order_tbl_type;

TYPE mmtt_mtlt_rec_type IS RECORD
(
    move_order_line_id             NUMBER
,   inventory_item_id              NUMBER
,   revision                       VARCHAR2(3)
,   transaction_quantity           NUMBER
,   transaction_uom                VARCHAR2(3)
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
,   lot_number                     VARCHAR2(80)
,   serial_transaction_temp_id     NUMBER
,   secondary_uom_code             VARCHAR2(3)  --INVCONV kkillams
,   secondary_transaction_quantity NUMBER  --INVCONV kkillams

);
l_null_rec mmtt_mtlt_rec_type;

/*********************************
Procedure to query the eligible material for pack/split/unpack transactions
For inbound, it queries move order lines
For outbound, it queries delivery detail lines
After it finds results, it populates global temp table
  WMS_PACKING_MATERIAL_GTEMP to display on the spreadtable on packing workbench form

Input Parameter:
p_source_id: 1=>Inbound, 2=>Outbound

The following input parameters applies for both inbound and outbound
p_organization_id: Organization
p_subinventory_code: Subinventory
p_locator_id: ID for Locator
p_inventory_item_id: ID for Item
p_from_lpn_id: ID for From LPN
p_project_id: ID for Project
p_task_id: ID for Task

The following parameters applies for inbound
p_document_type: 'ASN', 'INTSHIP', 'PO', 'REQ', 'RMA'
p_document_id: ID for inbound document
p_document_line_id: ID for inbound document line
p_receipt_number: Receipt number
p_partner_id: it can be vendor_id or internal org_id
p_partner_type: 1=> Vendor, 2=> Internal Organization
p_rcv_location_id: ID for receiving location

The following parameters applies for outbound
p_delivery_id: ID for delivery
p_order_header_id: ID for sales order header
p_carrier_id: ID for carrier
p_trip_id: ID for Trip
p_delivery_state: 'Y'=> Deliveries that are completed packed
                  'N"=> Deliveries that are not completed packed
                  NULL=> all deliveries
p_customer_id: ID for customer
*********************************/
PROCEDURE query_eligible_material(
     x_return_status OUT NOCOPY VARCHAR2
,    p_source_id IN NUMBER
,    p_organization_id IN NUMBER
,    p_organization_code IN VARCHAR2
,    p_subinventory_code IN VARCHAR2 DEFAULT NULL
,    p_locator_id IN NUMBER DEFAULT NULL
,    p_locator IN VARCHAR2 DEFAULT NULL
,    p_inventory_item_id IN NUMBER DEFAULT NULL
,    p_item IN VARCHAR2 DEFAULT NULL
,    p_from_lpn_id IN NUMBER DEFAULT NULL
,    p_project_id IN NUMBER DEFAULT NULL
,    p_project IN VARCHAR2 DEFAULT NULL
,    p_task_id IN NUMBER DEFAULT NULL
,    p_task IN VARCHAR2 DEFAULT NULL
,    p_document_type IN VARCHAR2 DEFAULT NULL
,    p_document_id IN NUMBER DEFAULT NULL
,    p_document_number IN VARCHAR2 DEFAULT NULL
,    p_document_line_id IN NUMBER DEFAULT NULL
,    p_document_line_num IN VARCHAR2 DEFAULT NULL--CLM PO Line number can be a VARCHAR
,    p_receipt_number IN VARCHAR2 DEFAULT NULL
,    p_partner_id IN NUMBER DEFAULT NULL
,    p_partner_type IN NUMBER DEFAULT NULL
,    p_partner_name IN VARCHAR2 DEFAULT NULL
,    p_rcv_location_id IN NUMBER DEFAULT NULL
,    p_rcv_location IN VARCHAR2 DEFAULT NULL
,    p_delivery_id IN NUMBER DEFAULT NULL
,    p_delivery IN VARCHAR2 DEFAULT NULL
,    p_order_header_id IN NUMBER DEFAULT NULL
,    p_order_number IN VARCHAR2 DEFAULT NULL
,    p_order_type  IN VARCHAR2 DEFAULT NULL
,    p_carrier_id IN NUMBER DEFAULT NULL
,    p_carrier IN VARCHAR2 DEFAULT NULL
,    p_trip_id IN NUMBER DEFAULT NULL
,    p_trip IN VARCHAR2 DEFAULT NULL
,    p_delivery_state IN VARCHAR2 DEFAULT NULL
,    p_customer_id IN NUMBER DEFAULT NULL
,    p_customer IN VARCHAR2 DEFAULT NULL
,    p_is_pjm_enabled_org IN VARCHAR2 DEFAULT 'N'
,    x_source_unique OUT nocopy VARCHAR2
  );


/*******************************************
 * Procedure to create MMTT/MTLT/MSNT record
 * For a pack/split/unpack transaction
 *******************************************/
PROCEDURE create_txn(
     x_return_status OUT NOCOPY VARCHAR2
,    x_proc_msg OUT NOCOPY VARCHAR2
,    p_source IN NUMBER
,    p_pack_process IN NUMBER
,    p_organization_id IN NUMBER
,    p_inventory_item_id IN NUMBER DEFAULT NULL
,    p_primary_uom IN VARCHAR2 DEFAULT NULL
,    p_revision IN VARCHAR2 DEFAULT NULL
,    p_lot_number IN VARCHAR2 DEFAULT NULL
,    p_lot_expiration_date IN DATE DEFAULT NULL
,    p_fm_serial_number IN VARCHAR2 DEFAULT NULL
,    p_to_serial_number IN VARCHAR2 DEFAULT NULL
,    p_from_lpn_id IN NUMBER DEFAULT NULL
,    p_content_lpn_id IN NUMBER DEFAULT NULL
,    p_to_lpn_id IN NUMBER DEFAULT NULL
,    p_subinventory_code IN VARCHAR2 DEFAULT NULL
,    p_locator_id IN NUMBER DEFAULT NULL
,    p_to_subinventory IN VARCHAR2 DEFAULT NULL
,    p_to_locator_id IN NUMBER DEFAULT NULL
,    p_project_id IN NUMBER DEFAULT NULL
,    p_task_id IN NUMBER DEFAULT NULL
,    p_transaction_qty IN NUMBER DEFAULT NULL
,    p_transaction_uom IN VARCHAR2 DEFAULT NULL
,    p_primary_qty IN NUMBER DEFAULT NULL
,    p_secondary_qty IN NUMBER DEFAULT NULL
,    p_secondary_uom IN VARCHAR2 DEFAULT NULL
,    p_transaction_header_id IN NUMBER DEFAULT NULL
,    p_transaction_temp_id IN NUMBER DEFAULT NULL
,    x_transaction_header_id OUT NOCOPY NUMBER
,    x_transaction_temp_id OUT NOCOPY NUMBER
,    x_serial_transaction_temp_id OUT NOCOPY NUMBER
,    p_grade_code IN VARCHAR2 DEFAULT NULL --INVCONV kkillams
);

/*******************************************
 * Procedure to delete MMTT/MTLT/MSNT record
 * For a pack/split/unpack transaction
 * This is used when user choose to do a UNDO
 *******************************************/
PROCEDURE delete_txn(
     x_return_status OUT NOCOPY VARCHAR2
,    x_msg_count OUT NOCOPY NUMBER
,    x_msg_data OUT NOCOPY VARCHAR2
,    p_transaction_header_id IN NUMBER
,    p_transaction_temp_id IN NUMBER
,    p_lot_number IN VARCHAR2 DEFAULT NULL
,    p_serial_number IN VARCHAR2 DEFAULT NULL
,    p_quantity IN NUMBER DEFAULT NULL
,    p_uom IN VARCHAR2 DEFAULT NULL
);

/*******************************************
 * Procedure to call transaction manager
 * to process the MMTT records
 * This is used when user close a LPN
   *******************************************/
PROCEDURE process_txn(
     p_source IN NUMBER
,    p_trx_hdr_id IN NUMBER
,    x_return_status OUT NOCOPY VARCHAR2
,    x_proc_msg OUT NOCOPY VARCHAR2);

/*******************************************************
 * Procedure to Firm Delivery for delivery merge purpose
 *******************************************************/
PROCEDURE firm_delivery(
     p_delivery_id IN NUMBER
,    x_return_status OUT NOCOPY VARCHAR2
,    x_proc_msg OUT NOCOPY VARCHAR2);

/**************************************
 * Procedure to get kitting information
 *  for a item and quantity
 **************************************/
PROCEDURE get_kitting_info(
    x_return_status OUT NOCOPY VARCHAR2
,   x_msg_data OUT NOCOPY VARCHAR2
,   x_msg_count OUT NOCOPY VARCHAR2
,   p_organization_id IN NUMBER
,   p_inventory_item_id IN NUMBER
,   p_quantity IN NUMBER);

/*************************************
 * Function to indicate whether the kit
 *  has been identified as the current kit for packing
 ************************************/
FUNCTION is_kit_identified(p_kit_id IN NUMBER) RETURN VARCHAR2;


/*************************************
 * Function to indicate whether the item
 * is unique across all the kits in the list of kits scanned so far
 ************************************/

 FUNCTION is_item_unique_existing_kit(p_component_id IN NUMBER) RETURN NUMBER;

/**********************************
 * Procedure to issue savepoint
 * This is called from the form/library
 * The savepoint can be set currently are
 *   PACK_START
 *   BEFORE_TM
 **************************************/
PROCEDURE issue_savepoint(p_savepoint VARCHAR2);
/**********************************
 * Procedure to issue rollback to savepoint
 * This is called from the form/library
 * The savepoint can be rollback currently are
 *   PACK_START
 *   BEFORE_TM
 *   NULL : Rollback everything
 **************************************/
PROCEDURE issue_rollback(p_savepoint VARCHAR2);
/**********************************
 * Procedure to issue commit
 * This is called from the form/library
**************************************/
PROCEDURE issue_commit;
/***********************************
 * Global Variables                *
 **********************************/
/* Organization ID */
ORG_ID NUMBER;

/* For debug profile */
l_debug NUMBER := 0;



END WMS_PACKING_WORKBENCH_PVT;

/
