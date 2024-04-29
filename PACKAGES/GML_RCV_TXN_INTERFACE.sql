--------------------------------------------------------
--  DDL for Package GML_RCV_TXN_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_RCV_TXN_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: GMLTISVS.pls 120.1 2005/06/03 13:18:10 appldev  $*/


TYPE cascaded_trans_rec_type IS RECORD
  (
   customer_id NUMBER,
   error_message VARCHAR2(255),
   error_status VARCHAR2(1),
   expected_receipt_date DATE,
   from_organization_id NUMBER,
   group_id NUMBER,
   item_id NUMBER,
   locator_id NUMBER,
   oe_order_header_id NUMBER,
   oe_order_line_id NUMBER,
   parent_transaction_id NUMBER,
   po_distribution_id NUMBER,
   po_header_id NUMBER,
   po_line_id NUMBER,
   po_line_location_id NUMBER,
   po_release_id NUMBER,
   primary_quantity NUMBER,
   primary_unit_of_measure VARCHAR2(25),
   qty_rcv_exception_code VARCHAR2(25),
   quantity NUMBER,
   quantity_shipped NUMBER,
   revision VARCHAR2(3),
   ship_to_location_id NUMBER,
   shipment_header_id NUMBER,
   shipment_line_id NUMBER,
   source_doc_quantity NUMBER,
   source_doc_unit_of_measure VARCHAR2(25),
   subinventory VARCHAR2(10),
   tax_amount NUMBER,
   to_organization_id NUMBER,
   transaction_type VARCHAR2(25),
   unit_of_measure VARCHAR2(25),
   inspection_status_code VARCHAR2(25),
   p_lpn_id NUMBER,
   item_desc VARCHAR2(240),
   project_id number default null,
   task_id   number  default null,
   lot_number mtl_lot_numbers.lot_number%TYPE DEFAULT NULL,
   secondary_quantity rcv_transactions_interface.SECONDARY_QUANTITY%TYPE,
   secondary_unit_of_measure rcv_transactions_interface.SECONDARY_UNIT_OF_MEASURE%TYPE
   );

TYPE cascaded_trans_tab_type IS TABLE OF cascaded_trans_rec_type
  INDEX BY BINARY_INTEGER;

PROCEDURE matching_logic
  (x_return_status                   OUT nocopy VARCHAR2,
   x_msg_count                       OUT nocopy NUMBER,
   x_msg_data                        OUT nocopy VARCHAR2,
   x_cascaded_table               IN OUT nocopy cascaded_trans_tab_type,
   n                              IN OUT nocopy  binary_integer,
   temp_cascaded_table            IN OUT nocopy cascaded_trans_tab_type,
   p_receipt_num                     IN   VARCHAR2,
   p_shipment_header_id              IN   NUMBER,  -- this parameter is for ASN only, should leave it NULL for PO receipt
   p_lpn_id                          IN   NUMBER -- this parameter is for ASN only, should leave it NULL for PO receipt
   );

END GML_RCV_TXN_INTERFACE;

 

/
