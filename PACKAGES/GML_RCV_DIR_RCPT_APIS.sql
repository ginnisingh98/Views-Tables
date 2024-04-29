--------------------------------------------------------
--  DDL for Package GML_RCV_DIR_RCPT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_RCV_DIR_RCPT_APIS" AUTHID CURRENT_USER AS
/* $Header: GMLDIRDS.pls 120.0 2005/05/25 16:45:31 appldev noship $*/

/*******************************************************
*  Name: create_direct_rti_rec
*
*  Description:
*
*  This API create record in RCV_TRANSACTIONS_INTERFACE for
*  direct delivery transaction.
*
*  This API takes PO_header_id, item_id, received_qty, received_UOM,
*  received_location, deliver to subinventory and deliver to locator
*  as input. It calls the matching algorithm API
*  to detail the receipt to PO_line_locations.
*
*  Then it calls insert API, insert_txn_interface, to inserts PO line
*  location record into RCV_TRANSACTION_INTERFACE
*
*  Flow:
*
*  1. query po_startup_value and other initial values
*  2. query a join of RCV_ENTER_RECEIPTS_V and PO_DISTRIBUTIONS table
*     to populate DB items in rcv_transaction block
*     before calling matching algorithm
*  3. call matching algorithm to detail the receipt
*  4. call insert API
*
*  Parameters:
*
*  p_organization_id
*  p_po_header_id
*  p_item_id
*  p_location_id
*  p_rcv_qty
*  p_rcv_uom
*  p_source_type
*  p_subinventory
*  p_locator_id
*
*******************************************************/
PROCEDURE create_direct_rti_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
				p_organization_id IN NUMBER,
				p_po_header_id IN NUMBER,
				p_po_release_id IN NUMBER,
				p_po_line_id IN NUMBER,
				p_shipment_header_id IN NUMBER,
				p_oe_order_header_id IN NUMBER,
				p_item_id IN NUMBER,
				p_rcv_qty IN NUMBER,
				p_rcv_sec_qty IN NUMBER,
				p_rcv_uom IN VARCHAR2,
				p_rcv_uom_code IN VARCHAR2,
				p_rcv_sec_uom IN VARCHAR2,
				p_rcv_sec_uom_code IN VARCHAR2,
				p_source_type IN VARCHAR2,
				p_subinventory IN VARCHAR2,
				p_locator_id IN NUMBER,
				p_transaction_temp_id IN NUMBER,
				p_lot_control_code IN NUMBER,
				p_serial_control_code IN NUMBER,
				p_lpn_id IN NUMBER,
				p_revision IN VARCHAR2,
				x_status   OUT NOCOPY VARCHAR2,
				x_message  OUT NOCOPY VARCHAR2,
				p_inv_item_id IN NUMBER DEFAULT NULL,
				p_item_desc IN VARCHAR2 DEFAULT NULL,
				p_location_id IN NUMBER DEFAULT NULL,
				p_is_expense IN VARCHAR2 DEFAULT NULL,
				p_project_id IN NUMBER DEFAULT NULL,
				p_task_id IN NUMBER DEFAULT NULL,
                                p_country_code IN VARCHAR2 DEFAULT NULL);


--PROCEDURE pack_lpn_txn;

-- MANEESH - BEGIN CHANGES - FOR OUTSIDE PROCESSING ITEM

PROCEDURE create_osp_direct_rti_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
				    p_organization_id IN NUMBER,
				    p_po_header_id IN NUMBER,
				    p_po_release_id IN NUMBER,
				    p_po_line_id IN NUMBER,
				    p_item_id IN NUMBER,
				    p_rcv_qty IN NUMBER,
				    p_rcv_uom IN VARCHAR2,
				    p_rcv_uom_code IN VARCHAR2,
				    p_source_type IN VARCHAR2,
				    p_transaction_temp_id IN NUMBER,
				    p_revision IN VARCHAR2,
				    p_po_distribution_id IN NUMBER,
				    x_status OUT NOCOPY VARCHAR2,
				    x_message OUT NOCOPY VARCHAR2);

-- MANEESH - END CHANGES - FOR OUTSIDE PROCESSING ITEM

END gml_rcv_dir_rcpt_apis;

 

/
