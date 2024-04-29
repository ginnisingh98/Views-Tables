--------------------------------------------------------
--  DDL for Package INV_LABEL_PVT5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL_PVT5" AUTHID CURRENT_USER AS
/* $Header: INVLAP5S.pls 120.0.12010000.2 2009/11/26 12:21:31 abasheer ship $ */
G_PKG_NAME	CONSTANT VARCHAR2(50) := 'INV_LABEL_PVT5';

TYPE lpn_data_type_rec is RECORD
(
  lpn					VARCHAR2(30)
, parent_lpn_id   NUMBER
, parent_lpn      VARCHAR2(30)
, outermost_lpn   VARCHAR2(30)
, container_item_id NUMBER
, container_item  VARCHAR2(40)
, volume          NUMBER
, volume_uom      VARCHAR2(3)
, gross_weight			NUMBER
, gross_weight_uom   VARCHAR2(3)
, tare_weight    	NUMBER
, tare_weight_uom VARCHAR2(3)
, lpn_attribute_category VARCHAR2(30)
, lpn_attribute1         VARCHAR2(150)
, lpn_attribute2         VARCHAR2(150)
, lpn_attribute3         VARCHAR2(150)
, lpn_attribute4         VARCHAR2(150)
, lpn_attribute5         VARCHAR2(150)
, lpn_attribute6         VARCHAR2(150)
, lpn_attribute7         VARCHAR2(150)
, lpn_attribute8         VARCHAR2(150)
, lpn_attribute9         VARCHAR2(150)
, lpn_attribute10        VARCHAR2(150)
, lpn_attribute11        VARCHAR2(150)
, lpn_attribute12        VARCHAR2(150)
, lpn_attribute13        VARCHAR2(150)
, lpn_attribute14        VARCHAR2(150)
, lpn_attribute15        VARCHAR2(150)
, parent_package NUMBER
, pack_level  NUMBER
);

TYPE item_data_type_rec is RECORD
(
  organization            VARCHAR2(3)
, item    					  VARCHAR2(40)
, client_item    					  VARCHAR2(40)       	-- Added for LSP Project, bug 9087971
, item_description 		  VARCHAR2(240)
, item_attribute_category VARCHAR2(30)
, item_attribute1         VARCHAR2(150)
, item_attribute2         VARCHAR2(150)
, item_attribute3         VARCHAR2(150)
, item_attribute4         VARCHAR2(150)
, item_attribute5         VARCHAR2(150)
, item_attribute6         VARCHAR2(150)
, item_attribute7         VARCHAR2(150)
, item_attribute8         VARCHAR2(150)
, item_attribute9         VARCHAR2(150)
, item_attribute10        VARCHAR2(150)
, item_attribute11        VARCHAR2(150)
, item_attribute12        VARCHAR2(150)
, item_attribute13        VARCHAR2(150)
, item_attribute14        VARCHAR2(150)
, item_attribute15        VARCHAR2(150)

, lot_expiration_date  	  VARCHAR2(100) -- Changed for bug 2977490
, item_hazard_class 		  VARCHAR2(40)
, lot_attribute_category  VARCHAR2(30)
, lot_c_attribute1	VARCHAR2(150)
, lot_c_attribute2	VARCHAR2(150)
, lot_c_attribute3	VARCHAR2(150)
, lot_c_attribute4	VARCHAR2(150)
, lot_c_attribute5	VARCHAR2(150)
, lot_c_attribute6	VARCHAR2(150)
, lot_c_attribute7	VARCHAR2(150)
, lot_c_attribute8	VARCHAR2(150)
, lot_c_attribute9	VARCHAR2(150)
, lot_c_attribute10	VARCHAR2(150)
, lot_c_attribute11	VARCHAR2(150)
, lot_c_attribute12	VARCHAR2(150)
, lot_c_attribute13	VARCHAR2(150)
, lot_c_attribute14	VARCHAR2(150)
, lot_c_attribute15	VARCHAR2(150)
, lot_c_attribute16	VARCHAR2(150)
, lot_c_attribute17	VARCHAR2(150)
, lot_c_attribute18	VARCHAR2(150)
, lot_c_attribute19	VARCHAR2(150)
, lot_c_attribute20	VARCHAR2(150)
, lot_d_attribute1	VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute2   VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute3   VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute4   VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute5   VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute6   VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute7   VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute8   VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute9   VARCHAR2(100) -- Changed for bug 2977490
, lot_d_attribute10  VARCHAR2(100) -- Changed for bug 2977490
, lot_n_attribute1   NUMBER
, lot_n_attribute2   NUMBER
, lot_n_attribute3   NUMBER
, lot_n_attribute4   NUMBER
, lot_n_attribute5   NUMBER
, lot_n_attribute6   NUMBER
, lot_n_attribute7   NUMBER
, lot_n_attribute8   NUMBER
, lot_n_attribute9   NUMBER
, lot_n_attribute10  NUMBER
, lot_country_of_origin 	VARCHAR2(30)
, lot_grade_code 				VARCHAR2(150)
, lot_origination_date  	VARCHAR2(100) -- Changed for bug 2977490
, lot_date_code            VARCHAR2(150)
, lot_change_date				VARCHAR2(100) -- Changed for bug 2977490
, lot_age                  NUMBER
, lot_retest_date          VARCHAR2(100) -- Changed for bug 2977490
, lot_maturity_date			VARCHAR2(100) -- Changed for bug 2977490
, lot_item_size				NUMBER
, lot_color                VARCHAR2(150)
, lot_volume               NUMBER
, lot_volume_uom           VARCHAR2(3)
, lot_place_of_origin    	VARCHAR2(150)
, lot_best_by_date         VARCHAR2(100) -- Changed for bug 2977490
, lot_length               NUMBER
, lot_length_uom           VARCHAR2(3)
, lot_recycled_cont     	NUMBER
, lot_thickness            NUMBER
, lot_thickness_uom        VARCHAR2(3)
, lot_width                NUMBER
, lot_width_uom            VARCHAR2(3)
, lot_curl             		VARCHAR2(150)
, lot_vendor					VARCHAR2(240)
, lot_number_status      	VARCHAR2(80)
, parent_lot_number      VARCHAR2(80) -- incovn changes start
, expiration_action_date DATE
, origination_type       NUMBER(2)
, hold_date              DATE
, expiration_action_code VARCHAR2(32)
, supplier_lot_number    VARCHAR2(150) -- incovn changes start
);


