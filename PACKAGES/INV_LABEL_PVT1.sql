--------------------------------------------------------
--  DDL for Package INV_LABEL_PVT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL_PVT1" AUTHID CURRENT_USER AS
/* $Header: INVLAP1S.pls 120.0.12010000.1 2008/07/24 01:37:35 appldev ship $ */
G_PKG_NAME	CONSTANT VARCHAR2(50) := 'INV_LABEL_PVT1';

-- Bug 2355294
-- When rti rows are split need to get the right qty for MSCA org
TYPE rcv_label_print_rec IS RECORD
   ( interface_transaction_id NUMBER,
     lot_number VARCHAR2(100),
     item_rev VARCHAR2(3)
   );

TYPE rcv_label_print_rec_tb_tp IS TABLE OF rcv_label_print_rec
   INDEX BY BINARY_INTEGER;

g_rcv_label_print_rec_tb rcv_label_print_rec_tb_tp;
-- End Bug 2355294

-- Added p_transaction_identifier, for flow
	-- Depending on when it is called, the driving table might be different
	-- 1 means MMTT is the driving table
	-- 2 means MTI is the driving table
-- 3 means Mtl_txn_request_lines is the driving table

/*****************************************************************************
 *  This function is used for printing labels at receiving                   *
 *  This function adds all the interface transaction ID's to the PL/SQL table*
 *  which means that any interface transaction ID existing in this table is  *
 *  already printed.                                                         *
 *****************************************************************************/
FUNCTION check_rti_id(p_rti_id IN NUMBER,
                      p_lot_number IN VARCHAR2 DEFAULT NULL,
                      p_rev   IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

PROCEDURE get_variable_data(
	x_variable_content 	OUT NOCOPY  LONG
,	x_msg_count		OUT NOCOPY  NUMBER
,	x_msg_data		OUT NOCOPY  VARCHAR2
,	x_return_status		OUT NOCOPY  VARCHAR2
,	p_label_type_info	IN INV_LABEL.label_type_rec DEFAULT NULL
,	p_transaction_id	IN NUMBER DEFAULT NULL
,	p_input_param		IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE DEFAULT NULL
,	p_transaction_identifier IN NUMBER DEFAULT 0
);

PROCEDURE get_variable_data(
	x_variable_content 	OUT NOCOPY  INV_LABEL.label_tbl_type
,	x_msg_count		OUT NOCOPY  NUMBER
,	x_msg_data		OUT NOCOPY  VARCHAR2
,	x_return_status		OUT NOCOPY  VARCHAR2
,	p_label_type_info	IN INV_LABEL.label_type_rec DEFAULT NULL
,	p_transaction_id	IN NUMBER DEFAULT NULL
,	p_input_param		IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE DEFAULT NULL
,p_transaction_identifier IN NUMBER DEFAULT 0
);

FUNCTION get_uom_code(
	p_organization_id IN NUMBER
,	p_inventory_item_id IN NUMBER
,	p_unit_of_measure	IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_uom2_code(
	p_organization_id IN NUMBER
,	p_inventory_item_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_origination_type(p_origination_type IN NUMBER) RETURN VARCHAR2;

END INV_LABEL_PVT1;

/
