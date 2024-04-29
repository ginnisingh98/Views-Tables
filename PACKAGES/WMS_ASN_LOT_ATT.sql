--------------------------------------------------------
--  DDL for Package WMS_ASN_LOT_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ASN_LOT_ATT" AUTHID CURRENT_USER AS
/* $Header: WMSINTLS.pls 115.2 2002/12/01 04:05:04 rbande ship $ */

-- Record Type for the lot number attributes columns
TYPE lot_sel_attributes_rec_type IS RECORD
(
        COLUMN_NAME     VARCHAR2(50)    :=NULL
,       COLUMN_TYPE     VARCHAR2(20)    :=NULL
,       COLUMN_VALUE    fnd_descr_flex_col_usage_vl.default_value%TYPE :=NULL
,       REQUIRED        VARCHAR2(10)    :='NULL'
,       PROMPT          VARCHAR2(100)   :=NULL
,       COLUMN_LENGTH   NUMBER          :=NULL
);

-- Table type definition for an array of cb_chart_status_rec_type records.
TYPE lot_sel_attributes_tbl_type is TABLE OF lot_sel_attributes_rec_type
 INDEX BY BINARY_INTEGER;

TYPE n_attribute_table_type IS TABLE OF mtl_lot_numbers.n_attribute1%TYPE INDEX BY BINARY_INTEGER;
TYPE d_attribute_table_type IS TABLE OF mtl_lot_numbers.d_attribute1%TYPE INDEX BY BINARY_INTEGER;
TYPE c_attribute_table_type IS TABLE OF mtl_lot_numbers.c_attribute1%TYPE INDEX BY BINARY_INTEGER;

g_lot_attributes_tbl    lot_sel_attributes_tbl_type;

g_serial_attributes_tbl lot_sel_attributes_tbl_type;


--
-- Validate Lot sets the default values
-- validates and inserts rows into
-- mtl_lot_numbers from wms_lpn_contents_interface
--

procedure validate_lot (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_interface_transaction_id    IN  NUMBER
);

PROCEDURE insert_range_serial
  (p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_inventory_item_id  IN NUMBER,
   p_organization_id    IN NUMBER,
   p_from_serial_number IN VARCHAR2,
   p_to_serial_number   IN VARCHAR2,
   p_initialization_date IN DATE,
   p_completion_date    IN DATE,
   p_ship_date          IN DATE,
   p_revision           IN VARCHAR2,
   p_lot_number         IN VARCHAR2,
   p_current_locator_id IN NUMBER,
   p_subinventory_code  IN VARCHAR2,
   p_trx_src_id         IN NUMBER,
   p_unit_vendor_id     IN NUMBER,
   p_vendor_lot_number  IN VARCHAR2,
   p_vendor_serial_number IN VARCHAR2,
   p_receipt_issue_type IN NUMBER,
   p_txn_src_id         IN NUMBER,
   p_txn_src_name       IN VARCHAR2,
   p_txn_src_type_id    IN NUMBER,
   p_transaction_id         IN NUMBER,
   p_current_status     IN NUMBER,
   p_parent_item_id     IN NUMBER,
   p_parent_serial_number IN VARCHAR2,
   p_cost_group_id      IN NUMBER,
   p_serial_transaction_intf_id IN NUMBER,
   p_status_id         IN NUMBER,
   p_inspection_status IN NUMBER,
   x_object_id          OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2)
;

end WMS_ASN_LOT_ATT;

 

/