-- Record type to hold LPN information for RCV flows : J-DEV
TYPE rcv_label_type_rec is RECORD
(
     lpn_id                  NUMBER
   , purchase_order          VARCHAR2(20)
   , subinventory            VARCHAR2(30)
   , locator_id              NUMBER
   , receipt_num             VARCHAR2(30)
   , po_line_num             NUMBER
   , quantity_ordered        NUMBER
   , supplier_part_number    VARCHAR2(25)
   , vendor_id               NUMBER
   , supplier_name           VARCHAR2(240)
   , vendor_site_id          NUMBER
   , supplier_site           VARCHAR2(15)
   , requestor               VARCHAR2(240)
   , deliver_to_location     VARCHAR2(60)
   , location                VARCHAR2(60)
   , note_to_receiver        VARCHAR2(480)
   -- Following fields for iSP
   , due_date                DATE
   , truck_num               VARCHAR2(35)
   , country_of_origin       VARCHAR2(2)
   , comments                VARCHAR2(240)
   -- Added for Bug 3581021 by joabraha
   , item_id                 NUMBER
   --
	, packing_slip             VARCHAR2(25)
);

-- Table to hold information for a group of LPNs
TYPE rcv_label_tbl_type IS TABLE OF rcv_label_type_rec INDEX BY BINARY_INTEGER;

-- Record type to hold LPN information specific to iSupplierPortal
TYPE rcv_isp_header_rec is RECORD
(
     asn_num                 VARCHAR2(30),
     shipment_date           DATE,
     expected_receipt_date   DATE,
     freight_terms           VARCHAR2(25),
     freight_carrier         VARCHAR2(25),
     num_of_containers       NUMBER,
     bill_of_lading          VARCHAR2(25),
     waybill_airbill_num     VARCHAR2(20),
     packing_slip            VARCHAR2(25),
     packaging_code          VARCHAR2(5),
     special_handling_code   VARCHAR2(3),
     locator_id              NUMBER,
     receipt_num             VARCHAR2(30),
     comments                VARCHAR2(240)
);



PROCEDURE get_variable_data(
	x_variable_content 	OUT NOCOPY LONG
,	x_msg_count		OUT NOCOPY  NUMBER
,	x_msg_data		OUT NOCOPY  VARCHAR2
,	x_return_status		OUT NOCOPY  VARCHAR2
,	p_label_type_info	IN INV_LABEL.label_type_rec DEFAULT NULL
,	p_transaction_id	IN NUMBER DEFAULT NULL
,	p_input_param		IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE DEFAULT NULL
,	p_lpn_id			IN NUMBER DEFAULT NULL
,p_transaction_identifier IN NUMBER DEFAULT 0);

PROCEDURE get_variable_data(
	x_variable_content 	OUT NOCOPY  INV_LABEL.label_tbl_type
,	x_msg_count		OUT NOCOPY  NUMBER
,	x_msg_data		OUT NOCOPY  VARCHAR2
,	x_return_status		OUT NOCOPY  VARCHAR2
,	p_label_type_info	IN INV_LABEL.label_type_rec DEFAULT NULL
,	p_transaction_id	IN NUMBER DEFAULT NULL
,	p_input_param		IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE DEFAULT NULL
,	p_lpn_id			IN NUMBER DEFAULT NULL
,p_transaction_identifier IN NUMBER DEFAULT 0);

FUNCTION get_variable_name(p_column_name IN VARCHAR2,
		p_row_index IN NUMBER, p_format_id IN NUMBER) RETURN VARCHAR2;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  This function get_sql_for_variable() is newly added for the Custom Labels project to     |
--  fetch the SQL statement from the PL/SQL table.                                           |
---------------------------------------------------------------------------------------------
FUNCTION get_sql_for_variable(p_column_name IN VARCHAR2,
		p_row_index IN NUMBER, p_format_id IN NUMBER) RETURN VARCHAR2;

END INV_LABEL_PVT5;

/
